**Terraform Guide**

- **Intro & Install**
  - Terraform is an IaC tool that turns declarative configs into real cloud infrastructure.
  - Install: download from HashiCorp, add to PATH; or `brew install terraform` (macOS); verify with `terraform version`.
  - Typical repo layout: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `modules/`, `env/`, `.terraform.lock.hcl`.

- **Core Concepts**
  - Providers: plugins that talk to APIs (e.g., `aws`, `azurerm`, `google`); declared with version constraints and auth settings.
  - Resources: concrete objects to manage (e.g., `aws_s3_bucket`, `aws_instance`).
  - Data sources: read-only lookups of existing objects.
  - Variables: inputs that parameterize configs; can have type, default, validation.
  - Outputs: surfaced values after `apply`, often fed to other systems.
  - State: tracks real-world objects ↔ config; stored in `terraform.tfstate`.

- **HCL & Basic Syntax**
  ```hcl
  # providers.tf
  terraform {
    required_version = ">= 1.6"
    required_providers {
      aws = { source = "hashicorp/aws", version = "~> 5.0" }
    }
  }

  provider "aws" {
    region = var.region
  }

  # main.tf
  resource "aws_s3_bucket" "logs" {
    bucket = "${var.project}-logs"
    tags   = { env = var.env }
  }

  # variables.tf
  variable "region" { type = string }
  variable "project" { type = string }
  variable "env" {
    type = string
    default = "dev"
    validation {
      condition = contains(["dev", "staging", "prod"], var.env)
      error_message = "Environment must be one of: dev, staging, prod."
    }
  }

  # outputs.tf
  output "log_bucket" { value = aws_s3_bucket.logs.bucket }
  ```
  - Interpolation: `${}` is only needed when embedding values **inside strings**. For standalone references, use bare identifiers: `bucket = var.project` (not `bucket = "${var.project}"`).
  - Conditionals: `condition ? a : b`; loops: `for` expressions; maps/lists with `[]` and `{}`.

- **Resource Management & Dependencies**
  - Implicit deps: created by referencing attributes (e.g., `bucket = aws_s3_bucket.logs.id`).
  - Explicit deps: `depends_on = [aws_iam_role.example]` when no attribute reference exists.
  - Lifecycle: `create_before_destroy`, `prevent_destroy`, `ignore_changes` under `lifecycle {}`.
  - Count/for_each: `count` for indexed lists; `for_each` for maps/sets for stable addressing.

- **Variables & Outputs Best Practices**
  - Type everything (`string`, `number`, `bool`, `list(object({...}))`); add `nullable = false` when needed.
  - Supply defaults only when sensible; use validation blocks for constraints.
  - Avoid secrets in `default`; prefer env vars or TFVARS.
  - Use descriptive output names; mark sensitive data with `sensitive = true`.
  - Keep a sample `terraform.tfvars.example` for onboarding.

- **State Management & Backends**
  - Local state (`terraform.tfstate`) is fine for learning; not for teams.
  - Remote backends: S3+DynamoDB (AWS), GCS, Azure Blob, Terraform Cloud. Example (S3 with security):
    ```hcl
    terraform {
      backend "s3" {
        bucket         = "my-tf-state"
        key            = "vpc/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "tf-state-locks"
        encrypt        = true

        # Additional security options
        # acl            = "private"  # Explicitly private
        # kms_key_id    = "arn:aws:kms:us-east-1:123456789012:key/xxxxx"  # Custom KMS key
      }
    }
    ```
    - The state bucket should have:
      - Versioning enabled
      - Server-side encryption (SSE-KMS recommended)
      - Public access blocked
      - MFA Delete for additional security
      - TLS-only access policy
    - DynamoDB table should enable point-in-time recovery for backup
  - Enable locking (DynamoDB) to prevent concurrent writes; enable server-side encryption.
  - Use `terraform state show/mv/rm` cautiously; prefer config changes then `apply`.

- **Modules & Reusability**
  - Modules = directories with `.tf` files; root module is current dir.
  - Call a module:
    ```hcl
    module "network" {
      source = "./modules/vpc"
      cidr_block = "10.0.0.0/16"
      env  = var.env
    }
    ```
  - Publish reusable modules via Git, registry, or local paths; pin versions (`?ref=v1.2.0`).
  - Expose inputs/outputs; keep interfaces narrow; add README and examples.

