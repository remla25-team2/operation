# Operation

## Application start

The application is Dockerized. Make sure you have Docker up and running. Application can be started with:
```
docker-compose up --build
```

The application frontend can be accessed at ```localhost:5000``` url.

You can also runt the Vagrant Kubernetes setup through:
```
vagrant up
```


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
  
### Comments for A1

### Comments for A2
All the steps are implemenented and works perfectly on Linux. Windows might have some problems due to Virtualbox network interface not cooperating well with WSL2/Vagrant for the Kubernets API server.

### Comments for A3
To run it: 
 - ```vagrant up --provision```
 - ```ansible-playbook -u vagrant -i 192.168.56.100, provision/finalization.yml -e "ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key"```
 - Copy config from ctrl to local machine: ```vagrant ssh ctrl -c 'cat /home/vagrant/.kube/config' > ~/operation-kubeconfig```
 - Then export the kube config: ```export KUBECONFIG=~/operation-kubeconfig```
 - ```helm install my-app ./kubernetes/charts/my-app```
 - To check that they are running;   ```kubectl get pods -n monitoring```
 - To run Grafana in the UI: ```kubectl --namespace monitoring port-forward svc/prometheus-operator-grafana 3000:80``` and then available at http://localhost:3000
 - To run Prometheus in the UI: ```kubectl --namespace monitoring port-forward svc/prometheus-operated 9090:9090``` and then available at http://localhost:9090
   Log in with username: admin and password: admin 
Grafana sidecar automatically imports the dashboard ConfigMap so no manual JSON import.

In case finalization.yml setup does not work:
 - ```ssh-copy-id vagrant@192.168.56.100```
 - Use the path to your default ssh key to run the command

### Comments for A4

### Comments for A5

The new experiment dashboards should be automatically imported. Documentation is not done yet nor the additional use case.
