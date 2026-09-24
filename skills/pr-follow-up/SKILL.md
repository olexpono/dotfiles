---
name: pr-follow-up
description: Follow up on the least-recently-active PR across bop categories [2] and [3], determine what would advance it, then confirm next steps with the user.
---

# PR Follow-up

From the repository being checked, run:

```bash
python3 /home/vscode/dotfiles/.local/bin/pr-status.py -vv
```

Do not rely on the `bop` alias; agent shells typically do not load it. If the
working directory is not the target repository, pass `--repo OWNER/NAME`.

Select the PR with the oldest `last activity` across categories `[2]` and `[3]`.
The `-vv` view orders each category by that value, so compare the first entry in
each. Completed follow-up activity moves a PR later and naturally rotates the
next invocation.

Inspect the selected PR enough to identify what would advance it. For `[2]`,
identify the concrete blocker or waiting state. For `[3]`, determine whether it
needs CI or conflict work, or is ready to leave draft. Report the PR, state, and
proposed action, then confirm with the user before changing code or GitHub. If
both categories are empty, say so.
