#! /bin/bash
aws eks --region $1 update-kubeconfig --name $2 --kubeconfig $4
eksctl utils associate-iam-oidc-provider --region $1 --cluster $2 --approve
eksctl create iamserviceaccount --region $1 --cluster=$2 --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=$3  --override-existing-serviceaccounts --approve
helm repo add eks https://aws.github.io/eks-charts
helm repo update
kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$2 --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set image.repository=$5