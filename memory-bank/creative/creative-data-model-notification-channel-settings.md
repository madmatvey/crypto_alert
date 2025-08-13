# 🎨 CREATIVE PHASE: DATA MODEL — NotificationChannel.settings

🎨🎨🎨 ENTERING CREATIVE PHASE: DATA MODEL 🎨🎨🎨

## Problem Statement
Define the `settings` JSONB structure for `NotificationChannel` per `kind`, and how to validate it.

## Requirements & Constraints
- Support at least two kinds: `log_file`, `email`
- Enforce presence/shape of required fields per kind
- Backwards-compatible for future kinds (e.g., telegram, webhook)
- Keep validations simple and testable

## OPTIONS ANALYSIS

### Option 1: JSONB + custom model validations (per-kind)
Description: Store flexible JSONB; validate presence/format of keys in model based on `kind`.
Pros:
- Simple, lightweight; no new dependencies
- Easy to extend for new kinds
Cons:
- Validation logic lives in model; must be kept tidy
Complexity: Low
Implementation Time: Short

### Option 2: JSON schema validation via gem
Description: Use a JSON schema validator gem to enforce structure.
Pros:
- Strong, explicit schemas; good error messages
Cons:
- Extra dependency; schemas maintenance overhead for small app
Complexity: Medium
Implementation Time: Medium

### Option 3: STI per kind (separate tables/columns)
Description: Split into subclassed models with dedicated columns.
Pros:
- Strong typing per kind; conventional validation
Cons:
- Overhead and schema churn for each new kind; premature complexity
Complexity: Medium-High
Implementation Time: Medium-High

## Decision
Choose Option 1: JSONB with per-kind custom validations.
Rationale: Minimal surface area, flexible for additions, aligns with app size.

## Settings Schema
- kind: `log_file`
  - settings:
    - path: string (default: `log/alerts.log` if blank)
    - format: enum ["plain", "json"] (default: "plain")
- kind: `email`
  - settings:
    - to: string/email (required)
    - subject_template: string (optional, default: "Alert: %{symbol} %{direction} %{threshold}")
    - from: string/email (optional)

## Validation Strategy
In `NotificationChannel`:
- Validate `kind` inclusion in [log_file, email]
- For `log_file`:
  - Coerce default `path` if blank
  - Validate `format` inclusion in [plain, json]
- For `email`:
  - Require `to` presence and basic email format
  - Optional `subject_template`/`from`
- Ensure `enabled` boolean defaults to true (column default)

## Implementation Plan
- Add `settings: :jsonb, null: false, default: {}`
- Add `enabled: boolean, default: true`
- Implement `validate_settings_by_kind` with case on `kind`
- Provide small helper methods to fetch typed settings with defaults
- Unit tests per kind: valid/invalid settings cases

## Example Settings
```json
// log_file
{
  "path": "log/alerts.log",
  "format": "plain"
}

// email
{
  "to": "alerts@example.com",
  "subject_template": "Alert: %{symbol} %{direction} %{threshold}"
}
```

## Verification
- Validations fail fast for missing/invalid keys
- Easy extension for future kinds without migrations
- Test coverage ensures reliability

🎨🎨🎨 EXITING CREATIVE PHASE — DECISION MADE 🎨🎨🎨
