@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
title Simplify11

:: Define colors
set "cRosewater=[38;5;224m"
set "cFlamingo=[38;5;210m"
set "cPink=[38;5;212m"
set "cMauve=[38;5;141m"
set "cRed=[38;5;203m"
set "cMaroon=[38;5;167m"
set "cGreen=[38;5;120m"
set "cTeal=[38;5;116m"
set "cSky=[38;5;111m"
set "cSapphire=[38;5;69m"
set "cBlue=[38;5;75m"
set "cGrey=[38;5;250m"
set "cReset=[0m"

cls
echo.
echo.
echo %cRosewater%   "Before using any of the options, please make a system restore point,%cReset%
echo %cRosewater%   I do not take any responsibility if you break your system, lose data,%cReset%
echo %cRosewater%   or have a performance decrease, thank you for understanding"%cReset%
echo.
echo %cFlamingo%   I tried as hard as possible to make the script universal for everyone!%cReset%
echo.
echo.

:restoreSuggestion
echo %cGrey%Checking for existing 'Pre-Script Restore Point'...%cReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        set "hasRestorePoint=1"
        echo %cGrey%Pre-Script Restore Point already exists. You can apply it from the main menu.%cReset%
        pause
        goto main
    )
)

echo %cGrey%Would you like to create a system restore point before proceeding?%cReset%
echo %cGrey%This is recommended to safely revert changes if needed%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==2 goto main

echo %cGrey%Configuring system restore settings...%cReset%
call :reg "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "REG_DWORD" "0" >nul 2>&1
if errorlevel 1 (
    echo %cRed%Failed to create restore point. Please ensure System Protection is enabled.%cReset%
    timeout /t 2 >nul
)

echo %cGrey%Creating system restore point (this may take a moment)...%cReset%
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop" >nul 2>&1
if errorlevel 1 (
    echo %cRed%Failed to create restore point. Please ensure System Protection is enabled.%cReset%
    echo %cRed%You can enable it in System Properties ^> System Protection.%cReset%
    pause
) else (
    echo %cGreen%Restore point created successfully.%cReset%
    timeout /t 2 >nul
)

:main
title Simplify11
cls
echo.
echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve% '%cMauve% Simpler way to setup your system with Tweaks ^& Scripts %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
if "%hasRestorePoint%"=="1" (
    echo %cMauve% '%cGrey% [0] Use Existing Restore Point                         %cMauve%'%cReset%
)
echo %cMauve% '%cGrey% [1] Apply Performance Tweaks                           %cMauve%'%cReset%
echo %cMauve% '%cGrey% [2] Free Up Space                                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [3] WinUtil - Install Programs, Tweaks and Fixes       %cMauve%'%cReset%
echo %cMauve% '%cGrey% [4] Privacy.Sexy - Tool to enforce privacy in clicks   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [5] Winget - Install programs without browser          %cMauve%'%cReset%
echo %cMauve% '%cGrey% [6] Check other cool stuff                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [7] Check Laptop Manufacturers                         %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
if "%hasRestorePoint%"=="1" (
    choice /C 01234567 /N /M " "
) else (
    choice /C 1234567 /N /M " "
)
if "%hasRestorePoint%"=="1" (
    if %errorlevel%==1 goto applyRestorePoint
    set /a "menuChoice=!errorlevel!-1"
) else (
    set "menuChoice=%errorlevel%"
)
goto s!menuChoice!

:applyRestorePoint
cls
echo %cGrey%Applying the Pre-Script Restore Point...%cReset%
powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | ForEach-Object { Restore-Computer -RestorePoint $_.SequenceNumber -Confirm:$false }"
if errorlevel 1 (
    echo %cRed%Failed to apply restore point. Please try applying it manually through System Restore.%cReset%
) else (
    echo %cGreen%Restore point applied successfully.%cReset%
    echo %cGrey%It is recommended to restart your computer to ensure all changes take effect.%cReset%
    echo %cGrey%Would you like to restart now?%cReset%
    choice /C YN /N /M "[Y] Yes [N] No: "
    if !errorlevel!==1 (
        shutdown /r /t 0
    ) else (
        echo %cGrey%Restart your PC to take full effect.%cReset%
        pause
    )
)
pause

:s1
call :applyTweaks
goto main

:s2
call :freeUpSpace
goto main

:s3
call :launchWinUtil
goto main

