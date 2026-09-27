---
title: "Stop Writing CLI — Start Validating Design"
date: 2025-11-18
lastmod: 2026-09-27T10:57:00+10:00
author: "Gary Wong"
slug: "stop-writing-cli-start-validating-design"
tags: ["networking", "architecture", "automation", "leadership"]
categories: ["Tech"]
summary: "A design-first argument for modelling intent, validating constraints, and treating generated configuration as an implementation artefact rather than the architecture itself."
description: "Why network architects should begin with validated design intent before producing CLI."
featuredImage: "cli.avif"
draft: false
---

![Stop Writing CLI](cli.avif)

## The Project That Triggered This Post

I have worked on designs where the technical problem was not unusual, but the delivery method was: the answer was expected to be a large volume of hand-written CLI before the intent had been made explicit.

The more I worked through the configuration, the clearer the architectural question became:

- Should network design in 2025 still rely on manual CLI output?
- Are we truly addressing the core architecture, or merely throwing syntax at complexity?

A better question would have been:

> **Could we design this multi-site data center fabric in a more automated, intent-driven way from the start?**

---

## The real problem: designing backwards

The network itself wasn’t broken — but the approach was.  
In this case, the team had been:

- Manually subnetting point-to-point IP addresses in spreadsheets or Notepad
- Copy-pasting BGP neighbor configurations with only ASNs changed
- Dispersing route-redistribution logic across individual devices
- Adding a VMware NSX overlay as an abstraction layer that didn’t reduce complexity

The design lacked any **intent-based modeling**.  
The CLI became both the glue holding the solution together **and** the scapegoat for its shortcomings.

---

## Manual IP subnetting is a design smell

Today, manually calculating point-to-point subnets shouldn’t exist.

Instead:

- Define IP pools  
- Define automated assignment policies  
- Let software handle the math  

In an API-first, cloud-first, IaC world, we shouldn’t still be solving BGP mesh addressing with “spreadsheet math.”  
It’s slow, brittle, and architecturally obsolete.

---

## The role we should play

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

## What needs to change

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

## If you are still writing CLI manually

Hand-written CLI is sometimes appropriate: a small change, a controlled exception, or a troubleshooting step may be clearest when expressed directly. The problem begins when syntax becomes the only design artefact.

The value of an experienced architect is not less configuration. It is better context: the ability to decide what should be modelled, what must be validated, and where an exception needs to be made visible.

---

## Conclusion: make configuration answer to design

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

Configuration is still necessary. It should simply remain an implementation of the design, not the place where the design first becomes visible.
