# Cloudflare DDNS for Kubernetes

Automatic Cloudflare DNS record updater for dynamic IP addresses in home environments.

## 📁 Project Structure

```
project/cloudflare-ddns/
├── base/
│   ├── kustomization.yaml    # Kustomize base configuration
│   ├── namespace.yaml         # Namespace definition
│   ├── secret.yaml            # Secret template (edit before applying)
│   └── cronjob.yaml           # CronJob definition
└── README.md                  # This file
```

## 🚀 Quick Start

### Step 1: Get Your Cloudflare API Token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Use the **"Edit zone DNS"** template
4. Select your zone (domain)
5. Click **"Continue to summary"** → **"Create Token"**
6. **Copy the token** (you won't see it again!)

### Step 2: Edit the Secret

Edit `base/secret.yaml` and replace the placeholder values:

```bash
# Edit the secret with your real values
vim base/secret.yaml
```

Replace:
- `your-cloudflare-api-token-here` → Your actual API token
- `example.org,www.example.org` → Your actual domains

### Step 3: Deploy with Kustomize

```bash
# Preview what will be deployed
kubectl kustomize base/

# Deploy to cluster
kubectl apply -k base/

# Or use the shorthand
kubectl apply -k ./project/cloudflare-ddns/base
```

### Step 4: Verify Deployment

```bash
# Check if namespace was created
kubectl get namespace cron-job

# Check CronJob
kubectl get cronjob -n cron-job

# Wait a few minutes, then check jobs
kubectl get jobs -n cron-job

# Check logs
kubectl logs -n cron-job -l app=cloudflare-ddns --tail=50
```

## 🔧 Configuration

### Update Frequency

Edit `base/cronjob.yaml` and change the `schedule` field:

```yaml
schedule: "*/5 * * * *"  # Every 5 minutes (default)
```

Common schedules:
- `"*/5 * * * *"` - Every 5 minutes
- `"*/15 * * * *"` - Every 15 minutes
- `"0 * * * *"` - Every hour
- `"0 */6 * * *"` - Every 6 hours

### Disable IPv6

Add to `base/secret.yaml`:

```yaml
IP6_PROVIDER: "none"
```

### Disable Cloudflare Proxy

Change in `base/secret.yaml`:

```yaml
PROXIED: "false"
```

### Multiple Domains

Just list them comma-separated in `base/secret.yaml`:

```yaml
DOMAINS: "example.org,www.example.org,another.com,*.wildcard.io"
```

## 📊 Monitoring

### Check CronJob Status

```bash
# Get CronJob details
kubectl get cronjob cloudflare-ddns -n cron-job

# Describe for more info
kubectl describe cronjob cloudflare-ddns -n cron-job
```

### View Job History

```bash
# List all jobs
kubectl get jobs -n cron-job

# View successful jobs
kubectl get jobs -n cron-job --field-selector status.successful=1
```

### View Logs

```bash
# Latest logs
kubectl logs -n cron-job -l app=cloudflare-ddns --tail=100

# Follow logs in real-time
kubectl logs -n cron-job -l app=cloudflare-ddns -f

# Logs from specific job
kubectl logs -n cron-job job/cloudflare-ddns-<timestamp>
```

### Manually Trigger Update

```bash
# Create a one-time job from the CronJob
kubectl create job --from=cronjob/cloudflare-ddns manual-update -n cron-job

# Check the job
kubectl get job manual-update -n cron-job

# View logs
kubectl logs -n cron-job job/manual-update
```

## 🛠️ Troubleshooting

### Check Current Public IP

```bash
curl https://1.1.1.1/cdn-cgi/trace
```

### Verify DNS Records

```bash
# Check DNS resolution
dig +short example.org
dig +short www.example.org

# Check with specific nameserver
dig @1.1.1.1 +short example.org
```

### Debug Failed Jobs

```bash
# List failed jobs
kubectl get jobs -n cron-job --field-selector status.successful=0

# Describe failed job
kubectl describe job <job-name> -n cron-job

# Get pod logs
kubectl logs -n cron-job <pod-name>
```

### Common Issues

**Issue:** CronJob not running
```bash
# Check if CronJob is suspended
kubectl get cronjob cloudflare-ddns -n cron-job -o yaml | grep suspend
```

**Issue:** Authentication errors
- Verify your API token in the secret
- Ensure token has "Edit DNS" permission
- Check token hasn't expired

**Issue:** IPv6 not working
- Ensure `hostNetwork: true` is set in cronjob.yaml
- Check if your cluster/nodes support IPv6

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete -k base/

# Or delete individually
kubectl delete namespace cron-job
```

## 🔐 Security Best Practices

1. **Never commit secrets to Git**
   ```bash
   # Add to .gitignore
   echo "base/secret.yaml" >> .gitignore
   ```

2. **Use Sealed Secrets or External Secrets** for production
   - [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
   - [External Secrets Operator](https://external-secrets.io/)

3. **Limit permissions** with RBAC if needed

4. **Use specific image tags** instead of `latest`:
   ```yaml
   image: timothyjmiller/cloudflare-ddns:1.0.3
   ```

## 📚 Advanced Usage

### Using Overlays for Multiple Environments

Create environment-specific configurations:

```
project/cloudflare-ddns/
├── base/
│   └── ...
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

Example `overlays/prod/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - schedule-patch.yaml

commonLabels:
  environment: production
```

Deploy overlay:
```bash
kubectl apply -k overlays/prod/
```

## 🔗 References

- [Official GitHub Repo](https://github.com/timothymiller/cloudflare-ddns)
- [Docker Hub](https://hub.docker.com/r/timothyjmiller/cloudflare-ddns)
- [Kustomize Documentation](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Cloudflare API Docs](https://developers.cloudflare.com/api/)
- [Kubernetes CronJob Docs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## 📝 License

This configuration is provided as-is. The underlying `timothymiller/cloudflare-ddns` project has its own license.
