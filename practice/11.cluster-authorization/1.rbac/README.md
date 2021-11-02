# RBAC

1) Исправляем манифесты

Исправляем название namespace в rolebinding

```bash
cd ~/slurm/practice/11.cluster-authorization/1.rbac
vim rolebinding.yaml
```

2) Создаем объекты

```bash
kubectl apply -f .

```

Видим:

```bash
configmap/my-configmap-env created
rolebinding.rbac.authorization.k8s.io/user created
secret/my-secret created
serviceaccount/user created
```

3) Пробуем получить список configmap под юзером

```bash
kubectl get configmap --as=system:serviceaccount:s<номер студента>:user
```

Список возвращается:
```bash
NAME               DATA   AGE
my-configmap-env   2      4m44
```

4) Пробуем получить список secret под юзером

```bash
kubectl get secret --as=system:serviceaccount:s<номер студента>:user
```

Выдается ошибка:
```bash
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:s000001:user" cannot list resource "secrets" in API group "" in the namespace "s000001"
```

5) Пробуем получить список сервисов под юзером в неймспейсе kube-system

```bash
kubectl get service --as=system:serviceaccount:s<номер студента>:user -n kube-system
```

Возвращается ошибка:
```bash
Error from server (Forbidden): services is forbidden: User "system:serviceaccount:s000001:user" cannot list resource "services" in API group "" in the namespace "kube-system"
```

6) Теперь пробуем удалить конфигмап  под юзером

```bash
kubectl delete configmap my-configmap-env --as=system:serviceaccount:s<номер студента>:user kubernetes
```

Видим что RBAC работает:

```bash
Error from server (Forbidden): configmaps "my-configmap-env" is forbidden: User "system:serviceaccount:s000001:user" cannot delete resource "configmaps" in API group "" in the namespace "s000001"
```

7) Чистим за собой кластер

```bash
kubectl delete -f .
```
