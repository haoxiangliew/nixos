#!/usr/bin/env bash

echo 'Disabling laptop keyboard...'
echo

pkexec evtest --grab /dev/input/event1
