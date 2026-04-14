# safe-vibe-coding

an attempt to make vibe coding safe.

### usage

make sure the "cw" user in the container has the same uid and gid as your local user, so that the files created by codex in the container will have the correct permissions on your local machine.

run docker compose build in ./base_image.

then, copy ./codex-safe to /usr/local/bin, and next time when you would call codex, call codex-safe instead.

### limitations

does not allow to run under /tmp/.

does mount your local /var/run/docker.sock to the container. this is indeed unsafe, but it is required to make docker available to the containered codex.
  - a better solution would be to use docker-in-docker or another rootless privilegeless dind solution, but it is too heavy for my current needs.