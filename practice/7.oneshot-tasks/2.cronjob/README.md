# CronJob

1) Создаем крон джоб

```bash
cd ~/slurm/practice/7.oneshot-tasks/2.cronjob
kubectl apply -f cronjob.yaml
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

3) Через минуту пробуем посмотреть на джобы

```bash
kubectl get job
```

Видим созданный джоб

```bash
NAME               COMPLETIONS   DURATION   AGE
hello-1552924260   1/1           2s         49s
```

4) Смотрим на поды

```bash
kubectl get pod
```

Видим под

```bash
NAME                     READY   STATUS      RESTARTS   AGE
hello-1552924260-gp7pk   0/1     Completed   0          80s
```

5) Если мы подождем 5-10 минут, то увидим что старые джобы и поды удаляются по мере появления новых

```bash
kubectl get job,pod
```

6) Удаляем крон джоб

```bash
kubectl delete -f cronjob.yaml
```
