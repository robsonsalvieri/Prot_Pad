#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOJXFUNL.CH"

Function LOJXFUNL()
Return

//--------------------------------------------------------
/*{Protheus.doc}LjLogL1Sit
Efetua o Log quando o campo L1_SITUA for alterado
@author  	Julio Nery
@version 	12
@since   	06/11/2020
@return  	Nil
@sample
*/
//--------------------------------------------------------
Function LjLogL1Sit(cAlias,cValor)
Local cCTRL := Chr(10)+Chr(13)  //Pula linha
Local cTexto:= ""
Local aValores:= {}
Local nI    := 0

Default cAlias := "SL1"
Default cValor := ""

//SL1 ja esta posicionado
cTexto := "L1_SITUA alterado para " + Iif(Empty(cValor),(cAlias)->L1_SITUA,cValor) + ;
          " -> Está em Transação ? " + IIf(InTransaction(), "SIM", "NÃO") + ;
		  cCTRL + " Pilha de chamada (ultimas 4 chamadas)"

For nI:= 1 to 4
    AAdd(aValores, ProcName(nI) + " - Linha: " + cValToChar(ProcLine(nI)))
Next nI

LjGrvLog(ProcName(1),cTexto,aValores)
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetPdvOn
Retornar se no cadastro de estação existe algum PDV setado 
para trabalhar Online

@type    	function
@author  	Bruno Almeida
@since   	17/05/2022
@version 	12.1.33
@return		Logico - Se existe ou nao um PDV para trabalhar Online
/*/
//-------------------------------------------------------------------
Function LjGetPdvOn()

Local lRet 		:= .F. 			//Variavel de retorno
Local cQuery 	:= ""			//Guarda a query a ser executada
Local aArea		:= GetArea()	//Guarda a area para ser restaurada
Local cAlias    := "" 			//Pega o proximo alias

DbSelectArea("SLG")

If SLG->(ColumnPos("LG_PDVON")) > 0
	cAlias := GetNextAlias()

	cQuery := "SELECT LG_PDVON"
	cQuery += "  FROM " + RetSqlName("SLG")
	cQuery += " WHERE LG_FILIAL = '" + xFilial("SLG") + "'"
	cQuery += "   AND LG_PDVON = '1'"
	cQuery += "   AND D_E_L_E_T_ <> '*'"

	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
	
	If !(cAlias)->( Eof() )
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	(cAlias)->( DbCloseArea() )

EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGrvNes
Grava as informações na tabela NES

@type  		Function	
@author 	Bruno Almeida
@since 		30/10/2025
@return 	Nil
/*/
//-------------------------------------------------------------------
Function LjGrvNes()

Local aArea      := GetArea()
Local cNumReceit := "001"
Local cNumTransp := "001"

SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))

dbSelectArea("NES")
dbSetOrder(1) //NES_FILIAL+NES_DOC+NES_SERIE+NES_CLIENT+NES_LOJA+NES_TPVINC+NES_ITEM
If !DbSeek(xFilial("NES") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) 

	While SL2->(!Eof()) .And. SL2->L2_FILIAL == SL1->L1_FILIAL .And. SL2->L2_NUM == SL1->L1_NUM		

		// Dados do receituario
		If !Empty(SL2->L2_CPFENG) .Or. !Empty(SL2->L2_NUMREC)
			RecLock("NES",.T.)
			NES->NES_FILIAL := SL1->L1_FILIAL
			NES->NES_DOC    := SL1->L1_DOC
			NES->NES_SERIE  := SL1->L1_SERIE
			NES->NES_CLIENT := SL1->L1_CLIENTE
			NES->NES_LOJA   := SL1->L1_LOJA
			NES->NES_TPVINC := "1"
			NES->NES_ITEM   := cNumReceit
			NES->NES_NUMREC := SL2->L2_NUMREC
			NES->NES_CGC    := SL2->L2_CPFENG
			NES->(MsUnlock())

			cNumReceit := Soma1(cNumReceit)
		EndIf

		// Dados do guia de transporte
		If !Empty(SL2->L2_NMRGUI) .Or. !Empty(SL2->L2_SERGUI) .Or. !Empty(SL2->L2_TPGUIA) .Or. !Empty(SL2->L2_UFGUIA)
			RecLock("NES",.T.)
			NES->NES_FILIAL := SL1->L1_FILIAL
			NES->NES_DOC    := SL1->L1_DOC
			NES->NES_SERIE  := SL1->L1_SERIE
			NES->NES_CLIENT := SL1->L1_CLIENTE
			NES->NES_LOJA   := SL1->L1_LOJA
			NES->NES_TPVINC := "2"
			NES->NES_ITEM   := cNumTransp
			NES->NES_TPGUIA := SL2->L2_TPGUIA
			NES->NES_UF     := SL2->L2_UFGUIA
			NES->NES_NUMGUI := SL2->L2_NMRGUI
			NES->NES_SERGUI := SL2->L2_SERGUI
			NES->(MsUnlock())
			
			cNumTransp := Soma1(cNumTransp)
		EndIf

		SL2->(DbSkip())

	EndDo
EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7Agro
Função para retornar se um determinado campo esta marcado como usado

@type  		Function	
@author 	Bruno Almeida
@since 		30/10/2025
@return 	Logico - Retorna .T. se o campo é usado ou .F. se não for usado.
/*/
//-------------------------------------------------------------------
Function LjAgro(aCampos)

Local aArea := GetArea()
Local lRet  := .F.
Local nI    := 0
Local lSl2  := .T.

Default aCampos := {}

SX3->(dbSetOrder(2))

If Len(aCampos) > 0
	lSl2 := SubStr(aCampos[1],1,2) == "L2"

	For nI := 1 To Len(aCampos)
		If lSl2
			If SL2->(ColumnPos(aCampos[nI])) > 0
				lRet := .T.
			Else
				lRet := .F.
				Exit
			EndIf
		Else
			If SX3->(dbSeek(aCampos[nI])) .And. X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
				lRet := .T.
			Else
				lRet := .F.
				Exit
			EndIf
		EndIf	
	Next nI

EndIf

If lRet .And. !FwAliasInDic("NES")
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7AgroSlr
Função para retornar os campos da SLR relacionados a NT 2024.003 do AGRO

@type  		Function	
@author 	Bruno Almeida
@since 		30/10/2025
@return 	Array - Retorna um array com os campos relacionados a NT
/*/
//-------------------------------------------------------------------
Function LjAgroSlr()
Local aRet := {"LR_CPFENG","LR_NUMREC","LR_NMRGUI","LR_SERGUI","LR_TPGUIA","LR_UFGUIA"}
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7AgroSl2
Função para retornar os campos da SLR relacionados a NT 2024.003 do AGRO

@type  		Function	
@author 	Bruno Almeida
@since 		30/10/2025
@return 	Array - Retorna um array com os campos relacionados a NT
/*/
//-------------------------------------------------------------------
Function LjAgroSl2()
Local aRet := {"L2_CPFENG","L2_NUMREC","L2_NMRGUI","L2_SERGUI","L2_TPGUIA","L2_UFGUIA"}
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAgroTela
Função para chamar a tela do Agro para informar os dados de engenheiro e guia

@type  		Function	
@author 	Bruno Almeida
@since 		06/11/2025
@return 	
/*/
//-------------------------------------------------------------------
Function LjAgroTela()



Local aArea         := GetArea()
Local cCadasOld     := ""
Local cFunNameOld   := ""
Local cAliasQry     := ""
Local cQuery        := ""
Local oExecStm      := Nil	// FWExecStatement usado na consulta de Nota sobre Cupom (NFC-e)
Local cDocAgro      := ""	// Doc do DF-e que sera aberto na tela (cupom atual ou Nota sobre Cupom, conforme escolha do usuario)
Local cSerAgro      := ""	// Serie do DF-e que sera aberto na tela
Local cCliAgro      := ""	// Cliente do DF-e que sera aberto na tela
Local cLojAgro      := ""	// Loja do DF-e que sera aberto na tela
Local lNFCe         := .F.	// Indica se o cupom foi emitido como NFC-e (chave NFC-e preenchida)
Local lTemNCupom    := .F.	// Indica se existe Nota sobre Cupom (NF-e modelo 55) vinculada a este cupom
Local lPendente     := .F.	// Indica se o DF-e escolhido ainda esta pendente/rejeitado
Local nOperacao     := MODEL_OPERATION_VIEW
Local oModelAgro    := Nil	// Model usado apenas no cenario de inclusao (quando ainda nao existe registro em NES)
Local lLJ130MN      := SuperGetMV("MV_LJ130MN",,.F.) // Permite gerar uma nota para multiplos cupons, utiliza tabela MDL
Local lAchouMDL     := .F. 