:s4
call :launchPrivacySexy
goto main

:s5
call :wingetInstall
goto main

:s6
call :coolStuff
goto main

:s7
goto :laptopMenu

:applyTweaks

:: Storage Type Selection
cls
echo %cGrey%What type of storage device do you have?%cReset%
echo.
echo %cGrey%[1] SSD/NVMe%cReset%
echo %cGrey%[2] HDD%cReset%
echo.
choice /C 12 /N /M "%cGrey%Select your storage type: %cReset%"

if errorlevel 2 (
    echo %cGrey%HDD selected - Skipping SSD optimizations...%cReset%
) else (
    echo %cGreen%SSD/NVMe selected - Applying SSD optimizations...%cReset%
    :: Enable and optimize TRIM for SSD
    fsutil behavior set DisableDeleteNotify 0
    :: Disable defragmentation for SSDs
    schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
    :: Disable NTFS last access time updates
    fsutil behavior set disablelastaccess 1
    :: Disable creation of MS-DOS short file names
    call :reg "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation" "REG_DWORD" 1
)

:checkLaptop
set "isLaptop=false"
for /f "delims=" %%i in ('powershell -NoProfile -Command ^
    "Get-CimInstance -ClassName Win32_SystemEnclosure | ForEach-Object { $_.ChassisTypes }"') do (
    if "%%i"=="8"  set "isLaptop=true"
    if "%%i"=="9"  set "isLaptop=true"
    if "%%i"=="10" set "isLaptop=true"
    if "%%i"=="14" set "isLaptop=true"
    if "%%i"=="30" set "isLaptop=true"
)

if "%isLaptop%"=="false" (
    call :applyPowerIntensiveTweaks
)

if "%isLaptop%"=="true" (
    echo %cGrey%Do you want to apply tweaks that will use maximum power and can drain the battery faster?%cReset%
    choice /C YN /N /M "[Y] Yes [N] No: "
    if errorlevel 2 (
        call :skipPowerIntensiveTweaks
    )
)

:applyPowerIntensiveTweaks
 :: CPU Performance Tuning by Kizzimo
