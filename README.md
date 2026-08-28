# Pomotime

Pomotime est une application de productivité basée sur la méthode Pomodoro, conçue pour aider les utilisateurs à maintenir une concentration profonde tout en gérant efficacement leurs tâches et leur bien-être.

## Fonctionnalités Principales

### Gestion du Temps et Concentration
- Chronomètre Pomodoro : Cycles de travail de 25 minutes alternés avec des pauses de 5 minutes.
- Persistance du Timer : Le décompte continue en arrière-plan et lors de la navigation entre les onglets.
- Transition Automatique : Passage fluide entre les sessions de focus et les pauses.

### Gestion des Tâches (To-Do List)
- Création de tâches personnalisées avec estimation du nombre de Pomodoros requis.
- Suivi de la progression en temps réel pour chaque tâche sélectionnée.
- Sauvegarde locale automatique des tâches.

### Système de Motivation (Gamification)
- Système d'XP : Gain d'expérience pour chaque session de travail complétée.
- Niveaux de Progression : Evolution du profil utilisateur basée sur l'effort fourni.
- Séries Quotidiennes (Streaks) : Compteur de jours consécutifs pour encourager la régularité.
- Statistiques Détaillées : Visualisation de l'effort total et de l'historique de concentration.

### Ambiance Sonore Immersive
- Sons d'ambiance intégrés (Pluie, Forêt, Bruit Blanc) pour favoriser l'immersion.
- Contrôle granulaire du volume pour une expérience personnalisée.

## Architecture Technique

L'application repose sur une architecture moderne et robuste :
- Framework : Flutter
- Gestion d'état : Provider & ProxyProvider
- Stockage Local : SharedPreferences
- Gestion Audio : Audioplayers
- Identification : Uuid

## Installation et Configuration

### Prérequis
- Flutter SDK (version 3.35.3 ou supérieure recommandée)
- Un appareil Android ou un émulateur

### Dépendances
Les bibliothèques suivantes sont utilisées :
- provider
- remixicon
- shared_preferences
- audioplayers
- uuid
- intl

### Ressources Audio (Important)
Pour activer les fonctionnalités sonores, les fichiers audio suivants doivent être présents dans le dossier `assets/sounds/` :
- rain.mp3
- forest.mp3
- white_noise.mp3

## Permissions

L'application requiert les autorisations suivantes sur Android :
- INTERNET : Pour le téléchargement initial des ressources si nécessaire.
- WAKE_LOCK : Pour empêcher l'appareil de se mettre en veille pendant une session de concentration active.
