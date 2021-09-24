# Особенности ЯП в Kubernetes

## Java

### 1. Проверяем как видны лимиты на память в поде

Для этого выполним команду:

```bash
kubectl run --image centos test -- free -h
```

Проверим логи, для чего выполним команду:

```bash
kubectl logs test
```

Результат будет примерно следующим:

```bash
              total        used        free      shared  buff/cache   available
Mem:          3.9Gi       1.8Gi       303Mi       3.0Mi       1.7Gi       1.8Gi
Swap:            0B          0B          0B
```

Обратите внимание, что в поде видна вся память, доступная на ноде.
Что логично, ведь мы не указывали никаких лимитов при создании пода.

Теперь попробуем запустить тот же под с лимитами по памяти.
Сначала удаляем старый под:

```bash
kubectl delete po test
```

После завершения предыдущей операции создаем новый, указывая лимит в 128Mi памяти:

```bash
kubectl run --limits="memory=128Mi" --image centos test -- free -h
```

Проверим логи, для чего выполним команду:

```bash
kubectl logs test
```

И обнаружим результат эквивалентный предыдущему:

```bash
              total        used        free      shared  buff/cache   available
Mem:          3.9Gi       1.8Gi       303Mi       3.0Mi       1.7Gi       1.8Gi
Swap:            0B          0B          0B
```

> Тоже самое касается и CPU. Можно проверить с помощью указания лимита на поде
> `--limit="cpu=100m"` и выполнения команды `lscpu`

Удалим за собой тестовый под:

```bash
kubectl delete po test
```

## Интерпретируемые языки

### 1. Тестим автоопределение CPU

Запускаем под с Nginx. Для этого выполним команду:

```bash
kubectl run --image nginx:1.15 --limits="cpu=100m" test
```

Заходим в контейнер:

```bash
kubectl exec -t -i test bash
```

Внутри контейнера ставим утилиту ps:

```bash
apt-get update -y && apt-get install -y procps
```

Проверяем конфигурацию Nginx:

```bash
cat /etc/nginx/nginx.conf
```

По умолчанию выставлен worker_processes 1

Видим что запущен один воркер:

```bash
ps aux | grep nginx
```

Правим конфиг Nginx на автоопределение воркеров:

```bash
sed -i 's/worker_processes  1;/worker_processes  auto;/g' /etc/nginx/nginx.conf
```

Релоадим Nginx:

```bash
nginx -s reload
```

Проверяем количество запущенных воркеров:

```bash
ps aux | grep nginx
```

Обратите внимание, что несмотря на выставленный лимит для пода
в 100m CPU, Nginx запустил воркеров по количеству ядер на хосте

Удалим за собой под:

```bash
kubectl delete po test
```
