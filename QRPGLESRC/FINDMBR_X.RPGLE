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

        // ===================================================================

        // *ENTRY
        dcl-pi *n;
          srcpfarr  char(10) dim(100);
        end-pi;

        dcl-s srcpflist Char(10)  DIM(100) CTDATA PERRCD(1);

        // ===================================================================
        //            MAIN
        // ===================================================================

        srcpfarr=srcpflist;

        *inlr = *on;
        return;
        // =======================================================================
**CTDATA srcpflist
OLDCMDSRC
OLDRPGSRC