from transformers import AutoModelForCausalLM, AutoTokenizer, GenerationConfig

model_name = "deepseek-ai/deepseek-llm-7b-chat"
model = AutoModelForCausalLM.from_pretrained(model_name)
model.generation_config = GenerationConfig.from_pretrained(model_name)
model.generation_config.pad_token_id = model.generation_config.eos_token_id
tokenizer = AutoTokenizer.from_pretrained(model_name)

model.save_pretrained("./model")
tokenizer.save_pretrained("./model")
