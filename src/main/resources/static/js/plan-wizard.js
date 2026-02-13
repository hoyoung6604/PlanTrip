(function () {
  // ===== 설정: 스텝별 제목/설명 =====
  const STEP_META = {
    0: {
      title: "여행 기본 정보 설정",
      sub: "여행 제목/기간/여행지/인원 등 기본 정보를 먼저 입력해요."
    },
    1: {
      title: "일정 짜기 전, 딱 6가지만!",
      sub: "여행 성격(예산/이동수단/테마/스타일/필수 장소·음식)을 먼저 정해요."
    },
    2: { title: "동선 설계", sub: "도시/권역/핵심 목적지를 기반으로 동선을 구성해요." },
    3: { title: "하루 일정 배치", sub: "오전/점심/오후/저녁 등 블록 기준으로 배치해요." },
    4: { title: "안정장치(선택)", sub: "예비 시간/플랜B 등을 설정해요." },
    5: { title: "상세 일정(SpotID/메모)", sub: "SpotID 기반으로 순서/메모를 정리해요." }
  };

  // ===== DOM 찾기 =====
  const steps = Array.from(document.querySelectorAll(".pt-step"));
  if (steps.length === 0) return;

  const submitWrap = document.querySelector(".pt-submit-wrap");
  const warnBox = document.createElement("div");
  warnBox.className = "pt-warn";
  warnBox.id = "ptWizardWarn";
  warnBox.textContent = "필수 입력을 확인해 주세요.";

  const topUI = document.createElement("div");
  topUI.className = "pt-wizard-top";
  topUI.innerHTML = `
    <div class="pt-wizard-progress">
      <div class="pt-wizard-title" id="ptWizardTitle"></div>
      <div class="pt-wizard-sub" id="ptWizardSub"></div>
      <div class="pt-wizard-bar"><div id="ptWizardBarFill"></div></div>
    </div>
    <div class="pt-wizard-nav">
      <button type="button" class="pt-btn" id="ptPrevBtn">이전</button>
      <button type="button" class="pt-btn primary" id="ptNextBtn">다음</button>
    </div>
  `;

  steps[0].parentElement.insertBefore(topUI, steps[0]);
  steps[0].parentElement.insertBefore(warnBox, steps[0]);

  const $title = document.getElementById("ptWizardTitle");
  const $sub = document.getElementById("ptWizardSub");
  const $bar = document.getElementById("ptWizardBarFill");
  const $prev = document.getElementById("ptPrevBtn");
  const $next = document.getElementById("ptNextBtn");

  let current = 0;

  // ===== 유효성 검사 =====
  function validateStep(stepEl) {
    const requiredEls = stepEl.querySelectorAll("[required], [data-required='true']");
    for (const el of requiredEls) {
      if ((el.type === "radio" || el.type === "checkbox")) {
        const name = el.name;
        if (name) {
          const group = stepEl.querySelectorAll(`input[name="${CSS.escape(name)}"]`);
          const anyChecked = Array.from(group).some(i => i.checked);
          if (!anyChecked) return false;
        } else {
          if (!el.checked) return false;
        }
      } else {
        const v = (el.value ?? "").toString().trim();
        if (!v) return false;
      }
    }
    return true;
  }

  function setWarn(show, msg) {
    if (msg) warnBox.textContent = msg;
    warnBox.classList.toggle("show", !!show);
  }

  function setStep(idx) {
    current = idx;

    steps.forEach((s, i) => s.classList.toggle("is-active", i === current));

    const meta = STEP_META[current] || { title: `Step ${current}`, sub: "" };
    $title.textContent = `[Step ${current}] ${meta.title}`;
    $sub.textContent = meta.sub || "";

    const percent = ((current + 1) / steps.length) * 100;
    $bar.style.width = `${percent}%`;

    $prev.disabled = current === 0;

    const isLast = current === steps.length - 1;
    $next.textContent = isLast ? "마지막 확인" : "다음";

    if (submitWrap) submitWrap.classList.toggle("is-active", isLast);

    setWarn(false);
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  // ✅ JSP 인라인 스크립트에서 Step 이동을 “정식으로” 제어할 수 있게 공개
  // (wizardGenerateDays() 안에서 Step0로 보내는 로직과 싱크 깨짐 방지)
  window.PTWizard = {
    goTo: (idx) => setStep(idx),
    getCurrent: () => current
  };

  $prev.addEventListener("click", () => {
    if (current > 0) setStep(current - 1);
  });

  $next.addEventListener("click", () => {
    const stepEl = steps[current];
/*
    if (!validateStep(stepEl)) {
      setWarn(true, "필수 입력(빈칸/선택)을 먼저 완료해 주세요.");
      const target = stepEl.querySelector("[required], [data-required='true']");
      if (target) target.focus?.();
      return;
    }
*/
// ✅ Step 2에서 다음으로 넘어갈 때 처리
    if (current === 2) {
      const wrap = document.getElementById("dayRegionWrap");
      const hasCard = !!(wrap && wrap.querySelector(".day-card"));

      if (!hasCard && typeof window.wizardGenerateDays === "function") {
        window.wizardGenerateDays();
        const nowHasCard = !!(wrap && wrap.querySelector(".day-card"));
        if (nowHasCard) {
          setWarn(true, "Day 입력칸이 생성됐어요. 정보를 입력한 뒤 다시 ‘다음’을 눌러주세요.");
          return;
        }
      }

      // ✅ [추가된 로직] Step 2 데이터를 Step 5로 자동 전송
      if (typeof window.syncStep2ToStep5 === "function") {
        window.syncStep2ToStep5();
      }
    }

    if (current < steps.length - 1) {
      setStep(current + 1);
    } else {
      setWarn(true, "마지막 단계입니다. 하단의 [저장] 버튼으로 완료해 주세요.");
    }
  });

  setStep(0);
})();
