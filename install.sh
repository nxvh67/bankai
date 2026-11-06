#!/bin/bash
# Installeur de Bankai. Idempotent : relancer ce script ne casse rien.

set -u

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/bankai"
CONFIG_DIR="$HOME/.config/bankai"
CONFIG_PATH="$CONFIG_DIR/config"
WANT_OLLAMA=0

for argument in "$@"; do
    case "$argument" in
        --ollama) WANT_OLLAMA=1 ;;
        -h|--help)
            echo "Usage: ./install.sh [--ollama]"
            echo "  --ollama  installe aussi Ollama et un modele local pour C-F4"
            exit 0 ;;
        *) echo -e "${RED}Option inconnue : $argument${NC}"; exit 2 ;;
    esac
done

echo -e "${BLUE}Installation de BANKAI...${NC}"

# 1. clang-format : Bankai s'en sert pour l'indentation et les accolades.
if command -v clang-format > /dev/null 2>&1; then
    echo -e "${GREEN}[ok]${NC} clang-format deja installe."
else
    echo -e "${YELLOW}[..]${NC} Installation de clang-format..."
    if command -v apt > /dev/null 2>&1; then
        sudo apt update && sudo apt install -y clang-format
    elif command -v dnf > /dev/null 2>&1; then
        sudo dnf install -y clang-tools-extra
    elif command -v pacman > /dev/null 2>&1; then
        sudo pacman -S --noconfirm clang
    elif command -v zypper > /dev/null 2>&1; then
        sudo zypper install -y clang-tools
    else
        echo -e "${RED}[!!]${NC} Gestionnaire de paquets inconnu."
        echo "     Installe clang-format a la main, sinon C-L1 a C-L4 ne"
        echo "     seront pas corrigees."
    fi
fi

# 2. epiclang sert aux garde-fous : sans lui Bankai corrige encore, mais ne
#    peut plus verifier qu'il n'a rien casse. On avertit sans bloquer.
if ! command -v epiclang > /dev/null 2>&1; then
    echo -e "${YELLOW}[!]${NC} epiclang introuvable : Bankai ne pourra pas verifier"
    echo "    que ses corrections n'ajoutent pas d'erreur. Installe-le pour"
    echo "    profiter des garde-fous."
fi

# 3. Style Epitech pour clang-format, sans ecraser une version differente.
if [ -f "$HOME/.clang-format" ] && \
   ! cmp -s "$SOURCE_DIR/.clang-format" "$HOME/.clang-format"; then
    cp "$HOME/.clang-format" "$HOME/.clang-format.bak"
    echo -e "${YELLOW}[!]${NC} ~/.clang-format existait : copie dans ~/.clang-format.bak"
fi
cp "$SOURCE_DIR/.clang-format" "$HOME/.clang-format"
echo -e "${GREEN}[ok]${NC} Style Epitech deploye dans ~/.clang-format"

# 4. Le binaire.
mkdir -p "$BIN_DIR"
cp "$SOURCE_DIR/outil" "$BIN_PATH"
chmod +x "$BIN_PATH"
echo -e "${GREEN}[ok]${NC} Binaire installe dans $BIN_PATH"

# 5. Il est compile sur une machine donnee : on verifie qu'il demarre ici
#    avant de promettre quoi que ce soit.
if ! "$BIN_PATH" --help > /dev/null 2>&1; then
    echo -e "${RED}[!!]${NC} Le binaire ne demarre pas sur cette machine."
    "$BIN_PATH" --help 2>&1 | head -3 | sed 's/^/     /'
    echo "     C'est en general une glibc plus ancienne que celle de la"
    echo "     machine de compilation. Demande une version compilee pour ta"
    echo "     distribution (ouvre une issue sur le depot)."
    exit 1
fi

# 6. Configuration IA, laissee en detection automatique si elle n'existe pas.
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_PATH" ]; then
    cat > "$CONFIG_PATH" <<'CONFIG'
# Configuration IA de Bankai (utilisee seulement pour l'erreur C-F4).
# Decommente et remplis ce qui te concerne. Tout est detaille dans le README.
# Priorite : options en ligne de commande > variables d'environnement > ce
# fichier > detection automatique.

# Backend : claude-cli | anthropic | openai | gemini | ollama
# provider =

# Identifiant du modele (voir le README pour chaque fournisseur).
# model =

# Cle d'API (inutile avec claude-cli et ollama).
# api_key =

# URL de base, pour un service compatible OpenAI ou un Ollama distant.
# api_url =
CONFIG
    echo -e "${GREEN}[ok]${NC} Modele de configuration ecrit dans $CONFIG_PATH"
else
    echo -e "${GREEN}[ok]${NC} Configuration existante conservee ($CONFIG_PATH)"
fi

# 7. Ollama seulement sur demande : c'est environ 1 Go de telechargement.
if [ "$WANT_OLLAMA" -eq 1 ]; then
    if ! command -v ollama > /dev/null 2>&1; then
        echo -e "${YELLOW}[..]${NC} Installation d'Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi
    echo -e "${YELLOW}[..]${NC} Telechargement du modele qwen2.5-coder:7b..."
    ollama pull qwen2.5-coder:7b
    sed -i 's/^# provider =.*/provider = ollama/' "$CONFIG_PATH"
    sed -i 's/^# model =.*/model = qwen2.5-coder:7b/' "$CONFIG_PATH"
    echo -e "${GREEN}[ok]${NC} Backend ollama inscrit dans $CONFIG_PATH"
fi

# 8. PATH. ~/.local/bin est standard mais pas toujours actif.
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

case ":$PATH:" in
    *":$BIN_DIR:"*)
        echo -e "${GREEN}[ok]${NC} $BIN_DIR est deja dans le PATH." ;;
    *)
        if [ -n "$SHELL_CONFIG" ]; then
            if ! grep -q 'bankai: PATH' "$SHELL_CONFIG" 2>/dev/null; then
                printf '\n# bankai: PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' \
                    >> "$SHELL_CONFIG"
            fi
            echo -e "${GREEN}[ok]${NC} PATH complete dans $(basename "$SHELL_CONFIG")"
        else
            echo -e "${YELLOW}[!]${NC} Ajoute $BIN_DIR a ton PATH a la main."
        fi ;;
esac

echo
echo -e "${GREEN}BANKAI est installe.${NC}"
if [ -n "$SHELL_CONFIG" ]; then
    echo -e "Ouvre un nouveau terminal, ou : ${BLUE}source $SHELL_CONFIG${NC}"
fi
echo -e "Ensuite : ${BLUE}bankai --help${NC} puis ${BLUE}bankai --ai-info${NC}"
