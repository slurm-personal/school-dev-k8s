# Создаем кластер

## 1. Создаем кластер в веб-интерфейсе VK Cloud Solutions

1 мастер из 2 cpu 4Gb RAM
2 узла и 1 cpu 2Gb RAM

Ждем пока кластер создасться и на вкладке подключение скачиваем конфиг для kubectl

## 2. объединяем два конфига

```bash
# Make a copy of your existing config 
cp ~/.kube/config ~/.kube/config.bak 

# Merge the two config files together into a new config file 
KUBECONFIG=~/.kube/config:~/.kube/vkcs kubectl config view --flatten > ~/.kube/config.new

# Replace your old config with the new merged config 
mv ~/.kube/config.new ~/.kube/config

# check config
kubectl config view

# (optional) Delete the backup once you confirm everything worked ok 
rm ~/.kube/config.bak
```

## 3. Переключаем на нужный контекст

```bash
kubectl config get-context
kubectl config use-context default/kubernetes-cluster-6802
```
