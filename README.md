# Brun

### Self-Hosted Privileged Access Management

Brun is a browser-based Privileged Access Management (PAM) solution that provides secure access to network devices, servers, and infrastructure through SSH, Telnet, RDP, and VNC — directly from a web browser.

No SSH/RDP client installation is required on end-user laptops.

Every session is automatically recorded and auditable.

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
