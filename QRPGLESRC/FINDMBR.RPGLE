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

dcl-s CMDARR    Char(100)  DIM(7) CTDATA PERRCD(1);

// ===================================================================
//            MAIN
// ===================================================================


// Imposta opzioni derivate dai parametri
if %trim(p_BATCH)='*YES';
    sFile='';
    for f = 1 to p_file.p_filecount;
      i1=20*(f-1)+1;
      FileEntry=%subst(p_file.p_filestr:i1:20);
      if %trim(FileEntry)<>'';
          sFile=sFile+%trim(%upper(FileEntry.Lib))+'/'+
            %trim(%upper(FileEntry.File))+' ';
      endif;
    endfor;

    cmd='';
    for i = 1 to %elem(CMDARR);
      if CMDARR(i)='';
        leave;
      endif;
      cmd=cmd+%trimr(CMDARR(i))+' ';
    endfor;
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

    // sbmjob
    QCMDEXC(cmd:%len(%trimr(cmd)));
else;
    // interactive
    FINDMBR0(p_FILE:p_TOK1:p_TOK2:p_TOK3:p_TOK4:p_TOK5:
      p_MODE:p_CASE:p_REGEX:p_EXITPGM:p_CSVFOLDER:p_CSVFILE:  
      p_APPEND:p_WRKLIB:p_LOG);
endif;

*inlr = *on;
return;
// =======================================================================
**CTDATA CMDARR
SBMJOB CMD(
FINDMBR FILE(&FILE)   
TOK1(&TOK1) TOK2(&TOK2) TOK3(&TOK3) TOK4(&TOK4) TOK5(&TOK5)                              
MODE(&MODE) CASE(&CASE) REGEXP(&REGEXP) EXITPGM(&EXITPGM) 
CSVFOLDER(&CSVFOLDER) CSVFILE(&CSVFILE)                        
APPEND(&APPEND) WRKLIB(&WRKLIB) LOG(&LOG) BCHJOB(*NO)
) JOBQ(QSYS/QSYSNOMAX)     