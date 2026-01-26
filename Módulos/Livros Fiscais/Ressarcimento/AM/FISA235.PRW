#INCLUDE "PROTHEUS.CH"
Static lFsa235Und    := ExistBlock("FSA235UND")

/*/{Protheus.doc} FISA235
Função que gera o arquivo de ressarcimento do ICMS ST DT-e
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, return_description
/*/
Function FISA235(lAutomato)
Private cAliasPri	:= GetNextAlias()
Private cVersao 	:= "2.00"
DEFAULT lAutomato	:= .F.

// MV_PAR01   Data De ?
// MV_PAR02   Data Ate ?
// MV_PAR03   Nome Responsável ?
// MV_PAR04   Telefone Responsável ?
// MV_PAR05   Email Responsável ?
// MV_PAR06   Dir. Destino ?
// MV_PAR07   Gera XML ? 1-Lista Produto | 2-Lista Pedido
// MV_PAR08   Modalidade Ressarcimento ?  1-ICMS ST | 2-Baixa Estoque
// MV_PAR09   Versão ?  2.00
If lAutomato .Or. Pergunte("FISA235",.T.)
	getQryXML()
	Processa( { || XMLPedido(lAutomato) } , "Processando Arq. Lista de Pedido" )	//"Processando Arquivo XML"
EndIf
If Select(cAliasPri) > 0
	(cAliasPri)->(DbCloseArea())
EndIf
Return

/*/{Protheus.doc} XMLPedido
Gera o arquivo xml do pedido do ressarcimento DT-e.
A SEFAZ AM institiu que os arquivos gerados por essa rotina dever ser subtimetidos via upload no portal DT-e da SEFAZ AM
A função XML pedido gera o XML de pedido (XMLPEDIDO) e produto (XMLPRODUTO).
Ambos são gerados juntos pois careciamos de informação por parte da SEFAZ para gerar os dois arquivos de forma distinta.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type,
/*/
Static Function XMLPedido(lAutomato)
Local cXML			:= ""
Local aCHVNF		:= {}
Local aListProd     := {}
Local cNome			:= "RESSTAM_LISTA_PEDIDO"
Local cAno      	:= Str(Year( MV_PAR01 ),4)
Local cPeriodo     	:= StrZero(Month( MV_PAR01 ),2)
DEFAULT lAutomato	:= .F.

cXML	+=	'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
cXML	+=	'<enviOperacaoRessarcimento xmlns="http://www.sefaz.am.gov.br/ressarcimento">'
cXML	+=	'<versao>' + cVersao + '</versao>'
cXML	+= noDeclarant( cVersao , "2" , cAno , cPeriodo)
cXML	+= noListOper(@aCHVNF,@aListProd)
cXml	+= noListNFE(aCHVNF)
cXML	+= '</enviOperacaoRessarcimento>'
cNome   += cAno + cPeriodo
GravaArq(cXML, cNome , lAutomato)
XMLProduto( aListProd, lAutomato)
Return

/*/{Protheus.doc} XMLProduto
Gera o arquivo xml do produto do ressarcimento DT-e. Será feito upload no site da sefaz AM
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type,
/*/
Static Function XMLProduto(aListProd,lAutomato)
Local cXML	:= ""
Local cNome			:= "RESSTAM_LISTA_PRODUTO"
Local cAno      	:= Str(Year( MV_PAR01 ),4)
Local cPeriodo     	:= StrZero(Month( MV_PAR01 ),2)
Local nX            := 1
Local aUnico		:= {}
DEFAULT aListProd   := {}

