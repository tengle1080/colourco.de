Meteor.startup(function(){
  //Twitter
  !function (d, s, id) { var js, fjs = d.getElementsByTagName(s)[0]; if (!d.getElementById(id)) { js = d.createElement(s); js.id = id; js.src = "//platform.twitter.com/widgets.js"; fjs.parentNode.insertBefore(js, fjs); } }(document, "script", "twitter-wjs");
  //Google+1
  (function () { var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true; po.src = 'https://apis.google.com/js/plusone.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s); })();
  //fb like
  (function (d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=277582698988224";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));
  //flattr
  (function() {
        var s = document.createElement('script'), t = document.getElementsByTagName('script')[0];
        s.type = 'text/javascript';
        s.async = true;
        s.src = 'http://api.flattr.com/js/0.6/load.js?mode=auto&popout=0';
        t.parentNode.insertBefore(s, t);
    })();
    //influads
    (function(){var acc='acc_1318d914_pub';var st='nocss';var or='130';var e=document.getElementsByTagName('script')[0];var d=document.createElement('script');d.src=('https:' == document.location.protocol ?'https://' : 'http://') +'engine.influads.com/show/'+or+'/'+st+'/'+acc;d.type='text/javascript';d.async=true;d.defer=true; e.parentNode.insertBefore(d,e);})();
});

CoinWidgetCom.go({
  wallet_address: "16bs6kN6wTVT7NUCMWxjCZ4UCTy3b9KVWX"
  , currency: "bitcoin"
  , counter: "count"
  , alignment: "bl"
  , qrcode: true
  , auto_show: false
  , lbl_button: "Donate BTC"
  , lbl_address: "My Bitcoin Address:"
  , lbl_count: "donations"
  , lbl_amount: "BTC"
});
CoinWidgetCom.go({
  wallet_address: "LYkd9Vo52NotPCpB6AUQ8Cg7sjF1meLsif"
  , currency: "litecoin"
  , counter: "count"
  , alignment: "bl"
  , qrcode: true
  , auto_show: false
  , lbl_button: "Donate LTC"
  , lbl_address: "My Litecoin Address:"
  , lbl_count: "donations"
  , lbl_amount: "LTC"
});
