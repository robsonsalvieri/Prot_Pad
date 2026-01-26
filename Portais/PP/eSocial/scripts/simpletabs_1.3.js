/*
simpleTabs v1.3

Author: Fotis Evangelou (Komrade Ltd.)
License: GNU/GPL v2.0
Credits:
- Peter-Paul Koch for the "Cookies" functions. More on: http://www.quirksmode.org/js/cookies.html
- Simon Willison for the "addLoadEvent" function. More on: http://simonwillison.net/2004/May/26/addLoadEvent/
Last updated: June 25th, 2009

RELEASE CHANGELOG:
v1.3
- Fixed "recurring divs in content" bug. If your tab contents included div tags, the tabs would break due to a faulty div tag count. Thanks to Sebastian Lšscher (www.ddfriends.de) for providing the very simple fix!
- Separated all CSS classes at the top of the script, in case you need to modify them to suit your HTML/CSS structure.
v1.2
- Fixed IE syntax error
v1.1
- Namespaced the entire script

FEATURES TO COME:
- Remember last accessed tab for all tab sets on the same page
- Enable tab selection via URL anchor
- Add a loading indicator for the tab panes

*/

// Main SimpleTabs function
var kmrSimpleTabs = {

	sbContainerClass: "simpleTabs",
	sbNavClass: "simpleTabsNavigation",
	sbContentClass: "simpleTabsContent",
	sbCurrentNavClass: "current",
	sbCurrentTabClass: "currentTab",
	sbIdPrefix: "tabber",	

	init: function(){
		if(!document.getElementsByTagName) return false;
		if(!document.getElementById) return false;
		
		var containerDiv = document.getElementsByTagName("div");
	
		for(var i=0; i<containerDiv.length; i++){
			if (containerDiv[i].className == kmrSimpleTabs.sbContainerClass) {
				
				// assign a unique ID for this tab block and then grab it
				containerDiv[i].setAttribute("id",kmrSimpleTabs.sbIdPrefix+[i]);		
				var containerDivId = containerDiv[i].getAttribute("id");
	
				// Navigation
				var ul = containerDiv[i].getElementsByTagName("ul");
				
				for(var j=0; j<ul.length; j++){
					if (ul[j].className == kmrSimpleTabs.sbNavClass) {
	
						var a = ul[j].getElementsByTagName("a");
						for(var k=0; k<a.length; k++){
							a[k].setAttribute("id",containerDivId+"_a_"+k);
							// get current
							if(kmrSimpleTabs.readCookie('simpleTabsCookie')){
								var cookieElements = kmrSimpleTabs.readCookie('simpleTabsCookie').split("_");
								var curTabCont = cookieElements[1];
								var curAnchor = cookieElements[2];
								if(a[k].parentNode.parentNode.parentNode.getAttribute("id")==kmrSimpleTabs.sbIdPrefix+curTabCont){
									if(a[k].getAttribute("id")==kmrSimpleTabs.sbIdPrefix+curTabCont+"_a_"+curAnchor){
										a[k].className = kmrSimpleTabs.sbCurrentNavClass;
									} else {
										a[k].className = "";
									}
								} else {
									a[0].className = kmrSimpleTabs.sbCurrentNavClass;
								}
							} else {
								a[0].className = kmrSimpleTabs.sbCurrentNavClass;
							}
							
							a[k].onclick = function(){
								kmrSimpleTabs.setCurrent(this,'simpleTabsCookie');
								return false;
							}
						}
					}
				}
	
				// Tab Content
				var div = containerDiv[i].getElementsByTagName("div");
				var countDivs = 0;
				for(var l=0; l<div.length; l++){
					if (div[l].className == kmrSimpleTabs.sbContentClass) {
						div[l].setAttribute("id",containerDivId+"_div_"+[countDivs]);	
						if(kmrSimpleTabs.readCookie('simpleTabsCookie')){
							var cookieElements = kmrSimpleTabs.readCookie('simpleTabsCookie').split("_");
							var curTabCont = cookieElements[1];
							var curAnchor = cookieElements[2];		
							if(div[l].parentNode.getAttribute("id")==kmrSimpleTabs.sbIdPrefix+curTabCont){
								if(div[l].getAttribute("id")==kmrSimpleTabs.sbIdPrefix+curTabCont+"_div_"+curAnchor){
									div[l].className = kmrSimpleTabs.sbContentClass+" "+kmrSimpleTabs.sbCurrentTabClass;
								} else {
									div[l].className = kmrSimpleTabs.sbContentClass;
								}
							} else {
								div[0].className = kmrSimpleTabs.sbContentClass+" "+kmrSimpleTabs.sbCurrentTabClass;
							}
						} else {
							div[0].className = kmrSimpleTabs.sbContentClass+" "+kmrSimpleTabs.sbCurrentTabClass;
						}
						countDivs++;
					}
				}	
	
				// End navigation and content block handling	
			}
		}
	},
	
	// Function to set the current tab
	setCurrent: function(elm,cookie){
		
		this.eraseCookie(cookie);
		
		//get container ID
		var thisContainerID = elm.parentNode.parentNode.parentNode.getAttribute("id");
	
		// get current anchor position
		var regExpAnchor = thisContainerID+"_a_";
		var thisLinkPosition = elm.getAttribute("id").replace(regExpAnchor,"");
	
		// change to clicked anchor
		var otherLinks = elm.parentNode.parentNode.getElementsByTagName("a");
		for(var n=0; n<otherLinks.length; n++){
			otherLinks[n].className = "";
		}
		elm.className = kmrSimpleTabs.sbCurrentNavClass;
		
		// change to associated div
		var otherDivs = document.getElementById(thisContainerID).getElementsByTagName("div");
		var RegExpForContentClass = new RegExp(kmrSimpleTabs.sbContentClass);
		for(var i=0; i<otherDivs.length; i++){
			if ( RegExpForContentClass.test(otherDivs[i].className) ) {
				otherDivs[i].className = kmrSimpleTabs.sbContentClass;
			}
		}
		document.getElementById(thisContainerID+"_div_"+thisLinkPosition).className = kmrSimpleTabs.sbContentClass+" "+kmrSimpleTabs.sbCurrentTabClass;
	
		// get Tabs container ID
		var RegExpForPrefix = new RegExp(kmrSimpleTabs.sbIdPrefix);
		var thisContainerPosition = thisContainerID.replace(RegExpForPrefix,"");
		
		// set cookie
		this.createCookie(cookie,'simpleTabsCookie_'+thisContainerPosition+'_'+thisLinkPosition,1);
	},
	
	// Cookies
	createCookie: function(name,value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
	},
	
	readCookie: function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	},
	
	eraseCookie: function(name) {
		this.createCookie(name,"",-1);
	},

	// Loader
	addLoadEvent: function(func) {
		var oldonload = window.onload;
		if (typeof window.onload != 'function') {
			window.onload = func;
		} else {
			window.onload = function() {
				if (oldonload) {
					oldonload();
				}
				func();
			}
		}
	}
	
	// END
};

