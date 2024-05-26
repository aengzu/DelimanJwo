from datetime import timedelta, datetime
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from starlette import status
from pydantic import BaseModel
from typing import Annotated

from database import SessionLocal
from models import Users
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from jose import jwt, JWTError

router = APIRouter(
    prefix='/auth',
    tags=['auth']
)

SECRET_KEY = 'd268a22e7e8597fc23a62f76bd9f59cb8c14bb784c215b4ed08f2269f247bbe0'
ALGORITHM = 'HS256'

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
oauth2_bearer = OAuth2PasswordBearer(tokenUrl='auth/token')

class CreateUserRequest(BaseModel):
    id: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def authenticate_user(id: str, password: str, db: Session):
    user = db.query(Users).filter(Users.id == id).first()
    if not user or not bcrypt_context.verify(password, user.hashed_password):
        return False
    return user

def create_access_token(user_id: int, id: str, expires_delta: timedelta):
    encode = {'sub': str(user_id), 'id': id}  # user_id를 문자열로 변환
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(token: str = Depends(oauth2_bearer)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get('sub')
        id: str = payload.get('id')
        if not user_id or not id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Could not validate user')
        return {'id': id, 'user_id': user_id}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Could not validate user')

@router.post("/", response_model=Token, status_code=status.HTTP_201_CREATED)
async def create_user(create_user_request: CreateUserRequest = Body(), db: Session = Depends(get_db)):
    existing_user = db.query(Users).filter(Users.id == create_user_request.id).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="User ID already registered")

    hashed_password = bcrypt_context.hash(create_user_request.password)
    user = Users(
        id=create_user_request.id,
        hashed_password=hashed_password,
    )
    db.add(user)
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    token = create_access_token(user.user_id, user.id, timedelta(minutes=120))
    return {'access_token': token, 'token_type': 'bearer'}

@router.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(form_data.username, form_data.password, db)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Could not validate user')
    token = create_access_token(user.user_id, user.id, timedelta(minutes=20))
    return {'access_token': token, 'token_type': 'bearer'}
