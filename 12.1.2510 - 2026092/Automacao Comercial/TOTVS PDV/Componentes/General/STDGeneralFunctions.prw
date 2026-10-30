#Include 'Protheus.ch'
#INCLUDE "AUTODEF.CH"
#INCLUDE "STDGENERALFUNCTIONS.CH"

/*/

	Fonte contendo funcoes genericas utilizadas pelo Totvs PDV. 

/*/


//-------------------------------------------------------------------
/*{Protheus.doc} STDExistChav
Funcao semelhante a ExistChav, porem esta ao inves de interagir com o usuario atraves da janela do help, o faz via componente de mensagem.

@param
@author  Varejo
@version P11.8
@since   17/07/2013
@return  lRet			Retorno .T. se nao houver registro com a mesma chave unica na base.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDExistChav(cAliasArq,cKey,nInd,cHelp,nFAtuCli)
Local aArea	:= GetArea()
Local lRet	:= .T.

DEFAULT cAliasArq 	:= "SA1"
DEFAULT cKey		:= ""
DEFAULT nInd		:= 1
DEFAULT cHelp		:= "Já existe registro com esta informação."
DEFAULT nFAtuCli	:= 2	// Força a atualizacao do cliente

DbSelectArea(cAliasArq)
(cAliasArq)->(DbSetOrder(nInd))
If DbSeek(xFilial(cAliasArq)+cKey)
	lRet := .F.
EndIf

If !lRet .AND. nFAtuCli == 2
	STFMessage(ProcName(),"STOP",cHelp)
	STFShowMessage(ProcName())
Else
	STFCleanInterfaceMessage()
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDUF
Funcao que retorna um array com as unidades federativas.

@param
@author  Varejo
@version P11.8
@since   17/07/2013
@return  lRet			Retorno .T. se nao houver registro com a mesma chave unica na base.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDUF()
Local aArea 	:= GetArea()											// Area atual
Local lEndFis   := SuperGetMv("MV_SPEDEND",, .F.)						// Se estiver como F refere-se ao endereço de Cobrança se estiver T ao endereço de Entrega.
Local cEstSM0	:= UPPER(IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)) // Indica qual estado sera considerado, se o de entrega ou cobrança
Local aRet  	:= {{"",{}}}											// Array Default, array de retorno

DbSelectArea("CC2")
CC2->(DbSetOrder(1))
DbSeek(xFilial("CC2"))

// Estado atual do sistema baseado no parametro MV_SPEDEND
aAdd(aRet, {cEstSM0,{}})

While CC2->CC2_FILIAL == xFilial("CC2") .AND. !EOF()

	If Alltrim(CC2->CC2_EST) <> AllTrim(cEstSM0)
		aAdd(aRet,{CC2->CC2_EST,{}})
		nPosEst := Len(aRet)
	Else
		// O estado do atual do sistema sempre será 2.
		nPosEst := 2
	EndIf 
	
	While CC2->CC2_FILIAL + CC2_EST == xFilial("CC2") + aRet[nPosEst][1] .AND. !EOF()
		aAdd(aRet[nPosEst][2],{CC2_CODMUN,CC2_MUN})
		CC2->(DbSkip())
	End

End

RestArea(aArea)

Return aRet
//-------------------------------------------------------------------
/*{Protheus.doc} STFIsFiscalPrint
Seta se utiliza impressora fiscal na configuração e retorna se pode entrar no sistema

@param
@author  Varejo
@version P11.8
@since   17/07/2013
@return  lRet			Retorna se pode entrar no sistema
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFIsFiscalPrint()

Local lRet 			:= .F.							// Retorna se pode entrar no sistema
Local cModelPrint		:= STFGetStation("IMPFISC")	// Modelo impressora estação
Local aDados			:= {}							// Retorno evento

/*
	Utiliza impressora fiscal se:
	1 - Brasil
	2 - Usuário fiscal
	3 - Modelo da impressora cadastrada for fiscal
*/

