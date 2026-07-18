**FREE
        // ============================================================================== //
        // PGM for command FINDMBR -  IBM i source-member search utility                  //
        // Compile with: CRTSQLRPGI OBJ(MYLIB/FINDMBR0) SRCFILE(MYLIB/QRPGLESRC)          //
        //               RPGPPOPT(*LVL2)                                                  //
        // ============================================================================== //
        // ============================================================================== //
        // MIT License                                                                    //
        //                                                                                //
        // Copyright (c) 2025-2026 Marco Benetti                                          //
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
          t1          varchar(60) const;
          t2          varchar(60) const;
          t3          varchar(60) const;
          t4          varchar(60) const;
          t5          varchar(60) const;
          MODE        varchar(10) const;
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

        dcl-pr ExitCall extpgm(exitpgm);
          srcpfarr  char(10) dim(100);
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
          p_TOK1       char(60);
          p_TOK2       char(60);
          p_TOK3       char(60);
          p_TOK4       char(60);
          p_TOK5       char(60);
          p_MODE       char(10);
          p_CASE       char(12);
          p_REGEX      char(4);
          p_EXITPGM    char(1);
          p_CSVFOLDER  char(500);
          p_CSVFILE    char(50);
          p_APPEND     char(4);
          p_WRKLIB     char(10);
          p_LOG        char(4);
        end-pi;

        dcl-s useRegex ind   inz(*off);
        dcl-s logSQL ind   inz(*off);
        dcl-s iS2   ind   inz(*off);
        dcl-s iS3   ind   inz(*off);
        dcl-s iFile ind   inz(*off);
        dcl-s vCase    char(1) inz('I');
        dcl-s rxFlag   char(1) inz('i');

        dcl-s csvPath  varchar(1024) inz('');
        dcl-s csvSummaryPath  varchar(1024) inz('');
        dcl-s csvFolder  varchar(1024) inz('');
        dcl-s mbrOpt   char(10)      inz('*REPLACE');
        dcl-s usr      char(10)      inz('');

        dcl-s i         int(10)        inz(0);
        dcl-s i1        int(10)        inz(0);
        dcl-s r         int(20)        inz(0);
        dcl-s r2        int(20)        inz(0);
        dcl-s rcount    int(20)        inz(0);
        dcl-s f         int(5)        inz(0);
        dcl-s x         int(5)        inz(0);
        dcl-s expr      varchar(64)    inz('');
        dcl-s sql       varchar(32766) inz('');
        dcl-s predLine  varchar(32766) inz('');
        dcl-s predAny   varchar(32766) inz('');
        dcl-s having    varchar(32766) inz('');
        dcl-s lib       char(10)       inz('');
        dcl-s srcfile   char(10)       inz('');
        dcl-s mbr       char(10)       inz('');
        dcl-s mbrdesc   char(50)       inz('');
        dcl-s exitpgm   char(10)       inz('');
        dcl-s srcpfesc  char(10) dim(100);
        dcl-s srcpflst  varchar(1500) inz('');
        dcl-s tmpstring   varchar(100)       inz('');
        dcl-s srctype   char(10)       inz('');
        dcl-s cmd       char(1024)  inz('');
        dcl-s sqlcmd    varchar(10000)  inz('');
        dcl-s sqltmp    varchar(2000)  inz('');
        dcl-s swhere    varchar(1000)  inz('');
        dcl-s sfile     varchar(10)  inz('');
        dcl-s slib     varchar(10)  inz('');
        dcl-s sconditions varchar(600) inz('');
        dcl-s Msg       varchar(30000);
        dcl-s lines     varchar(100) dim(500);
        dcl-s retSqlState  char(5)  inz('');
        dcl-s retSqlCode  packed(5:0)  inz(0);

        dcl-c cQuote       '''';
        dcl-c cDoubleQuote '''''';

        dcl-ds STR132 len(132) end-ds;
        dcl-ds SS1132 len(132) end-ds;
        dcl-ds SS2132 len(132) end-ds;

        dcl-ds *n PSDS;
                  //                   Program name
            YPGMNAME char(10) POS(1);
                  //                   System user name
            YUSER char(10) POS(254);
        end-ds;

        dcl-s YTODAYISO date(*ISO)  INZ(*SYS);
        dcl-s YTIME time(*HMS)  INZ(*SYS);
        dcl-s YTIMESTAMP timestamp  INZ(*SYS);
        dcl-s start_time timestamp;
        dcl-s time_taken int(20);
      /copy QRPGLEINC,IFSIO_H
      /copy QRPGLEINC,ERRNO_H
        dcl-s CMDARR    Char(100)  DIM(02) CTDATA PERRCD(1);
        dcl-s CMDARR2   Char(100)  DIM(02) CTDATA PERRCD(1);
        dcl-s SSQL1     Char(100)  DIM(15) CTDATA PERRCD(1);
        dcl-s SSQL2     Char(100)  DIM(15) CTDATA PERRCD(1);
        dcl-s SSQL3     Char(100)  DIM(15) CTDATA PERRCD(1);
        dcl-s SSQL4     Char(100)  DIM(02) CTDATA PERRCD(1);
        dcl-s SSQL5     Char(100)  DIM(02) CTDATA PERRCD(1);
        dcl-s SWHR1     Char(100)  DIM(03) CTDATA PERRCD(1);

        // ===================================================================
        //            MAIN
        // ===================================================================

        exec sql Set Option
                SQLPATH   = *LIBL,
                Naming    = *SYS,
                Commit    = *NONE,
                CloSqlCsr = *ENDACTGRP;

        start_time=%timestamp();

        // Validate that at least TOK1 is provided
        if %trim(p_TOK1) = '';
          STR132='Error: At least one search token (TOK1) is required.';
          EXSR PRTROW;
          *inlr = *on;
          return;
        endif;

        // Derive options from input parameters
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

        if p_EXITPGM<>'';
            exitpgm='FINDMBR_'+p_EXITPGM;
            callp ExitCall(srcpfesc);
            for x=1 to %elem(srcpfesc);
              if srcpfesc(x)<>'';
                if srcpflst='';
                  srcpflst=cQuote+%trim(srcpfesc(x))+cQuote;
                else;
                  srcpflst=srcpflst+', '+cQuote+%trim(srcpfesc(x))+cQuote;
                endif;
              endif;
            endfor;
        else;
            srcpflst='';
        endif;

        // Resolve CSV path and MBROPT
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
        if %subst(csvPath:1:1)='~';
          eval csvPath=%scanrpl('~':'/home/'+%trim(usr):csvPath);
        endif;
        csvFolder=csvPath;
        if %trim(p_CSVFILE)='*AUTO';
           csvPath=csvPath+'findmbr_'+%CHAR(YTIMESTAMP)+'.csv';
        else;
           csvPath =csvPath+%trim(p_CSVFILE);
        endif;

        // Build summary CSV path
        csvSummaryPath = csvFolder + 'findmbr_' + %CHAR(YTIMESTAMP) + '_summary.csv';

        if %trim(p_APPEND)='*YES';
           mbrOpt='*ADD';
        else;
           mbrOpt='*REPLACE';
        endif;

        CreatePath(csvFolder);

        sqlcmd = 'create or replace table &wrklib/results('+
         ' lib     varchar(10), '+
         ' srcfile varchar(10), '+
         ' mbr     varchar(10), '+
         ' mbrdesc varchar(50), '+
         ' srctype varchar(10), '+
         ' srcseq  varchar(6), '+
         ' srcdta  varchar(600)) '+
         'on replace delete rows';
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        sqlcmd = 'create or replace table &wrklib/mbrlist('+
         ' lib     char(10), '+
         ' srcfile char(10), '+
         ' mbr     char(10), '+
         ' mbrdesc char(50), '+
         ' srctype char(10)) '+
         'on replace delete rows';
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        // Load FILE/LIB pairs (supports *SRCPF)
        iS2=*off;
        iS3=*off;
        sconditions='Libraries/Files:';
        for f = 1 to p_file.p_filecount;
          iFile=*off;
          i1=20*(f-1)+1;
          FileEntry=%subst(p_file.p_filestr:i1:20);
          if %trim(FileEntry)<>'';
              sconditions=%trim(sconditions)+' '+%trim(FileEntry.Lib)+'/'
              +%trim(FileEntry.File)+',';
              sqlcmd ='';
              for i=1 to %elem(SSQL2);
                if SSQL2(i)='';
                  leave;
                endif;
                sqlcmd = %trimr(sqlcmd)+' '+%TRIMR(SSQL2(i));
              endfor;
              if %upper(FileEntry.File)='*SRCPF';
                if srcpflst='';
                  sqlcmd=%scanrpl('&where':'':sqlcmd);
                else;
                  swhere=%trim(SWHR1(3));
                endif;
              else;
                sfile=%scanrpl('*':'%':%upper(FileEntry.File));
                if %scan('%':sfile)=0;
                  swhere=%trim(SWHR1(1));
                else;
                  swhere=%trim(SWHR1(2));
                endif;
                if srcpflst<>'';
                  swhere=%trimr(swhere)+' '+%trim(SWHR1(3));
                endif;
                iFile=*on;
              endif;
              sqlcmd=%scanrpl('&where':swhere:sqlcmd);
              sqlcmd=%scanrpl('&file':FileEntry.File:sqlcmd);
              sqlcmd=%scanrpl('&listfile':srcpflst:sqlcmd);
              sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);

              sLib=%upper(FileEntry.Lib);
              exsr PRTLOG;
              if  iFile=*off;
                if iS2=*off;
                  exec sql prepare s2 from :sqlcmd;
                  exsr PRTERR;
                  iS2=*on;
                endif;
                exec sql execute s2 using :sLib;
              else;
                if iS3=*off;
                  exec sql prepare s3 from :sqlcmd;
                  exsr PRTERR;
                  iS3=*on;
                endif;
                exec sql execute s3 using :sLib , :sfile;
              endif;
              exsr PRTERR;
          endif;
        endfor;
        sconditions=%trim(sconditions)+' Tokens: ';
        if p_TOK1<>'';
          sconditions=%trim(sconditions)+' '+%trim(p_TOK1)+' , ';
        endif;
        if p_TOK2<>'';
          sconditions=%trim(sconditions)+' '+%trim(p_TOK2)+' , ';
        endif;
        if p_TOK3<>'';
          sconditions=%trim(sconditions)+' '+%trim(p_TOK3)+' , ';
        endif;
        if p_TOK4<>'';
          sconditions=%trim(sconditions)+' '+%trim(p_TOK4)+' , ';
        endif;
        if p_TOK5<>'';
          sconditions=%trim(sconditions)+' '+%trim(p_TOK5)+' , ';
        endif;
        sconditions=%scanrpl(cQuote : cDoubleQuote : %trim(sconditions));
        sconditions=%trim(sconditions)+' Params: MODE('+%trim(p_MODE)+')';
        sconditions=%trim(sconditions)+' CASE('+%trim(p_CASE)+')';
        sconditions=%trim(sconditions)+' REGEXP('+%trim(p_REGEX)+')';
        // Expression and comment filtering
        if vCase='I' and useRegex=*off;
          expr ='UPPER(SRCDTA)';
        else;
          expr ='SRCDTA';
        endif;

        // Insert csv header
        sqlcmd='';
        for i=1 to %elem(SSQL4);
            if SSQL4(i)='';
              leave;
            endif;
            sqlcmd = %trimr(sqlcmd)+' '+%TRIMR(SSQL4(i));
        endfor;
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exsr PRTLOG;
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        // Insert conditions
        sqlcmd='';
        for i=1 to %elem(SSQL5);
            if SSQL5(i)='';
              leave;
            endif;
            sqlcmd = %trimr(sqlcmd)+' '+%TRIMR(SSQL5(i));
        endfor;
        sqlcmd=%scanrpl('&conditions':%trim(sconditions):sqlcmd);
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exsr PRTLOG;
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        // loop on members's list
        sqlcmd=SSQL1(1);
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exec sql declare C cursor for s1;
        exec sql prepare s1 from :sqlcmd;
        exsr PRTERR;
        exec sql open C;
        exsr PRTERR;

        // Build WHERE and HAVING clauses
        BuildPreds( expr : useRegex : rxFlag : vCase
                  : p_TOK1 : p_TOK2 : p_TOK3 : p_TOK4 : p_TOK5 : p_MODE
                  : predLine : predAny : having);

        // Insert matching lines
        sqltmp='';
        for i=1 to %elem(SSQL3);
            if SSQL3(i)='';
              leave;
            endif;
            sqltmp = %trimr(sqltmp)+' '+%TRIMR(SSQL3(i));
        endfor;
        sqltmp=%scanrpl('&having':%trim(having):sqltmp);
        sqltmp=%scanrpl('&predAny':%trim(predAny):sqltmp);
        sqltmp=%scanrpl('&predLine':%trim(predLine):sqltmp);
        sqltmp=%scanrpl('&wrklib':%trim(p_WRKLIB):sqltmp);


        r=0;
        r2=0;
        exec sql fetch C into :lib, :srcfile, :mbr, :mbrdesc, :srctype;
        sqlcmd='fetch';
        exsr PRTERR;
        dow '00000' = sqlstate;

          r = r+1;
          // Create alias for member
          sqlcmd = 'CREATE OR REPLACE ALIAS &wrklib/FINDMBR' +
                ' FOR "' + %trim(lib) + '"/"' + %trim(srcfile)
                + '"("' + %trim(mbr) + '")';
          sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
          exsr PRTLOG;
          exec sql execute immediate :sqlcmd;
          exsr PRTERR;

          sqlcmd=sqltmp;
          sqlcmd=%scanrpl('&lib':%trim(lib):sqlcmd);
          sqlcmd=%scanrpl('&srcfile':%trim(srcfile):sqlcmd);
          tmpstring=%scanrpl(cQuote : cDoubleQuote : %trimr(mbrdesc));
          sqlcmd=%scanrpl('&mbrdesc':%trim(tmpstring):sqlcmd);
          sqlcmd=%scanrpl('&mbr':%trim(mbr):sqlcmd);
          sqlcmd=%scanrpl('&srctype':%trim(srctype):sqlcmd);

          if r=1;
            exsr PRTLOG;
          endif;
          exec sql execute immediate :sqlcmd;
          exsr PRTERR;
          if logSQL=*on;
            exec sql GET DIAGNOSTICS :rcount = ROW_COUNT;
            if rcount>0;
              r2=r2+1;
            endif;
          endif;
          exec sql fetch C into :lib, :srcfile, :mbr, :mbrdesc, :srctype;
          sqlcmd='fetch';
          exsr PRTERR;
        enddo;

        sqlcmd = 'DROP ALIAS &wrklib/FINDMBR';
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        exec sql close C;
        sqlcmd='close cursor';
        exsr PRTERR;

        // Create summary table with distinct members that have results
        sqlcmd = 'create or replace table &wrklib/SUMMARY as (' +     
          'SELECT DISTINCT CASE WHEN srcseq > ''000000'' THEN ''000000'' ELSE '+
          'srcseq END as srcseq, lib, srcfile, mbr, mbrdesc, srctype, '+
          'CASE WHEN srcseq > ''000000'' THEN '''' ELSE srcdta END AS srcdta ' +
          'FROM &wrklib/RESULTS ' +
          'ORDER BY srcseq, lib, srcfile, mbr) ' +
          'WITH DATA ON REPLACE DELETE ROWS';             
        sqlcmd=%scanrpl('&wrklib':%trim(p_WRKLIB):sqlcmd);
        exec sql execute immediate :sqlcmd;
        exsr PRTERR;

        // Export detail CSV with UTF-8 BOM
        // If not appending, create file with BOM first, then append CSV data
        if %trim(p_APPEND)<>'*YES';
           // Create file with UTF-8 BOM (EF BB BF) using QSYS2.IFS_WRITE_BINARY
           sqlcmd = %trim(CMDARR2(1))+' '+%trim(CMDARR2(2));
           sqlcmd=%scanrpl('&path':csvPath:sqlcmd);
           exec sql execute immediate :sqlcmd;
           exsr PRTERR;
           // Use ADD mode to append CSV data to BOM file
           mbrOpt='*ADD';
        endif;

        cmd = %trim(CMDARR(1))+' '+%trim(CMDARR(2));
        cmd=%scanrpl('&wrklib':%trim(p_WRKLIB):cmd);
        cmd = %scanrpl('&path':csvPath:cmd);
        cmd=%scanrpl('*REPLACE':mbrOpt:cmd);

        QCMDEXC(cmd:%len(%trimr(cmd)));

        // Export summary CSV
        // If not appending, create file with BOM first, then append CSV data
        if %trim(p_APPEND)<>'*YES';
           // Create file with UTF-8 BOM (EF BB BF) using QSYS2.IFS_WRITE_BINARY
           sqlcmd = %trim(CMDARR2(1))+' '+%trim(CMDARR2(2));
           sqlcmd=%scanrpl('&path':csvSummaryPath:sqlcmd);
           exec sql execute immediate :sqlcmd;
           exsr PRTERR;
           // Use ADD mode to append CSV data to BOM file
           mbrOpt='*ADD';
        endif;

        cmd = %trim(CMDARR(1))+' '+%trim(CMDARR(2));
        cmd=%scanrpl('&wrklib':%trim(p_WRKLIB):cmd);
        cmd = %scanrpl('&path':csvSummaryPath:cmd);
        cmd = %scanrpl('RESULTS': 'SUMMARY': cmd);
        cmd=%scanrpl('*REPLACE':mbrOpt:cmd);
        QCMDEXC(cmd:%len(%trimr(cmd)));

        time_taken = %DIFF (%timestamp() : start_time : *MSECONDS);
        time_taken=time_taken/1000;

        if logSQL=*on;
          STR132='time taken: '+%EDITC(time_taken:'K')+
          ' members analyzed:'+%EDITC(r:'Z')+
          ' members found:'+%EDITC(r2:'Z');
          EXSR PRTROW;
        endif;

        *inlr = *on;
        return;
        // ---------------------------------------------------------------
        //  Print error
        // ---------------------------------------------------------------
        BEGSR PRTERR;

          if sqlcod<0;

            EXSR PRTSQL;

            exec sql
                GET DIAGNOSTICS EXCEPTION 1 :Msg = MESSAGE_TEXT,
                :retSqlCode = DB2_RETURNED_SQLCODE,
                :retSqlState = RETURNED_SQLSTATE;

            STR132='SQLCOD '+%editc(retSqlCode:'P')+ ' - SQLSTATE '+retSqlState;
            EXSR PRTROW;
            WordWrap( Msg : 100 : lines );

            for i = 1 to %elem(lines);
              if %len(lines(i)) = 0;
                  leave;
              endif;

              STR132=lines(i);
              EXSR PRTROW;
            endfor;
            SS1132=*all'-';
            write QSYSPRT SS1132;
          endif;

        ENDSR;
        // ---------------------------------------------------------------
        //  Print log
        // ---------------------------------------------------------------
        BEGSR PRTLOG;

          if logSQL=*on;
            EXSR PRTSQL;
          endif;

        ENDSR;
        // ---------------------------------------------------------------
        //  Print SQL
        // ---------------------------------------------------------------
        BEGSR PRTSQL;

          if sqlcmd<>'';
            WordWrap( sqlcmd : 80 : lines );

            for i = 1 to %elem(lines);
              if %len(lines(i)) = 0;
                  leave;
              endif;

              STR132=lines(i);
              EXSR PRTROW;
            endfor;
            SS1132=*all'-';
            write QSYSPRT SS1132;
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
                 SS2132 = YPGMNAME+' - '+%CHAR(YTODAYISO)+' '+%CHAR(YTIME)
                 +' - '+YUSER;
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
            expr        varchar(64)   const;   // e.g. 'UPPER(SRCDTA)' or 'SRCDTA'
            useRx       ind           const;   // *ON = REGEXP_LIKE, *OFF = LIKE
            rxFlag      char(1)       const;   // 'i' or empty
            vCase       char(1)       const;   // 'I' = uppercase token, 'S' = case sensitive
            t1          varchar(60)  const;
            t2          varchar(60)  const;
            t3          varchar(60)  const;
            t4          varchar(60)  const;
            t5          varchar(60)  const;
            MODE        varchar(10) const;
            oPredLine   varchar(32766);        // => HAS1>0 AND HAS2>0 ...
            oPredAny    varchar(32766);        // => pred1 OR pred2 OR ...
            oHaving     varchar(32766);        // => SUM(CASE WHEN pred1 THEN... ) AS HAS1, ...
          end-pi;

          dcl-s whereAll  varchar(32766) inz('');      // AND di HASn>0
          dcl-s whereAny  varchar(32766) inz('');      // OR di predicati riga
          dcl-s chkCols   varchar(32766) inz('');      // lista SUM(... ) AS HASn

          dcl-s a         varchar(300) dim(5);
          dcl-s n         int(10);
          dcl-s lit       varchar(300);
          dcl-s v         varchar(300);
          dcl-s pred      varchar(1024);
          dcl-s alias     varchar(20);
          dcl-s tokenCnt  int(10) inz(0);

          dcl-c cQuote       '''';
          dcl-c cDoubleQuote '''''';

          // Load tokens into the array
          a(1) = t1;
          a(2) = t2;
          a(3) = t3;
          a(4) = t4;
          a(5) = t5;

          for n = 1 to 5;
            if %trim(a(n)) <> '';
              // Escape quotes inside the token
              lit = %scanrpl(cQuote : cDoubleQuote : %trimr(a(n)));

              // Build per-line predicate using regex or LIKE
              if useRx;
                // REGEXP_LIKE(expr, 'lit', 'rxFlag')
                pred = 'REGEXP_LIKE('+expr+','''+lit+''','''+rxFlag+''')';
              else;
                // LIKE with uppercase handling
                if vCase = 'I';
                  v = %upper(lit);
                else;
                  v = lit;
                endif;
                pred = expr + ' LIKE ''%' + v + '%''';
              endif;

              // Alias for this token in the CHK CTE: HAS1, HAS2, ...
              tokenCnt += 1;
              alias = 'HAS' + %trim(%char(tokenCnt));

              // Add aggregate column to CHK (oHaving)
              if chkCols <> '';
                chkCols += ', ';
              endif;
              chkCols += 'SUM(CASE WHEN ' + pred +
                         ' THEN 1 ELSE 0 END) AS ' + alias;

              // Add condition for tokens being present
              if whereAll = '';
                whereAll = alias + ' > 0';
              else;
                if %trim(MODE)='*OR';
                  whereAll += ' OR ' + alias + ' > 0';
                else;
                  whereAll += ' AND ' + alias + ' > 0';
                endif;
              endif;

              // Add predicate to the OR list of records
              if whereAny = '';
                whereAny = pred;
              else;
                if %trim(MODE)='*ANDLINE';
                  whereAny += ' AND ' + pred;
                else;
                  whereAny += ' OR ' + pred;
                endif;
              endif;

            endif;
          endfor;

          // Output structures
          oPredLine = whereAll;   // eg: 1=1 AND HAS1>0 AND HAS2>0
          oPredAny  = whereAny;   // eg: pred1 OR pred2 OR ...
          oHaving   = chkCols;    // eg: SUM(CASE WHEN pred1...) AS HAS1, ...

        end-proc;

        //---------------------------------------------------------------------
        //  WordWrap( text : maxLen : lines[] )
        //
        //  text    = long string to split
        //  maxLen  = maximum length per line
        //  lines   = array of wrapped lines (varchar)
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

           clear pLines;
           len = %len(%trimr(pText));

           dow start <= len;

                // If fewer than pMaxLen characters remain, take them all
              if (start + pMaxLen - 1 >= len);
                 chunk = %subst(pText : start);
                 idx=idx+1;
                 pLines(idx) = %trimr(chunk);
                 leave;
              endif;

                // Otherwise look for a space before the limit
              endPos = start + pMaxLen - 1;
              pos = endPos;

              dow pos > start and %subst(pText : pos : 1) <> ' ';
                 pos -= 1;
              enddo;

                if pos = start;
                  // No space found; hard cut
                 pos = endPos;
              endif;

                chunk = %subst(pText : start : pos - start + 1);
                idx=idx+1;
                pLines(idx) = %trimr(chunk);

                // Advance and skip any spaces
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

                 // Build the full directory path if missing
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
                      // TODO: handle mkdir error
                            ENDIF;
                            $P=$P+1;
        //           ....Continue
                        WHEN $P > 0;
                            $P=$P+1;
                      ENDSL;
                  ENDDO;
        // Create final path element if needed
                  IF %SUBST(pPath: %LEN(%TRIMR(pPath)):1)<>'/';
                      retcod=mkdir(%TRIM(pPath):mode);
                      IF retcod<0;
                      // TODO: handle mkdir error
                      ENDIF;
                  ENDIF;
              else;
                  callp EscErrno(errno);
              ENDIF;
            ENDIF;
        end-proc;
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QRPGLEINC,ERRNO_H
        // =======================================================================
