
// Limite de procedimentos por pagina ou procedimentos.
const nLimitador = 8;

window.onload = function() {


    var myParam = queryObj(); 
    var jObj = JSON.parse(myParam.data);

    var newNum = 1;
    var qtdPage = 0;
    var qtdProcedim = jObj.ProcRealizados.length;
    var qtdIdentEquipe = jObj.IdentEquipe.length;
    var qtdNewPage = 0;
    var qtdNewPageP = 0;
    var qtdNewPageI = 0;
    var newAtributo = [
        "#topo",
        "#cabecalho",
        "#beneficiario",
        "#contratado",
        "#internacao",
        "#tableProcedimento",
        "#tableIdentificacao",
        "#totais",
        "#assinaturas",
        "#observacao"
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
	for(var i=0; i< jObj.ProcRealizados.length; i++){
		
		jObj.ProcRealizados[i].retorno[0] =  jObj.ProcRealizados[i].retorno[0].replace(/(\d{2})(\d{2})(\d{4})/, "$1/$2/$3");
		jObj.ProcRealizados[i].retorno[1] =  jObj.ProcRealizados[i].retorno[1].replace(/(\d{2})(\d{2})/, "$1:$2");
		jObj.ProcRealizados[i].retorno[2] =  jObj.ProcRealizados[i].retorno[2].replace(/(\d{2})(\d{2})/, "$1:$2");
		jObj.ProcRealizados[i].retorno[9] =  formatMoeda(jObj.ProcRealizados[i].retorno[9]);
		jObj.ProcRealizados[i].retorno[10] =  formatMoeda(jObj.ProcRealizados[i].retorno[10]);
		jObj.ProcRealizados[i].retorno[11] =  formatMoeda(jObj.ProcRealizados[i].retorno[11]);
	}
	
	
	
	
    /*----------------------------------------------
      Qtd total de paginas de acordo com limitador.
	 -----------------------------------------------*/
    if (qtdProcedim > nLimitador) {

        nCntPro = qtdProcedim;
        while (nCntPro > nLimitador) {
            qtdNewPageP++;
            nCntPro = nCntPro - nLimitador;
        }
    }

    if (qtdIdentEquipe > nLimitador) {
        nCntIden = qtdIdentEquipe;
        while (nCntIden > nLimitador) {
            qtdNewPageI++;
            nCntIden = nCntIden - nLimitador;
        }
    }

    if ((qtdProcedim || qtdIdentEquipe) > nLimitador) {
        if (qtdNewPageP > qtdNewPageI) {
            qtdNewPage = qtdNewPageP;
        } else {
            qtdNewPage = qtdNewPageI;
        }
    }

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
    topo(jObj, qtdPage);
    cabecalho(jObj, qtdPage);
    beneficiario(jObj, qtdPage);
    contratado(jObj, qtdPage);
    internacao(jObj, qtdPage);
    procedimentos(jObj, qtdPage);
    identificacao(jObj, qtdPage);
    totais(jObj, qtdPage);
    assinaturas(jObj, qtdPage);
    observacao(jObj, qtdPage);

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



function topo(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var topo = document.getElementById('topo' + nTopo);
        topo.appendChild(createField("186", "10", "", "2 - Nª Guia no Prestador" + " " + jsonObject.NrPrestador, border = false));
        nTopo++;
    }
}



function cabecalho(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var cabecalho = document.getElementById('cabecalho' + nTopo);
        cabecalho.appendChild(createField("230", "29", "1 - Registro ANS", jsonObject.RegistroANS));
        cabecalho.appendChild(createField("864", "29", "3 - Numero da Guia de Solicitacao de Internacao", jsonObject.NrGuiaSolic));   
        cabecalho.appendChild(createField("182", "29", "4 - Data da Autorizacao", jsonObject.DtAutorizacao));
        cabecalho.appendChild(createField("330", "29", "5 - Senha", jsonObject.Senha));
        cabecalho.appendChild(createField("182", "29", "6 - Data da Validade da Senha", jsonObject.DtValSenha));
        cabecalho.appendChild(createField("390", "29", "7 - Numero da Guia Atribuida pela Operadora", jsonObject.NrGuiaOperadora));  
        nTopo++;
    }
}



