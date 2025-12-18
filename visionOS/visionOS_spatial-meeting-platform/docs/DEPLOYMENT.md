# Deployment Guide

Complete guide for deploying the Spatial Meeting Platform.

## Quick Start with Docker Compose

### Prerequisites

- Docker 24.0+
- Docker Compose 2.0+
- 2GB RAM minimum
- 10GB disk space

### 1. Clone and Configure

```bash
git clone https://github.com/yourorg/spatial-meeting-platform.git
cd spatial-meeting-platform

# Create environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 2. Start Services

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 3. Verify Deployment

```bash
# Check backend health
curl http://localhost:3000/health

# Check API docs
open http://localhost:3000/api-docs

# Check admin dashboard
open http://localhost:3002
```

## Production Deployment

### AWS Deployment

#### Architecture

```
┌─────────────┐
│   Route 53  │
└──────┬──────┘
       │
┌──────▼──────┐
│     ALB     │
└──────┬──────┘
       │
   ┌───┴───┐
   │  ECS  │
   └───┬───┘
       │
┌──────▼──────┐
│     RDS     │
└─────────────┘
```

#### Step 1: Create RDS Database

```bash
aws rds create-db-instance \
  --db-instance-identifier spatial-meetings-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.3 \
  --master-username postgres \
  --master-user-password <YOUR_PASSWORD> \
  --allocated-storage 20 \
  --backup-retention-period 7 \
  --publicly-accessible
```

#### Step 2: Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build and push backend
docker build -t spatial-backend ./backend
docker tag spatial-backend:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spatial-backend:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spatial-backend:latest

# Build and push dashboard
docker build -t spatial-dashboard ./admin-dashboard
docker tag spatial-dashboard:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spatial-dashboard:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spatial-dashboard:latest
```

#### Step 3: Create ECS Task Definition

```json
{
  "family": "spatial-meeting-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spatial-backend:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        },
        {
          "containerPort": 3001,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "DB_HOST",
          "value": "<RDS_ENDPOINT>"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:<ACCOUNT_ID>:secret:spatial-db-password"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:<ACCOUNT_ID>:secret:spatial-jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/spatial-meeting-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### Step 4: Create ECS Service

```bash
aws ecs create-service \
  --cluster spatial-meeting-cluster \
  --service-name spatial-backend-service \
  --task-definition spatial-meeting-backend \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx,subnet-yyy],securityGroups=[sg-xxx],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...,containerName=backend,containerPort=3000"
```

### Digital Ocean Deployment

#### Step 1: Create Droplet

```bash
# Create Ubuntu 22.04 droplet (2GB RAM minimum)
doctl compute droplet create spatial-meeting \
  --size s-2vcpu-2gb \
  --image ubuntu-22-04-x64 \
  --region nyc1 \
  --ssh-keys <YOUR_SSH_KEY_ID>
```

#### Step 2: Install Docker

```bash
# SSH into droplet
ssh root@<DROPLET_IP>

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Step 3: Deploy Application

```bash
# Clone repository
git clone https://github.com/yourorg/spatial-meeting-platform.git
cd spatial-meeting-platform

# Configure environment
cp .env.example .env
nano .env

# Start services
docker-compose up -d

# Set up reverse proxy with Caddy
docker run -d --name caddy \
  --network spatial-meeting-network \
  -p 80:80 -p 443:443 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  -v caddy_data:/data \
  caddy:latest
```

#### Caddyfile Configuration

```
api.yourdom ain.com {
  reverse_proxy backend:3000
}

dashboard.yourdomain.com {
  reverse_proxy dashboard:80
}

ws.yourdomain.com {
  reverse_proxy backend:3001
}
```

### Kubernetes Deployment

#### Step 1: Create Namespace

```bash
kubectl create namespace spatial-meeting
```

#### Step 2: Deploy PostgreSQL

```yaml
# postgres.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: spatial-meeting
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: spatial-meeting
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: spatial_meetings
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: spatial-meeting
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

#### Step 3: Deploy Backend

```yaml
# backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: spatial-meeting
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: <YOUR_REGISTRY>/spatial-backend:latest
        ports:
        - containerPort: 3000
        - containerPort: 3001
        env:
        - name: NODE_ENV
          value: production
        - name: DB_HOST
          value: postgres
        - name: DB_NAME
          value: spatial_meetings
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: spatial-meeting
spec:
  selector:
    app: backend
  ports:
  - name: http
    port: 3000
    targetPort: 3000
  - name: websocket
    port: 3001
    targetPort: 3001
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  namespace: spatial-meeting
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/websocket-services: backend
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.yourdomain.com
    secretName: backend-tls
  rules:
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 3000
```

#### Step 4: Deploy

```bash
# Create secrets
kubectl create secret generic db-credentials \
  --from-literal=username=postgres \
  --from-literal=password=<YOUR_PASSWORD> \
  -n spatial-meeting

kubectl create secret generic jwt-secret \
  --from-literal=secret=<YOUR_JWT_SECRET> \
  -n spatial-meeting

# Deploy
kubectl apply -f postgres.yaml
kubectl apply -f backend.yaml

# Check status
kubectl get pods -n spatial-meeting
kubectl logs -f deployment/backend -n spatial-meeting
```

## Monitoring

### Setup Prometheus & Grafana

```yaml
# monitoring/docker-compose.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3001:3000"

volumes:
  prometheus_data:
  grafana_data:
```

## Backup Strategy

### Database Backups

```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

docker exec spatial-postgres pg_dump -U postgres spatial_meetings | \
  gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

# Keep only last 30 days
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +30 -delete
```

### Restore from Backup

```bash
gunzip -c backup_20250115_020000.sql.gz | \
  docker exec -i spatial-postgres psql -U postgres spatial_meetings
```

## Security Checklist

- [ ] Change default passwords
- [ ] Use strong JWT secret (min 32 characters)
- [ ] Enable HTTPS/TLS
- [ ] Set up firewall rules
- [ ] Enable database encryption
- [ ] Regular security updates
- [ ] Monitor access logs
- [ ] Set up rate limiting
- [ ] Implement CORS properly
- [ ] Use secrets management (AWS Secrets Manager, Vault)

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs backend

# Check database connection
docker exec spatial-backend sh -c 'ping -c 3 postgres'

# Restart services
docker-compose restart backend
```

### High Memory Usage

```bash
# Check container stats
docker stats

# Limit container memory
docker-compose up -d --scale backend=2 --memory=512m
```

### Database Connection Issues

```bash
# Test database connection
docker exec spatial-postgres psql -U postgres -c "SELECT 1"

# Check database logs
docker-compose logs postgres
```

## Performance Tuning

### PostgreSQL Optimization

```sql
-- Increase connection pool
ALTER SYSTEM SET max_connections = 200;

-- Enable query optimization
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
```

### Node.js Optimization

```javascript
// Cluster mode for multi-core
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  startServer();
}
```

## Support

- **Documentation**: https://docs.spatialmeeting.com
- **Issues**: https://github.com/yourorg/spatial-meeting-platform/issues
- **Email**: devops@spatialmeeting.com
