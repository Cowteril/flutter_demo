# Remote Repository Policy

## Remote

- GitHub SSH remote: `ssh://git@ssh.github.com:443/Cowteril/flutter_demo.git`
- Local remote name: `origin`
- Reason for 443 endpoint: `git@github.com` on port 22 can be blocked or routed to proxy fake IPs in the current network. GitHub SSH over port 443 has been verified with `ssh -T -p 443 git@ssh.github.com`.

## Hard Rules

1. Never leak API keys, private keys, tokens, passwords, signing keys, service credentials, or other secrets.
2. If GitHub is unreachable because of domestic network blocking, DNS failure, SSH timeout, TLS timeout, or proxy/network instability, do not force the upload in that run. Report the failure and try again in a later session.

## Before Any Push

- Inspect `git status --short`.
- Review staged changes before commit or push.
- Do not stage obvious secret-bearing files such as `.env`, local config files, private keys, credential exports, keystores, or token files unless the user explicitly confirms they are safe.
- If a potential secret is detected, stop and ask the user before committing or pushing.
- Do not paste secret values into chat, logs, documentation, commit messages, or run artifacts.

## Network Failure Behavior

If remote commands such as `git fetch`, `git pull`, or `git push` fail because GitHub cannot be reached:

- Do not repeatedly retry.
- Do not switch remotes to mirrors.
- Do not upload to another platform.
- Do not ask the user to expose tokens or credentials.
- State that this upload is skipped due to network reachability and leave the repository ready for a later push.

## Normal Remote Workflow

- Use `origin` for this project's GitHub remote.
- Prefer SSH remote operations.
- Push only when the user asks for a push or when a completed commit/publish task clearly requires it.
- Keep unrelated local changes out of commits unless the user explicitly requests a broad commit.
