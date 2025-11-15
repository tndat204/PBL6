# import requests

# url = "http://127.0.0.1:8000/match/multiple"
# files = [
#     ('jd', open('/home/thanhhuy/Downloads/jobdes.pdf', 'rb')),
#     ('cvs', open('/home/thanhhuy/Downloads/java-developer-resume-example.pdf', 'rb')),
#     ('cvs', open('/home/thanhhuy/Downloads/junior-web-developer-resume-example.pdf', 'rb'))
# ]

# response = requests.post(url, files=files)
# print(response.json())

import datetime
from langchain_core.tools import tool
from pydantic import BaseModel
from src.LangchainClient import client
import asyncio

class ResponseFormat(BaseModel):
    answer: str
    question: str

@tool
def now_iso():
    """Get the current time in ISO format"""
    return datetime.datetime.now().isoformat()

async def main():
    res = await client.generate(
        system_prompt="Bạn là một trợ lý tư vấn viên hữu ích và chính xác.",
        user_prompt="Bây giờ là mấy giờ và ngày mấy?",
        tools=[now_iso],
    )
    print(res)

# chạy async
asyncio.run(main())

