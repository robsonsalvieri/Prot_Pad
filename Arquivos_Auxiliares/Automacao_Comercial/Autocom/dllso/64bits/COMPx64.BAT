set LIB=%LIB%;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\ucrt\x64

@echo off
del autocom.dll /f
\eadvpl\eadvpl autocom.ttl -target=WIN64DLL -name=DLL -g
if errorlevel 1 goto end-pause
goto copia

:copia
copy \ver811\autocom\dllso\autocom.dll \mp8\bin\remote
if errorlevel 1 goto end-pause
goto end

:end-pause
pause

:end