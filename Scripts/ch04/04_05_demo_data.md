# Demo Data — 04_05 Anomaly Detection

30-day slice of `daily_order_volume` for the 04_05 prompt demo.

**Context to include in the prompt:**
- Weekday average: ~85–90 orders
- Weekend average: ~40–50 orders
- Bank holidays: 40–60% of normal weekday volume

---

## daily_order_volume (Jan–Feb 2024)

| report_date | order_count | day_type |
|---|---|---|
| 2024-01-08 | 81 | weekday |
| 2024-01-09 | 80 | weekday |
| 2024-01-10 | 87 | weekday |
| 2024-01-11 | 87 | weekday |
| 2024-01-12 | 82 | weekday |
| 2024-01-13 | 44 | weekend |
| 2024-01-14 | 40 | weekend |
| 2024-01-15 | 76 | weekday |
| 2024-01-16 | 273 | weekday |
| 2024-01-17 | 82 | weekday |
| 2024-01-18 | 77 | weekday |
| 2024-01-19 | 83 | weekday |
| 2024-01-20 | 31 | weekend |
| 2024-01-21 | 40 | weekend |
| 2024-01-22 | 85 | weekday |
| 2024-01-23 | 82 | weekday |
| 2024-01-24 | 82 | weekday |
| 2024-01-25 | 90 | weekday |
| 2024-01-26 | 74 | weekday |
| 2024-01-27 | 45 | weekend |
| 2024-01-28 | 31 | weekend |
| 2024-01-29 | 74 | weekday |
| 2024-01-30 | 86 | weekday |
| 2024-01-31 | 30 | weekday |
| 2024-02-01 | 73 | weekday |
| 2024-02-02 | 84 | weekday |
| 2024-02-03 | 33 | weekend |
| 2024-02-04 | 46 | weekend |
| 2024-02-05 | 84 | weekday |
| 2024-02-06 | 70 | weekday |
| 2024-02-07 | 74 | weekday |
| 2024-02-08 | 83 | weekday |
| 2024-02-09 | 90 | weekday |
| 2024-02-10 | 34 | weekend |
| 2024-02-11 | 32 | weekend |
| 2024-02-12 | 85 | weekday |
| 2024-02-13 | 78 | weekday |
| 2024-02-14 | 80 | weekday |
| 2024-02-15 | 89 | weekday |
| 2024-02-16 | 82 | weekday |
| 2024-02-17 | 50 | weekend |
| 2024-02-18 | 32 | weekend |
| 2024-02-19 | 52 | weekday |
| 2024-02-20 | 38 | weekday |
| 2024-02-21 | 44 | weekday |
| 2024-02-22 | 68 | weekday |
| 2024-02-23 | 90 | weekday |
| 2024-02-24 | 45 | weekend |
| 2024-02-25 | 47 | weekend |
| 2024-02-26 | 71 | weekday |
| 2024-02-27 | 89 | weekday |
| 2024-02-28 | 72 | weekday |
| 2024-02-29 | 77 | weekday |

---

## What's in the data (for script reference — don't give this to AI upfront)

| Date | Value | What happened |
|---|---|---|
| 2024-01-16 | 273 | Large B2B restock order from a single Enterprise customer — one-off spike |
| 2024-01-31 | 30 | Unexplained — good candidate for AI to flag as "worth investigating" |
| 2024-02-19–22 | 52, 38, 44, 68 | Severe storm across North and East regions. Carrier suspended deliveries for 3 days. Orders recovered fully by Feb 23. |
| 2024-06-04 | 253 | Bulk pre-season restock order from a single Enterprise customer — same pattern as Jan 16. Legitimate spike, no data issue. |

---

## Demo flow suggestion

1. **Without weather context** — paste the table and baseline only. AI should flag Jan 16 (spike), Jan 31 (dip), and Feb 19–22 (sustained dip). For Feb 19–22 it should say "potential operational issue — investigate."
2. **Add weather context** — add a note: "A severe storm affected North and East regions 19–22 February, suspending carrier deliveries." Rerun. AI should now classify Feb 19–22 as explainable and Feb 23 recovery as confirmation the issue resolved. Jan 31 remains flagged as unexplained.
