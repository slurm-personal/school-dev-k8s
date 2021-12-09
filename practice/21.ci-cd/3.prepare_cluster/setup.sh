#!/bin/bash

CI_PROJECT_PATH_SLUG=$1
CI_ENVIRONMENT_NAME=$2


GREEN='\033[0;32m'
NC='\033[0m'


usage() {
    echo "Usage: $0 CI_PROJECT_PATH_SLUG CI_ENVIRONMENT_NAME"
}

base64_decode_key() {
if [[ "$OSTYPE" == "linux"* ]]; then
    echo "-d"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "-D"
else
    echo "--help"
fi
}


if [ -z "$CI_PROJECT_PATH_SLUG" ] || [ -z "$CI_ENVIRONMENT_NAME" ]; then
  usage
  exit 1
fi

NS="$CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME"
SA="$CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME"
ROLE="$CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME"
ROLEBIND="$CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME"

if kubectl get ns "$NS"; then
    echo -e "${GREEN}namespace for project already exists${NC}"
else
    echo -e "${GREEN}creating namespace for project${NC}"
    kubectl create namespace "$NS"
    echo
fi

if kubectl -n "$NS" get sa "$SA"; then
    echo -e "${GREEN}serviceaccount for project already exists${NC}"
else
    echo
    echo -e "${GREEN}creating CI serviceaccount for project${NC}"
    kubectl create serviceaccount \
        --namespace "$NS" \
        "$SA"
    echo
fi

if kubectl -n "$NS" get role "$ROLE"; then
    echo -e "${GREEN}role for project already exists${NC}"
else
    echo -e "${GREEN}creating CI role for project${NC}"
    cat << EOF | kubectl apply --namespace $NS -f -
        apiVersion: rbac.authorization.k8s.io/v1
        kind: Role
        metadata:
          name: "$ROLE"
        rules:
        - apiGroups: ["", "extensions", "apps", "batch", "events", "networking.k8s.io", "certmanager.k8s.io", "cert-manager.io", "monitoring.coreos.com"]
          resources: ["*"]
          verbs: ["*"]
EOF
    echo
fi

if kubectl -n "$NS" get rolebinding "$ROLEBIND"; then
    echo -e "${GREEN}rolebinding for project already exists${NC}"
else
    echo -e "${GREEN}creating CI rolebinding for project${NC}"
    kubectl create rolebinding \
        --namespace "$NS" \
        --serviceaccount "$NS":"$SA" \
        --role "$ROLE" \
        "$ROLEBIND"
    echo
fi

echo -e "${GREEN}access token for new CI user:${NC}"
kubectl get secret \
    --namespace "$NS" \
    $( \
        kubectl get serviceaccount \
            --namespace "$NS" \
            "$SA" \
            -o jsonpath='{.secrets[].name}'\
    ) \
    -o jsonpath='{.data.token}' | base64 $(base64_decode_key)
echo

