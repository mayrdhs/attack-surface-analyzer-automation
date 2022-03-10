import json

file = open('result.json')
data = json.load(file)

filtered_data = []

for j in data['results']:
    for k in data['results'][j]:
        if k['Analysis'] == 'WARNING':
            filtered_data.append(k)

json_object = json.dumps(filtered_data, indent=3)

filteredData = open("resultFiltered.json", "w")
filteredData.write(json_object)