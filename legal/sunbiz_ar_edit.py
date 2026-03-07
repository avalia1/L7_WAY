#!/usr/bin/env python3
"""
File 2026 Annual Report for AVALIA CONSULTING LLC (L19000154273).
Updates officer and RA from DENORCHIA, ALEC to VALIDO DELGADO, ALBERTO.

Uses JavaScript click handlers since the edit links are dynamic elements.
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

        # Step 1: Load entity
        print("[1] Loading entity...")
        page.goto('https://services.sunbiz.org/Filings/AnnualReport/FilingStart')
        page.wait_for_load_state('networkidle')
        page.fill('input[name="DocumentId"]', DOC_NUMBER)
        page.click('input[type="submit"]')
        page.wait_for_load_state('networkidle')
        time.sleep(1)
        print(f"    Loaded: {page.url}")

        # First, let's dump ALL clickable elements and their attributes
        print("\n[DEBUG] All clickable elements on page:")
        clickables = page.evaluate("""() => {
            const results = [];
            document.querySelectorAll('a, button, input[type="submit"], [onclick], [role="button"]').forEach(el => {
                const text = el.textContent.trim().substring(0, 80);
                const id = el.id || '';
                const href = el.href || '';
                const onclick = el.getAttribute('onclick') || '';
                const cls = el.className || '';
                const tag = el.tagName;
                if (text.length > 0) {
                    results.push({tag, id, href, onclick, cls, text});
                }
            });
            return results;
        }""")

        for el in clickables:
            if any(kw in el['text'].lower() for kw in [
                'edit', 'delete', 'add', 'manager', 'agent', 'signature',
                'save', 'cancel', 'move', 'final', 'review',
            ]):
                print(f"    <{el['tag']}> id='{el['id']}' class='{el['cls'][:40]}' text='{el['text'][:60]}'")
                if el['onclick']:
                    print(f"      onclick='{el['onclick'][:80]}'")
                if el['href']:
                    print(f"      href='{el['href'][:80]}'")

        # Step 2: Click "Edit or Delete Manager"
        print("\n[2] Clicking 'Edit or Delete Manager'...")

        # Try clicking by text content using page.get_by_text
        try:
            page.get_by_text('Edit or Delete Manager').click()
            time.sleep(2)
            print("    Clicked via get_by_text")
        except Exception as e:
            print(f"    get_by_text failed: {e}")
            # Try JavaScript
            clicked = page.evaluate("""() => {
                const els = document.querySelectorAll('a, button, span, div');
                for (const el of els) {
                    if (el.textContent.trim().includes('Edit or Delete Manager')) {
                        el.click();
                        return 'clicked: ' + el.tagName + ' ' + el.id;
                    }
                }
                return 'not found';
            }""")
            print(f"    JS click result: {clicked}")
            time.sleep(2)

        page.screenshot(path=f'{SS}ar_edit_officer.png', full_page=True)

        # Check what changed — new form fields?
        print("\n    Visible form fields after Edit Officer click:")
        visible_inputs = page.evaluate("""() => {
            const results = [];
            document.querySelectorAll('input[type="text"], select, textarea').forEach(el => {
                if (el.offsetParent !== null) {
                    results.push({
                        name: el.name || el.id || '?',
                        value: el.value || '',
                        type: el.type || '?',
                        placeholder: el.placeholder || ''
                    });
                }
            });
            return results;
        }""")

        for inp in visible_inputs:
            print(f"    {inp['name']}: '{inp['value']}' (placeholder: '{inp['placeholder']}')")

        # Try to find officer name fields and fill them
        if visible_inputs:
            # Fill last name
            for inp in visible_inputs:
                name_lower = inp['name'].lower()
                if 'last' in name_lower:
                    page.fill(f'input[name="{inp["name"]}"], input[id="{inp["name"]}"]', 'VALIDO DELGADO')
                    print(f"    FILLED {inp['name']}: VALIDO DELGADO")
                elif 'first' in name_lower:
                    page.fill(f'input[name="{inp["name"]}"], input[id="{inp["name"]}"]', 'ALBERTO')
                    print(f"    FILLED {inp['name']}: ALBERTO")

            # Look for Save/Update button
            save = page.evaluate("""() => {
                const els = document.querySelectorAll('a, button, input[type="submit"]');
                for (const el of els) {
                    const text = el.textContent.trim();
                    if (/save|update|confirm|apply|ok/i.test(text) && el.offsetParent !== null) {
                        el.click();
                        return 'clicked: ' + text;
                    }
                }
                return 'no save button found';
            }""")
            print(f"    Save result: {save}")
            time.sleep(2)

        page.screenshot(path=f'{SS}ar_officer_filled.png', full_page=True)

        # Step 3: Edit Registered Agent / Signature
        print("\n[3] Clicking 'Edit Agent / Signature'...")

        try:
            page.get_by_text('Edit Agent / Signature').click()
            time.sleep(2)
            print("    Clicked via get_by_text")
        except Exception as e:
            print(f"    get_by_text failed: {e}")
            clicked = page.evaluate("""() => {
                const els = document.querySelectorAll('a, button, span, div');
                for (const el of els) {
                    const text = el.textContent.trim();
                    if (text.includes('Edit Agent') || text.includes('Agent / Signature')) {
                        el.click();
                        return 'clicked: ' + el.tagName + ' ' + el.id;
                    }
                }
                return 'not found';
            }""")
            print(f"    JS click result: {clicked}")
            time.sleep(2)

        page.screenshot(path=f'{SS}ar_edit_agent.png', full_page=True)

        # Check for agent form fields
        print("\n    Visible form fields after Edit Agent click:")
        visible_inputs = page.evaluate("""() => {
            const results = [];
            document.querySelectorAll('input[type="text"], select, textarea').forEach(el => {
                if (el.offsetParent !== null) {
                    results.push({
                        name: el.name || el.id || '?',
                        value: el.value || '',
                        type: el.type || '?'
                    });
                }
            });
            return results;
        }""")

        for inp in visible_inputs:
            print(f"    {inp['name']}: '{inp['value']}'")

        # Fill agent fields
        if visible_inputs:
            for inp in visible_inputs:
                name_lower = inp['name'].lower()
                if 'last' in name_lower and 'agent' in name_lower.replace('_', ''):
                    page.fill(f'[name="{inp["name"]}"]', 'Valido Delgado')
                    print(f"    FILLED {inp['name']}: Valido Delgado")
                elif 'first' in name_lower and 'agent' in name_lower.replace('_', ''):
                    page.fill(f'[name="{inp["name"]}"]', 'Alberto')
                    print(f"    FILLED {inp['name']}: Alberto")
                elif 'last' in name_lower:
                    page.fill(f'[name="{inp["name"]}"]', 'Valido Delgado')
                    print(f"    FILLED {inp['name']}: Valido Delgado")
                elif 'first' in name_lower:
                    page.fill(f'[name="{inp["name"]}"]', 'Alberto')
                    print(f"    FILLED {inp['name']}: Alberto")
                elif 'sign' in name_lower:
                    page.fill(f'[name="{inp["name"]}"]', 'Alberto Valido Delgado')
                    print(f"    FILLED {inp['name']}: Alberto Valido Delgado")

            # Save
            save = page.evaluate("""() => {
                const els = document.querySelectorAll('a, button, input[type="submit"]');
                for (const el of els) {
                    const text = el.textContent.trim();
                    if (/save|update|confirm|apply|ok/i.test(text) && el.offsetParent !== null) {
                        el.click();
                        return 'clicked: ' + text;
                    }
                }
                return 'no save button found';
            }""")
            print(f"    Save result: {save}")
            time.sleep(2)

        page.screenshot(path=f'{SS}ar_agent_filled.png', full_page=True)

        # Step 4: Final review page state
        print("\n[4] FINAL STATE:")
        print("=" * 60)

        body = page.inner_text('body')
        for line in body.split('\n'):
            line = line.strip()
            if line and len(line) > 2 and len(line) < 300:
                if any(kw in line.upper() for kw in [
                    'AVALIA', 'VALIDO', 'DELGADO', 'ALBERTO', 'DENORCHIA', 'ALEC',
                    'AMBR', 'AGENT', 'SIGNATURE', 'ADDRESS', 'BOCA', 'FORT',
                    'PRINCIPAL', 'MAILING', 'FEI', 'EIN', 'DOCUMENT', 'STATUS',
                    'FEE', '$', 'FILING', 'NAME', 'MANAGER', 'TITLE', 'STEP',
                    'REVIEW', 'CERTIFICATE',
                ]):
                    print(f"  {line}")

        page.screenshot(path=f'{SS}ar_final.png', full_page=True)

        print("\n*** FORM IS NOT SUBMITTED — Review screenshots ***")
        print(f"*** Fee: $138.75 ***")

        browser.close()

if __name__ == '__main__':
    file_ar()
