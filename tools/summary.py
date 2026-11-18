#!/usr/bin/env python3
"""Prints the grader result for one student's tests. Usage: summary.py [s1|all]"""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
GROUPS = {"s1": r"PU-4\.2\.d|PU-4\.3\.|PU-4\.4\.[abchijk](-|$)|PP-4"}


def main():
    group = sys.argv[1] if len(sys.argv) > 1 else "s1"
    output = ROOT / "build" / "grader_output.txt"
    results = ROOT / "build" / "Team_105_results.txt"
    if output.exists():
        for line in output.read_text(encoding="utf-8").splitlines():
            if line.startswith("=" * 20):
                break
            print(line)
    if not results.exists():
        sys.exit("The grader did not finish. Read the messages above.")
    wanted = re.compile(GROUPS[group]) if group in GROUPS else None
    passed = total = 0
    show = False
    for line in results.read_text(encoding="utf-8").splitlines():
        match = re.match(r"(P[UP]-\S+)\s+(PASS|FAIL)\s", line)
        if match:
            show = wanted is None or bool(wanted.match(match.group(1)))
            if show:
                total += 1
                passed += match.group(2) == "PASS"
        if show and (match or line.startswith(" ")):
            print(line)
    print(f"\n{group}: passed {passed} of {total} tests.")


if __name__ == "__main__":
    main()
