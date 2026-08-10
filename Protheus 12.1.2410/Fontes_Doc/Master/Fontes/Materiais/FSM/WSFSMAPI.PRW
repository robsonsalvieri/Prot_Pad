#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmApi
Métodos Rest do FSM
@author flavio.martins
@since 13/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMAPI DESCRIPTION "WS de Integração Field Services Manager" 

	WSDATA dataAgenda            	AS STRING
	WSDATA codigo                	AS STRING
	WSDATA filtraAgendados		 	AS BOOLEAN
	WSDATA rawimage              	AS STRING    
	WSDATA userLogged            	AS STRING   
	WSDATA codObjeto             	AS STRING    
	WSDATA nomeObj               	AS STRING	
	WSDATA page                  	AS INTEGER
	WSDATA pageSize              	AS INTEGER
	WSDATA filter                	AS STRING
	WSDATA codProduto            	AS STRING 
	WSDATA codigoBase       	 	AS STRING 
	WSDATA idUnico		      	 	AS STRING 
	WSDATA cep	         		 	AS STRING
	WSDATA idUser 					AS STRING
	WSDATA codigoCliente			AS STRING
	WSDATA lojaCliente				AS STRING

	// Métodos GET
	WSMETHOD GET currentUser        DESCRIPTION 'Retorna os dados do usuario logado'                          	PATH "currentUser"   		PRODUCES APPLICATION_JSON 
	WSMETHOD GET dataGarantia    	DESCRIPTION 'Retorna a data de garantia da base de atendimento'   	  	  	PATH "dataGarantia"    		PRODUCES APPLICATION_JSON 
	WSMETHOD GET agendaAtendentes	DESCRIPTION 'Retorna agenda dos atendentes' 			  	  	 		  	PATH "agendaAtendentes"		PRODUCES APPLICATION_JSON 
	WSMETHOD GET clientesFSM		DESCRIPTION 'Retorno clientes	' 			  	  	 				      	PATH "clientesFSM"			PRODUCES APPLICATION_JSON 
	WSMETHOD GET workOrder			DESCRIPTION 'Ordem de Servico Field Service Manager' 			  		  	PATH "workOrder"	     	PRODUCES APPLICATION_JSON 
	WSMETHOD POST workOrder      	DESCRIPTION 'Inclusão Ordem de Servico Field Service Manager'             	PATH "workOrder"          	PRODUCES APPLICATION_JSON
	WSMETHOD PUT workOrder      	DESCRIPTION 'Alteração Ordem de Servico Field Service Manager'            	PATH "workOrder"          	PRODUCES APPLICATION_JSON
	WSMETHOD DELETE workOrder       DESCRIPTION 'Exclusão Ordem de Servico Field Service Manager'             	PATH "workOrder"          	PRODUCES APPLICATION_JSON
    WSMETHOD GET fotoProduto        DESCRIPTION 'Busca a foto do produto no repositorio de imagens'           	PATH "fotoProduto"        	PRODUCES APPLICATION_JSON  
    WSMETHOD GET codUsrLogged       DESCRIPTION 'Retorna se o usuario é um supervisor ou atendente' 	      	PATH "codUsrLogged"	    	PRODUCES APPLICATION_JSON 
	WSMETHOD POST anexarDocs       	DESCRIPTION 'Anexar arquivos - banco de conhecimento' 			  			PATH "anexarDocs"			PRODUCES APPLICATION_JSON      
    WSMETHOD POST deletarDocs     	DESCRIPTION 'Deletar arquivos - banco de conhecimento' 			  			PATH "deletarDocs"			PRODUCES APPLICATION_JSON  
	WSMETHOD GET baixarDocs			DESCRIPTION 'Retorna arquivos do banco de conhecimento' 			  	  	PATH "baixarDocs"			PRODUCES APPLICATION_JSON 
	WSMETHOD POST extraAnexar   	DESCRIPTION 'Anexar extras - banco de conhecimento'							PATH "extraAnexar"			PRODUCES APPLICATION_JSON 
	WSMETHOD GET usuarioChecklist  	DESCRIPTION 'Retorna os usuários do checklist'								PATH "usuarioChecklist"  	PRODUCES APPLICATION_JSON	
	WSMETHOD GET getAnexo   		DESCRIPTION 'Retorna os dados do Produto e seus anexos'						PATH "getAnexo"  			PRODUCES APPLICATION_JSON	
	WSMETHOD POST createForm      	DESCRIPTION 'Criação do formulário do checklist'                        	PATH "createForm"           PRODUCES APPLICATION_JSON
	WSMETHOD POST checklistOS  	    DESCRIPTION 'Criação do formulário do checklist - SIGAFSM'                 	PATH "checklistOS"     		PRODUCES APPLICATION_JSON
	WSMETHOD GET parametros			DESCRIPTION 'Retorna a lista de parâmetros do SIGAFSM'						PATH "parametros"			PRODUCES APPLICATION_JSON	
	WSMETHOD GET ordemServicoBase	DESCRIPTION 'Retorna todas as ordem de serviço da base de atendimento'	    PATH "ordemServicoBase"	    PRODUCES APPLICATION_JSON	
	WSMETHOD GET consultaCEP		DESCRIPTION 'Retorna as informacoes sobre o CEP consultado'	    	        PATH "consultaCEP"	       	PRODUCES APPLICATION_JSON
	WSMETHOD GET userAtendente  	DESCRIPTION 'Retorna os usuários Protheus para vinculo com o atendente'		PATH "userAtendente"  		PRODUCES APPLICATION_JSON	
	WSMETHOD GET dataBaseProtheus  	DESCRIPTION 'Retorna a database do servidor Protheus'						PATH "dataBaseProtheus"  	PRODUCES APPLICATION_JSON	
	WSMETHOD GET historicoAponta  	DESCRIPTION 'Historio de apontamento da base de atendimento'				PATH "historicoAponta"  	PRODUCES APPLICATION_JSON	
	WSMETHOD POST processEventsUpdate  	DESCRIPTION 'Atualiza o cadastro de eventos'							PATH "processEventsUpdate" 	PRODUCES APPLICATION_JSON	
	WSMETHOD POST quantEndereco  	DESCRIPTION 'Retorna a quantidade do endereço SBF '					        PATH "quantEndereco"  	    PRODUCES APPLICATION_JSON	

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Retorna o nome do usuario logado

@author vitor.kwon
@since 08/11/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD GET currentUser WSRECEIVE WSREST FSMAPI

Local oResponse	:= JsonObject():New()

aSM0Data := {}
cNomeUser:=  cUserName 
cCodUser := __cUserId
cEmprLog := FWGrpCompany()
cFiliLog := FWCodFil()
aFieldSM0 := { "M0_CODIGO","M0_CODFIL","M0_NOMECOM","M0_CGC","M0_INSCM","M0_CIDENT","M0_ESTENT","M0_ENDENT",;
				"M0_BAIRENT","M0_CEPENT","M0_COMPENT","M0_TEL"}

aSM0Data2 := FWSM0Util():GetSM0Data(, cFiliLog, aFieldSM0)

	oResponse['userCode'] := cCodUser
	oResponse['userName'] := cNomeUser
	oResponse['isAdmin']  := FwIsAdmin()

	dbSelectArea('AA1')
	AA1->(dbSetOrder(4))
	
	If AA1->(dbSeek(xFilial('AA1')+cCodUser))
		oResponse['armazem']        := (AA1->AA1_LOCAL)  // Armazem
		oResponse['pecasBoas']      := (AA1->AA1_LOCLZB) // pecas Boas
		oResponse['pecasRuins']     := (AA1->AA1_LOCLZR) // pecasRuins
		oResponse['attendantCode']  := (AA1->AA1_CODTEC) // Codigo do atendente
		oResponse['isAttendant']    := (AA1->AA1_SUPERV == '2') // Se o usuario === atendente
		oResponse['isSupervisor']   := (AA1->AA1_SUPERV == '1') // Se o usuario === Supervisor
	Else
		oResponse['attendantCode']  := '' // Codigo do atendente
		oResponse['isAttendant']    := .F. // Se o usuario === atendente
		oResponse['isSupervisor']   := .F. // Se o usuario === Supervisor
		oResponse['armazem']        := ''  // Armazem
		oResponse['pecasBoas']      := '' // pecas Boas
		oResponse['pecasRuins']     := '' // pecasRuins

	Endif

	oResponse['companyCode']    := aSM0Data2[1][2]  // Codigo da Companhia
	oResponse['branchCode']     := aSM0Data2[2][2]  // codigo da Filial
	oResponse['branchName']     := aSM0Data2[3][2]  // Razão social da Filial
	oResponse['cnpj']           := aSM0Data2[4][2]  // CNPJ
	oResponse['inscricao']      := aSM0Data2[5][2]  // IE
	oResponse['city']           := aSM0Data2[6][2]  // Cidade
	oResponse['state']          := aSM0Data2[7][2]  // Estado
	oResponse['adress']         := aSM0Data2[8][2]  // Endereço
	oResponse['neighborhood']   := aSM0Data2[9][2]  // Bairro
	oResponse['zipcode']        := aSM0Data2[10][2] // Cep
	oResponse['complement']     := aSM0Data2[11][2] // Complemento
	oResponse['telefone']       := aSM0Data2[12][2] // Telefone

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} codigoAtendente
Retorna o próximo código do cadastro de atendentes

