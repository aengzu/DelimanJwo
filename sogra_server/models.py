from sqlalchemy import Column, Integer, String, ForeignKey, Date
from sqlalchemy.orm import relationship
from database import Base

class Users(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True, index=True)
    id = Column(String(100), unique=True, index=True)
    email = Column(String(100), unique=True, index=True)
    hashed_password = Column(String(255))
    rank = Column(String(100))

class Menu(Base):
    __tablename__ = 'menus'
    id = Column(Integer, primary_key=True, index=True)
    restaurant_id = Column(Integer, ForeignKey('restaurants.id'))
    name = Column(String(255))
    image_url = Column(String(255))

class Restaurant(Base):
    __tablename__ = 'restaurants'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))
    latitude = Column(String(255))
    longitude = Column(String(255))
    menus = relationship("Menu", back_populates="restaurant")

class UserMenu(Base):
    __tablename__ = 'user_menus'
    user_id = Column(Integer, ForeignKey('users.user_id'), primary_key=True)
    menu_id = Column(Integer, ForeignKey('menus.id'), primary_key=True)
    restaurant_id = Column(Integer, ForeignKey('restaurants.id'))
    date_eaten = Column(Date)
