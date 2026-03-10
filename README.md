# MSF Assignment – Multi-Compartment AWS Architecture

This repository implements the **multi-compartment AWS architecture** (Internet, GEN, Workload X/Y/Z, Transit Gateway, PrivateLink) using **Terraform**, with config-driven design so any developer can run it in any AWS account by changing only configuration.

## Quick start

1. **Prerequisites:** Terraform ≥ 1.5, AWS CLI (or credentials) for the target account.
2. **Configure:** Edit `terraform/environments/dev/dev.tfvars` and set `project`, `environment`, `aws_region`, and subnet availability zones for your region.
3. **Apply:**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```

## Documentation

- **[terraform/README.md](terraform/README.md)** – Full steps: architecture overview, repository layout, configuration (Option A: Terraform only), first run, apply and verify, adding environments, naming conventions, module reference, and troubleshooting.

## What’s included

- **Transit Gateway** as the central hub.
- **VPC compartments:** Internet (public, firewall, interfacing), GEN (public, interfacing), Workload X (web, compute, data, interfacing), Workload Y/Z (compute, interfacing).
- **TGW attachments** from each compartment’s interfacing subnets.
- **TGW routes** so each compartment can reach other VPC CIDRs via the TGW.
- **Optional NAT Gateway** and **security groups** per subnet role.
- **PrivateLink:** producer (e.g. Workload Z exposes an API) and consumer (e.g. Workload Y consumes it).

All resource names and tags follow a consistent convention; see `terraform/README.md` for details.
