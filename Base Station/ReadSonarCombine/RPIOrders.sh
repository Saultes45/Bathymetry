file="/home/pi/Desktop/Matlab_has_been_there"
if [ -f "$file" ]
then
	echo "$file found."
    rm $file
else
	echo "$file not found."
fi
#file="/home/pi/Desktop/USV/Config_5.ini"
#if [ -f "$file" ]
#then
#	echo "$file found."
#    rm $file
#else
#	echo "$file not found."
#fi

cd /home/pi/Desktop/USV

#if [ -f *.ini" ]
#then
#	echo "$file found."
#else
#	echo "$file not found."
#fi

## Delete all Config_.ini files in the USV folder
find . -maxdepth 1 -name 'Config_*.ini' -delete

touch /home/pi/Desktop/Matlab_has_been_there