#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Descricao: Opcaes do Menu

@author Hermiro Jenior
@since 27/08/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}
	Private lAutom	:= .F.

	aAdd( aRotina, { "Gerar  XTE"				, 'GerArqLote(.F.)'						, 0 , 7 , 0 , Nil } ) // Geracao de Arquivo de Lotes
	aAdd( aRotina, { "Baixar XTE"				, 'CenDBKWXTE(.F.)'						, 0 , 2 , 0 , Nil } ) // Visualiza Criticas
	aAdd( aRotina, { "Visualizar Lote"			, 'VIEWDEF.CENMVCBKW'					, 0 , 2 , 0 , Nil } ) // Visualizacao   dos Lotes
	aAdd( aRotina, { "Visualizar Guias"	        , 'VisContLote(BKW->BKW_FORREM,.F.)'	, 0 , 2 , 0 , Nil } ) // Visualiza Conteudo dos Lotes
	aAdd( aRotina, { "Excluir"			    	, 'VIEWDEF.CENMVCBKW'					, 0 , 5 , 0 , Nil } ) // Exluseo de Lotes.
	aAdd( aRotina, { "Importar XTR"				, 'EnvArqSer("*.xtr|*.xtr","Importar arquivos de Retorno .XTR","1",.F.)', 0 , 3 , 0 , Nil } ) // importacao do arquivo .xtr
	aAdd( aRotina, { "Criticas XTR"				, 'VisCriLote(.F.)'						, 0 , 2 , 0 , Nil } ) // Visualiza Criticas
	aAdd( aRotina, { "Criticas Agrupadas"		, 'CenCritAgr(.F.,"BKW")'				, 0 , 2 , 0 , Nil } ) // Visualiza Criticas
	aAdd( aRotina, { "Gerar Lote"				, 'GerArqLt(.F.)'						, 0 , 3 , 0 , Nil } ) // Geracao de lotes de guias

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBKW
Descricao: Rotina de Lotes de Guias do Projeto de Monitoramento TISS

@author Hermiro Jenior
@since 26/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CENMVCBKW(cFiltro,lAutom)

	Local aCoors		:= FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Lotes de Guias"
	Local oPnl
	Local oBrowse
	Local cAlias	:= "BKW"

	Private oDlgBKW
	Default lAutom	:= .F.
	Default cFiltro	:= 	" BKW_FILIAL = xFilial( 'BKW' ) .AND. " +;
		" BKW_CODOPE = B3D->B3D_CODOPE .AND. " +;
		" BKW_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
		" BKW_ANO = B3D->B3D_ANO .AND. " +;
		" BKW_CDCOMP = B3D->B3D_CODIGO "

	(cAlias)->(dbSetOrder(1))

	//Desvio para contemplar a cobertura de testes
	If !lAutom
		Define MsDialog oDlgBKW Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBKW, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef( 'CENMVCBKW' )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetProfileID( 'CENMVCBKW' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	oBrowse:AddLegend( "BKW_STATUS=='1'", "YELLOW", "Pendente Geração Arquivo" )
	oBrowse:AddLegend( "BKW_STATUS=='2'", "BLUE", "Arquivo Gerado" )
	oBrowse:AddLegend( "BKW_STATUS=='3'", "RED", "Arquivo Gerado com Erros" )
	oBrowse:AddLegend( "BKW_STATUS=='4'", "ORANGE", "Enviado para ANS" )
	oBrowse:AddLegend( "BKW_STATUS=='5'", "BLACK", "Criticado pela ANS" )
	oBrowse:AddLegend( "BKW_STATUS=='6'", "GREEN", "Finalizado" )

	//Desvio para contemplar a cobertura de testes
	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgBKW Center
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author Hermiro Jenior
@since 27/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStrBKW	:= FwFormStruct(1,'BKW')
	Local oModel	:= Nil
	Local oEvent  	:= CENEVTMON():New()

	oModel := MPFormModel():New('CENMVCBKW')
	oModel:AddFields( 'BKWMASTER', NIL, oStrBKW )
	oModel:SetDescription( "Dados do Lote" )
	oModel:GetModel( 'BKWMASTER' ):SetDescription( "Lote" )

	oModel:InstallEvent("EVTMONIT", /*cOwner*/, oEvent)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBKW
Descricao: Cria as visees de MVC.

@author Hermiro Jenior
@since 29/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCBKW' )
	Local oStruBKW 	:= FWFormStruct( 2, 'BKW' )
	Local oView    	:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_BKW'	,oStruBKW,'BKWMASTER')
	oView:CreateHorizontalBox('CABEC',100)
	oView:SetOwnerView('VIEW_BKW','CABEC')
	oView:EnableTitleView('VIEW_BKW','Dados do Lote')
	oView:SetCloseOnOk({|| .T.})

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} VisContLote()
Descricao: Visualiza o Conteedo do Lote

