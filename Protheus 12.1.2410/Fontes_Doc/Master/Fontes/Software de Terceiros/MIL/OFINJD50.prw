#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'OFINJD50.CH'

Static oInfoNota
Static oMGarantia
Static oMArqRetor
Static oMCpoTotal

/*/{Protheus.doc} OFINJD50()

Rotina para gerenciamento de Faturas Dealer
(Mercado Internacional)

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFINJD50()

	Local oBrwFat
	Local aColumns:= OFJD500115_ColunasBrowse()
	Local aBkpRot := {}
	Local aIndex   := {}
	Local aSeek	:= {}

	if Type("aRotina") <> "U"
		aBkpRot := aClone(aRotina)
	EndIf

	aRotina := {}

	Aadd( aIndex, "VMBFILIAL+VMBNFTDEA+VMBSFTDEA")

	Aadd( aSeek, { Alltrim(RetTitle("VMB_FILIAL")) + "+" + RetTitle("VMB_NFTDEA") + "+" + RetTitle("VMB_SFTDEA") , {{"","C",TamSX3("VMB_FILIAL")[1],0, RetTitle("VMB_FILIAL"),,},{"","C",TamSX3("VMB_NFTDEA")[1],0, RetTitle("VMB_NFTDEA"),,},{"","C",TamSX3("VMB_SFTDEA")[1],0,RetTitle("VMB_SFTDEA"),,}}}) // "Filial/Nota/Série"

	oBrwFat:= FWMBrowse():New()
	oBrwFat:SetDescription(STR0004) // Faturas Dealer
	oBrwFat:SetDataQuery(.T.)
	oBrwFat:SetAlias("FATDEA")
	oBrwFat:SetQueryIndex(aIndex)
	oBrwFat:SetQuery( OFJD500105_Query() )
	oBrwFat:SetSeek(,aSeek)
	oBrwFat:SetMenuDef("")
	oBrwFat:AddButton( STR0001 , {|| OFJD500135_VisualizaFaturaDealer(oBrwFat) },,2,2) // Visualizar Fatura
	oBrwFat:AddButton( STR0002 , {|| OFJD500085_GeraFaturaDealer(oBrwFat) },,2,2) // Gerar Fatura
	oBrwFat:AddButton( STR0003 , {|| OFJD500095_CancelaFaturaDealer(oBrwFat) },,2,2) // Cancelar Fatura
	oBrwFat:SetColumns(aColumns)
	oBrwFat:DisableDetails()
	oBrwFat:DisableLocate()
	oBrwFat:SetAmbiente(.F.)
	oBrwFat:SetWalkthru(.F.)
	oBrwFat:SetUseFilter(.T.)
	oBrwFat:lOptionReport := .F.
	oBrwFat:Activate()

	aRotina := aClone(aBkpRot)

Return

/*/{Protheus.doc} ModelDef()

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function ModelDef()

	Local oModel 

	Local oStruInfNf
	Local oStruGarant
	Local oStruCpoTot

	Local bLoadInfNf := {|oModel| OFJD500045_GetInformacaoNotaFiscal(oModel)}
	Local bLoadBonus := {|oModel| OFJD500055_GetGarantiasLiberadas(oModel)}

	If oInfoNota == NIL
		oInfoNota  := OFJD500015_InformacaoNotaFiscal()
		oMGarantia := OFJD500025_Garantias()
		oMCpoTotal := OFJD500035_Totais()
	EndIf

	oStruInfNf  := oInfoNota:GetModel()
	oStruGarant := oMGarantia:GetModel()
	oStruCpoTot := oMCpoTotal:GetModel()

	oStruGarant:AddTrigger( "CPOSELGAR", "CPOSELGAR", {|| .T.}, { |oModel,cField,xVal| OFNJD50065_GarantiaSelecionada(oModel,cField,xVal) } )
	oStruCpoTot:AddTrigger( "CPOTOTGAR", "CPOTOTFAT", {|| .T.}, { |oModel| oModel:GetValue( "CPOTOTGAR" ) } )


	oModel := MPFormModel():New( 'OFINJD50', /* bPre */, /*bPost*/ , { || .t. } /* bCommit */ , { || .T. }/* bCancel */ )

	oModel:AddFields('INFORMACAONF', /* cOwner */   , oStruInfNf  , /* <bPre> */ , /* <bPost> */ , bLoadInfNf /* <bLoad> */ )
	oModel:AddGrid('GARANTIAS' ,'INFORMACAONF'  , oStruGarant , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadBonus/* <bLoad> */ )
	oModel:AddFields('CAMPOSTOTAL' , 'INFORMACAONF' , oStruCpoTot , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { |oModel| OFJD500125_GetTotais(oModel) } )

	oModel:SetDescription( STR0005 ) // 'Geração de fatura dealer'
	
	oModel:GetModel('INFORMACAONF'  ):SetDescription( STR0006 )	// 'Informações da fatura dealer'
	oModel:GetModel('GARANTIAS' ):SetDescription( STR0007 )	// 'Solicitações de Garantias'
	oModel:GetModel('CAMPOSTOTAL'   ):SetDescription( STR0008 )	// 'Campos de totais'

	oModel:GetModel('INFORMACAONF'  ):SetOnlyQuery( .T. )
	oModel:GetModel('GARANTIAS' ):SetOnlyQuery( .T. )
	
	oModel:GetModel('GARANTIAS' ):SetOptional( .T. )

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("OFINJD50EVDEF", /*cOwner*/, OFINJD50EVDEF():New("OFINJD50"))