function beneficiario(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var beneficiario = document.getElementById('beneficiario' + nTopo);
        beneficiario.appendChild(createField("350", "29", "8 - Numero da Carteira", jsonObject.NrCarteira));
        beneficiario.appendChild(createField("100", "29", "9 - Validade da Carteira", jsonObject.validCarteira));
        beneficiario.appendChild(createField("399", "29", "10 - Nome", jsonObject.Nome));
        beneficiario.appendChild(createField("150", "29", "11 - Cartao Nacional de Saude", jsonObject.CarteiraNacionalSaude));
        beneficiario.appendChild(createField("80", "29", "12 - Atendimento a RN", jsonObject.AtendRN));
        nTopo++;
    }
}



function contratado(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var contratado = document.getElementById('contratado' + nTopo);
        contratado.appendChild(createField("225", "29", "13 - Codigo na Operadora", jsonObject.CodOperadora));
        contratado.appendChild(createField("728", "29", "14 - Nome do Contratado", jsonObject.NomeContratado));
        contratado.appendChild(createField("136", "29", "15 - Codigo CNES", jsonObject.CodCNES));
        nTopo++;
    }

}



function internacao(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var internacao = document.getElementById('internacao' + nTopo);
        internacao.appendChild(createField("125", "29", "16 - Carater do Atendimento ", jsonObject.CaraterAtend));
        internacao.appendChild(createField("110", "29", "17 - Tipo de Faturamento", jsonObject.TpFaturamento));
        internacao.appendChild(createField("152", "29", "18 - Data do Inicio do Faturamento", jsonObject.DtIniFat));
        internacao.appendChild(createField("152", "29", "19 - Hora do Inicio do Faturamento", jsonObject.HrIniFat));
        internacao.appendChild(createField("150", "29", "20 - Data do Fim do Faturamento", jsonObject.DtFimFat));
        internacao.appendChild(createField("150", "29", "21 - Hora do Fim do Faturamento", jsonObject.HrFimFat));
        internacao.appendChild(createField("109", "29", "22 - Tipo de Internacao", jsonObject.TpInternacao));  
        internacao.appendChild(createField("115", "29", "23 - Regime de Internacao", jsonObject.RgInternacao));
        internacao.appendChild(createField("94", "29", "24 - CID10Principal (Opcional)", jsonObject.Cid10Principal, true, true));
        internacao.appendChild(createField("76", "29", "25 - CID10(2) (Opcional)", jsonObject.Cid102, true, true));
        internacao.appendChild(createField("76", "29", "26 - CID10(3) (Opcional)", jsonObject.Cid103, true, true));
        internacao.appendChild(createField("76", "29", "27 - CID10(4)(Opcional)", jsonObject.Cid104, true, true));
        internacao.appendChild(createField("179", "29", "28 - Indicacao de Acidente (acidente ou doenca relacionada)", jsonObject.IndAcindente));
        internacao.appendChild(createField("134", "29", "29 - Motivo de Encerramento da Internacao", jsonObject.MotEncInternacao));
        internacao.appendChild(createField("130", "29", "30 - Numero da declaracao de nascido vivo", jsonObject.NrNascVivo));
        internacao.appendChild(createField("89", "29", "31 - CID10 Obito(Opcional)", jsonObject.Cid10Obito, true, true));
        internacao.appendChild(createField("115", "29", "32 - Numero da declaracao de obito", jsonObject.NrObito));
        internacao.appendChild(createField("84", "29", "33 - Indicador D.O. de RN", jsonObject.IndDoRN));     
        nTopo++;
    }
}



function procedimentos(jsonObject, qtdPage) {

    var attribute = "id";
    var attributeName = "idProc";
    var tamanho = jsonObject.ProcRealizados.length;
    var nTopo = 1;
    var aArrays;
    var Itens;
    var obj;
    var ncontLinha = 7;
    var nQtdAlocada = 0;
    var cabecalho = ["34-Data",
        "35-Hora Inicial",
        "36-Hora Final",
        "37-Tabela",
        "38-Codigo do Procedimento",
        "39-Descricao",
        "40-Qtde.",
        "41-Via",
        "42-Tec",
        "43-Fator Red/Acresc",
        "44-Valor Unitario(R$)",
        "45-Valor Total(R$)"
    ];

    for (var j = 0; j < qtdPage; j++) {
        aArrays = [cabecalho];
        for (var i = nQtdAlocada; i < tamanho; i++) {
            obj = jsonObject.ProcRealizados[i];
            if (!(i > ncontLinha)) {
                for (var key in obj) {
                    Itens = obj[key];
                    aArrays.push(Itens);
                }
            }
            if (i > ncontLinha) {
                ncontLinha += nLimitador;
                break;
            }
        }
        document.getElementById("tableProcedimento" + nTopo).appendChild(createTable(aArrays, attribute, attributeName));
        aArrays = [];
        nQtdAlocada = i;
        nTopo++;
    }

}



