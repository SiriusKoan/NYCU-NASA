#!/bin/sh

trap "echo Ctrl + C pressed.;exit 2" SIGINT;

check_status(){
	code=$?;
	if [ $code -eq 1 ]; then
		echo "Exit.";
		exit 0;
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

main_page() {
	choice=$(dialog --stdout --extra-button --extra-label "Setting" --title "System Info Pannel" --menu "Please select the command you want to use" 100 100 100 \
		"1" "POST ANNOUNCEMENT" \
		"2" "USER LIST")
			check_status;
			if [ $code -eq 3 ]; then
				setting_page;
			fi
			if [ $choice = "1" ]; then
				announcement_page;
			elif [ $choice = "2" ]; then
				user_list_page;
			fi
		}

	setting_page(){
		touch /tmp/.admin_status
		status=$(cat /tmp/.admin_status)
		if [ $status = "on" ]; then
			choice=$(dialog --stdout --title "SETTING" --yesno "TURN OFF?" 100 100;)
			code=$?
			if [ $code -eq 0 ]; then
				echo "off" > /tmp/.admin_status
				main_page
			elif [ $code -eq 1 ]; then
				main_page;
			elif [ $code -eq 255 ]; then
				echo "Esc pressed." >&2;
				exit 1
			fi
		else
			choice=$(dialog --stdout --title "SETTING" --yesno "TURN ON?" 100 100;)
			code=$?
			if [ $code -eq 0 ]; then
				echo "on" > /tmp/.admin_status
				touch /tmp/.admin_locked
				sudo `dirname "$0"`/ssh_admin &
				main_page
			elif [ $code -eq 1 ]; then
				main_page
			elif [ $code -eq 255 ]; then
				echo "Esc pressed." >&2;
				exit 1
			fi
		fi
	}

announcement_page() {
	users=$(cat /etc/passwd | awk -F: '/^[^#+]/{print $1}');
	for user in $users; do
		user_list="$user_list $(id -u $user) $user off "
	done
	user_list=$(dialog --stdout --title "POST ANNOUNCE" --extra-button --extra-label "ALL" --checklist "Please choose who you want to post" 100 100 100 $user_list)
	echo $user_list;
	code=$?;
	if [ $code -eq 0 ]; then
		POST_ALL=0;
		message_input_page;
	elif [ $code -eq 1 ]; then
		POST_ALL=0;
		main_page;
	elif [ $code -eq 3 ]; then
		POST_ALL=1;
		message_input_page;
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

message_input_page() {
	msg=$(dialog --stdout --title "Enter your messages!" --inputbox "Post an announcement" 100 100 "");
	code=$?;
	if [ $code -eq 0 ]; then
		if [ $POST_ALL -eq 1 ]; then
			user_list=$users;
			for user in $user_list; do
				ts=$(who | grep $user | awk '{print $2}');
				for t in $ts; do
					echo $msg > "/dev/$t";
				done
			done
		else
			user_list=$(echo $user_list | tr " " "\n");
			for user in $user_list; do
				ts=$(who | grep $(id -un $user) | awk '{print $2}');
				for t in $ts; do
					echo $msg > "/dev/$t";
				done
			done
		fi
	elif [ $code -eq 1 ]; then
		announcement_page;
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

user_list_page(){
	users=$(cat /etc/passwd | awk -F: '/^[^#+].*[^(nologin)]$/{print $1}');
	user_list="";
	for user in $users; do
		if echo "$(who)" | grep -q "$user"; then
			user_list="$user_list\n$(id -u $user) $user[*]";
		else
			user_list="$user_list\n$(id -u $user) $user";
		fi
	done
	user=$(dialog --stdout --ok-label "SELECT" --cancel-label "EXIT" --title "User Info Panel" --menu "" 100 100 100 $(echo -e $user_list | awk '{print $0}'));
	code=$?;
	if [ $code -eq 0 ]; then
		user_actions_page;
	elif [ $code -eq 1 ]; then
		main_page;
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

user_actions_page(){
	username=$(id -un $user);
	userinfo=$(sudo cat /etc/master.passwd | awk -F: -v username=$username '{if($1==username)print $0}');
	if echo $userinfo | grep -q "LOCKED"; then
		lock="UNLOCK IT";
	else
		lock="LOCK IT";
	fi
	choice=$(dialog --stdout --cancel-label "EXIT" --title "User $username" --menu "" 100 100 100 "1" "$lock" "2" "GROUP INFO" "3" "PORT INFO" "4" "LOGIN HISTORY" "5" "SUDO LOG");
	code=$?;
	if [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
	case $choice in
		"1") lock_user_page
			;;
		"2") group_info_page
			;;
		"3") ports_info_page
			;;
		"4") login_history_page
			;;
		"5") sudo_log_page
	esac
}

