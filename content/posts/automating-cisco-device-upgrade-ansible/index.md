---
title: "Automating Cisco Device Upgrades with Ansible: A Playbook Journey"
date: 2024-09-01
author: "Gary Wong"
slug: "automating-cisco-device-upgrades-ansible"
tags: ["automation", "ansible", "cisco", "ios-xe", "networking", "upgrades"]
categories: ["Tech"]
draft: false
---

As networks scale and new software updates become available, keeping Cisco devices up to date is crucial for maintaining optimal performance, security, and functionality. However, manually upgrading multiple devices can be time-consuming and prone to errors.

That’s where **Ansible** comes into play, allowing us to automate and streamline the entire upgrade process for Cisco IOS/IOS-XE devices. Over the past few weeks, I’ve been working on a series of Ansible playbooks to automate this task efficiently.

This post walks through the key steps of this automation project, the challenges faced, and how the Ansible playbooks in my GitHub repository make upgrading Cisco devices a seamless experience.

## Why Automate Cisco Upgrades?

Upgrading network devices is an important maintenance activity to ensure that devices:

- run the latest software versions  
- receive bug fixes  
- close security vulnerabilities  

But there are common challenges:

- **Manual labour** – performing upgrades on each device, step by step, is tedious.  
- **Human error** – manual configurations can lead to misconfigurations or missed steps.  
- **Consistency** – maintaining uniformity across multiple devices is difficult when done manually.

Ansible addresses these challenges by allowing us to automate the process through well-defined playbooks, ensuring consistency, speed, and reduced error rates.

## Handling Different Types of Cisco Devices

One challenge I faced was that different Cisco devices require different commands for the upgrade process. This is due to variations between models such as Catalyst switches, IOS-XE routers, and legacy IOS devices.

To tackle this, I structured the Ansible playbooks into distinct sub-directories, each designed to handle specific device types:

- **`Catalyst_Install_Mode`**:  
  For Catalyst switches that use INSTALL mode (e.g. Catalyst 9200, 9300). In this mode, switches rely on packages and a `packages.conf` file for booting.

- **`IOS_XE_Router_Install_Mode`**:  
  For IOS-XE routers that also use INSTALL mode, where the boot system points to `bootflash:/packages.conf`.

- **`Legacy_Bundle_Mode`**:  
  For legacy IOS devices that use BUNDLE mode, where the boot system points directly to a firmware image on flash (e.g. `boot system flash:`).

Each sub-directory contains specific playbooks tailored to the upgrade process for those device types, ensuring the correct sequence of commands is used.

## Important Note on Smart Licensing (Version 16.10.1 and Later)

Before performing any upgrade, especially if you are moving from a version before **16.10.1**, it’s important to be aware that Cisco introduced **Smart Licensing** in IOS-XE version 16.10.1. Devices upgraded to this version or later may need to transition from legacy licensing to smart licensing.

The current playbooks do **not** include tasks to:

- check the running version for smart licensing readiness  
- automate the conversion from legacy licensing to smart licensing  

You should ensure that you are prepared to handle any licensing changes manually after upgrading to versions starting from 16.10.1. Proper attention to licensing is crucial to avoid service disruptions.

## The Playbook Collection

In this repository, I’ve created a series of Ansible playbooks that tackle different phases of the Cisco device upgrade process. Below is an overview of the main playbooks and their purpose.

### 1. Cleanup Flash (`cleanup-flash.yaml`)

The first step in the upgrade process is to free up space on the device by removing unused or outdated firmware files. This playbook runs the necessary cleanup commands, ensuring that the device has enough space to accommodate the new firmware.

Example usage:

```bash
ansible-playbook -i ansible_hosts Catalyst_Install_Mode/cleanup-flash.yaml
```

### 2. Upload Firmware (`upload-image-scp.yaml` / `tftp-upload-image.yaml`)
Once the device is ready, the next step is to upload the new firmware. Depending on the environment, this can be done using SCP or TFTP. Two separate playbooks are available:

- **SCP** – more secure and preferred where SCP is supported
- **TFTP** – an alternative where TFTP is faster or SCP is unavailable

Example usage:
```
ansible-playbook -i ansible_hosts Catalyst_Install_Mode/upload-image-scp.yaml
```

### 3. Verify File Validity (`file-validity-check.yaml`)
After uploading the firmware, the playbook verifies its integrity by comparing the MD5 checksum of the uploaded file with the official checksum from Cisco. This is crucial to avoid upgrading with a corrupted file.

Example usage:
```
ansible-playbook -i ansible_hosts Catalyst_Install_Mode/file-validity-check.yaml
```

### 4. Activate the New Firmware (`activate-image.yaml`)
Once the firmware is validated, the playbook proceeds to activate the new firmware on the device. This ensures the device boots using the new version after the next reload.

Example usage:
```
ansible-playbook -i ansible_hosts Catalyst_Install_Mode/activate-image.yaml
```

## Pre-Upgrade Health Check (`pre-upgrade-check.yaml`)

Before performing the actual upgrade, I built a pre-upgrade check playbook to ensure the device is ready.

This playbook checks:

- **Mode (INSTALL or BUNDLE)** – whether the device is running in INSTALL or BUNDLE mode
- **Firmware existence** – whether the target firmware file is already present on the device
- **MD5 checksum** – integrity of the firmware file on the device
- **Current version** – whether an upgrade is required

Running this playbook before the actual upgrade gives a comprehensive view of the device’s status and ensures that no manual pre-upgrade tasks are missed.

Example usage:
```
ansible-playbook -i ansible_hosts pre-upgrade-check.yaml
```

## Logging and Traceability
To ensure all playbook executions are traceable, Ansible outputs are logged using the tee command. This allows administrators to easily check which devices are ready for an upgrade and which require further actions.

For example, after running the pre-upgrade check, you can quickly see which devices are ready using:
```
grep Report log/*
```

## Conclusion
The journey to automate Cisco device upgrades using Ansible has been rewarding and has significantly simplified the process. By breaking down the upgrade procedure into manageable playbooks and incorporating health checks and logging, we can now upgrade devices across the network efficiently, with minimal risk of errors.

The playbooks can be found in my GitHub repository. I encourage network engineers to check it out, fork the repo, and contribute if you’d like to add improvements or adapt it to your own environment.

Gary @ Geelong, Australia — Sep 2024
