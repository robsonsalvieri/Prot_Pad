#Include "protheus.ch"
#Include "fwmvcdef.ch"
#INCLUDE "AGDP080.CH"


/*/{Protheus.doc} AGDP080UFS
Consulta especifica NEZ012
Abre a tela com o MarkBrowse
São as definições da interface
@author carlos.augusto/jean.schulze
@since 28/10/2025
/*/
Function AGDP080UFS()
	Local aColumns	:= {}
	Local lMarkAll	:= .f.
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local oMarkUF   := Nil
	Local cTheme    := totvs.framework.css.getNewWebAppTheme()
	Local lIsDark   := iif(!empty(cTheme) .and. cTheme == "DARK", .T., .F.) //Valida se o tema ativo é o dark
	
	Private _oTempTbl  := Nil            //Objeto único da Tabela temporária
	Private _oFwExecUF := Nil            //FwExecStatement único para busca dos estados
	Private _cAliasTMP := GetNextAlias() //Cria uma única para consulta de estados


	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F. 	
	oSize:Process() 

	If lIsDark
		oDlg := TDialog():New(0, 5, 440,430, STR0006,,,,,,,,,.T.) //"Seleção de Estados (UF)"
	Else
		oDlg := TDialog():New(0, 5, 440,430, STR0006, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Seleção de Estados (UF)"
	EndIf

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := TPanel():New( 10, 5, ,oDlg, , , , , ,200, 200)
								

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||TMP_UF}"))

	aColumns[Len(aColumns)]:SetTitle( "UF" )
	aColumns[Len(aColumns)]:SetSize(TamSx3("A1_EST")[1])
	aColumns[Len(aColumns)]:SetDecimal(TamSx3("A1_EST")[2])
	aColumns[Len(aColumns)]:SetPicture(X3PICTURE("A1_EST"))

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||TMP_DESUF}"))

	aColumns[Len(aColumns)]:SetTitle( "Desc. UF" )
	aColumns[Len(aColumns)]:SetSize(TamSx3("A1_ESTADO")[1])
	aColumns[Len(aColumns)]:SetDecimal(TamSx3("A1_ESTADO")[2])
	aColumns[Len(aColumns)]:SetPicture(X3PICTURE("A1_ESTADO "))

	AGDP80Temp() //Executa a criação da tabela temporária e insere os estados na mesma

	oMarkUF:=FWMarkBrowse():NEW()  
	oMarkUF:SetAlias(_cAliasTMP)
	oMarkUF:SetDescription( STR0006 ) //"Seleção de Estados (UF)"
	oMarkUF:SetColumns(aColumns)
	oMarkUF:SetFieldMark("MARK")	
	oMarkUF:SetCustomMarkRec({||AGDP80Mark( oMarkUF )})
	oMarkUF:bAllMark := { ||SetMarkAll(oMarkUF, lMarkAll := ! lMarkAll ), oMarkUF:Refresh(.T.)    }
	oMarkUF:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oMarkUF:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	oMarkUF:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	oMarkUF:DisableReport()	// Desabilita a opcao de imprimir
	oMarkUF:SetMenuDef( "" )
	oMarkUF:Activate(oPnDown)

	//Antes de abrir, caso tenham UF já preenchidas no campo NEZ_LISTUF, faz a marcação destas na tela
	AGDP80Prev(oMarkUF)

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| AGDP80Salv( oMarkUF ), oDlg:End(), NIL},{|| oDlg:End() },,/* @aButtons */) } )

	RestArea(aArea)

	(_cAliasTMP)->(dbCloseArea()) //Exclui a area criada para os estados
	_oFwExecUF := Nil
	_oTempTbl  := Nil
Return .T.


/*/{Protheus.doc} AGDP080RET
Retorno da Consulta especifica NEZ012 ao clicar em Salvar ou Cancelar na tela
@author carlos.augusto
@since 28/10/2025
/*/
Function AGDP080RET()
Return(_cUFSelect)


