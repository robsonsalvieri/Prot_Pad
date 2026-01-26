var aBuffer = {};
var oForm = this;
var cLanguage = "";

/************************************************************
Funcao	: defineLanguage
Autor	: Paulo RV - I.P./B.I.
Data	: 11/10/2007
Desc.	: define o idioma utilizado pelo usuário e será armazenada
	na variável cLanguage para na hora de validação fazer a troca
	do ponto decimal e de milhar para os países diferente do Brasil
Param.	: acLanguage, string, poderá contém:
	ENGLISH - para os países de línga inglesa (picture no formato 9,999.00)
	SPANISH - para os países de línga espanhola (picture no formato 9,999.00)
************************************************************/
function defineLanguage(acLanguage) {
	cLanguage = acLanguage;
}


//#####################################
//mensagens de erro customizáveis
//#####################################

mensagens=new Array()
mensagens[1]=STR0013 //"Email inválido."
mensagens[2]=STR0014 //"CPF inválido."
mensagens[3]=STR0015 //"CGC inválido."
mensagens[4]=STR0016 //"CGC/CPF inválido."
mensagens[5]=STR0017 //"Data inválida."
mensagens[6]=STR0018 //"Campo obrigatório não preenchido."
mensagens[7]=STR0019 //"Matricula Invalida."

//#####################################
//constantes
//#####################################

if (document.all){sender="event.srcElement"}else{sender="e.target"}
nenhuma=0;  
reais=1;  
dolares=2;  
truncar=0;  
aproximar=1;  

//#####################################
//varre o formulário validando os campos
//#####################################

function valida(oObjForm){
	if (oObjForm != undefined){
		obj=oObjForm
	}
	else{
		obj=oForm;
	}
	ixx=obj.campos;
	var cCampo=""
	if (obj.form.action != '') {
		for(y=0;y<obj.total;y++){
			//Valida email
			if (ixx[y].tipo=="email" && !branco(ixx[y].campo.value)){
				if(!verificaEmail(ixx[y].campo.value)){
					alert(mensagens[1])
					ixx[y].campo.focus()
					return false
				}
			}

			//Valida cpf
			if (ixx[y].tipo=="cpf" && !branco(ixx[y].campo.value)){
				if(!verificaCPF(ixx[y].campo.value)){
					alert(mensagens[2])
					ixx[y].campo.focus()
					return false
				}
			}

			//valida cgc
			if (ixx[y].tipo=="cgc" && !branco(ixx[y].campo.value)){
				if(!verificaCGC(ixx[y].campo.value)){
					alert(mensagens[3])
					ixx[y].campo.focus()
					return false
				}
			}

			//valida cgc ou cpf
			if (ixx[y].tipo=="cgcoucpf" && !branco(ixx[y].campo.value)){
				if(!verificaCPF(ixx[y].campo.value) && !verificaCGC(ixx[y].campo.value)){
					alert(mensagens[4])
					ixx[y].campo.focus()
					return false
				}
			}

			//valida data
			if (ixx[y].tipo=="data" && !branco(ixx[y].campo.value)){
				if(!ValData(ixx[y].campo.value)){
					alert(mensagens[5])
					ixx[y].campo.focus()
					return false
				}
			}

			//valida campos obrigatórios
			if (!ixx[y].branco){
				if((Trim(ixx[y].campo.value)=="" || ixx[y].campo.value == "SELECTED") && ixx[y].campo.disabled == false) {
					cCampo = ixx[y].campo.parentNode.textContent
					if (cCampo == ""){
						cCampo = ixx[y].campo.parentNode.parentNode.textContent
					}
										
					ShowModal("Atenção",mensagens[6] + " [" + cCampo + "]",true,false,true); 
					ixx[y].campo.focus();
					return false; 					
				}
			}
		}
		for(y=0;y<obj.total;y++){
			if (ixx[y].dinheiro){ixx[y].campo.value=eval("x"+ixx[y].campo.name)};
			if (ixx[y].tipo=="cgc" || ixx[y].tipo=="cpf" || ixx[y].tipo=="cgcoucpf" || ixx[y].tipo=="cep"){
			ixx[y].campo.value=trimtodigits(ixx[y].campo.value)}
		}
		
		// valida e troca o ponto decimal e de milhar para os países de língua inglesa e espanhola
		if (cLanguage == "ENGLISH" || cLanguage == "SPANISH") {
			for (y=0; y < obj.campos.length; y++) {
				obj.campos[y].campo.value = obj.campos[y].campo.value.replace(".", "|");
				obj.campos[y].campo.value = obj.campos[y].campo.value.replace(",", ".");
				obj.campos[y].campo.value = obj.campos[y].campo.value.replace("|", ",");
			}
		}
	}
	return true
};


