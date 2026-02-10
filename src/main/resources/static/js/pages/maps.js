(function(){
  function init(){
    var mapEl = document.getElementById('map');
    if(!mapEl || !window.kakao || !kakao.maps) return;

    var map = new kakao.maps.Map(mapEl, {
      center: new kakao.maps.LatLng(37.5665, 126.9780),
      level: 5
    });

    setTimeout(function(){
      try{ map.relayout(); }catch(e){}
      map.setCenter(new kakao.maps.LatLng(37.5665, 126.9780));
    }, 0);

    var places = new kakao.maps.services.Places();
    var markers = [];
    var infoWindow = new kakao.maps.InfoWindow({ zIndex: 1 });

    function clearMarkers(){
      markers.forEach(function(m){ m.setMap(null); });
      markers = [];
    }

    function placesSearchCB(data, status){
      if(status !== kakao.maps.services.Status.OK){
        if(window.UIToast) UIToast.show('검색 결과가 없습니다.');
        else alert('검색 결과가 없습니다');
        return;
      }

      clearMarkers();
      var bounds = new kakao.maps.LatLngBounds();

      data.forEach(function(place){
        var position = new kakao.maps.LatLng(place.y, place.x);
        var marker = new kakao.maps.Marker({ map: map, position: position });

        kakao.maps.event.addListener(marker, 'click', function(){
          var content =
            '<div class="info-window">' +
              '<b>' + place.place_name + '</b><br>' +
              (place.road_address_name || place.address_name) + '<br>' +
              (place.phone ? '☎ ' + place.phone : '') +
            '</div>';

          infoWindow.setContent(content);
          infoWindow.open(map, marker);
        });

        markers.push(marker);
        bounds.extend(position);
      });

      map.setBounds(bounds);
    }

    function searchPlace(){
      var input = document.getElementById('keyword');
      var keyword = input ? input.value.trim() : '';
      if(!keyword){
        if(window.UIToast) UIToast.show('검색어를 입력해 주세요.');
        else alert('검색어를 입력하세요');
        return;
      }
      places.keywordSearch(keyword, placesSearchCB);
    }

    var searchBtn = document.getElementById('searchBtn');
    if(searchBtn){
      searchBtn.addEventListener('click', function(e){
        e.preventDefault();
        searchPlace();
      });
    }

    var keywordInput = document.getElementById('keyword');
    if(keywordInput){
      keywordInput.addEventListener('keydown', function(e){
        if(e.key === 'Enter'){
          e.preventDefault();
          searchPlace();
        }
      });
    }

    // 햄버거 외부 클릭 시 닫기
    document.addEventListener('click', function(e){
      var hm = document.getElementById('hm');
      var btn = document.querySelector('.hamburger-btn');
      if(!hm || !btn) return;
      if(!hm.contains(e.target) && !btn.contains(e.target)){
        hm.classList.remove('open');
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function(){
    if(window.kakao && kakao.maps && typeof kakao.maps.load === 'function'){
      kakao.maps.load(init);
      return;
    }

    var t = setInterval(function(){
      if(window.kakao && kakao.maps && typeof kakao.maps.load === 'function'){
        clearInterval(t);
        kakao.maps.load(init);
      }
    }, 120);
    setTimeout(function(){ try{ clearInterval(t); }catch(e){} }, 4500);
  });
})();
