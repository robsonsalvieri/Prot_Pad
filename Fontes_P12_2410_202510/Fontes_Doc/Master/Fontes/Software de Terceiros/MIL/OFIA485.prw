//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#include "AP5MAIL.CH"
#Include 'OFIA485.CH'

static aSugest := {}

/*/{Protheus.doc} OFIA485

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
 
Function OFIA485( xSugest, lBO, lAguardar )

	Default lBO         := .f.
	Default lAguard     := .f.
	Default xSugest     := {}

	//Private lAguardar  := lAguard
	Private lRegBo      := lBo
	Private lOk         := .f.
	Private lMsErroAuto := .f.
	Private lNovaSug
	Private cOrigem     := "1"

	aSugest := xSugest

	If IsInCallStack("OFIOM020") .or. IsInCallStack("OFIXA120")
		cOrigem := "2"
	EndIf

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001) // "Sugestão de Compra"
	oExecView:setSource("OFIA485")
	oExecView:setOK({ || .T. })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return lOk


Static Function ModelDef()

	Local oModel 

	Local oMModPAR 		:= OA4850015_CamposGridPAR()
	Local oMModSFJ 		:= OA4850075_CamposGridSFJ()
	Local oMModSDF 		:= OA4850025_CamposGridSDF()

	Local oModeloPAR 	:= oMModPAR:GetModel()
	Local oModeloSFJ 	:= oMModSFJ:GetModel()
	Local oModeloSDF 	:= oMModSDF:GetModel()

	oModel := MPFormModel():New( 'OFIA485', /* bPre */, { || OA4850115_ValidaDados() } , {|| lOk := OA4850175_GravaSugestao() } /* bCommit */ , { || lOk := .f., .T. } /* bCancel */ )
	oModel:AddFields('MODPARAM'	, /* cOwner */	, oModeloPAR , /* <bPre> */ , /* <bPost> */ , {|oModel| OA4850035_LoadFieldParSug(oModel) } /* <bLoad> */ )

	oModel:AddGrid('MODSFJ'		, 'MODPARAM'	, oModeloSFJ , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ ,  {|oModelSug| OA4850065_LoadFieldCabSug(oModelSug) } /* <bLoad> */ )

	oModel:AddGrid('MODSDF'		,'MODPARAM'		, oModeloSDF , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ ,  {|oModelIte| OA4850045_LoadFieldIteSug(oModelIte) } /* <bLoad> */ )

	If IsInCallStack("OFIOM020") .or. IsInCallStack("OFIXA120")
		oModeloSDF:SetProperty( 'VB5GRUITE', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. OA4850145_GatilhoCodigoProduto()") )
		oModeloSDF:SetProperty( 'VB5CODITE', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "FS_VERBLQ3() .and. OA4850145_GatilhoCodigoProduto()" ) )
		oModeloSDF:SetProperty( 'VB5DESPRO', MODEL_FIELD_INIT,	FWBuildFeature( STRUCT_FEATURE_INIPAD, Posicione("SB1",1,xFilial("SB1")+VB5->VB5_GRUITE + VB5->VB5_CODITE,"B1_DESC")))
	EndIf

	oModel:SetDescription("Sugestão de Compra") // "Sugestão de Compra"

	oModel:GetModel('MODPARAM'):SetDescription( STR0002 )		// "Parametros Sugestão de Compra"
	oModel:GetModel('MODSFJ'  ):SetDescription( STR0001 )		// "Sugestão de Compra"
	oModel:GetModel("MODSDF"  ):SetDescription( STR0003 )		// "Itens da Sugestão de Compra"

	oModel:GetModel("MODSFJ"):SetOnlyView( .T. )
	oModel:GetModel("MODSFJ"):SetNoUpdateLine( .T. )

	If !IsInCallStack("OFIOM020") .and. !IsInCallStack("OFIXA120")
		oModel:GetModel("MODSDF"):SetNoInsertLine( .T. )
		oModel:GetModel("MODSDF"):SetNoDeleteLine( .T. )
	EndIf


	oModel:SetPrimaryKey({})
	
