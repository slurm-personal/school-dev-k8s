## Смотрим на Service'ы Kubernetes'а

1) Деплоим "основное" приложение

```bash
cd ~/slurm/practice/5.network-abstractions/2.ingress-and-services/

kubectl apply -f app
```

2) Запустим тестовое приложение, с которого мы будем обращаться к основному:

```bash
kubectl run test --image=amouat/network-utils -it bash

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

5) Создаем Service типа Nodeport:

```bash
kubectl apply -f nodeport.yaml
```

6) Проверяем что все ОК. Смотрим наши Service'ы, находим NodePort. Фиксируем, какой порт нам открылся и проверяем работу Service'а:

```bash
kubectl get svc

curl node-1.slurm.io:<свой номер порта>

curl master-1.slurm.io:<свой номер порта>
```

7) Создаем Service LoadBalancer:

```bash
kubectl create -f loadbalancer.yaml

kubectl get svc
```

8) Подчищаем за собой:

```bash
kubectl delete svc my-service-lb my-service-np
```

## Разбираемся с Ingress'ами

1) Создадим Ingress без указания хоста:

```bash
kubectl apply -f nginx-ingress.yaml
kubectl get ing
```

2) Попробуем покурлить разные домены:

```bash
curl my.s<свой номер логина>.k8s.slurm.io

curl notmy.s<свой номер логина>.k8s.slurm.io 
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Подправить Ingress таким образом, чтобы он работал только на домене `my.s<свой номер логина>.k8s.slurm.io`

Правильный ответ лежит в `right_answers/`
