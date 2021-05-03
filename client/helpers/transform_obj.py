#!/usr/bin/env python3

import sys

def print_usage():
    print("Usage: ./transform_obj.py <translate|scale> <x> <y> <z> <files>")

def lookup(mode):
    if mode == "translate":
        return translate
    elif mode == "scale":
        return scale
    else:
        print("Error: invalid mode %s" % mode, file=sys.stderr)
        print_usage()
        exit(-2)

def translate(point, by):
    px, py, pz = point
    tx, ty, tz = by
    return (px + tx, py + ty, pz + tz)

def scale(point, by):
    px, py, pz = point
    sx, sy, sz = by
    return (px * sx, py * sy, pz * sz)

def read_file(filename):
    with open(filename, "r") as f:
        content = f.read()
    return content

def write_file(filename, content):
    with open(filename, "w") as f:
        f.write(content)

def process_file(content, mode, by):
    lines = []

    for line in content.strip().split("\n"):
        if line.startswith("v "):
            _, x, y, z = line.split(" ")
            x = float(x)
            y = float(y)
            z = float(z)

            x, y, z = mode((x, y, z), by)
            lines.append("v %s %s %s" % (x, y, z))
        else:
            lines.append(line)

    return "\n".join(lines)

if len(sys.argv) < 5:
    print("Error: not enough arguments", file=sys.stderr)
    print_usage()
    sys.exit(-1)

files = sys.argv[5:]

if len(files) == 0:
    print("Error: No file to process", file=sys.stderr)
    sys.exit(-1)

mode, x, y, z = sys.argv[1:5]

mode = lookup(mode)
x = float(x)
y = float(y)
z = float(z)

if files == ["-"]:
    text_input = sys.stdin.read()
    text_output = process_file(text_input , mode, (x, y, z))
    sys.stdout.write(text_output)

else:
    for filename in files:
        print("Processing %s" % filename)
        text_input = read_file(filename)
        text_output = process_file(text_input , mode, (x, y, z))
        write_file(filename, text_output)
    print("Done.")
