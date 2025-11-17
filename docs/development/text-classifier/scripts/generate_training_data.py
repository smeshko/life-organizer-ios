#!/usr/bin/env python3
"""
Generate diverse, realistic training data for text classifier.
This script creates thousands of examples with:
- Typos and informal language
- Ambiguous cases
- Mixed intents
- Various phrasings
- Edge cases
"""

import json
import random
from typing import List, Dict

# Seed for reproducibility
random.seed(42)

def add_typos(text: str, typo_rate: float = 0.1) -> str:
    """Add realistic typos to text."""
    if random.random() > typo_rate:
        return text

    typo_patterns = [
        # Common keyboard mistakes
        ('the', 'teh'),
        ('and', 'adn'),
        ('for', 'fro'),
        ('you', 'yuo'),
        ('that', 'taht'),
        ('this', 'tihs'),
        ('from', 'form'),
        ('have', 'ahve'),
        ('with', 'wiht'),
        # Missing letters
        ('tomorrow', 'tommorow'),
        ('definitely', 'definately'),
        ('receive', 'recieve'),
        # Double letters
        ('good', 'goood'),
        ('really', 'reallly'),
    ]

    pattern = random.choice(typo_patterns)
    return text.replace(pattern[0], pattern[1])


def generate_budget_examples(count: int) -> List[Dict]:
    """Generate BUDGET training examples."""
    examples = []

    # Templates with variation
    amounts = ['5', '12', '23.50', '45', '67.99', '100', '250', '500', '1250', '2400']
    currencies = ['dollars', 'bucks', 'euro', 'euros', 'eur', 'usd', 'lev', 'leva', '$', '€']

    # Expense templates
    expense_templates = [
        "spent {amount} {currency} on {item}",
        "paid {amount} {currency} for {item}",
        "{amount} {currency} at {place}",
        "bought {item} for {amount}",
        "I think it was like {amount} maybe {amount2} {currency}",
        "umm spent {amount} on {item}",
        "{item} cost me {amount} {currency}",
        "paid about {amount} for {item} yesterday",
        "{amount} {currency} {item}",
        "spent somewhere around {amount} {currency}",
        "I paid {amount} {currency} {item}",
        "{item} {amount} {currency} today",
    ]

    # Income templates
    income_templates = [
        "got paid {amount} {currency}",
        "earned {amount} from {source}",
        "income: {amount} {currency}",
        "made {amount} {currency} selling {item}",
        "received {amount} {currency} refund",
        "salary {amount} {currency} deposited",
        "my paycheck was {amount}",
        "bonus payment {amount} {currency}",
        "{amount} {currency} cashback",
        "sold {item} for {amount}",
    ]

    items = [
        'coffee', 'groceries', 'lunch', 'dinner', 'gas', 'parking', 'uber',
        'rent', 'electricity bill', 'internet', 'gym membership', 'haircut',
        'clothes', 'shoes', 'phone charger', 'snacks', 'taxi', 'movie tickets',
        'medicine', 'vitamins', 'books', 'coffee beans', 'bread', 'milk'
    ]

    places = [
        'Starbucks', 'Whole Foods', 'Target', 'DM', 'Lidl', 'the store',
        'the restaurant', 'the gas station', 'Amazon', 'the pharmacy',
        'the market', 'the shop', 'online', 'the mall'
    ]

    sources = [
        'freelance work', 'side job', 'the client', 'tutoring',
        'selling stuff online', 'weekend gig', 'my side hustle',
        'consulting work', 'the project'
    ]

    # Generate expense examples
    for _ in range(int(count * 0.7)):
        template = random.choice(expense_templates)
        example = template.format(
            amount=random.choice(amounts),
            amount2=random.choice(amounts),
            currency=random.choice(currencies),
            item=random.choice(items),
            place=random.choice(places)
        )
        example = add_typos(example, 0.15)
        examples.append({"text": example, "label": "BUDGET"})

    # Generate income examples
    for _ in range(int(count * 0.3)):
        template = random.choice(income_templates)
        example = template.format(
            amount=random.choice(amounts),
            currency=random.choice(currencies),
            item=random.choice(items),
            source=random.choice(sources)
        )
        example = add_typos(example, 0.15)
        examples.append({"text": example, "label": "BUDGET"})

    return examples


