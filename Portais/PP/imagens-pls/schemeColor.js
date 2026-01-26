	updateScheme = true; //variavel que quando ativada permite a troca de cores do grid

//----------menu-----------------// 
	navBar     = '#F9FAFC'; //cor menu lateral/superior
	navBarBorder = '#E7E7E7'; //borda dos menus
	navBarTitle = '#777777'; //titulo superior 'Portal do prestador'
	navBarTitleHover = '#5E5E5E' //cor quando passa o mouse em cima do titulo superior
//------------------------------//

//--------menu mobile-----------//
	navBarMenuColor = '#777777'; //cor '3 barrinhas' do toggle do menu mobile
	navBarMenuColorHover = '#DDDDDD'; //cor quando passa o mouse em cima do menu
//------------------------------//

//-----------Links menu---------//
	linksNavBar =  '#3452AA'; //cor da fonte dos links de menu
	hoverLinksNavBarBG = '#F3F3F3'; //cor de fundo quando passa-se o mouse em cima do menu pai
	hoverLinksNavBarF = '#335E85'; //cor da fonte quando passa-se o mouse em cima do menu pai
//------------------------------//

//-----------SubLinks menu------//
	subLinksMenu    = '#E5EDF2'; //cor de fundo dos sublinks do menu
	hoverSubLinksMenuBG = '#D8E4EC'; // cor de fundo quando passa-se o mouse em cima do submenu
	hoverSubLinksMenuF = '#335E85'; //cor da fonte quando passa-se o mouse em cima do submenu
//------------------------------//

//-------Grid de dados----------//
	gridCab = '#019DBB'; //cor do cabeçalho da grid e do cabeçalho das noticias
	gridFont = '#FFFFFF'; //cor da fonte do cabeçalho
	gridBorder = '#DDDDDD'; //cor da borda do grid
	gridOdd = '#F7FCFC'; //cor linha alternada 1
	gridEven = '#E8F6F8'; //cor linha alternada 2
	gridLineHover = '#D2EEF1'; //cor quando passa-se o mouse em cima da linha do grid
//------------------------------//

//---------------Botoes com a classe btn-theme-----------//
	btnColor = '#FFFFFF'; // cor da fonte do botão
	btnBgColor = '#019DBB'; // cor do botão
	btnBorderColor = '#019DBB'; //cor da borda do botão
	
	btnColorHover = '#FFFFFF' //cor da fonte do botão efeito hover
	btnBgColorHover = '#007E96'; // cor do botão efeito hover
	btnBorderColorHover = '#007E96'; //cor da borda do botão efeito hover
//------------------------------------------------------------------------//


function updSchemeColor(){

	if (updateScheme){
		var style = document.getElementsByTagName('style')[0];

		if (typeof(style) == "undefined"){
				style=document.createElement('style');
				document.getElementsByTagName('head')[0].appendChild(style);
		}

		$("#wrapper").add(".navbar-default").css('background-color',navBar);	
		
		$(".navbar-default").css('border-color',navBarBorder);	
		
		$(".navbar-default .navbar-brand").css('color' ,navBarTitle);	
		
		//-------------------------MENU MOBILE-----------------------------------//
		$(".navbar-default .navbar-toggle").css('border-color' ,navBarMenuColor);
		
		$(".navbar-default .navbar-toggle .icon-bar").css('background' ,navBarMenuColor);
		//-----------------------------------------------------------------------//
		
		$(".sidebar ul li").add(".navbar-default .navbar-collapse, .navbar-default .navbar-form").css({
			'border-color' : navBarBorder
		});
		
		
		$(".nav > li > a").css({
		   'color' : linksNavBar
		});
				
		$( ".nav-second-level li .menuItem" ).css({
		   'background-color' : subLinksMenu,
		   'color' : linksNavBar
		});
		
		$( "#news  #newsCab").css({
		   'background-color' : gridCab,
		   'color' : gridFont
		});
		
		$( "#news  #newsSpace .newsItem a").css({
		   'background-color' :'white',
		   'color'            : 'black'
		});
		
		$("#menu-shortcuts").css({
			'background-color' : linksNavBar
		});
		
		$("#menu-shortcuts li a").css({
			'color' :'white'
		});
				
		//tem que fazer dessa forma para eventos hover, focus, active, etc.
		var css = '.nav > li > a:hover{background-color:' + hoverLinksNavBarBG + '!important ; color:' + hoverLinksNavBarF + '!important ;} '; // !important para cobrir o css padrão
		style.appendChild(document.createTextNode(css));
		
		css = '.sidebar .nav-second-level li .menuItem:hover{background-color:' + hoverSubLinksMenuBG + '!important; color:' + hoverSubLinksMenuF + '!important;} '; // !important para cobrir o css padrão
		style.appendChild(document.createTextNode(css));
		
		css = '.navbar-default .navbar-brand:hover{color:' + navBarTitleHover + '!important;} ';
		style.appendChild(document.createTextNode(css));
		
		css = '.navbar-default .navbar-toggle:hover,.navbar-default .navbar-toggle:focus{background-color:' + navBarMenuColorHover + '!important;} ';
		style.appendChild(document.createTextNode(css));
		
		css = '#news  #newsCab:hover{background-color:' + gridCab + ' !important; color:' + gridFont + ' !important}';
		style.appendChild(document.createTextNode(css));
		
		css = '#news  #newsSpace .newsItem a:hover{background-color:white !important; color:black !important; text-decoration: underline;}';
		style.appendChild(document.createTextNode(css));
		
		css = '#menu-shortcuts li a:hover, #menu-shortcuts li a:active, #menu-shortcuts li a:focus, #menu-shortcuts li a:visited, #menu-shortcuts li a:link{background-color:' + linksNavBar + ' !important; }';
		style.appendChild(document.createTextNode(css));
		
		css = '#menu-shortcuts li a:hover{text-decoration: underline !important; }';
		style.appendChild(document.createTextNode(css));
		
		css = '.btn-theme{';
		css +='color: ' + btnColor + ' !important;';
		css +='background-color: ' + btnBgColor + ' !important;';
		css +='border-color: ' + btnBorderColor + ' !important;}';
		style.appendChild(document.createTextNode(css));
		
		css = '.btn-theme:hover, .btn-theme:focus, .btn-theme.focus, .btn-theme:active, .btn-theme.active, .open > .dropdown-toggle.btn-theme {';
		css +=	'color: ' + btnColorHover + ' !important;';
		css +=	'background-color: ' + btnBgColorHover  + ' !important;';
		css +=	'border-color: ' + btnBorderColorHover + ' !important; }';
		style.appendChild(document.createTextNode(css));
	}
	
}

