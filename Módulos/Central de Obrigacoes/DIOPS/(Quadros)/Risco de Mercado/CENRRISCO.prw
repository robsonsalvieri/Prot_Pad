#Include "PROTHEUS.Ch"
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt12N := TFont():New("Arial",14,14,,.t., , , , .t., .f.)
STATIC oFnt12C := TFont():New("Arial",12,12,,.f., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENRCRDEOP

Impressão Quadro Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 21/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Function CENRRISCO(lTodosQuadros,lAuto)

	Local cCadastro  := "                                 Capital Baseado em Riscos - Risco de Mercado - ALM"
	Local aResult    := {}
	Default lTodosQuadros := .F.
	Default lAuto := .F.
	Private cTitulo   := cCadastro
	Private nPagina   := 0		

	If !lTodosQuadros

		Private oReport   := nil
		Private cRelName := "DIOPS_RiscoDeMercado_"+CriaTrab(NIL,.F.)
		Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }

		oReport := FWMSPrinter():New(cRelName,6,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
		oReport:setDevice(6)
		oReport:setResolution(72)
		oReport:SetLandscape(.T.)
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)

		IIf(lAuto,oReport:CFILENAME := cRelName,"")
		IIf(lAuto,oReport:CFILEPRINT:= oReport:CPATHPRINT + oReport:CFILENAME,"")
		IIf(lAuto,.t.,oReport:Setup())
		If !lAuto .aND. oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ()
		EndIf

	EndIf

	Processa( {|| aResult := CENDRISCO() }, cCadastro)

	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Capital Baseado em Riscos - Risco de Mercado - ALM')
		EndIf
		Return
	EndIf

	lRet := PRINTINAD(aResult[2]) 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} PRINTINAD

@description Imprime Capital Baseado em Riscos - Risco de Mercado - ALM
@author Cesar Almeida
@since 21/07/2023
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------
Static Function PRINTINAD(aValores)

	Local lRet := .T.
	Local nFor := 0
	Local cBxIndex := ""

    For nFor := 1 to Len(aValores)

		PlsRDCab(cTitulo,160)

		//Código Campo	
		oReport:box(140, 020, 110, 110)
		oReport:Say(130, 027, "Código Campo", oFnt12N)
		oReport:box(200, 020, 140, 110)
		oReport:Say(173, 039, "Campo 1", oFnt12N)
		oReport:box(260, 020, 200, 110)
		oReport:Say(233, 039, "Campo 2", oFnt12N)
		oReport:box(320, 020, 260, 110)
		oReport:Say(293, 039, "Campo 3", oFnt12N)
		oReport:box(380, 020, 320, 110)
		oReport:Say(353, 039, "Campo 4", oFnt12N)
		oReport:box(440, 020, 380, 110)
		oReport:Say(413, 039, "Campo 5", oFnt12N)

		//Título
		oReport:box(140, 110, 110, 300)
		oReport:Say(130, 187, "Título", oFnt12N)
		oReport:box(200, 110, 140, 300)
		oReport:Say(173, 112, "Número da conta com risco mitigado", oFnt12C)
		oReport:box(260, 110, 200, 300)
		oReport:Say(233, 112, "Valor (em módulo)", oFnt12C)
		oReport:box(320, 110, 260, 300)
		oReport:Say(293, 112, "Sinal", oFnt12C)
		oReport:box(380, 110, 320, 300)
		oReport:Say(353, 112, "Prazo médio do fluxo com risco mitigado", oFnt12C)
		oReport:Say(365, 112, "(em meses)", oFnt12C)
		oReport:box(440, 110, 380, 300)
		oReport:Say(413, 112, "Indexador", oFnt12C)

		//Descrição
		oReport:box(140, 300, 110, 700)
		oReport:Say(130, 480, "Descrição", oFnt12N)    
		oReport:box(200, 300, 140, 700)
		oReport:Say(173, 302, "Número da conta (com até 9 dígitos), conforme plano de contas da ANS, cujo risco de mercado ", oFnt12C)
		oReport:Say(185, 302, "pretende-se mitigar através de ferramentas de gerenciamento de ativos e passivos (ALM).", oFnt12C)
		oReport:box(260, 300, 200, 700)
		oReport:Say(233, 302, "Valor o qual o ALM tenha sido capaz de mitigar o risco de mercado naquela conta, ou seja,", oFnt12C)
		oReport:Say(245, 302, "este valor deve ser menor ou igual ao valor total informado para a conta contábil no DIOPS.", oFnt12C)
		oReport:box(320, 300, 260, 700)
		oReport:Say(293, 302, "Informa se o registro em questão trata-se de uma entrada (+) ou saída (-) de caixa.", oFnt12C)
		oReport:box(380, 300, 320, 700)
		oReport:Say(353, 302, "É o prazo médio ponderado em meses do valor informado no campo1.", oFnt12C)
		oReport:box(440, 300, 380, 700)
		oReport:Say(413, 302, "Indexador do fluxo em questão (Pré-fixado, pós-fixado, IPCA, IGPM ou cambial)", oFnt12C)

		//Valores
		oReport:box(140, 700, 110, 805)
		oReport:Say(130, 735, "Valor", oFnt12N)
		oReport:box(200, 700, 140, 805)
		oReport:Say(173, 730, aValores[nFor][1], oFnt12C)	//Conta
		oReport:box(260, 700, 200, 805)
		oReport:Say(233, 700, Transform((aValores[nFor][2]),Moeda), oFnt12C) //Valor	
		oReport:box(320, 700, 260, 805)
		oReport:Say(293, 730, iif(aValores[nFor][3] == "0","+","-"), oFnt12C) // Sinal (Entrada/ Saída)	
		oReport:box(380, 700, 320, 805)
		oReport:Say(353, 730, cValToChar(aValores[nFor][4]), oFnt12C)	//Prazo (MESES)

		cBxIndex := cBoxIndexa(aValores[nFor][5]) //Trata cBox

		oReport:box(440, 700, 380, 805)
		oReport:Say(413, 730, cBxIndex, oFnt12C)  //IPCA,IGPM etc

	Next

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CENDRISCO