// Load SimpleTabs
kmrSimpleTabs.addLoadEvent(kmrSimpleTabs.init);








//Gets the browser specific XmlHttpRequest Object
function getXmlHttpRequestObject() {
	if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	} else if(window.ActiveXObject) {
		return new ActiveXObject("Microsoft.XMLHTTP");
	} else {
		alert("Your don't suport XmlHttp Request!");
	}
}


var searchReq = getXmlHttpRequestObject();

//Starts the AJAX request.
function AjaxStartPageRequest(page, sender, dest) {
	var oSender = document.getElementById(sender);
	var oDest = document.getElementById(dest);

	oSender.disabled = true;
	oDest.disabled = true;

	if (searchReq.readyState == 4 || searchReq.readyState == 0) {
		searchReq.open("GET", page, true);
		searchReq.onreadystatechange = function() {AjaxHandlePageRequest(oSender, oDest);};
		searchReq.send(null);
	}
}


//Called when the AJAX response is returned.
function AjaxHandlePageRequest(sender, dest) {
	if (searchReq.readyState == 4) {
		dest.innerHTML = searchReq.responseText;

		sender.disabled = false;
		dest.disabled = false;
	}
}

function AjaxStartSearch(oSender, cDestination, cReturnID, cStandardQuery, nPageNumber, cSearch, cSequence) {
	var cURL = "W_PWSXSEARCH.APW?cStandardQuery=" + cStandardQuery;

	if (nPageNumber)
		cURL += "&nPage=" + nPageNumber;

	if (cSearch)
		cURL += "&cSearch=" +  cSearch;

	if (cSequence)
		cURL += "&cSequence=" +  cSequence;

	if (cReturnID)
		cURL += "&cReturnID=" +  cReturnID;


	new Ajax.Updater(	'SearchForm',
										cURL,
										{
											method: 'get',
											onFailure: function() {
												alert('Erro ao carregar a pagina!');
											},
											onComplete: function() {
												Effect.Fade('WaitForm', { duration: 0.5 });
												Effect.Appear('SearchForm', { duration: 0.5, queue: 'end'});
											}
									}
								);


/*
	if (searchReq.readyState == 4 || searchReq.readyState == 0) {
		searchReq.open("GET", sURL, true);
		searchReq.onreadystatechange = function() {AjaxHandleStartSearch(oSender, cDestination);};
		searchReq.send(null);
	}
	*/
}


