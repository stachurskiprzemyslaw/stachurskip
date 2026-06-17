from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    db_host: str = os.getenv("DB_HOST", "localhost")
    db_port: int = int(os.getenv("DB_PORT", "1433"))
    db_name: str = os.getenv("DB_NAME", "baseFunds")
    db_user: str = os.getenv("DB_USER", "workshop_reader")
    db_password: str = os.getenv("DB_PASSWORD", "")
    db_encrypt: str = os.getenv("DB_ENCRYPT", "true")
    db_trust_server_cert: str = os.getenv("DB_TRUST_SERVER_CERT", "true")

    @property
    def odbc_connection_string(self) -> str:
        return (
            "DRIVER={ODBC Driver 18 for SQL Server};"
            f"SERVER={self.db_host},{self.db_port};"
            f"DATABASE={self.db_name};"
            f"UID={self.db_user};"
            f"PWD={self.db_password};"
            f"Encrypt={self.db_encrypt};"
            f"TrustServerCertificate={self.db_trust_server_cert};"
        )


settings = Settings()
