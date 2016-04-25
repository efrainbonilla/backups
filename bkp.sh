
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
MYSQL_WORKBENCH_DUMP=mysqldump
MYSQL_WORKBENCH_DIR=/usr/lib/mysql-workbench

if [[ ! -d "$MYSQL_WORKBENCH_DIR" ]]; then
	FOUND=1
elif [[ ! -f $(find "$MYSQL_WORKBENCH_DIR" -name "$MYSQL_WORKBENCH_DUMP") ]]; then
	FOUND=1
fi

if [[ $FOUND -eq 1 ]]; then
	MYSQL_DUMP=mysqldump
else
	MYSQL_DUMP=${MYSQL_WORKBENCH_DIR}/${MYSQL_WORKBENCH_DUMP}
fi


GROUP_DB="default"
GROUP_IF="$GROUP_DB"

cd "${DIRECTORY_PATH}/database"

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
		echo "Error: el respaldo para $1 no esta permitido."
		exit 0
	fi
    shift
done

for i in $(find ${DIRECTORY_PATH}/database/$GROUP_DB -name '*.sh' 2> /dev/null); do
	if [[ -f $i && $(basename $i) != "bkp.sh" ]]; then
		echo
		echo "Incluyendo script [$i]..."
		source "${i}" && echo -e "...Ok.\n"
		echo
		echo "host: ${DATABASE_HOST}, user: ${DATABASE_USER}, password: ${DATABASE_PASSWORD}, database: $DATABASE_NAME"
		echo

		echo "Iniciando respaldo base de datos [${DATABASE_NAME}] en [${BKP_DIR}/${DATABASE_NAME}_${data}.sql]..."

		if [[ $FOUND -eq 1 ]]; then
			${MYSQL_DUMP} --max_allowed_packet=1G --host=$DATABASE_HOST --user=$DATABASE_USER --password=$DATABASE_PASSWORD --complete-insert=TRUE --port=3306 --default-character-set=utf8 --routines --events --databases $DATABASE_NAME > "${BKP_DIR}/${DATABASE_NAME}_${data}.sql"  && echo -e "...Ok.\n"
		else
			${MYSQL_DUMP} --host=$DATABASE_HOST --user=$DATABASE_USER --password=$DATABASE_PASSWORD --databases $DATABASE_NAME > "${BKP_DIR}/${DATABASE_NAME}_${data}.sql"  && echo -e "...Ok.\n" #PUEDE USAR '--all-databases' DESPUÉS
		fi
	fi
done


temp=$(mktemp -d)
BACKUPS_SOURCE="${date_time_compress_source}_${GROUP_DB}.tar.gz"
BKPCOMPRESS_PATH=$(dirname ${BKP_DIR})
BKPCOMPRESS_DIR=$(basename ${BKP_DIR})
cd "${BKPCOMPRESS_PATH}"

# comprimir paquetes
echo "Empaquetando directorio [$BKPCOMPRESS_DIR]..."
tar -czf "${temp}/${BACKUPS_SOURCE}" "$BKPCOMPRESS_DIR"


# mover a directorio de respaldo
echo "Respaldo guardado en: [${BKPCOMPRESS_PATH}]..."
mv "${temp}/${BACKUPS_SOURCE}" "${BKPCOMPRESS_PATH}" && echo -e "Ok.\n"

echo "Asignando permiso 777..."
chmod 777 -R "${BKPCOMPRESS_PATH}/${BACKUPS_SOURCE}" && echo -e "Ok.\n"


rm -rf "${BKP_DIR}"

echo "Compresión finalizado."

echo "BACKUPS ${data} SESSION_PATH:${SESSION_USER_PATH} BACKUP_PATH: $BKP_DIR" >> "${SESSION_USER_PATH}/bkp.log"
echo
echo "Respaldo finalizado."
echo
exit 0