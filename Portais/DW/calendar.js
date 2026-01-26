// #####################################################################################
// Classe: Calendar
// #####################################################################################

var CALENDAR_DIV_NAME = 'divCalendar';

function Calendar()
{
  // initialize internal properties.
  this.dValue = 0;
  this.xOffset = 0;
  this.yOffset = 0;
  this.name = CALENDAR_DIV_NAME;
  this.range = { min: 0, max: 0, UTCmin: 0, UTCmax:0 };
  this.onSelected = null;
  window[this.name] = this;
  this.resetCaptions();
  this.Months = MONTHS_ABR;
  
  var oDiv = document.createElement("DIV");
	document.body.appendChild(oDiv);
	oDiv.id=this.name;
	oDiv.className = "calendar";
	oDiv.innerHTML = this.renderCalendar().join('');
}

Calendar.prototype.DOMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
Calendar.prototype.Captions = {};

Calendar.prototype.resetCaptions = function(aaCaptions)
{
  this.Captions = {
    emBranco: STR0036,//'Em branco'
    fechar: STR0037,//'Fechar'
    ajustePara: STR0038,//'Ajusta a data para'
    selecioneData: STR0039 ,//'Selecione uma data'
    destaque: ''
  }
  this.updateCaptions(aaCaptions);
}

Calendar.prototype.updateCaptions = function(aaNewCaptions)
{                 
  if (aaNewCaptions)
    for (caption in aaNewCaptions)
      this.Captions[caption] = aaNewCaptions[caption];

  for (caption in this.Captions)            
  {
    if (this['spancaption_'+caption])
      this['spancaption_'+caption].innerHTML = this.Captions[caption];
  }
}

Calendar.prototype.setDate = function(dValue)
{                         
  if (!((this.dValue+'') == (dValue+'')))
  {     
    var nUTC = Date.UTC(dValue.getFullYear(), dValue.getMonth(), dValue.getDate());
    if (nUTC < this.range.UTCmin)
       dValue = this.range.min;
    else if (nUTC > this.range.UTCmax)
       dValue = this.range.max;
       
    this.dValue = new Date(dValue);
    this.fill();
  } 
}

Calendar.prototype.getDate = function()
{
  return new Date(this.dValue);
}

Calendar.prototype.updateDate = function (acCmd, acDay)
{ 
  var dAux = this.getDate();
  if (acCmd == "-y")
    dAux.setFullYear(dAux.getFullYear()-1);
  else if (acCmd == "+y")
    dAux.setFullYear(dAux.getFullYear()+1);
  else if (acCmd == "-m")
    dAux.setMonth(dAux.getMonth()-1);
  else if (acCmd == "+m")
    dAux.setMonth(dAux.getMonth()+1);
  else if (acCmd == "h")
  {
    this.setDate(new Date());
    dAux = new Date();
    this.oTarget.value = this.formatDate(dAux);
  }
  else if (acCmd == "u") // update de uma data específica com o style da data de hoje
  {
    dAux.setDate(acDay);
    this.oTarget.value = this.formatDate(dAux);
    if (acCmd != "u")
    { 
      this.hide();
    }
  }
  else if (acCmd == "d")
  {
    dAux.setDate(acDay);
    this.oTarget.value = this.formatDate(dAux);
    if (this.onSelected)
      this.onSelected(this.oTarget.value, this.ansiDate(dAux))
    this.hide();
  }
  this.setDate(dAux);
}

Calendar.prototype.makeAction = function (acOper, acText, acWhere, acCaptionID)
{                                                           
  var cCode = "<a href='javascript:void(0);' " +
			  "onMouseOver=\"window.status='"+acText+"'; return true;\" " +
			  "onMouseOut=\"window.status=' '; return true;\" ";   
                                                           
  if (acCaptionID)
    acText = "<span id='"+this.name+"spancaption_"+acCaptionID+"'>" + acText + "</span>";
    
  if (acOper == "b")
      cCode += "onClick=\"window['"+this.name+"'].clearDate();\">" + acText + "</A>";
  else if (acOper == "x")
      cCode += "onClick=\"window['"+this.name+"'].hide();\">" + acText + "</A>";
  else if (acOper == "h") 
      cCode += "onClick=\"window['"+this.name+"'].updateDate('h');\">" + acText + "</A>";
  else
  {
    if (acWhere == "d") 
      cCode += "onClick=\"window['"+this.name+"'].updateDate('"+acWhere+"','"+acOper+"');\">" + acOper + "</A>";
    else
      cCode += "onClick=\"window['"+this.name+"'].updateDate('"+acOper + acWhere+"');\">" + acOper + "</A>";
  }

  return cCode;
}

