## Architecture and Documentation of REMLA25 Sentiment Analysis System

Our application is built with cloud-native technologies providing modularity, continuous integration and deployment. Application is deployed on a Kubernetes cluster and supported by an Istio service mesh. It uses software deployment techniques that are common for modern production systems. Here are some aspects of application architecture:

__Microservice architecture.__  Application is implemented keeping modern microservice architecture practices in mind. The app is separated into 2 microservices communicating via API requests. The main application service is responsible for information delivery and presentation to user. The separated model-service is responsible for ML model initialization and communication with it. 

__Kubernetes Deployment.__  We deploy our system on Kubernetes using Helm charts, which allow us to define reusable and configurable deployment templates. This makes it easy to manage different environments and update services consistently. Sensitive information, such as keys and credentials, is managed separately using Kubernetes Secrets, ensuring a clear separation between configuration and secret data for improved security and maintainability.

__Istio Mesh.__ We use Istio as a service mesh to manage communication between our microservices. Istio handles traffic routing and load balancing. By offloading these responsibilities from the application code, Istio enables consistent policies and resilience across all services. It also allows us to implement advanced features like multi version deployment, which enables gradual feature rollout and testing. 

__Continuous Monitoring.__ Our application enables Prometheus metrics to monitor application load. It also has multiple grafana dashboards to monitor basic metrics, such as request rate, latency and number of active application users.


### Deployment Architecture
![architecture](/docs/images/REMLA_deployment.drawio.png)

#### System Components:

Istio Gateway: This component collects the incoming traffic and routes it to Kubernetes cluster. Istio is specifically designed for Kubernetes environments. The gateway listens on port 80 for HTTP traffic and makes decisions about which requests should be allowed into our cluster.

EnvoyFilter (Rate Limiter): This component is defensing application from the abuse behavior (spamming). We've implemented a rate limiting mechanism that restricts each IP address to 10 requests per minute. The traffic is filtered based on the ip address. When the users reach the limit of requests they receive a "429 Too Many Requests" error, protecting our system from spamming.

VirtualService: This components are used to route traffic to a correct destination within a cluster. They examine incoming requests and make routing decisions based on defined rules. 

App Deployments (v1 & v2): These are two deployments of our application. Each deployment may run different versions of our code. Each deployment contains pods with our Python Flask application. These pods contain minimalistic frontend UI and backend APIs. They forward some requests with sentiment prediction to model service.

Model Service Deployment: This is the service that loads the model and give predictions. It's responsible for our trained sentiment analysis model loading from GitHub artifacts and providing a REST API for predictions.

External Prometheus & Grafana:Prometheus continuously collects and stores time-series metrics data, while Grafana creates intuitive visual dashboards from that information.