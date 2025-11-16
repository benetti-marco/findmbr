**FREE
// ============================================================================== //
// PGM for command FINDMBR - an advanced source-member search utility for IBM i   //
// Compile with: CRTSQLRPGI OBJ(FINDMBRPGM)                                       //
// ============================================================================== //
// ============================================================================== //
// MIT License                                                                    //
//                                                                                //
// Copyright (c) 2025 Marco Benetti                                               //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
// ============================================================================== //

ctl-opt dftactgrp(*no) actgrp('FINDMBR') option(*srcstmt) alwnull(*usrctl);

// ===================================================================
dcl-f QSYSPRT printer(132) usropn oflind(*inoa);

dcl-pr QCMDEXC extpgm('QCMDEXC');
    cmd  char(32702) options(*varsize);
    len  packed(15:5)   const;
end-pr;

dcl-pr BuildPreds;
  expr        varchar(64) const;
  useRx       ind         const;
  rxFlag      char(1)     const;
  vCase       char(1)     const;
  t1          varchar(300) const;
  t2          varchar(300) const;
  t3          varchar(300) const;
  t4          varchar(300) const;
  t5          varchar(300) const;
  oPredLine   varchar(32766);
  oPredAny    varchar(32766);
  oHaving     varchar(32766);
end-pr;

dcl-pr WordWrap;
      pText    varchar(32767)   const;
      pMaxLen  int(10)          const;
      pLines   varchar(100)   dim(500);
end-pr;

dcl-pr CreatePath;
      pPath    varchar(1024)   const;
end-pr;

dcl-ds FileParm qualified;
  p_filecount  int(5);
  p_filestr    char(200);
end-ds;
dcl-ds FileEntry qualified;
  File  char(10);
  Lib   char(10);
end-ds;

// *ENTRY
dcl-pi *n;
  p_FILE       likeds(FileParm);
  p_MBRLIKE    char(10);
  p_TOK1       char(60);
  p_TOK2       char(60);
  p_TOK3       char(60);
  p_TOK4       char(60);
  p_TOK5       char(60);
  p_MODE       char(10);
  p_CASE       char(12);
  p_REGEX      char(4);
  p_CSVFOLDER  char(500);
  p_CSVFILE    char(50);
  p_APPEND     char(4);
  p_LOG        char(4);
end-pi;

dcl-s useRegex ind   inz(*off);
dcl-s logSQL ind   inz(*off);
dcl-s vCase    char(1) inz('I');
dcl-s rxFlag   char(1) inz('i');

dcl-s csvPath  varchar(1024) inz('');
dcl-s csvFolder  varchar(1024) inz('');
dcl-s mbrOpt   char(10)      inz('*REPLACE');
dcl-s usr      char(10)      inz('');

dcl-s i         int(10)        inz(0);
dcl-s i1        int(10)        inz(0);
dcl-s x         int(5)        inz(0);
dcl-s alias     varchar(18)    inz('');
dcl-s expr      varchar(64)    inz('');
dcl-s whereCom  varchar(256)   inz('');
dcl-s sql       varchar(32766) inz('');
dcl-s predLine  varchar(32766) inz('');
dcl-s predAny   varchar(32766) inz('');
dcl-s having    varchar(32766) inz('');
dcl-s lib       char(10)       inz('');
dcl-s srcfile   char(10)       inz('');
dcl-s mbr       char(10)       inz('');
dcl-s cmd       char(1024)  inz('');
dcl-s sqlcmd    varchar(10000)  inz('');
dcl-s Msg       varchar(30000);
dcl-s lines     varchar(100) dim(500);

dcl-ds STR132 len(132) end-ds;
dcl-ds SS1132 len(132) end-ds;
dcl-ds SS2132 len(132) end-ds;

dcl-ds *n PSDS;
          //                   Nome del programma
    YPGMNAME char(10) POS(1);
          //                   Nome dell'utente (di sistema)
    YUSER char(10) POS(254);

end-ds;

dcl-s YTODAYISO date(*ISO)  INZ(*SYS);
dcl-s YTIME time(*HMS)  INZ(*SYS);
dcl-s YTIMESTAMP timestamp  INZ(*SYS);
      /copy QRPGLESRC,IFSIO_H
      /copy QRPGLESRC,ERRNO_H
dcl-s CMDARR    Char(100)  DIM(02) CTDATA PERRCD(1);
dcl-s SSQL1     Char(100)  DIM(11) CTDATA PERRCD(1);

// ===================================================================
//            MAIN
// ===================================================================

exec sql Set Option
        SQLPATH   = *LIBL,
        Naming    = *SYS,
        Commit    = *NONE,
        CloSqlCsr = *ENDACTGRP;

// Imposta opzioni derivate dai parametri
if %trim(p_REGEX)='*YES';
   useRegex=*on;
