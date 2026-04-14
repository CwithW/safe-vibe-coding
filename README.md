# safe-vibe-coding

an attempt to make vibe coding safe.

### usage

run docker compose build in ./base_image.

then, copy ./codex-safe to /usr/local/bin, and next time when you would call codex, call codex-safe instead.

same for ./claude-safe.

### description

the base_image/entrypoint.sh checks for /home/cw/.codex or /home/cw/.claude, if any of them exists, it will set the cw user's uid and gid to match the owner of the folder. so the uid and gid of the containerized cw user is the same as the user of your pc.

the {claude,codex}-safe scripts create a docker using the base image, mount the {~/.codex,~/.claude and ~/.claude.json} and $(pwd) to the container, and run the vibe coding tool inside $(pwd).

the scripts, however, do NOT pass your HTTPS_PROXY and other environment variables to the container. so mind this if you are using claude code inside an unsupported country.

### limitations

does not allow to run under /tmp/.

does mount your local /var/run/docker.sock to the container. this is indeed unsafe, but it is required to make docker available to the containered codex.
  - a better solution would be to use docker-in-docker or another rootless privilegeless dind solution, but it is too heavy for my current needs.

Claude Code may have a detection for docker containers, and may category docker containers as multiple PCs.