//#####################################
//Funcoes de validação
//#####################################
function ValData (data) {
    if ( (data == null) || (data.length < 10) ) {
      return false;
    }
    var jsDataValida = true;
    var jsDia = data.substring(0,2)-0;
    var jsMes = data.substring(3,5)-1;
    var jsAno = data.substring(6,10)-0;
    var oData = new Date(jsAno, jsMes, jsDia);    
    if (jsDia != oData.getDate()) { jsDataValida = false }
    if (jsMes != oData.getMonth()) { jsDataValida = false }
    if (jsAno != oData.getFullYear()) { jsDataValida = false }
    return jsDataValida;
}

function ValData2 (data) {
    if ( (data == null) || (data.length < 10) ) {
      return false;
    }
    var jsDataValida = true;
    var jsDia = data.substring(0,2)-0;
    var jsMes = data.substring(3,5)-1;
    var jsAno = data.substring(6,8)-0;
    var oData = new Date(jsAno, jsMes, jsDia);    
    if (jsDia != oData.getDate()) { jsDataValida = false }
    if (jsMes != oData.getMonth()) { jsDataValida = false }
    if (jsAno != oData.getFullYear()) { jsDataValida = false }
    return jsDataValida;
}
function branco(valor)	{
	 if (valor== ""){
		return true
	 }else{
		return false
	 } 
}


function verificaEmail(email) {  
	var s = new String(email);  
	// { } ( ) < > [ ] | \ /  
	if ((s.indexOf("{")>=0) || (s.indexOf("}")>=0) || (s.indexOf("(")>=0) || (s.indexOf(")")>=0) || (s.indexOf("<")>=0) || (s.indexOf(">")>=0) || (s.indexOf("[")>=0) || (s.indexOf("]")>=0) || (s.indexOf("|")>=0) || (s.indexOf("\"")>=0) || (s.indexOf("/")>=0) )  
		return false;  
	// & * $ % ? ! ^ ~ ` ' "  
	if ((s.indexOf("&")>=0) || (s.indexOf("*")>=0) || (s.indexOf("$")>=0) || (s.indexOf("%")>=0) || (s.indexOf("?")>=0) || (s.indexOf("!")>=0) || (s.indexOf("^")>=0) || (s.indexOf("~")>=0) || (s.indexOf("`")>=0) || (s.indexOf("'")>=0) )  
		return false;  
		// , ; : = #  
	if ((s.indexOf(",")>=0) || (s.indexOf(";")>=0) || (s.indexOf(":")>=0) || (s.indexOf("=")>=0) || (s.indexOf("#")>=0) )  
		return false;  
	// procura se existe apenas um @  
	if ( (s.indexOf("@") < 0) || (s.indexOf("@") != s.lastIndexOf("@")) )  
		return false;  
	// verifica se tem pelo menos um ponto após o @  
	if (s.lastIndexOf(".") < s.indexOf("@"))  
	return false;  
	return true;  
} 


/************************************************  
* function verificaCGC  
* Verifica se um CGC é válido  
* Input: cgc a ser verificado  
************************************************/  
 
function verificaCGC(scgc) {  
	cgc = trimtodigits(scgc);  
	if ((cgc.indexOf("-") != -1) || (cgc.indexOf(".") != -1) || (cgc.indexOf("/") != -1)){  
		return( false )  
	}  
	var df, resto, dac = ""  
	df = 5*cgc.charAt(0)+4*cgc.charAt(1)+3*cgc.charAt(2)+2*cgc.charAt(3)+9*cgc.charAt(4)+8*cgc.charAt(5)+7*cgc.charAt(6)+6*cgc.charAt(7)+5*cgc.charAt(8)+4*cgc.charAt(9)+3*cgc.charAt(10)+2*cgc.charAt(11)  
	resto = df % 11  
	dac += ( (resto <= 1) ? 0 : (11-resto) )  
	df = 6*cgc.charAt(0)+5*cgc.charAt(1)+4*cgc.charAt(2)+3*cgc.charAt(3)+2*cgc.charAt(4)+9*cgc.charAt(5)+8*cgc.charAt(6)+7*cgc.charAt(7)+6*cgc.charAt(8)+5*cgc.charAt(9)+4*cgc.charAt(10)+3*cgc.charAt(11)+2*parseInt(dac)  
	resto = df % 11  
	dac += ( (resto <= 1) ? 0 : (11-resto) )  
	return (dac == cgc.substring(cgc.length-2,cgc.length))  
}  
 
