#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEX101.CH" 

// Códigos de mensagens padronizadas
#DEFINE GFEX101001 'GFEX101001'

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEX101
Agente Validador de Doc Carga
Uso Generico.

@sample
GFEX101()

@author Felipe Rafael Mendes
@since 13/10/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEX101()

	Private oBrowse

	//Verifica se o ERP integrado é DATASUL
	If SuperGetMV("MV_ERPGFE",,"2") != '1' .AND. SuperGetMV("MV_CADERP",,"1") == '1'
		Help( ,, 'HELP',, "Está rotina é utilizada apenas na integrações com o ERP Datasul.", 1, 0)
		Return .F.	
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW1")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEX101")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Monitor de Liberação de Documentos de Carga") // Descrição do browse //

	oBrowse:SetFilterDefault("GW1_SIT == '2' .AND. GW1_ORIGEM  == '2' ")  

	oBrowse:Activate() 
Return Nil

//-------------------------------------------------------------------  

Static Function MenuDef()

	Local aRotina := {}        

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE "Visualizar" 			ACTION "VIEWDEF.GFEC040" 	OPERATION 2  ACCESS 0  	//"Visualizar"
	ADD OPTION aRotina TITLE "Alterar" 			ACTION "GFEX101ALT()"      	OPERATION 6  ACCESS 0  	//"Alterar"
	ADD OPTION aRotina TITLE "Validar Todos" 		ACTION "GFEX101APR(.T.)"		OPERATION 2  ACCESS 0  
	ADD OPTION aRotina TITLE "Validar Registro" 	ACTION "GFEX101REG()" 		OPERATION 9  ACCESS 0   
	ADD OPTION aRotina TITLE "Erros"             	ACTION "GFEX101ERR()" 		OPERATION 7  ACCESS 0  

Return aRotina       
//--------------------------                                                
Function GFEX101REG()     
	Local cRet := ""

	GFEX101ONE()

	dbSelectArea("GW0")
	dbSetOrder(1)
	If dbSeek(xFilial("GW0") + PADR("GW1" , TamSX3("GW0_TABELA" )[1],'') + GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
		cRet := GFEX101ERM()
	Else
		If !IsBlind()
			MSGINFO("Registro validado com sucesso")
		EndIf
	EndIf

Return cRet
//-----------------------------------------------------------------
// Retorna a mensagem de Erro e também o retorno da função GFEX101MSG()
Function GFEX101ERM()
	Local cRet 	  := ""
	Local GFEResult := GFEViewProc():New()

	cRet := GFEX101MSG()
	If !IsBlind()
		GFEResult:Add(cRet)
		GFEResult:Show("Validação dos Documentos de Carga", "Validação dos Documentos de Carga", "", "")
	Else
		GFEConout("ERROR", "[WSGFE.GFEINSGW1ENT] Erro na validação do documento de carga. Motivo: " + cRet, .F.)

		GFEResult:EnableLog("valida_doc_carga","Validação dos Documentos de Carga")
		GFEResult:Add(cRet)
		GFEResult:GFELOG:Save()
		GFEResult:GFELOG:EndLog()
	EndIF

Return cRet
//-----------------------------------------------------------------
Function GFEX101ERR()

	Local GFEResult := GFEViewProc():New()

	cRet := GFEX101MSG()

	If !IsBlind()
		GFEResult:Add(cRet)
		GFEResult:Show("Validação dos Documentos de Carga", "Validação dos Documentos de Carga", "", "")
	Else
		GFEResult:EnableLog("valida_doc_carga","Validação dos Documentos de Carga")
		GFEResult:Add(cRet)
		GFEResult:GFELOG:Save()
		GFEResult:GFELOG:EndLog()
	EndIF

Return

//-----------------------------------------------------------------
//Função que chama o Model do GFEA044 para Alteração
Function GFEX101ALT()

	RecLock("GW1",.F.)
	GW1->GW1_SIT := '1'
	GW1->(MsUnlock())

	FWExecView("",'GFEA044',MODEL_OPERATION_UPDATE,,{||.T.})

	RecLock("GW1",.F.)
	GW1->GW1_SIT := '2'
	GW1->(MsUnlock())

Return     
//-------------------------------------------------------------------
Function GFEX101APR(lInterface)
	Local cFilialTemp := cFilAnt
	Local cEmpresa := SM0->M0_CODIGO
	Default lInterface := .F. 

	dbSelectArea("SM0")
	dbSeek(SM0->M0_CODIGO)
	While !SM0->(Eof()) .AND. SM0->M0_CODIGO == cEmpresa

		cFilAnt := SM0->M0_CODFIL

		GFEX101ALL(lInterface)

		SM0->(DbSkip())
	EndDo    

	cFilAnt := cFilialTemp

Return
//-------------------------------------------------------------------  
//Função que valida todos os Doc Cargas bloqueados de origem "ERP"
Function GFEX101ALL(lInterface)
	Local cQuery    
	Local cAliasGW1
	Default lInterface := .F.

	cQuery := "SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1_NRROM, R_E_C_N_O_ FROM " + ; 
	RetSQLName("GW1") + " GW1 WHERE GW1_FILIAL = '" + xFilial("GW1") + "' AND GW1_ORIGEM = '2' AND GW1_SIT = '2' AND GW1.D_E_L_E_T_ = ''"
	If !lInterface
		cQuery += " AND NOT EXISTS (SELECT * FROM " + RetSQLName("GW0") + " GW0 WHERE GW0_FILIAL = '" + xFilial("GW1") + "' AND GW0_CHAVE = GW1_FILIAL || GW1_CDTPDC || GW1_EMISDC || GW1_SERDC || GW1_NRDC AND GW0.D_E_L_E_T_ = '') ORDER BY GW1.GW1_NRROM, GW1.R_E_C_N_O_"
	EndIf

	cQuery := ChangeQuery(cQuery)

	cAliasGW1 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

	dbSelectArea(cAliasGW1) 
	(cAliasGW1)->( dbGoTop() )
	While !(cAliasGW1)->(Eof())
		GW1->( dbSetorder(1) )
		If GW1->( dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_CDTPDC+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC) )
			// Caso o usuário desbloqueie manualmente o documento de carga, verifica novamente se a situação continua bloqueada
			If GW1->GW1_SIT == "2"
				GFEX101ONE()
			EndIf

		EndIf
		dbSelectArea(cAliasGW1)
		(cAliasGW1)->(DbSkip())
	EndDo      

	(cAliasGW1)->( dbCloseArea() )

