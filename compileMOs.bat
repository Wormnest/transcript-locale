@echo off

call SetLanguages.bat

echo Compile Transcript PO translations to MO translations
echo Current languages: %LANGUAGES%

FOR %%l IN (%LANGUAGES%) DO call compileMO.bat %%l


pause
