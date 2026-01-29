#INCLUDE "FWMVCDEF.CH"
#Include "PROTHEUS.ch"
#Include "TMSAF94.ch"

Static lEstoque := .F.
Static aCatVei  := {{"1","comum",.T.},{"2","cavalo",.F.},{"3","carreta",.T.},{"4","especial",.T.},{"5","utilitario",.T.},{"6","composicao",.F.}}

/*{Protheus.doc} TMSAF94
    Envio de Documentos à Here
    @type Function
    @author Valdemar Roberto Mognon
    @since 23/01/2024
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF94()
    (examples)
    @see (links_or_references)
*/
Function TMSAF94()

Private aRotina := MenuDef()

oBrowse:= FwMBrowse():New()
oBrowse:SetAlias("DNP")
oBrowse:SetDescription(STR0001)	//-- "Envio de Documentos à Here"
oBrowse:AddLegend("DNP_STATUS == '1'","GREEN" ,STR0019)	//-- "Enviado"
oBrowse:AddLegend("DNP_STATUS == '2'","RED"   ,STR0020)	//-- "Não Enviado"
oBrowse:AddLegend("DNP_STATUS == '3'","YELLOW",STR0021)	//-- "Enviado com Falha"
oBrowse:Activate()

Return Nil

/*{Protheus.doc} Menudef
    Define o Menu
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/01/2024
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Menudef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()

Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION  1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAF94" OPERATION  2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAF94" OPERATION  3 ACCESS 0	//-- "Incluir"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.TMSAF94" OPERATION  4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina TITLE STR0016 ACTION "VIEWDEF.TMSAF94" OPERATION  5 ACCESS 0	//-- "Excluir"
ADD OPTION aRotina TITLE STR0009 ACTION "Tmsaf94Exe()"    OPERATION  3 ACCESS 0	//-- "Incluir Estoque"
ADD OPTION aRotina TITLE STR0017 ACTION "Tmsaf94Ger()"    OPERATION 10 ACCESS 0	//-- "Gerar Planejamento"
ADD OPTION aRotina TITLE STR0010 ACTION "Tmsaf94Env()"    OPERATION 10 ACCESS 0	//-- "Enviar à Here"
ADD OPTION aRotina TITLE STR0022 ACTION "Tmsaf94Fal()"    OPERATION 10 ACCESS 0	//-- "Registos com Falha"

Return aRotina

/*{Protheus.doc} Modeldef
    Define a Model
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/01/2024
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Modeldef()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruDNP := FwFormStruct(1,"DNP")
Local oStruDNQ := FwFormStruct(1,"DNQ")
Local oStruDNR := FwFormStruct(1,"DNR")

Local bCommitDNP := {|oModel| TMSAF94Grv(oModel)}

//-- Monta gatilhos
MntTrigger(oStruDNQ,{{{"DNQ_FILDOC","DNQ_DOC","DNQ_SERIE"},{"DNQ_DOCTMS","DNQ_SERTMS","DNQ_TIPTRA","DNQ_CLIREM","DNQ_LOJREM","DNQ_CLIDES",;
															"DNQ_LOJDES","DNQ_QTDVOL","DNQ_PESO"  ,"DNQ_PESOM3","DNQ_VALMER","DNQ_NOMREM",;
															"DNQ_NOMDES"}}})

//-- Define a Model
oModel := MPFormModel():New("TMSAF94",/*bPre*/,/*bPos*/,bCommitDNP,/*bCancel*/)
oModel:SetDescription(STR0001)	//-- "Envio de Documentos à Here"

//-- Cabeçalho do Planejamento
oModel:AddFields("MdFieldDNP",/*cOwner*/,oStruDNP,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"DNP_CODIGO"})

//-- Documentos do Planejamento
oModel:AddGrid("MdGridDNQ","MdFieldDNP",oStruDNQ,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDNQ",{{"DNQ_FILIAL","xFilial('DNQ')"},;
								{"DNQ_CODIGO","DNP_CODIGO"}},;
								DNQ->(IndexKey(1)))
oModel:GetModel("MdGridDNQ"):SetDescription(STR0006)	//-- "Documentos do Planejamento"
oModel:GetModel("MdGridDNQ"):SetUniqueLine({"DNQ_FILDOC","DNQ_DOC","DNQ_SERIE"})	
oModel:GetModel("MdGridDNQ"):SetMaxLine(9999)

//-- Veículos do Planejamento
oModel:AddGrid("MdGridDNR","MdFieldDNP",oStruDNR,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDNR",{{"DNR_FILIAL","xFilial('DNR')"},;
								{"DNR_CODIGO","DNP_CODIGO"}},;
								DNR->(IndexKey(1)))
oModel:GetModel("MdGridDNR"):SetDescription(STR0007)	//-- "Veículos do Planejamento"
oModel:GetModel("MdGridDNR"):SetUniqueLine({"DNR_CODVEI"})	
oModel:GetModel("MdGridDNR"):SetMaxLine(9999)

oModel:SetVldActivate({|oModel| Tmsaf94Ini(oModel)})

oModel:SetActivate({|oModel| Tmsaf94Inc(oModel)})

Return oModel

/*{Protheus.doc} Viewdef
    Define a model
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/01/2024
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Viewdef()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAF94")
Local oView    := Nil
Local oStruDNP := FwFormStruct(2,"DNP")
Local oStruDNQ := FwFormStruct(2,"DNQ")
Local oStruDNR := FwFormStruct(2,"DNR")

//-- Define a View
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a Tela Principal
oView:CreateHorizontalBox("Tela",100)
oView:CreateVerticalBox("Coluna",100,"Tela")

oView:CreateHorizontalBox("Planejamento",030,"Coluna")
oView:CreateHorizontalBox("Documentos"  ,040,"Coluna")
oView:CreateHorizontalBox("Veiculos"    ,030,"Coluna")

//-- Cria o Cabeçalho do Planejamento
oView:AddField("VwFieldDNP",oStruDNP,"MdFieldDNP") 
oView:SetOwnerView("VwFieldDNP","Planejamento")
oView:EnableTitleView("VwFieldDNP",STR0004)	//-- "Planejamento"

//-- Cria os Documentos do Planejamento
oView:AddGrid("VwGridDNQ",oStruDNQ,"MdGridDNQ") 
oView:SetOwnerView("VwGridDNQ","Documentos")
oView:EnableTitleView("VwGridDNQ",STR0006)	//-- "Documentos do Planejamento"

//-- Cria os Veículos do Planejamento
oView:AddGrid("VwGridDNR",oStruDNR,"MdGridDNR") 
oView:SetOwnerView("VwGridDNR","Veiculos")
oView:EnableTitleView("VwGridDNR",STR0007)	//-- "Veículos do Planejamento"

Return oView

/*{Protheus.doc} TMSAF94Grv
Grava registro
@author Valdemar Roberto Mognon
@since 02/02/2024
@version 1.0
@return xRet
*/
Function TMSAF94Grv(oModel)
Local lRet       := .T.
Local cQuery     := ""
Local nOperation := 0
Local oMdlFldDNP := oModel:GetModel("MdFieldDNP")
Local oColEnt

Default oModel := FwModelActive()

oColEnt := TMSBCACOLENT():New("DNM")
If oColEnt:DbGetToken()
	DNM->(DbGoTo(oColEnt:config_recno))

	Begin Transaction
	
		nOperation := oModel:GetOperation()
	
		If nOperation == 5 	//-- Exclusão
			//-- Estorna registros da tabela de históricos (DN5)
			cQuery := "UPDATE " + RetSqlName("DN5")
			cQuery += "   SET DN5_STATUS = '5' "
			cQuery += " WHERE DN5_FILIAL = '" + xFilial("DN5") + "' "
			cQuery += "   AND DN5_CODFON = '" + DNM->DNM_CODFON + "' " 
			cQuery += "   AND DN5_PROCES = 'HerePla" + DNP->DNP_CODIGO + "' " 
			cQuery += "   AND DN5_STATUS = '2' " 
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			TcSqlExec(cQuery)
		EndIf
	
		If lRet
			lRet := FwFormCommit(oModel)
		EndIf
		
		If !lRet	
			DisarmTransaction()
			Break
		EndIf
	
	End Transaction

	If lRet	
		If DNM->DNM_GERPLA == "1"	//-- Geração da transmissão do planejamento automática
			Tmsaf94Ger(oMdlFldDNP:GetValue("DNP_CODIGO"))
		EndIf

		If DNM->DNM_PLAAUT == "1"	//-- Envia o planejamento automaticamente à Here
			Tmsaf94Env(oMdlFldDNP:GetValue("DNP_CODIGO"))
		EndIf
	EndIf
	
