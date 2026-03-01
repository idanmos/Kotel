#!/usr/bin/env python3

# Read the project file
with open('Kotel.xcodeproj/project.pbxproj', 'r') as f:
    lines = f.readlines()

# Additional widget configuration IDs to remove
widget_config_ids = [
    '8A535E322F4E1C2100E436EC',  # Widget Debug config
    '8A535E332F4E1C2100E436EC',  # Widget Release config
]

# Process lines
output_lines = []
i = 0
while i < len(lines):
    line = lines[i]

    # Check if this line contains a widget config ID
    if any(config_id in line for config_id in widget_config_ids):
        # This is the start of a configuration block, skip until we find the closing brace
        depth = 0
        if '{' in line:
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                if '{' in lines[i]:
                    depth += 1
                if '}' in lines[i]:
                    depth -= 1
                    if depth == 0:
                        # Skip the closing brace line too
                        i += 1
                        break
                i += 1
            continue

    output_lines.append(line)
    i += 1

# Write the modified content
with open('Kotel.xcodeproj/project.pbxproj', 'w') as f:
    f.writelines(output_lines)

print("Widget configurations removed from project.pbxproj")
