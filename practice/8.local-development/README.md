# Local Development

[Ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/) на скачивание\как установить minikube 

В среде Windows, рекомендуем выполнять команды в [Git Bash](https://git-scm.com/downloads) 

[Описание и решение](https://github.com/Slurmio/school-dev-k8s/blob/main/practice/8.local-development/problems_window.md) возможных проблем на платформе Windows.  

## 1. Запускаем minikube

Для этого выполняем команду:

```bash
minikube start
```

И ждем завершения выполнения. После этого можем проверить что все работает:

```bash
kubectl get po -A
```

Должно вернуть что то типа:

```bash
kube-system   coredns-66bff467f8-mwqh4           1/1     Running   0          5m
kube-system   etcd-minikube                      1/1     Running   0          5m
kube-system   kube-apiserver-minikube            1/1     Running   0          5m
kube-system   kube-controller-manager-minikube   1/1     Running   0          5m
kube-system   kube-proxy-mq6g6                   1/1     Running   0          5m
kube-system   kube-scheduler-minikube            1/1     Running   0          5m
kube-system   storage-provisioner                1/1     Running   0         5m
```

## 2. Запускаем приложение

Сначала нужно подключиться к докеру в minikube. Для этого выполним команду:

```bash
eval $(minikube docker-env)
```

Дальше билдим образ

> ВАЖНО!!! нужно находиться в директории `~/school-dev-k8s/practice/8.local-development/app/`

```bash
docker build . -t myapp:dev
```

После этого В ОТДЕЛЬНОЙ КОНСОЛИ запускаем команду для монтирования
локальной директории в minikube.

> ВАЖНО!!! нужно находиться в директории `~/school-dev-k8s/practice/8.local-development/app/`

```bash
minikube mount .:/app
```

и оставляем ее висеть

Дальше возвращаемся в первую консоль и там аплаим манифесты

```bash
kubectl apply -f kube/
```

Проверяем что приложение запустилось

```bash
kubectl get po
```

и можем открыть его в браузере. Для этого можно просто выполнить команду:

```bash
minikube service myapp
```

## 3. Вносим изменения в код

Открываем файл app.py
и меняем строку

```diff
- return "Hello, World!"
+ return "Hello, Updated!"
```
Проверяем что приложение зарелоадилось

```bash
kubectl logs <pod_name>
```

Должно быть такое:

```bash
 * Detected change in '/app/app.py', reloading
 * Restarting with stat
```

и можем проверить в браузере что изменения действительно применились

## 4. Запускаем dashboard

```bash
minikube dashboard
```