def generate_shopping_examples(count: int) -> List[Dict]:
    """Generate SHOPPING training examples."""
    examples = []

    templates = [
        "buy {item}",
        "get {item}",
        "need {item}",
        "pick up {item}",
        "grab {item}",
        "I need to buy {item}",
        "get me {item}",
        "shopping: {item}",
        "{item} from the store",
        "need to get {item}",
        "buy {item} and {item2}",
        "{item} {item2} and {item3}",
        "get {item} the {variant} kind",
        "pick up {item} and maybe {item2}",
        "I need {item} later",
        "grab some {item}",
        "buy a {item}",
    ]

    items = [
        'milk', 'eggs', 'bread', 'cheese', 'butter', 'coffee', 'tea',
        'bananas', 'apples', 'oranges', 'tomatoes', 'lettuce', 'spinach',
        'chicken', 'beef', 'fish', 'pasta', 'rice', 'flour', 'sugar',
        'toilet paper', 'paper towels', 'laundry detergent', 'dish soap',
        'shampoo', 'toothpaste', 'soap', 'tissues', 'batteries', 'lightbulbs',
        'cat food', 'dog food', 'diapers', 'baby wipes', 'formula',
        'yogurt', 'cereal', 'oats', 'nuts', 'chocolate', 'snacks',
        'olive oil', 'salt', 'pepper', 'garlic', 'onions', 'carrots'
    ]

    variants = [
        'organic', 'unsweetened', 'low fat', 'whole wheat', 'gluten free',
        'fresh', 'frozen', 'canned', 'large', 'small', 'cheap'
    ]

    for _ in range(count):
        template = random.choice(templates)
        example = template.format(
            item=random.choice(items),
            item2=random.choice(items),
            item3=random.choice(items),
            variant=random.choice(variants)
        )
        example = add_typos(example, 0.12)
        examples.append({"text": example, "label": "SHOPPING"})

    return examples


def generate_reminder_examples(count: int) -> List[Dict]:
    """Generate REMINDER training examples."""
    examples = []

    templates = [
        "remind me to {action}",
        "call {person} {when}",
        "don't forget to {action}",
        "remind me {action}",
        "{action} {when}",
        "set a reminder to {action}",
        "remember to {action}",
        "I need to {action} {when}",
        "remind me to {action} at {time}",
        "don't forget {action}",
        "{action} before {deadline}",
        "reminder: {action}",
        "need to remember to {action}",
        "make sure to {action}",
    ]

    actions = [
        'pay the bill', 'call the dentist', 'pick up the kids',
        'take out the trash', 'water the plants', 'feed the cat',
        'check the mail', 'reply to that email', 'submit the report',
        'backup my files', 'renew the subscription', 'cancel the trial',
        'pick up dry cleaning', 'take medication', 'stretch',
        'practice guitar', 'go to the gym', 'send the invoice',
        'book the appointment', 'pay rent', 'change the password'
    ]

    people = ['mom', 'john', 'sarah', 'the dentist', 'the plumber', 'the vet', 'my boss', 'anna', 'mark']

    when_options = [
        'tomorrow', 'later', 'tonight', 'next week', 'on friday',
        'this weekend', 'in the morning', 'after work', 'before bed',
        'next monday', 'on tuesday', 'wednesday', 'at 3pm'
    ]

    times = ['5pm', '8am', '10:30', '3pm', '6:00', 'noon', '9am']
    deadlines = ['friday', 'the end of month', 'next week', 'tomorrow', '5pm', 'the weekend']

    for _ in range(count):
        template = random.choice(templates)
        example = template.format(
            action=random.choice(actions),
            person=random.choice(people),
            when=random.choice(when_options),
            time=random.choice(times),
            deadline=random.choice(deadlines)
        )
        example = add_typos(example, 0.12)
        examples.append({"text": example, "label": "REMINDER"})

    return examples


def generate_calendar_examples(count: int) -> List[Dict]:
    """Generate CALENDAR training examples."""
    examples = []

    templates = [
        "{event} {when} at {time}",
        "{event} on {day}",
        "{event} {when}",
        "meeting with {person} {when}",
        "{event} every {frequency}",
        "appointment {when} at {time}",
        "{event} {date} at {time}",
        "schedule {event} {when}",
        "{event} {when} {time}",
        "recurring: {event} {frequency}",
        "{event} departs {when}",
        "{event} starts {when}",
    ]

    events = [
        'dentist appointment', 'doctor appointment', 'team meeting', 'standup',
        'dinner', 'lunch', 'coffee', 'yoga class', 'gym session',
        'conference', 'webinar', 'interview', 'presentation',
        'flight', 'haircut', 'parent teacher meeting', 'book club',
        'project kickoff', 'team sync', 'review meeting', 'call',
        'playdate', 'party', 'wedding', 'birthday dinner'
    ]

    people = ['sarah', 'the client', 'john', 'anna', 'the team', 'my boss', 'mark', 'lisa']

    when_options = [
        'tomorrow', 'next monday', 'friday', 'next week',
        'on tuesday', 'wednesday morning', 'thursday afternoon',
        'this saturday', 'next month', 'in june', 'on the 5th'
    ]

    days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    times = ['9am', '2:30pm', '10:30', '6pm', '8:00', '11am', '3pm', '7:30pm', '14:00', '16:00']
    dates = ['march 21', 'july 3', 'june 12', 'oct 10', '12/11', 'august 5', '1st august']
    frequencies = ['monday', 'weekday', 'week', 'month', 'tuesday and thursday', 'saturday']

    for _ in range(count):
        template = random.choice(templates)
        example = template.format(
            event=random.choice(events),
            person=random.choice(people),
            when=random.choice(when_options),
            day=random.choice(days),
            time=random.choice(times),
            date=random.choice(dates),
            frequency=random.choice(frequencies)
        )
        example = add_typos(example, 0.12)
        examples.append({"text": example, "label": "CALENDAR"})

    return examples


