#INCLUDE "PLSA790M.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

STATIC aDadHeader := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA790M
Classe modelo de dados da rotina Principal da Auditoria

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
Class PLSA790M

METHOD New() Constructor

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New() Class PLSA790M
Return Self
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ MenuDef ³ Autor ³ Totvs                  ³ Data ³ 16.02.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ MenuDef                                                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aSubMenu 	 := {}
Local aRotConh	 := {}
Local aRet		 := {}        
Local o790C		 := PLS790GEC()
Local cSetor	 := GETNEWPAR('MV_SETJNMD','ND')   //Setor de Junta Médica
Local cInteracao := "PLSAINTE('','AD', '' , '' , '' , '' )"
Local cIntGuiRef := "PLSAINTE('','ADG','Substr(B53->B53_NMGORI,1,4)','Substr(B53->B53_NMGORI,5,4)','Substr(B53->B53_NMGORI,9,2)','Substr(B53->B53_NMGORI,11,8)')"
Local lVisGui    := B4A->(FieldPos('B4A_VISGUI')) > 0
Local aRotInte   := {{ STR0008 ,cInteracao, 0, 0}, ; // "Guia"
		             { STR0038 ,cIntGuiRef, 0, 0}} 	 // "Guia Referência"
Local aRotMensag := {}
Local aRotCarol  := {}
Local aLegPrazos := {}
Local aConsPrazos := {}
Local aRotAdic := {}
Local nI := 0
Local aPacLocal := {}
Local aPendencia := {}

PRIVATE aRotina  := {}              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Sub-Menu
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aAdd( aSubMenu, { STR0001	, "PLS790VAO('1')" , 0, 0} ) //"Contrato"
aAdd( aSubMenu, { STR0002	, "PLS790VAO('2')" , 0, 0} ) //"Familia"
aAdd( aSubMenu, { STR0003	, "PLS790VAO('3')" , 0, 0} ) //"Rda"
aAdd( aSubMenu, { STR0004	, "PLS790VAO('4')" , 0, 0} ) //"Solicitante"
aAdd( aSubMenu, { STR0005	, "PLS790VAO('5')" , 0, 0} ) //"Executante"
aAdd( aSubMenu, { STR0006	, "PLS790VAO('6')" , 0, 0} ) //"Vlr. Cobranca"
aAdd( aSubMenu, { STR0007	, "PLS790VAO('7')" , 0, 0} ) //"Movimentacao"
aAdd( aSubMenu, { STR0008	, "PLS790VAO('8')" , 0, 0} ) //"Guia"
aAdd( aSubMenu, { STR0009	, "PLS790VAO('9')" , 0, 0} ) //"Financeiro"
aAdd( aSubMenu, { STR0010	, "PLS790VAO('10')", 0, 0} ) //"Criticas"
aAdd( aSubMenu, { STR0011	, "PLS790VAO('11')", 0, 0} ) //"Grupo Caren"
aAdd( aSubMenu, { STR0012	, "PLS790VAO('12')", 0, 0} ) //"Classe Caren"
aAdd( aSubMenu, { "Hist. Aud. Guia"	, "PLS790VAO('23')", 0, 0} ) //"Hist. Aud. Guia"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ menu extras para uso em campo.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

aRotConh	:= {{"Guia" , "PLS790BAN('BE2',,'C')", 0, 0},;		// "Guia"
		        {"Item" , "PLS790BAN('BE2',,'I')", 0, 0}}		// "Item"

if GetNewPar("MV_PLSHAT","0") == "1"
	aAdd( aRotConh, { STR0032 , 'PLSVERARQ(B53->B53_NUMGUI,B53->B53_ALIMOV)'   , 0, MODEL_OPERATION_VIEW} )  //"Anexos HAT"
endIf

If ExistBlock("PL790BT1")
	AADD( aSubMenu, { ExecBlock("PL790NOMEBT",.F.,.F. ), ExecBlock("PL790BT1",.F.,.F. ), 0, 0} )
EndIf

