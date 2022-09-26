# IDE Operator

## 프로젝트 생성

```sh
$ mkdir ide-operator
$ cd ide-operator
$ operator-sdk init --plugins=helm --domain=org --group=uengine --version=v1alpha1 --kind=Ide
```

## 프로젝트 생성시 구조

```bash
├── Dockerfile
├── Makefile
├── PROJECT
├── config
│   ├── crd
│   │   ├── bases
│   │   │   └── demo.my.domain_idees.yaml
│   │   └── kustomization.yaml
│   ├── default
│   │   ├── kustomization.yaml
│   │   └── manager_auth_proxy_patch.yaml
│   ├── manager
│   │   ├── kustomization.yaml
│   │   └── manager.yaml
│   ├── prometheus
│   │   ├── kustomization.yaml
│   │   └── monitor.yaml
│   ├── rbac
│   │   ├── auth_proxy_client_clusterrole.yaml
│   │   ├── auth_proxy_role.yaml
│   │   ├── auth_proxy_role_binding.yaml
│   │   ├── auth_proxy_service.yaml
│   │   ├── kustomization.yaml
│   │   ├── leader_election_role.yaml
│   │   ├── leader_election_role_binding.yaml
│   │   ├── ide_editor_role.yaml # API 선언
│   │   ├── ide_viewer_role.yaml # API 선언
│   │   ├── role.yaml  # ServiceAccount 관련 에러 발생시, Role 수정 필요 / API 선언
│   │   └── role_binding.yaml
│   ├── samples
│   │   ├── uengine_v1alpha1_ide.yaml # Kind와 apiVersion이 작성되어있는 Sample YAML
│   │   └── kustomization.yaml
│   └── scorecard
│       ├── bases
│       │   └── config.yaml
│       ├── kustomization.yaml
│       └── patches
│           ├── basic.config.yaml
│           └── olm.config.yaml
├── helm-charts # Operator로 사용할 Helm Chart 작성
│   └── ide
│       ├── Chart.yaml
│       ├── charts
│       ├── templates
│       │   ├── NOTES.txt
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── hpa.yaml
│       │   ├── ingress.yaml
│       │   ├── service.yaml
│       │   ├── serviceaccount.yaml
│       │   └── tests
│       │       └── test-connection.yaml
│       └── values.yaml
└── watches.yaml
```

## Operator 실행 과정

1. helm-charts쪽의 파일은 모두 삭제하고 사용할 Helm Chart를 넣어준다.
2. Root 폴더에서 `make docker-build docker-push IMG=$dockerId/$repository:$version`

```bash
$ make docker-build docker-push IMG=gcr.io/eventstorming-tool/theia-ide-lab:v83
docker build . -t sanghoon01/ide-operator:v24
Sending build context to Docker daemon  62.46kB
Step 1/5 : FROM quay.io/operator-framework/helm-operator:v1.2.0
 ---> 16b9c17cdfce
Step 2/5 : ENV HOME=/opt/helm
 ---> Using cache
 ---> c66823a8b083
Step 3/5 : COPY watches.yaml ${HOME}/watches.yaml
 ---> Using cache
 ---> bc58d45b5ca0
Step 4/5 : COPY helm-charts  ${HOME}/helm-charts
 ---> dc6916d7e8bf
Step 5/5 : WORKDIR ${HOME}
 ---> Running in d3d43b600286
Removing intermediate container d3d43b600286
 ---> 1c5d9c294bf4
Successfully built 1c5d9c294bf4
Successfully tagged sanghoon01/ide-operator:v24
docker push sanghoon01/ide-operator:v24
The push refers to repository [docker.io/sanghoon01/ide-operator]
d2f967f4bb59: Pushed
0513c4129333: Layer already exists
20acaf8fcea7: Layer already exists
9c2b721a715f: Layer already exists
ba8840240cdf: Layer already exists
37330a2a1954: Layer already exists
d6ec160dc60f: Layer already exists
v24: digest: sha256:ca90d287a64f3e61f25027473036aeaf174991e711f83aad650442fa177108a0 size: 1778
```

1. Root 폴더에서 `make deploy IMG=$dockerId/$repository:$version`

```bash
$ make deploy IMG=gcr.io/eventstorming-tool/theia-ide-lab:v83
cd config/manager && /usr/local/bin/kustomize edit set image controller=sanghoon01/ide-operator:v24
/usr/local/bin/kustomize build config/default | kubectl apply -f -
namespace/ide-operator-system unchanged
customresourcedefinition.apiextensions.k8s.io/ides.uengine.org unchanged
role.rbac.authorization.k8s.io/ide-operator-leader-election-role unchanged
clusterrole.rbac.authorization.k8s.io/ide-operator-manager-role unchanged
clusterrole.rbac.authorization.k8s.io/ide-operator-metrics-reader unchanged
clusterrole.rbac.authorization.k8s.io/ide-operator-proxy-role unchanged
rolebinding.rbac.authorization.k8s.io/ide-operator-leader-election-rolebinding unchanged
clusterrolebinding.rbac.authorization.k8s.io/ide-operator-manager-rolebinding unchanged
clusterrolebinding.rbac.authorization.k8s.io/ide-operator-proxy-rolebinding unchanged
service/ide-operator-controller-manager-metrics-service unchanged
deployment.apps/ide-operator-controller-manager configured
```

