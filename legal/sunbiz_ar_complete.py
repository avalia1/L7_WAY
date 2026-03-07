#!/usr/bin/env python3
"""
File 2026 Annual Report for AVALIA CONSULTING LLC (L19000154273).
Complete flow:
  1. Load entity
  2. Edit officer: DENORCHIA, ALEC → Valido Delgado, Alberto
  3. Save officer
  4. Edit RA: DeNorchia, Alec → Valido Delgado, Alberto
  5. Sign RA: Alberto Valido Delgado
  6. Save RA
  7. Move to Final Review
  8. STOP — screenshot for Philosopher approval before payment

Does NOT submit payment.
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
        print("[1/7] Loading entity...")
        page.goto('https://services.sunbiz.org/Filings/AnnualReport/FilingStart')
        page.wait_for_load_state('networkidle')
        page.fill('input[name="DocumentId"]', DOC_NUMBER)
        page.click('input[type="submit"]')
        page.wait_for_load_state('networkidle')
        time.sleep(1)
        print("      AVALIA CONSULTING LLC — L19000154273 — $138.75")
        page.screenshot(path=f'{SS}ar_1_loaded.png', full_page=True)

        # ======== STEP 2: Edit Officer ========
        print("[2/7] Opening officer edit form...")
        page.get_by_text('Edit or Delete Manager').click()
        time.sleep(2)
        page.screenshot(path=f'{SS}ar_2_officer_form.png', full_page=True)

        # Fill officer fields
        last_f = page.query_selector('input[name="Officer.LastName"]')
        first_f = page.query_selector('input[name="Officer.FirstName"]')
        if last_f and first_f:
            print(f"      Current: {last_f.input_value()}, {first_f.input_value()}")
            last_f.fill('Valido Delgado')
            first_f.fill('Alberto')
            print("      Changed: Valido Delgado, Alberto")
        else:
            print("      ERROR: Officer name fields not found")
            browser.close()
            return

        # ======== STEP 3: Save Officer ========
        print("[3/7] Saving officer...")
        page.get_by_text('Save Manager/Authorized Member/Authorized Representative').click()
        time.sleep(2)
        page.screenshot(path=f'{SS}ar_3_officer_saved.png', full_page=True)

        # Verify the save took effect — check the main page shows new name
        body = page.inner_text('body')
        if 'Valido Delgado' in body or 'VALIDO DELGADO' in body:
            print("      VERIFIED: Officer name updated on main page")
        else:
            print("      WARNING: Officer name not visible on main page yet")

        # ======== STEP 4: Edit Registered Agent ========
        print("[4/7] Opening RA edit form...")
        page.get_by_text('Edit Agent / Signature').click()
        time.sleep(2)
        page.screenshot(path=f'{SS}ar_4_agent_form.png', full_page=True)

        # Fill RA fields
        ra_last = page.query_selector('input[name="RegisteredAgentName.LastName"]')
        ra_first = page.query_selector('input[name="RegisteredAgentName.FirstName"]')
        ra_sig = page.query_selector('input[name="RegisteredAgentName.AgentSignature"]')

        if ra_last:
            print(f"      RA Current: {ra_last.input_value()}, {ra_first.input_value() if ra_first else '?'}")
            ra_last.fill('Valido Delgado')
            print("      RA Last: Valido Delgado")
        if ra_first:
            ra_first.fill('Alberto')
            print("      RA First: Alberto")
        if ra_sig:
            ra_sig.fill('Alberto Valido Delgado')
            print("      RA Signature: Alberto Valido Delgado")
        else:
            print("      WARNING: RA signature field not found")

        page.screenshot(path=f'{SS}ar_5_agent_filled.png', full_page=True)

        # ======== STEP 5: Save Registered Agent ========
        print("[5/7] Saving registered agent...")
        page.get_by_text('Save Registered Agent').click()
        time.sleep(2)
        page.screenshot(path=f'{SS}ar_6_agent_saved.png', full_page=True)

        # Verify
        body = page.inner_text('body')
        if 'Valido Delgado' in body:
            print("      VERIFIED: RA name updated")
        else:
            print("      WARNING: RA name not visible yet")

        # Print the full current state
        print("\n      Current form state:")
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 2 and len(line) < 200:
                if any(kw in line.upper() for kw in [
                    'VALIDO', 'DELGADO', 'ALBERTO', 'DENORCHIA', 'ALEC',
                    'AMBR', 'AGENT', 'SIGNATURE', 'REGISTERED',
                    'MANAGER', 'TITLE', '84-2183945',
                ]):
                    print(f"        {line}")

        # ======== STEP 6: Certificate and Final Review ========
        print("[6/7] Moving to Final Review...")

        # Select No for certificate
        try:
            no_radio = page.query_selector('input[type="radio"][value="false"], input[type="radio"][value="False"], input[type="radio"][value="No"]')
            if no_radio and no_radio.is_visible():
                no_radio.click()
                print("      Certificate: No")
        except:
            pass

        # Click "Move on to the Final Review"
        try:
            page.get_by_text('Move on to the Final Review').click()
            time.sleep(2)
            print("      Final Review page loaded")
        except:
            # Try clicking the "Final Review" tab
            try:
                page.click('text=Final Review')
                time.sleep(2)
                print("      Final Review tab clicked")
            except:
                # Try any submit/continue button
                try:
                    page.evaluate("""() => {
                        document.querySelectorAll('a, button, input[type="submit"]').forEach(el => {
                            const t = el.textContent || el.value || '';
                            if (/move.*final|final.*review|continue|next|proceed/i.test(t) && el.offsetParent !== null) {
                                el.click();
                            }
                        });
                    }""")
                    time.sleep(2)
                except:
                    pass

        page.screenshot(path=f'{SS}ar_7_final_review.png', full_page=True)

        # ======== STEP 7: Final Review Dump ========
        print("\n[7/7] FINAL REVIEW:")
        print("=" * 60)

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 2 and len(line) < 300:
                print(f"  {line}")

        print("=" * 60)
        print(f"\n  Entity:    AVALIA CONSULTING LLC")
        print(f"  Doc #:     {DOC_NUMBER}")
        print(f"  EIN:       84-2183945")
        print(f"  Fee:       $138.75")
        print(f"  Changes:   Officer DENORCHIA→VALIDO DELGADO, RA same")
        print(f"  URL:       {page.url}")
        print(f"\n  *** READY FOR PHILOSOPHER'S APPROVAL ***")
        print(f"  *** No payment has been made ***")

        browser.close()

if __name__ == '__main__':
    file_ar()