Return   
//-------------------------------------------------------------------
//Função que valida um Doc Carga bloqueado de origem "ERP" (a GW1 vem posicionada) 
Function GFEX101ONE()
	Local oModelPai := FWLoadModel("GFEA044")
	Private nTempoProc := SECONDS()

	GFEX101VAL(oModelPai)

	FreeObj(oModelPai)

Return  
//-------------------------------------------------------------------    
//Função responsavel por fazer a validação
Static Function GFEX101VAL(oModelPai)
	Local aRet			:= {}
	Local cError		:= ''
	Local lRom			:= .F.
	Local aAreaGW1		:= {}
	Local cFiltroGW1	:= ""
	Local cNrRom		:= ""
	Local aAreaGWF		:= {}
	Local cSituacao 	:= "(Desconhecida)"
	Local cMV_GFE002	:= SuperGetMv("MV_GFE002",,"2")
	Local lReabre		:= .F.

	Local cAliasGV4		:= ""

	//Validações de Integridade
	If !ValidacaoSX3(@cError)
		GravaErro(cError)
		oModelPai:DeActivate()
		Return
	EndIf

	If !Empty(GW1->GW1_ROMTO)
		cAliasGV4 := GetNextAlias()

		BeginSQL Alias cAliasGV4
			SELECT GV4.R_E_C_N_O_ RECNOGV4
			FROM %Table:GV4% GV4
			WHERE GV4.GV4_FILIAL = %xFilial:GV4%
			AND GV4.GV4_CDTPOP = %Exp:GW1->GW1_ROMTO%
			AND GV4.GV4_SIT = '1'
			AND GV4.%NotDel%
		EndSQL

		If (cAliasGV4)->(Eof())
			cError := "[" + GFEX101001 + "] " + STR0001
			GravaErro(cError)

			(cAliasGV4)->(dbCloseArea())
			Return
		EndIf

		(cAliasGV4)->(dbCloseArea())
	EndIf

	//Altera para "Recebido" para poder utilizar as validações do Model GFEA044
	If !Empty(GW1->GW1_NRROM)
		If Empty(GW1->GW1_CARREG)
			RecLock("GW1",.F.)
			GW1->GW1_CARREG := GW1->GW1_NRROM // Mantém histórico do nr do romaneio do ERP
			GW1->(MsUnlock())
		EndIf

		GWN->(dbSetOrder(1))
		If !GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM ) )
			cNrRom := GW1->GW1_NRROM

			RecLock("GW1",.F.)
				GW1->GW1_NRROM  := ""
				If GFXCP1212210("GW1_FILROM") .And. !Empty(GW1->GW1_FILROM)
					GW1->GW1_FILROM := ""
				EndIf
			GW1->(MsUnlock())
		Else
			If GWN->GWN_SIT == "4"
				RecLock("GW1",.F.)
					GW1->GW1_NRROM  := ""
					GW1->GW1_CARREG := ""
					If GFXCP1212210("GW1_FILROM") .And. !Empty(GW1->GW1_FILROM)
						GW1->GW1_FILROM := ""
					EndIf
				GW1->(MsUnlock())
			ElseIf GWN->GWN_SIT == "3"
				lReabre := GFEA050REA(.T.)
			
				If lReabre
					lRom := .T.
				Else
					RecLock("GW1",.F.)
						GW1->GW1_NRROM  := ""
						GW1->GW1_CARREG := ""
						If GFXCP1212210("GW1_FILROM") .And. !Empty(GW1->GW1_FILROM)
							GW1->GW1_FILROM := ""
						EndIf
					GW1->(MsUnlock())
				EndIf
			Else
				lRom := .T.
			EndIf
		EndIf
	EndIf

	RecLock("GW1",.F.)
		GW1->GW1_SIT := '1'  
	GW1->(MsUnlock())   

	cSituacao := "Digitado"

	If !lRom .And. !Empty(cNrRom)
		aAreaGWF := GWF->(GetArea())

		GWF->( dbSetOrder(4) )
		GWF->(dbSeek(GW1->GW1_FILIAL + cNrRom)) 
		While !GWF->(Eof()) .And. GWF->GWF_FILIAL + GWF->GWF_NRROM == GW1->GW1_FILIAL + cNrRom
			If GWF->GWF_ORIGEM == "4"
				RecLock("GWF",.F.)
					GWF->GWF_NRROM  := ""
					If GFXCP1212210("GWF_FILROM") .And. !Empty(GWF->GWF_FILROM)
						GWF->GWF_FILROM := ""
					EndIf
				GWF->( MsUnlock() )
			EndIf
			GWF->(dbSkip())
		EndDo
		RestArea(aAreaGWF)
	EndIf

	//
	// Atribui ao romaneio o tipo de operação e/ou classificação de frete e/ou 
	// tipo de veículo informados no documento de carga 
	//
	If lRom .And. GfeVerCmpo({"GW1_ROMTV","GW1_ROMCF","GW1_ROMTO"})

		If (!Empty(GW1->GW1_ROMTV) .And. Empty(GWN->GWN_CDTPVC)) .Or. ;
		(!Empty(GW1->GW1_ROMCF) .And. Empty(GWN->GWN_CDCLFR)) .Or. ;
		(!Empty(GW1->GW1_ROMTO) .And. Empty(GWN->GWN_CDTPOP))

			RecLock("GWN", .F.)

			If !Empty(GW1->GW1_ROMTV) .And. Empty(GWN->GWN_CDTPVC)
				GWN->GWN_CDTPVC := GW1->GW1_ROMTV
			EndIf

			If !Empty(GW1->GW1_ROMCF) .And. Empty(GWN->GWN_CDCLFR)
				GWN->GWN_CDCLFR := GW1->GW1_ROMCF
			EndIf

			If !Empty(GW1->GW1_ROMTO) .And. Empty(GWN->GWN_CDTPOP)
				GWN->GWN_CDTPOP := GW1->GW1_ROMTO
			EndIf

			GWN->( MsUnlock() )

		EndIf

	EndIf

	oModelPai:SetOperation( 4 )
	oModelPai:Activate()
	oModelPai:LMODIFY := .T.

	If oModelPai:VldData() .AND. oModelPai:GetModel("GFEA044_GW8"):VldData()  .AND.  oModelPai:GetModel("GFEA044_GWU"):VldData()    
		oModelPai:CommitData()

		oModelPai:Deactivate()

		// Agrupamento de Itens por Item de Transporte
		//If SuperGetMv("MV_ITEMTRP",,"2") == "1"
		IF Empty(cMV_GFE002)
			cMV_GFE002 := "2"
		end If

		If cMV_GFE002  == "1"
			GFEItemTrp()
		EndIf

		//Verifica se o romaneio existe no GFE 
		GWN->(dbSetOrder(1))
		If !GWN->(dbSeek(xFilial("GWN") + GW1->GW1_NRROM ))
			RecLock("GW1",.F.)  
				GW1->GW1_SIT  	:= "3"
				GW1->GW1_NRROM 	:= ""
				If GFXCP1212210("GW1_FILROM") .And. !Empty(GW1->GW1_FILROM)
					GW1->GW1_FILROM := ""
				EndIf
			GW1->(MsUnlock())

			cSituacao := "Liberado"
		Else
			RecLock("GW1",.F.)  
				GW1->GW1_SIT := "4"
			GW1->(MsUnlock())

			cSituacao := "Embarcado"	
		EndIf

		RecLock("GW1",.F.)  
		// Grava a data e hora da liberação do documento de carga
			GW1->GW1_DTLIB := DATE()
			GW1->GW1_HRLIB := SubStr(Time(), 1, 5)	
		GW1->(MsUnlock())

		//Verifica a data de entrada automática e faz a entrega
		GFE44DtAut() // Só deve ser chamada na inserção de um doc carga

		// Vincula um calculo de origem simulado a um romaneio se já existir
		aAreaGW1:= GW1->(GetArea())

		cFiltroGW1 := GW1->(dbFilter())
		If !Empty(cFiltroGW1)
			GW1->(dbClearFilter())
		EndIf

		GFEA050ALI()
		GFE50LbRom() // verifica e libera o romaneio posicionado

		If !Empty(cFiltroGW1)
			GW1->(dbSetFilter( &("{||" + cFiltroGW1 + "}"),""))
		EndIf	

		RestArea(aAreaGW1)

		GravaErro('',.T.) // Elimina a mensagem de erro na Tab Generica (GW0)
	Else//Se reprovar retorna o registro para o estado bloqueado e armazena a msg do erro

		aRet := oModelPai:GetErrorMessage()  
		cError := aRet[6]       

		oModelPai:Deactivate()	      

		RecLock("GW1",.F.)
		GW1->GW1_SIT := '2'
		cSituacao := "Bloqueado"
		GW1->( MsUnlock() )

		GravaErro(cError)		
	EndIf

	If Type("cGFETrace") == "C" .AND. cGFETrace == "1"
		GFEconout("INFO","[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + PadR(GW1->GW1_NRDC, 8) + ", Serie: " + PadR(GW1->GW1_SERDC, 3) + ", Romaneio: " + GW1->GW1_NRROM + ", Implantacao: " + DTOC(GW1->GW1_DTIMPL) + " " + GW1->GW1_HRIMPL + ", Situacao: " + cSituacao + "] [Tempo: " + PrintElapsed(nTempoProc) + "]")
		nTempoProc := SECONDS()
	EndIf

	aSize( aRet, 0 ) 
	aRet := Nil

