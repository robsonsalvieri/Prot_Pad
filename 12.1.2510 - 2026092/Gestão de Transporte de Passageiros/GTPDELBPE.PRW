#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'GTPDELBPE.CH'

/*/{Protheus.doc} GTPDELBPE()
	Exclusão de nota fiscal BPE
	@type function
	@author José Carlos	
	@since 06/10/2025
	@version 1.0
	@param
	@return ${return}, ${return_description}
	@example
	(examples)
	@see (links_or_references)
/*/
Function GTPDELBPE()
	Local aAreaAtu  := GetArea()
	Local cQuery    := ''
	Local aColumns  := {}
	Local aFields   := {}
	Local n         := 0
    Local aParamBox := {}
    Local aRet      := {}
    Local aMvPar    := {}
    Local nX        := 0
	Local cAlias    := ''
	Local oMark     := Nil
    Local lMarca    := .T.
    Local lProcessa := .F.

    For nX := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    Next nX  

    aAdd(aParamBox,{1,STR0001, Ctod(Space(8)),"","","","",50,.F.})    //"Data Nota:"
    aAdd(aParamBox,{1,STR0002, Space(GetSX3Cache('G59_AGENCI', 'X3_TAMANHO')),"@!", ,"GI6", ,50,.F.})   //"Agência:"

    If ParamBox(aParamBox,STR0004,@aRet)  //"Informe os parâmetros..."
        lProcessa := .T.
    EndIF        

    For nX := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
    Next nX

    If lProcessa .And. CtbValiDt(3,aRet[1],.T.)
		Pergunte("MTA521",.F.)
		SetKey(VK_F12,{||Pergunte("MTA521",.T.)})    

		cAlias    := GetNextAlias()
		Aadd( aFields,{'F2_OK'		 ,GetSx3Cache('F2_OK'	    ,'X3_TITULO'),GetSx3Cache('F2_OK'	    ,'X3_TAMANHO')})
		Aadd( aFields,{'F2_MARK'	 ,'MARK', 01 })
		Aadd( aFields,{'F2_FILIAL'	,GetSx3Cache('F2_FILIAL'	,'X3_TITULO'),GetSx3Cache('F2_FILIAL'	,'X3_TAMANHO')})
		Aadd( aFields,{'F2_DOC'		,GetSx3Cache('F2_DOC'		,'X3_TITULO'),GetSx3Cache('F2_DOC'		,'X3_TAMANHO')})
		Aadd( aFields,{'F2_SERIE'	,GetSx3Cache('F2_SERIE' 	,'X3_TITULO'),GetSx3Cache('F2_SERIE'	,'X3_TAMANHO')})
		Aadd( aFields,{'F2_CLIENTE'	,GetSx3Cache('F2_CLIENTE'	,'X3_TITULO'),GetSx3Cache('F2_CLIENTE'	,'X3_TAMANHO')})
		Aadd( aFields,{'F2_LOJA'	,GetSx3Cache('F2_LOJA'  	,'X3_TITULO'),GetSx3Cache('F2_LOJA'		,'X3_TAMANHO')})
		Aadd( aFields,{'F2_EMISSAO'	,GetSx3Cache('F2_EMISSAO'	,'X3_TITULO'),GetSx3Cache('F2_EMISSAO'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_AGENCI'	,GetSx3Cache('GIC_AGENCI'	,'X3_TITULO'),GetSx3Cache('GIC_AGENCI'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_DTVEND'	,GetSx3Cache('GIC_DTVEND'	,'X3_TITULO'),GetSx3Cache('GIC_DTVEND'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_STATUS'	,GetSx3Cache('GIC_STATUS'	,'X3_TITULO'),GetSx3Cache('GIC_STATUS'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_CODIGO'	,GetSx3Cache('GIC_CODIGO'	,'X3_TITULO'),GetSx3Cache('GIC_CODIGO'	,'X3_TAMANHO')})
		Aadd( aFields,{'F2_CHVNFE'	,GetSx3Cache('F2_CHVNFE'	,'X3_TITULO'),GetSx3Cache('F2_CHVNFE'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_CHVBPE'	,GetSx3Cache('GIC_CHVBPE'	,'X3_TITULO'),GetSx3Cache('GIC_CHVBPE'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_CHVSUB'	,GetSx3Cache('GIC_CHVSUB'	,'X3_TITULO'),GetSx3Cache('GIC_CHVSUB'	,'X3_TAMANHO')})
		Aadd( aFields,{'GIC_CHVACE'	,GetSx3Cache('GIC_CHVACE'	,'X3_TITULO'),GetSx3Cache('GIC_CHVACE'	,'X3_TAMANHO')})

		cQuery += "SELECT "
		For n:=1 To Len(aFields)
			cQuery += Iif(Alltrim(aFields[n][1])=='F2_MARK',"' ' F2_MARK",Alltrim(aFields[n][1])) + Iif(n<Len(aFields),',','') 
		Next n 
		cQuery += " FROM "+RetSqlName('SF2')+ " SF2 "
		cQuery += "INNER JOIN "+RetSqlName('GIC')+ " GIC ON GIC_FILIAL = '"+xFilial('GIC')+"' AND "
		cQuery += "GIC_FILNF = '"+xFilial("SF2")+"' AND GIC_NOTA = F2_DOC AND GIC_CLIENT = F2_CLIENTE "
		cQuery += "AND GIC_LOJA = F2_LOJA AND GIC_SERINF = F2_SERIE "
		cQuery += "AND GIC.D_E_L_E_T_ = ' '"
		cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND F2_EMISSAO = '"+DtoS(aRet[1])+"' "

		If !Empty(aRet[2])
			cQuery += "AND GIC_AGENCI = '"+aRet[2]+"' " 
		EndIf 
        cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY F2_FILIAL,F2_DOC"

		For n:=1 To Len(aFields)
			If !(Alltrim(aFields[n][1]) $ 'F2_OK|F2_MARK')
				AAdd( aColumns, FWBrwColumn():New() )
				aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[n][1] + " }") )
				aColumns[Len(aColumns)]:SetTitle( aFields[n][2] )
				aColumns[Len(aColumns)]:SetSize( aFields[n][3] )
				aColumns[Len(aColumns)]:SetID( aFields[n] )		
			Endif
		Next n

		oMark:= FWMarkBrowse():New()
		oMark:SetDescription(STR0005)	//'Seleção de Notas BPE - Exclusão'    
		oMark:AddButton(STR0006, {|| InitProcessa(oMark) }) //"Confirmar"
		oMark:AddButton("Marca/DesMarca Todos", {|| SetMarkAll(oMark,lMarca),lMarca:= !lMarca,oMark:Refresh() }) //"Marca/DesMarca Todos"
		oMark:SetColumns( aColumns )
		oMark:SetDataQuery()
		oMark:SetQuery( cQuery )
		oMark:SetAlias( cAlias )
		oMark:SetMenuDef('')
		oMark:SetFieldMark( 'F2_OK' )
		oMark:ForceQuitButton(.t.)
		oMark:SetFilterDefault( "F2_MARK = ' ' " )
		oMark:Refresh(.T.)
		oMark:GoTop(.T.)

    	oMark:Activate()

	EndIf 

    If oMark <> NIl 
        oMark:DeActivate()
        FreeObj(oMark)
        oMark:= Nil
    EndIf 

	aSize(aColumns,0)
	aSize(aFields,0)
    aSize(aParamBox,0)
    aSize(aRet,0)
    aSize(aMvPar,0)
    
    SetKey(VK_F12,Nil)
	
    RestArea( aAreaAtu )
Return 

/*/{Protheus.doc} InitProcessa(oMark)
	Função avalia se existe registro para processamento e solicita confirmação do usuário.
	@type function
	@author José Carlos	
	@since 06/10/2025
	@version 1.0
	@param
	@return ${return}, ${return_description}
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function InitProcessa(oMark)
	If (oMark:Alias())->(!Eof()) 
		If FWAlertYesNo(STR0007, STR0008)   //"Confirma a exclusão da(s) nota(s)?" "Atenção!"
			Processa( {||ProcNotas( oMark ) }) 
			oMark:Refresh(.T.)
		EndIf 
	Else 
		FWAlertWarning(STR0009, STR0010) //"Não localizado registro(s) para processamento."   "Alerta!"
	EndIf 		
Return 

/*/{Protheus.doc} ProcNotas(oMark)
	Função de processamento de nota fiscal BPE marcadas
	@type function
	@author José Carlos	
	@since 06/10/2025
	@version 1.0
	@param
	@return ${return}, ${return_description}
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ProcNotas(oMark)
	Local aArea         := GetArea()
	Local cAliasMark    := oMark:Alias()
	Local cMarca        := oMark:Mark()
	Local cSeekCDA      := ''
    Local lAglCtb       := MV_PAR02 == 1
	Local lAutomatico   := .T.
    Local lCarteira     := .F.
    Local lContab       := MV_PAR03 == 1
    Local nOpc          := 1
	Local nStart        := Seconds()
	Private lMsErroAuto := .F.

	GIC->(DbSetOrder(01))   // GIC_CODIGO
	SF2->(DbSetOrder(01))	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
	CDA->(DbSetOrder(03))	// CDA_FILIAL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA

	(cAliasMark)->( dbGoTop() )
	While !(cAliasMark)->( EOF() )
		If oMark:IsMark(cMarca)	// Registro marcado
			
			If !Empty((cAliasMark)->GIC_CHVSUB)
				If !MNSubs((cAliasMark)->GIC_CHVSUB, oMark, cMarca, @cAliasMark)
					RecLock(cAliasMark, .F.)
						(cAliasMark)->F2_OK := Space(Len(cMarca))
					(cAliasMark)->(MsUnlock())
					(cAliasMark)->(DbSkip())
					Loop
				EndIf
			EndIf

			FwLogMsg("INFO", "LAST", "PROCNOTAS", FunName(), "", "GTPDELBPE", " INFO GTPDELBPE CHAVE INICIO: Filial:" + xFilial("SF2") + " Doc:" + (cAliasMark)->F2_DOC + " Serie:" + (cAliasMark)->F2_SERIE + " Cliente:" + (cAliasMark)->F2_CLIENTE + " Loja:" + (cAliasMark)->F2_LOJA, 0, (nStart - Seconds()), {})

			If SF2->(DbSeek(xFilial("SF2")+(cAliasMark)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
				Sf2Mkar(cMarca)
				cSeekCDA := xFilial('CDA') + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
			EndIf 

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z,a,b,c,d| MATA521A(x,y,z,a,b,c,d)},lAutomatico,'SF2',cMarca,nOpc,lAglCtb,lContab,lCarteira)

			FwLogMsg(Iif(lMsErroAuto, "ERROR", "INFO"), "LAST", "PROCNOTAS", FunName(), "", "GTPDELBPE", Iif(lMsErroAuto, "ERROR", "INFO") + " GTPDELBPE CHAVE FIM: Filial:" + xFilial("SF2") + " Doc:" + (cAliasMark)->F2_DOC + " Serie:" + (cAliasMark)->F2_SERIE + " Cliente:" + (cAliasMark)->F2_CLIENTE + " Loja:" + (cAliasMark)->F2_LOJA, 0, (nStart - Seconds()), {})
			
			If(lMsErroAuto,Sf2Mkar(),)
			
			If lMsErroAuto
				MostraErro()
			Else
				//Habilita para gerar Nota BPE
				If GIC->(DbSeek(xFilial('GIC')+(cAliasMark)->GIC_CODIGO))
					RecLock("GIC",.F.)
						GIC->GIC_NOTA 	:= ''
						GIC->GIC_CLIENT := ''
						GIC->GIC_LOJA   := ''
						GIC->GIC_STAPRO := '0'
						GIC->GIC_FILNF	:= ''
						GIC->GIC_SERINF := ''
					GIC->(MsUnlock())
				EndIf 
				RecLock(cAliasMark,.F. )
					(cAliasMark)->F2_MARK := 'X' // Atualiza filtro do FwMarkBrowse
				(cAliasMark)->(MsUnlock())
				If CDA->( DbSeek( cSeekCDA ) )
					While CDA->(!Eof()) .And. CDA->(CDA_FILIAL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA) == cSeekCDA
						RecLock("CDA",.F.)
							CDA->(DBDelete())
						CDA->(MsUnLock())
						CDA->(DbSkip())
					EndDo 
				EndIf 

				//Nesse ponto validar e excluir todos os itens da SF3/SFT que ainda possam existir, garantindo que não haja duplicidade em nova geração
				GtpDelSFTSF3((cAliasMark)->F2_SERIE,(cAliasMark)->F2_DOC, (cAliasMark)->F2_DOC, (cAliasMark)->F2_CLIENTE,(cAliasMark)->F2_CLIENTE, (cAliasMark)->F2_LOJA, (cAliasMark)->F2_LOJA)

			EndIf 
		EndIf
		(cAliasMark)->( dbSkip() )
	End

	RestArea( aArea )
Return 
/*/{Protheus.doc} SetMarkAll
    Seleção de registros
	@author Cleiton Genuino da Silva
	@type function
	@since 13/08/2026
	@version 1.0
	@param oMark, object, Marca
	@param lMarca, logical, Marca/Desmarca
/*/
Static Function SetMarkAll(oMark, lMarca)

	Local cMarca     := oMark:Mark()
	Local cAliasMark := oMark:Alias()
	Local aAreaMark  := (cAliasMark)->(GetArea())
	
	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )
	
	While !(cAliasMark)->( Eof() )
		RecLock( cAliasMark, .F. )
			(cAliasMark)->F2_OK := Iif(lMarca,cMarca,Space(04))
		(cAliasMark)->(MsUnLock())
		
		(cAliasMark)->(dbSkip())
	EndDo

    RestArea(aAreaMark)

