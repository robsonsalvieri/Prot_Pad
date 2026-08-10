var SHOW_JS_ERROR = false; //apresenta erros ocorridos dentro de um try...catch
var LAST_ORIG_COLOR = null;
var LAST_INPUT_CONTROL = null;
var PRINT_WINDOW_NAME = "winDWPrint";
var HEIGHT_LIMIT = 0.90;
var WIDTH_LIMIT = 0.95;
var GLOBAL_MSG = null; 

var lWindowPosSize = true;
var lHideWait = true;
var isMenu  = false ;
var isMenuShow  = false ;
var isOverPopupMenu = false;
var isOverPopupMenuShow = false;
var menuSelObj = null;


function allTrim(poField) {
	var temp = poField.value;

	if ((temp) && ((!(poField.type) || !(poField.type.toUpperCase() == 'CHECKBOX'))))
	{
		var obj = /^(\s*)([\W\w]*)(\b\s*$)/;
		if (obj.test(temp)) { temp = temp.replace(obj, '$2'); }
		obj = /  /g;
		while (temp.match(obj)) { temp = temp.replace(obj, " "); }
		if (temp == " ") temp = "";
	}

	return temp;
}

function doMinMax(oSender)
{
	var oDivMin = getElement('header_min');
	var oDivMax = getElement('header_max');
	var cURL = location.href;
	
	if (oDivMin)
    cURL = prepParam(cURL, 'miniHeader', '0'); // esta com o minimo, vai trocar para o m·ximo
	else                  
    cURL = prepParam(cURL, 'miniHeader', '1'); // esta com o m·ximo, vai trocar para o minimo	

	location.href = cURL;
}

function doChangeView(oSender, oImageList)
{
  var oDiv = getElement('divMini');
  var cClassName = '';

  if (oSender.src.indexOf('ic_list') == -1)
  {                
  	var re = /ic_mini/gi;
    oSender.src = oSender.src.replace(re, "ic_list");
    oSender.alt = 'Lista';
    cClassName = 'icone_mini';
  } else
  {
  	var re = /ic_list/gi;
    oSender.src = oSender.src.replace(re, "ic_mini");
    oSender.alt = 'Miniaturas';
    cClassName = 'icone_list';
  }
  oSender.title = oSender.alt;
  oDiv.className = cClassName;
}

function setColor(poElement, pcColor) 
{ 
   if (poElement.style) 
     poElement.style.backgroundColor = pcColor; 
} 

function getColor(poElement) 
{ 
   var xRet;
   
   if (poElement.style) 
     xRet = poElement.style.backgroundColor;
   else
     xRet = null;
   
   return xRet
} 

function doFocus(poElement)
{       
  if (retrieveFieldMessage(poElement)) 
  {
    defineMessage(retrieveFieldMessage(poElement));
    defineFieldError(poElement);
  } else 
  {              
    defineMessage("");
    defineFieldCurrent(poElement);
  }
}

function defineMessage(acMsg) 
{ 
  var oAux = getElement("formMsg");
  if (oAux)
    getElement("formMsg").innerHTML = acMsg;
}

function retrieveMessage() 
{        
  var oAux = getElement("formMsg");
  if (oAux)
		return oAux.innerHTML;
	else
		return "";		
}

function retrieveFieldMessage(aoField) 
{
	return aoField.msgError;
}

function defineFieldMessage(aoField, acMsg) 
{
	aoField.msgError = acMsg;
}

function defineFieldError(aoField) 
{
  var re;
                   
	if (aoField.className.indexOf('error') == -1)
  	aoField.className = aoField.className + " error";

  var oAux = getElement("formMsgHint");
  if (oAux)
  {                                  
    oAux.innerHTML = aoField.msgError;
		adjustPosComponent(oAux, aoField);
		showElement(oAux);
    window['timeOutControl'] = setInterval("doHideFormMsgHint()", 5000);
  }  
}

function defineFieldCurrent(aoField) {
	var re;

	if (aoField.className.indexOf('form_error') > -1)
	{
		re = /form_error/gi;
		aoField.className = aoField.className.replace(re, '');
	}
}

function defineFieldInput(aoField) {
	var re;
	if (aoField.className.indexOf('form_current') > -1)
  {
		re = /form_current/gi;
		aoField.className = aoField.className.replace(re, 'form_input');
	}
	
	if (aoField.className.indexOf('form_error') > -1)
  {
		re = /form_error/gi;
		aoField.className = aoField.className.replace(re, '');
	}
}                     

function doHideFormMsgHint()
{
  clearInterval(window['timeOutControl']);
  var oAux = getElement("formMsgHint");
  if (oAux)
    hideElement(oAux);
}

function doBlur(poElement, pcType)
{
              
  doHideFormMsgHint();

  defineMessage("");
  defineFieldInput(poElement);
  	
	if (poElement.tagName != "SELECT") 
	{
		poElement.value = allTrim(poElement);
		if ((pcType) && (pcType == "B"))
			poElement.value = poElement.value.toUpperCase();
		if (poElement.tagName == "INPUT")
			LAST_INPUT_CONTROL = poElement;
	}
}

