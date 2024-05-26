from pydantic import BaseModel
from typing import Optional

class UserRead(BaseModel):
    id: str
    rank: Optional[str] = None  # 선택적 필드로 설정

    class Config:
        orm_mode = True
