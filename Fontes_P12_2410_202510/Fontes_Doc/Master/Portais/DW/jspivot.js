var LIMIT_SIZE_OF_DIV = 400;
var LIMIT_RESIZE_OF_DIV = 600;

var oAtt, oInd, oTabAtt, oTabInd, oTabAttH, oTabIndH, oAttHeader, oIndHeader;

var oDoc;
var nLastPickup = 0;

function px2n(acValue)
{
  var re = new RegExp('px','gi');
  return eval(acValue.replace(re,''))
}

function setPivotObj(aoDocument, alCanPivot)
{      
	var oDivs;
	oDoc = aoDocument;	

	oAtt = aoDocument.getElementById('divAtt');
	oInd = aoDocument.getElementById('divInd');
	oTabAtt = aoDocument.getElementById('tabAtt');
	oTabInd = aoDocument.getElementById('tabInd');
	oTabAttH = aoDocument.getElementById('attHeader');
	oTabIndH = aoDocument.getElementById('indHeader');
	oAttHeader = aoDocument.getElementById('divAttHeader');
	oIndHeader = aoDocument.getElementById('divIndHeader');

  if (alCanPivot)	
		prepDragDrop();
}
	
function pivotPickUp(anType, oSender)
{
  var oTab;  
  if (nLastPickup)
  {               
    if (oTabAtt.rows[nLastPickup]) {
      var re = new RegExp(' pickUp','gi');
      oTabAtt.rows[nLastPickup].className = oTabAtt.rows[nLastPickup].className.replace(re,'');
      oTabInd.rows[nLastPickup].className = oTabAtt.rows[nLastPickup].className;
    }
    nLastPickup = 0;
  }

  oSender.className = oSender.className + ' pickUp';
  oTab = (anType == 1)?oTabInd:oTabAtt;
  oTab.rows[oSender.rowIndex].className = oSender.className;
  nLastPickup = oSender.rowIndex;
}

function makeRollover(oTableTR, alRollover) 
{
	var re = new RegExp(' rollOver','gi');
  oTableTR.className = oTableTR.className.replace(re,'');

	if (alRollover)
   oTableTR.className = oTableTR.className + ' rollOver';
}

function pivotRollover(anType, oSender, alRollover)
{                     
	if (oTabAtt)
	{
  	makeRollover(oTabAtt.rows[oSender.rowIndex], alRollover);
  	makeRollover(oTabInd.rows[oSender.rowIndex], alRollover);
 } else
 {                   
 	var oDocument = oSender.ownerDocument;
	oTabAtt = oDocument.getElementById('tabAtt');
	oTabInd = oDocument.getElementById('tabInd');
	pivotRollover(anType, oSender, alRollover);
 }
}

function doResize(anResize, alAbs)
{                
  var nWidth = oAtt.style.pixelWidth;

  if (anResize == 0)
  {          
    oAtt.style.width = LIMIT_SIZE_OF_DIV+'px';
  } else if ((nWidth > 99) && (nWidth < LIMIT_SIZE_OF_DIV)) 
  {
    nWidth = alAbs?anResize:nWidth + anResize;
    oAtt.style.width = nWidth;
  }

  //oInd.style.width = (oAtt.parentElement.offsetWidth - oAtt.style.pixelWidth) + 'px';

  if (anResize == 0)
  {              
    if ((oAtt.scrollWidth <= oAtt.style.pixelWidth))// && (oInd.scrollWidth > oInd.style.pixelWidth))
    { 
      while (oAtt.scrollWidth <= oAtt.style.pixelWidth)
    	{                                               
	  	oAtt.style.pixelWidth -= 1;
	    	oInd.style.pixelWidth += 1;
		  if (oInd.scrollWidth == oInd.style.pixelWidth)
		    	break;
  	}
    	oAtt.style.pixelWidth += 1;
	  oInd.style.pixelWidth -= 1;
    } else if ((oAtt.scrollWidth > oAtt.style.pixelWidth) && (oInd.scrollWidth < oInd.style.pixelWidth))
    {                              
  	while (oInd.scrollWidth < oInd.style.pixelWidth)
    	{                                               
  		oAtt.style.pixelWidth += 1;
    		oInd.style.pixelWidth -= 1;
	  	if (oAtt.scrollWidth == oAtt.style.pixelWidth)
	   	 	break;
  	}   
    }
  }
  
  oAttHeader.style.width = oAtt.style.width;
  oIndHeader.style.width = oInd.style.width;
  
//  posResizeCols();
}