def generate_note_examples(count: int) -> List[Dict]:
    """Generate NOTE training examples - this category needs the most work."""
    examples = []

    templates = [
        "I'm thinking about {topic}",
        "maybe {idea}",
        "note: {observation}",
        "idea: {idea}",
        "random thought: {thought}",
        "noted that {observation}",
        "brainstorm: {idea}",
        "observation: {observation}",
        "I should {goal}",
        "thinking {topic}",
        "mental note: {thought}",
        "jot: {observation}",
        "feeling {emotion} about {topic}",
        "wish list: {desire}",
        "planning {plan}",
        "remembered {thought}",
        "{observation} - worth noting",
        "I noticed {observation}",
        "had a thought about {topic}",
        "considering {idea}",
    ]

    topics = [
        'learning to cook', 'switching jobs', 'getting a new car',
        'redecorating the room', 'starting a blog', 'learning guitar',
        'improving my health', 'reading more', 'traveling',
        'the project strategy', 'better file organization', 'productivity'
    ]

    ideas = [
        'start a podcast', 'try meal prepping', 'take a course',
        'get a standing desk', 'automate the reports', 'weekend hackathon',
        'solar panels might be good', 'switch to a better app',
        'organize a team event', 'create a side project'
    ]

    observations = [
        'the car is making noise', 'traffic is worse on thursdays',
        'my focus is better mornings', 'the fridge light is flickering',
        'meetings run long without agenda', 'the plant needs less water',
        'the neighbor is loud', 'battery on laptop is dying',
        'coffee at main street is amazing', 'need better cable management'
    ]

    thoughts = [
        'try meditation for 10 days', 'book a weekend off',
        'look into co-working spaces', 'research VPN providers',
        'check warranty dates', 'experiment with new recipe',
        'probably shouldn\'t overcommit', 'learning new skill might be fun'
    ]

    emotions = [
        'good', 'excited', 'worried', 'optimistic', 'uncertain',
        'confident', 'hopeful', 'curious', 'motivated'
    ]

    desires = [
        'new laptop', 'better running shoes', 'standing desk',
        'comfortable chair', 'noise cancelling headphones', 'new sofa'
    ]

    plans = [
        'to paint the room', 'weekend trip', 'garden project',
        'home office setup', 'to reorganize closet', 'meal plan for week'
    ]

    goals = [
        'learn a new language', 'read more books', 'exercise regularly',
        'save more money', 'network more', 'improve my skills'
    ]

    for _ in range(count):
        template = random.choice(templates)
        example = template.format(
            topic=random.choice(topics),
            idea=random.choice(ideas),
            observation=random.choice(observations),
            thought=random.choice(thoughts),
            emotion=random.choice(emotions),
            desire=random.choice(desires),
            plan=random.choice(plans),
            goal=random.choice(goals)
        )
        example = add_typos(example, 0.12)
        examples.append({"text": example, "label": "NOTE"})

    return examples


