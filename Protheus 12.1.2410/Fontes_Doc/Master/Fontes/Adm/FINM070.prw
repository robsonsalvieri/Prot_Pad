#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINM070.CH'

Static __oFKWQry	As Object
Static __oTitOrig	As Object
Static __cAlsTMP	As Char
Static __cCdRetIRRt	:= NIL
Static __lFinxRtIR	:= NIL
Static __oRatIRF	:= NIL
Static __lFKWVlBr	As Logical
Static __lFTemFKY	As Logical

//-------------------------------------------------------------------
/*/ {Protheus.doc} FINM070
Modelo de dados da tabela FKW, responsavel pela proporcionalizasao dos 
impostos do titulo e suas respectivas naturezas de rendimento (FKX).

@author Fabio Casagrande Lima
@since 07/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function FINM070()

Return

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} ModelDef
Modelo de dados.

@author Rodrigo Pirolo
@since  10/05/2019
@version 12
/*/	
//-----------------------------------------------------------------------------

Static Function ModelDef() As Object 

	Local oModel	As Object
	Local oMaster	As Object
	Local oStruFKW	As Object

	oModel	:= MPFormModel():New('FINM070',/*Pre*/,/*bPos*/, /*Commit*/ )
	oMaster	:= FWFormModelStruct():New()
	oStruFKW:= FWFormStruct( 1, 'FKW' )

	//Criado master falso para a alimentação dos detail.
	oMaster:AddTable('FAKEMASTER',,STR0001 )
	oMaster:AddField("IDPROC"  ,"","IDPROC"  ,"C",TAMSX3("FKW_IDDOC")[1],0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""} ,/*Key*/,.F.,.T.,)
	oMaster:SetProperty('IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "FKW->FKW_IDDOC" ) )

	oModel:AddFields("FAKEMASTER", /*cOwner*/, oMaster , , ,{|o|{}} )
	oModel:AddGrid("FKWDETAIL", "FAKEMASTER", oStruFKW, /*bLinePre*/, , /*bPre*/, /*bLinePost*/, /*bLoadIMP*/ )	

	//Cria os modelos relacionados.
	oModel:SetPrimaryKey( {} )

	//Cria relacionamentos
	oModel:SetRelation('FKWDETAIL',{{'FKW_FILIAL','xFilial("FKW")'},{'FKW_IDDOC','IDPROC'}},FKW->(IndexKey(2)))

	oModel:GetModel('FAKEMASTER'):SetOnlyQuery(.T.)

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel('FKWDETAIL'):SetOptional(.T.)

Return oModel

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} F070Grv
Componente de gravação da tabela FKW

@param1 aDados - Array multidimencional c/ os dados
	[1][1]Filial 
	[1][2]ID Documento (FK7)
	[1][3]Tipo Imposto
	[1][4]Natureza de Rendimento
	[1][5]Percentual da retencao
	[1][6]Base da retencao
	[1][7]Valor do imposto retido
	[1][8]Base imposto nao retido
	[1][9]Valor do impoto nao retido
	[1][10]Numero Processo Judicial
	[1][11]Tipo Processo
	[1][12]Cod. Indicativo suspensao
	[1][13]Percentual não Retido
@param2 nOpc    - Opção de gravação (3-Inclusão / 4-Alteracao / 5-Exclusao )
@param3 cCartei - Carteira do titulo (1-Contas a Pagar / 2 - Contas a Receber)

@Retorno - lRet, logical

