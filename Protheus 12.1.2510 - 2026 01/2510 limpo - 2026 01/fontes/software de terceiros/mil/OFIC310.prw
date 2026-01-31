#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'OFIC310.CH'

/*/{Protheus.doc} OFIC310
	Rotina que exibe todos itens que estão reservados na reserva não rastreavel e mostra
	a quantidade de itens no armazem de reserva (MV_RESITE) para possibilitar o rastrea-
	-mento dos itens com divergência entre os itens reservados e os itens em estoque de 
	reserva
	@type  Function
	@author João Félix
	@since 11/06/2025
/*/
Function OFIC310()

	Local aSize     := FWGetDialogSize( oMainWnd )
	Local oDMSBrwStru
	Local oBrwVE6SB2 

	If GetMV("MV_MIL0181") == .T.
		FMX_HELP("OFC310ERR001",STR0025) // "A rotina de análise de itens reservados somente será executada com o controle de reserva rastreável desativado."
		Return
	Endif

	oDlgOFC310 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4],STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) //Painel Reservas

		oTPanSB2 := TPanel():New(0,0,"",oDlgOFC310,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFC310:nClientHeight/4)-10,.F.,.F.)
		oTPanSB2:Align := CONTROL_ALIGN_TOP

		oTPanVE6 := TPanel():New(0,0,"",oDlgOFC310,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFC310:nClientHeight/4)-10,.F.,.F.)
		oTPanVE6:Align := CONTROL_ALIGN_BOTTOM 

		OFC310001I_ConfigBrowseVE6(@oDMSBrwStru)	
		oBrwVE6SB2 := FWmBrowse():New()	
		oBrwVE6SB2:SetOwner(oTPanSB2)
		oDMSBrwStru:SetBrwOwner(oBrwVE6SB2)	
		oBrwVE6SB2:SetTemporary(.T.)
		oBrwVE6SB2:SetUseFilter( .T. )
		oBrwVE6SB2:SetDescription(STR0002) //Consulta de itens reservados
		oBrwVE6SB2:SetWalkThru(.F.)
		oBrwVE6SB2:SetAmbiente(.F.)	
		oBrwVE6SB2:AddLegend( 'B2_QATU == VE6_QTDITE' , 'BR_VERDE'    , STR0003 ) // "Sem divergência de itens entre o armazem de reserva e os itens reservados"
		oBrwVE6SB2:AddLegend( 'B2_QATU <> VE6_QTDITE' , 'BR_VERMELHO' , STR0004 ) // "Divergência de quantidade de itens entre o armazem de reserva e os itens reservados"
		oBrwVE6SB2:SetSeek(.T.,oDMSBrwStru:GetSeek())	
		oBrwVE6SB2:SetFieldFilter(oDMSBrwStru:_aColFilter)	
		oBrwVE6SB2:SetQueryIndex(oDMSBrwStru:_aIndex)	
		oBrwVE6SB2:DisableDetails()	
		oDMSBrwStru:AddBrwColumn()	
		oBrwVE6SB2:SetAlias(oDMSBrwStru:GetAlias())
		oBrwVE6SB2:AddButton( STR0005 , { || OFC310005I_GeraExcelOFIC310() } ) //"Exportar para excel"
		oBrwVE6SB2:Activate()

		OFC310004I_ConfiguraBrowseVE6(@oDMSBrwStruVE6) 
		oBrwVE6 := FWmBrowse():New()	
		oBrwVE6:SetOwner(oTPanVE6)
		oDMSBrwStruVE6:SetBrwOwner(oBrwVE6)	
		oBrwVE6:SetTemporary(.T.)
		oBrwVE6:SetUseFilter( .T. )
		oBrwVE6:SetDescription(STR0006) //"Detalhamento de itens reservados"
		oBrwVE6:SetWalkThru(.F.)
		oBrwVE6:SetAmbiente(.F.)	
		oBrwVE6:SetSeek(.T.,oDMSBrwStruVE6:GetSeek())	
		oBrwVE6:SetFieldFilter(oDMSBrwStruVE6:_aColFilter)	
		oBrwVE6:SetQueryIndex(oDMSBrwStruVE6:_aIndex)	
		oBrwVE6:DisableDetails()	
		oDMSBrwStruVE6:AddBrwColumn()	
		oBrwVE6:SetAlias(oDMSBrwStruVE6:GetAlias())	
		oBrwVE6:AddButton( STR0005 , { || OFC310006I_GeraExcelDetalhesOFIC310() } ) //"Exportar para excel"
		oBrwVE6:SetDoubleClick( { || OFC310007I_AbreOrcOs((oDMSBrwStruVE6:GetAlias())->VE6_NUMOSV, (oDMSBrwStruVE6:GetAlias())->VE6_NUMORC)})
		oBrwVE6:Activate()	


		oRelacPed:= FWBrwRelation():New()
		oRelacPed:AddRelation( oBrwVE6SB2 , oBrwVE6 , {{ "VE6_FILIAL", "VE6_FILIAL" }, { "VE6_CODITE", "VE6_CODITE" }, {"VE6_GRUITE", "VE6_GRUITE"} })	
		oRelacPed:Activate()

	oDlgOFC310:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OFC310001I_ConfigBrowseVE6
	Função que monta os campos exibidos no browse principal de reservas
	@type  Function
	@author João Félix
	@since 11/06/2025
	@param oDMSBrwStru (Objeto de browse principal de reservas)
