[ "${_INCLUDED_common:-}" = 1 ] && return 0
_INCLUDED_common=1

repo_root="$(git rev-parse --show-toplevel)"
repo_local="${repo_root}/.local"
micromamba_root="${repo_local}/micromamba"
micromamba_bin="${micromamba_root}/bin/micromamba"
micromamba_ver="latest"
env_name="repo"

set -aeuo pipefail

[ "${DEBUG:-}" = 1 ] && set -x
[ "${VERBOSE:-}" = 1 ] && export VERBOSE=1

_log.info() {
  [ "${VERBOSE:-}" != 1 ] && return 0
  >&2 echo "I] $*"
}
_log.warn() {
  >&2 echo "W] $*"
}
_log.err() {
  >&2 echo "E] $*"
  exit 1
}

_setup_steps=()

_setup.add() {
  _setup_steps+=("$1")
}

_setup.run() {
  for step in "${_setup_steps[@]}"; do
    _log.info "Running setup step: ${step} ..."
    ${step} || _log.err "Failed step: ${step} ..."
  done
}
