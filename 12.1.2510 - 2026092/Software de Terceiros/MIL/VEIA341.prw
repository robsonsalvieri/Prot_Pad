#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA341.CH"

/*/{Protheus.doc} VEIA341

ARGENTINA - FATURAMENTO DIRETO - ENTRADAS

Opções do aRotina chamadas pelo VEIXA030
1=Fatura de Entrada
2=Remito de Entrada

@author Andre Luis Almeida
@since 10/06/2026
/*/
Function VEIA341(nOpcSelec)
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
Local lOkExec  := .f.
Local lVV0_STAFDI := ( VV0->(FieldPos("VV0_STAFDI")) > 0 )
Local nMoeda   := 0
Local nTxMoeda := 0
Local nRecSA2  := 0
Local cOpcSelec := IIf(nOpcSelec==1,"FAT","REM")
Local cTitTela := IIf(nOpcSelec==1,STR0001,STR0002) // Geração da Fatura de Entrada / Geração do Remito de Entrada
Local aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
Private oModel   := FWLoadModel("VEIA341")
Private oView    := FWLoadView("VEIA341")
Private cEspecie := IIf(nOpcSelec==1,"NF","RCN") // variavel utilizada no BO
Private oConf341 := VEIA341Config():New()
//
If VV9->VV9_STATUS <> "F"
	FMX_HELP("VA341ERR001",STR0003,STR0004) // Opção não disponivel / O Faturamento Direto deve estar com o status Finalizado.
	Return
