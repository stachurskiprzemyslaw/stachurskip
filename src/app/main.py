from __future__ import annotations

from datetime import date
from pathlib import Path as FilePath

from fastapi import Depends, FastAPI, HTTPException, Path, Query
from fastapi.responses import FileResponse

from app.config import settings
from app.repository import FundRepository
from app.service import FundService, NotFoundError

app = FastAPI(title="Funds NAV API", version="0.1.0")
MOCK_PAGE_PATH = FilePath(__file__).with_name("static").joinpath("mock.html")


def get_service() -> FundService:
    repository = FundRepository(connection_string=settings.odbc_connection_string)
    return FundService(repository=repository)


@app.get("/")
def mock_page() -> FileResponse:
    return FileResponse(MOCK_PAGE_PATH)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/funds/{fund_id}/nav")
def get_fund_nav(
    fund_id: str = Path(pattern=r"^FUND-[A-Z0-9]+$"),
    date_value: date = Query(alias="date"),
    share_class: str = Query(alias="shareClass", pattern=r"^FUND-[A-Z0-9]+-[A-Z0-9]+$"),
    service: FundService = Depends(get_service),
):
    try:
        response = service.get_nav_overview(
            fund_id=fund_id,
            share_class_id=share_class,
            valuation_date=date_value,
        )
    except NotFoundError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc

    return response.model_dump(mode="json")
