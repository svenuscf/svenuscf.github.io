---
title: "Cumulus EVPN-VXLAN Lab — Built Fast with Containerlab"
date: 2026-05-15
tags: ["Cumulus", "EVPN", "VXLAN", "Containerlab", "FRR", "Lab", "networking"]
description: "Building a Cumulus EVPN-VXLAN lab on Containerlab, validating it with vtysh and Linux bridge state, and using automation to move from topology to verification faster."
---

> After rebuilding my Arista SR-MPLS lab on **Containerlab**, I wanted to keep that same workflow and move into **Cumulus EVPN-VXLAN**.
> This time the goal was not just to recreate a fabric, but to get hands-on quickly with a repeatable topology, fast verification, and a workflow that fits naturally with automation and AI.

---

## Why I built this lab

My earlier Containerlab work focused on **Arista SR-MPLS**.
That exercise proved something important: once the topology, startup configs, and validation flow are written as code, the time from idea to working lab drops dramatically.

So the next logical step was to build a compact **Cumulus EVPN-VXLAN** fabric and observe how the Linux bridge, FRR, and EVPN control plane all line up.

### On this lab, I wanted a few things immediately:

- **A reproducible spine-leaf topology in YAML**
- **Fast deployment with Containerlab**
- **Direct access to FRR via `vtysh`**
- **A realistic way to validate EVPN behavior from both BGP and Linux bridge views**

This is exactly the kind of workflow I want for short, focused infrastructure experiments in 2026.

---

## Architecture Summary

The lab focuses on a small **spine-leaf EVPN-VXLAN fabric** running on Cumulus Linux containers.
The underlay uses BGP between leaf and spine nodes, while EVPN distributes MAC/IP reachability for L2 VNIs across the fabric.

### Key design points

- Two spines in **AS 65100**
- Leaf1 in **AS 65111**
- Remote leaf visible as **VTEP 10.255.255.13**
- Leaf1 router ID / VTEP loopback **10.255.255.11**
- **VNI 10010** mapped to VLAN 10
- **VNI 10020** mapped to VLAN 20
- MLAG-style peerlink between the leaf nodes

Topology image:



---

## Topology YAML

Like the Arista lab, everything starts from one topology file:

```bash
containerlab deploy -t cumulus-evpn-vxlan.yaml
```

The YAML defines:

- Nodes
- Management IPs
- Spine-leaf links
- Startup configs
- EVPN-VXLAN structure

That is the real advantage of Containerlab.
The topology is not just documented — it is executable.

---

## Why Cumulus is interesting here

What makes Cumulus useful in a lab like this is the combination of **Linux visibility** and **networking abstraction**.

I can validate the same behavior from multiple angles:

- `net show` for high-level operational checks
- `vtysh` for FRR internals
- Linux bridge state for data-plane confirmation

That makes it ideal for learning EVPN-VXLAN properly rather than treating it like a black box.

---

## Validation approach (Architect mindset)

This lab is **not** a config copy-paste article.
I wanted to validate whether the design was behaving coherently at every layer.

These were the main questions:

- Are both EVPN sessions from leaf1 to the spines established?
- Are VNIs present and associated with a remote VTEP?
- Are local and remote MACs reflected correctly in the bridge table?
- Do EVPN Type-2 and Type-3 routes match what the data plane is learning?

When those answers line up, the fabric becomes predictable — and troubleshooting becomes much easier.

---

## EVPN BGP summary on leaf1

The first sanity check is:

```bash
net show bgp l2vpn evpn summary
```

From `leaf1`:

```text
BGP router identifier 10.255.255.11, local AS number 65111 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 2, using 43 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
spine1(swp1)    4      65100      1580      1589        0    0    0 01:16:19            4        9
spine2(swp2)    4      65100      1580      1592        0    0    0 01:16:08            4        9
```

What this tells me:

- Both spines are up and exchanging EVPN routes
- The sessions are stable
- `State/PfxRcd = 4` confirms routes are actually being received
- `PfxSnt = 9` suggests leaf1 is advertising its local EVPN state correctly

This is the fastest way to rule out basic adjacency or EVPN activation problems.

---

## VNI state on leaf1

Next check:

```bash
net show evpn vni
```

Output:

```text
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF
10010      L2   vni10                 2        8        1               default
10020      L2   vni20                 0        0        1               default
```

This is a very clean summary:

- **VNI 10010** is active and already populated with MAC and ARP state
- **VNI 10020** is present even though there is no active local endpoint in this snapshot
- Both VNIs already see **1 remote VTEP**

For a small two-leaf EVPN fabric, that is exactly what I want to see.

---

