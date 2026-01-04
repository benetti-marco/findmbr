# FINDMBR — IBM i Source-Member Search Utility
## Overview
FINDMBR is an IBM i command that searches source members across one or more source files. It can run interactively or submit a batch job, and exports results to CSV in the IFS.

## Components
- **Command definition:** FINDMBR in QCMDSRC (creates command FINDMBR).
- **Interactive driver:** FINDMBR.RPGLE (runs search in the caller job).
- **Batch/worker program:** FINDMBR0.SQLRPGLE (SQL-based search and CSV export).

## Key Features
- Search up to 5 tokens with AND/OR semantics at line or member level.
- Optional regular expressions via REGEXP_LIKE.
- Case-sensitive or case-insensitive matching.
- Supports *SRCPF shortcut or explicit FILE/LIB pairs (up to 10).
- Batch submission with selectable job queue.
- CSV export to IFS with optional append.
- Optional exit program suffix to run post-processing.

## Command Parameters (FINDMBR)
- **FILE:** One or more FILE/LIB pairs (up to 10). The *\*SRCPF* keyword is valid for indicating a search across all source files in a library.
- **TOK1…TOK5:** Up to five search tokens. Tokens can be regex when REGEXP(*YES).
- **MODE:** *OR (any token), *ANDLINE (all tokens on same line), *ANDMBR (all tokens somewhere in member). Default: *\*ANDMBR*
- **CASE:** *INSENSITIVE (default) or *SENSITIVE. Default: *\*INSENSITIVE*
- **REGEXP:** *NO (default) or *YES to use REGEXP_LIKE (POSIX extended syntax). Default *\*NO* 
- **EXITPGM:** Optional single-character suffix to call FINDMBR<suffix> after search.
- **CSVFOLDER:** IFS folder for output or *USRHOME (for /home/<user>). Default *\*USRHOME*
- **CSVFILE:** File name or *AUTO (timestamped, e.g. `findmbr_2026-01-04-16.02.39.688000.csv`). Default *\*AUTO*
- **APPEND:** *NO (replace) or *YES (append) for CSV. Default *\*NO*
- **WRKLIB:** Work library for temp tables. Default *QTEMP*.
- **LOG:** *NO or *YES to print SQL statements to spool. Default *\*NO*
- **BCHJOB:** *YES to submit in batch, *NO to run interactively. Default *\*YES*
- **JOBQ:** Job queue/lib used when BCHJOB(*YES). Default *QSYS/QUSRNOMAX*

## Build/Install
### Create the command:
`CRTCMD CMD(<lib>/FINDMBR) PGM(<lib>/FINDMBR) SRCFILE(<lib>/QCMDSRC)`

### Compile the interactive driver:
`CRTSQLRPGI OBJ(<lib>/FINDMBR) SRCFILE(<lib>/QRPGLESRC) SRCMBR(FINDMBR)`

### Compile the worker:
`CRTSQLRPGI OBJ(<lib>/FINDMBR0) SRCFILE(<lib>/QRPGLESRC) SRCMBR(FINDMBR0) RPGPPOPT(*LVL2)`

## Usage Examples
- Search two files for a single token with CSV to user home:  
  `FINDMBR FILE((QRPGLESRC MYLIB) (QCMDSRC MYLIB)) TOK1('customer')`

- Case-sensitive AND-at-line search with CSV to specific folder:  
  `FINDMBR FILE((QRPGLESRC DEVLIB)) TOK1('select') TOK2('where') MODE(*ANDLINE) CASE(*SENSITIVE) CSVFOLDER(/csv)`

- Batch submit to a specific job queue:
  `FINDMBR FILE((QRPGLESRC DEVLIB)) TOK1('TODO') BCHJOB(*YES) JOBQ(QBATCH/QGPL)`  

- Search all source files in a library using regex.  
  `FINDMBR FILE((*SRCPF MYLIB) (QCMDSRC MYLIB)) TOK1('customer|client') TOK2('address|city') `  
  **Regex examples:** *^foo* (line starts with foo), *bar$* (ends with bar), *c.t* (c then any char then t), *foo|bar* (foo or bar), *[A-Z]{2}[0-9]+* (two letters followed by digits).

## Output
- CSV: Written to CSVFOLDER/CSVFILE (UTF-8, ";" delimiter, CRLF).
- Spool: Optional SQL/log output when LOG(*YES).

## License
MIT License.