function AjaxHandleStartSearch(cSender) {
	if (searchReq.readyState == 4) {
		$('SearchForm').update(searchReq.responseText);

		Effect.Fade('WaitForm', { duration: 0.5 });
		Effect.Appear('SearchForm', { duration: 0.5, queue: 'end'});

		$(cSender).disabled = false;
	}
}



function AjaxConfirmSearch(cDestination, cStandardQuery, cRecNo) {
	var cURL = "W_PWSXRESULT.APW?cStandardQuery=" + cStandardQuery + "&nRecNo=" + cRecNo;


	new Ajax.Request(	cURL,
										{
											method: 'get',
											onFailure: function() {
												alert('Erro ao carregar a pagina!');
											},
											onSuccess: function(oTransport) {
												AjaxHandleConfirmSearch(cDestination, oTransport);
											}
										}
									);


/*
	if (searchReq.readyState == 4 || searchReq.readyState == 0) {
		searchReq.open("GET", sURL, true);
		searchReq.onreadystatechange = function() {AjaxHandleConfirmSearch(cDestination);};
		searchReq.send(null);
	}
*/
}


function AjaxHandleConfirmSearch(cDestination, oTransport) {
	var aResults = ReadXML(oTransport.responseText);
	var aInputs = $(cDestination).parentNode.getElementsByTagName("input");
	var nCount;
	var nStartItem;

	for (nCount = 0; nCount < aInputs.length; nCount++) {
		if (aInputs[nCount].id == cDestination)
			nStartItem = nCount;
	}

	for (nCount = 0; nCount < aResults.length; nCount++) {
		if ((nStartItem + nCount) < aInputs.length)
			aInputs[nStartItem + nCount].value = aResults[nCount].value;
			aInputs[nStartItem + nCount].focus();
	}

	CloseSearch()
}

function ReadXML(sXML) {
	var nCount;
	var nFields;
	var aFields = new Array("SEQUENCE", "FIELD", "VALUE");
	var aResults = sXML.split("</RESULT>\r\n<RESULT>");
	var aReturn = new Array();


	if (aResults.length > 0) {
		aResults[0] = aResults[0].replace("<RESULT>", "");
		aResults[aResults.length-1] = aResults[aResults.length-1].replace("</RESULT>\r\n", "");
	}


	for (nCount = 0; nCount < aResults.length; nCount++) {
		var oReturn = new Object;

		for (nFields = 0; nFields < aFields.length; nFields++) {
			var cResult = aResults[nCount];
			var cField = aFields[nFields];
			var nStart = cResult.indexOf("<" + cField + ">") + (cField.length + 2);
			var nLen   = cResult.indexOf("</" + cField + ">") - nStart;

			eval("oReturn." + cField.toLowerCase() + " = '" + cResult.substr(nStart, nLen) + "'")
		}

		aReturn.push(oReturn);
	}


	return aReturn;
}


