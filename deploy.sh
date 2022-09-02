PROJECT_ID="kela-presta-325511"
CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET="rephi_bash"
SERVICE_ACCOUNT="bash-identity"
DOCKER_IMAGE="bash"

othersProjects="787766483595"

set -x 
# docker build --tag gcr.io/$PROJECT_ID/$DOCKER_IMAGE .
# docker run --env "CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET=$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET"  --name "deploy" gcr.io/$PROJECT_ID/$DOCKER_IMAGE
# docker exec -it --name deploy gcr.io/kela-presta/bash

# exit
# Créez un bucket Cloud Storage
gsutil mb gs://$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET

# Créez un compte de service :
gcloud iam service-accounts create $SERVICE_ACCOUNT

# Accordez au compte de service l'autorisation de lire les services Cloud Run:
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.invoker

# give the service account right to impersonate
gcloud projects add-iam-policy-binding $othersProjects \
  --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

# Accordez à ce compte de service l'autorisation de lire depuis le bucket Cloud Storage et d'y écrire :
gsutil iam ch \
  serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com:objectViewer,objectCreator,objectDelete \
  gs://$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET

# Créez votre conteneur et publiez-le dans Container Registry 
gcloud builds submit --tag gcr.io/$PROJECT_ID/$DOCKER_IMAGE

# Ou sinon créez le localement et poussez le dans le container registry de google
# docker build --tag gcr.io/$PROJECT_ID/$DOCKER_IMAGE .
# Poussez le sur gcr.io
# docker push gcr.io/$PROJECT_ID/$DOCKER_IMAGE

# Exécutez la commande suivante pour déployer votre service 
gcloud run deploy $DOCKER_IMAGE \
   --image gcr.io/$PROJECT_ID/$DOCKER_IMAGE \
   --update-env-vars CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET=$CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET \
   --service-account $SERVICE_ACCOUNT \
   --no-allow-unauthenticated \
   --platform managed --region europe-west1 

# Tester la fonction
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)"  --data-urlencode "params='accords.app, dena mwana accords'" https://bash.rephi.app/click

# curl http://localhost:8080/node_to_zero


# create cloud cheduler
gcloud scheduler jobs create http click-accords-app --project=$PROJECT_ID --location=europe-west1 --schedule="*/20 * * * *" --uri=https://bash-qgaicxr67q-ew.a.run.appclick