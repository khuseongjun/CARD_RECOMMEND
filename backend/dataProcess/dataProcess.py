from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import requests
import time
from func import parse_annual_fee_text, parse_min_spend_text

# -------------------------------------------------------
# 카드 데이터 가져오기 (Selenium + BeautifulSoup)
# -------------------------------------------------------
def getCardData(cardID):
    # Selenium 
    options = Options()
    options.add_argument("--headless")
    driver = webdriver.Chrome(options=options)

    url = f"https://card-search.naver.com/item?cardAdId={cardID}"
    driver.get(url)

    details_elements = driver.find_elements(By.CSS_SELECTOR, ".Benefits .inner .details")
    for detail in details_elements:
        try:
            driver.execute_script("arguments[0].querySelector('summary').click();", detail)
            time.sleep(0.3)
        except:
            pass

    time.sleep(1)

    html = driver.page_source
    driver.quit()

    soup = BeautifulSoup(html, "html.parser")

    # 카드 전체
    card = soup.select_one(".cardItem")

    # 카드사
    apply = card.select_one(".apply")
    apply = apply["href"] if apply else None

    apply_url = requests.get(apply, allow_redirects=True, timeout=10).url

    issuers = {
        "shinhancard": "신한",
        "samsungcard": "삼성",
        "kbcard": "KB국민",
        "wooricard": "우리",
    }

    issuer = None
    for key, val in issuers.items():
        if key in apply_url:
            issuer = val
            break

    # 카드 이름
    nme = card.select_one(".cardname .txt")
    name = nme.get_text(strip=True) if nme else None

    # 연회비
    annual = card.select_one(".desc.as_annualFee .txt")
    annual_fee_text = annual.get_text(strip=True) if annual else None

    # 기준 실적
    min_spend = card.select_one(".desc.as_baseRecord .txt")
    min_spend_text = min_spend.get_text(strip=True) if min_spend else None

    # 카드 이미지
    img = card.select_one(".BaseInfo .img")
    image_url = img["src"] if img else None

    # 주요 혜택
    benefits = {
        "카페/베이커리": None,
        "대중교통": None,
        "편의점": None,
        "영화": None
    }

    for benefit_tag in card.select(".Benefits .details"):
        category = benefit_tag.select_one("b.text").get_text(strip=True)
        dl_list = benefit_tag.select_one("div.detail dl.list")
        if not dl_list:
            continue

        detail_benefits = {}
        title = None

        for child in dl_list.children:
            if child.name == "dt" and "detail_title" in child.get("class", []):
                title = child.get_text(strip=True)
                detail_benefits[title] = []
            elif child.name == "dd" and "desc" in child.get("class", []) and title:
                detail_benefits[title].append(child.get_text(strip=True))

        benefits[category] = detail_benefits

    return name, issuer, annual_fee_text, min_spend_text, image_url, benefits

# -------------------------------------------------------
# 데이터 전처리
# -------------------------------------------------------
def dataProcess(annual_fee_text, min_spend_text, benefits):
    
    annual_fee_domestic, annual_fee_international = parse_annual_fee_text(annual_fee_text)
    min_monthly_spending = parse_min_spend_text(min_spend_text)

    return annual_fee_domestic, annual_fee_international, min_monthly_spending, benefits


# -------------------------------------------------------
# 전체 초기 데이터 구성
# -------------------------------------------------------
def init_data(cardID):
    name, issuer, annual_fee_text, min_spend_text, image_url, benefits = getCardData(cardID)

    annual_fee_domestic, annual_fee_international, min_monthly_spending, benefits = dataProcess(annual_fee_text, min_spend_text, benefits)

    cardData = {
        "id": str(cardID),
        "name": name,
        "issuer": issuer,
        "card_type": ["credit"],
        "benefit_types": ["discount"],
        "annual_fee_domestic": annual_fee_domestic,
        "annual_fee_international": annual_fee_international,
        "min_monthly_spending": min_monthly_spending,
        "image_url": image_url  
    }
    
    cardBenefitsData = {
        "card_id": str(cardID),
        "benefits": benefits
    }

    return cardData, cardBenefitsData


# -------------------------------------------------------
# 실행 테스트
# -------------------------------------------------------
if __name__ == "__main__":
    cardID = 10344
    cardData, cardBenefitsData = init_data(cardID)
    print("성공!")