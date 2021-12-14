# Деплой на production

## 1. Добавляем переменные и шаг деплоя на production кластер

```yaml
variables:
  K8S_PROD_API_URL: https://ip.add.re.ss:6443
```

```yaml
deploy:prod:
  stage: deploy
  image: centosadmin/kubernetes-helm:3.6.3
  environment:
    name: production
  script:
    - kubectl config set-cluster k8s --insecure-skip-tls-verify=true --server=$K8S_PROD_API_URL
    - kubectl config set-credentials ci --token=$K8S_PROD_CI_TOKEN
    - kubectl config set-context ci --cluster=k8s --user=ci
    - kubectl config use-context ci
    - helm upgrade --install xpaste .helm
        -f .helm/values.prod.yaml
        --set image=$CI_REGISTRY_IMAGE
        --set imageTag=$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID
        --debug
        --atomic
        --timeout 120s
        --namespace $NAMESPACE-$CI_ENVIRONMENT_SLUG
  only:
    - master
```

Или копируем готовый файл `.gitlab-ci.yml` в репозиторий xpaste.

## 2. Создаем production настройки для чарта

```bash
cd .helm
cp values.yaml values.prod.yaml
vi values.prod.yaml
```

Исправляем адрес БД в .helm/values.prod.yaml
```
env:
  DB_HOST: 10.0.0.19
```

Исправляем host в ingress

```
ingress:
  host: xpaste.s000005.vkcs.slurm.io
```
Пушим, смотрим результат.

