#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "PLMensView.CH"

#DEFINE GET_EMPTY "0002"
#DEFINE ROOM_STATUS {'Pendente Auditor','Pendente Prestador','Finalizado'}


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLProcView
    Funcao para gestao de mensagens PLS x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Class PLProcView From PLMensCont

	Data cNome as String
	Data cCodRDA as String
	Data cNomeRDA as String
	Data cAlias as String
	Data cDescTipo as String
	Data cMatric as String
	Data cCodTipo as String
    Data cFase as String 
    Data cSituac as String
    Data cCodPeg as String
    Data cCodInt as String
	
	Method New()

    Method openRoom()
	Method openRooBrw()
	Method openMsgBrw(aMensagem)
	Method msgFilter(aMensagens)
	Method getRoomDesc(cCodTipo)
    Method getPhaseDesc(cFase)
    Method getSituationDesc(cSituac)
	Method upFileBrows(cId,oListAnexo,aAnexList)
	Method vldPostMsg(cMessage,oListHist,aMensagens)
	Method attacFilter(aAnexList,cId)
	Method procFinRoom()
	Method downFileBr(aAnexList,nAtFile,lAllFiles)
    Method chkOriPeg(cCodPeg,cCodInt)

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe PLChatHAT
    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method New(cNumPeg) Class PLProcView

    _Super:new()

	BCI->(DbSetOrder(14)) //BCI_FILIAL+BCI_CODPEG
    if !Empty(cNumPeg) .And. BCI->(DbSeek(xFilial("BCI")+cNumPeg))
		self:cCodRDA   := BCI->BCI_CODRDA
		self:cNomeRDA  := Alltrim(Posicione("BAU",1,xFilial("BAU")+BCI->BCI_CODRDA,"BAU->BAU_NOME"))
		self:cDescTipo := self:getRoomDesc(BCI->BCI_TIPGUI)
        self:cFase := self:getPhaseDesc(BCI->BCI_FASE)
        self:cSituac := self:getSituationDesc(BCI->BCI_SITUAC)		
		self:setRoomKey(cNumPeg)
	endIf

Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openRoom
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method openRoom() Class PLProcView

	Local lOpenRoom := .F.
	Local lComun    := .F.
	Local cMsgErro  := ''
	
	MsAguarde( {|| lComun := self:prGetRoom() }, STR0001 , STR0002, .F.) //'Mensageria' ## 'Carregando a sala de interações, aguarde...'
	
	if lComun
		//Sala ja existente, carrega as mensagens
		if !empty( self:getRoomId() )
			MsAguarde( {|| lComun := self:prGetMsg() }, STR0001 , STR0003, .F.)
			cMsgErro := iif(!lComun,STR0004,'') //"Não foi possível carregar as mensagens da sala, contate o administrador do sistema."
			if lComun
				self:setStatBCI(self:getRoomKey(),cValToChar(self:getStatus())) //Atualiza o status da sala
				lOpenRoom := .T.
			endIf
			
		//Nao foi encontrada a sala, deseja cria-la?
		elseIf self:getCodeErr() == GET_EMPTY	
			
			if MsgNoYes(STR0006) //"Não há sala aberta para esta guia, deseja cria-la?"
				MsAguarde( {|| lComun := self:prPostRoom() }, STR0001 , STR0008, .F.) //'Criando a sala de interações, aguarde...'
				cMsgErro := iif(!lComun,STR0009,'') //"Não foi possível criar a sala de chat, contate o administrador do sistema."
				if lComun
					lOpenRoom := .T.
					self:setStatBCI(self:cRoomKey,'1')
					MsAguarde( {|| self:prGetMsg() }, STR0001 , STR0003, .F.)
				endIf
			endIf

		endIf
	else
		cMsgErro := STR0010 //"Não foi possível carregar a sala de chat, contate o administrador do sistema."
	endif

	if lOpenRoom
		self:openRooBrw()
	elseIf !Empty(cMsgErro)
		MsgInfo(cMsgErro)
	endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openRooBrw
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method openRooBrw() Class PLProcView

	Local oDlg		  := nil	
	Local aButtons 	  := {}
	Local aMensagens  := {}
	Local nColunaIni  := 35
	Local cTitulo	  := STR0011 //"Mensageria"
	Local cMessage    := ""
	Local cDateRoom   := self:getDataMask(Substr(self:getCreaTim(),1,10))
	Local cTimeRoom   := Substr(self:getCreaTim(),12,8)
	Local cNumPeg     := self:getRoomKey()
	Local cDescTipo   := self:cDescTipo
	Local cNomeRDA    := self:cNomeRDA
	Local cCodRDA     := self:cCodRDA
    Local cFase       := self:cFase
    Local cSituac     := self:cSituac
	Local cStatusRoom := ROOM_STATUS[self:getStatus()]
	Local oFont       := NIL

	//Adiciona botoes adicionais
	//aadd(aButtons,{"PEDIDO",{|| PLS790VAO('8') },STR0012, STR0012} ) //"Visualizar Guia"

	nTamVerti := 600
	nTamHoriz := 740

	DEFINE FONT oFont  NAME "Arial" size 0,-12 BOLD
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO nTamVerti,nTamHoriz of oMainWnd PIXEL


    //Linha 1
	@ 035,010 SAY STR0054 SIZE 100,010 PIXEL OF oDlg //"Número Guia:"
	@ 042,010 MSGET cNumPeg WHEN .F. SIZE 070,010 PIXEL OF oDlg

	@ 035,100 SAY STR0016 SIZE 100,010 PIXEL OF oDlg //"Código RDA:"
	@ 042,100 MSGET cCodRDA WHEN .F. SIZE 080,010 PIXEL OF oDlg

	@ 035,240 SAY STR0017 SIZE 100,010 PIXEL OF oDlg //"Nome RDA:"
	@ 042,240 MSGET cNomeRDA WHEN .F. SIZE 120,010 PIXEL OF oDlg

	//Linha 2
	@ 060,010 SAY STR0055 SIZE 100,010 PIXEL OF oDlg //"Fase:"
	@ 067,010 MSGET cFase WHEN .F. SIZE 050,010 PIXEL OF oDlg
	
	@ 060,100 SAY STR0056 SIZE 100,010 PIXEL OF oDlg //"Situação:"
	@ 067,100 MSGET cSituac WHEN .F. SIZE 120,010 PIXEL OF oDlg

	@ 060,240 SAY STR0018 SIZE 100,010 PIXEL OF oDlg //"Data Criação Sala:"
	@ 067,240 MSGET cDateRoom WHEN .F. SIZE 050,010 PIXEL OF oDlg

	@ 060,310 SAY STR0019 SIZE 100,010 PIXEL OF oDlg //"Hora Criação Sala:"
	@ 067,310 MSGET cTimeRoom WHEN .F. SIZE 050,010 PIXEL OF oDlg

	//Linha 3
	@ 085,010 SAY STR0020 SIZE 100,010 PIXEL OF oDlg //"Tipo:"
	@ 092,010 MSGET cDescTipo WHEN .F. SIZE 080,010 PIXEL OF oDlg

	//Linha 4
	@ 115,010 SAY STR0035 SIZE 100,010 PIXEL OF oDlg //"Mensagem:"    
	@ 122,010 GET cMessage Memo SIZE 210,040 PIXEL OF oDlg

	//Panel de Pendencia
	@ 115,240 SAY STR0022 SIZE 100,010 PIXEL OF oDlg //"Status Sala:"
	@ 122,240 MSGET cStatusRoom WHEN .F. SIZE 120,010 PIXEL OF oDlg
	
	oButIni := TButton():New( 140, 240, STR0051, oDlg, ;
	{|| self:vldPostMsg(@cMessage,@oListHist,@aMensagens,@cStatusRoom) },120,15,nil,oFont,.F.,.T.,.F.,nil,.F.,nil,nil,.F.) //"Adicionar Mensagem"
	
	//Interacoes
	@ nColunaIni + 140, 010 SAY STR0023 SIZE 100,010 PIXEL OF oDlg //"Histórico de Interações"

	oListHist := TCBROWSE():New(nColunaIni + 150, 010, nTamHoriz*0.48 ,100 ,,;
		{},{40,40},;
		oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

	oListHist:AddColumn(TcColumn():New(STR0024 ,{ || aMensagens[oListHist:nAt, 1] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil)) //'Data Inter.'
	oListHist:AddColumn(TcColumn():New(STR0025 ,{ || aMensagens[oListHist:nAt, 2] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil)) //'Hora Inter.'
	oListHist:AddColumn(TcColumn():New(STR0026 ,{ || aMensagens[oListHist:nAt, 3] },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //'Interação'
	oListHist:AddColumn(TcColumn():New(STR0027 ,{ || aMensagens[oListHist:nAt, 7] },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //'Anexos'
	oListHist:AddColumn(TcColumn():New(STR0028 ,{ || aMensagens[oListHist:nAt, 4] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil)) //'Mensagem'

	oListHist:BLDBLCLICK := { || if( len(aMensagens) > 0, self:openMsgBrw(@aMensagens,@oListHist), nil) } 
	oListHist:bChange :=  {|| oListHist:SetArray(self:msgFilter(aMensagens)), oListHist:Refresh()}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnchoiceBar(oDlg,,{|| oDlg:End()},.F.,aButtons,,,,,,.F.) } )

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRoomDesc
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method getRoomDesc(cCodTipo) Class PLProcView

	Local cDescTipo := ''
	
	cCodTipo := Alltrim(cCodTipo)

	Do Case 
		Case cCodTipo == "01"
			cDescTipo := "Consulta"
		Case cCodTipo == "02"
			cDescTipo := "SADT"
		Case cCodTipo == "03"
			cDescTipo := "Sol. Internacao"
		Case cCodTipo == "05"
			cDescTipo := "Resumo Internação"
		Case cCodTipo == "06"
			cDescTipo := "Honorários"
		/*Case cCodTipo == "07"
			cDescTipo := "Anexo Quimioterapia"
		Case cCodTipo == "08"
			cDescTipo := "Anexo Radioterapia"
        Case cCodTipo == "09"
			cDescTipo := "Anexo OPME"*/
        Case cCodTipo == "10"
			cDescTipo := "Recurso de Glosa"
       /* Case cCodTipo == "11"
			cDescTipo := "Sol. Prorrogação Int."
        Case cCodTipo == "12"
			cDescTipo := "Outras Despesas"
        Case cCodTipo == "13"*/
			cDescTipo := "Odontologica"
	EndCase

Return cDescTipo

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getPhaseDesc
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method getPhaseDesc(cFase) Class PLProcView

	Local cFaseDesc := ''
	
	cFaseDesc := Alltrim(cFase)

	Do Case 
		Case cFase == "1"
			cFaseDesc := "Em Digitação"
		Case cFase == "2"
			cFaseDesc := "Em Conferência"
		Case cFase == "3"
			cFaseDesc := "Pronto"
	EndCase

Return cFaseDesc

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getSituationDesc
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method getSituationDesc(cSituac) Class PLProcView

	Local cSituacDesc := ''
	
	cSituacDesc := Alltrim(cSituac)

	Do Case 
		Case cSituac == "1"
			cSituacDesc := "Ativo"
		Case cSituac == "2"
			cSituacDesc := "Cancelado"
		Case cSituac == "3"
			cSituacDesc := "Bloqueado"
	EndCase

Return cSituacDesc

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openMsgBrw
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method openMsgBrw(aMensagens,oListHist) Class PLProcView

	Local oDlg
	Local cCadastro := STR0029 //'Visualizar Interação'
	Local aButtons  := {}
	Local aAnexList := {}
	Local lComun    := .F.
	Local nAt       := oListHist:nAt

	Local cDate     := aMensagens[nAt,1]
	Local cTime     := aMensagens[nAt,2]
	Local cType     := aMensagens[nAt,3]
	Local cMsg      := aMensagens[nAt,4]
	Local cId       := aMensagens[nAt,5]
	Local cAnexo    := aMensagens[nAt,7]

	if cType == 'Auditor'
		aadd(aButtons,{"PEDIDO",{|| self:upFileBrows(cId,@oListAnexo,@aAnexList) },STR0030,STR0030} ) //"Adicionar Anexos"
	endIf
	aadd(aButtons,{"PEDIDO",{|| self:downFileBr(aAnexList,0,.T.) },STR0031,STR0031} ) //"Download Anexos"
	
	if !Empty(cDate) .And. !Empty(cTime) .And. !Empty(cMsg)

		if cAnexo == STR0038 .And. !empty(cId)
			MsAguarde( {|| lComun := self:prGetAttach(cId) }, STR0001 , STR0032, .F.) //'Carregando a mensagem, aguarde...'
			//Busca os anexos e seus links
			if lComun
				self:getAttach(cId)
			endIf
		endIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 10,0 To 600, 500 of oMainWnd PIXEL

		@ 035,010 SAY STR0033 SIZE 100,010 PIXEL OF oDlg //"Data Interação"
		@ 042,010 MSGET cDate WHEN .F. SIZE 045,010 PIXEL OF oDlg

		@ 035,080 SAY STR0034 SIZE 100,010 PIXEL OF oDlg //"Hora Interação"
		@ 042,080 MSGET cTime WHEN .F. SIZE 045,010 PIXEL OF oDlg

		@ 060,010 SAY STR0026 SIZE 100,010 PIXEL OF oDlg //"Interação"
		@ 067,010 MSGET cType WHEN .F. SIZE 100,010 PIXEL OF oDlg

		@ 090,010 SAY STR0035 SIZE 100,010 PIXEL OF oDlg //"Mensagem:"
		@ 097,010 GET cMsg Memo WHEN .F. SIZE 230,040 PIXEL OF oDlg

		//Anexos
		@ 150,010 SAY STR0036 SIZE 100,010 PIXEL OF oDlg //"Anexos:"
		oListAnexo := TCBROWSE():New(157,010,230,100 ,,;
			{},{40,40},;
			oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )
			
		oListAnexo:AddColumn(TcColumn():New(STR0037,{ || aAnexList[oListAnexo:nAt, 1] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil)) //'Arquivo'

		oListAnexo:BLDBLCLICK := { || if( len(aAnexList) > 0, self:downFileBr(aAnexList,oListAnexo:nAt), nil) } 
		oListAnexo:bChange :=  {|| oListAnexo:SetArray(self:attacFilter(aAnexList,cId)), oListAnexo:Refresh()}

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnchoiceBar(oDlg,,{|| oDlg:End()},.F.,aButtons,,,,,,.F.) } )

		//Atualiza Tela
		oListHist:SetArray(self:msgFilter(aMensagens))
		oListHist:Refresh()

	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} msgFilter
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method msgFilter(aMensagens) Class PLProcView

	Local oAux      := self:getMessages()
	Local nX        := 0
	Local cDate     := ""
	Local cTime     := ""
	Local cType     := ""
	Local cMsg      := ""
	Local cId       := ""
	Local cCreation := ""
	Local lAnexos   := .F.

	aMensagens := {}

	//Adiciona linha vazia
	if self:getCodeErr() == GET_EMPTY
		aadd(aMensagens, {cDate,;
							cTime,;
							cType,;
							cMsg,;
							cId,;
							cCreation,;
							iif(lAnexos,STR0038,STR0039) }) //'Sim' ## 'Nao'

	//Carrega as interacoes da sala
	else
		for nX := 1 to len(oAux['items'])
			
			cDate     := self:getDataMask(Substr(oAux['items',nX,'creationTime'],1,10))
			cTime     := Substr(oAux['items',nX,'creationTime'],12,8)
			cType     := iif(oAux['items',nX,'type']==1,'Auditor','Prestador')
			cMsg      := oAux['items',nX,'message']
			cId       := oAux['items',nX,'id']
			cCreation := oAux['items',nX,'creationTime']
			lAnexos   := oAux['items',nX,'hasAttachment']

			aadd(aMensagens, {cDate,;
							cTime,;
							cType,;
							DecodeUTF8(cMsg),;
							cId,;
							cCreation,;
							iif(lAnexos,STR0038,STR0039) })
		next
		aDadH := aSort(aMensagens,,, { |x,y| x[6] > y[6] } )
	endIf

return aMensagens


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} attacFilter
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method attacFilter(aAnexList,cId) Class PLProcView

	Local aAux := {}
	Local nX   := 0

	aAnexList  := {}	
	aAux := self:getAttach(cId)

	if len(aAux) > 0
 		for nX := 1 to len(aAux[3])
			aadd(aAnexList, {aAux[3,nX],;         //Arquivo
							 aAux[1]+aAux[3,nX],; //URL	
							 aAux[2] })           //Sas Token 
		next
	//Linha Vazia
	else
		aadd(aAnexList,{"","",""})
	endIf

return aAnexList


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} downFileBr
    Funcao para download de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method downFileBr(aAnexList,nAtFile,lAllFiles) Class PLProcView

	Local lHaveAnex  := .F.
	Local cMsg       := ""
	Local nX         := 0

	Default lAllFiles  := .F.

	//Verifica se os anexos com url/nome para serem baixados
	if lAllFiles
		for nX := 1 to len(aAnexList)
			lHaveAnex := !Empty(aAnexList[nX,1]) .And. !Empty(aAnexList[nX,2])
		next
	else
		lHaveAnex := !Empty(aAnexList[nAtFile,1]) .And. !Empty(aAnexList[nAtFile,2])
	endif

	if lHaveAnex
		cMsg := self:downFile(aAnexList,nAtFile,lAllFiles)
	elseIf lAllFiles
		cMsg := STR0040 //"Não foram encontrados arquivos anexados para esta mensagem."
	endIf

	if !empty(cMsg)
		Aviso(STR0007,cMsg,{ "Ok" }, 2 ) //"Atenção"
	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} upFileBrows
    Funcao para upload de mensagens PLX x HAT

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method upFileBrows(cId,oListAnexo,aAnexList) Class PLProcView

	Local cMsgAviso  := self:uploadFile(cId)
	
	if !empty(cMsgAviso)
		//Atualiza json de mensagens
		MsAguarde( {||self:prGetMsg() }, STR0001 , STR0003, .F.)
		Aviso( STR0007,cMsgAviso,{ "Ok" }, 2 )

		//Atualiza Tela
		oListAnexo:SetArray(self:attacFilter(aAnexList,cId))
		oListAnexo:Refresh()
	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldPostMsg
    Faz validacoes e confirma o post de mensagem

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method vldPostMsg(cMessage,oListHist,aMensagens,cStatusRoom) Class PLProcView

	Local lRet      := .F.
	Local nStatRoom := 0
	Local cMsgRet   := ""
	Local lIntHat	:= 	GetNewPar("MV_PLSHAT","0") == "1"
	Default cMessage := ""

	if Empty(cMessage)
		cMsgRet := STR0041 //"O campo 'Mensagem' é obrigatório."
	
	//elseIf Alltrim(cStatusRoom) == Alltrim(ROOM_STATUS[2])
	//	cMsgRet := "A sala está aguardando uma resposta do Prestador."

	elseIf Alltrim(cStatusRoom) == Alltrim(ROOM_STATUS[3])
		cMsgRet := STR0042 //"A sala já está finalizada."

	/*elseIf self:getAnalyzed()
		cMsgRet := STR0043 //"Esta guia já foi analisada pelo auditor."*/

	elseIf MsgYesNo(STR0044) //"Confirma a inclusão da Mensagem?"
			
		MsAguarde( {|| lRet := self:prPostMsg(cMessage,2) }, STR0001 , STR0045, .F.) //'Adicionando a mensagem, aguarde...'
		cMsgRet := iif(!lRet,STR0047,'')//"Não foi possível enviar a 'Mensagem' para a Mensageria."
		if lRet
			nStatRoom := self:getStatus()			
			cStatusRoom := ROOM_STATUS[nStatRoom]
			self:setStatBCI(self:getRoomKey(),cValtoChar(nStatRoom))

			MsAguarde( {|| self:prGetMsg() }, STR0001 , STR0045, .F.)
			cMsgRet := STR0046 //"Mensagem adicionada com sucesso."
			if lIntHat .and. FindFunction( "PLSNotifica") .and. FWAliasInDic("BQ7")
				PLSNotifica('000002', self:cCodRDA, cMessage)
			endif
			cMessage  := ''
			//Atualiza Tela
			oListHist:SetArray(self:msgFilter(aMensagens))
			oListHist:Refresh()
		endIf
	endIf

	if !empty(cMsgRet)
		Aviso( STR0007,cMsgRet,{ "Ok" }, 2 )
	endIf	

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFinRoom
    Finaliza uma sala ao realizar a auditoria

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method procFinRoom() Class PLProcView

	Local lRet    := .F.

	lRet := self:prGetRoom() //MsAguarde( {|| lRet := self:prGetRoom() }, STR0001 , STR0048, .F.) //'Finalizando a sala de interações, aguarde...'
	if lRet
		lRet := self:prPostMsg(self:getMsgEnd(),3) //MsAguarde( {|| lRet := self:prPostMsg(self:getMsgEnd(),3) }, STR0001 , STR0048, .F.) //'Finalizando a sala de interações, aguarde...'
		if lRet
			self:setStatBCI(self:getRoomKey(),'3')
		endIf
	endIf
	self:destroy()

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} chkOriPeg
    Verifica se a PEG foi criada no HAT.

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Method chkOriPeg(cCodPeg,cCodInt) Class PLProcView

	Local lRet    := .F.

    BCI->(DbSetOrder(14)) //BCI_FILIAL+BCI_CODPEG

    If BCI->(DbSeek(xFilial("BCI")+cCodPeg))
        If !Empty(BCI->BCI_IDXML)
            BXX->(DbSetOrder(6)) //BXX_FILIAL+BXX_CODINT+BXX_CODPEG               
            If BXX->(DbSeek(xFilial("BXX")+cCodInt+cCodPeg))
                lRet := IIF( !Empty(BXX->BXX_PLSHAT), .T., .F.)
            EndIf
        EndIf
    EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLProcView
    Chamada mensageria

    @type  Class
    @author PLS Team
    @since 20240619
