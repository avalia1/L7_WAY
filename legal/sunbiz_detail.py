#!/usr/bin/env python3
"""Pull Sunbiz details for AVLI INC and Saavedra-linked entities."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def get_details():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # 1. Get AVLI INC details
        print("=" * 60)
        print("[1] AVLI INC — Entity Details")
        print("=" * 60)
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        search_input = page.query_selector('#SearchTerm')
        search_input.fill('AVLI')
        page.click('input[type="submit"], button[type="submit"]')
        page.wait_for_load_state('networkidle')

        # Click on AVLI INC
        results = page.query_selector_all('a[href*="SearchResultDetail"]')
        for r in results:
            if 'AVLI INC' in r.inner_text() or 'AVLI' == r.inner_text().strip():
                href = r.get_attribute('href')
                print(f"  Clicking: {r.inner_text()} -> {href}")
                r.click()
                page.wait_for_load_state('networkidle')

                # Dump all detail content
                body = page.inner_text('body')
                for line in body.split('\n'):
                    line = line.strip()
                    if line:
                        print(f"  {line}")
                print()
                page.go_back()
                page.wait_for_load_state('networkidle')
                break

        # 2. Get entities where Rodrigo Saavedra is RA
        print("=" * 60)
        print("[2] Entities with Rodrigo Saavedra as Registered Agent")
        print("=" * 60)
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByRegisteredAgent')
        page.wait_for_load_state('networkidle')
        search_input = page.query_selector('#SearchTerm')
        search_input.fill('Saavedra Rodrigo')
        page.click('input[type="submit"], button[type="submit"]')
        page.wait_for_load_state('networkidle')

        results = page.query_selector_all('a[href*="SearchResultDetail"]')
        saavedra_entities = []
        for r in results[:8]:
            text = r.inner_text()
            if 'SAAVEDRA, RODRIGO' in text and 'RODRIGUEZ' not in text and 'ROMAN' not in text and 'ROLAND' not in text:
                href = r.get_attribute('href')
                saavedra_entities.append((text, href))
                print(f"  Agent entry: {text}")

        # Click into each unique Rodrigo Saavedra entry to see the companies
        for name, href in saavedra_entities[:4]:
            print(f"\n  --- Clicking: {name} ---")
            page.goto(f'https://search.sunbiz.org{href}' if href.startswith('/') else href)
            page.wait_for_load_state('networkidle')

            body = page.inner_text('body')
            for line in body.split('\n'):
                line = line.strip()
                if line:
                    print(f"    {line}")
            page.go_back()
            page.wait_for_load_state('networkidle')

        browser.close()

if __name__ == '__main__':
    get_details()