End

Return lRet

/*{Protheus.doc} Tmsaf94Mot
Busca nome do motorista a partir do código do veículo
@type Function
@author Valdemar Roberto Mognon
@since 24/01/2024
*/
Function Tmsaf94Mot(cCodVei)
Local cRet   := Space(Len(DA4->DA4_NOME))
Local aAreas := {DA3->(GetArea()),DA4->(GetArea()),GetArea()}

Default cCodVei := ""

DA3->(DbSetOrder(1))
If DA3->(DbSeek(xFilial("DA3") + cCodVei))
	DA4->(DbSetOrder(1))
	If DA4->(DbSeek(xFilial("DA4") + DA3->DA3_MOTORI))
		cRet := DA4->DA4_NOME
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return cRet

/*{Protheus.doc} MntTrigger
    Monta a estrutura da Trigger
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 26/01/2024
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MntTrigger()
    (examples)
    @see (links_or_references)
*/
Static Function MntTrigger(oStruct,aTrigger)
Local cDominio  := ""
Local cContra   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local aAux      := {}

Local aTriggers := {}

For nCntFor1 := 1 To Len(aTrigger)
	For nCntFor2 := 1 To Len(aTrigger[nCntFor1,1])
		cDominio := aTrigger[nCntFor1,1,nCntFor2]
		For nCntFor3 := 1 To Len(aTrigger[nCntFor1,2])
			cContra := aTrigger[nCntFor1,2,nCntFor3]

			aAux :=(FwStruTrigger(cDominio	,; // Campo de Dominio
								  cContra	,; // Campo de ContraDominio
								  "TMSAF94GAT('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
								  ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
								  ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
								  )) // Condição para execução do gatilho (Opcional)

			oStruct:AddTrigger(aAux[1],;	//-- [01] Id do campo de origem
							   aAux[2],;	//-- [02] Id do campo de destino
							   aAux[3],;	//-- [03] Bloco de codigo de validação da execução do gatilho
							   aAux[4])		//-- [04] Bloco de codigo de execução do gatilho
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

FwFreeArray(aAux)
FwFreeArray(aTriggers)

Return

/* {Protheus.doc} TMSAF94Gat
Gatilhos de Campos do Documento
@author Valdemar Roberto Mognon
@since 26/01/2024
@version 1.0
@return xRet
*/
Function TMSAF94GAT(cCampo,cDest)
Local xRet := Nil

Default cCampo  := ReadVar()

If cCampo $ "M->DNQ_FILDOC|M->DNQ_DOC|M->DNQ_SERIE" 
	xRet:= Tmsaf94Doc(cCampo,cDest,FwFldGet("DNQ_FILDOC"),FwFldGet("DNQ_DOC"),FwFldGet("DNQ_SERIE"))
EndIf

Return xRet

/*{Protheus.doc} Tmsaf94Doc
Busca dados do documento para gatilho
@type Function
@author Valdemar Roberto Mognon
@since 24/01/2024
*/
Function Tmsaf94Doc(cCampo,cDest,cFilDoc,cDoc,cSerie)
Local xRet   := ""
Local aAreas := {DT6->(GetArea()),SA1->(GetArea()),GetArea()}
Local lLGPD  := ExistFunc("FWPDCanUse") .And. FWPDCanUse(.T.)

Default cCampo  := ""
Default cDest   := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

