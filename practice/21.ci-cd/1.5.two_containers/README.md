# Запускаем приложение в несколько реплик

## 1. Копируем манифест deployment

```
cp deployment.yaml ~/xpaste/.helm/templates/
```

## 2. Пушим, ждем запуска, рассматриваем

```
cd ~/xpaste
git add .helm/templates/deployment.yaml
git commit -m "Run app with nginx in separate containers"
git push
```

## 3. Смотрим описание пода, список запущенных процессов

```
kubectl describe pod ...
kubectl exec -it ...

ps ax
```
