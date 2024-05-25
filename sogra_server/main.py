from fastapi import FastAPI, HTTPException, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import List
import mysql.connector
from passlib.context import CryptContext
from dotenv import load_dotenv
import os
import logging
import time
import datetime

# .env 파일 로드
load_dotenv()

# FastAPI 앱 초기화
app = FastAPI(debug=True)
templates = Jinja2Templates(directory="sogra_server/templates")  # 경로 수정

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MySQL 연결 설정
db_config = {
    'user': 'root',
    'password': '0000',
    'host': 'localhost',
    'database': 'sogra'
}

# 암호화 설정 (bcrypt로 변경)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Restaurant(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float

class Menu(BaseModel):
    id: int
    restaurant_id: int
    name: str
    image_url: str

class User(BaseModel):
    id: int
    username: str
    email: str
    password: str

class UserMenu(BaseModel):
    user_id: int
    menu_id: int
    restaurant_id: int
    date_eaten: datetime.date

@app.post("/signup")
def signup(user: User):
    hashed_password = pwd_context.hash(user.password)
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)",
            (user.username, user.email, hashed_password)
        )
        conn.commit()
        conn.close()
        return {"msg": "User created successfully."}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))

@app.get("/restaurants", response_model=List[Restaurant])
def get_restaurants():
    start_time = time.time()
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM restaurants")
    result = cursor.fetchall()
    conn.close()
    logger.info(f"get_restaurants took {time.time() - start_time} seconds")
    return result

@app.get("/restaurants/{restaurant_id}/menus", response_model=List[Menu])
def get_menus(restaurant_id: int):
    start_time = time.time()
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM menus WHERE restaurant_id = %s", (restaurant_id,))
    result = cursor.fetchall()
    conn.close()
    logger.info(f"get_menus took {time.time() - start_time} seconds")
    return result

@app.post("/user_menu")
def add_user_menu(user_menu: UserMenu):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO user_menus (user_id, menu_id, restaurant_id, date_eaten) VALUES (%s, %s, %s, %s)",
            (user_menu.user_id, user_menu.menu_id, user_menu.restaurant_id, user_menu.date_eaten)
        )
        conn.commit()
        conn.close()
        return {"msg": "User menu added successfully"}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))

@app.get("/users", response_model=List[User])
def get_users():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, username, email, password FROM users")
        result = cursor.fetchall()
        conn.close()
        return result
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))

@app.get("/users/{user_id}/menus", response_model=List[UserMenu])
def get_user_menus(user_id: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM user_menus WHERE user_id = %s", (user_id,))
        result = cursor.fetchall()
        conn.close()
        return result
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))

@app.get("/restaurants/{restaurant_id}/menus/view", response_class=HTMLResponse)
async def view_menus(request: Request, restaurant_id: int):
    try:
        start_time = time.time()
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM menus WHERE restaurant_id = %s", (restaurant_id,))
        menu = cursor.fetchall()
        conn.close()
        logger.info(f"view_menus database query took {time.time() - start_time} seconds")

        start_time = time.time()
        response = templates.TemplateResponse("menu.html", {"request": request, "restaurant_id": restaurant_id, "menu": menu})
        logger.info(f"view_menus template rendering took {time.time() - start_time} seconds")
        return response
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
