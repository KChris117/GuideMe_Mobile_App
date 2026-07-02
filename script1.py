import re
import os

files = [
    'lib/views/admin/destination_management/create_destination_screen.dart',
    'lib/views/admin/event_management/create_event_screen.dart',
    'lib/views/admin/destination_management/modify_destination_screen.dart',
    'lib/views/admin/event_management/modify_event_screen.dart',
    'lib/views/admin/category_management/create_category_screen.dart'
]

# 1. Remove .toLowerCase() everywhere in these files
for fpath in files:
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            content = f.read()
        content = content.replace('.toLowerCase()', '')
        with open(fpath, 'w') as f:
            f.write(content)

# 2. Add GalleryModel import to all 4 files if not present
files_to_import = files[:4]
for fpath in files_to_import:
    with open(fpath, 'r') as f:
        content = f.read()
    if 'models/gallery_model.dart' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:guideme/models/gallery_model.dart';")
    with open(fpath, 'w') as f:
        f.write(content)
