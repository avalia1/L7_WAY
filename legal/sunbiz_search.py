#!/usr/bin/env python3
"""Search Sunbiz for LLC registration using Playwright."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright
import json

def search_sunbiz():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # Search by document number
        doc_number = '987654321'
        print(f"[1] Searching Sunbiz by document number: {doc_number}")
        page.goto(f'https://search.sunbiz.org/Inquiry/CorporationSearch/SearchByDocumentNumber?SearchTerm={doc_number}')
        page.wait_for_load_state('networkidle')
        content1 = page.content()
        print(f"    Page title: {page.title()}")
        print(f"    Content length: {len(content1)}")

        # Check if we got results or a detail page
        if 'No Records Found' in content1 or 'no entities' in content1.lower():
            print("    -> No results for document number search")
        else:
            # Try to extract entity details
            try:
                details = page.query_selector_all('.searchResultDetail, .detailSection, table')
                for d in details[:10]:
                    print(f"    -> {d.inner_text()[:200]}")
            except:
                pass

        # Search by entity name: Avli Cloud
        print(f"\n[2] Searching by entity name: Avli Cloud")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        try:
            search_input = page.query_selector('#SearchTerm')
            if search_input:
                search_input.fill('Avli Cloud')
                page.click('input[type="submit"], button[type="submit"]')
                page.wait_for_load_state('networkidle')
                content2 = page.content()
                print(f"    Page title: {page.title()}")
                results = page.query_selector_all('a[href*="SearchResultDetail"]')
                if results:
                    for r in results[:5]:
                        print(f"    -> {r.inner_text()}")
                        href = r.get_attribute('href')
                        print(f"       URL: {href}")
                else:
                    print("    -> No entity name results")
                    # Print any visible text
                    body = page.query_selector('body')
                    if body:
                        text = body.inner_text()
                        # Find relevant parts
                        for line in text.split('\n'):
                            line = line.strip()
                            if line and len(line) > 3 and len(line) < 200:
                                if any(kw in line.lower() for kw in ['no record', 'result', 'found', 'search', 'avli', 'cloud']):
                                    print(f"       {line}")
            else:
                print("    -> Could not find search input")
        except Exception as e:
            print(f"    -> Error: {e}")

        # Search by registered agent: Saavedra
        print(f"\n[3] Searching by registered agent name: Saavedra")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByRegisteredAgent')
        page.wait_for_load_state('networkidle')
        try:
            search_input = page.query_selector('#SearchTerm')
            if search_input:
                search_input.fill('Saavedra')
                page.click('input[type="submit"], button[type="submit"]')
                page.wait_for_load_state('networkidle')
                results = page.query_selector_all('a[href*="SearchResultDetail"]')
                if results:
                    for r in results[:10]:
                        text = r.inner_text()
                        print(f"    -> {text}")
                else:
                    print("    -> No registered agent results")
                    body = page.query_selector('body')
                    if body:
                        text = body.inner_text()
                        for line in text.split('\n'):
                            line = line.strip()
                            if line and len(line) > 3 and len(line) < 200:
                                if any(kw in line.lower() for kw in ['no record', 'result', 'found', 'saavedra']):
                                    print(f"       {line}")
            else:
                print("    -> Could not find search input")
        except Exception as e:
            print(f"    -> Error: {e}")

        # Also search by officer/agent name: Valido
        print(f"\n[4] Searching by officer/registered agent: Valido")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByOfficerRegisteredAgent')
        page.wait_for_load_state('networkidle')
        try:
            search_input = page.query_selector('#SearchTerm')
            if search_input:
                search_input.fill('Valido')
                page.click('input[type="submit"], button[type="submit"]')
                page.wait_for_load_state('networkidle')
                results = page.query_selector_all('a[href*="SearchResultDetail"]')
                if results:
                    for r in results[:10]:
                        text = r.inner_text()
                        print(f"    -> {text}")
                else:
                    print("    -> No officer results")
            else:
                print("    -> Could not find search input")
        except Exception as e:
            print(f"    -> Error: {e}")

        browser.close()

if __name__ == '__main__':
    search_sunbiz()