def generate_quote_examples(count: int) -> List[Dict]:
    """Generate QUOTE training examples."""
    examples = []

    templates = [
        "from {source}: {content}",
        "from {source} page {page}: {content}",
        "from {source} minute {minute}: {content}",
        "from {source} chapter {chapter}: {content}",
        "{source} says: {content}",
        "quote from {source}: {content}",
        "read in {source}: {content}",
        "from {person}'s {medium}: {content}",
        "from that {medium} about {topic}: {content}",
    ]

    sources = [
        'atomic habits', 'thinking fast and slow', 'deep work', 'the mom test',
        'sapiens', 'range', 'grit', 'blink', 'drive', 'quiet', 'flow',
        'the lean startup', 'start with why', 'how to win friends',
        'huberman lab', 'lex friedman podcast', 'ted talk', 'veritasium',
        'new york times', 'economist', 'bbc documentary', 'youtube video',
        'that article', 'the lecture', 'the interview', 'the study'
    ]

    content = [
        'you do not rise to goals you fall to systems',
        'small wins compound over time',
        'focus on why not what',
        'sleep impacts memory consolidation',
        'multitasking reduces productivity',
        'consistency beats intensity',
        'automation saves time',
        'caffeine has a 5 hour half life',
        'humans cooperate in large numbers',
        'persistence beats talent',
        'depth beats shallow work',
        'breadth can beat specialization',
        'exercise improves mood',
        'reading increases vocabulary'
    ]

    people = ['sam altman', 'bill gates', 'huberman', 'james clear', 'tim ferriss']
    mediums = ['podcast', 'interview', 'talk', 'video', 'book']
    topics = ['productivity', 'sleep', 'AI', 'habits', 'learning', 'health']

    pages = ['12', '32', '45', '88', '104']
    minutes = ['5', '10', '12', '22', '33', '45', '55']
    chapters = ['1', '2', '3', '4', '5']

    for _ in range(count):
        template = random.choice(templates)
        example = template.format(
            source=random.choice(sources),
            content=random.choice(content),
            person=random.choice(people),
            medium=random.choice(mediums),
            topic=random.choice(topics),
            page=random.choice(pages),
            minute=random.choice(minutes),
            chapter=random.choice(chapters)
        )
        example = add_typos(example, 0.1)
        examples.append({"text": example, "label": "QUOTE"})

    return examples


def generate_ambiguous_examples(count: int) -> List[Dict]:
    """Generate intentionally ambiguous examples to make the model more robust."""
    examples = []

    # These are examples that could be multiple categories but have a primary intent
    ambiguous = [
        # SHOPPING with urgency that sounds like reminder
        ("buy milk before 5pm", "SHOPPING"),
        ("need to get eggs tomorrow", "SHOPPING"),
        ("pick up bread on the way home", "SHOPPING"),

        # REMINDER that mentions shopping
        ("remind me to buy groceries", "REMINDER"),
        ("don't forget shopping list", "REMINDER"),

        # BUDGET with shopping item
        ("spent 20 on milk and eggs", "BUDGET"),
        ("paid 15 for groceries", "BUDGET"),

        # CALENDAR with cost
        ("dentist appointment tuesday costs 150", "CALENDAR"),
        ("meeting at 3pm about the budget", "CALENDAR"),

        # NOTE that sounds like reminder
        ("should probably call mom", "NOTE"),
        ("thinking I need to exercise more", "NOTE"),
        ("maybe learn guitar", "NOTE"),

        # Very short ambiguous
        ("milk", "SHOPPING"),
        ("tomorrow", "REMINDER"),
        ("call john", "REMINDER"),
        ("coffee", "SHOPPING"),

        # Mixed intent - primary category first
        ("spent 50 and need to buy more", "BUDGET"),
        ("buy milk and call mom", "SHOPPING"),
        ("meeting tomorrow about groceries", "CALENDAR"),
    ]

    for text, label in ambiguous[:count]:
        text = add_typos(text, 0.15)
        examples.append({"text": text, "label": label})

    return examples


def main():
    """Generate comprehensive training dataset."""
    print("="*60)
    print("GENERATING TRAINING DATA")
    print("="*60)

    # Generate examples for each category
    # Increase NOTE examples significantly since it's the weakest
    budget_examples = generate_budget_examples(400)
    shopping_examples = generate_shopping_examples(400)
    reminder_examples = generate_reminder_examples(300)
    calendar_examples = generate_calendar_examples(300)
    note_examples = generate_note_examples(500)  # Extra for weak category
    quote_examples = generate_quote_examples(300)
    ambiguous_examples = generate_ambiguous_examples(100)

    # Combine all
    all_examples = (
        budget_examples +
        shopping_examples +
        reminder_examples +
        calendar_examples +
        note_examples +
        quote_examples +
        ambiguous_examples
    )

    # Shuffle
    random.shuffle(all_examples)

    # Split into train/test (90/10)
    split_idx = int(len(all_examples) * 0.9)
    train_examples = all_examples[:split_idx]
    test_examples = all_examples[split_idx:]

    # Print statistics
    print(f"\n📊 Generated {len(all_examples)} total examples:")
    print(f"   Training: {len(train_examples)}")
    print(f"   Test: {len(test_examples)}")
    print()

    # Count by category
    from collections import Counter
    train_counts = Counter(ex['label'] for ex in train_examples)
    print("Training distribution:")
    for label, count in sorted(train_counts.items()):
        print(f"   {label}: {count} ({count/len(train_examples)*100:.1f}%)")

    # Save to file
    output = {
        "train": train_examples,
        "test": test_examples
    }

    output_file = "training_set_v2.json"
    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"\n✅ Saved to {output_file}")
    print()
    print("Next steps:")
    print("1. Review the generated examples")
    print("2. Run: python train_classifier.py")
    print("3. Test with: python test_classifier.py")


if __name__ == "__main__":
    main()
