#!/bin/bash

DOWNLOAD_PATH=$1
FILE_LIST=$2

echo "Creating tmp directory: /var/lib/postgresql/tmp"
mkdir /var/lib/postgresql/tmp

echo "Downloading database schema"
/usr/bin/curl -s https://raw.githubusercontent.com/kevincoakley/cloud-benchmark-postgres/master/schema/postgresql/schema-tweet-user-single-table.sql > /var/lib/postgresql/tmp/schema.sql

echo "Adding database schema to the database server"
/usr/bin/psql -f /var/lib/postgresql/tmp/schema.sql

echo "Download the import file list: $DOWNLOAD_PATH$FILE_LIST"
/usr/bin/curl -s $DOWNLOAD_PATH$FILE_LIST > /var/lib/postgresql/tmp/$FILE_LIST

echo "Reading $FILE_LIST"
while read file; do
  DOWNLOAD_FILE=${file//\//_}

  if [ -e $DOWNLOAD_FILE ]
    then
      echo "$DOWNLOAD_FILE exists; skipping"
    else
      echo "$DOWNLOAD_FILE does not exist; processing"

      echo "Downloading $DOWNLOAD_PATH$file"
      /usr/bin/curl -s $DOWNLOAD_PATH$file > /var/lib/postgresql/tmp/$DOWNLOAD_FILE

      echo "$file" >> /var/lib/postgresql/tmp/psql_time.txt
      echo "$file" >> /var/lib/postgresql/tmp/psql_output.txt
      /bin/date >> /var/lib/postgresql/tmp/psql_time.txt
      /bin/date >> /var/lib/postgresql/tmp/psql_output.txt

      echo "Importing $DOWNLOAD_FILE into postgresql"
      /usr/bin/time -o /var/lib/postgresql/tmp/psql_time.txt -a -f "Elapsed time: %E" /usr/bin/psql --command "\\copy public.tweet (tweet_created_at, tweet_id, tweet_id_str, tweet_text, tweet_source, tweet_truncated, tweet_in_reply_to_status_id, tweet_in_reply_to_status_id_str, tweet_in_reply_to_user_id, tweet_in_reply_to_user_id_str, tweet_in_reply_to_screen_name, tweet_coordinates, tweet_place, tweet_quoted_status_id, tweet_quoted_status_id_str, tweet_is_quote_status, tweet_quoted_status, tweet_retweeted_status, tweet_quote_count, tweet_reply_count, tweet_retweet_count, tweet_favorite_count, tweet_entities, tweet_extended_entities, tweet_favorited, tweet_retweeted, tweet_possibly_sensitive, tweet_filter_level, tweet_lang, tweet_matching_rules, user_id, user_id_str, user_name, user_screen_name, user_location, user_derived, user_url, user_description, user_protected, user_verified, user_followers_count, user_friends_count, user_listed_count, user_favourites_count, user_statuses_count, user_created_at, user_profile_banner_url, user_profile_image_url_https, user_default_profile, user_default_profile_image, user_withheld_in_countries, user_withheld_scope) FROM '/var/lib/postgresql/tmp/$DOWNLOAD_FILE' DELIMITER ',' CSV QUOTE '|' ESCAPE '''';" >> /var/lib/postgresql/tmp/psql_output.txt

      echo "Zeroing out $DOWNLOAD_FILE"
      echo "" > /var/lib/postgresql/tmp/$DOWNLOAD_FILE

      echo "" >> /var/lib/postgresql/tmp/psql_time.txt
      echo "" >> /var/lib/postgresql/tmp/psql_output.txt
  fi
done </var/lib/postgresql/tmp/$FILE_LIST

echo "Done"