@author Rodrigo Pirolo
@since  10/05/2019
@version 12
/*/	
//-----------------------------------------------------------------------------

Function F070Grv( aDados As Array, nOpc as Numeric, cCartei As Character ) As Logical

	Local aRatIrf   as Array
	Local cFilFkw   As Character
	Local cIdFK7    as Character
	Local lContinua as Logical
	Local lDesdobra as Logical
	Local lNewProc  as Logical
	Local lRet      as Logical
	Local nCount    as Numeric
	Local nI        as Numeric
	Local nLength   as Numeric
	Local oMdlFAKE  as Object
	Local oMdlFKW   as Object
	Local oModel    as Object
	Local cForn		as Character
	Local cLoja		as Character

	Default aDados	:= {}
	Default nOpc	:= 3 //Inclusão
	Default cCartei := "1" //1-Contas a Pagar

	aRatIrf   := {}
	cIdFK7    := ""
	lContinua := .T.
	lDesdobra := .F.
	lNewProc  := .F.
	lRet      := .T.
	nCount    := 0
	nI        := 0
	nLength   := Len(aDados)
	cForn     := ""
	cLoja     := ""
	
	If __lFTemFKY == Nil
		__lFTemFKY := FindFunction("FTemFKY")
	EndIf

	lRet := ValidTable() //Valida o compartilhamento das tabelas de natureza de rendimento (FKW/FKY)

	If lRet .AND. nLength > 0
		
		If nOpc <> 3 
			DbSelectArea("FKW")
			FKW->(DbSetOrder(2)) //FKW_FILIAL+FKW_IDDOC+FKW_CARTEI+FKW_TPIMP+FKW_NATREN
			If !FKW->(DBSeek(xFilial("FKW", aDados[1][1]) + aDados[1][2] + cCartei ) ) .and. nOpc == 4
				nOpc := 3
			Endif
		Else 
			If cCartei == "1"
				lDesdobra := (SE2->E2_DESDOBR == 'S')
			ElseIf cCartei == "2"
				lDesdobra := (SE1->E1_DESDOBR == 'S')
			Endif

			//Na inclusão, verifico se o título pertence a um desdobramento.
			//No caso do título gerador do desdobramento ou da parcela de desdobramento que já possui FKW gravada não permito nova inclusão.
			//Neste caso estamos fazendo proteção de n chamadas da FINA986 dentro de um processo de inclusão via desdobramento.
			DbSelectArea("FKW")
			FKW->(DbSetOrder(2)) //FKW_FILIAL+FKW_IDDOC+FKW_CARTEI+FKW_TPIMP+FKW_NATREN
			If lDesdobra .OR. (FKW->(DBSeek(xFilial("FKW", aDados[1][1]) + aDados[1][2] + cCartei ) ) )
				lContinua := .F.
			Endif
		EndIf
		
		If lContinua 

			//RATEIO IR ALUGUEL
			If cCartei == "1" .and. nOpc <> 5
				FVRatIrA(aRatIrf) 
				If Len(aRatIrf) > 0
					F070RatIRA(aDados,aRatIrf)
					nLength   := Len(aDados)

				//Verifica se tem rateio IR quando vindo de outro processo que não FINA050
				ElseIf F070TRatIR(aDados[1,2])	
					F070RatIRA(aDados,aRatIrf)
					nLength   := Len(aDados)
				Endif
			Endif

			If oModel == NIL
				If !__lFTemFKY .Or. ( __lFTemFKY .And. !FTemFKY(aDados[1][2]) )
					oModel:= FWLoadModel('FINM070')
				EndIf
			EndIf

			If ValType(oModel) == "O"
				
				If nOpc <> 5

					If nOpc == 4
						oModel:SetOperation(nOpc)
						oModel:Activate()
						oMdlFAKE:= oModel:GetModel("FAKEMASTER")
						oMdlFKW	:= oModel:GetModel("FKWDETAIL")

						For nI :=1 to oMdlFKW:Length()
							oMdlFKW:GoLine(Ni)
							oMdlFKW:DeleteLine()
						Next nI
						If oMdlFKW:VldData()
							FWFormCommit(oModel)
							oModel:DeActivate()
						Endif
					EndIf	

					For nCount := 1 To nLength

						If cIdFK7 != aDados[nCount][2]
							oModel:SetOperation(nOpc)
							oModel:Activate()
							oMdlFAKE:= oModel:GetModel("FAKEMASTER")
							oMdlFKW	:= oModel:GetModel("FKWDETAIL")
							cIdFK7 := aDados[nCount][2]
							lNewProc := .T.
						EndIf

						oMdlFAKE:Setvalue("IDPROC",aDados[nCount][2])

						If (nCount > 1 .and. !lNewProc) .or. (nCount == 1 .And. nOpc == 4)
							If oMdlFKW:VldData()
								oMdlFKW:AddLine()
							Else
								lRet := .F.
								Exit
							EndIf
						EndIf

						lNewProc := .F.
						cFilFkw := xFilial("FKW", aDados[nCount][1])
						__lFKWVlBr := If(__lFKWVlBr == Nil, FKW->(ColumnPos("FKW_VLBRUT")) > 0, __lFKWVlBr)
						
						oMdlFKW:SetValue( "FKW_FILIAL",	cFilFkw 		  )	 //Filial                   
						oMdlFKW:SetValue( "FKW_IDFKW" ,	FWUUIDV4()        )  //Codigo              			     
						oMdlFKW:SetValue( "FKW_IDDOC" ,	aDados[nCount][2] )  //ID Documento (FK7)
						oMdlFKW:SetValue( "FKW_CARTEI", cCartei			  )  //Carteira do titulo               
						oMdlFKW:SetValue( "FKW_TPIMP" ,	aDados[nCount][3] )  //Tipo Imposto             
						oMdlFKW:SetValue( "FKW_NATREN",	aDados[nCount][4] )  //Natureza de Rendimento    				
						oMdlFKW:SetValue( "FKW_PERC"  ,	aDados[nCount][5] )  //Percentual da retencao
						oMdlFKW:SetValue( "FKW_BASETR",	aDados[nCount][6] )  //Base da retencao
						oMdlFKW:SetValue( "FKW_VLIMP" ,	aDados[nCount][7] )  //Valor do imposto retido
						oMdlFKW:SetValue( "FKW_BASENR", aDados[nCount][8] )  //Base imposto nao retido  
						oMdlFKW:SetValue( "FKW_VLIMPN", aDados[nCount][9] )  //Valor do impoto nao retid
						oMdlFKW:SetValue( "FKW_NUMPRO", aDados[nCount][10] ) //Numero Processo Judicial 
						oMdlFKW:SetValue( "FKW_TPPROC", aDados[nCount][11] ) //Tipo Processo            
						oMdlFKW:SetValue( "FKW_CODSUS", aDados[nCount][12] ) //Cod. Indicativo suspensao
						oMdlFKW:SetValue( "FKW_PERCNR", aDados[nCount][13] ) //Percentual não Retido    

						If Len(aDados[nCount]) > 13
							oMdlFKW:SetValue( "FKW_CGC  " , aDados[nCount][14] ) //cnpj/cgc
						Endif
						
						If Len(aDados[nCount]) > 14 .And. __lFKWVlBr
							oMdlFKW:SetValue( "FKW_VLBRUT" , aDados[nCount][15] ) //Valor Bruto
						Endif

						If nCount == nLength .or. (nCount < nLength .and. cIdFK7 != aDados[nCount+1][2])
							If oModel:VldData()
								oModel:CommitData()
								oModel:DeActivate()
							Else 
								lRet := .F.
								Exit
							Endif
						Endif
					Next nCount
				else
					oModel:SetOperation(nOpc)
					oModel:Activate()
					oModel:CommitData()
					oModel:DeActivate()
				EndIf			
				
				If !lRet 
					cLog := cValToChar( oModel:GetErrorMessage()[4] ) + ' - '
					cLog += cValToChar( oModel:GetErrorMessage()[5] ) + ' - '
					cLog += cValToChar( oModel:GetErrorMessage()[6] )
					
					Help( , , "FINM070", , cLog, 1, 0 )		
					oModel:DeActivate()
				EndIf

				If ValType(oModel) == "O"
					oModel:Destroy()
					oModel:= NIL
				Endif
			EndIf
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} ValidTable
Valida o compartilhamento das tabelas de natureza de rendimento (FKW/FKY)

@Retorno - lRet, logical

@author Fabio Casagrande Lima
@since  01/02/2023
/*/	
//-----------------------------------------------------------------------------
Static Function ValidTable() as Logical

	Local cCompFKF  As Character
	Local cCompFKW  As Character
	Local cCompFK2  As Character
	Local cCompFKY  As Character
	Local lCont     As Logical

	lCont      := .F. 

	If AliasInDic("FKW") .and. AliasInDic("FKY")

		lCont      := .T.
		cCompFKF  := FWModeAccess( "FKF" , 1 ) + FWModeAccess( "FKF" , 2 ) + FWModeAccess( "FKF" , 3 )
		cCompFKW  := FWModeAccess( "FKW" , 1 ) + FWModeAccess( "FKW" , 2 ) + FWModeAccess( "FKW" , 3 )
		cCompFK2  := FWModeAccess( "FK2" , 1 ) + FWModeAccess( "FK2" , 2 ) + FWModeAccess( "FK2" , 3 )
		cCompFKY  := FWModeAccess( "FKY" , 1 ) + FWModeAccess( "FKY" , 2 ) + FWModeAccess( "FKY" , 3 )

		If (cCompFKF <> cCompFKW) .or. (cCompFK2 <> cCompFKY)
			Help( , , "FINM070COMP", , STR0007, 1, 0, , , , , , { STR0008 } )	// "Atenção! Problema encontrado no modo de compartilhamento de tabelas do REINF."

			lCont := .F.
		Endif

	Endif

Return lCont

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} F070RatIRA
Montagem da aDados quando houver rateio de IR Aluguel

@param1 aDados - Array multidimencional c/ os dados
	[1][1]Filial 
	[1][2]ID Documento (FK7)
	[1][3]Tipo Imposto
	[1][4]Natureza de Rendimento
	[1][5]Percentual da retencao
	[1][6]Base da retencao
	[1][7]Valor do imposto retido
	[1][8]Base imposto nao retido
	[1][9]Valor do impoto nao retido
	[1][10]Numero Processo Judicial
	[1][11]Tipo Processo
	[1][12]Cod. Indicativo suspensao
	[1][13]Percentual não Retido
@param2 aRatIrf  - Array multidimencional com o rateio IR Aluguel
 	[1]  = Codigo do Fornecedor
	[2]  = Loja do Fornecedor
	[3]  = CPF do Fornecedor
	[4]  = Percentual de Rateio
	[5]  = Base do Imposto
	[6]  = Imposto Calculado
	[7]  = Imposto Retido
	[8]  = Nome do Fornecedor
	[9]  = Base do imposto quando o MV_AGLIMPJ != 1 

@Retorno - lRet, logical

@author Pequim
@since  26/12/2022
@version 12.1.2310
/*/	
//-----------------------------------------------------------------------------
Function F070RatIRA(aDados as Array, aRatIrf as Array) as Logical

	Local aDadosRat  as Array
	Local cForn      as Character
	Local cLoja      as Character
	Local cTipo      as Character
	Local lIRPFBaixa as Logical
	Local lRatIr     as Logical
	Local nLenRat    as Numeric
	Local nTotBase   as Numeric
	Local nTotImpNR  as Numeric
	Local nTotImpR   as Numeric
	Local nX         as Numeric
	Local nY         as Numeric

	DEFAULT aDados  := {}
	DEFAULT aRatIrf := {}

	aDadosRat  := {}
	cForn      := ""
	cLoja      := ""
	cTipo      := ""
	lIRPFBaixa := .F.
	lRatIR     := .F.
	nLenRat    := Len(aRatIrf)
	nTotBase   := 0
	nTotImpNR  := 0
	nTotImpR   := 0
	nX         := 0
	nY         := 0

	If __cCdRetIRRt == NIL
   		__cCdRetIRRt  := SuperGetMv("MV_RETIRRT",.T.,"3208")
	EndIf

	FKJ->(DbSetOrder(1))	//FKJ_FILIAL+FKJ_COD+FKJ_LOJA+FKJ_CPF

	For nX := 1 to len(aDados)
		If aDados[nX,3] == 'IRF'
 			
			If Alltrim(SE2->E2_CODRET) $ __cCdRetIRRt
				lRatIr := F070TRatIR(aDados[nX,2], @cForn, @cLoja, @cTipo, @lIRPFBaixa )			
				If nLenRat > 0
					nTotBase := F070Totais(aDados)
					F070aDados(aDados[nX],aDadosRat,aRatIrf,nLenRat,nTotBase, lIRPFBaixa) 
				Else
					If lRatIr
						AADD(aDados[nX], "" )	//[14] CPF
						If nX == 1
							nTotBase := F070Totais(aDados)
						Endif

						If cTipo == "F"
							aRatIrf := f070CRatIR(lIRPFBaixa, nTotBase)
							nLenRat := Len(aRatIrf)
						EndIf

						If nLenRat > 0
							F070aDados(aDados[nX],aDadosRat,aRatIrf,nLenRat,nTotBase, lIRPFBaixa)
						EndIf
					Endif
				Endif
			Endif
		Else
			AADD(aDados[nX], "" )	//[14] CPF
			AADD(aDadosRat, aDados[nX])			
		Endif		
	NEXT
	
	If lRatIr
		aDados := aDadosRat
	Endif

Return 

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} F070aDados
Componente de gravação da tabela FKW

@param1 aLinDados - Array c/ os dados
	[1][1]Filial 
	[1][2]ID Documento (FK7)
	[1][3]Tipo Imposto
	[1][4]Natureza de Rendimento
	[1][5]Percentual da retencao
	[1][6]Base da retencao
	[1][7]Valor do imposto retido
	[1][8]Base imposto nao retido
	[1][9]Valor do impoto nao retido
	[1][10]Numero Processo Judicial
	[1][11]Tipo Processo
	[1][12]Cod. Indicativo suspensao
	[1][13]Percentual não Retido
	[1][14]CPF do rateio aluguel
	[1][15]Valor/rendimento bruto
@param2 aDadosRat - Array aDados com o rateio
	[1][1]Filial 
	[1][2]ID Documento (FK7)
	[1][3]Tipo Imposto
	[1][4]Natureza de Rendimento
	[1][5]Percentual da retencao
	[1][6]Base da retencao
	[1][7]Valor do imposto retido
	[1][8]Base imposto nao retido
	[1][9]Valor do impoto nao retido
	[1][10]Numero Processo Judicial
	[1][11]Tipo Processo
	[1][12]Cod. Indicativo suspensao
	[1][13]Percentual não Retido
	[1][14]FK4_IDORIG
	[1][15]"FK4"
@param3 aRatIrf  - Array multidimencional com o rateio IR Aluguel
 	[1]  = Codigo do Fornecedor
	[2]  = Loja do Fornecedor
	[3]  = CPF do Fornecedor
	[4]  = Percentual de Rateio
	[5]  = Base do Imposto
	[6]  = Imposto Calculado
	[7]  = Imposto Retido
	[8]  = Nome do Fornecedor
	[9]  = Base do imposto quando o MV_AGLIMPJ != 1 
@param4 nLenRat - Tamanho do array do rateio de IR
@param5 nTotBase - Total da base de impostos do título (Base Retidos + Base Não Retidos)

@author Pequim
@since  26/12/2022
@version 12.1.2310
/*/	
//-----------------------------------------------------------------------------
Function F070aDados(aLinDados As Array, aDadosRat as Array, aRatIrf as Array, nLenRat as Numeric, nTotBase as Numeric, lIRPFBaixa as Logical) 

	Local aAux       as Array
	Local nPropBNRet as Numeric
	Local nPropBRet  as Numeric
	Local nPropINRet as Numeric
	Local nPropPNRet as Numeric
	Local nX         as Numeric
	Local nPropBruto as Numeric

	Default aDadosRat  := {}
	Default aLinDados  := {}
	Default aRatIrf    := {}
	Default lIRPFBaixa := .F.
	Default nLenRat    := 0
	Default nTotBase   := 0

	aAux       := {}
	nPropBNRet := 0
	nPropBRet  := 0
	nPropINRet := 0
	nPropPNRet := 0
	nX         := 0
	nPropBruto := 0

	If nLenRat > 0
		For nX := 1 to nLenRat

			nPropBRet  := aLinDados[6] * (aRatIrf[nX,4]/100)
			nPropBNRet := aLinDados[8] * (aRatIrf[nX,4]/100)	//nPropBase = Base de retenção * % rateio IR
			nPropPNRet := nPropBNRet/nTotBase					//nPropPerc = Base de retenção do item / base total
			nPropINRet := aLinDados[9] * (nPropPNRet)			//nPropImp = Valor do imposto retido * nPropPerc
			nPropBruto := nPropBRet+nPropBNRet
			//Se o IR for na baixa, zero o valor do IR para a FKW
			If lIRPFBaixa .and. Alltrim(aLinDados[3]) == 'IRF' .and. aRatIrf[nX,6] > 0 .And. !( SE2->E2_TIPO $ MVPAGANT )
				aRatIrf[nX,6] := 0
			Endif

			AADD(aAux, aLinDados[1]  )	//01 Filial
			AADD(aAux, aLinDados[2]  )	//02 ID Documento (FK7)
			AADD(aAux, aLinDados[3]  )	//03 Tipo Imposto
			AADD(aAux, aLinDados[4]  )	//04 Natureza de Rendimento
			AADD(aAux, aRatIrf[nX,4] )	//05 Percentual da retencao 					
			AADD(aAux, nPropBRet     )	//06 Base de retencao
			AADD(aAux, aRatIrf[nX,6] )	//07 Valor do imposto retido
			AADD(aAux, nPropBNRet    )	//08 Base do Imposto não retido	
			AADD(aAux, nPropINRet    )	//09 Valor do imposto nao retido
			AADD(aAux, aLinDados[10] )	//10 Numero Processo Judicial 
			AADD(aAux, aLinDados[11] )	//11 Tipo Processo
			AADD(aAux, aLinDados[12] )	//12 Cod. Indicativo suspensao
			AADD(aAux, nPropPNRet    )	//13 Percentual da não retencao
			AADD(aAux, aRatIrf[nX,3] )	//14 CPF			
			AADD(aAux, nPropBruto )		//15 Valor/rendimento bruto	

			AADD(aDadosRat, aAux)
			aAux := {}
		Next
	Endif

	FWFreeArray(aAux)

