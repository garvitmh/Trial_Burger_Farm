gsap.registerPlugin(MotionPathPlugin);

/* ── SPLASH ORBIT ── */
const ICONS = ['#spI0', '#spI1', '#spI2'];
let orbits = [], ready = true;
gsap.set(ICONS, { xPercent: -50, yPercent: -50 });

function startOrbit() {
  ready = true;
  gsap.set(ICONS, { x: 0, y: 0, scale: 1, opacity: 1 });
  gsap.set('#spBag', { scale: 0 });
  orbits = ICONS.map((s, i) => gsap.to(s, {
    duration: 4, repeat: -1, ease: 'none',
    motionPath: { path: '#spArcPath', align: '#spArcPath', alignOrigin: [.5, .5], start: i * .333, end: i * .333 + 1 }
  }));
}

function packAndGo(cb) {
  ready = false;
  orbits.forEach(t => t.kill());
  const bag = document.getElementById('spBag');
  const tl = gsap.timeline({ onComplete: cb });
  tl.to('#spBag', { scale: 1, duration: .3, ease: 'back.out(2)' });
  ICONS.forEach((s, i) => {
    const el = document.querySelector(s);
    tl.add(() => {
      const ir = el.getBoundingClientRect(), br = bag.getBoundingClientRect();
      gsap.to(s, {
        x: '+=' + (br.left + br.width / 2 - (ir.left + ir.width / 2)),
        y: '+=' + (br.top + br.height / 2 - (ir.top + ir.height / 2)),
        scale: .15, opacity: 0, duration: .38, ease: 'power2.in'
      });
    }, i * .10);
  });
  tl.to('#spBag', { y: -7, duration: .09, yoyo: true, repeat: 1, ease: 'power2.out' }, '+=.28');
}

function handleSplash() {
  if (!ready) return;
  packAndGo(() => setTimeout(() => go('pOb'), 120));
}

/* ── SCREEN ROUTER ── */
const SCREENS = ['pSplash', 'pOb', 'pLogin', 'pPref', 'pLoc', 'pOutlet', 'pAddr', 'pDet', 'pHome'];

function go(id) {
  // Modified to handle separate pages
  const pageMap = {
    'pSplash': 'splash.html',
    'pOb': 'onboarding.html',
    'pLogin': 'login.html',
    'pPref': 'preferences.html',
    'pLoc': 'location.html',
    'pOutlet': 'outlet.html',
    'pAddr': 'address.html',
    'pDet': 'detail.html',
    'pHome': 'home.html'
  };
  if (pageMap[id]) {
    window.location.href = pageMap[id];
  } else {
    // Fallback for same page
    SCREENS.forEach(sid => {
      const el = document.getElementById(sid);
      if (el) { el.classList.remove('on'); el.style.display = ''; }
    });
    const t = document.getElementById(id);
    if (!t) return;
    t.classList.add('on');
    gsap.fromTo(t, { opacity: 0, y: 10 }, { opacity: 1, y: 0, duration: .28, ease: 'power2.out', clearProps: 'all' });
    if (id === 'pSplash') startOrbit();
  }
}

function restart() { go('pSplash'); }

/* ── DIET TOGGLE ── */
function setDiet(d) {
  const v = document.getElementById('vegBtn'), n = document.getElementById('nvBtn');
  if (!v || !n) return;
  v.className = 'pf-tog' + (d === 'veg' ? ' veg' : '');
  n.className = 'pf-tog' + (d === 'nv' ? ' nveg' : '');
}

/* ── FILTER TABS ── */
function setFilter(f) {
  const d = document.getElementById('delTab'), p = document.getElementById('pickTab');
  if (!d || !p) return;
  if (f === 'del') { d.classList.add('on'); p.classList.remove('on'); }
  else { p.classList.add('on'); d.classList.remove('on'); }
}

/* ── ADDRESS TAGS ── */
function setTag(el) {
  document.querySelectorAll('#pDet .det-tag').forEach(t => t.classList.remove('on'));
  el.classList.add('on');
}

