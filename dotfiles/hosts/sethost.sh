#!/bin/bash
# A slightly rude-looking case structure to set up our host-specific config

HOST=$(hostname)

if [[ $HOST == "lancer" ]]; then
  CONFIG_FOLDER="lancer"
elif [[ $HOST == "*andrew.cmu.edu" ]]; then
  CONFIG_FOLDER="andrew"
elif [[ $HOST == "caster" ]]; then
  # TODO
  #CONFIG_FOLDER="caster"
  CONFIG_FOLDER="default"
elif [[ $HOST == "*-PC" ]]; then
  #CONFIG_FOLDER="babun"
  CONFIG_FOLDER="default"
else
  CONFIG_FOLDER="default"
fi

ln -s hosts/$CONFIG_FOLDER ~/.hostrc

