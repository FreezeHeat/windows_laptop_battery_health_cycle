# Laptop Battery Health Cycle script

Lithium batteries' health can degrade without proper care and without daily
use.

To keep these batteries healthy, the following procedure is suggested to be done
once each month

1. Charge to 80%
2. Deplete to 40%
3. Archive the battery/laptop

While these also applies to any other lithium batteries (like smartphones), this
focuses on devices which **aren't** used daily.

## What the script does

* The script detects whether the laptop is being charged or not
* It uses Windows' TTS engine to speak via the speakers and notify you
* It will shutdown your laptop once it's done
* You can change the parameters yourself in the .ps1 file, for example, the
  upper limit of the charging and the lower limit for powering off the laptop,
by default these are set to 40% lower and 80% higher limit

Procedure:

* If the laptop is charging
    1. Notify the user to unplug the charger when it reaches 80%
* If the laptop is discharging
    1. Notify the user about shutting down when it reaches 40%
    2. Shuts down the laptop
