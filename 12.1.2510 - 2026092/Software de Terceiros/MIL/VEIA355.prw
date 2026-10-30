#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA355.CH"

/*/{Protheus.doc} VEIA355

ARGENTINA - TRANSFERENCIA PARA ENTREGA EM OUTRA FILIAL - REMITO DE ENTRADA

@author Andre Luis Almeida
@since 23/06/2026
/*/
Function VEIA355(nRecVWC)
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
Local aSA2Orig := {}
Local oFilHlp  := DMS_FilialHelper():New()
Local lOkExec  := .f.
Local cTitTela := STR0001+" - "+STR0002+": "+cFilAnt // Geração do Remito de Entrada / Filial
Local aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
Private oModel   := FWLoadModel("VEIA355")
Private oView    := FWLoadView("VEIA355")
Private oConf355 := VEIA355Config():New()
Private aAreaSM0 := SM0->(GetArea())

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oModelPar := oModel:GetModel("PARMASTER")

VWC->(DbGoTo(nRecVWC))
oModelPar:SetValue("F1_FILIAL" , VWC->VWC_FILSAI )
oModelPar:SetValue("F1_DOC"    , VWC->VWC_REMSAI )
oModelPar:SetValue("F1_SERIE"  , VWC->VWC_SRESAI )
aSA2Orig := oFilHlp:GetCodFor(VWC->VWC_FILSAI, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
If !Empty(aSA2Orig[1]+aSA2Orig[2])
	SA2->(DbGoTo(aSA2Orig[3]))
	oModelPar:SetValue("F1_FORNECE" , SA2->A2_COD  )
	oModelPar:SetValue("F1_LOJA"    , SA2->A2_LOJA )
	oModelPar:SetValue("A2_NOME"    , SA2->A2_NOME )
	oModelPar:SetValue("F1_EST"     , SA2->A2_EST  )
EndIf

// Buscar o ultimo SALVO
oModelPar:SetValue("F1_TRANSP" ,oConf355:GetValue("F1_TRANSP" , space(GetSx3Cache("F1_TRANSP" ,"X3_TAMANHO"))) )
if cPaisLoc == "ARG"
	oModelPar:SetValue("F1_PROVENT",oConf355:GetValue("F1_PROVENT", space(GetSx3Cache("F1_PROVENT","X3_TAMANHO"))) )
	oModelPar:SetValue("F1_NATUREZ",oConf355:GetValue("F1_NATUREZ", space(GetSx3Cache("F1_NATUREZ","X3_TAMANHO"))) )
endif
oModelPar:SetValue("D1_TES"    ,oConf355:GetValue("D1_TES"    , space(GetSx3Cache("D1_TES"    ,"X3_TAMANHO"))) )
oModelPar:SetValue("D1_CC"     ,oConf355:GetValue("D1_CC"     , space(GetSx3Cache("D1_CC"     ,"X3_TAMANHO"))) )
oModelPar:SetValue("D1_CONTA"  ,oConf355:GetValue("D1_CONTA"  , space(GetSx3Cache("D1_CONTA"  ,"X3_TAMANHO"))) )
oModelPar:SetValue("D1_ITEMCTA",oConf355:GetValue("D1_ITEMCTA", space(GetSx3Cache("D1_ITEMCTA","X3_TAMANHO"))) )
oModelPar:SetValue("D1_CLVL"   ,oConf355:GetValue("D1_CLVL"   , space(GetSx3Cache("D1_CLVL"   ,"X3_TAMANHO"))) )
//
CursorArrow()
oExec355 := FWViewExec():New()
oExec355:setModel(oModel)
oExec355:setView(oView)
oExec355:setTitle(cTitTela)
oExec355:setOK( { || VA3550031_TudoOK(nRecVWC) })
oExec355:setCancel( { || .T. } )
oExec355:setOperation(MODEL_OPERATION_UPDATE)
oExec355:setReduction(10) // Redução de 10% da tela
oExec355:SetButtons(aButtons)
oExec355:openView(.f.)
lOkExec := (oExec355:getButtonPress() == 0)
oExec355:DeActivate()
If lOkExec
	oProcess := MsNewProcess():New({|lEnd| VA3550021_Processa( nRecVWC , @oProcess , @lEnd ) },cTitTela,"",.T.)
	oProcess:Activate()
EndIf
//
Return lOkExec

Static Function ModelDef()
	Local oModel 
	Local oParametro := VA3550011_Campos_Parametros()
	Local oParamStru := oParametro:GetModel()
	oModel := MPFormModel():New( 'VEIA355', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oParamStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:SetDescription(STR0003) // Parametros
	oModel:GetModel('PARMASTER'):SetDescription(STR0003) // Parametros
	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIA355' )
	Local oView 	:= Nil
	Local oParametro := VA3550011_Campos_Parametros()
	Local oParamStru := oParametro:GetView()
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oParamStru , 'PARMASTER')
	oView:EnableTitleView('FORM_PARAM',STR0003) // Parametros
	oView:CreateHorizontalBox('TELA_PARAM',100) //,,.t.)
	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL
	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)
