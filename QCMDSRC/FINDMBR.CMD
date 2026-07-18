/* ============================================================================== */
/*   QCMDSRC(FINDMBR) - IBM i source-member search utility                        */ 
/*   Compile with: CRTCMD CMD(MYLIB/FINDMBR) PGM(MYLIB/FINDMBR)                   */ 
/*                 SRCFILE(MYLIB/QCMDSRC)                                         */
/* ============================================================================== */
/* ============================================================================== */
/* MIT License                                                                    */
/*                                                                                */
/* Copyright (c) 2025-2026 Marco Benetti                                          */
/*                                                                                */
/* Permission is hereby granted, free of charge, to any person obtaining a copy   */
/* of this software and associated documentation files (the "Software"), to deal  */
/* in the Software without restriction, including without limitation the rights   */
/* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      */
/* copies of the Software, and to permit persons to whom the Software is          */
/* furnished to do so, subject to the following conditions:                       */
/*                                                                                */
/* The above copyright notice and this permission notice shall be included in all */
/* copies or substantial portions of the Software.                                */
/*                                                                                */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     */
/* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    */
/* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  */
/* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  */
/* SOFTWARE.                                                                      */
/* ============================================================================== */
             CMD        PROMPT('Search text in source members')

/* Required FILE/LIB list (up to 10 entries) */
             PARM       KWD(FILE) TYPE(FILLIB) MIN(1) MAX(10) +
                          PROMPT('Source file(s)')

FILLIB:      QUAL       TYPE(*NAME) LEN(10) MIN(1) +
                          SPCVAL((*SRCPF)) +
                          CHOICE('File')
             QUAL       TYPE(*NAME) LEN(10) MIN(1) CHOICE('Library') +
                          PROMPT('Library')

/* Search: up to 5 tokens (at least TOK1 is required) */
             PARM       KWD(TOK1) TYPE(*CHAR) LEN(60) MIN(1) PROMPT('Token 1')
             PARM       KWD(TOK2) TYPE(*CHAR) LEN(60) DFT('') PROMPT('Token 2')
             PARM       KWD(TOK3) TYPE(*CHAR) LEN(60) DFT('') PROMPT('Token 3')
             PARM       KWD(TOK4) TYPE(*CHAR) LEN(60) DFT('') PROMPT('Token 4')
             PARM       KWD(TOK5) TYPE(*CHAR) LEN(60) DFT('') PROMPT('Token 5')

             PARM       KWD(MODE) TYPE(*CHAR) LEN(10) DFT(*ANDMBR) +
                          VALUES(*OR *ANDLINE *ANDMBR) +
                          PROMPT('Mode: *OR / *ANDLINE / *ANDMBR') RSTD(*YES)

             PARM       KWD(CASE) TYPE(*CHAR) LEN(12) DFT(*INSENSITIVE) +
                          VALUES(*INSENSITIVE *SENSITIVE) +
                          PROMPT('Case sensitivity') RSTD(*YES)

             PARM       KWD(REGEXP) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          VALUES(*NO *YES) PROMPT('Use REGEXP_LIKE') RSTD(*YES)

             PARM       KWD(EXITPGM) TYPE(*CHAR) LEN(1) +
                          PROMPT('Exit program suffix')

/* Output */
             PARM       KWD(CSVFOLDER) TYPE(*CHAR) LEN(500) DFT(*USRHOME) +
                          PROMPT('Output CSV folder or *USRHOME')

             PARM       KWD(CSVFILE) TYPE(*CHAR) LEN(50) DFT(*AUTO) +
                          PROMPT('Output CSV file name or *AUTO')

             PARM       KWD(APPEND) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          VALUES(*NO *YES) PROMPT('Append to CSV if exists') +
                          RSTD(*YES)

/* Debug */
             PARM       KWD(WRKLIB) TYPE(*NAME) LEN(10) DFT(QTEMP) +
                          PROMPT('Work library')

             PARM       KWD(LOG) TYPE(*CHAR) LEN(4) DFT(*NO) +
                         VALUES(*NO *YES) PROMPT('Log SQL statement to spool') +
                         RSTD(*YES)

/* Batch */
             PARM       KWD(BCHJOB) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*NO *YES) PROMPT('Submit +
                          in batch?')
/* JOBQ/LIB */
             PARM       KWD(JOBQ) TYPE(JOBQLIB) +
                          PROMPT('Job queue')

JOBQLIB:     QUAL       TYPE(*NAME) LEN(10) +
                          CHOICE('Job queue')
             QUAL       TYPE(*NAME) LEN(10) CHOICE('Library') +
                          PROMPT('Library')
