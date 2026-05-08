import glob
import re

premium_config = """  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            brand: { DEFAULT: '#E8560A', hover: '#C94208', light: '#FFF0E5' },
            brown: { DEFAULT: '#271200', muted: 'rgba(39, 18, 0, 0.42)', light: 'rgba(39, 18, 0, 0.06)' },
            cream: '#FBF7F2',
            line: '#EBE1D6',
            success: '#1A7A38',
            danger: '#C0001A',
          },
          fontFamily: {
            display: ['"Montreux Classic"', 'sans-serif'],
            sans: ['"Recoleta"', 'serif'],
          },
          boxShadow: {
            soft: '0 4px 24px rgba(39, 18, 0, 0.04), 0 1px 2px rgba(39, 18, 0, 0.02)',
            premium: '0 20px 40px -10px rgba(39,18,0,0.08), 0 1px 3px rgba(39,18,0,0.05)',
            glow: '0 8px 24px rgba(232, 86, 10, 0.25)',
            'brand-glow': '0 10px 30px -10px rgba(232,86,10,0.4), 0 4px 10px rgba(232,86,10,0.2)',
            float: '0 -12px 32px rgba(39, 18, 0, 0.04)',
            inset_soft: 'inset 0 2px 8px rgba(39, 18, 0, 0.04)',
          },
          transitionTimingFunction: {
            'spring': 'cubic-bezier(0.16, 1, 0.3, 1)',
          }
        }
      }
    }
  </script>"""

premium_style = """    /* Premium Noise Overlay */
    body::before {
      content: "";
      position: fixed;
      top: 0; left: 0; width: 100vw; height: 100vh;
      pointer-events: none;
      z-index: 9999;
      opacity: 0.025;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
    }"""

for file in glob.glob('*.html'):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace tailwind config block using regex
    content = re.sub(r'  <script>\s*tailwind\.config.*?  </script>', premium_config, content, flags=re.DOTALL)
    
    # Inject noise style right after <style> tag
    if '/* Premium Noise Overlay */' not in content:
        content = content.replace('<style>', f'<style>\n{premium_style}\n')
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print('Applied premium config and noise overlay to all HTML files.')