Calendar.prototype.renderCalendar = function()
{
  var aBuffer = new Array();

  aBuffer.push('<table border="0" cellpadding="0" cellspacing="0">');
  aBuffer.push('<caption><span id="'+this.name+'Caption"></span></caption>');
  aBuffer.push('<thead>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <th colspan="3">'+this.makeAction('-', 'Mês Anterior', 'm')+' <span id="'+this.name+'Month"></span> '+this.makeAction('+', 'Mês Sequinte', 'm')+'</th>');
  aBuffer.push('    <th>'+this.makeAction('h', 'hoje')+'</th>');
  aBuffer.push('    <th colspan="3">'+this.makeAction('-', 'Ano Anterior', 'y')+' <span id="'+this.name+'Year"></span> '+this.makeAction('+', 'Ano Sequinte', 'y')+'</th>');
  aBuffer.push('  </tr>');
  aBuffer.push('</thead>');
  aBuffer.push('<tbody>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <th>D</th>');
  aBuffer.push('    <th>S</th>');
  aBuffer.push('    <th>T</th>');
  aBuffer.push('    <th>Q</th>');
  aBuffer.push('    <th>Q</th>');
  aBuffer.push('    <th>S</th>');
  aBuffer.push('    <th>S</th>');
  aBuffer.push('  </tr>');
  
  for (var nRow = 0; nRow < 6; nRow++)
  {
    aBuffer.push('  <tr>');
    for (var nCol = 0; nCol < 7; nCol++)
      aBuffer.push('    <td'+(((nCol==0)||(nCol==6))?' class="weekend"':'')+'><span></span></td>');
    aBuffer.push('  </tr>');
  }

  aBuffer.push('  </tbody>');
  aBuffer.push('  <tfoot>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td colspan="3">'+this.makeAction('b', this.Captions.emBranco, null, 'emBranco')+'</th>');
  aBuffer.push('    <td>&nbsp;</th>');
  aBuffer.push('    <td colspan="3" style="text-align:right">'+this.makeAction('x', this.Captions.fechar, null, 'fechar')+'</th>');
  aBuffer.push('  </tr>');
  aBuffer.push('  </tfoot>');
  aBuffer.push('</table>');
  
  return aBuffer;
}

Calendar.prototype.init = function()
{
  if (this.oCalendar) return;
  
  this.oCalendar = document.getElementById(this.name);

  // get all <span> elements for complementation
  var oBody = this.oCalendar.getElementsByTagName('tbody')[0];
                                 
  this.oCaption = document.getElementById(this.name+'Caption');
  for (caption in this.Captions)
    this['spancaption_'+caption] = document.getElementById(this.name+'spancaption_'+caption);

  this.oYear = document.getElementById(this.name+'Year');
  this.oMonth = document.getElementById(this.name+'Month');
  this.aDays = oBody.getElementsByTagName('span');
}

Calendar.prototype.daysofmonth = function(monthNo, p_year)
{
	/*
	Check for leap year ..
	1.Years evenly divisible by four are normally leap years, except for...
	2.Years also evenly divisible by 100 are not leap years, except for...
	3.Years also evenly divisible by 400 are leap years.
	*/                                
	if ((monthNo == 1) && (p_year % 4) == 0) // é fevereiro 
	{
	  if ((p_year % 100) == 0 && (p_year % 400) != 0)
		return this.DOMonth[monthNo];
      return 29;
	} else
	  return this.DOMonth[monthNo];
}

