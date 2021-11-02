# Deployment

## 1. Создаем deployment

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/3.application-abstractions/3.deployment/
```

Проверяем список pods, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно таким:

```bash
NAME                             READY     STATUS              RESTARTS   AGE
my-deployment-7c768c95c4-47jxz   0/1       ContainerCreating   0          2s
my-deployment-7c768c95c4-lx9bm   0/1       ContainerCreating   0          2s
```

Проверяем список replicaset, для этого выполним команду:

```bash
kubectl get replicaset
```

Результат должен быть примерно таким:

```bash
NAME                       DESIRED   CURRENT   READY     AGE
my-deployment-7c768c95c4   2         2         2         1m
```

## 2. Обновляем версию image

Обновляем версию image для container в deployment my-deployment.
Для этого выполним команду:

```bash
kubectl set image deployment my-deployment nginx=nginx:1.13
```

Проверяем результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно таким:

```bash
NAME                             READY     STATUS              RESTARTS   AGE
my-deployment-685879478f-7t6ws   0/1       ContainerCreating   0          1s
my-deployment-685879478f-gw7sq   0/1       ContainerCreating   0          1s
my-deployment-7c768c95c4-47jxz   0/1       Terminating         0          5m
my-deployment-7c768c95c4-lx9bm   1/1       Running             0          5m
```

И через какое-то время вывод этой команды станет:

```bash
NAME                             READY     STATUS    RESTARTS   AGE
my-deployment-685879478f-7t6ws   1/1       Running   0          33s
my-deployment-685879478f-gw7sq   1/1       Running   0          33s
```

Проверяем что в новых pod новый image. Для этого выполним команду,
заменив имя pod на имя вашего pod:

```bash
kubectl describe pod my-deployment-685879478f-7t6ws
```

Результат должен быть примерно таким:

```bash
    Image:          nginx:1.13
```

Проверяем что стало с replicaset, для этого выполним команду:

```bash
kubectl get replicaset
```

Результат должен быть примерно таким:

```bash
NAME                       DESIRED   CURRENT   READY     AGE
my-deployment-685879478f   2         2         2         2m
my-deployment-7c768c95c4   0         0         0         7m
```

## 3. Чистим за собой кластер

```bash
kubectl delete deployment --all
```
