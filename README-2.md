✔ What do you want to use as your public directory? public
✔ Configure as a single-page app (rewrite all urls to /index.html)? No
✔ Set up automatic builds and deploys with GitHub? Yes
i public/404.html is unchanged
i public/index.html is unchanged

i You can manage your secrets at https://github.com/AxeloLabs/17--oxela-claude/settings/secrets.

////

Guide Firebase Hosting pour Monorepo
🎯 Architecture recommandée
Vous allez créer 3 sites Firebase Hosting dans un seul projet Firebase :

mon-projet-vitrine → Site public avec SEO
mon-projet-dashboard → Dashboard utilisateur (authentifié)
mon-projet-admin → Interface admin (authentifié)

📝 Étape 1 : Créer les sites Firebase
bash# Dans la console Firebase ou via CLI
firebase hosting:sites:create mon-projet-vitrine
firebase hosting:sites:create mon-projet-dashboard
firebase hosting:sites:create mon-projet-admin
