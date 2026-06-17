from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from decimal import Decimal


@dataclass
class NavAggregate:
    fund_id: str
    fund_name: str
    share_class_id: str
    currency: str
    valuation_date: date
    net_asset_value: Decimal
    units_outstanding: Decimal
    nav_per_unit: Decimal


class FundRepository:
    def __init__(self, connection_string: str) -> None:
        self._connection_string = connection_string

    def _connect(self):
        import pyodbc

        return pyodbc.connect(self._connection_string, autocommit=False)

    def fetch_nav(self, fund_id: str, share_class_id: str, valuation_date: date) -> NavAggregate | None:
        sql = """
        SELECT
            f.FundId,
            f.Name AS FundName,
            sc.ShareClassId,
            sc.Currency,
            v.ValuationDate,
            v.NetAssetValue,
            CAST(ISNULL(s.sub_units, 0) - ISNULL(r.red_units, 0) AS DECIMAL(20,4)) AS UnitsOutstanding,
            v.NavPerUnit
        FROM dbo.Fund f
        INNER JOIN dbo.ShareClass sc
            ON sc.FundId = f.FundId
        INNER JOIN dbo.Valuation v
            ON v.ShareClassId = sc.ShareClassId
           AND v.ValuationDate = ?
        LEFT JOIN (
            SELECT ShareClassId, SUM(Units) AS sub_units
            FROM dbo.Subscription
            WHERE TradeDate <= ?
            GROUP BY ShareClassId
        ) s ON s.ShareClassId = sc.ShareClassId
        LEFT JOIN (
            SELECT ShareClassId, SUM(Units) AS red_units
            FROM dbo.Redemption
            WHERE TradeDate <= ?
            GROUP BY ShareClassId
        ) r ON r.ShareClassId = sc.ShareClassId
        WHERE f.FundId = ?
          AND sc.ShareClassId = ?
        """
        params = (valuation_date, valuation_date, valuation_date, fund_id, share_class_id)

        with self._connect() as conn:
            cursor = conn.cursor()
            row = cursor.execute(sql, params).fetchone()
            if row is None:
                return None

            return NavAggregate(
                fund_id=row.FundId,
                fund_name=row.FundName,
                share_class_id=row.ShareClassId,
                currency=row.Currency,
                valuation_date=row.ValuationDate,
                net_asset_value=row.NetAssetValue,
                units_outstanding=row.UnitsOutstanding,
                nav_per_unit=row.NavPerUnit,
            )

    def fetch_top_holdings(self, fund_id: str, valuation_date: date, limit: int = 5) -> list[dict]:
        sql = """
        SELECT TOP (?)
            i.InstrumentId,
            i.Name,
            h.Quantity,
            p.ClosePrice,
            CAST(h.Quantity * p.ClosePrice AS DECIMAL(20,6)) AS MarketValue
        FROM dbo.Holding h
        INNER JOIN dbo.Instrument i
            ON i.InstrumentId = h.InstrumentId
        INNER JOIN dbo.PriceEOD p
            ON p.InstrumentId = h.InstrumentId
           AND p.PriceDate = ?
        WHERE h.FundId = ?
          AND h.AsOfDate = ?
        ORDER BY MarketValue DESC, i.InstrumentId ASC
        """
        params = (limit, valuation_date, fund_id, valuation_date)

        with self._connect() as conn:
            cursor = conn.cursor()
            rows = cursor.execute(sql, params).fetchall()

        return [
            {
                "instrumentId": row.InstrumentId,
                "name": row.Name,
                "quantity": row.Quantity,
                "closePrice": row.ClosePrice,
                "marketValue": row.MarketValue,
            }
            for row in rows
        ]
