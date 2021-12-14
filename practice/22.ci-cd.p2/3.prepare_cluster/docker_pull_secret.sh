#!/bin/bash

NS=xpaste-production

kubectl delete secret xpaste-gitlab-registry --namespace "$NS"

kubectl create secret docker-registry xpaste-gitlab-registry \
  --docker-server registry.gitlab.com \
  --docker-email 'student@slurm.io' \
  --docker-username '<первая строчка из окна создания токена в gitlab>' \
  --docker-password '<вторая строчка из окна создания токена в gitlab>' \
  --namespace "$NS"
