# Contributing to Brun

Thanks for considering contributing. A quick note on scope before you
dive in:

## What's in this repository

This repo contains the **installer and deployment configuration
only** — `install.sh`, the Docker Compose file the installer
downloads, and the release-build tooling. It does **not** contain the
Brun application's source code (see [README.md](README.md#license)
for why).

## Contributing to the installer / deployment tooling

This part is regular open source (MIT-licensed) — pull requests
welcome:

1. Fork this repository
2. Create a branch for your change
3. Test your change on a real Linux server before opening a PR —
   installer scripts are easy to get subtly wrong on one distro while
   looking fine on another
4. Open a pull request describing what changed and why

Good candidates for contribution here: support for additional Linux
distributions, better error handling in `install.sh`, clearer output
messages, documentation fixes.

## Reporting bugs in the Brun application itself

Since the application source isn't public, bug reports and feature
requests for Brun's actual functionality (the web UI, session
recording, RBAC, audit logging, etc.) go through the maintainer
directly rather than as issues against source you can't see:

**Shabran Al Khairi** — [LinkedIn](https://www.linkedin.com/in/shabrankhairi/)

When reporting a bug, please include:
- What you expected to happen vs. what actually happened
- Steps to reproduce
- Relevant output from `docker compose logs app` / `guacd` / `nginx`
  (strip out any credentials before sharing)
- Your Brun version (`docker compose images` inside `/opt/brun`)

## Reporting security issues

Please see [SECURITY.md](SECURITY.md) — security issues should **not**
be reported through public channels.

## Code of conduct

Be respectful, be constructive, assume good faith. Nothing more
formal than that for a project this size.