Return oModel

/*/{Protheus.doc} ViewDef()

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'OFINJD50' )
	Local oView 	:= Nil

	Local oStruInfNf  := oInfoNota:GetView()
	Local oStruGarant := oMGarantia:GetView()
	Local oCalcTOT    := oMCpoTotal:GetView()


	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FIELDS_INFORMACAONF' , oStruInfNf  , 'INFORMACAONF')
	oView:AddField('GRID_MODELO_TOTALIZA', oCalcTOT    , 'CAMPOSTOTAL')
	
	oView:AddGrid('GRID_GARANTIA' , oStruGarant , 'GARANTIAS')
	
	oView:EnableTitleView('FIELDS_INFORMACAONF', STR0006 ) //'Informações da fatura dealer'
	
	oView:EnableTitleView('GRID_GARANTIA', STR0007 ) //"Solicitações de Garantias"
	oView:SetNoInsertLine('GRID_GARANTIA')
	oView:SetNoDeleteLine('GRID_GARANTIA')

	oView:CreateHorizontalBox('TELA_INFORMNF',30)
	oView:CreateHorizontalBox('TELA_GARANTIA',60)
	oView:CreateHorizontalBox('TELA_TOTALIZA',10)

	oView:SetOwnerView('FIELDS_INFORMACAONF' ,'TELA_INFORMNF')
	oView:SetOwnerView('GRID_GARANTIA' ,'TELA_GARANTIA')
	oView:SetOwnerView('GRID_MODELO_TOTALIZA','TELA_TOTALIZA')

	oView:SetViewProperty("GRID_GARANTIA", "GRIDSEEK", {.T.})

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/{Protheus.doc} OFJD500015_InformacaoNotaFiscal()

	Função de estrutura dos campos da model de Informacões da Nota Fiscal

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500015_InformacaoNotaFiscal()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "SC5" , "C5_CLIENTE" , { {"cIdField" , "C5CLIENTE" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_LOJACLI" , { {"cIdField" , "C5LOJACLI" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_VEND1"   , { {"cIdField" , "C5VEND1"   } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_CONDPAG" , { {"cIdField" , "C5CONDPAG" } } )
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0009     } ,; //"Produto"
		{ "cTooltip" , STR0009     } ,;
		{ "cIdField" , "CPOCODPRD" } ,;
		{ "cTipo"    , "C"         } ,;
		{ "nTamanho" , 70          } ,;
		{ "cLookUp"  , "SB1"       } ,;
		{ "bValid"   , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. FG_Seek('SB1','CPOCODPRD',1)") } ,;
		{ "bInit"    , { || Space(70) } } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddFieldDictionary( "SC5" , "C5_NATUREZ" , { {"cIdField" , "C5NATUREZ" }, { "cLookUp", "SED" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_TIPOCLI" , { {"cIdField" , "C5TIPOCLI" }, { "bWhen" , { || .t. } } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MOEDA"   , { {"cIdField" , "C5MOEDA"   }, { "bWhen" , { || .t. } } , { "bValid" , { || .t. } } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MENPAD"  , { {"cIdField" , "C5MENPAD"  }, { "bWhen" , { || .t. } } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MENNOTA" , { {"cIdField" , "C5MENNOTA" }, { "bWhen" , { || .t. } } } )

	if cPaisLoc $ "ARG/MEX"
		oRetorno:AddFieldDictionary( "VMB" , "VMB_NFTDEA" , { {"cIdField" , "VMBNFTDEA" }, { "bWhen" , { || .f. } } } )
		oRetorno:AddFieldDictionary( "VMB" , "VMB_SFTDEA" , { {"cIdField" , "VMBSFTDEA" }, { "bWhen" , { || .f. } } } )
	Endif

Return oRetorno

/*/{Protheus.doc} OFJD500025_Garantias()

	Função de estrutura dos campos da model de Garantias

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500025_Garantias()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','CPOSELGAR', , .t.)

	oRetorno:AddFieldDictionary( "VMB" , "VMB_CHASSI" , { {"cIdField" , "VMBCHASSI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VMB" , "VMB_NUMOSV" , { {"cIdField" , "VMBNUMOSV" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VMB" , "VMB_CLAIM"  , { {"cIdField" , "VMBCLAIM"  } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VMB" , "VMB_TIPGAR" , { {"cIdField" , "VMBTIPGAR" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VMB" , "VMB_DTFALH" , { {"cIdField" , "VMBDTFALH" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VMB" , "VMB_TOTALW" , { {"cIdField" , "VMBTOTALW" } , { "lCanChange" , .f. } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0010 } ,; //"Recno"
		{ "cTooltip" , STR0010 } ,;
		{ "cIdField" , "RECNOVMB" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 999999 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

/*/{Protheus.doc} OFJD500035_Totais()

	Função de estrutura dos campos da model de Totais

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500035_Totais()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0011 } ,; //"Total Selecionado"
		{ "cTooltip" , STR0011 } ,;
		{ "cIdField" , "CPOTOTGAR" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0012 } ,; //"Valor total da fatura"
		{ "cTooltip" , STR0012 } ,;
		{ "cIdField" , "CPOTOTFAT" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .t. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

/*/{Protheus.doc} OFJD500045_GetInformacaoNotaFiscal()

	Função de carregamento de dados para a model de Informações da Nota Fiscal

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500045_GetInformacaoNotaFiscal(oModel)

	Local aAuxFields := oModel:GetStruct():GetFields()
	Local aRetorno   := Array(Len(aAuxFields))

	Local lCancelNf := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local lVisualNf := oModel:GetOperation() == MODEL_OPERATION_VIEW
	

	If lCancelNf .or. lVisualNf .and. cPaisLoc $ "ARG/MEX"

		SC5->(DbSeek(xFilial("SC5")+FATDEA->VMBPFTDEA))

		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5CLIENTE")] := SC5->C5_CLIENTE
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5LOJACLI")] := SC5->C5_LOJACLI
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5VEND1")]   := SC5->C5_VEND1
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5CONDPAG")] := SC5->C5_CONDPAG
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5NATUREZ")] := SC5->C5_NATUREZ
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5TIPOCLI")] := SC5->C5_TIPOCLI
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MOEDA")]   := SC5->C5_MOEDA
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MENPAD")]  := SC5->C5_MENPAD
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MENNOTA")] := SC5->C5_MENNOTA

		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"VMBNFTDEA")] := FATDEA->VMBNFTDEA
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"VMBSFTDEA")] := FATDEA->VMBSFTDEA

	Else

		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5CLIENTE")] := space(GetSX3Cache("C5_CLIENTE","X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5LOJACLI")] := space(GetSX3Cache("C5_LOJACLI","X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5VEND1")]   := space(GetSX3Cache("C5_VEND1"  ,"X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5CONDPAG")] := space(GetSX3Cache("C5_CONDPAG","X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"CPOCODPRD")] := space(GetSX3Cache("B1_COD"    ,"X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5NATUREZ")] := space(GetSX3Cache("C5_NATUREZ","X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5TIPOCLI")] := space(GetSX3Cache("C5_TIPOCLI","X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MOEDA")]   := 1
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MENPAD")]  := space(GetSX3Cache("C5_MENPAD" ,"X3_TAMANHO"))
		aRetorno[OFNJD50075_PesquisaCampo(aAuxFields,"C5MENNOTA")] := space(GetSX3Cache("C5_MENNOTA","X3_TAMANHO"))

	EndIf

Return aRetorno

/*/{Protheus.doc} OFJD500055_GetGarantiasLiberadas()

	Função de carregamento de dados para a model de Garantias

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500055_GetGarantiasLiberadas(oModel)

	Local aRetorno  := {}
	Local lCancelNf := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local lVisualNf := oModel:GetOperation() == MODEL_OPERATION_VIEW

	cQuery := "SELECT VMB.VMB_CHASSI, VMB.VMB_NUMOSV , VMB.VMB_CLAIM , VMB.VMB_TIPGAR, VMB.VMB_DTFALH, VMB.VMB_TOTALW , VMB.R_E_C_N_O_ RECVMB"
	cQuery += " FROM " + RetSQLName("VMB") + " VMB "

	If !lCancelNf .and. !lVisualNf
		cQuery += 	" JOIN " + RetSqlName("VMC") + " VMC ON VMC.VMC_FILIAL = VMB.VMB_FILIAL AND VMC.VMC_CODGAR = VMB.VMB_CODGAR AND VMC.D_E_L_E_T_ = ' ' "
		cQuery += 	" JOIN " + RetSqlName("VOO") + " VOO ON VOO.VOO_FILIAL = VMB.VMB_FILIAL AND VOO.VOO_NUMOSV = VMB.VMB_NUMOSV AND VOO.VOO_LIBVOO = VMC.VMC_LIBVOO AND VOO.VOO_TIPTEM = VMC.VMC_TIPTEM AND VOO.VOO_NUMNFI <> ' ' "
	EndIf

	cQuery += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "' "

	if cPaisLoc $ "ARG/MEX"

		If lCancelNf .or. lVisualNf 
			cQuery += 	" AND VMB.VMB_PFTDEA = '" + FATDEA->VMBPFTDEA + "'"
			cQuery += 	" AND VMB.VMB_NFTDEA = '" + FATDEA->VMBNFTDEA + "'"
			cQuery += 	" AND VMB.VMB_SFTDEA = '" + FATDEA->VMBSFTDEA + "'"
		Else
			cQuery += 	" AND VMB.VMB_NFTDEA = ' '"
			cQuery += 	" AND VMB.VMB_SFTDEA = ' '"
			cQuery += 	" AND VMB.VMB_TOTALW <> 0 "
			cQuery += 	" AND VMB.VMB_STATSG IN ('3','5') "		
		Endif
	
	Endif

	cQuery += 	" AND VMB.D_E_L_E_T_ = ' '"

	cQuery += " GROUP BY VMB.VMB_CHASSI, VMB.VMB_NUMOSV , VMB.VMB_CLAIM , VMB.VMB_TIPGAR, VMB.VMB_DTFALH, VMB.VMB_TOTALW , VMB.R_E_C_N_O_ "

	TcQuery cQuery New Alias "TMPVMB"

	While !TMPVMB->( Eof() )

		aAdd(aRetorno,{ ;
				Len(aRetorno) + 1 ,;
				{ 	If(lCancelNf,.t.,.f.) ,;
					TMPVMB->VMB_CHASSI ,;
					TMPVMB->VMB_NUMOSV ,;
					TMPVMB->VMB_CLAIM  ,;
					TMPVMB->VMB_TIPGAR ,;
					StoD(TMPVMB->VMB_DTFALH) ,;
					TMPVMB->VMB_TOTALW ,;
					TMPVMB->RECVMB ;
				};
		})
		TMPVMB->( DbSkip() )

	EndDo

	TMPVMB->( DbCloseArea() )

Return aRetorno

/*/{Protheus.doc} OFNJD50065_GarantiaSelecionada()

	Função de gatilho para o campo da model de Totais

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFNJD50065_GarantiaSelecionada(oModel,cField,xVal)

	Local oModCab := FwModelActive()

	cQuery := "SELECT VO1.VO1_MOEDA "
	cQuery += " FROM " + RetSqlName("VO1") + " VO1 "
	cQuery += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' "
	cQuery += 	" AND VO1.VO1_NUMOSV = '" + oModCab:GetValue("GARANTIAS","VMBNUMOSV") + "' "
	cQuery += 	" AND VO1.D_E_L_E_T_ = ' ' "

	nMoedaOS := FM_SQL(cQuery)

	nVConvert := FG_MOEDA( oModel:GetValue("VMBTOTALW") , nMoedaOS , oModCab:GetValue("INFORMACAONF","C5MOEDA"),,2)

	If xVal
		nValGar += nVConvert
	Else
		nValGar -= nVConvert
	EndIf

	oModCab:SetValue("CAMPOSTOTAL","CPOTOTGAR",nValGar)

Return

/*/{Protheus.doc} OFNJD50075_PesquisaCampo()

	Função para pesquisar o campo no vetor de estrutura de campos da model

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFNJD50075_PesquisaCampo(aFields,cCpoPesq)

	Local nRetorno := 0

	Default aFields := {}

	If Len(aFields) > 0
		nRetorno := aScan(aFields,{|x| x[3] == cCpoPesq })
	EndIf

Return nRetorno


/*/{Protheus.doc} OFJD500085_GeraFaturaDealer()

	Função para geração da fatura dealer

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFJD500085_GeraFaturaDealer(oBrowse)

	Local oViewGer := FWLoadView("OFINJD50")
	Local oStruView

	Private nValGar := 0 // Utilizado na consulta padrao de modelos 
	Private nValRet := 0

	oStruView := oViewGer:GetViewStruct( 'INFORMACAONF' )
	oStruView:RemoveField("VMBNFTDEA")
	oStruView:RemoveField("VMBSFTDEA")

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0005 ) //"Geração de fatura dealer"
	oExecView:setView(oViewGer)
	oExecView:setSource("OFINJD50")
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

	oBrowse:Refresh()
Return


/*/{Protheus.doc} OFJD500095_CancelaFaturaDealer()

	Função para cancelamento da fatura dealer

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFJD500095_CancelaFaturaDealer(oBrowse)

	Local oViewGer := FWLoadView("OFINJD50")

	Private nValGar := 0 // Utilizado na consulta padrao de modelos 
	Private nValRet := 0

	If Empty(FATDEA->VMBNFTDEA)
		Return .f.
	EndIf

	oViewGer:GetViewStruct( 'INFORMACAONF' ):RemoveField("CPOCODPRD")
	oViewGer:GetViewStruct( 'GARANTIAS'    ):RemoveField("CPOSELGAR")
	oViewGer:GetViewStruct( 'CAMPOSTOTAL'  ):RemoveField("CPOTOTGAR")

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0013 ) //"Cancelamento da fatura dealer"
	oExecView:setView(oViewGer)
	oExecView:setSource("OFINJD50")
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_DELETE)
	oExecView:openView(.T.)

	oBrowse:Refresh()

Return

/*/{Protheus.doc} OFJD500105_Query()

	Função para levanntamento das faturas dealer

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFJD500105_Query()

	Local cRetSQL := ""

	cRetSQL += "SELECT VMB_FILIAL AS VMBFILIAL, F2_EMISSAO AS F2EMISSAO , VMB_PFTDEA AS VMBPFTDEA , VMB_NFTDEA AS VMBNFTDEA , VMB_SFTDEA AS VMBSFTDEA, VMB_CFTDEA AS VMBCFTDEA, VMB_LFTDEA AS VMBLFTDEA, A1_NOME AS A1NOME "
	cRetSQL += "  FROM " + RetSQLName("VMB") + " VMB "
	cRetSQL += "  JOIN " + RetSQLName("SF2") + " SF2 "
	cRetSQL += 		"  ON SF2.F2_DOC     = VMB.VMB_NFTDEA "
	cRetSQL += 		" AND SF2.F2_SERIE   = VMB.VMB_SFTDEA "
	cRetSQL += 		" AND SF2.F2_CLIENTE = VMB.VMB_CFTDEA "
	cRetSQL += 		" AND SF2.F2_LOJA    = VMB.VMB_LFTDEA "
	cRetSQL += 		" AND SF2.D_E_L_E_T_ = ' '"
	cRetSQL += "  JOIN " + RetSQLName("SA1") + " SA1 "
	cRetSQL += 		"  ON SA1.A1_COD     = VMB.VMB_CFTDEA "
	cRetSQL += 		" AND SA1.A1_LOJA    = VMB.VMB_LFTDEA "
	cRetSQL += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
	cRetSQL += 		" AND VMB.VMB_PFTDEA <> ' '"
	cRetSQL += 		" AND VMB.VMB_NFTDEA <> ' '"
	cRetSQL += 		" AND VMB.VMB_SFTDEA <> ' '"
	cRetSQL += 		" AND VMB.D_E_L_E_T_ = ' ' "
	cRetSQL += " GROUP BY VMB_FILIAL, F2_EMISSAO, VMB_PFTDEA , VMB_NFTDEA , VMB_SFTDEA , VMB_CFTDEA, VMB_LFTDEA, A1_NOME"

Return cRetSQL

/*/{Protheus.doc} OFJD500115_ColunasBrowse()

	Função para indicação das colunas do browse

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFJD500115_ColunasBrowse()

	Local aColumns := {}

	AAdd(aColumns,FWBrwColumn():New())
		aColumns[1]:SetData( &("{|| VMBFILIAL }") ) 
		aColumns[1]:SetTitle(RetTitle("VMB_FILIAL"))
		aColumns[1]:SetSize(10)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[2]:SetData( &("{|| Stod(F2EMISSAO) }") ) 
		aColumns[2]:SetTitle(RetTitle("F2_EMISSAO"))
		aColumns[2]:SetSize(15)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[3]:SetData( &("{|| VMBPFTDEA }") ) 
		aColumns[3]:SetTitle(RetTitle("VMB_PFTDEA"))
		aColumns[3]:SetSize(15)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[4]:SetData( &("{|| VMBNFTDEA }") ) 
		aColumns[4]:SetTitle(RetTitle("VMB_NFTDEA"))
		aColumns[4]:SetSize(30)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[5]:SetData( &("{|| VMBSFTDEA }") ) 
		aColumns[5]:SetTitle(RetTitle("VMB_SFTDEA"))
		aColumns[5]:SetSize(15)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[6]:SetData( &("{|| VMBCFTDEA }") ) 
		aColumns[6]:SetTitle(RetTitle("VMB_CFTDEA"))
		aColumns[6]:SetSize(20)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[7]:SetData( &("{|| VMBLFTDEA }") ) 
		aColumns[7]:SetTitle(RetTitle("VMB_LFTDEA"))
		aColumns[7]:SetSize(10)
	AAdd(aColumns,FWBrwColumn():New())
		aColumns[8]:SetData( &("{|| A1NOME }") ) 
		aColumns[8]:SetTitle(RetTitle("A1_NOME"))
		aColumns[8]:SetSize(10)

Return aColumns

/*/{Protheus.doc} OFJD500125_GetTotais()

	Função de carregamento de dados da model de Totais

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Static Function OFJD500125_GetTotais(oModel)

	Local lCancelNf := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local lVisualNf := oModel:GetOperation() == MODEL_OPERATION_VIEW
	Local aRetorno  := {0,0}

	If lCancelNf .or. lVisualNf .and. cPaisLoc $ "ARG/MEX"

		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2")+ FATDEA->VMBNFTDEA+FATDEA->VMBSFTDEA+FATDEA->VMBCFTDEA+FATDEA->VMBLFTDEA))

		aRetorno[2] := SF2->F2_VALMERC

	EndIf

Return aRetorno

/*/{Protheus.doc} OFJD500135_VisualizaFaturaDealer()

	Função para cancelamento da fatura dealer

@author Renato Vinicius
@since 27/01/2024
@version undefined
@type function
/*/

Function OFJD500135_VisualizaFaturaDealer(oBrowse)

	Local oViewGer := FWLoadView("OFINJD50")

	Private nValGar := 0 // Utilizado na consulta padrao de modelos 
	Private nValRet := 0

	If Empty(FATDEA->VMBNFTDEA)
		Return .f.
	EndIf

	oViewGer:GetViewStruct( 'INFORMACAONF' ):RemoveField("CPOCODPRD")
	oViewGer:GetViewStruct( 'GARANTIAS'    ):RemoveField("CPOSELGAR")
	oViewGer:GetViewStruct( 'CAMPOSTOTAL'  ):RemoveField("CPOTOTGAR")

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0014 ) //"Visualização da fatura dealer"
	oExecView:setView(oViewGer)
	oExecView:setSource("OFINJD50")
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

	oBrowse:Refresh()

Return
