#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
  
STATIC MAXSIZE_FILE		:= 850000 	//limite de bytes (evitar erro de estouro de memória) ->  Paginação
STATIC MAXGET_EVENTOS	:= 200		//limite de retorno em 200 registros -> Paginação

//----------------------------------------------------------------------------------------------------------
/*/ WSTAFQueryElements
O Web Service REST WSTAFQueryElements permite que uma aplicação faça uma consulta 
generalizada na base de dados do TOTVS Automação Fiscal para 
obter uma série de registros/elementos através de um status 
pré-definido pela aplicação (de acordo com os status existentes no TAF) 
ou do tipo do registro (de acordo com os tipos existentes no TAF).     


http://tdn.totvs.com.br/display/TAF/Web+Service+REST+-+Consulta+de+Elementos   

@param status			String		Status do registro no TAF 							- OC 
@param registryType		String		Tipo do registro/layout. Exemplo: T007, S-1010... 	- O 
@param startRecNo   	Integer		RecNo inicial para consulta 						- O 

  
@return cMensagem Json na estrutura:

	{
	"registryType": "", 
	"statusCode": "", 
	"itens": 	
	[{
		"registryKey": "",
		"statusCode": "",
		"statusDescription": "",
		"validateErrors": 
		[{
			"validateErrorCode": "",
			"validateErrorDetail": ""
		}],
		"streamingErrors": 
		[{
			"streamingErrorCode": "",
			"streamingErrorDetail": ""
		}],
		"registryProtocol": ""
	}],
	"lastRecNo": 0,
	"maxRecNo": 0
	}

***  Somente os atributos do primeiro nível são obrigatórios! ***

@author Eduardo Bego Mantoan
@since 03/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------
//SIGAMAT incluir no header CNPJ INCR. estadual e municipal.
WSRESTFUL WSTAFQueryElements DESCRIPTION "Consultar uma lista de elementos presentes na base de dados do TAF através de um status ou tipo pré-definido."

WSDATA status 		as String
WSDATA registryType as String
WSDATA startRecNo	as Integer 
WSDATA sourceBranch as String

WSMETHOD GET DESCRIPTION "Consultar uma lista de elementos presentes na base de dados do TAF através de um status ou tipo pré-definido." WSSYNTAX "/WSTAFQueryElements || /WSTAFQueryElements/{id}"

END WSRESTFUL


//----------------------------------------------------------------------------
/*/{Protheus.doc} GET 
Método de consulta principal do Serviço WSTAFQueryElements.

@param status			String		Status do registro no TAF 							- OC 
@param registryType		String		Tipo do registro/layout. Exemplo: T007, S-1010... 	- O 
@param startRecNo   	Integer		RecNo inicial para consulta 						- O 


@author Eduardo Bego Mantoan
@since 03/07/2017

@version 12.1.18
/*/
//--------------------------------------------------------------------------- 

WSMETHOD GET WSRECEIVE status,registryType,startRecNo,sourceBranch WSSERVICE WSTAFQueryElements
	
	//Controle
	local cFuncIPC 	as character
	local cFuncREST	as character
	local cUId		as character
	local cChave	as character
	local cValorR	as character
	
	local lRet		as logical
	local lRet2		as logical
	
	local aQryParam	as array
	local aRetorno	as array
	
	aQryParam	:= {}
	
	cFuncIPC 		:= ""
	cFuncREST 		:= "TafRest"
	cUId 			:= "HTTPTAF_" + AllTrim(Str(Randomize(1,999)))
	cChave 			:= "GET"
	cValorR 		:= "respGET"
	
	lRet 			:= VarSetUID(cUId, .T.)

	::SetContentType("application/json")
	
	aAdd(aQryParam,::startRecNo)
   	aAdd(aQryParam,::registryType)
   	aAdd(aQryParam,::status)
	aAdd(aQryParam,::sourceBranch)

	::sourceBranch := IIf (ValType(::sourceBranch) == "U","",::sourceBranch)
   
	If WSST2ValFil(::sourceBranch,@cFuncIPC)
	   	TAFCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam)
   	   	
		lRet2 := VarGetAD(cUId,cValorR,@aRetorno) 
  	
	  	If Valtype(aRetorno) == "A"
  	
			If Valtype(aRetorno[1]) == "C"
		
				::Self:SetResponse(aRetorno[1])
			
			ElseIf Len(aRetorno) = 3
		
				SetRestFault(aRetorno[2],aRetorno[3])
				lRet := .F.
			Else
		
				SetRestFault(802," Internal error. ")
				lRet := .F.		
			
			EndIf
		
		Else
			SetRestFault(802," Internal error. ")
			lRet := .F.	
		EndIf
	Else
		SetRestFault(803,"O valor do campo " + "sourceBranch (TAFFIL) " + " não está cadastro no complemento de empresas.") ////"O valor do campo "#" não está cadastro no complemento de empresas."
	EndIf

Return lRet


//----------------------------------------------------------------------------
/*/{Protheus.doc} TafRest(cUId,cChave,cValorR,aQryParam)  
Função de consulta principal do Serviço WSTAFQueryElements.