If !Empty(cCampo) .And. !Empty(cDest) .And. !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
    DT6->(DbSetOrder(1))
    If DT6->(MsSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
		If "DNQ_DOCTMS" $ cDest
			xRet := DT6->DT6_DOCTMS
		ElseIf "DNQ_SERTMS" $ cDest
			xRet := DT6->DT6_SERTMS
		ElseIf "DNQ_TIPTRA" $ cDest
			xRet := DT6->DT6_TIPTRA
		ElseIf "DNQ_CLIREM" $ cDest
			xRet := DT6->DT6_CLIREM
		ElseIf "DNQ_LOJREM" $ cDest
			xRet := DT6->DT6_LOJREM
		ElseIf "DNQ_CLIDES" $ cDest
			xRet := DT6->DT6_CLIDES
		ElseIf "DNQ_LOJDES" $ cDest
			xRet := DT6->DT6_LOJDES
		ElseIf "DNQ_QTDVOL" $ cDest
			xRet := DT6->DT6_VOLORI
		ElseIf "DNQ_PESOM3" $ cDest
			xRet := DT6->DT6_PESOM3
		ElseIf "DNQ_PESO" $ cDest
			xRet := DT6->DT6_PESO
		ElseIf "DNQ_VALMER" $ cDest
			xRet := DT6->DT6_VALMER
		ElseIf "DNQ_NOMREM" $ cDest
			SA1->(DbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1") + DT6->DT6_CLIREM + DT6->DT6_LOJREM))
			xRet:= SA1->A1_NOME
			If lLGPD
				If Len(FwProtectedDataUtil():UsrAccessPDField(__CUSERID,{"A1_NREDUZ"})) == 0
					xRet := Replicate("*",TamSX3("A1_NOME")[1])
				EndIf
			EndIf
		ElseIf "DNQ_NOMDES" $ cDest
			SA1->(DbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1") + DT6->DT6_CLIDES + DT6->DT6_LOJDES))
			xRet:= SA1->A1_NOME
			If lLGPD
				If Len(FwProtectedDataUtil():UsrAccessPDField(__CUSERID,{"A1_NREDUZ"})) == 0
					xRet := Replicate("*",TamSX3("A1_NOME")[1])
				EndIf
			EndIf
		EndIf
    EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return xRet

/*{Protheus.doc} Tmsaf94Inc
Incluir documentos e veículos em estoque
@type Function
@author Valdemar Roberto Mognon
@since 26/01/2024
*/
Function Tmsaf94Inc(oModel)
Local cPerg   := "TMSAF94"
Local cCodigo := ""

If lEstoque
	If Pergunte(cPerg,.T.)
		cCodigo := GETSX8NUM("DNP","DNP_CODIGO")
		FWMsgrun(,{|| Tmsaf94Prc(oModel,1,cCodigo,,,,,,,,,,,,,,,,)},STR0011,STR0012)	//-- "Aguarde" ### "Montando Planejamento."
		FWMsgrun(,{|| Tmsaf94Prc(oModel,2,cCodigo,cFilAnt,"('1','3')",MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,;
		                         MV_PAR11,MV_PAR12,,)},STR0011,STR0013)	//-- "Aguarde" ### "Montando Planejamento com Documentos do Estoque."
		FWMsgrun(,{|| Tmsaf94Prc(oModel,3,cCodigo,,,,,,,,,,,,,,,cFilAnt,"('1','3','4','5')")},STR0011,STR0014)	//-- "Aguarde" ### "Montando Planejamento com Veículos do Estoque."
	EndIf
	lEstoque := .F.
EndIf

Return

/*{Protheus.doc} Tmsaf94Ger
Gera planejamento
@type Function
@author Valdemar Roberto Mognon
@since 26/01/2024
*/
Function Tmsaf94Ger(cCodigo)

Default cCodigo := DNP->DNP_CODIGO

FWMsgrun(,{|| Tmsaf94Prc(,4,cCodigo,,,,,,,,,,,,,,,,)},STR0011,STR0018)	//-- "Aguarde" ### "Gerando Planejamento"

Return

/*{Protheus.doc} Tmsaf94Env
Envia planejamento à Here
@type Function
@author Valdemar Roberto Mognon
@since 26/01/2024
*/
Function Tmsaf94Env(cCodigo)

Default cCodigo := DNP->DNP_CODIGO

FWMsgrun(,{|| Tmsaf94Prc(,5,cCodigo,,,,,,,,,,,,,,,,)},STR0011,STR0015)	//-- "Aguarde" ### "Enviando Planejamento à Here."

Return

/*{Protheus.doc} Tmsaf94Prc
Processa registros
@type Function
@author Valdemar Roberto Mognon
@since 26/01/2024
*/
Function Tmsaf94Prc(oModel,nAcao,cCodigo,cFilDoc,cSerTMS,cCliRemDe,cLojRemDe,cCliRemAte,cLojRemAte,cCliDesDe,cLojDesDe,cCliDesAte,cLojDesAte,;
					cFilDesDe,cFilDesAte,cCdrDesDe,cCdrDesAte,cFilAtu,cCatVei)
Local cQuery    := ""
Local cAliasQry := ""
Local cCndDep   := ""
Local aAreas    := {}
Local aAreaHer  := {}
Local aStruct   := {}
Local aLayout   := {}
Local aLatLong  := {}
Local nLinha    := 0
Local nCntFor1  := 0
Local oMdlFldDNP
Local oMdlGrdDNQ
Local oMdlGrdDNR
Local oColEnt

Default oModel     := FwModelActive()
Default nAcao      := 0
Default cCodigo    := ""
Default cFilDoc    := ""
Default cSerTMS    := "()"
Default cCliRemDe  := ""
Default cLojRemDe  := ""
Default cCliRemAte := ""
Default cLojRemAte := ""
Default cCliDesDe  := ""
Default cLojDesDe  := ""
Default cCliDesAte := ""
Default cLojDesAte := ""
Default cFilDesDe  := ""
Default cFilDesAte := ""
Default cCdrDesDe  := ""
Default cCdrDesAte := ""
Default cFilAtu    := ""
Default cCatVei    := "()"

If nAcao == 1	//-- Montando Planejamento
	oMdlFldDNP := oModel:GetModel("MdFieldDNP")

	oMdlFldDNP:LoadValue("DNP_FILIAL",xFilial("DNP"))
	oMdlFldDNP:LoadValue("DNP_CODIGO",cCodigo)
	oMdlFldDNP:LoadValue("DNP_DATA"  ,dDataBase)
	oMdlFldDNP:LoadValue("DNP_HORA"  ,SubStr(Time(),1,2) + SubStr(Time(),4,2))
	oMdlFldDNP:LoadValue("DNP_STATUS","2")
ElseIf nAcao == 2	//-- Montando Planejamento com Documentos do Estoque
	oMdlGrdDNQ := oModel:GetModel("MdGridDNQ")

	aAreas := {GetArea()}

	cAliasQry := GetNextAlias()
	cQuery := "SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE,"
	cQuery += "       DT6_DOCTMS,DT6_SERTMS,DT6_TIPTRA,DT6_CLIREM,DT6_LOJREM,DT6_CLIDES,DT6_LOJDES,DT6_VOLORI,DT6_PESO,DT6_PESOM3,DT6_VALMER,"
	cQuery += "       SA1REM.A1_NOME NOMEREM,SA1DES.A1_NOME NOMEDES "
		
	cquery += "  FROM " + RetSqlName("DUD") + " DUD "

	cQuery += "  LEFT OUTER JOIN " + RetSqlName("DNQ") + " DNQ "
	cQuery += "    ON DNQ_FILIAL = '" + xFilial("DNQ") + "' "
	cQuery += "   AND DNQ_FILDOC = DUD_FILDOC "
	cQuery += "   AND DNQ_DOC    = DUD_DOC "
	cQuery += "   AND DNQ_SERIE  = DUD_SERIE "
	cQuery += "   AND DNQ.D_E_L_E_T_ = ' ' "

	cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_FILDOC = DUD_FILDOC "
	cQuery += "   AND DT6_DOC    = DUD_DOC "
	cQuery += "   AND DT6_SERIE  = DUD_SERIE "
	cQuery += "   AND DT6_CLIREM BETWEEN '" + cCliRemDe + "' AND '" + cCliRemAte + "' "
	cQuery += "   AND DT6_LOJREM BETWEEN '" + cLojRemDe + "' AND '" + cLojRemAte + "' "
	cQuery += "   AND DT6_CLIDES BETWEEN '" + cCliDesDe + "' AND '" + cCliDesAte + "' "
	cQuery += "   AND DT6_LOJDES BETWEEN '" + cLojDesDe + "' AND '" + cLojDesAte + "' "
	cQuery += "   AND DT6_FILDES BETWEEN '" + cFilDesDe + "' AND '" + cFilDesAte + "' "
	cQuery += "   AND DT6_CDRDES BETWEEN '" + cCdrDesDe + "' AND '" + cCdrDesAte + "' "
	cQuery += "   AND DT6_DOCTMS IN ('1','2','5')"
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += "  LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1REM "
	cQuery += "    ON SA1REM.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "   AND SA1REM.A1_COD    = DT6_CLIREM "
	cQuery += "   AND SA1REM.A1_LOJA   = DT6_LOJREM "
	cQuery += "   AND SA1REM.D_E_L_E_T_ = ' ' "
	
	cQuery += "  LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1DES "
	cQuery += "    ON SA1DES.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "   AND SA1DES.A1_COD    = DT6_CLIDES "
	cQuery += "   AND SA1DES.A1_LOJA   = DT6_LOJDES "
	cQuery += "   AND SA1DES.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	If !Empty(cFilDoc)
		cQuery += "   AND DUD_FILORI = '" + cFilDoc + "' "
	EndIf
	If !Empty(cSerTMS)
		cQuery += "   AND DUD_SERTMS IN " + cSerTMS
	EndIf
	cQuery += "   AND DUD_STATUS = '1' "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

	cQuery += "   AND NOT EXISTS (SELECT 1 "
	cQuery += "                     FROM " + RetSqlName("DNP") + " DNP "
	cQuery += "                    WHERE DNP_FILIAL = '" + xFilial("DNP") + "' "
	cQuery += "                      AND DNP_CODIGO = DNQ_CODIGO "
	cQuery += "                      AND DNP_STATUS = '2' "
	cQuery += "                      AND DNP.D_E_L_E_T_ = ' ') "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
		
	While (cAliasQry)->(!Eof())
		aLatLong := AtuLatLong((cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE,(cAliasQry)->DT6_CLIREM,(cAliasQry)->DT6_LOJREM,(cAliasQry)->DT6_DOCTMS)
		If Len(aLatLong) == 2 .And. !Empty(aLatLong[1]) .And. !Empty(aLatLong[2])
			nLinha := oMdlGrdDNQ:Length()
			oMdlGrdDNQ:GoLine(nLinha)
			If !oMdlGrdDNQ:IsEmpty()
				oMdlGrdDNQ:AddLine()
			EndIf
			nLinha := oMdlGrdDNQ:Length()
	
			oMdlGrdDNQ:LoadValue("DNQ_FILIAL",xFilial("DNQ"))
			oMdlGrdDNQ:LoadValue("DNQ_FILDOC",(cAliasQry)->DUD_FILDOC)
			oMdlGrdDNQ:LoadValue("DNQ_DOC"   ,(cAliasQry)->DUD_DOC)
			oMdlGrdDNQ:LoadValue("DNQ_SERIE" ,(cAliasQry)->DUD_SERIE)
			oMdlGrdDNQ:LoadValue("DNQ_DOCTMS",(cAliasQry)->DT6_DOCTMS)
			oMdlGrdDNQ:LoadValue("DNQ_SERTMS",(cAliasQry)->DT6_SERTMS)
			oMdlGrdDNQ:LoadValue("DNQ_TIPTRA",(cAliasQry)->DT6_TIPTRA)
			oMdlGrdDNQ:LoadValue("DNQ_CLIREM",(cAliasQry)->DT6_CLIREM)
			oMdlGrdDNQ:LoadValue("DNQ_LOJREM",(cAliasQry)->DT6_LOJREM)
			oMdlGrdDNQ:LoadValue("DNQ_NOMREM",(cAliasQry)->NOMEREM)
			oMdlGrdDNQ:LoadValue("DNQ_CLIDES",(cAliasQry)->DT6_CLIDES)
			oMdlGrdDNQ:LoadValue("DNQ_LOJDES",(cAliasQry)->DT6_LOJDES)
			oMdlGrdDNQ:LoadValue("DNQ_NOMDES",(cAliasQry)->NOMEDES)
			oMdlGrdDNQ:LoadValue("DNQ_QTDVOL",(cAliasQry)->DT6_VOLORI)
			oMdlGrdDNQ:LoadValue("DNQ_PESO"  ,(cAliasQry)->DT6_PESO)
			oMdlGrdDNQ:LoadValue("DNQ_PESOM3",(cAliasQry)->DT6_PESOM3)
			oMdlGrdDNQ:LoadValue("DNQ_VALMER",(cAliasQry)->DT6_VALMER)
		EndIf
        
		(cAliasQry)->(DbSkip())
	EndDo		
	(cAliasQry)->(DbCloseArea())	

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aAreas)
ElseIf nAcao == 3	//-- Montando Planejamento com Veículos do Estoque
	oMdlGrdDNR := oModel:GetModel("MdGridDNR")

	aAreas := {GetArea()}

	cAliasQry := GetNextAlias()
	cQuery := "SELECT DA3_COD,DA3_DESC,DA3_MOTORI,DA3_CAPACM,"
	cQuery += "       DA4_NOME"

	cquery += "  FROM " + RetSqlName("DA3") + " DA3 "

	cQuery += "  JOIN " + RetSqlName("DUT") + " DUT "
	cQuery += "    ON DUT_FILIAL = '" + xFilial("DUT") + "' "
	cQuery += "   AND DUT_TIPVEI = DA3_TIPVEI "
	If !Empty(cCatvei)
		cQuery += "   AND DUT_CATVEI IN " + cCatVei
	EndIf
	cQuery += "   AND DUT.D_E_L_E_T_ = ' ' "

	cQuery += "  LEFT OUTER JOIN " + RetSqlName("DA4") + " DA4 "
	cQuery += "    ON DA4_FILIAL = '" + xFilial("DA4") + "' "
	cQuery += "   AND DA4_COD    = DA3_MOTORI "
	cQuery += "   AND DA4.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DA3_FILIAL = '" + xFilial("DA3") + "' "
	If !Empty(cFilAtu)
		cQuery += "   AND DA3_FILATU = '" + cFilAtu + "' "
	EndIf
	cQuery += "   AND DA3_STATUS = '2' "
	cQuery += "   AND DA3.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
		
	While (cAliasQry)->(!Eof())
		nLinha := oMdlGrdDNR:Length()
		oMdlGrdDNR:GoLine(nLinha)
		If !oMdlGrdDNR:IsEmpty()
			oMdlGrdDNR:AddLine()
		EndIf
		nLinha := oMdlGrdDNR:Length()

		oMdlGrdDNR:LoadValue("DNR_FILIAL",xFilial("DNR"))
		oMdlGrdDNR:LoadValue("DNR_CODVEI",(cAliasQry)->DA3_COD)
		oMdlGrdDNR:LoadValue("DNR_MODVEI",(cAliasQry)->DA3_DESC)
		oMdlGrdDNR:LoadValue("DNR_CODMOT",(cAliasQry)->DA3_MOTORI)
		oMdlGrdDNR:LoadValue("DNR_NOMMOT",(cAliasQry)->DA4_NOME)
		oMdlGrdDNR:LoadValue("DNR_CAPACM",(cAliasQry)->DA3_CAPACM)
		
		(cAliasQry)->(DbSkip())
	EndDo		
	(cAliasQry)->(DbCloseArea())	

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aAreas)
ElseIf nAcao == 4	//-- Gerando Planejamento
	aAreas := {DNQ->(GetArea()),DNR->(GetArea()),GetArea()}
	DNQ->(DbSetOrder(1))
	If DNQ->(DbSeek(xFilial("DNQ") + DNP->DNP_CODIGO))
		DNR->(DbSetOrder(1))
		If DNR->(DbSeek(xFilial("DNR") + DNP->DNP_CODIGO))
			oColEnt := TMSBCACOLENT():New("DNM")
			If oColEnt:DbGetToken()
				DNM->(DbGoTo(oColEnt:config_recno))
		
				//-- Inicializa a estrutura
				aStruct := TMSMntStru(DNM->DNM_CODFON,.T.,"0002")
				TMSSetVar("aStruct",aStruct)
				
				//-- Define o processo
				TMSSetVar("cProcesso","HerePla" + cCodigo)
		
				//-- Inicializa o localizador
				TMSSetVar("aLocaliza",{})
		
				//-- Processamento
				aAreaHer := {}
				Aadd(aAreaHer,GetArea())
				Aadd(aAreaHer,DN1->(GetArea()))
				For nCntFor1 := 1 To Len(aStruct)
					Aadd(aAreaHer,(aStruct[nCntFor1,3])->(GetArea()))
					If Empty(aStruct[nCntFor1,9])
						cCndDep := ".T."
					Else
						cCndDep := AllTrim(aStruct[nCntFor1,9])
					EndIf
					//-- Ainda não foi processado
					//-- Não depende de outro registro
					//-- Não é adicional de nenhum outro registro
					//-- Condição do Registro do Layout atendida ou não informada
					If aStruct[nCntFor1,10] == "2" .And. ;
					   Empty(aStruct[nCntFor1,6]) .And. ;
					   (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor1,1] + aStruct[nCntFor1,2]}) == 0) .And. ;
					   &(cCndDep)
						aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
						If !Empty(aLayout)
							If Empty(aStruct[nCntFor1,6])
								//-- Inicia a gravação dos registros
								MontaReg(Aclone(aLayout),nCntFor1,,,.T.)
								TMSCtrLoop(Aclone(aLayout),nCntFor1)
							EndIf
						EndIf
					EndIf
					aStruct := TMSGetVar("aStruct")
				Next nCntFor1
				TMSSetVar("aCatVei",{{"1","comum",.T.},{"2","cavalo",.F.},{"3","carreta",.T.},{"4","especial",.T.},{"5","utilitario",.T.},{"6","composicao",.F.}})
				AEval(aAreaHer,{|x,y| RestArea(x),FwFreeArray(x)})
				MsgAlert(STR0042,STR0041)	//-- "Planejamento Gerado e Pronto para Envio" ### "Atenção"
			EndIf
		EndIf
	EndIf
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aAreas)
ElseIf nAcao == 5	//-- Enviando Planejamento à Here
	TMSAI86AUX("HerePla" + cCodigo)
