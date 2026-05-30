import os

# fix app_provider.dart
with open("lib/providers/app_provider.dart", "r") as f:
    text = f.read()
if "flutter_tts.dart" not in text:
    text = 'import "package:flutter_tts/flutter_tts.dart";\nimport "package:shared_preferences/shared_preferences.dart";\n' + text
with open("lib/providers/app_provider.dart", "w") as f:
    f.write(text)

def fix_imports(filepath):
    with open(filepath, "r") as f:
        lines = f.readlines()
    for i, l in enumerate(lines):
        if "import '" in l and "../" in l and "../../" not in l:
            lines[i] = l.replace("../", "../../")
    with open(filepath, "w") as f:
        f.writelines(lines)

fix_imports("lib/screens/home_screen/home_scren.dart")
fix_imports("lib/screens/learn_screen/learn_screen.dart")
