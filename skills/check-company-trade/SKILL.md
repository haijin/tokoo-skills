---
name: check-company-trade
description: Use when the user names a specific company and wants to verify or understand its real import/export activity, e.g. "does Müller GmbH actually import stainless steel pipes", "what does Acme Trading Ltd buy and from where", "is this prospect a real importer or a middleman", "who are this company's suppliers", "how often does XYZ ship", "vet this buyer before we send samples". Drives the Tokoo API (www.tokoo.app). It resolves the company, then reports its trade history (HS mix, volumes over time, origin and destination lanes, counterparties) and firmographics, with optional masked contacts and paid unlocks. Skip credit ratings, financial statements, legal or sanctions screening, stock or investment analysis, and general company news. For lists of many companies, use find-importers or find-distributors instead.
version: "0.1.0"
metadata:
  api_base: https://www.tokoo.app/api/v1
  mcp_url: https://www.tokoo.app/api/mcp
  primary_tool: get_trade_history
---

# check-company-trade

Vet **one named company** against its real trade record. Read `reference.md`
first for costs, errors and key handling.

## Workflow

1. **Resolve the company.** Call `search_companies` with `q` (the name) and
   `country` if you know it. If several companies match, show the top 3 (name,
   city, domain) and ask which one. Similar names are common, so never assume a
   match from the name alone.
2. **Profile.** Call `get_company` for role (buyer/supplier/both), industry,
   size band, founded year and domain.
3. **Trade record.** Call `get_trade_history` (default `months: 24`, and pass
   `hs` if the user asked about a specific product). Report:
   - top HS codes with a plain-English description
   - shipment count and trend (growing, steady or fading), and the last
     shipment date
   - main origin and destination lanes
   - top counterparties (suppliers or customers), if the API returns them
4. **Answer the actual question in one line first**, then give the detail.
   Example: "Yes, 14 shipments of 7306 stainless pipe in the last 12 months,
   mostly from India". If the record is thin or empty, say so plainly: a
   company missing from the data isn't proof that it doesn't trade.
5. **Contacts on request.** Call `list_contacts`. Unlock only after a
   `confirm: false` cost preview and a yes.

## When NOT to use this skill

- Credit scores, financials, lawsuits, sanctions or KYC screening.
- Stock analysis or company news.
- Lists of many companies: use find-importers or find-distributors.
