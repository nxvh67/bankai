# Bankai

Metteur aux normes **Coding Style Epitech (C)**. Bankai lit le rapport
d'`epiclang`, corrige ce qu'il sait corriger, et verifie apres chaque
modification qu'il n'a rien casse.

```bash
bankai src/            # corrige tout un dossier
bankai -n main.c       # montre ce qui changerait, sans rien ecrire
bankai --ai src/       # autorise l'IA a decouper les fonctions trop longues
```

## Ce qu'il corrige

| Code | Erreur |
|---|---|
| C-A3 | fichier ne finissant pas par un retour a la ligne |
| C-F8 | commentaire a l'interieur d'une fonction |
| C-G1 | entete Epitech manquant ou incomplet |
| C-G2 | lignes vides en trop entre deux fonctions |
| C-G3 | indentation des directives preprocesseur |
| C-G7 | espaces en fin de ligne |
| C-G8 | lignes vides en fin de fichier |
| C-L1, C-L2, C-L3, C-L4 | instructions, indentation, espaces, accolades |
| C-L6 | ligne vide apres les declarations |
| **C-F4** | **fonction de plus de 20 lignes** — seule regle confiee a une IA |

Les autres erreurs ne sont pas touchees : elles sont signalees, pas corrigees.

## Garde-fous

Bankai ne modifie un fichier que s'il peut prouver qu'il ne l'a pas abime :

- un fichier aux accolades desequilibrees, ou avec un `/*` jamais ferme, n'est
  jamais touche ;