: source - https://github.com/AlchemyTweaks/Verified-Tweaks/blob/main/Max%20Pending%20Interrupts%20
: Minimizes the number of interrupts waiting, reducing latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
: Keeps I/O processing instant, minimizing wait times.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_MAX_PENDING_IO" "REG_SZ" "0"
: Prevents CPU from idling to maintain maximum performance.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_IDLE_POLICY" "REG_SZ" "0"
: Always allows the CPU to boost for better performance.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_BOOST_POLICY" "REG_SZ" "2"
: Allows the CPU to reach maximum frequency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_MAX_FREQUENCY" "REG_SZ" "100"
: Ensures interrupts are balanced across all CPU cores.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_INTERRUPT_BALANCE_POLICY" "REG_SZ" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "MKL_DEBUG_CPU_TYPE" "REG_SZ" "10"
:: I/O Performance Tuning
: Immediate completion of I/O requests to minimize latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "IO_COMPLETION_POLICY" "REG_SZ" "0"
: Increases the number of simultaneous I/O requests.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "IO_REQUEST_LIMIT" "REG_SZ" "1024"
: No pending I/O for disk operations, reducing read/write latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DISK_MAX_PENDING_IO" "REG_SZ" "0"
: Maximize I/O priority for all operations to minimize bottlenecks.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "IO_PRIORITY" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DISK_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "IO_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: Power Management and Performance
: Disables power throttling, ensuring high performance at all times.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "POWER_THROTTLE_POLICY" "REG_SZ" "0"
: Disables idle timeout to maintain continuous high performance.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "POWER_IDLE_TIMEOUT" "REG_SZ" "0"
: Enforces high-performance power policy, disabling all power-saving features.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CPU_POWER_POLICY" "REG_SZ" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DISABLE_DYNAMIC_TICK" "REG_SZ" "yes"
:: Memory and Latency Tuning
: Increase memory allocation to allow more data in memory for faster access.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "MEMORY_MAX_ALLOCATION" "REG_SZ" "0"
: Minimizes memory latency, optimizing for faster memory access.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "MEMORY_LATENCY_POLICY" "REG_SZ" "0"
: Enables memory prefetch to speed up data access in memory.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "MEMORY_PREFETCH_POLICY" "REG_SZ" "2"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "MEMORY_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DWM_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DWM_COMPOSITOR_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: Network and Connectivity Tuning
: Increases network buffer size for faster throughput.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_BUFFER_SIZE" "REG_SZ" "512"
: Disables interrupt coalescing for lower network latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_INTERRUPT_COALESCING" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: Miscellaneous Performance Tuning
: Sets the smallest possible timer resolution for the highest responsiveness.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "TIMER_RESOLUTION" "REG_SZ" "0"
: Prioritizes immediate thread scheduling to reduce latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "THREAD_SCHEDULER_POLICY" "REG_SZ" "0"
: Minimizes GPU interrupts for faster rendering.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "GPU_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: Network Adapter Performance Tuning
: Ensures no pending interrupts for network devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_ADAPTER_PENDING_INTERRUPTS" "REG_SZ" "0"
: Ensures instant I/O processing for network operations.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_ADAPTER_MAX_PENDING_IO" "REG_SZ" "0"
: Disables interrupt moderation for lower network latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_ADAPTER_INTERRUPT_MODERATION" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "NETWORK_ADAPTER_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: Storage Device (HDD/SSD) Performance Tuning
: Ensures no pending interrupts for storage devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "STORAGE_DEVICE_PENDING_INTERRUPTS" "REG_SZ" "0"
: Ensures storage I/O operations are processed immediately.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "STORAGE_DEVICE_MAX_PENDING_IO" "REG_SZ" "0"
: Forces immediate completion of storage I/O tasks.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "STORAGE_DEVICE_COMPLETION_POLICY" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "STORAGE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "STORAGE_DEVICE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: USB Device Performance Tuning
: No pending interrupts for USB devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "USB_DEVICE_PENDING_INTERRUPTS" "REG_SZ" "0"
: Processes USB I/O instantly, reducing latency.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "USB_DEVICE_MAX_PENDING_IO" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "USB_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "USB_DEVICE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: PCIe Device Performance Tuning
: No pending interrupts for PCIe devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PCIE_DEVICE_PENDING_INTERRUPTS" "REG_SZ" "0"
: Ensures PCIe I/O operations are processed immediately.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PCIE_DEVICE_MAX_PENDING_IO" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PCIE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PCIE_DEVICE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: GPU Performance Tuning
: Reduces GPU interrupt queue to zero for immediate processing.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "GPU_PENDING_INTERRUPTS" "REG_SZ" "0"
: Ensures compute operations are processed without delay.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "GPU_MAX_PENDING_COMPUTE" "REG_SZ" "0"
: Forces immediate rendering tasks processing.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "GPU_MAX_PENDING_RENDER" "REG_SZ" "0"
:: Audio Device Performance Tuning
: Ensures no pending interrupts for sound cards.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "AUDIO_DEVICE_PENDING_INTERRUPTS" "REG_SZ" "0"
: Keeps audio buffer size low to reduce latency in sound processing.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "AUDIO_DEVICE_BUFFER_SIZE" "REG_SZ" "512"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "AUDIO_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "AUDIO_DEVICE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"
:: General Device Tuning
: Generic setting to ensure no pending interrupts for all devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DEVICE_PENDING_INTERRUPTS" "REG_SZ" "0"
: Ensures immediate I/O operations across all devices.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DEVICE_MAX_PENDING_IO" "REG_SZ" "0"
: Forces devices to complete tasks instantly.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DEVICE_COMPLETION_POLICY" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "DEVICE_MAX_PENDING_INTERRUPTS" "REG_SZ" "0"

:skipPowerIntensiveTweaks
:: Changing Interrupts behavior for lower latency
: source - https://youtu.be/Gazv0q3njYU
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "InterruptSteeringDisabled" "REG_DWORD" "1"

:: Mouse & Keyboard Tweaks

:: These settings disable Enhance Pointer Precision, which increases pointer speed with mouse speed
:: This can be useful generally, but it causes cursor issues in games
:: It's recommended to disable this for gaming
call :reg "HKCU\Control Panel\Mouse" "MouseSpeed" "REG_SZ" "0"
call :reg "HKCU\Control Panel\Mouse" "MouseThreshold1" "REG_SZ" "0"
call :reg "HKCU\Control Panel\Mouse" "MouseThreshold2" "REG_SZ" "0"

