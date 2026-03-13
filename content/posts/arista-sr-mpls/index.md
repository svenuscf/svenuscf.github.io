---
title: "Arista SR-MPLS Lab — Rebuilt on Containerlab"
date: 2025-12-04
tags: ["Arista", "SR-MPLS", "Containerlab", "EVPN", "Lab", "networking"]
description: "Rebuilding my SR-MPLS lab from EVE-NG to Containerlab, with a cleaner topology, versioned configs, and a reproducible design process."
---

> After moving my blog to **https://garywong.pro**, this is my first technical article under the new branding.  
> Instead of migrating the old post 1:1, I **rebuilt the entire SR-MPLS lab** from scratch — this time using Containerlab, version control, and documented architecture decisions.

---

## Why I rebuilt this lab

I originally built this topology on EVE-NG back in 2023. 
It worked, but it also had typical issues:

- No version control  
- Risk of silent config drift  
- Hard to reproduce environments  
- CLI screenshots instead of structured notes  

### On Containerlab, things changed:

- **Topology as YAML (Infrastructure as Code)**  
- **All configs tracked in GitHub**  
- **Topology image embedded in README**  
- **Fast teardown / rebuild cycle**

This is closer to how real network testing **should** be done in 2026.

---

## Architecture Summary

The lab focuses on **Segment Routing over MPLS** using Arista cEOS, with ISIS for the underlay and BGP EVPN for service signaling.

### Key design points

- Single **ISIS level-2** domain  
- **SRGB: 400000–410000**  
- **Prefix-SID allocation** for all loopbacks  
- **Two route-reflectors** for BGP signaling  
- EVPN used **without VXLAN** (pure RFC7432 signaling over MPLS)

Topology image:

![Topology overview](sr-mpls1.avif)

---

## Topology YAML

Everything starts from one file:

```  
containerlab deploy -t ceos-sr-mpls.yaml  
```

The YAML defines:

- Nodes (cEOS images)
- Management IPs
- SR-MPLS links
- Startup configs

The full YAML is here:  
https://github.com/svenuscf/arista-ceos-sr-mpls/blob/main/ceos-sr-mpls.yaml

---

## GitHub Repository

Project Repo:  
https://github.com/svenuscf/arista-ceos-sr-mpls

Key folders:

- `ceos-sr-mpls.yaml` — topology definition  
- `configs/` — all router configs  
- `arista-ceos-sr-mpls-topo.png` — visual topology image  
- `readme.md` — quick deployment guide  

Clone:

```  
git clone https://github.com/svenuscf/arista-ceos-sr-mpls.git  
cd arista-ceos-sr-mpls  
containerlab deploy -t ceos-sr-mpls.yaml  
```

---

## Validation approach (Architect mindset)

This lab is **not** a config copy-paste article.  
I validated the design by answering these questions:

- Does ISIS correctly advertise prefix-SIDs for every loopback?  
- Is the LFIB populated with the expected next-hops for each remote SR endpoint?  
- Do RR nodes propagate EVPN routes (RT2/RT5) without VXLAN?  
- Does the SRGB remain consistent across all nodes?  

When everything aligns, the control plane becomes predictable — and troubleshooting becomes trivial.

---

## Useful show commands

These are the main operational commands I use to verify SR-MPLS behavior on Arista:

```  
show isis segment-routing  
show isis neighbors  
show bgp evpn summary  
show mpls lfib route  
show ip route detail  
```

(Full operational checklist will be a separate post.)

---

## Lessons learned during rebuild

- Running topology as code is liberating — I can **destroy and redeploy** the entire lab in <30 seconds  
- Topology changes become **Git commits**, not memories  
- Using an explicit **SRGB range** helps avoid silent SID collisions  
- EVPN without VXLAN is still highly relevant for MPLS service design  

---

## EVE-NG vs Containerlab (one architect’s perspective)

| Feature | EVE-NG | Containerlab |
|-------|-------|-------------|
| Config version control | screenshots | Git |
| Topology definition | UI | YAML |
| Reproducibility | Medium | **100%** |
| Build speed | Slow | Fast |
| Integration | Standalone | DevOps-ready |

> **Verdict:**  
I will still use EVE-NG for GUI, but all future design work will start in Containerlab.

---

## What’s next

I plan to expand this series into multiple posts:

- **Part 2 — TI-LFA testing with controlled link failures**  
- **Part 3 — EVPN Route-Types deep dive**  
- **Part 4 — SRv6 equivalent lab**  

---

## Contact

If you're a network architect, SE, DC/SP engineer, or studying SR-MPLS design — connect with me:

- LinkedIn: https://www.linkedin.com/in/gary-wong-0503a837/
- GitHub: https://github.com/svenuscf
- Blog: https://garywong.pro

---

## Meta

This is **blog post #1** after rebranding from my old platform to Hugo + Containerlab + real Git workflows.  
I want my technical content to reflect how I think as an architect, rather than just showing lines of CLI.

> **Stop writing CLI. Start validating design.**


