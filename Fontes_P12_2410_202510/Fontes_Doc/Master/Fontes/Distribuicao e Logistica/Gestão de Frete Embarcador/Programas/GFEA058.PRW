#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 

#DEFINE CPESO 1
#DEFINE CVAL  2
#DEFINE CVOL  3
#DEFINE CQTDE 4

Function GFEA058() 
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWP")
	oBrowse:SetDescription("Viagens")
	oBrowse:SetMenuDef("GFEA058") 
	oBrowse:AddLegend("GWP_SIT == '1'", "GREEN" ,"Aberta")
	oBrowse:AddLegend("GWP_SIT == '2'", "RED"   ,"Encerrada")
	oBrowse:Activate()
	
Return

Function GFEA058BRE()
	If GWP->GWP_SIT == '1'
		GfeMsgErro("Viagem já está aberta")
	Else
		RecLock("GWP",.F.)
		GWP->GWP_SIT := "1"
		GWP->GWP_DTPART := STOD(Space(8))
		GWP->GWP_HRPART := ""
		msUnlock()
	EndIf
Return

Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE	   "Pesquisar"			ACTION "AxPesqui"        OPERATION  1 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Visualizar"			ACTION "VIEWDEF.GFEC058" OPERATION  2 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Incluir"			ACTION "VIEWDEF.GFEA058" OPERATION  3 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Alterar"			ACTION "VIEWDEF.GFEA058" OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Excluir"			ACTION "VIEWDEF.GFEA058" OPERATION  5 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Reabrir"			ACTION "GFEA058BRE()"      OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Romaneios"			ACTION "GFEA058B()"      OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Partida Viagem"		ACTION "GFEA58PVIA()"    OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE       "Calcular Romaneios"	ACTION "GFEA58CVIA()"    OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE       "Liberar  Romaneios"	ACTION "GFEA58LVIA()"    OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Imprimir"			ACTION "VIEWDEF.GFEA058" OPERATION  8 ACCESS 0
	
Return aRotina

Static Function ModelDef()
	Local oModel := MPFormModel():New("GFEA058", /*bPre*/, { |oX| GFEA058POS( oX ) } /*bPost*/, {|oX|GFEA058CMT(oX)}/*bCommit*/, /*bCancel*/)
	Local oStructGWP := FWFormStruct(1,"GWP")
	oModel:AddFields("GFEA058_GWP", Nil, oStructGWP,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWP_FILIAL", "GWP_VIAGEM"})
	oModel:SetVldActivate({|oModel| GFEA58VLD(oModel)})
	oModel:SetDescription("Viagens")
	oModel:GetModel("GFEA058_GWP"):SetDescription("Viagens")
Return oModel

Function GFE58DVGS(cViagem,cMot)

	dbSelectArea('GWN')
	GWN->(dbOrderNickName('VIAGEM'))
	GWN->(dbSeek(cViagem))
	While !GWN->(Eof()) .And. GWN->GWN_VIAGEM == cViagem
		GFE58DVG(cMot)
		GWN->(dbSkip())
	EndDo
Return

Function GFE58DVG(cMot)

		RecLock("GWN", .F.)
			GWN->GWN_CALC := "4"
			GWN->GWN_MTCALC := cMot
			GWN->GWN_DTCALC := CToD("  /  /    ")
			GWN->GWN_HRCALC := ""
			GWN->GWN_VIAGEM := ''
			GWN->GWN_CPESO := 0
			GWN->GWN_CVAL := 0
			GWN->GWN_CVOL := 0
			GWN->GWN_CQTDE := 0
		MsUnLock("GWN")
Return

Function GFE58ATDP(oModel)
	Local aArea := GetArea()
	Local cViagem := ""
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cViagem := oModel:GetModel("GFEA058_GWP"):GetValue('GWP_VIAGEM')
		GFE58DVGS(cViagem,"A viagem relacionada foi excluída.")
	EndIf
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} GFE58ATVG
	Atualiza os romaneios relacionados a viagem
	Romaneio que disparou deve estar posicionado
	Romaneio ja deve estar gravado.