else;
   useRegex=*off;
endif;

if %trim(p_LOG)='*YES';
   logSQL=*on;
else;
   logSQL=*off;
endif;

if %trim(p_CASE)='*SENSITIVE';
   vCase='S';
   rxFlag='';
else;
   vCase='I';
   rxFlag='i';
endif;

// CSV path e MBROPT
exec sql values SESSION_USER into :usr;
if %trim(p_CSVFOLDER)='*USRHOME';
   csvPath='/home/'+%trim(usr)+'/';
else;
   csvPath =%trim(p_CSVFOLDER);
   x=%len(csvPath);
   if %subst(csvPath:x:1)<>'/';
      csvPath=csvPath+'/';
    endif;
endif;
csvFolder=csvPath;
if %trim(p_CSVFILE)='*AUTO';
   csvPath=csvPath+'findmbr_'+%CHAR(YTIMESTAMP)+'.csv';
else;
   csvPath =csvPath+%trim(p_CSVFILE);
endif;

if %trim(p_APPEND)='*YES';
   mbrOpt='*ADD';
else;
   mbrOpt='*REPLACE';
endif;

CreatePath(csvFolder);

// Pulizia/creazione tabelle di lavoro
exec sql drop table qtemp/results;
exec sql drop table qtemp/cands;
exec sql drop table qtemp/pairs;

exec sql create table qtemp/results(
  lib     char(10),
  srcfile char(10),
  mbr     char(10),
  srcseq  dec(6, 2),
  srcdta  varchar(200));
exsr PRTERR;

exec sql create table qtemp/pairs(lib char(10), sfile char(10));
exsr PRTERR;

// Carica coppie FILE/LIB (supporta *SRCPF)
for i = 1 to p_file.p_filecount;
  i1=20*(i-1)+1;
  FileEntry=%subst(p_file.p_filestr:i1:20);
  if %trim(FileEntry)<>'';
     exec sql insert into qtemp/pairs values(:FileEntry.Lib, :FileEntry.File);
     exsr PRTERR;
  endif;
endfor;

// Costruisce elenco candidati (usa SOURCE_TYPE per *SRCPF)
sqlcmd ='';
for i=1 to %elem(SSQL1);
  if SSQL1(i)='';
    leave;
  endif;
  sqlcmd = %trimr(sqlcmd)+%TRIMR(SSQL1(i));
endfor;
exec sql execute immediate :sqlcmd;
exsr PRTLOG;

// Espressione e filtro commenti
if vCase='I';
  expr ='UPPER(SRCDTA)';
else;
  expr ='SRCDTA';
endif;

// Cursor candidati e loop membri
exec sql declare C cursor for select lib, srcfile, mbr from qtemp/cands;
exec sql open C;
exsr PRTERR;

