// #####################################################################################
// Classe: PalleteColor
// #####################################################################################

var PALLETE_COLOR_DIV_NAME = 'divPalleteColor';
var SIMPLE_PALLETE_COLOR_DIV_NAME = 'divSimplePalleteColor';

function PalleteColor(alSimple)
{
  // initialize internal properties.
  this.cValue = ''
	this.simple = alSimple;
  this.name = this.simple?SIMPLE_PALLETE_COLOR_DIV_NAME:PALLETE_COLOR_DIV_NAME;
	this.bRed = -1;
	this.bGreen = -1;
	this.bBlue = -1;
	this.STEP = 5;
	this.SIZE = 3;
   
  window[this.name] = this;
  
  var oDiv = document.createElement("DIV");
	document.body.appendChild(oDiv);
	oDiv.id=this.name;
	oDiv.className = "calendar chooseColor";
	oDiv.innerHTML = this.renderPalleteColor().join('');
}

PalleteColor.prototype.setValue = function(cValue)
{                          
	if (!(cValue.substr(0,1) == "#"))
		cValue = "#" + cValue;
		
  if (!((this.cValue+'') == (cValue+'')))
  {       
    this.cValue = cValue;
    this.oTarget.value = this.cValue;
    this.oTarget.style.backgroundColor = this.cValue;
    if (this.cValue == "__")
    	document.getElementById('dot'+this.oTarget.id).style.backgroundColor = "";
    else	
    	document.getElementById('dot'+this.oTarget.id).style.backgroundColor = this.cValue;
    this.hide();
  } 
}

PalleteColor.prototype.getValue = function()
{
  return this.cValue;
}

PalleteColor.prototype.makeAction = function (acOper, acText, acWhere)
{                                                           
  var cCode = " onMouseOver=\"window.status='"+acText+"'; return true;\" " +
			  "onMouseOut=\"window.status=' '; return true;\" ";   

  if (acOper == "c")
    cCode += "onClick=\"window['"+this.name+"'].clearValue();\">" + acText;
  else if (acOper == "x")
    cCode += "onClick=\"window['"+this.name+"'].hide();\">" + acText;
	else if (acOper == "r")
		cCode += "onClick=\"window['"+this.name+"'].selectColorCode("+acText+",-1,-1);\">";
	else if (acOper == "g")
		cCode += "onClick=\"window['"+this.name+"'].selectColorCode(-1,"+acText+",-1);\">";
	else if (acOper == "b")
		cCode += "onClick=\"window['"+this.name+"'].selectColorCode(-1,-1,"+acText+");\">";
	else if (acOper == "s")
		cCode += "onClick=\"window['"+this.name+"'].setValue(this.style.backgroundColor);\">";
  else
		cCode += "onClick=\"window['"+this.name+"'].setValue('"+acText+"');\">";
  
  return cCode;
}

PalleteColor.prototype.hex = function (anNumber)
{
	var cRet = '00' + anNumber.toString(16);
	cRet = cRet.substr(cRet.length-2,2);   
	return cRet;
}

PalleteColor.prototype.rgb = function (abRed, abGreen, abBlue)
{
	return '#' + this.hex(abRed) + this.hex(abGreen) + this.hex(abBlue);
}

PalleteColor.prototype.selectColorCode = function (abRed, abGreen, abBlue)
{            
	if (!(this.rgb(this.bRed, this.bGreen, this.bBlue) == this.rgb(abRed, abGreen, abBlue)))
	{	                          
		var nAux = this.oPickBlue.getClientRects()[0].bottom;
		if (!(abRed == -1))                                
		{                       
			nAux = nAux * abRed / 255	
  		adjustPosComponent(this.oLvlRed, this.oPickBlue, -5);
  		this.oLvlRed.style.top = nAux;
  	}
		if (!(abGreen == -1))
		{                       
			nAux = nAux * abGreen / 255	
  		adjustPosComponent(this.oLvlGreen, this.oPickBlue, 2);
  		this.oLvlGreen.style.top = nAux;
  	}
		if (!(abBlue == -1))
		{                       
			nAux = nAux * abBlue / 255	
  		adjustPosComponent(this.oLvlBlue, this.oPickBlue, 8);
  		this.oLvlBlue.style.top = nAux;
  	}
		this.bRed = abRed;
		this.bGreen = abGreen;
		this.bBlue = abBlue;

		this.makePickColor();
	}
}

PalleteColor.prototype.showColorCode = function ()
{                                                                    
	var oSrcElement = window.event?window.event.srcElement:event.target;
	if (oSrcElement)
		window.status = 'Color='+oSrcElement.style.backgroundColor;
}