If cPaisLoc == "BRA"

	aDados := STFFireEvent( 			ProcName(0)				   		,; 		// Nome do processo
										"STExistEquip"					,;		// Nome do evento
										{EQUIP_IMPFISCAL					,;		// 01 - Tipo
										cModelPrint						,; 		// 02 - Modelo
										Nil		 							,;		// lCommuOk
										.F.		 							})		// Define se abre comunicação
	
	/*
		Impressora Fiscal
	*/
	If Len(aDados) > 0 .AND. aDados[1]
		If STFProfile(3)[1]
			STFSetCfg( "lUseECF" , .T. )
			lRet := .T.
		Else
			HELP(" ",1,"FRT002")			// "Usuário 1 para usar impressora fiscal.", "Atenção"
			lRet := .F.	
		EndIf
	/*
		Impressora nao fiscal
	*/		
	Else
		If STFProfile(3)[1]
			HELP(" ",1,STR0001)			// "Usuário fiscal não pode utilizar impressora não fiscal.", "Atenção"
			lRet := .F.	
		Else
			STFSetCfg( "lUseECF" , .F. )
			lRet := .T.
		EndIf
	EndIf
Else
	STFSetCfg( "lUseECF" , .F. )
	lRet := .T.	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} STDFisGetEnd
Retorna a estrutura do endereco passado

@param
@author  Varejo
@version P11.8
@since   08/01/2014
@return  lRet			Retorna a estrutura do endereco passado
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STDFisGetEnd(cEndereco, cUF)
Local nVirgula    := Rat(",",cEndereco) // Insere a Virgula antes do Endereço
Local cNumero     := ""	// Caracter do Numero
Local nNumero     := 0	// Numero
Local lEndNfe     := If(FunName()=="SPEDNFE", .T., .F.) // Se fo SPEDNFE
Local cEnderec    := ""	// Endereço
Local cCompl      := ""	// Complemento
Local cComplemen  := ""	// Complemento auxiliar
Local lExterior   := .F. // Exterior
Local cEndAlte    := ""	// Endereço alterado

Default cUF       := "" // UF
Default cEndereco := ""	// Endereço recebido

If ExistBlock('FISATEND')
	cEndAlte := ExecBlock('FISATEND',.F.,.F.,{ cEndereco, cUF })
	If !Empty(cEndAlte)
		cEndereco := cEndAlte
	EndIf		
EndIf	
lExterior   := (cUF == "EX")

cNumero     := If(!lExterior, AllTrim(SubStr(cEndereco,nVirgula+1)), Left(cEndereco, nVirgula-1))
nNumero     := NoRound(Val(cNumero),3)
cCompl      := If(!lExterior, AllTrim(SubStr(cEndereco,nVirgula+1)), Left(cEndereco, nVirgula-1))
cComplemen  := ""

If lEndNfe
	If nNumero != 0
		If !lExterior
			cEnderec := PadR(SubStr(cEndereco, 1, nVirgula-1), 60)
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nVirgula+1)), 60)
		EndIf
	Else
		cEnderec := PadR(cEndereco, 60)
	EndIf