Return 

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} F070Totais
Obtém total da base de IRRF do título

@param1 aDados - Array multidimencional c/ os dados
	[1][1]Filial 
	[1][2]ID Documento (FK7)
	[1][3]Tipo Imposto
	[1][4]Natureza de Rendimento
	[1][5]Percentual da retencao
	[1][6]Base da retencao
	[1][7]Valor do imposto retido
	[1][8]Base imposto nao retido
	[1][9]Valor do impoto nao retido
	[1][10]Numero Processo Judicial
	[1][11]Tipo Processo
	[1][12]Cod. Indicativo suspensao
	[1][13]Percentual não Retido

@author Pequim
@since  26/12/2022
@version 12.1.2310
/*/	
//-----------------------------------------------------------------------------
Function F070Totais(aDados as Array )

	Local nTotBase as Numeric
	Local nY       as Numeric

	DEFAULT aDados   := {}
	DEFAULT nTotBase := 0

	nTotBase := 0
	nY       := 0

	For nY := 1 to Len(aDados)
		If aDados[nY,3] == 'IRF'
			nTotBase  += aDados[nY,6] + aDados[nY,8]		//Base de Impostos Retidos e Não Retidos (Suspensão)
		Endif
	Next 

Return nTotBase

//-----------------------------------------------------------------------------
/*/{Protheus.doc} F070TRatIR
	
	Verifica se o fornecedor de títulos possui Rateio de IR Aluguel

	@type  Function
	@author Pequim
	@since 29/12/2022

	@param cIdDoc, Character, IDDoc do titulo 
	@param cForn , Character, Código do Fornecedor
	@param cLoja , Character, Código da Loja do Fornecedor

	@return lRatIr , Logical, Existe IRRF para rateio

