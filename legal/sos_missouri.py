#!/usr/bin/env python3
"""Search Missouri SOS for LLC registration."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def search_missouri():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        searches = [
            'Avli Cloud',
            'City Bird',
            'Stillwater Holdings',
            'Meridian Bridge',
            'Valido',
            'Cornerstone Administrative',
            'Clear Summit',
        ]

        for term in searches:
            print(f"\n{'='*50}")
            print(f"Searching Missouri SOS: {term}")
            print('='*50)
            try:
                page.goto('https://bsd.sos.mo.gov/BusinessEntity/BESearch.aspx?SearchType=0', timeout=30000)
                page.wait_for_load_state('networkidle', timeout=15000)

                # Find search input
                search_input = page.query_selector('#MainContent_txtSearchTerm, input[name*="SearchTerm"], input[name*="txtSearch"], input[type="text"]')
                if search_input:
                    search_input.fill(term)
                    # Find and click search button
                    submit = page.query_selector('#MainContent_btnSearch, input[type="submit"], button[type="submit"]')
                    if submit:
                        submit.click()
                        page.wait_for_load_state('networkidle', timeout=15000)

                        body = page.inner_text('body')
                        lines = [l.strip() for l in body.split('\n') if l.strip()]
                        # Print relevant results
                        for line in lines:
                            if any(kw in line.lower() for kw in [term.lower().split()[0].lower(), 'llc', 'active', 'inactive', 'charter', 'good standing', 'no record', 'no results']):
                                print(f"  {line[:200]}")
                    else:
                        print("  Could not find submit button")
                        # Dump form structure
                        forms = page.query_selector_all('input, button, select')
                        for f in forms[:10]:
                            n = f.get_attribute('name') or f.get_attribute('id') or '?'
                            t = f.get_attribute('type') or '?'
                            print(f"  Form: {n} ({t})")
                else:
                    print("  Could not find search input")
                    # Dump page structure
                    inputs = page.query_selector_all('input')
                    for inp in inputs[:10]:
                        n = inp.get_attribute('name') or inp.get_attribute('id') or '?'
                        print(f"  Input: {n}")
            except Exception as e:
                print(f"  Error: {e}")

        browser.close()

if __name__ == '__main__':
    search_missouri()
