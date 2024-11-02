### this is not monitoring the host yet

# Network Traffic Monitoring Stack

A Kubernetes-based network monitoring solution that uses Telegraf with TShark for packet capture, InfluxDB for storage, and Grafana for visualization.

## Overview

This project provides a complete stack for monitoring network traffic in a Kubernetes cluster. It captures and analyzes network packets, stores the data, and presents it in an interactive dashboard.

### Components
- **Telegraf** with TShark: Packet capture and metrics collection
- **InfluxDB**: Time-series database for storing metrics
- **Grafana**: Visualization and dashboarding

## Prerequisites

- Kubernetes cluster (minikube for local development)
- kubectl installed and configured
- Docker installed
- Base64 encoding utility

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/qwertyaya/Grafana-Tshark.git
cd Grafana-Tshark
```

### 2. Create Secrets
First, encode your secrets in base64:
```bash
echo -n 'your_admin_token_here' | base64
echo -n 'your_password_here' | base64
echo -n 'your_grafana_password_here' | base64
```

Update the encoded values in `kubernetes-manifests.yaml` under the `monitoring-secrets` section.

### 3. Build the Custom Telegraf Image
```bash
docker build -t your-registry/telegraf-tshark:1.0 .
docker push your-registry/telegraf-tshark:1.0
```

### 4. Deploy the Stack

Create the monitoring namespace and deploy all components:
```bash
kubectl apply -f kubernetes-manifests.yaml
```

Create the Telegraf configuration:
```bash
kubectl create configmap telegraf-config -n network-monitoring --from-file=telegraf.conf
```

### 5. Verify Deployment
```bash
# Check all pods are running
kubectl get pods -n network-monitoring

# Check services are available
kubectl get svc -n network-monitoring
```

### 6. Access the Dashboard

#### Set up port forwarding for Grafana:
```bash
kubectl port-forward svc/grafana -n network-monitoring 3000:3000
```

Access Grafana at: http://localhost:3000
- Default username: `admin`
- Password: The one you set in secrets

#### Configure Grafana

1. Add InfluxDB as a data source:
   - URL: `http://influxdb.network-monitoring.svc.cluster.local:8086`
   - Database: `network-metrics`
   - Organization: `your-org`
   - Token: Use the token from your secrets

2. Import the dashboard:
   - Go to Dashboards → Import
   - Upload the `network-dashboard.json` file

## Dashboard Features

The dashboard provides several visualizations:
- Network Interface Traffic
- Top Talkers Heatmap
- Traffic by IP Address
- Top Ports by Traffic Volume
- Active TCP Connections
- Top Destinations by Traffic Volume

## Configuration

### Telegraf Configuration
The `telegraf.conf` file includes:
- Packet capture using TShark
- Network interface monitoring
- TCP connection tracking
- Data output to InfluxDB

### Kubernetes Resources
- Persistent volumes for InfluxDB and Grafana
- Services for component communication
- DaemonSet for Telegraf deployment
- Deployments for InfluxDB and Grafana

## Troubleshooting

### Common Issues

1. Telegraf pod not starting:
```bash
kubectl logs -n network-monitoring -l app=telegraf
kubectl describe pod -n network-monitoring -l app=telegraf
```

2. No metrics in Grafana:
```bash
# Check InfluxDB connection
kubectl exec -it -n network-monitoring $(kubectl get pods -n network-monitoring -l app=telegraf -o name | head -n 1) -- curl -v http://influxdb.network-monitoring.svc.cluster.local:8086/health
```

3. TShark permissions:
```bash
kubectl exec -it -n network-monitoring $(kubectl get pods -n network-monitoring -l app=telegraf -o name | head -n 1) -- tshark -D
```

## Limitations

- When running in minikube, wireless interface (wlan0) capture is not available due to virtualization
- Host network access requires privileged container execution
- Resource usage may be high with heavy network traffic

## Security Considerations

1. The Telegraf DaemonSet runs with privileged access
2. Secrets are used for sensitive data
3. Network capture capabilities are restricted to cluster traffic

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request