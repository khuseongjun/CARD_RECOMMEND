import re

def parse_currency(text):
    text = text.replace(" ", "").replace("원", "")
    result = 0

    m = re.search(r'(\d+)만', text)
    if m:
        result += int(m.group(1)) * 10000

    c = re.search(r'(\d+)천', text)
    if c:
        result += int(c.group(1)) * 1000

    return result

def parse_annual_fee_text(text):
    annual_fee_domestic = 0
    annual_fee_international = 0

    for item in text.split(","):
        item = item.strip()
        if item.startswith("국내"):
            annual_fee_domestic = parse_currency(item.replace("국내", "").strip())
        elif item.startswith("해외"):
            annual_fee_international = parse_currency(item.replace("해외", "").strip())

    return annual_fee_domestic, annual_fee_international

def parse_min_spend_text(text):
    text = text.replace(" ", "")
    
    m = re.search(r'(\d+)\s*만', text)

    if not m:
        return 0

    min_monthly_spending = int(m.group(1)) * 10000
    
    return min_monthly_spending