import http.client

conn = http.client.HTTPSConnection("irctc1.p.rapidapi.com")

headers = {
    'x-rapidapi-key': "59538060bfmshf85bcc9e2e51212p1ce010jsn4f780c0cac7d",
    'x-rapidapi-host': "irctc1.p.rapidapi.com"
}

conn.request("GET", "/api/v1/searchTrain?query=19038", headers=headers)

res = conn.getresponse()
data = res.read()

print(data.decode("utf-8"))