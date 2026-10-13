# Product Engineer Handbook - Writing Style Guide

Use this guide when you want the structure, tone, and vocabulary of the PostHog Product Engineer Handbook. Use it for opinionated blog posts, handbook chapters, product essays, and practical notes. Do not use it for safety instructions, legal text, or neutral reference material.

This is a style extraction from the handbook. It is not a general plain-language guide and it is not ASD-STE100.

## Rule 1: Start With a Claim That Changes the Reader's Frame

Open with a confident observation about how the world, a team, or a product works. Then explain the practical consequence.

- Weak: "This chapter explains how product teams work."
- Handbook style: "Product engineers fundamentally reshape the way product teams work."
- Handbook style: "Software product development is changing. It's faster, less predictable."

Do not open with a definition unless the definition itself makes an argument. A strong opening creates tension between the current way and a better way.

## Rule 2: Make the Thesis a Point of View

State what you believe. Name the actor who should act. Do not hide the recommendation behind neutral language.

- Weak: "Teams may want to release earlier."
- Handbook style: "It's always best to get something into the hands of users."
- Weak: "Autonomy has potential benefits."
- Handbook style: "You have to resist your urge to control product engineers."

Use qualified language only for a real boundary or tradeoff. The handbook often makes the rule first, then gives the exception.

- Rule: "The default should be to always ship something as early as possible."
- Boundary: "Provided the 'why not' doesn't include some kind of critical problem."

## Rule 3: Use Contrast to Explain the Point

The handbook repeatedly compares a slow, distant, approval-heavy default with a direct, autonomous alternative. Use this pattern when it reveals a real choice.

1. Describe the common approach.
2. Name its cost in plain language.
3. Show the preferred approach.
4. Explain why it produces a better outcome.

Example shape:

> Engineers consume requirements at a distance. Product engineers talk to users, decide what to build, ship a solution, and learn from the result.

Do not create a straw man. Describe the opposing approach fairly enough that the reader recognizes it.

## Rule 4: Build Sections Around Strong, Specific Headings

Use headings as claims, principles, traits, or anti-patterns. They should be readable without the body text.

- "Engineers own product decisions"
- "Create time to build"
- "Not talking to users"
- "How to safely test in production"

For a handbook chapter, use numbered headings when the reader needs a sequence or a finite set. For an essay, use unnumbered headings that advance the argument.

Do not use vague headings such as "Background," "Discussion," or "Additional thoughts."

## Rule 5: Use a Repeating Section Rhythm

Most handbook sections use this order:

1. State the principle in one direct sentence.
2. Explain why it matters.
3. Give a concrete practice, example, or scenario.
4. Address the obvious objection or boundary.
5. Restate the practical conclusion.

A short section can stop after the first three parts. A long section can add a list, a quote, a real story, or a metric.

## Rule 6: Prefer Short Assertions Followed by Explanation

The handbook uses short declarative sentences to create momentum, then expands them with ordinary prose.

- "Speed compounds."
- "You learn faster. Grow faster."
- "The momentum is irresistible."
- "You own everything."

Use these sentences for a conclusion, transition, or emphasis. Do not make every paragraph a slogan. The surrounding explanation must earn the assertion.

## Rule 7: Write With High Agency

The handbook gives people responsibility and verbs. Its recurring actors talk, decide, build, ship, test, support, measure, learn, own, and improve.

Prefer:

- "Engineers decide what to build."
- "Talk to people who know about these things."
- "Go find a real problem."

Avoid abstract or passive phrasing:

- "Product decisions are made through a process."
- "Customer feedback is collected."

Name who does the work and what changes because of it.

## Rule 8: Use the Handbook's Core Vocabulary Deliberately

The handbook has a consistent vocabulary. Reuse these words when they name the actual idea:

- **Users** and **customers**, not abstract "stakeholders" when people mean users or customers.
- **Build**, **ship**, **iterate**, **test**, **learn**, and **improve** for product work.
- **Impact**, **outcomes**, **context**, **autonomy**, **feedback**, **speed**, and **trust** for the operating model.
- **Product sense**, **taste**, **real problems**, **small teams**, and **feedback loops** for recurring concepts.
- **Spark joy** for an outcome that genuinely delights a user. Use it sparingly, not as a generic substitute for "good."

Keep terms stable. If you introduce "customer," do not switch to "consumer," "end user," and "stakeholder" merely for variety.

## Rule 9: Use Conversational Vocabulary With Restraint

