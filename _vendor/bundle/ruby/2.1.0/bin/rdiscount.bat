@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
@"c:\Ruby21-x64\bin\ruby.exe" "C:/Ruby21-x64/axgit/_vendor/bundle/ruby/2.1.0/bin/rdiscount" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@"c:\Ruby21-x64\bin\ruby.exe" "%~dpn0" %*
