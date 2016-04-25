
#!/bin/bash

#########################

#               Script creado para       #

#                     backup             #

#              Base de datos mysql       #

#########################

# Incluyendo configuración
DIRECTORY_PATH=`readlink -f $(dirname $0)`
source "${DIRECTORY_PATH}/config.sh"
DISTRO=''

echo
echo "user: $SESSION_USER path: $SESSION_USER_PATH"

install_backup_auto(){

	read -p "Está de acuerdo en configurar respaldo automatico de base de datos [y/n] ? "
	if [[ "$REPLY" != "y" && "$REPLY" != "Y" ]] ; then
		return 1
	fi
	echo
	echo "Buscando Script de base de datos a respaldar..."
	echo

	# Cantidad de tarea para agregar a crontab
	length_crontab_time=${#CRONTAB_TIME[@]}

	for i in $(find ${DIRECTORY_PATH} -name 'bkp.sh' 2> /dev/null); do
		if [[ -f $i ]]; then
			echo "Aplicando permisos[$i]..."
			chmod u+x "${i}" && echo -e "...Ok.\n"

			CRONTAB_FILE="${SESSION_USER_PATH}/crontab_backups"
			if [[ -f "$CRONTAB_FILE" ]]; then
				mv "${CRONTAB_FILE}" "$CRONTAB_FILE.old"
			fi
			# Agregar tareas a crontab
			for (( z = 0; z < $length_crontab_time; z++ )); do
				# CRONTAB_LINE="${CRONTAB_TIME[$z]} ${SESSION_USER} bash ${i}"
				CRONTAB_LINE="${CRONTAB_TIME[$z]} bash ${i}"


				if grep -rl "$CRONTAB_LINE" ${CRONTAB_FILE}; then
				    echo "Existe una configuración previa de crontab. [$CRONTAB_FILE]."
				    crontab -l
				else
					echo "Integrando [${CRONTAB_LINE}] en [${CRONTAB_FILE}] ... "
					echo "${CRONTAB_LINE}" >> "${CRONTAB_FILE}"
					echo -e "...Ok.\n"

					crontab -u $SESSION_USER "${CRONTAB_FILE}"
				fi
			done

			read -p "Está de acuerdo ejecutar test de prueba [y/n] ? "
			if [[ "$REPLY" == "y" || "$REPLY" == "Y" ]] ; then
				echo
				echo "Ejecutando test de prueba de respaldo de base de datos."
				source "${i}"
			fi

			echo
			echo "Finalizado."
			echo
		fi
	done
}

install_gnome_schedule(){
	read -p "Está de acuerdo instalar Gnome Schedule [y/n] ? "
	if [[ "$REPLY" != "y" && "$REPLY" != "Y" ]] ; then
		return 1
	fi
	echo
	echo "Preparando instalación..."
	echo

	echo "Instalando gnome-schedule ..."
	sudo apt-get install gnome-schedule && echo -e "...Ok.\n"

	echo "Iniciando gnome-schedule."
	/usr/bin/gnome-schedule

	echo
	echo "Finalizado."
	echo
}

config_shutdown(){
	read -p "Está de acuerdo programar apagando automatico a través de crontab [y/n] ? "
	if [[ "$REPLY" != "y" && "$REPLY" != "Y" ]] ; then
		return 1
	fi

	echo
	echo "Hora de apagar el servidor?"
	echo -n "[$CRONTAB_SHUTDOWN]"
	read IN_CRONTAB_SHUTDOWN

	if [[ -z "$IN_CRONTAB_SHUTDOWN" ]]; then
		IN_CRONTAB_SHUTDOWN="$CRONTAB_SHUTDOWN"
	fi

	echo "$IN_CRONTAB_SHUTDOWN  /sbin/shutdown now -h" >> ~/crontab_shutdown

	if [[ "${DISTRO}" == "Ubuntu" ]]; then
		sudo crontab -u root ~/crontab_shutdown
	else
		crontab -u root ~/crontab_shutdown
	fi

	echo
	echo "Finalizado."
	echo
}

distro() {
	if [ -f /etc/lsb-release ]; then
	    . /etc/lsb-release
	    DISTRO=$DISTRIB_ID
	elif [ -f /etc/debian_version ]; then
	    DISTRO=Debian
	    # XXX or Ubuntu
	elif [ -f /etc/redhat-release ]; then
	    DISTRO="Red Hat"
	    # XXX or CentOS or Fedora
	else
	    DISTRO=$(uname -s)
	fi

	return 0
}

distro

MENU=()
cb_menu(){
	local array_menu=( $@ )
	MENU[${#MENU[@]}]=${array_menu[@]}
	return 0
}

cb_menu "Configurar respaldo automatico  base de datos mysql" "install_backup_auto"
cb_menu "Configurar apagando automatico de servidor" "config_shutdown"
cb_menu "Instalar Gnome Schedule(Aplicación para configurar respaldo.)" "install_gnome_schedule"
cb_menu "Salir/atajo (Ctrl-C)" "break"

menu_length=${#MENU[@]}
while true; do
	echo -e "\n- Menú de instalación (Seleccione una opción):"
	for (( i = 0; i < $menu_length; i++ )); do
		OTRO=( ${MENU[$i]} )
		count=$(expr ${#OTRO[@]} - 1)
		echo "[$i]: ${MENU[$i]//${OTRO[$count]}}"
	done
	read choose
	if [[ $choose -ge 0 ]] && [[ $choose -lt $menu_length ]]; then
		OTRO=( ${MENU[$choose]} )
		count=$(expr ${#OTRO[@]} - 1)
		if [[ `echo ${OTRO[$count]}` == "break" ]]; then
			echo -e "------------- Finalizando menú ------------\n"
			${OTRO[$count]}
		else
			${OTRO[$count]}
			echo -e "------------ Retornando al menú ----------\n"
		fi
	else
		echo -e "------------------------------------------"
		echo -e "-- Ops! Recuerda seleccionar una opción --"
		echo -e "------------ Retornando al menú ----------\n"
	fi
done


echo
echo "Finalizado."
echo
