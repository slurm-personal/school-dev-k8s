### Знакомимся с Helm

1) Подключаем repo и смотрим kube-ops-view

```bash
helm repo add southbridge https://charts.southbridge.ru
helm repo update

helm search hub kube-ops
helm show values southbridge/kube-ops-view > values.yaml

```

2) Правим `values.yaml`:

```bash
ingress:
  enabled: true
...
hostname: kube-ops.s<свой номер логина>.mcs.slurm.io
...
```

3) Устанавливаем `kube-ops-view`:

```bash
helm install ops-view southbridge/kube-ops-view -f values.yaml
```

4) Переходим в браузер в Инкогнито режим и заходим на `http://kube-ops.s<свой номер логина>.mcs.slurm.io/`

5) Удаляем чарт:

```bash
helm delete ops-view
```

### Посмотрим, что внутри чарта:

```bash
helm pull southbridge/kube-ops-view

tar -zxvf kube-ops-view-<TAB>

cd kube-ops-view/
```

### Создадим свой чарт

1) Возьмем за основу нашего чарта готовый Deployment. Создадим папку будущего чарта и создадим внутри необходимые файлы и папки:

```bash
cd ~
mkdir myapp

cd myapp

touch Chart.yaml values.yaml
mkdir templates

cp ~/school-dev-k8s/practice/18.templating/simple-deployment.yaml ~/myapp/templates/
```

2) Добавим в файл `Chart.yaml` минимально необходимые поля:

```
name: myapp
version: 1
```

3) Проверим что рендеринг чарта работает, в выводе команды должны увидеть наш Deployment

```
helm template .
```

### Темплейтируем свой чарт

> **Если отстали, сверяемся с файлом `summary_file.yaml`**

1) Смотрим на файл `templates/simple-deployment.yaml` и темплейтируем в нем количество реплик и image

```bash
replicas: 1

меняем на

replicas: {{ .Values.replicas }}

...

image: nginx:1.14.2

меняем на

image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}" 
```

2) Добавляем значения этих переменных в файл `values.yaml`:

```bash
replicas: 3

image:
  repository: nginx
  tag: 1.12
```

3) Проверяем что все корректно и что наши values подцепились:

```bash
helm template .
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Затемплейтировать по аналогии в Deployment значение поля `containerPort: 80`

### Стандартизируем наш чарт

1) Заменяем все лейблы в Deployment, а также имя деплоймента и контейнера

```bash
  labels:
    app: nginx

меняем на

  labels:
    app: {{ .Chart.Name }}-{{ .Release.Name }}

---

name: nginx-deployment

меняем на

name: {{ .Chart.Name }}-{{ .Release.Name }}

---

      containers:
      - name: nginx

меняем на

      containers:
      - name: {{ .Chart.Name }}

```

2) Для проверки используем ту же команду, но с доп ключом:

```bash
helm template . --name-template foobar
```

3) Указываем количество реплик по-умолчанию:

```bash
{{ .Values.replicas | default 2 }}
``` 

4) Проверяем изменения, а также пробуем переназначить тэг образа через ключ `--set`:

```bash
helm template . --name-template foobar --set image.tag=1.13
```

### Добавляем в наш Deployment `requests/limits`

1) Добавляем в `values.yaml` реквесты и лимиты, прям в их обычном формате:

```bash
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 80m
    memory: 64Mi
```

2) В нашем темплейтированном манифесте говорим, чтобы за ресурсами он сходил в `values.yaml` и взял оттуда секцию целиком:

```bash
        ports:
        - containerPort: {{ .Values.service.internalPort }}
        resources:    <--- вставляем в это место
{{ toYaml .Values.resources }}

```

3) Проверяем изменения

```bash
helm template . --name-template foobar
```

4) Видим что не хватает отступов. Добавляем `indent` в наш Deployment:

```bash
было

{{ toYaml .Values.resources }}

стало

{{ toYaml .Values.resources | indent 10 }}
```

5) Проверяем исправилось ли 

```bash
helm template . --name-template foobar
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Добавить таким же образом `annotations`
- Поиграйтесь с indent'ом. Сделайте так, чтобы при рендеринге показывались верные отступы
- В `values.yaml` укажите значение аннотации `abc: xyz`

6) Добавляем условие в аннотации:

```bash
было

  annotations:
{{ toYaml .Values.annotations | indent 4 }}

стало

{{ if .Values.annotations }}
  annotations:
{{ toYaml .Values.annotations | indent 4 }}
{{ end }}

```

