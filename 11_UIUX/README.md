# 11_UIUX — AI-07 Owned Workspace (UI/UX / Motion / Accessibility)

Owner: **AI-07**
Branch: `ai-07-uiux`
Status: Phase 00 (Product/IP Lock) — UX contribution

## Purpose

This directory is the canonical, clearly bounded home for AI-07 artifacts that are not yet
engine code: UX product-lock documents, accessibility/comfort baselines, AI-07-owned contract
drafts, deterministic fixtures, lightweight validators and evidence.

When the Unity project exists (Phase 02), runtime UI code will live in the owner path agreed
in Phase 01 ownership freeze. Nothing in this folder is a runtime dependency.

## Structure

| Path | Content |
|---|---|
| `phase_00/` | Phase 00 UX product lock, terminology usage, integration requests, handoff |
| `contracts/` | AI-07-owned contract drafts (currently `AccessibilityPreference` DRAFT) |
| `fixtures/` | Deterministic fixtures for AI-07-owned contracts (usable by AI-04/08/10/11 as mocks) |
| `tools/` | Stdlib-only validators for the fixtures/schemas in this folder |
| `evidence/` | Exact commands and results backing claims in handoffs |

## Ownership firewall

AI-07 does **not** edit: domain rules, gameplay logic, asset source files, audio, CI, story
canon, localization keys (AI-09), contracts owned by other accounts. Cross-track needs are
written as integration requests in `phase_00/INTEGRATION_REQUESTS_AI07.md`.

## Contract status legend

`DRAFT` artifacts here are **not consumable** until marked `FROZEN`/`RELEASED` through the
Phase 01 contract freeze (`06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`).
