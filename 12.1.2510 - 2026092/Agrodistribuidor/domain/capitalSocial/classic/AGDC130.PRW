#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDC130.CH"


/*/{Protheus.doc} AGDC130
Browse da rotina de Evolução de Capital
@type function
@version 12
@author ronery.filho
@since 07/07/2026
@param cCodCoop,  Character, informa o código do cooperado, default nil
@param cLojaCoop, Character, informa a loja do cooperado, default nil
/*/
Function AGDC130(cCodCoop, cLojaCoop)
	Local aArea       	:= GetArea()
	Local oDlgNF4     	:= Nil
	Local oFwLayer    	:= Nil
	Local oMovimento 	:= Nil
	Local oSize       	:= Nil
	Local cAliasNF4 	:= Nil
	Local nTotCota 		:= 0
	Local nTotCapit 	:= 0
	Local oGet1			:= nil
	Local oGet2			:= nil
	Local oMBrowse 		:= Nil
	Local cFiltro		:= nil

	Default cCodCoop 	:= Nil
	Default cLojaCoop 	:= Nil

	If !FWAliasInDic("NF4")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	If cCodCoop == Nil .And. cLojaCoop == Nil
		While  Empty(MV_PAR01) .and. Empty(MV_PAR02) .and. Empty(MV_PAR03)
			If !Pergunte( "AGDC130", .T.)
				Return Nil
			Endif
		Enddo

	Endif

	cFiltro := fGetFiltro(cCodCoop, cLojaCoop) //via parametro do pergunte(AGDC130)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )
	oSize:lLateral	:= .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	oDlgNF4 := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] , oSize:aWindSize[4] ,	STR0001 , , , , , CLR_BLACK, CLR_WHITE, , , .T. ) //Consulta Evolução de Capital

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlgNF4, .F., .T. )

	oFWLayer:AddLine( 'MOVIMENTOS', 90, .F. )
	oFWLayer:AddLine( 'TOTAL', 10, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'MOVIMENTOS' )
	oMovimento := oFWLayer:GetColPanel( 'ALL', 'MOVIMENTOS' )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'TOTAL' )
	oTotal := oFWLayer:GetColPanel( 'ALL', 'TOTAL' )

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetOwner(oMovimento)
	oMBrowse:SetAlias( "NF4" )
	oMBrowse:SetFilterDefault(cFiltro)
	oMBrowse:SetDescription( STR0002 )  //"Evolução de Capital"
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef("")
	oMBrowse:Activate()
	cAliasNF4 := oMBrowse:Alias()

	nTotCota := Posicione('NF3', 1, FwXfilial('NF3')+(cAliasNF4)->NF4_CODCOO+(cAliasNF4)->NF4_LOJCOO, 'NF3_QTDCOT')
	oSay1 := TSay():New(01,01,{||STR0003}, oTotal) //Total Cota
	oGet1 := TGet():New( 002, 001, bSetGet( nTotCota ),oTotal,050,009, "@E 99,999,999.99",,,,,,,,,,,,,,,,,,,,,,.T.)
	oGet1:lReadOnly := .T.
	nTotCapit := Posicione('NF3', 1, FwXfilial('NF3')+(cAliasNF4)->NF4_CODCOO+(cAliasNF4)->NF4_LOJCOO, 'NF3_VALCOT')
	oSay2 := TSay():New(01,10,{||STR0004}, oTotal) //Total Capital Social
	oGet2 := TGet():New( 002, 010, bSetGet( nTotCapit ),oTotal,050,009, "@E 99,999,999.99",,,,,,,,,,,,,,,,,,,,,,.T.)
	oGet2:lReadOnly := .T.

	oDlgNF4:Activate( , , , .T., { || .T. }, ,  )

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} fGetFiltro
Busca o filtro para o browser conforme os parametros do pergunte(AGDC130) da tela 
@type function
@version 12  
@author claudineia.reinert
@since 19/08/2026
@return Character, filtro montado para o browser
/*/
Static Function fGetFiltro(cCodCoop, cLojaCoop)
	Local aFiltro := {}

	If cCodCoop == Nil .And. cLojaCoop == Nil
		Pergunte( "AGDC130", .F.) 
		If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02) //codigo e loja do cooperado
			AAdd(aFiltro, "NF4_CODCOO = '" + MV_PAR01 + "' AND NF4_LOJCOO = '" + MV_PAR02 + "'")
		Endif

		If !Empty(MV_PAR03) //matricula do cooperado
			DBSelectArea("NEP")
			NEP->(DBSetOrder(3)) //NEP_FILIAL+NEP_MATRIC
			If NEP->(DBSeek(FWxFilial('NEP')+MV_PAR03))
				AAdd(aFiltro, "NF4_CODCOO = '" + NEP->NEP_CODCLI + "' AND NF4_LOJCOO = '" + NEP->NEP_LOJCLI + "'")
			Else
				AAdd(aFiltro, "NF4_CODCOO = '' AND NF4_LOJCOO = '' ") //não encontrou a matricula
			Endif
		Endif
	Else
		cCodCoop :=  IIF(cCodCoop == Nil,  "", cCodCoop)
		cLojaCoop := IIF(cLojaCoop == Nil, "", cLojaCoop)
		AAdd(aFiltro, "NF4_CODCOO = '" + cCodCoop + "' AND NF4_LOJCOO = '" + cLojaCoop + "'")
	Endif

Return fMontaFiltro(aFiltro)

/*/{Protheus.doc} fMontaFiltro
Monta o filtro para o browser
@type function
@version 12 
@author claudineia.reinert
@since 19/08/2026
@param aFiltro, array, array com os filtros a serem aplicados
@return Character, filtro montado para o browser
/*/
Static Function fMontaFiltro( aFiltro)
	Local cFiltroFix 	:= "@NF4_STATUS = '1' AND NF4_FILIAL = '" + FwXFilial('NF4') + "' "
	Local nX 			:= 0

	If Len(aFiltro) > 0
		cFiltro := cFiltroFix
		For nX := 1 To Len(aFiltro)
			cFiltro += " AND " + aFiltro[nX]
		Next
	Endif

Return cFiltro