@author siegklenes.beulke
@since 21/06/2016
@version 1.0
@param cViagem, characters, nova viagem
@param cCALC, characters, situação
@param cMTCALC, characters, campo MTCALC
@param dDTCALC, date, data do calculo
@param cHRCALC, characters, hora do calculo
@param cFil, characters, filial do romaneio que disparou
@param cNrRom, characters, número do romaneio que disparou
@param lAtuPeso, logic, se atualiza o peso de outras viagens
@param cViagAnt, characters, viagem anterior
@example
(examples)
@see (links_or_references)
/*/
Function GFE58ATVG(cViagem,cCALC,cMTCALC,dDTCALC,cHRCALC,cFil,cNrRom,lAtuPeso,cViagAnt)
	Local aArea := GetArea()
	Local aAreaGWN := GWN->(GetArea())
	Local aQtdes := {}
	Local cFilBkp := cFilAnt
	Default lAtuPeso := .F.
	
	If cViagAnt != Nil //troca de viagem, talvez
	
		If Empty(cViagAnt) .And. !Empty(cViagem) //Vinculo de romaneio sem viagem
			
			aQtdes := GFE58OUTCARGA(GWN->GWN_FILIAL,GWN->GWN_NRROM,cViagem)
			dbSelectArea('GWN')
			RestArea(aAreaGWN)
			
			RecLock("GWN",.F.)
			GWN->GWN_VIAGEM := cViagem
			GWN->GWN_CPESO := aQtdes[CPESO]
			GWN->GWN_CVAL  := aQtdes[CVAL ]
			GWN->GWN_CVOL  := aQtdes[CVOL ]
			GWN->GWN_CQTDE := aQtdes[CQTDE]
			MsUnLock("GWN")
			
		ElseIf !Empty(cViagAnt) .And. !Empty(cViagem) .And. AllTrim(cViagAnt) != AllTrim(cViagem) // troca de viagem
			
			RecLock("GWN",.F.)
			GWN->GWN_VIAGEM := ''
			MsUnLock("GWN")
			
			AtuOutCarga(cViagAnt,cCALC,cMTCALC,dDTCALC,cHRCALC,cFil,cNrRom,lAtuPeso)
			dbSelectArea('GWN')
			RestArea(aAreaGWN)
			
			aQtdes := GFE58OUTCARGA(GWN->GWN_FILIAL,GWN->GWN_NRROM,cViagem)
			dbSelectArea('GWN')
			RestArea(aAreaGWN)

			RecLock("GWN",.F.)
			GWN->GWN_VIAGEM := cViagem
			GWN->GWN_CPESO := aQtdes[CPESO]
			GWN->GWN_CVAL  := aQtdes[CVAL ]
			GWN->GWN_CVOL  := aQtdes[CVOL ]
			GWN->GWN_CQTDE := aQtdes[CQTDE]
			MsUnLock("GWN")
			
		ElseIf !Empty(cViagAnt) .And. Empty(cViagem) //Desvinculo de viagem
			RecLock("GWN",.F.)
			GWN->GWN_VIAGEM := ''
			GWN->GWN_CPESO := 0
			GWN->GWN_CVAL  := 0
			GWN->GWN_CVOL  := 0
			GWN->GWN_CQTDE := 0
			MsUnLock("GWN")
			cViagem := cViagAnt
		EndIf
		
	EndIf
	
	//Atualiza outros romaneios da nova viagem
	AtuOutCarga(cViagem,cCALC,cMTCALC,dDTCALC,cHRCALC,cFil,cNrRom,lAtuPeso)
	
	RestArea(aAreaGWN)
	RestArea(aArea)
	cFilAnt := cFilBkp
Return .T.

//Atualiza outros romaneios da viagem
Static Function AtuOutCarga(cViagem,cCALC,cMTCALC,dDTCALC,cHRCALC,cFil,cNrRom,lAtuPeso)
	dbSelectArea('GWN')
	GWN->(dbOrderNickName('VIAGEM'))
	GWN->(dbSeek(cViagem))
	While !GWN->(Eof()) .And. GWN->GWN_VIAGEM == cViagem
		
		If cFil != GWN->GWN_FILIAL .Or. cNrRom != GWN->GWN_NRROM
		
			RecLock("GWN", .F.)
				If GWN->GWN_CALC != "2"
					GWN->GWN_CALC := cCALC
					GWN->GWN_MTCALC := cMTCALC
					GWN->GWN_DTCALC := dDTCALC
					GWN->GWN_HRCALC := cHRCALC
				EndIf
				If lAtuPeso
					aQtdes := GFE58OUTCARGA(GWN->GWN_FILIAL,GWN->GWN_NRROM,cViagem)
					dbSelectArea('GWN')
					GWN->GWN_CPESO := aQtdes[CPESO]
					GWN->GWN_CVAL  := aQtdes[CVAL ]
					GWN->GWN_CVOL  := aQtdes[CVOL ]
					GWN->GWN_CQTDE := aQtdes[CQTDE]
				EndIf
			MsUnLock("GWN")
		EndIf
		
		GWN->(dbSkip())
	EndDo
Return 

Function GFE58OUTCARGA(cFil,cNrRom,cViagem)
	Local aQtdes := {0,0,0,0}
	Local cQuery
	Local cAlQry
	Local cFilBkp   := cFilAnt

	cFilAnt := cFil

	cQuery := " SELECT SUM(GW8.GW8_VOLUME) GWN_TOTVOL,"
	cQuery +=        " SUM(GW8.GW8_PESOR) GWN_TOTPER,"
	cQuery +=        " SUM(GW8.GW8_VALOR) GWN_TOTVAL,"
	cQuery +=        " SUM(GW8.GW8_QTDE) GWN_QTDE"
	cQuery +=   " FROM "+RetSqlName("GWN")+" GWN"
	cQuery +=  " INNER JOIN "+RetSqlName("GW1")+" GW1"
	If GFXCP1212210('GW1_FILROM')
		cQuery += " ON GW1.GW1_FILROM = GWN.GWN_FILIAL"
	Else
		cQuery += " ON GW1.GW1_FILIAL = GWN.GWN_FILIAL"
	EndIf
	cQuery +=    " AND GW1.GW1_NRROM  = GWN.GWN_NRROM"
	cQuery +=  " INNER JOIN "+RetSqlName("GW8")+" GW8"
	cQuery +=     " ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery +=    " AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery +=    " AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery +=    " AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery +=    " AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery +=  " WHERE (GWN.GWN_FILIAL <> '"+cFil+"'"
	cQuery +=    " OR GWN.GWN_NRROM  <> '"+cNrRom+"')"
	cQuery +=    " AND GWN.GWN_VIAGEM  = '"+cViagem+"'"
	cQuery +=    " AND GW1.GW1_SIT IN ('4','5')"
	cQuery +=    " AND GWN.D_E_L_E_T_ = ' '"
	cQuery +=    " AND GW1.D_E_L_E_T_ = ' '"
	cQuery +=    " AND GW8.D_E_L_E_T_ = ' '"
	cAlQry := MpSysOpenQuery(ChangeQuery(cQuery))
	
	If !(cAlQry)->(Eof())
		aQtdes[CPESO] := (cAlQry)->GWN_TOTPER
		aQtdes[CVAL ] := (cAlQry)->GWN_TOTVAL
		aQtdes[CVOL ] := (cAlQry)->GWN_TOTVOL
		aQtdes[CQTDE] := (cAlQry)->GWN_QTDE
	EndIf
	
	(cAlQry)->(dbCloseArea())
	cFilAnt := cFilBkp
Return aQtdes

Function GFEA058CMT(oModel)
	Local lRet := FWFormCommit(oModel, /*[ bBefore ]*/,/* [ bAfter ]*/, /*[ bAfterSTTS ]*/,{|oModel| GFE58ATDP(oModel)}, /*[ bABeforeTTS ]*/, /*<bIntegEAI >*/)
	
	If lRet
		While ( GetSx8Len() > 0 )
			ConfirmSX8()
		Enddo
	Else
		While ( GetSx8Len() > 0 )
			RollBackSX8()
		Enddo
	EndIf
