@echo off

title repLabel v1.0

set PATH=D:\sunyt\01_tool\strawberry\perl\bin;%PATH%

if not  exist D:\sunyt\01_tool\strawberry\perl\bin\perl.exe (
    echo Can not found the perl.exe.
    echo.
    pause
    goto END
)

echo Welcome to repLabel v1.0

    cmd /k repLabel.pl
    
goto END

:END
