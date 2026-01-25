#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFES003
Garação de arquivo .txt de ocorrencia para testes importação EDI


@author Ana Claudia da Silva
@since 07/10/13
@version 1.0

// TODO: Não identificado nenhum Componente do Modelo
/*/
//-------------------------------------------------------------------

Static _lGWL_SEQ := GFXCP12125("GWL_SEQ")

User Function GFES003()
	Local oBrowse
	
	Private cAliGWU
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWD") // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFES003") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Registrar Ocorrência") //"Registrar Ocorrência"
	
	oBrowse:AddLegend("GWD_SIT=='1'", "BLUE", "Pendente" ) //"Pendente"
	oBrowse:AddLegend("GWD_SIT=='2'", "GREEN" , "Aprovada" ) //"Aprovada"
	oBrowse:AddLegend("GWD_SIT=='3'", "RED"   , "Reprovada") //"Reprovada"
	oBrowse:Activate()
	
	If !Empty(Select(cAliGWU))
		GFEDelTab(cAliGWU)
	EndIf
Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Gerar .Txt (340)"      ACTION "GFES03TXT(1)" OPERATION 11 ACCESS 0
	ADD OPTION aRotina TITLE "Gerar .Txt (540)"      ACTION "GFES03TXT(2)" OPERATION 11 ACCESS 0
	ADD OPTION aRotina TITLE "Gerar .Txt (TOTVSOCT)" ACTION "GFES03TXT(3)" OPERATION 11 ACCESS 0
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//
// FIXME: Refatorar para utilizar a GWD como base do modeL
Static Function ModelDef()
	Local oModel
	Local oStructGWD := FWFormStruct(1, "GWD")
	Local oStructGWL := FWFormStruct(1, "GWL")

	// Incluindo campo de Sequência para o Trecho
	If !_lGWL_SEQ
		oStructGWL:AddField ("Sequência Trecho", "Sequência Trecho", "GWL_SEQ", "C", TamSX3("GWU_SEQ")[1], 0/*nDECIMAL*/, /*bVALID*/, {||.T.}/*bWHEN*/, /*@aVALUES*/, .F., /*bINIT*/, .F./*lKEY*/, /*lNOUPD*/, .T./*lVIRTUAL*/)
	EndIf	

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFES003", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFES003_GWD", Nil, oStructGWD, /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:AddGrid("GFES003_GWL","GFES003_GWD", oStructGWL,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation("GFES003_GWL",{{"GWL_FILIAL",'xFilial("GWD")'},{"GWL_NROCO","GWD_NROCO"}},"GWL_FILIAL+GWL_NROCO")

	oModel:SetPrimaryKey({"GWD_FILIAL", "GWD_NROCO"})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
// FIXME: Refatorar para utilizar a GWD como base do modeL
Static Function ViewDef()
	Local oModel      := FWLoadModel("GFES003")
	Local oStructGWD  := FWFormStruct(2, "GWD")

	// Static nValorTot  := 0
	// Static oBrwGWU    := Nil
	// Static cFilGWU    := Nil
	// Static oViewOco   := NIL
	// Static cGWUFil    := GetNextAlias()
	// Static nBrwGWUEve := 0 //Auxiliar para "adivinhar" se o usuário pressionou botão "Salvar" ou "Salvar e Criar novo" 
 	// Static lFuncSLC   := .F.
	// Static lPergSLC   := .F.

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

	// If IsInCallStack("GFEA044") .Or. IsInCallStack("GFEC041") .Or. IsInCallStack("GFEC054")
	// 	oStructGWD:SetProperty("GWD_CDTRP", MVC_VIEW_CANCHANGE, .F.)
	// EndIf

	oViewOco := FWFormView():New()

	oViewOco:SetModel(oModel)

	oViewOco:AddField("GFES003_GWD", oStructGWD, /*cLinkID*/)

	// oViewOco:AddOtherObject("GFES003_GWL", {|oPanel, oObj| GFEA032GWL(oPanel, oObj)},,{|oPanel| oBrwGWU:Refresh()})

	// oViewOco:SetFieldAction("GWD_CDTRP", {|oView, cIdView, cField, cValue| GFEA32LOAD(oView, cValue, .T.)})

	oViewOco:CreateHorizontalBox("MASTER", 55)
	oViewOco:CreateHorizontalBox("DETAILGWL", 45)

	oViewOco:SetOwnerView("GFES003_GWD", "MASTER")
	oViewOco:SetOwnerView("GFES003_GWL", "DETAILGWL")	
	// oViewOco:SetAfterOkButton({|oView| GFEA032ASav()})
	// oViewOco:SetViewAction("BUTTONOK", {|oView| GFEA032Sav()})
	// oViewOco:SetViewAction("BUTTONCANCEL", {|oView| GFEA032Fec()})
	
	// oViewOco:AddUserButton(STR0012, 'GCTIMG32', {|oView| GFEADCOK(oView)}) //"Doc. Relac."
Return oViewOco

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES03TXT
Montagem de arquivo .txt com base nos parametros do fonte GFES003

GWD - Ocorrências
GWL - Doc Cargas X Ocorrências

@author Ana Claudia da Silva
@since 03/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFES03TXT(nOpcao)
	Local lRet        := .T.
	Local aGWD_PESO   := TamSx3("GWD_PESO")
	Local aGWD_QTDVOL := TamSx3("GWD_QTDVOL")
	Local aGWD_QTPERN := TamSx3("GWD_QTPERN")
	Local aGWD_VALIND := TamSx3("GWD_VALIND")
	Local cAliasQry   := Nil
	Local cCampos     := ""
	Local cFile       := ""
	Local cNrOco      := ""
	Local cCdTrp      := ""
	Local cNmTrp      := ""
	Local cDsOcor     := ""
	Local cData       := ""
	Local cHrMn       := ""
	Local cDataD      := ""
	Local cDataM      := ""
	Local cDataA      := ""
	Local cDataA1     := ""
	Local cTpOco      := ""
	Local cMtOco      := ""
	Local cChvExt     := ""
	Local cCdEmit     := ""
	Local cNmEmit     := ""
	Local cSrNf       := ""
	Local cNrNf       := ""
	Local cSeq        := ""
	Local cNmRem      := ""
	Local cNmDest     := ""
	Local cObs        := ""
	Local cCdRec      := ""
	Local cEvenTr     := ""
	Local cNmCont     := ""
	Local cPrestServ  := ""
	Local cLayout     := ""
	Local nH          := 0
	Local nPesoEnt    := 0
	Local nQtdVol     := 0
	Local nQtdServ    := 0
	Local nValInd     := 0
	
	Private cNomeArq  := ""

	If Pergunte("GFEA117",.T.)
	
		cCampos += IIf(GFXCP12130("GWD_URLENT"), "' ' GWD_URLENT,","GWD.GWD_URLENT GWD_URLENT,")
		cCampos := "%"+cCampos+"%"

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GWD.GWD_NROCO,
					GWD.GWD_DTOCOR,
					GWD.GWD_HROCOR,
					GWD.GWD_CDTIPO,
					GWD.GWD_CDMOT,
					GWD.GWD_CHVEXT,
					GWL.GWL_SERDC,
					GWL.GWL_NRDC,
					GWL.GWL_SEQ,
					GWD.GWD_DSOCOR,
					GWD.GWD_NMCONT,
					GWD.GWD_PRESTS,
					GWD.GWD_PESO,
					GWD.GWD_QTDVOL,
					GWD.GWD_QTPERN,
					GWD.GWD_VALIND,
					GWD.GWD_CDREC,
					%Exp:cCampos%
					GU3A.GU3_IDFED GWD_IDFED,
					GU3A.GU3_NMEMIT GWD_NMEMIT,
					GU5.GU5_DESC,
					GU3B.GU3_IDFED GWL_IDFED,
					GU3B.GU3_NMEMIT GWL_NMEMIT,
					GU3C.GU3_NMEMIT GW1_NMREM,
					GU3D.GU3_NMEMIT GW1_NMDEST
			FROM %Table:GWL% GWL
			INNER JOIN %Table:GWD% GWD
			ON GWD.GWD_FILIAL = %xFilial:GWD%
			AND GWD.GWD_NROCO = GWL.GWL_NROCO
			AND GWD.%NotDel%
			LEFT JOIN %Table:GU3% GU3A
			ON GU3A.GU3_FILIAL = %xFilial:GU3%
			AND GU3A.GU3_CDEMIT = GWD.GWD_CDTRP
			AND GU3A.%NotDel%
			LEFT JOIN %Table:GU5% GU5
			ON GU5.GU5_FILIAL = %xFilial:GU5%
			AND GU5.GU5_CDTIPO = GWD.GWD_CDTIPO
			AND GU5.%NotDel%
			INNER JOIN %Table:GW1% GW1
			ON GW1.GW1_FILIAL = GWL.GWL_FILDC
			AND GW1.GW1_CDTPDC = GWL.GWL_TPDC
			AND GW1.GW1_EMISDC = GWL.GWL_EMITDC
			AND GW1.GW1_SERDC = GWL.GWL_SERDC
			AND GW1.GW1_NRDC = GWL.GWL_NRDC
			AND GW1.%NotDel%
			LEFT JOIN %Table:GU3% GU3B
			ON GU3B.GU3_FILIAL = %xFilial:GU3%
			AND GU3B.GU3_CDEMIT = GWL.GWL_EMITDC
			AND GU3B.%NotDel%
			LEFT JOIN %Table:GU3% GU3C
			ON GU3C.GU3_FILIAL = %xFilial:GU3%
			AND GU3C.GU3_CDEMIT = GW1.GW1_CDREM
			AND GU3C.%NotDel%
			LEFT JOIN %Table:GU3% GU3D
			ON GU3D.GU3_FILIAL = %xFilial:GU3%
			AND GU3D.GU3_CDEMIT = GW1.GW1_CDDEST
			AND GU3D.%NotDel%
			WHERE GWL.GWL_FILIAL = %xFilial:GWL%
			AND GWL.GWL_NROCO = %Exp:GWD->GWD_NROCO%
			AND GWL.%NotDel%
		EndSql
		TCSetField(cAliasQry,'GWD_DTOCOR','D')
		TCSetField(cAliasQry,'GWD_PESO'  ,'N',aGWD_PESO[1]  ,aGWD_PESO[2])
		TCSetField(cAliasQry,'GWD_QTDVOL','N',aGWD_QTDVOL[1],aGWD_QTDVOL[2])
		TCSetField(cAliasQry,'GWD_QTPERN','N',aGWD_QTPERN[1],aGWD_QTPERN[2])
		TCSetField(cAliasQry,'GWD_VALIND','N',aGWD_VALIND[1],aGWD_VALIND[2])
		If (cAliasQry)->(!Eof())
			cLayout    := IIf(nOpcao == 1,"_340",IIf(nOpcao == 2,"_540","_TOTVSOCT"))
			cNrOco     := (cAliasQry)->GWD_NROCO
			cCdTrp     := (cAliasQry)->GWD_IDFED
			cNmTrp     := (cAliasQry)->GWD_NMEMIT
			cDsOcor    := (cAliasQry)->GU5_DESC
			cData      := DToC((cAliasQry)->GWD_DTOCOR)
			cHrMn      := StrTran((cAliasQry)->GWD_HROCOR, ":", "")
			cDataD     := SubStr(cData,1,2)
			cDataM     := SubStr(cData,4,2)
			cDataA     := SubStr(cData,9,2)
			cDataA1    := SubStr(cData,7,4)
			cTpOco     := IIf(nOpcao == 3,(cAliasQry)->GWD_CDTIPO,StrZero(val((cAliasQry)->GWD_CDTIPO),2,0))
			cMtOco     := IIf(nOpcao == 3,(cAliasQry)->GWD_CDMOT ,StrZero(val((cAliasQry)->GWD_CDMOT),2,0))
			cChvExt    := (cAliasQry)->GWD_CHVEXT
			cCdEmit    := (cAliasQry)->GWL_IDFED
			cNmEmit    := (cAliasQry)->GWL_NMEMIT
			cSrNf      := (cAliasQry)->GWL_SERDC
			cNrNf      := (cAliasQry)->GWL_NRDC
			cSeq       := StrZero(val((cAliasQry)->GWL_SEQ),1,0)
			cNmRem     := (cAliasQry)->GW1_NMREM
			cNmDest    := (cAliasQry)->GW1_NMDEST
			cObs       := (cAliasQry)->GWD_DSOCOR
			cCdRec     := (cAliasQry)->GWD_CDREC
			cEvenTr    := (cAliasQry)->GWD_URLENT
			cNmCont    := (cAliasQry)->GWD_NMCONT
			cPrestServ := (cAliasQry)->GWD_PRESTS
			nPesoEnt   := (cAliasQry)->GWD_PESO
			nQtdVol    := (cAliasQry)->GWD_QTDVOL
			nQtdServ   := (cAliasQry)->GWD_QTPERN
			nValInd    := (cAliasQry)->GWD_VALIND
			
			cDiretorio := AllTrim(MV_PAR04)
			cFile      := cDiretorio + "\"+ "Ocor"+AllTrim(cNrOco)+cLayout+".TXT"

			nH := fCreate(cFile)
			If nH == -1
				MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
				lRet := .F.
			Else
				If nOpcao == 1
					fWrite(nH,"000"+;
								PADR(cNmRem,35)+;
								PADR(cNmDest,35)+;
								PADR(cDataD,2)+;
								PADR(cDataM,2)+;
								PADR(cDataA,2)+;
								PADR(cHrMn,4)+;
								"OCO"+;
								PADR(cDataD,2)+;
								PADR(cDataM,2)+;
								PADR(cHrMn,4)+;
								"0"+;
								CRLF)
							
					fWrite(nH,"340"+;
								"OCORR"+;
								PADR(cDataD,2)+;
								PADR(cDataM,2)+;
								PADR(cHrMn,4)+;
								"0"+;
								CRLF )
								
					fWrite(nH,"341"+;
								PADR(cCdTrp,14)+;
								PADR(cNmTrp,40)+;
								CRLF )
								
					fWrite(nH,"342"+;
								PADR(cCdEmit,14)+;
								PADR(cSrNf,3)+;
								PADR(cNrNf,8)+;
								PADR(cMtOco,2)+;
								PADR(cDataD,2)+;
								PADR(cDataM,2)+;
								PADR(cDataA1,4)+;
								PADR(cHrMn,4)+;
								PADR(cMtOco,2)+;
								PADR(cDsOcor,45))
		
					fClose(nH)
				ElseIf nOpcao == 2
					fWrite(nH,"000"+ ;                                          // TAG 000
								PADR(cNmRem,35)+;                               // Nome Remetente
								PADR(cNmDest,35)+;                              // Nome Destinatário
								PADR(cDataD,2)+PADR(cDataM,2)+PADR(cDataA,2)+;  // DDMMAA (Data)
								PADR(cHrMn,4)+;                                 // HHMM (Hora)
								"OCO50"+PADR(cDataD,2)+PADR(cDataM,2)+"000"+;   // Identificação ("OCO50"+ DDMM + SSS)
								CRLF)
							
					fWrite(nH,"540"+;                                           // TAG 540
								"OCORR50"+PADR(cDataD,2)+PADR(cDataM,2)+"000"+; // Identificação ("CORR50"+ DDMM + SSS)
								CRLF)
								
					fWrite(nH,"541"+;                                           // TAG 541 
								PADR(cCdTrp,14)+;                               // CNPJ Embarcador
								PADR(cNmTrp,50)+;                               // Nome Embarcador
								CRLF )
					fWrite(nH,"542"+;                                           // TAG 542
								PADR(cCdEmit,14)+;                              // Cnpj do embarcador
								PADR(cSrNf,3)+;                                 // Série da nota-fiscal
								PADR(cNrNf,9)+;                                 // número da nota-fiscal
								PADR(cMtOco,3)+;                                // código da ocorrência
								PADR(cDataD,2)+PADR(cDataM,2)+PADR(cDataA1,4)+; // DDMMAAAA
								PADR(cHrMn,4))                                  // HHMM
		
					fClose(nH)
				ElseIf nOpcao = 3
					fWrite(nH,"TOTVSOCT;"+;                  // Identificador de Layout
								"01;"+;                      // Identificador de registro
								"100;"+;                     // Versão do Layout
								cCdEmit+";"+;                // CNPJ Embarcador
								cCdTrp+";"+;                 // CNPJ Transportador
								cChvExt+";"+;                // Chave NF-e
								cCdEmit+";"+;                // CNPJ Emissor NF
								cSrNf+";"+;                  // Serie NF
								cNrNf+";"+;                  // Numero NF
								cData+";"+;                  // Data Emissão NF
								cSeq+";"+;                   // Trecho
								' ;'+;                       // Evento
								cData+";"+;                  // Data Ocorrência
								cHrMn+";"+;                  // Hora Ocorrência
								cTpOco+";"+;                 // Código Tipo Ocorrência
								cMtOco+";"+;                 // Código Motivo Ocorrência
								cValToChar(nPesoEnt)+";"+;   // Peso Entrega em KG
								cValToChar(nQtdVol)+";"+;    // Quantidade Entrega
								cPrestServ+";"+;             // CNPJ Prestador Serviço
								cValToChar(nQtdServ)+";"+;   // Quantidade Servico
								' ;'+;                       // Valor Total Adicional - (Campos que não têm correspondente na tabela Ocorrências)
								cValToChar(nValInd)+";"+;    // Valor Indenização
								cObs+";"+;                   // Descrição Breve
								' ;'+;                       // Descrição Longa
								cNmCont+";"+;                // Nome Contato
								cCdRec+";"+;                 // CNPJ/CPF/RG Recebedor
								' ;'+;                       // Nome Recebedor - (Campos que não têm correspondente na tabela Ocorrências)
								cEvenTr)                     // Link de evidencia de entrega realizada
					fClose(nH)
				EndIf
				Msginfo("Arquivo criado :" + cFile)
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet
