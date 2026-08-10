#INCLUDE "WMSA330.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF  Chr(13)+Chr(10)
#DEFINE WMSA33101 'WMSA33101'
#DEFINE WMSA33102 'WMSA33102'
#DEFINE WMSA33103 'WMSA33103'
#DEFINE WMSA33104 'WMSA33104'
#DEFINE WMSA33105 'WMSA33105'
#DEFINE WMSA33106 'WMSA33106'
#DEFINE WMSA33107 'WMSA33107'
#DEFINE WMSA33108 'WMSA33108'
#DEFINE WMSA33109 'WMSA33109'
#DEFINE WMSA33110 'WMSA33110'
#DEFINE WMSA33111 'WMSA33111'
#DEFINE WMSA33112 'WMSA33112'

Static __bKeyF5   := Nil
Static __bKeyF9   := Nil
Static __bKeyF10  := Nil
Static __nRefresh := 3
Static __lRefresh := .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA331
Monitor de Serviço

@author Felipe Machado de Oliveira.
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function WMSA331()
Local nSeconds   := SuperGetMV('MV_WMSREFS', .F., 10 ) // Tempo em Segundos para Refresh da tela (Default = 10 segundos)
// Status referente ao campo DB_STATUS
Private oBrowse   := Nil
Private cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') // DB_STATUS indicando Atividade Executada
Private cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') // DB_STATUS indicando Atividade com Problemas
Private cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') // DB_STATUS indicando Atividade Interrompida
Private cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') // DB_STATUS indicando Atividade A Executar
Private cStatAuto := SuperGetMV('MV_RFSTAUT', .F., 'A') // DB_STATUS indicando Atividade Automatica
Private cStatManu := SuperGetMV('MV_RFSTMAN', .F., 'M') // DB_STATUS indicando Atividade Manual
Private aStatus   := { cStatExec,cStatProb,cStatInte,cStatAExe,cStatAuto,cStatManu }
Private nIndSDB   := 8

	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSA332()
	EndIf

	dbSelectArea("SDB")

	If Pergunte('WMA330', .T.)
		__nRefresh := mv_par14 // Salva parametros do Pergunte
		SDB->(dbSetOrder(15))

		__bKeyF5  := {|| RefreshBrw()}
		__bKeyF9  := {|| WmsA331Sld(.T.)}
		__bKeyF10 := {|| WmsA331Log()}

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('SDB')
		oBrowse:SetDescription(STR0001) // Monitor de Serviços
		oBrowse:DisableDetails()
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetFilterDefault("@"+MontFiltro())
		oBrowse:SetMenuDef("WMSA331")   // Nome do fonte onde esta a função MenuDef
		oBrowse:AddLegend( "DB_STATUS=='"+cStatExec+"'"                                                            ,"GREEN" ,STR0030 )// Executada
		oBrowse:AddLegend( "(DB_STATUS=='"+cStatInte+"' .Or. DB_STATUS=='"+cStatProb+"') .And. DB_QUANT==DB_QTDLID","VIOLET",STR0110 )// Realizada
		oBrowse:AddLegend( "DB_STATUS=='"+cStatProb+"'"                                                            ,"RED"   ,STR0031 )// Com Problemas
		oBrowse:AddLegend( "DB_STATUS=='"+cStatInte+"'"                                                            ,"YELLOW",STR0032 )// Em Execução
		oBrowse:AddLegend( "DB_STATUS=='"+cStatAExe+"'"                                                            ,"BLUE"  ,STR0033 )// A Executar
		oBrowse:AddLegend( "DB_STATUS=='"+cStatAuto+"'"                                                            ,"BLACK" ,STR0034 )// Automática
		oBrowse:AddLegend( "DB_STATUS=='"+cStatManu+"'"                                                            ,"BROWN" ,STR0035 )// Manual
		oBrowse:SetParam({|| WMSA331SEL() })
		oBrowse:SetTimer({|| RefreshBrw() }, Iif(nSeconds<=0, 3600, nSeconds) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (__nRefresh < 3)})

		SetKey(VK_F5 , __bKeyF5)
		SetKey(VK_F9,  __bKeyF9)
		SetKey(VK_F10, __bKeyF10)

	//Ponto de entrada utilizado para manipular oBrowse da rotina
	If ExistBlock("WM331BRW")
		ExecBlock("WM331BRW",.F.,.F.)
	EndIf
		oBrowse:Activate()
	EndIf

	SetKey(VK_F5 , Nil)
	SetKey(VK_F9 , Nil)
	SetKey(VK_F10, Nil)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	Add OPTION aRotina TITLE STR0109 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	Add OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.WMSA331" OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	Add OPTION aRotina TITLE STR0013 ACTION "WmsA331Rel()"    OPERATION 2 ACCESS 0 DISABLE MENU // Imprimir Atividade
	Add OPTION aRotina TITLE STR0011 ACTION "WMSA331BAT()"    OPERATION 2 ACCESS 0 DISABLE MENU // Bloquear Atividade
	Add OPTION aRotina TITLE STR0077 ACTION "WMSA331BTA()"    OPERATION 2 ACCESS 0 DISABLE MENU // Bloquear Tarefa
	Add OPTION aRotina TITLE STR0078 ACTION "WMSA331BCD()"    OPERATION 2 ACCESS 0 DISABLE MENU // Bloquear Carga/Docto
	Add OPTION aRotina TITLE STR0009 ACTION "WMSA331RAT()"    OPERATION 2 ACCESS 0 DISABLE MENU // Reiniciar Atividade
	Add OPTION aRotina TITLE STR0009 ACTION "WMSA331RTA()"    OPERATION 2 ACCESS 0 DISABLE MENU // Reiniciar Tarefa
	Add OPTION aRotina TITLE STR0014 ACTION "WMSA331RCD()"    OPERATION 2 ACCESS 0 DISABLE MENU // Reiniciar Carga/Docto
	Add OPTION aRotina TITLE STR0017 ACTION "WMSA331ESV()"    OPERATION 2 ACCESS 0 DISABLE MENU // Estornar Servico
	Add OPTION aRotina TITLE STR0073 ACTION "WMSA331ECD()"    OPERATION 2 ACCESS 0 DISABLE MENU // Estornar Carga/Docto
	Add OPTION aRotina TITLE STR0094 ACTION "WMSA331FAT()"    OPERATION 2 ACCESS 0 DISABLE MENU // Finalizar Atividade
	Add OPTION aRotina TITLE STR0095 ACTION "WMSA331FTA()"    OPERATION 2 ACCESS 0 DISABLE MENU // Finalizar Tarefa
	Add OPTION aRotina TITLE STR0096 ACTION "WMSA331FCD()"    OPERATION 2 ACCESS 0 DISABLE MENU // Finalizar Carga/Docto
	Add OPTION aRotina TITLE STR0106 ACTION "WMSA331RPD()"    OPERATION 2 ACCESS 0 DISABLE MENU // Reprocessar Documento
	Add OPTION aRotina TITLE STR0107 ACTION "WMSA331RPF()"    OPERATION 2 ACCESS 0 DISABLE MENU // Reprocessar Todos
	Add OPTION aRotina TITLE STR0019 ACTION "WMSA331PRI()"    OPERATION 4 ACCESS 0 DISABLE MENU // Alterar Prioridade
	Add OPTION aRotina TITLE STR0021 ACTION "WMSA331RHU()"    OPERATION 4 ACCESS 0 DISABLE MENU // Recurso Humano
	Add OPTION aRotina TITLE STR0079 ACTION "CBMonRF()"       OPERATION 2 ACCESS 0 DISABLE MENU // Monitor
	Add OPTION aRotina TITLE STR0080 ACTION "WMSA331MSG()"    OPERATION 2 ACCESS 0 DISABLE MENU // Mensagem
	Add OPTION aRotina TITLE STR0023 ACTION "WMSA331SEL()"    OPERATION 3 ACCESS 0 DISABLE MENU // Selecionar

	// Ponto de entrada utilizado para manipular as opções do array aRotina
	If ExistBlock("WM331MNU")
		ExecBlock("WM331MNU",.F.,.F.)
	EndIf
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSDB := FWFormStruct(1,'SDB',/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := MPFormModel():New('WMSA331',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields('SDBMASTER',/*cOwner*/,oStruSDB )
	oModel:GetModel('SDBMASTER'):SetDescription( STR0001 ) // Monitor de Serviços
	oModel:SetPrimaryKey( {"DB_FILIAL","DB_PRODUTO","DB_LOCAL","DB_NUNSEQ","DB_DOC","DB_SERIE","DB_CLIFOR","DB_LOJA","DB_ITEM"} )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruSDB := FWFormStruct( 2, 'SDB' )
Local oModel   := FWLoadModel( 'WMSA331' )
Local oView    := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'SDBVIEW', oStruSDB, 'SDBMASTER' )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MontFiltro
Filtra arq.de movimentos de distribuicao conforme parametros

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function MontFiltro()
Local cQuery := ""

	cQuery := " DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery += " AND DB_ESTORNO = ' '"
	cQuery += " AND DB_ATUEST  = 'N'"
	If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
		cQuery += " AND DB_SERVIC >= '"+mv_par01+"'"
		cQuery += " AND DB_SERVIC <= '"+mv_par02+"'"
	EndIf
	If !(Empty(mv_par03) .And. Upper(mv_par04) == Replicate('Z', Len(mv_par04)))
		cQuery += " AND DB_CARGA >= '"+mv_par03+"'"
		cQuery += " AND DB_CARGA <= '"+mv_par04+"'"
	EndIf
	If !(Empty(mv_par05) .And. Upper(mv_par06) == Replicate('Z', Len(mv_par06)))
		cQuery += " AND DB_DOC >= '"+mv_par05+"'"
		cQuery += " AND DB_DOC <= '"+mv_par06+"'"
	EndIf
	If mv_par09 == 2
		cQuery += " AND NOT DB_STATUS IN ('"+aStatus[1]+"','"+aStatus[6]+"')"
	EndIf
	If !(Empty(mv_par10) .And. DtoS(mv_par11) == '20491231')
		cQuery += " AND DB_DATA >= '"+DToS(mv_par10)+"'"
		cQuery += " AND DB_DATA <= '"+DToS(mv_par11)+"'"
	EndIf
	If mv_par09 == 1
		If !(Empty(mv_par12) .And. DtoS(mv_par13) == '20491231')
			cQuery += " AND ( (DB_STATUS IN ('"+aStatus[1]+"','"+aStatus[6]+"')"
			cQuery +=        " AND DB_DATAFIM >= '"+DToS(mv_par12)+"'"
			cQuery +=        " AND DB_DATAFIM <= '"+DToS(mv_par13)+"' ) OR DB_STATUS NOT IN ('"+aStatus[1]+"','"+aStatus[6]+"') )"
		EndIf
	EndIf
	If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
		cQuery += " AND DB_PRODUTO >= '"+mv_par07+"'"
		cQuery += " AND DB_PRODUTO <= '"+mv_par08+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' '"

	// Ponto de Entrada WM330QRY para a alteracao da Query
	If ExistBlock('WM330QRY')
		If ValType(cQueryPE := ExecBlock('WM330QRY',.F.,.F.)) == 'C'
			cQuery += cQueryPE
		EndIf
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA331SEL
Seleciona um Novo Filtro ao Browse

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function WMSA331SEL()
	// Desativa teclas de atalho
	__bKeyF5  := SetKey(VK_F5 , Nil)
	__bKeyF9  := SetKey(VK_F9 , Nil)
	__bKeyF10 := SetKey(VK_F10, Nil)

	lRet := Pergunte('WMA330', .T.)
	If lRet
		__nRefresh := mv_par14
		oBrowse:oTimer:lActive := (__nRefresh < 3)
		// Selecionar atividades conforme a parametrizacao do usuario.
		oBrowse:SetFilterDefault("@"+MontFiltro())
		oBrowse:Refresh()
	EndIf
	// Reativa teclas de atalho
	SetKey(VK_F5 , __bKeyF5)
	SetKey(VK_F9 , __bKeyF9)
	SetKey(VK_F10, __bKeyF10)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshBrw
Refaz o setFilterDefault do Browse, para atualização

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function RefreshBrw()
Local nPos := oBrowse:At()
	If __nRefresh == 1
		oBrowse:Refresh( .T. )
	ElseIf __nRefresh == 2
		oBrowse:Refresh( .F. )
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh( .F. )
		oBrowse:GoTo(nPos,.F.)
	EndIf
Return .T.

/*----------------------------------------------------------------------------
Ativa/Desativa teclas de atalho e Refresh do Browse
----------------------------------------------------------------------------*/
Static Function TeclaAtalho(lAtiva)
	If !lAtiva
      __bKeyF5   := SetKey(VK_F5 , Nil)
      __bKeyF9   := SetKey(VK_F9 , Nil)
      __bKeyF10  := SetKey(VK_F10, Nil)
      If oBrowse:oTimer <> Nil
   		__lRefresh := oBrowse:oTimer:lActive //Salva o status do timer
   		// Desliga o Refresh automatico para nao desposicionar o cursor
   		oBrowse:oTimer:lActive := .F.
   	EndIf
	Else
		// Reativa as teclas de atalho
		SetKey(VK_F5 , __bKeyF5)
		SetKey(VK_F9 , __bKeyF9)
		SetKey(VK_F10, __bKeyF10)
		If oBrowse:oTimer <> Nil
		   // Retorna o status do timer do browse
		   oBrowse:oTimer:lActive := __lRefresh
		EndIf
	EndIf
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331RAT
---Reiniciar uma atividade
----------------------------------------------------------------------------------*/
Function WMSA331RAT()
	Reiniciar('1')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331RTA
---Reiniciar uma tarefa
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331RTA()
	Reiniciar('2')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331RCD
---Reiniciar carga/documento
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331RCD()
	Reiniciar('3')
Return Nil
/*--------------------------------------------------------------------------------
---Reiniciar
---Reinicia atividade que está pendente de execução.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Function Reiniciar(cAcao)
Local aAreaAnt    := GetArea()
Local aAreaSDB    := SDB->(GetArea())
Local cQuery      := ""
Local cAliasQry   := ""
Local cMessage    := ""
Local cRecHum     := ""
Local lRecHum     := .T.
Local lZeraQtdLid := .F.
Local cHoraFim    := Space(TamSx3("DB_HRFIM")[1])
Local lRet        := .T.
Local cDescFunExe := ""

	TeclaAtalho(.F.) // Desativa teclas de atalho
	DbSelectArea("SDB")
	If SDB->(!Eof())
		If cAcao == '1'
			If SDB->DB_STATUS == aStatus[1] .Or. SDB->DB_STATUS == aStatus[6] // Executada ou Manual
				WmsMessage(STR0041+CRLF+STR0042,WMSA33101) // Não é possível reiniciar a atividade pois a mesma ja foi finalizada. // Você deve estornar o serviço referente a este documento.
				lRet := .F.
			ElseIf SDB->DB_STATUS == aStatus[4] // A Executar
				WmsMessage(STR0044,WMSA33102) // A atividade ja esta reiniciada.
				lRet := .F.
			Else
				cMessage := STR0039+CRLF // Tem certeza que deseja reiniciar a atividade ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
				cMessage += STR0005+": "+SDB->DB_TAREFA+"-"+AllTrim(Tabela("L2",SDB->DB_TAREFA,.F.))+CRLF
				cMessage += STR0006+": "+SDB->DB_ATIVID+"-"+AllTrim(Tabela('L3',SDB->DB_ATIVID,.F.))
				If (lRet := WmsQuestion(cMessage))
					// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade ou no bloqueio
					WmsRegra('6',SDB->DB_LOCAL,SDB->DB_RECHUM)
					If !Empty(SDB->DB_RECHUM) .And. !WmsQuestion(STR0036) // O recurso humano deve ser mantido?
						cRecHum := Space(TamSx3("DB_RECHUM")[1])
						lRecHum := .F.
						If ExistBlock('WM330RHM')
							ExecBlock('WM330RHM',.F.,.F.,{cRecHum})
						EndIf
					EndIf
					If lRecHum
						cQuery := "SELECT DC5.DC5_FUNEXE"
						cQuery +=  " FROM "+RetSqlName("DC5")+" DC5"
						cQuery += " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
						cQuery +=   " AND DC5.DC5_SERVIC = '"+SDB->DB_SERVIC+"'"
						cQuery +=   " AND DC5.DC5_TAREFA = '"+SDB->DB_TAREFA+"'"
						cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasQry := GetNextAlias()
						DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
						If !(cAliasQry)->(Eof())
							// Busca a descrição da função a executar na tabela SX5
							cDescFunExe := FWGetSX5("L6",(cAliasQry)->DC5_FUNEXE)[1,4]
							// Se for uma tarefa de conferência
							If "DLCONF" $ Upper(AllTrim(cDescFunExe))
								lZeraQtdLid := !WmsQuestion(STR0115) // A quantidade conferida deve ser mantida?
							EndIf
						EndIf
						(cAliasQry)->(DbCloseArea())
					EndIf
					If SDB->(SimpleLock()) .And. RecLock('SDB',.F.)
						SDB->DB_STATUS := aStatus[4]
						SDB->DB_HRINI  := Time()
						SDB->DB_DATA   := dDataBase
						SDB->DB_HRFIM  := cHoraFim
						// Zera a quantidade lida quando opta por não manter RH
						If !lRecHum
							SDB->DB_RECHUM := cRecHum
						EndIf
						If !lRecHum .Or. lZeraQtdLid
							SDB->DB_QTDLID := 0
						EndIf
						SDB->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Else //cAcao == '2' .Or. cAcao == '3'
			If cAcao == "2"
				cMessage := STR0050+CRLF // Tem certeza que deseja reiniciar a tarefa ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
				cMessage += STR0005+": "+SDB->DB_TAREFA+"-"+AllTrim(Tabela("L2",SDB->DB_TAREFA,.F.))+CRLF
			ElseIf cAcao == "3"
				cMessage := STR0074+CRLF // Tem certeza que deseja reiniciar o servico ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
			EndIf
			If !Empty(SDB->DB_MAPSEP)
				cMessage += AllTrim(RetTitle("DB_MAPSEP"))+": "+AllTrim(SDB->DB_MAPSEP)+CRLF
			ElseIf !Empty(SDB->DB_CARGA)
				cMessage += AllTrim(RetTitle("DB_CARGA"))+": "+AllTrim(SDB->DB_CARGA)+CRLF
			Else
				cMessage += AllTrim(RetTitle("DB_DOC"))+": "+AllTrim(SDB->DB_DOC)+CRLF
				cMessage += Iif(Empty(SDB->DB_CLIFOR),"",AllTrim(RetTitle("DB_CLIFOR"))+": "+AllTrim(SDB->DB_CLIFOR)+"/"+AllTrim(SDB->DB_LOJA)+CRLF)
			EndIf
			If cAcao == "2"
				cMessage += AllTrim(RetTitle("DB_PRODUTO"))+": "+AllTrim(SDB->DB_PRODUTO)
			EndIf
			cAliasQry := GetNextAlias()
			cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO,"
			cQuery +=       " DC5.DC5_FUNEXE"
			cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " INNER JOIN "+RetSqlName("DC5")+" DC5"
			cQuery +=    " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
			cQuery +=   " AND DC5.DC5_SERVIC = SDB.DB_SERVIC"
			cQuery +=   " AND DC5.DC5_TAREFA = SDB.DB_TAREFA"
			cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND SDB.DB_ESTORNO = ' '"
			cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
			cQuery +=   " AND SDB.DB_STATUS IN ('"+aStatus[2]+"','"+aStatus[3]+"')"
			cQuery +=   " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
			If cAcao == "2"
				cQuery += " AND SDB.DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
				cQuery += " AND SDB.DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
				cQuery += " AND SDB.DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
				cQuery += " AND SDB.DB_IDDCF   = '"+SDB->DB_IDDCF+"'"
			EndIf
			If !Empty(SDB->DB_MAPSEP)
				cQuery += " AND SDB.DB_MAPSEP = '"+SDB->DB_MAPSEP+"'"
			ElseIf !Empty(SDB->DB_CARGA)
				cQuery += " AND SDB.DB_CARGA   = '"+SDB->DB_CARGA+"'"
			Else
				cQuery += " AND SDB.DB_DOC     = '"+SDB->DB_DOC+"'"
				If SDB->DB_ORIGEM <> "SC9"
					cQuery += " AND SDB.DB_SERIE = '"+SDB->DB_SERIE+"'"
				EndIf
				cQuery += " AND SDB.DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
				cQuery += " AND SDB.DB_LOJA    = '"+SDB->DB_LOJA+"'"
			EndIf
			cQuery += " AND SDB.D_E_L_E_T_  = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If !(cAliasQry)->(Eof())
				If (lRet := WmsQuestion(cMessage))
					// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade ou no bloqueio
					cRecHum := Space(TamSx3("DB_RECHUM")[1])
					lRecHum := WmsQuestion(STR0036) // O recurso humano deve ser mantido?
					If lRecHum
						// Busca a descrição da função a executar na tabela SX5
						cDescFunExe := FWGetSX5("L6",(cAliasQry)->DC5_FUNEXE)[1,4]
						// Se for uma tarefa de conferência
						If "DLCONF" $ Upper(AllTrim(cDescFunExe))
							lZeraQtdLid := !WmsQuestion(STR0115) // A quantidade conferida deve ser mantida?
						EndIf
					EndIf
					Begin Transaction
						WmsRegra('6',SDB->DB_LOCAL,SDB->DB_RECHUM)
						While (cAliasQry)->(!Eof())
							SDB->(DbGoTo((cAliasQry)->SDBRECNO))
							If SDB->(SimpleLock()) .And. RecLock('SDB',.F.)
								SDB->DB_STATUS := aStatus[4]
								SDB->DB_HRINI  := Time()
								SDB->DB_DATA   := dDataBase
								SDB->DB_HRFIM  := cHoraFim
								// Zera a quantidade lida quando opta por não manter RH
								If !lRecHum
									SDB->DB_RECHUM := cRecHum
								EndIf
								If !lRecHum .Or. lZeraQtdLid
									SDB->DB_QTDLID := 0
								EndIf
								SDB->(MsUnLock())
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
						(cAliasQry)->(DbCloseArea())
					End Transaction
				EndIf
			Else
				If cAcao == "2"
					WmsMessage(STR0111) // "A tarefa não possui atividades a serem reiniciadas."
				Else
					WmsMessage(STR0112) // "O serviço não possui atividades a serem reiniciadas."
				EndIf
			EndIf
		EndIf
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( Nil )
/*--------------------------------------------------------------------------------
---WMSA331BAT
---Bloqueia uma atividade
----------------------------------------------------------------------------------*/
Function WMSA331BAT()
	Bloquear('1')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331BTA
---Bloqueia uma tarefa
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331BTA()
	Bloquear('2')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331BCD
---Bloqueia carga/documento
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331BCD()
	Bloquear('3')
Return Nil
/*--------------------------------------------------------------------------------
---Bloquear
---Bloqueia uma atividade que está pendente de execução.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Bloquear(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local cQuery    := ""
Local cAliasQry := ""
Local cMessage  := ""
Local lRet      := .T.

   TeclaAtalho(.F.) // Desativa teclas de atalho

	DbSelectArea("SDB")
	If SDB->(!EOF())
		If cAcao == '1'
			If SDB->DB_STATUS == aStatus[1] .Or. SDB->DB_STATUS == aStatus[6] // Executada ou Manual
				WmsMessage(STR0048,WMSA33103) // Não é possível bloquear a tarefa pois a mesma ja foi finalizada.
				lRet := .F.
			ElseIf SDB->DB_STATUS == aStatus[2] // Bloqueada
				WmsMessage(STR0040,WMSA33104) // A atividade já está bloqueada.
				lRet := .F.
			Else
				cMessage := STR0076+CRLF // Tem certeza que deseja bloquear a atividade ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
				cMessage += STR0005+": "+SDB->DB_TAREFA+"-"+AllTrim(Tabela("L2",SDB->DB_TAREFA,.F.))+CRLF
				cMessage += STR0006+": "+SDB->DB_ATIVID+"-"+AllTrim(Tabela('L3',SDB->DB_ATIVID,.F.))
				If (lRet := WmsQuestion(cMessage))
					// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade ou no bloqueio
					WmsRegra('6',SDB->DB_LOCAL,SDB->DB_RECHUM)
					If SDB->(SimpleLock()) .And. RecLock('SDB',.F.)
						SDB->DB_STATUS := aStatus[2] //'2'
						SDB->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Else
			If cAcao == "2"
				cMessage := STR0047+CRLF // Tem certeza que deseja bloquear a tarefa ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
				cMessage += STR0005+": "+SDB->DB_TAREFA+"-"+AllTrim(Tabela("L2",SDB->DB_TAREFA,.F.))+CRLF
			Else
				cMessage := STR0075+CRLF // Tem certeza que deseja bloquear o servico ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
			EndIf
			If !Empty(SDB->DB_MAPSEP)
				cMessage += AllTrim(RetTitle("DB_MAPSEP"))+": "+AllTrim(SDB->DB_MAPSEP)+CRLF
			ElseIf !Empty(SDB->DB_CARGA)
				cMessage += AllTrim(RetTitle("DB_CARGA"))+": "+AllTrim(SDB->DB_CARGA)+CRLF
			Else
				cMessage += AllTrim(RetTitle("DB_DOC"))+": "+AllTrim(SDB->DB_DOC)+CRLF
				cMessage += Iif(Empty(SDB->DB_CLIFOR),"",AllTrim(RetTitle("DB_CLIFOR"))+": "+AllTrim(SDB->DB_CLIFOR)+"/"+AllTrim(SDB->DB_LOJA)+CRLF)
			EndIf
			If cAcao == "2"
				cMessage += AllTrim(RetTitle("DB_PRODUTO"))+": "+AllTrim(SDB->DB_PRODUTO)
			EndIf
			cAliasQry := GetNextAlias()
			cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
			cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_STATUS NOT IN ('"+aStatus[1]+"','"+aStatus[2]+"','"+aStatus[6]+"')"
			cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
			If cAcao == "2"
				cQuery += " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
				cQuery += " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
				cQuery += " AND DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
				cQuery += " AND DB_IDDCF   = '"+SDB->DB_IDDCF+"'"
			EndIf

			If !Empty(SDB->DB_MAPSEP)
				cQuery += " AND DB_MAPSEP = '"+SDB->DB_MAPSEP+"'"
			ElseIf !Empty(SDB->DB_CARGA)
				cQuery += " AND DB_CARGA   = '"+SDB->DB_CARGA+"'"
			Else
				cQuery += " AND DB_DOC     = '"+SDB->DB_DOC+"'"
				If SDB->DB_ORIGEM <> "SC9"
					cQuery += " AND DB_SERIE = '"+SDB->DB_SERIE+"'"
				EndIf
				cQuery += " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
				cQuery += " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
			EndIf
			cQuery += " AND D_E_L_E_T_  = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If !(cAliasQry)->(Eof())
				If (lRet := WmsQuestion(cMessage))
					Begin Transaction
					// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade ou no bloqueio
					WmsRegra('6',SDB->DB_LOCAL,SDB->DB_RECHUM)
					While (cAliasQry)->(!Eof())
						SDB->(DbGoTo((cAliasQry)->SDBRECNO))
						If SDB->(SimpleLock()) .And. RecLock('SDB',.F.)
							SDB->DB_STATUS := aStatus[2] //'2'
							SDB->(MsUnLock())
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())
					End Transaction
				EndIf
			Else
				If cAcao == "2"
					WmsMessage(STR0113) // "A tarefa não possui atividades a serem bloqueadas."
				Else
					WmsMessage(STR0114) // "O serviço não possui atividades a serem bloqueadas."
				EndIf
			EndIf
		EndIf
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( lRet )
/*--------------------------------------------------------------------------------
---WMSA331ESV
---Estorna um serviço
----------------------------------------------------------------------------------*/
Function WMSA331ESV()
	Estornar('1')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331ECD
---Estorna carga/documento
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331ECD()
	Estornar('2')
Return Nil
/*--------------------------------------------------------------------------------
---Processa estorno
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Serviço
---                 "2" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Estornar(cAcao)
Local aAreaAnt   := GetArea()
Local aAreaSDB   := SDB->(GetArea())
Local aAreaDCF   := DCF->(GetArea())
Local aDocOri    := {}
Local cMessage   := ""
Local lRet       := .T.

Local cAliasNew  := "DCF"
Local cQuery     := ""
Local lRetDoc    := .T.
Local cDoctos    := ''
Default cAcao    := 1

   TeclaAtalho(.F.) // Desativa teclas de atalho

	DbSelectArea("SDB")
	If  SDB->(!Eof())
		Do Case
		Case cAcao == "1"
			If SDB->DB_STATUS == aStatus[1] .Or.;  // Executada
				SDB->DB_STATUS == aStatus[6]        // Manual
				cMessage := STR0052 + CRLF          // O serviço selecionado ja esta finalizado. Continua com o Estorno?
			EndIf
			cMessage := STR0053+CRLF // Estornar o servico selecionado?
			cMessage += STR0004+": "+SDB->DB_SERVIC+" - "+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
			cMessage += AllTrim(RetTitle("DB_PRODUTO"))+": "+AllTrim(SDB->DB_PRODUTO)
			If WmsQuestion(cMessage)
				cAliasNew := GetNextAlias()
				cQuery := "SELECT DISTINCT DCF1.R_E_C_N_O_ RECNODCF, DCF1.DCF_DOCTO, DCF1.DCF_SERIE,"
				cQuery +=       " DCF1.DCF_CLIFOR, DCF1.DCF_LOJA, DCF1.DCF_ID"
				cQuery +=  " FROM "+RetSqlName('DCF')+" DCF1, "+RetSqlName('DCR')+" DCR1, "+RetSqlName('DCR')+" DCR2"
				cQuery += " WHERE DCF1.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF1.DCF_SERVIC = '"+SDB->DB_SERVIC+"'"
				cQuery +=   " AND DCF1.DCF_CODPRO = '"+SDB->DB_PRODUTO+"'"
				cQuery +=   " AND DCF1.DCF_STSERV IN ('2','3')"
				cQuery +=   " AND DCF1.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCR1.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR1.DCR_IDDCF = '"+SDB->DB_IDDCF+"'"
				cQuery +=   " AND DCR2.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR2.DCR_IDORI  = DCR1.DCR_IDORI"
				cQuery +=   " AND DCR2.DCR_IDDCF = DCF1.DCF_ID"
				cQuery +=   " AND DCR2.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
				If (cAliasNew)->( Eof() )
					Aviso("WMSA33008",STR0054,{"Ok"}) // O Estorno não será realizado pois o sistema não encontrou a execução de serviços.
				Else
					aDocto      := {}
					lRetDoc  := .T.
					cDoctos  := STR0089 // Serviço aglutinado, será necessário estornar os seguintes
					cDoctos  += CRLF+Trim(RetTitle('DCF_DOCTO'))+" - "+Trim(RetTitle('DCF_SERIE'))+" - "+Trim(RetTitle('DCF_CLIFOR'))+" - "+Trim(RetTitle('DCF_LOJA'))+':'
					While (cAliasNew)->(!Eof())
						If (aScan(aDocto , {|x| x[1]+x[2]+x[3]+x[4]==(cAliasNew)->DCF_DOCTO+(cAliasNew)->DCF_SERIE+(cAliasNew)->DCF_CLIFOR+(cAliasNew)->DCF_LOJA})) == 0
							aAdd(aDocto,{(cAliasNew)->DCF_DOCTO,(cAliasNew)->DCF_SERIE,(cAliasNew)->DCF_CLIFOR,(cAliasNew)->DCF_LOJA})
							cDoctos += CRLF+(cAliasNew)->DCF_DOCTO+" - "+(cAliasNew)->DCF_SERIE+" - "+(cAliasNew)->DCF_CLIFOR+" - "+(cAliasNew)->DCF_LOJA
						EndIf
						(cAliasNew)->( DbSkip() )
					EndDo
					If Len(aDocto) > 1
						If !WmsQuestion(cDoctos)
							lRetDoc := .F.
						EndIf
					EndIf
					If lRetDoc
						// Posiciona no primeiro registro selecionado
						(cAliasNew)->( DbGoTop() )
						While (cAliasNew)->(!Eof()) .And. lRet
							DCF->(DbGoTo((cAliasNew)->RECNODCF))
							If (lRet := VldEstDCF(@cMessage))
								lRet := WmsEstAll('1',(mv_par15 == 1),aDocOri,.T.)
							Else
								WmsMessage(cMessage,WMSA33109,1)
							EndIf
							(cAliasNew)->(DbSkip())
						EndDo
					EndIf
				EndIf
				(cAliasNew)->( DbCloseArea() )
				// Estorna todos os documentos com referencia a carga ou documento original
				If lRet .And. !Empty(aDocOri)
					WmsEstAll('2',.F.,aDocOri,.T.)
				EndIf
			EndIf
		Case cAcao == "2"
			cMessage := STR0024+CRLF // Estornar o serviço do documento selecionado?
			cMessage += STR0004+": "+SDB->DB_SERVIC+" - "+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
			cMessage += AllTrim(RetTitle("DB_DOC"))+": "+AllTrim(SDB->DB_DOC)+Iif(SDB->DB_ORIGEM=="SC9","",Iif(Empty(SDB->DB_SERIE),""," / "+AllTrim(SDB->DB_SERIE)))
			If WmsQuestion(cMessage)
				cAliasNew := GetNextAlias()
				cQuery := "SELECT DISTINCT DCF2.R_E_C_N_O_ RECNODCF, DCF2.DCF_DOCTO, "
				cQuery += Iif(SDB->DB_ORIGEM=="SC9","'"+Space(SerieNfId("DCF",6,"DCF_SERIE"))+"' DCF_SERIE,","DCF2.DCF_SERIE,")
				cQuery +=       " DCF2.DCF_CLIFOR, DCF2.DCF_LOJA, DCF2.DCF_ID"
				cQuery +=  " FROM "+RetSqlName('DCF')+" DCF1, "+RetSqlName('DCF')+" DCF2, "
				cQuery +=         RetSqlName('DCR')+" DCR1, "+RetSqlName('DCR')+" DCR2"
				cQuery += " WHERE DCF1.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF1.DCF_SERVIC = '"+SDB->DB_SERVIC+"'"
				cQuery +=   " AND DCF1.DCF_CODPRO = '"+SDB->DB_PRODUTO+"'"
				cQuery +=   " AND DCF1.DCF_STSERV IN ('2','3')"
				cQuery +=   " AND DCF1.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCF2.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF2.DCF_SERVIC = '"+SDB->DB_SERVIC+"'"
				cQuery +=   " AND DCF2.DCF_STSERV IN ('2','3')"
				If WmsCarga(SDB->DB_CARGA)
					cQuery += " AND DCF2.DCF_CARGA  = DCF1.DCF_CARGA"
				Else
					cQuery += " AND DCF2.DCF_DOCTO  = DCF1.DCF_DOCTO"
					If SDB->DB_ORIGEM != "SC9"
						cQuery += " AND DCF2.DCF_SERIE  = DCF1.DCF_SERIE"
					EndIf
					cQuery += " AND DCF2.DCF_CLIFOR = DCF1.DCF_CLIFOR"
					cQuery += " AND DCF2.DCF_LOJA   = DCF1.DCF_LOJA"
				EndIf
				cQuery +=   " AND DCF2.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCR1.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR1.DCR_IDDCF = '"+SDB->DB_IDDCF+"'"
				cQuery +=   " AND DCR2.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR2.DCR_IDORI  = DCR1.DCR_IDORI"
				cQuery +=   " AND DCR2.DCR_IDDCF = DCF1.DCF_ID"
				cQuery +=   " AND DCR2.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
				If (cAliasNew)->( Eof() )
					Aviso("WMSA33008",STR0054,{"Ok"}) // O Estorno não será realizado pois o sistema não encontrou a execução de serviços.
				Else
					aDocto   := {}
					lRetDoc  := .T.
					cDoctos  := STR0090 // Documento aglutinado, será necessário estornar os seguintes
					cDoctos  += CRLF+Trim(RetTitle('DCF_DOCTO'))+" - "+Trim(RetTitle('DCF_SERIE'))+" - "+Trim(RetTitle('DCF_CLIFOR'))+" - "+Trim(RetTitle('DCF_LOJA'))+':'
					While (cAliasNew)->(!Eof())
						If (aScan(aDocto , {|x| x[1]+x[2]+x[3]+x[4]==(cAliasNew)->DCF_DOCTO+ SubStr((cAliasNew)->DCF_SERIE,1,3)+(cAliasNew)->DCF_CLIFOR+(cAliasNew)->DCF_LOJA})) == 0
							aAdd(aDocto,{(cAliasNew)->DCF_DOCTO,(cAliasNew)->DCF_SERIE,(cAliasNew)->DCF_CLIFOR,(cAliasNew)->DCF_LOJA})
							cDoctos += CRLF+(cAliasNew)->DCF_DOCTO+" - "+ SubStr((cAliasNew)->DCF_SERIE,1,3) +" - "+(cAliasNew)->DCF_CLIFOR+" - "+(cAliasNew)->DCF_LOJA
						EndIf
						(cAliasNew)->( DbSkip() )
					EndDo
					If Len(aDocto) > 1
						If !WmsQuestion(cDoctos)
							lRetDoc := .F.
						EndIf
					EndIf
					If lRetDoc
						// Posiciona no primeiro registro selecionado
						(cAliasNew)->( DbGoTop() )
						While (cAliasNew)->(!Eof()) .And. lRet
							DCF->(DbGoTo((cAliasNew)->RECNODCF))
							If (lRet := VldEstDCF(@cMessage))
								lRet := WmsEstAll('1',(mv_par15 == 1),aDocOri,.T.)
							Else
								WmsMessage(cMessage,WMSA33109,1)
							EndIf
							(cAliasNew)->(DbSkip())
						EndDo
						// Estorna todos os documentos com referencia a carga ou documento original
						If lRet .And. !Empty(aDocOri)
							WmsEstAll('2',.F.,aDocOri,.T.)
						EndIf
					EndIf
				EndIf
				(cAliasNew)->( DbCloseArea() )
			EndIf
		EndCase
	EndIf

	// Ponto de Entrada WM330AEX - Apos Execucao/Estorno O.S.WMS.
	If ExistBlock("WM330AEX")
		ExecBlock("WM330AEX", .F., .F., {cAcao})
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaDCF)
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( lRet )
/*--------------------------------------------------------------------------------
---WMSA331FAT
---Finaliza uma atividade
----------------------------------------------------------------------------------*/
Function WMSA331FAT()
	Finalizar('1')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331FTA
---Finaliza uma tarefa
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331FTA()
	Finalizar('2')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331FCD
---Finaliza carga/documento
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331FCD()
	Finalizar('3')
Return Nil
/*--------------------------------------------------------------------------------
---Finalizar
---Permiti finalizar os serviços de movimentação sem utilizar o coletor
---ou estiver com problemas.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Finalizar(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local cQuery    := ""
Local cAliasQry := ""
Local cMessage  := ""
Local lRet      := .T.
Local aAreaAnt2 := {}
Local nTipoConv := SuperGetMV('MV_TPCONVO', .F., 1) // 1=Por Atividade/2=Por Tarefa
Local dDataFec  := DToS(WmsData())

// Variável utilizada pela função de validação da execução da atividade anterior
// Neste caso, sempre força o reinicio, mesmo estando bloqueado, pois é uma contingência
Private cReinAuto := 'S' // Indica se permite convocar atividade com problemas/ Interrompida
// Variavel utilizada na criação do SetRelation para diferenciar Atividade, Tarefa e Doc/Carga
// como relação dos dados da grid MVC
Private aParArr331 := {}

   TeclaAtalho(.F.) // Desativa teclas de atalho

	If SDB->( !EOF() )
		Do Case
		Case cAcao == "1"
		   If SDB->DB_STATUS == aStatus[1] .Or. SDB->DB_STATUS == aStatus[6] // Executada ou Manual
		      WmsMessage(STR0097,WMSA33105) // Atividade já está finalizada!
				lRet := .F.
		   ElseIf !DLVExecAnt(nTipoConv,dDataFec,SDB->DB_RECHUM)
				WmsMessage(STR0003,WMSA33106) // Existem atividades anteriores não finalizadas!
				lRet := .F.
			EndIf
			If lRet
				aParArr331 := { {"DB_FILIAL","xFilial('SDB')"},{"DB_ESTORNO","' '"},{"DB_ATUEST","'N'"},{"R_E_C_N_O_", Str(SDB->(Recno()))} }
			EndIf

		Case cAcao == "2" .Or. cAcao == "3"
			If cAcao == "2"
				cMessage := STR0098+CRLF // Tem certeza que deseja Finalizar a tarefa ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
				cMessage += STR0005+": "+SDB->DB_TAREFA+"-"+AllTrim(Tabela("L2",SDB->DB_TAREFA,.F.))+CRLF
			Else
				cMessage := STR0099+CRLF // Tem certeza que deseja Finalizar o servico ?
				cMessage += STR0004+": "+SDB->DB_SERVIC+"-"+AllTrim(Tabela("L4",SDB->DB_SERVIC,.F.))+CRLF
			EndIf
			If !Empty(SDB->DB_MAPSEP)
				cMessage += AllTrim(RetTitle("DB_MAPSEP"))+": "+AllTrim(SDB->DB_MAPSEP)+CRLF
			ElseIf !Empty(SDB->DB_CARGA)
				cMessage += AllTrim(RetTitle("DB_CARGA"))+": "+AllTrim(SDB->DB_CARGA)+CRLF
			Else
				cMessage += AllTrim(RetTitle("DB_DOC"))+": "+AllTrim(SDB->DB_DOC)+CRLF
				cMessage += Iif(Empty(SDB->DB_CLIFOR),"",AllTrim(RetTitle("DB_CLIFOR"))+": "+AllTrim(SDB->DB_CLIFOR)+"/"+AllTrim(SDB->DB_LOJA)+CRLF)
			EndIf
			If cAcao == "2"
				cMessage += AllTrim(RetTitle("DB_PRODUTO"))+": "+AllTrim(SDB->DB_PRODUTO)
			EndIf
			
			If cAcao == "2" .And. !(lRet := WMSOrdTare())
				WmsMessage(STR0003,WMSA33112) //Existem tarefas anteriores não finalizadas!
			EndIf
			If lRet .And. (lRet := WmsQuestion(cMessage))
				cAliasQry := GetNextAlias()
				cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
				cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
				cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
				cQuery +=   " AND SDB.DB_ESTORNO = ' '"
				cQuery +=   " AND SDB.DB_ATUEST = 'N'"
				cQuery +=   " AND SDB.DB_STATUS IN ('"+aStatus[2]+"','"+aStatus[3]+"','"+aStatus[4]+"')"
				cQuery +=   " AND SDB.DB_SERVIC = '"+SDB->DB_SERVIC+"'"
				aParArr331 := { {"DB_FILIAL","xFilial('SDB')"},;
									 {"DB_ESTORNO","' '"},;
									 {"DB_ATUEST","'N'"},;
									 {"DB_SERVIC", "DB_SERVIC"};
								  }
				If cAcao == "2"
					cQuery += " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
					cQuery += " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
					cQuery += " AND DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
					cQuery += " AND DB_IDDCF   = '"+SDB->DB_IDDCF+"'"
					AAdd(aParArr331 ,{"DB_TAREFA", "DB_TAREFA"})
					AAdd(aParArr331 ,{"DB_ORDTARE", "DB_ORDTARE"})
					AAdd(aParArr331 ,{"DB_PRODUTO", "DB_PRODUTO"})
					AAdd(aParArr331 ,{"DB_IDDCF", "DB_IDDCF"})
				EndIf

				If !Empty(SDB->DB_MAPSEP)
					cQuery += " AND DB_MAPSEP = '"+SDB->DB_MAPSEP+"'"
					AAdd(aParArr331 ,{"DB_MAPSEP", "DB_MAPSEP"})
				ElseIf !Empty(SDB->DB_CARGA)
					cQuery += " AND DB_CARGA   = '"+SDB->DB_CARGA+"'"
					AAdd(aParArr331 ,{"DB_CARGA", "DB_CARGA"})
				Else
					cQuery += " AND DB_DOC     = '"+SDB->DB_DOC+"'"
					AAdd(aParArr331 ,{"DB_DOC", "DB_DOC"})
					If SDB->DB_ORIGEM <> "SC9"
						cQuery += " AND DB_SERIE = '"+SDB->DB_SERIE+"'"
						AAdd(aParArr331 ,{"DB_SERIE", "DB_SERIE"})
					EndIf
					cQuery += " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
					cQuery += " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
					AAdd(aParArr331 ,{"DB_CLIFOR", "DB_CLIFOR"})
					AAdd(aParArr331 ,{"DB_LOJA", "DB_LOJA"})
				EndIf
				cQuery += " AND D_E_L_E_T_  = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(Eof())
					lRet := .F.
					If cAcao == "2"
						WmsMessage(STR0101,WMSA33110) // Tarefa já está finalizada!
					ElseIf cAcao == "3"
						WmsMessage(STR0102,WMSA33111) // Documento/Carga já está finalizada!
					EndIf
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf

		EndCase

		If lRet
			aAreaAnt2 := GetArea()
			FWExecView(STR0103,"WMSA331A", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) // Alterar
			RestArea(aAreaAnt2)
		EndIf

	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return (lRet)
/*----------------------------------------------------------------------------
---WMSA331REL
---Executa relatorio WMSR310 - Monitor de Servico
---Flavio Luiz Vicco 14/08/2006
----------------------------------------------------------------------------*/
Function WMSA331REL()
Local aArea      := GetArea()
	TeclaAtalho(.F.) // Desativa teclas de atalho
	WmsR310()        // Executa relat.Monitor de Servicos
	TeclaAtalho(.T.) // Reativa teclas de atalho

	RestArea(aArea)
Return( Nil )
/*--------------------------------------------------------------------------------
---WMSA331PRI
---Atualiza prioridade
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331PRI()
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local aOpcao    := {}
Local aParams   := {}
Local cQuery    := ""
Local cAliasQry := ""
Local cOpcao    := ""
Local cGrvPri   := ""
Local lProduto  := .F.
Local lRet      := .T.
Local lWmsRegra := ExistBlock('WMSREGRA')

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	DbSelectArea("SDB")
	If SDB->(!EOF())
		If !Empty(SDB->DB_CARGA)
			AAdd(aOpcao,STR0055+SDB->DB_CARGA) // Carga :
   		Else
   			AAdd(aOpcao,STR0056+SDB->DB_DOC+Iif(Empty(SDB->DB_SERIE),"",' - '+SDB->DB_SERIE)) // Documento :
   		EndIf
   		AAdd(aOpcao,STR0072+SDB->DB_PRODUTO) // Produto :
   		AAdd(aParams,{3,STR0057,1,aOpcao,100,'',.F.}) // Prioriza
   		AAdd(aParams,{1,STR0058,SubStr(SDB->DB_PRIORI,1,2),PesqPict('SDB','DB_PRIORI'),'','','',10,.T.}) // Prioridade
   		If ParamBox(aParams,STR0058,,,,,,,,,.F.,.F.) // Prioridade
   			cOpcao := Substr(aOpcao[mv_par01],1,1)
	   		If cOpcao == 'P'
	   			lProduto := .T.
	   			If !Empty(SDB->DB_CARGA)
	   				cOpcao := 'C'
	   			Else
	   				cOpcao := 'D'
	   			EndIf
	   		EndIf
	   		cAliasQry := GetNextAlias()
	   		cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
	   		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
	   		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
	   		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	   		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
	   		cQuery +=   " AND SDB.DB_STATUS IN ('"+aStatus[2]+"','"+aStatus[4]+"')"
	   		cQuery +=   " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
	   		If lProduto
	   		   cQuery += " AND DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
	   		EndIf
	   		If !Empty(SDB->DB_CARGA)
	   			cQuery += " AND DB_CARGA   = '"+SDB->DB_CARGA+"'"
	   		Else
	   			cQuery += " AND DB_DOC     = '"+SDB->DB_DOC+"'"
	   			If SDB->DB_ORIGEM <> "SC9"
	   				cQuery += " AND DB_SERIE = '"+SDB->DB_SERIE+"'"
	   			EndIf
	   			cQuery += " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
	   			cQuery += " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
	   		EndIf
	   		cQuery += " AND D_E_L_E_T_  = ' '"
	   		cQuery := ChangeQuery(cQuery)
	   		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	   		While (cAliasQry)->( !Eof() )
	   		   SDB->(DbGoTo((cAliasQry)->SDBRECNO))
	   			cGrvPri := AllTrim(SubStr(mv_par02,1,2))+SubStr(SDB->DB_PRIORI,3,Len(SDB->DB_PRIORI))
	   			// Ponto de entrada que permite a manipulacao do campo DB_PRIORI
	   			// Parametros: PARAMIXB[1] = Valor que seria gravado no campo DB_PRIORI
	   			//             PARAMIXB[2] = 1 para crescente / 2 para descrescente
	   			// Retorno:    Valor a ser gravado no campo DB_PRIORI
	   			If lWmsRegra
	   				cGrvPri := ExecBlock('WMSREGRA', .F., .F., {mv_par02, 1})
	   				If ValType(cGrvPri)!='C' .Or. Empty(cGrvPri)
	   					cGrvPri := mv_par02
	   				EndIf
	   			EndIf
	   			RecLock('SDB',.F.)
	   			SDB->DB_PRIORI := cGrvPri
	   			MsUnLock()
	      		(cAliasQry)->(dbSkip())
	   		EndDo
	   		(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( lRet )
/*--------------------------------------------------------------------------------
---WMSA331RHU
---Recurso Humano.
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331RHU()
Local aAreaAnt   := GetArea()
Local aAreaSDB   := SDB->(GetArea())
Local cQuery     := ""
Local cAliasQry  := ""
Local cMensagem  := ""
Local lRet       := .T.
Local cCarga     := ""
Local cDocto     := ""
Local cServico   := ""
Local cDesSer    := ""
Local cRecHum    := Space(TamSX3("DB_RECHUM")[1])
Local oSize      := Nil
Local aPosObj    := {}
Local aItensRh   := {}
Local aRecnoRh   := {}
Local aHList     := {}
Local aRetRegra  := {}
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local lMsgNaoC   := .F.
Local nOpca      := 0
Local nX         := 0
Local lMark      := .T.
Local oDlg       := Nil
Local oListBox   := Nil
Local oOk        := LoadBitmap( GetResources(), "LBOK")
Local oNo        := LoadBitmap( GetResources(), "LBNO")
Local lWM331Rhm  := ExistBlock('WM330RHM')
Local lCarga     := .F.

   TeclaAtalho(.F.)  // Desativa teclas de atalho

   DbSelectArea("SDB")
   If SDB->(!EOF())
      cCarga   := SDB->DB_CARGA
      cDocto   := SDB->DB_DOC + Iif(SDB->DB_ORIGEM <> "SC9",Iif(Empty(SDB->DB_SERIE)," / "+SDB->DB_SERIE,""),"")
      cServico := SDB->DB_SERVIC
      cDesSer  := Tabela("L4", SDB->DB_SERVIC, .F.)
      lCarga   := WmsCarga(SDB->DB_CARGA)

		cAliasQry := GetNextAlias()
		cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_STATUS IN ('"+aStatus[2]+"','"+aStatus[4]+"')"
		cQuery +=   " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
		If !Empty(SDB->DB_CARGA)
			cQuery += " AND DB_CARGA   = '"+SDB->DB_CARGA+"'"
		Else
			cQuery += " AND DB_DOC     = '"+SDB->DB_DOC+"'"
			If SDB->DB_ORIGEM <> "SC9"
				cQuery += " AND DB_SERIE = '"+SDB->DB_SERIE+"'"
			EndIf
			cQuery += " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
			cQuery += " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
		EndIf
		cQuery += " AND D_E_L_E_T_  = ' '"
		cQuery += " ORDER BY SDBRECNO"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->( !Eof() )
		   SDB->(DbGoTo((cAliasQry)->SDBRECNO))
   		// Array ListBox
   		AAdd(aItensRh,{.F., ;
   		(SDB->DB_TAREFA + " - " + Tabela("L2", SDB->DB_TAREFA, .F.)), ;
   		(SDB->DB_ATIVID + " - " + Tabela("L3", SDB->DB_ATIVID, .F.)), ;
   		 SDB->DB_RECHUM, ;
   		 SDB->DB_LOCAL, ;
   		 SDB->DB_LOCALIZ, ;
   		 SDB->DB_ENDDES, ;
   		 If(lCarga,"",SDB->DB_DOC), ;
   		 SDB->DB_PRODUTO, ;
   		 Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO,"B1_DESC"), ;
   		(SDB->DB_RHFUNC + " - " + Posicione("SRJ",1,xFilial("SRJ")+SDB->DB_RHFUNC,"RJ_DESC")), ;
   		 SDB->DB_QUANT })

   		AAdd(aRecnoRh,SDB->(RECNO()))

		(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

	If Len(aItensRh) > 0

		// Calcula as dimensoes dos objetos
		oSize := FwDefSize():New( .T. )  // Com enchoicebar

		// Cria Enchoice
		oSize:AddObject( "MASTER", 100, 85, .T., .F. ) // Adiciona enchoice
		oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

		// Dispara o cálculo
		oSize:Process()

		nOpca := 0

		DEFINE MSDIALOG oDlg TITLE STR0064;
		  FROM oSize:aWindSize[1],oSize:aWindSize[2];
		    TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

		// Monta a Enchoice
		aPosObj := {;
		oSize:GetDimension("MASTER","LININI"),;
		oSize:GetDimension("MASTER","COLINI"),;
		oSize:GetDimension("MASTER","LINEND"),;
		oSize:GetDimension("MASTER","COLEND")}

		@ aPosObj[1], aPosObj[2] TO aPosObj[3], aPosObj[4] LABEL STR0064 OF oDlg PIXEL // Recursos Humanos

		// ---
		If Empty(cCarga)
			@ aPosObj[1]+27,12 SAY RetTitle('DB_DOC') PIXEL
			@ aPosObj[1]+25,50 MSGET oGet2 VAR cDocto PIXEL WHEN .F.
		Else
			@ aPosObj[1]+27,12 SAY RetTitle('DB_CARGA') PIXEL
			@ aPosObj[1]+25,50 MSGET oGet4 VAR cCarga PIXEL WHEN .F.
		EndIf
		// ---
		@ aPosObj[1]+42,12 SAY RetTitle('DB_SERVIC') PIXEL
		@ aPosObj[1]+40,50 MSGET oGet5 VAR cServico PIXEL WHEN .F.
		@ aPosObj[1]+40,75 MSGET oGet6 VAR cDesSer  PIXEL WHEN .F.
		// ---
		@ aPosObj[1]+57,12 SAY RetTitle('DB_RECHUM') PIXEL
		@ aPosObj[1]+55,50 MSGET oGet7 VAR cRecHum PIXEL F3 "DCD"

		// ---
		AAdd( aHList, " ")
		AAdd( aHList, RetTitle("DB_TAREFA"))
		AAdd( aHList, RetTitle("DB_ATIVID"))
		AAdd( aHList, RetTitle("DB_RECHUM"))
		AAdd( aHList, RetTitle("DB_LOCAL"))
		AAdd( aHList, RetTitle("DB_LOCALIZ"))
		AAdd( aHList, RetTitle("DB_ENDDES"))
		AAdd( aHList, RetTitle("DB_DOC"))
		AAdd( aHList, RetTitle("DB_PRODUTO"))
		AAdd( aHList, RetTitle("B1_DESC"))
		AAdd( aHList, RetTitle("DB_RHFUNC"))
		AAdd( aHList, RetTitle("DB_QUANT"))

		// Carrega as informações a respeito do tamanho do objeto DETAIL
		aPosObj := {;
		oSize:GetDimension("DETAIL","LININI"),; // Pos.x
		oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
		oSize:GetDimension("DETAIL","XSIZE" ),; // Size.x
		oSize:GetDimension("DETAIL","YSIZE" )}  // Size.y

		oListBox := TWBrowse():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4],,aHList,,oDlg,,,,,,,,,,,,, "ARRAY", .T. )
		oListBox:SetArray(aItensRh)
		oListBox:bLine := { || {Iif(aItensRH[oListBox:nAT,1],oOk,oNo),;
		aItensRH[oListBox:nAT,2],;
		aItensRH[oListBox:nAT,3],;
		aItensRH[oListBox:nAT,4],;
		aItensRH[oListBox:nAT,5],;
		aItensRH[oListBox:nAT,6],;
		aItensRH[oListBox:nAT,7],;
		aItensRH[oListBox:nAT,8],;
		aItensRH[oListBox:nAT,9],;
		aItensRH[oListBox:nAT,10],;
		aItensRH[oListBox:nAT,11],;
		aItensRH[oListBox:nAT,12]}}
		oListBox:bLDblClick   := { || (aItensRh[oListBox:nAt,1]:=!aItensRh[oListBox:nAt,1],oListBox:Refresh())}
		oListBox:bHeaderClick := { |oObj,nCol| IIF(nCol==1,WmsA331Mrk(@oListBox,@aItensRH,@lMark),Nil) }

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()}) CENTERED

		// ---
		If nOpca == 2
			For nX := 1 To Len(aItensRh)
				If aItensRh[nX,1]
					SDB->(dbGoto(aRecnoRh[nX]))
					If SDB->(!EOF() .And. ;
						 DB_RECHUM <> cRecHum .And. ;
						 DB_ESTORNO== ' ' .And. ;
						 DB_ATUEST == 'N' .And. ;
						(DB_STATUS == aStatus[2] .Or. ;
						 DB_STATUS == aStatus[4]))
						DCI->(DbSetOrder(2))
						If Empty(cRecHum) .Or. DCI->(dbSeek( xFilial('DCI')+cRecHum+SDB->DB_RHFUNC,.T.))
							If !Empty(cRecHum)
								aRetRegra := {}
								// Verifica se ha regras para convocacao
								If WmsRegra('1',SDB->DB_LOCAL,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra)
									// Analisa se convocao ou nao
									If !WmsRegra('2',,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,,,,,aRetRegra,,SDB->DB_CARGA)
										lMsgNaoC := .T.
										Loop
									EndIf
								Else
								// Convocar para esta atividade somente se encontrar regra definida para o operador.
									If lNaoConv
										lMsgNaoC := .T.
										Loop
									EndIf
									// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
									// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
									If !WmsRegra('3',SDB->DB_LOCAL,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES)
										lMsgNaoC := .T.
										Loop
									EndIf
								EndIf
							EndIf
							If lWM331Rhm
								ExecBlock('WM330RHM',.F.,.F.,{cRecHum})
							EndIf
							RecLock('SDB',.F.)
							SDB->DB_RECHUM := cRecHum
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Next
			If lMsgNaoC
				Aviso('WMSA33100', STR0093, {'Ok'}) // Existem atividades que não foram atribuídas ao recurso humano devido limitação imposta pelas regras de convocação.
			EndIf
		EndIf
	Else
		cMensagem := STR0063 // Nao existem atividades a executar para este servico.
	EndIf

	If Len(cMensagem) > 0
		Aviso('WMS33010' ,cMensagem, {"Ok"})
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( lRet )
/*----------------------------------------------------------------------------
---WmsA331Mrk
---Marca/Desmarca Atividades
---Flavio Luiz Vicco 14/08/2006
----------------------------------------------------------------------------*/
Function WmsA331Mrk(oListBox, aItensRh, lMark)
Local nX
	For nX := 1 To Len(aItensRh)
		aItensRh[nX, 1] := lMark
	Next
	lMark := !lMark
	oListBox:Refresh()
Return( Nil )
/*----------------------------------------------------------------------------
---WmsA331Log
---Mostra Log de divergencia na conferencia
---Flavio Luiz Vicco 09/06/2006
----------------------------------------------------------------------------*/
Static Function WmsA331Log()
Local cWmsDoc  := SuperGetMV("MV_WMSDOC",.F.,"")
Local nTamDoc  := TamSX3('DB_DOC')[1]
Local nTamCar  := TamSX3('DB_CARGA')[1]
Local oDlg
Local oFont
Local cMemo    := ""
Local cSeekDCN := ""
Local cDocto   := ""
Local cCarga   := ""
Local cMapSep  := ""
Local cLogFile := ""

	// Desativa teclas de atalho
	TeclaAtalho(.F.)

	DbSelectArea("SDB")
	If SDB->(!EOF())
		cDocto   := SDB->DB_DOC
		cCarga   := SDB->DB_CARGA
		cMapSep := AllTrim(SDB->DB_MAPSEP)
		// Mostra registro de Ocorrencias (DCN)
		If !Empty(SDB->DB_OCORRE)
			DbSelectArea("DCN")
			DCN->(DbSetOrder(2)) // DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_NUMSEQ+DCN_DOC+DCN_SERIE+DCN_CLIFOR+DCN_LOJA+DCN_ITEM
			If DCN->(MSSeek(cSeekDCN:=(xFilial("DCN")+SDB->(DB_PRODUTO+DB_LOCAL))))
				Do While DCN->(!EOF() .And. DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_DOC+DCN_SERIE+DCN_CLIFOR+DCN_LOJA+DCN_ENDER==cSeekDCN+SDB->(DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_LOCALIZ))
					If Empty(cMemo)
						cMemo += STR0071+CRLF // Ocorrencias Registradas:
					EndIf
					cMemo += DCN->DCN_NUMERO+" - "+DCN->DCN_OCORR+" - "
					cMemo += AllTrim(Posicione("DCM",1,xFilial("DCM")+DCN->DCN_OCORR,"DCM_DESCRI"))+CRLF
					cMemo += DCN->DCN_STATUS+" - "+AllTrim(Substr(x3FieldToCbox("DCN_STATUS",DCN->DCN_STATUS),4))+" / "
					cMemo += DToC(DCN->DCN_DTINI)+" - "+DCN->DCN_HRINI
					If !Empty(DCN->DCN_DTFIM)
						cMemo += " / "+DToC(DCN->DCN_DTFIM)+" - "+DCN->DCN_HRFIM
					EndIf
					cMemo += CRLF
					If !Empty(DCN->DCN_ACAO)
						cMemo += DCN->DCN_ACAO+" - "+AllTrim(Substr(x3FieldToCbox("DCN_ACAO",DCN->DCN_ACAO),4))+CRLF
					EndIf
					cMemo += Replicate("-",80)+CRLF
					DCN->(dbSkip())
				EndDo
			EndIf
		EndIf
		If WmsCarga(cCarga)
			If !Empty(cMapSep)
				cLogFile := "EX"+AllTrim(Padr(cCarga,nTamCar))+".LOG"
			Else
				cLogFile := "RF"+AllTrim(Padr(cCarga,nTamCar))+".LOG"
			EndIf
		Else
			cLogFile := "RF"+AllTrim(Padr(cDocto,nTamDoc))+".LOG"
		EndIf
		// MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
		// Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
		// Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
		// C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
		If !Empty(cWmsDoc)
			cWmsDoc := AllTrim(cWmsDoc)
			If Right(cWmsDoc,1)$"/\"
				cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
			EndIf
			cLogFile := cWmsDoc+"\"+cLogFile
		EndIf
		If File(cLogFile) .Or. !Empty(cMemo)
			// MostraErro()
			DEFINE FONT oFont NAME "Courier New" SIZE 5,0
			cMemo += MemoRead(cLogFile)
			DEFINE MSDIALOG oDlg TITLE cLogFile FROM 3,0 TO 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL // Apaga
			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	EndIf

	// Reativa teclas de atalho
	TeclaAtalho(.T.)
Return( Nil )
/*----------------------------------------------------------------------------
---WmsA331Sld
---Exibe Saldos dos enderecos origem e destino
---Flavio Luiz Vicco 03/09/2006
----------------------------------------------------------------------------*/
Static Function WmsA331Sld()
Local aAreaAnt := GetArea()
Local aAreaSDB := SDB->(GetArea())
Local lRadioF  := (SuperGetMV('MV_RADIOF')=='S')
Local cStatRF  := "1"
Local aItSld   := {}
Local nSaldoOri:= 0
Local nSaldoDes:= 0
Local oDlgSld
Local oLBxSld

   TeclaAtalho(.F.)  // Desativa teclas de atalho

	DbSelectArea("SDB")
	// Endereco Origem
	nSaldoOri := SaldoSBF(SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO, Nil, Nil, Nil, .F., SDB->DB_ESTFIS)
	ConSldRF(SDB->DB_LOCAL, SDB->DB_LOCALIZ, SDB->DB_PRODUTO, Nil, Nil, @nSaldoOri, lRadioF, cStatRF, .F., .T., .T., .T.)
	AAdd(aItSld,{STR0066,SDB->DB_LOCAL,SDB->DB_LOCALIZ,Transform(nSaldoOri,PesqPict("SDB","DB_QUANT"))}) // Origem

	// Endereco Destino
	nSaldoDes := SaldoSBF(SDB->DB_LOCAL,SDB->DB_ENDDES, SDB->DB_PRODUTO, Nil, Nil, Nil, .F., SDB->DB_ESTDES)
	ConSldRF(SDB->DB_LOCAL, SDB->DB_ENDDES, SDB->DB_PRODUTO, Nil, Nil, @nSaldoDes, lRadioF, cStatRF, .F., .T., .T., .T.)
	AAdd(aItSld,{STR0067,SDB->DB_LOCAL,SDB->DB_ENDDES, Transform(nSaldoDes,PesqPict("SDB","DB_QUANT"))}) // Destino

	// Exibe Saldos dos enderecos
	DEFINE MSDIALOG oDlgSld TITLE STR0068 FROM 3,0 TO 160,480 PIXEL // Saldos (c/Servicos WMS)
	@ 05, 04 SAY RetTitle('DB_PRODUTO') PIXEL
	@ 05, 40 MSGET oGet1 VAR SDB->DB_PRODUTO PIXEL WHEN .F.
	@ 20, 04 LISTBOX oLBxSld VAR cVar FIELDS HEADER STR0069,RetTitle("DB_LOCAL"),RetTitle("DB_LOCALIZ"),STR0070 SIZE 235,45 OF oDlgSld PIXEL // Endereco // Saldo

	oLBxSld:SetArray(aItSld)
	oLBxSld:bLine := {||{aItSld[oLBxSld:nAT,1],aItSld[oLBxSld:nAT,2],aItSld[oLBxSld:nAT,3],aItSld[oLBxSld:nAT,4]}}

	DEFINE SBUTTON  FROM 65,200 TYPE 1 ACTION oDlgSld:End() ENABLE OF oDlgSld PIXEL
	ACTIVATE MSDIALOG oDlgSld CENTER

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return( Nil )
/*----------------------------------------------------------------------------
---WMSA331MSG
---Envia mensagens para coletores de radiofrequencia.
---Flavio Luiz Vicco 25/05/2010
----------------------------------------------------------------------------*/
Function WMSA331MSG()
Local oMemo
Local cMemo
Local oFont
Local oDlgMsg
Local cNumCol

	TeclaAtalho(.F.)  // Desativa teclas de atalho

	DbSelectArea("SDB")
	cCodOpe := SDB->DB_RECHUM
	If Empty(cCodOpe)
		WmsMessage(STR0081,WMSA33107) // Atividade sem operador atribuído.
		TeclaAtalho(.T.)
		Return
	EndIf
	cNumCol := RetNumCol(cCodOpe)
	If Empty(cNumCol)
		TeclaAtalho(.T.)
		Return
	EndIf
	//--
	DEFINE FONT oFont NAME "Mono AS" SIZE 8,20
	DEFINE MSDIALOG oDlgMsg FROM 0,0 TO 100,300  Pixel TITLE OemToAnsi(STR0082+cNumCol) // Mensagem para o coletor
	@ 0,0 GET oMemo  VAR cMemo MEMO SIZE 150,30 OF oDlgMsg PIXEL
	TButton():New( 035,001, STR0087, oDlgMsg, {|| MemoWrite('VT'+cNumCol+'.MSG',cMemo),oDlgMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) // Enviar
	TButton():New( 035,111, STR0088, oDlgMsg, {|| oDlgMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) // Sair
	oMemo:oFont:=oFont
	ACTIVATE MSDIALOG oDlgMsg CENTERED

   TeclaAtalho(.T.)  // Reativa teclas de atalho
Return
/*----------------------------------------------------------------------------
---RetNumCol
---Enva mensagens para coletores de radiofrequencia.
---Flavio Luiz Vicco 25/05/2010
----------------------------------------------------------------------------*/
Static Function RetNumCol(cCodOpe)
Local aAreaSav := GetArea()
Local cLinha   := Space(70)
Local cNumCol  := ""
Local cNomCol  := ""
Local cNomUsr  := ""
Local nX       := 0
Local aColetor := Directory("VT*.SEM")

Default cCodOpe := SDB->DB_RECHUM

	// Procura o usuario nos coletores ativos
	cNomUsr  := UsrRetName(cCodOpe)
	aColetor := Directory("VT*.SEM")
	For nX := 1 to Len(aColetor)
		cLinha  := Memoread(aColetor[nX,1])
		cNomCol := Subs(cLinha,4,25)
		If AllTrim(cNomCol) == Alltrim(cNomUsr)
			cNumCol := Left(cLinha,3)
			Exit
		EndIf
	Next nX
	If Empty(cNumCol)
		WmsMessage(STR0083,WMSA33108,2) // Operador com RF desligado.
	EndIf
	RestArea(aAreaSav)
Return( cNumCol )
/*--------------------------------------------------------------------------------
---WMSA331RPD
---Reprocessa documento
----------------------------------------------------------------------------------*/
Function WMSA331RPD()
	Reprocess('1')
Return Nil
/*--------------------------------------------------------------------------------
---WMSA331RPF
---Reprocessa todos
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Function WMSA331RPF()
	Reprocess('2')
Return Nil
/*--------------------------------------------------------------------------------
---Reprocess
---Reprocessa a Regra de Convocação
---Alexsander.Correa - 01/04/2015
---cOpcao, caracter, "1" = De acordo com o documento
                     "2" = Todos os documentos
----------------------------------------------------------------------------------*/
Static Function Reprocess(cOpcao)
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local cQuery    := ''
Local cQueryPE  := ''
Local cCliFor   := ''
Local cLoja     := ''
Local cCarga    := ''
Local cAliasSDB := GetNextAlias()

	Default cOpcao := '2'

	Private aLibSDB := {}

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	// Força recarregar os parametros da query do WMSA331
	Pergunte('WMA330', .F.)

	If cOpcao == '1' // Monta a query para reprocessar de acordo com o documento

		If SDB->(!Eof())

			cCarga  := SDB->DB_CARGA
			cDocto  := SDB->DB_DOC
			cCliFor := SDB->DB_CLIFOR
			cLoja   := SDB->DB_LOJA

			cQuery := "SELECT DB_LOCAL, DB_SERVIC, R_E_C_N_O_ RECNOSDB "
			cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_STATUS  = '-'"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
				cQuery += " AND DB_SERVIC >= '"+mv_par01+"'"
				cQuery += " AND DB_SERVIC <= '"+mv_par02+"'"
			EndIf
			If WmsCarga(cCarga)
				cQuery += " AND DB_CARGA  = '"+cCarga+"'"
			Else
				cQuery += " AND DB_DOC    = '"+cDocto+"'"
				cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
				cQuery += " AND DB_LOJA   = '"+cLoja+"'"
			EndIf
			If mv_par09 == 2
				cQuery += " AND NOT DB_STATUS IN ('"+aStatus[1]+"','"+aStatus[6]+"')"
			EndIf
			If !(Empty(mv_par10) .And. DtoS(mv_par11) == '20491231')
				cQuery += " AND DB_DATA >= '"+DToS(mv_par10)+"'"
				cQuery += " AND DB_DATA <= '"+DToS(mv_par11)+"'"
			EndIf
			If !(Empty(mv_par12) .And. DtoS(mv_par13) == '20491231')
				cQuery += " AND DB_DATAFIM >= '"+DToS(mv_par12)+"'"
				cQuery += " AND DB_DATAFIM <= '"+DToS(mv_par13)+"'"
			EndIf
			If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
				cQuery += " AND DB_PRODUTO >= '"+mv_par07+"'"
				cQuery += " AND DB_PRODUTO <= '"+mv_par08+"'"
			EndIf
			cQuery +=   " AND D_E_L_E_T_ = ' '"

			// Ponto de Entrada WM330QRY para a alteracao da Query
			If ExistBlock('WM330QRY')
				If ValType(cQueryPE:=ExecBlock('WM330QRY',.F.,.F.)) == 'C'
					cQuery += cQueryPE
				EndIf
			EndIf

		EndIf

	ElseIf cOpcao == '2' //Monta a query para reprocessar todos

		cQuery := "SELECT DB_LOCAL, DB_SERVIC, R_E_C_N_O_ RECNOSDB "
		cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
		cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
		cQuery +=   " AND DB_ESTORNO = ' '"
		cQuery +=   " AND DB_STATUS  = '-'"
		cQuery +=   " AND DB_ATUEST  = 'N'"
		If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
			cQuery += " AND DB_SERVIC >= '"+mv_par01+"'"
			cQuery += " AND DB_SERVIC <= '"+mv_par02+"'"
		EndIf
		If !(Empty(mv_par03) .And. Upper(mv_par04) == Replicate('Z', Len(mv_par04)))
			cQuery += " AND DB_CARGA >= '"+mv_par03+"'"
			cQuery += " AND DB_CARGA <= '"+mv_par04+"'"
		EndIf
		If !(Empty(mv_par05) .And. Upper(mv_par06) == Replicate('Z', Len(mv_par06)))
			cQuery += " AND DB_DOC >= '"+mv_par05+"'"
			cQuery += " AND DB_DOC <= '"+mv_par06+"'"
		EndIf
		If mv_par09 == 2
			cQuery += " AND NOT DB_STATUS IN ('"+aStatus[1]+"','"+aStatus[6]+"')"
		EndIf
		If !(Empty(mv_par10) .And. DtoS(mv_par11) == '20491231')
			cQuery += " AND DB_DATA >= '"+DToS(mv_par10)+"'"
			cQuery += " AND DB_DATA <= '"+DToS(mv_par11)+"'"
		EndIf
		If !(Empty(mv_par12) .And. DtoS(mv_par13) == '20491231')
			cQuery += " AND DB_DATAFIM >= '"+DToS(mv_par12)+"'"
			cQuery += " AND DB_DATAFIM <= '"+DToS(mv_par13)+"'"
		EndIf
		If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
			cQuery += " AND DB_PRODUTO >= '"+mv_par07+"'"
			cQuery += " AND DB_PRODUTO <= '"+mv_par08+"'"
		EndIf
		cQuery +=   " AND D_E_L_E_T_ = ' '"

		// Ponto de Entrada WM330QRY para a alteracao da Query
		If ExistBlock('WM330QRY')
			If ValType(cQueryPE:=ExecBlock('WM330QRY',.F.,.F.)) == 'C'
				cQuery += cQueryPE
			EndIf
		EndIf
	EndIf

	If !Empty(cQuery) // Validação para quando escolhida opção por documento e não existirem registros na tela

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSDB,.F.,.T.)

		// Carrega os registros SDB no array privado aLibSDB, para ser utilizado posteriormente pela função WmsExeDCF
		While (cAliasSDB)->(!Eof())
			AAdd(aLibSDB,{cStatAExe,(cAliasSDB)->RECNOSDB,(cAliasSDB)->DB_LOCAL,(cAliasSDB)->DB_SERVIC})
			(cAliasSDB)->(DbSkip())
		EndDo

		(cAliasSDB)->(DbCloseArea())

	EndIf

	If !Empty(aLibSDB)
		WmsExeDCF('2')  // Executa a regra e disponibiliza os registros do SDB para convocação
	Else
		WmsMessage(STR0108,'SIGAWMS') // Não existem registros aptos a reprocessar! A opção de reprocessar regra de convocação só pode ser executada em registros sem status definido.
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return


/*/{Protheus.doc} WMSOrdTare
	(Pesquisa por tarefas/atividades anteriores ainda nao executadas)
	@type  Function
	@author Equipe WMS
	@since 25/03/2024
	@return lRet, boolean, tarefa anterior
	@see (DLOGWMSMSP-16063)
	/*/
Static Function WMSOrdTare()
	Local aAreaSDB  := SDB->(GetArea())
	Local cQuery    := ''
	Local lOrdMov   := SuperGetMV('MV_WMSVLMV', .F., .T.) // Valida ordem de execução dos movimentos de recebimento com conferencia
	Local lConfEnd  := FwIsInCallStack("WMSA331") .And. lOrdMov .And. WMSHasConf(SDB->DB_SERVIC) //Executado via WMSA331, possui conferencia e enderecamento no mesmo servico e parametro habilitado
	Local lRet      := .T.
	Local lCarga    := WmsCarga(SDB->DB_CARGA)
	Local cAliasSDB := GetNextAlias()

	RestArea(aAreaSDB)
	aAreaSDB  := SDB->(GetArea())

	If lConfEnd
		cQuery := "SELECT DB_STATUS"
		cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
		cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
		If lCarga
			cQuery += " AND DB_CARGA  = '"+SDB->DB_CARGA+"'"
		Else
			cQuery += " AND DB_DOC    = '"+SDB->DB_DOC+"'"
			cQuery += " AND DB_SERIE  = '"+SDB->DB_SERIE+"'"
			cQuery += " AND DB_CLIFOR = '"+SDB->DB_CLIFOR+"'"
			cQuery += " AND DB_LOJA   = '"+SDB->DB_LOJA+"'"
		EndIf
		cQuery +=   " AND DB_PRODUTO   = '"+SDB->DB_PRODUTO+"'"
		cQuery +=   " AND DB_SERVIC  	 = '"+SDB->DB_SERVIC+"'"
		cQuery +=   " AND ((DB_ORDTARE < '"+SDB->DB_ORDTARE+"')"
		cQuery +=   " OR (DB_ORDTARE   = '"+SDB->DB_ORDTARE+"'"
		cQuery +=   " AND DB_IDMOVTO   = '"+SDB->DB_IDMOVTO+"'"
		cQuery +=   " AND DB_IDOPERA   < '"+SDB->DB_IDOPERA+"'))"
		cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
		cQuery +=   " AND DB_ATUEST    = 'N'"
		cQuery +=   " AND DB_ESTORNO   = ' '"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
		If (cAliasSDB)->(!Eof())
			lRet := .F. //-- Encontrou uma tarefa anterior ainda não executada
		EndIf
		(cAliasSDB)->(DbCloseArea())
	EndIf

	RestArea(aAreaSDB)
Return lRet
