
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
gcloud container clusters create shiny-cluster --num-nodes=3
gcloud compute addresses create shiny-static-ip --global
kubectl apply -f k8s/shiny-farkle-deploy.yaml
kubectl apply -f k8s/shiny-farkle-service.yaml
kubectl apply -f k8s/shiny-ingress.yaml
```
