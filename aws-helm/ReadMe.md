# AWS 배포 방법

## Cluster 생성

### AWS-Cli v2 설치

`curl “https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip” -o “awscliv2.zip”`
`unzip awscliv2.zip`
`sudo ./aws/install`

### AWS Configure

#### (AWS 관리콘솔)

1. 부여받은 교육 계정으로 AWS 콘솔 접속
1. IAM 서비스 접속
1. 왼쪽 메뉴에서 “엑세스 관리” > “사용자” 클릭
1. 나의 계정정보 클릭
1. 메인화면에서 “보안자격증명” 클릭
1. "액세스 키 만들기" 클릭
1. Access Key ID와 Secret Access key를 복사

#### 1. (클라이언트 Tool) 

1. aws configure 입력
1. 관리콘솔에 복사한 Access Key ID와 Secret Access key 입력
1. region 정보에 ap-northeast-2 입력
1. default output format에 json 입력

#### EKS Client (eksctl) 설치

1. `curl --location “https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz” | tar xz -C /tmp`
1. sudo mv /tmp/eksctl /usr/local/bin

#### Amazon EKS 생성

`eksctl create cluster --name Assessment-Cluster --version 1.19 --nodegroup-name standard-workers --node-type c5.4xlarge --nodes 4 --nodes-min 4 --nodes-max 5`

eksctl create cluster --name aws-Cluster0531 --version 1.19 --nodegroup-name standard-workers --node-type c5.4xlarge --nodes 4 --nodes-min 4 --nodes-max 5

#### 2. EKS 접속

1. `aws eks --region ap-northeast-2 update-kubeconfig --name {{Cluster-Name}}`

aws eks --region ap-northeast-2 update-kubeconfig --name aws-Cluster0531
aws eks --region ap-northeast-2 update-kubeconfig --name Cluster
<!-- 
1. 접속 후, Metric서버를 설치해줘야함.
   `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml` -->

1. efs csi driver

   1. `helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/`
    1. `helm repo update`
    1. `helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
      --namespace kube-system \
      --set image.repository=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/aws-efs-csi-driver \
      --set serviceAccount.controller.create=false \
      --set serviceAccount.controller.name=efs-csi-controller-sa`


kubectl get pod -n kube-system -l "app.kubernetes.io/name=aws-efs-csi-driver,app.kubernetes.io/instance=aws-efs-csi-driver"
확인
kubectl delete pod -n kube-system -l "app.kubernetes.io/name=aws-efs-csi-driver,app.kubernetes.io/instance=aws-efs-csi-driver"
삭제 

===
 
  1. helm install quickstart ingress-nginx/ingress-nginx 
  2. helm install aws-msaez .
      - value, pv.yaml 
  3. kubectl apply -f ingress.yaml 

  - `kubectl describe sa default` 
  - `kubectl describe secrets {{TOKENS}}`

## Operator 실행
  - make deploy IMG=gcr.io/eventstorming-tool/theia-ide-lab:v137


# get ing 
a12893a685467472698c6f4e3c9cb5bf-138631463.ap-northeast-2.elb.amazonaws.com


1. kubectl exec --tty -i redis-client \--namespace default -- bash
2. REDISCLI_AUTH=$REDISCLI_AUTH redis-cli -h redis-master


https://aws0809-labs--883425412.kuberez.io/#/home/project

