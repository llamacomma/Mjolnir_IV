@echo off
echo Generating SHA256 for Vanilla\dinput8.dll...
powershell -Command "(Get-FileHash 'Vanilla\dinput8.dll' -Algorithm SHA256).Hash"
echo.
echo Generating SHA256 for Ultimate ASI Loader\Mjolnir_IV.asi...
powershell -Command "(Get-FileHash 'Ultimate ASI Loader\Mjolnir_IV.asi' -Algorithm SHA256).Hash"
echo.
echo Paste these values into SHA256.txt before distributing.
pause
