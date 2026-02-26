/*
  fabs.js
  - 고객센터(.cs-fab) + 맨 위로(.top-fab) 공통 제어
  - 노출 정책:
      * 숨김: /support/**, /admin/**, /members/mypage/**
      * 그 외 페이지는 모두 노출 (spot/커뮤니티 작성 포함)
  - 맨 위로 버튼은 스크롤이 내려갔을 때만 표시
*/
(function(){
  function normalizePath(){
    var ctx = document.body.getAttribute('data-ctx') || '';
    var p = window.location.pathname || '/';
    if(ctx && p.indexOf(ctx) === 0) p = p.substring(ctx.length) || '/';
    return p;
  }

  function shouldHide(path){
    if(path.indexOf('/admin') === 0) return true;
    if(path.indexOf('/support') === 0) return true;
    if(path.indexOf('/members/mypage') === 0) return true;
    return false;
  }

  function setVisible(el, on){
    if(!el) return;
    el.style.display = on ? '' : 'none';
  }

  function init(){
    var path = normalizePath();
    var cs = document.querySelector('.cs-fab');
    var top = document.querySelector('.top-fab');

    if(shouldHide(path)){
      setVisible(cs, false);
      setVisible(top, false);
      return;
    }

    // 고객센터는 항상 노출
    setVisible(cs, true);

    // 맨 위로는 스크롤 시 노출
    function onScroll(){
      var y = window.scrollY || document.documentElement.scrollTop || 0;
      setVisible(top, y > 260);
    }
    window.addEventListener('scroll', onScroll, {passive:true});
    onScroll();

    if(top){
      top.addEventListener('click', function(){
        window.scrollTo({top:0, behavior:'smooth'});
      });
    }
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  }else{
    init();
  }
})();
