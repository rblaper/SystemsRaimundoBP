#!/usr/bin/env bash
#  /usr/bin/env bash is more portable than than !/bin/bash

# Check that the user is root
#!/usr/bin/env bash
# You ONLY NEED TO ADD ONE COMMAND BETWEEN `` that lists the user currently logged on 

user=`whoami`

if [ "$user" != "root" ]; then
   echo The script should be executed as root
   exit 1
fi

# DON'T TOUCH. Validating the number of parameters. You have to edit nothing
if [ $# -lt 2 ]; then
   echo Invalid number of parameters
   exit 2
fi

# From now on, complete the other parts taking into account that $1 is the first parameter and $2 is the second one. 
# We can create variables and refer to them like $user or $group

group=$2
user=$1

#new vble to check if the user already exists
#filtering username shown the word at the beginning
#-o only one
#echoing group message
#echo  $(grep -o "^$1"  /etc/passwd )
#echo  $(grep -o "^$2"  /etc/group )
#echo  $(grep --only-matching "^${2}"  /etc/group )
#Surround your variables with {}. Otherwise bash will try to access the $ENVIRONMENT_app v

#redirect normal output and errors to the black hole:  &>/dev/null the same as /dev/null 2>&1   
#redirect normal output and errors to the same file using <action > &> prueba.log
#redirect normal output <action> 1> normal.log and 
#redirect errors output <action> 2> error.log

#Some conditinals were added to be aware if the script has already been run

existsG=$(grep --only-matching "^${2}"  /etc/group )

if [[ ! "${existsG}" ]]; then

	#if not exists add the group and user

	sudo groupadd "${2}" &>/dev/null
else
	echo The group already exists
fi

#echoing passwd message
#echo  "$(grep -o "^$1"  /etc/passwd )"
#echo "Hola"
#chpasswd setting a default password
#echo  $(grep -o "^${1}"  /etc/passwd )

existsU=$(grep --only-matching "^${1}"  /etc/passwd )

if [[ ! "${existsU}" ]]; then

	#if not exists add the group and user
	sudo useradd --gid "${2}" --shell /bin/bash --groups sudo  --create-home "${1}"  &>/dev/null && echo "${1}":"${2}" | chpasswd  &>/dev/null

else
	echo The user already exists
fi

#if [ "${1}" != "$exists" ]; then
	#if not exists add the group and user
#	sudo groupadd ${2}
	#adding user usergroup ,shell, secondary group and home
#	sudo useradd -g ${2} -s /bin/bash -G sudo  -m ${1}
#else
#	echo The user and groups already exist
#fi

#echoing name of the directory
#echo  $(ls  /var | grep "${1}")

#checking if directory exists
#find directories && files witj letter grup 
#rsync alternative to cp , also it allows incremental copies also creates the directory

directory=$(ls  /var | grep "${1}")


if [[ ! "${directory}" ]]; then
	#only root can write in var

	sudo mkdir /var/"${1}"/  &>/dev/null
	
# -a, --archive  archive mode; equals -rlptgoD (no -H,-A,-X)
	sudo  find /etc -name grub* | xargs --replace sudo rsync --archive {} /var/"${1}"/grubBackup/  &>/dev/null

	#sudo  find /etc -name grub* | xargs -i sudo cp -r -p {} /var/${1}/grubBackup/ does not work

	sudo touch /var/"${1}"/critical{1,2}.sh   &>/dev/null

	sudo chown "${1}":${2} --recursive /var/"${1}"/
#chmod 750 only directories x permission is needed to go into the directories
	find /var/"${1}" -type d -exec chmod 750 {} \;  &>/dev/null
#chmod 	640 only files
	find /var/"${1}" -type f -exec chmod 640 {} \;  &>/dev/null

	#sudo chmod  640 --recursive /var// 

else

	echo The directory already exists

fi

# For the last part about scheduling tasks, below you will find an example (with different configuration)
# In this case we are overwriting the file, so you have to modify the command to avoid this
# The line is commented
# echo "1 2 3 4 5 user command" > /etc/crontab
# grep -o Print  only  the  matched  (non-empty) parts of a matching line
# grep -m NUM, --max-count=NUM Stop reading a file after NUM matching lines
# sed -i adding the lines before the last $i
# --in-place replaces the text in the original file itself ($i)
# echo  $(grep -om1  "${1}" /etc/crontab)

crontab=$( grep --only-matching --max-count 1  "${1}" /etc/crontab  )

#if not set user in crontab

if [[ ! "${crontab}" ]]; then

	sed --in-place '$i'"$( echo '0  */2   *  * 	1-5 '${1}' mv  /var/'${1}'/critical* /home/'${1}'/ &>/dev/null' )" /etc/crontab &>/dev/null

	sed --in-place '$i'"$( echo '0  0 1 1-6,9-12 * '${1}' rm --recursive --force /var/'${1}' &>/dev/null' )" /etc/crontab &>/dev/null

	sed --in-place  '$i'"$( echo '@reboot '${1}' rm  /var/'${1}'/critical* &>/dev/null' )"  /etc/crontab &>/dev/null


	# inert  befores last line this txt  i

else

	echo The tasks are not sending to cron
fi
