
1. Prepare the resource group, network and base resources
    ```shell
    terraform init
    terraform apply
    ```
2. Set the content of the `packer.pkrvars.hcl` file to the value of the `packer_pkrvars` output from the previous step.
   ```shell
   terraform output -raw packer_pkrvars > packer.pkrvars.hcl
   ```

3. Build the image
    ```shell
    git clone git@github.com:widespot/packer-azure-debian-builder.git
    packer build -var-file=packer.pkrvars.hcl ./packer-azure-debian-builder
    ```

4. and execute
    ```shell
    terraform apply -var vm_image_name="test-runner-vmimg"
    # TODO
    #terraform apply -var vm_image_name="$(terraform output -raw vm_image_name)"
    ```
