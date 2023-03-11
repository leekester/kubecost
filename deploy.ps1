helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace

# Create ALB ingress
kubectl apply -f simple-ingress.yaml

# Deploy example resources for Kubecost to look at
kubectl apply -f .\sample-apps.yaml --create-namespace
