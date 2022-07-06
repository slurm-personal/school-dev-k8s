### HPA v2

---

#### С чем будем работать

* `Prometheus` устанавливается из Helm репозитория
* `Prometheus adapter` устанавливается из Helm репозитория
* `HPA v2` является стандартной абстракцией кластера Kubernetes
* Каталог `deploy` содержит необходимые для прохождения практики манифесты
* Бинарный файл `wrk` - утилита для генерации нагрузки на тестовое приложение
* В качестве тестового приложения будет выступать `nginx`

#### Где будем выполнять практику

* Данная практика выполняется на собственном кластере Kubernetes - Minikube и тд

#### Практика

**1. Подготовка кластера**

* Устанавливаем helm
```bash
wget https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz
tar xzvf helm-v3.0.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

* Устанавливаем Helm репозиторий

Переходим к установке Prometheus. Сначала необходимо установить Helm репозиторий, в котором находится Prometheus Helm chart. Для этого выполним команду:
 
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

* Устанавливаем Prometheus

Для прохождения практики нам потребуется только сам Prometheus и kube-state-metrics экспортер. Все остальные компоненты лучше отключить, сделать это можно через `values.yml` или прямое переопределение переменных через ключ `--set`. В итоге получается следующая команда, которую необходимо выполнить в консоли:

```bash
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace --set alertmanager.enabled=false --set pushgateway.enabled=false --set nodeExporter.enabled=false --set server.persistentVolume.enabled=false
```

* Ставим Prometheus adapter

Устанавливаем Prometheus adapter, который необходим для доступа к метрикам Prometheus через kube-api (HPA умеет получать метрики только из kube-api). Он также устанавливается с помощью Helm chart. Через ключ `--set` указываем, по какому адресу и порту доступен Prometheus. Так как они находятся в одном namespace, можно указать просто имя сервиса. В итоге получается следующая команда, которую необходимо выполнить в консоли:

```bash
helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring --set prometheus.url=http://prometheus-server --set prometheus.port=80
```

* Проверяем, что всё заработало 

Проверяем, что все поды запустились. Для этого выполним команду:

```bash
kubectl get po -n monitoring
```

Эта команда выведет данные обо всех Pod в namespace monitoring. Все Pod должны быть в состояние `STATUS: Running` и `READY 1/1` или `READY 2/2` в зависимости от количества контейнеров в Pod. Если какие-то Pod не в этом состояние, стоит повторить команду через 1-2 минуты.

Теперь проверяем, что метрики Prometheus доступны через kube-api.  Для этого можно послать прямой запрос к kube-api. C использованием утилиты `kubectl` и указав ключ `--raw` можно выполнить запрос к любому kube-api endpoint. Получим список доступных метрик, выполнив следующую команду: 

```bash
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
```

На экран будет выведен список всех доступных метрик. Список должен быть длинным. 

Теперь проверим, что Prometheus адаптер зарегистрировался в kube-api. Для этого выполним команду:

```bash
kubectl get apiservices.apiregistration.k8s.io  v1beta1.custom.metrics.k8s.io
```

Результат должен быть следующим:

```bash
NAME                            SERVICE                         AVAILABLE   AGE
v1beta1.custom.metrics.k8s.io   monitoring/prometheus-adapter   True         1m
```

Данный результат говорит, что при обращении к kube-api на endpoint `v1beta1.custom.metrics.k8s.io` запросы будут перенаправлены в Service с именем `prometheus-adapter` в namespace `monitoring`. Данный Service доставляет запросы в Pod с prometheus-adapter, который в свою очередь, преобразует метрики из вида Prometheus к виду kube-api.  

**2. Запускаем тестовое приложение**

В качестве тестового приложения будет выступать Nginx, у которого мы будем запрашивать default page. Доступ к Pod будет открыт через Ingress. Для реализации данной схемы необходимо создать: Pod, Service и Ingress.

* Создаем Deployment и Service

Для начала применим Deployment в кластер, выполнив команду:

```bash
kubectl apply -f deploy/deployment.yml -n default
```

Теперь создадим Service, для этого мы не будем использовать готовые манифесты, а воспользуемся ключом `expose` для kubectl. Данный ключ позволяет создать Service для Deployment без написания манифеста. В итоге получается следующая команда, которую необходимо выполнить в консоли:

```bash
kubectl expose deployment hpa-v2-test --port 80 -n default
```

В результате выполнения данной команды будет создан Deployment и запущен Pod c Nginx версии 1.13. А так же будет создан Service, через который будет доступен данный Pod.

* Создаем Ingress

Зададим ip адрес, по которому принимает запросы Ingress, для этого в файле `deploy/ingress.yml` необходимо заменить <External Ingress IP> на IP адрес. Для миникуба это будет вывод команды `minikube ip` И применим данный манифест в кластер Kubernetes, выполнив команду:

```bash
kubectl apply -f deploy/ingress.yml -n default
```

* Проверяем результат

Для проверки, что все настроено верно, выполним запрос на `hpa-v2-test.<External Ingress IP>.nip.io`. Например, выполнив команду:

```bash
curl -I hpa-v2-test.<External Ingress IP>.nip.io
```

Ответ должен быть примерно таким:
```bash
HTTP/1.1 200 OK
Date: Tue, 19 May 2020 19:57:28 GMT
Content-Type: text/html
Content-Length: 612
Connection: keep-alive
Vary: Accept-Encoding
Last-Modified: Mon, 09 Apr 2018 16:01:09 GMT
ETag: "5acb8e45-264"
Accept-Ranges: bytes
```

**3. Настройка правил Prometheus**

* Для начала попросим прометеус собирать метрики с ингресс контроллеров. Для этого
отредактируем деплоймент ингресса

```bash
kubectl edit deployment -n ingress-nginx ingress-nginx-controller
```

В него нужно добавить на уровне темплейта пода две аннотации:

```yaml
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      annotations: # <--- вот отсюда
        prometheus.io/port: "10254"
        prometheus.io/scrape: "true"
