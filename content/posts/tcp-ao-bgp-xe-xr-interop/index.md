+++
title = "TCP-AO BGP Interop Between IOS-XE and IOS-XR"
date = 2026-06-06T07:19:00+10:00
tags = ["networking"]
summary = "Lab note on getting BGP with TCP Authentication Option (TCP-AO) working between Cisco IOS-XE and IOS-XR, and the small details that blocked interop."
description = "Technical lab note documenting a working TCP-AO BGP interop configuration between Catalyst 8000v (IOS-XE 26.1.1) and XR9kv (IOS-XR 7.11.21), including algorithm choice, key-string handling, and include-tcp-options behavior."
+++

This tech note documents a working TCP Authentication Option (TCP-AO) configuration for BGP between Cisco IOS-XE and IOS-XR. The lab used a Catalyst 8000v running IOS-XE 26.1.1 and an XR9kv running IOS-XR 7.11.21, and the same pattern also worked on newer XR releases in follow-up tests.[web:14][web:5]

The useful part is not that TCP-AO exists, but which specific details made the session actually establish: using AES-128-CMAC, entering the key as cleartext in a platform‑specific way, and handling `include-tcp-options` correctly on the IOS-XE side.[web:14][web:5]

## Lab setup

The topology is intentionally simple:

- Two routers in AS 65001.
- IOS-XE (C8000v) and IOS-XR (XR9kv).
- iBGP over loopbacks (`10.0.0.8/32` on XE, `10.0.0.9/32` on XR).
- TCP-AO used for BGP session protection instead of TCP MD5.[web:14][web:2]

Both sides are configured for TCP-AO; there is no mixing of MD5 on one side and AO on the other. BGP configuration on IOS-XE uses the TCP key chain under the neighbor, while IOS-XR uses a combination of `tcp ao`, a key chain, and the `ao` command under the neighbor.[web:14][web:5]

Cisco’s documentation for BGP support for TCP-AO on IOS-XE and master key tuple configuration on IOS-XR aligns with this split: XE exposes AO options under BGP (including `include-tcp-options`), while XR separates AO state from BGP and then binds a keychain to the neighbor.[web:14][web:5]

## What actually mattered

Several details turned out to be critical for interop:

- AES-128-CMAC was the only tested modern algorithm that worked consistently in this setup.[web:5]
- The key had to be entered as plaintext, but the syntax differed:
  - IOS-XE: `key-string 0 <secret>`
  - IOS-XR: `key-string clear <secret>`[web:5]
- On IOS-XE, `include-tcp-options` had to be present both in the TCP key chain and under the BGP neighbor.
- On IOS-XR, `ao <keychain> include-tcp-options enable` under the BGP neighbor was sufficient.[web:14][web:5]

The `include-tcp-options` setting controls whether TCP option headers other than the AO option are included in the MAC calculation.[web:14] If one side includes those options and the other does not, authentication will fail even though the key and algorithm appear correct.[web:14]

Key entry is another subtlety. On both platforms, using the “cleartext” key-string form matters because the AO MAC is computed from the underlying secret, not from the already encoded representation that sometimes appears in running configuration.[web:5]

## Working IOS-XE configuration

On IOS-XE, TCP-AO for BGP is configured using a TCP key chain with AO parameters and then referencing that key chain under the BGP neighbor with AO-specific options.[web:14][web:2]

### TCP key chains

```text
key chain KC_BGP tcp
 key 1
  send-id 1
  recv-id 1
  include-tcp-options
  cryptographic-algorithm aes-128-cmac
  key-string 0 cisco123
  accept-lifetime 00:00:00 Apr 1 2026 infinite
  send-lifetime 00:00:00 Apr 1 2026 infinite

key chain KC_OSPF
 key 1
  key-string 0 cisco123
  accept-lifetime 00:00:00 Apr 1 2026 infinite
  send-lifetime 00:00:00 Apr 1 2026 infinite
  cryptographic-algorithm hmac-sha-256
```

Points to note:

- `KC_BGP` is explicitly marked as a TCP key chain (`key chain KC_BGP tcp`).
- `send-id` and `recv-id` are both set to `1` to match the XR side.
- `include-tcp-options` is set here so the AO MAC includes non-AO TCP options.
- `cryptographic-algorithm aes-128-cmac` selects the AES-128-CMAC algorithm.[web:14]
- The key is entered as `key-string 0 cisco123` so that both platforms share the same cleartext secret.

The OSPF key chain is shown only as a contrast: it uses HMAC-SHA-256 and a standard key chain, not the AO-specific TCP key chain.

### BGP with TCP-AO

```text
router bgp 65001
 bgp log-neighbor-changes
 network 10.0.0.8 mask 255.255.255.255
 neighbor 10.0.0.9 remote-as 65001
 neighbor 10.0.0.9 ao KC_BGP include-tcp-options
 neighbor 10.0.0.9 update-source Loopback0
```

Key items:

- `neighbor 10.0.0.9 ao KC_BGP include-tcp-options` ties BGP to the `KC_BGP` key chain and explicitly enables `include-tcp-options` at the BGP layer.
- Without `include-tcp-options` both in the key chain and in this neighbor line, the session did not come up in this lab.

Cisco’s BGP TCP-AO documentation for IOS-XE notes that `include-tcp-options` controls whether TCP options are part of the MAC calculation, and interop requires both peers to agree on this behavior.[web:14]

