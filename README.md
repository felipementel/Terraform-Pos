# Principais comandos

````
https://registry.terraform.io/providers/Azure/azapi/latest
````

- `terraform init` - Inicializa o diretório de trabalho do Terraform, baixando os provedores necessários. Adicione `-upgrade` para atualizar os provedores para a versão mais recente.

- `terraform fmt` - Formata os arquivos de configuração do Terraform para um estilo consistente. Adicione `-recursive` para formatar arquivos em subdiretórios.

- `terraform validate` - Valida a configuração do Terraform, verificando se há erros de sintaxe e consistência.

- `terraform plan` - Mostra o plano de execução, ou seja, as ações que o Terraform irá realizar para atingir o estado desejado. Adicione `-out="plan.tfplan"` para salvar o plano em um arquivo para revisão ou aplicação posterior. Adicione `-var-file="credential.tfvars"` para usar um arquivo de variáveis, como credenciais de autenticação.

- `terraform apply` - Aplica as mudanças necessárias para alcançar o estado desejado, criando, modificando ou destruindo recursos conforme necessário.

- `terraform destroy` - Destroi os recursos gerenciados pelo Terraform, revertendo as mudanças feitas.

- `terraform show` - Exibe o estado atual dos recursos gerenciados pelo Terraform.

- `terraform state list` - Lista os recursos atualmente gerenciados pelo Terraform.


# Principais parâmetros

- `-upgrade` - Atualiza os provedores para a versão mais recente disponível.

- `-var-file="credential.tfvars"` - Especifica um arquivo de variáveis para fornecer valores de configuração, como credenciais de autenticação.

- `-auto-approve` - Aplica as mudanças sem solicitar confirmação, útil para automação.

- `-out="plan.tfplan"` - Salva o plano de execução em um arquivo para revisão ou aplicação posterior.

- `-chdir="path/to/directory"` - Especifica um diretório de trabalho diferente para os arquivos de configuração do Terraform.

# Workspace

- `terraform workspace new <nome>` - Cria um novo workspace com o nome especificado.

- `terraform workspace select <nome>` - Seleciona um workspace existente para uso.

- `terraform workspace list` - Lista todos os workspaces disponíveis.

- `terraform workspace show` - Mostra o workspace atualmente selecionado.


# Comandos

terraform -chdir="IaC" workspace

terraform -chdir="IaC" workspace new dev
                                       select dev

terraform -chdir="IaC" init
                       init -upgrade

terraform -chdir="IaC" fmt -recursive

terraform -chdir="IaC" validate

terraform -chdir="IaC" plan  `
-var-file="credential.tfvars" `
-var-file="environments/dev.tfvars"

terraform -chdir="IaC" apply `
-var-file="credential.tfvars" `
-var-file="environments/dev.tfvars" `
-auto-approve

terraform -chdir="IaC" destroy `
-var-file="credential.tfvars" `
-var-file="environments/dev.tfvars"

terraform -chdir="IaC" output -raw sql_password
