import asyncio
from playwright.async_api import async_playwright
import os

html_files = [
    "splash.html", "onboarding.html", "login.html", "location.html", 
    "address.html", "preferences.html", "home.html", "outlet.html", "detail.html"
]

SCREENSHOT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "screenshots")
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={'width': 400, 'height': 850})
        
        for file in html_files:
            file_path = f"file:///{os.path.abspath(file).replace(chr(92), '/')}"
            print(f"Screenshotting {file}...")
            await page.goto(file_path)
            # wait for GSAP animations to settle
            await page.wait_for_timeout(1500)
            out_path = os.path.join(SCREENSHOT_DIR, f"{file.split('.')[0]}.png")
            await page.screenshot(path=out_path)
            print(f"  -> Saved to {out_path}")
            
        await browser.close()
        print(f"\nAll screenshots saved to: {SCREENSHOT_DIR}")

asyncio.run(main())
