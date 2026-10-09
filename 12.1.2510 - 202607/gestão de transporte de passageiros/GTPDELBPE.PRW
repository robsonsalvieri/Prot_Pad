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
	Local cMarca        := oMark:Mark()
	Local cAliasMark    := oMark:Alias()
	Local lAutomatico   := .T.
    Local nOpc          := 1
    Local lAglCtb       := MV_PAR02 == 1
    Local lContab       := MV_PAR03 == 1
    Local lCarteira     := .F.
	Local cSeekCDA      := ''
	Private lMsErroAuto := .F.

	GIC->(DbSetOrder(1))
	SF2->(DbSetOrder(1))
	CDA->(DbSetOrder(3))	// CDA_FILIAL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA

	(cAliasMark)->( dbGoTop() )
	While !(cAliasMark)->( EOF() )
		If oMark:IsMark(cMarca)	// Registro marcado
			If SF2->(DbSeek(xFilial("SF2")+(cAliasMark)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
				RecLock('SF2',.F.)
					SF2->F2_OK := cMarca
				SF2->(MsUnlock())
				cSeekCDA := xFilial('CDA') + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
			EndIf 

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z,a,b,c,d| MATA521A(x,y,z,a,b,c,d)},lAutomatico,'SF2',cMarca,nOpc,lAglCtb,lContab,lCarteira)

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
			EndIf 
		EndIf
		(cAliasMark)->( dbSkip() )
	End

	RestArea( aArea )
Return 

/*/{Protheus.doc} SetMarkAll
    Seleção de registros
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