// Gera uma string com os caracteres básicos na sequência de códigos ASC  
function makeCharsetString(){  
	var astr  
	astr = ' !"#$%&\'()*+,-./0123456789:;<=>?@'  
	astr+= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'  
	astr+= '[\]^_`abcdefghijklmnopqrstuvwxyz'  
	astr+= '{|}~'  
	return astr  
}  
 
 
//Remove todos os caracteres excetos 0-9  
function trimtodigits(tstring){  
	s="";  
	ts=new String(tstring);  
	for (x=0;x<ts.length;x++){  
		ch=ts.charAt(x);  
			if (asc(ch)>=48 && asc(ch)<=57){  
			s=s+ch;  
		}  
	}  
	return s;  
}  
 
// Retorna o código ASC do caracter passada por parâmetro  
function asc(achar){  
	var n=0;  
	var ascstr = makeCharsetString()  
	for(i=0;i<ascstr.length;i++){  
		if(achar==ascstr.substring(i,i+1)){  
			n=i;  
			break;  
		}  
	}  
	return n+32  
}  



/************************************************  
* function verificaCPF  
* Verifica se um CPF é válido  
* Input: cpf a ser verificado  
************************************************/  
 
function verificaCPF(xcpf){
	cpf=trimtodigits(xcpf)  
	if (cpf.length != 11) {
		return false;
	}
	else {
		var iSum = 0;
		var iResult, j, i;
		var nonpermit = new Array();
		
		nonpermit[01] = "11111111111";
		nonpermit[02] = "22222222222";
		nonpermit[03] = "33333333333";
		nonpermit[04] = "44444444444";
		nonpermit[05] = "55555555555";
		nonpermit[06] = "66666666666";
		nonpermit[07] = "77777777777";
		nonpermit[08] = "88888888888";
		nonpermit[09] = "99999999999";
		nonpermit[10] = "00000000000";
		
		for (var nIndex = 1; nIndex <= 10; nIndex++)
		{
			if (cpf == nonpermit[nIndex] )
			{
				return false;
			}
		}
	
		j = 10
		for (i=0; i<11; i++) {
			if (j > 1) {
				iSum += j * parseInt(cpf.substring(i,i+1));
			}
			j--;
		}

		iSum = iSum - (11 * parseInt((iSum / 11)));
		
		if (iSum == 0 || iSum == 1) {
			iResult = 0;
		}
		else {
			iResult = 11 - iSum;
		}
		
		if (parseInt(cpf.substring(9,10)) == iResult) {
			iSum = 0;
			j = 11;
			
			for (i=0;i<11;i++) {
				if (j > 1) {
					iSum += j * parseInt(cpf.substring(i,i+1));
				}
				j--;
			}
			
			iSum = iSum - (11 * parseInt((iSum / 11)));
			
			if (iSum == 0 || iSum == 1) {
				iResult = 0;
			}
			else {
				iResult = 11 - iSum;
			}
			
			if (iResult == parseInt(cpf.substring(10,11))) {
				return true;
			}
			else {
				return false;
			}
		}
		else {
			return false;
		}
	}
} 


//#####################################
//eventos e funções de formatação de dinheiro
//#####################################

function formatamoeda(valor,moeda,metodo) {  
	retorno="";  
	if (moeda==reais){retorno="R$ "}  
	if (moeda==dolares){retorno="US$ "}  
	if (metodo==aproximar){valor=valor+.005}

	retorno = ""

	if(valor<0){  
		retorno=retorno+"-";  
		valor=-valor};  
	if(valor<1){  
		casas=1  
	}else{  
		for( casas = 0 ; Math.pow(1000,casas) < valor; casas++){};};  
	strvalor=""+Math.floor(valor);  
	dif= strvalor.length;  
	dif=dif + 3- (casas*3);  
	retorno=retorno+strvalor.substring(0,dif);  
	for(x=0;x<=casas;x++){  
		if(x<casas-1){retorno=retorno+"."};  
		retorno=retorno+strvalor.substring((x*3)+dif,(x*3)+3+dif);};  
	retorno=retorno+",";  
	decimal=Math.floor((valor-Math.floor(valor))*100);  
	if (decimal<10){retorno=retorno+"0"};  
	retorno=retorno+decimal;  
	return retorno;  
}; 

function mfoco( e )
{
	obj = eval( sender );
	valor = obj.value;
	
	if( valor != 0 )
	{
		eval( "x" + obj.name + "=" + valor );
	}
	
	else
	{
		eval( "x" + obj.name + "=0" );
	}

	if( eval( "x" + obj.name ) != 0 )
	{
		obj.value = eval( "x" + obj.name );
	}
	
	else
	{
		obj.value = "";
	}
}

function mperde( e )
{
	obj = eval( sender );
	valor = obj.value;
	
	while( valor.indexOf( "0" ) == 0 )
	{
		valor = valor.substring( 1, 100 );
	}

	if( valor != 0 )
	{
		eval( "x" + obj.name + "=" + valor );
	}
	
	else
	{
		eval( "x" + obj.name + "=0" )
	}
	
	obj.value = formatamoeda( eval( "x" + obj.name), reais, truncar )
}
   

