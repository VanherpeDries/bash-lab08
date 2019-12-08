#!/bin/bash 


BACKUPTIME=`date +%b-%d-%y_%H-%M-%S` #get the current date
encrypt=false
name=$(hostname)
dest=$(pwd)
SOURCEFOLDER=$PATH

deleteOldBackups(){
    find $dest -name "*.gpg" -type f -mtime +1 -exec rm -f {} \;
    find $dest -name "*.gz" -type f -mtime +1 -exec rm -f {} \;
    find $dest  -name "*.tar" -type f -mtime +1 -exec rm -f {} \;
    find $dest  -name "*.bzip" -type f -mtime +1 -exec rm -f {} \;
}
makeBackup(){
    if [[ $compress = "tar" ]]; then 
        DESTINATION="$DESTINATION".tar
        tar -cpf $DESTINATION -C $SOURCEFOLDER .
    elif [[ $compress = "bz2" ]]; then
        DESTINATION="$DESTINATION".tar.bz2
        tar -cpjf $DESTINATION -C $SOURCEFOLDER .
        DESTINATION="$DESTINATION".tar.gz
        tar -cpzf $DESTINATION -C $SOURCEFOLDER . 
    fi
    encryptFile
}
encryptFile() {
  if [[ $encrypt ]]; then 
        gpg -c --passphrase password --batch $DESTINATION
        rm $DESTINATION
  fi
}


while getopts ed:s:n:c: options; do 
    case "${options}" in 
    n)
        name="${OPTARG}"
        ;;
    d)
        
        dest="${OPTARG}"
        ;;
    e)
        encrypt=true
        ;;
    c)
        compress="${OPTARG}"
        ;;
    s)  
        SOURCEFOLDER="${OPTARG}"
        ;;
    esac
done



DESTINATION="$dest/$name-$BACKUPTIME"
deleteOldBackups
makeBackup
0 10 * * * /bin/bash $(pwd)/backup.sh
exit 0
    