Calendar.prototype.fill = function()
{
  this.init();
  var aDays = new Array();
  var vDate = new Date();
  var dHoje = new Date();
       
  dHoje.setHours(0, 0, 0, 0);

  vDate.setDate(1);
  vDate.setMonth(this.dValue.getMonth());
  vDate.setFullYear(this.dValue.getFullYear());
  vDate.setHours(0, 0, 0, 0);

  this.oYear.innerHTML = this.dValue.getFullYear();
  this.oMonth.innerHTML = this.Months[this.dValue.getMonth()];

  var vFirstDay=vDate.getDay();
  var vDay=1;
  var vLastDay=this.daysofmonth(vDate.getMonth(), vDate.getFullYear());
  var vOnLastDay=0;
  var vCode = "";

  /*
   Get day for the 1st of the requested month/year..
   Place as many blank cells before the 1st day of the month as necessary.
  */
  for (i=0; i<vFirstDay; i++) 
    aDays.push("&nbsp;");

  // Write rest of the 1st week
  for (j=vFirstDay; j<7; j++) 
  {
    vDate.setDate(vDay);              
    var cCode = this.makeAction(vDay, this.Captions.ajustePara + ' ' + this.formatDate(vDate), 'd', 'ajustePara')
    if (vDate+'' == dHoje+'')
	{
		cCode = "#" + cCode;
	}	
    if (this.formatDate(new Date(vDate)) == this.formatDate(new Date(this.getDate()))) {
		cCode = "@" + cCode;
    }
  	aDays.push(cCode);	
    vDay=vDay + 1;
  }

  // Write the rest of the weeks
  var lDestaque;
  for (k=2; k<7; k++) 
  {
    for (j=0; j<7; j++) 
	  {
      vDate.setDate(vDay);
      try { lDestaque = onDayAlert(this.ansiDate(vDate)); } catch (err) { lDestaque = false; }
      if (lDestaque)
        var cCode = this.makeAction(vDay, this.Captions.ajustePara + ' ' + this.formatDate(vDate) + this.Captions.destaque, 'd', 'ajustePara');
      else
        var cCode = this.makeAction(vDay, this.Captions.ajustePara + ' ' + this.formatDate(vDate), 'd', 'ajustePara');
      
      if ((vDate+'') == (dHoje+''))
        cCode = "#" + cCode;
      if (this.formatDate(new Date(vDate)) == this.formatDate(new Date(this.getDate())))
		    cCode = "@" + cCode;
      if (lDestaque)
		    cCode = "B" + cCode;
    	aDays.push(cCode);
	    vDay=vDay + 1;

	    if (vDay > vLastDay) 
	    {
        vOnLastDay = 1;
		    break;
      }
    }

	  if (vOnLastDay == 1)
	  	break;
  }

  // Fill table with datas
  var n;
  for (n = 0; n < aDays.length; n++)
  {
    this.aDays[n].parentElement.className = this.aDays[n].parentElement.className.replace(new RegExp(" today","gi"),"");    
    this.aDays[n].parentElement.className = this.aDays[n].parentElement.className.replace(new RegExp(" selectedDay","gi"),"");    
    this.aDays[n].parentElement.className = this.aDays[n].parentElement.className.replace(new RegExp(" destakDay","gi"),"");    

    if (aDays[n].substr(0,1) == "B")
    {
      aDays[n] = aDays[n].substr(1);
      this.aDays[n].parentElement.className += " destakDay";
    }

    if (aDays[n].substr(0,1) == "@")
    {
      aDays[n] = aDays[n].substr(1);
      this.aDays[n].parentElement.className += " selectedDay";
    }

    if (aDays[n].substr(0,1) == "#")
    {
      aDays[n] = aDays[n].substr(1);
      this.aDays[n].parentElement.className += " today";
    }

    this.aDays[n].innerHTML = aDays[n];
  }
  for (; n < this.aDays.length; n++)
    this.aDays[n].innerHTML = "&nbsp";
}
 
Calendar.prototype.show = function (acInputName, dMin, dMax, x, y, aoOnSelected, aaCaptions)
{              
  var dAux = new Date();
  this.init();
  this.resetCaptions(aaCaptions);
  this.oTarget = document.getElementById(acInputName);

  if (!(isElementVisible(this.oTarget)))
  { 
    var mousePos = getMousePostion();
    x = mousePos.x;
    y = mousePos.y;
  }

 adjustPosComponent(this.oCalendar, this.oTarget, x, y, true);
    
  var aParts = this.oTarget.value.split('/');
  if ((aParts.length < 3) || (aParts[0] == '  '))
	  dAux = new Date();
  else
	  dAux = new Date(aParts[2], aParts[1]-1, aParts[0]);
  
  this.oTarget.value = this.formatDate(dAux);

  this.setRange(dMin, dMax);  
  this.onSelected = aoOnSelected;
  this.oCalendar.style.display = "block";
  this.setDate(dAux);
}