function doResizePanSimples()
{                           
alert('doResizePanSimples');
	var oBrowsePivot = document.getElementById('browsePivot');

	oAtt.style.width = px2n(oTabAtt.currentStyle.width)+1 ;
	oInd.style.width = px2n(oTabInd.currentStyle.width)+2 ;
	
	oTabAttH.style.width = oTabAtt.style.width;
	oTabIndH.style.width = oTabInd.style.width;

	oAttHeader.style.width = oAtt.style.width;
	oIndHeader.style.width = oInd.style.width;
	
	oBrowsePivot.style.width = px2n(oAttHeader.style.width) +  px2n(oIndHeader.style.width);
	oBrowsePivot.cells[0].style.width = px2n(oAttHeader.style.width);
	oBrowsePivot.cells[1].style.width = px2n(oIndHeader.style.width);
	
	posResizeCols();
}

function verifyScrollTables(oSender, alAtt)
{
  if (alAtt)
  	oAttHeader.scrollLeft = oSender.scrollLeft;
  else   
  {
  	oIndHeader.scrollLeft = oSender.scrollLeft;
  	oAtt.scrollTop = oSender.scrollTop;
  }
}

function canResize()       
{                 
  var lHidden = false;
                               
  if (oAttHeader.scrollWidth == oAttHeader.style.pixelWidth)
    lHidden = true;
  else while (oAttHeader.scrollWidth < oAttHeader.style.pixelWidth)
  {
    lHidden = true;
  }

  if (lHidden) { oResize.className = oResize.className + ' hidden'; }
}

var nTimeResizeCol;

function doResizeColContinue(alOnOff, anType, anCol, anDir, anWidth)
{        
  if ((alOnOff) && !(nTimeResizeCol))
    nTimeResizeCol = setInterval("doResizeCol("+anType+","+anCol+","+anDir+")", 500);
  else if (nTimeResizeCol)
  {
    clearInterval(nTimeResizeCol);
    nTimeResizeCol = 0;
  }
}

function doResizeCol(anType, anCol, anDir, anWidth)
{   
  var oTab = (anType==1)?oTabAtt:oTabInd;
  var oHeader = (anType==1)?oTabAttH:oTabIndH;
  var oCell = oTab.rows[0].cells[anCol];
  var oHeaderCell = oHeader.rows[0].cells[anCol];
  var nWidth = px2n(oCell.currentStyle.width);
  var nTabWidth = px2n(oTab.currentStyle.width) - nWidth;
  var nHeaderWidth = px2n(oHeader.currentStyle.width) - nWidth;

  if (!(anWidth))
  	anWidth = anDir;
  	
  if (anDir == 0)
     nWidth = anWidth; //reset
  else if ((anWidth > 30) && (anWidth < LIMIT_RESIZE_OF_DIV)) // valor absoluto
     nWidth = anWidth;              

  oCell.style.width = (nWidth + anWidth) + 'px';
  oHeaderCell.style.width = oCell.style.width;

  oTab.style.width = (nTabWidth + px2n(oCell.style.width)) + 'px';
  oHeader.style.width = oTab.style.width;

  if ((nTimeResizeCol) && (Math.abs(anWidth) == 5))
  {
    clearInterval(nTimeResizeCol);
    nTimeResizeCol = 0;
  }
}

function posResizeCol(aoTab, acColResizeName, anCol, anBase)
{
  var oResize = document.getElementById(acColResizeName);
  var oCell = aoTab.rows[0].cells[anCol];
  if (oResize)
  {
    oResize.style.left = anBase + oCell.offsetWidth-2;
    return  px2n(oResize.style.left);
  } else
    return  0;
}

function setClass(aoTab, anColIndex, acClass)
{
	for (var nInd = 0; nInd < aoTab.rows.length; nInd++)
		aoTab.rows[nInd].cells[anColIndex].className = aoTab.rows[nInd].cells[anColIndex].className + ' ' + acClass;
}

function resetClass(aoTab, anColIndex, acClass)
{
  var re = new RegExp(acClass, 'gi');
  for (var nInd = 0; nInd < aoTab.rows.length; nInd++)
    aoTab.rows[nInd].cells[anColIndex].className = aoTab.rows[nInd].cells[anColIndex].className.replace(re);
}

