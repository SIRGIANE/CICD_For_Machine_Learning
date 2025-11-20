import gradio as gr
import skops.io as sio

# Load the scikit-learn pipeline and model
# First get the untrusted types to see what needs to be trusted
untrusted_types = sio.get_untrusted_types(file="Model/drug_pipeline.skops")
print(f"Untrusted types found: {untrusted_types}")

# Load with the specific trusted types (review these types before trusting them)
pipe = sio.load("Model/drug_pipeline.skops", trusted=untrusted_types)


def predict_drug(age, sex, blood_pressure, cholesterol, na_to_k_ratio):
    """Predict drugs based on patient features.

    Args:
        age (int): Age of patient
        sex (str): Sex of patient 
        blood_pressure (str): Blood pressure level
        cholesterol (str): Cholesterol level
        na_to_k_ratio (float): Ratio of sodium to potassium in blood

    Returns:
        str: Predicted drug label
    """
    features = [age, sex, blood_pressure, cholesterol, na_to_k_ratio]
    predicted_drug = pipe.predict([features])[0]

    label = f"Predicted Drug: {predicted_drug}"
    return label


# Define input components
inputs = [
    gr.Slider(15, 74, step=1, label="Age", value=30),
    gr.Radio(["M", "F"], label="Sex", value="M"),
    gr.Radio(["HIGH", "LOW", "NORMAL"], label="Blood Pressure", value="HIGH"),
    gr.Radio(["HIGH", "NORMAL"], label="Cholesterol", value="NORMAL"),
    gr.Slider(6.2, 38.2, step=0.1, label="Na_to_K Ratio", value=15.4),
]

# Define output components
outputs = [gr.Label(num_top_classes=5)]

# Sample inputs for easy testing
examples = [
    [30, "M", "HIGH", "NORMAL", 15.4],
    [35, "F", "LOW", "NORMAL", 8],
    [50, "M", "HIGH", "HIGH", 34],
]

# App metadata
title = "💊 Drug Classification"
description = """
Enter patient details to predict the most suitable drug type.
This ML model analyzes age, sex, blood pressure, cholesterol levels, and sodium-to-potassium ratio.
"""
article = """
### About This App
This app is part of the **Beginner's Guide to CI/CD for Machine Learning**. 
It demonstrates how to automate training, evaluation, and deployment of ML models to Hugging Face using GitHub Actions.

### Model Information
- **Algorithm**: Scikit-learn pipeline with preprocessing and classification
- **Features**: Age, Sex, Blood Pressure, Cholesterol, Na/K Ratio
- **Output**: Predicted drug type

---
Built with ❤️ using Gradio and automated with GitHub Actions
"""

# Create and launch the Gradio interface
demo = gr.Interface(
    fn=predict_drug,
    inputs=inputs,
    outputs=outputs,
    examples=examples,
    title=title,
    description=description,
    article=article,
    theme=gr.themes.Soft(),
    allow_flagging="never",
)

if __name__ == "__main__":
    demo.launch()