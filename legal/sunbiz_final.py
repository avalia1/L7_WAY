#!/usr/bin/env python3
"""Final search round — new terms + drill into DELGADO ALBERTO entities."""
import sys
sys.path.insert(0, '/Users/rnir_hrc_avd/Library/Python/3.9/lib/python/site-packages')

from playwright.sync_api import sync_playwright

def search():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )

        # New terms from the Philosopher
        names = [
            'YHVH', 'Bonterra', 'Baitaivah', 'IOU',
            'Avalia Consulting',
        ]

        for name in names:
            page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByName')
            page.wait_for_load_state('networkidle')
            si = page.query_selector('#SearchTerm')
            si.fill(name)
            page.click('input[type="submit"], button[type="submit"]')
            page.wait_for_load_state('networkidle')
            results = page.query_selector_all('a[href*="SearchResultDetail"]')
            if results:
                print(f"\n{name}:")
                for r in results[:5]:
                    text = r.inner_text().strip()
                    print(f"  -> {text}")

                    # Click into exact/close matches
                    if name.upper().replace(' ', '') in text.upper().replace(' ', ''):
                        href = r.get_attribute('href')
                        page.goto(f'https://search.sunbiz.org{href}' if href.startswith('/') else href)
                        page.wait_for_load_state('networkidle')
                        body = page.inner_text('body')
                        for line in body.split('\n'):
                            line = line.strip()
                            if line and len(line) > 2 and len(line) < 200:
                                print(f"     {line}")
                        page.go_back()
                        page.wait_for_load_state('networkidle')
                        break
            else:
                print(f"{name}: (no results)")

        # Drill into DELGADO, ALBERTO officer entries
        print("\n" + "=" * 60)
        print("DRILLING INTO DELGADO, ALBERTO OFFICER ENTRIES")
        print("=" * 60)

        page.goto('https://search.sunbiz.org/Inquiry/CorporationSearch/ByOfficerOrRegisteredAgent')
        page.wait_for_load_state('networkidle')
        si = page.query_selector('#SearchTerm')
        si.fill('Delgado Alberto')
        page.click('input[type="submit"], button[type="submit"]')
        page.wait_for_load_state('networkidle')

        results = page.query_selector_all('a[href*="SearchResultDetail"]')
        entries = []
        for r in results[:15]:
            text = r.inner_text().strip()
            href = r.get_attribute('href')
            if 'DELGADO, ALBERTO' in text or 'DELGADO , ALBERTO' in text:
                entries.append((text, href))

        for i, (text, href) in enumerate(entries[:10]):
            print(f"\n--- Entry {i+1}: {text} ---")
            full_url = f'https://search.sunbiz.org{href}' if href.startswith('/') else href
            page.goto(full_url)
            page.wait_for_load_state('networkidle')
            body = page.inner_text('body')
            for line in body.split('\n'):
                line = line.strip()
                if line and len(line) > 2 and len(line) < 200:
                    # Filter to key details
                    if any(kw in line for kw in [
                        'Document', 'Date Filed', 'Status', 'EIN', 'FEI',
                        'Principal', 'Registered', 'Name', 'Address',
                        'DELGADO', 'VALIDO', 'ALBERTO', 'LLC', 'Corp',
                        'Title', 'AMBR', 'MGR', 'Active', 'Inactive',
                        'Fort Lauderdale', 'Miami', 'Florida',
                        'Profit', 'Limited', 'Avli', 'Avalia',
                        'Cloud', 'Technology', 'L7', 'Apex',
                        'Saavedra', 'Bonterra', 'YHVH',
                    ]):
                        print(f"  {line}")

        browser.close()

if __name__ == '__main__':
    search()
