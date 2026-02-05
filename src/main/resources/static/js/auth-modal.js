/*
  auth-modal.js
  - 로그인/회원가입을 메인 위에 모달로 띄우기
  - ESC 닫기, 배경 클릭 닫기, 포커스 트랩, body 스크롤 잠금
  - 기존 컨트롤러/폼 action/name 은 건드리지 않음
*/

(function(){
  const q = (sel, el=document) => el.querySelector(sel);
  const qa = (sel, el=document) => Array.from(el.querySelectorAll(sel));

  function getFocusable(root){
    return qa(
      'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
      root
    ).filter(el => el.offsetParent !== null);
  }

  function applyEntryAnimation(modal, dialog){
    if(!dialog) return;

    const isSignup = (modal && modal.id && modal.id.includes('signup'));
    const enter = isSignup ? 'sign-up' : 'sign-in';
    const prep  = isSignup ? 'sign-up-prep' : 'sign-in-prep';

    dialog.classList.remove('sign-in','sign-up','sign-in-prep','sign-up-prep');
    dialog.classList.add(prep);

    requestAnimationFrame(() => {
      dialog.classList.remove(prep);
      dialog.classList.add(enter);
    });
  }

  function openModal(modal, opts={}){
    if(!modal) return;

    modal.classList.add('is-open');
    document.body.classList.add('is-modal-open');

    const dialog = q('.auth-modal__dialog', modal);

    if(dialog){
      dialog.classList.remove('is-flip-in-fwd','is-flip-in-back','is-flip-out-fwd','is-flip-out-back');
    }

    // ✅ 전환 중(openModal이 switch로 호출될 때)은 entry 애니메이션을 스킵(flip이 메인)
    if(!opts.skipEntryAnimation){
      applyEntryAnimation(modal, dialog);
    }

    const focusables = dialog ? getFocusable(dialog) : [];
    const first = focusables[0];
    const last = focusables[focusables.length - 1];

    if(!opts.skipAutoFocus){
      setTimeout(() => (first || dialog).focus(), 0);
    }

    modal.__focusTrap = function(e){
      if(e.key !== 'Tab') return;
      const f = getFocusable(dialog);
      if(!f.length) return;
      const f1 = f[0];
      const f2 = f[f.length - 1];

      if(e.shiftKey && document.activeElement === f1){
        e.preventDefault();
        f2.focus();
      }else if(!e.shiftKey && document.activeElement === f2){
        e.preventDefault();
        f1.focus();
      }
    };

    modal.__escClose = function(e){
      if(e.key === 'Escape') closeModal(modal);
    };

    document.addEventListener('keydown', modal.__escClose);
    dialog && dialog.addEventListener('keydown', modal.__focusTrap);
  }

  function closeModal(modal, opts={}){
    if(!modal) return;

    modal.classList.remove('is-open');
    if(!opts.keepBodyLock) document.body.classList.remove('is-modal-open');

    const dialog = q('.auth-modal__dialog', modal);

    if(dialog){
      dialog.classList.remove(
        'is-flip-in-fwd','is-flip-in-back','is-flip-out-fwd','is-flip-out-back',
        'sign-in','sign-up','sign-in-prep','sign-up-prep'
      );
    }

    if(modal.__escClose) document.removeEventListener('keydown', modal.__escClose);
    if(modal.__focusTrap) dialog && dialog.removeEventListener('keydown', modal.__focusTrap);
  }

  // 1) data-auth-open="login|signup"
  document.addEventListener('click', function(e){
    const opener = e.target.closest('[data-auth-open]');
    if(opener){
      e.preventDefault();
      const target = opener.getAttribute('data-auth-open');
      openModal(q(`#authModal-${target}`));
      return;
    }

    const closer = e.target.closest('[data-auth-close]');
    if(closer){
      e.preventDefault();
      closeModal(closer.closest('.auth-modal'));
      return;
    }

    const backdrop = e.target.classList && e.target.classList.contains('auth-modal__backdrop');
    if(backdrop){
      closeModal(e.target.closest('.auth-modal'));
    }
  });

  // 2) 모달 전환 (로그인 <-> 회원가입) : 180도 flip 유지
  document.addEventListener('click', function(e){
    const link = e.target.closest('a[data-auth-switch]');
    if(!link) return;

    const to = link.getAttribute('data-auth-switch');
    const currentModal = link.closest('.auth-modal');
    if(!currentModal) return;

    e.preventDefault();

    const nextModal = q(`#authModal-${to}`);
    if(!nextModal){
      closeModal(currentModal);
      return;
    }

    const dir = (to === 'signup') ? 'fwd' : 'back';

    const curDialog = q('.auth-modal__dialog', currentModal);
    const nextDialog = q('.auth-modal__dialog', nextModal);

    const reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if(reduce || !curDialog || !nextDialog){
      closeModal(currentModal, { keepBodyLock: true });
      openModal(nextModal, { skipAutoFocus: false });
      return;
    }

    curDialog.classList.remove('is-flip-in-fwd','is-flip-in-back','is-flip-out-fwd','is-flip-out-back');
    curDialog.classList.add(dir === 'fwd' ? 'is-flip-out-fwd' : 'is-flip-out-back');

    curDialog.addEventListener('animationend', function(){
      closeModal(currentModal, { keepBodyLock: true });

      // ✅ 전환으로 열 때는 entry 애니메이션 스킵 (flip이 확실히 보이게)
      openModal(nextModal, { skipAutoFocus: true, skipEntryAnimation: true });

      nextDialog.classList.remove('is-flip-in-fwd','is-flip-in-back','is-flip-out-fwd','is-flip-out-back');
      nextDialog.classList.add(dir === 'fwd' ? 'is-flip-in-fwd' : 'is-flip-in-back');

      nextDialog.addEventListener('animationend', function(){
        nextDialog.classList.remove('is-flip-in-fwd','is-flip-in-back');
      }, { once: true });

      setTimeout(() => {
        const focusables = getFocusable(nextDialog);
        (focusables[0] || nextDialog).focus();
      }, 0);
    }, { once: true });
  });

  // 3) 비밀번호 보기 토글
  document.addEventListener('click', function(e){
    const eye = e.target.closest('.eye');
    if(!eye) return;
    const row = eye.closest('.input-row');
    const input = row ? q('input', row) : null;
    if(!input) return;

    const isPw = input.getAttribute('type') === 'password';
    input.setAttribute('type', isPw ? 'text' : 'password');
    eye.textContent = isPw ? '🙈' : '👁';
  });

  // 외부에서 JS로 열고 싶을 때
  window.AuthModal = {
    open: (name) => openModal(q(`#authModal-${name}`)),
    close: (name) => closeModal(q(`#authModal-${name}`))
  };
})();
