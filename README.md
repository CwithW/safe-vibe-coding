# safe-vibe-coding

An attempt to make vibe coding safe.

## Usage

Run `docker compose build` in `./base_image`.

Then, copy `./codex-safe` to `/usr/local/bin`, and next time when you would call `codex`, call `codex-safe` instead.

Same for `./claude-safe`.

## Description

The `base_image/entrypoint.sh` checks for `/home/cw/.codex` or `/home/cw/.claude`, if any of them exists, it will set the `cw` user's uid and gid to match the owner of the folder. So the uid and gid of the containerized `cw` user is the same as the user of your PC.

The `{claude,codex}-safe` scripts create a docker container using the base image, mount `~/.codex`, `~/.claude`, `~/.claude.json` and `$(pwd)` to the container, and run the vibe coding tool inside `$(pwd)`.

The scripts, however, do **NOT** pass your `HTTPS_PROXY` and other environment variables to the container. So mind this if you are using Claude Code inside an unsupported country.

## Limitations

- Does not allow running under `/tmp/`, because `/tmp` is already mounted in the container. You can't have a mountpoint inside another mountpoint.
- Does mount your local `/var/run/docker.sock` to the container. This is indeed unsafe, but it is required to make docker available to the containerized `codex`.
  - A better solution would be to use docker-in-docker or another rootless privilegeless dind solution, but it is too heavy for my current needs.
- Claude Code may have a detection for docker containers, and may categorize docker containers as multiple PCs.
- Your existing MCP server on your local PC will likely fail to run inside the docker container, because they are not there. You can modify the Dockerfile to build them into the container.