dow '00000' = sqlstate;
  exec sql fetch C into :lib,:srcfile,:mbr;
  if sqlcode<>0;
  leave;
  endif;

  // Alias univoco
  alias = 'FINDMBR';

  // Create alias for member
  sqlcmd = 'CREATE OR REPLACE ALIAS QTEMP/' + %trim(alias) +
        ' FOR "' + %trim(lib) + '"/"' + %trim(srcfile) + '"("' + %trim(mbr) + '")';
  exec sql execute immediate :sqlcmd;
  exsr PRTLOG;

  // Set where and having
  BuildPreds( expr : useRegex : rxFlag : vCase
            : p_TOK1 : p_TOK2 : p_TOK3 : p_TOK4 : p_TOK5
            : predLine : predAny : having);

  // Insert matching lines
  if %trim(p_MODE)='*OR' or %trim(p_MODE)='*ANDLINE';
     sqlcmd = 'INSERT INTO QTEMP/RESULTS (LIB,SRCFILE,MBR,SRCSEQ,SRCDTA) ' +
           'SELECT ''' + %trim(lib) + ''',''' + %trim(srcfile) + ''',''' + %trim(mbr) + ''',' +
           'SRCSEQ,SRCDTA FROM QTEMP/' + %trim(alias) +
           ' WHERE ' + %trim(predLine) + whereCom +
           ' ORDER BY SRCSEQ';
     exec sql execute immediate :sqlcmd;
     exsr PRTLOG;
  else;
     sqlcmd ='INSERT INTO QTEMP/RESULTS (LIB,SRCFILE,MBR,SRCSEQ,SRCDTA) ' +
           'SELECT ''' + %trim(lib) + ''',''' + %trim(srcfile) + ''',''' + %trim(mbr) + ''',' +
           'SRCSEQ,SRCDTA FROM (SELECT SRCSEQ,SRCDTA FROM QTEMP/' + %trim(alias) + ') F, ' +
           '(SELECT 1 AS OK FROM (SELECT SRCSEQ,SRCDTA FROM QTEMP/' + %trim(alias) + ') '+
           ' GROUP BY 1 HAVING ' + %trim(having) + ') H ' +
           ' WHERE ' + %trim(predAny) + whereCom +
           ' ORDER BY SRCSEQ';
     exec sql execute immediate :sqlcmd;
     exsr PRTLOG;
  endif;

  sqlcmd = 'DROP ALIAS QTEMP/' + %trim(alias);
  exec sql execute immediate :sqlcmd;
  exsr PRTLOG;

enddo;

exec sql close C;

// Export CSV
cmd = %trim(CMDARR(1))+' '+%trim(CMDARR(2));
cmd = %scanrpl('&path':csvPath:cmd);

QCMDEXC(cmd:%len(%trimr(cmd)));

*inlr = *on;
return;
// ---------------------------------------------------------------
//  Print error
// ---------------------------------------------------------------
BEGSR PRTERR;

  if sqlcod < 0;

    exec sql
        GET DIAGNOSTICS EXCEPTION 1 :Msg = MESSAGE_TEXT;

    STR132='SQLCOD '+%editc(sqlcod:'P');
    EXSR PRTROW;
    WordWrap( Msg : 100 : lines );

    for i = 1 to %elem(lines);
      if %len(lines(i)) = 0;
          leave;
      endif;

      STR132=lines(i);
      EXSR PRTROW;
    endfor;
  endif;

ENDSR;
// ---------------------------------------------------------------
//  Print log
// ---------------------------------------------------------------
BEGSR PRTLOG;

  EXSR PRTERR;

  if logSQL=*on;
    WordWrap( sqlcmd : 80 : lines );

    for i = 1 to %elem(lines);
      if %len(lines(i)) = 0;
          leave;
      endif;

      STR132=lines(i);
      EXSR PRTROW;
    endfor;
  endif;

ENDSR;
// ---------------------------------------------------------------
//  Print row
// ---------------------------------------------------------------
BEGSR PRTROW;

  IF STR132<>'';
      IF NOT %OPEN(QSYSPRT);
          OPEN  QSYSPRT;
          *INOA = *ON;
      ENDIF;
      IF *INOA = *ON;
         SS1132=*all'-';
         write QSYSPRT SS1132;
         SS2132 = YPGMNAME+' - '+%CHAR(YTODAYISO)+' '+%CHAR(YTIME)+' - '+YUSER;
         write QSYSPRT SS2132;
         write QSYSPRT SS1132;
         *INOA = *OFF;
      ENDIF;
      write QSYSPRT STR132;
  ENDIF;

ENDSR;
// =======================================================================
dcl-proc BuildPreds;
  dcl-pi BuildPreds;
    expr        varchar(64) const;
    useRx       ind         const;
    rxFlag      char(1)     const;
    vCase       char(1)     const;
    t1          varchar(300) const;
    t2          varchar(300) const;
    t3          varchar(300) const;
    t4          varchar(300) const;
    t5          varchar(300) const;
    oPredLine   varchar(32766);
    oPredAny    varchar(32766);
    oHaving     varchar(32766);
  end-pi;

  dcl-s predLine varchar(32766) inz('1=1');
  dcl-s predAny  varchar(32766) inz('1=0');
  dcl-s having   varchar(32766) inz('');
  dcl-s first ind inz(*on);
  dcl-s a varchar(300) dim(5);
  dcl-s n int(10);
  dcl-s lit varchar(300);
  dcl-s v   varchar(300);

  dcl-c APICE '''';
  dcl-c doppioAPICE '''''';

  a(1)=t1;
  a(2)=t2;
  a(3)=t3;
  a(4)=t4;
  a(5)=t5;

  for n=1 to 5;
    if %trim(a(n))<>'';
      lit = %scanrpl(APICE:doppioAPICE:%trimr(a(n)));
      if useRx;
        predLine += ' AND REGEXP_LIKE(' + expr + ',''' + lit + ''',''' + rxFlag + ''')';
        predAny  += ' OR REGEXP_LIKE(' + expr + ',''' + lit + ''',''' + rxFlag + ''')';
        if first;
          having   += '';
        else;
          having   +=' AND ';
        endif;
        having   += ' SUM(CASE WHEN REGEXP_LIKE(' + expr + ',''' + lit + ''',''' + rxFlag +
                    ''') THEN 1 ELSE 0 END)>0';
      else;
        if vCase='I';
          v=%upper(lit);
        else;
          v=lit;
        endif;
        predLine += ' AND ' + expr + ' LIKE ''%' + v + '%''';
        predAny  += ' OR ' + expr + ' LIKE ''%' + v + '%''';
        if first;
          having   += '';
        else;
          having   +=' AND ';
        endif;
        having   += 'SUM(CASE WHEN ' + expr + ' LIKE ''%' + v + '%'' THEN 1 ELSE 0 END)>0';
      endif;
      first = *off;
    endif;
  endfor;

  oPredLine = predLine;
  oPredAny  = %subst(predAny:7);
  oHaving   = having;
