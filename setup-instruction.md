
# Symfony Demo App on Kubernetes

##  Table of Contents
1. [Overview](#overview)  
2. [Prerequisites](#prerequisites)  
3. [Project Structure](#project-structure)  
4. [Task 1: Deploy Symfony Demo App in Kubernetes](#task-1-deploy-symfony-demo-app-in-kubernetes)  
5. [Task 2: Implement Database Migrations](#task-2-implement-database-migrations)  
6. [Task 3: Scaling Concerns and Implementations](#task-3-scaling-concerns-and-implementations)  
7. [Testing Instructions](#testing-instructions)   
8. [Conclusion](#conclusion)  
9. [Appendix](#appendix)  

---

##  Overview

This project demonstrates the deployment of the Symfony Demo Application in a Kubernetes environment. It includes containerization, database migration integration, and scaling considerations with a focus on best practices.

---

##  Prerequisites

- Docker
- Kubernetes cluster (e.g., Minikube, Kind, GKE, etc.)
- `kubectl`
- `kustomization` 

---

##  Project Structure

The structure for the added kubernetes deployments files are as below (symfony-demo directories are not documented)

```
.
├── Dockerfile
├── docker-compose
├── docker/
│ └── nginx.conf
├── k8s/
│ ├── base/
│ │ ├── autoscaling/
│ │ │ └── hpa.yaml
│ │ ├── config/
│ │ │ └── configmap.yaml
│ │ ├── deployments/
│ │ │ ├── app-deployment.yaml
│ │ │ ├── mysql-deployment.yaml
│ │ │ └── web-deployment.yaml
│ │ ├── jobs/
│ │ │ └── db-migrate.yaml
│ │ ├── secrets/
│ │ │ └── secret.yaml
│ │ ├── services/
│ │ │ ├── db-service.yaml
│ │ │ ├── service.yaml
│ │ │ └── web-service.yaml
│ │ ├── storage/
│ │ │ └── symfony-pvc.yaml
│ │ └── kustomization.yaml
│ └── overlays/
│ ├── dev/
│ │ └── kustomization.yaml
│ └── pod/
│ └── kustomization.yaml
├── setup-instruction.md
└── ...
```

- `k8s/`: Kubernetes manifests
- `Dockerfile`: Symfony app containerization

---

##  Task 1: Deploy Symfony Demo App in Kubernetes

### 1.1 Clone and Prepare the Application

Clone the Symfony Demo app from GitHub:

//you can either clone the repo or use the image tag Link here 
[text](https://github.com/users/sazibsust10/packages/container/package/symfony-demo)

```bash
git clone git@github.com:sazibsust10/Symfony_demo.git
cd Symfony_demo
```

### 1.2 Dockerize the Symfony App

Build the Docker image:

Use the make script
```bash
docker build -t sazibsust10/symfony-demo:latest .
docker push sazibsust10/symfony-demo:latest
```

### 1.3 Kubernetes Manifests

Apply the manifests:

For `prod`
```bash
kubectl apply -k k8s/overlays/prod/
```
For `dev`
```bash
kubectl apply -k k8s/overlays/dev/
```

### 1.4 Deployment Instructions

Ensure all services and deployments are running:

```bash
kubectl get pods
kubectl get svc
```

Access the application via port-forward or ingress.

### 1.5 Best Practices & Notes

- Used `readinessProbe` and `livenessProbe` symfony app does not define a /health route. we need to create Symfony controller for /health
- Secrets managed via `Secret` object, right now its in plain text in k8s/base/secrets/secret.yaml. In real life we have to use vault to store secrets or aws secrets manager
- Suggested: external DB service for production workloads

---

##  Task 2: Implement Database Migrations

### 2.1 Migration Strategy

Use Doctrine migrations with zero-downtime practices:
- Additive schema changes
- Two-step deployment (migration, then app) - using init container and kustomization config

<!-- ### 2.2 Kubernetes Integration (Job/Init Container)

Migration job example:

```bash
kubectl apply -f k8s/base/jobs/db-migrate.yaml
``` -->

### 2.3 Deployment Workflow

Using CI/CD make sure the migrations run before the app deployment or rolls back
1. Run migration job
2. On success, deploy the app
3. Validate app functionality

### 2.4 Zero Downtime Considerations

- Avoid destructive schema changes
- App should tolerate both old and new schema
- Rollbacks tested with schema versioning

---

##  Task 3: Scaling Concerns and Implementations

### 3.1 Application Layer Scaling

Implemented `HorizontalPodAutoscaler`:

```bash
kubectl apply -f k8s/base/autoscaling/hpa.yaml
```

### 3.2 Database Layer Considerations

- Single-instance for demo
- Recommended: managed PostgreSQL with read replicas

### 3.3 Horizontal/Vertical Scaling Setup

Configured CPU/memory limits and requests.

### 3.4 Auto-scaling Examples

Load testing can be done using `kubectl run` and `ab`/`hey`.

---

##  Testing Instructions

From a clean namespace:

```bash
kubectl create namespace symfony-demo
kubectl config set-context --current --namespace=symfony-demo

kubectl apply -k k8s/base/
```

Check logs and endpoints to verify successful deployment.

---


##  Conclusion

This project demonstrates how to:
- Containerize and deploy Symfony
- Safely run DB migrations in Kubernetes
- Scale the app with Kubernetes-native tools

---

##  Appendix

### A.1 Useful Commands

```bash
kubectl get all
kubectl describe pod <name>
kubectl logs -f job/run-migrations
kubectl rollout status deployment symfony
```

### A.2 Kubernetes Resources

- [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Symfony Demo](https://github.com/symfony/demo)

### A.3 Links and References

- Symfony Documentation: https://symfony.com/doc/current/index.html
- Doctrine Migrations: https://www.doctrine-project.org/projects/doctrine-migrations.html
