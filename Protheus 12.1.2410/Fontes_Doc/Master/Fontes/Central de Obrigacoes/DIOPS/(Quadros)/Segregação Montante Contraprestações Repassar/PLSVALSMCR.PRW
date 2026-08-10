#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDMCR01

Funcao criada para validar Critica SM01
Valida o código do tipo de Débito de Operações de Administração de Benefícios

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDMCR01()
Local lRetorno	:= .F.

lRetorno	:= BVS->BVS_CODIGO $ '12347'

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDMCR02

Funcao criada para validar Critica SM02
Somatório dos Novos Avisos de Eventos com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDMCR02()
Local lRetorno	:= .F.
Local cWhere 	:= " "		// Soma todos os registros da competência
Local aConta	:= { '2136' }
	
lRetorno	:= PlVldMCRGe(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldMCRGe

Funcao criada para validar Critica do Segregação do Montante de Contraprestações a Repassar

@Parametros recebidos:
cCampo	-> Nome do campo referente ao mês do trimestre que irá validar
aConta	-> Array contendo as contas contábeis que validarão o total dos campos  

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldMCRGe(cWhere, aConta,oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp:= ""	
	Local cConta 	:= ""	
	Local nSldCob	:= 0
	Local nVez		:= 0
	Default oModel	:= Nil	
	Default cWhere	:= ''
	Default aConta	:= {}
	
	If Empty(aConta)
		Return(.F.)
	EndIf	

	For nVez := 1 to Len(aConta)
		cConta += aConta[nVez]+','   
	Next
	cConta := FormatIn(cConta,",")
	
	If oModel == Nil
		cCodOpe := AllTrim(B3D->B3D_CODOPE)
		cCodObr := AllTrim(B3D->B3D_CDOBRI)
		cAnoCmp := AllTrim(B3D->B3D_ANO)
		cCdComp := AllTrim(B3D->B3D_CODIGO)	
	Else
		cCodOpe	:= AllTrim(oModel:GetValue( 'BVSMASTER', 'BVS_CODOPE' )) 
		cCodObr	:= AllTrim(oModel:GetValue( 'BVSMASTER', 'BVS_CODOBR' )) 
		cAnoCmp	:= AllTrim(oModel:GetValue( 'BVSMASTER', 'BVS_ANOCMP' )) 
		cCdComp := AllTrim(oModel:GetValue( 'BVSMASTER', 'BVS_CDCOMP' ))
	EndIf

	cSql := " SELECT SUM(BVS_VLMES1+BVS_VLMES2+BVS_VLMES3) VALOR "
	cSql += "	FROM " + RetSqlName("BVS") 
	cSql += "	WHERE BVS_FILIAL = '" + xFilial("BVS") + "' " 
	cSql += "			AND BVS_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND BVS_CODOBR = '" + cCodObr + "' "
	cSql += "			AND BVS_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND BVS_CDCOMP = '" + cCdComp + "' "
	cSql += cWhere
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
		
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

	If !TRBCON->(Eof())	
		// Se há dados sobre o quadro, guarda valor para comparação com a conta	
		nSldCob	:= TRBCON->VALOR
	Else
		// Se nao há dados sobre o quadro, aborta validação retornando Verdadeiro
		Return(.T.)			
	EndIf
	TRBCON->(dbCloseArea())

	cSql := " SELECT SUM(B8A_SALFIN) AS VALCTB "
	cSql += "	FROM " + RetSqlName("B8A") 
	cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
	cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
	cSql += "			AND B8A_CONTA  IN " + cConta + " "
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
		
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB8A",.F.,.T.)

	If !TRBB8A->(Eof())	
		lRet := ( TRBB8A->VALCTB == nSldCob )
	Else
		lRet	:= .F.			
	EndIf
	TRBB8A->(dbCloseArea())
	 
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRISMCR

Funcao que cria os demais itens do quadro Segregação do Montante de Contraprestações a Repassar

@author RogerC
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRISMCR(cCodOpe,cCodObr,cCdComp,cAnoCmp,lAuto)
	Local cRefere	:= ''
	Local nFor		:= 0
	Local lRet		:= .T.
	Local cTipoBr	:= "3"	
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""                           
	Default lAuto   := .F.

	B3D->(dbSetOrder(3))
	B3D->(dbSeek(xFilial('B3D')+cCodOpe+cCodObr+cAnoCmp+cTipoBr+cCdComp))
	
	cRefere	:= B3DRefere()

	//Insere os demais itens no quadro
	For nFor := 1 TO 7

		// Descarta códigos 5 e 6 que nao existem	
		If nFor == 5 .or. nFor == 6
			Loop
		EndIf

		//Monta o where para verificar se existe o item no quadro
		cWhrQuadro := GetWhrQuadro("BVS",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND BVS_CODIGO = '"+StrZero(nFor,1)+"' "

		//Verifica se ja foi inserido o item no quadro
		If !ExisteEveInd(cWhrQuadro)
			//Vou inserir o registro nao encontrado
			InsereEveInd(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,StrZero(nFor,1),lAuto)
		EndIf
		
	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteEveInd

Funcao verifica se existe um evento no quadro Segregação do Montante de Contraprestações a Repassar

@author RogerC
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteEveInd(cWhrQuadro)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local lRet		:= .F.
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("BVS") + " WHERE D_E_L_E_T_ = ' ' AND " + cWhrQuadro
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			lRet := .T.
		EndIf

		(cAliTrb)->(dbCloseArea())

	EndIf

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsereEveInd

Funcao grava itens na tabela de Movimentação de Segregação do Montante de Contraprestações a Repassar

@author RogerC
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function InsereEveInd(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cCodigo,lAuto)
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cCodigo := ""
    Default lAuto   := .F.
    
	If !lAuto .And. !Empty(cCodigo)
		RecLock("BVS",.T.)
		BVS->BVS_FILIAL := xFilial("BVS")
		BVS->BVS_CODOPE := cCodOpe
		BVS->BVS_CODOBR := cCodObr
		BVS->BVS_ANOCMP := cAnoCmp
		BVS->BVS_REFERE := cRefere
		BVS->BVS_CDCOMP := cCdComp
		BVS->BVS_CODIGO := cCodigo
		BVS->BVS_VLMES1	:= 0 //Val(cCodigo)
		BVS->BVS_VLMES2 := 0 //Val(cCodigo)*2
		BVS->BVS_VLMES3 := 0 //Val(cCodigo)*3
		BVS->BVS_STATUS := "1"
		msUnLock()
	EndIf
Return