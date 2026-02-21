**FREE
        // ============================================================================== //
        // PGM for command FINDMBR -  IBM i source-member search utility                  //
        // Compile with: CRTBNDRPG PGM(MYLIB/FINDMBR_X) SRCFILE(MYLIB/QRPGLESRC)          //
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
        ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt);

        dcl-f UNIX disk(1000) handler('UNIXCMDOA': cmd) usropn;
        dcl-f QSYSPRT printer(132) usage(*output);

        dcl-pi *n;
          pLeft  char(240) const;
          pRight char(240) const;
          pScriptDir char(240) const;
          pMsg char(100);
          pIndErr ind;
        end-pi;

        dcl-s cmd char(5000);
        dcl-s vcmd varchar(5000);
        dcl-s cmde char(500);
        dcl-ds record len(1000) end-ds;
        dcl-ds outrec len(132) end-ds;
        dcl-pr QCMDEXC  EXTPGM('QCMDEXC');
          cmde char(500) CONST OPTIONS(*VARSIZE);
          lungCmd zoned(15:5) CONST;
        end-pr QCMDEXC;
        dcl-s ScriptDir like(pScriptDir);
        dcl-s scriptPath varchar(500);
        dcl-s Left varchar(240);
        dcl-s Right varchar(240);

        dcl-ds *n PSDS;
          sUser char(10) POS(254);
        end-ds;

        pIndErr = *off;

        cmde = 'ADDENVVAR ENVVAR(QIBM_MULTI_THREADED) VALUE(''Y'')'+
                 ' LEVEL(*JOB) REPLACE(*YES)';
        callp(e) QCMDEXC(cmde: %LEN(cmde));

        scriptDir = %trimr(pScriptDir);
        Left = %trimr(pLeft);
        Right = %trimr(pRight);

        if scriptDir = '';
          pMsg = 'CMPCSV: script directory parameter is empty';
          pIndErr = *on;
          *inlr = *on;
          return;
        endif;

        if %subst(scriptDir:1:1)='~';
          eval scriptDir=%scanrpl('~':'/home/'+%trim(sUser):ScriptDir);
        endif;
        if %subst(Left:1:1)='~';
          eval Left=%scanrpl('~':'/home/'+%trim(sUser):Left);
        endif;
        if %subst(Right:1:1)='~';
          eval Right=%scanrpl('~':'/home/'+%trim(sUser):Right);
        endif;

        scriptPath = %trimr(scriptDir) + '/compare_csv.sh';
        vcmd=scriptPath+' '+Left+' '+Right;
        vcmd = %scanrpl('''':'''\''''':vcmd);
        cmd = 'PATH=/QOpenSys/pkgs/bin:$PATH '+
            'exec /QOpenSys/pkgs/bin/bash -c '''+vcmd+'''';
        open UNIX;
        outrec = 'PATH=/QOpenSys/pkgs/bin:$PATH ';
        write QSYSPRT outrec;
        outrec = 'exec /QOpenSys/pkgs/bin/bash -c ''';
        write QSYSPRT outrec;
        outrec = vcmd+'''';
        write QSYSPRT outrec;

        read UNIX record;
        dow not %eof(UNIX);
          outrec = record;
          write QSYSPRT outrec;
          read UNIX record;
        enddo;

        monitor;
          close UNIX;
        on-error;
          pMsg = 'CMPCSV: Check the spool file for error details';
          pIndErr = *on;
        endmon;

        *inlr = *on;
        return;