:: The MouseDataQueueSize and KeyboardDataQueueSize parameters set the number of events stored in the mouse and keyboard driver buffers
:: A smaller value means faster processing of new information
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" "REG_DWORD" "20"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" "REG_DWORD" "20"

:: Disable StickyKeys
:: These settings disable the annoying Sticky Keys feature when Shift is pressed repeatedly, and the delay in character input.

call :reg "HKCU\Control Panel\Accessibility" "StickyKeys" "REG_SZ" "506"
call :reg "HKCU\Control Panel\Accessibility\ToggleKeys" "Flags" "REG_SZ" "58"
call :reg "HKCU\Control Panel\Accessibility\Keyboard Response" "DelayBeforeAcceptance" "REG_SZ" "0"
call :reg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatRate" "REG_SZ" "0"
call :reg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatDelay" "REG_SZ" "0"
call :reg "HKCU\Control Panel\Accessibility\Keyboard Response" "Flags" "REG_SZ" "122"

:: GPU Tweaks
:: The HwSchMode parameter optimizes hardware-level computation scheduling (Hardware Accelerated GPU Scheduling), reducing latency on lower-end GPUs.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "REG_DWORD" "2"
call :reg "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "EnablePreemption" "REG_DWORD" "0"

:: Network Tweaks

:: By default, Windows uses network throttling to limit non-multimedia traffic to 10 packets per millisecond (about 100 Mb/s).
:: This is to prioritize CPU access for multimedia applications, as processing network packets can be resource-intensive.
:: However, it's recommended to disable this setting, especially with gigabit networks, to avoid unnecessary interference.
: source - https://youtu.be/EmdosMT5TtA
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "REG_DWORD" "4294967295"
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NoLazyMode" "REG_DWORD" "1"

:: CPU Tweaks

:: LazyMode is a software flag that allows the system to skip some hardware events when CPU load is low.
:: Disabling it can use more resources for event processing, so we set the timer to a minimum of 1ms (10000ms).
: source - https://youtu.be/FxpRL7wheGc
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "LazyModeTimeout" "REG_DWORD" "25000"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" "Start" "REG_DWORD" "2"

:: Power Tweaks

:: Power Throttling is a service that slows down background apps to save energy on laptops.
:: In this case, it's unnecessary, so it's recommended to disable it.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" "PowerThrottlingOff" "REG_DWORD" "1"

: source - https://github.com/ancel1x/Ancels-Performance-Batch
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "EnergyEstimationEnabled" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "EventProcessorEnabled" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "CsEnabled" "REG_DWORD" "0"

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks

:: Specify priority for services (drivers) to handle interrupts first.
:: Windows uses IRQL to determine interrupt priority. If an interrupt can be serviced, it starts execution.
:: Lower priority tasks are queued. This ensures critical services are prioritized for interrupts.
call :reg "HKLM\SYSTEM\CurrentControlSet\services\DXGKrnl\Parameters" "ThreadPriority" "REG_DWORD" "15"
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBHUB3\Parameters" "ThreadPriority" "REG_DWORD" "15" 
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBXHCI\Parameters" "ThreadPriority" "REG_DWORD" "15" 
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "ThreadPriority" "REG_DWORD" "31"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "ThreadPriority" "REG_DWORD" "31"

:: Set Priority For Programs Instead Of Background Services
: source - https://youtu.be/bqDMG1ZS-Yw
call :reg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" "REG_DWORD" 0x00000024
: source -
call :reg "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" IRQ8Priority "REG_DWORD" 1
call :reg "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" IRQ16Priority "REG_DWORD" 2

:: Boot System & Software without limits
call :reg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "Startupdelayinmsec" "REG_DWORD" "0"

:: Disable Automatic maintenance
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" "REG_DWORD" "1"

:: Speed up start time
call :reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DelayedDesktopSwitchTimeout" "REG_DWORD" "0"

:: Disable ApplicationPreLaunch & Prefetch
:: The outdated Prefetcher and Superfetch services run in the background, analyzing loaded apps/libraries/services.
:: They cache repeated data to disk and then to RAM, speeding up app launches.
:: However, with an SSD, apps load quickly without this, so constant disk caching is unnecessary.
powershell Disable-MMAgent -ApplicationPreLaunch
call :reg "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" "REG_DWORD" "0"
call :reg "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "SfTracingState" "REG_DWORD" "0"

