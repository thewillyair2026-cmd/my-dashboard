// WILLY 공통 사이드바/탑바 셸
(function(){
  var LOGO_SVG = '<svg width="656" height="132" viewBox="0 0 656 132" fill="none" xmlns="http://www.w3.org/2000/svg">'+
    '<path d="M501.642 0H537.276L578.942 58.0691L620.42 0H655.111L593.648 80.1278V131.975H563.105V80.1278L501.642 0Z" fill="#F4F4F4"/>'+
    '<path d="M420.872 0H449.718V109.916H535.124V131.975H420.872V0Z" fill="#F4F4F4"/>'+
    '<path d="M289.73 0H318.576V109.916H403.983V131.975H289.73V0Z" fill="#F4F4F4"/>'+
    '<path d="M229.934 0H260.289V131.975H229.934V0Z" fill="#F4F4F4"/>'+
    '<path d="M171.379 131.975H140.082L106.9 36.0104L73.5291 131.975H41.8551L9.15527e-05 0H31.6741L59.0118 101.809L92.5712 3.77072H121.606L155.165 101.432L182.314 0H213.046L171.379 131.975Z" fill="#F4F4F4"/>'+
    '</svg>';

  var ICONS = {
    grid: '<path d="M4 4h6v6H4V4Zm10 0h6v6h-6V4ZM4 14h6v6H4v-6Zm10 0h6v6h-6v-6Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>',
    chart: '<path d="M4 20V10M11 20V4M18 20v-7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>',
    megaphone: '<path d="M3 10v4a1 1 0 0 0 1 1h2l4 4v-14l-4 4H4a1 1 0 0 0-1 1Z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="M14 9a4 4 0 0 1 0 6M17 6a8 8 0 0 1 0 12" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    users: '<circle cx="9" cy="8" r="3" stroke="currentColor" stroke-width="1.7"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><path d="M16 7a3 3 0 0 1 0 6M21 20c0-2.8-2-5.2-5-5.8" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    coins: '<ellipse cx="9" cy="7" rx="6" ry="3" stroke="currentColor" stroke-width="1.7"/><path d="M3 7v5c0 1.7 2.7 3 6 3s6-1.3 6-3V7" stroke="currentColor" stroke-width="1.7"/><path d="M9 15v2c0 1.7 2.7 3 6 3s6-1.3 6-3v-8c0-1.2-1.3-2.2-3.2-2.7" stroke="currentColor" stroke-width="1.7"/>',
    badge: '<circle cx="12" cy="8" r="3.2" stroke="currentColor" stroke-width="1.7"/><path d="M5 21c0-3.9 3.1-7 7-7s7 3.1 7 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>'
  };

  var NAV = [
    {key:'exec', label:'경영', href:'../exec/index.html', icon:'grid'},
    {key:'sales', label:'영업', href:'../sales/index.html', icon:'chart'},
    {key:'marketing', label:'마케팅', href:'../marketing/index.html', icon:'megaphone'},
    {key:'customer', label:'고객', href:'../customer/index.html', icon:'users'},
    {key:'pl', label:'손익', href:'../pl/index.html', icon:'coins'},
    {key:'hr', label:'인사', href:'../hr/index.html', icon:'badge'}
  ];

  function svgIcon(name){
    return '<svg viewBox="0 0 24 24" fill="none">'+ICONS[name]+'</svg>';
  }

  function mount(cfg){
    var root = document.getElementById('shell-root');
    if(!root) return;

    var navHtml = NAV.map(function(item){
      var cls = item.key === cfg.active ? 'active' : '';
      return '<a href="'+item.href+'" class="'+cls+'">'+svgIcon(item.icon)+'<span>'+item.label+'</span></a>';
    }).join('');

    root.innerHTML =
      '<aside class="willy-sidebar">'+
        '<a class="logo-row" href="../index.html">'+LOGO_SVG+'</a>'+
        '<nav class="willy-nav">'+navHtml+'</nav>'+
        '<div class="sb-footer"><div class="name">WILLY 경영관리</div><div class="role">시스템에어컨 설치</div></div>'+
      '</aside>';

    var topbar = document.createElement('header');
    topbar.className = 'willy-topbar';
    topbar.innerHTML =
      '<div class="titles"><h1>'+cfg.title+'</h1><p>'+(cfg.subtitle||'')+'</p></div>'+
      '<div class="meta">'+
        '<span class="range">'+(cfg.range || defaultRange())+'</span>'+
        '<span class="live"><span class="dot"></span>LIVE</span>'+
      '</div>';

    var main = document.createElement('div');
    main.className = 'willy-main';
    main.appendChild(topbar);

    var contentHost = document.getElementById('content');
    var contentParent = contentHost ? contentHost.parentNode : null;
    if(contentParent && contentParent !== document.body){
      contentParent.classList.add('willy-content');
      main.appendChild(contentParent);
    } else if(contentHost){
      var wrap = document.createElement('div');
      wrap.className = 'willy-content';
      contentHost.parentNode.insertBefore(wrap, contentHost);
      wrap.appendChild(contentHost);
      main.appendChild(wrap);
    }

    root.parentNode.insertBefore(main, root.nextSibling);
  }

  function defaultRange(){
    var d = new Date();
    var y = d.getFullYear();
    var m = String(d.getMonth()+1).padStart(2,'0');
    return y+'.'+m+' 실적';
  }

  window.WillyShell = { mount: mount };
})();
