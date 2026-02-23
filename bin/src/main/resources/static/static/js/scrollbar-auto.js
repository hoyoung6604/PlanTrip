/*
  scrollbar-auto.js
  - 기본 상태에서는 스크롤바를 최대한 숨기고
  - 마우스 휠/스크롤이 발생할 때만 잠깐 표시
  - 표시/숨김 시 레이아웃 흔들림을 줄이기 위해 scrollbar-gutter를 함께 사용
*/

(function(){
  const root = document.documentElement;
  let timer = null;

  function show(){
    root.classList.add('show-scrollbar');
    if(timer) clearTimeout(timer);
    timer = setTimeout(() => {
      root.classList.remove('show-scrollbar');
    }, 900);
  }

  // wheel이 가장 자연스럽고, touch/키보드 스크롤도 커버
  window.addEventListener('wheel', show, { passive:true });
  window.addEventListener('scroll', show, { passive:true });
  window.addEventListener('keydown', function(e){
    const keys = ['ArrowDown','ArrowUp','PageDown','PageUp','Home','End',' '];
    if(keys.includes(e.key)) show();
  });
  window.addEventListener('touchmove', show, { passive:true });
})();