:: Reducing time of disabling processes and menu
call :reg "HKCU\Control Panel\Desktop"  "AutoEndTasks" "REG_SZ" "1"
call :reg "HKCU\Control Panel\Desktop"  "HungAppTimeout" "REG_SZ" "1000"
call :reg "HKCU\Control Panel\Desktop"  "WaitToKillAppTimeout" "REG_SZ" "2000"
call :reg "HKCU\Control Panel\Desktop"  "LowLevelHooksTimeout" "REG_SZ" "1000"
call :reg "HKCU\Control Panel\Desktop"  "MenuShowDelay" "REG_SZ" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" "REG_SZ" "2000"

:: Memory Tweaks
: source - https://github.com/SanGraphic/QuickBoost/blob/main/v2/MemoryTweaks.bat

:: Enabling Large System Cache makes the OS use all RAM for caching system files,
:: except 4MB reserved for disk cache, improving Windows responsiveness.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" "REG_DWORD" "1"

:: Disabling Windows attempt to save as much RAM as possible, such as sharing pages for images, copy-on-write for data pages, and compression
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingCombining" "REG_DWORD" "1"

:: Enabling this parameter keeps the system kernel and drivers in RAM instead of the page file, improving responsiveness.
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" "REG_DWORD" "1"

:: DirectX Tweaks
:: source - https://youtu.be/itTcqcJxtbo
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_ENABLE_UNSAFE_COMMAND_BUFFER_REUSE" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_ENABLE_RUNTIME_DRIVER_OPTIMIZATIONS" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_RESOURCE_ALIGNMENT" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D11_MULTITHREADED" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_MULTITHREADED" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D11_DEFERRED_CONTEXTS" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_DEFERRED_CONTEXTS" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D11_ALLOW_TILING" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D11_ENABLE_DYNAMIC_CODEGEN" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_ALLOW_TILING" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_CPU_PAGE_TABLE_ENABLED" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_HEAP_SERIALIZATION_ENABLED" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" "D3D12_MAP_HEAP_ALLOCATIONS" "REG_DWORD" "1"
call :reg "HKLM\SOFTWARE\Microsoft\DirectX" '"D3D12_RESIDENCY_MANAGEMENT_ENABLED" "REG_DWORD" "1"

:: Serialize Timer Expiration mechanism, officially documented in Windows Internals 7th Edition Part 2
:: source - https://youtu.be/wil-09_5H0M
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" '"SerializeTimerExpiration" "REG_DWORD" "1"

goto customGPUTweaks

:customGPUTweaks
cls
echo %colorText%What size of RAM do you have?%colorReset%
echo.
echo %colorText%[1] 4GB%colorReset%
echo %colorText%[2] 6GB%colorReset%
echo %colorText%[3] 8GB%colorReset%
echo %colorText%[4] 16GB%colorReset%
echo %colorText%[5] 32GB%colorReset%
echo %colorText%[6] 64GB%colorReset%
echo %colorText%[7] Skip if Unsure%colorReset%
choice /C 1234567 /N /M "%colorSapphire%>%colorReset%"
if errorlevel 7 goto main
call :setRAMSize %errorlevel%

:setRAMSize
set "ramSize=%1"
set "svcHostThreshold="
set "ramSizeText="

if !ramSize! == 1 (
    set "svcHostThreshold=68764420"
    set "ramSizeText=4GB"
)
if !ramSize! == 2 (
    set "svcHostThreshold=103355478"
    set "ramSizeText=6GB"
)
if !ramSize! == 3 (
    set "svcHostThreshold=137922056"
    set "ramSizeText=8GB"
)
if !ramSize! == 4 (
    set "svcHostThreshold=376926742"
    set "ramSizeText=16GB"
)
if !ramSize! == 5 (
    set "svcHostThreshold=861226034"
    set "ramSizeText=32GB"
)
if !ramSize! == 6 (
    set "svcHostThreshold=1729136740"
    set "ramSizeText=64GB"
)

if defined svcHostThreshold (
    call :reg "HKLM\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" "REG_DWORD" "!svcHostThreshold!"
    echo %colorGreen%Successfully applied tweak for !ramSizeText! RAM.%colorReset%
) else (
    echo %colorRed%Invalid selection.%colorReset%
)
pause
goto next