/*/{Protheus.doc} AGDP80Temp
Geração da estrutura e dados da tabela temporária para os estados
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Temp()

	AGDP80Strt()
	AGDP80Data()

Return .T.


/*/{Protheus.doc} AGDP80Strt
Geração da estrutura da tabela temporária para os estados
Executa somente uma vez a estrutura para a tabela temporária
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Strt()
	Local nX       := 1
	Local aCposTmp := {}
	Local aIndex   := {}

	If _oTempTbl == Nil
		aCposTmp := {{"MARK" , 'C' ,2,1},;
		{"TMP_UF"    , TamSX3("A1_EST")[3],    TamSX3("A1_EST")[1],    TamSX3("A1_EST")[2]},;
		{"TMP_DESUF" , TamSX3("A1_ESTADO")[3], TamSX3("A1_ESTADO")[1], TamSX3("A1_ESTADO")[2]}}

		aIndex := {}
		aadd(aIndex,{"TMP_UF"}) 

		_oTempTbl:= FWTemporaryTable():New( _cAliasTMP )	
		_oTempTbl:SetFields(aCposTmp)						
		For nX := 1 to Len (aIndex)
			_oTempTbl:AddIndex( cValtochar(nX),aIndex[nX] )
		next nX
		_oTempTbl:Create()
	EndIf

Return 


/*/{Protheus.doc} AGDP80Data
Geração dos dados para a tabela temporária de estados
Executa somente uma vez a base de dados para a tabela temporária
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Data()
	Local cSql     := ""
	Local nPos     := 0
	Local aEstados := FWGetSX5("12")
	Local nX       := 1

	If _oFwExecUF == Nil
 		cSql := "INSERT INTO ? (MARK, TMP_UF, TMP_DESUF) VALUES "
		For nX := 1 To Len(aEstados)
			cSql += "(' ',?,?)"
			If nX < Len(aEstados)
				cSql += ","
			EndIf
		Next
		_oFwExecUF := FwExecStatement():New(cSql)
		_oFwExecUF:SetUnsafe(++nPos, _oTempTbl:GetRealName())

		If _oFwExecUF != Nil
			AEval(aEstados,{|estado| _oFwExecUF:SetString(++nPos, AllTrim(estado[3]) ), _oFwExecUF:SetString(++nPos, estado[4] ) })
		EndIf
		cSql := _oFwExecUF:GetFixQuery()
		TCSqlExec(cSql)
	EndIf
	(_cAliasTMP)->( dbGoTop() )
Return 


/*/{Protheus.doc} AGDP80Mark
Marca registro na temporária
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Mark( oMrkBrowse )
	Local aAreaAtu	:= GetArea()

	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
	else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK  := "  "
		(oMrkBrowse:Alias())->(MsUnLock())
	endif
	RestArea( aAreaAtu )
Return( .T. )


/*/{Protheus.doc} SetMarkAll
Marca ou desmarca todos os registros
@author carlos.augusto
@since 28/10/2025
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )
	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )
		AGDP80Mark( oMrkBrowse)
		(oMrkBrowse:Alias())->(DbSkip() )
	EndDo
Return .T.


/*/{Protheus.doc} AGDP80Salv
Ao clicar em Salvar na consulta especifica, envia os estados selecionados a variavel _cUFSelect
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Salv(oBrwMrk)
	Local lRet 			:= .T.
	Local aArea			:= GetArea()
    Local cUFSelec	:= ""

	(_cAliasTMP)->(dbGoTop())
	While .Not. (_cAliasTMP)->(Eof())
		If oBrwMrk:IsMark()
			If !Empty(cUFSelec)
				cUFSelec += ";"
			EndIf
			cUFSelec +=   (_cAliasTMP)->TMP_UF
		EndIf
		(_cAliasTMP)->(dbSkip())
	EndDo
	_cUFSelect := cUFSelec
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
Return lRet


/*/{Protheus.doc} AGDP80Prev
Faz a remarcao dos estados na consulta especifica quando acionada com o campo NEZ_LISTUF preenchido.
@author carlos.augusto
@since 28/10/2025
/*/
Static Function AGDP80Prev(oBrwMrk)
	Local oModel     := FwModelActive()
	Local oNEZ		 := oModel:GetModel(_cModelSXBNEZ)
	Local aArea		 := GetArea()
    Local aEstados	 := STRTOKARR ( oNEZ:GetValue(_cFieldSXBNEZ ) , ";" )
    Local nI         := 0

	_cUFSelect := oNEZ:GetValue(_cFieldSXBNEZ )
    
    If .Not. Empty(aEstados)          
		(_cAliasTMP)->(dbGoTop())
		While .Not. (_cAliasTMP)->(Eof())
			For nI := 1 To Len(aEstados)
				If aEstados[nI] = (_cAliasTMP)->TMP_UF
					oBrwMrk:MarkRec()
					Exit
				Else
					(oBrwMrk:Alias())->MARK  := "  "
				EndIf
			Next nI
			(_cAliasTMP)->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
	
Return .T.
