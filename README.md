# OpenRouter API Test Project

A simple Python project to test calling the OpenRouter API using the official OpenAI library. It also includes a Streamlit web app to analyze CVs (PDF) and display extracted information as JSON.

## Project Structure

```
ai/
├── src/
│   ├── main.py          # CLI script to test OpenRouter API
│   └── app.py           # Streamlit app for CV analysis
├── tests/               # Test directory (for future tests)
├── requirements.txt     # Python dependencies
├── .env.example         # Example environment file
└── README.md            # This file
```

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Get OpenRouter API Key

1. Visit [OpenRouter](https://openrouter.ai/)
2. Sign up for an account
3. Go to [API Keys](https://openrouter.ai/keys)
4. Create a new API key

### 3. Configure Environment

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and add your OpenRouter API key:
   ```
   OPENROUTER_API_KEY=your_actual_api_key_here
   ```

### 4. Run the CLI Test

```bash
python src/main.py
```

### 5. Run the Streamlit Web App

```bash
streamlit run src/app.py
```

Then open the displayed local URL in your browser. In the app:

1. Upload a CV PDF file
2. Click "Analyze CV"
3. View the extracted JSON on the page

```

## What the Script Does

The `main.py` script:

1. Loads your API key from the `.env` file
2. Initializes the OpenAI client with OpenRouter's base URL
3. Sends a test message to the GPT-4o model via OpenRouter
4. Prints the response along with usage information

## Example Output

```
Sending message: Hello! Can you tell me a short joke?
--------------------------------------------------
Response from OpenRouter API:
Why don't scientists trust atoms? Because they make up everything!
--------------------------------------------------
Model used: openai/gpt-4o
Tokens used: 45
```

## Available Models

You can change the model in `src/main.py` or `src/app.py` by modifying the `model` parameter. Some popular models available on OpenRouter:

- `openai/gpt-4o`
- `openai/gpt-4o-mini`
- `anthropic/claude-3.5-sonnet`
- `google/gemini-pro-1.5`
- `meta-llama/llama-3.1-405b-instruct`

## Troubleshooting

- **API Key Error**: Make sure your `.env` file exists and contains a valid `OPENROUTER_API_KEY`
- **Network Error**: Check your internet connection and OpenRouter service status
- **Model Error**: Verify the model name is correct and available on OpenRouter

## Dependencies

- `openai>=1.0.0`: Official OpenAI Python library
- `python-dotenv>=1.0.0`: For loading environment variables from .env files
- `streamlit>=1.37.0`: Web UI framework
- `PyPDF2>=3.0.0`: PDF text extraction