/*/
Function OFC310001I_ConfigBrowseVE6(oDMSBrwStru)

	oDMSBrwStru := OFBrowseStruct():New({"VE6", "SB1", "SB2"})
	oDMSBrwStru:AddField( "VE6_FILIAL" )
	oDMSBrwStru:AddField( "VE6_GRUITE" )
	oDMSBrwStru:AddField( "VE6_CODITE" )
	oDMSBrwStru:AddField( "B2_QATU" )
	oDMSBrwStru:AddField( "VE6_QTDITE" , STR0007)//"Quantidade de itens reservados"

	oDMSBrwStru:AddIndex( "VE6_CODITE" )

	oDMSBrwStru:AddSeek( { "VE6_CODITE" } )

	oDMSBrwStru:CriaTabTmp()
	oDMSBrwStru:LoadData( OFC310002I_MontaTabVE6() )

Return

/*/{Protheus.doc} OFC310002I_MontaTabVE6
	Função que monta a query que define as informações exibidas no browse principal de itens reservados
	@type  Function
	@author João Félix
	@since 11/06/2025
/*/
Function OFC310002I_MontaTabVE6()

	Local cQuery := ""
	Local cArmazem := GetMV("MV_RESITE")

		cQuery := "SELECT "
    	cQuery += "VE6.VE6_FILIAL, "
    	cQuery += "VE6.VE6_GRUITE, "
   		cQuery += "VE6.VE6_CODITE, "
    	cQuery += "SB2.B2_QATU, "
    	cQuery += "SUM(VE6.VE6_QTDITE) AS QTDVE6 "
	cQuery += "FROM " + RetSqlName("VE6") + " VE6 "
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1 "
    	cQuery += "ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
    	cQuery += "AND SB1.B1_GRUPO = VE6.VE6_GRUITE "
    	cQuery += "AND SB1.B1_CODITE = VE6.VE6_CODITE "
    	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " SB2 "
    	cQuery += "ON VE6.VE6_FILIAL = SB2.B2_FILIAL "
    	cQuery += "AND SB1.B1_COD = SB2.B2_COD "
    	cQuery += "AND SB2.B2_LOCAL = '"+cArmazem+"' "
    	cQuery += "AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
    	cQuery += "VE6.D_E_L_E_T_ = ' ' "
    	cQuery += "AND (VE6.VE6_QTDITE - VE6.VE6_QTDATE - VE6.VE6_QTDEST) > 0 "
    	cQuery += "AND VE6.VE6_INDREG = '3' "
	cQuery += "GROUP BY "
    	cQuery += "VE6.VE6_FILIAL, "
    	cQuery += "VE6.VE6_GRUITE, "
    	cQuery += "VE6.VE6_CODITE, "
    	cQuery += "SB2.B2_QATU "
	cQuery += "ORDER BY "
    	cQuery += "VE6.VE6_CODITE "


Return cQuery

/*/{Protheus.doc} OFC310004I_ConfiguraBrowseVE6
	Função que monta os campos exibidos no browse de detalhamento
	@type  Function
	@author João Félix
	@since 11/06/2025
	@param oDMSBrwStruVE6 (Objeto de browse de detalhamento)
