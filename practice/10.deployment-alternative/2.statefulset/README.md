# StatefulSet

1) Переходим в директорию с практикой.

```bash
cd ~/school-dev-k8s/practice/10.deployment-alternative/2.statefulset
```

### Создаем стэйтфулсет

2) Применяем каталог с манифестами

```bash
kubectl apply -f rabbitmq-statefulset
```

В ответ должны увидеть

```bash
configmap/rabbitmq-config created
role.rbac.authorization.k8s.io/endpoint-reader created
rolebinding.rbac.authorization.k8s.io/endpoint-reader created
service/rabbitmq created
serviceaccount/rabbitmq created
statefulset.apps/rabbitmq created
```

3) Смотрим на поды

```bash
kubectl get pod
```

Видим:

```bash
NAME         READY   STATUS              RESTARTS   AGE
rabbitmq-0   0/1     ContainerCreating   0          31s
```

Поды начали создаваться по одному, с нулевого
Ждем, пока get pod не вернет все три работающих пода
Должно быть так:

```bash
NAME         READY   STATUS    RESTARTS   AGE
rabbitmq-0   1/1     Running   0          10m
rabbitmq-1   1/1     Running   0          7m
```

4) Проверяем что под каждый pod создался pvc

```bash
 kubectl get pvc
```

Видим:

```bash
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-rabbitmq-0   Bound    pvc-d9030631-496e-11e9-96e5-4201ac101193   2Gi        RWO            standard       10m
data-rabbitmq-1   Bound    pvc-01c40ac5-496f-11e9-96e5-4201ac101193   2Gi        RWO            standard       7m
```

## Проверяем сервис

5) Запускаем под для тестов

```bash
kubectl run -t -i --rm --image centosadmin/utils:0.3 test bash
```

6) Дальше уже из этого пода выполняем:

```bash
nslookup rabbitmq
```

В ответ видим, что DNS возвращает IP всех подов (IP подов можно проверить в соседней консоли через kubectl get pod -o wide)

```bash
Server:		10.107.0.10
Address:	10.107.0.10#53

Name:	rabbitmq.default.svc.cluster.local
Address: 10.107.16.12
Name:	rabbitmq.default.svc.cluster.local
Address: 10.107.16.13
Name:	rabbitmq.default.svc.cluster.local
Address: 10.107.18.24
```

7) Пробуем резолвить конкретный инстанс

```bash
nslookup rabbitmq-0.rabbitmq
```

В ответ видим, что DNS возвращает IP пода rabbitmq-0

```bash
Server:		10.107.0.10
Address:	10.107.0.10#53

Name:	rabbitmq-0.rabbitmq.default.svc.cluster.local
Address: 10.107.16.12
```

8) Выходим из тестового пода

```bash
exit
```

9) Чистим за собой кластер

```bash
kubectl delete -f rabbitmq-statefulset
kubectl delete pvc --all
```

Обязательно удаляем PVC отдельно! Удаление стэйтфулсета не чистит PVC
