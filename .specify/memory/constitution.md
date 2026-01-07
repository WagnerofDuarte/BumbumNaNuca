<!--
Sync Impact Report
- Version change: template → 1.0.0
- Modified principles: (added) I. Mobile-First SwiftUI Components → II. Test-First (NON-NEGOTIABLE) →
  III. Clean Architecture & Module Boundaries → IV. Observability & Privacy → V. Versioning & Compatibility
- Added sections: Additional Constraints, Development Workflow (governance details expanded)
- Removed sections: none
- Templates requiring updates:
  - .specify/templates/plan-template.md ✅ updated
  - .specify/templates/spec-template.md ✅ updated
  - .specify/templates/tasks-template.md ✅ updated
  - .specify/templates/commands/*.md ⚠ pending (directory not present)
  - README / docs/quickstart.md ⚠ pending (not found in repo root)
- Follow-up TODOs:
  - TODO(RATIFICATION_DATE): original adoption date unknown — project should set the official ratification date.
  - Verify iOS deployment target and Swift toolchain in project settings; update "Target Platform" constraint if needed.
-->

# BumbumNaNuca Constitution

## Core Principles

### I. Mobile‑First SwiftUI Components
Every UI feature MUST be implemented as small, reusable SwiftUI views and lightweight view models. Views
MUST be accessible (VoiceOver labels, dynamic type, contrast), localized where user-facing strings are
present, and documented with a short usage note. Components MUST be independently previewable and
independently testable.

Rationale: A component-driven approach increases reusability, simplifies testing, and improves
accessibility and localization across the app.

### II. Test‑First (NON‑NEGOTIABLE)
All new features and bug fixes MUST include automated tests before implementation completes. Unit tests
(XCTest) MUST cover view models, business logic and any parsing/formatting. UI tests (XCTest UI or
lightweight snapshot tests) MUST cover primary user flows for P1 stories. Tests MUST be run by CI on
every PR and MUST pass before merge.

Rationale: Tests prevent regressions and enable safe refactoring; a Test‑First discipline encourages
well-scoped, decoupled design.

### III. Clean Architecture & Module Boundaries
Code MUST be organized by feature (feature module or folder), not by technical role only. Public APIs
between features MUST be explicit and minimal. Dependencies between modules SHOULD be acyclic. Use
small protocols for dependency inversion; avoid leaking UI details into business logic.

Rationale: Clear boundaries reduce coupling, make ownership obvious, and simplify testing and
incremental release strategies.

### IV. Observability & Privacy
Integrate structured logging, crash reporting and minimal telemetry for feature usage and errors. Logs
MUST be structured and emitted at appropriate levels (DEBUG/INFO/WARN/ERROR). All telemetry and
logging that could contain user data MUST be reviewed and documented; sensitive data MUST NOT be
logged. Follow applicable privacy rules and respect user opt‑out for analytics.

Rationale: Observability is required for diagnosing issues in production while protecting user privacy.

### V. Versioning, Backwards Compatibility & Releases
Releases MUST follow Semantic Versioning for public artifacts (MAJOR.MINOR.PATCH). Breaking changes
that affect persisted data, on‑device configuration, or exported file formats MUST be clearly
documented, accompanied by a migration plan and a deprecation period. Minor/patch releases MUST be
used for backward-compatible improvements and fixes.

Rationale: Predictable versioning and migration rules reduce user disruption and simplify release
coordination.

## Additional Constraints
- Target Platform: iOS (SwiftUI). Minimum deployment target: iOS 17.0+.
- Language / Toolchain: Swift 5.9+ (use the repository's configured toolchain; default to current stable
  Swift supported by Xcode). If the project requires a specific Swift version, document it in
  docs/ or the README.
- Third‑party libraries: Each dependency MUST be justified, reviewed for size and privacy impact, and
  pinned. Prefer SPM packages; avoid large UI frameworks unless necessary.
- Security: Follow Apple platform best practices for secure storage (Keychain), network transport
  (TLS), and permissions.

## Development Workflow
- All work MUST be done on short‑lived feature branches and delivered via pull requests (PRs).
- Every PR MUST include: description of change, linked spec/issue, test coverage details, screenshots
  or recordings for UI changes, and a "Constitution Compliance" checklist referencing relevant
  principles.
- Code review: At least one approving review from a maintainer is REQUIRED for routine changes; two
  approvals are REQUIRED for changes that alter architecture, introduce new dependencies, or affect
  data formats.
- CI: PRs MUST pass automated tests, linting and formatting checks before merge.

## Governance
Amendments to this constitution MUST follow the process below:

1. Propose: Create a draft PR against `.specify/memory/constitution.md` describing the amendment,
   rationale, and migration steps if applicable.
2. Review period: The PR MUST remain open for at least 7 calendar days to allow commentary from
   maintainers and contributors.
3. Approvals: Amendments that are non‑breaking (clarifications, wording, new non‑enforced guidance)
   REQUIRE one maintainer approval. Material changes (new/removed principles, governance changes,
   breaking policy) REQUIRE two maintainers' approvals and a documented migration plan.
4. Ratification: Once approval requirements and the review period are met, merge the PR. The
   `Last Amended` date MUST be updated to the merge date.
5. Versioning: Follow semantic versioning for constitution edits: MAJOR for incompatible principle
   removals/redefinitions; MINOR for added principles or material expansions; PATCH for wording and
   non‑semantic clarifications.
6. Compliance reviews: Once per release cycle (or quarterly), maintainers MUST run a Constitution
   Compliance review of open plans/specs/tasks and create issues for violations.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): original adoption date unknown | **Last Amended**: 2025-12-20
