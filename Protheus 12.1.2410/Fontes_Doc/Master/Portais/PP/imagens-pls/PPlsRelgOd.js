
// Limite de despesas por pagina lembrando que o contador começa da posição 0.
const nLimitador = 12;

window.onload = function() {


    var myParam = queryObj(); 
    var jObj = JSON.parse(myParam.data);

    var newNum = 1;
    var qtdPage = 0;
    var qtdProcedim = jObj.DespRealizados.length;
    var qtdNewPage = 0;
    var newAtributo = [
        "#cabecalho",
        "#contratado",
        "#tableDespesas",
        "#totais"
    ];

	
		
	/*----------------------------------------------
      Formatar imagens .
    -----------------------------------------------*/
	$('.print-guia-company-logo  img').replaceWith(function(i, v){
		return $('<div/>', {
			style: 'background-image: url(' + this.src + ');' + 
			'width:' + this.width + 'px;' + 
			'height:' + this.height + 'px;' ,
			class: 'fakeImg'
		})
	})

	
	
	/*----------------------------------------------
      Formatar valores .
   	 -----------------------------------------------*/

	for(var i=0; i< jObj.DespRealizados.length; i++){
		
		jObj.DespRealizados[i].retorno[0] =  jObj.DespRealizados[i].retorno[0].concat("-");
		jObj.DespRealizados[i].retorno[2] =  jObj.DespRealizados[i].retorno[2].replace(/(\d{2})(\d{2})(\d{4})/, "$1/$2/$3");
		jObj.DespRealizados[i].retorno[3] =  jObj.DespRealizados[i].retorno[3].replace(/(\d{2})(\d{2})/, "$1:$2");
		jObj.DespRealizados[i].retorno[4] =  jObj.DespRealizados[i].retorno[4].replace(/(\d{2})(\d{2})/, "$1:$2");
		jObj.DespRealizados[i].retorno[7] =  jObj.DespRealizados[i].retorno[7].replace(/(\d{1})(\d{4})$/,"$1,$2");		
		jObj.DespRealizados[i].retorno[9] =  formatMoeda(jObj.DespRealizados[i].retorno[9]);
		jObj.DespRealizados[i].retorno[10] =  formatMoeda(jObj.DespRealizados[i].retorno[10]);
		jObj.DespRealizados[i].retorno[11] =  formatMoeda(jObj.DespRealizados[i].retorno[11]);
	}

    /*----------------------------------------------
      Qtd total de paginas de acordo com limitador.
	 -----------------------------------------------*/
    if (qtdProcedim > nLimitador) {

        nCntPro = qtdProcedim;
        while (nCntPro > nLimitador) {
            qtdNewPage++;
            nCntPro = nCntPro - nLimitador;
        }
    }else{qtdNewPageP = 0;}

    /*-------------------------------
     Cria novas paginas .
	 --------------------------------*/
    createNewPages(qtdNewPage);

    // Quantidade de paginas
    qtdPage = document.getElementsByClassName('pagePrincipal').length

    // atribui informações para a pagina principal
    setAttributes(["#page"], qtdPage);

    // atribui informações da estrutura para nova pagina
    copyStructure(qtdNewPage);

    // atribui informações para quebra de pagina.
    createNewDiv(qtdPage);

    // incluir novos atributos
    setAttributes(newAtributo, qtdPage);


    /*------------------------------------
     Criação dos campos dinamico.
	 -------------------------------------*/
    cabecalho(jObj, qtdPage);
    contratado(jObj, qtdPage);
    despesas(jObj, qtdPage);
    totais(jObj, qtdPage);

};



function createField(width, height, title, value, border, colored) {
    if (border == undefined) {
        border = true
    }
    if (colored == undefined) {
        colored = false
    }
    var field = document.createElement('div');
    field.className = "print-guia-field-container";
    field.style.backgroundColor = colored ? "#c0c0c0" : "white"; // cor do fundo das celulas
    field.style.border = border ? "1px solid" : "none";
    field.style.height = height + "px";
    field.style.width = width + "px";

    var titleSpan = document.createElement('span');
    titleSpan.className = "print-guia-field-title";
    titleSpan.innerHTML = title;

    var contentSpan = document.createElement('span');
    contentSpan.className = "print-guia-field-content";
    contentSpan.innerHTML = value ? value : "";

    field.appendChild(titleSpan);
    field.appendChild(contentSpan);

    return field;
}



