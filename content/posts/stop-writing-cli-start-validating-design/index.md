---
title: "Stop Writing CLI — Start Validating Design"
date: 2025-11-18
author: "Gary Wong"
slug: "stop-writing-cli-start-validating-design"
tags: ["networking", "architecture", "automation", "leadership"]
categories: ["Tech"]
featuredImage: "cli.avif"
draft: false
---

![Stop Writing CLI](cli.avif)

## The Project That Triggered This Post

Recently, I was assigned to a mid-scale network migration spanning three data centers.

The architecture was straightforward but labor-intensive: dozens of VRFs, hundreds of point-to-point BGP sessions in a BGP fabric, and a VMware NSX overlay. Despite this modern setup, I was asked to manually write all of the configuration changes as CLI.

After coding over **6,000 lines of CLI** that night, I paused to reflect:

- Should network design in 2025 still rely on manual CLI output?
- Are we truly addressing the core architecture, or merely throwing syntax at complexity?

A better question would have been:

> **Could we design this multi-site data center fabric in a more automated, intent-driven way from the start?**

---

## The Real Problem: We’re Designing Backwards

The network itself wasn’t broken — but the approach was.  
In this case, the team had been:

- Manually subnetting point-to-point IP addresses in spreadsheets or Notepad
- Copy-pasting BGP neighbor configurations with only ASNs changed
- Dispersing route-redistribution logic across individual devices
- Adding a VMware NSX overlay as an abstraction layer that didn’t reduce complexity

The design lacked any **intent-based modeling**.  
The CLI became both the glue holding the solution together **and** the scapegoat for its shortcomings.

---

## Manual IP Subnetting is Outdated

Today, manually calculating point-to-point subnets shouldn’t exist.

Instead:

- Define IP pools  
- Define automated assignment policies  
- Let software handle the math  

In an API-first, cloud-first, IaC world, we shouldn’t still be solving BGP mesh addressing with “spreadsheet math.”  
It’s slow, brittle, and architecturally obsolete.

---

## The Role We Should Play

As network architects, our job is not to churn out config lines.

We are hired to:

- Validate and verify design logic  
- Model configuration intent  
- Align topology with business and security requirements  
- Build networks that are scalable, observable, and automatable  

In other words:

> **Stop being a config writer. Start being a design validator.**

We demonstrate value through architecture, not typing speed.

---

## What Needs to Change

### **Technically:**

- Use centralized IP pools and templates  
- Automate config generation (Python, Jinja2)  
- Use structured intent (YAML/JSON)  
- Leverage design metadata to generate configs  
- Adopt modern fabrics (ACI, EVPN-VXLAN) to simplify multi-site design  

### **Culturally:**

- Stop accepting “just give me the config”  
- Steer the conversation toward design validation  
- Respond with partnership such as:  
  > “Let me review the design logic first and deliver a reusable configuration model.”

This reframes you as a strategic advisor — not a syntax producer.

---

## If You’re Still Writing CLI Manually…

Here’s the hard truth:

> If you're typing every line by hand, you're proving you can type, not that you can think.

Don't let decades of experience be reduced to syntax.  
Your value is in **strategy**, not the keyboard.

---

## Conclusion: Be the Strategic Advisor, Not the Keyboard Resource

We often hear:

> “Hey, can you just generate the config for us?”

A better response:

- “Yes — but let me first review the design so I’m not just fixing symptoms.”  
- “Let’s align on the architecture model so we don't create another one-off solution.”

Because the future of network design isn’t more CLI.

It’s:

- better **context**  
- better **consistency**  
- smarter **delivery**  

---

### **Let’s raise the bar — one design at a time.**