lock_user_page(){
	echo $lock;
	if [ "$lock" = "LOCK IT" ]; then
		dialog --stdout --title "LOCK IT" --yesno "Are you sure you want to do this?" 100 100;
		code=$?;
		if [ $code -eq 0 ]; then
			sudo pw lock $username;
			dialog --stdout --no-cancel --title "LOCK IT" --msgbox "LOCK SUCCEED!" 100 100;
			code=$?;
			if [ $code -eq 255 ]; then
				echo "Esc pressed." >&2;
				exit 1;
			fi
			user_actions_page;
		elif [ $code -eq 1 ]; then
			user_actions_page;
		elif [ $code -eq 255 ]; then
			echo "Esc pressed." >&2;
			exit 1;
		fi
	else
		dialog --stdout --title "UNLOCK IT" --yesno "Are you sure you want to do this?" 100 100;
		code=$?;
		if [ $code -eq 0 ]; then
			sudo pw unlock $username;
			dialog --stdout --nocancel --title "UNLOCK IT" --msgbox "UNLOCK SUCCEED!" 100 100;
			code=$?;
			if [ $code -eq 255 ]; then
				echo "Esc pressed." >&2;
				exit 1;
			fi
			user_actions_page;
		elif [ $code -eq 1 ]; then
			user_actions_page;
		elif [ $code -eq 255 ]; then
			echo "Esc pressed." >&2;
			exit 1;
		fi
	fi
}

