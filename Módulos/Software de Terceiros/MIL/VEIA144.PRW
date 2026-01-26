#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA144.CH'

Static oInfoNota
Static oMBonusLib
Static oMArqRetor
Static oMCpoTotal

Function VEIA144()

	Private nValBon := 0 // Utilizado na consulta padrao de modelos 
	Private nValRet := 0
	Private M->C5_ESTPRES := Space(GetSX3Cache("C5_ESTPRES","X3_TAMANHO"))

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0001 ) //"Geração nota fiscal de bônus"
	oExecView:setSource("VEIA144")
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return


Static Function ModelDef()

	Local oModel 

	Local oStruInfNf
	Local oStruBonLib
	Local oStruCpoTot
	Local oStruArqRet

	Local bLoadInfNf := {|oModel| VA1440115_GetInformacaoNotaFiscal(oModel)}
	Local bLoadBonus := {|| VA1440135_GetBonusLiberados()}
	Local bLoadRetor := {|| VA1440145_GetArquivosRetornados()}

	If oInfoNota == NIL
		oInfoNota  := VA1440015_InformacaoNotaFiscal()
		oMBonusLib := VA1440035_Bonus()
		oMArqRetor := VA1440095_ArquivoRetorno()
		oMCpoTotal := VA1440085_BarraTotalizadora()
	EndIf

	oStruInfNf  := oInfoNota:GetModel()
	oStruBonLib := oMBonusLib:GetModel()
	oStruCpoTot := oMCpoTotal:GetModel()
	oStruArqRet := oMArqRetor:GetModel()

	aAuxTrigger := FwStruTrigger("PARCODMAR","PARCODMAR","cFilCodMar := FWFldGet('PARCODMAR')",.F.,"")
	oStruInfNf:AddTrigger(aAuxTrigger[1],aAuxTrigger[2],aAuxTrigger[3],aAuxTrigger[4])

	oModel := MPFormModel():New( 'VEIA144', /* bPre */, /*bPost*/ , { || .t. } /* bCommit */ , { || .T. }/* bCancel */ )
	oModel:AddFields('INFORMACAONF', /* cOwner */ , oStruInfNf, /* <bPre> */ , /* <bPost> */ , bLoadInfNf /* <bLoad> */ )
	oModel:AddFields('CAMPOSTOTAL', 'INFORMACAONF' , oStruCpoTot , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )

	oModel:AddGrid('BONUSLIBERADO' ,'INFORMACAONF',oStruBonLib, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadBonus/* <bLoad> */ )
	oModel:AddGrid('ARQUIVORETORNO','INFORMACAONF',oStruArqRet, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadRetor /* <bLoad> */ )

	oModel:SetDescription( STR0001 ) // 'Geração de nota fiscal de bonus'
	
	oModel:GetModel('INFORMACAONF'  ):SetDescription( STR0002 )	// 'Informacoes da Nota Fiscal'
	oModel:GetModel('BONUSLIBERADO' ):SetDescription( STR0003 )	// 'Lista de Bonus Liberado'
	oModel:GetModel('ARQUIVORETORNO'):SetDescription( STR0004 )	// 'Lista de Arquivo de Retorno'
	oModel:GetModel('CAMPOSTOTAL'   ):SetDescription( STR0005 )	// 'Campos de totais'

	oModel:GetModel('INFORMACAONF'  ):SetOnlyQuery( .T. )
	oModel:GetModel('BONUSLIBERADO' ):SetOnlyQuery( .T. )
	oModel:GetModel('ARQUIVORETORNO'):SetOnlyQuery( .T. )
	
	oModel:GetModel('BONUSLIBERADO' ):SetOptional( .T. )
	oModel:GetModel('ARQUIVORETORNO'):SetOptional( .T. )

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("VEIA144EVF", /*cOwner*/, VEIA144EVF():New("VEIA144"))
	