If !Empty(SL1->L1_NUM)
	If !Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_SERIE)

		
		cDocAgro := SL1->L1_DOC
		cSerAgro := SL1->L1_SERIE
		cCliAgro := SL1->L1_CLIENTE
		cLojAgro := SL1->L1_LOJA

		//Identifica se a venda foi feita via NFC-e (mesmo criterio usado em LOJR130 - chave NFC-e
		//preenchida no cupom). Para NFC-e, so e permitido incluir os dados de Guia/Receituario
		//quando ja existir uma Nota sobre Cupom (NF-e modelo 55) gerada a partir deste cupom.
		lNFCe := SL1->(ColumnPos("L1_KEYNFCE")) > 0 .And. !Empty(AllTrim(SL1->L1_KEYNFCE)).AND. !SL1->L1_IMPNF .AND. SL1->L1_TPORC == 'E'

		//Verifica se tem nota sobre cupom para modelo 65
		If lNFCe
			
			
		    If lLJ130MN
		        DbSelectArea("MDL")
		        MDL->(dbSetOrder(2)) //MDL_FILIAL+MDL_CUPOM+MDL_SERCUP+MDL_NFCUP+MDL_SERIE
		        If MDL->(dbSeek(xFilial("MDL") + SL1->L1_DOC + SL1->L1_SERIE))
		            lTemNCupom := .T.
		            lAchouMDL  := .T.
		            nRecnoSF2  := MDL->MDL_F2RECN
		        EndIf
		    EndIf
					
			If lAchouMDL
		        //MDL ja traz o recno exato do SF2 da Nota sobre Cupom - posiciona direto, sem nova busca
		        SF2->(dbGoTo(nRecnoSF2))
		        cDocAgro := SF2->F2_DOC
		        cSerAgro := SF2->F2_SERIE
		        cCliAgro := SF2->F2_CLIENTE
		        cLojAgro := SF2->F2_LOJA
		    Else
		        //Fallback: mecanismo legado, busca direta em SF2 pelo campo F2_NFCUPOM
		        cQuery := " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA "
		        cQuery += "   FROM " + RetSqlName("SF2") + " SF2 "
		        cQuery += "  WHERE SF2.F2_FILIAL  = ? "
		        cQuery += "    AND SF2.F2_NFCUPOM = ? "
		        cQuery += "    AND SF2.D_E_L_E_T_ = ? "
		        cQuery += "  ORDER BY SF2.R_E_C_N_O_ DESC "
		
		        cQuery := ChangeQuery(cQuery)
		
		        oExecStm := FWExecStatement():New(cQuery)
		        oExecStm:SetString(1, xFilial("SF2"))
		        oExecStm:SetString(2, SL1->L1_SERIE + SL1->L1_DOC)
		        oExecStm:SetString(3, " ")
		
		        cAliasQry := oExecStm:OpenAlias()
		
		        If !(cAliasQry)->(Eof())
		            lTemNCupom := .T.
		            cDocAgro   := (cAliasQry)->F2_DOC
		            cSerAgro   := (cAliasQry)->F2_SERIE
		            cCliAgro   := (cAliasQry)->F2_CLIENTE
		            cLojAgro   := (cAliasQry)->F2_LOJA
		        EndIf
		
		        (cAliasQry)->(DbCloseArea())
		        oExecStm:Destroy()
		    EndIf
		
		EndIf

		If lNFCe .And. !lTemNCupom
			MsgInfo(STR0005, STR0002) //"Para NFC-e, os Dados de Guia/Receituario so podem ser incluidos quando existir uma Nota sobre Cupom vinculada a este cupom." # "Venda Assistida"
		Else

			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(dbSeek(SL1->L1_FILIAL + cDocAgro + cSerAgro + cCliAgro + cLojAgro))
				If AllTrim(SF2->F2_ESPECIE) == 'SPED' .OR. lTemNCupom
					If LjProdAgro()

						If	Empty(SF2->F2_DAUTNFE)  
							lPendente := .T.
							nOperacao := MODEL_OPERATION_UPDATE
						EndIf

						DBSelectArea("NES")
						NES->(dbSetOrder(1)) //NES_FILIAL+NES_DOC+NES_SERIE+NES_CLIENT+NES_LOJA+NES_TPVINC+NES_ITEM

						cCadasOld   := cCadastro
						cFunNameOld := FunName()
						SetFunName("AGDA070")

						If NES->(dbSeek(xFilial("NES") + cDocAgro + cSerAgro + cCliAgro + cLojAgro))
							//Ja existe registro em NES para este documento - Alterar (se pendente) ou Visualizar
							FWExecView(STR0007, "VIEWDEF.AGDA070", nOperacao, , ,{|| LjOkAgro()}) //"Alterar/Visualizar"
						ElseIf lPendente .OR. lTemNCupom
							//Nao existe registro em NES ainda (venda original sem dados de AGRO) e o documento esta
							//pendente/rejeitado - inclui um novo registro, seguindo o mesmo padrao usado em AGDA070TSS
							oModelAgro := FwLoadModel("AGDA070")
							oModelAgro:SetOperation(MODEL_OPERATION_INSERT)
							oModelAgro:Activate()
							FWExecView(STR0008, "VIEWDEF.AGDA070", MODEL_OPERATION_INSERT, , {|| LjOkAgro()},,,,,,,oModelAgro)
							oModelAgro:Destroy()
							oModelAgro := Nil
						Else
							//Nao existe registro em NES e o documento nao esta pendente - nao ha o que exibir/corrigir
							MsgInfo(STR0006, STR0002) //"Nao foram encontrados dados de Guia/Receituario para este documento." # "Venda Assistida"
						EndIf

						cCadastro := cCadasOld
						SetFunName(cFunNameOld)

					Else
						MsgInfo(STR0001,STR0002) //"Nenhum produto possuí necessidade de Receituário ou Guia de Transporte" # "Venda Assistida"
					EndIf
				Else
					MsgInfo(STR0003,STR0002) //"Os Dados Guia/Receituario só é necessario o preenchimento para orçamentos que foram emitidos NF-e (modelo 55)!" # "Venda Assistida"
				EndIf
			EndIf
		EndIf
	Else
		MsgInfo(STR0004,STR0002) //"Nota fiscal não emitida para este orçamento, não sera exibida a tela de Dados Guia/Receituario" # "Venda Assistida"
	EndIf
