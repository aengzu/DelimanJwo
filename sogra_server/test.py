from passlib.context import CryptContext

# 암호화 설정 (argon2로 변경)
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

# 비밀번호 해싱
hashed_password = pwd_context.hash("my_password")
print("Hashed Password:", hashed_password)

# 비밀번호 검증
is_valid = pwd_context.verify("my_password", hashed_password)
print("Password is valid:", is_valid)
