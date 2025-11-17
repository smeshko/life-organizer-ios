#!/usr/bin/env python3
"""Fine-tune DistilBERT for text classification."""

import json
from pathlib import Path
from sklearn.metrics import classification_report, confusion_matrix
import torch
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    DataCollatorWithPadding,
)
from datasets import Dataset
import numpy as np

# Category mapping
LABEL_MAP = {
    "BUDGET": 0,
    "SHOPPING": 1,
    "REMINDER": 2,
    "CALENDAR": 3,
    "NOTE": 4,
    "QUOTE": 5,
}
ID_TO_LABEL = {v: k for k, v in LABEL_MAP.items()}

def load_data(file_path: Path):
    """Load training data from JSON file."""
    print(f"📂 Opening file: {file_path}")

    # Try v2 first, fallback to v1
    if not file_path.exists():
        print(f"   File not found, trying training_set.json...")
        file_path = Path("training_set.json")
        if not file_path.exists():
            raise FileNotFoundError(f"Training data file not found")

    print(f"   Reading JSON data...")
    with open(file_path) as f:
        data = json.load(f)

    print(f"   Extracting train/test splits...")
    train_data = data["train"]
    test_data = data["test"]

    print(f"   ✅ Loaded {len(train_data)} training examples")
    print(f"   ✅ Loaded {len(test_data)} test examples")

    # Validate data structure
    print(f"   Validating data structure...")
    for i, item in enumerate(train_data[:3]):
        if "text" not in item or "label" not in item:
            raise ValueError(f"Invalid data structure at train index {i}: {item}")
    print(f"   ✅ Data structure validated")

    return train_data, test_data

def prepare_dataset(data, split_name):
    """Convert raw data to HuggingFace Dataset format."""
    print(f"   Converting {split_name} data to HuggingFace Dataset format...")
    print(f"   Extracting texts...")
    texts = [item["text"] for item in data]

    print(f"   Mapping labels to integers...")
    labels = []
    for i, item in enumerate(data):
        label = item["label"]
        if label not in LABEL_MAP:
            raise ValueError(f"Unknown label '{label}' at index {i}. Valid labels: {list(LABEL_MAP.keys())}")
        labels.append(LABEL_MAP[label])

    print(f"   Creating Dataset object...")
    dataset = Dataset.from_dict({"text": texts, "label": labels})
    print(f"   ✅ Created {split_name} dataset with {len(dataset)} examples")

    return dataset

def tokenize_function(examples, tokenizer):
    """Tokenize text examples."""
    return tokenizer(examples["text"], truncation=True, max_length=128)

def compute_metrics(eval_pred):
    """Compute accuracy metrics."""
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)

    accuracy = (predictions == labels).mean()
    return {"accuracy": accuracy}

