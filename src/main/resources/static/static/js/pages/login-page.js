(function(){
  function sameOriginReferrer(){
    try{
      if(!document.referrer) return null;
      var u = new URL(document.referrer);
      if(u.origin !== location.origin) return null;
      // 로그인/회원가입 페이지로부터의 referrer는 무시
      if(u.pathname.startsWith('/members/login') || u.pathname.startsWith('/members/register')) return null;
      return u.pathname + u.search + u.hash;
    }catch(e){ return null; }
  }

  document.addEventListener('DOMContentLoaded', function(){
    var redirect = sameOriginReferrer();
    if(redirect){
      try{ sessionStorage.setItem('authRedirect', redirect); }catch(err){}
    }

    if(window.AuthModal && typeof window.AuthModal.open === 'function'){
      window.AuthModal.open('login');
    }

    var errEl = document.getElementById('serverAuthError');
    var msg = errEl ? (errEl.textContent || '').trim() : '';
    if(msg && window.AuthModal && typeof window.AuthModal.setError === 'function'){
      window.AuthModal.setError('login', msg);
    }
  });
})();
