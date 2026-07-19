## FINDMBR - IBM i Source Member Search Utility

A fast, flexible, open-source search utility for IBM i source members.

## Features

- **Flexible**: Search by token, regex, case-sensitive/insensitive
- **Multiple sources**: Search specific files, all source files (*SRCPF), or multiple libraries
- **CSV output**: Results exported to CSV with UTF-8 encoding and BOM
- **Logging**: Optional SQL/log output to spool
- **Exit program**: Optional user exit program for custom filtering

## Installation

1. Clone or download the repository to your IBM i
2. Create a library (e.g., `FINDMBR`)
3. Create source files: `CRTSRCFILE FINDMBR/QRPGLESRC` and `CRTSRCFILE FINDMBR/QUTISRC`
4. Copy source members from the repository to your library
5. Compile:
   ```
   CRTSQLRPGI OBJ(FINDMBR/FINDMBR0) SRCFILE(FINDMBR/QRPGLESRC) RPGPPOPT(*LVL2)
   CRTBNDRPG PGM(FINDMBR/FINDMBR) SRCFILE(FINDMBR/QRPGLESRC)
   CRTBNDRPG PGM(FINDMBR/FINDMBR_X) SRCFILE(FINDMBR/QRPGLESRC)
   CRTBNDRPG PGM(FINDMBR/CMPCSV) SRCFILE(FINDMBR/QUTISRC)
   CRTBNDCL PGM(FINDMBR/TEST_RUN) SRCFILE(FINDMBR/QUTISRC)
   CRTBNDCL PGM(FINDMBR/TEST_SETUP) SRCFILE(FINDMBR/QUTISRC)
   ```
6. Create the command:
   ```
   CRTCMD CMD(FINDMBR/FINDMBR) PGM(FINDMBR/FINDMBR) SRCFILE(FINDMBR/QCMDSRC)
   ```

- Search up to 5 tokens with AND/OR semantics at line or member level.
- Optional regular expressions via REGEXP_LIKE.
- Case-sensitive or case-insensitive matching.
- Supports *SRCPF keyword for indicating all source files in a library or explicit FILE/LIB pairs (up to 10).
- Batch submission with selectable job queue.
- CSV export to IFS with optional append.
- **Two CSV outputs:** detail CSV with all matching lines and summary CSV with list of members containing results.
- **Validation:** At least one LIB/FILE and TOK1 (search token) are required.
- Optional exit program suffix to run post-processing.

## Usage

```
FINDMBR FILE(MYLIB/QRPGLESRC) TOK1('customer') TOK2('address')                       
```

### Parameters

- **FILE**: Source file(s) to search. Format: `LIB/FILE`. Supports *SRCPF for all source files in a library. Multiple files separated by spaces. Required.
- **TOK1-TOK5**: Tokens to search for. Supports wildcards (`%`) and regex (with REGEXP(*YES)).
- **MODE**: Search mode. *AND (default) = all tokens must match. *OR = any token matches. *ANDLINE = all tokens must match on the same line.
- **CASE**: *INSENSITIVE (default) or *SENSITIVE.
- **REGEX**: *NO (default) or *YES to use regex for tokens.
- **CSVFILE**: File name or \*AUTO (timestamped, e.g. `findmbr_2026-01-04-16.02.39.688000.csv`). Default *\*AUTO*.
- **CSVFOLDER**: Output folder. Default *USRHOME. Supports ~ expansion.
- **APPEND**: *NO (default) or *YES to append to existing CSV file.
- **WRKLIB**: Work library for temporary tables. Default QTEMP.
- **LOG**: *NO (default) or *YES for SQL/log output to spool.
- **EXITPGM**: Optional exit program suffix for custom filtering (e.g. 'X' for FINDMBR_X).

### Examples

  Search for 'customer' in all source files in MYLIB:
  ```
  FINDMBR FILE(MYLIB/*SRCPF) TOK1('customer')
  ```

  Search for 'customer' OR 'client' with regex:
  ```
  FINDMBR FILE(MYLIB/*SRCPF) TOK1('customer|client') REGEX(*YES)
  ```

  Case-sensitive search for 'CUSTOMER' at start of line:
  ```
  FINDMBR FILE(MYLIB/QRPGLESRC) TOK1('^CUSTOMER') REGEX(*YES) CASE(*SENSITIVE)
  ```

  Search multiple libraries/files:
  ```
  FINDMBR FILE(MYLIB1/QRPGLESRC MYLIB2/*SRCPF) TOK1('foo') TOK2('bar')
  ```
  **Regex examples:** *^foo* (line starts with foo), *bar$* (ends with bar), *c.t* (c then any char then t), *foo|bar* (foo or bar), *[A-Z]{2}[0-9]+* (two letters followed by digits).

## Output

- CSV (detail): Written to CSVFOLDER/CSVFILE with all matching lines (UTF-8 with BOM, ";" delimiter, CRLF).
- CSV (summary): Written to CSVFOLDER/findmbr_<timestamp>_summary.csv with list of members containing results (UTF-8 with BOM, ";" delimiter, CRLF).
- Spool: Optional SQL/log output when LOG(*YES).

## Testing

An IBM i end-to-end test harness is included in this repository.
See **[TEST.md](TEST.md)** for the updated layout (`QUTISRC`, `tests/expected`, `tests/fixtures`, `tests/bin`) and full setup/compile/run steps.

## Use with Code for i extension

You can add an Action with *Command(s) to run* like this (adapt libraries and Exit program suffix):  

  ```
FINDMBR FILE(${FILE|Libraries/Files|LIB1/*SRCPF LIB2/*SRCPF LIB2/*SRCPF LIB4/*SRCPF LIB5/*SRCPF}) TOK1(${TOK1|First token to search|}) TOK2(${TOK2|Second token to search|}) TOK3(${TOK3|Third token to search|}) TOK4(${TOK4|Fourth token to search|}) TOK5(${TOK5|Fifth token to search|}) MODE(${MODE|Search mode|*ANDMBR}) CASE(${CASE|Case|*INSENSITIVE}) REGEXP(${REGEXP|Use regular expressions|*NO}) CSVFOLDER(${CSVFOLDER|Csv folder|*USRHOME}) CSVFILE(${CSVFILE|Csv file name|*AUTO}) BCHJOB(${BCHJOB|Execute in batch|*YES}) EXITPGM('X')
  ```
This is the action prompt:  
  
<img width="700" height="920" alt="FINDMBR_prompt" src="https://github.com/user-attachments/assets/f295f265-d06e-475a-8aed-911356845f0b" />

