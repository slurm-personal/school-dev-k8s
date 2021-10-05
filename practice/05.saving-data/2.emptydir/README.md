# EmptyDir

1) Применяем манифест

```bash
kubectl apply -f ~/school-dev-k8s/practice/5.saving-data/2.emptydir/
```

2) Заходим в под и создаем файлик на томе empty dir

```bash
kubectl exec -it my-deployment-<TAB> -- sh -c 'echo "Some data" > /files/data.txt'

kubectl exec -it my-deployment-<TAB> -- cat /files/data.txt
```

3) Удаляем под и ищем данные

```bash
kubectl delete pod my-deployment-<TAB>
```

```bash
kubectl exec -it my-deployment-<TAB> -- cat /files/data.txt
```

4) Очищаем

```bash
kubectl delete deployment my-deployment
```
