
RESPALDO BASE DE DATOS MYSQL

EL DIRECTORIO DE BACKUPS DEBE ESTAR LOCALIZADO EN HOME DEL USUARIO

ASIGNAR PERMISOS DE EJECUSION

chmod u+x -R ~/backups

PARA PROGRAMAR E INSTALAR RESPALDO AUTOMATICO EJECUTA EL ARCHIVO

	bash install.sh
OR
	./install.sh
OR
	cd backups && bash install.sh


PARA EJECUTAR BACKUPS DE FORMA MANUAL EJECUTAR EL ARCHIVO
	bash bkp.sh
OR
	./bkp.sh
OR
	cd backups && bash bkp.sh

OR
	cd backups && bash bkp.sh nombre_de_directorio_de_base_de_datos

OPCIONES DE FICHEROS
~/backups
~/backups/database
	- SE ALMACENA ARCHIVO DE TODA LAS BASE DE DATOS A RESPALDAR
	- CADA ARCHIVO DEBE ESPECIFICAR VARIABLES DE CONECCION A BASE DE DATOS MYSQL
		* DATABASE_HOST="localhost"
		* DATABASE_PORT=""
		* DATABASE_NAME="nombredebasededatos"
		* DATABASE_USER="usuario"
		* DATABASE_PASSWORD="clave"
	- PARA AGREGAR UNA NUEVA BASE DE DATOS A RESPALDAR, CREAR UN NUEVO ACHIVO CON EXTENSION SH
		* EJEMPLO nombredebasededatos.sh
		* CONTENIDO
			#!/bin/bash

			#########################

			#               Script creado para       #

			#                     backup             #

			#              Base de datos mysql       #

			#########################

			# VARIABLES

			DATABASE_HOST="localhost"
			DATABASE_PORT=""
			DATABASE_NAME="nombredebasededatos"
			DATABASE_USER="usuario"
			DATABASE_PASSWORD="clave"


~/backups/database/config.sh
	- ARCHIVO DE CONFIGURACIÓN
		* BKP_DIR="/home/usuario/rutaderespaldo"
		* CRONTAB_TIME=("50 8 * * *" "20 16 * * *") #8:50AM, 16:20PM
		#CRONTAB_TIME (TUPLA PARA ESTABLECER EL TIEMP0 DE EJECUCION )


SCRIPT DESARROLLADO POR: EFRAIN BONILLA
CORREO: efrainbonilla.dev@gmail.com
