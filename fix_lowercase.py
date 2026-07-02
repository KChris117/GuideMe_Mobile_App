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
        content = content.replace('.toLowerCase()', '')
        with open(fpath, 'w') as f:
            f.write(content)

print("Part 1: toLowerCase removed")
