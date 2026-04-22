#!/bin/bash

CUDA="0"
DEVICE="auto"
RUNNING_LANGUAGE='chn'
VERSION='v1'

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cuda) CUDA="$2"; shift ;;
        --device) DEVICE="$2"; shift ;;
        --version) VERSION="$2"; shift ;;
        --language) RUNNING_LANGUAGE="$2"; shift ;;
        start) COMMAND_ACTION="start" ;;
        stop) COMMAND_ACTION="stop" ;;
        restart) COMMAND_ACTION="restart" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$COMMAND_ACTION" ]]; then
    echo "Usage: $0 {start|stop|restart} [--device auto|cuda|mps|cpu] [--cuda <CUDA_VISIBLE_DEVICES>] [--language chn|eng] [--version v0|v1]"
    exit 1
fi

cd vinci-local/docker
./boot.sh "$COMMAND_ACTION"
cd ../..
./vinci-inference/boot.sh --device "$DEVICE" --cuda "$CUDA" --language "$RUNNING_LANGUAGE" --version "$VERSION" "$COMMAND_ACTION"