@param cUId			- Identificador da sessão de Variáveis Globais.
@param cChave 		- Identificador da chave (tabela X) HashMap
@param cValorR 		- Variável onde será armazenado o valor da chave ("Tabela A").
@param aQryParam 	- Parâmetros de entrada do método GET.

@author Eduardo Bego Mantoan
@since 03/07/2017

@version 12.1.18
/*/
//--------------------------------------------------------------------------- 

Function TafRest(cUId,cChave,cValorR,aQryParam) 
	
	
	//REST
	local cJson 	as character
	local cError 	as character
	local nError 	as numeric
	local lRest		as logical
	
	local nRecNo	as numeric
	local cCGC		as character 
	local cInscEst	as character
	local cInscMun	as character
	local cRegType	as character
	local cStatus	as character
	
	//HEADER
	local aArea     	as array
	local lAchou		as logical
	local cEmpresa  	as character
	local cSourceBranch	as character
	local aFil      	as array
	
	cJson			:= ""
	cError 			:= ""
	nError 			:= 0
	lRest			:= .T.
		
	aArea			:= SM0->( GetArea() )
	lAchou			:= .F.
	cEmpresa		:= ""
	aFil			:= {}
	
	default cUId		:= ""
	default cChave		:= "" 
	default	cValorR		:= 0
	default aQryParam 	:= {0,"","",""}
	
	
	nRecNo			:= aQryParam[1]
	cRegType		:= aQryParam[2]
	cStatus			:= aQryParam[3]
	cSourceBranch	:= aQryParam[4]

	lAchou := .T.
	cEmpresa	:= SM0->M0_CODIGO
	aFil		:= WsFilGrp(cSourceBranch)

	If lAchou
		If  Valtype(nRecNo) == "N" .And. Valtype(cRegType) == "C" // Recno e layout são obrigatórios
			If Valtype(cStatus) == "C" 
				cJson := TAFQryElmt(cStatus,cRegType,nRecNo,@cError,@nError,cEmpresa,aFil)						
			Else
				cJson := TAFQryElmt(,cRegType,nRecNo,@cError,@nError,cEmpresa,aFil)				
			EndIf
		Else	
			cError	:= " Os parametros obrigatorios estao incorretos. " 
			nError	:= 804
			lRest 	:= .F.			
		EndIf
		
		If !EmptY(cJson) .And. Empty(cError) .And. nError = 0
			TAFFinishWS(cChave,cUId,cValorR,{cJson} ,3)			
		ElseIf !Empty(cError) .And. nError > 0 				
			lRest := .F.	
			TAFFinishWS(cChave,cUId,cValorR,{,nError,cError} ,3)			
		Else		
			lRest := .F.	
			TAFFinishWS(cChave,cUId,cValorR,{,802," Internal error. "} ,3)		
		EndIf
		
	Else
		lRest := .F.
		TAFFinishWS(cChave,cUId,cValorR,{,805," A Empresa/Filial não foi encontrada no TAF. "} ,3)
	EndIf

	RestArea( aArea )
	
Return lRest

//----------------------------------------------------------------------------
/*/{Protheus.doc} WsFilGrp
Realiza Busca das Filial do Grupo de empresas informado 

@sourceBranch - Filial do Erp

@author Leonardo Kichitaro
@since 20/02/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function WsFilGrp(sourceBranch)

	Local cUUIDFil		as character
	Local cChaveFil		as character
	Local aEmpresas		as array
	Local aFilGrp		as array
	Local nPosEmpTAF	as numeric
	Local nX		as numeric
	
	cUUIDFil     := "tafJobID"
	cChaveFil    := "keyTafJob"
	cEmpTaf		 := ""
	aEmpresas	 := {}
	aFilGrp		 := {}
	
	//Seção tafJobID (cUUIDFil) criada no fonte TAF_CFGJOB
	If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)
	
		For nX := 1 To Len(aEmpresas)
	
			nPosEmpTAF := aScan(aEmpresas[nX][2],{|emps|AllTrim(emps[1]) == AllTrim(sourceBranch)}) 
	
			If (nPosEmpTAF > 0)
				aAdd(aFilGrp,AllTrim(aEmpresas[nX][2][nPosEmpTAF][2]))
				Exit
			EndIf
		Next nX
	EndIf

Return aFilGrp

