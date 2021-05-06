### В рамках задания были использованы следующие инструменты:
1. terraform:
- подключен провайдер aws с модулями aws vpc и aws eks
- подключён провайдер kubernetes
- state хранится удалённо в S3 bucket
2. kubernetes - kubectl:
- основные ресурсы описаны в манифестах deployment.yaml, ingress.yaml
- для работы ingress использовался [ngin ingress-controller для aws](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/aws/deploy.yaml)

### Особенности проекта:
- Terraform разворачивает полностью настроенный k8s кластер на базе AWS EKS, в состав кластера входят 2 working-ноды типа t2.small
- Приложение реализовано на flask. Статитический контент перемещён в S3 bucket.
- Приложение было упаковано в docker-образ, образ залит в паблик репозиторий AWS ECR.
- В k8s-кластере приложение разворачивается в deployment, доступ к которому реализован через Service типа ClusterIP. 
  Публичный доступ через Ingress типа nginx, который стоит за сервисом типа LoadBalancer, реализованным на базе AWS ELB типа NLB, 
- На базе nginx реализована базовая аутентификация посредством basic-auth.
  
### Порядок разворачивания сайта
1. Запустить скрипты терраформ:

  $ terraform init

  $ terraform apply

2. Создать ресурсы с помощью манифестов из папки kube_yamls путём выполнения баш-скрипта из этой папки:

  $ ./deploy_k8s_resources

  После запуска всех ресурсов сайт станет доступен по адресу, на котором висит ingress (он же адрес NLB).

### На данный момент сайт доступен по следующему адресу:
 > address: [a3bfd6567038c43529efb81f6fa54ece-8e9e898aae4594fb.elb.eu-central-1.amazonaws.com](a3bfd6567038c43529efb81f6fa54ece-8e9e898aae4594fb.elb.eu-central-1.amazonaws.com)
 >
 > login: decathlon
 >
 > password: password

  
