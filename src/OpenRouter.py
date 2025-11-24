from openai import OpenAI
import dotenv
import os
from pathlib import Path
from typing import Optional, List, Dict, Any


class OpenRouterClient:
    """OpenRouter client for LLM interactions using OpenAI SDK."""
    
    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize OpenRouter client.
        
        Args:
            api_key: Optional API key. If not provided, will load from environment.
        """
        # Load .env file from the parent directory
        env_path = Path(__file__).parent.parent / '.env'
        dotenv.load_dotenv(dotenv_path=env_path)
        
        # Get API key from parameter or environment
        self.api_key = api_key or os.getenv("OPENROUTER_KEY")
        
        if not self.api_key:
            raise ValueError(
                "OPENROUTER_KEY not found. Please set it in your .env file or pass it as a parameter."
            )
        
        # Initialize OpenAI client with OpenRouter base URL
        self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=self.api_key,
        )
        
        # List of free models to try in order (fallback mechanism)
        self.default_models = [
            "x-ai/grok-4.1-fast:free",
            "z-ai/glm-4.5-air:free",
            "google/gemma-3-27b-it:free",
            "nvidia/nemotron-nano-12b-v2-vl:free",
            "meta-llama/llama-3.2-3b-instruct:free",
            "meta-llama/llama-3.2-1b-instruct:free",
        ]
    
    async def generate(
        self,
        user_prompt: str,
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
        use_fallback: bool = True
    ) -> str:
        """
        Generate a response from the LLM.
        
        Args:
            user_prompt: The user's prompt/question
            system_prompt: Optional system prompt to set context
            model: Specific model to use. If None, will try default models with fallback
            temperature: Sampling temperature (0-2)
            max_tokens: Maximum tokens to generate
            use_fallback: If True, will try multiple models on failure
            
        Returns:
            The generated text response
            
        Raises:
            Exception: If all models fail or if use_fallback is False and the model fails
        """
        # Build messages
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": user_prompt})
        
        # Determine which models to try
        models_to_try = [model] if model and not use_fallback else self.default_models
        
        last_error = None
        
        for model_name in models_to_try:
            try:
                # Create completion
                completion = self.client.chat.completions.create(
                    model=model_name,
                    messages=messages,
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
                
                # Return the response content
                return completion.choices[0].message.content
                
            except Exception as e:
                error_type = type(e).__name__
                last_error = e
                
                # Log the error (you can replace with proper logging)
                print(f"[OpenRouter] Model {model_name} failed: {error_type}")
                
                # If authentication fails, no point trying other models
                if "AuthenticationError" in error_type:
                    raise Exception(f"Authentication failed. Check your API key: {e}")
                
                # If not using fallback, raise immediately
                if not use_fallback:
                    raise
                
                # Continue to next model
                continue
        
        # If we get here, all models failed
        raise Exception(f"All models failed. Last error: {last_error}")
    
    def generate_sync(
        self,
        user_prompt: str,
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
        use_fallback: bool = True
    ) -> str:
        """
        Synchronous version of generate method.
        
        Same parameters as generate() but runs synchronously.
        """
        # Build messages
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": user_prompt})
        
        # Determine which models to try
        models_to_try = [model] if model and not use_fallback else self.default_models
        
        last_error = None
        
        for model_name in models_to_try:
            try:
                # Create completion
                completion = self.client.chat.completions.create(
                    model=model_name,
                    messages=messages,
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
                
                # Return the response content
                return completion.choices[0].message.content
                
            except Exception as e:
                error_type = type(e).__name__
                last_error = e
                
                # Log the error
                print(f"[OpenRouter] Model {model_name} failed: {error_type}")
                
                # If authentication fails, no point trying other models
                if "AuthenticationError" in error_type:
                    raise Exception(f"Authentication failed. Check your API key: {e}")
                
                # If not using fallback, raise immediately
                if not use_fallback:
                    raise
                
                # Continue to next model
                continue
        
        # If we get here, all models failed
        raise Exception(f"All models failed. Last error: {last_error}")


# Create a singleton instance for easy import
client = OpenRouterClient()
