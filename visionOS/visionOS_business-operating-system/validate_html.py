#!/usr/bin/env python3
"""
HTML Validation Script for Business Operating System Landing Page
"""

import re
import sys
from pathlib import Path

def validate_html(file_path):
    """Validate HTML structure and common issues"""

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    errors = []
    warnings = []
    successes = []

    # Check for DOCTYPE
    if not content.strip().startswith('<!DOCTYPE html>'):
        errors.append("Missing or incorrect DOCTYPE declaration")
    else:
        successes.append("✅ Valid DOCTYPE declaration")

    # Check for html lang attribute
    if 'lang="' in content:
        successes.append("✅ HTML lang attribute present")
    else:
        warnings.append("⚠️  HTML lang attribute missing")

    # Check for meta charset
    if 'charset="UTF-8"' in content or 'charset=UTF-8' in content:
        successes.append("✅ UTF-8 charset declared")
    else:
        errors.append("❌ UTF-8 charset not declared")

    # Check for viewport meta tag
    if 'name="viewport"' in content:
        successes.append("✅ Viewport meta tag present")
    else:
        errors.append("❌ Viewport meta tag missing (required for responsive design)")

    # Check for meta description
    if 'name="description"' in content:
        successes.append("✅ Meta description present")
    else:
        warnings.append("⚠️  Meta description missing (important for SEO)")

    # Check for title tag
    if '<title>' in content and '</title>' in content:
        title_match = re.search(r'<title>(.*?)</title>', content)
        if title_match and title_match.group(1).strip():
            successes.append(f"✅ Title tag present: '{title_match.group(1)[:50]}...'")
        else:
            errors.append("❌ Empty title tag")
    else:
        errors.append("❌ Title tag missing")

    # Check for matching tags (basic validation)
    open_tags = re.findall(r'<(\w+)[^>]*>', content)
    close_tags = re.findall(r'</(\w+)>', content)

    # Self-closing tags to ignore
    self_closing = {'meta', 'link', 'img', 'br', 'hr', 'input'}

    tag_counts = {}
    for tag in open_tags:
        if tag not in self_closing:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1

    for tag in close_tags:
        tag_counts[tag] = tag_counts.get(tag, 0) - 1

    unmatched_tags = {tag: count for tag, count in tag_counts.items() if count != 0}

    if unmatched_tags:
        for tag, count in unmatched_tags.items():
            if count > 0:
                errors.append(f"❌ Unclosed tag: <{tag}> ({count} unclosed)")
            else:
                errors.append(f"❌ Extra closing tag: </{tag}> ({abs(count)} extra)")
    else:
        successes.append("✅ All HTML tags properly closed")

    # Check for accessibility
    if 'alt=' in content or 'alt =' in content:
        successes.append("✅ Alt attributes found on images")
    else:
        warnings.append("⚠️  No alt attributes found (check if images have alt text)")

    # Check for semantic HTML5 tags
    semantic_tags = ['header', 'nav', 'main', 'section', 'article', 'aside', 'footer']
    found_semantic = [tag for tag in semantic_tags if f'<{tag}' in content]

    if len(found_semantic) >= 3:
        successes.append(f"✅ Semantic HTML5 tags used: {', '.join(found_semantic)}")
    else:
        warnings.append("⚠️  Limited use of semantic HTML5 tags")

    # Check for external resources
    if '<link rel="stylesheet"' in content:
        css_links = re.findall(r'<link[^>]*href="([^"]*)"[^>]*>', content)
        successes.append(f"✅ {len(css_links)} stylesheet(s) linked")

    if '<script' in content:
        script_tags = re.findall(r'<script[^>]*src="([^"]*)"[^>]*>', content)
        successes.append(f"✅ {len(script_tags)} external script(s) linked")

    # Check for form elements
    if '<form' in content:
        if 'action=' in content or 'onsubmit=' in content:
            successes.append("✅ Form with action/handler found")
        else:
            warnings.append("⚠️  Form without action or handler")

        # Check for required attributes
        if 'required' in content:
            successes.append("✅ Form validation attributes present")

    # Check for ARIA attributes
    aria_count = len(re.findall(r'aria-[a-z]+', content))
    if aria_count > 0:
        successes.append(f"✅ {aria_count} ARIA attributes found (accessibility)")

    return errors, warnings, successes

def main():
    html_file = Path("/home/user/visionOS_business-operating-system/landing-page/index.html")

    if not html_file.exists():
        print(f"❌ File not found: {html_file}")
        sys.exit(1)

    print("=" * 70)
    print("HTML VALIDATION REPORT")
    print("=" * 70)
    print(f"File: {html_file}")
    print()

    errors, warnings, successes = validate_html(html_file)

    # Print successes
    if successes:
        print("✅ PASSED CHECKS:")
        for success in successes:
            print(f"  {success}")
        print()

    # Print warnings
    if warnings:
        print("⚠️  WARNINGS:")
        for warning in warnings:
            print(f"  {warning}")
        print()

    # Print errors
    if errors:
        print("❌ ERRORS:")
        for error in errors:
            print(f"  {error}")
        print()

    # Summary
    print("=" * 70)
    print("SUMMARY:")
    print(f"  ✅ Passed: {len(successes)}")
    print(f"  ⚠️  Warnings: {len(warnings)}")
    print(f"  ❌ Errors: {len(errors)}")
    print("=" * 70)

    if errors:
        print("\n❌ HTML validation FAILED")
        sys.exit(1)
    elif warnings:
        print("\n⚠️  HTML validation PASSED with warnings")
        sys.exit(0)
    else:
        print("\n✅ HTML validation PASSED")
        sys.exit(0)

if __name__ == "__main__":
    main()
