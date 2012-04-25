@echo off

call SetLanguages.bat

echo Update Transcript PO template file and the translations derived from it
echo Current languages: %LANGUAGES%

: test the existence of dxgettext
dxgettext -q -b. >tmp1.txt 2>tmp2.txt
if errorlevel 1 goto nodxgettext

: test the existence of SetPoHeader
:if exist ..\devtools\bin\SetPoHeader.exe goto nextSetPoHeader
:cd ..\devtools
:make -s SetPoHeader.exe
:cd ..\locale

:nextSetPoHeader
:if not exist ..\devtools\bin\SetPoHeader.exe goto noSetPoHeader

: first, extract all strings
echo Extracting strings from jgb\source...
dxgettext -q -o ..\..\jgb\source -b ..\..\jgb\source --delphi --nonascii --useignorepo
echo Extracting strings from Transcript\stable...
dxgettext -q -o ..\stable -b ..\stable --delphi --nonascii --useignorepo
:echo Extracting strings from Transcript\thirdparty
: currently nothing really important that needs translating so ignore it for now
:dxgettext -q -r -o ..\thirdparty -b ..\thirdparty --delphi --nonascii --useignorepo
: We need some translatable strings from JclUnicode
: However those are defined as CONST meaning it won't get extracted unless we specify
: a flag inside the file which we prefer not to, and we don't need all unicode blocktypes
: anyway, therefore we will make our file by hand from the old translations...
: and we call it unicodeblockdata.po
:dxgettext ..\..\jcl\source\common\JclUnicode.pas -q -b jcl.po --delphi --nonascii --useignorepo

: then merge all the generated po files into one
echo Merging files...
copy ..\stable\default.po default.po
msgcat ..\stable\default.po ..\..\jgb\source\default.po unicodeblockdata.po jvcl-for-transcript.po -o default.po

: ensure uniqueness
msguniq -u --no-wrap default.po -o transcript.po

: remove translations that need to be ignored
echo Removing strings that do not require translation...
if not exist ignore.po msgmkignore transcript.po -o ignore.po
msgremove --no-wrap transcript.po -i ignore.po -o default.po

: merge with existing transcript.po file
echo Updating existing translations...
if exist transcript.po msgmerge -o transcript.po transcript.po default.po 
if not exist transcript.po copy default.po transcript.po

: set the headers to match JVCL ones
:..\devtools\bin\SetPoHeader -t "JVCL localization source file." -c "The JEDI Visual Component Library group." -p JVCL -v 3 -a "JVCL Group" -e "jvcl@sourceforge.net" jvcl.po

echo Translation template transcript.po has been updated

echo Updating languages...
FOR %%l IN (%LANGUAGES%) DO call UpdateLanguage.bat %%l

: cleanup
:echo Cleaning up...
:del ..\run\default.po default.po
: del ..\common\default.po ..\run\default.po default.po

goto end

:noSetPoHeader
echo SetPoHeader was not found
echo Please compile it before running this script. It is available in the devtools directory

goto end

:nodxgettext
echo DxGettext was not found.
echo This script requires dxgettext from http://dxgettext.sf.net

:end
if exist tmp1.txt del /q tmp?.txt
set LANGUAGES=

pause
