#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "TBICONN.CH"
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1124  บAutor  ณVendas Clientes     บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Job Replicacao de Dados entre os Ambientes                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA1124(cEmpTrb, cFilTrb)
	Local oRplDados					//Replicacao de Dados

	DEFAULT cEmpTrb := ""			//Empresa de Trabalho
	DEFAULT cFilTrb := ""			//Filial de Trabalho
	
	oRplDados := LJCRplDados():New(cEmpTrb, cFilTrb)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณ LJCRplDados  บAutor  ณVendas Clientes บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravacao dos Dados de Entrada                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCRplDados
	Data lPrepEnv					//Determina se Prepara o Ambiente
	Data cEmpTrb					//Empresa de Trabalho
	Data cFilTrb					//Filial de Trabalho

	Method New(cEmpTrb, cFilTrb)	//Instancia o Objeto
 	Method PrepEnv()				//Prepara o Environment
	Method ReplicaDados()				//Faz a Replicacao dos Dados
	Method ClearEnv() 				//Fecha o Environment
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ New      บAutor  ณVendas Clientes     บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Instancia o Objeto                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(cEmpTrb, cFilTrb) Class LJCRplDados
	DEFAULT cEmpTrb	:= ""					//Empresa para processamento
	DEFAULT cFilTrb	:= ""					//Filial para processamento

	::cEmpTrb	:= cEmpTrb
	::cFilTrb	:= cFilTrb
	::lPrepEnv	:= !Empty(cEmpTrb) .AND. !Empty(cFilTrb)
	
	::PrepEnv()

	::ReplicaDados()

	::ClearEnv()
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ PrepEnv  บAutor  ณVendas Clientes     บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara o Environment                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepEnv() Class LJCRplDados
	If ::lPrepEnv
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ::cEmpTrb FILIAL ::cFilTrb TABLES "MD6", "MD7", "MD8" MODULO "LOJA"
	EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณReplicaDadosบAutor  ณVendas Clientes   บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a Replicacao dos Dados                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ReplicaDados() Class LJCRplDados
	Local aDados		:= {}										//Dados para Processamento

	Local cAmbiente		:= SuperGetMV("MV_LJAMBIE", NIL, "")		//Ambiente Atual
	Local cProcesso		:= ""										//Processo de Replicacao
	Local cQuery		:= ""										//Consulta Ambiente x Processos
	Local cOrigem		:= ""										//Origem da Transacao
	Local cTransacao	:= ""										//Guarda o Numero da Transacao
	
	Local nI			:= 0										//Contador
	Local nJ			:= 0										//Contador
	Local nK			:= 0

	Local lMatOff		:= SuperGetMV("MV_LJMATOF", NIL, .F.) 		//Determina se o Ambiente e Matriz

	Local oESaixAmb		:= NIL										//Entidade Saida x Ambientes
	Local oESaida		:= NIL										//Entidade Saida
	Local oEEntrada		:= NIL										//Entidade Entrada
	Local oDEntrada		:= NIL										//Dados da Entidade Entrada

	Local oTrans		:= NIL										//Controle do Numero da Transacao
	Local oGrafo		:= NIL										//Controle da Replicacao

	Local cMD5Proces 	:= ""										//Campo MD5_PROCES
	Local cMD5AmbDes 	:= ""										//Campo MD5_AMBDES

	Local cMD8Trans		:= ""        	          					//Campo MD8_TRANS
	Local cMD8Origem	:= ""        	          					//Campo MD8_ORIGEM	
	
	
	//Executa somente em Ambiente TOP
	#IFDEF TOP
		//Seleciona os dados para Replicacao
		cQuery := "SELECT MD8.MD8_TRANS, "
		cQuery += "       MD8.MD8_ORIGEM, "
		cQuery += "       MD8.MD8_PROCES, "
		cQuery += "       MD5.MD5_AMBDES "
		//cQuery += "FROM   MD8010 MD8, "
		//cQuery += "       MD5010 MD5 "
		cQuery += "FROM "
		cQuery += RetSqlName("MD8") + " MD8, "
		cQuery += RetSqlName("MD5") + " MD5 "	
		cQuery += "WHERE  MD8.MD8_STATUS = '2' "
		cQuery += "  AND MD5_AMBORI = '" + cAmbiente + "' "
		cQuery += "  AND MD5_AMBDES <> MD8_ORIGEM "
		cQuery += "  AND MD5_PROCES = MD8_PROCES "
		cQuery += "  AND MD5.D_E_L_E_T_ = '' "
		cQuery += "  AND MD8.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY MD8_TRANS, MD8_PROCES, MD8_STATUS, MD8_ORIGEM, MD5_AMBDES "
		cQuery += "ORDER BY MD8_TRANS, MD8_PROCES, MD8_STATUS, MD8_ORIGEM, MD5_AMBDES "
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea(.T., "TopConn", TCGenQry(NIL, NIL, cQuery), "TRBREP", .F., .F.)
		
		//Monta Array de Trabalho
		While !TRBREP->(Eof())
			nPosTrans := aScan(aDados, {|x| x[1] + x[2] + x[3] == TRBREP->MD8_TRANS + TRBREP->MD8_PROCES + TRBREP->MD8_ORIGEM })
			If nPosTrans > 0
				Aadd(aDados[nPosTrans][4],	TRBREP->MD5_AMBDES )
			Else
				Aadd(aDados, {TRBREP->MD8_TRANS, TRBREP->MD8_PROCES, TRBREP->MD8_ORIGEM, {TRBREP->MD5_AMBDES}})
			EndIf
			TRBREP->(DbSkip())
		End

		If Select("TRBREP") > 0
			TRBREP->(DbCloseArea())
		EndIf
	#ELSE
		DbSelectArea("MD5")         

		cMD5Proces 	:=	Space(TamSx3("MD5_PROCES")[1])
		cMD5AmbDes 	:=	Space(TamSx3("MD5_AMBDES")[1])

		MD5->(DbSetOrder(1))		//MD5_AMBORI+MD5_PROCES+MD5_AMBDES
		MD5->(DbSeek(xFilial("MD5") + cAmbiente + cMD5Proces + cMD5AmbDes))

		While MD5->(!Eof())         
			DbSelectArea("MD8")                                    
			
			cMD8Trans	:= Replicate("0",TamSX3("MD8_TRANS")[1])	
			cMD8Origem	:= Replicate("0",TamSX3("MD8_ORIGEM")[1])				
					
			MD8->(DbSetOrder(3)) //MD8_TRANS + MD8_PROCES + MD8_STATUS + MD8_ORIGEM
            MD8(DbSeek(xFilial("MD8") + cMD8Trans + MD5->MD5_PROCES + "2" + cMD8Origem))
            
			While MD8->(Eof()) .AND. !(nPosTrans > 0) .AND. (MD5->MD5_AMBDES <> MD8->MD8_ORIGEM)
				nPosTrans := aScan(aDados, {|x| x[1] + x[2] + x[3] == MD8->MD8_TRANS + MD8->MD8_PROCES + MD8->MD8_ORIGEM })
				If nPosTrans > 0                       
					Aadd(aDados[nPosTrans][4],	MD5->MD5_AMBDES )
				Else
					Aadd(aDados, {MD8->MD8_TRANS, MD8->MD8_PROCES, MD8->MD8_ORIGEM, {MD8->MD5_AMBDES}})
					MD8->(DbSkip())
				EndIf					        				
			End
			                                    
			MD5->(DbSkip())
		End	
	#ENDIF

		//Processamento das Transacoes
		For nI := 1 to Len(aDados)
			//Instancia o Objeto que controla o Numero das Transacoes
			oTrans := LJCGetTrans():New("MD6")

			//Recupera a Transacao da Tabela de Saida
			oTrans:SetTrans()

			//Trava a Transacao
			oTrans:LockTrans()

			//Guarda a Transacao de Origem
			cTransacao	:= aDados[nI][1]

			//Guarda o Processo de Origem
			cProcesso	:= aDados[nI][2]
			
			//Guarda o Ambiente de Origem
			cOrigem		:= aDados[nI][3]

			//Mapeia a Replicacao do Processo
			oGrafo := LJCGrafo():New(cProcesso, Val(cOrigem))
			
			Begin Transaction
				Begin Sequence
					//Replica para os Ambientes de Destino
					For nJ := 1 to Len(aDados[nI][4])
						//Verifica se o Ambiente para Replicacao selecionado na Query,
						//nao esta no caminho percorrido ate o Ambiente atual
						If !oGrafo:TemCaminho(Val(aDados[nI][4][nJ]), Val(cOrigem))
							//Instancia a Entidade Saida x Ambientes
							oESaixAmb := LJCEntSaidaAmb():New()
							
							//Prepara os Dados para Gravacao
							oESaixAmb:DadosSet("MD7_TRANS"	,oTrans:GetTrans())
							oESaixAmb:DadosSet("MD7_DEST"	,aDados[nI][4][nJ])
							oESaixAmb:DadosSet("MD7_STATUS", "1")

							//Insere o Registro na Tabela Saida x Ambientes
							oESaixAmb:Incluir()
						EndIf
					Next nJ
					
					//Se nao for Ambiente Matriz, insere registro para o proprio Ambiente
					If !lMatOff
						//Verifica se os registros foram enviados de um nivel superior
						If !oGrafo:TemCaminho(Val(cOrigem), Val(cAmbiente))
							//Instancia a Entidade Saida x Ambientes
							oESaixAmb := LJCEntSaidaAmb():New()

							//Prepara os Dados para Gravacao
							oESaixAmb:DadosSet("MD7_TRANS"	,oTrans:GetTrans())
							oESaixAmb:DadosSet("MD7_DEST"	,cAmbiente)
							oESaixAmb:DadosSet("MD7_STATUS", "1")
							
							//Insere o Registro na Tabela Saida x Ambientes
							oESaixAmb:Incluir()
						EndIf
					EndIf

					//Consulta a Transacao na Entidade Entrada
					oEEntrada := LJCEntEntrada():New()

					//Passa os dados para Consulta
					oEEntrada:DadosSet("MD8_TRANS", cTransacao)

					//Consulta os Dados
					oDEntrada := oEEntrada:Consultar(1)		//MD8_TRANS, MD8_REG, MD8_SEQ

					//Grava a Tabela de Saida com os dados da Tabela de Entrada
					For nK := 1 to oDEntrada:Count()
						
						//Instancia a Entidade Saida
						oESaida := LJCEntSaida():New()

						//Passa os dados para Gravacao
						oESaida:DadosSet("MD6_TRANS"	,oTrans:GetTrans())
						oESaida:DadosSet("MD6_REG"		,oDEntrada:Elements(nK):DadosGet("MD8_REG"))
						oESaida:DadosSet("MD6_SEQ"		,oDEntrada:Elements(nK):DadosGet("MD8_SEQ"))
						oESaida:DadosSet("MD6_TPCPO"	,oDEntrada:Elements(nK):DadosGet("MD8_TPCPO"))
						oESaida:DadosSet("MD6_NOME"		,oDEntrada:Elements(nK):DadosGet("MD8_NOME"))
						oESaida:DadosSet("MD6_VALOR"	,oDEntrada:Elements(nK):DadosGet("MD8_VALOR"))
						oESaida:DadosSet("MD6_TIPO"		,oDEntrada:Elements(nK):DadosGet("MD8_TIPO"))
						oESaida:DadosSet("MD6_ORIGEM"	,oDEntrada:Elements(nK):DadosGet("MD8_ORIGEM"))
						oESaida:DadosSet("MD6_SERVWB"	,oDEntrada:Elements(nK):DadosGet("MD8_SERVWB"))
						oESaida:DadosSet("MD6_MODULO"	,oDEntrada:Elements(nK):DadosGet("MD8_MODULO"))
						oESaida:DadosSet("MD6_STATUS"	,"1")
						oESaida:DadosSet("MD6_SITPRO"	,"1")
						oESaida:DadosSet("MD6_PROCES"	,oDEntrada:Elements(nK):DadosGet("MD8_PROCES"))
						oESaida:DadosSet("MD6_DATA"		,DToC(dDataBase))

						//Insere o Registro na Tabela de Saida
						oESaida:Incluir()
					Next nK
					
					//Instancia a Entidade Entrada
					oEEntrada := LJCEntEntrada():New()

					//Passa os dados para Gravacao
					oEEntrada:DadosSet("MD8_TRANS", cTransacao)
					oEEntrada:DadosSet("MD8_STATUS", "4")
					oEEntrada:DadosSet("MD8_SITPRO", "4")
					
					oEEntrada:Alterar(1)	//MD8_TRANS, MD8_REG, MD8_SEQ

				Recover
					ConOut("LOJA1124 - 01 - " + Time() + " - " + "Erro na Replicacao da Transacao " + cTransacao + " da Tabela de Entrada.")
					DisarmTransaction()
				End Sequence
			End Transaction
			//Libera a Reserva da Transacao
			oTrans:FreeTrans()
		Next nI
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ ClearEnv บAutor  ณVendas Clientes     บ Data ณ  14/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fecha o Environment                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ClearEnv() Class LJCRplDados
	If ::lPrepEnv
		RESET ENVIRONMENT
	EndIf
Return NIL
