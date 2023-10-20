#!/bin/bash
## check HW model and run the specific scripts

compatible="$(</proc/device-tree/compatible)"

case ${compatible} in:
lemaker,bananaproallwinner,sun7i-a20) 
	hwsbc_rtc.bpi.sh
	hwsbc_setup.bpi.sh
	;;
*) 
	echo "ERROR: /proc/device-tree/compatible '${compatible}' not known, aborting."
	exit 1
	;;
esac