function cabecalho(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var cabecalho = document.getElementById('cabecalho' + nTopo);
        cabecalho.appendChild(createField("228", "29", "1 - Registro ANS", jsonObject.RegistroANS));
        cabecalho.appendChild(createField("859", "29", "2 - Numero da Guia Referenciada", jsonObject.NrGuiaRef));
        nTopo++;
    }
}



function contratado(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var beneficiario = document.getElementById('contratado' + nTopo);
        beneficiario.appendChild(createField("249", "29", "3 - Codigo na Operadora", jsonObject.CodOperadora));
        beneficiario.appendChild(createField("642", "29", "4 - Nome do Contratado", jsonObject.NomeContratado));
        beneficiario.appendChild(createField("191", "29", "5 - Codigo CNES", jsonObject.CodCNES));
        nTopo++;
    }
}



function despesas(jsonObject, qtdPage) {

    var attribute = "id";
    var attributeName = "idDes";
    var tamanho = jsonObject.DespRealizados.length;
    var nTopo = 1;
	var ncontLinha = 11;
	var ncontLinDesp = 12;
    var aArrays;
    var Itens;
	var ndiv = 0;
	var nDesp = 0;
	var nCab = 0;
    var ndivCab = 0;		
    var obj;
	var despDescri;
    var nQtdAlocada = 0;
    var cabecalho = ["","6-CD",
        "7-Data",
        "8-Hora Inicial",
        "9-Hora Final",
        "10-Tabela",
        "11-Codigo do Item",
        "12-Qtde.",
        "13-Unidade de Medida",
        "14-Fator Red/Acresc",
        "15-Valor Unitario R$",
        "16-Valor Total R$"
    ];

    for (var j = 0; j < qtdPage; j++) {
        aArrays = [cabecalho];
        for (var xy = nQtdAlocada; xy < tamanho; xy++) {
            obj = jsonObject.DespRealizados[xy];
            if (!(xy > ncontLinha)) {
                for (var key in obj) {
                    Itens = obj[key];
                    aArrays.push(Itens);
                }
            }
            if (xy >= ncontLinha) {
                ncontLinha += nLimitador;
                break;
            }
        }
	
		document.getElementById("tableDespesas" + nTopo).appendChild(createTable(aArrays, attribute, attributeName, j , nQtdAlocada ));
		var nodeCabecalho = document.createElement("div");
		nodeCabecalho.setAttribute("id", "divCabecalho" + j);
		nodeCabecalho.setAttribute("class", "divCabecalho");
		document.getElementById("subCabecalho" + j).appendChild(nodeCabecalho);
		
		// Cabecalho registro ANVISA do Material
		var RegAnvCabe = document.createElement("div");
		RegAnvCabe.setAttribute("id", "RegAnvCabe");
		RegAnvCabe.setAttribute("class", "table-cell");
		var textnode = document.createTextNode("17-Registro ANVISA do Material");
		RegAnvCabe.appendChild(textnode);
		document.getElementById("divCabecalho" + j).appendChild(RegAnvCabe);
							   
		// Cabecalho referência do material no fabricante
		var RefMatCabe = document.createElement("div");
		RefMatCabe.setAttribute("id", "RefMatCabe");
		RefMatCabe.setAttribute("class", "table-cell");
		var textnode = document.createTextNode("18-Referencia do material no fabricante");
		RefMatCabe.appendChild(textnode);
		document.getElementById("divCabecalho" + j).appendChild(RefMatCabe);
										 
		// Cabecalho autorizacao de Funcionamento
		var AutFunCabe = document.createElement("div");
		AutFunCabe.setAttribute("id", "AutFunCabe");
		AutFunCabe.setAttribute("class", "table-cell");
		var textnode = document.createTextNode("19-N\272 Autorizacao de Funcionamento");
		AutFunCabe.appendChild(textnode);
		document.getElementById("divCabecalho" + j).appendChild(AutFunCabe);
		
		 nDesp = nQtdAlocada;
	    (nQtdAlocada != 0) ? nDesp++: nDesp;
		
		for (var xg = 0; xg < aArrays.length; xg++) {	
			if(xg > 0){
				var nodeDesp = document.createElement("div");
				nodeDesp.setAttribute("id", "divTabela" + nDesp);
				nodeDesp.setAttribute("class", "divTabela");
				document.getElementById("subDespesas" + nDesp).appendChild(nodeDesp);

				//Registro ANVISA do Material
				var nodeRegAnv = document.createElement("div");
				nodeRegAnv.setAttribute("id", "RegAnv");
				nodeRegAnv.setAttribute("class", "table-cell");
				var textnode = document.createTextNode(aArrays[xg][12]);
				nodeRegAnv.appendChild(textnode);
				document.getElementById("divTabela" + nDesp).appendChild(nodeRegAnv);
				
				//Referência do material no fabricante
				var nodeRefMat = document.createElement("div");
				nodeRefMat.setAttribute("id", "RefMat");
				nodeRefMat.setAttribute("class", "table-cell");
				var textnode = document.createTextNode(aArrays[xg][13]);
				nodeRefMat.appendChild(textnode);
				document.getElementById("divTabela" + nDesp).appendChild(nodeRefMat);
				
				//Autorizacao de Funcionamento
				var nodeAutFun = document.createElement("div");
				var br = document.createElement("br");
				nodeAutFun.setAttribute("id", "AutFun");
				nodeAutFun.setAttribute("class", "table-cell");
				var textnode = document.createTextNode(aArrays[xg][14]);
				nodeAutFun.appendChild(textnode);
				if(textnode.data == ""){
					nodeAutFun.appendChild(br);
				}
				document.getElementById("divTabela" + nDesp).appendChild(nodeAutFun);
				nDesp++;
				
				if (xg >= ncontLinDesp) {
					ncontLinDesp += nLimitador;
					break;
				}
					
			 }
	    }
			
        aArrays = [];
        nQtdAlocada = xy + 1;
        nTopo++;
    }

}



