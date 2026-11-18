#!/usr/bin/env python3
"""Joins src/*.sql, in Section 4 order, into build/Team_105.sql."""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "build" / "Team_105.sql"


def order(path):
    return path.name.split("_")[0].split(".")


def has_code(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"--[^\n]*", "", text)
    return bool(text.strip())


def main():
    files = sorted((ROOT / "src").glob("*.sql"), key=order)
    parts, empty, temp, tables_built = [], [], [], False
    for f in files:
        text = f.read_text(encoding="utf-8")
        if not has_code(text):
            empty.append(f.stem)
            continue
        if "TEMP" in f.name:
            temp.append(f.name)
        is_structure = order(f)[:2] == ["4", "1"]
        if not is_structure and order(f)[0] != "0" and not tables_built:
            parts.append("EXEC createAllTables;\nGO\n")
            tables_built = True
        parts.append(text.rstrip() + "\nGO\n")
    if not tables_built:
        parts.append("EXEC createAllTables;\nGO\n")
    OUT.parent.mkdir(exist_ok=True)
    OUT.write_text("\n".join(parts), encoding="utf-8")
    print(f"Built {OUT.relative_to(ROOT)}: {len(files) - len(empty)} files included, {len(empty)} not written yet.")
    if temp:
        print("WARNING: temporary files are included, do not submit this build: " + ", ".join(temp))
    if "--final" in sys.argv and (temp or empty):
        sys.exit("Not ready to submit: remove the temporary files and finish the empty ones.")


if __name__ == "__main__":
    main()
