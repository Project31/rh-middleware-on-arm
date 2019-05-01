oc delete is prometheus
oc delete serviceaccount syndesis-prometheus
oc delete service syndesis-prometheus
oc delete dc syndesis-prometheus
oc delete cm syndesis-prometheus-config
oc delete pvc syndesis-prometheus
oc delete rolebindings.authorization.openshift.io syndesis:viewers 

oc delete pv pv003
rm -fr /mnt/pv003/*