Return oModel

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'VEIA144' )
	Local oView 	:= Nil

	Local oStruInfNf  := oInfoNota:GetView()
	Local oStruBonLib := oMBonusLib:GetView()
	Local oStruCpoTot := oMCpoTotal:GetView()
	Local oStruArqRet := oMArqRetor:GetView()

	If VQ4->(FieldPos("VQ4_CREDNT")) == 0
		oStruInfNf:RemoveField( "CPOTPGER" )
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FIELDS_INFORMACAONF' , oStruInfNf  , 'INFORMACAONF')
	oView:AddField('GRID_MODELO_TOTALIZA', oStruCpoTot , 'CAMPOSTOTAL')
	
	oView:AddGrid('GRID_BONUS_LIBERADO' , oStruBonLib , 'BONUSLIBERADO')
	oView:AddGrid('GRID_ARQUIVO_RETORNO', oStruArqRet , 'ARQUIVORETORNO')

	oView:EnableTitleView('FIELDS_INFORMACAONF', STR0002 ) //'Informacoes da Nota Fiscal'
	
	oView:EnableTitleView('GRID_BONUS_LIBERADO', STR0006 ) //"Bônus Liberados"
	oView:SetNoInsertLine('GRID_BONUS_LIBERADO')
	oView:SetNoDeleteLine('GRID_BONUS_LIBERADO')

	oView:EnableTitleView('GRID_ARQUIVO_RETORNO', STR0007 ) //'Arquivos de Retorno'
	oView:SetNoInsertLine('GRID_ARQUIVO_RETORNO')
	oView:SetNoDeleteLine('GRID_ARQUIVO_RETORNO')

	oView:CreateHorizontalBox('TELA_INFORMNF',30)
	oView:CreateHorizontalBox('TELA_BONUSLIB',30)
	oView:CreateHorizontalBox('TELA_RETURNID',30)
	oView:CreateHorizontalBox('TELA_TOTALIZA',10)

	oView:SetOwnerView('FIELDS_INFORMACAONF' ,'TELA_INFORMNF')
	oView:SetOwnerView('GRID_BONUS_LIBERADO' ,'TELA_BONUSLIB')
	oView:SetOwnerView('GRID_ARQUIVO_RETORNO','TELA_RETURNID')
	oView:SetOwnerView('GRID_MODELO_TOTALIZA','TELA_TOTALIZA')

	oView:SetViewProperty("GRID_BONUS_LIBERADO", "GRIDSEEK", {.T.})

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

