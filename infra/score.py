import json
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, GenerationConfig
import os

MAX_NEW_TOKENS = 5000

def init():
    global model, tokenizer

    model_dir = os.path.join(os.getenv("AZUREML_MODEL_DIR", "."), "model")

    tokenizer = AutoTokenizer.from_pretrained(model_dir)
    model = AutoModelForCausalLM.from_pretrained(
        model_dir, torch_dtype=torch.bfloat16, device_map="auto"
    )

    model.generation_config = GenerationConfig.from_pretrained(model_dir)
    model.generation_config.pad_token_id = model.generation_config.eos_token_id


def run(raw_data):
    try:
        data = json.loads(raw_data)
        messages = data.get("messages", [])

        if not messages:
            return json.dumps({"error": "No messages provided."})

        input_tensor = tokenizer.apply_chat_template(
            messages, add_generation_prompt=True, return_tensors="pt"
        ).to(model.device)

        outputs = model.generate(input_tensor, max_new_tokens=MAX_NEW_TOKENS)
        result = tokenizer.decode(outputs[0][input_tensor.shape[1]:], skip_special_tokens=True)

        return json.dumps({"response": result})
    
    except Exception as e:
        return json.dumps({"error": str(e)})
