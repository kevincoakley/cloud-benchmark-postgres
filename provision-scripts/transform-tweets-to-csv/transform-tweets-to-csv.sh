#!/bin/bash

OS_PASSWORD=$1
FILE_LIST=$2
DOWNLOAD_CONTAINER=$3
UPLOAD_CONTAINER=$4

echo "Setting OpenStack password"
export OS_PASSWORD=$OS_PASSWORD

echo "Downloading OpenStack openrc file"
/usr/bin/curl -s https://raw.githubusercontent.com/kevincoakley/cloud-benchmark-postgres/master/files/klc-openrc.sh > /mnt/disk-workspace/openrc.sh

echo "Sourcing the OpenStack openrc file"
source /mnt/disk-workspace/openrc.sh

echo "Downloading transform-tweets-to-csv.py"
/usr/bin/curl -s https://raw.githubusercontent.com/kevincoakley/cloud-benchmark-postgres/master/provision-scripts/transform-tweets-to-csv/transform-tweets-to-csv.py > /mnt/disk-workspace/transform-tweets-to-csv.py

echo "Download the import file list: $FILE_LIST"
/usr/bin/curl -s $FILE_LIST > /mnt/disk-workspace/file-list.txt

echo "Making tmp ram disk directory"
mkdir /mnt/ram-workspace/tmp/

echo "Reading $FILE_LIST"
while read file; do
  DOWNLOAD_FILE=${file//\//_}

  /bin/date >> /mnt/disk-workspace/transform.log

  if [ -e /mnt/ram-workspace/$DOWNLOAD_FILE ]
    then
      echo "$DOWNLOAD_FILE exists; skipping"
      echo "$DOWNLOAD_FILE exists; skipping" >> /mnt/disk-workspace/transform.log
    else
      echo "$DOWNLOAD_FILE does not exist; processing"
      echo "$DOWNLOAD_FILE does not exist; processing" >> /mnt/disk-workspace/transform.log

      echo "Downloading $DOWNLOAD_FILE"
      echo "Downloading $DOWNLOAD_FILE" >> /mnt/disk-workspace/transform.log
      /usr/bin/swift download -o /mnt/ram-workspace/$DOWNLOAD_FILE $DOWNLOAD_CONTAINER $file >> /mnt/disk-workspace/transform.log

      echo "Uncompressing /mnt/ram-workspace/$DOWNLOAD_FILE"
      echo "Uncompressing /mnt/ram-workspace/$DOWNLOAD_FILE" >> /mnt/disk-workspace/transform.log
      /bin/gunzip /mnt/ram-workspace/$DOWNLOAD_FILE >> /mnt/disk-workspace/transform.log

      UNCOMPRESSED_FILE=${DOWNLOAD_FILE//.gz/}
      CSV_FILE=${UNCOMPRESSED_FILE//.txt/}.csv

      echo "" > /mnt/ram-workspace/$DOWNLOAD_FILE

      echo "Transforming the tweet json to csv: /mnt/ram-workspace/$UNCOMPRESSED_FILE"
      echo "Transforming the tweet json to csv: /mnt/ram-workspace/$UNCOMPRESSED_FILE" >> /mnt/disk-workspace/transform.log
      /usr/bin/python3 /mnt/disk-workspace/transform-tweets-to-csv.py  -s /mnt/ram-workspace/$UNCOMPRESSED_FILE -o /mnt/ram-workspace/transform.csv >> /mnt/disk-workspace/transform.log

      /bin/rm /mnt/ram-workspace/$UNCOMPRESSED_FILE >> /mnt/disk-workspace/transform.log

      echo "Sorting $DOWNLOAD_FILE"
      echo "Sorting $DOWNLOAD_FILE" >> /mnt/disk-workspace/transform.log
      /usr/bin/sort /mnt/ram-workspace/transform.csv -o /mnt/ram-workspace/sort.csv -T /mnt/ram-workspace/tmp/ >> /mnt/disk-workspace/transform.log

      /bin/rm /mnt/ram-workspace/transform.csv >> /mnt/disk-workspace/transform.log

      echo "Removing Duplicates from $DOWNLOAD_FILE"
      echo "Removing Duplicates from $DOWNLOAD_FILE" >> /mnt/disk-workspace/transform.log
      /usr/bin/uniq -u /mnt/ram-workspace/sort.csv /mnt/ram-workspace/$CSV_FILE >> /mnt/disk-workspace/transform.log

      /bin/rm /mnt/ram-workspace/sort.csv >> /mnt/disk-workspace/transform.log

      echo "Compressing $CSV_FILE"
      echo "Compressing $CSV_FILE" >> /mnt/disk-workspace/transform.log
      gzip /mnt/ram-workspace/$CSV_FILE >> /mnt/disk-workspace/transform.log

      echo "Uploading $CSV_FILE.gz to swift container: $UPLOAD_CONTAINER"
      echo "Uploading $CSV_FILE.gz to swift container: $UPLOAD_CONTAINER" >> /mnt/disk-workspace/transform.log
      /usr/bin/swift upload -S 1000000000 --object-name $CSV_FILE.gz $UPLOAD_CONTAINER /mnt/ram-workspace/$CSV_FILE.gz >> /mnt/disk-workspace/transform.log

      /bin/rm /mnt/ram-workspace/$CSV_FILE.gz >> /mnt/disk-workspace/transform.log

      echo ""
      echo "" >> /mnt/disk-workspace/transform.log
  fi
done </mnt/disk-workspace/file-list.txt