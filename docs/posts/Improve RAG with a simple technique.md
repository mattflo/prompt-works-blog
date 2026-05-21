---
date: 2025-11-25
categories:
  - rag
  - context_engineering
slug: improve-rag-with-a-simple-technique
comments: true
description: Chunk windowing is an incredibly simple context engineering technique that can improve the quality of augmented replies while keeping your costs predictable.
---
# Improve RAG with a simple technique

Are you burning tokens on irrelevant context? Or losing critical details by sending isolated chunks? There's a better way.

<figure>
<p align="center">
  <img src="../images/chunk_windowing_512px.png" alt="Chunk Windowing">
</p>
<figcaption style="text-align: center">Obligatory AI generated image of chunk windowing</figcaption>
</figure>

## The Problem with Chunks

Once you've matched the top n similar chunks to a query, you could just put each chunk into context by itself. This will work ok, but we can do better! You could put whatever document the chunk came from entirely into context. This is better than supplying the chunk in isolation and works well if all the documents are consistent in size and relatively small. But what if there are really large documents in the corpus? You could end up sending a bunch of irrelevant context to the LLM. Maybe this is somewhat ok too, but it comes with additional latency and cost. If you're looking for a middle ground, you could try chunk windowing.

<!-- more -->

## Chunk Windowing

Chunk windowing is an incredibly simple context engineering technique. Instead of only sending the matched chunk to the LLM in isolation, we also send some adjacent chunks to provide additional context. We need to choose a window size. Don't overthink it. We are just trying to find a good middle ground between sending too much context (the whole document) and too little (a single chunk). Four is a good default. Just fetch 2 chunks before and one after the matched chunk for a total of 4 chunks. Concatenate them and provide it all together in context to the LLM. It's that simple.

## A concrete example

Here's what this looks like in practice. Imagine your RAG system matches this chunk about API authentication:

**Without windowing (matched chunk only):**
> "Use the bearer token in the Authorization header."

**With windowing (matched + adjacent chunks):**
> "All API requests require authentication. Generate a bearer token from your dashboard under Settings > API Keys. Use the bearer token in the Authorization header. Tokens expire after 90 days and should be rotated regularly."

The adjacent chunks provide critical context about *where* to get the token and *how long* it's valid—details that would be missing with isolated chunks.

## Implementation

Here's an example of how to implement chunk windowing in Python.

```python
def chunk_window(
    chunks: list[str],
    match_index: int,
    size: int = 4,
    separator: str = "\n\n",
) -> str:
    """Return a window of concatenated chunks centered around the match_index, joined by separator.

    For even window sizes, include more chunks before match_index than after. 
    Handle boundary conditions."""
    n = len(chunks)

    if match_index < 0 or match_index >= n:
        raise IndexError(
            f"chunk index {match_index} out of range for list of length {n}"
        )

    before = size // 2

    start = max(0, match_index - before)

    if start + size > n:
        start = max(0, n - size)

    end = start + size

    return separator.join(chunks[start:end])
```

## What next?

This approach gives you the best of both worlds: enough context for the LLM to understand the surrounding information, without the cost and latency of sending entire documents. In practice, chunk windowing can improve the quality of augmented replies while keeping your costs predictable. If you've already gone to the trouble of chunking and embedding your documents, you should definitely give chunk windowing a try.

!!! tip "Did you find this helpful?"

    📅 I currently offer free consultations. Or if you're more technical, I'd love to schedule a complimentary pair programming session. Feel free to [schedule some time on my calendar](https://cal.com/mattflo/30min).

    🤝 I'd love to connect!

    - 👔 [Connect on LinkedIn](https://www.linkedin.com/in/mattflo/)
    - 🌟 [Follow me on bsky.app](https://bsky.app/profile/mattflo.com)
    - 🐦 [Follow me on X](https://x.com/mattflo)
