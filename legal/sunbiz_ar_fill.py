#!/usr/bin/env python3
"""
File 2026 Annual Report for AVALIA CONSULTING LLC (L19000154273).
Changes:
  - Officer (AMBR): DENORCHIA, ALEC → VALIDO DELGADO, ALBERTO
  - Registered Agent: DENORCHIA, ALEC → Alberto Valido Delgado
  - RA Signature: Alberto Valido Delgado

Does NOT submit payment — stops for review after filling.
"""
import sys, time
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

DOC_NUMBER = 'L19000154273'
SCREENSHOTS = '/Users/rnir_hrc_avd/Backup/L7_WAY/legal/'

def file_ar():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                       'AppleWebKit/537.36 (KHTML, like Gecko) '
                       'Chrome/120.0.0.0 Safari/537.36'
        )

        # ---- Step 1: Enter document number ----
        print("=" * 60)
        print("[1/5] Entering document number")
        print("=" * 60)

        page.goto('https://services.sunbiz.org/Filings/AnnualReport/FilingStart')
        page.wait_for_load_state('networkidle')

        page.fill('input[name="DocumentId"]', DOC_NUMBER)
        page.click('input[type="submit"]')
        page.wait_for_load_state('networkidle')

        print(f"  URL: {page.url}")
        print(f"  Entity: AVALIA CONSULTING LLC loaded")

        page.screenshot(path=f'{SCREENSHOTS}ar_01_loaded.png', full_page=True)

        # ---- Step 2: Edit Officer (AMBR) ----
        print("\n" + "=" * 60)
        print("[2/5] Editing Officer (AMBR): DENORCHIA → VALIDO DELGADO")
        print("=" * 60)

        # Click "Edit or Delete Manager" link
        edit_officer = page.query_selector('a[id*="editofficer"], a[href*="editofficer"]')
        if not edit_officer:
            # Try by text content
            links = page.query_selector_all('a')
            for link in links:
                text = link.inner_text().strip()
                if 'Edit or Delete' in text or 'Edit Manager' in text.replace('  ', ' '):
                    edit_officer = link
                    break

        if edit_officer:
            print(f"  Clicking: {edit_officer.inner_text().strip()}")
            edit_officer.click()
            page.wait_for_load_state('networkidle')
            time.sleep(1)  # Wait for any JS rendering

            page.screenshot(path=f'{SCREENSHOTS}ar_02_edit_officer.png', full_page=True)

            # Map all form fields after clicking edit
            print("\n  Form fields after clicking Edit Officer:")
            all_inputs = page.query_selector_all('input[type="text"], input[type="email"], textarea, select')
            for inp in all_inputs:
                inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
                try:
                    inp_val = inp.input_value()
                except:
                    inp_val = inp.get_attribute('value') or ''
                vis = inp.is_visible()
                if vis:
                    print(f"    {inp_name}: '{inp_val}'")

            # Look for title, last name, first name fields
            # Try common field name patterns
            officer_fields = {}
            for pattern in [
                ('title', ['Title', 'title', 'OfficerTitle', 'off_title']),
                ('last', ['LastName', 'last_name', 'lastName', 'OfficerLastName', 'lname']),
                ('first', ['FirstName', 'first_name', 'firstName', 'OfficerFirstName', 'fname']),
                ('middle', ['MiddleName', 'middle_name', 'middleName', 'mname']),
                ('suffix', ['Suffix', 'suffix', 'NameSuffix']),
                ('addr1', ['Address1', 'address1', 'addr1', 'Street']),
                ('addr2', ['Address2', 'address2', 'addr2']),
                ('city', ['City', 'city']),
                ('state', ['State', 'state']),
                ('zip', ['Zip', 'zip', 'ZipCode', 'zipcode']),
                ('country', ['Country', 'country']),
            ]:
                field_key, selectors = pattern
                for sel in selectors:
                    inp = page.query_selector(f'input[name*="{sel}"]')
                    if inp and inp.is_visible():
                        try:
                            val = inp.input_value()
                        except:
                            val = ''
                        officer_fields[field_key] = (inp, sel, val)
                        break

            print(f"\n  Identified officer fields: {list(officer_fields.keys())}")
            for key, (inp, sel, val) in officer_fields.items():
                print(f"    {key} ({sel}): '{val}'")

            # Fill in the new values
            changes_made = []
            if 'last' in officer_fields:
                inp, sel, old = officer_fields['last']
                inp.fill('VALIDO DELGADO')
                changes_made.append(f"Last: '{old}' → 'VALIDO DELGADO'")
            if 'first' in officer_fields:
                inp, sel, old = officer_fields['first']
                inp.fill('ALBERTO')
                changes_made.append(f"First: '{old}' → 'ALBERTO'")

            for c in changes_made:
                print(f"  CHANGED: {c}")

            # Look for save/update button
            save_btns = page.query_selector_all('button, input[type="submit"], a.btn')
            for btn in save_btns:
                try:
                    bt = btn.inner_text().strip()
                except:
                    bt = btn.get_attribute('value') or ''
                if bt and btn.is_visible():
                    print(f"  Button: [{bt}]")
                    if any(kw in bt.lower() for kw in ['save', 'update', 'confirm', 'ok', 'apply']):
                        print(f"  Clicking: [{bt}]")
                        btn.click()
                        page.wait_for_load_state('networkidle')
                        time.sleep(1)
                        break

            page.screenshot(path=f'{SCREENSHOTS}ar_03_officer_changed.png', full_page=True)

        else:
            print("  WARNING: Could not find Edit Officer link")
            # Try clicking by JavaScript/href
            page.evaluate("""
                document.querySelectorAll('a').forEach(a => {
                    if (a.textContent.includes('Edit') && a.textContent.includes('Manager')) {
                        a.click();
                    }
                });
            """)
            time.sleep(2)

        # ---- Step 3: Edit Registered Agent ----
        print("\n" + "=" * 60)
        print("[3/5] Editing Registered Agent: DENORCHIA → VALIDO DELGADO")
        print("=" * 60)

        # Navigate back to main form if needed
        if 'FilingDetails' not in page.url:
            page.go_back()
            page.wait_for_load_state('networkidle')

        edit_agent = page.query_selector('a[id*="agent"]:not([id*="address"])')
        if not edit_agent:
            links = page.query_selector_all('a')
            for link in links:
                text = link.inner_text().strip()
                href = link.get_attribute('id') or ''
                if ('Edit Agent' in text or 'Signature' in text) and 'Address' not in text:
                    edit_agent = link
                    break
                if 'agent' in href.lower() and 'address' not in href.lower():
                    edit_agent = link
                    break

        if edit_agent:
            print(f"  Clicking: {edit_agent.inner_text().strip()}")
            edit_agent.click()
            page.wait_for_load_state('networkidle')
            time.sleep(1)

            page.screenshot(path=f'{SCREENSHOTS}ar_04_edit_agent.png', full_page=True)

            # Map agent fields
            print("\n  Form fields after clicking Edit Agent:")
            all_inputs = page.query_selector_all('input[type="text"]')
            for inp in all_inputs:
                inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
                try:
                    inp_val = inp.input_value()
                except:
                    inp_val = ''
                vis = inp.is_visible()
                if vis:
                    print(f"    {inp_name}: '{inp_val}'")

            # Find agent name fields and signature field
            agent_fields = {}
            for pattern in [
                ('last', ['LastName', 'last_name', 'AgentLastName', 'RALastName']),
                ('first', ['FirstName', 'first_name', 'AgentFirstName', 'RAFirstName']),
                ('middle', ['MiddleName', 'middle_name']),
                ('suffix', ['Suffix', 'suffix']),
                ('signature', ['Signature', 'signature', 'AgentSignature', 'RASignature']),
            ]:
                field_key, selectors = pattern
                for sel in selectors:
                    inp = page.query_selector(f'input[name*="{sel}"]')
                    if inp and inp.is_visible():
                        try:
                            val = inp.input_value()
                        except:
                            val = ''
                        agent_fields[field_key] = (inp, sel, val)
                        break

            print(f"\n  Identified agent fields: {list(agent_fields.keys())}")
            for key, (inp, sel, val) in agent_fields.items():
                print(f"    {key} ({sel}): '{val}'")

            # Fill new values
            changes_made = []
            if 'last' in agent_fields:
                inp, sel, old = agent_fields['last']
                inp.fill('Valido Delgado')
                changes_made.append(f"Last: '{old}' → 'Valido Delgado'")
            if 'first' in agent_fields:
                inp, sel, old = agent_fields['first']
                inp.fill('Alberto')
                changes_made.append(f"First: '{old}' → 'Alberto'")
            if 'signature' in agent_fields:
                inp, sel, old = agent_fields['signature']
                inp.fill('Alberto Valido Delgado')
                changes_made.append(f"Signature: '{old}' → 'Alberto Valido Delgado'")

            for c in changes_made:
                print(f"  CHANGED: {c}")

            # Save
            save_btns = page.query_selector_all('button, input[type="submit"], a.btn')
            for btn in save_btns:
                try:
                    bt = btn.inner_text().strip()
                except:
                    bt = btn.get_attribute('value') or ''
                if bt and btn.is_visible():
                    if any(kw in bt.lower() for kw in ['save', 'update', 'confirm', 'ok', 'apply']):
                        print(f"  Clicking: [{bt}]")
                        btn.click()
                        page.wait_for_load_state('networkidle')
                        time.sleep(1)
                        break

            page.screenshot(path=f'{SCREENSHOTS}ar_05_agent_changed.png', full_page=True)

        else:
            print("  WARNING: Could not find Edit Agent link")

        # ---- Step 4: Review final state ----
        print("\n" + "=" * 60)
        print("[4/5] FINAL STATE — Review before submission")
        print("=" * 60)

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 2 and len(line) < 300:
                # Show key info
                if any(kw in line.upper() for kw in [
                    'AVALIA', 'VALIDO', 'DELGADO', 'ALBERTO', 'DENORCHIA', 'ALEC',
                    'AMBR', 'AGENT', 'SIGNATURE', 'ADDRESS', 'BOCA', 'FORT',
                    'PRINCIPAL', 'MAILING', 'FEI', 'EIN', 'DOCUMENT', 'STATUS',
                    'FEE', '$', 'FILING', 'NAME', 'MANAGER', 'TITLE',
                    'REVIEW', 'SUBMIT', 'CONTINUE', 'NEXT', 'PAYMENT',
                    'CERTIFICATE', 'STEP',
                ]):
                    print(f"  {line}")

        page.screenshot(path=f'{SCREENSHOTS}ar_06_final_review.png', full_page=True)

        # ---- Step 5: DO NOT SUBMIT ----
        print("\n" + "=" * 60)
        print("[5/5] STOP — NOT SUBMITTED")
        print("=" * 60)
        print(f"  Entity: AVALIA CONSULTING LLC")
        print(f"  Doc #:  {DOC_NUMBER}")
        print(f"  Fee:    $138.75")
        print(f"  URL:    {page.url}")
        print(f"\n  Screenshots saved to: legal/ar_01 through ar_06")
        print(f"\n  *** FORM IS FILLED BUT NOT SUBMITTED ***")
        print(f"  *** Review screenshots, then approve payment ***")

        browser.close()

if __name__ == '__main__':
    file_ar()
