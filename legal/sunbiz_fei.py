#!/usr/bin/env python3
"""Search Sunbiz by FEI/EIN number and other number formats."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def search_by_number():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # Try various number formats
        numbers = [
            '987654321',
            '98-7654321',
            'L26000987654',
            'L26000098765',
            'L25000987654',
            'L26000004321',
        ]

        # First, discover all search types available
        print("[0] Discovering search types...")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
        page.wait_for_load_state('networkidle')
        links = page.query_selector_all('a')
        for link in links:
            href = link.get_attribute('href') or ''
            text = link.inner_text().strip()
            if 'Search' in text or 'search' in href.lower():
                print(f"  {text}: {href}")

        # Try FEI/EIN search if available
        print("\n[1] Searching by FEI/EIN Number")
        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByFeiEinNumber')
        page.wait_for_load_state('networkidle')
        title = page.title()
        print(f"  Page: {title}")

        search_input = page.query_selector('#SearchTerm')
        if search_input:
            search_input.fill('987654321')
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            body = page.inner_text('body')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                for r in results[:10]:
                    print(f"  -> {r.inner_text()}")
                    href = r.get_attribute('href')
                    print(f"     {href}")
            else:
                for line in body.split('\n'):
                    line = line.strip()
                    if line and len(line) > 3 and len(line) < 200:
                        if any(kw in line.lower() for kw in ['no record', 'result', 'found', 'search', '987', 'entity']):
                            print(f"  {line}")
        else:
            print("  No search input found on FEI/EIN page")

        # Try document number searches
        for num in numbers:
            print(f"\n[Doc#] Searching document number: {num}")
            page.goto(f'https://search.sunbiz.org/Inquiry/CorporationSearch/ByDocumentNumber')
            page.wait_for_load_state('networkidle')
            search_input = page.query_selector('#SearchTerm')
            if search_input:
                search_input.fill(num)
                page.click('input[type="submit"], button[type="submit"]')
                page.wait_for_load_state('networkidle')
                results = page.query_selector_all('a[href*="SearchResultDetail"]')
                if results:
                    for r in results[:5]:
                        print(f"  -> {r.inner_text()}")
                        # Click through to detail
                        r.click()
                        page.wait_for_load_state('networkidle')
                        detail = page.inner_text('body')
                        for line in detail.split('\n'):
                            line = line.strip()
                            if line and len(line) > 2:
                                print(f"     {line}")
                        break
                else:
                    t = page.title()
                    if 'Error' in t or 'error' in t.lower():
                        print(f"  -> Error page")
                    else:
                        print(f"  -> No match (page: {t})")

        browser.close()

if __name__ == '__main__':
    search_by_number()
