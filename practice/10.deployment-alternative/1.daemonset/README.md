# DaemonSet

1) Переходим в директорию с практикой.

```bash
cd ~/school-dev-k8s/practice/10.deployment-alternative/1.daemonset
```

2) Создаем демонсет

```bash
kubectl apply -f daemonset.yaml
```

В ответ должны увидеть

```bash
daemonset.apps/node-exporter created
```

3) Смотрим на поды

```bash
kubectl get pod -o wide
```

Видим
```bash
NAME                  READY   STATUS    RESTARTS   AGE   IP            NODE
node-exporter-g5tt8   2/2     Running   0          11s   10.107.32.4   gke-s000-default-pool-41fb7951-ntk8
node-exporter-jczbm   2/2     Running   0          32s   10.107.32.3   gke-s000-default-pool-41fb7951-4sns
node-exporter-xpb9f   2/2     Running   0          22s   10.107.32.2   gke-s000-default-pool-41fb7951-lkjn
```

4) Чистим за собой кластер

```bash
kubectl delete -f daemonset.yaml
```