- une copie `<fichier>.bak` est ecrite avant toute modification
  (`--no-backup` pour s'en passer) ;
- le resultat est recompile : s'il ajoute une erreur de compilation, ou s'il
  fait monter le nombre d'erreurs de style, il est jete et l'original est
  conserve ;
- un fichier deja conforme n'est pas reformate.

## Installation

```bash
git clone https://github.com/nxvh67/bankai.git
cd bankai
./install.sh
```

L'installeur depose le binaire dans `~/.local/bin/bankai`, installe
`clang-format` si besoin, ecrit le style Epitech dans `~/.clang-format` et
cree un modele de configuration dans `~/.config/bankai/config`. Il ne
telecharge aucune IA : `./install.sh --ollama` si tu veux un modele local.

Ensuite :

```bash
bankai --help
bankai --ai-info      # montre quelle IA sera utilisee pour C-F4
```

> **Compatibilite.** Le binaire est compile sur Ubuntu 26.04 (glibc 2.43). Sur
> une distribution plus ancienne il refusera de demarrer — l'installeur le
> detecte et le dit. Dans ce cas, ouvre une issue pour demander une version
> compilee pour ta distribution.

Prerequis : `clang-format` (installe par le script) et `epiclang` (la
Coding Style Epitech). Sans `epiclang`, Bankai corrige encore, mais perd ses
garde-fous : il ne peut plus comparer l'avant et l'apres.

## Changer l'IA utilisee pour C-F4

C-F4 demande de **comprendre** le code pour le decouper en sous-fonctions :
c'est la seule regle que Bankai delegue a un modele. Tout le reste est
deterministe et ne depend d'aucune IA — sans `--ai`, Bankai n'appelle rien.

### Les backends disponibles

| `provider` | Ce que c'est | Cle d'API | Cout |
|---|---|---|---|
| `claude-cli` | la CLI [Claude Code](https://claude.com/claude-code) installee sur ta machine | aucune | inclus dans ton abonnement Claude |
| `anthropic` | l'API Claude officielle | `ANTHROPIC_API_KEY` | a l'usage |
| `openai` | **tout service parlant le dialecte OpenAI** : OpenAI, Groq, OpenRouter, Together, Mistral, DeepSeek, llama.cpp, LM Studio... | `OPENAI_API_KEY` ou `BANKAI_API_KEY` | selon le service |
| `gemini` | l'API Google Gemini | `GEMINI_API_KEY` | palier gratuit |
| `ollama` | un modele local servi par [Ollama](https://ollama.com) | aucune | gratuit, hors ligne |

Sans configuration, Bankai choisit tout seul : la CLI `claude` si elle est
installee, sinon une cle d'API trouvee dans l'environnement, sinon Ollama.

### Trois facons de configurer, de la plus forte a la plus faible

**1. En ligne de commande**, pour un essai ponctuel :

```bash
bankai --ai --provider gemini --model gemini-2.5-flash src/
```

**2. Par variables d'environnement**, pour toute une session (ou dans ton
`~/.bashrc` pour que ce soit permanent) :

```bash
export BANKAI_PROVIDER=openai
export BANKAI_API_URL=https://api.groq.com/openai/v1
export BANKAI_API_KEY=gsk_...
export BANKAI_MODEL=llama-3.3-70b-versatile
```

| Variable | Role |
|---|---|
| `BANKAI_PROVIDER` | le backend, parmi les cinq du tableau |
| `BANKAI_MODEL` | l'identifiant du modele |
| `BANKAI_API_KEY` | la cle, quel que soit le fournisseur |
| `BANKAI_API_URL` | l'URL de base (service compatible OpenAI, Ollama distant) |
| `BANKAI_CLI` | le nom de la CLI a lancer pour `claude-cli` (defaut : `claude`) |
| `BANKAI_CONFIG` | un autre fichier de configuration |

**3. Par le fichier `~/.config/bankai/config`**, pour ne plus y penser :

```ini
provider = gemini
model    = gemini-2.5-flash
api_key  = AIza...
```

Les lignes vides et celles commencant par `#` sont ignorees. Les noms de cles
sont ceux des variables ci-dessus, sans le prefixe `BANKAI_` et en minuscules.

Vérifie toujours le resultat avec :

```bash
bankai --ai-info
```

```
backend  gemini
modele   gemini-2.5-flash
url      https://generativelanguage.googleapis.com/v1beta
cle      definie
config   /home/toi/.config/bankai/config (lu)
etat     pret
```

### Ou prendre une cle, et quel modele demander

Les identifiants de modeles changent souvent et les anciens sont retires :
prends le nom dans la liste du fournisseur plutot que de recopier un exemple.

| Fournisseur | Cle | Liste des modeles |
|---|---|---|
| Claude Code (CLI) | rien a faire | `claude --help` ; laisse `model` vide pour utiliser celui de ta session |
| Anthropic | [console.anthropic.com](https://console.anthropic.com/settings/keys) | `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5` (le moins cher) |
| Google Gemini | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) | [ai.google.dev/gemini-api/docs/models](https://ai.google.dev/gemini-api/docs/models) |
| Groq | [console.groq.com/keys](https://console.groq.com/keys) | [console.groq.com/docs/models](https://console.groq.com/docs/models) |
| OpenRouter | [openrouter.ai/keys](https://openrouter.ai/keys) | [openrouter.ai/models](https://openrouter.ai/models) |
| OpenAI | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | [platform.openai.com/docs/models](https://platform.openai.com/docs/models) |
| Ollama (local) | rien a faire | `ollama list` ; `ollama pull qwen2.5-coder:7b` |

Pour Groq, OpenRouter et les autres services compatibles OpenAI, le backend est
`openai` et c'est `BANKAI_API_URL` qui designe le service :

| Service | `BANKAI_API_URL` |
|---|---|
| OpenAI | `https://api.openai.com/v1` (defaut) |
| Groq | `https://api.groq.com/openai/v1` |
| OpenRouter | `https://openrouter.ai/api/v1` |
| Together | `https://api.together.xyz/v1` |
| LM Studio / llama.cpp local | `http://localhost:1234/v1` |

### Ce que l'IA peut et ne peut pas faire

La reponse du modele passe les memes garde-fous que le reste : si le decoupage
ne compile pas, desequilibre les accolades, fait monter le nombre d'erreurs de
style ou ne reduit pas le nombre de fonctions trop longues, il est **ignore**
et le code d'origine est conserve. Un petit modele local echouera souvent sur
ce test — c'est le comportement voulu : Bankai prefere ne rien faire.

Relis toujours un decoupage avant de le rendre. Tu dois pouvoir le defendre.

## Problemes courants

| Symptome | Cause |
|---|---|
| `bankai: command not found` | ouvre un nouveau terminal, ou `source ~/.bashrc` |
| `C-F4 non corrigee : aucune cle d'API` | configure un backend (section ci-dessus), ou enleve `--ai` |
| `CLI claude introuvable` | `claude-cli` est choisi mais la CLI n'est pas installee : mets un autre `provider` |
| `clang-format introuvable` | installe-le ; sans lui C-L1 a C-L4 restent en place |
| `aucun modele pour le backend X` | ce backend n'a pas de defaut : definis `BANKAI_MODEL` |
| le binaire ne demarre pas | glibc trop ancienne, voir la note de compatibilite |
| une fonction n'est pas decoupee | le decoupage a ete refuse par les garde-fous ; le message le dit |
