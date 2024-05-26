from fastapi import APIRouter, Depends, HTTPException
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from typing import Annotated
from starlette import status

from models import Users
from routers.auth import get_db, oauth2_bearer, SECRET_KEY, ALGORITHM
from schemas import UserRead

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

async def get_current_user(token: str = Depends(oauth2_bearer)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = int(payload.get('sub'))
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid token')
        return user_id
    except JWTError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f'JWT Error: {str(e)}')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {str(e)}')

@router.get("/me", response_model=UserRead)
async def get_user_me(user_id: int = Depends(get_current_user), db: Session = Depends(get_db)):
    user = db.query(Users).filter(Users.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