//----------------------------------------------------------------------------------------------------------
/*/ TAFQryElmt(cStatus,cRegType,nSRecNo,cError,nError,cEmpresa,aFil)
O serviço permite que uma aplicação faça uma consulta 
generalizada na base de dados do TOTVS Automação Fiscal para 
obter uma série de registros/elementos através de um status 
pré-definido pela aplicação (de acordo com os status existentes no TAF) 
ou do tipo do registro (de acordo com os tipos existentes no TAF).     


http://tdn.totvs.com.br/display/TAF/Web+Service+REST+-+Consulta+de+Elementos   

@param cStatus		Character		Status do registro no TAF 							- OC 
@param cRegType		Character		Tipo do registro/layout. Exemplo: T007, S-1010... 	- O 
@param nSRecNo   	Numeric			RecNo inicial para consulta 						- O 
@param cError		Character		Menssagem de erro									
@param nError		Numeric			Código de erro
@param cEmpresa		Character		Código do grupo de empresa
@param aFil			Array			Código da filial da empresa 
  
@return cJSONResponse	Mensagem JSON de resposta da requisição.  

@author Eduardo Bego Mantoan
@since 03/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------
Function TAFQryElmt(cStatus,cRegType,nSRecNo,cError,nError,cEmpresa,aFil)


	local cJSONResponse	as character
	local aDados 		as array
 
	cJSONResponse		:= ""
	aDados 				:= {}
	
	default cStatus		:= "" 
	default cRegType	:= "" 
	default nSRecNo		:= 0 
	
	default cError		:= ""
	default nError		:= 0
	
	default cEmpresa	:= ""
	default aFil		:= {}
	
	//Chama a função que valida e obtem os dados
	aDados := GetInfo(AllTrim(cStatus),AllTrim(cRegType),nSRecNo,@cError,@nError,cEmpresa,aFil)	

	If(empty(cJSONResponse))

		cJSONResponse := getJSONResp(aDados, @cError,@nError)
	
	EndIf	
		
	aDados := nil
	
return cJSONResponse


//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetInfo(cStatus,cRegType,nSRecNo,@cError,cEmpresa,aFil)
Função com o objetivo de validar, buscar e retornar informações do TAF         

@param cStatus		Character		Status do registro no TAF 							- OC 
@param cRegType		Character		Tipo do registro/layout. Exemplo: T007, S-1010... 	- O 
@param nSRecNo   	Integer			RecNo inicial para consulta 						- O 
@param cError		Character		Menssagem de erro									
@param nError		Numeric			Código de erro
@param cEmpresa		Character		Código do grupo de empresa
@param aFil			Array		Código da filial da empresa 
 
@return aDados		Array		Array contendo as informações obtidas nas tabelas do TAF .  

@author Eduardo Bego Mantoan
@since 03/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------
Static Function GetInfo(cStatus,cRegType,nSRecNo,cError,nError,cEmpresa,aFil)
	
	Local lOk			as logical	
	Local aDados		as array
	Local aRotina		as array
	
	default cStatus		:= "" 
	default cRegType	:= "" 
	default nSRecNo		:= 0
	
	default cError		:= "" 
	default nError		:= 0
	
	default cEmpresa	:= ""
	default aFil		:= {}
	
	lOk 				:= .T.
	aDados				:= {}
	aRotina				:= {}
	
	If	!Empty(cRegType) 
	
		aRotina := TAFRotinas(cRegType,4,.F.) // Busca layout no TAFRotinas
		
		If !Len(aRotina) > 0
			lOk	:= .F.
			cError := " Tipo de registro (registryType) solicitado no request é inválido. " 	
			nError := 801	
		EndIf
		
	Else
		lOk	:= .F.
		cError := " O tipo de registro (registryType) não foi informado. " 
		nError := 801			
	Endif
	
	If !Empty(cStatus) .And. lOk		
		If !(cStatus $ "' '|0|1|2|3|4|6|7") 	
			lOk	:= .F.	
			cError := " Status (status) solicitado no request é inválido. "
			nError := 800
		EndIf	
	EndIf
		
	//Se os dados validados estiverem OK, chama a função que buscará as informações nas tabelas do TAF	(RetInfoTAF)
	If lOk
		aDados	:= RetInfoTAF(cStatus,aRotina,nSRecNo,@cError,@nError,cEmpresa,aFil)		
	Else		
		If	Empty(cError)
			cError := " Internal error. "
			nError := 802
		EndIf		
	EndIf

return aDados

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetInfoTAF(cStatus,aRotina,nSRecNo,cError,cEmpresa,aFil)
Retorna informações do TAF conforme parâmetros de entrada.      

@param cStatus		Character		Status do registro no TAF 											- OC 
@param aRotina		Array			Aray contendo  o tipo do registro/layout. Exemplo: T007, S-1010... 	- O 
@param nSRecNo   	Integer			RecNo inicial para consulta 										- O 
@param cError		Character		Menssagem de erro									
@param nError		Numeric			Código de erro
@param cEmpresa		Character		Código do grupo de empresa
@param aFil			Array		Código da filial da empresa 
  
@return aDados		Array		Array contendo as informações obtidas nas tabelas do TAF.

@author Eduardo Bego Mantoan
@since 04/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------

Static Function RetInfoTAF(cStatus,aRotina,nSRecNo,cError,nError,cEmpresa,aFil)
	
	local lOracle		as logical
	local nQuebra		as numeric
	local nDados		as numeric
	local cQrec			as character
	local nTam			as numeric
	local lLimite		as logical
	Local lCosultTrans  as logical
	local cQ			as character
	local cQuery		as character
	local cAUlt			as character
	local cAlias		as character
	local cTab			as character
	local cStatgov		as character
	Local cIdEntidade 	as character 
	local nX			as numeric
	local nY			as numeric
	local nZ			as numeric
	local nV			as numeric
	local nTafRec		as numeric
	local nRecCU0		as numeric
	local nUltRec		as numeric
	local nQtdReg		as numeric
	local cTabCU0		as character
	local cTabC1E		as character
	local cFilTab		as character
	Local cCachFil		as character
	
	local cModo			as character
	local cModoTab		as character
	local cX2Alias		as character
	local cCodGrpEmp	as character 
	local aAreaSM0		as array
	
	local aDados		as array
	local aGetArea		as array
	default cStatus 	:= ""
	default aRotina 	:= {}
	default nSRecNo	 	:= 0
	
	default cError		:= ""
	default nError		:= 0
	
	default cEmpresa	:= ""
	default aFil		:= {}
	
	lOracle				:= .F.
	nQuebra				:= 50 //-> limite para processamento da query
	nDados				:= 0 // tamanho do retorno
	cQrec				:= ""
	nTam				:= 0
	lLimite				:= .F.
	lCosultTrans 	 	:= SuperGetMv('MV_TAFWSCT',.F.,.F.) // Habilita consulta a regitros Transmitidos (Status Igual a 2), por default somente é consultado os inconsitentes
	cQ					:= ""
	cQuery				:= ""
	cAUlt				:= ""
	cAlias				:= ""
	cTab				:= ""
	cStatgov			:= ""
	cCachFil			:= ""
	cIdEntidade			:= ' '
	nX					:= 1
	nY					:= 1
	nZ					:= 1
	nV					:= 0
	nTafRec				:= 0
	nRecCU0				:= 0
	nUltRec				:= 0
	nQtdReg				:= 0
	cTabCU0				:= ""
	cTabC1E				:= ""
	cFilTab				:= ""
	cModo				:= ""
	cModoTab			:= ""
	cX2Alias			:= "SX2"
	aGetArea			:= {}
	cCodGrpEmp 			:= FWGrpCompany()
	aAreaSM0			:= {}
	//Monta estrutura do array para o retorno conforme documentação: http://tdn.totvs.com.br/display/TAF/Web+Service+REST+-+Consulta+de+Elementos
	
	aDados				:= {"","",{},0,0}		// Primeiro nível		
	aAdd(aDados[3],	{"","","",{},{},""})		// Segundo nível -> cria mesmo que não haja dados, assim gerando retornando o json com nenhum resoltado.
	
	If Len(aRotina) > 0
	
		cTab			:= AllTrim(aRotina[3])
		
		lOracle := "ORACLE" $ TcGetDB()
			
		cModo 		:= GetSXSName("SX2","CU0",cEmpresa,"X2_MODO") 
		cModoTab	:= GetSXSName("SX2",cTab,cEmpresa,"X2_MODO") 
		
		cTabLay		:= GetSXSName("SX2",cTab,cEmpresa,"X2_ARQUIVO")
		cTabCU0 	:= GetSXSName("SX2","CU0",cEmpresa,"X2_ARQUIVO")
		cTabC1E		:= GetSXSName("SX2","C1E",cEmpresa,"X2_ARQUIVO")

		// As informações das tabelas não podem estar 'vazias'
		If  EmpOpenFile("CU0","CU0",1,.T.,AllTrim(cEmpresa),@cModo) .And. !Empty(cTabLay) .And. !Empty(cTabCU0)	.And. !Empty(cModoTab)

			cCachFil := TAFCacheFil(Nil, aFil, .T.)

			//Início da atribuição dos dados no array multidimencional
			aDados[1] 		:= AllTrim(aRotina[4])
			nDados			+= Len(aDados[1])
			
			If !Empty(cStatus)
				If cStatus $ "' '"				
					aDados[2] 	:=  "' '"				
				Else				
					aDados[2] 	:=  AllTrim(cStatus)					
				EndIf	
					
				nDados		+= Len(aDados[2])			
			EndIf
					
			cAlias 	:= getNextAlias()
				
			If !lOracle			
				cQuery 	:= " Select TOP "+ ALLTRIM(STR(nQuebra)) +" " 	//Quantidade de registros por paginação + 1 para que será o registro de controle para a próxima consulta.
				cQrec	:= " Select TOP "+ ALLTRIM(STR(1)) +" " 		//Ultimo registro.				
			Else			
				cQuery	:= " Select "
				cQrec	:= " Select "
			EndIf
			
			cQ 	:= "  TAFXERP.TAFKEY as TAFKEY, "+ cTab +"."+ cTab +"_STATUS as STATUS,CU0.CU0_CODERR as CODERR," 
			cQ 	+= " CU0.CU0_DCODER as DCODER,TAFXERP.R_E_C_N_O_ as RECERP,"+ cTab +".R_E_C_N_O_ as REC,CU0.R_E_C_N_O_ as RecCU0 "

			If SubStr(AllTrim(aRotina[4]),1,2) == "S-"
				cQ 	+=" ,"+ cTab +"."+ cTab +"_PROTUL as PROTUL "
			EndIf

			cQ 	+= " From " + cTabLay + " "+ cTab
			cQ 	+= " Left  Join TAFXERP on TAFXERP.TAFRECNO  = "+ cTab +".R_E_C_N_O_  And TAFXERP.TAFALIAS = '"+ cTab +"' And TAFXERP.D_E_L_E_T_ = ' ' and TAFXERP.TAFKEY In "
			cQ 	+= " ( "
			cQ 	+= "    Select TAFST2.TAFKEY "
			cQ 	+= " 	From TAFST2 "
			cQ 	+= " 	Where "
			cQ 	+= "  TAFST2.TAFFIL IN (SELECT C1E_CODFIL FROM "+ cTabC1E +" C1E WHERE C1E.C1E_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) " 
			cQ 	+= "			) "
			cQ 	+= " ) "
			cQ 	+= " Left Join "+ cTabCU0 +" CU0 on CU0.CU0_RECNO  = "+ cTab +".R_E_C_N_O_  And CU0.CU0_ALIAS	= '"+ cTab +"' And CU0.D_E_L_E_T_	= ' ' "

			If AllTrim(cModo) == "E"

				cQ += " AND CU0.CU0_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) " 

			EndIf
			
			cQ 	+= " Where "
			cQ +=  cTab +".D_E_L_E_T_ = ' ' "
			
			If cTab $ "C9V|C91" // tabelas possum mais de um layout/Evento
			
				cQ += " And "+ cTab +"."+ cTab +"_NOMEVE = '"+ StrTran(aDados[1],"-","") +"' "	
			
			EndIf

			If SubStr(AllTrim(aRotina[4]),1,2) == "S-"  // Se for e-social verifica se o campo _Ativo existe, se existir _ATIVO = 1
				If EmpOpenFile(cTab,cTab,1,.T.,AllTrim(cEmpresa),@cModoTab)				
					If (cTab)->(FieldPos(cTab+"_ATIVO")) > 0					
						cQ += " And "+ cTab +"."+ cTab + "_ATIVO = '1' "							
					EndIf					
					//Fecha alias cTab de outra empresa aberto
					EmpOpenFile(cTab,cTab,1,.F.,AllTrim(cEmpresa),@cModoTab)					
				EndIf
			Endif
			
			If !Empty(cStatus) 			
				If  cStatus $ "' '"					
					cQ 	+= " And "+ cTab +"_STATUS 		= ' ' "					
				Else				
					cQ 	+= " And "+ cTab +"_STATUS 		= '"+cStatus+"' "					
				EndIf				
			EndIf
			
			cQ  += " And "+ cTab +".R_E_C_N_O_ >= '"+ AllTrim(Str(nSRecNo)) +"' " // Recno da próxima consulta deve ser maior que o recno enviado anteriormente pois o registro ja foi informado no JSON.
			
			If AllTrim(cModoTab) == "E"

				cQ += " AND " + cTab + "." + cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) " 

			EndIf
			
			cQuery += cQ	// Query para obter todos os dados necessários para o retorno.
			cQrec  += cQ	// Query para ver o ultimo registro para efeio de paginação.
			
			If lOracle	
				cQuery += " And ROWNUM  <= '"+ALLTRIM(STR(nQuebra))+" '  " 	//Quantidade de registros por paginação + 1 para que será o registro de controle para a próxima consulta.	
				cQrec  += " And ROWNUM  <= '"+ALLTRIM(STR(1))+" '  "			//Ultimo registro.				
			EndIf
			
			cQuery 	+= " Order By "+ cTab +".R_E_C_N_O_,TAFXERP.R_E_C_N_O_,CU0.R_E_C_N_O_ "
			cQrec	+= " Order By "+ cTab +".R_E_C_N_O_ DESC "

			DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery),(cAlias),.F.,.T.)
			
			DbSelectArea(cAlias)
			(cAlias)->(DbGoTop())
			
		 	If !(cAlias)->(Eof())
				
				nTam := nQtdReg := 0

				While !(cAlias)->(Eof())
					//ConOut("Contador Thread " + AllTrim(Str(ThreadID())) + " : " + AllTrim(Str(nQtdReg)))
					If nDados > MAXSIZE_FILE .Or. nQtdReg > MAXGET_EVENTOS
						lLimite := .T.
						exit
					Else
						nUltRec := (cALias)->REC // ultimo recno (Paginação)
					EndIf

					nTafRec := (cALias)->REC
							
					If !Empty((cAlias)->TAFKEY) // Se não encontrar registro na TAFXERP significa que a inclusão foi manual e não por integração.
						aDados[3][nX][1] 		:= AllTrim((cAlias)->TAFKEY)
						nDados					+= Len(aDados[3][nX][1])
					Else
						aDados[3][nX][1] 		:= "Inclusão Manual"	
						nDados					+= Len(aDados[3][nX][1])
					EndIf
								
					If Empty(cStatus)
					
						If Empty((cAlias)->STATUS)
							aDados[3][nX][2] 		:= "' '"
							aDados[3][nX][3] 		:= StatusTaf("' '")
						Else
							aDados[3][nX][2] 		:= AllTrim((cAlias)->STATUS)
							aDados[3][nX][3] 		:= StatusTaf((cAlias)->STATUS)
						EndIf
						
						nDados					+= Len(aDados[3][nX][2])
						nDados					+= Len(aDados[3][nX][3])						
					EndIf
					
					If SubStr(AllTrim(aRotina[4]),1,2) == "S-"
						aDados[3][nX][6]		:= AllTrim((cAlias)->PROTUL)
					Else
						aDados[3][nX][6]		:= ""	
					EndIf
					nDados					+= Len(aDados[3][nX][6])

					//Retorna erros do RET/TSS
					If SubStr(AllTrim(aRotina[4]),1,2) == "S-"
						
						cFilTab  := ""
						aGetArea := (cTab)->(GetArea())
						(cTab)->(dbgoto((cAlias)->REC))
						cFilTab	:= (cTab)->&(cTab + "_FILIAL")
						RestArea(aGetArea)

						aAreaSM0 := SM0->(GetArea())
						SM0->(MsSeek(cCodGrpEmp+AllTrim(cFilTab)))
						aErrosRET := GetErroTSS( AllTrim(aRotina[4]) , (cAlias)->REC, cFilTab,,,, cTab )
						RestArea(aAreaSm0)
						//ConOut("Contador RECNO " + AllTrim(Str( (cAlias)->REC )) )

						For nV := 1 To Len(aErrosRET)
							aAdd(aDados[3][nX][5],	{"",""}) // Terceiro nível

							aDados[3][nX][5][nV][1] := aErrosRET[nV][1]
							aDados[3][nX][5][nV][2]	:= aErrosRET[nV][2]
						Next
					EndIf

					nY := 1
					If (cALias)->RecCU0 > 0 
					
						aAdd(aDados[3][nX][4],	{"",""}) // Terceiro nível
						
						While nTafRec = (cALias)->REC 	
								
							nRecCU0 := (cALias)->RecCU0
							
							CU0->(dbgoto((cALias)->RecCU0))
							
							aDados[3][nX][4][nY][1] := AllTrim((cALias)->CODERR)
							
							aDados[3][nX][4][nY][2]	:= AllTrim(CU0->CU0_DCODER)
							
							nDados					+= Len(aDados[3][nX][4][nY][1])
							nDados					+= Len(aDados[3][nX][4][nY][2])
							
							(cAlias)->(DbSkip())
							nTam ++
							If !(cAlias)->(Eof())
								If nRecCU0 <> (cALias)->RecCU0 .And. nTafRec = (cALias)->REC // Se o recno não for o mesmo, cria novo nível 3 no array
									nY++
									aAdd(aDados[3][nX][4],	{"",""}) // Terceiro nível
								EndIf
							EndIf
						EndDo
					Else						
						(cAlias)->(DbSkip())						
						nTam ++							
					EndIf

					If !(cAlias)->(Eof())
						If nTafRec <> (cALias)->REC // Se o recno não for o mesmo, cria novo nível 2 no array
							nX++
							aAdd(aDados[3],	{"","","",{},{},""})		// Segundo nível
						EndIf
					EndIf
					++nQtdReg
				EndDo
			EndIf

			aDados[4] := nUltRec

			If lLimite .Or. nTam >= nQuebra //Contar(cAlias,"!Eof()")// se chegou no limite , verifica qual o ultimo registro
			
				cAUlt 	:= getNextAlias()
			
				DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQrec),(cAUlt),.F.,.T.) // Obtem o ultimo Recno
				
				DbSelectArea(cAUlt)
				
				(cAUlt)->(DbGoTop())
				
			 	If !(cAUlt)->(Eof())			 	
					aDados[5] := (cAUlt)->REC
				Else				
					aDados[5] := 0						
				EndIf
				
			Else // Se não existe mais registro para processar, assume o valor do ultimo recno.				
				aDados[5] := aDados[4]
			EndIf

			nDados					+= Len(AllTrim(Str(aDados[4])))
			nDados					+= Len(AllTrim(Str(aDados[5])))			
		Else		
			cError 	:= " Tabelas da empresa informada não foram encontradas. "
			nEror	:= 	805
		EndIf	

		//Fecha alias CU0 de outra empresa aberto
		EmpOpenFile("CU0","CU0",1,.F.,AllTrim(cEmpresa),@cModo)
			
	Else
		cError 	:= " O tipo de registro (registryType) não foi informado. "
		nEror	:= 	801		
	EndIf

	If Select(cAlias)  > 0 .And. !Empty(cAlias)
		DbSelectArea(cAlias) 
		DbCloseArea()
	EndIf
	
	If nDados >= 1000000	
		cError 	:= " A quantidade de bytes no arquivo de retorno está acima do limite. "
		nEror	:= 	806
	EndIf

Return aDados

//--------------------------------------------------------------------
/*/{Protheus.doc} getJSONResp()
Retorna a Mensagem JSON padrao de retorno de Processamento de requisições      