EndIf

RestArea(aArea)


Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} LjOkAgro
Valida, no fechamento da tela AGDA070, se a venda nao possui itens que
exigem Receituario e Guia de Transporte simultaneamente - a NT 2024.003
nao permite que a NF-e contenha os dois grupos de dados agropecuarios ao
mesmo tempo (a SEFAZ rejeita o documento nesse caso).

@type  		Function
@author 	Jose Erik Belmonte
@since 		26/08/2026
@return 	lOk - .T. libera o fechamento da tela, .F. bloqueia
/*/
//-------------------------------------------------------------------
Static Function LjOkAgro()

Local lOk    := .T.
Local oModel := FWModelActive()

//Valida se os dados  preenchidos  (grids NES_RECE/NES_GUIA do model AGDA070)
//se o usuario preencheu os dois grupos na mesma nota bloqueia pq não é permitido
If !(oModel == Nil) .And. !(oModel:GetModel("NES_RECE") == Nil) .And. !(oModel:GetModel("NES_GUIA") == Nil)
	If LjGridTemLinha(oModel:GetModel("NES_RECE")) .And. LjGridTemLinha(oModel:GetModel("NES_GUIA"))
		MsgAlert(STR0009, STR0002) //"Esta nota nao pode conter, ao mesmo tempo, dados de Receituario e de Guia de Transporte. Preencha apenas um dos grupos." # "Venda Assistida"
		lOk := .F.
	EndIf
EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGridTemLinha
Verifica se um submodelo do tipo Grid (FWFormGridModel) possui ao menos
uma linha ativa (nao deletada pelo usuario). Diferente de IsEmpty(),
desconsidera linhas marcadas como deletadas na grid mas ainda presentes
no model ate o commit.

@type  		Function
@author 	Jose Erik Belmonte
@since 		28/08/2026
@param 		oGrid, object, submodelo (FWFormGridModel) 
@return 	lTem - .T. se existe ao menos uma linha ativa (nao deletada)
/*/
//-------------------------------------------------------------------
Static Function LjGridTemLinha(oGrid)

Local lTem := .F.
Local nX   := 0

If !(oGrid == Nil)
	For nX := 1 To oGrid:Length()
		oGrid:GoLine(nX)
		If !oGrid:IsDeleted()
			lTem := .T.
			Exit
		EndIf
	Next nX
EndIf

Return lTem

//-------------------------------------------------------------------
/*/{Protheus.doc} LjReceAgro
Função para validar se deve habilitar os campos LR_CPFENG e LR_NUMREC

@type  		Function	
@author 	Bruno Almeida
@since 		11/11/2025
@return 	lRet - .T. habilita o campo para edição ou .F. desabilita.
/*/
//-------------------------------------------------------------------
Function LjReceAgro(cCodProd)