def main():
    print("="*60)
    print("DISTILBERT CLASSIFIER TRAINING")
    print("="*60)

    # Setup - try v2 first
    data_file = Path("training_set_v2.json")
    if not data_file.exists():
        print("   Using training_set.json (v1)")
        data_file = Path("training_set.json")
    else:
        print("   Using training_set_v2.json (expanded)")
    output_dir = Path("./distilbert-classifier")

    print(f"\n📋 Configuration:")
    print(f"   Data file: {data_file}")
    print(f"   Output directory: {output_dir}")
    print(f"   Number of categories: 6")
    print(f"   Categories: {list(LABEL_MAP.keys())}")

    # Check for MPS (Apple Silicon GPU) support
    print(f"\n🖥️  Checking device...")
    if torch.backends.mps.is_available():
        device = "mps"
        print("   ✅ Using Apple Silicon GPU (MPS)")
    else:
        device = "cpu"
        print("   ⚠️  Using CPU (slower)")

    # Load data
    print("\n" + "="*60)
    print("STEP 1: LOADING DATA")
    print("="*60)
    train_data, test_data = load_data(data_file)

    # Prepare datasets
    print("\n" + "="*60)
    print("STEP 2: PREPARING DATASETS")
    print("="*60)
    train_dataset = prepare_dataset(train_data, "train")
    test_dataset = prepare_dataset(test_data, "test")

    # Load tokenizer and model
    print("\n" + "="*60)
    print("STEP 3: LOADING MODEL")
    print("="*60)
    print("🤖 Loading DistilBERT tokenizer...")
    print("   Model: distilbert-base-uncased")
    print("   This may take a few moments on first run (downloads ~268MB)...")
    tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased")
    print("   ✅ Tokenizer loaded")

    print("\n🤖 Loading DistilBERT model...")
    print(f"   Configuring for {len(LABEL_MAP)} labels...")
    model = AutoModelForSequenceClassification.from_pretrained(
        "distilbert-base-uncased",
        num_labels=6,
        id2label=ID_TO_LABEL,
        label2id=LABEL_MAP,
    )
    print("   ✅ Model loaded")

    # Tokenize datasets
    print("\n" + "="*60)
    print("STEP 4: TOKENIZING DATA")
    print("="*60)
    print("🔤 Tokenizing training data...")
    print("   This will convert text to tokens that the model can understand...")
    train_dataset = train_dataset.map(
        lambda x: tokenize_function(x, tokenizer), batched=True
    )
    print("   ✅ Training data tokenized")

    print("\n🔤 Tokenizing test data...")
    test_dataset = test_dataset.map(
        lambda x: tokenize_function(x, tokenizer), batched=True
    )
    print("   ✅ Test data tokenized")

    # Data collator
    print("\n" + "="*60)
    print("STEP 5: SETTING UP TRAINING")
    print("="*60)
    print("📦 Creating data collator...")
    data_collator = DataCollatorWithPadding(tokenizer=tokenizer)
    print("   ✅ Data collator created")

    # Training arguments
    print("\n⚙️  Configuring training arguments...")
    print(f"   Epochs: 3")
    print(f"   Batch size: 16")
    print(f"   Learning rate: 2e-5")
    print(f"   Device: {device}")
    training_args = TrainingArguments(
        output_dir=str(output_dir),
        num_train_epochs=3,
        per_device_train_batch_size=16,
        per_device_eval_batch_size=16,
        learning_rate=2e-5,
        weight_decay=0.01,
        eval_strategy="epoch",  # Changed from evaluation_strategy
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model="accuracy",
        push_to_hub=False,
        use_mps_device=(device == "mps"),
    )
    print("   ✅ Training arguments configured")

    # Trainer
    print("\n🎯 Initializing trainer...")
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=test_dataset,
        tokenizer=tokenizer,
        data_collator=data_collator,
        compute_metrics=compute_metrics,
    )
    print("   ✅ Trainer initialized")

    # Train
    print("\n" + "="*60)
    print("STEP 6: TRAINING MODEL")
    print("="*60)
    print("🚀 Starting training...")
    print("   This will take 5-10 minutes on M1 Max")
    print("   You'll see progress for each epoch...")
    print()
    try:
        trainer.train()
        print("\n   ✅ Training completed successfully")
    except Exception as e:
        print(f"\n   ❌ Training failed: {e}")
        raise

    # Evaluate
    print("\n" + "="*60)
    print("STEP 7: EVALUATING MODEL")
    print("="*60)
    print("📊 Running evaluation on test set...")
    try:
        predictions = trainer.predict(test_dataset)
        print("   ✅ Predictions generated")
    except Exception as e:
        print(f"   ❌ Prediction failed: {e}")
        raise

    print("   Extracting predicted labels...")
    pred_labels = np.argmax(predictions.predictions, axis=1)
    true_labels = predictions.label_ids
    print(f"   ✅ Extracted {len(pred_labels)} predictions")

    # Print results
    print("\n" + "="*60)
    print("CLASSIFICATION REPORT")
    print("="*60)
    print(classification_report(
        true_labels,
        pred_labels,
        target_names=["BUDGET", "SHOPPING", "REMINDER", "CALENDAR", "NOTE", "QUOTE"]
    ))

    print("\n" + "="*60)
    print("CONFUSION MATRIX")
    print("="*60)
    print("           BUDGET  SHOPPING  REMINDER  CALENDAR  NOTE  QUOTE")
    cm = confusion_matrix(true_labels, pred_labels)
    for i, row in enumerate(cm):
        label = ["BUDGET", "SHOPPING", "REMINDER", "CALENDAR", "NOTE", "QUOTE"][i]
        print(f"{label:10s} {row[0]:7d} {row[1]:9d} {row[2]:9d} {row[3]:9d} {row[4]:5d} {row[5]:6d}")

    # Calculate overall accuracy
    print("   Calculating accuracy...")
    accuracy = (pred_labels == true_labels).mean()
    print(f"\n✅ Overall Accuracy: {accuracy:.2%}")

    # Save model
    print("\n" + "="*60)
    print("STEP 8: SAVING MODEL")
    print("="*60)
    print(f"💾 Saving model to {output_dir}...")

    if not output_dir.exists():
        print(f"   Creating directory: {output_dir}")
        output_dir.mkdir(parents=True, exist_ok=True)

    try:
        print("   Saving model weights...")
        trainer.save_model(str(output_dir))
        print("   ✅ Model saved")

        print("   Saving tokenizer...")
        tokenizer.save_pretrained(str(output_dir))
        print("   ✅ Tokenizer saved")

        print(f"\n   Model files saved to: {output_dir.absolute()}")
    except Exception as e:
        print(f"   ❌ Save failed: {e}")
        raise

    print("\n" + "="*60)
    print("TRAINING COMPLETE")
    print("="*60)
    if accuracy >= 0.90:
        print("✅ SUCCESS! Accuracy >90%. Ready for Phase 2!")
        print("   Next step: Run test_classifier.py to test the model")
    else:
        print("⚠️  Accuracy <90%. Consider:")
        print("   - Adding more training examples")
        print("   - Checking for mislabeled data")
        print("   - Running more epochs")
    print("="*60)

if __name__ == "__main__":
    main()
