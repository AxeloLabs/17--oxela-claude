Prompt pour Gemini :
"En te basant sur le plan Titanic Health Check (PHASE 0 et PHASE 1), 
génère un script bash qui :
1. Initialise l'environnement d'audit
2. Détecte et vérifie la configuration Firebase
3. Extrait les environnements et vérifie la cohérence
4. Stocke les résultats dans des variables

Contexte : macOS, Turborepo avec apps (admin, dashboard, public), 
projet Firebase local.

Le script doit être exécutable et robuste."
```

Ensuite, testez le script généré, corrigez les erreurs éventuelles avec Gemini.

**Étape 2 - État Git :**
```
Prompt pour Gemini :
"Ajoute maintenant la PHASE 1.5 (État Git) au script existant.
Le script doit vérifier l'état Git, lister les fichiers modifiés 
et extraire l'historique des 5 derniers commits.
Utilise les mêmes variables globales déjà initialisées."
```

**Étape 3 - Build Check :**
```
Prompt pour Gemini :
"Ajoute la PHASE 2 (Build Check) au script.
Détecte la config Turborepo, build les 3 apps séquentiellement,
capture erreurs/warnings, et propose de m'appeler si échec."
```

Et ainsi de suite pour chaque phase...

#### Option 2 : Approche globale (AVANCÉE)

Si vous voulez tout donner d'un coup :
```
Prompt initial pour Gemini :
"Je vais te fournir un plan d'audit complet en pseudo-code 
pour un script bash 'Titanic Health Check'. 

TON RÔLE : Transformer ce plan en script bash exécutable, 
phase par phase.

IMPORTANT : 
- Ne génère PAS tout le script d'un coup
- Demande-moi confirmation après chaque phase
- Teste chaque phase avant de passer à la suivante
- Propose des corrections si quelque chose ne fonctionne pas

Voici le plan complet :
[Coller tout mon document]

Commence par générer la PHASE 0 (Initialisation) et la PHASE 1 
(Configuration Firebase). Attends ma validation avant de continuer."