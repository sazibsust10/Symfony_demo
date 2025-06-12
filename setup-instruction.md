# Symfony Demo Application Deployment on Kubernetes

## Table of Contents
- [Overview](#overview)  
- [Prerequisites](#prerequisites)  
- [Project Structure](#project-structure)  
- [Task 1: Deploy Symfony Demo App in Kubernetes](#task-1-deploy-symfony-demo-app-in-kubernetes)  
- [Task 2: Implement Database Migrations](#task-2-implement-database-migrations)  
- [Task 3: Scaling Concerns and Implementations](#task-3-scaling-concerns-and-implementations)  
- [Testing Instructions](#testing-instructions)  
- [Conclusion](#conclusion)  
- [Appendix](#appendix)  

---

## Overview

This project demonstrates the containerization and deployment of the Symfony Demo Application within a Kubernetes environment. It highlights best practices such as zero-downtime database migrations and autoscaling strategies, focusing on reliability, maintainability, and reproducibility.

---

## Prerequisites

The deployment assumes the following tools and environment:

- Docker (for containerization)  
- Kubernetes cluster (e.g., Minikube, Kind, GKE)  
- `kubectl` CLI  
- `kustomize` for manifest management  

---

## Project Structure

The Kubernetes manifests and Docker-related files are organized as follows:

```
.
├── Dockerfile
├── docker-compose.yaml
├── docker/
│   └── nginx.conf
├── k8s/
│   ├── base/
│   │   ├── autoscaling/hpa.yaml
│   │   ├── config/configmap.yaml
│   │   ├── deployments/
│   │   │   ├── app-deployment.yaml
│   │   │   ├── mysql-deployment.yaml
│   │   │   └── web-deployment.yaml
│   │   ├── jobs/db-migrate.yaml
│   │   ├── secrets/secret.yaml
│   │   ├── services/
│   │   │   ├── app-service.yaml
│   │   │   ├── db-service.yaml
│   │   │   └── web-service.yaml
│   │   ├── storage/symfony-pvc.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/kustomization.yaml
│       └── prod/kustomization.yaml
├── setup-instruction.md
└── ...
```

---

## Task 1: Deploy Symfony Demo App in Kubernetes

### Objective

To containerize and deploy the Symfony demo application on Kubernetes, ensuring the process is reproducible in a clean namespace.

### Implementation Details

- The Symfony demo app was cloned from the public GitHub repository.
- A Dockerfile was created to containerize the application, with images pushed to GitHub Container Registry.
- Kubernetes manifests were structured using Kustomize for environment overlays (dev and prod) for managing multiple deployment environments.
- The manifests include Deployments, Services, ConfigMaps, Secrets and PersistentVolumeClaims.

- Secrets are currently managed via Kubernetes Secret objects in plaintext for simplicity; production deployments should use secret management solutions such as Vault or cloud provider equivalents.
- Database is deployed as a MySQL instance within the cluster for demonstration; for production, an external managed database service is recommended.
- Health checks (`readinessProbe` and `livenessProbe`) can be implemented; a minimal `/health` endpoint should be added in the Symfony app for these to function properly.

#### Future Improvement
- Migrate to `Helm` to enable better versioned and rollback-capable deployments, along with rich templating support for future scalability
- Implement automated CI/CD pipelines integrating Helm charts for streamlined, reliable deployments across environments.
### Deployment Steps

```bash
git clone git@github.com:sazibsust10/Symfony_demo.git
cd Symfony_demo

docker build -t ghcr.io/sazibsust10/symfony-demo:2.0.3 .
docker push ghcr.io/sazibsust10/symfony-demo:2.0.3

# for prodcution
kubectl apply -k k8s/overlays/prod/
# or for development
kubectl apply -k k8s/overlays/dev/

kubectl get pods
kubectl get svc
```

---

## Task 2: Implement Database Migrations

### Objective

Integrate database migration capability into the Kubernetes deployment pipeline to maintain schema consistency without downtime.

### Strategy

- Utilized Doctrine Migrations with additive, non-destructive schema changes.
- Introduced a Kubernetes Job to run migrations (`db-migrate.yaml`) before the application deployment.
- Migration job designed to be idempotent and safe to re-run if needed.



### Deployment Workflow

Execute the migration Job using:

```bash
kubectl apply -f k8s/base/jobs/db-migrate.yaml
```

**Note:** In my Kustomize configuration, all resources and patches are organized to ensure they are applied in the correct sequence. This guarantees that dependencies—such as ConfigMaps, Secrets, and PersistentVolumeClaims—are created before the pods or deployments that rely on them, preventing runtime errors and deployment failures. 

#### Future Improvement
- Introduce connection pooling (e.g., ProxySQL for MySQL) to improve database performance and scalability.
- Enhance observability by adding monitoring, logging, and alerting tools (Prometheus, Grafana, ELK stack).
- Adopt StatefulSets for stateful services like MySQL to improve resilience and data persistence.

---

## Task 3: Scaling Concerns and Implementations

### Objective

Identify scalability challenges and implement solutions at both application and database layers.

### Identified Scaling Issues

### Application Layer
- Static number of replicas limits responsiveness to traffic surges.
- Resource bottlenecks (CPU, memory) under high load.
- No Horizontal/Vertical Pod Autoscaler.
- Lack of load testing and benchmarking.

### Database Layer
- Single-point-of-failure database.
- No read/write separation.
- Potential for DB connection exhaustion.
- Stateful services are harder to scale dynamically.

---

### Proposed Scaling Strategies

### Application Layer

| Strategy | Description | Benefit |
|---------|-------------|---------|
| **Horizontal Pod Autoscaler (HPA)** | Auto-scales pods based on CPU/utilization metrics. | Handles variable traffic efficiently. |
| Vertical Pod Autoscaler (VPA) | Adjusts resource requests/limits automatically. | Prevents over/under-provisioning. |
| Load Testing (ab, k6, wrk) | Simulates user traffic to discover bottlenecks. | Sets baselines for auto-scaling. |
| Pod Disruption Budgets (PDB) | Ensures availability during node or pod disruptions. | Maintains reliability during changes. |

### Database Layer

| Strategy | Description | Benefit |
|---------|-------------|---------|
| Read Replicas with Proxy | Offloads read traffic using tools like `ProxySQL` | Reduces pressure on the primary DB. |
| Clustering (e.g., Patroni, MySQL Group Replication) | Enables horizontal scale and high availability. | Removes single points of failure. |
| Scalable Storage (PVC expansion) | Use dynamically resizable PersistentVolumes. | Supports growing data workloads. |

- Production recommendation: utilize managed database services with high availability and read replicas to scale read operations.
---

### Horizontal Pod Autoscaler (HPA)

I chose to implement Horizontal Pod Autoscaler (HPA) because it's a native and efficient way to dynamically scale stateless applications in Kubernetes based on real-time metrics such as CPU and memory usage.



### Additional Notes
```bash
kubectl run load-generator --image=ubuntu --restart=Never -it -- /bin/bash
```

- Load testing tools such as `ab` or `hey` can be employed to simulate traffic.
- CPU and memory thresholds in HPA can be tuned based on profiling.

---

## Testing Instructions

To validate deployment in a clean Kubernetes namespace:

```bash
kubectl create namespace symfony-demo
kubectl config set-context --current --namespace=symfony-demo

kubectl apply -k k8s/overlays/dev
kubectl apply -k k8s/overlays/prod

kubectl get all
kubectl logs -f job/run-migrations
kubectl rollout status deployment symfony
```

---

## Conclusion

This deployment project highlights key DevOps competencies:

- Effective containerization and Kubernetes deployment  
- Zero-downtime database migrations integrated into CI/CD workflows  
- Autoscaling configuration to manage load variations  
- Awareness of production-grade best practices around secrets and database management  


---

## Appendix

### Useful Kubernetes Commands

```bash
kubectl get all
kubectl describe pod <pod-name>
kubectl logs -f job/run-migrations
kubectl rollout status deployment symfony
```

### References

- Symfony Documentation: https://symfony.com/doc/current/index.html  
- Doctrine Migrations: https://www.doctrine-project.org/projects/doctrine-migrations.html  

---


