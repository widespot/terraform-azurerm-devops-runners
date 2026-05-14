
1. Prepare the resource group, network and base resources
    ```shell
    terraform init
    terraform apply
    > ...
    > Outputs:
   
    packer_pkrvars = <<EOT
    subscription_id = "f9da3531-9249-48b4-b5e9-707a8f643b40"
    resource_group_name = "test-runner-rg"
    vm_image_name = "test-runner-vmimg"
    EOT
    ```
2. Set the content of the `packer.pkrvars.hcl` file to the value of the `packer_pkrvars` output from the previous step.
   ```shell
   terraform output -raw packer_pkrvars > packer.pkrvars.hcl
   ```

3. Build the image
    ```shell
    packer build -var-file=packer.pkrvars.hcl ../packer
    ```

4. and execute
    ```shell
    terraform apply -var vm_image_name="test-runner-vmimg"
    ```
