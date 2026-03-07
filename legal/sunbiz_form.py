#!/usr/bin/env python3
"""Accept disclaimer and map the full LLC filing form on Sunbiz."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def map_full_form():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # Step 1: Accept disclaimer
        print("[1] Loading filing page...")
        page.goto('https://efile.sunbiz.org/llc_file.html')
        page.wait_for_load_state('networkidle')

        print("[2] Accepting disclaimer...")
        page.check('#disclaimer_read')
        # Click the first submit (File Articles)
        submits = page.query_selector_all('input[type="submit"]')
        if submits:
            submits[0].click()
            page.wait_for_load_state('networkidle')

        title = page.title()
        url = page.url
        print(f"[3] New page: {title}")
        print(f"    URL: {url}")

        # Map ALL form fields
        inputs = page.query_selector_all('input, select, textarea')
        print(f"\n    Total form fields: {len(inputs)}")
        print()

        visible_count = 0
        for inp in inputs:
            name = inp.get_attribute('name') or ''
            iid = inp.get_attribute('id') or ''
            itype = inp.get_attribute('type') or inp.evaluate('el => el.tagName')
            value = inp.get_attribute('value') or ''
            placeholder = inp.get_attribute('placeholder') or ''
            maxlen = inp.get_attribute('maxlength') or ''
            required = inp.get_attribute('required')

            if itype == 'hidden':
                continue

            visible_count += 1
            # Get label - try various methods
            label_text = ''
            if iid:
                label = page.query_selector(f'label[for="{iid}"]')
                if label:
                    label_text = label.inner_text().strip()

            # Try parent for context
            if not label_text:
                try:
                    parent_text = inp.evaluate('el => el.parentElement ? el.parentElement.textContent.trim().substring(0, 80) : ""')
                    if parent_text:
                        label_text = parent_text
                except:
                    pass

            print(f"  FIELD {visible_count}: [{itype}] name=\"{name}\"")
            if label_text:
                print(f"    label: {label_text}")
            if placeholder:
                print(f"    placeholder: {placeholder}")
            if maxlen:
                print(f"    maxlength: {maxlen}")
            if required is not None:
                print(f"    REQUIRED")
            if value and itype in ('radio', 'checkbox', 'submit'):
                print(f"    value: {value}")
            print()

        # Dump full page text
        print("=" * 60)
        print("FULL PAGE TEXT")
        print("=" * 60)
        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line:
                print(f"  {line}")

        # Screenshot
        page.screenshot(path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/sunbiz_articles_form.png', full_page=True)
        print("\n[Screenshot: legal/sunbiz_articles_form.png]")

        browser.close()

if __name__ == '__main__':
    map_full_form()
