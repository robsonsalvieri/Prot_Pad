#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA766.CH" // TECA765.CH

Static cTmpAlias := ""
Static oGSTmpTb

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA766
Integração por Lote - FindMe
@sample TECA766()
@since	11/03/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Function TECA766()    
 
	Local cPerg := "TECA766"   
	Local aArea := GetArea()

	Private cCadastro := STR0001 //"Monitor de Integração por Lote com o FindMe"

	DbSelectArea("CN9")
	CN9->(DbSetOrder(1)) // CN9_FILIAL+CN9_NUMERO

	DbselectArea("TFJ") 
	TFJ->(DbSetOrder(1)) // TFJ_FILIAL+TFJ_CODIGO                                                                                                                                                                                                                                                                                   

	DbselectArea("TFF")
	TFF->(DbSetOrder(1)) // TFF_FILIAL+TFF_COD                                                                                                                                               	

	DbselectArea("TFL")
	TFL->(DbSetOrder(1)) // TFL_FILIAL+TFL_CODIGO                                                                                                                                           

	If Pergunte(cPerg,.T.)
		Processa( {|| (AT766Brow(cPerg)) }, STR0005, STR0006,.F.) //"Aguarde..."##"Processando a requisição solicitada..."
	Endif	

	RestArea(aArea)


Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT766Brow
Definicao do Objeto Browse
@since	23/08/2022
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT766Brow(cPerg)

	Local oBrowse  := Nil
	Local aStru    := AT766aStru()
	Local aColumns := {}
	Local aSeek    := {}

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetFieldMark("OK") 
	oBrowse:SetAllMark( { || oBrowse:AllMark() } )      

	At766Cria(@oBrowse)

	oBrowse:SetMenuDef("")
	oBrowse:SetDescription(OEmToAnsi(cCadastro))   

	oBrowse:AddButton(STR0007,{||Pergunte(cPerg,.T.),AT766AtBrw(@oBrowse)}) // Parametros
	oBrowse:AddButton(STR0034,{||AT766dInMn(),AT766AtBrw(@oBrowse)}) // Integrar
	oBrowse:AddButton(STR0008,{||CloseBrowse()}) // Sair

	aColumns := AT766aCols(aStru)  
	
	oBrowse:SetColumns(aColumns)

	aAdd(aSeek, {TxDadosCpo('CN9_FILIAL')[1],{{'','C',TamSX3('CN9_FILIAL')[1],TamSX3('CN9_FILIAL')[2],TxDadosCpo('CN9_FILIAL')[1],PesqPict('CN9','CN9_FILIAL'),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo('CN9_NUMERO')[1],{{'','C',TamSX3('CN9_NUMERO')[1],TamSX3('CN9_NUMERO')[2],TxDadosCpo('CN9_NUMERO')[1],PesqPict('CN9','CN9_NUMERO'),NIL}},2, .T.})

	oBrowse:SetSeek(.T., aSeek)
	oBrowse:SetParam({||Pergunte(cPerg,.T.),AT766AtBrw(@oBrowse)})

	oBrowse:DisableConfig()

	oBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT766AtBrw
Criacao do Objeto Browse
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Function AT766AtBrw(oBrw)

	// Se a opção Dados automaticos meu posto == sim

	(At766Alias())->(DbCloseArea())
	At766Cria(@oBrw)
	oBrw:Refresh(.T.)
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At766Alias
Retorna alias uso do browse
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At766Alias(cSetValue)

	If VALTYPE(cSetValue) == 'C'
		cTmpAlias := cSetValue
	EndIf

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At766Alias
Retorna query uso do browse
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At766QryGen(aTmpStruct)

	Local cQuery   	:= " " 
	Local lFindMe	:= TFF->(ColumnPos("TFF_FINDME")) > 0 

	MakeSqlExp("TECA766") 

	cQuery += " SELECT  DISTINCT '' OK, CN9_FILIAL,CN9_NUMERO,CN9_REVISA,TFJ_CODIGO,"
	cQuery += " TFJ_CODENT,TFJ_LOJA, A1_NOME" 
	cQuery += " FROM "+ RetSqlName('CN9') + " CN9 "
	cQuery += " INNER JOIN "+ RetSqlName('TFJ') + " TFJ "
	cQuery += " 	ON TFJ.TFJ_FILIAL = CN9.CN9_FILIAL "
	cQuery += " 	AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
	If !Empty(MV_PAR03)
		cQuery += " 	AND "+MV_PAR03+"  "
	EndIf
	cQuery += " 	AND TFJ_FINDME <>'1' "
	cQuery += " 	AND TFJ.D_E_L_E_T_=' ' "  
	cQuery += " INNER JOIN "+ RetSqlName('TFL') + " TFL "
	cQuery += " 	ON TFL.TFL_FILIAL = TFJ.TFJ_FILIAL "
	cQuery += " 	AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
	cQuery += " 	AND TFL.D_E_L_E_T_= ' ' "
	cQuery += " INNER JOIN "+ RetSqlName('TFF') + " TFF "
	cQuery += " 	ON TFF.TFF_FILIAL = TFJ.TFJ_FILIAL " 
	cQuery += "     AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	If lFindMe
		cQuery += "	AND TFF.TFF_FINDME = '1' " 
	EndIf
	cQuery += " 	AND TFF.D_E_L_E_T_=' ' "
	cQuery += " INNER JOIN "+ RetSqlName('SA1') + " SA1 "
	cQuery += " 	ON SA1.A1_COD = TFJ.TFJ_CODENT "
	cQuery += " 	AND SA1.A1_LOJA = TFJ_LOJA " 
	cQuery += " 	AND SA1.D_E_L_E_T_=' ' "
	cQuery += " WHERE CN9_SITUAC='05'  " 
	If !Empty(MV_PAR01) 
		cQuery += "		AND "+MV_PAR01+" " 
	EndIf
	If !Empty(MV_PAR02)
		cQuery += " 	AND "+MV_PAR02+" "
	EndIf
	If !Empty(MV_PAR04) .AND. !Empty(MV_PAR05)
		cQuery += " 	AND CN9_DTINIC BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " 
	ElseIf !Empty(MV_PAR04) .AND. Empty(MV_PAR05)
		cQuery += " 	AND CN9_DTINIC = '"+DTOS(MV_PAR04)+"' " 
	ElseIf Empty(MV_PAR04) .AND. !Empty(MV_PAR05)
		cQuery += " 	AND CN9_DTINIC = '"+DTOS(MV_PAR05)+"' " 	
	EndIf
	cQuery += " 	AND CN9.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY CN9_FILIAL,CN9_NUMERO " 
	 
Return cQuery   


//------------------------------------------------------------------------------
/*/{Protheus.doc} At766Cria
Criacao tabela temporaria
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At766Cria(oBrw)

Local cAliasTmp  := IIF( EMPTY(At766Alias()) , GetNextAlias() , At766Alias())
Local aTmpStruct := AT766aStru()
Local aInsert    := {}
Local aIdx       := {}
Local nX         := 0
Local cAliasAux  := GetNextAlias()
Local lRet       := .F.
Local xValue
Local nAtual     := 1
Local cOperado   := ""
Local lOK        := .F.

If VALTYPE(oGSTmpTb) == 'O'
	oGSTmpTb:Close()
	TecDestroy(oGSTmpTb)
EndIf

//Cria indices para a tabela temporária 
Aadd(aIdx, {"I1",{ 'CN9_FILIAL' },{ 'CN9_NUMERO' }})

oGSTmpTb := GSTmpTable():New(cAliasTmp,aTmpStruct,aIdx)
If oGSTmpTb:CreateTMPTable()

	Count to nTotal
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,At766QryGen(aTmpStruct)),cAliasAux, .F., .T.)
	ProcRegua(nTotal)

	While (cAliasAux)->(!EOF())

		lOk := .T.
		aInsert := {}

		If lOK			
			For nX := 1 To LEN(aTmpStruct)
				xValue := (&("(cAliasAux)->" + aTmpStruct[nX][1]))

				Aadd(aInsert, {aTmpStruct[nX][1], xValue })

				IncProc(STR0013 + cValToChar(nAtual) + STR0014 + cOperado  )
			Next nX

			If ( lRet := ( oGSTmpTb:Insert(aInsert) .AND. oGSTmpTb:Commit() ) )
				(cAliasAux)->(DbSkip())
				lOK := .F.

			EndIf
		Endif	
		nAtual++			

	EndDo

	If ( Select( cAliasAux ) > 0 )
		DbSelectArea(cAliasAux)
		(cAliasAux)->(DbCloseArea())
		cAliasAux := ""
	EndIf
EndIf

At766Alias(oGSTmpTb:cAliasTmp)
( At766Alias() )->(DbGoTop())
oBrw:SetAlias((At766Alias()))

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT766aStru
Definicao dos campos uso do browse
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT766aStru()

    Local aRet     := {}

	Aadd(aRet, At766Field("OK")) 			// OK
	Aadd(aRet, At766Field("CN9_FILIAL")) 	// FILIAL
	Aadd(aRet, At766Field("CN9_NUMERO")) 	// CONTRATO 
	Aadd(aRet, At766Field("CN9_REVISA")) 	// REVISÃO
	Aadd(aRet, At766Field("TFJ_CODIGO")) 	// ORÇAMENTO 
	Aadd(aRet, At766Field("TFJ_CODENT")) 	// CLIENTE
	Aadd(aRet, At766Field("TFJ_LOJA"))		// LOJA
	Aadd(aRet, At766Field("A1_NOME"))		// RAZÃO SOCIAL

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At766Field
Definicao das colunas uso do browse
@since  11/02/2024
@author djalma.mathias
@return Array Campo, Tipo, Tamanho, Decimais
/*/
//------------------------------------------------------------------------------
Function At766Field(cField)

	Local aRet   := {}
	Local aField := {} 


	// Altera tipo/tamanho do campo  
	If cField == "OK"
		aField := {cField, "C", 1, 0}		 
	Else
		aRet   := FwTamSx3(cField)
		aField := {cField, aRet[3], aRet[1], aRet[2]}	     
	Endif

Return aField 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT766aCols
Definicao das colunas uso do browse
@since	11/02/2024
@author djalma.mathias
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT766aCols(aStru)

	Local nY       := 0
	Local nTam     := 0
	Local aColumns := {}
	Local cAlias   := At766Alias()  
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	For nY := 1 To Len(aStru) 
		cField := aStru[nY][1]
		If !cField $ "OK"
			cMasc  := X3Picture(cField) 

			cTitle := RetTitle(cField)

			AAdd(aColumns,FWBrwColumn():New()) 
			nTam := Len(aColumns)

			aColumns[nTam]:SetData(&("{||Rtrim("+(cAlias)+"->"+(cField)+")}"))
			aColumns[nTam]:SetTitle(cTitle)
			aColumns[nTam]:SetSize(aStru[nY][3])
			aColumns[nTam]:SetDecimal(aStru[nY][4]) 
			aColumns[nTam]:SetPicture(cMasc)  
		EndIf

	Next nY 

Return aColumns


//------------------------------------------------------------------------------
/*/{Protheus.doc} At766Findme

@since	14/03/2024
@author	Djalma.Mathias
@description Integracao Find-me
/*/
//------------------------------------------------------------------------------
Static Function At766Findme() //  cCodCLi, cLoja, cCodOrc
Local oGsFindMe	:= GsFindMe():new()
Local lAuth		:= oGsFindMe:lAuth  
Local cDefReg	:= GetMV("MV_DEFREG", .F., " | | ")
Local aPostCli	:= {} 
Local aLogs		:= {}
Local aLocais	:= {}
Local nX		:= 0 
Local nY		:= 0
Local aRegiao 	:= {}
Local lRegiao   := .T.
Local cQuery	:= ""
Local cAliasUsr := GetNextAlias()
Local aUserRet	:= {}

Default cCodOrc := ""

(cTmpAlias)->(dBGoTop())


While !(cTmpAlias)->(Eof())

	If !Empty((cTmpAlias)->OK) 

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If  lAuth .And. SA1->(DbSeek(xfilial("SA1")+(cTmpAlias)->TFJ_CODENT+(cTmpAlias)->TFJ_LOJA)) 
			If oGsFindMe:canAddClient((cTmpAlias)->TFJ_CODENT, xfilial("SA1"), (cTmpAlias)->TFJ_LOJA) 
				AADD(aPostCli,{"codigo",SA1->A1_COD})
				AADD(aPostCli,{"filial",SA1->A1_FILIAL})
				AADD(aPostCli,{"loja",SA1->A1_LOJA})
				AADD(aPostCli,{"descricao",SA1->A1_NOME})
				AADD(aPostCli,{"name",SA1->A1_NREDUZ}) 
				AADD(aLogs,aPostCli)

				If oGsFindMe:addClient(aPostCli) 
					// Geracao dos Logs
					TECLOGFME(aLogs)
				EndIf
			EndIf 

			aLogs 	:= {}
			aLocais := localFindMe((cTmpAlias)->TFJ_CODIGO,oGsFindMe) //   cCodOrc  

			if Len(aLocais) > 0
				for nX := 1 to Len(aLocais)
					if !Empty(aLocais[nX][18])
						aRegiao := regFindMe(aLocais[nX][18],aLocais[nX][8])
						lRegiao := oGsFindMe:addRegions(aRegiao[1],aRegiao[2],aRegiao[3],{aRegiao[4],aRegiao[5]})
						if lRegiao
							aRegiao := {aRegiao[1],aRegiao[3],aRegiao[2]} 
						EndIf
					else
						//região padrão (passar via parametro)
						aRegiao := Separa(cDefReg,"|") //{"000055","00","0101"}
					EndIf
					// Incluindo local (se ele já não estiver integrado)
					oGsFindMe:addLocation(;
						aPostCli,;
						{;
							aLocais[nX][1],;	//ABS_LOCAL
							aLocais[nX][2],;	//ABS_FILIAL
							aLocais[nX][3],;	//ABS_LOJA
							aLocais[nX][4],;	//ABS_ESTADO
							aLocais[nX][5],;	//ABS_MUNIC
						},;
						/* região */;
						aRegiao,;
						{;
							aLocais[nX][6],;	//ABS_DESCRI - 01
							aLocais[nX][7],;	//ABS_END    - 02
							aLocais[nX][8],;	//TIMEZONE   - 03
							aLocais[nX][9],;	//ABS_LATITU - 04
							aLocais[nX][10],;	//ABS_LONGIT - 05
							aLocais[nX][11],;   //RADIUS     - 06
							aLocais[nX][12],;	//AUTOFINISHRADIUS - 07
							aLocais[nX][13],;	//GEOLOCATIONADJUSTMENT - 08
							aLocais[nX][14],;	//PASSWORD	 - 09
							aLocais[nX][15],;	//COUNTERPASSWORD - 10
							aLocais[nX][16],;	//SECURITYPHONE - 11
						})
						// Integrando os postos do local
						If Len(aLocais[nX][17]) > 0
							For nY := 1 to Len(aLocais[nX][17])
								oGsFindMe:addStation(;
									/*cLocCod*/ aLocais[nX][1],;  	 //Código do local
									/*cFilInt*/ aLocais[nX][2],;	 //Filial do local
									/*cLojInt*/ aLocais[nX][3],; 	 //Loja do orçamento
									/*cFilPosto*/ aLocais[nX][17][nY][2],;	 //Filial do posto
									/*cLojPosto*/ aLocais[nX][17][nY][3],;	 //Loja do orçamento
									/*cCodPosto*/ aLocais[nX][17][nY][1],;	 //código do posto
									/*cNomePosto*/ aLocais[nX][17][nY][6],;  //descrição do posto (descrição tff)
									/*nOptype*/	, 02;
								)
							Next nY
						EndIf
				Next nX
			EndIf

		EndIf 

		// TFJ (ORÇAMENTO) - TFL (LOCAL) - TFF (POSTO)
		
		cQuery:= " SELECT DISTINCT TFF.TFF_COD, TFF.TFF_FILIAL, ABB_CODTEC "
		cQuery+= " FROM  "+ RetSqlName('TFL') + " TFL "
		cQuery+= " INNER JOIN "+ RetSqlName('TFF') + " TFF "
		cQuery+= " 		ON TFF.TFF_FILIAL = '"+(cTmpAlias)->CN9_FILIAL+"' "
		cQuery+= " 		AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
		cQuery+= " 		AND TFF.TFF_FINDME IN ('1', ' ') "
		cQuery+= " 		AND TFF.D_E_L_E_T_=' ' "
		cQuery+= " INNER JOIN "+ RetSqlName('ABQ') + " ABQ "
		cQuery+= " 		ON ABQ.ABQ_CODTFF = TFF.TFF_COD "
		cQuery+= " 		AND ABQ.D_E_L_E_T_=' ' "
		cQuery+= " INNER JOIN "+ RetSqlName('ABB') + " ABB "
		cQuery+= " 		ON ABB.ABB_FILIAL = TFF.TFF_FILIAL "
		cQuery+= " 		AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT + ABQ.ABQ_ITEM + ABQ.ABQ_ORIGEM "
		cQuery+= " 		AND ABB.D_E_L_E_T_ = ' ' "
		cQuery+= " WHERE TFL.TFL_FILIAL = '"+(cTmpAlias)->CN9_FILIAL+"' "
		cQuery+= " 		AND TFL.TFL_CODPAI = '"+(cTmpAlias)->TFJ_CODIGO+"' "
		cQuery+= " 		AND TFL.D_E_L_E_T_= ' ' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasUsr, .F., .T.) 

		While (cAliasUsr)->(!EOF())

			aUserRet	:= intFindMe((cAliasUsr)->ABB_CODTEC)

			IF !EMPTY(aUserRet)

				oGsFindMe:newUser((cAliasUsr)->TFF_COD,aUserRet)  

			ENDIF 

			(cAliasUsr)->(dBSkip())

		EndDo

		(cAliasUsr)->(dBCloseArea())

		TFJ->(DBSETORDER(1))
		TFJ->(DBSEEK((cTmpAlias)->CN9_FILIAL+(cTmpAlias)->TFJ_CODIGO))
		TFJ->(MsRLock())	
		TFJ->TFJ_FINDME := '1'
		TFJ->(MsUnLock())

	EndIf 

	(cTmpAlias)->(dBSkip())

EndDo


Return  

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECLOGFME
Log de gravacao da Findme
@return Nil
@author Vitor kwon
@since 06/12/2022
/*/
//------------------------------------------------------------------------------------------

Static Function TECLOGFME(aDados)

Local cLog     := ""
Local cTitle   := STR0027 //"Resumo de integracao FIND-ME"
Local lVScroll := .F.
Local lHScroll := .F.
Local lWrdWrap := .F.
Local lCancel  := .F.
Local nX       :=  0
Default aDados   := {}

    For nX := 1 to len(aDados)

        If nX == 1
            cLog := STR0028  +CRLF  //"Log de Integração : "
            cLog += " "+CRLF
        Endif

        cLog += STR0029 +aDados[nX][4][2]+STR0030+CRLF // O cliente#"foi integrado com sucesso"
        cLog += STR0031+cValtochar(Date())+STR0032+time()+" "+CRLF //"A inclusao ocorreu no dia"#as#
        cLog += "" +CRLF

        If nX == len(aDados)
            cLog += STR0033 +CRLF // "Fim do processamento" 
        Endif

    Next nX

    AtShowLog(cLog,cTitle,lVScroll,lHScroll,lWrdWrap,lCancel) 

Return

 
/*/{Protheus.doc} localFindMe
	Consumo da api de integração com a plataforma FindMe
		Envio dos dados de local de atendimento
		api v2
	@type  Static Function
	@author Diego Bezerra
	@since 22/12/2022
	@version 1
	@param cCodOrc, string, código do orçamento de serviços
	@return aPostLoc, array, dados para executar o envio de dados do local de atendimento para a plataforma da FindMe
/*/
Static Function localFindMe(cCodOrc,oGsFindMe)
Local cAlias 	 := GetNextAlias()
Local cTimeZone  := 'America/Sao_Paulo'
Local aPostos	 := {}
Local aLoc		 := {}
Local cLatitude  := "-1"
Local cLongitude := "-1"
Local cEndereco	 := 'Nao informado'

BeginSql Alias cAlias
	SELECT 	 ABS.ABS_LOCAL,;
			 ABS.ABS_FILIAL,;
			 ABS.ABS_LOJA,;
			 ABS.ABS_DESCRI,;
			 ABS.ABS_LATITU,;
			 ABS.ABS_LONGIT,;
			 ABS.ABS_END,;
			 ABS.ABS_ESTADO,;
			 ABS.ABS_MUNIC,;
			 ABS.ABS_CEP,;
			 TFL.TFL_CODIGO,;
			 ABS.ABS_CODSUP
	FROM %table:ABS% ABS
		INNER JOIN %table:TFL% TFL
			ON TFL.TFL_FILIAL = %xFilial:TFL%
			AND TFL.TFL_LOCAL = ABS.ABS_LOCAL
			AND TFL.%NotDel% 
	WHERE TFL.TFL_CODPAI = %exp:cCodOrc%
			AND ABS.%NotDel%
EndSql

If !(cAlias)->(Eof()) 
	If !Empty((cAlias)->ABS_ESTADO) .AND. !Empty((cAlias)->ABS_MUNIC)
		cTimeZone := oGsFindMe:timezone('BR',(cAlias)->ABS_ESTADO,(cAlias)->ABS_MUNIC)
	EndIf
EndIf

While (cAlias)->(!Eof())

	If !Empty((cAlias)->ABS_END)
		cEndereco := RTRIM((cAlias)->ABS_END)
	EndIf

	If !Empty((cAlias)->ABS_LATITU)
		cLatitude := RTRIM((cAlias)->ABS_LATITU)
	EndIF

	If !Empty((cAlias)->ABS_LONGIT)
		cLongitude := RTRIM((cAlias)->ABS_LONGIT)
	EndIf

	aPostos := postoFindMe(;
					 cCodOrc,;
					 (cAlias)->TFL_CODIGO;
				 )

	If Len(aPostos) > 0
		AADD(aLoc,{;
			(cAlias)->ABS_LOCAL,;		//01
			(cAlias)->ABS_FILIAL,;		//02
			(cAlias)->ABS_LOJA,;		//03
			(cAlias)->ABS_ESTADO,;		//04
			(cAlias)->ABS_MUNIC,;		//05
			(cAlias)->ABS_DESCRI,;		//06
			cEndereco,;			//07
			cTimeZone,;					//08
			cLatitude,;					//09
			cLongitude,;				//10
			10,;						//11
			0,;							//12
			'false',;					//13
			'',;						//14
			'',;						//15
			'',;						//16
			aPostos,;					//17
			(cAlias)->ABS_CODSUP;		//18
		})

	EndIf

(cAlias)->(dbSkip())
EndDo

(cAlias)->(DbCloseArea())
Return aLoc


/*
Função resposável por enviar enviar obter os postos de um determinado local
*/
Static Function postoFindMe(cCodOrc,cCodLoc)
Local cAlias 	 := GetNextAlias()

Local aPostos := {}

// Obtendo os postos dos repectivos locais
BeginSql Alias cAlias

SELECT  TFF.TFF_COD,;
		TFF.TFF_FILIAL,;
		TFJ.TFJ_LOJA,;
		TFL.TFL_CODIGO,;
		TFL.TFL_FILIAL,;
		TFF.TFF_PRODUT; 
	FROM %table:TFF% TFF
		INNER JOIN %table:TFL% TFL
			ON TFL.TFL_CODIGO = TFF.TFF_CODPAI
			AND TFL.TFL_FILIAL = %xFilial:TFL%
			AND TFL.%NotDel%
		INNER JOIN %table:TFJ% TFJ
			ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.TFJ_FILIAL = %xFilial:TFJ%
			AND TFJ.%NotDel%
		WHERE TFF.TFF_FINDME = '1'
			AND TFJ.TFJ_CODIGO = %exp:cCodOrc%
			AND TFL.TFL_CODIGO = %exp:cCodLoc%

EndSql

While (cAlias)->(!Eof())
	aAdd(aPostos,{;
					(cAlias)->TFF_COD,; 	//01
					(cAlias)->TFF_FILIAL,;	//02
					(cAlias)->TFJ_LOJA,;    //03
					(cAlias)->TFL_CODIGO,;  //04
					(cAlias)->TFL_FILIAL,;  //05
					(cAlias)->TFF_PRODUT,;  //06
				})

(cAlias)->(dbSkip())
EndDo

(cAlias)->(DbCloseArea()) 
Return aPostos



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} intFindMe
Responsável por criar usuário na plataforma findme, com os dados do atendente
@author	Diego Bezerra
@since 		12/09/2023
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function intFindMe(cCodTec)
	
	Local aTec := {}
	Local aRet := {}

	IF AA1->(DBSEEK(XFILIAL("AA1")+cCodTec))
		If !Empty(AA1->AA1_EMAIL) .AND. !Empty(AA1->AA1_FONE) .AND. !Empty(AA1->AA1_CDFUNC)

			AADD(aTec,AA1->AA1_CODTEC)
			AADD(aTec,AA1->AA1_FILIAL)
			AADD(aTec,'01')
			AADD(aTec,RTRIM(AA1->AA1_NOMTEC))
			AADD(aTec,SuperGetMv("MV_FDROLE",,'coordinator'))
			AADD(aTec,RTRIM(AA1->AA1_EMAIL))
			AADD(aTec,RTRIM(AA1->AA1_CDFUNC))
			AADD(aTec,SuperGetMv('MV_FDPSW',,'1234'))
			AADD(aTec,'pt-BR')
			AADD(aTec,RTRIM(AA1->AA1_FONE))
			AADD(aRet,aTec) 

		EndIf

	EndIf

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT766dInMn

@description Chama a função AT766dIMn2 dentro de um MsgRun

@author	djalma.mathias
@since	22/03/2024
/*/
//------------------------------------------------------------------------------
Function AT766dInMn()
	FwMsgRun(Nil,{|| At766Findme()}, Nil, STR0035)	// "Processando Integração Find-Me"
Return
 