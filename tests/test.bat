@echo off
echo [47;30m IT: DEFAULT [0m
perl ../it2agi.pl kq6flute.it out_kq6flute.ags
fc /b out_kq6flute.ags expect-kq6flute-default.ags >nul
call :RESULTS %ERRORLEVEL%

echo [47;30m IT: AUTODRUMOFFS 2 [0m
perl ../it2agi.pl --auto-drum-offs 2 kq6flute.it out_kq6flute_ado2.ags
fc /b out_kq6flute_ado2.ags expect-kq6flute-ado2.ags >nul
call :RESULTS %ERRORLEVEL%

echo [47;30m MOD: INSTRNOTE,INSTRTP [0m
perl ../it2agi.pl --instr-note 5 13 --instr-note 11 14 --instr-shift 7 -12 --auto-drum-offs 1 cremona.mod out_cremona.ags
fc /b out_cremona.ags expect-cremona-id-io-ado.ags >nul
call :RESULTS %ERRORLEVEL%

echo All tests passed.
del out_*.ags

exit 0


:RESULTS
if "%1"=="0" goto good
:bad
echo [31m### [31;1mFAIL [0;31m###[0m
exit 1
:good
echo [32m*** [32;1mPASS [0;32m***[0m
exit /b 0
