# Добавляем helm hook

## 1. Добавляем манифест job

```bash
cp job.yaml ~/xpaste/.helm/templates/job.yaml

cd ~/xpaste
```

## 2. Добавляем просмотр результатов работы job в CI/CD

Добавляем в `.gitlab-ci.yml` в шаг `deploy:` раздел `after_script:`

```yaml
deploy:
  ...
  after_script:
    - kubectl -n $CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME logs -lcomponent=atomiclog --tail=-1
    - kubectl -n $CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME delete job -lcomponent=atomiclog
```

## 3. Пушим, смотрим в вывод CI/CD

```
git add -A
git commit -am "Add job template for getting k8s logs if deploy has failed"
git push

```

## 4. Исправление настроек приложения

Ищем ошибку в выводе логов пода.

* Для исправления ошибки в работе приложения необходимо внести изменения в `values.yml` чарта, описанные в [snippet](https://gitlab.slurm.io/-/snippets/83)

Для проверки открываем в браузере URL: `http://xpaste.s<Ваш номер логина>.mcs.slurm.io`. `<Ваш номер логина>` необходимо заменить на номер своего студента. Открывать нужно в режиме `инкогнито`. Теперь приложение должно быть доступно.
