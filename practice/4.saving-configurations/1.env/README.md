# Environment

## 1. Применим манифесты для создания deployment

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/1.env/deployment-with-env.yaml
```

## 2. Проверяем результат

Для этого выполним команду, подставив вместо < RANDOM > нужное значение(`автоподстановка по TAB`):

```bash
kubectl describe pod my-deployment-< RANDOM >
```

Результат должен содержать:

```bash
Environment:
      TEST:    foo
```

## 3. Создаем configmap

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/1.env/configmap.yaml
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/1.env/deployment-with-env-cm.yaml
```

## 4. Проверяем результат

Для этого выполним команду, подставив вместо < RANDOM > нужное значение(`автоподстановка по TAB`):

```bash
kubectl exec -it my-deployment-< RANDOM > -- env
```

Результат должен содержать:

```bash
TEST=foo
dbhost=postgresql
DEBUG=false
```
