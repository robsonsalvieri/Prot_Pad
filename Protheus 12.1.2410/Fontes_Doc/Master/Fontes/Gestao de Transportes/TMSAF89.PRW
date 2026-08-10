#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF89.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Static lTMF89BUT := ExistBlock("TMF89BUT")	//-- Ponto de Entrada para Incluir Botões na Tela
Static lManDoc   := .T.	//-- Indica se Existe Integração com Manutenção de Documentos
Static lDocRee   := .T.	//-- Novo Documento de Reentrega na Viagem
Static lTMSPNDB  := .T.	//-- Permite Informar a Ocorrência de Pendência para um Documento Bloqueado
Static lITmsDmd  := .F.	//-- Ativa Integração entre TMS e Gestão de Demandas
Static nTMSDIND  := 0	//-- Dias Permitidos para Indenização Após o Documento Entregue
Static cTMSCOSB  := "0"	//-- Deverá ser informada Identificação Produto na Conciliação Sobras/Faltas 0=Não Utiliza,1=Obrigatório,2=Não Obrigatório
Static cEntAer   := "2"	//-- Define o Tipo de Transporte que Realizará a Entrega de um Transporte Aereo. 1-Rodoviario / 2-Aereo
Static nRotExt   := 0	//-- Define a Rotina Externa ao MVC que Está sendo Executada
Static nRadio    := 0	//-- Opções do Encerramento da Pendência
Static lConAut   := .F.	//-- Fecha Conciliação Automaticamente
Static lPergUsu  := .T.	//-- Exibe Perguntas ao Usuário

/*{Protheus.doc} TMSAF89
    Registro de Pendências
    @type Function
    @author Valdemar Roberto Mognon
    @since 10/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89()
*/
Function TMSAF89()
Local aSetKey := {}

Private aRotina	:= MenuDef()

Aadd(aSetKey,{VK_F12,{|| Pergunte("TMAF89",.T.)}})   
TmsKeyOn(aSetKey)

lTMSPNDB := SuperGetMv("MV_TMSPNDB",.F.,.F.)
nTMSDIND := SuperGetMv("MV_TMSDIND",.F.,0)
lDocRee  := SuperGetMV("MV_DOCREE",,.F.)
cTMSCOSB := SuperGetMV("MV_TMSCOSB",,"0")
lITmsDmd := SuperGetMv("MV_ITMSDMD",,.F.)
cEntAer  := SuperGetMv("MV_ENTAER",,"2")

oBrowse:= FwMBrowse():New()
oBrowse:SetAlias("DUU")
oBrowse:SetDescription(STR0001)	//-- "Registro de Pendências"
oBrowse:AddLegend("DUU_STATUS == '1'","BR_VERDE"   ,STR0009)	//-- "Em Aberto"
oBrowse:AddLegend("DUU_STATUS == '2'","BR_AMARELO" ,STR0010)	//-- "Indenização Solicitada"
oBrowse:AddLegend("DUU_STATUS == '3'","BR_VERMELHO",STR0011)	//-- "Indenizada" 
oBrowse:AddLegend("DUU_STATUS == '4'","BR_AZUL"    ,STR0012)	//-- "Encerrada"
oBrowse:Activate()

TmsKeyOff(aSetKey)

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 10/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION  1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAF89" OPERATION  2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAF89" OPERATION  4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "TMSAF89Ind()"    OPERATION 10 ACCESS 0	//-- "Indenizar"
ADD OPTION aRotina TITLE STR0006 ACTION "TMSAF89Enc()"    OPERATION 11 ACCESS 0	//-- "Encerrar"
ADD OPTION aRotina TITLE STR0007 ACTION "TMSAF89Est()"    OPERATION 12 ACCESS 0	//-- "Estornar"
ADD OPTION aRotina TITLE STR0008 ACTION "TMSAF89Con()"    OPERATION 13 ACCESS 0	//-- "Vis. Conciliação"

Return aRotina

/*{Protheus.doc} ModelDef
    Definição do Modelo
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 10/01/2025
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruDUU   := FwFormStruct(1,"DUU")
Local bPosVldDUU := {|oModel| TMSAF89Pos(oModel)}
Local bCommitDUU := {|oModel| TMSAF89Grv(oModel)}

oModel := MpFormModel():New("TMSAF89",/*bPreVld*/,bPosVldDUU,bCommitDUU,/*bCancel*/)

oModel:SetDescription(STR0001)	//-- "Registro de Pendencias"

//-- Enchoice da Pendência
oModel:AddFields("MdFieldDUU",,oStruDUU,,,)
oModel:SetPrimaryKey({"DUU_FILPND","DUU_NUMPND"})
oModel:GetModel("MdFieldDUU"):SetDescription(STR0001)	//-- "Registro de Pendencias"

oModel:SetVldActivate({|oModel| TMSAF89Ent(oModel)})

oModel:SetActivate({|oModel| TMSAF89Ini(oModel,oStruDUU)})

Return oModel

/*{Protheus.doc} ViewDef
    Definição da View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 10/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAF89")
Local oStruDUU := FwFormStruct(2,"DUU")
Local aButTmp  := {}
Local oView

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a tela principal
oView:CreateHorizontalBox("Tela",100)

oView:AddField("VwFieldDUU",oStruDUU,"MdFieldDUU")
oView:SetOwnerView("VwFieldDUU","Tela")

oView:AddUserButton(STR0013,"DEVOLNF" ,{|| TMSAF89NFA(oModel)},NIL,VK_F4,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})	//-- "Notas Fiscais com Avaria"
oView:AddUserButton(STR0008,"S4WB005N",{|| TMSAF89CON(oModel)},NIL,VK_F5,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})	//-- "Vis. Conciliação"

//-- Ponto de Entrada para Adicionar Botões
If lTMF89BUT
	aButTmp := ExecBlock("TMF89BUT",.F.,.F.,{oModel,nRotExt})
	If ValType(aButTmp) == "A" .And. Len(aButTmp) > 0
		AEval(aButTmp,{|x| oView:AddUserButton(x[3],x[1],x[2],NIL,NIL,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})}) 			
	EndIf
EndIf

Return oView

/*{Protheus.doc} TMSAF89Ind
    Executa a Chamada da Função de Indenização
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Ind()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Ind()

nRotExt := 10

FwExecView(STR0005,"TMSAF89",MODEL_OPERATION_UPDATE,,{|| .T.},{|| .T.},,,{|| .T.})

nRotExt := 0

Return

/*{Protheus.doc} TMSAF89Enc
    Executa a Chamada da Função de Encerramento
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Enc()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Enc()

nRotExt := 11

FwExecView(STR0006,"TMSAF89",MODEL_OPERATION_UPDATE,,{|| .T.},{|| .T.},,,{|| .T.})

nRotExt := 0

Return

/*{Protheus.doc} TMSAF89Est
    Executa a Chamada da Função do Estorno do Encerramento
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Est()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Est()

nRotExt := 12

FwExecView(STR0007,"TMSAF89",MODEL_OPERATION_UPDATE,,{|| .T.},{|| .T.},,,{|| .T.})

nRotExt := 0

Return

/*{Protheus.doc} TMSAF89Ini
    Trata abertura da tela
    @type Function
    @author Valdemar Roberto Mognon
    @since 16/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Ini(oStruct)
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Ini(oModel,oStruct)
Local nOperation := 0
Local oMdFldDUU

Default oModel  := FWModelActive()
Default oStruct := Nil

oMdFldDUU  := oModel:GetModel("MdFieldDUU")
nOperation := oModel:GetOperation()

If nOperation == 4	//-- Alterar
	//-- Fixa os Whens dos campos
	If nRotExt == 10	//-- Indenizar
		TMSAF89FWh(oStruct,"TMSAF89Whe()","DUU","DUU_CODCLI:DUU_LOJCLI:DUU_DATENC:DUU_HORENC:DUU_OBSENC:DUU_STATUS:DUU_CODMTC:DUU_IDRSP:DUU_CODRSP:DUU_DATRSP")
	ElseIf nRotExt == 11	//-- Encerrar
		TMSAF89FWh(oStruct,"TMSAF89Whe()","DUU","DUU_VALPRE:DUU_CODCLI:DUU_LOJCLI:DUU_DATENC:DUU_HORENC:DUU_STATUS:DUU_IDRSP:DUU_CODRSP:DUU_DATRSP")
		//-- Inicializa campos
		oMdFldDUU:LoadValue("DUU_DATENC",dDataBase)
		oMdFldDUU:LoadValue("DUU_HORENC",StrTran(SubStr(Time(),1,5),":",""))
	ElseIf nRotExt == 12	//-- Estornar
		TMSAF89FWh(oStruct,"TMSAF89Whe()","DUU","DUU_VALPRE:DUU_MOTIVO:DUU_CODCLI:DUU_LOJCLI:DUU_DATENC:DUU_HORENC:DUU_STATUS:DUU_CODMTC:DUU_IDRSP:DUU_CODRSP:DUU_DATRSP")
	Else
		TMSAF89FWh(oStruct,"TMSAF89Whe()","DUU","DUU_DATENC:DUU_HORENC:DUU_OBSENC:DUU_STATUS:DUU_CODMTC:DUU_IDRSP:DUU_CODRSP:DUU_DATRSP")
	EndIf
	//-- Altera estrutura dos campos
	TMSAF89Str(oStruct,{{"DUU_HORENC",{{3,StrTran(SubStr(Time(),1,5),":","")}}},;
						{"DUU_DATENC",{{5,.F.}}},;
						{"DUU_HORENC",{{5,.F.}}}})
EndIf

Return

/*{Protheus.doc} TMSAF89Str
    Altera estrutura dos campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 17/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Str(oStruct,aCampos (cCampo,(1=Valid / 2=When / 3=IniPad / 4=PictVar / 5=Obrigat)))
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Str(oStruct,aCampos)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local bCodigo

Default oStruct := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	For nCntFor2 := 1 To Len(aCampos[nCntFor1,2])
		If aCampos[nCntFor1,2,nCntFor2,1] == 5
			bCodigo := aCampos[nCntFor1,2,nCntFor2,2]
		Else
			bCodigo := FWBuildFeature(Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,STRUCT_FEATURE_VALID,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,STRUCT_FEATURE_WHEN,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,STRUCT_FEATURE_INIPAD,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,STRUCT_FEATURE_PICTVAR,Nil)))),aCampos[nCntFor1,2,nCntFor2,2])
		EndIf
				
		oStruct:SetProperty(aCampos[nCntFor1,1],Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,MODEL_FIELD_VALID,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,MODEL_FIELD_WHEN,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,MODEL_FIELD_INIT,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,MODEL_FIELD_PICTVAR,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 5,MODEL_FIELD_OBRIGAT,Nil))))),bCodigo)
	Next nCntFor2
Next nCntFor1

Return

/*{Protheus.doc} TMSAF89FWh
    Altera estrutura dos campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 16/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89FWh(oStruct,cFuncao,cTabela,cCampos)
    (examples)
    @see (links_or_references)
*/
Function TMSAF89FWh(oStruct,cFuncao,cTabela,cCampos)
Local nCntFor1 := 0
Local aCampos  := {}
Local lFixWhen := .T.
Local bCodigo

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""
Default cCampos := ""

