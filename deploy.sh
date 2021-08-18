PROJECT_ID="kela-presta"
CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET="cloudrun_exec_cli_archive_bucket"
SERVICE_ACCOUNT="cloudrun-exec-cli-identity"
DOCKER_IMAGE="cloudrun-exec-cli"

# Créez un bucket Cloud Storage
gsutil mb gs://$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET

# Créez un compte de service :
gcloud iam service-accounts create $SERVICE_ACCOUNT

# Accordez au compte de service l'autorisation de lire les services Cloud Run:
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.viewer

# Accordez à ce compte de service l'autorisation de lire depuis le bucket Cloud Storage et d'y écrire :
gsutil iam ch \
  serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com:objectViewer,objectCreator \
  gs://$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET

# Créez votre conteneur et publiez-le dans Container Registry 
gcloud builds submit --tag gcr.io/$PROJECT_ID/$DOCKER_IMAGE

# Exécutez la commande suivante pour déployer votre service 
gcloud run deploy $DOCKER_IMAGE \
   --image gcr.io/$PROJECT_ID/$DOCKER_IMAGE \
   --update-env-vars CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET=$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET \
   --service-account $SERVICE_ACCOUNT
   --no-allow-unauthenticated