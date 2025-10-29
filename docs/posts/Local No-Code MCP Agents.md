---
date: 2025-03-13
categories:
  - mcp
  - agents
slug: local-no-code-mcp-agents
comments: true
description: In this post I introduce one of my favorite new use cases for local, no-code agents using Anthropic's popular MCP standard.
---
# Local No-Code MCP Agents

Do you keep notes and other configuration files on your local system under a git repo? Do you neglect committing and pushing because it feels like a chore? In this post I introduce one of my favorite new use cases for local, no-code agents using Anthropic's popular MCP standard.

<!-- more -->

![Chat with MCP Agent](/images/chat.png)

Admittedly my index has been a lot cleaner lately because of this tool. But you can see how easy this makes it to stay on top of your repo.  I used to only commit once or twice a month. Now I commit most days. 

One of my favorite quotes is, "How can you write clean code if you have a dirty index?" Now you can get some of that [GTD](https://gettingthingsdone.com/what-is-gtd/) psychic weight off your shoulders and inch your way towards [zettelkasten](https://zettelkasten.de/overview/) nirvana.

First, I'll share a brief background on MCP. If you're already familiar with MCP, you can skip ahead to the [Home Directory Git Repo Agent Setup](#home-directory-git-repo-agent-setup) section.

## MCP 

MCP (Model Context Protocol) is a new standard offered by Anthropic. MCP aims to be the "USB-C" of AI, making it easy to plug different components into your AI system. Components in the MCP ecosystem are made up of servers and clients. _Servers_ package up reusable bits of information (context) to be used by language models within _clients_. You can learn more about MCP at [modelcontextprotocol.io](https://modelcontextprotocol.io/introduction).

## MCP Servers

The community has been busy building a wide range of [MCP servers](https://modelcontextprotocol.io/examples).

One of my favorite MCP servers is [Git](https://github.com/modelcontextprotocol/servers/tree/main/src/git).

The git server supplies several tools that allow models to work with git repositories on your local machine. Some of the tools include:

- git_status
- git_add
- git_commit

## MCP Clients

Windsurf and Cursor are among the many "front-end" AI applications to recently add MCP Client support. This allows you to supply data from any MCP server to the LLMs and agents inside these applications. Here's a list of more [MCP clients](https://modelcontextprotocol.io/clients).

To get started with MCP powered agents in a **no-code** way, two clients you should check out are [Claude Desktop](https://claude.ai/download) and [LibreChat](https://www.librechat.ai/). Both are just chatbot applications that support the MCP client protocol. 

Claude Desktop is a simple but well designed chatbot application. It's really easy to get started with, however you're limited to Anthropic models. 

LibreChat is a popular open source chatbot application. It's highly customizable and supports a wide range of models and model providers. However, it can take a bit more work to get everything setup how you want.

## Home Directory Git Repo Agent Setup

The setup is slightly different for Claude Desktop vs LibreChat. Ultimately, LibreChat offers more flexibility. But for simplicity's sake, today I'll be showing you how to get started with Claude Desktop.

## Claude Desktop Setup Instructions

1. Install Claude Desktop. This quick start guide on [modelcontextprotocol.io](https://modelcontextprotocol.io/quickstart/user) has you covered to set up your first MCP server (Filesystem).
2. Install the [Git MCP server](https://github.com/modelcontextprotocol/servers/tree/main/src/git). Be sure to point it to the path of the git repo you want to manage.
3. After you restart you should see the tools showing up in the bottom right corner of the chat input. If you click on it, you should see all the tools and a brief description.

![Tools Enabled](/images/tools_enabled.png)

![MCP Tools](/images/mcp_tools.png)

4. Create a Claude Project titled "Home Directory Git Repo Agent". A Claude Project is kind of like an agent. Unfortunately, you can't configure specific tools for different projects. All MCP server tools are available in every project. However, each project can have its own files and system prompt. Enter the following Project Instructions (aka system prompt) and click save. Be sure to use the path to the same git repo you configured above.

> Help me maintain my home directory git repo. Run a git status and group all the changes into logical commits. Use only the file name and path to make your groupings. No need to read the file contents. Present your proposed commits and the files in them in a markdown list for my review before you make the commit(s).

> path: /Users/matt/

That's it! Start a new chat in the project and ask Claude to clean up your index.

## What's Next?

I think we are just scratching the surface here. Maybe my long-lived dream of having an effective digital [second brain](https://www.buildingasecondbrain.com/) is right around the corner?

I'll continue to share my learnings as I evolve and refine these approaches. Have you tried any MCP servers yet? Any recipes you've found useful and want to share? I'd love to hear how others are using these techniques!

!!! tip "Did you find this helpful?"

    📅 I currently offer free consultations. Or if you're more technical, I'd love to schedule a complimentary pair programming session. Feel free to [schedule some time on my calendar](https://cal.com/mattflo/30min).

    🤝 I'd love to connect!

    - 👔 [Connect on LinkedIn](https://www.linkedin.com/in/mattflo/)
    - 🌟 [Follow me on bsky.app](https://bsky.app/profile/mattflo.com)
    - 🐦 [Follow me on X](https://x.com/mattflo)