aCampos  := oStruct:GetFields()
cfuncao  := StrTran(cfuncao,"()","('" + cCampos + "')")
bCodigo  := FWBuildFeature(STRUCT_FEATURE_WHEN,cFuncao)
lFixWhen := Iif(cTabela == "DUU",.T.,.F.) 

For nCntFor1 := 1 To Len(aCampos)
	If GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_PROPRI") != "U"
		If lFixWhen
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,bCodigo)
		EndIf
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMSAF89Whe
Executa o when dos campos da DTQ
@type Function
@author Valdemar Roberto Mognon
@since 16/01/2025
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF89Whe(cCampos)
(examples)
@see (links_or_references)
*/
Function TMSAF89Whe(cCampos)
Local lRet := .T.

Default cCampos := ""

lRet := !(StrTran(ReadVar(),"M->","") $ cCampos)

Return lRet

/*{Protheus.doc} TMSAF89Ent
    Executa a Validação Antes da Entrada da Tela
    @type Function
    @author Valdemar Roberto Mognon
    @since 13/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Ent()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Ent(oModel)
Local lRet       := .T.
Local lReent     := .F.
Local nOperation := 0
Local aAreas     := {DT6->(GetArea()),DUB->(GetArea()),DTQ->(GetArea()),DUD->(GetArea()),GetArea()}

Default oModel := FWModelActive()

nOperation := oModel:GetOperation()

If nRotExt != 0
	nOperation := nRotExt
EndIf

If lRet
	If nOperation == 4 .Or. nOperation == 10 .Or. nOperation == 11	//-- Alterar, Indenizar ou Encerrar
		If DUU->DUU_STATUS == StrZero(4,Len(DUU->DUU_STATUS))
			Help("",1,"TMSAF8901")	//-- Pendência já encerrada. ### Selecione uma pendência não encerrada.
			lRet := .F.
		EndIf
		If lRet
			If nOperation == 10	//-- Indenizar
				If DUU->DUU_TIPPND == "04"
					Help("",1,"TMSAF8916") 	//-- A pendência do tipo 04 não pode ser indenizada, só encerrada. ### Selecione outra pendência.
					lRet := .F.
				ElseIf DUU->DUU_STATUS == StrZero(2,Len(DUU->DUU_STATUS))
					Help("",1,"TMSAF8902")	//-- Indenização já solicitada. ### Selecione uma pendência sem indenização solicitada.
					lRet := .F.
				ElseIf lRet .And. (DUU->DUU_STATUS == StrZero(3,Len(DUU->DUU_STATUS)) .Or. ;
						    (Empty(DUU->DUU_FILDOC) .And. Empty(DUU->DUU_DOC) .And. ;
						     Empty(DUU->DUU_SERIE)))
					Help("",1,"TMSAF8910")	//-- A indenização não poderá ser efetuada para este eocumento. ### Selecione outra pendência.
					lRet := .F.
				EndIf
			ElseIf nOperation == 4 .Or. nOperation == 11	//-- Alterar ou Encerrar
				If DUU->DUU_STATUS == StrZero(2,Len(DUU->DUU_STATUS))
					Help("",1,"TMSAF8914")	//-- Documento com indenização solicitada. ### Selecione uma pendência sem indenização solicitada.
					lRet := .F.
				EndIf
				If lRet
					If DUU->DUU_STATUS == StrZero(3,Len(DUU->DUU_STATUS))
						Help("",1,"TMSAF8915")	//-- Documento com pendência indenizada. ### Selecione uma pendência sem indenização.
						lRet := .F.
					EndIf
				EndIf
				If nOperation == 11	//-- Encerrar
					DT6->(DbSetOrder(1))
					If DT6->(DbSeek( xFilial("DT6") + DUU->(DUU_FILDOC + DUU_DOC + DUU_SERIE)))
						If dDataBase < DUU->DUU_DATPND
							Help("",1,"TMSAF8903")	//-- Data/Hora do encerramento menor que Data/Hora da pendência. ### Selecione uma pendência apta.
							lRet := .F.
						EndIf
					Else
						Help("",1,"TMSAF8917")	//-- Erro ao localizar documento de transporte. ### Selecione uma pendência apta.
						lRet := .F.
					EndIf
					If lRet
						If DUU->DUU_FILPND != cFilAnt
							Help("",1,"TMSAF8924",,DUU->DUU_NUMPND + "/" + DUU->DUU_FILPND,4)	//-- A pendência só pode ser encerrada pela filial. ### FilPnd ### NumPnd ### Entre na filial correta.
							lRet := .F.
						EndIf
						If lRet
							cAliasQry := GetNextAlias()
							cQuery := "SELECT MAX(R_E_C_N_O_) REC "
							cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "
							cQuery +=  "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
							cQuery +=    "AND DUD_FILDOC = '" + DUU->DUU_FILDOC + "' "
							cQuery +=    "AND DUD_DOC    = '" + DUU->DUU_DOC + "' "
							cQuery +=    "AND DUD_SERIE  = '" + DUU->DUU_SERIE + "' "
							cQuery +=    "AND DUD_FILORI = '" + cFilant + "' "
							cQuery +=    "AND D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

							If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
								DUD->(DbGoto((cAliasQry)->REC))
								If !DUD->DUD_STATUS $ "1:4:9" .And. DUU->DUU_TIPPND != StrZero(5,Len(DT2->DT2_TIPPND))
									DTQ->(DbSetOrder(2))
									If DTQ->(DbSeek(xFilial("DTQ") + DUD->DUD_FILORI + DUD->DUD_VIAGEM)) 
										If !DTQ->DTQ_STATUS $ "1:3:4:9"
											Help("",1,"TMSAF8925")	//-- A Pendência não pode ser encerrada. Parte do documento está em viagem. ### A pendencia só poderá ser encerrada quando a viagem for finalizada.
											lRet := .F.
										EndIf
									EndIf
								EndIf
							EndIf
							(cAliasQry)->(DbCloseArea())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf nOperation == 12	//-- Estornar
		If DUU->DUU_TIPPND == "04"	//-- Retorno Documento Cliente
			If lDocRee
				cAliasQry := GetNextAlias()
				cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_DATEMI,DT6_HOREMI,DT6_DOCTMS "
				cQuery +=   "FROM " + RetSqlName("DT6") + " DT6 "
				cQuery +=  "WHERE DT6_FILIAL = '" + xFilial("DT6") + "'"
				cQuery +=    "AND DT6_FILDCO = '" + DUU->DUU_FILDOC + "'"
				cQuery +=    "AND DT6_DOCDCO = '" + DUU->DUU_DOC + "'"
				cQuery +=    "AND DT6_SERDCO = '" + DUU->DUU_SERIE + "'"
				cQuery +=    "AND DT6.D_E_L_E_T_ = ' ' "			
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				
				While (cAliasQry)->(!Eof())
					If StoD((cAliasQry)->DT6_DATEMI) >= DUU->DUU_DATENC .And. ;
							(cAliasQry)->DT6_HOREMI >= DUU->DUU_HORENC
						Help("",1,"TMSAF8920") //-- É necessário estornar o documento de reentrega gerado por essa ocorrência. ### Estorne o documento de reentrega.
						lRet := .F.
					EndIf
					If !lReent .And. (cAliasQry)->DT6_DOCTMS == "7"	//-- Documento de Reentrega
						lReent := .T.
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			EndIf
			If lRet
				If !lReent
					cAliasQry := GetNextAlias()
					cQuery := "SELECT MAX(R_E_C_N_O_) REC "
					cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "
					cQuery +=  "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery +=    "AND DUD_FILDOC = '" + DUU->DUU_FILDOC + "' "
					cQuery +=    "AND DUD_DOC    = '" + DUU->DUU_DOC + "' "
					cQuery +=    "AND DUD_SERIE  = '" + DUU->DUU_SERIE + "' "
					cQuery +=    "AND DUD_FILORI = '" + cFilant + "' "
					cQuery +=    "AND DUD_VIAGEM <> '' "
					cQuery +=    "AND D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
					
					If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
						DUD->(DbGoto((cAliasQry)->REC))
						If DUD->DUD_VIAGEM != DUU->DUU_VIAGEM
							Help("",1,"TMSAF8918")	//-- Existem viagens mais recentes para este documento. ### Selecione uma pendência apta.
							lRet := .F.
						EndIf
					EndIf
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		EndIf
		If lRet
			If DUU->DUU_STATUS == StrZero(1,Len(DUU->DUU_STATUS))
				Help("",1,"TMSAF8905")	//-- Pendência está em aberto. ### Selecione uma pendência que não esteja em aberto.
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If DUU->DUU_STATUS == StrZero(2,Len(DUU->DUU_STATUS))	//-- Indenização Solicitada
				DUB->( DbSetOrder( 2 ) )
				If DUB->(!DbSeek(xFilial("DUB") + DUU->DUU_FILRID + DUU->DUU_NUMRID))
					Help("",1,"TMSAF8906")	//-- Erro ao localizar registro de indenização. ### Selecione uma pendência indenizada.
					lRet := .F.
				EndIf
				If DUB->DUB_STATUS != StrZero(1,Len(DUB->DUB_STATUS))	//-- Em Aberto
					Help("",1,"TMSAF8907")	//-- Registro de indenização já está em andamento. ### Selecione uma pendência não indenizada.
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If lRet
			If DUU->DUU_STATUS == StrZero(3,Len(DUU->DUU_STATUS))	//-- Indenizada
				Help("",1,"TMSAF8908")	//-- Pendência já indenizada. ### Selecione uma pendência ainda não indenizada.
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If DUU->DUU_STATUS == StrZero(4,Len(DUU->DUU_STATUS))	//-- Encerrada
				If !Empty(DUU->DUU_FILDOC + DUU->DUU_DOC + DUU->DUU_SERIE)
					DT6->(DbSetOrder(1))
					If DT6->(!DbSeek(xFilial("DT6") + DUU->DUU_FILDOC + DUU->DUU_DOC + ;
													  DUU->DUU_SERIE))
						Help("",1,"TMSAF8909",,DUU->DUU_FILDOC + "-" + DUU->DUU_DOC + "-" + ;
									DUU->DUU_SERIE,2,15)	//-- Erro ao localizar documento que originou a pendência. ### Selecione uma pendência apta.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lRet
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} TMSAF89Pos
    Executa a Validação Antes da Gravação
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Pos(oModel)
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Pos(oModel)
Local lRet       := .T.
Local lParcial   := .T.
Local lDocEntre  := .F.
Local lHelp      := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local cSeekDUU   := ""
Local cNumDUU    := ""
Local cSeekDUA   := ""
Local cCliDes    := ""
Local cLojDes    := ""
Local cAtvChgCli := SuperGetMV("MV_ATVCHGC",,"")
Local aAreas     := {}
Local nTotalPre  := 0
Local nHorBloq   := 0
Local dDatBloq   := CToD("")
Local oMdFldDUU

Default oModel := FWModelActive()

oMdFldDUU  := oModel:GetModel("MdFieldDUU")
nOperation := oModel:GetOperation()

cNumDUU  := oMdFldDUU:GetValue("DUU_NUMPND")
nHorBloq := Val(oMdFldDUU:GetValue("DUU_HORPND"))
dDatBloq := oMdFldDUU:GetValue("DUU_DATPND")

If nRotExt != 0
	nOperation := nRotExt
EndIf

If lRet .And. nOperation == 10	//-- Indenizar
	If Empty(oMdFldDUU:GetValue("DUU_VALPRE"))
		Help("",1,"OBRIGAT",,RetTitle("DUU_VALPRE"),4)	//-- "Um ou alguns campos obrigatórios não foram preenchidos. xxx -> xxx Pasta"
		lRet := .F.
	EndIf
	
	If lRet
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DUB_VALPRE "

		cQuery +=   "FROM " + RetSqlName("DUB") + " DUB "

		cQuery +=  "WHERE DUB_FILIAL = '" + xFilial("DUB") + "' "
		cQuery +=    "AND DUB_FILDOC = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
		cQuery +=    "AND DUB_DOC    = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
		cQuery +=    "AND DUB_SERIE  = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
		cQuery +=    "AND D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		While (cAliasQry)->(!Eof())
			nTotalPre += (cAliasQry)->DUB_VALPRE
			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())

		If nTotalPre + oMdFldDUU:GetValue("DUU_VALPRE") > oMdFldDUU:GetValue("DUU_VALMER")
			Help("",1,"TMSAF8913")	//-- A soma do valor de prejuízo para este documento ultrapassou o valor da mercadoria. ### Selecione uma pendência com o valor compatível.
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .and. nOperation == 12	//-- Estornar
	aAreas   := {DUU->(GetArea()),DUA->(GetArea()),DT6->(GetArea()),GetArea()}
	lParcial := Posicione("DT6",1,xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
								  oMdFldDUU:GetValue("DUU_SERIE"),"DT6_VOLORI") != oMdFldDUU:GetValue("DUU_QTDOCO")
	If lParcial .And. oMdFldDUU:GetValue("DUU_STATUS") == StrZero(4,Len(DUU->DUU_STATUS))	//-- Se for Pendência Encerrada
		lDocEntre := .F.
		//-- Verifica se a Última Ocorrência Apontada para o Documento Entregue, é de Gera Pendência/Indenização
		//-- Se sim, Permite Estornar o Encerramento da Pendência
		If nTMSDIND > 0 .And. DT6->DT6_STATUS ==  StrZero(7,Len(DT6->DT6_STATUS))
			cAliasQry := GetNextAlias()
			cQuery := "SELECT MAX(DUA.DUA_NUMOCO) NUMOCO "

			cQuery +=   "FROM " + RetSqlName("DUA") + " DUA "

			cQuery +=  "INNER JOIN " + RetSqlName("DT2") + " DT2 "
			cQuery +=     "ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
			cQuery +=    "AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
			cQuery +=    "AND DT2.DT2_TIPOCO <> '05' "
			cQuery +=    "AND DT2.D_E_L_E_T_ = ' ' "
			
			cQuery +=  "WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
			cQuery +=    "AND DUA.DUA_FILDOC = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
			cQuery +=    "AND DUA.DUA_DOC	 = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
			cQuery +=    "AND DUA.DUA_SERIE  = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
			cQuery +=    "AND DUA.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			If (cAliasQry)->(!Eof())
				cNumOco := (cAliasQry)->NUMOCO
			EndIf
			(cAliasQry)->(DbCloseArea())
			
			DUA->(DbSetOrder(5))
			If DUA->(MsSeek(xFilial("DUA") + cNumOco)) .And. ;
				Posicione("DT2",1,xFilial("DT2") + DUA->DUA_CODOCO,"DT2_TIPOCO") $ "06:09"	//-- Gera Pendência ou Indenização
				lDocEntre:= .T.
			EndIf            
		EndIf

		//-- Validacao para Bloqueios
		DUU->(DbSetOrder(3))
		If DUU->(DbSeek(cSeekDUU := xFilial("DUU") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
									oMdFldDUU:GetValue("DUU_SERIE"))) 
			While DUU->(!EoF()) .And. DUU->(DUU_FILIAL + DUU_FILDOC + DUU_DOC + DUU_SERIE) == cSeekDUU
				If DUU->DUU_NUMPND != cNumDUU .And. DUU->DUU_TIPPND == "99"	//-- Verifica a Pendência de Bloqueio Selecionada
					//-- Confere com os Registros de Bloquios Anteriores
					If DUU->DUU_DATPND > dDatBloq .Or. (Val(DUU->DUU_HORPND) > nHorBloq .And. DUU->DUU_DATPND == dDatBloq)
						Help("",1,"TMSAF8919")	//-- Existem pendências de bloqueio mais recentes. ### Selecione uma pendência apta. 
						lRet := .F.
						Exit
					EndIf
				EndIf  
				DUU->(DbSkip())
			Enddo
		EndIf
		
		//-- Se Houve um Apontamento de Entrega Parcial para Este Documento, Gera DUD para Entrega da Quantidade que Falta ser Entregue
		//-- Se Este DUD Estiver em Trânsito não é Possivel Estornar
		DUA->(DbSetOrder(4))
		If DUA->(DbSeek(cSeekDUA := xFilial("DUA") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
									oMdFldDUU:GetValue("DUU_SERIE") + oMdFldDUU:GetValue("DUU_FILORI") + ;
									oMdFldDUU:GetValue("DUU_VIAGEM"))) .And. DUA->DUA_SERTMS != StrZero(1,Len(DUA->DUA_SERTMS))
			While DUA->(!EoF()) .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM) == cSeekDUA
				//-- Verifica se Existe Alguma Viagem de Transporte ou Entrega em Aberto para o Documento
				cAliasQry := GetNextAlias()
				cQuery := "SELECT DUD_FILORI,DUD_VIAGEM "

				cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "

				cQuery +=  "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQuery +=    "AND DUD_FILDOC = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
				cQuery +=    "AND DUD_DOC    = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
				cQuery +=    "AND DUD_SERIE  = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
				//-- Se a Viagem a qual Gerou a Pendência Está na Filial de Destino (final), Entao Verifica se há uma Viagem de Entrega
				//-- se Ela for de Transporte Gerada para o Documento
				cQuery +=    "AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
				cQuery +=    "AND DUD_FILVGE = '" + oMdFldDUU:GetValue("DUU_FILORI") + "' "
				cQuery +=    "AND DUD_NUMVGE = '" + oMdFldDUU:GetValue("DUU_VIAGEM") + "' "
				cQuery +=    "AND DUD.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

				If (cAliasQry)->(!Eof()) .Or. (DT6->DT6_STATUS ==  StrZero(7,Len(DT6->DT6_STATUS)) .And. !lDocEntre)
					Help("",1,"TMSAF8911",,(cAliasQry)->DUD_FILORI + "/" + (cAliasQry)->DUD_VIAGEM)	//-- O estorno não pode ser efetuado pois existe uma viagem para este documento. ### Selecione uma pendência sem viagem.
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
				DUA->(DbSkip())
			EndDo
		EndIf
	EndIf
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
EndIf
                          
If lRet .And. nOperation == 11	//-- Encerrar
	aAreas := {DUL->(GetArea()),DTQ->(GetArea()),DT2->(GetArea()),DUU->(GetArea()),DUA->(GetArea()),DT6->(GetArea()),GetArea()}

	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
					oMdFldDUU:GetValue("DUU_SERIE"))) .And. DT6->DT6_STATUS == StrZero(7, Len(DT6->DT6_STATUS))	//-- Entregue
		//-- Antes de Considerar que não Pode Encerrar Devido o Status do CTe Estar Como Entregue,
		//-- Verifica se a Entrega Está Apontada Juntamente com a Ocorrência que Gera Pendência
		DUA->(DbSetOrder(4))
		If DUA->(DbSeek(cSeekDUA := xFilial("DUA") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
									oMdFldDUU:GetValue("DUU_SERIE")))
			While DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE) == cSeekDUA
				If DUA->DUA_CODOCO != oMdFldDUU:GetValue("DUU_CODOCO")
					If Posicione("DT2",1,xFilial("DT2") + DUA->DUA_CODOCO,"DT2_TIPOCO")	== StrZero(1,Len(DT2->DT2_TIPOCO))
						lHelp := .F.
					EndIf
				EndIf
				DUA->(DbSkip())
			EndDo
		EndIf
		If lHelp
			Help("",1,"TMSAF8904")	//-- O encerramento não poderá ser efetuado, pois este documento já foi entregue. ### Selecione uma pendência apta.
			lRet := .F.
		EndIf
	EndIf

	//-- Verificar se Existe Um Movimento de Viagem já Carregado, e se Houver não Permite Encerrar Essa Pendência até se Desfazer
	//-- Esse Carregamento, ou Encerrar Essa Viagem
	If lRet
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DUD_FILORI,DUD_VIAGEM "

		cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "

		cQuery +=  "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery +=    "AND DUD_FILDOC = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
		cQuery +=    "AND DUD_DOC    = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
		cQuery +=    "AND DUD_SERIE  = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
		If DUA->DUA_SERTMS == StrZero(2,Len(DUA->DUA_SERTMS)) .And. ;
				Posicione("DTQ",2,xFilial("DTQ") + oMdFldDUU:GetValue("DUU_FILORI") + oMdFldDUU:GetValue("DUU_VIAGEM"),"DTQ_FILATU") == ;
							DT6->DT6_FILDES
			cQuery +=    "AND DUD_SERTMS = '" + StrZero(3,Len(DUA->DUA_SERTMS)) + "' "
		Else
			cQuery +=    "AND DUD_SERTMS = '" + DUA->DUA_SERTMS + "' "
		EndIf
		cQuery +=    "AND DUD_FILVGE = '" + oMdFldDUU:GetValue("DUU_FILORI") + "' "
		cQuery +=    "AND DUD_NUMVGE = '" + oMdFldDUU:GetValue("DUU_VIAGEM") + "' "
		cQuery +=    "AND DUD_STATUS IN ('" + StrZero(2,Len(DUD->DUD_STATUS)) + "','" + StrZero(3,Len(DUD->DUD_STATUS)) + "') "
		cQuery +=    "AND DUD.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		If (cAliasQry)->(!Eof())
			Help("",1,"TMSAF8912",,(cAliasQry)->DUD_FILORI + "/" + (cAliasQry)->DUD_VIAGEM)	//-- Esta pendência não poderá ser encerrada até que a viagem atual tenha seu carregamento estornado ou ser encerrada. ### Selecione uma pendência apta.
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
 
	If lRet .And. oMdFldDUU:GetValue("DUU_TIPPND") == "05"	//-- Retirada de Mercadoria
		If Posicione("DTQ",2,xFilial("DTQ") + oMdFldDUU:GetValue("DUU_FILORI") + oMdFldDUU:GetValue("DUU_VIAGEM"),"DTQ_STATUS") != "2"
			Help("",1,"TMSAF8922")	//-- Esta pendência não pode ser encerrada pois para pendência do tipo 05=Retirada de Mercadoria, a viagem necessita estar com o status 2=Em trânsito. ### Selecione uma pendência apta.
			lRet := .F. 
		EndIf

		If lRet
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
							oMdFldDUU:GetValue("DUU_SERIE")))
				If !Empty(DT6->DT6_SQEDES)
					DUL->(dbSetOrder(2))
					If DUL->(DbSeek(xFilial("DUL") + DT6->(DT6_CLIDES + DT6_LOJDES + DT6_SQEDES))) .And. ;
									(!Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED))
						cCliDes	:= DUL->DUL_CODRED
						cLojDes	:= DUL->DUL_LOJRED
					EndIf
				Else
					cCliDes := DT6->DT6_CLIDES
					cLojDes := DT6->DT6_LOJDES
				EndIf
			EndIf

			cAliasQry := GetNextAlias()
			cQuery := "SELECT DTW_CODCLI,DTW_LOJCLI,DTW_ATIVID "

			cQuery +=   "FROM " + RetSQLName("DTW") + " DTW "

			cQuery +=  "WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery +=    "AND DTW_FILORI = '" + oMdFldDUU:GetValue("DUU_FILORI")  + "' " 
			cQuery +=    "AND DTW_VIAGEM = '" + oMdFldDUU:GetValue("DUU_VIAGEM")  + "' "
			cQuery +=    "AND DTW_STATUS = '2' "	//-- Encerrado
			cQuery +=    "AND DTW_DATREA <> '' "
			cQuery +=    "AND DTW_HORREA <> '' "
			cQuery +=    "AND DTW.D_E_L_E_T_ = ' ' "

			cQuery +=  "ORDER BY DTW.R_E_C_N_O_ DESC "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

			If (cAliasQry)->(!Eof())
				If (cAliasQry)->DTW_ATIVID == cAtvChgCli .And. ;
						((cAliasQry)->DTW_CODCLI == cCliDes .And. (cAliasQry)->DTW_LOJCLI == cLojDes)
					lRet := .T.
				Else
					lRet := .F.
					Help("",1,"TMSAF8923")	//-- Esta pendência não pode ser encerrada pois para pendência do tipo 05=Retirada de Mercadoria, a operação de chegada no respectivo cliente deve estar corretamente apontada e a operação de saída desse respectivo cliente deve estar em aberto. ### Selecione uma pendência apta.
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Trata Conciliação
	If lRet
		If oMdFldDUU:GetValue("DUU_TIPPND") $ "01:03" .And. cTMSCOSB != "0"
			lRet := TMSAF89DYZ(,oMdFldDUU)
			If !lRet .Or. oMdFldDUU:GetValue("DUU_QTDCON") > 0	//-- Não Encontrou Pendente ou Existe Conciliacao Efetuada
				If Empty(oMdFldDUU:GetValue("DUU_CODMTC"))
					Help("",1,"TMSAF8921")	//-- O código do motivo da conciliação não foi informado. ### Informe o código do motivo da conciliação.
					lRet:= .F.
				EndIf
			EndIf
			If !lRet .And. !Empty(oMdFldDUU:GetValue("DUU_CODMTC"))
				If lPergUsu
					If MsgYesNo(STR0025)	//-- "Existem Conciliações Pendentes e Serão Encerradas Automaticamente. Confirma?"
						lRet:= .T.
					EndIf
				Else
					If lConAut
						lRet := .T.
					EndIf
				EndIf 
			EndIf
		EndIf
	EndIf

	If lRet
		If oMdFldDUU:GetValue("DUU_TIPPND") == StrZero(4,Len(DUU->DUU_TIPPND))
			If lManDoc .And. lPergUsu
				nRadio := TMSAF89Doc()
			EndIf
		EndIf
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
EndIf    

Return lRet

/*{Protheus.doc} TMSAF89Grv
    Gravação
    @type Function
    @author Valdemar Roberto Mognon
    @since 13/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Grv()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Grv(oModel)
Local lRet       := .T.
Local lBloqueado := .F.
Local lDocEntre  := .F.
Local lRetMer    := .F.
Local lDesbloDoc := .T.
Local lGeraDud   := .T.
Local lVigVazia  := .F.
Local lTransito  := .F.
Local nOperation := 0
Local nQuant     := 0
Local aAreas     := {DUB->(GetArea()),DT2->(GetArea()),DT6->(GetArea()),GetArea()}
Local aAreaDUD   := {}
Local aAreaDT6   := {}
Local aCampos    := {}
Local cQuery     := ""
Local cAliasQry  := ""
Local cDUDStat   := "1"
Local oMdFldDUU

//-- Variaveis Utilizadas no TMSA500
Private cCadastro := ""
Private cLoteAut  := ""
Private lTmsCFec  := .F.	//-- Desabilita as Funções do TMSA200 o Tratamento de Carga Fechada
Private nDiaArm   := 0
Private lPenArm   := .F.

Default oModel := FWModelActive()

Pergunte("TMAF89",.F.)
lManDoc := Iif(MV_PAR01 == 1,.T.,.F.)

oMdFldDUU  := oModel:GetModel("MdFieldDUU")
nOperation := oModel:GetOperation()

If nRotExt != 0
	nOperation := nRotExt
EndIf

//-- Verifica Indenização Após o Documento Entregue
If nTMSDIND > 0        
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + oMdFldDUU:GetValue("DUU_SERIE"))) .And. ;
		DT6->DT6_STATUS == StrZero(7,Len(DUU->DUU_STATUS)) .And. ;
		DT6->DT6_BLQDOC == StrZero(2,Len(DT6->DT6_BLQDOC))
			lDocEntre:= .T.
	EndIf
EndIf

//-- Verifica Documento Bloqueado
If lTMSPNDB
	lBloqueado := TM360BLOQ(oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),oMdFldDUU:GetValue("DUU_SERIE"))
EndIf

Begin Transaction

	If lRet
		If nOperation == 10	//-- Indenizar
			oMdFldDUU:LoadValue("DUU_NUMRID",TmsA360DUB(oMdFldDUU:GetValue("DUU_FILORI"),oMdFldDUU:GetValue("DUU_VIAGEM"),;
														oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),;
														oMdFldDUU:GetValue("DUU_SERIE") ,oMdFldDUU:GetValue("DUU_CODCLI"),;
														oMdFldDUU:GetValue("DUU_LOJCLI"),oMdFldDUU:GetValue("DUU_CODOCO"),;
														oMdFldDUU:GetValue("DUU_MOTIVO"),oMdFldDUU:GetValue("DUU_QTDOCO"),;
														oMdFldDUU:GetValue("DUU_VALPRE"),3))
			If !Empty(oMdFldDUU:GetValue("DUU_NUMRID"))
				oMdFldDUU:LoadValue("DUU_FILRID",cFilAnt)
				oMdFldDUU:LoadValue("DUU_STATUS",StrZero(2,Len(DUU->DUU_STATUS)))	//-- Indenização Solicitada

				//-- Atualiza o Saldo Apenas para Indicar a Entrega se Encerrou o Saldo do Documento
				nQuant := 0
				If !lDocEntre
					lRet := TM360AtuSal(oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),oMdFldDUU:GetValue("DUU_SERIE"),;
										@nQuant,"01",Iif(Empty(oMdFldDUU:GetValue("DUU_DATENC")),dDataBase,oMdFldDUU:GetValue("DUU_DATENC")),.F.,;
										oMdFldDUU:GetValue("DUU_FILORI"),oMdFldDUU:GetValue("DUU_VIAGEM"),.T.,DUU->(Recno()))
				EndIf

				//-- Documento de Devolução não Possui DTC Logo Help não Pode ser Apresentado para Devolução
				If DT6->DT6_DOCTMS != "6" .And. !lDocEntre
					TMSAF89ASt(oMdFldDUU:GetValue("DUU_FILPND"),oMdFldDUU:GetValue("DUU_NUMPND"),oMdFldDUU:GetValue("DUU_CODOCO"),nOperation) 
				EndIf

				//-- Encerra as Conciliações
				If cTMSCOSB != "0" .And. oMdFldDUU:GetValue("DUU_TIPPND") $ "01/03" 
					TMSAF89DYZ(nOperation,oMdFldDUU)
				EndIf
			Else
				lRet := .F.
			EndIf						

		ElseIf nOperation == 11 	//-- Encerrar
			lRetMer := Posicione("DT2",1,xFilial("DT2") + oMdFldDUU:GetValue("DUU_CODOCO"),"DT2_TIPPND") == StrZero(5,Len(DT2->DT2_TIPPND))

			DT6->(DbSetOrder(1))
			If DT6->(DbSeek( xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + oMdFldDUU:GetValue("DUU_SERIE"))) .And. !lDocEntre
				cAliasQry := GetNextAlias()
				cQuery := "SELECT COUNT(*) PNDABERTA "

				cQuery +=   "FROM " + RetSqlName("DUU") + " DUU "

				cQuery +=  "WHERE DUU_FILIAL = '" + xFilial("DUU") + "' "
				cQuery +=    "AND DUU_FILDOC = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
				cQuery +=    "AND DUU_DOC    = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
				cQuery +=    "AND DUU_SERIE  = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
				cQuery +=    "AND DUU_STATUS = '1' "
				cQuery +=    "AND DUU_TIPPND NOT IN ('02') "
				cQuery +=    "AND D_E_L_E_T_   = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)   							

				If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(PNDABERTA) > 1
					lDesbloDoc := .F.
				EndIf

				(cAliasQry)->(DbCloseArea())

				nQuant := oMdFldDUU:GetValue("DUU_QTDOCO")
				lRet   := TM360AtuSal(oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),oMdFldDUU:GetValue("DUU_SERIE"),-nQuant,;
									"01",oMdFldDUU:GetValue("DUU_DATENC"),.F.,oMdFldDUU:GetValue("DUU_FILORI"),oMdFldDUU:GetValue("DUU_VIAGEM"),;
									.T.,DUU->(Recno()))

				If lRet
					If lDesbloDoc
						If !lBloqueado
							RecLock("DT6",.F.)
							DT6->DT6_BLQDOC := StrZero(2,Len(DT6->DT6_BLQDOC))	//-- Não Bloqueado
							DT6->(MsUnLock())
						EndIf
		
						If DT6->DT6_DOCTMS != "6"
							TMSAF89ASt(oMdFldDUU:GetValue("DUU_FILPND"),oMdFldDUU:GetValue("DUU_NUMPND"),oMdFldDUU:GetValue("DUU_CODOCO"),nOperation)
						EndIf
		
						If lRet .And. !lRetMer
							cAliasQry := GetNextAlias()
							cQuery := "SELECT DUD_FILORI,DUD_VIAGEM "
		
							cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "
		
							cQuery +=  "WHERE DUD_FILIAL  = '" + xFilial("DUD") + "' "
							cQuery +=    "AND DUD_FILDOC  = '" + oMdFldDUU:GetValue("DUU_FILDOC") + "' "
							cQuery +=    "AND DUD_DOC     = '" + oMdFldDUU:GetValue("DUU_DOC") + "' "
							cQuery +=    "AND DUD_SERIE   = '" + oMdFldDUU:GetValue("DUU_SERIE") + "' "
							cQuery +=    "AND (DUD_SERTMS = '" + StrZero(3,Len(DUD->DUD_SERTMS)) + "' "
							cQuery +=     "OR DUD_SERTMS  = '" + StrZero(2,Len(DUD->DUD_SERTMS)) + "') "
							cQuery +=    "AND DUD_STATUS  < '" + StrZero(4,Len(DUD->DUD_STATUS)) + "' "
							cQuery +=    "AND DUD.D_E_L_E_T_ = ' ' "
		
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
							If (cAliasQry)->(!Eof())
								lGeraDud := .F.
							EndIf
		
							(cAliasQry)->(DbCloseArea())
		
							If lGeraDud
								aAreaDUD := DUD->(GetArea())
								DUD->(DbSetOrder(1))
								
								lVigVazia := DUD->(DbSeek(xFilial("DUD") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
														oMdFldDUU:GetValue("DUU_SERIE") + oMdFldDUU:GetValue("DUU_FILORI") + Space(Len(DUU->DUU_VIAGEM))))
								
								If DUD->(DbSeek(xFilial("DUD") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
												oMdFldDUU:GetValue("DUU_SERIE") + oMdFldDUU:GetValue("DUU_FILORI") + ;
												oMdFldDUU:GetValue("DUU_VIAGEM"))) .And. DUD->DUD_STATUS != StrZero(9,Len(DUD->DUD_STATUS))
									RecLock("DUD",.F.)
									DUD->DUD_STATUS := StrZero(9,Len(DUD->DUD_STATUS))
									DUD->(MsUnLock())
								EndIf					 
								
								If !lVigVazia
									aCampos := {}
									If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. DT6->DT6_FILDES == cFilAnt
										lTransito := .F.
										cDUDStat := TMSAF89DUD(oMdFldDUU:GetValue("DUU_VIAGEM"),@lTransito,oMdFldDUU:GetValue("DUU_FILORI"))
										Aadd(aCampos,{"DUD_SERTMS",StrZero(3,Len(DUD->DUD_SERTMS))})
									ElseIf (DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS))) .Or. (oMdFldDUU:GetValue("DUU_TIPPND") == "99" .And. ;
											DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)))
										lTransito := .F.
										If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
											cDUDStat := TMSAF89DUD(oMdFldDUU:GetValue("DUU_VIAGEM"),@lTransito,oMdFldDUU:GetValue("DUU_FILORI"))
										EndIf
										Aadd(aCampos,{"DUD_FILORI",Iif(lTransito,DUD->DUD_FILORI,cFilAnt)})
									EndIf
									Aadd(aCampos,{"DUD_FILATU",Iif(lTransito,DUD->DUD_FILATU,cFilAnt)})
									Aadd(aCampos,{"DUD_STATUS",cDUDStat})
									Aadd(aCampos,{"DUD_MANIFE",Iif(lTransito,DUD->DUD_MANIFE,CriaVar("DUD_MANIFE",.F.))})
									Aadd(aCampos,{"DUD_SERMAN",Iif(lTransito,DUD->DUD_SERMAN,CriaVar("DUD_SERMAN",.F.))})
									Aadd(aCampos,{"DUD_FILMAN",Iif(lTransito,DUD->DUD_FILMAN,CriaVar("DUD_FILMAN",.F.))})
									Aadd(aCampos,{"DUD_VIAGEM",Iif(lTransito,DUD->DUD_VIAGEM,CriaVar("DUD_VIAGEM",.F.))})
									Aadd(aCampos,{"DUD_SEQUEN",Iif(lTransito,DUD->DUD_SEQUEN,CriaVar("DUD_SEQUEN",.F.))})
									AAdd(aCampos,{"DUD_DTRNPR",CriaVar("DUD_DTRNPR",.F.)})
									AAdd(aCampos,{"DUD_HRRNPR",CriaVar("DUD_HRRNPR",.F.)})
									AAdd(aCampos,{"DUD_USURNP",CriaVar("DUD_USURNP",.F.)})
									AAdd(aCampos,{"DUD_NOMUSU",CriaVar("DUD_NOMUSU",.F.)})
									If cEntAer == "1"	//-- Se a Entrega do Aereo for Feita no Rodoviário
										Aadd(aCampos,{"DUD_TIPTRA",StrZero(1,Len(DUD->DUD_TIPTRA))})
									EndIf
		
									If AllTrim(aCampos[1,1]) == "DUD_FILORI" .And. AllTrim(aCampos[1,2]) != "" .And. AllTrim(aCampos[1,2]) != Nil .And. ;
										!lTransito
										TmsCopyReg(aCampos)
									EndIf
		
									If lTransito
										RecLock("DT6",.F.)
										DT6->DT6_STATUS := StrZero(3,Len(DT6->DT6_BLQDOC))	//-- Em Transito
										DT6->(MsUnLock())
		
										If DUD->(DbSeek(xFilial("DUD") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
														oMdFldDUU:GetValue("DUU_SERIE") + oMdFldDUU:GetValue("DUU_FILORI") + ;
														oMdFldDUU:GetValue("DUU_VIAGEM"))) .And. DUD->DUD_STATUS = StrZero(9,Len(DUD->DUD_STATUS))
											RecLock("DUD",.F.)
											DUD->DUD_STATUS := cDUDStat
											DUD->(MsUnLock())
										EndIf
									EndIf
								EndIf
								RestArea(aAreaDUD)
							EndIf
						EndIf
					EndIf

					//-- Incluido tratamento para que ao encerrar uma pendência de BLOQUEIO gerado por uma ocorrência
					//-- de GERA PENDÊNCIA parcial o campo o seu DT6 seja liberado no campo BLQDOC, alteração feita
					//-- de acordo com alinhamento entre analista especialista em TMS e IP, mais informações no chamado: SDMQII.
					If (oMdFldDUU:GetValue("DUU_TIPPND") == "01" .Or. oMdFldDUU:GetValue("DUU_TIPPND") == "02" .Or. ;
					oMdFldDUU:GetValue("DUU_TIPPND") == "03" .Or. oMdFldDUU:GetValue("DUU_TIPPND") == "99") .And. !lDocEntre
						aAreaDT6 := DT6->(GetArea())
						If !lBloqueado
							If (DT6->DT6_VOLORI > DUA->DUA_QTDOCO)
								RecLock("DT6",.F.)
								DT6->DT6_BLQDOC := StrZero(2,Len(DT6->DT6_BLQDOC))	//-- Nao Bloqueado
								DT6->(MsUnLock())
							EndIf
						EndIf
						RestArea(aAreaDT6)
					EndIf

					//-- Atualiza Gestão de Demandas
					If nRadio == 1 .And. lITmsDmd
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.F.,,,.T.,.F.)
					EndIf

					//---- Encerra as Conciliações
					If cTMSCOSB != "0" .And. oMdFldDUU:GetValue("DUU_TIPPND") $ "01/03" 
						TMSAF89DYZ(nOperation,oMdFldDUU)
					EndIf

					//-- Opção de Gerar Outro Documento
					If nRadio == 1	//-- Somente Encerrar
						lRet := .T.
					ElseIf nRadio == 2	//-- Re-entregar
						SaveInter()
						cCadastro := STR0019	//-- "Manutenção de Documentos"
						lRet := TMSA500Mnt("DT6",DT6->(Recno()),5) != 0   
						If lDocRee .And. lRet .And. !lRetMer	//-- Pendência de Reentrega Encerra Movimento de Viagem
							DUD->(DbSetOrder(1))
							If DUD->(DbSeek(xFilial("DUD") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
											oMdFldDUU:GetValue("DUU_SERIE")))
								RecLock("DUD",.F.)
								DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS))	//-- Encerrado
								DUD->(MsUnLock())
							EndIf
						EndIf
						RestInter()
					ElseIf nRadio == 3	//-- Devolver
						SaveInter()
						cCadastro := STR0019	//-- "Manutenção de Documentos"
						lRet := TMSA500Mnt("DT6",DT6->(Recno()),4) != 0
						RestInter()
					EndIf

					nRadio  := 0
					lConAut := .F.
					If lRetMer 
						If lPergUsu
							TMSAF89Ret()
						EndIf
					EndIf
				EndIf
			EndIf

		ElseIf nOperation == 12 	//-- Estornar
			If oMdFldDUU:GetValue("DUU_STATUS") == StrZero(2,Len(DUU->DUU_STATUS))	//-- Indenização Solicitada
				nQuant := 0
				If !lDocEntre
					lRet := TM360AtuSal(oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),oMdFldDUU:GetValue("DUU_SERIE"),@nQuant,;
										"ES",,.F.,oMdFldDUU:GetValue("DUU_FILORI"),oMdFldDUU:GetValue("DUU_VIAGEM"),.T.,DUU->(Recno()))
				EndIf

			ElseIf oMdFldDUU:GetValue("DUU_STATUS") == StrZero(4,Len(DUU->DUU_STATUS))	//-- Encerrada
				DT6->(DbSetOrder(1))
				If DT6->(DbSeek(xFilial("DT6") + oMdFldDUU:GetValue("DUU_FILDOC") + oMdFldDUU:GetValue("DUU_DOC") + ;
								oMdFldDUU:GetValue("DUU_SERIE"))) .And. !lDocEntre
					nQuant := oMdFldDUU:GetValue("DUU_QTDOCO")
					lRet   := TM360AtuSal(oMdFldDUU:GetValue("DUU_FILDOC"),oMdFldDUU:GetValue("DUU_DOC"),oMdFldDUU:GetValue("DUU_SERIE"),@nQuant,;
										StrZero(6,Len(DT2->DT2_TIPOCO)),,.F.,oMdFldDUU:GetValue("DUU_FILORI"),oMdFldDUU:GetValue("DUU_VIAGEM"),;
										.T.,DUU->(Recno()),,nOperation)
					If lRet .And. nQuant == 0
						If !lBloqueado
							RecLock("DT6",.F.)
							DT6->DT6_BLQDOC := StrZero(1,Len(DT6->DT6_BLQDOC))	//-- Bloqueado
							DT6->(MsUnLock())
						EndIf	
					EndIf

					//-- Atualiza Gestão de Demandas
					If nRadio == 1 .And. lITmsDmd
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.T.,,,.T.,.F.)
					EndIf
				EndIf
			EndIf			

			TMSAF89ASt(oMdFldDUU:GetValue("DUU_FILPND"),oMdFldDUU:GetValue("DUU_NUMPND"),oMdFldDUU:GetValue("DUU_CODOCO"),nOperation) 

			//-- Encerra as Conciliações
			If cTMSCOSB != "0" .And. oMdFldDUU:GetValue("DUU_TIPPND") $ "01/03" 
				TMSAF89DYZ(nOperation,oMdFldDUU)
			EndIf		
		EndIf
	EndIf
	
	If lRet
		lRet:= FwFormCommit(oModel)
	EndIf

	If lRet
		//-- Complementa dados da DUU e DUB
		RecLock("DUU",.F.)
		If nOperation == 11 	//-- Encerrar
			DUU->DUU_STATUS := StrZero(4,Len(DUU->DUU_STATUS))	//-- Encerrada
			MSMM(DUU->DUU_CODMTV,80,,oMdFldDUU:GetValue("DUU_MOTIVO"),1,,,"DUU","DUU_CODMTV")
			MSMM(DUU->DUU_CODENC,80,,oMdFldDUU:GetValue("DUU_OBSENC"),1,,,"DUU","DUU_CODENC")
		ElseIf nOperation == 12 	//-- Estornar
			DUU->DUU_STATUS := StrZero(1,Len(DUU->DUU_STATUS))	//-- Em Aberto
			DUU->DUU_FILRID := Space(Len(DUU->DUU_FILRID))
			DUU->DUU_NUMRID := Space(Len(DUU->DUU_NUMRID))
			DUU->DUU_DATENC := Ctod("")
			DUU->DUU_HORENC := Space(Len(DUU->DUU_HORENC))
			DUU->DUU_CODMTC := ""
			MSMM(DUU->DUU_CODMTV,,,,2)
			MSMM(DUU->DUU_CODENC,,,,2)

			DUB->(DbSetOrder(2))
			If DUB->(DbSeek(xFilial("DUB") + oMdFldDUU:GetValue("DUU_FILRID") + oMdFldDUU:GetValue("DUU_NUMRID")))
				//-- Exclui motivo
				MSMM(DUB->DUB_CODMTV,,,,2)
				//-- Exclui registro de indenização
				RecLock("DUB",.F.)
				DUB->(DbDelete())
				DUB->(MsUnLock())
			EndIf
		EndIf
		DUU->(MsUnlock())
	Else
		DisarmTransaction()
		Break
	EndIf

End Transaction

nRadio := 0

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} TMSAF89Doc
    Define o que Será Feito com o Documento
    @type Function
    @author Valdemar Roberto Mognon
    @since 14/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Doc()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Doc()
Local nOpca   := 0
Local oRadio
Local oDlgRet
Local oBotao

nRadio := 1

While nOpca == 0
	Define MsDialog oDlgRet Title STR0014 From 09,0 To 18,37 Of oMainWnd	//-- "Opção"
	Define FONT oBold NAME "Arial" Size 0, -13 BOLD

	@ 03,14 Say STR0015 FONT oBold Pixel	//-- "Selecione a opção desejada:"
	@ 14,00 To 16,400 LABEL "" Of oDlgRet Pixel
	@ 20,40 Radio oRadio Var nRadio 3D Size 70, 11 PROMPT STR0016,STR0017,STR0018 of oDlgRet Pixel	//-- "Somente Encerrar" ### "Re-Entregar" ### "Devolver"

	oRadio:SetEnable( .T. )
	
	Define SButton oBotao From 055, 061 Type 1 Action (nOpca := 1,oDlgRet:End()) Enable of oDlgRet
   
	oBotao:SetFocus()
	
	Activate MsDialog oDlgRet Centered
  		
	If nOpca == 1
  	 	Exit
  	EndIf
EndDo

Return nRadio

/*{Protheus.doc} TMSAF89DUD
    Define o Novo Status da DUD
    @type Function
    @author Valdemar Roberto Mognon
    @since 14/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89DUD()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89DUD(cViagem,lTransito,cFilOri)
Local aAreas := {DTQ->(GetArea()),GetArea()}
Local cRet   := "1"

Default cViagem   := ""
Default lTransito := .F.
Default cFilOri   := ""

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem)) .And. DTQ->DTQ_STATUS $ "1:2:5"
	lTransito := .T.
	If DTQ->DTQ_STATUS = "2"
		cRet := "2"
	ElseIf DTQ->DTQ_STATUS $ "1:5"
		cRet := "3"
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return cRet

/*{Protheus.doc} TMSAF89Ret
    Exibição da Tela Para Escolha de uma Ação Após a Ocorrência de Retorno de Mercadoria
    @type Function
    @author Valdemar Roberto Mognon
    @since 14/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89Ret()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Ret()
Local oDlgRet
Local oBotao1
Local oBotao2
Local oBotao3

//-- Variáveis para Uso no TMSA050
Private cNumLotUso := CriaVar("DTC_LOTNFC",.F.)
Private Inclui     := .T.

Define MsDialog oDlgRet Title STR0019 FROM 06,0 TO 20,61 OF oMainWnd	//-- "Pendência de Retorno de Mercadoria"
	Define FONT oBold NAME "Arial" Size 0, -13 BOLD
	
	//-- "A Pendência de (Retorno de Mercadoria) foi encerrada com sucesso. "
	//-- "Escolha a ação a ser realizada para a mercadoria através dos botões abaixo."
	@ 01,01 Say STR0020 + CHR(13) + CHR(10) + STR0021
	@ 02,01 To 87,243 LABEL "" Of oDlgRet Pixel
	
	oBotao2 := TButton():New(090,156,STR0022,oDlgRet,{|| TMSA050Mnt("DTC",0,3,.T.)},40,15,,,.F.,.T.,.F.,,.F.,,,.F.)		//-- "Entrada Dc.Cli."
	oBotao1 := TButton():New(090,111,STR0023,oDlgRet,{|| Tmsa460Mnt("DT5",0,3 )},40,15,,,.F.,.T.,.F.,,.F.,,,.F.) 		//-- "Solict.Coleta"
	oBotao3 := TButton():New(090,201,STR0024,oDlgRet,{|| oDlgRet:End()},40,15,,,.F.,.T.,.F.,,.F.,,,.F.)					//-- "Fechar"
	
	oBotao1:SetFocus()
Activate MsDialog oDlgRet Centered  

Return NIL

/*{Protheus.doc} TMSAF89ASt
    Altera Status da NF
    @type Function
    @author Valdemar Roberto Mognon
    @since 14/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89ASt()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89ASt(cFilPnd,cNumPnd,cCodOco,nOperation)
Local aAreas    := {DT2->(GetArea()),DTC->(GetArea()),GetArea()}
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := "" 

Default cFilPnd    := ""
Default cNumPnd    := ""
Default nOperation := 0
Default cCodOco    := ""

//-- A tela de notas fiscais pendentes não é exibida para tipos de pendência diferentes de 01,02 e 04,
//-- com isso a validação abaixo é feita apenas para pendências tipo 01,02,04 e 06.
DT2->(DbSetOrder(1))
If DT2->(DbSeek(xFilial("DT2") + cCodOco))
	If (DT2->DT2_TIPOCO == "01" .Or. DT2->DT2_TIPOCO == "02" .Or. DT2->DT2_TIPOCO == "04" .Or. DT2->DT2_TIPOCO == "06")

		cAliasQry := GetNextAlias()
		cQuery := "SELECT DTC.R_E_C_N_O_ RECDTC "

		cQuery +=   "FROM " + RetSqlName("DV4") + " DV4 "

		cQuery +=  "INNER JOIN " + RetSqlName("DTC") + " DTC "
		cQuery +=     "ON DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery +=    "AND DTC_FILDOC = DV4_FILDOC "
		cQuery +=    "AND DTC_DOC    = DV4_DOC "
		cQuery +=    "AND DTC_SERIE  = DV4_SERIE "
		cQuery +=    "AND DTC_NUMNFC = DV4_NUMNFC "
		cQuery +=    "AND DTC_SERNFC = DV4_SERNFC "
		cQuery +=    "AND DTC.D_E_L_E_T_ = ' ' "

		cQuery +=  "WHERE DV4_FILIAL = '" + xFilial("DV4") + "' "
		cQuery +=    "AND DV4_FILPND = '" + cFilPnd + "' "
		cQuery +=    "AND DV4_NUMPND = '" + cNumPnd + "' "
		cQuery +=    "AND DV4.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
		//-- Caso a query padrão não localize registros, é chamada uma segunda exclusiva para casos de reentrega
		If (cAliasQry)->(Eof()) .And. lDocRee .And. (DT2->DT2_TIPOCO == "04" .Or. DT2->DT2_TIPOCO == "06")
			(cAliasQry)->(DbCloseArea())
			cAliasQry := GetNextAlias()
			
			cQuery := "SELECT DTC.R_E_C_N_O_ RECDTC "

			cQuery +=   "FROM " + RetSqlName("DUU") + " DUU "

			cQuery +=  "INNER JOIN " + RetSqlName("DTC") + " DTC "
			cQuery +=     "ON DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery +=    "AND DTC_FILDOC = DUU_FILDOC "
			cQuery +=    "AND DTC_DOC    = DUU_DOC "
			cQuery +=    "AND DTC_SERIE  = DUU_SERIE "
			cQuery +=    "AND DTC.D_E_L_E_T_ = ' ' "

			cQuery +=  "WHERE DUU_FILIAL = '" + xFilial("DUU") + "' "
			cQuery +=    "AND DUU_FILPND = '" + cFilPnd + "' "
			cQuery +=    "AND DUU_NUMPND = '" + cNumPnd + "' "  
			cQuery +=    "AND DUU.D_E_L_E_T_ = ' ' "
	
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		EndIf		

		While (cAliasQry)->(!Eof())
			DTC->(DbGoTo((cAliasQry)->(RECDTC)))

			RecLock("DTC",.F.)
			If nOperation == 10
				DTC->DTC_NFENTR := "1"
			ElseIf (nOperation == 11) .And. DTC->DTC_NFENTR != "1" 
				DTC->DTC_NFENTR := "2"
				If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND == "04"
					DTC->DTC_DOCREE := "2"
				EndIf
			ElseIf nOperation == 12 .And. DTC->DTC_NFENTR != "1" 
				DTC->DTC_NFENTR := "3"
				If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND == "04"
					DTC->DTC_DOCREE := "1"
				EndIf
			EndIf
			DTC->(MsUnlock())

			lRet := .T.
			
			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())
	Else
		lRet := .T.
	EndIf
EndIf

If !lRet
	If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND $ "03:02"	//-- Pendência Sobra ou Avaria
		lRet:= .T.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} TMSAF89DYZ
    Atualizacao dos Registros de Conciliação
    @type Function
    @author Valdemar Roberto Mognon
    @since 14/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89DYZ()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89DYZ(nOperation,oMdFldDUU)
Local aAreas    := {GetArea()}
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

Default nOperation := 0

cAliasQry := GetNextAlias()

If nOperation == 10 .Or. nOperation == 11	//-- Indenizar ou Encerrar 
	cQuery := "UPDATE " + RetSqlName("DYZ") + " "
	cQuery +=    "SET DYZ_STACON = '5',DYZ_CODMTC = '" + oMdFldDUU:GetValue("DUU_CODMTC") + "'," + "DYZ_DATCON = " + Dtos(dDataBase) + " "
	cQuery +=  "WHERE DYZ_FILIAL = '" + xFilial("DYZ") + "' "
	cQuery +=    "AND DYZ_FILPND = '" + oMdFldDUU:GetValue("DUU_FILPND") + "' "
	cQuery +=    "AND DYZ_NUMPND = '" + oMdFldDUU:GetValue("DUU_NUMPND") + "' "
	cQuery +=    "AND DYZ_STACON = '1' "	//-- Pendente
	cQuery +=    "AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
ElseIf nOperation == 12	//-- Estornar
	cQuery := "UPDATE " + RetSqlName("DYZ")
	cQuery +=    "SET DYZ_STACON   = '1',DYZ_CODMTC = ' ',DYZ_DATCON = ' ' "
	cQuery +=  "WHERE DYZ_FILIAL = '" + xFilial("DYZ") + "' "
	cQuery +=    "AND DYZ_FILPND = '" + oMdFldDUU:GetValue("DUU_FILPND") + "' "
	cQuery +=    "AND DYZ_NUMPND = '" + oMdFldDUU:GetValue("DUU_NUMPND") + "' "
	cQuery +=    "AND DYZ_STACON = '5' "	//-- Encerrado
	cQuery +=    "AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
Else
	cQuery := "SELECT COUNT(*) NTOTREG "

	cQuery +=   "FROM " + RetSqlName("DYZ")

	cQuery +=  "WHERE DYZ_FILIAL ='" + xFilial("DYZ") + "' "
	cQuery +=    "AND DYZ_FILPND ='" + oMdFldDUU:GetValue("DUU_FILPND") + "' "
	cQuery +=    "AND DYZ_NUMPND ='" + oMdFldDUU:GetValue("DUU_NUMPND") + "' "
	cQuery +=    "AND DYZ_STACON = '1' "	//-- Pendente
	cQuery +=    "AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->NTOTREG > 0
		lRet:= .F.
	EndIf

	(cAliasQry)->(DbCloseArea())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} TMSAF89NFA
    Visualiza as Notas Fiscais com Avaria
    @type Function
    @author Valdemar Roberto Mognon
    @since 13/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89NFA()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89NFA(oModel)
Local aAreas     := {DUA->(GetArea()),GetArea()}
Local aNoFields  := {}
Local aYesFields := {}
Local nOperation := 0
Local oMdFldDUU

//-- Variáveis do Registro de Ocorrências
Private cCadastro := STR0026	//-- "Notas Fiscais com Avaria"
Private n          := 1
Private aHeaderDV4 := {}
Private aHeader    := {}
Private aCols      := {}
Private aNFAvaria  := {}
Private aIdProduto := {}
Private aHeaderDYM := {}

Default oModel := FWModelActive()

oMdFldDUU := oModel:GetModel("MdFieldDUU")

DUA->(DbSetOrder(6))
If DUA->(DbSeek(xFilial("DUA") + oMdFldDUU:GetValue("DUU_FILPND") + oMdFldDUU:GetValue("DUU_NUMPND")))
	//-- Prepara aCols e aHeader do TMSA360
	nOperation := oMdFldDUU:GetOperation()
	
	If nRotExt != 0
		nOperation := nRotExt
	EndIf
	
	Aadd(aNoFields,"DUA_FILOCO")
	Aadd(aNoFields,"DUA_NUMOCO")
	Aadd(aNoFields,"DUA_FILORI")
	Aadd(aNoFields,"DUA_VIAGEM")
	Aadd(aNoFields,"DUA_NUMROM")
	Aadd(aNoFields,"DUA_IDENT" )
	Aadd(aNoFields,"DUA_CODCAR")
	Aadd(aNoFields,"DUA_SEQCAR")
	Aadd(aNoFields,"DUA_TIPUSO")
	Aadd(aNoFields,"DUA_ESTOCO")
	Aadd(aNoFields,"DUA_SERTMS")
	Aadd(aNoFields,"DUA_NUMROM")
	
	TMSFillGetDados(nOperation,"DUA",1,xFilial("DUA") + DUA->DUA_FILOCO + DUA->DUA_NUMOCO + DUA->DUA_FILORI + DUA->DUA_VIAGEM,;
								  {|| DUA->DUA_FILIAL + DUA->DUA_FILOCO + DUA->DUA_NUMOCO + DUA->DUA_FILORI + DUA->DUA_VIAGEM},;
								  {|| .T.},aNoFields,aYesFields)

	//-- Executa Chamadas do TMSA360	
	TMSA360CarNF(DUA->DUA_FILOCO,DUA->DUA_NUMOCO,,oMdFldDUU:GetValue("DUU_FILPND"),oMdFldDUU:GetValue("DUU_NUMPND"))
	
	TMSA360NF(DUA->DUA_FILOCO,DUA->DUA_NUMOCO,2)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSAF89CON
    Visualiza Conciliação
    @type Function
    @author Valdemar Roberto Mognon
    @since 13/01/2025
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF89CON()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89CON(oModel,cNumNFc,cSerNFc)
Local aAreas    := {DYM->(GetArea()),DYZ->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasQry := ""
Local cStaCon   := ""
Local lRet      := .F.

Default oModel  := FWModelActive()
Default cNumNFc := ""
Default cSerNFc := ""

//--- Para visualizar a conciliação, busca sempre a ultima Conciliação efetuada da Pendencia,
//--- No caso de Notas, deve-se utilizar a opção Visualizar Conciliação dentro da opção NF Avaria.          

cAliasQry := GetNextAlias()
cQuery := "SELECT DYZ.R_E_C_N_O_ RECDYZ,DYZ_DATCON,DYM.R_E_C_N_O_ RECDYM "

cQuery +=   "FROM " + RetSqlName("DYZ") + " DYZ " 

cQuery +=  "INNER JOIN " + RetSqlName("DYM") + " DYM " 
cQuery +=     "ON DYM_FILIAL = '" + xFilial("DYM") + "' "
cQuery +=    "AND DYM_FILPND = '" + DUU->DUU_FILPND + "' "
cQuery +=    "AND DYM_NUMPND = '" + DUU->DUU_NUMPND + "' "
If !Empty(cNumNfc)
	cQuery +=    "AND DYM_NUMNFC = '" + cNumNfc + "' "
	cQuery +=    "AND DYM_SERNFC = '" + cSerNfc + "' "
EndIf
cQuery +=    "AND DYM.D_E_L_E_T_ = ' ' "

cQuery +=  "WHERE DYZ_FILIAL = '" + xFilial("DYZ") + "' "
cQuery +=    "AND DYZ_FILPND = '" + DUU->DUU_FILPND + "' "
cQuery +=    "AND DYZ_NUMPND = '" + DUU->DUU_NUMPND + "' "
If !Empty(cNumNfc)
	cQuery +=    "AND DYZ_NUMNFC = '" + cNumNfc + "' "
	cQuery +=    "AND DYZ_SERNFC = '" + cSerNfc + "' "
EndIf	
cQuery +=    "AND DYZ.D_E_L_E_T_ = ' ' "

cQuery +=  "ORDER BY DYZ_DATCON DESC "
		
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
If (cAliasQry)->(!Eof()) .And. (cAliasQry)->RECDYZ > 0
	DYZ->(DbGoto((cAliasQry)->RECDYZ))
	DYM->(DbGoto((cAliasQry)->RECDYM))
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

If lRet
	If DYZ->DYZ_STACON == "4"	//-- Conciliado Item
		cStaCon := "3"			//-- Conciliado
	Else
		cStaCon := DYZ->DYZ_STACON
	EndIf

	If cStaCon == "3"	//-- Posiciona no registro principal
		DYZ->(DbSetOrder(2))  
		DYZ->(DbSeek(xFilial("DYZ")+ DYZ->DYZ_FILCON + DYZ->DYZ_NUMCON + cStaCon ))
	EndIf	
	
	//-- Enviar Recno para que nao haja problema na visualizacao da ID. Produto da rotina
	If !Empty(cStaCon)
		TMSA541Mnt("DYZ",DYZ->(RECNO()),2)
	EndIf    
EndIf

nRotExt := 0

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSAF89Get
    Exporta conteúdo de variável estática
    @type Function
    @author Valdemar Roberto Mognon
    @since 01/02/2025
    @version P12 R12.1.29
    @param cVar
    @return Conteúdo da cVar
    @example TMSAF89Get()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Get(cVar)

Return &(cVar)

/*{Protheus.doc} TMSAF89Set
    Importa conteúdo para variável estática
    @type Function
    @author Valdemar Roberto Mognon
    @since 01/02/2025
    @version P12 R12.1.29
    @param cVar,xCont
    @return
    @example TMSAF89Set()
    (examples)
    @see (links_or_references)
*/
Function TMSAF89Set(cVar,xCont)

&(cVar) := xCont

Return
