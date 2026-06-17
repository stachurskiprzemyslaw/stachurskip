from __future__ import annotations

from datetime import date

from app.models import HoldingItem, NavResponse
from app.repository import FundRepository


class NotFoundError(Exception):
    """Raised when no valuation data exists for input parameters."""


class FundService:
    def __init__(self, repository: FundRepository) -> None:
        self._repository = repository

    def get_nav_overview(self, fund_id: str, share_class_id: str, valuation_date: date) -> NavResponse:
        nav = self._repository.fetch_nav(
            fund_id=fund_id,
            share_class_id=share_class_id,
            valuation_date=valuation_date,
        )
        if nav is None:
            raise NotFoundError("No valuation data found for provided fund/share class/date.")

        holdings = self._repository.fetch_top_holdings(
            fund_id=fund_id,
            valuation_date=valuation_date,
            limit=5,
        )
        ranked_holdings = [
            HoldingItem(rank=index + 1, **item) for index, item in enumerate(holdings)
        ]

        return NavResponse(
            fundId=nav.fund_id,
            fundName=nav.fund_name,
            shareClassId=nav.share_class_id,
            currency=nav.currency,
            valuationDate=nav.valuation_date,
            netAssetValue=nav.net_asset_value,
            unitsOutstanding=nav.units_outstanding,
            navPerUnit=nav.nav_per_unit,
            topHoldings=ranked_holdings,
        )
