[ "${_INCLUDED_mamba_env:-}" = 1 ] && return 0
_INCLUDED_mamba_env=1

. shell/common.sh

_env_name="repo"

_env.create_file() {
  _log.info "Creating environment.yml if not present..."
  if [ ! -f "${repo_root}/environment.yml" ]; then
    cat <<EOF > "${repo_root}/environment.yml"
channels:
  - conda-forge
  - conda-canary
dependencies:
  - conda-forge/label/python_rc::_python_rc
  - python=3.14.0rc1
  - nodejs=24.4.1
  - gxx=15.1.0
  - gcc=15.1.0
  - ninja=1.13.1
  - ccache=4.11.3
  - cmake=4.1.0
  - bash=5.2.37
  - clang-tools=20.1.8
  - make=4.4.1
  - git=2.49.0
EOF
  fi
}

_env.create() {
  "${micromamba_bin}" env create -f "${repo_root}/environment.yml" --prefix "${MAMBA_ROOT_PREFIX}/envs/${_env_name}" -y \
    || _log.err "Failed to create Micromamba environment"
  _env.write_checksum
}

_env.exists() {
  ("${micromamba_bin}" env list | grep -q "${MAMBA_ROOT_PREFIX}/envs/${_env_name}") && return 0
  _log.warn "Couldn't find: "${MAMBA_ROOT_PREFIX}/envs/${_env_name}""
  return 1
}

_env.write_checksum() {
  echo "$(shasum "${repo_root}/environment.yml")" > "${repo_local}/.env_sha"
}

_env.equal_checksum() {
  [ "$(shasum "${repo_root}/environment.yml")" = "$(cat "${repo_local}/.env_sha" 2>/dev/null)" ] && return 0
  return 1
}

_env.activate() {
  # Source Micromamba shell hook
  eval "$(${micromamba_bin} shell hook -s bash)" || _log.err "Failed to source Micromamba shell hook"
  # Activate environment
  micromamba activate ${env_name} || _log.err "Failed to activate Micromamba environment"
}

_setup_mamba_env() {
  export MAMBA_ROOT_PREFIX="${repo_local}/mamba-root"
  mkdir -p ${MAMBA_ROOT_PREFIX}
}

_install_micromamba() {
  echo "Installing Micromamba ${micromamba_ver} in ${micromamba_root}..."
  rm -rf "${micromamba_root}" || _log.err "Failed to clean up ${micromamba_root}"
  mkdir -p "${micromamba_root}/bin" || _log.err "Failed to create ${micromamba_root}/bin"
  curl -L "https://micromamba.snakepit.net/api/micromamba/linux-64/${micromamba_ver}" | tar -xj -C "${micromamba_root}"  || _log.err "Failed to download or extract Micromamba"
  chmod +x "${micromamba_bin}" || _log.err "Failed to make Micromamba executable"
  # Verify installation
  if [ ! -f "${micromamba_bin}" ]; then
    _log.err "Micromamba binary not found at ${micromamba_bin}"
  fi
}

_activate_mamba_env() {
  _env.create_file

  _log.info "Activating Micromamba environment..."
  if [ ! -f "${micromamba_bin}" ]; then
    _log.err "Micromamba binary not found at ${micromamba_bin}"
  fi
  if ! (_env.exists && _env.equal_checksum) ; then
    _env.create
  fi

  _env.activate
}

_setup.add _setup_mamba_env
[ -f "${micromamba_bin}" ] || _setup.add _install_micromamba
_setup.add _activate_mamba_env
