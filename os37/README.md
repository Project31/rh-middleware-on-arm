There is a release candidate for OpenShift 3.7 that can be found at 
https://cbs.centos.org/repos/paas7-openshift-multiarch-candidate/aarch64/os

You will need to add this repo using a Lentos-Origin.repo

```
[openshift]
name=CentOS-$releasever - OpenShift Origin
baseurl=https://cbs.centos.org/repos/paas7-openshift-multiarch-candidate/$basearch/os/
enabled=1
gpgcheck=0

[extras]
name=CentOS-7 - Extras
mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=extras&infra=$infra
#baseurl=http://mirror.centos.org/altarch/7/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7-aarch64
enabled=1

[base]
name=CentOS-7 - Base
mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=os&infra=$infra
#baseurl=http://mirror.centos.org/altarch/$releasever/os/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7-aarch64
```

```
yum-config-manager --enable openshift
yum repolist all
yum install docker 
systemctl enable docker; systemctl start docker
yum install openshift-ansible

yum install origin
yum install origin-sdn-ovs

cat /etc/ansible/hosts

```

```
# bare minimum hostfile
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# add follows to the end
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
# admin user created in previous section
openshift_deployment_type=origin

# localhost likely doesn't meet the minimum requirements
openshift_disable_check=disk_availability,memory_availability,docker_storage

openshift_node_groups=[{'name': 'node-config-all-in-one', 'labels': ['node-role.kubernetes.io/master=true', 'node-role.kubernetes.io/infra=true', 'node-role.kubernetes.io/compute=true']}]


[masters]
localhost ansible_connection=local

[etcd]
localhost ansible_connection=local

[nodes]
# openshift_node_group_name should refer to a dictionary with matching key of name in list openshift_node_groups.
localhost  openshift_node_labels="{'region': 'infra', 'zone': 'default'}" openshift_schedulable=true ansible_connection=local openshift_node_group_name="node-config-all-in-one"
```

```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-etcd/config.yml
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-master/config.yml
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-node/config.yml
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-nfs/config.yml
oadm manage-node  <node-name> --schedulable
```
