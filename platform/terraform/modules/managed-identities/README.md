# Managed identities module

Creates one user-assigned managed identity for each deployable CloudMart
component.

The input map uses stable CloudMart component keys, while the values contain
the Azure resource names. The module exposes four keyed maps:

- resource IDs
- client IDs
- principal IDs
- names

No Azure RBAC role assignments are created here. Identity creation and
authorization are intentionally kept separate so Lesson 36 answers
"who is the workload?" and Lesson 37 answers "what may it do?".