/*/
Function OFC310004I_ConfiguraBrowseVE6(oDMSBrwStruVE6)

	oDMSBrwStruVE6 := OFBrowseStruct():New({"VE6", "VS1", "VSJ"})
	oDMSBrwStruVE6:AddField( "VE6_QTDITE", STR0007)//"Quantidade de itens reservados"
	oDMSBrwStruVE6:AddField( "VE6_FILIAL" )
	oDMSBrwStruVE6:AddField( "VE6_CODITE" )
	oDMSBrwStruVE6:AddField( "VE6_GRUITE" )
	oDMSBrwStruVE6:AddField( "VE6_NUMORC" )
	oDMSBrwStruVE6:AddField( "VS1_STARES" )
	oDMSBrwStruVE6:AddField( "VE6_NUMOSV" )
	oDMSBrwStruVE6:AddField( "VE6_DATREG" )
	oDMSBrwStruVE6:AddField( "VE6_HORREG" )
	oDMSBrwStruVE6:AddField( "VSJ_TIPTEM" )

	oDMSBrwStruVE6:AddIndex( "VE6_CODITE" )

	oDMSBrwStruVE6:AddSeek( { "VE6_CODITE" } )

	oDMSBrwStruVE6:CriaTabTmp()
	oDMSBrwStruVE6:LoadData( OFC310003I_MontaDetalhesVE6() )

Return

/*/{Protheus.doc} OFC310003I_MontaDetalhesVE6
	Função que monta a query que define as informações exibidas no browse do detalhamento
	@type  Function
	@author João Félix
	@since 11/06/2025
/*/
Function OFC310003I_MontaDetalhesVE6()

	local cQuery := "" 

		cQuery := "SELECT " 
	    cQuery += "VE6.VE6_QTDITE AS QTDVE6, "
		cQuery += "VE6.VE6_FILIAL, "
	    cQuery += "VE6.VE6_CODITE, "
	    cQuery += "VE6.VE6_GRUITE, "
	    cQuery += "VE6.VE6_NUMORC, "
	    cQuery += "V.VS1_STARES, "
	    cQuery += "VE6.VE6_NUMOSV, "
	    cQuery += "VE6.VE6_DATREG, "
	    cQuery += "VE6.VE6_HORREG, "
	    cQuery += "VSJ.VSJ_TIPTEM "
	cQuery += "FROM "+RetSqlName("VE6")+" VE6 WITH (NOLOCK) "
	cQuery += "LEFT JOIN "+RetSqlName("VS1")+" V WITH (NOLOCK) " 
	    cQuery += "ON V.VS1_FILIAL = VE6.VE6_FILIAL "
	    cQuery += "AND V.VS1_NUMORC = VE6.VE6_NUMORC "
	    cQuery += "AND V.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+RetSqlName("VO1")+" VO1 "
	    cQuery += "ON VO1.VO1_FILIAL = VE6.VE6_FILIAL " 
	    cQuery += "AND VO1.VO1_NUMOSV = VE6.VE6_NUMOSV " 
	    cQuery += "AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+RetSqlName("VSJ")+" VSJ "
	    cQuery += "ON VSJ_FILIAL = VE6.VE6_FILIAL "
		cQuery += "AND VSJ_NUMOSV = VE6.VE6_NUMOSV "
		cQuery += "AND VSJ.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE " 
	    cQuery += "VE6.VE6_INDREG = '3' "
	    cQuery += "AND (VE6.VE6_QTDITE - VE6.VE6_QTDATE - VE6.VE6_QTDEST) > 0 "
	    cQuery += "AND VE6.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY " 
		cQuery += "VE6.VE6_QTDITE, "
		cQuery += "VE6.VE6_FILIAL, "
	    cQuery += "VE6.VE6_CODITE, "
	    cQuery += "VE6.VE6_GRUITE, "
	    cQuery += "VE6.VE6_NUMORC, "
	    cQuery += "V.VS1_STARES, "
	    cQuery += "V.VS1_TIPTEM, "
	    cQuery += "VE6.VE6_NUMOSV, "
	    cQuery += "VE6.VE6_DATREG, "
	    cQuery += "VE6.VE6_HORREG, "
	    cQuery += "VSJ.VSJ_TIPTEM "   
	cQuery += "ORDER BY "
	    cQuery += "VE6.VE6_CODITE "

Return cQuery

/*/{Protheus.doc} OFC310005I_GeraExcelOFIC310
	Função que gera o relatorio em excel dos itens do browse de reservas (principal)
	@type  Function
	@author João Félix
	@since 11/06/2025