//VALIDACAO DE HORARIO  
function formatahora(hora) {  
	retorno	="";  
	strmin	="";

	if( hora.indexOf(":")!= -1 ) 
	{
		strmin = hora.substr(hora.indexOf(":")+1,hora.length - hora.indexOf(":")-1)
		
		if(strmin.length > 2)
		  {strmin = strmin.substring(0,2)}

		if(parseInt(strmin) > 59)
		  {strmin="59"}
		  
		retorno = hora.substr(0,hora.indexOf(":")) + ':' + strmin

		if(strmin.length == 1)
		  {retorno = retorno + '0'}
		  
		return retorno;
	}
	
	if(hora.length == 0)
		{hora = '00:00';}

	if(hora.length == 4)
		{hora = hora.substr(0,2)+':'+hora.substr(2,2) }

	if(hora.length == 6)
		{hora = hora.substr(0,2)+':'+hora.substr(2,2)+':'+hora.substr(4,2) }

	retorno = hora;
	return retorno;  

}; 

function hfoco( e )
{
	obj = eval( sender );
	valor = obj.value;
	
	if( valor.indexOf(':') != -1 )
	{
		if(parseInt(valor.substr(0,valor.indexOf(':'))) == 0 && parseInt(valor.substr(valor.indexOf(':')+1, valor.length - valor.indexOf(':') -1)) == 0)
		{valor = '';}
	}

	obj=eval(sender);
	obj.value=valor;
}

function hperde( e )
{
	obj=eval(sender)
	valor=obj.value
	
	obj.value = formatahora( valor ) ;
}

//#####################################
//eventos e funcoes de validacao de CEP, CGC e CPF
//#####################################

function cepfoco(e){
	obj=eval(sender)
	obj.value=trimtodigits(obj.value)
}
function cgcfoco(e){
	obj=eval(sender)
	obj.value=trimtodigits(obj.value)
}
function cpffoco(e){
	obj=eval(sender)
	obj.value=trimtodigits(obj.value)
}
function cgcoucpffoco(e){
	obj=eval(sender)
	obj.value=trimtodigits(obj.value)
}
function cepperde(e){
	obj=eval(sender)
	valor=obj.value
	if(valor.length==8){
		valor=valor.substr(0,5)+"-"+valor.substr(5,3)
		obj.value=valor
	}
}
function cgcperde(e){
	obj=eval(sender)
	valor=obj.value
	if(valor.length==14){
		valor=valor.substr(0,2)+"."+valor.substr(2,3)+"."+valor.substr(5,3)+"/"+valor.substr(8,4)+"-"+valor.substr(12,2)
		obj.value=valor
	}
}
function cpfperde(e){
	obj=eval(sender)
	valor=obj.value
	if(valor.length==11){
		valor=valor.substr(0,3)+"."+valor.substr(3,3)+"."+valor.substr(6,3)+"-"+valor.substr(9,2)
		obj.value=valor
	}
}
function cgcoucpfperde(e){
	obj=eval(sender)
	ovalor=obj.value
	if(ovalor.length==11){return cpfperde(e)}else{return cgcperde(e)}
}
function tudoMaiusculoperde(e)
{
	obj = eval( sender );
	obj.value = obj.value.toUpperCase();
}

//#####################################
//insere/remove o sinal de negatico de um campo
//#####################################

function inverte(a){
	valor=a.value
	if (valor.indexOf("-")==-1){
		a.value="-"+valor
	}else{
		a.value=valor.substr(1,100)
	}
}

//#####################################
//tratadores de teclas
//#####################################

function inteiro(e){
	alvo=eval(sender)
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	if (x>47 && x<58 || x==8){return true}else{return false}
}
function inteironegativo(e){
	alvo=eval(sender)
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	if (x>47 && x<58 || x==8){return true}else{
	if (x==45){setTimeout("inverte(alvo)",50)}
	return false}
}
function email(e){
	regra="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.@-_1234567890"
	alvo=eval(sender)
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	key=String.fromCharCode(x)
	if(regra.indexOf(key)==-1){return false}else{
	valor=alvo.value
	if(key=="@" && valor.indexOf("@")!=-1){return false}
	return true}
}
function tudo(e){
	return true
}

function onkeypress(){
	return true
}