EndIf

Return

/*{Protheus.doc} Tmsaf94Exe
Executa chamada da inclusão de estoque
@type Function
@author Valdemar Roberto Mognon
@since 31/01/2024
*/
Function Tmsaf94Exe()

lEstoque := .T.

FWExecView (,"TMSAF94",3) 	

Return

/*{Protheus.doc} Tmsaf94Vld
Valida campos
@type Function
@author Valdemar Roberto Mognon
@since 02/02/2024
*/
Function Tmsaf94Vld(cCampo)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDNP := ""
Local aAreas    := {DT6->(GetArea()),GetArea()}

Default cCampo := ReadVar()

If cCampo $ "M->DNQ_FILDOC:M->DNQ_DOC:M->DNQ_SERIE"
	If !Empty(FwFldGet("DNQ_FILDOC")) .And. !Empty(FwFldGet("DNQ_DOC")) .And. !Empty(FwFldGet("DNQ_SERIE"))
		DT6->(DbSetOrder(1))
		If !DT6->(DbSeek(xFilial("DT6") + FwFldGet("DNQ_FILDOC") + FwFldGet("DNQ_DOC") + FwFldGet("DNQ_SERIE")))
			Help("",1,"TMSAF9406",,,5,11)	//-- Documento não encontrado.
			lRet := .F.
		Else
			If !DT6->DT6_DOCTMS $ "125"
				Help("",1,"TMSAF9407",,,5,11)	//-- Tipo de documento inválido.
				lRet := .F.
			Else
				cAliasDNP := GetNextAlias()
				cQuery := "SELECT DNQ_CODIGO "
			
				cquery += "  FROM " + RetSqlName("DNQ") + " DNQ "

				cQuery += " WHERE DNQ_FILIAL = '" + xFilial("DNQ") + "' "
				cQuery += "   AND DNQ_FILDOC = '" + FwFldGet("DNQ_FILDOC") + "' "
				cQuery += "   AND DNQ_DOC    = '" + FwFldGet("DNQ_DOC") + "' "
				cQuery += "   AND DNQ_SERIE  = '" + FwFldGet("DNQ_SERIE") + "' "
				cQuery += "   AND DNQ_CODIGO <> '" + FwFldGet("DNP_CODIGO") + "' "
				cQuery += "   AND DNQ.D_E_L_E_T_ = ' ' "

				cQuery += "   AND EXISTS (SELECT 1 "
				cQuery += "                 FROM " + RetSqlName("DNP") + " DNP "
				cQuery += "                WHERE DNP_FILIAL = '" + xFilial("DNP") + "' "
				cQuery += "                  AND DNP_CODIGO = DNQ_CODIGO "
				cQuery += "                  AND DNP_STATUS = '2' "
				cQuery += "                  AND DNP.D_E_L_E_T_ = ' ') "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDNP,.F.,.T.)		
					
				If (cAliasDNP)->(!Eof())
					Help("",1,"TMSAF9403",,,5,11)	//-- Documento já pertence a um planejamento em aberto. ### Inicialmente envie o planejamento aberto.
					lRet := .F.
				EndIf		
				(cAliasDNP)->(DbCloseArea())
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} Tmsaf94Dad
Retorna dados do documento e veículo
@type Function
@author Valdemar Roberto Mognon
@since 06/02/2024
*/
Function Tmsaf94Dad(cCampo,cFilDoc,cDoc,cSerie,cCodVei)
Local aAreas    := {DUM->(GetArea()),DTE->(GetArea()),DTC->(GetArea()),DT5->(GetArea()),DT6->(GetArea()),DA3->(GetArea()),DUT->(GetArea()),GetArea()}
Local aAgrupa   := {}
Local aCampos   := {}
Local aTipos    := {}
Local cRet      := ""
Local cUltDoc   := ""
Local cUltNFc   := ""
Local nHorPrv   := 0
Local nMinPrv   := 0
Local dDatPrv   := dDataBase
Local nLinha    := 0
Local nCntFor1  := 0
Local nWork1    := 0
Local nSequen   := 0
Local nIntCpo   := 0
Local nPeso     := 0
Local nQtdVol   := 0
Local nMetro3   := 0
Local nAltura   := 0
Local nLargur   := 0
Local nCompri   := 0