- **Workspaces & Environments**
  - Workspaces give multiple state files per config: `terraform workspace new staging`; `terraform workspace select prod`.
  - Good for simple env splits; for complex needs, prefer separate backends or folders (e.g., `env/dev`, `env/prod`) to isolate blast radius.

- **Common Commands**
  - `terraform init` (downloads providers/backends and modules).
  - `terraform fmt` (format), `terraform validate` (static checks).
  - `terraform plan` (shows changes; use `-var-file` and `-out planfile`).
  - `terraform apply planfile` (executes); `terraform destroy` (teardown).
  - `terraform show` (state/plan view), `terraform graph` (dep graph).

- **Resource Refactoring (Terraform 1.1+)**
  - Use `moved` blocks to rename resources without recreation:
    ```hcl
    # Renamed resource without destroying/recreating
    moved {
      from = aws_instance.old_name
      to   = aws_instance.new_name
    }
    ```
  - Use `removed` blocks (Terraform 1.7+) to remove resources from state without destroying:
    ```hcl
    # Remove from state but keep infrastructure
    removed {
      from = aws_instance.deprecated
    }
    ```

- **Testing (Terraform 1.6+)**
  - Use native `terraform test` command to validate configurations:
    ```hcl
    # test/integration.tftest.hcl
    variables {
      env = "test"
      project = "test-project"
    }

    run "validate_bucket_exists" {
      command = plan

      assert {
        condition     = aws_s3_bucket.logs.bucket != ""
        error_message = "Bucket must exist"
      }
    }
    ```
  - Run tests: `terraform test` - executes all `*.tftest.hcl` files
  - Tests support `plan` and `apply` commands with assertions on expected state

- **Post-Deployment Validation (Terraform 1.5+)**
  - Use `check` blocks to validate infrastructure after creation:
    ```hcl
    check "endpoint_health" {
      assert {
        condition     = can(lookup(data.http.health_check, "status_code"))
        error_message = "Endpoint is not responding"
      }
    }

    data "http" "health_check" {
      url = "https://${aws_lb.main.dns_name}/health"
    }
    ```

- **Security Best Practices**
  - Store state in encrypted, access-controlled buckets; enable versioning.
  - Never commit `terraform.tfstate`, `.terraform/`, or real `*.tfvars`; use `.gitignore`.
  - Least-privilege IAM for Terraform runner; short-lived creds; prefer OIDC where possible.
  - Mark outputs/vars as `sensitive`; avoid logging secrets.
  - Validate external data; restrict provisioners; avoid `local-exec`/`remote-exec` unless necessary.
  - **Automated Security Scanning**: Use tools to catch misconfigurations:
    - `tfsec` or `trivy` for static analysis of Terraform files
    - `checkov` (Prisma Cloud) for comprehensive policy checks
    - Run in CI/CD before `terraform apply` to prevent insecure configurations
  - **CI/CD Integration**: Use HashiCorp Terraform Cloud/Enterprise or GitHub Actions:
    ```yaml
    # .github/workflows/terraform.yml
    name: Terraform

    on:
      push:
        branches: [main]
      pull_request:

    jobs:
      terraform:
        runs-on: ubuntu-latest
        permissions:
          id-token: write  # For AWS OIDC authentication
          contents: read

        steps:
          - uses: actions/checkout@v4

          - name: Setup Terraform
            uses: hashicorp/setup-terraform@v3
            with:
              terraform_version: 1.6

          - name: Configure AWS Credentials
            uses: aws-actions/configure-aws-credentials@v4
            with:
              role-to-assume: arn:aws:iam::123456789012:role/GitHubActionRole
              aws-region: us-east-1

          - name: Terraform Init
            run: terraform init

          - name: Terraform Format Check
            run: terraform fmt -check

          - name: Terraform Validate
            run: terraform validate

          - name: Terraform Plan
            run: terraform plan -out=tfplan

          - name: Terraform Apply
            if: github.ref == 'refs/heads/main'
            run: terraform apply -auto-approve tfplan
    ```

