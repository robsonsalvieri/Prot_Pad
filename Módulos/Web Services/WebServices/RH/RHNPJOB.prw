#INCLUDE "TOTVS.CH"

/*/
{Protheus.doc} RHNPLIBJOB
- Relaçao de funcoes do Meu RH que poderão ser executadas via JOB quando é necessário obter dados de outro grupo;
/*/

/*/
{Protheus.doc} GetDataOrJob
- Executa a função normal, ou via job quando a solicitação é para outro grupo
@author:	Marcelo Silveira
@since:		03/08/2020
@param:		cRotina - Código que indica qual rotina será executada;
			aParams - Parametros que serão passados para a rotina que será executada;			
			cEmpToReq - Empresa para verificar se a execução será via Job;
@return:	uRet - Retorno conforme a função que está sendo executada

----------------------------------------------------------
Premissas para que uma função possa ser executada via Job

Uma função qualquer que está sendo executada via Job:

	1. Deverá receber 3 parâmetros adicionais: 
		- Código do Grupo onde a função deve ser executada
		- Variável lógica para indicar a execução via JOB
		- Nome da variável pública de controle 

	2. Na execução via Job deverá setar a conexão e o ambiente do grupo (3 para não consumir licenças)
		RPCSetType( 3 )
		RPCSetEnv( CEMPRESA, CFILIAL ) //Empresa e Filial para preparação do ambiente
	
	3. Antes do retorno da função a variável de controle deverá ser alimentada com valor "1" para indicar o término do Job
		PutGlbValue(cUID, "1")

Exemplo de uso: GetPeriodApont()
----------------------------------------------------------
/*/
Function GetDataForJob( cRotina, aParams, cEmpToReq, cEmpAtual)

Local uRet							//Retorno da função
Local cNewPar01		:= Nil
Local cUID			:= ""			//Nome da variavel de controle na execução via Job
Local nCount		:= 0			//Contador para controlar o limite para finalização do Job
Local nTime			:= 1000			//Indica quantos segundos o sistema irá aguardar a cada incremento do contador (default 1 segundo) 
Local lNumPar 		:= .F.			//Valida o número de parametros que a função executada deve ter
Local lExecJob		:= .F.			//Indica que a execução será feita via Job

