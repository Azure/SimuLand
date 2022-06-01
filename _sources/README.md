# Welcome to SimuLand

# SimuLand
> See the [announcement](https://www.microsoft.com/security/blog/2021/05/20/simuland-understand-adversary-tradecraft-and-improve-detection-strategies/) on the Microsoft Security Blog.

<p align="center">
  <a href="#about">About</a> •
  <a href="#purpose">Purpose</a> •
  <a href="#structure">Structure</a> •
  <a href="#labs">Labs</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#trademarks">Trademarks</a>
</p>

---

## About

SimuLand is an open-source initiative by Microsoft to help security researchers around the world deploy lab environments that reproduce well-known techniques used in real attack scenarios, actively test and verify effectiveness of related Microsoft 365 Defender, Azure Defender and Microsoft Sentinel detections, and extend threat research using telemetry and forensic artifacts generated after each simulation exercise. 

These lab environments will provide use cases from a variety of data sources including telemetry from  Microsoft 365 Defender security products, Azure Defender and other integrated data sources through [Microsoft Sentinel data connectors](https://docs.microsoft.com/en-us/azure/sentinel/connect-data-sources#data-connection-methods).

## Purpose

As we build out the SimuLand framework and start populating lab environments, we will be working under the following basic principles: 

* Understand the underlying behavior and functionality of adversary tradecraft
* Identify mitigations and attacker paths by documenting preconditions for each attacker action
* Expedite the design and deployment of threat research lab environments
* Stay up-to-date with the latest techniques and tools used by real threat actors
* Identify, document, and share relevant data sources to model and detect adversary actions
* Validate and tune detection capabilities

## Structure

| Folder  | Description |
|---------|-------------|
| [Lab Environments](environments/README.md) | Azure Resource Manager (ARM) Templates and documents to deploy lab environments. Some environments contributed through this initiative require at least a Microsoft 365 E5 license (paid or trial) and an Azure tenant. Depending on the lab guide being worked on, the design of the network environments might change a little. While some labs would replicate a hybrid cross-domain environment (on-prem -> Cloud), others would focus only on resources in the cloud. |
| [Lab Guides](labs/README.md) | Step-by-step lab guides summarizing simulation scenarios. From a defensive perspective, simulation steps are also mapped to detection queries and alerts from Microsoft 365 Defender, Azure Defender, and Microsoft Sentinel. We believe this would help guide some of the extended threat research generated from the simulation exercise. |

```{tableofcontents}
```
