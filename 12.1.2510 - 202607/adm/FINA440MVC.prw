#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE "FINA440.ch"

/*/{Protheus.doc} FINA440MVC
	Valores de comissão a serem gravadas na SE3
	@author Francisco Oliveira
	@since  22/10/2025
	@version 12
/*/
Function FINA440MVC() As Logical

	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local lRet := .T.

	FWExecView( STR0033,"FINA440MVC", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons ) // "Valores de Comissão"
	
Return lRet

/*/{Protheus.doc} ViewDef
	Interface.
	@author Francisco Oliveira
	@since  22/10/2025
	@version 12
/*/
Static Function ViewDef()
	
	Local oView  := FWFormView():New()
	Local oModel := FWLoadModel('FINA440MVC')
	Local oSE1	 := FWFormStruct(2,'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_VALOR' } )
	Local oSE3	 := FWFormStruct(2,'SE3', { |x| ALLTRIM(x) $ 'E3_BASE, E3_PORC, E3_COMIS' })

	oSE1:AddField("E1_NOMVEND", "40", STR0034, STR0034, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //"Nome Vendedor"
	oSE1:AddField("E1_VENDX"  , "06", STR0035, STR0035, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //"Cod. Vend."
	oSE1:AddField("E1_QTDVEN" , "06", STR0036, STR0036, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //"Seq. Vend."

	oSE1:SetProperty("*", MVC_VIEW_CANCHANGE, .F. )
	
	oSE1:SetProperty( 'E1_VENDX'  , MVC_VIEW_ORDEM,	'20')
	oSE1:SetProperty( 'E1_NOMVEND', MVC_VIEW_ORDEM,	'21')
	oSE1:SetProperty( 'E1_QTDVEN' , MVC_VIEW_ORDEM,	'22')

	oSE3:SetProperty( 'E3_BASE'	  , MVC_VIEW_CANCHANGE, .T. )
	oSE3:SetProperty( 'E3_PORC'	  , MVC_VIEW_CANCHANGE, .T. )
	oSE3:SetProperty( 'E3_COMIS'  , MVC_VIEW_CANCHANGE, .T. )

	oView:SetModel( oModel )
	oView:AddField("VIEWSE1",oSE1,"SE1MASTER")
	oView:AddGrid("VIEWSE3" ,oSE3,"SE3DETAIL")
	
	oView:SetViewProperty("VIEWSE1","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})
	
	oView:CreateHorizontalBox( 'BOXSE1', 027 )
	oView:CreateHorizontalBox( 'BOXSE3', 073 )
	
	oView:SetOwnerView('VIEWSE1', 'BOXSE1')
	oView:SetOwnerView('VIEWSE3', 'BOXSE3')
	
	oView:EnableTitleView('VIEWSE1', STR0037 ) // 'Informações do Título'
	oView:EnableTitleView('VIEWSE3', STR0033 ) // 'Valores de Comissão'

	oView:SetNoDeleteLine("SE3DETAIL")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} ModelDef
	Modelo de dados.
	@author Francisco Oliveira
	@since  22/10/2025
	@version 12
/*/
Static Function ModelDef()

	Local oModel	:= MPFormModel():New('FINA440MVC',/*Pre*/,/*Pos*/,{|oModel|COMISAGRV( oModel )}/*Commit*/)
	Local oSE1		:= FWFormStruct(1, 'SE1')
	Local oSE3		:= FWFormStruct(1, 'SE3')

	oSE1:AddField( STR0035, STR0035, "E1_VENDX"  ,"C",06,0,{||.T.},{||.F.}, ,.F.) //"Cod. Vend."
	oSE1:AddField( STR0034, STR0034, "E1_NOMVEND","C",40,0,{||.T.},{||.F.}, ,.F.) //"Nome Vendedor"
	oSE1:AddField( STR0036, STR0036, "E1_QTDVEN" ,"C",06,0,{||.T.},{||.F.}, ,.F.) //"Seq. Vend."

	oSE3:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oSE3:SetProperty( 'E3_BASE' , MODEL_FIELD_VALID, {|| .T. } )
	oSE3:SetProperty( 'E3_PORC' , MODEL_FIELD_VALID, {|| .T. } )
	oSE3:SetProperty( 'E3_COMIS', MODEL_FIELD_VALID, {|| .T. } )

	oModel:AddFields("SE1MASTER",/*cOwner*/	, oSE1)
	oModel:AddGrid("SE3DETAIL"  ,"SE1MASTER", oSE3)

	oModel:GetModel('SE3DETAIL'):SetOptional( .T. )
	
	oModel:SetPrimarykey({})

	oModel:SetActivate( {|oModel| LOADCOMIS(oModel) } )

Return oModel

/*/{Protheus.doc} COMISAGRV
	Atualiza os valores do array aBases
	@author Francisco Oliveira
	@since  22/10/2025
	@version 12
/*/
Static Function COMISAGRV( oModel )

	Local lRet		:= .T.
	Local oSE3COM	:= oModel:GetModel("SE3DETAIL")

	If oSE3COM:GetValue("E3_BASE") == aBaseMVC[1][4] .And. oSE3COM:GetValue("E3_PORC") == aBaseMVC[1][7] .And. oSE3COM:GetValue("E3_COMIS") == aBaseMVC[1][6]
		lGrvAjuste := .F.
	Else
		aBaseMVC[1][4] := oSE3COM:GetValue("E3_BASE")
		aBaseMVC[1][7] := oSE3COM:GetValue("E3_PORC")
		aBaseMVC[1][6] := oSE3COM:GetValue("E3_COMIS")
		lGrvAjuste := .T.
	Endif

Return lRet

/*/{Protheus.doc} LOADCOMIS
	Atualiza tela da GRID com os valores do array aBases
	@author Francisco Oliveira
	@since  22/10/2025
	@version 12
/*/

Static Function LOADCOMIS(oModel)

	Local oModelSE3	:= oModel:GetModel("SE3DETAIL")
	Local oModelSE1	:= oModel:GetModel("SE1MASTER")
	Local oView		:= FWViewActive()

	If Len(aBaseMVC) > 0
		
		oModelSE1:LoadValue("E1_VENDX"  , aBaseMVC[1][1])
		oModelSE1:LoadValue("E1_QTDVEN" , cValToChar(nSeqVend) + " / " + cValToChar(nQtdeMVC))

		oModelSE1:LoadValue("E1_NOMVEND", Posicione("SA3",1, xFilial("SA3") + aBaseMVC[1][1],"A3_NOME"))

		oModelSE3:GoLine(1)
		oModelSE3:LoadValue("E3_BASE"   , aBaseMVC[1][4])
		oModelSE3:LoadValue("E3_PORC"   , aBaseMVC[1][7])
		oModelSE3:LoadValue("E3_COMIS"  , aBaseMVC[1][6])
	Endif
		
	oView:SetNoInsertLine('SE3DETAIL')

Return