Return
/*/{Protheus.doc} GetChavesSub
	Retorna a chave informada e todas as chaves de substituição relacionadas.
	@type function
	@author Cleiton Genuino da Silva
	@since 21/08/2026
	@param cChvSub, character, Chave inicial de substituição
	@return array, Array com todas as chaves de substituição
/*/
Static Function GetChavesSub(cChvSub as character)
	Local aChaves := {} as array

	GetCRec(cChvSub, @aChaves)

Return aChaves
/*/{Protheus.doc} GetCRec
	Retorna a chave informada e todas as chaves de substituição relacionadas.
	@type function
	@author Cleiton Genuino da Silva
	@since 21/08/2026
	@param cChvSub, character, Chave inicial de substituição
	@return array, Array com todas as chaves de substituição
/*/
Static Function GetCRec(cChvSub as character, aChaves as array)
	Local cAliasQry := GetNextAlias() as character
	Local cQuery    := "" as character
	Local cChvProx  := "" as character

	If Empty(cChvSub) .Or. AScan(aChaves, {|cChave| cChave == cChvSub}) > 0
		Return aChaves
	EndIf

	AAdd(aChaves, cChvSub)
	cQuery := "SELECT GIC_CHVSUB "
	cQuery += "FROM " + RetSqlName('GIC') + " GIC "
	cQuery += "WHERE GIC_FILIAL = '" + xFilial('GIC') + "' "
	cQuery += "AND GIC_CHVBPE = '" + cChvSub + "' "
	cQuery += "AND GIC_CHVSUB <> ' ' "
	cQuery += "AND GIC.D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbGoTop())
		While !(cAliasQry)->(Eof())
			cChvProx := AllTrim((cAliasQry)->GIC_CHVSUB)
			If !Empty(cChvProx)
				GetCRec(cChvProx, @aChaves)
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