Static Function VA1440015_InformacaoNotaFiscal()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField({;
					{ 'cIdField'     , 'CPOTPGER' } ,;
					{ 'cTitulo'      , STR0020 } ,; // "Tipo de Geração"
					{ 'cTooltip'     , STR0020 } ,; // "Tipo de Geração"
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '1='+STR0021 , '2='+STR0022 } } ,; // NF + Título / Título
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("12")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } ;
	})

	oRetorno:AddFieldDictionary( "SC5" , "C5_CLIENTE" , { {"cIdField" , "C5CLIENTE" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_LOJACLI" , { {"cIdField" , "C5LOJACLI" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_VEND1"   , { {"cIdField" , "C5VEND1"   } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_CONDPAG" , { {"cIdField" , "C5CONDPAG" } } )

	If cPaisLoc == "MEX"
		oRetorno:AddFieldDictionary( "SC5" , "C5_USOCFDI" , { {"cIdField" , "C5USOCFDI" },;
			{ "bValid", FWBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .or. ValidF3I("S013", M->C5USOCFDI,1,3)') },;
			{ "bWhen" , { || FWFldGet('CPOTPGER')=='1' } }} )
		oRetorno:AddFieldDictionary( "SC5" , "C5_TPDOC"   , { {"cIdField" , "C5TPDOC"   },;
			{ "bValid", FWBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .or. ValidF3I("S005", M->C5TPDOC,1,2)'  ) },;
			{ "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )
	EndIf

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0008 } ,; //"Servico - Produto"
		{ "cTooltip" , STR0008 } ,;
		{ "cIdField" , "CPOCODPRD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 70 } ,;
		{ "cLookUp" , "SB1" } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. FG_Seek('SB1','CPOCODPRD',1)") } ,;
		{ "bInit" , { || Space(70) } } ,;
		{ "lVirtual" , .t. } ,;
		{ "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } ;
	})

		oRetorno:AddField( { ;
		{ "cTitulo"  , STR0009 } ,; //"Valor"
		{ "cTooltip" , STR0009 } ,;
		{ "cIdField" , "PARVALOR" } ,;
		{ "cTipo"    , "N" } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "bInit" , { || 0 } } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddFieldDictionary( "SC5" , "C5_NATUREZ" , { {"cIdField" , "C5NATUREZ" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_BANCO"   , { {"cIdField" , "C5BANCO"   } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_TIPOCLI" , { {"cIdField" , "C5TIPOCLI" }, { "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )

	If SC5->(FieldPos("C5_INDPRES")) > 0
		oRetorno:AddFieldDictionary( "SC5" , "C5_INDPRES" , { {"cIdField" , "C5INDPRES" }, { "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )
	EndIf

	oRetorno:AddFieldDictionary( "SC5" , "C5_MENPAD"  , { {"cIdField" , "C5MENPAD"  }, { "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MENNOTA" , { {"cIdField" , "C5MENNOTA" }, { "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_ESTPRES" , { {"cIdField" , "C5ESTPRES" } , { "bValid", FWBuildFeature(STRUCT_FEATURE_VALID,"VA1440155_ValidaEstadoPrestacao()") } } )

	If SC5->(FieldPos("C5_MUNPRES")) > 0 // Campo existente somente no Brasil e no Mexico
		oRetorno:AddFieldDictionary( "SC5" , "C5_MUNPRES" , { {"cIdField" , "C5MUNPRES" } } )
	EndIf
	
	If SC5->(FieldPos("C5_DESCMUN")) > 0 //Campo existente somente no Brasil
		oRetorno:AddFieldDictionary( "SC5" , "C5_DESCMUN" , { {"cIdField" , "C5DESCMUN" }, { "bWhen" , { || .f. } } } )
	EndIf

	If SC6->(FieldPos("C6_NATREN")) > 0
		oRetorno:AddFieldDictionary( "SC6" , "C6_NATREN"  , { {"cIdField" , "C6NATREN"  }, { "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } } )
	EndIf

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0010 } ,; //"Observacao NF"
		{ "cTooltip" , STR0010 } ,;
		{ "cIdField" , "PAROBSNF" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 250 } ,;
		{ "bWhen" , { || FWFldGet('CPOTPGER')=='1' } } ;
	})

Return oRetorno

Static Function VA1440035_Bonus()

	Local oRetorno := OFDMSStruct():New()
	Local nTamCpoNF := 0

	oRetorno:AddSelect('','CPOSELBON', , .t.)

	oRetorno:AddFieldDictionary( "VQ1" , "VQ1_CODBON" , { {"cIdField" , "VQ1CODBON" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ1" , "VQ1_VLRTOT" , { {"cIdField" , "VQ1VLRTOT" } , { "lCanChange" , .t. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_NUMPED" , { {"cIdField" , "VQ0NUMPED" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_DATPED" , { {"cIdField" , "VQ0DATPED" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CHASSI" , { {"cIdField" , "VQ0CHASSI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CODMAR" , { {"cIdField" , "VQ0CODMAR" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_MODVEI" , { {"cIdField" , "VQ0MODVEI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CORVEI" , { {"cIdField" , "VQ0CORVEI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_FILATE" , { {"cIdField" , "VQ0FILATE" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_NUMATE" , { {"cIdField" , "VQ0NUMATE" } , { "lCanChange" , .f. } } )

	nTamCpoNF := 1
	nTamCpoNF += GetSX3Cache("VV0_NUMNFI","X3_TAMANHO")
	nTamCpoNF += GetSX3Cache("VV0_SERNFI","X3_TAMANHO")

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0011 } ,; //"NF e Serie"
		{ "cTooltip" , STR0011 } ,;
		{ "cIdField" , "VV0NUMNFI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0012 } ,; //"Recno VQ1"
		{ "cTooltip" , STR0012 } ,;
		{ "cIdField" , "RECNOVQ1" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 999999 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Static Function VA1440095_ArquivoRetorno()

	Local lVQ4CREDNT := VQ4->(FieldPos("VQ4_CREDNT")) > 0
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','CPOSELRET', , .t.)

	If lVQ4CREDNT
		oRetorno:AddFieldDictionary( "VQ4" , "VQ4_CREDNT" , { {"cIdField" , "VQ4CREDNT" } , { "lCanChange" , .f. } } )
	Else
		oRetorno:AddFieldDictionary( "VQ4" , "VQ4_RETUID" , { {"cIdField" , "VQ4RETUID" } , { "lCanChange" , .f. } } )
	EndIf
	oRetorno:AddFieldDictionary( "VQ4" , "VQ4_VLRTOT" , { {"cIdField" , "VQ4VLRTOT" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ4" , "VQ4_CIACGC" , { {"cIdField" , "VQ4CIACGC" } , { "lCanChange" , .f. } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0013 } ,; //"Referente as NF's"
		{ "cTooltip" , STR0013 } ,;
		{ "cIdField" , "REFNF" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 250 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})


Return oRetorno

Static Function VA1440085_BarraTotalizadora()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0014 } ,; //"Bonus selecionados"
		{ "cTooltip" , STR0014 } ,;
		{ "cIdField" , "CPOTOTBON" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0015 } ,; //"Retorno selecionado"
		{ "cTooltip" , STR0015 } ,;
		{ "cIdField" , "CPOTOTRET" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0016 } ,; //"Divergência"
		{ "cTooltip" , STR0016 } ,;
		{ "cIdField" , "CPOTOTDIV" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Static Function VA1440115_GetInformacaoNotaFiscal(oModel)

	Local aAuxFields := oModel:GetStruct():GetFields()
	Local aRetorno   := Array(Len(aAuxFields))
	Local cFilVQ1    := xFilial("VQ1")
	Local lC5INDPRES := SC5->(FieldPos("C5_INDPRES")) > 0
	Local lC5MUNPRES := SC5->(FieldPos("C5_MUNPRES")) > 0
	Local lC5DESCMUN := SC5->(FieldPos("C5_DESCMUN")) > 0
	Local lC6NATREN  := SC6->(FieldPos("C6_NATREN"))  > 0
	
	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"CPOTPGER")] := "1"

	cQuery := "SELECT SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_VEND1 , SF2.F2_COND , SD2.D2_COD "
	If cPaisLoc == "MEX"
		cQuery += ", SF2.F2_USOCFDI , SF2.F2_TPDOC "
	EndIf
	cQuery += " FROM " + RetSQLName("VQ1") + " VQ1 "
	cQuery += " JOIN " + RetSQLName("SF2") + " SF2 "
	cQuery += 		" ON  SF2.F2_FILIAL = VQ1.VQ1_FILNFI "
	cQuery += 		" AND SF2.F2_DOC = VQ1.VQ1_NUMNFI "
	cQuery += 		" AND SF2.F2_SERIE = VQ1.VQ1_SERNFI "
	cQuery += 		" AND SF2.D_E_L_E_T_=' ' "
	cQuery += " JOIN " + RetSQLName("SD2") + " SD2 "
	cQuery += 		" ON  SD2.D2_FILIAL = VQ1.VQ1_FILNFI "
	cQuery += 		" AND SD2.D2_DOC = VQ1.VQ1_NUMNFI "
	cQuery += 		" AND SD2.D2_SERIE = VQ1.VQ1_SERNFI "
	cQuery += 		" AND SD2.D_E_L_E_T_=' ' "
	cQuery += " WHERE VQ1.VQ1_FILIAL = '" + cFilVQ1 + "' "
	cQuery += 	" AND VQ1.VQ1_NUMNFI <> ' ' "
	cQuery += 	" AND VQ1.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY VQ1.VQ1_CODIGO DESC"

	TcQuery cQuery New Alias "TMPNF"

	If !TMPNF->( Eof() )
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5CLIENTE")] := TMPNF->F2_CLIENTE
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5LOJACLI")] := TMPNF->F2_LOJA
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5VEND1")]   := TMPNF->F2_VEND1
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5CONDPAG")] := TMPNF->F2_COND
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"CPOCODPRD")] := TMPNF->D2_COD
		If cPaisLoc == "MEX"
			aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5USOCFDI")] := TMPNF->F2_USOCFDI
			aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5TPDOC")]   := TMPNF->F2_TPDOC
		EndIf
	EndIf

	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"PARVALOR")]  := 0
	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5NATUREZ")] := space(TamSX3("C5_NATUREZ")[1])
	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5BANCO")]   := space(TamSX3("E1_PORTADO")[1])

	TMPNF->( DbCloseArea() )

	If !Empty(aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5CLIENTE")])
		SA1->(DbSetOrder(1))
		SA1->( DbSeek( xFilial("SA1") + aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5CLIENTE")] + aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5LOJACLI")]))
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5TIPOCLI")] := SA1->A1_TIPO
	EndIf

	If lC5INDPRES
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5INDPRES")] := "0"
	EndIf

	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5MENPAD")]  := space(GetSX3Cache("C5_MENPAD","X3_TAMANHO"))
	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5BANCO")]   := space(GetSX3Cache("C5_BANCO" ,"X3_TAMANHO"))
	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5ESTPRES")] := space(GetSX3Cache("C5_ESTPRES","X3_TAMANHO"))

	If lC5MUNPRES
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5MUNPRES")] := space(GetSX3Cache("C5_MUNPRES","X3_TAMANHO"))
	EndIf

	If lC5DESCMUN
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C5DESCMUN")] := space(GetSX3Cache("C5_DESCMUN","X3_TAMANHO"))
	endif

	If lC6NATREN
		aRetorno[VA1440165_PesquisaCampo(aAuxFields,"C6NATREN")] := space(GetSX3Cache("C6_NATREN","X3_TAMANHO"))
	EndIf

	aRetorno[VA1440165_PesquisaCampo(aAuxFields,"PAROBSNF")] := ""

Return aRetorno


Static Function VA1440135_GetBonusLiberados()

	Local aRetorno := {}

	Local cNamVQ1   := RetSQLName("VQ1")

	cQuery := "SELECT VQ1_CODBON , VQ1_VLRTOT , R_E_C_N_O_ RECVQ1, VQ1_CODIGO"
	cQuery += " FROM " + cNamVQ1 + " "
	cQuery += " WHERE VQ1_FILIAL = '" + xFilial("VQ1") + "' "
	//cQuery += 	" AND VQ1_CODIGO = '" + VQ0->VQ0_CODIGO + "' "
	cQuery += 	" AND VQ1_NUMNFI = ' ' "
	cQuery += 	" AND VQ1_STATUS = '2' "
	cQuery += 	" AND D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVQ1"

	While !TMPVQ1->( Eof() )

		VQ0->( DbSetOrder(1) )
		VQ0->( DbSeek( xFilial("VQ0") + TMPVQ1->VQ1_CODIGO ) )

		cNUMNFI := ""
		If !Empty( VQ0->VQ0_FILATE + VQ0->VQ0_NUMATE )
			DbSelectArea("VV0")
			DbSetOrder(1)
			If DbSeek( VQ0->VQ0_FILATE + VQ0->VQ0_NUMATE ) .and. !Empty( VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
				cNUMNFI := VV0->VV0_NUMNFI + "-" + FGX_UFSNF( VV0->VV0_SERNFI )
			EndIf
		EndIf

		aAdd(aRetorno,{ ;
				Len(aRetorno) + 1 ,;
				{ 	.f. ,;
					TMPVQ1->VQ1_CODBON ,;
					TMPVQ1->VQ1_VLRTOT ,;
					VQ0->VQ0_NUMPED ,;
					VQ0->VQ0_DATPED ,;
					VQ0->VQ0_CHASSI ,;
					VQ0->VQ0_CODMAR ,;
					VQ0->VQ0_MODVEI ,;
					VQ0->VQ0_CORVEI ,;
					VQ0->VQ0_FILATE ,;
					VQ0->VQ0_NUMATE ,;
					cNUMNFI ,;
					TMPVQ1->RECVQ1 ;
				};
		})
		TMPVQ1->( DbSkip() )

	EndDo

	TMPVQ1->( DbCloseArea() )

Return aRetorno



Static Function VA1440145_GetArquivosRetornados()

	Local aRetorno := {}
	Local cNamVQ1   := RetSQLName("VQ1")
	Local cFilVQ1  := xFilial("VQ1")
	
	Local cRetAux   := "INICIAL"
	Local cNFSAux   := ""

	Local lVQ4CREDNT := VQ4->(FieldPos("VQ4_CREDNT")) > 0
	

	cQuery := "SELECT " + If (lVQ4CREDNT, "VQ4.VQ4_CREDNT", "VQ4.VQ4_RETUID") + " AS VQ4_CREDNT , "
	cQuery += "VQ4.VQ4_VLRTOT , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI , VQ4.VQ4_CIACGC "
	cQuery += " FROM " + RetSQLName( "VQ4" ) + " VQ4 "
	cQuery += " WHERE VQ4.VQ4_FILIAL = '" + xFilial("VQ4") + "' "
	cQuery += 	" AND VQ4.VQ4_TIPREG = '2' "
	cQuery += 	" AND VQ4.VQ4_TIPNFI = '2' "
	cQuery += 	" AND NOT EXISTS ( "
	cQuery += 						" SELECT " + If (lVQ4CREDNT, "VQ1_CREDNT ", "VQ1_RETUID ")
	cQuery += 						" FROM " + cNamVQ1 + " "
	cQuery += 						" WHERE   VQ1_FILIAL = '" + cFilVQ1 + "' "
	cQuery += 							" AND " + If (lVQ4CREDNT, "VQ1_CREDNT = VQ4_CREDNT ", "VQ1_RETUID = VQ4_RETUID ") "
	cQuery += 							" AND D_E_L_E_T_ = ' ' "
	cQuery += 					" ) "
	cQuery += 	" AND VQ4.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + If (lVQ4CREDNT,"VQ4.VQ4_CREDNT","VQ4.VQ4_RETUID") + " , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI "

	TcQuery cQuery New Alias "TMPVQ4"

	While !TMPVQ4->( Eof() )

			If cRetAux <> TMPVQ4->VQ4_CREDNT
				cRetAux := TMPVQ4->VQ4_CREDNT
				aAdd( aRetorno , { ;
							Len(aRetorno) + 1 ,;
							{ 	.f. ,;
								cRetAux ,;
								TMPVQ4->VQ4_VLRTOT ,;
								TMPVQ4->VQ4_CIACGC ,;
								"" ;
							};
				})
			EndIf

			cNFSAux := Alltrim( TMPVQ4->VQ4_NUMNFI ) + "-" + FGX_UFSNF( TMPVQ4->VQ4_SERNFI )

			If( cNFSAux <> "-" ) .and. !( cNFSAux $ aRetorno[len(aRetorno),2,5] )
				aRetorno[len(aRetorno),2,5] += IIf(!Empty(aRetorno[len(aRetorno),2,5]),", ","")+cNFSAux
			EndIf

		TMPVQ4->( DbSkip() )

	EndDo

	TMPVQ4->( DbCloseArea() )

Return aRetorno


Function VA1440155_ValidaEstadoPrestacao()

	M->C5_ESTPRES := C5ESTPRES

Return .t.

/*/{Protheus.doc} VA1440165_PesquisaCampo()
Função para pesquisar o campo no vetor de estrutura de campos da model

@author Renato Vinicius
@since 06/01/2024
@version undefined
@type function
/*/

Static Function VA1440165_PesquisaCampo(aFields,cCpoPesq)

	Local nRetorno := 0

	Default aFields := {}

	If Len(aFields) > 0
		nRetorno := aScan(aFields,{|x| x[3] == cCpoPesq })
	EndIf

Return nRetorno
