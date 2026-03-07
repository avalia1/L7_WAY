#!/usr/bin/env python3
"""Search Sunbiz for AVD, HRC, NRI entities."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def search():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        terms = ['AVD', 'HRC', 'NRI', 'AVD HRC', 'RNIR', 'AVLI']

        for term in terms:
            print(f"\n{'='*50}")
            print(f"Entity name search: {term}")
            print('='*50)
            page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
            page.wait_for_load_state('networkidle')
            si = page.query_selector('#SearchTerm')
            si.fill(term)
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')

            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:8]:
                    text = r.inner_text().strip()
                    print(f"  -> {text}")
            else:
                print("  -> No results")

        # Also try officer/RA search with correct URL
        print(f"\n{'='*50}")
        print("Officer/RA search: VALIDO DELGADO")
        print('='*50)
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByOfficerOrRegisteredAgent')
        page.wait_for_load_state('networkidle')
        si = page.query_selector('#SearchTerm')
        if si:
            si.fill('Valido Delgado')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:10]:
                    text = r.inner_text().strip()
                    print(f"  -> {text}")
            else:
                print("  -> No results")
        else:
            # Try all text inputs
            inputs = page.query_selector_all('input[type="text"]')
            print(f"  Found {len(inputs)} text inputs")
            if inputs:
                inputs[0].fill('Valido')
                page.click('input[type="submit"], button[type="submit"]')
                page.wait_for_load_state('networkidle')
                results = page.query_selector_all('a[href*="SearchResultDetail"]')
                if results:
                    for r in results[:10]:
                        print(f"  -> {r.inner_text().strip()}")
                else:
                    print("  -> No results")

        browser.close()

if __name__ == '__main__':
    search()