function tudoMaiusculo(e){
	return true
}
function numero(e)
{
	obj = eval( sender );
	valor = obj.value;
	
	if ( document.all ) {
		x = event.keyCode;
	} else {
		x = e.which;
	}

	if( x == 44 )
	{
		if( document.all && valor.indexOf( "." ) == -1 )
		{
			event.keyCode = 46;
			return true;
		}
		
		else
		{
			window.status = STR0020; //"Use ponto como separador de centavos."
		}
	}
	
	if( x > 47 && x < 58 || x == 0 || x == 8 || ( x == 46 && valor.indexOf( "." ) == -1 ) )
	{
		if(x.length==4){
		obj.value = obj.value + ':';}
		return true;
	}
	
	else
	{
		return false;
	}
}

function negativo(e){
	obj=eval(sender)
	valor=obj.value;
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	if(x==45){setTimeout("inverte(obj)",50)}
	if(x==44){
		if(document.all && valor.indexOf(".")==-1){
			event.keyCode=46;
			return true
		}else{
		window.status=STR0020} //"Use ponto como separador de centavos."
	}
	if (x>47 && x<58 || x==8 || (x==46 && valor.indexOf(".")==-1)){return true}
	else{
		return false
	}
}
function cep(e){
	return inteiro(e)
}
function cgc(e){
	return inteiro(e)
}
function cpf(e){
	return inteiro(e)
}
function cgcoucpf(e){
	return inteiro(e)
}
function data(e){
	alvo=eval(sender)
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	if (x==8){return true}
	if(document.all){
		if (x>47 && x<58){
			x=x-48
			valor=alvo.value
			if (valor.length==0){
				if (x>3){alvo.value="0"}
			}
			if (valor.length==2){
				if (x>1){alvo.value+="/0"}else{alvo.value+="/"}
			}
			if (valor.length==5){
				if (x>3){alvo.value+="/19"}else{
					if (x>0){alvo.value+="/"}else{alvo.value+="/20"}
				}
			}
			return true
		}
	}else{
		if (x>46 && x<58){return true}
	}
	return false
}

//#####################################
//objeto xform
//#####################################

function xform(obj){
	this.form=obj
	this.campos=new Array
	this.total=0
	this.add=add
	obj.onsubmit=valida
	oForm = this;
}

//metodo para adicionar inputs

function add(campo,tipo,dinheiro,branco){
	oForm.campos[oForm.total++]=new xinput(campo,tipo,dinheiro,branco)
}

//#####################################
//objeto xinput
//#####################################
function xinput(campo,tipo,dinheiro,branco){
	this.campo=campo
	this.tipo=tipo
	this.dinheiro=dinheiro
	this.branco=branco
	if (tipo != 'onkeypress'){
		campo.onkeypress=eval(tipo)
	}
	
	if (dinheiro){
		eval( "x" + campo.name + "='"+ campo.value +"'" )
		campo.value=formatamoeda(eval("x"+campo.name),reais,truncar)
		campo.onfocus=mfoco
		campo.onblur=mperde
	}
	if (tipo=="horario"){
		eval( "x" + campo.name + "='"+ campo.value +"'" )
		campo.value=formatahora(eval("x"+campo.name))
		campo.onfocus=hfoco
		campo.onblur=hperde
	}	
	if (tipo=="cgc"){
		campo.onfocus=cgcfoco
		campo.onblur=cgcperde
	}
	if (tipo=="cpf"){
		campo.onfocus=cpffoco
		campo.onblur=cpfperde
	}
	if (tipo=="cgcoucpf"){
		campo.onfocus=cgcoucpffoco
		campo.onblur=cgcoucpfperde
	}
	if (tipo=="cep"){
		campo.onfocus=cepfoco
		campo.onblur=cepperde
	}
	if (tipo=="tudoMaiusculo"){
		campo.onfocus=tudoMaiusculo
		campo.onblur=tudoMaiusculoperde
	}                                     
}	
function Trim(s) 
{
  while ( ( s.substring( 0, 1 ) == ' ' ) || ( s.substring( 0, 1 ) == '\n' ) || ( s.substring( 0, 1 ) == '\r' ) )
  {
    s = s.substring(1,s.length);
  }

  while ( ( s.substring( s.length-1, s.length ) == ' ' ) || ( s.substring( s.length-1, s.length ) == '\n' ) || ( s.substring( s.length-1, s.length ) == '\r' ) )
  {
    s = s.substring( 0, s.length-1 );
  }
  return s;
}


function horario( e )
{
	obj = eval( sender );
	valor = obj.value;

	if ( document.all )
	{
		x = event.keyCode;
	}
	else
	{
		x = e.which;
	}


	if( (x > 47 && x < 59) || x == 8 ) //&& ( ( valor.indexOf(':') != -1 && valor.substr(valor.indexOf(':')+1,valor.length-valor.indexOf(':')-1).length < 3 ) || valor.indexOf(':') == -1 ) )
	{
		if(valor.length==4 && valor.indexOf(':') == -1){obj.value = obj.value + ':'}
		return true;
	}
	
	else
	{
		return false;
	}
} 