Calendar.prototype.hide = function ()
{              
  this.oTarget = null;
  this.oCalendar.style.display = "none";
  this.onSelected = null;
}

Calendar.prototype.formatDate = function (dValue)
{
  return dValue.getDate() +"/"+ (dValue.getMonth()+1) + "/" + dValue.getYear();
}

Calendar.prototype.ansiDate = function (dValue)
{                                            
  var nYYYY = dValue.getFullYear();
  var nMM = dValue.getMonth()<9?'0'+(dValue.getMonth()+1):dValue.getMonth()+1;
  var nDD = dValue.getDate()<10?'0'+dValue.getDate():dValue.getDate();
 
  return (nYYYY +'/'+ nMM +'/'+ nDD).replace(new RegExp("/","gi"),"");
}

Calendar.prototype.clearDate = function ()
{
  this.oTarget.value = "";  
  if (this.onSelected)
   this.onSelected(this.oTarget.value);
  this.hide();          
}

Calendar.prototype.setRange = function (dMin, dMax)
{
  if (!(dMin))
    dMin = new Date(1970, 0, 1);
  if (!(dMax))
    dMax = new Date(2050, 11, 31);
 
  this.range.min = dMin;
  this.range.max = dMax;
  this.range.UTCmin = Date.UTC(dMin.getFullYear(), dMin.getMonth(), dMin.getDate());
  this.range.UTCmax = Date.UTC(dMax.getFullYear(), dMax.getMonth(), dMax.getDate());
}

// #####################################################################################
// Classe: ClockTable
// #####################################################################################

var CLOCK_TABLE_DIV_NAME = 'divClockTable';

var ANO_BASE = 2000;
var MES_BASE = 0;
var DIA_BASE = 1;

function ClockTable()
{
  // initialize internal properties.
  this.tValue = this.newTime();
  this.xOffset = 0;
  this.yOffset = 0;
  this.name = CLOCK_TABLE_DIV_NAME;
  this.range = { min: 0, max: 0, UTCmin: 0, UTCmax:0 };
   
  window[this.name] = this;

  var oDiv = document.createElement("DIV");
	document.body.appendChild(oDiv);
	oDiv.id = this.name;
	oDiv.className = "calendar";
	oDiv.innerHTML = this.renderClockTable().join('');
}

ClockTable.prototype.newTime = function(cValue)
{
  var aParts;
  var dRet = new Date(ANO_BASE, MES_BASE, DIA_BASE);
  
  if (cValue)
  {                      
    aParts = cValue.split(":");
    if (aParts[0] == ' ')
      aParts = [0, 0, 0];
  } else
    aParts = [0, 0, 0];

  dRet.setHours(aParts[0]);
  dRet.setMinutes(aParts[1]);
  dRet.setSeconds(aParts[2]);

  return dRet;
}

ClockTable.prototype.UTCTime = function(dValue)
{
  return Date.UTC(ANO_BASE, MES_BASE, DIA_BASE, 
                  dValue.getHours(), dValue.getMinutes(), dValue.getSeconds(), 0)
}

ClockTable.prototype.setTime = function(cValue)
{                             
  var dValue;
  
  if (typeof(cValue) == "string")
    dValue = this.newTime(cValue);
  else
    dValue = cValue;
    
  if (!((this.dValue+'') == (dValue+'')))
  {     
    var nUTC = this.UTCTime(dValue);
    if (nUTC < this.range.UTCmin)
       dValue = this.range.min;
    else if (nUTC > this.range.UTCmax)
       dValue = this.range.max;
       
    this.dValue = new Date(dValue);
    this.fill();
  } 
}

ClockTable.prototype.getTime = function()
{
  return this.dValue;
}