- **Directory Structure (Recommended Layout)**
  ```
  project-root/
  ├── main.tf              # Primary resources
  ├── variables.tf         # Input variables
  ├── outputs.tf           # Output values
  ├── providers.tf         # Provider configuration
  ├── versions.tf          # Terraform & provider versions
  ├── terraform.tfvars     # Environment-specific values (gitignored)
  ├── terraform.tfvars.example  # Template for new users
  ├── modules/             # Reusable modules
  │   └── vpc/
  │       ├── main.tf
  │       ├── variables.tf
  │       └── outputs.tf
  ├── env/                 # Environment-specific configs
  │   ├── dev/
  │   │   ├── main.tf
  │   │   └── terraform.tfvars
  │   └── prod/
  │       ├── main.tf
  │       └── terraform.tfvars
  └── test/                # Integration tests (*.tftest.hcl)
  ```

- **Troubleshooting**
  - "Provider credentials not found": check env vars (`AWS_PROFILE`, `AWS_REGION`) or shared config; run `aws sts get-caller-identity`.
  - "Resource already exists": modern approach uses **import blocks** (Terraform 1.5+):
    ```hcl
    import {
      to = aws_s3_bucket.logs
      id = "my-existing-bucket"
    }

    resource "aws_s3_bucket" "logs" {
      # configuration...
    }
    ```
    Then run `terraform plan` to generate the plan and `terraform apply` to apply.
    - **Auto-generate configs**: Use `-generate-config-out` to create resource configs:
      ```bash
      terraform plan -generate-config-out=generated.tf
      ```
      This creates the resource configuration automatically for imports.
  - "Lock timeout": ensure state lock table reachable; clear stale locks with `terraform force-unlock <id>` (last resort).
  - Drift detected: run `terraform plan` regularly; use `terraform refresh` (deprecated) or `apply` to reconcile.
  - Version mismatch: align Terraform and provider versions; regenerate `.terraform.lock.hcl` with `init -upgrade`.

- **Real-World Examples (AWS)**
  - **VPC (minimal)**
    ```hcl
    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "~> 5.0"
      name    = "demo"
      cidr    = "10.0.0.0/16"
      azs             = ["us-east-1a", "us-east-1b"]
      public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
      enable_nat_gateway = true
    }
    ```
  - **S3 Bucket (Modern v5.0+ syntax)**
    ```hcl
    resource "aws_s3_bucket" "logs" {
      bucket = "demo-logs-${var.env}"
      tags   = { env = var.env, project = var.project }
    }

    # Control object ownership before setting ACL (required for v5+)
    resource "aws_s3_bucket_ownership_controls" "logs" {
      bucket = aws_s3_bucket.logs.id
      rule {
        object_ownership = "BucketOwnerPreferred"
      }
    }

    # Block public access (security best practice)
    resource "aws_s3_bucket_public_access_block" "logs" {
      bucket = aws_s3_bucket.logs.id

      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }

    # ACL - only set if needed, otherwise buckets default to private
    resource "aws_s3_bucket_acl" "logs" {
      depends_on = [
        aws_s3_bucket_ownership_controls.logs,
        aws_s3_bucket_public_access_block.logs
      ]
      bucket = aws_s3_bucket.logs.id
      acl    = "private"
    }

    resource "aws_s3_bucket_versioning" "logs" {
      bucket = aws_s3_bucket.logs.id
      versioning_configuration {
        status = "Enabled"
      }
    }

    resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
      bucket = aws_s3_bucket.logs.id
      rule {
        apply_server_side_encryption_by_default {
          # Use KMS for better security (optional, requires KMS key)
          # sse_algorithm = "aws:kms"
          # kms_master_key_id = aws_kms_key.example.arn
          sse_algorithm = "AES256"  # Default encryption
        }
      }
    }
    ```
  - **EC2 Instance**
    ```hcl
    resource "aws_instance" "web" {
      ami           = data.aws_ami.al2.id
      instance_type = "t3.micro"
      subnet_id     = module.vpc.public_subnets[0]
      vpc_security_group_ids = [aws_security_group.web.id]
      user_data = file("userdata.sh")
      tags = { Name = "demo-web-${var.env}" }
    }

    data "aws_ami" "al2" {
      most_recent = true
      owners      = ["amazon"]
      filter { name = "name", values = ["al2023-ami-*-x86_64"] }
    }
    ```
  - Run flow: `terraform init` → `terraform plan -var-file=env/dev.tfvars` → `terraform apply`.

- **Getting Started Checklist**
  - Install Terraform; configure cloud creds.
  - Set backend (S3/GCS/Azure/TFC) with locking.
  - Create `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`, `.gitignore`.
  - Add env-specific `*.tfvars` and a remote state bucket/table.
  - Run `fmt`, `validate`, `plan`, then `apply`.