function identificacao(jsonObject, qtdPage) {

    var attribute = "id";
    var attributeName = "idIdent"
    var nTopo = 1;
    var tamanho = jsonObject.IdentEquipe.length;
    var nTopo = 1;
    var aArrays;
    var Itens;
    var obj;
    var ncontLinha = 7;
    var nQtdAlocada = 0;
    var cabecalho = ["46-Seq.Ref",
        "47-Grau Part.",
        "48-Codigo na Operadora/CPF",
        "49-Nome do Profissional",
        "50-Conselho Profissional",
        "51-Numero no Conselho",
        "52-UF ",
        "53-Codigo CBO"
    ]

    for (var j = 0; j < qtdPage; j++) {
        aArrays = [cabecalho];
        for (var i = nQtdAlocada; i < tamanho; i++) {
            obj = jsonObject.IdentEquipe[i];
            if (!(i > ncontLinha)) {
                for (var key in obj) {
                    Itens = obj[key];
                    aArrays.push(Itens);
                }
            }
            if (i > ncontLinha) {
                ncontLinha += nLimitador;
                break;
            }
        }
        document.getElementById("tableIdentificacao" + nTopo).appendChild(createTable(aArrays, attribute, attributeName));
        aArrays = [];
        nQtdAlocada = i;
        nTopo++;
    }


}



function totais(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var totais = document.getElementById("totais" + nTopo);
        totais.appendChild(createField("140", "29", "54 - Total de Procedimentos (R$) ", jsonObject.TotalProc));
        totais.appendChild(createField("120", "29", "55 - Total de Diarias (R$) ", jsonObject.TotalDiarias));
        totais.appendChild(createField("140", "29", "56 - Total de Taxase Alugueis (R$) ", jsonObject.TotalTaxa));
        totais.appendChild(createField("140", "29", "57 - Total de Materiais (R$) ", jsonObject.TotalMateriais));
        totais.appendChild(createField("120", "29", "58 - Total de OPME (R$) ", jsonObject.TotalOPME));
        totais.appendChild(createField("140", "29", "59 - Total de Medicamentos (R$) ", jsonObject.TotalMedicam));
        totais.appendChild(createField("140", "29", "60 - Total de Gases Medicinais (R$) ", jsonObject.TotalGasesMed));
        totais.appendChild(createField("123", "29", "61 - Total Geral (R$) ", jsonObject.TotalGeral));    
        nTopo++;
    }

}



function assinaturas(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var assinaturas = document.getElementById("assinaturas" + nTopo);
        assinaturas.appendChild(createField("200", "29", "62 - Data da assinatura do contratado", jsonObject.DtAssinatura));
        assinaturas.appendChild(createField("444", "29", "63 - Assinatura do contratado", jsonObject.AssinContrato));
        assinaturas.appendChild(createField("445", "29", "64 - Assinatura do(s) Auditor(es) da Operadora", jsonObject.AssinAudOper));    
        nTopo++;
    }
}



function observacao(jsonObject, qtdPage) {

    var nTopo = 1;

    for (var i = 0; i < qtdPage; i++) {
        var observacao = document.getElementById("observacao" + nTopo);
        observacao.appendChild(createField("1100", "73", "65 - Observacao / Justificativa", jsonObject.Observacao, true, true));
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
                fileName: "Guias_Resumo_Internacao",
                proxyURL: "PPlsRelhg.html"
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



function createTable(conteudo, objAtrib, objAtribName) {
    var tabela = document.createElement("table");
    var thead = document.createElement("thead");
    var tbody = document.createElement("tbody");
    var thd = function(i) {
        return (i == 0) ? "th" : "td";
    };

    for (var i = 0; i < conteudo.length; i++) {
        var tr = document.createElement("tr");
        for (var j = 0; j < conteudo[i].length; j++) {
            var tmp = document.createElement(thd(i));
            var texto = document.createTextNode(conteudo[i][j]);

            tmp.appendChild(texto);
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

    var thvalue = obj.childNodes[0].children;
    var nCnt = 0;

    if (!isObjectEmpty(thvalue)) {
        for (var y = 0; y < thvalue.length; y++) {
            thvalue[y].setAttribute(objAtrib, objAtribName + nCnt);
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




