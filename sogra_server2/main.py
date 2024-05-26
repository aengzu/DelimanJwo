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

import sys
import os

from routers import auth, user

# Load environment variables from .env file
load_dotenv()

# Define paths
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import database and models
try:
    from database import get_db
    from models import Users, Menu, Restaurant
except ModuleNotFoundError as e:
    print(f"Error: {e}. Please ensure that database.py and models.py are in the correct directory.")

# Initialize FastAPI app
app = FastAPI(debug=True)
templates = Jinja2Templates(directory="PythonProject3/templates")  # Ensure this path is correct

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MySQL connection settings
db_config = {
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', '0000'),
    'host': os.getenv('DB_HOST', 'localhost'),
    'database': os.getenv('DB_NAME', 'sogora')
}

# Password encryption settings
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Define Pydantic models
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

class User(BaseModel):
    id: int
    username: str
    email: str
    password: str
    rank: str  # Add rank to the User model

class UserMenu(BaseModel):
    user_id: int
    menu_id: int
    restaurant_id: int
    date_eaten: datetime.date

# SQLAlchemy asynchronous engine and session configuration
DATABASE_URL = os.getenv("DATABASE_URL").replace("pymysql", "aiomysql")
engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(
    bind=engine,
    expire_on_commit=False,
    class_=AsyncSession
)

# API Endpoints
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
async def add_user_menu(user_menu: UserMenu):
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

@app.get("/users", response_model=List[User])
async def get_users():
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(User))
            users = result.scalars().all()
    return users

@app.get("/users/{user_id}/menus", response_model=List[UserMenu])
async def get_user_menus(user_id: int):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(UserMenu).where(UserMenu.user_id == user_id))
            user_menus = result.scalars().all()
    return user_menus

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
        conn.close()
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

@app.put("/users/{user_id}/rank", response_model=str)
async def update_user_rank(user_id: int, rank: str, db: AsyncSession = Depends(get_db)):
    async with AsyncSessionLocal() as session:
        async with session.begin():
            result = await session.execute(select(Users).where(Users.user_id == user_id))
            user = result.scalar_one_or_none()
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            user.rank = rank
            await session.commit()
            return "User rank updated successfully"

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")

# Include additional routers
app.include_router(auth.router)
app.include_router(user.router)
