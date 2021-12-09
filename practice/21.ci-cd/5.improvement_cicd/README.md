# Ещё больше улучшений в конфиге CI/CD

## 1. Добавляем helm linter и вывод манифестов.

Добавляем новые шаги:

```
helm_lint:
  stage: linter
  image: centosadmin/kubernetes-helm:3.6.3
  environment:
    name: production
  script:
    - helm lint .helm
        --set image=$CI_REGISTRY_IMAGE
        --set imageTag=$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID
  only:
    - master
```

```
template:
  stage: template
  image: centosadmin/kubernetes-helm:3.6.3
  environment:
    name: production
  script:
    - helm template $CI_PROJECT_PATH_SLUG .helm
        --set image=$CI_REGISTRY_IMAGE
        --set imageTag=$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID
  only:
    - master
```

Заносим их в список стейджей

```
stages:
  - linter
  - build
  - template
  - deploy
```

Или копируем готовый файл `.gitlab-ci.yml` в репозиторий xpaste.

Пушим, смотрим результат.

## 2. Самостоятельная работа

Исправляем Error в выводе линтера, Warning можно пропустить.

PS: В принципе можно убрать ключ `--debug` из шага deploy.