Default cCampo  := ""
Default cFilDoc := DNQ->DNQ_FILDOC
Default cDoc    := DNQ->DNQ_DOC
Default cSerie  := DNQ->DNQ_SERIE
Default cCodVei := DNR->DNR_CODVEI

If cCampo $ "TIPODOC:LATITUDE:LONGITUDE:INICIO:FIM:DEMANDA"
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
		If cCampo == "TIPODOC"
			If DT6->DT6_DOCTMS == "1"
				cRet := "pickups"
			Else
				cRet := "deliveries"
			EndIf
		ElseIf cCampo == "LATITUDE"
			If DT6->DT6_DOCTMS == "1"
				cRet := AtuLatLong(cFilDoc,cDoc,cSerie,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_DOCTMS)[1]
			Else
				cRet := AtuLatLong(cFilDoc,cDoc,cSerie,DT6->DT6_CLIDES,DT6->DT6_LOJDES,DT6->DT6_DOCTMS)[1]
			EndIf
		ElseIf cCampo == "LONGITUDE"
			If DT6->DT6_DOCTMS == "1"
				cRet := AtuLatLong(cFilDoc,cDoc,cSerie,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_DOCTMS)[2]
			Else
				cRet := AtuLatLong(cFilDoc,cDoc,cSerie,DT6->DT6_CLIDES,DT6->DT6_LOJDES,DT6->DT6_DOCTMS)[2]
			EndIf
		ElseIf cCampo == "INICIO"
			If DT6->DT6_DOCTMS == "1"
				DT5->(DbSetOrder(4))
				If DT5->(MsSeek(xFilial("DT5") + cFilDoc + cDoc + cSerie))
					dDatPrv := DT5->DT5_DATPRV
					nHorPrv := Val(SubStr(DT5->DT5_HORPRV,1,2)) + 4
					nMinPrv := Val(SubStr(DT5->DT5_HORPRV,3,2))
					If nHorPrv > 23
						nHorPrv := nHorPrv - 23
						dDatPrv := dDatPrv + 1
					EndIf
				EndIf
			Else
				dDatPrv := DT6->DT6_PRZENT
				nHorPrv := 0
				nMinPrv := 0
			EndIf
			cRet := FWTimeStamp(6,dDatPrv,StrZero(nHorPrv,2)+ ":" + StrZero(nMinPrv,2)+ ":00")
			cRet := FWTimeStamp(6,dDataBase,"00:00:01")
		ElseIf cCampo == "FIM"
			If DT6->DT6_DOCTMS == "1"
				DT5->(DbSetOrder(4))
				If DT5->(MsSeek(xFilial("DT5") + cFilDoc + cDoc + cSerie))
					dDatPrv := DT5->DT5_DATPRV
					nHorPrv := Val(SubStr(DT5->DT5_HORPRV,1,2)) - 4
					nMinPrv := Val(SubStr(DT5->DT5_HORPRV,3,2))
					If nHorPrv < 0
						nHorPrv := 23 + nHorPrv
						dDatPrv := dDatPrv + 1
					EndIf
				EndIf
			Else
				dDatPrv := DT6->DT6_PRZENT
				nHorPrv := 23
				nMinPrv := 59
			EndIf
			cRet := FWTimeStamp(6,dDatPrv,StrZero(nHorPrv,2)+ ":" + StrZero(nMinPrv,2)+ ":00")
			cRet := FWTimeStamp(6,dDataBase,"23:59:59")
		ElseIf cCampo == "DEMANDA"
			If cSerie == "COL"
				DUM->(DbSetOrder(1))
				DTE->(DbSetOrder(3))
				If DUM->(DbSeek(cUltDoc := xFilial("DUM") + cFilDoc + cDoc))
					While DUM->(!Eof()) .And. DUM->(DUM_FILIAL + DUM_FILORI + DUM_NUMSOL) == cUltDoc
						nPeso += DUM->DUM_PESO
						If DTE->(DbSeek(cUltNFc := xFilial("DTE") + DUM->(DUM_FILORI + DUM_NUMSOL + DUM_ITEM)))
							While DTE->(!Eof()) .And. DTE->(DTE_FILIAL + DTE_FILORI + DTE_NUMSOL + DTE_ITESOL) == cUltNFc
								nQtdVol += DTE->DTE_QTDVOL
								nMetro3 += ((DTE->DTE_ALTURA * DTE->DTE_LARGUR * DTE->DTE_COMPRI) * DTE->DTE_QTDVOL)
								nAltura := Max(DTE->DTE_ALTURA,nAltura)
								nLargur := Max(DTE->DTE_LARGUR,nLargur)
								nCompri := Max(DTE->DTE_COMPRI,nCompri)
								DTE->(DbSkip())
							EndDo
						EndIf
						DUM->(DbSkip())
					EndDo
				EndIf
			Else
				DTC->(DbSetOrder(3))
				DTE->(DbSetOrder(1))
				If DTC->(DbSeek(cUltDoc := xFilial("DTC") + cFilDoc + cDoc + cSerie))
					While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == cUltDoc
						nPeso += DTC->DTC_PESO
						If DTE->(DbSeek(cUltNFc := xFilial("DTE") + DTC->(DTC_FILORI + DTC_NUMNFC + DTC_SERNFC + DTC_CLIREM + DTC_LOJREM)))
							While DTE->(!Eof()) .And. DTE->(DTE_FILIAL + DTE_FILORI + DTE_NUMNFC + DTE_SERNFC + DTE_CLIREM + DTE_LOJREM) == cUltNFc
								nQtdVol += DTE->DTE_QTDVOL
								nMetro3 += ((DTE->DTE_ALTURA * DTE->DTE_LARGUR * DTE->DTE_COMPRI) * DTE->DTE_QTDVOL)
								nAltura := Max(DTE->DTE_ALTURA,nAltura)
								nLargur := Max(DTE->DTE_LARGUR,nLargur)
								nCompri := Max(DTE->DTE_COMPRI,nCompri)
								DTE->(DbSkip())
							EndDo
						EndIf
						DTC->(DbSkip())
					EndDo
				EndIf
			EndIf
			cRet := AllTrim(Str(Int(nQtdVol))) + "," + AllTrim(Str(Int(nPeso)))   + "," + AllTrim(Str(Int(nMetro3))) + "," + ;
					AllTrim(Str(Int(nAltura))) + "," + AllTrim(Str(Int(nLargur))) + "," + AllTrim(Str(Int(nCompri)))
		EndIf
	EndIf
