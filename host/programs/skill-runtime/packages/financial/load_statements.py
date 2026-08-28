"""Load and validate financial JSON for ratios / DCF (real mode)."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Tuple


class DataQualityError(ValueError):
    """Raised when real-mode data is incomplete or invalid."""


def _require_numbers(obj: dict, fields: List[str], prefix: str) -> List[str]:
    missing = []
    for f in fields:
        if f not in obj or obj[f] is None:
            missing.append(f"{prefix}.{f}")
        else:
            try:
                float(obj[f])
            except (TypeError, ValueError):
                missing.append(f"{prefix}.{f} (not numeric)")
    return missing


def load_statements_json(path: Path) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """
    Load statements.v1 JSON.

    Returns (statements_for_calculator, meta) where meta includes mode, assumptions, data_quality.
    Raises DataQualityError if required fields missing.
    """
    path = Path(path).expanduser()
    if not path.exists():
        raise DataQualityError(f"statements file not found: {path}")
    raw = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise DataQualityError("statements root must be an object")

    inc = raw.get("income_statement") or {}
    bal = raw.get("balance_sheet") or {}
    if not isinstance(inc, dict) or not isinstance(bal, dict):
        raise DataQualityError("income_statement and balance_sheet must be objects")

    missing = []
    missing += _require_numbers(inc, ["revenue", "net_income"], "income_statement")
    missing += _require_numbers(bal, ["total_assets", "shareholders_equity"], "balance_sheet")
    if missing:
        raise DataQualityError(
            "real-mode statements incomplete; missing required fields: " + ", ".join(missing)
        )

    # Optional but recommended — track quality without inventing values
    recommended = {
        "income_statement": ["cost_of_goods_sold", "operating_income", "ebit", "ebitda", "interest_expense"],
        "balance_sheet": [
            "current_assets",
            "cash_and_equivalents",
            "accounts_receivable",
            "inventory",
            "current_liabilities",
            "total_debt",
        ],
        "market_data": ["share_price", "shares_outstanding"],
    }
    warnings = []
    for section, fields in recommended.items():
        block = raw.get(section) or {}
        for f in fields:
            if f not in block or block[f] is None:
                warnings.append(f"{section}.{f}")

    statements = {
        "company": raw.get("company"),
        "period": raw.get("period"),
        "income_statement": dict(inc),
        "balance_sheet": dict(bal),
        "cash_flow": dict(raw.get("cash_flow") or {}),
        "market_data": dict(raw.get("market_data") or {}),
    }

    meta = {
        "mode": "real",
        "source": str(path),
        "company": raw.get("company"),
        "period": raw.get("period"),
        "currency": raw.get("currency", "USD"),
        "data_quality": {
            "status": "ok_with_warnings" if warnings else "ok",
            "required_ok": True,
            "missing_recommended": warnings,
            "proxies_used": [],
            "note": "No silent proxies in real mode; missing recommended fields reduce ratio coverage.",
        },
        "assumptions": {
            "demo": False,
            "interpretation": "industry benchmarks are generic, not company-specific",
        },
    }
    return statements, meta


def load_dcf_case_json(path: Path) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """Load dcf_case.v1 JSON. Fail loud on missing history."""
    path = Path(path).expanduser()
    if not path.exists():
        raise DataQualityError(f"dcf case file not found: {path}")
    raw = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise DataQualityError("dcf case root must be an object")

    company = raw.get("company") or "Company"
    hist = raw.get("historical") or {}
    if not isinstance(hist, dict):
        raise DataQualityError("historical must be an object")

    years = hist.get("years") or []
    revenue = hist.get("revenue") or []
    ebitda = hist.get("ebitda") or []
    if len(years) < 2 or len(revenue) < 2 or len(ebitda) < 2:
        raise DataQualityError(
            "real-mode DCF requires historical.years, revenue, ebitda with at least 2 points each"
        )
    if not (len(years) == len(revenue) == len(ebitda)):
        raise DataQualityError("historical years/revenue/ebitda length mismatch")

    n = len(revenue)
    capex = hist.get("capex")
    nwc = hist.get("nwc")
    proxies = []
    if not capex or len(capex) != n:
        capex = [r * 0.05 for r in revenue]
        proxies.append("historical.capex defaulted to 5% of revenue")
    if not nwc or len(nwc) != n:
        nwc = [r * 0.10 for r in revenue]
        proxies.append("historical.nwc defaulted to 10% of revenue")

    assumptions = dict(raw.get("assumptions") or {})
    wacc = dict(raw.get("wacc") or {})
    equity = dict(raw.get("equity") or {})

    # Defaults only when keys absent — recorded in assumptions meta
    defaulted = []
    if "projection_years" not in assumptions:
        assumptions["projection_years"] = 5
        defaulted.append("assumptions.projection_years=5")
    if "tax_rate" not in assumptions:
        assumptions["tax_rate"] = 0.25
        defaulted.append("assumptions.tax_rate=0.25")
    if "terminal_growth" not in assumptions:
        assumptions["terminal_growth"] = 0.025
        defaulted.append("assumptions.terminal_growth=0.025")

    wacc_defaults = {
        "risk_free_rate": 0.04,
        "beta": 1.1,
        "market_premium": 0.05,
        "cost_of_debt": 0.055,
        "debt_to_equity": 0.4,
        "tax_rate": assumptions.get("tax_rate", 0.25),
    }
    for k, v in wacc_defaults.items():
        if k not in wacc:
            wacc[k] = v
            defaulted.append(f"wacc.{k}={v}")

    equity_defaults = {"net_debt": 0.0, "cash": 0.0, "shares_outstanding": 100.0}
    for k, v in equity_defaults.items():
        if k not in equity:
            equity[k] = v
            defaulted.append(f"equity.{k}={v}")

    case = {
        "company": company,
        "historical": {
            "years": [float(x) for x in years],
            "revenue": [float(x) for x in revenue],
            "ebitda": [float(x) for x in ebitda],
            "capex": [float(x) for x in capex],
            "nwc": [float(x) for x in nwc],
        },
        "assumptions": assumptions,
        "wacc": wacc,
        "equity": equity,
    }
    meta = {
        "mode": "real",
        "source": str(path),
        "company": company,
        "data_quality": {
            "status": "ok_with_defaults" if (proxies or defaulted) else "ok",
            "required_ok": True,
            "proxies_used": proxies,
            "defaults_applied": defaulted,
            "note": "Historical revenue/ebitda required; other series may use documented defaults.",
        },
        "assumptions": {
            "demo": False,
            "model": "FCFF DCF with Gordon growth terminal value",
            "units": "same as input history (typically $M)",
        },
    }
    return case, meta
