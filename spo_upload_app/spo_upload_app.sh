#!/bin/bash
#
# v1.0

# EXIT PARAMETER (BE CAUTIOUS WITH THE LOCK FILE)
## EXIT ON ERRORS
#set -e
## DO NOT EXIT ON ERRORS
set +e

# VARIABLES
## AZURE ACTIVE DIRECTORY PARAMETERS
AAD_USERNAME="example@contoso.com"
AAD_PASSWORD="password"
## SHAREPOINT ONLINE PARAMETERS
SPO_ENDPOINT="contoso.sharepoint.com"
SPO_DOCUMENT_LIBRAY="Billing Library"
## SENDMAIL PARAMETERS
SENDMAIL_ERROR_FROM_NAME="CentOS APPS.MACHINE"
SENDMAIL_ERROR_FROM_EMAIL="centos.apps.machine@contosogroup.com"
SENDMAIL_ERROR_TO_EMAIL="itss@contosogroup.com"
SENDMAIL_ERROR_SUBJECT="Error from spo_upload_app.sh on $(hostname)"
## DELETE LOCAL FILES
DELETE_LOCAL_FILE="true"
#DELETE_LOCAL_FILE="false"
## STATIC FOLDERS
BASE_FOLDER="/home/harvest_apps/spo_upload_app"
SAML_FOLDER="${BASE_FOLDER}/saml"
RUN_FOLDER="${BASE_FOLDER}/run"
ARCHIVE_FOLDER="/home/harvest_apps/clients"
## WORK FOLDERS
LOGS_FOLDER="${BASE_FOLDER}/logs"
TMP_FOLDER="${BASE_FOLDER}/tmp"
## STATIC FILES
REQUEST_SECURITY_TOKEN_XML_FILE="${SAML_FOLDER}/request_security_token.xml"
TIMESTAMP_REF_FILE="${RUN_FOLDER}/timestamp.ref"
## WORK FILES
NEW_TIMESTAMP_REF_FILE="${TMP_FOLDER}/new_timestamp.ref"
SECURITY_TOKEN_RESPONSE_TXT_FILE="${TMP_FOLDER}/security_token_response.txt"
COOKIES_TXT_FILE="${TMP_FOLDER}/cookies.txt"
COOKIES_RESPONSE_TXT_FILE="${TMP_FOLDER}/cookies_response.txt"
FORM_DIGEST_RESPONSE_TXT_FILE="${TMP_FOLDER}/form_digest_response.txt"
FILES_TO_UPLOAD_TXT_FILE="${TMP_FOLDER}/files_to_upload.txt"
FILE_UPLOAD_RESPONSE_TXT_FILE="${TMP_FOLDER}/file_upload_response.txt"
### LOG FILE
LOG_FILE="${LOGS_FOLDER}/$(date +%Y%m%d)_spo_upload_app.log"
#### LOG FILE RETENTION
LOG_FILE_RETENTION="30"
## LOCK FILE
LOCK_FILE="${BASE_FOLDER}/spo_upload_app.lock"

