## 📄 Design Choices and Rationale

### 1. **Containerization with Docker**
- **Choice**: Symfony application containerized using a custom `Dockerfile` based on the `php:8.2-apache` image.
- **Rationale**: 
  - Ensures compatibility with Symfony's PHP requirements.
  - Apache is a straightforward web server for PHP apps and easy to configure with `.htaccess` and mod_rewrite.
  - Composer is included in the build for dependency management.
  - Files and permissions are adjusted to ensure runtime compatibility with Symfony's cache and logs.

---

### 2. **Kubernetes Deployment**
- **Choice**: Used Kubernetes Deployments, Services, Secrets, and optional Ingress.
- **Rationale**:
  - **Deployments** manage scaling, updates, and health checks.
  - **Secrets** store sensitive data such as the database URL to avoid hardcoding credentials.
  - **Ingress** enables clean external access using domain names.
  - Application is deployed in a **dedicated namespace** to isolate resources.

---

### 3. **PostgreSQL as Database**
- **Choice**: PostgreSQL deployed in the same namespace or external managed DB (recommended for production).
- **Rationale**:
  - Symfony Demo supports PostgreSQL out of the box.
  - Helm or manifest-based deployment allows portability and reproducibility.
  - For production, using a managed service improves reliability, backup, and scaling.

---

### 4. **Database Migrations**
- **Choice**: Handled using a **Kubernetes Job** that runs `php bin/console doctrine:migrations:migrate`.
- **Rationale**:
  - Isolates schema changes from application logic.
  - Ensures migrations run **once** and complete **before** application pods start.
  - Reduces risk of downtime or race conditions in multi-pod environments.
  - Integrates cleanly with CI/CD pipelines and rollback strategies.

---

### 5. **Scaling Strategy**
- **Application Scaling**:
  - **Choice**: Configured Horizontal Pod Autoscaler (HPA) based on CPU usage.
  - **Rationale**: Automatically adds/removes replicas based on demand, ensuring cost-efficiency and availability.
  - Sessions should be stored in Redis or database for stateless scaling.

- **Database Scaling**:
  - **Choice**: Recommended external PostgreSQL service with connection pooling.
  - **Rationale**: Stateful workloads are harder to scale horizontally. Managed services like AWS RDS provide high availability, backup, and failover without operational overhead.

---

### 6. **Security and Best Practices**
- Used **Kubernetes Secrets** to manage credentials.
- Container runs with a non-root user where applicable.
- Network policies and resource limits (CPU/memory) should be applied in a production setting.
- Config files and manifests are modular and environment-agnostic to support different clusters (dev, staging, prod).

---

### 7. **Reproducibility**
- All Kubernetes manifests are provided in declarative YAML format.
- Docker image can be built and pushed to any registry.
- Namespace isolation ensures that the app can be deployed cleanly into any Kubernetes cluster without interference.
