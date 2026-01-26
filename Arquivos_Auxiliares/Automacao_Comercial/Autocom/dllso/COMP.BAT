@echo off
del autocom.dll /f
\eadvpl\eadvpl autocom.prg -target=WIN32DLL -name=DLL -g
if errorlevel 1 goto end-pause
goto copia

:copia
copy \ver811\autocom\dllso\autocom.dll \mp8\bin\remote
if errorlevel 1 goto end-pause
goto end

:end-pause
pause

:end