/*/
//-----------------------------------------------------------------------------
Function F070TRatIR(cIdDoc As Character, cForn as Character, cLoja as Character , cTipo as Character, lIRPFBaixa as Logical )

	Local lRatIr as Logical

	DEFAULT cForn      := ""
	DEFAULT cIdDoc     := ""
	DEFAULT cLoja      := ""
	DEFAULT cTipo      := ""
	DEFAULT lIRPFBaixa := .F.

	lRatIr := .F.

	// Posiciona FK7 com aDados[nX,2] -	ID FK7
	FK7->(DbSetOrder(1))
	If FK7->(dbSeek(xFilial("FK7")+cIdDoc))
		// Obtém o fornecedor
		cForn := FK7->FK7_CLIFOR
		cLoja := FK7->FK7_LOJA

		// Posiciona na SA2 para saber se o fornecedor tem IR na baixa ou emissao
		SA2->(DbSetOrder(1))	//A2_FILIAL+A2_COD+A2_LOJA
		If SA2->(MsSeek(xFilial("SA2")+cForn+cLoja)) 
			
			lIRPFBaixa := SA2->A2_CALCIRF == '2'

			If SA2->A2_IRPROG == '1'.AND. !Empty(SA2->A2_CPFIRP)
				// Posiciona na FKJ e verifica se o fornecedor possui cadastro de rateio de IR Aluguel
				FKJ->(DbSetOrder(1))	//FKJ_FILIAL+FKJ_COD+FKJ_LOJA+FKJ_CPF
				If FKJ->(MsSeek(xFilial("FKJ")+cForn+cLoja))
					lRatIr := .T.
					cTipo := "F"
				Endif
			Endif
		Endif
	Endif

Return lRatIr


//-----------------------------------------------------------------------------
/*/ {Protheus.doc} f070CRatIR
Obtém o rateio IR Aluguel do título

