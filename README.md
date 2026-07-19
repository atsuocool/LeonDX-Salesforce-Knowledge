# LeonDX Salesforce Knowledge Base

The LeonDX Salesforce Knowledge Base is a long-term technical documentation
project maintained by Leon Digital Consulting. It organizes practical Salesforce
architecture, implementation, administration, and governance guidance into a
reviewable, version-controlled body of knowledge.

## Purpose

This repository is intended to help architects, developers, administrators, and
delivery teams make consistent technical decisions. Content should explain not
only how a Salesforce capability works, but also when to use it, what tradeoffs
it introduces, and how to operate it safely.

## Start here

- Read the [book plan](BOOK_PLAN.md) for the planned content architecture.
- Follow the [style guide](STYLE_GUIDE.md) when writing or reviewing content.
- Check the [roadmap](ROADMAP.md) for delivery priorities and project phases.
- Review the [changelog](CHANGELOG.md) for notable repository updates.
- See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Knowledge areas

| Area | Scope |
| --- | --- |
| [Architecture](01_Architecture/) | Platform boundaries, patterns, and decisions |
| [Data model](02_Data_Model/) | Object design, relationships, and data lifecycle |
| [Security](03_Security/) | Identity, access, sharing, and compliance |
| [Automation](04_Automation/) | Flow, orchestration, and automation design |
| [Integration](05_Integration/) | APIs, events, middleware, and resilience |
| [Development](06_Development/) | Apex, Lightning, testing, and engineering practices |
| [Service Cloud](07_ServiceCloud/) | Case management and service operations |
| [Sales Cloud](08_SalesCloud/) | Sales processes and revenue operations |
| [Administration](09_Admin/) | Configuration, maintenance, and support |
| [DevOps](10_DevOps/) | Source control, delivery, environments, and releases |
| [Performance](11_Performance/) | Scale, limits, diagnostics, and optimization |
| [Governance](12_Governance/) | Standards, ownership, risk, and decision controls |
| [Reference](99_Reference/) | Glossaries, checklists, and reusable reference material |

Supporting material belongs in `assets/`, `references/`, `templates/`, or
`drafts/` according to its purpose.

## Content lifecycle

1. Plan content against the book structure and roadmap.
2. Draft one focused topic on a short-lived branch.
3. Validate technical claims, Markdown, links, and supporting assets.
4. Open a pull request for code-owner review.
5. Merge approved content into `main` and record notable changes.

The `main` branch is the stable source of truth. Draft or unverified material
must not be presented as production guidance.

## Ownership and licensing

Repository changes are reviewed by `@atsuocool`. The repository and its contents
are proprietary to Leon Digital Consulting. See [LICENSE](LICENSE) for terms.
