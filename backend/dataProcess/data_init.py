from dataProcess import init_data
import json
import os

cardID = [10344, 1408] # [10344, 1408, 10216, 1530, 115, 10343]
cards_data = []
cards_raw_benefitsdata = []

for id in cardID:
    cardData, cardBenefitsData = init_data(id)
    cards_data.append(cardData)
    cards_raw_benefitsdata.append(cardBenefitsData)

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
output_path = os.path.join(parent_dir, "app\dataset", "cards_data.json")
output_path2 = os.path.join(parent_dir, "app\dataset", "cards_raw_benefitsdata.json") 

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(cards_data, f, ensure_ascii=False, indent=4)
    
with open(output_path2, "w", encoding="utf-8") as f:
    json.dump(cards_raw_benefitsdata, f, ensure_ascii=False, indent=4)

print(f"Data saved to {output_path}")
print(f"Data saved to {output_path2}")