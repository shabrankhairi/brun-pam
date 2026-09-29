# Brun

### Self-Hosted Privileged Access Management

Brun is a browser-based Privileged Access Management (PAM) solution that
provides secure access to network devices, servers, and infrastructure
through SSH, Telnet, RDP, and VNC — directly from a web browser.

No SSH/RDP client installation is required on end-user laptops.

Every session is automatically recorded and auditable.

Built on top of [`guacd`](https://guacamole.apache.org/), the protocol
proxy engine behind Apache Guacamole.

---

## ✨ Features

- 🌐 **Browser-Based Access**
  - Access infrastructure directly from your browser.
  - No SSH/RDP client required on user laptops.

- 🎥 **Automatic Session Recording**
  - Every session is automatically recorded.
  - Recordings can be replayed directly from the browser.

- ⌨️ **Command Transcript**
  - SSH and Telnet sessions are captured as searchable command transcripts.
  - Transcript is grouped by command line rather than individual keystrokes.

- 🔐 **Automatic Password Redaction**
  - Passwords entered after commands such as `sudo`, `su`, and `passwd` are automatically redacted from transcripts.
  - Redaction uses heuristic pattern detection and is intentionally tuned toward over-redaction.

- 👀 **Live Session Monitoring**
  - Administrators can monitor active sessions in real time.
  - Monitoring is read-only and does not allow the administrator to interact with the session.

- 👥 **Role-Based Access Control**
  - Administrators have full access to Brun.
  - Regular users can only access connections explicitly assigned to them.

- 📋 **Structured Audit Log**
  - Security-relevant events are recorded in JSON Lines (`.jsonl`) format.
  - Logs can be consumed directly by SIEM and log-shipping tools.

- 🏠 **Self-Hosted**
  - Brun runs on your own infrastructure.
  - Data remains within your environment.

## 🔌 Supported Connections

Brun supports:

| Protocol | Use Case |
|---|---|
| SSH | Network devices, Linux servers, CLI-based infrastructure |
| Telnet | Legacy CLI-based devices |
| RDP | Windows servers / VMs |
| VNC | Desktop and web-based applications |

Connections can be restricted to specific users using the **Allowed users** field.

## 🏗️ Requirements

A Linux server is required.

### Minimum Requirements

- Linux server
  - Ubuntu/Debian recommended
- Root or `sudo` access
- Docker
  - Installer automatically installs Docker if required
- Internet access during installation
- Ports `80` and `443` available
- Minimum:
  - **2 GB RAM**
  - **20 GB storage**

> Storage requirements increase depending on the volume of session recordings.

## 🚀 Installation

Log in to your Linux server as `root` or a user with `sudo` access.

Run:

```bash
wget -qO- https://raw.githubusercontent.com/shabrankhairi/brun-pam/main/install.sh | bash
```

The installer will:

1. Install Docker (if not already present)
2. Set up the install directory at `/opt/brun`
3. Ask for an admin username (default: `admin`)
4. Ask for the domain Brun will be reached at
5. Automatically generate the admin password, encryption key, and a TLS certificate
6. Pull the application image and start it

At the end, you'll get a summary with the URL and login credentials —
save it somewhere safe (it's also stored in `/opt/brun/.env` on the
server, root-readable only).

## 📦 What This Repository Contains

This repo holds the **installer and deployment configuration only**:

```
install.sh                        <- the one-liner end users run
release-tools/
  ├── docker-compose.release.yml  <- Compose file the installer downloads
  ├── Dockerfile.release          <- builds the published image from the obfuscated build
  ├── build-release.js            <- obfuscates/minifies the app source before packaging
  └── pam.conf                    <- nginx reverse proxy config
```

It does **not** contain the Brun application's source code. The app
itself ships as a prebuilt container image pulled from
`ghcr.io/shabrankhairi/brun-app` during installation — see
[License](#-license) below for why.

## 🔄 Updating

```bash
cd /opt/brun
docker compose pull
docker compose up -d
```

## 📖 Documentation

| File | What's in it |
|---|---|
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute to the installer, and how to report application bugs |
| [SECURITY.md](SECURITY.md) | How to report a security vulnerability |
| [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) | Open-source components Brun is built on, and their licenses |
| [LICENSE](LICENSE) | License for this repository's contents |

## 💬 Support

Questions, bug reports, or feedback: **Shabran Al Khairi** —
[LinkedIn](https://www.linkedin.com/in/shabrankhairi/)

## 📄 License

This repository (the installer script and deployment configuration in
`release-tools/`) is licensed under the [MIT License](LICENSE) — use it,
modify it, redistribute it, no strings attached.

The **Brun application itself** — the code that actually runs inside the
container this installer pulls — is **not** published as source in this
or any other repository. It's distributed only as a prebuilt, obfuscated
container image. This is a deliberate choice, not an oversight: it lets
the deployment tooling stay fully open while the application logic stays
harder to casually copy or reverse-engineer.

If that split doesn't work for your use case (e.g. you need to audit the
application source directly), reach out — see [Support](#-support) above.

### Third-party components

Brun's protocol engine (`guacd`) and the libraries that bridge it to a
browser (`guacamole-lite`, `guacamole-common-js`) all come from the
[Apache Guacamole](https://guacamole.apache.org/) project and are used
under the **Apache License, Version 2.0**. Brun would not exist without
that project — see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for
full attribution and a disclosure of the one small patch applied to
`guacamole-common-js` (a fix for an upstream session-recording playback
bug).