EndIf

If cCampo $ "LATINI:LONGINI:HORAINI"
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek(xFilial("DA3") + cCodVei))
		If cCampo == "LATINI"
			cRet := TMSDadFil(cEmpAnt,cFilAnt)[1]
		ElseIf cCampo == "LONGINI"
			cRet := TMSDadFil(cEmpAnt,cFilAnt)[2]
		ElseIf cCampo == "HORAINI"
			cRet := FWTimeStamp(6,dDataBase,"00:00:01")
		EndIf
	EndIf
EndIf

If cCampo $ "LATFIM:LONGFIM:HORAFIM"
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek(xFilial("DA3") + cCodVei))
		If cCampo == "LATFIM"
			cRet := TMSDadFil(cEmpAnt,cFilAnt)[1]
		ElseIf cCampo == "LONGFIM"
			cRet := TMSDadFil(cEmpAnt,cFilAnt)[2]
		ElseIf cCampo == "HORAFIM"
			cRet := FWTimeStamp(6,dDataBase + 15,"23:59:59")
		EndIf
	EndIf
EndIf

If cCampo $ "CATVEI"
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek(xFilial("DA3") + cCodVei))
		DUT->(DbSetOrder(1))
		If DUT->(MsSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If (nLinha := Ascan(aCatVei,{|x| x[1] == DUT->DUT_CATVEI})) > 0
				cRet := aCatVei[nLinha,2]
			EndIf
		EndIf
	EndIf
EndIf

If cCampo $ "CAPACIDADE:TIPHER"
	aAgrupa := TMSGetVar("aAgrVei")
	nSequen := TMSGetVar("nSqAgrVei")
	If cCampo == "CAPACIDADE"
		If Len(aAgrupa) >= nSequen
			aCampos := {"DA3_MAXVOL","DA3_CAPACN","DA3_VOLMAX","DA3_ALTINT","DA3_LARINT","DA3_COMINT"}
			For nCntFor1 := 3 To 8
				nIntCpo := TamSx3(aCampos[nCntFor1 - 2])[1] - TamSx3(aCampos[nCntFor1 - 2])[2] - 1
				
				nWork1  := Val(Replicate("9",nIntCpo))
	
				nWork1  := Iif(aAgrupa[nSequen,nCntFor1] == 0,nWork1,aAgrupa[nSequen,nCntFor1])
				cRet += AllTrim(Str(Int(nWork1)))
				If nCntFor1 < 8
					cRet += ","
				EndIf
			Next nCntFor1
		EndIf
	ElseIf cCampo == "TIPHER"
		If Len(aAgrupa) >= nSequen
			aTipos := RetSX3Box(GetSX3Cache("DUT_TIPHER","X3_CBOX"),,,1)
			If (nLinha := Ascan(aTipos,{|x| x[2] == aAgrupa[nSequen,2]})) > 0
				cRet := aTipos[nLinha,3]
			EndIf
        EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return cRet

/*{Protheus.doc} TMSAF94Fal
Visualiza Registros com Falha
@author Valdemar Roberto Mognon
@since 11/11/2024
@version 1.0
@return xRet
*/
Function TMSAF94Fal(cCodigo)
Local aCoors    := FWGetDialogSize(oMainWnd)
Local aButtons  := {}
Local nOpca     := 0
Local aRotBak   := {}
Local oFwLayer
Local oPanelSup
Local oPanelInf
Local oMrkBrwDoc
Local oMrkBrwVei
Local oDlgFal

Private aSetKey := {}

Default cCodigo := DNP->DNP_CODIGO

If DNP->DNP_STATUS != "3"
	Help("",1,"TMSAF9408",,,5,11)	//-- Planejamento não possui falhas. ### Selecione um planejamento com falhas.
Else
	aRotBak := Aclone(aRotina)
	aRotina := {}

	Aadd(aSetKey,{VK_F4,{|| TMSAF94Det(1)}})
	Aadd(aButtons,{"CARGA",{|| TMSAF94Det(1)},STR0030,STR0030})	//-- "Detalhes Documento" ### "Detalhes Documento"

	Aadd(aSetKey,{VK_F5,{|| TMSAF94Det(2)}})
	Aadd(aButtons,{"CARGANEW",{|| TMSAF94Det(2)},STR0031,STR0031})	//-- "Detalhes Veículo" ### "Detalhes Veículo"

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	DEFINE MSDIALOG oDlgFal TITLE STR0022 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL	//-- Registros com Falha

		//-- Cria Novo Layer
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgFal,.F.,.T.)
		
		//-- Adiciona Linhas
		oFWLayer:AddLine("SUPERIOR",44,.F.)
		oFWLayer:AddLine("INFERIOR",44,.F.)
		
		//-- Adiciona Colunas
		oFWLayer:AddCollumn("TUDO",100,.T.,"SUPERIOR")
		oFwLayer:AddCollumn("TUDO",100,.T.,"INFERIOR")
		
		//-- Adiciona Paineis
		oPanelSup := oFWLayer:GetColPanel("TUDO","SUPERIOR")
		oPanelInf := oFwLayer:GetColPanel("TUDO","INFERIOR")  
		
		//-- Adiciona Mark Browse Documentos
		oMrkBrwDoc:= FWMarkBrowse():New()
		oMrkBrwDoc:SetFieldMark("DNQ_OK")
		oMrkBrwDoc:SetOwner(oPanelSup)
		oMrkBrwDoc:SetAlias("DNQ")
		oMrkBrwDoc:SetMenuDef("")
		oMrkBrwDoc:AddFilter("MANUAL","DNQ->DNQ_CODIGO == '" + cCodigo + "' .AND. DNQ->DNQ_MSGRET != ''",.T.,.T.)
		oMrkBrwDoc:SetDescription(STR0023)	//-- "Selecione os Documentos"
		oMrkBrwDoc:bAllMark := {|| TMSAF94All(1,oMrkBrwDoc,oMrkBrwDoc:Mark(),cCodigo)}
		oMrkBrwDoc:DisableReport()
		oMrkBrwDoc:DisableConfig()
		oMrkBrwDoc:DisableDetails() 
		oMrkBrwDoc:Activate()
		
		//-- Adiciona Mark Browse Veículos
		oMrkBrwVei:= FWMarkBrowse():New()
		oMrkBrwVei:SetFieldMark("DNR_OK")
		oMrkBrwVei:SetOwner(oPanelInf)
		oMrkBrwVei:SetAlias("DNR")
		oMrkBrwVei:SetMenuDef("")
		oMrkBrwVei:AddFilter("MANUAL","DNR->DNR_CODIGO == '" + cCodigo + "' .AND. DNR->DNR_MSGRET != ''",.T.,.T.)
		oMrkBrwVei:SetDescription(STR0024)	//-- "Selecione os Veículos"
		oMrkBrwVei:bAllMark := {|| TMSAF94All(2,oMrkBrwVei,oMrkBrwVei:Mark(),cCodigo)}
		oMrkBrwVei:DisableReport()
		oMrkBrwVei:DisableConfig()
		oMrkBrwVei:DisableDetails() 
		oMrkBrwVei:Activate()
	
		ACTIVATE MSDIALOG oDlgFal ON INIT (EnchoiceBar(oDlgFal,;
						{|| nOpca := 1, Iif(TMSAF94VMk(DNP->DNP_CODIGO,oMrkBrwDoc:Mark(),oMrkBrwVei:Mark()),oDlgFal:End(),nOpca := 0)},;
						{|| oDlgFal:End()};
						,,aButtons),)

	If nOpca == 1
		TMSAF94New(DNP->DNP_CODIGO)

		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
	EndIf 

	aRotina := Aclone(aRotBak)
