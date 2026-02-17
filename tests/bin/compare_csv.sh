#!/QOpenSys/pkgs/bin/bash

## ============================================================================== 
## PGM for command FINDMBR -  IBM i source-member search utility                  
## Compile with: CRTBNDRPG PGM(MYLIB/FINDMBR_X) SRCFILE(MYLIB/QRPGLESRC)          
## ============================================================================== 
## ============================================================================== 
## MIT License                                                                    
##                                                                                
## Copyright (c) 2025-2026 Marco Benetti                                          
##                                                                                
## Permission is hereby granted, free of charge, to any person obtaining a copy   
## of this software and associated documentation files (the "Software"), to deal  
## in the Software without restriction, including without limitation the rights   
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      
## copies of the Software, and to permit persons to whom the Software is          
## furnished to do so, subject to the following conditions:                       
##                                                                                
## The above copyright notice and this permission notice shall be included in all 
## copies or substantial portions of the Software.                                
##                                                                                
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
## SOFTWARE.                                                                      
## ============================================================================== 

if [ "$#" -ne 2 ]; then
  echo "ERROR: expected 2 arguments: <left_csv> <right_csv>"
  exit 1
fi

left="$1"
right="$2"

if [ ! -r "$left" ] || [ ! -r "$right" ]; then
  echo "ERROR: one or both files are missing or not readable"
  exit 1
fi

diff <(sed 's/\r$//' "$left") <(sed 's/\r$//' "$right") >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "OK: files are identical"
  exit 0
fi

echo "DIFF: files are different"
exit 1