@param1 lIRPFBaixa, Logical, Indica retenção de IR na baixa
@param2 nTotBase, Numeric, Valor da Base Total de IR

@author Pequim
@since  04/01/2023
@version 12.1.2310
/*/
//-----------------------------------------------------------------------------	
Function f070CRatIR(lIRPFBaixa as Logical, nTotBase as Numeric)
    
	Local aRatIrf    as Array
	Local cCdRetIRRt as Character
	Local lRateioIR  as Logical
	Local nX         as Numeric

    Default lIRPFBaixa := .F.
	Default nTotBase   := 0

	aRatIrf    := {}
    cCdRetIRRt := ""
    lRateioIR  := .F.
	nX         := 0

	If __lFinxRtIR == NIL
		__lFinxRtIR := FindFunction("FinXRatIR")
	Endif

    If cPaisLoc == "BRA" .and. __lFinxRtIR

        If Alltrim(SE2->E2_CODRET) $ __cCdRetIRRt
            If __oRatIRF == Nil
                __oRatIRF := FinBCRateioIR():New()
            EndIf
            __oRatIRF:SetFilOrig(cFilAnt)
            __oRatIRF:SetForLoja(SA2->A2_COD,SA2->A2_LOJA)
            __oRatIRF:SetIRBaixa(lIRPFBaixa)
            If !Empty(__oRatIRF:aRatIRF)
                lRateioIR := .T.
            EndIf
        EndIf    
    EndIf

    If lRateioIR
		__oRatIRF:SetBaseIR(nTotBase)
        __oRatIRF:CalcRatIr()

		If Len(__oRatIRF:aRatIRF) > 1
			//Verifica o IR retido por CPF (Rateio de Ir Progressivo)
			__oRatIRF:GetIdDoc(SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA)
			__oRatIRF:GetIRRetido(__oRatIRF:cIdDoc)
		Endif            
        aRatIrf := __oRatIRF:aRatIRF
	EndIf

	If lIRPFBaixa
		For nX := 1 to Len(aRatIrf)
			aRatIrf[nX, 6] := 0
		Next
	Endif

Return aRatIrf


//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FVRatIrA
Obtém o rateio IR Aluguel do título

@param1 aRatIrf  - Array multidimencional com o rateio IR Aluguel
 	[1]  = Codigo do Fornecedor
	[2]  = Loja do Fornecedor
	[3]  = CPF do Fornecedor
	[4]  = Percentual de Rateio
	[5]  = Base do Imposto
	[6]  = Imposto Calculado
	[7]  = Imposto Retido
	[8]  = Nome do Fornecedor
	[9]  = Base do imposto quando o MV_AGLIMPJ != 1 

@author Pequim
@since  04/01/2023
@version 12.1.2310
/*/	
//-----------------------------------------------------------------------------
Function FVRatIrA(aRatIrf As Array) 

	DEFAULT aRatIrf := {}

	FGaRatIrA(aRatIrf) 

	If Len(aRatIrf) == 0
		__oRatIRF := a103GRatIR()
		If ValType( __oRatIRF ) =='O' 
			aRatIrf := __oRatIRF:aRatIRF
		Endif
	Endif
Return 


//--------------------------------------------------------------------------------
/*/{Protheus.doc} FGrvReinf
	Montagem do processo de gravação da tabela FKW quando impostos forem na baixa

	@type  Function
	@author Pequim
	@since 06/01/2023
	@version 12.1.2310

	@param aTitOrig  , array	, Array contendo as chaves FK7 dos titulos originadores da Fatura

	@param aFKWTitSon, Numeric	, Array com informações ref as parcelas geradas 
			[1,1] cChave FK7 da parcela gerada
			[1,2] Codigo do imposto (conforme tabela "0C" da SX5)
			[1,3] Base do imposto na parcela gerada
			[1,4] Valor do imposto na parcela gerada

	@param nBIRFReinf, Numeric	, Base Total do IRF no processo 
	@param nBPISReinf, Numeric	, Base Total do PIS no processo 
	@param nBCOFReinf, Numeric	, Base Total do COF no processo 
	@param nBCSLReinf, Numeric	, Base Total do CSL no processo
	@param nBSEMReinf, Numeric  , Base Total dos sem impostos 

	@return return_var, return_type, return_description
	/*/