//FUNCAO QUE PERMITE APENAS ALFABETO E ESPACO - SEM ACENTUACAO
function permiteAlfabeto( e )
{
	if ( document.all )	{
		x = event.keyCode;
	}
	else{
		x = e.which;
	}
	if( x == 32 || (x > 64 && x < 91) || (x > 96 && x < 123) ) {
		return true;
	}
	else{               
		return false;
	} 
} 

function fChkJS( cData )
{
	if( cData != "20051017" )
	{
		return false;
	}
	else
	{
		return true;
	}
}

/************************************************************
Funcao	: Form
Autor	: Luiz Couto
Data	: 07/10/05
Desc.	: Formulario dinamico
Param.	: ExpO1: Objeto a ser utilizado como formulario
************************************************************/
function Form( oObjForm )
{
	this.form 			= oObjForm;
	this.campos 		= new Array();
	this.total			= 0;
	this.Add			= Add;
	oObjForm.onsubmit	= valida;
	oForm 				= this;
}

/************************************************************
Funcao	: Add
Autor	: Luiz Couto
Data	: 07/10/05
Desc.	: Adiciona os campos do formulario ao formulario
		  dinamico
Param.	: ExpO1: Campo do formulario
************************************************************/
function Add( oCampo, lObrigat )
{
	oForm.campos[oForm.total++] = new Input( oCampo, lObrigat );
}

/************************************************************
Funcao	: Input
Autor	: Luiz Couto
Data	: 07/10/05
Desc.	: Funcao para adicao do campo ao formulario dinamico
Param.	: ExpO1: Campo do formulario
************************************************************/
function Input( oCampo, lObrigat )
{
	this.campo 	= oCampo;
	this.branco = lObrigat;
}

/************************************************************
Funcao	: Picture
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Aplica picture ao campo
Param.	: ExpO1: Evento do campo
		  ExpO2: Campo
		  ExpS3: Picture
		  ExpC4: Tipo da Picture
		  ExpA5: Array de Buffer
************************************************************/
function Picture( evento, oTxt, sPict, cType, aBuffer )
{
	// Se for movimento de carro ou teclas sem ação não faço nada
	if( evento.keyCode == 9 || evento.keyCode == 16 || evento.keyCode == 17 || evento.keyCode == 18 || evento.keyCode == 35 || evento.keyCode == 36 || evento.keyCode == 37 || evento.keyCode == 39 || evento.keyCode == 45 )
	{
		return;
	}
	
	if( sPict.substr( 0, 1 ) == "@" )
	{
		if( sPict.substr( 1, 1 ) == "E" || sPict.substr( 1, 1 ) == "e" )
		{
			if( cType == 'N' )
			{
				SetPict_A_E_N( oTxt, sPict.substr( 3 ), aBuffer );
			}
		}           

		if( sPict.substr( 1, 1 ) == "D" || sPict.substr( 1, 1 ) == "d" )
		{
			SetPict_A_R_C( oTxt, sPict.substr( 3 ), aBuffer );
		}
 		else if( sPict.substr( 1, 1 ) == "R" || sPict.substr( 1, 1 ) == "r" )
		{
			if( cType == 'C' )
			{
				SetPict_A_R_C( oTxt, sPict.substr( 3 ), aBuffer );
			}
			else
			{
				//alert( "sPict: " + sPict +" oTxt: "+ oTxt +" cType: " + cType);
				if( cType == 'N' )
				{
					SetPict_A_E_N( oTxt, sPict.substr( 3 ), aBuffer );
				}
			}
		}
		else if( sPict.substr( 1, 1 ) == "!" )
		{
			oTxt.value = oTxt.value.toUpperCase();
		}
		else if( sPict.substr( 1, 1 ) == "S" )
		{
			SetPict_A_S_C( oTxt, sPict, aBuffer );
		}
	}
	else
	{
		SetPict_A_R_C( oTxt, sPict, aBuffer );
	}
}