function totais(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var totais = document.getElementById("totais" + nTopo);
        totais.appendChild(createField("150", "29", "21 - Total de Gases Medicinais (R$) ", jsonObject.TotalGasesMed));
        totais.appendChild(createField("151", "29", "22 - Total de Medicamentos (R$) ", jsonObject.TotalMedicam));
        totais.appendChild(createField("153", "29", "23 - Total de Materiais (R$) ", jsonObject.TotalMateriais));
        totais.appendChild(createField("153", "29", "24 - Total de OPME (R$) ", jsonObject.TotalOPME));
        totais.appendChild(createField("152", "29", "25 - Total de Taxas e Alugueis (R$) ", jsonObject.TotalTaxa));
        totais.appendChild(createField("151", "29", "26 - Total de Diarias (R$) ", jsonObject.TotalDiarias));
        totais.appendChild(createField("150", "29", "27 - Total Geral (R$) ", jsonObject.TotalGeral));
        nTopo++;
    }

}



function exportPdf() {
  		
	 kendo.drawing.drawDOM($(".content"), {
		forcePageBreak: ".page-break",
		scale: 0.69
	}).then(function(group) {

		return kendo.drawing.exportPDF(group, {
			paperSize: "auto",
			margin: { left: "1cm", top: "1cm", right: "1cm", bottom: "1cm" }
		});
	})
	.done(function(data) {
		kendo.saveAs({
			dataURI: data,
			fileName: "Guias_Outras_Despesas",
			proxyURL: "PPlsRelgOd.html"
		});
	});
			
}



function queryObj() {
    var result = {},
        keyValuePairs = location.search.slice(1).split("&");
    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[decodeURIComponent(keyValuePair[0])] = decodeURIComponent(keyValuePair[1]) || '';
    });


    return result
}