The handbook sounds like a confident colleague, not a corporate policy. It uses contractions, direct questions, parenthetical asides, and occasional informal phrases.

- "Why is this important?"
- "Will this go wrong? Sometimes."
- "It's a no."
- "You don't need anyone's permission."

It also uses memorable phrases such as "hair on fire problems," "minimum lovable product," and "I told you so tour."

Use one vivid phrase when it clarifies the idea or makes it memorable. Do not add slang, jokes, or profanity as decoration. The underlying sentence must work without them.

## Rule 10: Treat Objections as Part of the Argument

The handbook does not pretend the recommendation has no cost. It names the objection, agrees where appropriate, and draws a boundary.

- "Should you ship genuinely bad code that doesn't work? Obviously not."
- "This isn't without its drawbacks."
- "Will this go wrong? Sometimes."

Use this three-part move:

1. State the objection in the reader's words.
2. Give the honest answer.
3. Return to the rule and its boundary.

This makes an opinionated post more credible without turning it into false balance.

## Rule 11: Ground Principles in Real Work

Support a principle with one of these forms:

- A concrete story about a decision and its result.
- A short scenario that shows the expected behavior.
- A list of specific practices.
- A metric or operating detail.
- A quotation from a named person or organization.

The handbook names companies, roles, team sizes, customer behavior, and practices. Its examples make abstract values observable.

Do not invent a story, quote, measurement, or outcome. Link to the original source. Attribute the author or organization in the same paragraph or list item.

## Rule 12: Use Lists to Make Standards Scannable

Use a list after you state a principle when the reader needs to recognize several behaviors, practices, metrics, or questions.

Good list items are parallel and specific:

- "Talk to users directly."
- "Decide how to prioritize the roadmap."
- "Measure the impact of the work."

For questions, write the exact questions a reader should ask. For standards, write observable actions rather than values alone.

## Rule 13: Give the Reader Permission to Act

The handbook often lowers the barrier to action. It explains what a meaningful first step looks like and rejects unnecessary status gates.

- "Start wherever you want and see where you end up."
- "You don't have to apply to Y Combinator."
- "Go do that."

For a practical post, end a section with the smallest real action a reader can take. Do not substitute a vague call to action for useful guidance.

## Rule 14: Use "We" for a Lived Operating Model

Use "we" when you describe your team's actual behavior, principle, or experience. This gives an opinion context and ownership.

- "At our company, engineers support customers directly."
- "We prefer feedback after the work to approval before it."

Do not use "we" to claim universal authority. Use "I" for personal experience. Use "you" for a recommendation to the reader.

## Rule 15: Close With Momentum

End a post or chapter by reinforcing the main belief, stating the next practical step, or linking the reader to the next related subject.

A handbook chapter can finish with:

- A concise conclusion.
- A useful resource list.
- A "Next chapter" link.

Do not repeat the whole post. Leave the reader with one durable idea or one clear action.

## Rule 16: Keep the Style's Boundaries

This style is direct, but it is not careless.

- Do not turn confidence into unsupported certainty.
- Do not turn directness into cruelty toward readers or colleagues.
- Do not use a slogan where the reader needs an explanation.
- Do not copy PostHog's company-specific claims as universal rules.
- Do not use the informal voice for legal, safety, incident-response, or compliance documents.

Borrow the handbook's structure and rhetorical energy. Keep your own evidence, experience, audience, and judgment.

## Draft Template

Use this template for a handbook chapter or opinionated post:

```md
# [Strong claim or specific subject]

[Opening claim about how the world works.]
[Why the current default falls short.]
[The better principle.]

## [First principle or anti-pattern]

[Direct statement.]
[Why it matters.]
[Concrete example, practice, or story.]
[Boundary or objection, if needed.]

## [Second principle or anti-pattern]

[Repeat the pattern.]

## [What to do next]

[The smallest real action the reader can take.]
```

## Final Check

Before publishing, confirm these points:

- The opening makes a claim, not an announcement.
- The post has a clear point of view.
- Each heading names a principle, trait, practice, or anti-pattern.
- Each strong assertion has reasoning, an example, or a stated boundary.
- The post names people, actions, and outcomes instead of abstractions.
- Vocabulary stays consistent with the subject.
- Informal language helps the point instead of decorating it.
- Quotes, data, and external ideas have an author or organization credit and an original link.
- The ending leaves the reader with momentum, an action, or a next topic.
