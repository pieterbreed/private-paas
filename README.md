# Application Environment

Provisions a full-featured application environment.

## Features

 - Terraform for resource acquisition. (currently AWS only)
 - Consul for service discovery and failure detection.
 - Vault for sensitive data storage.
 - Nomad for job scheduling.
 
## Extra (app-specific) features

 - ZooKeeper cluster
 - kafka cluster
 
## Planned/future features

 - Centralised logging infrastructure
 - Centralised monitoring infrastructure
 
# How

## Resource Acquisition

 - You need [`terraform`](https://www.terraform.io/) installed and in the path.
 - Go into the `terraform` directory and run `terraform apply`.
 - You might discover some config is needed...

 