PalleteColor.prototype.makePickColor = function ()
{                    
	var nIndex = 0;
	var aCells = this.aPickColor;
	
  for (var nRed = 0; nRed < 256;)
  {
    for (var nGreen = 0; nGreen < 256;)
    {                      
    	for (var nBlue = 0; nBlue < 256;)
    	{                
    		var nRedCode, nGreenCode, nBlueCode;
    		nRedCode = (this.bRed == -1)?nRed:this.bRed;
    		nGreenCode = (this.bGreen == -1)?nGreen:this.bGreen;
    		nBlueCode = (this.bBlue == -1)?nBlue:this.bBlue;
    		try
    		{
 					aCells[nIndex].style.backgroundColor = this.rgb(nRedCode, nGreenCode, nBlueCode);
   				aCells[nIndex].onmouseover = this.showColorCode;
  	  	} catch (err) { return }
    		nBlue += this.STEP;
      	nIndex++;
    	}
    	nGreen += this.STEP;
    }
    nRed += this.STEP;
  }
}

PalleteColor.prototype.doAtzValue = function (oSender)
{
	window.status = oSender.style.backgroundColor;
}

PalleteColor.prototype.renderPalleteColor = function()
{
  var aBuffer = new Array();
  var cObjName = this.name;
	var oThis = this;

	function pickColor()
	{
		aBuffer.push("<table summary='' id='"+cObjName+"pickColor' style='width: 100%;' border='1' cellpadding='0' cellspacing='0'>");
		aBuffer.push("	<tbody>");
  	for (var nRow = 0; nRow < 52; nRow++)
  	{
			aBuffer.push("	<tr>");
    	for (var nCol = 0; nCol < 52; nCol++)
				aBuffer.push("	<td style='border:none; width:5px;height:5px;' "+oThis.makeAction('s')+"</td>");
			
			aBuffer.push("	</tr>");
		}
		aBuffer.push("	</tbody>");
		aBuffer.push("</table>");
	}	

	function pickColorBlue()
	{
		aBuffer.push("<table summary='' id='"+cObjName+"pickColorBlue' style='width:100%;' border='0' cellpadding='0' cellspacing='0'>");
		aBuffer.push("<tbody>");
    var nRed = 0;
    var nGreen = 0;
    var nBlue = 0;
  	for (var nRow = 0; nRow < 52; nRow++)
  	{                        
  	  var cColor;
			aBuffer.push("	<tr>");
			cColor = oThis.rgb(nRed, 0, 0);
			aBuffer.push("		<td style='border:none;height:5px;width:33%;background-color:" + cColor + "'" + oThis.makeAction('r', 'Color='+nRed) + "</td>");
			cColor = oThis.rgb(0, nGreen, 0);
			aBuffer.push("		<td style='border:none;height:5px;width:33%;background-color:" + cColor + "'" + oThis.makeAction('g', 'Color='+nGreen)+"</td>");
			cColor = oThis.rgb(0, 0, nBlue);
			aBuffer.push("		<td style='border:none;height:5px;width:33%;background-color:" + cColor + "'" + oThis.makeAction('b', 'Color='+nBlue)+"</td>");
			nRed += 5;
			nGreen += 5;
			nBlue += 5;
			aBuffer.push("	</tr>");
		}
		aBuffer.push("	</tbody>");
		aBuffer.push("</table>");
	}
  
	function pickColorBase()
	{
		var nSteps = 85;
  	var HEXCodes = new Array(256);
  	var HEX = new Array("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F");
  	var k = 0;
  	for (var i = 0; i < 16; i++)
  	{
			for (var j = 0; j < 16; j++)
			{
				HEXCodes[k] = HEX[i] + HEX[j];
				k++;
			}
  	}

		aBuffer.push("<table summary='' id='"+cObjName+"pickColorBase' border='0' cellpadding='0' cellspacing='0'>");
		aBuffer.push("	<tbody>");
	  k = 0;
		for (var nRow = 255; nRow >= 0; nRow-=nSteps)
		{
			aBuffer.push("	<tr>");
			for (var middle = 255; middle >= 0; middle-=nSteps)
			{
				for (var inner = 255; inner >= 0; inner-=nSteps)
				{                                   
					var cColor = HEXCodes[255 - nRow] + HEXCodes[255 - middle] + HEXCodes[255 - inner];
					aBuffer.push("	<td style='border:none;height:15px;width:15px;background-color:#" + cColor + "' " + oThis.makeAction('', cColor)+"</td>");
					k++;
      	}
    	}
			aBuffer.push("	</tr>");
  	}
		aBuffer.push("	<tr>");
		for (var nRow = 255; nRow >= 0; nRow-=16)
		{
			var cColor = HEXCodes[255 - nRow] + HEXCodes[255 - nRow] + HEXCodes[255 - nRow];
			aBuffer.push("	<td style='border:none;height:15px;width:15px;background-color:#" + cColor + "' " + oThis.makeAction('', cColor)+"</td>");
		}
		aBuffer.push("	</tr>");
		aBuffer.push("		</tbody>");
		aBuffer.push("	</table>");
	}                                      
	
	aBuffer.push("<table summary='' style='width: 300px;' border='0' cellpadding='0' cellspacing='0'>");
	aBuffer.push("<caption><span id='"+this.name+"Caption'></span></caption>");
	aBuffer.push("<tbody>");
	if (!(this.simple))
	{
		aBuffer.push("	<tr>");
		aBuffer.push("		<td style='width: 275px'>");
		pickColor();
		aBuffer.push("		</td>");
		aBuffer.push("		<td style='width: 25px'>");
		pickColorBlue();
		aBuffer.push("		</td>");
		aBuffer.push("	</tr>");
		aBuffer.push("	<tr>");
	}
	aBuffer.push("		<td colspan='2'>");
	pickColorBase();
	aBuffer.push("		</td>");
	aBuffer.push("	</tr>");
  aBuffer.push(" 	</tbody>");
  aBuffer.push("  <tfoot>");
  aBuffer.push("  <tr>");
	aBuffer.push("		<td colspan='2'>");
	aBuffer.push("		  <table width='100%'>");
	aBuffer.push("		    <col width='50%'>");
	aBuffer.push("		    <col width='50%'>");
	aBuffer.push("		    <tr>");
  aBuffer.push("          <td style='text-align:center' "+this.makeAction("x", "Fechar")+"</td>");
  aBuffer.push("          <td style='text-align:center' "+this.makeAction("c", "Limpar")+"</td>");
	aBuffer.push("		    </tr>");
	aBuffer.push("		  </table>");
	aBuffer.push("		</td>");
  aBuffer.push("  </tr>");
  aBuffer.push("  </tfoot>");
  aBuffer.push("</table>");

  aBuffer.push("<img id='"+this.name+"lvlRed' style='width:10px;height:10px;position:absolute;display:none' src='mark_color.gif'>");
  aBuffer.push("<img id='"+this.name+"lvlGreen' style='width:10px;height:10px;position:absolute;display:none' src='mark_color.gif'>");
  aBuffer.push("<img id='"+this.name+"lvlBlue' style='width:10px;height:10px;position:absolute;display:none' src='mark_color.gif'>");
  
  return aBuffer;
}