function createTable(conteudo, objAtrib, objAtribName, nCab, nDesp) {
   
	var nTam = 0;									 
	var tr;
	var br;
	var tmp;
	var valor;
	var texto;
	var Descri = "20-Descricao:\xa0\xa0\xa0";
	var tabela = document.createElement("table");
    var thead = document.createElement("thead");
    var tbody = document.createElement("tbody");
    var thd = function(i) {
        return (i == 0) ? "th" : "td";
    };
	
	(nDesp != 0) ? nDesp++: nDesp;

    for (var i = 0; i < conteudo.length; i++) {
        tr = document.createElement("tr");
		if(i >= 1){
			 nTam = conteudo[i].length - 4;
		}else{
			 nTam = conteudo[i].length
		}
		   for (var j = 0; j < nTam; j++) {
				tmp = document.createElement(thd(i));
				texto = document.createTextNode(conteudo[i][j]);
				tmp.appendChild(texto);
				tr.appendChild(tmp);
			}

			(i == 0) ? thead.appendChild(tr): tbody.appendChild(tr);
			
			if(i == 0){
				tr = document.createElement("tr");
				tmp = document.createElement(thd(i+1));																	  					      
				tmp.setAttribute("colspan", "13");
				tmp.setAttribute("id", "subCabecalho" + nCab);		   
				tr.appendChild(tmp);
				
			}	
			
			if(i>=1 ){
				tr = document.createElement("tr");
				tmp = document.createElement(thd(i+1));	
				tmp.setAttribute("colspan", "13");
				tmp.setAttribute("id", "subDespesas" + nDesp++);
				tr.appendChild(tmp);
				
			}							
			(i == 0) ? thead.appendChild(tr): tbody.appendChild(tr);
			if(i>=1 ){
				tr = document.createElement("tr");
				tmp = document.createElement(thd(i+1));
				valor = Descri  + conteudo[i][15];
				texto = document.createTextNode(valor);
				tmp.appendChild(texto);
				tmp.setAttribute("colspan", "13");
				tmp.setAttribute("id","despDescri");
				tmp.setAttribute("class","despDescri");
				tr.appendChild(tmp);
			}
			(i == 0) ? thead.appendChild(tr): tbody.appendChild(tr);
    }
    tabela.appendChild(thead);
    tabela.appendChild(tbody);

    if (!isObjectEmpty(objAtrib)) {
        setAtributoTable(thead, objAtrib, objAtribName);
    }
	

    return tabela;
}



function setAtributoTable(obj, objAtrib, objAtribName) {

    var objvalue = obj.childNodes[0].children;
    var nCnt = 0;

    if (!isObjectEmpty(objvalue)) {
        for (var y = 0; y < objvalue.length; y++) {
            objvalue[y].setAttribute(objAtrib, objAtribName + nCnt);
            nCnt++;
        }
    }

}



function isObjectEmpty(obj) {
    for (var x in obj) {
        return false;
    }
    return true;
}



function createNewPages(qtdNewPage) {

    for (var i = 0; i < qtdNewPage; i++) {
        var newPages = document.createElement("page");
        var pagesActual = document.getElementById('page');
        var parentPage = pagesActual.parentNode;

        // new pages	
        newPages.setAttribute('id', 'page');
        newPages.setAttribute('size', 'A4');
        newPages.setAttribute('layout', 'landscape');
        newPages.setAttribute('class', 'pagePrincipal');
        parentPage.insertBefore(newPages, pagesActual.nextSibling);
    }
}



function createNewDiv(qtdPage) {

    var divActual = "";
    var parentDiv = "";
    var newDiv = "";
    var newVlr = 1;

    for (var i = 0; i < qtdPage - 1; i++) {

        divActual = document.getElementById('page' + newVlr);
        parentDiv = divActual.parentNode;
        newDiv = document.createElement("div");

        // new div	
        newDiv.setAttribute('id', 'break' + newVlr);
        newDiv.setAttribute('class', 'page-break');
        parentDiv.insertBefore(newDiv, divActual.nextSibling);
        newVlr++
    }
}



function setAttributes(objAttrib, qtdPage) {

    var newNum = 1;
    for (var i = 0; i < objAttrib.length; i++) {
        if (!isObjectEmpty(objAttrib[i])) {
            $(objAttrib[i]).each(function() {
                for (var j = 0; j < qtdPage; j++) {
                    $(objAttrib[i]).prop('id', objAttrib[i].replace(/\W/g, "") + newNum++);
                }
            });
            newNum = 1;
        }
    }
}



function copyStructure(qtdNewPage) {

    var prox = 1;
    for (var i = 0; i < qtdNewPage; i++) {
        $(document).ready(function() {
            prox++;
            $("#page" + prox).append($("#page1").html());
        });
    }
}


function formatMoeda(x){
     x = x.replace(/\D/g,"");//Remove tudo o que não é dígito
     x = x.replace(/(\d)(\d{8})$/,"$1.$2");//coloca o ponto dos milhões
     x = x.replace(/(\d)(\d{5})$/,"$1.$2");//coloca o ponto dos milhares
     x = x.replace(/(\d)(\d{2})$/,"$1,$2");//coloca a virgula antes dos 2 últimos dígitos
   return x;
}
