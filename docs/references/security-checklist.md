# Security Checklist

Walk this before every PR. Think of it as unit tests for yourself.

## Input validation

- [ ] Every request body parsed by a **Pydantic model**, not raw `dict` or `Request.json()`.
- [ ] Every query/path parameter typed — FastAPI will validate.
- [ ] String fields have `max_length`; list fields have `max_items`. Unbounded = DoS surface.
- [ ] Numeric fields have `ge` / `le` bounds where semantically meaningful.
- [ ] Upload file size capped at the ASGI / reverse-proxy layer.

## AuthN / AuthZ

- [ ] Every non-public route has an auth dependency (`Depends(get_current_user)` or similar).
- [ ] AuthZ is checked **per resource**, not just per route. (A user can hit `GET /orders/{id}` — can they see *this* order?)
- [ ] Tokens verified against signature + expiry + issuer. No "trust me it's from the gateway."
- [ ] No secrets in logs, error messages, or stack traces. Assume log output is public.

## Data handling

- [ ] SQL queries use **parameter binding**. Never f-string / `%` interpolation into SQL.
- [ ] ORM queries use the ORM — no `execute(raw_sql_from_user_input)`.
- [ ] Output encoding: JSON response building uses `jsonable_encoder` / Pydantic serialization, not string concat.
- [ ] PII fields (email, phone, name) have a logging filter or are marked `SecretStr` / custom type.

## Secrets & config

- [ ] No secrets in code, commits, or CI logs. `.env` is gitignored.
- [ ] Settings loaded via `pydantic-settings` from env vars, not from hardcoded strings.
- [ ] Default secret values are **missing** (required field), not placeholders like `"changeme"`.
- [ ] Production secrets come from the deployment platform's secret store — never baked into images.

## External calls

- [ ] Every `httpx` / requests call has an explicit **timeout** (total + connect).
- [ ] Retries use bounded exponential backoff with a cap on total attempts.
- [ ] Circuit breaker or fallback for downstream that is required on the hot path.
- [ ] TLS verification enabled (never `verify=False` in production code).

## Dependencies

- [ ] New dependency justified in PR description (what, why, license check).
- [ ] Pinned in `pyproject.toml` with a lower bound that matches tested version.
- [ ] `uv lock --check` / `pip-audit` run in CI.
- [ ] No dependencies from unknown publishers / suspicious similar-name packages (typosquat check).

## Error handling

- [ ] Internal exceptions never leak to the client response body. Map to a sanitized error model.
- [ ] `500` responses don't include stack traces in production (check env-based debug flag).
- [ ] Correlation ID / request ID in every log line for traceability.

## Session / CORS / CSRF

- [ ] CORS origins: explicit allowlist, never `*` in production.
- [ ] Cookies: `Secure`, `HttpOnly`, `SameSite=Lax` (or stricter).
- [ ] CSRF protection on any session-cookie-authenticated state-changing route.

## Rate limiting

- [ ] Public endpoints have rate limits (middleware or upstream gateway).
- [ ] Expensive endpoints (auth, search, file upload) have stricter limits.

## Before merging

- [ ] `uv run pip-audit` (or equivalent) passes in CI
- [ ] No new `# type: ignore` or `# noqa: S...` (bandit codes) without a justification comment
- [ ] No new `eval`, `exec`, `pickle.loads(untrusted_input)`, `subprocess(shell=True)`

Upstream checklist (broader, covers frontend too): <https://github.com/addyosmani/agent-skills/blob/main/references/security-checklist.md>
