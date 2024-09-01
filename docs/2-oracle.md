https://signup.cloud.oracle.com/?intcmp=OcomFreeTierPromoBanner&language=en_US

----

Terraform OCI user creation (Optional)

Is always recommended to create a separate user and group in your preferred domain to use with Terraform. This user must have less privileges possible (Zero trust policy). Below is an example policy that you can create allow terraform-group to manage all the resources needed by this module:

Allow group terraform-group to manage virtual-network-family  in compartment id <compartment_ocid>
Allow group terraform-group to manage instance-family  in compartment id <compartment_ocid>
Allow group terraform-group to manage compute-management-family  in compartment id <compartment_ocid>
Allow group terraform-group to manage volume-family  in compartment id <compartment_ocid>
Allow group terraform-group to manage load-balancers  in compartment id <compartment_ocid>
Allow group terraform-group to manage network-load-balancers  in compartment id <compartment_ocid>
Allow group terraform-group to manage dynamic-groups in compartment id <compartment_ocid>
Allow group terraform-group to manage policies in compartment id <compartment_ocid>
Allow group terraform-group to read network-load-balancers  in compartment id <compartment_ocid>
Allow group terraform-group to manage dynamic-groups in tenancy

See how to find the compartment ocid. The user and the group have to be manually created before using this module. To create the user go to Identity & Security -> Users, then create the group in Identity & Security -> Groups and associate the newly created user to the group. The last step is to create the policy in Identity & Security -> Policies.


----

Here’s a summary of the Always Free resources available in Oracle Cloud Infrastructure (OCI):

Compute:
    Up to two Always Free VM instances with VM.Standard.E2.1.Micro (AMD processor) shape.
    3,000 OCPU hours and 18,000 GB hours per month for VM.Standard.A1.Flex (Arm processor) instances.
    Multiple combinations possible with up to 200 GB of Always Free block volume storage.
    Instances may be reclaimed if idle (low CPU, network, memory usage).

Block Volume:
    200 GB of Always Free Block Volume storage, including five volume backups.
    Always Free volumes must be created in the tenancy’s home region.

Object and Archive Storage:
    20 GB of Always Free Object Storage.

Vault:
    Free master encryption keys protected by software.
    20 key versions with HSM and 150 Always Free Vault secrets.

Resource Manager:
    Resources to automate infrastructure provisioning using Terraform.

Database:
    Two Always Free Oracle Autonomous Databases for various application development purposes.
    Oracle NoSQL Database with generous read/write allowances.
    Oracle HeatWave DB system with 50 GB storage.

Networking:
    Up to 50 Always Free cluster placement groups.
    One Always Free Flexible Load Balancer with 10 Mbps bandwidth.
    One Always Free Network Load Balancer.
    Up to 2 Virtual Cloud Networks (VCNs) per Free Tier tenancy.