EndIf

Return

/*{Protheus.doc} TMSAF94All
Visualiza Registros com Falha
@author Valdemar Roberto Mognon
@since 11/11/2024
@version 1.0
*/
Function TMSAF94All(nAcao,oMarkBrw,cMark,cCodigo)
Local aAreas  := {DNQ->(GetArea()),DNR->(GetArea()),GetArea()}
Local cUltCod := ""

Default nAcao    := 0
Default oMarkBrw := Nil
Default cMark    := ""
Default cCodigo  := DNP->DNP_CODIGO

If nAcao == 1	//-- Documentos
	DNQ->(DbSetOrder(1))
	If DNQ->(DbSeek(cUltCod := xFilial("DNQ") + cCodigo))
		While DNQ->(!Eof()) .And. DNQ->(DNQ_FILIAL + DNQ_CODIGO) == cUltCod
			If DNQ->(MsRLock())
				If DNQ->DNQ_OK == cMark
					DNQ->DNQ_OK := "  "
					DNQ->(MsUnlock())
				Else
					DNQ->DNQ_OK := cMark
				Endif
			Endif
			DNQ->(DbSkip())
		EndDo
	EndIf
	DNQ->(DbGoTop())
	DNQ->(DbSeek(xFilial("DNQ") + cCodigo))
	oMarkBrw:Refresh()
ElseIf nAcao == 2	//-- Veículos
	DNR->(DbSetOrder(1))
	If DNR->(DbSeek(cUltCod := xFilial("DNR") + cCodigo))
		While DNR->(!Eof()) .And. DNR->(DNR_FILIAL + DNR_CODIGO) == cUltCod
			If DNR->(MsRLock())
				If DNR->DNR_OK == cMark
					DNR->DNR_OK := "  "
					DNR->(MsUnlock())
				Else
					DNR->DNR_OK := cMark
				Endif
			Endif
			DNR->(DbSkip())
		EndDo
	EndIf
	DNR->(DbGoTop())
	DNR->(DbSeek(xFilial("DNR") + cCodigo))
	oMarkBrw:Refresh()
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSAF94New
Gera Novo Planejamento com Documentos e Veículos Selecionados
@author Valdemar Roberto Mognon
@since 11/11/2024
@version 1.0
*/
Function TMSAF94New(cPlanej)
Local aArea     := {}
Local aLinha    := {}
Local cQuery    := ""
Local cAliasQry := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local lCont     := .T.
Local oModelPla

//-- Variáveis do Planejamento
Local aDadosDNP  := {}
Local aCamposDNP := ""
Local oMdlFldDNP
Local oStruDNP

//-- Variaveis dos Documentos
Local aDadosDNQ  := {}
Local aCamposDNQ := ""
Local oMdlGrdDNQ
Local oStruDNQ

//-- Variáveis dos Veículos
Local aDadosDNR  := {}
Local aCamposDNR := ""
Local oMdlGrdDNR
Local oStruDNR

Default cPlanej := ""

If !Empty(cPlanej)
	//-- Verifica se existem registros de documentos ou veículos selecionados
	aArea := GetArea()
	//-- Variável Base dos Documentos
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DNQ_FILDOC,DNQ_DOC,DNQ_SERIE "
	cquery +=   "FROM " + RetSqlName("DNQ") + " DNQ "
	cQuery +=  "WHERE DNQ_FILIAL = '" + xFilial("DNQ") + "' "
	cQuery +=    "AND DNQ_CODIGO = '" + cPlanej + "' "
	cQuery +=    "AND DNQ_OK     <> ' ' "
	cQuery +=    "AND DNQ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
	While (cAliasQry)->(!Eof())
		aLinha := {}
		Aadd(aLinha,{"DNQ_FILDOC",(cAliasQry)->DNQ_FILDOC})
		Aadd(aLinha,{"DNQ_DOC"   ,(cAliasQry)->DNQ_DOC})
		Aadd(aLinha,{"DNQ_SERIE" ,(cAliasQry)->DNQ_SERIE})
		Aadd(aDadosDNQ,Aclone(aLinha))
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	//-- Variável Base dos Veiculos
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DNR_CODVEI "
	cquery +=   "FROM " + RetSqlName("DNR") + " DNR "
	cQuery +=  "WHERE DNR_FILIAL = '" + xFilial("DNR") + "' "
	cQuery +=    "AND DNR_CODIGO = '" + cPlanej + "' "
	cQuery +=    "AND DNR_OK     <> ' ' "
	cQuery +=    "AND DNR.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
	While (cAliasQry)->(!Eof())
		aLinha := {}
		Aadd(aLinha,{"DNR_CODVEI",(cAliasQry)->DNR_CODVEI})
		Aadd(aDadosDNR,Aclone(aLinha))
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
	FwFreeArray(aArea)

	//-- Gera novo planejamento
	If !Empty(aDadosDNQ) .And. !Empty(aDadosDNR)
		//-- Variável Base do Planejamento
		Aadd(aDadosDNP,{"DNP_CODIGO",GetSX8Num("DNP","DNP_CODIGO")})
		Aadd(aDadosDNP,{"DNP_DATA",dDataBase})
		Aadd(aDadosDNP,{"DNP_HORA",SubStr(Time(),1,2) + SubStr(Time(),4,2)})
		Aadd(aDadosDNP,{"DNP_STATUS",StrZero(2,Len(DNP->DNP_STATUS))})
		Aadd(aDadosDNP,{"DNP_OBSERV",STR0025})	//-- "Gerado Automaticamente"
		ConfirmSX8()
		
		//-- Carrega o Model do Planejamento
		oModelPla := FWLoadModel("TMSAF94")
		oModelPla:SetOperation(3)	//-- Inclusão

		//-- Ativa o Model do Planejamento
		oModelPla:Activate()

		//-- Carrega o Modelo Cabeçalho do Planejamento
		oMdlFldDNP := oModelPla:GetModel("MdFieldDNP")
		oStruDNP   := oMdlFldDNP:GetStruct()
		aCamposDNP := oStruDNP:GetFields()

		//-- Planejamento
		For nCntFor1 := 1 To Len(aDadosDNP)
			If AScan(aCamposDNP,{|x| AllTrim(x[3]) == AllTrim(aDadosDNP[nCntFor1,1])}) > 0
				If !oMdlFldDNP:SetValue(aDadosDNP[nCntFor1,1],aDadosDNP[nCntFor1,2])
					lCont := .F.
					Exit
				EndIf
			EndIf
		Next nCntFor1

		//-- Documentos
		If lCont
			//-- Carrega o Modelo dos Documentos do Planejamento
			oMdlGrdDNQ := oModelPla:GetModel("MdGridDNQ")
			oStruDNQ   := oMdlGrdDNQ:GetStruct()
			aCamposDNQ := oStruDNQ:GetFields()
			For nCntFor1 := 1 To Len(aDadosDNQ)
				If !oMdlGrdDNQ:IsEmpty()
					oMdlGrdDNQ:GoLine(oMdlGrdDNQ:Length())
					If !oMdlGrdDNQ:AddLine()
						lCont := .F.
						Exit
					EndIf
				EndIf
				If lCont
					For nCntFor2 := 1 To Len(aDadosDNQ[nCntFor1])
						If AScan(aCamposDNQ,{|x| AllTrim(x[3]) == AllTrim(aDadosDNQ[nCntFor1,nCntFor2,1])}) > 0
							If !oMdlGrdDNQ:SetValue(aDadosDNQ[nCntFor1,nCntFor2,1],aDadosDNQ[nCntFor1,nCntFor2,2])
								lCont := .F.
								Exit
							EndIf
						EndIf
					Next nCntFor2
				EndIf
			Next nCntFor1
		EndIf

		//-- Veiculos
		If lCont
			//-- Carrega o Modelo dos Veículos do Planejamento
			oMdlGrdDNR := oModelPla:GetModel("MdGridDNR")
			oStruDNR   := oMdlGrdDNR:GetStruct()
			aCamposDNR := oStruDNR:GetFields()
			For nCntFor1 := 1 To Len(aDadosDNR)
				If !oMdlGrdDNR:IsEmpty()
					oMdlGrdDNR:GoLine(oMdlGrdDNR:Length())
					If !oMdlGrdDNR:AddLine()
						lCont := .F.
						Exit
					EndIf
				EndIf
				If lCont
					For nCntFor2 := 1 To Len(aDadosDNR[nCntFor1])
						If AScan(aCamposDNR,{|x| AllTrim(x[3]) == AllTrim(aDadosDNR[nCntFor1,nCntFor2,1])}) > 0
							If !oMdlGrdDNR:SetValue(aDadosDNR[nCntFor1,nCntFor2,1],aDadosDNR[nCntFor1,nCntFor2,2])
								lCont := .F.
								Exit
							EndIf
						EndIf
					Next nCntFor2
				EndIf
			Next nCntFor1
		EndIf

		//-- Grava os Dados
		If lCont
			If (lCont := oModelPla:VldData())
				oModelPla:CommitData()
			EndIf
		EndIf
	
		//-- Se Ocorreu Algum Erro Exibe Mensagem
		If !lCont
			//-- Monta mensagem de erro
			TMSAF94Err(oModelPla)
		
			If !FWGetRunSchedule()
				MostraErro()
			EndIf
		EndIf
	
		//-- Desativa o Model do Planejamento
		oModelPla:DeActivate()
