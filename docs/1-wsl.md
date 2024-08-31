
Step 1: Install Ubuntu

Install Ubuntu using the default command:

```
wsl --install -d Ubuntu
```

Step 2: Export the Installed Distribution

Once installed, you can export the distribution to a tar file:

```
wsl --export Ubuntu C:\<path>\ubuntu.tar
```

Step 3: Unregister the Default Installation
After exporting, you can remove the default installation:
```
wsl --unregister Ubuntu
```


Step 4: Import the Distribution with a Custom Name and Location
Now, import the tarball you exported earlier to the desired location on your D drive and give it the name "tibia":

bash
```
wsl --import tibia C:\<path>\ubuntu.tar C:\<path>\ubuntu.tar --version 2
```

Step 5: Launch Your WSL Instance
You can now start the WSL instance with the custom name "tibia":
```
wsl -d tibia
```

-----------

**TODO: Don't use default 'id_rsa'**

Follow:
https://arnoldgalovics.com/oracle-cloud-kubernetes-terraform/


Install OCI CLI (for your WSL Linux distro):

Firstly, ensure you navigate to the home directory:
```
cd $HOME
```

Then follow the installation instructions in each of the following:

https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix

Install Terraform:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Install Kubectl:
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/


NOTE: You can use this command to copy the file contents of the public key from WSL to your windows clipboard:
```
cat /root/.oci/oci_api_key_public.pem | clip.exe
```

-----

Double check after you've done this that `nano ~/.oci/config` similar to:

[DEFAULT]
user=xxxxx
fingerprint=xxxxx
tenancy=xxxxx
region=xxxxx
key_file=/root/.oci/oci_api_key.pem