DEFAULT cEmpAtual	:= cEmpAnt	
DEFAULT cRotina 	:= ""
DEFAULT aParams		:= {}
DEFAULT cEmpToReq	:= cEmpAnt

	lExecJob := !(cEmpToReq == cEmpAtual) //Define a execução via Job quando a requisição é para outro grupo

	DO CASE 
		Case cRotina == "1" // Retorna os periodos de apontamento

			//Valida a quantidade de parametros esperados pela rotina => GetPeriodApont
			lNumPar := Len(aParams) >= 3

			//Variavel para tratar novos parametros acionados na rotina
			cNewPar01 := If( Len(aParams) > 3, aParams[4], cNewPar01 )

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_PERAPO_" + AllTrim( Str(ThreadID()) )
				
				//Atribui a variavel de controle				
				PutGlbValue(cUID,"0")
				
				//Define a criação e o retorno do Job				
				uRet := StartJob( "GetPeriodApont", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], cNewPar01, cEmpToReq, .T., cUID )
			Else
				uRet := GetPeriodApont(aParams[1], aParams[2], aParams[3], cNewPar01 )
			EndIf

		Case cRotina == "2" // Realiza a reprovacao de uma batida que foi incluida por geolocalizao

			//Valida a quantidade de parametros esperados pela rotina => fUpdGeoClock
			lNumPar := Len(aParams) == 4

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHU_GEOUPD_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fUpdGeoClock", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], cEmpToReq, .T., cUID )
			Else
				uRet := fUpdGeoClock( aParams[1], aParams[2], aParams[3], aParams[4] )
			EndIf

		Case cRotina == "3" // Retorna as marcações do funcionario

			lNumPar := Len(aParams) >= 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_GETCLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "getClockings", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID, aParams[6] )
			EndIf

		Case cRotina == "4" // Retorna os saldos de horas do período do colaborador

			lNumPar := Len(aParams) == 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_GETBALANCE_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fMyBalance", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID )
			Else
				uRet := fMyBalance(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5])
			EndIf

		Case cRotina == "5" // Retorna o arquivo do espelho de ponto

			lNumPar := Len(aParams) == 7

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FILECLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "FileClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], .T., cUID )
			EndIf

		Case cRotina == "6" // Inclusão de batidas do ponto eletronico (POST)

			lNumPar := Len(aParams) == 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHPO_CLOCKING_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fSetClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID )
			EndIf

		Case cRotina == "7" // Alteração de batidas do ponto eletronico (PUT)

			lNumPar := Len(aParams) == 6

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHPU_CLOCKING_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fEditClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "8" // Retorna o arquivo do informe de rendimentos

			lNumPar := Len(aParams) >= 6

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FIRPF_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetFileAnnualRec", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "9" // Retorna o Join do campo Filial de duas tabelas para uso em queryes 

			lNumPar := Len(aParams) == 4

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FWJOIN_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "getJoinFilial", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := getJoinFilial(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "10" // Retorna os processos da tabela RCJ
			lNumPar := Len(aParams) >= 3
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_PROCESS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fProcess", GetEnvServer(), .T., aParams, .T., cUID )
			EndIf
		Case cRotina == "11" // Retorna os centros de custo
			lNumPar := Len(aParams) >= 3
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_COSTCENTER_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fCostCenter", GetEnvServer(), .T., aParams, .T., cUID )
			EndIf
		Case cRotina == "12" // Retorna os departamentos.
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_DEPTOS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetDepto", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			EndIf
		Case cRotina == "13" // Retorna os motivos de inclusão de batida de ponto. 

			lNumPar := Len(aParams) == 3

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TYPECLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetClockType", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := fGetClockType(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "14" // Retorna os motivos de inclusão de batida de ponto. 

			lNumPar := Len(aParams) == 2

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TYPEALLOWANCES_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "GetAllowances", GetEnvServer(), .T., aParams[1], aParams[2], .T., cUID )
			Else
				uRet := GetAllowances(aParams[1], aParams[2])
			EndIf
		Case cRotina == "15" // Retorna objeto com dados do funcionário no formato employeesRequisitions.

			lNumPar := Len(aParams) == 3

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TRANSFDETAIL_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetReqEmp", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := fGetReqEmp(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "16" // Ocorrências de férias/afastamentos/feriados no espelho de ponto do funcionário.
			lNumPar := Len(aParams) >= 4
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_OCCASIONALDAYS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fMontaOcc", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "17" // Funções
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_JOBFUNC_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fJobFunc", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := fJobFunc(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)
			EndIf
		Case cRotina == "18" // Cargos
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_JOBROLES_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fJobRoles", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := fJobRoles(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)
			EndIf
		Case cRotina == "19" // Extrato do banco de horas
			lNumPar := Len(aParams) == 5
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_EXTRACT_BH_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				// Define se vai chamar o RDMAKE.
				uRet := StartJob("fProcExtBh", GetEnvServer(), .T., { aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID })
			Else
				uRet := fProcExtBh( { aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL })
			EndIf
		Case cRotina == "20" // Extrato do banco de horas
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_MYSCHEDULE_" + AllTrim(Str(ThreadID()))

				//Atribui a variavel de controle
				PutGlbValue(cUID, "0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetMySchedule", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := fGetMySchedule(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)
			EndIf
		Case cRotina == "21" // Ocorrências do ponto
			lNumPar := Len(aParams) >= 7
			If lExecJob .And. lNumPar
				cUID := "MRHG_DELAYANDABSENSCES_" + AllTrim(Str(ThreadID()))

				//Atribui a variavel de controle
				PutGlbValue(cUID, "0")

				uRet := StartJob( "fQryOccurs()", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], .T., cUID )
			Else
				uRet := fQryOccurs(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], .F., NIL)
			EndIf
		Case cRotina == "22" // Push Notifications
			lNumPar := Len(aParams) >= 4 .And. Len(aParams[1]) > 0
			If lExecJob .And. lNumPar .And. !( aParams[1,8] == "4" )
				cUID := "MRHG_PUSHNOT_" + AllTrim(Str(ThreadID()))

				//Atribui a variavel de controle
				PutGlbValue(cUID, "0")
				uRet := StartJob("MrhPushNot()", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], .T., cUID )
			Else
				uRet := MrhPushNot(aParams[1], aParams[2], aParams[3], aParams[4], .F., NIL)
			EndIf
		Case cRotina == "23" // Marcação global de ponto
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHPO_GLOBAL_CLOCKINGS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGlobalClocks", GetEnvServer(), .T., aParams[1], aParams[2], .T., cUID )
			Else
				uRet := fGlobalClocks(aParams[1], aParams[2] )
			EndIf
		Case cRotina == "24" // Informações de férias solicitadas.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_INFO_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetVacInfo", ;
								   GetEnvServer(), ;
								   .T., 		   ;
								   aParams[1], 	   ;
								   aParams[2], 	   ;
								   aParams[3], 	   ;
								   aParams[4] ,    ;
								   aParams[5] ,    ;
								   aParams[6] ,    ;
								   aParams[7] ,    ;
								   .T., 		   ;
								   cUID )
			Else
				uRet := fGetVacInfo(aParams[1], ;
								    aParams[2], ;
									aParams[3], ;
									aParams[4], ;
									aParams[5], ;
									aParams[6], ;
									aParams[7], ;
									.F., 		;
									NIL )
			EndIf
		Case cRotina == "25" // Histórico de férias solicitadas.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_HISTORY_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetVacHist", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3] , .T., cUID )
			Else
				uRet := fGetVacHist(aParams[1], aParams[2], aParams[3], .F., NIL )
			EndIf
		Case cRotina == "26" // Detalhe do recibo de férias.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_DETAIL_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fGetVacDet", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4] , .T., cUID )
			Else
				uRet := fGetVacDet(aParams[1], aParams[2], aParams[3], aParams[4], .F., NIL )
			EndIf
		Case cRotina == "27" // Validações do PUT e POST das solicitações de Férias.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRH_VACATION_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fValidVac",     ;
						          GetEnvServer(), ;
								  .T.,            ;
								  aParams[1],     ;
								  aParams[2],     ;
								  aParams[3],     ;
								  aParams[4],     ;
								  aParams[5],     ;
								  aParams[6],     ;
								  aParams[7],     ;
								  aParams[8],     ;
								  aParams[9],     ;
								  aParams[10],    ;
								  aParams[11],    ;
								  .T.,            ;
								  cUID )
			Else
			uRet := fValidVac(	aParams[1], 	;
								aParams[2],     ;
								aParams[3],     ;
								aParams[4],     ;
								aParams[5],     ;
								aParams[6],     ;
								aParams[7],     ;
								aParams[8],     ;
								aParams[9],     ;
								aParams[10],    ;
								aParams[11],    ;
								.F.,        	;
								NIL )
			EndIf
		Case cRotina == "28" // Saldo de férias proporcionais para férias futuras.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_BALANCE_AUX" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fProjDias",     ;
						          GetEnvServer(), ;
								  .T.,            ;
								  aParams[1],     ;
								  aParams[2],     ;
								  aParams[3],     ;
								  aParams[4],     ;
								  aParams[5],     ;
								  .T.,            ;
								  cUID )
			Else
			uRet := fProjDias(	aParams[1], 	;
								aParams[2],     ;
								aParams[3],     ;
								aParams[4],     ;
								aParams[5],     ;
								.F.,        	;
								NIL )
			EndIf
		
		Case cRotina == "29" // Retorna o aviso de férias.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_NOTICE" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fVacNotice",     ;
						          GetEnvServer(), ;
								  .T.,            ;
								  aParams[1],     ;
								  aParams[2],     ;
								  aParams[3],     ;
								  aParams[4],     ;
								  .T.,            ;
								  cUID )
			Else
			uRet := fVacNotice(	aParams[1], 	;
								aParams[2],     ;
								aParams[3],     ;
								aParams[4],     ;
								.F.,        	;
								NIL )
			EndIf
		Case cRotina == "30" // Retorna o recibo de férias.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_VACATION_REPORT" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a criação e o retorno do Job
				uRet := StartJob( "fVacReport",     ;
						          GetEnvServer(), ;
								  .T.,            ;
								  aParams[1],     ;
								  aParams[2],     ;
								  aParams[3],     ;
								  aParams[4],     ;
								  .T.,            ;
								  cUID )
			Else
			uRet := fVacReport(	aParams[1], 	;
								aParams[2],     ;
								aParams[3],     ;
								aParams[4],     ;
								.F.,        	;
								NIL )
			EndIf
		Case cRotina == "31" // Retorna o time do colaborador logado ou do colaborador consultado.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_TEAM_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")
				
				uRet := StartJob( "fTeamEmp"	, ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  .T.			, ;
								  cUID )
			Else
				uRet := fTeamEmp( aParams[1], ;
								  aParams[2], ;
								  aParams[3], ;
								  aParams[4], ;
								  .F.		, ;
								  "" )
			EndIf
		Case cRotina == "32" // Retorna o detalhe de uma requisição.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_REQ_DETAIL" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fDetailReq" 	, ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := fDetailReq(aParams[1]	, ;
								   aParams[2]	, ;
								   aParams[3]	, ;
								   aParams[4]	, ;
								   .F.			, ;
								   cUID)
			EndIf
		Case cRotina == "33" // Retorna o detalhe da requisição de transferência.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_REQ_TRANSF" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fDetailTrnsf"	, ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  .T.			, ;
								  cUID)
			ELse
				uRet := fDetailTrnsf(aParams[1]	, ;
									aParams[2]	, ;
									aParams[3]	, ;
									aParams[4]	, ;
									.F.			, ;
								   	cUID)
			EndIf
		Case cRotina == "34" // Retorna os tipos cadastrados para ações salariais.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_SALARY_TYPES" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fSalaryTypes"	, ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .T.			, ;
								  cUID)

			Else
				uRet := fSalaryTypes(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "35" // Retorna as categorias utilizadas na requisição de ação salarial
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_CATEGORY_TYPES" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fCategoryTypes", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .T.			, ;
								  cUID)

			Else
				uRet := fCategoryTypes(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "36" // Retorna o perfil do colaborador.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_PROFILE" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("DataProfile", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := DataProfile(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "37" // Retorna a lista de atestados médicos.
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_MEDICAL_CERTIFICATE" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fGetMedical", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := fGetMedical(;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "38"
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRH_MEDICAL_CERTIFICATE" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fGrvMedical", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  aParams[8]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := fGrvMedical(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  aParams[8]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina =="39"
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_PAYMENT_DETAIL" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("GetResume", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  .T.			, ;
								  cUID)

			Else
				uRet := GetResume(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  aParams[7]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "40"
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_PAYMENT_REPORT" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("GetRecptPay", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := GetRecptPay(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  .F.			, ;
								  cUID)
			EndIf
		Case cRotina == "41"
			If lExecJob
				//Define o nome da variavel de controle
				cUID := "MRHG_SALARY_HISTORY" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				uRet := StartJob("fGetHistSal", ;
								  GetEnvServer(), ;
								  .T.			, ;
								  aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  .T.			, ;
								  cUID)
			Else
				uRet := fGetHistSal(aParams[1]	, ;
								  aParams[2]	, ;
								  aParams[3]	, ;
								  aParams[4]	, ;
								  aParams[5]	, ;
								  aParams[6]	, ;
								  .F.			, ;
								  cUID)
			EndIf
	ENDCASE

	//Aguarda a finalizacao do JOB no máximo por 10 segundos antes de sair da rotina
	While lExecJob
		//Obtem o valor da variavel global
		If GetGlbValue(cUID) == "1"
			Exit
		Else 
			nCount ++
			Sleep(nTime)
		EndIf
		lExecJob := (nCount < 10)
	EndDo

	//Limpa a variavel global da memoria
	If !Empty(cUID)
		ClearGlbValue(cUID)
	EndIf

Return( uRet )

