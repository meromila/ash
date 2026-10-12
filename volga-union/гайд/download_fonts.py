import json
import urllib.request
from pathlib import Path

root = Path(__file__).parent / 'шрифты'
for folder, family, selected in [('golostext', 'Golos Text', None), ('alegreyasans', 'Alegreya Sans', ['AlegreyaSans-Medium.ttf'])]:
    entries = json.load(urllib.request.urlopen('https://api.github.com/repos/google/fonts/contents/ofl/' + folder))
    target = root / family
    target.mkdir(parents=True, exist_ok=True)
    for entry in entries:
        if entry['name'] == 'OFL.txt' or (entry['name'].endswith('.ttf') and (selected is None or entry['name'] in selected)):
            urllib.request.urlretrieve(entry['download_url'], target / entry['name'])
            print(family, entry['name'])
