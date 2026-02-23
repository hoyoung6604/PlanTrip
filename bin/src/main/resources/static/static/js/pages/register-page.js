(function(){
  document.addEventListener('DOMContentLoaded', function(){
    if(window.AuthModal && typeof window.AuthModal.open === 'function'){
      window.AuthModal.open('signup');
    }

    var errEl = document.getElementById('serverAuthError');
    var msg = errEl ? (errEl.textContent || '').trim() : '';
    if(msg && window.AuthModal && typeof window.AuthModal.setError === 'function'){
      window.AuthModal.setError('signup', msg);
    }
  });
})();