@author flavio.martins
@since 13/10/2023
@version 1.0
*/*/
//-------------------------------------------------------------------
WSMETHOD GET dataGarantia WSRECEIVE WSREST FSMAPI
Local oResponse	:= JsonObject():New()

    cDataGarantia :=  DtoS(&(SuperGetMv("MV_FORMGAR")))

	oResponse['dataGarantia'] := cDataGarantia

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T. 


//-------------------------------------------------------------------
/*/{Protheus.doc} codigoAtendente
Retorna o próximo código do cadastro de atendentes

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------


WSMETHOD GET agendaAtendentes WSRECEIVE dataAgenda, filtraAgendados WSREST FSMAPI
Local lRet      	:= .T.
Local cAliasTmp		:= GetNextAlias()
Local nAtendentes   := 0
Local nAgendas      := 0
Local cCodAtendente := ''
Local oResponse		:= JsonObject():New()
Local cQry := ''
local oQry

cQry := "	SELECT AA1.AA1_CODTEC, "
cQry += "	       AA1.AA1_NOMTEC, "
cQry += "	       AA1.AA1_FUNCAO, "
cQry += "		   SRJ.RJ_DESC,    "
cQry += "		   JN6.JN6_CODJN3, "
cQry += "	       JN6.JN6_DTINI,  "
cQry += "	       JN6.JN6_DTFIM,  "
cQry += "	       JN6.JN6_HRINI,  "
cQry += "	       JN6.JN6_HRFIM,  "
cQry += "		   JN6.JN6_SITUAC,  "
cQry += "		   JN6.JN6_CODIGO "
cQry += "	FROM "+RetSqlName('AA1')+""
cQry += "	AA1 LEFT JOIN  "+RetSqlName("JN6")+" JN6 ON JN6.JN6_FILIAL = ? "
cQry += "	AND JN6.JN6_CODAA1 = AA1.AA1_CODTEC "
cQry += "	AND JN6.JN6_DTINI = '"+Self:dataAgenda+"' "
cQry += "	AND JN6.JN6_STATUS = '1'  "
cQry += "	AND JN6.D_E_L_E_T_ = ' ' "
cQry += "	LEFT JOIN  "+RetSqlName("SRJ")+"  SRJ ON SRJ.RJ_FILIAL = ? "
cQry += "	AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO "
cQry += "	AND SRJ.D_E_L_E_T_ = ' ' "
cQry += "	WHERE AA1.AA1_FILIAL = ? "
cQry += "	AND AA1.D_E_L_E_T_ = ' ' "
If (Self:filtraAgendados != Nil .And. Self:filtraAgendados)
	cQry += " AND JN6.JN6_CODJN3 IS NOT NULL "
Endif
cQry += "	ORDER BY AA1.AA1_CODTEC "

oQry := FwPreparedStatement():New(cQry)
oQry:SetString(1, xFilial("JN6"))
oQry:SetString(2, xFilial("SRJ"))
oQry:SetString(3, xFilial("AA1"))

cQry := oQry:GetFixQuery()
MPSysOpenQuery(cQry, cAliasTmp)

oResponse['atendentes'] := {}

While (cAliasTmp)->(!Eof())
	
	If cCodAtendente != (cAliasTmp)->AA1_CODTEC
		
		cCodAtendente := (cAliasTmp)->AA1_CODTEC

		Aadd(oResponse['atendentes'], JsonObject():New())

		nAtendentes++

		oResponse['atendentes'][nAtendentes]['codigoAtendente'] := AllTrim((cAliasTmp)->AA1_CODTEC)
		oResponse['atendentes'][nAtendentes]['nomeAtendente'] := AllTrim((cAliasTmp)->AA1_NOMTEC)
		oResponse['atendentes'][nAtendentes]['codigoFuncao'] := AllTrim((cAliasTmp)->AA1_FUNCAO)
		oResponse['atendentes'][nAtendentes]['descricaoFuncao'] := AllTrim((cAliasTmp)->RJ_DESC)
		

		oResponse['atendentes'][nAtendentes]['agendas'] := {}
		
		nAgendas := 0

	Endif

	nAgendas++

	Aadd(oResponse['atendentes'][nAtendentes]['agendas'], JsonObject():New())
	
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['codigo'] := AllTrim((cAliasTmp)->JN6_CODIGO)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['ordemServico'] := AllTrim((cAliasTmp)->JN6_CODJN3)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['dataInicial'] := AllTrim((cAliasTmp)->JN6_DTINI)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['dataFinal'] := AllTrim((cAliasTmp)->JN6_DTFIM)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['horaInicial'] := AllTrim((cAliasTmp)->JN6_HRINI)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['horaFinal'] := AllTrim((cAliasTmp)->JN6_HRFIM)
	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['situacao'] := AllTrim((cAliasTmp)->JN6_SITUAC)

	(cAliasTmp)->(dbSkip())

End

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()
FwFreeObj( oQry )


Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------


WSMETHOD GET clientesFSM WSRECEIVE WSREST FSMAPI
Local lRet      	:= .T.
Local cAliasTmp		:= GetNextAlias()
Local nClientes   := 0
Local oResponse		:= JsonObject():New()
Local cQry := ''
local oQry

cQry := "	SELECT A1_FILIAL, A1_COD, A1_LOJA "
cQry += "	FROM "+RetSqlName("SA1")+" SA1 "
cQry += "	WHERE SA1.A1_FILIAL = ? "
cQry += "	AND SA1.D_E_L_E_T_ = ' ' "

oQry := FwPreparedStatement():New(cQry)
oQry:SetString(1, xFilial("SA1"))
cQry := oQry:GetFixQuery()
MPSysOpenQuery(cQry, cAliasTmp)
	
oResponse['clientes'] := {}

While (cAliasTmp)->(!Eof())

		nClientes++
	
		Aadd(oResponse['clientes'], JsonObject():New())

		oResponse['clientes'][nClientes]['filial'] := AllTrim((cAliasTmp)->A1_FILIAL)
		oResponse['clientes'][nClientes]['codigoCliente'] := AllTrim((cAliasTmp)->A1_COD)
		oResponse['clientes'][nClientes]['lojaCliente'] := AllTrim((cAliasTmp)->A1_LOJA)
	

	(cAliasTmp)->(dbSkip())

End

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()
FwFreeObj( oQry )

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD GET workOrder WSRECEIVE codigo WSREST FSMAPI
Local lRet      	:= .T.
Local oResponse		:= JsonObject():New()
Local oModel        := Nil
Local nServico      := 0
Local nProduto      := 0
Local nAtendente    := 0

If (Self:codigo == Nil)

	SetRestFault(404, EncodeUtf8("O parâmetro 'codigo' deve ser informado para este tipo de requisição"))

	Return .F.

Endif

JN3->(dbSetOrder(1))