If ExistBlock("PL790BT2")
	AADD( aSubMenu, { ExecBlock("PL790NOMEBT",.F.,.F. ), ExecBlock("PL790BT2",.F.,.F. ), 0, 0} )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ aRotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !o790C:lVisible .And. !Empty(o790C:cPerfil) .And. !o790C:lIntSau
	aAdd( aRotina, { STR0013, 'FWMsgRun(, {|| PLS790ANA(0) }, "SÓ UM MOMENTO", "INICIANDO ANÁLISE...")', 0, MODEL_OPERATION_INSERT} ) //'Analisar'
	
	If GetNewPar("MV_PL790NE","0") == "0" .Or. SuperGetMV("MV_PLSSOOL") == "1"  //Se não for a nova auditoria ou se estiver disponível comunicação online 
		aAdd( aRotina, { "Evolução de intern.", 'PLS790ANA(2)', 0, MODEL_OPERATION_INSERT} ) //'Evolução de intern.'
	EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Personalisar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ExistBlock("PLSAUDFI") 
	aAdd( aRotina, { STR0014, 'PLS790VFI', 0, MODEL_OPERATION_INSERT} ) //'Personalizar'
EndIf                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ perfil definido e nao e visual
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !o790C:lVisible .And. !Empty(o790C:cPerfil)            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se nao for interna saude
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !o790C:lIntSau
		aAdd( aRotina, { STR0015 , 'PLS790RTG("2")', 0, MODEL_OPERATION_VIEW} ) 	//'Reservar/Liberar'
		aAdd( aRotina, { STR0016 , 'PLS790RTG("3")', 0, MODEL_OPERATION_VIEW} ) 	//'Enviar p/ Espera'
		aAdd( aRotina, { STR0017 , 'PLS790FAP()'   , 0, MODEL_OPERATION_VIEW} ) 	//'Finaliza Analise Part.'
		aAdd( aRotina, { STR0026 , 'PLSCNGUIA()'   , 0, MODEL_OPERATION_VIEW} )  //Atualizar Browse
		aAdd( aRotina, { STR0030 , 'PLSEXGUAX()'   , 0, MODEL_OPERATION_VIEW} )  //"Anexos Clin. Vinc."
		If lVisGui
			aAdd( aRotina, { "Anexo Radioterapia", 'PLANEXRADI(B53->B53_NUMGUI)'   , 0, MODEL_OPERATION_VIEW} )  //"Anexo Radioterapia"
		EndIf
		aAdd( aRotina, { STR0023 , 'PLS790TDE' 	   , 0, MODEL_OPERATION_VIEW} ) //"Transf. p/ Demanda"
		aAdd( aRotina, { STR0018 , 'PLS790VPR'	   , 0, MODEL_OPERATION_VIEW} ) 	//'Alt. Prioridade' 
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Daqui para baixo vai ficar no menu acoes relacionadas					 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If(PLSALIASEX("BOZ"))
		aAdd( aRotina, { "Hist. GIH", 'PLSGIH(B53->b53_NUMGUI)',0, MODEL_OPERATION_VIEW})
	EndIf
	
	If !o790C:lIntSau
		aAdd( aRotina, { STR0019 , 'PLS790ICO'		, 0, MODEL_OPERATION_VIEW} ) 	//'Inconsistência'
	EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Sub-Menu
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//aAdd( aRotina, { STR0020, "PLS790BAN('BE2')", 0, MODEL_OPERATION_VIEW} ) //'Banco de conhecimento'
aAdd( aRotina, { STR0020, aRotConh, 0, MODEL_OPERATION_VIEW} ) //'Banco de conhecimento'
aAdd( aRotina, { STR0021, aSubMenu, 0, 0} ) //'Relacionados'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Somente se existir o rdmake
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

If ExistBlock("PLSAUDBT") .And. !o790C:lVisible .And. !Empty(o790C:cPerfil)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna opcao do menu e funcao a ser executada
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	aRet := ExecBlock("PLSAUDBT",.F.,.F.,{} )
	
	aAdd( aRotina, { aRet[1], aRet[2], 0, 0} )
EndIf	 

