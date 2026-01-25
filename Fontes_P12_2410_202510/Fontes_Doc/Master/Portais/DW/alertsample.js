var cIDMsgAtiva;

function alertSample_close(acID)
{
  var oDivMsg = document.getElementById(acID);
  var oRow = getParentElement(oDivMsg);
  while ((oRow) && (!(oRow.tagName == "TR")))
  	oRow = getParentElement(oRow);
  if (oRow)
	 	oRow.style.display = 'none';
	 else
	  oDivMsg.style.visibility = 'hidden';
  cIDMsgAtiva = 0;
}

function alertSample_open(acID, acMsgSource)
{ 
  if (cIDMsgAtiva)
  {
    alertSample_close(cIDMsgAtiva);
    cIDMsgAtiva = 0;
  }               

  var oDivMsg = document.getElementById(acID);
  var oDivMsgText = document.getElementById(acID+'MsgText');
	var oMsgSrc = document.getElementById(acMsgSource);

  if (oMsgSrc)
		oDivMsgText.innerHTML = oMsgSrc.value;

  var oRow = getParentElement(oDivMsg);
  while ((oRow) && (!(oRow.tagName == "TR")))
  	oRow = getParentElement(oRow);
	if (oRow)
	 	oRow.style.display = '';
	else
	  oDivMsg.style.visibility = 'visible';
  cIDMsgAtiva = acID;
}