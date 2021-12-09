# Запуск раннера в Kubernetes

## 1. Добавляем helm repo

```bash
helm repo add gitlab https://charts.gitlab.io
```

## 2. Установка gitlab-runner в кластер

Перед установкой нужно поправить файл с настройками: ```values.yaml```

Для того, чтобы раннер зарегистрировался, нужно будет вписать уникальный токен, взятый из вашего форка xpaste вот тут: ``Settings - CI/CD - Runners - Specific runners - registration token``. Скопируйте его из Gitlab и вставьте в файл values.yaml, в переменную `runnerRegistrationToken`.

Как вы уже поняли, для установки мы пойдем знакомым путём Helm, выполнив команды:

```bash
helm upgrade -i gitlab-runner gitlab/gitlab-runner -f values.yaml -n gitlab-runner --create-namespace
```

## 3. Проверка регистрации раннера

Там же, где вы брали токен для регистрации раннера, можно будет посмотреть на него (если всё сделано правильно) в списке "Available specific runners".
