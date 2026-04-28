#!/usr/bin/env bash
set -e

BUILD_TARGET=""
BUILD_NAME=""
BUILD_NUMBER=""
FLUTTER_COMMAND="flutter build"

if [[ -z "$KLIPY_API_KEY" ]]; then
  echo "Error: env variable(s) missing"
  exit 1
fi

DART_DEFINES=(
  "--dart-define=\"KLIPY_API_KEY=$KLIPY_API_KEY\""
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
    if [[ -z "$2" && "$BUILD_TARGET" == "ios" ]]; then
      echo "Error: --build-name requires a value for ios."
      exit 1
    fi
    BUILD_NAME="$2"
    shift 2
    ;;
  --build-number)
    if [[ -z "$2" && "$BUILD_TARGET" == "ios" ]]; then
      echo "Error: --build-number requires a value for ios."
      exit 1
    fi
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
