#!/usr/bin/env python3

import sys


def process_file(filename):
    lines = []
    with open(filename, "r") as f:
        content = f.read()

    for line in content.strip().split("\n"):
        if line.startswith("usemtl"):
            continue
        elif line.startswith("mtllib"):
            continue
        else:
            lines.append(line)

    content = "\n".join(lines)
    with open(filename, "w") as f:
        f.write(content)

files = sys.argv[1:]

if len(files) == 0:
    print("Error: No file to process", file=sys.stderr)
    sys.exit(-1)

for filename in files:
    print("Processing %s" % filename)
    process_file(filename)

print("Done.")
