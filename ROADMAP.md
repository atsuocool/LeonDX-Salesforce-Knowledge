# Roadmap

This roadmap describes the planned evolution of the LeonDX Salesforce Knowledge
Base. It is directional and may change as priorities, platform releases, and
review capacity evolve.

## Guiding outcomes

- Establish a trustworthy, navigable source of Salesforce technical guidance.
- Publish reusable decision frameworks before isolated feature notes.
- Make security, scale, operations, and governance part of every relevant topic.
- Keep the documentation reviewable and maintainable over multiple releases.

## Delivery phases

- **Sprint 0 — Repository and editorial foundation:** In progress. Exit when
  governance, automation, planning, and style guidance are established.
- **Sprint 1 — Architecture and data foundations:** Planned. Exit when the
  initial architecture and data-model chapters are reviewed.
- **Sprint 2 — Security and automation:** Planned. Exit when core access and
  automation decision guidance is reviewed.
- **Sprint 3 — Integration and development:** Planned. Exit when the API, event,
  Apex, Lightning, and testing foundations are reviewed.
- **Sprint 4 — Service and Sales Cloud:** Planned. Exit when core cloud process
  and configuration guidance is reviewed.
- **Sprint 5 — Administration and DevOps:** Planned. Exit when operating and
  delivery practices are reviewed.
- **Sprint 6 — Performance and governance:** Planned. Exit when scale,
  diagnostics, controls, and the operating model are reviewed.
- **Ongoing — Maintenance and expansion:** Planned. Continue regular review of
  release-sensitive content.

## Sprint 0: Foundation

### Objectives

- Establish repository contribution and ownership controls.
- Automate Markdown formatting and link validation.
- Define the book architecture and standard chapter shape.
- Define editorial, terminology, source, and review standards.
- Publish a phased content roadmap and initial changelog.

### Completion criteria

- The root project documents are approved and merged.
- Pull requests use the repository templates and required review workflow.
- Markdown and link checks pass on `main`.
- Every planned knowledge area has a tracked directory.

## Sprint 1: Architecture and data foundations

Planned themes:

- Salesforce platform boundaries and architecture principles
- Architecture decision records and reusable solution patterns
- Object and relationship design
- Ownership, sharing dependencies, and data skew
- Data lifecycle, quality, retention, and large data volumes

## Sprint 2: Security and automation

Planned themes:

- Identity, authentication, authorization, and sharing
- Permission-set-led access management
- Automation selection and transaction boundaries
- Flow design, recursion control, and error handling
- Security and operational review checklists

## Sprint 3: Integration and development

Planned themes:

- Integration ownership and pattern selection
- APIs, events, asynchronous processing, and resilience
- Apex and Lightning Web Component engineering
- Testing strategy, test data, and code review
- Packaging and maintainability

## Sprint 4: Service Cloud and Sales Cloud

Planned themes:

- Case, routing, entitlement, and knowledge design
- Lead, account, opportunity, territory, and forecasting design
- Cross-cloud data and automation boundaries
- Operational reporting and data quality controls

## Sprint 5: Administration and DevOps

Planned themes:

- User, access, data, and configuration operations
- Source control and environment strategy
- Deployment pipelines and metadata dependencies
- Release, rollback, recovery, and audit practices

## Sprint 6: Performance and governance

Planned themes:

- Capacity, limits, query performance, and transaction performance
- Diagnostics, observability, and incident investigation
- Platform ownership, decision rights, and architecture review
- Standards, exceptions, technical debt, and continuous improvement

## Ongoing maintenance

After the foundational phases, maintainers will:

- triage reported gaps and corrections;
- review release-sensitive guidance on a regular cadence;
- repair stale references and links;
- consolidate duplicate or conflicting guidance;
- expand reference checklists and templates; and
- record notable changes in [CHANGELOG.md](CHANGELOG.md).

See the [book plan](BOOK_PLAN.md) for detailed subject coverage.
