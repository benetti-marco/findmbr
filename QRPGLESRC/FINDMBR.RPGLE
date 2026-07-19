**FREE
        // ============================================================================== //
        // PGM for command FINDMBR -  IBM i source-member search utility                  //
        // Compile with: CRTBNDRPG PGM(MYLIB/FINDMBR) SRCFILE(MYLIB/QRPGLESRC)            //
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


        dcl-pr QCMDEXC extpgm('QCMDEXC');
            cmd  char(32702) options(*varsize);
            len  packed(15:5)   const;
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
          p_BATCH      char(4);
          p_JOBQ       char(20);
        end-pi;

        dcl-pr FINDMBR0 extpgm('FINDMBR0');
          p1_FILE       likeds(FileParm);
          p1_TOK1       char(60);
          p1_TOK2       char(60);
          p1_TOK3       char(60);
          p1_TOK4       char(60);
          p1_TOK5       char(60);
          p1_MODE       char(10);
          p1_CASE       char(12);
          p1_REGEX      char(4);
          p1_EXITPGM    char(1);
          p1_CSVFOLDER  char(500);
          p1_CSVFILE    char(50);
          p1_APPEND     char(4);
          p1_WRKLIB     char(10);
          p1_LOG        char(4);
        end-pr;

        dcl-s i         int(10)        inz(0);
        dcl-s f         int(10)        inz(0);
        dcl-s i1        int(10)        inz(0);
        dcl-s sfile     varchar(200);
        dcl-s cmd       char(5000);
        dcl-s Jobqnam   char(10);
        dcl-s Jobqlib   char(10);


        dcl-pr SendEscMsg extpgm('QMHSNDPM');
          msgId    char(7)   const;
          msgFile  char(20)  const;
          msgData  char(256) const;
          msgLen   int(10)   const;
          msgType  char(10)  const;
          callStk  char(10)  const;
          callStkCnt int(10) const;
          msgKey   char(4);
          errCode  char(8);
        end-pr;

        dcl-pr FailWith;
            txt varchar(256) const;
        end-pr;
        dcl-s msgKey char(4);
        dcl-s errCode char(8) inz(*loval);

        dcl-s CMDARR    Char(100)  DIM(7) CTDATA PERRCD(1);
        dcl-s CMDJOBQ   Char(100)  DIM(1) CTDATA PERRCD(1);

        // ===================================================================
        //            MAIN
        // ===================================================================


        // Derive behavior from input parameters

        sFile='';
        
        // Validate that at least TOK1 is provided
        if %trim(p_TOK1) = '';
          FailWith('At least one search token (TOK1) is required.');
          return;
        endif;

        // Validate requested files/libraries before queuing the batch
        for f = 1 to p_file.p_filecount;
          i1=20*(f-1)+1;
          FileEntry=%subst(p_file.p_filestr:i1:20);
          if %trim(FileEntry)<>'';
              if FileEntry.File<>'*SRCPF';
                cmd = 'CHKOBJ OBJ(' + %trim(FileEntry.Lib) + '/' +
                      %trim(FileEntry.File) + ') OBJTYPE(*FILE)';
                monitor;
                  QCMDEXC(cmd:%len(%trimr(cmd)));
                on-error;
                  FailWith('Missing file: ' + %trim(FileEntry.Lib) + '/' +
                    %trim(FileEntry.File));
                  return;
                endmon;
              else;
                cmd = 'CHKOBJ OBJ(' + %trim(FileEntry.Lib) +
                      ') OBJTYPE(*LIB)';
                monitor;
                  QCMDEXC(cmd:%len(%trimr(cmd)));
                on-error;
                  FailWith('Invalid library: ' + %trim(FileEntry.Lib));
                  return;
                endmon;
              endif;
              sFile=sFile+%trim(%upper(FileEntry.Lib))+'/'+
                %trim(%upper(FileEntry.File))+' ';
          endif;
        endfor;

        if p_EXITPGM<>'';
          p_EXITPGM=%upper(p_EXITPGM);
          // Ensure the exit program exists
          cmd = 'CHKOBJ OBJ(FINDMBR_' + %trim(p_EXITPGM) +
                ') OBJTYPE(*PGM)';
          monitor;
            QCMDEXC(cmd:%len(%trimr(cmd)));
          on-error;
            // Clear message and return
                  FailWith('Missing exit program: '+
                    'FINDMBR_' + %trim(p_EXITPGM));
            return;
          endmon;
        endif;
        
        // Ensure the working library exists
        cmd = 'CHKOBJ OBJ(' + %trim(p_WRKLIB) + ') OBJTYPE(*LIB)';
        monitor;
          QCMDEXC(cmd:%len(%trimr(cmd)));
        on-error;
          FailWith('Invalid library: ' + %trim(p_WRKLIB));
          return;
        endmon;

        if %trim(p_BATCH)='*YES';

            Jobqnam=%subst(p_Jobq:01:10);
            Jobqlib=%subst(p_Jobq:11:10);

            if Jobqnam<>'';
              // Ensure the target job queue exists before submission
              cmd = 'CHKOBJ OBJ(' + %trim(Jobqlib) + '/'+%trim(Jobqnam)+
                    ') OBJTYPE(*JOBQ)';
              monitor;
                QCMDEXC(cmd:%len(%trimr(cmd)));
              on-error;
                // Clear message and return
                      FailWith('Missing job queue: '+
                        %trim(Jobqlib)+'/'+%trim(Jobqnam));
                return;
              endmon;
            endif;

            cmd='';
            // Build the SBMJOB command by expanding placeholders
            for i = 1 to %elem(CMDARR);
              if CMDARR(i)='';
                leave;
              endif;
              if i=1;
                cmd=%trimr(CMDARR(i));
              else;
                cmd=%trimr(cmd)+' '+%trimr(CMDARR(i));
              endif;
            endfor;
            if Jobqnam<>'';
                cmd=%trimr(cmd)+' '+%trimr(CMDJOBQ(1));
            endif;
            cmd=%scanrpl('&FILE':%trimr(sfile):cmd);
            cmd=%scanrpl('&TOK1':%trimr(p_TOK1):cmd);
            cmd=%scanrpl('&TOK2':%trimr(p_TOK2):cmd);
            cmd=%scanrpl('&TOK3':%trimr(p_TOK3):cmd);
            cmd=%scanrpl('&TOK4':%trimr(p_TOK4):cmd);
            cmd=%scanrpl('&TOK5':%trimr(p_TOK5):cmd);
            cmd=%scanrpl('&MODE':%trimr(p_MODE):cmd);
            cmd=%scanrpl('&CASE':%trimr(p_CASE):cmd);
            cmd=%scanrpl('&REGEX':%trimr(p_REGEX):cmd);
            cmd=%scanrpl('&EXITPGM':%trimr(p_EXITPGM):cmd);
            cmd=%scanrpl('&CSVFOLDER':%trimr(p_CSVFOLDER):cmd);
            cmd=%scanrpl('&CSVFILE':%trimr(p_CSVFILE):cmd);
            cmd=%scanrpl('&APPEND':%trimr(p_APPEND):cmd);
            cmd=%scanrpl('&WRKLIB':%trimr(p_WRKLIB):cmd);
            cmd=%scanrpl('&LOG':%trimr(p_LOG):cmd);
            cmd=%scanrpl('&JOBQNAM':%trimr(Jobqnam):cmd);
            cmd=%scanrpl('&JOBQLIB':%trimr(Jobqlib):cmd);

            // Submit FINDMBR via SBMJOB to the specified queue
            QCMDEXC(cmd:%len(%trimr(cmd)));
        else;
            // Interactive mode: run in the current job
            FINDMBR0(p_FILE:p_TOK1:p_TOK2:p_TOK3:p_TOK4:p_TOK5:
              p_MODE:p_CASE:p_REGEX:p_EXITPGM:p_CSVFOLDER:p_CSVFILE:
              p_APPEND:p_WRKLIB:p_LOG);
        endif;

        *inlr = *on;
        return;
        // =======================================================================
        dcl-proc FailWith;
          dcl-pi *n;
            txt varchar(256) const;
          end-pi;
          SendEscMsg('CPF9898':'QCPFMSG   *LIBL':txt:%len(txt):
                    '*INFO':'*EXT':0:msgKey:errCode);
        end-proc;
        // =======================================================================
**CTDATA CMDARR
SBMJOB CMD(
FINDMBR FILE(&FILE)
TOK1('&TOK1') TOK2('&TOK2') TOK3('&TOK3') TOK4('&TOK4') TOK5('&TOK5')
MODE(&MODE) CASE(&CASE) REGEXP(&REGEX) EXITPGM(&EXITPGM)
CSVFOLDER('&CSVFOLDER') CSVFILE('&CSVFILE')
APPEND(&APPEND) WRKLIB(&WRKLIB) LOG(&LOG) BCHJOB(*NO)
) JOB(FINDMBR)
**CTDATA CMDJOBQ
JOBQ(&JOBQLIB/&JOBQNAM)