function HighlightRow(objRow) {
	var lstRows = $('tblSearch').getElementsByTagName('tr');

	for(var i = 0; i < lstRows.length; i++) {
		if ((lstRows[i].Highlighted) && (lstRows[i] != objRow)){
			lstRows[i].Highlighted = false;
			new Effect.Highlight(lstRows[i], { startcolor: '#D4D0C8', endcolor: '#FFFFFF', restorecolor: '#FFFFFF' });
		};
	};


	if (!objRow.Highlighted) {
		objRow.Highlighted = true;
		new Effect.Highlight(objRow, { startcolor: '#FFFFFF', endcolor: '#D4D0C8', restorecolor: '#D4D0C8' });
	};

	$('btnConfirma').onclick = objRow.ondblclick;
};



function ChangePage(sender, cReturnID, cConsPadName, nPage, cSearch) {
	if (!nPage) nPage = 1;
	if (!cSearch) cSearch = "";

	var selIndex = document.getElementById('SelectIndex');
	var divSearch = document.getElementById('SearchForm');
	var cSequence = selIndex.options[selIndex.selectedIndex].value;

	if (!divSearch) {
		document.body.innerHTML += '<DIV ID="SearchForm"></DIV>';
		divSearch = document.getElementById('SearchForm');
	}

	AjaxStartSearch(sender, divSearch, cReturnID, cConsPadName, nPage, cSearch, cSequence);
}


function GoToPage(sender, ev, nPageNo, nTotalPage, cReturnID, cConsPadName) {
	var keyCode = window.event ? ev.keyCode : ev.which;

	if (keyCode != 13)
		return true;

	if (nPageNo > nTotalPage) {
		alert("A página nao existe!");
		return false;
	}

	ChangePage(sender, cReturnID, cConsPadName, nPageNo);
	return false;
}

function PerformSearch(ev, cReturnID, cConsPadName) {
	if (ev.type == 'keypress') {
		var keyCode = window.event ? ev.keyCode : ev.which;

		if (keyCode != 13)
			return true;
	}

	var txtSearch = document.getElementById('txtSearch');
	var btnSearch = document.getElementById('btnSearch');

	ChangePage(btnSearch, cReturnID, cConsPadName, null, txtSearch.value);
}


function CloseSearch() {
	Effect.Fade('LightBox', { duration: 0.5 });
	Effect.Fade('SearchForm', { duration: 0.5 });

}

function ShowSearch(oSender, cReturnID, cConsPadName,cFil) {
	if (!($('SearchForm'))) {
		document.body.appendChild(new Element('div', {'id':'WaitForm'}).setStyle({ display: 'none'}));
		document.body.appendChild(new Element('div', {'id':'SearchForm'}).setStyle({ display: 'none'}));
		document.body.appendChild(new Element('div', {'id':'LightBox', onclick:'CloseSearch'}).setStyle({ display: 'none'}));

		var TitleBar = $('WaitForm').appendChild(new Element('div', {'id':'TitleBar'}));
		TitleBar.appendChild(new Element('div', {'id':'TitleBarLeft'}));
		TitleBar.appendChild(new Element('div', {'id':'TitleBarCenter'}).update('Aguarde'));
		TitleBar.appendChild(new Element('div', {'id':'TitleBarRight'}));

		var FrameBody = $('WaitForm').appendChild(new Element('div', {'id':'FrameBody'}));
		FrameBody.appendChild(new Element('p').update('Carregando...').setStyle({textAlign:'left'}));
		FrameBody.appendChild(new Element('img', {'src':'images/ajax-loader.gif'}));
	}


	Effect.Appear('LightBox', { duration: 0.5 });
	Effect.Appear('WaitForm', { duration: 0.5 });

	AjaxStartSearch(oSender, $('SearchForm'), cReturnID, cConsPadName,0,cFil);
}


function ConfirmSearch(cDestination, cAliasName, nRecNo) {
	AjaxConfirmSearch(cDestination, cAliasName, nRecNo);
}

function ShowMessage(cMessage) {
	document.body.appendChild(	new Element('div', {'id':'MessageContainer'} ) );
	
	$('MessageContainer').insert(new Element('div', {'id':'MessageBox'}).setStyle({ display: 'none'}));
	$('MessageBox').insert(cMessage);
	
	Effect.Appear('MessageBox');
	
	setTimeout("FadeOut('MessageBox');", 5000);
}
	
function FadeOut(cElement) {
	Effect.Fade(cElement);
}   

