function DateMask(inputData, e){

	if(document.all)
   	   var tecla = event.keyCode;    // Internet Explorer
	else 			
 	   var tecla = e.which; 		 // Outros Browsers


	if(tecla >= 47&&tecla < 58){     // números de 0 a 9 e "/"
       var data = inputData.value;
			
	if (data.length == 2 || data.length == 5){
		data += '/';
		inputData.value = data;}
	}else  
        // Backspace, Delete e setas direcionais
        //(para mover o cursor, apenas para FF)
        if(tecla == 8 || tecla == 0) 
           return true;
	    else
		   return false;
		   
}

function DateValid(campo,valor,tipocompdatasys) {
	var dataval=valor;
	if (dataval==''){
	   return true;
	}
			
	var ardt   = new Array;
	var ExpReg = new RegExp("(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/[12][0-9]{3}");
	ardt       = dataval.split("/");
	erro       = false;
			
	if (dataval.search(ExpReg)==-1){
		erro = true;
	} else {
	     if (((ardt[1]==4)||(ardt[1]==6)||(ardt[1]==9)||(ardt[1]==11))&&(ardt[0]>30)) {
				erro = true;
		 } else 
		   if (ardt[1]==2) {
				if ((ardt[0]>28)&&((ardt[2]%4)!=0))
					erro = true;
				if ((ardt[0]>29)&&((ardt[2]%4)==0))
					erro = true;
			}
	}
		   
	if (erro) {
		//alert('<%=STR0018%>');

		//alert("\"" + valor + "\" +" " +'<%=STR0018%>');
		campo.focus();
		campo.value = "";
		return false;
	}


	if (tipocompdatasys!=''){
 		if (DateSys(valor,tipocompdatasys)) {
		 	return true;
		}
		else
		{
			campo.focus();
			campo.value = "";
		 	return false;
		}
	}


	return true;
	
}

function DateSys(datapar1,tipocomp) {

	var data1 = datapar1;

	var today = new Date();
	var dd 	  = today.getDate();
	var mm 	  = today.getMonth()+1;
	var yyyy  = today.getFullYear();

	if (mm < 10){
		mm = "0" +mm;
	}
	var data2 = dd +"/" +mm +"/" +yyyy; 

	if (tipocomp=='=')
	{
		if ( parseInt( data2.split( "/" )[2].toString() + data2.split( "/" )[1].toString() + data2.split( "/" )[0].toString() ) == parseInt( data1.split( "/" )[2].toString() + data1.split( "/" )[1].toString() + data1.split( "/" )[0].toString() ) )
		{
			alert('<%=STR0019%>');
        	return false;
		}
	}

	if (tipocomp=='>')
	{
		if ( parseInt( data2.split( "/" )[2].toString() + data2.split( "/" )[1].toString() + data2.split( "/" )[0].toString() ) > parseInt( data1.split( "/" )[2].toString() + data1.split( "/" )[1].toString() + data1.split( "/" )[0].toString() ) )
		{
			alert('<%=STR0020%>');
        	return false;
		}
	}

	if (tipocomp=='<')
	{
		if ( parseInt( data2.split( "/" )[2].toString() + data2.split( "/" )[1].toString() + data2.split( "/" )[0].toString() ) < parseInt( data1.split( "/" )[2].toString() + data1.split( "/" )[1].toString() + data1.split( "/" )[0].toString() ) )
		{
			alert('<%=STR0021%>');
        	return false;
		}
	}


	return true;

}

function numdias(mes,ano) {
    if((mes<8 && mes%2==1) || (mes>7 && mes%2==0)) return 31;
	   if(mes!=2)   return 30;
	   if(ano%4==0) return 29;
	   return 28;
}
	
function somaDias(txtData, diasQtd) {
          
	if (diasQtd==''){
	   return;
	}

    // Criado obj Date, pegar o campo txtData e aplicar o split("/") e depois reverse() 
    // para deixar ela em padrão americanos YYYY/MM/DD, em seguida eu coloco por barras "/"
    // com o join, depois em milisegundos multiplicar um dia (86400000 milisegundos)
    // pelo número de dias que deseja somar.
    var d = new Date();
    d.setTime(Date.parse(txtData.split("/").reverse().join("/"))+(86400000*(diasQtd)))

    var DataFinal;

    // Comparar o dia no objeto d.getDate().            
    if(d.getDate() < 10) {
      // Se o dia for menor que 10 eu coloca o zero no inicio, transformar em string
      // com o toString() para o zero ser reconhecido como uma string e não como um número.
       DataFinal = "0"+d.getDate().toString();
    }
    else {    
	   DataFinal = d.getDate().toString();    
    }
        
	// Aqui, já com a soma do mês, vejo se é menor do que 10
    // se for coloco o zero ou não.
    if((d.getMonth()+1) < 10){
        DataFinal += "/0"+(d.getMonth()+1).toString()+"/"+d.getFullYear().toString();
	}
    else {
       	DataFinal += "/"+((d.getMonth()+1).toString())+"/"+d.getFullYear().toString();
	}

    document.formFerias.txtdtFinal.value = DataFinal;
    return;    
		  
}