Else
	If nNumero != 0
		If !lExterior
			cEnderec := PadR(SubStr(cEndereco,1,nVirgula-1),34)
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nVirgula+1)), 34)
		EndIf
	Else
		cEnderec := PadR(SubStr(cEndereco,1,nVirgula-1),34)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando nao ha virgula no endereco procura-se o caracter branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nVirgula == 0 )
	nVirgula 	:= Rat(" ",AllTrim(cEndereco))
	cEnderec	:= RTrim(cEndereco)
	cCompl		:= ""	//NAO TEM COMO PEGAR O COMPLEMENTO, JAH QUE UTILIZO O ULTIMO ESPACO A DIREITO PARA SEPARAR O LOGRADOURO DO NUMERO.
	cNumero     := AllTrim(SubStr(cEndereco,nVirgula+1))
	nNumero		:= Val(cNumero)
	If lEndNfe == .F.
		lEnderec	:= PadR(IIf(nNumero!=0,SubStr(cEndereco,1,nVirgula-1),cEndereco),34)
    Else
    	lEnderec	:= PadR(IIf(nNumero!=0,SubStr(cEndereco,1,nVirgula-1),cEndereco),60)
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o numero é numerico, obtem-se o complemento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNumero <> 0 
	If At(" ",AllTrim(cCompl)) > 0
		cComplemen := Alltrim(SubStr(cCompl,At(" ",AllTrim(cCompl))+1))
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o numero caracter extrai o complemmento.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumero := StrTran(cNumero,cComplemen,"")

Return({cEnderec,nNumero,cNumero,cComplemen})



//-------------------------------------------------------------------
/*{Protheus.doc} STDFisGetTel
Retorna a estrutura do telefone passado

@param
@author  Varejo
@version P11.8
@since   08/01/2014
@return  lRet			Retorna a estrutura do telefone passado
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDFisGetTel(cTelefone,cArea,cPais)

Local nX      := 0 	// Variável pra Loop
Local nCount  := 0  	// Contador
Local cAux    := ""	// Auxiliar
Local cNumero := ""	// Numero
Local lFone   := .T. // Lógica do Fone
Local lArea   := .F.	// Lógica da Area
Local lPais   := .F. // Lógica do País

DEFAULT cArea := ""  // Area
DEFAULT cPais := ""  // Pais
DEFAULT cTelefone := "" 	// Telefone


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o que deve ser extraido do numero do telefone        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lArea := Empty(cArea)
lPais := Empty(cPais) .And. lArea
cTelefone := AllTrim(cTelefone)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtenho o codigo de pais/area e telefone do Telefone          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := Len(cTelefone) To 1 Step -1
    nCount++
	cAux := SubStr(cTelefone,nX,1)
	If cAux >= "0" .And. cAux <= "9"
		Do Case
		Case lFone
			cNumero := cAux + cNumero
		Case lArea
			cArea := cAux + cArea
		Case lPais
			cPais := cAux + cPais
		EndCase
		If (nCount == 9)
			lFone := .F.
		Endif
	Else
		Do Case
		Case lFone
			If Len(cNumero) > 5
				lFone := .F.
			EndIf
		Case lArea
			If !Empty(cArea)
				lArea := .F.
			EndIf
		EndCase
	EndIf
Next nX

Return({Val(cPais),Val(cArea),Val(cNumero)})



//-------------------------------------------------------------------
/*{Protheus.doc} STDAsc2Hex
Converte um texto com caracteres ASCII em texto com carac-
teres HEXA.

@param
@author  Varejo
@version P11.8
@since   10/01/2014
@return  lRet			
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDAsc2Hex(cString)

Local nX     	:= 1  // Contador
Local cResult	:= "" // Resulado
Local nVal		:= 0 // Valor

Default cString := ""

For nX := 1 to Len(cString)
	nVal 	:= Asc(SubStr(cString,nX,1))
	cResult += STDDec2Hex(nVal)
Next nX     

cResult := Lower(cResult)

Return(cResult)


//-------------------------------------------------------------------
/*{Protheus.doc} STDDec2Hex
Converte um numero decimal ate' 255 para hexadecimal

@param
@author  Varejo
@version P11.8
@since   10/01/2014
@return  lRet			
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDDec2Hex(nVal)
Local cString := "0123456789ABCDEF"

Default nVal := ""

Return(Substr(cString,Int(nVal/16)+1,1)+Substr(cString,nVal-(Int(nVal/16)*16)+1,1))


//-------------------------------------------------------------------
/*/{Protheus.doc} STDQueryDB
Executa query no banco de dados da Retaguarda.
@param   	aFields			- Campos para montagem da Query.
@param   	aTables			- Tabelas para montagem da Query.
@param   	cWhere			- Cláusula "WHERE" para montagem da Query.
@param   	cOrderBy		- Cláusula "ORDER BY" para montagem da Query.
@param   	nLimitRegs		- Quantidade de registros que se deseja limitar a pesquisa da query.
@author  	Varejo
@version 	P11.8
@since   	11/05/2015
@return		aRet			- Array com o resultado da query executada.		  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDQueryDB( aFields, aTables, cWhere, cOrderBy, nLimitRegs )
Local aRet		  	:= {}
Local aArea	  		:= GetArea()
Local cAliasQry		:= ""
Local cQuery 		:= ""
Local cEndQuery 	:= ""
Local nY          	:= 0
Local nX          	:= 1
Local cFields 		:= ""
Local cTables 		:= ""
Local lExecQuery 	:= .T.
Local cSGBD			:= AllTrim(Upper(TcGetDb())) //Tipo do banco de dados em uso

