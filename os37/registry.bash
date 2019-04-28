oadm registry --config=/etc/origin/master/admin.kubeconfig --images=p31arm64v8/origin-dockerregistry:v3.7.1 --mount-host=/mnt/data

oc volume deploymentconfigs/docker-registry --add --name=registry-storage -t pvc --claim-name=aws-ebs-pvc --overwrite
