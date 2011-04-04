#!/bin/bash
#
#David Chen(david.chen@canonical.com) for india rupee symbol

if ! apt-get install --allow-unauthenticated xkb-data;
then
	exit -1
fi
