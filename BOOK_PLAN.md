# Book Plan

## Vision

Build a durable Salesforce engineering handbook that connects platform concepts
to production decisions. The book should support both targeted reference use and
structured learning, while remaining maintainable as Salesforce evolves.

## Audience

The primary audience includes:

- Salesforce technical and solution architects
- Salesforce developers and integration engineers
- Salesforce administrators and platform owners
- Delivery leads, reviewers, and governance teams
- Practitioners preparing to own production systems

Readers are expected to understand basic Salesforce terminology. Each chapter
should introduce specialized concepts before relying on them.

## Editorial principles

- Prefer durable concepts over release-specific feature tours.
- Separate verified platform behavior from recommendations and opinion.
- Explain tradeoffs, limits, failure modes, and operational consequences.
- Use realistic examples without exposing customer or confidential information.
- Link related topics instead of duplicating guidance.
- State the applicable Salesforce product, edition, or release when relevant.

## Planned structure

### Part I: Platform foundations

#### 1. Architecture

- [Architecture section](01_Architecture/)
- Platform boundaries and multitenancy
- Architecture decision records
- Common solution patterns and anti-patterns
- Environment and lifecycle architecture

#### 2. Data model

- [Data model section](02_Data_Model/)
- Standard and custom object strategy
- Relationships, ownership, and data skew
- Data quality, retention, archival, and deletion
- Large data volume considerations

#### 3. Security

- [Security section](03_Security/)
- Identity and authentication
- Profiles, permission sets, and permission set groups
- Organization-wide defaults, roles, teams, and sharing
- Encryption, auditability, and compliance controls

### Part II: Application behavior

#### 4. Automation

- [Automation section](04_Automation/)
- Automation selection framework
- Record-triggered and screen flows
- Orchestration, transactions, and recursion control
- Error handling, observability, and maintenance

#### 5. Integration

- [Integration section](05_Integration/)
- Integration architecture and system ownership
- REST, SOAP, Bulk, and Composite APIs
- Platform Events, Change Data Capture, and asynchronous patterns
- Authentication, retries, idempotency, and monitoring

#### 6. Development

- [Development section](06_Development/)
- Apex design and governor limits
- Lightning Web Components
- Testing strategy and test data
- Code quality, packaging, and maintainability

### Part III: Salesforce clouds

#### 7. Service Cloud

- [Service Cloud section](07_ServiceCloud/)
- Case lifecycle and support processes
- Omni-Channel routing and workload management
- Knowledge, entitlements, milestones, and digital engagement
- Service analytics and operational controls

#### 8. Sales Cloud

- [Sales Cloud section](08_SalesCloud/)
- Lead, account, contact, and opportunity design
- Territory, forecasting, and pipeline governance
- Activity management and productivity
- Data quality and revenue process controls

#### 9. Administration

- [Administration section](09_Admin/)
- Configuration ownership and change control
- User lifecycle and access operations
- Data operations, monitoring, and support
- Routine platform health checks

### Part IV: Production engineering

#### 10. DevOps

- [DevOps section](10_DevOps/)
- Source-driven development and branching
- Environment strategy and deployment pipelines
- Metadata dependencies and release management
- Rollback, recovery, and audit evidence

#### 11. Performance

- [Performance section](11_Performance/)
- Governor limits and capacity planning
- Query, transaction, and user-interface performance
- Diagnostics, telemetry, and incident investigation
- Performance testing and optimization

#### 12. Governance

- [Governance section](12_Governance/)
- Platform operating model and decision rights
- Standards, exceptions, and technical debt
- Risk, compliance, and architecture review
- Adoption, measurement, and continuous improvement

### Reference material

The [reference area](99_Reference/) will contain shared glossaries, decision
matrices, checklists, limit summaries, and other concise material used by several
chapters.

## Standard chapter shape

Use this structure when it suits the topic:

1. Purpose and scope
2. Context and prerequisites
3. Core concepts
4. Recommended approach
5. Implementation guidance
6. Security and data considerations
7. Limits and performance considerations
8. Operations and troubleshooting
9. Alternatives and tradeoffs
10. Validation checklist
11. Related topics and references

Short reference pages do not need every section, but they should preserve the
same emphasis on context, decisions, and validation.

## Definition of done

A chapter is publication-ready when it:

- has a clear audience and scope;
- distinguishes facts from recommendations;
- has been reviewed for technical accuracy;
- addresses security, limits, and operations where applicable;
- contains tested examples or explicitly labels illustrative examples;
- uses valid internal and external links;
- passes repository Markdown checks; and
- has no confidential, customer-specific, or unsupported claims.
