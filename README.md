# "Amazon Web Services 基礎からのネットワーク&サーバー構築 改訂版" を Terraform でやり直す

## 環境
- Terraform v0.12.7

`~/.aws/credentials` に `AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` を書いておく。

[Provider: AWS - Terraform by HashiCorp](https://www.terraform.io/docs/providers/aws/index.html)

```
export AWS_PROFILE=default

ssh-keygen -t rsa
Enter file in which to save the key (/Users/xxxxx/.ssh/id_rsa): /Users/xxxxx/.ssh/terraform_keypair

git clone https://github.com/goropikari/awsbook-terraform.git
cd awsbook-terraform
terraform init
terraform apply
```