/************************************************************
Funcao	: SetPict_A_R_C
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Aplica picture do tipo @R em dados carater
Param.	: ExpO1: Campo
		  ExpC2: Picture
		  ExpA3: Array de Buffer
************************************************************/
function SetPict_A_R_C( oTxt, sPict, aBuffer )
{
	var PosValidas 		= 0;
	var iSomaPosValidas = 0;
	var cTmp 			= "";
	var sRet 			= "";
	var iIdx 			= 0;
	var sTmpValid 		= "";
	var UltChar 		= oTxt.value.substr( oTxt.value.length - 1, 1 );
	var UltPos  		= oTxt.value.length-1;
	var isInsertUltChar = false;
 
	ClearPicture( oTxt, sPict, 'C' );

	for( var i = 0; i < sPict.length; i++ )
	{
		if( isCharTemplate( sPict.substr( i, 1 ) ) )
		{
			cTmp = oTxt.value.substr( iIdx, 1 );
			iIdx++;
			sRet += cTmp;
			
			if( cTmp == " " )
			{
				continue;
			}
 
			PosValidas += 1 + iSomaPosValidas;
			iSomaPosValidas = 0;
		}
		else
		{
			if( i == UltPos )
			{
				if( UltChar == sPict.substr( i , 1 ) )
				{
					isInsertUltChar = true;
				}
			}

			sRet += sPict.substr( i , 1 );
			iSomaPosValidas++;
		}
	}

	sTmpValid = ValidPicture( sRet, sPict );

	if( sTmpValid.length > 0 )
	{
		aBuffer[0] = ClearReturn( PosValidas, sTmpValid, 'C' );

		if( isInsertUltChar )
		{
			aBuffer[0] += UltChar;
		}
	}

	oTxt.value = aBuffer[0];
}

/************************************************************
Funcao	: SetPict_A_E_N
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Aplica picture do tipo @E em dados numericos
Param.	: ExpO1: Campo
		  ExpC2: Picture
		  ExpA3: Array de Buffer
************************************************************/
function SetPict_A_E_N( oTxt, sPict, aBuffer )
{
	var sRet 			= "";
	var iIdx 			= 0;
	var PosValidas 		= 0;
	var iSomaPosValidas = 0;
	var cTmp 			= "";
	var sTmpValid 		= "";
            
	ClearPicture( oTxt, sPict, 'N' );
	
	iIdx = sPict.length - 1;

	for( var i = iIdx; i >= 0; i-- )
	{
		if( isCharTemplate( sPict.substr( i, 1 ) ) )
		{
			cTmp = oTxt.value.substr( iIdx, 1 );
			iIdx--;
			sRet = cTmp + sRet;

			if( cTmp == " " )
			{
				continue;
			}
 
			PosValidas += 1 + iSomaPosValidas;
			iSomaPosValidas = 0;
		}
		else
		{
			sRet = sPict.substr( i , 1 ) + sRet;
			iSomaPosValidas++;
		}
	}
            
	sTmpValid = ValidPicture( sRet, sPict );

	if( sTmpValid.length > 0 )
	{
		aBuffer[0] = ClearReturn( PosValidas, sTmpValid, 'N' );
		// EM picture @E numérica, os pontos(.) e virgulas(,) são invertidos...
		// então troco um pelo outro
		aBuffer[0] = ReplaceAll(aBuffer[0], ".", "|" );
		aBuffer[0] = ReplaceAll(aBuffer[0], ",", "." );
		aBuffer[0] = ReplaceAll(aBuffer[0], "|", "," );
	}
	
	oTxt.value = aBuffer[0];
}
 
/************************************************************
Funcao	: SetPict_A_S_C
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Aplica picture do tipo @S em campos text
Param.	: ExpO1: Campo
		  ExpS2: Picture
		  ExpA3: Array de Buffer
************************************************************/
function SetPict_A_S_C( oTxt, sPict, aBuffer )
{
	oTxt.maxlength = sPict.substring( 2 );
}

/************************************************************
Funcao	: ValidPicture
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Valida os dados da picture
Param.	: ExpS1: String
		  ExpS2: Picture
************************************************************/
function ValidPicture( sStr, sPict )
{
	var cTmpP = '';
	var cTmpS = '';

	for( var i = 0; i < sPict.length; i++ )
	{
		cTmpP = sPict.substr( i, 1 );
		
		if( isCharTemplate( cTmpP ) )
		{
			cTmpS = sStr.substr( i, 1 );
			
			if( cTmpS == ' ' )
			{
				continue;
			}
			else if( cTmpP == '9' )
			{
				if( isNumber( cTmpS.charCodeAt( 0 ) ) )
				{
					continue;
				}
			}
			else if( cTmpP == 'A' )
			{
				if( isLetter( cTmpS.charCodeAt( 0 ), true ) )
				{
					continue;
				}
			}
			else if( cTmpP == 'X' )
			{
				continue;
			}
			else if( cTmpP == '!' )
			{
				if( isLetter( cTmpS.charCodeAt( 0 ), true ) )
				{
					sStr = sStr.substr( 0, i ) + cTmpS.toUpperCase() + sStr.substr( i+1 );
					continue;
				}
			}
			else
			{
				alert( "Invalid Char! -> [" + cTmpP + "]" );
			}
			
			return "";
		}
	}
	
	return sStr;
}
 
/************************************************************
Funcao	: isNumber
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Verifica se caracter é um número
Param.	: ExpC1: Caracter a ser verificado
************************************************************/
function isNumber( cChar )
{
	return ( cChar >= 48 && cChar <= 57 );
}
 
