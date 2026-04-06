#!/bin/bash
set -euo pipefail

readonly RUNNER_USER="cw"
readonly RUNNER_HOME="/home/cw"
readonly RUNNER_CODEX_DIR="${RUNNER_HOME}/.codex"

build_command_payload() {
    local escaped_args=()
    local arg

    for arg in "$@"; do
        printf -v arg '%q' "${arg}"
        escaped_args+=("${arg}")
    done

    printf '%s' "${escaped_args[*]}"
}

sync_runner_identity() {
    local current_uid
    local current_gid
    local target_uid
    local target_gid

    [ -e "${RUNNER_CODEX_DIR}" ] || return

    current_uid="$(id -u "${RUNNER_USER}")"
    current_gid="$(id -g "${RUNNER_USER}")"
    target_uid="$(stat -c '%u' "${RUNNER_CODEX_DIR}")"
    target_gid="$(stat -c '%g' "${RUNNER_CODEX_DIR}")"

    if [ "${target_gid}" != "${current_gid}" ]; then
        groupmod -o -g "${target_gid}" "${RUNNER_USER}"
    fi

    if [ "${target_uid}" != "${current_uid}" ]; then
        usermod -o -u "${target_uid}" -g "${target_gid}" "${RUNNER_USER}"
    elif [ "${target_gid}" != "${current_gid}" ]; then
        usermod -g "${target_gid}" "${RUNNER_USER}"
    fi

    chown "${RUNNER_USER}:${RUNNER_USER}" "${RUNNER_HOME}"

    if [ -d "${RUNNER_HOME}/.ssh" ]; then
        chown -R "${RUNNER_USER}:${RUNNER_USER}" "${RUNNER_HOME}/.ssh"
    fi

    if [ -d "${RUNNER_HOME}/workspace" ]; then
        chown -R "${RUNNER_USER}:${RUNNER_USER}" "${RUNNER_HOME}/workspace"
    fi
}

sync_runner_identity

# Proxy Docker socket so the runner user can access it without root
# Host socket is mounted at /var/run/docker-real.sock; socat proxies it to /var/run/docker.sock
if [ -S /var/run/docker-real.sock ]; then
    [ -e /var/run/docker.sock ] && rm -f /var/run/docker.sock
    socat UNIX-LISTEN:/var/run/docker.sock,fork,user=cw,group=cw,mode=0660 \
          UNIX-CONNECT:/var/run/docker-real.sock &
    # echo "Docker socket proxy started for runner"
fi

if [ "$#" -eq 0 ]; then
    set -- codex --yolo
fi

command_payload="$(build_command_payload "$@")"
command_payload_b64="$(printf '%s' "${command_payload}" | base64 | tr -d '\n')"

exec su -s /bin/bash -c '
decoded_cmd="$(printf "%s" "$0" | base64 -d)"
eval "exec ${decoded_cmd}"
' "${RUNNER_USER}" "${command_payload_b64}"
