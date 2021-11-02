# Job

### Запускаем простой job

1) Создаем job

```bash
kubectl apply -f ~/school-dev-k8s/practice/9.oneshot-tasks/1.job/job.yaml
```

2) Проверяем

```bash
kubectl get job
```

Видим:

```bash
NAME    COMPLETIONS   DURATION   AGE
hello   1/1           2s         88s
```

3) Смотрим на Pod'ы

```bash
kubectl get pod
```

Видим Pod, созданный Job'ой:

```bash
NAME          READY   STATUS      RESTARTS   AGE
hello-6l9tv   0/1     Completed   0          2m6s
```

4) Смотрим его логи

```bash
kubectl logs hello-6l9tv
```

Видим что все отработало правильно:

```bash
Mon Mar 18 15:06:10 UTC 2019
Hello from the Kubernetes cluster
```

5) Удаляем Job

```bash
kubectl delete job hello
```

### Проверяем работу параметра backoffLimit

6) Открываем файл job.yaml и находим командy выполняющуюся в Pod:

```yaml
args:
  - /bin/sh
  - -c
  - date; echo Hello from the Kubernetes cluster
```

И ломаем полностью:

```yaml
args:
  - /bin/sh
  - -c
  - date; echo Hello from the Kubernetes cluster; exit 1
```

7) Создаем Job:

```bash
kubectl apply -f ~/school-dev-k8s/practice/9.oneshot-tasks/1.job/job.yaml
```

8) Проверяем

```bash
kubectl get job
```

Видим:

```bash
NAME    COMPLETIONS   DURATION   AGE
hello   0/1           27s        27s
```

9) Смотрим на Pod'ы

```bash
kubectl get pod
```

Видим Pod'ы, созданные Job'ой:

```bash
NAME          READY   STATUS   RESTARTS   AGE
hello-5nvqf   0/1     Error    0          22m
hello-ks4ks   0/1     Error    0          22m
hello-rl984   0/1     Error    0          22m
```

Они в статусе Error

10) Смотрим в описание Job'ы

```bash
kubectl describe job hello
```

Видим, что backoffLimit сработал

```bash
  Warning  BackoffLimitExceeded  23m   job-controller  Job has reached the specified backoff limit
```

11) Удаляем Job

```bash
kubectl delete job hello
```

### Проверяем работу параметра activeDeadlineSeconds

12) Открываем файл job.yaml и находим командy, выполняющуюся в Pod'е:

```yaml
args:
  - /bin/sh
  - -c
  - date; echo Hello from the Kubernetes cluster
```

И делаем ее бесконечной

```yaml
args:
  - /bin/sh
  - -c
  - while true; do date; echo Hello from the Kubernetes cluster; sleep 1; done
```

13) Создаем Job

```bash
kubectl apply -f ~/school-dev-k8s/practice/9.oneshot-tasks/1.job/job.yaml
```

14) Проверяем

```bash
kubectl get job
```

Видим:

```bash
NAME    COMPLETIONS   DURATION   AGE
hello   0/1           27s        27s
```

15) Смотрим на Pod'ы

```bash
kubectl get pod
```

Видим Pod'ы, созданный Job'ой

```bash
NAME          READY   STATUS   RESTARTS   AGE
hello-bt6g6   1/1     Running   0          5s
```

16) Ждем 60 секунд и проверяем Job

```bash
kubectl describe job hello
```

Видим, что activeDeadlineSeconds сработал
```bash
  Warning  DeadlineExceeded  2m17s  job-controller  Job was active longer than specified deadline
```

17) Удаляем Job

```bash
kubectl delete job hello
```

### Есть еще два неописанных в манифесте Job'а параметра

Это `.spec.completions` и `.spec.parallelism` . Они отвечают за желаемое количество успешно выполненных Pod'ов в рамках Job'а и за параллельный запуск Pod'ов в рамках Job'а соответственно. 