**CTDATA CMDARR
CPYTOIMPF FROMFILE(&wrklib/RESULTS) TOSTMF('&path') MBROPT(*REPLACE)
STMFCCSID(1208) STMFAUT(*INDIR) RCDDLM(*CRLF) FLDDLM(';') ADDCOLNAM(*NONE)
**CTDATA CMDARR2
CALL QSYS2.IFS_WRITE_BINARY(PATH_NAME => '&path',
LINE => BLOB(X'EFBBBF'), FILE_CCSID => 1208, OVERWRITE => 'REPLACE')
**CTDATA SSQL1
select lib, srcfile, mbr, mbrdesc, srctype from &wrklib/mbrlist order by lib, srcfile, mbr
**CTDATA SSQL2
insert into &wrklib/mbrlist
select a.system_table_schema, a.system_table_name, a.system_table_member,
ifnull(a.partition_text, '') as mbrdesc, ifnull(a.source_type, '') as source_type
FROM qsys2.syspartitionstat a
inner join qsys2.systables c on a.system_table_schema=c.system_table_schema
and a.system_table_name=c.system_table_name
inner join qsys2.syscolumns d on a.system_table_schema=d.table_schema
and a.system_table_name=d.table_name
where a.system_table_schema= ? and c.file_type='S' and d.column_name='SRCDTA'
and IFNULL(d.CCSID, 0) <> 65535
&where
**CTDATA SSQL3
INSERT INTO &wrklib/RESULTS (LIB, SRCFILE, MBR, MBRDESC, SRCTYPE, SRCSEQ, SRCDTA)
WITH BASE AS (SELECT SRCSEQ, SRCDTA FROM &wrklib/FINDMBR),
CHK AS (SELECT &having
FROM BASE)
SELECT '&lib' AS LIB, '&srcfile' AS FILE, '&mbr' AS MBR, '&mbrdesc' AS MBRDESC,
'&srctype' AS SRCTYPE, DIGITS(SRCSEQ), SRCDTA
FROM BASE, CHK WHERE (&predLine)
  AND (&predAny)
ORDER BY SRCSEQ
**CTDATA SSQL4
INSERT INTO &wrklib/RESULTS (LIB,SRCFILE,MBR,MBRDESC,SRCTYPE,SRCSEQ,SRCDTA)
values('Library', 'Src File', 'Member', 'Description', 'Src Type', 'Seq.Nr', 'Row')
**CTDATA SSQL5
INSERT INTO &wrklib/RESULTS (LIB,SRCFILE,MBR,MBRDESC,SRCTYPE,SRCSEQ,SRCDTA)
values('', '', '', 'Conditions', '', '000000', '&conditions')
**CTDATA SWHR1
and a.system_table_name = '&file'
and a.system_table_name like '&file'
and a.system_table_name NOT IN (&listfile)
