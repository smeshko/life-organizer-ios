# Training Data Generation Prompts

Use these prompts with Claude or ChatGPT to generate training examples for each category.

---

## Prompt 1: BUDGET Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the BUDGET category.

Requirements:
- These are voice inputs, so use natural, spoken language (not formal writing)
- Include variations in length (short: "50 bucks at Starbucks" to long: "I spent around 45 euros yesterday at that new Italian restaurant downtown, the one near the park")
- Include different contexts: casual, rushed, detailed, vague
- Include edge cases: ambiguous amounts, missing info, yesterday/today/last week time references
- Include typos/transcription errors that might come from speech-to-text

IMPORTANT: Include a good mix of:
- Expenses (60 examples): groceries, eating out, transport, utilities, clothes, medical, subscriptions, fun activities, etc.
- Income (15 examples): salary deposits, freelance payments, bonuses, sold items, refunds
- Savings (5 examples): transferred to savings account, retirement contributions

Format as JSON array:
[
  {"text": "spent 45 dollars at target today", "label": "BUDGET"},
  {"text": "got my paycheck today 2400 dollars deposited", "label": "BUDGET"},
  {"text": "transferred 500 to savings account", "label": "BUDGET"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 2: SHOPPING Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the SHOPPING category.

Requirements:
- These are shopping lists - items people need to buy
- Voice inputs with natural, spoken language
- Include variations: single items, multiple items, specific brands, vague descriptions
- Include typos/transcription errors from speech-to-text

Examples should include:
- Grocery items: "milk eggs bread and cheese"
- Household items: "paper towels and laundry detergent"
- Mixed lists: "I need to get coffee filters um some bananas and maybe toilet paper"
- Specific requests: "organic almond milk the unsweetened kind"
- Rushed inputs: "just milk"

Format as JSON array:
[
  {"text": "milk eggs and bread", "label": "SHOPPING"},
  {"text": "I need to get coffee", "label": "SHOPPING"},
  {"text": "pick up organic spinach and tomatoes", "label": "SHOPPING"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 3: REMINDER Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the REMINDER category.

Requirements:
- These are tasks, todos, things to remember
- Voice inputs with natural, spoken language
- Include time references: later, tomorrow, next week, Monday, etc.
- Include various action types: call, email, pay, pick up, don't forget, etc.

Examples should include:
- Simple tasks: "call mom tomorrow"
- Complex tasks: "remind me to pick up the dry cleaning before friday"
- Urgent items: "don't forget passport for trip"
- Vague timing: "I need to email john back later"
- Work tasks: "schedule meeting with team next week"

Format as JSON array:
[
  {"text": "call mom tomorrow", "label": "REMINDER"},
  {"text": "remind me to pay the water bill", "label": "REMINDER"},
  {"text": "don't forget to pick up kids at 3", "label": "REMINDER"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 4: CALENDAR Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the CALENDAR category.

Requirements:
- These are events, appointments, meetings with specific times
- Voice inputs with natural, spoken language
- Must include time references: specific times (3pm, noon), dates, days of week
- Include event types: meetings, appointments, social events, recurring events

Examples should include:
- Work meetings: "team standup tomorrow at 9am"
- Appointments: "dentist appointment thursday at 2:30"
- Social events: "dinner with sarah friday night at 7"
- Recurring: "yoga class every monday at 6pm"
- All-day events: "conference on wednesday"

Format as JSON array:
[
  {"text": "dentist appointment thursday at 2pm", "label": "CALENDAR"},
  {"text": "meeting with clients tomorrow at 10:30", "label": "CALENDAR"},
  {"text": "dinner reservation saturday night 7:30", "label": "CALENDAR"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 5: NOTE Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the NOTE category.

Requirements:
- These are personal notes, brain dumps, random thoughts
- Voice inputs with natural, spoken language
- Catch-all category for anything that doesn't fit other categories
- Can be ideas, observations, reflections, thoughts, plans, etc.

Examples should include:
- Random thoughts: "I should really learn how to cook better"
- Ideas: "maybe we could do a road trip to the mountains next summer"
- Observations: "noticed the car is making a weird noise when I brake"
- Reflections: "feeling pretty good about the progress on the project"
- Plans (not specific enough for calendar): "thinking about redecorating the living room"
- Mixed content: "had a good conversation with mike about AI today, made me think about our own product strategy"
- Brain dumps: "need to figure out a better system for organizing my files, maybe try that new app everyone's talking about"

Format as JSON array:
[
  {"text": "I should really learn how to cook better", "label": "NOTE"},
  {"text": "noticed the car making a weird noise", "label": "NOTE"},
  {"text": "thinking about redecorating the living room", "label": "NOTE"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 6: QUOTE Category

```
I'm training a text classifier for a voice-first life organizer app.
Generate 80 realistic training examples for the QUOTE category.

Requirements:
- These are quotes from books, videos, podcasts, articles
- Usually prefixed with the source
- Can include interesting facts, statistics, insights, advice
- Voice inputs with natural, spoken language
- May include page numbers, timestamps, chapter references

Examples should include:
- Book quotes with page: "from atomic habits page 32: you do not rise to the level of your goals you fall to the level of your systems"
- Book quotes without page: "from sapiens: humans are the only species that can cooperate flexibly in large numbers"
- Video quotes with timestamp: "from veritasium's video on nuclear energy minute 12: nuclear produces less radiation than coal"
- Video quotes without timestamp: "from lex friedman's interview with sam altman: AI will be the biggest technological shift in human history"
- Podcast quotes: "from huberman lab episode on sleep: caffeine has a half life of 5 to 6 hours"
- Article quotes: "from that new york times article on productivity: multitasking reduces your iq more than marijuana"
- Statistics: "from bill gates talk minute 45: malaria kills over 400 thousand people per year"
- Short quotes: "from the mom test: your mom will lie to you"
- Academic quotes: "from thinking fast and slow chapter 3: system 1 operates automatically and quickly with little effort"

Format as JSON array:
[
  {"text": "from atomic habits page 32: you do not rise to the level of your goals", "label": "QUOTE"},
  {"text": "from veritasium minute 12: nuclear produces less radiation than coal", "label": "QUOTE"},
  {"text": "from huberman lab: caffeine has a half life of 5 hours", "label": "QUOTE"},
  ...
]

Generate diverse, realistic examples that sound like someone speaking naturally into their phone.
```

---

## Prompt 7: Edge Cases

```
I'm training a text classifier for a voice-first life organizer app.
Generate 60 challenging examples that test category boundaries.

Include:
1. Multi-transaction budget entries (8 examples):
   - "50 at DM, 120 at Next, and 30 for lunch"
   - "spent 20 on coffee and 15 on parking"

2. Ambiguous shopping vs reminder (8 examples):
   - "buy milk" (could be shopping list OR reminder to buy milk)
   - "get groceries" (shopping list OR task reminder)

3. Ambiguous calendar vs reminder (8 examples):
   - "call john tomorrow" (reminder OR phone meeting?)
   - "meet sarah for coffee tuesday" (calendar event OR reminder to meet)

4. Ambiguous note vs reminder (8 examples):
   - "I need to think about changing jobs" (note/reflection OR reminder?)
   - "should probably clean the garage" (note OR task reminder?)

5. Ambiguous quote vs note (8 examples):
   - "read somewhere that sleep is important" (vague quote OR note?)
   - "someone said AI will change everything" (quote without source OR note?)

6. Incomplete/vague inputs (8 examples):
   - "spent some money yesterday" (budget, but missing amount)
   - "that thing tomorrow" (reminder/calendar but unclear)
   - "stuff from the store" (shopping but vague)

7. Mixed category content (12 examples):
   - "dentist appointment at 2pm and it's gonna cost like 150 bucks" (calendar + budget)
   - "buy milk and eggs for tomorrow's breakfast meeting at 9am" (shopping + calendar)
   - "from productivity book: batch your shopping trips, I should try that" (quote + note)

Format as JSON array with your best guess for the label:
[
  {"text": "buy milk", "label": "SHOPPING"},
  {"text": "50 at target and 30 for gas", "label": "BUDGET"},
  {"text": "should probably clean the garage", "label": "REMINDER"},
  ...
]

These edge cases help the model learn decision boundaries between categories.
```

---

## Summary

**Total examples to generate: 540**

- BUDGET: 80 examples
- SHOPPING: 80 examples
- REMINDER: 80 examples
- CALENDAR: 80 examples
- NOTE: 80 examples
- QUOTE: 80 examples
- Edge cases: 60 examples

**Split:**
- Training set: 432 examples (80%)
- Test set: 108 examples (20%)
