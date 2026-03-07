#!/usr/bin/env python3
"""
File Articles of Organization for Avli Cloud LLC on Sunbiz.
Fills all fields, stops at "Continue" for review before payment.
"""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

FILING = {
    # LLC Name
    'corp_name': 'Avli Cloud LLC',

    # Principal Address (RA office — keeps personal address private)
    'princ_addr1': '3000 N Federal Hwy',
    'princ_addr2': 'Bldg 2 Suite 300',
    'princ_city': 'Fort Lauderdale',
    'princ_st': 'FL',
    'princ_zip': '33306',
    'princ_cntry': 'US',

    # Mailing = same as principal
    'same_addr_flag': True,

    # Registered Agent
    'ra_name_last_name': 'Saavedra',
    'ra_name_first_name': 'Rodrigo',
    'ra_name_m_name': 'L',
    'ra_name_title_name': 'Jr.',
    'ra_addr1': '3000 N Federal Hwy',
    'ra_addr2': 'Bldg 2 Suite 300',
    'ra_city': 'Fort Lauderdale',
    'ra_zip': '33306',
    'ra_signature': 'Rodrigo L Saavedra Jr',

    # Purpose
    'purpose': 'Technology development, software licensing, intellectual property management, and any and all lawful business.',

    # Correspondence
    'ret_name': 'Alberto Valido Delgado',
    'ret_email_addr': 'avalia@avli.cloud',
    'email_addr_verify': 'avalia@avli.cloud',

    # Signatory
    'signature': 'Alberto Valido Delgado',

    # Authorized Person — RA's firm as entity manager (private filing)
    # Philosopher's name stays off the public Sunbiz search page.
    # Only appears in the signed PDF document image.
    'off1_name_title': 'MGR',
    'off1_name_corp_name': 'Rodrigo L. Saavedra, Jr., P.A.',
    'off1_name_addr1': '3000 N Federal Hwy Bldg 2 Ste 300',
    'off1_name_city': 'Fort Lauderdale',
    'off1_name_st': 'FL',
    'off1_name_zip': '33306',
    'off1_name_cntry': 'US',
}

def file_llc():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # Step 1: Accept disclaimer
        print("[1/4] Loading Sunbiz filing page...")
        page.goto('https://efile.sunbiz.org/llc_file.html')
        page.wait_for_load_state('networkidle')
        page.check('#disclaimer_read')
        submits = page.query_selector_all('input[type="submit"]')
        submits[0].click()
        page.wait_for_load_state('networkidle')
        print(f"      Page: {page.title()}")
        print(f"      URL:  {page.url}")

        # Step 2: Check Certificate of Status
        print("\n[2/4] Filling form fields...")
        cos = page.query_selector('input[name="cos_num_flag"]')
        if cos:
            cos.check()
            print("      [x] Certificate of Status ($5)")

        # Step 3: Fill all text fields
        for field_name, value in FILING.items():
            if field_name == 'same_addr_flag':
                if value:
                    cb = page.query_selector('input[name="same_addr_flag"]')
                    if cb:
                        cb.check()
                        print("      [x] Mailing = Principal address")
                continue

            inp = page.query_selector(f'input[name="{field_name}"], textarea[name="{field_name}"]')
            if inp:
                inp.fill(str(value))
                # Truncate display for clean output
                display = value if len(str(value)) < 40 else str(value)[:37] + '...'
                print(f"      {field_name}: {display}")
            else:
                print(f"      WARNING: field '{field_name}' not found on page")

        # Step 4: Screenshot before submit
        print("\n[3/4] Taking pre-submission screenshot...")
        page.screenshot(
            path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/sunbiz_preflight.png',
            full_page=True
        )
        print("      Saved: legal/sunbiz_preflight.png")

        # Step 5: DO NOT CLICK CONTINUE — dump the page state
        print("\n[4/4] PRE-FLIGHT CHECK — Form state before submission:")
        print("=" * 60)

        # Read back all filled values to verify
        fields_to_check = [
            'corp_name', 'princ_addr1', 'princ_addr2', 'princ_city',
            'princ_st', 'princ_zip', 'princ_cntry',
            'ra_name_last_name', 'ra_name_first_name', 'ra_name_m_name',
            'ra_name_title_name', 'ra_addr1', 'ra_addr2', 'ra_city',
            'ra_zip', 'ra_signature',
            'purpose',
            'ret_name', 'ret_email_addr', 'email_addr_verify',
            'signature',
            'off1_name_title', 'off1_name_last_name', 'off1_name_first_name',
            'off1_name_addr1', 'off1_name_city', 'off1_name_st',
            'off1_name_zip', 'off1_name_cntry',
        ]

        all_ok = True
        for fname in fields_to_check:
            inp = page.query_selector(f'input[name="{fname}"], textarea[name="{fname}"]')
            if inp:
                val = inp.input_value()
                expected = str(FILING.get(fname, ''))
                match = 'OK' if val == expected else f'MISMATCH (got: {val})'
                if val != expected:
                    all_ok = False
                print(f"  {fname}: \"{val}\" [{match}]")
            else:
                print(f"  {fname}: FIELD NOT FOUND")
                all_ok = False

        print("=" * 60)
        if all_ok:
            print("ALL FIELDS VERIFIED. Ready to click 'Continue'.")
        else:
            print("WARNING: Some fields did not match. Review above.")

        print("\n*** FORM IS FILLED BUT NOT SUBMITTED ***")
        print("*** To submit: approve, then run file_avli_cloud_submit.py ***")

        browser.close()

if __name__ == '__main__':
    file_llc()
