from __future__ import annotations

from datetime import date
from decimal import Decimal

from fastapi.testclient import TestClient

from app.main import app, get_service
from app.models import HoldingItem, NavResponse


class StubFundService:
    def get_nav_overview(self, fund_id: str, share_class_id: str, valuation_date: date) -> NavResponse:
        assert fund_id == "FUND-A"
        assert share_class_id == "FUND-A-ACC"
        assert valuation_date == date(2025, 2, 10)

        holdings = [
            HoldingItem(
                rank=1,
                instrumentId="INSTR-003",
                name="Nordwind Energy",
                quantity=Decimal("12000"),
                closePrice=Decimal("66.496000"),
                marketValue=Decimal("797952.000000"),
            ),
            HoldingItem(
                rank=2,
                instrumentId="INSTR-002",
                name="Aurora Tech",
                quantity=Decimal("8000"),
                closePrice=Decimal("88.315000"),
                marketValue=Decimal("706520.000000"),
            ),
            HoldingItem(
                rank=3,
                instrumentId="INSTR-001",
                name="Helios Industries",
                quantity=Decimal("5000"),
                closePrice=Decimal("124.680000"),
                marketValue=Decimal("623400.000000"),
            ),
            HoldingItem(
                rank=4,
                instrumentId="INSTR-004",
                name="Govt Bond 2030",
                quantity=Decimal("3000"),
                closePrice=Decimal("101.822000"),
                marketValue=Decimal("305466.000000"),
            ),
            HoldingItem(
                rank=5,
                instrumentId="INSTR-005",
                name="Corp Bond Helios",
                quantity=Decimal("2000"),
                closePrice=Decimal("104.939000"),
                marketValue=Decimal("209878.000000"),
            ),
        ]
        return NavResponse(
            fundId="FUND-A",
            fundName="Global Equity Fund",
            shareClassId="FUND-A-ACC",
            currency="EUR",
            valuationDate=date(2025, 2, 10),
            netAssetValue=Decimal("18046000.0000"),
            unitsOutstanding=Decimal("175000.0000"),
            navPerUnit=Decimal("103.120000"),
            topHoldings=holdings,
        )


def test_nav_endpoint_happy_path_matches_expected_values() -> None:
    app.dependency_overrides[get_service] = lambda: StubFundService()
    try:
        client = TestClient(app)
        response = client.get(
            "/funds/FUND-A/nav",
            params={"date": "2025-02-10", "shareClass": "FUND-A-ACC"},
        )
        assert response.status_code == 200

        payload = response.json()
        assert payload["fundId"] == "FUND-A"
        assert payload["shareClassId"] == "FUND-A-ACC"
        assert payload["navPerUnit"] == "103.120000"
        assert payload["unitsOutstanding"] == "175000.0000"
        assert len(payload["topHoldings"]) == 5
        assert payload["topHoldings"][0]["instrumentId"] == "INSTR-003"
        assert payload["topHoldings"][0]["marketValue"] >= payload["topHoldings"][1]["marketValue"]
    finally:
        app.dependency_overrides.clear()


def test_root_returns_mock_page() -> None:
    client = TestClient(app)
    response = client.get("/")

    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "Podglad NAV i najwiekszych pozycji funduszu." in response.text
