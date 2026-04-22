#!/usr/bin/env python3
"""
Script to update all .sv file headers to MIT license format.
"""

import os
import re
from pathlib import Path

# New header format
NEW_HEADER_TEMPLATE = '''// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : {filename}
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : {description}
// ============================================================================
'''

def extract_description(content):
    """Extract description from old header format."""
    # Try to extract from the old block comment format
    match = re.search(r'/\*\*\nproject: openx86\nauthor:.*?\ndescription: (.*?)\n\*/', content, re.DOTALL)
    if match:
        desc = match.group(1).strip()
        if desc and desc != "This module implements {module_name}.":
            return desc
    
    # Try alternative format
    match = re.search(r'/\*\nproject: openx86\nauthor:.*?\ndescription: (.*?)\n\*/', content, re.DOTALL)
    if match:
        desc = match.group(1).strip()
        if desc and desc != "This module implements {module_name}.":
            return desc
    
    # If no description found or generic, try to extract from module name
    match = re.search(r'module\s+(\w+)', content)
    if match:
        module_name = match.group(1)
        return f"{module_name} module"
    
    return "Module"

def update_header(file_path):
    """Update header in a single .sv file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract description from old header
    description = extract_description(content)
    
    # Generate new header
    filename = os.path.basename(file_path)
    new_header = NEW_HEADER_TEMPLATE.format(filename=filename, description=description)
    
    # Remove old header (multiple patterns to handle variations)
    # Pattern 1: Block comment with project/author/repo/description
    pattern1 = r'/\*\*\nproject: openx86\nauthor:.*?\nrepo:.*?\ndescription:.*?\n\*/'
    content = re.sub(pattern1, '', content, flags=re.DOTALL)
    
    pattern2 = r'/\*\nproject: openx86\nauthor:.*?\nrepo:.*?\ndescription:.*?\n\*/'
    content = re.sub(pattern2, '', content, flags=re.DOTALL)
    
    # Pattern 3: Simple block comment
    pattern3 = r'/\*\nproject: openx86\nauthor:.*?\ndescription:.*?\n\*/'
    content = re.sub(pattern3, '', content, flags=re.DOTALL)
    
    # Remove the old separator comments that might follow
    content = re.sub(r'// ============================================================================\n// .*?\n// ----------------------------------------------------------------------------.*?\n// ============================================================================\n\n', '', content, flags=re.DOTALL)
    content = re.sub(r'// ============================================================================\n// .*?\n// ----------------------------------------------------------------------------.*?\n// ============================================================================\n', '', content, flags=re.DOTALL)
    
    # Remove old-style single-line comments that may appear after the new header
    # Pattern variations:
    # - // project: ..., // author: ..., // repo: ..., // create at: ..., // description: ...
    # - // project: ..., // description: ...
    pattern_single1 = r'// project:.*?\n// author:.*?\n// repo:.*?\n(// create at:.*?\n)?// description:.*?\n'
    pattern_single2 = r'// project:.*?\n// description:.*?\n'
    content = re.sub(pattern_single1, '', content, flags=re.DOTALL)
    content = re.sub(pattern_single2, '', content, flags=re.DOTALL)
    
    # Add new header at the beginning
    content = new_header + '\n' + content.lstrip('\n')
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return description

def main():
    """Main function to update all .sv files."""
    # Find all .sv files
    root_dir = Path(r'd:\GitHub\openx86\openx86')
    sv_files = list(root_dir.rglob('*.sv'))
    
    print(f"Found {len(sv_files)} .sv files")
    
    updated_count = 0
    for file_path in sv_files:
        print(f"Processing: {file_path}")
        try:
            description = update_header(file_path)
            print(f"  -> Description: {description}")
            updated_count += 1
        except Exception as e:
            print(f"  -> ERROR: {e}")
    
    print(f"\nUpdated {updated_count} files")

if __name__ == '__main__':
    main()
