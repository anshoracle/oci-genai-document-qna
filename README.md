# oci-tf-document-qna

Terraform scripts to deploy in OCI a document Q&amp;A app with langchain framework, Opensearch as vector store and Cohere AI as the LLM.

The app have endpoints to call REST services or you can use the gradio interface with the same functionality. 

## Requirements
- Terraform
- ssh-keygen

## Configuration

1. Follow the instructions to add the authentication to your tenant https://medium.com/@carlgira/install-oci-cli-and-configure-a-default-profile-802cc61abd4f.
2. Clone this repository:
    ```bash
    git clone https://github.com/anshoracle/oci-genai-document-qna
    ```

3. Set three variables in your path. 
- The tenancy OCID, 
- The comparment OCID where the instance will be created.
- A cohere token.
- The "Region Identifier" of region of your tenancy.
> **Note**: [More info on the list of available regions here.](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)

```bash
    export TF_VAR_tenancy_ocid='<tenancy-ocid>'
    export TF_VAR_compartment_ocid='<comparment-ocid>'
    export TF_VAR_cohere_token='<cohere-token>'
    export TF_VAR_region='<oci-region>'
```

4. If you're using a Linux OS, you may need to execute the following command to obtain execution permissions on the shell script:
```bash
    chmod a+x generate-keys.sh
```
5. Execute the script generate-keys.sh to generate private key to access the instance. 
```bash
    sh generate-keys.sh
```

## Build

To build the terraform solution, simply execute: 

```bash
    terraform init
    terraform plan
    terraform apply
```

## Test
Create a tunel to the machine like this.
```bash
ssh -i server.key -L 7860:localhost:7860 opc@<ip-address>
```


## Acknowledgements

* **Author** - [Carlos Giraldo](https://www.linkedin.com/in/carlos-giraldo-a79b073b/), Oracle
* **Author** - [Anshuman Panda](https://www.linkedin.com/in/ansh-panda/), Oracle
* **Last Updated Date** - September 26th, 2023