aAdd( aRotina, { STR0028 , aRotInte, 0, MODEL_OPERATION_VIEW} ) 	//'Interação'

IF (o790C:cCodDep $ cSetor) //Se código do auditor estiver contido no departamento de Junta Médica, pode acessar
aAdd( aRotina, { STR0029 , "PLSUPJNT", 0, MODEL_OPERATION_VIEW} ) 	//'Instaura\Libera Junta Médica'
ENDIF

//Opcoes para Mensageria PLS x HAT
if GetNewPar("MV_PLSHAT","0") == "1" .And. B53->(FieldPos("B53_MSGSTA")) > 0
	aRotMensag := {{ STR0039,'PLMensageria(B53->B53_NUMGUI,B53->B53_ORIMOV)', 0, MODEL_OPERATION_VIEW } ,; //"Consultar Sala"
	               { STR0040,'PL790FMens'                   , 0, MODEL_OPERATION_INSERT }} //"Filtrar Guias"

		aAdd( aRotina, { STR0041, aRotMensag, 0, MODEL_OPERATION_VIEW} ) //"Mensageria"
	endIf

if BA0->(FieldPos("BA0_CARURL")) > 0 .And. BA0->(FieldPos("BA0_CARTOK")) > 0
	BA0->(DbSetOrder(1))
	if BA0->(DbSeek(xFilial("BA0")+PlsIntPad())) .And. !Empty(BA0->BA0_CARURL) .And. !Empty(BA0->BA0_CARTOK)
		aRotCarol := {{ STR0054,"P790AtuCar('1')", 0, MODEL_OPERATION_VIEW } ,; //"Atualizar Guia"
	                  { STR0055,"P790AtuCar('2')", 0, MODEL_OPERATION_INSERT }} //"Atualizar Todas Guias"

		aAdd( aRotina, { STR0056, aRotCarol, 0, MODEL_OPERATION_VIEW} ) //"Auditoria Pré"
	endIf
endIf

// Item do Menu para o Prazo de Atendimento
If B53->(FieldPos("B53_DATPRZ")) > 0 .And. FindFunction("PLLegPrzAtend")

	aAdd(aConsPrazos, {STR0043, "FwMsgRun(,{|| PLStaPrzAtend()},,'"+STR0053+"')", 0, MODEL_OPERATION_VIEW}) // "Status dos Prazos" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0044, "FwMsgRun(,{|| PLConPrzBrw('0')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Excedido" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0046, "FwMsgRun(,{|| PLConPrzBrw('1')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Prazo pra Hoje" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0047, "FwMsgRun(,{|| PLConPrzBrw('2')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Prazo em até 3 dias" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0048, "FwMsgRun(,{|| PLConPrzBrw('3')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Prazo em até 7 dias" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0049, "FwMsgRun(,{|| PLConPrzBrw('4')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Prazo em até 14 dias" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0050, "FwMsgRun(,{|| PLConPrzBrw('5')},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Prazo a partir de 14 dias" / "Carregando Prazos..."
	aAdd(aConsPrazos, {STR0051, "FwMsgRun(,{|| PLConPrzBrw()},,'"+STR0053+"')", 0, MODEL_OPERATION_INSERT}) // "Todos os Prazos" / "Carregando Prazos..."

	aAdd(aLegPrazos, {STR0042, "PLLegPrzAtend", 0, MODEL_OPERATION_VIEW}) // "Legenda"
	aAdd(aLegPrazos, {STR0052, aConsPrazos, 0, MODEL_OPERATION_VIEW}) //"Consultas"
	aAdd(aRotina, {STR0045, aLegPrazos, 0, MODEL_OPERATION_VIEW}) // "Prazos do Atendimento"
EndIf

// Ponto de Entrada para inserir novos botões no menu da Auditoria por guia
if ExistBlock("PL790BOT")
	 aRotAdic := ExecBlock("PL790BOT", .F., .F.,{})

	 if ValType(aRotAdic) == "A"
		For nI := 1 To Len(aRotAdic)
			AAdd(aRotina, aRotAdic[nI])
		next
	 endif 
