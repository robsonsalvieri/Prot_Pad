#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include "PARMTYPE.CH" 
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "FILEIO.CH"
#include "RESTFUL.ch"

Function ImpTraTool(cCheckChv)

Private aTools		:= {"Consultar Recibo","Incluir Recibo","Consultar Log","Atualizar Status"}
Private aXML		:= {"NFE","NFS","CTE","CTO"}
Private aDHWImp		:= {}
Private aDHWTra		:= {}
Private aImpTraTool	:= {}
Private aAgendSched	:= {"SCHEDIMPTRA","SCHEDUPDTRA"}
Private aLogSched	:= {}
Private cAgendSched	:= ""
Private cLogSched	:= ""
Private cTpXML		:= ""
Private cDHWFil		:= ""
Private cCboTool	:= ""
Private cRecibo		:= "" 
Private cImpTraTool	:= ""
Private cChvDoc		:= ""
Private lImpXTra	:= .F.

Private oDlgFil			:= Nil
Private oLayer 			:= FWLayer():new()
Private oPainel1		:= Nil
Private oPainel2		:= Nil
Private oComTransmite 	:= ComTransmite():New()
Private oSchedule		:= Nil

Default cCheckChv	:= ""

oComTransmite:GetCodFilDHW(@aDHWTra)
aDHWImp		:= ImpTraDHW(aDHWTra,1)
cRecibo		:= Space(oComTransmite:nTamId)
cChvDoc		:= Space(oComTransmite:nTamChv)

If !Empty(cCheckChv) .And. cCheckChv <> "SDS"
	cChvDoc := cCheckChv
Endif

//Verifica se integração com TOTVS Transmite esta ativa
lImpXTra := oComTransmite:GetImpXTra()

DEFINE MSDIALOG oDlgFil TITLE "Ferramentas - Importador XML x Totvs Transmite" FROM 000,000 TO 650,1200 PIXEL //"Filial(ais) - Importador XML x Totvs Transmite"

oLayer:init(oDlgFil,.T.) 

//Cria as colunas do Layer
oLayer:addCollumn('Col01',100,.F.)
 
//Adiciona Janelas as colunas
oLayer:addWindow('Col01','C1_Win01','Agendamentos',15,.F.,.F.)
oLayer:addWindow('Col01','C1_Win02','Ferramentas',80,.F.,.F.)

oPanel1 := oLayer:GetWinPanel('Col01','C1_Win01')
oPanel2 := oLayer:GetWinPanel('Col01','C1_Win02')

//Agendamentos
oReqLog := TSay():New(05,05,{||'Requisição com Log'},oPanel1,,,,,,.T.,,,60,10) 
oF1B1 	:= TBrowseButton():New(03,75,"SCHEDIMPTRA",oPanel1, {|| IPTOOLAGEN("SCHEDIMPTRA","IMP")},60,12,,,.F.,.T.,.F.,,.F.,,,) 

oUpdLog := TSay():New(05,170,{||'Atualização com Log'},oPanel1,,,,,,.T.,,,60,10)
oF1B2 	:= TBrowseButton():New(03,240,"SCHEDUPDTRA",oPanel1, {|| IPTOOLAGEN("SCHEDUPDTRA","UPD")},60,12,,,.F.,.T.,.F.,,.F.,,,) 

oImpLog := TSay():New(05,330,{||'Importação Monitor'},oPanel1,,,,,,.T.,,,60,10)
oF1B3 	:= TBrowseButton():New(03,400,"SCHEDCOMCOL",oPanel1, {|| IPTOOLAGEN("SCHEDCOMCOL")},60,12,,,.F.,.T.,.F.,,.F.,,,)   

//Combo com ferramentas disponiveis
oCbo 	:= TComboBox():New(05,05,{|u|if(PCount()>0,cCboTool:=u,cCboTool)},aTools,100,20,oPanel2,,{|| ImpTraChg()},,,,.T.,,,,,,,,,'cCboTool')

//MultiGet
oMultG 	:= tMultiget():new(25,05, {| u | if( pCount() > 0, cImpTraTool := u, cImpTraTool ) },oPanel2, 580, 180, , , , , , .T. ) 
oMultG:lReadOnly := .T.

