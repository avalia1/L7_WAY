#!/usr/bin/env python3
"""
File 2026 Annual Report for AVALIA CONSULTING LLC (L19000154273).
Updates:
  1. Officer (AMBR): DENORCHIA, ALEC → VALIDO DELGADO, ALBERTO
  2. Registered Agent: DENORCHIA, ALEC → Valido Delgado, Alberto
  3. RA Signature: Alberto Valido Delgado

Stops before payment. Takes screenshots at each step.
"""
import sys, time
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

DOC_NUMBER = 'L19000154273'
SS = '/Users/rnir_hrc_avd/Backup/L7_WAY/legal/'

def file_ar():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                       'AppleWebKit/537.36 (KHTML, like Gecko) '
                       'Chrome/120.0.0.0 Safari/537.36'
        )

        # ======== STEP 1: Load entity ========
        print("[1/6] Loading entity...")
        page.goto('https://services.sunbiz.org/Filings/AnnualReport/FilingStart')
        page.wait_for_load_state('networkidle')
        page.fill('input[name="DocumentId"]', DOC_NUMBER)
        page.click('input[type="submit"]')
        page.wait_for_load_state('networkidle')
        time.sleep(1)
        print(f"      Loaded: AVALIA CONSULTING LLC")
        page.screenshot(path=f'{SS}ar_1_loaded.png', full_page=True)

        # ======== STEP 2: Edit Officer ========
        print("[2/6] Editing officer (AMBR)...")
        page.get_by_text('Edit or Delete Manager').click()
        time.sleep(2)

        # Verify the edit form opened
        last_field = page.query_selector('input[name="Officer.LastName"]')
        first_field = page.query_selector('input[name="Officer.FirstName"]')

        if last_field and first_field:
            old_last = last_field.input_value()
            old_first = first_field.input_value()
            print(f"      Current: {old_last}, {old_first}")

            last_field.fill('Valido Delgado')
            first_field.fill('Alberto')
            print(f"      Changed: Valido Delgado, Alberto")

            page.screenshot(path=f'{SS}ar_2_officer_filled.png', full_page=True)

            # Click "Save Manager/Authorized Member/Authorized Representative"
            save_btn = page.get_by_text('Save Manager/Authorized Member/Authorized Representative')
            save_btn.click()
            time.sleep(2)
            print(f"      Saved officer changes")
            page.screenshot(path=f'{SS}ar_3_officer_saved.png', full_page=True)
        else:
            print(f"      ERROR: Officer fields not found")
            page.screenshot(path=f'{SS}ar_2_error.png', full_page=True)
            browser.close()
            return

        # ======== STEP 3: Edit Registered Agent ========
        print("[3/6] Editing registered agent...")

        # After saving officer, we should be back on the main form
        # Click "Edit Agent / Signature"
        try:
            page.get_by_text('Edit Agent / Signature').click()
            time.sleep(2)
            print("      Agent edit form opened")
        except:
            # Try variations
            try:
                page.get_by_text('Edit Agent').first.click()
                time.sleep(2)
                print("      Agent edit form opened (alt)")
            except Exception as e:
                print(f"      ERROR clicking agent edit: {e}")
                # Debug: dump all visible text
                clickables = page.evaluate("""() => {
                    const results = [];
                    document.querySelectorAll('a, button, [onclick]').forEach(el => {
                        if (el.offsetParent !== null) {
                            results.push(el.textContent.trim().substring(0, 80));
                        }
                    });
                    return results;
                }""")
                for c in clickables:
                    if c:
                        print(f"        visible: [{c}]")

        page.screenshot(path=f'{SS}ar_4_agent_edit.png', full_page=True)

        # Map visible fields
        visible_inputs = page.evaluate("""() => {
            const results = [];
            document.querySelectorAll('input[type="text"]').forEach(el => {
                if (el.offsetParent !== null) {
                    results.push({ name: el.name || el.id, value: el.value });
                }
            });
            return results;
        }""")

        print("      Visible fields:")
        for inp in visible_inputs:
            print(f"        {inp['name']}: '{inp['value']}'")

        # Fill agent fields
        agent_last = page.query_selector('input[name="Agent.LastName"], input[name="RegisteredAgent.LastName"]')
        agent_first = page.query_selector('input[name="Agent.FirstName"], input[name="RegisteredAgent.FirstName"]')
        agent_sig = page.query_selector('input[name="Agent.Signature"], input[name="RegisteredAgent.Signature"], input[name*="Signature"]')

        # Try broader selectors if specific ones fail
        if not agent_last:
            for inp in visible_inputs:
                if 'last' in inp['name'].lower():
                    agent_last = page.query_selector(f'input[name="{inp["name"]}"]')
                    break
        if not agent_first:
            for inp in visible_inputs:
                if 'first' in inp['name'].lower():
                    agent_first = page.query_selector(f'input[name="{inp["name"]}"]')
                    break
        if not agent_sig:
            for inp in visible_inputs:
                if 'sign' in inp['name'].lower():
                    agent_sig = page.query_selector(f'input[name="{inp["name"]}"]')
                    break

        if agent_last:
            old = agent_last.input_value()
            agent_last.fill('Valido Delgado')
            print(f"      Last: '{old}' → 'Valido Delgado'")
        if agent_first:
            old = agent_first.input_value()
            agent_first.fill('Alberto')
            print(f"      First: '{old}' → 'Alberto'")
        if agent_sig:
            old = agent_sig.input_value()
            agent_sig.fill('Alberto Valido Delgado')
            print(f"      Signature: '{old}' → 'Alberto Valido Delgado'")

        page.screenshot(path=f'{SS}ar_5_agent_filled.png', full_page=True)

        # Save agent changes
        try:
            save = page.get_by_text('Save', exact=False)
            # Find the visible save button
            all_saves = page.query_selector_all('input[type="submit"], button')
            for s in all_saves:
                if s.is_visible():
                    text = s.get_attribute('value') or ''
                    try:
                        text = s.inner_text()
                    except:
                        pass
                    if 'save' in text.lower() or 'agent' in text.lower():
                        s.click()
                        time.sleep(2)
                        print(f"      Saved agent: [{text}]")
                        break
        except:
            pass

        page.screenshot(path=f'{SS}ar_6_agent_saved.png', full_page=True)

        # ======== STEP 4: Certificate of Status ========
        print("[4/6] Certificate of Status...")
        # Select "No" for certificate (or Yes if desired)
        try:
            page.get_by_text('No', exact=True).click()
            time.sleep(1)
            print("      Selected: No certificate")
        except:
            print("      Certificate option not found or already set")

        # ======== STEP 5: Move to Final Review ========
        print("[5/6] Moving to Final Review...")
        try:
            page.get_by_text('Move on to the Final Review').click()
            time.sleep(2)
            print("      Final review page loaded")
        except:
            print("      Could not find 'Move on to Final Review'")
            # Try by link text
            try:
                page.click('text=Final Review')
                time.sleep(2)
            except:
                pass

        page.screenshot(path=f'{SS}ar_7_final_review.png', full_page=True)

        # ======== STEP 6: Dump final state ========
        print("\n[6/6] FINAL STATE:")
        print("=" * 60)

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 2 and len(line) < 300:
                print(f"  {line}")

        print("=" * 60)
        print(f"\n  Entity:  AVALIA CONSULTING LLC")
        print(f"  Doc #:   {DOC_NUMBER}")
        print(f"  Fee:     $138.75")
        print(f"  URL:     {page.url}")
        print(f"\n  *** FORM IS READY BUT NOT SUBMITTED ***")
        print(f"  *** No payment has been made ***")
        print(f"  *** Screenshots: ar_1 through ar_7 ***")

        browser.close()

if __name__ == '__main__':
    file_ar()