PalleteColor.prototype.init = function()
{
  if (this.oPalleteColor) return;
  
  this.oPalleteColor = document.getElementById(this.name);
  this.oCaption = document.getElementById(this.name+'Caption');

  // get all <span> elements for complementation
  if (!(this.simple))
  {
		this.aPickColor = document.getElementById(this.name+'pickColor').getElementsByTagName('TD');
		this.oPickBlue = document.getElementById(this.name+'pickColorBlue');
	  this.aPickBlue = this.oPickBlue.getElementsByTagName('TD');
	}
  this.aPickBase = document.getElementById(this.name+'pickColorBase').getElementsByTagName('TD');
	this.oLvlRed = document.getElementById(this.name+"lvlRed");
	this.oLvlGreen = document.getElementById(this.name+"lvlGreen");
	this.oLvlBlue = document.getElementById(this.name+"lvlBlue");
  
  this.makePickColor();
}

PalleteColor.prototype.fill = function()
{
  this.init();
}
 
PalleteColor.prototype.show = function (acInputName, x, y)
{              
  this.init();

  this.oTarget = document.getElementById(acInputName);
  this.oCaption.innerHTML = "Selecione uma cor";

  adjustPosComponent(this.oPalleteColor, this.oTarget, 0, 0)

  this.oPalleteColor.style.display = "block";
}

PalleteColor.prototype.hide = function ()
{              
  this.oTarget = null;
  this.oPalleteColor.style.display = "none";
}

PalleteColor.prototype.clearValue = function ()
{
  this.setValue("__");
  this.hide();
}

// #####################################################################################
// Função para acionamento da paleta de seleção de cores
// #####################################################################################

function showPalleteColor(acInputName, aoEvent)
{                                             
	aoEvent = aoEvent?aoEvent:window.event;
	
  if (!window[PALLETE_COLOR_DIV_NAME])
		new PalleteColor(false);
  window[PALLETE_COLOR_DIV_NAME].show(acInputName, aoEvent.x, aoEvent.y);
}

function showSimplePalleteColor(acInputName, aoEvent)
{ 
	aoEvent = aoEvent?aoEvent:window.event;
  if (!window[SIMPLE_PALLETE_COLOR_DIV_NAME])
		new PalleteColor(true); 
  window[SIMPLE_PALLETE_COLOR_DIV_NAME].show(acInputName, aoEvent.x, aoEvent.y);
}