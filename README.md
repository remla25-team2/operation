# Operation

## Application start

The application is Dockerized. Make sure you have Docker up and running. 

You need to have `.env` file with environment variables for docker. You can copy contents of `.env.example` to your `.env` file.

After creation of environment variables, application can be started with:
```
docker-compose up --build
```

The application frontend can be accessed at ```localhost:5000``` url.

You can also run the Vagrant Kubernetes setup through:
```
vagrant up
```

### Comments for A1

### Comments for A2
All the steps are implemenented and works perfectly on Linux. Windows might have some problems due to Virtualbox network interface not cooperating well with WSL2/Vagrant for the Kubernets API server.

### Comments for A3
 - ```vagrant up --provision```
 - ```ansible-playbook -u vagrant -i 192.168.56.100, provision/finalization.yml -e "ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key"```
 - Copy config from ctrl to local machine: ```vagrant ssh ctrl -c 'cat /home/vagrant/.kube/config' > ~/operation-kubeconfig```
 - Then export the kube config: ```export KUBECONFIG=~/operation-kubeconfig```
 - **Create required secrets**: ```./create_secrets.sh```
 - ```helm install my-app ./kubernetes/charts/my-app```
 - Or if it exists already: ```helm upgrade my-app ./kubernetes/charts/my-app```
 - To check that they are running;   ```kubectl get pods -n monitoring```
 - To run Grafana in the UI: ```kubectl --namespace monitoring port-forward svc/prometheus-operator-grafana 3000:80``` and then available at http://localhost:3000
 - To run Prometheus in the UI: ```kubectl --namespace monitoring port-forward svc/prometheus-operated 9090:9090``` and then available at http://localhost:9090
   Log in with username: admin and password: (the one you set when running create_secrets.sh)
 - Access the app through (http://192.168.56.91).
Grafana sidecar automatically imports the dashboard ConfigMap so no manual JSON import.

## Required Secrets

Before deploying the application, you must create the following Kubernetes secrets:

1. **app-secrets** (default namespace): Contains application passwords
2. **grafana-admin-secret** (monitoring namespace): Contains Grafana admin credentials  
3. **smtp-secret** (monitoring namespace): Contains SMTP credentials for AlertManager

Run `./create-secrets.sh` to create these secrets interactively.

In case finalization.yml setup does not work:
 - ```ssh-copy-id vagrant@192.168.56.100```
 - Use the path to your default ssh key to run the command

### Comments for A4

## DVC setup
This repository is using Data Version Control with remote storage. To pick files from remote storage do:

- ```make requirements``` to download all requirements and dvc

- dvc is set up to use Google Drive remote storage with service account access to download and process data. Please request service account credential file from the owners of the repository and add it to `.dvc/tmp/remlaproject-sa.json`. The credentials can not be made fully public because of Google Politics. Additionally, GitHub workflows are setup to use Google Drive credentials for continuous integration. 

Once credentials are received: 
-  ```dvc pull``` this will pull all training model files from the Google Drive. 
-  ```dvc push``` will push your changes to the model files to the remote storage if you have appropriate access.

To launch training pipeline:
- ```dvc repro``` it will launch all pipeline stages and create the missing files locally

To check model metrics:
- ```dvc exp show --no-pager``` will show the model accuracy, precision and recall
More details can be found in the readme on model-training repo: https://github.com/remla25-team2/model-training/edit/main/README.md
### Comments for A5

The new experiment dashboards should be automatically imported.


## Repositories

- **Operation**  
  - Repo link: https://github.com/remla25-team2/operation/
  - A2 tag: https://github.com/remla25-team2/operation/releases/tag/a2
  - A3 tag: https://github.com/remla25-team2/operation/releases/tag/a3
  - A5 tag: https://github.com/remla25-team2/operation/releases/tag/a5
  
- **App**  
  - Repo link: https://github.com/remla25-team2/app/
  - A1 tag: https://github.com/remla25-team2/app/releases/tag/a1
  - A3 tag: https://github.com/remla25-team2/app/releases/tag/a3
  - A5 tag: https://github.com/remla25-team2/app/releases/tag/a5

- **Model-Service**  
  - Repo link: https://github.com/remla25-team2/model-service/  
  - A1 tag: https://github.com/remla25-team2/model-service/releases/tag/a1
  - A5 tag: https://github.com/remla25-team2/model-service/releases/tag/a5
  
- **Model-Training**  
  - Repo link: https://github.com/remla25-team2/model-training/  
  - A1 tag: https://github.com/remla25-team2/model-training/releases/tag/a1
  - A4 tag: https://github.com/remla25-team2/model-training/releases/tag/a4
  - A5 tag: https://github.com/remla25-team2/model-training/releases/tag/a5
  
- **lib-ml**  
  - Repo link: https://github.com/remla25-team2/lib-ml/ 
  - A1 tag: https://github.com/remla25-team2/lib-ml/releases/tag/a1
  
- **lib-version**  
  - Repo link: https://github.com/remla25-team2/lib-version/  
  - A1 tag: https://github.com/remla25-team2/lib-version/releases/tag/a1
  - A2 tag: https://github.com/remla25-team2/lib-version/releases/tag/a2
