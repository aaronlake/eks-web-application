## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.17.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.11.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.23.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.17.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | 5.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.23.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common variables for all modules | `map(string)` | n/a | yes |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | Version of MongoDB to install | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_creation_date"></a> [ami\_creation\_date](#output\_ami\_creation\_date) | Old Ubuntu AMI creation date |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | Old Ubuntu AMI ID |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | MongoDB instance ID |
| <a name="output_mongodb_connection_string"></a> [mongodb\_connection\_string](#output\_mongodb\_connection\_string) | MongoDB connection string |
| <a name="output_mongodb_password"></a> [mongodb\_password](#output\_mongodb\_password) | MongoDB password |
| <a name="output_ssh_key_filename"></a> [ssh\_key\_filename](#output\_ssh\_key\_filename) | MongoDB SSH command |