/************************************************************
Funcao	: isLetter
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Verifica se o caracter é uma letra
Param.	: ExpC1: Caracter a ser verificado
		  ExpB2: Acentua
************************************************************/
function isLetter( cChar, bAcento )
{
	if( bAcento )
	{
		return ( ( cChar >= 97 && cChar <= 122 ) || ( cChar >= 65 && cChar <= 90 ) || isCharAcentuado( cChar ) );
	}
	else
	{
		return ( ( cChar >= 97 && cChar <= 122 ) || ( cChar >= 65 && cChar <= 90 ) );
	}
}
 
/************************************************************
Funcao	: isCharAcentuado
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Verifica se caracter é acentuado, 
		  ç 231 à 224 á 225 é 233 í 237 ó 243 ú 250 ã 227 
		  õ 245 Ç 199 À 192 Á 193 É 201 Í 205 Ó 211 Ú 218 
		  Ã 195 Õ 213
Param.	: ExpC1: Caracter a ser verificado
************************************************************/
function isCharAcentuado( cChar )
{
	return ( cChar == 231 || cChar == 224 || cChar == 225 || cChar == 233 || cChar == 237 || cChar == 243 || cChar == 250 || cChar == 227 || cChar == 245 || cChar == 199 || cChar == 192 || cChar == 193 || cChar == 201 || cChar == 205 || cChar == 211 || cChar == 218 || cChar == 195 || cChar == 213 );
}
 
/************************************************************
Funcao	: isCharAcentuado
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Completa string com espaços ate o número de 
		  caracteres da picture
Param.	: ExpO1: Campo
		  ExpS2: Picture
		  ExpC3: Tipo da Picture
************************************************************/
function CompleteSpace( oTxt, sPict, cType )
{
	var iTmp = sPict.length - oTxt.value.length;
	var sTmp = "";

	for( var i = 0; i < iTmp; i++ )
	{
		sTmp += " ";
	}
            
	if( cType == 'N' )
	{
		oTxt.value = sTmp + oTxt.value;
	}
	else if( cType == 'C' )
	{
		oTxt.value = oTxt.value + sTmp;
	}
}
 
/************************************************************
Funcao	: isCharTemplate
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Verifica se caracter é um template de pictures
Param.	: ExpC1: Caracter a ser verificado
************************************************************/
function isCharTemplate( cChar )
{
	return ( cChar == '9' || cChar == 'A' || cChar == 'X' || cChar == '!' );
}
 
/************************************************************
Funcao	: ClearReturn
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Retorna apenas os dados ate o momento digitado pelo 
		  usuario
Param.	: ExpN1: Posicao de Validacao
		  ExpS2: String 
		  ExpC3: Tipo da Picture
************************************************************/
function ClearReturn( iPosValidas, sStr, cType )
{
	if( cType == 'N' )
	{
		return sStr.substr( sStr.length - iPosValidas );
	}
	else if( cType == 'C' )
	{
		return sStr.substr( 0, iPosValidas );
	}
}
 
/************************************************************
Funcao	: ClearPicture
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Retira do input todos os caracteres não template, 
		  para nova aplicação de picture
Param.	: ExpO1: Campo
		  ExpS2: Picture
		  ExpC3: Tipo da Picture
************************************************************/
function ClearPicture( oTxt, sPict, cType )
{
	if( cType == 'N' )
	{
		oTxt.value = ReplaceAll( oTxt.value, ".", "" );
		oTxt.value = ReplaceAll( oTxt.value, ",", "" );
	}
	else
	{
		for( var i = 0; i < sPict.length; i++ )
		{
			if( !isCharTemplate( sPict.substr( i, 1 ) ) )
			{
				oTxt.value = oTxt.value.replace( sPict.substr( i, 1 ), "" );
			}
		}
	}
	
	CompleteSpace( oTxt, sPict, cType );
}

/************************************************************
Funcao	: ClearPicture
Autor	: Alexandro Picolini
Data	: 06/10/05
Desc.	: Replace, mas inves de trocar apanas um caracter por outro, 
		  troca uma string por outra. Troca na string original inteira 
		  e nao apenas a primeira encontrada como a replace do javascript
Param.	: ExpO1: Campo
		  ExpS2: Procura
		  ExpC3: Troca
************************************************************/
function ReplaceAll( sTexto, sProcura, sTroca )
{
	var sRet = "";
	var iPos = 0;
 
	while( ( iPos = sTexto.indexOf( sProcura ) ) > -1 )
	{
		sTexto = sTexto.substring( 0, iPos ) + sTroca + sTexto.substring( ( iPos + sProcura.length ), sTexto.length );
	}
  
	return sTexto;
}
