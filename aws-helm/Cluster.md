# AWS 배포 방법

## Cluster 생성

### AWS-Cli v2 설치

`curl “https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip” -o “awscliv2.zip”`  
`unzip awscliv2.zip`  
`sudo ./aws/install`

### AWS Configure

#### AWS 관리콘솔

1. 부여받은 교육 계정으로 AWS 콘솔 접속
1. IAM 서비스 접속
1. 왼쪽 메뉴에서 “엑세스 관리” > “사용자” 클릭
1. 나의 계정정보 클릭
1. 메인화면에서 “보안자격증명” 클릭
1. "액세스 키 만들기" 클릭
1. Access Key ID와 Secret Access key를 복사

#### 클라이언트 Tool

1. aws configure 입력
1. 관리콘솔에 복사한 Access Key ID와 Secret Access key 입력
1. region 정보에 ap-northeast-2 입력
1. default output format에 json 입력

#### EKS Client (eksctl) 설치

1. `curl --location “https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz” | tar xz -C /tmp`
1. sudo mv /tmp/eksctl /usr/local/bin

#### Amazon EKS 생성

`eksctl create cluster --name Assessment-Cluster --version 1.17 --nodegroup-name standard-workers --node-type c5.4xlarge --nodes 4 --nodes-min 4 --nodes-max 6`

#### EKS 접속

1. `aws eks --region ap-northeast-2 update-kubeconfig --name {{Cluster-Name}}`

1. 접속 후, Metric서버를 설치해줘야함.  
   `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml`

===

## EFS 생성

#### AWS 관리콘솔

1. efs 생성
   - 옵션 생성시, Virtual Private Cloud(VPC) 설정에서 이전에 생성한 클러스터 선택
   - 생성한 efs 선택 > 네트워크
   - 관리 선택후, 가용영역별로 보안그룹을 미선택 되어 있는 부분 모두 선택.