/*/
//------------------------------------------------------------------------------------------
Main Function PLMensPrc(cNumPeg,cCodOpe)

	Local oMensageria := nil
	Local cMsg        := ''
	Local aRet        := {}
	Local lMsgSta := BCI->(FieldPos("BCI_MSGSTA")) > 0
	Default cNumPeg   := ""
	Default cCodOpe   := ""
	Private cCadastro := STR0001

	If lMsgSta
		BCI->(DbSetOrder(14)) //BCI_FILIAL+BCI_CODPEG
		if !Empty(cNumPeg) .And. BCI->(DbSeek(xFilial("BCI")+cNumPeg))
			If BCI->BCI_FASE $ '1/2/3            
				oMensageria := PLProcView():New(cNumPeg)            
				If oMensageria:chkOriPeg(cNumPeg,cCodOpe) .OR. BCI->BCI_LOTHAT == "1"
					aRet := oMensageria:vldDadAces()
					if aRet[1]
						oMensageria:openRoom()				
					else
						cMsg := aRet[2]
					endIf
				Else 
					cMsg := STR0050 //"A Mensageria está disponível somente para guias geradas no Portal Autorizador HAT."
				EndIf 
			Else 
				cMsg := "A mensageria está dispónível somente para guias em fase de digitação, conferência ou pronto. " 
			Endif
		else
			cMsg := "Não foi encontrado o registro correspondente no proc. contas (tabela BCI)." 
		endIf
	Else 
		cMsg := "Não foi encontrado o campo de Status na Tabela BCI (BCI_MSGSTA)." 
	EndIf
	
	if !empty(cMsg)
		MsgInfo(cMsg)
	endIf

Return
