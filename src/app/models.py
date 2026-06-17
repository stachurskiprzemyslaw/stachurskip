from __future__ import annotations

from datetime import date
from decimal import Decimal

from pydantic import BaseModel, Field


class HoldingItem(BaseModel):
    rank: int = Field(ge=1)
    instrumentId: str
    name: str
    quantity: Decimal
    closePrice: Decimal
    marketValue: Decimal


class NavResponse(BaseModel):
    fundId: str
    fundName: str
    shareClassId: str
    currency: str
    valuationDate: date
    netAssetValue: Decimal
    unitsOutstanding: Decimal
    navPerUnit: Decimal
    topHoldings: list[HoldingItem]
