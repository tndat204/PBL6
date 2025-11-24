#!/usr/bin/env python3
"""
Generate a secure API key for your CV-JD Matching API
"""
import secrets

def generate_api_key():
    """Generate a secure random API key."""
    # Generate a URL-safe random string
    random_part = secrets.token_urlsafe(32)
    
    # Add a prefix for easy identification
    api_key = f"sk_{random_part}"
    
    return api_key


if __name__ == "__main__":
    print("=" * 60)
    print("🔐 API Key Generator")
    print("=" * 60)
    print()
    
    # Generate key
    api_key = generate_api_key()
    
    print("Your new API key:")
    print()
    print(f"  {api_key}")
    print()
    print("=" * 60)
    print()
    print("📝 Next steps:")
    print()
    print("1. Copy the API key above")
    print("2. Add it to your .env file:")
    print(f"   API_SECRET_KEY={api_key}")
    print()
    print("3. Restart your API server:")
    print("   uvicorn src.api:app --reload")
    print()
    print("4. Use this key in your API requests:")
    print("   -H 'X-API-Key: <your-key-here>'")
    print()
    print("=" * 60)
    print()
    print("⚠️  IMPORTANT: Keep this key secret!")
    print("   - Never commit it to Git")
    print("   - Don't share it publicly")
    print("   - Store it securely")
    print()