cXML	+=	'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
cXML	+=	'<enviProdutoRessarcimento xmlns="http://www.sefaz.am.gov.br/ressarcimento">'
cXML	+=	'<versao>' + cVersao + '</versao>'
cXML	+= noDeclarant()
cXML	+= 	'<listaProdutos>'
For nX := 1 To Len(aListProd)
	// Controla registros únicos - Baseado na estrutura do XML para não gerar informações repetidas estamos criando uma PK na lista de produto.
	// Caso a SEFAZ de amazonas crie um campo/tag que idenfique o documento na lista de produto essa PK pode ser retirara.
	If aScan(aUnico,{|x| x[1] == aListProd[nX,1] .And. x[2] == aListProd[nX,5]  .And. x[3] == aListProd[nX,6] .And. x[4] == aListProd[nX,7]   }) == 0
				     //Cod.Prod          CNPJ Fornecedor  Cod.Prod.Fornec   Uni.Fornecedor
		AADD(aUnico, { aListProd[nX,1] , aListProd[nX,5], aListProd[nX,6] , aListProd[nX,7]  })
	    cXML	+= noProduto( aListProd[nX][1], aListProd[nX][2], aListProd[nX][3], aListProd[nX][4] ,aListProd[nX][5] ,aListProd[nX][6] ,aListProd[nX][7])
	EndIf
Next nX
cXML	+= 	'</listaProdutos>'
cXML	+= 	'</enviProdutoRessarcimento>'
cNome   += 	cAno + cPeriodo
GravaArq(cXML, cNome , lAutomato)
Return

/*/{Protheus.doc} noProduto
Cria o nó do Produto do XML da lista de produtos
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informações do nó do XML
/*/
Static Function noProduto(cCod,cDescri,cUni,cFator,cCNPJ,cCodFor,cUniFor)
Local cXML          := ""
cXML	+=	'<produto>'
cXML	+=	'	<codInternoProduto>'+AllTrim(cCod)+'</codInternoProduto>' // Protheus
cXML	+=	'	<descricaoProduto>'+AllTrim(cDescri)+'</descricaoProduto>' // Protheus
cXML	+=	'	<unidadeInternaProduto>'+AllTrim(cUni)+'</unidadeInternaProduto>' // Protheus
cXML	+=	'	<fatorConversao>'+AllTrim(cFator)+'</fatorConversao>' // Protheus
cXML	+=	'	<cnpjFornecedor>'+AllTrim(cCNPJ)+'</cnpjFornecedor>' // Protheus
cXML	+=	'	<codProdFornecedor>'+AllTrim(cCodFor)+'</codProdFornecedor>' // Protheus / Ponto de entrada
cXML	+=	'	<unidadeProdutoFornecedor>'+AllTrim(cUniFor)+'</unidadeProdutoFornecedor>' // Protheus / Ponto de entrada
cXML 	+=	'</produto>'
Return cXML


/*/{Protheus.doc} noListOper
Cria o nó do lista de operações do XML da lista de pedidos
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informações do nó do XML
/*/
Static Function noListOper( aCHVNF , aListProd )
Local cXML          := ""
Local cChave		:= ""
Local aFsa235Und    := {}
DEFAULT aListProd   := {}
DEFAULT aCHVNF     	:= {}

cXml += '<listaOperacoes>
While (cAliasPri)->(!Eof())
	If Empty(cChave) .Or. cChave <>  (cAliasPri)->FT_CHVNFE
		cChave :=  (cAliasPri)->FT_CHVNFE
		cXml += '<operacao>
		cXml += '<chaveNFe>' + (cAliasPri)->FT_CHVNFE + '</chaveNFe>
		cXml += '<listaItens>'
		While (cAliasPri)->(!Eof()) .And. cChave ==  (cAliasPri)->FT_CHVNFE
			cXml += noListItem()

            // Retorna as informações da nota fiscal do fornecedor por ponto de entrada referente a unidade de medida.
            aadd( aListProd, { (cAliasPri)->B1_COD      ,;  // 1 Código do produto
                                (cAliasPri)->B1_DESC    ,;  // 2 Descrição do produto
                                (cAliasPri)->B1_UM      ,;  // 3 Unidade de medida fiscal
                                (cAliasPri)->B1_CONV    ,;  // 4 Unidade de conversão
                                (cAliasPri)->A2_CGC     ,;  // 5 Código do fornecedor
                                (cAliasPri)->B1_COD     ,;  // 6 Código do produto do fornecedor
                                (cAliasPri)->B1_UM     ,;  // 7 Unidade de medida do fornecedor
                                0                       ,;  // 8 Fator de conversão entre o produto do Fornecedor e o principal do cliente
                                '' })                       // 9 Tipo de Conversão M Multiplicação  / Divisão

			If lFsa235Und
				aFsa235Und := ExecBlock("FSA235UND", .F., .F., {cAliasPri})
				If ValType(aFsa235Und) == "A" .And. Len(aFsa235Und) == 4 .And. ValType(aFsa235Und[1]) == 'C' .And. ValType(aFsa235Und[2]) == 'C' .And. ValType(aFsa235Und[3]) == 'N' .And. ValType(aFsa235Und[4]) == 'C'
					 aListProd[Len(aListProd)][6]   := aFsa235Und[1]
                     aListProd[Len(aListProd)][7]   := aFsa235Und[2]
                     aListProd[Len(aListProd)][8]   := aFsa235Und[3]
                     aListProd[Len(aListProd)][9]   := aFsa235Und[4]
				Endif
			EndIf

            // Grava chaves de acessos únicas (distinct)
			If ! aScan(aCHVNF, {|x| x == (cAliasPri)->FT_CHVNFE } ) > 0
				AADD(aCHVNF,(cAliasPri)->FT_CHVNFE)
			EndIf

			cChave :=  (cAliasPri)->FT_CHVNFE
			(cAliasPri)->(DbSkip())
		End
		cXml += '</listaItens>'
		cXml += '</operacao>

	EndIf
