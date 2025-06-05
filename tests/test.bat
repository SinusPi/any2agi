@echo off
echo [47;30m IT: DEFAULT [0m
perl ../it2agi.pl kq6flute.it out_kq6flute.ags
fc /b out_kq6flute.ags expect-kq6flute-default.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo [47;30m IT: AUTODRUMOFFS 2 [0m
perl ../it2agi.pl --auto-drum-offs 2 kq6flute.it out_kq6flute.ags
fc /b out_kq6flute.ags expect-kq6flute-ado2.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo [47;30m MOD: INSTRNOTE,INSTRTP [0m
perl ../it2agi.pl --instr-note 5 13 --instr-note 6 14  --instr-note 5 13 --instr-note 4 15 --instr-note 11 14 --arpspeed 2 --auto-drum-offs 1 --channels 2,3,4,1 cremona.mod out_cremona.ags
fc /b out_cremona.ags expect-cremona-id-io-ado.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo [47;30m MOD: INSTRNOTE,INSTRTP,INSTRARP [0m
perl ../it2agi.pl --length 500 --instr-note 5 13 --instr-note 6 14  --instr-note 5 13 --instr-note 4 15 --instr-note 11 14 --instr-arp 1 047 --instr-arp 2 037 --instr-arp 12 037 --instr-arp 13 047 --arpspeed 2 --auto-drum-offs 1 --channels 2,3,4,1 cremona.mod out_cremona.ags
fc /b out_cremona.ags expect-cremona-id-io-ado-arp.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo [47;30m MID: DEFAULT [0m
perl ../it2agi.pl --nomidiremap wlaskot.mid out_wlaskot.ags
fc /b out_wlaskot.ags expect-wlaskot-noremap.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo [47;30m MID: REMAP [0m
perl ../it2agi.pl wlaskot.mid out_wlaskot.ags
fc /b out_wlaskot.ags expect-wlaskot-remap.ags >nul
call :RESULTS %ERRORLEVEL%
del out_*.ags

echo All tests passed.

exit 0


:RESULTS
if "%1"=="0" goto good
:bad
echo [31m### [31;1mFAIL [0;31m###[0m
exit 1
:good
echo [32m*** [32;1mPASS [0;32m***[0m
exit /b 0
