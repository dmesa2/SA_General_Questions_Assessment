# SA_General_Questions_Assessment

1. **Create an image with python2, python3, R, install a set of requirements and upload it to docker hub.**

2. **For the previously created image**
   a. **Share build times**  
   Locally:

   Building: **23.9s (22/22) FINISHED**

   GitHub Actions: **10min+**

   b. **How would you improve build times?**  
   The installation of r-base was the primary bottleneck affecting build times. Initially, I started with a standard Ubuntu image and attempted to install the necessary packages. However, after nearly an hour of building, I recognized the need for a different approach. Through research on Stack Overflow, I discovered an existing Docker image with R pre-installed, which significantly accelerated the process. I then added Python 2 and 3 and implemented a multi-stage build strategy to ensure that the final Docker image is lean, containing only the essential binaries.

   As for the build time in GitHub Actions, we could utilize GitHub Action cache exporter as written in this article to speed it up: [Using the GitHub Actions Cache Exporter](https://depot.dev/blog/docker-layer-caching-in-github-actions#using-the-github-actions-cache-exporter).

3. **Scan the recently created container and evaluate the CVEs that it might contain.**  
   a. **Create a report of your findings and follow best practices to remediate the CVE**  
   [CVE Vulnerability Report](https://github.com/dmesa2/SA_General_Questions_Assessment/blob/main/Report/CVE_Vulnerability_Report.pdf)

   b. **What would you do to avoid deploying malicious packages?**

   - Use Trusted Sources
   - Implement Dependency Management (i.e., pip)
   - Conduct Regular Security Audits
   - Use Automated Scanning Tools
   - Implement Runtime Security Measures
   - Review and Monitor Dependencies

4. **Use the created image to create a Kubernetes deployment with a command that will keep the pod running.**

Go to the deployment manifest file: /Kubernetes/Deployment/sa-assessment-deployment.yaml

```bash
kubectl apply -f sa-assessment-deployment.yaml
```

```bash
kubectl get pods
NAME                                        READY   STATUS    RESTARTS   AGE
sa-assessment-deployment-55b4f8589f-mwjtw   1/1     Running   0          35s
```

5. **Expose the deployed resource.**

Go to the service manifest file: /Kubernetes/Service/sa-assessment-service.yaml

```bash
kubectl apply -f sa-assessment-service.yaml
```

```bash
kubectl get svc
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes              ClusterIP   10.96.0.1       <none>        443/TCP        328d
sa-assessment-service   NodePort    10.96.198.192   <none>        80:31176/TCP   7s
```

6. **Every step mentioned above has to be in a code repository with automated CI/CD.**

The code repository can be found at: dmesa2/SA_General_Questions_Assessment
The CI/CD workflow is located at: .github/workflows/docker-build-and-push.yml

7. **How would you monitor the above deployment? Explain or implement the tools that you would use.**

There are a number of ways to monitor the above deployment. From an application perspective, we can leverage ELK and monitor the logs in Kibana.
This can be further optimized by using fluentbit to filter the logs. All of this can be installed onto the same kubernetes cluster.

As for the deployment itself, we can utilize Prometheus and Grafana which can easily be installed onto our cluster using helm charts. Prometheus can be used
to collect the metrics and Grafana can be used to visualize those metrics.

```bash
kubectl create namespace monitoring
```

Step 1: Add Helm Repositories
Before installing Prometheus and Grafana, we need to add the required Helm repositories:

```bash
# Add the Prometheus community helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add the Grafana helm charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update the helm repos to get the latest versions
helm repo update
```

Step 2: Install Prometheus

```bash
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
```

Step 3: Install Grafana

```bash
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set service.type=NodePort \
  --set service.nodePort=32000 \
  --set persistence.enabled=false \
  --set adminPassword='your-admin-password'
```

This is a quick way to get grafana up and running, but ideally the admin password should be encrypted and passed in using value files.

Step 4: Access Grafana

```bash
http:<kubernetes-node-ip>:32000
```

Step 5: Configure Grafana
Login to Grafana and add Prometheus as a Data Source

Step 6: Create the Dashboards, Panels, and Alerts
Create the following dashboards:
Deployment Overview - CPU Usage - Memory Usage - Pod Status - Request Rate

Application Performance Dashboard - Response Time - Error Rate - Active Users

Resource Utilization Dashboard - Node CPU Usage - Node Memory Usage - Disk I/O

Alerts: - CPU and Memory Usage Alerts - Pod Health Alerts - Error Rate Alerts - Deployment Rollback Alerts