function validMail(emailStr)
{ 
	emailStr = emailStr.toLowerCase(); 
	var checkTLD=1; 
	var knownDomsPat=/^(com|net|org|edu|int|mil|gov|arpa|biz|aero|name|coop|info|pro|museum)$/; 
	var emailPat=/^(.+)@(.+)$/; 
	var specialChars="\\(\\)><@,;:\\\\\\\"\\.\\[\\]"; 
	var validChars="\[^\\s" + specialChars + "\]"; 
	var quotedUser="(\"[^\"]*\")"; 
	var ipDomainPat=/^\[(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\]$/; 
	var atom=validChars + '+'; 
	var word="(" + atom + "|" + quotedUser + ")"; 
	var userPat=new RegExp("^" + word + "(\\." + word + ")*$"); 
	var domainPat=new RegExp("^" + atom + "(\\." + atom +")*$"); 
	var matchArray=emailStr.match(emailPat); 
	if (matchArray==null) 
	{ 
		GLOBAL_MSG =  STR0001 + '"@" e ".".'; //"Verifique os caracteres "
		return false; 
	} 
	var user=matchArray[1]; 
	var domain=matchArray[2]; 
	for (i=0; i<user.length; i++) 
	{ 
   	if (user.charCodeAt(i)>127) 
		{ 
     		GLOBAL_MSG = STR0002; //"O nome do usu·rio contÈm caracteres inv·lidos."
			return false; 
		} 
	} 
	for (i=0; i<domain.length; i++) 
	{ 
		if (domain.charCodeAt(i)>127) 
		{ 
			GLOBAL_MSG = STR0003; //"O nome do domÌnio contÈm caracteres inv·lidos."
			return false; 
		} 
	} 
	if (user.match(userPat)==null) 
	{ 
		GLOBAL_MSG = STR0004; //"Nome do usu·rio n„o informado ou È inv·lido."  
		return false; 
	} 
	var IPArray=domain.match(ipDomainPat); 
	if (IPArray!=null) 
	{ 
		for (var i=1;i<=4;i++) 
		{ 
			if (IPArray[i]>255) 
			{ 
				GLOBAL_MSG = STR0005; // "Enderáo IP do destino Ç inv†lido." 
				return false;
			} 
		} 
		return true; 
	} 
	var atomPat=new RegExp("^" + atom + "$"); 
	var domArr =domain.split("."); 
	var len=domArr.length; 
	for (i=0;i<len;i++) 
	{ 
		if (domArr[i].search(atomPat)==-1) 
		{ 
			GLOBAL_MSG = STR0006; //"O nome do dom°nio contÇm informaá‰es inv†lidas."
			return false; 
		} 
	} 
	if (checkTLD && domArr[domArr.length-1].length!=2 &&  
		domArr[domArr.length-1].search(knownDomsPat)==-1) 
	{ 
		GLOBAL_MSG = STR0007; //"O endereáo deve terminar com tipo de dom°nio conhecido ou com o c¢digo do pa°s (2 letras)." 
		return false; 
	} 
	if (len<2)
	{ 
		GLOBAL_MSG = STR0008; //"Este dom°nio n∆o Ç um hostname v†lido"
		return false; 
	} 
	return true; 
} 
function getMailValidMsg()
{
	return GLOBAL_MSG; 
}

function validValue(AValue, ACheckOK, ANotSpaces) 
{ 
	var lRet = true; 
	
	if (ANotSpaces)
	{
		if (AValue.indexOf(" ") != -1)
			return (false);
	}
	for (i = 0;  i < AValue.length;  i++) 
	{
   	if (ACheckOK.indexOf(AValue.charAt(i)) == -1) 
	   { 
			lRet = false; 
			break; 
		} 
	} 
	return (lRet);
} 

function doValidField(poField, plRequired,  pcFieldType, pnFieldLen, pnDecimals, pxMinValue, pxMaxValue, poFieldMsg) 
{ 
	var cValid = null;              
              
	defineFieldMessage(poField, null);
  
  if (poField.disabled)
    return true;

  if ((poField.type) && !(poField.type == 'file'))
		poField.value = allTrim(poField);
    
exitValid :
{                    
	if (plRequired)
	{
		if (poField.type != "select-multiple" && (poField.value == "" || (poField.selectedIndex && (poField.selectedIndex < 0)))) {
			defineFieldMessage(poField, STR0009); //"O preenchimento Ç obrigat¢rio."
			break exitValid; 
		} else if (poField.type == "select-multiple" && poField.options.length < 1) {
			defineFieldMessage(poField, STR0009); //"O preenchimento Ç obrigat¢rio."
			break exitValid;
		}
	} else {
		if ((poField.type != "select-multiple" && poField.value == "" || (poField.selectedIndex && poField.selectedIndex < 0))) {
			break exitValid;
		} else if (poField.type == "select-multiple" && poField.options.length < 1) {
			break exitValid;
		}
	}

	if (pcFieldType == "A") 
	{
		cValid =          "ABCDEFGHIJKLMNOPQRSTUVWXYZ";                      
		cValid = cValid + "abcdefghijklmnopqrstuvwxyz";
		cValid = cValid + "¿¡¬√ƒ≈∆«»… ÀÃÕŒœ—“”‘’÷Ÿ⁄€‹";
		cValid = cValid + "‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˘˙˚¸"; 
	} else if (pcFieldType == "I") 
	{
		cValid = "0123456789-";
		poField.value = parseFloat(poField.value);
	} else if (pcFieldType == "N")  
	{
		cValid = "0123456789-."; 
		poField.value = parseFloat(poField.value);
	} else if (pcFieldType == "D") 
	{ 
		cValid = "0123456789/" ;
	} else if (pcFieldType == "H") 
	{
		cValid = "0123456789:" 
	} else if (pcFieldType == "B")        
	{
		cValid =          "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		cValid = cValid + "0123456789_";
		poField.value = poField.value.toUpperCase();
	} else if (pcFieldType == "P" || pcFieldType == "S" || pcFieldType == "C" || pcFieldType == "@") 
		cValid = null; 

	if (cValid && !validValue(poField.value, cValid, (pcFieldType == "B"))) 
   { 
		defineFieldMessage(poField, STR0010 + cValid); //"O valor informado Ç inv†lido.<br>Caracteres v†lidos para este campo:<br>"
         break exitValid; 
	} 
	if (pcFieldType == "B")
	{                      
		var cLetra = poField.value.substr(0,1).toUpperCase();
		if ((cLetra < "A")|| (cLetra > "Z"))
	   { 
    		defineFieldMessage(poField, STR0011); //"O valor informado inv·lido. Ele deve comeÁar com uma letra."
            break exitValid; 
		} 
	}
	else if (pcFieldType == "@" && !validMail(poField.value)) 
	{ 
		defineFieldMessage(poField, STR0012 ); //"O valor informado n∆o Ç um endereáo de e-Mail v†lido.<br>Use o formato: nome@dominio.xxx[.yy]"
         break exitValid; 
	} else if (pcFieldType == "I" || pcFieldType == "N")  
   { 
		var cValue = poField.value;     
		var cPos = cValue.indexOf("-"); 
		if (cPos != -1) 
		{ 
			if ( cPos != cValue.lastIndexOf("-")) 
			{ 
       	defineFieldMessage(poField, STR0013 + '\"-\"."' ); //"O valor informado possue mais de uma ocorrància do sinal" 
        break exitValid; 
			} 
			if ( cPos != 0) 
				poField.value = "-" + cValue.substring(0, cPos) + cValue.substring(cPos + 1, 255); 
		} 
      if (pcFieldType == "N") 
      { 
			var cValue = poField.value; 
         var cPos = cValue.indexOf("."); 
         if (cPos != -1) 
         { 
            if ( cPos != cValue.lastIndexOf(".")) 
            { 
			   defineFieldMessage(poField, STR0014 ); //"O valor informado possue mais de uma ocorrància do ponto decimal."
               break exitValid; 
            }                              
            
			var cDec = cValue.substring(cPos + 1, cValue.length); 
            if (cDec.length > pnDecimals) 
            { 
	          defineFieldMessage(poField, STR0015  + pnDecimals + STR0016 ); //"O n£mero de decimais informado ultrapassa o limite de " " casas decimais."
              break exitValid; 
            } 
         } 
		} 
	} else if (pcFieldType == "D") 
    {
      var cValue = poField.value; 
      var cBarraDia = cValue.indexOf("/"); 
      var cBarraMes = cValue.lastIndexOf("/"); 
      
      if (cBarraDia == cBarraMes || cValue.length < 6) 
      { 
     		defineFieldMessage(poField, STR0017); //"O valor informado n∆o Ç um formato v†lido.<br>Use o formato DD/MM/YYYY."
        break exitValid; 
      } 
      var cDia = cValue.substr(0, cBarraDia); 
      var cMes = cValue.substr(cBarraDia + 1, cBarraMes - cBarraDia - 1); 
      var cAno = cValue.substr(cBarraMes + 1, 4); 
      if (cAno < 40) 
        cAno = "20" + cAno 
      else if (cAno.length == 2) 
        cAno = "19" + cAno; 
      cMes = eval(cMes); 
      if (cMes < 1 || cMes > 12) 
      { 
        defineFieldMessage(poField, STR0018); //"O màs informado n∆o Ç um màs v†lido."
        break exitValid; 
      } 
      var aDaysMonth = new Array(-1, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31); 
      var nMaxDays = aDaysMonth[ cMes ]; 
      if (cMes == 2) 
      { 
        if ((cAno % 4) != 0 || ((cAno % 400) != 0 && (cAno % 100) == 0)) 
          nMaxDays = 28; 
      } 
      if (cDia < 1 || cDia > nMaxDays ) 
      { 
        defineFieldMessage(poField, STR0019 ); //"O dia informado n∆o Ç um dia v†lido."
        break exitValid; 
      } 
      strDia = "A" + (100+eval(cDia)); 
      strMes = "A" + (100+eval(cMes)); 
      poField.value = strDia.substr(2,2) + 
                    "/" + strMes.substr(2,2) + 
                    "/" + cAno; 
   } else if (pcFieldType == "P") 
   { 
      if (poField.selectedIndex == 0) 
      { 
		defineFieldMessage(poField, STR0020 ); //"A primeira opá∆o n∆o Ç v†lida. Escolha outra."
         break exitValid; 
      } 
	} else if (pcFieldType == "H") 
   {
		var cValue = poField.value; 
      var cBarraHora = cValue.indexOf(":"); 
      var cBarraMin = cValue.lastIndexOf(":"); 
      if (cBarraHora == -1)
      { 
 		 defineFieldMessage(poField, STR0021); //"O valor informado n∆o Ç um formato v†lido.<br>Use o formato HH:MM:SS ou HH:MM, com rel¢gio de 24h, <BR>pode-se colocar a hora (HH), minutos (MM) ou segundos (SS) com um ou dois d°gitos."
         break exitValid; 
      } 
      if (cBarraHora == cBarraMin)
		{                 
			cValue += ':00';
			cBarraMin = cValue.lastIndexOf(":"); 
		}                                       

      var cHora = cValue.substr(0, cBarraHora); 
      var cMinuto = cValue.substr(cBarraHora + 1, 2);
      var cSegundo = cValue.substr(cBarraMin + 1, 2); 

      cHora = eval(cHora); 
      if ((cHora < 0) || (cHora > 23))
      { 
		defineFieldMessage(poField, STR0022); //"A hora informada, n∆o Ç uma hora v†lida."
         break exitValid; 
		} 

      cMinuto = eval(cMinuto); 
      if ((cMinuto < 0) || (cMinuto > 59) )
      { 
		   defineFieldMessage(poField, STR0023); //"O minuto informado n∆o Ç um minuto v†lido."
       break exitValid; 
		} 

      cSegundo = eval(cSegundo); 
      if ((cSegundo < 0) || (cSegundo > 59)) 
      { 
				defineFieldMessage(poField, STR0024 );//"O segundo informado n∆o È um segundo v†lido."
        break exitValid; 
      } 
      strHora = "A" + (100+eval(cHora)); 
      strMin  = "A" + (100+eval(cMinuto)); 
      strSeg  = "A" + (100+eval(cSegundo)); 
      poField.value = strHora.substr(2,2) + ":" + strMin.substr(2,2) + ":" + strSeg.substr(2,2);
   }
   
   if (pxMinValue && poField.value < pxMinValue) 
   { 
     defineFieldMessage(poField, STR0025 + '"\"' + pxMinValue + '"\"."'); //"O valor informado Ç inferior a "
     break exitValid; 
   } 
   if (pxMaxValue && poField.value > pxMaxValue) 
   { 
     defineFieldMessage(poField, STR0026 + '"\"' + pxMaxValue + '"\"."'); //"O valor informado Ç superior a "
     break exitValid; 
   } 
  }

	try 
	{ 
    eval(poField.name + "_valid(poField)");
	} catch (err) { };                     

	if (retrieveFieldMessage(poField))
	{
		if (poFieldMsg) {
			defineFieldError(poFieldMsg);
		} else {
			defineFieldError(poField);
		}
	}

  return (retrieveFieldMessage(poField)?false:true); 
}

function doChangeToolbar(oSender, cIDToolbar, oImageList)
{                                             
  var oDiv = getElement(cIDToolbar);
  var cClassName = '';                      
  if (oSender.src.indexOf('ic_toolbar_label') == -1)
  {
    oSender.src=oImageList[3];
    oSender.alt='Identificado';
    cClassName = 'toolbar_normal';
  } else
  {
    oSender.src=oImageList[2];
    oSender.alt='Sem identificaÁ„o';
    cClassName = 'toolbar_label';
  }
  oSender.title = oSender.alt;
  oDiv.className = cClassName;
}                             

function doHelp(oSender, sLocation){
	window.open( sLocation )
}
                          
function doRefresh(oSender)
{
	//document.location.reload(true)
	var dAux = new Date();
	if (oSender.tagName == 'IFRAME')                                 
		oSender.document.location = prepParam(oSender.document.location, "_forceReload", dAux.getTime().toString(16));
	else
		oSender.location = prepParam(oSender.location, "_forceReload", dAux.getTime().toString(16));
}

function doClose(alRefresh)
{                         
  if (arguments.length == 0)
    alRefresh = true;

	if (window.opener) 
	{          
	  if (alRefresh)
      doRefresh(window.opener);
    window.close();
	} else if (parent.window.opener) {
	   parent.window.close();
	} else {
	   window.history.back();
	}
}                     

function enableAllButtons()
{
	setClassAllButtons("");
}

function disableAllButtons()
{
	setClassAllButtons("inativo");
}

function setClassAllButtons(acClassName) {
	var oObjs = document.getElementsByTagName('button');
	for (var o in oObjs)
	{
		oObjs[o].className = acClassName;
		oObjs[o].disabled = true;
	}
}

function doReset(oForm)
{
	var oObjs = oForm.getElementsByTagName('div');
	var lReset = true;
		
	for (var o in oObjs)
		if (oObjs[o].className == "DwTabbedGroup")
		{
			lReset = window.confirm(STR0027); //"Atená∆o: Todas as "ABAS" ter∆o seus dados restaurados para os valores inicias.\n\nConfirma 'desfazer'?"
			break;
		}

	if (lReset)
	  oForm.reset();
  
  return true;
}

function doSubmit(oForm)
{            
  var lRet = (retrieveMessage() == "");
  
	if (lRet)
	{
		if (oForm.onsubmit)
		{
			lRet = oForm.onsubmit();
		}
	}
	if (lRet)
	{
		oForm.submit();
	} else
  {
		focusFirst(oForm, true);
  }
  
	return lRet;
}                     

function doLoad(acURL, acTarget, poDocument, acWinName, anWidth, anHeight, anLeft, anTop, alConfirma)
{           
  if (alConfirma)
  {
    if (!window.confirm(STR0028)) //"A execuá∆o deste procedimento pode levar algum tempo,\nem funá∆o do volume de dados ou mesmo outros fatores.\n\nConfirma o processamento?"
       return;
  }   

  var cScroll = "scrollbars=";
  var cStatus="status=";
  var re = /&amp;/gi          
  acURL = acURL.replace(re, "&");
  
  if ((anHeight == 1) && (anWidth ==  1)) {
		cScroll = cScroll + "yes,resizable=yes"
		cStatus += "no";
	} else {
		cScroll = cScroll + 'yes'; //((acWinName == PRINT_WINDOW_NAME)?'yes':'no');
		cStatus += "yes";
	}

	if (acTarget)            
	{          
		if ((acTarget == "_window") || (acTarget == "_blank") || (acTarget == "_hidden") || (acTarget == "_modal") || (acTarget == "_DwPrint"))
		{
			var nHeight = Math.floor(anHeight>1.1?anHeight:window.screen.availHeight * anHeight - 10);
			var nWidth = Math.floor(anWidth>1.1?anWidth:window.screen.availWidth * anWidth - 10);
			var nLeft = Math.floor(anLeft?anLeft:((window.screen.availWidth - nWidth) / 2));
			var nTop = Math.floor(anTop?anTop:((window.screen.availHeight - nHeight) / 2));
			var cSize = "top="+nTop+", left="+nLeft+", height=" + nHeight + ", width=" + nWidth;
			var oWin;                                   

			if (acTarget == "_modal") 
			{ 
			  oWin = openModalWindow(acURL, 0, cSize);
			} else     
			{
			  if (!(acWinName) || acTarget == "_blank")
					acWinName = "WinDW"+(new Date()).getTime();
			  oWin = window.open(acURL+"&_w=1", acWinName, cStatus+", toolbar=no, menubar=no," + cScroll + ", " + cSize);
			  if (!(acTarget == "_hidden"))
			     oWin.focus();
			}
		} else
		{               
			if (acTarget == "_top")
			{                   
				window.parent.location.href = MakeURL(acURL);
			} else if (acTarget == "_main")
			{               
				top.principal.inferior_direito.location.href = MakeURL(acURL);
			} else if (acTarget == "_script")
			{                   
 				top.documentSource = poDocument;
				top.script.location.href = MakeURL(acURL);
			} else
			{
				var oAux = window.frames[acTarget];
				if (oAux)
					oAux.location.href = MakeURL(acURL);
				else
					window.parent.frames[acTarget].location.href = MakeURL(acURL);
			}
		}  
	} else
	{
 		location.href = MakeURL(acURL);
  }
}

function doSelAll(aoSelectedObj, aoFormId) 
{
  var cAlvo = aoSelectedObj.name.substring(0, 3);
  var oElements = aoFormId.elements;
  
  for (var nInd = 0; nInd < oElements.length; nInd++) {
    if (oElements[nInd].type == "checkbox" &&
        oElements[nInd].name.substr(0, 3).toUpperCase() == cAlvo.toUpperCase()) {
      oElements[nInd].checked = aoSelectedObj.checked;
    }
  }
}

function MakeURL(acURLParcial) {                            
  var cUrl = "";                                 
  if (acURLParcial.substr(0,4).toUpperCase() != "HTTP") {
    cUrl = location.href;
    cUrl = cUrl.split("?")[0]
    cUrl = cUrl.substr(0, cUrl.lastIndexOf("/"));
    if (acURLParcial.substr(0,1) == ".") {
      cUrl = cUrl + acURLParcial.substr(1);
    } else {
      cUrl = cUrl + acURLParcial;
    }
  } else {
    cUrl = acURLParcial;
  }
  return (cUrl);
}

function checkConfirmationCode(confCode) {
  var cCode = window.prompt( STR0029 , ''); //'Informe c¢digo de confirmaá∆o'
  
  if (!( cCode == confCode)) {
    alert( STR0031 );
  }
  
  return (cCode == confCode);
}

function resetForm(formName) {
  var aElem = formName.elements;
  var component;
  for (i = 0; i < aElem.length; i++) 
  {
    component = aElem[i];
    if (component.type == "checkbox" || component.type == "radio") 
    {
      component.checked = false;
    } else if (component.type == "text" || component.type == "textarea" || component.type == "password") 
    {
      component.value = "";
    } else if (component.type == "select-one") 
    {
      component.selectedIndex = 0;
    }
  }
  focusFirst(formName);
}

function doShowMenu(anMenu, anAba, aEvent)
{              
	var lFF = window.event ? false : true;
	var oEvent = lFF ? aEvent : window.event ;
	var oSource = lFF ? oEvent.target : oEvent.srcElement;
  var oDivMenu = getElement("divMenu"+anMenu);

  if (oEvent)
  {                             
  	if (oBw.ff)
	  {
  	  oDivMenu.style.left = (oEvent.clientX+document.body.scrollLeft)+"px";
    	oDivMenu.style.top = (oEvent.clientY+document.body.scrollTop)+"px";
	  } else
  	{
    	oDivMenu.style.pixelLeft = oEvent.clientX+document.body.scrollLeft;
	    oDivMenu.style.pixelTop = oEvent.clientY+document.body.scrollTop;
  	}
	  showElement(oDivMenu);
	  isMenuShow = true;
    menuSelObj = oDivMenu;
	  return false ;
  }
}

function doHideMenu(oSender, aoEvent)
{                             
}

function startMenu(anMenu)
{
  if (getElement('divMenu'+anMenu))
  	initTable('divMenu'+anMenu, true, true);
}

function prepParam(acURL, pcParam, pxValue)
{                 
	var lOk = false;
	var aBase = acURL.toString().split('?');
	var aParms = new Array();
	
	if (aBase.length > 1)	
		aParms = aBase[1].split('&');
	
	for (var nInd=0; nInd < aParms.length;nInd++)
		if (aParms[nInd].indexOf(pcParam+'=') > -1)
		{
			aParms[nInd] = pcParam+'='+pxValue;
			lOk = true;
			break;
		}
	if (!lOk) aParms.push(pcParam+'='+pxValue);
 
	return aBase[0] + "?" + aParms.join('&');
}

function makeRollover(oTableTR, mouseOverEvent) 
{        
	if (mouseOverEvent)
	{
		if (oTableTR.className.indexOf("rollOver") == -1)
			oTableTR.className = "rollOver" + oTableTR.className;
	} else {
  	var re = /rollOver/gi;
		oTableTR.className = oTableTR.className.replace(re, "");
	}
}

function gravaCookie(name, value, cMasterCookie)
{
	var cCookie;
	if (cMasterCookie)
	{
		cCookie = value;
	} else    
	{
		cMasterCookie = "params";
		cCookie = GetCookie(cMasterCookie);
		cCookie = prepParam("?"+cCookie, name, value).substr(1);
	}		
	var dAux;
	if (cMasterCookie.substr(1,1) == "_")
	{                                                
		dAux = new Date();
		dAux.setYear(dAux.getYear()+1);
	}
	SetCookie(cMasterCookie, cCookie, dAux);
}

function SetCookie (name, value) 
{  
	var argv = SetCookie.arguments;  
	var argc = SetCookie.arguments.length;  
	var expires = (argc > 2) ? argv[2] : null;  
	var path = (argc > 3) ? argv[3] : null;  
	var domain = (argc > 4) ? argv[4] : null;  
	var secure = (argc > 5) ? argv[5] : false;  
	name = name.toUpperCase();
	var cAux = name + "=" + escape(value);
	if (expires) { cAux += 	"; expires=" + expires.toGMTString() };
	if (path) { cAux += 	"; path=" + path };
	if (domain) { cAux += 	"; domain=" + path };
	if (secure) { cAux += 	"; secure" };
	
	document.cookie = cAux;
}

function clearCookie(name, all) 
{                       
	if (document.cookie != "") 
	{
		var thisCookie = document.cookie.split("; ");
	 	var expireDate = new Date();
		expireDate.setDate(expireDate.getDate()-1);
	   for (i=0; i<thisCookie.length; i++)
	   {
			var cookieName = thisCookie[i].split("=")[1]
			if ((cookieName == name) || all)
		    	document.cookie = "cookieName="+cookieName + ";expires=" + expireDate.toGMTString();
  		}
	}
}

function GetCookie(name) 
{  
	var arg = name.toUpperCase() + "=";  
	var alen = arg.length;  
	var clen = document.cookie.length;  
	var i = 0;  
	while (i < clen) 
	{
		var j = i + alen;    
		if (document.cookie.substring(i, j) == arg)      
			return getCookieVal (j);    
		i = document.cookie.indexOf(" ", i) + 1;    
		if (i == 0) break;   	
	}  
	return "";
}

function getCookieVal (offset) 
{  
	var endstr = document.cookie.indexOf (";", offset);  
	
	if (endstr == -1)    
		endstr = document.cookie.length;  
	
	return unescape(document.cookie.substring(offset, endstr));
}

function doMouseOut_img(oSender)
{
	var oStatusInfo = getElement('statusInfo');
	
	if (oStatusInfo)
		hideElement(oStatusInfo);
	oSender.src = oSender.src.replace(new RegExp("_on","gi"),"_off");
}

function doMouseOver_img(oSender)
{ 
  doMouseEnter_img(oSender);
}

function doMouseEnter_img(oSender)
{ 
	if (oSender.alt)
	{
		var oStatusInfo = getElement('statusInfo');
		if (oStatusInfo)
		{
			oStatusInfo.innerHTML = oSender.alt;
			showElement(oStatusInfo, true);
		}
	}
	oSender.src = oSender.src.replace(new RegExp("_off","gi"),"_on");
}

function focusFirst(oSender, lError)
{
	var lContinue = true;
	function procElements(aElements)
	{
		for (j = 0; j < aElements.length && lContinue; j++) 
		{
	 		if ((aElements[j].type == "text" || aElements[j].type == "checkbox" || aElements[j].type == "textarea"
	  			|| aElements[j].type == "select-one" || aElements[j].type == "select-multiple")
		  		&& !aElements[j].disabled && !aElements[j].readOnly) {
				try {
					if (lError)
					{
						if (aoField.msgError)
						{
							aElements[j].focus();
							lContinue = false;
						}
					} else
					{
						aElements[j].focus();
						lContinue = false;
					}
				} catch (err) { 
					showError('focusFist', err);
					lContinue = true;
				}
			}
		}
	}
	
	if (oSender)
	{
		procElements(oSender.getElementsByTagName("input"));
	} else
	{
		var aForms = window.document.forms;
		for (i = 0; i < aForms.length && lContinue; i++)
		{
			procElements(aForms[i].elements);
			fitComponentsToClient(aForms[i].elements);
		}
	}
}

function fitComponentsToClient(aElements) {
	for (j = 0; j < aElements.length; j++) {
		if ((aElements[j].type == "text" || aElements[j].type == "textarea" || aElements[j].type == "select-one"
				|| aElements[j].type == "select-multiple") && !aElements[j].disabled && !aElements[j].readOnly) {
			var iParWidth = Math.floor(getParentElement(aElements[j]).clientWidth / 7);
			if (iParWidth > 0 && aElements[j].size > iParWidth) 
			{
				aElements[j].size = iParWidth;
			}
		}
	}
}

function setAllInputReadOnly() {
	var aForms = window.document.forms;
	for (i = 0; i < aForms.length; i++) {
		var aElements = aForms[i].elements;
		for (j = 0; j < aElements.length; j++) {
			if ((aElements[j].type == "text" || aElements[j].type == "checkbox" || aElements[j].type == "textarea"
					|| aElements[j].type == "select-one" || aElements[j].type == "select-multiple")
					&& !aElements[j].disabled) {
				try { aElements[j].disabled = true;	} catch (err) { showError('setAllInputReadOnly', err) }
			}
		}
	}
}

function zoomIn(aoComponent)
{
	zoomComponent(aoComponent, 0.05);
}

function zoomReset(aoComponent)
{
	zoomComponent(aoComponent, 0);
}

function zoomOut(aoComponent)
{
	zoomComponent(aoComponent, -0.05);
}

function zoomComponent(aoComponent, nZoomLevel)
{
	if (!(aoComponent.style.zoom) || !(nZoomLevel))
		aoComponent.style.zoom = 1.0;
		
	var nZoom = Number(aoComponent.style.zoom);
	
	nZoom = nZoom + nZoomLevel; 
	nZoom = Math.max(0.20, nZoom);
	nZoom = Math.min(2.00, nZoom);
	aoComponent.style.zoom = nZoom;
	window.status = "Zoom: " + nZoom;
}

var aAbas = new Array();

function initAbaList(aaAbaList)
{
  for (i = 0; i < aaAbaList.length; i++) 
  	aAbas.push(aaAbaList[i]);
}

function showAba(acAbaName) 
{   
  for (var i = 0; i < aAbas.length; i++) 
  {                                                   
    var oAba = getElement(aAbas[i]);   
    if (acAbaName == aAbas[i]) 
    {                            
			showElement(oAba);
			focusFirst(oAba);
      oAba = getElement("DwTabbed" + aAbas[i])
      oAba.className = "current";
			var oTR = getParentElement(oAba);
			while ((oTR) && !(oTR.tagName == 'TR'))
			  oTR = getParentElement(oTR);
			var oTable = getParentElement(oTR);
			if (oBw.ie)
      {
        if (!(oTR.rowIndex == (oTable.rows.length - 1)))
          oTR.swapNode(oTable.rows[oTable.rows.length - 1]);
      }
			try 
			{
    		eval(acAbaName + "_doShow()");
	    } catch (err) { };                     
    } else
    {
		  if (isElementVisible(oAba))
		  {
				try 
				{              
    			eval(aAbas[i] + "_doHide()");
				} catch (err) { };                     
				hideElement(oAba);
			}
      getElement("DwTabbed" + aAbas[i]).className = "";
    }
  }
}

function adjustSizeAba() 
{
  var nWidth = -1;
  var nHeight = -1;
  
  for (var i = 0; i < aAbas.length; i++) 
  {                                                   
    var oAba = getElement(aAbas[i]);
	  if (oAba)
	  {
        nWidth = nWidth < oAba.offsetWidth?oAba.offsetWidth:nWidth;
        nHeight = nHeight < oAba.offsetHeight?oAba.offsetHeight:nHeight;
	  }
  }                                            
            
  if (nWidth > 0)
  {
	  for (var i = 0; i < aAbas.length; i++) 
	  {                                                   
    	  var oAba = getElement(aAbas[i]);
	  	  oAba.style.width = nWidth;
  		  oAba.style.height = nHeight;
	  }
  }
} 
				
function initAba(acAbaName)
{                                   
  showAba((acAbaName) ? acAbaName : aAbas[0]);
  adjustSizeAba();
}

function doShowOperMenu(aoParams, aEvent)
{                
	var lFF = window.event ? false : true;
	var oEvent = lFF ? aEvent : window.event ;
	var oSource = lFF ? oEvent.target : oEvent.srcElement;

  if (oEvent)
  {                             
    var oDivMenu = getElement("operMenu");
    var aLinks, aImages;

    aLinks = getElementsByTag('A', oDivMenu);
    aImages = getElementsByTag('IMG', oDivMenu);
    
    var aButtonList = new Array();
    
    for (var nInd = 0; nInd < aLinks.length; nInd++)
      aButtonList.push(true);

    var lOk = true;
     
    try { lOk = u_operActIsEnable(aButtonList, aoParams['id']); } catch (err) { showError('doShowOperMenu', err) }

    for (var nInd = 0; nInd < aLinks.length; nInd++)
    {                                  
        var lEnable = (aButtonList[nInd] && lOk);
        if (aLinks[nInd].oldHref)
          aLinks[nInd].href = aLinks[nInd].oldHref;
        else  
          aLinks[nInd].oldHref = aLinks[nInd].href;
        aLinks[nInd].disabled = !lEnable;
        getParentElement(aLinks[nInd]).disabled = !lEnable;
        aImages[nInd].disabled = !lEnable;
        if (lEnable)
        {
          for (var i in aoParams)
           aLinks[nInd].href = aLinks[nInd].href.replace('@' + i, aoParams[i]);
        } else
        	aLinks[nInd].href = '#';
    }

  	if (oBw.ff)
	  {
  	  oDivMenu.style.left = (oEvent.clientX+document.body.scrollLeft)+"px";
    	oDivMenu.style.top = (oEvent.clientY+document.body.scrollTop)+"px";
	  } else
  	{
    	oDivMenu.style.pixelLeft = oEvent.clientX+document.body.scrollLeft;
	    oDivMenu.style.pixelTop = oEvent.clientY+document.body.scrollTop;
  	}
	  showElement(oDivMenu);
  	isOverPopupMenuShow = true;
  	menuSelObj = oDivMenu
	  return false ;
  }
}

function body_resize()
{
	if (!window.opener) {
		body_load(true);
		getElement('page_body').style.overflow = "auto";
	}
}

function body_load(alOnResize, alP11)
{ 
  lWindowPosSize = true;
  lHideWait = true;
  
  if (!alOnResize) {
    try { u_bodyonload(); } catch (err) { showError('body_load.1', err) }
    try { u_bodyMenuNaveg(); } catch (err) { showError('body_load.2', err) }
    try { u_drawFunctions(); } catch (err) { showError('body_load.3', err) }
    try { u_pivotonload(); } catch (err) { showError('body_load.4', err) }
    try { u_queryPageonload(); } catch (err) { showError('body_load.5', err) }
  }
  
  if (window.opener)
    try { u_setWindowPosSize(); } catch (err) { showError('body_load.6', err); autoWindowPosSize(); } ;
                
  if (getElement('operMenu'))
  	initTable('operMenu', true);

  if (!alP11) {
    if (!(window.opener)) {     
      adjustFooterPosition();
    }
  }
  
  if (!alOnResize) {
    focusFirst();
  }

  if (getElement('onLineNotify'))
    doOnLineNotify();
	
  if (lHideWait)
    hideWait();	
}

function hideWait(aoSender)
{                        
	var oWait = getElement('waitImg', aoSender);
 	if (oWait)
 	{
	  clearInterval(oWait.hWaitBarAtz);
	  hideElement(oWait);
		oWait.hWaitBarAtz = 0;
	}
	window.status = 'Pronto'; 
	_nAnima = MAX_ANIMA
	_cBarra = ""
}

var _cCharBarra = "|";
var _cBarra = "";
var MAX_ANIMA = 30;
var _nAnima = MAX_ANIMA;

function waitBarAtz()
{              
  _cBarra += _cCharBarra
  window.status = STR0031 + _cBarra //"Favor aguardar. Transferindo dados... "
  if (_nAnima == 0)
  {
  	_cBarra = '';
    _nAnima = MAX_ANIMA + 1;
  }
  _nAnima -= 1;
}

function showWait(aoSender)
{                                          
	var oWait = getElement('waitImg', aoSender);
 	if (oWait)
	{
	  showElement(oWait);
    if (!oWait.hWaitBarAtz)
			oWait.hWaitBarAtz = setInterval('waitBarAtz()', 500);
		_nAnima = MAX_ANIMA
		_cBarra = ""
  } else
  {
	 	document.write(getTagWaitImage())
  	showWait(aoSender);
  };
}

function body_unload(acAction)
{
	if (document.getElementsByTagName)
	{ 
		var objs = document.getElementsByTagName("object");  //Get all the tags of type object in the page. 
		for (i=0; i<objs.length; i++) 
			objs[i].outerHTML = ""; // Clear out the HTML content of each object tag to prevent an IE memory leak issue. 
	}

	if (!window.opener && self.screenTop > 9000)
	{
		if (!window.frameElement || window.frameElement.tagName != 'IFRAME')
		{
			doLoad(acAction, '_window', null, 'DwSaving', "0.50", "0.25");
		}
	}
}

function doEditExpression(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, acTipo, anObjID, 
      alSQL, alChange, alEmbedded, acAlias, acEmpFil, acSample)
{
  var cURL = getEditExpressionURL();
  cURL = prepParam(cURL, 'Tipo', acTipo);
  cURL = prepParam(cURL, 'objID', anObjID);
  cURL = prepParam(cURL, 'isSQL', alSQL?'1':'0');
  cURL = prepParam(cURL, 'chg', alChange?'1':'0');
  cURL = prepParam(cURL, 'caption', acCaption);
  cURL = prepParam(cURL, 'id_expr', anIDSQL);
  cURL = prepParam(cURL, 'id_base', anIDSQLBase);
  cURL = prepParam(cURL, 'targetID', acTargetID);
  cURL = prepParam(cURL, 'targetText', acTargetText);
  if (alEmbedded)
  {
  	cURL = prepParam(cURL, 'embedded', '1');
  	cURL = prepParam(cURL, 'alias', acAlias);
  	cURL = prepParam(cURL, 'empfil', acEmpFil);
  	cURL = prepParam(cURL, 'sample', acSample);
	}  	

  doLoad(cURL, '_blank', document, 'expressao', 0.90,0.90, 0, 0);
}

function doEditSQL(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, 
		acTipo, anObjID, alEmbedded, acAlias, acEmpFil, acSample)
{
	if (alEmbedded)
	  doEditExpression(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, acTipo, anObjID, true, false, alEmbedded, acAlias, acEmpFil, acSample);
	else
	  doEditExpression(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, acTipo, anObjID, true, false, false);
}

function doEditAdvpl(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, acTipo, anObjID)
{
  doEditExpression(acCaption, anIDSQL, anIDSQLBase, acTargetID, acTargetText, acTipo, anObjID, false, false);
}

function makeMask(acTipo, anTam, anNDec)
{
  var cRet = "";
  anTam	= parseInt(anTam);
  anNDec	= parseInt(anNDec);

	switch (acTipo) 
	{
		case 'C': 
			cRet = '@X';
			break;
		case 'D': 
			cRet = '@E 99/99/9999';
			break;
		case "L": 
			cRet = '@L';
			break;
		case "M": 
			cRet = '@X';
			break;
		default:        
			anTam = anTam - (anNDec==0?0:anNDec+1);     
            var cNum = "999999999999999999999999999999".substr(0, anTam);
			cRet = formatCurrency(cNum) + ".999999999999999999".substr(0, (anNDec==0?0:anNDec+1));
			cRet = "@E " + cRet;
 	}
 	return cRet;   
}

function formatCurrency(num) {
	num = num.toString().replace(/\$|\,\./g,'');
	sign = (num == (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	num = Math.floor(num/100).toString();
    for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
	    num = num.substring(0,num.length-(4*i+3))+','+
  		num.substring(num.length-(4*i+3));
  		
    return num;
}

function checkNumber(oSender, aEvent)
{
	var oEvent = window.event ? window.event : aEvent;
	var nKeyCode = oBw.ie?event.keyCode:aEvent.which;
	var cKeyChar = String.fromCharCode(nKeyCode);
	var lErro = false;
	var lRet = true;
	
  if ((nKeyCode > 31) && ((nKeyCode < 45) || (nKeyCode > 57)))
		lErro = true;

	if (oBw.ie)
	{
	  if (lErro)
	    event.returnValue = false;
	}
	
	if (lErro)
	{
		if (!(getColor(oSender) == "silver"))
		{
			window['timeOutObject'] = oSender;
			window['timeOutColor'] = getColor(oSender);
			setColor(oSender, "silver");
			window['timeOutControl'] = setInterval("doResetColor()", 750);
		}  
	                  
	}
	return !lErro;
}

function checkKey(oSender, aEvent)
{        
	var lErro = false;
	var lRet = true;
	
	var nKeyCode = oBw.ie?event.keyCode:aEvent.which;
	var cKeyChar = String.fromCharCode(nKeyCode);
	var cSpcChars = '\'(!@#$%®&*()-+^~\"=[]{}/?:><.,;`¥';

  if ( (nKeyCode > 31) && (
      ((nKeyCode == 32) || (nKeyCode == 45) ||
			(cSpcChars.indexOf(cKeyChar) > -1))))
		lErro = true;

	if (oBw.ie)
	{
	  if (lErro)
  	{                                           
	    event.returnValue = false;
	  } else
  	{
	    var x = String.fromCharCode(event.keyCode);
  	  x = x.toUpperCase()
	    event.keyCode = x.charCodeAt(0);
	  }   
	} else
	{
	  if (lErro)
	  { } 
	  else if (!(cKeyChar.toUpperCase() ==  cKeyChar))
	  {
      var evt = document.createEvent("KeyboardEvent");
      evt.initKeyEvent(                                                                                      
                 "keypress",        //  in DOMString typeArg,                                                           
                  true,             //  in boolean canBubbleArg,                                                        
                  true,             //  in boolean cancelableArg,                                                       
                  null,             //  in nsIDOMAbstractView viewArg,  Specifies UIEvent.view. This value may be null.     
                  false,            //  in boolean ctrlKeyArg,                                                               
                  false,            //  in boolean altKeyArg,                                                        
                  false,            //  in boolean shiftKeyArg,                                                      
                  false,            //  in boolean metaKeyArg,                                                       
                   0,               //  in unsigned long keyCodeArg,                                                      
                   cKeyChar.toUpperCase().charCodeAt(0));              //  in unsigned long charCodeArg);
      oSender.dispatchEvent(evt);
			lErro = true;
	  }
	  
	}
	
	if (lErro)
	{
		if (!(getColor(oSender) == "silver"))
		{
			window['timeOutObject'] = oSender;
			window['timeOutColor'] = getColor(oSender);
			setColor(oSender, "silver");
			window['timeOutControl'] = setInterval("doResetColor()", 750);
		}  
	                  
	}
	return !lErro;
}

function checkDate(oSender, aEvent)
{
	var oEvent = window.event ? window.event : aEvent;

  oEvent.returnValue = ((oEvent.keyCode >  47) && (oEvent.keyCode < 58 )) || (oEvent.keyCode == 47);
  if (oEvent.returnValue == false)
  {                                           
    if (!(getColor(oSender) == "silver"))
    {
      window['timeOutObject'] = oSender;
      window['timeOutColor'] = getColor(oSender);
      setColor(oSender, "silver");
      window['timeOutControl'] = setInterval("doResetColor()", 750);
    }  
  }  
}

function doResetColor()
{
  clearInterval(window['timeOutControl']);
  setColor(window['timeOutObject'], window['timeOutColor']);
  window['timeOutObject'] = 0;
  window['timeOutColor'] = 0;
  window['timeOutControl'] = 0;
}

function autoWindowPosSize()
{       
	if (!(window.name == PRINT_WINDOW_NAME))
	{
  	if (lWindowPosSize)
  	{
	  	var oStart = getAllElements();
		  var nWidth = 0, nHeight = 0;
  		var rBody = getClientRect(document.body);
		  for (var i = 0; i < oStart.length; i++)
  		{          
				if (isElementVisible(oStart[i]))
				{				
    			var rAux = getClientRect(oStart[i]);
		    	if (rAux)
  		  	{
    		  	nWidth = Math.max(rAux.right - rAux.left, nWidth);
	    	  	nHeight = Math.max(rAux.bottom - rAux.top, nHeight);
	  	  }
	  	  }
		  }
                            
		  setWindowSize(nWidth + 30, nHeight + 30);
		}
	}
}

function setWindowSize(anWidth, anHeight)
{   
	var nTop = window.screen.availHeight, nLeft = window.screen.availWidth;
	
	if (anHeight > window.screen.availHeight * HEIGHT_LIMIT)
	{
		anHeight = Math.ceil(window.screen.availHeight * HEIGHT_LIMIT);
		anWidth += 30;
		document.body.scroll = "yes";
	}

	if (anWidth > window.screen.availWidth * WIDTH_LIMIT)
		anWidth = Math.ceil(window.screen.availWidth * WIDTH_LIMIT);

	if (oBw.ie)
	  window.resizeTo(anWidth, Math.max(anHeight, 200));
	else
	  window.resizeTo(anWidth+50, Math.max(anHeight, 200)+50);
	
  nLeft = Math.max(Math.ceil((nLeft - anWidth) / 2), 0)
  nTop = Math.max(Math.ceil((nTop - anHeight) / 2), 0)  
  window.moveTo(nLeft, nTop);
  lWindowPosSize = false;
}
 
function adjustFooterPosition()
{                            
  if ((window.frameElement) && (window.frameElement.tagName == 'IFRAME'))
  { 
    if (oBw.ie6)
    { // n„o faz nada
    } else
    {
      adjustDivSize(getElement('page_body'), getParentElement(document.body));
    }
  } else    
  {      
   adjustDivSize(getElement('page_body'), getParentElement(document.body));
  }       
}

function adjustDivSize(aoDiv, aoComponent) 
{      
	if ( aoDiv ) {
		var nHeight = verifyBodyAvailableSpace(aoComponent);
		if (nHeight && nHeight > 0)
			aoDiv.style.height = nHeight + "px";            
	}
}

function verifyBodyAvailableSpace(aoObjHtml) {
	var nHeight = 0;

  if (aoObjHtml)
  {
		nHeight = aoObjHtml.clientHeight - 1;
		var oHeader = getElement('page_header'); 
		var oFooter = getElement('page_footer');
		var oBody = getElement('page_body');
		var oFolder = getElement('folder');
	
		if (oHeader)
			nHeight -= oHeader.offsetHeight;
	
		if (oFolder)
			nHeight -= oFolder.offsetHeight;
	
		if (oFooter)
			nHeight -= oFooter.offsetHeight;
	}	

	return nHeight;	
}

var http_request = false;
var oTarget = false;
var execOnComplete = false;

function doRequestData(acAction, aoTarget, aOnComplete, acRequestMetod, acParameters)
{                                            
	if (!(aoTarget))
		aoTarget = getElement("page_body");

	http_request = false;
	execOnComplete = aOnComplete;
	
	if (window.XMLHttpRequest)  // Mozilla, Safari,...
	{
		http_request = new XMLHttpRequest();
		if (http_request.overrideMimeType)
		{
			http_request.overrideMimeType('text/html');
		}
	} else if (window.ActiveXObject) // IE
	{
		try 
		{
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (err)
		{
			try 
			{
				http_request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (err) { showError('doRequestData', err) }
		}
	}
	
	if (!http_request)
	{
		alert( STR0032 ); //"N∆o foi possivel inicializar o elemento de comunicaá∆o com o servidor (Http Request)"
		return false;
	}
	
	oTarget = aoTarget;
	
	var cForceLoad = new Date();
	cForceLoad = cForceLoad.getMilliseconds().toString(16);
	var cAction = prepParam(acAction, 'jscript', '1');
	cAction = prepParam(cAction, 'isIFrame', '1');
	cAction = prepParam(cAction, 'ign', cForceLoad);
	
	/*O mÈtodo padr„o a ser utilizado È o GET*/
	if (acRequestMetod == undefined) {
		acRequestMetod = 'GET';
	}
	
	http_request.open(acRequestMetod, cAction /*, true*/);    //pela documentaÁ„o ult param n„o existe
	http_request.onreadystatechange = handlerResponseData;
	
	// request por POST
	if (acRequestMetod && acRequestMetod.toUpperCase() == "POST") {
		http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		http_request.setRequestHeader("Content-length", acParameters.length);
		http_request.setRequestHeader("Connection", "close");
	}
	
	http_request.send(acParameters);
}

function handlerResponseData() 
{
	if (http_request.readyState == 4)
	{                   
		if (http_request.status == 200)
		{                     
			var nPosI = http_request.responseText.indexOf('<!-- buildBody beginData -->');
			var nPosF = http_request.responseText.indexOf('<!-- buildBody endData -->');
			
			if (nPosI == -1) nPosI = 0;
			if (nPosF == -1) nPosF = http_request.responseText.length;
			
			var cText = http_request.responseText.substr(nPosI, nPosF - nPosI);
			
			try
			{
				if (oTarget.tagName == 'TBODY') {
					var oAux = getElement('divAuxiliarBrowser');
					oAux.innerHTML = cText;        	
					var oAuxBody = oAux.getElementsByTagName('TBODY');        	
					var oRows = oAuxBody[2].rows;        	
					var oRowsTarget = oTarget.rows;
					for (nRow = 0; nRow < oRows.length; nRow++) {
						var oCells = oRows[nRow].cells;
						var oCellsTarget = oRowsTarget[nRow].cells;
						for (nCell = 0; nCell < oCells.length; nCell++) {
							if (oCellsTarget[nCell])
								oCellsTarget[nCell].innerHTML = oCells[nCell].innerHTML;
						}
					}
					oAux.innerHTML = '';
				} else {
					oTarget.innerHTML = cText;
			  	}
			}
			catch(err)
	  		{
	  		};
			
			if (execOnComplete)
				execOnComplete();
		} else
		{
			alert( STR0033 +http_request.status); //"Ocorreu um erro de comunicaá∆o com o servidor. Erro= "
		}
	}
}

function adjustPosComponent(oObject, oBase, x, y, alTestBounds)
{                 
  var oClientRect = getClientRect(oBase);
  var nTop = y?y:0;
  var nLeft = x?x:0;

  if (oClientRect)
  {
    nTop += oClientRect.bottom;
    nLeft += oClientRect.left;
  }
                           
	if (oBw.ff)
	{         
		nTop = nTop + "px"
		nLeft = nLeft + "px"
	}                 
	
  oObject.style.top = nTop;
  oObject.style.left = nLeft;
  oObject.style.zindex = 99;

  if (alTestBounds)
  {
  	var oAux = document.body;
  	var rAux = getClientRect(oAux);
  	var rObj = getClientRect(oObject);
  	var nDif = (rObj.bottom > rAux.bottom)?(rAux.bottom - rObj.bottom - 30):0;
  	oObject.style.top = nTop + nDif;
  }
}

function getLastInputControl()
{
  return LAST_INPUT_CONTROL;
}

function doOnLineNotify()
{                           
	if (window['timeOnLineNotify'])
	{
		clearTimeout(window['timeOnLineNotify']);
		var dAux = new Date();
		doRequestData('?action=onLineNotify&time='+dAux, 'onLineNotify', doOnLineNotify)
		window['timeOnLineNotify'] = null;
	} else
		window['timeOnLineNotify'] = setTimeout("doOnLineNotify()", 180000); //3 minutos
}

// funÁ„o JavaScript para o preview da impress„o da browser
function doPreviewPrint(acAction) 
{
	doLoad(acAction, "_window", null, "winDWPrint", 0.98, 0.98);
}

function showError(local, err)
{
  if (SHOW_JS_ERROR)
  {
  	var cErro = (err.number * -1).toString(16);
	 	if (false) //((cErro == '7ff5f7c2') || (cErro == '7ff5ec71'))
	 	{ }
	 	else
  	{
  		var aLines = new Array();
			aLines.push('Local de erro: ' + local + "(" + err.number + ")");
  		for (var o in err)
				aLines.push(o+": " + err[o]);
			alert(aLines.join("\n"));
		}
	}	  	
}

function enableElement(oObject, alValue)
{
	oObject.disabled = alValue;

	if (oObject.tagName == "BUTTON")
	{
  	  var re = /inativo/gi;
      oObject.className = oObject.className.replace(re, "");
      if (oObject.className.indexOf("small") > -1)
        oObject.className = alValue?"inativo":"" + oObject.className;
      else
        oObject.className = alValue?"inativo":"";
  }
  
	return alValue;
}

function updateRows(oBodySource, oBodyTarget)
{
	var nRow = 0;

	for (nRow = 0; nRow < oBodySource.rows.length; nRow++)
	{
		var oRow = oBodySource.rows(nRow);
		for (var nCol = 0; nCol < oRow.cells.length; nCol++)
		{
			oBodyTarget.rows(nRow).cells(nCol).innerHTML = oRow.cells(nCol).innerHTML;
		}
	}
	for (; nRow < oBodyTarget.rows.length; nRow++)
	{
		var oRow = oBodyTarget.rows(nRow);
		for (var nCol = 0; nCol < oRow.cells.length; nCol++)
			oRow.cells(nCol).innerHTML = "";
	}
}

function writeApplet(acAppName, acJarFile, acObjName, acWidth, acHeight, acParams, acTextFlow) {
	document.write('<object'+
		'	    classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93"'+
		'	    codebase = "http://java.sun.com/update/1.5.0/jinstall-1_5_0-windows-i586.cab"'+
		'	    WIDTH = "' + acWidth + '" HEIGHT = "' + acHeight + '" ID = "' + acObjName + '" NAME = "' + acObjName + '" >'+
		'	    <param name = "CODE" VALUE = "' + acAppName + '" >'+
		'	    <param name = "ARCHIVE" VALUE = "' + acJarFile + '" >'+
		'	    <param name = "NAME" VALUE = "' + acObjName + '" >'+
		'	    <param name = "type" value = "application/x-java-applet;version=1.5">'+
		'	    <param name = "mayscript" value = "true">'+
		'	    <param name = "scriptable" value = "true">' );
		
	var aParams = acParams.split("|");
	var aParam;
	for (i=0; i<aParams.length; i++) {
		aParam = aParams[i].split(":=");
		document.write('	    <param name = "' + aParam[0] + '" value = "' + aParam[1] + '">');
	}
	
	document.write('<comment>'+
		'		<embed'+
		'			type = "application/x-java-applet;version=1.5" '+
		'	        	CODE = "' + acAppName + '" '+
		'	        	ARCHIVE = "' + acJarFile + '" '+
		'	        	ID = "' + acObjName + '" NAME = "' + acObjName + '"'+
		'			WIDTH = "' + acWidth + '" HEIGHT = "' + acHeight +'"' );
	
	for (i=0; i<aParams.length; i++) {
		aParam = aParams[i].split(":=");
		document.write('			' + aParam[0] + '= "' + aParam[1] + '"');
	}
	
	document.write('		mayscript = "true" scriptable = "true" '+
		'			pluginspage = "http://java.sun.com/products/plugin/index.html#download">'+
		'			<noembed>'+
		'	        		<textflow><i>' + acTextFlow + '</i></textflow>'+
		'	        	</noembed>'+
		'		</embed>'+
		'	    </comment>'+
		'	</object>');
}

function doApplyFilter(oSender)
{                                                                                              
	oSender.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage( Grayscale=1,Opacity=0.40)';

	var oObjs = oSender.getElementsByTagName('button');

	for (var i=0; i< oObjs.length; i++)
		oObjs[i].style.filter = 'progid:DXImageTransform.Microsoft.BasicImage( Grayscale=0,Opacity=1.00)';
}

function mouseMove(e)
{
  var obj;
	try 
	{ 

  if (oBw.ff)
     obj = ""+e == "undefined" ? null : e.target;
  else
    obj = event ? event.srcElement : null;
  
  if (obj)
  {
  	var d = new Date();
  	var lFecha = true;

    if (isOverPopupMenuShow)
    {
      if (isOverPopupMenu)
      {       
        var oAux = obj;
        while (oAux)
        {
        	if ((oAux.id) && (oAux.id == 'operMenu'))
        		lFecha = false;
        	oAux = getParentElement(oAux);
        }  
      } else
      {
        var oAux = obj;
        lFecha = false;
        while (oAux)
        {
        	if ((oAux.id) && (oAux.id == 'operMenu'))
        		isOverPopupMenu = true;
        	oAux = getParentElement(oAux);
        }
      }

      if ((lFecha) && (obj))
      {
        isOverPopupMenu = false;
        menuSelObj.style.display = "none" ;
        menuSelObj = null;
  	  }    
    }      
    
    if (isMenuShow)
    {
      if( isMenu )
      {       
        var oAux = obj;
        while (oAux)
        {
        	if ((oAux.id) && (oAux.id == 'operMenuTab'))
        		lFecha = false;
        	oAux = getParentElement(oAux);
        }  
      } else
      {
        var oAux = obj;
        lFecha = false;
        while (oAux)
        {
        	if ((oAux.id) && (oAux.id == 'operMenuTab'))
        		isMenu = true;
        	oAux = getParentElement(oAux);
        }
      }
      if ((lFecha) && (obj))
      {
  		  isMenu = false ;
        menuSelObj.style.display = "none" ;
        menuSelObj = null;
  	  }    
    }
  }

	} catch (err) { };                     

  return true;
}
    
//Funá‰es utilizada para manipulaá∆o do Help  QBE (Query-By-Exemplo).
var evt_onAfterApply = 0;

function showHlpQbe( bSelecao, oTarget, bOnAfterApply )
{ 
	var oSource = window.event.srcElement; 

	evt_onAfterApply = 0;
	//Tratamento para exibiá∆o de QBE para Seleá∆o. 
	if( bSelecao )
	{		
		var oObj = getParentElement(oSource).childNodes[0];
		oObj.focus();
	}
	else
	{
		//Tratamento para exibiá∆o de QBE para Browsers. 
		if (oTarget){
			var oObj = oTarget;			
			oObj.focus();			
		
		//Tratamento para exibiá∆o de QBE para Filtros. 
		}else{		
			var oObj = getLastInputControl();
		}
	}

	if (oObj)
	{
		clearHlpQBE();
			
		var oDivMain = getElement("divHelpQbeMain");
		var oDivCpts = getElement("divHelpQbeCompon");
				
		showElement(oDivMain);
		showElement(oDivCpts);
				
		oDivCpts.targetField = oObj
		var oAux = oObj;
		
		while ((oAux) && (!(oAux.tagName == 'TR')))
		  oAux = getParentElement(oAux);
		  
		//Realiza posicionamento para exibiá∆o do QBE no DotField.
		if (bSelecao){
			adjustPosComponent(oDivMain, oObj , -50, -115);
		}else{
			adjustPosComponent(oDivMain, oSource , 0, 0);
		}
		
		showElement(oDivMain);
		showElement(oDivCpts);
		evt_onAfterApply = bOnAfterApply;		
	} else
		alert( STR0034 ); //"Favor selecionar um campo primeiro"

}


function clearHlpQBE()
{
	var oDiv = getElement("divHelpQbe");
	var aChecks = document.getElementsByName('edHlpQBE');
	var oNeg = getElement('edHlpQBENeg');
          
	oNeg.checked = false;
	for (var nInd = 0; nInd < aChecks.length; nInd++)
	{
		aChecks[nInd].checked = false;
		var oValue1 = getElement('edHlpQBEValue1'+aChecks[nInd].value);
		var oValue2 = getElement('edHlpQBEValue2'+aChecks[nInd].value);
		if (oValue1) oValue1.value = "";
		if (oValue2) oValue2.value = "";
	}
}       


function applyHlpQBE( alAplly )
{
	var oDiv = getElement("divHelpQbeCompon");
	
	//Recebe o objeto do £ltimo imput que recebeu foco. 
	var oObj = getLastInputControl();
	
	if (alAplly)
	{
		var aChecks = document.getElementsByName('edHlpQBE');
		var oCheck = null;
	
		for (var nInd = 0; nInd < aChecks.length; nInd++)
		{
			if (aChecks[nInd].checked)
				oCheck = aChecks[nInd];
		}

		if (oCheck)
		{
			var oNeg = getElement('edHlpQBENeg');
			var cValue = "";
			var oValue1 = getElement('edHlpQBEValue1'+oCheck.value);
			var oValue2 = getElement('edHlpQBEValue2'+oCheck.value);
			if (oCheck.value == "1") cValue = "vazio"; // n∆o traduzir
			else if (oCheck.value == "2") cValue = oValue1.value;
			else if (oCheck.value == "3") cValue = oValue1.value;
			else if (oCheck.value == "4") cValue = oValue1.value + "-" + oValue2.value;
			else if (oCheck.value == "5") cValue =  "nao " + oValue1.value;
			else if (oCheck.value == "6") cValue = "< " + oValue1.value;
			else if (oCheck.value == "7") cValue = "-" + oValue1.value;
			else if (oCheck.value == "8") cValue = oValue1.value + "-";
			else if (oCheck.value == "9") cValue = "> " + oValue1.value;
			else if (oCheck.value == "10") cValue = oValue1.value + "..";
			else if (oCheck.value == "11") cValue = ".." + oValue1.value + "..";
			else if (oCheck.value == "12") cValue = ".." + oValue1.value;
			else if (oCheck.value == "13") cValue = oValue1.value + "/../..";
			else if (oCheck.value == "14") cValue = "../" + oValue1.value + "/..";
			else if (oCheck.value == "15") cValue = "../../" + oValue1.value;
			else if (oCheck.value == "16") cValue = oValue1.value + "/" + oValue2.value + "/..";
			else if (oCheck.value == "17") cValue = oValue1.value + "/../" + oValue2.value;
			else if (oCheck.value == "18") cValue = "../" + oValue1.value + "/"+ oValue2.value;

			if (oNeg.checked)
				cValue = "nao " + cValue;
			
			oDiv.targetField.value = cValue;
			hideElement(oDiv);
			hideElement(getElement("divHelpQbeMain"));								
						
			//Muda o foco para imput que foi afetado pelo QBE. 
			oObj.focus();
            if (evt_onAfterApply) {
            	evt_onAfterApply(alAplly);
            } 
		} else
			alert( STR0035 ); //"Selecione uma opá∆o ou acione fechar."
	} else {
		hideElement(oDiv);
		hideElement(getElement("divHelpQbeMain"));
		 
		//Muda o foco para imput que foi afetado pelo QBE. 
		oObj.focus();
		
        if (evt_onAfterApply) {
          	evt_onAfterApply(alAplly);
        } 
	}
}       
                                    
document.onmousemove = mouseMove;
