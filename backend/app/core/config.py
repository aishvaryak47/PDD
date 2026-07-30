from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "PSYNOVA AI Backend"
    API_V1_STR: str = "/api/v1"
    
    # Database Settings
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "psynova_db"
    POSTGRES_PORT: str = "5432"
    DATABASE_URL: Optional[str] = None

    @property
    def async_database_url(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return "sqlite+aiosqlite:///./psynova.db"

    # JWT Settings
    SECRET_KEY: str = "PSYNOVA_SUPER_SECRET_KEY_CHANGE_IN_PRODUCTION_2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30 # 30 days

    # AI Integration Settings
    GROQ_API_KEY: str = "gsk_dummy_key_replace_with_actual"
    GROQ_MODEL: str = "llama-3.3-70b-versatile"

    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
