import os

files = [
    'lib/views/admin/destination_management/create_destination_screen.dart',
    'lib/views/admin/event_management/create_event_screen.dart',
    'lib/views/admin/destination_management/modify_destination_screen.dart',
    'lib/views/admin/event_management/modify_event_screen.dart',
]

for fpath in files:
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            content = f.read()

        # Remove commented invalid imports that might have been accidentally inserted
        content = content.replace("import 'package:guideme/models/gallery_model.dart';", "")

        # Insert correctly at top
        if 'models/gallery_model.dart' not in content:
            content = "import 'package:guideme/models/gallery_model.dart';\n" + content
            
        with open(fpath, 'w') as f:
            f.write(content)

print("Imports fixed")
