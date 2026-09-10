#!/usr/bin/env bash
set -euo pipefail

# ==========================================================================
# Brun installer
# ==========================================================================
# Usage:
#   wget -qO- https://raw.githubusercontent.com/shabrankhairi/brun-pam/main/install.sh | bash
#
# What this script does:
#   1. Checks/installs Docker + the Compose plugin
#   2. Creates /opt/brun and downloads ONLY the deployment config files
#      (docker-compose.yml, nginx config) -- never any application source.
#      The actual application is pulled as a prebuilt image from a
#      container registry (see BRUN_IMAGE below).
#   3. Generates a random JWT secret, token cipher key, and VNC password
#   4. Prompts for an admin username/password
#   5. Generates a self-signed TLS certificate
#   6. Pulls the image and starts everything with `docker compose up -d`
#
# This script deliberately never clones or downloads the app/ source tree.
# ==========================================================================

GITHUB_USER="shabrankhairi"
GITHUB_REPO="brun-pam"
GITHUB_BRANCH="main"
BRUN_IMAGE="ghcr.io/${GITHUB_USER}/brun-app"
INSTALL_DIR="/opt/brun"
RAW_BASE="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/release-tools"

c_cyan='\033[0;36m'; c_green='\033[0;32m'; c_red='\033[0;31m'; c_reset='\033[0m'
info()  { echo -e "${c_cyan}==>${c_reset} $1"; }
ok()    { echo -e "${c_green}✓${c_reset} $1"; }
fail()  { echo -e "${c_red}✗ $1${c_reset}"; exit 1; }

# ---- 0. Basic checks ----
if [ "$(id -u)" -ne 0 ]; then
  fail "Please run this installer as root (or with sudo)."
fi
if [ "$(uname -s)" != "Linux" ]; then
  fail "This installer only supports Linux servers."
fi

info "Brun installer starting..."

# ---- 1. Docker ----
if ! command -v docker >/dev/null 2>&1; then
  info "Docker not found, installing via get.docker.com..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
  ok "Docker installed"
else
  ok "Docker already installed"
fi

if ! docker compose version >/dev/null 2>&1; then
  fail "Docker Compose plugin not found. Please install it and re-run this script."
fi

# ---- 2. Download deployment files (NOT source code) ----
mkdir -p "$INSTALL_DIR/nginx/certs" "$INSTALL_DIR/data"
cd "$INSTALL_DIR"

info "Downloading deployment configuration..."
curl -fsSL "${RAW_BASE}/docker-compose.release.yml" -o docker-compose.yml \
  || fail "Failed to download docker-compose.yml"
curl -fsSL "${RAW_BASE}/pam.conf" -o nginx/pam.conf \
  || fail "Failed to download nginx config"
ok "Deployment configuration downloaded"

echo "[]" > data/connections.json
echo "[]" > data/users.json

# ---- 3. Generate .env ----
if [ -f .env ]; then
  info ".env already exists, keeping it as-is."
else
  info "Generating configuration..."

  read -rp "Choose an admin username [admin]: " ADMIN_USER
  ADMIN_USER=${ADMIN_USER:-admin}

  ADMIN_PASS=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c 20)
  JWT_SECRET=$(openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c 48)
  TOKEN_CIPHER_KEY=$(openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c 32)
  VNC_PW=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c 20)

  read -rp "Domain this server will be reached at [pam.brun.local]: " BRUN_DOMAIN
  BRUN_DOMAIN=${BRUN_DOMAIN:-pam.brun.local}

  cat > .env <<EOF
BRUN_IMAGE=${BRUN_IMAGE}
BRUN_VERSION=latest
BRUN_DOMAIN=${BRUN_DOMAIN}
JWT_SECRET=${JWT_SECRET}
ADMIN_USERNAME=${ADMIN_USER}
ADMIN_PASSWORD=${ADMIN_PASS}
TOKEN_CIPHER_KEY=${TOKEN_CIPHER_KEY}
WEBAPP_BROWSER_VNC_PW=${VNC_PW}
EOF
  chmod 600 .env
  ok "Configuration generated (.env, permissions restricted to root)"
fi

# shellcheck disable=SC1091
source .env

# ---- 4. TLS certificate ----
if [ ! -f nginx/certs/pam.crt ]; then
  info "Generating a self-signed TLS certificate for ${BRUN_DOMAIN}..."
  docker compose run --rm certgen
  ok "Certificate generated"
else
  ok "Certificate already exists"
fi

# ---- 5. Pull and start ----
info "Pulling images (this will NOT build anything locally)..."
docker compose pull

info "Starting Brun..."
docker compose up -d

# ---- 6. Fix recording volume permissions (guacd runs as uid 1000) ----
sleep 3
docker compose run --rm --user root --entrypoint sh guacd -c "chown -R 1000:1000 /record" >/dev/null 2>&1 || true

echo ""
ok "Brun is up and running."
echo ""
echo "  URL:      https://${BRUN_DOMAIN}"
if [ -n "${ADMIN_PASS:-}" ]; then
  echo "  Username: ${ADMIN_USER}"
  echo "  Password: ${ADMIN_PASS}"
  echo ""
  echo "  (this password is also saved in ${INSTALL_DIR}/.env — save it somewhere safe)"
fi
echo ""
echo "Add this to your DNS or /etc/hosts on the machine you'll browse from:"
echo "  <this-server-ip>   ${BRUN_DOMAIN}"
echo ""
