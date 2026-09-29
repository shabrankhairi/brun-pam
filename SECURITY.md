# Security Policy

Brun handles privileged credentials and session recordings for
production infrastructure. If you find a security issue, please
report it responsibly.

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, contact the maintainer directly:

**Shabran Al Khairi** — [LinkedIn](https://www.linkedin.com/in/shabrankhairi/)

Please include:
- A description of the vulnerability and its potential impact
- Steps to reproduce (or a proof of concept, if you have one)
- The Brun version affected, if known

You should receive an acknowledgement within a few days. Once a fix
is available, it will be released as a new image version, and you're
welcome to be credited in the release notes if you'd like.

## Scope

This covers:
- The Brun application itself (auth, session handling, RBAC, recording/
  audit-log storage and access control)
- The installer script and deployment configuration in this repository

This does **not** cover vulnerabilities in upstream dependencies
(Apache Guacamole / `guacd`, Docker, nginx, Node.js, etc.) — please
report those to the respective upstream projects. See
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for a list of the
main components Brun builds on.

## Supported versions

Only the latest released image (`ghcr.io/shabrankhairi/brun-app:latest`)
receives security fixes. There is no long-term-support branch at this
project's current stage — please stay on the latest version and update
regularly:

```bash
cd /opt/brun
docker compose pull
docker compose up -d
```
