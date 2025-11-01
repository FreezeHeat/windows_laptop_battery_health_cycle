# -----------------------------------------------------------------------------
# Battery Manager Script - A script to manage laptop battery charge cycles
# to prolong battery life by staying within a 40%-80% range.
# -----------------------------------------------------------------------------

<#
.SYNOPSIS
    Monitors battery charge and provides voice notifications to connect/disconnect
    AC power or shuts down the system if the charge drops too low.

.DESCRIPTION
    The script runs in an infinite loop, checking the battery level every 60 seconds.
    - If plugged in (AC Power is ON) and charge >= 80%: Plays a voice notification 
      to disconnect the charger.
    - If unplugged (AC Power is OFF) and charge <= 40%: Plays a voice notification
      and then initiates a system shutdown.
    - Also sends a harmless keystroke ('a') every cycle to prevent the system 
      from going to sleep/locking due to inactivity.

.NOTES
    Requires the 'Sapi.spvoice' COM object for voice notifications.
    Needs to run with appropriate permissions to access WMI and perform Stop-Computer.
#>
function Show-HelpText {
    Write-Host "--- Battery Manager Script ---" -ForegroundColor Cyan
    Write-Host "Monitoring battery charge to keep it between 40% and 80%." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop the script." -ForegroundColor Red
    Write-Host ""
    Write-Host "✅ Status Check Interval: 60 seconds" -ForegroundColor Green
    Write-Host "⬆️ Upper Limit (Disconnect Charger): 80%" -ForegroundColor Green
    Write-Host "⬇️ Lower Limit (System Shutdown): 40%" -ForegroundColor Green
    Write-Host ""
}

# --- Configuration ---
$CheckIntervalSeconds = 60 # How often to check the battery status (in seconds)
$NotificationCount = 5      # Number of times to repeat the voice notification
$UpperLimit = 80            # Upper limit of battery charge percentage
$LowerLimit = 40            # Lower limit of battery charge percentage

# --- Initialization ---
# Create COM objects once outside the loop for efficiency
try {
    $WShell = New-Object -ComObject "Wscript.Shell"
    $Voice = New-Object -ComObject Sapi.spvoice
    $Voice.Rate = 0
} catch {
    Write-Error "Failed to initialize COM objects (Wscript.Shell or Sapi.spvoice). Check permissions."
    Exit 1
}

# Show help text at startup
Show-HelpText

# --- Main Loop ---
While ($true) {
    # Get current battery and AC status
    try {
        $BatteryAC = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine
        $BatteryCharge = (Get-WmiObject win32_battery).estimatedChargeRemaining
    } catch {
        Write-Warning "Could not retrieve battery status. Retrying in $CheckIntervalSeconds seconds."
        Start-Sleep -Seconds $CheckIntervalSeconds
        continue
    }

    # Log current status
    $Status = if ($BatteryAC) {"PLUGGED IN (AC)"} else {"UNPLUGGED (Battery)"}
    Write-Host "$(Get-Date -Format 'HH:mm:ss') | Charge: $BatteryCharge% | Status: $Status"

    # Keep the PC active by sending a harmless keystroke
    $WShell.SendKeys("a")

    # --- AC Connected Logic (Depletion needed) ---
    if ($BatteryAC) {
        if ($BatteryCharge -ge $UpperLimit) {
            $Message = "Take the AC power off the PC so it can deplete the power. Current charge is $BatteryCharge percent."
            Write-Warning "!!! ALERT: $Message"
            
            # Repeat the voice notification $NotificationCount times
            1..$NotificationCount | ForEach-Object {
                $Voice.Speak($Message)
                Start-Sleep -Milliseconds 500 # Short pause between repeats
            }
        }
    }
    # --- AC Disconnected Logic (Charging or Shutdown needed) ---
    else {
        if ($BatteryCharge -le $LowerLimit) {
            # Low Battery Alert and Shutdown
            $Message1 = "Computer has depleted the battery to $BatteryCharge percent."
            $Message2 = "Shutting down system in 10 seconds!"
            Write-Error "!!! CRITICAL: $Message1 $Message2"

            # Repeat the voice notification $NotificationCount times
            1..$NotificationCount | ForEach-Object {
                $Voice.Speak($Message1)
                $Voice.Speak($Message2)
                Start-Sleep -Milliseconds 500 # Short pause between repeats
            }
            
            # Initiate Shutdown
            Start-Sleep -Seconds 10 # Give the user 10 seconds to cancel (Ctrl+C)
            Stop-Computer -ComputerName localhost -Force
        }
    }

    # Wait before checking again
    Start-Sleep -Seconds $CheckIntervalSeconds
}
