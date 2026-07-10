# Coding Agents

You might be wondering why I have so many coding agents in this repo. I have `claudecode`, `pi-agent`, `opencode`, and a few others
(`codex`, `cursor`, `antigravity-cli`). The last three are mostly for testing and are used very
rarely.

## Why so many?

**Claude Code** from Anthropic is a top-tier, market-leading coding agent, so there's no reason
not to try it. My company uses Anthropic models through Google Vertex AI. Personally, though, I
don't like it because I think it's a bit bloated. I also don't want to customize it, so I don't
find its output particularly outstanding.

However, Anthropic currently has some of the best models in the world - Opus 4.8 and, more
recently, Fable - both of which are widely regarded as state-of-the-art for coding. Since
we're not currently constrained by token usage or budget, Claude Code paired with Opus still
delivers excellent overall results.

## Pi

For personal projects, I use Chinese models such as DeepSeek or Xiaomi's MiMo Pro because they're much
cheaper than Anthropic. I'm completely satisfied with the output - the quality is excellent.
With Pi, I customize the model selection based on the folder path, especially when I'm working
on company projects.

When using DeepSeek, I need a coding agent that supports it. DeepSeek doesn't have an official
coding agent (although recently there's Reasonix). I chose Pi almost randomly after spending
about two minutes reading a comparison between Pi and OpenCode. I ended up choosing Pi simply
because I had a positive impression of it.

I've customized Pi to use Anthropic models through Google Vertex AI. Previously, it worked
extremely well, and I frequently used Pi + Opus 4.8 for company projects. Recently, however,
the response speed and token throughput have become strangely slow. I think Anthropic changed
something, because Claude Code still performs normally.

My initial experience with Pi was extremely good. The documentation is easy to understand - I
only needed about 30 minutes to read through everything and understand how Pi works. Pi is also
very lightweight (unlike Claude, which I find rather bloated), and I really like Pi's prompt
templates.

I actually know Armin Ronacher (https://github.com/mitsuhiko), who is the second-largest
contributor to the project alongside Mario Zechner (https://github.com/badlogic). I knew Armin
from his work on Sentry and because he's the creator of the Flask framework. I've also read
many of his blog posts over the years, so I already had a very positive impression of him.

I really love Pi. One feature I especially like is that whenever I want to customize something
(themes, packages, extensions, prompt templates, or skills), Pi automatically scans its own
source code to find the relevant implementation. I think that's incredibly cool.

Another thing - which I believe is Pi's biggest selling point, and something I haven't seen in
other coding agents - is how accurately it reinterprets my requests. Even if my prompt is
short, contains typos, or is poorly written, Pi usually understands exactly what I mean. I
think this is a very valuable soft skill: before answering, it effectively summarizes and
validates the user's intent to make sure both the agent and the model understand the request
correctly. It's excellent.

I honestly have nothing to complain about, and Pi remains my primary coding agent. That said, I'm always curious to try new things - which brings me to OpenCode.

## OpenCode

I recently watched this video:

https://www.youtube.com/watch?v=3C2wWsKXY3c

**OpenCode Creator: Why Open-Source AI Models Dominate**

Madison (Baseten) interviewed Dax Raad, the co-founder of OpenCode.

I've actually followed both Madison and Dax on Twitter for quite some time and often read
their posts.

I've known about Madison since before the AI era. I don't remember exactly when I started
following her, but my first impression was that she was a very talented engineer (and yes,
she's also very pretty - I'm just being honest 😄). I remember reading several of her
engineering and product blog posts, which were very well written, and that's what made me
follow her on Twitter.

After watching the interview, I came away with a very positive impression of both Dax and
OpenCode. I thought, "Why not give OpenCode a try?" So I decided to onboard it.

My experience after about 30 minutes of reading the documentation, watching the interview,
and using OpenCode:

- The documentation is more extensive than Pi's, but it's still easy enough to read. The
  configuration is a little more complicated.
- I prefer Pi's prompt-template system, while OpenCode seems to rely only on skills, like
  most other coding agents.
- I really like OpenCode's TUI. It looks modern, clean, and lightweight without being overly
  complicated.
- The animations are smooth and enjoyable.
- After watching the interview and browsing their website, I realized they're building more
  than just a coding agent. They also have projects like Zen and Go, and I think their product
  vision and business model are quite interesting.

## antigravity-cli

I have a Google AI Pro subscription, so I installed `antigravity-cli` here as well. I mainly
use Gemini because it can be shared with my family and includes 5 TB of Google Drive storage.
However, my wife says that Gemini Pro isn't as good as the free version of ChatGPT.

Sometimes I use `antigravity-cli` for code review with Gemini Pro - that's about the only
case where I reach for it.

That's my current lineup. Pi for daily work, OpenCode for exploration, and the rest for
specific needs. Different tools for different jobs.
