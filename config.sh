#!/bin/bash

# DIRECTORIO DE EJECUCIÓN DEL SCRIPT ACTUAL
DIRECTORY_PATH=`readlink -f $(dirname $0)`

# NOMBRE DE USUARIO AUTENTICADO
dp=`echo $DISPLAY | cut -d '.' -f 1`
SESSION_USER=`who | grep $dp | cut -d ' ' -f 1 | tail -1`

# DIRECTORIO HOME DE USUARIO AUTENTICADO
SESSION_USER_PATH="$HOME"
# $(dirname $XAUTHORITY)

#DATOS PARA RESPALDAR (AÑO MES DIA HORA MINUTO SEGUNDO)
data=$(date "+%Y-%m-%d_%H:%M:%S")
date_time_compress_source=$(date "+%Y-%m-%d_%H-%M-%S")
date_year=$(date "+%Y")
date_month=$(date "+%m")
date_day=$(date "+%d")

# DB GLOBAL
GLOBAL_DB_PASSWORD="123456"


# DIRECTORIO DE RESPALDO
# BKP_DIR="${SESSION_USER_PATH}/sqldata/${date_year}/${date_month}/${date_day}/${data}"
BKP_DIR="/media/datos/sistemas/www/sicap/sicapDatabase/${date_year}/${date_month}/${date_day}/${data}"
#BKP_DIR="/media/datos/sqldata"


# TIEMPO CRONTAB PARA RESPALDO
# CRONTAB_TIME=("50 8 * * *" "20 16 * * *") #8:50AM, 16:20PM
CRONTAB_TIME=("59 9 * * *" "30 16 * * *") #9:59AM, 12:59PM
#CRONTAB_TIME=("*/2 * * * *") #cada 2 minutos
# TODOS [*]
# MINUTO [0-59]
# HORA [0-23]
# DIA [1-31]
#  m  h  d  m  (dia de la semana)
#  50 8  *  *  *  usuario bash /home/usuario/backups/bkp.sh
#  20 16 *  *  *  usuario bash /home/usuario/backups/bkp.sh

notify() {
  local title="$1"
  local message="$2"

  if [ $(which zenity 2>/dev/null) ]; then
    zenity --info --title "$title" --text "$message"
  elif [ $(which notify-send 2>/dev/null) ]; then
    notify-send "$title" "$message"
  elif [ $(which kdialog 2>/dev/null) ]; then
    kdialog --title "$title" --passivepopup "$message"
  else
    echo -e "$0: [$title] $message" >&2
  fi
}


# SHUTDOWN
CRONTAB_SHUTDOWN="30 18 * * *"