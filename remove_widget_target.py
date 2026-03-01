#!/usr/bin/env python3
import re

# Read the project file
with open('Kotel.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Widget target ID and related IDs to remove
widget_ids = [
    '8A535E1E2F4E1C2000E436EC',  # Main widget target
    '8A535E1F2F4E1C2000E436EC',  # Widget product reference
    '8A535E1B2F4E1C2000E436EC',  # Widget Sources build phase
    '8A535E1C2F4E1C2000E436EC',  # Widget Frameworks build phase
    '8A535E1D2F4E1C2000E436EC',  # Widget Resources build phase
    '8A535E2D2F4E1C2100E436EC',  # Widget container proxy
    '8A535E2E2F4E1C2100E436EC',  # Widget target dependency
    '8A535E2F2F4E1C2100E436EC',  # Widget in Embed Foundation Extensions
    '8A535E312F4E1C2100E436EC',  # Widget build configuration list
    '8A535E342F4E1C2100E436EC',  # Embed Foundation Extensions build phase
    '8A535E442F4E24A500E436EC',  # Widget exception set
]

# Remove entire blocks containing these IDs
lines = content.split('\n')
output_lines = []
skip_until_end = 0
block_depth = 0

i = 0
while i < len(lines):
    line = lines[i]

    # Check if this line starts a block we want to remove
    if any(wid in line for wid in widget_ids):
        # Find the block depth
        if '{' in line and '}' not in line:
            # Start of a block, skip until matching }
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                if '{' in lines[i]:
                    depth += 1
                if '}' in lines[i]:
                    depth -= 1
                i += 1
            continue
        elif ');' in line or ';' in line:
            # Single line, skip it
            i += 1
            continue

    # Check for widget extension file references
    if 'Kotel​Widget​Extension' in line or 'KotelWidget' in line:
        # Skip this line and potentially the enclosing block
        if '{' in line and '}' not in line:
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                if '{' in lines[i]:
                    depth += 1
                if '}' in lines[i]:
                    depth -= 1
                i += 1
            continue
        else:
            i += 1
            continue

    output_lines.append(line)
    i += 1

# Write the modified content
with open('Kotel.xcodeproj/project.pbxproj', 'w') as f:
    f.write('\n'.join(output_lines))

print("Widget target removed from project.pbxproj")
