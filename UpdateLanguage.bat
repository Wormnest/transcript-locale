@echo off
set LANGUAGE=%1
if %LANGUAGE%!==! goto help

: test the existence of msgmerge
msgmerge --help 1> tmp1.txt 2> tmp2.txt
if errorlevel 1 goto nomsgmerge

: test the existence of SetPoHeader
:if not exist ..\devtools\bin\SetPoHeader.exe goto noSetPoHeader

: test the existence of the target po
if not exist %LANGUAGE%\LC_MESSAGES\default.po goto ponotfound


: now that we are sure that all required files exist, process transcript.po
echo Updating %LANGUAGE%...
msgmerge --force-po -o %LANGUAGE%\LC_MESSAGES\default.po %LANGUAGE%\LC_MESSAGES\default.po transcript.po

: set the headers to match Transcript ones
:..\devtools\bin\SetPoHeader -t "Transcript localization template" -c "Transcript by Jacob Boerema" -p JVCL -v 3 -a "Jacob Boerema" -e "transcript-translation@jacobboerema.nl" %LANGUAGE%\LC_MESSAGES\default.po 

goto end

:ponotfound
echo Error: %LANGUAGE%\LC_MESSAGES\jvcl.po has not been found.
goto end

:noSetPoHeader
:echo SetPoHeader was not found
:echo Please compile it before running this script. It is available in the devtools directory
goto end

:nomsgmerge
echo msgmerge was not found.
echo This script requires msgmerge from http://dxgettext.sf.net
goto end

:help
echo UpdateLanguage.bat - Updates one language for Transcript
echo.
echo Usage: UpdateLanguage.bat LangId
echo.
echo     LangId is the Id of the language to update. It will
echo     be used as the directory name where to find default.po
echo     for the given language

:end
if exist tmp1.txt del /q tmp?.txt
set LANGUAGE=