Return oView

/*/
{Protheus.doc} VA3550011_Campos_Parametros
Monta Campos da Grid de Parametros

@author Andre Luis Almeida
@since 23/06/2026
/*/
Static Function VA3550011_Campos_Parametros()
Local oRetorno := OFDMSStruct():New()
oRetorno:AddFieldDictionary( "SF1" , "F1_FILIAL"  , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } , { 'cTitulo' , STR0004 } } ) // Filial Origem
oRetorno:AddFieldDictionary( "SF1" , "F1_DOC"     , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_SERIE"   , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_FORNECE" , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_LOJA"    , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SA2" , "A2_NOME"    , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_EST"     , { { 'lCanChange' , .f. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SF1" , "F1_TRANSP"  , { { 'bValid' , VA3550041_Valid('F1_TRANSP' ,.t.,'ExistCpo("SA4",,1)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .f. } } )
if cPaisLoc == "ARG"
	oRetorno:AddFieldDictionary( "SF1" , "F1_PROVENT" , { { 'bValid' , VA3550041_Valid('F1_PROVENT',.t.,'ExistCpo("SX5","12"+M->F1_PROVENT)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
	oRetorno:AddFieldDictionary( "SF1" , "F1_NATUREZ" , { { 'bValid' , VA3550041_Valid('F1_NATUREZ',.t.,'ExistCpo("SED",,1)') } , { 'lCanChange' , .t. } , { 'cLookUp' , "SED" } , { 'lObrigat' , .t. } } )
endif
oRetorno:AddFieldDictionary( "SD1" , "D1_TES"     , { { 'bValid' , VA3550041_Valid('D1_TES'    ,.t.,'(Existcpo("SF4",,1).and.MaAvalTes("E",M->D1_TES).and.VX0000145_ValidacaoTES("5",M->D1_TES))') } , { 'cTitulo' , RetTitle('VVA_TESREM') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CC"      , { { 'bValid' , VA3550041_Valid('D1_CC'     ,.t.,'ExistCpo("CTT",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CONTA"   , { { 'bValid' , VA3550041_Valid('D1_CONTA'  ,.t.,'ExistCpo("CT1",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_ITEMCTA" , { { 'bValid' , VA3550041_Valid('D1_ITEMCTA',.t.,'ExistCpo("CTD",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "SD1" , "D1_CLVL"    , { { 'bValid' , VA3550041_Valid('D1_CLVL'   ,.t.,'ExistCpo("CTH",,1)') } , { 'lCanChange' , .t. } } )
Return oRetorno

/*/
{Protheus.doc} VA3550021_Processa
Processa

@author Andre Luis Almeida
@since 23/06/2026
/*/
Static Function VA3550021_Processa( nRecVWC , oProcess , lEnd )
Local lOkExec   := .t.
Local cProcesso := STR0005 // Gerando Remito de Entrada
Local aVWC      := {}
Local cQuery    := ""
Local cSQLAlias := "SQLSD2SB1"
Local nD1_ITEM  := 0
Local aTemp     := {}
Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")

Private aIteNFE := {}
Private aCabNFE := {}
//
VWC->(DbGoTo(nRecVWC))
//
SF2->(DbSetOrder(1))
SF2->(DbSeek(VWC->VWC_FILSAI+VWC->VWC_REMSAI+VWC->VWC_SRESAI+VWC->VWC_CLISAI+VWC->VWC_LOJSAI))
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(VWC->VWC_FILTRA+VWC->VWC_NUMTRA))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
oProcess:SetRegua1(0)
oProcess:IncRegua1(STR0006) // Processando...
oProcess:SetRegua2(3)
oProcess:IncRegua2(cProcesso) // Gerando Remito de Entrada
// SF1 //
aAdd(aCabNFE,{"F1_TIPO"				,"N"						,Nil})
aAdd(aCabNFE,{"F1_FORMUL"			,"N" 						,Nil})
aAdd(aCabNFE,{"F1_TIPODOC"			,"60"						,Nil}) // 60=Remito
aAdd(aCabNFE,{"F1_DOC"				,VWC->VWC_REMSAI			,Nil})
aAdd(aCabNFE,{"F1_SERIE"			,VWC->VWC_SRESAI			,Nil})
aAdd(aCabNFE,{"F1_EMISSAO"			,SF2->F2_EMISSAO			,Nil})
If !Empty(M->F1_TRANSP)
	aAdd(aCabNFE,{"F1_TRANSP"		,M->F1_TRANSP  				,Nil})
EndIf
aAdd(aCabNFE,{"F1_DTDIGIT"			,dDataBase					,Nil})
aAdd(aCabNFE,{"F1_FORNECE"			,M->F1_FORNECE				,Nil})
aAdd(aCabNFE,{"F1_LOJA"				,M->F1_LOJA		 			,Nil})
aAdd(aCabNFE,{"F1_VALMERC"			,SF2->F2_VALBRUT			,Nil})
aAdd(aCabNFE,{"F1_VALBRUT"			,SF2->F2_VALBRUT			,Nil})
aAdd(aCabNFE,{"F1_EST"				,M->F1_EST					,Nil})
aAdd(aCabNFE,{"F1_MOEDA"			,SF2->F2_MOEDA				,Nil})
aAdd(aCabNFE,{"F1_TXMOEDA"			,SF2->F2_TXMOEDA			,Nil})
aAdd(aCabNFE,{"F1_PROVENT"			,M->F1_PROVENT				,Nil})
aAdd(aCabNFE,{"F1_NATUREZ"			,M->F1_NATUREZ				,Nil})
aAdd(aCabNFE,{"E2_NATUREZ"			,M->F1_NATUREZ				,Nil})
// SD1 //
SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
SF4->(dbSeek(xFilial("SF4")+M->D1_TES)) // Posiciona no SF4
aTemp := {}
cQuery := "SELECT SD2.D2_COD , SD2.D2_TOTAL , SB1.B1_UM , SB1.B1_LOCPAD	, SB1.B1_DESC "
cQuery += "  FROM "+RetSQLName("SD2")+" SD2 "
cQuery += "  JOIN "+RetSQLName("SB1")+" SB1 "
cQuery += "       ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQuery += "       AND SB1.B1_COD = SD2.D2_COD "
cQuery += "       AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD2.D2_FILIAL  = '"+VWC->VWC_FILSAI+"'"
cQuery += "   AND SD2.D2_DOC     = '"+VWC->VWC_REMSAI+"'"
cQuery += "   AND SD2.D2_SERIE   = '"+VWC->VWC_SRESAI+"'"
cQuery += "   AND SD2.D2_CLIENTE = '"+VWC->VWC_CLISAI+"'"
cQuery += "   AND SD2.D2_LOJA    = '"+VWC->VWC_LOJSAI+"'"
cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	nD1_ITEM++
	aAdd(aTemp,{"D1_DOC"		,VWC->VWC_REMSAI					,Nil})
	aAdd(aTemp,{"D1_SERIE"		,VWC->VWC_SRESAI					,Nil})
	aAdd(aTemp,{"D1_ITEM"		,strzero(nD1_ITEM,TamSX3("D1_ITEM")[1]),Nil})
	aAdd(aTemp,{"D1_COD"		,(cSQLAlias)->( D2_COD )			,Nil})
	aAdd(aTemp,{"D1_UM"			,(cSQLAlias)->( B1_UM )				,Nil})
	aAdd(aTemp,{"D1_QUANT"		,1									,Nil})
	aAdd(aTemp,{"D1_VUNIT"		,(cSQLAlias)->( D2_TOTAL )			,Nil})
	aAdd(aTemp,{"D1_TOTAL"		,(cSQLAlias)->( D2_TOTAL )			,Nil})
	aAdd(aTemp,{"D1_EMISSAO"	,SF2->F2_EMISSAO					,Nil})
	aAdd(aTemp,{"D1_TES"		,M->D1_TES							,Nil})
	aadd(aTemp,{"D1_CF"     	,SF4->F4_CF							,Nil})
	aadd(aTemp,{"D1_DTDIGIT"	,dDataBase							,Nil})
	aAdd(aTemp,{"D1_RATEIO"		,'2'								,Nil})
	aAdd(aTemp,{"D1_LOCAL"		,(cSQLAlias)->( B1_LOCPAD )			,Nil})
	aAdd(aTemp,{"D1_CHASSI"		,Alltrim((cSQLAlias)->( B1_DESC ))	,Nil})
	aAdd(aTemp,{"D1_CC"			,M->D1_CC							,Nil})
	aAdd(aTemp,{"D1_CONTA"		,M->D1_CONTA						,Nil})
	aAdd(aTemp,{"D1_ITEMCTA"	,M->D1_ITEMCTA						,Nil})
	aAdd(aTemp,{"D1_CLVL"		,M->D1_CLVL							,Nil})
	aAdd(aTemp,{"D1_PROVENT"	,M->F1_PROVENT						,Nil})
	aAdd(aIteNFE,aclone(aTemp))
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VWC")
//
oProcess:IncRegua2(cProcesso) // Gerando Remito de Entrada
Begin Transaction
	lMsErroAuto := .f.
	MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,3)
	If lMsErroAuto
		DisarmTransaction()
		RollBackSX8()
		MostraErro()
		lOkExec := .f.
	EndIf
End Transaction

If lOkExec

	oProcess:IncRegua2(cProcesso) // Gerando Remito de Entrada
	// Voltar o RecNo do VV0/VWC
	VV0->(DbGoTo(nRecVV0))
	VWC->(DbGoTo(nRecVWC))

	dbSelectarea("VV0")
	RecLock("VV0",.f.)
		VV0->VV0_FILREM := VWC->VWC_FILENT // PARA DEIXAR ENTREGAR NA FILIAL QUUE ESTA O VEICULO
	VV0->(MsUnLock())

	aAdd(aVWC,{ "VWC_REMENT" , VWC->VWC_REMSAI })
	aAdd(aVWC,{ "VWC_SREENT" , VWC->VWC_SRESAI })
	aAdd(aVWC,{ "VWC_FORENT" , M->F1_FORNECE })
	aAdd(aVWC,{ "VWC_LOJENT" , M->F1_LOJA })
	aAdd(aVWC,{ "VWC_DATENT" , dDataBase })
	aAdd(aVWC,{ "VWC_HORENT" , val(substr(time(),1,2)+substr(time(),4,2)) })
	aAdd(aVWC,{ "VWC_USRENT" , __cUserID })
	aAdd(aVWC,{ "VWC_STATUS" , "2" }) // Transferencia Concluida
	VA3530011_MVC_CAD_VWC( nRecVWC , aVWC )

	FMX_TELAINF( "1" , { { Alltrim(VWC->VWC_SRESAI) , Alltrim(VWC->VWC_REMSAI) , STR0007 } } ) // GERADO

EndIf

If lOkExec
	DBSelectArea("SF1")
	DBSetOrder(1)
	DbSeek(xFilial("SF1")+VWC->VWC_REMSAI+VWC->VWC_SRESAI+M->F1_FORNECE+M->F1_LOJA)

	RecLock("SF1",.f.)
	SF1->F1_ORIGEM := cPrefOri
	SF1->(MsUnlock())
Endif

Return lOkExec

/*/
{Protheus.doc} VA3550031_TudoOK
Tudo Ok Tela

@author Andre Luis Almeida
@since 23/06/2026
/*/
Static Function VA3550031_TudoOK(nRecVWC)
Local lRet  := .t.
Local jJson := JsonObject():New()
// SALVAR INFORMACOES PARA PROXIMA EXECUCAO
jJson["F1_TRANSP"]  := M->F1_TRANSP 
jJson["F1_PROVENT"] := M->F1_PROVENT
jJson["F1_NATUREZ"] := M->F1_NATUREZ
jJson["D1_TES"]     := M->D1_TES
jJson["D1_CC"]      := M->D1_CC
jJson["D1_CONTA"]   := M->D1_CONTA 
jJson["D1_ITEMCTA"] := M->D1_ITEMCTA
jJson["D1_CLVL"]    := M->D1_CLVL  
oConf355:Save(jJson)
VWC->(DbGoTo(nRecVWC))
If VWC->VWC_STATUS <> "1" 
	lRet := .f.
	FMX_HELP("VEIA355ERR01",STR0008,STR0009) // Impossivel realizar a Entrada da Transferência. / Transferência deve estar apenas com a Saida Efetivada.
EndIf
Return lRet

/*/
{Protheus.doc} VA3550041_Valid
Monta o VALID do prw e carrega VALIDUSER dos campos

@author Andre Luis Almeida
@since 23/06/2026
/*/
Static Function VA3550041_Valid(cCpo,lVazio,cVldPRW)
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
{Protheus.doc} VA3550051_Cancelar_Entrada
Cancelar Remito de Entrada

@author Andre Luis Almeida
@since 24/06/2026
/*/
Function VA3550051_Cancelar_Entrada()
Local lOkExec := .t.
Local nRecVWC := VWC->(RecNo())
Local nRecVV0 := 0
Local aCabNFE := {}
Local aIteNFE := {}
Local aVWC    := {}
Local aInfo   := {}
//
ProcRegua(3)
IncProc(STR0010) // Cancelamento do Remito de Entrada
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(VWC->VWC_FILTRA+VWC->VWC_NUMTRA))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
If VWC->VWC_STATUS $ "3/4"
	FMX_HELP("VEIA355ERR02",STR0011) // Transferência não esta mais disponível para o Cancelamento.
EndIf
//
AAdd(aInfo, { Alltrim(VWC->VWC_SRESAI) , Alltrim(VWC->VWC_REMSAI) , STR0012 } ) // CANCELADO
If VWC->VWC_STATUS == "2" // Transferencia Concluida
	Begin Transaction
		lMsErroAuto := .f.
		aCabNFE := VX0000091_Carrega_Cabec_SF1( VWC->VWC_REMENT , VWC->VWC_SREENT , VWC->VWC_FORENT , VWC->VWC_LOJENT )
		If len(aCabNFE) > 0
			aIteNFE := VX0000101_Carrega_Itens_SD1( VWC->VWC_REMENT , VWC->VWC_SREENT , VWC->VWC_FORENT , VWC->VWC_LOJENT )
			aAdd(aCabNFE,{"F1_TIPODOC",SF1->F1_TIPODOC,Nil})
			MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,5) // Exclui o Remito
		EndIf
		IncProc(STR0010) // Cancelamento do Remito de Entrada
		lOkExec := !lMsErroAuto
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
		Else
			DbSelectArea("VV0")
			DbGoto(nRecVV0)
			RecLock("VV0",.f.)
				VV0->VV0_FILREM := "**" // ** PARA NAO DEIXAR ENTREGAR
			VV0->(MsUnLock())
		EndIf
	End Transaction
EndIf
IncProc(STR0010) // Cancelamento do Remito de Entrada
If lOkExec
	DbSelectArea("VWC")
	DbGoto(nRecVWC)
	aAdd(aVWC,{ "VWC_STATUS" , "3" }) // Transferência Cancelada na Entrada
	VA3530011_MVC_CAD_VWC( nRecVWC , aVWC )
	FMX_TELAINF( "1" , aInfo )
EndIf
Return lOkExec

/*/{Protheus.doc} VEIA355Config
	Transferencia para Entrega em outra Filial- ARGENTINA
	Classe principal para tratar os dados da parametrização da Geração de Remito de Entrada
	
	@type class
	@author Andre Luis Almeida
	@since 23/06/2026
/*/
Class VEIA355Config
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
	@since 23/06/2026
/*/
Method New() Class VEIA355Config
	::cCodigo  := "VEIA355"
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
	@since 23/06/2026
/*/
Method GetValue(cLabel, xDef) Class VEIA355Config
	if self:jConfig:hasProperty(cLabel)
		return self:jConfig[cLabel]
	endif
Return xDef

/*/{Protheus.doc} SetValue
	Seta o valor do parametro no json

	@type method
	@author Andre Luis Almeida
	@since 23/06/2026
/*/
Method SetValue(cAttr, xValue) Class VEIA355Config
	self:jConfig[cAttr] := xValue
Return .t.

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 23/06/2026
/*/
Method Save(jConfig) Class VEIA355Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		VRN->(msUnlock())
	EndIf
	self:jConfig := jConfig
Return .t.