Local aArea    := GetArea()
Local lRet     := .F.
Local nPosItem := 0

If FWAliasInDic("NCR")

	If Empty(cCodProd)
		nPosItem := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]
		cCodProd := aCols[n][nPosItem]
	EndIf

	dbSelectArea("NCR")
	NCR->(dbSetOrder(1)) //NCR_FILIAL+NCR_PROD
	If NCR->(dbSeek(xFilial("NCR") + cCodProd))
		lRet := AllTrim(NCR->NCR_EMREC) == "1"
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGuiaAgro
Função para validar se deve habilitar os campos LR_NMRGUI, LR_SERGUI, LR_TPGUIA e LR_UFGUIA

@type  		Function	
@author 	Bruno Almeida
@since 		11/11/2025
@return 	lRet - .T. habilita o campo para edição ou .F. desabilita.
/*/
//-------------------------------------------------------------------
Function LjGuiaAgro(cCodProd)

Local aArea    := GetArea()
Local lRet     := .F.
Local nPosItem := 0

If FWAliasInDic("NCR")

	If Empty(cCodProd)
		nPosItem := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]
		cCodProd := aCols[n][nPosItem]
	EndIf

	dbSelectArea("NCR")
	NCR->(dbSetOrder(1)) //NCR_FILIAL+NCR_PROD
	If NCR->(dbSeek(xFilial("NCR") + cCodProd))
		lRet := AllTrim(NCR->NCR_EMGUIA) == "1"
	EndIf

EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LjProdAgro
Verifica se algum produto da venda esta com os campos NCR_EMGUIA ou NCR_EMREC
marcamos como Sim no cadastro de produto.

@type  		Function	
@author 	Bruno Almeida
@since 		11/11/2025
@return 	lRet - .T. caso encontre algum produto ou .F. caso nenhum produto esteja
                       marcado como SIM.
/*/
//-------------------------------------------------------------------
Static Function LjProdAgro()

Local lRet  := .F.
Local aArea := GetArea()

SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
If SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))

	While !lRet .And. SL2->(!Eof()) .And. AllTrim(SL2->L2_FILIAL + SL2->L2_NUM) == AllTrim(SL1->L1_FILIAL + SL1->L1_NUM)
		If LjReceAgro(SL2->L2_PRODUTO)
			lRet := .T.
		EndIf

		If !lRet .And. LjGuiaAgro(SL2->L2_PRODUTO)
			lRet := .T.
		EndIf

		SL2->(dbSkip())
	EndDo

EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} Lj7ItmAgro
Valida se na venda existem itens do AGRO de receituario e guia de transporte
@type  		Function	
@author 	joao.marcos
@since 		14/01/2026
@param 		cCodOrc, character, Codigo do orcamento/venda
@return 	lItensAgro - .T. indica que encontou item com guia de transporte e receituario marcado na venda atual
/*/
Function Lj7ItmAgro(cCodOrc)
Local lItensAgro 	:= .F.
Local aAreaSL2	 	:= SL2->( GetArea() )
Local lVendaAgro	:= "AGRO" $ SuperGetMv("MV_CADPROD", .F., "") .AND. SL2->(ColumnPos("L2_NUMREC")) > 0 .AND. SL2->(ColumnPos("L2_NMRGUI")) > 0 // Indica se o ambiente esta preparado para venda de item do AGRO
Local lItemRece		:= .F. // Indica a venda poosui item do agro e necessita receituario
Local lItemGuia		:= .F. // Indica a venda poosui item do agro e necessita guia de transporte

If lVendaAgro
	SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	If SL2->(dbSeek(xFilial("SL2") + cCodOrc))

		While SL2->(!Eof()) .And. ( AllTrim(SL2->L2_FILIAL + SL2->L2_NUM ) == AllTrim(xFilial("SL2") + cCodOrc ) )
			
			If GetAdvFVal("NCR","NCR_EMREC",xFilial('NCR') + SL2->L2_PRODUTO, 1) == "1"
				lItemRece := .T.

				If lItemGuia
					lItensAgro := .T.
					Exit
				EndIf
			EndIf

			If GetAdvFVal("NCR","NCR_EMGUIA",xFilial('NCR') + SL2->L2_PRODUTO, 1) == "1"
				lItemGuia := .T.

				If lItemRece
					lItensAgro := .T.
					Exit
				EndIf
			EndIf

			SL2->(dbSkip())
		EndDo

	EndIf

EndIf

RestArea(aAreaSL2)

Return lItensAgro

