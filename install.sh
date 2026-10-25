#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}⚔️  Lancement de l'installation automatisée de BANKAI...${NC}"

# 1. Vérification et installation de clang-format
if ! command -v clang-format &> /dev/null; then
    echo -e "${YELLOW}📦 Installation de clang-format requise...${NC}"
    sudo apt update && sudo apt install -y clang-format
else
    echo -e "${GREEN}✅ clang-format est déjà installé.${NC}"
fi

# 2. Déploiement de la configuration de style Epitech globale
echo -e "${BLUE}⚙️  Configuration du style Epitech global (~/.clang-format)...${NC}"
cp .clang-format ~/.clang-format

# 3. Déploiement de ton binaire secret outil
echo -e "${BLUE}📂 Déploiement du moteur de nettoyage...${NC}"
cp outil ~/outil
chmod +x ~/outil

# 4. Automatisation de l'IA : Vérification et installation d'Ollama
if ! command -v ollama &> /dev/null; then
    echo -e "${YELLOW}🤖 Ollama n'est pas détecté. Installation automatique en cours...${NC}"
    # Installation silencieuse officielle d'Ollama via curl
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo -e "${GREEN}✅ Ollama est déjà présent sur la machine.${NC}"
fi

# 5. Téléchargement automatique du modèle d'IA pour l'erreur C-F4
echo -e "${BLUE}🧠 Téléchargement et mise à jour de l'IA (Qwen 1.5B)... Cela peut prendre 1 à 2 minutes.${NC}"
ollama pull qwen2.5-coder:1.5b

# 6. Configuration automatique de l'alias universel bankai
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
    if ! grep -q "alias bankai=" "$SHELL_CONFIG"; then
        echo -e "${BLUE}✨ Ajout de l'alias universel 'bankai' dans $(basename $SHELL_CONFIG)...${NC}"
        echo -e "\n# Alias universel Bankai pour la Coding Style Epitech" >> "$SHELL_CONFIG"
        echo "alias bankai=\"$HOME/outil\"" >> "$SHELL_CONFIG"
    else
        echo -e "${GREEN}✅ L'alias 'bankai' est déjà configuré dans $(basename $SHELL_CONFIG).${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Impossible de détecter .bashrc ou .zshrc.${NC}"
fi

echo -e "${GREEN}🎉 [Succès] BANKAI et son IA locale ont été installés avec succès !${NC}"
echo -e "${YELLOW}💡 Ouvre un nouveau terminal ou tape 'source $(basename $SHELL_CONFIG)' pour libérer le Bankai !${NC}"
