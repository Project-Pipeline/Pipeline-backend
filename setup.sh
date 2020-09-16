#!/bin/sh

#  setup.sh
#  PipelineBackend
#
#  Created by Jing Wei Li on 9/15/20.
#  
if ! hash jq 2>/dev/null
then
    echo "Please install jq"
    exit 1
fi

if ! [[ -f config.json ]]; then
    echo "Please add setup.json"
    exit 1
fi

client_id=$(jq -r ".googleClientID" < config.json)
callback_url=$(jq -r ".googleCallbackURL" < config.json)
client_secret=$(jq -r ".googleClientSecret" < config.json)

export GOOGLE_CLIENT_ID="$client_id"
export GOOGLE_CALLBACK_URL="$callback_url"
export GOOGLE_CLIENT_SECRET="$client_secret"
