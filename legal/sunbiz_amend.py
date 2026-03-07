#!/usr/bin/env python3
"""
Amend AVALIA CONSULTING LLC on Sunbiz:
  - Update officer (AMBR) name: DENORCHIA, ALEC → VALIDO DELGADO, ALBERTO
  - Update registered agent: DeNorchia, Alec → Alberto Valido Delgado
  - Update address if needed

Navigates the Sunbiz e-filing portal to find the correct forms.
Does NOT submit — stops for review.
"""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

DOC_NUMBER = 'L19000154273'
ENTITY_NAME = 'AVALIA CONSULTING LLC'

# New officer info
NEW_OFFICER = {
    'last_name': 'Valido Delgado',
    'first_name': 'Alberto',
    'title': 'AMBR',  # Authorized Member
}

# New RA info
NEW_RA = {
    'last_name': 'Valido Delgado',
    'first_name': 'Alberto',
}

def explore_efile():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                       'AppleWebKit/537.36 (KHTML, like Gecko) '
                       'Chrome/120.0.0.0 Safari/537.36'
        )

        # Step 1: Check what filing options exist at efile.sunbiz.org
        print("=" * 60)
        print("STEP 1: Exploring Sunbiz e-filing portal")
        print("=" * 60)

        page.goto('https://efile.sunbiz.org/')
        page.wait_for_load_state('networkidle')
        print(f"Title: {page.title()}")
        print(f"URL: {page.url}")

        # Find all links on the main page
        links = page.query_selector_all('a')
        for link in links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and len(text) > 2 and len(text) < 100:
                # Look for amendment, change, annual report, LLC-related links
                if any(kw in text.lower() for kw in [
                    'amend', 'change', 'annual', 'report', 'llc',
                    'limited', 'update', 'registered', 'agent',
                    'officer', 'member', 'existing', 'file',
                ]):
                    print(f"  [{text}] -> {href}")

        # Step 2: Try the LLC amendment page directly
        print("\n" + "=" * 60)
        print("STEP 2: Looking for LLC amendment forms")
        print("=" * 60)

        # Common Sunbiz e-filing URLs for LLC changes
        urls_to_try = [
            ('LLC Amendment', 'https://efile.sunbiz.org/llc_amend.html'),
            ('LLC RA Change', 'https://efile.sunbiz.org/llc_ra_chg.html'),
            ('LLC Annual Report', 'https://efile.sunbiz.org/llc_ar.html'),
            ('Annual Report Portal', 'https://efile.sunbiz.org/ann_report.html'),
            ('Change RA', 'https://efile.sunbiz.org/change_ra.html'),
            ('Amendment', 'https://efile.sunbiz.org/amend.html'),
        ]

        for name, url in urls_to_try:
            page.goto(url)
            page.wait_for_load_state('networkidle')
            title = page.title()
            current_url = page.url
            status = 'FOUND' if '404' not in title.lower() and 'error' not in title.lower() else 'NOT FOUND'

            if status == 'FOUND' and current_url != 'https://efile.sunbiz.org/':
                print(f"\n  {name}: {status}")
                print(f"    URL: {current_url}")
                print(f"    Title: {title}")

                # Look for doc number input or any relevant fields
                inputs = page.query_selector_all('input[type="text"], input[type="number"]')
                for inp in inputs:
                    inp_name = inp.get_attribute('name') or inp.get_attribute('id') or '?'
                    print(f"    Input field: {inp_name}")

                # Look for submit buttons
                submits = page.query_selector_all('input[type="submit"], button[type="submit"]')
                for sub in submits:
                    val = sub.get_attribute('value') or sub.inner_text().strip()
                    print(f"    Submit: [{val}]")

                # Look for disclaimers/checkboxes
                checks = page.query_selector_all('input[type="checkbox"]')
                for chk in checks:
                    chk_name = chk.get_attribute('name') or chk.get_attribute('id') or '?'
                    print(f"    Checkbox: {chk_name}")
            else:
                print(f"\n  {name}: NOT FOUND or redirected")

        # Step 3: Try the annual report system (most common way to update officers)
        print("\n" + "=" * 60)
        print("STEP 3: Annual Report / Entity Filing System")
        print("=" * 60)

        # The annual report system typically asks for document number
        ar_urls = [
            'https://efile.sunbiz.org/ar_filing.html',
            'https://efile.sunbiz.org/annual_report.html',
            'https://efile.sunbiz.org/llc_annual.html',
        ]

        for url in ar_urls:
            page.goto(url)
            page.wait_for_load_state('networkidle')
            if page.url != 'https://efile.sunbiz.org/' and '404' not in page.title().lower():
                print(f"  Found: {page.url}")
                print(f"  Title: {page.title()}")
                body_text = page.inner_text('body')
                for line in body_text.split('\n'):
                    line = line.strip()
                    if line and len(line) > 5 and len(line) < 200:
                        if any(kw in line.lower() for kw in [
                            'document', 'number', 'enter', 'file',
                            'annual', 'report', 'llc', 'amend',
                        ]):
                            print(f"    {line}")

        # Step 4: Navigate from the main page to find LLC-specific options
        print("\n" + "=" * 60)
        print("STEP 4: Main portal — all filing links")
        print("=" * 60)

        page.goto('https://efile.sunbiz.org/')
        page.wait_for_load_state('networkidle')

        # Get ALL links
        all_links = page.query_selector_all('a')
        print(f"  Total links on main page: {len(all_links)}")
        for link in all_links:
            text = link.inner_text().strip()
            href = link.get_attribute('href') or ''
            if text and len(text) > 2:
                print(f"  [{text}] -> {href}")

        # Step 5: Check the entity detail page for filing options
        print("\n" + "=" * 60)
        print("STEP 5: Entity detail page — look for 'File' links")
        print("=" * 60)

        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        si = page.query_selector('#SearchTerm')
        si.fill('AVALIA CONSULTING')
        page.click('input[type="submit"], button[type="submit"]')
        page.wait_for_load_state('networkidle')

        results = page.query_selector_all('a[href*="SearchResultDetail"]')
        for r in results[:5]:
            text = r.inner_text().strip()
            if 'AVALIA' in text:
                print(f"  Found: {text}")
                href = r.get_attribute('href')
                full_url = f'https://search.sunbiz.org{href}' if href.startswith('/') else href
                page.goto(full_url)
                page.wait_for_load_state('networkidle')

                # Dump the full entity detail
                body = page.inner_text('body')
                print("\n  --- CURRENT ENTITY RECORD ---")
                for line in body.split('\n'):
                    line = line.strip()
                    if line and len(line) > 2 and len(line) < 200:
                        print(f"  {line}")

                # Look for any filing/amendment links on the detail page
                detail_links = page.query_selector_all('a')
                print("\n  --- LINKS ON DETAIL PAGE ---")
                for dl in detail_links:
                    dt = dl.inner_text().strip()
                    dh = dl.get_attribute('href') or ''
                    if dt and len(dt) > 2 and any(kw in dt.lower() for kw in [
                        'file', 'amend', 'change', 'annual', 'report', 'update', 'efile'
                    ]):
                        print(f"  [{dt}] -> {dh}")

                break

        # Take a screenshot of the entity page
        page.screenshot(
            path='/Users/rnir_hrc_avd/Backup/L7_WAY/legal/sunbiz_entity_current.png',
            full_page=True
        )
        print("\n  Screenshot saved: legal/sunbiz_entity_current.png")

        browser.close()

if __name__ == '__main__':
    explore_efile()
