#!/usr/bin/env python3
"""
Navigate Sunbiz amendment/annual report system to update officer and RA
for AVALIA CONSULTING LLC (L19000154273).

Change: DENORCHIA, ALEC → VALIDO DELGADO, ALBERTO
"""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

DOC_NUMBER = 'L19000154273'

def update_entity():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                       'AppleWebKit/537.36 (KHTML, like Gecko) '
                       'Chrome/120.0.0.0 Safari/537.36'
        )

        # Step 1: Annual Report e-filing
        print("=" * 60)
        print("STEP 1: Annual Report e-filing system")
        print("=" * 60)

        page.goto('https://dos.fl.gov/sunbiz/manage-business/efile/annual-report/')
        page.wait_for_load_state('networkidle')
        print(f"Title: {page.title()}")
        print(f"URL: {page.url}")

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 5 and len(line) < 300:
                print(f"  {line}")

        # Look for links to the actual filing system
        links = page.query_selector_all('a')
        for link in links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and any(kw in text.lower() for kw in [
                'file', 'annual', 'report', 'efile', 'online', 'begin',
                'start', 'click here', 'proceed',
            ]):
                print(f"\n  FILING LINK: [{text}] -> {href}")

        # Step 2: Update/Change Information page
        print("\n" + "=" * 60)
        print("STEP 2: Update or Change Your Information")
        print("=" * 60)

        page.goto('https://dos.fl.gov/sunbiz/manage-business/update-information/')
        page.wait_for_load_state('networkidle')
        print(f"Title: {page.title()}")

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 5 and len(line) < 300:
                if any(kw in line.lower() for kw in [
                    'amend', 'change', 'officer', 'member', 'agent',
                    'registered', 'name', 'address', 'annual', 'report',
                    'llc', 'limited', 'update', 'form', 'mail', 'online',
                    'fee', '$', 'file', 'document',
                ]):
                    print(f"  {line}")

        links = page.query_selector_all('a')
        for link in links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and any(kw in text.lower() for kw in [
                'amend', 'change', 'form', 'registered agent',
                'officer', 'pdf', 'download',
            ]):
                print(f"\n  FORM LINK: [{text}] -> {href}")

        # Step 3: Manage Business main page
        print("\n" + "=" * 60)
        print("STEP 3: Manage/Change Existing Business")
        print("=" * 60)

        page.goto('https://dos.fl.gov/sunbiz/manage-business/')
        page.wait_for_load_state('networkidle')

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 5 and len(line) < 300:
                if any(kw in line.lower() for kw in [
                    'amend', 'change', 'annual', 'report', 'officer',
                    'member', 'agent', 'update', 'llc', 'name',
                ]):
                    print(f"  {line}")

        links = page.query_selector_all('a')
        for link in links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and len(text) > 3:
                if any(kw in text.lower() for kw in [
                    'amend', 'change', 'annual', 'update', 'form',
                ]):
                    print(f"  LINK: [{text}] -> {href}")

        # Step 4: Try the old efile.sunbiz.org annual report portal directly
        print("\n" + "=" * 60)
        print("STEP 4: Direct annual report portal (efile.sunbiz.org)")
        print("=" * 60)

        page.goto('https://efile.sunbiz.org/annual_report.html')
        page.wait_for_load_state('networkidle')
        print(f"Title: {page.title()}")
        print(f"URL: {page.url}")

        # Check if there's a document number field
        inputs = page.query_selector_all('input')
        for inp in inputs:
            inp_type = inp.get_attribute('type') or '?'
            inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
            inp_val = inp.get_attribute('value') or ''
            print(f"  Input: type={inp_type}, name={inp_name}, value={inp_val}")

        # Try submitting document number if field exists
        doc_field = page.query_selector('input[name="docnum"], input[name="doc_num"], input[name="document_number"], input[name="entity_id"]')
        if doc_field:
            print(f"\n  Found doc number field. Entering {DOC_NUMBER}...")
            doc_field.fill(DOC_NUMBER)
        else:
            # Try first text input
            text_inputs = page.query_selector_all('input[type="text"]')
            if text_inputs:
                print(f"\n  Trying first text input with {DOC_NUMBER}...")
                text_inputs[0].fill(DOC_NUMBER)

                submits = page.query_selector_all('input[type="submit"], button[type="submit"]')
                if submits:
                    print(f"  Clicking submit: {submits[0].get_attribute('value')}")
                    submits[0].click()
                    page.wait_for_load_state('networkidle')
                    print(f"  After submit URL: {page.url}")
                    print(f"  After submit Title: {page.title()}")

                    # Dump the result page
                    body = page.inner_text('body')
                    for line in body.split('\n'):
                        line = line.strip()
                        if line and len(line) > 2 and len(line) < 300:
                            print(f"    {line}")

                    # Look for form fields
                    form_inputs = page.query_selector_all('input[type="text"], textarea, select')
                    if form_inputs:
                        print(f"\n  FORM FIELDS FOUND: {len(form_inputs)}")
                        for fi in form_inputs:
                            fi_name = fi.get_attribute('name') or fi.get_attribute('id') or '?'
                            fi_val = fi.input_value() if fi.get_attribute('type') != 'hidden' else fi.get_attribute('value')
                            print(f"    {fi_name}: {fi_val}")

        # Step 5: Try forms page for downloadable amendment forms
        print("\n" + "=" * 60)
        print("STEP 5: Forms & Fees page")
        print("=" * 60)

        page.goto('https://dos.fl.gov/sunbiz/forms/')
        page.wait_for_load_state('networkidle')

        links = page.query_selector_all('a')
        for link in links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and any(kw in text.lower() for kw in [
                'amend', 'llc', 'limited liability', 'change',
                'registered agent', 'officer', 'annual',
            ]):
                print(f"  [{text}] -> {href}")

        # Take screenshot
        page.screenshot(
            path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/sunbiz_amendment_options.png',
            full_page=True
        )

        browser.close()

if __name__ == '__main__':
    update_entity()
