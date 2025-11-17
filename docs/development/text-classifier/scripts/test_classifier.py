#!/usr/bin/env python3
"""Test the fine-tuned classifier interactively."""

import json
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from pathlib import Path
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np

def classify_text(text, model, tokenizer, device):
    """Classify a single text input."""
    # Tokenize
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=128)
    inputs = {k: v.to(device) for k, v in inputs.items()}

    # Predict
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        probabilities = torch.softmax(logits, dim=1)
        predicted_class = torch.argmax(probabilities, dim=1).item()
        confidence = probabilities[0][predicted_class].item()

    # Get label
    label = model.config.id2label[predicted_class]

    return label, confidence

def evaluate_on_test_set(model, tokenizer, device, test_data):
    """Evaluate model on test set and print metrics."""
    LABEL_MAP = {
        "BUDGET": 0,
        "SHOPPING": 1,
        "REMINDER": 2,
        "CALENDAR": 3,
        "NOTE": 4,
        "QUOTE": 5,
    }

    print("\n" + "="*60)
    print("EVALUATING ON TEST SET")
    print("="*60)
    print(f"📊 Processing {len(test_data)} test examples...")
    predictions = []
    true_labels = []

    # Process in batches for progress tracking
    batch_size = 20
    for i in range(0, len(test_data), batch_size):
        batch_end = min(i + batch_size, len(test_data))
        print(f"   Processing examples {i+1}-{batch_end}/{len(test_data)}...")

        for item in test_data[i:batch_end]:
            text = item["text"]
            true_label = LABEL_MAP[item["label"]]

            # Classify
            inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=128)
            inputs = {k: v.to(device) for k, v in inputs.items()}

            with torch.no_grad():
                outputs = model(**inputs)
                logits = outputs.logits
                predicted_class = torch.argmax(logits, dim=1).item()

            predictions.append(predicted_class)
            true_labels.append(true_label)

    print("   ✅ All examples processed")

    # Convert to numpy
    predictions = np.array(predictions)
    true_labels = np.array(true_labels)

    # Print results
    print("\n" + "="*60)
    print("TEST SET CLASSIFICATION REPORT")
    print("="*60)
    print(classification_report(
        true_labels,
        predictions,
        target_names=["BUDGET", "SHOPPING", "REMINDER", "CALENDAR", "NOTE", "QUOTE"]
    ))

    print("\n" + "="*60)
    print("CONFUSION MATRIX")
    print("="*60)
    print("           BUDGET  SHOPPING  REMINDER  CALENDAR  NOTE  QUOTE")
    cm = confusion_matrix(true_labels, predictions)
    for i, row in enumerate(cm):
        label = ["BUDGET", "SHOPPING", "REMINDER", "CALENDAR", "NOTE", "QUOTE"][i]
        print(f"{label:10s} {row[0]:7d} {row[1]:9d} {row[2]:9d} {row[3]:9d} {row[4]:5d} {row[5]:6d}")

    accuracy = (predictions == true_labels).mean()
    print(f"\n✅ Test Set Accuracy: {accuracy:.2%}")

def main():
    print("="*60)
    print("DISTILBERT CLASSIFIER TESTING")
    print("="*60)

    # Setup
    model_dir = Path("./distilbert-classifier")
    data_file = Path("training_set.json")

    print(f"\n📋 Configuration:")
    print(f"   Model directory: {model_dir}")
    print(f"   Data file: {data_file}")

    # Check paths exist
    print(f"\n🔍 Checking paths...")
    if not model_dir.exists():
        print(f"   ❌ Model directory not found: {model_dir}")
        print(f"   Please run train_classifier.py first!")
        return
    print(f"   ✅ Model directory found")

    if not data_file.exists():
        print(f"   ❌ Data file not found: {data_file}")
        return
    print(f"   ✅ Data file found")

    # Check device
    print(f"\n🖥️  Checking device...")
    if torch.backends.mps.is_available():
        device = torch.device("mps")
        print("   ✅ Using Apple Silicon GPU (MPS)")
    else:
        device = torch.device("cpu")
        print("   ⚠️  Using CPU")

    # Load model
    print(f"\n" + "="*60)
    print("LOADING MODEL")
    print("="*60)
    print(f"🤖 Loading tokenizer from {model_dir}...")
    try:
        tokenizer = AutoTokenizer.from_pretrained(str(model_dir))
        print("   ✅ Tokenizer loaded")
    except Exception as e:
        print(f"   ❌ Failed to load tokenizer: {e}")
        return

    print(f"\n🤖 Loading model from {model_dir}...")
    try:
        model = AutoModelForSequenceClassification.from_pretrained(str(model_dir))
        print("   ✅ Model loaded")
    except Exception as e:
        print(f"   ❌ Failed to load model: {e}")
        return

    print(f"\n   Moving model to {device}...")
    model.to(device)
    model.eval()
    print(f"   ✅ Model ready for inference")

    # Load test data
    print(f"\n" + "="*60)
    print("LOADING TEST DATA")
    print("="*60)
    print(f"📂 Reading {data_file}...")
    try:
        with open(data_file) as f:
            data = json.load(f)
        print("   ✅ JSON loaded")

        test_data = data["test"]
        print(f"   ✅ Extracted {len(test_data)} test examples")
    except Exception as e:
        print(f"   ❌ Failed to load test data: {e}")
        return

    # Evaluate on test set
    evaluate_on_test_set(model, tokenizer, device, test_data)

    print("\n" + "="*60)
    print("Interactive Classifier Test")
    print("="*60)
    print("Enter text to classify (or 'quit' to exit)")
    print("="*60 + "\n")

    # Test examples
    test_examples = [
        "spent 50 dollars at whole foods",
        "milk eggs and bread",
        "call mom tomorrow",
        "dentist appointment friday at 2pm",
        "thinking about redecorating the living room",
        "from atomic habits page 32: you do not rise to the level of your goals",
    ]

    print("Example classifications:\n")
    for text in test_examples:
        label, confidence = classify_text(text, model, tokenizer, device)
        print(f"📝 '{text}'")
        print(f"   → {label} (confidence: {confidence:.2%})\n")

    # Interactive mode
    print("\n" + "="*60)
    print("Now try your own examples:")
    print("="*60 + "\n")

    while True:
        text = input("Enter text: ").strip()

        if text.lower() in ["quit", "exit", "q"]:
            break

        if not text:
            continue

        label, confidence = classify_text(text, model, tokenizer, device)
        print(f"   → {label} (confidence: {confidence:.2%})\n")

    print("\n👋 Goodbye!")

if __name__ == "__main__":
    main()
