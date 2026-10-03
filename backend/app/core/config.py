from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "AgriSmart"
    debug: bool = False
    database_url: str = "sqlite:///./agrismart.db"
    jwt_secret: str = "change-this-secret-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 1440
    cors_allowed_origins: str = "http://localhost:3000,http://localhost:8080"
    hf_token: str = ""
    hf_disease_model: str = "prof-freakenstein/plantnet-disease-detection"
    hf_chat_model: str = ""
    open_meteo_base_url: str = "https://api.open-meteo.com"
    openrouter_api_key: str = ""
    openrouter_model: str = "openai/gpt-4o-mini"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def cors_origins(self) -> list[str]:
        return [item.strip() for item in self.cors_allowed_origins.split(",") if item.strip()]


settings = Settings()
