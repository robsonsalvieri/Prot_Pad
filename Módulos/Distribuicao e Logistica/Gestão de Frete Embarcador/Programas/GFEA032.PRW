#INCLUDE "GFEA032.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE GFEA032001 'GFEA032001'
#DEFINE GFEA032002 'GFEA032002'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GFEA032  ³ Autor ³ Luiz Fernando Soares  ³ Data ³ 25.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Registro de Ocorrencia                                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GFEA032()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 			 ³        ³XXXXXX³	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/**/

Static s_VLCNPJ  := SuperGetMV('MV_VLCNPJ',,'1')
Static _lGWL_SEQ := GFXCP12125("GWL_SEQ")

Function GFEA032()
	Local oBrowse
	Private cAliGWU
	Private _CodDocTransp
	Private aCalc 	 := {}
	Private aRotina  := MenuDef()
	Private lCopy    := .F.
	Private lAltOcor := .F.

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWD")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA032")	//  Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0044)	//"Registrar Ocorrência"
	oBrowse:SetProfileID("3")
	oBrowse:AddLegend("GWD_SIT=='1'", "BLUE"  , STR0001 )	//"Pendente"
	oBrowse:AddLegend("GWD_SIT=='2'", "GREEN" , STR0002 )	//"Aprovada"
	oBrowse:AddLegend("GWD_SIT=='3'", "RED"   , STR0003 )	//"Reprovada"

	oBrowse:Activate()

	If !Empty(Select(cAliGWU))
		GFEDelTab(cAliGWU)
	EndIf

Return Nil

//---------------------------------------------------------------------//
//------------------------- Funcao MenuDEF ----------------------------//
//--------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina := {}
	Local s_GFEA0322 := ExistBlock("GFEA0322")

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	AAdd(aRotina, {STR0004, 'AxPesqui'       , 0, 1 , 0, .F.}) // Buscar
	AAdd(aRotina, {STR0005, "VIEWDEF.GFEC032", 0, 2 , 0, .F.}) // Visualizar
	AAdd(aRotina, {STR0006, "GFEA032INC()", 0, 3 , 0, .F.}) // Incluir
	AAdd(aRotina, {STR0007, "GFEA032ALT()"   , 0, 4 , 0, .F.}) // Modificar
	AAdd(aRotina, {STR0061, "GFEA032DEL()"   , 0, 5 , 0, .F.}) // Excluir // É proposital para aproveitar a viewdef do GFEC032
	AAdd(aRotina, {STR0008, "GFE032COPY()"   , 0, 9 , 0, .F.}) // Copiar
	AAdd(aRotina, {STR0009, "GFEA032APR()"   , 0, 11, 0, .F.}) // Aprovar/Reprovar
	AAdd(aRotina, {STR0062, "GFEA032CAN()"   , 0, 4 , 0, .F.}) // Cancelar Aprov/Reprov
	AAdd(aRotina, {STR0063, "GFEA032SIM()"   , 0, 4 , 0, .F.}) // Simular
	AAdd(aRotina, {"Cancelar/Excluir em Lote", "GFEA032LOT()"   , 0, 4 , 0, .F.}) //
	AAdd(aRotina, {STR0010, "VIEWDEF.GFEA032", 0, 8 , 0, .F.}) // Imprimir
	AAdd(aRotina, {STR0064, "MsDocument('GWD',GWD->(RecNo()), 4)",  0, 4 , 0, .F.}) // Documentos
	
	If SuperGetMv("MV_TMS2GFE", .F. , .F.)
		AAdd(aRotina, {STR0065, "GFE032TMSINT()", 0, 12, 0, .F.}) // Enviar TMS
	EndIf

	If s_GFEA0322
		aRotAdic := ExecBlock("GFEA0322 ",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
	Local oModel
	Local cCdTipo    := Nil
	Local oStructGWD := FWFormStruct(1, "GWD")
	Local oStructGWL := FWFormStruct(1, "GWL")

	Default lAltOcor := .F.

	// Incluindo campo de Sequência para o Trecho
	If !_lGWL_SEQ
		oStructGWL:AddField ("Sequência Trecho", "Sequência Trecho", "GWL_SEQ", "C", TamSX3("GWU_SEQ")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.T.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	EndIf

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA032", /*bPre*/, {|oModel| GFEA032VAL(oModel)}/* bPost*/, {|oModel| GFEA032CMT(oModel)}, /*bCancel*/)

	If GFXCP12130("GWD_URLENT") .And. !isBlind()
		cCdTipo := iif(lAltOcor, GWD->GWD_CDTIPO,"")
		oStructGWD:SetProperty("GWD_URLENT", MODEL_FIELD_WHEN , {|| GFE032WHEN(cCdTipo)})
	EndIf

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA032_GWD", Nil, oStructGWD,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid("GFEA032_GWL","GFEA032_GWD", oStructGWL,/*bLinePre*/,{|oModel| GFEA032VB(oModel)} /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation("GFEA032_GWL",{{"GWL_FILIAL",'xFilial("GWD")'},{"GWL_NROCO","GWD_NROCO"}},"GWL_FILIAL+GWL_NROCO")

	oModel:SetPrimaryKey({"GWD_FILIAL", "GWD_NROCO"})

	oModel:GetModel("GFEA032_GWL"):SetUniqueLine({"GWL_FILDC", "GWL_TPDC", "GWL_EMITDC", "GWL_SERDC", "GWL_NRDC", "GWL_SEQ"})
	oModel:GetModel("GFEA032_GWL"):SetDelAllLine(.T.)
	oModel:SetOptional("GFEA032_GWL", .T.)
	oModel:SetVldActivate({|oModel| GFEA032VAC(oModel)})
	oModel:SetActivate({|oModel| GFEA032ACT(oModel)})
Return oModel

Function GFEA032VAC(oModel)
	Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If GWD->GWD_SIT == '2'
			Help(,,'HELP',, "Para excluir a ocorrência, é necessário efetuar o cancelamento da aprovação.",1,0)
			lRet := .F.
		EndIf

		If GWD->GWD_SIT == '3'
			Help(,,'HELP',, "Para excluir a ocorrência, é necessário efetuar o cancelamento da reprovação.",1,0)
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------//

Function GFEA032ACT(oModel)
	Local aAreaGWE  := {}
	Local aAreaGWU  := {}
	Local lCpoSrGW1 := GfeVerCmpo({"GW1_SDOC"})

	If IsInCallStack("GFEA044") .Or. IsInCallStack("GFEC041") .Or. IsInCallStack("GFEC054")

		oModel:GetModel("GFEA032_GWD"):SetValue("GWD_CDTRP" , GWU->GWU_CDTRP)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_NRDC"  , GWU->GWU_NRDC)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_FILDC" , GWU->GWU_FILIAL)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_EMITDC", GWU->GWU_EMISDC)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SERDC" , GWU->GWU_SERDC)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_TPDC"  , GWU->GWU_CDTPDC)
		oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SEQ"   , GWU->GWU_SEQ)

		If lCpoSrGW1
			oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SDOCDC", GWU->GWU_SDOC)
		EndIf

		If SuperGetMv("MV_TMS2GFE",.F.,.F.)
			aAreaGWE := GWE->(GetArea())

			If IsInCallStack("GFEC054")
				dbSelectArea("GWE")
				GWE->(dbSetOrder(1))
				If !Empty(_CodDocTransp) .And. GWE->(dbSeek(GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC)))
					_CodDocTransp := GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
				EndIf
			Endif

			If IsInCallStack("GFEC054OCO")

				aAreaGWU := GWU->(GetArea())

				GWE->(dbSetOrder(2))
				GWE->(dbSeek(_CodDocTransp))

				dbSelectArea("GWU")
				GWU->(dbSetOrder(1))
				Do While !GWE->(Eof()) .And. GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT) == _CodDocTransp
					If GWU->(dbSeek(GWE->(GWE_FILIAL+GWE_CDTPDC+GWE_EMISDC+GWE_SERDC+GWE_NRDC))) ;
							.And. oModel:GetModel("GFEA032_GWD"):GetValue("GWD_CDTRP") == GWU->GWU_CDTRP; //Mesmo Transportador
						.And. !GFEA32SKDC() // Não está no model ainda
						oModel:GetModel("GFEA032_GWL"):AddLine()
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_NRDC"  , GWU->GWU_NRDC)
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_FILDC" , GWU->GWU_FILIAL)
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_EMITDC", GWU->GWU_EMISDC)
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SERDC" , GWU->GWU_SERDC)
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_TPDC"  , GWU->GWU_CDTPDC)
						oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SEQ"   , GWU->GWU_SEQ)
						If lCpoSrGW1
							oModel:GetModel("GFEA032_GWL"):SetValue("GWL_SDOCDC", GWU->GWU_SDOC)
						EndIf
					EndIf
					GWE->(dbSkip())
				EndDo
				RestArea(aAreaGWU)
			EndIf
			RestArea(aAreaGWE)
		EndIf
	EndIf

	If IsInCallStack("GFEA032") .And. lCopy
		oModel:LoadValue("GFEA032_GWD","GWD_SIT","1")
		lCopy := .F.
	EndIf
Return .T.

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
	Local oModel      := FWLoadModel("GFEA032")
	Local oStructGWD  := FWFormStruct(2, "GWD")

	Static nValorTot  := 0
	Static oBrwGWU    := Nil
	Static cFilGWU    := Nil
	Static oViewOco   := NIL
	Static cGWUFil    := GetNextAlias()
	Static nBrwGWUEve := 0 //Auxiliar para "adivinhar" se o usuário pressionou botão "Salvar" ou "Salvar e Criar novo"
	Static lFuncSLC   := .F.
	Static lPergSLC   := .F.

	Pergunte("GFEA032", .F.)

	oStructGWD:RemoveField("GWD_NMCLI")

	oStructGWD:AddGroup("GrpId" , "Identificação", "2", 2)
	oStructGWD:AddGroup("GrpReg", "Registro", "2", 2)
	oStructGWD:AddGroup("GrpGen", "Generalidades", "2", 2)
	oStructGWD:AddGroup("GrpPP" , "Pátios e Portarias", "2", 2)

	oStructGWD:AddGroup("GrpGer", "Gerais", "2", 2)
	oStructGWD:AddGroup("GrpApr", "Aprovação", "2", 2)

	oStructGWD:AddGroup("GrpInt" , "Integrações", "2", 2)

	oStructGWD:SetProperty("GWD_NROCO" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_CDTRP" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_NMTRP" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpId")

	oStructGWD:SetProperty("GWD_DSOCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSOCOR" , MVC_VIEW_ORDEM, "01")
	oStructGWD:SetProperty("GWD_CDTIPO", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_CDTIPO" , MVC_VIEW_ORDEM, "02")
	oStructGWD:SetProperty("GWD_DSTIPO", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSTIPO" , MVC_VIEW_ORDEM, "03")
	oStructGWD:SetProperty("GWD_CDMOT" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_CDMOT" , MVC_VIEW_ORDEM, "04")
	oStructGWD:SetProperty("GWD_DSMOT" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSMOT" , MVC_VIEW_ORDEM, "05")

	If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_PRESTS"}) != 0
		oStructGWD:SetProperty("GWD_PRESTS" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_PRESTS" , MVC_VIEW_ORDEM, "06")
	EndIf
	If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_DESPRE"}) != 0
		oStructGWD:SetProperty("GWD_DESPRE" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_DESPRE" , MVC_VIEW_ORDEM, "07")
	EndIf

	If GFXCP12121("GWD_CDREC") .And. GFXCP12121("GWD_NMREC")
		oStructGWD:SetProperty("GWD_CDREC" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_NMREC" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	EndIf

	If GFXCP12130("GWD_URLENT")
		oStructGWD:SetProperty("GWD_URLENT", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	EndIf

	oStructGWD:SetProperty("GWD_DSPROB", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_NMCONT", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DTOCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_HROCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")

	oStructGWD:SetProperty("GWD_QTPERN", MVC_VIEW_GROUP_NUMBER, "GrpGen")
	oStructGWD:SetProperty("GWD_QTPERN" , MVC_VIEW_ORDEM, "01")
	oStructGWD:SetProperty("GWD_QTDVOL", MVC_VIEW_GROUP_NUMBER, "GrpGen")
	oStructGWD:SetProperty("GWD_QTDVOL" , MVC_VIEW_ORDEM, "02")

	If GFXCP12121("GWD_PESO") .And. GFXCP12121("GWD_VALIND")
		oStructGWD:SetProperty("GWD_PESO", MVC_VIEW_GROUP_NUMBER, "GrpGen")
		oStructGWD:SetProperty("GWD_PESO" , MVC_VIEW_ORDEM, "03")
		oStructGWD:SetProperty("GWD_VALIND", MVC_VIEW_GROUP_NUMBER, "GrpGen")
		oStructGWD:SetProperty("GWD_VALIND" , MVC_VIEW_ORDEM, "04")
	EndIf

	If GFXCP12121("GWD_MAXQBR")
		oStructGWD:RemoveField("GWD_MAXQBR")
	EndIf

	oStructGWD:SetProperty("GWD_NRMOV" , MVC_VIEW_GROUP_NUMBER, "GrpPP")
	oStructGWD:SetProperty("GWD_CDPTCT", MVC_VIEW_GROUP_NUMBER, "GrpPP")

	oStructGWD:SetProperty("GWD_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_HRCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_ACAODF", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_ACAODC", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_USUCRI", MVC_VIEW_GROUP_NUMBER, "GrpGer")

	oStructGWD:SetProperty("GWD_DSSOLU", MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_DTBAI" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_HRBAI" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_USUBAI", MVC_VIEW_GROUP_NUMBER, "GrpApr")

	If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_SITTMS"}) != 0
		oStructGWD:SetProperty("GWD_SITTMS" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		oStructGWD:SetProperty("GWD_DTTMS" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		oStructGWD:SetProperty("GWD_MOTTMS" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_CHVEXT"}) != 0
			oStructGWD:SetProperty("GWD_CHVEXT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		EndIf
	EndIf

	If IsInCallStack("GFEA044") .Or. IsInCallStack("GFEC041") .Or. IsInCallStack("GFEC054")
		oStructGWD:SetProperty("GWD_CDTRP", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	oViewOco := FWFormView():New()

	oViewOco:SetModel(oModel)

	oViewOco:AddField("GFEA032_GWD", oStructGWD, /*cLinkID*/)

	oViewOco:AddOtherObject("GFEA032_GWL", {|oPanel, oObj| GFEA032GWL(oPanel, oObj)},,{|oPanel| oBrwGWU:Refresh()})

	oViewOco:SetFieldAction("GWD_CDTRP", {|oView, cIdView, cField, cValue| GFEA32LOAD(oView, cValue, .T.)})

	oViewOco:CreateHorizontalBox("MASTER", 55)
	oViewOco:CreateHorizontalBox("DETAILGWL", 45)

	oViewOco:SetOwnerView("GFEA032_GWD", "MASTER")
	oViewOco:SetOwnerView("GFEA032_GWL", "DETAILGWL")
	oViewOco:SetAfterOkButton({|oView| GFEA032ASav()})
	oViewOco:SetViewAction("BUTTONOK", {|oView| GFEA032Sav()})
	oViewOco:SetViewAction("BUTTONCANCEL", {|oView| GFEA032Fec()})

	oViewOco:AddUserButton(STR0012, 'GCTIMG32', {|oView| GFEADCOK(oView)}) //"Doc. Relac."
Return oViewOco

//-------------------------------------------------------------------
//Alterar o controle para 2 quando for pressionado botão de Salvar
Function GFEA032Sav()
	nBrwGWUEve := 2
Return

//-------------------------------------------------------------------
//Se for selecionada a opção Salvar e Criar novo, o evento AfterOK do Grid não é executado.
//Assim, o valor de nBrwGWUEve continua com 2 e o grid dos trechos não é recriado. 
//Se for selecionada a opção Salvar, o evento AfterOK do Grid é executado e na próxima 
//inclusão o grid será criado.
Function GFEA032ASav()
	If nBrwGWUEve == 2
		nBrwGWUEve := 0
	EndIf
Return .T.

Function GFEA032Fec()
	nBrwGWUEve := 0
Return

//-------------------------------------------------------------------

Function GFEA32LOAD(oView, cValue, lChange, lPergunte)
	Local nTot       := 0
	Local nOp        := oView:GetModel():GetOperation()
	Local nI         := 1
	Local lDisable   := .T.
	Local aRom       := {}
	Local lOp        := .F.
	Local aStruct    := {{"GWU_OK", "C", 2, 0}}
	Local aTmpStru   := {}
	Local lExistVol  := GfeVerCmpo({"GWD_QTDVOL"})
	Local lCpoSrGW1  := GfeVerCmpo({"GW1_SDOC"})
	Local cCpoSrGWU  := SerieNfId('GWU',3,'GWU_SERDC')
	Local aAreaCGWU  := {}
	Local s_GFEA0325 := ExistBlock("GFEA0325")
	Local s_GFEA0324 := ExistBlock("GFEA0324")
	Local s_GFEA0329 := ExistBlock("GFEA0329")
	Local cListEmit	 := GFEGetEmRz(cValue) 
	Local cQuery	 := ""
	Local oQry

	If lExistVol .AND. nOp == MODEL_OPERATION_INSERT //Reseta o valor da quantidade de volumes ao recarregar browse de escolha
		oView:GetModel():GetModel("GFEA032_GWD"):SetValue("GWD_QTDVOL",0)
	EndIf

	dbSelectArea("GWU")
	aTmpStru := GWU->( dbStruct() )
	AEval(aTmpStru, {|x| IIf(x[1] $ "GWU_FILIAL|GWU_CDTPDC|GWU_EMISDC|GWU_SEQ|GWU_SERDC|GWU_NRDC|GWU_DTENT" + If(lCpoSrGW1,"GWU_SDOC",""), AAdd(aStruct, x), )})
	AAdd(aStruct, {"GWU_NMEMIS", "C", TamSX3("GU3_NMEMIT")[1], 0})
	AAdd(aStruct, {"GW1_CDDEST" , "C", TamSX3("GU3_CDEMIT")[1], 0})
	AAdd(aStruct, {"GU3_NMEMIT", "C", TamSX3("GU3_NMEMIT")[1], 0})
	AAdd(aStruct, {"GW1_QTVOL", "N", TamSX3("GW1_QTVOL")[1], TamSX3("GW1_QTVOL")[2]})
	AAdd(aStruct, {"GW1_NRROM", "C", TamSX3("GW1_NRROM")[1], TamSX3("GW1_NRROM")[2]})
	AAdd(aStruct, {"GW1_NRDC",  "C", TamSX3("GW1_NRDC")[1],  TamSX3("GW1_NRDC")[2]})
	AAdd(aStruct, {"GW1_DTSAI", "D", TamSX3("GW1_DTSAI")[1], TamSX3("GW1_DTSAI")[2]})

	dbSelectArea(cAliGWU)
	(cAliGWU)->( dbSetorder(1) )
	ZAP

	If Empty(cValue)
		oBrwGWU:Enable()
		oBrwGWU:Refresh(.T.)
		oBrwGWU:Disable()
		Return
	EndIf

	cQuery := "SELECT ' ' AS GWU_OK, 
	cQuery += " GWU.GWU_FILIAL," 
	cQuery += " GWU.GWU_NRDC," 
	cQuery += " GWU.GWU_CDTPDC," 
	cQuery += " GWU.GWU_SERDC," 
	cQuery += " GWU.GWU_SEQ,"
	cQuery += " GWU.GWU_SEQ,"
	cQuery += " GWU.GWU_EMISDC," 
	cQuery += " GU3.GU3_NMEMIT AS GWU_NMEMIS," 
	cQuery += " GWU.GWU_DTENT," 
	cQuery += " GW1.GW1_QTVOL,"
	cQuery += " GW1.GW1_NRROM," 
	cQuery += " GW1.GW1_NRDC," 
	cQuery += " GW1.GW1_DTSAI,"
	cQuery += " GW1.GW1_CDDEST," 
	cQuery += " GU3DES.GU3_NMEMIT,"
	cQuery += " GWU.GWU_SDOC"
	If s_GFEA0324
		cQuery := ExecBlock("GFEA0324",.F.,.F.,{(cQuery)})
	Endif
	cQuery += " FROM " + RetSQLName("GWU") + " GWU "
	cQuery += " INNER JOIN " + RetSQLName("GW1") + " GW1"
	cQuery += " ON GW1.GW1_FILIAL = ?"
	cQuery += " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += " AND GWU.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += " AND GWU.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += " INNER JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += " ON (GU3.GU3_FILIAL = ?"
	cQuery += " AND GU3.GU3_CDEMIT = GWU.GWU_EMISDC)"
	cQuery += " INNER JOIN " + RetSQLName("GU3") + " GU3DES"
	cQuery += " ON (GU3DES.GU3_FILIAL = ?"
	cQuery += " AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST)"

	If (!IsInCallStack("GFEA044") .And. nOp == MODEL_OPERATION_DELETE) .Or. (IsInCallStack("GFEA032") .And. !lPergunte .And. nOp == MODEL_OPERATION_UPDATE)
		cQuery += " INNER JOIN " + RetSQLName("GWL") + " GWL"
		cQuery += " ON GWL.GWL_FILIAL = ?"
		cQuery += " AND GWU.GWU_CDTPDC = GWL.GWL_TPDC"
		cQuery += " AND GWU.GWU_EMISDC = GWL.GWL_EMITDC"
		cQuery += " AND GWU.GWU_SERDC = GWL.GWL_SERDC"
		cQuery += " AND GWU.GWU_NRDC = GWL.GWL_NRDC"
		cQuery += " AND GWL.GWL_NROCO = ?"
		cQuery += " AND GWL.D_E_L_E_T_  = ' '"
	EndIf

	//Se não for inclusão através da GFEA044 e não for chamada do Pergunte.
	cQuery += " WHERE "
	If !IsInCallStack("GFEA044") .And. !lPergunte .And. nOp == MODEL_OPERATION_INSERT
		cQuery += " GW1.GW1_SIT = ? AND "
	EndIf

	// Caso seja chamado pelo GFEA044 utiliza a GW1 que está ativa.
	If IsInCallStack("GFEA044")
		dbSelectArea("GW1")
		cQuery += " GW1.GW1_FILIAL = ?"
		cQuery += " AND GW1.GW1_CDTPDC = ?"
		cQuery += " AND GW1.GW1_EMISDC = ?"
		cQuery += " AND GW1.GW1_SERDC = ?"
		cQuery += " AND GW1.GW1_NRDC = ? AND"
	EndIf

	//Utiliza os filtros dos parâmetros caso seja chamado via pergunte.
	If lPergunte

		If !Empty(cRoman)
			cQuery += " GW1.GW1_NRROM = ? AND "
		EndIf

		If !Empty(cDcAte)
			cQuery += " GW1.GW1_NRDC >= ? AND  GW1.GW1_NRDC  <= ? AND "
		EndIf

		If !Empty(dDeSaiAte)
			cQuery += " GW1.GW1_DTSAI >= ? AND GW1.GW1_DTSAI <= ? AND "
		EndIf

		If cValToChar(cSit) != "3"
			cQuery += " GW1.GW1_SIT = ? AND "
		EndIf

		If !Empty(dDtEntAte)
			If cValToChar(cSit) == "1"
				cQuery += " GWU.GWU_DTENT >= ? AND GWU.GWU_DTENT <= ? AND "
			ElseIf cValToChar(cSit) == "3"
				cQuery += " ( (GWU.GWU_DTENT >= ? AND GWU.GWU_DTENT <= ? ) "
				cQuery += " OR GWU.GWU_DTENT = '' ) AND "
			EndIf
		EndIf

	EndIf

	cQuery += " GWU.GWU_CDTRP IN (?)"
	cQuery += " AND GWU.GWU_FILIAL = ?" 
	cQuery += "	AND GW1.D_E_L_E_T_ = '' AND GWU.D_E_L_E_T_ = '' AND GU3.D_E_L_E_T_ = '' AND GU3DES.D_E_L_E_T_ = ''"

	// Executa a criação da área de acordo com a Query montada.
	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	nI := 1
	oQry:SetString(nI,xFilial("GW1")) 
	nI ++
	oQry:SetString(nI,xFilial("GU3")) 
	nI ++
	oQry:SetString(nI,xFilial("GU3")) 
	If (!IsInCallStack("GFEA044") .And. nOp == MODEL_OPERATION_DELETE) .Or. (IsInCallStack("GFEA032") .And. !lPergunte .And. nOp == MODEL_OPERATION_UPDATE)
		nI ++
		oQry:SetString(nI,xFilial("GWL"))
		nI ++
		oQry:SetString(nI,GWD->GWD_NROCO) 
	EndIf
	If !IsInCallStack("GFEA044") .And. !lPergunte .And. nOp == MODEL_OPERATION_INSERT
		nI ++
		oQry:SetString(nI,'4') 
	EndIf
	If IsInCallStack("GFEA044")
		dbSelectArea("GW1")
		nI ++
		oQry:SetString(nI,GW1->GW1_FILIAL) 
		nI ++
		oQry:SetString(nI,GW1->GW1_CDTPDC) 
		nI ++
		oQry:SetString(nI,GW1->GW1_EMISDC) 
		nI ++
		oQry:SetString(nI,GW1->GW1_SERDC) 
		nI ++
		oQry:SetString(nI,GW1->GW1_NRDC) 
	EndIf
	If lPergunte
		If !Empty(cRoman)
			nI ++
			oQry:SetString(nI,cRoman) 
		EndIf
		If  !Empty(cDcAte) 
			If !Empty(cDcDe)
				nI ++
				oQry:SetString(nI,cDcDe) 
			Else 
				nI ++ 
				oQry:SetString(nI,' ')
			EndIf
			nI ++
			oQry:SetString(nI,cDcAte) 
		EndIf
		If !Empty(dDeSaiAte)
			nI ++
			oQry:SetString(nI,DToS(dDtSaiDe)) 
		EndIf
		If cValToChar(cSit) != "3"
			If cValToChar(cSit) == "1"
				nI ++
				oQry:SetString(nI,"5")
			Else
				nI ++
				oQry:SetString(nI,"4")
			EndIf 		
		EndIf
		If !Empty(dDeSaiAte)
			nI ++
			oQry:SetString(nI,DToS(dDeSaiAte)) 
		EndIf
		If !Empty(dDtEntAte)
			If cValToChar(cSit) == "1" 
				nI ++
				oQry:SetString(nI,DToS(dDtEntDe))
				nI ++
				oQry:SetString(nI,DToS(dDtEntAte))
			ElseIf cValToChar(cSit) == "3"
				nI ++
				oQry:SetString(nI,DToS(dDtEntDe))
				nI ++
				oQry:SetString(nI,DToS(dDtEntAte))
			EndIf
		EndIf
	EndIf
	nI ++
	oQry:SetIn(nI,{cListEmit}) 
	nI ++
	oQry:SetString(nI,xFilial("GWU")) 
	cGWUFil := oQry:OpenAlias()

	(cGWUFil)->( dbGoTop() )
	Do While (cGWUFil)->(!Eof())
		If lDisable
			lDisable := .F.
		EndIf

		// Realiza a verificação se o registro será exibido.
		If lChange .Or. IIf(Empty(cFilGWU), .T., &(cFilGWU))
			dbSelectArea(cAliGWU)
			(cAliGWU)->( dbSetOrder(1) ) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
			If !(cAliGWU)->( dbSeek((cGWUFil)->GWU_FILIAL +;
					(cGWUFil)->GWU_CDTPDC +;
					(cGWUFil)->GWU_EMISDC +;
					(cGWUFil)->GWU_SERDC +;
					(cGWUFil)->GWU_NRDC +;
					(cGWUFil)->GWU_SEQ ))
				RecLock(cAliGWU, .T.)
				(cAliGWU)->GWU_FILIAL := (cGWUFil)->GWU_FILIAL
				(cAliGWU)->GWU_NRDC   := (cGWUFil)->GWU_NRDC
				(cAliGWU)->GWU_CDTPDC := (cGWUFil)->GWU_CDTPDC
				(cAliGWU)->GWU_SERDC  := (cGWUFil)->GWU_SERDC
				(cAliGWU)->GWU_SEQ    := (cGWUFil)->GWU_SEQ
				(cAliGWU)->GWU_EMISDC := (cGWUFil)->GWU_EMISDC
				(cAliGWU)->GWU_NMEMIS := (cGWUFil)->GWU_NMEMIS
				(cAliGWU)->GWU_DTENT  := StoD((cGWUFil)->GWU_DTENT)
				(cAliGWU)->GW1_CDDEST := (cGWUFil)->GW1_CDDEST
				(cAliGWU)->GU3_NMEMIT := (cGWUFil)->GU3_NMEMIT
				(cAliGWU)->GW1_NRROM  := (cGWUFil)->GW1_NRROM
				If IsInCallStack("GFEA044")

					If cTreEsc == (cGWUFil)->GWU_SEQ
						(cAliGWU)->GWU_OK := oBrwGWU:Mark()
					EndIf

				ElseIf nOp == MODEL_OPERATION_UPDATE .and. !oBrwGWU:IsMark(oBrwGWU:Mark()) .and. !lFuncSLC
					// Se a ocorrencia estiver na chave da GWL, marcar
					GWL->(dbSetOrder(1))// GWL_FILIAL+GWL_NROCO+GWL_FILDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC+GWL_TPDC
					If GWL->(dbSeek(xFilial("GWL")+M->GWD_NROCO+(cAliGWU)->GWU_FILIAL+(cAliGWU)->GWU_EMISDC+(cAliGWU)->GWU_SERDC+(cAliGWU)->GWU_NRDC+(cAliGWU)->GWU_CDTPDC))
						(cAliGWU)->GWU_OK := oBrwGWU:Mark()
					EndIf
				EndIf

				If lPergSLC .or. lFuncSLC
					For nI := 1 to Len(aReg)
						(cAliGWU)->( dbSetOrder(1) )// GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
						If (cAliGWU)->(dbSeek(aReg[nI][1]+aReg[nI][2]+aReg[nI][3]+aReg[nI][4]+aReg[nI][5]+aReg[nI][6]))
							RecLock(cAliGWU, .F.)
							(cAliGWU)->GWU_OK := oBrwGWU:Mark()
							(cAliGWU)->( MSUnlock() )
						EndIf
					Next nI
				EndIf

				If lCpoSrGW1
					(cAliGWU)->GWU_SDOC := (cGWUFil)->GWU_SDOC
				EndIf
				If s_GFEA0325
					ExecBlock("GFEA0325",.F.,.F.,{(cAliGWU),(cGWUFil)})
				EndIf
				(cAliGWU)->( MSUnlock() )
			EndIf

			If IsInCallStack("GFEA044") .And. !lOp
				lOp := .T.
				aRom := {}
				aRom := GFEA32REL()

				If (Len(aRom) > 0 .OR. !Empty(aRom)) .And. IIf(!Empty((cGWUFil)->GW1_NRROM),MsgYesNo("Deseja vincular os Documentos de Carga do mesmo Romaneio?"),.F.)

					dbSelectArea(cAliGWU)
					(cAliGWU)->( dbSetOrder(1) )

					For nI := 1 To Len(aRom)
						If !(cAliGWU)->( dbSeek(aRom[nI][1] + aRom[nI][2] + aRom[nI][3] + aRom[nI][4] + aRom[nI][5] + aRom[nI][6]) )
							RecLock(cAliGWU, .T.)
							(cAliGWU)->GWU_FILIAL := aRom[nI][1]
							(cAliGWU)->GWU_NRDC   := aRom[nI][5]
							(cAliGWU)->GWU_CDTPDC := aRom[nI][2]
							(cAliGWU)->GWU_SERDC  := aRom[nI][4]
							(cAliGWU)->GWU_SEQ    := aRom[nI][6]
							(cAliGWU)->GWU_EMISDC := aRom[nI][3]
							(cAliGWU)->GWU_DTENT  := CTOD(aRom[nI][7])
							(cAliGWU)->GWU_NMEMIS := Posicione("GU3", 1, xFilial("GU3") + aRom[nI][3] , "GU3_NMEMIT")
							(cAliGWU)->GW1_CDDEST := aRom[nI][9]
							(cAliGWU)->GU3_NMEMIT := Posicione("GU3", 1, xFilial("GU3") + aRom[nI][9] , "GU3_NMEMIT")
							If lCpoSrGW1
								(cAliGWU)->GWU_SDOC := aRom[nI][10]
							EndIf
						Else
							RecLock(cAliGWU, .F.)
						EndIf

						If s_GFEA0329
							ExecBlock("GFEA0329",.F.,.F.,{(cAliGWU),aRom,nI})
						EndIf

						If cTreEsc == (cAliGWU)->GWU_SEQ
							(cAliGWU)->GWU_OK := oBrwGWU:Mark()
							(cAliGWU)->( MSUnlock() )
							GFEA32MARK(.T.)
						EndIf

						//GFEA32MOD()

						If lExistVol .And. nOp == MODEL_OPERATION_INSERT .And. oBrwGWU:IsMark(oBrwGWU:Mark())
							oView:GetModel():GetModel("GFEA032_GWD"):SetValue("GWD_QTDVOL"  ,;
								oView:GetModel():GetModel("GFEA032_GWD"):GetValue("GWD_QTDVOL") + aRom[nI][8])
						EndIf

					Next nI
				Else
					aCalc := {}

					dbSelectArea("GWH")
					GWH->( dbSetOrder(2) )
					GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) ) //Retirar campo filial quando puder relacionar ocorrência e DC de filiais distintas.
					Do While !GWH->( Eof()) .And. GWH->GWH_FILIAL == xFilial("GWH") .AND. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC .AND. GWH->GWH_EMISDC == GW1->GW1_EMISDC .AND. GWH->GWH_SERDC == GW1->GW1_SERDC .AND. GWH->GWH_NRDC == GW1->GW1_NRDC
						aCalc := GFEA32CAL()
						dbSelectArea("GWH")
						GWH->( dbSkip() )
					EndDo
					If (Len(aCalc) > 0 .or. !Empty(aCalc)) .and. MsgYesNo("Deseja vincular os Documentos de Carga da mesma entrega?")
						aAreaCGWU := (cAliGWU)->(GetArea())
						dbSelectArea(cAliGWU)
						(cAliGWU)->( dbSetOrder(1) )
						For nI := 1 To Len(aCalc)
							If !(cAliGWU)->( dbSeek(aCalc[nI][1] + aCalc[nI][2] + aCalc[nI][3] + aCalc[nI][4] + aCalc[nI][5] + aCalc[nI][6]) )
								RecLock(cAliGWU, .T.)
								(cAliGWU)->GWU_FILIAL := aCalc[nI][1]
								(cAliGWU)->GWU_NRDC   := aCalc[nI][5]
								(cAliGWU)->GWU_CDTPDC := aCalc[nI][2]
								(cAliGWU)->GWU_SERDC  := aCalc[nI][4]
								(cAliGWU)->GWU_SEQ    := aCalc[nI][6]
								(cAliGWU)->GWU_EMISDC := aCalc[nI][3]
								(cAliGWU)->GWU_DTENT  := CTOD(aCalc[nI][7])
								(cAliGWU)->GWU_NMEMIS := Posicione("GU3", 1, xFilial("GU3") + aCalc[nI][3] , "GU3_NMEMIT")
								(cAliGWU)->GW1_CDDEST := aCalc[nI][9]
								(cAliGWU)->GU3_NMEMIT := Posicione("GU3", 1, xFilial("GU3") + aCalc[nI][9] , "GU3_NMEMIT")
								If lCpoSrGW1
									(cAliGWU)->GWU_SDOC := aCalc[nI][10]
								EndIf
							Else
								RecLock(cAliGWU, .F.)
							EndIf

							If s_GFEA0329
								ExecBlock("GFEA0329",.F.,.F.,{(cAliGWU),aCalc ,nI})
							EndIf

							If cTreEsc == (cAliGWU)->GWU_SEQ
								(cAliGWU)->GWU_OK     := oBrwGWU:Mark()
								(cAliGWU)->( MSUnlock() )
							EndIf

							//GFEA32MOD()
							GFEA32MARK(.T.)

							If lExistVol .And. nOp == MODEL_OPERATION_INSERT .And. oBrwGWU:IsMark(oBrwGWU:Mark())
								oView:GetModel():GetModel("GFEA032_GWD"):SetValue("GWD_QTDVOL"  ,;
									oView:GetModel():GetModel("GFEA032_GWD"):GetValue("GWD_QTDVOL") + aCalc[nI][8])
							EndIf
						Next nI
						RestArea(aAreaCGWU)
					EndIf
				EndIf
			EndIf

			nTot++
			If IsInCallStack("GFEA044")
				If cTreEsc == (cAliGWU)->GWU_SEQ
					RecLock(cAliGWU, .F.)
					(cAliGWU)->GWU_OK := IIf(GFEA32SKDC(), oBrwGWU:Mark(), "")
					(cAliGWU)->( MSUnlock() )
				EndIf
			EndIf

			If lExistVol .And. nOp == MODEL_OPERATION_INSERT .And. oBrwGWU:IsMark(oBrwGWU:Mark())
				oView:GetModel():GetModel("GFEA032_GWD"):SetValue("GWD_QTDVOL"  , ;
					oView:GetModel():GetModel("GFEA032_GWD"):GetValue("GWD_QTDVOL") + (cAliGWU)->GW1_QTVOL)
			EndIf
		EndIf

		GFEA32MOD()
		(cGWUFil)->( dbSkip() )
	EndDo

	If nOp != MODEL_OPERATION_DELETE

		oBrwGWU:Enable()

		If lExistVol .And. nOp == MODEL_OPERATION_INSERT
			oView:Refresh()
		EndIf
	EndIf
	oBrwGWU:Refresh(.T.)
	(cGWUFil)->(dbCloseArea())
Return

//-------------------------------------------------------------------
Function GFEA32SKDC(lBlank)
	Local oModel    := FWModelActive()
	Local oModelGWL := oModel:GetModel("GFEA032_GWL")
	Local aSeekLine
	Default lBlank  := .F.

	If lBlank .And. oModelGWL:IsEmpty()
		Return .T.
	EndIf
	If IsInCallStack("GFEC054")
		aSeekLine := {{"GWL_NRDC", (cAliasGWU)->GWU_NRDC}, {"GWL_FILDC", (cAliasGWU)->GWU_FILIAL}, {"GWL_EMITDC", (cAliasGWU)->GWU_EMISDC},;
			{"GWL_SERDC", (cAliasGWU)->GWU_SERDC}, {"GWL_TPDC", (cAliasGWU)->GWU_CDTPDC}}
		If !lBlank
			aAdd(aSeekLine,{"GWL_SEQ", (cAliasGWU)->GWU_SEQ})
		EndIf
	Else
		aSeekLine := {{"GWL_NRDC", (cGWUFil)->GWU_NRDC}, {"GWL_FILDC", (cGWUFil)->GWU_FILIAL}, {"GWL_EMITDC", (cGWUFil)->GWU_EMISDC},;
			{"GWL_SERDC", (cGWUFil)->GWU_SERDC}, {"GWL_TPDC", (cGWUFil)->GWU_CDTPDC}}
		If IsInCallStack("GFEA044")
			If !lBlank .And. cTreEsc == (cGWUFil)->GWU_SEQ
				aAdd(aSeekLine,{"GWL_SEQ", (cGWUFil)->GWU_SEQ})
			EndIf
		Else
			If !lBlank
				aAdd(aSeekLine,{"GWL_SEQ", (cGWUFil)->GWU_SEQ})
			EndIf
		EndIf
	EndIf
Return oModelGWL:SeekLine(aSeekLine) .And. !oModelGWL:IsDeleted()

//-------------------------------------------------------------------
Function GFEA32FDC()
	Local oFilter    := FWFilter():New(oBrwGWU:GetOwner())
	Local aFields    := {}
	Local aTmpStru   := {}
	Local nI         := 0
	Local cFilter    := 'GWU_FILIAL|GWU_CDTPDC|GWU_EMISDC|GWU_SEQ|GWU_SERDC|GWU_NRDC|GWU_DTENT'
	Local cCpoSrGWU  := SerieNfId('GWU',3,'GWU_SERDC')
	Local s_GFEA0326 := ExistBlock("GFEA0326")


	dbSelectArea(cAliGWU)
	aTmpStru := (cAliGWU)->( dbStruct() )

	AAdd(aTmpStru, {"GWU_NMEMIS", "C", TamSX3("GU3_NMEMIT")[1], 0})

	If s_GFEA0326
		cFilter := ExecBlock("GFEA0326",.F.,.F.,{cFilter})
	EndIf

	For nI := 1 To Len(aTmpStru)
		If aTmpStru[nI][1] $ cFilter

			dbSelectArea("SX3")
			SX3->( dbSetOrder(2) )
			If aTmpStru[nI][1] == "GWU_SERDC"

				SX3->( dbSetOrder(2) )
				SX3->( dbSeek(cCpoSrGWU) )
				AAdd(aFields, {"(cGWUFil)->" + cCpoSrGWU, X3TITULO(), "C", TamSX3("GWU_SERDC")[1], TamSX3("GWU_SERDC")[2], X3PICTURE()})

			ElseIf SX3->( dbSeek(IIf(aTmpStru[nI][1]=="GWU_NMEMIS", "GW1_NMEMIS", aTmpStru[nI][1])) )
				If aTmpStru[nI][1]=="GWU_DTENT"
					AAdd(aFields, {"sToD((cGWUFil)->" + aTmpStru[nI][1] + ")", X3TITULO(), aTmpStru[nI][2], aTmpStru[nI][3], aTmpStru[nI][4], X3PICTURE()})
				Else
					AAdd(aFields, {"(cGWUFil)->" + aTmpStru[nI][1], X3TITULO(), aTmpStru[nI][2], aTmpStru[nI][3], aTmpStru[nI][4], X3PICTURE()})
				EndIf
			EndIf
		EndIf
	Next nI

	AAdd(aFields, {"(cGWUFil)->GW1_NRROM", "Romaneio", "C", TamSX3("GW1_NRROM")[1], 0, Replicate("9", TamSX3("GW1_NRROM")[1])})
	AAdd(aFields, {"(cGWUFil)->GW1_CDDEST", "Cod Dest", "C", TamSX3("GW1_CDDEST")[1], TamSX3("GW1_CDDEST")[2], Replicate("9", TamSX3("GW1_CDDEST")[1])})

	oFilter:SetAlias(cAliGWU)
	oFilter:SetProfileID("1")
	oFilter:SetField(aFields)
	oFilter:SetExecute({|| cFilGWU := oFilter:GetExprAdvPL(), GFEA32LOAD(oViewOco, FWFldGet("GWD_CDTRP"), .F.)})
	oFilter:DisableValid(.F.)
	oFilter:CleanFilter(.F.)
	oFilter:DisableDel(.T.) // Desabilita a exclusão dos filtros pelo usuário

	//Filtros
	AAdd(oFilter:aCheckFil, oViewOco:GetModel():GetOperation() != MODEL_OPERATION_INSERT .Or. IsInCallStack("GFEA044") .Or. IsInCallStack("GFEC041") .Or. IsInCallStack("GFEC054OCO"))
	AAdd(oFilter:aFilter, {"Somente Relacionados", "GFEA32SKDC()",, {}, .F., .F., .F.,,})

	AAdd(oFilter:aCheckFil, .T.)
	AAdd(oFilter:aFilter, {"Parametros", "GFEA32PERG()",, {}, .T., .T., .F.,,})

	If IsInCallStack("GFEC054")
		AAdd(oFilter:aCheckFil, .T.)
		AAdd(oFilter:aFilter, {"Documento de Transporte", "GFEA32DTP()",, {}, .T., .T., .F.,,})
	EndIf

	oFilter:LoadFilter() // Carrega os filtros gravados para o usuário

	oFilter:Activate()
Return Nil

//-------------------------------------------------------------------
// Função do botão "Selec/Todos"
//-------------------------------------------------------------------
Function GFEA32SLC()
	Local cDesmark    := .F.
	Private aFields   := {}
	Private aReg      := {}
	Private cRoman    := ""
	Private cDcDe     := ""
	Private cDcAte    := ""
	Private	dDtSaiDe  := Nil
	Private	dDeSaiAte := Nil
	Private	cSit      := 3
	Private	dDtEntDe  := Nil
	Private	dDtEntAte := Nil

	If Empty(oViewOco) .Or. oViewOco:lActivate == .F.
		oViewOco := FwViewActive()
	EndIf

	// Verifica se há algum registro desmarcado
	(cAliGWU)->( dbGoTop() )
	Do While !(cAliGWU)->( Eof() )
		If (cAliGWU)->GWU_OK != oBrwGWU:Mark()
			cDesmark := .T.
			(cAliGWU)->GWU_OK := oBrwGWU:Mark() //marca CHECK
		EndIf
		(cAliGWU)->( dbSkip() )
	EndDo

	If cDesmark == .T.
		// Salva no array os registros marcados
		(cAliGWU)->( dbGoTop() )
		Do While !(cAliGWU)->( Eof() )
			If (cAliGWU)->GWU_OK == oBrwGWU:Mark()
				aFields := {(cAliGWU)->GWU_FILIAL,;
					(cAliGWU)->GWU_CDTPDC,;
					(cAliGWU)->GWU_EMISDC,;
					(cAliGWU)->GWU_SERDC ,;
					(cAliGWU)->GWU_NRDC,;
					(cAliGWU)->GWU_SEQ}
				Aadd(aReg,aFields)
			EndIf
			(cAliGWU)->( dbSkip() )
		EndDo

		lFuncSLC := .T.
		GFEA32LOAD(oViewOco, FwFldGet("GWD_CDTRP"), .T.)

		lFuncSLC := .F.
	Else
		// Deleta desmarcados do browse
		(cAliGWU)->( dbGoTop() )
		Do While !(cAliGWU)->( Eof() )
			If (cAliGWU)->GWU_OK != oBrwGWU:Mark()
				RecLock(cAliGWU, .F.)
				dbDelete()
				(cAliGWU)->(MSUnlock())
			EndIf
			(cAliGWU)->(dbSkip())
		EndDo
	EndIf
Return Nil

Function GFEA32DTP()
	Local lRet      := .F.
	Local cAliasGWE := GetNextAlias()
	
	BeginSql Alias cAliasGWE
		SELECT GWE.GWE_FILIAL,
				GWE.GWE_FILDT,
				GWE.GWE_NRDT,
				GWE.GWE_SERDT
		FROM %Table:GWE% GWE
		WHERE GWE.GWE_FILIAL = %Exp:GWU->GWU_FILIAL%
		AND GWE.GWE_CDTPDC = %Exp:GWU->GWU_CDTPDC%
		AND GWE.GWE_EMISDC = %Exp:GWU->GWU_EMISDC%
		AND GWE.GWE_SERDC = %Exp:GWU->GWU_SERDC%
		AND GWE.GWE_NRDC = %Exp:GWU->GWU_NRDC%
		AND GWE.%NotDel%
	EndSql
	If (cAliasGWE)->(!Eof())
		lRet := _CodDocTransp == (cAliasGWE)->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
	EndIf
	(cAliasGWE)->(dbCloseArea())
Return lRet

//-------------------------------------------------------------------

Function GFEA32PDC(lVincRom)
	Local nI := 0
	Local nF := 0

	Private cRoman    := ""
	Private cDcDe     := ""
	Private cDcAte    := ""
	Private dDtSaiDe  := Nil
	Private dDtSaiAte := Nil
	Private nSit      := 0
	Private dDtEntDe  := Nil
	Private dDtEntAte := Nil
	Private aFields   := {}
	Private aReg      := {}

	Default lVincRom  := .F.

	lFuncSLC := .T.

	(cAliGWU)->( dbGoTop() )
	Do While !(cAliGWU)->( Eof() )
		If (cAliGWU)->GWU_OK == oBrwGWU:Mark()
			aFields := {(cAliGWU)->GWU_FILIAL,;
				(cAliGWU)->GWU_CDTPDC,;
				(cAliGWU)->GWU_EMISDC,;
				(cAliGWU)->GWU_SERDC ,;
				(cAliGWU)->GWU_NRDC,;
				(cAliGWU)->GWU_SEQ,;
				(cAliGWU)->GWU_EMISDC,;
				(cAliGWU)->GWU_NMEMIS,;
				(cAliGWU)->GWU_DTENT ,;
				(cAliGWU)->GW1_CDDEST,;
				(cAliGWU)->GU3_NMEMIT,;
				(cAliGWU)->GW1_NRROM}

			Aadd(aReg,aFields)
		EndIf
		(cAliGWU)->( dbSkip() )
	EndDo

	If Empty(oViewOco) .Or. oViewOco:lActivate == .F.
		oViewOco := FwViewActive()
	EndIf

	If lVincRom
		cRoman    := (cAliGWU)->GW1_NRROM
		cDcDe     := ""
		cDcAte    := ""
		dDtSaiDe  := MV_PAR04
		dDeSaiAte := MV_PAR05
		cSit      := MV_PAR06
		dDtEntDe  := MV_PAR07
		dDtEntAte := MV_PAR08

		lPergSLC := .T.
		GFEA32LOAD(oViewOco, FwFldGet("GWD_CDTRP"), .T., .T.)
	Else
		If Pergunte("GFEA032", .T.)
			cRoman    := MV_PAR01
			cDcDe     := MV_PAR02
			cDcAte    := MV_PAR03
			dDtSaiDe  := MV_PAR04
			dDeSaiAte := MV_PAR05
			cSit      := MV_PAR06
			dDtEntDe  := MV_PAR07
			dDtEntAte := MV_PAR08

			lPergSLC := .T.
			GFEA32LOAD(oViewOco, FwFldGet("GWD_CDTRP"), .T., .T.)
			nF := Len(aReg)
			For nI := 1 To nF
				(cAliGWU)->( dbSetOrder(1) )// GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
				If (cAliGWU)->(dbSeek(aReg[nI][1]+aReg[nI][2]+aReg[nI][3]+aReg[nI][4]+aReg[nI][5]+aReg[nI][6]))
					RecLock(cAliGWU, .F.)
					(cAliGWU)->GWU_OK := oBrwGWU:Mark()
					(cAliGWU)->( MSUnlock() )
				Else
					RecLock(cAliGWU, .T.)
					(cAliGWU)->GWU_FILIAL := aReg[nI][1]
					(cAliGWU)->GWU_CDTPDC := aReg[nI][2]
					(cAliGWU)->GWU_EMISDC := aReg[nI][3]
					(cAliGWU)->GWU_SERDC  := aReg[nI][4]
					(cAliGWU)->GWU_NRDC   := aReg[nI][5]
					(cAliGWU)->GWU_SEQ    := aReg[nI][6]
					(cAliGWU)->GWU_EMISDC := aReg[nI][7]
					(cAliGWU)->GWU_NMEMIS := aReg[nI][8]
					(cAliGWU)->GWU_DTENT  := aReg[nI][9]
					(cAliGWU)->GW1_CDDEST := aReg[nI][10]
					(cAliGWU)->GU3_NMEMIT := aReg[nI][11]
					(cAliGWU)->GW1_NRROM  := aReg[nI][12]
					(cAliGWU)->GWU_OK     := oBrwGWU:Mark()
					(cAliGWU)->( MSUnlock() )
				EndIf
			Next nI
		EndIf
	EndIf
	lFuncSLC := .F.
	lPergSLC := .F.

Return Nil

//-------------------------------------------------------------------

Static Function GFEA32PERG()

	If ((cAliGWU)->GW1_NRROM == MV_PAR01 .Or. Empty(MV_PAR01)) ;
			.And. (cAliGWU)->GW1_NRDC  >= MV_PAR02 ;
			.And. ((cAliGWU)->GW1_NRDC <= MV_PAR03 .Or. Empty(MV_PAR03)) ;
			.And. (cAliGWU)->GW1_DTSAI >= MV_PAR04 ;
			.And. ((cAliGWU)->GW1_DTSAI <= MV_PAR05 .Or. Empty(MV_PAR05))

		If MV_PAR06 == 1 // Entregue
			Return (cAliGWU)->GWU_DTENT >= MV_PAR07 .And. ((cAliGWU)->GWU_DTENT <= MV_PAR08 .Or. Empty(MV_PAR08)) .And. !Empty((cAliGWU)->GWU_DTENT)
		ElseIf MV_PAR06 == 2 // Não Entregue
			Return Empty((cAliGWU)->GWU_DTENT)
		Else // Todas
			Return Empty((cAliGWU)->GWU_DTENT) .Or. ((cAliGWU)->GWU_DTENT >= MV_PAR07 .And. ((cAliGWU)->GWU_DTENT <= MV_PAR08 .Or. Empty(MV_PAR08)) .And. !Empty((cAliGWU)->GWU_DTENT))
		EndIf
	EndIf
Return .F.

//-------------------------------------------------------------------

Function GFEA032GWL(oPanel, oObj)
	Local aStruct   := {{"GWU_OK", "C", 2, 0}}
	Local aTmpStru  := {}
	Local nI        := 0
	Local nF        := 0
	Local aPos      := {{"GWU_FILIAL", 1},;
		{"GWU_NRDC"  , 2},;
		{"GWU_CDTPDC", 3},;
		{"GWU_SERDC" , 4},;
		{"GWU_SEQ"   , 5},;
		{"GWU_DTENT" , 6},;
		{"GW1_CDDEST", 7},;
		{"GU3_NMEMIT", 8},;
		{"GWU_EMISDC", 9},;
		{"GWU_NMEMIS",10}}
	Local aHeader   := Array(Len(aPos))
	Local oView     := oObj:oControl
	Local lCpoSrGW1 := GfeVerCmpo({"GW1_SDOC"})
	Local cSerie    := ""
	Local lActivate := .F.
	Local aRotina   := MenuDef()
	Local aRotina2 	:= {}
	Local s_GFEA0327 := ExistBlock("GFEA0327")

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA032A")

	If !IsBlind() .and. !IsInCallStack("GFEA044")
		aRotina2 := aRotina // fazer isso por causa da função dos anexos MATXFUNC
		aRotina  := {}
	EndIf

	cSerie := If(lCpoSrGW1,"+GWU_SDOC ","")

	dbSelectArea("GWU")
	aTmpStru := GWU->( dbStruct() )

	AEval(aTmpStru, {|x| IIf(x[1] $ "GWU_FILIAL|GWU_CDTPDC|GWU_EMISDC|GWU_SEQ|GWU_SERDC|GWU_NRDC|GWU_DTENT", AAdd(aStruct, x), )})

	AAdd(aStruct, {"GWU_NMEMIS", "C", TamSX3("GU3_NMEMIT")[1], 0})
	AAdd(aStruct, {"GW1_CDDEST", "C", TamSX3("GW1_CDDEST")[1], TamSX3("GW1_CDDEST")[2]})
	AAdd(aStruct, {"GU3_NMEMIT", "C", TamSX3("GU3_NMEMIT")[1], TamSX3("GU3_NMEMIT")[2]})

	If s_GFEA0327
		aRet := ExecBlock("GFEA0327",.F.,.F.,{aPos,Len(aPos),aStruct})
		aPos := aRet[1]
		aStruct := aRet[2]
	EndIf

	aHeader := Array(Len(aPos))
	nF := Len(aStruct)
	For nI := 2 To nF

		dbSelectArea("SX3")
		SX3->( dbSetOrder(2) )
		If SX3->( dbSeek(IIf(aStruct[nI][1]=="GWU_NMEMIS", "GW1_NMEMIS", aStruct[nI][1])) )

			aHeader[aPos[AScan(aPos, {|x| x[1]==aStruct[nI][1]})][2]] := ;
				{ IIf(aStruct[nI][1]=="GWU_SEQ", "Seq. Trecho", X3TITULO()), ; //Título
			aStruct[nI][1], ; // Nome do campo
			aStruct[nI][2], ; // Tipo
			aStruct[nI][3], ; // Tamanho
			aStruct[nI][4], ; // Decimal
			X3PICTURE() }     // Picture
		EndIf
	Next nI

	aHeader[4] := {"Série"            ,"GWU_SERDC", "C",TamSx3("GWU_SERDC")[1],0, "!!!"}
	aHeader[7] := {"Cod. Destin."     ,"GW1_CDDEST","C",TamSx3("GW1_CDDEST")[1],0,"@!"}
	aHeader[8] := {"Nome Destinatário","GU3_NMEMIT","C",TamSx3("GU3_NMEMIT")[1],0,"@!"}

	AAdd(aStruct, {"GW1_QTVOL",  "N", TamSX3("GW1_QTVOL")[1], TamSX3("GW1_QTVOL")[2]})
	AAdd(aStruct, {"GW1_NRROM",  "C", TamSX3("GW1_NRROM")[1], TamSX3("GW1_NRROM")[2]})
	AAdd(aStruct, {"GW1_NRDC",   "C", TamSX3("GW1_NRDC")[1],  TamSX3("GW1_NRDC")[2]})
	AAdd(aStruct, {"GW1_DTSAI",  "D", TamSX3("GW1_DTSAI")[1], TamSX3("GW1_DTSAI")[2]})
	If lCpoSrGW1
		AAdd(aStruct, {"GWU_SDOC",  "C", TamSX3("GWU_SDOC")[1], TamSX3("GWU_SDOC")[2]})
	EndIf

	cAliGWU := GFECriaTab({aStruct, { "GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ",;
		"GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ+GWU_FILIAL",;
		"GWU_OK+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC" + cSerie}})

	//Não criará o grid caso seja selecionada a opção Salvar e Criar Novo
	If nBrwGWUEve == 0
		nBrwGWUEve := 1

		oBrwGWU := FWMarkBrowse():New()
		oBrwGWU:SetOwner(oPanel)

		oBrwGWU:SetMenuDef("GFEA032A")
		oBrwGWU:AddButton(STR0066, "GFEA32PDC()",, 3, 0) // Parâmetros
		oBrwGWU:AddButton(STR0067, "GFEA32SLC()",, 3, 0) // Seleção/Todos
		oBrwGWU:AddButton(STR0068, "GFEA32DOC()",, 2, 0) // Documento Carga
		oBrwGWU:AddButton(STR0069, "GFEA32ROM()",, 2, 0) // Romaneio
		oBrwGWU:SetIgnoreARotina(.T.) // Ignora aRotina na construção das opções de menu
		oBrwGWU:SetUseFilter(.F.) // Desabilita filtro padrão no Browse

		lActivate := .T.
	EndIf

	oBrwGWU:SetProfileID("2")
	oBrwGWU:SetFieldMark("GWU_OK")
	oBrwGWU:SetDescription("Documentos de Carga")
	oBrwGWU:DisableReport()
	oBrwGWU:SetSeeAll(.T.)
	oBrwGWU:SetAllMark({|| })
	oBrwGWU:SetCustomMarkRec({|| GFEA32MARK()})
	oBrwGWU:SetTemporary(.T.)
	oBrwGWU:SetAlias(cAliGWU)
	oBrwGWU:SetFields(aHeader)

	If lActivate
		oBrwGWU:Activate()
	EndIf

	oBrwGWU:Disable()

	If SuperGetMv("MV_TMS2GFE",.F.,.F.) .And. IsInCallStack("GFEC054")
		cFilGWU := "GFEA32SKDC(.T.) .And. GFEA32DTP()"
	Else
		cFilGWU := "GFEA32SKDC(.T.)"
	EndIf
	GFEA32LOAD(oView, oView:GetModel():GetModel("GFEA032_GWD"):GetValue("GWD_CDTRP"), .F.)

	// Código abaixo foi necessário pois o foco estava no browse - oBrwGWU:Activate()
	// fazendo com que o usuário tivesse que clicar no campo Transportador para começar a digitação da ocorrência
	oView:GetViewObj("GFEA032_GWD")[3]:GetFWEditCTRL("GWD_CDTRP"):OCONTAINER:NextControl():SetFocus()

	If !IsBlind() .and. !IsInCallStack("GFEA044")
		aRotina := aRotina2 // carregando novamente o arotina com o menudef para que não ocorra erros na função de anexo no MATXFUNC
	EndIf
Return Nil
//-------------------------------------------------------------------

Function GFEA32DOC()
	Local cAliasGW1 := GetNextAlias()
	Local aAreaGW1  := GW1->(GetArea())
	Local cQuery 	:= ""
	Local oQry		
	
	cQuery := "SELECT GW1.R_E_C_N_O_ RECNOGW1"
	cQuery += " FROM " + RetSqlName("GW1") + " GW1"
	cQuery += " WHERE GW1.GW1_FILIAL = ?"
	cQuery += " AND GW1.GW1_CDTPDC   = ?"
	cQuery += " AND GW1.GW1_EMISDC   = ?"
	cQuery += " AND GW1.GW1_SERDC    = ?"
	cQuery += " AND GW1.GW1_NRDC     = ?"
	cQuery += " AND GW1.D_E_L_E_T_   = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,(cAliGWU)->GWU_FILIAL) 
	oQry:SetString(2,(cAliGWU)->GWU_CDTPDC) 
	oQry:SetString(3,(cAliGWU)->GWU_EMISDC) 
	oQry:SetString(4,(cAliGWU)->GWU_SERDC) 
	oQry:SetString(5,(cAliGWU)->GWU_NRDC) 
	cAliasGW1 := oQry:OpenAlias()

	If (cAliasGW1)->(!Eof())
		GW1->(dbGoTo((cAliasGW1)->RECNOGW1))
		FWExecView("Visualizar", "GFEC040", 1,, {||.T.})
	EndIf
	(cAliasGW1)->(dbCloseArea())
	RestArea(aAreaGW1)
Return Nil

//-------------------------------------------------------------------

Function GFEA32ROM()
	Local cAliasGW1 := GetNextAlias()
	Local aAreaGWN  := GWN->(GetArea())
	Local cQuery	:= ""
	Local oQry
	
	cQuery := "SELECT GWN.R_E_C_N_O_ RECNOGWN"
	cQuery += " FROM " + RetSqlName("GW1") + " GW1"
	cQuery += " INNER JOIN " + RetSqlName("GWN") + " GWN"
	cQuery += " ON GWN.GWN_FILIAL = '" + xFilial("GWN") + "'"
	cQuery += " AND GWN.GWN_NRROM = GW1.GW1_NRROM"
	cQuery += " AND GWN.D_E_L_E_T_ = ''"
	cQuery += " WHERE GW1.GW1_FILIAL = ?"
	cQuery += " AND GW1.GW1_CDTPDC   = ?"
	cQuery += " AND GW1.GW1_EMISDC   = ?"
	cQuery += " AND GW1.GW1_SERDC    = ?"
	cQuery += " AND GW1.GW1_NRDC     = ?"
	cQuery += " AND GW1.D_E_L_E_T_   = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,(cAliGWU)->GWU_FILIAL) 
	oQry:SetString(2,(cAliGWU)->GWU_CDTPDC) 
	oQry:SetString(3,(cAliGWU)->GWU_EMISDC) 
	oQry:SetString(4,(cAliGWU)->GWU_SERDC) 
	oQry:SetString(5,(cAliGWU)->GWU_NRDC) 
	cAliasGW1 := oQry:OpenAlias()

	If (cAliasGW1)->(!Eof())
		GWN->(dbGoTo((cAliasGW1)->RECNOGWN))
		FWExecView("Visualizar", "GFEC050", 1,, {||.T.})
	EndIf
	(cAliasGW1)->(dbCloseArea())
	RestArea(aAreaGWN)
Return Nil

//-------------------------------------------------------------------

Function GFEA32MARK(lMark)
	Local aAreaGWU   := (cAliGWU)->( GetArea() )
	Local aAreaGW1   := GW1->( GetArea() )
	Local cChave     := (cAliGWU)->GWU_FILIAL + (cAliGWU)->GWU_CDTPDC + (cAliGWU)->GWU_EMISDC + (cAliGWU)->GWU_SERDC + (cAliGWU)->GWU_NRDC + (cAliGWU)->GWU_SEQ
	Local cGWLChave  := (cAliGWU)->GWU_FILIAL + (cAliGWU)->GWU_CDTPDC + (cAliGWU)->GWU_EMISDC + (cAliGWU)->GWU_SERDC + (cAliGWU)->GWU_NRDC
	Local cGWUSeq    := (cAliGWU)->GWU_SEQ
	Local lErroMark  := .F.
	Local nDC        := 0
	Local nQtdVol    := 0

	Default lMark    := .F.

	If !oBrwGWU:IsMark(oBrwGWU:Mark()) .Or. lMark
		lMark := .T.
	EndIf

	// Comando para não permitir marcar dois trechos do mesmo documento
	dbSelectArea(cAliGWU)
	(cAliGWU)->(dbSetOrder(1))
	(cAliGWU)->(dbSeek(cGWLChave))
	Do While !(cAliGWU)->( Eof() ) .And. (cAliGWU)->GWU_FILIAL + (cAliGWU)->GWU_CDTPDC + (cAliGWU)->GWU_EMISDC + ;
			(cAliGWU)->GWU_SERDC + (cAliGWU)->GWU_NRDC == cGWLChave

		If (cAliGWU)->GWU_SEQ != cGWUSeq .And. (cAliGWU)->GWU_OK != "  "
			lErroMark := .T.
		EndIf
		dbSelectArea(cAliGWU)
		(cAliGWU)->( dbSkip() )
	EndDo

	If lMark .And. !lErroMark
		dbSelectArea(cAliGWU)
		(cAliGWU)->( dbSetOrder(1) )
		(cAliGWU)->( dbSeek(cChave) )

		lMark := GFEA32DCREL()
		If lMark
			nDC++
		EndIf
	EndIf

	If lErroMark
		dbSelectArea(cAliGWU)
		(cAliGWU)->(dbSetOrder(1))
		(cAliGWU)->(dbSeek(cChave))
		RecLock(cAliGWU, .F.)
		(cAliGWU)->GWU_OK := "  "
		(cAliGWU)->(MSUnlock())
		Help( ,, 'HELP',, "Não é possível marcar dois trechos do mesmo documento de carga em apenas uma ocorrência.", 1, 0)
	Else
		dbSelectArea(cAliGWU)
		(cAliGWU)->( dbSetOrder(1) )
		(cAliGWU)->( dbSeek(cChave) )
		Do While !(cAliGWU)->( Eof() ) .And. (cAliGWU)->GWU_FILIAL + (cAliGWU)->GWU_CDTPDC + (cAliGWU)->GWU_EMISDC + ;
				(cAliGWU)->GWU_SERDC + (cAliGWU)->GWU_NRDC + (cAliGWU)->GWU_SEQ == cChave

			RecLock(cAliGWU, .F.)
			(cAliGWU)->GWU_OK := IIf(lMark, oBrwGWU:Mark(), "  ")
			(cAliGWU)->(MSUnlock())

			GFEA32MOD()

			nDC++

			(cAliGWU)->( dbSkip() )
		EndDo

		GW1->(dbSetOrder(1))
		If GfeVerCmpo({"GWD_QTDVOL"})
			(cAliGWU)->( dbSetOrder(3) )
			(cAliGWU)->( dbSeek(oBrwGWU:Mark()) )
			Do While !(cAliGWU)->( Eof() ) .And. (cAliGWU)->GWU_OK == oBrwGWU:Mark()
				If GW1->(dbSeek((cAliGWU)->(GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC)))
					nQtdVol += GW1->GW1_QTVOL
				EndIf
				(cAliGWU)->( dbSkip() )
			EndDo
			oViewOco:GetModel():GetModel("GFEA032_GWD"):SetValue("GWD_QTDVOL"  , nQtdVol)
		EndIf
	EndIf

	RestArea(aAreaGWU)

	If nDc > 1
		oBrwGWU:Refresh()
	EndIf
	RestArea(aAreaGW1)
Return Nil

//-------------------------------------------------------------------

Function GFEA32MOD()
	Local oModelGWL  := Nil
	Local aSaveLn    := FWSaveRows()
	Local aTotLen    := {}
	Local oModel     := FWMODELACTIVE()
	Local lCpoSrGW1  := GfeVerCmpo({"GW1_SDOC"})

	If Empty(oViewOco)
		oViewOco := FWViewActive()
	EndIf

	oModelGWL := oViewOco:GetModel():GetModel("GFEA032_GWL")
	aTotLen   := oModelGWL:Length() + 1

	If oBrwGWU:IsMark(oBrwGWU:Mark()) //Marcando
		If oModelGWL:SeekLine({{"GWL_NRDC", (cAliGWU)->GWU_NRDC}, {"GWL_FILDC", (cAliGWU)->GWU_FILIAL}, ;
				{"GWL_EMITDC", (cAliGWU)->GWU_EMISDC}, {"GWL_SERDC", (cAliGWU)->GWU_SERDC}, ;
				{"GWL_TPDC", (cAliGWU)->GWU_CDTPDC}, {"GWL_SEQ",(cAliGWU)->GWU_SEQ}})

			oModelGWL:UndeleteLine()
			oViewOco:SetModified(.T.)
		ElseIf !oModelGWL:IsEmpty()
			If oModelGWL:AddLine() != aTotLen
				Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0)
			Else
				oModelGWL:SetValue("GWL_NRDC"  , (cAliGWU)->GWU_NRDC)
				oModelGWL:SetValue("GWL_FILDC" , (cAliGWU)->GWU_FILIAL)
				oModelGWL:SetValue("GWL_EMITDC", (cAliGWU)->GWU_EMISDC)
				oModelGWL:SetValue("GWL_SERDC" , (cAliGWU)->GWU_SERDC)
				oModelGWL:SetValue("GWL_TPDC"  , (cAliGWU)->GWU_CDTPDC)
				oModelGWL:SetValue("GWL_SEQ"   , (cAliGWU)->GWU_SEQ)
				If lCpoSrGW1
					oModelGWL:SetValue("GWL_SDOCDC",(cAliGWU)->GWU_SDOC)
				EndIf
				oViewOco:SetModified(.T.)
			EndIf
		ElseIf oModelGWL:IsEmpty()
			oModelGWL:GoLine(1)
			oModelGWL:SetValue("GWL_NRDC"  , (cAliGWU)->GWU_NRDC)
			oModelGWL:SetValue("GWL_FILDC" , (cAliGWU)->GWU_FILIAL)
			oModelGWL:SetValue("GWL_EMITDC", (cAliGWU)->GWU_EMISDC)
			oModelGWL:SetValue("GWL_SERDC" , (cAliGWU)->GWU_SERDC)
			oModelGWL:SetValue("GWL_TPDC"  , (cAliGWU)->GWU_CDTPDC)
			oModelGWL:SetValue("GWL_SEQ"   , (cAliGWU)->GWU_SEQ)
			If lCpoSrGW1
				oModelGWL:SetValue("GWL_SDOCDC",(cAliGWU)->GWU_SDOC)
			EndIf
			oViewOco:SetModified(.T.)
		EndIf
	Else //Desmarcando
		If oModelGWL:SeekLine({{"GWL_NRDC", (cAliGWU)->GWU_NRDC}, {"GWL_FILDC", (cAliGWU)->GWU_FILIAL}, ;
				{"GWL_EMITDC", (cAliGWU)->GWU_EMISDC}, {"GWL_SERDC", (cAliGWU)->GWU_SERDC}, ;
				{"GWL_TPDC", (cAliGWU)->GWU_CDTPDC}})
			oModelGWL:DeleteLine()
			oViewOco:SetModified(.T.)
		EndIf
	EndIf
	FWRestRows(aSaveLn)
Return

//-------------------------------------------------------------------

Function GFEA032APR()
	Local oDlg       :=  Nil
	Local cSitDoc    := .T.
	Local lSimula    := PodeSimularOcorrencia(.F.)
	Local lRet       := .T.
	Local cDcOco     := .F.
	Local s_GFEA032E := ExistBlock("GFEA032E")
	Local s_GFEA032G := ExistBlock("GFEA032G")
	Local cSituacao  := Space(20)

	Private cTexto1   := ""
	Private cTexto2   := ""
	Private nRadio    := 0
	Private cTipoCalc := ""

	cTexto2 := GWD->GWD_DSPROB

	If lSimula
		cTipoCalc := TipoCalc(.F.)
	EndIf

	If Alltrim(GWD->GWD_SIT) == "1"
		cSituacao := "1 - Pendente"
	ElseIf Alltrim(GWD->GWD_SIT) == "2"
		cSituacao := "2 - Aprovada"
	Else
		cSituacao := "3 - Reprovada"
	EndIf

	// Início Ponto de Entrada
	If s_GFEA032E
		lRet := ExecBlock("GFEA032E",.F.,.F.,)
	EndIf

	If lRet
		dbSelectArea("GU5")
		GU5->(dbSetOrder(1))
		GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
		If GU5->GU5_EVENTO == "1"

			dbSelectArea("GWL")
			GWL->(dbSetOrder(1))
			GWL->(dbSeek(xFilial("GWL")+GWD->GWD_NROCO))
			Do While !Eof() .And. xFilial("GWL") == GWL->GWL_FILIAL .And. GWL->GWL_NROCO == GWD->GWD_NROCO
				cDcOco := .T.

				dbSelectArea("GW1")
				GW1->(dbSetOrder(1))
				GW1->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
				If !(GW1->GW1_SIT $ '456')
					GFEMsgErro("Situação do documento de carga, série: " + GWL->GWL_SERDC +" número: " +GWL->GWL_NRDC+ " não permite ocorrências aprovadas.")
					cSitDoc := .F.
				Endif

				dbSelectArea("GWL")
				GWL->(dbSkip())
			EndDo

			If !cDcOco
				GFEMsgErro("Não foram encontrados documentos de carga vinculados a ocorrência.")
				cSitDoc := .F.
			Endif
		Endif

		If cSitDoc
			If GWD->GWD_SIT == "1"

				DEFINE MSDIALOG oDlg TITLE STR0014 From 4,0 To 35,60 OF oMainWnd				 //"Aprovar\Reprovar" //"Aprovar\Reprovar"
				@ 03, 006  SAY STR0017 SIZE 30,7 PIXEL OF oDlg  //"Ocorrência:"
				@ 02, 036 MSGET GWD->GWD_NROCO When .F. SIZE 40,7 PIXEL OF oDlg

				nRadio := 1
				aItens := {STR0018,STR0019} //'Aprovar'###'Reprovar'
				oRadio := TRadMenu():New(02,140,aItens,,oDlg,,,,,,,,100,42,,,,.T.)
				oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

				@ 22, 006 SAY "Dt Criação"  SIZE 40,7 PIXEL OF oDlg
				@ 22, 060 SAY "Hr Criação"  SIZE 40,7 PIXEL OF oDlg
				@ 22, 106 SAY "Situação"    SIZE 40,7 PIXEL OF oDlg
				@ 22, 160 SAY "Usr Criação" SIZE 40,7 PIXEL OF oDlg
				@ 30, 006 MSGET GWD->GWD_DTCRIA	When .F. SIZE 43,7 PIXEL OF oDlg Hasbutton
				@ 30, 060 MSGET GWD->GWD_HRCRIA	When .F. SIZE 10,7 PIXEL OF oDlg
				@ 30, 106 MSGET cSituacao 	    When .F. SIZE 40,7 PIXEL OF oDlg
				@ 30, 160 MSGET GWD->GWD_USUCRI When .F. SIZE 60,7 PIXEL OF oDlg

				If GFXCP12130("GWD_URLENT") .And. !isBlind()
					@ 47, 006 SAY "Evidencia Entrega" SIZE 70,7 PIXEL OF oDlg
					@ 55, 006 MSGET GWD->GWD_URLENT	When .F. SIZE 225,7 PIXEL OF oDlg
				EndIf

				@ 073, 006  SAY STR0015 SIZE 25,7 PIXEL OF oDlg //"Motivo :" //"Problema:"
				@ 143, 006  SAY STR0016 SIZE 20,7 PIXEL OF oDlg //"Motivo :" //"Solução:"

				oTMultiget1 := TMultiget():New(080,06,{|u|if(Pcount()>0,cTexto2:=u,cTexto2)}, oDlg,225,60,,,,,,.T.,,,,,,.T.)
				oTMultiget2 := TMultiget():New(150,06,{|u|if(Pcount()>0,cTexto1:=u,cTexto1)}, oDlg,225,60,,,,,,.T.)


				oButtonOK   :=tButton():New(215,5,'OK',oDlg,{|| if(GFEAPROV(),oDlg:End(),oDlg:End())},25,10,,,,.T.)
				oButtonCanc :=tButton():New(215,35,STR0020,oDlg,{||(oDlg:End())},25,10,,,,.T.) //'Cancelar'

				If lSimula .And. !Empty(cTipoCalc)
					tButton():New(215,65,"Simular",oDlg,{||GFEA032CA(GWD->GWD_NROCO, cTipoCalc,,,lSimula)},25,10,,,,.T.)
				EndIf

				ACTIVATE MSDIALOG oDlg
			Else
				GFEMsgErro(STR0021)  //"Ocorrência já foi aprovada\reprovada"
			EndIf
		Endif
	Endif

	If cSitDoc .AND. s_GFEA032G
		ExecBlock("GFEA032G",.F.,.F.,{})
	EndIf

Return

//-------------------------------------------------------------------

//
// Retorna em ponto de controle corrente da operação
//
Function GFEA32PCAT()
	Local cOp    := ""
	Local lLast  := .F.
	Local aChave := {}
	Local cOcor  := ""

	aAreaGWD := GWD->( GetArea() )

	dbSelectArea("GX4")
	GX4->( dbSetOrder(4) )
	GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV) )
	Do While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GWD->GWD_NRMOV
		aChave := {GX4->GX4_CDPTCT, GX4->GX4_SEQ}
		If lLast
			dbSelectArea("GX4")
			GX4->( dbSkip() )
			Loop
		EndIf

		If GX4->GX4_SIT == "1"
			cOp := "1"
		ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
			cOp := "2"
		ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
			cOp := "3"
		ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
			cOp := "4"
		ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
			cOp := "5"
		EndIf

		cOcor := GFEA519BIM(GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)

		If cOp $ "124"
			Exit
		Else
			If cOp == "5" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "1"
				If cOcor == "3"
					lLast  := .T.
				ElseIf cOcor $ "0;1"
					Exit
				EndIf
			EndIf
		EndIf

		dbSelectArea("GX4")
		GX4->( dbSkip() )
	EndDo
	RestArea(aAreaGWD)
Return aChave

//-------------------------------------------------------------------
/*
Verifica se o ponto de controle é o último da movimentação/CONFIGURAÇÃO DE OPERAÇÃO
*/
Function GFEA32PCP(cPtCt, cSeq, cOper, cOpSeq)
	Local aAreaGVJ := GVJ->( GetArea() )
	Local cChave   := xFilial("GVJ") + cOper + cOpSeq
	Local aPts := {}
	Local lRet := .F.

	dbSelectArea("GVJ")
	GVJ->( dbSetOrder(1) )

	//
	// Verifica se é o índice antigo
	//
	If GVJ->(IndexKey()) == "GVJ_FILIAL+GVJ_CDOPER+GVJ_SEQ+GVJ_CDPTCT+GVJ_ORDEM"

		If GVJ->( dbSeek(cChave) )
			Do While GVJ->( !Eof() ) .And. ;
					GVJ->GVJ_FILIAL == xFilial("GVJ") .And. ;
					GVJ->GVJ_CDOPER == cOper .And. ;
					GVJ->GVJ_SEQ == cOpSeq

				aAdd(aPts, { GVJ->GVJ_CDPTCT, GVJ->GVJ_ORDEM })

				GVJ->( dbSkip() )
			EndDo

			aSort(aPts, , ,{|x, y| x[2] <  y[2]})

			If AllTrim(aPts[Len(aPts)][1]) == AllTrim(cPtCt) .And.  aPts[Len(aPts)][2] == cSeq
				lRet := .T.
			EndIf
		EndIf
	Else
		If GVJ->( dbSeek(cChave + cSeq) )
			GVJ->( dbSkip() )
			If cChave != (GVJ->GVJ_FILIAL + GVJ->GVJ_CDOPER + GVJ->GVJ_SEQ)
				lRet := .T.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaGVJ)
Return lRet

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEAPROV()
	Local lRet       := .T.
	Local lPass      := .F.
	Local cMsgErro   := ""
	Local cGX4Seq    := ""
	Local cSituacao  := ""
	Local aAreaTmp   := {}
	Local s_GFEA0321 := ExistBlock("GFEA0321")
	Local s_GFEA032B := ExistBlock("GFEA032B")
	Local cAliasGU5  := ""
	Local cAliasEnt  := ""
	Local cDocPEntr  := " "
	Local cRecPrz	 := SuperGetMV("MV_RECPRZ", .F., "0")
	Local dDtPEnt    := ctod("")
	Local cHrPEnt    := ""
	Local lMsg 		 := .T.
	Local cQuery	 := ""
	Local cAliasGU5  
	Local oQry 
	
	Private cNovoNrCalc := ""

	If Empty(cTexto1)
		GFEMsgErro(STR0022)  //"Informe uma solução"
		Return .F.
	EndIf

	If nRadio == 1
		cSituacao := "2" // APROVAR
	Else
		cSituacao := "3" // REPROVAR
	EndIf

	lFindGU5 := .F.
	cQuery := "SELECT GU5.GU5_EVENTO,"
	cQuery += " GU5.GU5_TPCALC,"
	cQuery += " GU5.GU5_INDEN,"
	cQuery += " GU5.GU5_CANCDC,"
	cQuery += " GU5.GU5_INTTMS"
	cQuery += " FROM " + RetSqlName("GU5") + " GU5"
	cQuery += " WHERE GU5.GU5_FILIAL = ?"
	cQuery += " AND GU5.GU5_CDTIPO   = ?"
	cQuery += " AND GU5.D_E_L_E_T_   = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetNumeric(1,xFilial("GU5")) 
	oQry:SetString(2,GWD->GWD_CDTIPO)
	cAliasGU5 := oQry:OpenAlias()

	If (cAliasGU5)->(!Eof())
		cEvento  := (cAliasGU5)->GU5_EVENTO
		cTpCalc  := (cAliasGU5)->GU5_TPCALC
		cInDen   := (cAliasGU5)->GU5_INDEN
		cCancDc  := (cAliasGU5)->GU5_CANCDC
		cIntTMS  := (cAliasGU5)->GU5_INTTMS
		lFindGU5 := .T.
	EndIf
	(cAliasGU5)->(dbCloseArea())

	//Início da transação.
	//Caso haja geração de cálculo na aprovação da ocorrência (reentrega, devolução ou serviço), a transação deve garantir que a aprovação
	//só será feita em conjunto com o cálculo.
	//Cria o temporário fora da transação, evita erro fwtemporarytable
	XFUNBTRB()
	XFUNCTAB()

	BeginTran()
		If lFindGU5
			If nRadio == 1
				If cEvento == "1"
					If cTpCalc == "1" //reeentrega
						cTipoCalc := "4"
						lRet := GFEA032CA(GWD->GWD_NROCO, cTipoCalc)

					ElseIf cTpCalc == "2" // devolução
						cTipoCalc := "5"
						lRet := GFEA032CA(GWD->GWD_NROCO, cTipoCalc)

					Elseif cTpCalc == "3" //serviço
						cTipoCalc := "7"
						lRet := GFEA032CA(GWD->GWD_NROCO, cTipoCalc)

						// Quando o nValorTot ficou zerado, a função GFEA032CA já emitiu um Help de erro, o restante das validações não são necessários
						If !lRet .And. nValorTot <= 0
							lRet := .F.
						EndIf
					EndIf

				ElseIf GFXCP12121("GWD_PESO")
					If cInDen == "2"
						aRet := GFECalInd(GWD->GWD_FILIAL, GWD->GWD_NROCO, "2")
						If aRet[1] == .F.
							GFEMsgErro(aRet[2])
							lRet := .F.
						EndIf
					ElseIf cInDen == "3"
						aRet := GFECalInd(GWD->GWD_FILIAL, GWD->GWD_NROCO, "3")
						If aRet[1] == .F.
							GFEMsgErro(aRet[2])
							lRet := .F.
						EndIf
					EndIf
				EndIf

				If lRet
					If cCancDc == "1"
						GWL->(dbSetOrder(1))
						GWL->(dbSeek(xFilial("GWL")+GWD->GWD_NROCO))
						Do While GWL->( !Eof()) .And. GWL->(GWL_FILIAL+GWL_NROCO) == xFilial("GWL")+GWD->GWD_NROCO
							GW1->(dbSetOrder(1))
							If GW1->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
								RecLock(("GW1"),.F.)
								GW1->GW1_SIT := "8"
								GW1->(MsUnLock())
							EndIf

							GWL->(dbSkip())
						Enddo
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet
			If lFindGU5
				If nRadio == 1
					If cEvento == "4"
						cMsgErro := GFE32REGET()
						If !Empty(cMsgErro)
							GFEMsgErro(cMsgErro)
							lRet := .F.
						EndIf
					ElseIf cEvento == "5"
						If _lGWL_SEQ
							cQuery := "SELECT GWU.R_E_C_N_O_ RECNOGWU"
							cQuery += " FROM " + RetSqlName("GWL") + " GWL"
							cQuery += " INNER JOIN " + RetSqlName("GWU") + " GWU"
							cQuery += " ON GWU.GWU_FILIAL = GWL.GWL_FILDC"
							cQuery += " AND GWU.GWU_CDTPDC = GWL.GWL_TPDC"
							cQuery += " AND GWU.GWU_EMISDC = GWL.GWL_EMITDC"
							cQuery += " AND GWU.GWU_SERDC = GWL.GWL_SERDC"
							cQuery += " AND GWU.GWU_NRDC = GWL.GWL_NRDC"
							cQuery += " AND GWU.GWU_SEQ = GWL.GWL_SEQ"
							cQuery += " AND GWU.D_E_L_E_T_ = ''"
							cQuery += " WHERE GWL.GWL_FILIAL = ?"
							cQuery += " AND GWL.GWL_NROCO = ?"
							cQuery += " AND GWL.D_E_L_E_T_ = ''"

							cQuery := ChangeQuery(cQuery)
							oQry := FWExecStatement():New(cQuery) 
							oQry:SetNumeric(1,GWD->GWD_FILIAL) 
							oQry:SetNumeric(2,GWD->GWD_NROCO) 
							cAliasEnt := oQry:OpenAlias()

							Do While (cAliasEnt)->(!Eof())
								GWU->(dbGoTo((cAliasEnt)->RECNOGWU))

								dDtPEnt := GWU->GWU_DTPENT
								cHrPEnt := GWU->GWU_HRPENT
								
								// Gravação de registro anterior na tabela GW0 para possivel estorno								
								cQuery := "SELECT GW0.R_E_C_N_O_"
								cQuery += " FROM " + RetSqlName("GW0") + " GW0"
								cQuery += " WHERE GW0.GW0_FILIAL = ?"
								cQuery += " AND GW0.GW0_TABELA = ?"
								cQuery += " AND GW0.GW0_CHAVE = ?"
								cQuery += " AND GW0.GW0_CHAR02 = ?"
								cQuery += " AND GW0.D_E_L_E_T_ = ''"

								cQuery := ChangeQuery(cQuery)
								oQry := FWExecStatement():New(cQuery)
								oQry:SetNumeric(1,GWU->GWU_FILIAL) 
								oQry:SetString(2,'GWU') 
								oQry:SetString(3,GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ) + GWD->(GWD_FILIAL+GWD_NROCO)) 
								oQry:SetString(4,GWD->(GWD_FILIAL+GWD_NROCO) + DtoS(GWD->GWD_DTOCOR)) 
								cAliasGW0 := oQry:OpenAlias()

								If (cAliasGW0)->(EoF())
									RecLock("GW0", .T.)
									GW0->GW0_FILIAL := xFilial("GW0")
									GW0->GW0_TABELA := 'GWU'
									GW0->GW0_CHAVE  := GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ) + GWD->(GWD_FILIAL+GWD_NROCO)
									GW0->GW0_CHAR02 := GWD->(GWD_FILIAL+GWD_NROCO + DtoS(GWD_DTOCOR))
									GW0->GW0_DATA01 := GWU->GWU_DTPENT
									GW0->GW0_CHAR01 := GWU->GWU_HRPENT
									GW0->( MsUnlock() )
								EndIf
								(cAliasGW0)->(dbCloseArea())

								cDocPEntr += "Doc./Seq. " + Alltrim(GWU->GWU_NRDC) + "-" + Alltrim(GWU->GWU_SEQ) +;
							 	 			" Data/Hora Prevista: " + Iif(!Empty(GWU->GWU_DTPENT), (Dtoc(GWU->GWU_DTPENT) +  " " + Alltrim(GWU->GWU_HRPENT)), "Não Informado") + CRLF

								RecLock("GWU", .F.)
									GWU->GWU_DTPENT = GWD->GWD_DTOCOR
									GWU->GWU_HRPENT = GWD->GWD_HROCOR
								GWU->(MsUnlock())
								
								// -----------------------------------------------------------------------------------------
								// Verifica se existe mais de 1 trecho para atualizar prazo de entrega dos demais trechos
								// -----------------------------------------------------------------------------------------
								If Posicione("GU5", 1, xFilial("GU5") + GWD->GWD_CDTIPO, "GU5_EVENTO") == "5" // Reagendar Entrega
									If cRecPrz == "1"
										If dDtPEnt < GWD->GWD_DTOCOR .Or. (dDtPEnt == GWD->GWD_DTOCOR .And. cHrPEnt < GWD->GWD_HROCOR)
											RecPrzTrec( GWU->(Recno()), GWD->GWD_DTOCOR, Alltrim(GW0->GW0_CHAR01))
										EndIf
									ElseIf cRecPrz == "2"
										RecPrzTrec( GWU->(Recno()), GWD->GWD_DTOCOR, GWD->GWD_HROCOR)
									EndIf
								EndIf

								(cAliasEnt)->(dbSkip())
							EndDo

							// Grava historico de dados previstos para entrega em tabela de log
							If !Empty(cDocPEntr)
								cTexto1 += CRLF + CRLF + "Historico previsão de entrega:" + CRLF + cDocPEntr
							EndIf

							(cAliasEnt)->(dbCloseArea())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			aChave := GFEA32PCAT()

			GWL->(dbSetOrder(1))
			If GWL->(dbSeek(xFilial("GWL")+GWD->GWD_NROCO)) .Or. cEvento == "3"
				lPass := .T.
				RecLock("GWD",.F.)
					GWD->GWD_DSSOLU:= cTexto1
					GWD->GWD_SIT   := cSituacao
					GWD->GWD_HRBAI := TIME()
					GWD->GWD_DTBAI := dDataGWD()
					GWD->GWD_USUBAI:= cUserName
					If GfeVerCmpo({"GU5_INTTMS"}) .And. cIntTMS  == "2" .And. nRadio == 1 .And. (!GFXCP12117("GWD_CHVEXT") .Or. Empty(GWD->GWD_CHVEXT))
						GWD->GWD_SITTMS := "2"
						GWD->GWD_DTTMS := DDATABASE
						
						//Se integração automática da ocorrência
						If SuperGetMv("MV_GFEI22" ,.F.,"2") == "1"
							GFE032TMSINT()
						EndIf
					EndIf
				GWD->(MsUnLock())
				//Ponto de entrada Vicunha
				If s_GFEA032B
					ExecBlock("GFEA032B",.f.,.f.,{GWD->GWD_NROCO,cSituacao,1})
				EndIf
			Else
				GFEMsgErro(STR0023)  //"Ocorrência sem documentos de carga"
				lRet := .F.
			EndIf
		Else
			If lFindGU5
				If cEvento <> "3"
					GFEMsgErro(STR0076) //"Apenas é permitido criar ocorrência sem documento de carga, quando o evento do tipo da ocorrência for 'Simples Registro'. Para ocorrências que possuem somente documentos entregues, algumas operações não são permitidas."
					lRet := .F.
				Else
					lPass := .T.
					RecLock("GWD",.F.)
						GWD->GWD_DSSOLU := cTexto1
						GWD->GWD_SIT    := cSituacao
						GWD->GWD_HRBAI  := TIME()
						GWD->GWD_DTBAI  := dDataGWD()
						GWD->GWD_USUBAI := cUserName
					GWD->(MsUnLock())
				EndIf
			EndIf
		EndIf
		//Fim da transação
	
		GFE032AUDIT(GWD->GWD_FILIAL, GWD->GWD_NROCO, lMsg)
		If GWD->GWD_SIT == "2"
			GF32EVEOCO("APROVACAO",GWD->GWD_FILIAL,GWD->GWD_NROCO) //Evento de ocorrência
		EndIf
		If !lRet
			DisarmTransaction()
			//Cria o temporário fora da transação, evita erro fwtemporarytable
			XFUNCDTAB()

			XFUNBDLTRB()
		EndIf
	EndTran()
	If lRet
		//Cria o temporário fora da transação, evita erro fwtemporarytable
		XFUNCDTAB()

		XFUNBDLTRB()
		
		// CONTINUAR
		If cSituacao == "2" .And. !Empty(aChave)
			If aChave[1] == GWD->GWD_CDPTCT
				GX4->( dbSetOrder(1) )
				If GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV + GWD->GWD_CDPTCT + aChave[2]) )
					If !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "3" //.And. ;
						//Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "1"
						aAreaTmp := GX4->(GetArea())
						GX4->( dbSetOrder(4) )
						If GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV ) )
							Do While GX4->( !Eof() ) .And. xFilial("GX4") == GX4->GX4_FILIAL .And. GX4->GX4_NRMOV == GWD->GWD_NRMOV
								cGX4Seq := GX4->GX4_SEQ
								GX4->( dbSkip() )
							EndDo
						EndIf
						RestArea(aAreaTmp)
						// Verifica se GX4_SEQ é o ultimo.. Se sim.... (GX3) deve ser concluído
						If cGX4Seq == GX4->GX4_SEQ
							GX3->( dbSetOrder(1) )
							If GX3->( dbSeek(xFilial("GX3") + GWD->GWD_NRMOV ) )
								// GX3_SIT >>>> 1=Aberto;2=Movimentado;3=Em Fila;4=Enderecado;5=Cancelado;6=Concluido
								RecLock("GX3", .F.)
									GX3->GX3_SIT := "6"
								GX3->(MsUnlock())
							EndIf
						EndIf
						// GX4_SIT   -> 1=Nao avaliado; 2=Aprovado; 3=Reprovado
						// Continuar -> GX4_SIT do ponto de controle da movimentação como aprovado
						RecLock("GX4", .F.)
							GX4->GX4_SIT := "2"
							GX4->GX4_REPUSU := cUserName
						GX4->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf

		// Reprova OCORRENCIA
		If cSituacao == "3" .And. !Empty(aChave)

			GX4->( dbSetOrder(1) )
			If GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV + GWD->GWD_CDPTCT ) )

				GX3->( dbSetOrder(1) )
				If GX3->( dbSeek(xFilial("GX3") + GWD->GWD_NRMOV ) )

					GVJ->( dbSetOrder(2) ) // GVJ_FILIAL+GVJ_ORDEM+GVJ_CDPTCT+GVJ_CDOPER+GVJ_SEQ
					If GVJ->( dbSeek(xFilial("GVJ") + GX4->GX4_SEQ + GX4->GX4_CDPTCT + GX3->GX3_CDOPER + GX3->GX3_SEQ ) )

						// GVJ_REPOCO -- 1=Cancelar Movimentacao;
						If GVJ->GVJ_REPOCO == "1"
							// Cancelar  -> GX3_SIT da movimentação corrente deve utilizar o status "Cancelado"
							RecLock("GX3", .F.)
								GX3->GX3_SIT := "5"
							GX3->(MsUnlock())
							RecLock("GX4", .F.)
								GX4->GX4_REPUSU := cUserName
							GX4->(MsUnlock())
						EndIf

						// GVJ_REPOCO -- 2=Retornar ao Ponto Anterior
						If GVJ->GVJ_REPOCO == "2"
							// .... copiado da FUNCTION GFEA519BRP()
							// ########### INICIO ###########
							GX4->( dbSetOrder(4) )
							If GX4->( dbSeek(xFilial("GX4") + GX4->GX4_NRMOV + GX4->GX4_SEQ ) )

								If Val(GX4->GX4_SEQ) == 1
									Help( ,, 'HELP',, "Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior.", 1, 0)
									Return lRet
								EndIf
								RecLock("GX4",.F.)
								GX4->GX4_SIT	:= "1"
								GX4->GX4_DTENTR	:= CToD("  /  /    ")
								GX4->GX4_HRENTR	:= ""
								GX4->GX4_REPUSU := cUserName
								
								GVK->( dbSetOrder(2) )
								If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV+ GX4->GX4_CDPTCT + GX4->GX4_SEQ) )

									GFEA519RGK()// Remove da fila do endereçamento

								ElseIf !Empty(GX4->GX4_DTCHEN) .And. Empty(GX4->GX4_DTLIEN)
									GFEA519BPF(GX4->GX4_CDENDE)// Desfaz endereçamento
								EndIf
								A523CanEnd() // Desfaz endereçamento
								GX4->(MSUnlock())
								
								GX4->( dbSetOrder(4) )
								If GX4->( dbSeek(xFilial("GX4") + GX4->GX4_NRMOV + StrZero(Val(GX4->GX4_SEQ)-1, 3)) )
									RecLock("GX4", .F.)
										GX4->GX4_DTSAI := CToD("  /  /    ")
										GX4->GX4_HRSAI := ""
										GX4->GX4_SIT   := "1"
									GX4->(MSUnlock())
								EndIf
								RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
								GX3->(MSUnlock())
							EndIf
							// ########### FIM ###########
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If s_GFEA0321
			ExecBlock("GFEA0321",.F.,.F.)
		EndIf
	EndIf
Return lRet

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
function GFEADCOK(oView)
	Local oDlg        := Nil
	Local oModelGWD   := FWMODELACTIVE()
	local nOpc        := (oModelGWD:GetOperation())
	Local oModelGWL   := oView:GetModel("GFEA032_GWL")
	Local cNrDoc      := oModelGWL:GetValue('GWL_NRDC')

	Private nOrigemDC := 0

	If nOpc == 3 .or. nOpc == 4
		 If !empty(cNrDoc)
			DEFINE MSDIALOG oDlg TITLE STR0024 From 4,0 To 13,45 OF oMainWnd				 //"Aprovar\Reprovar" //"Doc. Relacionados"
					@ 03, 006  SAY STR0025 SIZE 150,7 PIXEL OF oDlg  //"Origem dos Documentos de Cargas relacionados:"
					nOrigemDC := 1
					aItens := {STR0026,STR0027} //'Cálculo de Frete'###'Romaneio de Carga'
					oRadio := TRadMenu():New(20,80,aItens,,oDlg,,,,,,,,60,32,,,,.T.)
					oRadio:bSetGet := {|u|Iif (PCount()==0,nOrigemDC,nOrigemDC:=u)}

					oButtonOK   :=tButton():New(050,5,'OK',oDlg,{|| if(GFEA032DCT(oView),oDlg:End(),NIL)},25,10,,,,.T.)
					oButtonCanc :=tButton():New(050,35,STR0020,oDlg,{||(oDlg:End())},25,10,,,,.T.) //'Cancelar'
			 ACTIVATE MSDIALOG oDlg
		Else
			Alert(STR0028) //"Selecione um Documento de Carga"
		EndIf
	EndIf
Return .T.

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032DCT(oView)
	Local oModelGWD	:= FWModelActive()
	Local oModelGWL := oModelGWD:GetModel( "GFEA032_GWL" )
	Local cNrDc     := ""
	Local cSerDc    := ""
	Local cTpDc     := ""
	Local cEmitDc   := ""
	Local lExist    := .F. // verifica se existe apenas um registro para o romaneio ou calculo
	Local lIgual    := .F. // Verifica se os elementos do array são iguais dos registros do grid
	Local nIgualTd  := 0
	Local cNrCalc   := ""
	Local cNrRom    := ""
	Local nCont     := 0
	Local nContA    := 0
	Local aArray    := {}
	Local nLineaUX  := 0
	Local aAreaGWH  := GWH->(GetArea())
	Local aAreaGWF  := GWF->(GetArea())
	Local aAreaGW1  := GW1->(GetArea())
	Local nSrGWL    := SerieNfId("GWL",6,"GWL_SERDC")
	Local nTamSrGWL := TamSx3("GWL_SERDC")[1]
	Local lCpoSrGW1 := GfeVerCmpo({"GW1_SDOC"})

	nLineaUX := oModelGWL:nLine
	For nCont := 1 to oModelGWL:GetQtdLine()
		oModelGWL:GoLine( nCont )
		If !oModelGWL:IsDeleted()
			cNrDc     := FwFldGet( 'GWL_NRDC'  )
			cSerDc    := FwFldGet( 'GWL_SERDC' )
			cTpDc     := FwFldGet( 'GWL_TPDC'  )
			cEmitDc   := FwFldGet( 'GWL_EMITDC')
			Exit
		 EndIf
	Next
	oModelGWL:GoLine( nLineaUX )

	If nOrigemDC == 1
		dbSelectArea("GWH")
		dbSetOrder(2)
		If dbSeek(xFilial("GWH")+cTpDc+cEmitDc+cSerDc+cNrDc)
			Do While !Eof() .And. xFilial("GWH")+cTpDc+cEmitDc+cSerDc+cNrDc == GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC
				dbSelectArea("GWF")
				dbSetOrder(1)
				if dbSeek(xFilial("GWF")+GWH->GWH_NRCALC)
					Do While !Eof() .And. xFilial("GWF")+GWH->GWH_NRCALC == GWF->GWF_FILIAL+GWF->GWF_NRCALC .And. Empty(cNrCalc)
						If GWF->GWF_TPCALC == '1'
							cNrCalc := GWH->GWH_NRCALC
						EndIf
						dbSkip()
					EndDo
				EndIf
				dbSelectArea("GWH")
				dbSkip()
			EndDo
		EndIf
		If !Empty(cNrCalc)
			dbSelectArea("GWH")
			dbSetOrder(1)
			dbSeek(xFilial("GWH")+cNrCalc)
			Do while !Eof() .and. GWH->GWH_NRCALC == cNrCalc
				If GWH->GWH_EMISDC+ GWH->GWH_CDTPDC + GWH->GWH_SERDC +GWH->GWH_NRDC != cEmitDc+cTpDc+cSerDc+cNrDc
					aAdd(aArray,{GWH->GWH_NRDC,GWH->GWH_FILIAL,GWH->GWH_EMISDC,GWH->GWH_SERDC,GWH->GWH_CDTPDC,SerieNfId("GWH",2,"GWH_SERDC")})
					lExist := .T.
				EndIf
				dbSelectArea("GWH")
				dbSkip()
			EndDo
			If !lExist
				GFEMsgErro(STR0045 +Alltrim(cNrCalc)+STR0046) //"O cálculo "###" possui apenas este Documento de carga."
				Return .F.
			EndIf
		Else
			GFEMsgErro(STR0047)	 //"Este Documento de Carga não possui cálculo do tipo 'Normal'."
			Return .F.
		EndIf
	Elseif nOrigemDC == 2
		DbSelectArea("GW1")
		DbSetOrder(1)
		If DbSeek(xFilial("GW1")+cTpDc+cEmitDc+cSerDc+cNRDC)
			cNrRom := GW1->GW1_NRROM
		EndIf
		if !Empty(cNrRom)
			dbSelectArea("GW1")
			dbSetOrder(9)
			dbSeek(xFilial("GW1")+cNrRom)
			Do While !Eof() .and. GW1->GW1_NRROM == cNrRom
					If	GW1->GW1_EMISDC+ GW1->GW1_CDTPDC + GW1->GW1_SERDC +GW1->GW1_NRDC + GW1->GW1_FILIAL != ;
						FwFldGet( 'GWL_EMITDC') + FwFldGet( 'GWL_TPDC') + FwFldGet( 'GWL_NRDC') + FwFldGet( 'GWL_FILDC')

						aAdd(aArray,{GW1->GW1_NRDC,GW1->GW1_FILIAL,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_CDTPDC,SerieNfId("GW1",2,"GW1_SERDC")})
						lExist := .T.
				 EndIf
				dbSelectArea("GW1")
				dbSkip()
			EndDo
			
			If !lExist
				GFEMsgErro(STR0048 +Alltrim(cNrRom)+STR0046) //"O romaneio "###" possui apenas este Documento de carga."
				Return .F.
			EndIf
		 Else
			GFEMsgErro(STR0049) //"Este Documento de Carga não possui romaneio."
			Return .F.
		 EndIf
	EndIf
	RestArea( aAreaGW1 )
	RestArea( aAreaGWF )
	RestArea( aAreaGWH )

	If Len(aArray) != 0
		For nContA := 1 to Len(aArray)
			lIgual := .F.
			nLineaUX := oModelGWL:nLine
			For nCont := 1 to oModelGWL:GetQtdLine()
				If !oModelGWL:IsDeleted()
					oModelGWL:GoLine( nCont )
					If aArray[nContA][1]+aArray[nContA][2]+aArray[nContA][3]+aArray[nContA][4]+aArray[nContA][5] == FwFldGet( 'GWL_NRDC' ) + FwFldGet( 'GWL_FILDC' ) + FwFldGet( 'GWL_EMITDC' ) + FwFldGet( 'GWL_SERDC' ) + FwFldGet( 'GWL_TPDC' )
						lIgual := .T.
						nIgualTd := nIgualTd + 1
					  EndIf
				  EndIf
			Next nCont
			oModelGWL:GoLine( nLineaUX )
			If !lIgual
				oModelGWL:AddLine()
				oModelGWL:SetValue("GWL_EMITDC",PadR(aArray[nContA][3], TamSx3("GWL_EMITDC")[1]))
				oModelGWL:LoadValue("GWL_EMITDC")
				oModelGWL:SetValue("GWL_TPDC"  ,PadR(aArray[nContA][5],5))
				oModelGWL:LoadValue("GWL_TPDC")
				oModelGWL:SetValue("GWL_SERDC" ,PadR(aArray[nContA][4],nTamSrGWL))
				oModelGWL:LoadValue("GWL_SERDC")
				oModelGWL:SetValue("GWL_NRDC"  ,PadR(aArray[nContA][1],16))
				oModelGWL:LoadValue("GWL_NRDC")
				oModelGWL:SetValue("GWL_FILDC" ,PadR(aArray[nContA][2],2))
				oModelGWL:LoadValue("GWL_FILDC")
				If lCpoSrGW1
					oModelGWL:SetValue("GWL_SDOCDC" ,PadR(aArray[nContA][6],nSrGWL))
					oModelGWL:LoadValue("GWL_SDOCDC")
				EndIf
			EndIf
		 Next nContA
		 If nIgualTd == Len(aArray)
			GFEMsgErro(STR0050) //"Todos os Documentos de Cargas relacionados por este critérios já foram relacionados."
			Return .F.
		 EndIf
	EndIf
	dbSelectArea("GWL")
	dbGotop()
	oModelGWL:SetLine(1)
Return .T.

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032VAL(oModel)
	Local oModelGWD  :=  oModel:GetModel("GFEA032_GWD")
	Local oModelGWL  :=  oModel:GetModel("GFEA032_GWL")
	Local nOpc       := (oModel:GetOperation())
	Local cNrOcor    := oModelGWD:GetValue( 'GWD_NROCO'  )
	Local cCdTipo    := oModelGWD:GetValue( 'GWD_CDTIPO' )
	Local cCdMot     := oModelGWD:GetValue( 'GWD_CDMOT'  )
	Local cNumDoc    := oModelGWL:GetValue( 'GWL_NRDC'   )
	Local nqtdeServ  := oModelGWD:GetValue( 'GWD_QTPERN' )
	Local cDocTrp    := ""
	Local cDocBase   := ""
	Local cChaveGWE  := FwFldGet('GWL_FILDC',1) + FwFldGet('GWL_TPDC',1) + FwFldGet('GWL_EMITDC',1) + FwFldGet('GWL_SERDC',1) + FwFldGet('GWL_NRDC',1)
	Local aDocSemRel := {}
	Local cErroMsg   := ""
	Local nLine      := 0
	Local cQuery     := ''
	Local cAliasQry  := Nil
	Local lRecorr    := .F.
	Local lExistRec  := .T.
	Local lExistVal  := .T.
	Local lCpoSrGW1  := TamSx3("GW1_SERDC")[1] == 14
	Local nIndGWL    := 2
	Local cExpGW1    := ""
	Local cExpGWL    := ""
	Local cSeekGWL   := ""
	Local nF         := 0
	Local aAreaGWD   :=  GWD->(GetArea())
	Local cChvExtTms := ""
	Local nCount     := 1
	Local lCallTMS   := .F.
	Local s_SERVTO   := SuperGetMV("MV_SERVTO",.F.,"2")
	Local cAliasEnt  := ""
	Local nQtdDC     := 0
	Local nLinha     := 0
	Local cDocPEntr  := " "
	Local cRecPrz	 := SuperGetMV("MV_RECPRZ",.F.,"0")
	Local nRecBkp	 := 0
	Local dDtPEnt  	 := ctod("")
	Local cHrPEnt  	 := ""
	Local oQry

	dbSelectArea("GU5")
	GU5->( dbSetOrder(1) )
	
	lExistRec := GfeVerCmpo({"GU5_RECOR"})
	lExistVal := GfeVerCmpo({"GU5_RECVAL"})
	
	If nOpc == 5
		If !Empty(oModelGWD:GetValue('GWD_NRMOV')) .And. !Empty(oModelGWD:GetValue('GWD_CDPTCT'))
			//verifica se o parâmetro "Permite Ocorrência" do ponto de controle informado esteja marcado
			GX4->(dbSetOrder(1))
			If GX4->(dbSeek(xFilial('GX4')+oModelGWD:GetValue('GWD_NRMOV')+oModelGWD:GetValue('GWD_CDPTCT')))
				GX3->(dbSetOrder(1))
				If GX3->(dbSeek(xFilial('GX3')+GX4->GX4_NRMOV))
					GFEMsgErro(STR0051) //"Não é permitido eliminar uma ocorrência que esteja relacionada a uma Movimentação"
				EndIf
			EndIf
		EndIf
		
		If GFXCP12117("GWD_CHVEXT") .And. !Empty(oModelGWD:GetValue('GWD_CHVEXT'))
			// Só permite eliminar se chamada por funcao do TMS
			Do While !Empty(ProcName(nCount))
				If "TMS" $ ProcName(nCount)  
					lCallTMS := .T.
				EndIf
				nCount++
			EndDo

			If !lCallTMS
				GFEMsgErro("Não é permitido eliminar uma ocorrência que foi gerada via integração") 
				Return .F.
			EndIf
		EndIf
	EndIf

	If nOpc == 3 .or. nOpc == 4
		//Valida o Transportador
		If !GFEA32VCO(oModelGWL,.T.)
			RestArea(aAreaGWD)
			Return .F.
		EndIf

		/* ----- Pátios e Portarias ------ */
		If !Empty(oModelGWD:GetValue('GWD_NRMOV')) .And. !Empty(oModelGWD:GetValue('GWD_CDPTCT'))
			//verifica se o parâmetro "Permite Ocorrência" do ponto de controle informado esteja marcado
			GX4->(dbSetOrder(1))
			If GX4->(dbSeek(xFilial('GX4')+oModelGWD:GetValue('GWD_NRMOV')+oModelGWD:GetValue('GWD_CDPTCT')))
				GVF->(dbSetOrder(1))
				If GVF->(dbSeek(xFilial('GVF')+GX4->GX4_CDPTCT))
					If GVF->GVF_IDOCOR != '1'
						GFEMsgErro(STR0052)	 //"Ponto de Controle não permite vincular ocorrência"
					EndIf
				EndIf
			EndIf
		ElseIf (Empty(oModelGWD:GetValue('GWD_NRMOV')) .Or. Empty(oModelGWD:GetValue('GWD_CDPTCT'))) .And. !(Empty(oModelGWD:GetValue('GWD_NRMOV')) .And. Empty(oModelGWD:GetValue('GWD_CDPTCT')))
			GFEMsgErro(STR0053)	 //"É necessário informar o Número da Movimentação e o Código do Ponto de Controle'"
		EndIf

		If lCpoSrGW1
			nIndGWL := 4 // GWL_FILIAL+GWL_NRDC+GWL_FILDC+GWL_EMITDC+GWL_SDOCDC+GWL_TPDC+GWL_NROCO
			cExpGW1 := "GW1->GW1_FILIAL+GW1->GW1_NRDC+GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SDOC+GW1->GW1_CDTPDC"
			cExpGWL := "GWL->GWL_FILIAL+GWL->GWL_NRDC+GWL->GWL_FILDC+GWL->GWL_EMITDC+GWL->GWL_SDOCDC+GWL->GWL_TPDC"
		Else
			nIndGWL := 2 // GWL_FILIAL+GWL_NRDC+GWL_FILDC+GWL_EMITDC+GWL_SERDC+GWL_TPDC+GWL_NROCO
			cExpGW1 := "GW1->GW1_FILIAL+GW1->GW1_NRDC+GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_CDTPDC"
			cExpGWL := "GWL->GWL_FILIAL+GWL->GWL_NRDC+GWL->GWL_FILDC+GWL->GWL_EMITDC+GWL->GWL_SERDC+GWL->GWL_TPDC"
		EndIf
		GWL->( dbSetOrder(nIndGWL) )

		GW1->(dbSetOrder(1))
		GWD->( dbSetOrder(1))
		nF := oModelGWL:GetQtdLine()
		For nLine := 1 To nF
			oModelGWL:GoLine(nLine)
			If !oModelGWL:IsDeleted()
				If GW1->(dbSeek(FwFldGet('GWL_FILDC',nLine)+FwFldGet('GWL_TPDC',nLine)+ FwFldGet('GWL_EMITDC',nLine) + FwFldGet('GWL_SERDC',nLine) + FwFldGet('GWL_NRDC',nLine)  ))
					If Empty(GW1->GW1_NRROM)
						GFEMsgErro(STR0029+". "+STR0030) //"Documento Inválido" "Documento não possui romaneio"
						Return .F.
					EndIf

					If Empty(GW1->GW1_DTSAI) .And. GU5->GU5_EVENTO != "3"
						GFEMessage(5,GFEA032001,GFEMsgFmt(STR0070,{{"[VAR01]",Alltrim(GW1->GW1_NRDC)}}),STR0071) //"O Documento de carga ## deve possuir data de saída para que a ocorrência seja registrada" , "Realize a liberação do Documento de Carga para continuar com a manutenção da ocorrência."
							Return .F.
					EndIf
					//Verifica se a data a ocorrencia é inferior a data da emissão do Doc. Carga
					If FWFldGet("GWD_DTOCOR") < GW1->GW1_DTEMIS
						GFEMessage(5,GFEA032002,STR0072,STR0073+CRLF+STR0074) //"A Data da ocorrencia é inferior a data da emissão do Doc. Carga." , " 1)Verifique se a data informada está correta., 2) Verifique se o Doc. Carga selecionado está correto."
						Return .F.
					EndIf
						dbSelectArea("GWN")
						dbSelectArea("GU5")
						GU5->(dbSeek(xFilial("GU5") + cCdTipo))
						GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )
						GWN->( dbSetOrder(1) )
						GU5->( dbSetOrder(1) )

					If GU5->GU5_EVENTO == "1" .And. GWN->GWN_CALC != "1"
						Help(,,'HELP',,"Para gerar Cálculo Adicional o documento de carga " + Alltrim(GW1->GW1_NRDC) + " deve estar Calculado e o Romaneio " + AllTrim(GW1->GW1_NRROM) + " deve estar Calculado com sucesso.",1,0)
						Return .F.
					EndIf
					If lExistRec .And. GU5->( dbSeek(xFilial("GU5") + FwFldGet("GWD_CDTIPO")) ) .And. GU5->GU5_RECOR == "2"
						cSeekGWL := &cExpGW1
						GWL->( dbSeek(cSeekGWL) )
						Do While !GWL->( Eof() ) .And. cSeekGWL == &cExpGWL
							If GWL->GWL_FILIAL == FwFldGet("GWD_FILIAL") .And. GWL->GWL_NROCO == FwFldGet("GWD_NROCO")
								GWL->( dbSkip() )
								Loop
							EndIf
							
							If GWD->( dbSeek(GWL->GWL_FILIAL + GWL->GWL_NROCO) )
								If GWD->GWD_SIT <> "3"
									If FwFldGet("GWD_CDTIPO") == GWD->GWD_CDTIPO
										lRecorr := .F.
										If !lExistVal
											lRecorr := .T.
										Else//GU5_RECVAL = 1=Tipo;2=Tipo e data/hora;3=Tipo e transportador;4=Tipo,transportador e data/hora;5=Tipo,motivo e resumo
											If Empty(GU5->GU5_RECVAL) .Or. GU5->GU5_RECVAL == "1"
												lRecorr := .T.
											ElseIf GU5->GU5_RECVAL == "2";
													.And. FwFldGet("GWD_DTOCOR") == GWD->GWD_DTOCOR .And. FwFldGet("GWD_HROCOR") == GWD->GWD_HROCOR
												lRecorr := .T.
											ElseIf GU5->GU5_RECVAL == "3";
													.And. FwFldGet("GWD_CDTRP") == GWD->GWD_CDTRP
												lRecorr := .T.
											ElseIf GU5->GU5_RECVAL == "4" .And. FwFldGet("GWD_CDTRP") == GWD->GWD_CDTRP;
													.And. FwFldGet("GWD_DTOCOR") == GWD->GWD_DTOCOR .And. FwFldGet("GWD_HROCOR") == GWD->GWD_HROCOR
												lRecorr := .T.
											ElseIf GU5->GU5_RECVAL == "5" .And. FwFldGet("GWD_CDTRP") == GWD->GWD_CDTRP;
													.And. FwFldGet("GWD_CDMOT") == GWD->GWD_CDMOT .And. FwFldGet("GWD_DSOCOR") == GWD->GWD_DSOCOR
												lRecorr := .T.
											EndIf
										EndIf
										If lRecorr
											GFEMsgErro("Conforme a validação do tipo de ocorrência, não é possível inserir uma recorrência." + CRLF + "Documento " + AllTrim(GW1->GW1_NRDC) + " possui outra ocorrência (" + AllTrim(GWL->GWL_NROCO) + ")")
											RestArea(aAreaGWD)
											Return .F.
										EndIf
									EndIf
								EndIf
							EndIf
							GWL->( dbSkip() )
						EndDo
						RestArea(aAreaGWD)
					EndIf
				Endif
			EndIf
		Next nLine

		GU5->(dbSetOrder(1))
		If GU5->(dbSeek(xFilial("GU5") + cCdTipo))
			If GU5->GU5_TPCALC == "3" //Serviço
				// Quando o tipo da ocorrência gera cálculo adicional, possui outro
				// prestador de serviço e deverá ser utilizada a tabela de frete do
				// Prestador o campo Prestador de Serviço na ocorrência não poderá estar em branco
				If GU5->GU5_EVENTO == "1" .and.;
					GfeVerCmpo({"GU5_PRESTS"}) .And. GU5->GU5_PRESTS == "1" .and.;
					GfeVerCmpo({"GU5_TABFRE"}) .And. GU5->GU5_TABFRE == "2" .and.;
					GfeVerCmpo({"GWD_PRESTS"}) .And. Empty(FwFldGet("GWD_PRESTS"))

					GFEMsgErro("Para este tipo de ocorrência gerar um cálculo de serviço é necessário que seja informado o Prestador de Serviço")
					Return .F.
				EndIf

				If nqtdeServ == 0
					If s_SERVTO == '2' //Serviço por tipo de ocorrência 1 = Sim, 2 = Não
						GFEMsgErro(STR0032) //"Informe Qtde de Serviço"
						Return .F.
					Else
						//Se gera serviço por tipo de ocorrência, deve verificar se algum
						//dos componentes gera cálculo por quantidade de serviço
						
						cQuery := "SELECT 1 "
						cQuery += " FROM " + RetSqlName("GV2") + " GV2"
						cQuery += " WHERE GV2.GV2_FILIAL = ?"
						cQuery += " AND GV2.GV2_CDCOMP = ?"
						cQuery += " AND GV2.GV2_ATRCAL = ?"
						cQuery += " AND GV2.D_E_L_E_T_ = ''"

						cQuery := ChangeQuery(cQuery)
						oQry := FWExecStatement():New(cQuery) 
						oQry:SetNumeric(1,xFilial("GV2")) 
						oQry:SetString(2,('"+GU5->GU5_SERV1+"','"+GU5->GU5_SERV2+"','"+GU5->GU5_SERV3+"'))
						oQry:SetString(3,'11') //Quantidade de serviço
						cAliasQry := oQry:OpenAlias()

						If (cAliasQry)->(!Eof())
							GFEMsgErro(STR0032) //"Informe Qtde de Serviço"
							(cAliasQry)->(dbCloseArea())
							Return .F.
						EndIf
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
			Else
				If nqtdeServ <> 0 
					GFEMsgErro(STR0033) //"Não é necessário informar Qtde de Serviço"
					Return .F.
				EndIf
			EndIf
		EndIf

		GU5->(dbSetOrder(1))
		If GU5->(dbSeek(xFilial("GU5") + cCdTipo))
			If GU5->GU5_SIT == "2"
				GFEMsgErro(STR0034)  //"Informe um tipo de ocorrência ativo"
				Return .F.
			EndIf
		EndIf

		GU4->(dbSetOrder(1))
		If !GU4->(dbSeek(xFilial("GU4")+cCdMot+cCdTipo))
			GFEMsgErro(STR0035)  //"Motivo não está relacionado ao tipo"
			Return .F.
		Else
			GU6->(dbSetOrder(1))
			if GU6->(dbSeek(xFilial("GU6")+cCdMot))
				if GU6->GU6_SIT == "2"
					GFEMsgErro(STR0036)  //"Informe um motivo de ocorrência ativo"
					Return .F.
				EndIf
			EndIf
		EndIf
		
		GU5->(dbSetOrder(1))
		If GU5->(dbSeek(xFilial("GU5") + cCdTipo))
			If GFXCP12121("GWD_PESO") .And. GFXCP12121("GU5_INFPES")
				If GU5->GU5_INFPES == "2" .And. Empty(FwFldGet("GWD_PESO"))
					GFEMsgErro("Obrigatório informar o Peso.")  
					Return .F.
				EndIf
			EndIf
		EndIf

		If nOpc != MODEL_OPERATION_DELETE ;
			.And. oModelGWL:Length() > 0 ;
			.And. SuperGetMv("MV_TMS2GFE",.F.,.F.) ;
			.And. GfeVerCmpo({"GU5_INTTMS"}) ;
			.And. !Empty(FwFldGet("GWD_CDTIPO")) ;
			.And. Posicione("GU5",1,xFilial("GU5") + FwFldGet("GWD_CDTIPO"), "GU5_INTTMS") == "2"

			GWE->(dbSetOrder(1))
			If GWE->(dbSeek(cChaveGWE))
				cDocTrp := GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
				cDocBase :=  "O Documento de Carga " + FwFldGet('GWL_SERDC',1) + "/" + FwFldGet('GWL_NRDC',1) + " está vinculado ao Documento de Transporte " + GWE->GWE_SERDT + "/" + GWE->GWE_NRDT +" que possui também os seguintes documentos de carga: "
				GWE->(dbSetOrder(2))
				GWE->(dbSeek(cDocTrp))
				Do While GWE->(!Eof()) .And. GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT) == cDocTrp
					If !oModelGWL:SeekLine({{"GWL_NRDC", GWE->GWE_NRDC},;
											{"GWL_FILDC", GWE->GWE_FILIAL},;
											{"GWL_EMITDC", GWE->GWE_EMISDC},;
							  				{"GWL_SERDC", GWE->GWE_SERDC},;
											{"GWL_TPDC", GWE->GWE_CDTPDC}}) ;
						.Or. oModelGWL:IsDeleted() // Tem na gwe mas não na gwl
	
						//Documentos de carga que estão em um doc transporte relacionado mas não estão na ocorrência
						If cChaveGWE != GWE->(GWE_FILIAL + GWE_CDTPDC  + GWE_EMISDC + GWE_SERDC + GWE_NRDC) ;
							.And. aScan(aDocSemRel,{|x| x == GWE->(GWE_FILIAL + GWE_CDTPDC  + GWE_EMISDC + GWE_SERDC + GWE_NRDC)}) == 0

							If Len(aDocSemRel) > 0
								cDocBase += ", "
							EndIf
							aAdd (aDocSemRel, GWE->(GWE_FILIAL + GWE_CDTPDC  + GWE_EMISDC + GWE_SERDC + GWE_NRDC))
							cDocBase += AllTrim(GWE->GWE_SERDC) + "/" + AllTrim(GWE->GWE_NRDC)
						EndIf
					EndIf
					GWE->(dbSkip())
				EndDo
				cDocBase += ". Confirma o registro desta Ocorrência? "
				If Len(aDocSemRel) > 0 .And. !IsInCallStack("GFEA117") //Não apresenta a mensagem quando executado pelo GFEA117
					If !IsBlind() .And. !MsgYesNo(cDocBase)
						oModel:SetErrorMessage(,,,,,"Abortado pelo usuário.")
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
		GU6->(dbSetOrder(1))
		If GU6->(dbSeek(xFilial("GU6")+cCdMot))
			If GU6->GU6_APRAUT == "1"
				GU5->(dbSetOrder(1))
				If GU5->(dbSeek(xFilial("GU5") + cCdTipo))
					If Empty(cNumDoc)
						GWL->(dbSetOrder(1))
						If !GWL->(dbSeek(xFilial("GWL")+cNrOcor))
							If GU5->GU5_EVENTO <> "3"
								GFEMsgErro(STR0023)  //"Ocorrência sem documentos de carga"
								Return .F.
							EndIf
						EndIf
					EndIf
					
					If GU5->GU5_EVENTO == "4" // Registrar Entrega por evento
						cErroMsg := GFE32REGET(oModel) // Retorna um array com os erros do registro da entrega
						If !Empty(cErroMsg)
							GFEMsgErro(cErroMsg)
							Return .F.
						EndIf
					ElseIf GU5->GU5_EVENTO == "5"
						nQtdDC := oModelGWL:GetQTDLine()
						For nLinha := 1 To nQtdDC
							oModelGWL:GoLine(nLinha) 
							cQuery := "SELECT GWU.R_E_C_N_O_ RECNOGWU "
							cQuery += " FROM " + RetSqlName("GWU") + " GWU"
							cQuery += " WHERE GWU.GWU_FILIAL = ?"
							cQuery += " AND GWU.GWU_CDTPDC = ?"
							cQuery += " AND GWU.GWU_EMISDC = ?"
							cQuery += " AND GWU.GWU_SERDC = ?"
							cQuery += " AND GWU.GWU_NRDC = ?" 
							cQuery += " AND GWU.GWU_SEQ = ?"
							cQuery += " AND GWU.D_E_L_E_T_ = ''"

							cQuery := ChangeQuery(cQuery)
							oQry := FWExecStatement():New(cQuery)
							oQry:SetNumeric(1,oModelGWL:GetValue("GWL_FILDC")) 
							oQry:SetString(2,oModelGWL:GetValue("GWL_TPDC"))
							oQry:SetString(3,oModelGWL:GetValue("GWL_EMITDC")) 
							oQry:SetString(4,oModelGWL:GetValue("GWL_SERDC")) 
							oQry:SetString(5,oModelGWL:GetValue("GWL_NRDC")) 
							oQry:SetString(6,oModelGWL:GetValue("GWL_SEQ"))
							cAliasEnt := oQry:OpenAlias()

							If (cAliasEnt)->(!Eof())
								GWU->(dbGoTo((cAliasEnt)->RECNOGWU))

								// Gravação de registro anterior na tabela GW0 para possivel estorno
								cQuery := "SELECT GW0.R_E_C_N_O_ "
								cQuery += " FROM " + RetSqlName("GW0") + " GW0"
								cQuery += " WHERE GW0.GW0_FILIAL = ?"
								cQuery += " AND GW0.GW0_TABELA = ?"
								cQuery += " AND GW0.GW0_CHAVE = ?"
								cQuery += " AND GW0.GW0_CHAR02 = ?"
								cQuery += " AND GW0.D_E_L_E_T_ = ''"

								cQuery := ChangeQuery(cQuery)
								oQry := FWExecStatement():New(cQuery) 
								oQry:SetString(1,GWU->GWU_FILIAL)
								oQry:SetString(2,'GWU') 
								oQry:SetString(3,GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)+(xFilial("GWD")+oModelGWD:GetValue("GWD_NROCO"))) 
								oQry:SetString(4,(xFilial("GWD")+oModelGWD:GetValue("GWD_NROCO")+dtos(oModelGWD:GetValue("GWD_DTOCOR"))))
								cAliasGW0 := oQry:OpenAlias()

								If (cAliasGW0)->(EoF())
									RecLock("GW0", .T.)
									GW0->GW0_FILIAL := xFilial("GW0")
									GW0->GW0_TABELA := 'GWU'
									GW0->GW0_CHAVE  := GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)+(xFilial("GWD")+oModelGWD:GetValue("GWD_NROCO"))
									GW0->GW0_CHAR02 := xFilial("GWD")+oModelGWD:GetValue("GWD_NROCO")+dtos(oModelGWD:GetValue("GWD_DTOCOR"))
									GW0->GW0_DATA01 := GWU->GWU_DTPENT
									GW0->GW0_CHAR01 := GWU->GWU_HRPENT
									GW0->( MsUnlock() )
								EndIf
								(cAliasGW0)->(dbCloseArea())

								cDocPEntr += "Doc./Seq. " + Alltrim(GWU->GWU_NRDC) + "-" + Alltrim(GWU->GWU_SEQ) +;
							 	 			 " Data/Hora Prevista: " + Iif(!Empty(Dtos(GWU->GWU_DTPENT)), (Dtoc(GWU->GWU_DTPENT) +  " " + Alltrim(GWU->GWU_HRPENT)), "Não Informado")

								dDtAnt := GWU->GWU_DTPENT
								cHrAnt := GWU->GWU_HRPENT

								RecLock("GWU", .F.)
									GWU->GWU_DTPENT = oModelGWD:GetValue("GWD_DTOCOR")
									GWU->GWU_HRPENT = oModelGWD:GetValue("GWD_HROCOR")
								GWU->(MsUnlock())

								nRecBkp := GWU->(Recno())
								If cRecPrz == "1"
									If dDtAnt < GWU->GWU_DTPENT .Or. (dDtAnt == GWU->GWU_DTPENT .And. cHrAnt < GWU->GWU_HRPENT)
										RecPrzTrec(GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
									ENDIF
								ElseIf cRecPrz == "2"
									RecPrzTrec(GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
								EndIf
								GWU->(dbGoTo(nRecBkp))
								
								(cAliasEnt)->(dbSkip())
							EndIf

							// Grava historico de dados previstos para entrega em tabela de log
							If !Empty(cDocPEntr)
								oModel:LoadValue("GFEA032_GWD", "GWD_DSSOLU", "Aprovada automaticamente" + CRLF + CRLF + "Historico previsão de entrega:" + CRLF + cDocPEntr)
							EndIf

							(cAliasEnt)->(dbCloseArea())
						Next nLinha
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	// Integração TMS
	cChvExtTms := If(GFXCP12117("GWD_CHVEXT"), FwFldGet("GWD_CHVEXT"), "")
	
	If !Empty(cChvExtTms) .And. nOpc != MODEL_OPERATION_DELETE
		oModel:LoadValue("GFEA032_GWD","GWD_SITTMS","0")
	Else
		dbSelectArea("GU5")
		GU5->(dbSetOrder(1))
		If nOpc != MODEL_OPERATION_DELETE .And. GU5->(dbSeek(xFilial("GU5") + cCdTipo)) .And. GfeVerCmpo({"GU5_INTTMS"})
			If !(SuperGetMv("MV_TMS2GFE",.F.,.F.)) .Or. GU5->GU5_INTTMS != "2"
				If nopc == 3
					oModel:LoadValue("GFEA032_GWD","GWD_SITTMS","0")
				ElseIf nopc == 4
					RecLock("GWD",.F.)
						GWD->GWD_SITTMS := "0"
					GWD->(MSUnlock())
				EndIf
			Else
				If nopc == 3
					oModel:LoadValue("GFEA032_GWD","GWD_SITTMS","2")
					oModel:LoadValue("GFEA032_GWD","GWD_DTTMS",DDATABASE)
				ElseIf nopc == 4
					RecLock("GWD",.F.)
						GWD->GWD_SITTMS := "2"
						GWD->GWD_DTTMS  := DDATABASE
					GWD->(MSUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032INC()
	Local lRet := .T.
	Local cFunBkp := FunName()
	Local s_GFEA032D := ExistBlock("GFEA032D")

	FWExecView("",'GFEA032',3,,{||.T.})
	SetFunName(cFunBkp)

	If s_GFEA032D
		ExecBlock("GFEA032D",.F.,.F.)
	Endif

Return lRet
/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032ALT()
	Local lRet := .T.
	Local cFunBkp := FunName()

	If GWD->GWD_SIT <> "1"
		GFEMsgErro(STR0038)  //"Não é posivel alterar ocorrencia"
		lRet := .F.
	Else
		lAltOcor := .T.
		FWExecView("",'GFEA032',4,,{||.T.})
	EndIf

	lAltOcor := .F.
	SetFunName(cFunBkp)
Return lRet

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032VB(oModel) //validação do BROWSE
	Local lRet       := .T.
	Local aAreaGWD   := GWD->(GetArea())
	Local oModelGWD  := oModel:GetModel("GFEA032_GWD")
	Local oModelGWL  := oModelGWD:GetModel("GFEA032_GWL")
	Local cFilialGW1 := ""
	Local cAliasGW1  := Nil
	Local cFilDc     := FwFldGet('GWL_FILDC')
	Local cCdTpDc    := FwFldGet('GWL_TPDC')
	Local cEmisDc    := FwFldGet('GWL_EMITDC')
	Local cSerDc     := FwFldGet('GWL_SERDC')
	Local cNrDc      := FwFldGet('GWL_NRDC')
	Local cQuery 	 := ""
	Local oQry

	If !oModelGWL:IsDeleted() 
		cQuery := "SELECT GW1.GW1_FILIAL "
		cQuery += " FROM " + RetSqlName("GW1") + " GW1"
		cQuery += " WHERE GW1.GW1_FILIAL = ?"
		cQuery += " AND GW1.GW1_CDTPDC = ?"
		cQuery += " AND GW1.GW1_EMISDC = ?"
		cQuery += " AND GW1.GW1_SERDC = ?"
		cQuery += " AND GW1.GW1_NRDC = ?"
		cQuery += " AND GW1.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,cFilDc)
		oQry:SetString(2,cCdTpDc) 
		oQry:SetString(3,cEmisDc) 
		oQry:SetString(4,cSerDc)
		oQry:SetString(5,cNrDc)
		cAliasGW1 := oQry:OpenAlias()

		If (cAliasGW1)->(Eof())
			GFEMsgErro(STR0039 + "! Serie: " + AllTrim(cSerDc) + " Numero: " + AllTrim(cNrDc) + ". ")  //"Documento Inexistente"
			lRet := .F.
		Else
			cFilialGW1 := GW1->GW1_FILIAL
			lRet := GFEA32VCO(oModelGWL,.F.)
		EndIf
		(cAliasGW1)->(dbCloseArea())
		RestArea(aAreaGWD)
	EndIf
	If lRet .And. Empty(cFilDc) 
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT COUNT(GW1.GW1_FILIAL) NR_FILIAL
			FROM %Table:GW1% GW1
			WHERE GW1.GW1_CDTPDC = %Exp:cCdTpDc%
			AND GW1.GW1_EMISDC = %Exp:cEmisDc%
			AND GW1.GW1_SERDC = %Exp:cSerDc%
			AND GW1.GW1_NRDC = %Exp:cNrDc%
			AND GW1.%NotDel%
		EndSql

		If (cAliasGW1)->NR_FILIAL == 1
			oModel:SetValue('GWL_FILDC',cFilialGW1,.T.)
		Else
			GFEMsgErro(STR0043)  //"Documento de Carga em filiais diferentes"
			lRet := .F.
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf
Return lRet

Function GF32VLTPGW(cCdTipo)
	Local lRet      := .T.
	Local oModel    := FwModelActive()

	// Adicionando validação de habilitação de campo de evidencia somente para tipo entrega
	If GFXCP12130("GWD_URLENT") .And. !isBlind()
		If GFE032WHEN(cCdTipo)
			oModel:GetModel("GFEA032_GWD"):GetStruct():SetProperty("GWD_URLENT", MODEL_FIELD_WHEN , {|| .T.})
		Else
			oModel:GetModel("GFEA032_GWD"):GetStruct():SetProperty("GWD_URLENT", MODEL_FIELD_WHEN , {|| .F.})
		EndIf
	EndIf
Return lRet

/*-------------------------------------------------------------------
-------------------------------------------------------------------*/
Function GFEA032CA(cNumOcor,cTpCalc,oModel,lApraut,lSimular)
	Local lRet       := .T.
	Local lMosTela   := .F.
	Local lProcess   := (IsBlind() .Or. IsInCallStack('GFEA117'))
	Local oDlg       := Nil
	Local aDocCalc   := {}
	Local nCount     := 0
	Local cDescTela  := ""
	Local nI         := 0
	Local nValorSug  := 0 // guarda o valor sugerido com o percentual aplicado
	Local aAux       := {}
	Local nPcReen    := 0
	Local nMaxReen   := 0
	Local nPcDev     := 0
	Local aRet       := {}
	Local aCServ     := {}
	Local nServico   := 0
	Local nVlOcor    := 0
	Local nTmpServi  := 0
	Local nMinReen   := 0
	Local nDocCarga  := 0
	Local cCdTipo    := ""
	Local cPrests    := ""
	Local cTpCalcDes := ""
	Local cMsgErro   := ""
	Local nValFret   := 0
	Local cParTel    := SuperGetMv( 'MV_CALREN',,'1' )
	Local cMV_CALREN := If (Empty(cParTel),"1",cParTel)
	Local s_GFEA032F := ExistBlock("GFEA032F")
	Local s_CALDEV   := SuperGetMV('MV_CALDEV',,'N')
	Local s_CALSER   := SuperGetMV('MV_CALSER',,'N')
	Local s_SERVTO   := SuperGetMV("MV_SERVTO",.F.,"2")
	Local S_GFEBRF	 := "1"
	Local cMemo		 := ""
	Local oMemo		 := ""
	Local cAliasGWH  := ""
	Local cDocsCarg  := ""
	Local nCont		 := 0
	Local cQuery	 := ""
	Local oQry
	
	Private GFELog032  := GFELog():New("Ocorren" + cNumOcor + "_Calc_Add", "Cálculo da ocorrência", SuperGetMV('MV_GFEEDIL',,'1'))
	Private cTransp    := ""
	Private aAgrFrt    := {}
	Private aDocCarg   := {}
	Private aTrchDoc   := {}
	Private aItDoc     := {}
	Private nAuxVlFrt  := 0
	Private lValorSug  := .T. //indica se o valor sugerido foi usado
	Private lPrestServ := .F.

	Default lApraut    := .F.
	Default lSimular   := .F.
	
	If cTpCalc == "4"
		cTpCalcDes := "Reentrega"
	ElseIf cTpCalc == "5"
		cTpCalcDes := "Devolução"
	ElseIf cTpCalc == "7"
		cTpCalcDes := "Serviço"
	EndIf

	GFELog032:Add(Replicate("-",15) + "Ocorrência" + Replicate("-",15))
	GFELog032:Add("Filial....: " + LgInfo("GWD_FILIAL",,oModel))
	GFELog032:Add("Número....: " + LgInfo("GWD_NROCO",,oModel))
	GFELog032:Add("Transp....: " + AllTrim(LgInfo("GWD_CDTRP",,oModel)) + " - " + Posicione("GU3",1,xFilial('GU3') + LgInfo("GWD_CDTRP",,oModel),"GU3_NMEMIT"))
	GFELog032:Add("Tipo......: " + LgInfo("GWD_CDTIPO",,oModel) + " - " + Posicione("GU5",1,xFilial('GU5') + LgInfo("GWD_CDTIPO",,oModel),"GU5_DESC"))
	GFELog032:Add("Motivo....: " + LgInfo("GWD_CDMOT",,oModel) + " - " + Posicione("GU6",1,xFilial('GU6') + LgInfo("GWD_CDMOT",,oModel),"GU6_DESC"))
	GFELog032:Add("Dt ocorrên: " + LgInfo("GWD_DTOCOR",,oModel) + " " + LgInfo("GWD_HROCOR",,oModel) ) 
	GFELog032:Add("Cálculo de: " + cTpCalcDes)
	GFELog032:Add("Simulação?: " + Iif(lSimular,"Sim","Não"))
	GFELog032:NewLine()
	aDocCalc := GFE32DCCLC(@nDocCarga,lApraut,oModel,cTpCalc,cNumOcor,lSimular) // Cálculos dos documentos e preparação do cálculo serviço

	nQtPern  := IIf(lApraut, FwFldGet("GWD_QTPERN"), GWD->GWD_QTPERN)

	If cTpCalc == "7" // Servico
		GFELog032:NewLine()
		GFELog032:Add(Replicate("-",8) + "Informações Cálculo " + cTpCalcDes + Replicate("-",8))
		If nDocCarga == 0
			GFEMsgErro("Ocorrência não possui Documentos de Carga vinculados!")
			GFELog032:Add("Erro......: Ocorrência não possui Documentos de Carga vinculados!")
			GFELog032:Save()
			Return .F.
		Endif

		If lApraut
			cCdTipo := FwFldGet('GWD_CDTIPO')
			cPrests  := If(GfeVerCmpo({"GWD_PRESTS"}), FwFldGet("GWD_PRESTS"), "")
		Else
			cCdTipo := GWD->GWD_CDTIPO
			cPrests  := If(GfeVerCmpo({"GWD_PRESTS"}), GWD->GWD_PRESTS, "")
		EndIf

		If !Empty(cPrests)
			GFELog032:Add("Prestador: " + cPrests + " - " + Posicione("GU3",1,xFilial('GU3') + cPrests,"GU3_NMEMIT"))
		EndIf

		If s_SERVTO == "1"
			GFELog032:Add("Serviço por tipo de ocorrência: 1-Sim")
			dbSelectArea("GU5")
			dbSetOrder(1)
			dbSeek(xFilial("GU5") + cCdTipo)
			Do While !eof() .and. xFilial("GU5") == GU5->GU5_FILIAL .and. GU5->GU5_CDTIPO == cCdTipo

				IF !EMPTY(GU5->GU5_SERV1)
					GFELog032:Add("Comp 01..: " + GU5->GU5_SERV1)
					aAdd(aCServ,GU5->GU5_SERV1)
				Endif
				IF !EMPTY(GU5->GU5_SERV2)
					GFELog032:Add("Comp 02..: " + GU5->GU5_SERV2)
					aAdd(aCServ,GU5->GU5_SERV2)
				EndIf
				IF !EMPTY(GU5->GU5_SERV3)
					GFELog032:Add("Comp 03..: " + GU5->GU5_SERV3)
					aAdd(aCServ,GU5->GU5_SERV3)
				EndIf
				dbSelectArea("GU5")
				dbSkip()
			EndDo
		Else
			GFELog032:Add("Serviço por tipo de ocorrência: 2-Não")
		Endif

		// Nas seguintes situações o cálculo de serviço utilizará a função padrão GFECLCFRT:
		// 1 - Quando o parâmetro Serviço por Tipo de Ocorrência estiver marcado
		// 2 - Quando no tipo da ocorrência permitir informar um outro prestador de serviço e utilizar a tabela do mesmo
		//     para o cálculo de serviço deve-se procurar todas as tabelas disponíveis deste prestador localizando
		//     as que possuam componentes de serviço
		If s_SERVTO == "1" .or. (lPrestServ .and. s_SERVTO != "1")
			dbSelectArea("GU5")
			dbSetOrder(1)
			dbSeek(xFilial("GU5") + cCdTipo)
			GFELog032:NewLine()
			GFELog032:Add("Utilizando cálculo de frete para calcular o valor do serviço...")
			aRet := GFEServFrete(aCServ, aAgrFrt, aDocCarg, aTrchDoc, aItDoc, nQtPern, cNumOcor, IsInCallStack('GFEA117'), GU5->GU5_TPIMP, cCdTipo,lSimular)
			If !Empty(aRet[2])
				GFELog032:Add("Caminho do Log: " + aRet[2] )
			EndIf
			If aRet[1] == .F.
				If !lSimular
					If lApraut
						GFEMsgErro("Ocorrência de Serviço não foi criada. Verifique os erros ocasionados no cálculo do frete!")
					Else
						GFEMsgErro("Ocorrência de Serviço não foi aprovada. Verifique os erros ocasionados no cálculo do frete!")
					Endif
				EndIf
				GFELog032:Add("Cálculo: Erro" )
				GFELog032:Add("Motivo: " + GFERomErro(aRet[3], AllTrim(cNumOcor)))
				GFELog032:Save()
				Return .F.
			ElseIf !lSimular
				GFELog032:Add("Cálculo(s): OK")
				// Prestador de serviço foi informado na ocorrência mas será utilizada a tabela de frete do Transportador do Romaneio
				// Será verificado o cálculo gerado e alterado o Transportador para o Prestador de Serviço
				dbSelectArea("GWF")
				dbsetorder(5)
				dbseek(xfilial("GWF") + cNumOcor)
				Do While !Eof() .AND. GWF->GWF_NROCO == cNumOcor
					nTmpServi := VLTOTFRET(GWF->GWF_FILIAL, GWF->GWF_NRCALC)
					nServico += nTmpServi

					GFELog032:Add("Número...: " + GWF->GWF_NRCALC + " - Valor: " + AllTrim(Transform(nTmpServi,"@E 999,999,999.99")))
					dbSelectArea("GWF")
					dbskip()
				EndDo
				If !lPrestServ .And. !Empty(cPrests)
					dbseek(xfilial("GWF") + cNumOcor)
					Do While !Eof() .And. GWF->GWF_NROCO == cNumOcor
						GFELog032:Add("Alterando o prestador do cálculo " + GWF->GWF_NRCALC)
						GFELog032:Add("De: " + AllTrim(GWF->GWF_TRANSP) + " - " + Posicione("GU3",1,xFilial('GU3') + GWF->GWF_TRANSP,"GU3_NMEMIT"))
						GFELog032:Add("Para: " + AllTrim(cPrests) + " - " + Posicione("GU3",1,xFilial('GU3') + cPrests,"GU3_NMEMIT"))
						GFE032TRAN(GWF->GWF_NRCALC, cPrests, cCdTipo)

						dbSelectArea("GWF")
						dbskip()
					EndDo
				EndIf

				If s_CALSER $ "1S" .And. !IsInCallStack("GFEA117")
					GWF->(dbsetorder(5))
					GWF->(dbseek(xfilial("GWF") + cNumOcor))

					// Bloco de codigo para tratar todos calculo e substituir em todos documentos associados alem do selecionado
					If Len(aRet[3]) > 0
						Do While !GWF->(Eof()) .And. GWF->GWF_NROCO == cNumOcor
							nAuxVlFrt += VLTOTFRET(GWF->GWF_FILIAL, GWF->GWF_NRCALC)

							GWF->(DbSkip())
						EndDo
						nValFret  := nAuxVlFrt
						nValorTot := nAuxVlFrt
						GWF->(dbsetorder(5))
						GWF->(dbseek(xfilial("GWF") + cNumOcor))
					Else
						nValFret := VLTOTFRET(GWF->GWF_FILIAL,GWF->GWF_NRCALC)
						nValorTot := nValFret
					EndIf
					
					//DLOGGFE2-601
					DEFINE MSDIALOG oDlg TITLE STR0057 From 4,0 To 12,40 OF oMainWnd //"Liberar" //"Valor Frete"

					@  4,  6 SAY   "Deseja alterar o valor do serviço?" SIZE 100,7 PIXEL OF oDlg

					@ 19,  6 SAY   STR0057 SIZE 70,7  PIXEL OF oDlg  //"Valor Frete"
					@ 18, 60 MSGET nValorTot     When !lSimular   Picture "@E 999,999,999.99" SIZE 50,7 PIXEL OF oDlg
				
					oButtonOK := tButton():New(45,5,'OK',oDlg,{||GFEOcoACal(nValorTot, cNumOcor),oDlg:End(),lRet},25,10,,,,.T.)

					ACTIVATE MSDIALOG oDlg
				Endif
			ElseIf lSimular
				If S_GFEBRF == "1"
					For nI := 1 To Len(aRet[10])
						If ARET[10][nI][15] == "0" .And. ARET[10][nI][9] == "1"	
							nServico += ARET[10][nI][8]
						EndIf 
					Next nX
				Else
					cTRBCCF := ARET[12]
					(cTRBCCF)->(dbGoTop())
					Do While !(cTRBCCF)->(Eof())
						If (cTRBCCF)->TOTFRE == "1"
							nServico += (cTRBCCF)->VALOR
						EndIf
						(cTRBCCF)->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	Endif

	If cTpCalc != "7" .or. (s_SERVTO != "1" .and. !lPrestServ)
		GFELog032:NewLine()
		For nCount := 1 To Len(aDocCalc)
			cNumCalc := aDocCalc[nCount]
			nValorTot := 0
			GFELog032:Add("Cálculo...: " + cNumCalc)
			// Retorna os percentuais de reentrega e devolução
			if cTpCalc == "4" .Or. cTpCalc == "5" // 4 - Reentrega, 5 - Devolução
				cDescTela := STR0055 //"Deseja alterar o valor do frete?"
				aAux      := GFEPcReenDev(cNumCalc,cTpCalc)
				nPcReen   := aAux[1]
				nMaxReen  := aAux[2]
				nPcDev    := aAux[3]
				nMinReen  := aAux[4]
				cTransp   := aAux[5]
				
				GFELog032:Add("Emitente..: " + AllTrim(aAux[6]) + " - Tabela: " + aAux[7])
				GFELog032:Add("Negociação: " + aAux[8] + " - Rota: " + aAux[9])
				
				nValorTot := GFE32VLRAT(xFilial("GWD"),cNumOcor,lApraut,oModel,cNumCalc)
				GFELog032:NewLine()
				GFELog032:Add("Valor referência: " + AllTrim(Transform(nValorTot,"@E 999,999,999.99")))
				
				If cTpCalc == "4" //Reentrega
					GFELog032:Add("Percentual reentrega: " + cValToChar(nPcReen))
					
					nValorTot := nValorTot * (nPcReen/100)
					
					GFELog032:Add("Valor do cálculo: " + AllTrim(Transform(nValorTot,"@E 999,999,999.99")))
					
					If nMaxReen > 0
						If nValorTot > nMaxReen
							GFELog032:Add("Ultrapassou o valor máximo permitido. Usando valor máximo: " + AllTrim(Transform(nMaxReen,"@E 999,999,999.99")))
						EndIf
						nValorTot := Min(nValorTot, nMaxReen)
					EndIf
					
					If nMinReen > 0
						If nValorTot < nMinReen
							GFELog032:Add("Ultrapassou o valor mínimo permitido. Usando valor mínimo: " + AllTrim(Transform(nMinReen,"@E 999,999,999.99")))
						EndIf
						nValorTot := Max(nValorTot, nMinReen)
					EndIf
					
				    // Início Ponto de Entrada Ellece 
				 	If s_GFEA032F	
						nReentrega := ExecBlock("GFEA032F",.F.,.F.,{cNumOcor,cNumCalc})
						
						GFELog032:Add("Ponto de entrada GFEA032F: " + AllTrim(Transform(nReentrega,"@E 999,999,999.99")))
						
						if nReentrega != 0
							nValorTot := nReentrega
						endif
					EndIf
					// Fim Ponto de Entrada Ellece
				Else //Devolução
					GFELog032:Add("Percentual devolução: " + cValToChar(nPcDev))
					nValorTot := nValorTot * (nPcDev/100)
					GFELog032:Add("Valor do cálculo: " + AllTrim(Transform(nValorTot,"@E 999,999,999.99")))
				EndIf
			EndIf

			If cTpCalc == "7" .and. s_SERVTO != "1" .and. !lPrestServ // Servico
				cDescTela := STR0056 //"Deseja alterar o valor de Serviço?"
				GFELog032:NewLine()
				GFELog032:Add("Procurando componente de serviço nas tarifas das tabelas do cálculo...")
				GFELog032:Add("Utilizando 'Vl. Fixo Nor' da tarifa para cálculo do serviço...")
				nValorTot := GFEVlServ(cNumCalc, GWD->GWD_FILIAL, GWD->GWD_NROCO)
				GFELog032:Add("Valor do cálculo: " + AllTrim(Transform(nValorTot,"@E 999,999,999.99")) + " " + If(GWD->GWD_QTPERN <> 1,"X " + AllTrim(Transform(GWD->GWD_QTPERN,"@E 999,999,999.99")) + " = " + AllTrim(Transform(GWD->GWD_QTPERN * nValorTot,"@E 999,999,999.99")),""))
				If lSimular
					nValorTot := nValorTot * GWD->GWD_QTPERN
				EndIf
				If s_CALSER $ "1S"
					lMosTela := .T.
				EndIf
			EndIf

			If cTpCalc == "4" //reentrega
				If cMV_CALREN $ "1S"
					lMosTela := .T.
				EndIf
			ElseIf cTpCalc == "5" // devolução
				If s_CALDEV $ "1S"
						lMosTela := .T.
				EndIf
			EndIf

			If lMosTela .And. Len(aDocCarg) > 0
				If Empty(cDocsCarg)
					For nCont := 1 to Len(aDocCarg)
						If nCont != Len(aDocCarg)
							cDocsCarg += "'" + Alltrim(aDocCarg[nCont][3]) + "'" + ","
						Else 
							cDocsCarg += "'" + Alltrim(aDocCarg[nCont][3]) + "'"
						EndIf
					Next nCont
				EndIf
				 
				cMemo := ""
				
				cQuery := "SELECT GWH_NRDC"
				cQuery += " FROM " + RetSqlName("GWH") + " GWH"
				cQuery += " WHERE GWH.GWH_FILIAL = ?"
				cQuery += " AND GWH.GWH_NRCALC = ?"
				cQuery += " AND GWH.GWH_CDTPDC = ?"
				cQuery += " AND GWH.GWH_EMISDC = ?"
				cQuery += " AND GWH.GWH_SERDC = ?"
				cQuery += " AND GWH.GWH_NRDC IN (?)"
				cQuery += " AND GWH.D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery)
				oQry:SetString(1,xFilial("GWH")) 
				oQry:SetString(2,cNumCalc) 
				oQry:SetString(3,aDocCarg[nCount][4])
				oQry:SetString(4,aDocCarg[nCount][5])
				oQry:SetString(5,aDocCarg[nCount][2])
				oQry:SetIn(6,{cDocsCarg})
				cAliasGWH := oQry:OpenAlias()
				
				While (cAliasGWH)->(!Eof())
					cMemo += AllTrim((cAliasGWH)->(GWH_NRDC)) + "; " 
					(cAliasGWH)->(dbSkip())
				EndDo
				
				(cAliasGWH)->(dbCloseArea())
			EndIf 

			nValorSug := nValorTot
			If (lMosTela .And. !lProcess) .Or. lSimular
				If !Empty(cMemo)
					DEFINE MSDIALOG oDlg TITLE If(lSimular,"Simulação valor frete",STR0057) From 4,0 To 14,40 OF oMainWnd //"Liberar" //"Valor Frete"
						If !lSimular
							@  4,  6 SAY   cDescTela     SIZE 100,7 PIXEL OF oDlg 
						EndIf
						
						@ 19,  6 SAY   "Doc Carga"   SIZE 70,7  PIXEL OF oDlg  //"Doc Carga"
						@ 18, 40 GET oMemo VAR cMemo MEMO  When .F. SIZE 118,20 /*50,7*/ PIXEL OF oDlg
						
						@ 45,  6 SAY   If(lSimular,"Valor",STR0057) SIZE 75,7  PIXEL OF oDlg  //"Valor Frete"
						@ 44, 40 MSGET nValorTot     When !lSimular   Picture "@E 999,999,999.99" SIZE 50,7 PIXEL OF oDlg
						If !lSimular
							oButtonOK := tButton():New(60,5,'OK',oDlg,{||GFE32GECAL(cNumCalc,cNumOcor,lApraut,oModel,cTpCalc),oDlg:End(),lRet},35,10,,,,.T.)
						Else
							oButtonOK := tButton():New(60,5,'Fechar',oDlg,{||oDlg:End()},25,10,,,,.T.)
						EndIf
					ACTIVATE MSDIALOG oDlg
				Else
					DEFINE MSDIALOG oDlg TITLE If(lSimular,"Simulação valor frete",STR0057) From 4,0 To 12,40 OF oMainWnd //"Liberar" //"Valor Frete"
						If !lSimular
							@  4,  6 SAY   cDescTela     SIZE 100,7 PIXEL OF oDlg
						EndIf

						@ 19,  6 SAY   If(lSimular,"Valor",STR0057) SIZE 70,7  PIXEL OF oDlg  //"Valor Frete"
						@ 18, If(lSimular,20,60) MSGET nValorTot     When !lSimular   Picture "@E 999,999,999.99" SIZE 50,7 PIXEL OF oDlg
						If !lSimular
							oButtonOK := tButton():New(45,5,'OK',oDlg,{||GFE32GECAL(cNumCalc,cNumOcor,lApraut,oModel,cTpCalc),oDlg:End(),lRet},25,10,,,,.T.)
						Else
							oButtonOK := tButton():New(45,5,'Fechar',oDlg,{||oDlg:End()},25,10,,,,.T.)
						EndIf
					ACTIVATE MSDIALOG oDlg
				EndIf
			Elseif lret
				GFE32GECAL(cNumCalc,cNumOcor,lApraut,oModel,cTpCalc)
			EndIf
			
			If cTpCalc == "7" .and. s_SERVTO != "1" .and. !lPrestServ
				If !lSimular
					nServico += nValorTot * GWD->GWD_QTPERN
				EndIf
			EndIf

			If nValorSug != nValorTot .And. !lSimular
				GFELog032:NewLine()
				GFELog032:Add("Valor do cálculo " + cNumCalc + " alterado pelo usuário de " + AllTrim(Transform(nValorSug,"@E 999,999,999.99")) + " para " + AllTrim(Transform(nValorTot,"@E 999,999,999.99")))
				// Zerar a quantidade para cálculo dos componentes
				dbSelectArea("GWF")
				dbSetOrder(1)
				If dbSeek(xFilial("GWF")+cNovoNrCalc)
					Do While !Eof() .and. xFilial("GWF")+cNovoNrCalc == GWF->GWF_FILIAL+GWF->GWF_NRCALC
						 If GWF->GWF_TPCALC == '4' // Reentrega
							DbSelectArea("GWI")
							dbSetOrder(1)
							dbSeek(xFilial("GWI")+cNovoNrCalc)
							Do While !Eof() .and. xFilial("GWI")+GWF->GWF_NRCALC == GWI->GWI_FILIAL+GWI->GWI_NRCALC
								RecLock("GWI",.F.)
								GWI->GWI_QTCALC := 0
								GWI->(MSUnlock())
								DbSelectArea("GWI")
								dbSkip()
							EndDo
						EndIf
						dbSelectArea("GWF")
						dbSkip()
					EndDo
				EndIf
			EndIf
			nVlOcor += nValorTot
		Next nCount
	EndIf

	If nServico != 0
		GFELog032:Add("Valor da ocorrência: " + AllTrim(Transform(nServico,"@E 999,999,999.99")))
	Else
		GFELog032:Add("Valor da ocorrência: " + AllTrim(Transform(nVlOcor,"@E 999,999,999.99")))
	Endif
	
	If !lSimular .And. lRet .And. cTpCalc == "5"
		aAux := GetArea()
		If GU5->GU5_CDTIPO != LgInfo("GWD_CDTIPO",,oModel) .Or. xFilial("GU5") != GU5->GU5_FILIAL
			dbSelectArea("GU5")
			GU5->(dbSetOrder(1))
			GU5->(msSeek(xFilial("GU5") + LgInfo("GWD_CDTIPO",,oModel)))
		EndIf
		
		If GU5->GU5_DEVTOT == "1"
			GFELog032:NewLine()
			GFELog032:Add("Registrando as entregas dos documentos...")
			cMsgErro := GFE32REGET(oModel, .T.)
			If !Empty(cMsgErro)
				GFELog032:Add("Ocorreu um ou mais erros ao registrar a entrega: " + cMsgErro)
				GFEMsgErro(cMsgErro)
				lRet := .F.
			Else
				GFELog032:Add("Sucesso no registro das entregas dos documentos...")
			EndIf
		EndIf
		RestArea(aAux)
	EndIf
	GFELog032:Save()
Return lRet

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
Function GFE32GECAL(cNumBase, cNrOcor, lApraut, oModel, cTpCalc)
	Local aDocOcor  := {}
	Local nQtPern   := 0
	Local oModelGWL := Nil
	Local nLineAux  := 0
	Local nI        := 0
	Local cMsgErro  := ""
	Local s_SERVTO  := SuperGetMV("MV_SERVTO",.F.,"2")

	Default lApraut := .F.

		If lApraut
			oModelGWL := oModel:GetModel("GFEA032_GWL")
			nLineAux  := oModelGWL:nLine
			For nI := 1 To oModelGWL:Length()
				oModelGWL:GoLine( nI )
				If !oModelGWL:IsDeleted()
					dbSelectArea("GWH")
					dbSetOrder(2)
					dbSeek(xFilial("GWH")+FwFldGet('GWL_TPDC')+FwFldGet('GWL_EMITDC')+FwFldGet('GWL_SERDC')+FwFldGet('GWL_NRDC')+cNumBase)
					Do While !Eof() .AND.;
						xFilial("GWH")  == GWH->GWH_FILIAL        .And.;
						GWH->GWH_CDTPDC == FwFldGet('GWL_TPDC')   .And.;
						GWH->GWH_EMISDC == FwFldGet('GWL_EMITDC') .And.;
						GWH->GWH_SERDC  == FwFldGet('GWL_SERDC')  .And.;
						GWH->GWH_NRDC   == FwFldGet('GWL_NRDC')   .And.;
						GWH->GWH_NRCALC == cNumBase
						aAdd(aDocOcor,{	GWH->GWH_EMISDC,; //Emitente do Documento
										GWH->GWH_SERDC ,; //Serie do Documento
										GWH->GWH_NRDC  ,; //Numero do Documento
										GWH->GWH_CDTPDC})
						dbSelectArea("GWH")
						dbSkip()
					enddo
				EndIf
			Next
			oModelGWL:GoLine( nLineAux )
			nQtPern := FwFldGet("GWD_QTPERN")
		Else
			dbSelectArea("GWD")
			dbSetOrder(1)
			If dbSeek(xFilial("GWD")+cNrOcor)
				dbSelectArea("GWL")
				dbSetOrder(1)
				dbSeek(xFilial("GWL")+GWD->GWD_NROCO)
				Do While !Eof() .And. xFilial("GWL") == GWL->GWL_FILIAL .And. GWL->GWL_NROCO == GWD->GWD_NROCO
					aAdd(aDocOcor,{	GWL->GWL_EMITDC ,; //Emitente do Documento
										GWL->GWL_SERDC  ,; //Serie do Documento
									GWL->GWL_NRDC   ,; //Numero do Documento
										GWL->GWL_TPDC})
					dbSelectArea("GWL")
					dbSkip()
				EndDo
			EndIf
			nQtPern := GWD->GWD_QTPERN
		EndIf

		If nValorTot <= 0
			cMsgErro := "Valor total do frete ficou zerado."

			If cTpCalc == "7"
				cMsgErro += CHR(13) + CHR(10) + CHR(13) + CHR(10)
				cMsgErro += "Verifique se a tarifa da tabela de frete possui um componente do tipo serviço."
			EndIf

			GFEMsgErro(cMsgErro)
			Return .F.
		Else
			cNovoNrCalc := GETSXENUM("GWF","GWF_NRCALC")

			ConfirmSX8()

			If cTipoCalc != '7' .or. s_SERVTO != "1"
				If !GFECalcMan(aDocOcor, cNovoNrCalc, cNumBase, cTipoCalc, nQtPern, nValorTot, .T., cNrOcor)

					dbSelectArea("GWD")
					dbSetOrder(1)
					If dbSeek(xFilial("GWD")+cNrOcor)
						RecLock("GWD",.F.)
						GWD->GWD_DSSOLU := ""
						GWD->GWD_SIT    := "1"
						GWD->GWD_USUBAI := ""
						GWD->(MSUnlock())
					EndIf
					Return .F.
				Else
					if lApraut
						If cTipoCalc == "4" .and. !Empty(cTransp)
							GFE032TRAN(cNovoNrCalc, cTransp, FwFldGet( 'GWD_CDTIPO')	)
						ElseIf cTipoCalc == "7" .And. GfeVerCmpo({"GWD_PRESTS"}) .And. !Empty(FwFldGet("GWD_PRESTS"))
							GFE032TRAN(cNovoNrCalc, FwFldGet("GWD_PRESTS"), FwFldGet( 'GWD_CDTIPO'))
						EndIf
					else
						If cTipoCalc == "4" .and. !Empty(cTransp)
							GFE032TRAN(cNovoNrCalc, cTransp, GWD->GWD_CDTIPO)
						ElseIf cTipoCalc == "7" .And. GfeVerCmpo({"GWD_PRESTS"}) .And. !Empty(GWD->GWD_PRESTS)
							GFE032TRAN(cNovoNrCalc, GWD->GWD_PRESTS, GWD->GWD_CDTIPO)
						EndIf
					ENDIF
				EndIf
			EndIf
		EndIf
Return .T.

//---------------------------------------------

Function GFEA32MVPC()
	Local aAreaGX3 := GX3->( GetArea() )
	Local aAreaGVJ := GVJ->( GetArea() )

	If Empty(FwFldGet("GWD_NRMOV")) .Or. Empty(FwFldGet("GWD_CDPTCT"))
		Return .T.
	EndIf

	If !ExistCpo(If("GWD_NRMOV" $ ReadVar(), "GX3", "GVF"))
		Help(,,'HELP',, STR0059,1,0) //"O Ponto de Controle não existe no cadastro de Pontos de Controle."
		Return .F.
	EndIf

	dbSelectArea("GX3")
	GX3->( dbSetOrder(1) )
	If GX3->( dbSeek(xFilial("GX3") + FwFldGet("GWD_NRMOV")) )

		dbSelectArea("GVJ")
		GVJ->( dbSetOrder(1) )
		GVJ->( dbSeek(xFilial("GVJ") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
		Do While !GVJ->( Eof() ) .And. GVJ->GVJ_FILIAL == xFilial("GVJ") .And. GVJ->GVJ_CDOPER == GX3->GX3_CDOPER .And. GVJ->GVJ_SEQ == GX3->GX3_SEQ

			If GVJ->GVJ_CDPTCT == FwFldGet("GWD_CDPTCT")
				RestArea(aAreaGX3)
				RestArea(aAreaGVJ)
				Return .T.
			EndIf

			dbSelectArea("GVJ")
			GVJ->( dbSkip() )
		EndDo
	EndIf
	RestArea(aAreaGX3)
	RestArea(aAreaGVJ)
	Help(,,'HELP',, STR0060,1,0) //"Não foi encontrado o Ponto de Controle na Movimentação informada."
Return .F.

//---------------------------------------------
Function GFEA032CMT(oModel)
	Local nOpc       := (oModel:GetOperation())
	Local lRet       := .F.
	Local lRollBack  := .F.
	Local nrOco      := oModel:GetModel("GFEA032_GWD"):GetValue("GWD_NROCO")
	Local cFilOco    := ""
	Local cNrOco     := ""
	Local s_GFEA032B := ExistBlock("GFEA032B")
	Local lMsg 		 := .T.

	Private cNovoNrCalc := ""

	If (lRet := oModel:VldData())

		lRet := FwFormCommit(oModel)
		cFilOco := FWFldGet("GWD_FILIAL")
		If Empty(cFilOco) 
			cFilOco := xFilial("GWD")
		EndIf
		cNrOco  := FWFldGet("GWD_NROCO")
		If GWD->GWD_FILIAL + GWD->GWD_NROCO != cFilOco + cNrOco 
			GWD->(dbsetOrder(1))
			GWD->(dbSeek(cFilOco + cNrOco))
		EndIf

		dbSelectArea("GU5")
		dbSetOrder(1)
		If dbSeek(xFilial("GU5") + FWFldGet("GWD_CDTIPO")) 
			//Cria os cálculos somente após salvar a ocorrência. 
			//Ao criar o cálculo, o número da ocorrência fica vinculado, se for serviço.
			//Assim, a tela do cálculo é exibida e, mesmo se houver um timeout sem ser confirmado, a ocorrência estará criada, o cálculo
			//também, e ambos estarão vinculados, sem ocorrer de ter um cálculo com uma numeração de ocorrência ainda não existente,
			//que ocasionava o erro da criação de 2 cálculos de diferentes documentos para a mesma ocorrência.
			If nOpc == 3 .or. nOpc == 4 
				dbSelectArea("GU6")
				dbSetOrder(1)
				If dbSeek(xFilial("GU6")+FWFldGet("GWD_CDMOT")) 
					If GU6->GU6_APRAUT == "1" 
						//Cria o temporário fora da transação, evita erro fwtemporarytable
						XFUNBTRB()

						XFUNCTAB()

						BeginTran()

						dbSelectArea("GWD")
						GWD->( dbSetOrder(1) )
						GWD->( dbSeek(xFilial("GWD") + nrOco))
						
						aChave := GFEA32PCAT()
						
						If !Empty(aChave)
							If aChave[1] == GWD->GWD_CDPTCT
								dbSelectArea("GX4")
								GX4->( dbSetOrder(1) )
								If GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV + GWD->GWD_CDPTCT + aChave[2]) )
									If !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "3"
			
										aAreaTmp := GX4->(GetArea())
										dbSelectArea("GX4")
										GX4->( dbSetOrder(4) )
										If GX4->( dbSeek(xFilial("GX4") + GWD->GWD_NRMOV ) )
											Do While GX4->( !Eof() ) .And. xFilial("GX4") == GX4->GX4_FILIAL .And. GX4->GX4_NRMOV == GWD->GWD_NRMOV
												cGX4Seq := GX4->GX4_SEQ
				
												GX4->( dbSkip() )
											EndDo
										EndIf
										RestArea(aAreaTmp)
	
										// Verifica se GX4_SEQ é o ultimo.. Se sim.... (GX3) deve ser concluído
										If cGX4Seq == GX4->GX4_SEQ
											dbSelectArea("GX3")
											GX3->( dbSetOrder(1) )
											If GX3->( dbSeek(xFilial("GX3") + GWD->GWD_NRMOV ) )
												// GX3_SIT >>>> 1=Aberto;2=Movimentado;3=Em Fila;4=Enderecado;5=Cancelado;6=Concluido
												RecLock("GX3", .F.)
													GX3->GX3_SIT := "6"
												GX3->(MsUnlock())
											EndIf
										EndIf
	
										// GX4_SIT   -> 1=Nao avaliado; 2=Aprovado; 3=Reprovado
										// Continuar -> GX4_SIT do ponto de controle da movimentação como aprovado
										RecLock("GX4", .F.)
											GX4->GX4_SIT := "2"
											GX4->GX4_REPUSU := cUserName
										GX4->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf

						If GU5->GU5_CANCDC == "1" 
							GWL->(dbSetOrder(1))
							If GWD->(dbSeek(xFilial("GWL") + nrOco))
								Do While !GWL->(Eof()) .And. GWL->GWL_FILIAL == xFilial("GWL") .And. GWL->GWL_NROCO == nrOco
									GW1->(dbSetOrder(1))
									If GW1->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC  + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
										RecLock("GW1",.F.)
											GW1->GW1_SIT := "8"
										GW1->(MsUnLock())
									EndIf
									
									GWL->(dbSkip())
								EndDo
							EndIf
						EndIf

						If GU5->GU5_EVENTO == "1"
							If GU5->GU5_TPCALC == "1" //reeentrega
								cTipoCalc := "4"
								If !GFEA032CA(nrOco,cTipoCalc,oModel,.T.)
									lRollBack := .T.
								EndIf

							ElseIf GU5->GU5_TPCALC == "2" // devolução
								cTipoCalc := "5"
								If !GFEA032CA(nrOco,cTipoCalc,oModel,.T.)
									lRollBack := .T.
								EndIf

							ElseIf GU5->GU5_TPCALC == "3" //serviço
								cTipoCalc := "7"
								If !GFEA032CA(nrOco,cTipoCalc,oModel,.T.)
									lRollBack := .T.
								EndIf
							EndIf

						ElseIf GFXCP12121("GWD_PESO")
							If GU5->GU5_INDEN == "2"
								aInd := GFECalInd(GWD->GWD_FILIAL, GWD->GWD_NROCO, "2")
								If aInd[1] == .F.
									lRollBack := .T.
								EndIf
							ElseIf GU5->GU5_INDEN == "3"
								aInd := GFECalInd(GWD->GWD_FILIAL, GWD->GWD_NROCO, "3")
								If aInd[1] == .F.
									lRollBack := .T.
								EndIf
							EndIf
						EndIf

						If !lRollBack

							GWD->( dbSetOrder(1) )
							GWD->( dbSeek(xFilial("GWD") + nrOco))

							RecLock("GWD",.F.)
								GWD->GWD_SIT   := "2"
								GWD->GWD_HRBAI := TIME()
								GWD->GWD_DTBAI := dDataGWD()
								GWD->GWD_USUBAI:= cUserName
							GWD->(MsUnlock())

							GF32EVEOCO("APROVACAO",GWD->GWD_FILIAL,GWD->GWD_NROCO) //Evento de ocorrência
							
							//Se integração automática da ocorrência
							If SuperGetMv("MV_GFEI22" ,.F.,"2") == "1" .And. GU5->GU5_INTTMS  == "2" .And. (!GFXCP12117("GWD_CHVEXT") .Or. Empty(GWD->GWD_CHVEXT))
								GFE032TMSINT()
							EndIf

							//Ponto de entrada Vicunha
							If s_GFEA032B
								ExecBlock("GFEA032B",.f.,.f.,{nrOco,"2",2})
							EndIf

							EndTran()

							If IsInCallStack("GFEA117")
								lMsg := .F.
							EndIf
							GFE032AUDIT(cFilOco, nrOco, lMsg)	// Verificar Documento(s) de Frete bloqueados relacionados à ocorrência para executar a rotina de auditoria de frete.
						Else
							DisarmTransaction()	
						EndIf		
						//Cria o temporário fora da transação, evita erro fwtemporarytable
						XFUNCDTAB()

						XFUNBDLTRB()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet 

Function GFEA032V1()
	Local lRet
	GU5->(dbCloseArea())
	dbSelectArea("GU5")
	dbGoTop()
	GU5->(dbSetOrder(1))
	If GU5->(dbSeek(xFilial("GU5") + M->GWD_CDTIPO))
		lRet := .T.
		If SuperGetMv("MV_TMS2GFE", .F., .F.) .And. GfeVerCmpo({"GU5_INTTMS"}) .And. GU5->GU5_INTTMS != '2' .And. IsInCallStack("GFEC054")
			Help(,,'HELP',,'Ao incluir uma ocorrência para um documento de carga associado a um documento de transporte, é obrigatório que o tipo da ocorrência integre com o SIGATMS',1,0)
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

Function GFEA032V2()
	Local lRet
	GU3->(dbCloseArea())
	dbSelectArea("GU3")
	dbGoTop()
	GU3->(dbSetOrder(1))
	If GU3->(dbSeek(xFilial("GU3") + M->GWD_PRESTS))
		lRet := .T.
		If GU3->GU3_SIT == '1'
			IF GU3->GU3_AUTON == '1'
				Help(,,'HELP',,'Prestador de Serviço não pode ser Autônomo',1,0)
				lRet := .F.
			Else
				If GU3->GU3_TRANSP != '1' .AND. GU3->GU3_FORN != '1'
					Help(,,'HELP',,'Prestador de Serviço deve ser uma Transportadora ou um Fornecedor',1,0)
					lRet := .F.
				EndIf
			ENDIF
		ELSE
			Help(,,'HELP',,'Emitente inativo',1,0)
			lRet := .F.
		ENDIF
	Else
		Help(,,'HELP',,'Emitente não cadastrado',1,0)
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} GFEA32DCREL
	@author siegklenes.beulke
	@since 25/11/2013
	@version 1.0
	@description	Verifica documentos relacionados pelo documento de transporte
	@example

	lRet := GFEA32DCREL()
/*/
Function GFEA32DCREL()
	Local lMark := .T.
	Local lBranco := .F.
	Local cMsg := ""
	Local cDocTrp
	Local aDocMark := {}
	Local nI
	Local aRom := {}
	Local cValSeq

	If SuperGetMv("MV_TMS2GFE",.F.,.F.) .And. GfeVerCmpo({"GU5_INTTMS"}) ;
		.And. !Empty(FwFldGet("GWD_CDTIPO")) .And. Posicione("GU5",1,xFilial("GU5") + FwFldGet("GWD_CDTIPO"), "GU5_INTTMS") == "2"
		dbSelectArea("GU5")
		dbSelectArea("GWE")
		GWE->(dbSetOrder(1))
		If GWE->(dbSeek((cAliGWU)->(GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC)))
			cDocTrp := GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
			cMsg := "Existem outros Documento de Carga relacionado ao Documento de Transporte " + AllTrim(GWE->GWE_SERDT) + "/" + AllTrim(GWE->GWE_NRDT)  + ". Deseja que o sistema selecione os demais Documentos de Carga a esta Ocorrência?"
		EndIf
		aDocMark := A32DocRelTrp(cDocTrp)
		lMark := aDocMark[1]
		lBranco := aDocMark[3]
		aDocMark := aDocMark[2]

		dbSelectArea(cAliGWU)
		(cAliGWU)->( dbSetOrder(1) )
		If lMark
			If !Empty(cDocTrp) .And. Len(aDocMark) >1 .And. MsgYesNo(cMsg)
				For nI := 1 To Len(aDocMark)
					If (cAliGWU)->( dbSeek(aDocMark[nI])) .And. Empty((cAliGWU)->GWU_OK)
						If cTreEsc == (cAliGWU)->GWU_SEQ
							RecLock(cAliGWU, .F.)
							(cAliGWU)->GWU_OK := oBrwGWU:Mark()
							(cAliGWU)->( MSUnlock() )
						EndIf
						GFEA32MOD()
					EndIf
				Next nI
			EndIf
		Else
			If lBranco
				Help(,,'HELP',,"Não é possível selecionar Documentos de Carga sem um documento de Transporte",1,0)
			Else
				Help(,,'HELP',,"Não é possível selecionar Documentos de Carga de outros Documentos de Transporte quando houver integração da Ocorrência com TMS",1,0)
			EndIf
		EndIf
	Else
		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->(dbSeek((cAliGWU)->(GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC)))
			aRom := GFEA32REL(.T.)
		EndIf

		dbSelectArea(cAliGWU)
		(cAliGWU)->( dbSetOrder(1) )
		If (Len(aRom) > 1) .and. !IsInCallStack("GFEA044")
			if MsgYesNo("Deseja vincular os Documentos de Carga do mesmo Romaneio?")
				cValSeq := (cAliGWU)->GWU_SEQ
				//chamado TSLZK9 - Nestle.
				//Caso esteja filtrado por Documento de Carga, altera o filtro do pergunte pro Romaneio 
				//do Docto de Carga.
			
				For nI := 1 To Len(aRom)
					If (cAliGWU)->( dbSeek(aRom[nI][1] + aRom[nI][2] + aRom[nI][3] + aRom[nI][4] + aRom[nI][5] + aRom[nI][6])) .And. Empty((cAliGWU)->GWU_OK) .And. cValSeq == (cAliGWU)->(aRom[nI][6])
						RecLock(cAliGWU, .F.)
						(cAliGWU)->GWU_OK := oBrwGWU:Mark()
						(cAliGWU)->( MSUnlock() )
						GFEA32MOD()
					EndIf
				Next nI
			Else
				aCalc := {}
				//  Verifica se há outras notas fiscais na mesma entrega. A busca é feita verificando se há outras notas no cálculo da nota marcada
				dbSelectArea("GWH")
				GWH->( dbSetOrder(2) )
				GWH->( dbSeek((cAliGWU)->(GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC)) )
				Do While !GWH->( Eof()) .And. GWH->GWH_FILIAL == (cAliGWU)->GWU_FILIAL  .AND. GWH->GWH_CDTPDC ==(cAliGWU)->GWU_CDTPDC .AND. GWH->GWH_EMISDC == (cAliGWU)->GWU_EMISDC .AND. GWH->GWH_SERDC == (cAliGWU)->GWU_SERDC .AND. GWH->GWH_NRDC == (cAliGWU)->GWU_NRDC
					aCalc := GFEA32CAL()

					dbSelectArea("GWH")
					GWH->( dbSkip() )
				EndDo

				If (Len(aCalc) > 0 .or. !empty(aCalc)) .and. MsgYesNo("Deseja vincular os Documentos de Carga da mesma entrega?")
					For nI := 1 To Len(aCalc)
						If (cAliGWU)->( dbSeek(aCalc[nI][1] + aCalc[nI][2] + aCalc[nI][3] + aCalc[nI][4] + aCalc[nI][5])) .And. Empty((cAliGWU)->GWU_OK) 
							If IsInCallStack("GFEA044")
								If cTreEsc == (cAliGWU)->GWU_SEQ
									RecLock(cAliGWU, .F.)
										(cAliGWU)->GWU_OK := oBrwGWU:Mark()
									(cAliGWU)->( MSUnlock() )
								EndIf
							Else 
								RecLock(cAliGWU, .F.)
									(cAliGWU)->GWU_OK := oBrwGWU:Mark()
								(cAliGWU)->( MSUnlock() )
							EndIf
							GFEA32MOD()
						EndIf
					Next nI
				EndIf
			EndIf
		EndIf
	EndIf
Return lMark

/*/{Protheus.doc} A32DocRelTrp
	@author siegklenes.beulke
	@since 25/11/2013
	@version 1.0
	@param cDocTrp, Char, Documento de Transporte
	
	@description  traz um array com documentos de carga se os documentos marcados pertencerem ao documento de transporte
	(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)/DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)

	@example aRet := A32DocRelTrp("0101123")
/*/
Static Function A32DocRelTrp(cDocTrp)
	Local aRet     := {}
	Local aAreaGWU := (cAliGWU)->(GetArea())
	Local lMark    := .T.
	Local lBranco  := .F.

	(cAliGWU)->(dbGotop())
	dbselectArea("GWE")
	GWE->(dbSetOrder(1))
	Do While !(cAliGWU)->( Eof() ) .And. lMark
		If GWE->(dbSeek((cAliGWU)->(GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC)))
			If cDocTrp != GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
				If oBrwGWU:IsMark(oBrwGWU:Mark())
					lMark := .F.
				EndIf
			ElseIf aScan(aRet,{|x| x == GWE->(GWE_FILIAL + GWE_CDTPDC + GWE_EMISDC + GWE_SERDC + GWE_NRDC)}) == 0
				aAdd(aRet,GWE->(GWE_FILIAL + GWE_CDTPDC + GWE_EMISDC + GWE_SERDC + GWE_NRDC))
			EndIf
		ElseIf !Empty(cDocTrp) .And. oBrwGWU:IsMark(oBrwGWU:Mark()) // Mensagem que existem documentos selecionados que não estão no mesmo documento de transporte
			lMark := .F.
		ElseIf Empty(cDocTrp) //documento de transporte em branco
			lMark := .F.
			lBranco := .T.
		EndIf
		(cAliGWU)->(dbSkip())
	EndDo
	RestArea(aAreaGWU)

	If !lMark
		aRet := {}
	EndIf
Return {lMark,aRet,lBranco}

/*/{Protheus.doc} A32DocAprov
	@author siegklenes.beulke
	@since 25/11/2013
	@version 1.0

	@param aDocTrp, Array, por referencia, vai devolver um array com as chaves do documento de transporte
	@param aGWD, Array, por referencia, vai devolver um array com as ocorrências relacionadas
	@param cDocTrp, Char, chave do documento de transporte que se quer recuperar as ocorrencias, DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)

	@description

	Verifica se todas as ocorrências relacionadas atraves do documento de transporte
	dos documentos de carga estão aprovadas da ocorrencia posicionada
	ou do documento de transporte passado pelo parametro cDocTrp

	lRet:=A32DocAprov(@aDocTrp,@aGWD)
	lRet:=A32DocAprov(@aDocTrp,@aGWD,'01011   A   ')
/*/
Static Function A32DocAprov(aDocTrp,aGWD,cDocTrp,cOper)
	Local lTodos     := .T.
	Local lTemOcoInt := .F. // Tem pelo menos uma ocorrencia que integra para o documento de carga
	Local aAreaGWD   := {}
	Local aAreaGWL   := {}
	Local aAreaGWE   := {}
	Local aAreaGU5   := {}
	Default cDocTrp  := ""
	Default aDocTrp  := {}
	Default aGWD     := {}

	dbSelectarea("GWD")
	dbSelectarea("GWL")
	dbSelectarea("GWE")
	dbSelectarea("GU5")

	aAreaGWD := GWD->(GetArea())
	aAreaGWL := GWL->(GetArea())
	aAreaGWE := GWE->(GetArea())
	aAreaGU5 := GU5->(GetArea())

	GWD->(dbSetOrder(1))
	GWL->(dbSetOrder(1))
	GWE->(dbSetOrder(1))
	GU5->(dbSetOrder(1))

	If Empty(cDocTrp) // Ocorrência posicionada
		If GWL->(dbseek(GWD->(GWD_FILIAL+GWD_NROCO)));
			.And. GWE->(dbSeek(GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC)))
			cDocTrp := GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
			GWE->(dbSetOrder(2))
			GWE->(dbSeek(cDocTrp))
		EndIf
	Else //Documento como parâmetro
		GWE->(dbSetOrder(2))
		If !GWE->(dbSeek(cDocTrp))
			cDocTrp := ""
		EndIf
	EndIf
	GWL->(dbSetOrder(5))
	If !Empty(cDocTrp)

		aAdd(aDocTrp,GWE->GWE_FILIAL)
		aAdd(aDocTrp,GWE->GWE_FILDT)
		aAdd(aDocTrp,GWE->GWE_NRDT)
		aAdd(aDocTrp,GWE->GWE_SERDT)
		Do While !GWE->(Eof()) .And. cDocTrp == GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT) .And. lTodos
			// Procura todas as ocorrências do documento, independente da filial da ocorrência
			If GWL->(dbSeek(GWE->(GWE_FILIAL + GWE_EMISDC + GWE_CDTPDC + GWE_SERDC + GWE_NRDC)))
				lTemOcoInt := .F.
				Do While !GWL->(Eof()) ;
					.And. GWE->GWE_FILIAL == GWL->GWL_FILDC;
					.And. GWE->GWE_NRDC	== GWL->GWL_NRDC;
					.And. GWE->GWE_EMISDC == GWL->GWL_EMITDC;
					.And. GWE->GWE_SERDC == GWL->GWL_SERDC;
					.And. GWE->GWE_CDTPDC == GWL->GWL_TPDC

					If GWD->(dbSeek(GWL->(GWL_FILIAL+GWL_NROCO)))
						If cOper == '3' //incluir
							If GWD->GWD_SIT != "3" // Reprovado
								if GWD->GWD_SIT != "2" .And. Posicione("GU5",1,xFilial("GU5") + GWD->GWD_CDTIPO,"GU5_INTTMS") == "2"//não aprovado ou pendente, integratms
									lTodos := .F.
									Exit
								Else
									If aScan(aGWD,{|x| x ==  GWD->(GWD_FILIAL+GWD_NROCO)}) == 0
										If GWD->GWD_SIT == "2" .And. GWD->GWD_SITTMS $ "2;3"  // aprovado, pendente integração
											aAdd(aGWD, GWD->(GWD_FILIAL+GWD_NROCO))
											lTemOcoInt := .T.
										ElseIf GWD->GWD_SITTMS == "4"
											lTemOcoInt := .T.
										EndIf
									Else
										lTemOcoInt := .T.
									EndIf
								EndIf
							EndIf
						Else //Operação Estornar
							If aScan(aGWD,{|x| x ==  GWD->(GWD_FILIAL+GWD_NROCO)}) == 0
								If GWD->GWD_SITTMS == "4"  // atualizado
									aAdd(aGWD, GWD->(GWD_FILIAL+GWD_NROCO))
									lTemOcoInt := .T.
								EndIf
							Else
								lTemOcoInt := .T.
							EndIf
						EndIf
					Else
						lTodos := .F.
						Exit
					EndIf
					GWL->(dbSkip())
				EndDo
				If !lTemOcoInt // O documento possui ocorrencia, está aprovada e pendente a integração ou está integrada a ocorrência
					lTodos := .F.
					Exit
				EndIF
			Else
				lTodos := .F.
				Exit
			EndIf
			GWE->(dbSkip())
		EndDo
	Else
		lTodos := .F.
	EndIf
	RestArea(aAreaGWD)
	RestArea(aAreaGWL)
	RestArea(aAreaGWE)
	RestArea(aAreaGU5)

Return lTodos


/*/{Protheus.doc} GFE32REGET
	@author siegklenes.beulke
	@since 27/11/2013
	@version 1.0

	@description

	Realiza a entrega dos documentos de carga relacionados à ocorrência posicionada
	Baseado na função Processamento do Fonte GFEA117A

	@example

	aRet := GFE32REGET()
/*/
Function GFE32REGET(oModel,lDevTot)
	Local lEntrega   := .T.
	Local aNrRoms    := {}
	Local s_GFEA0513 := ExistBlock("GFEA0513")
	Local s_SITEDC   := SuperGetMV("MV_SITEDC",.F.,"1")
	Local aDocsGW1   := {} // Posição dos registros a serem atualizados
	Local aTrechoGWU := {} // Posição dos registros a serem atualizados
	Local aAreaGW1   := {}
	Local aAreaGU3   := {}
	Local aGWL       := {}
	Local cAliasGWU  := Nil
	Local cAliasGWL  := Nil
	Local cAliasGW1  := Nil
	Local cErroMsg   := ""
	Local cCdTrp     := ""
	Local cDtOcor    := ""
	Local cHrOcor    := ""
	Local cTrecho    := .F.
	Local cSeq       := ""
	Local cWhere     := ""
	Local cErroAux   := ""
	Local nTrechoRec := 0
	Local nPosTrecho := 0
	Local nCountTrEn := 0
	Local nTotal     := 0
	Local nI         := 0
	Local nF         := 0
	Local dDtEntr    := Nil
	Local cRecPrz	 := SuperGetMV("MV_RECPRZ",.F.,"0")
	Local nRecBkp	 := 0
	Local cQuery	 := ""
	Local oQry

	Default lDevTot  := .F.

	aAreaGW1 := GW1->(GetArea())
	GW1->(dbSetOrder(1))

	aAreaGU3 := GU3->(GetArea())
	GU3->(dbSetOrder(1))

	If oModel != Nil
		cSeq    := FwFldGet("GWL_SEQ")
		oModel:= oModel:GetModel("GFEA032_GWL")
		nF := oModel:Length()
		For nI := 1 To nF
			If !oModel:IsDeleted(nI)
				aAdd(aGWL, {FwFldGet("GWL_FILDC",nI),;
							FwFldGet("GWL_TPDC",nI),;
							FwFldGet("GWL_EMITDC",nI),;
							FwFldGet("GWL_SERDC",nI),;
							FwFldGet("GWL_NRDC",nI)})
			EndIf
		Next nI
		cCdTrp  := FwFldget("GWD_CDTRP")
		cDtOcor := FwFldget("GWD_DTOCOR")
		cHrOcor := FwFldget("GWD_HROCOR")
	Else
		cQuery := "SELECT GWL.GWL_FILDC,GWL.GWL_TPDC,GWL.GWL_EMITDC,GWL.GWL_SERDC,GWU.GWU_SEQ,GWL.GWL_NRDC"
		cQuery += " FROM " + RetSqlName("GWL") + " GWL"
		cQuery += " INNER JOIN " + RetSqlName("GWU") + " GWU"
		cQuery += " ON GWU.GWU_FILIAL = GWL.GWL_FILDC"
		cQuery += " AND GWU.GWU_EMISDC = GWL.GWL_EMITDC"
		cQuery += " AND GWU.GWU_SERDC = GWL.GWL_SERDC"
		cQuery += " AND GWU.GWU_NRDC = GWL.GWL_NRDC"
		cQuery += " AND GWU.GWU_CDTPDC = GWL.GWL_TPDC"
		cQuery += " AND GWU.GWU_DTENT = ''"
		If _lGWL_SEQ
			cWhere := " AND GWU.GWU_SEQ = GWL.GWL_SEQ"
		EndIf
		cQuery += " WHERE GWL.GWL_FILIAL = ?"
		cQuery += " AND GWL.GWL_NROCO = ?"
		cQuery += " AND GWL.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,GWD->GWD_FILIAL)
		oQry:SetString(2,GWD->GWD_NROCO)
		cAliasGWL := oQry:OpenAlias()

		If (cAliasGWL)->(!Eof())
			cSeq := (cAliasGWL)->GWU_SEQ
			Do While (cAliasGWL)->(!Eof())
				aAdd(aGWL, {(cAliasGWL)->GWL_FILDC,;
							(cAliasGWL)->GWL_TPDC,;
							(cAliasGWL)->GWL_EMITDC,;
							(cAliasGWL)->GWL_SERDC,;
							(cAliasGWL)->GWL_NRDC})
			
				(cAliasGWL)->(dbSkip())
			EndDo
		EndIf
		(cAliasGWL)->(dbCloseArea())
		cCdTrp  := GWD->GWD_CDTRP
		cDtOcor := GWD->GWD_DTOCOR
		cHrOcor := GWD->GWD_HROCOR
	EndIf

	If Len(aGWL) == 0
		cErroMsg += STR0075 // "Não existem Documentos de Carga relacionados à ocorrência ou todos os documentos possuem data de entrega informada."
	Else
		nF := Len(aGWL)
		For nI := 1 To nF
			cFilDc  := aGWL[nI][1]
			cCdTpDc := aGWL[nI][2]
			cEmitDc := aGWL[nI][3]
			cSerDc  := aGWL[nI][4]
			cNrDc   := aGWL[nI][5]
			
			cQuery := "SELECT GW1.R_E_C_N_O_ RECNOGW1,
			cQuery += " GW1.GW1_FILIAL,
			cQuery += " GW1.GW1_CDTPDC,
			cQuery += " GW1.GW1_EMISDC,
			cQuery += " GW1.GW1_SERDC,
			cQuery += " GW1.GW1_NRDC,
			cQuery += " GW1.GW1_SIT,
			cQuery += " GW1.GW1_NRROM"
			cQuery += " FROM " + RetSqlName("GW1") + " GW1"
			cQuery += " WHERE GW1.GW1_FILIAL = ?"
			cQuery += " AND GW1.GW1_CDTPDC = ?"
			cQuery += " AND GW1.GW1_EMISDC = ?"
			cQuery += " AND GW1.GW1_SERDC = ?"
			cQuery += " AND GW1.GW1_NRDC = ?"
			cQuery += " AND GW1.D_E_L_E_T_ = ''"

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery) 
			oQry:SetString(1,cFilDc)
			oQry:SetString(2,cCdTpDc) 
			oQry:SetString(3,cEmitDc) 
			oQry:SetString(4,cSerDc)
			oQry:SetString(5,cNrDc)
			cAliasGW1 := oQry:OpenAlias()

			If (cAliasGW1)->(!Eof())
				nTrechoRec := 0
				nPosTrecho := 0
				nCountTrEn := 0

				// Busca os trechos do documento de carga para atribuir a data e hora de entrega e marcar o documento de carga como entrege
				// A Data e Hora de entrega serão atribuidos nos trechos que:
				//     a) O transportador do arquivo (GXL->GXL_CDTRP) for igual ao do trecho
				//     b) O Transportador de faturamento do transportador do arquivo for igual ao do trecho
				//     c) Também é possível buscar pela raiz do CNPJ, desconsiderando a filial
				// O Documento de Carga será entregue quando?
				//     a) For o último trecho
				cQuery := "SELECT GWU.R_E_C_N_O_ RECNOGWU,
				cQuery += " GWU.GWU_PAGAR,
				cQuery += " GWU.GWU_CDTRP,
				cQuery += " GWU.GWU_DTENT"
				cQuery += " FROM " + RetSqlName("GWU") + " GWU"
				cQuery += " WHERE GWU.GWU_FILIAL = ?"
				cQuery += " AND GWU.GWU_CDTPDC = ?"
				cQuery += " AND GWU.GWU_EMISDC = ?"
				cQuery += " AND GWU.GWU_SERDC = ?"
				cQuery += " AND GWU.GWU_NRDC = ?"
				cQuery += " AND GWU.GWU_SEQ = ?"
				cQuery += " AND GWU.GWU_DTENT = ?"
				cQuery += " AND GWU.D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery) 
				oQry:SetString(1,(cAliasGW1)->GW1_FILIAL)
				oQry:SetString(2,(cAliasGW1)->GW1_CDTPDC) 
				oQry:SetString(3,(cAliasGW1)->GW1_EMISDC) 
				oQry:SetString(4,(cAliasGW1)->GW1_SERDC)
				oQry:SetString(5,(cAliasGW1)->GW1_NRDC)
				oQry:SetString(6,cSeq)
				oQry:SetString(7,' ')
				cAliasGWU := oQry:OpenAlias()
				
				Do While (cAliasGWU)->(!Eof())
					dDtEntr := (cAliasGWU)->GWU_DTENT
					// Soma os trechos que são de entregas ou não pagos
					If (cAliasGWU)->GWU_PAGAR == '1'
						nCountTrEn++
					EndIf

					If nTrechoRec == 0
						If AllTrim((cAliasGWU)->GWU_CDTRP) == AllTrim(cCdTrp)
							nTrechoRec := (cAliasGWU)->RECNOGWU
							nPosTrecho := nCountTrEn
							cTrecho    := .T.
						Else
							If GU3->(dbSeek(xFilial("GU3") + cCdTrp))
								If AllTrim(GU3->GU3_CDEMFT) == AllTrim((cAliasGWU)->GWU_CDTRP)
									nTrechoRec := (cAliasGWU)->RECNOGWU
									nPosTrecho := nCountTrEn
								EndIf
							EndIf
							If s_VLCNPJ == "2"
								If SubStr(Posicione("GU3",1,xFilial("GU3")+(cAliasGWU)->GWU_CDTRP,"GU3->GU3_IDFED"),1,8) == SubStr(Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3->GU3_IDFED"),1,8)
									nTrechoRec := (cAliasGWU)->RECNOGWU
									nPosTrecho := nCountTrEn
								EndIf
							EndIf
						EndIf
					EndIf
					(cAliasGWU)->(dbSkip())
				EndDo
				(cAliasGWU)->(dbCloseArea())
				
				If nTrechoRec == 0
					cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : Trecho não encontrado com transportador " + cCdTrp  + CRLF
				EndIf
				//Verificando se o Doc. Carga Está Embarcado
				//Se devolução total, pode ser entregue. // Se entrega normal, só vai registrar a entrega do trecho, mantendo a situação como retornado
				If (cAliasGW1)->GW1_SIT == "4" ;
					.Or. (!lDevTot .And. (cAliasGW1)->GW1_SIT == "6") ;
					.Or. (lDevTot .And. (cAliasGW1)->GW1_SIT == "5") ;
					.Or. ((cAliasGW1)->GW1_SIT == "5" .And. Empty(dDtEntr))

					// Efetiva a alteração do trecho com a Data e Hora de entrega
					// Marca o Documento de Carga como entregue
					If nTrechoRec != 0
						GWU->(dbGoTo(nTrechoRec))
						If GWU->(!Eof() )
							If cDtOcor > Date()
								cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : A data de entrega da Ocorrência não pode ser maior que a data atual." + CRLF
							Else
								If nPosTrecho == nCountTrEn
									//Armazena posição para atualização gw1
									aAdd(aDocsGW1,(cAliasGW1)->RECNOGW1)
									//Armazena os romaneios afetados para atualização
									Aadd(aNrRoms, { (cAliasGW1)->GW1_FILIAL,;
													(cAliasGW1)->GW1_NRROM})
								EndIf
								//Armazena posição para atualização gw1
								aAdd(aTrechoGWU,nTrechoRec)
							EndIf
						Else
							cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : Erro fatal ao encontrar trecho para entrega para o documento de carga." + CRLF
						EndIf
					Else
						cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : Trecho não encontrado com transportador " + cCdTrp + " ou o trecho já possui data de entrega (manual/ocorrência)" + CRLF
					EndIf
				Else
					If !lDevTot
						cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : Documento de carga deve estar com a situação 4=Embarcado ou 6=Retornado, e com o trecho sem data de entrega." + CRLF
					Else
						cErroMsg += AllTrim((cAliasGW1)->GW1_SERDC) + '/' + AllTrim((cAliasGW1)->GW1_NRDC) + " : Documento de carga deve estar com a situação 4=Embarcado ou 5=Entregue." + CRLF
					EndIf
				EndIf
			Else
				cErroMsg += AllTrim(cSerDc) + '/' + AllTrim(cNrDc) + " : Documento de carga inexistente." + CRLF
			EndIf
			(cAliasGW1)->(dbCloseArea())
		Next nI
	EndIf
	
	// Verificando a data de entrega em comparação com os demais trechos
	If GFXFU12123("GFEA51ANT")
		nF := Len(aTrechoGWU)
		For nI := 1 To nF
			GWU->(dbGoTo(aTrechoGWU[nI]))
			If !GFEA051VDE(cDtOcor, cHrOcor, Nil, Nil, @cErroAux)
			 	cErroMsg += cErroAux + CRLF
			EndIf
		Next nI
	EndIf
	
	If Empty(cErroMsg)
		nF := Len(aTrechoGWU)
		For nI := 1 To nF
			GWU->(dbGoTo(aTrechoGWU[nI]))
			If GWU->(!Eof())
				// Atribui a Data e Hora de entrega para o trecho
				RecLock("GWU",.F.)
					GWU->GWU_DTENT := cDtOcor
					GWU->GWU_HRENT := cHrOcor
				GWU->(MSUnlock())

				If GWU->GWU_DTPENT <> cDtOcor .Or. GWU->GWU_HRPENT <> cHrOcor
					nRecBkp := GWU->(Recno())
					If cRecPrz == "1"
						If GWU->GWU_DTPENT < cDtOcor .Or. (GWU->GWU_DTPENT == cDtOcor .And. GWU->GWU_HRPENT < cHrOcor)
							RecPrzTrec(GWU->(Recno()), GWU->GWU_DTENT, GWU->GWU_HRENT)
						ENDIF
					ElseIf cRecPrz == "2"
						RecPrzTrec(GWU->(Recno()), GWU->GWU_DTENT, GWU->GWU_HRENT)
					EndIf

					GWU->(dbGoTo(nRecBkp))
				EndIf
				
				GW1->( dbSetOrder(1) )
				If GW1->(dbSeek(GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC) )
					If lDevTot .And. GW1->GW1_SIT != "6"
						RecLock("GW1",.F.)
							GW1->GW1_SIT := "6"
						GW1->(MsUnLock())
					ElseIf GW1->GW1_SIT != "6" .And. GW1->GW1_SIT != "5"
						lEntrega := .T.
						nTotal   := 0
						
						cQuery := "SELECT GWU.GWU_SEQ,GWU.GWU_PAGAR,GWU.GWU_DTENT "
						cQuery += " FROM " + RetSqlName("GWU") + " GWU"
						cQuery += " WHERE GWU.GWU_FILIAL = ?"
						cQuery += " AND GWU.GWU_CDTPDC = ?"
						cQuery += " AND GWU.GWU_EMISDC = ?"
						cQuery += " AND GWU.GWU_SERDC = ?"
						cQuery += " AND GWU.GWU_NRDC = ?"
						cQuery += " AND GWU.D_E_L_E_T_ = ''"

						cQuery := ChangeQuery(cQuery)
						oQry := FWExecStatement():New(cQuery) 
						oQry:SetString(1,GWU->GWU_FILIAL)
						oQry:SetString(2,GWU->GWU_CDTPDC) 
						oQry:SetString(3,GWU->GWU_EMISDC) 
						oQry:SetString(4,GWU->GWU_SERDC)
						oQry:SetString(5,GWU->GWU_NRDC)
						cAliasGWU := oQry:OpenAlias()

						Do While (cAliasGWU)->(!Eof())
							nTotal++
							If s_SITEDC == "1" .Or. Empty(s_SITEDC)
								If lEntrega  .And. (cAliasGWU)->GWU_PAGAR == "1" .And. Empty((cAliasGWU)->GWU_DTENT)
									lEntrega := .F.
								EndIf
							Else 
								If lEntrega  .And. Empty((cAliasGWU)->GWU_DTENT)
									lEntrega := .F.
								EndIf
							EndIf
							(cAliasGWU)->(dbSkip())
						EndDo
						(cAliasGWU)->(dbCloseArea())
						
						//Se for o ultimo trecho ou todos pagos tiverem entregues
						If Val(GWU->GWU_SEQ) == nTotal .Or. lEntrega
							RecLock ("GW1", .F.)
								GW1->GW1_SIT := "5"
							GW1->(MsUnLock())
						EndIf
					EndIf
				EndIf
			EndIf
			
			//Ponto de Entrada Vicunha
			If s_GFEA0513
				ExecBlock( "GFEA0513",.F.,.F.,{cDtOcor,cHrOcor,3})
			EndIf
		Next nI
		nF := Len(aDocsGW1)
		For nI := 1 To nF
			// Altera o Documento de Carga para Entregue caso seja o último trecho
			GW1->(dbGoTo(aDocsGW1[nI]))
			If GW1->(!Eof())
				GFE51IENT() //Integração da data de saída Protheus/Datasul
			EndIf
		Next nI
		
		If len(aNrRoms) > 0
			A117AtuSitRom(aNrRoms)
		EndIf
	EndIf
	RestArea(aAreaGW1)
	RestArea(aAreaGU3)
Return cErroMsg

/*/{Protheus.doc} GFE032TMSINT
	@author siegklenes.beulke
	@since 29/11/2013
	@version 1.0

	@param cDocTrp,Char,chave do documento de transporte DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)
	@param lMan, Number, para automático é necessário estar declarado
						Private GFEResult := GFEViewProc():New()
						Private nCountErro := 0

	@description

	Verifica se é possível integrar a ocorrência Posicionada ou do documento de transporte passado por parâmetro
	e integra com o TMS, atualizando a situação da integração
/*/
Function GFE032TMSINT(cDocTrp,lMan,cOpc)
	Local lRet      := .F.
	Local lOk       := .F.
	Local aCab      := {}
	Local aItens    :={} // ocorrencias
	Local aNFAvaria := {} // documentos
	Local aDocTrp   := {}
	Local aGWD      := {}
	Local nPeso     := 0
	Local nVolOri   := 0
	Local aNF       := {}
	Local aCols     := {}
	Local nPesoNota := 0
	Local aErro     := {}
	Local cMsg      := ""
	Local nX        := 0
	Local cSeq      := ""
	Local nSeq      := 0
	Local dData     := Nil
	Local cHora     := ""
	Local aAreaGWD  := GWD->(GetArea())
	Local nAlt      := 0
	Local cMsgOco   := ""
	Local cNrOcov   := ""
	Local nVlrRec   := 0

	Default cDocTrp := ""
	Default lMan    := .T. // Manual
	Default cOpc    := '3'

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	If Type("GFEResult") != "O"
		GFEResult := GFEViewProc():New()
		nCountErro := 0
	EndIf
	
	If cOpc == '3'
		If GFXCP12117("GWD_CHVEXT") .And. !Empty(GWD->GWD_CHVEXT) 
			If !IsBlind()
				MsgInfo("Ocorrência gerada via integração não permite integração com o SIGATMS.","Aviso")
			EndIf
			Return .F.
		EndIf
			
		If Empty(cDocTrp) .And. !(GWD->GWD_SITTMS $ "2;3")// .And. GWD->GWD_SIT != "2"
			If !IsBlind()
				MsgInfo("Situação da Ocorrência não permite integração com o SIGATMS.","Aviso")
			EndIf
			Return .F.
		EndIf
	
		If GWD->GWD_SIT == "3"
			If !IsBlind()
				MsgInfo("Ocorrência Reprovadas não permite integração com o SIGATMS.","Aviso")
			EndIf
			Return .F.
		EndIf
		If GWD->GWD_SIT == "1"
			If !IsBlind()
				MsgInfo("Ocorrência Pendente não permite integração com o SIGATMS.","Aviso")
			EndIf
			Return .F.
		EndIf
	EndIf

	If !lMan
		GFEResult:Add("")
	EndIf
	dbSelectArea("GU5")
	GU5->(dbSetOrder(1))
	If GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO)) .Or. !Empty(cDocTrp)
		If GfeVerCmpo({"GU5_INTTMS"}) .And. SuperGetMv("MV_TMS2GFE", .F. , .F.) .And. (GU5->GU5_INTTMS == "2" .Or. !Empty(cDocTrp))
			If !A32DocAprov(@aDocTrp,@aGWD,cDocTrp,cOpc) .And. cOpc == '3'
				If !IsBlind()
					If Len(aDocTrp) == 0
						If (nCountErro > 0)
							GFEResult:AddErro("")
							GFEResult:AddErro(Replicate("-", 50))
						EndIf
						GFEResult:AddErro( "Não existe Documento de Transporte associado à Ocorrência." )
						nCountErro++
					Else
						If Empty(cDocTrp)
							If (nCountErro > 0)
								GFEResult:AddErro("")
								GFEResult:AddErro(Replicate("-", 50))
							EndIf
							GFEResult:AddErro(GWD->GWD_NROCO + " : poderá ser integrada ao SIGATMS quando todos os Documentos de Carga do Documento de Transporte " + AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " possuírem Ocorrências aprovadas no SIGAGFE.")
							nCountErro++
						Else
							If (nCountErro > 0)
								GFEResult:AddErro("")
								GFEResult:AddErro(Replicate("-", 50))
							EndIf
							GFEResult:Add(AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : Não enviado.")
							GFEResult:AddErro(AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : ocorrências não podem ser integradas no momento. Consulte as pendências do Documento de Transporte no Monitor de Integração SIGATMS X SIGAGFE para mais detalhes.")
							nCountErro++
						EndIf
					EndIf
				EndIf
			Else
				If Len(aGWD) > 0
					dbSelectArea("DUA")
					//-- Cabecalho da Ocorrencia
					AAdd(aCab,{"DUA_FILORI",Space(TamSx3("DUA_FILORI")[1]),Nil})
					AAdd(aCab,{"DUA_VIAGEM",Space(TamSx3("DUA_VIAGEM")[1]),Nil})
					dbSelectArea("GWD")
					GWD->(dbSetOrder(1))
					dbSelectArea("GU5")
					GU5->(dbSetOrder(1))
					dbSelectArea("GW8")
					GW8->(dbSetOrder(1))
					dbSelectArea("GW1")
					GW1->(dbSetOrder(1))
					dbSelectArea("GWL")
					GWL->(dbSetOrder(1))
					GWD->(dbSeek(aGWD[1]))
					dData := GWD->GWD_DTOCOR
					cHora := GWD->GWD_HROCOR
					For nX := 2 to Len(aGWD) // Determina a melhor data hora da ocorrencia
						GWD->(dbSeek(aGWD[nX]))
						If GWD->GWD_DTOCOR == dData
							If GWD->GWD_HROCOR > cHora
								cHora := GWD->GWD_HROCOR
							EndIf
						ElseIf GWD->GWD_DTOCOR > dData
							dData := GWD->GWD_DTOCOR
							cHora := GWD->GWD_HROCOR
						EndIf
					Next nX
					For nX := 1 to Len(aGWD)
						aSize(aItens,    0 )
						aSize(aNFAvaria, 0 )
						aSize(aNF,       0 )
						
						GWD->(dbSeek(aGWD[nX]))

						nVlrRec := 0
						GWF->(dbSetOrder(5))
						If GWF->( dbseek(GWD->GWD_FILIAL + GWD->GWD_NROCO) ) // Validação cálculos de frete (devolução/reentrega/serviço)
							Do While GWF->(!Eof()) .And. GWF->(GWF_FILIAL + GWF_NROCO) == GWD->(GWD_FILIAL + GWD_NROCO)
								If GWF->GWF_TPCALC == '4' // Reentrega
									GWI->(DbSetOrder(1))
									If GWI->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
										Do While GWI->(!Eof()) .And. GWI->(GWI_FILIAL + GWI_NRCALC) == GWF->(GWF_FILIAL + GWF_NRCALC)
											nVlrRec += GWI->GWI_VLFRET

											GWI->(dbSkip())
										EndDo
									EndIf
								EndIf

								GWF->(dbSkip())
							EndDo
						EndIf

						If cOpc == '3'
						
							GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
							GWL->(dbSeek(GWD->(GWD_FILIAL+GWD_NROCO)))
							
							cMsgOco := 'Ocorrência: ' + IIF(Empty(GWL->GWL_FILIAL),'',GWL->GWL_FILIAL +'/') + GWL->GWL_NROCO +' Documentos de Transporte: '
							
							Do While !GWL->(Eof()) .And. GWD->(GWD_FILIAL+GWD_NROCO) == GWL->(GWL_FILIAL + GWL_NROCO)
								nPesoNota := 0
								GW8->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
								Do While !GW8->(Eof()) .And. GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC == GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC
									nPesoNota += GW8->GW8_PESOR
									GW8->(dbSkip())
								EndDo
								nPeso += nPesoNota
								If GW1->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
									nVolOri += GW1->GW1_QTVOL
									//aNF -> {DTC->DTC_NUMNFC,(DTC->DTC_PESO/DTC->DTC_QTDVOL)}
									aAdd(aNf,{GW1->GW1_NRDC, (nPesoNota/GW1->GW1_QTVOL)})
									//aCols -> {DV4->DV4_NUMNFC,DV4->DV4_SERNFC,nQtdVol,DV4->DV4_QTDPND ,.F.}
									aAdd(aCols,{GW1->GW1_NRDC,GW1->GW1_SERDC,GWD->GWD_QTDVOL,GWD->GWD_QTDVOL,.F.})
								EndIf
								
								GWE->(dbSetOrder(1))
								GWE->(dbSeek(GWL->GWL_FILDC + GWL->GWL_TPDC + GWL->GWL_EMITDC + GWL->GWL_SERDC + GWL->GWL_NRDC))
								nAlt := ASCAN(aItens,{|X| AllTrim(X[06,02]) == AllTrim(GU5->GU5_OCOTMS) .AND.;
														  AllTrim(X[08,02]) == AllTrim(GWE->GWE_FILDT)  .AND.;
														  AllTrim(X[09,02]) == AllTrim(GWE->GWE_NRDT)   .AND.;
														  AllTrim(X[10,02]) == AllTrim(GWE->GWE_SERDT)})
								
								If nAlt == 0 	
									//-- Itens da Ocorrencia
									nSeq++
									cSeq := StrZero(nSeq,TamSx3("DUA_SEQOCO")[1])
									AAdd(aItens,{ ;
												{"DUA_FILIAL",GWD->GWD_FILIAL,Nil},;
												{"DUA_FILOCO",GWD->GWD_FILIAL,Nil},;
												{"DUA_SEQOCO",cSeq,Nil},;
												{"DUA_DATOCO",dData ,Nil},;
												{"DUA_HOROCO",cHora ,Nil},;
												{"DUA_CODOCO",GU5->GU5_OCOTMS ,Nil},;
												{"DUA_MOTIVO",Posicione("GU6",1,xFilial("GU6") + GWD->GWD_CDMOT,"GU6_DESC") ,Nil},;
												{"DUA_FILDOC",GWE->GWE_FILDT ,Nil},;
												{"DUA_DOC"   ,GWE->GWE_NRDT ,Nil},;
												{"DUA_SERIE" ,GWE->GWE_SERDT ,Nil},;
												{"DUA_QTDOCO",GW1->GW1_QTVOL ,Nil},;
												{"DUA_PESO"  ,nPesoNota ,Nil},;
												{"DUA_PESOCO",nPesoNota ,Nil},;
												{"DUA_CHVEXT",GWD->GWD_FILIAL + ";" + GWD->GWD_NROCO ,Nil},;
												{"DUA_ORIGEM","SIGAGFE" ,Nil}})

									If GFXCP12137("DUA_VLRRCT") .And. nVlrRec > 0
										aAdd(aTail(aItens), {"DUA_VLRRCT", nVlrRec, NIL})
									EndIf
								Else
									aItens[nAlt,11,2] := aItens[nAlt,11,2] + GW1->GW1_QTVOL  
									aItens[nAlt,12,2] := aItens[nAlt,12,2] + nPesoNota  
									aItens[nAlt,13,2] := aItens[nAlt,13,2] + nPesoNota  
								EndIf
								
								GWL->(dbSkip())
							EndDo

							DT2->(DbSetOrder(1))
							DT2->(dbSeek(xFilial("DT2") + GU5->GU5_OCOTMS))
							If DT2->DT2_TIPOCO == "06" .Or. DT2->DT2_TIPOCO == "19" // Conforme instrução da Katia Bianch / Somente Tipo ocorrencia == "06"
								aAdd(aNFAvaria,{aDocTrp[2]+aDocTrp[3]+aDocTrp[4],;
												aCols,;
												aNF,;
												DT2->DT2_CODOCO,;
												DT2->DT2_TIPPND,;
												AllTrim(Str(Val(cSeq)))})
							EndIf
						Else //Opc = 6
							aSize(aCab, 0 )
						
							DUA->( DbSetOrder( 7) )
							DUA->(dbSeek(xFilial("DUA")+aDocTrp[2]+aDocTrp[3]+aDocTrp[4]))
							
							Do While !DUA->(Eof()) .And. DUA->(DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE) == xFilial("DUA")+aDocTrp[2]+aDocTrp[3]+aDocTrp[4]
							
								If AllTrim(DUA->DUA_CHVEXT) == AllTrim(GWD->GWD_FILIAL + ";" + GWD->GWD_NROCO)
									Aadd(aCab,{"DUA_FILOCO",DUA->DUA_FILOCO,NIL})
									Aadd(aCab,{"DUA_NUMOCO",DUA->DUA_NUMOCO,NIL})
									Aadd(aCab,{"DUA_FILORI",DUA->DUA_FILORI,NIL})
									Aadd(aCab,{"DUA_VIAGEM",DUA->DUA_VIAGEM,NIL})
									//-- Itens da Ocorrencia
									aAdd(aItens,{ {"DUA_SEQOCO", DUA->DUA_SEQOCO , NIL},;
													{"DUA_ESTOCO", '1', NIL},;
													{"DUA_DATOCO", DUA->DUA_DATOCO , NIL},;
													{"DUA_HOROCO", DUA->DUA_HOROCO , NIL},;
													{"DUA_CODOCO", DUA->DUA_CODOCO , NIL},;
													{"DUA_SERTMS", DUA->DUA_SERTMS , NIL},;
													{"DUA_FILDOC", DUA->DUA_FILDOC , NIL},;
													{"DUA_DOC"   , DUA->DUA_DOC    , NIL},;
													{"DUA_SERIE" , DUA->DUA_SERIE  , NIL},;
													{"DUA_QTDOCO", DUA->DUA_QTDOCO , NIL},;
													{"DUA_PESOCO", DUA->DUA_PESOCO , NIL}})

									If GFXCP12137("DUA_VLRRCT") .And. nVlrRec > 0
										aAdd(aTail(aItens), {"DUA_VLRRCT", nVlrRec, NIL})
									EndIf
								EndIf

								DUA->(dbSkip())
							EndDo
							cMsgOco := 'Ocorrência: ' + IIF(Empty(GWD->GWD_FILIAL),'',GWD->GWD_FILIAL +'/') + GWD->GWD_NROCO +' Documentos de Transporte: '
						EndIf
						cNrOcov := GWD->GWD_NROCO 
						MsAguarde( {|| MsExecAuto( {|x,y,z,w| TMSA360(x,y,z,w)}, aCab, aItens, aNFAvaria, Val(cOpc) ) }, 'Aguarde, enviando ao TMS...' )
						//Default nOperacao = 3 // inserção
						//TODO determinar erro somente se não existir um DUA (chave ext e chave documento transporte)
						GWD->(dbSetOrder(1))
						GWD->(dbSeek(xFilial("GWD")+cNrOcov))
						If lMsErroAuto
							aErro := GetAutoGrLog()
							cMsg := ""

							For nX := 1 To Len(aErro)
								cMsg += aErro[nX] + CRLF
							Next nX
							dbSelectArea("DUA")
							DUA->(dbSetOrder(4))
							lMsErroAuto := .T.
							RecLock("GWD",.F.)
								If cOpc == '3'
									DUA->(dbSeek(xFilial("DUA")+aDocTrp[2]+aDocTrp[3]+aDocTrp[4]))
									Do While !DUA->(Eof()) .And. DUA->(DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE) == xFilial("DUA")+aDocTrp[2]+aDocTrp[3]+aDocTrp[4]
										If AllTrim(DUA->DUA_CHVEXT) == AllTrim(GWD->GWD_FILIAL + ";" + GWD->GWD_NROCO)
											lMsErroAuto := .F.
											lOk := .T.
										EndIf
										DUA->(dbSkip())
									EndDo
								EndIf
								If !lMsErroAuto
									IF cOpc == '3' 
										GWD->GWD_SITTMS := "4"
									Else
										GWD->GWD_SITTMS := "2"
									EndIf
								Else
									GWD->GWD_SITTMS := "3"
								EndIf
								GWD->GWD_MOTTMS := cMsg
							GWD->(MSUnlock())
							If !IsBlind()
								If lOk
									GFEResult:Add(cMsgOco + AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : Integrado.")
								Else
									GFEResult:Add(cMsgOco + AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : Não Integrado.")
									If (nCountErro > 0)
										GFEResult:AddErro("")
										GFEResult:AddErro(Replicate("-", 50))
									EndIf
									GFEResult:AddErro(cMsgOco + AllTrim(aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : Informações do SIGATMS.")
									GFEResult:AddErro(cMsg,2)
									nCountErro++
								EndIf
							EndIf
						Else
							RecLock("GWD",.F.)
								If cOpc == '3'
									GWD->GWD_SITTMS := "4"
									GWD->GWD_MOTTMS := "Integração realizado com sucesso"
									GWD->GWD_DTTMS := Date()
								Else
									GWD->GWD_SIT    := "1"
									GWD->GWD_SITTMS := "1"
									GWD->GWD_MOTTMS := ""
									GWD->GWD_DTTMS  := CToD(" / / ")
								EndIF
							GWD->(MSUnlock())
							lRet := .T.
							If !IsBlind()
								GFEResult:Add(cMsgOco + AllTrim( aDocTrp[4]) + "/" + AllTrim(aDocTrp[3]) + " : Integrado.")
							EndIf
						EndIf
					Next nX
				Else
					GFEResult:Add("Registros já integrados ou nenhum registro para ser integrado.")
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaGWD)

	If lMan .And. !IsInCallStack("GFEA117") // Se for manual, mostra aqui, se for automatico, a rotina chamadora mostra o resultado
		GFEResult:Show("Integração", "Documentos", "Informações", "Um ou mais documentos possuem alertas ou não foram integrados. Clique em 'Informações' para mais detalhes.")
	EndIf

Return lRet

//Uso do dicionário gatilho gwd_cdtipo 005
Function GFE32TPMOT(cCDTipo,cCDMot)
	dbSelectArea("GU5")
	dbSelectArea("GU4")
	If Posicione("GU5",1,xFilial("GU5") + cCDTipo,"GU5_INTTMS") == "2"
		cCDMot := Posicione("GU4",2,xFilial("GU4") + cCDTipo,"GU4_CDMOT")
	EndIf
Return cCDMot

Static Function GFEA32REL(lMesmo)
	Local aRom       := {} 
	Local cQuery     := ''
	Local cTmp       := ''
	Local cSelect    := ''
	Local cValue     := FWFldGet("GWD_CDTRP")	
	Local lCpoSrGW1  := GfeVerCmpo({"GW1_SDOC"})
	Local s_GFEA0328 := ExistBlock("GFEA0328")
	Local cQuery	 
	Local oQry
	
	Default lMesmo   := .F. //Indica se o próprio doc carga que está sendo utilizado como base p pesquisa tmb será trazido na consulta

	nRecno := Iif(lMesmo,0,GW1->(Recno()))
	cSelect := If(lCpoSrGW1,",GW1.GW1_SDOC","")

	cQuery := "	SELECT GW1.GW1_FILIAL, GW1.GW1_NRDC, GW1.GW1_CDTPDC, GW1.GW1_SERDC, GW1.GW1_EMISDC," 
	cQuery += " GW1.GW1_NRROM, GWU.GWU_SEQ, GWU.GWU_DTENT, GW1.GW1_QTVOL, GW1.GW1_CDDEST " + If(lCpoSrGW1,",GW1.GW1_SDOC","")
	cQuery += " FROM " + RetSQLName("GW1") + " GW1, " + RetSQLName("GWU") + " GWU "
	cQuery += " WHERE GW1.GW1_FILIAL = ?"   
	cQuery += " AND GW1.GW1_NRROM  = ?"
	cQuery += " AND GW1.R_E_C_N_O_ <> ?"
	cQuery += " AND GWU.GWU_FILIAL = ?"
	cQuery += " AND GWU.GWU_CDTRP  = ?"
	cQuery += " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += " AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += " AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += " AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += " AND GWU.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetNumeric(1,xFilial("GWF"))
	oQry:SetString(2,GW1->GW1_NRROM)
	oQry:SetString(3,Str( nRecno ))
	oQry:SetNumeric(4,xFilial("GWU")) 
	oQry:SetNumeric(5,cValue)
	cTmp := oQry:OpenAlias()	

	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	Do While (cTmp)->( !Eof() )
		aAdd(aRom, {(cTmp)->(GW1_FILIAL), (cTmp)->(GW1_CDTPDC), (cTmp)->(GW1_EMISDC), (cTmp)->(GW1_SERDC), (cTmp)->(GW1_NRDC), (cTmp)->(GWU_SEQ), (cTmp)->(GWU_DTENT), (cTmp)->(GW1_QTVOL), (cTmp)->(GW1_CDDEST), If(lCpoSrGW1,(cTmp)->(GW1_SDOC),"")})
		(cTmp)->( dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

	If s_GFEA0328 .And. Len(arom) > 0
		aRom := ExecBlock("GFEA0328",.F.,.F.,{aRom,len(arom[1])})
	EndIf
Return aRom

Static Function GFEA32CAL()
	Local cValue     := FWFldGet("GWD_CDTRP")
	Local s_GFEA0328 := ExistBlock("GFEA0328")
	Local QryGWH	 := GetNextAlias()
	Local cQuery	 := ""
	Local oQry
	Local cRecnoGWH  := GWH->(Recno())
	
	dbSelectArea("GWF")
	GWF->( dbSetOrder(1) )
	If GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC ) )

		IF GWF->GWF_TPCALC == '1'

			cQuery := "SELECT GWH.GWH_NRCALC, GW1.GW1_NRDC, GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GWU.GWU_SEQ, GWU.GWU_DTENT, GW1.GW1_QTVOL, GW1.GW1_CDDEST, GW1.GW1_SDOC"
			cQuery += " FROM " + RetSqlName("GWH") + " GWH"
			cQuery += "," + RetSqlName("GW1") + " GW1"
			cQuery += "," + RetSqlName("GWU") + " GWU"
			cQuery += " WHERE GWH.GWH_FILIAL = ?"
			cQuery += " AND GWH.GWH_NRCALC = ?"
			cQuery += " AND GWH.R_E_C_N_O_ != ?"
			cQuery += " AND GW1.GW1_FILIAL = ?"
			cQuery += " AND GW1.GW1_CDTPDC = GWH.GWH_CDTPDC" 
			cQuery += "	AND GW1.GW1_EMISDC = GWH.GWH_EMISDC"
			cQuery += "	AND GW1.GW1_SERDC = GWH.GWH_SERDC"
			cQuery += "	AND GW1.GW1_NRDC = GWH.GWH_NRDC"
			cQuery += "	AND GWU.GWU_FILIAL = ?"
			cQuery += "	AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC" 
			cQuery += "	AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
			cQuery += "	AND GWU.GWU_SERDC = GW1.GW1_SERDC" 
			cQuery += "	AND GWU.GWU_NRDC = GW1.GW1_NRDC"
			cQuery += " AND GWU.GWU_CDTRP = ?"
			cQuery += " AND GWH.D_E_L_E_T_ = ''"
			cQuery += " AND GWU.D_E_L_E_T_ = ''"
			cQuery += " AND GW1.D_E_L_E_T_ = ''"

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery) 
			oQry:SetNumeric(1,xFilial("GWH"))
			oQry:SetString(2,GWH->GWH_NRCALC)
			oQry:SetNumeric(3,cRecnoGWH)
			oQry:SetNumeric(4,xFilial("GW1")) 
			oQry:SetNumeric(5,xFilial("GWU"))
			oQry:SetString(6,cValue) 
			QryGWH := oQry:OpenAlias()	

			(QryGWH)->(dbGotop())
			Do While (QryGWH)->(!Eof())

				aAdd(aCalc,{(QryGWH)->(GW1_FILIAL), (QryGWH)->(GW1_CDTPDC), (QryGWH)->(GW1_EMISDC), (QryGWH)->(GW1_SERDC), (QryGWH)->(GW1_NRDC), (QryGWH)->(GWU_SEQ), (QryGWH)->(GWU_DTENT), (QryGWH)->(GW1_QTVOL), (QryGWH)->(GW1_CDDEST),(QryGWH)->(GW1_SDOC)})

				(QryGWH)->(dbSkip())
			EndDo
			(QryGWH)->(dbCloseArea())

			If s_GFEA0328 .And. Len(aCalc)
				aCalc := ExecBlock("GFEA0328",.F.,.F.,{aCalc,Len(aCalc[1])})
			EndIf
		EndIf
	EndIf
Return aCalc

// Utilizado para Ocorrências de Serviço
// Agrupa as Notas Fiscais para que o cálculo do frete seja realizado pela GFEXFUNB - GFECLCFRT
// Lógica retirada da GFE050CALC
Static Function criaTabTemp(lApraut,cSeq)
	Local nX         := 0
	Local nPos       := 0
	Local aTrechos   := 0
	Local aUnitiliz  := {}

	dbSelectArea("GWN")
	GWN->( dbSetOrder(1) )
	If GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )
		criaGrpClc(lApraut)
	EndIf

	// Obtem a quantidade de unitizadores (embalagens) do documento de carga
	nQtdeUnit := 0

	dbSelectArea("GWB")
	GWB->( dbSetOrder(2) )
	GWB->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
	Do While !GWB->( Eof() ) .And. GWB->GWB_FILIAL == GW1->GW1_FILIAL .And. GWB->GWB_CDTPDC == GW1->GW1_CDTPDC ;
							 .And. GWB->GWB_EMISDC == GW1->GW1_EMISDC .And. GWB->GWB_SERDC  == GW1->GW1_SERDC ;
							 .And. GWB->GWB_NRDC == GW1->GW1_NRDC

		nQtdeUnit += GWB->GWB_QTDE
		nPos := aScan(aUnitiliz,{|x|x[1] == GWB->GWB_CDUNIT})
		If nPos == 0
			aAdd(aUnitiliz,{GWB->GWB_CDUNIT,GWB->GWB_QTDE})
		EndIf
		GWB->( dbSkip() )
	EndDo

	aAdd(aDocCarg, {;
					GW1->GW1_EMISDC,; //Emitente do Documento
					GW1->GW1_SERDC ,; //Serie do Documento
					GW1->GW1_NRDC  ,; //Numero do Documento
					GW1->GW1_CDTPDC,; //Tipo do Documento
					GW1->GW1_CDREM ,; //Remetente do Documento
					GW1->GW1_CDDEST,; //Destinatario do Documento
					GW1->GW1_ENTEND,; //Endereco de Entrega
					GW1->GW1_ENTBAI,; //Bairro de entrega
					GW1->GW1_ENTNRC,; //Cidade de Entrega
					GW1->GW1_ENTCEP,; //CEP de Entrega
					GW1->GW1_NRREG ,; //Região de destino
					GW1->GW1_TPFRET,; //Tipo de Frete
					GW1->GW1_ICMSDC,; //ICMS?
					GW1->GW1_USO   ,; //Finalidade da mercadoria
					GW1->GW1_CARREG,; //Número do carregamento
					IIf(lApraut,FwFldGet('GWD_NROCO'),GWD->GWD_NROCO),; //Numero do Agrupador
					IIf(nQtdeUnit > 0, nQtdeUnit, GW1->GW1_QTVOL),; //Quantidade de Unitizadores ou qtde de volumes do documento de carga
					aUnitiliz,; //Codigo do Unitilizador + Quantidade do Unitilizador
					GW1->GW1_FILIAL; //Filial do Documento
					})
	
	aTrechos := XFBGWUDC(,GW1->GW1_FILIAL,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC)
	For nX := 1 To Len(aTrechos)
		If aTrechos[nX,6] == cCdTransp
			aTrechos[nX,6] := cCdPrest
		EndIf
		If Empty(cSeq) .OR. (!Empty(cSeq) .And. aTrechos[nX,5] == cSeq)
			aAdd(aTrchDoc,aClone(aTrechos[nX]))
		EndIf
	Next nX
	
	dbSelectArea("GW8")
	GW8->( dbSetOrder(1) )
	GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
	Do While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == GW1->GW1_FILIAL .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
		GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

		aAdd(aItDoc, { GW8->GW8_EMISDC,; // Emitente do Documento
						GW8->GW8_SERDC ,; // Serie do Documento
						GW8->GW8_NRDC  ,; // Numero do Documento
						GW8->GW8_CDTPDC,; // Tipo do Documento
						GW8->GW8_ITEM  ,; // Item
						GW8->GW8_CDCLFR,; // ClassIficacao de Frete
						GW8->GW8_TPITEM,; // ClassIficacao de Frete
						GW8->GW8_QTDE  ,; // Quantidade do Item
						GW8->GW8_PESOR ,; // Peso do Item
						GW8->GW8_PESOC ,; // Peso Cubado
						GW8->GW8_QTDALT,; // Quantidade/Peso Alternativo
						GW8->GW8_VALOR ,; // Valor do Item
						GW8->GW8_VOLUME,; // Volume ocupado (m3)
						GW8->GW8_TRIBP,;  // Frete tributado PIS
						GW8->GW8_VALLIQ,; // Valor Liquido
						GW8->GW8_FILIAL;  // Filial do Documento
						})

		GW8->( dbSkip() )
	EndDo
Return .T.

/* Campo GWD_PREST será habilitado somente se o tipo de ocorrência for de Serviço
	e estiver habilitado para permitir outro Prestador de Serviço */
Function GFE032PSER()
	Local lRet := .F.

	dbSelectArea('GU5')
	dbSetOrder(01)
	If dbSeek(xFilial('GU5')+M->GWD_CDTIPO)
			If GU5->GU5_TPCALC == "3" .And. GfeVerCmpo({"GU5_PRESTS"}) .And. GU5->GU5_PRESTS == "1"
				lRet := .T.
		 EndIf
	EndIf
Return lRet

Static Function GFE032TRAN(cNrCalc, cTransp, cCdTipo)
	// Quando o prestador de serviço for informado, o transportador do cálculo e dos movimentos contábeis serão alterados

	dbSelectArea("GWF")
	dbSetOrder(01)
	If dbSeek(xFilial("GWF")+cNrCalc)

		dbSelectArea("GWH")
		dbSetOrder(01)
		dbSeek(xFilial("GWH")+cNrCalc)
		Do While !Eof() .AND. GWH->GWH_FILIAL == xFilial("GWH") .and. GWH->GWH_NRCALC == cNrCalc

			dbSelectArea("GWM")
			dbSetOrder(02)
			If dbSeek(GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC)
				Do While !GWM->(Eof()) .And. GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC) == GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC
					If GWM->GWM_NRDOC == cNrCalc .And. GWM->GWM_TPDOC == '1'
						RecLock( "GWM", .F. )
							GWM->GWM_CDTRP := cTransp
						GWM->(MsUnlock())
					EndIf
					GWM->(dbskip())	
				EndDo
			EndIf
			dbSelectArea("GWH")
			dbSkip()
		EndDo

		dbSelectArea("GWA")
		dbSetOrder(03)
		If dbSeek(xFilial("GWA")+'1'+cNrCalc)
			Do While !GWA->(Eof()) .And. GWA->(GWA_FILIAL+GWA_TPDOC+GWA_NRDOC) == xFilial("GWA")+'1'+cNrCalc
				RecLock( "GWA", .F. )
					GWA->GWA_CDEMIT := cTransp
				GWA->(MsUnlock())
				GWA->(dbSkip())
			EndDo
		EndIf

		RecLock( "GWF", .F. )
			GWF->GWF_TRANSP := cTransp
		GWF->(MsUnlock())
	EndIf
Return .T.

Function GFEA32VCO(oModelGWL,lTodos,cNrOco,cCdTrp,cCdTipo,dDtOcor,cHrOcor,cOrigem)
	Local nX         := 0 //Loop
	Local nI         := 0
	Local nF         := 0
	Local cTpCalcOco := ""
	Local lCmpExist  := .F.
	Local cMsg       := ""
	Local aVldDtEmis := {}
	Local aAreaGWD   := GWD->(GetArea())
	Local lFuncaoVld := GFXFU12123("GFEVLDDTHR")
	Local s_GFEOCO   := SuperGetMv("MV_GFEOCO",.F.,"1")

	Default lTodos  := .F.
	Default cNrOco  := FwFldGet("GWD_NROCO")
	Default cCdTrp  := FwFldGet("GWD_CDTRP")
	Default cCdTipo := FwFldGet("GWD_CDTIPO")
	Default dDtOcor := FwFldGet("GWD_DTOCOR")
	Default cHrOcor := FwFldGet("GWD_HROCOR")
	Default cOrigem := FwFldGet("GWD_ORIGEM")

	nI := If(lTodos,1, oModelGWL:GetLine()) // Inicio
	nF := If(lTodos,oModelGWL:Length(), oModelGWL:GetLine()) // Fim

	dbSelectArea("GWD")
	GWD->( dbSetOrder(1) )

	dbSelectArea("GU5")
	GU5->( dbSetOrder(1) )

	dbSelectArea("GWL")
	GWL->( dbSetOrder(2) )

	dbSelectArea("GU3")
	GU3->( dbSetOrder(1) )
	lCmpExist := GfeVerCmpo({"GU3_OCORET"})

	If lFuncaoVld
		aValOcor := GFEVLDDTHR(cHrOcor, DtoS(dDtOcor),,,"da ocorrência" )
		If !aValOcor[1]
			GFEMsgErro(aValOcor[2])  
			Return .F.
		EndIf
	EndIf
	
	For nX := nI to nF
 		GW1->(dbSetOrder(01))
		If lFuncaoVld .And. !oModelGWL:IsDeleted(nX) .And.  GW1->(dbSeek(oModelGWL:GetValue('GWL_FILDC',nX) + oModelGWL:GetValue('GWL_TPDC',nX) + oModelGWL:GetValue('GWL_EMITDC',nX) + oModelGWL:GetValue('GWL_SERDC',nX) + oModelGWL:GetValue('GWL_NRDC',nX)))
			aVldDtEmis := GFEVLDDTHR("00:00", DToS(GW1->GW1_DTEMIS), cHrOcor, DtoS(dDtOcor), "de emissão do DC", "da ocorrência")
			If !aVldDtEmis[1]
				GFEMsgErro("Documento " + Alltrim(oModelGWL:GetValue('GWL_NRDC',nX)) + "/" + Alltrim(oModelGWL:GetValue('GWL_SERDC',nX)) + ": " + aVldDtEmis[2])  
				Return .F.
			EndIf
		EndIf
		If !oModelGWL:IsDeleted(nX) .And. GWL->( dbSeek(xFilial("GWL")+ oModelGWL:GetValue('GWL_NRDC',nX)+oModelGWL:GetValue('GWL_FILDC',nX)+ oModelGWL:GetValue('GWL_EMITDC',nX) + oModelGWL:GetValue('GWL_SERDC',nX) + oModelGWL:GetValue('GWL_TPDC',nX)) )
			Do While !GWL->( Eof() ) .And. GWL->GWL_FILIAL == xFilial("GWL") .AND. GWL->GWL_NRDC == oModelGWL:GetValue('GWL_NRDC',nX);
												.AND. GWL->GWL_FILDC == oModelGWL:GetValue('GWL_FILDC',nX) .AND. GWL->GWL_EMITDC == oModelGWL:GetValue('GWL_EMITDC',nX);
												.AND. GWL->GWL_SERDC == oModelGWL:GetValue('GWL_SERDC',nX) .AND. GWL->GWL_TPDC == oModelGWL:GetValue('GWL_TPDC',nX)
				
				If GWL->GWL_NROCO != cNrOco
					If GWD->( dbSeek(xFilial("GWD") + GWL->GWL_NROCO) ) .And. cCdTrp == GWD->GWD_CDTRP
						If GWD->GWD_SIT <> "3"
							If GU5->( dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO) )
								cTpCalcOco := GU5->GU5_TPCALC
								If GU5->( dbSeek(xFilial("GU5") + cCdTipo) )
									If GU5->GU5_TPCALC == "2" .And. cTpCalcOco == "2"
										GFEMsgErro("Documento " + GWL->GWL_NRDC + " relacionado a outra ocorrencia de devolução : " + GWD->GWD_NROCO)								
										Return .F.
									Else
										If lCmpExist //Novo campo existe
											GU3->(dbSeek(xFilial("GU3")+GWD->GWD_CDTRP))
											If GU3->GU3_OCORET == "1" .Or. Empty(GU3->GU3_OCORET)
												cTpValid := s_GFEOCO
												If Empty(cTpValid)
													cTpValid := "1" // Não permite ocorrência com data retroativa
												EndIf
											Else
												Do Case
													Case GU3->GU3_OCORET == "2"
														cTpValid := "1" // Não permite ocorrência com data retroativa
													Case GU3->GU3_OCORET == "3"
														cTpValid := "2" // Permite ocorrência com data retroativa para ocorrência EDI
													Case GU3->GU3_OCORET == "4"
														cTpValid := "3" // Sempre Permite
													OtherWise
														cTpValid := "1"
												EndCase
											EndIf
											If cTpValid == "3"
												GWL->(DbSkip())
												Loop
											Else
												If cTpValid == "1" .Or. (cTpValid == "2" .And. (cOrigem == "2" .Or. Empty(cOrigem)))
													If (GWD->GWD_DTOCOR > dDtOcor) .Or. (GWD->GWD_DTOCOR == dDtOcor .and. AllTrim(GWD->GWD_HROCOR) > AllTrim(cHrOcor))
														cMsg := "Conforme " + If(GU3->GU3_OCORET == "1" .Or. Empty(GU3->GU3_OCORET),"parâmetro do módulo","transportador") + ", não é permitida a inserção de ocorrência com data/hora anterior à última para o documento de carga " + AllTrim(GWL->GWL_NRDC)  + ". Ocorrência " + GWD->GWD_NROCO + "."
													EndIf
												EndIf
											EndIf
										Else
											If GWD->GWD_DTOCOR > dDtOcor
												GFEMsgErro(STR0041)  //"Data de ocorrencia invalida"
												RestArea(aAreaGWD)
												Return .F.
											ElseIf GWD->GWD_DTOCOR == dDtOcor .and. AllTrim(GWD->GWD_HROCOR) > AllTrim(cHrOcor)
												GFEMsgErro(STR0042)  //"Hora de ocorrencia invalida"
												RestArea(aAreaGWD)
												Return .F.
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				GWL->(DbSkip())
			EndDo
		EndIf
	Next nX
	If !Empty(cMsg)
		GFEMsgErro(cMsg)
	EndIf
	RestArea(aAreaGWD)
Return Empty(cMsg)

Function GFE32VLRAT(cFil,cNumOcor,lApraut,oModel,cNumCalc)
	Local nValorRet := 0
	Local cQuery    := ""
	Local cAlGen    := GetNextAlias()
	Local oModelGWD := Nil
	Local oModelGWL := Nil
	Local cTrp      := ""
	Local cFils     := ""
	Local cNrDcs    := ""
	Local cEmisDcs  := ""
	Local cSerDcs   := ""
	Local cCdTpDcs  := ""
	Local aTemp     := {}
	Local cCampo    := ""
	Local cCriRat   := SuperGetMv("MV_CRIRAT",.F.,"1")
	Local aCampo    := {"GWM_VLFRET","GWM_VLFRE1","GWM_VLFRE3","GWM_VLFRE2"}
	Local nVlTot    := 0
	Local nVlRee    := 0
	Local cTipoCalc := TipoCalc()
	Local cListEmit := ""
	Local aAreaGWD	:= {}
	Local oQry		

	If Empty(cCriRat) .Or. !(cCriRat $ "1234")
		cCriRat := "1"
	EndIf
		
	cCampo := aCampo[Val(cCriRat)]

	If lApraut
		oModelGWD := oModel:GetModel("GFEA032_GWD")
		oModelGWL := oModel:GetModel("GFEA032_GWL")
		cTrp      := oModelGWD:GetValue("GWD_CDTRP")
		cListEmit := GFEGetEmRz(cTrp)
			
		aTemp := MDGrdtoArr(oModelGWL,"GWL_NRDC,GWL_FILDC,GWL_EMITDC,GWL_SERDC,GWL_TPDC")
			
		cNrDcs  := MDArrSqlIn(aTemp,"GWL_NRDC")
		cFils   := MDArrSqlIn(aTemp,"GWL_FILDC")
		cEmisDcs:= MDArrSqlIn(aTemp,"GWL_EMITDC")
		cSerDcs := MDArrSqlIn(aTemp,"GWL_SERDC")
		cCdTpDcs:= MDArrSqlIn(aTemp,"GWL_TPDC")
			
		cQuery := "SELECT Sum(?) VALOR" 
		cQuery += " FROM " + RetSqlName("GWM") + " GWM"
		cQuery += " INNER JOIN " + RetSqlName("GWF") + " GWF"
		cQuery += " ON GWF_FILIAL = GWM_FILIAL"
		cQuery += " AND GWM_NRDOC = GWF_NRCALC"
		cQuery += " AND GWF_TPCALC IN ('1','6')"
		cQuery += " AND GWM_TPDOC = '1'"
		cQuery += " AND GWF_TRANSP = GWM_CDTRP"
		cQuery += " AND GWF.D_E_L_E_T_ = ''"
		cQuery += " AND GWM.D_E_L_E_T_ = ''"
		cQuery += " WHERE GWF_TRANSP IN (?)"
		cQuery += " AND GWM_FILIAL IN (?)"
		cQuery += " AND GWM_NRDC   IN (?)"
		cQuery += " AND GWM_EMISDC IN (?)"
		cQuery += " AND GWM_SERDC  IN (?)"
		cQuery += " AND GWM_CDTPDC IN (?)"
		cQuery += " AND GWF_NRCALC = ?"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetUnsafe(1,cCampo)
		oQry:SetIn(2,{cListEmit}) 
		oQry:SetIn(3,{cFils})
		oQry:SetIn(4,{cNrDcs})
		oQry:SetIn(5,{cEmisDcs}) 
		oQry:SetIn(6,{cSerDcs})
		oQry:SetIn(7,{cCdTpDcs})
		oQry:SetString(8,cNumCalc)
		cAlGen := oQry:OpenAlias()
	Else
		aAreaGWD := GWD->(GetArea())
		GWD->(dbSetOrder(1))
		If GWD->(DbSeek(xFilial("GWD") + cNumOcor))
			cListEmit := GFEGetEmRz(GWD->GWD_CDTRP)
		EndIf
		RestArea(aAreaGWD)
		
		cQuery := "SELECT Sum(?) VALOR" 
		cQuery += " FROM " + RetSqlName("GWM") + " GWM"
		cQuery += " INNER JOIN " + RetSqlName("GWL") + " GWL"
		cQuery += " ON GWL_FILIAL = ?"
		cQuery += " AND GWM_NRDC = GWL_NRDC"
		cQuery += " AND GWM_FILIAL = GWL_FILDC"
		cQuery += " AND GWM_EMISDC = GWL_EMITDC"
		cQuery += " AND GWM_SERDC = GWL_SERDC"
		cQuery += " AND GWM_CDTPDC = GWL_TPDC"
		cQuery += " AND GWM.D_E_L_E_T_ = ''"
		cQuery += " AND GWL.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GWD") + " GWD"
		cQuery += " ON GWD_FILIAL = GWL_FILIAL"
		cQuery += " AND GWD_NROCO = GWL_NROCO"
		cQuery += " AND GWM_CDTRP IN (?)"
		cQuery += " AND GWD.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GWF") + " GWF"
		cQuery += " ON GWF_FILIAL = GWM_FILIAL"
		cQuery += " AND GWM_NRDOC = GWF_NRCALC"
		cQuery += " AND GWF_TPCALC IN ('1','6')"
		cQuery += " AND GWM_TPDOC = '1'"
		cQuery += " AND GWF.D_E_L_E_T_ = ''"
		cQuery += " WHERE GWD_NROCO	= ?"
		cQuery += " AND GWF_NRCALC = ?"
		
		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetUnsafe(1,cCampo) 
		oQry:SetString(2,cFil)
		oQry:SetIn(3,{cListEmit})
		oQry:SetString(4,cNumOcor)
		oQry:SetString(5,cNumCalc) 
		cAlGen := oQry:OpenAlias()
	EndIf
		
	nValorRet := (cAlGen)->VALOR
		
	(cAlGen)->(dbCloseArea())
	
	if GFXCP12117("GUY_REENT")
		cQuery := " SELECT GWI.GWI_NRCALC, GWI_CDCOMP, GWI_VLFRET, GUY.GUY_REENT, GUY.GUY_DEVOL"
		cQuery += " FROM " + RetSqlName("GWI") + " GWI "
		cQuery += " INNER JOIN " + RetSqlName("GWG") + " GWG" 
		cQuery += " ON (GWG.GWG_FILIAL = GWI.GWI_FILIAL"
		cQuery += " AND GWG.GWG_NRCALC = GWI.GWI_NRCALC"
		cQuery += " AND GWG.D_E_L_E_T_ = ' ')"
		cQuery += " INNER JOIN " + RetSqlName("GUY") + " GUY" 
		cQuery += " ON (GUY.GUY_FILIAL = '" + xFilial("GUY") + "'" 
		cQuery += " AND GUY.GUY_CDCOMP = GWI.GWI_CDCOMP"
		cQuery += " AND GUY.D_E_L_E_T_ = ''"
		cQuery += " AND GUY.GUY_CDEMIT = GWG.GWG_CDEMIT" 
		cQuery += " AND GWG.GWG_NRTAB = GUY.GUY_NRTAB"
		cQuery += " AND GWG.GWG_NRNEG = GUY.GUY_NRNEG)"
		cQuery += " WHERE GWI.GWI_TOTFRE = ?"
		cQuery += " AND GWI.GWI_NRCALC = ?"
		cQuery += " AND GWI.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,'1')
		oQry:SetString(2,cNumCalc)
		cAlGen := oQry:OpenAlias()	
			
		nVlTot := 0
		nVlRee := 0
			
		If cTipoCalc == '4'
			GFELog032:Add("Componentes da Base de Calculo de Reentrega")
		Else 
			GFELog032:Add("Componentes da Base de Calculo de Devolução")
		EndIf 

		Do While !(cAlGen)->(EOF())
		
			nVlTot += (cAlGen)->GWI_VLFRET
			If (cTipoCalc == '4' .And. (cAlGen)->GUY_REENT == '1' .Or. Empty((cAlGen)->GUY_REENT)) .Or.; 
			   (cTipoCalc == '5' .And. (cAlGen)->GUY_DEVOL == '1' .Or. Empty((cAlGen)->GUY_DEVOL))
					
				nVlRee += (cAlGen)->GWI_VLFRET
				GFELog032:Add(" > " + (cAlGen)->GWI_CDCOMP  + cValToChar((cAlGen)->GWI_VLFRET))
			Else
				If cTipoCalc == '4'
					GFELog032:Add(" > Componente " + Alltrim((cAlGen)->GWI_CDCOMP)  + " não configurado para fazer parte da base de Reentrega.")
				ElseIf cTipoCalc == '5'
					GFELog032:Add(" > Componente " + Alltrim((cAlGen)->GWI_CDCOMP)  + " não configurado para fazer parte da base de Devolução.")
				EndIf
			EndIf
					
			(cAlGen)->(dbSkip())
		EndDo
		(cAlGen)->(dbCloseArea())
			
		// QUANDO OS VALORES SÃO DIFERENTES, DEVE CALCULAR O PERCENTUAL 
		If GFETratDec( nVlTot,0,.T.) != GFETratDec( nVlRee,0,.T.)
			nValorRet := nValorRet * (nVlRee / nVlTot)
		EndIf
	EndIf

Return nValorRet

Function MDGrdtoArr(oModel,cField,cBlock)
	Local aArray  := {}
	Local nX      := 0
	Local nY      := 0
	Local nCampo  := 0
	Local uValue  := Nil
	Local nLine   := 0
	Local aFlds   := StrToKarr(cField,",")

	Default cBlock := ""

	If Type("oModel:Length()") == "UI"
		nLine := oModel:nLine
		For nX := 1 to oModel:Length()
			For nY := 1 to Len(aFlds)
				If !oModel:IsDeleted(nX)
					If Empty(cBlock)
						uValue :=  oModel:GetValue(aFlds[nY],nX)
					Else
						oModel:GoLine(nX)
						uValue := &(cBlock)
					EndIf
					nCampo := aScan(aArray,{|x|x[1] == aFlds[nY]})
					If nCampo == 0
						aAdd(aArray,{aFlds[nY],{}})
						nCampo := Len(aArray)
					EndIf	
					If aScan(aArray[nCampo][2],{|x|x == uValue}) == 0
						aAdd(aArray[nCampo][2],uValue)
					EndIf
				EndIf
			Next nY
		Next nX
		oModel:GoLine(nLine)
	EndIf
Return aArray

Function MDArrSqlIn(aArray,cField)
	Local cRet      := ""
	Local nX        := 0
	Local nY        := 0
	Local aValores  := {}

	nX := aScan(aArray,{|x|x[1] == cField})
	If nX != 0
		aValores := aArray[nX][2]
		For nY := 1 To Len(aValores)
			If nY != 1
				cRet += ","
			EndIf
			cRet += "'" + aValores[nY] + "'"
		Next nY
	EndIf
	If Empty(cRet)
		cRet := "''"
	EndIf
Return cRet

// Classe Mock da GFELog. Usado quando ocorrer execução sem instancia do log032
CLASS GFELogMock
		METHOD New() CONSTRUCTOR
		METHOD Add()
		METHOD NewLine()
		METHOD Save()
	ENDCLASS

	METHOD New() Class GFELogMock
	Return Self

	METHOD Add() Class GFELogMock
	Return

	METHOD NewLine() Class GFELogMock
	Return

	METHOD Save() Class GFELogMock
Return

Function GFE32DCCLC(nDocCargaOut,lApraut,oModel,cTpCalc,cNumOcor,lSimular)
	Local oModelGWD := Nil
	Local oModelGWL := Nil
	Local nLineaUX  := 0
	Local nI        := 0
	Local nF        := 0
	Local aDocCalc  := {}
	Local nItemAdd  := 1
	Local cSeq      := ""
	
	Default nDocCargaOut := 0

	If Type("GFELog032") != "O"
		GFELog032 := GFELogMock():New()
	EndIf

		GFELog032:Add(Replicate("-",15) + "Documentos" + Replicate("-",15))
		If lApraut
			oModelGWD :=  oModel:GetModel("GFEA032_GWD")
			oModelGWL :=  oModel:GetModel("GFEA032_GWL")
			nLineaUX := oModelGWL:nLine
			nF := oModelGWL:Length()
			For nI := 1 To nF
				oModelGWL:GoLine( nI )
				If !oModelGWL:IsDeleted()
					If nItemAdd != 1
						GFELog032:NewLine()
						GFELog032:Add(Replicate("-",40))
						GFELog032:NewLine()
					EndIf
					GFELog032:Add("Número....:" + AllTrim(FwFldGet('GWL_NRDC')) + " | Série.....:" + FwFldGet('GWL_SERDC') )
					GFELog032:Add("Emissor...:" + AllTrim(FwFldGet('GWL_EMITDC')) + " | Tipo......:" + FwFldGet('GWL_TPDC') )
					nItemAdd++
					nDocCargaOut++
					
					cSeq := FwFldGet('GWL_SEQ')
					ListaCalculosEPreparaServico( FwFldGet('GWL_FILDC'),;
													FwFldGet('GWL_TPDC'),;
													FwFldGet('GWL_EMITDC'),;
													FwFldGet('GWL_SERDC'),;
													FwFldGet('GWL_NRDC'),;
													oModelGWD:GetValue("GWD_CDTRP"),;
													cSeq,;
													cTpCalc,;
													aDocCalc,;
													lApraut,;
													lSimular)
					
				EndIf
			Next
			oModelGWL:GoLine( nLineaUX )
		Else
			dbSelectArea("GWL")
			dbSetOrder(1)
			dbSeek(xFilial("GWD") + cNumOcor)
			Do While !Eof() .And. GWL->GWL_FILIAL == xFilial("GWD") .And. GWL->GWL_NROCO  == cNumOcor
				If nItemAdd != 1
					GFELog032:Add(Replicate("-",40))
				EndIf
				GFELog032:Add("Número....:" + AllTrim(GWL->GWL_NRDC) + " | Série.....:" + GWL->GWL_SERDC )
				GFELog032:Add("Emissor...:" + AllTrim(GWL->GWL_EMITDC) + " | Tipo......:" + GWL->GWL_TPDC )
				GFELog032:NewLine()
				nItemAdd++
				nDocCargaOut++
				
				cSeq := IIf(_lGWL_SEQ,GWL->GWL_SEQ,GWU->GWU_SEQ)
				ListaCalculosEPreparaServico( GWL->GWL_FILDC,;
												GWL->GWL_TPDC,;
												GWL->GWL_EMITDC,;
												GWL->GWL_SERDC,;
												GWL->GWL_NRDC,;
												GWD->GWD_CDTRP,;
												cSeq,;
												cTpCalc,;
												aDocCalc,;
												lApraut,;
												lSimular)

				dbSelectArea("GWL")
				dbSkip()
			EndDo
		EndIf
Return aDocCalc

Static Function ListaCalculosEPreparaServico(cFilDc,cTpDc,cEmtDc,cSerDc,cNrDc,cCdTrp,cSeq,cTpCalc,aDocCalc,lApraut, lSimular)
	Local cAliasQry := Nil
	Local nPos     	:= 0
	Local cListEmit	:= GFEGetEmRz(cCdTrp)
	Local cQuery	:= ""
	Local oQry

	Default cFilDc  := xFilial("GW1")
	Default cTpCalc := ""
	
	cQuery := "SELECT GWF.GWF_NRCALC "
	cQuery += " FROM " + RetSqlName("GWH") + " GWH "
	cQuery += " INNER JOIN " + RetSqlName("GWU") + " GWU "
	cQuery += " ON GWU.GWU_FILIAL = GWH.GWH_FILIAL"
	cQuery += " AND GWU.GWU_CDTPDC = GWH.GWH_CDTPDC"
	cQuery += " AND GWU.GWU_EMISDC = GWH.GWH_EMISDC"
	cQuery += " AND GWU.GWU_SERDC = GWH.GWH_SERDC"
	cQuery += " AND GWU.GWU_NRDC = GWH.GWH_NRDC"
	cQuery += " AND GWU.GWU_CDTRP IN (?)"
	cQuery += " AND GWU.D_E_L_E_T_ = ''"
	cQuery += " INNER JOIN " + RetSqlName("GWF") + " GWF "
	cQuery += " ON GWF.GWF_FILIAL = GWH.GWH_FILIAL"
	cQuery += " AND GWF.GWF_NRCALC = GWH.GWH_NRCALC"
	cQuery += " AND GWF.GWF_TPCALC IN ('1','6')"
	cQuery += " AND GWF.GWF_TRANSP = GWU.GWU_CDTRP"
	cQuery += " AND GWF.GWF_SEQTRE = ?" 
	cQuery += " AND GWF.D_E_L_E_T_ = ''"
	cQuery += " WHERE GWH.GWH_FILIAL = ?"
	cQuery += " AND GWH.GWH_CDTPDC = ?"
	cQuery += " AND GWH.GWH_EMISDC = ?"
	cQuery += " AND GWH.GWH_SERDC = ?"
	cQuery += " AND GWH.GWH_NRDC = ?"
	cQuery += " AND GWH.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetIn(1,{cListEmit})
	oQry:SetString(2,cSeq)
	oQry:SetString(3,cFilDc)
	oQry:SetString(4,cTpDc)
	oQry:SetString(5,cEmtDc)
	oQry:SetString(6,cSerDc) 
	oQry:SetString(7,cNrDc)
	cAliasQry := oQry:OpenAlias()

	Do While (cAliasQry)->(!Eof())
		nPos := aScan(aDocCalc, {|x| x == (cAliasQry)->GWF_NRCALC})
		If nPos == 0
			aAdd(aDocCalc,(cAliasQry)->GWF_NRCALC) //Nr Calc
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	// Arrays utilizados somente para o cálculo de serviço realizados quando o parâmetro estiver marcado
	If cTpCalc == "7"
	
		Private cCdTransp
		Private cCdPrest

		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek(cFilDc + cTpDc + cEmtDc + cSerDc + cNrDc)
			//1=Digitado;2=Bloqueado;3=Liberado;4=Embarcado;5=Entregue;6=Retornado;7=Cancelado;8=Sinistrado                                   
			If GW1->GW1_SIT $ '456' .Or. lSimular
				criaTabTemp(lApraut,cSeq)
			Else
				criaGrpClc(lApraut)
			EndIf
			
		Endif
	Endif
Return aDocCalc

Static Function LgInfo(cCampo, lModel, oModel)
	Local cTab := SubStr(cCampo,1,3)

	Default lModel := .F.

	If lModel == .T.
		Return cValToChar(oModel:GetModel("GFEA032_GWD"):GetValue(cCampo))
	Else
		Return cValToChar(&(cTab + '->' + cCampo))
	EndIf
Return Nil

/*/{Protheus.doc} GFEA032PTO
	Retorna o numero de uma ocorrência pendente para o ponto de controle

	@author siegklenes.beulke
	@since 08/09/2014
	@version 1.0
	@param cFil, Char, Filial da ocorrência para comparação
	@param cNrOco, Char, Número da ocorrência para comparação
	@param cNrMov, Char, Movimentação
	@param cCdPtCt, Char, Ponto de controle
	@example If !Empty(GFEA032PTO(,,"00000001","ENTRADA       "))
				//ponto já tem ocorrencia pendente
				endif
/*/
Function GFEA032PTO(cNrOco,cNrMov,cCdPtCt)
	Local aAreaGWD
	Local cFil := xFilial("GWD")
	Default cNrOco := ""

	If !Empty(cNrMov) .And. !Empty(cCdPtCt)
		aAreaGWD := GWD->(GetArea())
		GWD->(dbSetOrder(3))
		GWD->(dbSeek(cFil+cNrMov+cCdPtCt))

		Do While !GWD->(Eof()) .And. GWD->GWD_FILIAL == cFil .And. GWD->GWD_NRMOV == cNrMov .And. GWD->GWD_CDPTCT == cCdPtCt
			If GWD->GWD_NROCO != cNrOco .And. GWD->GWD_SIT == "1"
				Return GWD->GWD_NROCO
			ElseIf GWD->GWD_NROCO != cNrOco .And. IsInCallStack("GFEA519BRE")
				Return GWD->GWD_NROCO
			EndIf
			GWD->(dbSkip())
		EndDo
		RestArea(aAreaGWD)
	EndIf
Return Nil

Function GFEA032SIM()
	Local lSimula := PodeSimularOcorrencia()
	Local cTipoCalc
	
	If lSimula
		cTipoCalc := TipoCalc()
		If !Empty(cTipoCalc)
			//(cNumOcor,cTpCalc,oModel,lApraut,lSimular)
			GFEA032CA(GWD->GWD_NROCO, cTipoCalc,/*oModel*/,/*lApraut*/,lSimula)
		EndIf
	EndIf
Return Nil

Static Function PodeSimularOcorrencia(lMsg)
	Local lRet      := .T.
	Local cAliasGU5 := Nil
	Local cQuery	:= ""
	Local oQry

	Default lMsg := .T.
	
	cQuery := "SELECT GU5.GU5_EVENTO,GU5.GU5_TPCALC "
	cQuery += " FROM " + RetSqlName("GU5") + " GU5"
	cQuery += " WHERE GU5.GU5_FILIAL = ?"
	cQuery += " AND GU5.GU5_CDTIPO = ?"
	cQuery += " AND GU5.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,xFilial("GU5"))
	oQry:SetString(2,GWD->GWD_CDTIPO) 
	cAliasGU5 := oQry:OpenAlias()

	If (cAliasGU5)->(!Eof())
		If !((cAliasGU5)->GU5_EVENTO == "1")
			If lMsg
				Help(,,'HELP',,"Só é possível simular valores para ocorrências do tipo 'Cálculo Adicional'.",1,0)
			EndIf
			lRet := .F.
		EndIf
		If !((cAliasGU5)->GU5_TPCALC  $ "1|2|3")
			If lMsg
				Help(,,'HELP',,"Só é possível simular valores para ocorrências de cálculos adicionais de Reentrega,Retorno ou Serviço.",1,0)
			EndIf
			lRet := .F.
		EndIf
	EndIf
	(cAliasGU5)->(dbCloseArea())

	If lRet
		cQuery := "SELECT 1 "
		cQuery += " FROM " + RetSqlName("GWL") + " GWL"
		cQuery += " WHERE GWL.GWL_FILIAL = ?"
		cQuery += " AND GWL.GWL_NROCO = ?"
		cQuery += " AND GWL.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,xFilial("GWL"))
		oQry:SetString(2,GWD->GWD_NROCO) 
		cAliasGWL := oQry:OpenAlias()
		
		If (cAliasGWL)->(Eof())
			If lMsg
				Help(,,'HELP',,"Não há documentos de carga associados à ocorrência.",1,0)
			EndIf
			lRet := .F.
		EndIf
		(cAliasGWL)->(dbCloseArea())
	EndIf
Return lRet

Static Function TipoCalc(lMsg)
	Local cTipoCalc := ""

	Default lMsg := .T.

	If GU5->GU5_TPCALC == "1" //reeentrega
		cTipoCalc := "4"

	ElseIf GU5->GU5_TPCALC == "2" // devolução
		cTipoCalc := "5"

	ElseIf GU5->GU5_TPCALC == "3" //serviço
		cTipoCalc := "7"
	Else
		If lMsg
			Help(,,'HELP',,'Tipo Cálculo não definido',1,0)
		EndIf
	EndIf
Return cTipoCalc

//Função para padronizar o cancelamento da aprovação/reprovação da ocorrencia
Static Function CancAprRpr(cSit)
	Reclock("GWD",.F.)
		GWD->GWD_SIT    := "1"
		GWD->GWD_DSSOLU := If( (cSit == "2"),"Aprovação","Reprovação") + " cancelada."
		GWD->GWD_DTBAI  := dDataBase
		GWD->GWD_HRBAI  := SubStr(Time(),1,5)
		GWD->GWD_USUBAI := cUserName
	GWD->(MsUnlock())
	If cSit == "2"
		GF32EVEOCO("CANC/APROVACAO",GWD->GWD_FILIAL,GWD->GWD_NROCO) // Estava aprovada.
	EndIf
Return Nil

//Verifica se existe outras ocorrencias de entrega para os documentos da ocorrencia
Static Function TemOcorEntApr(cNrOco)
	Local cAliasGWD := Nil
	Local lRet      := .F.

	cAliasGWD := GetNextAlias()
	BeginSql Alias cAliasGWD
		SELECT GWD.GWD_NROCO
		FROM %Table:GWD% GWD
		INNER JOIN %Table:GWL% GWLOUT
		ON GWLOUT.GWL_FILIAL = GWD.GWD_FILIAL
		AND GWLOUT.GWL_NROCO = GWD.GWD_NROCO
		AND EXISTS (SELECT 1 
					FROM %Table:GWL% GWLATU
					WHERE GWLATU.GWL_FILDC = GWLOUT.GWL_FILDC
					AND GWLATU.GWL_EMITDC = GWLOUT.GWL_EMITDC
					AND GWLATU.GWL_SERDC = GWLOUT.GWL_SERDC
					AND GWLATU.GWL_NRDC = GWLOUT.GWL_NRDC
					AND GWLATU.GWL_TPDC = GWLOUT.GWL_TPDC
					AND GWLATU.GWL_NROCO <> GWLOUT.GWL_NROCO
					AND GWLATU.GWL_NROCO = %Exp:cNrOco%
					AND GWLATU.%NotDel% )
		AND GWLOUT.%NotDel%
		INNER JOIN %Table:GU5% GU5
		ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO
		AND GU5.GU5_EVENTO = '4'
		AND GU5.GU5_SIT = '1'
		AND GU5.%NotDel%
		WHERE GWD.GWD_NROCO <> %Exp:cNrOco%
		AND GWD.GWD_SIT = '2'
		AND GWD.%NotDel%
	EndSql
	If (cAliasGWD)->(!Eof()) .And. !Empty((cAliasGWD)->GWD_NROCO)
		lRet := .T.
	EndIf
	(cAliasGWD)->(dbCloseArea())
Return lRet

Static Function CancRegEntr(lMantemTrecho,lDevTot)
	Local s_GFEA0515 := ExistBlock("GFEA0515")
	Local cAliasDc   := DocOcorrencia()
	Local cAliasGWU  := Nil
	Local cAliasQry  := Nil
	Local nTrecho    := 0
	Local nTrechoEnt := 0
	Local nTrechoPg  := 0
	Local nTrePgEnt  := 0
	Local cRecPrz	 := SuperGetMV("MV_RECPRZ",.F.,"0")
	Local dDtAnt	 := Date()
	Local cHrAnt	 := ""
	Local nRecBkp	 := 0
	Local cQuery	 := ""
	Local oQry

	Default lMantemTrecho := .F.
	Default lDevTot       := .F.
	
	Do While (cAliasDc)->(!Eof())
		If !((cAliasDc)->GW1_SIT == "6" .And. !lDevTot)
			GW1->(dbGoTo((cAliasDc)->RECNOGW1))
			
			nTrecho    := 0
			nTrechoEnt := 0
			nTrechoPg  := 0
			nTrePgEnt  := 0

			// Busca os trechos do documento atendidos pelo transportador na ocorrência. 
			cQuery := "SELECT GWU.R_E_C_N_O_ RECNOGWU "
			cQuery += " FROM " + RetSqlName("GWU") + " GWU"
			cQuery += " INNER JOIN " + RetSqlName("GU3") + " GU3"
			cQuery += " ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "'"
			cQuery += " AND GU3.GU3_CDEMIT = ?" 
			cQuery += " AND GU3.D_E_L_E_T_ =''"
			cQuery += " INNER JOIN " + RetSqlName("GWL") + " GWL"
			cQuery += " ON GWL.GWL_FILIAL = ?" 
			cQuery += " AND GWL.GWL_NROCO = ?"
			cQuery += " AND GWL.GWL_FILDC = GWU.GWU_FILIAL "
			cQuery += " AND GWL.GWL_EMITDC = GWU.GWU_EMISDC"
			cQuery += " AND GWL.GWL_SERDC = GWU.GWU_SERDC"
			cQuery += " AND GWL.GWL_NRDC = GWU.GWU_NRDC"
			cQuery += " AND GWL.GWL_TPDC = GWU.GWU_CDTPDC"
			cQuery += " AND GWL.GWL_SEQ = GWU.GWU_SEQ"
			cQuery += " AND GWL.D_E_L_E_T_ = ''"
			cQuery += " WHERE GWU.GWU_FILIAL = ?"
			cQuery += " AND GWU.GWU_CDTPDC = ?"
			cQuery += " AND GWU.GWU_EMISDC = ?"
			cQuery += " AND GWU.GWU_SERDC = ?"
			cQuery += " AND GWU.GWU_NRDC = ?"
			cQuery += " AND (GWU.GWU_CDTRP = ? OR GWU.GWU_CDTRP = GU3.GU3_CDEMFT)"
			cQuery += " AND GWU.GWU_DTENT <> ' '"
			cQuery += " AND GWU.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY GWU.GWU_SEQ DESC"			

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery) 
			oQry:SetString(1,GWD->GWD_CDTRP)  
			oQry:SetString(2,GWD->GWD_FILIAL) 
			oQry:SetString(3,GWD->GWD_NROCO) 
			oQry:SetNumeric(4,xFilial("GWU"))  
			oQry:SetString(5,GW1->GW1_CDTPDC)
			oQry:SetString(6,GW1->GW1_EMISDC)
			oQry:SetString(7,GW1->GW1_SERDC)  
			oQry:SetString(8,GW1->GW1_NRDC)    
			oQry:SetString(9,GWD->GWD_CDTRP)  
			cAliasGWU := oQry:OpenAlias()

			If (cAliasGWU)->(!Eof())
				If !lMantemTrecho
					GWU->(DbGoTo((cAliasGWU)->RECNOGWU))

					dDtAnt := GWU->GWU_DTENT
					cHrAnt := GWU->GWU_HRENT

					RecLock ("GWU", .F.)
						GWU->GWU_DTENT := CToD(" / / ")
						GWU->GWU_HRENT := ""
					GWU->(MsUnlock())

					nRecBkp := GWU->(Recno())

					If cRecPrz == "1"
						If GWU->GWU_DTPENT < dDtAnt .Or. (GWU->GWU_DTPENT == dDtAnt .And. GWU->GWU_HRPENT < cHrAnt)
							RecPrzTrec(GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
						ENDIF
					ElseIf cRecPrz == "2"
						RecPrzTrec(GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
					EndIf

					GWU->(dbGoTo(nRecBkp))

					//Ponto de Entrada Vicunha
					If s_GFEA0515
						ExecBlock( "GFEA0515",.F.,.F.,{2})
					EndIf
				EndIf
	
				cQuery := "SELECT GWU.GWU_DTENT,GWU.GWU_PAGAR "
				cQuery += " FROM " + RetSqlName("GWU") + " GWU"
				cQuery += " WHERE GWU.GWU_FILIAL = ?"
				cQuery += " AND GWU.GWU_CDTPDC = ?"
				cQuery += " AND GWU.GWU_EMISDC = ?"
				cQuery += " AND GWU.GWU_SERDC = ?"
				cQuery += " AND GWU.GWU_NRDC = ?"
				cQuery += " AND GWU.D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery) 
				oQry:SetString(1,GW1->GW1_FILIAL)
				oQry:SetString(2,GW1->GW1_CDTPDC) 
				oQry:SetString(3,GW1->GW1_EMISDC)
				oQry:SetString(4,GW1->GW1_SERDC) 
				oQry:SetString(5,GW1->GW1_NRDC) 
				cAliasQry := oQry:OpenAlias()	

				Do While (cAliasQry)->(!Eof())
					nTrecho++
					// Soma a quantidade total de trechos e trechos entregues
					If !Empty((cAliasQry)->GWU_DTENT)
						nTrechoEnt++
					EndIf
					
					// Soma a quantidade total de trechos pagos e trechos pagos entregues
					If (cAliasQry)->GWU_PAGAR == '1'
						nTrechoPg++
						If !Empty((cAliasQry)->GWU_DTENT)
							nTrePgEnt++
						EndIf
					EndIf
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())

				// Quando houverem trechos pagos, o sistema deve analisar somente eles.
				// Do contrário, analisa todos os trechos.
				If (nTrechoPg > 0 .And. nTrechoPg != nTrePgEnt) .Or. (nTrechoPg == 0 .And. nTrecho != nTrechoEnt)
					cDcSit := "4"
				Else
					cDcSit := GW1->GW1_SIT
				EndIf
				
				If lMantemTrecho .And. cDcSit != "4"
					cDcSit := "5"
				EndIf
				
				If cDcSit != GW1->GW1_SIT
					RecLock ("GW1", .F.)
						GW1->GW1_SIT := cDcSit
					GW1->(MsUnlock())
				EndIf
				
				If cDcSit == "4"
					GWN->( dbSetOrder(1) )
					If GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )
						If GWN->GWN_SIT == "4"
							RecLock("GWN", .F.)
								GWN->GWN_SIT := "3"
							GWN->(MSUnlock())
						EndIf
					EndIf
				EndIf
				GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.			
			EndIf
			(cAliasGWU)->(dbCloseArea())
		EndIf
		(cAliasDc)->(dbSkip())
	EndDo
	(cAliasDc)->(dbCloseArea())
Return

//Cancelamento da aprovação de um ocorrência
Function GFEA032CAN(lShow)
	Local lCancelado := .F.
	Local lContinua  := .T.
	Local cMsg       := ""
	Local aAreaGWF   := GWF->(GetArea())
	Local aAreaGW3   := GW3->(GetArea())
	Local cChave     := ""
	Local aCalcRel   := {}
	Local aDfRel     := {}
	Local nX         := 1
	Local cFilBkp    := cFilAnt
	Local cAliasQry  := Nil
	Local lChvExt    := If(Empty(GWD->GWD_CHVEXT), .T., .F.)
	Local s_GFEA032C := ExistBlock("GFEA032C")
	Local s_GFEA032H := ExistBlock("GFEA032H")
	Local s_GFEIND   := SuperGetMV('MV_GFEIND',,'0')
	Local lOkProc    := .F.
	Local cQuery	 := ""
	Local oQry
	Local nI 		 := 0

	Private cMotBloq     := ""
	Private nVlFrete     := 0
	Private nVlTotAj     := 0
	Private nVlFinal     := 0
	Private nVlAjust     := 0
	Private lImpEmbutido := .F.
	Private nImpAliquota := 0
	Private nImpValor    := 0
	Private cCombo       := ""
	
	Default lShow := .T.

	cFilAnt := GWD->GWD_FILIAL
	If s_GFEIND == "1" .and. GWD->GWD_VALIND > 0
		cQuery := "SELECT GW3.GW3_SERFAT, GW3.GW3_NRFAT "
		cQuery += " FROM " + RetSqlName("GWL") + " GWL "
		cQuery += " INNER JOIN " + RetSqlName("GW1") + " GW1"
		cQuery += " ON GW1.GW1_FILIAL = GWL.GWL_FILDC"
		cQuery += " AND GW1.GW1_CDTPDC = GWL.GWL_TPDC"
		cQuery += " AND GW1.GW1_EMISDC = GWL.GWL_EMITDC"
		cQuery += " AND GW1.GW1_SERDC = GWL.GWL_SERDC"
		cQuery += " AND GW1.GW1_NRDC = GWL.GWL_NRDC"
		cQuery += " AND GW1.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GW4") + " GW4"
		cQuery += " ON  GW4.GW4_FILIAL = GW1.GW1_FILIAL"
		cQuery += " AND GW4.GW4_EMISDC = GW1.GW1_EMISDC"
		cQuery += " AND GW4.GW4_SERDC = GW1.GW1_SERDC"
		cQuery += " AND GW4.GW4_NRDC = GW1.GW1_NRDC"
		cQuery += " AND GW4.GW4_TPDC = GW1.GW1_CDTPDC"
		cQuery += " AND GW4.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GW3") + " GW3"
		cQuery += " ON GW3.GW3_FILIAL = GW4.GW4_FILIAL"
		cQuery += " AND GW3.GW3_CDESP = GW4.GW4_CDESP"
		cQuery += " AND GW3.GW3_EMISDF = GW4.GW4_EMISDF"
		cQuery += " AND GW3.GW3_SERDF = GW4.GW4_SERDF"
		cQuery += " AND GW3.GW3_NRDF = GW4.GW4_NRDF" 
		cQuery += " AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS"
		cQuery += " AND GW3.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GW6") + " GW6
		cQuery += " ON GW6.GW6_FILIAL = GW3.GW3_FILFAT"
		cQuery += " AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
		cQuery += " AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
		cQuery += " AND GW6.GW6_NRFAT = GW3.GW3_NRFAT"
		cQuery += " AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA"
		cQuery += " AND GW6.GW6_SITAPR IN ('3','4')" 
		cQuery += " AND GW6.GW6_DINDEN > 0"
		cQuery += " AND GW6.D_E_L_E_T_ = ''"
		cQuery += " WHERE GWL.GWL_FILIAL = ?"
		cQuery += " AND GWL.GWL_NROCO = ?"
		cQuery += " AND GWL.D_E_L_E_T_ = ''"			

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,GWD->GWD_FILIAL) 
		oQry:SetString(2,GWD->GWD_NROCO)
		cAliasQry := oQry:OpenAlias()	

		If (cAliasQry)->(!Eof())
			Help(,,'HELP',,'Esta ocorrência gerou um valor indenizatório na fatura ' + (cAliasQry)->GW3_SERFAT + (cAliasQry)->GW3_NRFAT + ' O cancelamento da ocorrencia não alterará o valor do desconto indenizatório da fatura de frete, para recalcula-lo, acione a conferencia da fatura novamente.',1,0)
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If GWD->GWD_SIT == "1"
		cMsg := "A ocorrência possui pendência de aprovação/reprovação."
		If lShow
			MsgInfo(cMsg)
		EndIf
		cFilAnt := cFilBkp
		Return {lCancelado,cMsg}
	EndIf
	
	If !Empty(GWD->GWD_NRMOV + GWD->GWD_CDPTCT)
		cMsg += "Não é permitido cancelar a " + If( (GWD->GWD_SIT == "2"), "aprovação","reprovação") + " de ocorrências relacionadas ao processo de Pátios e Portarias."  + CRLF
	EndIf
	
	If GWD->GWD_SIT == "2" .And. (GWD->GWD_SITTMS == "4" .Or. GWD->GWD_SITTMS == "0") .and. IsInCallStack("GFEA032") 

		cQuery := "SELECT GWD.GWD_FILIAL,"
		cQuery += " GWD.GWD_NROCO,"
		cQuery += " DTQ.DTQ_VIAGEM,"
		cQuery += "	DTQ.DTQ_STATUS,"
		cQuery += "	DUA.DUA_CHVEXT"
		cQuery += " FROM " + RetSqlName("GWD") + " GWD"
		cQuery += " INNER JOIN " + RetSqlName("DUA") + " DUA"
		cQuery += " ON DUA.DUA_FILOCO = '" + xFilial("GWD") + "'"
		If lChvExt
			cQuery += " AND DUA.DUA_CHVEXT = ?"
		Else
			cQuery += " AND DUA.DUA_CHVEXT = ''"
			cQuery += " AND DUA.DUA_NUMOCO + DUA.DUA_SEQOCO = GWD.GWD_CHVEXT "
		EndIf
		cQuery += " AND DUA.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("DTQ") + " DTQ"
		cQuery += " ON DTQ.DTQ_FILORI = DUA.DUA_FILORI"
		cQuery += " AND DTQ.DTQ_VIAGEM = DUA.DUA_VIAGEM"
		cQuery += " AND DTQ.D_E_L_E_T_ = ''"
		cQuery += " WHERE GWD.GWD_FILIAL = ?"
		cQuery += " AND GWD.GWD_NROCO = ?"
		cQuery += " AND GWD.GWD_SITTMS = ?"
		cQuery += " AND GWD.D_E_L_E_T_ = ''"			

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		If lChvExt
			nI ++
			oQry:SetString(nI, xFilial("GWD") + ';' + GWD->GWD_NROCO)
		EndIf
		nI ++
		oQry:SetString(nI,xFilial("GW1")) 
		nI ++
		oQry:SetString(nI,GWD->GWD_NROCO)
		nI ++
		oQry:SetString(nI,IIf(lChvExt,'4','0')) 
		cAliasQry := oQry:OpenAlias()			
		
		Do While (cAliasQry)->(!Eof())
			If (cAliasQry)->DTQ_STATUS == '3' ;
				.And. (AllTrim((cAliasQry)->DUA_CHVEXT) == AllTrim(xFilial("GWD")) + ";" + Alltrim((cAliasQry)->GWD_NROCO) ;
				.Or. Empty((cAliasQry)->DUA_CHVEXT)) 

				MsgInfo("Não é permitido CANCELAR aprovação de ocorrências associadas à DOCUMENTOS/VIAGENS no SIGATMS." + CRLF + CRLF + " DOC\VIAGEM - N° " + (cAliasQry)->DTQ_VIAGEM)
				lCancelado := .F.
				(cAliasQry)->(dbCloseArea())
				Return {lCancelado,cMsg}
			Else
				lCancelado := .T.
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	GU5->(dbSetOrder(1))
	GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
	If GWD->GWD_SIT == "3"
		If Empty(cMsg) .And. FwIsInCallStack("GFE032LOTE")
			lOkProc := .T. // Execução sem msgYesNo para processamento em lote
		ElseIf Empty(cMsg) .And. MsgYesNo("Confirma o cancelamento da reprovação da ocorrência?")
			lOkProc := .T. // Execução sem msgYesNo para processamento em lote
		EndIf

		If lOkProc
			//Cria o temporário fora da transação, evita erro fwtemporarytable
			XFUNBTRB()
			XFUNCTAB()

			BEGIN TRANSACTION
				CancAprRpr(GWD->GWD_SIT)
			END TRANSACTION
			//Cria o temporário fora da transação, evita erro fwtemporarytable
			XFUNCDTAB()
			XFUNBDLTRB()
			lCancelado := .T.
		EndIf
		
		If lShow .And. !Empty(cMsg)
			MsgInfo(cMsg)
		EndIf
		cFilAnt := cFilBkp
		Return {lCancelado,cMsg}
	EndIf
	
	If GWD->GWD_SIT == "2"
		If !FwIsInCallStack("GFE032LOTE")
			If !MsgYesNo("Confirma o cancelamento da aprovação da ocorrência?")
				Return .F.
			EndIF
		EndIf
	EndIf
	
	If GWD->GWD_SITTMS == '4'
		GFE032TMSINT(,,'6')
	EndIF

	GWF->(dbSetOrder(5))
	cChave := xFilial("GWF") + GWD->GWD_NROCO
	
	If GWF->(dbseek(cChave)) // Validação cálculos de frete (devolução/reentrega/serviço)
		Do While !GWF->(Eof()) .And. GWF->(GWF_FILIAL+GWF_NROCO) == cChave
			
			// Valida o calculo de frete existente em relacao aos documentos de frete
			If !GFEVldDocFrete(GWF->GWF_NRCALC,.T.) // GFEXFUNB
				cMsg += "Um dos documentos de carga do cálculo " + GWF->GWF_NRCALC + " está vinculado a um documento de frete do mesmo tipo." + CRLF
			EndIf
			
			If !Empty(GWF->GWF_NRPREF)
				cMsg += "Cálculo " + GWF->GWF_NRCALC + " está associado a pré-fatura de frete." + CRLF
			EndIf
			
			If !Empty(GWF->GWF_NRCONT)
				cMsg += "Cálculo " + GWF->GWF_NRCALC + "  está associado a contrato com autônomo." + CRLF
			EndIf
			
			/*Verificar se o cálculo da ocorrencia não está 
			vinculado a um lote de provisão. Caso esteja, 
			deve-se emitir mensagem impedindo que a ocorrencia seja cancelada*/
			GXD->(DbSetOrder(02))
			If GXD->(DbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
				cMsg += "Cálculo " + GWF->GWF_NRCALC + "  está associado a um lote de provisão." + CRLF
			EndIf
			
			aAdd(aCalcRel,{GWF->GWF_FILIAL,GWF->GWF_NRCALC})
			
			GWF->(dbSkip())
		EndDo
	EndIf
	
	If Empty(cMsg)
		//Ponto de entrada Vicunha
		If s_GFEA032C
			ExecBlock("GFEA032C",.f.,.f.)
		EndIf
		//Cria o temporário fora da transação, evita erro fwtemporarytable
		XFUNBTRB()
		XFUNCTAB()
		
		BEGIN TRANSACTION
			CancAprRpr(GWD->GWD_SIT)
			// Estorno a alteração da data prevista de entrega em cada trecho relacionado a ocorrencia
			cAntOcorr := GFE032DTPRV()
			If !Empty(Alltrim(cAntOcorr))
				DisarmTransaction()
				cMsg := "Não é permitido CANCELAR aprovação de ocorrências que possuam outras ocorrências posteriores." + CRLF + CRLF + " Cancele a(s) aprovação(ões) " + cAntOcorr + " antes de cancelar esta."
				lContinua := .F.
			Else
				If GU5->GU5_EVENTO == "1" //Cálculo Adicional
					For nX := 1 To Len(aCalcRel)
						GFEDelCalc(aCalcRel[nX][2], aCalcRel[nX][1]) // GFEXFUNB
					Next nX
					
					If GU5->GU5_TPCALC == '2' .And. GU5->GU5_DEVTOT == "1"
						CancRegEntr(.F.,.T.)
					EndIf
				EndIf
				
				If GU5->GU5_EVENTO == "4" // Cancelamento de Entrega
					CancRegEntr()
					If GFXCP12121("GWD_PESO")
						If GU5->GU5_INDEN $ "2;3"
							RecLock("GWD", .F.)
								GWD->GWD_VALIND := 0
							GWD->(MsUnlock())
						EndIf
					EndIf
				EndIf
			EndIf
		END TRANSACTION
		// Apresenta mensagem e sai do processamento se encontrada pendencias da ocorrência
		If !lContinua
			MsgInfo(cMsg)
			Return {.F.,cMsg}
		EndIf

		GFE032AUDIT(GWD->GWD_FILIAL, GWD->GWD_NROCO)
					
		If GU5->GU5_CANCDC == "1" // Bloquear, realizar conferência para desbloquear
			cAliasQry := DocOcorrencia()
			Do While (cAliasQry)->(!Eof())
				cDcSit := "4" // Embarcado
							
				If !Empty(GFER059DTE((cAliasQry)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
					cDcSit := "5"
				EndIf
							
				GW1->(dbGoTo((cAliasQry)->RECNOGW1))
					RecLock("GW1",.F.)
					GW1->GW1_SIT := cDcSit
				GW1->(MsUnLock())
								
				If cDcSit == "4" // Se cancelar entrega, muda situacao para EMBARCADO 
					GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf

		//Cria o temporário fora da transação, evita erro fwtemporarytable
		XFUNCDTAB()
		XFUNBDLTRB()
		lCancelado := .T.
	EndIf 
	
	If lShow .And. !Empty(cMsg)
		MsgInfo(cMsg)
	EndIf

	If lCancelado .AND. s_GFEA032H
		ExecBlock("GFEA032H",.f.,.f.)
	EndIf

	RestArea(aAreaGWF)
	RestArea(aAreaGW3)
	aSize(aAreaGWF,0)
	aSize(aAreaGW3,0)
	aSize(aCalcRel,0)
	aSize(aDfRel,0)
	cFilAnt := cFilBkp
Return {lCancelado,cMsg}

Static Function DocOcorrencia()
	Local cAliasGW1 := GetNextAlias()
	Local cQuery 	:= ""
	Local oQry

	cQuery := "SELECT GW1.GW1_FILIAL,"
	cQuery += "GW1.GW1_CDTPDC,"
	cQuery += "GW1.GW1_EMISDC,"
	cQuery += "GW1.GW1_SERDC,"
	cQuery += "GW1.GW1_NRDC,"
	cQuery += "GW1.GW1_SIT,"
	cQuery += "GW1.R_E_C_N_O_ RECNOGW1"
	cQuery += " FROM " + RetSqlName("GW1") + " GW1"
	cQuery += " INNER JOIN " + RetSqlName("GWL") + " GWL"
	cQuery += " ON GWL.GWL_FILDC = GW1.GW1_FILIAL"
	cQuery += " AND GWL.GWL_EMITDC = GW1.GW1_EMISDC"
	cQuery += " AND GWL.GWL_SERDC = GW1.GW1_SERDC"
	cQuery += " AND GWL.GWL_NRDC = GW1.GW1_NRDC"
	cQuery += " AND GWL.GWL_TPDC = GW1.GW1_CDTPDC"
	cQuery += " AND GWL.GWL_FILIAL = ?" 
	cQuery += " AND GWL.GWL_NROCO = ?" 
	cQuery += " AND GWL.D_E_L_E_T_ = ''"
	cQuery += " WHERE GW1.GW1_FILIAL = ?"
	cQuery += " AND GW1.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,GWD->GWD_FILIAL)
	oQry:SetString(2,GWD->GWD_NROCO)
	oQry:SetNumeric(3,xFilial("GW1"))
	cAliasGW1 := oQry:OpenAlias()	

Return cAliasGW1

Function GFEA032DEL()
	Local oModel := FwLoadModel("GFEA032")
	Local aErro  := {}
	Local nApaga := 0
	Local lDelLote := FwIsInCallStack("GFE032LOTE")

	Default aMsgProc := {}

	oModel:SetOperation(MODEL_OPERATION_DELETE)
	//Executa a validação real de exclusão
	If !oModel:Activate() .Or. !oModel:VldData() .Or. !oModel:VldData("GFEA032_GWD") .Or. !oModel:VldData("GFEA032_GWL") // eXECUTA AS FUNÇÕES DE VALIDAÇÃO
		aErro := oModel:GetErrorMessage()
		MsgInfo( AllToChar(aErro[6]) + CRLF + AllToChar(aErro[7]) + CRLF + CRLF + "Campo: " + AllToChar(aErro[2]) + CRLF + "Valor: " + AllToChar(aErro[9]))

		oModel:DeActivate()
		FreeObj(oModel)
	Else
		oModel:DeActivate()
		FreeObj(oModel)
		//Apenas exibe uma tela para que o usuário confirme.
		GWF->(dbGoTop())
		GWF->(dbSkip(-1))
		If !FwIsInCallStack("GFE032LOTE")
			nApaga := FwExecView("Excluir",'GFEC032',MODEL_OPERATION_DELETE)
		EndIf
		If nApaga == 0
			//Efetiva a exclusão
			oModel := FwLoadModel("GFEA032")
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			If !oModel:Activate() .Or. !oModel:VldData() .Or. !oModel:VldData("GFEA032_GWD") .Or. !oModel:VldData("GFEA032_GWL") // eXECUTA AS FUNÇÕES DE VALIDAÇÃO
				aErro := oModel:GetErrorMessage()
				MsgInfo( AllToChar(aErro[6]) + CRLF + AllToChar(aErro[7]) + CRLF + CRLF + "Campo: " + AllToChar(aErro[2]) + CRLF + "Valor: " + AllToChar(aErro[9]))
			Else
				oModel:CommitData()
			EndIf
			oModel:DeActivate()
			FreeObj(oModel)
		EndIf
	EndIf
	aSize(aErro,0)
Return

Static Function criaGrpClc(lApraut)
	
	If lApraut

		cCdTransp := FwFldGet('GWD_CDTRP')
		cCdPrest  := FwFldGet('GWD_CDTRP')

		dbSelectArea('GU5')
		dbSetOrder(01)
		If dbSeek(xFilial('GU5')+FwFldGet('GWD_CDTIPO'))
			If GU5->GU5_TPCALC == "3" .And. GfeVerCmpo({"GU5_PRESTS"}) .And. GU5->GU5_PRESTS == "1";
				.And. GfeVerCmpo({"GU5_TABFRE"}) .And. GU5->GU5_TABFRE == "2"

				cCdPrest := FwFldGet('GWD_PRESTS')
				lPrestServ := .T.
			EndIf
		EndIf
		If aScan(aAgrFrt,{|x| x[1] == FwFldGet('GWD_NROCO') }) = 0

			aAdd(aAgrFrt, {	FwFldGet('GWD_NROCO'),; //Numero do Agrupador
							cCdPrest,; //Transportador
							GWN->GWN_CDTPVC,; //Tipo de Veículo
							GWN->GWN_CDCLFR,; // Classificação de Frete
							GWN->GWN_CDTPOP,; // Tipo de Operação
							GWN->GWN_DISTAN,; //Distancia Percorrida
							"",;
							"",;
							"0"})
		EndIf
	Else
		cCdTransp := GWD->GWD_CDTRP
		cCdPrest  := GWD->GWD_CDTRP

		dbSelectArea('GU5')
		dbSetOrder(01)
		If dbSeek(xFilial('GU5')+GWD->GWD_CDTIPO)
			If GU5->GU5_TPCALC == "3" .And. GfeVerCmpo({"GU5_PRESTS"}) .And. GU5->GU5_PRESTS == "1";
				.And. GfeVerCmpo({"GU5_TABFRE"}) .And. GU5->GU5_TABFRE == "2"

				cCdPrest   := GWD->GWD_PRESTS
				lPrestServ := .T.
			 EndIf
		EndIf

		If aScan(aAgrFrt,{|x| x[1] == GWD->GWD_NROCO }) = 0
			aAdd(aAgrFrt, { GWD->GWD_NROCO,; //Numero do Agrupador
							cCdPrest,; //Transportador
							GWN->GWN_CDTPVC,; //Tipo de Veículo
							GWN->GWN_CDCLFR,; // Classificação de Frete
							GWN->GWN_CDTPOP,; // Tipo de Operação
							GWN->GWN_DISTAN,; //Distancia Percorrida
							"",;
							"",;
							"0"})
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} GF32EVEOCO
	Registra os eventos da ocorrência no documento de carga 
	@author siegklenes.beulke
	@since 18/05/2017
	@version undefined
	@param cTipoEvento, characters, Evento que ocorreu 
	@example
	(examples)
	@see (links_or_references)
/*/
Function GF32EVEOCO(cTipoEvento,cFilOco,cNrOco)
	Local lRet      := .T.
	Local cAliasGW1 := Nil
	Local cFilBkp   := ""
	Local cMotivo   := ""
	Local cQuery	:= ""
	Local oQry

	lRet := !(GFXCP12117("GW1_SITFRE") == .F. .And. SuperGetMv("MV_INTFRE",.F.,"1") != "2")

	If lRet
		cFilBkp := cFilAnt
		cFilAnt := cFilOco
		
		If cTipoEvento == "APROVACAO" .Or. cTipoEvento == "CANC/APROVACAO"

			If cTipoEvento == "CANC/APROVACAO"
				cMotivo := "GFEA032 - Aprovação de ocorrência cancelada"
			Else
				cMotivo := "GFEA032 - Ocorrência aprovada"
			EndIf

			cQuery := "SELECT DISTINCT GW1.R_E_C_N_O_ RECNOGW1"
			cQuery += " FROM " + RetSqlName("GW1") + " GW1"
			cQuery += " INNER JOIN " + RetSqlName("GWL") + " GWL"
			cQuery += " ON GWL.GWL_FILDC = GW1.GW1_FILIAL"
			cQuery += " AND GWL.GWL_EMITDC = GW1.GW1_EMISDC"
			cQuery += " AND GWL.GWL_SERDC = GW1.GW1_SERDC"
			cQuery += " AND GWL.GWL_TPDC = GW1.GW1_CDTPDC"
			cQuery += " AND GWL.GWL_NRDC = GW1.GW1_NRDC"
			cQuery += " AND GWL.GWL_NROCO = ?"
			cQuery += " AND GWL.D_E_L_E_T_ = ''"
			cQuery += " WHERE GW1.GW1_FILIAL = ?"
			cQuery += " AND GW1.GW1_ORIGEM = ?"
			cQuery += "	AND GW1.GW1_SITFRE <> ?"
			cQuery += " AND GW1.D_E_L_E_T_ = ''"

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery) 
			oQry:SetString(1,cNrOco)
			oQry:SetNumeric(2,xFilial("GW1"))
			oQry:SetString(3,'2')
			oQry:SetString(4,'6')
			cAliasGW1 := oQry:OpenAlias()	

			Do While (cAliasGW1)->(!Eof())
				GW1->(dbGoTo((cAliasGW1)->RECNOGW1))
				
				RecLock("GW1",.F.)
					GW1->GW1_SITFRE := "2"
					GW1->GW1_MOTFRE := cMotivo
					GW1->GW1_DTFRE  := DATE()
				GW1->(MsUnLock())
				
				(cAliasGW1)->(dbSkip())
			EndDo
			
			(cAliasGW1)->(dbCloseArea())
		Else
			lRet := .F.
		EndIf		
		cFilAnt := cFilBkp
	EndIf
Return lRet

Static Function GFEOcoACal(nNovoVlCa, cNumOcor)
	Local nX       := 0
	Local nAuxPerc := 0
	Local nAuxTot  := 0
	Local nTotCalc := 0
	Local nVlrCalc := 0
	Local lRet     := .T.
	Local aItens   := {}
	Local cCriRat  := GetNewPar("MV_CRIRAT", "1") 	// 1-Peso mercadoria, 2-Valor mercadoria, 3-Volume, 4-Quantidade.

	Private nAuxFrt     := 0
	Private nVlTotComp  := 0
	Private nVlCompSrv  := 0		
	Private aRetRateio  := {}

	Default nNovoVlCa := 0

	GWF->(dbsetorder(5))
	If GWF->(dbseek(xFilial("GWF") + cNumOcor))
		While GWF->(!Eof()) .And. Alltrim(GWF->GWF_NROCO) == Alltrim(cNumOcor)
			GWH->(DbSetOrder(1))
			GWH->(DbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
			While !GWH->(Eof()) .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
				ListItemRat(@aItens, cCriRat, {GWH->GWH_FILIAL, GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC})
				GWH->(dbSkip())
			EndDo
			GWF->(DbSkip())
		EndDo

		For nX := 1 To Len(aItens)
			nTotCalc += aItens[nX][9]
		Next

		GWF->(dbsetorder(5))
		GWF->(dbseek(xFilial("GWF") + cNumOcor))
		While GWF->(!Eof()) .And. Alltrim(GWF->GWF_NROCO) == Alltrim(cNumOcor)
			aItens     := {}
			nVlrCalc   := 0
			nVlTotComp := 0

			GWH->(DbSetOrder(1))
			GWH->(DbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
			While !GWH->(Eof()) .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
				ListItemRat(@aItens, cCriRat, {GWH->GWH_FILIAL, GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC})
				GWH->(dbSkip())
			EndDo

			For nX := 1 To Len(aItens)
				nVlrCalc += aItens[nX][9]
			Next

			nAuxPerc:= (nVlrCalc / nTotCalc) * 100

			nAuxFrt := Round(nNovoVlCa * (nAuxPerc / 100), 2)
			nAuxTot += nAuxFrt

			GFECalOcor(GWF->GWF_NRCALC)

			GWF->(DbSkip())
		EndDo
	EndIf
Return lRet

Static Function GFECalOcor(cNrCalc)
	Local nAdIcms     := 0
	Local lAchouGV9   := .F.
	Local nCalcVlr    := 0
	Local nRecnoGWI   := 0
	Local nVlIcms     := 0
	Local nPerPisCal := SuperGetMV('MV_PCPIS',,'0')
	Local nPerCofCal := SuperGetMV('MV_PCCOFI',,'0')

	//Localiza os componentes do novo cálculo e realiza a alteração pelo novo valor.
	GWG->(dbSetOrder(1))
	If GWG->(dbSeek(xFilial("GWG") + cNrCalc))
		GWI->(dbSetOrder(1))
		GWI->(dbSeek(GWG->(GWG_FILIAL+GWG_NRCALC+GWG_CDCLFR+GWG_CDTPOP)))
		nRecnoGWI := GWI->(Recno())

		//Avaliar se tem ICMS adicionado ao Componente ou não
		Do While !GWI->(Eof()) .And. GWG->(GWG_FILIAL+GWG_NRCALC+GWG_CDCLFR+GWG_CDTPOP) == GWI->(GWI_FILIAL+GWI_NRCALC+GWI_CDCLFR+GWI_CDTPOP)
			GV9->(dbSetOrder(1))
			lAchouGV9 := GV9->(dbSeek(xFilial("GV9") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG))
			If !lAchouGV9
				GVA->(DbSetOrder(1))
				If GVA->(DbSeek(xFilial("GVA") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB))
					lAchouGV9 := GV9->(dbSeek(xFilial("GV9") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GWG->GWG_NRNEG))
				EndIf
			EndIf
			If lAchouGV9
				If GV9->GV9_ADICMS == "1" .And. GV9->GV9_RATIMP == "2" .And. GV9->GV9_COMIMP == GWI->GWI_CDCOMP	
					nAdIcms := 1      // Tem componente especifico para ICMS e Adiciona ICMS
				Else
					nVlTotComp += GWI->GWI_VLFRET  //soma dos componentes, Total OU sem ICMS se este estiver em um componente
				EndIf			   
			EndIf
			GWI->(DbSkip())
		EndDo
	
		GWF->(dbSetOrder(1))
		If GWF->(dbSeek(xFilial("GWF") + cNrCalc)) .And. nAdIcms == 1  
			nVlIcms := nAuxFrt * (GWF->GWF_PCICMS/100)
			nAuxFrt := nAuxFrt - nVlIcms   
		EndIf		

		GWI->(DbGoto(nRecnoGWI))
		//Para cada componente ajusta o seu valor de acordo com o total informado pelo usuário.
		Do While !GWI->(Eof()) .And. GWG->(GWG_FILIAL+GWG_NRCALC+GWG_CDCLFR+GWG_CDTPOP) == GWI->(GWI_FILIAL+GWI_NRCALC+GWI_CDCLFR+GWI_CDTPOP)

			GV9->(dbSetOrder(1))
			lAchouGV9 := GV9->(dbSeek(xFilial("GV9") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG))
			If !lAchouGV9
				GVA->(DbSetOrder(1))
				If GVA->(DbSeek(xFilial("GVA") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB))
					lAchouGV9 := GV9->(dbSeek(xFilial("GV9") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GWG->GWG_NRNEG))
				EndIf
			EndIf
			If lAchouGV9
					//Quando o componento conter ICMS
					If GV9->GV9_ADICMS == "1" .And. GV9->GV9_RATIMP == "2" .And. GV9->GV9_COMIMP == GWI->GWI_CDCOMP	
						nCalcVlr := nVlIcms
					ElseIf GWI->GWI_VLFRET == 0 .Or. nVlTotComp == 0
						nCalcVlr := nAuxFrt
					Else
						nCalcVlr := nAuxFrt * (GWI->GWI_VLFRET/nVlTotComp)
					EndIf	

				RecLock("GWI", .F.)
				GWI->GWI_VLFRET := nCalcVlr
				GWI->(MsUnlock())

				nVlCompSrv += GWI->GWI_VLFRET

			EndIf
			GWI->(dbSkip())
		EndDo
	EndIf

	/* ---------------- Impostos --------------- */
	GWF->(dbSetOrder(1))
	If GWF->(dbSeek(xFilial("GWF") + cNrCalc))
		RecLock( "GWF", .F. )
			If GWF->GWF_IMPOST == "1"  .Or. empty(GWF->GWF_IMPOST)   //ICMS
				GWF->GWF_BASICM :=  nVlCompSrv
				GWF->GWF_VLICMS :=  GWF->GWF_BASICM * (GWF->GWF_PCICMS/100)
			ElseIf GWF->GWF_IMPOST == "2"  //ISS
				GWF->GWF_BASISS :=  nVlCompSrv
				GWF->GWF_VLISS  :=  GWF->GWF_BASISS * (GWF->GWF_PCISS/100)
			EndIf
		
			GWF->GWF_BAPICO :=  nVlCompSrv
			GWF->GWF_VLPIS  :=  GWF->GWF_BAPICO * (nPerPisCal/100)
			GWF->GWF_VLCOFI :=  GWF->GWF_BAPICO * (nPerCofCal/100)
		MsUnlock()
	EndIf

	//Realiza o rateio do cálculo novamente com base no novo valor
	aRetRateio := GFERatCal(.F., cNrCalc)
Return

Function GFEA032IND()
	Local lRet := .F.

	GU5->(dbSetOrder(1))
	If GU5->(dbSeek(xFilial('GU5')+M->GWD_CDTIPO))
			If GU5->GU5_INDEN == "1"
				lRet := .T.
		 EndIf
	EndIf
	
Return lRet
Function dDataGWD()
	Local dData := dDataBase

	If IsBlind()
		dData := DATE()
	EndIf
Return dData

Static Function GFECalInd(cGWD_FILIAL, cGWD_NROCO, cGU5_INDEN)
	Local nValorTotal := 0
	Local nPesoTotal  := 0
	Local nValorInd   := 0
	Local nPesoInd    := 0
	Local nValorRat   := 0
	Local nValUnIt    := 0
	Local nValIndFre  := 0
	Local nMV_GFEQBR  := 0
	Local nMV_CRIRAT  := SuperGetMV('MV_CRIRAT',,'1')
	Local cGWD_PESO   := 0
	Local aRet        := {.T., ""}

	nMV_GFEQBR := GFEPQbrPes(cGWD_FILIAL, cGWD_NROCO)
	
	//Soma todos os pesos de todas as notas e itens.
	GWD->(dbSetOrder(1))
	GWD->(dbSeek(cGWD_FILIAL+cGWD_NROCO))
	cGWD_PESO := GWD->GWD_PESO
	GWL->(dbSetOrder(1))
	GWL->(dbSeek(GWD->(GWD_FILIAL+GWD_NROCO)))
	Do While !GWL->(Eof()) .And. GWD->(GWD_FILIAL+GWD_NROCO) == GWL->(GWL_FILIAL+GWL_NROCO)
		GW8->(dbSetOrder(1))
		GW8->(msSeek(GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC))) //GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC
		Do While !GWL->(Eof()) .And. GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC) == GW8->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC)
			
			nPesoTotal += GW8->GW8_PESOR
			nValorTotal += GW8->GW8_VALOR
			
			GW8->(dbSkip())
		EndDo			 
		GWL->(dbSkip())
	EndDo
	
	If cGWD_PESO < nPesoTotal
		nPesoInd := (nPesoTotal - cGWD_PESO) - (nPesoTotal * (nMV_GFEQBR / 100))
		nValUnIt := nValorTotal / nPesoTotal
		nValorInd := nPesoInd * nValUnIt
		
		If nValorInd > 0
			RecLock("GWD",.F.)
				GWD->GWD_VALIND := nValorInd
				GWD->GWD_MAXQBR := nMV_GFEQBR
			GWD->(MsUnlock())
		EndIf
	EndIf
	
	//Calcula o Frete proporcional.
	If cGU5_INDEN == "3" .And. nValorInd > 0

		GWL->(dbSetOrder(1))
		GWL->(dbSeek(GWD->(GWD_FILIAL+GWD_NROCO)))
		Do While !GWL->(Eof()) .And. GWD->(GWD_FILIAL+GWD_NROCO) == GWL->(GWL_FILIAL+GWL_NROCO)
			//Documento de Carga
			GW1->(dbSetOrder(1)) //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
			GW1->(dbSeek(GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC)))
			Do While !GW1->(Eof()) .And. GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC) == GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)
				
				GW4->(dbSetOrder(2)) //GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
				If GW4->(dbSeek(GW1->(GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_CDTPDC)))
					Do While !GW4->(Eof()) .And. GW1->(GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_CDTPDC) == GW4->(GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC)
						//Posicionar GW8.
				
						GW3->(dbSetOrder(1))
						GW3->(dbSeek(GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS))))
						Do While !GW3->(Eof()) .And. GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)) == GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS))
						
							If GW3->GW3_TPDF == "1"
						
								GW8->(dbSetOrder(2)) //GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ 
								GW8->(dbSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
								Do While !GW8->(Eof()) .And. GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC) == GW8->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC)
							
									GWM->(dbSetOrder(1))
									If GWM->(dbSeek(xFilial("GWM")+"2"+GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC+GW8->GW8_SEQ)) 
									
										If nMV_CRIRAT == "1" 
											nValorRat := GWM->GWM_VLFRET
										ElseIf nMV_CRIRAT == "2"
											nValorRat := GWM->GWM_VLFRE1
										ElseIf nMV_CRIRAT == "3"
											nValorRat := GWM->GWM_VLFRE3
										ElseIf nMV_CRIRAT == "4"
											nValorRat := GWM->GWM_VLFRE2
										EndIf
										
										//Pega o valor de acordo com o critério de Rateio.
										nValorItem := nValorRat / GW8->GW8_PESOR
										nValIndFre := nPesoInd * nValorItem 
										
										If nValIndFre > 0
											RecLock("GWD",.F.)
												GWD->GWD_VALIND += nValIndFre
											GWD->(MsUnlock())
										EndIf
									Else
										aRet[1] := .F.
										aRet[2] := "Não foi possível calcular a indenização por carga e frete. É necessário que o Documento de Frete do Tipo Normal vinculado ao Documento de Carga da Ocorrência esteja aprovado. Esta Ocorrência não foi aprovada."
									EndIf
									
									GW8->(dbSkip())
								EndDo
							
							Else
								aRet[1] := .F.
								aRet[2] := "Não foi possível calcular a indenização por carga e frete. É necessário que haja um Documento de Frete aprovado do Tipo Normal vinculado ao Documento de Carga da Ocorrência. Esta Ocorrência não foi aprovada."
							EndIf
						
							GW3->(dbSkip())
						EndDo
					
						GW4->(dbSkip())
					EndDo
				Else
					aRet[1] := .F.
					aRet[2] := "Não foi possível calcular a indenização por carga e frete. É necessário que haja um Documento de Frete aprovado vinculado ao Documento de Carga da Ocorrência. Esta Ocorrência não foi aprovada. "
				EndIf
				GW1->(dbSkip())
			EndDo
			GWL->(dbSkip())
		EndDo
	EndIf
Return aRet

Function GFEPQbrPes(cGWD_FILIAL, cGWD_NROCO)
	/*aCriterios[1]	: Remetente
	aCriterios[2]	: Destinatário
	aCriterios[3]	: Cidade Origem
	aCriterios[4]	: Cidade Destino
	aCriterios[5]	: Transportador
	aCriterios[6]	: Grupo Transportador
	aCriterios[7]	: Tipo Operação
	aCriterios[8]	: Tipo Veículo
	aCriterios[9]	: Modalidade de Transporte
	aCriterios[10]	: Classificação de Frete*/
	Local aCriterios[14]
	Local aResult  := {}
	Local nPercQbr := 0

		GWD->(dbSetOrder(1))
		GWD->(dbSeek(GWD->(cGWD_FILIAL+cGWD_NROCO)))
		
		GWL->(dbSetOrder(1))
		GWL->(dbSeek(GWD->(GWD_FILIAL+GWD_NROCO)))
		
		GW1->(dbSetOrder(1)) //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
		GW1->(dbSeek(GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC)))
		
		GWN->(dbSetOrder(1))
		GWN->(dbSeek(GW1->(GW1_FILIAL+GW1_NRROM)))
		
		GWU->(dbSetOrder(1))
		GWU->(dbSeek(GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC)))
		
		Do While GWU->(!Eof()) .And. GWL->(GWL_FILDC+GWL_TPDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC) == GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC)
			If GWD->GWD_CDTRP == GWU->GWU_CDTRP
				aCriterios[1] := GW1->GW1_CDREM
				aCriterios[2] := GW1->GW1_CDDEST
				aCriterios[3] := GWU->GWU_NRCIDO
				aCriterios[4] := GWU->GWU_NRCIDD
				aCriterios[5] := GWU->GWU_CDTRP
				aCriterios[6] := Posicione("GU3", 1, xFilial("GU3")+GWU->GWU_CDTRP, "GU3_CDGREM")
				aCriterios[7] := GWN->GWN_CDTPOP
				aCriterios[8] := GWN->GWN_CDTPVC
				aCriterios[10] := GWN->GWN_CDCLFR
			EndIf
			GWU->(dbSkip())
		EndDo
		
		aResult := GFETabPrzQbr(aCriterios, Date(), Time(), '3')
		
		/*Retorno Array contendo:
		aRet[1]	: Data Prevista
		aRet[2]	: Hora Prevista
		aRet[3]	: Tabela escolhida
		aRet[3]	: Tabela escolhida
		aRet[5] : Sucesso da operação (true/false)
		aRet[6]	: Mensagem de erro/warning*/
		
		If !Empty(aResult[3])
			nPercQbr := aResult[3]
		Else
			nPercQbr := SuperGetMV('MV_GFEQBR',,'0')
		EndIf
Return nPercQbr

Function GFE032COPY()
	lCopy := .T.
	FWExecView("Copiar","GFEA032",9,,{|| .T.}) //"Copiar"
Return

// Função para verificar se o(s) Documento(s) de Carga relacionados à ocorrência possuem Documento de Frete.
// Em caso positivo, se o documento estiver na situação bloqueado, executar a rotina de auditoria de frete (GFEA065CO). 
Function GFE032AUDIT(cFilOco, nrOco, lMsg)
	Local cWhere	:= ""
	Local aAreaGW3  := GW3->(GetArea())
	Local aAreaGWD  := GWD->(GetArea())
	Local cAliasGWD := GetNextAlias()
	Local cAliasQry := GetNextAlias()
	Local cQuery 	:= ""
	Local nI 		:= 1
	Local oQry

	Default lmsg := .T.

	cQuery := "SELECT GU5_EVENTO, GU5_TPCALC"
	cQuery += " FROM " + RetSqlName("GWD") + " GWD"
	cQuery += " INNER JOIN " + RetSqlName("GU5") + " GU5"
	cQuery += " ON GU5.GU5_FILIAL = '" + xFilial("GU5") + "'"
	cQuery += " AND GU5.GU5_CDTIPO = GWD_CDTIPO"
	cQuery += " AND GU5.D_E_L_E_T_ = ''"
	cQuery += " WHERE GWD.GWD_FILIAL = ?"
	cQuery += " AND GWD.GWD_NROCO = ?"
	cQuery += " AND GWD.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,cFilOco)
	oQry:SetString(2,nrOco)
	cAliasGWD := oQry:OpenAlias()
	
	If (cAliasGWD)->(!Eof())
		cQuery := "SELECT GW3.R_E_C_N_O_ AS GW3Recno"
		cQuery += " FROM " + RetSqlName("GWL") + " GWL"
		cQuery += " INNER JOIN " + RetSqlName("GW4") + " GW4"
		cQuery += " ON GW4.GW4_FILIAL = GWL.GWL_FILDC"
		cQuery += " AND GW4.GW4_EMISDC = GWL.GWL_EMITDC"
		cQuery += " AND GW4.GW4_SERDC = GWL.GWL_SERDC"
		cQuery += " AND GW4.GW4_NRDC = GWL.GWL_NRDC"
		cQuery += " AND GW4.GW4_TPDC = GWL.GWL_TPDC"
		cQuery += " AND GW4.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetSqlName("GW3") + " GW3"
		cQuery += " ON GW3.GW3_FILIAL = GW4.GW4_FILIAL"
		cQuery += " AND GW3.GW3_CDESP = GW4.GW4_CDESP"
		cQuery += " AND GW3.GW3_EMISDF = GW4.GW4_EMISDF"
		cQuery += " AND GW3.GW3_SERDF = GW4.GW4_SERDF"
		cQuery += " AND GW3.GW3_NRDF = GW4.GW4_NRDF"
		cQuery += " AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS"
		cQuery += " AND GW3.D_E_L_E_T_ = ''"
		cQuery += " WHERE GWL.GWL_FILIAL = ?"
		cQuery += " AND GWL.GWL_NROCO = ?"		
		
		If (cAliasGWD)->GU5_EVENTO == "1"
			DO CASE
				CASE (cAliasGWD)->GU5_TPCALC == "1" // 0=Nenhum;1=Reentrega;2=Retorno;3=Serviço
					cQuery += " AND GW3.GW3_TPDF = ? AND GW3.GW3_SIT = ?" // 1=Normal;2=Complementar Valor;3=Complementar Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico
				CASE (cAliasGWD)->GU5_TPCALC == "2"
					cQuery += " AND GW3.GW3_TPDF = ? AND GW3.GW3_SIT = ?" // 1=Normal;2=Complementar Valor;3=Complementar Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico
				CASE (cAliasGWD)->GU5_TPCALC == "3"
					cQuery += " AND GW3.GW3_TPDF = ? AND GW3.GW3_SIT = ?" // 1=Normal;2=Complementar Valor;3=Complementar Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico
			EndCase			
		ElseIf (cAliasGWD)->GU5_EVENTO == "4"
			cQuery += " AND (GW3.GW3_TPDF = ? OR GW3.GW3_TPDF = ?) AND GW3.GW3_SIT = ?"
		EndIf
		cQuery += " AND GWL.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(nI,cFilOco)
		nI ++
		oQry:SetString(nI,nrOco)
		If (cAliasGWD)->GU5_EVENTO == "1"
			DO CASE
				CASE (cAliasGWD)->GU5_TPCALC == "1" 
					nI ++
					oQry:SetString(nI,'4')
					nI ++
					oQry:SetString(nI,'2')  
				CASE (cAliasGWD)->GU5_TPCALC == "2"
					nI ++
					oQry:SetString(nI,'5')
					nI ++
					oQry:SetString(nI,'2') 
				CASE (cAliasGWD)->GU5_TPCALC == "3"
					nI ++
					oQry:SetString(nI,'7')
					nI ++
					oQry:SetString(nI,'2') 
			EndCase
		ElseIf (cAliasGWD)->GU5_EVENTO == "4"
			nI ++
			oQry:SetString(nI,'1')
			nI ++
			oQry:SetString(nI,'6')
			nI ++
			oQry:SetString(nI,'5')
		EndIf	
		cAliasQry := oQry:OpenAlias()	
			
		Do While (cAliasQry)->(!Eof())
		GW3->(DbGoTo((cAliasQry)->GW3Recno))
			GFE50DFCONF(lMsg)
		(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		(cAliasGWD)->(dbCloseArea())
	EndIf
	RestArea(aAreaGW3)
	RestArea(aAreaGWD)
Return

/*/{Protheus.doc} GFE032WHEN
@author Jefferson Hita
@since 14/02/2020
@version 1.0

@description: Função para validar tipo de evento de ocorrencia para habilitar/desabilitar edição do campo Evidencia de entrega quando o tipo de ocorrência tiver evento de entrega.
/*/
Function GFE032WHEN(cTipoEven)
	Local lRet   	:= .F.
	Local cAliasQry := "" 
	Local cQuery	:= ""
	Local oQry

	If !Empty(Alltrim(cTipoEven))
		cAliasQry := GetNextAlias()
		cQuery := "SELECT GU5.R_E_C_N_O_ RECNOGU5"
		cQuery += " FROM " + RetSqlName("GU5") + " GU5"
		cQuery += " WHERE GU5.GU5_FILIAL = ?"
		cQuery += " AND GU5.GU5_CDTIPO = ?"
		cQuery += " AND GU5.GU5_EVENTO = ?"
		cQuery += " AND GU5.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetNumeric(1,xFilial("GU5"))
		oQry:SetString(2,cTipoEven)
		oQry:SetString(3,'4')
		cAliasQry := oQry:OpenAlias()

		If  (cAliasQry)->(!Eof())
			lRet := .T.
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet

/*/{protheus.Doc} GFE032DTPRV
@autor Jefferson Hita
@since 04/03/2020
@version 1.0

@description: Função para estorno da alteração da data prevista de entrega dos trechos relacionados a ocorrencia que foram alterados na aprovação.
/*/
Static Function GFE032DTPRV()
	Local cRet      := ""
	Local cAliasGW0 := Nil
	Local cAliasEnt := GetNextAlias()
	Local cHrPEnt   := ""
	Local cRecPrz	:= SuperGetMV("MV_RECPRZ", .F., "0")
	Local cQuery	:= ""
	Local oQry
	
	cQuery := "SELECT GWU.R_E_C_N_O_"
	cQuery += " FROM " + RetSqlName("GWL") + " GWL"
	cQuery += " INNER JOIN " + RetSqlName("GWU") + " GWU"
	cQuery += "	ON GWU.GWU_FILIAL = GWL.GWL_FILDC"
	cQuery += "	AND GWU.GWU_CDTPDC = GWL.GWL_TPDC"
	cQuery += "	AND GWU.GWU_EMISDC = GWL.GWL_EMITDC"
	cQuery += "	AND GWU.GWU_SERDC = GWL.GWL_SERDC"
	cQuery += "	AND GWU.GWU_NRDC = GWL.GWL_NRDC"
	cQuery += "	AND GWU.GWU_SEQ = GWL.GWL_SEQ"
	cQuery += " AND GWU.D_E_L_E_T_ = ''"
	cQuery += " WHERE GWL.GWL_FILIAL = ?"
	cQuery += " AND GWL.GWL_NROCO = ?"
	cQuery += " AND GWL.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetString(1,GWD->GWD_FILIAL)
	oQry:SetString(2,GWD->GWD_NROCO)
	cAliasEnt := oQry:OpenAlias()	

	(cAliasEnt)->(dbGoTop())
	Do While (cAliasEnt)->(!EoF())
		GWU->(dbGoTo((cAliasEnt)->R_E_C_N_O_))
		
		// Gravação de registro anterior na tabela GW0 para possivel estorno
		cQuery := "SELECT GW0.R_E_C_N_O_ AS RECNOGW0"
		cQuery += " FROM " + RetSqlName("GW0") + " GW0"
		cQuery += " WHERE GW0.GW0_FILIAL = ?"
		cQuery += " AND GW0.GW0_TABELA = ?"
		cQuery += " AND GW0.GW0_CHAVE = ?"
		cQuery += " AND GW0.GW0_CHAR02 = ?"
		cQuery += " AND GW0.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery) 
		oQry:SetString(1,GWU->GWU_FILIAL)
		oQry:SetString(2,'GWU')
		oQry:SetString(3,GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ) + GWD->(GWD_FILIAL+GWD_NROCO))
		oQry:SetString(4,GWD->(GWD_FILIAL+GWD_NROCO)+DtoS(GWD->GWD_DTOCOR))
		cAliasGW0 := oQry:OpenAlias()	

		If (cAliasGW0)->(!EoF())
			GW0->(dbGoTo((cAliasGW0)->RECNOGW0))

			// Verifico se existe outra ocorrencia com data de alteração posterios a em cancelamento
			cQuery := "SELECT GW0A.GW0_CHAR02"
			cQuery += " FROM " + RetSqlName("GW0") + " GW0A"
			cQuery += " WHERE GW0A.GW0_FILIAL = ?"
			cQuery += " AND GW0A.GW0_TABELA = ?"
			cQuery += " AND GW0A.GW0_CHAVE = ?"
			cQuery += " AND GW0A.GW0_CHAR02 = ?"
			cQuery += " AND GW0A.GW0_DATA01 = ?"
			cQuery += " AND GW0A.D_E_L_E_T_ = ''"

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery) 
			oQry:SetString(1,GWU->GWU_FILIAL)
			oQry:SetString(2,'GWU')
			oQry:SetString(3,GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ))
			oQry:SetString(4,GWD->(GWD_FILIAL+GWD_NROCO)+DtoS(GWD->GWD_DTOCOR))
			oQry:SetString(5,DtoS(GW0->GW0_DATA01))
			cAliasGW0A := oQry:OpenAlias()	

			If (cAliasGW0A)->(!EoF())	// Se existir outras ocorrencias com datas posteriores, retorna mensagem e cancela o processo.
				Do While (cAliasGW0A)->(!EoF())
					cRet += "[" + Substr(Alltrim( (cAliasGW0A)->GW0_CHAR02 ), 1, Len(Alltrim( (cAliasGW0A)->GW0_CHAR02 ))-8) + "]"

					(cAliasGW0A)->(DbSkip())
				EndDo

			Else
				dDtAnt := GWU->GWU_DTPENT
				cHrAnt := GWU->GWU_HRPENT

				// Estorno dados no trecho do documento
				RecLock("GWU", .F.)
				GWU->GWU_DTPENT = GW0->GW0_DATA01
				GWU->GWU_HRPENT = Alltrim(GW0->GW0_CHAR01)
				GWU->(MsUnlock())
				
				// -----------------------------------------------------------------------------------------
				// Verifica se existe mais de 1 trecho para atualizar prazo de entrega dos demais trechos
				// -----------------------------------------------------------------------------------------
				If Posicione("GU5", 1, xFilial("GU5") + GWD->GWD_CDTIPO, "GU5_EVENTO") == "5" // Reagendar Entrega
					If cRecPrz == "1"
						If GWU->GWU_DTPENT < dDtAnt .Or. (GWU->GWU_DTPENT == dDtAnt .And. cHrPEnt < cHrAnt)
							RecPrzTrec( GWU->(Recno()), GW0->GW0_DATA01, Alltrim(GW0->GW0_CHAR01))
						EndIf
					ElseIf cRecPrz == "2"
						RecPrzTrec( GWU->(Recno()), GW0->GW0_DATA01, Alltrim(GW0->GW0_CHAR01))
					EndIf
				EndIf

				// Excluo o registro de log da alteração dos dados
				RecLock("GW0", .F.)
				GW0->( DbDelete() )
				GW0->(MsUnlock())
			EndIf
			(cAliasGW0A)->(dbCloseArea())

		EndIf
		(cAliasGW0)->(dbCloseArea())
		
		(cAliasEnt)->(dbSkip())
	EndDo

	(cAliasEnt)->(dbCloseArea())
Return cRet

Static Function ListItemRat(aItens, cCriterio, aChaveGW1)
	Local aItem[19]
	Local nFatorItem := 0
	/* aItem - Dados do item [1] FILIAL / [2] CDTPDC/ [3] EMISDC / [4] SERDC / [5] NRDC / [6] SEQ / [7] ITEM / [8] Rateio? / [9] VALOR FATOR */
	
	dbSelectArea("GW1")
	dbsetorder(1)
	If dbseek(aChaveGW1[1] + aChaveGW1[2] + aChaveGW1[3] + aChaveGW1[4] + aChaveGW1[5])
		While !GW1->(EOF()) .AND. GW1->GW1_FILIAL = aChaveGW1[1] ;
							.AND. GW1->GW1_CDTPDC = aChaveGW1[2] ;
							.AND. GW1->GW1_EMISDC = aChaveGW1[3] ;
							.AND. GW1->GW1_SERDC  = aChaveGW1[4] ;
							.AND. GW1->GW1_NRDC   = aChaveGW1[5]
			   
				dbSelectArea("GW8")
				dbsetorder(1)
				dbseek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
				While !GW8->(EOF()) .AND. GW8->GW8_FILIAL = GW1->GW1_FILIAL ;
									.AND. GW8->GW8_CDTPDC = GW1->GW1_CDTPDC ;
									.AND. GW8->GW8_EMISDC = GW1->GW1_EMISDC ;
									.AND. GW8->GW8_SERDC  = GW1->GW1_SERDC ;
									.AND. GW8->GW8_NRDC   = GW1->GW1_NRDC
					   
					aItem := Array(19)
					   
					aItem[1] := GW8->GW8_FILIAL
					aItem[2] := GW8->GW8_CDTPDC
					aItem[3] := GW8->GW8_EMISDC
					aItem[4] := GW8->GW8_SERDC
					aItem[5] := GW8->GW8_NRDC
					aItem[6] := GW8->GW8_SEQ
					aItem[7] := GW8->GW8_ITEM
					aItem[8] := GW8->GW8_RATEIO
						
					nFatorItem  := 0
					DO CASE
						CASE cCriterio == "1" //peso
							nFatorItem  := GW8->GW8_PESOR
						CASE cCriterio == "2" //Valor
							nFatorItem  := GW8->GW8_VALOR
						CASE cCriterio == "3" //Volume (M3)
							nFatorItem  := GW8->GW8_VOLUME
						CASE cCriterio == "4" //Quantidade
							nFatorItem  := GW8->GW8_QTDE
					EndCase
						
					aItem[9] := nFatorItem
						
					aADD(aItens, aItem)
					dbSelectArea("GW8")
					GW8->(dbSkip())
				EndDo
			dbSelectArea("GW1")
			GW1->(dbSkip())
		EndDo
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44CHK

Função para cancelar ou excluir ocorrencias em lote conforme filtro informado e dados marcados

@author Jefferson Hita
@since 08/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA032LOT()
	Local oDlg
	Local oPnlA
	Local oPnlB
	Local aCores    := {}
	Local aGWD      := Nil
	Local aCpGWD    := Nil
	Local cCadastro := "Cancelamento e Exclusão de Ocorrências em Lote"
	Local nAlt      := GetScreenRes()[2]
	Local nLrg      := GetScreenRes()[1]
	Local aNewButton:= {}

	Private oMark
	Private cAliGWD   := Nil
	Private cOperacao := ""
	Private cMarca    := GetMark()

	nAlt -= (nAlt - 1100) * 80 / 100

	// Pergunte Cancelar/Excluir Ocorrências em Lote
	If Pergunte("GFEA032LOT",.T.)  
		Do Case
		Case MV_PAR04 == 1
			cOperacao := "1 - Cancelar"
		Case MV_PAR04 == 2
			cOperacao := "2 - Excluir"
		OtherWise
			cOperacao := "3 - Ambos"
		EndCase

		Aadd(aNewButton, {"Parâmetros" ,{||RepPerg032()},"Parâmetros","Parâmetros"})

		//----------------------------------------------
		// Criacao da tabela temporaria p/ Markbrowse
		//----------------------------------------------
		aGWD := {{"OK"     , "C", 02                     , 0},;
			{"FILIAL" , "C", TamSX3("GWD_FILIAL")[1], 0},;
			{"OCORREN", "C", TamSX3("GWD_NROCO")[1]   , 0},;
			{"TRANSP" , "C", TamSX3("GWD_CDTRP")[1] , 0},;
			{"NMTRP"  , "C", TamSX3("GU3_NMEMIT")[1] , 0},;
			{"DESCRIC", "C", TamSX3("GWD_DSOCOR")[1] , 0},;
			{"TIPO"   , "C", TamSX3("GWD_CDTIPO")[1] + TamSX3("GU5_DESC")[1], 0},;
			{"MOTIVO" , "C", TamSX3("GWD_CDMOT")[1] + TamSX3("GU6_DESC")[1], 0},;
			{"DTCRIA" , "D", TamSX3("GWD_DTCRIA")[1], 0},;
			{"HRCRIA" , "C", TamSX3("GWD_HRCRIA")[1], 0},;
			{"SIT"    , "C", 12   , 0},;
			{"RECNUM" , "N", 10, 0}}

		aCpGWD := {{"OK"     , Nil, " ",""},;
			{"FILIAL" , Nil, "Filial","@!"},;
			{"OCORREN", Nil, "Ocorrência","@!"},;
			{"TRANSP" , Nil, "Transportador","@!"},;
			{"NMTRP"  , Nil, "Nome","@!"},;
			{"DESCRIC", Nil, "Descrição","@!"},;
			{"TIPO"   , Nil, "Tipo","@!"},;
			{"MOTIVO" , Nil, "Motivo","@!"},;
			{"DTCRIA" , Nil, "Data Criação",""},;
			{"HRCRIA" , Nil, "Hora Criação","@!"},;
			{"SIT"    , Nil, "Situação","@!"}}

		cAliGWD := GFECriaTab({aGWD, {"FILIAL+OCORREN"}})

		CursorWait()

		Processa({|lEnd| GFE032Load()}, "Filtrando ocorrências...", "Aguarde")

		dbSelectArea(cAliGWD)
		dbSetOrder(1)
		dbGoTop()

		//--------------------------
		// Montagem da tela
		//--------------------------
		Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Color CLR_BLACK,RGB(225,225,225) Pixel Of oMainWnd
		oDlg:lEscClose := .F.

		oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
		oPnlA:Align := CONTROL_ALIGN_TOP

		oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
		oPnlB:Align := CONTROL_ALIGN_ALLCLIENT
		
		@ 07,10  Say "Transportador: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 05,63  MsGet MV_PAR01 Picture "@!" SIZE 50,7 When .F. Pixel Of oPnlA
		@ 07,180 Say "Dt Criação De: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 05,220 MsGet MV_PAR02 Picture "99/99/9999" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA
		@ 07,310 Say "Dt Criação Até: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 05,350 MsGet MV_PAR03 Picture "99/99/9999" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA
		@ 07,440 Say "Operação: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 05,480 MsGet cOperacao Picture "@!" SIZE 50,7 When .F. Hasbutton Pixel Of oPnlA

		@ 23,10 Say "Num da NF De: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 21,63 MsGet MV_PAR05 Picture "@!" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA
		@ 23,180 Say "Num da NF Até: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 21,220 MsGet MV_PAR06 Picture "@!" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA
		@ 23,310 Say "Ocorrência De: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 21,350 MsGet MV_PAR07 Picture "@!" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA
		@ 23,440 Say "Ocorrência Até: " COLOR CLR_BLACK Pixel Of oPnlA
		@ 21,480 MsGet MV_PAR08 Picture "@!" SIZE 50,7  When .F. Hasbutton Pixel Of oPnlA

		oMark := MsSelect():New(cAliGWD, "OK", , aCpGWD, , @cMarca, {0,0,0,0}, , , oPnlB,,aCores)
		oMark:oBrowse:bLDblClick := {|| GFE032CHK(.F.) }
		oMark:oBrowse:cToolTip := "Cancelar/Excluir"
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:bAllMark :=  {|| GFE032CHK(.T.)}

		CursorArrow()

		Activate MsDialog oDlg ON Init EnchoiceBar(ODlg, {|| If(GFE032LOTE(), ODlg:End(), NIL)},;
				{|| If(APMSGYESNO("Deseja cancelar esse processo?"), ODlg:End(),)},,aNewButton) CENTERED

		GFEDelTab(cAliGWD)
	Else 
		MsgAlert("Realize o cadastro do Pergunte (GFEA032LOT) antes de seguir com a exclusão em lote!")
		Return
	EndIf 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RepPerg032

Função para realizar o reprocessamento do Pergunte através do botão em Outras Ações

@author Philippe Rocca
@since 16/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RepPerg032()
	// Pergunte Cancelar/Excluir Ocorrências em Lote
	Pergunte("GFEA032LOT",.T.)

	Do Case
	Case MV_PAR04 == 1
		cOperacao := "1 - Cancelar"
	Case MV_PAR04 == 2
		cOperacao := "2 - Excluir"
	OtherWise
		cOperacao := "3 - Ambos"
	EndCase

	Processa({|lEnd| GFE032Load()}, "Filtrando ocorrências...", "Aguarde")

	dbSelectArea(cAliGWD)
	dbSetOrder(1)
	dbGoTop()
Return

Static Function GFE032CHK(lMarkAll)
	Default lMarkAll := .F.

	If lMarkAll
		(cAliGWD)->(dbGoTop())
		Do While (cAliGWD)->(!Eof())
			RecLock(cAliGWD, .F.)
			If ((cAliGWD)->OK <> cMarca)
				(cAliGWD)->OK := cMarca
			Else
				(cAliGWD)->OK := " "
			EndIf
			(cAliGWD)->(MsUnlock())
			(cAliGWD)->(dbSkip())
		EndDo
		(cAliGWD)->(DbGoTop())
	Else
		RecLock((cAliGWD), .F.)
		(cAliGWD)->OK := If(IsMark('OK', cMarca), "  ", cMarca)
		(cAliGWD)->(MsUnLock())
	EndIf
	(cAliGWD)->(DbGoTop())
	oMark:oBrowse:Refresh(.T.)
Return

Static Function GFE032Load()
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local oQry

	DbSelectArea(cAliGWD)
	ZAP

	If MV_PAR04 == 1	// Cancelar
		cWhere := " AND GWD_SIT != '1'"
	EndIf
	If MV_PAR04 == 2	// Excluir
		cWhere := "AND GWD_SIT == '1'"
	EndIf
	
	cQuery := "SELECT DISTINCT 
	cQuery += "GWD_FILIAL,"
	cQuery += "GWD_NROCO,"
	cQuery += "GWD_CDTRP,"
	cQuery += "GWD_DSOCOR,"
	cQuery += "GWD_CDTIPO,"
	cQuery += "GWD_CDMOT,"
	cQuery += "GWD_DTCRIA,"
	cQuery += "GWD_HRCRIA,"
	cQuery += "GWD_SIT,"
	cQuery += "GWD.R_E_C_N_O_ AS RECNUM"
	cQuery += " FROM " + RetSqlName("GWD") + " GWD"
	cQuery += " INNER JOIN " + RetSqlName("GWL") + " GWL"
	cQuery += " ON GWL.GWL_FILIAL = '" + xFilial("GWD") + "'"
	cQuery += " AND GWL.GWL_NROCO = GWD.GWD_NROCO
	cQuery += " AND GWL.D_E_L_E_T_ = ''"
	cQuery += " WHERE GWD.GWD_FILIAL = ?"
	cQuery += "	AND GWD.GWD_CDTRP = ?"
	cQuery += "	AND GWD.GWD_DTCRIA BETWEEN ? AND ?"
	cQuery += "	AND GWD.GWD_NROCO BETWEEN ? AND ? "
	cQuery += "	AND GWL.GWL_NRDC BETWEEN ? AND ?"
	cQuery += "	AND GWD.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY GWD_FILIAL, GWD_NROCO, GWD_CDTRP"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery) 
	oQry:SetNumeric(1,xFilial("GWD"))
	oQry:SetString(2,MV_PAR01)
	oQry:SetString(3,DToS(MV_PAR02))
	oQry:SetString(4,DToS(MV_PAR03))
	oQry:SetString(5,MV_PAR07)
	oQry:SetString(6,MV_PAR08)
	oQry:SetString(7,MV_PAR05)
	oQry:SetString(8,MV_PAR06)
	cAliasQry := oQry:OpenAlias()	

	While (cAliasQry)->(!Eof())
		RecLock((cAliGWD),.T.)
		(cAliGWD)->OK      := cMarca
		(cAliGWD)->FILIAL  := (cAliasQry)->GWD_FILIAL
		(cAliGWD)->OCORREN := (cAliasQry)->GWD_NROCO
		(cAliGWD)->TRANSP  := (cAliasQry)->GWD_CDTRP
		(cAliGWD)->NMTRP   := Posicione("GU3", 1, xFilial("GU3") + (cAliasQry)->GWD_CDTRP, "GU3_NMEMIT")
		(cAliGWD)->DESCRIC := Alltrim((cAliasQry)->GWD_DSOCOR)
		(cAliGWD)->TIPO    := Alltrim((cAliasQry)->GWD_CDTIPO) + " - " + Alltrim(Posicione("GU5", 1, xFilial("GU5") + (cAliasQry)->GWD_CDTIPO, "GU5_DESC"))
		(cAliGWD)->MOTIVO  := Alltrim((cAliasQry)->GWD_CDMOT) + " - " + Alltrim(Posicione("GU6", 1, xFilial("GU6") + (cAliasQry)->GWD_CDMOT, "GU6_DESC"))
		(cAliGWD)->DTCRIA  := StoD((cAliasQry)->GWD_DTCRIA)
		(cAliGWD)->HRCRIA  := (cAliasQry)->GWD_HRCRIA
		(cAliGWD)->SIT     := (cAliasQry)->GWD_SIT + " - " + IIF((cAliasQry)->GWD_SIT=='1', "Pendente",	IIf((cAliasQry)->GWD_SIT=='2', "Aprovada", "Reprovada"))
		(cAliGWD)->RECNUM  := (cAliasQry)->RECNUM
		(cAliGWD)->(MsUnlock())
		(cAliasQry)->(DbSkip())

	EndDo
	(cAliasQry)->(DbCloseArea())

Return .T.

Static Function GFE032LOTE()
	Local nX         := 0
	Local nY         := 0
	Local lRet       := .T.
	Local aRet       := Nil

	Private nCount   := 0
	Private aMsgProc := {}
	Private oVwProc  := GFEViewProc():New()

	MV_PAR04 := cValToChar(MV_PAR04)

	(cAliGWD)->(dbGoToP())
	If !(cAliGWD)->(Eof())
		While (cAliGWD)->(!Eof())
			If (cAliGWD)->OK == cMarca
				nCount++

				GWD->(DbGoTo((cAliGWD)->RECNUM))
				// Cancelar
				If MV_PAR04 $ "1;3" .And. GWD->GWD_SIT != "1"
					aRet := GFEA032CAN()
					If !Empty(aRet) .And. !aRet[1]
						aAdd(aMsgProc, { nCount,;
							"Falha no cancelamento da ocorrência Filial/Nr Ocorr: " + Alltrim(GWD->GWD_FILIAL) +"/"+ Alltrim(GWD->GWD_NROCO) + CRLF +;
							"Mensagem: " + aRet[2]})
					EndIf
				ElseIf MV_PAR04 $ "1;3" .And. GWD->GWD_SIT == "1"
					aAdd(aMsgProc, { nCount,;
						"Falha no cancelamento da ocorrência Filial/Nr Ocorr: " + Alltrim(GWD->GWD_FILIAL) +"/"+ Alltrim(GWD->GWD_NROCO) + CRLF +;
						"Mensagem: Somente é permitido cancelar ocorrências que estejam aprovadas." + CRLF})
				EndIf

				// Excluir
				If MV_PAR04 $ "2;3" .And. GWD->GWD_SIT == "1"
					GFEA032DEL()
				ElseIf MV_PAR04 $ "2;3" .And. GWD->GWD_SIT != "1"
					aAdd(aMsgProc, { nCount,;
						"Falha na exclusão da ocorrência Filial/Nr Ocorr: " + Alltrim(GWD->GWD_FILIAL) +"/"+ Alltrim(GWD->GWD_NROCO) + CRLF +;
						"Mensagem: Somente é permitido excluir ocorrências que não possuam aprovações. Realize o cancelamento da aprovação antes de tentar excluir." + CRLF})
				EndIf
			EndIf

			(cAliGWD)->(DbSkip())
		EndDo

		// Processamento da mensagens da rotina
		CursorArrow()
		For nX := 1 To Len(aMsgProc)
			If nY != aMsgProc[nX,1]
				nY := aMsgProc[nX,1]
				oVwProc:AddErro( "Erro(s) no registro " + cValToChar(nY) + ": " + aMsgProc[nX,2] )
			EndIf
		Next nX

		If Len(aMsgProc) == 0
			oVwProc:Add("")
			oVwProc:Add("As ocorrencias selecionadas foram processadas com sucesso!")
		EndIf
		oVwProc:Show("Cancelar/Excluir em Lote", "Ocorrências", "Erros", "Um ou mais registros não foram cancelados/excluídos com sucesso. Clique em 'Erros' para mais detalhes.")
	EndIf
	FreeObj(oVwProc)
Return lRet
