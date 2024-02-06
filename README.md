Terraform tracks the state in which it makes changes to your infrastructure in a state file. You’ll want to go into the examples directory, and initialize Terraform with init. This will initialize Terraform, creating the state file to track our work:

cd eks-getting-started

terraform init


Now, to see a detailed outline of the changes Terraform would make, run plan. This should include the EKS cluster, VPC, and other AWS resources that will be facilitated in this project:

terraform plan

Make sure to review the changes. The plan command will additionally warn you if there are any errors in your Terraform code. Assuming everything looks alright, since this is a fresh checkout, you should be able to apply the default configuration using the apply:

terraform apply

Terraform will prompt you to make sure that you want to apply the changes, since this will create resources that will incur charges on our AWS account. You’ll want to go ahead and apply the changes since you already reviewed them with the plan command previously:

Do you want to perform these actions?

Terraform will perform the actions described above.

Only 'yes' will be accepted to approve.

Enter a value: yes

By default, the resources are targeted to be created in us-east-1, so bear that in mind if you go looking for the resources created in your console. This apply step will create many of the resources you need to get up and running initially, including:

•	VPC

•	IAM roles

•	Security groups

•	An internet gateway

•	Subnets

•	Autoscaling group

•	Route table

•	EKS cluster

•	Your kubectl configuration



Setting Up kubectl

You will need the configuration output from Terraform in order to use kubectl to interact with your new cluster. Create your kube configuration directory, and output the configuration from Terraform into the config file using the Terraform output command:

mkdir ~/.kube/

terraform output kubeconfig>~/.kube/config

You’ll need kubectl, a command line tool to run commands against Kubernetes clusters, for the next step. Installation instructions can be found here. Once you’ve got this installed, you’ll want to check to make sure that you’re connected to your cluster by running kubectl version. Your output may vary slightly here:

$ kubectl version

Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.1", GitCommit:"4ed3216f3ec431b140b1d899130a69fc671678f4", GitTreeState:"clean", BuildDate:"2018-10-05T16:46:06Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"12+", GitVersion:"v1.12.6-eks-d69f1b", GitCommit:"d69f1bf3669bf00b7f4a758e978e0e7a1e3a68f7", GitTreeState:"clean", BuildDate:"2019-02-28T20:26:10Z", GoVersion:"go1.10.8", Compiler:"gc", Platform:"linux/amd64"}

Now let’s add the ConfigMap to the cluster from Terraform as well. The ConfigMap is a Kubernetes configuration, in this case for granting access to our EKS cluster. This ConfigMap allows our ec2 instances in the cluster to communicate with the EKS master, as well as allowing our user account access to run commands against the cluster. You’ll run the Terraform output command to a file, and the kubectl apply command to apply that file:

terraform output config_map_aws_auth > configmap.yml

kubectl apply -f configmap.yml

Once this is complete, you should see your nodes from your autoscaling group either starting to join or joined to the cluster. Once the second column reads Ready the node can have deployments pushed to it. Again, your output may vary here:

$ kubectl get nodes -o wide


NAME STATUS ROLES AGE VERSION INTERNAL-IP EXTERNAL-IP OS-IMAGE KERNEL-VERSION CONTAINER-RUNTIME

ip-10-0-0-193.us-west-2.compute.internal Ready 83s v1.12.7 10.0.0.193 18.236.129.186 Amazon Linux 2 4.14.106-97.85.amzn2.x86_64 docker://18.6.1

ip-10-0-1-237.us-west-2.compute.internal Ready 83s v1.12.7 10.0.1.237 34.222.17.198 Amazon Linux 2 4.14.106-97.85.amzn2.x86_64 docker://18.6.1

At this point, your EKS cluster is up, the nodes have joined, and they are ready for a deployment!


Helm
Next, you’ll install Helm. First you need to create a Kubernetes ServiceAccount for tiller, which allows helm to talk to the cluster:

cat >tiller-user.yaml

apiVersion: v1

kind: ServiceAccount

metadata:

  name: tiller
  
  namespace: kube-system

---

apiVersion: rbac.authorization.k8s.io/v1

kind: ClusterRoleBinding

metadata:

  name: tiller

roleRef:

  apiGroup: rbac.authorization.k8s.io
  
  kind: ClusterRole
  
  name: cluster-admin

subjects:

- kind: ServiceAccount

  name: tiller

Now, you apply the ServiceAccount with kubectl, and install helm with the init command:


$ kubectl apply -f tiller-user.yaml

$ helm init --service-account tiller

You will need a way for our Airflow deployment to communicate with the outside world. For this, you will install nginx-ingress, an ingress controller that uses ConfigMap to store nginx configurations. 

Nginx is an industry standard software for web and proxy servers. We will use the proxy feature to serve up our Airflow web interface. Install nginx-ingress via the helm 

chart:

helm install \

stable/nginx-ingress \

--name my-nginx \

--set rbac.create=true
