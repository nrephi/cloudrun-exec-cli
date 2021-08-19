set -x
echo "Resize cluster to "$1" nodes"
gcloud container clusters resize k8sterraform --num-nodes=$1 --region=europe-west1 --quiet