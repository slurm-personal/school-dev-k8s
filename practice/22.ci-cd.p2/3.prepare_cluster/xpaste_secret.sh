#!/bin/bash

NS=xpaste-production

kubectl delete secret slurm-xpaste --namespace "$NS"

kubectl create secret generic slurm-xpaste \
  --from-literal secret-key-base=xxxxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal db-user='xpaste' \
  --from-literal db-password='xpaste1234567890' \
  --namespace "$NS"
