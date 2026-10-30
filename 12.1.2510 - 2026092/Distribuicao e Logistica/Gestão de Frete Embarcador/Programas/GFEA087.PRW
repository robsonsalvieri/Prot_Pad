#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GFEA087
Manut Calc Periodo - Programa utilizado para manutenção do fechamento de negociações por franquias e cotas
	
@author Alan Victor Lamb
@since 18/10/2013
@version 1.0		
/*/
Function GFEA087()
	Local aSize := MsAdvSize()
	Private oDialog, oBrwCalc, oBrwRom, aRomsExcluir

	oDialog := MSDialog():New(aSize[1], aSize[2], aSize[6], aSize[5], "Manutenção de Cálculos de Frete com Frota Dedicada",,,,, CLR_BLACK, CLR_WHITE,,, .T.)
	oDialog:Activate(,,,.T.,,,{|| Iniciar() })
Return Nil

Static Function Iniciar()
	Local oColumn, oFWLayer, cTmp, bChange, nCount, aCols 
	
	CursorWait()
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDialog,.F.)
	oFWLayer:AddLine('LINET',50,.F.)
	oFWLayer:AddCollumn('COLT',100,.T.,'LINET')
	oFWLayer:AddLine('LINEB',50,.F.)
	oFWLayer:AddCollumn('COLB',100,.T.,'LINEB')
	
	//
	// Cálculos
	//	
	oBrwCalc := CriaBrowse('GWF', oFWLayer:GetColPanel('COLT','LINET'), 'Cálculos de fechamento', '1')
	oBrwCalc:SetFilterDefault("GWF_ORIGEM == '3'")
	oBrwCalc:AddButton("Visualizar", {|| GFEA087002() },,2,,.F.)
	oBrwCalc:AddButton("Excluir", {|| GFEA087003() },,2,,.F.)
	oBrwCalc:Activate()	

	//
	// Romaneios
	//
	oBrwRom := CriaBrowse('GWN', oFWLayer:GetColPanel('COLB','LINEB'), 'Romaneios', '2')
	oBrwRom:SetFilterDefault(FiltroRomaneios())
	oBrwRom:AddButton("Visualizar", {|| GFEA087005_VisualizarRomaneio() },,2,,.F.)
	oBrwRom:ForceQuitButton(.T.)
	oBrwRom:Activate()
	
	If Type("oBrwCalc:bChange") == "B"
		cTmp := GetCbSource(oBrwCalc:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", GFEA087004_ChangeCalculo() }"
		bChange := &(cTmp)
	Else
		bChange := {|| GFEA087004_ChangeCalculo() }
	EndIf

	oBrwCalc:SetChange(bChange)
	
	aCols := { 'GWF_FILIAL', 'GWF_NRCALC', 'GWF_DTCRIA', 'GWF_TRANSP', 'GWF_NMTRP' }
		
	For nCount := 1 To Len(oBrwCalc:aColumns)
		oBrwCalc:aColumns[nCount]:SetDelete(.T.)
	Next nCount
		
	For nCount := 1 To Len(aCols)
		oColumn := FWBrwColumn():New()
		If aCols[nCount] == 'GWF_NMTRP'
			oColumn:SetData( &("{|| Posicione('GU3',1,xFilial('GU3')+GWF_TRANSP,'GU3_NMEMIT') }") )
		Else
			oColumn:SetData( &("{|| "+aCols[nCount]+"}") )
		EndIf
		oColumn:SetTitle( X3COLTI(aCols[nCount]) )
		oColumn:SetOrder(nCount)
		oBrwCalc:SetColumns({oColumn})
	Next nCount
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData( &("{|| GFEC001VLF()}") )
	oColumn:SetTitle("Valor Calc.")
	oColumn:SetType("N")
	oColumn:SetSize(15)
	oColumn:SetDecimal(2)
	oColumn:SetAlign(2)
	oColumn:SetOrder(nCount+1)
	oColumn:SetPicture("@E 999,999,999.99")
	oBrwCalc:SetColumns({oColumn})
	
	oBrwCalc:UpdateBrowse()
	
	aCols := {'GWN_NRROM', 'GWN_CDTPOP', 'GWN_CDCLFR', 'GWN_CDTPVC', 'GWN_PLACAD', 'GWN_DTIMPL', 'GWN_DTSAI', 'GWN_DTRET'}
		
	For nCount := 1 To Len(oBrwRom:aColumns)
		oBrwRom:aColumns[nCount]:SetDelete(.T.)
	Next nCount
		
	For nCount := 1 To Len(aCols)
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &("{|| "+aCols[nCount]+"}") )
		oColumn:SetTitle( X3COLTI(aCols[nCount]) )
		oColumn:SetOrder(nCount)
		oBrwRom:SetColumns({oColumn})
	Next nCount

	oBrwRom:UpdateBrowse()
	oBrwCalc:UpdateBrowse()
	
	CursorWait()
	
	//oRel := FWBrwRelation():New()
	//oRel:AddRelation(oBrwCalc,oBrwRom,{{'GWN_FILIAL','GWF_FILIAL'},{'GWN_NRROM',GFEA087006(),'$'}})
	//oRel:Activate()
	
Return Nil

Static Function CriaBrowse(cAli, oOwner, cDescription, profId)
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetOwner(oOwner)
	oBrowse:SetAlias(cAli)
	oBrowse:SetDescription(cDescription) 
	oBrowse:DisableDetails()
	oBrowse:SetLocate()
	oBrowse:SetProfileID(profId)
	oBrowse:SetAmbiente(.T.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetFixedBrowse(.T.)
	
Return oBrowse

//
// Filtro utilizado no browse de romaneios
//
Static Function FiltroRomaneios()
	Local cFiltro := ''
	
	cFiltro := "GWN_FILIAL == '" + GWF->GWF_FILIAL + "' .AND. GWN_NRROM $ '" + GFEA087006_RomaneiosCalculo() + "'"
	
Return cFiltro

Function GFEA087002_Consultar()
	Local aAreaGWN := GWN->(GetArea())
	Local aAreaGWF := GWF->(GetArea())
	
	If ChkDdsGWF()
		FWExecView('Visualizar','GFEC080',MODEL_OPERATION_VIEW,,{||.T.})
	Else
		MsgAlert("Não há dados a serem exibidos.")
	EndIf
		
	RestArea(aAreaGWN)
	RestArea(aAreaGWF)
	
	oBrwCalc:Refresh()	
Return

Function GFEA087003_Excluir()
	Local aAreaGWN
	Local nCount
	Local lExcluir := .T.
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	
	If !ChkDdsGWF()
		MsgAlert("Não existem dados para excluir.")
		lExcluir := .F.
	EndIf

	If lExcluir .And. !Empty(GWF->GWF_NRCONT)
	
		lExcluir := .F.
		MsgStop("Não é possível eliminar este cálculo, pois já existe um Contrato relacionado.")
	
	EndIf
	
	If lExcluir .And. !Empty(GWF->GWF_NRPREF)
		
		lExcluir := .F.
		MsgStop("Não é possível eliminar este cálculo, pois já existe uma Pré-Fatura relacionada.")
		
	EndIf
	
	If lExcluir
	
		If lExistCamp //Utiliza novo indice para pesquisar se o cálculo está relacionado a algum documento de frete
			dbSelectArea("GW3")
			GW3->(dbSetOrder(1))//GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
			
			If GW3->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_CDESP+GWF->GWF_EMISDF+GWF->GWF_SERDF+GWF->GWF_NRDF+DtoS(GWF->GWF_DTEMDF)))
				lExcluir := .F.
				MsgStop("Não é possível eliminar este cálculo, pois já existe um Documento de Frete relacionado.")		
			EndIf
		Else
	  		dbSelectArea("GWH")
	  		GWH->( dbSetOrder(1) )
	  		If GWH->( dbSeek( GWF->GWF_FILIAL+GWF->GWF_NRCALC ) )
	  			
	  			While !GWH->(Eof()) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
	  				
	  				dbSelectArea("GW1")
	  				GW1->( dbSetOrder(1) )
	  				If GW1->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
	  					
	  					dbSelectArea("GW4")
	  					GW4->( dbSetOrder(2) )
	  					If GW4->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC))
	  						
	  						If Posicione("GW3",1,GW4->GW4_FILIAL+GW4->GW4_CDESP+GW4->GW4_EMISDF+GW4->GW4_SERDF+GW4->GW4_NRDF,"GW3_TPDF") == GWF->GWF_TPCALC
	  							
	  							lExcluir := .F.
	  							MsgStop("Não é possível eliminar este cálculo, pois já existe um Documento de Frete relacionado.")
	  							Exit
	  							
	  						EndIf		
	  					EndIf	
	  				EndIf				
	  				
	  				GWH->( dbSkip() )
	  			EndDo		
	  		EndIf
		EndIf	
	EndIf
	
	If lExcluir .And.;
	   MsgYesNo("O cálculo será excluido e todos os romaneios relacionados terão sua situação de fechamento alteradas para 'Pendente'." +;
				   CRLF + ;
				   "Confirma esta ação?","Aviso")
		
		//
		// Altera a situação de fechamento dos romaneios
		//
		
		CursorWait()
		
		aAreaGWN := GWN->( GetArea() ) 
		GWN->(dbSetOrder(1))
		
		For nCount := 1 To Len(aRomsExcluir)
			
			If GWN->( dbSeek(GWF->GWF_FILIAL+aRomsExcluir[nCount]) )
				
				RecLock("GWN",.F.)
					GWN->GWN_FECHAM := '2'
				MsUnlock()
				
			EndIf
			
		Next nCount
		RestArea( aAreaGWN )
		
		GFEDelCalc( GWF->GWF_NRCALC, GWF->GWF_FILIAL )
		
		CursorArrow()
		
		oBrwCalc:Refresh()
		GFEA087004_ChangeCalculo()
		
	EndIf
	
Return

Function GFEA087004_ChangeCalculo()
	oBrwRom:SetFilterDefault( FiltroRomaneios() )
	oBrwRom:Refresh()
Return

Function GFEA087005_VisualizarRomaneio()
	Local aAreaGWN := GWN->(GetArea())
	Local aAreaGWF := GWF->(GetArea())
	
	If ChkDdsGWF()
		FWExecView('Visualizar','GFEC050',MODEL_OPERATION_VIEW,,{||.T.})
	Else
		MsgAlert("Não há dados a serem exibidos.")
	EndIf
		
	RestArea(aAreaGWN)
	RestArea(aAreaGWF)
	
	oBrwCalc:Refresh()
Return

//
// Retorna uma string contendo os romaneios de um cálculo separados por ;
//
Function GFEA087006_RomaneiosCalculo()
	Local cRet := ''
	Local cRom
	aRomsExcluir := {}
	
	dbSelectArea("GWH")
	GWH->(dbSetOrder(1))
	
	If GWH->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
		
		While !GWH->(Eof()) .And. ;
				GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. ;
				GWH->GWH_NRCALC == GWF->GWF_NRCALC 	
			
			cRom := Posicione("GW1",1,GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC,"GW1_NRROM")		
			
			If !Empty(cRom) .And. At(cRet, cRom) == 0
				If !Empty(cRet)
					cRet += ';'
				EndIf
				
				cRet += cRom
				aAdd(aRomsExcluir, cRom)
				
			EndIf
			
			GWH->(dbSkip())
		EndDo
	EndIf
	
Return cRet

Static Function X3COLTI(cCampo)
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	If SX3->( dbSeek(cCampo) )
		Return X3TITULO()		
	EndIf
Return ''

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkDdsGWF()
Verifica se existem cálculos de fechamento a serem exibidos

@author  Guilherme A. Metzger
@since   10/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ChkDdsGWF()
	Local lRet      := .T.
	Local aAreaAnt  := GetArea()
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()

	cQuery := "SELECT 1 "
	cQuery +=  " FROM " + RetSqlName('GWF') 
	cQuery += " WHERE GWF_FILIAL = '"+xFilial('GWF')+"'" 
	cQuery +=   " AND GWF_ORIGEM = '3'" 
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(Eof())
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return lRet