group_info_page(){
	groups_info='GROUP_ID GROUP_NAME'"\n";
	groups_name="$groups_name $(id -Gn $username)";
	groups_id="$groups_id $(id -G $username)";
	i=1;
	for g in ${groups_name}; do
		groups_info="$groups_info$(echo $(id -G $username | cut -d' ' -f$i)) $(echo $(id -Gn $username | cut -d' ' -f$i))\n";
		i=$(expr $i + 1);
	done
	choice=$(dialog --stdout --extra-button --extra-label "EXPORT" --title "GROUP" --msgbox "$groups_info" 100 100);
	code=$?;
	if [ $code -eq 0 ]; then
		user_actions_page;
	elif [ $code -eq 3 ]; then
		export_page "groups";
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

ports_info_page(){
	socket_info=$(sockstat -4 -P tcp,udp | grep $username | awk '{print $3" "$5"_"$6}');
	socket_info="$socket_info";
	if [ -z "$socket_info" ]; then
		socket_info="NO PROCESS";
	fi
	pid=$(dialog --stdout --scrollbar --title "Port INFO(PID and Port)" --menu "" 100 100 100 ${socket_info});
	code=$?;
	if [ $code -eq 0 ]; then
		process_info=$(ps -p $pid -o user= -o pid= -o ppid= -o stat= -o %cpu= -o %mem= -o command= | tr -s ' ');
		process_info=$(echo $process_info | awk '{print "USER "$1"\nPID "$2"\nPPID "$3"\nSTAT "$4"\n%CPU "$5"\n%MEM "$6"\nCOMMAND "$7}');
		choice=$(dialog --stdout --no-cancel --extra-button --extra-label "EXPORT" --title "PROCESS STATE: $pid" --msgbox "$process_info" 100 100);
		code=$?;
		if [ $code -eq 0 ]; then
			ports_info_page;
		elif [ $code -eq 3 ]; then
			export_page "process";
		elif [ $code -eq 255 ]; then
			echo "Esc pressed." >&2;
			exit 1;
		fi
	elif [ $code -eq 1 ]; then
		user_actions_page;
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

login_history_page(){
	login_history=$(last $username | awk 'BEGIN{print "DATE IP"} /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $4" "$5" "$6" "$7" "$3}' | awk 'NR<=10');
	choice=$(dialog --stdout --nocancel --extra-button --extra-label "EXPORT" --title "LOGIN HISTORY" --msgbox "$login_history" 100 100);
	code=$?;
	if [ $code -eq 0 ]; then
		user_actions_page;
	elif [ $code -eq 3 ]; then
		export_page "login";
	elif [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}

sudo_log_page(){
	m=$(date -Idate | awk -F- '{print $2}')
	d=$(date -Idate | awk -F- '{print $3}')
	sudo_history=$(sudo cat /var/log/auth.log | awk -v username=$username -v m=$m -v d=$d 'BEGIN{month["Jan"]="01"; month["Feb"]="02"; month["Mar"]="03"; month["Apr"]="04"; month["May"]="05"; month["Jun"]="06"; month["Jul"]="07"; month["Aug"]="08"; month["Sep"]="09"; month["Oct"]="10"; month["Nov"]="11"; month["Dec"]="12";}
	{if($6==username){split($0,full,"COMMAND=");if (full[2] != ""){split(full[1],info," ");if(m==month[info[1]] || (m-month[info[1]]==1 && d<=info[2])){print info[6]" used sudo to do "full[2]" on "info[1]" "info[2]" "info[3]}}}}');
		choice=$(dialog --stdout --cr-wrap --nocancel --extra-button --extra-label "EXPORT" --title "SUDO LOG" --msgbox "$sudo_history" 90 70);
		code=$?;
		if [ $code -eq 0 ]; then
			user_actions_page;
		elif [ $code -eq 3 ]; then
			export_page "sudo";
		elif [ $code -eq 255 ]; then
			echo "Esc pressed." >&2;
			exit 1;
		fi
	}

export_page(){
	path=$(dialog --stdout --title "Export to file" --inputbox "Enter the path:" 100 100 "");
	code=$?;
	check=$(echo $path | awk '{if($0 ~ /^[\/^]/){print 1} else if($0 ~ /^~/){print 2} else{print 3}}')
	if [ $check -eq 2 ]; then
		path=$(echo $path | sed "s|~|$HOME|")
	elif [ $check -eq 3 ]; then
		path=$HOME"/"$path
	fi
	if [ $1 == "groups" ]; then
		if [ $code -eq 0 ]; then
			groups_info=$(echo $groups_info | tr ' ' '\t');
			echo -e "$groups_info" > $path;
			group_info_page;
		elif [ $code -eq 1 ]; then
			group_info_page;
		fi
	elif [ $1 == "process" ]; then
		if [ $code -eq 0 ]; then
			echo -e "$process_info" > $path;
			ports_info_page;
		elif [ $code -eq 1 ]; then
			ports_info_page;
		fi
	elif [ $1 == "login" ]; then
		if [ $code -eq 0 ]; then
			echo -e "$login_history" > $path;
			login_history_page;
		elif [ $code -eq 1 ]; then
			login_history_page;
		fi
	elif [ $1 == "sudo" ]; then
		if [ $code -eq 0 ]; then
			echo -e "$sudo_history" > $path;
			sudo_log_page;
		elif [ $code -eq 1 ]; then
			sudo_log_page;
		fi
	fi
	if [ $code -eq 255 ]; then
		echo "Esc pressed." >&2;
		exit 1;
	fi
}


username=$(whoami);
sudo pw usermod $username -G tty;
main_page;

