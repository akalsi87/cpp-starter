#!/bin/bash

_dir=$(dirname -- $(dirname $(readlink -f "${BASH_SOURCE[0]}")))
cd "${_dir}" || exit 1

. shell/common.sh
. shell/mamba-env.sh

_setup.run

([ "${NONINTERACTIVE:-}" = 1 ] || [ "$#" -gt 0 ]) && {
  exec make run ARGS="$*"
}

exec make run ARGS="bash -l"