7) Смущают пустые строчки. Уберем их

```bash
было

{{ if .Values.annotations }}
  annotations:
{{ toYaml .Values.annotations | indent 4 }}
{{ end }}

стало

{{- if .Values.annotations }}
  annotations:
{{ toYaml .Values.annotations | indent 4 }}
{{- end }}

```

8) Проверяем что теперь все ОК

```bash
helm template . --name-template foobar
```

### Добавляем указание переменных окружения

1) Вносим в наш темплейтированный манифест следующее:

```bash
        - containerPort: {{ .Values.port }}
{{ if .Values.env }}    <--- Сюда вставляем
        env:
        {{ range $key, $val := .Values.env }}
        - name: {{ $key | quote }}
          value: {{ $val | quote }}
        {{ end }}
{{ end }}

```

2) Проверяем что ничего не сломали

```bash
helm template . --name-template foobar
```

3) Добавляем в `values.yaml` переменные окружения:

```bash
env:
  one: two
  ENV: DEVELOPMENT
```

4) Проверяем что переменные подтянулись

```bash
helm template . --name-template foobar
```

**ДОМАШНЯЯ РАБОТА:**

- Перейти в папку `homework`
- Запустить deployment из файла `bad_deployment.yaml`
- Исправить все найденные ошибки и сделать так, чтобы все pod'ы были в состоянии `Running 1/1`

Ответ-шпаргалка находится в файле `bad_deployment.yaml_otvet`

### Helm Tests

1) Переходим в каталог `~/school-dev-k8s/practice/18.templating/wordpress`, осматриваем чарт. Смотрим папку `tests` и манифест там

```bash
cd ~/school-dev-k8s/practice/18.templating/wordpress
ls
cd templates/tests/
ls
cat test-mariadb-connection.yaml
```
2) Устанавливаем чарт Wordpress в свой кластер и запускаем тесты:

```bash
helm install wordpress ~/school-dev-k8s/practice/18.templating/wordpress
helm test wordpress
```

3) Видим что все работает и тест прошел успешно. Удаляем чарт из кластера, однако замечаем что pod с тестом остается:

```bash
helm delete wordpress
kubectl get po
```

4) Удалим этот оставшийся pod. Затем модернизируем наши тесты, добавив туда аннотацию `"helm.sh/hook-delete-policy": hook-succeeded`

```bash
kubectl delete po <имя_пода>

cd ~/school-dev-k8s/practice/18.templating/
vim wordpress/templates/tests/test-mariadb-connection.yaml
```
```yaml
...
annotations: 
  "helm.sh/hook-delete-policy": hook-succeeded  <-- Добавляем аннотацию
  "helm.sh/hook": test-succeded
...
```

5) Снова ставим чарт и делаем тест:

```bash
helm install wordpress ~/school-dev-k8s/practice/18.templating/wordpress/
helm test wordpress
```

6) Видим, что теперь pod удаляется. Намеренно испортим тест, чтобы проверить что произойдет. Изменим в манифесте `test-mariadb-connection.yaml` номер порта с `3306` на `3333`. Затем обновим чарт, добавив необходимые переменные:

```bash
vim wordpress/templates/tests/test-mariadb-connection.yaml

export MARIADB_PASSWORD=$(kubectl get secret wordpress-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
export WORDPRESS_PASSWORD=$(kubectl get secret wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

helm upgrade --install wordpress ./wordpress/ --set mariadb.auth.password=$MARIADB_PASSWORD --set wordpressPassword=$WORDPRESS_PASSWORD
```

7) Выполним тест, указав таймаут, чтобы не ждать ошибки от самого pod'а. Смотрим статус теста и pod'а:

```bash
helm test wordpress --timeout 30s
kubectl get po
```

8) Удаляем чарт

```bash
helm delete wordpress
```

### Helm Library Chart

1) Смотрим на чарты в каталогах `libchart/` и `mychart/`

2) Проверяем как подключается библиотечный чарт с шаблоном configmap'а:

```bash
helm install libtest mychart/ --debug --dry-run
```

### Helm Cheatsheet

Поиск чартов

```bash
helm search hub
```

Получение дефолтных values

```bash
helm show values repo/chart > values.yaml
```

Установка чарта в кластер

```bash
helm install release-name repo/chart [--atomic] [--namespace namespace]
```

Локально отрендерить чарт

```bash
helm template /path/to/chart
```
