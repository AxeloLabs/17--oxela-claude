DÉBUT initialisation

- Capturer timestamp de début (format ISO 8601)
- Créer variable globale STATUS = "OK"
- Initialiser structure de données pour stocker résultats :
  - config_results = {}
  - git_results = {}
  - build_results = {}
  - test_results = {}
  - emulator_results = {}
  - deploy_results = {}
- Détecter la racine du projet (remonter jusqu'à trouver turbo.json ou package.json avec workspaces)
- Créer répertoire de sortie si inexistant : /apps/admin/reports/ ou /superdev/reports/
- Initialiser fichier de log temporaire : /tmp/titanic-health-TIMESTAMP.log
  FIN initialisation

```

**Commandes à exécuter** :
- `date +"%Y-%m-%dT%H:%M:%S%z"` pour timestamp
- `pwd` et navigation avec `cd` pour trouver racine
- `mkdir -p` pour créer répertoire reports
- `mktemp` pour fichier log temporaire

**Format de résultat** : Variables d'environnement shell initialisées

---

### PHASE 1 : Configuration Firebase

**Action** : Auditer la configuration Firebase du projet

#### 1.1 Détection des fichiers de configuration

**Pseudo-code** :
```

DÉBUT détection_config

- Rechercher dans la racine du projet :

  - firebase.json (obligatoire)
  - .firebaserc (obligatoire)
  - firestore.rules
  - firestore.indexes.json
  - storage.rules
  - database.rules.json

- Rechercher dans apps/admin/, apps/dashboard/, apps/public/ :

  - .env
  - .env.local
  - .env.production
  - next.config.js ou vite.config.js (selon framework)
  - firebase-config.ts ou firebaseConfig.js

- Rechercher dans packages/ :

  - Tout fichier contenant "firebase" dans son nom
  - Fichiers de configuration partagés

- Pour chaque fichier trouvé :
  _ Enregistrer chemin absolu
  _ Vérifier lisibilité (permissions)
  _ Capturer date de dernière modification
  _ Marquer comme TROUVÉ ou MANQUANT
  FIN détection_config

```

**Commandes à exécuter** :
- `find . -name "firebase.json" -o -name ".firebaserc"` pour fichiers racine
- `find ./apps -name ".env*" -type f` pour variables d'environnement
- `ls -l` pour permissions et dates
- `test -r` pour vérifier lisibilité

**Format de résultat dans rapport** :
```

Tableau : Fichiers de configuration Firebase
| Fichier | Chemin | Statut | Dernière modification |

```

#### 1.2 Extraction des environnements et clés

**Pseudo-code** :
```

DÉBUT extraction_environnements

- Parser .firebaserc (format JSON) :

  - Extraire tous les alias de projets (projects.\*)
  - Identifier le projet par défaut (projects.default)
  - Lister tous les projectId configurés

- Parser firebase.json :

  - Extraire projectId si présent
  - Lister services configurés (hosting, functions, firestore, storage, etc.)
  - Pour chaque service, extraire configuration clé

- Scanner tous les fichiers .env\* :

  - Extraire toutes variables commençant par FIREBASE*, NEXT_PUBLIC_FIREBASE*, VITE*FIREBASE*
  - Extraire apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId
  - Masquer les valeurs sensibles (afficher seulement premiers/derniers 4 caractères)
  - Identifier l'environnement (production, staging, dev selon nom fichier)

- Créer matrice environnements × clés détectées
  FIN extraction_environnements

```

**Commandes à exécuter** :
- `cat firebase.json | jq` pour parser JSON
- `cat .firebaserc | jq '.projects'` pour extraire projets
- `grep -r "FIREBASE_" apps/*/env*` pour scanner variables
- `sed` ou `awk` pour masquer valeurs sensibles

**Format de résultat dans rapport** :
```

Section : Environnements détectés

- Projet par défaut : [projectId]
- Projets configurés : [liste]

Tableau : Clés Firebase par application
| Application | Environnement | apiKey | projectId | authDomain | Statut |
(avec valeurs masquées : AIza\*\*\*xy89)

```

#### 1.3 Vérification de cohérence

**Pseudo-code** :
```

DÉBUT verification_coherence

- Extraire projectId de .firebaserc (default)
- Extraire projectId de firebase.json si présent
- Pour chaque .env trouvé :

  - Extraire FIREBASE_PROJECT_ID ou équivalent
  - Comparer avec projectId de référence

- Créer liste de divergences :

  - Si projectId diffère entre .firebaserc et firebase.json → WARNING
  - Si projectId diffère entre environnements → WARNING
  - Si projectId contient "demo-" ou "test-" en production → WARNING

- Vérifier présence obligatoire :

  - Si firebase.json manquant → ERROR, STATUS = "ERROR"
  - Si .firebaserc manquant → ERROR, STATUS = "ERROR"
  - Si aucune apiKey détectée → WARNING
  - Si authDomain ne correspond pas au pattern [projectId].firebaseapp.com → WARNING

- Pour chaque service dans firebase.json :
  _ Vérifier présence fichiers règles correspondants
  _ Ex : si firestore configuré, vérifier firestore.rules existe \* Si fichier manquant → WARNING
  FIN verification_coherence

```

**Commandes à exécuter** :
- `jq -r '.projects.default' .firebaserc` pour projectId de référence
- Comparaisons avec `[[ "$var1" == "$var2" ]]` en bash
- `test -f firestore.rules` pour vérifier existence fichiers

**Format de résultat dans rapport** :
```

Section : Cohérence de configuration
✓ projectId cohérent entre tous les environnements
⚠ Warning : authDomain de dashboard ne suit pas le pattern standard
✗ Error : firebase.json manquant

Liste des divergences :

- .firebaserc : my-project-prod
- apps/admin/.env : my-project-prod
- apps/dashboard/.env.local : my-project-dev (DIVERGENCE)

```

**Appel à Gemini si erreurs critiques** :
```

SI firebase.json OU .firebaserc manquant ALORS
Proposer à l'utilisateur :
"Configuration Firebase incomplète détectée. Voulez-vous que Gemini génère les fichiers manquants ? (y/n)"

SI utilisateur accepte ALORS
Envoyer à Gemini :
"Generate missing Firebase configuration files for a Turborepo project with 3 apps (admin, dashboard, public).
Project structure detected: [liste des apps trouvées].
Create firebase.json with hosting configuration for all apps and .firebaserc with default project alias.
Use placeholder project ID 'my-firebase-project'."
FIN SI

```

---

### PHASE 1.5 : État Git

**Action** : Auditer l'état du versioning et historique Git

#### 1.5.1 Vérification du statut working directory

**Pseudo-code** :
```

DÉBUT verification_git_status

- Vérifier présence dépôt Git :

  - Chercher répertoire .git à la racine
  - Si absent → WARNING et passer à phase suivante

- Exécuter équivalent de "git status --porcelain" :

  - Capturer sortie complète
  - Compter lignes commençant par "M " (modified)
  - Compter lignes commençant par "??" (untracked)
  - Compter lignes commençant par "A " (added)
  - Compter lignes commençant par "D " (deleted)
  - Compter lignes commençant par "UU" ou "AA" (conflits)

- Évaluer propreté :

  - Si aucun fichier modifié/untracked → git_status = "CLEAN"
  - Si fichiers modifiés mais pas de conflit → git_status = "DIRTY"
  - Si conflits présents → git_status = "CONFLICT", STATUS global = "ERROR"

- Lister fichiers non commités (max 20 premiers)
  FIN verification_git_status

```

**Commandes à exécuter** :
- `test -d .git` pour vérifier présence dépôt
- `git status --porcelain` pour état détaillé
- `wc -l` pour compter lignes
- `grep "^M "` pour filtrer par type

**Format de résultat dans rapport** :
```

Section : État Git
Statut : CLEAN / DIRTY / CONFLICT

- Fichiers modifiés : 12
- Fichiers non suivis : 3
- Fichiers en conflit : 0
- Fichiers supprimés : 1

Liste des fichiers non commités (max 20) :
M apps/admin/src/components/Header.tsx
M apps/dashboard/package.json
?? apps/public/temp-file.js

```

#### 1.5.2 Historique des commits récents

**Pseudo-code** :
```

DÉBUT historique_commits

- Exécuter équivalent de "git log -5 --pretty=format" :

  - Capturer hash court (7 caractères)
  - Capturer date au format "YYYY-MM-DD HH:MM"
  - Capturer nom auteur
  - Capturer message commit (première ligne)

- Pour chaque commit :

  - Enregistrer dans tableau structuré
  - Calculer ancienneté (différence avec timestamp actuel)

- Identifier dernier commit :
  _ Date du dernier commit
  _ Calculer si > 7 jours → WARNING "Projet potentiellement inactif"
  FIN historique_commits

```

**Commandes à exécuter** :
- `git log -5 --pretty=format:"%h|%ai|%an|%s"` pour historique formaté
- `git log -1 --format=%ct` pour timestamp dernier commit
- `date` pour calculs de différence

**Format de résultat dans rapport** :
```

Section : Historique récent (5 derniers commits)
Tableau :
| Hash | Date | Auteur | Message |
| a3f5d9c | 2025-10-14 15:32 | John Doe | feat: add user authentication |
| b2e4c1a | 2025-10-13 09:15 | Jane Smith | fix: resolve dashboard bug |
| ... | ... | ... | ... |

⚠ Dernier commit il y a 12 jours (inactivité détectée)

```

#### 1.5.3 Informations de branche

**Pseudo-code** :
```

DÉBUT info_branche

- Détecter branche courante (git branch --show-current)
- Lister toutes les branches locales
- Si branche courante != main ET != master → INFO
- Compter commits en avance/retard par rapport à origin (si configuré)
- Vérifier si remote configuré (git remote -v)
  FIN info_branche

```

**Commandes à exécuter** :
- `git branch --show-current` pour branche active
- `git branch -a` pour toutes les branches
- `git rev-list --count @{u}..HEAD` pour commits en avance

**Format de résultat dans rapport** :
```

Branche courante : feature/new-dashboard
Branches locales : main, develop, feature/new-dashboard
Remote : origin (https://github.com/user/repo.git)
État : 3 commits en avance sur origin/feature/new-dashboard

```

**Appel à Gemini si conflits détectés** :
```

SI git_status == "CONFLICT" ALORS
Afficher message :
"⚠️ CONFLITS GIT DÉTECTÉS - Résolution manuelle requise avant de continuer.
Fichiers en conflit : [liste]

Gemini ne peut pas résoudre automatiquement les conflits de merge.
Veuillez résoudre manuellement avec 'git status' et 'git mergetool'."

Arrêter l'exécution du script avec code sortie 1
FIN SI

```

---

### PHASE 2 : Build Check

**Action** : Vérifier la compilation des trois applications et du linting

#### 2.1 Détection de la configuration Turborepo

**Pseudo-code** :
```

DÉBUT detection_turborepo

- Vérifier présence turbo.json à la racine
- Parser turbo.json pour identifier pipeline de build :

  - Extraire tasks "build", "lint", "type-check"
  - Identifier dépendances entre tasks

- Lire package.json racine :

  - Vérifier présence de "workspaces"
  - Lister tous les workspaces (apps/_, packages/_)

- Pour chaque app (admin, dashboard, public) :
  _ Vérifier présence de package.json
  _ Identifier script "build" dans package.json
  _ Identifier framework (Next.js, Vite, CRA) via dependencies
  _ Enregistrer commande de build spécifique
  FIN detection_turborepo

```

**Commandes à exécuter** :
- `cat turbo.json | jq '.pipeline.build'` pour configuration build
- `cat package.json | jq '.workspaces'` pour workspaces
- `cat apps/admin/package.json | jq '.scripts.build'` pour script build
- `grep "next\|vite\|react-scripts"` dans dependencies pour détecter framework

**Format de résultat dans rapport** :
```

Section : Configuration Build
Turborepo détecté : ✓
Workspaces : 3 apps, 5 packages

Applications détectées :

- admin (Next.js) : npm run build --filter=admin
- dashboard (Vite) : npm run build --filter=dashboard
- public (Next.js) : npm run build --filter=public

```

#### 2.2 Build des applications (séquentiel)

**Pseudo-code** :
```

POUR CHAQUE app IN [admin, dashboard, public] FAIRE
DÉBUT build_app - Afficher message : "Building [app]..." - Capturer timestamp début build

    - Exécuter commande : turbo run build --filter=[app]
      OU : npm run build --workspace=apps/[app]
      * Rediriger stdout vers fichier temporaire : /tmp/build-[app].log
      * Rediriger stderr vers même fichier
      * Capturer code de sortie

    - Capturer timestamp fin build
    - Calculer durée : fin - début

    - Analyser fichier log :
      * Compter occurrences de "error" (case insensitive) → nombre_erreurs
      * Compter occurrences de "warning" (case insensitive) → nombre_warnings
      * Extraire dernières 50 lignes pour inclusion dans rapport

    - Évaluer résultat :
      * Si code sortie == 0 ET nombre_erreurs == 0 → build_status = "SUCCESS"
      * Si code sortie == 0 ET nombre_erreurs > 0 → build_status = "SUCCESS_WITH_WARNINGS"
      * Si code sortie != 0 → build_status = "FAILED", STATUS global = "ERROR"

    - Enregistrer dans build_results[app] :
      * status : build_status
      * duration : durée en secondes
      * errors : nombre_erreurs
      * warnings : nombre_warnings
      * log_path : chemin du fichier log

FIN build_app
FIN POUR

```

**Commandes à exécuter** :
- `turbo run build --filter=admin 2>&1 | tee /tmp/build-admin.log ; echo ${PIPESTATUS[0]}` pour build avec capture
- `date +%s` pour timestamps
- `grep -i "error" /tmp/build-admin.log | wc -l` pour compter erreurs
- `tail -n 50 /tmp/build-admin.log` pour extraire fin de log

**Format de résultat dans rapport** :
```

Section : Build des applications

Tableau récapitulatif :
| Application | Statut | Durée | Erreurs | Warnings |
| admin | ✓ SUCCESS | 45s | 0 | 3 |
| dashboard | ✗ FAILED | 12s | 5 | 8 |
| public | ✓ SUCCESS | 38s | 0 | 1 |

Détails dashboard (FAILED) :
[Afficher extrait du log avec les 5 premières erreurs]

```

**Appel à Gemini si build échoue** :
```

SI build_status == "FAILED" POUR n'importe quelle app ALORS
Proposer à l'utilisateur :
"❌ Build de [app] a échoué avec [X] erreurs.

Voulez-vous que Gemini analyse et corrige automatiquement les erreurs ? (y/n)

Les erreurs seront envoyées à Gemini avec le contexte du projet."

SI utilisateur accepte ALORS - Extraire les 20 premières lignes contenant "error" du log - Identifier les fichiers sources mentionnés dans les erreurs

    Envoyer à Gemini :
    "Fix the following build errors in the [app] application of a Turborepo project.

    Build command used: turbo run build --filter=[app]
    Framework detected: [Next.js/Vite/etc]

    Build errors:
    [Coller extrait du log avec erreurs]

    Analyze the errors, identify the root causes, and provide:
    1. Exact file paths that need modification
    2. Code changes needed (as diffs or complete file content)
    3. Explanation of what caused each error

    Context: This is part of an automated health check script."

    - Attendre réponse Gemini
    - Afficher réponse à l'utilisateur
    - Proposer d'appliquer les corrections automatiquement

FIN SI
FIN SI

```

#### 2.3 Linting global

**Pseudo-code** :
```

DÉBUT linting_global

- Vérifier présence d'ESLint :

  - Chercher .eslintrc.\* ou eslint.config.js à la racine
  - Vérifier script "lint" dans package.json racine

- SI ESLint configuré ALORS

  - Exécuter : turbo run lint
    OU : npm run lint

    - Rediriger vers /tmp/lint.log
    - Capturer code de sortie

  - Analyser log :

    - Extraire nombre de fichiers vérifiés (parsing sortie ESLint)
    - Compter problèmes par sévérité :
      - Errors (rouge)
      - Warnings (jaune)
    - Extraire règles les plus violées (top 5)

  - Évaluer :
    - Si code sortie == 0 → lint_status = "PASSED"
    - Si warnings > 0 mais errors == 0 → lint_status = "WARNINGS", STATUS global = "WARNING"
    - Si errors > 0 → lint_status = "FAILED", STATUS global = "ERROR"

SINON
lint_status = "NOT_CONFIGURED"
FIN SI

- Enregistrer dans build_results.lint
  FIN linting_global

```

**Commandes à exécuter** :
- `find . -name ".eslintrc*" -o -name "eslint.config.js"` pour détecter ESLint
- `turbo run lint 2>&1 | tee /tmp/lint.log ; echo ${PIPESTATUS[0]}`
- `grep -E "✖ [0-9]+ problem" /tmp/lint.log` pour parser résultats ESLint
- Expression régulière pour extraire règles violées

**Format de résultat dans rapport** :
```

Section : Linting (ESLint)
Statut : WARNINGS
Fichiers vérifiés : 247
Erreurs : 0
Warnings : 15

Règles les plus violées :

1. @typescript-eslint/no-explicit-any (8 occurrences)
2. react-hooks/exhaustive-deps (4 occurrences)
3. no-console (3 occurrences)

[Bouton : Voir log complet]

```

**Appel à Gemini si linting échoue avec erreurs** :
```

SI lint_status == "FAILED" ALORS
Proposer :
"⚠️ Linting a détecté [X] erreurs critiques.

Gemini peut analyser et suggérer des corrections. Continuer ? (y/n)"

SI accepté ALORS
Envoyer à Gemini :
"Fix ESLint errors in Turborepo project.

    Lint output:
    [Extrait avec les 30 premières erreurs du log]

    For each error:
    1. Identify file and line number
    2. Explain the rule violation
    3. Provide fixed code snippet

    Focus on errors only, ignore warnings for now."

FIN SI

```

---

### PHASE 3 : Tests

**Action** : Auditer la couverture et santé des tests

#### 3.1 Détection des frameworks de test

**Pseudo-code** :
```

DÉBUT detection_test_frameworks

- Scanner package.json de toutes les apps et packages :
  - Chercher dans devDependencies :
    - jest, @types/jest → jest_detected = true
    - vitest → vitest_detected = true
    - @playwright/test → playwright_detected = true
    - cypress → cypress_detected = true
- Pour chaque framework détecté :

  - Identifier fichiers de configuration (jest.config.js, vitest.config.ts, etc.)
  - Identifier script de test dans package.json ("test", "test:unit", "test:e2e")

- Scanner structure fichiers de test :

  - Chercher fichiers _.test.ts, _.test.tsx, _.spec.ts, _.spec.tsx
  - Chercher fichiers dans répertoires **tests**/, tests/, e2e/
  - Compter nombre total de fichiers de test

- Créer matrice : \* [app/package] × [framework] × [nombre de fichiers]
  FIN detection_test_frameworks

```

**Commandes à exécuter** :
- `find . -name "package.json" -exec grep -l "jest\|vitest\|playwright" {} \;`
- `find . -name "*.test.ts" -o -name "*.spec.ts" -o -name "*.test.tsx" -o -name "*.spec.tsx"`
- `cat package.json | jq '.scripts | to_entries[] | select(.value | contains("test"))'`

**Format de résultat dans rapport** :
```

Section : Frameworks de test détectés

- Jest : ✓ (apps/admin, apps/dashboard, packages/shared)
- Vitest : ✓ (apps/public)
- Playwright : ✓ (apps/admin - E2E)
- Cypress : ✗

Fichiers de test : 89 fichiers

- Unit tests : 67
- Integration tests : 15
- E2E tests : 7

```

#### 3.2 Inventaire des tests par fichier

**Pseudo-code** :
```

DÉBUT inventaire_tests

- Pour chaque fichier de test trouvé :

  - Lire contenu du fichier
  - Parser pour identifier blocs :
    - describe('...') ou suite('...')
    - test('...') ou it('...')
  - Construire arborescence :
    fichier
    → describe 1
    → test 1.1
    → test 1.2
    → describe 2
    → test 2.1

  - Compter :
    - Nombre de describe/suite par fichier
    - Nombre de test/it par fichier
    - Tests avec .skip ou .todo → marquer comme SKIPPED

- Calculer statistiques globales :
  _ Total de suites
  _ Total de tests \* Tests actifs vs skipped
  FIN inventaire_tests

```

**Commandes à exécuter** :
- `grep -n "describe\|suite\|test\|it" [fichier_test]` pour extraire blocs
- Expression régulière pour parser : `(describe|suite|test|it)\s*\(\s*['"]([^'"]+)['"]`
- `grep -c "\.skip\|\.todo"` pour tests skipped

**Format de résultat dans rapport** :
```

Section : Inventaire des tests

Tableau par fichier (top 10 par nombre de tests) :
| Fichier | Suites | Tests actifs | Tests skipped |
| apps/admin/src/components/Header.test.tsx | 3 | 12 | 2 |
| apps/dashboard/src/utils/auth.test.ts | 2 | 8 | 0 |
| ... | ... | ... | ... |

Total : 247 tests (225 actifs, 22 skipped) dans 34 suites

```

#### 3.3 Exécution des tests

**Pseudo-code** :
```

POUR CHAQUE framework détecté FAIRE
DÉBUT execution_tests - Identifier commande de test appropriée :
_ Jest : turbo run test --filter=[workspace] -- --json --outputFile=/tmp/jest-results.json
_ Vitest : vitest run --reporter=json --outputFile=/tmp/vitest-results.json \* Playwright : playwright test --reporter=json

    - Capturer timestamp début
    - Exécuter commande de test :
      * Rediriger stdout vers /tmp/test-[framework]-output.log
      * Rediriger stderr vers même fichier
      * Capturer code de sortie
    - Capturer timestamp fin
    - Calculer durée totale

    - Parser résultats JSON (si disponible) :
      * Nombre total de tests exécutés
      * Nombre de tests passés (success)
      * Nombre de tests échoués (failed)
      * Nombre de tests skipped
      * Durée d'exécution de chaque test
      * Calculer durée moyenne
      * Identifier tests les plus lents (top 5)

    - SI pas de JSON, parser sortie texte :
      * Chercher patterns "X passed", "Y failed", "Z tests"
      * Extraire avec regex

    - Pour chaque test échoué :
      * Extraire nom du test
      * Extraire message d'erreur
      * Extraire stack trace (10 premières lignes)
      * Identifier fichier et ligne

    - Évaluer :
      * Si tous tests passés → test_status = "PASSED"
      * Si tests échoués > 0 → test_status = "FAILED", STATUS global = "ERROR"
      * Si aucun test exécuté → test_status = "NO_TESTS", WARNING

    - Enregistrer dans test_results[framework]

FIN execution_tests
FIN POUR

- Calculer statistiques globales toutes frameworks :
  - Total tests exécutés
  - Taux de réussite (%)
  - Durée totale d'exécution
  - Temps moyen par test

```

**Commandes à exécuter** :
- `turbo run test 2>&1 | tee /tmp/test-output.log ; echo ${PIPESTATUS[0]}`
- `cat /tmp/jest-results.json | jq '.numPassedTests'` pour parser JSON
- `grep -E "Tests:.*passed.*failed" /tmp/test-output.log` pour parser sortie texte
- `awk` pour calculer moyennes et statistiques

**Format de résultat dans rapport** :
```

Section : Résultats des tests

Tableau récapitulatif :
| Framework | Tests exécutés | Réussis | Échoués | Skipped | Durée | Taux réussite |
| Jest | 156 | 152 | 4 | 8 | 34.2s | 97.4% |
| Vitest | 42 | 42 | 0 | 2 | 8.7s | 100% |
| Playwright | 12 | 11 | 1 | 0 | 45.3s | 91.7% |
| TOTAL | 210 | 205 | 5 | 10 | 88.2s | 97.6% |

Tests échoués (5) :

1. apps/admin - Header component > should render logo
   Erreur : Expected element to have src="/logo.png" but got "/assets/logo.png"
   Fichier : apps/admin/src/components/Header.test.tsx:42
2. apps/dashboard - Authentication > login with invalid credentials
   Erreur : NetworkError: Failed to fetch
   Fichier : apps/dashboard/src/utils/auth.test.ts:78
   [...]

Tests les plus lents (top 5) :

1. E2E full user journey (12.4s)
2. Database migration test (5.8s)
3. Image upload with compression (3.2s)
   [...]

[Section logs détaillés pliable]
SI test_status == "FAILED" POUR n'importe quel framework ALORS
Proposer à l'utilisateur :
"❌ [X] test(s) ont échoué.

Voulez-vous que Gemini analyse et corrige automatiquement les tests échoués ? (y/n)

Gemini analysera les erreurs et proposera des corrections."

SI utilisateur accepte ALORS - Pour chaque test échoué (max 10 premiers) : \* Extraire contexte complet : - Nom du test - Fichier et ligne - Message d'erreur - Stack trace - Code du test (bloc describe/test complet)

    Envoyer à Gemini :
    "Fix the following failed tests in a Turborepo Firebase project.

    Test framework: [Jest/Vitest/Playwright]
    Total failed: [X] tests

    Failed tests details:

    TEST 1:
    File: [chemin]
    Test name: [nom]
    Error: [message]
    Stack trace:
    [stack trace]

    Test code:

```typescript
    [code du test complet]
```

    TEST 2:
    [...]

    For each failed test:
    1. Analyze the error and identify root cause
    2. Determine if it's a test issue or application code issue
    3. Provide corrected test code OR application code fix
    4. Explain what was wrong and why the fix works

    Consider common issues:
    - Async/await problems
    - Mock/stub configuration
    - Timing issues in tests
    - Changed API responses
    - Environment variables
    - Firebase emulator connectivity"

    - Attendre réponse Gemini
    - Afficher corrections proposées
    - Demander confirmation avant application

    SI utilisateur confirme application ALORS
      Pour chaque correction :
        - Sauvegarder backup du fichier original
        - Appliquer les modifications
        - Ré-exécuter le test spécifique
        - Rapporter succès/échec
    FIN SI

FIN SI
FIN SI

```

---

### PHASE 4 : Firebase Emulators

**Action** : Vérifier la configuration et le fonctionnement des émulateurs Firebase

#### 4.1 Identification des émulateurs configurés

**Pseudo-code** :
```

DÉBUT identification_emulateurs

- Parser firebase.json section "emulators" :

  - Extraire configuration pour chaque émulateur :

    - auth : { host, port }
    - firestore : { host, port }
    - functions : { host, port }
    - storage : { host, port }
    - hosting : { host, port }
    - pubsub : { host, port }
    - database : { host, port }
    - ui : { enabled, port }

  - Pour chaque émulateur configuré :
    - Enregistrer nom
    - Enregistrer port
    - Vérifier si port est dans range valide (1024-65535)
    - Marquer comme CONFIGURÉ

- Scanner package.json pour scripts d'émulateurs :

  - Chercher scripts contenant "emulators" ou "firebase emulators"
  - Identifier scripts : emulators:start, emulators:export, etc.
  - Extraire commandes exactes

- Vérifier présence de données seed :

  - Chercher répertoire emulator-data/ ou firebase-export/
  - Si présent, lister contenu (firestore, auth, storage)
  - Calculer taille des données seed

- Créer inventaire complet des émulateurs
  FIN identification_emulateurs

```

**Commandes à exécuter** :
- `cat firebase.json | jq '.emulators'` pour parser configuration
- `cat package.json | jq '.scripts | to_entries[] | select(.key | contains("emulator"))'`
- `find . -name "firebase-export" -o -name "emulator-data" -type d`
- `du -sh firebase-export/` pour taille données seed
- `lsof -i :PORT` pour vérifier si port déjà utilisé

**Format de résultat dans rapport** :
```

Section : Configuration des émulateurs Firebase

Émulateurs configurés :
Tableau :
| Émulateur | Port | Statut configuration | Port disponible |
| Auth | 9099 | ✓ Configuré | ✓ Libre |
| Firestore | 8080 | ✓ Configuré | ✗ Occupé (PID 12345) |
| Functions | 5001 | ✓ Configuré | ✓ Libre |
| Storage | 9199 | ✓ Configuré | ✓ Libre |
| Hosting | 5000 | ✓ Configuré | ✓ Libre |
| UI | 4000 | ✓ Configuré | ✓ Libre |

Scripts package.json :

- emulators:start → firebase emulators:start --import=./firebase-export
- emulators:export → firebase emulators:export ./firebase-export

Données seed détectées :
✓ firebase-export/ (156 MB)

- Firestore : 1,247 documents
- Auth : 45 utilisateurs
- Storage : 23 fichiers

```

**Détection de conflits de ports** :
```

POUR CHAQUE émulateur configuré FAIRE

- Extraire port configuré
- Vérifier disponibilité : lsof -i :PORT

SI port occupé ALORS - Identifier processus utilisant le port (PID, nom) - Vérifier si c'est Firebase CLI déjà lancé

    SI processus == firebase emulators ALORS
      emulator_running_status[émulateur] = "ALREADY_RUNNING"
    SINON
      emulator_running_status[émulateur] = "PORT_CONFLICT"
      STATUS global = "WARNING"

      Enregistrer conflit :
        - Port : X
        - Processus : [nom] (PID [Y])
        - Recommandation : "Arrêter processus ou changer port dans firebase.json"
    FIN SI

SINON
emulator_running_status[émulateur] = "PORT_AVAILABLE"
FIN SI
FIN POUR

```

#### 4.2 Démarrage des émulateurs (optionnel)

**Pseudo-code** :
```

DÉBUT demarrage_emulateurs
Proposer à l'utilisateur :
"Voulez-vous démarrer les émulateurs Firebase pour vérifier leur bon fonctionnement ? (y/n)

Cette opération peut prendre 30-60 secondes."

SI utilisateur accepte ALORS - Vérifier qu'aucun conflit de port n'existe

    SI conflits détectés ALORS
      Afficher : "⚠️ Conflits de ports détectés. Veuillez résoudre avant de démarrer."
      Passer à phase suivante
      RETOUR
    FIN SI

    - Capturer timestamp début
    - Identifier commande de démarrage :
      * Depuis package.json script "emulators:start"
      * OU : firebase emulators:start --project=[projectId]
      * Ajouter flags : --only=[liste émulateurs] --import=[chemin seed data si existe]

    - Lancer émulateurs en arrière-plan :
      * Exécuter commande avec & pour background
      * Rediriger stdout vers /tmp/emulators-startup.log
      * Rediriger stderr vers même fichier
      * Capturer PID du processus

    - Attendre démarrage (polling) :
      POUR i de 1 à 60 (max 60 secondes) FAIRE
        - Attendre 1 seconde
        - Vérifier si Emulator UI répond (curl http://localhost:4000)

        SI réponse 200 ALORS
          emulators_started = true
          SORTIR de la boucle
        FIN SI
      FIN POUR

    - SI emulators_started == false ALORS
      emulators_status = "FAILED_TO_START"
      STATUS global = "ERROR"

      - Tuer processus (kill PID)
      - Extraire erreurs du log
      - Enregistrer dans rapport
    SINON
      emulators_status = "RUNNING"
      - Capturer timestamp fin (temps de démarrage)
    FIN SI

    - Vérifier disponibilité de chaque émulateur :
      POUR CHAQUE émulateur configuré FAIRE
        - Tenter connexion HTTP : curl http://localhost:[PORT]

        SI réponse ALORS
          emulator_health[émulateur] = "HEALTHY"
        SINON
          emulator_health[émulateur] = "UNREACHABLE"
          STATUS global = "WARNING"
        FIN SI
      FIN POUR

    - Capturer logs de démarrage :
      * Lire /tmp/emulators-startup.log
      * Extraire lignes importantes :
        - "All emulators ready"
        - Messages d'erreur ou warnings
        - Ports effectivement utilisés
        - Données importées

    - À la fin de l'audit :
      Proposer : "Voulez-vous arrêter les émulateurs ? (y/n)"
      SI oui ALORS kill [PID]

SINON
emulators_status = "NOT_STARTED"
Note : "Démarrage des émulateurs non effectué (choix utilisateur)"
FIN SI
FIN demarrage_emulateurs

```

**Commandes à exécuter** :
- `firebase emulators:start --project=demo-project --only=auth,firestore,functions --import=./firebase-export > /tmp/emulators-startup.log 2>&1 &`
- `echo $!` pour capturer PID
- `curl -s -o /dev/null -w "%{http_code}" http://localhost:4000` pour vérifier UI
- `curl -s http://localhost:9099` pour vérifier Auth
- `tail -f /tmp/emulators-startup.log` pour suivre logs
- `kill [PID]` pour arrêter

**Format de résultat dans rapport** :
```

Section : Santé des émulateurs

Statut global : RUNNING (démarrage en 23s)

État des émulateurs :
Tableau :
| Émulateur | Port | Statut | Temps réponse |
| Auth | 9099 | ✓ HEALTHY | 45ms |
| Firestore | 8080 | ✓ HEALTHY | 67ms |
| Functions | 5001 | ✓ HEALTHY | 123ms |
| Storage | 9199 | ✓ HEALTHY | 34ms |
| Hosting | 5000 | ✓ HEALTHY | 12ms |
| UI | 4000 | ✓ HEALTHY | 89ms |

Logs de démarrage (extrait) :
✓ firestore: Emulator running on port 8080
✓ auth: Emulator running on port 9099
✓ functions: Emulator running on port 5001
✓ All emulators ready! It is now safe to connect.
✓ Imported 1,247 documents to Firestore
✓ Imported 45 users to Auth

[Lien : Ouvrir Emulator UI - http://localhost:4000]
[Bouton : Voir logs complets]

```

**Appel à Gemini si échec de démarrage** :
```

SI emulators_status == "FAILED_TO_START" ALORS

- Extraire erreurs critiques du log de démarrage
- Identifier type d'erreur :
  - Port déjà utilisé
  - Configuration invalide
  - Dépendances manquantes (Java, Node version)
  - Permissions insuffisantes

Proposer :
"❌ Échec du démarrage des émulateurs.

Voulez-vous que Gemini analyse les logs et propose une solution ? (y/n)"

SI accepté ALORS
Envoyer à Gemini :
"Firebase emulators failed to start in a Turborepo project.

    Firebase configuration:

```json
    [Contenu firebase.json section emulators]
```

    Startup logs:

```
    [Contenu /tmp/emulators-startup.log - 100 dernières lignes]
```

    Analyze the error and provide:
    1. Root cause identification
    2. Step-by-step fix instructions
    3. If configuration issue, provide corrected firebase.json
    4. If port conflict, suggest alternative ports
    5. If dependency issue, provide installation commands

    System: macOS, Node version: [version détectée], Firebase CLI version: [version]"

FIN SI

```

---

### PHASE 5 : Deploy Check

**Action** : Analyser la configuration de déploiement et proposer options de déploiement

#### 5.1 Détection Data Connect

**Pseudo-code** :
```

DÉBUT detection_data_connect

- Vérifier dans firebase.json section "dataconnect" :

  - SI section existe ALORS
    data_connect_configured = true
    - Extraire configuration :

      - source (chemin du schéma)
      - serviceId
      - cloudsql.instanceId
      - cloudsql.database

    - Vérifier présence du schéma :

      - Localiser fichier schema.gql ou schema.graphql dans [source]
      - SI trouvé ALORS
        - Lire contenu du schéma
        - Compter nombre de types définis
        - Compter nombre de queries définis
        - Compter nombre de mutations définies
        - Extraire liste des tables/collections principales
        schema_status = "FOUND"
        SINON
        schema_status = "MISSING"
        STATUS global = "WARNING"
        FIN SI

    - Vérifier configuration GraphQL :

      - Chercher fichier codegen.yml ou graphql.config.js
      - Vérifier présence de dossier generated/ ou **generated**/
      - SI présent ALORS graphql_codegen = "CONFIGURED"
      - SINON graphql_codegen = "NOT_CONFIGURED"

    - Vérifier connexion Cloud SQL :
      _ Parser cloudsql.instanceId
      _ Vérifier format : project:region:instance \* SI format invalide ALORS WARNING
      SINON
      data_connect_configured = false
      FIN SI

- Enregistrer résultats dans deploy_results.data_connect
  FIN detection_data_connect

```

**Commandes à exécuter** :
- `cat firebase.json | jq '.dataconnect'`
- `find . -name "schema.gql" -o -name "schema.graphql"`
- `grep -c "type " schema.gql` pour compter types
- `grep -c "query\|mutation" schema.gql` pour compter opérations
- Validation regex pour instanceId : `^[a-z0-9-]+:[a-z0-9-]+:[a-z0-9-]+$`

**Format de résultat dans rapport** :
```

Section : Data Connect

Statut : ✓ Configuré

Configuration :

- Service ID : my-dataconnect-service
- Cloud SQL Instance : my-project:us-central1:my-db-instance
- Database : production_db
- Source : ./dataconnect/

Schéma GraphQL :
✓ Trouvé : ./dataconnect/schema.gql

- 12 types définis
- 8 queries
- 6 mutations
- Tables principales : users, posts, comments, likes

GraphQL Codegen : ✓ Configuré
Generated types : ./dataconnect/**generated**/

```

#### 5.2 Détection Static Deploy (SPA/SSG)

**Pseudo-code** :
```

DÉBUT detection_static_deploy

- Parser firebase.json section "hosting" :

  - SI array ALORS multiple_sites = true
  - SI object ALORS single_site = true

- POUR CHAQUE site dans hosting FAIRE - Extraire configuration :
  _ site (nom du site)
  _ public (répertoire build)
  _ ignore (fichiers ignorés)
  _ rewrites (règles de routage)
  _ headers (en-têtes personnalisés)
  _ redirects
      - Identifier application correspondante :
        * Comparer "public" avec structure apps/
        * Ex : "public": "apps/admin/out" → app = admin
        * Ex : "public": "apps/public/dist" → app = public

      - Détecter type de build :
        * SI répertoire = "out" ou contient "_next" → type = "Next.js SSG"
        * SI répertoire = "dist" → type = "Vite/SPA"
        * SI répertoire = "build" → type = "Create React App"

      - Vérifier existence répertoire build :
        * test -d [public]
        * SI existe ALORS
          build_exists = true
          - Calculer taille du build
          - Compter nombre de fichiers
          - Lister fichiers principaux (index.html, main.js, etc.)
        SINON
          build_exists = false
          STATUS global = "WARNING"
          Note : "Build directory missing - run build before deploy"
        FIN SI

      - Vérifier rewrites pour SPA :
        * Chercher rewrite : "source": "**", "destination": "/index.html"
        * SI trouvé ALORS spa_routing = "CONFIGURED"
        * SINON spa_routing = "NOT_CONFIGURED" (OK pour SSG)

      - Analyser règles de cache :
        * Parser headers pour cache-control
        * Identifier assets avec long cache (*.js, *.css, images)
        * Vérifier index.html a no-cache

      - Enregistrer dans deploy_results.static[app]
  FIN POUR
  FIN detection_static_deploy

```

**Commandes à exécuter** :
- `cat firebase.json | jq '.hosting'`
- `test -d apps/admin/out && echo "exists"` pour vérifier build
- `du -sh apps/admin/out` pour taille
- `find apps/admin/out -type f | wc -l` pour nombre fichiers
- `ls -lh apps/admin/out/index.html` pour fichier principal

**Format de résultat dans rapport** :
```

Section : Static Deploy (Hosting)

Sites configurés : 3

1. Admin (superdev)
   ✓ Site : admin-app-prod
   ✓ Type : Next.js SSG
   ✓ Build directory : apps/admin/out
   ✓ Build exists : Oui (12.4 MB, 342 fichiers)
   ✓ SPA routing : Configuré
   Cache rules : Optimisé (assets: 1 year, HTML: no-cache)

2. Dashboard
   ⚠ Site : dashboard-app-prod
   ✓ Type : Vite SPA
   ✓ Build directory : apps/dashboard/dist
   ✗ Build exists : Non (à générer)
   ✓ SPA routing : Configuré
3. Public
   ✓ Site : public-site-prod
   ✓ Type : Next.js SSG
   ✓ Build directory : apps/public/out
   ✓ Build exists : Oui (8.7 MB, 198 fichiers)
   ✗ SPA routing : Non configuré (normal pour SSG)

```

#### 5.3 Détection SSR Deploy (App Hosting)

**Pseudo-code** :
```

DÉBUT detection_ssr_deploy

- Vérifier présence fichier apphosting.yaml à la racine OU dans chaque app

- POUR CHAQUE apphosting.yaml trouvé FAIRE

  - Parser configuration YAML :

    - runConfig.runtime (nodejs18, nodejs20)
    - runConfig.concurrency
    - runConfig.cpu
    - runConfig.memoryMiB
    - runConfig.minInstances
    - runConfig.maxInstances
    - env (variables d'environnement)

  - Identifier application :

    - Depuis chemin du fichier (apps/admin/apphosting.yaml)
    - OU depuis field "source" dans config

  - Vérifier configuration Next.js pour SSR :

    - Lire next.config.js de l'app
    - Vérifier output != "export" (sinon c'est SSG pas SSR)
    - Vérifier présence API routes dans pages/api/ ou app/api/
    - Compter nombre de routes API
    - Identifier middleware (middleware.ts)

  - Vérifier build SSR :

    - Chercher .next/standalone/ ou .next/server/
    - SI existe ALORS ssr_build_exists = true
    - SINON ssr_build_exists = false, WARNING

  - Analyser variables d'environnement requises :

    - Extraire depuis apphosting.yaml section env
    - Vérifier si secrets Firebase configurés (SECRET_NAME)
    - Pour chaque variable, vérifier si définie dans .env

  - Vérifier configuration Cloud Run (sous-jacent) :

    - minInstances : si = 0 → cold starts possibles
    - maxInstances : vérifier limites raisonnables
    - memoryMiB : vérifier >= 512 pour Next.js

  - Enregistrer dans deploy_results.ssr[app]
    FIN POUR

- SI aucun apphosting.yaml trouvé ALORS
  ssr_configured = false
  Note : "SSR non configuré (OK si SPA/SSG uniquement)"
  FIN SI
  FIN detection_ssr_deploy

```

**Commandes à exécuter** :
- `find . -name "apphosting.yaml"`
- `cat apps/admin/apphosting.yaml` pour lire config
- `cat apps/admin/next.config.js | grep "output"` pour vérifier SSR
- `find apps/admin/pages/api -type f` pour compter API routes
- `test -d apps/admin/.next/standalone` pour vérifier build SSR
- Parser YAML avec `grep` ou tool externe si disponible

**Format de résultat dans rapport** :
```

Section : SSR Deploy (App Hosting)

Applications SSR : 1

1. Admin (superdev)
   ✓ Configuration : apps/admin/apphosting.yaml
   ✓ Runtime : Node.js 20
   ✓ Resources : 1 CPU, 1024 MB RAM
   ✓ Scaling : min 0, max 10 instances
   ⚠ Cold starts possibles (minInstances = 0)

   Next.js SSR :
   ✓ Output mode : server (SSR enabled)
   ✓ API routes : 7 trouvées
   ✓ Middleware : Présent (auth check)
   ✓ Build SSR : apps/admin/.next/standalone/ (23.5 MB)

   Variables d'environnement :
   ✓ FIREBASE_API_KEY (from secret)
   ✓ DATABASE_URL (from secret)
   ✗ NEXT_PUBLIC_APP_URL (manquante dans .env)

Dashboard & Public : Static deploy uniquement (voir section précédente)

```

#### 5.4 Synthèse des options de déploiement

**Pseudo-code** :
```

DÉBUT synthese_deploiement

- Compiler liste de tous les déploiements possibles :
  deployments_available = []

  - SI data_connect_configured ALORS
    Ajouter : { type: "dataconnect", name: "Data Connect Schema", command: "firebase deploy --only dataconnect" }

  - POUR CHAQUE static site FAIRE
    Ajouter : { type: "hosting", app: [nom], name: "Static [app]", command: "firebase deploy --only hosting:[site]" }

  - POUR CHAQUE ssr app FAIRE
    Ajouter : { type: "apphosting", app: [nom], name: "SSR [app]", command: "firebase apphosting:deploy [app]" }

  - SI functions configurées (firebase.json.functions) ALORS
    Ajouter : { type: "functions", name: "Cloud Functions", command: "firebase deploy --only functions" }

  - SI firestore rules (firestore.rules) ALORS
    Ajouter : { type: "firestore:rules", name: "Firestore Rules", command: "firebase deploy --only firestore:rules" }

  - SI storage rules (storage.rules) ALORS
    Ajouter : { type: "storage", name: "Storage Rules", command: "firebase deploy --only storage" }

- Créer menu interactif :
  Afficher : "Options de déploiement disponibles :"

  [0] Tout déployer (all)
  [1] Admin uniquement (hosting:admin-app-prod + apphosting si SSR)
  [2] Dashboard uniquement (hosting:dashboard-app-prod)
  [3] Public uniquement (hosting:public-site-prod)
  [4] Data Connect uniquement
  [5] Firestore rules uniquement
  [6] Functions uniquement
  [7] Déploiement personnalisé (choisir composants)
  [8] Passer (ne pas déployer maintenant)

- Attendre input utilisateur

- SELON choix utilisateur :
  CASE 0: # Tout
  deploy_targets = "tous les composants"
  deploy_command = "firebase deploy --project=[projectId]"

  CASE 1: # Admin
  deploy_targets = "admin"
  SI admin_is_ssr ALORS
  deploy_command = "firebase deploy --only hosting:admin-app-prod && firebase apphosting:deploy admin"
  SINON
  deploy_command = "firebase deploy --only hosting:admin-app-prod"
  FIN SI

  CASE 2: # Dashboard
  deploy_targets = "dashboard"
  deploy_command = "firebase deploy --only hosting:dashboard-app-prod"

  CASE 3: # Public
  deploy_targets = "public"
  deploy_command = "firebase deploy --only hosting:public-site-prod"

  CASE 4-6: # Composants individuels
  [Construire commande appropriée]

  CASE 7: # Personnalisé
  Afficher checkboxes pour chaque composant
  Construire commande combinée

  CASE 8: # Passer
  deploy_targets = "aucun"
  deploy_command = null
  FIN SELON

- SI deploy_command != null ALORS
  Afficher : "Commande de déploiement préparée :"
  Afficher : deploy_command

  Demander confirmation : "Exécuter le déploiement maintenant ? (y/n)"

  SI utilisateur confirme ALORS - Vérifier prérequis :
  _ Tous les builds existent
  _ Pas d'erreurs critiques dans l'audit \* Authentifié Firebase CLI (firebase login:list)

      SI prérequis OK ALORS
        - Capturer timestamp début deploy
        - Exécuter deploy_command
        - Rediriger vers /tmp/deploy-output.log
        - Afficher progression en temps réel

        - Attendre fin de déploiement
        - Capturer code sortie

        SI succès ALORS
          deploy_status = "SUCCESS"
          - Extraire URLs de déploiement depuis logs
          - Afficher URLs cliquables
        SINON
          deploy_status = "FAILED"
          STATUS global = "ERROR"
          - Extraire erreurs
        FIN SI

        - Capturer timestamp fin
        - Calculer durée
      SINON
        Afficher : "⚠️ Prérequis non satisfaits. Déploiement annulé."
        Lister prérequis manquants
      FIN SI

  SINON
  deploy_status = "SKIPPED_BY_USER"
  FIN SI
  SINON
  deploy_status = "NOT_REQUESTED"
  FIN SI

- Enregistrer dans deploy_results.execution
  FIN synthese_deploiement

```

**Commandes à exécuter** :
- `firebase login:list` pour vérifier authentification
- `firebase deploy --only [targets] --project=[projectId] 2>&1 | tee /tmp/deploy-output.log`
- `grep -E "hosting URL|Function URL" /tmp/deploy-output.log` pour extraire URLs
- Parsing des logs Firebase CLI pour progression

**Format de résultat dans rapport** :
```

Section : Déploiement

Choix utilisateur : Admin uniquement

Prérequis :
✓ Build admin existe
✓ Authentifié Firebase (user@example.com)
✓ Projet configuré : my-project-prod

Commande exécutée :
firebase deploy --only hosting:admin-app-prod --project=my-project-prod

Résultat : ✓ SUCCESS (durée : 2m 34s)

URLs de déploiement :
🌐 Admin app : https://admin-app-prod.web.app
🌐 Admin app (custom domain) : https://admin.myapp.com

Détails du déploiement :

- Fichiers uploadés : 342
- Taille totale : 12.4 MB
- Cache utilisé : 67% (230 fichiers inchangés)
- Temps d'upload : 45s
- Propagation CDN : ~5 minutes

[Bouton : Ouvrir admin app]
[Bouton : Voir logs complets]

```

**Appel à Gemini si déploiement échoue** :
```

SI deploy_status == "FAILED" ALORS

- Extraire erreurs du log de déploiement

Proposer :
"❌ Déploiement échoué.

Voulez-vous que Gemini analyse l'erreur et propose une solution ? (y/n)"

SI accepté ALORS
Envoyer à Gemini :
"Firebase deployment failed for a Turborepo project.

    Deployment command:
    [deploy_command]

    Deployment target:
    [deploy_targets]

    Error logs:

```
    [Extrait /tmp/deploy-output.log avec erreurs]
```

    Firebase configuration:

```json
    [firebase.json relevant sections]
```

    Analyze the deployment error and provide:
    1. Root cause identification
    2. Whether it's a configuration, build, or authentication issue
    3. Step-by-step fix instructions
    4. If config issue, provide corrected firebase.json or apphosting.yaml
    5. If build issue, explain what needs to be rebuilt
    6. If auth issue, provide authentication steps

    Common issues to check:
    - Missing or incorrect hosting configuration
    - Build directory not found
    - Firebase CLI not authenticated
    - Quota exceeded
    - Invalid project ID
    - Missing required files"

FIN SI

DÉBUT calcul_statut_global

- Initialiser compteurs :

  - total_checks = 0
  - passed_checks = 0
  - warning_checks = 0
  - error_checks = 0

- Évaluer chaque phase :

  # Configuration Firebase

  SI firebase.json ET .firebaserc existent ALORS
  passed_checks++
  SINON
  error_checks++
  FIN SI
  total_checks++

  SI divergences de projectId > 0 ALORS
  warning_checks++
  total_checks++
  FIN SI

  # Git

  SI git_status == "CLEAN" ALORS
  passed_checks++
  SINON SI git_status == "DIRTY" ALORS
  warning_checks++
  SINON SI git_status == "CONFLICT" ALORS
  error_checks++
  FIN SI
  total_checks++

  # Build

  POUR CHAQUE app IN [admin, dashboard, public] FAIRE
  SI build_results[app].status == "SUCCESS" ALORS
  passed_checks++
  SINON SI build_results[app].status == "SUCCESS_WITH_WARNINGS" ALORS
  warning_checks++
  SINON
  error_checks++
  FIN SI
  total_checks++
  FIN POUR

  # Lint

  SI lint_status == "PASSED" ALORS
  passed_checks++
  SINON SI lint_status == "WARNINGS" ALORS
  warning_checks++
  SINON SI lint_status == "FAILED" ALORS
  error_checks++
  FIN SI
  total_checks++

  # Tests

  SI test_status == "PASSED" pour tous frameworks ALORS
  passed_checks++
  SINON SI tests échoués > 0 ALORS
  error_checks++
  FIN SI
  total_checks++

  # Emulateurs

  SI emulators_status == "RUNNING" OU "NOT_STARTED" ALORS
  passed_checks++
  SINON
  warning_checks++
  FIN SI
  total_checks++

  # Deploy config

  SI au moins un type de deploy configuré ALORS
  passed_checks++
  SINON
  warning_checks++
  FIN SI
  total_checks++

- Calculer statut final :
  SI error_checks > 0 ALORS
  GLOBAL_STATUS = "CRITICAL"
  status_color = "#dc2626" (rouge)
  status_icon = "⚠️"
  status_message = "Des erreurs critiques nécessitent une attention immédiate"
  SINON SI warning_checks > 0 ALORS
  GLOBAL_STATUS = "WARNING"
  status_color = "#f59e0b" (orange)
  status_icon = "⚠"
  status_message = "Le projet fonctionne mais présente des avertissements"
  SINON
  GLOBAL_STATUS = "HEALTHY"
  status_color = "#10b981" (vert)
  status_icon = "✓"
  status_message = "Tous les systèmes sont opérationnels"
  FIN SI

- Calculer score de santé (0-100) :
  health_score = (passed_checks / total_checks) × 100
  Arrondir à l'entier

- Enregistrer métriques globales :
  _ timestamp_debut
  _ timestamp_fin
  _ duree_totale (en secondes et format humain)
  _ total_checks
  _ passed_checks
  _ warning_checks
  _ error_checks
  _ health_score \* GLOBAL_STATUS
  FIN calcul_statut_global

```

**Commandes à exécuter** :
- Calculs arithmétiques bash avec `$(( ))` ou `bc`
- `date -d @$timestamp_debut +"%Y-%m-%d %H:%M:%S"` pour formatter dates
- Conversion durée : `printf '%02d:%02d:%02d' $hours $minutes $seconds`

**Format de résultat (données pour HTML)** :
```

Variables globales :
GLOBAL_STATUS = "WARNING"
health_score = 87
total_checks = 15
passed_checks = 13
warning_checks = 2
error_checks = 0
duree_totale = "3m 47s"
timestamp_rapport = "2025-10-15 14:32:18"

```

#### 6.2 Structure du document HTML

**Pseudo-code** :
```

DÉBUT generation_html

- Créer fichier HTML : /apps/admin/reports/titanic-health-TIMESTAMP.html
- OU : /superdev/reports/titanic-health.html (écrase version précédente)

- Structure du document :
      <!DOCTYPE html>
      <html lang="fr">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Titanic Health Check - [timestamp]</title>
        <style>
          [CSS embarqué - voir section 6.3]
        </style>
      </head>
      <body>
        <!-- Header avec logo et titre -->
        <header>
          [Section 6.4]
        </header>

        <!-- Résumé exécutif -->
        <section id="executive-summary">
          [Section 6.5]
        </section>

        <!-- Dashboard de métriques -->
        <section id="metrics-dashboard">
          [Section 6.6]
        </section>

        <!-- Sections détaillées -->
        <main>
          <section id="config-firebase">
            [Section 6.7.1]
          </section>

          <section id="git-status">
            [Section 6.7.2]
          </section>

          <section id="build-results">
            [Section 6.7.3]
          </section>

          <section id="test-results">
            [Section 6.7.4]
          </section>

          <section id="emulators">
            [Section 6.7.5]
          </section>

          <section id="deploy-config">
            [Section 6.7.6]
          </section>
        </main>

        <!-- Logs détaillés (accordéons) -->
        <section id="detailed-logs">
          [Section 6.8]
        </section>

        <!-- Footer avec métadonnées -->
        <footer>
          [Section 6.9]
        </footer>

        <script>
          [JavaScript pour interactivité - Section 6.10]
        </script>
      </body>
      </html>
  FIN generation_html

```

#### 6.3 Styles CSS embarqués

**Pseudo-code** :
```

DÉBUT generation_css
Inclure dans <style> :

- Reset et base :

  - { box-sizing, margin, padding }
    body { font-family: system-ui, background: #f9fafb, color: #111827 }

- Layout :
  .container { max-width: 1400px, margin: auto, padding }
  .grid { display: grid, gap, responsive columns }

- Composants réutilisables :
  .card { background: white, border-radius, box-shadow, padding }
  .badge { inline badge avec couleurs selon statut }
  .status-indicator { cercle coloré pour statut }
  .progress-bar { barre de progression avec gradient }

- Statuts avec couleurs :
  .status-success { color: #10b981, background: #d1fae5 }
  .status-warning { color: #f59e0b, background: #fef3c7 }
  .status-error { color: #dc2626, background: #fee2e2 }

- Tableaux :
  table { width: 100%, border-collapse }
  th { background: #f3f4f6, text-align: left, font-weight: 600 }
  td { border-bottom, padding, vertical-align: top }
  tr:hover { background: #f9fafb }

- Accordéons (pour logs) :
  .accordion { cursor: pointer, transition }
  .accordion.active { background change }
  .accordion-content { max-height: 0, overflow: hidden, transition }
  .accordion-content.open { max-height: 1000px }

- Utilitaires :
  .text-sm, .text-lg, .text-xl, .text-2xl, .text-3xl
  .font-bold, .font-semibold
  .mt-4, .mb-2, .p-4, .px-6
  .flex, .justify-between, .items-center

- Responsive :
  @media (max-width: 768px) { grid colonnes 1, reduce padding }

- Animations :
  @keyframes fadeIn { opacity 0 to 1 }
  @keyframes slideDown { transform translateY }
  .fade-in { animation: fadeIn 0.3s }

- Print styles :
  @media print { hide accordions, expand all sections, remove shadows }
  FIN generation_css

```

**Instructions pour Gemini** :
```

"Generate modern, clean CSS styles for the Titanic Health Check report.
Use a design system approach with:

- Color palette: green (#10b981) for success, orange (#f59e0b) for warnings, red (#dc2626) for errors
- Gray scale: #111827 (text), #6b7280 (secondary), #f3f4f6 (backgrounds)
- Font: system-ui stack
- Spacing scale: 4px base (0.25rem, 0.5rem, 1rem, 1.5rem, 2rem, 3rem)
- Border radius: 0.5rem for cards, 0.25rem for badges
- Shadows: subtle shadows for depth (0 1px 3px rgba(0,0,0,0.1))
- Responsive: mobile-first approach, breakpoint at 768px
- Accessibility: sufficient contrast ratios, focus states"

```

#### 6.4 Header du rapport

**Pseudo-code** :
```

DÉBUT generation_header

  <header class="header bg-gradient">
    <div class="container">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold">
            🚢 Titanic Health Check
          </h1>
          <p class="text-sm text-gray-600">
            Rapport d'audit Firebase Cloud - [nom_projet]
          </p>
        </div>
        
        <div class="status-badge" style="background-color: [status_color]">
          <span class="status-icon">[status_icon]</span>
          <span class="status-text">[GLOBAL_STATUS]</span>
          <span class="status-score">[health_score]%</span>
        </div>
      </div>
      
      <div class="metadata text-sm text-gray-500 mt-4">
        <span>📅 Généré le [timestamp_rapport]</span>
        <span class="mx-2">•</span>
        <span>⏱️ Durée d'exécution: [duree_totale]</span>
        <span class="mx-2">•</span>
        <span>📊 [total_checks] vérifications</span>
      </div>
    </div>
  </header>
FIN generation_header
```

**Données à injecter** :

- `status_color` depuis calcul statut global
- `status_icon`, `GLOBAL_STATUS`, `health_score`
- `timestamp_rapport`, `duree_totale`, `total_checks`
- `nom_projet` depuis firebase.json ou .firebaserc

#### 6.5 Résumé exécutif

**Pseudo-code** :

```
DÉBUT generation_resume_executif
  <section id="executive-summary" class="container mt-8">
    <div class="card">
      <h2 class="text-2xl font-bold mb-4">📋 Résumé Exécutif</h2>

      <div class="status-message mb-6">
        <p class="text-lg">
          [status_icon] [status_message]
        </p>
      </div>

      <div class="grid grid-cols-4 gap-4">
        <!-- Carte: Checks passed -->
        <div class="metric-card status-success">
          <div class="metric-value">[passed_checks]</div>
          <div class="metric-label">Vérifications réussies</div>
          <div class="metric-icon">✓</div>
        </div>

        <!-- Carte: Warnings -->
        <div class="metric-card status-warning">
          <div class="metric-value">[warning_checks]</div>
          <div class="metric-label">Avertissements</div>
          <div class="metric-icon">⚠</div>
        </div>

        <!-- Carte: Errors -->
        <div class="metric-card status-error">
          <div class="metric-value">[error_checks]</div>
          <div class="metric-label">Erreurs critiques</div>
          <div class="metric-icon">✗</div>
        </div>

        <!-- Carte: Health score -->
        <div class="metric-card">
          <div class="metric-value">[health_score]%</div>
          <div class="metric-label">Score de santé</div>
          <div class="progress-bar">
            <div class="progress-fill" style="width: [health_score]%"></div>
          </div>
        </div>
      </div>

      <!-- Points d'attention prioritaires -->
      <div class="mt-6">
        <h3 class="text-lg font-semibold mb-3">🎯 Points d'attention prioritaires</h3>
        <ul class="attention-list">
          [POUR CHAQUE erreur ou warning critique]
            <li class="attention-item [status-class]">
              <span class="attention-icon">[icon]</span>
              <span class="attention-text">[description]</span>
              <a href="#[section-id]" class="attention-link">Voir détails →</a>
            </li>
          [FIN POUR]
        </ul>
      </div>

      <!-- Actions recommandées -->
      <div class="mt-6 p-4 bg-blue-50 border-l-4 border-blue-500">
        <h3 class="text-lg font-semibold mb-2">💡 Actions recommandées</h3>
        <ol class="recommended-actions">
          [Générer liste priorisée basée sur erreurs détectées]
          Exemples :
          - Corriger les [X] erreurs de build dans dashboard
          - Résoudre les [Y] tests échoués
          - Mettre à jour la configuration Firebase pour cohérence
        </ol>
      </div>
    </div>
  </section>
FIN generation_resume_executif
```

**Logique de priorisation des points d'attention** :

```
Liste priorité (ordre décroissant) :
1. Conflits Git non résolus
2. Erreurs de build bloquantes
3. Tests échoués
4. Configuration Firebase invalide/manquante
5. Émulateurs ne démarrent pas
6. Warnings de build nombreux (> 10)
7. Lint errors
8. Divergences de configuration
9. Build directory manquant pour deploy
10. Autres warnings

Limiter à 5 points d'attention max dans le résumé
```

#### 6.6 Dashboard de métriques

**Pseudo-code** :

```
DÉBUT generation_metrics_dashboard
  <section id="metrics-dashboard" class="container mt-8">
    <h2 class="text-2xl font-bold mb-6">📊 Vue d'ensemble des métriques</h2>

    <div class="grid grid-cols-3 gap-6">
      <!-- Colonne 1: Build & Code Quality -->
      <div class="card">
        <h3 class="text-lg font-semibold mb-4 border-b pb-2">
          🔨 Build & Qualité
        </h3>

        <div class="metric-row">
          <span class="metric-label">Applications</span>
          <span class="metric-value">
            [admin_build_status_icon]
            [dashboard_build_status_icon]
            [public_build_status_icon]
          </span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Durée totale build</span>
          <span class="metric-value">[total_build_duration]s</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Erreurs build</span>
          <span class="metric-value [color-class]">[total_build_errors]</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Warnings build</span>
          <span class="metric-value [color-class]">[total_build_warnings]</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Lint status</span>
          <span class="badge [lint-status-class]">[lint_status]</span>
        </div>
      </div>

      <!-- Colonne 2: Tests & Coverage -->
      <div class="card">
        <h3 class="text-lg font-semibold mb-4 border-b pb-2">
          🧪 Tests
        </h3>

        <div class="metric-row">
          <span class="metric-label">Tests exécutés</span>
          <span class="metric-value">[total_tests]</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Taux de réussite</span>
          <span class="metric-value text-lg font-bold [color]">
            [test_success_rate]%
          </span>
        </div>

        <div class="progress-bar-container">
          <div class="progress-bar-segment success" style="width: [passed_percent]%"></div>
          <div class="progress-bar-segment failed" style="width: [failed_percent]%"></div>
          <div class="progress-bar-segment skipped" style="width: [skipped_percent]%"></div>
        </div>

        <div class="metric-legend">
          <span class="legend-item">
            <span class="legend-color success"></span>
            [passed_tests] réussis
          </span>
          <span class="legend-item">
            <span class="legend-color failed"></span>
            [failed_tests] échoués
          </span>
          <span class="legend-item">
            <span class="legend-color skipped"></span>
            [skipped_tests] skipped
          </span>
        </div>

        <div class="metric-row mt-4">
          <span class="metric-label">Durée moyenne</span>
          <span class="metric-value">[avg_test_duration]ms</span>
        </div>
      </div>

      <!-- Colonne 3: Git & Deploy -->
      <div class="card">
        <h3 class="text-lg font-semibold mb-4 border-b pb-2">
          📦 Git & Déploiement
        </h3>

        <div class="metric-row">
          <span class="metric-label">Git status</span>
          <span class="badge [git-status-class]">[git_status]</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Fichiers modifiés</span>
          <span class="metric-value">[modified_files_count]</span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Dernier commit</span>
          <span class="metric-value text-sm">[last_commit_age]</span>
        </div>

        <div class="metric-row mt-4 pt-4 border-t">
          <span class="metric-label">Config déploiement</span>
          <span class="metric-value">
            [SI data_connect] <span class="deploy-type-badge">Data Connect</span>
            [SI static] <span class="deploy-type-badge">Static</span>
            [SI ssr] <span class="deploy-type-badge">SSR</span>
          </span>
        </div>

        <div class="metric-row">
          <span class="metric-label">Émulateurs</span>
          <span class="badge [emulator-status-class]">
            [emulators_configured_count] configurés
          </span>
        </div>
      </div>
    </div>

    <!-- Timeline des phases d'exécution -->
    <div class="card mt-6">
      <h3 class="text-lg font-semibold mb-4">⏱️ Timeline d'exécution</h3>
      <div class="timeline">
        [POUR CHAQUE phase]
          <div class="timeline-item">
            <div class="timeline-marker [status-class]"></div>
            <div class="timeline-content">
              <div class="timeline-title">[phase_name]</div>
              <div class="timeline-duration">[phase_duration]s</div>
            </div>
            <div class="timeline-bar" style="width: [phase_percent]%"></div>
          </div>
        [FIN POUR]
      </div>
    </div>
  </section>
FIN generation_metrics_dashboard
```

**Données à calculer** :

- Sommes et moyennes depuis les résultats collectés
- Pourcentages pour barres de progression
- Durées relatives pour timeline (% de durée totale)
- Classes CSS conditionnelles selon valeurs

#### 6.7 Sections détaillées

##### 6.7.1 Configuration Firebase

**Pseudo-code** :

```
DÉBUT section_config_firebase
  <section id="config-firebase" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">⚙️ Configuration Firebase</h2>

      <!-- Fichiers de configuration -->
      <div class="subsection">
        <h3 class="text-lg font-semibold mb-3">Fichiers détectés</h3>
        <table class="config-table">
          <thead>
            <tr>
              <th>Fichier</th>
              <th>Chemin</th>
              <th>Statut</th>
              <th>Dernière modification</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE fichier config]
              <tr>
                <td><code>[filename]</code></td>
                <td class="text-sm text-gray-600">[path]</td>
                <td>
                  [SI trouvé]
                    <span class="badge status-success">✓ Trouvé</span>
                  [SINON]
                    <span class="badge status-error">✗ Manquant</span>
                  [FIN SI]
                </td>
                <td class="text-sm">[last_modified]</td>
              </tr>
            [FIN POUR]
          </tbody>
        </table>
      </div>

      <!-- Environnements configurés -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Environnements</h3>
        <div class="grid grid-cols-2 gap-4">
          <div class="info-box">
            <div class="info-label">Projet par défaut</div>
            <div class="info-value"><code>[default_project_id]</code></div>
          </div>
          <div class="info-box">
            <div class="info-label">Projets configurés</div>
            <div class="info-value">[projects_list]</div>
          </div>
        </div>
      </div>

      <!-- Clés Firebase par application -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Clés Firebase</h3>
        <table class="keys-table">
          <thead>
            <tr>
              <th>Application</th>
              <th>Environnement</th>
              <th>apiKey</th>
              <th>projectId</th>
              <th>authDomain</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE app ET environnement]
              <tr>
                <td class="font-semibold">[app_name]</td>
                <td><span class="badge">[env_name]</span></td>
                <td class="font-mono text-sm">[masked_api_key]</td>
                <td class="font-mono text-sm">[project_id]</td>
                <td class="font-mono text-sm">[auth_domain]</td>
                <td>
                  [SI cohérent]
                    <span class="status-indicator success"></span>
                  [SINON]
                    <span class="status-indicator warning"></span>
                  [FIN SI]
                </td>
              </tr>
            [FIN POUR]
          </tbody>
        </table>
      </div>

      <!-- Vérifications de cohérence -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Cohérence</h3>
        [SI divergences OU warnings]
          <div class="alert alert-warning">
            <div class="alert-title">⚠️ Divergences détectées</div>
            <ul class="alert-list">
              [POUR CHAQUE divergence]
                <li>[description_divergence]</li>
              [FIN POUR]
            </ul>
          </div>
        [SINON]
          <div class="alert alert-success">
            <div class="alert-title">✓ Configuration cohérente</div>
            <p>Tous les fichiers de configuration sont alignés.</p>
          </div>
        [FIN SI]
      </div>

      <!-- Services Firebase configurés -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Services configurés</h3>
        <div class="services-grid">
          [POUR CHAQUE service dans firebase.json]
            <div class="service-card [active-class]">
              <div class="service-icon">[icon]</div>
              <div class="service-name">[service_name]</div>
              <div class="service-status">
                [SI configuré] ✓ Actif
                [SINON] ○ Inactif
              </div>
            </div>
          [FIN POUR]
        </div>
      </div>
    </div>
  </section>
FIN section_config_firebase


DÉBUT section_git_status
  <section id="git-status" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">📚 État Git</h2>

      <!-- Statut du working directory -->
      <div class="status-banner [git-status-class]">
        <div class="status-banner-icon">[icon]</div>
        <div class="status-banner-content">
          <div class="status-banner-title">
            Working Directory: [git_status]
          </div>
          <div class="status-banner-stats">
            [modified_count] modifiés •
            [untracked_count] non suivis •
            [conflicts_count] conflits
          </div>
        </div>
      </div>

      <!-- Informations de branche -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Branche et remote</h3>
        <div class="grid grid-cols-3 gap-4">
          <div class="info-box">
            <div class="info-label">Branche courante</div>
            <div class="info-value">
              <code>[current_branch]</code>
            </div>
          </div>
          <div class="info-box">
            <div class="info-label">Remote</div>
            <div class="info-value text-sm">
              [remote_name] ([remote_url_short])
            </div>
          </div>
          <div class="info-box">
            <div class="info-label">État sync</div>
            <div class="info-value">
              [SI ahead > 0] +[ahead] commits en avance
              [SI behind > 0] -[behind] commits en retard
              [SI synced] ✓ À jour
            </div>
          </div>
        </div>
      </div>

      <!-- Fichiers non commités -->
      [SI modified_count + untracked_count > 0]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3">
            Fichiers non commités ([modified_count + untracked_count])
          </h3>
          <div class="file-list">
            [POUR CHAQUE fichier (max 20)]
              <div class="file-item">
                <span class="file-status-badge [status-class]">[M/A/D/??]</span>
                <code class="file-path">[filepath]</code>
              </div>
            [FIN POUR]
            [SI total > 20]
              <div class="file-item-more">
                ... et [total - 20] autres fichiers
              </div>
            [FIN SI]
          </div>
        </div>
      [FIN SI]

      <!-- Historique récent -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Historique récent (5 derniers commits)</h3>
        <div class="commits-list">
          [POUR CHAQUE commit dans last_5_commits]
            <div class="commit-item">
              <div class="commit-hash">
                <code>[short_hash]</code>
              </div>
              <div class="commit-content">
                <div class="commit-message">[message]</div>
                <div class="commit-meta">
                  <span class="commit-author">[author]</span>
                  <span class="commit-date">[relative_date]</span>
                </div>
              </div>
            </div>
          [FIN POUR]
        </div>


[SI last_commit_age > 7 jours]
          <div class="alert alert-warning mt-4">
            <div class="alert-icon">⚠️</div>
            <div class="alert-content">
              <div class="alert-title">Inactivité détectée</div>
              <p>Le dernier commit date de [last_commit_age] jours.
              Le projet semble inactif.</p>
            </div>
          </div>
        [FIN SI]
      </div>

      <!-- Branches locales -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Branches locales</h3>
        <div class="branches-grid">
          [POUR CHAQUE branche locale]
            <div class="branch-item [active-class-if-current]">
              <span class="branch-icon">🌿</span>
              <code class="branch-name">[branch_name]</code>
              [SI branche == current_branch]
                <span class="badge badge-primary">Courante</span>
              [FIN SI]
            </div>
          [FIN POUR]
        </div>
      </div>
    </div>
  </section>
FIN section_git_status
```

##### 6.7.3 Résultats des builds

**Pseudo-code** :

```
DÉBUT section_build_results
  <section id="build-results" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">🔨 Résultats des builds</h2>

      <!-- Tableau récapitulatif -->
      <div class="subsection">
        <h3 class="text-lg font-semibold mb-3">Compilation des applications</h3>
        <table class="results-table">
          <thead>
            <tr>
              <th>Application</th>
              <th>Framework</th>
              <th>Statut</th>
              <th>Durée</th>
              <th>Erreurs</th>
              <th>Warnings</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE app IN [admin, dashboard, public]]
              <tr class="[row-status-class]">
                <td class="font-semibold">[app_name]</td>
                <td><span class="badge badge-tech">[framework]</span></td>
                <td>
                  [SI build_status == "SUCCESS"]
                    <span class="status-badge status-success">
                      ✓ SUCCESS
                    </span>
                  [SINON SI build_status == "SUCCESS_WITH_WARNINGS"]
                    <span class="status-badge status-warning">
                      ⚠ SUCCESS (warnings)
                    </span>
                  [SINON]
                    <span class="status-badge status-error">
                      ✗ FAILED
                    </span>
                  [FIN SI]
                </td>
                <td>[duration]s</td>
                <td class="[error-color-class]">
                  [SI errors > 0]
                    <span class="error-count">[errors]</span>
                  [SINON]
                    <span class="text-gray-400">0</span>
                  [FIN SI]
                </td>
                <td class="[warning-color-class]">
                  [SI warnings > 0]
                    <span class="warning-count">[warnings]</span>
                  [SINON]
                    <span class="text-gray-400">0</span>
                  [FIN SI]
                </td>
                <td>
                  <button class="btn-sm" onclick="toggleLog('[app]-build-log')">
                    Voir logs
                  </button>
                  [SI build_status == "FAILED"]
                    <button class="btn-sm btn-primary" onclick="fixBuild('[app]')">
                      🤖 Corriger avec Gemini
                    </button>
                  [FIN SI]
                </td>
              </tr>
            [FIN POUR]
            <tr class="total-row">
              <td colspan="3" class="font-bold">TOTAL</td>
              <td class="font-bold">[total_duration]s</td>
              <td class="font-bold [color]">[total_errors]</td>
              <td class="font-bold [color]">[total_warnings]</td>
              <td></td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Détails par application (accordéons) -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Détails par application</h3>

        [POUR CHAQUE app]
          <div class="accordion-container mb-4">
            <button class="accordion" onclick="toggleAccordion('[app]-build-details')">
              <span class="accordion-title">
                [app_icon] [app_name] - [build_status]
              </span>
              <span class="accordion-arrow">▼</span>
            </button>

            <div id="[app]-build-details" class="accordion-content">
              <!-- Informations build -->
              <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="info-box">
                  <div class="info-label">Commande exécutée</div>
                  <code class="info-value">[build_command]</code>
                </div>
                <div class="info-box">
                  <div class="info-label">Répertoire de sortie</div>
                  <code class="info-value">[output_dir]</code>
                </div>
                <div class="info-box">
                  <div class="info-label">Taille du build</div>
                  <div class="info-value">[build_size] MB</div>
                </div>
                <div class="info-box">
                  <div class="info-label">Nombre de fichiers</div>
                  <div class="info-value">[files_count]</div>
                </div>
              </div>

              <!-- Erreurs si présentes -->
              [SI errors > 0]
                <div class="errors-section">
                  <h4 class="text-md font-semibold mb-2 text-red-600">
                    Erreurs de compilation ([errors])
                  </h4>
                  <div class="error-list">
                    [POUR CHAQUE erreur (max 10)]
                      <div class="error-item">
                        <div class="error-file">
                          <span class="error-icon">📄</span>
                          <code>[file_path]:[line]:[column]</code>
                        </div>
                        <div class="error-message">[error_message]</div>
                        <pre class="error-code">[code_snippet]</pre>
                      </div>
                    [FIN POUR]
                    [SI errors > 10]
                      <div class="error-more">
                        ... et [errors - 10] autres erreurs (voir log complet)
                      </div>
                    [FIN SI]
                  </div>
                </div>
              [FIN SI]

              <!-- Warnings si présents -->
              [SI warnings > 0]
                <div class="warnings-section mt-4">
                  <h4 class="text-md font-semibold mb-2 text-orange-600">
                    Avertissements ([warnings])
                  </h4>
                  <div class="warning-list">
                    [Afficher top 5 warnings avec même format que erreurs]
                  </div>
                </div>
              [FIN SI]

              <!-- Log brut (pliable) -->
              <div class="log-section mt-4">
                <button class="btn-sm" onclick="toggleLog('[app]-build-log')">
                  📋 Afficher/Masquer log complet
                </button>
                <pre id="[app]-build-log" class="log-content hidden">
[contenu de /tmp/build-[app].log]
                </pre>
              </div>
            </div>
          </div>
        [FIN POUR]
      </div>

      <!-- Résultats Linting -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">🔍 Linting (ESLint)</h3>

        [SI lint configuré]
          <div class="lint-summary">
            <div class="grid grid-cols-4 gap-4">
              <div class="metric-card">
                <div class="metric-label">Statut</div>
                <div class="metric-value">
                  <span class="badge [lint-status-class]">[lint_status]</span>
                </div>
              </div>
              <div class="metric-card">
                <div class="metric-label">Fichiers vérifiés</div>
                <div class="metric-value">[files_checked]</div>
              </div>
              <div class="metric-card [error-class]">
                <div class="metric-label">Erreurs</div>
                <div class="metric-value text-2xl">[lint_errors]</div>
              </div>
              <div class="metric-card [warning-class]">
                <div class="metric-label">Warnings</div>
                <div class="metric-value text-2xl">[lint_warnings]</div>
              </div>
            </div>
          </div>

          [SI lint_errors > 0 OU lint_warnings > 0]
            <div class="lint-details mt-4">
              <h4 class="text-md font-semibold mb-3">Règles les plus violées</h4>
              <table class="lint-rules-table">
                <thead>
                  <tr>
                    <th>Règle</th>
                    <th>Occurrences</th>
                    <th>Sévérité</th>
                  </tr>
                </thead>
                <tbody>
                  [POUR CHAQUE règle dans top 10]
                    <tr>
                      <td><code>[rule_name]</code></td>
                      <td>[count]</td>
                      <td>
                        <span class="badge [severity-class]">[severity]</span>
                      </td>
                    </tr>
                  [FIN POUR]
                </tbody>
              </table>
            </div>

            [SI lint_errors > 0]
              <div class="mt-4">
                <button class="btn btn-primary" onclick="fixLint()">
                  🤖 Corriger avec Gemini
                </button>
              </div>
            [FIN SI]
          [FIN SI]

          <div class="mt-4">
            <button class="btn-sm" onclick="toggleLog('lint-log')">
              📋 Voir log complet ESLint
            </button>
            <pre id="lint-log" class="log-content hidden">
[contenu de /tmp/lint.log]
            </pre>
          </div>
        [SINON]
          <div class="alert alert-info">
            <p>ESLint n'est pas configuré dans ce projet.</p>
          </div>
        [FIN SI]
      </div>
    </div>
  </section>
FIN section_build_results
```

##### 6.7.4 Résultats des tests

**Pseudo-code** :

```
DÉBUT section_test_results
  <section id="test-results" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">🧪 Résultats des tests</h2>

      <!-- Vue d'ensemble -->
      <div class="test-summary">
        <div class="grid grid-cols-5 gap-4">
          <div class="metric-card">
            <div class="metric-value text-3xl font-bold">[total_tests]</div>
            <div class="metric-label">Tests totaux</div>
          </div>
          <div class="metric-card status-success">
            <div class="metric-value text-3xl font-bold text-green-600">
              [passed_tests]
            </div>
            <div class="metric-label">✓ Réussis</div>
          </div>
          <div class="metric-card status-error">
            <div class="metric-value text-3xl font-bold text-red-600">
              [failed_tests]
            </div>
            <div class="metric-label">✗ Échoués</div>
          </div>
          <div class="metric-card">
            <div class="metric-value text-3xl font-bold text-gray-500">
              [skipped_tests]
            </div>
            <div class="metric-label">○ Skipped</div>
          </div>
          <div class="metric-card">
            <div class="metric-value text-3xl font-bold [score-color]">
              [success_rate]%
            </div>
            <div class="metric-label">Taux de réussite</div>
            <div class="progress-bar mt-2">
              <div class="progress-fill" style="width: [success_rate]%; background: [color]"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Barre de progression visuelle -->
      <div class="test-progress-bar mt-6">
        <div class="progress-segment passed"
             style="width: [passed_percent]%"
             title="[passed_tests] réussis">
        </div>
        <div class="progress-segment failed"
             style="width: [failed_percent]%"
             title="[failed_tests] échoués">
        </div>
        <div class="progress-segment skipped"
             style="width: [skipped_percent]%"
             title="[skipped_tests] skipped">
        </div>
      </div>

      <!-- Métriques de performance -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">⏱️ Performances</h3>
        <div class="grid grid-cols-3 gap-4">
          <div class="info-box">
            <div class="info-label">Durée totale</div>
            <div class="info-value">[total_duration]s</div>
          </div>
          <div class="info-box">
            <div class="info-label">Durée moyenne par test</div>
            <div class="info-value">[avg_duration]ms</div>
          </div>
          <div class="info-box">
            <div class="info-label">Test le plus lent</div>
            <div class="info-value text-sm">[slowest_test_name] ([slowest_duration]s)</div>
          </div>
        </div>
      </div>

      <!-- Résultats par framework -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Résultats par framework</h3>
        <table class="results-table">
          <thead>
            <tr>
              <th>Framework</th>
              <th>Tests</th>
              <th>Réussis</th>
              <th>Échoués</th>
              <th>Skipped</th>
              <th>Durée</th>
              <th>Taux</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE framework détecté]
              <tr>
                <td>
                  <span class="badge badge-tech">[framework_name]</span>
                </td>
                <td>[tests_count]</td>
                <td class="text-green-600">[passed]</td>
                <td class="text-red-600">[failed]</td>
                <td class="text-gray-500">[skipped]</td>
                <td>[duration]s</td>
                <td>
                  <div class="inline-progress">
                    <div class="progress-fill" style="width: [rate]%"></div>
                  </div>
                  <span class="text-sm ml-2">[rate]%</span>
                </td>
              </tr>
            [FIN POUR]
          </tbody>
        </table>
      </div>

      <!-- Tests échoués (PRIORITAIRE) -->
      [SI failed_tests > 0]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3 text-red-600">
            ❌ Tests échoués ([failed_tests])
          </h3>

          <div class="alert alert-error mb-4">
            <div class="alert-icon">⚠️</div>
            <div class="alert-content">
              <div class="alert-title">Action requise</div>
              <p>[failed_tests] test(s) nécessitent une correction.</p>
              <button class="btn btn-primary mt-2" onclick="fixTests()">
                🤖 Analyser et corriger avec Gemini
              </button>
            </div>
          </div>

          <div class="failed-tests-list">
            [POUR CHAQUE test échoué (tous, pas de limite)]
              <div class="test-failure-card">
                <div class="test-failure-header">
                  <div class="test-failure-title">
                    <span class="test-failure-icon">✗</span>
                    <span class="test-failure-name">[test_name]</span>
                  </div>
                  <span class="badge">[framework]</span>
                </div>

                <div class="test-failure-meta">
                  <code class="text-sm">[file_path]:[line_number]</code>
                  <span class="test-duration">[duration]ms</span>
                </div>

                <div class="test-failure-error">
                  <div class="error-label">Erreur:</div>
                  <pre class="error-message">[error_message]</pre>
                </div>

                [SI stack_trace disponible]
                  <details class="test-failure-stack">
                    <summary>Stack trace</summary>
                    <pre class="stack-trace">[stack_trace]</pre>
                  </details>
                [FIN SI]

                <div class="test-failure-actions mt-3">
                  <button class="btn-sm" onclick="openFile('[file_path]', [line_number])">
                    📝 Ouvrir dans l'éditeur
                  </button>
                  <button class="btn-sm btn-primary" onclick="fixSingleTest('[test_id]')">
                    🤖 Corriger ce test
                  </button>
                </div>
              </div>
            [FIN POUR]
          </div>
        </div>
      [FIN SI]

      <!-- Tests les plus lents -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">🐌 Tests les plus lents (Top 10)</h3>
        <table class="results-table">
          <thead>
            <tr>
              <th>Test</th>
              <th>Fichier</th>
              <th>Framework</th>
              <th>Durée</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE test dans slowest_10]
              <tr>
                <td class="test-name">[test_name]</td>
                <td><code class="text-sm">[file_path_short]</code></td>
                <td><span class="badge badge-tech">[framework]</span></td>
                <td class="font-mono">[duration]s</td>
                <td>
                  <span class="status-indicator [status-class]"></span>
                </td>
              </tr>
            [FIN POUR]
          </tbody>
        </table>
      </div>

      <!-- Inventaire complet des tests -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">📚 Inventaire complet</h3>

        <div class="inventory-stats mb-4">
          <span class="stat-item">
            <strong>[total_suites]</strong> suites de tests
          </span>
          <span class="stat-item">
            <strong>[total_files]</strong> fichiers de test
          </span>
          <span class="stat-item">
            <strong>[active_tests]</strong> tests actifs
          </span>
          <span class="stat-item">
            <strong>[skipped_tests]</strong> tests skipped
          </span>
        </div>

        <div class="accordion-container">
          <button class="accordion" onclick="toggleAccordion('test-inventory')">
            <span class="accordion-title">
              Afficher l'inventaire détaillé par fichier
            </span>
            <span class="accordion-arrow">▼</span>
          </button>

          <div id="test-inventory" class="accordion-content">
            [POUR CHAQUE fichier de test]
              <div class="test-file-section">
                <div class="test-file-header">
                  <code>[file_path]</code>
                  <span class="test-file-count">
                    [suite_count] suite(s), [test_count] test(s)
                  </span>
                </div>

                <div class="test-file-content">
                  [POUR CHAQUE suite dans fichier]
                    <div class="test-suite">
                      <div class="test-suite-name">
                        📦 <strong>[suite_name]</strong>
                      </div>
                      <ul class="test-list">
                        [POUR CHAQUE test dans suite]
                          <li class="test-item [status-class]">
                            <span class="test-status-icon">[icon]</span>
                            [test_name]
                            [SI skipped]
                              <span class="badge badge-gray">SKIPPED</span>
                            [FIN SI]
                          </li>
                        [FIN POUR]
                      </ul>
                    </div>
                  [FIN POUR]
                </div>
              </div>
            [FIN POUR]
          </div>
        </div>
      </div>

      <!-- Logs des frameworks de test -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">📋 Logs d'exécution</h3>
        [POUR CHAQUE framework]
          <button class="btn-sm mb-2" onclick="toggleLog('[framework]-test-log')">
            Voir log [framework]
          </button>
          <pre id="[framework]-test-log" class="log-content hidden">
[contenu de /tmp/test-[framework]-output.log]
          </pre>
        [FIN POUR]
      </div>
    </div>
  </section>
FIN section_test_results

6.7.5 État des émulateurs
**Pseudo-code** :
DÉBUT section_emulators
  <section id="emulators" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">🔥 Émulateurs Firebase</h2>

      <!-- Statut global -->
      <div class="emulator-status-banner [status-class]">
        <div class="status-icon">[icon]</div>
        <div class="status-content">
          <div class="status-title">
            État global: [emulators_status]
          </div>
          <div class="status-description">
            [SI RUNNING]
              Tous les émulateurs configurés sont opérationnels
            [SINON SI NOT_STARTED]
              Émulateurs non démarrés (démarrage optionnel non effectué)
            [SINON]
              Problèmes détectés - voir détails ci-dessous
            [FIN SI]
          </div>
        </div>
      </div>

      <!-- Configuration détectée -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Configuration</h3>

        <table class="results-table">
          <thead>
            <tr>
              <th>Émulateur</th>
              <th>Port</th>
              <th>Config</th>
              <th>Port disponible</th>
              <th>Statut santé</th>
              <th>Temps réponse</th>
            </tr>
          </thead>
          <tbody>
            [POUR CHAQUE émulateur configuré]
              <tr class="[row-status-class]">
                <td>
                  <div class="emulator-name">
                    <span class="emulator-icon">[icon]</span>
                    <strong>[emulator_name]</strong>
                  </div>
                </td>
                <td><code>[port]</code></td>
                <td>
                  <span class="status-indicator success"></span>
                  Configuré
                </td>
                <td>
                  [SI port libre]
                    <span class="badge status-success">✓ Libre</span>
                  [SINON SI émulateur déjà running]
                    <span class="badge status-info">⟳ Déjà actif</span>
                  [SINON]
                    <span class="badge status-error">✗ Occupé (PID [pid])</span>
                  [FIN SI]
                </td>
                <td>
                  [SI emulators_started ET emulator_health == "HEALTHY"]
                    <span class="badge status-success">✓ HEALTHY</span>
                  [SINON SI emulators_started ET emulator_health == "UNREACHABLE"]
                    <span class="badge status-error">✗ UNREACHABLE</span>
                  [SINON]
                    <span class="badge badge-gray">- Non testé</span>
                  [FIN SI]
                </td>
                <td>
                  [SI response_time disponible]
                    <span class="[latency-color-class]">[response_time]ms</span>
                  [SINON]
                    <span class="text-gray-400">-</span>
                  [FIN SI]
                </td>
              </tr>
            [FIN POUR]
          </tbody>
        </table>
      </div>

      <!-- Conflits de ports si détectés -->
      [SI conflits de ports > 0]
        <div class="alert alert-error mt-6">
          <div class="alert-icon">⚠️</div>
          <div class="alert-content">
            <div class="alert-title">Conflits de ports détectés</div>
            <ul class="alert-list">
              [POUR CHAQUE conflit]
                <li>
                  Port <code>[port]</code> ([emulator_name]) occupé par
                  <strong>[process_name]</strong> (PID [pid])
                </li>
              [FIN POUR]
            </ul>
            <p class="mt-2">
              Recommandation : Arrêter les processus conflictuels ou
              modifier les ports dans firebase.json
            </p>
          </div>
        </div>
      [FIN SI]

      <!-- Scripts package.json -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Scripts npm</h3>
        [SI scripts émulateurs détectés]
          <div class="scripts-list">
            [POUR CHAQUE script émulateur]
              <div class="script-item">
                <code class="script-name">npm run [script_name]</code>
                <code class="script-command">[command]</code>
              </div>
            [FIN POUR]
          </div>
        [SINON]
          <div class="alert alert-info">
            <p>Aucun script d'émulateur détecté dans package.json</p>
            <p class="text-sm mt-1">
              Suggestion : Ajouter un script
              <code>"emulators:start": "firebase emulators:start"</code>
            </p>
          </div>
        [FIN SI]
      </div>

      <!-- Données seed -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">Données seed</h3>
        [SI seed data détectées]
          <div class="seed-data-info">
            <div class="info-box">
              <div class="info-label">Répertoire</div>
              <code class="info-value">[seed_data_path]</code>
            </div>
            <div class="info-box">
              <div class="info-label">Taille totale</div>
              <div class="info-value">[seed_data_size] MB</div>
            </div>
          </div>

          <div class="seed-details mt-4">
            <h4 class="text-md font-semibold mb-2">Contenu des données seed</h4>
            <div class="grid grid-cols-3 gap-4">
              [SI firestore seed]
                <div class="seed-item">
                  <div class="seed-icon">🔥</div>
                  <div class="seed-name">Firestore</div>
                  <div class="seed-count">[document_count] documents</div>
                </div>
              [FIN SI]
              [SI auth seed]
                <div class="seed-item">
                  <div class="seed-icon">🔐</div>
                  <div class="seed-name">Authentication</div>
                  <div class="seed-count">[user_count] utilisateurs</div>
                </div>
              [FIN SI]
              [SI storage seed]
                <div class="seed-item">
                  <div class="seed-icon">💾</div>
                  <div class="seed-name">Storage</div>
                  <div class="seed-count">[file_count] fichiers</div>
                </div>
              [FIN SI]
            </div>
          </div>
        [SINON]
          <div class="alert alert-info">
            <p>Aucune donnée seed détectée</p>
            <p class="text-sm mt-1">
              Pour créer des données seed :
              <code>firebase emulators:export ./firebase-export</code>RéessayerClaude n'a pas encore la capacité d'exécuter le code qu'il génère.RContinuer </p>
          </div>
        [FIN SI]
      </div>
  <!-- Logs de démarrage (si émulateurs démarrés) -->
  [SI emulators_started]
    <div class="subsection mt-6">
      <h3 class="text-lg font-semibold mb-3">📋 Logs de démarrage</h3>

      <div class="emulator-startup-info mb-4">
        <div class="grid grid-cols-3 gap-4">
          <div class="info-box">
            <div class="info-label">Temps de démarrage</div>
            <div class="info-value">[startup_duration]s</div>
          </div>
          <div class="info-box">
            <div class="info-label">Émulateur UI</div>
            <div class="info-value">
              <a href="http://localhost:[ui_port]" target="_blank" class="link">
                http://localhost:[ui_port]
              </a>
            </div>
          </div>
          <div class="info-box">
            <div class="info-label">PID du processus</div>
            <div class="info-value"><code>[emulator_pid]</code></div>
          </div>
        </div>
      </div>

      <div class="log-excerpt">
        <h4 class="text-sm font-semibold mb-2">Extrait des logs :</h4>
        <pre class="log-content">[extrait logs startup - lignes importantes]
Exemple :
✔ firestore: Emulator running on http://localhost:8080
✔ functions: Emulator running on http://localhost:5001
✔ auth: Emulator running on http://localhost:9099
✔ All emulators ready! View in UI: http://localhost:4000
</pre>
</div>
      <button class="btn-sm mt-3" onclick="toggleLog('emulator-full-log')">
        📋 Voir log complet de démarrage
      </button>
      <pre id="emulator-full-log" class="log-content hidden">
[contenu complet de /tmp/emulators-startup.log]
</pre>
      <div class="alert alert-warning mt-4">
        <div class="alert-icon">ℹ️</div>
        <div class="alert-content">
          <p>Les émulateurs sont actuellement en cours d'exécution (PID [pid]).</p>
          <button class="btn btn-danger mt-2" onclick="stopEmulators()">
            🛑 Arrêter les émulateurs
          </button>
        </div>
      </div>
    </div>
  [FIN SI]

  <!-- Connexions émulateurs depuis les apps -->
  <div class="subsection mt-6">
    <h3 class="text-lg font-semibold mb-3">🔗 Configuration des applications</h3>
    <p class="text-sm text-gray-600 mb-3">
      Vérification que les applications sont configurées pour utiliser les émulateurs
    </p>

    [POUR CHAQUE app IN [admin, dashboard, public]]
      <div class="app-emulator-config mb-4">
        <h4 class="text-md font-semibold mb-2">[app_name]</h4>

        [Chercher dans code source de l'app des patterns comme :]
        [- connectAuthEmulator()]
        [- connectFirestoreEmulator()]
        [- connectFunctionsEmulator()]
        [- connectStorageEmulator()]

        [SI configuration émulateurs trouvée]
          <div class="config-found">
            <span class="status-indicator success"></span>
            Configuration émulateurs détectée
            <ul class="config-details text-sm mt-2">
              [POUR CHAQUE émulateur configuré dans le code]
                <li>
                  ✓ [emulator_name] →
                  <code>localhost:[port]</code>
                </li>
              [FIN POUR]
            </ul>
          </div>
        [SINON]
          <div class="config-not-found">
            <span class="status-indicator warning"></span>
            Configuration émulateurs non détectée dans le code
            <p class="text-sm text-gray-600 mt-1">
              Les apps pourraient ne pas se connecter aux émulateurs en développement
            </p>
          </div>
        [FIN SI]
      </div>
    [FIN POUR]
  </div>

  <!-- Actions rapides -->
  <div class="subsection mt-6">
    <h3 class="text-lg font-semibold mb-3">⚡ Actions rapides</h3>
    <div class="actions-grid">
      [SI emulators_started == false]
        <button class="btn btn-primary" onclick="startEmulators()">
          ▶️ Démarrer les émulateurs
        </button>
      [FIN SI]

      <button class="btn" onclick="openEmulatorUI()">
        🌐 Ouvrir Emulator UI
      </button>

      <button class="btn" onclick="exportEmulatorData()">
        💾 Exporter les données actuelles
      </button>

      <button class="btn" onclick="clearEmulatorData()">
        🗑️ Effacer les données émulateurs
      </button>
    </div>
  </div>
</div>
  </section>
FIN section_emulators
```

6.7.6 Configuration de déploiement
**Pseudo-code** :
DÉBUT section_deploy_config

  <section id="deploy-config" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">🚀 Configuration de déploiement</h2>
      
      <!-- Vue d'ensemble des déploiements configurés -->
      <div class="deploy-overview">
        <div class="grid grid-cols-3 gap-4">
          <div class="deploy-type-card [active-if-configured]">
            <div class="deploy-type-icon">🗄️</div>
            <div class="deploy-type-name">Data Connect</div>
            <div class="deploy-type-status">
              [SI data_connect_configured]
                <span class="badge status-success">✓ Configuré</span>
              [SINON]
                <span class="badge badge-gray">○ Non configuré</span>
              [FIN SI]
            </div>
          </div>
          
          <div class="deploy-type-card [active-if-configured]">
            <div class="deploy-type-icon">📦</div>
            <div class="deploy-type-name">Static (Hosting)</div>
            <div class="deploy-type-status">
              [SI static_sites_count > 0]
                <span class="badge status-success">
                  ✓ [static_sites_count] site(s)
                </span>
              [SINON]
                <span class="badge badge-gray">○ Non configuré</span>
              [FIN SI]
            </div>
          </div>
          
          <div class="deploy-type-card [active-if-configured]">
            <div class="deploy-type-icon">⚡</div>
            <div class="deploy-type-name">SSR (App Hosting)</div>
            <div class="deploy-type-status">
              [SI ssr_apps_count > 0]
                <span class="badge status-success">
                  ✓ [ssr_apps_count] app(s)
                </span>
              [SINON]
                <span class="badge badge-gray">○ Non configuré</span>
              [FIN SI]
            </div>
          </div>
        </div>
      </div>
      
      <!-- Data Connect (si configuré) -->
      [SI data_connect_configured]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3">🗄️ Data Connect</h3>
          
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div class="info-box">
              <div class="info-label">Service ID</div>
              <code class="info-value">[service_id]</code>
            </div>
            <div class="info-box">
              <div class="info-label">Cloud SQL Instance</div>
              <code class="info-value">[cloudsql_instance]</code>
            </div>
            <div class="info-box">
              <div class="info-label">Database</div>
              <code class="info-value">[database_name]</code>
            </div>
            <div class="info-box">
              <div class="info-label">Source</div>
              <code class="info-value">[source_path]</code>
            </div>
          </div>
          
          <div class="schema-info">
            <h4 class="text-md font-semibold mb-2">Schéma GraphQL</h4>
            [SI schema_status == "FOUND"]
              <div class="schema-found">
                <span class="status-indicator success"></span>
                Schéma détecté : <code>[schema_file]</code>
                
                <div class="schema-stats mt-3">
                  <div class="stat-item">
                    <strong>[types_count]</strong> types
                  </div>
                  <div class="stat-item">
                    <strong>[queries_count]</strong> queries
                  </div>
                  <div class="stat-item">
                    <strong>[mutations_count]</strong> mutations
                  </div>
                </div>
                
                [SI tables_list disponible]
                  <div class="mt-3">
                    <strong>Tables principales :</strong>
                    <div class="tables-list">
                      [POUR CHAQUE table]
                        <span class="badge">[table_name]</span>
                      [FIN POUR]
                    </div>
                  </div>
                [FIN SI]
                
                [SI graphql_codegen == "CONFIGURED"]
                  <div class="mt-3">
                    <span class="status-indicator success"></span>
                    GraphQL Codegen configuré
                  </div>
                [SINON]
                  <div class="alert alert-warning mt-3">
                    <p>GraphQL Codegen non configuré</p>
                    <p class="text-sm">
                      Recommandation : Configurer codegen pour la génération de types
                    </p>
                  </div>
                [FIN SI]
              </div>
            [SINON]
              <div class="alert alert-error">
                <div class="alert-icon">⚠️</div>
                <div class="alert-content">
                  <p>Schéma GraphQL manquant dans <code>[source_path]</code></p>
                  <p class="text-sm mt-1">
                    Data Connect configuré mais schéma non trouvé
                  </p>
                </div>
              </div>
            [FIN SI]
          </div>
          
          <div class="deploy-command mt-4">
            <strong>Commande de déploiement :</strong>
            <code class="command-box">firebase deploy --only dataconnect</code>
          </div>
        </div>
      [FIN SI]
      
      <!-- Static Deploy (Hosting) -->
      [SI static_sites_count > 0]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3">📦 Static Deploy (Hosting)</h3>
          
          [POUR CHAQUE static site]
            <div class="deploy-site-card mb-4">
              <div class="deploy-site-header">
                <h4 class="text-md font-semibold">[app_name]</h4>
                <span class="badge badge-tech">[framework_type]</span>
              </div>
              
              <div class="grid grid-cols-2 gap-4 mt-3">
                <div class="info-box">
                  <div class="info-label">Site Firebase</div>
                  <code class="info-value">[site_id]</code>
                </div>
                <div class="info-box">
                  <div class="info-label">Build directory</div>
                  <code class="info-value">[public_dir]</code>
                </div>
              </div>
              
              <div class="build-check mt-3">
                [SI build_exists]
                  <div class="build-exists">
                    <span class="status-indicator success"></span>
                    Build présent
                    <div class="build-stats">
                      <span class="stat-item">[build_size] MB</span>
                      <span class="stat-item">[files_count] fichiers</span>
                    </div>
                  </div>
                  
                  <div class="main-files mt-2">
                    <strong>Fichiers principaux :</strong>
                    <ul class="file-list-compact">
                      [Liste des fichiers clés détectés]
                      <li>✓ index.html</li>
                      <li>✓ main.js</li>
                      <li>✓ styles.css</li>
                      [etc.]
                    </ul>
                  </div>
                [SINON]
                  <div class="alert alert-warning">
                    <div class="alert-icon">⚠️</div>
                    <div class="alert-content">
                      <p>Build directory <code>[public_dir]</code> n'existe pas</p>
                      <p class="text-sm mt-1">
                        Exécutez <code>npm run build --filter=[app]</code> avant le déploiement
                      </p>
                    </div>
                  </div>
                [FIN SI]
              </div>
              
              <div class="routing-config mt-3">
                <strong>Configuration routing :</strong>
                [SI spa_routing == "CONFIGURED"]
                  <div class="routing-item">
                    <span class="status-indicator success"></span>
                    SPA routing configuré (** → /index.html)
                  </div>
                [SINON]
                  <div class="routing-item">
                    <span class="status-indicator info"></span>
                    Mode SSG (pas de SPA rewrite)
                  </div>
                [FIN SI]
                
                [SI rewrites_count > 0]
                  <div class="routing-item">
                    [rewrites_count] règle(s) de rewrite personnalisée(s)
                  </div>
                [FIN SI]
                
                [SI redirects_count > 0]
                  <div class="routing-item">
                    [redirects_count] redirection(s) configurée(s)
                  </div>
                [FIN SI]
              </div>
              
              <div class="cache-config mt-3">
                <strong>Configuration cache :</strong>
                [SI cache optimisé]
                  <span class="status-indicator success"></span>
                  Cache optimisé (long cache sur assets, no-cache sur HTML)
                [SINON]
                  <span class="status-indicator warning"></span>
                  Cache par défaut (recommandation : optimiser les headers)
                [FIN SI]
              </div>
              
              <div class="deploy-command mt-4">
                <strong>Commande :</strong>
                <code class="command-box">
                  firebase deploy --only hosting:[site_id]
                </code>
              </div>
            </div>
          [FIN POUR]
        </div>
      [FIN SI]
      
      <!-- SSR Deploy (App Hosting) -->
      [SI ssr_apps_count > 0]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3">⚡ SSR Deploy (App Hosting)</h3>
          
          [POUR CHAQUE ssr app]
            <div class="deploy-site-card mb-4">
              <div class="deploy-site-header">
                <h4 class="text-md font-semibold">[app_name]</h4>
                <span class="badge badge-tech">Next.js SSR</span>
              </div>
              
              <div class="grid grid-cols-2 gap-4 mt-3">
                <div class="info-box">
                  <div class="info-label">Configuration</div>
                  <code class="info-value">[apphosting_yaml_path]</code>
                </div>
                <div class="info-box">
                  <div class="info-label">Runtime</div>
                  <code class="info-value">[runtime]</code>
                </div>
              </div>
              
              <div class="resources-config mt-3">
                <h5 class="text-sm font-semibold mb-2">Resources Cloud Run</h5>
                <div class="grid grid-cols-4 gap-3">
                  <div class="resource-item">
                    <div class="resource-label">CPU</div>
                    <div class="resource-value">[cpu]</div>
                  </div>
                  <div class="resource-item">
                    <div class="resource-label">Memory</div>
                    <div class="resource-value">[memory] MB</div>
                  </div>
                  <div class="resource-item">
                    <div class="resource-label">Min instances</div>
                    <div class="resource-value">[minInstances]</div>
                  </div>
                  <div class="resource-item">
                    <div class="resource-label">Max instances</div>
                    <div class="resource-value">[maxInstances]</div>
                  </div>
                </div>
                
                [SI minInstances == 0]
                  <div class="alert alert-info mt-2">
                    <p class="text-sm">
                      ⚠️ minInstances = 0 : cold starts possibles 
                      (délai ~2-5s au premier accès après inactivité)
                    </p>
                  </div>
                [FIN SI]
              </div>
              
              <div class="nextjs-config mt-3">
                <h5 class="text-sm font-semibold mb-2">Configuration Next.js</h5>
                [SI output != "export"]
                  <div class="config-item">
                    <span class="status-indicator success"></span>
                    Mode SSR activé (output: "[output]")
                  </div>
                [SINON]
                  <div class="alert alert-error">
                    <p>Configuration incorrecte : output="export" détecté</p>
                    <p class="text-sm">
                      Pour SSR, supprimez ou changez la valeur de "output" 
                      dans next.config.js
                    </p>
                  </div>
                [FIN SI]
                
                [SI api_routes_count > 0]
                  <div class="config-item">
                    <span class="status-indicator success"></span>
                    [api_routes_count] route(s) API détectée(s)
                  </div>
                [FIN SI]
                
                [SI middleware_exists]
                  <div class="config-item">
                    <span class="status-indicator success"></span>
                    Middleware configuré
                  </div>
                [FIN SI]
              </div>
              
              <div class="ssr-build-check mt-3">
                [SI ssr_build_exists]
                  <div class="build-exists">
                    <span class="status-indicator success"></span>
                    Build SSR présent : <code>[standalone_path]</code>
                    <div class="build-stats">
                      <span class="stat-item">[build_size] MB</span>
                    </div>
                  </div>
                [SINON]
                  <div class="alert alert-warning">
                    <div class="alert-icon">⚠️</div>
                    <div class="alert-content">
                      <p>Build SSR manquant</p>
                      <p class="text-sm mt-1">
                        Exécutez <code>npm run build --filter=[app]</code>
                      </p>
                    </div>
                  </div>
                [FIN SI]
              </div>
              
              <div class="env-vars mt-3">
                <h5 class="text-sm font-semibold mb-2">Variables d'environnement</h5>
                <table class="env-table">
                  <thead>
                    <tr>
                      <th>Variable</th>
                      <th>Source</th>
                      <th>Statut</th>
                    </tr>
                  </thead>
                  <tbody>
                    [POUR CHAQUE env var dans apphosting.yaml]
                      <tr>
                        <td><code>[var_name]</code></td>
                        <td>
                          [SI from secret]
                            <span class="badge badge-secret">Secret</span>
                          [SINON]
                            <span class="badge">Value</span>
                          [FIN SI]
                        </td>
                        <td>
                          [SI var trouvée dans .env local]
                            <span class="status-indicator success"></span>
                            Définie localement
                          [SINON]
                            <span class="status-indicator warning"></span>
                            Non trouvée en local
                          [FIN SI]
                        </td>
                      </tr>
                    [FIN POUR]
                  </tbody>
                </table>
              </div>
              
              <div class="deploy-command mt-4">
                <strong>Commande :</strong>
                <code class="command-box">
                  firebase apphosting:deploy [app]
                </code>
              </div>
            </div>
          [FIN POUR]
        </div>
      [FIN SI]
      
      <!-- Autres services (Functions, Rules) -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">📋 Autres services</h3>
        
        <div class="services-checklist">
          [SI functions configurées]
            <div class="service-item">
              <span class="status-indicator success"></span>
              <strong>Cloud Functions</strong>
              <div class="service-details">
                Source : <code>[functions_source]</code>
                <br>
                Commande : <code>firebase deploy --only functions</code>
              </div>
            </div>
          [FIN SI]
          
          [SI firestore.rules existe]
            <div class="service-item">
              <span class="status-indicator success"></span>
              <strong>Firestore Rules</strong>
              <div class="service-details">
                Fichier : <code>firestore.rules</code>
                <br>
                Commande : <code>firebase deploy --only firestore:rules</code>
              </div>
            </div>
          [FIN SI]
          
          [SI firestore.indexes.json existe]
            <div class="service-item">
              <span class="status-indicator success"></span>
              <strong>Firestore Indexes</strong>
              <div class="service-details">
                Fichier : <code>firestore.indexes.json</code>
                <br>
                Commande : <code>firebase deploy --only firestore:indexes</code>
              </div>
            </div>
          [FIN SI]
          
          [SI storage.rules existe]
            <div class="service-item">
              <span class="status-indicator success"></span>
              <strong>Storage Rules</strong>
              <div class="service-details">
                Fichier : <code>storage.rules</code>
                <br>
                Commande : <code>firebase deploy --only storage</code>
              </div>
            </div>
          [FIN SI]
        </div>
      </div>
      
      <!-- Menu de déploiement interactif -->
      <div class="subsection mt-6">
        <h3 class="text-lg font-semibold mb-3">🚀 Lancer un déploiement</h3>
        
        <div class="deploy-menu">
          <p class="text-sm text-gray-600 mb-4">
            Sélectionnez les composants à déployer :
          </p>
          
          <div class="deploy-options">
            <label class="deploy-option">
              <input type="radio" name="deploy-choice" value="all">
              <div class="option-content">
                <strong>Tout déployer</strong>
                <span class="text-sm text-gray-600">
                  Tous les services configurés
                </span>
              </div>
            </label>
            
            [POUR CHAQUE app]
              <label class="deploy-option">
                <input type="radio" name="deploy-choice" value="[app]">
                <div class="option-content">
                  <strong>[app_name] uniquement</strong>
                  <span class="text-sm text-gray-600">
                    [Type de déploiement : Static/SSR]
                  </span>
                </div>
              </label>
            [FIN POUR]
            
            [SI data_connect_configured]
              <label class="deploy-option">
                <input type="radio" name="deploy-choice" value="dataconnect">
                <div class="option-content">
                  <strong>Data Connect uniquement</strong>
                  <span class="text-sm text-gray-600">
                    Schéma et configuration
                  </span>
                </div>
              </label>
            [FIN SI]
            
            <label class="deploy-option">
              <input type="radio" name="deploy-choice" value="custom">
              <div class="option-content">
                <strong>Déploiement personnalisé</strong>
                <span class="text-sm text-gray-600">
                  Choisir les composants
                </span>
              </div>
            </label>
            
            <label class="deploy-option">
              <input type="radio" name="deploy-choice" value="skip" checked>
              <div class="option-content">
                <strong>Passer (ne pas déployer maintenant)</strong>
              </div>
            </label>
          </div>
          
          <div id="custom-deploy-options" class="hidden mt-4">
            <p class="text-sm font-semibold mb-2">Composants à déployer :</p>
            [Liste de checkboxes pour chaque composant]
          </div>
          
          <div class="deploy-actions mt-6">
            <button class="btn btn-primary btn-lg" onclick="executeDeploy()">
              🚀 Préparer le déploiement
            </button>
            <button class="btn" onclick="validateDeployPrerequisites()">
              ✓ Vérifier les prérequis
            </button>
          </div>
        </div>
      </div>
      
      <!-- Résultat du déploiement (si exécuté) -->
      [SI deploy_executed]
        <div class="subsection mt-6">
          <h3 class="text-lg font-semibold mb-3">📊 Résultat du déploiement</h3>
          
          <div class="deploy-result [status-class]">
            <div class="deploy-result-header">
              <div class="deploy-result-icon">[icon]</div>
              <div class="deploy-result-content">
                <div class="deploy-result-status">[deploy_status]</div>
                <div class="deploy-result-duration">
                  Durée : [deploy_duration]
                </div>
              </div>
            </div>
            
            [SI deploy_status == "SUCCESS"]
              <div class="deploy-urls mt-4">
                <h4 class="text-md font-semibold mb-2">URLs de déploiement :</h4>
                <ul class="url-list">
                  [POUR CHAQUE URL déployée]
                    <li class="url-item">
                      <span class="url-icon">[icon]</span>
                      <a href="[url]" target="_blank" class="url-link">[url]</a>
                      <button class="btn-sm" onclick="copyToClipboard('[url]')">
                        📋 Copier
                      </button>
                      <button class="btn-sm btn-primary" onclick="openUrl('[url]')">
                        🌐 Ouvrir
                      </button>
                    </li>
                  [FIN POUR]
                </ul>
              </div>
              
              <div class="deploy-details mt-4">
                <h4 class="text-md font-semibold mb-2">Détails :</h4>
                <ul class="detail-list">
                  <li>Fichiers uploadés : [files_uploaded]</li>
                  <li>Taille totale : [total_size] MB</li>
                  <li>Cache utilisé : [cache_percentage]%</li>
                  <li>Temps d'upload : [upload_time]s</li>
                  <li>Propagation CDN : ~[propagation_time] minutes</li>
                </ul>
              </div>
            [SINON]
              <div class="deploy-error mt-4">
                <h4 class="text-md font-semibold text-red-600 mb-2">Erreurs :</h4>
                <pre class="error-log">[deploy_error_message]</pre>
                
                <button class="btn btn-primary mt-4" onclick="fixDeployError()">
                  🤖 Analyser et corriger avec Gemini
                </button>
              </div>
            [FIN SI]
            
            <div class="mt-4">
              <button class="btn-sm" onclick="toggleLog('deploy-log')">
                📋 Voir log complet du déploiement
              </button>
              <pre id="deploy-log" class="log-content hidden">
[contenu de /tmp/deploy-output.log]
              </pre>
            </div>
          </div>
        </div>
      [FIN SI]
    </div>
  </section>
FIN section_deploy_config

PHASE 6.8 : Logs détaillés (accordéons)
**Pseudo-code** :
DÉBUT section_detailed_logs

  <section id="detailed-logs" class="container mt-8">
    <div class="card">
      <h2 class="text-xl font-bold mb-4">📋 Logs détaillés</h2>
      
      <p class="text-sm text-gray-600 mb-4">
        Tous les logs d'exécution de l'audit, organisés par phase
      </p>
      
      <!-- Accordéons par phase -->
      <div class="logs-accordion">
        [POUR CHAQUE phase DANS [config, git, build, lint, test, emulators, deploy]]
<div class="accordion-container mb-3">
<button class="accordion" onclick="toggleAccordion('[phase]-logs')">
<span class="accordion-title">
<span class="accordion-icon">[phase_icon]</span>
Logs [phase_name]
<span class="log-size">([log_file_size])</span>
</span>
<span class="accordion-meta">
Durée : [phase_duration]s
</span>
<span class="accordion-arrow">▼</span>
</button>

  <div id="[phase]-logs" class="accordion-content">
          <div class="log-controls mb-2">
            <button class="btn-sm" onclick="downloadLog('[phase]')">
              💾 Télécharger
            </button>
            <button class="btn-sm" onclick="copyLog('[phase]')">
              📋 Copier
            </button>
            <button class="btn-sm" onclick="searchInLog('[phase]')">
              🔍 Rechercher
            </button>
            <label class="log-filter">
              <input type="checkbox" onchange="filterLogLevel('[phase]', 'error')">
              Erreurs uniquement
            </label>
            <label class="log-filter">
              <input type="checkbox" onchange="filterLogLevel('[phase]', 'warning')">
              Warnings uniquement
            </label>
          </div>          <pre class="log-content" id="[phase]-log-content">
[Contenu du fichier log correspondant, avec coloration syntaxique]
[Exemples de formatting :]
<span class="log-timestamp">[2025-10-15 14:32:18]</span> <span class="log-info">INFO</span> Démarrage de la phase [phase]
<span class="log-timestamp">[2025-10-15 14:32:19]</span> <span class="log-success">SUCCESS</span> Configuration détectée
<span class="log-timestamp">[2025-10-15 14:32:20]</span> <span class="log-warning">WARNING</span> Divergence de projectId détectée
<span class="log-timestamp">[2025-10-15 14:32:21]</span> <span class="log-error">ERROR</span> Build failed with exit code 1
</pre>
</div>
</div>
[FIN POUR]    <!-- Log global du script -->
    <div class="accordion-container mb-3">
      <button class="accordion" onclick="toggleAccordion('global-log')">
        <span class="accordion-title">
          <span class="accordion-icon">📄</span>
          Log global du script
          <span class="log-size">([global_log_size])</span>
        </span>
        <span class="accordion-arrow">▼</span>
      </button>      <div id="global-log" class="accordion-content">
        <div class="log-controls mb-2">
          <button class="btn-sm" onclick="downloadLog('global')">
            💾 Télécharger log complet
          </button>
          <button class="btn-sm" onclick="copyLog('global')">
            📋 Copier tout
          </button>
        </div>        <pre class="log-content" id="global-log-content">
[Contenu de /tmp/titanic-health-TIMESTAMP.log]
[Log consolidé de toutes les phases avec horodatage]
</pre>
</div>
</div>
</div>  <!-- Export des logs -->
  <div class="subsection mt-6">
    <h3 class="text-lg font-semibold mb-3">💾 Exporter les logs</h3>
    <div class="export-options">
      <button class="btn" onclick="exportAllLogs('txt')">
        📄 Exporter tous les logs (.txt)
      </button>
      <button class="btn" onclick="exportAllLogs('json')">
        📊 Exporter en JSON
      </button>
      <button class="btn" onclick="exportReport('html')">
        🌐 Exporter ce rapport HTML
      </button>
      <button class="btn" onclick="exportReport('pdf')">
        📕 Générer PDF (via impression)
      </button>
    </div>
  </div>
</div>
  </section>
FIN section_detailed_logs
```
DÉBUT generation_footer
  <footer class="footer mt-12">
    <div class="container">
      <div class="footer-content">
        <!-- Métadonnées du rapport -->
        <div class="footer-section">
          <h4 class="footer-title">📊 Métadonnées</h4>
          <ul class="footer-list">
            <li>Généré le : <strong>[timestamp_complet]</strong></li>
            <li>Projet : <strong>[project_id]</strong></li>
            <li>Environnement : <strong>[environment]</strong></li>
            <li>Système : <strong>macOS</strong></li>
            <li>Node version : <strong>[node_version]</strong></li>
            <li>Firebase CLI : <strong>[firebase_cli_version]</strong></li>
            <li>Durée totale : <strong>[duree_totale_formatee]</strong></li>
            <li>Rapport version : <strong>1.0.0</strong></li>
          </ul>
        </div>
        
        <!-- Résumé des chemins -->
        <div class="footer-section">
          <h4 class="footer-title">📁 Chemins</h4>
          <ul class="footer-list">
            <li>Racine projet : <code>[project_root]</code></li>
            <li>Rapport HTML : <code>[report_path]</code></li>
            <li>Logs globaux : <code>[global_log_path]</code></li>
            <li>Apps : <code>[apps_path]</code></li>
          </ul>
        </div>
        
        <!-- Actions rapides -->
        <div class="footer-section">
          <h4 class="footer-title">⚡ Actions rapides</h4>
          <div class="footer-actions">
            <button class="btn-sm" onclick="refreshReport()">
              🔄 Rafraîchir le rapport
            </button>
            <button class="btn-sm" onclick="runAuditAgain()">
              ▶️ Relancer l'audit
            </button>
            <button class="btn-sm" onclick="window.print()">
              🖨️ Imprimer
            </button>
            <button class="btn-sm" onclick="shareReport()">
              📤 Partager
            </button>
          </div>
        </div>
        
        <!-- Statistiques d'exécution -->
        <div class="footer-section">
          <h4 class="footer-title">⏱️ Timeline des phases</h4>
          <div class="footer-timeline">
            [POUR CHAQUE phase]
              <div class="timeline-bar-item">
                <span class="timeline-label">[phase_name]</span>
                <div class="timeline-bar-container">
                  <div class="timeline-bar-fill [status-class]" 
                       style="width: [phase_percent]%"
                       title="[phase_duration]s">
                  </div>
                </div>
                <span class="timeline-duration">[phase_duration]s</span>
              </div>
            [FIN POUR]
          </div>
        </div>
      </div>
      
      <!-- Copyright et signature -->
      <div class="footer-bottom">
        <div class="footer-signature">
          <p class="text-sm text-gray-600">
            🚢 <strong>Titanic Health Check</strong> - Audit automatisé Firebase Cloud
          </p>
          <p class="text-xs text-gray-500 mt-1">
            Généré par script bash • Conçu pour Turborepo • 
            Assisté par Gemini AI
          </p>
        </div>
        
        <div class="footer-links">
          <a href="#executive-summary" class="footer-link">↑ Retour en haut</a>
          <a href="https://firebase.google.com/docs" target="_blank" class="footer-link">
            📚 Documentation Firebase
          </a>
          <a href="https://turbo.build/repo/docs" target="_blank" class="footer-link">
            📖 Turborepo Docs
          </a>
        </div>
      </div>
    </div>
  </footer>
FIN generation_footer
DÉBUT generation_javascript
  <script>
    // ====================================
    // VARIABLES GLOBALES
    // ====================================
    const reportData = {
      timestamp: '[timestamp]',
      projectId: '[project_id]',
      globalStatus: '[GLOBAL_STATUS]',
      healthScore: [health_score],
      phases: [phase_results_json]
    };
    
    // ====================================
    // ACCORDÉONS
    // ====================================
    function toggleAccordion(id) {
      const content = document.getElementById(id);
      const button = content.previousElementSibling;
      
      if (content.classList.contains('open')) {
        content.classList.remove('open');
        button.classList.remove('active');
        button.querySelector('.accordion-arrow').textContent = '▼';
      } else {
        content.classList.add('open');
        button.classList.add('active');
        button.querySelector('.accordion-arrow').textContent = '▲';
      }
    }
    
    // Fermer tous les accordéons
    function collapseAll() {
      document.querySelectorAll('.accordion-content.open').forEach(content => {
        content.classList.remove('open');
        content.previousElementSibling.classList.remove('active');
        content.previousElementSibling.querySelector('.accordion-arrow').textContent = '▼';
      });
    }
    
    // Ouvrir tous les accordéons
    function expandAll() {
      document.querySelectorAll('.accordion-content').forEach(content => {
        content.classList.add('open');
        content.previousElementSibling.classList.add('active');
        content.previousElementSibling.querySelector('.accordion-arrow').textContent = '▲';
      });
    }
    
    // ====================================
    // LOGS
    // ====================================
    function toggleLog(logId) {
      const logElement = document.getElementById(logId);
      if (logElement.classList.contains('hidden')) {
        logElement.classList.remove('hidden');
      } else {
        logElement.classList.add('hidden');
      }
    }
    
    function downloadLog(phase) {
      const logContent = document.getElementById(phase + '-log-content').textContent;
      const blob = new Blob([logContent], { type: 'text/plain' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `titanic-health-${phase}-log.txt`;
      a.click();
      window.URL.revokeObjectURL(url);
    }
    
    function copyLog(phase) {
      const logContent = document.getElementById(phase + '-log-content').textContent;
      navigator.clipboard.writeText(logContent).then(() => {
        showNotification('Log copié dans le presse-papiers', 'success');
      });
    }
    
    function searchInLog(phase) {
      const searchTerm = prompt('Rechercher dans le log :');
      if (!searchTerm) return;
      
      const logElement = document.getElementById(phase + '-log-content');
      const logContent = logElement.textContent;
      
      // Highlight search results
      const regex = new RegExp(searchTerm, 'gi');
      const highlighted = logContent.replace(regex, match => 
        `<mark>${match}</mark>`
      );
      
      logElement.innerHTML = highlighted;
    }
    
    function filterLogLevel(phase, level) {
      const logElement = document.getElementById(phase + '-log-content');
      const lines = logElement.textContent.split('\n');
      
      const filtered = lines.filter(line => {
        if (level === 'error') return line.includes('ERROR');
        if (level === 'warning') return line.includes('WARNING');
        return true;
      });
      
      logElement.textContent = filtered.join('\n');
    }
    
    // ====================================
    // CORRECTIONS AVEC GEMINI
    // ====================================
    function fixBuild(app) {
      showNotification('Préparation de la requête pour Gemini...', 'info');
      
      // Extraire les erreurs de build pour cette app
      const buildErrors = extractBuildErrors(app);
      
      // Construire prompt pour Gemini
      const prompt = `Fix the following build errors in the ${app} application:
      
Build errors:
${buildErrors}

Provide:

1. Root cause analysis
2. Exact files to modify
3. Code changes needed
4. Explanation`;

   // Afficher modal avec le prompt
   showGeminiPromptModal('Build Errors - ' + app, prompt, buildErrors);
   }

   function fixTests() {
   showNotification('Préparation de la requête pour Gemini...', 'info');

   const failedTests = extractFailedTests();

   const prompt = `Fix the following failed tests:

${failedTests}

For each test:

1. Analyze the error
2. Identify if test or code issue
3. Provide fix
4. Explain`;

   showGeminiPromptModal('Failed Tests', prompt, failedTests);
   }

   function fixLint() {
   showNotification('Préparation de la requête pour Gemini...', 'info');

   const lintErrors = extractLintErrors();

   const prompt = `Fix the following ESLint errors:

${lintErrors}

For each error:

1. Identify file and line
2. Explain rule violation
3. Provide fixed code`;

   showGeminiPromptModal('Lint Errors', prompt, lintErrors);
   }

   function fixDeployError() {
   showNotification('Préparation de la requête pour Gemini...', 'info');

   const deployLog = document.getElementById('deploy-log').textContent;

   const prompt = `Analyze this Firebase deployment error:

${deployLog}

Provide:

1.  Root cause
2.  Configuration issue or auth issue?
3.  Step-by-step fix
4.  Corrected config if needed`;
          showGeminiPromptModal('Deploy Error', prompt, deployLog);
        }

        function showGeminiPromptModal(title, prompt, context) {
          // Créer modal
          const modal = document.createElement('div');
          modal.className = 'modal';
          modal.innerHTML = `
            <div class="modal-content">
              <div class="modal-header">
                <h3>🤖 Requête pour Gemini - ${title}</h3>
                <button onclick="closeModal()" class="modal-close">×</button>
              </div>
              <div class="modal-body">
                <p class="mb-3">
                  Copiez le prompt ci-dessous et envoyez-le à Gemini dans votre IDE :
                </p>
                <textarea id="gemini-prompt" class="prompt-textarea" readonly>${prompt}</textarea>

                <div class="mt-4">
                  <button class="btn btn-primary" onclick="copyPromptToClipboard()">
                    📋 Copier le prompt
                  </button>
                  <button class="btn" onclick="openInIDE()">
                    💻 Ouvrir dans l'IDE
                  </button>
                </div>

                <div class="alert alert-info mt-4">
                  <p class="text-sm">
                    <strong>Instructions :</strong>
                    <br>1. Copiez le prompt
                    <br>2. Ouvrez Gemini dans VS Code
                    <br>3. Collez le prompt
                    <br>4. Appliquez les corrections suggérées
                  </p>
                </div>
              </div>
            </div>
          `;

          document.body.appendChild(modal);
          modal.style.display = 'flex';
        }

        function copyPromptToClipboard() {
          const textarea = document.getElementById('gemini-prompt');
          textarea.select();
          document.execCommand('copy');
          showNotification('Prompt copié ! Envoyez-le à Gemini', 'success');
        }

        // ====================================
        // DÉPLOIEMENT
        // ====================================
        function executeDeploy() {
          const selectedOption = document.querySelector('input[name="deploy-choice"]:checked').value;

          if (selectedOption === 'skip') {
            showNotification('Déploiement ignoré', 'info');
            return;
          }

          showNotification('Préparation du déploiement...', 'info');

          // Construire commande
          let command = 'firebase deploy';

          switch(selectedOption) {
            case 'all':
              command += ' --project=[project_id]';
              break;
            case 'admin':
              command += ' --only hosting:admin-app-prod';
              break;
            case 'dashboard':
              command += ' --only hosting:dashboard-app-prod';
              break;
            case 'public':
              command += ' --only hosting:public-site-prod';
              break;
            case 'dataconnect':
              command += ' --only dataconnect';
              break;
            case 'custom':
              // Construire depuis checkboxes
              const selected = getSelectedDeployComponents();
              command += ' --only ' + selected.join(',');
              break;
          }

          // Afficher confirmation
          if (confirm(`Exécuter la commande :\n${command}\n\nContinuer ?`)) {
            showNotification('Exécution du déploiement...', 'info');
            // Dans un vrai script, ceci déclencherait l'exécution bash
            // Ici, afficher seulement la commande
            showCommandToRun(command);
          }
        }

        function validateDeployPrerequisites() {
          showNotification('Vérification des prérequis...', 'info');

          const checks = [
            { name: 'Builds existent', status: checkBuildsExist() },
            { name: 'Pas d\'erreurs critiques', status: checkNoCriticalErrors() },
            { name: 'Firebase CLI authentifié', status: checkFirebaseAuth() }
          ];

          const allPassed = checks.every(check => check.status);

          // Afficher résultats
          showPrerequisitesModal(checks, allPassed);
        }

        // ====================================
        // UTILITAIRES
        // ====================================
        function showNotification(message, type = 'info') {
          const notification = document.createElement('div');
          notification.className = `notification notification-${type}`;
          notification.textContent = message;

          document.body.appendChild(notification);

          setTimeout(() => {
            notification.classList.add('show');
          }, 10);

          setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
          }, 3000);
        }

        function copyToClipboard(text) {
          navigator.clipboard.writeText(text).then(() => {
            showNotification('Copié !', 'success');
          });
        }

        function openUrl(url) {
          window.open(url, '_blank');
        }

        function openFile(filepath, line) {
          // Construct VS Code URL
          const vscodeUrl = `vscode://file${filepath}:${line}`;
          window.location.href = vscodeUrl;
        }

        function refreshReport() {
          if (confirm('Relancer l\'audit complet ? Cette action peut prendre quelques minutes.')) {
            window.location.href = 'javascript:void(0)'; // Trigger reload
            showNotification('Relancement de l\'audit...', 'info');
          }
        }

        function exportReport(format) {
          if (format === 'html') {
            // Clone et nettoyer le HTML
            const clone = document.documentElement.cloneNode(true);
            const html = clone.outerHTML;
            const blob = new Blob([html], { type: 'text/html' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `titanic-health-report-${Date.now()}.html`;
            a.click();
            window.URL.revokeObjectURL(url);
          } else if (format === 'pdf') {
            window.print();
          }
        }

        function exportAllLogs(format) {
          // Collecter tous les logs
          const allLogs = {};
          ['config', 'git', 'build', 'lint', 'test', 'emulators', 'deploy'].forEach(phase => {
            const logElement = document.getElementById(phase + '-log-content');
            if (logElement) {
              allLogs[phase] = logElement.textContent;
            }
          });

          if (format === 'json') {
            const json = JSON.stringify({ ...reportData, logs: allLogs }, null, 2);
            const blob = new Blob([json], { type: 'application/json' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `titanic-health-logs-${Date.now()}.json`;
            a.click();
            window.URL.revokeObjectURL(url);
          } else {
            let allLogsText = '';
            Object.entries(allLogs).forEach(([phase, log]) => {
              allLogsText += `\n\n========== ${phase.toUpperCase()} ==========\n\n${log}`;
            });

            const blob = new Blob([allLogsText], { type: 'text/plain' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `titanic-health-all-logs-${Date.now()}.txt`;
            a.click();
            window.URL.revokeObjectURL(url);
          }
        }

        // ====================================
        // INITIALISATION
        // ====================================
        document.addEventListener('DOMContentLoaded', function() {
          console.log('🚢 Titanic Health Check Report loaded');
          console.log('Report data:', reportData);

          // Ajouter smooth scroll
          document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
              e.preventDefault();
              const target = document.querySelector(this.getAttribute('href'));
              if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
              }
            });
          });

          // Auto-expand erreurs critiques
          if (reportData.globalStatus === 'CRITICAL') {
            document.querySelectorAll('.status-error').forEach(elem => {
              const accordion = elem.closest('.accordion-container');
              if (accordion) {
                const button = accordion.querySelector('.accordion');
                button.click();
              }
            });
          }
        });
      </script>
    FIN generation_javascript

PHASE 6.11 : Écriture finale du fichier HTML
**Pseudo-code** :
DÉBUT ecriture_fichier_html

- Définir chemin de sortie :
  output_path = "[project_root]/apps/admin/reports/titanic-health.html"
  OU output_path = "[project_root]/superdev/reports/titanic-health.html"

- Créer répertoire parent si nécessaire :
  mkdir -p $(dirname $output_path)

- Assembler le HTML complet :

  - Concaténer toutes les sections générées (6.2 à 6.10)
  - Injecter toutes les variables dynamiques
  - Remplacer tous les placeholders [variable] par valeurs réelles

- Écrire dans fichier :
  echo "$html_content" > $output_path

- Vérifier écriture réussie :
  SI fichier existe ET taille > 0 ALORS
  html_generated = true
  Afficher : "✓ Rapport HTML généré : $output_path"
  SINON
  html_generated = false
  STATUS global = "ERROR"
  Afficher : "✗ Échec génération HTML"
  RETOUR code erreur 1
  FIN SI

- Calculer taille du rapport :
  report_size = $(stat -f%z "$output_path") # macOS
  report_size_mb = $(echo "scale=2; $report_size / 1048576" | bc)
- Créer copie horodatée (historique) :
  cp "$output_path" "$output_path.$(date +%Y%m%d-%H%M%S).html"

- Afficher résumé :
  echo "========================================="
  echo "🚢 TITANIC HEALTH CHECK - TERMINÉ"
  echo "========================================="
  echo "Statut global : $GLOBAL_STATUS"
  echo "Score de santé : $health_score%"
  echo "Durée totale : $duree_totale"
  echo "Rapport généré : $output_path"
  echo "Taille : $report_size_mb MB"
  echo "========================================="

- Proposer d'ouvrir le rapport :
  echo ""
  read -p "Ouvrir le rapport dans le navigateur ? (y/n) " open_browser
      SI open_browser == "y" OU open_browser == "Y" ALORS
        open "$output_path"  # macOS
        Afficher : "✓ Rapport ouvert dans le navigateur par défaut"
      FIN SI
  FIN ecriture_fichier_html
  DÉBUT execution_globale
  #!/bin/bash
  set -euo pipefail # Exit on error, undefined var, pipe failure

# Trap pour cleanup

trap cleanup EXIT INT TERM

function cleanup() {
echo "Nettoyage..." # Arrêter émulateurs si démarrés
if [ ! -z "$EMULATOR_PID" ]; then
kill $EMULATOR_PID 2>/dev/null || true
fi # Supprimer fichiers temporaires
rm -f /tmp/titanic-health-\*.log 2>/dev/null || true
}

# Afficher bannière

echo "========================================"
echo "🚢 TITANIC HEALTH CHECK"
echo " Firebase Cloud Audit Tool"
echo "========================================"
echo ""

# PHASE 0 : Initialisation

echo "[1/7] 🔧 Initialisation..."
TIMESTAMP_START=$(date +%s)
  TIMESTAMP_ISO=$(date +"%Y-%m-%dT%H:%M:%S%z")
GLOBAL_STATUS="OK"
PROJECT_ROOT=$(find_project_root)
  cd "$PROJECT_ROOT"

# PHASE 1 : Configuration Firebase

echo "[2/7] ⚙️ Vérification configuration Firebase..."
check_firebase_config
validate_config_coherence

# PHASE 1.5 : État Git

echo "[3/7] 📚 Analyse état Git..."
check_git_status
extract_git_history

# PHASE 2 : Build Check

echo "[4/7] 🔨 Vérification des builds..."
detect_turborepo_config
build_all_apps
run_lint

# Si erreurs critiques de build

if [ "$BUILD_FAILED" = true ]; then
echo ""
echo "❌ Des erreurs de build ont été détectées."
read -p "Voulez-vous appeler Gemini pour les corriger ? (y/n) " fix_build
if [ "$fix_build" = "y" ]; then
propose_gemini_fix "build"
fi
fi

# PHASE 3 : Tests

echo "[5/7] 🧪 Exécution des tests..."
detect_test_frameworks
run_all_tests

# Si tests échoués

if [ "$TESTS_FAILED" = true ]; then
echo ""
echo "❌ Des tests ont échoué."
read -p "Voulez-vous appeler Gemini pour les corriger ? (y/n) " fix_tests
if [ "$fix_tests" = "y" ]; then
propose_gemini_fix "tests"
fi
fi

# PHASE 4 : Émulateurs

echo "[6/7] 🔥 Vérification émulateurs Firebase..."
detect_emulators_config
echo ""
read -p "Démarrer les émulateurs pour vérification ? (y/n) " start_emu
if [ "$start_emu" = "y" ]; then
start_emulators
check_emulators_health
fi

# PHASE 5 : Deploy Config

echo "[7/7] 🚀 Analyse configuration déploiement..."
detect_data_connect
detect_static_deploy
detect_ssr_deploy

# Proposer déploiement

echo ""
echo "========================================="
echo "Configuration déploiement détectée."
echo "Voulez-vous déployer maintenant ?"
echo "========================================="
echo "[0] Tout déployer"
echo "[1] Admin uniquement"
echo "[2] Dashboard uniquement"
echo "[3] Public uniquement"
echo "[4] Data Connect uniquement"
echo "[5] Personnalisé"
echo "[6] Passer (ne pas déployer)"
echo ""
read -p "Choix : " deploy_choice
case $deploy_choice in 0) deploy_all ;;

1. deploy_app "admin" ;;
2. deploy_app "dashboard" ;;
3. deploy_app "public" ;;
4. deploy_dataconnect ;;
5. deploy_custom ;;
6. echo "Déploiement ignoré" ;;
   \*) echo "Choix invalide, déploiement ignoré" ;;
   esac
   PHASE 6 : Génération rapport HTML
   echo ""
   echo "📊 Génération du rapport HTML..."
   calculate_global_status
   generate_html_report
   Fin
   TIMESTAMP_END=$(date +%s)
DURATION=$((TIMESTAMP_END - TIMESTAMP_START))
   echo ""
   echo "========================================="
   echo "✅ AUDIT TERMINÉ"
   echo "========================================="
   echo "Statut : $GLOBAL_STATUS"
echo "Score : $HEALTH_SCORE%"
echo "Durée : ${DURATION}s"
echo "Rapport : $REPORT_PATH"
echo "========================================="
Ouvrir rapport
echo ""
read -p "Ouvrir le rapport dans le navigateur ? (y/n) " open_report
if [ "$open_report" = "y" ]; then
   open "$REPORT_PATH"
   fi
   exit 0
   FIN execution_globale

### 7.2 Gestion des erreurs et validations

**Pseudo-code** :

```
DÉBUT gestion_erreurs
  # Validation à chaque phase
  function validate_phase() {
    local phase_name=$1
    local phase_status=$2

    case $phase_status in
      "SUCCESS")
        echo "✓ $phase_name : SUCCESS"
        ;;
      "WARNING")
        echo "⚠ $phase_name : WARNING"
        GLOBAL_STATUS="WARNING"
        ;;
      "ERROR")
        echo "✗ $phase_name : ERROR"
        GLOBAL_STATUS="ERROR"

        # Demander si continuer
        echo ""
        read -p "Continuer malgré l'erreur ? (y/n) " continue_on_error

        if [ "$continue_on_error" != "y" ]; then
          echo "Arrêt de l'audit."
          generate_partial_report "$phase_name"
          exit 1
        fi
        ;;
    esac
  }

  # Génération rapport partiel en cas d'arrêt prématuré
  function generate_partial_report() {
    local failed_phase=$1

    echo "Génération d'un rapport partiel..."

    # Générer HTML avec sections complétées uniquement
    # Marquer phase échouée
    # Inclure logs jusqu'au point d'échec

    REPORT_PATH="$PROJECT_ROOT/apps/admin/reports/titanic-health-PARTIAL.html"
    generate_html_report

    echo "Rapport partiel généré : $REPORT_PATH"
  }

  # Vérification des dépendances
  function check_dependencies() {
    local missing_deps=()

    # Commandes obligatoires
    command -v node >/dev/null 2>&1 || missing_deps+=("node")
    command -v npm >/dev/null 2>&1 || missing_deps+=("npm")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v firebase >/dev/null 2>&1 || missing_deps+=("firebase-tools")

    # Commandes optionnelles mais recommandées
    if ! command -v jq >/dev/null 2>&1; then
      echo "⚠ Warning: jq non installé (recommandé pour parsing JSON)"
      echo "  Installation: brew install jq"
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
      echo "❌ Dépendances manquantes : ${missing_deps[*]}"
      echo ""
      echo "Installation requise :"
      for dep in "${missing_deps[@]}"; do
        case $dep in
          "firebase-tools")
            echo "  npm install -g firebase-tools"
            ;;
          *)
            echo "  brew install $dep"
            ;;
        esac
      done
      exit 1
    fi
  }

  # Vérification structure projet
  function validate_project_structure() {
    if [ ! -f "package.json" ]; then
      echo "❌ package.json non trouvé. Êtes-vous à la racine du projet ?"
      exit 1
    fi

    if [ ! -d "apps" ]; then
      echo "❌ Répertoire apps/ non trouvé. Structure Turborepo invalide ?"
      exit 1
    fi

    # Vérifier présence des 3 apps
    local required_apps=("admin" "dashboard" "public")
    for app in "${required_apps[@]}"; do
      if [ ! -d "apps/$app" ]; then
        echo "⚠ Warning: apps/$app non trouvé"
      fi
    done
  }

  # Timeout pour commandes longues
  function run_with_timeout() {
    local timeout=$1
    shift
    local command="$@"

    # Utiliser timeout command (GNU coreutils)
    # Sur macOS, utiliser gtimeout (brew install coreutils)
    if command -v gtimeout >/dev/null 2>&1; then
      gtimeout $timeout $command
      return $?
    elif command -v timeout >/dev/null 2>&1; then
      timeout $timeout $command
      return $?
    else
      # Fallback sans timeout
      echo "⚠ Warning: timeout command non disponible"
      $command
      return $?
    fi
  }
FIN gestion_erreurs
```

### 7.3 Interactions avec Gemini

**Pseudo-code** :

```
DÉBUT interactions_gemini
  # Fonction générique pour proposer correction Gemini
  function propose_gemini_fix() {
    local fix_type=$1  # "build", "tests", "lint", "deploy"

    echo ""
    echo "========================================="
    echo "🤖 CORRECTION AVEC GEMINI"
    echo "========================================="

    # Préparer le contexte
    local context=""
    local prompt=""

    case $fix_type in
      "build")
        context=$(extract_build_errors)
        prompt="Fix the following build errors in a Turborepo Firebase project:

Build errors:
$context

Analyze and provide:
1. Root cause for each error
2. Files that need modification
3. Exact code changes (as diffs)
4. Explanation of fixes

Project structure: Turborepo with apps (admin, dashboard, public)"
        ;;

      "tests")
        context=$(extract_failed_tests)
        prompt="Fix the following failed tests:

Failed tests:
$context

For each test:
1. Analyze the error
2. Determine if test code or application code needs fixing
3. Provide corrected code
4. Explain the issue"
        ;;

      "lint")
        context=$(extract_lint_errors)
        prompt="Fix the following ESLint errors:

Lint errors:
$context

For each error:
1. Identify file and line
2. Explain the rule violation
3. Provide corrected code snippet"
        ;;

      "deploy")
        context=$(cat /tmp/deploy-output.log)
        prompt="Analyze this Firebase deployment error:

Deployment log:
$context

Provide:
1. Root cause identification
2. Type of issue (config/auth/build/quota)
3. Step-by-step fix instructions
4. Corrected configuration if needed"
        ;;
    esac

    # Sauvegarder prompt dans fichier
    local prompt_file="/tmp/gemini-prompt-$fix_type.txt"
    echo "$prompt" > "$prompt_file"

    echo ""
    echo "Prompt préparé pour Gemini :"
    echo "----------------------------"
    echo "$prompt" | head -n 20
    echo "..."
    echo "----------------------------"
    echo ""
    echo "Le prompt complet a été sauvegardé : $prompt_file"
    echo ""
    echo "INSTRUCTIONS :"
    echo "1. Ouvrez Gemini dans VS Code"
    echo "2. Copiez le contenu du fichier : $prompt_file"
    echo "3. Collez dans Gemini et envoyez"
    echo "4. Appliquez les corrections suggérées"
    echo "5. Re-lancez l'audit pour vérifier"
    echo ""

    # Copier dans clipboard si pbcopy disponible (macOS)
    if command -v pbcopy >/dev/null 2>&1; then
      cat "$prompt_file" | pbcopy
      echo "✓ Prompt copié dans le presse-papiers !"
      echo ""
    fi

    read -p "Appuyez sur Entrée quand vous avez appliqué les corrections..."

    # Proposer de relancer la phase concernée
    echo ""
    read -p "Relancer la vérification de $fix_type ? (y/n) " rerun

    if [ "$rerun" = "y" ]; then
      case $fix_type in
        "build")
          build_all_apps
          ;;
        "tests")
          run_all_tests
          ;;
        "lint")
          run_lint
          ;;
        "deploy")
          # Re-proposer menu déploiement
          echo "Re-proposer déploiement après corrections..."
          ;;
      esac
    fi
  }

  # Extraction contexte pour Gemini
  function extract_build_errors() {
    local errors=""

    for app in admin dashboard public; do
      if [ -f "/tmp/build-$app.log" ]; then
        local app_errors=$(grep -i "error" "/tmp/build-$app.log" | head -n 20)
        if [ ! -z "$app_errors" ]; then
          errors+="
=== $app ===
$app_errors
"
        fi
      fi
    done

    echo "$errors"
  }

  function extract_failed_tests() {
    local failures=""

    # Parser les résultats de tests (dépend du framework)
    # Jest format
    if [ -f "/tmp/jest-results.json" ]; then
      # Parser JSON avec jq si disponible
      if command -v jq >/dev/null 2>&1; then
        failures=$(jq -r '.testResults[] | select(.status == "failed") |
          "File: \(.name)\n" +
          (.assertionResults[] | select(.status == "failed") |
          "  Test: \(.fullName)\n  Error: \(.failureMessages[0])\n")'
          /tmp/jest-results.json)
      else
        # Fallback : extraire du log texte
        failures=$(grep -A 5 "FAIL" /tmp/test-output.log)
      fi
    fi

    echo "$failures"
  }

  function extract_lint_errors() {
    if [ -f "/tmp/lint.log" ]; then
      # Extraire seulement les erreurs (pas warnings)
      grep -E "error  " /tmp/lint.log | head -n 30
    fi
  }
FIN interactions_gemini
```

---

## SECTION 8 : Liste de vérifications supplémentaires et cas limites

### 8.1 Vérifications optionnelles avancées

**Pseudo-code** :

```
DÉBUT verifications_avancees
  # Ces vérifications peuvent être ajoutées selon besoins

  # 1. Cohérence des versions de dépendances
  function check_dependency_versions() {
    echo "Vérification cohérence des versions..."

    # Vérifier que toutes les apps utilisent les mêmes versions
    # de dépendances critiques (react, firebase, etc.)

    local critical_deps=("react" "firebase" "next" "typescript")

    for dep in "${critical_deps[@]}"; do
      local versions=()

      for app in admin dashboard public; do
        local version=$(jq -r ".dependencies.\"$dep\" // .devDependencies.\"$dep\" // \"not-found\""
          "apps/$app/package.json")
        versions+=("$app:$version")
      done

      # Comparer versions
      local unique_versions=$(printf '%s\n' "${versions[@]}" | sort -u | wc -l)

      if [ $unique_versions -gt 1 ]; then
        echo "⚠ Warning: Versions divergentes pour $dep"
        printf '%s\n' "${versions[@]}"
      fi
    done
  }

  # 2. Vérification des secrets manquants
  function check_missing_secrets() {
    echo "Vérification des secrets Firebase..."

    # Lister les secrets référencés dans apphosting.yaml
    local secret_refs=$(find . -name "apphosting.yaml" -exec grep "secret:" {} \; |
      sed 's/.*secret: //' | sort -u)

    if [ ! -z "$secret_refs" ]; then
      echo "Secrets requis détectés :"
      echo "$secret_refs"
      echo ""
      echo "⚠ Vérifiez que ces secrets sont configurés dans Firebase Console"
      echo "  → https://console.firebase.google.com/project/$PROJECT_ID/settings/secrets"
    fi
  }

  # 3. Analyse de sécurité basique des rules
  function analyze_security_rules() {
    echo "Analyse des règles de sécurité..."

    # Firestore rules
    if [ -f "firestore.rules" ]; then
      # Vérifier patterns dangereux
      if grep -q "allow read, write: if true" firestore.rules; then
        echo "❌ CRITIQUE : Règles Firestore trop permissives (allow if true)"
      fi

      if ! grep -q "allow read" firestore.rules; then
        echo "⚠ Warning : Aucune règle de lecture détectée dans firestore.rules"
      fi
    fi

    # Storage rules
    if [ -f "storage.rules" ]; then
      if grep -q "allow read, write: if true" storage.rules; then
        echo "❌ CRITIQUE : Règles Storage trop permissives (allow if true)"
      fi
    fi
  }

  # 4. Vérification taille des bundles
  function check_bundle_sizes() {
    echo "Vérification taille des bundles..."

    for app in admin dashboard public; do
      local build_dir=""

      # Détecter répertoire de build
      if [ -d "apps/$app/out" ]; then
        build_dir="apps/$app/out"
      elif [ -d "apps/$app/dist" ]; then
        build_dir="apps/$app/dist"
      elif [ -d "apps/$app/build" ]; then
        build_dir="apps/$app/build"
      fi

      if [ ! -z "$build_dir" ]; then
        # Trouver plus gros fichiers JS
        local largest_js=$(find "$build_dir" -name "*.js" -type f -exec ls -lh {} \; |
          sort -k5 -hr | head -n 5)

        echo "📦 $app - Plus gros bundles JS :"
        echo "$largest_js"

        # Warning si bundle > 500KB
        local large_bundles=$(find "$build_dir" -name "*.js" -type f -size +500k)
        if [ ! -z "$large_bundles" ]; then
          echo "⚠ Warning: Bundles > 500KB détectés (considérer code splitting)"
        fi
      fi
    done
  }

  # 5. Ports d'émulateurs déjà utilisés
  function check_port_availability() {
    local ports=(9099 8080 5001 9199 5000 4000)  # Ports Firebase par défaut
    local conflicts=()

    for port in "${ports[@]}"; do
      if lsof -i :$port >/dev/null 2>&1; then
        local process=$(lsof -i :$port | tail -n 1 | awk '{print $1 " (PID " $2 ")"}')
        conflicts+=("Port $port occupé par $process")
      fi
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
      echo "⚠ Conflits de ports détectés :"
      printf '%s\n' "${conflicts[@]}"
      return 1
    fi

    return 0
  }

  # 6. Vérification compatibilité Node version
  function check_node_version() {
    local current_version=$(node -v | sed 's/v//')
    local required_version="18.0.0"

    # Comparer versions (simpliste)
    local current_major=$(echo $current_version | cut -d. -f1)
    local required_major=$(echo $required_version | cut -d. -f1)

    if [ $current_major -lt $required_major ]; then
      echo "⚠ Warning: Node.js $current_version détecté"
      echo "  Version recommandée : >=$required_version"
      echo "  Certaines fonctionnalités Firebase requièrent Node 18+"
    fi
  }

  # 7. Détection de fichiers sensibles commités
  function check_committed_secrets() {
    echo "Recherche de secrets potentiellement commités..."

    # Patterns de fichiers sensibles
    local sensitive_patterns=(
      "*.env.local"
      "*.env.production"
      ".env.local"
      ".env.production"
      "*serviceAccountKey.json"
      "*firebase-adminsdk*.json"
    )

    local found_secrets=()

    for pattern in "${sensitive_patterns[@]}"; do
      local files=$(git ls-files "$pattern" 2>/dev/null)
      if [ ! -z "$files" ]; then
        found_secrets+=("$files")
      fi
    done

    if [ ${#found_secrets[@]} -gt 0 ]; then
      echo "❌ ALERTE SÉCURITÉ : Fichiers sensibles trouvés dans Git :"
      printf '%s\n' "${found_secrets[@]}"
      echo ""
      echo "Action recommandée :"
      echo "  1. Ajouter à .gitignore"
      echo "  2. Supprimer de l'historique Git (git filter-branch ou BFG)"
      echo "  3. Regénérer les secrets compromis"
    fi
  }

  # 8. Vérification .gitignore
  function check_gitignore() {
    if [ ! -f ".gitignore" ]; then
      echo "⚠ Warning: .gitignore manquant à la racine"
      return
    fi

    # Patterns importants qui devraient être ignorés
    local required_patterns=(
      "node_modules"
      ".env.local"
      ".env.production"
      "*.log"
      ".firebase"
      "firebase-debug.log"
    )

    local missing_patterns=()

    for pattern in "${required_patterns[@]}"; do
      if ! grep -q "^$pattern" .gitignore; then
        missing_patterns+=("$pattern")
      fi
    done

    if [ ${#missing_patterns[@]} -gt 0 ]; then
      echo "⚠ Patterns manquants dans .gitignore :"
      printf '%s\n' "${missing_patterns[@]}"
    fi
  }

  # 9. Vérification des scripts package.json
  function check_npm_scripts() {
    echo "Vérification des scripts npm..."

    # Scripts recommandés
    local recommended_scripts=(
      "dev"
      "build"
      "test"
      "lint"
    )

    for script in "${recommended_scripts[@]}"; do
      if ! jq -e ".scripts.$script" package.json >/dev/null 2>&1; then
        echo "⚠ Script '$script' non trouvé dans package.json racine"
      fi
    done
  }

  # 10. Analyse des imports circulaires (basique)
  function check_circular_dependencies() {
    echo "Détection imports circulaires (analyse basique)..."

    # Utiliser madge si installé
    if command -v madge >/dev/null 2>&1; then
      local circular=$(madge --circular --extensions ts,tsx apps/)

      if [ ! -z "$circular" ]; then
        echo "⚠ Imports circulaires détectés :"
        echo "$circular"
      else
        echo "✓ Aucun import circulaire détecté"
      fi
    else
      echo "ℹ madge non installé (npm install -g madge pour analyse complète)"
    fi
  }
FIN verifications_avancees
```

### 8.2 Cas limites et gestion

**Pseudo-code** :

```
DÉBUT gestion_cas_limites
  # Cas 1 : Projet sans Git
  if [ ! -d ".git" ]; then
    echo "⚠ Dépôt Git non initialisé"
    echo "La phase Git sera ignorée"
    GIT_AVAILABLE=false
  fi

  # Cas 2 : Firebase non initialisé
  if [ ! -f "firebase.json" ] && [ ! -f ".firebaserc" ]; then
    echo "⚠ Projet Firebase non initialisé"
    echo "Voulez-vous initialiser Firebase maintenant ? (y/n)"
    read init_firebase

    if [ "$init_firebase" = "y" ]; then
      firebase init
    else
      echo "Audit limité (configuration Firebase absente)"
      FIREBASE_CONFIGURED=false
    fi
  fi

  # Cas 3 : Turborepo non configuré
  if [ ! -f "turbo.json" ]; then
    echo "⚠ turbo.json non trouvé"
    echo "Le projet utilise-t-il Turborepo ? (y/n)"
    read uses_turbo

    if [ "$uses_turbo" != "y" ]; then
      echo "Adaptation du script pour monorepo standard..."
      USES_TURBOREPO=false
      # Adapter commandes build
    fi
  fi

  # Cas 4 : Aucune app trouvée
  local apps_found=$(find apps -maxdepth 1 -type d | wc -l)
  if [ $apps_found -le 1 ]; then
    echo "❌ Aucune application trouvée dans apps/"
    echo "Structure attendue : apps/admin, apps/dashboard, apps/public"
    exit 1
  fi

  # Cas 5 : Firebase CLI non authentifié
  local firebase_user=$(firebase login:list 2>&1 | grep "Logged in as")
  if [ -z "$firebase_user" ]; then
    echo "⚠ Firebase CLI non authentifié"
    echo "L'audit continuera mais le déploiement sera impossible"
    echo ""
    echo "Pour vous authentifier : firebase login"
    FIREBASE_AUTHENTICATED=false
  fi

  # Cas 6 : Émulateurs déjà running
  if lsof -i :4000 >/dev/null 2>&1; then
    echo "ℹ Émulateurs Firebase déjà en cours d'exécution"
    EMULATORS_ALREADY_RUNNING=true
  fi

  # Cas 7 : Build directory inexistant mais config déploiement présente
  if [ "$HOSTING_CONFIGURED" = true ]; then
    for app in admin dashboard public; do
      local public_dir=$(jq -r ".hosting[] | select(.site | contains(\"$app\")) | .public" firebase.json 2>/dev/null)

      if [ ! -z "$public_dir" ] && [ ! -d "$public_dir" ]; then
        echo "⚠ Build manquant pour $app : $public_dir"
        echo "  Exécutez 'npm run build --filter=$app' avant de déployer"
      fi
    done
  fi

  # Cas 8 : Dépendances node_modules manquantes
  if [ ! -d "node_modules" ]; then
    echo "⚠ node_modules manquant à la racine"
    echo "Installation des dépendances requise"
    read -p "Exécuter 'npm install' maintenant ? (y/n) " install_deps

    if [ "$install_deps" = "y" ]; then
      npm install
    else
      echo "Audit limité (dépendances non installées)"
    fi
  fi

  # Cas 9 : Espace disque insuffisant
  local available_space=$(df -h . | tail -1 | awk '{print $4}' | sed 's/G//')
  if (( $(echo "$available_space < 1" | bc -l) )); then
    echo "⚠ Warning: Espace disque faible (<1GB disponible)"
    echo "Les builds pourraient échouer"
  fi

  # Cas 10 : Timeout sur opérations longues
  # Ajouter timeout sur builds/tests qui prennent trop de temps
  TIMEOUT_BUILD=300  # 5 minutes max par build
  TIMEOUT_TESTS=600  # 10 minutes max pour tous les tests

FIN gestion_cas_limites
```

---

## SECTION 9 : Conclusion et instructions finales pour Gemini

### 9.1 Récapitulatif du plan

Ce plan d'audit "Titanic Health Check" est structuré en **7 phases principales** :

1. **Phase 0** : Initialisation (variables, timestamps, détection racine projet)
2. **Phase 1** : Configuration Firebase (détection fichiers, extraction clés, cohérence)
3. **Phase 1.5** : État Git (status, historique, branches)
4. **Phase 2** : Build Check (compilation apps, linting, gestion erreurs)
5. **Phase 3** : Tests (détection frameworks, inventaire, exécution, analyse échecs)
6. **Phase 4** : Émulateurs (configuration, démarrage optionnel, santé)
7. **Phase 5** : Deploy Check (Data Connect, Static, SSR, menu interactif)
8. **Phase 6** : Génération rapport HTML (calcul statut, HTML/CSS/JS, écriture fichier)

**Caractéristiques clés** :

- Interactif : propose corrections via Gemini en cas d'erreur
- Robuste : gestion erreurs, validations, cas limites
- Complet : 15+ vérifications, logs détaillés
- Visuel : rapport HTML moderne et interactif

### 9.2 Instructions précises pour Gemini

**Contexte d'implémentation** :

```
Gemini doit transformer ce plan en script bash exécutable sur macOS avec les contraintes suivantes :

ENVIRONNEMENT :
- macOS (commandes spécifiques comme 'open', 'stat -f', 'pbcopy')
- Visual Studio Code comme IDE
- Turborepo avec 3 apps : admin, dashboard, public
- Firebase Cloud (Auth, Firestore, Functions, Storage, Hosting, App Hosting)

DÉPENDANCES :
- Obligatoires : bash, node, npm, git, firebase-tools
- Optionnelles : jq (pour parsing JSON), bc (pour calculs)
- Si jq absent : utiliser parsing alternatif (grep/sed/awk)

STRUCTURE FICHIERS :
project-root/
├── package.json (avec workspaces)
├── turbo.json
├── firebase.json
├── .firebaserc
├── apps/
│   ├── admin/
│   ├── dashboard/
│   └── public/
├── scripts/
│   └── titanic-health-check.sh  ← SCRIPT À GÉNÉRER
└── apps/admin/reports/
    └── titanic-health.html  ← RAPPORT GÉNÉRÉ

COMMANDES PRINCIPALES :
- Builds : turbo run build --filter=[app]
- Tests : turbo run test OU npm run test --workspace=apps/[app]
- Lint : turbo run lint
- Émulateurs : firebase emulators:start
- Deploy : firebase deploy --only [targets]

RÈGLES D'IMPLÉMENTATION :
1. Utiliser 'set -euo pipefail' pour robustesse
2. Créer fonctions bash réutilisables pour chaque phase
3. Capturer TOUS les outputs dans /tmp/titanic-health-*.log
4. Variables globales en MAJUSCULES
5. Couleurs ANSI pour output terminal (optionnel)
6. Trap EXIT/INT/TERM pour cleanup (arrêter émulateurs, supprimer temp files)
7. Commentaires abondants pour maintenance
8. Messages utilisateur clairs et formatés

GÉNÉRATION HTML :
- CSS et JavaScript EMBARQUÉS (pas de dépendances externes)
- HTML auto-suffisant (peut être ouvert offline)
- Données injectées via heredoc ou echo
- Échapper correctement les caractères spéciaux (quotes, backticks)

POINTS D'INTERACTION GEMINI :
- Après échec build : proposer prompt pour correction
- Après tests échoués : proposer prompt pour analyse
- Prompts sauvegardés dans /tmp/gemini-prompt-*.txt
- Utiliser pbcopy pour copier automatiquement (macOS)
- Instructions claires pour utilisateur

FORMAT SORTIE :
- Script bash commenté et structuré
- Peut être exécuté via : bash scripts/titanic-health-check.sh
- OU via : npm run health:titanic (ajouter dans package.json)
- Rapport HTML dans apps/admin/reports/titanic-health.html
- Exit code : 0 si succès, 1 si erreur critique
```

### 9.3 Approche recommandée pour Gemini

**Stratégie d'implémentation progressive** :