/*/
Function OFC310005I_GeraExcelOFIC310() 

	Local cNome    := "OFIC310"
	Local oExcel   := FWMSEXCEL():New()
	Local aCol      := {}
	Local cArq  := ''

	cArq := &("cGetFile('*.xls', '*.xls', 1, 'SERVIDOR', .F., " + str(nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)) + ", .T., .T.)")

	If Empty(cArq)
		MsgInfo(STR0009) //"Geração cancelada."
		Return
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,OFC310002I_MontaTabVE6()), "TRB", .T., .F. )
	dbSelectArea("TRB")
	dbGoTop()

	oExcel:AddWorkSheet(cNome)
	oExcel:AddTable(cNome,STR0002) // OFIC310 / "Consulta de itens reservados"

	oExcel:AddColumn( cNome , STR0002 , STR0011 , 1 , 1 ) // OFIC310 / "Consulta de itens reservados" / "Filial"
	oExcel:AddColumn( cNome , STR0002 , STR0012 , 1 , 1 ) // OFIC310 / "Consulta de itens reservados" / "Grupo de item" 
	oExcel:AddColumn( cNome , STR0002 , STR0013 , 1 , 1 ) // OFIC310 / "Consulta de itens reservados" / "Codigo de item"
	oExcel:AddColumn( cNome , STR0002 , STR0014 , 1 , 1 ) // OFIC310 / "Consulta de itens reservados" / "Quantidade atual"  
	oExcel:AddColumn( cNome , STR0002 , STR0015 , 1 , 1 ) // OFIC310 / "Consulta de itens reservados" / "Itens reservados"

	While !Eof()
		aCol := {}

		aAdd(aCol, TRB->VE6_FILIAL)
		aAdd(aCol, TRB->VE6_GRUITE)
		aAdd(aCol, TRB->VE6_CODITE)
		aAdd(aCol, TRB->B2_QATU)
		aAdd(aCol, TRB->QTDVE6)

		oExcel:AddRow(cNome, STR0002, aCol) // "Consulta de itens reservados"

		dbSkip()
	EndDo


	oExcel:Activate()
	oExcel:GetXMLFile(cArq+cNome+'_'+StrTran(DtoC(Date()), "/", "")+".xls")
	oExcel:DeActivate()

	MsgInfo( STR0008 , STR0016 )// "Exportação concluída" / "Atenção"

	dbSelectArea("TRB")
	dbCloseArea()

Return

/*/{Protheus.doc} OFC310006I_GeraExcelDetalhesOFIC310
	Função que gera o relatorio em excel dos itens do browse de detalhamento
	@type  Function
	@author João Félix
	@since 11/06/2025
