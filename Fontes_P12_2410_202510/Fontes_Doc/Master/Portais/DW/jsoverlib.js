function libBwCheck()  //Browsercheck (needed)
{ 
	this.ie4 = false;
	this.ie5 = false;
	this.ie6 = false;
	this.ie7 = false;
	this.ie8 = false;
	this.ns6 = false;
	this.ns4 = false;
	this.ns = false;
	this.mac = false;
	this.opera = false;
	this.ff2 = false;
	this.ff3 = false;

	this.ie = false;
	this.ns = false;
	this.ff = false;

	this.ver = navigator.appVersion; 
	this.agent = navigator.userAgent; 
	this.dom = document.all?true:false; //document.getElementById?1:0;

	if (this.dom)
	{             
		this.ie6 = (this.ver.indexOf("MSIE 6")>-1)?true:false 
		this.ie7 = (this.ver.indexOf("MSIE 7")>-1)?true:false 
		this.ie8 = (this.ver.indexOf("MSIE 8")>-1)?true:false 
	}

//	this.opera = this.agent.indexOf("Opera")>-1 
	this.ff2 = this.agent.indexOf("Firefox/2")>-1?true:false 
	this.ff3 = this.agent.indexOf("Firefox/3")>-1?true:false 

	// coloque aqui, apenas browser homologados
	this.ie = this.ie6 || this.ie7; 
	this.ff = this.ff2 || this.ff3;
	/////

	this.bw=(this.ie || this.ff) 
  
	return this 
}

// Decide browser version
var oBw = new libBwCheck();

function browserHomologado()
{        
  return oBw.bw;
}

var oJVMTest;

function jvmVendor()
{    
  var cRet = "(nd)";

  if (oJVMTest)
    cRet = oJVMTest.Vendor;
    
  return cRet;
}

function jvmVersion()
{    
  var cRet = "(nd)";

  if (oJVMTest)
    cRet = oJVMTest.Version;
    
  return cRet;
}
  
function jvmHomologado()
{              
  // Testa se a JVM esta ativa e a versão, retornando um dos códigos abaixo
  //  0 - esta ok
  //  -1 - não habilitado
  //  -2 - erro na carga do JAR
  //  -3 - não homologado
  
  var nRet = -1; // não habilitado
  if (navigator.javaEnabled())
  {
   	document.writeln("<applet code='br.com.microsiga.sigadw.applet.DWJavaVersion.class'");
    document.writeln("  archive='SigaDw3Test.jar' name='jvmTest' id='jvmTest' style='width: 1px; height: 1px;'>");
    document.writeln("</applet>");
	  if (oBw.ie)
      oJVMTest = getApplet('jvmTest');
	  else 
		  oJVMTest = getObject('jvmTest');
    if (oJVMTest)
    {  
	    if (oBw.ie)
	      nRet = 0;
      else
      {
      	var cVendor = oJVMTest.Vendor.toString();
      	var cVersion = oJVMTest.Version.toString();
				if ((cVendor.substr(0,3) == 'Sun') && ((cVersion == '1.5.0_10') || cVersion.substr(0,3) == '1.6'))
        	nRet = 0; // ok
      	else
        	nRet = -3; // Vendor ou version não homologado
    	}
    } else
    {
      nRet = -2; // erro na carga
    }
  }
  
  return nRet;
}

function getElementsByName(cObjName, oSource)
{
  if (!(oSource)) { oSource = document };

	return oSource.all[cObjName];
}

function getElementsByTag(cTagName, oSource)
{
  var oRet;                       
  
  if (!(oSource)) { oSource = document };
  oRet = oSource.getElementsByTagName(cTagName.toUpperCase());

  return oRet
}

function getElement(cObjName, oSource, dbgIdentifier)
{                  
  return getObject(cObjName, oSource, dbgIdentifier)
}

function getObject(cObjName, oSource, dbgIdentifier)
{
	var oRet;                                                    
	var c = '';
	
	if (!oSource) {
		oSource = document;
	}
	
	if (oBw.ie) {
		oRet = oSource.all[cObjName];
	} else { 
		if ((!oRet) && (oSource.elements)) {
			oRet = oSource.elements[cObjName];
		} else if ((!oRet) && (oSource.getElementById)) {
			oRet = oSource.getElementById(cObjName);
		}
		if ((!oRet) && (oSource.forms)) {
			oRet = new Array();
			for (oForm in oSource.forms) {
				if ((oForm.name) && (oForm.name == cObjName)) {
					oRet.push(oElement);
					exit;
				}
				
				for (oElement in oForm) {
					if ((oElement.name) && (oElement.name == cObjName)) {
						oRet.push(oElement);
					}
				}
			}
			
			if (oRet.length == 0)
				oRet = null;
			else if (oRet.length == 1)
				oRet = oRet[0];
		}
	}

	return oRet
}

function getApplet(cObjName)
{
	var oElem;

	if (oBw.ie) {
		oElem = getObject(cObjName);
	} else {
		oElem = document.embeds[cObjName];
	}
	
	return oElem;
}

function getParentElement(oObject)
{
	var oRet;
	
	if (oBw.ie)
	{
	  if (oObject)
			oRet = oObject.parentElement;
	} else
    oRet = oObject.parentNode;

	return oRet;
}

function openModalWindow(acURL, acWindowName, acWindowFeatures)
{
  var oWin;

  if (oBw.ie)
    oWin = window.showModalDialog(acURL, acWindowName, "resizable=yes, status=yes, help=no, scrollbar=yes, " + acWindowFeatures);
  else
    oWin = window.open(acURL, acWindowName, "modal, resizable=yes, status=yes, help=no, scrollbar=yes, " + acWindowFeatures);
  
  return oWin;
}

function getClientRect(oSender)
{ 
	var oRet;
	
	if (oBw.ie)
		oRet = oSender.getClientRects()[0];
	else
		oRet = { bottom: oSender.offsetHeight, left: oSender.offsetLeft, right: oSender.offsetWidth, top: oSender.offsetTop };

  return oRet;
}

function showElement(oElement, alInLine)
{
  oElement.style.display = alInLine?"inline":"block"
}

function isElementVisible(oElement)
{                        
  return !(oElement.style.display == "none");
}

function hideElement(oElement)
{               
  oElement.style.display = "none";
}

function getAllElements(oSource)
{             
  if (!(oSource)) { oSource = document };
  return (oBw.ie)?oSource.all:oSource.getElementsByTagName('*');
}

function prepURL(acURL)
{                                          
  var re = /&amp;/gi
  return acURL.replace(re, "&")
}

function doLoadHere(acURL, aoLocation)
{ 
  aoLocation = aoLocation ? aoLocation : window.location;
	aoLocation.href = prepURL(acURL);
}

function getParentWin(aoSource)
{                  
	aoSource = aoSource ? aoSource : document;
	var oAux = oBw.ff ? document.defaultView : aoSource.parentWindow

	return oAux
}

function getParentDoc(aoSource)
{                  
	aoSource = aoSource ? aoSource : document;
	var oAux = getParentWin(aoSource)

	return oAux.parent.document;
}

function getMousePosition(event)
{
  if (this.ff)
    var pos = { x: event.pageX, y: event.pageY };
  else
    var pos = { x: event.x, y: event.y };
                                                 
  return pos
}