#!/usr/bin/env bash
set -e

BUILD_TARGET=""
BUILD_NAME=""
BUILD_NUMBER=""
FLUTTER_COMMAND="flutter build"

DART_DEFINES=(
    "--dart-define=\"TENOR_API_KEY=$TENOR_API_KEY\""
    "--dart-define=\"SEARCH_API_KEY=$SEARCH_API_KEY\""
    "--dart-define=\"ALGOLIA_APP_ID=$ALGOLIA_APP_ID\""
)

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ios)
            BUILD_TARGET="ios"
            shift
            ;;
        --android)
            BUILD_TARGET="apk"
            shift
            ;;
        --build-name)
            if [ -z "$2" ]; then echo "Error: --build-name requires a value."; exit 1; fi
            BUILD_NAME="$2"
            shift 2
            ;;
        --build-number)
            if [ -z "$2" ]; then echo "Error: --build-number requires a value."; exit 1; fi
            BUILD_NUMBER="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

if [ -z "$BUILD_TARGET" ]; then
    echo "Error: Must specify build target using --ios or --android."
    echo "Usage: ./build.sh [--ios | --android] --build-name <name> --build-number <number>"
    exit 1
fi

FULL_COMMAND="$FLUTTER_COMMAND $BUILD_TARGET"

for define in "${DART_DEFINES[@]}"; do
    FULL_COMMAND="$FULL_COMMAND $define"
done

if [ -n "$BUILD_NAME" ]; then
    FULL_COMMAND="$FULL_COMMAND --build-name $BUILD_NAME"
fi

if [ -n "$BUILD_NUMBER" ]; then
    FULL_COMMAND="$FULL_COMMAND --build-number $BUILD_NUMBER"
fi

eval "$FULL_COMMAND"
