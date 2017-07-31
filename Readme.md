# Deploying Domain Controller and Compute Nodes

This document is to show you how to comfigure a template to deploy a domain controller and then follow up provisioning compute nodes which will then join the domain. A user will be created during the process for use.

## Template configuration
### Variables
| softlayer_username | SoftLayer Account Username |
| softlayer_api_key | SoftLayer Account API Key |
| environment_name | Name of the environment (Used for Openwhisk endpoint) |
| base_template_image | Image Template used for Domain Controller |
| computenode_template_image | Image Template used for compute nodes |
| datacenter | SoftLayer Datacenter to provision into |
| domain_exists | Y/N Flag to determine if a Domain Controller already exists |
| domain | The Domain Name to provision |
| domain_username | Username of User Account to create in domain |
| domain_password | User Password for User Account created |
| dc_hostname | Hostname of the Domain Controller |
| cn_hostname | Hostname for compute nodes (appended with a number) |
| domaincontroller_count | Count of domain controller to provision (1 or 0) |
| computenode_count | Count of compute nodes to provision (0-N) |
| domaincontroller_script_url | URL of PS script to download and execute |

## Plan / Apply environment
When starting a new environment, the `domain_exists` paramater should be set to `N`. This allows the Domain Controller to be built, and skips the process of building any compute nodes. A domain controller is required for the compute nodes to provision and join a domain. 


## Call OpenWhisk endpoint to start process of compute nodes
```shell
$ curl http://path-to-openwhisk/report-in
```
