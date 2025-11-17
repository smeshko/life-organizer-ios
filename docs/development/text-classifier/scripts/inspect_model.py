#!/usr/bin/env python3
"""
Inspect CoreML model to find output names
"""
import coremltools as ct

# Load the model
model_path = "/Users/A1E6E98/Developer/Projects/life-organizer/LifeOrganizeriOS/LifeOrganizeriOS/Resources/TextClassifier.mlpackage"
model = ct.models.MLModel(model_path)

# Print model spec
print("="*60)
print("MODEL INPUTS")
print("="*60)
spec = model.get_spec()
for input_desc in spec.description.input:
    print(f"Name: {input_desc.name}")
    print(f"Type: {input_desc.type}")
    print()

print("="*60)
print("MODEL OUTPUTS")
print("="*60)
for output_desc in spec.description.output:
    print(f"Name: {output_desc.name}")
    print(f"Type: {output_desc.type}")
    print()
