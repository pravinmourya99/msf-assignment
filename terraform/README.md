# Terraform: Multi-Compartment AWS Architecture

This directory contains Terraform code to build the **multi-compartment AWS architecture** from the design diagram: Internet compartment, GEN compartment, Workload compartments (X, Y, Z), Transit Gateway, and PrivateLink for system-to-system API consumption and exposure.

Any developer can run this in **any AWS account and region** by changing only configuration (Option A: Terraform variables + `.tfvars`).

---

## Table of contents

1. [Architecture overview](#1-architecture-overview)
2. [Repository layout](#2-repository-layout)
3. [Prerequisites](#3-prerequisites)
4. [Configuration (run in any account)](#4-configuration-run-in-any-account)
5. [Step-by-step: first run](#5-step-by-step-first-run)
6. [Step-by-step: apply and verify](#6-step-by-step-apply-and-verify)
7. [Adding environments (e.g. staging, prod)](#7-adding-environments-eg-staging-prod)
8. [Naming conventions](#8-naming-conventions)
9. [Module reference](#9-module-reference)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Architecture overview

The design includes:

| Component | Terraform mapping |
|-----------|-------------------|
| **Internet Compartment** | VPC with subnets: `public`, `firewall`, `interfacing`. IGW, optional NAT, TGW attachment. |
| **GEN Compartment** | VPC with `public`, `interfacing` subnets. IGW, optional NAT, TGW attachment. |
| **Workload X / Y / Z** | VPCs with `web` (X only), `compute`, `data` (X only), `interfacing`. TGW attachment. |
| **Transit Gateway (TGW)** | Central hub; all compartments attach via `interfacing` subnets. |
| **TGW routing** | Routes from each compartment’s private route tables to other VPC CIDRs via TGW. |
| **PrivateLink producer** | NLB + VPC Endpoint Service (e.g. Workload Z exposes an API). |
| **PrivateLink consumer** | Interface VPC Endpoint in a compartment (e.g. Workload Y consumes Z’s API). |

Traffic flow:

- **Public / GEN** → Internet or GEN VPC → (optional firewall) → TGW → Workload VPCs.
- **Workload-to-workload** → TGW or PrivateLink (consumer → producer endpoint).

---

## 2. Repository layout

```
terraform/
├── README.md                    # This file
├── environments/
│   └── dev/
│       ├── main.tf               # Root: TGW, VPCs, attachments, routes, PrivateLink
│       ├── variables.tf          # Variable definitions
│       ├── outputs.tf           # Outputs (VPC IDs, TGW ID, service names, etc.)
│       ├── locals.tf             # name_prefix, common_tags
│       ├── provider.tf           # AWS provider
│       ├── versions.tf           # Terraform & provider constraints
│       ├── backend.tf.example    # Example S3 backend (copy to backend.tf)
│       └── dev.tfvars            # Dev config (compartments, CIDRs, PrivateLink)
└── modules/
    ├── transit-gateway/          # Single TGW
    ├── vpc-compartment/          # One VPC + subnets, IGW, NAT, route tables, SGs
    ├── tgw-attachment/           # TGW VPC attachment (interfacing subnets)
    ├── private-link-consumer/    # Interface VPC endpoint (consume an API)
    └── private-link-producer/    # NLB + VPC Endpoint Service (expose an API)
```

---

## 3. Prerequisites

- **Terraform** ≥ 1.5.
- **AWS CLI** configured (or env vars `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`) for the account/region you want to use.
- Sufficient **IAM permissions** in that account for: VPC, Subnets, Internet Gateway, NAT Gateway, Transit Gateway, EC2 (route tables, security groups), Elastic Load Balancing (NLB), VPC Endpoints.

---

## 4. Configuration (run in any account)

All environment- and account-specific values are in **variables** and **`.tfvars`**. To run in another AWS account or region:

1. **Region / project / environment**  
   In the environment’s `.tfvars` (e.g. `environments/dev/dev.tfvars`), set:
   - `aws_region` (e.g. `us-east-1`, `ap-south-1`)
   - `project`
   - `environment`

2. **CIDRs**  
   Ensure VPC CIDRs in `compartments` don’t overlap with existing networks in that account (or on-prem).

3. **Availability zones**  
   Set `availability_zone` in each subnet to valid AZs for the chosen region (e.g. `ap-south-1a`, `ap-south-1b`).

4. **Backend (recommended)**  
   Copy `backend.tf.example` to `backend.tf` and set S3 bucket, key, and optional DynamoDB table for the target account.

No code changes are required; only configuration.

---

## 5. Step-by-step: first run

### 5.1 Use the dev environment

All commands are run from the **environment** directory (e.g. `dev`):

```bash
cd terraform/environments/dev
```

### 5.2 Configure backend (optional but recommended)

```bash
cp backend.tf.example backend.tf
# Edit backend.tf: set bucket, key, region, and optionally dynamodb_table for locking
```

### 5.3 Set your config

- **Quick test in default region:**  
  Ensure `dev.tfvars` has the correct `aws_region` and AZs for your account.

- **Different account/region:**  
  Change in `dev.tfvars`:
  - `project`, `environment`, `aws_region`
  - Every subnet’s `availability_zone` to match that region (e.g. `us-east-1a`, `us-east-1b`).
  - VPC CIDRs in `compartments` if needed to avoid overlap.

### 5.4 Initialize Terraform

```bash
terraform init
```

If you added `backend.tf`, use:

```bash
terraform init -reconfigure
```

### 5.5 Plan

```bash
terraform plan -var-file=dev.tfvars -out=tfplan
```

Review the plan: new TGW, VPCs, subnets, route tables, NAT gateways (where enabled), TGW attachments, routes to TGW, and optionally PrivateLink producer/consumer.

### 5.6 Apply

```bash
terraform apply tfplan
```

Or:

```bash
terraform apply -var-file=dev.tfvars
```

---

## 6. Step-by-step: apply and verify

### 6.1 After apply

- **Outputs** (e.g. `terraform output`):
  - `transit_gateway_id`, `vpc_compartment_ids`, `tgw_attachment_ids`
  - `privatelink_producer_service_names` (for consumers)
  - `subnet_ids_by_compartment`

### 6.2 Verify connectivity (conceptual)

- From a host in a workload VPC (e.g. Workload X), ensure you have a route to other compartment CIDRs (e.g. 10.0.0.0/16, 10.1.0.0/16) via the TGW (check route tables and security groups).
- For PrivateLink: from a host in the consumer compartment (e.g. Workload Y), resolve the endpoint’s DNS and connect to the producer (e.g. Workload Z) on the configured port (e.g. 443).

### 6.3 Cost notes

- NAT Gateways and Transit Gateway attachments incur cost. In dev, `single_nat_gateway = true` and fewer NATs are used.
- Destroy when not needed: `terraform destroy -var-file=dev.tfvars`.

---

## 7. Adding environments (e.g. staging, prod)

1. Copy the `dev` environment:

   ```bash
   cp -r terraform/environments/dev terraform/environments/staging
   ```

2. In the new folder:
   - Rename or add `staging.tfvars` with `environment = "staging"`, production-ready CIDRs, and AZs.
   - Optionally use a different backend key (e.g. `key = "msf-assignment/staging/terraform.tfstate"`).

3. Run from the new directory:

   ```bash
   cd terraform/environments/staging
   terraform init -reconfigure
   terraform plan -var-file=staging.tfvars
   terraform apply -var-file=staging.tfvars
   ```

---

## 8. Naming conventions

Resources follow a consistent pattern:

- **Prefix:** `{project}-{environment}` (e.g. `msf-dev`).
- **VPC:** `{prefix}-{compartment}-vpc` (e.g. `msf-dev-internet-vpc`).
- **Subnets:** `{prefix}-{compartment}-subnet-{type}` (e.g. `msf-dev-internet-subnet-firewall`).
- **TGW:** `{prefix}-tgw`.
- **TGW attachment:** `{prefix}-tgw-attach-{compartment}`.
- **Security groups:** `{prefix}-{compartment}-sg-{type}`.

All resources are tagged with `Project`, `Environment`, `Compartment` (where applicable), and `ManagedBy = "terraform"`.

---

## 9. Module reference

| Module | Purpose | Key inputs |
|--------|--------|------------|
| **transit-gateway** | Create one Transit Gateway | `name_prefix`, optional default route table behaviour |
| **vpc-compartment** | One VPC + subnets, IGW, NAT, route tables, SGs | `compartment_name`, `vpc_cidr`, `subnets`, `enable_internet_gateway`, `enable_nat_gateway`, `single_nat_gateway`, `enable_security_groups` |
| **tgw-attachment** | Attach one VPC to TGW | `transit_gateway_id`, `vpc_id`, `subnet_ids` (interfacing) |
| **private-link-producer** | NLB + VPC Endpoint Service | `vpc_id`, `subnet_ids`, `allowed_principals`, optional `existing_nlb_arn` |
| **private-link-consumer** | Interface VPC Endpoint | `vpc_id`, `subnet_ids`, `service_name`, optional `security_group_ids` |

Root `main.tf` in `environments/dev`:

- Creates one TGW.
- Creates one VPC per entry in `var.compartments`.
- Creates one TGW attachment per compartment that has `interfacing` subnets.
- Adds routes in each compartment’s private route tables to CIDRs in `var.tgw_routes` via the TGW.
- Creates PrivateLink producers and consumers from `var.privatelink_producers` and `var.privatelink_consumers`.

---

## 10. Troubleshooting

- **“Invalid subnet” or “subnet not found”**  
  Ensure subnet `availability_zone` in your `.tfvars` matches the selected `aws_region` (e.g. `ap-south-1a` for `ap-south-1`).

- **TGW route not working**  
  Check that `tgw_routes` includes the destination VPC CIDR for the compartment you’re routing from, and that the TGW attachment exists and is associated with the correct TGW route table.

- **PrivateLink consumer cannot connect**  
  Ensure the consumer’s `service_name` matches the producer’s (or use `producer_compartment` in `privatelink_consumers`). Check security groups on both endpoint and producer NLB/targets.

- **NAT / IGW not created**  
  Compartments need at least one `public` subnet and `enable_internet_gateway` / `enable_nat_gateway` set to `true` in `compartments` in your `.tfvars`.

---

## Summary

- **Config-only portability:** Change `project`, `environment`, `aws_region`, AZs, and CIDRs in `.tfvars` (and backend) to run in any account/region.
- **Diagram alignment:** Internet, GEN, Workload X/Y/Z, TGW, and PrivateLink consumer/producer are implemented as described above.
- **Optional pieces:** Security groups per subnet role, NAT gateway, and PrivateLink are enabled via variables; disable or adjust in your `.tfvars` as needed.
