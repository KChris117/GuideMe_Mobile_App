import re

with open('lib/views/admin/event_management/modify_event_screen.dart', 'r') as f:
    content = f.read()

# Fix _imageBytes errors
content = content.replace('_imageBytes = bytes;', '_imageBytesList = [bytes];')
content = content.replace('if (_imageBytes == null) return imageUrl;', 'if (_imageBytesList.isEmpty) return imageUrl;')
content = content.replace('uploadBinary(path, _imageBytes!,', 'uploadBinary(path, _imageBytesList.first,')

with open('lib/views/admin/event_management/modify_event_screen.dart', 'w') as f:
    f.write(content)
