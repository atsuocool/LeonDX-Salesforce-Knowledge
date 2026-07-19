# Contributing

Thank you for helping maintain the LeonDX Salesforce Knowledge Base. These
guidelines keep contributions consistent, reviewable, and safe to publish.

## Branch strategy

The `main` branch is the stable source of truth and should remain releasable.
Create a short-lived branch from the latest `main` for each focused change.
Use a descriptive prefix and kebab-case name, for example:

- `docs/service-cloud-routing`
- `fix/broken-architecture-link`
- `chore/update-workflow`

Keep branches focused and rebase or merge the latest `main` before final review
when needed. Delete branches after they are merged.

## Pull request process

1. Confirm the branch contains one coherent change.
2. Review the rendered Markdown and all changed links locally.
3. Complete the pull request template, including related issues.
4. Mark the pull request ready only after all checklist items are complete.
5. Resolve automated checks and review feedback before merge.
6. Squash merge unless preserving separate commits adds meaningful history.

Do not mix unrelated documentation, formatting, and infrastructure changes in a
single pull request.

## Review workflow

Pull requests require review from the repository code owner. Reviewers check
technical accuracy, clarity, structure, links, formatting, and scope. Authors
should respond to every review thread and request another review after making
material updates. Approval does not override required status checks.

## Markdown writing standards

- Follow `STYLE_GUIDE.md` when it is present and applicable.
- Use one level-one heading per document and maintain a logical heading order.
- Write concise, descriptive headings and use sentence case.
- Use relative links for repository content and descriptive text for all links.
- Add a language identifier to fenced code blocks.
- Use spaces rather than tabs and remove trailing whitespace.
- Keep tables readable and use lists only when they improve scanning.
- Verify images include useful alternative text and use repository-relative
  paths.
- Run the repository Markdown and link checks before requesting review.

## Commit message conventions

Write imperative, present-tense commit subjects that describe the outcome. Keep
the subject concise and omit a trailing period. Use an optional body to explain
why a change is necessary or to document important tradeoffs.

Examples:

- `Document Service Cloud routing model`
- `Fix broken data model references`
- `Update Markdown validation workflow`

Reference an issue in the commit body when useful, such as `Refs #123` or
`Fixes #123`.