End
cXml += '</listaOperacoes>
Return cXML

/*/{Protheus.doc} noListNFE
Cria o nó do lista de lista de chaves de acesso do XML da lista de pedidos.
Essa tag retorna apenas as chaves de acesso. Pode ser de entrada ou saída pois a LEI x XSD x Exemplos da SEFAZ não deixam claro o conteúdo esperado.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informações do nó do XML
/*/
Static Function noListNFE(aCHVNF)
Local cXML          := ""
Local nX 			:= 1
DEFAULT aCHVNF		:= {}

cXml += '<listaNFeEntrada>
For nX := 1 To Len(aCHVNF)
	cXml += '<chaveNFeEntrada>' + aCHVNF[nX]+ '</chaveNFeEntrada>
Next nX
cXml += '</listaNFeEntrada>
Return cXML

/*/{Protheus.doc} noListItem
Cria o nó do lista de NFE de entrada filho do listaOperacoes do XML da lista de pedidos.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informações do nó do XML
/*/
Static Function noListItem()
Local cXML          := ""
cXml += '<item>'
cXml += '<codInternoProduto>' +AllTrim((cAliasPri)->CD0_COD) + '</codInternoProduto>'
cXml += '<numItemNFe>' +AllTrim((cAliasPri)->CD0_ITEM) + '</numItemNFe>'
//Nova redação dada ao Anexo II pela Resolução n° 002/2020-GSEFAZ, efeitos a partir de 13.1.2020.
//cXml += '<chaveNFeEntrada>' + (cAliasPri)->CD0_CHVNFE + '</chaveNFeEntrada>'
cXml += '</item>'
Return cXml


/*/{Protheus.doc} noDeclarant
Retorna o cabeçalho dos XMLS de lista de pedido e/ou produto.
Devido a semelhança criamos uma função para retorna esse nó do XML
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cVersao, character, Versão do arquivo do ressarcimento
@param cTipoXML, character, 1 = lista de produto 2= lista de pedido
@param cAno, character, cAno do exercício (somente para xTipoXML=2)
@param cPeriodo, character, cPeriodo do exercício (somente para xTipoXML=2)
@return return_type, Retorna uma string com as informações do nó do XML
/*/
Static Function noDeclarant( cVersao , cTipoXML , cAno , cPeriodo )
Local cXML          := ""
DEFAULT cTipoXML   	:= "1"
DEFAULT cAno		:= ""
DEFAULT cPeriodo	:= ""

