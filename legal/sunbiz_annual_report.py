#!/usr/bin/env python3
"""
File 2026 Annual Report for AVALIA CONSULTING LLC (L19000154273).
Updates officer and RA from DENORCHIA, ALEC to VALIDO DELGADO, ALBERTO.

Does NOT submit — fills form, takes screenshot, stops for review.
"""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

DOC_NUMBER = 'L19000154273'

def file_annual_report():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                       'AppleWebKit/537.36 (KHTML, like Gecko) '
                       'Chrome/120.0.0.0 Safari/537.36'
        )

        # Step 1: Go to filing start page
        print("=" * 60)
        print("STEP 1: Annual Report Filing Start")
        print("=" * 60)

        page.goto('https://services.sunbiz.org/Filings/AnnualReport/FilingStart')
        page.wait_for_load_state('networkidle')
        print(f"Title: {page.title()}")
        print(f"URL: {page.url}")

        # Screenshot the start page
        page.screenshot(
            path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/ar_step1_start.png',
            full_page=True
        )

        # Look for document number input
        inputs = page.query_selector_all('input')
        print("\n  All inputs on page:")
        for inp in inputs:
            inp_type = inp.get_attribute('type') or '?'
            inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
            inp_val = inp.get_attribute('value') or ''
            inp_placeholder = inp.get_attribute('placeholder') or ''
            print(f"    type={inp_type}, name={inp_name}, value='{inp_val}', placeholder='{inp_placeholder}'")

        # Look for text on page
        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 3 and len(line) < 200:
                print(f"  {line}")

        # Try to find and fill the document number field
        doc_field = None
        for selector in [
            '#DocumentNumber', '#docnum', '#doc_num',
            'input[name="DocumentNumber"]', 'input[name="docnum"]',
            'input[name="doc_num"]', 'input[name="documentNumber"]',
        ]:
            doc_field = page.query_selector(selector)
            if doc_field:
                print(f"\n  Found doc field: {selector}")
                break

        if not doc_field:
            # Try first text input
            text_inputs = page.query_selector_all('input[type="text"]')
            if text_inputs:
                doc_field = text_inputs[0]
                print(f"\n  Using first text input")

        if doc_field:
            print(f"  Entering document number: {DOC_NUMBER}")
            doc_field.fill(DOC_NUMBER)

            # Find and click submit
            submits = page.query_selector_all('input[type="submit"], button[type="submit"], button.btn')
            for sub in submits:
                val = sub.get_attribute('value') or sub.inner_text().strip()
                print(f"  Submit button: [{val}]")

            if submits:
                submits[0].click()
                page.wait_for_load_state('networkidle')

                print(f"\n  After submit URL: {page.url}")
                print(f"  After submit Title: {page.title()}")

                # Screenshot step 2
                page.screenshot(
                    path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/ar_step2_entity.png',
                    full_page=True
                )

                # Dump the entity info/form
                print("\n" + "=" * 60)
                print("STEP 2: Entity Information / Form")
                print("=" * 60)

                body = page.inner_text('body')
                for line in body.split('\n'):
                    line = line.strip()
                    if line and len(line) > 2 and len(line) < 300:
                        print(f"  {line}")

                # Map all form fields
                print("\n  --- FORM FIELDS ---")
                all_inputs = page.query_selector_all('input[type="text"], input[type="email"], textarea, select')
                for inp in all_inputs:
                    inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
                    try:
                        inp_val = inp.input_value()
                    except:
                        inp_val = inp.get_attribute('value') or ''
                    print(f"    {inp_name}: '{inp_val}'")

                # Look for officer/member fields
                print("\n  --- LOOKING FOR OFFICER/RA FIELDS ---")
                for selector in [
                    'input[name*="officer"]', 'input[name*="Officer"]',
                    'input[name*="member"]', 'input[name*="Member"]',
                    'input[name*="agent"]', 'input[name*="Agent"]',
                    'input[name*="last"]', 'input[name*="Last"]',
                    'input[name*="first"]', 'input[name*="First"]',
                    'input[name*="name"]', 'input[name*="Name"]',
                    'input[name*="title"]', 'input[name*="Title"]',
                    'input[name*="addr"]', 'input[name*="Addr"]',
                    'input[name*="Address"]',
                    'input[name*="signature"]', 'input[name*="Signature"]',
                ]:
                    fields = page.query_selector_all(selector)
                    for f in fields:
                        fn = f.get_attribute('name') or f.get_attribute('id') or '?'
                        try:
                            fv = f.input_value()
                        except:
                            fv = f.get_attribute('value') or ''
                        print(f"    {fn}: '{fv}'")

                # Look for edit/change buttons
                print("\n  --- BUTTONS/LINKS ---")
                buttons = page.query_selector_all('button, a.btn, input[type="button"], input[type="submit"]')
                for btn in buttons:
                    try:
                        bt = btn.inner_text().strip()
                    except:
                        bt = btn.get_attribute('value') or '?'
                    bh = btn.get_attribute('href') or ''
                    print(f"    [{bt}] {bh}")

                # Check for multiple pages/steps
                links = page.query_selector_all('a')
                for link in links:
                    text = link.inner_text().strip()
                    href = link.get_attribute('href') or ''
                    if text and any(kw in text.lower() for kw in [
                        'edit', 'change', 'modify', 'delete', 'add',
                        'next', 'continue', 'submit', 'officer', 'agent',
                    ]):
                        print(f"    LINK: [{text}] -> {href}")

        else:
            print("  ERROR: Could not find document number input field")
            # Dump the full page HTML for debugging
            html = page.content()
            print(f"  Page HTML length: {len(html)}")
            # Show forms
            forms = page.query_selector_all('form')
            for i, form in enumerate(forms):
                action = form.get_attribute('action') or '?'
                method = form.get_attribute('method') or '?'
                print(f"  Form {i}: action={action}, method={method}")

        browser.close()

if __name__ == '__main__':
    file_annual_report()