//Consultar e Incluir Recibo
oP2S1 := TSay():New(08,120,{|| 'Recibo: '},oPanel2,,,,,,.T.,,,40,12)
oP2G1 := TGet():New(05,160,{|u|If(PCount()==0,cRecibo,cRecibo := u ) },oPanel2,120,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cRecibo",,,,)

//Incluir Recibo
oP2S2 := TSay():New(08,290,{|| 'Tipo XML: '},oPanel2,,,,,,.T.,,,40,12)
oP2CB1:= TComboBox():New(05,330,{|u|if(PCount()>0,cTpXML:=u,cTpXML)},aXML,35,13,oPanel2,,{|| },,,,.T.,,,,,,,,,'cTpXML')

//Incluir Recibo
oP2S3 := TSay():New(08,375,{|| 'Empresa/Filial: '},oPanel2,,,,,,.T.,,,40,12)
oP2CB2:= TComboBox():New(05,415,{|u|if(PCount()>0,cDHWFil:=u,cDHWFil)},aDHWImp,100,13,oPanel2,,{|| },,,,.T.,,,,,,,,,'cDHWFil') 

//Consultar Log
oP2S4 := TSay():New(08,120,{|| 'Agendamento: '},oPanel2,,,,,,.T.,,,40,12)
oP2CB3:= TComboBox():New(05,160,{|u|if(PCount()>0,cAgendSched:=u,cAgendSched)},aAgendSched,120,13,oPanel2,,{|| },,,,.T.,,,,,,,,,'cAgendSched')
oP2CB3:bChange := {|| ImpTraLogSeg()}

//Consultar Log
oP2S5 := TSay():New(08,290,{|| 'Logs: '},oPanel2,,,,,,.T.,,,40,12)
oP2CB4:= TComboBox():New(05,330,{|u|if(PCount()>0,cLogSched:=u,cLogSched)},aLogSched,120,13,oPanel2,,{|| },,,,.T.,,,,,,,,,'cLogSched')

//Consultar Log
oP2B1 := TBrowseButton():New(05,525,Iif(cCboTool=="Consultar Log","Download",cCboTool),oPanel2, {|| FWMsgRun(, {|| IPTOOLFER() }, Iif(cCboTool=="Consultar Log","Download",cCboTool), "Aguarde...")},60,12,,,.F.,.T.,.F.,,.F.,,,) 
oP2B2 := TBrowseButton():New(05,460,Iif(cCboTool=="Consultar Log","Apagar Logs","Consultar Chave"),oPanel2, {|| FWMsgRun(, {|| IPTOOLFER(1) }, Iif(cCboTool=="Consultar Log","Apagar Logs","Consultar Chave"), "Aguarde...")},60,12,,,.F.,.T.,.F.,,.F.,,,) 

//Atualizar Status
oP2S6 := TSay():New(08,120,{|| 'Chave Documento (CKO_CHVDOC): '},oPanel2,,,,,,.T.,,,100,12)
oP2G2 := TGet():New(05,220,{|u|If(PCount()==0,cChvDoc,cChvDoc := u ) },oPanel2,220,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cChvDoc",,,,)

oT1B1 := TBrowseButton():New(310,460,"Limpar",oDlgFil, {|| (cImpTraTool := "",oMultG:Refresh())},60,12,,,.F.,.T.,.F.,,.F.,,,)
oT1B2 := TBrowseButton():New(310,530,"Sair",oDlgFil, {|| oDlgFil:End()},60,12,,,.F.,.T.,.F.,,.F.,,,)

ImpTraChg()

If !Empty(cCheckChv) .And. cCheckChv <> "SDS"
	oCbo:nAt := 4
	ImpTraChg()
Endif

ACTIVATE MSDIALOG oDlgFil CENTERED

//-- Limpa objetos da memória
If oComTransmite <> Nil
	FreeObj(oComTransmite)
EndIf

FwFreeArray(aTools)
FwFreeArray(aDHWTra)
FwFreeArray(aDHWImp)
FwFreeArray(aXML)
FwFreeArray(aImpTraTool)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IPTOOLFER
Ferramenta de Auxilio - Ferramentas
Consultar recibo e Incluir recibo

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function IPTOOLFER(nOpc)

Local aIPToolRet	:= {} 
Local aEmpFil		:= {}
Local aIdDHY		:= {}
Local nI			:= 0
Local cCodFil		:= ""
Local nTamCodFil	:= TamSX3("DHY_CODFIL")[1]
Local nTamTpXML		:= TamSX3("DHY_TPXML")[1]
Local nTamId		:= TamSX3("DHY_ID")[1]
Local cCLogAgend	:= ""
Local cLogDown		:= ""
Local lRet			:= .T.

Default nOpc := 0

If !lImpXTra
	cImpTraTool := CRLF + "Ferramenta: " + cCboTool + " disponivel apenas para integração entre Importador XML x TOTVS Transmite"
	oMultG:Refresh()
	lRet := .F.
Endif

If lRet

	If cCboTool == "Consultar Recibo"
		If !Empty(cRecibo)
			aIPToolRet := oComTransmite:IPToolConsult(cRecibo,cTpXML)
			If Len(aIPToolRet) > 0
				cImpTraTool := ""
				For nI := 1 To Len(aIPToolRet)
					cImpTraTool += aIPToolRet[nI]
				Next nI
			Endif
			oMultG:Refresh()
		Else
			cImpTraTool := "Preencha o recibo."
		Endif
	Elseif cCboTool == "Incluir Recibo"
		If !Empty(cRecibo) .And. !Empty(cDHWFil)
			aEmpFil := Separa(cDHWFil,"-")
			cCodFil := ImpTraDHW(,2,AllTrim(aEmpFil[1]),AllTrim(aEmpFil[2])) 

			If !Empty(cCodFil)
				aAdd(aIdDHY,{cCodFil,cTpXML,cRecibo,""}) 

				oComTransmite:PutIdDHY(aIdDHY)  
				cImpTraTool := "Inserido recibo: " + PadR(cCodFil,nTamCodFil) + " - " + PadR(cTpXML,nTamTpXML) + " - " +  PadR(cRecibo,nTamId) + CRLF + CRLF

				DbSelectArea("DHZ")
				DHZ->(DbSetOrder(1))
				If DHZ->(DbSeek(xFilial("DHZ") + PadR(cCodFil,nTamCodFil) + PadR(cTpXML,nTamTpXML) + PadR(cRecibo,nTamId)))
					cImpTraTool += "Recibo deletado (DHZ - Historico): " + PadR(cCodFil,nTamCodFil) + " - " + PadR(cTpXML,nTamTpXML) + " - " +  PadR(cRecibo,nTamId) + CRLF + CRLF
					If RecLock("DHZ",.F.)
						DHZ->(DbDelete())
						DHZ->(MsUnlock())
					Endif
				Endif
			Endif
		Else
			cImpTraTool := "Preencha o recibo e a qual empresa/grupo pertence."
		Endif
	Elseif cCboTool == "Consultar Log"
		If nOpc == 0
			If !Empty(cLogSched)
				cCLogAgend := oComTransmite:LogSegPlan() + cLogSched

				If File(cCLogAgend)
					cLogDown := cGetFile( "*.log", "Log (.log)", 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .T., .T.)

					If !Empty(cLogDown)
						( __CopyFile(cCLogAgend, cLogDown+cLogSched,,,oComTransmite:lSOWin))
						cImpTraTool := "Download realizado com sucesso. " + CRLF + CRLF + "Arquivo na pasta: " + cLogDown + cLogSched
					Endif				
				Endif		
			Endif
		Else // Limpar Logs
			If MsgYesNo("Deseja apagar logs anteriores a data: " + DtoC(dDatabase) + "?")
				oComTransmite:CleanUp("DELSEG",,,oComTransmite:LogSegPlan())
				ImpTraLogSeg()
			Endif
		Endif
	Elseif cCboTool == "Atualizar Status"
		If nOpc == 0
			oComTransmite:IPToolUpdStatus(cChvDoc)
		Else //Consultar Chave
			aIPToolRet := oComTransmite:IPToolCheckChv(cChvDoc)
			If Len(aIPToolRet) > 0
				cImpTraTool := ""
				For nI := 1 To Len(aIPToolRet)
					cImpTraTool += aIPToolRet[nI]
				Next nI
			Endif
			oMultG:Refresh()
		Endif
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpTraChg
Ferramenta de Auxilio - Ferramentas
Mudança da ferramenta a ser executada

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function ImpTraChg()

If cCboTool == "Consultar Recibo"
	oP2S1:Show() ; oP2G1:Show()

	oP2S2:Hide() ; oP2CB1:Hide() ; oP2S3:Hide() ; oP2CB2:Hide() ; oP2S4:Hide() ; oP2CB3:Hide() ; oP2S5:Hide() ; oP2CB4:Hide() ; oP2S6:Hide() ; oP2G2:Hide() ; oP2B2:Hide()
Elseif cCboTool == "Incluir Recibo"
	oP2S1:Show() ; oP2G1:Show() ; oP2S2:Show() ; oP2CB1:Show() ; oP2S3:Show() ; oP2CB2:Show()

	oP2S4:Hide() ; oP2CB3:Hide() ; oP2S5:Hide() ; oP2CB4:Hide() ; oP2S6:Hide() ; oP2G2:Hide() ; oP2B2:Hide()
Elseif cCboTool == "Consultar Log"
	oP2S4:Show() ; oP2CB3:Show() ; oP2S5:Show() ; oP2CB4:Show() ; oP2B1:Show() ; oP2B2:Show()

	oP2S1:Hide() ; oP2G1:Hide() ; oP2S2:Hide() ; oP2CB1:Hide() ; oP2S3:Hide() ; oP2CB2:Hide() ; oP2S6:Hide() ; oP2G2:Hide()

	ImpTraLogSeg()
Elseif cCboTool == "Atualizar Status"
	oP2S6:Show() ; oP2G2:Show() ; oP2B2:Show()

	oP2S4:Hide() ; oP2CB3:Hide() ; oP2S5:Hide() ; oP2CB4:Hide() ; oP2S1:Hide() ; oP2G1:Hide() ; oP2S2:Hide() 
	oP2CB1:Hide() ; oP2S3:Hide() ; oP2CB2:Hide()
Endif

//Botão - Atualiza
oP2B1:cCaption := Iif(cCboTool=="Consultar Log","Download",cCboTool)
oP2B2:cCaption := Iif(cCboTool=="Consultar Log","Apagar Logs","Consultar Chave")
cImpTraTool := "" 
oMultG:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpTraDHW
Ferramenta de Auxilio
Buscar informações da DHW (de x para Protheus e TOTVS Transmite)

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function ImpTraDHW(aDHWTra,nOpc,cEmp,cFil)

Local cAliasImp := GetNextAlias()
Local oQryDHW   := Nil
Local cQryStat  := ""
Local aRet		:= {}
Local cRet		:= ""
Local nOrder	:= 1

oQryDHW := FWPreparedStatement():New()  

cQry := " SELECT DHW_GRPEMP, DHW_FILEMP, DHW_CODFIL"
cQry += " FROM " + RetSqlName("DHW")
If nOpc == 1
	cQry += " WHERE DHW_CODFIL IN (?)"
Elseif nOpc == 2
	cQry += " WHERE DHW_GRPEMP = ?"
	cQry += " AND DHW_FILEMP = ?"
Endif
cQry += " AND D_E_L_E_T_ = ?"

oQryDHW:SetQuery(cQry)

If nOpc == 1
	oQryDHW:SetIn(nOrder++,aDHWTra)
Elseif nOpc == 2
	oQryDHW:SetString(nOrder++,cEmp)
	oQryDHW:SetString(nOrder++,cFil)
Endif
oQryDHW:SetString(nOrder++,Space(1))

cQryStat := oQryDHW:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

While (cAliasImp)->(!EOF())
	If nOpc == 1
		aAdd(aRet,AllTrim((cAliasImp)->DHW_GRPEMP) + " - " + AllTrim((cAliasImp)->DHW_FILEMP) )
	Elseif nOpc == 2
		cRet := (cAliasImp)->DHW_CODFIL
	Endif
	(cAliasImp)->(DbSkip())	
Enddo

(cAliasImp)->(DbCloseArea())

FreeObj(oQryDHW)

Return Iif(nOpc==1,aRet,cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpTraPrint
Ferramenta de Auxilio
Impressão de log (Schedimptra e Schedupdtra)

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Function ImpTraPrint(cOpc,lCreateTask,cCamTask)

Local cCaminho	:= ""
Local cLog		:= ""
Local cCamLog	:= ""
Local nHandle	:= 0
Local nI		:= 0

Default cOpc 		:= "GEN"
Default lCreateTask	:= .F.
Default cCamTask	:= "\"

If !lCreateTask
	cLog := "ImpTraTool"+cOpc+".Log"
Else
	cLog := "ImpTraTool"+cOpc+"_"+DtoS(dDataBase)+"_"+StrTran(Time(),":","")+".Log"
Endif

If !Empty(cOpc)
	If !lCreateTask
		cCaminho := cGetFile( "*.log", "Log (.log)", 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .T., .T.)
	Else
		cCaminho := cCamTask
	Endif

	If !Empty(cCaminho)
		cCamLog := cCaminho + cLog

		If File(cCamLog)
			FErase(cCamLog) 
		Endif

		nHandle := FCREATE(cCamLog)
	
		if nHandle > 0
			For nI := 1 To Len(aImpTraTool)
				FWrite(nHandle, aImpTraTool[nI])
			Next nI
			FClose(nHandle)
			
			If !lCreateTask
				ShellExecute( "open", cCamLog, "", "", 1 )
			Endif
		Endif
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IPTOOLAGEN
Ferramenta de Auxilio
Execução de agendamentos (Schedimptra, Schedupdtra e Schedcomcol)

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function IPTOOLAGEN(cAgendamento,cOpc)

Local cRotina	:= ""
Local lRet		:= .T.

Default cOpc := ""

aImpTraTool := {}

If cAgendamento $ "SCHEDIMPTRA|SCHEDUPDTRA" .And. !lImpXTra
	cImpTraTool := CRLF + "Agendamento: " + cAgendamento + " disponivel apenas para integração entre Importador XML x TOTVS Transmite"
	oMultG:Refresh()
	lRet := .F.
Endif
	
If lRet
	If MsgYesNo("Deseja executar o agendamento: " + cAgendamento + " em segundo plano?")
		oSchedule := totvs.protheus.backoffice.com.general.schedule():new()
		If oSchedule:lLibVersion .And. oSchedule:lUsrAdmin .And. oSchedule:lSmartSched
			If cAgendamento == "SCHEDCOMCOL"
				cRotina := cAgendamento
			Elseif cAgendamento == "SCHEDIMPTRA"
				cRotina := "IMPTRASEG"
			Elseif cAgendamento == "SCHEDUPDTRA"
				cRotina := "UPDTRASEG"
			Endif
			oSchedule:createTask(cRotina,.F.)
		Else
			cImpTraTool := CRLF + "Agendamento: " + cAgendamento + " não foi executado em segundo plano."
			cImpTraTool += CRLF + "Verificar se LIB esta atualizada e/ou usuario é ou pertence ao grupo de administradores e SmartSchedule esta ativo e habilitado. " + CRLF
			oMultG:Refresh()
		Endif
	Else
		aAdd(aImpTraTool,'inicio: ' + Time() + CRLF)

		FWMsgRun(, {|| &(cAgendamento+"()") }, "Processando", "Processando a rotina " + cAgendamento)

		aAdd(aImpTraTool,'Fim: ' + Time() + CRLF)

		FWMsgRun(, {|| ImpTraPrint(cOpc) }, "Imprimindo", "Imprimindo log da rotina " + cAgendamento)
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpTraLogSeg
Logs - Segundo Plano

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function ImpTraLogSeg()

Local cCaminho 	:= oComTransmite:LogSegPlan()
Local aLogs		:= {}
Local aLogAux	:= {}
Local cId		:= ""
Local nI		:= ""

aLogSched := {}

If cAgendSched == "SCHEDIMPTRA"
	cId := "imp"
Elseif cAgendSched == "SCHEDUPDTRA"
	cId := "upd"
Endif

aLogs := Directory(cCaminho + "*.log","D",,.F.)

For nI := 1 To Len(aLogs)
	aLogAux := Separa(aLogs[nI,1],"_")
	If Right(Lower(aLogAux[1]),3) == cId
		aAdd(aLogSched,aLogs[nI,1]) 
	Endif
Next nI

ASort(aLogSched,,,{|x,y|x > y})

If Len(aLogSched) > 0
	cLogSched := aLogSched[1]
Else
	cLogSched := ""
	aAdd(aLogSched,cLogSched) 
Endif
oP2CB4:aItems := aLogSched
oP2CB4:Refresh()

FwFreeArray(aLogs)
FwFreeArray(aLogAux)

Return