Return

Static Function PrintElapsed(nTempoIni)
	Local nTempoTotal
	Local cRet := ""

	nTempoTotal := SECONDS() - nTempoIni

	If nTempoTotal > 60
		cRet := cValToChar(NoRound(nTempoTotal / 60, 1)) + " Minutos"
	Else
		cRet := cValToChar(NoRound(nTempoTotal, 1)) + " Segundos"
	EndIf

Return(cRet)

//------------------------------------------------------------------------- 
//Grava a mensagem do erro da validação
//Necessita que a GW1 esteja posicionada

Static Function GravaErro(cError, lExcluiError)
	Local cLock		:= ""
	Local lGravou 	:= .F.

	Default lExcluiError := .F.

	cLock := "GFEX101_" + xFilial("GW0") + PADR("GW1" , TamSX3("GW0_TABELA" )[1],'') + GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC	

	Do While !lGravou
		If LockByName(cLock, .F., .F.)
			lGravou := .T.

			If !lExcluiError
				dbSelectArea("GW0")
				dbSetOrder(1)
				If dbSeek(xFilial("GW0") + PADR("GW1" , TamSX3("GW0_TABELA" )[1],'') + GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)

					RecLock("GW0",.F.)   
					GW0->GW0_CHAR02 := ''
					GW0->GW0_CHAR03 := ''  
					If Len(cError) < 100
						GW0->GW0_CHAR01 := cError
					Else
						GW0->GW0_CHAR01 := Substring(cError,1,100)
						GW0->GW0_CHAR02 := Substring(cError,101,100)     
						GW0->GW0_CHAR03 := Substring(cError,201,100) 
					EndIf                                                                                                                               	
					GW0->(MsUnlock())			
				Else
					RecLock("GW0",.T.)
					GW0->GW0_FILIAL := xFilial("GW0")
					GW0->GW0_TABELA := "GW1"
					GW0->GW0_CHAVE  := GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC  
					If Len(cError) < 100
						GW0->GW0_CHAR01 := cError  
					Else
						GW0->GW0_CHAR01 := Substring(cError,1,100)
						GW0->GW0_CHAR02 := Substring(cError,101,100) 
						GW0->GW0_CHAR03 := Substring(cError,201,100)			            
					EndIf                                                                                                        	
					GW0->(MsUnlock())
				EndIf
			Else
				dbSelectArea("GW0")
				dbSetOrder(1)
				If dbSeek(xFilial("GW0") + PADR("GW1" , TamSX3("GW0_TABELA" )[1],'') + GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
					RecLock("GW0",.F.)
					dbDelete()
					GW0->(MsUnlock())   
				EndIf
			EndIf

			UnLockByName(cLock, .F., .F.) 
		EndIf
	EndDo	
Return
//------------------------------------------------------------------------- 
//Validações e integridade de chave estrangeira que estão no Dicionario
Static Function ValidacaoSX3(cError)

	/*Validações do Doc Carga*/
	//GW1_CDTPDC
	dbSelectArea("GV5")
	dbSetOrder(1)
	If !dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC) .OR. GV5->GV5_SIT <> '1' 
		cError := "Não foi encontrado '" + GW1->GW1_CDTPDC +"' no cadastro de " +  BuscaNomeX2("GV5") + " com a situação 'Ativo'"
		Return .F.
	EndIf
	//GW1_EMISDC
	dbSelectArea("GU3")
	dbSetOrder(1)
	If !dbSeek(xFilial("GU3")+GW1->GW1_EMISDC) .OR. GU3->GU3_SIT <> '1'  
		cError := "Não foi encontrado Emissor: '" + GW1->GW1_EMISDC +"' no cadastro de " +  BuscaNomeX2("GU3") + " com a situação 'Ativo'"
		Return .F.
	EndIf        
	//GW1_CDREM
	If !dbSeek(xFilial("GU3")+GW1->GW1_CDREM) .OR. GU3->GU3_SIT <> '1'  
		cError := "Não foi encontrado Remetente: '" + GW1->GW1_CDREM +"' no cadastro de " +  BuscaNomeX2("GU3") + " com a situação 'Ativo'"
		Return .F.
	EndIf 
	//GW1_CDDEST
	If !dbSeek(xFilial("GU3")+GW1->GW1_CDDEST) .OR. GU3->GU3_SIT <> '1'
		cError := "Não foi encontrado Destinatario: '" + GW1->GW1_CDDEST +"' no cadastro de " +  BuscaNomeX2("GU3") + " com a situação 'Ativo'"
		Return .F.
	EndIf 
	//GW1_ENTNRC
	If Alltrim(GW1->GW1_ENTNRC) != "" 
		dbSelectArea("GU7")
		dbSetOrder(1)
		If !dbSeek(xFilial("GU7")+GW1->GW1_ENTNRC) .OR. GU7->GU7_SIT <> '1' 
			cError := "Não foi encontrado Cidade de Entrega: '" + GW1->GW1_ENTNRC +"' no cadastro de " +  BuscaNomeX2("GU7") + " com a situação 'Ativo'"	 
			Return .F.
		EndIf
	EndIf

	/*Validações dos Itens do Doc Carga*/
	dbSelectArea("GW8")
	dbSetorder(2)                                                                                                      
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)  

	While !GW8->(Eof()) .AND. GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC == ;
	GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC			

		//GW8_CDCLFR
		If !Empty(GW8->GW8_CDCLFR)
			dbSelectArea("GUB")
			DbSetOrder(1)
			If !dbSeek(xFilial("GUB")+GW8->GW8_CDCLFR) .OR. GUB->GUB_SIT <> '1'   
				cError := "Não foi encontrado '" + GW8->GW8_CDCLFR +"' no cadastro de " +  BuscaNomeX2("GUB") + " com a situação 'Ativo'"
				Return .F.
			EndIf
		Else 
			cError := BuscaNomeX2("GUB") + " não informada. Verifique se o parâmetro de "+BuscaNomeX2("GUB")+" padrão foi preenchido."
			Return .F.                                    
		EndIf

		//GW8_TPITEM
		If !Empty(GW8->GW8_TPITEM)
			dbSelectArea("GUQ")
			DbSetOrder(1)
			If !dbSeek(xFilial("GUB")+GW8->GW8_TPITEM) .OR. GUQ->GUQ_SIT <> '1'   
				cError := "Não foi encontrado '" + GW8->GW8_TPITEM +"' no cadastro de " +  BuscaNomeX2("GUQ") + " com a situação 'Ativo'"
				Return .F.
			EndIf
		EndIf

		GW8->(DbSkip())
	EndDo

	/*Validações dos Trechos do Doc Carga*/
	dbSelectArea("GWU")
	dbSetorder(1)                                                                                                      
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)  

	While !GWU->(Eof()) .AND. GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC == ;
	GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC			

		//GWU_CDTRP
		If !Empty(GWU->GWU_CDTRP)
			dbSelectArea("GU3")
			dbSetOrder(1)
			If !dbSeek(xFilial("GU3")+GWU->GWU_CDTRP) .OR. GU3->GU3_SIT <> '1' .OR. (GU3->GU3_TRANSP <>'1' .AND. GU3->GU3_AUTON <> '1')    
				cError := "Não foi encontrado '" + GWU->GWU_CDTRP +"' no cadastro de " +  BuscaNomeX2("GU3") + " com a situação 'Ativo' que fosse Transportador ou Autônomo "
				Return .F.
			EndIf        
		EndIf

		//GWU_NRCIDD
		dbSelectArea("GU7")
		dbSetOrder(1)
		If !dbSeek(xFilial("GU7")+GWU->GWU_NRCIDD) .OR. GU7->GU7_SIT <> '1'  
			cError := "Não foi encontrado '" + GWU->GWU_NRCIDD +"' no cadastro de " +  BuscaNomeX2("GU7") + " com a situação 'Ativo'"
			Return .F.
		EndIf

		//GWU_CDTPVC 
		If !Empty(GWU->GWU_CDTPVC)
			dbSelectArea("GV3")
			dbSetOrder(1)
			If !dbSeek(xFilial("GV3")+GWU->GWU_CDTPVC) .OR. GV3->GV3_SIT <> '1' 
				cError := "Não foi encontrado '" + GWU->GWU_CDTPVC +"' no cadastro de " +  BuscaNomeX2("GV3") + " com a situação 'Ativo'" 
				Return .F.
			EndIf
		Endif 

		GWU->(DbSkip())
	EndDo


	/*Validações dos Unitizadores do Doc Carga*/
	dbSelectArea("GWB")
	dbSetorder(1)                                                                                                      
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)  

	While !GWB->(Eof()) .AND. GWB->GWB_FILIAL + GWB->GWB_CDTPDC + GWB->GWB_EMISDC + GWB->GWB_SERDC + GWB->GWB_NRDC == ;
	GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC			

		//GWB_CDUNIT
		If !Empty(GWB->GWB_CDUNIT)
			dbSelectArea("GUG")
			dbSetOrder(1)
			If dbSeek(xFilial("GUG")+GWB->GWB_CDUNIT) .AND. GUG->GUG_SIT <> '1' 
				cError := "Não foi encontrado '" + GWB->GWB_CDUNIT +"' no cadastro de " +  BuscaNomeX2("GWB") + " com a situação 'Ativo'" 
				Return .F.
			Endif
		EndIf

		GWB->(DbSkip())
	EndDo

