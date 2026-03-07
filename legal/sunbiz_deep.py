#!/usr/bin/env python3
"""Deep Sunbiz search — officer name, Rodrigo Saavedra agent, and EIN."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def deep_search():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # 1. Search registered agent: Rodrigo Saavedra
        print("[1] Registered agent: SAAVEDRA RODRIGO")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByRegisteredAgent')
        page.wait_for_load_state('networkidle')
        search_input = page.query_selector('#SearchTerm')
        if search_input:
            search_input.fill('Saavedra Rodrigo')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:15]:
                    print(f"  -> {r.inner_text()}")
            else:
                # Try to get page text
                body_text = page.inner_text('body')
                for line in body_text.split('\n'):
                    line = line.strip()
                    if line and 'saavedra' in line.lower():
                        print(f"  -> {line[:200]}")

        # 2. Officer/RA search: Valido
        print("\n[2] Officer/RA: VALIDO")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByOfficerRegisteredAgent')
        page.wait_for_load_state('networkidle')
        # Dump the page structure to understand the form
        inputs = page.query_selector_all('input, select')
        for inp in inputs:
            name = inp.get_attribute('name') or inp.get_attribute('id') or 'unknown'
            itype = inp.get_attribute('type') or 'unknown'
            print(f"  Form field: {name} (type={itype})")

        # Try filling whatever search fields exist
        search_fields = page.query_selector_all('input[type="text"]')
        if search_fields:
            search_fields[0].fill('Valido')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:15]:
                    print(f"  -> {r.inner_text()}")
            else:
                print("  -> No results")

        # 3. Officer search: Delgado
        print("\n[3] Officer/RA: DELGADO")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByOfficerRegisteredAgent')
        page.wait_for_load_state('networkidle')
        search_fields = page.query_selector_all('input[type="text"]')
        if search_fields:
            search_fields[0].fill('Delgado Alberto')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:15]:
                    text = r.inner_text()
                    href = r.get_attribute('href')
                    print(f"  -> {text}")
                    print(f"     {href}")
            else:
                print("  -> No results")

        # 4. Try entity name: AVLI (broader)
        print("\n[4] Entity name: AVLI")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        search_input = page.query_selector('#SearchTerm')
        if search_input:
            search_input.fill('AVLI')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:10]:
                    text = r.inner_text()
                    print(f"  -> {text}")
            else:
                print("  -> No results")

        # 5. Try entity name: City Bird
        print("\n[5] Entity name: CITY BIRD")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        search_input = page.query_selector('#SearchTerm')
        if search_input:
            search_input.fill('City Bird')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:10]:
                    text = r.inner_text()
                    print(f"  -> {text}")
            else:
                print("  -> No results")

        browser.close()

if __name__ == '__main__':
    deep_search()
