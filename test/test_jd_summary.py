"""
Test script for Job Description Summarization
This demonstrates how to use the summarize_jd function to get a structured summary of a job description.
"""

import asyncio
import sys
import json
from pathlib import Path

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from OpenRouter import client
from ExtractLLM import summarize_jd


# Sample job description for testing
SAMPLE_JD = """
Senior Full-Stack Developer

Company: TechVision Solutions
Location: Ho Chi Minh City, Vietnam (Hybrid)
Employment Type: Full-time

About the Role:
We are seeking an experienced Senior Full-Stack Developer to join our growing engineering team. 
You will be responsible for designing, developing, and maintaining scalable web applications 
that serve millions of users worldwide.

Key Responsibilities:
- Design and develop robust, scalable web applications using modern technologies
- Lead technical discussions and provide mentorship to junior developers
- Collaborate with product managers and designers to deliver high-quality features
- Write clean, maintainable code following best practices
- Participate in code reviews and contribute to technical documentation
- Optimize application performance and ensure security best practices

Requirements:
- 5+ years of experience in full-stack web development
- Strong proficiency in JavaScript/TypeScript, React, and Node.js
- Experience with relational databases (PostgreSQL, MySQL) and NoSQL databases (MongoDB)
- Solid understanding of RESTful APIs and microservices architecture
- Experience with Docker, Kubernetes, and CI/CD pipelines
- Strong problem-solving skills and attention to detail
- Excellent communication skills in English
- Bachelor's degree in Computer Science or related field

Nice to Have:
- Experience with cloud platforms (AWS, GCP, or Azure)
- Knowledge of GraphQL
- Experience with Agile/Scrum methodologies
- Contributions to open-source projects

Benefits:
- Competitive salary: $2,000 - $3,500 USD/month
- Health insurance and annual health check-up
- 15 days of annual leave
- Professional development opportunities
- Modern office with free snacks and drinks
- Team building activities and company trips
- Flexible working hours
"""


async def main():
    """Main function to test JD summarization."""
    print("=" * 80)
    print("Job Description Summarization Test")
    print("=" * 80)
    print("\n📄 Original Job Description:")
    print("-" * 80)
    print(SAMPLE_JD)
    print("-" * 80)
    
    print("\n🤖 Processing with AI...")
    print("⏳ This may take a few seconds...\n")
    
    try:
        # Call the summarize_jd function
        result = await summarize_jd(client, SAMPLE_JD)
        
        print("=" * 80)
        print("✅ Summary Result (JSON Format)")
        print("=" * 80)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        print("=" * 80)
        
        # Display formatted output
        if "error" not in result:
            print("\n📊 Formatted Summary:")
            print("-" * 80)
            print(f"🏢 Job Title: {result.get('jobTitle', 'N/A')}")
            print(f"🏭 Company: {result.get('company', 'N/A')}")
            print(f"📍 Location: {result.get('location', 'N/A')}")
            print(f"💼 Employment Type: {result.get('employmentType', 'N/A')}")
            print(f"📈 Experience Level: {result.get('experienceLevel', 'N/A')}")
            print(f"💰 Salary Range: {result.get('salaryRange', 'N/A')}")
            
            print(f"\n📝 Summary:")
            print(f"   {result.get('summary', 'N/A')}")
            
            print(f"\n🎯 Key Responsibilities:")
            for i, resp in enumerate(result.get('keyResponsibilities', []), 1):
                print(f"   {i}. {resp}")
            
            print(f"\n✅ Key Requirements:")
            for i, req in enumerate(result.get('keyRequirements', []), 1):
                print(f"   {i}. {req}")
            
            print(f"\n🎁 Benefits:")
            for i, benefit in enumerate(result.get('benefits', []), 1):
                print(f"   {i}. {benefit}")
            
            print("-" * 80)
        else:
            print(f"\n❌ Error occurred: {result.get('error')}")
            if 'raw_output' in result:
                print(f"Raw output: {result['raw_output']}")
    
    except Exception as e:
        print(f"\n❌ An error occurred: {str(e)}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    # Run the async main function
    asyncio.run(main())
