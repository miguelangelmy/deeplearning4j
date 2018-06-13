#!/bin/bash

set -exuo pipefail

IS_RELEASE='true'

if [ -f /etc/redhat-release ]; then
    source /opt/rh/devtoolset-7/enable
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    export CC=$(ls -1 /usr/local/bin/gcc-? | head -n 1)
    export CXX=$(ls -1 /usr/local/bin/g++-? | head -n 1)
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    export CC=$(which gcc)
    export CXX=$(which g++)
fi

parse_commandline ()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--release=*)
				IS_RELEASE="${_key##--release=}"
				;;
			*)
				;;
		esac
		shift
	done
}

parse_commandline "$@"

cmake -G "Unix Makefiles" -D_RELEASE=${IS_RELEASE} && make -j4 && layers_tests/runtests --gtest_output="xml:../target/surefire-reports/TEST-results.xml"
