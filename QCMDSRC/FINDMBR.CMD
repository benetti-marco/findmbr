/* ============================================================================== */
/*   QCMDSRC(FINDMBR) -an advanced source-member search utility for IBM i         */
/* ============================================================================== */
/* ============================================================================== */
/* MIT License                                                                    */
/*                                                                                */
/* Copyright (c) 2025 Marco Benetti                                               */
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

/* Lista FILE/LIB obbligatoria (1\Z10 occorrenze) */
             PARM       KWD(FILE) TYPE(FILLIB) MIN(1) MAX(10) +
                          PROMPT('Source file(s)')

FILLIB:      QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC) +
                          SPCVAL((*SRCPF)) +
                          CHOICE('File')
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB)) +
                          CHOICE('Library') PROMPT('Library')

/* Ricerca: fino a 5 token */
             PARM       KWD(TOK1) TYPE(*CHAR) LEN(60) PROMPT('Token 1')
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

/* Output */
             PARM       KWD(CSVFOLDER) TYPE(*CHAR) LEN(500) DFT(*USRHOME) +
                          PROMPT('Output CSV folder or *USRHOME')

             PARM       KWD(CSVFILE) TYPE(*CHAR) LEN(50) DFT(*AUTO) +
                          PROMPT('Output CSV file name or *AUTO')

             PARM       KWD(APPEND) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          VALUES(*NO *YES) PROMPT('Append to CSV if exists') RSTD(*YES)

             PARM       KWD(LOG) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          VALUES(*NO *YES) PROMPT('Log SQL statement to spool') RSTD(*YES)
