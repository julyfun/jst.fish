#!/usr/bin/env python3
import subprocess
from collections import defaultdict

# Run git log with numstat (shows additions/deletions per file)
git_log = subprocess.run(
    ["git", "log", "--pretty=format:%ae", "--numstat"],
    capture_output=True,
    text=True,
    check=True
)

lines = git_log.stdout.splitlines()
stats = defaultdict(lambda: {"add": 0, "del": 0})

current_email = None

for line in lines:
    if line.strip() == "":
        continue
    if "@" in line and not line[0].isdigit():
        # This line is an email
        current_email = line.strip()
    else:
        # This line is a file stat: additions deletions filename
        parts = line.split("\t")
        if len(parts) >= 3:
            try:
                added = int(parts[0])
            except ValueError:
                added = 0
            try:
                deleted = int(parts[1])
            except ValueError:
                deleted = 0
            stats[current_email]["add"] += added
            stats[current_email]["del"] += deleted

# Sort by total lines modified (additions + deletions)
sorted_stats = sorted(
    stats.items(),
    key=lambda x: x[1]["add"] + x[1]["del"],
    reverse=True
)

# Print results
print(f"{'Email':40} {'Added':>8} {'Deleted':>8}")
print("-" * 60)
for email, data in sorted_stats:
    total = data["add"] + data["del"]
    print(f"{email:40} {'+' + str(data['add']):>8} {'-' + str(data['del']):>8}")
