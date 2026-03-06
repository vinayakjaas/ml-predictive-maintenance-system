import requests
import random, json, sys

# Environment check
if len(sys.argv) > 1 and sys.argv[1] == "local":
    host = "127.0.0.1:9696"
else:
    host = 'failure-serving-env.eba-4asms9ir.eu-west-1.elasticbeanstalk.com'
url = f"http://{host}/predict"
print(f"Using endpoint {url}\n")

# Equipment data
equipments = [
    {
        'temperature': 69.94045290787271,
        'pressure': 26.18938696984232,
        'vibration': 0.6971832984686062,
        'humidity': 52.640224489963536,
        'equipment': 'turbine',
        'location': 'atlanta'
    },
    {
        'temperature': 149,
        'pressure': 35,
        'vibration': 4,
        'humidity': 50,
        'equipment': 'turbine',
        'location': 'atlanta'
    }
]
# request prediction
try:
    selected_equipment = random.choice(equipments)
    response = requests.post(url, json=selected_equipment)
    response.raise_for_status()  # HTTP errors management
    print(f"Equipment: {selected_equipment}")
    print(f"Prediction: {response.json()}")
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
