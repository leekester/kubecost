helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace

# Create ALB ingress
kubectl apply -f simple-ingress.yaml

# Deploy example resources for Kubecost to look at
kubectl apply -f .\sample-apps.yaml

# Get the Kubecost URL(s)
Write-Host "Waiting a few seconds for the kubecost service to be exposed.." -ForegroundColor Yellow
Sleep 5
$kubecostJson = kubectl get svc kubecost -n kubecost -o json
$kubecostConfig = $kubecostJson | ConvertFrom-Json

If ($kubecostConfig.status.loadBalancer.ingress.ip) {
    Write-Host ("Internal URL of Kubecost is http://" + $kubecostConfig.spec.clusterIP) -ForegroundColor Yellow
}

If ($kubecostConfig.status.loadBalancer.ingress.ip) {
    Write-Host ("Public URL of Kubecost is http://" + $kubecostConfig.status.loadBalancer.ingress.ip) -ForegroundColor Yellow
}
