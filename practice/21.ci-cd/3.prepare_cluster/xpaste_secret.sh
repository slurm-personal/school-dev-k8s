#!/bin/bash

NS=xpaste-development

kubectl delete secret slurm-xpaste --namespace "$NS"

kubectl create secret generic slurm-xpaste \
  --from-literal secret-key-base=xxxxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal db-user='postgres' \
  --from-literal db-password='postgres' \
  --namespace "$NS"