function doHideAtt(oSender, anType)
{       
    var oCells = oTabAttH.getElementsByTagName('td');
    var aAxisX = new Array();
    var aAxisY = new Array();
    
    for (var nInd = 0; nInd < oCells.length; nInd++)
        {        
        //Os atributos do eixo X sÒo passados para o eixo Y e entÒo ocultados.     
        if ((getParentElement(oCells[nInd]).axis == 'X') && (oCells[nInd].id != oSender.id )) 
            {                
                aAxisX.push(oCells[nInd].id); 
            } 
            else
            {
                aAxisY.push(oCells[nInd].id);
            }
        }
            
    var cURL = prepParam(window.location.href, 'hideAtt', oSender.id)
    cURL = prepParam(cURL, 'axisX', aAxisX.join(';'));
    cURL = prepParam(cURL, 'axisY', aAxisY.join(';'));
    cURL = prepParam(cURL, 'acao', '');
    cURL = prepParam(cURL, 'dd', '');
    window.location.href = cURL;    
}

function doSelection(oSender, anID)
{                                            
  var re = new RegExp('#&','gi');	
  var cURL = window.location.href;

  cURL = cURL.replace(window.location.search,'');
  
  cURL = prepParam(cURL, 'id', anID);
  cURL = prepParam(cURL, 'action', 'queryData'); 
  cURL = prepParam(cURL, 'objType', 'Q');
  cURL = prepParam(cURL, 'colName', oSender.id);
  cURL = prepParam(cURL, 'targetField', 'sel' + oSender.id);
  cURL = prepParam(cURL, 'dd', '');
  cURL = prepParam(cURL, 'hideatt', '');

  cURL = prepParam(cURL, 'type', '1');
  cURL = prepParam(cURL, 'oper', '10');

  cURL = cURL.replace(re,'&');

  doLoad(cURL, "_window", null, null, 0.75, 0.75);
}

function removeRows(oTabAtt, oTabInd, nRowIndex, alDel)
{
  var nIndex;
  var oRow = oTabAtt.rows[nRowIndex+1];

  while (oRow.parentRow == nRowIndex)
  {
    removeRows(oTabAtt, oTabInd, oRow.rowIndex, true);
    oRow = oTabAtt.rows[nRowIndex+1];
  }                                                 
  if (alDel)
  {
	  oTabAtt.deleteRow(nRowIndex);
	  oTabInd.deleteRow(nRowIndex);
  }
}

function showHideDDRows(oParentRow, acDisplay)
{ 
	var cParentID = oParentRow.id;
	for (var nRow = oParentRow.rowIndex+1; nRow < oTabAtt.rows.length; )
	{
		if (oTabAtt.rows[nRow].parentRow == cParentID)
		{                        
			if (oTabAtt.rows[nRow+1].parentRow == oTabAtt.rows[nRow].id)
				showHideDDRows(oTabAtt.rows[nRow], acDisplay)
			//oTabAtt.rows[nRow].style.display = acDisplay; BOPS 
			//oTabInd.rows[nRow].style.display = acDisplay;
			oTabAtt.deleteRow(nRow);
			oTabInd.deleteRow(nRow);
		} else {
		  nRow++;
		}  
	}
}

function doDrill(oSender, pnLevel, pcDdKey)
{     
	if (oSender.src.indexOf('up.gif') == -1) {
		oSender.src = oSender.src.replace('down.gif', 'wait.gif');
		var oTR = getParentElement(getParentElement(oSender));
		var oTRNext = getParentElement(oTR).rows[oTR.rowIndex+1];
		
		var cURL = location.href.replace('#','');
		cURL = prepParam(cURL, 'dl', pnLevel);
		cURL = prepParam(cURL, 'acao', 'PI');
		cURL = prepParam(cURL, 'rowBase', oTR.rowIndex);
		cURL = prepParam(cURL, 'idBase', oTR.id);
		
		if ((oTRNext) && (oTRNext.parentRow) && (oTRNext.parentRow == oTR.id)) {
			cURL = prepParam(cURL, 'dr', pcDdKey); // DR - Drill Redefined
			requestPivotData(cURL); // painel duplo
			
			showHideDDRows(oTR, '');
			for (var nCol = 0; nCol < oTR .cells.length; nCol++) {
				oTR.cells[nCol].innerHTML = oTR.cells[nCol].innerHTML.replace('wait.gif', 'up.gif');
			}
		} else {
			cURL = prepParam(cURL, 'dd', pcDdKey);
			requestPivotData(cURL); // painel duplo
		}
	} else {
		oSender.src = oSender.src.replace('up.gif', 'wait.gif');
		var oTR = getParentElement(getParentElement(oSender));
		showHideDDRows(oTR, 'none');
		
		var cURL = prepParam(location.href.replace('#',''), 'du', pcDdKey);
		cURL = prepParam(cURL, 'dl', pnLevel);
		cURL = prepParam(cURL, 'acao', 'PI');
		cURL = prepParam(cURL, 'rowBase', oTR.rowIndex);
		cURL = prepParam(cURL, 'idBase', oTR.id);
		requestPivotData(cURL); // painel duplo
		
		for (var nCol = 0; nCol < oTR .cells.length; nCol++) {
			oTR.cells[nCol].innerHTML = oTR.cells[nCol].innerHTML.replace('wait.gif', 'down.gif');
		}
	}
}