@param aDados		Array 			Dados a serem processados
@param cError		Character		Menssagem de erro									
@param nError		Numeric			Código de erro

@return cJSONResponse - String JSON com Retorno da requisição 
Exemplo de retorno com todos os campos usando Json:

	{
	"registryType": "", 
	"statusCode": "", 
	"itens": 	
	[{
		"registryKey": "",
		"statusCode": "",
		"statusDescription": "",
		"validateErrors": 
		[{
			"validateErrorCode": "",
			"validateErrorDetail": ""
		}],
		"streamingErrors": 
		[{
			"streamingErrorCode": "",
			"streamingErrorDetail": ""
		}],
		"registryProtocol": ""
	}],
	"lastRecNo": 0,
	"maxRecNo": 0
	}

***  Somente os atributos do primeiro nível são obrigatórios! ***

@author Eduardo Bego Mantoan
@since 04/07/2017

@version 12.1.18
 
/*/
//-------------------------------------------------------------------
static function getJSONResp(aDados,cError,nError)

	local cJSONResponse	 as character 
	local nY			 as numeric 
	local nX			 as numeric 
	local lError		 as logical
	
	default aDados		:= {}
	
	default cError  	:= ""
	default nError		:= 0
	
	cJSONResponse	 	:= ""
	nY			 		:= 1
	nX			 		:= 1
	lError				:= .f.
	
	// Se não foi possíveel executar a operação e não existe tratamente para o problema, retorna status 802 (Erro Interno do Servidor)	
	If Len(aDados) <> 5 .Or. !Empty(cError) .Or. nError > 0 
	
		If empty(cError)
			cError	:= " Internal error. "
			nError  := 802	
		ElseIf  nError <= 0
			cError	+= " - Internal error. " // Agrega com a informaão já contida na variável pois por alum problema não tatou o código de erro.
			nError  := 802		
		EndIf	

	Else	
		If Len(aDados) = 5
			
			cJSONResponse := '{"registryType": "'+aDados[1]+'",'
			If	!Empty(aDados[2])
				cJSONResponse += '"statusCode": "'+aDados[2]+'",'
			EndIf
			cJSONResponse += '"itens": ['
			If	Len(aDados[3]) > 0 
				For nX := 1 to Len(aDados[3])
					If Len(aDados[3][nX]) = 6 .And. !lError // Tamanho do array deve sempre ser 8, mesmo que informações não existam.
						cJSONResponse += '{'
						If !Empty(aDados[3][nX][1]) // Atributo é obrigatório estar preenchido, caso não esteja, aborta a operação.
							cJSONResponse += '"registryKey": "'+AllTrim(aDados[3][nX][1])+'"'
						Else			
							lError := .T.					
						EndIf
						
						If Empty(aDados[2]) // Só preenche as informações caso o status não tenha sido informado na requisição
						
							If !Empty(aDados[3][nX][2]) .And. !lError
								cJSONResponse += ',"statusCode": "'+AllTrim(aDados[3][nX][2])+'"'
							EndIf
							
							If !Empty(aDados[3][nX][3]) .And. !lError
								cJSONResponse += ',"statusDescription": "'+AllTrim(aDados[3][nX][3])+'"'
							EndIf							
						EndIf
												
						If Len(aDados[3][nX][4]) > 0 .And. !lError
						
							cJSONResponse += ',"validateErrors": ['
							
							For nY := 1 to Len(aDados[3][nX][4])
							
								If Len(aDados[3][nX][4][nY]) = 2
								
									cJSONResponse +='{'
									cJSONResponse += '"validateErrorCode": "'+AllTrim(aDados[3][nX][4][nY][1])+'",'
									cJSONResponse += '"validateErrorDetail": "'+AllTrim(aDados[3][nX][4][nY][2])+'"'
									cJSONResponse +='}'
									
									If nY < Len(aDados[3][nX][4])
										cJSONResponse +=','		
									EndIf									
								EndIf								
							Next nY
							cJSONResponse += ']'
						EndIf	
						
						If Len(aDados[3][nX][5]) > 0 .And. !lError
						
							cJSONResponse += ',"streamingErrors": ['
							
							For nY := 1 to Len(aDados[3][nX][5])								
								
								If Len(aDados[3][nX][5][nY]) = 2
									cJSONResponse +='{'
									cJSONResponse += '"streamingErrorCode": "'+AllTrim(aDados[3][nX][5][nY][1])+'",'
									cJSONResponse += '"streamingErrorDetail": "'+AllTrim(aDados[3][nX][5][nY][2])+'"'
									cJSONResponse +='}'								
									If nY < Len(aDados[3][nX][5])
										cJSONResponse +=','		
									EndIf
								EndIf
							Next nY								
							cJSONResponse += ']'
						EndIf
						
						If !Empty(aDados[3][nX][6]) .And. !lError						
							cJSONResponse += ',"registryProtocol": "'+AllTrim(aDados[3][nX][6])+'"'
						EndIf
						
						cJSONResponse 	+= '}'
						
						If nX < Len(aDados[3])
							cJSONResponse 	+= ','
						EndIf						
					Else
						cError			:= " Internal error. "
						nError  		:= 802	
						cJSONResponse 	:= ""	
						exit
					EndIf					
				Next nX	
			Else
				cError			:= " Internal error. "
				nError  		:= 802	
				cJSONResponse 	:= ""		
			EndIf	
			
			If	Empty(cError)// se não ocoreu nenhum erro durante o pocessamento, continua inserindo informações na variável.
				cJSONResponse += '],'
				If aDados[4] >= 0 .And. aDados[5] >= 0
					cJSONResponse += '"lastRecNo": '+AllTrim(Str(aDados[4]))+','
					cJSONResponse += '"maxRecNo": '+AllTrim(Str(aDados[5]))+' }'
				Else
					cError			:= " Internal error. "
					nError  		:= 802	
					cJSONResponse 	:= ""	
				EndIf
			EndIf			
		Else
			cError			:= " Internal error. "
			nError  		:= 802	
			cJSONResponse 	:= ""	
		EndIf		
	EndIf
	
Return cJSONResponse 

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StatusTaf(cStatus)
Retorna descrição do Status do registro.      

@param cStatus		Character		Status do registro no TAF 											- O

@return cDesc		Character		Descrição do status.

@author Eduardo Bego Mantoan
@since 04/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------


Static Function StatusTaf(cStatus)

	local cDesc 	as character
	
	cDesc			:= "" 	
	
	default cStatus := "NIL"
	
	If cStatus $ "' '|0|1|2|3|4|6|7"
	
		Do Case
	
		Case cStatus $ "' '"
		
			cDesc := "Aguardando validação do TAF"
			
		Case cStatus $ "0"
		
			cDesc := "Registro validado pelo TAF - Aguardando transmissão ao Governo"
			
		Case cStatus $ "1"
		
			cDesc := "Registro com inconsistências encontradas pelo TAF - Não será enviado ao Governo"
			
		Case cStatus $ "2"
		
			cDesc := "Registro já transmitido ao Governo, aguardando retorno"
			
		Case cStatus $ "3"
		
			cDesc := "Registro com inconsistências retornadas pelo Governo"
			
		Case cStatus $ "4"
		
			cDesc := "Registro transmitido e aceito pelo Governo"
			
		Case cStatus $ "6"
		
			cDesc := "Exclusão transmitida ao Governo, aguardando retorno"
			
		Case cStatus $ "7"
		
			cDesc := "Exclusão transmitida e aceita pelo Governo"

		End Case

	EndIf
	
	
	
Return cDesc

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSXSName(cChave,cEmp,cCampo)
Abre SX2 da empresa passada como parâmetro.      

@param cAliasSx		Character		Alias SX (SX2,SX3....) 
@param cChave		Character		Tabela que deseja consultar 	
@param cEmp		    Character		Grupo de empresa	
@param cCampo		Character		Campo cuja a informação será retornada 											

@return cDesc		Character		Descrição do status.

@author Eduardo Bego Mantoan
@since 04/07/2017

@version 12.1.18
 
/*/
//----------------------------------------------------------------------------------------------------------

Static Function GetSXSName(cAliasSx,cChave,cEmp,cCampo)

	local cRetorno 		as character
	
	local cSXMDI 	    as character
    local aArea 		as array

	default cAliasSx	:= ""
	default cEmp		:= ""
	default cChave		:= ""
	default cCampo		:= ""
	
	cRetorno 			:= ""
	
	cSXMDI				:= "SXMDI"
	aArea 				:= GetArea()
	
	If !Empty(cEmp) 
		OpenSxs(,,,,cEmp,cSXMDI,cAliasSx,,.F.)
		
		If Select(cSXMDI) > 0
			If (cSXMDI)->(FieldPos(cCampo)) > 0
				cRetorno := If(dbSeek(cChave),AllTrim((cSXMDI)->&(cCampo)),NIL)	
			EndIf
		EndIf
		
	EndIf
	
	If Select(cSXMDI)  > 0 
		DbSelectArea(cSXMDI) 
		DbCloseArea()
	EndIf	
	
    RestArea(aArea)

Return cRetorno
