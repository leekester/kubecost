$resourceGroup = "rg-aks"
$location = "uksouth"
$clusterName = "aks"
$nodesize = "Standard_B4ms"
$nodeCount = "1"
$subscriptionId = (az account show --query id --output tsv)

# Create AKS cluster
Write-Host "Creating AKS cluster $clusterName in resource group $resourceGroup" -ForegroundColor Yellow
az group create `
  --name $resourceGroup `
  --location $location
az aks create `
  --resource-group $resourceGroup `
  --name $clusterName `
  --node-vm-size $nodesize `
  --node-count $nodeCount `
  --enable-blob-driver `
  --network-plugin azure `
  --network-plugin-mode overlay `
  --pod-cidr 192.168.0.0/16 `
  --zones 1 `
  --generate-ssh-keys

# Retrieve AKS admin credentials
Write-Host "Retrieving AKS credentials" -ForegroundColor Yellow
az aks get-credentials --name $clusterName --resource-group $resourceGroup --overwrite-existing

# Deploy Kubecost
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
