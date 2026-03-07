#!/usr/bin/env python3
"""Navigate to Sunbiz LLC filing page and map the form."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def map_filing_form():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        print("=" * 60)
        print("SUNBIZ LLC FILING FORM — efile.sunbiz.org")
        print("=" * 60)

        page.goto('https://efile.sunbiz.org/llc_file.html')
        page.wait_for_load_state('networkidle')

        title = page.title()
        print(f"Page: {title}")
        print()

        # Get all form fields
        inputs = page.query_selector_all('input, select, textarea')
        print(f"Total form fields: {len(inputs)}")
        print()

        for inp in inputs:
            name = inp.get_attribute('name') or ''
            iid = inp.get_attribute('id') or ''
            itype = inp.get_attribute('type') or inp.evaluate('el => el.tagName')
            value = inp.get_attribute('value') or ''
            placeholder = inp.get_attribute('placeholder') or ''
            maxlen = inp.get_attribute('maxlength') or ''

            # Get associated label
            label_text = ''
            if iid:
                label = page.query_selector(f'label[for="{iid}"]')
                if label:
                    label_text = label.inner_text().strip()

            if itype != 'hidden':
                print(f"  [{itype}] name={name} id={iid}")
                if label_text:
                    print(f"         label: {label_text}")
                if placeholder:
                    print(f"         placeholder: {placeholder}")
                if maxlen:
                    print(f"         maxlength: {maxlen}")
                if value and itype in ('radio', 'checkbox'):
                    checked = inp.get_attribute('checked')
                    print(f"         value={value} checked={checked}")
                print()

        # Also dump the visible page structure
        print("\n" + "=" * 60)
        print("PAGE TEXT CONTENT")
        print("=" * 60)
        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line:
                print(f"  {line}")

        # Take a screenshot for reference
        page.screenshot(path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/sunbiz_filing_form.png', full_page=True)
        print("\n[Screenshot saved to legal/sunbiz_filing_form.png]")

        browser.close()

if __name__ == '__main__':
    map_filing_form()
