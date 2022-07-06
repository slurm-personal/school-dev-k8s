# Secret

## 1. Создаем секрет

Для этого выполним команду:

```bash
kubectl create secret generic test --from-literal=test1=asdf --from-literal=dbpassword=1q2w3e
kubectl get secret
kubectl get secret test -o yaml
```

## 2. Применим наш деплоймент

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/2.secret/deployment-with-secret.yaml
```

## 3. Проверяем результат

Для этого выполним команду, подставив вместо < RANDOM > нужное значение(`автоподстановка по TAB`):

```bash
kubectl describe pod my-deployment-< RANDOM >
```

Результат должен содержать:

```bash
Environment:
      TEST:    foo
      TEST_1:  <set to the key 'test1' in secret 'test'>  Optional: false
```

## 4. Применяем манифест с секретом

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/2.secret/secret.yaml
```

## 5. Проверяем что в секрете

```bash
kubectl get secret test -o yaml
```

## 6. Исправляем манифест секрета и применяем

```bash
# изменяем ключ test на test1
vim  ~/school-dev-k8s/practice/4.saving-configurations/2.secret/secret.yaml
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/2.secret/secret.yaml
```

## 7. Проверяем что в секрете

```bash
kubectl get secret test -o yaml
```