ClockTable.prototype.updateTime = function (acCmd, acValue)
{ 
  var dAux = this.getTime();
  if (acCmd == "h")
  {
    dAux.setHours(acValue);
    this.oCaption.innerHTML = STR0040; //
  } else if (acCmd == "m")
    dAux.setMinutes(acValue);
  else if (acCmd == "s")
    dAux.setSeconds(acValue);

  this.setTime(this.formatTime(dAux));
  this.oTarget.value = this.formatTime(this.getTime());
  
  if ((acCmd == "m") || (acCmd == "s"))
 	this.hide();
}

ClockTable.prototype.makeAction = function (acOper, acText)
{                                                           
  var cCode = "<a href='javascript:void(0);' " +
			  "onMouseOver=\"window.status='"+acText+"'; return true;\" " +
			  "onMouseOut=\"window.status=' '; return true;\" ";   

  if (acOper == "x")
      cCode += "onClick=\"window['"+this.name+"'].hide();\">" + acText + "</A>";
  else if (acOper == "b") 
      cCode += "onClick=\"window['"+this.name+"'].clearTime();\">" + acText + "</A>";
  else
      cCode += "onClick=\"window['"+this.name+"'].updateTime('"+acOper+"',"+acText+");\">" + acText + "</A>";
  
  return cCode;
}

