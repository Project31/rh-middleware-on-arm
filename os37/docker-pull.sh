docker pull docker.io/p31arm64v8/centos:7.6.1810
docker tag 7a51de8a65d5 docker.io/centos:7
docker pull docker.io/p31arm64v8/origin-release:golang-1.10
docker pull p31arm64v8/origin-source:v3.7.1 
docker tag 2373919a4b9a openshift/origin-source:latest
docker pull p31arm64v8/origin-pod:v3.7.1
docker tag c4f82cd5377d docker.io/openshift/origin-pod:v3.7.1
docker pull p31arm64v8/origin-base:v3.7.1
docker pull p31arm64v8/origin:v3.7.1
docker tag d2219bc79b09 docker.io/openshift/origin:v3.7.1
docker pull p31arm64v8/origin-docker-builder:v3.7.1
docker tag 15b6426779b1 docker.io/openshift/origin-docker-builder:v3.7.1
docker pull p31arm64v8/origin-dockerregistry:v3.7.1
docker pull p31arm64v8/origin-deployer:v3.7.1
docker tag bc23ac58970f docker.io/openshift/origin-deployer:v3.7.1
docker pull p31arm64v8/origin-sti-builder:v3.7.1
docker tag 689a7a8fbbdd openshift/origin-sti-builder:v3.7.1
docker pull p31arm64v8/origin-haproxy-router:v3.7.1
docker tag 03c6bbe67dca openshift/origin-haproxy-router:v3.7.1
docker pull p31arm64v8/postgresql-95-centos7
docker tag 16a2c873d39a docker-registry.default.svc:5000/syndesis/postgresql-on-arm