Default aFields  	:= {}
Default aTables 	:= {}
Default cWhere 		:= ""
Default cOrderBy 	:= ""
Default nLimitRegs 	:= 0

For nX:=1 To Len(aFields)
	cFields += aFields[nX]+","
Next nX
cFields := Left(cFields,Len(cFields)-1) //Retira a última vírgula

For nX:=1 To Len(aTables)
	cTables += RetSQLName(aTables[nX]) + " " + aTables[nX] + ","
Next nX
cTables := Left(cTables,Len(cTables)-1) //Retira a última vírgula

If Empty(cFields) .Or. Empty(cTables) .Or. Empty(cWhere)
	lExecQuery := .F.
EndIf

If lExecQuery
	
	cAliasQry := GetNextAlias()
	
	If !Empty(cOrderBy)
		cOrderBy := " ORDER BY " + cOrderBy
	EndIf
	
	//Tratamento para trazer uma quantidade limitada de registros
	If nLimitRegs > 0
		
		If "MSSQL" $ cSGBD //Microsoft SQL Server
			cFields := " TOP " + AllTrim(Str(nLimitRegs)) + " " + cFields			
		ElseIf "ORACLE" $ cSGBD //Oracle 
			cWhere += " AND ROWNUM <= " + AllTrim(Str(nLimitRegs))
		ElseIf "DB2" $ cSGBD //DB2
			cEndQuery := "FETCH FIRST " + AllTrim(Str(nLimitRegs)) + " ROWS ONLY"
		ElseIf "INFORMIX" $ cSGBD //Informix
			cFields := "FIRST " + AllTrim(Str(nLimitRegs)) + " " + cFields
		ElseIf "SYBASE" $ cSGBD //Sybase
			cFields := " TOP " + AllTrim(Str(nLimitRegs)) + " " + cFields
		ElseIf "POSTGRES" $ cSGBD //PostgreSQL
			cEndQuery := " LIMIT " + AllTrim(Str(nLimitRegs))
		ElseIf "MYSQL" $ cSGBD //MySQL
			cEndQuery := " LIMIT " + AllTrim(Str(nLimitRegs))
		EndIf
		
	EndIf
	
	//Montagem da query
	cQuery := "SELECT " + cFields
	cQuery += "  FROM " + cTables
	cQuery += " WHERE " + cWhere
	cQuery += cOrderBy
	cQuery += cEndQuery
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)    
	
	nX := 0
	While (cAliasQry)->(!EOF())
		aAdd(aRet,{})
		nX++
		
		For nY := 1 To Len(aFields)
			aAdd(aRet[nX], &((cAliasQry)->(aFields[nY])))
		Next nY
		
		(cAliasQry)->(DbSkip())
	End
	
	(cAliasQry)->(DbCloseArea())
	 
EndIf

RestArea(aArea)

Return aRet
