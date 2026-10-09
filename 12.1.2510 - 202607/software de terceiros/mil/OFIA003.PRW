#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE STR0001 "Abertura de OS - Manual"
#DEFINE STR0002 "Abertura de OS - Manual - ABRIR O. S."
#DEFINE STR0003 "Visualizar"
#DEFINE STR0004 "Incluir"
#DEFINE STR0005 "Alterar"
#DEFINE STR0006 "Excluir"
#DEFINE STR0007 "Replicar"
#DEFINE STR0008 "Aberta"
#DEFINE STR0009 "Liberada"
#DEFINE STR0010 "Fechada"
#DEFINE STR0011 "Cancelada"
#DEFINE STR0012 "O Proprietário deste novo Chassi está diferente do Proprietário do Chassi informado inicialmente nesta OS? Continuar?"
#DEFINE STR0013 "Atenção"

Static cAberta := "A"
Static cLiberada := "D"
Static cFechado := "F"
Static cCancelado := "C"

/*/{Protheus.doc} OFIA003
	Abertura de Ordens de Servico Manual MVC (VO1)

	@type function
	@author Iury Soares Azevedo
	@since 22/06/2025
/*/
Function OFIA003()
	Local oBrowse := BrowseDef()

	oBrowse:AddLegend( "VO1_STATUS == '" + cAberta		+ "'", "GREEN"	, STR0008 	) //Aberta
	oBrowse:AddLegend( "VO1_STATUS == '" + cLiberada	+ "'", "BLUE"	, STR0009 	) //Liberada
	oBrowse:AddLegend( "VO1_STATUS == '" + cFechado		+ "'", "RED"	, STR0010 	) //Fechada
	oBrowse:AddLegend( "VO1_STATUS == '" + cCancelado	+ "'", "BLACK"	, STR0011 	) //Cancelada
	

	oBrowse:Activate()
Return

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VO1')
	oBrowse:SetDescription(STR0001) // 'Abertura de OS - Manual'
Return oBrowse


Static Function ModelDef()
	Local oModel := MPFormModel():New('OFIA003')
	Local oStruVO1 := FWFormStruct( 1, 'VO1' )

	// oStruVO1:SetProperty("VO1_NUMOSV", MODEL_FIELD_INIT,{|| NumOS() })
	oStruVO1:SetProperty("VO1_GETKEY", MODEL_FIELD_VALID,{|oModel| ValidGetKey(oModel) })

	oModel:AddFields( 'MODEL_VO1', /*cOwner*/, oStruVO1)

	oModel:GetModel( 'MODEL_VO1' ):SetDescription( STR0002 ) // 'Abertura de OS - Manual - ABRIR O. S.'
	
	oModel:SetPrimaryKey( { "VO1_FILIAL", "VO1_NUMOSV" } )

	oModel:InstallEvent("DEF",, OFIA003EVDEF():New())

Return oModel

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oModel   := FWLoadModel( 'OFIA003' )
	Local oStruVO1 := FWFormStruct( 2, 'VO1' ,{|cField| !cField $ "VO1_NUMOSV/VO1_DATSAI/VO1_HORSAI/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_TIPSOL/VO1_SITGAR/VO1_OBSMEM/VO1_CODMAR/VO1_EXPGAR/VO1_MOTIVO/VO1_DESMOT/VO1_TEMFEC/VO1_TEMCAN/VO1_OBSLAU"})

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VO1', oStruVO1, 'MODEL_VO1' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VO1', 'TELA' )
Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.OFIA003' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA003' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.OFIA003' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.OFIA003' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.OFIA003' OPERATION 9 ACCESS 0 // 'Replicar'
Return aRotina