endif

If B53->(FieldPos("B53_PACLOC")) > 0 
	aAdd(aPacLocal, {STR0058,  "FwMsgRun(,{|| PLConPacLoc('0')},,'"+STR0057+"')", 0, MODEL_OPERATION_INSERT}) // "Paciente no Local" / "Carregando Atendimentos..." 
	aAdd(aPacLocal, {STR0059,"FwMsgRun(,{|| PLConPacLoc('1')},,'"+STR0057+"')" , 0, MODEL_OPERATION_INSERT}) // "Urgência e Emergência" / "Carregando Atendimentos..." 
	aAdd(aPacLocal, {STR0060,"FwMsgRun(,{|| PLConPacLoc('2')},,'"+STR0057+"')" , 0, MODEL_OPERATION_INSERT}) // "Demais Atendimentos" / "Carregando Atendimentos..." 
	aAdd(aPacLocal, {STR0061,"FwMsgRun(,{|| PLConPacLoc('')},,'"+STR0057+"')", 0, MODEL_OPERATION_INSERT}) // "Todos os Atendimentos" / "Carregando Atendimentos..."
	aAdd(aRotina, {STR0062, aPacLocal, 0, MODEL_OPERATION_VIEW}) //Prioridade
EndIf

aAdd(aPendencia, { "Incluir / Excluir Pendência de Justificativa Técnica",  "PLControlPend('1')", 0, MODEL_OPERATION_INSERT}) // "Justificativa Técnica" 
aAdd(aPendencia, { "Incluir / Excluir Pendência de Documentos", "PLControlPend('2')" , 0, MODEL_OPERATION_INSERT}) // "Documentação" 
aAdd(aRotina, { "Pendências", aPendencia, 0, MODEL_OPERATION_VIEW}) //Pendências
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da funcao															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return aRotina
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ ViewDef ³ Autor ³ Totvs                  ³ Data ³ 16.02.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ ViewDef													  	    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/               
Static Function ViewDef()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVERARQ
	Realiza o donwload do arquivo
