# Pod

## 1. Создаем Pod

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/3.application-abstractions/1.pod/pod.yaml
```

Проверим результат, для чего выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME      READY     STATUS              RESTARTS   AGE
my-pod    0/1       ContainerCreating   0          2s
```

Через какое-то время Pod должен перейти в состояние `Running`
и вывод команды `kubectl get po` станет таким:

```bash
NAME      READY     STATUS    RESTARTS   AGE
my-pod    1/1       Running   0          59s
```

## 2. Скейлим приложение

Открываем файл pod.yaml редактором:

```bash
vim ~/school-dev-k8s/practice/3.application-abstractions/1.pod/pod.yaml
```

Входим в режим редактирования нажатием `i`  и заменяем там строку:

```diff
-  name: my-pod
+  name: my-pod-1
```

Сохраняем и выходим.

> Для vim нужно нажать последовательность кнопок
>
> `<Esc>:wq<Enter>`
> **Esc** - выход из режима редактирования,
> комбинация **:wq** - сохраняет внесенные изменения

Применяем изменения, для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/3.application-abstractions/1.pod/pod.yaml
```

Проверяем результат, для этого выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME      READY     STATUS    RESTARTS   AGE
my-pod    1/1       Running   0          10m
my-pod-1  1/1       Running   0          59s
```


Посмотрим описание, для чего выполним команду:

```bash
kubectl describe pod my-pod
```

## 3. Чистим за собой кластер

Для этого выполним команду:

```bash
kubectl delete pod --all
```
