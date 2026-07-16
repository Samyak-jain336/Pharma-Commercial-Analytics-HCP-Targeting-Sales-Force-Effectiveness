import pandas as pd
from sqlalchemy import create_engine, text

DB_USER     = "root"
DB_PASSWORD = "Samyak@336"
DB_HOST     = "127.0.0.1"
DB_PORT     = 3306
DB_NAME     = "pharmaanalytics"

engine_base = create_engine(
    "mysql+pymysql://",
    connect_args={
        "host"   : DB_HOST,
        "port"   : DB_PORT,
        "user"   : DB_USER,
        "passwd" : DB_PASSWORD
    }
)

with engine_base.connect() as conn:
    conn.execute(text("CREATE DATABASE IF NOT EXISTS pharmaanalytics"))
    conn.commit()

engine = create_engine(
    "mysql+pymysql://",
    connect_args={
        "host"   : DB_HOST,
        "port"   : DB_PORT,
        "user"   : DB_USER,
        "passwd" : DB_PASSWORD,
        "db"     : DB_NAME
    }
)

df = pd.read_csv(
    "C:/Users/samya/OneDrive/Documents/GitHub/Pharma-Commercial-Analytics-HCP-Targeting-Sales-Force-Effectiveness/hcp_pharma_enriched.csv",
    parse_dates=["week_start_date"]
)

df.columns = [c.lower().strip() for c in df.columns]

df.to_sql(
    name      = "hcp_marketing",
    con       = engine,
    if_exists = "replace",
    index     = False,
    chunksize = 5000,
    method    = "multi"
)

with engine.connect() as conn:
    result = conn.execute(text("SELECT COUNT(*) FROM hcp_marketing"))
    print(f"Rows loaded: {result.scalar():,}")
