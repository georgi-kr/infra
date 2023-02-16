#!/bin/bash
#
# Simplify creating new berglas secrets manually
# The "${@:3}" at the end would pass all the arguments along to berglas.
# Usage:
#
#   ./scripts/berglas-create.sh nonprod <<secret-name>> <<secret-value>>
#
# Would result in:
#
#   berglas create --key projects/nonprod/locations/us-west1-a/keyRings/berglas/cryptoKeys/berglas-key nonprod-berglas/<<secret-name>> '<<secret-value>>'


case $1 in

  nonprod)
    KEY=projects/nonprod/locations/us-west1-a/keyRings/berglas/cryptoKeys/berglas-key
    BUCKET=nonprod-berglas
    ;;

  prod)
    KEY=projects/prod/locations/us-west1-a/keyRings/berglas/cryptoKeys/berglas-key
    BUCKET=prod-berglas
    ;;

  *)
    echo "Usage: ./berglas-create.sh [nonprod|prod] [name] [value]"
    exit 1
    ;;

esac

berglas create --key=$KEY $BUCKET/$2 ${@:3}
