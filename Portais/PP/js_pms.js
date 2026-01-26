//////////////////////////////////
// JavaScript para o Portal PMS //
//////////////////////////////////

///////////////////////////////////
// Swap Image usada no Folder
// Autor: Cristiano Denardi Alarcon
function PMS_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.PMS_p) d.PMS_p=new Array();
    var i,j=d.PMS_p.length,a=PMS_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.PMS_p[j]=new Image; d.PMS_p[j++].src=a[i];}}
}

function PMS_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=PMS_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function PMS_swapImage() { //v3.0
  var i,j=0,x,a=PMS_swapImage.arguments; document.PMS_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=PMS_findObj(a[i]))!=null){document.PMS_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
// Swap Image usada no Folder
/////////////////////////////


///////////////////////////////////
// Abre Janela Pop-Up
// Autor: Cristiano Denardi Alarcon
function abreJanela(url,nX,nY,Resi)
{
	var cStr;
	if(nY != 0 && nX != 0)
	{
		cStr = ', width='+nX;
		cStr += ', height='+nY;
		cStr += ', left=' + (screen.width-nX)/2 + ', top=' + (screen.height-nY)/2;
	}
	if(Resi == undefined)
		Resi = false;
	cStr += ', resizable='+(Resi?'yes':'no');
	Janela = null;
	Janela = window.open(url, 'Details', 'scrollbars=1, status=no, menubar=no' + cStr );
	Janela.focus();
}


/////////////////////////////////////
// Funcoes para abrir Menu Drop-Down
// na tela 22.aph chamando a inclusao
// de apontamentos e confirmacoes
// de tarefas
// Sera' usado em help avancado da busca em formato WORD.
// Autor: Cristiano Denardi Alarcon
function show(menu)
{
   var menuObj = document.getElementById(menu);
   menuObj.style.display = "block";
}
function hide(menu)
{
   var menuObj = document.getElementById(menu);
   menuObj.style.display = "none";
}


/////////////////////////////////////////////////////////////
// Funcoes para validacao e gatilhos de horas no aprontamento
// Autor: Carlos Alberto Gomes Jr.
function ValidHora(oRecHora)
{
   var cHora = oRecHora.value ;
   if ( cHora.length < 4 )
   {
      alert(STR0001) ; //"Hora invalida. (hh:mm)"
      oRecHora.value = "00:00" ;
      return false
   }
   if ( cHora.indexOf(":") == 1 )
   {
      cHora = '0' + cHora.substr(0) ;
   }
   if ( cHora.indexOf(":") != 2 )
   {
      cHora = cHora.substr(0,2) + ':' + cHora.substr(2,2);
   }
   if ( cHora.length == 4 )
   {
      cHora = cHora + '0' ;
   }
   if ( !(Number(cHora.substr(0,2)) == cHora.substr(0,2)) ||  cHora.substr(0,2) < 00 || cHora.substr(0,2) > 23  )
   {
      alert(STR0001) ; //"Hora invalida. (hh:mm) - Erro hora."
      oRecHora.value = "00:00" ;
      return false
   }
   if ( !(Number(cHora.substr(3,2)) == cHora.substr(3,2)) ||  cHora.substr(3,2) < 00 || cHora.substr(3,2) > 59 )
   {
      alert(STR0002) ; //"Hora invalida. (hh:mm) - Erro minutos."
      oRecHora.value = "00:00" ;
      return false
   }
   oRecHora.value = cHora ;
   return true
}

function H2M(cHora)
{
   return (Number(cHora.substr(0,2)) * 60) + Number(cHora.substr(3,2)) ;
}

function M2H(nMinutos)
{
   var cHora = '00' ;
   var cMin  = '00' ;
   cHora = String(parseInt(nMinutos/60)) ;
   cMin = String(Math.round(nMinutos%60)) ;
   if ( cHora.length == 1 )
   {
      cHora = '0' + cHora ;
   }
   if ( cMin.length == 1 )
   {
      cMin = '0' + cMin ;
   }
   return cHora+':'+cMin
}

function GatHoraF(oPasDoc)
{
   if ( !ValidHora(oPasDoc.AFU_HORAF) )
   {
	  GatQtHo(oPasDoc) ;
      return false
   }
   var nMinutos = H2M(oPasDoc.AFU_HORAF.value) - H2M(oPasDoc.AFU_HORAI.value) ;
   if ( nMinutos < 0 )
   {
      alert(STR0003) ; //'A Hora Final deve ser maior doque a Hora Inicial.'
      GatQtHo(oPasDoc) ;
      return false
   }
   var cHoraDec = String(parseInt( ((nMinutos/60) - parseInt(nMinutos/60)) * 100 )) ;
   if ( cHoraDec.length == 1 )
   {
      cHoraDec = '0' + cHoraDec ;
   }
   oPasDoc.AFU_HQUANT.value = String(parseInt(nMinutos/60)) + '.' + cHoraDec ;
}

function GatQtHo(oPasDoc)
{
   if ( Number(oPasDoc.AFU_HQUANT.value) != oPasDoc.AFU_HQUANT.value )
   {
      if ( oPasDoc.AFU_HQUANT.value.indexOf(',') > 0 )
      {
         alert(STR0004) ; //'Utilize ponto ao invés de virgula'
      }
      else
      {
         alert(STR0005) ; //'Valor invalido.'
      }
      GatHoraF(oPasDoc) ;
      return false
   }
   var nNewHoraF = H2M(oPasDoc.AFU_HORAI.value) + ( oPasDoc.AFU_HQUANT.value * 60 )
   if ( nNewHoraF > H2M('23:59') )
   {
      alert(STR0006 + oPasDoc.AFU_HORAI.value +  STR0007) ; //'Nao e possivel trabalhar este numero de horas iniciando as ' ### '! Corrija a hora inicial primeiro.'
      GatHoraF(oPasDoc) ;
      return false
   }
   oPasDoc.AFU_HORAF.value = M2H(nNewHoraF) ;
   GatHoraF(oPasDoc) ;
   return true
}

function QtExecut(oPasDoc)
{
	if ( Number(oPasDoc.AFF_QUANT.value) != oPasDoc.AFF_QUANT.value)
		{
			if (oPasDoc.AFF_QUANT.value.indexOf(',') > 0 )
				{ alert(STR0008) ; } //'Utilize ponto no lugar de virgula'
			else
				{ alert(STR0009) ; } //'Quantidade inválida! Digite um valor numérico!'
			PerExecut(oPasDoc) ;
			return false
		}
	if ( Number(oPasDoc.AFF_QUANT.value) < 0 )
		{ alert(STR0010) ; //'A quantidade deve ser maior que zero!'
			PerExecut(oPasDoc) ;
			return false
		}
	if ( Number(oPasDoc.AFF_QUANT.value) > Number(oPasDoc.AF9_QUANT.value) )
		{ alert(STR0011 + oPasDoc.AF9_QUANT.value + ' !') ; //'A quantidade deve ser menor ou igual a '
			PerExecut(oPasDoc) ;
			return false
		}

	oPasDoc.AFF_PERC.value  = PicNum(String( Math.round((Number(oPasDoc.AFF_QUANT.value)*10000 )/Number(oPasDoc.AF9_QUANT.value)) / 100 ),2) ;
	oPasDoc.AFF_QUANT.value = PicNum(String( Math.round((Number(oPasDoc.AFF_PERC.value)*Number(oPasDoc.AF9_QUANT.value))*1000) / 100000 ),5) ;
}

function PerExecut(oPasDoc)
{
	if ( Number(oPasDoc.AFF_PERC.value) != oPasDoc.AFF_PERC.value || Number(oPasDoc.AFF_PERC.value) < 0 || Number(oPasDoc.AFF_PERC.value) > 100 )
		{
			if (oPasDoc.AFF_PERC.value.indexOf(',') > 0 )
				{ alert(STR0008) ; } //'Utilize ponto no lugar de virgula'
			else
				{ alert(STR0012) ;} //'Percentual inválido! Digite um valor entre 0 e 100 !'
			QtExecut(oPasDoc)
			return false
		}
	oPasDoc.AFF_QUANT.value = PicNum(String( Math.round((Number(oPasDoc.AFF_PERC.value)*Number(oPasDoc.AF9_QUANT.value))*1000) / 100000 ),5) ;
	oPasDoc.AFF_PERC.value  = PicNum(String( Math.round((Number(oPasDoc.AFF_QUANT.value)*10000 )/Number(oPasDoc.AF9_QUANT.value)) / 100 ),2) ;
}

function PicNum(cValor,nDec)
{
	if ( cValor.indexOf('.') == -1 )
		{ cValor = cValor + '.0' ; }
	while ( cValor.length - cValor.indexOf('.') < nDec + 1 )
		{cValor = cValor + '0' ;}
	return cValor

}
function AbreF3(cLink,aParamAdic,cWPars)
{
	if (aParamAdic.constructor==Array)
	{	for (x=0;x<aParamAdic.length;x+=2)
		{
			var y;
			if (y=document.getElementById(aParamAdic[x+1]))
		    	cLink	+=	'&'+aParamAdic[x]+"="+y.value;
		}
	}
	window.open(cLink, 'jF3', cWPars);
}


////////////////////////////////////
// Verifica se pelo menos 1 elemento
// de uma ChekBox esta selecionado
// Autor: Cristiano Denardi Alarcon
function checkBoxes (form)
{
   for (var c = 0; c < form.elements.length; c++)
      if (form.elements[c].type == 'checkbox')
         if (form.elements[c].checked)
            return true;
   return false;
}
