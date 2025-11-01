import requests

url = "http://127.0.0.1:8000/match/multiple"
files = [
    ('jd', open('/home/thanhhuy/Downloads/jobdes.pdf', 'rb')),
    ('cvs', open('/home/thanhhuy/Downloads/java-developer-resume-example.pdf', 'rb')),
    ('cvs', open('/home/thanhhuy/Downloads/junior-web-developer-resume-example.pdf', 'rb'))
]

response = requests.post(url, files=files)
print(response.json())