function updFrameSchemeColor(){
	if (updateScheme){
		var style = document.getElementsByTagName('style')[0];

		if (typeof(style) == "undefined"){
			style=document.createElement('style');
			document.getElementsByTagName('head')[0].appendChild(style);
		}
		
		var css = '.nav-tabs > li.active > a, .nav-tabs > li.active > a:hover, .nav-tabs > li.active > a:focus { color: #555 !important;}';
		style.appendChild(document.createTextNode(css));
		
		var css = 'a { color:' + linksNavBar + ' !important;}';
		style.appendChild(document.createTextNode(css));
		
		css = 'a:hover, a:focus { color:' + hoverLinksNavBarF + ' !important;}';
		style.appendChild(document.createTextNode(css));
		
		css = '.btn-theme{';
		css +='color: ' + btnColor + ' !important;';
		css +='background-color: ' + btnBgColor + ' !important;';
		css +='border-color: ' + btnBorderColor + ' !important;}';
		style.appendChild(document.createTextNode(css));
		
		css = '.btn-theme:hover, .btn-theme:focus, .btn-theme.focus, .btn-theme:active, .btn-theme.active, .open > .dropdown-toggle.btn-theme {';
		css +=	'color: ' + btnColorHover + ' !important;';
		css +=	'background-color: ' + btnBgColorHover  + ' !important;';
		css +=	'border-color: ' + btnBorderColorHover + ' !important; }';
		style.appendChild(document.createTextNode(css));
	}
}

function updGridSchemeColor(){
	if (updateScheme){
		var style = document.getElementsByTagName('style')[0];

		if (typeof(style) == "undefined"){
			style=document.createElement('style');
			document.getElementsByTagName('head')[0].appendChild(style);
		}
		
		$(".table-bordered").css({
			'border-color' : gridBorder
		});
		
		$(".table-bordered > thead > tr > th, .table-bordered > tbody > tr > th, .table-bordered > tfoot > tr > th, .table-bordered > thead > tr > td, .table-bordered > tbody > tr > td, .table-bordered > tfoot > tr > td").css({
				'border-color' : gridBorder
		});
		
		$(".table-striped > tbody > tr:nth-of-type(odd)").css({
				'background-color' : gridOdd
		});
		
		$(".table-striped > tbody > tr:nth-of-type(even)").css({
				'background-color' : gridEven
		});
		
		//$(".table-bordered > thead > tr > th").css("cssText", "background-color: " + gridCab + " !important; color: " + gridFont + "; border-color: " + gridBorder + "; ");
		
		css = '.table-bordered.thead.tr.th { background-color: ' + gridCab + ' !important; color: ' + gridFont + '; border-color: ' + gridBorder + '; }';
		style.appendChild(document.createTextNode(css));
		
		css = '.selectedLine { background-color:' + gridLineHover + ' !important; }';
		style.appendChild(document.createTextNode(css));
		
		css = '.table-hover > tbody > tr:hover{ background-color:' + gridLineHover + ' !important; }'; 
		style.appendChild(document.createTextNode(css));
	}	
}
