# Classifier Training Data Improvements - V2

## Problem Analysis

The original classifier had **91.8% accuracy** but suffered from:

1. **Low confidence scores** (30-50% for some categories)
2. **Poor NOTE category performance** (only 38% recall)
3. **Small training dataset** (only 588 examples total)
4. **Clean, unrealistic data** (not representative of real user input)

## Solution Implemented

### 1. Expanded Training Dataset

**Before:**
- Total: 686 examples (588 train, 98 test)
- NOTE: 69 examples (11.7%)
- Data was too clean and well-formatted

**After:**
- Total: 2,219 examples (1,997 train, 222 test) - **3.2x increase**
- NOTE: 459 examples (23.0%) - **6.6x increase**
- Data includes typos, informal language, and ambiguous cases

### 2. Training Data Features

The new dataset (`training_set_v2.json`) includes:

#### Realistic Variations
- **Typos and misspellings** (10-15% of examples)
  - "tommorow", "recieve", "definately"
  - Keyboard mistakes: "teh", "adn", "wiht"

#### Informal Language
- Filler words: "umm", "like", "I think"
- Uncertainty: "maybe", "around", "not sure"
- Casual phrasing: "grab some", "pick up", "get me"

#### Ambiguous Cases
- Very short inputs: "milk", "coffee", "tomorrow"
- Mixed intent: "spent 50 and need to buy milk"
- Boundary cases between categories

####  Category-Specific Improvements

**BUDGET (400 examples)**
- Wide range of amounts: $5 - $5000
- Multiple currencies: USD, EUR, LEV, $, €
- Both expenses and income
- Vague amounts: "some money", "a bit"

**SHOPPING (400 examples)**
- Bare items: "milk"
- Complex lists: "milk eggs bread cheese"
- Variants: "organic", "unsweetened", "large"
- Different phrasings: "buy", "get", "need", "grab", "pick up"

**REMINDER (300 examples)**
- Various time references
- With/without explicit "remind me"
- Action-focused vs time-focused
- Different urgency levels

**CALENDAR (300 examples)**
- Many date/time formats
- Recurring events
- Event types with times
- Informal scheduling language

**NOTE (500 examples - BOOSTED)**
- Ideas and observations
- Random thoughts
- Planning notes
- Emotional reflections
- Brainstorming content
- Clearly distinguished from reminders

**QUOTE (300 examples)**
- Books, podcasts, articles
- With/without source attribution
- Page numbers, timestamps
- Various citation styles

#### Edge Cases (100 examples)
- Intentionally ambiguous examples
- Helps model learn category boundaries
- Reduces overconfidence on unclear inputs

### 3. Expected Improvements

After retraining, we expect:

**Accuracy**: 92-95% (up from 91.8%)
**Confidence scores**:
- BUDGET: 70-90% (was 85%)
- SHOPPING: 65-85% (was 76%)
- REMINDER: 60-80% (was 50%) ⬆️
- CALENDAR: 75-90% (was 73%)
- NOTE: 55-75% (was 31%) ⬆️⬆️
- QUOTE: 70-85% (was 65%)

**NOTE category recall**: 75-85% (up from 38%) ⬆️⬆️

### 4. Training Parameters

```python
epochs: 5
learning_rate: 2e-5
batch_size: 16
max_length: 128
model: distilbert-base-uncased
```

These parameters work well for ~2000 examples. Could increase to 8-10 epochs with larger datasets.

## Files Modified/Created

1. **generate_training_data.py** - Data generation script
2. **training_set_v2.json** - New expanded dataset
3. **train_classifier.py** - Updated to use new data
4. **This document** - Documentation

## Next Steps

### After Training Completes:

1. **Test the new model**
   ```bash
   cd docs/planning
   python test_classifier.py
   ```

2. **Convert to CoreML**
   ```bash
   python convert_to_coreml.py
   ```

3. **Copy to Xcode project**
   ```bash
   cp TextClassifier.mlpackage ../../LifeOrganizeriOS/Resources/
   ```

4. **Test in the app**
   - Build and run
   - Try various inputs in the test view
   - Verify confidence scores are 60-90%

### If Still Low Confidence:

1. **Lower the fallback threshold**
   - Edit `ClassificationResult.swift`
   - Change from 0.7 to 0.5 or 0.6

2. **Add more training data**
   - Run `generate_training_data.py` again with higher counts
   - Focus on problem categories

3. **Adjust training parameters**
   - Increase epochs to 8-10
   - Lower learning rate to 1e-5
   - Add gradient accumulation

## Monitoring Performance

### Key Metrics to Watch:

- **Overall accuracy**: Should be 92-95%
- **Per-category F1 scores**: Should all be >0.85
- **Confidence scores**: Average should be 70-80%
- **NOTE category**: Most important - watch recall and confidence

### Test Examples to Try:

```
"spent 50 bucks" → BUDGET (high confidence)
"buy milk" → SHOPPING (medium-high confidence)
"call mom tomorrow" → REMINDER (medium confidence)
"meeting at 3pm" → CALENDAR (high confidence)
"thinking about learning guitar" → NOTE (medium confidence)
"from atomic habits: you fall to your systems" → QUOTE (high confidence)
```

## Future Enhancements

1. **Data augmentation pipeline**
   - Automatic paraphrasing
   - Back-translation for variety
   - Synonym replacement

2. **Active learning**
   - Log low-confidence predictions
   - Manually review and add to training set
   - Continuous improvement

3. **Ensemble approach**
   - Combine ML model with rule-based heuristics
   - Boost confidence on clear signals (currency → BUDGET)

4. **User feedback loop**
   - Allow users to correct classifications
   - Feed corrections back into training data

## Summary

The expanded training dataset addresses all major weaknesses:
- ✅ 3.2x more training data
- ✅ 6.6x more NOTE examples
- ✅ Realistic typos and informal language
- ✅ Ambiguous edge cases
- ✅ Better category distribution

This should significantly improve confidence scores and overall reliability.
