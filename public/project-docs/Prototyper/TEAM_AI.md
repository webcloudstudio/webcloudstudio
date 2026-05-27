# TEAM·AI — Building Right and Fast When the Spec Has Unknowns

*A process for delegating an under-specified build to an AI agent and reviewing its work
through a purpose-built console.*

Ed Barlow · 2026

---

## The problem

Some projects are small but you don't yet know how to build them *right*. You don't know
the best library, whether the data is usable, whether a score runs high-is-good or
low-is-good, or whether the idea is even worth doing. That kind of spec can't be finished
on paper — the answers come from doing the work.

Hand it to an agent as one shot and it must guess every unknown. The wrong guesses are
the ones only you could have caught.

> **Why it bites:** the corrections end up in the *code* while the *spec* still says the
> old thing. You are left with software you don't fully understand and a spec that lies
> about what it is.

## What's new

TEAM·AI is a third build mode. You **delegate the build to the agent and stay the
reviewer.** The agent turns the spec into a plan of *knowns and unknowns*, investigates
each unknown as an agile **spike**, and shows you its work in a **console built for
review** — predicting what you'll want to see and putting the evidence in front of you.

💡 **You delegate; you don't drive.** You give the agent the spec and review its output.
You are the product owner, not the implementer.

💡 **A purpose-built console for viewing the dev work.** At each step the agent predicts
what you'll want to verify and presents it — the downloaded data, a coverage table, the
library it chose — so you can confirm the obvious things in seconds. *This is the core
innovation.*

💡 **Spikes turn unknowns into evidence.** Each unknown becomes a spike — a small, custom
investigation. Spikes can have prerequisites, and some require the agent to build
best-guess parts of the app (a downloader, an analyzer) just to run — so you often get
most of the application as a by-product of investigating it.

💡 **The plan is split into knowns and unknowns.** Spikes investigate the unknowns; the
plan is then re-evaluated and the code assembled. You approve the plan before any of it
runs.

💡 **Spike artifacts assemble the next step.** Each spike writes a named file
(e.g. `STEP_2_LIBS.md`); later prompts — and the final build — are assembled from those
files. The build learns from its own evidence.

## The workflow — and what you approve

1. **You give the agent the spec.**
2. **The agent returns a plan:** *"I found 8 spikes I need to investigate to make this
   happen,"* shown cleanly in the console. **You approve the plan.** *(This is the gate.)*
3. **You adjust** — *change this and that* — the agent revises, you approve.
4. **The agent runs the spikes,** one at a time. Each is a custom investigation; where a
   spike needs working code, the agent builds a best-guess version. Each spike produces
   evidence.
5. **You review in the console** and change the items you want — say items 5 and 9 — which
   then iterate through normal processing (rerun a spike with new information, etc.). The
   spec is small, so iterating is cheap.

> **What is actually gated:** the **plan**, up front. After that you **review and adjust
> individual spikes** — not a hard stop at every step.

## The console

A small FastAPI app — the window into the build, not the product. One tab per spike,
color-coded by status, with an *approved / total* count and an *awaiting review* badge up
top. Each tab shows the spike's intent, the evidence files it produced, the rendered
evidence (text, tables, samples), and a review control: a comment box with **Approve**,
**Request revision**, and **Reject**. Your decision is written to a small state file the
build is watching — so the browser steers the build without launching anything itself.

## Running it

```bash
bash bin/build_plan.sh <Spec> spikes      # spec → a plan of spikes
bash bin/oneshot2.sh   <Spec> <Target>     # run spikes, produce evidence, iterate
bash teamai_console/bin/start.sh           # review at http://127.0.0.1:8077
```

> **Example** *(illustrative).* A data pipeline whose unknowns are: which library,
> connectivity, a client class, data coverage, the database schema, which signals are
> computable, and whether the idea is differentiated. Each is one spike. You approve the
> plan, review each result, and the spec is complete and de-risked once the last spike is
> approved.
