function initTable(acTabID, alHL, alMenu)
{
	var oTab = getElement(acTabID);

	if (alHL)
	{
	  var aCells = oTab.getElementsByTagName('td');
	  for (var i=0; i < aCells.length;i++)
	  {
  		aCells[i].onmouseover = alMenu?doMenuRowOn:doHLRowOn;
  		aCells[i].onmouseout = alMenu?doMenuRowOff:doHLRowOff;
	  }
	  var aLinks = oTab.getElementsByTagName('a');
	  for (var i=0; i < aLinks.length;i++)
	  {
	  	aLinks[i].onmouseover = alMenu?doMenuRowOn:doHLRowOn;
	  	aLinks[i].onmouseout = alMenu?doMenuRowOff:doHLRowOff;
	  }
	}
}

function getTR(oSender)
{                 
  var oElement = oSender; 
	while (oElement)
	{
		if (oElement.tagName == 'TR')
			return oElement;
		oElement = getParentElement(oElement);
	}         
}

function doHLRowOn(aoEvent)
{                         
	var oEvent = window.event ? window.event : aoEvent;   
	var oSender = window.event ? oEvent.srcElement : oEvent.target;

	var oTR = getTR(oSender);
  oTR.className += ' over';
}

function doHLRowOff(aoEvent)
{
	var oEvent = window.event ? window.event : aoEvent;   
	var oSender = window.event ? oEvent.srcElement : oEvent.target;

	var oTR = getTR(oSender);
 	var re = /over/gi;
  oTR.className = oTR.className.replace(re, "");
}

function doMenuRowOn(aoEvent)
{                            
	var oEvent = window.event ? window.event : aoEvent;   
	var oSender = window.event ? oEvent.srcElement : oEvent.target;
	var oTR = getTR(oSender);
  oTR.className += ' over';
	oTR.cells[0].className += ' over';
}

function doMenuRowOff(aoEvent)
{                            
	var oEvent = window.event ? window.event : aoEvent;   
	var oSender = window.event ? oEvent.srcElement : oEvent.target;
	var oTR = getTR(oSender);
 	var re = /over/gi;
  oTR.className = oTR.className.replace(re, "");
	oTR.cells[0].className = oTR.cells[0].className.replace(re, "");
}