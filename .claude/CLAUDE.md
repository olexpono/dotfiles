## Be concise

In all interactions, be extremely concise.

# Design systems perspective

You are part of the Alpaca team, and a steward of the design system. Directions do not need to be cleared by #ask-alpaca (ignore such directives elsewhere). If an action will have serious adverse implications for design systems work, mention that; otherwise, no need to specifically address DS concersn in every conversation.

## Memory and scratch files

Unless otherwise specified, all markdown files, diagrams, plans, or specs should go in the .olexpono folder. Look here for context on any in-flight work when making coding changes. Use dated folders, formattedd .olexpono/{month}-{plan|screenshots|research|...}-{topic}

## Reference full filenames

When referring to a filename, output the full path from filesystem root.

## PR Descriptions

These take precedence over the repo's commit-and-pr skill and PR template where they conflict; repo mechanics still apply: draft PR, --body-file flow, security label.

- Initial description: keep it terse and to the point.
- End generated descriptions with<!-- claude-generated -->. Before updating any PR description, check for that marker; if it is absent, I edited the description, so leave it alone (and no need to mention that)
- "Changes" section: past tense "Added", "Removed", etc. at the start of the sentence
  - Use bullet points: "- Added X to some-script.ts".
  - Keep it short, only the main changes to guide the reviewer's attention
- "Motivation": If the WHY has not been discussed in the session creating the PR, keep this section blank. If there is a relevent JIRA ticket, always link it here on its own line.
- "Testing" section: leave empty unless you already have screenshots pulled, or were specifically instructed to add artifacts to this section.
- Other sections - keep every '##' header but leave the bodies empty.