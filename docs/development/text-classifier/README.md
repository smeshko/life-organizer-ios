# Text Classifier - Training & Deployment Guide

On-device text classification using DistilBERT for categorizing user input into 6 categories.

## Overview

**Model**: DistilBERT (distilbert-base-uncased)
**Categories**: BUDGET, SHOPPING, REMINDER, CALENDAR, NOTE, QUOTE
**Target Accuracy**: >90%
**Model Size**: ~127MB (CoreML with FP16)
**Inference Time**: <100ms on device

### Why DistilBERT?
- Mature CoreML conversion tooling
- Apple Neural Engine optimization (10x faster, 14x less memory)
- Well-supported by HuggingFace Transformers
- 97% of BERT performance, 60% faster

## Quick Start

### Prerequisites
```bash
pip install transformers datasets torch accelerate scikit-learn coremltools
```

### 1. Generate Training Data
Use `generate_training_data.py` to create synthetic training examples:
```bash
python generate_training_data.py
```

This creates a `training_set_v2.json` file with ~2,200 examples including:
- Realistic typos and informal language
- Various phrasings and edge cases
- Balanced distribution across all categories

See `training_data_prompts.md` for detailed guidance on data generation.

### 2. Train the Model
```bash
python train_classifier.py
```

**Training parameters:**
- Epochs: 5
- Learning rate: 2e-5
- Batch size: 16
- Max length: 128 tokens
- Device: MPS (Apple Silicon GPU) or CPU

**Expected time**: 5-10 minutes on M1 Max

**Output**: `distilbert-classifier/` directory containing the fine-tuned model

### 3. Test the Model
```bash
python test_classifier.py
```

Tests the model interactively and shows confidence scores.

**Success criteria:**
- Overall accuracy >90%
- Per-category F1 scores >0.85
- Confidence scores >70% for clear examples

### 4. Convert to CoreML
```bash
python convert_to_coreml.py
```

**Output**: `TextClassifier.mlpackage` (~127MB with FP16 precision)

**Conversion details:**
- Target: iOS 16+
- Precision: FLOAT16 for smaller size
- Inputs: `input_ids` [1, 128], `attention_mask` [1, 128]
- Output: `logits` [1, 6]

### 5. Deploy to iOS
1. Copy `TextClassifier.mlpackage` to `LifeOrganizeriOS/Resources/`
2. Use `TextClassifier.swift` as reference for integration
3. Build and test on device

## Scripts Reference

### `generate_training_data.py`
Generates synthetic training data with realistic variations:
- Creates ~2,200 examples across 6 categories
- Includes typos, informal language, edge cases
- Balanced distribution with focus on difficult categories
- Output: `training_set_v2.json`

### `train_classifier.py`
Fine-tunes DistilBERT on training data:
- Loads training data from JSON
- Trains for 5 epochs with early stopping
- Evaluates on test set (20% holdout)
- Saves model to `distilbert-classifier/`
- Prints classification report and confusion matrix

### `test_classifier.py`
Interactive testing of trained model:
- Runs example classifications
- Interactive mode for custom inputs
- Shows category and confidence scores
- Useful for validating before CoreML conversion

### `convert_to_coreml.py`
Converts PyTorch model to CoreML:
- Traces the model with TorchScript
- Converts to CoreML with coremltools
- Applies FP16 quantization
- Adds metadata and class labels
- Output: `TextClassifier.mlpackage`

### `inspect_model.py`
Utility for examining model details:
- Prints model architecture
- Shows layer information
- Displays config and labels

## Retraining Workflow

### When to Retrain
- New categories added
- Accuracy drops in production
- User feedback indicates misclassifications
- Quarterly maintenance updates

### Steps
1. **Collect new data**: Add examples to training set or regenerate
2. **Train**: Run `train_classifier.py`
3. **Validate**: Check accuracy >90%, review confusion matrix
4. **Convert**: Run `convert_to_coreml.py`
5. **Test on device**: Verify performance and accuracy
6. **Deploy**: Replace old model in iOS project

### Training Data Best Practices
- **Diversity by design**: Cover various phrasings, lengths, and edge cases
- **Realistic variations**: Include typos, filler words, informal language
- **Balanced distribution**: Ensure all categories well-represented
- **Edge cases**: Add boundary examples between categories
- **Quality over quantity**: 50-100 good examples per category beats 500 noisy ones

## Training Data Insights

### Current Dataset (v2)
- **Total**: 2,219 examples (1,997 train, 222 test)
- **BUDGET**: 400 examples (expenses, income, savings)
- **SHOPPING**: 400 examples (items, lists, specific requests)
- **REMINDER**: 300 examples (tasks, todos, time references)
- **CALENDAR**: 300 examples (events, appointments, meetings)
- **NOTE**: 500 examples (ideas, observations, reflections) - BOOSTED
- **QUOTE**: 300 examples (books, podcasts, articles)
- **Edge cases**: 100 examples (ambiguous, boundary cases)

### Key Improvements from v1
- 3.2x more training data (686 → 2,219)
- 6.6x more NOTE examples (69 → 459)
- Realistic typos and informal language
- Better category distribution
- Confidence scores improved: NOTE 31% → 55-75%

