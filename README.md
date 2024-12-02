# Déploiement de clusters Kubernetes sur GCP avec kubeadm

### Introduction

Ce projet Terraform a pour objectif d'automatiser le déploiement de clusters Kubernetes sur Google Cloud Platform (GCP), en utilisant kubeadm pour l'installation de Kubernetes. Il est structuré en deux modules principaux :

  * **prerequisites:** Ce module contient les ressources communes à tous les clusters, telles que le VPC, l'Artifact Registry et le stockage des binaires sur Google Cloud Storage.
  * **clusters:** Ce module se concentre sur les ressources spécifiques à chaque cluster, comme les groupes d'instances, les load balancers, etc.

### Prérequis

  * **Un compte Google Cloud Platform:** Assurez-vous d'avoir créé un projet et activé les APIs nécessaires (Compute Engine, Container Engine, Storage, etc.).
  * **Terraform installé:** Suivez les instructions officielles pour installer Terraform sur votre système : [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://www.google.com/url?sa=E&source=gmail&q=https://learn.hashicorp.com/tutorials/terraform/install-cli)
  * **Un fichier de configuration de Google Cloud:** Vous aurez besoin d'un fichier JSON contenant les informations d'authentification pour votre projet GCP.
  * **Connaissances de base en Terraform et Kubernetes:** Une bonne compréhension de Terraform et des concepts de base de Kubernetes est recommandée.

### Structure du projet

Le projet est organisé de la manière suivante :

  * **prerequisites:** Contient la configuration Terraform pour les ressources communes.
  * **clusters:** Contient la configuration Terraform pour les ressources spécifiques aux clusters.

### Utilisation

1.  **Cloner le référentiel:** Clonez ce référentiel Git sur votre machine locale.
2.  **Configurer les variables:** Modifiez le fichier `variables.tf` pour définir les valeurs spécifiques à votre environnement (projet GCP, région, nombre de nœuds, etc.).
3.  **Initialiser Terraform:** Exécutez la commande `terraform init` dans le répertoire racine du projet.
4.  **Appliquer les changements:** Exécutez la commande `terraform plan` pour visualiser les changements à apporter et `terraform apply` pour appliquer les modifications.

### Exemple d'utilisation

```bash
# Initialiser Terraform
terraform init

# Visualiser les changements
terraform plan

# Appliquer les changements
terraform apply
```

### Personnalisation

  * **Modules:** Vous pouvez personnaliser les modules en ajoutant de nouvelles ressources ou en modifiant les configurations existantes.
  * **Variables:** Utilisez les variables pour rendre votre configuration plus flexible et réutilisable.
  * **Outputs:** Exposez les informations importantes (par exemple, l'adresse IP du master) pour faciliter la gestion du cluster.

### Avertissements

  * **Sécurité:** Assurez-vous de configurer correctement les règles de pare-feu pour sécuriser votre cluster.
  * **Coûts:** Soyez conscient des coûts associés à l'utilisation de GCP.
  * **Mises à jour:** Tenez-vous informé des dernières versions de Terraform et de Kubernetes pour bénéficier des nouvelles fonctionnalités et correctifs de sécurité.

### Contributeurs

  * Mathieu GOULIN <mathieu.goulin@gadz.org>

### Licence

  * voir LICENCE.txt