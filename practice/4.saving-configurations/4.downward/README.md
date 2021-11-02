# Secret

## 1. Применим деплоймент

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/4.downward/
```

## 2. Смотрим переменные окружения в контейнере

Для этого выполним команду, подставив вместо < RANDOM > нужное значение(`автоподстановка по TAB`):

```bash
kubectl exec -it my-deployment-< RANDOM > -- env
```

## 3. Смотрим файлы в контейнере /etc/podinfo

Для этого выполним команду, подставив вместо < RANDOM > нужное значение(`автоподстановка по TAB`):

```bash
kubectl exec -it my-deployment-< RANDOM > -- cat /etc/podinfo/labels

kubectl exec -it my-deployment-< RANDOM > -- cat /etc/podinfo/annotations
```

PS: Документация

https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/
https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/

## 4. Очистка

```
kubectl delete deployment my-deployment
kubectl delete configmap my-configmap-env
kubectl delete configmap my-configmap
kubectl delete secret test
```
