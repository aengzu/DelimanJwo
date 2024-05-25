import sys
import os
from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import List
from passlib.context import CryptContext
from dotenv import load_dotenv
import logging
import time
import datetime
import aiomysql
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.future import select
from sqlalchemy.orm import sessionmaker

# 현재 파일의 디렉토리를 PYTHONPATH에 추가
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# database 모듈 임포트
try:
    from database import get_db
    from models import Users, Menu, Restaurant, UserMenu  # Users, Menu, Restaurant, UserMenu 임포트
except ModuleNotFoundError as e:
    print(f"Error: {e}. Please ensure that database.py and models.py are in the same directory as this script.")

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

# Pydantic 모델 정의
class RestaurantModel(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float

class MenuModel(BaseModel):
    id: int
    restaurant_id: int
    name: str
    image_url: str

class UserModel(BaseModel):
    user_id: int
    id: str
    hashed_password: str
    rank: str  # Add rank to the User model

class UserMenuModel(BaseModel):
    user_id: int
    menu_id: int
    restaurant_id: int
    date_eaten: datetime.date

# SQLAlchemy 비동기 엔진 및 세션 설정
DATABASE_URL = os.getenv("DATABASE_URL", "mysql+aiomysql://root:0000@localhost:3306/sogra")
engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(
    bind=engine,
    expire_on_commit=False,
    class_=AsyncSession
)

@app.get("/restaurants", response_model=List[RestaurantModel])
async def get_restaurants():
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(Restaurant))
            restaurants = result.scalars().all()
    return restaurants

@app.get("/restaurants/{restaurant_id}/menus", response_model=List[MenuModel])
async def get_menus(restaurant_id: int):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(Menu).where(Menu.restaurant_id == restaurant_id))
            menus = result.scalars().all()
    return menus

@app.post("/user_menu")
async def add_user_menu(user_menu: UserMenuModel):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            new_user_menu = UserMenu(
                user_id=user_menu.user_id,
                menu_id=user_menu.menu_id,
                restaurant_id=user_menu.restaurant_id,
                date_eaten=user_menu.date_eaten
            )
            session.add(new_user_menu)
            await session.commit()
    return {"msg": "User menu added successfully"}

@app.get("/users", response_model=List[UserModel])
async def get_users():
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(Users))  # select(User) -> select(Users)로 변경
            users = result.scalars().all()
    return users

@app.get("/users/{user_id}/menus", response_class=HTMLResponse)
async def get_user_menus(request: Request, user_id: int):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(UserMenu).where(UserMenu.user_id == user_id))
            user_menus = result.scalars().all()
    return templates.TemplateResponse("user_menu.html", {"request": request, "user_menus": user_menus})

@app.get("/restaurants/{restaurant_id}/menus/view", response_class=HTMLResponse)
async def view_menus(request: Request, restaurant_id: int):
    try:
        start_time = time.time()
        conn = await aiomysql.connect(
            host=db_config['host'],
            port=3306,
            user=db_config['user'],
            password=db_config['password'],
            db=db_config['database']
        )
        async with conn.cursor(aiomysql.DictCursor) as cursor:
            await cursor.execute("SELECT * FROM menus WHERE restaurant_id = %s", (restaurant_id,))
            menu = await cursor.fetchall()
        await conn.ensure_closed()
        logger.info(f"view_menus database query took {time.time() - start_time} seconds")

        start_time = time.time()
        response = templates.TemplateResponse("menu.html", {"request": request, "restaurant_id": restaurant_id, "menu": menu})
        logger.info(f"view_menus template rendering took {time.time() - start_time} seconds")
        return response
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

# New endpoints for handling user rank

@app.get("/users/{user_id}/rank", response_model=str)
async def get_user_rank(user_id: int, db: AsyncSession = Depends(get_db)):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(Users).where(Users.user_id == user_id))
            user = result.scalar_one_or_none()
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            return user.rank

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
