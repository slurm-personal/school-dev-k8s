# Applications debug

## 1. Тестим termination log

Запускаем в кластере подготовленный деплоймент. Для этого выполним команды:

```bash
cd ~/slurm/practice/15.application-debug
kubectl apply -f deployment.yaml
```

Проверим результат, для чего выполним команду:

```bash
kubectl get pod
```

Результат должен быть примерно следующим:

```bash
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-54cc978cf6-5d67r   1/1     Running   0          3s
```

Через какое-то время Pod должен рестартануть
и можно будет проверить как это выглядит в дескрайбе:

```bash
kubectl describe po my-deployment-<TAB>
```

```bash
    Last State:  Terminated
      Reason:    Error
      Message:   working OK
                 working OK
                 .......
                 working OK
                 broken

      Exit Code:    1
      Started:      Wed, 03 Mar 2021 15:46:27 +0300
      Finished:     Wed, 03 Mar 2021 15:46:38 +0300
```

## 2. Чистим за собой кластер

Для этого выполним команду:

```bash
kubectl delete deployment my-deployment
```
