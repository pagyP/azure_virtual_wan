## Virtual WAN using Routing Intent Capability

- This template deploys a Virtual WAN with a Routing Intent Capability.
- The Routing Intent Capability is a new capability that allows you to define routing intents for your Virtual WAN. Routing intents are used to define how traffic is routed between your branches and your Azure Virtual Networks. You can define routing intents to route traffic between your branches, between your branches and your Azure Virtual Networks, or between your branches and the Internet. You can also define routing intents to route traffic between your branches and your Azure Virtual Networks through a specific branch.
- There is an optional vpn configuration provided to setup a site to site vpn tunnel to an on-prem location. This is not required for the routing intent capability to work.  All code in vpn.tf is commented out by default.  To enable the vpn, uncomment the code in vpn.tf and fill in the required variables in variables.tfvars.

<img src="/terraform\routing_intent\Routing Intent.png" alt="High Level Design">

- When destroying use terraform apply -destroy -parallelism=1 -auto-approve.  This helps avoid some race conditions when destroying the resources.

- Original work from https://github.com/spotakash/azurenetworking but customised for my needs.  TODO feedback some changes to the original repo.