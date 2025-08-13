# 🎨 CREATIVE PHASE: UI/UX — Alerts & Channels

🎨🎨🎨 ENTERING CREATIVE PHASE: UI/UX 🎨🎨🎨

## Problem Statement
Design minimal, clear UI flows for managing Alerts and Notification Channels with accessible forms and validation feedback.

## Requirements & Constraints
- Simple lists and CRUD forms
- Validation errors visible and clear
- Toggle active/enabled flags quickly
- Use Hotwire (Turbo/Stimulus) where helpful, but keep simple

## OPTIONS ANALYSIS

### Option 1: Standard CRUD pages (index/new/edit) with Turbo for form updates
Description: Conventional Rails pages; Turbo Streams for create/update feedback; simple partial reuse.
Pros:
- Lowest complexity; fast to build and test
- Works well with Rails defaults
Cons:
- Toggles may require small Stimulus controller for snappy UX
Complexity: Low
Implementation Time: Short

### Option 2: Single-page index with nested Turbo Frames for forms
Description: Index hosts both lists and embedded forms in frames; actions update frames.
Pros:
- Few navigations; feels app-like
Cons:
- More Turbo wiring; higher template complexity
Complexity: Medium
Implementation Time: Medium

### Option 3: Stimulus-heavy SPA-like behavior
Description: Stimulus controllers manage state changes inline; minimal full-page reloads.
Pros:
- Very responsive UX
Cons:
- More JS to write and test; beyond current scope
Complexity: Medium-High
Implementation Time: Medium-High

## Decision
Choose Option 1: Standard CRUD with Turbo enhancements.
Rationale: Meets requirements with minimal complexity; easy to test.

## UI Structure
- Alerts
  - Index: table of alerts (symbol, direction, threshold, active); buttons: New, Edit, Delete; toggle Active (POST action)
  - New/Edit: form fields: symbol (select or text), direction (radio up/down), threshold (number), active (checkbox)
- Channels
  - Index: table (kind, enabled, settings summary); buttons: New, Edit, Delete; toggle Enabled
  - New/Edit: form fields based on kind
    - log_file: path, format
    - email: to, subject_template, from (optional)

## Forms & Validation
- Server-side validations with error summaries at top and inline field errors
- Use semantic labels and inputs; ensure keyboard navigation
- Number input for threshold with min > 0
- Direction radio buttons with clear labels

## Interactions
- Toggle endpoints for alert.active and channel.enabled (Turbo-friendly actions returning Turbo Stream or redirect)
- Flash messages on success/error

## Accessibility
- Labels tied to inputs; use fieldset/legend for grouped radios
- Sufficient contrast per style guide; focus states visible

## Implementation Plan
- Views: ERB templates with partials: `_form` for each resource
- Controllers: standard REST + `toggle_active`/`toggle_enabled` actions
- Routes: resources for alerts/channels; member routes for toggles
- Stimulus (optional): simple controller for optimistic toggle UI

## Verification
- Feature specs: create, edit, delete; see errors; toggle flags
- Usability: minimal clicks to complete tasks

🎨🎨🎨 EXITING CREATIVE PHASE — DECISION MADE 🎨🎨🎨