function doDrillAll(oSender, pnLevel)
{     
	if (oSender.src.indexOf('up.gif') == -1)
	{
		oSender.src = oSender.src.replace('down.gif', 'wait.gif');
		var cURL = prepParam(location.href.replace('#',''), 'dd', '*all*');
		cURL = prepParam(cURL, 'dl', pnLevel);
		cURL = prepParam(cURL, 'acao', '');
		cURL = prepParam(cURL, 'hideatt', '');
	} else
	{
		oSender.src = oSender.src.replace('up.gif', 'wait.gif');
		var cURL = prepParam(location.href.replace('#',''), 'dd', '*all*');
		cURL = prepParam(cURL, 'dl', pnLevel - 1);
		cURL = prepParam(cURL, 'acao', '');
	}
  location.href = cURL;
}

function doChangeIcone(aoTabAttH, anCol,acImage)
{                      
  var aImages = aoTabAttH.getElementsByTagName('img');
	for (var nInd = 0; nInd < aImages.length; nInd++)
	{
 	  if (aImages[nInd].id == ('imgDD' + anCol))
 	  {
			aImages[nInd].src = acImage;           
		}
	}	
}

function doDrillEnd(aoRowBase, aoRowNext, anDrillLevel, anColWidth, aoTabHeader, aoTabData, anDescto)
{
	var oTR = aoRowBase;
	var oTRNext = aoRowNext;
  var nLastDrill;

	for (var nCol = 0; nCol < anDrillLevel; nCol++)
	{
    if ((oTR.cells[nCol]) && (oTR.cells[nCol].innerHTML.indexOf('wait.gif') > 0))
      nLastDrill = nCol+1;
	}

	for (var nCol = 0; nCol < nLastDrill; nCol++)
	{
      oTR.cells[nCol].innerHTML = oTR.cells[nCol].innerHTML.replace('wait.gif', 'up.gif');
		  oTRNext.cells[nCol].innerHTML = '&nbsp;'
	}
	
	if (anDescto > 0)
	{
		var nCol = anDrillLevel;
		hideElement(oTR.cells[nCol]);
		
		if (!aoTabHeader.colsAdjust)
			aoTabHeader.colsAdjust = new Array();
		
		if (!aoTabHeader.colsAdjust[nCol])
		{                                
			aoTabHeader.colsAdjust[nCol] = true;
			for (var nInd = 0; nInd < aoTabData.rows.length; nInd++)
			{
				aoTabData.rows[nInd].cells[nCol].width = anColWidth;
				hideElement(aoTabData.rows[nInd].cells[nCol]);
			}                                                                                   
			for (var nInd = 0; nInd < aoTabHeader.rows.length; nInd++)
			{                                    
				if (aoTabHeader.rows[nInd].cells[nCol])
				{
					aoTabHeader.rows[nInd].cells[nCol].width = anColWidth;
					hideElement(aoTabHeader.rows[nInd].cells[nCol]);
				}  
			}
		}
	}
}

function showResizeTool(oSender, cPanel)
{              
return;
	var oImg = document.getElementById('img'+cPanel+'ColResize.'+(oSender.cellIndex));

	oImg.style.top = oSender.offsetTop; // - ( oImg.style.pixelHeight / 2);
	oImg.style.left = oSender.offsetLeft + ((oSender.style.pixelWidth - oImg.style.pixelWidth) / 2);
	oImg.style.display = 'inline'; 
}

function hideResizeTool(oSender, cPanel)
{                                
return;
	var oImg = document.getElementById('img'+cPanel+'ColResize.'+(oSender.cellIndex));
	oImg.style.display = 'none';
  
 	if (nTimeResizeCol)             
 	{
   	clearInterval(nTimeResizeCol);
   	nTimeResizeCol = 0;
  }
}

