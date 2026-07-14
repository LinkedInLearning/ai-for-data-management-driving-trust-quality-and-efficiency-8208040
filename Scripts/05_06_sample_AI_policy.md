# AI Use Policy — Data Team
*Version 1.0 · Owner: Head of Data · Last reviewed: [date]*

---

## What this covers

AI tools used for query writing, documentation, data analysis, and pipeline diagnosis.

---

## Approved tools

[List your approved tools here]. Any new tool must be approved before use.

---

## What you can send to AI

- Schema definitions and DDL
- Anonymised or synthetic data
- Code, error messages, and pipeline config
- Publicly available documentation

---

## What you cannot send to AI *(public/cloud models)*

- Customer PII — names, emails, addresses, IDs
- Financial records or payment data
- Internal credentials, connection strings, or API keys
- Any data classified as Confidential or Restricted under the data classification policy

---

## Before you use AI output

- **SQL queries:** run in a dev environment first, review logic before executing on production
- **Documentation:** check for invented facts — AI does not know your business rules
- **Any output feeding an automated process:** log it and get a second pair of eyes

---

## Who owns it

The person who uses AI output is responsible for it. "The AI wrote it" is not a defence. If you're not sure whether something is safe to send to AI, ask before you send it.

---

## Exceptions

On-premise or private model deployments may have a different data handling agreement — check with your manager before assuming the above rules apply.