@author  Renan Sakai 
@version P12
@since    06.11.18
/*/
//-------------------------------------------------------------------
Function PLSVERARQ(cNumGuia,cAlias, lAuto)

	Local cEnvServ   := GetEnvServer()
	Local cDirRaiz 	 := GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())
	Local cFile		 := GetNewPar("MV_RELT",'\SPOOL\')
	Local cDirFinal  := cDirRaiz + cFile
	Local cUserPwd   := ""
	Local aInfo      := {}
	Local cDirCsv    := "" 
	Local cFilesDown := ""
	Local cAction    := ""
	Local nX         := 0
	Local nRet       := 0
	Local lOk        := .F.
	Local cHttpGetRet := ""

	Default lAuto	 := .F.
	Default cAlias   := 'BEA'
			
	PLSLogHAT(Replicate("*",20),.F.)
	PLSLogHAT("Iniciando download arquivos, guia: " + cNumGuia,.F.)

	if !Empty(cNumGuia)

		Do Case
			Case cAlias == 'BEA' .Or. cAlias == 'BE4'
				cAction := 'authorizations'
			Case cAlias == 'B4A'
				cAction := 'clinicalAttachments'
			Case cAlias == 'B4Q'
				cAction := 'treatmentExtensions'
		EndCase
//		cDirFinal := Strtran(cDirFinal,"\\","\") //Ajusta diretorio
		aFiles    := P790PdfDow(cNumGuia,cAction) //Comunica com o server do HAT
		
		if len(aFiles) > 0 

			if !lAuto
				cDirCsv := cGetFile("TOTVS","Selecione o diretório",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY, .F.)
			else
				cDirCsv := ".\"
			endif
			
			if !empty(cDirCsv)
			
				for nX := 1 to len(aFiles)

					if !lAuto
					 	nRet = WDClient("GET", cDirFinal+aFiles[nX,2], STRTRAN(aFiles[nX,1]," ","%20"), "", cUserPwd, @aInfo)
					else
						nRet := 99
						aadd(aInfo, 409)
						aadd(aInfo, 0)
						aadd(aInfo, 0)
					endif

					if nRet == 0
						FErase(cDirCsv+aFiles[nX,2])
						lOk := CpyS2T( cFile + aFiles[nX,2], cDirCsv )

						if lOk
							PLSLogHAT("Arquivo " + aFiles[nX,1] + " copiado com sucesso.",.F.)
							cFilesDown += aFiles[nX,2] + Chr(10)
						else
							PLSLogHAT("Falha ao copiar o arquivo " + aFiles[nX,1] + " para o diretório " + cDirCsv,.F.)
						endIf
					else
						cHttpGetRet := HttpGet(STRTRAN(aFiles[nX,1]," ","%20"))
						PLSLogHAT("* Erro ao baixar o arquivo: " + AllTrim(Str(nRet)) + " no download.",.F.)
						PLSLogHAT("* HttpRespCode: " + AllTrim(Str(aInfo[1])),.F.)
						PLSLogHAT("* Erro2: " + AllTrim(Str(aInfo[2])),.F.)
						PLSLogHAT("* Erro3: " + AllTrim(Str(aInfo[3])),.F.)
						PLSLogHAT("* Resposta HttpGet: " + AllTrim(cHttpGetRet))
					endif
				next

				if lOk
					Aviso( STR0033,STR0034 + Chr(10) + cFilesDown,{ STR0037 }, 2 ) //"Atenção" ### "Download do(s) arquivo(s) realizado com sucesso. Arquivos: " ### "Ok" 
				else
					Aviso( STR0033,STR0035,{ STR0037 }, 2 ) //"Atenção" ### "Falha ao copiar arquivo(s)." ### "Ok" 
				endIf

			endIf

		endIf
	else
		Aviso( STR0033,STR0036,{ STR0037 }, 2 ) //"Atenção" ### "O número da guia no prestador não está preenchido." ### "Ok" 
	endIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ ModelDef³ Autor ³ Totvs                  ³ Data ³ 16.02.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ ModelDef		                                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSA790M  ³ Autor ³ Totvs			    	³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA790M
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLConPacLoc
--DSAUBE-23751 Opção na Auditoria p/ Filtrar Paciente no Local
@author Gabriela Cattin
@version Protheus 12
@since 07/03/2024
/*/
//-------------------------------------------------------------------
Function PLConPacLoc(cTipoFiltro)

    Default cTipoFiltro := ""

    If ValType(oB53) == "O"

        oB53:CleanFilter()
        oB53:CleanExFilter()
        oB53:DeleteFilter("CUSTOM")

        cFiltro := GetPrioriAten(cTipoFiltro)
       
        oB53:AddFilter("Filial", cFiltro, .T., .T., "B53", Nil, Nil, "CUSTOM")
        oB53:SetFilterDefault(cFiltro)
        oB53:Refresh(.T.)

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrioriAten
Retorna o Filtro de Acordo com o Tipo de Prioridade de Atendimento

