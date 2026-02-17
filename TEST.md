# FINDMBR test harness (IBM i)

This project includes a minimal end-to-end test setup for FINDMBR that:

- builds a deterministic source physical file
- runs FINDMBR in multiple modes
- compares generated CSV output with expected CSV files

## Repository layout

- `QUTISRC/test_setup.clle` : creates `UT_FINDMBR/QTESTSRC` and loads fixture members
- `QUTISRC/test_run.clle` : executes 4 E2E tests
- `QUTISRC/cmpcsv.rpgle` : ILE wrapper using `Qp2RunPase` + `bash` to compare CSVs
- `tests/bin/compare_csv.sh` : `diff -B -Z` compare script (returns `0`/`1`)
- `tests/expected/*.csv` : expected outputs
- `tests/fixtures/*.txt` : fixture member source lines

## Prepare files on IBM i

1) Copy expected CSV files to IFS:

    ~/findmbr-tests/expected/t1.csv
    ~/findmbr-tests/expected/t2.csv
    ~/findmbr-tests/expected/t3.csv
    ~/findmbr-tests/expected/t4.csv

2) Copy fixture files to IFS:

    ~/findmbr-tests/setup/mbr1.txt
    ~/findmbr-tests/setup/mbr2.txt
    ~/findmbr-tests/setup/mbr3.txt
    ~/findmbr-tests/setup/mbr4.txt
    ~/findmbr-tests/setup/mbr5.txt

3) Copy compare script to IFS and make it executable:

    ~/findmbr-tests/bin/compare_csv.sh
    chmod +x ~/findmbr-tests/bin/compare_csv.sh

4) Upload test sources from `QUTISRC` to your IBM i source files:

    - test_setup.clle -> QCLSRC
    - test_run.clle   -> QCLSRC
    - cmpcsv.rpgle    -> QRPGLESRC

## Compile and run

CRTBNDCL PGM(UT_FINDMBR/TEST_SETUP) SRCFILE(UT_FINDMBR/QCLSRC) SRCMBR(TEST_SETUP)
CRTBNDRPG PGM(UT_FINDMBR/CMPCSV)    SRCFILE(UT_FINDMBR/QRPGLESRC) SRCMBR(CMPCSV)
CRTBNDCL PGM(UT_FINDMBR/TEST_RUN)   SRCFILE(UT_FINDMBR/QCLSRC) SRCMBR(TEST_RUN)

CALL PGM(UT_FINDMBR/TEST_SETUP)
CALL PGM(UT_FINDMBR/TEST_RUN)

## Notes

- Update `BASEDIR` in `QUTISRC/test_setup.clle` and `QUTISRC/test_run.clle` if needed.
- Update `&LIB` in `QUTISRC/test_setup.clle` if your test library is different.
- `CMPCSV` receives the script directory from `QUTISRC/test_run.clle` (`&SCRIPTDIR`).
- Ensure `bash` exists at `/QOpenSys/pkgs/bin/bash` or adjust `shellCmd` in `QUTISRC/cmpcsv.rpgle`.
- FINDMBR and FINDMBR0 must already be compiled and in library list.
