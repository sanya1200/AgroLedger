import sys
import os

# Add backend directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal, Base, engine
from sqlalchemy import text

# Import all models to ensure they are registered with Base.metadata
from app.models.user import User, UserSession, VerificationCode
from app.models.business_profile import BusinessProfile
from app.models.calculator import LivestockAsset, LivestockExpense, LivestockYield
from app.models.calendar import CalendarEvent
from app.models.marketplace import Product

def clear_database():
    print("Connecting to database...")
    db = SessionLocal()
    try:
        # Disable foreign key checks / truncate tables in dependency order
        # For Postgres, we can do TRUNCATE table_name CASCADE or just delete everything
        tables = ["verification_codes", "user_sessions", "livestock_yields", "livestock_expenses", "livestock_assets", "products", "calendar_events", "business_profiles", "users"]
        
        print("Clearing tables...")
        for table in tables:
            try:
                db.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE;"))
                print(f"Table '{table}' cleared successfully.")
            except Exception as e:
                # Fallback if CASCADE is not supported or table doesn't exist
                db.rollback()
                try:
                    db.execute(text(f"DELETE FROM {table};"))
                    print(f"Table '{table}' cleared using DELETE.")
                except Exception as ex:
                    db.rollback()
                    print(f"Could not clear table '{table}': {ex}")
        
        db.commit()
        print("Database successfully cleared!")
    except Exception as e:
        db.rollback()
        print(f"Error occurred: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_database()
