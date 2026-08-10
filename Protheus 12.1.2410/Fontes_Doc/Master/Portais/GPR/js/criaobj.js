//#####################################
//mensagens de erro customizáveis
//#####################################

mensagens=new Array()
mensagens[1]="Email inválido."
mensagens[2]="CPF inválido."
mensagens[3]="CGC inválido."
mensagens[4]="CGC/CPF inválido."
mensagens[5]="Data inválida."
mensagens[6]="Campo obrigatório não preenchido."


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

function valida(){
	obj=this.parent
	ixx=obj.campos
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
			if(ixx[y].campo.value==""){
				alert(mensagens[6])
				ixx[y].campo.focus()
				return false
			}
		}
	}
	for(y=0;y<obj.total;y++){
		if (ixx[y].dinheiro){ixx[y].campo.value=eval("x"+ixx[y].campo.name)};
		if (ixx[y].tipo=="cgc" || ixx[y].tipo=="cpf" || ixx[y].tipo=="cgcoucpf" || ixx[y].tipo=="cep"){
		ixx[y].campo.value=trimtodigits(ixx[y].campo.value)}
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
	var dac = "", inicio = 2, fim = 10, soma, digito, i, j  
	for (j=1;j<=2;j++) {  
		soma = 0  
		for (i=inicio;i<=fim;i++) {  
			soma += parseInt(cpf.substring(i-j-1,i-j))*(fim+1+j-i)  
		}  
		if (j == 2) { soma += 2*digito }  
		digito = (10*soma) % 11  
		if (digito == 10) { digito = 0 }  
		dac += digito  
		inicio = 3  
		fim = 11  
	}  
	return (dac == cpf.substring(cpf.length-2,cpf.length))  
}  


//#####################################
//eventos e funções de formatação de dinheiro
//#####################################

function formatamoeda(valor,moeda,metodo) {  
	retorno="";  
	if (moeda==reais){retorno="R$ "}  
	if (moeda==dolares){retorno="US$ "}  
	if (metodo==aproximar){valor=valor+.005}  
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
function mfoco(e){
	obj=eval(sender)
	if(eval("x"+obj.name)!=0){
		obj.value=eval("x"+obj.name)
	}else{
		obj.value=""
	}
}
function mperde(e){
	obj=eval(sender)
	valor=obj.value
	while(valor.indexOf("0")==0){
		valor=valor.substring(1,100)
	}
	if(valor!=0){
		eval("x"+obj.name+"="+valor)}
	else{
		eval("x"+obj.name+"=0")}
	obj.value=formatamoeda(eval("x"+obj.name),obj.id,truncar)
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
function numero(e){
	obj=eval(sender)
	valor=obj.value;
	if (document.all){
		x=event.keyCode;
	}else{
		x=e.which
	}
	if(x==44){
		if(document.all && valor.indexOf(".")==-1){
			event.keyCode=46;
			return true
		}else{
		window.status="Use ponto como separador de centavos."}
	}
	if (x>47 && x<58 || x==8 || (x==46 && valor.indexOf(".")==-1)){return true}
	else{
		return false
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
		window.status="Use ponto como separador de centavos."}
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
	obj.parent=this
}

//metodo para adicionar inputs

function add(campo,tipo,dinheiro,branco,nmoeda){
	this.campos[this.total++]=new xinput(campo,tipo,dinheiro,branco,nmoeda)
}

//#####################################
//objeto xinput
//#####################################
function xinput(campo,tipo,dinheiro,branco,nmoeda){
	this.campo=campo
	this.tipo=tipo
	this.dinheiro=dinheiro
	this.branco=branco
	this.nmoeda=nmoeda
	campo.onkeypress=eval(tipo)
	if (dinheiro){
		eval("x"+campo.name+"="+campo.value);
		campo.value=formatamoeda(eval("x"+campo.name),nmoeda,truncar);
		campo.id=nmoeda;
		campo.onfocus=mfoco;
		campo.onblur=mperde;
	}
	if (tipo=="cgc"){
		campo.onfocus=cgcfoco;
		campo.onblur=cgcperde;
	}
	if (tipo=="cpf"){
		campo.onfocus=cpffoco;
		campo.onblur=cpfperde;
	}
	if (tipo=="cgcoucpf"){
		campo.onfocus=cgcoucpffoco;
		campo.onblur=cgcoucpfperde;
	}
	if (tipo=="cep"){
		campo.onfocus=cepfoco;
		campo.onblur=cepperde;
	}
}