EndIf
//
If lVV0_STAFDI .and. VXA030051_valida_Veiculos(VV9->VV9_FILIAL,VV9->VV9_NUMATE)
	VV0->(DbSetOrder(1))
	VV0->(DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE))
	If nOpcSelec == 1// 1=Fatura de Entrada
		If !Empty(VV0->VV0_STAFDI) .and. VV0->VV0_STAFDI <> "0"
			FMX_HELP("VA341ERR002",cTitTela+". "+STR0003,STR0005) // Opção não disponivel. / O Faturamento Direto não pode ter Faturas ou Remitos já gerados.
			Return
		EndIf
	Else // 2=Remito de Entada
		If VV0->VV0_STAFDI <> "1"
			FMX_HELP("VA341ERR003",cTitTela+". "+STR0003,STR0006) // Opção não disponivel. / O Faturamento Direto deve possuir apenas a Fatura de Entrada gerada.
			Return
		EndIf
	EndIf
	nRecSA2 := VA3410041_SA2( VV0->VV0_CLIFTD , VV0->VV0_LOJFTD )
	If nRecSA2 == 0
		FMX_HELP("VA341ERR004",STR0007+CHR(13)+CHR(10)+VV0->VV0_CLIFTD+" - "+VV0->VV0_LOJFTD,STR0008) // Fornecedor não encontrado para este cliente. / Favor relaciona-lo no Cadastro de Fornecedores.
		Return
	EndIf
	SA2->(DbGoTo(nRecSA2))
	//
	If nOpcSelec == 1// 1=Fatura de Entrada
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'F1_TRANSP' , MODEL_FIELD_OBRIGAT, .f.)
		oView:GetViewStruct( 'PARMASTER' ):RemoveField("F1_TRANSP")
	Else // 2=Remito de Entrada
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'D1_TES'  , MODEL_FIELD_TITULO , RetTitle('VVA_TESREM') )
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'D1_TES'  , MODEL_FIELD_VALID  , VA3410061_Valid('D1_TES',.t.,'(Existcpo("SF4",,1).and.MaAvalTes("E",M->D1_TES).and.VX0000145_ValidacaoTES("5",M->D1_TES))') )
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'F1_COND' , MODEL_FIELD_OBRIGAT, .f.)
		oView:GetViewStruct( 'PARMASTER' ):RemoveField("F1_COND")
	EndIf
	//
	nMoeda   := IIf(VV0->VV0_MOEDA>0,VV0->VV0_MOEDA,1)
	nTxMoeda := IIf(VV0->VV0_TXMOED>0,VV0->VV0_TXMOED,RecMoeda(dDataBase,nMoeda))
	//
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModelPar := oModel:GetModel("PARMASTER")
	oModelPar:SetValue("F1_FORNECE"     , SA2->A2_COD     )
	oModelPar:SetValue("F1_LOJA"        , SA2->A2_LOJA    )
	oModelPar:SetValue("A2_NOME"        , SA2->A2_NOME    )
	oModelPar:SetValue("F1_EST"         , SA2->A2_EST     )
	oModelPar:SetValue("F1_ESPECIE"     , cEspecie        )
	If nOpcSelec == 1 // 1=Fatura de Entrada
		oModelPar:SetValue("F1_DOC"     , VV0->VV0_NNFFDI )
		oModelPar:SetValue("F1_SERIE"   , VV0->VV0_SNFFDI )
		oModelPar:SetValue("F1_EMISSAO" , VV0->VV0_DATEMI )
	EndIf
	oModelPar:SetValue("F1_VALBRUT"     , VV0->VV0_VALTOT )
	oModelPar:SetValue("F1_MOEDA"       , nMoeda          )
	oModelPar:SetValue("F1_TXMOEDA"     , nTxMoeda        )
	// Buscar o ultimo SALVO
	oModelPar:SetValue("F1_COND"   ,oConf341:GetValue(cOpcSelec+"_F1_COND"   , space(GetSx3Cache("F1_COND"   ,"X3_TAMANHO"))) )
	oModelPar:SetValue("F1_TRANSP" ,oConf341:GetValue(cOpcSelec+"_F1_TRANSP" , space(GetSx3Cache("F1_TRANSP" ,"X3_TAMANHO"))) )
	oModelPar:SetValue("F1_PROVENT",oConf341:GetValue(cOpcSelec+"_F1_PROVENT", space(GetSx3Cache("F1_PROVENT","X3_TAMANHO"))) )
	oModelPar:SetValue("F1_NATUREZ",oConf341:GetValue(cOpcSelec+"_F1_NATUREZ", space(GetSx3Cache("F1_NATUREZ","X3_TAMANHO"))) )
	oModelPar:SetValue("D1_TES"    ,oConf341:GetValue(cOpcSelec+"_D1_TES"    , space(GetSx3Cache("D1_TES"    ,"X3_TAMANHO"))) )
	oModelPar:SetValue("D1_CC"     ,oConf341:GetValue(cOpcSelec+"_D1_CC"     , space(GetSx3Cache("D1_CC"     ,"X3_TAMANHO"))) )
	oModelPar:SetValue("D1_CONTA"  ,oConf341:GetValue(cOpcSelec+"_D1_CONTA"  , space(GetSx3Cache("D1_CONTA"  ,"X3_TAMANHO"))) )
	oModelPar:SetValue("D1_ITEMCTA",oConf341:GetValue(cOpcSelec+"_D1_ITEMCTA", space(GetSx3Cache("D1_ITEMCTA","X3_TAMANHO"))) )
	oModelPar:SetValue("D1_CLVL"   ,oConf341:GetValue(cOpcSelec+"_D1_CLVL"   , space(GetSx3Cache("D1_CLVL"   ,"X3_TAMANHO"))) )
	//
	CursorArrow()
	oExec341 := FWViewExec():New()
	oExec341:setModel(oModel)
	oExec341:setView(oView)
	oExec341:setTitle(cTitTela)
	oExec341:setOK( { || VA3410051_TudoOK(nOpcSelec) })
	oExec341:setCancel( { || .T. } )
	oExec341:setOperation(MODEL_OPERATION_UPDATE)
	oExec341:setReduction(10) // Redução de 10% da tela
	oExec341:SetButtons(aButtons)
	oExec341:openView(.f.)
	lOkExec := (oExec341:getButtonPress() == 0)
	oExec341:DeActivate()
	If lOkExec
		oProcess := MsNewProcess():New({|lEnd| VA3410021_Processa( nOpcSelec , @oProcess , @lEnd ) },cTitTela,"",.T.)
		oProcess:Activate()
	EndIf
EndIf
//
Return