/* ── CHIP TOGGLE ── */
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(startOrbit, 260);

  // Entry animations for all screens
  gsap.from('.ph', { y: -30, opacity: 0, duration: 0.6, ease: 'back.out(1.7)' });
  gsap.from('.row', { y: 30, opacity: 0, duration: 0.6, delay: 0.2, ease: 'back.out(1.7)' });

  // Button hover effects
  document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('mouseenter', () => gsap.to(btn, { scale: 1.05, duration: 0.2, ease: 'power2.out' }));
    btn.addEventListener('mouseleave', () => gsap.to(btn, { scale: 1, duration: 0.2, ease: 'power2.out' }));
  });

  // Ghost button hover
  document.querySelectorAll('.btn-ghost').forEach(btn => {
    btn.addEventListener('mouseenter', () => gsap.to(btn, { scale: 1.02, backgroundColor: 'rgba(255,255,255,0.15)', duration: 0.2 }));
    btn.addEventListener('mouseleave', () => gsap.to(btn, { scale: 1, backgroundColor: 'rgba(255,255,255,0.1)', duration: 0.2 }));
  });

  // Outline button hover
  document.querySelectorAll('.btn-outline').forEach(btn => {
    btn.addEventListener('mouseenter', () => gsap.to(btn, { scale: 1.02, borderColor: 'var(--o)', color: 'var(--o)', duration: 0.2 }));
    btn.addEventListener('mouseleave', () => gsap.to(btn, { scale: 1, borderColor: 'var(--line)', color: 'var(--brown)', duration: 0.2 }));
  });

  // Chip interactions
  document.querySelectorAll('.chip').forEach(c => {
    c.addEventListener('click', function () {
      gsap.to(this, { scale: 0.95, duration: 0.1, yoyo: true, repeat: 1, ease: 'power2.inOut' });
      const cur = this.getAttribute('data-on') === 'true';
      this.setAttribute('data-on', !cur);
      const ico = this.querySelector('svg');
      if (ico) ico.setAttribute('fill', !cur ? 'var(--o)' : 'var(--muted)');
    });
    c.addEventListener('mouseenter', () => gsap.to(c, { scale: 1.02, duration: 0.2 }));
    c.addEventListener('mouseleave', () => gsap.to(c, { scale: 1, duration: 0.2 }));
  });

  // Toggle animations
  document.querySelectorAll('.pf-tog').forEach(tog => {
    tog.addEventListener('click', () => {
      gsap.to(tog, { scale: 0.98, duration: 0.1, yoyo: true, repeat: 1 });
    });
  });

  // Floating elements
  gsap.to('.pf-ring', { y: -5, duration: 2, ease: 'power2.inOut', yoyo: true, repeat: -1 });
  gsap.to('.lc-ring', { y: -3, duration: 1.5, ease: 'power2.inOut', yoyo: true, repeat: -1 });

  // Staggered animations for lists
  gsap.from('.out-card', { x: -20, opacity: 0, duration: 0.4, stagger: 0.1, delay: 0.5 });
  gsap.from('.addr-item', { x: -20, opacity: 0, duration: 0.4, stagger: 0.1, delay: 0.5 });

  // Onboarding specific animations
  if (document.querySelector('.sc-ob')) {
    const tl = gsap.timeline();
    tl.from('.ob-dots', { x: -30, opacity: 0, duration: 0.5, ease: 'back.out(1.7)' })
      .from('.ob-h', { y: 20, opacity: 0, duration: 0.6, ease: 'power2.out' }, '-=0.3')
      .from('.ob-p', { y: 10, opacity: 0, duration: 0.4 }, '-=0.3')
      .from('.ob-avs', { x: -20, opacity: 0, duration: 0.5, ease: 'back.out(1.7)' }, '-=0.2')
      .from('.ob-pm, .ob-ps', { y: 10, opacity: 0, duration: 0.3 }, '-=0.3')
      .from('.ob-feat', { y: 20, opacity: 0, duration: 0.6, stagger: 0.15, ease: 'power3.out' }, '-=0.4')
      .from('.ob-cta', { y: 20, opacity: 0, duration: 0.4 }, '-=0.2');

    // Feature card hover
    document.querySelectorAll('.ob-feat').forEach(card => {
      card.addEventListener('mouseenter', () => {
        gsap.to(card, { y: -4, scale: 1.02, duration: 0.4, ease: 'power2.out' });
        gsap.to(card.querySelector('.ob-fi'), { scale: 1.08, rotation: 5, duration: 0.4 });
      });
      card.addEventListener('mouseleave', () => {
        gsap.to(card, { y: 0, scale: 1, duration: 0.4, ease: 'power2.out' });
        gsap.to(card.querySelector('.ob-fi'), { scale: 1, rotation: 0, duration: 0.4 });
      });
    });

    // Social avatars bounce
    gsap.to('.ob-av', { y: -3, duration: 1.5, ease: 'power2.inOut', yoyo: true, repeat: -1, stagger: 0.2 });
  }
});