Static Function ValidGetKey(oVO1)
	Local lRet := .T.
	Local oVeiculos := Nil
	Local cSegmento := ""
	Local aCidEst := {}
	Private cGetKey := oVO1:GetValue("VO1_GETKEY")

	VV1->(dbSelectArea("VV1"))
	
	If !Empty(cGetKey) .AND. FG_POSVEI("cGetKey")
		oVeiculos := DMS_Veiculo():New()
		// Chassi Bloqueado
		If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
			
			lRet := .F. // A mensagem já é exibida dentro da função Bloqueado()

		EndIf

		If lRet ; 
				.AND. (Empty(VV1->VV1_PROATU) .or. Empty(VV1->VV1_LJPATU))
			
			Help(" ",1,"OM010OBR")
			lRet := .F.

		EndIf

		If lRet ;
				.AND. !IsBlind();
				.AND. !Empty(M->VO1_PROVEI+M->VO1_LOJPRO);
				.AND. VV1->VV1_PROATU+VV1->VV1_LJPATU != M->VO1_PROVEI+M->VO1_LOJPRO;
				.AND. !MsgYesNo(STR0012,STR0013) // O Proprietário deste novo Chassi está diferente do Proprietário do Chassi informado inicialmente nesta OS? Continuar? / Atenção
			
			lRet := .F.

		Endif

		If lRet ;
				.AND. !IsBlind();
				.AND. FindFunction("OFA1100016_PesquisaCampanha"); 
				.AND. VOU->(FieldPos("VOU_SERINT")) > 0
			OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
		EndIf

		oVO1:LoadValue("VO1_CHAINT",VV1->VV1_CHAINT)
		oVO1:LoadValue("VO1_CHASSI",AllTrim(VV1->VV1_CHASSI))
		oVO1:LoadValue("VO1_PLAVEI",VV1->VV1_PLAVEI)
		oVO1:LoadValue("VO1_CODFRO",VV1->VV1_CODFRO)
		oVO1:LoadValue("VO1_FABMOD",VV1->VV1_FABMOD)
		oVO1:LoadValue("VO1_LOJPRO",VV1->VV1_LJPATU)

		VE1->(dbSelectArea("VE1"))
		VE1->(dbSetOrder(1))
		If VE1->(MsSeek(xFiliaL("VE1")+VV1->VV1_CODMAR))
			oVO1:LoadValue("VO1_CODMAR",VE1->VE1_CODMAR)
			oVO1:LoadValue("VO1_DESMAR",VE1->VE1_DESMAR)
		EndIf
	
		VV2->(dbSelectArea("VV2"))
		VV2->(dbSetOrder(1))
		If VV2->(MsSeek(xFiliaL("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			oVO1:LoadValue("VO1_DESMOD",VV2->VV2_DESMOD)
		EndIf
	
		VVC->(dbSelectArea("VVC"))
		VVC->(dbSetOrder(1))
		If VVC->(MsSeek(xFiliaL("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
			oVO1:LoadValue("VO1_DESCOR",VVC->VVC_DESCRI)
		EndIf
		
		SA1->(dbSelectArea("SA1"))
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFiliaL("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU))
			aCidEst := ValidaCidadeEstado()
			oVO1:LoadValue("VO1_PROVEI",SA1->A1_COD)
			oVO1:LoadValue("VO1_LOJPRO",SA1->A1_LOJA)
			oVO1:LoadValue("VO1_NOMPRO",Left(SA1->A1_NOME,TamSX3("VO1_NOMPRO")[1]))
			oVO1:LoadValue("VO1_NOMFAT",Left(SA1->A1_NOME,TamSX3("VO1_NOMFAT")[1]))
			oVO1:LoadValue("VO1_ENDPRO",Left(SA1->A1_END,TamSX3("VO1_ENDPRO")[1]))
			oVO1:LoadValue("VO1_CIDPRO",Left(aCidEst[1],TamSX3("VO1_CIDPRO")[1]))
			oVO1:LoadValue("VO1_ESTPRO",Left(aCidEst[2],TamSX3("VO1_ESTPRO")[1]))
			oVO1:LoadValue("VO1_FONPRO",Left(SA1->A1_TEL,TamSX3("VO1_FONPRO")[1]))
		EndIf

		If FindFunction("OM0100062_buscaAgendamentos")
			oVO1:LoadValue("VO1_NUMAGE", OM0100062_buscaAgendamentos(oVO1:GetValue("VO1_CHASSI"), oVO1:GetValue("VO1_DATABE"), oVO1:GetValue("VO1_HORABE")))
			If !Empty(oVO1:GetValue("VO1_NUMAGE"))
				OM350STATUS(oVO1:GetValue("VO1_NUMAGE"),"1","2")
			Endif
		Endif

		VXA010GVO5(VV1->VV1_CHAINT,3)
		If ExistBlock("VA010DPGR")
			ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpcE,VO5->(RecNo())})
		EndIf


		If !Empty(oVO1:GetValue("VO1_FATPAR")+oVO1:GetValue("VO1_LOJA"))// Se existir "Faturar para", vale ele
			cSegmento := BuscaSegmento(oVO1:GetValue("VO1_FATPAR"),oVO1:GetValue("VO1_LOJA"))// Segmento do Faturar para
		ElseIf !Empty(oVO1:GetValue("VO1_PROVEI")+oVO1:GetValue("VO1_LOJPRO")) // Senao, vale o "Proprietario do Veiculo" se existir
			cSegmento := BuscaSegmento(oVO1:GetValue("VO1_PROVEI"),oVO1:GetValue("VO1_LOJPRO")) // Segmento do Proprietario do Veiculo
		EndIf

		If !Empty(cSegmento)
			oVO1:LoadValue("VO1_SEGMTO",cSegmento,"VO1_SEGMTO")
		EndIf
	EndIf

Return lRet

// Static Function FormataTexto(cTexto, cCampo)
// 	Local cRet := Left(AllTrim(cTexto), TamSX3(cCampo)[1])
// Return cRet


Static Function BuscaSegmento(cCdCli,cLjCli)
	Local cRet := ""
	VCF->(dbSelectArea("VCF"))
	VCF->(dbSetOrder(1))

	if VCF->(FieldPos("VCF_SEGMTO")) > 0 ;
			.AND. !empty(cCdCli) .AND. !empty(cLjCli);
			.AND. VCF->(msSeek(xFilial("VCF") + cCdCli + cLjCli))
		
		cRet := VCF->VCF_SEGMTO

	endif
return cRet


Function ValidaCidadeEstado()

	Local lVAMCid  := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
	Local aRet := {}

	if lVAMCid
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		aadd(aRet,VAM->VAM_DESCID)
		aadd(aRet,VAM->VAM_ESTADO)
	Else
		aadd(aRet,SA1->A1_MUN)
		aadd(aRet,SA1->A1_EST)
	Endif

Return aRet