Return lRet

Function GFEA58VLD(oModel)
	Local lRet := .T.
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If GWP->GWP_SIT == '2'
			GfeMsgErro("Não é possível alterar ou excluir viagens fechadas")
			lRet := .F.
		EndIf
	EndIf
Return lRet

Function GFEA058POS(oModel)
	Local lRet := .T.
	Local cQuery
	Local cAlQry
	Local cRomaneios := ""
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		cQuery := "SELECT GWN_FILIAL,GWN_NRROM FROM " + RetSqlName('GWN') + " WHERE D_E_L_E_T_ = ' ' AND GWN_VIAGEM = '" + GWP->GWP_VIAGEM + "' AND GWN_CDTRP <> '" + FwFldGet("GWP_CDTRP") + "'"
		cAlQry := MpSysOpenQuery(ChangeQuery(cQuery))
		
		While !(cAlQry)->(Eof()) .And. !Empty((cAlQry)->GWN_NRROM)
			cRomaneios += CRLF + "Filial " + AllTrim((cAlQry)->GWN_FILIAL) + " - Romaneio " + AllTrim((cAlQry)->GWN_NRROM)
			(cAlQry)->(dbSkip())
			If !(cAlQry)->(Eof())
				cRomaneios += CRLF
			EndIf
		EndDo
		
		If !Empty(cRomaneios)
			Help( ,, 'HELP',, "Não é possível alterar o transportador pois a viagem está relacionada com romaneio: " + cRomaneios, 1, 0,)
			lRet := .F.
		EndIf
		
		(cAlQry)->(dbCloseArea())
	EndIf
	
