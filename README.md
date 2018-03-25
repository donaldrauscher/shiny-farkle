
About
-----
Shiny app for analyzing the game of [Farkle](http://www.smartboxdesign.com/farklerules.html).  My blog post summarizing the app is [here](http://donaldrauscher.com/shiny-on-docker).

Infrastructure
-------

Create GKE cluster and install [Helm](https://helm.sh) Tiller.

```
export PROJECT_ID=$(gcloud config get-value project -q)
terraform apply -var project=${PROJECT_ID}

gcloud container clusters get-credentials shiny-cluster
gcloud config set container/cluster shiny-cluster

helm init
```

Deploy Instructions - Manually
-------

Build Docker image, push to GCR, and then deploy to GKE cluster using Helm.

``` bash
docker build -t farkle:latest .
docker run --rm -p 3838:3838 farkle:latest # test that it works locally

export PROJECT_ID=$(gcloud config get-value project -q)
docker tag farkle gcr.io/${PROJECT_ID}/shiny-farkle:latest
gcloud docker -- push gcr.io/${PROJECT_ID}/shiny-farkle
gcloud container images list-tags gcr.io/${PROJECT_ID}/shiny-farkle

helm upgrade --install --set projectId=${PROJECT_ID} shiny-farkle .
```

Deploy Instructions - Google Container Builder
-------

NOTE: For this approach, you will need to add a Helm cloud-builder step to your GCR.  Instructions for this [here](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/helm).

NOTE: You will also need to add "Kubernetes Enginer Developer" role to your GCB service account so that it can fetch cluster credentials.

``` bash
gcloud container builds submit --config cloudbuild.yaml .
```
