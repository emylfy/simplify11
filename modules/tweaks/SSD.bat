@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (
    echo Not running as admin. Elevating...
    where wt.exe >nul 2>&1
    if %errorlevel% equ 0 (
        powershell "Start-Process -FilePath 'wt.exe' -ArgumentList 'cmd /k \"%~0\"' -Verb runAs"
    ) else (
        powershell "Start-Process -FilePath 'cmd.exe' -ArgumentList '/k \"%~0\"' -Verb runAs"
    )
    exit /b
)

set Purple=[38;5;141m
set Grey=[38;5;250m
set Reset=[0m
set Red=[38;5;203m
set Green=[38;5;120m

powershell "Get-PhysicalDisk | Where-Object { $_.MediaType -eq 'SSD' -or $_.BusType -eq 'NVMe' } | Measure-Object | ForEach-Object { if ($_.Count -gt 0) { exit 0 } else { exit 1 } }"
if %errorlevel% equ 0 (
    echo Enable and optimize TRIM for SSD
    fsutil behavior set DisableDeleteNotify 0

    echo Disable defragmentation for SSDs
    schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
		
    echo Disable NTFS last access time updates
    fsutil behavior set disablelastaccess 1
    
    echo Disabling legacy 8.3 filename creation
    call :reg "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation" "REG_DWORD" "1" "Disabled legacy 8.3 filename creation for better SSD performance"
) else (
    echo No SSD or NVMe detected. Skipping tweaks.
)

echo.
echo %Purple%Press any key to exit...%Reset%
pause >nul
exit /b

:reg
call "%~dp0\..\reg_helper.bat" %*