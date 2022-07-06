# Configmap

## 1. Создаем configmap

Для этого выполним команду:

```bash
kubectl apply -f ~/school-dev-k8s/practice/4.saving-configurations/3.configmap/
```

## 2. Проверяем

Проверим, что configmap попал в контейнер, для этого пробросим порт из пода и выполним curl.
Для этого выполним команду, заменив имя pod на имя вашего pod(``можно воспользоваться автоподстановкой по TAB``).

& - это запуск команд в фоновом режиме, потом вводим следующую команду. 
```bash
kubectl port-forward my-deployment-5b47d48b58-l4t67 8080:80 &
curl 127.0.0.1:8080
```

В результате выполнения curl увидим имя пода, который обработал запрос. Результат должен быть примерно таким:

```bash
my-deployment-5b47d48b58-l4t67
```

## 3. Обновим configmap

```bash
kubectl edit configmap my-configmap

# изменим текст ответа

            return 200 '$hostname\nOK\n';
```

## 4. Проверим вывод пода

```bash
curl 127.0.0.1:8080
```

Вывод не изменился