@author Hermiro Jenior
@since 29/08/2019
@version 1.0

@Param: cTipo -> Tipo do Lote (Campo: BKW->BKW_FORREM)
/*/
//-------------------------------------------------------------------
Function VisContLote(cTipo,lAutom)

	Local cFiltro	:= ''
	Local nX		:= 0
	Local aTipo		:= {'1','2','3','4'}

	Default cTipo 	:= ''
	Default lAutom	:= ''

	For nX:= 1 to Len(aTipo)
		If lAutom
			cTipo := aTipo[nX]
		EndIf

		If  cTipo == '1' // Tipo -> Guias Monitoramento
			cFiltro		:= "BKR_FILIAL=='"+xFilial("BKW")+"'  .And. BKR_CODOPE=='"+BKW->BKW_CODOPE+"' .And. "
			cFiltro		+= "BKR_CDOBRI=='"+BKW->BKW_CDOBRI+"' .And. BKR_ANO== '"+BKW->BKW_ANO+"' .And. "
			cFiltro		+= "BKR_CDCOMP=='"+BKW->BKW_CDCOMP+"' .And. BKR_LOTE== '"+BKW->BKW_CODLOT+"' "
			CENMVCBKR(cFiltro,lAutom)
			If !lAutom
				Exit
			EndIf
		ElseIf cTipo =='2' // Tipo - Fornecimento Direto
			cFiltro		:= "BVQ_FILIAL=='"+xFilial("BKW")+"'  .And. BVQ_CODOPE=='"+BKW->BKW_CODOPE+"' .And. "
			cFiltro		+= "BVQ_CDOBRI=='"+BKW->BKW_CDOBRI+"' .And. BVQ_ANO== '"+BKW->BKW_ANO+"' .And. "
			cFiltro		+= "BVQ_CDCOMP=='"+BKW->BKW_CDCOMP+"' .And. BVQ_LOTE== '"+BKW->BKW_CODLOT+"' "
			CENMVCBVQ(cFiltro,lAutom)
			If !lAutom
				Exit
			EndIf
		ElseIf cTipo =='3' // Tipo - Outra Remuneracao
			cFiltro		:= "BVZ_FILIAL=='"+xFilial("BKW")+"'  .And. BVZ_CODOPE=='"+BKW->BKW_CODOPE+"' .And. "
			cFiltro		+= "BVZ_CDOBRI=='"+BKW->BKW_CDOBRI+"' .And. BVZ_ANO== '"+BKW->BKW_ANO+"' .And. "
			cFiltro		+= "BVZ_CDCOMP=='"+BKW->BKW_CDCOMP+"' .And. BVZ_LOTE== '"+BKW->BKW_CODLOT+"' "
			CENMVCBVZ(cFiltro,lAutom)
			If !lAutom
				Exit
			EndIf
		ElseIf cTipo =='4' // Tipo - Valor Pre-Estabelecido
			cFiltro		:= "B9T_FILIAL=='"+xFilial("B9T")+"'  .And. B9T_CODOPE=='"+BKW->BKW_CODOPE+"' .And. "
			cFiltro		+= "B9T_CDOBRI=='"+BKW->BKW_CDOBRI+"' .And. B9T_ANO== '"+BKW->BKW_ANO+"' .And. "
			cFiltro		+= "B9T_CDCOMP=='"+BKW->BKW_CDCOMP+"' .And. B9T_LOTE== '"+BKW->BKW_CODLOT+"' "
			CENMVCB9T(cFiltro,lAutom)
			If !lAutom
				Exit
			EndIf
		EndIf
	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvArqSer
Descricao: Faz importacao dos arquivos .xtr
cTpArq: 1= arquivo .XTR    2= arquivo .XTQ
@author Jose Paulo de Azevedo
@since 22/01/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function EnvArqSer(cMascara,cTitulo,cTpArq,lAuto)
	Local cFile		    := ""
	Local cPath			:= ""
	Local lCopok        := .F.
	Local cErro         := ""
	Local aArqUp        := {}
	Local nI            := 0
	Local lRet          := .T.
	Local oFileRead		:= Nil
	Default cTpArq      := "1"
	Default lAuto       := .F.
	Default cMascara	:= "*.xtr|*.xtr"
	Default cTitulo	    := "Importar arquivos de Retorno"

	// Utilizando o lAuto para passar na automação, utilizar o else caso precise de aumento de cobertura no fonte.
	if !lAuto
		cFile := cGetFile(cMascara,cTitulo,0,"",.T.,GETF_MULTISELECT + GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD,.F.)
	Else
		oFileRead := FWFILEREADER():New("")
		if oFileRead:Open()
			while (oFileRead:hasLine())
				cFile += oFileRead:GetLine()
			EndDo
			oFileRead:Close()
		EndIf
	EndIf

	iF !empty(cFile)
		if( at( ":\",cFile ) <> 0 )	//COPIA ARQUIVO PARA SERVIDOR

			If !ExistDir( "\monitoramento")
				If MakeDir( "\monitoramento") != 0
					cErro := "Nao foi possivel criar o direterio:monitoramento"
				EndIf
			EndIf

			if cTpArq == "1"
				If !ExistDir( "\monitoramento\xtr",,.F.)
					If MakeDir( "\monitoramento\xtr",,.F.) != 0
						cErro := "Nao foi possivel criar o diretorio:xtr"
					EndIf
				EndIf
				If !ExistDir( "\monitoramento\xtr\" + SubStr(cFile,24,4) + "")
					If MakeDir("\monitoramento\xtr\" + SubStr(cFile,24,4) + "") != 0
						cErro := "Nao foi possivel criar o diretorio:ano"
					EndIf
				EndIf
				If !ExistDir( "\monitoramento\xtr\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "" )
					If MakeDir("\monitoramento\xtr\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "") != 0
						cErro := "Nao foi possivel criar o diretorio:mes "
					EndIf
				EndIf
			Else
				If !ExistDir( "\monitoramento\xtq",,.F.)
					If MakeDir( "\monitoramento\xtq",,.F.) != 0
						cErro := "Nao foi possivel criar o diretorio:xtr"
					EndIf
				EndIf
				If !ExistDir( "\monitoramento\xtq\" + SubStr(cFile,24,4) + "")
					If MakeDir("\monitoramento\xtq\" + SubStr(cFile,24,4) + "") != 0
						cErro := "Nao foi possivel criar o diretorio:ano"
					EndIf
				EndIf
				If !ExistDir( "\monitoramento\xtq\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "" )
					If MakeDir("\monitoramento\xtq\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "") != 0
						cErro := "Nao foi possivel criar o diretorio:mes "
					EndIf
				EndIf
			EndIf

			iF empty(cErro)

				IIf (cTpArq == "1",cPath := "\monitoramento\xtr\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "",cPath := "\monitoramento\xtq\" + SubStr(cFile,24,4) + "\"+ SubStr(cFile,28,2) + "")

				aArqUp:=strtokarr2(cFile," | ")
				If len(aArqUp)>0
					for nI:=1 to Len(aArqUp)

						lCopok:= CpyT2S( aArqUp[nI],cPath,.F.,.F. )
						if !lCopok
							Exit
						EndIf
					Next
				EndIf

				If !lCopok
					MSGINFO(cErro)
					lRet:=.f.
				endIf
			Else
				Msginfo("Nao foi possivel copiar o arquivo " + cErro + "para o servidor.")
				lRet:=.f.
			EndIf
		EndIf
	Else
		MSGINFO("Nenhum arquivo selecionado.")
		lRet :=.f.
	EndIf

	If lRet .AND. !lAuto
		If MsgYesNo("Deseja executar o processamento do JOB?")
			Msginfo("O JOB sera processado em segundo plano")
			If cTpArq == '1'
				SvcImpXTR()
			Else
				SvcImpXTQ()
			EndIf
		Else
			Msginfo("O Job sera processado posteriormente de acordo com a parametrizacao.")

		EndIf
	EndIf

Return	lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSXTECOMP
Gera um job para geracao de XTE por competencia

@author renan.almeida
@since 04/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSXTECOMP()

	Local oSvcGerXTE := nil

	if MsgYesNo("Deseja gerar os arquivos XTE para o compromisso selecionado?")

		Aviso("Exportacao XTE","Os arquivos XTE deste compromisso serao gerados em segundo plano.",{ "Ok" }, 2 )
		oSvcGerXTE := SvcGerXTE():New()
		MV_PAR01   := B3D->B3D_CODOPE
		oSvcGerXTE:run(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO)
		FreeObj(oSvcGerXTE)
		oSvcGerXTE := nil
		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Gera Arquivo para Envio - Monitoramento", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CenDBKWXTE
Download do arquivo XTE do lote

@author everton.mateus
@since 31/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function CenDBKWXTE(lAuto)
	Local cPathSrv := PLSMUDSIS("\monitoramento\xte\" + AllTrim(BKW->BKW_ANO) + "\" + AllTrim(SubStr(BKW->BKW_CDCOMP,2,2)) + "\" + AllTrim(BKW->BKW_ARQUIV)) + ".xte"
	Local cDirLocal := ""
	If File(cPathSrv)
		cDirLocal := cGetFile(,"Selecione o diretorio",,"",,GETF_LOCALHARD+GETF_RETDIRECTORY)
		If !Empty(cDirLocal)
			If CpyS2T( cPathSrv, cDirLocal )
				Aviso("Lotes","Download concluido na pasta: " + cDirLocal + ".")
			Else
				Aviso("Lotes","Não foi possível realizar o download do arquivo XTE. Verifique as permissoes das pastas.")
			EndIf
		EndIf
	Else
		Aviso("Lotes","Não foi encontrado um arquivo XTE para este lote.")
		GerArqLote(.F.)

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArqLote
Descricao: Geracao do Arquivo de Lotes

@author Hermiro Jenior
@since 04/09/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function GerArqLote(lAutom)

	Local oSvcGerXTE := nil

	Default lAutom	:= .F.

	if lAutom .OR. MsgYesNo("Deseja gerar o arquivo XTE para o lote selecionado?")

		Aviso("Exportacao XTE","O arquivo XTE deste lote sera gerado em segundo plano.",{ "Ok" }, 2 )
		oSvcGerXTE := SvcGerXTE():New()
		MV_PAR01   := B3D->B3D_CODOPE
		oSvcGerXTE:run(BKW->BKW_CODOPE,BKW->BKW_CDOBRI,BKW->BKW_ANO,BKW->BKW_CDCOMP,BKW->BKW_CODLOT)
		FreeObj(oSvcGerXTE)
		oSvcGerXTE := nil

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSXTESEMM
Gera XTE de uma competencia sem movimentacao

@author renan.almeida
@since 04/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSXTESEMM()

	Local oCltBKW := CenCltBKW():New()

	oCltBKW:setValue("operatorRecord" ,B3D->B3D_CODOPE)
	oCltBKW:SetValue("requirementCode",B3D->B3D_CDOBRI)
	oCltBKW:SetValue("referenceYear"  ,B3D->B3D_ANO)
	oCltBKW:SetValue("commitmentCode" ,B3D->B3D_CODIGO)

	if oCltBKW:buscar()
		Aviso("Exportacao XTE","Nao e possivel gerar o arquivo sem movimentacao pois ha lotes gerados para esta competencia.",{ "Ok" }, 2 )
	else
		oCltBKW:setValue("batchCode","000000000001")
		oXTE := CenExpoMon():New()
		oXTE:cCodOpe := B3D->B3D_CODOPE
		oXTE:procSemMov(oCltBKW)
		if !Empty(oXTE:cError) .Or. !Empty(oXTE:cWarning)
			Aviso("Exportacao XTE","Foram apresentados erros na geracao do arquivo XTE: "+oXTE:cError+" "+oXTE:cWarning,{ "Ok" }, 2 )
		else
			Aviso("Exportacao XTE","Arquivo "+oXTE:cFileName+".xte gerado com sucesso.",{ "Ok" }, 2 )
		EndIf
	EndIf
	oCltBKW:destroy()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}
Descricao:  Visualizacao das Criticas das Guias de Fornecimento Direto.

@author Hermiro Jenior
@since 02/09/2019
@version 1.0

@Param: Numero da Guia = BVQ_NMGPRE

/*/
//-------------------------------------------------------------------
Function VisCriLote(lAuto, cCodCri)

	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
		" B3F_TIPO = '3' .AND. " +;
		" B3F_CODOPE = '" + BKW->BKW_CODOPE + "' .AND." +;
		" B3F_DESORI = '" + BKW->BKW_CODLOT + "' "

	Default lAuto := .F.
	Default cCodCri := ""

	If !Empty(cCodCri)
		cFiltro += "B3F_CODCRI = '" + cCodCri + "' "
	EndIf

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto, .T.)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArqLote
Descricao: Geracao do Lote de guias

@author José Paulo
@since 29/07/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function GerArqLt(lAutom)

	Local oSvcGeraLote := nil

	Default lAutom	:= .F.

	if lAutom .OR. MsgYesNo("Deseja gerar o lote?")

		Aviso("Geração de Lote","O lote será gerado em segundo plano.",{ "Ok" }, 2 )
		oSvcGeraLote := SvcGeraLote():New()
		MV_PAR01   := B3D->B3D_CODOPE


		If oSvcGeraLote:CheckSemaforo()
			oSvcGeraLote:run()
		else
			Aviso("Job já está sendo executado!")
		endIf

		FreeObj(oSvcGeraLote)
		oSvcGeraLote := nil
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonStat
Descricao: Status dos campos de cabeçalho

@author José Paulo
@since 03/08/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CenMonStat()
	Local cStatus:= "1=Pendente Validação;2=Pronto para o Envio;3=Criticado;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado;7=Pendente Geração do Arquivo;8=Arquivo Gerado"

Return cStatus
