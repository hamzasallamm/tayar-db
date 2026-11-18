# Tayar

Database for the Tayar local delivery marketplace. Team 105, Databases I, Milestone 2.

## Commands

```bash
bash tools/setup_mac.sh   # one-time setup
bash tools/test.sh        # build and run the Student 1 tests
bash tools/test.sh all    # build and run every public test
```

The file to submit is `build/Team_105.sql`. Run `python3 tools/build.py --final` before submitting. It refuses to pass while temporary or empty files remain.

## Layout

- `src/`: one file per requirement, named after its section, for example `4.3.a_Customer_Register.sql`
- `tests/`: the course grader, public tests and seed data
- `tools/`: setup, build and test scripts

`src/4.1_TEMP_tables.sql` is a temporary copy of the tables for local testing. Delete it when Student 4 delivers the real one.

## Open question

`Detect_Voucher_Abuse` is assigned to Student 1 in Section 5 but has no specification yet.
