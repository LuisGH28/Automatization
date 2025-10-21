#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo "  Mac Dev Setup (Apple Silicon)"
echo "=============================="

append_once() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

ensure_zshrc() {
  [[ -f "$HOME/.zshrc" ]] || touch "$HOME/.zshrc"
}

ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
  echo "Advertencia: Este script está optimizado para Apple Silicon (arm64). Continúo, pero revisa rutas si usas Intel."
fi

ensure_zshrc

if ! command -v brew >/dev/null 2>&1; then
  echo "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew ya instalado. Actualizando..."
  brew update
fi

echo "Instalando iTerm2..."
brew install --cask iterm2

echo "Instalando Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh ya está instalado."
fi

echo "Instalando tema powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 2>/dev/null || true

echo "Instalando plugins zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true

install_meslo_nerd_font() {
  set -e
  echo "Instalando Meslo Nerd Font…"

  if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
    echo "Meslo Nerd Font ya instalado por brew."
    return 0
  fi

  if brew info --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
    brew install --cask font-meslo-lg-nerd-font && return 0
  else
    echo "El cask font-meslo-lg-nerd-font no está disponible en tu brew. Voy por descarga directa…"
  fi

  TMP_DIR="$(mktemp -d)"
  ZIP="$TMP_DIR/Meslo.zip"
  DEST_DIR="$HOME/Library/Fonts"  

  mkdir -p "$DEST_DIR"
  echo "Descargando Meslo.zip (Nerd Fonts release)…"
  curl -fL \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" \
    -o "$ZIP"

  echo "Descomprimiendo…"
  unzip -qo "$ZIP" -d "$TMP_DIR/meslo_nf"

  echo "Copiando .ttf a $DEST_DIR…"
  find "$TMP_DIR/meslo_nf" -type f -name "*.ttf" -print -exec cp {} "$DEST_DIR" \;

  echo "Verificando instalación…"
  ls "$DEST_DIR" | grep -Ei 'meslo.*nerd|meslolg.*nerd' >/dev/null && {
    echo "Meslo Nerd Font instalada en $DEST_DIR"
  } || {
    echo "No se encontraron los .ttf en $DEST_DIR. Revisa permisos."
    return 1
  }

  rm -rf "$TMP_DIR"
}

install_meslo_nerd_font
echo "Recuerda: en iTerm2 > Preferences > Profiles > Text elige 'MesloLGS Nerd Font'."

echo "Configurando ~/.zshrc..."
append_once 'export PATH="/opt/homebrew/bin:$PATH"' "$HOME/.zshrc"
append_once 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"

if ! grep -qE '^plugins=\(' "$HOME/.zshrc"; then
  append_once 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)' "$HOME/.zshrc"
else
  sed -i '' 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)/' "$HOME/.zshrc" || true
fi
append_once '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' "$HOME/.zshrc"

echo "Herramientas de productividad..."
brew install --cask rectangle
brew install --cask stats
brew install --cask raycast || true

echo "CLI útiles..."
brew install git gh wget curl jq fzf ripgrep bat htop tree

echo "Instalando Java (OpenJDK 17 LTS) + SDKMAN..."
brew install openjdk@17

append_once 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' "$HOME/.zshrc"
append_once 'export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"' "$HOME/.zshrc"

if [[ ! -d "$HOME/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
  append_once 'export SDKMAN_DIR="$HOME/.sdkman"' "$HOME/.zshrc"
  append_once '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' "$HOME/.zshrc"
fi

echo "Instalando IntelliJ IDEA CE..."
brew install --cask intellij-idea-ce

echo "Instalando pyenv y Python..."
brew install pyenv
append_once 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.zshrc"
append_once 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' "$HOME/.zshrc"
append_once 'eval "$(pyenv init -)"' "$HOME/.zshrc"

PY_VER="3.11.9"
if ! pyenv versions --bare 2>/dev/null | grep -q "$PY_VER"; then
  CFLAGS="-Wno-implicit-function-declaration" pyenv install -s "$PY_VER" || true
fi
pyenv global "$PY_VER" || true

pip3 install --upgrade pip
pip3 install numpy pandas matplotlib scipy scikit-learn jupyter jupyterlab ipykernel
pip3 install tensorflow-macos tensorflow-metal || true
pip3 install torch torchvision torchaudio || true

echo "Instalando NVM y Node LTS..."
brew install nvm

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

source "/opt/homebrew/opt/nvm/nvm.sh" || true
nvm install --lts || true
npm i -g pnpm yarn @nestjs/cli || true

echo "Instalando Flutter y Android Studio..."
brew install --cask flutter
brew install --cask android-studio

xcode-select --install 2>/dev/null || true

echo "Instalando VS Code y DB tools..."
brew install --cask visual-studio-code
brew install --cask tableplus || brew install --cask dbeaver-community

echo "Instalando Postman y Docker Desktop..."
brew install --cask postman
brew install --cask docker

echo "Instalando Kafka local..."
brew install kafka

echo "Instalando LaTeX, Obsidian y Zotero..."
brew install --cask mactex
brew install --cask obsidian
brew install --cask zotero
brew install pandoc

echo "Limpiando fórmulas obsoletas..."
brew cleanup

echo ""
echo "==========================================="
echo "  Listo. Cierra y reabre tu terminal."
echo "  Siguientes pasos recomendados:"
echo "    1) Abre iTerm2 y selecciona la fuente: MesloLGS Nerd Font"
echo "    2) Powerlevel10k lanzará un asistente la primera vez"
echo "    3) Android Studio -> abre y deja que instale SDKs/Emuladores"
echo "    4) Docker Desktop -> abre y acepta permisos"
echo "==========================================="

