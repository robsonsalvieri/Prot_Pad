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

function AjaxStartSearch(oSender, cDestination, cReturnID, cStandardQuery, nPageNumber, cSearch, cSequence, cFiltro,cFunction) {
	var cURL = "W_PWSXSEARCH.APW?cStandardQuery=" + cStandardQuery;

	if (nPageNumber)
		cURL += "&nPage=" + nPageNumber;

	if (cSearch)
		cURL += "&cSearch=" +  cSearch;

	if (cSequence)
		cURL += "&cSequence=" +  cSequence;

	if (cReturnID)
		cURL += "&cReturnID=" +  cReturnID;

	if (cFiltro)
		cURL += "&cFiltro=" + cFiltro;

	if (cFunction)
		cURL += "&cFunction=" + cFunction;
		
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



function AjaxConfirmSearch(cDestination, cStandardQuery, cRecNo,cFunction) {
	var cURL = "W_PWSXRESULT.APW?cStandardQuery=" + cStandardQuery + "&nRecNo=" + cRecNo;


	new Ajax.Request(	cURL,
										{
											method: 'get',
											onFailure: function() {
												alert('Erro ao carregar a pagina!');
											},
											onSuccess: function(oTransport) {
												AjaxHandleConfirmSearch(cDestination, oTransport,cFunction);
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


function AjaxHandleConfirmSearch(cDestination, oTransport,cFunction) {
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
	if (cFunction)
		eval(cFunction);
	
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



function ChangePage(sender, cReturnID, cConsPadName, nPage, cSearch, cFiltro, cFunction) {
	if (!nPage) nPage = 1;
	if (!cSearch) cSearch = "";
	if (!cFiltro) cFiltro = "";

	var selIndex = document.getElementById('SelectIndex');
	var divSearch = document.getElementById('SearchForm');
	var cSequence = selIndex.options[selIndex.selectedIndex].value;

	if (!divSearch) {
		document.body.innerHTML += '<DIV ID="SearchForm"></DIV>';
		divSearch = document.getElementById('SearchForm');
	}

	AjaxStartSearch(sender, divSearch, cReturnID, cConsPadName, nPage, cSearch, cSequence, cFiltro, cFunction);
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

function PerformSearch(ev, cReturnID, cConsPadName, cFiltro, cFunction) {
	if (!cFiltro) cFiltro = "";
	if (ev.type == 'keypress') {
		var keyCode = window.event ? ev.keyCode : ev.which;

		if (keyCode != 13)
			return true;
	}

	var txtSearch = document.getElementById('txtSearch');
	var btnSearch = document.getElementById('btnSearch');

	ChangePage(btnSearch, cReturnID, cConsPadName, null, txtSearch.value, cFiltro, cFunction);
}


function CloseSearch() {
	Effect.Fade('LightBox', { duration: 0.5 });
	Effect.Fade('SearchForm', { duration: 0.5 });

}

function ShowSearch(oSender, cReturnID, cConsPadName, cSearch, cFiltro,cFunction) {
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

	AjaxStartSearch(oSender, $('SearchForm'), cReturnID, cConsPadName,0,cSearch,'',cFiltro,cFunction);
}


function ConfirmSearch(cDestination, cAliasName, nRecNo,cFunction) {
	AjaxConfirmSearch(cDestination, cAliasName, nRecNo,cFunction);
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