## Working IOS-XR configuration

On IOS-XR, configuration is split into three parts: `tcp ao` for Send/Receive IDs, the key chain for the secret and algorithm, and BGP for enabling AO on the neighbor.[web:5][web:3]

### TCP AO section

```text
tcp ao
 keychain KC_BGP
  key 1 SendID 1 ReceiveID 1
 !
!
```

This maps key `1` of key chain `KC_BGP` to SendID and ReceiveID `1`, aligning with the XE side.

### Key chains

```text
key chain KC_BGP
 key 1
  accept-lifetime 00:00:00 april 01 2026 infinite
  key-string clear cisco123
  send-lifetime 00:00:00 april 01 2026 infinite
  cryptographic-algorithm AES-128-CMAC-96
 !
!

key chain KC_OSPF
 key 1
  accept-lifetime 00:00:00 april 01 2026 infinite
  key-string clear cisco123
  send-lifetime 00:00:00 april 01 2026 infinite
  cryptographic-algorithm HMAC-SHA-256
 !
!
```

Important details:

- `key-string clear cisco123` ensures the underlying secret matches IOS-XE, which was entered with `key-string 0 cisco123`.[web:5]
- `cryptographic-algorithm AES-128-CMAC-96` is the XR-side name for AES-128-CMAC with a 96-bit MAC.[web:5]
- Lifetimes match the XE side to avoid any time-based mismatches.

### BGP with TCP-AO

```text
router bgp 65001
 address-family ipv4 unicast
  network 10.0.0.9/32
 !
 neighbor 10.0.0.8
  remote-as 65001
  ao KC_BGP include-tcp-options enable
  update-source Loopback0
  address-family ipv4 unicast
  !
 !
!
```

Notes:

- `ao KC_BGP include-tcp-options enable` attaches TCP-AO using key chain `KC_BGP` and ensures TCP options are included in the MAC calculation.
- XR does not require `include-tcp-options` under the key chain in this model; it is controlled at the BGP neighbor level for this test.

Cisco’s XR documentation for master key tuple configuration and BGP AO usage shows the same pattern of binding a key chain to AO and then enabling AO per neighbor.[web:5]

## Interop mapping

The table below summarizes how the key elements align between IOS-XE and IOS-XR in this working lab.

| Item                           | IOS-XE                                           | IOS-XR                                            |
|--------------------------------|--------------------------------------------------|---------------------------------------------------|
| AO IDs                         | `send-id 1`, `recv-id 1` in `KC_BGP tcp`        | `SendID 1 ReceiveID 1` in `tcp ao` key mapping    |
| Algorithm name                 | `aes-128-cmac`                                   | `AES-128-CMAC-96`                                 |
| Key entry                      | `key-string 0 cisco123`                         | `key-string clear cisco123`                       |
| TCP options inclusion          | `include-tcp-options` in key chain and neighbor | `include-tcp-options enable` under BGP neighbor   |
| BGP AO activation              | `neighbor ... ao KC_BGP include-tcp-options`    | `neighbor ... ao KC_BGP include-tcp-options enable` |

AES-128-CMAC is implemented slightly differently in naming, but operationally both sides use the same AES-128-CMAC family for TCP-AO.[web:5][web:14] The important part is that the algorithm, key, IDs, and TCP options behavior all match between the two platforms.[web:5][web:14]

## What failed before this state

Before arriving at the working configuration, several patterns caused the session to stay down:

- Using other “modern” algorithms instead of AES-128-CMAC in this particular interop test.
- Entering the key in a way that resulted in an encoded password on one side and a cleartext key on the other.
- Omitting `include-tcp-options` from the IOS-XE key chain.
- Omitting `include-tcp-options` from the IOS-XE BGP neighbor.
- Assuming IOS-XR needed the same dual placement of `include-tcp-options` as IOS-XE.

Cisco’s description of `include-tcp-options` makes the failure mode clear: if one side includes extra TCP options in the MAC and the other does not, AO authentication fails even though the visible running configuration looks almost identical.[web:14]

## Verification steps

Once configuration is in place, verification is straightforward:

On IOS-XE:

```text
show run | sec key chain
show run | sec router bgp
show bgp ipv4 unicast summary
show bgp neighbors
```

On IOS-XR:

```text
show run tcp ao
show run key chain
show run router bgp
show bgp ipv4 unicast summary
show bgp neighbors
```

The key checks:

- BGP neighbor state is `Established`.
- AO key IDs, algorithm, and lifetimes match.
- AO is effectively attached to the neighbor on both sides.

Cisco’s documentation also points out that TCP-AO can be debugged via AO-specific show commands and, if necessary, packet captures that confirm the AO option and MAC are present in the TCP header.[web:14][web:2]

## What to remember

For TCP-AO BGP interop between IOS-XE and IOS-XR, the safe baseline demonstrated in this lab is:

- Use AES-128-CMAC as the AO algorithm family.
- Match SendID and ReceiveID on both peers.
- Enter the key as cleartext with `key-string 0` on IOS-XE and `key-string clear` on IOS-XR.
- Ensure `include-tcp-options` is applied correctly: in both the IOS-XE key chain and neighbor, and under the IOS-XR neighbor with `include-tcp-options enable`.[web:14][web:5]

That combination was the difference between a BGP session that looked almost right and one that actually came up.