Return lRet

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oStructGWP := FWFormStruct(2,"GWP")	
	oView:SetModel(FWLoadModel("GFEA058"))
	oView:AddField( "GFEA058_GWP" , oStructGWP)
Return oView

/*/{Protheus.doc} GFEA58CVIA
	Calcula todos os romaneios da viagem (GWP) POSICIONADA
@author siegklenes.beulke
@since 20/06/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GFEA58CVIA(cNrRom)
	Default cNrRom := ""
	lRet := GFEA58PVIA(.T.,.F.,IsInCallStack("GFEA058") .And. !IsBlind(),cNrRom)//Calcular, não libera, não mostra log
Return lret

/*/{Protheus.doc} GFEA58CVIA
	Libera todos os romaneios da viagem (GWP) POSICIONADA
@author siegklenes.beulke
@since 20/06/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GFEA58LVIA(cNrRom)
	Default cNrRom := ""
	lRet := GFEA58PVIA(.F.,.T.,!IsBlind(),cNrRom)//Não calcula, libera, mostra log
Return lret

Function GFEA58PVIA(lCalcular,lLiberar,lShowLog,cNrRom) //Calcular e liberar significa a partida da viagem
	Local lProssegue := .T.
	Local cFilBkp := cFilAnt
	Local aArea := GetArea()
	Local cTitulo
	Local cAcao
	Local S_GFEBRF := "1"

	Private GFELog     := GFEViewProc():New()
	Private _lSemHelp := .F.// Variável para não exibir os Help's da função GFEA50LIB()
	Default lCalcular := .T.
	Default lLiberar := .T.
	Default lShowLog := !IsBlind()
	Default cNrRom := ""

	If !lCalcular .And. !lLiberar
		UserException("Só é possível calcular, liberar ou dar a partida da viagem(calcular e liberar). Verfique o uso da função")
	EndIf

	If GWP->GWP_SIT == '2' .And. lCalcular .And. lLiberar
		GfeMsgErro('Não é possível realizar a partida da viagem pois já foi fechada.')
		lProssegue := .F.
		lShowLog := .F.
	EndIf
	
	If lCalcular .And. lLiberar
		cAcao := "a partida"
		cTitulo := "Partida da viagem"
	ElseIf lCalcular
		cAcao := "o cálculo"
		cTitulo := "Cálculo dos romaneios da viagem"
	ElseIf lLiberar
		cAcao := "a liberação"
		cTitulo := "Liberação dos romaneios da viagem"
	EndIf
	
	If lProssegue
		IF S_GFEBRF != "1"
			//Ao iniciar uma transação, não deve ser criada TRB. Desta forma foram iniciadas antes da transação
			XFUNBTRB() //Cria as tabelas temporárias GFEXFUNB
			XFUNCTAB() //Cria as tabelas temporárias GFEXFUNC
		Endif
		BEGIN TRANSACTION
		Processa( {||GF58ExecPVIA(@lProssegue,lCalcular,lLiberar,cFilAnt,@lShowLog,cNrRom),"Realizando " + cAcao + " da viagem... Aguarde"})
		END TRANSACTION
		IF S_GFEBRF != "1" .And. !IsBlind()
			//Após a transação, as TRB são deletadas
			XFUNBDLTRB() //Deleta as tabelas temporárias GFEXFUNB
			XFUNCDTAB() //Delete as tabelas temporárias GFEXFUNC
		EndIf
	EndIf
	
	cFilAnt := cFilBkp
	RestArea(aArea)
	
	If lShowLog
		GFELog:Show(cTitulo, "Romaneios", "Erros", "Não foi possível realizar " + cAcao + " da viagem, clique no botão 'Erros' para mais detalhes.")
	EndIf
	