cXML	+=	'<dadosDeclarante>'
cXML	+=	'<cnpjRaiz>' + SubStr(SM0->M0_CGC,1,8) + '</cnpjRaiz>'
cXML	+=	'<razaoSocial>' + AllTrim(SM0->M0_NOMECOM) + '</razaoSocial>'
cXML	+=	'<nomeResponsavel>' + Alltrim(MV_PAR03)+ '</nomeResponsavel>'
cXML	+=	'<foneResponsavel>' + AllTrim(MV_PAR04) +'</foneResponsavel>'
cXML	+=	'<emailResponsavel>'+ AllTrim(MV_PAR05) +'</emailResponsavel>'
If cTipoXML == "2"
    cXML	+=	'<anoPeriodoReferencia>' + cAno + '</anoPeriodoReferencia>'
    cXML	+=	'<mesPeriodoReferencia>' + cPeriodo + '</mesPeriodoReferencia>''
EndIf

cXML 	+=	'</dadosDeclarante>'
Return cXML


/*/{Protheus.doc} GetQryPri
Função que retorna a query principal para geração dos arquivos XML
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna a query
/*/
Static Function getQryXML()

Local nMotivo	:= MV_PAR08
Local cQryCD0   := ""
Local oQryCD0	:= Nil

/*
	MV_PAR08   Modalidade Ressarcimento ?  1-ICMS ST | 2-Baixa Estoque
	Ao subir o arquivo no site da SEFAZ Amazonas é feita uma divisão para upload do arquivo
	Opção de upload: 1- ICMS ST
	Opção de upload:2 = Baixa de estoque (perda, roubo ....).
	Por essa razão efetuamos a divisão através desse recurso do pergunte. CD0_MOTRES:
	1=Venda para outra UF;
	2=Saída por isenção ou não incidência;
	3=Perda ou deterioração;
	4=Furto ou roubo;
	5=Exportação;
	9=Outros	
*/


	cQryCD0 := " SELECT CD0.CD0_COD, CD0.CD0_ITENFE, CD0.CD0_CHVNFE , SFT.FT_CHVNFE , CD0.CD0_DOCENT , CD0.CD0_SERENT , CD0.CD0_FORNE , CD0.CD0_LOJENT , CD0.CD0_COD , CD0.CD0_ITEM, "
	cQryCD0 += " SB1.B1_COD , SB1.B1_DESC , SB1.B1_UM , SB1.B1_CONV , SA2.A2_CGC"
	cQryCD0 += " FROM ? CD0 "
	cQryCD0 += " INNER JOIN ? SFT ON ( "
	cQryCD0 += " ? "
	cQryCD0 += " AND SFT.D_E_L_E_T_ = ' ' "
	cQryCD0 += " AND SFT.FT_NFISCAL = CD0.CD0_DOC"
	cQryCD0 += " AND SFT.FT_SERIE = CD0.CD0_SERIE"
	cQryCD0 += " AND SFT.FT_ITEM = CD0.CD0_ITEM"
	cQryCD0 += " AND SFT.FT_PRODUTO = CD0.CD0_COD )"
	cQryCD0 += " INNER JOIN ? SB1 ON  ( "
	cQryCD0 += " ? "
	cQryCD0 += " AND SB1.D_E_L_E_T_ = ' ' "
	cQryCD0 += " AND SB1.B1_COD = SFT.FT_PRODUTO "
	cQryCD0 += " AND SB1.B1_FILIAL =  ? ) 
	cQryCD0 += " INNER JOIN ?  SA2 ON ( "
	cQryCD0 += " SA2.D_E_L_E_T_ = ' ' "
	cQryCD0 += " AND SA2.A2_FILIAL = ? 
	cQryCD0 += " AND SA2.A2_COD = CD0.CD0_FORNE ) "
	cQryCD0 += " WHERE CD0.D_E_L_E_T_ = ' '"
	cQryCD0 += " AND CD0_EMISSA >= ?  
	cQryCD0 += " AND CD0_EMISSA <= ?  
	cQryCD0 += " AND CD0_FILIAL = ? 
	cQryCD0 += " AND CD0_EMISSA >= '2015'" // Conforme portal DT-e Amazonas só é possível solicitar o ressarcimento das notas emitidas a partir de 2015
	if nMotivo == 1
		cQryCD0 += " AND CD0_MOTRES IN ('1', '5') "
	else
		cQryCD0 += " AND CD0_MOTRES IN ('3', '4') "
	EndiF
	cQryCD0 += " AND CD0_TPMOV = 'S'  "
	cQryCD0 += " ORDER BY FT_CHVNFE,FT_NFISCAL,FT_SERIE,FT_ITEM,FT_PRODUTO "
	
	cQryCD0 := ChangeQuery(cQryCD0)
	OQryCD0 := FwExecStatement():New(cQryCD0)

