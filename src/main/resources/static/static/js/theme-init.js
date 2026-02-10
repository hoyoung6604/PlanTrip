(function(){
  try{
    var key = "plantrip-theme";
    var t = localStorage.getItem(key) || "dark";
    document.documentElement.dataset.theme = t;

    // 페이지별 스타일 분기용(배경/카드 톤 등)
    // - JSP를 대량 수정하지 않고도 support/admin 등 페이지에 맞춰 CSS를 조정하기 위해 사용
    var p = (location && location.pathname) ? location.pathname : "";
    var page = "default";
    if(p === "/" || p === "" || p.indexOf("/index") === 0){
      page = "home";
    }else if(p.indexOf("/support") === 0){
      page = "support";
    }else if(p.indexOf("/admin") === 0){
      page = "admin";
    }else if(p.indexOf("/community") === 0){
      page = "community";
    }else if(p.indexOf("/members") === 0){
      page = "members";
    }
    document.documentElement.dataset.page = page;
  }catch(e){}
})();