/*/
Function OFC310006I_GeraExcelDetalhesOFIC310()

	Local cNome    := "DETOFIC310" // 
	Local oExcel   := FWMSEXCEL():New()
	Local aCol      := {}
	Local cArq

	cArq := &("cGetFile('*.xls', '*.xls', 1, 'SERVIDOR', .F., " + str(nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)) + ", .T., .T.)")

	If Empty(cArq)
		MsgInfo("Geração cancelada.")
		Return
	EndIf

	cQuery := OFC310003I_MontaDetalhesVE6()

	dbUseArea( .T., "TOPCONN", TcGenQry(,,OFC310003I_MontaDetalhesVE6()), "TRB", .T., .F. )
	dbSelectArea("TRB")
	dbGoTop()

	oExcel:AddWorkSheet(cNome)
	oExcel:AddTable(cNome,STR0006) // DETOFIC310 / 

	oExcel:AddColumn( cNome , STR0006 , STR0007, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Unidade"
	oExcel:AddColumn( cNome , STR0006 , STR0011, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Filial" 
	oExcel:AddColumn( cNome , STR0006 , STR0013, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Codigo de item"
	oExcel:AddColumn( cNome , STR0006 , STR0012, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Grupo de item"  
	oExcel:AddColumn( cNome , STR0006 , STR0018, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Numero do orçamento"
	oExcel:AddColumn( cNome , STR0006 , STR0019, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Status da reserva"	
	oExcel:AddColumn( cNome , STR0006 , STR0020, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Numero da ordem de serviço"
	oExcel:AddColumn( cNome , STR0006 , STR0021, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Data do registro"
	oExcel:AddColumn( cNome , STR0006 , STR0022, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Hora do registro"
	oExcel:AddColumn( cNome , STR0006 , STR0023, 1 , 1 ) //  "DETOFIC310" / "Detalhamento de itens reservados" / "Tipo de tempo"	


	While !Eof()
		aCol := {}
		aAdd(aCol, TRB->QTDVE6)
		aAdd(aCol, TRB->VE6_FILIAL)
		aAdd(aCol, TRB->VE6_CODITE)
		aAdd(aCol, TRB->VE6_GRUITE)
		aAdd(aCol, TRB->VE6_NUMORC)
		aAdd(aCol, TRB->VS1_STARES)
		aAdd(aCol, TRB->VE6_NUMOSV)
		aAdd(aCol, TRB->VE6_DATREG)
		aAdd(aCol, TRB->VE6_HORREG)
		aAdd(aCol, TRB->VSJ_TIPTEM)

		oExcel:AddRow(cNome, STR0006, aCol) // "Detalhamento de itens reservados"
		dbSelectArea("TRB")
		dbSkip()
	EndDo

	oExcel:Activate()
	oExcel:GetXMLFile(cArq+cNome+'_'+StrTran(DtoC(Date()), "/", "")+".xls")
	oExcel:DeActivate()

	MsgInfo( STR0008 , STR0016 ) // "Exportação concluída" / "Atenção"

	dbSelectArea("TRB")
	dbCloseArea()

Return

/*/{Protheus.doc} OFC310007I_AbreOrcOs
	Função que abre o orçamento ou ordem de serviço no modo de visualização 
	ao dar um duplo clique no registro no browse de detalhamento de reserva
	@type  Function
	@author João Félix
	@since 11/06/2025
	@param cNumOS, cNumOrc (Numero OS e numero do orçamento)
/*/
Function OFC310007I_AbreOrcOs(cNumOS, cNumOrc)

	Private VISUALIZA := .T. // variavel necessaria no OFIOC060 (SX3)
	Private INCLUI    := .F. // variavel necessaria no OFIOC060 (SX3)
	Private ALTERA    := .F. // variavel necessaria no OFIOC060 (SX3)
	Private EXCLUI    := .F. // variavel necessaria no OFIOC060 (SX3)

	If !Empty(cNumOrc) 
		DBSelectArea("VS1")
		DBSetOrder(1)
		If DBSeek(xFilial("VS1")+cNumOrc)
			OXA011("VS1",VS1->(RECNO()),2)
		Else
			MsgStop( STR0017 , STR0016) // "Orçamento não encontrado" / "Atenção"
		EndIF
	Else
		DBSelectArea("VO1")
		DBSetOrder(1)
		If DBSeek(xFilial("VO1")+cNumOS)
			OC060("VO1", VO1->(RECNO()), 2)
		Else
			MsgStop ( STR0024 , STR0016) //"Ordem de serviço não encontrada" / "Atenção"
		EndIF
	EndIF

Return