```

Для того чтобы поды смогли пересоздаться, придется вручную заскейлить
деплоймент до одной реплики

```bash
kubectl scale deployment -n ingress-nginx --replicas=1 ingress-nginx-controller
```

Дождаться когда одна реплика обновится и после этого заскейлить обратно до двух реплик.

* Обновляем настройки Prometheus

Ingress-controller отдает в Prometheus метрику с общим количеством запросов, а не за промежуток времени. В то же время HPA не умеет работать с функциями для обработки метрик Prometheus, поэтому нам необходимо дописать в Prometheus `recording rule` для получения нужной нам метрики.

Для этого получаем текущие значения Helm values для запущенного у нас Prometheus

```bash
helm get values --all prometheus -n monitoring > values.yaml   
```

Далее находим в файле `rules: {}` и заменяем на правило:

```yaml
rules:
  groups:
    - name: Ingress
      rules:
        - record: nginx_ingress_controller_requests_per_second
          expr: rate(nginx_ingress_controller_requests[5m])
```

Не забудьте убрать пустой словарь `(скобки {})` после rules.

Применяем изменения, для этого выполним команду:

```bash
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring -f values.yaml         
```

После применения изменений в Prometheus появится новая метрика с именем `nginx_ingress_controller_requests_per_second`.

Проверяем, что метрика `nginx_ingress_controller_requests_per_second` доступна через kube-api.

Prometheus `начинает считать` данную метрику только после прохождения трафика через Ingress. Поэтому выполним несколько тестовых запросов, повторив 2-3 раза команду:

```bash
curl -I hpa-v2-test.<External Ingress IP>.nip.io
```

Теперь проверим доступность метрики `nginx_ingress_controller_requests_per_second` через kube-api. Для этого выполним команду:

```bash
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | grep --color nginx_ingress_controller_requests_per_second        
```

В результате выполнения этой команды на экран будет выведен список всех метрик и цветом обозначена наша новая метрика: `nginx_ingress_controller_requests_per_second`. Обратите внимание что метрика будет доступна спустя некоторое время.

**3. Создаем HPA**

Осталось добавить в кластер объект типа HPA. Важной особенностью HPA является то, что он не является cluster-wide, проще говоря он может взаимодействовать с Deployment только в том же namespace. Манифест для HPA уже подготовлен, и теперь его необходимо применить в кластер. Для этого выполните команду: 

```bash
kubectl apply -f deploy/hpa-v2.yml -n default
```

Проверяем, что манифест применился, для этого выполним команду:

```bash
kubectl get hpa -n default
```

В результате выполнения этой команды на экран будет выведен список всех объектов типа HPA. В списке должен присутствовать HPA с именем: `hpa-v2-test`.

**4. Тестирование работы HPA**

* Создаем тестовую нагрузку

Для создания тестовой нагрузки будем использовать утилиту wrk из текущего каталога. Для запуска выполним команду:

```bash
./wrk -c 5 -t 2 -d 15m --latency http://hpa-v2-test.<External Ingress IP>.nip.io
```

* Проверка результата

Через 5-10 минут (в другой консоли) проверьте, что HPA успешно отработал и Pod стало больше. Для этого выполните команду: 

```bash
kubectl get po -n default
```

Количество Pod `hpa-v2-test-XXX` должно было увеличиться.

* Отключаем тестовую нагрузку

Для отключения тестовой нагрузки в консоли, где запущен wrk, выполните: `CTRL + C`. 

Обратите внимание, что количество Pod уменьшится не сразу после прекращения нагрузки. Это связано с тем, что HPA производит scale down не сразу, что бы избежать ситуации, когда нагрузка находится у пороговых значений. Количество Pod будет уменьшено в течение нескольких минут.

**5. Чистим за собой кластер**

```bash
kubectl delete all --all -n default
kubectl delete apiservice v1beta1.custom.metrics.k8s.io
kubectl delete ns monitoring
```

#### Troubleshooting

* Проверяем, что Prometheus запущен

```bash
kubectl get po -n monitoring
```

Эта команда выведет данные о всех Pod в namespace monitoring. Все Pod должны быть в состоянии `STATUS: Running` и `READY 1/1` или `READY 2/2` в зависимости от количества контейнеров в Pod. Если какие-то Pod не в этом состоянии, стоит повторить команду через 1-2 минуты. Если что-то не работает, надо смотреть причину: `kubectl describe po -n monitoring <Pod name>`. Часто причина заключается в нехватке ресурсов, в этом случае необходимо удалить абстракции прошлых практик.

* Проверяем, что метрики доступны

!Перед проверкой доступности метрики необходимо выполнить несколько запросов к приложению.!

```bash
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | grep nginx_ingress_controller_requests_per_second        
```

В результате выполнения этой команды на экран будет выведено: `nginx_ingress_controller_requests_per_second`.

Если метрики недоступны, проверяем наличие и корректность добавления правил в Prometheus. Пункт 3. 

* Перед выполнением пункта 2 на minikube необходимо включить addon ingress

```bash
minikube addons enable ingress
```


#### Полезные ссылки

1. [k8s doc: HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics)
2. [github: HPA](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/autoscaling/hpa-v2.md)
