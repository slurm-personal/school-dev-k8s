# CronJob

1) Создаем CronJob:

```bash
kubectl apply -f ~/school-dev-k8s/practice/9.oneshot-tasks/2.cronjob/cronjob.yaml
```

2) Проверяем

```bash
kubectl get cronjob
```

Видим:

```bash
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */1 * * * *   False     0        <none>          14s
```

3) Через минуту пробуем посмотреть на Job'ы

```bash
kubectl get job
```

Видим созданный Job

```bash
NAME               COMPLETIONS   DURATION   AGE
hello-1552924260   1/1           2s         49s
```

4) Смотрим на Pod'ы

```bash
kubectl get pod
```

Видим Pod

```bash
NAME                     READY   STATUS      RESTARTS   AGE
hello-1552924260-gp7pk   0/1     Completed   0          80s
```

5) Если мы подождем 5-10 минут, то увидим что старые Job'ы и Pod'ы удаляются по мере появления новых

```bash
kubectl get job,pod
```

6) Удаляем CronJob

```bash
kubectl delete -f ~/school-dev-k8s/practice/9.oneshot-tasks/2.cronjob/cronjob.yaml
```
