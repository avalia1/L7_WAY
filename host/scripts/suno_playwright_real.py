import asyncio
from playwright.async_api import async_playwright

async def generate_oshun_music():
    prompt = "Lush melodic strings, soft flowing water sounds, shimmering golden bells, peaceful and divine, spiritual feminine energy, slow and reverent, 78bpm, cinematic spiritual atmosphere"

    print("Launching browser for Suno...")

    async with async_playwright() as p:\n        context = await p.chromium.launch_persistent_context(\n            "./suno_session",
            headless=False
        )
        page = await context.new_page()
        await page.goto("https://suno.com/create")
        await page.wait_for_load_state("networkidle")

        try:
            textarea = page.locator('textarea').first
            await textarea.fill(prompt)
            await page.locator('button:has-text("Create")').click()
            print("Prompt submitted to Suno. Waiting for generation...")
            await page.wait_for_timeout(60000)
        except Exception as e:\n            print(f"Error: {e}")

        await context.close()

asyncio.run(generate_oshun_music())
