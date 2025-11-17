#!/usr/bin/env python3
"""Convert fine-tuned DistilBERT model to Core ML format for iOS deployment."""

import coremltools as ct
from pathlib import Path
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import numpy as np

def main():
    print("="*60)
    print("CONVERTING DISTILBERT TO CORE ML")
    print("="*60)

    # Paths
    model_dir = Path("./distilbert-classifier")
    output_path = Path("./TextClassifier.mlpackage")

    print(f"\n📋 Configuration:")
    print(f"   Input model: {model_dir}")
    print(f"   Output model: {output_path}")

    # Check model exists
    print(f"\n🔍 Checking model directory...")
    if not model_dir.exists():
        print(f"   ❌ Model directory not found: {model_dir}")
        print(f"   Please run train_classifier.py first!")
        return
    print(f"   ✅ Model directory found")

    # Load model and tokenizer
    print(f"\n" + "="*60)
    print("STEP 1: LOADING PYTORCH MODEL")
    print("="*60)
    print(f"🤖 Loading tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(str(model_dir))
    print(f"   ✅ Tokenizer loaded")

    print(f"\n🤖 Loading model...")
    model = AutoModelForSequenceClassification.from_pretrained(str(model_dir))
    model.eval()
    print(f"   ✅ Model loaded")
    print(f"   Categories: {model.config.id2label}")

    # Create example input for tracing
    print(f"\n" + "="*60)
    print("STEP 2: PREPARING FOR CONVERSION")
    print("="*60)
    print(f"📝 Creating example input for tracing...")

    example_text = "spent 50 dollars at whole foods"
    example_input = tokenizer(
        example_text,
        return_tensors="pt",
        padding="max_length",
        max_length=128,
        truncation=True
    )

    print(f"   Example text: '{example_text}'")
    print(f"   Input shape: {example_input['input_ids'].shape}")
    print(f"   ✅ Example input created")

    # Trace the model
    print(f"\n" + "="*60)
    print("STEP 3: TRACING MODEL")
    print("="*60)
    print(f"🔄 Converting PyTorch model to TorchScript...")

    # Create a wrapper that returns only logits (not a dict)
    class ModelWrapper(torch.nn.Module):
        def __init__(self, model):
            super().__init__()
            self.model = model

        def forward(self, input_ids, attention_mask):
            outputs = self.model(input_ids=input_ids, attention_mask=attention_mask)
            return outputs.logits

    print(f"   Creating model wrapper to extract logits...")
    wrapped_model = ModelWrapper(model)
    wrapped_model.eval()

    print(f"   Tracing wrapped model...")
    with torch.no_grad():
        traced_model = torch.jit.trace(
            wrapped_model,
            (example_input['input_ids'], example_input['attention_mask']),
            strict=False
        )

    print(f"   ✅ Model traced successfully")

    # Convert to Core ML
    print(f"\n" + "="*60)
    print("STEP 4: CONVERTING TO CORE ML")
    print("="*60)
    print(f"🍎 Converting to Core ML format...")
    print(f"   This may take a few minutes...")

    # Define input types
    input_ids_input = ct.TensorType(
        name="input_ids",
        shape=(1, 128),
        dtype=np.int32
    )
    attention_mask_input = ct.TensorType(
        name="attention_mask",
        shape=(1, 128),
        dtype=np.int32
    )

    # Define output type with explicit name
    logits_output = ct.TensorType(
        name="logits",
        dtype=np.float16
    )

    # Convert
    mlmodel = ct.convert(
        traced_model,
        inputs=[input_ids_input, attention_mask_input],
        outputs=[logits_output],
        minimum_deployment_target=ct.target.iOS16,
        compute_precision=ct.precision.FLOAT16,  # Use FP16 for smaller size
    )

    print(f"   ✅ Conversion complete")

    # Set metadata
    print(f"\n" + "="*60)
    print("STEP 5: ADDING METADATA")
    print("="*60)
    print(f"📋 Setting model metadata...")

    mlmodel.author = "Life Organizer"
    mlmodel.license = "Private"
    mlmodel.short_description = "Text classification model for categorizing user input"
    mlmodel.version = "1.0"

    # Add class labels
    mlmodel.user_defined_metadata["classes"] = str(model.config.id2label)

    print(f"   ✅ Metadata added")

    # Save
    print(f"\n" + "="*60)
    print("STEP 6: SAVING CORE ML MODEL")
    print("="*60)
    print(f"💾 Saving to {output_path}...")

    mlmodel.save(str(output_path))

    print(f"   ✅ Model saved successfully")

    # Print model info
    print(f"\n" + "="*60)
    print("MODEL INFORMATION")
    print("="*60)
    print(f"📊 Model details:")
    print(f"   Input: input_ids [1, 128], attention_mask [1, 128]")
    print(f"   Output: logits [1, {len(model.config.id2label)}]")
    print(f"   Categories: {len(model.config.id2label)}")
    print(f"   Precision: FLOAT16")
    print(f"   Min iOS: 16.0")

    # Estimate size
    import os
    if output_path.exists():
        size_mb = sum(f.stat().st_size for f in output_path.rglob('*')) / (1024 * 1024)
        print(f"   Size: {size_mb:.1f} MB")

    print(f"\n" + "="*60)
    print("CONVERSION COMPLETE")
    print("="*60)
    print(f"✅ Core ML model ready for iOS!")
    print(f"   Next steps:")
    print(f"   1. Drag {output_path} into your Xcode project")
    print(f"   2. Create a Swift wrapper for tokenization + inference")
    print(f"   3. Test on device")
    print("="*60)

if __name__ == "__main__":
    main()
