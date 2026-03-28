---
title: "From 0–22 to 0–5: Learning AI the Hard Way in 1999"
date: 2026-03-29
author: "Gary Wong"
slug: "robocup-1999-fyp"
tags: ["ai"]
categories: ["Tech"]
draft: false
---

In 1999, three of us at HKUST decided to spend our final year project trying to teach a team of simulated soccer players how to survive against the world champions. We did not have GPUs, Python, or deep learning frameworks. We had C, a room full of Sun workstations, an NFS share, and a lot of stubbornness.

Our opponent was CMUnited from Carnegie Mellon University, the top RoboCup simulator team at the time. They were the kind of team that routinely crushed others by double digits. Our starting point was simple: take our baseline HKUST team, play them against CMUnited, and see what happens.

The first scoreline was **0–22**.

{{< figure src="/images/robocup-2d-field.jpg" alt="RoboCup 2D soccer simulation field" >}}

*RoboCup 2D soccer simulation, similar to what we used in 1999. Image credit: Wikipedia, “RoboCup 2D Soccer Simulation League”.*

## Why we still called it “AI”

Back then, “AI” did not mean large language models; it meant you wrote programs that tried to make sensible decisions in messy environments. The soccer simulator gave each player limited vision, noisy sensor readings, and a small set of actions. You had to decide, every few hundred milliseconds, whether to run, turn, pass, shoot, or just try not to make things worse.

Instead of hard‑coding every behavior, we wanted the agents to learn from experience. That idea—letting the system improve by trial and error—is what drew us to reinforcement learning, long before it became a buzzword in industry.

We picked a method that, in simple terms, tried out many different “little programs” inside each player, watched how well they did in matches, and then kept mutating the better ones. It was more like selective breeding for strategies than like today’s gradient‑based deep learning. Conceptually, it sounded elegant. In practice, it meant a lot of waiting.

## Our “cluster”: a late‑90s computer lab

Our “compute cluster” was a lab of Sun Ultra‑class SPARC workstations in a horizontal desktop setup, with chunky CRT monitors sitting directly on top of the beige boxes, classic late‑90s UNIX style. To us, as undergraduates, having access to around twenty of these machines felt like owning a supercomputer.

{{< figure src="/images/sun-ultra-workstation.png" alt="Sun Ultra-class SPARC workstation" >}}

*A late‑90s Sun Ultra‑class SPARC workstation, similar to what we used in the HKUST lab.*

We did “distributed training” without using that phrase.

All the machines mounted the same NFS share in the lab. We split the set of candidate strategies into chunks and assigned them to different workstations. Each machine would:

- Load its assigned strategies  
- Play simulated matches to see how they performed  
- Write the results to files on the shared disk  

A small “supervisor” program then walked through that shared directory, collected everyone’s results, and produced the next generation of strategies. Today, people would talk about parameter servers, workers, and orchestration. We just talked about “scripts” and “jobs” and hoped NFS would not freeze.

Sometimes the bottleneck was not the CPU at all; it was the fact that twenty machines were all trying to read and write to the same directory at the same time.

We let this whole system run for about a month.

## From 0–22 to 0–5

After that first brutal 0–22, we started the long training run. The lab lights were often off, but the fans on the SPARC boxes were still humming. We got used to reading logs instead of watching matches.

When we finally played our new, “trained” team against CMUnited again, the scoreline changed.

**0–5.**

It was still a clear defeat, but it felt very different. The players held their positions a bit better. They avoided some of the most embarrassing mistakes. They forced the champions to work a little harder for each goal. We had not built a winner, but we had clearly moved from “no chance” to “at least respectable.”

For a bunch of undergrads sharing a lab full of borrowed machines, that small improvement was huge.

## What this taught me about AI (before deep learning)

Looking back, a few lessons have stuck with me much more than any specific algorithm:

- **Computation is part of the idea.** On paper, our approach sounded powerful. In reality, we were capped by how many matches we could simulate in a month on those machines. The theory and the hardware were inseparable.  
- **Systems work matters as much as algorithms.** A lot of our time went into scripting runs, dealing with crashes, and coping with NFS quirks. The fanciest learning method in the world does nothing if your pipeline cannot stay up long enough to train it.  
- **You get what you reward.** Our learned team became decent at “not losing too badly,” but not at scoring. Looking back, it is obvious: our setup implicitly rewarded survival more than risk‑taking. The AI optimized exactly what we asked for, not what we wished for.  
- **Progress is often incremental.** Going from 0–22 to 0–5 is not a Hollywood story. It is much more typical of real AI work: incremental, imperfect, but undeniably moving in the right direction.

## Seeing today’s AI through a 1999 lens

Fast‑forward to today. We talk about large language models, retrieval‑augmented generation, and reinforcement learning from human feedback. We can rent, in minutes, more compute than our lab had access to in an entire semester. We have libraries that hide the complexity of distributed training behind a few configuration flags.

From the outside, it all looks very different from a late‑90s computer lab full of beige boxes. But the experience in 1999 quietly shaped how I think about AI now:

- When I see a model behave “safely but uselessly,” I hear the echo of our over‑defensive soccer agents.  
- When someone says “it’s just a matter of compute,” I remember how hard it was to squeeze more learning out of our month‑long run.  
- When people are surprised that an AI system does exactly what its reward structure encourages, I think of our 0–5 and smile.

We did not change the world with that project. But somewhere between that first 0–22 and the final 0–5, I learned that AI is not magic. It is a long, messy negotiation between algorithms, data, compute, and the real‑world goals we try—often clumsily—to encode.

And that realization has stayed with me, through every new wave of AI hype since.

---

Images sourced from Wikipedia and public online archives, used here for illustrative and non‑commercial purposes.
