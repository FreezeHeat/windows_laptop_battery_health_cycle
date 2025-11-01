# The value is true/false if the battery is connected to a power source or not
# state false will allow depletion until 41% and will then shutdown the computer
# state true will allow to charge unti 100% and will then play a voice to tell you to disconnect the power
$battery_ac = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine

# Get current battery level
$battery = (Get-WmiObject win32_battery).estimatedChargeRemaining

# Upper/Lower limits of battery charge percentage
$upper_limit = 80
$lower_limit = 40

# Keep the PC going by sending some keystrokes
$WShell = New-Object -Com "Wscript.Shell"
$WShell.SendKeys("a")

# Voice object to say stuff via speakers
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0

if ( $battery_ac )
{
        if( $battery -ge $upper_limit )
        {               
                $voice.speak("Take the AC power off the PC so it can deplete the power") 
                $voice.speak("Take the AC power off the PC so it can deplete the power")
                $voice.speak("Take the AC power off the PC so it can deplete the power")
        }
}
else
{
        if ( $battery -le $lower_limit )
        {
        $voice.speak("Computer the depleted battery to 40%")
        $voice.speak("Shutting down")
        $voice.speak("Shutting down!!!")
                Stop-Computer -ComputerName localhost
        }
}