# Mac Development Setup — Apple Silicon

A fully automated Bash script for setting up a **complete development environment** on macOS (Apple Silicon).

It installs CLI tools, IDEs, SDKs, a modern Zsh configuration with Oh My Zsh and Powerlevel10k, fonts, and essential productivity utilities.

>  **Compatibility:** Optimized for  **Apple Silicon (arm64)** .
>
> It also works on Intel-based Macs, but you may need to adjust Homebrew paths (`/usr/local` vs `/opt/homebrew`).

---

## Table of Contents

* [Requirements](#requirements)
* [Quick Installation](#quick-installation)
* [What It Installs](#what-it-installs)
* [Automatic Configuration](#automatic-configuration)
* [Quick Verification](#quick-verification)
* [Post-Installation Steps](#post-installation-steps)
* [Troubleshooting](#troubleshooting)
* [Customization](#customization)
* [Uninstallation](#uninstallation)
* [License](#license)

---

## Requirements

* macOS Ventura (13) or newer
* Internet connection
* Permissions to install system applications (may prompt for your password)

---

## Quick Installation

```text
chmod +x setup.sh
./setup.sh
```

This script will:

* Install or update **Homebrew**
* Configure **Zsh** with **Oh My Zsh** and **Powerlevel10k**
* Install **Meslo Nerd Fonts**
* Add environment variables to your `~/.zshrc`
* Install all tools and SDKs listed below

---

##  What It Installs

### Terminal & Shell

* **iTerm2**
* **Oh My Zsh**
* **Powerlevel10k** theme
* **zsh-autosuggestions** , **zsh-syntax-highlighting**
* **MesloLGS Nerd Font**

### CLI Tools

* `git`, `gh`, `wget`, `curl`, `jq`, `fzf`, `ripgrep`, `bat`, `htop`, `tree`

### Java & SDKs

* **OpenJDK 17 (LTS)**
* **SDKMAN!** configured in `~/.zshrc`

### Python & Data Science

* **pyenv** with **Python 3.11.9**
* Packages: `numpy`, `pandas`, `matplotlib`, `scipy`, `scikit-learn`,

  `jupyter`, `jupyterlab`, `ipykernel`, `tensorflow-macos`, `torch`

### Node.js / JavaScript

* **nvm** with latest **Node LTS**
* Global tools: `pnpm`, `yarn`, `@nestjs/cli`

###   IDEs & GUI Tools

* **IntelliJ IDEA CE**
* **Visual Studio Code**
* **Flutter** & **Android Studio**
* **TablePlus** (or DBeaver)
* **Postman**
* **Docker Desktop**

###  Productivity & Utilities

* **Rectangle** (window manager)
* **Stats** (system monitor)
* **Raycast**
* **Kafka** (local)
* **MacTeX (LaTeX)**
* **Obsidian** ,  **Zotero** , **Pandoc**

---

## Automatic Configuration

The script automatically:

* Updates your `~/.zshrc` with new paths and plugins
* Sets **Powerlevel10k** as the default theme
* Installs and enables **Meslo Nerd Font**
* Runs `brew cleanup` at the end to remove obsolete packages

---

## Quick Verification

After installation, open a new terminal (or run `source ~/.zshrc`):

```text
brew --version
java -version
python --version
node -v
flutter --version
docker --version
```

If all commands return valid versions, your setup is complete 

---

## Post-Installation Steps

1. In  **iTerm2 → Preferences → Profiles → Text** , choose `MesloLGS Nerd Font`.
2. The **Powerlevel10k** setup wizard will start the first time you open your terminal.
3. Launch **Android Studio** and let it install SDKs and emulators.
4. Open **Docker Desktop** and grant permissions when prompted.
5. Personalize **VS Code** or **IntelliJ** with your preferred extensions.

---

## Troubleshooting

**Homebrew not found:**

```text
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Meslo font missing:**

Verify `.ttf` files exist in `~/Library/Fonts`.

Restart iTerm2 and reselect  *MesloLGS Nerd Font* .

**Python build fails:**

Make sure Xcode Command Line Tools are installed:

```text
xcode-select --install
```

**Kafka doesn’t start:**

Run:

```text
brew services start kafka
tail -f ~/Library/Logs/Homebrew/kafka/*.log
```

---

## Customization

You can tailor the setup by editing the script:

* Comment out sections (e.g., Flutter or LaTeX)
* Change versions (`PY_VER="3.11.9"`)
* Add more plugins or packages
* Future improvement idea: use environment variables like

  `SKIP_FLUTTER=1`, `SKIP_LATEX=1` for modular execution

---

## Uninstallation

To remove installed apps and tools:


```text
brew uninstall --cask iterm2 raycast rectangle stats \
  intellij-idea-ce visual-studio-code android-studio \
  postman docker obsidian zotero mactex

brew uninstall git gh jq fzf ripgrep bat htop tree kafka nvm pyenv openjdk@17 flutter pandoc
brew cleanup
```

> You may also remove lines from your `~/.zshrc` and delete `~/.oh-my-zsh` if you want a clean reset.

---

## License

This project is released under the  **MIT License** .

You are free to use, modify, and distribute it for personal or professional setups.
