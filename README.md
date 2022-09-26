# Using GCP Cluster

### 1. Download helm Charts 
  - [msa-ez/on-prem-helm](https://github.com/msa-ez/on-prem-helm/blob/main/README.md)
---
### 2. Create & Connect GCP Cluster
---
### 3. on-prem 설치 
  - Cluseter ip: ```kubeclt cluseter-info```
  - Domain: Route53 도메인 중 사용할 도메인 
  - token: ```kubectl describe secret default```
    #### 1. yaml 파일 별 수정 필요 내용 
    - <b>deployment.yaml</b>: Cluseter ip, Domain, token
    - <b>values.yaml</b>: Cluseter ip, Domain
    - <b>2q</b>: Domain 
    - <b>ingress.yaml</b>: Domain 
    - <b>issuer.yaml</b> Domain
      * 변경 후 <b>issuer.yaml</b> 전체내용 주석 
    #### 2. helm install on-prem . 
      * on-prem install 후 <b>issuer.yaml</b> 주석 제거
    #### 3. Apply issuer, secrets.yaml 
      ```kubectl apply -f issuer.yaml, secrets.yaml```
    #### 4. ingress-nginx 설치
    ```
      helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx --create-namespace
    ```
---
### 4. Route53 도메인 record 생성 & 설정
  #### 1. gitlab, kas, minio, registry 생성 후 ip 등록
    - 사진
   - 등록할 IP: ```kubectl get ing```
     - 사진
  #### 2. *, api, www, file, acebase 생성 후 ip 등록
    - 사진
   - 등록할 IP: ```kubectl get svc -n ingress-nginx```, external-ip  
    - 사진
---
### 5. cd ide-operator
  #### 1. Operator 설치
    ```make deploy IMG=gcr.io/eventstorming-tool/theia-ide-lab:v137```
---
### 6. cd gcp_helm
  #### 1. <b>values.yaml/disk</b> 수정
    - 클러스터에 연결할 disk 명으로 수정 
  #### 2. nfs 설치 
    ```helm install gcp-msaez .```
---
