# Validation Rules

HBN validation is designed to remain explicit and inspectable.

## Rule Set

1. A request is not treated as HBN-active unless a valid trigger is detected.
2. Intent must be structured before higher-level protocol checks are applied.
3. Risk-sensitive requests should carry explicit validation requirements.
4. Unsupported claims should be flagged rather than silently accepted.
5. Missing uncertainty in risky contexts should be surfaced as a warning.
6. Consent must be explicit before any contribution record is created.
7. Assumptions should be documented when they affect behavior or interpretation.

## Traceability Requirement

Every significant protocol action should be explainable from one of the following:

- user input
- code
- schema
- documentation
- local warning or consent record

## Safety Requirement

Validation must not be bypassed to make the system feel smoother or faster. If a rule is too weak or too strict, it should be revised transparently rather than ignored.
