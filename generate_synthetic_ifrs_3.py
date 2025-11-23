import pandas as pd
import numpy as np

BASE_CSV_PATH = "IFRS_FCA_Report.csv"
OUTPUT_CSV_PATH = "IFRS_FCA_Report_1M_synthetic.csv"
TARGET_ROWS = 1_000_000
np.random.seed(42)

# -----------------------------------------------------------
# 1. CSV READ
# -----------------------------------------------------------

df_base = pd.read_csv(
    BASE_CSV_PATH,
    sep=";",            # SEMICOLON
    engine="python",
    encoding="latin1"   #  ENCODING 
)


print("Base rows:", len(df_base))

# -----------------------------------------------------------
# 2. 1M ENHANCED ROWS
# -----------------------------------------------------------
repeat_factor = int(np.ceil(TARGET_ROWS / len(df_base)))
df_big = pd.concat([df_base] * repeat_factor, ignore_index=True)
df_big = df_big.sample(TARGET_ROWS, random_state=42).reset_index(drop=True)

print("Expanded rows:", len(df_big))

# -----------------------------------------------------------
# 3. POLICY_ID DIVERSFY
# -----------------------------------------------------------
if "Policy_ID" in df_big.columns:
    df_big["Policy_ID"] = "P-" + (1000 + np.arange(TARGET_ROWS)).astype(str)

# -----------------------------------------------------------
# 4. CUSTOMER_ID & CUSTOMER_NAME CREATE
# -----------------------------------------------------------
# 150k CUSTOMER VARIATION
N_CUSTOMERS = 150_000

df_big["Customer_ID"] = ["CUST" + str(i % N_CUSTOMERS).zfill(6) for i in range(TARGET_ROWS)]

first_names = ["Alex", "Maria", "John", "Elena", "James", "Sofia",
               "David", "Emily", "Ahmet", "Ayşe", "Mehmet", "Zeynep"]

last_names = ["Smith", "Johnson", "Brown", "Miller", "Taylor",
              "Yılmaz", "Kaya", "Demir", "Öztürk", "Şahin"]

df_big["Customer_Name"] = [
    np.random.choice(first_names) + " " + np.random.choice(last_names)
    for _ in range(TARGET_ROWS)
]

# -----------------------------------------------------------
# 5. COUNTRY / LOCATION DIVERSFY
# -----------------------------------------------------------
country_list = ["UK", "DE", "FR", "NL", "TR", "IT", "ES", "US"]

df_big["Country"] = np.random.choice(country_list, size=TARGET_ROWS)

location_map = {
    "UK": ["London", "Manchester", "Cardiff"],
    "DE": ["Berlin", "Frankfurt", "Munich"],
    "FR": ["Paris", "Lyon", "Nice"],
    "NL": ["Amsterdam", "Rotterdam", "Utrecht"],
    "TR": ["Istanbul", "Ankara", "Izmir"],
    "IT": ["Rome", "Milan", "Florence"],
    "ES": ["Madrid", "Barcelona", "Valencia"],
    "US": ["New York", "Chicago", "LA"]
}

df_big["Location"] = df_big["Country"].apply(lambda c: np.random.choice(location_map[c]))

# -----------------------------------------------------------
# 6. PRODUCT_ID / PRODUCT_NAME / PRODUCT_TYPE DIVERSFY
# -----------------------------------------------------------
product_pool = pd.DataFrame({
    "Product_ID": ["PR-01", "PR-02", "PR-03", "PR-04", "PR-05"],
    "Product_Name": ["TravelCare Basic", "TravelCare Premium", "HealthProtect", "AutoShield", "LifeAssure Basic"],
    "Product_Type": ["Travel", "Travel", "Health", "Auto", "Life"]
})

sampled = product_pool.sample(n=TARGET_ROWS, replace=True).reset_index(drop=True)

df_big["Product_ID"] = sampled["Product_ID"]
df_big["Product_Name"] = sampled["Product_Name"]
df_big["Product_Type"] = sampled["Product_Type"]

# -----------------------------------------------------------
# 7. FILL EMPTY ROWS (Regulatory etc.)
# -----------------------------------------------------------
fill_cols_default = {
    "Regulatory_Framework": "IFRS17",
    "Risk_Exposure_Category": "Medium",
}

for col, val in fill_cols_default.items():
    if col in df_big.columns:
        df_big[col] = df_big[col].fillna(val)

# -----------------------------------------------------------
# 8. WRU-ITE THE FILE
# -----------------------------------------------------------
df_big.to_csv(OUTPUT_CSV_PATH, index=False, encoding="utf-8")
print("Created:", OUTPUT_CSV_PATH)