//--------------------------------------------------------------------------------
Function FGrvReinf(aTitOrig as Array, aFKWTitSon as Array, nBIRFReinf as Numeric, nBPISReinf as Numeric, nBCOFReinf as Numeric, nBCSLReinf as Numeric, nBSEMReinf as Numeric)

	Local aArea     as Array
	Local aAux      as Array
	Local aDados    as Array
	Local aRatNatR  as Array
	Local cFilFKW   as Character
	Local nBaseTot  as Numeric
	Local nImpPropN as Numeric
	Local nImpPropR as Numeric
	Local nX        as Numeric
	Local nY        as Numeric

	DEFAULT aTitOrig   := {}
	DEFAULT aFKWTitSon := {}
	DEFAULT nBIRFReinf := 0
 	DEFAULT nBPISReinf := 0
 	DEFAULT nBCOFReinf := 0
 	DEFAULT nBCSLReinf := 0
 	DEFAULT nBSEMReinf := 0
 
	aArea     := GetArea()
	aAux      := {}
	aDados    := {}
	aRatNatR  := {}
	cFilFKW   := xFilial("FKW")
	nBaseTot  := 0
	nImpPropN := 0
	nImpPropR := 0
	nX        := 0
	nY        := 0

	For nX := 1 to Len(aFKWTitSon)

		If aFKWTitSon[nX,2] == "IRF"
			nBaseTot := nBIRFReinf
		ElseIf aFKWTitSon[nX,2] == "PIS"
			nBaseTot := nBPISReinf
		ElseIf aFKWTitSon[nX,2] == "COF"
			nBaseTot := nBPISReinf
		ElseIf aFKWTitSon[nX,2] == "CSL"
			nBaseTot := nBPISReinf
		ElseIf aFKWTitSon[nX,2] == "SEMIMP"
			nBaseTot := nBSEMReinf
		EndIf

		aRatNatR := NatRenProp(aTitOrig, aFKWTitSon[nX,2], nBaseTot, aFKWTitSon[nX,3])

		For nY := 1 to Len(aRatNatR)
			//aNatProp,{(cAliasTmp)->FKW_NATREN, nBasProp, nPerProp, nBasPropN, nPerPropN,(cAliasTmp)->FKW_NUMPRO,(cAliasTmp)->FKW_TPPROC,(cAliasTmp)->FKW_CODSUS
			nImpPropR := aFKWTitSon[nX,4] * (aRatNatR[nY,3]/100)		//Imposto retido
			nImpPropN := aFKWTitSon[nX,4] * (aRatNatR[nY,5]/100)		//Imposto suspenso

			AADD(aAux, cFilFKW		 	)	//01 Filial
			AADD(aAux, aFKWTitSon[nX,1] )	//02 ID Documento (FK7)
			AADD(aAux, aFKWTitSon[nX,2] )	//03 Tipo Imposto
			AADD(aAux, aRatNatR[nY,1]  	)	//04 Natureza de Rendimento
			AADD(aAux, aRatNatR[nY,3]	)	//05 Percentual da retencao 					
			AADD(aAux, aRatNatR[nY,2]	)	//06 Base de retencao
			AADD(aAux, nImpPropR		)	//07 Valor do imposto retido
			AADD(aAux, aRatNatR[nY,4]	)	//08 Base do Imposto não retido	
			AADD(aAux, nImpPropN    	)	//09 Valor do imposto nao retido
			AADD(aAux, aRatNatR[nY,6]	)	//10 Numero Processo Judicial 
			AADD(aAux, aRatNatR[nY,7]	)	//11 Tipo Processo
			AADD(aAux, aRatNatR[nY,8]	)	//12 Cod. Indicativo suspensao
			AADD(aAux, aRatNatR[nY,5]	)	//13 Percentual da não retencao

			AADD(aDados, aAux)
			aAux := {}
		Next
	Next
	//GRAVAR FKW
	F070Grv( aDados , 3, "1" ) 

	RestArea(aArea)
	
	FWFreeArray(aArea)
	FWFreeArray(aAux)
	FWFreeArray(aDados)
	FWFreeArray(aRatNatR)

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} NatRenProp
Calcula a proporcionalização das "naturezas de rendimento x impostos"
para a renegociação dos títulos via fatura/liquidacao.

Obs: A chamada da função deve ser feita para cada nova parcela a ser gerada.

@param aTitOrig - Array - Lista contando os ID's (FK7) dos titulos de origem da renegociacao
@param cImpos   - Char - Codigo do imposto (conforme tabela "0C" da SX5)
@param nBaseTot - Numeric - Base do imposto total da renegociacao
@param nBasParc - Numeric - Base do imposto pra parcela

