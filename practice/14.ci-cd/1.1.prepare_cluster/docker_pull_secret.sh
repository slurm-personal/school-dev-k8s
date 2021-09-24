#!/bin/bash

NS=s<Ваш номер логина>-xpaste-production

kubectl delete secret xpaste-gitlab-registry --namespace "$NS"

kubectl create secret docker-registry xpaste-gitlab-registry \
  --docker-server registry.slurm.io \
  --docker-email 'student@slurm.io' \
  --docker-username '<первая строчка из окна создания токена в gitlab>' \
  --docker-password '<вторая строчка из окна создания токена в gitlab>' \
  --namespace "$NS"