:next
cls
echo %colorText%What kind of video card do you have?%colorReset%
echo.
echo %colorText%[1] NVIDIA%colorReset%
echo %colorText%[2] AMD%colorReset%
echo.
echo %colorText%[3] Skip if Unsure%colorReset%
echo.
choice /C 123 /N /M "%colorSapphire%>%colorReset%"
if errorlevel 3 goto main
if errorlevel 2 goto amd
if errorlevel 1 goto nvidia

:nvidia
: source - https://github.com/AlchemyTweaks/Verified-Tweaks/blob/main/Nvidia/RmGpsPsEnablePerCpuCoreDpc
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "RmGpsPsEnablePerCpuCoreDpc" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" "RmGpsPsEnablePerCpuCoreDpc" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "RmGpsPsEnablePerCpuCoreDpc" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\NVAPI" "RmGpsPsEnablePerCpuCoreDpc" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" "RmGpsPsEnablePerCpuCoreDpc" "REG_DWORD" "1"

goto main

:amd
: source - https://youtu.be/nuUV2RoPOWc
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "AllowSnapshot" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "AllowSubscription" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "AllowRSOverlay" "REG_SZ" "false"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "AllowSkins" "REG_SZ" "false"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "AutoColorDepthReduction_NA" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableUVDPowerGatingDynamic" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableVCEPowerGating" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisablePowerGating" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableDrmdmaPowerGating" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableDMACopy" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableBlockWrite" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "StutterMode" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_GPUPowerDownEnabled" "REG_DWORD" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "LTRSnoopL1Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "LTRSnoopL0Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "LTRNoSnoopL1Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "LTRMaxNoSnoopLatency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "KMD_RpmComputeLatency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DalUrgentLatencyNs" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "memClockSwitchLatency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_RTPMComputeF1Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_DGBMMMaxTransitionLatencyUvd" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_DGBPMMaxTransitionLatencyGfx" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DalNBLatencyForUnderFlow" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRSnoopL1Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRSnoopL0Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRNoSnoopL1Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRNoSnoopL0Latency" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRMaxSnoopLatencyValue" "REG_DWORD" "1"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "BGM_LTRMaxNoSnoopLatencyValue" "REG_DWORD" "1" 

goto main

:freeUpSpace

:: Disable Reserved Storage
echo.
echo %cGrey%Would you like to disable Reserved Storage?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Disabling Reserved Storage...%cReset%
    dism /Online /Set-ReservedStorageState /State:Disabled
)

:: Cleanup WinSxS
echo.
echo %cGrey%Would you like to clean up WinSxS?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Cleaning up WinSxS...%cReset%
    dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth
)

:: Remove Virtual Memory
echo.
echo %cGrey%Would you like to remove Virtual Memory (pagefile.sys)?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Removing Virtual Memory...%cReset%
    powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value ''"
)

:: Clear Windows Update Folder
echo.
echo %cGrey%Would you like to clear the Windows Update Folder?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Clearing Windows Update Folder...%cReset%
    rd /s /q %systemdrive%\Windows\SoftwareDistribution
    md %systemdrive%\Windows\SoftwareDistribution
)

:: Advanced disk cleaner
echo.
echo %cGrey%Would you like to run the advanced disk cleaner?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Running advanced disk cleaner...%cReset%
    cleanmgr /sagerun:65535
)

:: Install and Launch PC Manager
echo.
echo %cGrey%Would you like to install and launch PC Manager? (Official Microsoft Utility from Store)%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Installing PC Manager...%cReset%
    winget install Microsoft.PCManager --accept-package-agreements --accept-source-agreements
    if !errorlevel! equ 0 (
        echo %cGreen%Successfully installed PC Manager.%cReset%
        echo %cGrey%Launching PC Manager...%cReset%
    ) else (
        echo %cRed%Failed to install PC Manager. Please try manually.%cReset%
        pause
    )
)

goto main

:launchWinUtil
cls
start cmd /c powershell -Command "irm 'https://christitus.com/win' | iex"
goto main

:launchPrivacySexy
cls
start "" "https://privacy.sexy/"
echo %cGrey%Recommended to set a Standard option if you are not sure what to do%cReset%
echo %cGrey%and also dont forget to download revert version for your selected tweaks if anything can go wrong%cReset%
pause
goto main

:wingetInstall
title Simplify11: Install apps
cls