Return .T.
//------------------------------------------------------------------------
Static Function BuscaNomeX2(cTabela)
	Local cNome := ''

	dbSelectArea("SX2") 
	dbSetOrder(1) 
	If dbSeek(cTabela) 
		cNome := CAPITAL(X2NOME())
	EndIf

Return cNome

//-------------------------------------------------------------------------

Function GFEX101MSG()

	dbSelectArea("GW0")
	dbSetOrder(1)
	dbSeek(xFilial("GW0") + PADR("GW1" , TamSX3("GW0_TABELA" )[1],'') + GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)

Return GW0->GW0_CHAR01 + GW0->GW0_CHAR02 + GW0->GW0_CHAR03


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEItemTrp
Realiza o agrupamento de itens por Item de Transporte
Uso Interno.

- A função busca cada item e analisa os itens subsequentes.
- Os itens subsequentes são verificados com o item comparador, os que se encaixarem na condição de agrupamento,
os valores são acumulados e o item é eliminado.

Pré-Requisito:
Tabela GW1 posicionada

@author Israel Alcantara Possoli
@since 18/07/14
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEItemTrp()
	Local aAreaGW1 := GW1->(getArea())
	Local aAreaGW8
	Local aCriterio 		:= {}		// Campos de critérios de agrupamento
	Local bCondicaoCriterio	:= ""		// Define a condição de critério de agrupamento
	Local cCampoGW8						// Campo da GW8 relacionado ao critério de rateio (MV_TPGRPXX)
	Local lAlterarGW8					// Flag para alterar a GW8
	Local lSkipGW8						// Flag para identificar se o item será processado (Estouro de limite)
	Local nRecNoGW8			:= 0
	Local nI

	// Acumuladores de valor
	Local nGW8Qtde
	Local nGW8Valor
	Local nGW8Volume
	Local nGW8PesoR
	Local nGW8PesoC
	Local nGW8QtdAlt

	// Limites de valores
	Local Max_Qtde	 	:= Replicate("9", TamSX3("GW8_QTDE")[1]   - TamSX3("GW8_QTDE")[2]   - 1) + "." + Replicate("9", TamSX3("GW8_QTDE")[2])
	Local Max_Valor  	:= Replicate("9", TamSX3("GW8_VALOR")[1]  - TamSX3("GW8_VALOR")[2]  - 1) + "." + Replicate("9", TamSX3("GW8_VALOR")[2])
	Local Max_Volume 	:= Replicate("9", TamSX3("GW8_VOLUME")[1] - TamSX3("GW8_VOLUME")[2] - 1) + "." + Replicate("9", TamSX3("GW8_VOLUME")[2])
	Local Max_PesoR		:= Replicate("9", TamSX3("GW8_PESOR")[1]  - TamSX3("GW8_PESOR")[2]  - 1) + "." + Replicate("9", TamSX3("GW8_PESOR")[2])
	Local Max_PesoC		:= Replicate("9", TamSX3("GW8_PESOC")[1]  - TamSX3("GW8_PESOC")[2]  - 1) + "." - Replicate("9", TamSX3("GW8_PESOC")[2])
	Local Max_QtdAlt	:= Replicate("9", TamSX3("GW8_QTDALT")[1] - TamSX3("GW8_QTDALT")[2] - 1) + "." - Replicate("9", TamSX3("GW8_QTDALT")[2])

	// --------------------------------------------------
	// Ajusta o limite máximo dos campos acumuladores
	// --------------------------------------------------
	Max_Qtde	:= Val(Max_Qtde)
	Max_Valor	:= Val(Max_Valor)
	Max_Volume  := Val(Max_Volume)
	Max_PesoR	:= Val(Max_PesoR)
	Max_PesoC	:= Val(Max_PesoC)
	Max_QtdAlt  := Val(Max_QtdAlt)

	// --------------------------------------------------
	// Critério de Agrupamento 
	// --------------------------------------------------
	aADD(aCriterio, "GW8_CDCLFR")	// Class Frete
	aADD(aCriterio, "GW8_RATEIO")	// Rateio Ctb
	aADD(aCriterio, "GW8_TPITEM") 	// Unid Negocio
	aADD(aCriterio, "GW8_TRIBP")	// Trib PIS/COF
	aADD(aCriterio, "GW8_CRDICM")	// Credita ICMS
	aADD(aCriterio, "GW8_UNINEG") 	// Unid Negocio

	// --------------------------------------------------
	// Critério de Agrupamento - Critério de Rateio
	// --------------------------------------------------	
	For nI := 1 To 7
		cCampoGW8 := CampoGrpCtb("MV_TPGRP" + cValToChar(nI))

		// Caso o campo GW8_ITEM estiver como critério de rateio, o parâmetro MV_ITEMTRP é anulado
		If cCampoGW8 == "GW8_ITEM"
			aSize(aCriterio, 0)
			aCriterio := Nil

			RestArea(aAreaGW1)
			Return
		EndIf

		If !Empty(cCampoGW8) .AND. AScan(aCriterio, {|x|x == cCampoGW8}) == 0
			aADD(aCriterio, cCampoGW8)
		EndIf
	Next

	// --------------------------------------------------
	// Agrupamento por Item de Transporte
	// --------------------------------------------------	
	dbSelectArea("GW8")
	dbSetOrder(2) // Como o GW8_ITEM está sendo alterado dentro do loop, o índice não deve ter este campo.
	dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
	While !GW8->(Eof()) .AND. ;
	GW8->GW8_FILIAL == GW1->GW1_FILIAL .AND. ;
	GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .AND. ;
	GW8->GW8_EMISDC == GW1->GW1_EMISDC .AND. ;
	GW8->GW8_SERDC  == GW1->GW1_SERDC .AND. ;
	GW8->GW8_NRDC   == GW1->GW1_NRDC

		aAreaGW8 	:= GW8->(getArea())

		If !GW8->(Deleted())

			nRecNoGW8			:= GW8->(RecNo())
			bCondicaoCriterio 	:= ""
			lAlterarGW8 		:= .F.
			nGW8Qtde   			:= GW8->GW8_QTDE  
			nGW8Valor  			:= GW8->GW8_VALOR 
			nGW8Volume 			:= GW8->GW8_VOLUME
			nGW8PesoR  			:= GW8->GW8_PESOR 
			nGW8PesoC 			:= GW8->GW8_PESOC 
			nGW8QtdAlt			:= GW8->GW8_QTDALT

			// --------------------------------------------------
			// Condição de Agrupamento
			// --------------------------------------------------				
			For nI := 1 To Len(aCriterio)
				If !Empty(bCondicaoCriterio)
					bCondicaoCriterio += " .AND. "
				EndIf

				bCondicaoCriterio += "Upper(GW8->" + aCriterio[nI] + ") == '" + Upper(&("GW8->" + aCriterio[nI])) + "'"
			Next

			// --------------------------------------------------
			// Verificação e Agrupamento dos itens subsequentes
			// --------------------------------------------------				    	
			GW8->(dbSkip())

			While !GW8->(Eof()) .AND. ;
			GW8->GW8_FILIAL == GW1->GW1_FILIAL .AND. ;
			GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .AND. ;
			GW8->GW8_EMISDC == GW1->GW1_EMISDC .AND. ;
			GW8->GW8_SERDC  == GW1->GW1_SERDC .AND. ;
			GW8->GW8_NRDC   == GW1->GW1_NRDC

				lSkipGW8	:= .F.

				If &(bCondicaoCriterio)
					// --------------------------------------------------
					// Verificação do limite de cada campo acumulador
					// --------------------------------------------------					    
					If nGW8Qtde + GW8->GW8_QTDE > Max_Qtde
						lSkipGW8 := .T.
					EndIf
					If nGW8Valor + GW8->GW8_VALOR > Max_Valor
						lSkipGW8 := .T.
					EndIf

					If nGW8Volume + GW8->GW8_VOLUME > Max_Volume
						lSkipGW8 := .T.
					EndIf

					If nGW8PesoR + GW8->GW8_PESOR > Max_PesoR
						lSkipGW8 := .T.
					EndIf

					If nGW8PesoC + GW8->GW8_PESOC > Max_PesoC
						lSkipGW8 := .T.
					EndIf

					If nGW8QtdAlt + GW8->GW8_QTDALT > Max_QtdAlt
						lSkipGW8 := .T.
					EndIf

					// --------------------------------------------------
					// Armazena os valores acumuladores e elimina o item
					// --------------------------------------------------					    					    	
					If !lSkipGW8
						lAlterarGW8 := .T.
						nGW8Qtde  	+= GW8->GW8_QTDE
						nGW8Valor 	+= GW8->GW8_VALOR
						nGW8Volume	+= GW8->GW8_VOLUME
						nGW8PesoR 	+= GW8->GW8_PESOR
						nGW8PesoC 	+= GW8->GW8_PESOC
						nGW8QtdAlt	+= GW8->GW8_QTDALT

						RecLock("GW8", .F.)
						dbDelete()
						GW8->(MsUnlock())
					EndIf
				EndIf

				GW8->(dbSkip())
			EndDo

			// --------------------------------------------------
			// Restaura a posição do item comparador 
			//  - Salva os valores acumulados, caso existam
			//  - Altera o nome do código do Item
			//  - Reorganiza a sequência dos itens
			// --------------------------------------------------						
			RestArea(aAreaGW8)
			dbSelectArea("GW8")
			dbGoTo(nRecNoGW8)
			RecLock("GW8", .F.)
			GW8->GW8_ITEM	:= GW8->GW8_CDCLFR
			GW8->GW8_DSITEM := POSICIONE("GUB", 1 ,xFilial("GUB") + GW8->GW8_CDCLFR, "GUB_DSCLFR")
			If lAlterarGW8
				GW8->GW8_QTDE  	:= nGW8Qtde
				GW8->GW8_VALOR 	:= nGW8Valor
				GW8->GW8_VOLUME	:= nGW8Volume
				GW8->GW8_PESOR 	:= nGW8PesoR
				GW8->GW8_PESOC 	:= nGW8PesoC
				GW8->GW8_QTDALT	:= nGW8QtdAlt
			EndIf
			GW8->(MsUnLock())
		EndIf

		RestArea(aAreaGW8)
		GW8->(dbSkip())
	EndDo

	RestArea(aAreaGW1)
Return


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} CampoGrpCtb
Retorna o campo do item (GW8) equivalente ao grupo contábil
Uso Interno.

@param
cMvTpGrp	: Grupo Contábil X (MV_TPGRPX)


@author Israel Alcantara Possoli
@since 18/07/14
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CampoGrpCtb(cMvTpGrp)
	Local cRet := ""
	Local cValPar
	Local aGrpCtb := {"", "", "GW8_ITEM", "", "", "", ;
	"", "", "GW8_INFO1", "GW8_INFO2", "GW8_INFO3", ;
	"GW8_INFO4", "GW8_INFO5", "", "", "GW8_CFOP",""}

	cValPar := SuperGetMv(cMvTpGrp, .F., "")

	If !Empty(cValPar) .And. cValPar != "0"
		cRet := aGrpCtb[Val(cValPar)]
	EndIf
Return (cRet)
