
About
-----
Shiny app for analyzing the game of [Farkle](http://www.smartboxdesign.com/farklerules.html).  My blog post summarizing the app is [here](http://donaldrauscher.com/shiny-on-docker).


Deploy Instructions
-------

(1) Set up Docker image
```
docker build -t farkle:latest .
docker run --rm -p 3838:3838 farkle:latest # test that it works locally
```

(2) Tag the image and push it to Google Container Repository
```
export PROJECT_ID=$(gcloud config get-value project -q)
docker tag farkle gcr.io/${PROJECT_ID}/shiny-farkle:latest
gcloud docker -- push gcr.io/${PROJECT_ID}/shiny-farkle
gcloud container images list-tags gcr.io/${PROJECT_ID}/shiny-farkle
```

(3) Create cluster on Google Container Engine and deploy using Kubernetes
```
terraform apply -var project=${PROJECT_ID}

gcloud container clusters get-credentials shiny-cluster
gcloud config set container/cluster shiny-cluster

helm init
helm install . --set projectId=${PROJECT_ID}
```

NOTE: I packaged my Kubernetes resources in [a Helm chart](https://helm.sh/).