function doAdjustHeight(oTabAtt, oTabInd)
{
	var nAjusteAlt = 0;
	var nLimite = getParentElement(getParentElement(getParentElement(oTabAtt))).style.pixelHeight;
	var rCell = getClientRect(oTabAtt.rows[0].cells[0]);
	var nHeightCell = rCell.bottom - rCell.top;
              
	for (var nRow = 0; nRow < oTabAtt.rows.length - 1; nRow++)
	{
		if (isElementVisible(oTabAtt.rows[nRow]))
			nAjusteAlt = nAjusteAlt + nHeightCell+2;
	}

	if (nAjusteAlt > nLimite)
	{
		getParentElement(oTabAtt).style.pixelHeight = nAjusteAlt;
		getParentElement(oTabInd).style.pixelHeight = nAjusteAlt;
	}
}

var srcElementId;  //Id of dragged object
var destElementId; //Id of valid drop target object   
var curElementId; //Id of current object (enter)

var draggingCell = false;
var sourceCell = null;
var original = null;

function getTargetCell(oSrcElement)
{
	while (oSrcElement.parentNode != null && oSrcElement.tagName && oSrcElement.tagName != 'TD')
		oSrcElement = oSrcElement.parentNode;
	return oSrcElement;
}

function startedDragging()
{
	draggingCell = true;
  sourceCell = event.srcElement;
  
  while (!(sourceCell.tagName == "TD"))
  	sourceCell = getParentElement(sourceCell);
}

function dragEnter()
{
  if (draggingCell)
  {
		var targetCell = getTargetCell(event.srcElement);
		window.event.returnValue = false;
	}
}

function dragOver()
{
	if (draggingCell)
	{
		var targetCell = getTargetCell(event.srcElement);
		targetCell.className = targetCell.className + ' dragOver';
		window.event.returnValue = false;
	}
}

function dragLeave()
{
	if (draggingCell)
	{
  	var re = /dragover/gi;
		var targetCell = getTargetCell(event.srcElement);
		targetCell.className = targetCell.className.replace(re, "");
	}
}

function dropped()
{
	if (draggingCell)
	{
		draggingCell = false;
		var targetCell = getTargetCell(event.srcElement);
  	var re = /dragover/gi;
		var targetCell = getTargetCell(event.srcElement);
		targetCell.className = targetCell.className.replace(re, "");
		// faz o drop - >sourceCell.swapNode(targetRow);
  	var oTR = getParentElement(targetCell);
    if (oTR.axis == 'X')
		{
	  	var oNewTR = oDoc.createElement('TR');
		 	oNewTR.mergeAttributes(oTR);
			oNewTR.appendChild(sourceCell.removeNode(true));
			oTR.insertAdjacentElement('afterEnd', oNewTR);
    } else
    {
			targetCell.insertAdjacentElement('afterEnd', sourceCell.removeNode(true));
    }
	  var oCells = oTabAttH.getElementsByTagName('td');
    var newArrange = new Array();
 	  var aAxisX = new Array();
 	  var aAxisY = new Array();
	
		for (var nInd = 0; nInd < oCells.length; nInd++)
		{
	  	if (getParentElement(oCells[nInd]).axis == 'X')
	  	{
	  		newArrange.push('X'+oCells[nInd].id);
	  		aAxisX.push(oCells[nInd].id);
	  	} else
	  	{
	  		newArrange.push('Y'+oCells[nInd].id);
	  		aAxisY.push(oCells[nInd].id);
	  	}
    }
    
  	if (!(newArrange.join(';') == original.join(';')))
  	{
  		var cURL = oDoc.location.href;
  		cURL = prepParam(cURL, 'axisX', aAxisX.join(';'));
  		cURL = prepParam(cURL, 'axisY', aAxisY.join(';'));
  		oDoc.location.href = cURL;
		}
	}
}

function prepDragDrop()
{
	var oCells = oTabAttH.getElementsByTagName('td');
  var oImgs = oTabAttH.getElementsByTagName('img');

  original = new Array();
	oTabAttH.ondrop = dropped;
	
	for (var nInd = 0; nInd < oCells.length; nInd++)
	{   
	  var oDrag = oCells[nInd];
	  oDrag.ondragenter = dragEnter;
	  oDrag.ondragover = dragOver;
	  oDrag.ondragleave = dragLeave;
	  original.push(getParentElement(oDrag).axis + oDrag.id);
	}

	for (var nInd = 0; nInd < oImgs.length; nInd++)
	{   
		var oImg = oImgs[nInd];             
	  if (!(oImg.src.indexOf('ic_dimensao') == -1))
	  {
			oImg.style.cursor = 'move';
		  oImg.ondragstart = startedDragging;
	  }
  }
}