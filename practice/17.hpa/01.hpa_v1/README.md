### HPA v1

---

**1. Запускаем Metric server (!!! только при выполнении практики на собственном кластере - Minikube и тд)**

* Применяем манифесты Metric server

Поскольку Metric server не устанавливается в Kubernetes кластер по умолчанию, первое что необходимо сделать - это установить его. Все необходимые манифесты находятся в каталоге `for-minikube-only-metric-server` и их можно сразу применить в кластер. Для этого необходимо в консоли выполнить команду:

```bash
kubectl apply -f for-minikube-only-metrics-server/ -n kube-system
```

* Проверяем работу Metric server

Metric server собирает данные с kubelet c периодичностью 1 раз в минуту. После установки необходимо подождать 1-2 минуты и выполнить команду:

```bash
kubectl top node
```

Данная команда выведет текущую нагрузку на ноды. В результате выполнения команды на экран будут выведены примерно следующие данные:

```bash
NAME                     CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
master-1.s000000.slurm.io   122m         12%    1693Mi          44%
master-2.s000000.slurm.io   114m         11%    1489Mi          38%
master-3.s000000.slurm.io   97m          9%     1423Mi          37%
node-1.s000000.slurm.io     59m          5%     1505Mi          39%
node-2.s000000.slurm.io     357m         35%    1389Mi          36%
```

Важной особенностью Metric Server является то, что он не хранит полученные данные, а только отображает последние полученные. По этому расценивать его как полноценную систему мониторинга нельзя. 

**2. Запускаем тестовое приложение**

В качестве тестового приложения будет использоваться специальное приложение, предназначенное для тестирования HPA. Приложение написано на PHP, и при запросах генерирует высокую нагрузку. Для начала применим Deployment в кластер, выполнив команду:

```bash
kubectl apply -f deploy/deployment.yml
```

Для работы HPA обязательным является наличие у Pod выставленных `request`. Обратите внимание на [deployment.yml](deploy/deployment.yml), в нем указано:

```yaml
resources:
  requests:
    cpu: 100m
```

Теперь создадим Service. Для этого мы не будем использовать готовые манифесты, а воспользуемся ключом `expose` для kubectl. Данный ключ позволяет создать Service для Deployment без написания манифеста. В итоге получается следующая команда, которую необходимо выполнить в консоли:

```bash
kubectl expose deployment php-apache --port 80
```

**3. Устанавливаем HPA**

Для запуска HPA так же воспользуемся возможностями kubectl. Для создания абстракции HPA без манифеста можно использовать ключ `autoscale`. Выполним команду:

```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=5
```

В результате выполнения команды будет создан HPA, который отслеживает состояние Deployment с именем `php-apache`. При достижении средней нагрузки на все Pod 50% (для расчетов суммируется процент нагрузки на каждый Pod и делится на их количество) scaling будет производиться в границах от 1-го Pod до 5 Pod.

**4. Проверяем работу**

* Смотрим на текущее количество Pod

```bash
kubectl get pod
```

Должен быть запущен один Pod

```bash
NAME                          READY   STATUS    RESTARTS   AGE
php-apache-566d7644df-z9dtt   1/1     Running   0          15s
```

* Смотрим на HPA

```bash
kubectl get hpa
```

Видим созданный HPA

```bash
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   1%/50%    1         5         1          32s
```

Она будет скейлить Pod, как только их использование cpu начнет составлять 50% от request.

* Создаем нагрузку

Для генерации нагрузки создадим еще один Pod из образа busybox. Внутри Pod в цикле будет запущена утилита wget, которая будет обращаться к тестовому приложению по имени Service. В итоге получается следующая команда, которую необходимо выполнить в консоли:

```bash
kubectl run load-generator --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
```
?!? Если возникают ошибки "load-generator 0/1 ImagePullBackOff" запрашиваем образ так --image=gcr.io/google-containers/busybox:latest

* Проверяем текущее потребление cpu Pod

Metric server может отдавать не только нагрузку по Node, но и по Pod. Для вывода информации по нагрузке от Pod выполните команду:

```
kubectl top pod
```

Видим, что нагрузка начинает увеличиваться.

```bash
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-566d7644df-z9dtt   936m         11Mi
```

* Ждем когда начнет работать Autoscaling

У kubectl есть ключ `-w`, который позволяет выводить в режиме реального времени все изменения для нашего текущего запроса. Выполним следующую команду в консоли, чтобы отслеживать изменения количества Pod:

```bash
kubectl get pod -w
```

Спустя несколько минут количество Pod должно увеличиться до 5-ти.

```bash
NAME                              READY   STATUS    RESTARTS   AGE
load-generator-6b9cf94758-5qmbx   1/1     Running   0          2m16s
php-apache-566d7644df-4zvv7       1/1     Running   0          108s
php-apache-566d7644df-kv662       1/1     Running   0          93s
php-apache-566d7644df-tg8qw       1/1     Running   0          108s
php-apache-566d7644df-z9dtt       1/1     Running   0          13m
php-apache-566d7644df-zlwd7       1/1     Running   0          108s
```

Отлично, autoscaling сработал!

* Проверяем работу в обратную сторону

Удаляем Pod с тестовой нагрузкой выполнив команду:

```bash
kubectl delete pod load-generator
```

* Проверяем нагрузку на поды

```bash
kubectl top pod
```

Через какое-то время замечаем, что она упала

```bash
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-566d7644df-4zvv7   1m           11Mi
php-apache-566d7644df-kv662   1m           11Mi
php-apache-566d7644df-tg8qw   1m           11Mi
php-apache-566d7644df-z9dtt   1m           11Mi
php-apache-566d7644df-zlwd7   1m           11Mi
```

* Проверяем, как autoscaling отработает в обратную сторону

```bash
kubectl get pod -w
```

Видим, что ненужные поды умирают (в течение 5 минут).  После снижения нагрузки scale down не происходит слишком быстро, чтобы избежать ситуации, когда значения по потреблению находятся в пограничном состоянии.

```bash
NAME                          READY   STATUS        RESTARTS   AGE
php-apache-566d7644df-4zvv7   0/1     Terminating   0          8m59s
php-apache-566d7644df-kv662   0/1     Terminating   0          8m44s
php-apache-566d7644df-tg8qw   0/1     Terminating   0          8m59s
php-apache-566d7644df-z9dtt   1/1     Running       0          20m
php-apache-566d7644df-zlwd7   0/1     Terminating   0          8m59s
```

Autoscaling вернул все к первоначальному варианту с одним Pod.

**5. Чистим за собой кластер**

```bash
kubectl delete all --all
```

#### Troubleshooting

* Проверяем, что Metric server запущен

```bash
kubectl get po -n kube-system | grep metrics-server
```

Поды должны быть в состоянии `STATUS: Running` и `READY 1/1`. Если Pod отсутствует, начинаем практику с первого пункта. Если состояние не `Running` или `0/1`, то смотрим причины, выполнив команду:

```bash
kubectl describe po -n kube-system metrics-server-<TAB>
```

* Проверяем, что метрики доступны

Для проверки доступности метрик выполним команду:

```bash
kubectl top node
```

Если не выводится потребления по Node, но в прошлом шаге не выявлено ошибок, то пробуем установить еще раз все абстракции, выполнив команду:

```bash
kubectl apply -f ~/slurm/practice/8.hpa/v1/metrics-server -n kube-system
```

#### Полезные ссылки

1. [k8s doc: HPA v1](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
2. [Metric server](https://github.com/kubernetes-sigs/metrics-server)