oQryCD0:SetUnSafe(1, RetSqlName("CD0"))
oQryCD0:SetUnSafe(2, RetSqlName("SFT"))
oQryCD0:SetUnSafe(3, FWJoinFilial("SFT","CD0","SFT","CD0",,,.T.))
oQryCD0:SetUnSafe(4, RetSqlName("SB1"))
oQryCD0:SetUnSafe(5, FWJoinFilial("SB1","SFT","SB1","SFT",,,.T.))
oQryCD0:SetString(6,xFilial("SB1"))
oQryCD0:SetUnSafe(7, RetSqlName("SA2"))
oQryCD0:SetString(8,xFilial("SA2"))
oQryCD0:SetDate(9, MV_PAR01)
oQryCD0:SetDate(10, MV_PAR02)
oQryCD0:SetString(11,xFilial("CD0"))


cAliasPri := oQryCD0:OpenAlias()

TcSetField(cAliasPri,"CD0_EMISSA","D",8,0)
DbSelectArea(cAliasPri)

If oQryCD0 != Nil	
   oQryCD0:Destroy()
   oQryCD0 := Nil
EndIf

Return Nil

/*/{Protheus.doc} MontaArq
Retorna o nome dompleto do arquivo que será gerado.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cPath, character, Diretório
@param cFile, character, nome do arquivo
@param cExtension, character, extensão do arquivo
@return return_type, return_description
/*/
Static Function MontaArq( cPath ,cFile ,cExtension , lAutomato )
Local cBarra := iIf(IsSrvUnix() ,"/" ,"\")
Local cCNPJ	 := AllTrim(SM0->M0_CGC)
Local cTime	 := AllTrim(STRTRAN(Alltrim(time()),":",'_'))
DEFAULT cPath := ""
DEFAULT cFile := ""
DEFAULT cExtension := ".xml"
DEFAULT lAutomato := .F.

	cPath := Alltrim(cPath)

	If IsSrvUnix()
		cPath := STRTRAN(cPath ,"\" ,"/")
	Else
		cPath := STRTRAN(cPath ,"/" ,"\")
	EndIF

	If !File(cPath)
		If !lAutomato
			MsgInfo("Não foi possível localizar o diretório informando", "DT-e Ressarcimento")
		EndIf
	EndIf

	If !(Right(cPath ,1) == cBarra)
		cPath += cBarra
	EndIf

	cFile := Alltrim(cFile) + cCNPJ + IIF( lAutomato ,'' , "_" + cTime)
	cExtension := Alltrim(cExtension)
	cFile += cExtension

Return(cPath+cFile)

/*/{Protheus.doc} GravaArq
Gravado o arquivo XML para que o usuário possa subir o arquivo no site da SEFAZ Amazonas
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cXML, character, string com o XML
@param cNome, character, nome do arquivo que será gerado.
@return return_type, return_description
/*/
Static Function GravaArq(cXML,cNome,lAutomato)
Local nBytes	:= 0
Local nHandle
Local  cFile	:= ""
DEFAULT lAutomato	:= .F.

cFile := MontaArq( MV_PAR06 , cNome , ,lAutomato)

nHandle := FCreate(cFile)

If nHandle == -1
	If !lAutomato
		MsgInfo("Não foi criar o arquivo no diretório especificado: " + AllTrim(cFile) , "DT-e Ressarcimento")
	EndIf
	Return
EndIf

nBytes := fWrite(nHandle,cXML)
fClose(nHandle)
If nBytes > 0
	If !lAutomato
		MsgInfo("Arquivo gerado com sucesso: " + AllTrim(cFile) , "DT-e Ressarcimento")
	EndIf
EndIf

Return

