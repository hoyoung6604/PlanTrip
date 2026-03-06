document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.wish-card-item');
    const citySet = new Set();
    
    // 1. 현재 찜 목록에 있는 도시만 스캔
    cards.forEach(card => {
        const city = card.getAttribute('data-city');
        if (city && city !== '기타') citySet.add(city);
    });

    // 2. 도시 탭 생성 및 정렬
    const cityTabsContainer = document.getElementById('cityTabs');
    const targetOrder = ['서울', '부산', '제주도', '강릉', '경주', '수원', '속초'];

    targetOrder.forEach(city => {
        if (citySet.has(city)) {
            const tab = document.createElement('div');
            tab.className = 'city-tab';
            tab.setAttribute('data-filter-city', city);
            tab.innerText = city;
            cityTabsContainer.appendChild(tab);
            citySet.delete(city);
        }
    });
    citySet.forEach(city => {
        const tab = document.createElement('div');
        tab.className = 'city-tab';
        tab.setAttribute('data-filter-city', city);
        tab.innerText = city;
        cityTabsContainer.appendChild(tab);
    });

    const cityTabs = document.querySelectorAll('.city-tab');
    const catBtns = document.querySelectorAll('.cat-btn');
    let currentCity = 'ALL';
    let currentCat = 'ALL';

    // 3. 클릭 시 트립닷컴 스타일 상호작용
    cityTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            cityTabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentCity = tab.getAttribute('data-filter-city');
            applyFilter();
        });
    });

    catBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            catBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentCat = btn.getAttribute('data-filter-cat');
            applyFilter();
        });
    });

    // 4. ✅ 부드러운 전환(Fade-in) 애니메이션 적용
    function applyFilter() {
        let visibleCount = 0;
        cards.forEach(card => {
            const matchCity = (currentCity === 'ALL' || currentCity === card.getAttribute('data-city'));
            const matchCat = (currentCat === 'ALL' || currentCat === card.getAttribute('data-cat'));

            if (matchCity && matchCat) {
                card.style.display = 'flex';
                // 슥 나타나는 효과를 위한 타이밍 조절
                requestAnimationFrame(() => {
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0) scale(1)';
                });
                visibleCount++;
            } else {
                card.style.opacity = '0';
                card.style.transform = 'translateY(10px) scale(0.98)';
                setTimeout(() => { card.style.display = 'none'; }, 300);
            }
        });
    }
});