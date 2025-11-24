from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.auto_pay import process_payment
import os

router = APIRouter(prefix="/auto-pay", tags=["auto-pay"])

class AutoPayRequest(BaseModel):
    user_id: str
    payment_type: str  # "qr" or "nfc"

@router.post("/simulate")
def simulate_auto_pay(request: AutoPayRequest):
    use_nfc = request.payment_type.lower() == "nfc"
    
    # QR 파일 경로 설정 (시뮬레이션용)
    # 현재 작업 디렉토리 기준
    qr_file = os.path.join("app", "services", "test_qr.png")
    
    # process_payment 호출
    result = process_payment(user_id=request.user_id, qr_file=qr_file, use_nfc=use_nfc, simulate=True)
    
    if not result:
         raise HTTPException(status_code=500, detail="Internal Server Error: No result returned")

    if result.get("status") == "error":
        raise HTTPException(status_code=400, detail=result.get("message"))
        
    return result
