# FINDMBR — IBM i source-member search utility

## Overview

FINDMBR is an IBM i command that searches source members across one or more source files. It can run interactively or submit a batch job, and exports results to CSV in the IFS.

## Components

- **Command definition:** FINDMBR in QCMDSRC (creates command FINDMBR).
- **Interactive driver:** FINDMBR.RPGLE (runs search in the caller job).
- **Batch/worker program:** FINDMBR0.SQLRPGLE (SQL-based search and CSV export).
- **Exit program:** FINDMBR_X.RPGLE (Example of an exit program for excluding source files from the search).

## Key Features

- Search up to 5 tokens with AND/OR semantics at line or member level.
- Optional regular expressions via REGEXP_LIKE.
- Case-sensitive or case-insensitive matching.
- Supports *SRCPF keyword for indicating all source files in a library or explicit FILE/LIB pairs (up to 10).
- Batch submission with selectable job queue.
- Two CSV outputs: a detail CSV (all matching lines) and a summary CSV (members with results). Optional: append results.
- Optional exit program suffix to run post-processing.

## Command Parameters (FINDMBR)

- **FILE:** One or more FILE/LIB pairs (up to 10). The *\*SRCPF* keyword is valid for indicating a search across all source files in a library.
- **TOK1…TOK5:** Up to five search tokens. Tokens can be regex when REGEXP(\*YES).
- **MODE:** \*OR (any token), \*ANDLINE (all tokens on same line), \*ANDMBR (all tokens somewhere in member). Default: *\*ANDMBR*.
- **CASE:** \*INSENSITIVE (default) or \*SENSITIVE. Default: *\*INSENSITIVE*.
- **REGEXP:** \*NO (default) or \*YES to use REGEXP_LIKE (POSIX extended syntax). Default *\*NO*.
- **EXITPGM:** Optional single-character suffix to call FINDMBR_x to exclude source files from the search.
- **CSVFOLDER:** IFS folder for output or \*USRHOME (for /home/*user*). Default *\*USRHOME*.
- **CSVFILE:** File name or \*AUTO (timestamped, e.g. `findmbr_2026-01-04-16.02.39.688000.csv`). Default *\*AUTO*.
- **APPEND:** \*NO (replace) or \*YES (append) for CSV. Default *\*NO*.
- **WRKLIB:** Work library for temp tables. Default *QTEMP*.
- **LOG:** \*NO or \*YES to print SQL statements to spool. Default *\*NO*.
- **BCHJOB:** \*YES to submit in batch, \*NO to run interactively. Default *\*YES*.
- **JOBQ:** Job queue/lib used when BCHJOB(\*YES).

## Build/Install

### Create the command

`CRTCMD CMD(library/FINDMBR) PGM(library/FINDMBR) SRCFILE(library/QCMDSRC)`

### Compile the interactive driver

`CRTBNDRPG PGM(MYLIB/FINDMBR) SRCFILE(MYLIB/QRPGLESRC)`

### Compile the worker

`CRTSQLRPGI OBJ(library/FINDMBR0) SRCFILE(library/QRPGLESRC) SRCMBR(FINDMBR0) RPGPPOPT(*LVL2)`

## Usage Examples

- Search two files for a single token with CSV to user home:  
  `FINDMBR FILE(MYLIB/QRPGLESRC MYLIB/QCMDSRC) TOK1('customer')`

- Case-sensitive AND-at-line search with CSV to specific folder:  
  `FINDMBR FILE(DEVLIB/QRPGLESRC) TOK1('select') TOK2('where') MODE(*ANDLINE) CASE(*SENSITIVE) CSVFOLDER(/csv)`

- Batch submit to a specific job queue:
  `FINDMBR FILE(DEVLIB/QRPGLESRC) TOK1('TODO') BCHJOB(*YES) JOBQ(QGPL/QBATCH)`  

- Search all source files in a library using regex.  
  `FINDMBR FILE(MYLIB/*SRCPF MYLIB/QCMDSRC) TOK1('customer|client') TOK2('address|city')`  
  **Regex examples:** *^foo* (line starts with foo), *bar$* (ends with bar), *c.t* (c then any char then t), *foo|bar* (foo or bar), *[A-Z]{2}[0-9]+* (two letters followed by digits).

## Output

- CSV (detail): Written to CSVFOLDER/CSVFILE with all matching lines (UTF-8 with BOM, ";" delimiter, CRLF).
- CSV (summary): Written to CSVFOLDER/CSVFILE_summary.csv with list of members containing results (UTF-8 with BOM, ";" delimiter, CRLF).
- Spool: Optional SQL/log output when LOG(*YES).

## Testing

An IBM i end-to-end test harness is included in this repository.
See **[TEST.md](TEST.md)** for the updated layout (`QUTISRC`, `tests/expected`, `tests/fixtures`, `tests/bin`) and full setup/compile/run steps.

## Use with Code for i extension

Add a new action with a command like this:

```cmd
FINDMBR FILE(${FILE|Libraries/Files|LIB1/*SRCPF LIB2/*SRCPF LIB3/*SRCPF LIB4/*SRCPF LIB5/*SRCPF}) TOK1(${TOK1|First token to search|}) TOK2(${TOK2|Second token to search|}) TOK3(${TOK3|Third token to search|}) TOK4(${TOK4|Fourth token to search|}) TOK5(${TOK5|Fifth token to search|}) MODE(${MODE|Search mode|*ANDMBR}) CASE(${CASE|Case|*INSENSITIVE}) REGEXP(${REGEXP|Use regular expressions|*NO}) CSVFOLDER(${CSVFOLDER|Csv folder|*USRHOME}) CSVFILE(${CSVFILE|Csv file name|*AUTO}) BCHJOB(${BCHJOB|Execute in batch|*YES}) JOBQ(${JOBQ|Job queue|QGPL/QBATCH})
```

You will get a prompt window like this:

![FINDMBR_prompt](https://github.com/user-attachments/assets/813ded0d-460b-459e-9444-b620a6a62935)

## License

findmbr is released under the **MIT License**.  

Thanks to Scott Klement for the IFSIO_H and ERRNO_H copybooks.  
The IFSIO_H and ERRNO_H copybooks are copyright © Scott Klement and are distributed under the BSD 2-Clause license.