Return aChaves

/*/{Protheus.doc} MNSubs
    Apresenta dialog para marcar e incluir na exclusão as notas da mesma chave de substituição
	@author Cleiton Genuino da Silva
	@type function
	@since 13/08/2026
	@version 1.0
	@param cChvSub, character, Chave de Substituição
	@param oMarkOrig, object, Marca do browse principal
	@param cMarcaOrig, character, Marca do browse principal
	@param cAliasMark, character, Alias do browse principal

/*/
Static Function MNSubs(cChvSub as character, oMarkOrig as object, cMarcaOrig as character, cAliasMark as character)
	Local aCampos     := {}  as array
	Local aColumns    := {}  as array
	Local aSize       := {}  as array
	Local cAliasSubst := ""  as character
	Local cQuery      := ""  as character
	Local lMarcaSubst := .T. as logical
	Local n           := 1   as numeric
	Local oDlgSubst   := nil as object
	Local oMarkSubst  := nil as object
	Local lConfirmado := .F. as logical
	Local aChavesSub  := {} as array
	Local cChavesSql  := "" as character
	
	aSize := MsAdvSize()
	cAliasSubst := GetNextAlias()
	aChavesSub := GetChavesSub(cChvSub)
	For n := 1 To Len(aChavesSub)
		If n > 1
			cChavesSql += ","
		EndIf
		cChavesSql += "'" + aChavesSub[n] + "'"
	Next n

	// Define os campos do browse secundário (conforme fluxo exclusao.md)
	AAdd(aCampos, {'OK'         , 'Mark'                                 , 02})
	AAdd(aCampos, {'GIC_CODIGO' , GetSx3Cache('GIC_CODIGO','X3_TITULO')  , GetSx3Cache('GIC_CODIGO','X3_TAMANHO')})
	AAdd(aCampos, {'F2_DOC'     , GetSx3Cache('F2_DOC','X3_TITULO')      , GetSx3Cache('F2_DOC','X3_TAMANHO')})
	AAdd(aCampos, {'F2_SERIE'   , GetSx3Cache('F2_SERIE','X3_TITULO')    , GetSx3Cache('F2_SERIE','X3_TAMANHO')})
	AAdd(aCampos, {'GIC_DTVEND' , GetSx3Cache('GIC_DTVEND','X3_TITULO')  , GetSx3Cache('GIC_DTVEND','X3_TAMANHO')})
	AAdd(aCampos, {'GIC_STATUS' , GetSx3Cache('GIC_STATUS','X3_TITULO')  , GetSx3Cache('GIC_STATUS','X3_TAMANHO')})
	AAdd(aCampos, {'GIC_CHVSUB' , GetSx3Cache('GIC_CHVSUB','X3_TITULO')  , GetSx3Cache('GIC_CHVSUB','X3_TAMANHO')})
	// Campos ocultos, apenas para uso em processamento no cursor original
	AAdd(aCampos, {'F2_CLIENTE' , 'Cliente'                              , 6})
	AAdd(aCampos, {'F2_LOJA'    , 'Loja'                                 , 2})

	// Construção da Query filtrando a mesma chave
	cQuery := "SELECT '  ' AS OK, GIC_CODIGO, GIC_NOTA AS F2_DOC, GIC_SERINF AS F2_SERIE, GIC_DTVEND, GIC_STATUS, GIC_CHVSUB, GIC_CLIENT AS F2_CLIENTE, GIC_LOJA AS F2_LOJA "
	cQuery += " FROM " + RetSqlName('GIC') + " GIC "
	cQuery += " WHERE GIC_FILIAL = '" + xFilial('GIC') + "' "
	cQuery += " AND GIC_CHVBPE IN (" + cChavesSql + ") "
	cQuery += " AND GIC.D_E_L_E_T_ = ' ' "
	// Oculta a nota atual que disparou o popup
	cQuery += " AND GIC_CODIGO <> '" + (cAliasMark)->GIC_CODIGO + "' "
	cQuery += " AND GIC_DTVEND >= '" + (cAliasMark)->F2_EMISSAO + "' "
	cQuery += " ORDER BY GIC_DTVEND "

	For n := 1 To Len(aCampos)
		If aCampos[n][1] != 'OK' .And. aCampos[n][1] != 'F2_CLIENTE' .And. aCampos[n][1] != 'F2_LOJA'
			AAdd(aColumns, FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{ || " + aCampos[n][1] + " }") )
			aColumns[Len(aColumns)]:SetTitle( aCampos[n][2] )
			aColumns[Len(aColumns)]:SetSize( aCampos[n][3] )
			aColumns[Len(aColumns)]:SetID( aCampos[n] )
		EndIf
	Next n

	// Criação da Interface e FWMarkBrowse
	DEFINE MSDIALOG oDlgSubst TITLE "Notas com a Mesma Chave de Subscrição (" + AllTrim(cChvSub) + ")" FROM aSize[7]/2,0 TO aSize[6]/2,aSize[5]/2 PIXEL
	
	oMarkSubst := FWMarkBrowse():New()
	oMarkSubst:SetOwner(oDlgSubst)
	oMarkSubst:SetDescription("Selecione as notas que deseja excluir junto com a principal:")
	oMarkSubst:AddButton("ConFirma Sub.", {|| lConfirmado := ConfExcSub(oMarkSubst, cAliasSubst, oMarkOrig, cMarcaOrig, @cAliasMark, oDlgSubst) })
	oMarkSubst:AddButton("Marca/DesMarca Todos", {|| SetAllSub(oMarkSubst, lMarcaSubst), lMarcaSubst := !lMarcaSubst, oMarkSubst:Refresh() })
	oMarkSubst:AddButton("Sair", {|| oDlgSubst:End() })
	
	oMarkSubst:SetColumns(aColumns)
	oMarkSubst:SetDataQuery()
	oMarkSubst:SetQuery(cQuery)
	oMarkSubst:SetAlias(cAliasSubst)
	oMarkSubst:SetFieldMark('OK')
	oMarkSubst:ForceQuitButton(.F.)
	
	ACTIVATE MSDIALOG oDlgSubst CENTER ON INIT oMarkSubst:Activate()
	
	If oMarkSubst <> Nil
		oMarkSubst:DeActivate()
		FreeObj(oMarkSubst)
	EndIf
	
	If (Select(cAliasSubst) > 0,(cAliasSubst)->(DbCloseArea()),)
	
Return lConfirmado

/*/{Protheus.doc} ConfExcSub
    Valida, avisa e inclui as notas filhas selecionadas no cursor principal
	@author Cleiton Genuino da Silva
	@type function
	@since 13/08/2026
	@version 1.0
	@param oMarkSubst, object, Marca do browse secundário
	@param cAliasSubst, character, Alias do browse secundário
	@param oMarkOrig, object, Marca do browse principal
	@param cMarcaOrig, character, Marca do browse principal
	@param cAliasMark, character, Alias do browse principal
	@param oDlg, object, Dialog do browse secundário

/*/
Static Function ConfExcSub(oMarkSubst as object, cAliasSubst as character, oMarkOrig as object, cMarcaOrig as character, cAliasMark as character, oDlg as object)
	Local nMarcadas := 0
	Local cMarcaSubst := oMarkSubst:Mark()
	Local aAreaSubst := (cAliasSubst)->(GetArea())
	Local aAreaMark  := (cAliasMark)->(GetArea())
	Local lAchou := .F.
	Local lConfirmado := .F.
	
	(cAliasSubst)->(DbGoTop())
	While !(cAliasSubst)->(Eof())
		If oMarkSubst:IsMark(cMarcaSubst)
			nMarcadas++
		EndIf
		(cAliasSubst)->(DbSkip())
	EndDo
	
	If nMarcadas > 0
		If FWAlertYesNo("Deseja excluir " + cValToChar(nMarcadas) + " nota(s) selecionada(s)?", "Confirmação")
			(cAliasSubst)->(DbGoTop())
			While !(cAliasSubst)->(Eof())
				If oMarkSubst:IsMark(cMarcaSubst)
					lAchou := .F.
					(cAliasMark)->(DbGoTop())
					
					// Varre o cursor principal para ver se a nota já está lá
					While !(cAliasMark)->(Eof())
						If AllTrim((cAliasMark)->GIC_CODIGO) == AllTrim((cAliasSubst)->GIC_CODIGO)
							lAchou := .T.
							RecLock(cAliasMark, .F.)
								(cAliasMark)->F2_OK := cMarcaOrig
								(cAliasMark)->GIC_CHVSUB := "" // Limpa a chave p/ evitar novo prompt no while
							(cAliasMark)->(MsUnlock())
							Exit
						EndIf
						(cAliasMark)->(DbSkip())
					EndDo
					
					// Se não achou na memória (ex. datas de emissão diferentes), adiciona dinamicamente no browse
					If !lAchou
						RecLock(cAliasMark, .T.)
							(cAliasMark)->F2_OK      := cMarcaOrig
							(cAliasMark)->F2_DOC     := (cAliasSubst)->F2_DOC
							(cAliasMark)->F2_SERIE   := (cAliasSubst)->F2_SERIE
							(cAliasMark)->F2_CLIENTE := (cAliasSubst)->F2_CLIENTE
							(cAliasMark)->F2_LOJA    := (cAliasSubst)->F2_LOJA
							(cAliasMark)->GIC_CODIGO := (cAliasSubst)->GIC_CODIGO
							(cAliasMark)->GIC_CHVSUB := "" // Limpa a chave p/ evitar novo prompt no while
						(cAliasMark)->(MsUnlock())
					EndIf
				EndIf
				(cAliasSubst)->(DbSkip())
			EndDo
			
			FWAlertSuccess("Notas marcadas para exclusão.", "Sucesso")
			lConfirmado := .T.
			oDlg:End()
		EndIf
	Else
		FWAlertWarning("Nenhuma nota selecionada.", "Aviso")
	EndIf
	
	RestArea(aAreaMark)
	RestArea(aAreaSubst)
Return lConfirmado
/*/{Protheus.doc} SetAllSub
    
	Marca/Desmarca todos os registros do browse secundário de substitutas

	@author Cleiton Genuino da Silva
	@type function
	@since 13/08/2026
	@version 1.0
	@param oMark, object, Marca
	@param lMarca, logical, Marca/Desmarca

/*/
Static Function SetAllSub(oMark, lMarca)
	Local cMarca     := oMark:Mark()
	Local cAliasSubst := oMark:Alias()
	Local aAreaSubst  := (cAliasSubst)->(GetArea())
	
	dbSelectArea(cAliasSubst)
	(cAliasSubst)->( dbGoTop() )
	
	While !(cAliasSubst)->( Eof() )
		RecLock( cAliasSubst, .F. )
			(cAliasSubst)->OK := Iif(lMarca, cMarca, Space(02))
		(cAliasSubst)->(MsUnLock())
		
		(cAliasSubst)->(dbSkip())
	EndDo

	RestArea(aAreaSubst)
Return
/*/{Protheus.doc} Sf2Mkar
    
	Marca/Desmarca o campo F2_OK da tabela SF2

	@author Cleiton Genuino da Silva
	@type function
	@since 31/08/2026
	@version 1.0
	@param cMarca, character, Marca/Desmarca

/*/
Static Function Sf2Mkar(cMarca as character)
Default cMarca := Space(TamSx3('F2_OK')[1])

	If RecLock('SF2',.F.)
		SF2->F2_OK := cMarca
		SF2->(MsUnlock())
	EndIf

Return
/*/{Protheus.doc} GtpDelSFTSF3
Deleta o SF3 e SFT no periodo informado nos parametros mv_par01 e mv_par02 para Mapa Resumo.
@type function
@version  1.0
@author Cleiton Genuino da Silva
@since 01/09/2026
@param cSerie, character, Série da nota fiscal
@param cNfDe, character, Número da nota fiscal inicial
@param cNfAte, character, Número da nota fiscal final
@param cCLiDe, character, Código do cliente inicial
@param cCLiAte, character, Código do cliente final
@param cLojaDe, character, Código da loja inicial
@param cLojaAte, character, Código da loja final
/*/
Function GtpDelSFTSF3(cSerie, cNfDe, cNfAte, cCLiDe, cCLiAte, cLojaDe, cLojaAte)
	Local aArea      := {}  as array
	Local cSql       := ''  as character
	Local cSqlAlias  := ''  as character
	Local lModoFpF3  := .F. as logical
	Local lModoFpFT  := .F. as logical
	Local nLastSF3   := 0   as numeric
	Local nRecSF3    := 0   as numeric
	Local nRecSFT    := 0   as numeric
	Local oSmt       := nil as object
	Default cCLiAte  := Space(10)
	Default cCLiDe   := Space(10)
	Default cLojaAte := Space(03)
	Default cLojaDe  := Space(03)
	Default cNfAte   := Space(10)
	Default cNfDe    := Space(10)
	Default cSerie   := Space(03)

	aArea     := FwGetArea() // Guarda a area corrente
	lModoFpF3 := SF3->(FieldPos("F3_MSFIL")) > 0
	lModoFpFT := SFT->(FieldPos("FT_MSFIL")) > 0

	cSql :=" SELECT "  
    cSql += "   SF3.R_E_C_N_O_ AS REC_SF3, 	"
    cSql += "   SFT.R_E_C_N_O_ AS REC_SFT 	"
    cSql += "FROM " + RetSqlName("SF3") + " SF3 "
    cSql += "INNER JOIN " + RetSqlName("SFT") + " SFT "
    cSql += "   ON SFT.D_E_L_E_T_ = ' ' "

    If( lModoFpF3 .and. lModoFpFT, cSql += " AND SF3.F3_MSFIL = SFT.FT_MSFIL ", cSql += " AND SF3.F3_FILIAL = SFT.FT_FILIAL " )
    
    cSql += " AND SFT.FT_TIPOMOV 	= 'S' "
    cSql += " AND SFT.FT_CLIEFOR 	= SF3.F3_CLIEFOR "
    cSql += " AND SFT.FT_LOJA 		= SF3.F3_LOJA "
    cSql += " AND SFT.FT_SERIE 		= SF3.F3_SERIE "
    cSql += " AND SFT.FT_NFISCAL 	= SF3.F3_NFISCAL "
    
    // Relacionamento crucial para integridade
    cSql += " AND SFT.FT_IDENTF3 = SF3.F3_IDENTFT " 
    
    cSql += "WHERE SF3.D_E_L_E_T_ = ' ' "
    
    If ( lModoFpF3 , cSql += " AND SF3.F3_MSFIL = ? " , cSql += " AND SF3.F3_FILIAL = ? " )
    
    cSql += " AND SF3.F3_SERIE = 	?	"
    cSql += " AND SF3.F3_OBSERV = 	? 	"
	cSql += " AND SF3.F3_CLIEFOR BETWEEN 	? AND ? "
	cSql += " AND SF3.F3_LOJA 	 BETWEEN 	? AND ? "
	cSql += " AND SF3.F3_NFISCAL BETWEEN 	? AND ? "    
    
    oSmt := FWExecStatement():New(cSql)
    
    oSmt:SetString(1, xFilial("SF3"))
    oSmt:SetString(2, cSerie)
    oSmt:SetString(3, "NF CANCELADA")
    oSmt:SetString(4, cCLiDe)
    oSmt:SetString(5, cCLiAte)
    oSmt:SetString(6, cLojaDe)
    oSmt:SetString(7, cLojaAte)
    oSmt:SetString(8, cNfDe)
    oSmt:SetString(9, cNfAte)
    
    cSqlAlias := oSmt:OpenAlias()    
    
    While (cSqlAlias)->(!Eof())
        
        nRecSF3 := (cSqlAlias)->REC_SF3
        nRecSFT := (cSqlAlias)->REC_SFT
        
        // Controle para deletar SF3 apenas uma vez (1:N)
        If nRecSF3 != nLastSF3
            SF3->(DbGoTo(nRecSF3))
            If SF3->(!Eof())
                RecLock("SF3", .F.)
                SF3->(DbDelete())
                SF3->(MsUnlock())
            EndIf
            nLastSF3 := nRecSF3
        EndIf
        
        // Deleta SFT
        SFT->(DbGoTo(nRecSFT))
        If SFT->(!Eof())
            RecLock("SFT", .F.)
            SFT->(DbDelete())
            SFT->(MsUnlock())
        EndIf
        
        (cSqlAlias)->(DbSkip())
    End
    
    (cSqlAlias)->(DbCloseArea())
    oSmt:Destroy()
    oSmt := Nil

	FwRestArea(aArea)

Return NIL