### Expected Performance
- **Accuracy**: 92-95%
- **BUDGET**: 70-90% confidence
- **SHOPPING**: 65-85% confidence
- **REMINDER**: 60-80% confidence
- **CALENDAR**: 75-90% confidence
- **NOTE**: 55-75% confidence (most challenging)
- **QUOTE**: 70-85% confidence

## iOS Integration

### Basic Usage
```swift
let classifier = try TextClassifier()
let result = try classifier.classify("spent 50 dollars at whole foods")
print("Category: \(result.category)")
print("Confidence: \(result.confidence)")
```

### Confidence Threshold Strategy
```swift
let confidenceThreshold: Float = 0.7

func classifyWithFallback(_ text: String) -> Category? {
    guard let result = try? classifier.classify(text) else {
        return nil  // Classification failed - use backend
    }

    if result.confidence > confidenceThreshold {
        return result.category  // High confidence - use on-device
    } else {
        return nil  // Low confidence - send to backend
    }
}
```

### Performance Targets
- ⏱️ Inference time: <100ms
- 💾 Memory usage: <50MB
- 🎯 Accuracy: Matches test set (~92%)

## Troubleshooting

### Issue: Accuracy <90%
**Solutions:**
1. Check confusion matrix to identify weak categories
2. Add more targeted examples for confused categories
3. Increase training epochs to 8-10
4. Lower learning rate to 1e-5

### Issue: Low confidence scores
**Solutions:**
1. Lower confidence threshold (0.7 → 0.5)
2. Add more training data for low-confidence categories
3. Review edge cases and boundary examples

### Issue: Model file too large
**Solution:** Use INT8 quantization instead of FP16
```python
# In convert_to_coreml.py:
compute_precision=ct.precision.INT8  # ~65MB instead of 127MB
```

### Issue: Inference too slow
**Solutions:**
1. Enable Neural Engine: `configuration.computeUnits = .all`
2. Reduce max_length: 128 → 64 tokens
3. Verify using Neural Engine (not CPU fallback)

### Issue: Poor accuracy on device
**Common causes:**
1. Tokenization mismatch (most common)
2. Input preprocessing differences
3. Model conversion issues

**Debug:** Compare tokenizer output between Python and Swift

## Category Definitions

### BUDGET
Expenses, income, savings transactions
- Examples: "spent 50 dollars", "got paid 2400", "transferred to savings"
- Sub-categories: 16 expense types, 4 income types, 3 savings types

### SHOPPING
Shopping lists, items to buy
- Examples: "milk eggs bread", "buy coffee", "pick up groceries"
- Various phrasings: buy, get, need, grab, pick up

### REMINDER
Tasks, todos, things to remember
- Examples: "call mom tomorrow", "don't forget passport", "pay water bill"
- Time references: tomorrow, later, next week, Friday

### CALENDAR
Events, appointments, meetings with specific times
- Examples: "dentist at 2pm", "meeting tomorrow 10:30", "dinner friday 7pm"
- Must include time/date reference

### NOTE
Personal notes, ideas, observations, catch-all
- Examples: "thinking about learning guitar", "car making weird noise"
- Brain dumps, reflections, vague plans

### QUOTE
Quotes from books, videos, podcasts, articles
- Examples: "from atomic habits page 32: you fall to your systems"
- Usually prefixed with source

## Files Overview

**Scripts:**
- `generate_training_data.py` - Generate synthetic training data
- `train_classifier.py` - Train DistilBERT model
- `test_classifier.py` - Test model interactively
- `convert_to_coreml.py` - Convert to CoreML format
- `inspect_model.py` - Examine model details

**Documentation:**
- `README.md` - This file
- `training_data_prompts.md` - Detailed prompts for data generation
- `initial-prd.md` - Original product requirements

**Reference:**
- `TextClassifier.swift` - iOS integration example

**Generated (not in repo):**
- `training_set_v2.json` - Training data (regenerate as needed)
- `distilbert-classifier/` - Trained model (regenerate from training)
- `TextClassifier.mlpackage` - CoreML model (in iOS Resources, regenerate from model)

## Architecture Notes

### Model Pipeline
1. **User input** → Raw text
2. **Tokenizer** → Token IDs + attention mask
3. **DistilBERT** → Category logits
4. **Softmax** → Category probabilities
5. **Argmax** → Top category + confidence

### On-Device vs Backend
- **High confidence (>70%)**: Use on-device classification
- **Low confidence (<70%)**: Send to backend with fallback prompt
- Backend can override if needed based on extraction results

### Cost Savings
- Original: 10K line monolithic prompt → $1,642/year
- New: Category-specific 2K line prompts → $255/year
- **Savings**: ~5x cost reduction

## Resources

- [HuggingFace DistilBERT](https://huggingface.co/distilbert-base-uncased)
- [Apple CoreML BERT Guide](https://apple.github.io/coremltools/docs-guides/)
- [HuggingFace Text Classification](https://huggingface.co/docs/transformers/tasks/sequence_classification)
- [Apple Neural Engine Transformers](https://machinelearning.apple.com/research/neural-engine-transformers)

## Version History

- **v2**: Expanded training data (2,219 examples), improved NOTE category, better confidence
- **v1**: Initial implementation (686 examples), 91.8% accuracy
