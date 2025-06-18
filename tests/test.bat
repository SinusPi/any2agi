@echo off
echo [47;30m IT: DEFAULT [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi kq6flute.it out_kq6flute.ags >out_kq6flute.txt
fc out_kq6flute.txt expect-kq6flute-default.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_kq6flute.ags expect-kq6flute-default.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_kq6flute.txt expect-kq6flute-default.txt
del out_*.ags

echo [47;30m IT: AUTODRUMOFFS 2 [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi --auto-drum-offs 2 kq6flute.it out_kq6flute.ags >out_kq6flute.txt
fc out_kq6flute.txt expect-kq6flute-ado2.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_kq6flute.ags expect-kq6flute-ado2.ags >nul
call :RESULTS Output %ERRORLEVEL% 
if "%1"=="savedebug" copy /y out_kq6flute.txt expect-kq6flute-ado2.txt
del out_*.ags out_*.txt

echo [47;30m MOD: INSTRNOTE,INSTRTP [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi --instr 5 note 13 --instr 6 note 14 --instr 4 note 15 --instr 11 note 14 --arpspeed 2 --auto-drum-offs 1 --channels 2,3,4,1 cremona.mod out_cremona.ags >out_cremona.txt
fc out_cremona.txt expect-cremona-id-io-ado.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_cremona.ags expect-cremona-id-io-ado.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_cremona.txt expect-cremona-id-io-ado.txt
del out_*.ags out_*.txt

echo [47;30m MOD: INSTRNOTE,INSTRTP,INSTRARP [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi --length 500 --instr 5 note 13 --instr 6 note 14 --instr 4 note 15 --instr 11 note 14 --instr 1 arp 047 --instr 2 arp 037 --instr 12 arp 037 --instr 13 arp 047 --arpspeed 2 --auto-drum-offs 1 --channels 2,3,4,1 cremona.mod out_cremona.ags >out_cremona.txt
fc out_cremona.txt expect-cremona-id-io-ado-arp.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_cremona.ags expect-cremona-id-io-ado-arp.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_cremona.txt expect-cremona-id-io-ado-arp.txt
del out_*.ags out_*.txt

echo [47;30m MID: DEFAULT [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi --nomidiremap wlaskot.mid out_wlaskot.ags >out_wlaskot.txt
fc out_wlaskot.txt expect-wlaskot-noremap.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_wlaskot.ags expect-wlaskot-noremap.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_wlaskot.txt expect-wlaskot-noremap.txt
del out_*.ags out_*.txt

echo [47;30m MID: REMAP [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi wlaskot.mid out_wlaskot.ags >out_wlaskot.txt
fc out_wlaskot.txt expect-wlaskot-remap.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_wlaskot.ags expect-wlaskot-remap.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_wlaskot.txt expect-wlaskot-remap.txt
del out_*.ags out_*.txt

echo [47;30m VGM: DEFAULT [0m
perl ../it2agi.pl --debug-input --debug-proc --debug-agi aladdin-onejump.vgm out_aladdin-onejump.ags >out_aladdin-onejump.txt
fc out_aladdin-onejump.txt expect-aladdin-onejump.txt >nul
call :RESULTS Debug %ERRORLEVEL% nostop
fc /b out_aladdin-onejump.ags expect-aladdin-onejump.ags >nul
call :RESULTS Output %ERRORLEVEL%
if "%1"=="savedebug" copy /y out_aladdin-onejump.txt expect-aladdin-onejump.txt
del out_*.ags out_*.txt

echo All tests passed.

exit 0


:RESULTS
if "%2"=="0" goto good
:bad
echo %1: [31m### [31;1mFAIL [0;31m###[0m
if "%3"=="nostop" exit /b 1
exit 1
:good
echo %1: [32m*** [32;1mPASS [0;32m***[0m
exit /b 0
