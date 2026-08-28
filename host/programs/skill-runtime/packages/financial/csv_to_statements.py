"""Convert playground financial_statements.csv into ratio calculator input."""

from __future__ import annotations

import csv
from pathlib import Path
from typing import Any, Dict, Optional


def load_csv_period(
    csv_path: Path,
    period: str = "Q4_2024",
    share_price: float = 48.0,
    shares_outstanding: float = 5_000_000,
    earnings_growth_rate: float = 0.12,
) -> Dict[str, Any]:
    """
    Map a column period from financial_statements.csv into the nested dict
    expected by FinancialRatioCalculator.
    """
    rows: Dict[str, float] = {}
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if period not in (reader.fieldnames or []):
            raise ValueError(f"period {period!r} not in columns: {reader.fieldnames}")
        for row in reader:
            cat = row["Category"].strip()
            try:
                rows[cat] = float(row[period])
            except (TypeError, ValueError):
                continue

    revenue = rows.get("Revenue", 0)
    cogs = rows.get("Cost of Revenue", 0)
    op_inc = rows.get("Operating Income", 0)
    net = rows.get("Net Income", 0)
    interest = rows.get("Interest Expense", 0)
    # Approximate EBIT/EBITDA when not explicit
    ebit = op_inc
    ebitda = op_inc + rows.get("R&D Expenses", 0) * 0.1  # soft proxy only

    current_assets = rows.get("Current Assets", 0)
    current_liab = rows.get("Current Liabilities", 0)
    total_assets = rows.get("Total Assets", 0)
    total_liab = rows.get("Total Liabilities", 0)
    equity = rows.get("Shareholders Equity", 0)
    total_debt = max(total_liab - current_liab * 0.5, 0)  # coarse split

    return {
        "period": period,
        "income_statement": {
            "revenue": revenue,
            "cost_of_goods_sold": cogs,
            "operating_income": op_inc,
            "ebit": ebit,
            "ebitda": ebitda,
            "interest_expense": interest,
            "net_income": net,
        },
        "balance_sheet": {
            "total_assets": total_assets,
            "current_assets": current_assets,
            "cash_and_equivalents": current_assets * 0.25,
            "accounts_receivable": current_assets * 0.20,
            "inventory": current_assets * 0.20,
            "current_liabilities": current_liab,
            "total_debt": total_debt,
            "current_portion_long_term_debt": current_liab * 0.15,
            "shareholders_equity": equity,
        },
        "cash_flow": {
            "operating_cash_flow": rows.get("Operating Cash Flow", 0),
            "free_cash_flow": rows.get("Free Cash Flow", 0),
            "capex": rows.get("Capital Expenditures", 0),
        },
        "market_data": {
            "share_price": share_price,
            "shares_outstanding": shares_outstanding,
            "earnings_growth_rate": earnings_growth_rate,
        },
        "raw_rows": rows,
    }


def default_sample_path() -> Path:
    return Path(__file__).resolve().parent / "data" / "financial_statements.csv"