@author Gabriela Cattin
@version Protheus 12
@since 07/03/2024
/*/
//-------------------------------------------------------------------
Static Function GetPrioriAten(cTipoFiltro)

    Local cFiltro := ""

    Default cTipoFiltro := ""

    cFiltro := " B53_FILIAL = '"+xFilial("B53")+"'"
	if !empty(cTipoFiltro)
		cFiltro += " AND B53_SITUAC <> '1' "
		cFiltro += " AND B53_STATUS <> '6' "
	endif

    Do Case
        Case cTipoFiltro == "0" // Paciente no Local
            cFiltro += " AND B53_PACLOC = '1' "

        Case cTipoFiltro == "1" // Urgência e Emergência
            cFiltro += " AND B53_CARINT = 'U' "

        Case cTipoFiltro == "2" // "Demais Atendimentos"
			cFiltro += " AND B53_PACLOC <> '1' "
			cFiltro += " AND B53_CARINT <> 'U' "
    EndCase

    If ExistBlock("PL790FIL")
	    cFiltro += ExecBlock("PL790FIL")
    EndIf

	//Altera filtro para executar como SQL
	cFiltro := "@" + cFiltro
	cFiltro := StrTran(cFiltro, ".AND.", " AND ")
	cFiltro := StrTran(cFiltro, ".and.", " AND ")
	cFiltro := StrTran(cFiltro, ".OR.", " OR ")
	cFiltro := StrTran(cFiltro, ".or.", " OR ")

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} PLControlPend
Cria a dialog de incluir/remover pendências
@author Nicole Luna
@version Protheus 12
@since 28/10/2025
/*/
//-------------------------------------------------------------------
Function PLControlPend(cOption)
	Local cObj 		 := ''
	Local cAlias  	 := B53->B53_ALIMOV
	Local cNumGui 	 := B53->B53_NUMGUI
	Local cStatus 	 := ""
	Local cAcao    	 := ""
	Default cOption  := '1'

	cObj := iif(cOption == '1', "justificativa técnica", "documentação")

	If !empty(cAlias) .AND. !empty(cNumGui)
		&(cAlias+"->( DbSetOrder(" + iif(cAlias == 'BE4', "2", "1") + ") )")
		If &(cAlias+'->( DbSeek(xFilial("' + cAlias + '")+cNumGui) )')
			cStatus := &(cAlias + "->" + cAlias + "_STTISS")
			If cStatus $ "2,4,5"
				If cStatus == '2' .OR. (cStatus == '4' .AND. cOption == '1') .OR.  (cStatus == '5' .AND. cOption == '2')
					cAcao := iif(cStatus == '2', "incluir", " remover")
					If MsgYesNo("Deseja " + cAcao + " a pendência de " + cObj + "?")
						PLUpdtStts(cAlias, cNumGui, iif(cAcao == "incluir", .T., .F.), iif(cOption == '1', .T., .F.))
						//Internacao e prorrogacao gera BEA tambem, necessario alterar o STTISS da BEA para nao gerar inconsistencias
						If	cAlias $ 'BE4,B4Q'
							BEA->( DbSetOrder(1) )
							If BEA->( DbSeek(xFilial("BEA") + cNumGui))
								PLUpdtStts("BEA", cNumGui, iif(cAcao == "incluir", .T., .F.), iif(cOption == '1', .T., .F.), .F.)
							Endif 
						Endif 
					Endif
				Else
					MsgAlert("A guia já possui pendência de " + iif(cStatus == '4', "justificativa técnica", "documentação") + ". Remova esta pendência primeiro.")
				Endif
			Else 
				MsgAlert("A guia se encontra em um status que não permite esta ação!") //A guia se encontra em um status que não permite esta ação!
			Endif
		Endif
	Else
		MsgAlert("Não foi possível identificar o alias de movimentação ou o número da guia") //Não foi possível identificar o alias de movimentação ou o número da guia
	Endif 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLUpdtStts
Atualiza o STATUS TISS da GUIA
@author Nicole Luna
@version Protheus 12
@since 28/10/2025
/*/
//-------------------------------------------------------------------
Function PLUpdtStts(cAlias, cNumGui, lInclui, lJustTec, lShowMsg)
	Default cAlias   := ""
	Default cNumGui  := ""
	Default lInclui  := .T.
	Default lJustTec := .T.
	Default lShowMsg := .T.

	&(cAlias+"->(RecLock('"+cAlias+"',.F.))")
	If lInclui
		If lJustTec
			&(cAlias + "->" + cAlias + "_STTISS") := "4" //Aguardando justificativa tecnica do solicitante
		Else
			&(cAlias + "->" + cAlias + "_STTISS") := "5" //Aguardando documentacao do prestador
		Endif
	Else
		&(cAlias + "->" + cAlias + "_STTISS") := "2" //Em analise
	Endif
	&(cAlias+"->( MsUnlock() )")

	If lShowMsg
		MsgInfo("A pendência de " + iif(lJustTec, "justificativa técnica", "documentação") + iif(lInclui, " foi incluída ", " foi removida ") + "com sucesso para a guia " + cNumGui)
	Endif

Return 
