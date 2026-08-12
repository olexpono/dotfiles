#!/usr/bin/env python3
"""List open PRs for a branch prefix, grouped by review/merge readiness.

Categories:
  [1] Ready       — not draft, mergeable, all checks pass, approved
  [2] Blocked     — not draft, but checks failing/pending and/or review missing
  [3] Draft clean — draft with no unresolved code comments
  [4] Draft w/ comments — draft with unresolved code comments

Usage: pr-status.py [branch-prefix] [--repo OWNER/NAME] [--author LOGIN]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

DEFAULT_PREFIX = "olex/"

SEARCH_QUERY = """
query($q: String!, $endCursor: String) {
  search(query: $q, type: ISSUE, first: 50, after: $endCursor) {
    pageInfo { hasNextPage endCursor }
    nodes {
      ... on PullRequest {
        number
        title
        url
        isDraft
        mergeable
        reviewDecision
        reviewThreads(first: 100) {
          nodes {
            isResolved
            isOutdated
            path
            line
            comments(first: 1) { nodes { url } }
          }
        }
      }
    }
  }
}
"""


def gh(*args: str) -> str:
    result = subprocess.run(
        ["gh", *args], capture_output=True, text=True, check=True
    )
    return result.stdout


def current_repo() -> str:
    """Repo of the working directory, so the script travels between checkouts."""
    out = gh("repo", "view", "--json", "nameWithOwner")
    return json.loads(out)["nameWithOwner"]


def fetch_pulls(repo: str, prefix: str, author: str) -> list[dict]:
    """Page through the search API; --paginate concatenates JSON documents."""
    raw = gh(
        "api",
        "graphql",
        "--paginate",
        "-f",
        f"q=repo:{repo} is:pr is:open author:{author} head:{prefix}",
        "-f",
        f"query={SEARCH_QUERY}",
    )
    pulls, decoder, pos = [], json.JSONDecoder(), 0
    while pos < len(raw):
        if raw[pos].isspace():
            pos += 1
            continue
        doc, pos = decoder.raw_decode(raw, pos)
        pulls.extend(doc["data"]["search"]["nodes"])
    return sorted(pulls, key=lambda p: p["number"])


def resolve_mergeable(repo: str, pulls: list[dict], attempts: int = 4) -> None:
    """GitHub computes mergeability lazily; asking for it schedules the job, so
    re-read the PRs that came back UNKNOWN until the answer settles."""
    for attempt in range(attempts):
        pending = [p for p in pulls if p["mergeable"] == "UNKNOWN"]
        if not pending:
            return
        if attempt:
            time.sleep(3)
        with ThreadPoolExecutor(max_workers=8) as pool:
            states = pool.map(lambda p: _mergeable_state(repo, p), pending)
            for pull, state in zip(pending, states):
                pull["mergeable"] = state


def _mergeable_state(repo: str, pull: dict) -> str:
    out = gh(
        "pr", "view", str(pull["number"]), "--repo", repo, "--json", "mergeable"
    )
    return json.loads(out)["mergeable"]


def fetch_checks(repo: str, number: int) -> list[dict]:
    """`gh pr checks` exits 8 when checks are failing and 1 when there are none."""
    proc = subprocess.run(
        [
            "gh", "pr", "checks", str(number),
            "--repo", repo,
            "--json", "name,bucket,link",
        ],
        capture_output=True,
        text=True,
    )
    if not proc.stdout.strip():
        return []
    return json.loads(proc.stdout)


def open_threads(pull: dict) -> list[dict]:
    return [t for t in pull["reviewThreads"]["nodes"] if not t["isResolved"]]


def thread_url(thread: dict) -> str | None:
    comments = thread["comments"]["nodes"]
    return comments[0]["url"] if comments else None


def categorize(pull: dict, checks: list[dict]) -> tuple[int, list[str]]:
    """Return the bucket number and the human-readable reasons for it."""
    if pull["isDraft"]:
        threads = open_threads(pull)
        if not threads:
            return 3, []
        reasons = []
        for thread in threads:
            label = f"{thread['path']}:{thread['line']}"
            if thread["isOutdated"]:
                label += " (outdated)"
            url = thread_url(thread)
            reasons.append(f"{label}\n        {url}" if url else label)
        return 4, reasons

    reasons = []
    failing = [c["name"] for c in checks if c["bucket"] in ("fail", "cancel")]
    pending = [c["name"] for c in checks if c["bucket"] == "pending"]
    if failing:
        reasons.append(f"failing: {', '.join(sorted(failing))}")
    if pending:
        reasons.append(f"pending: {len(pending)} check(s)")
    if pull["reviewDecision"] != "APPROVED":
        reasons.append(f"review: {pull['reviewDecision'] or 'NONE'}")
    if pull["mergeable"] != "MERGEABLE":
        reasons.append(f"mergeable: {pull['mergeable']}")
    threads = open_threads(pull)
    if threads:
        reason = f"{len(threads)} unresolved comment(s)"
        url = thread_url(threads[0])
        reasons.append(f"{reason}\n        {url}" if url else reason)

    return (2, reasons) if reasons else (1, [])


TITLES = {
    1: "[1] Open — mergeable, all checks pass, approved",
    2: "[2] Open — checks failing/pending and/or review missing",
    3: "[3] Draft — no open code comments",
    4: "[4] Draft — has open code comments",
}


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Group open PRs by review/merge readiness."
    )
    parser.add_argument(
        "prefix",
        nargs="?",
        default=DEFAULT_PREFIX,
        help=f"branch name prefix to match (default: {DEFAULT_PREFIX!r})",
    )
    parser.add_argument(
        "--repo",
        help="OWNER/NAME to query (default: the repo of the working directory)",
    )
    parser.add_argument(
        "--author", default="@me", help="PR author to filter on (default: @me)"
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    try:
        repo = args.repo or current_repo()
    except subprocess.CalledProcessError:
        print(
            "Not in a GitHub repo — pass --repo OWNER/NAME.",
            file=sys.stderr,
        )
        return 1

    pulls = fetch_pulls(repo, args.prefix, args.author)
    if not pulls:
        print(
            f"No open PRs in {repo} for branches starting with '{args.prefix}'"
        )
        return 0

    resolve_mergeable(repo, pulls)

    needs_checks = [p["number"] for p in pulls if not p["isDraft"]]
    with ThreadPoolExecutor(max_workers=8) as pool:
        checks = dict(
            zip(needs_checks, pool.map(lambda n: fetch_checks(repo, n), needs_checks))
        )

    buckets: dict[int, list[tuple[dict, list[str]]]] = {1: [], 2: [], 3: [], 4: []}
    for pull in pulls:
        bucket, reasons = categorize(pull, checks.get(pull["number"], []))
        buckets[bucket].append((pull, reasons))

    print(
        f"{len(pulls)} open PR(s) in {repo} "
        f"on branches starting with '{args.prefix}'\n"
    )
    for bucket in (1, 2, 3, 4):
        entries = buckets[bucket]
        print(f"{TITLES[bucket]} — {len(entries)}")
        for pull, reasons in entries:
            team = pull["title"].split("(")[-1].rstrip(")")
            print(f"  #{pull['number']}  {team}")
            print(f"      {pull['url']}")
            for reason in reasons:
                print(f"      · {reason}")
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
