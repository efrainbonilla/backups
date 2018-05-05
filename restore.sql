
#!/bin/bash

# Incluyendo configuración
DIRECTORY_PATH=`readlink -f $(dirname $0)`
source "${DIRECTORY_PATH}/config.sh"

echo
echo "Creando directorio de almacenamiento para respaldo de base de datos."
echo
mkdir -p "$BKP_DIR"
chmod 777 -R "$BKP_DIR"

COMPRESS_FILES=""

GROUP_DB="default"
GROUP_IF="$GROUP_DB"

cd "${DIRECTORY_PATH}/database/restore"

while [ $# -gt 0 ] ; do
	for a in $(ls -d */); do
		a=$(basename $a)
		if [[ "$a" == "$1" ]]; then
			GROUP_IF="$a"
		fi
	done
	if [[ "$GROUP_DB" != "$GROUP_IF" ]]; then
		GROUP_DB=$GROUP_IF
	else
		echo "Error: importación para $1 no esta permitido."
		exit 0
	fi
    shift
done

v1=$(date "+%Y-%m-%d")
v2=$(date "+%Y-%m-%d")
for i in $(find ${DIRECTORY_PATH}/database/restore/$GROUP_DB -name '*.sh' 2> /dev/null); do
	if [[ -f $i && $(basename $i) != "bkp.sh" ]]; then
		unset DATABASE_DRIVER
		unset DATABASE_HOST
		unset DATABASE_NAME
		unset DATABASE_USER
		unset DATABASE_PASSWORD
		echo
		echo "Importando script [$i]..."
		source "${i}"

		echo "driver: ${DATABASE_DRIVER}, host: ${DATABASE_HOST}, user: ${DATABASE_USER}, password: ${DATABASE_PASSWORD}, database: $DATABASE_NAME"

		if [[ -z "$DATABASE_DRIVER" || -z "$DATABASE_HOST" || -z "$DATABASE_NAME" || -z "$DATABASE_USER" || -z "$DATABASE_PASSWORD"  ]]; then
			echo "Parametros incompletos retornando sin acción de respaldo."
			echo
			continue
		fi

		echo

		if [[ "${DATABASE_DRIVER}" == 'pgsql' ]]; then
			DATABASE_NAME_SQLDATA_PATH="${DATABASE_NAME}_${v1}"

			DATABASE_NAME="${DATABASE_NAME}_${v2}"

			echo
			echo "path sqldata ${DATABASE_NAME_SQLDATA_PATH}"
			echo "database: ${DATABASE_NAME}"
			echo

			echo $(dirname ${BKP_DIR})

			for i in $(find $(dirname ${BKP_DIR}) -maxdepth 1 -name '.sql' 2> /dev/null); do
				echo "${i}"
			done
			#for i in $(find /etc/apache2/conf.d -name 'phppgadmin' 2> /dev/null); do


			# su ${DATABASE_USER}

			#  echo "Creando base de datos: ${DATABASE_NAME}"
			# PGPASSWORD="${DATABASE_PASSWORD}" psql -tc "SELECT 1 FROM pg_database WHERE datname = '${DATABASE_NAME}'" -U ${DATABASE_USER} -d postgres -p 5432 -h ${DATABASE_HOST}  | grep -q 1 || PGPASSWORD="${DATABASE_PASSWORD}" psql -c "CREATE DATABASE ${DATABASE_NAME}" -U ${DATABASE_USER} -d postgres -p 5432 -h ${DATABASE_HOST}
			# #PGPASSWORD="s3n4p1" psql -tc "SELECT 1 FROM pg_database WHERE datname = 'dbsenapiweb_prueba4'" -U senapi -d postgres -p 5432 -h 10.0.139.27  | grep -q 1 || PGPASSWORD="s3n4p1" psql -c "CREATE DATABASE dbsenapiweb_prueba4" -U senapi -d postgres -p 5432 -h 10.0.139.27

			# echo "Iniciando importación base de datos [${DATABASE_NAME}] desde [${DATABASE_NAME_SQLDATA_PATH}]..."
			# PGPASSWORD="${DATABASE_PASSWORD}" psql -U ${DATABASE_USER} -d ${DATABASE_NAME} -p 5432 -h ${DATABASE_HOST} < ${DATABASE_NAME_SQLDATA_PATH} && echo -e "...Ok.\n"
			# echo "Respaldo terminado."
			# echo
		elif [[ "${DATABASE_DRIVER}" == 'mysql' ]]; then

			#pendiente
			echo "no soportado."
		else
			echo "Error, driver incorrecto."
		fi
	fi
done


# echo "BACKUPS ${data} SESSION_PATH:${SESSION_USER_PATH} BACKUP_PATH: $BKP_DIR" >> "${SESSION_USER_PATH}/restore.log"
echo
echo "Importación finalizado."
echo
exit 0