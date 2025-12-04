from openai import AzureOpenAI
from dotenv import load_dotenv
import os
import time

# Load environment variables
load_dotenv()

# Initialize Azure OpenAI client
gpt_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
gpt_deployment = os.getenv("gpt_deployment")
gpt_api_key = os.getenv("AZURE_OPENAI_KEY")

client = AzureOpenAI(
    azure_endpoint=gpt_endpoint,
    api_key=gpt_api_key,
    api_version="2024-08-01-preview"
)

def generate_response(text_input):
    """
    Generate a response using Azure OpenAI GPT model.
    
    Args:
        text_input: The user's input message
        
    Returns:
        str: The generated response
    """
    try:
        system_prompt = """You are a helpful assistant for Zava, a DIY store. 
        You help customers with DIY projects and products.
        The store specializes in paints (blue, green, and white colors), 
        wood products, and gardening supplies like trellis.
        The store is located in Miami.
        Only provide assistance with DIY-related topics."""
        
        response = client.chat.completions.create(
            model=gpt_deployment,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text_input}
            ],
            temperature=0.7,
            max_tokens=800
        )
        
        return response.choices[0].message.content
        
    except Exception as e:
        return f"Error generating response: {str(e)}"