Return lProssegue

Function GFA58VLDDH(nOpcao,oDlgA058,dDtSai,cHrSai)
	nOpcao := 1
	
	If Empty(dDtSai)
		MsgAlert("É obrigatório informar a data da partida")
		nOpcao := 0
	EndIf
	
	If Empty(StrTran(cHrSai,":",""))
		MsgAlert("É obrigatório informar a hora da partida")
		nOpcao := 0
	EndIf
	
	If dDtSai > Date()
		MsgAlert("Data da partida da viagem não pode ser superior à data atual")
		nOpcao := 0
	ElseIf dDtSai == Date()
		If StrTran(cHrSai,":","") > StrTran(SubStr(Time(),1,5),":","")
			MsgAlert("Hora da partida da viagem não pode ser superior à hora atual")
			nOpcao := 0
		EndIf
	EndIf
	If nOpcao == 1
		oDlgA058:End()
	EndIf
Return
/*/{Protheus.doc} PVIAExec
	A partida da viagem é a verificação da situação e do cálculo dos romaneios de todas as filiais, por isso não é utilizado xfilial 
@author siegklenes.beulke
@since 20/06/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GF58ExecPVIA(lOk,lCalcular,lLiberar,cFilAtu,lShowLog,cNrRom)
	Local cQuery		:= "SELECT R_E_C_N_O_ GWN_RECNO, GWN_SIT, GWN_CALC, GWN_FILIAL, GWN_NRROM FROM " + RetSqlName("GWN") + " WHERE D_E_L_E_T_ = ' ' AND GWN_VIAGEM = '" + GWP->GWP_VIAGEM + "'"  
	Local cAlQry		:= MpSysOpenQuery(ChangeQuery(cQuery))
	Local nOpcao 		:= 0
	Local lPodeLiberar 	:= .T.
	Local aCalcs		:= {}
	Local aCalcErro		:= {}
	Local aRoms			:= {}
	Local aRomErro		:= {}
	Local cMsg 			:= ""
	Local cTpLib 		:= SuperGetMv('MV_DTROMV',.F.,'1')
	Local lIsDark 		:= GfeDark()
	Local nQtdRom
	Local nX
	Local lHelp
	Local oDlgA058	

	Private dDtSai,cHrSai, dDtVig, cHrVig
	Default cNrRom 		:= ""

	ProcRegua(0)
	
	dDtSai := If( ValType("DDATABASE") == 'D', DDATABASE,Date())
	cHrSai := SubStr(Time(),1,5)

	If lCalcular .And. lLiberar .And. !IsBlind()
		If lIsDark
			DEFINE MSDIALOG oDlgA058 TITLE "Data/Hora da Partida" FROM 000, 000  TO 96, 188 PIXEL
			
			@ 005, 005 SAY oSay1 PROMPT "Data:" SIZE 014, 007 OF oDlgA058 PIXEL
			@ 017, 005 SAY oSay2 PROMPT "Hora:" SIZE 016, 007 OF oDlgA058 PIXEL
			@ 005, 020 MSGET oGet1 VAR dDtSai SIZE 047, 007 OF oDlgA058  HASBUTTON PIXEL
			@ 017, 020 MSGET oGet2 VAR cHrSai SIZE 015, 007 OF oDlgA058 PICTURE "@R 99:99" PIXEL Valid GFEVLDHR(cHrSai)
			@ 032, 054 BUTTON oButton1 PROMPT "Ok" SIZE 037, 012 OF oDlgA058 ACTION {||GFA58VLDDH(@nOpcao,oDlgA058,dDtSai,cHrSai)} PIXEL
			@ 032, 005 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgA058 ACTION oDlgA058:End() PIXEL
		Else 
			DEFINE MSDIALOG oDlgA058 TITLE "Data/Hora da Partida" FROM 000, 000  TO 96, 188 COLOR CLR_BLACK PIXEL
			
			@ 005, 005 SAY oSay1 PROMPT "Data:" SIZE 014, 007 OF oDlgA058 COLORS CLR_BLACK,CLR_WHITE PIXEL
			@ 017, 005 SAY oSay2 PROMPT "Hora:" SIZE 016, 007 OF oDlgA058 COLORS CLR_BLACK,CLR_WHITE PIXEL
			@ 005, 020 MSGET oGet1 VAR dDtSai SIZE 047, 007 OF oDlgA058 COLORS CLR_BLACK,CLR_WHITE HASBUTTON PIXEL
			@ 017, 020 MSGET oGet2 VAR cHrSai SIZE 015, 007 OF oDlgA058 PICTURE "@R 99:99" COLORS CLR_BLACK,CLR_WHITE PIXEL Valid GFEVLDHR(cHrSai)
			@ 032, 054 BUTTON oButton1 PROMPT "Ok" SIZE 037, 012 OF oDlgA058 ACTION {||GFA58VLDDH(@nOpcao,oDlgA058,dDtSai,cHrSai)} PIXEL
			@ 032, 005 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgA058 ACTION oDlgA058:End() PIXEL
		EndIf 
		ACTIVATE MSDIALOG oDlgA058 CENTERED
		If nOpcao == 0
			lOk := .F.
			lShowLog := .F.
			Return
		EndIf
	EndIf
	
	dDtVig := dDtSai
	cHrVig := cHrSai
	
	If (cAlQry)->(Eof()) .Or. Empty((cAlQry)->(GWN_NRROM))
		GFELog:AddErro("Não há romaneios relacionados à viagem")
		lPodeLiberar := .F.
	EndIf	
	
	If lPodeLiberar
		nQtdRom := 0
		
		While !(cAlQry)->(Eof()) .And. nQtdRom <= 1
			nQtdRom++
			(cAlQry)->(dbSkip())
		Enddo
		
		If nQtdRom == 1 .And. lCalcular .And. lLiberar .And. !IsBlind()
			If !MsgYesNo("Há somente um romaneio relacionado a viagem. Prosseguir com a partida?")
				GFELog:AddErro("Partida cancelada pelo usuário")
				lPodeLiberar := .F.
			EndIf
		EndIf
		
		If lPodeLiberar
			(cAlQry)->(dbGoTop())
			nQtdRom := 0
			While !(cAlQry)->(Eof())
				nQtdRom++
				If lCalcular
					GWN->(dbGoto((cAlQry)->GWN_RECNO))
					If GWN->GWN_CALC != '1' .Or. !lLiberar
						cFilAnt := GWN->GWN_FILIAL
						cMsg := ""
						lHelp := lShowLog == .F. .And. cFilAtu == cFilAnt .And. cNrRom == GWN->GWN_NRROM
						If GFE050CALC(Nil, lHelp,@cMsg)
							aAdd(aCalcs,{GWN->GWN_FILIAL,GWN->GWN_NRROM,""})
						Else
							aAdd(aCalcErro,{GWN->GWN_FILIAL,GWN->GWN_NRROM,cMsg})
						EndIf
					Else
						If !TemCalcCb()
							aAdd(aCalcs,{GWN->GWN_FILIAL,GWN->GWN_NRROM,"Calculado anteriormente"})
						Else
							aAdd(aCalcErro,{GWN->GWN_FILIAL,GWN->GWN_NRROM,"Possúi cálculo informado/origem erp"})
						EndIf
					EndIf
				EndIf
				
				If lLiberar
					If (cAlQry)->GWN_SIT != '3'
						cMsg := ""
						GWN->(dbGoto((cAlQry)->GWN_RECNO))
						
						If cTpLib == '1' .Or. Empty(cTpLib)
							dDtSai := GWN->GWN_DTIMPL
							cHrSai := GWN->GWN_HRIMPL
						EndIf
						
						If GFEA050LIB(.T., @cMsg,dDtSai,cHrSai)
							aAdd(aRoms,{GWN->GWN_FILIAL,GWN->GWN_NRROM,""})
						Else
							lPodeLiberar := .F.
							aAdd(aRomErro,{GWN->GWN_FILIAL,GWN->GWN_NRROM,cMsg})
						EndIf
					Else
						aAdd(aRoms,{(cAlQry)->GWN_FILIAL,(cAlQry)->GWN_NRROM,"Liberado anteriormente"})
					EndIf
				EndIf
				(cAlQry)->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If lPodeLiberar .And. lCalcular .And. lLiberar
		GFELog:Add("Partida realizada com sucesso.")
		GFELog:Add(Replicate('-',50))
		GFELog:Add("")
	EndIf 
	
	If lCalcular
		GFELog:Add("Romaneios calculados")
		GFELog:Add(Replicate('-',50))
		For nX := 1 To Len(aCalcs)
			GFELog:Add("Filial - " + aCalcs[nX][1] + " - Romaneio - " + aCalcs[nX][2] + If( (!Empty(aCalcs[nX][3]) )," : " + aCalcs[nX][3],""))
		Next nX
		GFELog:Add(Replicate('-',50))
	EndIf

	If Len(aCalcErro) > 0
		GFELog:Add("")
		GFELog:Add("Romaneios não calculados")
		GFELog:Add(Replicate('-',50))
		For nX := 1 To Len(aCalcErro)
			GFELog:Add("Filial - " + aCalcErro[nX][1] + " - Romaneio - " + aCalcErro[nX][2] + If( (!Empty(aCalcErro[nX][3]) )," : " + aCalcErro[nX][3],""))
		Next nX
		GFELog:Add(Replicate('-',50))
	EndIf
	
	If lCalcular .And. lLiberar
		GFELog:Add("")
	EndIf
	
	If lLiberar
		GFELog:Add("Romaneios liberados")
		GFELog:Add(Replicate('-',50))
		For nX := 1 To Len(aRoms)
			GFELog:Add("Filial - " + aRoms[nX][1] + " - Romaneio - " + aRoms[nX][2] + If( (!Empty(aRoms[nX][3]) )," : " + aRoms[nX][3],""))
		Next nX
		GFELog:Add(Replicate('-',50))
	EndIf
		
	If Len(aRomErro) > 0
		GFELog:AddErro("Romaneios não liberados")
		GFELog:AddErro(Replicate('-',50))
		For nX := 1 To Len(aRomErro)
			GFELog:AddErro("Filial - " + aRomErro[nX][1] + " - Romaneio - " + aRomErro[nX][2] + If( (!Empty(aRomErro[nX][3]) )," : " + aRomErro[nX][3],""))
		Next nX
		GFELog:AddErro(Replicate('-',50))
	EndIf
	
	(cAlQry)->(dbCloseArea())
	
	If lPodeLiberar .And. lCalcular .And. lLiberar
		RecLock('GWP',.F.)
		GWP->GWP_SIT := '2'
		GWP->GWP_DTPART := dDtVig
		GWP->GWP_HRPART := cHrVig
	EndIf
	
	lOk := lPodeLiberar
Return

Static Function TemCalcCb(nRecDc,cNrDc)
	Local cQuery
	Local lTemCalcCB := .F.
	Local cAlQry
	Default nRecDc := 0
	
	cQuery := " SELECT GWN.GWN_NRROM "
	cQuery += " FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " INNER JOIN " + RetSQLName("GWF") + " GWF"
	If GFXCP1212210('GWF_FILROM')
		cQuery += " ON GWF.GWF_FILROM = GWN.GWN_FILIAL"
	Else
		cQuery += " ON GWF.GWF_FILIAL = GWN.GWN_FILIAL"
	EndIf
	cQuery += "   AND GWF.GWF_NRROM = GWN.GWN_NRROM"
	cQuery += "   AND GWF.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE GWN.D_E_L_E_T_ = ' ' AND GWN.R_E_C_N_O_ = " + cValToChar(GWN->(RecNo()))
	cQuery += "	AND GWF.GWF_ORIGEM IN ('2','4') "
	
	cAlQry := MpSysOpenQuery(ChangeQuery(cQuery))
	lTemCalcCB := !(cAlQry)->(Eof()) .Or. !Empty((cAlQry)->GWN_NRROM)
	(cAlQry)->(dbCloseArea())
	If !lTemCalcCB // Procura por calculos relacionados aos documentos do romaneio mas ainda não foi relacionado ao romaneio
		If nRecDc != 0
			cQuery := " SELECT GW1.GW1_NRDC "
			cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
		Else
			cQuery := " SELECT GWN.GWN_NRROM "
			cQuery += " FROM " + RetSQLName("GWN") + " GWN "
			cQuery += " INNER JOIN " + RetSQLName("GW1") + " GW1"
			If GFXCP1212210('GW1_FILROM')
				cQuery += " ON GW1.GW1_FILROM = GWN.GWN_FILIAL"
			Else
				cQuery += " ON GW1.GW1_FILIAL = GWN.GWN_FILIAL"
			EndIf
			cQuery += "  AND GW1.GW1_NRROM = GWN.GWN_NRROM"
			cQuery += "  AND GW1.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += " INNER JOIN " + RetSQLName("GWH") + " GWH ON GWH.GWH_FILIAL = GW1.GW1_FILIAL AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC AND GWH.GWH_EMISDC = GW1.GW1_EMISDC AND GWH.GWH_SERDC = GW1.GW1_SERDC AND GWH.GWH_NRDC = GW1.GW1_NRDC AND GWH.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSQLName("GWF") + " GWF ON GWF.GWF_FILIAL = GWH.GWH_FILIAL AND GWF.GWF_NRCALC = GWH.GWH_NRCALC AND GWF.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE GWF.GWF_ORIGEM IN ('2','4') "
		cQuery += " AND GW1.D_E_L_E_T_ = ' '
		If nRecDc != 0
			cQuery += "	AND GW1.R_E_C_N_O_ = " + cValToChar(nRecDc)
		Else
			cQuery += " AND GWN.D_E_L_E_T_ = ' ' "
			cQuery += " AND GWN.R_E_C_N_O_ = " + cValToChar(GWN->(RecNo()))
		EndIf
		cAlQry := MpSysOpenQuery(ChangeQuery(cQuery))
		If nRecDc != 0
			lTemCalcCB := !(cAlQry)->(Eof()) .Or. !Empty((cAlQry)->GW1_NRDC)
			cNrDc := (cAlQry)->GW1_NRDC
		Else
			lTemCalcCB := !(cAlQry)->(Eof()) .Or. !Empty((cAlQry)->GWN_NRROM)
		EndIf
		(cAlQry)->(dbCloseArea())
	EndIf
Return lTemCalcCB

Function GFEA058RVG(nRecDc,cNrDc)
Return !TemCalcCb(nRecDc,@cNrDc)

Function GFEA058GWN()
	Local oModelBkp := FwModelActive()
	Local oModel := FwLoadModel("GFEA058")
	Local aErro
	Private cCdtrp
	If oModelBkp != Nil
		cCdtrp := oModelBkp:GetModel("GFEA050_GWN"):GetValue("GWN_CDTRP")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If !oModel:Activate()
			aErro := oModel:GetErrorMessage()
			GfeMsgErro( AllToChar(aErro[6]) + CRLF +;
					 AllToChar(aErro[7]))
		Else
			If !Empty(cCdtrp)
				oModel:Getmodel("GFEA058_GWP"):SetValue("GWP_CDTRP", cCdtrp)
			EndIf
			FwExecView("Incluir",'GFEA058',MODEL_OPERATION_INSERT,,{||.T.},{||GFEA058OKGWN()},,,,,,oModel)
		EndIf
	EndIf
	
	
	FwModelActive(oModelBkp)
Return

Function GFEA058OKGWN()
	Local oX := FwModelActive()
	Local lRet := cCdtrp == oX:Getmodel("GFEA058_GWP"):GetValue("GWP_CDTRP")
	If !lRet
		GfeMsgErro("O transportador da viagem deve ser o mesmo do romaneio.")
	EndIf
Return lRet
