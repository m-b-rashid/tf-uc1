# tf-uc1

Difficulty :  Easy-Intermediate

Estimated Length: 1/2 day

Use case asks for AWS but the solution was done in Azure.

Overview
This usecase covers HashiCorp's Terraform and AWS. 

As a reminder, Terraform is an Infrastructure as Code tool. In other word, once the desired state of the infrastructure has been defined in a terraform file, TF will apply it to the cloud.

Usecase 
You need to build a classic AWS infrastructure with Terraform, in no particular order : 

AWS VPC, Subnet, Internet gateway .   
A load balancer .   
Three EC2 instances, that you would have provisioned with a simple webserver (apache ?) .   
Those machine should be in the VPC/subnet created beforehand     
Those machine need to be reachable via the load balancer.    
Configure Terraform to use Consul as a Remote state.     
Try to use this state from a  different machine, to confirm.    