//	Else
//		Help("",1,"TMSAF9409",,,5,11)	//-- Nenhum documento ou veículo selecionado. ### Selecione ao menos um documento e um veículo.
	EndIf
EndIf

Return

/*{Protheus.doc} TMSAF94Err
Monta mensagem de erro
@type Function
@author Valdemar Roberto Mognon
@since 11/11/2024
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF94Err(oModel)
Local aMsgErr := {}

aMsgErr := oModel:GetErrorMessage()

AutoGrLog(STR0032 + " [" + AllToChar(aMsgErr[1]) + "]" )	//-- "Id do formulário de origem:"
AutoGrLog(STR0033 + " [" + AllToChar(aMsgErr[2]) + "]" )	//-- "Id do campo de origem:"
AutoGrLog(STR0034 + " [" + AllToChar(aMsgErr[3]) + "]" )	//-- "Id do formulário de erro:"
AutoGrLog(STR0035 + " [" + AllToChar(aMsgErr[4]) + "]" )	//-- "Id do campo de erro:"
AutoGrLog(STR0036 + " [" + AllToChar(aMsgErr[5]) + "]" )	//-- "Id do erro:"
AutoGrLog(STR0037 + " [" + AllToChar(aMsgErr[6]) + "]" )	//-- "Mensagem do erro:"
AutoGrLog(STR0038 + " [" + AllToChar(aMsgErr[7]) + "]" )	//-- "Mensagem da solução:"
AutoGrLog(STR0039 + " [" + AllToChar(aMsgErr[8]) + "]" )	//-- "Valor atribuído:"
AutoGrLog(STR0040 + " [" + AllToChar(aMsgErr[9]) + "]" )	//-- "Valor anterior:"

Return

/*{Protheus.doc} Tmsaf94Ini
Valida entrada da tela
@type Function
@author Valdemar Roberto Mognon
@since 13/11/2024
*/
Function Tmsaf94Ini(oModel)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE	//-- Alteração ou Exclusão
	If DNP->DNP_STATUS != StrZero(2,Len(DNP->DNP_STATUS))	//-- Enviado ou Enviado com Falha
		Help("",1,"TMSAF9410",,,5,11)	//-- Planejamento já transmitido. Operação não permitida. ### Selecione um planejamento ainda não transmitido.
		lRet := .F.
	EndIf
EndIf

Return lRet

/*{Protheus.doc} Tmsaf94VMk
Valida tela de planejamento com falha
@type Function
@author Valdemar Roberto Mognon
@since 14/11/2024
*/
Function TMSAF94VMk(cCodigo,cMarkDoc,cMarkVei)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local aArea     := GetArea()

Default cCodigo  := DNP->DNP_CODIGO
Default cMarkDoc := GetMark()
Default cMarkVei := GetMark()

cAliasQry := GetNextAlias()
cQuery := "SELECT COUNT(DNQ_DOC) QTDREG "
cquery +=   "FROM " + RetSqlName("DNQ") + " DNQ "
cQuery +=  "WHERE DNQ_FILIAL = '" + xFilial("DNQ") + "' "
cQuery +=    "AND DNQ_CODIGO = '" + cCodigo + "' "
cQuery +=        "AND DNQ_OK = '" + cMarkDoc + "' "
cQuery +=    "AND DNQ.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
	
If (cAliasQry)->(Eof()) .Or. (cAliasQry)->QTDREG == 0
	lRet := .F.
EndIf
(cAliasQry)->(DbCloseArea())

If lRet
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(DNR_CODVEI) QTDREG "
	cquery +=   "FROM " + RetSqlName("DNR") + " DNR "
	cQuery +=  "WHERE DNR_FILIAL = '" + xFilial("DNR") + "' "
	cQuery +=    "AND DNR_CODIGO = '" + cCodigo + "' "
	cQuery +=        "AND DNR_OK = '" + cMarkVei + "' "
	cQuery +=    "AND DNR.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
		
	If (cAliasQry)->(Eof()) .Or. (cAliasQry)->QTDREG == 0
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

If !lRet
	Help("",1,"TMSAF9411",,,5,11)	//-- Planejamento não possui documentos ou veículos vinculados. ### Selecione um planejamento com documento e veículo vinculado.
EndIf

RestArea(aArea)
FwFreeArray(aArea)

Return lRet

/*{Protheus.doc} Tmsaf94Det
Exibe os detalhes dos registros com falha
@type Function
@author Valdemar Roberto Mognon
@since 18/11/2024
*/
Function TMSAF94Det(nAcao)
Local cMensagem := ""
Local oMensagem
Local oDlgDet

Default nAcao := 0

DEFINE MSDIALOG oDlgDet FROM 0,0 TO 200, 235 PIXEL TITLE Iif(nAcao == 1,STR0028,STR0029) + STR0026	//-- "Documentos" ### "Veículos" ### " com Problema"

	cMensagem := Iif(nAcao == 1,DNQ->DNQ_MSGRET,DNR->DNR_MSGRET)

	@004,010 Say STR0027 Size 150,007 Pixel Of oDlgDet	//-- "Mensagem:"
	@015,010 Get oMensagem VAR cMensagem OF oDlgDet Multiline Size 100,080 HSCROLL PIXEL

ACTIVATE MSDIALOG oDlgDet CENTERED

Return

/*{Protheus.doc} Tmsaf94Atu
Atualiza Status do Planejamento
@type Function
@author Valdemar Roberto Mognon
@since 19/11/2024
*/
Function TMSAF94Atu(cPlanej,cStatus)
Local aAreas := {DNP->(GetArea()),GetArea()}

Default cPlanej := ""
Default cStatus := ""

If !Empty(cPlanej) .And. !Empty(cStatus)
	DNP->(DbSetOrder(1))
	If DNP->(DbSeek(xFilial("DNP") + cPlanej))
		RecLock("DNP",.F.)
		DNP->DNP_STATUS := cStatus
		DNP->(MsUnlock())
	EndIf
Endif

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return
