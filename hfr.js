function quoter(add, cat, post, numreponse) {

    var date = new Date;
	
    date.setHours(date.getHours() + 1);
    var name = 'quotes' + add + '-' + cat + '-' + post;
	
    quotes = LireCookie(name);

	//alert(quotes);

	
    //if (document.getElementById('plus' + numreponse).style.display != 'none') {
	quotes = quotes.replace('|' + numreponse, '');
	quotes = quotes + '|' + numreponse;
    //    document.getElementById('plus' + numreponse).style.display = 'none';
    //    document.getElementById('moins' + numreponse).style.display = 'inline';
    //    document.getElementById('viderliste').style.display = 'inline';
    //} else {
    //   quotes = quotes.replace('|' + numreponse, '');
    //   document.getElementById('plus' + numreponse).style.display = 'inline';
    //   document.getElementById('moins' + numreponse).style.display = 'none';
    //}
	
	alert(quotes);
	
    if (quotes == '') vider_liste(name);
    else EcrireCookie(name, quotes, date, '/');
}
function EcrireCookie(nom, valeur) {
    var argv = EcrireCookie.arguments;
    var argc = EcrireCookie.arguments.length;
    var expires = (argc > 2) ? argv[2] : null;
    var path = (argc > 3) ? argv[3] : null;
    var domain = (argc > 4) ? argv[4] : null;
    var secure = (argc > 5) ? argv[5] : false;
    document.cookie = nom + '=' + escape(valeur) +
    ((expires == null) ? '': ('; expires=' + expires.toGMTString())) +
    ((path == null) ? '': ('; path=' + path)) +
    ((domain == null) ? '': ('; domain=' + domain)) +
    ((secure == true) ? '; secure': '');
}
function getCookieVal(offset) {
    var endstr = document.cookie.indexOf(';', offset);
    if (endstr == -1) endstr = document.cookie.length;
    return unescape(document.cookie.substring(offset, endstr));
}
function LireCookie(nom) {
	//alert(nom);

    var arg = nom + '=';
    var alen = arg.length;
    var clen = document.cookie.length;
    var i = 0;
	//alert(clen);

    while (i < clen) {
        var j = i + alen;
        if (document.cookie.substring(i, j) == arg) return getCookieVal(j);
        i = document.cookie.indexOf(' ', i) + 1;
        if (i == 0) break;
    }
    return '';
}
function EffaceCookie(nom) {
    var date = new Date;
    date.setFullYear(date.getFullYear() - 1);
    EcrireCookie(nom, null, date, '/');
}