@description Retorna dados cadastrados do quadro Capital Baseado em Riscos - Risco de Mercado - ALM
@author Cesar Almeida
@since 21/07/2023
@version P12

/*/
//------------------------------------------------------------------
Static Function CENDRISCO()

	Local cSql := ""
    Local cAlias := GetNextAlias()
	Local lRet := .F.
	Local aResult := {}

	cSql := " SELECT BVU_CONTA,BVU_VALOR,BVU_ESCX,BVU_MESES,BVU_INDEXA "
	cSql += " FROM " + RetSqlName("BVU")
	cSql += " WHERE BVU_FILIAL = '" + xFilial("BVU") + "' "
	cSql += " AND BVU_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BVU_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BVU_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BVU_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	(cAlias)->(dbGoTop())

	If !(cAlias)->(Eof())
		lRet := .T.
		While !(cAlias)->(Eof())
			aAdd(aResult,{(cAlias)->BVU_CONTA,;
                          (cAlias)->BVU_VALOR,;
                          (cAlias)->BVU_ESCX,;
                          (cAlias)->BVU_MESES,;
                          (cAlias)->BVU_INDEXA})
			(cAlias)->(dbSkip())
		EndDo
	Else
		aResult	:= {0,0}
	EndIf
	(cAlias)->(DbCloseArea())

Return( { lRet, aResult} )

//------------------------------------------------------------------
/*/{Protheus.doc} cBoxIndexa

@description Trata Valor do cBOX
@author Cesar Almeida
@since 24/07/2023
@version P12

/*/
//------------------------------------------------------------------
Static Function cBoxIndexa(cIndex)

	Local cIndexador := ""

	Do Case
		Case cIndex == "0"
			cIndexador := "Pré-Fixado"
		Case cIndex == "1"
			cIndexador := "Pós-Fixado"
		Case cIndex == "2"
			cIndexador := "IPCA"
		Case cIndex == "3"
			cIndexador := "IGPM"
		Case cIndex == "4"
			cIndexador := "Cambial"
	EndCase
	
Return cIndexador