Static Function ModelDef()
	Local oModel 
	Local oParametro := VA3410011_Campos_Parametros()
	Local oParamStru := oParametro:GetModel()
	oModel := MPFormModel():New( 'VEIA341', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oParamStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:SetDescription(STR0009) // Parametros
	oModel:GetModel('PARMASTER'):SetDescription(STR0009) // Parametros
	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIA341' )
	Local oView 	:= Nil
	Local oParametro := VA3410011_Campos_Parametros()
	Local oParamStru := oParametro:GetView()
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oParamStru , 'PARMASTER')
	oView:EnableTitleView('FORM_PARAM',STR0009) // Parametros
	oView:CreateHorizontalBox('TELA_PARAM',100) //,,.t.)
	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL
	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)
Return oView

/*/
{Protheus.doc} VA3410011_Campos_Parametros
Monta Campos da Grid de Parametros

@author Andre Luis Almeida
@since 10/06/2026
/*/
Static Function VA3410011_Campos_Parametros()
Local oRetorno := OFDMSStruct():New()
oRetorno:AddFieldDictionary( "SF1" , "F1_FORNECE" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_LOJA"    , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SA2" , "A2_NOME"    , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_EST"     , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_ESPECIE" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_DOC"     , { { 'bValid' , VA3410061_Valid('F1_DOC'    ,.t.,'') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_SERIE"   , { { 'bValid' , VA3410061_Valid('F1_SERIE'  ,.t.,'') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_VALBRUT" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_MOEDA"   , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_TXMOEDA" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_EMISSAO" , { { 'bValid' , VA3410061_Valid('F1_EMISSAO',.t.,'M->F1_EMISSAO<=dDataBase') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_COND"    , { { 'bValid' , VA3410061_Valid('F1_COND'   ,.t.,'ExistCpo("SE4",,1)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_TRANSP"  , { { 'bValid' , VA3410061_Valid('F1_TRANSP' ,.t.,'ExistCpo("SA4",,1)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .f. } } )
if cPaisLoc == "ARG"
	oRetorno:AddFieldDictionary( "SF1" , "F1_PROVENT" , { { 'bValid' , VA3410061_Valid('F1_PROVENT',.t.,'ExistCpo("SX5","12"+M->F1_PROVENT)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
	oRetorno:AddFieldDictionary( "SF1" , "F1_NATUREZ" , { { 'bValid' , VA3410061_Valid('F1_NATUREZ',.t.,'ExistCpo("SED",,1)') } , { 'lCanChange' , .t. } , { 'cLookUp' , "SED" } , { 'lObrigat' , .t. } } )
endif
oRetorno:AddFieldDictionary( "SD1" , "D1_TES"     , { { 'bValid' , VA3410061_Valid('D1_TES'    ,.t.,'(Existcpo("SF4",,1).and.MaAvalTes("E",M->D1_TES).and.VX0000145_ValidacaoTES("4",M->D1_TES))') } , { 'cTitulo' , RetTitle('VVA_CODTES') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CC"      , { { 'bValid' , VA3410061_Valid('D1_CC'     ,.t.,'ExistCpo("CTT",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CONTA"   , { { 'bValid' , VA3410061_Valid('D1_CONTA'  ,.t.,'ExistCpo("CT1",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_ITEMCTA" , { { 'bValid' , VA3410061_Valid('D1_ITEMCTA',.t.,'ExistCpo("CTD",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CLVL"    , { { 'bValid' , VA3410061_Valid('D1_CLVL'   ,.t.,'ExistCpo("CTH",,1)') } , { 'lCanChange' , .t. } } )
Return oRetorno

/*/
{Protheus.doc} VA3410021_Processa
Processa

@author Andre Luis Almeida
@since 12/06/2026
/*/
Static Function VA3410021_Processa( nOpcSelec , oProcess , lEnd )
Local lOkExec   := .f.
Local dDatEmi   := M->F1_EMISSAO
Local cNroDoc   := M->F1_DOC
Local cSerDoc   := M->F1_SERIE
Local cForDoc   := M->F1_FORNECE
Local cLojDoc   := M->F1_JOJA
Local nMoeda    := M->F1_MOEDA
Local nTxMoeda  := M->F1_TXMOEDA
Local cProcesso := IIf(nOpcSelec==1,STR0011,STR0012) // Gerando Fatura de Entrada / Gerando Remito de Entrada
Local nRecVV0   := VV0->(RecNo())
//
oProcess:SetRegua1(0)
oProcess:IncRegua1(STR0010) // Processando...
oProcess:SetRegua2(3)
Begin Transaction
	oProcess:IncRegua2(cProcesso)
	oProcess:IncRegua2(cProcesso)
	lOkExec := VA3410031_gerar_Entrada(nOpcSelec)
	If lOkExec
		oProcess:IncRegua2(STR0013) // Atualizando Faturamento Direto
		// VV0 //
		DbSelectArea("VV0")
		DbGoTo(nRecVV0)
		RecLock("VV0",.f.)
			If nOpcSelec == 1 // 1=Fatura de Entrada
				VV0->VV0_DATEMI := dDatEmi // Corrigir o Numero da Fatura caso alterou
				VV0->VV0_NNFFDI := cNroDoc // Corrigir o Numero da Fatura caso alterou
				VV0->VV0_SNFFDI := cSerDoc // Corrigir a Serie da Fatura caso alterou
				VV0->VV0_MOEDA  := nMoeda  // Corrigir a Moeda da Fatura caso estava zero
				VV0->VV0_TXMOED := nTxMoeda // Corrigir a Taxa da Moeda da Fatura caso estava zero
				VV0->VV0_STAFDI := "1" // Gerou Fatura de Entrada
			Else // 2=Remito de Entrada
				VV0->VV0_NREFDI := cNroDoc // Numero do Remito
				VV0->VV0_SREFDI := cSerDoc // Serie do Remito
				VV0->VV0_FORFDI := cForDoc // Codigo Fornecedor
				VV0->VV0_LOJFDI := cLojDoc // Loja Fornecedor
				VV0->VV0_STAFDI := "2" // Gerou Remito de Entrada
			EndIf
		VV0->(MsUnLock())
	EndIf
End Transaction
If lOkExec
	FMX_TELAINF( "1" , { { Alltrim(cSerDoc) , Alltrim(cNroDoc) , STR0014 } } ) // GERADO
EndIf
Return lOkExec

/*/{Protheus.doc} VA3410031_gerar_Entrada
Gerar:
1=Fatura de Entrada
2=Remito de Entrada

@author Andre Luis Almeida
@since 10/06/2026
/*/
Static Function VA3410031_gerar_Entrada(nOpcSelec)
Local lOkExec   := .t.
Local cNomeFunc := ""
Local cGruVei   := ""
Local cQuery    := ""
Local cSQLAlias := "SQLVVAVV1"
Local nD1_ITEM  := 0
Local aTemp     := {}
Local cMVGruVei := Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])
Local lFGXGrupoVeic := ExistFunc('FGX_GrupoVeic')
Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Private aIteNFE := {}
Private aCabNFE := {}
// SF1 //
aAdd(aCabNFE,{"F1_TIPO"				,"N"						,Nil})
aAdd(aCabNFE,{"F1_FORMUL"			,"N" 						,Nil})
aAdd(aCabNFE,{"F1_TIPODOC"			,IIf(nOpcSelec==1,"10","60"),Nil}) // 10=Fatura / 60=Remito
aAdd(aCabNFE,{"F1_DOC"				,M->F1_DOC					,Nil})
aAdd(aCabNFE,{"F1_SERIE"			,M->F1_SERIE				,Nil})
aAdd(aCabNFE,{"F1_EMISSAO"			,M->F1_EMISSAO				,Nil})
If nOpcSelec == 1 // 1=Fatura de Entrada
	aAdd(aCabNFE,{"F1_COND"			,M->F1_COND					,Nil})
Else // 2=Remito de Entrada
	If !Empty(M->F1_TRANSP)
		aAdd(aCabNFE,{"F1_TRANSP"	,M->F1_TRANSP  				,Nil})
	EndIf
EndIf
aAdd(aCabNFE,{"F1_DTDIGIT"			,dDataBase					,Nil})
aAdd(aCabNFE,{"F1_FORNECE"			,M->F1_FORNECE				,Nil})
aAdd(aCabNFE,{"F1_LOJA"				,M->F1_LOJA		 			,Nil})
aAdd(aCabNFE,{"F1_VALMERC"			,M->F1_VALBRUT				,Nil})
aAdd(aCabNFE,{"F1_VALBRUT"			,M->F1_VALBRUT				,Nil})
aAdd(aCabNFE,{"F1_EST"				,M->F1_EST					,Nil})
aAdd(aCabNFE,{"F1_MOEDA"			,M->F1_MOEDA				,Nil})
aAdd(aCabNFE,{"F1_TXMOEDA"			,M->F1_TXMOEDA				,Nil})
aAdd(aCabNFE,{"F1_PROVENT"			,M->F1_PROVENT				,Nil})
aAdd(aCabNFE,{"F1_NATUREZ"			,M->F1_NATUREZ				,Nil})
aAdd(aCabNFE,{"E2_NATUREZ"			,M->F1_NATUREZ				,Nil})
// SD1 //
SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
SF4->(dbSeek(xFilial("SF4")+M->D1_TES)) // Posiciona no SF4
aTemp := {}
cQuery := "SELECT VVA_VALTAB , VV1.R_E_C_N_O_ RECVV1 "
cQuery += "  FROM "+RetSQLName("VVA")+" VVA "
cQuery += "  JOIN "+RetSQLName("VV1")+" VV1 "
cQuery += "       ON VV1.VV1_FILIAL='"+xFilial("VV1")+"'"
cQuery += "       AND VV1.VV1_CHAINT=VVA.VVA_CHAINT"
cQuery += "       AND VV1.D_E_L_E_T_=' '"
cQuery += " WHERE VVA.VVA_FILIAL='"+VV0->VV0_FILIAL+"'"
cQuery += "   AND VVA.VVA_NUMTRA='"+VV0->VV0_NUMTRA+"'"
cQuery += "   AND VVA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	VV1->(DbGoTo( (cSQLAlias)->( RECVV1 ) ))
	cGruVei := IIF(lFGXGrupoVeic,FGX_GrupoVeic(VV1->VV1_CHAINT),cMVGruVei )
	If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		nD1_ITEM++
		aAdd(aTemp,{"D1_DOC"		,M->F1_DOC					,Nil})
		aAdd(aTemp,{"D1_SERIE"		,M->F1_SERIE				,Nil})
		aAdd(aTemp,{"D1_ITEM"		,strzero(nD1_ITEM,TamSX3("D1_ITEM")[1])	,Nil})
		aAdd(aTemp,{"D1_COD"		,SB1->B1_COD				,Nil})
		aAdd(aTemp,{"D1_UM"			,SB1->B1_UM					,Nil})
		aAdd(aTemp,{"D1_QUANT"		,1							,Nil})
		aAdd(aTemp,{"D1_VUNIT"		,(cSQLAlias)->( VVA_VALTAB ),Nil})
		aAdd(aTemp,{"D1_TOTAL"		,(cSQLAlias)->( VVA_VALTAB ),Nil})
		aAdd(aTemp,{"D1_EMISSAO"	,M->F1_EMISSAO				,Nil})
		aAdd(aTemp,{"D1_TES"		,M->D1_TES					,Nil})
		aadd(aTemp,{"D1_CF"     	,SF4->F4_CF					,Nil})
		aadd(aTemp,{"D1_DTDIGIT"	,dDataBase					,Nil})
		aAdd(aTemp,{"D1_RATEIO"		,'2'                  		,Nil})
		aAdd(aTemp,{"D1_LOCAL"		,SB1->B1_LOCPAD				,Nil})
		aAdd(aTemp,{"D1_CHASSI"		,VV1->VV1_CHASSI			,Nil})
		aAdd(aTemp,{"D1_PLACA"		,VV1->VV1_PLAVEI			,Nil})
		aAdd(aTemp,{"D1_CC"			,M->D1_CC					,Nil})
		aAdd(aTemp,{"D1_CONTA"		,M->D1_CONTA				,Nil})
		aAdd(aTemp,{"D1_ITEMCTA"	,M->D1_ITEMCTA				,Nil})
		aAdd(aTemp,{"D1_CLVL"		,M->D1_CLVL					,Nil})
		aAdd(aTemp,{"D1_PROVENT"	,M->F1_PROVENT				,Nil})
		aAdd(aIteNFE,aclone(aTemp))
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VVA")
lMsErroAuto := .f.
If nOpcSelec == 1 // 1=Fatura de Entrada
	cNomeFunc := FunName()
	SetFunName("MATA101N")
	MsExecAuto({|x,y,z| MATA101N(x,y,z) },aCabNFE,aIteNFE,3)
	SetFunName(cNomeFunc)
Else // 2=Remito de Entrada
	MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,3)
EndIf
If lMsErroAuto
	DisarmTransaction()
	RollBackSX8()
	MostraErro()
	lOkExec := .f.
EndIf
If lOkExec
	DBSelectArea("SF1")
	DBSetOrder(1)
	DbSeek(xFilial("SF1")+M->F1_DOC+M->F1_SERIE+M->F1_FORNECE+M->F1_LOJA)

	RecLock("SF1",.f.)
	SF1->F1_ORIGEM := cPrefOri
	SF1->(MsUnlock())
Endif

Return lOkExec

/*/{Protheus.doc} VA3410041_SA2
Retorna o Recno do SA2 correspontende ao Cliente do Faturamento Direto (Fabrica)

@author Andre Luis Almeida
@since 10/06/2026
/*/
Function VA3410041_SA2(cCodCli,cLojCli)
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName('SA2')
cQuery += " WHERE A2_FILIAL  = '"+xFilial("SA2")+"'"
cQuery += "   AND A2_CLIENTE = '"+cCodCli+"'"
cQuery += "   AND A2_LOJCLI  = '"+cLojCli+"'"
cQuery += "   AND D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery)

/*/
{Protheus.doc} VA3410051_TudoOK
Tudo Ok Tela

@author Andre Luis Almeida
@since 10/06/2026
/*/
Static Function VA3410051_TudoOK(nOpcSelec)
Local cOpcSelec := ""
Local nCntFor   := 0
Local lRet      := .t.
Local jJson     := JsonObject():New()
Local cQuery    := ""
cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM "+RetSQLName("SF1")
cQuery += " WHERE F1_FILIAL  = '"+xFilial("SF1")+"'"
cQuery += "   AND F1_DOC     = '"+M->F1_DOC+"'"
cQuery += "   AND F1_SERIE   = '"+M->F1_SERIE+"'"
cQuery += "   AND F1_FORNECE = '"+M->F1_FORNECE+"'"
cQuery += "   AND F1_SERIE   = '"+M->F1_SERIE+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	lRet := .f.
	If nOpcSelec == 1 // 1=Fatura de Entrada
		FMX_HELP("VA341ERR005",STR0015,STR0017) // Fatura de Entrada já existente para este Fornecedor. / Impossivel continuar.
	Else // 2=Remito de Entrada
		FMX_HELP("VA341ERR006",STR0016,STR0017) // Remito de Entrada já existente para este Fornecedor. / Impossivel continuar.
	EndIf
EndIf
If lRet
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("SE4")+M->F1_COND)) // Posiciona no SE4
	If SE4->E4_TIPO $ "A/9"
		lRet := .f.
		FMX_HELP("VA341ERR007",STR0018,STR0019) // Condição de Pagamento inválida. / Utilize uma Condição de Pagamento do Tipo 1.
	EndIf
EndIf
If lRet // SALVAR INFORMACOES PARA PROXIMA EXECUCAO
	For nCntFor := 1 to 2
		cOpcSelec := IIf(nCntFor==1,"FAT","REM")
		jJson[cOpcSelec+"_F1_COND"]    := IIf( nCntFor == nOpcSelec , M->F1_COND    , oConf341:GetValue(cOpcSelec+"_F1_COND"   , space(GetSx3Cache("F1_COND"   ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_F1_TRANSP"]  := IIf( nCntFor == nOpcSelec , M->F1_TRANSP  , oConf341:GetValue(cOpcSelec+"_F1_TRANSP" , space(GetSx3Cache("F1_TRANSP" ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_F1_PROVENT"] := IIf( nCntFor == nOpcSelec , M->F1_PROVENT , oConf341:GetValue(cOpcSelec+"_F1_PROVENT", space(GetSx3Cache("F1_PROVENT","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_F1_NATUREZ"] := IIf( nCntFor == nOpcSelec , M->F1_NATUREZ , oConf341:GetValue(cOpcSelec+"_F1_NATUREZ", space(GetSx3Cache("F1_NATUREZ","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_D1_TES"]     := IIf( nCntFor == nOpcSelec , M->D1_TES     , oConf341:GetValue(cOpcSelec+"_D1_TES"    , space(GetSx3Cache("D1_TES"    ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_D1_CC"]      := IIf( nCntFor == nOpcSelec , M->D1_CC      , oConf341:GetValue(cOpcSelec+"_D1_CC"     , space(GetSx3Cache("D1_CC"     ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_D1_CONTA"]   := IIf( nCntFor == nOpcSelec , M->D1_CONTA   , oConf341:GetValue(cOpcSelec+"_D1_CONTA"  , space(GetSx3Cache("D1_CONTA"  ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_D1_ITEMCTA"] := IIf( nCntFor == nOpcSelec , M->D1_ITEMCTA , oConf341:GetValue(cOpcSelec+"_D1_ITEMCTA", space(GetSx3Cache("D1_ITEMCTA","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_D1_CLVL"]    := IIf( nCntFor == nOpcSelec , M->D1_CLVL    , oConf341:GetValue(cOpcSelec+"_D1_CLVL"   , space(GetSx3Cache("D1_CLVL"   ,"X3_TAMANHO"))) )
	Next
	oConf341:Save(jJson)
EndIf
Return lRet

/*/
{Protheus.doc} VA3410061_Valid
Monta o VALID do prw e carrega VALIDUSER dos campos

@author Andre Luis Almeida
@since 13/06/2026
/*/
Static Function VA3410061_Valid(cCpo,lVazio,cVldPRW)
Local cVldRet := IIf(lVazio,'vazio().or.(','')
Local cVldUsr := Alltrim(GetSx3Cache(cCpo,"X3_VLDUSER"))
If !Empty(cVldPRW)
	cVldRet += cVldPRW // VALID do campo
EndIf
If !Empty(cVldUsr)
	cVldRet += IIf(!Empty(cVldPRW),'.and.('+cVldUsr+')',cVldUsr)
EndIf
cVldRet += IIf(cVldRet=='vazio().or.(',".t.","")
cVldRet += IIf(lVazio,')','')
cVldRet := IIf(!Empty(cVldRet),cVldRet,'.T.')
Return FWBuildFeature(STRUCT_FEATURE_VALID,cVldRet)

/*/
{Protheus.doc} VA3410071_Cancelar_Entrada
Cancelar Entrada

@author Andre Luis Almeida
@since 17/06/2026
/*/
Function VA3410071_Cancelar_Entrada(nFatRem,nRECVV0)
Local cVV0_STAFDI := ""
Local lOkExec     := .t.
Local cNomeFunc   := ""
Local aCabNFE     := {}
Local aIteNFE     := {}
Local aInfo       := {}
Local nRecSA2     := VA3410041_SA2( VV0->VV0_CLIFTD , VV0->VV0_LOJFTD )
If nRecSA2 > 0
	SA2->(DbGoTo(nRecSA2))
EndIf
Begin Transaction
	lMsErroAuto := .f.
	If VV0->VV0_STAFDI == "1" .and. nFatRem == 1 // 1=Fatura de Entrada
		AAdd(aInfo, { Alltrim(VV0->VV0_SNFFDI) , Alltrim(VV0->VV0_NNFFDI) , STR0020 } ) // CANCELADO
		aCabNFE := VX0000091_Carrega_Cabec_SF1( VV0->VV0_NNFFDI , VV0->VV0_SNFFDI , SA2->A2_COD , SA2->A2_LOJA )
		If len(aCabNFE) > 0
			aIteNFE := VX0000101_Carrega_Itens_SD1( VV0->VV0_NNFFDI , VV0->VV0_SNFFDI , SA2->A2_COD , SA2->A2_LOJA )
			aAdd(aCabNFE,{"F1_TIPODOC",SF1->F1_TIPODOC,Nil})
			cNomeFunc := FunName()
			SetFunName("MATA101N")
			MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabNFE,aIteNFE,5) // Exclui a Fatura
			SetFunName(cNomeFunc)
			cVV0_STAFDI := "0" // Volta para nenhum documento gerado (Fatura/Remito)
		EndIf
	ElseIf VV0->VV0_STAFDI == "2" .and. nFatRem == 2 // 2=Remito de Entrada
		AAdd(aInfo, { Alltrim(VV0->VV0_SREFDI) , Alltrim(VV0->VV0_NREFDI) , STR0020 } ) // CANCELADO
		aCabNFE := VX0000091_Carrega_Cabec_SF1( VV0->VV0_NREFDI , VV0->VV0_SREFDI , SA2->A2_COD , SA2->A2_LOJA )
		If len(aCabNFE) > 0
			aIteNFE := VX0000101_Carrega_Itens_SD1( VV0->VV0_NREFDI , VV0->VV0_SREFDI , SA2->A2_COD , SA2->A2_LOJA )
			aAdd(aCabNFE,{"F1_TIPODOC",SF1->F1_TIPODOC,Nil})
			MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,5) // Exclui o Remito
			cVV0_STAFDI := "1" // Volta para apenas Fatura gerada
		EndIf
	EndIf
	lOkExec := !lMsErroAuto
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	ElseIf !Empty(cVV0_STAFDI)
		VV0->(DbGoTo(nRECVV0))
		RecLock("VV0",.f.)
			VV0->VV0_STAFDI := cVV0_STAFDI
			If cVV0_STAFDI == "1" // Somente Fatura de Entrada
				VV0->VV0_NREFDI := ""
				VV0->VV0_SREFDI := ""
				VV0->VV0_FORFDI := ""
				VV0->VV0_LOJFDI := ""
			EndIf
		VV0->(MsUnLock())
	EndIf
End Transaction
If lOkExec .and. len(aInfo) > 0
	FMX_TELAINF( "1" , aInfo )
EndIf
Return lOkExec

/*/{Protheus.doc} VEIA341Config
	Faturamento Direto - ARGENTINA
	Classe principal para tratar os dados da parametrização da Geração de Fatura e Remito de Entrada
	
	@type class
	@author Andre Luis Almeida
	@since 13/06/2026
/*/
Class VEIA341Config
	Public Data cCodigo
	Public Data cFilConf
	Data jConfig

	Public Method New() CONSTRUCTOR
	Public Method SetValue()
	Public Method GetValue()
	Public Method Save()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Andre Luis Almeida
	@since 13/06/2026
/*/
Method New() Class VEIA341Config
	::cCodigo  := "VEIA341"
	::cFilConf := Padr(cFilAnt,FWSizeFilial()) // Carrega a Filial Logada
	::jConfig  := JsonObject():New()
	dbselectArea("VRN")
	dbSetOrder( 2 ) // Ordem do VRN
	If dbSeek(xFilial("VRN") + ::cFilConf + ::cCodigo)
		::jConfig:FromJson(VRN->VRN_CONFIG)
	Else
		VRN->(reclock("VRN", .T.))
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := ::cCodigo
		VRN->VRN_CONFIG := "{}"
		VRN->VRN_FILCON := ::cFilConf
		VRN->(msUnlock())
	EndIf	
Return SELF

/*/{Protheus.doc} GetValue
	retorna o valor contido no json para o parametro passado

	@type method
	@author Andre Luis Almeida
	@since 13/06/2026
/*/
Method GetValue(cLabel, xDef) Class VEIA341Config
	if self:jConfig:hasProperty(cLabel)
		return self:jConfig[cLabel]
	endif
Return xDef

/*/{Protheus.doc} SetValue
	Seta o valor do parametro no json

	@type method
	@author Andre Luis Almeida
	@since 13/06/2026
/*/
Method SetValue(cAttr, xValue) Class VEIA341Config
	self:jConfig[cAttr] := xValue
Return .t.

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 13/06/2026
/*/
Method Save(jConfig) Class VEIA341Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		VRN->(msUnlock())
	EndIf
	self:jConfig := jConfig
Return .t.