If !(JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	SetRestFault(404, EncodeUtf8("Código da ordem de serviço não encontrada"))

	Return .F.

Endif

oModel := FwLoadModel('FSMA008')
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

oResponse['codigoOrdem'] := oModel:GetValue('JN3MASTER','JN3_CODIGO')
oResponse['ordemOrigem'] := oModel:GetValue('JN3MASTER','JN3_CODORI')
oResponse['descricaoOrdem'] := oModel:GetValue('JN3MASTER','JN3_DESCRI')
oResponse['codigoCliente'] := oModel:GetValue('JN3MASTER','JN3_CLIENT')
oResponse['lojaCliente'] := oModel:GetValue('JN3MASTER','JN3_LOJA')
oResponse['prioridade'] := oModel:GetValue('JN3MASTER','JN3_PRIORI')
oResponse['nomeSolicitante'] := oModel:GetValue('JN3MASTER','JN3_NOMSOL')
oResponse['nomeContato'] := oModel:GetValue('JN3MASTER','JN3_NOMCNT')
oResponse['telefoneContato'] := oModel:GetValue('JN3MASTER','JN3_TELCNT')
oResponse['atendimentoInterno'] := oModel:GetValue('JN3MASTER','JN3_ATEINT')
oResponse['codigoBase'] := oModel:GetValue('JN3MASTER','JN3_CODPRO')
oResponse['descricaoBase'] := oModel:GetValue('JN3MASTER','JN3_DSCSB1')
oResponse['numeroSerie'] := oModel:GetValue('JN3MASTER','JN3_NUMSER')
oResponse['dataInclusao'] := DtoS(oModel:GetValue('JN3MASTER','JN3_DTINCL'))

oResponse['servicos'] := {}

For nServico := 1 To oModel:GetModel('JN4DETAIL'):Length()

	Aadd(oResponse['servicos'], JsonObject():New())
	
	oModel:GetModel('JN4DETAIL'):GoLine(nServico)

	oResponse['servicos'][nServico]['codigoServico'] := oModel:GetValue('JN4DETAIL','JN4_CODJN1', nServico)
	oResponse['servicos'][nServico]['descricaoServico'] := oModel:GetValue('JN4DETAIL','JN4_DSCJN1', nServico)
	oResponse['servicos'][nServico]['checklistObrigatorio'] := oModel:GetValue('JN4DETAIL','JN4_CHKOBR', nServico)
	oResponse['servicos'][nServico]['observacoes'] := oModel:GetValue('JN4DETAIL','JN4_OBSERV', nServico)

	oResponse['servicos'][nServico]['produtos'] := {}

	For nProduto := 1 To oModel:GetModel('JN5DETAIL'):Length() 

		Aadd(oResponse['servicos'][nServico]['produtos'], JsonObject():New())

		oModel:GetModel('JN5DETAIL'):GoLine(nProduto)

		oResponse['servicos'][nServico]['produtos'][nProduto]['codigoProduto'] := oModel:GetValue('JN5DETAIL','JN5_CODPRO', nProduto)
		oResponse['servicos'][nServico]['produtos'][nProduto]['descricaoProduto'] := oModel:GetValue('JN5DETAIL','JN5_DSCSB1', nProduto)
		oResponse['servicos'][nServico]['produtos'][nProduto]['quantidade'] := oModel:GetValue('JN5DETAIL','JN5_QTDPRO', nProduto)

	Next 
	
Next 

oResponse['atendentes'] := {}

For nAtendente := 1 To oModel:GetModel('JN6DETAIL'):Length()

	Aadd(oResponse['atendentes'], JsonObject():New())
	
	oModel:GetModel('JN6DETAIL'):GoLine(nAtendente)

	oResponse['atendentes'][nAtendente]['codigoAtendente'] := oModel:GetValue('JN6DETAIL','JN6_CODAA1', nAtendente)
	oResponse['atendentes'][nAtendente]['codigoFuncao'] := oModel:GetValue('JN6DETAIL','JN6_CODFUN', nAtendente)
	oResponse['atendentes'][nAtendente]['dataInicial'] := DtoS(oModel:GetValue('JN6DETAIL','JN6_DTINI', nAtendente))
	oResponse['atendentes'][nAtendente]['horaInicial'] := StrTran(oModel:GetValue('JN6DETAIL','JN6_HRINI', nAtendente),':')
	oResponse['atendentes'][nAtendente]['dataFinal'] := DtoS(oModel:GetValue('JN6DETAIL','JN6_DTFIM', nAtendente))
	oResponse['atendentes'][nAtendente]['horaFinal'] := StrTran(oModel:GetValue('JN6DETAIL','JN6_HRFIM', nAtendente),':')
	
Next 

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------



WSMETHOD POST workOrder WSREST FSMAPI
Local oModel       := Nil
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgError	   := ''
Local nServico     := 0
Local nProduto     := 0
Local nAtendente   := 0
Local cCodigoJN3   := ''
Local cFilialJN3   := ''

oRequest:fromJson(cBody)

oModel := FwLoadModel('FSMA008')

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

oModel:SetValue('JN3MASTER', 'JN3_CODIGO', oRequest['codigoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CODORI', oRequest['ordemOrigem'])
oModel:SetValue('JN3MASTER', 'JN3_DESCRI', oRequest['descricaoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CLIENT', oRequest['codigoCliente'])
oModel:SetValue('JN3MASTER', 'JN3_LOJA',   oRequest['lojaCliente'])
oModel:SetValue('JN3MASTER', 'JN3_PRIORI', oRequest['prioridade'])
oModel:SetValue('JN3MASTER', 'JN3_NOMSOL', oRequest['nomeSolicitante'])
oModel:SetValue('JN3MASTER', 'JN3_NOMCNT', oRequest['nomeContato'])
oModel:SetValue('JN3MASTER', 'JN3_TELCNT', oRequest['telefoneContato'])
oModel:SetValue('JN3MASTER', 'JN3_ATEINT', oRequest['atendimentoInterno'])
oModel:SetValue('JN3MASTER', 'JN3_CODPRO', oRequest['codigoBase'])
oModel:SetValue('JN3MASTER', 'JN3_NUMSER', oRequest['numeroSerie'])
oModel:SetValue('JN3MASTER', 'JN3_DTINCL', StoD(oRequest['dataInclusao']))

For nServico := 1 To Len(oRequest['servicos'])

	If (nServico > 1) 
		oModel:GetModel('JN4DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN4DETAIL', 'JN4_CODJN3', oRequest['codigoOrdem'])
	oModel:SetValue('JN4DETAIL', 'JN4_CODJN1', oRequest['servicos'][nServico]['codigoServico'])
	oModel:SetValue('JN4DETAIL', 'JN4_CHKOBR', oRequest['servicos'][nServico]['checklistObrigatorio'])
	oModel:SetValue('JN4DETAIL', 'JN4_OBSERV', oRequest['servicos'][nServico]['observacoes'])

	For nProduto := 1 To Len(oRequest['servicos'][nServico]['produtos'])

		If (nProduto > 1) 
			oModel:GetModel('JN5DETAIL'):AddLine()
		Endif

		oModel:SetValue('JN5DETAIL', 'JN5_CODJN4', oModel:GetValue('JN4DETAIL', 'JN4_CODIGO'))
		oModel:SetValue('JN5DETAIL', 'JN5_CODPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['codigoProduto'])
		oModel:SetValue('JN5DETAIL', 'JN5_QTDPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['quantidade'])

	Next

Next

For nAtendente := 1 To Len(oRequest['atendentes'])

	If (nAtendente > 1) 
		oModel:GetModel('JN6DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN6DETAIL', 'JN6_CODJN3', oModel:GetValue('JN3MASTER', 'JN3_CODIGO'))
	oModel:SetValue('JN6DETAIL', 'JN6_CODAA1', oRequest['atendentes'][nAtendente]['codigoAtendente'])
	oModel:SetValue('JN6DETAIL', 'JN6_CODFUN', oRequest['atendentes'][nAtendente]['codigoFuncao'])
	oModel:SetValue('JN6DETAIL', 'JN6_DTINI', StoD(oRequest['atendentes'][nAtendente]['dataInicial']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRINI', Transform(oRequest['atendentes'][nAtendente]['horaInicial'],'@R 99:99'))
	oModel:SetValue('JN6DETAIL', 'JN6_DTFIM', StoD(oRequest['atendentes'][nAtendente]['dataFinal']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRFIM', Transform(oRequest['atendentes'][nAtendente]['horaFinal'],'@R 99:99'))

Next

If oModel:VldData()
	cFilialJN3 := xFilial('JN3')
	cCodigoJN3 := oModel:GetValue('JN3MASTER', 'JN3_CODIGO')

	oModel:CommitData()
Else
	lRet 	  := .F.	
	cMsgError := oModel:GetErrorMessage()[6]
Endif

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço incluída com sucesso')
	oResponse['data'] := {}
		
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['filial'] := cFilialJN3
	oResponse['data'][1]['codigoOrdem'] := cCodigoJN3

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()
oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD PUT workOrder WSRECEIVE codigo WSREST FSMAPI
Local oModel       := Nil
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgError	   := ''
Local nServico     := 0
Local nProduto     := 0
Local nAtendente   := 0
Local cCodigoJN3   := ''
Local cFilialJN3   := ''

oRequest:fromJson(cBody)

If (Self:codigo == Nil)

	SetRestFault(404, EncodeUtf8("O parâmetro 'codigo' deve ser informado para este tipo de requisição"))

	Return .F.

Endif

JN3->(dbSetOrder(1))

If !(JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	SetRestFault(404, EncodeUtf8("Código da ordem de serviço não encontrada"))

	Return .F.

Endif

oModel := FwLoadModel('FSMA008')

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

oModel:SetValue('JN3MASTER', 'JN3_CODIGO', oRequest['codigoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CODORI', oRequest['ordemOrigem'])
oModel:SetValue('JN3MASTER', 'JN3_DESCRI', oRequest['descricaoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CLIENT', oRequest['codigoCliente'])
oModel:SetValue('JN3MASTER', 'JN3_LOJA', oRequest['lojaCliente'])
oModel:SetValue('JN3MASTER', 'JN3_PRIORI', oRequest['prioridade'])
oModel:SetValue('JN3MASTER', 'JN3_NOMSOL', oRequest['nomeSolicitante'])
oModel:SetValue('JN3MASTER', 'JN3_NOMCNT', oRequest['nomeContato'])
oModel:SetValue('JN3MASTER', 'JN3_TELCNT', oRequest['telefoneContato'])
oModel:SetValue('JN3MASTER', 'JN3_ATEINT', oRequest['atendimentoInterno'])
oModel:SetValue('JN3MASTER', 'JN3_CODPRO', oRequest['codigoBase'])
oModel:SetValue('JN3MASTER', 'JN3_NUMSER', oRequest['numeroSerie'])
oModel:SetValue('JN3MASTER', 'JN3_DTINCL', StoD(oRequest['dataInclusao']))

For nServico := 1 To Len(oRequest['servicos'])

	If (nServico > 1) 
		oModel:GetModel('JN4DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN4DETAIL', 'JN4_CODJN3', oRequest['codigoOrdem'])
	oModel:SetValue('JN4DETAIL', 'JN4_CODJN1', oRequest['servicos'][nServico]['codigoServico'])
	oModel:SetValue('JN4DETAIL', 'JN4_CHKOBR', oRequest['servicos'][nServico]['checklistObrigatorio'])
	oModel:SetValue('JN4DETAIL', 'JN4_OBSERV', oRequest['servicos'][nServico]['observacoes'])

	For nProduto := 1 To Len(oRequest['servicos'][nServico]['produtos'])

		If (nProduto > 1) 
			oModel:GetModel('JN5DETAIL'):AddLine()
		Endif

		oModel:SetValue('JN5DETAIL', 'JN5_CODJN4', oModel:GetValue('JN4DETAIL', 'JN4_CODIGO'))
		oModel:SetValue('JN5DETAIL', 'JN5_CODPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['codigoProduto'])
		oModel:SetValue('JN5DETAIL', 'JN5_QTDPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['quantidade'])

	Next

Next

For nAtendente := 1 To Len(oRequest['atendentes'])

	If (nAtendente > 1) 
		oModel:GetModel('JN6DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN6DETAIL', 'JN6_CODJN3', oModel:GetValue('JN3MASTER', 'JN3_CODIGO'))
	oModel:SetValue('JN6DETAIL', 'JN6_CODAA1', oRequest['atendentes'][nAtendente]['codigoAtendente'])
	oModel:SetValue('JN6DETAIL', 'JN6_CODFUN', oRequest['atendentes'][nAtendente]['codigoFuncao'])
	oModel:SetValue('JN6DETAIL', 'JN6_DTINI', StoD(oRequest['atendentes'][nAtendente]['dataInicial']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRINI', Transform(oRequest['atendentes'][nAtendente]['horaInicial'],'@R 99:99'))
	oModel:SetValue('JN6DETAIL', 'JN6_DTFIM', StoD(oRequest['atendentes'][nAtendente]['dataFinal']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRFIM', Transform(oRequest['atendentes'][nAtendente]['horaFinal'],'@R 99:99'))

Next

If oModel:VldData()
	cFilialJN3 := xFilial('JN3')
	cCodigoJN3 := oModel:GetValue('JN3MASTER', 'JN3_CODIGO')

	oModel:CommitData()
Else
	lRet 	  := .F.	
	cMsgError := oModel:GetErrorMessage()[6]
Endif

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço atualizada com sucesso')
	oResponse['data'] := {}
		
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['filial'] := cFilialJN3
	oResponse['data'][1]['codigoOrdem'] := cCodigoJN3

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()
oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD DELETE workOrder WSRECEIVE codigo WSREST FSMAPI
Local oModel       := Nil
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cMsgError	   := ''

oModel := FwLoadModel('FSMA008')

If (Self:codigo == Nil)

	SetRestFault(404, EncodeUtf8("O parâmetro 'codigo' deve ser informado para este tipo de requisição"))

	Return .F.

Endif

JN3->(dbSetOrder(1))

If !(JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	SetRestFault(404, EncodeUtf8("Código da ordem de serviço não encontrada"))

	Return .F.

Endif

oModel:SetOperation(MODEL_OPERATION_DELETE)
oModel:Activate()

If oModel:VldData()
	oModel:CommitData()
Else
	lRet 	  := .F.	
	cMsgError := oModel:GetErrorMessage()[6]
Endif

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço excluída com sucesso')

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	oResponse['status'] := 'error'
	oResponse['message'] := EncodeUtf8(cMsgError)
	
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()
oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

Static Function GrvOrdem(oModel)
Local cMsgError	   := ''
Local nServico     := 0
Local nProduto     := 0
Local nAtendente   := 0
Local cCodigoJN3   := ''
Local cFilialJN3   := ''

oModel:SetValue('JN3MASTER', 'JN3_CODIGO', oRequest['codigoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CODORI', oRequest['ordemOrigem'])
oModel:SetValue('JN3MASTER', 'JN3_DESCRI', oRequest['descricaoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CLIENT', oRequest['codigoCliente'])
oModel:SetValue('JN3MASTER', 'JN3_LOJA', oRequest['lojaCliente'])
oModel:SetValue('JN3MASTER', 'JN3_PRIORI', oRequest['prioridade'])
oModel:SetValue('JN3MASTER', 'JN3_NOMSOL', oRequest['nomeSolicitante'])
oModel:SetValue('JN3MASTER', 'JN3_NOMCNT', oRequest['nomeContato'])
oModel:SetValue('JN3MASTER', 'JN3_TELCNT', oRequest['telefoneContato'])
oModel:SetValue('JN3MASTER', 'JN3_ATEINT', oRequest['atendimentoInterno'])
oModel:SetValue('JN3MASTER', 'JN3_CODPRO', oRequest['codigoBase'])
oModel:SetValue('JN3MASTER', 'JN3_NUMSER', oRequest['numeroSerie'])
oModel:SetValue('JN3MASTER', 'JN3_DTINCL', StoD(oRequest['dataInclusao']))

For nServico := 1 To Len(oRequest['servicos'])

	If (nServico > 1) 
		oModel:GetModel('JN4DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN4DETAIL', 'JN4_CODJN3', oRequest['codigoOrdem'])
	oModel:SetValue('JN4DETAIL', 'JN4_CODJN1', oRequest['servicos'][nServico]['codigoServico'])
	oModel:SetValue('JN4DETAIL', 'JN4_CHKOBR', oRequest['servicos'][nServico]['checklistObrigatorio'])
	oModel:SetValue('JN4DETAIL', 'JN4_OBSERV', oRequest['servicos'][nServico]['observacoes'])

	For nProduto := 1 To Len(oRequest['servicos'][nServico]['produtos'])

		If (nProduto > 1) 
			oModel:GetModel('JN5DETAIL'):AddLine()
		Endif

		oModel:SetValue('JN5DETAIL', 'JN5_CODJN4', oModel:GetValue('JN4DETAIL', 'JN4_CODIGO'))
		oModel:SetValue('JN5DETAIL', 'JN5_CODPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['codigoProduto'])
		oModel:SetValue('JN5DETAIL', 'JN5_QTDPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['quantidade'])

	Next

Next

For nAtendente := 1 To Len(oRequest['atendentes'])

	If (nAtendente > 1) 
		oModel:GetModel('JN6DETAIL'):AddLine()
	Endif

	oModel:SetValue('JN6DETAIL', 'JN6_CODJN3', oModel:GetValue('JN3MASTER', 'JN3_CODIGO'))
	oModel:SetValue('JN6DETAIL', 'JN6_CODAA1', oRequest['atendentes'][nAtendente]['codigoAtendente'])
	oModel:SetValue('JN6DETAIL', 'JN6_CODFUN', oRequest['atendentes'][nAtendente]['codigoFuncao'])
	oModel:SetValue('JN6DETAIL', 'JN6_DTINI', StoD(oRequest['atendentes'][nAtendente]['dataInicial']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRINI', Transform(oRequest['atendentes'][nAtendente]['horaInicial'],'@R 99:99'))
	oModel:SetValue('JN6DETAIL', 'JN6_DTFIM', StoD(oRequest['atendentes'][nAtendente]['dataFinal']))
	oModel:SetValue('JN6DETAIL', 'JN6_HRFIM', Transform(oRequest['atendentes'][nAtendente]['horaFinal'],'@R 99:99'))

Next

If oModel:VldData()
	cFilialJN3 := xFilial('JN3')
	cCodigoJN3 := oModel:GetValue('JN3MASTER', 'JN3_CODIGO')

	oModel:CommitData()
Else
	lRet 	  := .F.	
	cMsgError := oModel:GetErrorMessage()[6]
Endif

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço atualizada com sucesso')
	oResponse['data'] := {}
		
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['filial'] := cFilialJN3
	oResponse['data'][1]['codigoOrdem'] := cCodigoJN3

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	oResponse['status'] := 'error'
	oResponse['message'] := EncodeUtf8(cMsgError)
	
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD GET fotoProduto WSRECEIVE rawimage WSSERVICE FSMAPI
Local cData     := ""
Local cTmp      := GetNextAlias()
Local cFile     := ""
Local cMime     := "image/jpeg"
Local cQry := ''
local oQry

	rawimage := Self:rawimage

	cQry := " SELECT B1_BITMAP
	cQry += " FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' "
	cQry += " AND B1_BITMAP  = '"+Self:rawimage+"'  "

	oQry := FwPreparedStatement():New(cQry)
	cQry := oQry:GetFixQuery()
	MPSysOpenQuery(cQry, cTmp)


    If ! (cTmp)->(Eof())

        cFile := AllTrim((cTmp)->B1_BITMAP) + ".jpg"
   		If RepExtract(AllTrim((cTmp)->B1_BITMAP), cFile)

			If File(cFile)
				oFile := FwFileReader():New(cFile)
				if (oFile:Open())
					cData := ReadAllFile(oFile:nHandlen)  
					oFile:Close()
				endif
			Endif

			If Left(cData, 2) == Chr(66) + Chr(77) 
				cMime := "image/bmp"
			Endif

			If !Empty(rawimage)
				Self:SetContentType(cMime)
			EndIf
        EndIf
    EndIf


    (cTmp)->(DbCloseArea())

    Self:SetResponse(cData)

	oQry:Destroy()
	
	FwFreeObj( oQry )
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ReadAllFile(nHandle)
    Local cBuff := Space(2048)
    Local cData := ""
    Local nLido := 0

    While (nLido := FRead(nHandle, @cBuff, Len(cBuff))) > 0
        cData += Left(cBuff, nLido)
    EndDo
Return cData

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 29/01/2024
@Retorna dos dados do atendente amarrado pelo usuario do protheus
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD GET codUsrLogged WSRECEIVE userLogged WSREST FSMAPI

Local lRet      := .T.
Local cAliasTmp	:= GetNextAlias()
Local oResponse	:= JsonObject():New()
Local cQry 		:= ''
Local oQry      := Nil
Local cUsuario  := __cUserId

	If !Empty(Self:userLogged)
		cUsuario := Self:userLogged
	Endif	

	cQry := " SELECT AA1_CODTEC, AA1_SUPERV "
	cQry += " FROM "+RetSqlName("AA1")+"  AA1 "
	cQry += " WHERE AA1.D_E_L_E_T_ = ' ' "
	cQry += " AND AA1.AA1_FILIAL  = ? "
	cQry += " AND AA1_CODUSR = ? "	

	oQry := FwPreparedStatement():New(cQry)
	oQry:SetString(1, xFilial("AA1"))
	oQry:SetString(2, cUsuario)
	cQry := oQry:GetFixQuery()
	MPSysOpenQuery(cQry, cAliasTmp)

	oResponse['supervisor'] := (cAliasTmp)->AA1_SUPERV
	oResponse['codAtendente'] := (cAliasTmp)->AA1_CODTEC
		
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasTmp)->(dbCloseArea())

	oQry:Destroy()
	FwFreeObj( oQry )

Return lRet 

//-------------------------------------------------------------------
/*/{Fonte} - anexarDocs
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD POST anexarDocs WSREST FSMAPI

    Local oRequest     := JSonObject():New()
    Local oResponse    := JsonObject():New()
    Local cBody        := Self:GetContent()
    Local cFileName    := ''
    Local cFileContent := ''
    Local lFileSaved   := .F.

    oRequest:fromJson(cBody)

    cFileName 		:= oRequest['name']
    cFileContent 	:= oRequest['content']

	lFileSaved := salvarArquivo(cFileName, cFileContent)

	If lFileSaved
		oResponse['status'] 	:= 'Sucesso'
		oResponse['message'] 	:= EncodeUtf8('Arquivo anexado com sucesso')
		oResponse['data'] 		:= {}	

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

    oResponse := Nil
    oRequest := Nil

Return(.T.)

//-------------------------------------------------------------------
/*/{Fonte} - salvarArquivo
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
Static Function salvarArquivo(cFileName, cFileContent)

	Local aArea 	:= GetArea()
	Local cDirDocs 	:= ""
	Local lOk 		:= .F.
	Local oFile		:= Nil
	
	cDirDocs := MsDocPath()
	
    oFile := FwFileWriter():New(cDirDocs + "\" + cFileName ,.t.)

	If oFile:Create()
		oFile:Write(Decode64(cFileContent))
    EndIf	

	lOk := oFile:Exists()
	oFile:Close()
	FreeObj(oFile)

	RestArea(aArea)
	FwFreeArray(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Fonte} - deletarDocs
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD POST deletarDocs WSREST FSMAPI

    Local oResponse    	:= JsonObject():New()
    Local cBody        	:= Self:GetContent()
    Local cIdAnexo    	:= ''
    Local lExcluiu   	:= .F.

    oResponse:fromJson(cBody)

    cIdAnexo := oResponse['id']
    
	lExcluiu := excluirArquivo(cIdAnexo)

	If lExcluiu
		oResponse['status'] := 'Sucesso'
		oResponse['message'] := EncodeUtf8('Arquivo excluído com sucesso')
		oResponse['data'] := {}
	
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

    oResponse := Nil

Return(.T.)

//-------------------------------------------------------------------
/*/{Fonte} - excluirArquivo
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
Static Function excluirArquivo(cIdAnexo)

	Local aArea 	:= GetArea()
	Local lOk 		:= .F.
	
	AC9->(dbSetOrder(1))
	If lOk := AC9->(dbSeek(xFilial('AC9') + cIdAnexo))
		RecLock("AC9",.F.)
        	AC9->(dbDelete())
        AC9->(MsUnlock())
	EndIf

	If lOk
	
		ACB->(dbSetOrder(1))
		ACB->(dbSeek(xFilial('ACB') + cIdAnexo))
		RecLock("ACB",.F.)
			ACB->(dbDelete())
		ACB->(MsUnlock())
		
		ACC->(dbSetOrder(1))
		ACC->(dbSeek(xFilial('ACC') + cIdAnexo))
		RecLock("ACC",.F.)
			ACC->(dbDelete())
		ACC->(MsUnlock())
	
	EndIf
	
	RestArea(aArea)
	FwFreeArray(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Fonte} - baixarDocs
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET baixarDocs WSRECEIVE codObjeto, nomeObj WSREST FSMAPI

	Local cFile 		As Character
	Local cData			As Character
	Local lMsMultDir 	As Logical
    Local oJsonRet 		As Object

	lMsMultDir := MsMultDir()
    oJsonRet := JsonObject():New() 

	ACB->(dbSetOrder(1))
	If ACB->(dbSeek(xFilial('ACB') + Self:codObjeto))
	
		cFile := Alltrim(ACB->ACB_OBJETO)
		If lerArquivo(cFile, @cData)
			Self:SetContentType("application/octet-stream")
			Self:SetResponse(cData)
			Self:SetHeader("Content-Disposition", "attachment; filename=" + AllTrim(ACB->ACB_OBJETO))
		EndIf
	
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Fonte} - lerArquivo
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
Static Function lerArquivo(cFile, cData)

	Local oFile 	As Object
	Local cPathFile As Character
	Local lRet  	As Logical

	
	Default cFile 	:= ""
    Default cData 	:= ""
	
	cDirDocs := MsDocPath()

	cDirDocs  := MsDocRmvBar(cDirDocs)
    cPathFile := cDirDocs + "\" + cFile

	oFile := FwFileReader():New(cPathFile)

	If lRet := oFile:Open()
        cData := oFile:FullRead()
        oFile:Close()
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Fonte} - extraAnexar
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD POST extraAnexar WSREST FSMAPI

    Local oRequest     	:= JSonObject():New()
    Local oResponse    	:= JsonObject():New()
    Local cBody        	:= Self:GetContent()
    Local cCodProduto	:= ""
	Local cCodObjeto	:= ""
	Local cDescObjeto	:= ""
	Local cPalavraChave	:= ""
	Local ctabela 		:= ""

    oRequest:fromJson(cBody)

	cCodProduto		:= oRequest['codProduto']
	cCodObjeto		:= oRequest['codObjeto']
	cDescObjeto		:= oRequest['descObjeto']
	cPalavraChave	:= oRequest['palavraChave']
	ctabela			:= oRequest['tabela']

    gravarDados(cCodProduto,cCodObjeto,cDescObjeto,cPalavraChave,cTabela)
	
	oResponse['status'] 	:= 'Sucesso'
	oResponse['message'] 	:= EncodeUtf8('Arquivo anexado com sucesso')
	oResponse['data'] 		:= {}
    
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

    oResponse := Nil
    oRequest := Nil

Return(.T.)

//-------------------------------------------------------------------
/*/{Fonte} - gravarDados
@author Alexandre Takaki
@since 	19/08/2024
@Retorn 
@version 1.0
*/
//-------------------------------------------------------------------
Static Function gravarDados(cCodProduto,cCodObjeto,cDescObjeto,cPalavraChave,cTabela)

	Local aArea 	:= GetArea()
	
	Default cCodProduto		:= ""
	Default cCodObjeto		:= ""
	Default cDescObjeto		:= ""
	Default cPalavraChave	:= ""
	Default cTabela			:= ""

	If !Empty(cCodProduto) .And. !Empty(cCodObjeto) .And. !Empty(cDescObjeto) .And. !Empty(cTabela)
		
		DbSelectArea("AC9")	
		DbSelectArea("ACB")
		DbSelectArea("ACC")
		
		AC9->(RecLock("AC9",.T.))
			AC9->AC9_FILIAL	:= xFilial("AC9")
			AC9->AC9_FILENT	:= xFilial(cTabela)
			AC9->AC9_ENTIDA	:= cTabela
			AC9->AC9_CODENT	:= cCodProduto
			AC9->AC9_CODOBJ	:= cCodObjeto
		AC9->(MsUnlock())
		
		ACB->(RecLock("ACB",.T.))
			ACB->ACB_FILIAL	:= xFilial("ACB")
			ACB->ACB_CODOBJ	:= cCodObjeto
			ACB->ACB_OBJETO	:= cDescObjeto
			ACB->ACB_DESCRI	:= cDescObjeto
		ACB->(MsUnlock())
				
		ACC->(RecLock("ACC",.T.))
			ACC->ACC_FILIAL	:= xFilial("ACC")
			ACC->ACC_CODOBJ	:= cCodObjeto
			ACC->ACC_KEYWRD	:= cPalavraChave
		ACC->(MsUnlock())
		
		AC9->(DbCloseArea())		
		ACB->(DbCloseArea())
		ACC->(DbCloseArea())
	
	EndIf	
	
	RestArea(aArea)
	FwFreeArray(aArea)

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 06/09/2024
@Retorna usuários do checklist
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET usuarioChecklist WSRECEIVE page, pageSize, filter WSREST FSMAPI

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nUsuarios := 0

Default Self:page     := 1
Default Self:pageSize := 10

If Self:filter == Nil
	Self:filter := ''
Endif

cQuery := " SELECT DISTINCT USR_ID, USR_NOME FROM " + RetSqlName("JND") + " JND "
cQuery += " INNER JOIN SYS_USR USR ON USR_ID = JND.JND_USUINC "
cQuery += " AND USR.D_E_L_E_T_ = ' '"
cQuery += " WHERE JND_FILIAL = ?"
cQuery += " AND (USR_ID LIKE ? OR USR_NOME LIKE ?)"
cQuery += " AND JND.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY USR_ID "
cQuery += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("AA1"))
oQryTmp:SetString(2, '%'+Self:filter+'%')
oQryTmp:SetString(3, '%'+Self:filter+'%')
oQryTmp:SetNumeric(4, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(5, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nUsuarios++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nUsuarios]['codigo'] := AllTrim((cAliasTmp)->USR_ID)
	oResponse['items'][nUsuarios]['nome']  := AllTrim((cAliasTmp)->USR_NOME)

	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nUsuarios >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Alexandre Takaki
@since 10/09/2024
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET getAnexo WSRECEIVE codProduto WSREST FSMAPI

	Local lRet      := .T.
	Local cAliasTmp	:= GetNextAlias()
	Local oResponse	:= JsonObject():New()
	Local cQry 		:= ''
	Local oQry		:= Nil
	Local nItens 	:= 0

    cQry := " SELECT "
    cQry += "   AC9.AC9_CODENT, "
    cQry += "   ACB.ACB_CODOBJ, "
    cQry += "   ACB.ACB_OBJETO, "
    cQry += "   ACC.ACC_KEYWRD "
    cQry += " FROM "
    cQry += "   " + RetSqlName('AC9') + " AC9, "
    cQry += "   " + RetSqlName('ACB') + " ACB, "
    cQry += "   " + RetSqlName('ACC') + " ACC "
    cQry += " WHERE "
    cQry += "   AC9.AC9_FILIAL = ? "
    cQry += "   AND AC9.AC9_CODENT = ? "
    cQry += "   AND AC9.AC9_ENTIDA = 'SB1' "
    cQry += "   AND AC9.D_E_L_E_T_ = ' ' "
    cQry += "   AND ACB.ACB_FILIAL = AC9.AC9_FILIAL "
    cQry += "   AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ "
    cQry += "   AND ACB.D_E_L_E_T_ = ' ' "
    cQry += "   AND ACC.ACC_FILIAL = ACB.ACB_FILIAL "
    cQry += "   AND ACC.ACC_CODOBJ = ACB.ACB_CODOBJ "
    cQry += "   AND ACC.D_E_L_E_T_ = ' ' "

	oQry := FwPreparedStatement():New(cQry)

	oQry:SetString(1, xFilial("AC9"))
	oQry:SetString(2, Self:codProduto)

	cQry := oQry:GetFixQuery()
	MPSysOpenQuery(cQry, cAliasTmp)

    oResponse['itens'] := {}

	While (cAliasTmp)->(!Eof())

        nItens++
        Aadd(oResponse['itens'], JsonObject():New())
        oResponse['itens'][nItens]['codObjeto'] := AllTrim((cAliasTmp)->ACB_CODOBJ)
        oResponse['itens'][nItens]['descricaoObjeto'] := AllTrim((cAliasTmp)->ACB_OBJETO)
        oResponse['itens'][nItens]['palavraChave'] := AllTrim((cAliasTmp)->ACC_KEYWRD)

		(cAliasTmp)->(dbSkip())
    End

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasTmp)->(dbCloseArea())

	oQry:Destroy()
	FwFreeObj( oQry )

Return lRet 

WSMETHOD POST createForm  WSREST FSMAPI
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgRet	   := ''
Local cCodigo      := ''
Local cCodRet      := ''

oRequest:fromJson(cBody)

cCodigo := oRequest['codigo']

lRet := FSMX001(cCodigo, @cMsgRet, @cCodRet)

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Formulário de checklist criado')
	oResponse['data'] := {}
			
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['codigo'] := cCodRet

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(@cMsgRet))
Endif

oResponse := Nil
oRequest :=  Nil

Return lRet

WSMETHOD POST checklistOS WSREST FSMAPI
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgRet	   := ''
Local cCodOrdem    := ''
Local cCodAtend    := ''
Local aCodRet      := {}

oRequest:fromJson(cBody)

cCodOrdem := oRequest['codigoOrdem']
cCodAtend := oRequest['codigoAtendente']

lRet := FSMX002(cCodOrdem, cCodAtend, @cMsgRet, @aCodRet)

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Formulário de checklist criado')
	oResponse['data'] := {}
			
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['codigo'] := aCodRet

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(@cMsgRet))
Endif

oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} parametros
Retorna a lista de parâmetros do SIGAFSM

@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET parametros WSRECEIVE WSREST FSMAPI
Local oResponse		:= JsonObject():New()
Local lRet      	:= .T.
Local cQuery  		:= ''
Local oQryTmp 		:= Nil
Local cAliasTmp 	:= Nil
Local nParametro	:= 0

lRet := FsmUpdPar()

If lRet 

	cQuery := " SELECT JNU_CODPAR, JNU_TIPO, JNU_DESCRI, "
	cQuery += "   JNU_OBSERV, JNU_CONTEU FROM " + RetSqlName("JNU") 
	cQuery += " WHERE JNU_FILIAL = ?"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY JNU_CODPAR "

	oQryTmp := FwPreparedStatement():New(cQuery)

	oQryTmp:SetString(1, xFilial("JNU"))

	cQuery    := oQryTmp:GetFixQuery()
	cAliasTmp := MpSysOpenQuery(cQuery)

	oResponse['items'] := {}

	While !(cAliasTmp)->(Eof())

		nParametro++

		Aadd(oResponse['items'], JsonObject():New())

		oResponse['items'][nParametro]['parametro'] := AllTrim((cAliasTmp)->JNU_CODPAR)
		oResponse['items'][nParametro]['tipo']  	:= AllTrim((cAliasTmp)->JNU_TIPO)
		oResponse['items'][nParametro]['descricao']	:= AllTrim((cAliasTmp)->JNU_DESCRI)
		oResponse['items'][nParametro]['conteudo']  := AllTrim((cAliasTmp)->JNU_CONTEU)

		(cAliasTmp)->(dbSkip())

	EndDo

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasTmp)->(dbCloseArea())

Endif

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 15/10/2024
@Retorna ordem servico da base de atendimento
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET ordemServicoBase WSRECEIVE page, pageSize, codigoBase, idUnico WSREST FSMAPI

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nOrdens   := 0

Default Self:page     := 1
Default Self:pageSize := 10

If Self:codigoBase == Nil
	Self:codigoBase := ''
Endif

cQuery := " SELECT JN3_CODIGO, JN3_DESCRI, JN3_DTINCL FROM " + RetSqlName("JN3") 
cQuery += " WHERE JN3_FILIAL = ?"
cQuery += " AND JN3_CODPRO = ?"
cQuery += " AND JN3_NUMSER = ?"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY JN3_CODIGO DESC"
cQuery += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JN3"))
oQryTmp:SetString(2, Self:codigoBase)
oQryTmp:SetString(3, Self:idUnico)
oQryTmp:SetNumeric(4, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(5, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nOrdens++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nOrdens]['codigo'] := AllTrim((cAliasTmp)->JN3_CODIGO)
	oResponse['items'][nOrdens]['descricao']  := AllTrim((cAliasTmp)->JN3_DESCRI)

	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nOrdens >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author julia.marcela
@since 12/12/2024
@Retorna as informacoes sobre o CEP consultado
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET consultaCEP WSRECEIVE cep WSREST FSMAPI

    Local oRest     := FWRest():New("https://viacep.com.br")
    Local oJson     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cCep      := self:cep
    Local cResult   := ""
    Local cError    := ""
    Local cJson     := ""

    oRest:setPath("/ws/" + cCep + "/json/")

    If oRest:Get()
        cResult := oRest:GetResult()
        cJson := oJson:FromJson(cResult)

        oResponse['Info'] := {}
        Aadd(oResponse['Info'], JsonObject():New())

            If !Empty(oJson:GetJsonObject('cep'))
                oResponse['Info'][1]['cep'] := oJson:GetJsonObject('cep')
            EndIf

            If !Empty(oJson:GetJsonObject('logradouro'))
                oResponse['Info'][1]['logradouro'] := oJson:GetJsonObject('logradouro')
            EndIf

            If !Empty(oJson:GetJsonObject('complemento'))
                oResponse['Info'][1]['complemento'] := oJson:GetJsonObject('complemento')
            EndIf

            If !Empty(oJson:GetJsonObject('bairro'))
                oResponse['Info'][1]['bairro'] := oJson:GetJsonObject('bairro')
            EndIf

            If !Empty(oJson:GetJsonObject('localidade'))
                oResponse['Info'][1]['localidade'] := oJson:GetJsonObject('localidade')
            EndIf

            If !Empty(oJson:GetJsonObject('uf'))
                oResponse['Info'][1]['uf'] := oJson:GetJsonObject('uf')
            EndIf

            If !Empty(oJson:GetJsonObject('ibge'))
                oResponse['Info'][1]['ibge'] := oJson:GetJsonObject('ibge')
            EndIf

            If !Empty(oJson:GetJsonObject('gia'))
                oResponse['Info'][1]['gia'] := oJson:GetJsonObject('gia')
            EndIf

            If !Empty(oJson:GetJsonObject('ddd'))
                oResponse['Info'][1]['ddd'] := oJson:GetJsonObject('ddd')
            EndIf

            If !Empty(oJson:GetJsonObject('siafi'))
                oResponse['Info'][1]['siafi'] := oJson:GetJsonObject('siafi')
            EndIf

    Else
        cError := oRest:GetLastError()

        oResponse['Error'] := {}
        Aadd(oResponse['Error'], JsonObject():New())

        oResponse['Error'][1]['Mensagem'] := "Erro ao consultar CEP: " + cError

    EndIf

    self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return .T.

WSMETHOD GET userAtendente WSRECEIVE page, pageSize, filter, idUser WSREST FSMAPI
Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nUsuarios := 0

Default Self:page     := 1
Default Self:pageSize := 10

If Self:filter == Nil
	Self:filter := ''
Endif

If Self:idUser != Nil 
	Self:filter := ''

Endif

cQuery := " SELECT USR_ID, USR_CODIGO, USR_NOME, AA1_CODTEC FROM SYS_USR USR "
cQuery += " LEFT JOIN " + RetSqlName('AA1') + " AA1 ON AA1_CODUSR = USR.USR_ID "
cQuery += " AND AA1_FILIAL = ? "
cQuery += " AND AA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " USR.D_E_L_E_T_ = ' ' "
cQuery += " AND USR.USR_MSBLQL = '2' "

If (Self:idUser != '' .And. Self:idUser != Nil)
	cQuery += " AND USR_ID = ? "
Else
	cQuery += " AND (USR_ID LIKE ? OR USR_NOME LIKE ?)"
Endif

cQuery += " ORDER BY USR_ID "
cQuery += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("AA1"))

If (Self:idUser != '' .And. Self:idUser != Nil)
	oQryTmp:SetString(2, Self:idUser) 
	oQryTmp:SetNumeric(3, (Self:page -1) * Self:pageSize) 
	oQryTmp:SetNumeric(4, Self:pageSize) 
Else
	oQryTmp:SetString(2, '%'+Self:filter+'%')
	oQryTmp:SetString(3, '%'+Self:filter+'%')
	oQryTmp:SetNumeric(4, (Self:page -1) * Self:pageSize) 
	oQryTmp:SetNumeric(5, Self:pageSize) 
Endif 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nUsuarios++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nUsuarios]['id'] := AllTrim((cAliasTmp)->USR_ID)
	oResponse['items'][nUsuarios]['codigo'] := AllTrim((cAliasTmp)->USR_CODIGO)
	oResponse['items'][nUsuarios]['nome']  := AllTrim((cAliasTmp)->USR_NOME)
	oResponse['items'][nUsuarios]['atendenteVinculado']  := AllTrim((cAliasTmp)->AA1_CODTEC)


	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nUsuarios >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDataBase
Retorna a database do servidor Protheus

@author flavio.martins
@since 14/03/2025
@version 1.0
*/*/
//-------------------------------------------------------------------
WSMETHOD GET dataBaseProtheus WSRECEIVE WSREST FSMAPI
Local oResponse	:= JsonObject():New()
   
	oResponse['dataBase'] := DtoS(dDataBase)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 15/10/2024
@Retorna ordem servico da base de atendimento
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET historicoAponta WSRECEIVE codigoCliente, lojaCliente, codigoBase, idUnico WSREST FSMAPI

Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cQuery  	:= ''
Local oQryTmp 	:= Nil
Local cAliasTmp := Nil
Local nItems    := 0

Default Self:page     		:= 1
Default Self:pageSize 		:= 10
Default Self:codigoCliente 	:= ''
Default Self:lojaCliente 	:= ''
Default Self:codigoBase 	:= ''
Default Self:idUnico 		:= ''

cQuery := " SELECT "
cQuery += "   JO4.JO4_TPAPON, "
cQuery += "   JO4.JO4_CODPRO, "
cQuery += "   JO4.JO4_NSEPRO, "
cQuery += "   JO4.JO4_QTDPRO, "
cQuery += "   JO4.JO4_DTINST, "
cQuery += "   JO4.JO4_DTGARA, "
cQuery += "   JO4.JO4_STATUS, "
cQuery += "   JO4.JO4_DTAPON, "
cQuery += "   JO4.JO4_HRAPON, "
cQuery += "   SB1.B1_DESC, "
cQuery += "   AA1.AA1_CODTEC, "
cQuery += "   AA1.AA1_NOMTEC "
cQuery += " FROM " + RetSqlName("JN3") + " JN3 "
cQuery += "   INNER JOIN " + RetSqlName("JO4") + " JO4 ON JO4.JO4_FILIAL = ? "
cQuery += "   AND JO4.JO4_CODJN3 = JN3.JN3_CODIGO "
cQuery += "   AND JO4.JO4_CODAA3 = ? "
cQuery += "   AND JO4.JO4_NUMSER = ? "
cQuery += "   AND JO4.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = ? "
cQuery += "   AND SB1.B1_COD = JO4.JO4_CODPRO "
cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName("JN6") + " JN6 ON JN6.JN6_FILIAL = ? "
cQuery += "   AND JN6.JN6_CODIGO = JO4.JO4_CODJN6 "
cQuery += "   AND JN6.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName("AA1") + " AA1 ON AA1.AA1_FILIAL = ? "
cQuery += "   AND AA1.AA1_CODTEC = JN6.JN6_CODAA1 "
cQuery += "   AND AA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   JN3.JN3_FILIAL = ? "
cQuery += "   AND JN3.JN3_CLIENT = ? "
cQuery += "   AND JN3.JN3_LOJA = ? "
cQuery += "   AND JN3.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY JO4.JO4_DTINST DESC "
cQuery += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JO4"))
oQryTmp:SetString(2, Self:codigoBase)
oQryTmp:SetString(3, Self:idUnico)
oQryTmp:SetString(4, xFilial("SB1"))
oQryTmp:SetString(5, xFilial("JN6"))
oQryTmp:SetString(6, xFilial("AA1"))
oQryTmp:SetString(7, xFilial("JN3"))
oQryTmp:SetString(8, Self:codigoCliente)
oQryTmp:SetString(9, Self:lojaCliente)
oQryTmp:SetNumeric(10, (Self:page -1) * Self:pageSize) 
oQryTmp:SetNumeric(11, Self:pageSize) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	oResponse['items'][nItems]['tipoApontamento'] 	:= AllTrim((cAliasTmp)->JO4_TPAPON)
	oResponse['items'][nItems]['status']  			:= AllTrim((cAliasTmp)->JO4_STATUS)
	oResponse['items'][nItems]['codigoProduto']  	:= AllTrim((cAliasTmp)->JO4_CODPRO)
	oResponse['items'][nItems]['descricaoProduto'] 	:= AllTrim((cAliasTmp)->B1_DESC)
	oResponse['items'][nItems]['idUnico']  			:= AllTrim((cAliasTmp)->JO4_NSEPRO)
	oResponse['items'][nItems]['quantidade'] 		:= AllTrim(Str((cAliasTmp)->JO4_QTDPRO))
	oResponse['items'][nItems]['dataInstalacao'] 	:= AllTrim((cAliasTmp)->JO4_DTINST)
	oResponse['items'][nItems]['dataGarantia'] 		:= AllTrim((cAliasTmp)->JO4_DTGARA)
	oResponse['items'][nItems]['dataApontamento']	:= AllTrim((cAliasTmp)->JO4_DTAPON)
	oResponse['items'][nItems]['horaApontamento']  	:= AllTrim((cAliasTmp)->JO4_HRAPON)
	oResponse['items'][nItems]['codigoAtendente']  	:= AllTrim((cAliasTmp)->AA1_CODTEC)
	oResponse['items'][nItems]['nomeAtendente']  	:= AllTrim((cAliasTmp)->AA1_NOMTEC)
	
	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nItems >= Self:pageSize)

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

(cAliasTmp)->(dbCloseArea())

Return lRet 

WSMETHOD POST processEventsUpdate WSREST FSMAPI
Local lRet         := .T.
Local oResponse	   := JsonObject():New()

FSMCriaJNK()

oResponse['status'] := 'success'
oResponse['message'] := EncodeUtf8('Atualização de eventos concluída')

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

oResponse := Nil

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 10/09/2025
@Retorna se tem a quantidade solicitada x disponivel no endereço
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD POST quantEndereco WSREST FSMAPI

    Local oEst      := FSM_ESTO():New()
    Local lRet      := .F.
    Local oRequest  := JsonObject():New()
    Local oResponse := JsonObject():New()
	Local nX := 0
	Local cMessage  := 'Quantidade válida para o endereço informado.'

	oRequest:fromJson(Self:GetContent())

	For nX := 1 To Len(oRequest)

		If oRequest[nX]['tipo'] == '1'

			lRet := oEst:QuantEnd( ;
				oRequest[nX]['produto'], ;
				oRequest[nX]['armazemOrigem'], ;
				oRequest[nX]['enderecoOrigem'], ;
				oRequest[nX]['quantidade'] )
		Else

			lRet := oEst:QuantEnd( ;
				oRequest[nX]['produto'], ;
				oRequest[nX]['armazemOrigem'], ;
				oRequest[nX]['enderecoOrigem'], ;
				oRequest[nX]['quantidade'] )
		Endif	

		If !lRet
			cMessage := 'Quantidade inválida ou não localizada no endereço.'
			Exit
		Endif	

	Next

	oResponse["success"]  := lRet
    oResponse["message"]  := EncodeUTF8(cMessage)

    Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

    oRequest  := Nil
	oResponse := Nil

Return lRet

