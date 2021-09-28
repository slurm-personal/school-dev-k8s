## Не запускается minikube - minikube start

Возможно вам надо включить Hyper-V. Запускаем PowerShell с админскими правами.  
Включаем 
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
После проделанной работы отключаем 
```
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

## Не монитруется локальная директория в minikube - minikube mount .:/app

Ошибка `X Exiting due to HOST_PATH_MISSING: Cannot find directory .;C for mount`

Нужно указать абсолютный путь. Указываем свое имя профиля - `<ваше имя профиля>`
```
minikube mount "C:\Users\<ваше имя профиля>\devk8s\practice\12.local-development\app:/app"
```
или
```
minikube mount C:\\Users\\<ваше имя профиля>\\devk8s\\practice\\12.local-development\\app:/app
```

## Всё равно не монтирует директорию в minikube

Ошибка
```
Process exited with status 32
stdout:

stderr:
mount: /app: mount(2) system call failed: Connection timed out.
```

Нужно отключить брандмауэр Windows  

Или задать правила в брандмауэр Windows. Создать два правила (UDP/TCP протоколов) для - Правила для входящих подключений. Задать в поле `Программа` путь, где лежит программа `C:\Program Files\Kubernetes\Minikube\minikube.exe`. В поле `Локальный адрес` задать IP диапазон из 1-ого и 2-ого октета в 16-ой маски `172.25.0.0./16`. Остальные поля `Любой`. 

Узнаем свой IP диапазон, где работает minikube.
```
$ minikube ip

172.25.46.107
```