:: Define packages for winget installation
set "pkg[1]=Microsoft.VisualStudioCode"
set "pkg[2]=Python"
set "pkg[3]=OpenJS.NodeJS"
set "pkg[4]=Anysphere.Cursor"
set "pkg[5]=Git.Git"
set "pkg[6]=GitHub.GitHubDesktop"
set "pkg[7]=TheBrowserCompany.Arc"
set "pkg[8]=Alex313031.Thorium"
set "pkg[9]=Zen-Team.Zen-Browser"
set "pkg[10]=Yandex.Browser"
set "pkg[11]=Microsoft.PowerToys"
set "pkg[12]=M2Team.NanaZip"
set "pkg[13]=agalwood.motrix"
set "pkg[14]=MartiCliment.UniGetUI"
set "pkg[15]=TechPowerUp.NVCleanstall"
set "pkg[16]=NVIDIA.Broadcast"
set "pkg[17]=RadolynLabs.AyuGramDesktop"
set "pkg[18]=Vencord.Vesktop"
set "pkg[19]=lencx.ChatGPT"
set "pkg[20]=Doist.Todoist"
set "pkg[21]=RustemMussabekov.Raindrop"
set "pkg[22]=Valve.Steam"
set "pkg[23]=EpicGames.EpicGamesLauncher"
set "pkg[24]=Microsoft.DirectX"
set "pkg[25]=Microsoft.DotNet.Runtime.8"
set "pkg[26]=Microsoft.PCManager"
set "pkg[27]=Microsoft.EdgeWebView2Runtime"

echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve%  %cGreen%[0] Search for any program                              %cMauve% %cReset%
echo.
echo %cMauve%  %cGreen%Development Tools:                                      %cMauve% %cReset%
echo %cMauve%  %cGrey%[1] Visual Studio Code  [2] Python                     %cMauve% %cReset%
echo %cMauve%  %cGrey%[3] Node.js             [4] Cursor                     %cMauve% %cReset%
echo %cMauve%  %cGrey%[5] Git                 [6] GitHub Desktop             %cMauve% %cReset%
echo %cMauve%  %cGreen%Browsers:                                              %cMauve% %cReset%
echo %cMauve%  %cGrey%[7] Arc                 [8] Thorium                    %cMauve% %cReset%
echo %cMauve%  %cGrey%[9] Zen                 [10] Yandex                    %cMauve% %cReset%
echo %cMauve%  %cGreen%Utilities:                                             %cMauve% %cReset%
echo %cMauve%  %cGrey%[11] PowerToys          [12] NanaZip                   %cMauve% %cReset%
echo %cMauve%  %cGrey%[13] Motrix             [14] UniGetUI                  %cMauve% %cReset%
echo %cMauve%  %cGrey%[15] NVCleanstall       [16] NVIDIA Broadcast         %cMauve% %cReset%
echo %cMauve%  %cGreen%Social ^& Productivity:                                 %cMauve% %cReset%
echo %cMauve%  %cGrey%[17] AyuGram            [18] Vesktop                   %cMauve% %cReset%
echo %cMauve%  %cGrey%[19] ChatGPT            [20] Todoist                   %cMauve% %cReset%
echo %cMauve%  %cGrey%[21] Raindrop                                          %cMauve% %cReset%
echo %cMauve%  %cGreen%Gaming:                                                %cMauve% %cReset%
echo %cMauve%  %cGrey%[22] Steam              [23] Epic Games Store          %cMauve% %cReset%
echo %cMauve%  %cGreen%Microsoft Stuff:                                       %cMauve% %cReset%
echo %cMauve%  %cGrey%[24] DirectX            [25] .NET 8.0                  %cMauve% %cReset%
echo %cMauve%  %cGrey%[26] PC Manager         [27] Edge WebView              %cMauve% %cReset%
echo.
echo %cMauve%  %cGrey%[28] Update all installed apps                          %cMauve% %cReset%
echo %cMauve%  %cGrey%[29] Back to Main Menu                                 %cMauve% %cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%

set /p choice="%cSapphire%Enter your choices (space-separated numbers '1 2'): %cReset%"