Return oModel


Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'OFIA485' )
	Local oView 	:= Nil

	Local oMModPAR := OA4850015_CamposGridPAR()
	Local oMModSFJ := OA4850075_CamposGridSFJ()
	Local oMModSDF := OA4850025_CamposGridSDF()

	Local oModeloPar := oMModPAR:GetView()
	Local oModeloSFJ := oMModSFJ:GetView()
	Local oModeloSDF := oMModSDF:GetView()

	If IsInCallStack("OFIXA120") .or. IsInCallStack("OFIOM020")
		
		oModeloSDF:SetProperty( 'VB5GRUITE' , MVC_VIEW_CANCHANGE , .t.)
		oModeloSDF:SetProperty( 'VB5CODITE' , MVC_VIEW_CANCHANGE , .t.)
		oModeloSDF:SetProperty( 'VB5QTDSUG' , MVC_VIEW_CANCHANGE , .t.)

		oModeloSDF:RemoveField('VB5SEQITE')
		oModeloSDF:RemoveField('VS3QTDITE')
		oModeloSDF:RemoveField('VS3QTDEST')

		oModeloPar:RemoveField('VS1NUMORC')
	Else
		oModeloPar:RemoveField('VO1NUMOSV')
		oModeloSDF:RemoveField('VB5CODVSJ')
	Endif

	oModeloSDF:RemoveField('CNOMTAB')
	oModeloSDF:RemoveField('NRECTAB')

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('PARSUG'	, oModeloPar , 'MODPARAM')
	oView:EnableTitleView('PARSUG', STR0002 ) // "Parametros da Sugestão de Compra"

	oView:AddGrid('SUGCOM'	, oModeloSFJ , 'MODSFJ')
	oView:EnableTitleView('SUGCOM', STR0001 ) // "Sugestão de Compra"

	oView:AddGrid('ITEMSUG'	, oModeloSDF , 'MODSDF')
	oView:EnableTitleView('ITEMSUG', STR0003 ) // "Itens da Sugestão de Compra"

	//oView:SetNoInsertLine('ITEMSUG')
	//oView:SetNoDeleteLine('ITEMSUG')

	oView:CreateHorizontalBox('BOX_SUGEST',30)
	oView:CreateVerticalBox(  'BOX_PARAM' , 45, 'BOX_SUGEST')
	oView:CreateVerticalBox(  'BOX_CODSUG', 55, 'BOX_SUGEST')
	oView:SetOwnerView('PARSUG','BOX_PARAM' )
	oView:SetOwnerView('SUGCOM','BOX_CODSUG')

	oView:CreateHorizontalBox('BOX_ITEMSUG',70)
	oView:SetOwnerView('ITEMSUG' ,'BOX_ITEMSUG')

	oModeloPar:RemoveField('PARFILIAL')
	oModeloPar:RemoveField('PARCODSUG')

	oModeloSFJ:RemoveField('NOVSUGEST')

	oModeloSDF:RemoveField('SDFFILIAL')
	oModeloSDF:RemoveField('SDFCODIGO')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView


