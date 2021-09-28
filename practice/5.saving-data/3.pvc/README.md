# PV/PVC

1) Применяем манифест pvc.yml

```bash
kubectl apply -f ~/school-dev-k8s/practice/5.saving-data/3.pvc/pvc.yaml

kubectl get pvc
kubectl get pv
```

2) Запустим приложение, использующее PV

```bash
kubectl apply -f ~/school-dev-k8s/practice/5.saving-data/3.pvc/
```

3) Посмотрим describe и смонтированные тома в контейнере

```bash
kubectl describe pod fileshare-<TAB>
kubectl exec -it fileshare-<TAB> -- df -h
```

4) Очищаем

```bash
kubectl delete -f ~/school-dev-k8s/practice/5.saving-data/3.pvc/
```
