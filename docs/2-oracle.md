https://signup.cloud.oracle.com/?intcmp=OcomFreeTierPromoBanner&language=en_US

* once you get the account, follow the *Before you begin* and *Prepare* steps in [this](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm) document.

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
