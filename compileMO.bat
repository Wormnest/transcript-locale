@echo off
set LANGUAGE=%1
if %LANGUAGE%!==! goto help

: test the existence of msgfmt
msgfmt --help 1> tmp1.txt 2> tmp2.txt
if errorlevel 1 goto nomsgfmt

: test the existence of the target po
if not exist %LANGUAGE%\LC_MESSAGES\default.po goto ponotfound

: now that we are sure that all required files exist, process transcript.po
echo Updating %LANGUAGE%...
msgfmt -o %LANGUAGE%\LC_MESSAGES\default.mo %LANGUAGE%\LC_MESSAGES\default.po

goto end

:ponotfound
echo Error: %LANGUAGE%\LC_MESSAGES\default.po does not exist.
goto end

:noSetPoHeader
:echo SetPoHeader was not found
:echo Please compile it before running this script. It is available in the devtools directory
goto end

:nomsgfmt
echo msgfmt was not found.
echo This script requires msgmerge from http://dxgettext.sf.net
goto end

:end
if exist tmp1.txt del /q tmp?.txt
set LANGUAGE=