Static Function OA4850015_CamposGridPAR()

	Local oRetorno := OFDMSStruct():New()
	
	oRetorno:AddFieldDictionary( "SFJ", "FJ_FILIAL"  , { {"cIdField" , "PARFILIAL" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_CODIGO"  , { {"cIdField" , "PARCODSUG" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_DATREF"  , { {"cIdField" , "PARDATREF" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_DIASSUG" , { {"cIdField" , "PARDIASSUG"} } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_CUSUNIT" , { {"cIdField" , "PARCUSUNIT"} } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_TIPPRC"  , { {"cIdField" , "PARTIPPRC" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_IMPORT"  , { {"cIdField" , "PARIMPORT" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_CLASSIF" , { {"cIdField" , "PARCLASSIF"} } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_ANO"     , { {"cIdField" , "PARANO"    } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_MES"     , { {"cIdField" , "PARMES"    } } )

	oRetorno:AddFieldDictionary( "VS1", "VS1_NUMORC" , { {"cIdField" , "VS1NUMORC" } } )
	oRetorno:AddFieldDictionary( "VO1", "VO1_NUMOSV" , { {"cIdField" , "VO1NUMOSV" } } )
//	oRetorno:AddButton(STR0019,'BTNPESQUISA',{ |oMdl| OA4850075_BuscarConfiguracao(oMdl) }) // Buscar Configurações

Return oRetorno


Static Function OA4850075_CamposGridSFJ()

	Local oRetorno := OFDMSStruct():New()
	
	oRetorno:AddFieldDictionary( "SFJ", "FJ_FILIAL"  , { {"cIdField" , "SFJFILIAL" } } )
	oRetorno:AddFieldDictionary( "SFJ", "FJ_CODIGO"  , { {"cIdField" , "SFJCODSUG" } } )

	if SFJ->(FieldPos("FJ_TIPPED")) > 0
		oRetorno:AddFieldDictionary( "SFJ", "FJ_TIPPED"  , { {"cIdField" , "SFJTIPPED" } } )
	endif

	oRetorno:AddField( { ;
		{ "cTitulo"  , "Cod Tipo Ped" } ,;
		{ "cTooltip" , "Cd Tipo Ped" } ,;
		{ "cIdField" , "CODTIPPED" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VEJ_CODIGO","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , "Nova Sugestão?" } ,;
		{ "cTooltip" , "Nova Sugestão?" } ,;
		{ "cIdField" , "NOVSUGEST" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 1 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno


Static Function OA4850025_CamposGridSDF()

	Local oRetorno := OFDMSStruct():New()
	
	oRetorno:AddFieldDictionary( "SDF", "DF_FILIAL"  , { {"cIdField" , "SDFFILIAL"} } )
	oRetorno:AddFieldDictionary( "SDF", "DF_CODIGO"  , { {"cIdField" , "SDFCODIGO"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_SEQITE" , { {"cIdField" , "VB5SEQITE"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_GRUITE" , { {"cIdField" , "VB5GRUITE"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_CODITE" , { {"cIdField" , "VB5CODITE"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_COD"    , { {"cIdField" , "VB5CODPRO"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_DESC"   , { {"cIdField" , "VB5DESPRO"} } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDITE" , { {"cIdField" , "VS3QTDITE"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDRES" , { {"cIdField" , "VS3QTDRES"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDEST" , { {"cIdField" , "VS3QTDEST"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_QTDSUG" , { {"cIdField" , "VB5QTDSUG"} } )
	oRetorno:AddFieldDictionary( "VB5", "VB5_CODVSJ" , { {"cIdField" , "VB5CODVSJ"} } )
	
	if SFJ->(FieldPos("FJ_TIPPED")) > 0
		oRetorno:AddFieldDictionary( "SFJ", "FJ_TIPPED" , { {"cIdField" , "FJTIPPED"}, { 'bValid' , FWBuildFeature(STRUCT_FEATURE_VALID,'OA4850055_ValidTipoPedido(VEJ->VEJ_CODIGO)') }, { "cLookUp"  , "VEJPED" } } )
	endif

	oRetorno:AddField( { ;
		{ "cTitulo"  , "Cod Tipo Ped" } ,;
		{ "cTooltip" , "Cd Tipo Ped" } ,;
		{ "cIdField" , "CDTIPPED" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VEJ_CODIGO","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , "Tabela" } ,;
		{ "cTooltip" , "Tabela" } ,;
		{ "cIdField" , "CNOMTAB" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange", .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , "RecNo" } ,;
		{ "cTooltip" , "RecNo" } ,;
		{ "cIdField" , "NRECTAB" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 15 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno


Static Function OA4850035_LoadFieldParSug(oModel)

	Local nX         := 0
	Local cFJClassif := ""

	Local oStruct := oModel:GetStruct()
	Local aFields := oStruct:GetFields()

	Local nPARFILIAL  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARFILIAL"  } )
	Local nPARCODSUG  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARCODSUG"  } )
	Local nPARDATREF  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARDATREF"  } )
	Local nVS1NUMORC  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VS1NUMORC"  } )
	Local nVO1NUMOSV  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VO1NUMOSV"  } )
	Local nPARDIASSUG := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARDIASSUG" } )
	Local nPARCUSUNIT := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARCUSUNIT" } )
	Local nPARTIPPRC  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARTIPPRC"  } )
	Local nPARIMPORT  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARIMPORT"  } )
	Local nPARCLASSIF := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARCLASSIF" } )
	Local nPARANO     := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARANO"     } )
	Local nPARMES     := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "PARMES"     } )

	Local aRetorno := {}

	Pergunte("MTA297M",.f.)
	
	If Alltrim(MV_PAR04) == "*"
		cFJClassif := "AA/AB/AC/BA/BB/BC/CA/CB/CC/"
	Else
		For nX:=1 to Len(AllTrim(MV_PAR04)) Step 3
			cFJClassif += Upper(SubStr(MV_PAR04,nX,2))+"/"
		Next
	EndIf

	aRetorno := Array(Len(aFields))

	aRetorno[ nPARFILIAL  ] := ""
	aRetorno[ nPARCODSUG  ] := ""

	If IsInCallStack("OFIXA120") .or. IsInCallStack("OFIOM020")
		aRetorno[ nVS1NUMORC  ] := ""
		aRetorno[ nVO1NUMOSV  ] := VO1->VO1_NUMOSV
	Else
		aRetorno[ nVS1NUMORC  ] := VS1->VS1_NUMORC
		aRetorno[ nVO1NUMOSV  ] := ""
	EndIf

	aRetorno[ nPARDATREF  ] := dDataBase
	aRetorno[ nPARDIASSUG ] := 1
	aRetorno[ nPARCUSUNIT ] := Str(MV_PAR02,1)
	aRetorno[ nPARTIPPRC  ] := Str(MV_PAR03,1)
	aRetorno[ nPARIMPORT  ] := Str(MV_PAR05,1)
	aRetorno[ nPARCLASSIF ] := cFJClassif
	aRetorno[ nPARANO     ] := Year2Str(dDataBase)
	aRetorno[ nPARMES     ] := Month2Str(dDataBase)

Return aRetorno


Static Function OA4850045_LoadFieldIteSug(oModelIte)

	Local ni      := 0
	Local oStruct := oModelIte:GetStruct()
	Local aFields := oStruct:GetFields()

	Local nSDFFILIAL := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "SDFFILIAL" } )
	Local nSDFCODIGO := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "SDFCODIGO" } )
	Local nVB5SEQITE := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5SEQITE" } )
	Local nVB5GRUTIE := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5GRUITE" } )
	Local nVB5CODITE := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5CODITE" } )
	Local nVB5CODPRO := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5CODPRO" } )
	Local nVB5DESPRO := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5DESPRO" } )
	Local nVS3QTDITE := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VS3QTDITE" } )
	Local nVS3QTDEST := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VS3QTDEST" } )
	Local nVB5QTDSUG := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5QTDSUG" } )
	Local nFJTIPPED  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "FJTIPPED"  } )
	Local nCDTIPPED  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "CDTIPPED"  } )
	Local nVS3QTDRES := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VS3QTDRES" } )
	Local nCNOMTAB   := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "CNOMTAB"   } )
	Local nNRECTAB   := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "NRECTAB"   } )
	Local nVB5CODVSJ := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VB5CODVSJ" } )

	Local aRetorno := {}

	For ni := 1 to Len(aSugest)

		AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )

		nPos := Len(aRetorno)

		aRetorno[ nPos , 2 ][nSDFFILIAL  ] := ""
		aRetorno[ nPos , 2 ][nSDFCODIGO  ] := ""
		aRetorno[ nPos , 2 ][nVB5SEQITE  ] := aSugest[ ni, 13]
		aRetorno[ nPos , 2 ][nVB5GRUTIE  ] := aSugest[ ni, 2 ]
		aRetorno[ nPos , 2 ][nVB5CODITE  ] := aSugest[ ni, 3 ]
		aRetorno[ nPos , 2 ][nVB5CODPRO  ] := aSugest[ ni, 12]

		SB1->( DBSetOrder(7))
		SB1->( DbSeek( xFilial("SB1") + aSugest[ ni, 2] + aSugest[ ni, 12] ) )
		aRetorno[ nPos , 2 ][nVB5DESPRO  ] := SB1->B1_DESC

		aRetorno[ nPos , 2 ][nVS3QTDITE  ] := aSugest[ ni, 14]
		aRetorno[ nPos , 2 ][nVS3QTDEST  ] := aSugest[ ni, 8 ]
		aRetorno[ nPos , 2 ][nVB5QTDSUG  ] := aSugest[ ni, 5 ]
		
		if nFJTIPPED > 0
			aRetorno[ nPos , 2 ][nFJTIPPED   ] := Space(GetSX3Cache("FJ_TIPPED","X3_TAMANHO"))
		endif
		
		aRetorno[ nPos , 2 ][nCDTIPPED   ] := Space(GetSX3Cache("VEJ_CODIGO","X3_TAMANHO"))
		
		aRetorno[ nPos , 2 ][nVS3QTDRES  ] := aSugest[ ni, 15 ]

		aRetorno[ nPos , 2 ][nCNOMTAB    ] := ""
		aRetorno[ nPos , 2 ][nNRECTAB    ] := 0
		aRetorno[ nPos , 2 ][nVB5CODVSJ  ] := ""

		If Len(aSugest[ni]) > 26
			aRetorno[ nPos , 2 ][nCNOMTAB    ] := If(aSugest[ ni, 26 ] == Nil, "", aSugest[ ni, 26 ])
			aRetorno[ nPos , 2 ][nNRECTAB    ] := If(aSugest[ ni, 27 ] == Nil, 0 , aSugest[ ni, 27 ])

			aRetorno[ nPos , 2 ][nVB5CODVSJ  ] := If(aSugest[ ni, 28 ] == Nil, "", aSugest[ ni, 28 ])
		EndIf

	Next

Return aRetorno


Function OA4850065_LoadFieldCabSug(oModelSug)

Return {}


Function OA4850055_ValidTipoPedido(cCdTpPed)

	Local oModel	 := FWModelActive()

	Default cCdTpPed := ""
	
	if SFJ->(FieldPos("FJ_TIPPED")) > 0
		cCdTpPed := OA4850105_CodigoTipoPedido( FwFldGet("FJTIPPED"), VEJ->VEJ_TIPPED )
	endif

	If Empty(cCdTpPed)
		Return .f.
	EndIf

	oModIte := oModel:GetModel('MODSDF')
	oModSug := oModel:GetModel("MODSFJ")

	cCodAlt := oModIte:GetValue('CDTIPPED')

	nBkpLn := oModIte:GetLine()

	lSeek := oModIte:SeekLine({;
								{ "CDTIPPED" , cCdTpPed };
							})

	If lSeek

		cCodigo := oModIte:GetValue('SDFCODIGO')

	Else

		lSeekCab := oModSug:SeekLine({;
							{ "CODTIPPED" , cCdTpPed };
						},.t.)

		If lSeekCab
			// Restaura a linha do numero da sugestão caso a mesma tenha sido deletada anteriormente
			If oModSug:IsDeleted()
				oModSug:SetNoDeleteLine( .F. )
				oModSug:UnDeleteLine()
				oModSug:SetNoDeleteLine( .T. )
			EndIf

			cCodigo := oModSug:GetValue("SFJCODSUG")

		Else
			cCodigo := OA4840025_NumeroSugestaoCompra(cCdTpPed, @lNovaSug)

			oModSug:SetNoInsertLine(.f.)
			oModSug:SetNoUpdateLine(.f.)
			oModSug:AddLine()

			oModSug:SetValue("SFJFILIAL" , xFilial("SFJ") )
			oModSug:SetValue("SFJCODSUG" , cCodigo )
			oModSug:SetValue("NOVSUGEST" , If(lNovaSug,'S','N') )
			if SFJ->(FieldPos("FJ_TIPPED")) > 0
				oModSug:SetValue("SFJTIPPED" , oModIte:GetValue("FJTIPPED") )
			endif
			oModSug:SetValue("CODTIPPED" , cCdTpPed)

			oModSug:SetNoInsertLine(.T.)
			oModSug:SetNoUpdateLine(.T.)
		EndIf

		If oModSug:Length() > 1
			oModSug:GoLine(1)
		EndIf

	EndIf

	oModIte:GoLine(nBkpLn)

	oModIte:SetValue("SDFFILIAL", xFilial("SDF"))
	oModIte:SetValue('SDFCODIGO', cCodigo )
	oModIte:SetValue('CDTIPPED' , cCdTpPed)

	If !Empty(cCodAlt) // Deleta a linha do numero da sugestão quando não nenhum item vinculado a ele

		lSeekIte := oModIte:SeekLine({;
									{ "CDTIPPED" , cCodAlt };
								})

		If !lSeekIte

			lSeekCab := oModSug:SeekLine({;
								{ "CODTIPPED" , cCodAlt };
							})

			If lSeekCab
				If !oModSug:IsDeleted()
					oModSug:SetNoDeleteLine( .F. )
					oModSug:DeleteLine()
					oModSug:SetNoDeleteLine( .T. )
					oModSug:GoLine(1)
				EndIf
			EndIf

		EndIf

	EndIf

	oModIte:GoLine(nBkpLn)

Return .t.



Static Function OA4850175_GravaSugestao()

	Local oModel	:= FWModelActive()

	Local nx        := 0
	Local nI        := 0

	oModPar := oModel:GetModel('MODPARAM')
	oModSug := oModel:GetModel('MODSFJ'  )
	oModIte := oModel:GetModel('MODSDF'  )
	
	VEJ->( DbSetOrder(2) )
	VEJ->( DbSeek( xFilial("VEJ") + oModSug:GetValue('CODTIPPED') ) )

	For nI := 1 to oModSug:Length()

		oModSug:GoLine(nI)

		If !oModSug:IsDeleted()
			If oModSug:GetValue("NOVSUGEST") == "S"

				OA4850125_GeraSFJSugCompra( oModSug:GetValue("SFJFILIAL"),;
											oModSug:GetValue("SFJCODSUG"),;
											IIf(SFJ->(FieldPos("FJ_TIPPED")) > 0, oModSug:GetValue("SFJTIPPED"),""),;
											oModPar:GetValue('PARDATREF'),;
											oModPar:GetValue('PARDIASSUG'),;
											oModPar:GetValue('PARCUSUNIT'),;
											oModPar:GetValue('PARTIPPRC'),;
											oModPar:GetValue('PARIMPORT'),;
											oModPar:GetValue('PARCLASSIF'),;
											oModPar:GetValue('PARANO'),;
											oModPar:GetValue('PARMES') )

			EndIf

		EndIf

	Next

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SDF")
	DbSetOrder(1)

	for nX := 1 to oModIte:Length()

		oModIte:GoLine(nX)
		If !oModIte:IsDeleted()

			OA4850135_GeraSDFSugCompra( oModIte:GetValue("SDFCODIGO"),;
										oModIte:GetValue("VB5CODPRO"),;
										oModIte:GetValue("SDFFILIAL"),;
										oModIte:GetValue("VB5QTDSUG"),;
										oModPar:GetValue("PARTIPPRC") )

			xAutoInc := {}
			aAdd( xAutoInc,{"VB5_FILIAL", xFilial("VB5") , Nil } )
			
			If Empty(oModPar:GetValue('VS1NUMORC'))
				aAdd( xAutoInc,{"VB5_FILOSV", xFilial("VB5") , Nil } )
			Else
				aAdd( xAutoInc,{"VB5_FILORC", xFilial("VB5") , Nil } )
			EndIf

			aAdd( xAutoInc,{"VB5_ORIGEM", cOrigem , Nil } )
			aAdd( xAutoInc,{"VB5_NUMORC", oModPar:GetValue('VS1NUMORC') , Nil } )
			aAdd( xAutoInc,{"VB5_NUMOSV", oModPar:GetValue('VO1NUMOSV') , Nil } )
			aAdd( xAutoInc,{"VB5_SEQITE", oModIte:GetValue('VB5SEQITE') , Nil } )
			aAdd( xAutoInc,{"VB5_GRUITE", oModIte:GetValue('VB5GRUITE') , Nil } )
			aAdd( xAutoInc,{"VB5_CODITE", oModIte:GetValue('VB5CODITE') , Nil } )
			aAdd( xAutoInc,{"VB5_COD"   , oModIte:GetValue('VB5CODPRO') , Nil } )
			aAdd( xAutoInc,{"VB5_QTDSUG", oModIte:GetValue('VB5QTDSUG') , Nil } )
			aAdd( xAutoInc,{"VB5_QTDAGU", oModIte:GetValue('VB5QTDSUG') , Nil } )
			aAdd( xAutoInc,{"VB5_CODVEJ", oModIte:GetValue('CDTIPPED')  , Nil } )
			aAdd( xAutoInc,{"VB5_CODSFJ", oModIte:GetValue('SDFCODIGO') , Nil } )
			aAdd( xAutoInc,{"VB5_CODVSJ", oModIte:GetValue('VB5CODVSJ') , Nil } )

			oModelVB5 := FWLoadModel( 'OFIA484' )
			FWMVCRotAuto(oModelVB5,"VB5",3,{{"VB5MASTER",xAutoInc}})

			If lMsErroAuto
				MostraErro()
				Return .f.
			EndIf

			If !Empty(oModIte:GetValue('CNOMTAB'))
				DbSelectArea(oModIte:GetValue('CNOMTAB'))
				DbGoTo(oModIte:GetValue('NRECTAB'))

				RecLock(oModIte:GetValue('CNOMTAB'),.f.)
					If oModIte:GetValue('CNOMTAB') == "VSJ"
						VSJ->VSJ_QTDAGU := oModIte:GetValue('VB5QTDSUG')
					EndIf
				MsUnLock()
			EndIf
		
		EndIf

	Next

Return .t.


Function OA4850085_ValorTotalPecaSugestao(cParPrc)

	Local nValRet := 0

	If cParPrc == "1"
		If SB1->B1_UPRC > 0
			If SDF->DF_QTDINF > 0
				nValRet  := (SDF->DF_QTDINF*SB1->B1_UPRC)
			Else
				nValRet  := (SDF->DF_QTDSUG*SB1->B1_UPRC)
			EndIf
		Else
			SB2->(DbSetOrder(1))
			SB2->(Dbseek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
			If SDF->DF_QTDINF > 0
				nValRet  := (SDF->DF_QTDINF*SB2->B2_CM1)
			Else
				nValRet  := (SDF->DF_QTDSUG*SB2->B2_CM1)
			EndIf
		Endif
	ElseIF cParPrc == "2"
		SB5->(Dbseek(xFilial("SB5")+SB1->B1_COD))
		If SDF->DF_QTDINF > 0
			nValRet  := (SDF->DF_QTDINF*SB5->B5_PRV2)
		Else
			nValRet  := (SDF->DF_QTDSUG*SB5->B5_PRV2)
		EndIf
	Else
		If SDF->DF_QTDINF > 0
			nValRet  := (SDF->DF_QTDINF*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
		Else
			nValRet  := (SDF->DF_QTDSUG*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
		EndIf
		
	EndIF

	If nValRet < 0.01
		nValRet := 0.01
	Endif

Return nValRet


Function OA4850095_ConsumoPecaSugestao( cAno, cMes, cCodProd )

	cQuery := "SELECT SBL.BL_DEMANDA "
	cQuery += "FROM " + RetSqlName("SBL") + " SBL "
	cQuery += "WHERE SBL.BL_FILIAL = '" + xFilial("SBL") + "' "
	cQuery += 	"AND SBL.BL_PRODUTO = '" + cCodProd + "' "
	cQuery += 	"AND SBL.BL_ANO = '" + cAno + "' "
	cQuery += 	"AND SBL.BL_MES = '" + cMes + "' "
	cQuery += 	"AND SBL.D_E_L_E_T_ = ' ' "

Return FM_SQL(cQuery)


Function OA4850105_CodigoTipoPedido( cTpPdDg, cTpVEJ )

	Local cRetorno := ""

	If cTpPdDg <> cTpVEJ
		cQuery := "SELECT VEJ.VEJ_CODIGO "
		cQuery += "FROM " + RetSqlName("VEJ") + " VEJ "
		cQuery += "WHERE VEJ.VEJ_FILIAL = '" + xFilial("VEJ") + "' "
		cQuery += 	"AND VEJ.VEJ_TIPPED = '" + cTpPdDg + "' "
		cQuery += 	"AND VEJ.D_E_L_E_T_ = ' ' "

		cRetorno := FM_SQL(cQuery)
	Else
		cRetorno := VEJ->VEJ_CODIGO
	EndIf

Return cRetorno


Function OA4850115_ValidaDados()

	Local lRetorno := .t.
	Local oModel   := FWModelActive()
	Local lSeekIte := .f.
	Local cMsgErro := ""

	oModIte := oModel:GetModel('MODSDF'  )

	lSeekIte := oModIte:SeekLine({;
									{ "CDTIPPED" , Space(GetSX3Cache("VEJ_CODIGO","X3_TAMANHO")) };
								})
	If lSeekIte
		cMsgErro += STR0004 + CHR(13) + CHR(10) //"Existem itens que não tem o tipo de pedido preenchido"
	EndIf

	lSeekIte := oModIte:SeekLine({;
									{ "VB5GRUITE" , Space(GetSX3Cache("VB5_GRUITE","X3_TAMANHO")) };
								})
	If lSeekIte
		cMsgErro += STR0005 + CHR(13) + CHR(10) //"Existem itens que não tem o grupo de item preenchido"
	EndIf

	lSeekIte := oModIte:SeekLine({;
									{ "VB5CODITE" , Space(GetSX3Cache("VB5_CODITE","X3_TAMANHO")) };
								})
	If lSeekIte
		cMsgErro += STR0006 + CHR(13) + CHR(10) //"Existem itens que não tem o código de item preenchido"
	EndIf

	lSeekIte := oModIte:SeekLine({;
									{ "VB5CODPRO" , Space(GetSX3Cache("VB5_COD","X3_TAMANHO")) };
								})
	If lSeekIte
		cMsgErro += STR0007 + CHR(13) + CHR(10) //"Existem itens que não tem o código de produto preenchido"
	EndIf

	lSeekIte := oModIte:SeekLine({;
									{ "VB5QTDSUG" , 0 };
								})
	If lSeekIte
		cMsgErro += STR0008 + CHR(13) + CHR(10) //"Existem itens que não tem a quantidade preenchida"
	EndIf

	If !Empty(cMsgErro)
		Help("",1,"VALIDITEM",,cMsgErro,1,0)
		Return .f.
	EndIf

Return lRetorno


Function OA4850125_GeraSFJSugCompra( cFilSug, cCodSug, cTipPed, dDatRef, nDiaSug, cCusUnit, cTipPrc, cImport, cClassif, cAno, cMes)

	RecLock("SFJ",.T.)
		SFJ->FJ_FILIAL  := cFilSug
		SFJ->FJ_CODIGO  := cCodSug
		SFJ->FJ_FORPED  := cTipPed
		If SFJ->(FieldPos("FJ_TIPPED")) > 0
			SFJ->FJ_TIPPED  := cTipPed
		Endif	
		SFJ->FJ_DATREF  := dDatRef
		SFJ->FJ_DIASSUG := nDiaSug
		SFJ->FJ_CUSUNIT := cCusUnit
		SFJ->FJ_TIPPRC  := cTipPrc
		SFJ->FJ_IMPORT  := cImport
		SFJ->FJ_CLASSIF := cClassif
		SFJ->FJ_ANO     := cAno
		SFJ->FJ_MES     := cMes
	MsUnlock()

Return


Function OA4850135_GeraSDFSugCompra( cCodSug, cCodPro, cFilSug, nQtdSug, cTipPrc )

	Local nI := 0

	DbSelectArea("SDF")
	DbSeek( xFilial("SDF") + cCodSug + cCodPro )

	RecLock("SDF",!Found())

		SDF->DF_FILIAL  := cFilSug
		SDF->DF_CODIGO  := cCodSug
		SDF->DF_FLAG    := "A"
		SDF->DF_PRODUTO := cCodPro
		SDF->DF_QTDSUG  += nQtdSug

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + cCodPro )

		SDF->DF_VLRTOT := OA4850085_ValorTotalPecaSugestao( cTipPrc )
		SDF->DF_QTDINF := SDF->DF_QTDSUG

		IF SB1->B1_QE > 0 .and. FindFunction('FGX_CalcMultiploEmbalagem')
			SDF->DF_QTDINF := FGX_CalcMultiploEmbalagem(SDF->DF_QTDSUG, SB1->B1_QE)
		EndIF

		For nI := 1 to 12

			dDtDeman := MonthSub(dDataBase,nI)
			nDemanda := OA4850095_ConsumoPecaSugestao( Right(cValToChar(Year( dDtDeman )),2) , Month2Str( dDtDeman ) , cCodPro )

			&("SDF->DF_D"+StrZero(nI,2)) := nDemanda

		Next

		SDF->DF_M03     := (SDF->DF_D01+SDF->DF_D02+SDF->DF_D03)/3
		SDF->DF_M12     := (SDF->DF_D01+SDF->DF_D02+SDF->DF_D03+;
							SDF->DF_D04+SDF->DF_D05+SDF->DF_D06+;
							SDF->DF_D07+SDF->DF_D08+SDF->DF_D09+;
							SDF->DF_D10+SDF->DF_D11+SDF->DF_D12)/12

		If SB1->B1_QE == 0
			SDF->DF_QE      := 1
		Else
			SDF->DF_QE      := SB1->B1_QE
		Endif

	MsUnlock()

Return


Function OA4850145_GatilhoCodigoProduto()

	Local oModel := FWModelActive()
	Local oModItem := oModel:GetModel('MODSDF')
	Local lRet	:= .F.

	If ReadVar() == "M->VB5CODITE"
		If FG_POSSB1('FwFldGet("VB5CODITE")','SB1->B1_CODITE','FwFldGet("VB5GRUITE")')
			lRet := .T.
			oModItem:LoadValue("VB5CODITE", Left(Alltrim(SB1->B1_CODITE), GetSX3Cache("VB5_CODITE","X3_TAMANHO"))) // Necessário carregar para validar o grupo e código antes do SetValue
			oModItem:SetValue("VB5GRUITE", SB1->B1_GRUPO)
			oModItem:SetValue("VB5CODITE", Left(Alltrim(SB1->B1_CODITE), GetSX3Cache("VB5_CODITE","X3_TAMANHO")))
			oModItem:SetValue("VB5DESPRO", SB1->B1_DESC)
			oModItem:LoadValue("VB5CODPRO", SB1->B1_COD)
		Endif
	Endif

	If ReadVar() == "M->VB5GRUITE"
		SB1->(DBSetOrder(7))
		If SB1->(DBSeek(xFilial("SB1") + oModItem:GetValue("VB5GRUITE") + oModItem:GetValue("VB5CODITE"))) .or. Empty(oModItem:GetValue("VB5CODITE"))
			lRet := .T.
		Endif
	Endif

Return lRet
