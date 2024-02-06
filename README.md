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



