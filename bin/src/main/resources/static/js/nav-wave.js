(() => {
  const nav = document.querySelector('.pt-nav');
  if (!nav) return;

  const waveItems = Array.from(nav.querySelectorAll('a.pt-wave'));
  const simpleItems = Array.from(nav.querySelectorAll('a.pt-simple'));

  const setWave = (idx) => {
    waveItems.forEach((el, i) => {
      const d = Math.abs(i - idx);
      let s = 1;
      let y = 0;

      // ▼ 아래로 '파도'가 내려앉는 느낌 (요청사항)
      // - 중심이 가장 많이 내려가고, 양 옆이 그 다음, 멀어질수록 0
      if (d === 0){ s = 1.10; y = 6; }
      else if (d === 1){ s = 1.06; y = 3; }
      else if (d === 2){ s = 1.03; y = 1; }

      el.style.transform = `translateY(${y}px) scale(${s})`;
      el.style.opacity = d <= 2 ? '1' : '0.92';
    });
  };

  const resetWave = () => {
    waveItems.forEach((el) => {
      el.style.transform = '';
      el.style.opacity = '';
    });
  };

  waveItems.forEach((el, idx) => {
    el.addEventListener('mouseenter', () => setWave(idx));
    el.addEventListener('focus', () => setWave(idx));
  });

  nav.addEventListener('mouseleave', resetWave);
  nav.addEventListener('focusout', (e) => {
    if (!nav.contains(e.relatedTarget)) resetWave();
  });

  simpleItems.forEach((el) => {
    el.addEventListener('mouseenter', () => {
      el.style.transform = 'scale(1.06)';
    });
    el.addEventListener('mouseleave', () => {
      el.style.transform = '';
    });
    el.addEventListener('focus', () => {
      el.style.transform = 'scale(1.06)';
    });
    el.addEventListener('blur', () => {
      el.style.transform = '';
    });
  });
})();
