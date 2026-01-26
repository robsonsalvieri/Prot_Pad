#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"

Static lConfCaixa := SuperGetMV( "MV_LJCONFF",,.F. ) //Parametro da conferencia de caixa

//-------------------------------------------------------------------
/*/{Protheus.doc} STDStStation
Verifica status da estacao e usuario 

@param   cStation		Estacao
@param   cOperName		Nome do Operador
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] CAIXA_FECHADO					1 // Caixa foi fechado pelo operador
@return  aRet[2] TROCOU_OPERADOR				2 // Houve troca de operador
@return  aRet[3] ULTIMO_OPERADOR				3 // Ultimo operador que usou o sistema e nao fechou caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDStStation( cStation , cOperName )
	
Local 			aRet 			:= Array(3)								// Retorno

Default		cStation		:= 0										// Numero do item na venda
Default		cOperName		:= ""										// Codigo do Item
	
ParamType 0 Var cStation  AS Character	Default ""
ParamType 1 Var cOperName AS Character	Default ""

/*/
	Verifica status da estacao e usuario
/*/     
DbSelectArea("SLI")
DbSetOrder(1)	//LI_FILIAL+LI_ESTACAO+LI_TIPO
If 	DbSeek	( xFilial("SLI")+PadR(cStation,4)+"OPE")

	If Empty(SLI->LI_MSG)
		aRet[CAIXA_FECHADO]		:=  .T.
	Else			
		aRet[CAIXA_FECHADO]		:=  .F.
	EndIf
	
	If AllTrim(SLI->LI_USUARIO) == AllTrim(cOperName)
		aRet[TROCOU_OPERADOR]		:=  .F.
	Else
		aRet[TROCOU_OPERADOR]		:=  .T.
	EndIf
	
	// Ultimo operador que usou o sistema e nao fechou caixa
	aRet[ULTIMO_OPERADOR]		:=  SLI->LI_USUARIO
	
EndIf   
	
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDNumMov
Retorna o ultimo numero de movimento   

@param   aFieldsRet  Campos que devem ser retornados (caracter passar apenas 1 | Array ilimitado)
@author  Varejo
@version P11.8
@since   02/07/2012
@return  uRetorno	Caixa foi fechado pelo operador / Campos solicitados

@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDNumMov( aFieldsRet ) 

Local aStation	:= STBInfoEst(1,.T.,.F.)			// Retorna Informacoes da estacao
Local aArea  	:= GetArea()						// Guarda Area
Local nI			:= 0								//	Variavel de controle
Local lRetCmp		:= .F.								//	Retornara campos
Local aLstCmp		:= {}								//	Guarda Lista de campos validados
Local uRetorno	:= Nil								//	Retorno Indefinido
Local aLstCmpPad	:= {"LW_NUMMOV","LW_DTFECHA"}	//	Lista de Campos padrao para consulta
Local cArq		:= ""								//	Arquivo
Local cIndice		:= ""								//	Indice
Local cFiltro		:= ""								//	Filtro
Local nInd		:= 0								//	Guarda Index
Local cQry		:= ""								//	Query
Local cAlias		:= ""								//	Alias
Local cSGBD		:= ""								//	guarda Gerenciador de banco de dados
Local nPos		:= 0								//	Posicao
Local aEstru		:= {}								//	Estrutura
Local CNumMov		:= ""								//	Movimento

Default aFieldsRet	:= {}							// aFieldsRet Campos que devem ser retornados

ParamType 0 Var aFieldsRet As Array		Default {}

//Caso existam, validar campos de retorno solicitados 
Do Case
	Case ValType(aFieldsRet) == "C"
		If !Empty(aFieldsRet)
			aAdd(aLstCmp,AllTrim(Upper(aFieldsRet)))
		Endif	
	Case ValType(aFieldsRet) == "A"
		If Len(aFieldsRet) > 0
			For nI := 1 to Len(aFieldsRet)
				If ValType(aFieldsRet[nI]) == "C" .AND. !Empty(aFieldsRet[nI])
					aAdd(aLstCmp,AllTrim(Upper(aFieldsRet[nI])))
				Endif
			Next nI 	
		Endif
EndCase

//Verificar os campos solicitados 
If Len(aLstCmp) > 0
	aFieldsRet := {}
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nI := 1 to Len(aLstCmp)
		If Substr(aLstCmp[nI],1,3) # "LW_"
			aLstCmp[nI] := "LW_" + aLstCmp[nI]
		Endif
		//Caso o campo nao tenha sido utilizado ainda, adicionar a lista
		If aScan(aFieldsRet,{|x| x == aLstCmp[nI]}) == 0
			If SX3->(dbSeek(aLstCmp[nI]))
				aAdd(aFieldsRet,aLstCmp[nI])
			Endif
		Endif
	Next nI
	If Len(aFieldsRet) > 0
		lRetCmp := .T.
	Endif
Endif

If (AllTrim(CNumMov) == "" .OR. lRetCmp) 

	#IFDEF TOP
		
		cAlias		:= GetNextAlias()		
	
		aEstru := SLW->(dbStruct())
		cSGBD := Upper(AllTrim(TcGetDB()))
		
		cQry := "SELECT DISTINCT LW_NUMMOV, LW_DTFECHA "
		 
		If lRetCmp
			For nI := 1 to Len(aFieldsRet)
				If aScan(aLstCmpPad,{|x| x == aFieldsRet[nI]}) == 0
					cQry += "," + aFieldsRet[nI] + Space(1)
				Endif
			Next nI
		Endif
		
		cQry += "FROM " + RetSQLName("SLW") + " "
		cQry += "WHERE LW_FILIAL = '" + xFilial("SLW") + "' AND LW_PDV = '" + aStation[4] + "' AND LW_OPERADO = '" + aStation[1] + "' "
		
		Do Case
			Case cSGBD $ "MSSQL|SYBASE"
				cQry += "AND (LEN(LW_DTFECHA) = 0) "
			Case cSGBD $ "MYSQL|POSTGRES|INFORMIX"
				cQry += "AND (LENGTH(LW_DTFECHA) = 0) "
			Case cSGBD $ "DB2|DB2/400|SQLITE"
				cQry += "AND (LENGTH(TRIM(LW_DTFECHA)) = 0) "
			Case cSGBD $ "ORACLE"
				cQry += "AND NVL2(TRIM(LW_DTFECHA),8,0) =  '0' "				
			OtherWise
				cQry += "AND (LEN(LW_DTFECHA) = 0) " 
		EndCase
		
		cQry += "ORDER BY LW_DTFECHA DESC, LW_NUMMOV ASC"	
		cQry := ChangeQuery(cQry)
		
		// Importante: Por utilizar funcao build in de SGBD, nao aplicar o PARSER.	
		dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)
		// Se retorna Campos
		If lRetCmp
			For nI := 1 to (cAlias)->(FCount())
				If (nPos := aScan(aEstru,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(nI)))})) > 0
					If aEstru[nPos][2] # "C"
						TcSetField(cAlias,aEstru[nPos][1],aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
					Endif
				Endif
			Next nI
		Endif
		
		(cAlias)->(dbGoTop())
		
		If !(cAlias)->(Eof())
			CNumMov := (cAlias)->LW_NUMMOV
			If lRetCmp
				uRetorno := Array(Len(aFieldsRet))
				For nI := 1 to Len(aFieldsRet)
					uRetorno[nI] := (cAlias)->&(aFieldsRet[nI])
				Next nI
			Else
				uRetorno := CNumMov
			Endif
		Else
			uRetorno := ""	
		Endif
		
		FechaArqT(cAlias)
		
	#ELSE
	
		//Buscar o movimento em aberto
		dbSelectArea("SLW")
		cArq := CriaTrab(,.F.)
		cIndice := "DTOS(LW_DTABERT)"
		cFiltro := "Empty(LW_DTFECHA) .AND. LW_FILIAL = '" + xFilial("SLW") + "' .AND. LW_PDV = '" + aStation[4] + "' .AND. LW_OPERADO = '" + aStation[1] + "'"
		IndRegua("SLW",cArq,cIndice,"D",cFiltro,"",.F.)
		dbSelectArea("SLW")
		nInd := RetIndex("SLW")
		dbSetIndex(cArq + OrdBagExt())
		SLW->(dbSetOrder(nInd + 1))
		SLW->(dbGoTop())
		If !SLW->(Eof())
			CNumMov := SLW->LW_NUMMOV
			If lRetCmp
				uRetorno := Array(Len(aFieldsRet))
				For nI := 1 to Len(aFieldsRet)
					uRetorno[nI] := SLW->&(aFieldsRet[nI])
				Next nI
			Else
				uRetorno := CNumMov
			Endif	
		Else
			uRetorno := ""				
		Endif
		
		//Retornar ao estado anterior		
	    dbSelectArea("SLW")
	    dbClearFilter()
	    RetIndex("SLW")
	    If File(cArq + OrdBagExt())	
	    	fErase(cArq + OrdBagExt())
	    Endif
	       	
	#ENDIF

	RestArea(aArea)
	
Else
	uRetorno := CNumMov	
Endif

Return uRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} STDOpenCash
Abre o caixa 
@param cCash			Caixa	
@param dDtOpen    	Data de abertura
@param cHrOpen		Hora de abertura 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet Retorna se abriu o caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDOpenCash( cCash	,	dDtOpen	, cHrOpen	)

Local aArea				:= GetArea()				// Guarda area
Local lRet				:= .F.						// Retorno

Default cCash			:= ""						// Caixa	
Default dDtOpen      	:= CtoD("  /  /  ")		// Data de abertura
Default cHrOpen			:= "  :  "					// Hora de abertura


ParamType 0 Var 		cCash 			As Character		Default 	""
ParamType 1 Var 		dDtOpen 		As Date			Default 	CtoD("  /  /  ")
ParamType 2 var  	cHrOpen		As Character		Default 	"  :  "

DbSelectArea("SA6") 
DbSetOrder(2)//A6_FILIAL+A6_NOME
DbGotop()
If MsSeek( xFilial("SA6") + Upper(cUserName)  )

	RecLock("SA6",.F.)

	SA6->A6_DATAABR 	:= dDtOpen
	SA6->A6_HORAABR 	:= cHrOpen
	SA6->A6_DATAFCH 	:= CtoD("  /  /  ")
	SA6->A6_HORAFCH 	:= "  :  "
		
	MsUnLock()
	
	lRet := .T.
	
EndIf

RestArea(aArea) // Restaura area
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDOpenMult
Abre caixas associados (tratamento multi-moeda)
@param cCash			Caixa	
@param dDtOpen    	Data de abertura
@param cHrOpen		Hora de abertura 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet Retorna se abriu os caixas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDOpenMult( cCash	,	dDtOpen	, cHrOpen	)

Local aArea			:= GetArea()				// Guarda area
Local lRet			:= .T.						// Retorno
Local cCodigo			:= ""						// Codigo do caixa principal
Local cAgencia		:= ""						// Agencia  do caixa principal
Local cConta			:= ""						// Conta  do caixa principal

Default cCash		:= ""						// Caixa	
Default dDtOpen    	:= CtoD("  /  /  ")		// Data de abertura
Default cHrOpen		:= "  :  "					// Hora de abertura


ParamType 0 Var 		cCash 			As Character		Default 	""
ParamType 1 Var 		dDtOpen 		As Date			Default 	CtoD("  /  /  ")
ParamType 2 var  	cHrOpen		As Character		Default 	"  :  "

// Abre caixas associados(tratamento multi-moeda) 
xNumCaixa()
cCodigo  	:= SA6->A6_COD				
cAgencia 	:= SA6->A6_AGENCIA			
cConta   	:= SA6->A6_NUMCON  			
      	
DbSelectArea("SA6")
DbSetOrder(1) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If DbSeek( xFilial("SA6") + Upper(cCash)  )
      	
	While !Eof() .And. ( xFilial()+cCodigo ) == ( SA6->A6_FILIAL+SA6->A6_COD )

		If AllTrim(cCodigo + cAgencia + cConta) == AllTrim(SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON)
       	SA6->(dbSkip())
        	Loop
		EndIf
            	
		RecLock("SA6",.F.)
				
		SA6->A6_DATAABR 	:= dDtOpen
		SA6->A6_HORAABR 	:= cHrOpen
		SA6->A6_DATAFCH 	:= CtoD("  /  /  ")
		SA6->A6_HORAFCH 	:= "  :  "
		
		MsUnLock()
       
		SA6->(dbSkip())
            	
    EndDo
         	
EndIf  

RestArea(aArea) // Restaura area
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSaveMov
Grava Movimento  da Abertura de Caixa sendo que:
A cada troca de "PDV , Operador ou , Data" 
o Numero Passa a Ser 1 (Um)
@param aDtHr    		Array de data e hora
@param cCupomIni		Numero do Cupom inicial
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet 	Retorna se realizou a gravacao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDOSaveMov( aDtHr , cCupomIni)

Local aArea		:= GetArea()							// Guarda area
Local aStation	:= {}								 	// Informacoes da estacao  // [1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local lRet			:= .T.									// Retorno
Local cChave		:= ""									// Chave de Pesquisa
Local cNumMov		:= ""									// Numero do Movimento

Local lConfCega	:= SuperGetMV("MV_LJEXAPU",.T.,.F.) == .F.	//Conferencia cega?
Local lDetADMF	:= SuperGetMV("MV_LJDESM",.T.,.F.)				//Conferencia detalhada por adm. financeira?
Local cOpcExib	:= ""												//Grava informacao sobre exibicao da Administradora Financeira

Default aDtHr 		:= 	STBDtCash()	
Default cCupomIni 	:= 	""

ParamType 0 Var   aDtHr 			As Array		Default 	STBDtCash()	
ParamType 1 Var 	cCupomIni 		As Character	Default 	""

//Tratamento especifico para conferencia de caixa
If lConfCaixa
	aStation := STBInfoEst( 1, .T. )

	If !lConfCega .AND. lDetADMF
		cOpcExib := "3" //Detalha a conferencia por administradoras financeiras e não mostra a coluna de valores apurados 
	ElseIf !lConfCega
		cOpcExib := "1" //Não exibe a coluna de valores apurados e não detalha a conferencia por administradoras financeiras
	ElseIf lDetADMF
		cOpcExib := "2" //Exibe a coluna de valores apurados e detalha a conferencia por administradoras financeiras
	Else 
		cOpcExib := "0" //Exibe a coluna de valores apurados e não detalha a conferencia por administradoras financeiras
	EndIf
Else
	aStation := STBInfoEst(	1, .T. )//	, .T. )	
EndIf

//Numero da movimentação da SLW
cNumMov := STDGerMov(aStation, aDtHr)

// Grava SLW
RecLock("SLW", .T.)

Replace	SLW->LW_FILIAL  		With xFilial("SLW")							// Filial
Replace	SLW->LW_PDV     		With aStation[4]								// PDV
Replace	SLW->LW_OPERADO 		With aStation[1]								// Caixa	
Replace	SLW->LW_DTABERT 		With aDtHr[1]									// Data
Replace 	SLW->LW_HRABERT 		With aDtHr[2]									// Hora
Replace	SLW->LW_NUMMOV  		With cNumMov									// Numero do Movimento

If Empty(SerieNfId("SLW",1,"LW_SERIE",dDataBase,LjEspecieNF(),aStation[3]))			// Serie Movimento de Processo de Vendas
	//Se nao achou campo na funcao fiscal faz a gravação manual na tabela SLW
	Replace	SLW->LW_SERIE  		With aStation[3]									// Numero da serie
EndIf

Replace	SLW->LW_NUMINI  		With cCupomIni								// Cupom inicial
Replace 	SLW->LW_ESTACAO 		With aStation[2]								// Estacao
Replace 	SLW->LW_SITUA 		With Replicate("0",TamSX3("LW_SITUA")[1]) // Determina situacao como pendente de transmissao "00"
Replace 	SLW->LW_ORIGEM 		With cModulo									// Modulo
Replace 	SLW->LW_CONFERE 		With "1"										// Tipo de conferencia
Replace 	SLW->LW_OPCEXIB 		With cOpcExib									// Grava informacao sobre exibicao da Administradora Financeira

MsUnlock()

If lConfCaixa

	cChave := SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + DTOS(LW_DTABERT) + LW_ESTACAO + LW_NUMMOV)
	
	If !Empty(cChave) .AND. Len(aDtHr) > 0
	
		STFSLICreate(AllTrim(aStation[1]),"ABR",StrZero(3,2) + cChave,"ABANDONA",.T.,AllTrim(UsrRetName(__cUserID)),aDtHr[1],aDtHr[2])
		
	Endif

EndIf


RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDNumCash
Devolve o Numero do Caixa Ativo 
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  cNumCash 	Retorna numero do caixa Ativo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDNumCash()

Local cNumCash			:= ""					// Numero do caixa
Local aArea				:= GetArea()			// Guarda area

SA6->(dbSetOrder(2))
cNumCash	:=	Iif(SA6->(dbSeek(xFilial( "SA6" )+Upper(cUsername))),SA6->A6_COD,"   ")
SA6->(dbSetOrder(1))


RestArea(aArea)

Return cNumCash


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGerMov
Gera numero de movimento para SLW
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  cNumMov 	Retorna novo numero de movimento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGerMov(aStation, aDtHr)

Local cChave 	 := ""
Local cNumMov    := "" 
Local nTamNumMov := TamSX3("LW_NUMMOV")[1]

Default aStation 	:= {}
Default aDtHr		:= {}

ParamType 0 Var	aStation 	As Array	Default	{}
ParamType 1 Var 	aDtHr 		As Array	Default 	{}

If lConfCaixa

	cChave := xFilial("SLW") + aStation[4] + aStation[1] + aStation[2] + DtoS(aDtHr[1])
	
	DbSelectArea("SLW")
	DbSetOrder(5) //LW_FILIAL + LW_PDV + LW_OPERADO + LW_ESTACAO + DTOS(LW_DTABERT) + LW_NUMMOV
	If DbSeek( cChave )
	
		While !SLW->(Eof()) .AND. SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + LW_ESTACAO + DtoS(LW_DTABERT)) == cChave
			cNumMov := SLW->LW_NUMMOV
			SLW->(DbSkip())
		EndDo
		
		cNumMov := Soma1(AllTrim(cNumMov),nTamNumMov)		
		
	Else
		cNumMov := StrZero( 1, nTamNumMov )   
	EndIf

Else
	
	cChave := xFilial("SLW") + aStation[4] + aStation[1] + DtoS(aDtHr[1])
	
	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	If DbSeek( cChave )
	
		While !SLW->(Eof()) .AND. ( SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + DtoS(LW_DTABERT)) == cChave )
			cNumMov := SLW->LW_NUMMOV
			SLW->(DbSkip())
		EndDo
		
		cNumMov := Soma1(AllTrim(cNumMov),TamSX3("LW_NUMMOV")[1])
		
	Else
		cNumMov := StrZero( 1, nTamNumMov ) 	   
	EndIf
	
EndIf

Return cNumMov


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGtLstMov
Pega data do ultimo fechamento do caixa
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  dDtLastMov 	Retorna data do fechamento do caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGtLstMov()

Local dDtLastMov := CtoD("  /  /  ")		//Pega data do ultimo fechamento antes de abrir

xNumCaixa()

dDtLastMov		:= SA6->A6_DATAFCH

Return dDtLastMov
