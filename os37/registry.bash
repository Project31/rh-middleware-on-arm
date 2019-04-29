oc adm policy add-scc-to-user privileged system:serviceaccount:default:registry

oadm registry --config=/etc/origin/master/admin.kubeconfig --service-account=registry --images=p31arm64v8/origin-dockerregistry:v3.7.1 --mount-host=/mnt/data

