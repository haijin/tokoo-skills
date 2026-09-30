---
name: find-buyers-for-my-product
description: Use when an exporter or manufacturer describes what they make and wants to know who could buy it abroad, without a precise HS code or target market yet, e.g. "we manufacture aluminum window frames in Foshan, who should we sell to", "find overseas customers for our organic cashews", "which countries and companies buy products like ours", "help me find B2B buyers for our electric scooters in Europe". Drives the Tokoo API (api.tokoo.app / mcp.tokoo.app). It maps the product to HS codes, compares candidate destination markets by importer activity, then lists the strongest importers and their masked buyer contacts, with paid unlocks. Skip when the user already gives an HS code and a single destination country (use find-importers). Also skip consumer marketing, retail e-commerce customer acquisition, and finding suppliers to buy from.
version: "0.1.0"
metadata:
  api_base: https://api.tokoo.app/v1
  mcp_url: https://mcp.tokoo.app/mcp
  primary_tool: search_hs_codes
---

# find-buyers-for-my-product

Turn "here's what we make" into a ranked shortlist of markets and importers.
Read `reference.md` first for costs, errors and key handling.

## Workflow

1. **Understand the product.** Ask at most two questions, and only if you need
   to: what the product is (material, use) and where they ship from.
2. **Map it to HS codes.** Call `search_hs_codes` with 2-3 phrasings. Show the
   top 2-3 candidate codes with their descriptions, and let the user confirm or pick.
3. **Compare markets.**
   - Pick up to 5 destinations: the user's priorities, or common markets for
     that product.
   - For each one, call `search_importers` with `limit: 5`.
   - For each country, summarize: active importers found and typical shipment
     frequency. For the top 2-3 importers, `get_trade_history` shows whether
     they already buy from the user's country.
   - These calls are free, but stop at about 5 countries so you don't burn the
     daily cap (2,000 rows per org).
4. **Recommend 1-2 markets** and give the reason, for example "12 active
   importers, 7 already buying from Vietnam".
5. **Shortlist importers** in the chosen market by following the find-importers
   workflow: an evidence table, then `list_contacts`.
6. **Unlock only with consent.** Run a `confirm: false` preview, tell the user
   the exact credit cost and their balance, and wait for a yes.

## When NOT to use this skill

- The user already has an HS code and a country: use find-importers.
- Consumer or retail marketing ("get more Amazon customers").
- The user wants suppliers or factories to buy from.
