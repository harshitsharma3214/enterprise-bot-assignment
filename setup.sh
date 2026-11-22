#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="demo"
IMAGE="demo-app:1.0.0"

for cmd in docker kind kubectl helm; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: $cmd is not installed"
    exit 1
  }
done

echo "==> Checking Docker"
docker info >/dev/null

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "==> Creating kind cluster"
  CONFIG="$(mktemp)"
  cat > "$CONFIG" <<'KIND'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    labels:
      ingress-ready: "true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 8083
        protocol: TCP
      - containerPort: 443
        hostPort: 8446
        protocol: TCP
KIND
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG"
  rm -f "$CONFIG"
else
  echo "==> Reusing existing kind cluster"
fi

kubectl config use-context "kind-${CLUSTER_NAME}"

echo "==> Installing ingress-nginx"
kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/kind/deploy.yaml

kubectl rollout status deployment/ingress-nginx-controller \
  -n ingress-nginx --timeout=300s

echo "==> Building application image"
docker build -t "$IMAGE" "$ROOT_DIR/service"

echo "==> Loading image into kind"
kind load docker-image "$IMAGE" --name "$CLUSTER_NAME"

echo "==> Installing/upgrading Helm release"
helm upgrade --install demo "$ROOT_DIR/chart" \
  --namespace demo \
  --create-namespace \
  --wait \
  --timeout 300s

echo "==> Deployment status"
kubectl get pods,svc,ingress -n demo

echo "==> Setup completed"
echo "Test with: curl -H 'Host: demo.local' http://localhost:8083/"
