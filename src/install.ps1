# Define the path to the Start Menu Programs folder
$startMenuPath = [System.Environment]::GetFolderPath('Programs')

# Define the path for the shortcut
$shortcutPath = Join-Path -Path $startMenuPath -ChildPath "Simplify11.lnk"

# Create a new COM object for WScript.Shell
$wshShell = New-Object -ComObject WScript.Shell

# Create a new shortcut
$shortcut = $wshShell.CreateShortcut($shortcutPath)

# Set the target path to launch PowerShell with the desired command
$shortcut.TargetPath = "powershell.exe"

# Set the arguments to execute the command
$shortcut.Arguments = '-NoProfile -ExecutionPolicy Bypass -Command "iwr \"https://dub.sh/simplify11\" | iex"'

# Set the shortcut description
$shortcut.Description = "Launch Simplify11"

# Set the shortcut working directory
$shortcut.WorkingDirectory = $startMenuPath

# Download icon
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnav-kr/windows-11-icons/refs/heads/main/imageres_5308.ico" -OutFile "$env:APPDATA\icon.ico"

# Set the path to the ICO file
$icoPath = "$env:APPDATA\icon.ico"  # Make sure this path points to the ICO file

# Set the icon for the shortcut
$shortcut.IconLocation = $icoPath

# Save the shortcut
$shortcut.Save()

# Output confirmation message
Write-Host "Shortcut 'Simplify11' created in the Start Menu."

# Define the shortcut target and the location of the shortcut
$shortcutPath = "$env:USERPROFILE\Desktop\Simplify11.lnk"
$targetPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Simplify11.lnk"

# Create a WScript.Shell COM object
$shell = New-Object -ComObject WScript.Shell

# Create the shortcut
$shortcut = $shell.CreateShortcut($shortcutPath)

# Set the target path for the shortcut
$shortcut.TargetPath = $targetPath

# Optionally, set the shortcut name and icon (if desired)
$shortcut.Description = "Shortcut to Simplify11"
# $shortcut.IconLocation = "C:\Path\To\Icon.ico" # Uncomment and set if you want a custom icon

# Save the shortcut
$shortcut.Save()