# CHECK STATIC FOLDERS
if [ ! -d "${BASE_FOLDER}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${BASE_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

if [ ! -d "${SAML_FOLDER}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${SAML_FOLDER}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${SAML_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

if [ ! -d "${RUN_FOLDER}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${RUN_FOLDER}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${RUN_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

if [ ! -d "${ARCHIVE_FOLDER}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${ARCHIVE_FOLDER}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${ARCHIVE_FOLDER}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

# CHECK STATIC FILES
if [ ! -s "${REQUEST_SECURITY_TOKEN_XML_FILE}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${REQUEST_SECURITY_TOKEN_XML_FILE}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${REQUEST_SECURITY_TOKEN_XML_FILE}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

if [ ! -f "${TIMESTAMP_REF_FILE}" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${TIMESTAMP_REF_FILE}', EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] COULD NOT FIND '${TIMESTAMP_REF_FILE}', EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
fi

# CHECK LOCK FILE
if [ ! -f "${LOCK_FILE}" ]; then
		touch "${LOCK_FILE}"
elif [ "$(pgrep "${0##*/}" | wc -l)" -eq "0" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" 1>&2
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] FOUND '${LOCK_FILE}' BUT NO PROCESS RUNNING, EXITING" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		exit 1
else
		exit 0
fi

# CHECK WORK FOLDERS
if [ ! -d "${LOGS_FOLDER}" ]; then
		mkdir "${LOGS_FOLDER}"
else
		find "${LOGS_FOLDER}" -name "*.log" -mtime "+${LOG_FILE_RETENTION}" -exec rm {} \;
fi

if [ ! -d "${TMP_FOLDER}" ]; then
		mkdir "${TMP_FOLDER}"
else
		rm -R "${TMP_FOLDER}"
		mkdir "${TMP_FOLDER}"
fi

{ #START

# TOUCH NEW TIMESTAMP REF FILE
touch "${NEW_TIMESTAMP_REF_FILE}"

# RETRIEVE FILES TO UPLOAD
find "${ARCHIVE_FOLDER}" -name "*" -type "f" -newer "${TIMESTAMP_REF_FILE}" > "${FILES_TO_UPLOAD_TXT_FILE}"

# CHECK NUMBER OF FILES TO UPLOAD RETRIEVED
FILES_TO_UPLOAD_MATCHES="$(wc -l "${FILES_TO_UPLOAD_TXT_FILE}" | awk '{ print $1 }')"

if [ "${FILES_TO_UPLOAD_MATCHES}" -gt "0" ]; then
	
	# SHOW NUMBER OF FILES TO UPLOAD RETRIEVED
	echo "[$(date +%Y-%m-%d+%H:%M:%S)] '${FILES_TO_UPLOAD_MATCHES}' FILES TO UPLOAD RETRIEVED" | tee -a "${LOG_FILE}"
	
	# LOGON TO AAD AND RETRIEVE SECURITY TOKEN
	curl -X "POST" "https://login.microsoftonline.com/extSTS.srf" -S -s \
	-d "$( \
		sed -e "s/\[username\]/${AAD_USERNAME}/g" \
		-e "s/\[password\]/${AAD_PASSWORD}/g" \
		-e "s/\[endpoint\]/https:\/\/${SPO_ENDPOINT}/g" \
		"${REQUEST_SECURITY_TOKEN_XML_FILE}" \
		)" \
	-D - \
	> "${SECURITY_TOKEN_RESPONSE_TXT_FILE}"
	
	# CHECK SECURITY TOKEN RESPONSE
	if [ "$(grep "HTTP/1.1 200 OK" "${SECURITY_TOKEN_RESPONSE_TXT_FILE}" | wc -l)" -gt "0" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (OK) RETRIEVE SECURITY TOKEN" | tee -a "${LOG_FILE}"
	else
		# SEND ERROR, REMOVE LOCK FILE AND EXIT
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) RETRIEVE SECURITY TOKEN" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		rm "${LOCK_FILE}"
		exit 1
	fi
	
	# EXTRACT SECURITY TOKEN
	SECURITY_TOKEN="$( \
		grep "BinarySecurityToken" "${SECURITY_TOKEN_RESPONSE_TXT_FILE}" | \
		sed -e "s/.*<wsse\:BinarySecurityToken Id\=\"Compact0\">\(.*\)<\/wsse\:BinarySecurityToken>.*/\1/g" \
		)"
	
	# DELETE SECURITY TOKEN RESPONSE
	rm "${SECURITY_TOKEN_RESPONSE_TXT_FILE}"
	
	# RETRIEVE COOKIES
	curl -H "Host: ${SPO_ENDPOINT}" \
	-H "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)" \
	-H "Content-Length: ${#SECURITY_TOKEN}" \
	"https://${SPO_ENDPOINT}/_forms/default.aspx?wa=wsignin1.0" -S -s \
	-c "${COOKIES_TXT_FILE}" \
	-d "${SECURITY_TOKEN}" \
	-D - \
	> "${COOKIES_RESPONSE_TXT_FILE}"
	
	# CHECK COOKIES RESPONSE
	if [ "$(grep "HTTP/1.1 302 Found" "${COOKIES_RESPONSE_TXT_FILE}" | wc -l)" -gt "0" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (OK) RETRIEVE COOKIES" | tee -a "${LOG_FILE}"
	else
		# SEND ERROR, REMOVE LOCK FILE AND EXIT
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) RETRIEVE COOKIES" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		rm "${LOCK_FILE}"
		exit 1
	fi
	
	# RETRIEVE FORM DIGEST
	curl -X "POST" "https://${SPO_ENDPOINT}/_api/contextinfo" -S -s \
	-b "${COOKIES_TXT_FILE}" \
	-d "" \
	-D - \
	> "${FORM_DIGEST_RESPONSE_TXT_FILE}"
	
	# CHECK FORM DIGEST RESPONSE
	if [ "$(grep "HTTP/1.1 200 OK" "${FORM_DIGEST_RESPONSE_TXT_FILE}" | wc -l)" -gt "0" ]; then
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (OK) RETRIEVE FORM DIGEST" | tee -a "${LOG_FILE}"
	else
		# SEND ERROR, REMOVE LOCK FILE AND EXIT
		echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) RETRIEVE FORM DIGEST" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
		rm "${LOCK_FILE}"
		exit 1
	fi
	
	# EXTRACT FORM DIGEST
	FORM_DIGEST="$( \
		grep "FormDigestValue" "${FORM_DIGEST_RESPONSE_TXT_FILE}" | \
		sed -e "s/.*<d\:FormDigestValue>\(.*\)<\/d\:FormDigestValue>.*/\1/g" \
		)"
	
	# DELETE FORM DIGEST RESPONSE
	rm "${FORM_DIGEST_RESPONSE_TXT_FILE}"
	
	# UPLOAD FILES
	while read UPLOAD_FILE; do
		
		curl -H "Host: ${SPO_ENDPOINT}" \
		-H "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)" \
		-H "X-RequestDigest: ${FORM_DIGEST}" \
		-H "Content-Type: application/json;odata=verbose" \
		-H "Content-Length: $(wc -c "${UPLOAD_FILE}" | awk '{ print $1 }')" \
		-H "BinaryStringRequestBody: true" \
		-X "POST" "https://${SPO_ENDPOINT}/_api/web/GetFolderByServerRelativeUrl('/${SPO_DOCUMENT_LIBRAY//[ ]/%20}$( \
			dirname "${UPLOAD_FILE}" | \
			sed -e "s/${ARCHIVE_FOLDER//\//\/}//g" \
			-e "s/[ ]/%20/g" \
			)')/Files/add(url='$( \
			basename "${UPLOAD_FILE}" | \
			sed -e "s/[ ]/%20/g" \
			-e "s/[\']//g" \
			)',overwrite=true)" -S -s \
		-b "${COOKIES_TXT_FILE}" \
		--data-binary "@${UPLOAD_FILE}" \
		-D - \
		> "${FILE_UPLOAD_RESPONSE_TXT_FILE}"
		
		# CHECK FILE UPLOAD RESPONSE
		if [ "$(grep "HTTP/1.1 200 OK" "${FILE_UPLOAD_RESPONSE_TXT_FILE}" | wc -l)" -gt "0" ]; then
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] (OK) UPLOAD FILE '$(basename "${UPLOAD_FILE}")'" | tee -a "${LOG_FILE}"
			
			# CHECK IF LOCAL FILE SHOULD BE DELETED
			if [ "${DELETE_LOCAL_FILE}" -eq "true" ]; then
				echo "[$(date +%Y-%m-%d+%H:%M:%S)] DELETING LOCAL FILE '$(basename "${UPLOAD_FILE}")'" | tee -a "${LOG_FILE}"
				rm "${UPLOAD_FILE}"
			fi
			
		else
			# SEND ERROR, REMOVE LOCK FILE AND EXIT
			echo "[$(date +%Y-%m-%d+%H:%M:%S)] (ERROR) UPLOAD FILE '$(basename "${UPLOAD_FILE}")'" | tee -a "${LOG_FILE}" | xargs -I % -0 echo -e "To: <${SENDMAIL_ERROR_TO_EMAIL}>\nFrom: ${SENDMAIL_ERROR_FROM_NAME} <${SENDMAIL_ERROR_FROM_EMAIL}>\nSubject: ${SENDMAIL_ERROR_SUBJECT}\nMIME-Version: 1.0\nContent-Type: text/plain\n\n%\n\n" | sendmail -t
			rm "${LOCK_FILE}"
			exit 1
		fi
		
	done < "${FILES_TO_UPLOAD_TXT_FILE}"
	
	# UPDATE TIMESTAMP REF FILE
	mv "${NEW_TIMESTAMP_REF_FILE}" "${TIMESTAMP_REF_FILE}"
	
fi

# CLEAN TMP FOLDER
rm -R "${TMP_FOLDER}"

} 2>> "${LOG_FILE}" #END

# CLEAN LOG FILE (^M SHOULD BE DONE THROUGH VI USING CTRL-SHIFT-V CTRL-SHIFT-M)
sed -i 's/^M/\
/g' "${LOG_FILE}"

# REMOVE LOCK FILE AND EXIT
rm "${LOCK_FILE}"
exit 0