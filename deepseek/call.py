import requests

endpoint_url = "https://deepseek-ep.westeurope.inference.ml.azure.com/score"
api_key = "xxx"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

payload = {
    "messages": [{"role": "user", "content": "Who are you?"}]
}

response = requests.post(endpoint_url, headers=headers, json=payload, timeout=60)

print(response.text)
