# ReplicaSet

## 1. Создаем Replicaset

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/3.application-abstractions/2.replicaset/replicaset.yaml
```

Проверим результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS              RESTARTS   AGE
my-replicaset-pbtdm   0/1       ContainerCreating   0          2s
my-replicaset-z7rwm   0/1       ContainerCreating   0          2s
```

## 2. Скейлим Replicaset

Для этого выполним команду:

```bash
kubectl scale replicaset my-replicaset --replicas 3
```

Проверим результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS              RESTARTS   AGE
my-replicaset-pbtdm   1/1       Running             0          2m
my-replicaset-szqgz   0/1       ContainerCreating   0          1s
my-replicaset-z7rwm   1/1       Running             0          2m
```

## 3. Удаляем один из Pod

Для этого выполним команду подставив имя своего Pod:

> можно воспользоваться автоподстановкой по TAB

```bash
kubectl delete pod my-replicaset-pbtdm
```

Проверим результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS              RESTARTS   AGE
my-replicaset-55qdj   0/1       ContainerCreating   0          1s
my-replicaset-pbtdm   1/1       Running             0          4m
my-replicaset-szqgz   1/1       Running             0          2m
my-replicaset-z7rwm   0/1       Terminating         0          4m
```

## 4. Добавляем в Replicaset лишний Pod

Открываем файл `2.replicaset/pod.yaml`

```bash
vim ~/school-dev-k8s/practice/3.application-abstractions/2.replicaset/pod.yaml
```

И в него после metadata: на следующей строке добавляем:

```yaml
  labels:
    app: my-app
```

В итоге должно получиться:

```yaml
.............
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
.............
```

Сохраняем и выходим.

Создаем дополнительный Pod, для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/3.application-abstractions/2.replicaset/pod.yaml
```

Проверяем результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS        RESTARTS   AGE
my-pod                0/1       Terminating   0          1s
my-replicaset-55qdj   1/1       Running       0          3m
my-replicaset-pbtdm   1/1       Running       0          8m
my-replicaset-szqgz   1/1       Running       0          6m
```

## 5. Обновляем версию Image

Для этого выполним команду:

```bash
kubectl set image replicaset my-replicaset nginx=nginx:1.13
```

Проверяем результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS        RESTARTS   AGE
my-replicaset-55qdj   1/1       Running       0          3m
my-replicaset-pbtdm   1/1       Running       0          8m
my-replicaset-szqgz   1/1       Running       0          6m
```

И проверяем сам Replicaset, для чего выполним команду:

```bash
kubectl describe replicaset my-replicaset
```

В результате находим строку Image и видим:

```bash
  Containers:
   nginx:
    Image:        nginx:1.13
```

Проверяем версию image в pod. Для этого выполним команду, подставив имя своего Pod

```bash
kubectl describe pod my-replicaset-55qdj
```

Видим что версия имаджа в поде не изменилась:

```bash
  Containers:
   nginx:
    Image:        nginx:1.12
```

Помогаем поду обновиться - для этого выполним команду, подставив имя своего Pod

```bash
kubectl delete po my-replicaset-55qdj
```

Проверяем результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                  READY     STATUS              RESTARTS   AGE
my-replicaset-55qdj   0/1       Terminating         0          11m
my-replicaset-cwjlf   0/1       ContainerCreating   0          1s
my-replicaset-pbtdm   1/1       Running             0          16m
my-replicaset-szqgz   1/1       Running             0          14m
```

Проверяем версию Image в новом Pod. Для этого выполним команду,
подставив имя своего Pod

```bash
kubectl describe pod my-replicaset-cwjlf
```

Результат должен быть примерно следующим:

```bash
    Image:          nginx:1.13
```

## 6. Чистим за собой кластер

Для этого выполним команду:

```bash
kubectl delete replicaset --all
```
