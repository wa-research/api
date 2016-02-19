#! env bash
URL=${1:-$CC_API_URL}
KEY=${2:-$CC_API_KEY}
SECRET=${3:-$CC_API_SECRET}

if [[ -z $URL && -z $KEY && -z $SECRET ]]
then
    echo "USAGE"
    echo 
    echo "    ./echo.sh api_key api_secret community_url"
    echo
    echo "Alternatively, use a combination of arguments and environment variables CC_API_KEY, CC_API_SECRET, CC_API_URL:"
    echo 
    echo "    CC_API_KEY=api_key CC_API_SECRET=api_secret ./echo.sh community_url"
    echo
    echo "A community URL should include the protocol (for example https://ecs.wa-research.ch/community)"
    exit -1
fi

if [[ -z $KEY ]]
then
    echo "Please specify your API key"
    exit -1
fi
if [[ -z $SECRET ]]
then
    echo "Please specify your API secret"
    exit -1
fi
if [[ -z $URL ]]
then
    echo "Please specify a community URL with protocol (for example https://ecs.wa-research.ch/community)"
    exit -1
fi

BASEURL=$URL/__api/v1
REQ_TIME=$(curl -s $BASEURL/time)
OP=echo
SIGBASE=$OP$KEY$SECRET$REQ_TIME
SIG=$(echo -n "$SIGBASE" | openssl sha1)
#Several languages can also calculate the SHA1 hex digest from command line
#PHP
#SIG=$(php -r "echo sha1('$SIGBASE');")
#Ruby
#SIG=$(ruby -e "require 'digest/sha1'" -e "puts Digest::SHA1.hexdigest('$SIGBASE')")
#Python
#SIG=$(python -c "import hashlib; print hashlib.sha1('$SIGBASE').hexdigest()")

curl -v $BASEURL/$OP?site-id=$KEY\&request-time=$REQ_TIME\&signature=$SIG\&t=$REQ_TIME
