#!/bin/bash

FQDN=javachen.xyz

#安装helm3
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#安装cert-manager
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
helm install cert-manager -n cert-manager --version v0.13.0 jetstack/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
kubectl -n cert-manager rollout status deploy/cert-manager-webhook


#安装cert-manager-webhook-dnspod
git clone https://github.com/qqshfox/cert-manager-webhook-dnspod.git
helm install cert-manager-webhook-dnspod -n cert-manager  \
    --set groupName=javachen.xyz \
    --set secrets.apiID=123438,secrets.apiToken=a028d574e4e390f259b97e4c3f4cb861 \
    --set clusterIssuer.enabled=true,clusterIssuer.email=czj.june@gmail.com  \
    cert-manager-webhook-dnspod/deploy/cert-manager-webhook-dnspod

#安装rancher
git clone https://github.com/javachen/charts.git
cat <<EOF > rancher-values.yaml
hostname: rancher.javachen.xyz
ingress:
  tls:
    source: letsEncrypt
letsEncrypt:
  email: chenzj@wesine.com
  environment: prod
  solvers: 
  - selector:
      dnsNames:
      - 'rancher.javachen.xyz'
    dns01:
      webhook:
        groupName: acme.javachen.xyz
        solverName: dnspod
        config:
          apiID: 123438 
          apiTokenSecretRef:
            key: api-token
            name: cert-manager-webhook-dnspod-secret
EOF
kubectl create namespace cattle-system
helm install rancher -n cattle-system ./charts/rancher -f rancher-values.yaml