@return aNatProp - Array - Lista da proporcionalizacao das naturezas, base e percentual

@author Fabio Casagrande Lima
@since 05/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Function NatRenProp(aTitOrig As Array, cImpos As Character, nBaseTot As Numeric, nBasParc As Numeric) As Array

	Local aNatProp  as Array
	Local aFields	as Array
	Local cAliasTmp as Character
    Local cQuery    as Character
	Local cRealName as Character
    Local lTemFKW   as Logical
	Local nBasPropN as Numeric
	Local nBasPropR as Numeric
    Local nPercPar  as Numeric
	Local nPerPropN as Numeric
	Local nPerPropR as Numeric
	Local nI		as Numeric
	Local nTcSql	as Numeric

    Default aTitOrig := {}
    Default cImpos   := ""
    Default nBaseTot := 0
    Default nBasParc := 0

    lTemFKW  	:= AliasInDic("FKW")
	aNatProp 	:= {}
	aFields		:= {}

	//Percentual da base da parcela em relacao a base total da renegociacao
    nPercPar := (nBasParc / nBaseTot) * 100

	If __oTitOrig != Nil
		__cAlsTMP	:= __oTitOrig:GetAlias()		
		nTcSql 		:= TcSQLExec("DELETE FROM " + __oTitOrig:GetRealName() )
		If nTcSql < 0
			//-- Se ocorrer algum problema refaz a temporaria
			__oTitOrig:Delete()
			__oTitOrig := Nil
		Else // Necessária para atualização do Alias após deleção dos dados 
			(__cAlsTMP)->(dbGoTo(1))
		EndIf
	EndIf
	If __oTitOrig == Nil
		__cAlsTMP	:= GetNextAlias()
		//Cria Alias Temporário com os RECNOs a excluir
		__oTitOrig 	:= FWTemporaryTable():New(__cAlsTMP)
		AADD(aFields, {"IDDOC",	"C", TamSx3("FK7_IDDOC")[1], 0})	
		__oTitOrig:SetFields(aFields)
		__oTitOrig:Create()
	EndIf

	cRealName	:= __oTitOrig:GetRealName()
	For nI := 1 to Len(aTitOrig)
		(__cAlsTMP)->(DbAppend())
		(__cAlsTMP)->IDDOC := aTitOrig[nI]
		(__cAlsTMP)->(DbCommit())
	Next nI

    If lTemFKW 

		//Busca no(s) titulo(s) de origem da renegociacao as naturezas de rendimento e as bases do imposto
		IF __oFKWQry == NIL
			cQuery :=	"SELECT FKW_NATREN, FKW_NUMPRO, FKW_TPPROC,	FKW_CODSUS, SUM(FKW_BASETR) FKW_BASETR,SUM(FKW_BASENR) FKW_BASENR" 
			cQuery +=	" FROM ? FKW" 
			cQuery +=	" WHERE FKW.D_E_L_E_T_ = ' ' AND"   
			cQuery +=	" FKW_CARTEI = '1' AND"      
			cQuery +=	" FKW_TPIMP = ? AND" 
			cQuery +=	" FKW_IDDOC IN (SELECT IDDOC FROM ?) " 
			cQuery +=	" GROUP BY FKW_NATREN, FKW_NUMPRO, FKW_TPPROC, FKW_CODSUS"

			cQuery := ChangeQuery(cQuery)
			__oFKWQry := FWPreparedStatement():New(cQuery)
		EndIf

		__oFKWQry:SetNumeric(1,RetSqlName("FKW"))
		__oFKWQry:SetString(2,cImpos)
		__oFKWQry:SetNumeric(3,cRealName)
		cQuery := __oFKWQry:GetFixQuery()	

		cAliasTmp := MpSysOpenQuery(cQuery)
			
		While (cAliasTmp)->(!Eof())
			//Obtem a base do FKW_BASETR para a parcela renegociada
			nBasPropR := ((cAliasTmp)->FKW_BASETR * nPercPar) / 100 

			//Obtem a base do FKW_BASENR para a parcela renegociada
			nBasPropN := ((cAliasTmp)->FKW_BASENR * nPercPar) / 100 

			//Obtem o percentual do FKW_PERC para a parcela renegociada
			nPerPropR := (nBasPropR / nBasParc) * 100 

			//Obtem o percentual do FKW_PERC para a parcela renegociada
			nPerPropN := (nBasPropN / nBasParc) * 100 

			//Grava dados no array de retorno
			Aadd(aNatProp,{(cAliasTmp)->FKW_NATREN, nBasPropR, nPerPropR, nBasPropN, nPerPropN,(cAliasTmp)->FKW_NUMPRO,(cAliasTmp)->FKW_TPPROC,(cAliasTmp)->FKW_CODSUS })
			
			(cAliasTmp)->(DbSkip())
		EndDo	
		(cAliasTmp)->(DbCloseArea())

	Endif

Return aNatProp
