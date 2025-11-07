"""인증 서비스"""
import hashlib
import secrets
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import User, UserCard
from app.schemas import UserRegister, UserLogin, UserResponse, TokenResponse
from fastapi import HTTPException, status


def hash_password(password: str) -> str:
    """비밀번호 해싱"""
    return hashlib.sha256(password.encode()).hexdigest()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """비밀번호 검증"""
    return hash_password(plain_password) == hashed_password


def generate_token() -> str:
    """간단한 토큰 생성 (실제 프로덕션에서는 JWT 사용)"""
    return secrets.token_urlsafe(32)


class AuthService:
    """인증 서비스"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def register_user(self, user_data: UserRegister) -> UserResponse:
        """사용자 등록"""
        
        # 중복 확인
        existing_user = (
            self.db.query(User)
            .filter(
                (User.username == user_data.username) | (User.email == user_data.email)
            )
            .first()
        )
        
        if existing_user:
            if existing_user.username == user_data.username:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="이미 사용 중인 아이디입니다"
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="이미 사용 중인 이메일입니다"
                )
        
        # 사용자 생성
        new_user = User(
            username=user_data.username,
            email=user_data.email,
            nickname=user_data.nickname,
            password_hash=hash_password(user_data.password),
            created_at=datetime.now().isoformat()
        )
        
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        
        return UserResponse.model_validate(new_user)
    
    def login_user(self, login_data: UserLogin) -> TokenResponse:
        """로그인"""
        
        user = (
            self.db.query(User)
            .filter(User.username == login_data.username)
            .first()
        )
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="아이디 또는 비밀번호가 올바르지 않습니다"
            )
        
        if not verify_password(login_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="아이디 또는 비밀번호가 올바르지 않습니다"
            )
        
        # 토큰 생성
        token = generate_token()
        
        return TokenResponse(
            access_token=token,
            user=UserResponse.model_validate(user)
        )
    
    def get_user_by_id(self, user_id: int) -> UserResponse:
        """사용자 조회"""
        user = self.db.query(User).filter(User.user_id == user_id).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="사용자를 찾을 수 없습니다"
            )
        
        return UserResponse.model_validate(user)
    
    def register_user_card(self, user_id: int, card_id: int) -> bool:
        """사용자 카드 등록"""
        
        # 이미 등록된 카드인지 확인
        existing = (
            self.db.query(UserCard)
            .filter(UserCard.user_id == user_id, UserCard.card_id == card_id)
            .first()
        )
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="이미 등록된 카드입니다"
            )
        
        # 카드 등록
        user_card = UserCard(
            user_id=user_id,
            card_id=card_id,
            registered_at=datetime.now().isoformat()
        )
        
        self.db.add(user_card)
        self.db.commit()
        
        return True
    
    def get_user_cards(self, user_id: int) -> list:
        """사용자 등록 카드 목록"""
        user_cards = (
            self.db.query(UserCard)
            .filter(UserCard.user_id == user_id)
            .all()
        )
        
        return [uc.card_id for uc in user_cards]
    
    def delete_user_card(self, user_id: int, card_id: int) -> bool:
        """사용자 카드 삭제"""
        
        user_card = (
            self.db.query(UserCard)
            .filter(UserCard.user_id == user_id, UserCard.card_id == card_id)
            .first()
        )
        
        if not user_card:
            return False
        
        self.db.delete(user_card)
        self.db.commit()
        
        return True


def get_auth_service(db: Session) -> AuthService:
    """인증 서비스 팩토리"""
    return AuthService(db)