## MAC learning through the Linux bridge

This is where Cumulus becomes especially useful from a learning perspective.

```bash
net show bridge macs
```

Relevant excerpts:

```text
10        bridge  swp10          aa:c1:ab:c1:79:a2
10        bridge  vni10          aa:c1:ab:1b:76:8c                            extern_learn
...
untagged          vni10          aa:c1:ab:1b:76:8c  10.255.255.13             self, extern_learn
untagged          vni20          00:00:00:00:00:00  10.255.255.13  permanent  self
```

This tells me:

- Local MACs are learned on the access-facing interface (`swp10`)
- Remote MACs are learned on the VXLAN interface (`vni10`) with `extern_learn`
- The remote VTEP for that learned state is **10.255.255.13**, which matches the other leaf

This is the exact kind of visibility I like in Cumulus.
The Linux bridge is not hidden from you — it becomes part of the validation workflow.

---

## EVPN route inspection with vtysh

To tie the control plane back to the MAC table, I inspect FRR directly:

```bash
vtysh -c "show bgp l2vpn evpn route"
```

Relevant portions:

```text
Route Distinguisher: 10.255.255.11:10010
*> [2]:[0]:[48]:[aa:c1:ab:c1:79:a2]:[32]:[10.1.10.101]
                    10.255.255.11                      32768 i
                    ET:8 RT:65111:10010
*> [3]:[0]:[32]:[10.255.255.11]
                    10.255.255.11                      32768 i
                    ET:8 RT:65111:10010

Route Distinguisher: 10.255.255.13:10010
*> [2]:[0]:[48]:[aa:c1:ab:1b:76:8c]:[32]:[10.1.10.102]
                    10.255.255.13                          0 65100 65113 i
                    RT:65113:10010 ET:8
*> [3]:[0]:[32]:[10.255.255.13]
                    10.255.255.13                          0 65100 65113 i
                    RT:65113:10010 ET:8
```

What this shows:

- Leaf1 originates a local **Type-2 MAC/IP route** for host `10.1.10.101`
- Leaf1 also originates a **Type-3 IMET route** for its own VTEP participation
- Remote host `10.1.10.102` is learned from VTEP **10.255.255.13**
- The EVPN routes match the MAC learning seen in the Linux bridge

That cross-check is the whole point.
BGP, VNI state, and bridge learning all tell the same story.

---

## Useful show commands

These are the main commands I used to validate the fabric:

```bash
net show bgp l2vpn evpn summary
net show evpn vni
net show bridge macs
vtysh -c "show bgp l2vpn evpn route"
ip -br a
```

For a compact EVPN-VXLAN lab, this is enough to validate most of the important behavior quickly.

---

## Lessons learned during build

- Running the topology as code makes EVPN-VXLAN experiments very fast
- Cumulus + FRR is excellent for understanding how EVPN control plane state maps into Linux bridge behavior
- `vtysh` gives the clearest view when I want to see exactly what EVPN is advertising and receiving
- AI-assisted workflows make it easier to move from raw CLI output into structured validation notes

The biggest change is not speed alone.
It is that I spend less time transcribing commands and more time validating design intent.

---

## EVE-NG vs Containerlab (one architect’s perspective)

| Feature | EVE-NG | Containerlab |
|-------|-------|-------------|
| Topology definition | UI | YAML |
| Config version control | Manual | Git |
| Reproducibility | Medium | **High** |
| Build speed | Slower | Fast |
| Linux-level visibility | Limited | Excellent |
| Automation / AI workflow | Awkward | Natural |

> **Verdict:**
> For compact EVPN-VXLAN and control-plane labs, Containerlab is now my default starting point.

---

## What’s next

I plan to expand this into multiple follow-up posts:

- **Part 2 — EVPN route-type interpretation on Cumulus**
- **Part 3 — MLAG behavior in a dual-leaf fabric**
- **Part 4 — Failure testing during spine or peerlink loss**
- **Part 5 — Parsing and validating outputs with automation**

---

## Contact

If you're a network architect, SE, data centre engineer, or working on EVPN fabrics, connect with me:

- LinkedIn: [https://www.linkedin.com/in/gary-wong-0503a837/](https://www.linkedin.com/in/gary-wong-0503a837/)
- GitHub: [https://github.com/svenuscf](https://github.com/svenuscf)
- Blog: [https://garywong.pro](https://garywong.pro)

---

## Meta

This post continues the direction I wanted after moving onto Hugo and code-driven labs.
I do not just want to publish CLI output.
I want technical posts to reflect how I validate systems as an architect.

> **Build fast. Validate deeper. Keep the lab in code.**