ClockTable.prototype.renderClockTable = function()
{
  var aBuffer = new Array();

  aBuffer.push('<table border="0" cellpadding="0" cellspacing="0">');
  aBuffer.push('<caption><span id="'+this.name+'Caption"></span></caption>');
  aBuffer.push('<tbody>');
  aBuffer.push('  <tr>');
  for (var nHora = 0; nHora < 12; nHora ++)
    aBuffer.push('    <td>'+this.makeAction('h', nHora)+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  <tr>');
  for (var nHora = 12; nHora < 24; nHora ++)
    aBuffer.push('    <td>'+this.makeAction('h', nHora)+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  <tr>');
  for (var nMin = 0; nMin < 60; nMin += 5)
    aBuffer.push('    <th>'+this.makeAction('m', nMin)+'</th>');
  aBuffer.push('  </tr>');
  
  aBuffer.push('  </tbody>');
  aBuffer.push('  <tfoot>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td colspan="6">'+this.makeAction('b', 'Em_branco')+'</td>');
  aBuffer.push('    <td colspan="6">'+this.makeAction('x', 'Fechar')+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  </tfoot>');
  aBuffer.push('</table>');
  
  return aBuffer;
}

ClockTable.prototype.init = function()
{
  if (this.oClockTable) return;

  this.oCaption = document.getElementById(this.name+'Caption');
  this.oClockTable = document.getElementById(this.name);
}

ClockTable.prototype.fill = function()
{
  this.init();
}
 
ClockTable.prototype.show = function (acInputName, cMin, cMax, x, y)
{              
  var dAux = new Date();
  this.init();

  this.oTarget = document.getElementById(acInputName);
  adjustPosComponent(this.oClockTable, this.oTarget, x, y)
  this.oCaption.innerHTML = STR0041; //"Selecione a hora"

  dAux = this.newTime(this.oTarget.value);

  if (dAux == "NaN")
  {
    dAux = this.newTime(this.formatTime(dAux));
    this.oTarget.value = this.formatTime(dAux);
  }
  this.setRange(cMin, cMax);
  this.setTime(this.formatTime(dAux));
  this.oClockTable.style.display = "block";
}

ClockTable.prototype.hide = function ()
{              
  this.oTarget = null;
  this.oClockTable.style.display = "none";
}

ClockTable.prototype.formatTime = function (dValue)
{
  return dValue.toString().substr(10, 8);
}

ClockTable.prototype.clearTime = function ()
{
  this.oTarget.value = "";
  this.hide();
}

ClockTable.prototype.setRange = function (cMin, cMax)
{
  if (!(cMin))
    cMin = '00:00:00';
  if (!(cMax))
    cMax = '23:59:59';
   
  this.range.min = this.newTime(cMin);
  this.range.max = this.newTime(cMax);
  this.range.UTCmin = this.UTCTime(this.range.min);
  this.range.UTCmax = this.UTCTime(this.range.max);
}

// #####################################################################################
// Classe: DaysOfWeekTable
// #####################################################################################

var DAYS_OF_WEEK_TABLE_DIV_NAME = 'divDaysOfWeekTable';

function DaysOfWeekTable()
{                         
  // initialize internal properties.
  this.aValues = { dom: false, seg: false, ter: false, qua: false, qui: false, sex: false, sab: false }
  this.aTraduz = { dom: "Dom", seg: "Seg", ter: "Ter", qua: "Qua", qui: "Qui", sex: "Sex", sab: "Sab" }
  this.xOffset = 0;
  this.yOffset = 0;
  this.name = DAYS_OF_WEEK_TABLE_DIV_NAME;
   
  window[this.name] = this;

  var oDiv = document.createElement("DIV");
	document.body.appendChild(oDiv);
  oDiv.id = this.name;
	oDiv.className = "calendar";
	oDiv.innerHTML = this.renderDaysOfWeekTable().join('');
}

DaysOfWeekTable.prototype.setValue = function(cWeekDay, lValue)
{            
  if (!(this.aValues[cWeekDay] == lValue))
  {
	  this.aValues[cWeekDay] = lValue;
	  this.fill();
	 }
}

DaysOfWeekTable.prototype.invertMarks = function()
{
  for (var o in this.aValues)
  	this.setValue(o, !this.getValue(o));
}

DaysOfWeekTable.prototype.getValue = function(cWeekDay)
{
  return this.aValues[cWeekDay];
}

DaysOfWeekTable.prototype.updateValue = function ()
{ 
  this.oTarget.value = this.formatWeek();
}

DaysOfWeekTable.prototype.updateTable = function ()
{ 
  var cValue = this.oTarget.value;
  var i = 0;
  for (var o in this.aValues)
  { 
    this.aChecks[i].checked = cValue.indexOf(this.aTraduz[o]) > -1;
    i++;
  }
}

DaysOfWeekTable.prototype.makeAction = function (acOper, acText)
{                                                           
  var cCode = "<a href='javascript:void(0);' " +
			  "onMouseOver=\"window.status='"+acText+"'; return true;\" " +
			  "onMouseOut=\"window.status=' '; return true;\" ";   

  if (acOper == "x")
      cCode += "onClick=\"window['"+this.name+"'].hide();\">" + acText + "</A>";
  else if (acOper == "b") 
      cCode += "onClick=\"window['"+this.name+"'].clearValue();\">" + acText + "</A>";
  
  return cCode;
}

DaysOfWeekTable.prototype.renderDaysOfWeekTable = function()
{
  var aBuffer = new Array();
  var cOnClick = "onClick=\"window['"+this.name+"'].setValue('@',this.checked);\"";
  var cDoInvert = "onClick=\"window['"+this.name+"'].invertMarks();\"";

  aBuffer.push('<table border="0" cellpadding="0" cellspacing="0">');
  aBuffer.push('<caption><span id="'+this.name+'Caption"></span></caption>');
  aBuffer.push('<tbody>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td><input id="'+this.name+'WDay0" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "dom")+'>' + STR0042 + '</td>'); //Domingo
  aBuffer.push('    <td><input id="'+this.name+'WDay1" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "seg")+'>' + STR0043 + '</td>'); //Segunda
  aBuffer.push('    <td><input id="'+this.name+'WDay2" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "ter")+'>' + STR0044 + '</td>'); //Ter‡a
  aBuffer.push('    <td><input id="'+this.name+'WDay3" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "qua")+'>' + STR0045 + '</td>'); //Quarta
  aBuffer.push('  </tr>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td><input id="'+this.name+'WDay4" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "qui")+'>' + STR0046 + '</td>'); //Quinta
  aBuffer.push('    <td><input id="'+this.name+'WDay5" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "sex")+'>' + STR0047 + '</td>'); //Sexta
  aBuffer.push('    <td><input id="'+this.name+'WDay6" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), "sab")+'>' + STR0048 + '</td>'); //Sabado
  aBuffer.push('    <td><input class="form_input" type="checkbox" '+cDoInvert+'>Inverte</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('</tbody>');
  aBuffer.push('<tfoot>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td colspan="2">'+this.makeAction('b', 'Em_branco')+'</td>');
  aBuffer.push('    <td colspan="2">'+this.makeAction('x', 'Fechar')+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  </tfoot>');
  aBuffer.push('</table>');
  
  return aBuffer;
}

DaysOfWeekTable.prototype.init = function()
{
  if (this.oDaysOfWeekTable) return;

  this.oCaption = document.getElementById(this.name+'Caption');
  this.oDaysOfWeekTable = document.getElementById(this.name);
  this.aChecks = new Array();
  for (var i=0; i<7;i++)                 
 		this.aChecks.push(document.getElementById(this.name+'WDay'+i));
}

DaysOfWeekTable.prototype.fill = function()
{
  this.init();
  this.updateValue();
  this.updateTable();
}
 
DaysOfWeekTable.prototype.show = function (acInputName, x, y)
{                   
  this.oTarget = document.getElementById(acInputName);
  this.init();
  adjustPosComponent(this.oDaysOfWeekTable, this.oTarget, x, y)
  this.oCaption.innerHTML = STR0049; //"Selecione os dias da semana"
  this.oDaysOfWeekTable.style.display = "block";
  this.updateTable()
}

DaysOfWeekTable.prototype.hide = function ()
{              
  this.oTarget = null;
  this.oDaysOfWeekTable.style.display = "none";
}

DaysOfWeekTable.prototype.formatWeek = function ()
{
  var aRet = new Array();

  for (var o in this.aValues)
  	if (this.getValue(o))
  		aRet.push(''+this.aTraduz[o]);

  return aRet.join(',');
}

DaysOfWeekTable.prototype.clearValue = function ()
{
  this.oTarget.value = "";
  this.hide();
}

// #####################################################################################
// Classe: DaysOfMonthTable
// #####################################################################################

var DAYS_OF_MONTH_TABLE_DIV_NAME = 'divDaysOfMonthTable';
var START_DAY = 1;
var STOP_DAY = 32;

function DaysOfMonthTable()
{                         
  // initialize internal properties.
  this.aValues = new Array(STOP_DAY);
  for (var i=START_DAY; i < STOP_DAY;i++)
  	this.aValues[i] = false;
  this.xOffset = 0;
  this.yOffset = 0;
  this.name = DAYS_OF_MONTH_TABLE_DIV_NAME;
   
  window[this.name] = this;

  var oDiv = document.createElement("DIV");
	document.body.appendChild(oDiv);
  oDiv.id = this.name;
	oDiv.className = "calendar";
	oDiv.innerHTML = this.renderDaysOfMonthTable().join('');
}

DaysOfMonthTable.prototype.setValue = function(nMonthDay, lValue)
{            
  if (!(this.aValues[nMonthDay] == lValue))
  {
	  this.aValues[nMonthDay] = lValue;
	  this.fill();
	 }
}

DaysOfMonthTable.prototype.invertMarks = function()
{
  for (var i=START_DAY; i < STOP_DAY;i++)
  	this.setValue(i, !this.getValue(i));
}

DaysOfMonthTable.prototype.getValue = function(nMonthDay)
{
  return this.aValues[nMonthDay];
}

DaysOfMonthTable.prototype.updateValue = function ()
{ 
  this.oTarget.value = this.formatMonth();
}

DaysOfMonthTable.prototype.updateTable = function ()
{ 
  var cValue = ","+this.oTarget.value +",";
  for (var i=START_DAY; i < STOP_DAY;i++)
    this.aChecks[i].checked = cValue.indexOf(","+i+",") > -1;
}

DaysOfMonthTable.prototype.makeAction = function (acOper, acText)
{                                                           
  var cCode = "<a href='javascript:void(0);' " +
			  "onMouseOver=\"window.status='"+acText+"'; return true;\" " +
			  "onMouseOut=\"window.status=' '; return true;\" ";   

  if (acOper == "x")
  	cCode += "onClick=\"window['"+this.name+"'].hide();\">" + acText + "</A>";
  else if (acOper == "b") 
    cCode += "onClick=\"window['"+this.name+"'].clearValue();\">" + acText + "</A>";
  
  return cCode;
}

DaysOfMonthTable.prototype.renderDaysOfMonthTable = function()
{
  var aBuffer = new Array();
  var cOnClick = "onClick=\"window['"+this.name+"'].setValue('@',this.checked);\"";
  var cDoInvert = "onClick=\"window['"+this.name+"'].invertMarks();\"";

  aBuffer.push('<table border="0" cellpadding="0" cellspacing="0">');
  aBuffer.push('<caption><span id="'+this.name+'Caption"></span></caption>');
  aBuffer.push('<tbody>');
  aBuffer.push('  <tr>');
  for (var i=1; i < 9;i++)
  	aBuffer.push('    <td><input id="'+this.name+'WDay'+i+'" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), (i))+'>'+i+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  <tr>');
  for (var i=9; i < 17;i++)
  	aBuffer.push('    <td><input id="'+this.name+'WDay'+i+'" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), (i))+'>'+i+'</td>');
  aBuffer.push('  </tr>');
  for (var i=17; i < 25;i++)
  	aBuffer.push('    <td><input id="'+this.name+'WDay'+i+'" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), (i))+'>'+i+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  </tr>');
  for (var i=25; i < 32;i++)
  	aBuffer.push('    <td><input id="'+this.name+'WDay'+i+'" class="form_input" type="checkbox" '+cOnClick.replace(new RegExp("@","gi"), (i))+'>'+i+'</td>');
  aBuffer.push('    <td><input class="form_input" type="checkbox" '+cDoInvert+'>Inv.</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('</tbody>');
  aBuffer.push('<tfoot>');
  aBuffer.push('  <tr>');
  aBuffer.push('    <td colspan="4">'+this.makeAction('b', 'Em_branco')+'</td>');
  aBuffer.push('    <td colspan="4">'+this.makeAction('x', 'Fechar')+'</td>');
  aBuffer.push('  </tr>');
  aBuffer.push('  </tfoot>');
  aBuffer.push('</table>');
  
  return aBuffer;
}

DaysOfMonthTable.prototype.init = function()
{
  if (this.oDaysOfMonthTable) return;

  this.oCaption = document.getElementById(this.name+'Caption');
  this.oDaysOfMonthTable = document.getElementById(this.name);
  this.aChecks = new Array(STOP_DAY);
  for (var i=START_DAY; i < STOP_DAY;i++)
 		this.aChecks[i] = document.getElementById(this.name+'WDay'+i);
}

DaysOfMonthTable.prototype.fill = function()
{
  this.init();
  this.updateValue();
  this.updateTable();
}
 
DaysOfMonthTable.prototype.show = function (acInputName, x, y)
{                   
  this.oTarget = document.getElementById(acInputName);
  this.init();
  adjustPosComponent(this.oDaysOfMonthTable, this.oTarget, x, y)
  this.oCaption.innerHTML = STR0050; //"Selecione os dias"
  this.oDaysOfMonthTable.style.display = "block";
  this.updateTable()
}

DaysOfMonthTable.prototype.hide = function ()
{              
  this.oTarget = null;
  this.oDaysOfMonthTable.style.display = "none";
}

DaysOfMonthTable.prototype.formatMonth = function ()
{
  var aRet = new Array();

  for (var i=START_DAY; i < STOP_DAY;i++)
  	if (this.getValue(i))
  		aRet.push(i);

  return aRet.join(',');
}

DaysOfMonthTable.prototype.clearValue = function ()
{
  this.oTarget.value = "";
  this.hide();
}

// #####################################################################################
// Função para acionamento do calendário e da tabela de horas
// #####################################################################################

function showCalendar(acInputName, dMin, dMax, anX, anY, aoOnSelected, aaCaption)
{ 
  if (!window[CALENDAR_DIV_NAME])
		new Calendar();
  window[CALENDAR_DIV_NAME].show(acInputName, dMin, dMax, anX, anY, aoOnSelected, aaCaption);
}

function showClockTable(acInputName, cMin, cMax)
{ 
  if (!window[CLOCK_TABLE_DIV_NAME])
		new ClockTable();
  window[CLOCK_TABLE_DIV_NAME].show(acInputName, cMin, cMax)
}

function showDaysOfWeekTable(acInputName)
{
  if (!window[DAYS_OF_WEEK_TABLE_DIV_NAME])
		new DaysOfWeekTable();
  window[DAYS_OF_WEEK_TABLE_DIV_NAME].show(acInputName);
}

function	showDaysOfMonthTable(acInputName)
{
  if (!window[DAYS_OF_MONTH_TABLE_DIV_NAME])
		new DaysOfMonthTable();
  window[DAYS_OF_MONTH_TABLE_DIV_NAME].show(acInputName);
}