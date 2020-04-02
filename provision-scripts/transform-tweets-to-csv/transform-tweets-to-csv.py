#!/usr/bin/env python

import json
import csv
import argparse


def parse(from_tweet, key, length=None):
    return_var = None

    # Make sure the key exists
    if key in from_tweet:
        # Skip if the key value is None
        if from_tweet[key] is not None:

            return_var = from_tweet[key]

            # Parse String
            if isinstance(return_var, str):
                # Remove any white space
                return_var = return_var.strip()

                # Remove any new line characters as they will break the csv file
                return_var = return_var.replace('\n', ' ').replace('\r', '')

                # Cap the string length if the length var is passed
                if length is not None:
                    return_var = return_var[:length]

                # If the key value ends with ' then add a space to keep it from escaping the csv quotechar
                if return_var.endswith("'"):
                    return_var = "%s " % return_var

            # Parse Dictionary
            if isinstance(return_var, dict):
                return_var = json.dumps(return_var)

    return return_var


parser = argparse.ArgumentParser()

parser.add_argument("-s",
                    metavar="source_file",
                    dest="source_file",
                    help="Source File",
                    required=True)

parser.add_argument("-o",
                    metavar="output_file",
                    dest="output_file",
                    help="Output File",
                    required=True)

args = parser.parse_args()

with open(args.output_file, 'w') as tweet_csv_file:
    tweet_writer = csv.writer(tweet_csv_file, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL, escapechar="'")

    with open(args.source_file, 'rt') as f:
        for line in f:
            # Remove quotechar
            line = line.replace("|", "")
            # Remove the Unicode escape notation
            line = line.replace('\u0000', '').replace('\\u0000', '')
            tweet_json = json.loads(line)

            # Skip any tweets where the language isn't English
            if tweet_json["lang"] != "en":
                continue

            # Tweet
            tweet_created_at = parse(tweet_json, "created_at")
            tweet_id = parse(tweet_json, "id")
            tweet_id_str = parse(tweet_json, "id_str", length=80)
            if "extended_tweet" in tweet_json:
                tweet_text = parse(tweet_json["extended_tweet"], "full_text")
            else:
                tweet_text = parse(tweet_json, "text")
            tweet_source = parse(tweet_json, "source", length=200)
            tweet_truncated = parse(tweet_json, "truncated")
            tweet_in_reply_to_status_id = parse(tweet_json, "in_reply_to_status_id")
            tweet_in_reply_to_status_id_str = parse(tweet_json, "in_reply_to_status_id_str", length=80)
            tweet_in_reply_to_user_id = parse(tweet_json, "in_reply_to_user_id")
            tweet_in_reply_to_user_id_str = parse(tweet_json, "in_reply_to_user_id_str", length=80)
            tweet_in_reply_to_screen_name = parse(tweet_json, "in_reply_to_screen_name", length=80)
            tweet_coordinates = parse(tweet_json, "coordinates")
            tweet_place = parse(tweet_json, "place")
            tweet_quoted_status_id = parse(tweet_json, "quoted_status_id")
            tweet_quoted_status_id_str = parse(tweet_json, "quoted_status_id_str", length=80)
            tweet_is_quote_status = parse(tweet_json, "is_quote_status")
            tweet_quoted_status = parse(tweet_json, "quoted_status")
            tweet_retweeted_status = parse(tweet_json, "retweeted_status")
            tweet_quote_count = parse(tweet_json, "quote_count")
            tweet_reply_count = parse(tweet_json, "reply_count")
            tweet_retweet_count = parse(tweet_json, "retweet_count")
            tweet_favorite_count = parse(tweet_json, "favorite_count")
            tweet_entities = parse(tweet_json, "entities")
            tweet_extended_entities = parse(tweet_json, "extended_entities")
            tweet_favorited = parse(tweet_json, "favorited")
            tweet_retweeted = parse(tweet_json, "retweeted")
            tweet_possibly_sensitive = parse(tweet_json, "possibly_sensitive")
            tweet_filter_level = parse(tweet_json, "filter_level", length=80)
            tweet_lang = parse(tweet_json, "lang", length=80)
            tweet_matching_rules = parse(tweet_json, "matching_rules")

            # Twitter User
            user_id = parse(tweet_json["user"], "id")
            user_id_str = parse(tweet_json["user"], "id_str", length=80)
            user_name = parse(tweet_json["user"], "name", length=80)
            user_screen_name = parse(tweet_json["user"], "screen_name", length=80)
            user_location = parse(tweet_json["user"], "location", length=200)
            user_derived = parse(tweet_json["user"], "derived")
            user_url = parse(tweet_json["user"], "url", length=200)
            user_description = parse(tweet_json["user"], "description", length=400)
            user_protected = parse(tweet_json["user"], "protected")
            user_verified = parse(tweet_json["user"], "verified")
            user_followers_count = parse(tweet_json["user"], "followers_count")
            user_friends_count = parse(tweet_json["user"], "friends_count")
            user_listed_count = parse(tweet_json["user"], "listed_count")
            user_favourites_count = parse(tweet_json["user"], "favourites_count")
            user_statuses_count = parse(tweet_json["user"], "statuses_count")
            user_created_at = parse(tweet_json["user"], "created_at")
            user_profile_banner_url = parse(tweet_json["user"], "profile_banner_url", length=200)
            user_profile_image_url_https = parse(tweet_json["user"], "profile_image_url_https", length=400)
            user_default_profile = parse(tweet_json["user"], "default_profile")
            user_default_profile_image = parse(tweet_json["user"], "default_profile_image")
            user_withheld_in_countries = parse(tweet_json["user"], "withheld_in_countries")
            user_withheld_scope = parse(tweet_json["user"], "withheld_scope", length=80)

            tweet_writer.writerow([tweet_created_at, tweet_id, tweet_id_str, tweet_text,
                                   tweet_source, tweet_truncated, tweet_in_reply_to_status_id,
                                   tweet_in_reply_to_status_id_str, tweet_in_reply_to_user_id,
                                   tweet_in_reply_to_user_id_str, tweet_in_reply_to_screen_name,
                                   tweet_coordinates, tweet_place, tweet_quoted_status_id,
                                   tweet_quoted_status_id_str, tweet_is_quote_status, tweet_quoted_status,
                                   tweet_retweeted_status, tweet_quote_count, tweet_reply_count,
                                   tweet_retweet_count, tweet_favorite_count, tweet_entities,
                                   tweet_extended_entities, tweet_favorited, tweet_retweeted,
                                   tweet_possibly_sensitive, tweet_filter_level, tweet_lang,
                                   tweet_matching_rules, user_id, user_id_str, user_name, user_screen_name,
                                   user_location, user_derived, user_url, user_description, user_protected,
                                   user_verified, user_followers_count, user_friends_count, user_listed_count,
                                   user_favourites_count, user_statuses_count, user_created_at,
                                   user_profile_banner_url, user_profile_image_url_https, user_default_profile,
                                   user_default_profile_image, user_withheld_in_countries, user_withheld_scope])

