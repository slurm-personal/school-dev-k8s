## Смотрим на Service'ы Kubernetes'а

1) Деплоим "основное" приложение

```bash
cd ~/school-dev-k8s/practice/6.network-abstractions/2.ingress-and-services/

kubectl apply -f app
```

2) Запустим тестовое приложение, с которого мы будем обращаться к основному:

```bash
kubectl run test --image=centosadmin/utils:0.3 -it bash

exit
```

3) Создаем Service типа ClusterIP:

```bash
kubectl apply -f clusterip.yaml
```

4) Убедимся, что Service работает. Узнаем его IP, зайдем внутрь нашего тестового Pod'а и обратимся к основному приложению, используя имя сервиса и IP:

```bash
kubectl get svc
kubectl exec test -it bash

curl <ip-адрес сервиса>
curl my-service

exit
```

## Важно! На Service'ы типа NodePort и LoadBalancer просто смотрим. Их в кластере не создаем!

5) Смотрим как выглядят Service'ы типа Nodeport и LoadBalancer:

```bash
cat nodeport.yaml
cat loadbalancer.yaml
```

6) Подчищаем за собой:

```bash
kubectl delete svc my-service-lb my-service-np
```

## Разбираемся с Ingress'ами

1) Создадим Ingress, предварительно поправив плейсхолдер:

```bash
vim host-ingress.yaml

kubectl apply -f host-ingress.yaml
kubectl get ing
```

2) Попробуем покурлить:

```bash
curl my.s<свой номер логина>.mcs.slurm.io

curl notmy.s<свой номер логина>.mcs.slurm.io 
```