:: Process each number in the input sequentially
for %%a in (%choice%) do (
    if %%a==0 (
        goto searchPkg
    ) else if %%a==28 (
        echo %cGrey%Updating all installed apps...%cReset%
        winget upgrade --all --accept-package-agreements --accept-source-agreements
        if !errorlevel! equ 0 (
            echo %cGreen%Successfully updated all apps.%cReset%
        ) else (
            echo %cRed%Failed to update some apps. Error code: !errorlevel!%cReset%
            pause
        )
    ) else if %%a==29 (
        goto main
    ) else (
        :: Check if it's a valid number
        set /a "num=%%a" 2>nul
        if !num! geq 1 if !num! leq 27 (
            if defined pkg[%%a] (
                echo.
                echo %cGrey%Installing !pkg[%%a]!...%cReset%
                winget install --id !pkg[%%a]! --accept-package-agreements --accept-source-agreements
                if !errorlevel! equ 0 (
                    echo %cGreen%Successfully installed !pkg[%%a]!%cReset%
                ) else (
                    echo %cRed%Failed to install !pkg[%%a]!. Error code: !errorlevel!%cReset%
                    pause
                )
            ) else (
                echo %cRed%No package defined for choice %%a%cReset%
                pause
            )
        ) else (
            echo %cRed%Invalid choice: %%a%cReset%
            pause
        )
    )
)

goto wingetInstall

:searchPkg
cls
echo %cGrey%Enter Program name to search (or 'b' to return):%cReset%
set /p "searchTerm="
if /i "%searchTerm%"=="b" goto wingetInstall
if /i "%searchTerm%"=="" goto searchPkg

echo %cGrey%Searching for "%searchTerm%"...%cReset%
winget search "%searchTerm%"
echo.
echo %cGrey%Enter the exact package ID to install (or 'b' to return):%cReset%
set /p "packageId="
if /i "%packageId%"=="b" goto wingetInstall
if /i "%packageId%"=="" goto searchPkg

call :installPkg "%packageId%"
goto wingetInstall

:installPkg
set "packageId=%~1"
echo.
echo %cGrey%Installing %packageId%...%cReset%
winget install --id %packageId% --accept-package-agreements --accept-source-agreements
if !errorlevel! equ 0 (
    echo %cGreen%Successfully installed %packageId%%cReset%
    goto searchPkg
) else (
    echo %cRed%Failed to install %packageId%. Error code: !errorlevel!%cReset%
    pause
    goto searchPkg
)

:coolStuff
cls
start "" "https://github.com/emylfy/simplify11?tab=readme-ov-file#-cool-stuff"
pause
goto main

:laptopMenu
cls
:: Define URLs for modern laptop manufacturers
set "url[0]=https://support.hp.com/us-en/drivers"
set "url[1]=https://support.lenovo.com"
set "url[2]=https://www.asus.com/support/download-center/"
set "url[3]=https://www.acer.com/ac/en/US/content/drivers"
set "url[4]=https://www.msi.com/support/download"
set "url[5]=https://www.huawei.com/en/support"
set "url[6]=https://www.xiaomi.com/global/support"
set "url[7]=https://www.alienware.com/support"
set "url[8]=https://www.gigabyte.com/support/consumer"

echo %cGrey%Select your laptop manufacturer to install drivers:%cReset%
echo.
echo %cGrey%[0] HP%cReset%
echo %cGrey%[1] Lenovo%cReset%
echo %cGrey%[2] Asus%cReset%
echo %cGrey%[3] Acer%cReset%
echo %cGrey%[4] MSI%cReset%
echo %cGrey%[5] Huawei%cReset%
echo %cGrey%[6] Xiaomi%cReset%
echo %cGrey%[7] Alienware%cReset%
echo %cGrey%[8] Gigabyte%cReset%
echo.
echo %cGrey%[9] Back to menu%cReset%

choice /C 0123456789 /N /M "Select a number: "
set /A "choice=%errorlevel%-1"

if %choice% geq 0 if %choice% leq 8 (
    start "" "!url[%choice%]!"
    goto main
) else if %choice%==9 (
    goto main
) else (
    echo %cRed%Invalid choice. Returning to main menu.%cReset%
    timeout /t 2 >nul
    goto main
)

:reg
set "key=%~1"
set "valueName=%~2"
set "valueType=%~3"
set "valueData=%~4"
reg.exe add "%key%" /v "%valueName%" /t "%valueType%" /d "%valueData%" /f
goto :eof

@REM reg add "HKEY_CURRENT_USER\Control Panel\International" sShortDate "REG_SZ" "d MMM yy"