end-proc;
//---------------------------------------------------------------------
//  WordWrap( text : maxLen : lines[] )
//
//  testo   = stringa lunga da spezzare
//  maxLen  = lunghezza massima per riga
//  righe   = array di righe wrappate (varchar)
//---------------------------------------------------------------------

dcl-proc WordWrap;
   dcl-pi WordWrap;
      pText    varchar(32767)   const;
      pMaxLen  int(10)          const;
      pLines   varchar(100)   dim(500);
   end-pi;

   dcl-s start   int(10) inz(1);
   dcl-s pos     int(10);
   dcl-s endPos  int(10);
   dcl-s chunk   varchar(32767);
   dcl-s len     int(10);
   dcl-s idx     int(10);

   len = %len(%trimr(pText));

   dow start <= len;

      // Se resta meno di pMaxLen prendi tutto
      if (start + pMaxLen - 1 >= len);
         chunk = %subst(pText : start);
         idx=idx+1;
         pLines(idx) = %trimr(chunk);
         leave;
      endif;

      // Altrimenti cerchiamo uno spazio *prima* del limite
      endPos = start + pMaxLen - 1;
      pos = endPos;

      dow pos > start and %subst(pText : pos : 1) <> ' ';
         pos -= 1;
      enddo;

      if pos = start;
         // Niente spazio trovato taglio brutale
         pos = endPos;
      endif;

      chunk = %subst(pText : start : pos - start + 1);
      idx=idx+1;
      pLines(idx) = %trimr(chunk);

      // Avanza saltando eventuali spazi
      start = pos + 1;
      dow start <= len and %subst(pText : start : 1) = ' ';
         start += 1;
      enddo;

   enddo;

end-proc;
//---------------------------------------------------------------------
//  CreatePath( path )
//---------------------------------------------------------------------
dcl-proc CreatePath;
   dcl-pi CreatePath;
      pPath    varchar(1024)   const;
   end-pi;
   Dcl-S mode         Uns(10);
   Dcl-S retcod       Int(10);
   Dcl-S $P           Int(5);

         //           ...Costruisco l'intera struttura
    if Access(%trimr(pPath): F_OK) < 0;

      if errno = ENOENT;

          mode=S_IRWXU+S_IRWXG;
          $P=1;
          DOW $P > 0;
              $P=%SCAN('/':pPath:$P);
              SELECT;
                WHEN $P > 0 AND %TRIM(%SUBST(pPath:1:$P))<>'/';
                    retcod=mkdir(%TRIM(%SUBST(pPath:1:$P)) :mode);
                    IF retcod<0;
              // gestisco errore
                    ENDIF;
                    $P=$P+1;
//           ....Continuo
                WHEN $P > 0;
                    $P=$P+1;
              ENDSL;
          ENDDO;
//           ..Ulrimo percorso
          IF %SUBST(pPath: %LEN(%TRIMR(pPath)):1)<>'/';
              retcod=mkdir(%TRIM(pPath):mode);
              IF retcod<0;
              // gestisco errore
              ENDIF;
          ENDIF;
      else;
          callp EscErrno(errno);
      ENDIF;
    ENDIF;
end-proc;
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QRPGLESRC,ERRNO_H
// =======================================================================
**CTDATA SSQL1
create table qtemp/cands as
(SELECT TRIM(system_table_schema)  AS lib, TRIM(system_table_name)
 AS srcfile, TRIM(system_table_member) AS mbr
 FROM qsys2.syspartitionstat AS S WHERE EXISTS
 (SELECT 1 FROM qtemp/pairs AS P
 WHERE ((P.lib = '*LIBL' AND S.system_table_schema IN
 (SELECT system_schema_name FROM qsys2.library_list_info))
 OR (P.lib <> '*LIBL' AND S.system_table_schema = TRIM(P.lib)))
 AND (P.sfile = '*ALL' OR (P.sfile = '*SRCPF' AND S.source_type IS NOT NULL)
 OR (LOCATE('*', P.sfile) > 0 AND S.table_name LIKE REPLACE(P.sfile, '*', '%'))
 OR (LOCATE('*', P.sfile) = 0 AND S.table_name = TRIM(P.sfile))))) with data
**CTDATA CMDARR
CPYTOIMPF FROMFILE(QTEMP/RESULTS) TOSTMF('&path') MBROPT(*REPLACE)
STMFCCSID(1208) STMFAUT(*INDIR) RCDDLM(*CRLF) FLDDLM(';')