1. 3번의 과정을 거치고 난 후, `kubectl get deployment -n ide-operator-system`을 실행.

```bash
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
ide-operator-controller-manager   1/1     1            1           22h

# ide-operator-controller-manager 실행 확인
```

1. ide-operator-controller-manager가 정상 동작한다면 Operator를 위한 YAML을 작성한다.
2. Sample YAML의 경로와 YAML 구조는 아래와 같다.

```yaml
# operator-sdk init --plugins=helm --domain=org --group=uengine --version=v1alpha1 --kind=Ide
# root기준 ./config/samples/demo_v1_ide.yaml

apiVersion: uengine.org/v1alpha1 # --domain=org --group=uengine --version=v1alpha1 를 기준으로 생성
kind: Ide # --kind=Ide 를 기준으로 생성
metadata:
  name: ide-sample 
spec:
  # Spec 부분의 값이 Helm의 values.yaml에 매핑된다.
  hashName: ""
  userId: ""
  templateFile: ""
  image: ""
  tenant: ""
  course: ""
```

## Test YAML 실행

```bash
$ ide-operator kubectl apply -f ./config/samples/uengine_v1alpha1_ide.yaml
```

## 배포 상태 확인

1. Helm에 작성된 객체가 정상적으로 확인을 하면된다.
2. 추가적으로 `kubectl describe ide labs--680760739`를 입력했을때, 만약 배포에 성공했을경우에는 Status에 아래와 같은 내용이 나오고,

```
Status:
  Conditions:
    Last Transition Time:  2021-01-07T04:29:16Z
    Status:                True
    Type:                  Initialized
    Last Transition Time:  2021-01-07T04:29:19Z
    Reason:                InstallSuccessful # 인스톨 완료
    Status:                True
    Type:                  Deployed
  Deployed Release:
    Manifest:  ---
...
```

에러가 났을 경우에는 Status에 에러의 원인이 Message쪽에 작성되어 있다.

```
Status:
  Conditions:
    Last Transition Time:  2021-01-07T04:02:48Z
    Status:                True
    Type:                  Initialized
    Last Transition Time:  2021-01-07T04:02:51Z
    Message:               failed to install release: rendered manifests contain a resource that already exists. Unable to continue with install: Namespace "labs--680760739" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "labs--680760739"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "default"
    Reason:                InstallError # 인스톨 실패
    Status:                True
    Type:                  ReleaseFailed
Events:                    <none>
```

## 에러 확인 관련

에러메시지는 아래와 같이 출력되는데 아래의 메시지를 나열하면

```
# 수정 전

    Message:               failed to install release: rendered manifests contain a resource that already exists. Unable to continue with install: Namespace "labs--680760739" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "labs--680760739"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "default"
```

```
# 수정 후

    Message:               
    failed to install release: rendered manifests contain a resource that already exists. 
    Unable to continue with install: Namespace "labs--680760739" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; 

    label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; 
    annotation validation error: missing key "meta.helm.sh/release-name": must be set to "labs--680760739"; 
    annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "default"
```

아래와 같이 콜론을 기준으로 나누면 각 에러의 원인을 찾기 쉬워진다.

위의 에러같은경우는 labs--680760739 Namespace 가 이미 존재하므로 발생한 에러이므로 `kubectl delete ns labs--680760739`를 해준 후, 다시 실행시켜주면 된다.

## RestAPI 관련

api서버에 연결되어있는경우 `/apis/uengine.org/v1alpha1`로 호출하면 된다.

```json
{
    "kind": "APIResourceList", 
    "apiVersion": "v1", 
    "groupVersion": "uengine.org/v1alpha1",
    "resources":[
        {
            "name": "ides",
            "singularName": "ide",
            "namespaced": true,
            "kind": "Ide",
            "verbs": ["delete", "deletecollection", "get", "list", "patch", "create", "update", "watch"],
            "storageVersionHash": "mU7IaACBIec="
        }, 
        {
            "name": "ides/status",
            "singularName": "",
            "namespaced": true,
            "kind": "Ide",
            "verbs": ["get", "patch", "update"]
        }
    ]
}
```

API관련 선언부분은 `ide_editor_role.yaml`, `ide_viewer_role.yaml`, `role.yaml` 에서 수정하면 된다.