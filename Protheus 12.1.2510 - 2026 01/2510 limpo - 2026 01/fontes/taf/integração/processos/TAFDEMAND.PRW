#INCLUDE "Protheus.ch"
#INCLUDE "fwmvcdef.ch"


/*/{Protheus.doc} TAFDEMAND
Rotina de job centralizador para acionamento dos Jobs 2 ,4 e 5
@type function
@version 
@since 19/05/2020
@param aParam, array, parametrização do schedule
@return null,null, Função sem retorno
@obs Estrutura do aParam:
aParam 1 :T1
aParam 2 :EVENTO
aParam 3 :D MG 01
aParam 4 :000000
aParam 5 :000001000002
/*/
Function TAFDEMAND(aParam)

	Local cEmpSched 	:= ""
	Local cEventos		:= ""
	Local lLocalizou	:= .T.

	Default aParam 		:= {}
	If Len(aParam) > 0
		cEmpSched := aParam[1]
	Else
		cEmpSched := "01"
	EndIf 
	//==================================================
	//BUSCA DOS EVENTOS CADASTRADOS NO GRUPO DE EVENTOS
	//==================================================
	If Len(aParam) > 1
		lLocalizou	:= GetEventos(aParam[1],aParam[2],@cEventos) //GRUPO DE EMPRESA,CÓDIGO DO GRUPO DE EVENTOS
	EndIf

	//==================================
	//SE LOCALIZAR EVENTOS, ACIONA JOBS
	//==================================
	TafConOut("*************** PROCESSO DE INTEGRAÇÃO TAFAINTEG 2 ***************")
	TAFDinamicJOB(2,cEmpSched,cEventos)
	TafConOut("*************** PROCESSO DE INTEGRAÇÃO TAFPROC4 ***************")
	TAFDinamicJOB(4,cEmpSched,cEventos)
	TafConOut("*************** PROCESSO DE INTEGRAÇÃO TAFPROC5 ***************")
	TAFDinamicJOB(5,cEmpSched)

Return Nil 

/*/{Protheus.doc} GetEventos
Encapsulamento de busca dos eventos cadastrados no grupo de eventos.
@type function
@version 1.0
@author eduardo.vicente
@since 19/05/2020
@param cGrpJob, character, código do grupo de empresas
@param cGrpEvent, character, código do grupo de eventos
@return cEventos,string, Eventos cadastrados
/*/
Function GetEventos(cGrpJob,cGrpEvent,cEventos)
	
	Local lResult		:= .T.
	
	Default cEventos	:= ""
	Default cGrpEvent	:= ""
	Default cGrpJob		:= ""
	
	//=====================================================================
	//ABERTURA DE AMBIENTE PARA CONSULTA DE TABELAS E ACESSO AO DICIONÁRIO
	//=====================================================================
    RpcSetType(3)
	RpcSetEnv(cGrpJob,,,,"TAF","TAFDEMAND",,,,.T.,)
	TafConOut('Ambiente em preparo. Grupo : ' + cGrpJob + '.' + " Buscando eventos cadastros no Grupo de Eventos.")
	cGrpEvent	:= PadR(cGrpEvent,TamSX3('LE6_CODIGO')[1])

	dbSelectArea('LE6')//Grupo de Eventos              
	dbSelectArea("LE8")//Eventos Relacionados ao Grupo 
	dbSelectArea("C8E")//Cadastro de tipos de Arquivos da eSocial
	
	LE6->(dbSetOrder(2)) //LE6_FILIAL+LE6_CODIGO
	LE8->(dbSetOrder(1)) //LE8_FILIAL+LE8_ID+LE8_IDEVEN
	C8E->(dbSetOrder(1)) //C8E_FILIAL+C8E_ID

	If LE6->(dbSeek(xFilial("LE6")+cGrpEvent))

		If FwIsInCallStack('TAFSCHED4')
			While !LE6->(EOF()) 
		
				If LE8->(dbSeek(xFilial("LE6",LE6->LE6_FILIAL)+LE6->LE6_ID)) 
		
					While LE8->(LE8_FILIAL+LE8_ID) == (xFilial("LE6",LE6->LE6_FILIAL)+LE6->LE6_ID)
						
						If C8E->(dbSeek(xFilial("C8E",LE8->LE8_FILIAL)+LE8->LE8_IDEVEN))
							
							cEventos+= C8E->C8E_CODIGO + "|"
		
						EndIf
		
						LE8->(dbSkip())
		
					EndDo
		
				EndIf
		
				LE6->(dbSkip())
		
			EndDo
		Else
			While !LE6->(EOF()) .And. (LE6->(LE6_FILIAL+LE6_CODIGO) == xFilial("LE6")+cGrpEvent)
		
				If LE8->(dbSeek(xFilial("LE6",LE6->LE6_FILIAL)+LE6->LE6_ID)) 
		
					While LE8->(LE8_FILIAL+LE8_ID) == (xFilial("LE6",LE6->LE6_FILIAL)+LE6->LE6_ID)
						
						If C8E->(dbSeek(xFilial("C8E",LE8->LE8_FILIAL)+LE8->LE8_IDEVEN))
							
							cEventos+= C8E->C8E_CODIGO + "|"
		
						EndIf
		
						LE8->(dbSkip())
		
					EndDo
		
				EndIf
		
				LE6->(dbSkip())
		
			EndDo
		EndIf
		
	EndIf

	If EMPTY(cEventos)
		TafConOut('Ambiente em preparo. Grupo : ' + cGrpJob + '.' + " Eventos não localizados, favor acessar a rotina TAFA441-Cadastro de Grupo de Eventos.")
		lResult:= .F.
	EndIf
    RpcClearEnv()

Return lResult
