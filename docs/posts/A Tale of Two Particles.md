---
date: 2026-05-19
categories:
  - ai_architecture
  - context_engineering
  - agents
  - skills
slug: a-tale-of-two-particles
comments: true
description: Agentic systems run on two primitives, one stochastic and one deterministic. Almost every confusion about prompts, tools, skills, and agents starts when you lose track of which is which.
---

# A Tale of Two Particles

Agentic systems have exactly two fundamental particles: text the model reads, and code it can ask to run. One is stochastic, the other deterministic. Almost every confusion about prompts, tools, skills, and agents starts when you lose track of which is which.

The patterns built on top of these two primitives — filtering, skills, progressive disclosure — are all in service of one problem: keeping the stochastic half on the rails as the system grows. This is the problem domain of context engineering. This is the discrete measurement of agent trajectory.

<!-- more -->

## Two primitives

The two primitives are different in substance, different in who reads and runs them, and different in purpose.

![The two primitives: Prompt vs Tool](images/01_primitives.light.png#only-light)
![The two primitives: Prompt vs Tool](images/01_primitives.dark.png#only-dark)

**A Prompt is natural language read by the LLM.** It is text — instructions, rules, examples, tone. The LLM interprets it the same way it interprets the conversation. No code runs. A prompt shapes behavior through *in-context learning* — the model conditions its next-token predictions on whatever is currently in its context window. That is how a prompt guides how to respond, what to consider, what tone to take, and what is in or out of scope.

**A Tool is code executed by the orchestrator.** It has a contract (name, description, JSON schema for arguments) that the LLM reads, but the actual function runs outside the LLM — on a server, against a database, hitting an API. A tool may depend on external state (the current time, a database, a remote API), so the same arguments will not always produce the same result. The point is that the function's behavior is governed by code, not by LLM inference. The LLM never *runs* a tool; it *requests* one by emitting a structured [`tool_use`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works) block, and the orchestrator executes it.

## A skill composes the primitives

A skill is the unit that brings these two primitives together. Minimally it is a name, a description, and a prompt. Optionally it bundles tools that belong together for the work the prompt describes.

![A skill composes a prompt and zero or more tools](images/02_composition.light.png#only-light)
![A skill composes a prompt and zero or more tools](images/02_composition.dark.png#only-dark)

**The description is load-bearing.** It is what an LLM (or any router) uses to decide when to activate the skill, and what the LLM reads to understand the skill's purpose. A vague description leads to a skill being ignored when it should be selected, or selected when it shouldn't.

**A skill with zero tools is a perfectly valid skill.** Think of a "house writing style" skill or a "code review checklist" skill — pure guidance, no executable functions attached. A skill can also bundle many tools when the work calls for several actions in concert. The prompt is the non-negotiable part; the tools are optional.

**A note on terminology.** The definition above is the conceptual shape: a name, a description, a prompt, and zero or more tools, surfaced via progressive disclosure. The canonical implementation — [Agent Skills](https://agentskills.io/) — realizes that shape as folders of files on disk with a `SKILL.md` at the root. Other systems implement the same concept differently; see *Further reading* below.

### Quick reference

|                       | Prompt                                  | Tool                                     | Skill                                          |
| --------------------- | --------------------------------------- | ---------------------------------------- | ---------------------------------------------- |
| **Substance**         | Natural language                        | Code + schema                            | Name + description + prompt + 0..n tools       |
| **Who reads/runs it** | LLM (as tokens)                         | Orchestrator executes; LLM reads schema  | LLM selects; Orchestrator loads; LLM reads      |
| **Purpose**           | Shape behavior                          | Take actions, fetch data                 | Compose prompt and related tools               |

## Two shapes of skills

Skills come in two qualitatively different shapes. The distinction is not structural — both shapes have the same `name + description + prompt + 0..n tools` anatomy — and it is not about the tools either. The difference lives entirely in the prompt: how prescriptive its natural-language instructions are about sequencing.

![Two shapes of skills: open-ended vs workflow-style](images/03_skill_shapes.light.png#only-light)
![Two shapes of skills: open-ended vs workflow-style](images/03_skill_shapes.dark.png#only-dark)

**Only the prompt differs.** If you handed someone the JSON for each, the only thing that would look different is the prose inside the prompt field. An open-ended prompt says "here is the goal, here are your tools, figure it out." A workflow-style prompt says "do these things in this order." Same LLM, same tools, same orchestrator — just different instructions about how much latitude the LLM has.

**The LLM still runs the show in both cases.** A workflow-style skill is not a deterministic script. The LLM reads "step 1, then step 2, then step 3" the same way it reads any other instructions — as guidance it usually follows but might not. It can skip a step, reorder, get the arguments wrong, or hallucinate a step that wasn't listed. The numbered list is a strong nudge, not a guarantee. There is no separate deterministic executor stepping through the workflow. There is just an LLM with a more prescriptive prompt.

**Tools are orthogonal to shape.** An open-ended skill can have zero tools (pure judgment) or many. A workflow-style skill can have zero tools (a checklist for the LLM to walk through in conversation) or many. The shape of the prompt and the inventory of tools are independent design choices.

**Why workflow-style is still useful, despite being non-deterministic.** Even though the LLM might deviate, a strongly worded ordered list dramatically reduces the variance of what it does. Combined with system-level safeguards (the refund tool itself checking that a return was initiated first, for example), you get practical predictability without ever having a truly deterministic flow. The determinism, when you need it, lives in the tools, not in the skill prompt.

## Activation and progressive disclosure

Skills-based architectures imply a notion of filtering and activation that simpler tools-only architectures do not require. A tools-only setup can implement tool filtering — and the strategies are essentially the same ones used with skills: intent classifiers, vector retrieval, hierarchical routers. But filtering is optional in a tools-only world. In a skills-based world, activation is part of the design.

The defining move is this: skill names and descriptions are presented to the LLM up front, and the LLM itself decides which 0..n skills are relevant for the current turn. Only then is the full prompt and tool inventory of each activated skill disclosed.

![Skill activation flow](images/04_activation.light.png#only-light)
![Skill activation flow](images/04_activation.dark.png#only-dark)

The same idea, in terms of what is actually in the LLM's context before and after activation:

![Context before and after skill activation](images/05_context_before_after.light.png#only-light)
![Context before and after skill activation](images/05_context_before_after.dark.png#only-dark)

**Activation is intrinsic to skills, not bolted on.** Without activation, every skill's full prompt and tools would have to be dumped into context on every turn, which defeats the purpose of having skills at all. The lightweight catalog of names + descriptions is what makes the pattern scale.

**The mechanism is the LLM itself, using descriptions.** Skill names and descriptions are cheap to include in context, so all of them get presented up front. The LLM reads them like a menu and picks what fits — the same kind of inference it does when choosing which tool to call. Other filtering strategies (classifiers, embeddings, rule-based routers) can layer in *before* the LLM sees the catalog to prune large skill libraries, but the LLM doing the final selection from descriptions is the defining move.

**[Progressive disclosure](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) is the payoff.** A skill is `name + description + prompt + 0..n tools`. The name and description are the lightweight summary face of the skill — what the LLM sees during selection. The prompt and tools are the heavy payload — what gets revealed once activated. This is what makes the pattern scale: you can have hundreds of skills in a catalog, and the LLM only ever pays the context cost for the handful it activated.

**The same filtering strategies still apply on top.** Once you have hundreds of skills, even the catalog of names + descriptions gets unwieldy, and you will want a pre-filter (intent classification, embeddings, hierarchical routing) before presenting the catalog to the LLM. Skills do not replace those filtering strategies — they sit alongside them, with LLM-driven activation as the final, always-present layer.

**Why this is different from tools-only filtering.** In a tools-only setup, filtering is an optimization — you do it to save tokens or improve tool selection. In a skills setup, activation is *the interface*. The prompt and tools of a skill are meant to be hidden behind their description and revealed on demand. That is the architectural shift.

## The bigger frame: context engineering and agent trajectory

The choice of whether to filter, how aggressively to filter, when to compose tools with a prompt into a skill, whether to pre-filter the skill catalog itself — these are all instances of the same activity: shaping what the LLM sees on any given turn.

**That activity is [context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).** It is the discipline of deciding what goes into the LLM's context window, in what form, at what point in the conversation. Tools, skills, prompts, and filtering strategies are not the goal; they are the building blocks that context engineering operates on.

**And what is context engineering in service of? Agent trajectory.** That is the term for the path a stochastic LLM takes through a task — which tools it invokes, in what order, with what arguments, and whether it arrives at a sensible answer. A "good" trajectory looks like the LLM picking the right tool, calling it with the right arguments, observing the result, and proceeding sensibly. A "bad" trajectory looks like the LLM picking the wrong tool, hallucinating arguments, ignoring results, or getting lost mid-task.

[Trajectory degrades as context grows](https://research.trychroma.com/context-rot). At 10 tools the LLM may pick well almost every time. At 50 tools the failure rate creeps up. At 200 tools it can fall apart — not because the LLM cannot read 200 descriptions, but because too many of them are either confusable with each other or irrelevant to the task. The model can no longer *pay attention* to the relevant tokens; discrimination breaks down. This is *context rot*. The exact breaking point depends on the model, the task, and how distinct the descriptions are from each other.

**This reframes the filtering discussion.** Saving tokens is a real concern in some systems — sometimes the primary one. But it is not the concern in this discussion. The question that matters here is "at what point does adding more to context start hurting the LLM's ability to do the job well?" That is a question about trajectory. Filtering, skills, activation, and progressive disclosure are all ways of keeping the LLM's working set small enough that its trajectory stays on the rails.

**Skills, viewed through this lens, are a context-engineering pattern.** They exist because composing prompt + tools into named, described units lets you defer the full content until the LLM has decided it is relevant. The architectural shift from "tools" to "skills" is really a shift in how aggressively the system practices progressive disclosure to protect agent trajectory.

Which raises the only question that matters: when does a given agent's trajectory degrade enough that the filtering strategy has to change? You cannot know by inspection. You cannot know by intuition. There is no general rule, no prescriptive best practice that works with any certainty. The only honest answer is empirical — exercise the system against an evaluation dataset and measure what happens to the trajectory. This is evals, and it's the next post.

!!! tip "Working on similar things?"

    I help teams build AI software worth shipping. If that's something you're working on, [find a time](https://cal.com/mattflo/30min) or reach me on [LinkedIn](https://www.linkedin.com/in/mattflo/), [Bluesky](https://bsky.app/profile/mattflo.com), or [X](https://x.com/mattflo).

## Further reading

The skill pattern shows up in a few different shapes today, all working off the same underlying primitives.

**The canonical (filesystem) standard.**

- [Agent Skills (agentskills.io)](https://agentskills.io/) — the open spec; folders on disk with a `SKILL.md` at the root.
- [Anthropic's skills repo](https://github.com/anthropics/skills) — production examples (PDF, Excel, PowerPoint, Word).

**Provider / backend abstraction.** Decouple where skills live from how the agent sees them.

- [Agent Skills SDK proposal](https://github.com/agentskills/agentskills/issues/139) — provider interface above the canonical spec (filesystem, HTTP, custom backends).
- [AgentSkills MCP](https://github.com/zouyingcao/agentskills-mcp) — exposes the canonical skill format as MCP resources and tools.

**Virtual filesystems for agents.** Same idea, applied to the agent's whole filesystem rather than just skill storage.

- [LangChain Deep Agents `Backend` protocol](https://docs.langchain.com/oss/python/deepagents/backends) — production-ready expression of the pattern; any storage under a unified filesystem view.
- [Turso AgentFS](https://github.com/tursodatabase/agentfs) — SQLite-backed VFS with a tool-call audit trail built into the storage layer.
- [Strukto Mirage](https://github.com/strukto-ai/mirage) — unified VFS mounting cloud services side-by-side; snapshot, restore, and clone for replayable runs.
