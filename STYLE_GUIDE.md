# Style Guide

This guide defines the editorial and Markdown standards for the LeonDX
Salesforce Knowledge Base. It supplements the contribution workflow in
[CONTRIBUTING.md](CONTRIBUTING.md).

## Voice and audience

Write for technical practitioners who need to make and defend production
decisions.

- Use clear, direct, professional language.
- Address the reader as "you" only when giving an instruction.
- Prefer active voice and concrete verbs.
- Explain acronyms on first use unless they are universally understood by the
  intended audience.
- Avoid marketing language, unsupported superlatives, and unnecessary jargon.
- Describe what is known; label recommendations, assumptions, and opinions.

## Document structure

- Use exactly one level-one heading (`#`) as the document title.
- Increase heading depth one level at a time.
- Use sentence case for headings.
- Begin with a short statement of purpose or scope.
- Keep sections focused and move reusable details to a dedicated page.
- Add related links near the relevant text or in a final related-topics section.

Do not number headings manually unless the number communicates an ordered method
or matches an established book structure.

## Markdown conventions

### Paragraphs and line breaks

Use blank lines between paragraphs, headings, lists, tables, block quotes, and
code blocks. Do not use trailing spaces to force line breaks.

### Lists

Use bullets for unordered collections and numbers for sequences. Write list
items with parallel grammar. Use sentence punctuation when items are complete
sentences.

### Links

- Use descriptive link text rather than "click here" or a raw URL.
- Use relative links for files and directories in this repository.
- Link to the most authoritative source available for external claims.
- Prefer durable documentation entry points over release-specific deep links.
- Check anchors after changing a heading.

### Code and technical values

Use backticks for commands, file names, metadata API names, object names, field
API names, and short code values. Use fenced code blocks for multi-line examples
and always include a language identifier.

```apex
Account accountRecord = new Account(Name = 'Example');
insert accountRecord;
```

Examples must be safe, minimal, and clearly labeled if they omit production
concerns such as bulkification, error handling, or authorization.

### Tables

Use tables for compact comparisons with consistent columns. Avoid tables for
long prose, procedural steps, or content that is difficult to read on a narrow
screen.

### Images and diagrams

- Store diagrams in `assets/diagrams/`, screenshots in `assets/images/`, and
  reusable icons in `assets/icons/`.
- Use meaningful, lowercase, kebab-case file names.
- Provide concise alternative text that communicates the image's purpose.
- Remove customer data, credentials, identifiers, and other sensitive details.
- Include a text explanation for important information shown visually.

## Salesforce terminology

- Use official Salesforce product and feature names.
- Use an API name when implementation precision matters and a label when
  describing the user experience.
- Put API names such as `Account`, `Case.OwnerId`, and `My_Custom_Field__c` in
  backticks.
- State whether guidance applies to a specific cloud, edition, license, release,
  or user interface.
- Avoid calling a feature "new" without naming the applicable release.

## Recommendations and cautions

Use explicit labels when the distinction helps the reader:

**Recommendation:** Prefer permission sets and permission set groups for
scalable access assignment.

**Caution:** Confirm current platform limits before applying a numeric value to
production capacity planning.

Use these callouts sparingly. A warning must state the risk and the action that
reduces it.

## Sources and verification

- Verify platform behavior against authoritative Salesforce documentation or a
  reproducible test.
- Record release-sensitive details close to the claim.
- Distinguish documented behavior from observed behavior.
- Do not copy substantial source text; summarize it and link to the source.
- Never include customer-confidential information or production credentials.

## File naming

Use uppercase names only for repository-level conventions such as `README.md`.
For knowledge pages, use descriptive `kebab-case.md` names unless a section has
adopted another documented convention.

Avoid vague names such as `notes.md`, `misc.md`, or `new-page.md`.

## Review checklist

Before requesting review, confirm that the document:

- has a clear purpose and audience;
- follows the planned repository structure;
- uses consistent terms and heading levels;
- explains tradeoffs and operational impact;
- identifies release-sensitive information;
- contains valid links and accessible images;
- passes Markdown validation; and
- contains no confidential or unsupported material.
