#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TAFXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TOTVS.CH"

#DEFINE TCD_UF     01
#DEFINE TCD_TAM    02
#DEFINE TCD_FATF   03
#DEFINE TCD_DVXROT 04
#DEFINE TCD_DVXMD  05
#DEFINE TCD_DVXTP  06 
#DEFINE TCD_DVYROT 07
#DEFINE TCD_DVYMD  08
#DEFINE TCD_DVYTP  09
#DEFINE TCD_DIG14  10
#DEFINE TCD_DIG13  11
#DEFINE TCD_DIG12  12
#DEFINE TCD_DIG11  13
#DEFINE TCD_DIG10  14
#DEFINE TCD_DIG09  15
#DEFINE TCD_DIG08  16
#DEFINE TCD_DIG07  17
#DEFINE TCD_DIG06  18
#DEFINE TCD_DIG05  19
#DEFINE TCD_DIG04  20
#DEFINE TCD_DIG03  21
#DEFINE TCD_DIG02  22
#DEFINE TCD_DIG01  23
#DEFINE TCD_CRIT   24

#DEFINE LARGURA_DO_SBUTTON 32

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_RECIBO 				15

/// Arrays utilizados para fazer cache das informações, visando maior performance na importação dos Layouts TAF/Mile
Static __aFilCach     := {}
Static __aSM0BaseCNPJ := Nil
Static __cBanco       := Nil
Static __cCacheID     := ""
Static __cFilC1E      := Nil
Static __cFilCach     := ""
Static __cLibVer      := Nil
Static __cTmpAlia     := ""
Static __lCanBulk     := Nil
Static __oQryT1U      := Nil
Static __OQRYT3A      := Nil
Static aCacheC01      := {}
Static aCacheC02      := {}
Static aCacheC09      := {}
Static aCacheC0G      := {}
Static aCacheC0U      := {}
Static aCacheC0Y      := {}
Static aCacheC11      := {}
Static aCacheC17      := {}
Static aCacheC1A      := {}
Static aCacheC1J      := {}
Static aCacheC1N      := {}
Static aCacheC1O      := {}
Static aCacheC1P      := {}
Static aCacheC1V      := {}
Static aCacheC3D      := {}
Static aCacheC6C      := {}
Static aCacheC86      := {}
Static aCacheT71      := {}
Static aUsrAccess     := {} //Array para otimização de performance de consultas a MPUserHasAccess
Static cTAFXLOGMSG    := GetSrvProfString( 'TAFLOGMESSAGE' , '0' )
Static lFindClass     := FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools
Static lTAFCodRub     := FindFunction("TAFCodRub")
Static lTsi           := IsInCallStack( "Ws034PutPost" )
Static oReport        	:= Nil

//------------------------------------------------------------------
/*/{Protheus.doc} TAFXFUN

Fonte generico das funcionalidades do TAF - Totvs Fiscal Unico.

@author Gustavo G. Rueda
@since 13/04/2012
@version 1.0

/*/

//------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldUni
Funcao generica de validacao da chave unica da tabela utilizando EXISTCPO

@param	cAlias - Alias da tabela para o EXISTCPO
		nOrder - Caso seja necessario alterar a ordem de pesquisa
do EXISTCPO
		cChave - Deve ser enviado caso seja uma chave diferente do
				padrao da funcao, o proprio campo em edicao no momento (READVAR)

		lUpper - Default converte em Maiúsculas a string de busca, caso utilize
case-sensitive envie .F. (False) no parâmetro
@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldUni( cAlias as Character, nOrder as Numeric, cChave as Character, lUpper as Logical )

	Local cCmp     as Character
	Local lOk      as Logical
	Local lPerApur as Logical

	Default nOrder := 1
	Default cChave := &( ReadVar() )
	Default lUpper := .T.

	cCmp     := ReadVar()
	lOk      := .T.
	lPerApur := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leonardo Kichitaro - 18/08/2018  							    ³
	//³																	³
	//³Regra para verificar se existe uma reabertura no periodo         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias == 'CUO'

		//T1S_FILIAL+T1S_INDAPU+T1S_PERAPU+T1S_ATIVO
		T1S->( DbSetOrder( 2 ) )
		If T1S->( MsSeek( xFilial( 'T1S' ) + cChave + "1") )
			lPerApur := .T.
		EndIf
		lOk := .F.

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Felipe Morais - 14/09/2018		  							    ³
	//³																	³
	//³Regra para verificar limite de 3 envios por período	            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias == 'T72'

		lPerApur := .T.
		lOk := .F.

	EndIf

	If cAlias == 'CMR'

		lPerApur := .T.
		lOk := .F.

		//CMR_FILIAL+CMR_INDAPU+CMR_PERAPU+CMR_TPINSC+CMR_INSCES+CMR_ATIVO
		DbSelectArea("CMR")
		CMR->( DbSetOrder( 2 ) )
		If CMR->( MsSeek( xFilial( 'CMR' ) + cChave + "1") )

			While CMR->(!Eof()) .And. CMR->(CMR_FILIAL+CMR_INDAPU+CMR_PERAPU+CMR_TPINSC+CMR_INSCES+CMR_ATIVO) == (xFilial( 'CMR' ) + cChave + "1")

				If CMR->CMR_EVENTO == "I"

					lPerApur := .F.
					lOk := .T.
					Exit

				EndIf

				CMR->(DbSkip())

			EndDo

		EndIf

	EndIf

	/*
	Inclusão de validação em virtude de alteração de chave no evento S-2210
	*/
	If cAlias == 'CM0'

		nOrder  := 7
		cChave  += M->CM0_TPCAT + M->CM0_NRCAT

	EndIf

	If cAlias $ "T1V|T1U|T0F|V76|V77|V78|"

		If cAlias == 'T1V'

			DbSelectArea("T1V")
			T1V->( DbSetOrder( 3 ) )
			If T1V->( MsSeek( xFilial( 'T1V' ) + cChave ) )

				If T1V->T1V_EVENTO == 'E' .And. T1V->T1V_STATUS == "7"
					lPerApur := .T.
					lOk 	 := .F.
				EndIf

			EndIf

		EndIf

		If ProcName(17) == "GOSETEXTEMP" .Or. ProcName(17) == "ALTCADTRAB"

			If !xVldExtemp(cAlias, ProcName(17))

				lPerApur := .T.
				lOk 	 := .T.

				If ProcName(17) == "GOSETEXTEMP"
					Help(, , STR0008, , STR0192, 1, 0, , , , , , {STR0195}) //"ATENÇÄO" ..... "Não pode ser incluída alteração com data superior a ultima alteração via extemporâneo." ..... "Incluir alterações retroativas via extemporâneo."
				Else
					Help(, , STR0008, , STR0193, 1, 0, , , , , , {STR0194}) //"ATENÇÄO" ..... "Não pode ser incluída alteração com data menor que a última alteração."  ..... "Incluir nova alteração via tela trabalhador."
				EndIf

			EndIf

		EndIf

	EndIf

	If cAlias == "T1M"

		lPerApur := .T.
		lOk 	 := .F.
	
		T1M->(DbSetOrder(2) )
		If T1M->( MsSeek( xFilial( 'T1M' ) + cChave + "1") )

			While T1M->(!Eof()) .And. T1M->(T1M_FILIAL+T1M_INDAPU+T1M_PERAPU+T1M_IDESTA+T1M_ATIVO) == (xFilial( 'T1M' ) + cChave + "1")

				If T1M->T1M_EVENTO <> "E" .And. T1M->T1M_STATUS <> "7" 

					cChave := cChave + "1"
					lPerApur := .F.
					lOk := .T.

					Exit

				EndIf	

				T1M->(DBSkip())

			EndDo

		EndIf

		
	ElseIf cAlias == "T62"

		lPerApur := .T.
		lOk 	 := .F.
	
		T62->(DbSetOrder(nOrder) )
		If T62->( MsSeek( xFilial( 'T62' ) + cChave + "1") )

			While T62->(!Eof()) .And. T62->(T62_FILIAL+T62_INDAPU+T62_PERAPU+T62_IDBEN+T62_ATIVO) == (xFilial( 'T62' ) + cChave + "1")

				If T62->T62_EVENTO <> "E" .OR. T62->T62_STATUS <> "7" 

					cChave := cChave + "1"
					lPerApur := .F.
					lOk := .T.

				EndIf	

				T62->(DBSkip())

			EndDo

		EndIf

	ElseIf cAlias == "T2A"

		lPerApur := .T.
		lOk 	 := .F.

		T2A->(DbSetOrder(2) )
		If T2A->( MsSeek( xFilial( 'T2A' ) + cChave + "1") )

			While T2A->(!Eof()) .And. T2A->(T2A_FILIAL+T2A_INDAPU+T2A_PERAPU+T2A_ATIVO) == (xFilial( 'T2A' ) + cChave + "1")

				If T2A->T2A_EVENTO <> "E" .And. T2A->T2A_STATUS <> "7" 

					cChave := cChave + "1"
					lPerApur := .F.
					lOk := .T.

					Exit

				EndIf	

				T2A->(DBSkip())
			EndDo
			
		EndIf

	//As tabelas onde tem as chamadas da função devem ser corrigidas na próxima atualização de dicionário, quando a validação do campo que tenha a 
	//função tiver com o ativo no final esta validação pode ser retirada.
	//Usar quando a alteração do dicionário não puder ser refletida com urgência.
	ElseIf cAlias $ "T3A|T87|CM9|C8B|"

		cChave += "1"
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rodrigo Aguilar - 08/04/2013 																   ³
	//³																			   ³
	//³A variavel lRotImport informa se o processamento esta sendo realizado pelo Mile                 ³
	//³e se o LAYOUT possui filhos, se sim, o tipo de importacao deve ser  OBRIGATORIAMENTE            ³
	//³Exclusao / Inclusao, assim nao eh necessario realizar a validacao da informacao na Base de Dados³
	//³apenas permitir que a inclusao seja realizada.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPerApur

		If Type( "lRotImport" ) == "U" .Or. ( Type( "lRotImport" ) == "L" .And. !lRotImport )

			lOk := ExistCpo( cAlias , IIF(lUpper, Upper(cChave), cChave) , nOrder )

			If lOk
				Help( ,,"TAFJAGRAVADO",,, 1, 0 )
			EndIf

		Else

			lOk := .F.

		EndIf

	EndIf

Return !lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldCmp
Funcao generica de validacao utilizando EXISTCPO e chamando o HELP
do campo

@param	cAlias  - Alias da tabela para o EXISTCPO
		nOrder  - Caso seja necessario alterar a ordem de pesquisa
do EXISTCPO
		cChave  - Deve ser enviado caso seja uma chave diferente do
				padrao da funcao, o proprio campo em edicao no momento (READVAR)
		lID     - Tratamento para criar um facilitador de digitacao, de forma a aceitar
				tanto o ID como o codigo do cadastro (segundo identificador)
		nOrdID  - Ordem/Indice da tabela para o conceito acima (lId == .T.)
		lVldVig - Informa se necessita validacao da Data de Vigencia
		lVldFin - Informa se necessita validacao da Data Inicial e Final
		lVldAtv - Informa se necessita validacao do campo Ativo

@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 13/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldCmp( cAlias , nOrder , cChave , lID , nOrdID , lVldVig , lVldFin , lVldAtv)

	Local cCmp      := ReadVar()
	Local cCmp2     := SubStr( cCmp , 4 )
	Local cAlsMod   := Left( cCmp2 , 3 )
	Local lOk       := .T.
	Local oModel    := Nil
	Local cCompChv  := ''
	Local cChvBkp   := ''
	Local cId       := ""
	Local lRelacC1H := alltrim(cAlias) == 'C1H' .and. alltrim(GetSX3Cache(cCmp2,'X3_F3')) $ ('C1H|C1HA')
	Local cMsgSoluc := 'Nil'

	Default nOrder  := 1
	Default cChave  := &( cCmp )
	Default lID     := .T.
	Default nOrdID  := 1
	Default lVldVig := .F.
	Default lVldFin := .F.
	Default lVldAtv := lVldFin

	If !Vazio() .Or. cCmp2 $ 'C0Q_UF/C30_CFOP'	//Permito conteudo vazio. 	Regra Geral: A obrigatoriedade serah tratada no SAVE do modelo.
		//							  	Regra Especifica: Alguns campos sou obrigado a validar o conteudo,
		//									principalmente campos que estao amarrados a outros, exe: UF + CODMUN,
		// 									um nao eh valido sem o outro.

		If !Vazio()

			lOk := ExistCpo( cAlias , cChave , nOrder )

			// Tratamento para quando for utilizado o conceito de validacao de data vigencia.
			// Se encontrar o registro (lOk) verifica data de vigencia do mesmo
			If lVldVig .and. lOk
				(cAlias)->( DBSetOrder( nOrder ) )
				If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
					lOk := !(!Empty( &( cAlias + "->" + cAlias + "_VALIDA" ) ) .and. &( cAlias + "->" + cAlias + "_VALIDA" ) < dDataBase)
				EndIf
			EndIf

			// Tratamento para quando for utilizado o conceito de validacao pela data final de vigencia do registro
			// Se encontrar o registro (lOk) verifica data de vigencia do mesmo
			If lVldFin .and. lOk
				(cAlias)->( DBSetOrder( nOrder ) )
				If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
					lOk := (Empty( xFunDtPer(&( cAlias + "->" + cAlias + "_DTFIN" )) ) .or. xFunDtPer(&( cAlias + "->" + cAlias + "_DTFIN" ),.T.) >= dDataBase)
				EndIf
			EndIf

			// Tratamento para quando for utilizado o conceito de validacao do campo Ativo do registro
			If lVldAtv .and. lOk
				(cAlias)->( DBSetOrder( nOrder ) )
				If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
					cId := &( cAlias + "->" + cAlias + "_ID" )
					lOk := .F.
					While (cAlias)->(!EOF()) .And. (cId == &( cAlias + "->" + cAlias + "_ID")) .And. !lOk
						lOk := &( cAlias + "->" + cAlias + "_ATIVO" ) == "1"
						(cAlias)->(DBSkip())
					EndDo
				EndIf
			EndIf
			//Tratamento para registros genericos do Bloco X do ECF. Chave deve conter no nome do menu
			If alltrim( SubStr( cCmp , 4 ) ) $ "CFT_REGECF" .and. FunName() == "TAFA332" .and. lOk
				lOk := AllTrim( cChave ) $ Upper( FunDesc() )
			EndIf
			//Tratamento para criar um facilitador de digitacao, de forma a aceitar tanto o ID como o codigo do cadastro (segundo identificador). Ex:
			//	No caso da UF, este tratamento permite informar tanto o ID 000001 para a UF AC quanto o proprio AC, que dae o tratamento abaixo converte
			//		para 000001 automaticamente.
			If lID
				If !lOk
					//Tratamento para quando a chave eh composta e o campo ID eh o ultimo da chave.
					If cAlias != "C20" .And. Len( cChave ) > Len( &( cAlias + '->' + cAlias + "_ID" ) )
						cCompChv	:=	Left( cChave , RAT( &( cCmp ) , cChave ) - 1 )	//Retiro o READVAR (ID)  da chave pq troco no posicione abaixo
					EndIf

					cChvBkp	:=	cChave
					if cAlias == "CH6" .And. nOrder <> 1
						cChave	:=	Posicione( cAlias , nOrder , xFilial( cAlias ) + RTrim( cChvBkp ) , cAlias + "_ID" )
						if !Empty(cChave)
							lOk := .T.
						endif
					elseif cAlias != "C20" .And. Empty( cChave := Posicione( cAlias , nOrdID , xFilial( cAlias ) + cChvBkp , cAlias + "_ID" ) )
						cChave	:=	Posicione( cAlias , nOrdID , xFilial( cAlias ) + RTrim( cChvBkp ) , cAlias + "_ID" )
					EndIf

					If !Empty( cCompChv + cChave ) .And. ( cAlias <> "CH6" .And. nOrder <> 2 )
						If( lOk := ExistCpo( cAlias , cCompChv + cChave , nOrder ) )

							// Tratamento para quando for utilizado o conceito de validacao de data vigencia.
							// Se encontrar o registro (lOk) verifica data de vigencia do mesmo
							If lVldVig
								(cAlias)->( DBSetOrder( nOrder ) )
								If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
									lOk := !(!Empty( &( cAlias + "->" + cAlias + "_VALIDA" ) ) .and. &( cAlias + "->" + cAlias + "_VALIDA" ) < dDataBase)
								EndIf
							EndIf

							// Tratamento para quando for utilizado o conceito de validacao pela data final de vigencia do registro
							// Se encontrar o registro (lOk) verifica data de vigencia do mesmo
							If lVldFin .and. lOk
								(cAlias)->( DBSetOrder( nOrder ) )
								If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
									lOk := (Empty( xFunDtPer(&( cAlias + "->" + cAlias + "_DTFIN" )) ) .or. xFunDtPer(&( cAlias + "->" + cAlias + "_DTFIN" ),.T.) >= dDataBase)
								EndIf
							EndIf

							// Tratamento para quando for utilizado o conceito de validacao do campo Ativo do registro
							If lVldAtv .and. lOk
								(cAlias)->( DBSetOrder( nOrder ) )
								If (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) )
									cId := &( cAlias + "->" + cAlias + "_ID" )
									lOk := .F.
									While (cAlias)->(!EOF()) .And. (cId == &( cAlias + "->" + cAlias + "_ID")) .And. !lOk
										lOk := &( cAlias + "->" + cAlias + "_ATIVO" ) == "1"
										(cAlias)->(DBSkip())
									EndDo
								EndIf
							EndIf

							If lOk
								oModel := FWModelActive()
								oModel:LoadValue( 'MODEL_' + cAlsMod , cCmp2 , cChave )
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		Else
			lOk	:=	.F.
		EndIf

		//Caso a release ja tenha iniciado a unificação dos cadastros, valida se esta usando o cadastro correto!
		if lOk .and. lRelacC1H .and. C1H->(FieldPos('C1H_NEWCAD')) > 0
			(cAlias)->( DBSetOrder( nOrder ) )
			if (cAlias)->( MsSeek( xFilial( cAlias ) + cChave) ) .and. C1H->C1H_NEWCAD == '3'
				lOk := .f.
				cMsgSoluc := "{'" + STR0223 + "'}" //# 'O código informado foi unificado e não esta ativo, por favor use a consulta(F3) para selecionar um código de participante válido!'
			endif
		endif
		
		If !lOk
			Help( ,,AllTrim(SubStr(cCmp,4)),,, 1, 0,,,,,, &cMsgSoluc )
		EndIf
	EndIf

Return lOk
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldIE
Rotina de validacao do digito verificador da IE

@param		ExpC1: Codigo da Inscricao estadual
          	ExpL2: Unidade Federativa
          	ExpL3: Indica se o help devera ser demonstrado         (OPC)

@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 13/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldIE( cIE , cUF , lHelp )

	Local aPesos   := {}
	Local aDigitos := {}
	Local aCalculo := {}
	Local aMi      := {}
	Local nX       := 0
	Local nY       := 0
	Local nDVX     := 0
	Local nDVY     := 0
	Local nPUF     := 0
	Local nPPeso   := 0
	Local nSomaS   := 0
	Local cDigito  := ""
	Local cDVX     := ""
	Local cDVY     := ""
	Local lRetorno := .T.
	Local cIEOrig  := cIE

	DEFAULT lHelp := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta o codigo da Inscricao Estadual                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIE := AllTrim(cIE)
	cIE := StrTran(cIE,".","")
	cIE := StrTran(cIE,"/","")
	cIE := StrTran(cIE,"-","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recebe o ID da UF e retorna a UF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	C09->( dbSetOrder( 3 ) )
	If C09->( MsSeek ( xFilial("C09") + cUF ) )
		cUf := AllTrim(C09->C09_UF)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem da Tabela de Calculo                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cIEOrig) .And. Empty(cIE) .And. !Empty(cUF)
		lRetorno := .F.
	EndIf
	If !Empty(cIE) .And. !"ISENT"$cIE .And. lRetorno
		aadd(aCalculo,{"AC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=1","09","09","09","09","09","09","DVX",{||Len(cIE)==09}})
		aadd(aCalculo,{"AC",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=1","09","09","09","09","09","09","09","09","09","DVX","DVY",{||Len(cIE)==13}})
		aadd(aCalculo,{"AL",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=4","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"AP",09,00,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE<="030170009"}})
		aadd(aCalculo,{"AP",09,01,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030170010".And.cIE<="030190229"}})
		aadd(aCalculo,{"AP",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030190230"}})
		aadd(aCalculo,{"AM",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","=0","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"BA",08,00,"E ",10,"P02","E ",10,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"0123458" .AND. Len( cIE )==8}})
		aadd(aCalculo,{"BA",08,00,"E ",11,"P02","E ",11,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"679".AND. Len( cIE )==8}})
		aadd(aCalculo,{"BA",09,00,"E ",10,"P02","E ",10,"P03","--","--","--","--","--","09","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,2,1)$"0123458" .AND. Len( cIE )==9}})
		aadd(aCalculo,{"BA",08,00,"E ",11,"P02","E ",11,"P03","--","--","--","--","--","09","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,2,1)$"679".AND. Len( cIE )==9}})
		aadd(aCalculo,{"CE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"DF",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=78","=345","09","09","09","09","09","09","09","09","DVX","DVY",{|| Len(cIE)==13 .AND. SubStr(cIE,3,1)  $ "345"}})
		aadd(aCalculo,{"DF",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=78","09","09","09","09","09","09","09","09","09","DVX","DVY",{|| Len(cIE)==13 .AND. !SubStr(cIE,3,1)  $ "345"}})
		aadd(aCalculo,{"ES",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"GO",09,01,"F ",11,"P01","  ",00,"   ","--","--","--","--","--","=12","=015","09","09","09","09","09","09","DVX",{||cIE>="101031050".And.cIE<="101199979"}})
		aadd(aCalculo,{"GO",09,00,"F ",11,"P01","  ",00,"   ","--","--","--","--","--","=12","=015","09","09","09","09","09","09","DVX",{||!(cIE>="101031050".And.cIE<="101199979")}})
		aadd(aCalculo,{"MA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=2","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"MT",11,00,"E ",11,"P01","  ",00,"   ","--","--","--","09","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"MS",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=8","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"MG",13,00,"AE",10,"P10","E ",11,"P11","--","09","09","09","09","09","09","09","09","09","09","09","DVX","DVY",{||SubStr(cIE,1,1)<>"P".And.Len(cIE)==13}})
		aadd(aCalculo,{"MG",09,00,"  ",00,"P09","  ",00,"   ","--","--","--","--","--","=P","=R","09","09","09","09","09","09","09",{||SubStr(cIE,1,1)=="P".And.Len(cIE)==9}})
		aadd(aCalculo,{"PA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=5","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"PB",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"PR",10,00,"E ",11,"P09","E ",11,"P08","--","--","--","--","09","09","09","09","09","09","09","09","DVX","DVY",{||.T.}})
		aadd(aCalculo,{"PE",14,01,"E ",11,"P07","  ",00,"   ","=1","=8","19","09","09","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==14}})
		aadd(aCalculo,{"PE",09,00,"E ",11,"P02","E ",11,"P01","--","--","--","--","--","09","09","09","09","09","09","09","DVX","DVY",{||Len(cIE)==9}})
		aadd(aCalculo,{"PI",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=9","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"RJ",08,00,"E ",11,"P08","  ",00,"   ","--","--","--","--","--","--","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"RN",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=0","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
		aadd(aCalculo,{"RN",10,00,"BD",11,"P11","  ",00,"   ","--","--","--","--","=2","=0","09","09","09","09","09","09","09","DVX",{||Len(cIE)==10}})
		aadd(aCalculo,{"RS",10,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"RO",09,01,"E ",11,"P04","  ",00,"   ","--","--","--","--","--","19","09","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
		aadd(aCalculo,{"RO",14,01,"E ",11,"P01","  ",00,"   ","09","09","09","09","09","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==14}})
		aadd(aCalculo,{"RR",09,00,"D ",09,"P05","  ",00,"   ","--","--","--","--","--","=2","=4","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"SC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
		aadd(aCalculo,{"SP",12,00,"D ",11,"P12","D ",11,"P13","--","--","09","09","09","09","09","09","09","09","DVX","09","09","DVY",{||SubStr(cIE,1,1)<>"P"}})
		aadd(aCalculo,{"SP",13,00,"D ",11,"P12","  ",00,"   ","--","=P","09","09","09","09","09","09","09","09","DVX","09","09","09",{||SubStr(cIE,1,1)=="P"}})
		aadd(aCalculo,{"SE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
		aadd(aCalculo,{"TO",11,00,"E ",11,"P06","  ",00,"   ","--","--","--","=2","=9","09","=1239","09","09","09","09","09","09","DVX",{||.T.}})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem da Tabela de Pesos                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,02,00}) //01
		aadd(aPesos,{05,04,03,02,09,08,07,06,05,04,03,02,00,00}) //02
		aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,00,02}) //03
		aadd(aPesos,{00,00,00,00,00,00,00,00,06,05,04,03,02,00}) //04
		aadd(aPesos,{00,00,00,00,00,01,02,03,04,05,06,07,08,00}) //05
		aadd(aPesos,{00,00,00,09,08,00,00,07,06,05,04,03,02,00}) //06
		aadd(aPesos,{05,04,03,02,01,09,08,07,06,05,04,03,02,00}) //07
		aadd(aPesos,{08,07,06,05,04,03,02,07,06,05,04,03,02,00}) //08
		aadd(aPesos,{07,06,05,04,03,02,07,06,05,04,03,02,00,00}) //09
		aadd(aPesos,{00,01,02,01,01,02,01,02,01,02,01,02,00,00}) //10
		aadd(aPesos,{00,03,02,11,10,09,08,07,06,05,04,03,02,00}) //11
		aadd(aPesos,{00,00,01,03,04,05,06,07,08,10,00,00,00,00}) //12
		aadd(aPesos,{00,00,03,02,10,09,08,07,06,05,04,03,02,00}) //13

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao dos digitos da inscricao estadual                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPUF := aScan(aCalculo,{|x| x[TCD_UF] == cUF .And. Eval(x[TCD_CRIT])})
		If nPUF <> 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao do Tamanho da inscricao estadual                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case

			Case aCalculo[nPUF][2] <> Len(cIE) .And. cUF == "TO"
				cIE := SubStr(cIe,1,2)+"01"+SubStr(cIe,3)
				
			EndCase
			nY := TCD_DIG01+1
			For nX := Len(cIE) To 1 STEP - 1
				cDigito := SubStr(cIE,nX,1)
				nY--
				Do Case
				Case SubStr(aCalculo[nPUF][nY],1,2)=="DV"
					If IsAlpha(cDigito) .Or. IsDigit(cDigito)
						If SubStr(aCalculo[nPUF][nY],1,3)=="DVX"
							cDVX := cDigito
						Else
							cDVY := cDigito
						EndIf
					Else
						lRetorno := .F.
					EndIf
				Case SubStr(aCalculo[nPUF][nY],1,2)=="--"
					lRetorno := .F.
					Exit
				Case SubStr(aCalculo[nPUF][nY],1,1)=="="
					If !cDigito $ SubStr(aCalculo[nPUF][nY],2)
						lRetorno := .F.
						Exit
					EndIf
				OtherWise
					If !(cDigito >= SubStr(aCalculo[nPUF][nY],1,1) .And. cDigito <= SubStr(aCalculo[nPUF][nY],2,1))
						lRetorno := .F.
						Exit
					EndIf
				EndCase
				aadd(aDigitos,cDigito)
			Next nX
		Else
			lRetorno := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do digito verificador DVX                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno

			nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVXTP],2))
			nSomaS := 0
			aMI    := {}

			For nX := 1 To Len(aDigitos)
				aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
				nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
			Next nX

			If "A"$aCalculo[nPUF][TCD_DVXROT]
				For nX := 1 To Len(aMi)
					nSomaS += Int(aMi[nX] / 10)
				Next nX
			EndIf

			If "B"$aCalculo[nPUF][TCD_DVXROT]
				nSomaS *= 10
			EndIf

			If "C"$aCalculo[nPUF][TCD_DVXROT]
				nSomaS += 5+4*aCalculo[nPUF][TCD_FATF]
			EndIf

			If "D"$aCalculo[nPUF][TCD_DVXROT]
				nDVX := Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
			EndIf

			If "E"$aCalculo[nPUF][TCD_DVXROT]
				nDVX := aCalculo[nPUF][TCD_DVXMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
			EndIf

			If "F"$aCalculo[nPUF][TCD_DVXROT]

				nDVX := aCalculo[nPUF][TCD_DVXMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
				If nDVX == 11
					nDVX := 0
				EndIf
				If nDVX == 10
					nDVX := aCalculo[nPUF][TCD_FATF]
				EndIf

			EndIf

			If nDVX == 10
				nDVX := 0
			EndIf

			If nDVX == 11
				nDVX := aCalculo[nPUF][TCD_FATF]
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do digito verificador DVY                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCalculo[nPUF][TCD_DVYROT])

				nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVYTP],2))
				nSomaS := 0
				aMi    := {}

				For nX := 1 To Len(aDigitos)
					aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
					nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
				Next nX

				If "A"$aCalculo[nPUF][TCD_DVYROT]
					For nX := 1 To Len(aMi)
						nSomaS += Int(aMi[nX] / 10)
					Next nX
				EndIf

				If "B"$aCalculo[nPUF][TCD_DVYROT]
					nSomaS *= 10
				EndIf

				If "C"$aCalculo[nPUF][TCD_DVYROT]
					nSomaS *= 5+4*aCalculo[nPUF][TCD_FATF]
				EndIf

				If "D"$aCalculo[nPUF][TCD_DVYROT]
					nDVY := Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
				EndIf

				If "E"$aCalculo[nPUF][TCD_DVYROT]
					nDVY := aCalculo[nPUF][TCD_DVYMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
				EndIf

				If nDVY == 10
					nDVY := 0
				EndIf

				If nDVY == 11
					nDVY := aCalculo[nPUF][TCD_FATF]
				EndIf

			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificacao dos digitos calculados                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Val(cDVX) <> nDVX .Or. Val(cDVY) <> nDVY
				lRetorno := .F.
			EndIf

		EndIf

	EndIf

	If !lRetorno .And. lHelp
		Help(" ",1,"IE")
	EndIf

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunWizard

Função de montagem da Wizard da rotina.

@Param		aTxtApre		-	Array com o cabeçalho da Wizard
			aPaineis		-	Array com os painéis da Wizard
			cNomeWizard	-	Nome do arquivo da Wizard
			cNomeAnt		-	Nome do arquivo anterior da Wizard, caso tenha mudado de nome
			nTamSay		-
			lBackIni		-
			bFinalExec		-	Bloco de código a ser executado ao final da Wizard

@Return	lRet	-	Estrutura
						.T. Para validação OK
						.F. Para validação NÃO OK

@Author	Gustavo G. Rueda
@Since		24/04/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function xFunWizard( aTxtApre, aPaineis, cNomeWizard, cNomeAnt, nTamSay, lBackIni, bFinalExec )

	Local oFont        := Nil
	Local oWizard      := Nil
	Local cAuxVar      := ""
	Local cAlsF3       := ""
	Local cBLine       := ""
	Local cSep         := ""
	Local cTextoMGet   := ""
	Local nInd         := 0
	Local nInd2        := 0
	Local nI           := 0
	Local nObject      := 0
	Local nLinha       := 0
	Local nColuna      := 10
	Local nTamCmpDlg   := 115
	Local nTpColIni    := 0
	Local nQtdTW       := 0
	Local lMarkCB      := .F.
	Local lIniWiz      := .F.
	Local lFim         := .F.
	Local lRet         := .T.
	Local lGetRdOnly   := .F.
	Local lInitPad     := .F.
	Local lPassword    := .F.
	Local aItObj       := {}
	Local aButtons     := {}
	Local aFunParGet   := {}
	Local aVarPaineis  := {}
	Local aIniWiz      := {}
	Local aHeader      := {}
	Local aArea        := GetArea()
	Local bProcura     :={|| }
	Local bValidGet    :={|| }
	Local bDblClick    :={|| }
	Local bNext        :={|| }
	Local bBack        :={|| }
	Local bFinish      :={|| }
	Local bWhen        :={|| }
	Local lGetDir	   := .F.	

	Default cNomeAnt   := ""
	Default nTamSay    := 0
	Default lBackIni   := .F.
	Default bFinalExec := Nil

	lIniWiz := xFunLoadProf( Iif( Empty( cNomeAnt ), cNomeWizard, cNomeAnt ), @aIniWiz )

	Define FONT oFont NAME "Arial" SIZE 00,-11 BOLD

	Define WIZARD oWizard;
		TITLE SubStr( aTxtApre[1], 1, 80 );
		HEADER SubStr( aTxtApre[2], 1, 80 );
		MESSAGE SubStr( aTxtApre[3], 1, 80 );
		TEXT aTxtApre[4];
	NEXT { || .T. };
	FINISH { || .T. }

	For nInd := 1 to Len( aPaineis )

		//---------------------------------------------------
		// Tratamento para casos em que é passada posição 4.
		// Utilizado para Code Block do botão Avançar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 4 .and. aPaineis[nInd,4] <> Nil
			bNext := &( "{ || Iif( xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,4] + ", .F. ) }" )
		Else
			bNext := &( "{ || xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
		EndIf

		//---------------------------------------------------
		// Tratamento para casos em que é passada posição 5.
		// Utilizado para Code Block do botão Voltar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 5 .and. aPaineis[nInd,5] <> Nil
			bBack := &( "{ || Iif( xValWizB( lBackIni, oWizard ), " + aPaineis[nInd,5] + ", .F. ) }" )
		Else
			bBack := &( "{ || xValWizB( lBackIni, oWizard ) }" )
		EndIf

		//---------------------------------------------------
		// Tratamento para casos em que é passada posição 6.
		// Utilizado para Code Block do botão Finalizar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 6 .and. aPaineis[nInd,6] <> Nil
			bFinish := &( "{ || Iif( lFim := xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,6] + ", .F. ) }" )
		Else
			bFinish := &( "{ || lFim := xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
		EndIf

		CREATE PANEL oWizard;
			HEADER aPaineis[nInd,1];
			MESSAGE aPaineis[nInd,2];
			BACK bBack;
		NEXT bNext;
		FINISH bFinish

	//-----------------------------------------------------------------------
	// Este array aVarPaineis contém as variáveis objetos dos
	// componentes de cada painél. Sua estrutura é a seguinte:
	// 1 - { <conteúdo atribuído ao componente através da dialog>,<variável do objeto componente>}
	// 2 - ...
	// 3 - ...
	// .
	// .
	// Obs: As linhas do array indicam cada componente do respectivo painél.
	//-----------------------------------------------------------------------
	aAdd( aVarPaineis, {} )

	nLinha		:=	0
	nColuna	:=	10
	nObject	:=	0

	For nInd2 := 1 to Len( aPaineis[nInd,3] )

		//Obs: A Coluna pode mudar de valor caso a posição 18 do aPaineis existir
		//neste caso a coluna terá o valor 10 e o nTamCmpDlg será multiplicado por 2
		If ( nInd2 % 2 == 0 )
			nColuna	:=	nTamCmpDlg + 20
		Else
			nColuna	:=	10
			nLinha		+=	10
		EndIf

		nTpObj		:=	Iif( aPaineis[nInd][3][nInd2][1] == Nil, 0, aPaineis[nInd][3][nInd2][1] )					//Tipo do objeto = 1=SAY, 2=MSGET, 3=COMBOBOX, 4=CHECKBOX, 5=LISTBOX, 6=RADIO, 7=BUTTON	,8=Multi-Get	( OBRIGATORIO )
		cTitObj		:=	Iif( aPaineis[nInd][3][nInd2][2] == Nil, "", OemToAnsi( aPaineis[nInd][3][nInd2][2] ) )	//Título do objeto, quando tiver. Ex: SAY( Caption ), CHECKBOX									( G=OPCIONAL, E=OBRIGATORIO )
		cPctObj		:=	Iif( aPaineis[nInd][3][nInd2][3] == Nil, "", aPaineis[nInd][3][nInd2][3] )				//Picture quando for necessário. Ex: MSGET														( G=OPCIONAL, E=OBRIGATORIO )
		cTpContObj	:=	Iif( aPaineis[nInd][3][nInd2][4] == Nil, "", aPaineis[nInd][3][nInd2][4] )				//Tipo de conteúdo do objeto. Ex: 1=Caracter, 2=Numérico, 3=Data								( G=OPCIONAL, E=OBRIGATORIO )
		nDecObj		:=	Iif( aPaineis[nInd][3][nInd2][5] == Nil, 0 , aPaineis[nInd][3][nInd2][5] )				//Número de casas decimais do objeto MSGET caso seja numérico.									( G=OPCIONAL, E=OBRIGATORIO )
		aItObj		:=	Iif( aPaineis[nInd][3][nInd2][6] == Nil, {}, aPaineis[nInd][3][nInd2][6] )				//Itens de seleção dos objetos. Ex: COMBOBOX, LISTBOX, RADIO									( G=OPCIONAL, E=OBRIGATORIO )
		lMarkCB		:=	Iif( aPaineis[nInd][3][nInd2][7] == Nil, .F., aPaineis[nInd][3][nInd2][7] )				//Opção de seleção do item quando CHECKBOX. Determina se iniciará marcado ou não.			( G=OPCIONAL, E=OBRIGATORIO )
		nNumIntObj	:=	Iif( aPaineis[nInd][3][nInd2][8] == Nil, 0, aPaineis[nInd][3][nInd2][8] )					//Número de casas inteiras quando o conteúdo do objeto MSGET for numérico.					( G=OPCIONAL, E=OBRIGATORIO )
		cIniPad		:=  Iif( Len(aPaineis[nInd][3][nInd2]) < 22 , "", aPaineis[nInd][3][nInd2][22] )
		If ( Len( aPaineis[nInd][3][nInd2] ) >= 9 ) .and. aPaineis[nInd][3][nInd2][9] <> Nil

			lGetRdOnly	:=	aPaineis[nInd][3][nInd2][9][1]
			cTitObj	:=	aPaineis[nInd][3][nInd2][9][2]

			If Len( aPaineis[nInd][3][nInd2][9] ) >= 3
				lInitPad := aPaineis[nInd][3][nInd2][9][3]
			Else
				lInitPad := aPaineis[nInd][3][nInd2][9][1]
			EndIf

		Else
			lGetRdOnly := .F.
		EndIf

		If ( Len( aPaineis[nInd][3][nInd2] ) >= 10 ) .and. aPaineis[nInd][3][nInd2][10] <> Nil
			lGetFile := aPaineis[nInd][3][nInd2][10]
		Else
			lGetFile := .F.
		EndIf

		If ( Len( aPaineis[nInd][3][nInd2] ) >= 11 ) .and. aPaineis[nInd][3][nInd2][11] <> Nil
			cAlsF3 := aPaineis[nInd][3][nInd2][11]
		Else
			cAlsF3 := ""
		EndIf

		
		//------------------------------------------------------------
		// Tratamento para casos em que é passada posição 13.
		// Utilizado para validar o conteúdo dos campos da wizard.
		// Deverá ser enviado dentro de um array o nome da função que
		// será utilizada para realizar a validação e os parâmetros
		// necessários para processar esta função.
		// Exemplo de utilização: TAFXECF( CriaWzECF )
		//------------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 13 .and. aPaineis[nInd,3,nInd2,13] <> Nil
			aFunParGet	:=	aPaineis[nInd,3,nInd2,13]
			bValidGet	:=	&( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 + 1 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 - 1 ) ) + "], @aVarPaineis, aButtons, oWizard ) }" )
		Else
			aFunParGet	:=	{}
			bValidGet	:=	{ || }
		EndIf

		//----------------------------------------------------------------------
		// Tratamento para casos em que é passada posição 14.
		// Utilizado para Header de objetos que necessitam desta funcionalidade
		//----------------------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 14 .and. aPaineis[nInd,3,nInd2,14] <> Nil
			aHeader := aPaineis[nInd,3,nInd2,14]
		Else
			aHeader := {}
		EndIf

		//----------------------------------------------------
		// Tratamento para casos em que é passada posição 15.
		// Utilizado para tipo da primeira coluna do Browse
		// 1=MARK, 2=LEGEND
		//----------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 15 .and. aPaineis[nInd,3,nInd2,15] <> Nil
			nTpColIni := aPaineis[nInd,3,nInd2,15]
		Else
			nTpColIni := 0
		EndIf

		//-------------------------------------------------------
		// Tratamento para casos em que é passada posição 16.
		// Utilizado para Bloco de Código de Double Click
		// Obs: Opção automática de Marca/Desmarca quando é MARK
		//-------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 16 .and. aPaineis[nInd,3,nInd2,16] <> Nil
			bDblClick := &( "{ || " + aPaineis[nInd,3,nInd2,16] + " }" )
		Else
			bDblClick := { || }
		EndIf

		//-------------------------------------------------------
		// Tratamento para casos em que é passada posição 17.
		// Utilizado para Bloco de Código de Action
		//-------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 17 .and. aPaineis[nInd,3,nInd2,17] <> Nil
			bAction := &( "{ || " + aPaineis[nInd,3,nInd2,17] + " }" )
		Else
			bAction := { || }
		EndIf

		//-------------------------------------------------------
		// Tratamento para casos em que é passada posição 18.
		// o objeto ira ocupar o tamnho das 2 colunas e seu tamanho será dobrado
		// para o mesmo ocupar toda a largura da linha na qual está posicionado.
		//-------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 18 .and. aPaineis[nInd,3,nInd2,18] <> Nil
			If aPaineis[nInd,3,nInd2,18]
				nTamCmpDlg := nTamCmpDlg*2 + 10
				nColuna := 10
			EndIf
		Else
			nTamCmpDlg := 115
		EndIf

		//-------------------------------------------------------
		// Tratamento para casos em que é passada posição 19.
		// Seta a propriedade de Password em um campo TGET
		//-------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 19 .and. aPaineis[nInd,3,nInd2,19] <> Nil
			lPassword := aPaineis[nInd,3,nInd2,19]
		Else
			lPassword := .F.
		EndIf
		//------------------------------------------------------------
		// Posição 20.
		// Determina se deve gravar as Informações do objeto no profile
		// A lógica está na função FatXGrvWizard
		//-------------------------------------------------------------

		//------------------------------------------------------------
		// Posição 21.
		// Texto padrão para os objetos TMULTIGET
		//-------------------------------------------------------------
		If Len( aPaineis[nInd,3,nInd2] ) >= 21 .and. aPaineis[nInd,3,nInd2,21] <> Nil
			cTextoMGet := aPaineis[nInd,3,nInd2,21]
		Else
			cTextoMGet := ""
		EndIf

		//------------------------------------------------------------
		// Posição 22.
		// Iniciar padrão
		//-------------------------------------------------------------

		//Se já exisitir um .WIZ criado anteriormente carrego-o para exibição e alteração conforme necessidade.
		If lIniWiz .and. ( nTpObj >= 2 .and. nTpObj <= 8 ) //Somente objetos que geram txt

			//Contador somente dos objetos que irão gerar o txt para que se possa recuperá-lo na ordem de exibição dos objetos de cada painél.
			nObject ++

			//No caso de CHECKBOX não posso armazenar "" e sim lógico.
			If nTpObj == 4
				aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )
			Else
				aAdd( aVarPaineis[nInd], { "", } )
			EndIf

			//Contém somente o conteúdo que será atribuído em cada objeto. Sem a cláusula { OBJ??? } que é gerado no txt.
			If Len( aIniWiz ) >= nInd
				If Len( aIniWiz[nInd] ) >= nObject
					cStrIniWiz := aIniWiz[nInd,nObject]
				Else
					cStrIniWiz := ""
				EndIf
			Else
				cStrIniWiz := ""
			EndIf

			//Caso venha conteúdo a ser utilizado pela wizard devo desconsiderar os valores de antes e assumir sempre o default passado como parâmetro.
			If lInitPad .and. !Empty( cTitObj ) .and. nTpObj == 2
				cStrIniWiz := cTitObj
			EndIf

		ElseIf lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 1 ) //Somente objetos que não geram txt.

			aAdd( aVarPaineis[nInd], { "", } )

		ElseIf !lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 8 ) //Caso não tenha um .WIZ anterior, carrego os objetos normalmente e no padrão. ( Branco ou lógicos ).

			If lGetRdOnly .and. !Empty( cTitObj ) .and. nTpObj == 2
				cStrIniWiz := cTitObj
			EndIf

			aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )

		EndIf

		if ( nTpObj >= 2 .and. nTpObj <= 8 ) //Somente objetos que geram txt
			if (("TAFAWIZD" $ cNomeWizard) .and. nInd == 1 .and. nInd2 == 22)
				cStrIniWiz := aItObj[aPaineis[nInd,3,nInd2,22]]
			endif
		endif

		//------------------------------------------------------------
		// Posição 23.
		// Indica se deve passar pelo campo ou não (WHEN)
		//-------------------------------------------------------------
		if Len( aPaineis[nInd,3,nInd2] ) >= 23 .and. aPaineis[nInd,3,nInd2,23] <> Nil
			bWhen := &( "{ || " + cValToChar(aPaineis[nInd,3,nInd2,23]) + " }" )
		else
			bWhen := { || }
		endIf

		//------------------------------------------------------------
		// Posição 24.
		// Indica se for um get para seleção de diretorios
		//-------------------------------------------------------------
		If ( Len( aPaineis[nInd][3][nInd2] ) >= 24 ) .and. aPaineis[nInd][3][nInd2][24] <> Nil
			lGetDir := aPaineis[nInd][3][nInd2][24]
		Else
			lGetDir := .F.
		EndIf

		//Quando o tipo de objeto for SAY, devo tratar somente como informativo, ou seja, somente para exibição na Dialog.
		If nTpObj == 1

			aVarPaineis[nInd][nInd2][2] := TSay():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,, .F., .F., .F., .T., CLR_BLUE,, nTamCmpDlg + nTamSay, 10, .F., .F., .F., .F., .F. )
			aVarPaineis[nInd][nInd2][2]:cCaption := cTitObj

			//Quando o tipo de objeto for tipo MSGET devo tratar os casos de terem conteúdo como Caracter, Numérico ou Data.
		ElseIf nTpObj == 2

			If cTpContObj == 1 //Caracter

				If lIniWiz
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz + Iif( nNumIntObj > Len( cStrIniWiz ), Space( nNumIntObj - Len( cStrIniWiz ) ), "" )
				Else
					aVarPaineis[nInd][nInd2][1] := Iif( !Empty( cTitObj ), cTitObj, Space( nNumIntObj ) )
				EndIf

			ElseIf cTpContObj == 2 //Numérico

				If lIniWiz
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz
				ElseIf nDecObj == 0
					aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) )
				Else
					aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) + "." + Replicate( "0", nDecObj ) )
				EndIf

			ElseIf cTpContObj == 3 //Data

				If lIniWiz
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz
				Else
					aVarPaineis[nInd][nInd2][1] := CToD( "  /  /  " )
				EndIf

			EndIf

			//Verifica se utiliza validação do conteúdo do campo na Wizard. Executa Bloco de Código conforme função e parâmetros enviados.
			If !Empty( aFunParGet )
				bValidGet := &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "], @aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 + 1 ) + "], aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 - 1 ) + "], @aVarPaineis, aButtons, oWizard ) }" )
			EndIf

			aVarPaineis[nInd][nInd2][2] := TGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg - Iif( lGetFile .or. lGetDir, 30, 0 ), 9, cPctObj, bValidGet,,,,,, .T.,,,bWhen,,,, lGetRdOnly,lPassword, cAlsF3 )

			If lGetFile .or. lGetDir
				If lGetFile
					cAuxVar	:=	'aVarPaineis[' +  AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := cGetFile( "", OemToAnsi( "Procurar" ),,,,12345 )'
				Else
					cAuxVar	:=	'aVarPaineis[' +  AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := cGetFile( "*.xml", OemToAnsi( "Procurar" ),,,,128+16 )'
				Endif		
				bProcura	:=	&( '{ || ' + cAuxVar + ', Iif( Empty( aVarPaineis[' + Str( nInd ) + '][' + Str( nInd2 ) + '][1] ), aVarPaineis[' + AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := Space( 115 ), Nil ) }' )

				//Adiciono o botão e a posição do array da variável do cGetFile para uso na função xValWizCmp
				aAdd( aButtons, { TButton():New( nLinha, nColuna + nTamCmpDlg - 30, OemToAnsi( "..." ), oWizard:oMPanel[nInd + 1], bProcura, 30, 12,,, .F., .T., .F.,, .F.,,, .F. ), { nInd, nInd2, 1 } } )
			EndIf
			If !Empty(cIniPad)
				aVarPaineis[nInd][nInd2][2]:cText :=  cIniPad
			EndIf
		ElseIf nTpObj == 3 //Quando o objeto for do tipo COMBOBOX

			If lIniWiz
				aVarPaineis[nInd][nInd2][1] := cStrIniWiz
			elseIf !lIniWiz .and. (("TAFAWIZD" $ cNomeWizard) .and. nInd == 1 .and. nInd2 == 22)
				aVarPaineis[nInd][nInd2][1] := cStrIniWiz
			EndIf

			//Validação para manipular/alterar a criação do cGetFile
			If Len( aFunParGet ) > 0
				Eval( &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "],,, @aVarPaineis, aButtons ) }" ) )
			EndIf

			aVarPaineis[nInd][nInd2][2] := TCombobox():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), aItObj, nTamCmpDlg, 10, oWizard:oMPanel[nInd + 1],,, bValidGet,,, .T.,,,,bWhen )

		ElseIf nTpObj == 4 //Quando o objetvo for do tipo CHECKBOX devo converter caso exista um .WIZ para booleano.

			If lIniWiz
				If (valtype( cStrIniWiz ) = "L")
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz
				ElseIf "T" $ cStrIniWiz
					aVarPaineis[nInd][nInd2][1] := .T.
				Else
					aVarPaineis[nInd][nInd2][1] := .F.
				EndIf
			EndIf

			aVarPaineis[nInd][nInd2][2] := TCheckBox():New( nLinha, nColuna, cTitObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg, 10,,,,, CLR_BLUE,,, .T.,,,bWhen)

		ElseIf nTpObj == 5

			nQtdTW ++
			&( "aItObj" + AllTrim( Str( nQtdTW ) ) ) := aClone( aItObj )
			cAuxVar := "aItObj" + AllTrim( Str( nQtdTW ) )

			aVarPaineis[nInd][nInd2][2] := TWBrowse():New( nLinha, nColuna, 273, 80,, aHeader,, oWizard:oMPanel[nInd + 1],,,,, bDblClick,,,,,,,,, .T.,,,, .T., .T. )
			aVarPaineis[nInd][nInd2][2]:SetArray( &cAuxVar )

			If !Empty( &cAuxVar )

				cSep := ""
				cBLine := "{ || { "
				For nI := 1 to Len( aHeader )

					If nI == 1

						//MARK
						If nTpColIni == 1
							cBLine += cSep + "Iif( " + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "], LoadBitmap( GetResources(), 'LBTIK' ), LoadBitmap( GetResources(), 'LBNO' ) )"
							//LEGEND - Desenvolver
						ElseIf nTpColIni == 2
							cBLine += cSep
						Else
							cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
						EndIf

					Else
						cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
					EndIf

					cSep := ","

				Next nI
				cBLine += " } }"
				aVarPaineis[nInd][nInd2][2]:bLine := &( cBLine )
			EndIf

		ElseIf nTpObj == 6

			If lIniWiz
				aVarPaineis[nInd][nInd2][1] := cStrIniWiz
			EndIf

			aVarPaineis[nInd][nInd2][2] := TRadMenu():New( nLinha, nColuna, aItObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,,,,,,bWhen, nTamCmpDlg, 10,,,, .T. )

		ElseIf nTpObj == 7

			aVarPaineis[nInd][nInd2][2] := TButton():New( nLinha - 2, nColuna, cTitObj, oWizard:oMPanel[nInd + 1], bAction, 50, 10,,,, .T. )

		ElseIf nTpObj == 8
			aVarPaineis[nInd][nInd2][1] := cTextoMGet
			aVarPaineis[nInd][nInd2][2] := tMultiGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],280,120,,,,,,.T.,,,bWhen,,,.T.)

		EndIf

	Next nInd2

	Next nInd

	Activate WIZARD oWizard Centered

	//lFim indica se o botão fim foi pressionado. .T. = Sim ou .F. = Não.
	If lFim
		FatXGrvWizard( cNomeWizard, aVarPaineis, aPaineis )

		If bFinalExec <> Nil
			Eval( bFinalExec )
		EndIf

	Else
		lRet := .F.
	EndIf

	RestArea( aArea )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FATXGrvWizard
Gravacao dos dados inseridos nos objetos no txt (.WIZ)

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
			aVarPaineis - Array com as informacoes digitadas no Wizard
           	aPaineis - Array com os paineis do Wizard

@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FATXGrvWizard ( cNomeWizard , aVarPaineis , aPaineis )

	Local lRet         := .T.
	Local cConteudo    := ""
	Local nInd         := 0
	Local nInd2        := 0
	Local nQtdCasasInt := 0
	Local nQtdCasasDec := 0
	Local nTipObj      := 0
	Local nCtdObj      := 1
	Local nPadR        := 0
	Local aGrava       := {}
	Local lGrvCmp      := .T.

	For nInd := 1 To Len (aVarPaineis)

		nCtdObj		:=	1
		aAdd ( aGrava, "{PAINEL"+StrZero (nInd, 3)+"}" )

		For nInd2 := 1 To Len (aVarPaineis[nInd])

			nQtdCasasInt	:=	aPaineis[nInd][3][nInd2][8]
			nQtdCasasDec	:=	aPaineis[nInd][3][nInd2][5]
			nTipObj			:=	aPaineis[nInd][3][nInd2][1]

			//Verifica se deve grava as informações do campo
			If Len( aPaineis[nInd,3,nInd2] ) >= 20 .and. aPaineis[nInd,3,nInd2,20] <> Nil
				lGrvCmp :=  aPaineis[nInd,3,nInd2,20]
			Else
				lGrvCmp := .T.
			EndIf

			If lGrvCmp

				//Tratamento para gravacao de objetos com retorno logigos, tipo CHECKBOX
				If (ValType (aVarPaineis[nInd][nInd2][1])=="L")

					If (aVarPaineis[nInd][nInd2][1])
						cConteudo	:=	"T"
					Else
						cConteudo	:=	"F"
					EndIf
					nPadR	:=	1

				//Tratamento da gravacao do objeto GET com conteudo do tipo DATA
				ElseIf (ValType (aVarPaineis[nInd][nInd2][1])=="D")

					cConteudo	:=	DToS (aVarPaineis[nInd][nInd2][1])
					nPadR		:=	8

				//tratamento da gravacao do objeto GET com conteudo NUMERICO+CASAS DECIMAIS.
				ElseIf (ValType (aVarPaineis[nInd][nInd2][1])=="N")

					If nTipObj==6
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], 3, 0)
						nPadR	:=	3
					ElseIf (nQtdCasasDec==0)
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], nQtdCasasInt, 0)
						nPadR	:=	nQtdCasasInt
					Else
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], nQtdCasasInt+nQtdCasasDec+1, nQtdCasasDec)	//O 1 eh por causa do ponto Ex: 99.99
						nPadR	:=	nQtdCasasInt+nQtdCasasDec+1
					EndIf

				Else

					//Tratamento do objeto GET para conteudos CARACTER onde devera menter a quantidade de casas na gravacao para que nao
					//	ocasione problema de truncagem no momendo da recuperacao das informacoes para exibicao no CFP.
					If (nQtdCasasInt<>Nil .And. nQtdCasasInt>0)
						cConteudo	:=	SubStr (aVarPaineis[nInd][nInd2][1], 1, nQtdCasasInt)
						nPadR		:=	nQtdCasasInt
					Else
						cConteudo	:=	aVarPaineis[nInd][nInd2][1]
						nPadR		:=	Len (aVarPaineis[nInd][nInd2][1])
					EndIf

				EndIf

			Else
				cConteudo := ""
			EndIf

			If (nTipObj>1)

				cConteudo	:=	"{OBJ"+StrZero (nCtdObj++, 3)+";"+ValType (aVarPaineis[nInd][nInd2][1])+";"+AllTrim (StrZero (nPadR, 3))+"}"+cConteudo
				aAdd ( aGrava, cConteudo )

			EndIf

		Next (nInd2)

	Next (nInd)

	If nInd >= 1
		XFUNSaveProf ( cNomeWizard , aGrava )
	EndIf

Return (lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNSaveProf
Funcao que salva os parametros no profile

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
			aParametros - Array com o conteudo dos campos do Wizard para gravacao no profile

@return lOk - Estrutura
			.T. Para validacao OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XFUNSaveProf ( cNomeWizard , aParametros )

	Local nX        := 0
	Local cWrite    := ""
	Local cBarra    := If ( IsSrvUnix () , "/" , "\" )
	Local lRet      := .T.
	Local cUserName := __cUserID

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	For nX := 1 to Len(aParametros)
		cWrite 	+= 	aParametros[nx]+CRLF
	Next

	cNomeWizard	:=	cNomeWizard+"_"+cUserName
	MemoWrit ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNLoadProf
Funcao que carrega os parametros no profile

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
			aParametros - Array com o conteudo do arquivo texto do Wizard (RETORNO POR REFERENCIA)

@return lOk - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNLoadProf ( cNomeWizard , aIniWiz )

	Local nJ        := 0
	Local nI        := 0
	Local cBarra    := Iif ( IsSrvUnix() , "/" , "\" )
	Local cTipo     := ""
	Local nPadR     := 0
	Local cLinha    := ""
	Local lRet      := .F.
	Local cUserName := __cUserID

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	cArqWiz := Upper(Substring(cNomeWizard,1,8))//IIF(At("_",cNomeWizard)>0,Upper(Substring(cNomeWizard,1,At("_",cNomeWizard))),Upper(Alltrim(cNomeWizard)))

	cNomeWizard	:=	cNomeWizard+"_"+cUserName

	If File ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" )

		If FT_FUse ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" ) <> -1

			FT_FGoTop ()
			While ( !FT_FEof () )

				cLinha	:=	FT_FReadLn ()
				If ( "PAINEL" $ cLinha )
					aAdd ( aIniWiz , {} )
				Else
					aAdd ( aIniWiz[Len ( aIniWiz )] , cLinha )
				EndIf

				FT_FSkip ()

			Enddo

			FT_FUse ()

			For nJ := 1 To Len ( aIniWiz )

				For nI := 1 To Len ( aIniWiz[nJ] )

					If (SubStr (aIniWiz[nJ][nI], 8, 1)==";")

						cTipo	:=	SubStr ( aIniWiz[nJ][nI] , 9 , 1 )
						nPadR	:=	Val ( SubStr (aIniWiz[nJ][nI] , 11 , 3 ) )
						cLinha	:=	SubStr ( aIniWiz[nJ][nI] , 15 , nPadR )

						Do case
							Case cTipo == "L"
								aIniWiz[nJ][nI]	:= 	Iif ( cLinha == "F" , .F. , .T. )

							Case cTipo == "D"
								aIniWiz[nJ][nI]	:= 	SToD ( cLinha )

							Case cTipo == "N"
								aIniWiz[nJ][nI]	:= 	Val ( cLinha )

							OtherWise
								aIniWiz[nJ][nI]	:=	cLinha
						EndCase

					Else
						aIniWiz[nJ][nI]	:=	SubStr ( aIniWiz[nJ][nI] , 9 )
					EndIf

				Next nI

			Next nJ

			lRet		:=	.T.

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunFilSXB

Função utilizada nas consultas SXB para
personalizar os filtros das informações.

@Param	lVldDtVig	- Informa se deve filtrar informação Data de Vigência
		lVldDtFin	- Informa se deve filtrar informação Data Final
		cTipoModel	- Informa qual o modelo para registros genericos do ECF
		cF3Wizard	-	Parâmetro usado apenas quando necessário um filtro de F3
						vindo da Wizard de Geração de Obrigação Fiscal

@Return	cRet	-	Retorna a string do filtro SXB

@Author	Gustavo G. Rueda
@Since		08/05/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function XFUNFilSXB( cFilDtVig, cFilDtFin, cTipoModel, cF3Wizard )

	Local cCmp         := ReadVar()
	Local c3PosCmp     := SubStr( cCmp, 4, 3 )
	Local cPrefixo     := Alias() + "->" + Alias()
	Local cRet         := "@#.T.@#"
	Local cCmpModel    := SubStr( cCmp, 4, 3 ) + "_UF"
	Local cContCmpMdl  := ""
	Local cUF          := ""
	Local cReg         := ""
	Local cCodNat      := ""
	Local cPropST      := ""
	Local cNmConsult   := ""
	Local cEvtTrab     := ""
	Local cCpfTrab     := ""
	Local cIdC91       := ""
	Local cSelect      := ""
	Local cMesPerAp    := ""
	Local cAnoPerAp    := ""
	Local cAlsCmp      := ""
	Local cCampo       := ""

	Default cFilDtVig  := ""
	Default cFilDtFin  := ""
	Default cTipoModel := ""

	//Quando a consulta padrão é feita pelo TGET, esta condição permite filtrar os modelos fiscais de acordo com a rotina TAF062.
	If Empty( cCmp ) .and. ( FunName() $ "TAFA062E" .or. FunName() $ "TAFA062S" )
		cNmConsult := "CININOT"
	EndIf

	If "CFILPERG" $ AllTrim( cCmp ) //Utilizado no filtro padrão do Browse
		cRet := "@#.T.@#"
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'C50_CODAJU/C2T_CODAJU/C3K_CODAJU'
		cRet := '@#(C1A->C1A_VALIDA>=dDataBase .OR. Empty(C1A->C1A_VALIDA)) .AND. ' + "( Empty( C1A->C1A_UF ) .Or. C1A->C1A_UF=='" + XFUNUFID() + "')@#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'C2D_CODAJ'
		cRet := '@#C0J->((C0J_VALIDA>=dDataBase.OR.Empty(C0J_VALIDA)).AND.C0J_UF=="' + XFUNUFID() + '")@#'
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'C51_TPUTIL'
		cUF 	:= GetNewPar( "MV_TAFUF" , SM0->M0_ESTCOB )
		cRet := '@#C4Z->((C4Z_VALIDA>=dDataBase.OR.Empty(C4Z_VALIDA)).AND. SubStr(C4Z_CODIGO,1,2)=="' + cUF +'")@#'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para Filtro de SXB de tabelas autocontidas do eSocial³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf !Empty(cFilDtVig)

		If AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDREND"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '11|12|13|14|15|18|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDRETI"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '31|32|33|34|35|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDDEDI"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '41|42|43|44|46|47|51|52|53|54|55|56|57|58|61|62|63|64|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDISEN"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '70|71|72|73|74|75|76|77|78|79|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDDEMJ"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '81|82|83|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "LE4_IDNRET"
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase) .and. C8U_CODIGO $ '91|92|93|94|95|'@#"
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C8R_CINTPS" .And. TafLayESoc("S_01_00_00")
			cRet := "@#Empty(" + cPrefixo + "_VALIDA)@#"
		Else
			cRet := "@#(Empty(" + cPrefixo + "_VALIDA) .or. " + cPrefixo + "_VALIDA >= dDataBase)@#"
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro para Atestado de Saude Ocupacional³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'C9V_CODASO|CUP_CODASO|'
		cRet := "@#C8B_FUNC=='" + FWFLDGET('C9V_ID') + "'@#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro para Atestado de Saude Ocupacional³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'CMD_CODASO'
		cRet := "@#C8B_FUNC=='" + FWFLDGET('CMD_FUNC') + "'@#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro para Beneficiarios do Funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'C9T_BENEF'
		cRet := "@#C9Z_ID=='" + FWFLDGET('C91_TRABAL') + "'@#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³E-social - Dados Rúbricas  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C8R_PROCCP|C8R_PROCIR|C8R_PROCFG|C8R_PROCCS"
	//	cRet := "@#(&(xFunDtPer(" + cPrefixo + "_DTFIN, .T.)) >= dDataBase .or. Empty(" + cPrefixo + "_DTFIN)) .and. " + cPrefixo + "_ATIVO == '1'@#"
		cRet := "@#( xFunDtPer(" + cPrefixo + "_DTFIN, .T.) >= dDataBase .or. Empty(" + cPrefixo + "_DTFIN)) .and. " + cPrefixo + "_ATIVO == '1'@#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para Filtro de SXB de tabelas de eventos³
	//³do eSocial que possuam os campos de C9K_ESTABE     ³
	//³C9P_ESTABE                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	ElseIf TafLayESoc("S_01_00_00") .And. AllTrim( SubStr( cCmp , 4 ) ) $ 'C9K_ESTABE|C9P_ESTABE'
		cRet := "@#( xFunDtPer(" + cPrefixo + "_DTFIN, .T.) >= dDataBase .or. Empty(" + cPrefixo + "_DTFIN)) .and. " + cPrefixo + "_ATIVO == '1'  .and. " + cPrefixo + "_TPINSC $ '1|3|4' .and. " + cPrefixo + "_STATUS == '4' @#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para Filtro de SXB de tabelas de eventos³
	//³do eSocial que possuam os campos de historico      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf !Empty(cFilDtFin)
	//	cRet := "@#(&(xFunDtPer(" + cPrefixo + "_DTFIN, .T.)) >= dDataBase .or. Empty(" + cPrefixo + "_DTFIN)) .and. " + cPrefixo + "_ATIVO == '1'@#"
		cRet := "@#( xFunDtPer(" + cPrefixo + "_DTFIN, .T.) >= dDataBase .or. Empty(" + cPrefixo + "_DTFIN)) .and. " + cPrefixo + "_ATIVO == '1' @#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para Plano de Contas Referencial (ECF)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'CAE_CTAREF'
		cRet := "@#CH5_ID=='" + FWFLDGET('CAD_CTA') + "' .AND. CH5_TABECF=='"+FWFLDGET('CAE_TABECF')+"' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'CAG_CTAREF'
		cRet := "@#CH5_ID=='" + FWFLDGET('CAF_CTA') + "' .AND. CH5_TABECF=='"+FWFLDGET('CAG_TABECF')+"' @#"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para Periodo de Apuração (ECF)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ 'CEG_PERAPU|CAC_PERAPU|CEN_PERAPU|CAP_PERAPU|CEJ_PERAPU|CEY_PERAPU|CEA_PERAPU'

		If AllTrim( SubStr( cCmp , 4 ) ) $ 'CEG_PERAPU|CEJ_PERAPU'
			cRet := "@#CAH_CODIGO >= '"+('T01')+"'"+".And."+"CAH_CODIGO <= '"+('T04')+"'@#"
		Elseif AllTrim( SubStr( cCmp , 4 ) ) $ 'CEY_PERAPU'
			cRet := "@#CAH_CODIGO >= '"+('T01')+"'"+".And."+"CAH_CODIGO <= '"+('T04')+"'"+".Or."+"CAH_CODIGO == '"+('A00')+"'@#"
		Else
			cRet := "@#CAH_CODIGO <> ' '@#"
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registros Genericos Bloco X|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CFT_REGECF"

		If "X291" $ Upper( FunDesc() )
			cReg := "X291"
		ElseIf "X292" $ Upper( FunDesc() )
			cReg := "X292"
		ElseIf "X360" $ Upper( FunDesc() )
			cReg := "X360"
		ElseIf "X390" $ Upper( FunDesc() )
			cReg := "X390"
		ElseIf "X400" $ Upper( FunDesc() )
			cReg := "X400"
		ElseIf "X460" $ Upper( FunDesc() )
			cReg := "X460"
		ElseIf "X470" $ Upper( FunDesc() )
			cReg := "X470"
		ElseIf "X480" $ Upper( FunDesc() )
			cReg := "X480"
		ElseIf "X490" $ Upper( FunDesc() )
			cReg := "X490"
		ElseIf "X500" $ Upper( FunDesc() )
			cReg := "X500"
		ElseIf "X510" $ Upper( FunDesc() )
			cReg := "X510"
		EndIf

		cRet := "@#CFU_CODIGO = '" + cReg + "'@#"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Codigo de Lancamento ECF|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CFT_CODLAN|CEB_CODLAN|CEK_CODCTA|CAS_CODCTA|CAU_CODCTA|CGX_CODCTA|CEI_CODIGO|CFI_CODIGO|V1S_CODLAN"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registros  Bloco X|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim( SubStr( cCmp , 4 ) ) $ "CFT_CODLAN"

			If "X291" $ Upper( FunDesc() )
				cReg := "X291"
			ElseIf "X292" $ Upper( FunDesc() )
				cReg := "X292"
			ElseIf "X360" $ Upper( FunDesc() )
				cReg := "X360"
			ElseIf "X390" $ Upper( FunDesc() )
				cReg := "X390"
			ElseIf "X400" $ Upper( FunDesc() )
				cReg := "X400"
			ElseIf "X460" $ Upper( FunDesc() )
				cReg := "X460"
			ElseIf "X470" $ Upper( FunDesc() )
				cReg := "X470"
			ElseIf "X480" $ Upper( FunDesc() )
				cReg := "X480"
			ElseIf "X490" $ Upper( FunDesc() )
				cReg := "X490"
			ElseIf "X500" $ Upper( FunDesc() )
				cReg := "X500"
			ElseIf "X510" $ Upper( FunDesc() )
				cReg := "X510"
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registros Genericos Bloco N|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEB_CODLAN"

			If cTipoModel == "01"
				cReg := "N500"
			ElseIf cTipoModel == "02"
				cReg := "N600"
			ElseIf cTipoModel == "03"
				cReg := "N610"
			ElseIf cTipoModel == "04"
				cReg := "N620"
			ElseIf cTipoModel == "05"
				cReg := "N630"
			ElseIf cTipoModel == "06"
				cReg := "N650"
			ElseIf cTipoModel == "07"
				cReg := "N660"
			ElseIf cTipoModel == "08"
				cReg := "N670"
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registros Genericos Bloco T|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEK_CODCTA"

			If cTipoModel == "01"
				cReg := "T120"
			ElseIf cTipoModel == "02"
				cReg := "T150"
			ElseIf cTipoModel == "03"
				cReg := "T170"
			ElseIf cTipoModel == "04"
				cReg := "T181"
			EndIf

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAS_CODCTA" //L210

			cReg := "L210"

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAU_CODCTA" //L400

			cReg := "L400"

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CGX_CODCTA" //Y681

			cReg := "Y681"

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEI_CODIGO"

			If cTipoModel == "01"
				cReg := "P130"
			ElseIf cTipoModel == "02"
				cReg := "P200"
			ElseIf cTipoModel == "03"
				cReg := "P230"
			ElseIf cTipoModel == "04"
				cReg := "P300"
			ElseIf cTipoModel == "05"
				cReg := "P400"
			ElseIf cTipoModel == "06"
				cReg := "P500"
			EndIf

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CFI_CODIGO"

			If cTipoModel == "01"
				cReg := "U180"
			ElseIf cTipoModel == "02"
				cReg := "U182"
			EndIf

		ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "V1S_CODLAN" //V100

			cReg := "V100"

		EndIf

		If AllTrim( SubStr( cCmp, 4 ) ) $ "CEB_CODLAN" .and. cTipoModel == "05"
			cRet := "@#CH6_CODREG = 'N630A' .or. CH6_CODREG = 'N630B'@#"
		Else
			cRet := "@#CH6_CODREG = '" + cReg + "'@#"
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Código de Conta Referencial|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CH5_CTAREF|CEH_CODCTA|CEZ_CODCTA|CAQ_CODCTA|CAT_CODCTA|CHA_CTASUP|CHE_CODCTA"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro J051|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim( SubStr( cCmp , 4 ) ) $ "CH5_CTAREF"

			If FwFldGet( "CH5_TABECF" ) == "01"
				cReg := "L100A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "02"
				cReg := "L100B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "03"
				cReg := "L100C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "04"
				cReg := "L300A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "05"
				cReg := "L300B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "06"
				cReg := "L300C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "07"
				cReg := "P100"
			ElseIf FwFldGet( "CH5_TABECF" ) == "08"
				cReg := "P150"
			ElseIf FwFldGet( "CH5_TABECF" ) == "09"
				cReg := "U100A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "10"
				cReg := "U100B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "11"
				cReg := "U100C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "12"
				cReg := "U100D"
			ElseIf FwFldGet( "CH5_TABECF" ) == "13"
				cReg := "U100E"
			EndIf

			cCodNat := FwFldGet( "C1O_CODNAT" )

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAQ_CODCTA" //L100

			If FwFldGet( "CAQ_REGECF" ) == "1"
				cReg := "L100A"
			ElseIf FwFldGet( "CAQ_REGECF" ) == "2"
				cReg := "L100B"
			ElseIf FwFldGet( "CAQ_REGECF" ) == "3"
				cReg := "L100C"
			EndIf

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAT_CODCTA" //L300

			If FwFldGet( "CAT_REGECF" ) == "1"
				cReg := "L300A"
			ElseIf FwFldGet( "CAT_REGECF" ) == "2"
				cReg := "L300B"
			ElseIf FwFldGet( "CAT_REGECF" ) == "3"
				cReg := "L300C"
			EndIf

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEH_CODCTA"

			cReg := "P100"

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEZ_CODCTA"

			If FwFldGet( "CEZ_TABECF" ) == "1"
				cReg := "U100A"
			ElseIf FwFldGet( "CEZ_TABECF" ) == "2"
				cReg := "U100B"
			ElseIf FwFldGet( "CEZ_TABECF" ) == "3"
				cReg := "U100C"
			ElseIf FwFldGet( "CEZ_TABECF" ) == "4"
				cReg := "U100D"
			ElseIf FwFldGet( "CEZ_TABECF" ) == "5"
				cReg := "U100E"
			EndIf

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CHA_CTASUP"

			cReg := FwFldGet( "CHA_CODREG" )

		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CHE_CODCTA"

			cReg := "P150"

		EndIf

		cRet := "@#CHA_CODREG = '" + cReg + "'@#"

	//Registros do Bloco M
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CEO_CODLAN|CHR_CODLAN|CFR_CODLAN|LE9_CODLAN"

		If FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "1"
			cReg := "M300A"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "2"
			cReg := "M300B"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "3"
			cReg := "M300C"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "4"
			cReg := "M350A"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "5"
			cReg := "M350B"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "6"
			cReg := "M350C"
		EndIf

		cRet := "@#CH8_CODREG = '" + cReg + "'@#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CHG_CODIGO"

		cReg:= FwFldGet("CHG_TABECF")

		If cReg == '1'
			cReg:= "U150A"
		Elseif cReg == '2'
			cReg:= "U150B"
		Elseif cReg == '3'
			cReg:= "U150C"
		Elseif cReg == '4'
			cReg:= "U150D"
		Elseif cReg == '5'
			cReg:= "U150E"
		Endif

		cRet := "@#CHA_CODREG = '" + cReg + "'@#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CGM_QUALIF|CGO_QUALIF"

		If "CGM" $ cCmp
			cRet := "@#CGN_CODIGO >= '"+('01')+"'"+" .And. "+"CGN_CODIGO <= '"+('09')+"'@#"
		ElseIf  "CGO" $ cCmp
			cRet := "@#CGN_CODIGO >= '"+('10')+"'"+" .And. "+"CGN_CODIGO <= '"+('17')+"'@#"
		EndIf

	//ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C2T_SUBITE"
	//	cRet := "@#CHY_OPERAC == '0' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C2D_SUBITE"
		cPropST := SubStr( Posicione("C0J",3,xFilial("C0J") + FWFLDGET("C2D_CODAJ"),"C0J_CODIGO"), 4,1 )
		cRet := "@#CHY_OPERAC == '" + cPropST + "' .And. CHY_IDUF == '"+XFUNUFID()+"' @#"


	//ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C3K_SUBITE"
	//	cRet := "@#CHY_OPERAC == '1' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "C2T_SUBITE|C3K_SUBITE"

		If "C2T" $ cCmp
			cRet := "@#CHY_OPERAC == '0' .And. CHY_IDUF == '"+XFUNUFID()+"'@#"
		ElseIf  "C3K" $ cCmp
			cRet := "@#CHY_OPERAC == '1' .And. CHY_IDUF == '"+XFUNUFID()+"'@#"
		EndIf

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "C2T_CODMOT|C2D_CODMOT|C3K_CODMOT"

		If "C2T" $ cCmp
			cRet := "@#T0V_IDSBIT == '"+FWFLDGET("C2T_IDSUBI")+"' .AND. (Empty(T0V_VALIDA)) @#"
		ElseIf "C2D" $ cCmp
			cRet := "@#T0V_IDSBIT == '"+FWFLDGET("C2D_IDSUBI")+"' .AND. (Empty(T0V_VALIDA)) @#"
		ElseIf "C3K" $ cCmp
			cRet := "@#T0V_IDSBIT == '"+FWFLDGET("C3K_IDSUBI")+"' .AND. (Empty(T0V_VALIDA))  @#"
		EndIf

	//Cadastro de Configuração de Tributo
	ElseIf FunName() == "TAFA430" .and. Empty( cCmp )

		cRet := "@#.T.@#"

	//Cadastro de Evento Tributário
	ElseIf FunName() == "TAFA433"

		//Campos tratados pelo cadastro
		If AllTrim( SubStr( cCmp, 4 ) ) $ "T0N_CODEVE|T0N_COTRIB|T0O_CODECF|T0O_CODTDE|T0O_CODEVE|T0O_CODLAL|LEC_CODECF|LEC_CODLAL|LEC_CODTDE|LEC_CODGRU|T0O_FILITE"
			cRet := FilSXBEven( cCmp )
			//Os demais campos que não têm o tratamento específico apresentarão todos os resultados
		Else
			cRet := "@#.T.@#"
		EndIf

	//Cadastro de Apuração de Impostos
	ElseIf FunName() == "TAFA444"

		//Campos tratados pelo cadastro
		If AllTrim( SubStr( cCmp, 4 ) ) $ "CWX_CODLAL|CWX_CODECF"
			//Deverá utilizar os mesmos filtros do Evento Tributário para definir os códigos que serão visíveis ao usuário
			cRet := FilSXBEven( cCmp )
			//Os demais campos que não têm o tratamento específico apresentarão todos os resultados
		Else
			cRet := "@#.T.@#"
		EndIf

	//Filtro para os modelos de documentos fiscais para a rotina TAFA062
	ElseIf cNmConsult $ "CININOT"
		cRet := "@# (Empty(C01_VALIDA)) @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "C4X_UF"

		cRet := "@#C09_UF == '" + SM0->M0_ESTENT + "'@#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LE9_CODTBT|T0N_TGET_T0J"

		DBSelectArea( "C3S" )
		C3S->( DBSetOrder( 1 ) )
		If C3S->( MsSeek( xFilial( "C3S" ) + "18" ) )
			cReg := "|" + C3S->C3S_ID
		EndIf

		If C3S->( MsSeek( xFilial( "C3S" ) + "19" ) )
			cReg += "|" + C3S->C3S_ID
		EndIf

		cRet := "@#T0J_TPTRIB $ '" + cReg + "' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LE9_TGET_T0J_A"

		DBSelectArea( "LE9" )
		LE9->( DBSetOrder( 1 ) )
		If LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID ) )
			While LE9->( !Eof() ) .and. LE9->( LE9_FILIAL + LE9_ID ) == xFilial( "LE9" ) + T0S->T0S_ID
				cReg += LE9->LE9_IDCODT
				LE9->( DBSkip() )
			EndDo
		EndIf

		cRet := "@#T0J_ID $ '" + cReg + "' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LE9_TGET_T0J_B"

		DBSelectArea( "C3S" )
		C3S->( DBSetOrder( 1 ) )
		If C3S->( MsSeek( xFilial( "C3S" ) + "19" ) )
			DBSelectArea( "LE9" )
			LE9->( DBSetOrder( 1 ) )
			If LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID ) )
				DBSelectArea( "T0J" )
				T0J->( DBSetOrder( 1 ) )
				While LE9->( !Eof() ) .and. LE9->( LE9_FILIAL + LE9_ID ) == xFilial( "LE9" ) + T0S->T0S_ID
					If T0J->( MsSeek( xFilial( "T0J" ) + LE9->LE9_IDCODT ) )
						If T0J->T0J_TPTRIB == C3S->C3S_ID
							cReg += LE9->LE9_IDCODT
						EndIf
					EndIf
					LE9->( DBSkip() )
				EndDo
			EndIf
		EndIf

		cRet := "@#T0J_ID $ '" + cReg + "' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEL_CODEVE"

		//Filtro para não exibir os códigos "000004 e "000005" referente a Atividade Rural e Lucro da Exploração
		DBSelectArea( "T0K" )
		T0K->( DBSetOrder( 2 ) )

		If T0K->( MsSeek( xFilial( "T0K" ) + "000004" ) )
			cReg += "|" + T0K->T0K_ID
		EndIf

		If T0K->( MsSeek( xFilial( "T0K" ) + "000005" ) )
			cReg += "|" + T0K->T0K_ID
		EndIf

		cRet := "@#!( T0N_IDFTRI $ '" + cReg + "' )@#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "C35_MOTINC"

		If(FWFLDGET("C35_VLISEN") > 0)
			cRet := "@#CWZ_TPINC == '1' .AND. CWZ_IDUF = '"+ XFUNUFID() +"' .AND. (Empty(CWZ_VALIDA)) @#"
		ElseIf(FWFLDGET("C35_VLNT") > 0)
			cRet := "@#CWZ_TPINC == '2' .AND. CWZ_IDUF = '"+ XFUNUFID() +"' .AND. (Empty(CWZ_VALIDA)) @#"
		ElseIf(FWFLDGET("C35_VLOUTR") > 0)
			cRet := "@#CWZ_TPINC == '3' .AND. CWZ_IDUF = '"+ XFUNUFID() +"' .AND. (Empty(CWZ_VALIDA)) @#"
		Else
			cRet := "@#CWZ_TPINC == '' .AND. CWZ_IDUF = '"+ XFUNUFID() +"' .AND. (Empty(CWZ_VALIDA)) @#"
		EndIf

	ElseIF AllTrim(cTipoModel) == "GST" //gia-st
		c1EID   := POSICIONE('C1E',3,xFILIAL("C1E") + cFilAnt,"C1E_ID")

		cIdObri := ""

		DbSelectArea("CZR")
		DbSetOrder(1)
		If DbSeek(xFilial("CZR")+c1EID)
			nRegCZR := CZR->( LASTREC())
			While CZR->(!EOF()) .AND. c1EID == CZR->CZR_ID
				if nRegCZR == 1
					cIdObri += CZR->CZR_IDOBRI
				Else
					cIdObri += CZR->CZR_IDOBRI + "|"
				EndIf
				nRegCZR := nRegCZR - 1
				CZR->( DBSkip() )
			EndDo
			cRet := "@#CHW_ID $  '" + cIDObri + "'@#"
		EndIf

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T03_FPAS"

		cCodFpas := Posicione( "C8A", 1, xFilial( "C8A" ) + FwFldGet( "C99_FPAS" ), "C8A_CDFPAS" )
		cRet := "@#C8A_CDFPAS == '" + cCodFpas + "' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C9L_TRABAL|C9Q_TRABAL"

		cEvtTrab   := POSICIONE("C9V",1, xFilial("C9V")+FWFLDGET("C91_TRABAL"),"C9V_NOMEVE")

		// VERIFICA QUAL TIPO DE FILTRO REALIZAR
		If cEvtTrab $ "S2200"
			cCpfTrab := POSICIONE("C9V",1, xFilial("C9V")+FWFLDGET("C91_TRABAL"),"C9V_CPF")
			cRet := "@#C9V_CPF == '" + cCpfTrab  + "' @#"
		ElseIf cEvtTrab == "S2300"
			cRet := "@#C9V_ID == '" + FWFLDGET("C91_TRABAL")  + "' @#"
		EndIf

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T3R_IDPGTO"

		If FWFLDGET("T3Q_TPPGTO") $ "1|5"
			If !Empty(FWFLDGET("T3R_PERREF"))
				If Len(FWFLDGET("T3R_PERREF")) == 6

					cSelect := "SELECT C91_ID IdC91 FROM " + RetSqlName("C91")
					cSelect += " WHERE  C91_FILIAL = '" + xFilial("C91")  + "' AND C91_TRABAL = '" + FWFLDGET("T3P_BENEFI") + "' AND C91_INDAPU = '1'"
					cSelect += " AND C91_PERAPU = '" + FWFLDGET("T3R_PERREF") + "' AND C91_ATIVO = '1' AND D_E_L_E_T_ <> '*'"

					DBUseArea( .T., "TOPCONN", TcGenQry( ,, cSelect ), "cIDC91" )

					cRet := "@#T14_ID == '" + ( cIDC91 )->IdC91 + "'@#"
					( cIDC91 )->( DBCloseArea() )

				Elseif Len(FWFLDGET("T3R_PERREF")) == 4

					cSelect := "SELECT C91_ID IdC91 FROM " + RetSqlName("C91")
					cSelect += " WHERE  C91_FILIAL = '" + xFilial("C91")  + "' AND C91_TRABAL = '" + FWFLDGET("T3P_BENEFI") + "' AND C91_INDAPU = '2'"
					cSelect += " AND C91_PERAPU = '" + FWFLDGET("T3R_PERREF") + "' AND C91_ATIVO = '1' AND D_E_L_E_T_ <> '*'"

					DBUseArea( .T., "TOPCONN", TcGenQry( ,, cSelect ), "cIDC91" )

					cRet := "@#T14_ID == '" + ( cIDC91 )->IdC91 + "' @#"

					( cIdC91 )->( DBCloseArea() )

				EndIf
			EndIf
		Endif

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T3S_IDPGTO"

		//2299
		If FWFLDGET("T3Q_TPPGTO") == "2"

			cMesPerAp :=  SubStr( FWFLDGET("T3P_PERAPU"), 5, 3 )
			cAnoPerAp :=  SubStr( FWFLDGET("T3P_PERAPU"), 1, 4 )

			cSelect := "SELECT CMD_ID CMDID FROM " + RetSqlName("CMD")
			cSelect += " WHERE  CMD_FILIAL = '" + xFilial("CMD") + "' AND CMD_FUNC = '" + FWFLDGET("T3P_BENEFI") + "' "
			cSelect += " AND ( MONTH(CMD_DTDESL) = '" + cMesPerAp + "' AND YEAR(CMD_DTDESL) = '" + cAnoPerAp + "') AND CMD_ATIVO = '1' AND D_E_L_E_T_ <> '*'"

			dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cSelect ) , "cIdCMD")

			cRet := "@#T06_ID == '" + cIdCMD->CMDID + "' @#"

			cIdCMD->(dbCloseArea())

			//2399
		Elseif FWFLDGET("T3Q_TPPGTO") == "3"

			cSelect := "SELECT C9V_CPF C9VCPF FROM " + RetSqlName("C9V")
			cSelect += " WHERE C9V_ID = '" + FWFLDGET("T3P_BENEFI") + "' AND C9V_NOMEVE = 'S2300' AND C9V_ATIVO = '1' AND D_E_L_E_T_ <> '*'"
			dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cSelect ) , "cCPFC9V")

			cSelect := "SELECT C9V_ID C9VID FROM "+ RetSqlName("C9V") + "," + RetSqlName("T92")
			cSelect += " WHERE C9V_ID = T92_TRABAL AND C9V_CPF = '" + cCPFC9V->C9VCPF + "'"
			cSelect += " AND C9V_ATIVO = '1' AND "+ RetSqlName("C9V") + ".D_E_L_E_T_ <> '*'"
			dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cSelect ) , "cIdC9V")

			cRet := "@#T3I_ID == '" + cIdC9V->C9VID + "' @#"

			cCPFC9V->(dbCloseArea())
			cIdC9V->(dbCloseArea())
		EndIf

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CRN_CODSUS|T1P_CODSUS|T3H_CODSUS|T1Z_CODSUS|T03_CODSUS|" //T5N_CODSUS

		cAlsCmp := SubStr( cCmp, 4, 3 )
		cCampo := cAlsCmp + "_IDPROC"
		cRet := "@#T5L_ID == '" + FWFldGet( cCampo ) + "'@#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T98_CODSUS|T99_CODSUS|T9Z_CODSUS|V0A_CODSUS|CW7_CODSUS|T9M_CODSUS|"

		cAlsCmp := SubStr( cCmp, 4, 3 )
		cCampo := cAlsCmp + "_IDPROC"

		DBSelectArea( "T9V" )
		T9V->( DBSetOrder( 5 ) ) //T9V_FILIAL + T9V_ID + T9V_ATIVO

		If T9V->( MsSeek( xFilial( "T9V" ) + FWFldGet( cCampo ) + "1" ) )
			cRet := "@#T9X_ID == T9V->T9V_ID .and. T9X_VERSAO == T9V->T9V_VERSAO @#"
		EndIf

	ElseIf AllTrim(SubStr(cCmp,4)) == "CMK_ITABRU"

		cAlsCmp	:= Substr(cCmp,4,3)
		cCampo		:= cAlsCmp + "_CODRUB"

		If lTAFCodRub
			dbSelectArea("C8R")
			C8R->(dbGoTo(TAFCodRub(FWFLDGET(cCampo), /*DTINI*/SubS(DTOS(dDatabase),1,6), /*DTFIN*/"", /*ATIVO*/"1")))
		Else
			dbSelectArea("C8R")
			dbSetOrder(5)
			MsSeek(xFilial("C8R")+FWFLDGET(cCampo)+ "1")
		EndIf

		cRet := "@#T3M_ID =='" + C8R->C8R_IDTBRU + "'@#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T3D_IDFATR"
		cRet := "@#T3E_TPFATR == '1' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T3O_IDFATR"
		cRet := "@#T3E_TPFATR == '2' @#"
	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T1X_CODTER"
		cCodFpas := Posicione("C8A",1,xFilial("C8A") + FWFLDGET("T1X_FPAS"),"C8A_CDFPAS")
		cRet := "@#C8A_CDFPAS == '" + cCodFpas  + "' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CMR_IDESTA"
		cRet := "@#C92_TPINSC == '3' @#"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T6L_OPEANP|C1N_CODANP"

		If AllTrim( SubStr( cCmp , 4 ) ) $ "T6L_OPEANP"
			cRet := "@#T5A_ORGOPE == '4' .AND. Empty(T5A_DATFIN) @#"  //4 - Outros
		ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "C1N_CODANP"
			cRet := "@#T5A_ORGOPE == '1' .AND. Empty(T5A_DATFIN) @#"  //1 - Doc. Fiscal
		Else
			cRet := "@#Empty(T5A_DATFIN) @#"
		EndIf

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "T89_CODCON"

		cRet := "@#T87_TRABAL = '" + FWFLDGET("C91_TRABAL") + "' @#"

	ElseIf cF3Wizard == "CHA"

		If cCombo == '1'
			cRet := "@#CHA_CODREG == 'L100A' .OR. CHA_CODREG == 'L300A'@#"
		ElseIf cCombo == '2'
			cRet := "@#CHA_CODREG == 'L100B' .OR. CHA_CODREG == 'L300B'@#"
		ElseIf cCombo == '3'
			cRet := "@#CHA_CODREG == 'L100C' .OR. CHA_CODREG == 'L300C'@#"
		ElseIf cCombo == '4'
			cRet := "@#CHA_CODREG == 'P100' .OR. CHA_CODREG == 'P150'@#"
		ElseIf cCombo == '5'
			cRet := "@#CHA_CODREG == 'U100A' .OR. CHA_CODREG == 'U150A'@#"
		ElseIf cCombo == '6'
			cRet := "@#CHA_CODREG == 'U100B' .OR. CHA_CODREG == 'U150B'@#"
		ElseIf cCombo == '7'
			cRet := "@#CHA_CODREG == 'U100C' .OR. CHA_CODREG == 'U150C'@#"
		ElseIf cCombo == '8'
			cRet := "@#CHA_CODREG == 'U100D' .OR. CHA_CODREG == 'U150D'@#"
		ElseIf cCombo == '9'
			cRet := "@#CHA_CODREG == 'U100E' .OR. CHA_CODREG == 'U150E'@#"
		EndIf

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T88_CODCON"

		cAlsCmp := Substr( cCmp, 4, 3 )

		If cAlsCmp = "T88"
			cCampo := "CMD_FUNC"
		EndIf

		cRet := "@#T87_TRABAL == '" + FWFldGet( cCampo ) + "'@#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CMJ_TPEVEN"

		cRet := "@#C8E_CODIGO $ '" + TAFAlw3000() + "' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "V7J_TPEVEN"

		cRet := "@#C8E_CODIGO $ 'S-2500|S-2501|S-2555' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T9D_TPEVEN"

		cRet := "@#T9B_CODIGO $ '" + TAFAlw9000() + "' @#"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "V2P_IDEVEN"

		cRet := "@#C8E_CODIGO $ '" + TAFAlw5003() + "' @#"

	elseif alltrim(substr(cCmp,4)) $ 'CFR_CODPB'

		cRet := "@#V3K_TRIBUT $ '" + iif( FwFldGet(alltrim(SubStr( cCmp, 4, 3 ) ) + "_TRIBUT" ) == '1', 'IA', 'CA') + "'@#"

	elseif alltrim(substr(cCmp,4)) $ 'V6R_TPAJUS|V6S_TPAJUS'

		cRet := "@#V6T_REGECF == '" + iif( substr(cCmp,4,3) == 'V6R','X305','X325' ) + "'@#"

	elseIf alltrim(substr(cCmp,4)) $ 'CFV_CODCOT'

		cRet := "@#V6U_REGECF = 'X320'@#"

	elseIf alltrim(substr(cCmp,4)) $ 'CAY_CODFCO'

		cRet := "@#V6U_REGECF = 'X300'@#"
		
	Else

		If c3PosCmp + "_CMUNOR|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_UFORIG"
		ElseIf c3PosCmp + "_CMUNDE|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_UFDEST"
		ElseIf c3PosCmp + "_MUNES|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_UFES"
		ElseIf c3PosCmp + "_MUNAES|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_UFAES"
		ElseIf c3PosCmp + "_CMUNTD|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_UFTRBD"
		ElseIf c3PosCmp + "_CODMUN|" $ cCmp + "|"
			cCmpModel := c3PosCmp + "_CODUF"

			//Se for C1G(Tabela de Processos) deve ser usado UFVARA
			If c3PosCmp $ "C1G|V9U"
				cCmpModel := c3PosCmp + "_UFVARA"
			Else
				//Devido a falta de padronização, algumas tabelas que possuem o campo CODMUN, não usam
				//o CODUF e sim UF. Então verifico se o campo existe, caso não exista usamos UF.
				DBSelectArea( c3PosCmp )
				If FieldPos( cCmpModel ) <= 0
					cCmpModel := c3PosCmp + "_UF"
				EndIf
			EndIf
		EndIf

		If !(SubStr(cCmpModel, 1, 1) == "_")
			cContCmpMdl := FWFldGet( cCmpModel )
		Endif

		If !Empty( cContCmpMdl )
			C09->( DBSetOrder( 3 ) )
			If C09->( DBSeek( xFilial( "C09" ) + cContCmpMdl ) )
				if !(AllTrim( SubStr( cCmp, 4 ) ) $ "C20_CODLOC|C20_CODDES")
					cRet := "@#C07->C07_UF=='" + C09->C09_ID + "'@#"
				endif
			EndIf
		EndIf
	EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldDiv
Funcao utilizada na validacao da data extemporanea do movimento

@return lRet - Retorna FLAG de validacao
			.T., conteudo OK
			.F., conteudo incorreto

@author David Costa
@since 07/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldDiv( )

	Local lRet   := .T.
	Local codSit := FWFLDGET( "C20_CODSIT" )
	Local cDtExt := DTos(FWFLDGET( "C20_DTEXT" ))

	If	(!Empty(codSit))

		DbSelectArea("C02")
		C02->( DbSetOrder( 3 ) )

		If(C02->(MsSeek(xFilial("C02") + codSit)))

			If(C02->C02_CODIGO $ "|01|07|" .And. Empty(cDtExt)) .Or. (!(C02->C02_CODIGO $ "|01|07|") .And. !Empty(cDtExt))
				lRet := .F.
			EndIf

		EndIf

		C02->(DbCloseArea())

	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVld
Funcao utilizada na validacao

@return lRet - Retorna FLAG de validacao
			.T., conteudo OK
			.F., conteudo incorreto

lUpper - Default converte em Maiúsculas a string de busca, caso utilize
case-sensitive envie .F. (False) no parâmetro
@author Mauro A. Goncalves
@since 07/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVld( nIndice, lUPPER )

	Local lRet      := .T.
	Local cCampo    := ReadVar()
	Local cCampo2   := Substr( cCampo , 4 )
	Local cChv      := ""
	Local cRet      := ""

	Default nIndice := 1
	Default lUPPER  := .T.

	If "C0G" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C0G_FAMILI" ) + '
		cChv	+=	'FWFLDGET( "C0G_GRUPO"  ) + '
		cChv	+=	'FWFLDGET( "C0G_SUBGRP" ) + '
		cChv	+=	'FWFLDGET( "C0G_SUBSUB" ) + '
		cChv	+=	'FWFLDGET( "C0G_CODIGO" ) + '
		cChv	+=	'DTOS(FWFLDGET("C0G_VALIDA"))'

	ElseIf "C1U" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C1U_CODTAB" ) + '
		cChv	+=	'FWFLDGET( "C1U_CODGRU" ) + '
		cChv	+=	'FWFLDGET( "C1U_CODIGO" ) + '
		cChv	+=	'DTOS(FWFLDGET("C1U_VALIDA"))'

	ElseIf "C3B" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C3B_INDOPE" ) + '
		cChv	+=	'FWFLDGET( "C3B_CODPAR" ) + '
		If TamSX3("C3B_CODITE")[1] == 36
			cChv += 'Posicione("C1L",1,xFilial("C1L") + FWFLDGET("C3B_ITEM"),"C1L_ID") + '
		Else
			cChv	+=	'FWFLDGET( "C3B_CODITE" ) + '
		EndIf

		cChv	+=	'DTOS(FWFLDGET("C3B_DTOPER"))'

	ElseIf "C40" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C40_IO"   ) + '
		cChv	+=	'FWFLDGET( "C40_UI"   ) + '
		cChv	+=	'FWFLDGET( "C40_IEMP" ) + '
		cChv	+=	'FWFLDGET( "C40_CPF"  ) + '
		cChv	+=	'FWFLDGET( "C40_CNPJ" ) + '
		cChv	+=	'DTOS(FWFLDGET("C40_DTO")) + '
		cChv	+=	'FWFLDGET( "C40_CSTP" ) + '
		cChv	+=	'FWFLDGET( "C40_CSTC" )'

	ElseIf "C49" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'DTOS(FWFLDGET( "C49_PERIOD")) + '
		cChv	+=	'FWFLDGET( "C49_TIPTRB" ) + '
		cChv	+=	'FWFLDGET( "C49_CODCRD" ) + '
		cChv	+=	'FWFLDGET( "C49_INDCOR" ) + '
		cChv	+=	'STR( FWFLDGET( "C49_ALIQPC" ),8, 4 ) + '
		cChv	+=	'STR( FWFLDGET( "C49_ALPCQT" ),8, 4 ) + '
		cChv	+=	'FWFLDGET( "C49_INDDCR" ) '

	ElseIf "C4L" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'DTOS(FWFLDGET( "C4L_PERIOD")) + '
		cChv	+=	'FWFLDGET( "C4L_NATBCR" ) + '
		cChv	+=	'FWFLDGET( "C4L_IDBMOB" ) + '
		cChv	+=	'FWFLDGET( "C4L_INDORI" ) + '
		cChv	+=	'FWFLDGET( "C4L_UTBIMO" ) + '
		cChv	+=	'FWFLDGET( "C4L_CSTPIS" ) + '
		cChv	+=	'FWFLDGET( "C4L_CSTCOF" )'

	ElseIf "C4E" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'DTOS(FWFLDGET( "C4E_DTMOV")) 	+ '
		cChv	+=	'FWFLDGET( "C4E_TPTRIB" ) 		+ '
		cChv	+=	'FWFLDGET( "C4E_CODCON" ) 		+ '
		cChv	+=	'FWFLDGET( "C4E_NATCRD" ) 		+  '
		cChv	+=	'DTOS(FWFLDGET( "C4E_DTRECE"))'

	ElseIf "C4F" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C4F_INDDOC" ) + '
		cChv	+=	'FWFLDGET( "C4F_NRODE"  ) + '
		cChv	+=	'DTOS(FWFLDGET("C4F_DTDE")) + '
		cChv	+=	'FWFLDGET( "C4F_NATEXP" )'

	ElseIf "C4G" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C4G_CODMOD" ) + '
		cChv	+=	'FWFLDGET( "C4G_SERIE"  ) + '
		cChv	+=	'FWFLDGET( "C4G_NUMDOC" ) + '
		cChv	+=	'DTOS(FWFLDGET("C4G_DTDOC")) + '

		If TamSX3("C4G_CODITE")[1] == 36
			cChv += 'Posicione("C1L",1,xFilial("C1L") + FWFLDGET("C4G_ITEM"),"C1L_ID") '
		Else
			cChv	+=	'FWFLDGET( "C4G_CODITE" )'
		EndIf

	ElseIf "C4H" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "C4H_CODPAR" ) + '
		cChv	+=	'FWFLDGET( "C4H_CODMOD" ) + '
		cChv	+=	'FWFLDGET( "C4H_SERIE"  ) + '
		cChv	+=	'FWFLDGET( "C4H_NUMDOC" ) + '
		cChv	+=	'DTOS(FWFLDGET("C4H_DTDOC"))'

	ElseIf "C4I" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'DTOS(FWFLDGET( "C4I_PERIOD")) + '
		cChv	+=	'FWFLDGET( "C4I_NATBCR" ) + '
		cChv	+=	'FWFLDGET( "C4I_IDBMOB" ) + '
		cChv	+=	'FWFLDGET( "C4I_INDORI" ) + '
		cChv	+=	'FWFLDGET( "C4I_UTBIMO" ) + '
		cChv	+=	'FWFLDGET( "C4I_CSTPIS" ) + '
		cChv	+=	'FWFLDGET( "C4I_CSTCOF" )'

	ElseIf  "C50" == SubStr( cCampo2 , 1 , 3 )

		Chv	    :=	'DTOS(FWFLDGET( "C50_PERIOD" )) + '
		cChv	+=	'FWFLDGET( "C50_CODAJU" )'

	ElseIf "C4X" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'DTOS(FWFLDGET( "C4X_PERIOD")) + '
		If TamSX3("C4X_CODITE")[1] == 36
			cChv += 'Posicione("C1L",1,xFilial("C1L") + FWFLDGET("C4X_ITEM"),"C1L_ID") + '
		Else
			cChv	+=	'FWFLDGET( "C4X_CODITE" ) + '
		EndIf

		cChv	+=	'FWFLDGET( "C4X_UF" ) + '
		cChv	+=	'FWFLDGET( "C4X_CODMUN" )'

	ElseIf "C58" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'DTOS(FWFLDGET( "C58_PERIOD")) + '
		cChv	+=	'FWFLDGET("C58_TPTRIB") + '
		cChv	+=	'FWFLDGET("C58_CSTPC")  + '
		cChv	+=	'FWFLDGET("C58_NATREC") '

	ElseIf "C5F" == SubStr( cCampo2 , 1 , 3 )

		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET("C5F_TPTRIB") + '
		cChv	+=	'DTOS(FWFLDGET("C5F_PERIOD")) + '
		cChv	+=	'FWFLDGET("C5F_PERAPR") + '
		cChv	+=	'FWFLDGET("C5F_ORCRE")  + '
		cChv	+=	'FWFLDGET("C5F_CNPJ") +'
		cChv	+=	'FWFLDGET("C5F_CDCRE") '

	ElseIf "C5I" == SubStr( cCampo2, 1, 3 )

		//Chave UNICA da tabela
		cChv := 'FWFLDGET("C5I_NATRET") + '
		cChv += 'DTOS(FWFLDGET("C5I_DTRETE")) + '
		cChv += 'FWFLDGET("C5I_CNPJ") +'
		cChv += 'FWFLDGET("C5I_INDDEC") +'
		cChv += 'FWFLDGET("C5I_CODREC") +'
		cChv += 'FWFLDGET("C5I_NATREC") '

	ElseIf "C5K" == SubStr( cCampo2 , 1 , 3 )

		cChv	+=	'FWFLDGET("C5K_CNPJ") + '
		cChv	+=	'FWFLDGET("C5K_CSTPC") +'
		cChv	+=	'FWFLDGET("C5K_CDPAR") +'
		cChv	+=	'DTOS(FWFLDGET("C5K_DTOPER"))'

	ElseIf "C5L" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C5L_PERACR") + '
		cChv	+=	'FWFLDGET("C5L_ORGCRD") + '
		cChv	+=	'FWFLDGET("C5L_CODCRE") '

	ElseIf "C6A" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C6A_PERIOD") + '
		cChv	+=	'FWFLDGET("C6A_CODDIS") + '
		cChv	+=	'FWFLDGET("C6A_CODMOD") + '
		cChv	+=	'FWFLDGET("C6A_SERDIS") + '
		cChv	+=	'FWFLDGET("C6A_SSERDI") + '
		cChv	+=	'FWFLDGET("C6A_NDIINI") + '
		cChv	+=	'FWFLDGET("C6A_NDIFIN") '

	ElseIf "C5G" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C5G_CDPAR") + '
		cChv	+=	'FWFLDGET("C5G_CODMOD") + '
		cChv	+=	'FWFLDGET("C5G_SER") + '
		cChv	+=	'FWFLDGET("C5G_SUBSER") + '
		cChv	+=	'FWFLDGET("C5G_NUMDOC") + '
		cChv	+=	'DTOS(FWFLDGET("C5G_DTOPER")) '

	ElseIf "C6P" == SubStr( cCampo2 , 1 , 3 )

		If TamSX3("C6P_CODITE")[1] == 36
			cChv += 'Posicione("C1L",1,xFilial("C1L") + FWFLDGET("C6P_ITEM"),"C1L_ID") + '
		Else
			cChv	:=	'FWFLDGET("C6P_CODITE") + '
		EndIf

		cChv	+=	'FWFLDGET("C6P_CSTPC")  '

	ElseIf "C0R" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C0R_PERIOD") + '
		cChv	+=	'FWFLDGET("C0R_UF") +  '
		cChv	+=	'FWFLDGET("C0R_CODDA") +  '
		cChv	+=	'FWFLDGET("C0R_NUMDA") '

	ElseIf "C4Q" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'DTOS(FWFLDGET("C4Q_PERIOD"))+FWFLDGET("C4Q_IDORDE")+FWFLDGET("C4Q_IDNTOP")+FWFLDGET("C4Q_CNPJ")'

	ElseIf "C5J" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'DTOS(FWFLDGET("C5J_PERMOV"))+FWFLDGET("C5J_TPTRB")+FWFLDGET("C5J_PERAPR")+FWFLDGET("C5J_CNATC")'

	ElseIf "C6E" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C6E_INDAJU")+FWFLDGET("C6E_CODAJU")+FWFLDGET("C6E_NUMDOC")'

	ElseIf "C4E" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C4E_TPTRIB")+FWFLDGET("C4E_CODCON")+FWFLDGET("C4E_NATCRD")+DTOS(FWFLDGET("C4E_DTRECE"))'

	ElseIf "C5Z" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C5Z_TPTRIB")+DTOS(FWFLDGET("C5Z_PERIOD"))+FWFLDGET("C5Z_INDNAT")+FWFLDGET("C5Z_PERRET")'

	ElseIf "C3J" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C3J_UF")+DTOS(FWFLDGET("C3J_DTINI"))+DTOS(FWFLDGET("C3J_DTFIN"))+FWFLDGET("C3J_INDMOV")'

	ElseIf "C20" == SubStr( cCampo2 , 1 , 3 )

		If TamSX3("C20_CODPAR")[1] == 36

			cChv	:=	'FWFLDGET("C20_CODMOD")+FWFLDGET("C20_INDOPE")+FWFLDGET("C20_TPDOC")+FWFLDGET("C20_INDEMI")+'
			cChv	+=	'Posicione("C1H",1,xFilial("C1H") + FWFLDGET("C20_CPARTI"),"C1H_ID")+FWFLDGET("C20_CODSIT")+FWFLDGET("C20_SERIE")+FWFLDGET("C20_SUBSER")+FWFLDGET("C20_NUMDOC")+'
			cChv	+=	'DTOS(FWFLDGET("C20_DTDOC"))+DTOS(FWFLDGET("C20_DTES"))'

		Else

			cChv	:=	'FWFLDGET("C20_CODMOD")+FWFLDGET("C20_INDOPE")+FWFLDGET("C20_TPDOC")+FWFLDGET("C20_INDEMI")+'
			cChv	+=	'FWFLDGET("C20_CODPAR")+FWFLDGET("C20_CODSIT")+FWFLDGET("C20_SERIE")+FWFLDGET("C20_SUBSER")+FWFLDGET("C20_NUMDOC")+'
			cChv	+=	'DTOS(FWFLDGET("C20_DTDOC"))+DTOS(FWFLDGET("C20_DTES"))'

		EndIf

	ElseIf "C95" == SubStr( cCampo2 , 1 , 3 )
	
		cChv	:=	'FWFLDGET("C95_IDFAM") + '
		cChv	+=	'FWFLDGET("C95_CODIGO") + '
		cChv	+=	'DTOS(FWFLDGET("C95_VALIDA"))'

	ElseIf "C96" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C96_IDFAM") + '
		cChv	+=	'FWFLDGET("C96_IDGRU") + '
		cChv	+=	'FWFLDGET("C96_CODIGO") + '
		cChv	+=	'DTOS(FWFLDGET("C96_VALIDA"))'

	ElseIf "C97" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C97_IDFAM") + '
		cChv	+=	'FWFLDGET("C97_IDGRU") + '
		cChv	+=	'FWFLDGET("C97_IDNIV") + '
		cChv	+=	'FWFLDGET("C97_CODIGO") + '
		cChv	+=	'DTOS(FWFLDGET("C97_VALIDA"))'

	ElseIf "C98" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("C98_IDFAM") + '
		cChv	+=	'FWFLDGET("C98_IDGRU") + '
		cChv	+=	'FWFLDGET("C98_IDNIV") + '
		cChv	+=	'FWFLDGET("C98_IDITEM") + '
		cChv	+=	'FWFLDGET("C98_CODIGO") + '
		cChv	+=	'DTOS(FWFLDGET("C98_VALIDA"))'

	ElseIf "CMD" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET("CMD_FUNC") + '
		cChv	+=	'DTOS(FWFLDGET("CMD_DTDESL")) + '
		cChv	+=	'FWFLDGET("CMD_ATIVO")'

	ElseIf "C92" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("C92_TPINSC") + '
		cChv += 'FWFLDGET("C92_NRINSC") + '
		cChv += '(FWFLDGET("C92_DTINI")) + '
		cChv += '(FWFLDGET("C92_DTFIN")) + '
		cChv += 'FWFLDGET("C92_ATIVO")  '

	ElseIf "C9Z" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("C9Z_IDFUNC") + '
		cChv += 'FWFLDGET("C9Z_IDREND") + '
		cChv += 'FWFLDGET("C9Z_TPINSC") + '
		cChv += 'FWFLDGET("C9Z_NRINSC")'

	ElseIf "C53" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("C53_PERIOD")) + '
		cChv += 'FWFLDGET("C53_INCIMO") +'
		cChv += 'DTOS(FWFLDGET("C53_DTREC")) +'
		cChv += 'FWFLDGET("C53_CODREC") +'
		cChv += 'STR(FWFLDGET("C53_ALQRET"),6,2)'

	ElseIf "CGM" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("CGM_PERIOD")) + '
		cChv += 'DTOS(FWFLDGET("CGM_INCSOC")) + '
		cChv += 'FWFLDGET("CGM_PAIS") + '
		cChv += 'FWFLDGET("CGM_QUASOC") + '
		cChv += 'FWFLDGET("CGM_CPFCNP") '

	ElseIf "CH6" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("CH6_CODREG") + '
		cChv += 'FWFLDGET("CH6_CODIGO") + '
		cChv += 'DTOS(FWFLDGET("CH6_DTINI")) + '
		cChv += 'DTOS(FWFLDGET("CH6_DTFIN")) '

	ElseIf "CH8" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("CH8_CODREG") + '
		cChv += 'FWFLDGET("CH8_CODIGO") + '
		cChv += 'DTOS(FWFLDGET("CH8_DTINI")) + '
		cChv += 'DTOS(FWFLDGET("CH8_DTFIN")) '

	ElseIf "CHA" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("CHA_CODREG") + '
		cChv += 'FWFLDGET("CHA_CODIGO") + '
		cChv += 'DTOS(FWFLDGET("CHA_DTINI")) + '
		cChv += 'DTOS(FWFLDGET("CHA_DTFIN")) '

	ElseIf "CFK" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("CFK_PERIOD")) + '
		cChv += 'FWFLDGET("CFK_IDBENF") + '
		cChv += 'FWFLDGET("CFK_IDINDP") +'
		cChv += 'FWFLDGET("CFK_ATOCON") +'
		cChv += 'DTOS(FWFLDGET("CFK_VIGINI")) + '
		cChv += 'DTOS(FWFLDGET("CFK_VIGFIM"))'


	ElseIf "CGP" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("CGP_PERIOD")) + '
		cChv += 'DTOS(FWFLDGET("CGP_DTEVEN")) + '
		cChv += 'FWFLDGET("CGP_INDREL") + '
		cChv += 'FWFLDGET("CGP_PAIS") + '
		cChv += 'FWFLDGET("CGP_CNPJ")'

	ElseIf "CEM" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("CEM_PERIOD")) + '
		cChv += 'FWFLDGET("CEM_PAIS") +'
		cChv += 'FWFLDGET("CEM_PESSOA") +'
		cChv += 'FWFLDGET("CEM_NOMEMP") +'
		cChv += 'FWFLDGET("CEM_IDQUAL")'

	ElseIf "C1G" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'FWFLDGET("C1G_TPPROC") + '
		cChv += 'FWFLDGET("C1G_NUMPRO") +'
		cChv += 'FWFLDGET("C1G_DTINI") +'
		cChv += 'FWFLDGET("C1G_DTFIN")'

	ElseIf "CFQ" == SubStr( cCampo2 , 1 , 3 )

		cChv := 'DTOS(FWFLDGET("CFQ_PERIOD"))+ '
		cChv += 'FWFLDGET("CFQ_TIPEXT") +'
		cChv += 'FWFLDGET("CFQ_PAIS") +'
		cChv += 'FWFLDGET("CFQ_FORMA") +'

		If TamSX3("CFQ_NATOPE")[1] == 36
			cChv += 'Posicione("C1N",1,xFilial("C1N") + FWFLDGET("CFQ_CODNAT"),"C1N_ID")'
		Else
			cChv += 'FWFLDGET("CFQ_NATOPE")'
		EndIf

	ElseIf "CM6" == SubStr( cCampo2 , 1 , 3 )

		cChv	:=	'FWFLDGET( "CM6_FUNC" )+'
		cChv	+=	'DTOS(FWFLDGET("CM6_DTAFAS"))'

	ElseIf "C9V" == SubStr( cCampo2 , 1 , 3 )

		If nIndice == 12
			cChv 	:= 'FWFLDGET("C9V_CPF") +'
			cChv	+= 'FWFLDGET("C9V_MATRIC")'
		Else
			cChv 	:= 'FWFLDGET("C9V_CPF") +'
			cChv	+= 'FWFLDGET("C9V_CATCI") +'
			cChv	+= 'DTOS(FWFLDGET("C9V_DTINIV"))'
		EndIf

	ElseIf "C7H" == SubStr( cCampo2 , 1 , 3 )

		cChv 	:= 'DTOS(FWFLDGET("C7H_DTMOVI")) +'
		If TamSX3("C7H_ITEM")[1] == 36
			cChv	+= 'POSICIONE("C1L",1,XFILIAL("C1L")+FWFLDGET("C7H_CODITE"),"C1L_ID")'
		Else
			cChv += 'FWFLDGET("C7H_ITEM")'
		EndIf

	ElseIf "LEZ" == SubStr( cCampo2 , 1 , 3 )

		If TamSX3("LEZ_CODPRO")[1] == 36
			cChv := 'POSICIONE("C1L",1,XFILIAL("C1L")+FWFLDGET("LEZ_PRODTO"),"C1L_ID") +'
		Else
			cChv := 'FWFLDGET("LEZ_CODPRO") +'
		EndIf

		cChv 	+= 'DToS(FwFldGet("LEZ_DTINI")) +'
		cChv 	+= 'DToS(FwFldGet("LEZ_DTFIN")) '

	EndIf

	//Converto a chamada do FWFLDGET para o campo de memoria "M->"
	cChv	:=	StrTran( cChv , 'FWFLDGET("' + cCampo2 + '")' , cCampo )

	//Executo a macro para retornar as informacoes dos campos do modelo e validar a chave unica
	cRet	:=	Iif(SubStr(cCampo2,1,3) <> 'C9V', &( cChv ), &( cChv ) + "1")

	lRet 	:=	XFUNVldUni( SubStr( cCampo2 , 1 , 3 ) , nIndice , cRet, lUpper )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNRedund
Funcao utilizada para validar redundancia entre a relacao.
Exemplo: Cadastro de Fator de Conversão, onde seleciona-se uma unidade de medida e
           cadastra-se as conversoes para a mesma. Porem nao pode existir a conversao
           para a mesma UM selecionada.

@param	cCmpModel - Campo a ser validado com o campo editado.

@return lRet -  .T. -> Valido
				.F. -> NAO Valido

@author Gustavo G. Rueda
@since 13/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNRedund(cCmpModel)

	Local	cCampo	:=	ReadVar()
	Local	lRet	:=	.F.

	If ( lRet := FWFldGet( cCmpModel ) == &( cCampo ) )
		Help( ,,"TAFREDUND",,, 1, 0 )
	EndIf

Return !lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNTrg
Funcao utilizada nos Gatilhos

@param	nOpc	  - Numero da opcao do tratamento especifico
		cCmpModel - Campo a ser validado com o campo editado.
		cString	  - Utilizacao para opcao 21

@return nValor- Retorna o Valor de retorno para o gatilho.

@author Rodrigo Aguilar
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNTrg( nOpc , cCmpModel , cString )

	Local cCmpM       := ReadVar()
	Local cCmp        := SubStr( cCmpM , 4 )
	Local nValor      := Nil
	Local cRetAux     := ""
	Local cRetAux2    := ""
	Local cValor      := Nil
	Local cReg        := ""

	Default cCmpModel := SubStr( cCmp , 1 , 3 ) + "_CODTRI"
	Default cString   := ''

	If nOpc != Nil

		If nOpc == 1
			nValor := M->C46_VCAPUR+ FWFLDGET("C46_VAJACR")-FWFLDGET("C46_VAJRED")- FWFLDGET("C46_VATDIF")+ FWFLDGET("C46_VANDIF")
		ElseIf nOpc == 2
			nValor := FWFLDGET("C46_VCAPUR")+ M->C46_VAJACR-FWFLDGET("C46_VAJRED")- FWFLDGET("C46_VATDIF")+ FWFLDGET("C46_VANDIF")
		ElseIf nOpc == 3
			nValor := FWFLDGET("C46_VCAPUR")+ FWFLDGET("C46_VAJACR")-M->C46_VAJRED- FWFLDGET("C46_VATDIF")+ FWFLDGET("C46_VANDIF")
		ElseIf nOpc == 4
			nValor := FWFLDGET("C46_VCAPUR")+ FWFLDGET("C46_VAJACR")-FWFLDGET("C46_VAJRED")- M->C46_VATDIF+ FWFLDGET("C46_VANDIF")
		ElseIf nOpc == 5
			nValor := FWFLDGET("C46_VCAPUR")+ FWFLDGET("C46_VAJACR")-FWFLDGET("C46_VAJRED")- FWFLDGET("C46_VATDIF")+M->C46_VANDIF
		ElseIf nOpc == 6
			nValor := (M->C46_VBCPC  * (FWFLDGET("C46_ALQPC")/100)) + (FWFLDGET("C46_QBCPPC") * FWFLDGET("C46_ALQVPC"))
		ElseIf nOpc == 7
			nValor := (FWFLDGET("C46_VBCPC")  * (M->C46_ALQPC/100)) + (FWFLDGET("C46_QBCPPC") * FWFLDGET("C46_ALQVPC"))
		ElseIf nOpc == 8
			nValor := (FWFLDGET("C46_VBCPC")  * (FWFLDGET("C46_ALQPC")/100)) + (M->C46_QBCPPC * FWFLDGET("C46_ALQVPC"))
		ElseIf nOpc == 9
			nValor := (FWFLDGET("C46_VBCPC")  * (FWFLDGET("C46_ALQPC")/100)) + (FWFLDGET("C46_QBCPPC") * M->C46_ALQVPC)
		ElseIf nOpc == 10
			nValor := M->C48_VLBCPC-FWFLDGET("C48_VLEXEC")-FWFLDGET("C48_VLEXSC")
		ElseIf nOpc == 11
			nValor := FWFLDGET("C48_VLBCPC")-M->C48_VLEXEC-FWFLDGET("C48_VLEXSC")
		ElseIf nOpc == 12
			nValor := FWFLDGET("C48_VLBCPC")-FWFLDGET("C48_VLEXEC")-M->C48_VLEXSC
		ElseIf nOpc == 13
			If SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="1" .Or. SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="9"
				nValor := M->C4L_BCCRED
			ElseIf SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="2"
				nValor := (M->C4L_BCCRED / 12)
			ElseIf SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="3"
				nValor := (M->C4L_BCCRED / 24)
			ElseIf SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="4"
				nValor := (M->C4L_BCCRED / 48)
			ElseIf SubStr(FWFLDGET("C4L_INDNPC"),1,1)=="5"
				nValor := (M->C4L_BCCRED / 6)
			EndIf
		ElseIf nOpc == 14
			If SubStr(M->C4L_INDNPC,1,1)=="1" .Or. SubStr(M->C4L_INDNPC,1,1)=="9"
				nValor := FWFLDGET("C4L_BCCRED")
			ElseIf SubStr(M->C4L_INDNPC,1,1)=="2"
				nValor := (FWFLDGET("C4L_BCCRED") / 12)
			ElseIf SubStr(M->C4L_INDNPC,1,1)=="3"
				nValor := (FWFLDGET("C4L_BCCRED") / 24)
			ElseIf SubStr(M->C4L_INDNPC,1,1)=="4"
				nValor := (FWFLDGET("C4L_BCCRED") / 48)
			ElseIf SubStr(M->C4L_INDNPC,1,1)=="5"
				nValor := (FWFLDGET("C4L_BCCRED") / 6)
			EndIf
		ElseIf nOpc == 15

			C2L->( DbSetOrder(3))
			If C2L->( MsSeek( xFilial("C2L") + FWFLDGET("C4S_INDBEM") ) )
				nValor := C2L->C2L_NRPARC
			Else
				nValor := 1
			EndIf

			nValor := (M->C4S_VLICPR + FWFLDGET("C4S_VLICFR") + FWFLDGET("C4S_VLICDA") + FWFLDGET("C4S_VLICST") ) / nValor

		ElseIf nOpc == 16

			C2L->( DbSetOrder(3))
			If C2L->( MsSeek( xFilial("C2L") + FWFLDGET("C4S_INDBEM") ) )
				nValor := C2L->C2L_NRPARC
			Else
				nValor := 1
			EndIf

			nValor := (FWFLDGET("C4S_VLICPR") + M->C4S_VLICFR + FWFLDGET("C4S_VLICDA") + FWFLDGET("C4S_VLICST") ) / nValor

		ElseIf nOpc == 17

			C2L->( DbSetOrder(3))
			If C2L->( MsSeek( xFilial("C2L") + FWFLDGET("C4S_INDBEM") ) )
				nValor := C2L->C2L_NRPARC
			Else
				nValor := 1
			EndIf

			nValor := (FWFLDGET("C4S_VLICPR") + FWFLDGET("C4S_VLICFR") + M->C4S_VLICDA + FWFLDGET("C4S_VLICST") ) / nValor

		ElseIf nOpc == 18

			C2L->( DbSetOrder(3))
			If C2L->( MsSeek( xFilial("C2L") + FWFLDGET("C4S_INDBEM") ) )
				nValor := C2L->C2L_NRPARC
			Else
				nValor := 1
			EndIf

			nValor := (FWFLDGET("C4S_VLICPR") + FWFLDGET("C4S_VLICFR") + FWFLDGET("C4S_VLICDA") + M->C4S_VLICST ) / nValor

		ElseIf nOpc == 19

			C2L->( DbSetOrder(3))
			If C2L->( MsSeek( xFilial("C2L") + FWFLDGET("C4S_INDBEM") ) )
				nValor := C2L->C2L_NRPARC
			Else
				nValor := 1
			EndIf

			nValor := (FWFLDGET("C4S_VLICPR") + FWFLDGET("C4S_VLICFR") + FWFLDGET("C4S_VLICDA") + FWFLDGET("C4S_VLICST") ) / nValor

		ElseIf nOpc == 20
			If FWFLDGET("C20_CODMOD") $ '000004/000020'	//'06/28'
				cValor	:=	Posicione( "C0L" , 3 , xFilial( "C0L" ) + M->C2E_CODCON , "C0L_DESCRI")
			Else
				cValor	:=	Posicione( "C0O" , 3 , xFilial( "C0O" ) + M->C2E_CODCON , "C0O_DESCRI")
			EndIf
		ElseIf nOpc == 21

			//Tratamento para utilizar o cString quando for passado, pois neste caso o campo de TRIBUTO nao existe e devo utilizar esta variavel para vincular o mesmo
			cString	:=	Iif( Empty( cString ) , FWFLDGET( cCmpModel ) , cString )

			//ISSQN
			If cString $ '000001/000016'
				cValor	:=	Posicione( "C0H" , 3 , xFilial( "C0H" ) + &cCmp , "C0H_CODIGO + ' - ' + C0H_DESCRI")
				//ICMS e ICMS/ST
			ElseIf cString $ '000002/000003/000004/000017/000026'
				cValor	:=	Posicione( "C14" , 3 , xFilial( "C14" ) + &cCmp , "C14_CODIGO + ' - ' + C14_DESCRI")
				//IPI
			ElseIf cString $ '000005'
				cValor	:=	Posicione( "C15" , 3 , xFilial( "C15" ) + &cCmp , "C15_CODIGO + ' - ' + C15_DESCRI")
				//PIS/Pasep/Cofins
			ElseIf cString $ '000006/000007/000008/000009/000010/000011/000014/000015'
				cValor	:=	Posicione( "C17" , 3 , xFilial( "C17" ) + &cCmp , "C17_CODIGO + ' - ' + C17_DESCRI")
			EndIf
			//Tratamento para consulta da Modalidade de determinacao da base de calculo do ICMS e/ou ICMS/ST conforme tributo do documento fiscal selecionado
		ElseIf nOpc == 22
			//ICMS
			If FWFLDGET(cCmpModel) $ '000002/000003/000017'
				cValor	:=	Posicione( "C04" , 3 , xFilial( "C04" ) + &cCmp , "C04_CODIGO + ' - ' + C04_DESCRI")
				//ICMS/ST
			ElseIf FWFLDGET(cCmpModel) $ '000004/000026'
				cValor	:=	Posicione( "C05" , 3 , xFilial( "C05" ) + &cCmp , "C05_CODIGO + ' - ' + C05_DESCRI")
			EndIf
		ElseIf nOpc == 23
			cRetAux	:=	Posicione("C1H",5,xFilial("C1H")+M->C20_CODPAR,"C1H_CODPAI")
			cValor	:=	AllTrim( Posicione("C08",3,xFilial("C08")+cRetAux,"C08_DESCRI") )

			cRetAux	:=	Posicione("C1H",5,xFilial("C1H")+M->C20_CODPAR,"C1H_UF")
			cValor	+=	", " + AllTrim( Posicione("C09",3,xFilial("C09")+cRetAux,"C09_DESCRI") )

			cRetAux	:=	Posicione("C1H",5,xFilial("C1H")+M->C20_CODPAR,"C1H_CODMUN")
			cValor	+=	", " + AllTrim( Posicione("C07",3,xFilial("C07")+cRetAux,"C07_DESCRI") )
		ElseIf nOpc == 24
			cValor := (M->C5F_SLCDIS - FWFLDGET("C5F_VLCRDE") - FWFLDGET("C5F_VCRRAT")- FWFLDGET("C5F_VCRCAT") - FWFLDGET("C5F_VCRTRA")- FWFLDGET("C5F_VLOTCR"))
		ElseIf nOpc == 25
			cValor := (FWFLDGET("C5F_SLCDIS") -M->C5F_VLCRDE - FWFLDGET("C5F_VCRRAT")- FWFLDGET("C5F_VCRCAT") - FWFLDGET("C5F_VCRTRA")- FWFLDGET("C5F_VLOTCR"))
		ElseIf nOpc == 26
			cValor := (FWFLDGET("C5F_SLCDIS") - FWFLDGET("C5F_VLCRDE") -M->C5F_VCRRAT- FWFLDGET("C5F_VCRCAT") - FWFLDGET("C5F_VCRTRA")- FWFLDGET("C5F_VLOTCR"))
		ElseIf nOpc == 27
			cValor := (FWFLDGET("C5F_SLCDIS") - FWFLDGET("C5F_VLCRDE") - FWFLDGET("C5F_VCRRAT") - M->C5F_VCRCAT - FWFLDGET("C5F_VCRTRA")- FWFLDGET("C5F_VLOTCR"))
		ElseIf nOpc == 28
			cValor := (FWFLDGET("C5F_SLCDIS") - FWFLDGET("C5F_VLCRDE") - FWFLDGET("C5F_VCRRAT")- FWFLDGET("C5F_VCRCAT") -M->C5F_VCRTRA- FWFLDGET("C5F_VLOTCR"))
		ElseIf nOpc == 29
			cValor := (FWFLDGET("C5F_SLCDIS") - FWFLDGET("C5F_VLCRDE") - FWFLDGET("C5F_VCRRAT")- FWFLDGET("C5F_VCRCAT") - FWFLDGET("C5F_VCRTRA")- M->C5F_VLOTCR)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Contra Dominio - C98_CODIGO e C98_DESCRI³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nOpc == 30

			If Upper(AllTrim(cCmpModel)) == "C98_CODIGO"
				If !Empty(FwFldGet("C98_IDITEM"))
					cValor := Posicione("C97",1,xFilial("C97") + FwFldGet("C98_IDITEM"),"C97_CODIGO")
				ElseIf !Empty(FwFldGet("C98_IDNIV"))
					cValor := Posicione("C96",1,xFilial("C96") + FwFldGet("C98_IDNIV"),"C96_CODIGO")
				ElseIf !Empty(FwFldGet("C98_IDGRU"))
					cValor := Posicione("C95",1,xFilial("C95") + FwFldGet("C98_IDGRU"),"C95_CODIGO")
				ElseIf !Empty(FwFldGet("C98_IDFAM"))
					cValor := Posicione("C94",1,xFilial("C94") + FwFldGet("C98_IDFAM"),"C94_CODIGO")
				Else
					cValor := TamSX3("C98_CODIGO")[2]
				EndIf
			ElseIf Upper(AllTrim(cCmpModel)) == "C98_DESCRI"
				If !Empty(FwFldGet("C98_IDITEM"))
					cValor := AllTrim(Posicione("C94",1,xFilial("C94") + FwFldGet("C98_IDFAM"),"C94_DESCRI")) + " - " +;
						AllTrim(Posicione("C95",1,xFilial("C95") + FwFldGet("C98_IDGRU"),"C95_DESCRI")) + " - " +;
						AllTrim(Posicione("C96",1,xFilial("C96") + FwFldGet("C98_IDNIV"),"C96_DESCRI")) + " - " +;
						AllTrim(Posicione("C97",1,xFilial("C97") + FwFldGet("C98_IDITEM"),"C97_DESCRI"))
				ElseIf !Empty(FwFldGet("C98_IDNIV"))
					cValor := AllTrim(Posicione("C94",1,xFilial("C94") + FwFldGet("C98_IDFAM"),"C94_DESCRI")) + " - " +;
						AllTrim(Posicione("C95",1,xFilial("C95") + FwFldGet("C98_IDGRU"),"C95_DESCRI")) + " - " +;
						AllTrim(Posicione("C96",1,xFilial("C96") + FwFldGet("C98_IDNIV"),"C96_DESCRI"))
				ElseIf !Empty(FwFldGet("C98_IDGRU"))
					cValor := AllTrim(Posicione("C94",1,xFilial("C94") + FwFldGet("C98_IDFAM"),"C94_DESCRI")) + " - " +;
						AllTrim(Posicione("C95",1,xFilial("C95") + FwFldGet("C98_IDGRU"),"C95_DESCRI"))
				ElseIf !Empty(FwFldGet("C98_IDFAM"))
					cValor := AllTrim(Posicione("C94",1,xFilial("C94") + FwFldGet("C98_IDFAM"),"C94_DESCRI"))
				Else
					cValor := TamSX3("C98_DESCRI")[2]
				EndIf
			EndIf
		ElseIf nOpc == 31
			cValor		:=  Posicione("C9V",1,xFilial("C9V") + &cCmpM, "Alltrim(C9V_MATRIC)+'-'+C9V_NOME")
		ElseIf nOpc == 32
			cRetAux 	:=  Posicione("CM6",1,xFilial("CM6")+&cCmp,"CM6_MOTVAF")
			cRetAux2    :=  Posicione("C8N",1,xFilial("C8N")+cRetAux,"C8N_DESCRI")
			cValor		:=  IF(!EMPTY(cRetAux2),CM6->CM6_FUNC + ' / ' + cRetAux + ' - ' + AllTrim(cRetAux2),"")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contra Dominio - CFT_DCODLA e CFT_IDCODL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nOpc == 33

			If "X291" $ Upper( FunDesc() )
				cReg := "X291"
			ElseIf "X292" $ Upper( FunDesc() )
				cReg := "X292"
			ElseIf "X360" $ Upper( FunDesc() )
				cReg := "X360"
			ElseIf "X390" $ Upper( FunDesc() )
				cReg := "X390"
			ElseIf "X400" $ Upper( FunDesc() )
				cReg := "X400"
			ElseIf "X460" $ Upper( FunDesc() )
				cReg := "X460"
			ElseIf "X470" $ Upper( FunDesc() )
				cReg := "X470"
			ElseIf "X480" $ Upper( FunDesc() )
				cReg := "X480"
			ElseIf "X490" $ Upper( FunDesc() )
				cReg := "X490"
			ElseIf "X500" $ Upper( FunDesc() )
				cReg := "X500"
			ElseIf "X510" $ Upper( FunDesc() )
				cReg := "X510"
			EndIf

			If Upper( AllTrim( cCmpModel ) ) == "CFT_DCODLA"

				cValor := Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( cReg, TamSX3( "CH6_CODREG" )[1] ) + FwFldGet( "CFT_CODLAN" ), "CH6_DESCRI" )

			ElseIf Upper( AllTrim( cCmpModel ) ) == "CFT_IDCODL"

				cValor := Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( cReg, TamSX3( "CH6_CODREG" )[1] ) + FwFldGet( "CFT_CODLAN" ), "CH6_ID" )

			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contra Dominio - CH5_DCODCT e CH5_IDCODC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nOpc == 34

			If FwFldGet( "CH5_TABECF" ) == "01"
				cReg := "L100A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "02"
				cReg := "L100B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "03"
				cReg := "L100C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "04"
				cReg := "L300A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "05"
				cReg := "L300B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "06"
				cReg := "L300C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "07"
				cReg := "P100"
			ElseIf FwFldGet( "CH5_TABECF" ) == "08"
				cReg := "P150"
			ElseIf FwFldGet( "CH5_TABECF" ) == "09"
				cReg := "U100A"
			ElseIf FwFldGet( "CH5_TABECF" ) == "10"
				cReg := "U100B"
			ElseIf FwFldGet( "CH5_TABECF" ) == "11"
				cReg := "U100C"
			ElseIf FwFldGet( "CH5_TABECF" ) == "12"
				cReg := "U100D"
			ElseIf FwFldGet( "CH5_TABECF" ) == "13"
				cReg := "U100E"
			EndIf

			If Upper( AllTrim( cCmpModel ) ) == "CH5_DCTARE"
				cValor := Posicione( "CHA", 2, xFilial( "CHA" ) + PadR( cReg, TamSX3( "CHA_CODREG" )[1] ) + FwFldGet( "CH5_CTAREF" ), "CHA_DESCRI" )
			ElseIf Upper( AllTrim( cCmpModel ) ) == "CH5_IDCTAR"
				cValor := Posicione( "CHA", 2, xFilial( "CHA" ) + PadR( cReg, TamSX3( "CHA_CODREG" )[1] ) + FwFldGet( "CH5_CTAREF" ), "CHA_ID" )
			EndIf

		ElseIf nOpc == 38

			cNatInfo := FWFLDGET(cCmpModel)

			If !Empty(cNatInfo)
				//S-4000 - T1R
				If cNatInfo $ ("1|2|")
					cValor := Posicione( "T1R", 3, xFilial( "T1R" ) + FWFLDGET(cCmp) + "1", "T1R_PROTUL" )
					//S-1299 - CUO
				ElseIf  cNatInfo == "3"
					cValor := Posicione( "CUO", 4, xFilial( "CUO" ) + FWFLDGET(cCmp) + "1", "CUO_PROTUL" )
				EndIf
			EndIf

		ElseIf nOpc == 39

			cId := FWFLDGET(cCmpModel)

			cIdTpBen := Posicione("T5T",3,xFilial("T5T")+cId+"1","T5T_TPBENE")

			cValor := Posicione("T5G",1,xFilial("T5G")+cIdTpBen,"T5G_CODIGO")

		ElseIf nOpc == 40

			cId := FWFLDGET(cCmpModel)

			cValor := Posicione("T5T",3,xFilial("T5T")+cId+"1","T5T_NUMBEN")

		ElseIf nOpc == 41

			cID := SubStr( cCmp, 1, 3  )+ "_IDPROC"

			DBSelectArea( "T9V" )
			T9V->( DBSetOrder( 5 ) ) //T9V_FILIAL + T9V_ID + T9V_ATIVO

			If T9V->( MsSeek( xFilial( "T9V" ) + FWFldGet( cID ) + "1" ) )
				DBSelectArea( "T9X" )
				T9X->( DBSetOrder( 1 ) ) //T9X_FILIAL + T9X_ID + T9X_VERSAO + T9X_CODSUS

				If T9X->( MsSeek( T9V->( T9V_FILIAL + T9V_ID + T9V_VERSAO ) + &( cCmpM ) ) )
					cValor := T9X->( T9X_ID + T9X_VERSAO + T9X_CODSUS )
				Else
					cValor := ""
				EndIf
			Else
				cValor := ""
			EndIf

		EndIf

	Else

		If cCmp + "|" $ "C20_VLMERC|C20_VLSERV|C20_VLDESC|C20_VLABNT|C20_VLRFRT|C20_VLRSEG|C20_VLRDA|C20_VLOUDE|"
			cRetAux	:=	'( FWFLDGET( "C20_VLMERC" ) + FWFLDGET( "C20_VLSERV" ) ) - ( FWFLDGET( "C20_VLDESC" ) + FWFLDGET( "C20_VLABNT" ) ) + FWFLDGET( "C20_VLRFRT" ) + FWFLDGET( "C20_VLRSEG" ) + FWFLDGET( "C20_VLRDA" ) + FWFLDGET( "C20_VLOUDE" )'

		ElseIf cCmp + "|" $ "C2S_TOTDEB|C2S_AJUDEB|C2S_TAJUDB|C2S_ESTCRE|C2S_TOTCRE|C2S_AJUCRE|C2S_TAJUCR|C2S_ESTDEB|C2S_CREANT|"
			cRetAux	:=	'( FWFLDGET( "C2S_TOTDEB" ) + FWFLDGET( "C2S_AJUDEB" ) + FWFLDGET( "C2S_TAJUDB" ) + FWFLDGET( "C2S_ESTCRE" ) ) - ( FWFLDGET( "C2S_TOTCRE" ) + FWFLDGET( "C2S_AJUCRE" ) + FWFLDGET( "C2S_TAJUCR" ) + FWFLDGET( "C2S_ESTDEB" ) + FWFLDGET( "C2S_CREANT" ) )'

		ElseIf cCmp + "|" $ "C3J_CREANT|C3J_VLRDEV|C3J_VLRRES|C3J_OUTCRD|C3J_AJUCRD|C3J_VLRRET|C3J_OUTDEB|C3J_AJUDEB|"
			cRetAux	:=	'( FWFLDGET( "C3J_VLRRET" ) + FWFLDGET( "C3J_OUTDEB" ) + FWFLDGET( "C3J_AJUDEB" ) ) - ( FWFLDGET( "C3J_CREANT" ) + FWFLDGET( "C3J_VLRDEV" ) + FWFLDGET( "C3J_VLRRES" ) + FWFLDGET( "C3J_OUTCRD" ) + FWFLDGET( "C3J_AJUCRD" ) )'

		ElseIf cCmp + "|" $ "C2N_VSDANT|C2N_VCRED|C2N_VOCRED|C2N_VDEB|C2N_VODEB|"
			cRetAux	:=	'( FWFLDGET( "C2N_VSDANT" ) + FWFLDGET( "C2N_VCRED" )+ FWFLDGET( "C2N_VOCRED" ) ) - (FWFLDGET( "C2N_VDEB" ) + FWFLDGET(" C2N_VODEB" ) )'

		EndIf

		//Executo a macro para retornar as informacoes dos campos do modelo e validar
		nValor	:=	&( cRetAux )

	EndIf

Return Iif( nValor == Nil .And. cValor == Nil , 0 , Iif( nValor == Nil , cValor , nValor ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunRelac

Função utilizada no X3_RELAC.
nTpRet: 0 - Código + Descrição
nTpRet: 1 - Código
nTpRet: 2 - Descricao

lBrw: Retorno é para campo que está no browse?

@Return	nValor	- Retorna o valor de retorno para o X3_RELAC

@Author	Danilo Zanaga
@Since		13/08/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function xFunRelac( nOpc, cCmpPar, nTpRet, lBrw )

	Local cValor    := ""
	Local cCmpM     := ReadVar()
	Local cCampo    := ""
	Local cAlsCmp   := ""
	Local cCampo2   := ""
	Local cCmp3Pos  := SubStr( cCmpM, 4, 3 )
	Local cRetAux   := ""
	Local cRetAux2  := ""
	Local cFilItem  := ""
	Local nRecno    := 0
	Local aAreaBkp  := Nil
	Local lECFCent  := .F.// Define se a apuração é feita de forma centralizada ou não.

	Default cCmpPar := ""
	Default nOpc    := 999
	Default nTpRet  := 0
	Default lBrw    := .F.

	cCampo		:=	cCmpPar
	cAlsCmp	:=	SubStr( cCampo, 1, 3 )
	cCmp3Pos	:=	cCmp3Pos + "->" + cCmp3Pos + "_"

	If "T0J_TPTRIB" $ cCmpM

		cValor := MV_PAR01//cIDTrib
		If nOpc == 999 .And. Empty(cValor)
			TAF430Pre( 'INCLUIR', 'TAFA430' )
			cValor := MV_PAR01 //cIDTrib
		EndIf

	ElseIf "T0J_DTPTRI" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If INCLUI
			cCampo2 := FWFldGet( cCampo )
		EndIf

		cValor := Posicione( "C3S", 3, xFilial( "C3S" ) + cCampo2, "C3S->( AllTrim( C3S_CODIGO ) + ' - ' + AllTrim( C3S_DESCRI ) )" )

	ElseIf "T0J_DCODRE" $ cCmpM

		If !Empty( &( cAlsCmp + "->" + cCampo ) )
			cCampo2 := &( cAlsCmp + "->" + cCampo )
			cValor := Iif( !INCLUI .and. !Empty( cCampo2 ), Posicione( "C6R", 3, xFilial( "C6R" ) + cCampo2, "C6R->( AllTrim( C6R_CODIGO ) + ' - ' + AllTrim( C6R_DESCRI ) )" ), "" )
		EndIf

	ElseIf "T0N_CODFTR" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0K", 1, xFilial( "T0K" ) + cCampo2, "AllTrim( T0K->T0K_CODIGO )" )
		ElseIf cAlsCmp == "T0N"
			cValor := Posicione( "T0K", 1, xFilial( "T0K" ) + cIDFormTrib, "AllTrim( T0K->T0K_CODIGO )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T0N_DFTRIB" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0K", 1, xFilial( "T0K" ) + cCampo2, "AllTrim( T0K->T0K_DESCRI )" )
		ElseIf(cAlsCmp == "T0N")
			cValor := Posicione( "T0K", 1, xFilial( "T0K" ) + cIDFormTrib, "AllTrim( T0K->T0K_DESCRI )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T0N_CODEVE" $ cCmpM

		aAreaBkp := T0N->( GetArea() )
		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0N", 1, xFilial( "T0N" ) + cCampo2, "T0N->T0N_CODIGO" )
		Else
			cValor := ""
		EndIf

		RestArea( aAreaBkp )

	ElseIf "T0N_DEVENT" $ cCmpM

		aAreaBkp := T0N->( GetArea() )
		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0N", 1, xFilial( "T0N" ) + cCampo2, "T0N->T0N_DESCRI" )
		Else
			cValor := ""
		EndIf

		RestArea( aAreaBkp )

	ElseIf "T0O_DCUSTO" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )
		cFilItem := xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "C1P", 3, xFilial( "C1P", cFilItem ) + T0O->T0O_IDCUST, "C1P->( AllTrim( C1P_CODCUS ) + ' - ' + SubStr( C1P_CCUS, 1, 60 ) )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T0O_CODCC" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )
		cFilItem := xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "C1O", 3, xFilial( "C1O", cFilItem ) + T0O->T0O_IDCC, "C1O->( AllTrim( C1O_CODIGO ) )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T0O_CODPAB" $ cCmpM
		lECFCent := SuperGetMv("MV_TAFCENT",.F.,.T.)
		cCampo2  := &( cAlsCmp + "->" + cCampo )
		cFilItem := Iif( lECFCent, xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 ), T0O->T0O_FILIAL )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0S", 1, xFilial( "T0S", cFilItem ) + T0O->T0O_IDPARB, "T0S->( AllTrim( T0S_CODIGO ) )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T0O_DPARTB" $ cCmpM
		lECFCent := SuperGetMv("MV_TAFCENT",.F.,.T.)
		cCampo2  := &( cAlsCmp + "->" + cCampo )
		cFilItem := Iif( lECFCent, xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 ), T0O->T0O_FILIAL )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0S", 1, xFilial( "T0S", cFilItem ) + T0O->T0O_IDPARB, "T0S->( SubStr( T0S_DESCRI, 1, 100 ) )" )
		Else
			cValor := ""
		EndIf

	ElseIf "CWV_CODTRI" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0J", 1, xFilial( "T0J" ) + cCampo2, "AllTrim( T0J->T0J_CODIGO )" )
		ElseIf cAlsCmp == "CWV"
			cValor := Posicione( "T0J", 2, xFilial( "T0J" ) + MV_PAR01, "AllTrim( T0J->T0J_CODIGO )" )
		Else
			cValor := ""
		EndIf

	ElseIf "CWV_DTRIBU" $ cCmpM

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )
			cValor := Posicione( "T0J", 1, xFilial( "T0J" ) + cCampo2, "AllTrim( T0J->T0J_DESCRI )" )
		ElseIf cAlsCmp == "CWV"
			cValor := Posicione( "T0J", 2, xFilial( "T0J" ) + MV_PAR01, "AllTrim( T0J->T0J_DESCRI )" )
		Else
			cValor := ""
		EndIf

	ElseIf "T63_IDBENE" $ cCmpPar .And. nOpc == 1

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )

			cIdTpBen := Posicione("T5T",3,xFilial("T5T")+cCampo2+"1","T5T_TPBENE")

			cValor := Posicione("T5G",1,xFilial("T5G")+cIdTpBen,"T5G_CODIGO")
		Else
			cValor := ""
		EndIf

	ElseIf "T63_IDBENE" $ cCmpPar .And. nOpc == 2

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !INCLUI .and. !Empty( cCampo2 )

			cValor := Posicione("T5T",3,xFilial("T5T")+cCampo2+"1","T5T_NUMBEN")

		Else
			cValor := ""
		EndIf

	ElseIf nOpc == 1

		cValor := Iif( !INCLUI .and. !Empty( C50->C50_CODAJU ), Posicione( "C1A", 4, xFilial( "C1A" ) + C50->C50_CODAJU, "AllTrim( C1A_CODIGO ) + ' - ' + SubStr( C1A_DESCRI, 1, 150 )" ), "" )

	ElseIf nOpc == 2

		cValor := Iif( !INCLUI .and. !Empty( C58->C58_NATREC ), Posicione( "C1U", 6, xFilial( "C1U" ) + C58->C58_NATREC, "AllTrim( C1U_CODIGO ) + ' - ' + SubStr( C1U_DESCRI, 1, 150 )" ), "" )

	ElseIf nOpc == 3

		If C20->C20_CODMOD $ "000004/000020" //"06/28"
			cValor := Iif( !INCLUI .and. !Empty( C2E->C2E_CODCON ), Posicione( "C0L", 3, xFilial( "C0L" ) + C2E->C2E_CODCON, "C0L_DESCRI" ), "" )
		Else
			cValor := Iif( !INCLUI .and. !Empty( C2E->C2E_CODCON ), Posicione( "C0O", 3, xFilial( "C0O" ) + C2E->C2E_CODCON, "C0O_DESCRI" ), "" )
		EndIf

	ElseIf nOpc == 4

		cCampo	:=	cCmp3Pos + "CST"
		cCampo2	:=	cCmp3Pos + "CODTRI"

		//ISSQN
		If &cCampo2 $ '000001/000016'

			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C0H" , 3 , xFilial( "C0H" ) + &cCampo , "AllTrim(C0H_CODIGO) + ' - ' + SubStr(C0H_DESCRI,1,150)"),"")

		//ICMS e ICMS/ST
		ElseIf &cCampo2 $ '000002/000003/000004/000017/000026'

			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C14" , 3 , xFilial( "C14" ) + &cCampo , "AllTrim(C14_CODIGO) + ' - ' + SubStr(C14_DESCRI,1,150)"),"")

		//IPI
		ElseIf &cCampo2 $ '000005'

			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C15" , 3 , xFilial( "C15" ) + &cCampo , "AllTrim(C15_CODIGO) + ' - ' + SubStr(C15_DESCRI,1,150)"),"")

		//PIS/Pasep/Cofins
		ElseIf &cCampo2 $ '000006/000007/000008/000009/000010/000011/000014/000015'

			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C17" , 3 , xFilial( "C17" ) + &cCampo , "AllTrim(C17_CODIGO) + ' - ' + SubStr(C17_DESCRI,1,150)"),"")

		EndIf

	//Tratamento para consulta da Modalidade de determinacao da base de calculo do ICMS e/ou ICMS/ST conforme tributo do documento fiscal selecionado
	ElseIf nOpc == 5

		cCampo	:=	cCmp3Pos + "MODBC"
		cCampo2:=	cCmp3Pos + "CODTRI"

		//ICMS
		If &cCampo2 $ '000002/000003/000017'
			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C04" , 3 , xFilial( "C04" ) + &cCampo , "AllTrim(C04_CODIGO) + ' - ' + SubStr(C04_DESCRI,1,150)"),"")

			//ICMS/ST
		ElseIf &cCampo2 $ '000004/000026'
			cValor := IiF( !INCLUI .AND. !EMPTY( &cCampo ) , Posicione( "C05" , 3 , xFilial( "C05" ) + &cCampo , "AllTrim(C05_CODIGO) + ' - ' + SubStr(C05_DESCRI,1,150)"),"")

		EndIf

	ElseIf nOpc == 6

		If !INCLUI .And. !Empty( C20->C20_CODPAR )
			cRetAux	:=	POSICIONE("C1H",5,xFilial("C1H")+C20->C20_CODPAR,"C1H_CODPAI")
			cValor	:=	AllTrim( POSICIONE("C08",3,xFilial("C08")+cRetAux,"C08_DESCRI") )

			cRetAux	:=	POSICIONE("C1H",5,xFilial("C1H")+C20->C20_CODPAR,"C1H_UF")
			cValor	+=	", " + AllTrim( POSICIONE("C09",3,xFilial("C09")+cRetAux,"C09_DESCRI") )

			cRetAux	:=	POSICIONE("C1H",5,xFilial("C1H")+C20->C20_CODPAR,"C1H_CODMUN")
			cValor	+=	", " + AllTrim( POSICIONE("C07",3,xFilial("C07")+cRetAux,"C07_DESCRI") )
		EndIf

	ElseIf nOpc == 7

		If !INCLUI .And. !Empty( C20->C20_CODPAR )
			cValor	:=	POSICIONE("C1H",5,xFilial("C1H")+C20->C20_CODPAR,"C1H_DDD+'-'+C1H_FONE+', '+C1H_DDDFAX+'-'+C1H_FAX")
		EndIf

	ElseIf nOpc == 8

		cValor	:= IIF(!INCLUI.AND.!EMPTY(C2T->C2T_CODAJU),POSICIONE("C1A",4,xFilial("C1A")+C2T->C2T_CODAJU,"AllTrim(C1A_CODIGO)+ ' - ' +SubStr(C1A_DESCRI,1,150)"),"")

	ElseIf nOpc == 9

		cValor	:= IIF(!INCLUI.AND.!EMPTY(C3K->C3K_CODAJU),POSICIONE("C1A",4,xFilial("C1A")+C3K->C3K_CODAJU,"AllTrim(C1A_CODIGO)+ ' - ' +SubStr(C1A_DESCRI,1,150)"),"")

	ElseIf nOpc == 10

		If !INCLUI .And. !Empty( C1L->C1L_CODIND )
			cRetAux	:=	POSICIONE("C3X",3,xFilial("C3X")+C1L_CODIND,"C3X_CODTAB")
			cValor	:=	AllTrim( POSICIONE("C3V",3,xFilial("C3V")+cRetAux,"C3V_DESCRI") )
		EndIf

	ElseIf nOpc == 14

		cValor	:=	IF(!INCLUI.AND.!EMPTY(C0R->C0R_CODPRD),POSICIONE("C6U",3,xFilial("C6U")+C0R->C0R_CODPRD,"AllTrim(C6U_CODIGO)+' - '+SubStr(C6U_DESCRI,1,150)"),"")

	ElseIf nOpc == 17

		cValor	:=	IF(!INCLUI.AND.!EMPTY(C2U->C2U_DOCARR),POSICIONE("C0R",6,xFilial("C0R")+C2U->C2U_DOCARR,"AllTrim(C0R_NUMDA)+' - '+SubStr(C0R_DESDOC,1,150)"),"")

	ElseIf nOpc == 21

		cValor	:=	IF(!INCLUI.AND.!EMPTY(C4S->C4S_INDBEM),POSICIONE("C2L",3,xFilial("C2L")+C4S->C4S_INDBEM,"AllTrim(C2L_CODBEM)+' - '+SubStr(C2L_DESCRI,1,150)"),"")

	ElseIf nOpc == 43

		cValor	:=	IF(!INCLUI .AND. !EMPTY(C3O->C3O_UNID),POSICIONE("C1J",3, xFilial("C1J")+C3O->C3O_UNID,"AllTrim(C1J_CODIGO)+' - '+SubStr(C1J_DESCRI,1,150)"),"")

	ElseIf nOpc == 44

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C01",3,xFilial("C01")+cCampo2,"AllTrim(C01_CODIGO)+' - '+SubStr(C01_DESCRI,1,150)"),;
			IF(cAlsCmp == "C20",POSICIONE("C01",3,xFilial("C01")+FWFLDGET("C20_CODMOD"),"AllTrim(C01_CODIGO)+' - '+SubStr(C01_DESCRI,1,150)"),""))

	ElseIf nOpc == 73 //CRP_DAGEQU

		cValor	:= ""
		IF (!INCLUI.AND.!EMPTY(CRP->CRP_IDMBIO))

			("CUQ")->(DBSetOrder(1))
			If ("CUQ")->(MsSeek(xFilial("CUQ")+CRP->CRP_IDMBIO))

				("CUA")->(DBSetOrder(1))
				If ("CUA")->(MsSeek(xFilial("CUM")+CUQ->CUQ_CODAGE))
					cValor := CUA->(CUA_CODIGO + ' - ' + CUA_DESCRI)
				EndIf

			EndIf

		EndIf

	ElseIf nOpc == 74 //CRP_DCODAN

		cValor	:= ""

		IF (!INCLUI.AND.!EMPTY(CRP->CRP_IDMBIO))

			("CUQ")->(DBSetOrder(1))
			If ("CUQ")->(MsSeek(xFilial("CUQ")+CRP->CRP_IDMBIO))

				("CUM")->(DBSetOrder(1))
				If ("CUM")->(MsSeek(xFilial("CUM")+CUQ->CUQ_CODBIO))
					cValor := CUM->(CUM_CODIGO + ' - ' + CUM_DESCRI)
				EndIf

			EndIf

		EndIf

	ElseIf nOpc == 47 //CFQ_DNATOP

		cValor	:= ""

		IF (!INCLUI.AND.!EMPTY(CFQ->CFQ_NATOPE))

			dbSelectArea("C1N")
			("C1N")->(DBSetOrder(3))
			If ("C1N")->(MsSeek(xFilial("C1N")+CFQ->CFQ_NATOPE))
				cValor := Alltrim(C1N->C1N_CODNAT)+' - '+left(C1N_DESNAT,30)
			EndIf

		EndIf

	//Conta contabil -> C1O
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '011/018/026/031/036/039/041/'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )

		If nTpRet == 1     //código
			cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1O",3,xFilial("C1O")+cCampo2, "AllTrim(C1O_CODIGO)"),"")
		ElseIf nTpRet == 0 //código + descricao
			cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1O",3,xFilial("C1O")+cCampo2, "AllTrim(C1O_CODIGO)+' - '+SubStr(C1O_DESCRI,1,150)"),"")
		EndIf

	//Centro de Custo -> C1P
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '012/019/027/'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1P",3,xFilial("C1P")+cCampo2, "AllTrim(C1P_CODCUS)+' - '+SubStr(C1P_CCUS,1,150)"),"")

	//Itens -> C1L
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '013/023/024/029/032/034/038/040/042/'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor		:=	IF(!INCLUI .AND. !EMPTY(cCampo2),POSICIONE("C1L",3, xFilial("C1L")+cCampo2,"AllTrim(C1L_CODIGO)+' - '+SubStr(C1L_DESCRI,1,150)"),"")

	//Participante -> C1H
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '015/022/025/028/030/035/'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		If nTpRet == 1     //código
			cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1H",5,xFilial("C1H")+cCampo2,"AllTrim(C1H_CODPAR)"),"")
		ElseIf nTpRet == 0 //código + descricao
			cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1H",5,xFilial("C1H")+cCampo2,"AllTrim(C1H_CODPAR)+' - '+SubStr(C1H_NOME,1,150)"),"")
		Endif

	//Processo Referenciado -> C1G
	ElseIf !Empty( cCampo ) .and. StrZero( nOpc, 3 ) $ "016/020/033/037/061/071"

		If(cCmpPar == 'C3N_NRPROC' .And. nOpc == 16)
			cCampo2		:=	ALLTRIM(&( cAlsCmp + '->' + cCampo ))
		Else
			cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		EndIf

		cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C1G",3,xFilial("C1G")+cCampo2,"AllTrim(C1G_NUMPRO)+' - '+SubStr(C1G_DESCRI,1,150)"),"")

	//Processo Referenciado -> C01
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '045'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C01",3,xFilial("C01")+cCampo2,"AllTrim(C01_CODIGO)+' - '+SubStr(C01_DESCRI,1,150)"),"")


	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '048'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cRetAux 	:=  Posicione("C9V",1,xFilial("C9V")+cCampo2,"C9V->C9V_ID+C9V->C9V_VERSAO")
		cRetAux2	:=  Posicione("C9V",1,xFilial("C9V")+cRetAux,"C9V_CPF")
		//cRetAux2	:=  Posicione("CUP",1,xFilial("CUP")+cRetAux,"CUP_MATRIC")
		cValor		:=  IF(!INCLUI .And. !EMPTY(cCampo2),AllTrim(cRetAux2) + " - " + AllTrim(C9V->C9V_NOME),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '049'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cRetAux 	:=  Posicione("CM6",1,xFilial("CM6")+cCampo2,"CM6_MOTVAF")
		cRetAux2    :=  Posicione("C8N",1,xFilial("C8N")+cRetAux,"C8N_DESCRI")
		cValor		:=  IF(!INCLUI .And. !EMPTY(cRetAux2),CM6->CM6_FUNC + ' / ' + cRetAux + ' - ' + AllTrim(cRetAux2),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '050/057/058/062/068'

		//Tratamento para reposicionamento na tabela, pois sera desposicionada para buscar conta superior, que fica na mesma tabela
		aAreaBkp := C1O->( GetArea() )
		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If !lBrw
			If nTpRet == 1     //código
				cValor  := Iif( !Empty( cCampo2 ) .and. !INCLUI, Posicione( "C1O", 3, xFilial( "C1O" ) + cCampo2, "AllTrim( C1O_CODIGO )" ), "" )
			ElseIf nTpRet == 0 //codigo + descricao
				cValor  := Iif( !Empty( cCampo2 ) .and. !INCLUI, Posicione( "C1O", 3, xFilial( "C1O" ) + cCampo2, "AllTrim( C1O_CODIGO ) + ' – ' + AllTrim( C1O_DESCRI )" ), "" )
			EndIf
		Else
			cValor  := Iif( !Empty( cCampo2 ), Posicione( "C1O", 3, xFilial( "C1O" ) + cCampo2, "AllTrim( C1O_CODIGO )" ), "" )
		EndIf

		RestArea( aAreaBkp )

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '051/059/066/067/069/070'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C1P",3, xFilial("C1P")+cCampo2, "AllTrim(C1P_CODCUS)+' - '+ AllTrim(C1P_CCUS)" ),"")
		
	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '052/054'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C0A",3, xFilial("C0A")+cCampo2, "AllTrim(C0A_CODIGO)+' – '+ AllTrim(C0A_DESCRI)" ),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '053/055'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C1J",3, xFilial("C1J")+cCampo2, "AllTrim(C1J_CODIGO)+' – '+ AllTrim(C1J_DESCRI)" ),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '056'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C0W",4, xFilial("C0W")+cCampo2, "AllTrim(C0W_CODIGO)+' – '+ AllTrim(C0W_DESCRI)" ),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '057'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C3R",4, xFilial("C3R")+cCampo2, "AllTrim(C3R_CODIGO)+' – '+ AllTrim(C3R_DESCRI)" ),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '058'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C1G",4, xFilial("C1G")+cCampo2, "AllTrim(C1G_NUMPRO)+' – '+ AllTrim(C1G_DESCRI)" ),"")

	ElseIf !Empty(cCampo) .And. StrZero( nOpc , 3 ) $ '059'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor 		:= IF(!EMPTY(cCampo2) .And. !INCLUI,Posicione( "C1L",3, xFilial("C1L")+cCampo2, "AllTrim(C1L_CODIGO)+' – '+ AllTrim(C1L_DESCRI)" ),"")

	//Lista Serviço -> C0B
	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '060'

		cCampo2		:=	&( cAlsCmp + '->' + cCampo )
		cValor		:=	IF(!INCLUI.AND.!EMPTY(cCampo2),POSICIONE("C0B",3,xFilial("C0B")+cCampo2,"AllTrim(C0B_CODIGO)+' - '+SubStr(C0B_DESCRI,1,150)"),"")

	ElseIf !Empty( cCampo ) .And. StrZero( nOpc , 3 ) $ '061'

		cCampo2	:=	&( cAlsCmp + '->' + cCampo )
		cValor		:= IF(!INCLUI.AND.!EMPTY(CA2->CA2_INDATV),Posicione("CA0",1,xFilial("CA0")+cCampo2,"AllTrim(CA0_CODIGO) + ' - '+ SubStr(CA0_DESCRI,1,150)"),"")

	ElseIf StrZero( nOpc , 3 ) $ '072'

		cValor := IF(!INCLUI.AND.!EMPTY(C20->C20_TPDOC),POSICIONE("C0U",3,xFilial("C0U")+C20->C20_TPDOC,"AllTrim(C0U_CODIGO)+' - '+SubStr(C0U_DESCRI,1,150)"),"")

	ElseIf !Empty( cCampo ) .and. StrZero( nOpc, 3 ) $ "063|064|065"

		nRecno := CHA->( Recno() )

		cCampo2 := &( cAlsCmp + "->" + cCampo )

		If StrZero( nOpc, 3 ) $ "063"
			cValor  := Iif( !Empty( cCampo2 ) .and. !INCLUI, Posicione( "CHA", 1, xFilial( "CHA" ) + cCampo2, "CHA_CODIGO" ), "" )
		ElseIf StrZero( nOpc, 3 ) $ "064"
			cValor  := Iif( !Empty( cCampo2 ) .and. !INCLUI, Posicione( "CHA", 1, xFilial( "CHA" ) + cCampo2, "CHA_DESCRI" ), "" )
		ElseIf StrZero( nOpc, 3 ) $ "065"
			cValor  := Iif( !Empty( cCampo2 ), Posicione( "CHA", 1, xFilial( "CHA" ) + cCampo2, "CHA_CODIGO" ), "" )
		EndIf

		CHA->( DBGoTo( nRecno ) )

	ElseIf StrZero( nOpc , 3 ) $ '075'

		cValor := IF(!INCLUI.AND.!EMPTY(C1G->C1G_INDDEC),POSICIONE("C8S",1,xFilial("C8S")+C1G->C1G_INDDEC,"AllTrim(C8S_CODIGO)+' - '+AllTrim(C8S_DESCRI)"),"")

	ElseIf StrZero( nOpc , 3 ) $ '076'

		If !Empty(&( cAlsCmp + '->' + cCampo ))

			dbSelectArea("C1G")
			("C1G")->(DBSetOrder(8))
			If ("C1G")->(MsSeek(xFilial("C1G")+&( cAlsCmp + '->' + cCampo ) + "1"))
				cValor := "Processo " + Iif( C1G->C1G_TPPROC == "2", "Administrativo - ", "Judicial - " )
				cValor += C1G->C1G_NUMPRO
			EndIf

		Endif

	ElseIf nOpc == 77

		cValor := IIF(!INCLUI,POSICIONE("T04",1,xFilial("T04")+T3C->T3C_IDAMB,"T04_DESCRI"),"")

	ElseIf nOpc == 79

		cValor := IIF(!EMPTY(CM6->CM6_DTFAFA) .And. CM6->CM6_DTFAFA <= dDatabase ,"Periodo Afastamento Finalizado","Periodo Afastamento em Aberto")

	ElseIf nOpc == 80

		cNatInfo := FWFLDGET(cCmpPar)

		If !Empty(cNatInfo)

			//S-4000 - T1R
			If cNatInfo $ ("1|2|")
				cValor := IF(!INCLUI.AND.!EMPTY(&(cCmp3Pos + "IDARQB")),POSICIONE("T1R",3, xFilial("T1R")+ &(cCmp3Pos + "IDARQB") +"1","T1R->T1R_PROTUL"),"")
				//S-1299 - CUO
			ElseIf  cNatInfo == "3"
				cValor := IF(!INCLUI.AND.!EMPTY(&(cCmp3Pos + "IDARQB")),POSICIONE("CUO",4, xFilial("CUO")+ &(cCmp3Pos + "IDARQB") +"1","CUO->CUO_PROTUL"),"")
			EndIf

		EndIf

	ElseIf nOpc == 81

		cValor := IIF(!INCLUI .AND. !EMPTY(C9Q->C9Q_TRABAL),Posicione("C9V",1,xFilial("C9V")+C9Q->C9Q_TRABAL,"Alltrim(C9V_MATRIC)"),"")

	ElseIf nOpc == 82

		cValor := IIF(!INCLUI .AND. !EMPTY(C9L->C9L_TRABAL),Posicione('C9V',1,xFilial('C9V')+C9L->C9L_TRABAL,"Alltrim(C9V_MATRIC)"),"")

	ElseIf nOpc == 83

		cCampo	:= "IDRUBR"
		cCampo2 := &( cCmp3Pos + cCampo )

		cValor := Iif(!INCLUI .AND. !EMPTY(cCampo2),Posicione("C8R", 1, xFilial("C8R")+cCampo2, "Alltrim(C8R_CODRUB)+ ' - ' +Alltrim(C8R_DESRUB)"),"")

	ElseIf nOpc == 84

		cValor := Iif(!INCLUI .and. !Empty(CRQ->CRQ_CODHOR),Posicione("C90",1,xFilial("C90")+CRQ->CRQ_CODHOR,"Alltrim(C90_CODIGO)+' - '+C90_DESCRI"),"")

	ElseIf nOpc == 85

		cValor := Iif(!INCLUI .and. !Empty(CUU->CUU_FUNCI),Posicione("C8X",1,xFilial("C8X")+CUU->CUU_FUNCI,"Alltrim(C8X_CODIGO)+' – '+C8X_DESCRI"),"")

	ElseIf nOpc == 86

		cValor	:= Iif(!INCLUI .and. !Empty(&(cCmp3Pos + "IDAMB")),Posicione("T04",3,xFilial("T04")+&(cCmp3Pos + "IDAMB")+'1',"Alltrim(T04_CODIGO)+' - '+T04_DESCRI"),"")

	ElseIf nOpc == 87

		If cCmpPar == "C9L_TRABAL"

			cIdCatTrb := Posicione("CUP",1,xFilial("CUP")+C9L->C9L_TRABAL,"CUP_CODCAT")
			cDescCat  := Posicione("C87",1,xFilial("C87")+cIdCatTrb,"C87_CODIGO+'-'+C87_DESCRI")
			cValor	:= IF(!INCLUI .AND. !EMPTY(C9L->C9L_TRABAL),cDescCat,"")

		ElseIf cCmpPar == "C9Q_TRABAL"

			cIdCatTrb := Posicione("CUP",1,xFilial("CUP")+C9Q->C9Q_TRABAL,"CUP_CODCAT")
			cDescCat  := Posicione("C87",1,xFilial("C87")+cIdCatTrb,"C87_CODIGO+'-'+C87_DESCRI")
			cValor	:= IF(!INCLUI .AND. !EMPTY(C9Q->C9Q_TRABAL),cDescCat,"")

		EndIf

	ElseIf nOpc == 89

		If Select('C9M') > 0 .And. Select('C91') > 0 .And. !Empty(C9M->C9M_RUBRIC)

			nRecno := TAFCodRub( AllTrim(C9M->C9M_RUBRIC), C91->C91_PERAPU,,, AllTrim(C9M->C9M_IDTABR) )

			DbSelectArea("C8R")
			C8R->(DbGoTo(nRecno))

			cValor := AllTrim(C9M->C9M_RUBRIC) + ' - ' + AllTrim(C8R->C8R_DESRUB)

		Else

			cCampo	:= "CODRUB"
			cCampo2 := &( cCmp3Pos + cCampo )

			cValor := Iif(!INCLUI .AND. !EMPTY(cCampo2),Posicione("C8R", 1, xFilial("C8R")+cCampo2, "Alltrim(C8R_CODRUB)+ ' - ' +Alltrim(C8R_DESRUB)"),"")

		EndIf

	ElseIf "T0F_NOME" $ cCmpM

		// Tratamento para simplificação do e-Social
		If !(TafLayESoc("S_01_00_00"))
			cValor	:= Iif(!INCLUI .and. !Empty(T0Q->T0Q_CODAMB),Posicione("T04",1,xFilial("T04")+T0Q->T0Q_CODAMB,"AllTrim(T04_CODIGO)+' – '+T04_DESCRI"),"")
		Else
			cValor	:= Iif(!INCLUI .and. !Empty(T0Q->T0Q_LAMB),Posicione("T04",1,xFilial("T04")+T0Q->T0Q_LAMB,"AllTrim(T04_CODIGO)+' – '+T04_DESCRI"),"")
		EndIf

	ElseIf "T1V_NOME" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T1V->T1V_ID),Posicione("C9V",1,xFilial("C9V")+T1V->T1V_ID,"C9V_NOME"),"")

	ElseIf "T1U_NOME" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T1U->T1U_ID),Posicione("C9V",1,xFilial("C9V")+T1U->T1U_ID,"C9V_NOME"),"")

	ElseIf "T0Q_DCODAM" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T0Q->T0Q_LAMB),Posicione("T04",1,xFilial("T04")+T0Q->T0Q_LAMB,"AllTrim(T04_CODIGO)+' – '+T04_DESCRI"),"")

	ElseIf "LE2_DRUBR" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(LE2->LE2_IDRUBR),Posicione("C8R",1,xFilial("C8R")+LE2->LE2_IDRUBR,"AllTrim(C8R_CODRUB)+' – '+C8R_DESRUB"),"")

	ElseIf "LE4_DRUBR" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(LE4->LE4_IDRUBR),Posicione("C8R",1,xFilial("C8R")+LE4->LE4_IDRUBR,"AllTrim(C8R_CODRUB)+' – '+C8R_DESRUB"),"")

	ElseIf "T6Q_DRUBR" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T6Q->T6Q_IDRUBR),Posicione("C8R",1,xFilial("C8R")+T6Q->T6Q_IDRUBR,"AllTrim(C8R_CODRUB)+' – '+C8R_DESRUB"),"")

	ElseIf "T6R_DRUBR" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T6R->T6R_IDRUBR),Posicione("C8R",1,xFilial("C8R")+T6R->T6R_IDRUBR,"AllTrim(C8R_CODRUB)+' – '+C8R_DESRUB"),"")

	ElseIf "T5Y_DRUBR" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(T5Y->T5Y_IDRUBR),Posicione("C8R",1,xFilial("C8R")+T5Y->T5Y_IDRUBR,"AllTrim(C8R_CODRUB)+' – '+C8R_DESRUB"),"")

	ElseIf "C3B_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C3B->C3B_CODCTA),Posicione("C1O",3,xFilial("C1O")+C3B->C3B_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C3B_DCODPA" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C3B->C3B_CODPAR),Posicione("C1H",5,xFilial("C1H")+C3B->C3B_CODPAR,"AllTrim(C1H_CODPAR)+' - '+C1H_NOME"),"")

	ElseIf "C4I_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C4I->C4I_CODCTA),Posicione("C1O",3,xFilial("C1O")+C4I->C4I_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C58_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C58->C58_CODCTA),Posicione("C1O",3,xFilial("C1O")+C58->C58_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C5M_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C5M->C5M_CODCTA),Posicione("C1O",3,xFilial("C1O")+C5M->C5M_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C6M_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C6M->C6M_CODCTA),Posicione("C1O",3,xFilial("C1O")+C6M->C6M_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C7J_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C7J->C7J_CODCTA),Posicione("C1O",3,xFilial("C1O")+C7J->C7J_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "C7K_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(C7K->C7K_CODCTA),Posicione("C1O",3,xFilial("C1O")+C7K->C7K_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CA9_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CA9->CA9_CODCTA),Posicione("C1O",3,xFilial("C1O")+CA9->CA9_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CAA_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CAA->CAA_CODCTA),Posicione("C1O",3,xFilial("C1O")+CAA->CAA_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CAD_DCTA" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CAD->CAD_CTA),Posicione("C1O",3,xFilial("C1O")+CAD->CAD_CTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CAF_DCTA" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CAF->CAF_CTA),Posicione("C1O",3,xFilial("C1O")+CAF->CAF_CTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CEQ_DCTA" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CEQ->CEQ_CTA),Posicione("C1O",3,xFilial("C1O")+CEQ->CEQ_CTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "CHB_DCODCT" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(CHB->CHB_CODCTA),Posicione("C1O",3,xFilial("C1O")+CHB->CHB_CODCTA,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "T0O_DCONTC" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(T0O->T0O_IDCC),Posicione("C1O",3,xFilial("C1O")+T0O->T0O_IDCC,"AllTrim(C1O_CODIGO)+' - '+C1O_DESCRI"),"")

	ElseIf "T31_NOME" $ cCmpM

		cValor := Iif(!INCLUI .and. !EMPTY(T31->T31_CODPAR),Posicione("C1H",5,xFilial("C1H")+T31->T31_CODPAR,"AllTrim(C1H_CODPAR)+' - '+C1H_NOME"),"")

	ElseIf "V3E_DESCAT" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(V3E->V3E_IDATV),Posicione("V2L",1,xFilial("V2L")+V3E->V3E_IDATV,"AllTrim(V2L_CODIGO)+' – '+V2L_DESCRI"),"")

	ElseIf "CMA_DESCUM" $ cCmpM

		cValor	:= Iif(!INCLUI .and. !Empty(CMA->CMA_UNMED),Posicione("V3F",1,xFilial("V3F")+CMA->CMA_UNMED,"AllTrim(V3F_CODIGO)+' – '+V3F_DESCRI"),"")

	ElseIf nOpc == 90

		cValor  := IF(!INCLUI .AND. !EMPTY(T86->T86_CODPAR),POSICIONE("C1H",5,XFILIAL("C1H")+ T86->T86_CODPAR,"Alltrim(C1H_CODPAR)+' -  '+Alltrim(C1H_NOME)"),"")

	ElseIf nOpc == 91

		cValor  := IF(!INCLUI .AND. !EMPTY(T86->T86_CODITE),POSICIONE("C1L",3,XFILIAL("C1L")+ T86->T86_CODITE,"Alltrim(C1L_CODIGO)+' - '+Alltrim(C1L_DESCRI)"),"")

	ElseIf nOpc == 92

		cValor	:= IIF(!INCLUI.AND.!EMPTY(C2T->C2T_CODAJ1),POSICIONE("C0J",3,xFilial("C0J")+C2T->C2T_CODAJ1,"AllTrim(C0J_CODIGO)+ ' - ' +SubStr(C0J_DESCRI,1,150)"),"")

	ElseIf nOpc == 93

		cValor	:= Posicione("C9V",1,xFilial("C9V",CM8->CM8_FILIAL)+CM8->CM8_TRABAL, "C9V_NOME" )

	EndIf

	If !Empty( cValor ) .and. AllTrim( cValor ) == "-"
		cValor := ""
	EndIf

Return( cValor )

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldDt
Funcao utilizada para fazer validacao de data e apresentar um help ao usuario

@param	cCmpModDe  - Campo de referencia para comparacao de data incial
		cCmpModAte - Campo de referencia para comparacao de data final

@return lRet - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Gustav G. Rueda
@since 14/08/2012
@version 1.0
/*/
//--------------------------------------------------------------------
Function XFUNVldDt ( cCmpModDe , cCmpModAte )

	Local lRet      := .T.
	Local cCampo    := ReadVar()
	Local cMensagem := ""
	Local dDtDe     := ""
	Local dDtAte    := ""

	If !cCmpModDe == Nil

		If Type(cCmpModDe) == "D" .Or. Type(cCmpModDe) == "U"

			dDtDe := FWFldGet( cCmpModDe )
			dDtAte := &(cCampo)

		Else

			If !Empty(FWFldGet(cCmpModDe))
				dDtDe := CTOD("01/" + Substr(FWFldGet(cCmpModDe),1,2) + "/" + Substr(FWFldGet(cCmpModDe),3,4))
			EndIf

			dDtAte := LastDate(CTOD("01/" + Substr(&(cCampo),1,2) + "/" + Substr(&(cCampo),3,4)))

		EndIf

	ElseIf !cCmpModAte == Nil

		If Type(cCmpModAte) == "D" .Or. Type(cCmpModAte) == "U"

			dDtDe := &(cCampo)
			dDtAte := FWFldGet( cCmpModAte )

		Else

			dDtDe := CTOD("01/" + Substr(&(cCampo),1,2) + "/" + Substr(&(cCampo),3,4))

			If !Empty(FWFldGet(cCmpModAte))
				dDtAte := LastDate(CTOD("01/" + Substr(FWFldGet(cCmpModAte),1,2) + "/" + Substr(FWFldGet(cCmpModAte),3,4)))
			EndIf

		EndIf

	EndIf

	If Type(cCampo) == "C" .and. !Empty(&(cCampo)) .and. ((Val(Substr(&(cCampo),1,2)) < 1) .Or. (Val(Substr(&(cCampo),1,2)) > 12))

		lRet		:=	.F.
		cMensagem	:=	Substr(&(cCampo),1,2)

		Help( ,,"TAFDATADE",,cMensagem, 5, 0 )

	ElseIf Type( cCampo ) == "D" .and. !Empty( AllTrim( &(cCampo) ) ) .and. ( ( Month( &( cCampo ) ) < 1 ) .Or. ( Month( &( cCampo ) ) > 12 ) )

		lRet		:=	.F.
		cMensagem	:=	AllTrim( Str( Month( &( cCampo ) ) ) )

		Help( ,,"TAFDATADE",,cMensagem, 5, 0 )

	ElseIf !cCmpModDe == Nil .And. cCmpModAte == Nil

		If !Empty(dDtDe) .And. !Empty(dDtAte) .and. dDtAte < dDtDe

			lRet		:=	.F.
			cMensagem	:=	StrZero( Day( dDtDe ) , 2)+"/"
			cMensagem	+=	StrZero( Month( dDtDe ) , 2)+"/"
			cMensagem	+=	StrZero( Year( dDtDe ) , 4)

			Help( ,,"TAFDATADE",,cMensagem, 5, 0 )

		EndIf

	ElseIf !cCmpModAte == Nil .And. cCmpModDe == Nil

		If !Empty(dDtAte) .And. !Empty(dDtDe) .and. dDtDe > dDtAte

			lRet		:=	.F.
			cMensagem	:=	StrZero( Day( dDtAte ) , 2)+"/"
			cMensagem	+=	StrZero( Month( dDtAte ) , 2)+"/"
			cMensagem	+=	StrZero( Year( dDtAte ) , 4)

			Help( ,,"TAFDATAATE",,cMensagem, 5, 0 )

		EndIf

	ElseIf !cCmpModDe == Nil .And. !cCmpModAte == Nil

		If ( !Empty(dDtDe) .And. dDtAte < dDtDe ) .Or.  ;
				( !Empty(dDtAte) .And. dDtDe > dDtAte )

			lRet		:=	.F.
			cMensagem	:=	StrZero( Day( dDtDe ) , 2)+"/"
			cMensagem	+=	StrZero( Month( dDtDe ) , 2)+"/"
			cMensagem	+=	StrZero( Year( dDtDe ) , 4)
			cMensagem	+=	" a "
			cMensagem	+=	StrZero( Day( dDtAte ) , 2)+"/"
			cMensagem	+=	StrZero( Month( dDtAte ) , 2)+"/"
			cMensagem	+=	StrZero( Year( dDtAte ) , 4)

			Help( ,,"TAFDATAENTRE",,cMensagem, 1, 0 )

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNChgF3
Funcao utilizada para trocar a consulta F3 em momento de execucao dependendo
do tributo informado

@param cCampoCond  	- Nomde do campo do tributo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCampoCond )
							Default eh o as 3 primeiras posicoes do campo que esta sendo editado mais a string "_CODTRI". Ex: C35_CODTRI
		cModel			- Id do modelo para passar na funcao GetValue( cModel , cCampoCond )
							Default eh a string "MODEL_" mais as 3 primeiras posicoes do campo que esta sendo editado. Ex: MODEL_C35
		cFlag      	- Flag para indicar qual controle de alteração da consulta F3 serah validado.
							"T" eh para Tributos
							"EAG" eh para consulta de Energia Eletrica, Agua e Gas
		cIdTrib     - Id do tributo para o retorno da tabela F3, caso não seja passado pega o conteúdo desse campo na Model.

@return cF3 - Retorna o nome da consulta F3 a ser utilizada

@author Gustavo G. Rueda
@since 11/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNChgF3( cCampoCond , cModel , cFlag, cIdTrib )

	Local oModel       := FWModelActive()
	Local cF3          := ''
	Local cCampoM      := ReadVar()
	Local cGet         := ""
	Local cNatInfo     := ""

	Default cCampoCond := SubStr( cCampoM , 4 , 3 ) + "_CODTRI"
	Default cModel     := "MODEL_" + SubStr( cCampoM , 4 , 3 )
	Default cFlag      := "TRI"
	Default cIdTrib    := ''

	cGet	:=	iif(!empty(cIdTrib), cIdTrib, oModel:GetValue( cModel , cCampoCond ))

	//Tratamento para o CST conforme tTributo selecionado
	If cFlag == "TRI"

		//ISSQN
		If cGet $ '000001/000016'

			cF3 	:= 'C0H'

		//ICMS e ICMS/ST
		ElseIf cGet $ '000002/000003/000004/000017/000026'

			cF3 := 'C14'

		//IPI
		ElseIf cGet $ '000005'

			cF3 := 'C15'

		//PIS/Pasep
		ElseIf cGet $ '000006/000008/000010/000014'

			cF3 := 'C17'

		//Cofins
		ElseIf cGet $ '000007/000009/000011/000015'

			cF3 := 'C17'

		Else
			msgalert("Para esse tipo de Tributo, não há opções disponíveis. Os tipos de Tributos que contém CST são os códigos: 01 à 11; e 14 à 17.",STR0008)
		EndIf

	//Tratamento para consulta da Classe de Consumo de Energia Eletrica/Agua/Gas conforme modelo do documento fiscal selecionado
	ElseIf cFlag == "EAG"

		//NOTA FISCAL/CONTA DE ENERGIA ELETRICA OU NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS CANALIZADO
		If cGet $ '000004/000025/000041'	//'06/28/66'

			cF3 := 'C0L'

		//NOTA FISCAL/CONTA DE FORNECIMENTO DE AGUA CANALIZADA
		ElseIf cGet $ '000026'	//'29'

			cF3 := 'C0O'

		Else
			msgalert("Para esse tipo de Tributo, não há opções disponíveis.",STR0008)
		EndIf

	//Tratamento para consulta da Modalidade de determinacao da base de calculo do ICMS e/ou ICMS/ST conforme tributo do documento fiscal selecionado
	ElseIf cFlag == "MBC"

		//ICMS
		If cGet $ '000002/000003/000017'

			cF3 := 'C04'

		//ICMS/ST
		ElseIf cGet $ '000004/000026'

			cF3 := 'C05'

		Else
			msgalert("Para esse tipo de Tributo, não há opções disponíveis. Os tipos de Tributos que contém Mod. BC são os códigos	: 02 à 04; e 17.",STR0008)
		EndIf

	ElseIf cFlag == "NAT"

		cNatInfo := FWFLDGET(cCampoCond)

		If !Empty(cNatInfo)
			//S-4000 - T1R
			If cNatInfo $ ("1|2|")
				cF3 := 'T1R'
			ElseIf cNatInfo == "3"
				//S-1299 - CUO
				cF3 := 'CUO'
			EndIf
		EndIf
	EndIf

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldMem
Funcao generica de validacao do conteudo do campo em memoria diante de uma condicao. Apresenta Help padrao.

@param  cFlag 	- 	Flag para tratamento especifico de validacao. Default de cFlag eh "CST"
		 cCmpModel	- 	Campo do model para tratamento da validacao baseado em outra informacao.
		 				Este campo serah chamado atraves do FWFLDGET. Default de cCmpModel eh o Alias da tabela + "_CODTRI", ex: C35_CODTRI
@return lOk 		- 	Estrutura
						.T. Para validacao OK
						.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldMem( cFlag , cCmpModel , nIndice , cString , lInteg,  cAliasMot )

	Local cCmpM       := ReadVar()
	Local cCmp        := SubStr( cCmpM , 4 )
	Local lOk         := .T.
	Local xRet        := .T.
	Local cCampo      := &cCmpM
	Local cAlias      := ""

	Default cFlag     := "CST"
	Default cCmpModel := SubStr( cCmp , 1 , 3 ) + "_CODTRI"
	Default nIndice   := Nil
	Default cString   := ''
	Default lInteg    := .F. // Define se a rotina esta sendo chamada via motor/Tafainteg de integração

	If !lTsi //Para integracoes via tsi, nao deve entrar nessa regra

		If cCmp == "C2E_CODCON" .Or. ( cFlag =="C2E_CODCON" .And. lInteg == .T. )

			If lInteg

				If !Empty( cString )

					If C20->C20_CODMOD $ '000004/000025' //"06/28/"
						cAlias	:=	"C0L"
					Elseif	C20->C20_CODMOD $ '000026' //"29"
						cAlias := "C0O"
					EndIf

					xRet := Iif(!Empty(cAlias),XFUNCh2ID( cString, cAlias, 1,,.T.),"")

				Else
					xRet := ""
				EndIf

			Else

				If !Empty( cCampo ) .And. !FWFLDGET( "C20_CODMOD" ) $ '000004/000025/000026/000041'	//"06/28/29"
					
					cMensagem	:=	"O Código da Classe de Consumo informado somente é válido para documentos fiscais com môdelo de emissão 06, 28 ou 29. Caso contrário, deixar em branco."
					lOk	:=	.F.

				ElseIf !Empty( cCampo ) .And. FWFLDGET( "C20_CODMOD" ) $ '000004/000025/000041'	//"06/28/66"
					
					cAlias	:=	"C0L"

				ElseIf !Empty( cCampo ) .And. FWFLDGET( "C20_CODMOD" ) $ '000026'	//"29"
					
					cAlias	:=	"C0O"

				EndIf

			EndIf

		Else

			If cFlag == "CST"

				//Rodrigo
				//Caso seja integracao via motor
				If lInteg

					If !Empty( cString ) .And. !Empty( cAliasMot )

						//ISSQN
						If (cAliasMot)->&(cAliasMot + "_CODTRI" ) $ "000001/000016"
							
							cAlias	:=	"C0H"

						//ICMS e ICMS/ST
						ElseIf (cAliasMot)->&(cAliasMot + "_CODTRI" ) $ "000002/000003/000004/000017/000026"
							
							cAlias	:=	"C14"

						//IPI
						ElseIf (cAliasMot)->&(cAliasMot + "_CODTRI" ) $ "000005"
							
							cAlias	:=	"C15"

						//PIS/Pasep/Cofins
						ElseIf (cAliasMot)->&(cAliasMot + "_CODTRI" ) $ "000006/000008/000010/000014/000007/000009/000011/000015"
							
							cAlias	:=	"C17"

						EndIf

						xRet := Iif(!Empty(cAlias),XFUNCh2ID( cString, cAlias, 1,,.T.),"")

					Else
						xRet := ""
					EndIf

				Else

					//Tratamento para utilizar o cString quando for passado, pois neste caso o campo de TRIBUTO nao existe e devo utilizar esta variavel para vincular o mesmo
					cString	:=	Iif( Empty( cString ) , FWFLDGET( cCmpModel ) , cString )

					//Tratamento para apresentar help para os tributos que nao precisam do CST
					If !Empty( cCampo ) .And. !cString $ "000001/000002/000003/000004/000005/000006/000007/000008/000009/000010/000011/000014/000015/000016/000017/000026"
						
						cMensagem	:=	"O Código de Situação Tributária (CST) somente é necessária para os tributos ICMS, IPI, ISS, PIS/Pasep e/ou Cofins. Se não for o caso, deixá-lo em branco."
						lOk	:=	.F.

					//ISSQN
					ElseIf !Empty( cCampo ) .And. cString $ "000001/000016"
						
						cAlias	:=	"C0H"

					//ICMS e ICMS/ST
					ElseIf !Empty( cCampo ) .And. cString $ "000002/000003/000004/000017/000026"
						
						cAlias	:=	"C14"

					//IPI
					ElseIf !Empty( cCampo ) .And. cString $ "000005"
						
						cAlias	:=	"C15"

					//PIS/Pasep/Cofins
					ElseIf !Empty( cCampo ) .And. cString $ "000006/000008/000010/000014/000007/000009/000011/000015"
						
						cAlias	:=	"C17"

					EndIf

				EndIf

			ElseIf cFlag == "MODBC"

				// --------------------------------------------------------------
				// Demetrio  - 20/08/2014
				// Se a rotina chamada via integração - TAFAINTEG
				If lInteg
					If !Empty(cString)

						cAlias := ""

						// ICMS
						If C35->C35_CODTRI $ "000002/000003/000017"
							cAlias	:=	"C04"

							// ICMS - ST
						ElseIf C35->C35_CODTRI $ "000004/000026"
							cAlias	:=	"C05"
						EndIf

						// Chama Ch2Id apenas para ICMS/ICMS-ST, caso contrario retorna vazio " "
						// MODBC apenas para os impostos acima.
						xRet := Iif(!Empty(cAlias),XFUNCh2ID( cString, cAlias, 1,,.T.),"")
					Else
						xRet := ""
					EndIf

				Else
					//Tratamento para apresentar help para os tributos que nao precisam do MODBC
					If !Empty( cCampo ) .And. !FWFLDGET( cCmpModel ) $ "000002/000003/000004/000017/000026"
						cMensagem	:=	"A Modalidade de determinação da Base de Calculo somente é necessária para o ICMS. Se não for o caso, deixar em branco."
						lOk	:=	.F.

						//ICMS
					ElseIf !Empty( cCampo ) .And. FWFLDGET( cCmpModel ) $ "000002/000003/000017"
						cAlias	:=	"C04"

						//ICMS/ST
					ElseIf !Empty( cCampo ) .And. FWFLDGET( cCmpModel ) $ "000004/000026"
						cAlias	:=	"C05"

					EndIf

				EndIf

			ElseIf cFlag == 'CPRB'

				//Ricardo - Inicio
				If lInteg

					If !Empty(cString)

						cAlias := ""

						// ISSQN - CPRB
						If C35->C35_CODTRI $ "000020"
							cAlias	:=	"C3S"
						EndIf
						// CPRB apenas para o imposto acima ISSQN.
						xRet := Iif(!Empty(cAlias),XFUNCh2ID( cString, cAlias, 1,,.T.),"")

					Else
						xRet := ""
					EndIf

				Else

					//Tratamento para apresentar help para os tributos que nao precisam do CPRB
					If !Empty( cCampo ) .And. !FWFLDGET( cCmpModel ) $ "000020"
						cMensagem	:=	"Este campo somente é preenchido para o tributo ISSQN - CPRB. Se não for o caso, deixar em branco."
						lOk	:=	.F.
					EndIf

				EndIf

				//Ricardo - Fim
			EndIf

		EndIf

		// --------------------------------------------------------------
		// Apenas para quando não for integração via TAFAINTEG.

		If !lInteg

			//Verifico se apresento o help condicional a validacao
			If !lOk
				xRet	:=	.F.
				Help( ,,"TAFCONTINVALID",, CRLF+cMensagem , 5, 0 )

			Else
				//Se a condicao for valida, a seguencia de validacao eh o EXISTCPO para garantir a integradade do valor digitado
				xRet	:=	Iif( Empty( cAlias ) , xRet , xRet .And. XFUNVldCmp( cAlias , nIndice) )
			EndIf

		EndIf

	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldCod
Funcao utilizada para fazer validacao de Codigo e apresentar um help ao usuario

@param	cCmpModDe  - Campo de referencia para comparacao de Codigo Inicial
		cCmpModAte - Campo de referencia para comparacao de Codigo Final

@return lRet - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldCod( cCmpModDe , cCmpModAte)

	Local	lRet		:=	.T.
	Local	cCampo		:=	ReadVar()
	Local	cMensagem	:=	""

	If !cCmpModDe == Nil .And. !cCmpModAte == Nil

		If ( !Empty(FWFldGet( cCmpModDe )) .And. &( cCampo ) < FWFldGet( cCmpModDe  ) )

			lRet		:=	.F.
			cMensagem	:=	FWFldGet( cCmpModDe )
			Help( ,,"TAFCODMAIOR",,cMensagem, 1, 0 )

		ElseIf ( !Empty(FWFldGet( cCmpModAte)) .And. &( cCampo ) > FWFldGet( cCmpModAte ) )

			lRet		:=	.F.
			cMensagem	:=	FWFldGet( cCmpModAte )
			Help( ,,"TAFCODMENOR",,cMensagem, 1, 0 )

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldVal
Funcao utilizada para validar conteudos negativos de campos numericos
  e tambem efetuar a comparacao entre o valor informado e o calculado.

@param	nDec - Quantidade de decimais a ser tratado no arredondamento

@return lRet - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Fabio V. Santana
@since 30/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldVal( nDec )

	Local	lRet		:=	.T.
	Local	cCampoM	:=	ReadVar()
	Local	cCampo		:=	SubStr( cCampoM , 4 )
	Local	nValor		:=	0
	Local	nVlrCmp	:=	0
	Local	nMVTAFRND	:=	GetNewPar( "MV_TAFRND" , '1' )
	Local	lMVVLDTOT	:=	GetNewPar( "MV_VLDTOT" , .T. )
	Local	lProc		:=	.T.

	Default	nDec	:=	2

	//Parametro que permite a validacao de campos totalizadores dos modelos.
	If lMVVLDTOT
		Do Case

		Case cCampo + "|" $ "C20_VLDOC|"
			nValor	:=	( FWFLDGET( "C20_VLMERC" ) + FWFLDGET( "C20_VLSERV" ) ) - ( FWFLDGET( "C20_VLDESC" ) + FWFLDGET( "C20_VLABNT" ) ) + FWFLDGET( "C20_VLRFRT" ) + FWFLDGET( "C20_VLRSEG" ) + FWFLDGET( "C20_VLRDA" ) + FWFLDGET( "C20_VLOUDE" )
		Case cCampo + "|" $ "C30_TOTAL|"
			//Quando a Nota for de Complemento de ICMS, IPI ou Frete o valor dos itens não devem ser multiplicados
			// pela quantidade, pois ela deverá estar zerada nesses casos.
			If TafNfCompl()
				nValor	:=	 FWFLDGET( "C30_VLRITE" )  - FWFLDGET( "C30_VLDESC" )
			else
				nValor	:=	( FWFLDGET( "C30_QUANT" ) * FWFLDGET( "C30_VLRITE" ) ) - FWFLDGET( "C30_VLDESC" )
			endif
		Case cCampo + "|" $ "C5I_VLRETE|"
			nValor	:= FWFLDGET("C5I_RETPIS")+FWFLDGET("C5I_RETCOF")

		Case cCampo + "|" $ "C46_VCAPUR|"
			nValor	:= FWFLDGET("C46_VBCPC")* FWFLDGET("C46_ALQPC")/100+(FWFLDGET("C46_QBCPPC")*FWFLDGET("C46_ALQVPC"))

		Case cCampo + "|" $ "C46_VTCPER|"
			nValor	:= FWFLDGET("C46_VCAPUR")+FWFLDGET("C46_VAJACR")-FWFLDGET("C46_VAJRED")-FWFLDGET("C46_VATDIF")+FWFLDGET("C46_VANDIF")
		Case cCampo + "|" $ "C4E_VCONAN|"
			nValor	:= FWFLDGET("C4E_VCONTR")-FWFLDGET("C4E_VCRDDI")

		Case cCampo + "|" $ "C4L_BCCRED|"
			nValor	:= FWFLDGET("C4L_VLAQBM")-FWFLDGET("C4L_PAVAQS")

		Case cCampo + "|" $ "C40_PERREC|"
			nValor	:= ( FWFLDGET( "C40_VRECAC" )+FWFLDGET( "C40_VTOTRE" ) ) / FWFLDGET( "C40_VTOTVE" )

		Case cCampo + "|" $ "C44_BCINC|"
			nValor	:= FWFLDGET("C44_INCACU")+FWFLDGET("C44_EXCBC")

		Case cCampo + "|" $ "C44_INCACU|"
			nValor	:= FWFLDGET("C44_INCANT")+FWFLDGET("C44_INCESC")

		Case cCampo + "|" $ "C44_CRDFUP|"
			nValor	:= FWFLDGET("C44_CRDACP")-FWFLDGET("C44_CRDANP")-FWFLDGET("C44_CRDDEP")

		Case cCampo + "|" $ "C44_CRDFUC|"
			nValor	:=  FWFLDGET("C44_CRDACC")-FWFLDGET("C44_CRDANC")-FWFLDGET("C44_CRDDEC")

		Case cCampo + "|" $ "C45_CUSAJU|"
			nValor	:=  FWFLDGET("C45_CUSORC")-FWFLDGET("C45_VEXC")

		Case cCampo + "|" $ "C50_SDCRFI|"
			nValor	:=  FWFLDGET("C50_SLDCRD")+FWFLDGET("C50_CRDAPR")+FWFLDGET("C50_CRDREC")-FWFLDGET("C50_CRDUTI")

		Case cCampo + "|" $ "C5E_VTOTBC|"
			nValor	:=   FWFLDGET("C5E_TOTFOL")-FWFLDGET("C5E_TOEXBC")

		Case cCampo + "|" $ "C4I_VLBPIS|"
			nValor	:=   FWFLDGET("C4I_VLENDE")-FWFLDGET("C4I_PAVLEN")

		Case cCampo + "|" $ "C4I_VLBCOF|"
			nValor	:=   FWFLDGET("C4I_VLENDE")-FWFLDGET("C4I_PAVLEN")

		Case cCampo + "|" $ "C5J_VLEXPG|"
			nValor	:=   FWFLDGET("C5J_VLEXDV")-FWFLDGET("C5J_VLOUTD")

		Case cCampo + "|" $ "C5J_VLEXDV|"
			nValor	:=   FWFLDGET("C5J_VLCTAP")-FWFLDGET("C5J_VLCRPC")

		Case cCampo + "|" $ "C5M_BASE|"
			nValor	:=   FWFLDGET("C5M_VATIV")-FWFLDGET("C5M_VEXC")

		Case cCampo + "|" $ "C6M_VBCEST|"
			nValor	:=   FWFLDGET("C6M_TOTEST")-FWFLDGET("C6M_ESTIMP")

		Case cCampo + "|" $ "C6M_VBCMES|"
			nValor  := FWFLDGET("C6M_VBCEST")/12


		Case cCampo + "|" $ "C2N_VSCRED|"
			nValor	:= 	(FWFLDGET("C2N_VSDANT")+FWFLDGET("C2N_VCRED")+FWFLDGET("C2N_VOCRED"))-(FWFLDGET("C2N_VDEB")+FWFLDGET("C2N_VODEB"))
			nValor	:=	Iif( nValor < 0 , nValor * -1 , nValor )

		Case cCampo + "|" $ "C2N_VSDEV|"
			nValor	:= 	(FWFLDGET("C2N_VSDANT")+FWFLDGET("C2N_VCRED")+FWFLDGET("C2N_VOCRED"))-(FWFLDGET("C2N_VDEB")+FWFLDGET("C2N_VODEB"))
			nValor	:=	Iif( nValor < 0 , nValor * -1 , nValor )

		Case cCampo + "|" $ "C2S_SDOAPU|"
			nValor	:=   (FWFLDGET("C2S_TOTDEB")+FWFLDGET("C2S_AJUDEB")+FWFLDGET("C2S_TAJUDB")+FWFLDGET("C2S_ESTCRE"))-(FWFLDGET("C2S_TOTCRE")+FWFLDGET("C2S_AJUCRE")+FWFLDGET("C2S_TAJUCR")+FWFLDGET("C2S_ESTDEB")+FWFLDGET("C2S_CREANT"))

		Case cCampo + "|" $ "C2S_CRESEG|"
			nValor	:=   (FWFLDGET("C2S_TOTCRE")+FWFLDGET("C2S_AJUCRE")+FWFLDGET("C2S_TAJUCR")+FWFLDGET("C2S_ESTDEB")+FWFLDGET("C2S_CREANT"))-(FWFLDGET("C2S_TOTDEB")+FWFLDGET("C2S_AJUDEB")+FWFLDGET("C2S_TAJUDB")+FWFLDGET("C2S_ESTCRE"))

		Case cCampo + "|" $ "C5T_VLRPAU|"
			nValor	:=   FWFLDGET("C5T_BASEQT")*FWFLDGET("C5T_ALIQQT")

		Case cCampo + "|" $ "C4R_VLICAP|"
			nValor	:=   FWFLDGET("C4R_SOMPAR")*FWFLDGET("C4R_INDPVL")

		Case cCampo + "|" $ "C4R_INDPVL|"
			nValor	:=   FWFLDGET("C4R_VLTREX") / FWFLDGET("C4R_VLTOTS")

		Case cCampo + "|" $ "C4T_IDPTVL|"
			nValor	:=   FWFLDGET("C4T_VLSTRB") / FWFLDGET("C4T_VLTOT")

		Case cCampo + "|" $ "C5H_VLFATU|"
			nValor	:=   FWFLDGET("C5H_VCARGA")+FWFLDGET("C5H_VLPASS")

		Case cCampo + "|" $ "C5H_INDRAT|"
			nValor	:=   FWFLDGET("C5H_VCARGA")/FWFLDGET("C5H_VLFATU")

		Case cCampo + "|" $ "C5H_VICMAP|"
			nValor	:=   FWFLDGET("C5H_INDRAT")*FWFLDGET("C5H_VICANT")

		Case cCampo + "|" $ "C5H_VBICAP|"
			nValor	:=   FWFLDGET("C5H_INDRAT")*FWFLDGET("C5H_VBCICM")

		Case cCampo + "|" $ "C5H_VDIFER|"
			nValor	:=   FWFLDGET("C5H_VICANT")-FWFLDGET("C5H_VICMAP")

		Case cCampo + "|" $ "C5B_VITEM|"
			nValor	:=   FWFLDGET("C5B_QTD")*FWFLDGET("C5B_VUNIT")

			//REQ103

		Case cCampo + "|" $ "C3B_VPIS|"
			nValor	:=   FWFLDGET("C3B_VBCPIS")*FWFLDGET("C3B_ALQPIS")/100

		Case cCampo + "|" $ "C3B_VCOF|"
			nValor	:=   FWFLDGET("C3B_VBCCOF")*FWFLDGET("C3B_ALQCOF")/100

		Case cCampo + "|" $ "C4L_VLPIS|"
			nValor	:=   FWFLDGET("C4L_VLBPIS")*FWFLDGET("C4L_ALQPIS") /100

		Case cCampo + "|" $ "C4L_VLRCOF|"
			nValor	:=   FWFLDGET("C4L_VLBCOF")*FWFLDGET("C4L_ALQCOF") / 100

		Case cCampo + "|" $ "C40_VPIS|"
			nValor	:=   FWFLDGET("C40_VBCPIS")*FWFLDGET("C40_ALQPIS")/100

		Case cCampo + "|" $ "C40_VCOFIN|"
			nValor	:=   FWFLDGET("C40_VBCCOF")*FWFLDGET("C40_ALQCOF")/100

		Case cCampo + "|" $ "C44_CRDACP|"
			nValor	:=   FWFLDGET("C44_BCINC")*FWFLDGET("C44_ALQPIS")/100

		Case cCampo + "|" $ "C44_CRDACC|"
			nValor	:=   FWFLDGET("C44_BCINC")*FWFLDGET("C44_ALQCOF")/100

		Case cCampo + "|" $ "C45_CRDPIS|"
			nValor	:=   FWFLDGET("C45_BCCRED")*FWFLDGET("C45_ALQPIS")/100

		Case cCampo + "|" $ "C45_CRDCOF|"
			nValor	:=   FWFLDGET("C45_BCCRED")*FWFLDGET("C45_ALQCOF")/100

		Case cCampo + "|" $ "C5E_VCOFOL|"
			nValor	:=   FWFLDGET("C5E_VTOTBC")*FWFLDGET("C5E_ALQPIS")/100

		Case cCampo + "|" $ "C53_VREC|"
			nValor	:=   FWFLDGET("C53_BCRET")*FWFLDGET("C53_ALQRET")/100

		Case cCampo + "|" $ "C4I_VLPIS|"
			nValor	:=   FWFLDGET("C4I_VLBPIS")*FWFLDGET("C4I_ALQPIS")/100

		Case cCampo + "|" $ "C4I_VLRCOF|"
			nValor	:=   FWFLDGET("C4I_VLBCOF")*FWFLDGET("C4I_ALQCOF")/100

		Case cCampo + "|" $ "C5M_VCON|"
			nValor	:=   FWFLDGET("C5M_BASE")*FWFLDGET("C5M_ALQCON")/100

		Case cCampo + "|" $ "C6M_CRDPIS|"
			nValor	:=   FWFLDGET("C6M_VBCMES")*FWFLDGET("C6M_ALQPIS")/100

		Case cCampo + "|" $ "C6M_CRDCOF|"
			nValor	:=   FWFLDGET("C6M_VBCMES")*FWFLDGET("C6M_ALQCOF")/100

		Case cCampo + "|" $ "C5T_VALOR|"
			nValor	:=   FWFLDGET("C5T_BASE")*FWFLDGET("C5T_ALIQ")/100

		Case cCampo + "|" $ "C2D_VLICM|"
			nValor	:=   FWFLDGET("C2D_BSICM")*FWFLDGET("C2D_ALQICM")/100

		Case cCampo + "|" $ "C35_VALOR|"
			nValor	:=   FWFLDGET("C35_BASE")*FWFLDGET("C35_ALIQ")/100

		Case cCampo + "|" $ "C35_VLRPAU|"
			nValor	:=   FWFLDGET("C35_BASEQT")*FWFLDGET("C35_ALIQQT")/100

		Case cCampo + "|" $ "C3J_SDODEV|"
			nValor	:=   ( FWFLDGET( "C3J_VLRRET" ) + FWFLDGET( "C3J_OUTDEB" ) + FWFLDGET( "C3J_AJUDEB" ) ) - ( FWFLDGET( "C3J_CREANT" ) + FWFLDGET( "C3J_VLRDEV" ) + FWFLDGET( "C3J_VLRRES" ) + FWFLDGET( "C3J_OUTCRD" ) + FWFLDGET( "C3J_AJUCRD" ) )
			If nValor < 0	//Se o retorno do calculo for <0 indica que se tem credito e nao debito. Portanto este campo deve ser ZERADO
				nValor	:=	0
			EndIf

		Case cCampo + "|" $ "C3J_VLRREC|"
			nValor	:=   Iif( FWFLDGET( "C3J_SDODEV" ) - FWFLDGET( "C3J_TOTDED" ) > 0 , FWFLDGET( "C3J_SDODEV" ) - FWFLDGET( "C3J_TOTDED" ) , 0 )

		Case cCampo + "|" $ "C3J_CRDTRA|"
			nValor	:=   ( FWFLDGET( "C3J_VLRRET" ) + FWFLDGET( "C3J_OUTDEB" ) + FWFLDGET( "C3J_AJUDEB" ) ) - ( FWFLDGET( "C3J_CREANT" ) + FWFLDGET( "C3J_VLRDEV" ) + FWFLDGET( "C3J_VLRRES" ) + FWFLDGET( "C3J_OUTCRD" ) + FWFLDGET( "C3J_AJUCRD" ) )
			nValor	:=   ( nValor * -1 ) + IIF( FWFLDGET( "C3J_SDODEV" ) - FWFLDGET( "C3J_TOTDED" ) < 0 , (FWFLDGET( "C3J_SDODEV" ) - FWFLDGET( "C3J_TOTDED" ) ) * -1 , 0 )

		OtherWise
			lProc	:=	.F.

		EndCase

		//Tratamento para efetuar o calculo somente caso encontre o campo na relacao acima
		If lProc

			//Parametro que trata o tipo de arredondamento desejado, ARREDONDANDO (1) ou TRUNCANDO(2)
			If nMVTAFRND == '1'
				nValor		:=	Round( nValor , nDec )
				nVlrCmp	:=	Round( &( cCampoM ) , nDec )
			Else
				nValor		:=	NoRound( nValor , nDec )
				nVlrCmp	:=	NoRound( &( cCampoM ) , nDec )
			EndIf

			//condica de validacao: Valor informado deve ser igual ao calculado e nao pode ser negativo
			If ( nVlrCmp <> nValor .Or. nValor < 0 ) .And. !TafNfCompl()
				lRet :=	.F.
				Help( ,,AllTrim( cCampo ),,, 1, 0 )
			EndIf

		EndIf

	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNPer
Funcao utilizada para validar conteudos de campos de periodos.

@param	cCampo  - Campo a ser validado

@return lRet - Estrutura
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Fabio V. Santana
@since 30/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNPer()

	Local	lRet		:=	.T.
	Local	cCampo		:=	ReadVar()
	Local	cMensagem	:=	""
	Local	cMes        := SubStr(&cCampo,1,2)
	Local	cAno        := SubStr(&cCampo,3,4)
	Local	cTafPer     := GetNewPar( "MV_TAFPER" , "012000" )

	If !cCampo == Nil

		If Val(cMes) > 12 .Or. Val(cMes) == 00

			lRet		:=	.F.
			cMensagem 	:= 	SubStr( cTafPer , 1 , 2) + '/' + SubStr( cTafPer , 3 , 4)
			Help( ,,"TAFPERIODO",,cMensagem, 5, 0 )

		ElseIf Val(cAno) < Val(SubStr(cTafPer,3,4))

			lRet		:=	.F.
			cMensagem 	:= 	SubStr( cTafPer , 1 , 2) + '/' + SubStr( cTafPer , 3 , 4)
			Help( ,,"TAFPERIODO",,cMensagem, 5, 0 )

		ElseIf Val(&cCampo) < Val(cTafPer)

			lRet		:=	.F.
			cMensagem 	:= 	SubStr( cTafPer , 1 , 2) + '/' + SubStr( cTafPer , 3 , 4)
			Help( ,,"TAFPERIODO",,cMensagem, 5, 0 )

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNMNot
Retorna o modelo da nota fiscal de acordo com o Convenio 31/99.

@param cEspecie  - Especie da nota Fiscal

@return cCodigo - Codigo da especie nota fiscal

@author Fabio V. Santana
@since 18/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNMNot(cID)

	Local cEspecie:= "NF" // Default Nota Fiscal ou Nota Fiscal Fatura
	Local cChave	:= 	''

	Default cID := ""

	cChave:= xFilial("C01") + cID

	C01->(dbSetOrder(3))
	If C01->(MsSeek(cChave))
		cEspecie := C01->C01_CODIGO
	EndIf

/*
	Do Case
	Case Alltrim(cCodigo)=="000002"
		cEspecie:="NFCF" // NF de venda a Consumidor Final
	Case Alltrim(cCodigo)=="000003"
		cEspecie:="NFP" // NF de Produtor
	Case Alltrim(cCodigo)=="000004"
		cEspecie:="NFCEE" // Conta de Energia Eletrica
	Case Alltrim(cCodigo)=="000005"
		cEspecie:="NFST" // NF Servico de Transporte
	Case Alltrim(cCodigo)=="000006"
		cEspecie:="CTR" // Conh.Transp.Rodoviario
	Case Alltrim(cCodigo)=="000007"
		cEspecie:="CTA" // Conh.Transp.Aquaviario
	Case Alltrim(cCodigo)=="000008"
		cEspecie:="CA" // Conh.Aereo
	Case Alltrim(cCodigo)=="000009"
		cEspecie:="CTF" // Conh.Transp.Ferroviario
	Case Alltrim(cCodigo)=="000014"
		cEspecie:="RMD" // Resumo Movimento Diario
	Case Alltrim(cCodigo)=="000015"
		cEspecie:="NFA" // Nota Fiscal Avulsa
	Case Alltrim(cCodigo)=="000016"
		cEspecie:="NFSC" // NF Servico de Comunicacao
	Case Alltrim(cCodigo)=="000017"
		cEspecie:="NTST" // NF Servico de Telecomunicacoes
	Case Alltrim(cCodigo)=="000018"
		cEspecie:="CTM" // Conh.Transp.Multimodal
	Case Alltrim(cCodigo)=="000020"
		cEspecie:="NFCFG" // Nota fiscal/conta de fornecimento de gas
	Case Alltrim(cCodigo)=="000021"
		cEspecie:="NFFA" // Nota fiscal de fornecimento de agua
	Case Alltrim(cCodigo)=="000022"
		cEspecie:="CF" // Cupon Fiscal
	Case Alltrim(cCodigo)=="000024"
		cEspecie:="SPED" // Nota fiscal eletronica do SEFAZ.
	Case Alltrim(cCodigo)=="000025"
		cEspecie:="CTE" // Conhecimento de Transporte Eletronico
	Case Alltrim(cCodigo)=="000026"
		cEspecie:="CFE" // Cupon Fiscal
	EndCase
*/

Return (cEspecie)
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNUFID
Retorna o ID da UF passada por parametro, ou do MV_TAFUF como DEFAULT

@return cUF - Codigo da UF

@author Danilo L Zanaga
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNUFID( cUF )

	Local cID 		:= ''
	Local cChave	:= 	''

	Default	cUF 	:= GetNewPar( "MV_TAFUF" , SM0->M0_ESTCOB )

	cChave:= xFilial("C09") + cUf

	C09->(dbSetOrder(1))
	If C09->(MsSeek(cChave))
		cID := C09->C09_ID
	EndIf

Return cID
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNCodUF
Retorna a UF mediante o codigo da propria uf. Ex: Transforma 35 em SP.

@return cCodUF - Codigo da UF

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNCodUF( cCodUF )

	Local cRet 		:= 	''

	Default	cCodUF 	:= ''

	C09->( dbSetOrder( 4 ) )
	If C09->( MsSeek( xFilial( "C09" ) + cCodUF ) )
		cRet := C09->C09_UF
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNMEtod
Valida se o código de registro da ECF corresponde ao método utilizado.

@return cCdRegECF - Codigo de Registro da ECF

@author Jose Felipe
@since 27/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNMEtod(cCdReg)

	Local cRetorno	:= ""
	
	Do Case
	Case cCdReg == "PRL"
		cRetorno := "Inf. Rel. ao Método PRL - Preço de Rev. Menos Lucro"
	Case cCdReg == "MCL"
		cRetorno := "Inf. Rel. ao Método MCL - Custo Mais Lucro"
	Case cCdReg == "MLT"
		cRetorno := "Inf. Rel. ao Método MLT - Marg.Líq. da Trans."
	Case cCdReg == "MDL"
		cRetorno := "Inf. Rel. ao Método MDL - Div. do Lucro"
	Case cCdReg == "PIC"
		cRetorno := "Inf. Rel. ao Método PIC - Preço Indep. Comp."
	Case cCdReg == "OUT"
		cRetorno := "Outro"
	End Case

Return ( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNMnuTAF
Funcao responsavel por retornar o MENU padrao das rotinas do TAF

@param 	cMenu   - Nome da Rotina
        lCopiar - Habilita rotina padrao de Copia
        aFuncao - Array com rotinas adicionais. Posicoes do Array:
                  1 - C - Titulo da Rotina (Caso nao esteja disponibilizado no TAFXFUN)
                  2 - C - Nome da Funcao a ser executada
                  3 - C - Titulo da rotina (Disponibilizado no TAFXFUN)
        lMenPadrao - Indica se deve caregar os botões padrões do Menu

@return	aRotina - Array com as opcoes de MENU

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNMnuTAF( cMenu as character, lCopiar as logical, aFuncao as array,;
					 lMenPadrao as logical, cRetific as character, cAlterac as character,;
					 cCancFim as character, lCallMenu as logical)

	Local aRotAlt    	as array
	Local aRotExcl   	as array
	Local aRotina    	as array
	Local aTafRot    	as array
	Local cAlias     	as character
	Local cEventos   	as character
	Local cFuncExc   	as character
	Local cNmFun     	as character
	Local lMnuExc    	as logical
	Local nCont      	as numeric
	Local nI         	as numeric
	Local nPos       	as numeric
	Local nPosAlt    	as numeric
	Local nPosDel    	as numeric
	Local nPosExc    	as numeric
	Local nPosInc    	as numeric
	Local nPosPrint  	as numeric
	Local nPosVisual 	as numeric
	Local nX         	as numeric

	Default aFuncao		:= {}
	Default cMenu		:= ""
	Default cRetific	:= ""
	Default cAlterac	:= ""
	Default cCancFim	:= ""
	Default lCopiar		:= .F.
	Default lMenPadrao	:= .T.
	Default lCallMenu	:= .T.

	aRotAlt    := {}
	aRotExcl   := {}
	aRotina    := {}
	aTafRot    := {}
	aTafRot    := {}
	cAlias     := ""
	cEventos   := "S-5001|S-5002|S-5011|S-5012|S-5003|S-5013|S-5501|"
	cFuncExc   := ""
	cNmFun     := IIF( FunName() == 'CFGA530', cMenu, FunName() )
	lMnuExc    := .T.
	nCont      := 8
	nI         := 0
	nPos       := 0
	nPosAlt    := 0
	nPosDel    := 0
	nPosExc    := 0
	nPosInc    := 0
	nPosPrint  := 0
	nPosVisual := 0
	nX         := 0

	If lMenPadrao
		aRotina := FwMVCMenu( cMenu )
	EndIf

	If !TafLayESoc()

		cEventos +=  "S-2190|"

	EndIf

	//Tratamento para que os cadastros de tabelas auto-contidas não tenham as opções de Alterar, Excluir e Incluir
	//no Menu
	FCadAutCon(cMenu, aRotina, lCallMenu)

	//tratamento para retirar a opcao de COPIAR, pois para habilizar, FRAME precisa disponibilizar um componente para informar quais campos
	//	devem vir em BRANCO, pois da forma que estah, virao todos preenchidos e ao confirmar serah gravado informacoes duplicadas, porque
	//	o ID eh diferente.
	If !lCopiar

		nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Copiar" } )

		If nPosDel > 0
			aDel( aRotina , nPosDel )
			aSize( aRotina , Len( aRotina ) - 1 )
		EndIf

	EndIf

	If lCallMenu

		aTafRot	:= IIf((cNmFun $ "TAFPNFUNC|TAFMONTES|CFGA530" .Or.; 
					(Empty(cNmFun) .And. !(cMenu $ "TAFA421|TAFA420"))),;
					TAFRotinas(cMenu, 1, .F., 2,, .T.),;
					TAFRotinas(cNmFun, 1, .F., 2,, .T.))

	EndIf
	
	//Cadastro do trabalhador
	If cNmFun == "TAFA421" .or. cNmFun == "TAFA420" //Verifico se o cadastro é referente as rotinas do trabalhador

		nPosInc 	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Incluir" } )      //Inclusão do Trabalhador
		nPosAlt 	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } ) 	  //Alteração do Trabalhador
		nPosVisual  := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )   //Visualização do Trabalhador
		nPosPrint	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Imprimir" } )     //Imprimir

		If nPosInc > 0 //Incluir
			aRotina[nPosInc][2] := IIF(cNmFun == "TAFA421","InclCadTrab()","IncCarInic()") //Trabalhador com ou Sem Vínculo
			nPosInc := 0
		EndIf

		If cNmFun <> "TAFA420"

			If nPosAlt > 0 //Alterar
				aRotina[nPosAlt][2] := "AltCadTrab()" //Trabalhador Com ou Sem Vínculo
				nPosAlt := 0
			EndIf

		Else

			If nPosPrint > 0 //Imprimir
				aRotina[nPosPrint][2] = "VIEWDEF.TAFA256"
			EndIf

		Endif

		If nPosPrint > 0 .AND. cNmFun == "TAFA421" //Imprimir
			aRotina[nPosPrint][2] = "VIEWDEF.TAFA256"
		EndIf

		If nPosVisual > 0 //Visualizar
			aRotina[nPosVisual][2] := "xCarrVisul" //Trabalhador - Carga Inicial
			nPosVisual := 0
		EndIf

	ElseIf cNmFun == "TAFA588"

		nPosInc 	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Incluir" } )     //Inclusão do Beneficiário
		nPosAlt 	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } ) 	 //Alteração do Beneficiário
		nPosVisual	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )  //Visualização do Beneficiário
		nPosPrint	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Imprimir" } )    //Imprimir

		nPosExc := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Excluir" } )

		If nPosInc > 0 //Incluir
			aRotina[nPosInc][2] := "TAF588Inc()"
			nPosInc := 0
		EndIf

		If nPosAlt > 0 //Alterar
			aRotina[nPosAlt][2] := "TAF588Alt()"
			nPosAlt := 0
		EndIf

		If nPosPrint > 0
			aRotina[nPosPrint][2] = "VIEWDEF.TAFA589"
		EndIf

		If nPosVisual > 0 //Visualizar
			aRotina[nPosVisual][2] := "TAF588Vis"
			nPosVisual := 0
		EndIf

		If nPosExc > 0 //Excluir

			aRotina[nPosExc][2] := ""
			nPosVisual := 0

			Aadd(aRotExcl,{STR0212					,"TAF588Del"     ,0, 1 } ) //"Excluir Registro"
			Aadd(aRotExcl,{STR0213					,"TAF588Del"     ,0, 2 } ) //"Desfazer Exclusão"
			Aadd(aRotExcl,{STR0214					,"TAF588Del"     ,0, 3 } ) //"Visualizar Registro de Exclusão"
			
			aRotina[nPosExc][2] := aRotExcl
			aRotExcl := {}

		EndIf

	ElseIf cNmFun == "TAFA403"
		
		nPosVisual	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )  

		If nPosVisual > 0 //Visualizar
			aRotina[nPosVisual][2] := "TAF403View('T3A',RECNO())"
			nPosVisual := 0
		EndIf

	ElseIf cNmFun == "TAFA473"

		nPosVisual	:= aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )  

		If nPosVisual > 0 //Visualizar
			aRotina[nPosVisual][2] := "TAF473View('C9V',RECNO())"
			nPosVisual := 0
		EndIf

	ElseIf Len(aTafRot) > 0

		If Findfunction("xTafAlt")

			nPosAlt := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } ) 		 //Alteração do Trabalhador

			If nPosAlt > 0 //Alterar
				cAlias      := aTafRot[3]
				aRotina[nPosAlt][2] := "xTafAlt('" + cAlias + "', 0 , 0)" //Trabalhador - Carga Inicial				
			EndIf

			nPosAlt := 0

		EndIf

	EndIf

	If !Empty(aTafRot)

		cAlias := aTafRot[3]

		If aTafRot[4] $ ("S-2250|S-2241|S-2230")

			Aadd(aRotAlt,{cRetific					,"xTafAlt('" + cAlias + "', 0 , 1)"     , 0, 4} )

			If !Alltrim(aTafRot[4]) $ "S-2230|S-2250|"
				Aadd(aRotAlt,{cAlterac				,"xTafAlt('" + cAlias + "', 0 , 2)"     , 0, 4} )
			EndIf

			Aadd(aRotAlt,{cCancFim					,"xTafAlt('" + cAlias + "', 0 , 3)"     , 0, 4} )

			nPosAlt	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } )

			If nPosAlt > 0
				aRotina[nPosAlt][2] := aRotAlt
			Endif

			If Alltrim(aTafRot[4]) $ "S-2230" //Afastamento

				nPosVisual  := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )
				aRotina[nPosVisual][2] := "TAFA261Op('1')" //Visualizar
				nPosVisual := 0

			EndIf

		ElseIf aTafRot[4] $ cEventos

			If !( aTafRot[4] $ "S-5003|S-5013" )

				nPosAlt := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } )

				If nPosAlt > 0 //Alterar
					aRotina[nPosAlt][2] := "TAFVAltEsocial('" + cAlias + "')" //Valida as alterações do eSocial
					nPosAlt := 0
				EndIf

			EndIf

			If aTafRot[4] $ "S-5001|S-5002|S-5011|S-5012|S-5501"

				nPosExc	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Excluir" } )

				If nPosExc > 0
					aRotina[nPosExc][2] := "TAFVExcEsocial('" + cAlias + "')" //Valida a exclusão do eSocial
				EndIf

			EndIf

			If (aTafRot[4] $ "S-5001|S-5011|S-5002|S-5012|S-5003|S-5013|S-5501")

				nPosAlt := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } )

				If nPosAlt > 0
					aDel( aRotina , nPosAlt )
					aSize( aRotina , Len( aRotina ) - 1 )
				EndIf

				nPosInc := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Incluir" } )

				If nPosInc > 0
					aDel( aRotina , nPosInc )
					aSize( aRotina , Len( aRotina ) - 1 )
				EndIf

				If aTafRot[4] $ "S-5003|S-5013"

					nPosExc := aScan( aRotina, { |aX| AllTrim( aX[1] ) == "Excluir" } )

					If nPosExc > 0
						aDel( aRotina, nPosExc )
						aSize( aRotina, Len( aRotina ) - 1 )
					EndIf

				EndIf

				If Alltrim(aTafRot[4]) $ "S-5013"

					nPosVisual  := aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Visualizar" } )
					aRotina[nPosVisual][2] := 'VIEWDEF.TAFA521' //Visualizar
					nPosVisual := 0

				EndIf

			EndIf

		ElseIf aTafRot[4] == "S-1200"

			For nX := 1 To Len( aRotina )

				If aRotina[nX][4] == 3
					aRotina[nX][2] := "TAF250Inc"
				ElseIf aRotina[nX][4] == 2
					aRotina[nX][2] := "TAF250View"
				EndIf

			Next nX

		ElseIf aTafRot[4] == "S-1250"

			If FindFunction("ImpDataNF")
				aAdd(aRotina, {"Buscar Docs Fiscais", "ImpDataNF", 0, 3, 0, Nil, Nil, Nil} )
			EndIf

		EndIf

		/*+-----------------------------------------------------+
		| Tratamento para o Menu de Exclusão para os eventos  	|
		| NÃO cadastrais		    							|
		+-----------------------------------------------------+*/
		If !Empty(cNmFun)

			lMnuExc	:=  (Len(aTafRot) > 10 .And. aTafRot[12] $ "EM")

			If lMnuExc

				If !aTafRot[4] $ ("S-1298|S-1299|S-2555")

					Aadd(aRotExcl,{"Excluir Registro"					,"xTafVExc"     , 0, 8 ,0, Nil} )
					
					If !aTafRot[4] $ ("S-3500")
						Aadd(aRotExcl,{"Desfazer Exclusão"					,"xTafVExc"     , 0, 5 } )
					EndIf

					Aadd(aRotExcl,{"Visualizar Registro de Exclusão"	,"xTafVExc"     , 0, 2 } )
					nPosExc	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Excluir" } )

					If nPosExc > 0
						aRotina[nPosExc][2] := aRotExcl
					EndIf

				EndIf

			ElseIf Len(aTafRot) > 10 .And. aTafRot[12] == "C"

            	nPosExc	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Excluir" } )

				If nPosExc > 0
                	aRotina[nPosExc][2] := "xTafDelTab('" + cAlias + "', 0 , 5)"
				EndIf

			EndIf

		EndIf

	EndIf

	If !Empty(aFuncao)

		For nI := 1 to Len(aFuncao)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O Terceiro parametro do Array aFuncao recebe um caracter      ³
			//³contendo as informacoes abaixo:                               ³
			//³                                                              ³
			//³"1" - Titulo predefinido -> "Gerar Xml e-Social"              ³
			//³"2" - Titulo predefinido -> "Validar Registro"                ³
			//³                                                              ³
			//³Caso seja informado, o primeiro parametro recebera o conteudo ³
			//³predefinido                                                   ³
			//³                                                              ³
			//³Foi desenvolvido para que as Strings sejam criadas em unico   ³
			//³local, em situacoes que os Titulos forem usados com frequencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aFuncao[nI] ) > 2

				If aFuncao[nI,3] <> Nil

					If aFuncao[nI,3] == "1"

						If cMenu == "TAFA441"
							aFuncao[nI,1] := STR0114 //"Carregar Grupo de Eventos"
						Else
							aFuncao[nI,1] := STR0059 //"Gerar Xml e-Social"
						EndIf

					ElseIf aFuncao[nI,3] == "2"

						If cMenu == "TAFA441"
							aFuncao[nI,1] := STR0116 //"Agendar Transmissão"
						Else
							aFuncao[nI,1] := STR0060 //"Validar Registro"
						EndIf

					ElseIf aFuncao[nI,3] == "3" .and. !(cMenu $ "TAFA269|TAFA423")

						aFuncao[nI,1] := STR0061 //"Exibir Histórico de Alterações"

					ElseIf aFuncao[nI,3] == "4"

						aFuncao[nI,1] := STR0080 //"Gerar Registro"

					ElseIf aFuncao[nI,3] == "5"

						aFuncao[nI,1] := STR0111 //"Gerar XML em Lote"

					ElseIf aFuncao[nI,3] == "6"

						If cMenu $ "TAFA269|TAFA610"
							aFuncao[nI,1] := "Ajuste de Status Exclusão"
						Else
							aFuncao[nI,1] := STR0118 //"Cadastro de Insumos"
						EndIf

					ElseIf aFuncao[nI,3] == "7"

						If cMenu == "TAFA269"
							aFuncao[nI,1] := "Ajuste de CNPJ/CPF"
						Else
							aFuncao[nI,1] := STR0124 //"Carregar Predecessões"
						EndIf

					ElseIf aFuncao[nI,3] == "8"

						aFuncao[nI,1] := STR0125 //"Carregar Predecessão de Evento"
						//Reinf-Obras

					ElseIf aFuncao[nI,3] == "9"

						aFuncao[nI,1] := STR0139 //"Importar Estabelecimentos Esocial"

					ElseIf aFuncao[nI,3] == "10"

						aFuncao[nI,1] := "Ajuste de Recibo"

					EndIf

				EndIf

			EndIf

			If Len( aFuncao[nI] ) > 2 .And. aFuncao[nI,3] == "9" //Reinf-Obras
				nOper := 3
			Else //Padrao-Esocial
				nOper := Iif( Len( aFuncao[nI] ) >= 4, aFuncao[nI,4], nCont )
			EndIf

			aAdd( aRotina, { aFuncao[nI,1], aFuncao[nI,2], 0, nOper, 0, Nil } )
			nCont += 1

		Next nI

	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNPerfil
Funcao responsavel por retornar o modelo do documento fiscal abaixo conforme perfil da empresa configurada.
	Para os documentos de Saida, tem a opcao se sempre perguntar na inclusao ou trazer um DEFAUL conforme parametro MV_TAFSEG.
	Para os documentos de Entrada, sempre apresentarah a pergunta na inclusao.

	Nas outras manutencoes, pego o modelo do registro posicionado.

	Este tratamento de mostrar um pergunte eh para poder otimizar a tela de manutencao do documento fiscal, omitindo alguns folder nao
		necessarios para o respectivo modelo. Como o MVC nao trata isso dinamico, tenho que apresentar esta tela antes de montar a VIEW.

	Os modelos validos sao:

@param 	oModel	 - Model
			cOper   - Tipo de operacao, 0=entrada, 1=Saida

@return	cCodMod - Codigo do modelo do documento fiscal conforme tabela abaixo:
						01		NOTA FISCAL
						02		NOTA FISCAL DE VENDA A CONSUMIDOR
						04		NOTA FISCAL DE PRODUTOR
						06		NOTA FISCAL/CONTA DE ENERGIA ELETRICA
						07		NOTA FISCAL DE SERVICO DE TRANSPORTE
						08		CONHECIMENTO DE TRANSPORTE RODOVIARIO DE CARGAS
						09		CONHECIMENTO DE TRANSPORTE AQUAVIARIO DE CARGAS
						10		CONHECIMENTO AEREO
						11		CONHECIMENTO DE TRANSPORTE FERROVIARIO DE CARGAS
						13		BILHETE DE PASSAGEM RODOVIARIO
						14		BILHETE DE PASSAGEM AQUAVIARIO
						15		BILHETE DE PASSAGEM E NOTA DE BAGAGEM
						16		BILHETE DE PASSAGEM FERROVIARIO
						18		RESUMO DE MOVIMENTO DIARIO
						1B		NOTA FISCAL AVULSA
						21		NOTA FISCAL DE SERVICO DE COMUNICACAO
						22		NOTA FISCAL DE SERVICO DE TELECOMUNICACAO
						26		CONHECIMENTO DE TRANSPORTE MULTIMODAL DE CARGAS
						27		NOTA FISCAL DE TRANSPORTE FERROVIARIO DE CARGA
						28		NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS CANALIZADO
						29		NOTA FISCAL/CONTA DE FORNECIMENTO DE AGUA CANALIZADA
						2D		CUPOM FISCAL
						2E		CUPOM FISCAL BILHETE DE PASSAGEM
						55		NOTA FISCAL ELETRONICA NF-E
						57		CONHECIMENTO DE TRANSPORTE ELETRONICO - CT-E
						58		CUPOM FISCAL ELETRONICO - CF-E
						8B		CONHECIMENTO DE TRANSPORTE DE CARGAS AVULSO

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNPerfil( oModel , cOper )

	Local	cCodMod		:=	''
	Local	cMVTAFSEG	:=	'  '
	Local	aButtons	:=	{}

	//Para documento de saida, utilizo o parametro se tiver configurado
	If cOper == '1'
		cMVTAFSEG	:=	GetNewPar( "MV_TAFSEG" , cMVTAFSEG )
	EndIf

	//Para documento de Entrada ou Parametro em branco, aciono o pergunte e mostro na tela
	If Empty( cMVTAFSEG ) .Or. cOper == '0'
		aAdd( aButtons , { 1 , .T. , { | o | nOpca := 1 , o:oWnd:End() } } )

		//Aciona pergunta personalizada do TAF
		PergTAF( 'TAFA062' , 'Parâmetros...', {'Modelo do Documento Fiscal'}, aButtons, {|| .T. } )

		cCodMod	:=	XFUNID2Cd( MV_PAR01 , 'C01' )

	//Para documento de Saida ou Parametro preenchido, aciono o pergunte e NAO mostro na tela
	Else
		aAdd( aButtons , { 1 , .T. , { | o | nOpca := 1 , o:oWnd:End() } } )

		//Aciona pergunta personalizada do TAF
		PergTAF( 'TAFA062' , 'Parâmetros...', {'Modelo do Documento Fiscal'}, aButtons, {|| .T. } )

		MV_PAR01	:=	XFUNCh2ID( cMVTAFSEG , 'C01' )
		cCodMod		:=	cMVTAFSEG
	EndIf

	cCodMod	:=	Iif( Empty( cCodMod ) , '01' , cCodMod )
	MV_PAR01:=	Iif( Empty( MV_PAR01 ) , XFUNCh2ID( cCodMod , 'C01' ) , MV_PAR01 )

Return cCodMod
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNSeekCh
Essa rotina utiliza arrays para montar um cache com informações que são muito recorrentes durante a importação dos layouts TAF, diminuindo o
acesso ao banco de dados, e consequentemente melhorando a performance da aplicação nesse momento.
Os arrays utilizados estão declarados no início do fonte, seus nomes possuem o prefixo 'aCache' e sufixo com nome da tabela correspondente. Isso
permite que a função trate dinamicamente o cachê a ser utilizado de acordo com o parametro cAlias (nome da tabela).

Atualmente a rotina está preparada para trabalhar com as tabelas C09,C1V,C6C,C86,C1J,C0G,C1O,C1P,C01,C0U,C02,C1A,C11,C17,C3D,C1N,T71,C0Y;
Caso seja necessário a criação de outras possibilidades de cache, é necessário apenas que se crie o array (utilizando o padrão de nomenclatura) e
que seja acrescentado o alias na verificação de alias válidos que é feita logo no início da função.

@param 	cChave		-	Chave a ser pesquisada
		cAlias		-	Alias para o SEEK
		nIndice	    - 	Indice do SEEK

@return	cRet	- 	ID do cadastro

@author Leandro Prado
@since 17/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XFUNSeekCh( cChave , cAlias , nIndice )
	Local cRet := "" //Retorno da função
	Local nIndArray := 0 //Indice onde a chave está armazenada dentro do array utilizado para o cache
	Local cSeekFil := "" 
	
	If cAlias == "C1E" .and. (__cFilC1E == Nil .or. !Empty(Alltrim(__cFilC1E)))
		__cFilC1E := xFilial("C1E")
	EndIf

// A rotina de cache só é válida para os cAlias : C09,C1V,C6C,C86,C1J,C0G,C1O,C1P,C01,C0U,C02,C1A,C11,C17,C3D,C1N,T71,C0Y
	If cAlias + '|' $ 'C09|C1V|C6C|C86|C1J|C0G|C1O|C1P|C01|C0U|C02|C1A|C11|C17|C3D|C1N|T71|C0Y|'
		cSeekFil := Iif(cAlias != "C1E",xFilial( cAlias ), __cFilC1E)
		// Verifica se a chave existe dentro do array correspondente ao Alias.
		If ( nIndArray := aScan(&('aCache' + cAlias), {|x,y| x[1] == cSeekFil + cChave}) ) > 0
			//Retorna o ID que está armazenado no array.
			cRet := &('aCache' + cAlias )[nIndArray][2]
		Else
			// Se não achar no cachê, busca no banco de dados.
			DbSelectArea( cAlias )
			(cAlias)->( dbSetOrder( nIndice ) )
			If (cAlias)->( MsSeek( cSeekFil + cChave ) ) .or. ;
					(cAlias)->( MsSeek( cSeekFil + Padr( cChave, 100 ) ) )

				//Se o ID for encontrado no banco de dados ele é armazenado em cache juntamente com a chave e retorna utilizando cRet.
				aAdd(&('aCache' + cAlias), {cSeekFil + cChave, ( cAlias )->( &( cAlias + "_ID" ) )} )
				cRet := ( cAlias )->( &( cAlias + "_ID" ) )
			EndIf

		EndIf
	EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNCh2ID
Retorna o ID do registro para uma chave de pesquisa passada por parametro

@param 	cChave		-	Chave a ser pesquisada
		cAlias		-	Alias para o SEEK
		nIndice	    - 	Indice do SEEK
		cCmpOrig    -   Nome do campo de onde esta sendo chamada a validacao
		lMotorInt	-	Indica que a chamada da funcao eh originada da integracao
						banco a banco
		lSameAlias	-	Indica que a tabela de destino da consulta eh a mesma que a tabela
						de origem. O tratamento eh necessario, pois neste caso deve ser
						feito um select na tabela de destino ao inves de seek, evitando
						concorrencia no	reclock apos retorno desta funcao.
						Utilizado na integracao banco a banco
		lForcarID	-	Indica qual retorno será o ID do campo desejado.
						Utilizar para os campos que retornam o Código ao invés do ID.


@return	cID			- 	ID do cadastro

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNCh2ID( cChave, cAlias, nIndice, cCmpOrig, lMotorInt, lSameAlias, lForcarID )

	Local cID          := ""
	Local cQuery       := ''
	Local cAliasQry    := ''
	Local cSeekFil     := ""

	Default cAlias     := ""
	Default cChave     := ""
	Default nIndice    := 1
	Default cCmpOrig   := ""
	Default lMotorInt  := .F.
	Default lSameAlias := .F.
	Default lForcarID  := .F.

	cID := cChave //Tratamento para quando vir VAZIO no arquivo, ele nao ache o primeiro registro no SEEK soh com a filial

	If !Empty( cID )

		//Indica que a tabela de destino da consulta eh a mesma que a tabela de origem.
		//Este tratamento eh necessario, pois neste caso deve ser feito um select na tabela de destino ao inves de seek
		//evitando concorrencia no reclock apos retorno desta funcao.
		if lSameAlias

			cAliasQry	:=	getNextAlias()

			//Select da tabela C1O - utilizado para o campo C1O_CTASUP
			if cAlias == "C1O"
				cQuery:="SELECT C1O_ID FROM " + RetSqlName( cAlias ) + " WHERE C1O_FILIAL = '" + xFilial( "C1O" ) + "' AND C1O_CODIGO = '" + cChave + "' AND D_E_L_E_T_ = ''"

				//Select da tabela C1E - utilizado para o campo C1E_FILTAF
			elseif cAlias == "C1E"
				cQuery:="SELECT C1E_FILTAF FROM " + RetSqlName( cAlias ) + " WHERE C1E_FILIAL = '" + xFilial( "C1E" ) + "' AND C1E_CODFIL = '" + cChave + "' AND D_E_L_E_T_ = ''"
			endif

			//Executa a query e atribui o ID retornado
			cQuery := ChangeQuery( cQuery )
			TcQuery cQuery New Alias &cAliasQry

			//Valido novamente para evitar utilizacao de macro-execucao
			if cAlias == "C1O"
				cID := ( cAliasQry )->C1O_ID
			elseif cAlias == "C1E"
				cID := ( cAliasQry )->C1E_FILTAF
			endif

			( cAliasQry )->( dbCloseArea() )

		else

			cID := XFUNSeekCh( cChave , cAlias , nIndice ) //Verifica se existe a informação em cache

			If Empty( cID )
				DbSelectArea( cAlias )
				(cAlias)->( dbSetOrder( nIndice ) )
				
				cSeekFil := Iif(cAlias != "C1E",xFilial( cAlias ), __cFilC1E)
				//No campo cChave é necessário incluir espaços a direita antes do seek para evitar que chaves incompletas sejam
				//encontradas, definimos o tamanho 100 como um valor default que atende todos os campos que sao integrados

				If ( !(cAlias == "C1L" ) .And. ( cAlias )->( MsSeek( cSeekFil + cChave ) ) ) .Or. ;
						( cAlias )->( MsSeek( cSeekFil + Padr( cChave, 100 ) ) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Rodrigo Aguilar - 15/03/2013                                         ³
					//³Quando for referente ao DE/PARA da Filial ( Cadastro de Complemento )³
					//³nao se deve retornar o ID mas sim o codigo da filial de referencia   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cAlias == "C1E" .And. !lForcarID
						cID	:=	( cAlias )->( &( cAlias + "_FILTAF" ) )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Luccas Curcio - 20/05/2016	                                        											³
						//³Quando for referente ao DE/PARA da Filial ( Cadastro de Complemento ) através da tabela CR9, necessito utilizar	³
						//³a conversão do ID para o código da C1E, pois o índice utiliza na integração é pelo campo C1E_FILTAF.				³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Elseif cAlias == "CR9" .And. !lForcarID
						cID	:=	( cAlias )->( &( cAlias + "_ID" ) )
						cID	:=	XFUNID2Cd( cID , "C1E" , 2 )

					Else
						cID	:=	( cAlias )->( &( cAlias + "_ID" ) )
					EndIf
				Else

					//Caso seja o motor de integracao deixo gravar cid == ""
					If !lMotorInt
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Rodrigo Aguilar - 15/03/2013                                                            ³
						//³Os tratamentos abaixo sao para quando o codigo informado no arquivo de importacao       ³
						//³eh maior do que o tamanho do campo de ID e nao existam na base de dados, nesse caso     ³
						//³as variaveis abaixo sao manipuladas para que o retorno do erro contenha o codigo correto³
						//³do arquivo TXT.                                                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cAlias == "C1H"
							cID	   	   :=	'.'
							If cCmpOrig == "C32_CODPAR"
								lC32CodPar := .F.
							ElseIf cCmpOrig == "C38_CODPAR"
								lC38CodPar := .F.
							ElseIf cCmpOrig == "C20_CODPAR"
								lC20CodPar := .F.
							EndIf
						ElseIf cAlias == "C1G" .And. !Empty( cCmpOrig )
							If cCmpOrig == "C6W_NUMERO"
								cID	   	   :=	'.'
								lC6WNumPrc := .F.
							EndIf
						ElseIf cAlias == "C1O"
							cID	   	   :=	'.'
							If cCmpOrig == "C20_CODCTA"
								lC20CodCta := .F.
							EndIf
						ElseIf Type( "GB_MEMVAR2" ) != "U"
							GB_MEMVAR2	:=	.F.
							cID			:=	'.'
						EndIf
					Else
						cId := ""
					EndIf
				EndIf
			EndIf
		endif
	EndIf

Return cID
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunID2Cd

Retorna o Código do registro para um ID passado por parâmetro.

@Param		cID			- ID a ser pesquisado
			cAlias		- Alias para a busca
			nIndice	- Índice para busca

@Return	cCodigo	- Código do cadastro relacionado ao ID

@Author	Gustavo G. Rueda
@Since		22/10/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function xFunID2Cd( cID, cAlias, nIndice )

	Local cCodigo	:=	""
	Local cCmpCod	:=	Iif( cAlias == "C1E", "_FILTAF", "_CODIGO" )
	Local aArea	:=	( cAlias )->( GetArea() )

	Default nIndice	:=	3

	cID := Iif( Empty( cID ), " ", cID ) //Tratamento para quando vir VAZIO no arquivo, ele não ache o primeiro registro na busca só com a Filial

	If ( cAlias )->( DBSetOrder( nIndice ), MsSeek( xFilial( cAlias ) + cID ) )
		cCodigo := ( cAlias )->( &( cAlias + cCmpCod ) )
	EndIf

	RestArea( aArea )

Return( cCodigo )
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldX1
Funcao de validacao generida de pergunte, tratando Codigo e ID, o que for digitado no pergunte.

@param 	nOpc		-	Opcao para definir a condicao a ser tratada (IDENTIFICADOR)

@return	lRet		- 	FLAG de retorno da validacao

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldX1( nOpc )
	Local	lRet	:=	.T.

	Default	nOpc	:=	1

	If nOpc == 1 	//Tratamento para o pergunt do TAFA062 para a tabela C01
		If !C01->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C01' ) + MV_PAR01 ) )
			If C01->( dbSetOrder( 1 ) , MsSeek( xFilial( 'C01' ) + MV_PAR01 ) )
				MV_PAR01 	:= 	XFUNCh2ID( MV_PAR01 , "C01" )
				MV_PAR02 	:= 	C01->C01_CODIGO + ' - ' + C01->C01_DESCRI
			Else
				Help( ,,'.TAFA06201.',,, 1, 0 )
				lRet	:=	.F.
			EndIf
		Else
			MV_PAR02 	:= C01->C01_CODIGO + ' - ' + C01->C01_DESCRI
		EndIf
	EndIf

	If nOpc == 2 	//Tratamento para o pergunt do TAFR110 para a tabela C0A - NCM Inicio
		If Alltrim(MV_PAR02)<>"" .And. C0A->( dbSetOrder( 1 ) , MsSeek( xFilial( 'C0A' ) + PadR(AllTrim(MV_PAR02),TamSx3("C0A_CODIGO")[1])))
			MV_PAR02 	:= 	AllTrim(C0A->C0A_CODIGO)
			MV_PAR02 	:=  PadR(MV_PAR02,TamSx3("C0A_ID")[1])
		ElseIf Alltrim(MV_PAR02)<>"" .And. C0A->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C0A' ) + PadR(AllTrim(MV_PAR02),TamSx3("C0A_ID")[1])))
			MV_PAR02 	:= 	C0A->C0A_CODIGO
			MV_PAR02 	:=  PadR(MV_PAR02,TamSx3("C0A_ID")[1])
		ElseIf Alltrim(MV_PAR02)<>""
			Help( ,,'.TAFR11002.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 3 	//Tratamento para o pergunt do TAFR110 para a tabela C0A - NCM Fin
		If Alltrim(MV_PAR03)<>"" .And. C0A->( dbSetOrder( 1 ) , MsSeek( xFilial( 'C0A' ) + PadR(AllTrim(MV_PAR03),TamSx3("C0A_CODIGO")[1])))
			MV_PAR03 	:= 	C0A->C0A_CODIGO
			MV_PAR03 	:=  PadR(MV_PAR03,TamSx3("C0A_ID")[1])
		ElseIf Alltrim(MV_PAR03)<>"" .And. C0A->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C0A' ) + PadR(AllTrim(MV_PAR03),TamSx3("C0A_ID")[1])))
			MV_PAR03 	:= 	C0A->C0A_CODIGO
			MV_PAR03 	:=  PadR(MV_PAR03,TamSx3("C0A_ID")[1])
		ElseIf Alltrim(MV_PAR03)<>""
			Help( ,,'.TAFR11003.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 4 	//Tratamento para o pergunt do TAFR113 para a tabela C1L - Produto Inicio
		If Alltrim(MV_PAR04)<>"" .And. C1L->( dbSetOrder( 1 ) , MsSeek( xFilial( 'C1L' ) + PadR(AllTrim(MV_PAR04),TamSx3("C1L_CODIGO")[1])))
			MV_PAR04 	:= 	AllTrim(C1L->C1L_CODIGO)
			MV_PAR04 	:=  PadR(MV_PAR04,TamSx3("C1L_ID")[1])
		ElseIf Alltrim(MV_PAR04)<>"" .And. C1L->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C1L' ) + PadR(AllTrim(MV_PAR04),TamSx3("C1L_ID")[1])))
			MV_PAR04 	:= 	AllTrim(C1L->C1L_CODIGO)
			MV_PAR04 	:=  PadR(MV_PAR04,TamSx3("C1L_ID")[1])
		ElseIf Alltrim(MV_PAR04)<>""
			Help( ,,'.TAFR11305.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 5 	//Tratamento para o pergunt do TAFR113 para a tabela C1L - Produto Fin
		If Alltrim(MV_PAR05)<>"" .And. C1L->( dbSetOrder( 1 ) , MsSeek( xFilial( 'C1L' ) + PadR(AllTrim(MV_PAR05),TamSx3("C1L_CODIGO")[1])))
			MV_PAR05 	:= 	C1L->C1L_CODIGO
			MV_PAR05 	:=  PadR(MV_PAR05,TamSx3("C1L_ID")[1])
		ElseIf Alltrim(MV_PAR05)<>"" .And. C1L->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C1L' ) + PadR(AllTrim(MV_PAR05),TamSx3("C1L_ID")[1])))
			MV_PAR05 	:= 	C1L->C1L_CODIGO
			MV_PAR05 	:=  PadR(MV_PAR05,TamSx3("C1L_ID")[1])
		ElseIf Alltrim(MV_PAR05)<>""
			Help( ,,'.TAFR11306.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 6 	//Tratamento para o pergunt do TAFR111 para a tabela C0R - Documento de Arrecadacao Inicial
		If Alltrim(MV_PAR07) <> "" .And. C0R->( dbSetOrder( 2 ) , MsSeek( xFilial( 'C0R' ) + AllTrim(MV_PAR07)))
			MV_PAR07 := 	PadR(C0R->C0R_NUMDA,TamSx3("C0R_NUMDA")[1])
		ElseIf Alltrim(MV_PAR07) <> "" .And. Len(Alltrim(MV_PAR07)) == TamSx3("C0R_ID")[1] .And. C0R->( dbSetOrder( 6 ) , MsSeek( xFilial( 'C0R' ) + AllTrim(MV_PAR07)))
			MV_PAR07 := 	PadR(C0R->C0R_NUMDA,TamSx3("C0R_NUMDA")[1])
		ElseIf Alltrim(MV_PAR07) <> ""
			Help( ,,'.TAFR11003.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 7 	//Tratamento para o pergunt do TAFR111 para a tabela C0R - Documento de Arrecadacao Final
		If Alltrim(MV_PAR08) <> "" .And. C0R->( dbSetOrder( 2 ) , MsSeek( xFilial( 'C0R' ) + AllTrim(MV_PAR08)))
			MV_PAR08 := 	PadR(C0R->C0R_NUMDA,TamSx3("C0R_NUMDA")[1])
		ElseIf Alltrim(MV_PAR08) <> "" .And.  Len(Alltrim(MV_PAR08)) == TamSx3("C0R_ID")[1] .And.C0R->( dbSetOrder( 6 ) , MsSeek( xFilial( 'C0R' ) + AllTrim(MV_PAR08)))
			MV_PAR08 := 	PadR(C0R->C0R_NUMDA,TamSx3("C0R_NUMDA")[1])
		ElseIf Alltrim(MV_PAR08) <> ""
			Help( ,,'.TAFR11003.',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 8 	//Tratamento para o pergunt do TAF275 para a tabela C9V
		If !Empty( MV_PAR01 )
			If !C9V->( dbSetOrder( 2 ) , MsSeek( xFilial( 'C9V' ) + Alltrim( MV_PAR01 ) + "1" ) )
				If C9V->( dbSetOrder( 3 ) , MsSeek( xFilial( 'C9V' ) + Padr( MV_PAR01, Tamsx3( "C9V_CPF" )[1] ) + "1" ) )
					//Utilizo o TAMSX3 do campo CPF para que o usuario possa alterar o CPF na
					//telam caso contrario como o campo ID eh tamanho 06 nao seria possivel incluir o
					//CPF novamente que eh tamanho 11
					MV_PAR01 	:= 	Padr( C9V->C9V_ID, Tamsx3( "C9V_CPF" )[1] )
					MV_PAR02 	:= 	C9V->C9V_CPF + ' - ' + C9V->C9V_NOME
				Else
					Help( ,,'CPFVALID',,, 1, 0 )
					lRet	:=	.F.
				EndIf
			Else
				MV_PAR02 	:= C9V->C9V_CPF + ' - ' + C9V->C9V_NOME
			EndIf
		Else
			Help( ,,'CPFVALID',,, 1, 0 )
			lRet	:=	.F.
		EndIf
	EndIf

	If nOpc == 9 //Tratamento para o Pergunte do TAFA322 para a tabela CHD
		If !Empty( MV_PAR01 )
			If CHD->( DBSetOrder( 1 ), CHD->( MsSeek( xFilial( "CHD" ) + PadR( MV_PAR01, TamSX3( "CHD_ID" )[1] ) ) ) )
				MV_PAR01 := CHD->CHD_ID
				MV_PAR02 := DToC( CHD->CHD_PERINI ) + " - " + DToC( CHD->CHD_PERFIN )
			Else
				MsgInfo( STR0085 ) //"Período de escrituração não cadastrado."
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0084 ) //"Período de escrituração não informado."
			lRet := .F.
		EndIf
	EndIf

	If nOpc == 10 //Tratamento para o Pergunte do TAFA430 para a tabela C3S
		If !Empty( MV_PAR01 )

			If Len( AllTrim( MV_PAR01 ) ) < 6
				MV_PAR01 := Iif( !Empty( xFunCh2ID( MV_PAR01, "C3S" ) ), xFunCh2ID( MV_PAR01, "C3S" ), MV_PAR01 )
			EndIf

			If C3S->( DBSetOrder( 3 ), C3S->( MsSeek( xFilial( "C3S" ) + PadR( MV_PAR01, TamSX3( "C3S_ID" )[1] ) ) ) )
				MV_PAR01 := C3S->C3S_ID
				MV_PAR02 := AllTrim( C3S->C3S_CODIGO ) + " - " + AllTrim( C3S->C3S_DESCRI )
			Else
				MsgInfo( STR0106 ) //"Tributo não cadastrado."
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0107 ) //"Tributo não informado."
			lRet := .F.
		EndIf
	EndIf

	If nOpc == 11 //Tratamento para o Pergunte do TAFA433 para a tabela T0K
		If !Empty( MV_PAR01 )
			If Len( AllTrim( MV_PAR01 ) ) < 6
				MV_PAR01 := Iif( !Empty( xFunCh2ID( MV_PAR01, "T0K" ) ), xFunCh2ID( MV_PAR01, "T0K" ), MV_PAR01 )
			EndIf

			If T0K->( DBSetOrder( 2 ), T0K->( MsSeek( xFilial( "T0K" ) + PadR( MV_PAR01, TamSX3( "T0K_CODIGO" )[1] ) ) ) )
				MV_PAR01 := T0K->T0K_CODIGO
				MV_PAR02 := AllTrim( T0K->T0K_DESCRI )
			Else
				MsgInfo( STR0112 ) //"Forma de Tributação incorreta."
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0113 ) //"Forma de Tributação não informada"
			lRet := .F.
		EndIf
	EndIf

	If nOpc == 12 //Tratamento para o Pergunte do TAFA444 para a tabela T0J
		If !Empty( MV_PAR01 )

			If T0J->( DBSetOrder( 2 ), T0J->( MsSeek( xFilial( "T0J" ) + PadR( MV_PAR01, TamSX3( "T0J_CODIGO" )[1] ) ) ) )
				MV_PAR01 := T0J->T0J_CODIGO
				MV_PAR02 := AllTrim( T0J->T0J_DESCRI )
			Else
				MsgInfo( STR0106 ) //"Tributo não cadastrado."
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0107 ) //"Tributo não informado."
			lRet := .F.
		EndIf
	EndIf

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} PergTAF
Funcao que monta a tela de pergunta do com botoes costomizados. Os dados digitados
sao armazenados no profile e de lah recuperados

@param 	cPergunte	-	Nome do pergunte (SX1)
			cTitle		-	Titulo da tela de perguntas
			aSays		- 	SAYs (titulos) das perguntas
			aButtons	-	Botoes da tela
			bValid		-	Codeblock com o Valid da DIALOG
			nAltura	-	Tamanho da altura (padrao 250)
			nLargura	-	Tamanho da largura (padrao 520)

@return	Nil


*** NAO ESTA CONSTRUIDO PARA SER UMA FUNCAO DINAMICA, HJ ESTAH ESPECIFICO PARA O DOCUMENTO FISCAL - TAFA062

Foi incluido tratamento para o cadastro de funcionários, tabela C9V ( TAFA275 )


@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function PergTAF( cPergunte , cTitle , aSays , aButtons, bValid, nAltura, nLargura, lProfile )

	Local	cSxb		:=	""
	Local 	nButtons	:=	Len( aButtons )
	Local 	nSays		:=	Len( aSays )
	Local	nOpcFilt	:=	0
	Local	nTamSX3	:=	0
	Local	nI
	Local	nTop
	Local 	nType
	Local 	lEnabled
	Local	lRet		:=	.T.
	Local 	oFont
	Local 	nLarguraBox
	Local 	nAlturaBox
	Local 	nLarguraSay
	Local	aPergunte	:=	{}
	Local	aGrava		:=	{}

	Default	aSays		:=	{}
	Default	aButtons	:=	{}
	Default	nAltura	:= 	250
	Default	nLargura	:= 	520
	Default	lProfile	:=	!( cPergunte $ "TAFA275|TAFA276|TAFA277|TAFA280|TAFA444" )

	If cPergunte == "TAFA062"
		cSXB := "C01"
		nTamSX3 := TamSX3( "C20_CODMOD" )[1]
		nOpcFilt := 1
	ElseIf cPergunte $ "TAFA277|TAFA280"
		cSXB := "C9VB"
		nTamSX3 := TamSX3( "C9V_CPF" )[1]
		nOpcFilt := 8
	ElseIf cPergunte $ "TAFA275"
		cSXB := "C9V"
		nTamSX3 := TamSX3( "C9V_CPF" )[1]
		nOpcFilt := 8
	ElseIf cPergunte $ "TAFA276"
		cSXB := "C9VC"
		nTamSX3 := TamSX3( "C9V_CPF" )[1]
		nOpcFilt := 8
	ElseIf cPergunte $ "TAFA322"
		cSXB := "CHD"
		nTamSX3 := TamSX3( "CHD_ID" )[1]
		nOpcFilt := 9
	ElseIf cPergunte $ "TAFA430"
		cSXB := "C3SA"
		nTamSX3 := TamSX3( "C3S_ID" )[1]
		nOpcFilt := 10
	ElseIf cPergunte $ "TAFA433"
		cSXB := "T0KA"
		nTamSX3 := TamSX3( "T0K_CODIGO" )[1]
		nOpcFilt := 11
	ElseIf cPergunte $ "TAFA444"
		cSXB := "T0J"
		nTamSX3 := TamSX3( "T0J_CODIGO" )[1]
		nOpcFilt := 12
	ElseIf cPergunte $ "TAFA623"
		cSXB := "CH6K"
		nTamSX3 := TamSX3( "V17_METODO" )[1]
		nOpcFilt := 6
	Else
		cSXB := "C9VA"
		nTamSX3 := TamSX3( "C20_CODMOD" )[1]
		nOpcFilt := 1
	EndIf

// Numero maximo de linhas
	If( nSays > 7 )
		nSays	:=	7
	EndIf

// Numero maximo de botoes
	If( nButtons > 5 )
		nButtons	:= 	5
	EndIf

	DEFINE FONT oFont NAME "Arial" SIZE 0, -11

	DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO nAltura,nLargura OF oMainWnd PIXEL

	nAlturaBox	:=	( nAltura - 60 ) / 2
	nLarguraBox	:= 	( nLargura- 20 ) / 2
	@ 10,10 TO nAlturaBox , nLarguraBox OF oDlg PIXEL

	If lProfile
		XFUNLoadProf ( cPergunte , @aPergunte )
	EndIf

	MV_PAR01	:=	If( Len( aPergunte ) > 0 , aPergunte[ 1 , 1 ] , Space( nTamSX3 ) )
	MV_PAR02	:=	If( Len( aPergunte ) > 0 , aPergunte[ 1 , 2 ] , Space( 220 ) )

	nLarguraSay :=	nLarguraBox - 30
	nTop		:=	20
	TSay():New( nTop , 20 , {|| aSays[1] } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLarguraSay / 2 , 10 , .F. , .F. , .F. , .F. , .F. )
	nTop		+= 	10
	TGet():New( nTop , 20  , { | u | If( PCount() == 0 , MV_PAR01 , MV_PAR01 := u ) } , oDlg , 040 , 10 , '@!', {|| lRet := XFUNVldX1( nOpcFilt ) } , , , , .F. , , .T. , , .F. , {|| .T. } , .F. , .F. , , .F. , .F. ,cSXB )
	If "X370" $ Upper( FunDesc() )
		TGet():New( nTop , 65  , { | u | If( PCount() == 0 , MV_PAR02 := XFUNMEtod(MV_PAR01) , MV_PAR02 := u ) } , oDlg , 177 , 10 , '@!', {|| .T.        } , , , , .F. , , .T. , , .F. , {|| .F. } , .F. , .F. , , .F. , .F. )
	Else
		TGet():New( nTop , 65  , { | u | If( PCount() == 0 , MV_PAR02 , MV_PAR02 := u ) } , oDlg , 177 , 10 , '@!', {|| .T.        } , , , , .F. , , .T. , , .F. , {|| .F. } , .F. , .F. , , .F. , .F. )
	EndIf
	nTop		+= 	10

//monta bottoes(bof)
	nPosIni			:= 	( ( nLargura - 20 ) / 2 ) - ( nButtons * LARGURA_DO_SBUTTON )
	nAlturaButton	:= 	nAlturaBox + 10

	For nI := 1 To nButtons
		nType	:= 	aButtons[ nI , 1 ]
		lEnabled:= 	aButtons[ nI , 2 ]

		DEFAULT lEnabled:= .T.

		If lEnabled
			If Len( aButtons[ nI ] ) > 3 .And. ValType( aButtons[ nI , 4 ] ) == "C"
				SButton():New( nAlturaButton , nPosIni , nType , aButtons[ nI, 3 ] , oDlg , .T. , aButtons[ nI , 4 ] )
			Else
				SButton():New( nAlturaButton , nPosIni , nType , aButtons[ nI , 3 ] , oDlg , .T. , , )
			Endif
		Else
			SButton():New( nAlturaButton , nPosIni , nType , , oDlg , .F. , , )
		EndIf

		nPosIni	+=	LARGURA_DO_SBUTTON
	Next

	oDlg:Activate( ,,,.T.,bValid,,,, )



	If lProfile

		aAdd ( aGrava, "{PAINEL001}" )
		aAdd ( aGrava, "{OBJ001;C;" + StrZero( nTamSX3, 3 ) + "}"+MV_PAR01 )
		aAdd ( aGrava, "{OBJ002;C;" + StrZero( Len( MV_PAR02 ) , 3 ) + "}"+MV_PAR02 )

		XFUNSaveProf ( cPergunte , aGrava )
	EndIf

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNSpcMIL
Funcao de tratamento na importacao do MILE para obter o ID para campos multiplos.

@param 	cAlias		-	Alias de pesquisa
			xX			-	Primeiro Parametro do Posicione
			xY			-	Segundo Parametro do Posicione

@return	cRetorno	- 	Conteudo do campo ID, retorno do Posicione

@author Gustavo G. Rueda
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNSpcMIL( cAlias , x1 , x2 , x3 , x4 , x5 , x6 , x7, x8 )

	Local cRetorno	:=	""

	Local cStr01 := Iif( ValType( x1 ) <> "U", x1, "" )
	Local cStr02 := Iif( ValType( x2 ) <> "U", x2, "" )
	Local cStr03 := Iif( ValType( x3 ) <> "U", x3, "" )
	Local cStr04 := Iif( ValType( x4 ) <> "U", x4, "" )
	Local cStr05 := Iif( ValType( x5 ) <> "U", x5, "" )
	Local cStr08 := Iif( Valtype( x8 ) <> "U", x8, "" )
	Local cAtivo := ""

	Local cStrAux1		:=	''

	Local nPadR1 := 0
	Local nPadR2 := 0
	Local nPadR3 := 0
	Local nPadR4 := 0
	Local nPadR5 := 0
	Local nPadR6 := 0
	Local nPadR7 := 0

	Local nOrd := 0

	Local lColumnPos := .F.

//Definição da chave, ordem e campos para a busca
	If cAlias == 'C1G'
		If cStr03 == 'ECF' .Or. cStr03 == 'REINF'
			nOrd := 9
			nPadR1	:=	TamSx3( 'C1G_TPPROC' )[ 1 ]
			cAtivo := "1"
		Else
			nOrd := 4
			nPadR1	:=	TamSx3( 'C1G_INDPRO' )[ 1 ]
		EndIf

		nPadR2	:=	TamSx3( 'C1G_NUMPRO' )[ 1 ]

	ElseIf cAlias == 'C0R'
		nPadR1	:=	TamSx3( 'C0R_NUMDA' )[ 1 ]
		nPadR2	:=	TamSx3( 'C0R_CODDA' )[ 1 ]

		lColumnPos := TafColumnPos('C0R_CODOBR')
		if lColumnPos
			nPadR3	:=	TamSx3( 'C0R_CODOBR' )[ 1 ]
		endif

		//Verifico se foi enviada a chave completa para definir a chave de busca da informação
		if Valtype( x3 ) <> "U" .and. lColumnPos
			nOrd := 7
		Else
			nOrd := 5
		EndIf

	ElseIf cAlias == 'C0A'
		nPadR1	:=	TamSx3( 'C0A_CODIGO' )[ 1 ]
		nPadR2	:=	TamSx3( 'C0A_EXNCM' )[ 1 ]
		nOrd	:=	1

	ElseIf cAlias == 'C20'
		nPadR1	:=	TamSx3( 'C20_CODMOD' )[ 1 ]
		nPadR2	:=	TamSx3( 'C20_SERIE' )[ 1 ]
		nPadR3	:=	TamSx3( 'C20_SUBSER' )[ 1 ]
		nPadR4	:=	TamSx3( 'C20_NUMDOC' )[ 1 ]
		nPadR5	:=	TamSx3( 'C20_DTDOC' )[ 1 ]
		nPadR6	:=	TamSx3( 'C20_CODPAR' )[ 1 ]

		if cStr08 == 'REINF'
			nPadR7	:=	TamSx3( 'C20_INDOPE' )[ 1 ]
		endif
		nOrd	:=	5
	ElseIf cAlias == "T9C"
		nPadR1	:=	TamSx3("T9C_TPINSC")[1]
		nPadR2	:=	TamSx3("T9C_NRINSC")[1]
		nOrd	:=	3
	ElseIf cAlias == "V3R"
		nPadR1	:=	TamSx3("V3R_CPF")[1]
		nPadR2	:=	TamSx3("V3R_ID")[1]
		nOrd	:=	3

		If cStr02 == "V85" .Or. cStr02 == "V95"
			x2 := V3U->V3U_IDPART
		ElseIf 	cStr02 == "V84" .Or. cStr02 == "V94"
			x2 := C20->C20_CODPAR
		ElseIf 	cStr02 == "V83" .Or. cStr02 == "V96"
			x2 := LEM->LEM_IDPART
	EndIf
	EndIf


//Busca especifica por tabela ou genérica via Posicione conforme definições do nOrd e nPadR* (verificar o ultimo else)
	If cAlias == "C20"

		//Tratamento para o registro T154, se não for enviado os campos referentes ao documento original
		//as variaveis tem que ser limpas para não acusar erro de registro não encontrado.
		//Isso acontece por que a chave da nota usa os campos de participante e natureza que podem estar
		//preenchido para a fatura, neste caso só deve ser feito o seek no documento original caso o usuário
		//tenha informado os campos para o mesmo.
		If cStr08 == 'REINF' .And. Empty(AllTrim(x1+x2+x3+x4))
			xA := "";xB := "";xC := "";xD := "";xE := "";xF := "";xG := "";xH := ""
		ElseIf cStr08 == "IDRMD" .and. Empty( x2 + x3 + x4 + x5 + x6 + x7 )
			//limpo as variaveis que controlam a chave concatenada para que não ocorra erro de chave estrangeira
			//ao retornar ao fluxo do motor - TAFGrvDados()
			xA := ""; xB := ""; xC := ""; xD := ""; xE := ""; xF := ""; xG := ""; xH := ""
			cRetorno := ""
		Else
			if cStr08 == 'REINF'
				cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x7 , nPadR7 ) + PadR( x1 , nPadR1 )  + PadR( x2 , nPadR2 ) + PadR( x3 , nPadR3 ) + PadR( x4 , nPadR4 ) + PadR( x5 , nPadR5 ) + PadR( x6 , nPadR6 )  , cAlias + '_CHVNF' )
			else
				cRetorno   := Posicione( cAlias , nOrd , xFilial( cAlias ) + x1 + PadR( x2, nPadR1 ) + PadR( x3, nPadR2 ) + PadR( x4, nPadR3 ) + PadR( x5, nPadR4 ) + x6 +  x7, cAlias + "_CHVNF" )
			endif
		EndIf

	ElseIf cAlias == 'C0R'
		//Verifico se foi enviada a chave completa para definir a chave de busca da informação
		if Valtype( x3 ) <> "U"
			cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x2 , nPadR2 ) + PadR( x1 , nPadR1 ) + PadR( x3 , nPadR3 ) , cAlias + '_ID' )
		else
			cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x2 , nPadR1 ) + PadR( x1 , nPadR2 ) , cAlias + '_ID' )
		endif

	elseif cAlias == 'C07'

		//C07 -> Tabela de Municipios
		//Neste caso o xA precisa ser convertido para o ID da UF ( tabela C09 ) e o xB contem o codigo de municpio
		//Somente efetuou a busca se o codigo de municipio for enviado, pois ele nao eh obrigatorio mas a UF é.
		if !empty( cStr02 )

			nOrd	:=	1 //FILIAL + UF + CODIGO

			nPadR1	:=	TamSx3( 'C07_UF' )[ 1 ] //Tamanho do campo de UF na tabela de municipios
			x1		:=	XFUNCh2ID( x1 , 'C09' , 1 , , .T. ) //Converto a UF enviada para o ID correspondente da tabela C09

			nPadR2	:=	TamSx3( 'C07_CODIGO' )[ 1 ] //Tamanho do campo de Codigo do Municipio na tabela de municipios

			cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x1 , nPadR1 ) + PadR( x2 , nPadR2 ) , cAlias + '_ID' )
		else
			//limpo as variaveis que controlam a chave concatenada para que não ocorra erro de chave estrangeira
			//ao retornar ao fluxo do motor - TAFGrvDados()
			xA := ""; xB := ""
			cRetorno := ""
		endif

	Elseif cAlias == 'C35'

		if cStr08 == "IDMINC"
			//apenas prossigo se um dos campos necessários na montagem da chave tiver valor
			if ( val( cStr03 ) + val( cStr04 ) + val( cStr05 ) ) > 0

				do case
				case val( cStr03 ) > 0 //campo 15 do layout t015ae - VLR_ISENTO
					cStrAux1 := '1'
				case val( cStr04 ) > 0 //campo 16 do layout t015ae - VLR_OUTROS
					cStrAux1 := '2'
				case val( cStr05 ) > 0 //campo 17 do layout t015ae - VALOR_NT
					cStrAux1 := '3'
				end case

				cStrAux1 := XFUNCh2ID( cStr02 , 'C3S' , 1 ,, .T. ) + cStrAux1 + cStr01 + AllTrim( xFunUFID() )

				if len( cStrAux1 ) > 12
					cRetorno := XFunCh2Id( cStrAux1 , 'CWZ' , 2 ,, .T. )
				endif
			endif
		endif
	Elseif  cAlias == "T5L"
		cIdC1G := XFUNCh2ID(x2,'C1G',1, ,.T.)

		If !Empty(cIdC1G)

			nPadR1 := TamSx3("T5L_CODSUS")[1]
			nPadR2 := TamSx3("C1G_NUMPRO")[1]

			cCodSusT5L := PadR(x1, nPadR1)
			cNumProCG1 := PadR(x2, nPadR2)

			cVersaoC1G := Posicione("C1G", 1, xFilial("C1G")+cNumProCG1, "C1G_VERSAO")
			cCodSusT5L := Posicione("T5L", 1, xFilial("T5L")+cIdC1G+cVersaoC1G+cCodSusT5L, "T5L_CODSUS")
			If !Empty(cCodSusT5L)
				cRetorno := cIdC1G+cVersaoC1G+cCodSusT5L //T5L->(T5L_ID+T5L_VERSAO+T5L_CODSUS)
			EndIf
		EndIf
	Elseif  cAlias == "V3Z"
		cIdC1G := XFUNCh2ID(x2,'C1G',1, ,.T.)
	Elseif cAlias == "V3R"	
		cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x1 , nPadR1 ) + PadR( x2 , nPadR2 ) + cAtivo , cAlias + '_CODIGO' )
	Else
		cRetorno	:=	Posicione( cAlias , nOrd , xFilial( cAlias ) + PadR( x1 , nPadR1 ) + PadR( x2 , nPadR2 ) + cAtivo , cAlias + '_ID' )
	EndIf

Return ( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunCd2ID
Funcao utilizada nos layouts de importacao do Mile para que os campos
informados sejam convertidos para o ID, sendo possivel utilizar mais
de um campo de arquivo TXT para montar a chave de busca do ID na
tabela

@Param 	aDados		-	Posicao [1] - Alias da Tabela de Busca
                        Posicao [2] - Indice de busca na Tabela
                        Posicao [3] - Chave de Busca
                        Posicao [4] - Informa se deve-se realizar o seek apenas
                        			  com o valor passados na posicao [3] ou
                        			  se deve concatenar esse conteudo com o
                        			  da tabela processada anteriormente

@return	cRet	- 	Conteudo do campo ID

@author Rodrigo Aguilar
@since 23/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunCd2ID( aDados )

	Local cRet 			:= ""
	Local cRet2			:= ""
	Local nlI  		 	:= 0
	Local lUsaChvAnt 	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executo cada tabela que foi passada no CodeBlock dos Layouts Mile ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlI := 1 To Len( aDados )

		DbSelectArea( aDados[nlI][1] )
		(aDados[nlI][1])->( DbSetOrder( aDados[nlI][2] ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao foi passada a 4 posicao do array assumo que eh um seek simples que devo ³
		//³realizar na tabela                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aDados[nlI] ) <= 3
			lUsaChvAnt := .T.
		Else
			lUsaChvAnt := aDados[nlI][4]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja a primeira tabela do CodeBlock ou seja apenas um seek simples busco³
		//³o id conforme abaixo                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aDados[nlI][3]	:=	Iif( Empty( aDados[nlI][3] ) , ' ' , aDados[nlI][3] )	//Tratamento para quando vir VAZIO no arquivo, ele nao ache o primeiro registro no SEEK soh com a filial

		If Empty( cRet ) .Or. !lUsaChvAnt
			If (aDados[nlI][1])->( MsSeek( xFilial( aDados[nlI][1] ) + aDados[nlI][3] ) )
				cRet += ( aDados[nlI][1])->&(aDados[nlI][1] + "_ID" )
			Else
				cRet2	:=	aDados[nlI][3]
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso contrario eu realizo o seek composto utilizando o processamento³
			//³da tabela anterior                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			If (aDados[nlI][1])->( MsSeek( xFilial( aDados[nlI][1] ) + cRet + aDados[nlI][3] ) )
				cRet := ( aDados[nlI][1])->&(aDados[nlI][1] + "_ID" )
			Else
				cRet :=	 aDados[nlI][3]
				If Type( "GB_MEMVAR2" ) != "U"
					GB_MEMVAR2	:=	.F.
				EndIf
			EndIf
		EndIf
	Next

	If Empty( cRet )
		cRet	:=	cRet2
	EndIf

Return ( cRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunTelaFil
Troca tela de selecao de filiais

@Param 	lMostraTela	-	Mostra tela de aviso no caso de inconsistencia
		aListaFil	-	Array com a selecao das filiais
		lChkUser	-	Indica se verifica permissoes do usuario
		lSped		-	Gera tela para Sped Fiscal
		lEmpr		-	Indica se é para apresentar apenas as empresas para seleção
		lContEmp	-	Indica se apresenta todas as empresas do grupo ou apenas os da mesma empresa
		lCancSel    -   Indica se cancela a chamada da tela ao clicar em 'Sair' já que o retorno é um array
		cRotina		- 	Indica a rotina que deve checar se o usuário corrente tem acesso na filial

@return aFilsCalc - Retorna o vetor de filiais selecionadas

@author Danilo L. Zanaga
@since 23/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunTelaFil(lMostratela,aListaFil,lChkUser,lGiaSP,lEmpr,lContEmp,lCancSel,lBaseCNPJ,cRotina,aCNPJIE)

	Local aFilsCalc		:= {}

	// Variaveis utilizadas na selecao de categorias
	Local oChkQual,lQual,oQual,cVarQ

	// Carrega bitmaps
	Local oOk       	:= LoadBitmap( GetResources(), "LBOK")
	Local oNo       	:= LoadBitmap( GetResources(), "LBNO")

	// Variaveis utilizadas para lista de filiais
	Local nx        	:= 0
	Local nAchou    	:= 0
	Local lIsBlind  	:= IsBlind()

	Local aAreaSM0		:= SM0->(GetArea())
	Local aSM0      	:= FWLoadSM0(.T.,,.T.)
	Local cGrpEmp  		:= ""
	Local cTitulo		:= STR0003
	Local cTitulo2		:= STR0004
	Local cBaseCNPJ		:= Left(AllTrim(Posicione("SM0",1,cEmpAnt+cFilAnt, "M0_CGC")),8)
	Local aProdRural 	:= {}

	Default lMostraTela	:= .F.
	Default aListaFil	:= {{.T., cFilAnt}}
	Default lChkUser	:= .T.
	Default lGiaSP		:= .F.
	Default lEmpr		:= .F.
	Default lContEmp	:= .T.
	Default lCancSel	:= .F.
	Default lBaseCNPJ	:= .F.
	Default cRotina		:= ""
	Default aCNPJIE 	:= {}

//----------------------------------------------------------------------------
//³ Carrega filiais da empresa com a mesma base do CNPJ  ou de Produtor Rural|
//----------------------------------------------------------------------------
	If lBaseCNPJ

		If __aSM0BaseCNPJ == Nil .Or. (Len(__aSM0BaseCNPJ) > 0 .And. cBaseCNPJ <> Alltrim(Left(__aSM0BaseCNPJ[1][SM0_CGC],8)))
			__aSM0BaseCNPJ := {}
			FWMsgRun(,{|oMsgRun|loadSM0BaseCNPJ(aSM0,cBaseCNPJ,lIsBlind,lChkUser,oMsgRun)},"Seleção de Filiais","Carregando arquivo de empresas ...")
		EndIf

		// Verifica se a Matriz Corrente é Produtor Rural
		aProdRural	:= VProdRural(aFilsCalc,lChkUser)

		If !(aProdRural[1])

			For nX := 1 To Len(__aSM0BaseCNPJ)

				//----------------------------------------------------------
				// Posiciona na SM0 para obter os campos M0_INSC e M0_INSCM
				//----------------------------------------------------------
				SM0->(dBGoTo(__aSM0BaseCNPJ[nX][SM0_RECNO]))
				AAdd( aFilsCalc, {.F., __aSM0BaseCNPJ[nX][SM0_CODFIL], __aSM0BaseCNPJ[nX][SM0_NOMRED], __aSM0BaseCNPJ[nX][SM0_CGC], SM0->M0_INSC, SM0->M0_INSCM} )

			Next nX

			cTitulo	:=	"Seleção da(s) Empresa(s) com a mesma raiz de CNPJ"
			cTitulo2	:=	"Marque a(s) Empresa(s) a serem considerada(s) no processamento"
		Else
			cTitulo	:=	"Seleção da(s) Empresa(s) com o mesmo CPF de Produtor Rural"
			cTitulo2	:=	"Marque a(s) Empresa(s) a serem considerada(s) no processamento"
		EndIf

	ElseIf !lEmpr
//--------------------------------------------------------------
// Carrega filiais da empresa corrente  para Versão Protheus 11 |
//--------------------------------------------------------------
		aEval(aSM0,	{ |x|	If(x[SM0_GRPEMP] == cEmpAnt .And.;
			Iif (!lContEmp ,x[SM0_EMPRESA] == FWCompany(),.T.) .And.;
			(!lChkUser .Or. x[SM0_USEROK].Or. lIsBlind) .And.;
			(x[SM0_EMPOK] .Or. lIsBlind),;
			aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
			Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM")}),;
			NIL)})

	Else
		aEval( aSM0, { |x| If((!lChkUser .Or. x[SM0_USEROK]) .And. (x[SM0_EMPOK] .Or. lIsBlind),Aadd(aFilsCalc,{.F.,x[SM0_GRPEMP],x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC]}),) } )
		For nX := 1 To Len(aFilsCalc)
			If nX>Len(aFilsCalc)
				Exit
			Else
				If cGrpEmp<>aFilsCalc[nX,2]
					cGrpEmp	:=	aFilsCalc[nX,2]
				Else
					aDel(aFilsCalc,nX)
					aSize(aFilsCalc,Len(aFilsCalc)-1)
					nX := nX - 1
				EndIf
			EndIf
		Next nX
		cTitulo	:=	"Seleção do(s) Grupo(s) de Empresa(s)"
		cTitulo2	:=	"Marque o(s) Grupo(s) de Empresa(s) a serem considerada(s) no processamento"
	EndIf

	RestArea(aAreaSM0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para selecao de filiais                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMostraTela
		DEFINE MSDIALOG oDlgTel TITLE OemToAnsi(cTitulo) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
		oDlgTel:lEscClose := .F.

		@ 05,15 TO 125,300 LABEL OemToAnsi(cTitulo2) OF oDlgTel  PIXEL
		@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0005) SIZE 50, 10 OF oDlgTel PIXEL ON CLICK (aFilsCalc:=xFunFClTroca(0,aFilsCalc,lGiaSP,,cRotina,,aCNPJIE), oQual:Refresh(.F.))

		If !lEmpr

			If lGiaSP
				@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0002),OemToAnsi(STR0006),STR0190,STR0191 SIZE 273,090 ON DBLCLICK (aFilsCalc:=xFunFClTroca(oQual:nAt,aFilsCalc,lGiaSP,,cRotina,,aCNPJIE),oQual:Refresh()) NoScroll OF oDlgTel PIXEL
			Else
				@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0002),OemToAnsi(STR0006) SIZE 273,090 ON DBLCLICK (aFilsCalc:=xFunFClTroca(oQual:nAt,aFilsCalc,lGiaSP,,cRotina,,aCNPJIE),oQual:Refresh()) NoScroll OF oDlgTel PIXEL
			Endif
		Else
			@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi("Grp.Empr.") SIZE 273,090 ON DBLCLICK (aFilsCalc:=xFunFClTroca(oQual:nAt,aFilsCalc,lGiaSP,,cRotina,,aCNPJIE),oQual:Refresh()) NoScroll OF oDlgTel PIXEL
		EndIf

		oQual:SetArray(aFilsCalc)
		oQual:bLine := { || {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],aFilsCalc[oQual:nAt,4],aFilsCalc[oQual:nAt,5]}}
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(xFunFCalOk(aFilsCalc,.T.,.T.,lEmpr,cRotina,aCNPJIE),oDlgTel:End(),) ENABLE OF oDlgTel
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(xFunFCalOk(aFilsCalc,.F.,.T.,lEmpr,cRotina,aCNPJIE),(lCancSel:= .T.,oDlgTel:End()),) ENABLE OF oDlgTel
		ACTIVATE MSDIALOG oDlgTel CENTERED
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida lista de filiais passada como parametro               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		// Checa parametros enviados
		For nx:=1 to Len(aListaFil)
			nAchou:=ASCAN(aFilsCalc,{|x| x[2] == aListaFil[nx,2]})
			If nAchou > 0
				aFilsCalc[nAchou,1]:=.T.
			EndIf
		Next nx
		// Valida e assume somente filial corrente em caso de problema
		If !MtFCalOk(aFilsCalc,.T.,.F.)
			For nx:=1 to Len(aFilsCalc)
				// Adiciona filial corrente
				aFilsCalc[nx,1]:=(aFilsCalc[nx,2]==cFilAnt)
			Next nx
		EndIf
	EndIf

Return aFilsCalc

//-------------------------------------------------------------------
/*/{Protheus.doc} loadSM0BaseCNPJ
Realiza cache das filias com a mesma raiz de CNPJ  

@Param 	aSM0		-	Array contendo as empresas/filias do SM0
		cBaseCNPJ	-	Base de CNPJ da empresa logada
		lIsBlind	-   Indica que a rotina está sendo executada em background
		lChkUser	-	Indica se verifica permissoes do usuario
		oMsg		-	Objeto FWMsgRun

@return Nil

@author Evandro dos Santos Oliveira Teixeira
@since 19/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function loadSM0BaseCNPJ(aSM0,cBaseCNPJ,lIsBlind,lChkUser,oMsg)

	Local nX := 0
	Local nPosGrp := 0
	Local aGrpSameRoot := {}

	Local cGrpCompany 	:= FWGrpCompany()


	If __aSM0BaseCNPJ == Nil
		__aSM0BaseCNPJ := {}
	EndIf

	For nX := 1 To Len(aSM0)

		If aSM0[nX][SM0_GRPEMP] == cGrpCompany
			IncMessagens(oMsg,"Carregando empresa " + aSM0[nX][SM0_GRPEMP]  + " filial " + aSM0[nX][SM0_CODFIL])

			//-------------------------------------
			// Desconsidera Empresa nao autorizada
			//-------------------------------------
			If !lIsBlind .And. !aSM0[nX][SM0_EMPOK]
				Loop
			EndIf

			//---------------------------------------------------
			// Desconsidera Filiais que o usuario nao tem acesso
			//---------------------------------------------------
			If lChkUser .And. !lIsBlind .And. !aSM0[nX][SM0_USEROK]
				Loop
			EndIf

		EndIf


		If cBaseCNPJ == Alltrim(Left(aSM0[nX][SM0_CGC],8)) //CNPJ é igual

			If aSM0[nX][SM0_GRPEMP] != cEmpAnt // Grupo é diferente

				If Len(aGrpSameRoot) == 0
					aAdd(aGrpSameRoot,aSM0[nX][SM0_GRPEMP])
					If !isShareCompany(cEmpAnt,aSM0[nX][SM0_GRPEMP])
						Loop
					EndIf
				Else

					nPosGrp := aScan(aGrpSameRoot,{|grp|grp == aSM0[nX][SM0_GRPEMP]})
					If nPosGrp == 0
						aAdd(aGrpSameRoot,aSM0[nX][SM0_GRPEMP])
						If !isShareCompany(cEmpAnt,aSM0[nX][SM0_GRPEMP])
							Loop
						EndIf
					EndIf
				EndIf
			EndIf

			aAdd(__aSM0BaseCNPJ,aSM0[nX])
		EndIf


	Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IncMessagens
Inclui mensagem e força a atualização do objeto FwMsgRun 

@Param 	oMsgRun	-	Objeto FWMsgRun
		cMsg	-	Mensagem a ser exibida

@return Nil

@author Evandro dos Santos Oliveira Teixeira
@since 19/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncMessagens(oMsgRun,cMsg)

	oMsgRun:cCaption := cMsg
	ProcessMessages()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} isShareCompany
Informa se alguma tabela do escopo e-Social está com o grupo de 
empresa compartilhado.

@Param 	cGrpLogged	-	Grupo de Empresa Logado (Posicionado)
		cGrpSameRoot -	Grupo de empresa que possui filiais com base
		de cnpj iguais a empresa logada.

@return lShareCompany - Determina se o grupo de empresa comparado (cGrpSameRoot)
		está compartilhado, ou seja a mesma possui alguma tabela relacionada 
		ao e-social com o X2_ARQUIVO apontando para a tabela da filial logada. 

@author Evandro dos Santos Oliveira Teixeira
@since 19/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function isShareCompany(cGrpLogged,cGrpSameRoot)

	Local lShareCompany := .F.

	lShareCompany := StartJob("TAFCSX2Share", GetEnvServer(),.T.,cGrpLogged,cGrpSameRoot)

Return lShareCompany

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCSX2Share
Conecta-se a um determinado grupo de empresa para verificar se o mesmo
está compartilhado.

@Param 	cGrpLogged	-	Grupo de Empresa Logado (Posicionado)
		cGrpCompany -	Grupo de empresa que possui filiais com base
		de cnpj iguais a empresa logada.

@return isShare - Determina se o grupo de empresa comparado (cGrpSameRoot)
		está compartilhado, ou seja a mesma possui alguma tabela relacionada 
		ao e-social com o X2_ARQUIVO apontando para a tabela da filial logada. 

@author Evandro dos Santos Oliveira Teixeira
@since 19/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFCSX2Share(cGrpLogged,cGrpCompany)

	Local isShare := .F.
	Local cAliasEvent := ""
	Local cTypeEvent := ""
	Local cNameFile := ""
	Local nX := 0

	Local lCheckShare	:= .F.

	RpcSetType(3)
	RpcSetEnv(cGrpCompany,,,,"TAF","TAFXFUN",,,,.T.,)

	lCheckShare	:= SuperGetMv('MV_TAFGSH',.F.,.F.)


	If lCheckShare //Quando foi informado que o dicionário é compartilhado, eu não faço a verificação abaixo.
		isShare := .T.
	Else

		aRotinas := TAFRotinas(,,.T.,2)

		For nX := 1 To Len(aRotinas)

			cAliasEvent  := aRotinas[nX][3]
			cTypeEvent 	 := AllTrim(aRotinas[nX][12])

			If cTypeEvent != 'T' .And. !Empty(cAliasEvent)

				cNameFile := cAliasEvent + cGrpLogged + "0" //Exemplo: C1E010

				If FwSX2Util():SeekX2File(cNameFile)
					isShare := .T.
					Exit
				EndIf

			EndIf

		Next nX
	EndIf


Return isShare

//-------------------------------------------------------------------------------
/*/{Protheus.doc} xFunFCalOk
Verifica marcacao das filiais para calculo por filial

@Param 	aFilsCalc		-	Array com a selecao das filiais
		lValidaArray	-	Valida array de filiais (.t. se ok e .f. se cancel)
		lMostraTela 	-	Mostra tela de aviso no caso de inconsistencia
		lEmpr			-	Indica se está exibindo apenas empresas na seleção

@return lRet - Flag de retorno (.T. ou .F., marcacao ok ou nao)

@author Danilo L. Zanaga
@since 23/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------------------
Function xFunFCalOk(aFilsCalc,lValidaArray,lMostraTela,lEmpr,cRotina,aCNPJIE)
	Local lRet			:= .F.
	Local nx			:= 0
	Local cFilBkp		:= cFilAnt
	Local lExit         := .F.
	Local lIE		    := .F.
	Local lCNPJ         := .F.

	Default lMostraTela := .T.
	Default lEmpr 		:= .F.
	Default cRotina		:= ""
	Default aCNPJIE     := {} //aglutinacao nova gia sp

	If !lValidaArray
		aFilsCalc := {}
		lRet := .T.
	Else
		// Checa marcacoes efetuadas
		For nx:=1 To Len(aFilsCalc)
			If aFilsCalc[nx,1]
				If GetVersao(.f.) < '12'
					lRet:=.T.
				Else
					cFilAnt	:= aFilsCalc[nx,2]
					If Empty(cRotina) .OR. MPUserHasAccess(cRotina, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )
						lRet:=.T.
					Else
						aFilsCalc[nx,1]	:= .F.
					EndIf
					cFilAnt	:= cFilBkp
				EndIf
			EndIf
		Next nx
		// Checa se existe alguma filial marcada na confirmacao
		If !lRet
			If lMostraTela
				If lEmpr
					Alert(OemToAnsi(STR0098)) // "Deve ser selecionada ao menos uma empresa para o processamento."
				Else
					Alert(OemToAnsi(STR0007)) // "Deve ser selecionada ao menos uma filial para o processamento."
				EndIf
			EndIf
		EndIf
	EndIf

	lTAFXGSP := IsInCallStack("TAFXGSP")
	lTAFRGSP := Upper(Alltrim(FunName())) == "TAFRGSP"

	//validacao geral com aglutinacao + inverte selecao
	If lRet .And. (lTAFRGSP .Or. (lTAFXGSP .And. len(aCNPJIE) == 1 .And. (aCNPJIE[1][1] .Or. aCNPJIE[1][2])) )
		if lTAFXGSP
			//aCNPJIE ja validado
			lCNPJ := aCNPJIE[1][1] //aglt cnpj
			lIE   := aCNPJIE[1][2] //aglt IE
		elseif lTAFRGSP
			if MV_PAR03 == 2 .And. MV_PAR04 == 2 //Seleciona Filiais? 2-Sim e Aglutina? 2-CNPJ+IE
				lCNPJ := .T.
				lIE   := .T.
			endif
		endif

		aStruct := {}
		// Checa marcacoes efetuadas
		For nx := 1 To Len(aFilsCalc)
			If aFilsCalc[nx,1]
				If len(aStruct) == 0
					aadd( aStruct, { aFilsCalc[nx][4], aFilsCalc[nx][5] } ) //cnpj e ie
				else
					cCnpj := iif( lCNPJ, aFilsCalc[nx][4], "" )
					cIE   := iif( lIE  , aFilsCalc[nx][5], "" )

					lFoundCnpj := aScan( aStruct, { |x| x[1] == cCnpj } ) == 0
					lFoundIE   := aScan( aStruct, { |x| x[2] == cIE } ) == 0

					if lTAFXGSP
						if !Empty(cCnpj) .And. !Empty(cIE) //valida aglutinacao por CNPJ e IE
							if lFoundCnpj .Or. lFoundIE
								lExit := .T.
								Help(NIL, NIL, STR0184, NIL, STR0185, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0186}) //"Validação"##"A aglutinação por CNPJ+IE foi selecionado."##"Selecione apenas Filiais com o mesmo CNPJ e IE."
								exit
							endif
						elseif !Empty(cCnpj) .And. Empty(cIE) //valida aglutinacao apenas por CNPJ
							if lFoundCnpj
								lExit := .T.
								Help(NIL, NIL, STR0184, NIL, STR0187, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0188}) //"Validação"##"A aglutinação por CNPJ foi selecionado."##"Selecione apenas Filiais com o mesmo CNPJ."
								exit
							endif
						endif
					endif

					if lTAFRGSP .And. lCNPJ .And. lIE //regra apartada pois o sigamat pode estar com o IE vazio
						if lFoundCnpj .Or. lFoundIE //Se o CNPJ ou IE for diferente apresenta mensagem de inconsistencia
							lExit := .T.
							Help(NIL, NIL, STR0184, NIL, STR0185, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0186}) //"Validação"##"A aglutinação por CNPJ+IE foi selecionado."##"Selecione apenas Filiais com o mesmo CNPJ e IE."
							exit
						endif
					endif
				Endif
			EndIf
		Next nx
		//Caso exista alguma inconsistencia nao continua
		if lExit
			lRet := .F.
		Endif
	Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunFClTroca
Troca marcador entre x e branco

@Param 	nIt		-	Numero do item do Array
		aArray	-	Vetor com a lista de filiais

@return aArray - Retorna o vetor de filiais

@author Danilo L. Zanaga
@since 23/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunFClTroca(nIt,aArray,lSped,cVersion,cRotina,lRecursiva,aCNPJIE)

	Local nX 			:= 1
	Local nCont 		:= 0
	Local cFilBkp		:= cFilAnt
	Local nIndAux		:= 0

	Default lSped 		:= .F.
	Default cVersion	:= ""
	Default cRotina		:= ""
	Default lRecursiva	:= .F.
	Default aCNPJIE 	:= {}

	If nIt == 0	//TODOS
		For nIndAux := 1 to Len(aArray)
			xFunFClTroca(nIndAux,aArray,lSped,cVersion,cRotina,.T.)
		Next nIndAux
	Elseif valtype( aCNPJIE ) == 'A' .And. len( aCNPJIE ) == 1 .And. ( aCNPJIE[1][1] .Or. aCNPJIE[1][2] )
		xFunAglt( aCNPJIE, nIt, @aArray )
	Else
		aArray[nIt,1] := !aArray[nIt,1]

		If aArray[nIt,1]
			cFilAnt	:= aArray[nIt,2]
			If !(GetVersao(.f.) < '12') .and. !Empty(cRotina) .AND. !MPUserHasAccess(cRotina, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )
				aArray[nIt,1]	:= .F.
				//"Acesso negado!"- "O usuário corrente não possui privilégios de acesso a rotina TAFMONTES na filial selecionada." - "Verifique as configurações dos privilégios de acesso no configurador."
				Help(NIL, NIL, STR0174, NIL, StrTran(STR0175,"selecionada",cFilAnt), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0176})
			EndIf
			cFilAnt	:= cFilBkp
		EndIf
	EndIf

	If !lRecursiva
		If cVersion >= '0003'
			For nX := 1 to Len(aArray)
				If aArray[nX][1]
					nCont++
				EndIf
				If nCont > 2
					MsgAlert(STR0123)//"A partir do leiaute 0003 o ECF passou aceitar no máximo duas ocorrências para o registro 0930. Selecione no máximo 2 contadores."
					aArray[nIt,1] := !aArray[nIt,1]
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

Return aArray
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNInf
Funcao utilizada para validar o valor digitado no campo, condicionado a outro.
Exemplo: Somente posso informar a DEDUCAO se houver valor de Sld Devedor

@param	cCmpModel - Campo a ser validado com o campo editado.

@return lRet -  .T. -> Valido
				.F. -> NAO Valido

@author Gustavo G. Rueda
@since 13/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNInf( cCmpModel )
	Local	lRet	:=	.F.
	Local	cCampo		:=	ReadVar()

	If ( lRet := FWFldGet( cCmpModel ) == 0 )
		Help( ,,"TAFVLRINF001",,SubStr( cCampo , 4 ) , 1 , 0 )
	EndIf

Return !lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAviso
Funcao utilizada para montar tela de aviso com algumas opcoes e botoes personalizados

@param	cCaption - Caption da tela
		cMensagem - Mensagem a ser exibida
		aBotoes   - Label dos botoes
		nSize     - Tamanho da linha
		cCaption2 - Caption da imagem
		cBitmap   - Imagem
		lEdit     - Flag de edicao do campo da tela. .T. -> Edita, .F. não edita

@return nOpcAviso- Opcao selecionada conforme sequencia de botoes passada ( aBotoes )
				.F. -> NAO Valido

@author Gustavo G. Rueda
@since 13/07/2012
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFAviso( cCaption , cMensagem , aBotoes , nSize , cCaption2 , cBitmap , lEdit )
	Local ny        := 0
	Local nx        := 0
	Local aSize  := {  {134,304,35,155,35,113,51, 44, 150 },; // Tamanho 1
	{134,450,35,155,35,185,51, 44, 210 },; // Tamanho 2
	{227,450,35,120,77,185,99, 44, 210 },; // Tamanho 3
	{300,500,35,120,110,205,130, 44, 210 } } // Tamanho 4
	Local nLinha    := 0
	Local cMsgButton:= ""
	Local oGet, oBt
	Local aTamButt	:= {032,012}

	Private oDlgAviso
	Private nOpcAviso := 0

	DEFAULT lEdit := .F.

	If lEdit
		nSize := 4
	EndIf

	cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)

	If nSize == Nil
		//+--------------------------------------------------------------+
		//| Verifica o numero de botoes Max. 5 e o tamanho da Msg.       |
		//+--------------------------------------------------------------+
		If  Len(aBotoes) > 3
			If Len(cMensagem) > 286
				nSize := 3
			Else
				nSize := 2
			EndIf
		Else
			Do Case
			Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
				nSize := 2
			Case Len(cMensagem) >= 250
				nSize := 3
			OtherWise
				nSize := 1
			EndCase
		EndIf
	EndIf
	If nSize <= 4
		nLinha := nSize
	Else
		nLinha := 4
	EndIf

	oDlgAviso := tDialog():New(000,000,aSize[nLinha][1],aSize[nLinha][2] ,cCaption,,,,DS_MODALFRAME,CLR_BLUE,CLR_WHITE,,,.T.)
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//@ 000,001 BITMAP oImg RESOURCE "TafSmallApp_logo_mini.png" oF oDlgAviso SIZE 43,35 NOBORDER WHEN .F. PIXEL ADJUST .T.

	oImg := TBitmap():New(000, 001, 043, 035, "TafSmallApp_logo_mini.png", Nil, .T., oDlgAviso,;
		Nil, Nil, .F., .F., Nil, Nil, .F., Nil, .T., Nil, .F.)

	@ 011,aSize[nLinha][08] TO 013,aSize[nLinha][09] OF oDlgAviso PIXEL

	If cBitmap <> Nil
		@ 002, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
		@ 003 ,50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 150 ,9 FONT oBold
	Else
		@ 003 ,aSize[nLinha][08]  SAY cCaption2 Of oDlgAviso PIXEL SIZE 150 ,9 FONT oBold
	EndIf
	If nSize < 3
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	ElseIf nSize == 3
		If !lEdit
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
		Else
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] MEMO
		EndIf
	ElseIf nSize == 4
		If !lEdit
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
		Else
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] MEMO
		EndIf
	EndIf
	If Len(aBotoes) > 1
		TButton():New(1000,1000," ",oDlgAviso,{||Nil},aTamButt[01],aTamButt[02],,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	EndIf
	ny := (aSize[nLinha][2]/2)-36
	For nx:=1 to Len(aBotoes)
		cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
		cMsgButton:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )
		oBt	:=	TButton():New(aSize[nLinha][7],ny,cMsgButton, oDlgAviso,bAction,aTamButt[01],aTamButt[02],,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		ny -= 35
	Next nx

	oDlgAviso:Activate(,,,.T.,/*valid*/,,/*On Init*/)

Return (nOpcAviso)
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldCfo
Funcao utilizada para validar o CFOP correto ao tipo de documento(123 para Entrada ou 567 para Saida)

@param	cCampo - Campo do MODEL que identifica a operacao

@return lRet  - .T. -> Validacao OK
				  .F. -> NAO Valido

@author Gustavo G. Rueda
@since 13/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNVldCfo( cCampo )
	Local	lRet	:=	.T.
	Local	cRVar	:=	SubStr( ReadVar() , 4 )
	Local	cCmpVar	:=	FWFldGet( cRVar )

	Default	cCampo	:=	'C20_INDOPE'

	If Empty( cCodigo := XFUNID2Cd( cCmpVar , 'C0Y' ) )
		cCodigo	:=	cCmpVar
	EndIf
	cCodigo	:=	Left( cCodigo , 1 )

	If FWFldGet( cCampo ) == '0' .And.;	//ENTRADA
		!cCodigo $ '123'
		lRet	:=	.F.

	ElseIf FWFldGet( cCampo ) == '1' .And.;	//SAIDA
		!cCodigo $ '567'
		lRet	:=	.F.

	EndIf

	If !lRet
		Help( ,, AllTrim( cRVar ) ,,, 1 , 0 )
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNNWFunc
Funcao generica utilizada para chamar outra funcao porem fazer um tratamento de FindFunction antes,
     de forma a nao causar erro por existir no dicionario e no RPO nao

@param	cFunc - Nome da Funcao a ser chamada
		x1 - 1. Parametro (Caso seja necessário na funcao a ser chamada)
		x2 - 2. Parametro (Caso seja necessário na funcao a ser chamada)
		x3 - 3. Parametro (Caso seja necessário na funcao a ser chamada)
		x4 - 4. Parametro (Caso seja necessário na funcao a ser chamada)
		x5 - 5. Parametro (Caso seja necessário na funcao a ser chamada)
		x6 - 6. Parametro (Caso seja necessário na funcao a ser chamada)
		x7 - 7. Parametro (Caso seja necessário na funcao a ser chamada)
		x8 - 8. Parametro (Caso seja necessário na funcao a ser chamada)
		x9 - 9. Parametro (Caso seja necessário na funcao a ser chamada)

@return lRet  - .T. -> Validacao OK
				  .F. -> NAO Valido


Obs:
Formato a ser utilizado: Iif(FindFunction('XFUNNWFunc'),XFUNNWFunc('XFUNVldCfo'),.T.)

@author Gustavo G. Rueda
@since 13/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFUNNWFunc( cFunc , x1 , x2 , x3 , x4 , x5 , x6 , x7 , x8 , x9 )

	If FindFunction( cFunc )
		Return &cFunc.( x1 , x2 , x3 , x4 , x5 , x6 , x7 , x8 , x9 )
	Else
		Return .T.
	EndIf
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNVldPJF
Funcao generica utilizada para efetuar validacao do numero de inscricao da pessoa JURIDICA/FISICA.
     Esta funcao deve ser chamada no valid dos campos de CNPJ/CPF dos cadastros.

@param	cCmpTpPess 	-> 	Refere-se ao campo do modelo que identifica o tipo de estabelecimento/pessoa.
						Geralmente 1=Fisica (CPF), 2=Juridica (CNPJ)
		nOpc			->	Opcao de chamada da funcao. 1=Tratamento para CPF e 2=Tratamento para CNPJ

@return lRet  - .T. -> Validacao OK
				  .F. -> NAO Valido

@author Gustavo G. Rueda
@since 18/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function XFUNVldPJF( cCmpTpPess , nOpc , lExstCmp )
	Local 	cCmp		:= 	ReadVar()
	Local	cAlias		:=	SubStr( cCmp, 4 , 3 )
	Local	lRet	:=	.T.

	Default	cCmpTpPess	:=	cAlias + '_TPESTA'
//Default	nOpc		:=	1
	Default lExstCmp	:= .T.
	If(Empty(nOpc))
		If !Empty(cCmpTpPess)
			nOpc:= Val(FWFLDGET( cCmpTpPess ))
		Else
			nOpc:= 1
		Endif
	Endif

	If lExstCmp .and. Empty( FWFLDGET( cCmpTpPess ) )
		lRet	:=	.F.
	Else
		If nOpc == 1 .and. NAOVAZIO()	//CPF
			If lExstCmp .and. FWFLDGET( cCmpTpPess ) == "2"
				lRet	:=	.F.

			ElseIf !CGC( &( cCmp ) ) .OR. len(M->(ALLTRIM(&( cCmp )))) <> 11
				lRet	:=	.F.

			EndIf

		ElseIf nOpc == 2 .and. NAOVAZIO()
			If lExstCmp .and. FWFLDGET( cCmpTpPess ) == "1"
				lRet	:=	.F.

			ElseIf !CGC( &( cCmp ) )	.OR. len(M->(ALLTRIM(&( cCmp )))) <> 14
				lRet	:=	.F.

			EndIf

		EndIf

	EndIf

	If !lRet
		Help( ,, AllTrim( SubStr( cCmp , 4 ) ) ,,, 1 , 0 )
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNMemVar
Funcao generica de validacao especifica utilizando variavel global definida no MILE.
	Utilizado para trocar o conteudo da variavel de memoria quando trato conversao.
	Por exemplo: No arquivo texto estah vindo um codigo da conta contabil com 60 caracteres, mais
	o campo que vai receber eh de 6 e refere-se ao ID. Para gravar este campo, efetuo uma busca no cadastro
	para recuperar o ID, caso nao exista a conta, nao serah encontrado o ID, retornando branco e dando
	uma mensagem incorreta. Neste caso, volto o conteudo guardado na variavel global e apresento o erro
	com o conteudo correto.

@param	Nil

@return lRet  - .T. -> Validacao OK
				  .F. -> NAO Valido

@author Gustavo G. Rueda
@since 18/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function XFUNMemVar()
	Local 	cCmp		:= 	ReadVar()
	Local	cCmp2		:=	SubStr( cCmp , 4 )
	Local	lRet		:=	.T.
	Local	cHelp		:=	AllTrim( cCmp2 )
	Local	cMens		:=	''
	Local	nLin		:=	1

//GB_MEMVAR -> Variavel global utilizada no MILE para guardar o conteudo de algum campo, para efetuar outras validacoes nao possiveis durante a importacao chamando um help especifico
	If Type( "GB_MEMVAR" ) != "U" .And. !Empty( GB_MEMVAR )

		If cCmp2 == 'C0Q_PLACA' .And.;
				!( IsAlpha( SubStr( GB_MEMVAR , 1 , 3 ) ) .And. IsDigit( SubStr( GB_MEMVAR , 4 , 4 ) ) )
			lRet		:=	.F.

		ElseIf cCmp2 == 'C58_NATREC' .And. Type( "GB_MEMVAR2" ) == "L" .And. !GB_MEMVAR2
			cHelp		:=	'TAFNATREC'
			lRet		:=	.F.

		ElseIf cCmp2 == 'C32_CODPAR' .And. Type( "lC32CodPar" ) == "L" .And. !lC32CodPar

			If Type( "GB_C32CPAR" ) != "U"
				nLin	:=	15
				cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_C32CPAR + '|' + CRLF + CRLF + CRLF
				lRet := .F.
			EndIf

		ElseIf cCmp2 == 'C38_CODPAR' .And. Type( "lC38CodPar" ) == "L" .And. !lC38CodPar

			If Type( "GB_C38CPAR" ) != "U"
				nLin	:=	15
				cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_C38CPAR + '|' + CRLF + CRLF + CRLF
				lRet := .F.
			EndIf

		ElseIf cCmp2 == 'C6W_NUMERO' .And. Type( "lC6WNumPrc" ) == "L" .And. !lC6WNumPrc

			If Type( "GB_C6WNPRC" ) != "U"
				nLin	:=	15
				cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_C6WNPRC + '|' + CRLF + CRLF + CRLF
				lRet := .F.
			EndIf

		ElseIf cCmp2 == 'C20_CODCTA' .And. Type( "lC20CodCta" ) == "L" .And. !lC20CodCta

			If Type( "GB_C20CCTA" ) != "U"
				nLin	:=	15
				cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_C20CCTA + '|' + CRLF + CRLF + CRLF
				lRet := .F.
			EndIf

		ElseIf cCmp2 == 'C20_CODPAR' .And. Type( "lC20CodPar" ) == "L" .And. !lC20Codpar

			If Type( "GB_C20CPAR" ) != "U"
				nLin	:=	15
				cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_C20CCTA + '|' + CRLF + CRLF + CRLF
				lRet := .F.
			EndIf

		ElseIf Type( "GB_MEMVAR2" ) == "L" .And. !GB_MEMVAR2
			nLin	:=	15
			cMens	:=	CRLF + CRLF +'Código informado não foi enviado anteriormente no respectivo registro de informações cadastrais. Valor informado |' + GB_MEMVAR + '|' + CRLF + CRLF + CRLF
			lRet	:=	.F.

		EndIf

		If !lRet
			M->( &( cCmp2 ) )	:=	GB_MEMVAR
			Help( ,,cHelp,,cMens, nLin, 0 )
		EndIf
	EndIf

	if cCmp2 == 'C0Q_PLACA'
		lRet		:=	.f.
		if  ( IsAlpha( SubStr( M->( &( cCmp2 ) ) , 1 , 1 ) ) .And.;
				IsAlpha( SubStr( M->( &( cCmp2 ) ) , 2 , 1 ) ) .And.;
				IsAlpha( SubStr( M->( &( cCmp2 ) ) , 3 , 1 ) ) .And.;
				IsNumeric( SubStr( M->( &( cCmp2 ) ) , 4 , 4 )))
			lRet		:=	.t.
		elseif  ( IsAlpha( SubStr( M->( &( cCmp2 ) ) , 1 , 1 ) ) .And.;
				IsAlpha( SubStr( M->( &( cCmp2 ) ) , 2 , 1 ) ) .And.;
				IsAlpha( SubStr( M->( &( cCmp2 ) ) , 3 , 1 ) ) .And.;
				IsNumeric( SubStr( M->( &( cCmp2 ) ) , 4 , 1 ) ) .And. ;
				IsAlpha( SubStr( M->( &( cCmp2 ) ) , 5 , 1 ) ) .and.;
				IsNumeric( SubStr( M->( &( cCmp2 ) ) , 6 , 2 )))
			lRet		:=	.t.
		endif

	endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNReflex
Funcao generica responsavel pelas mensagens de reflexo dos ajustes efetuados em tela

Este tratamento de mensagens estao nos layouts: TAFA062, TAFA053, TAFA027, TAFA075, TAFA109, TAFA093, TAFA095, TAFA063, TAFA064, TAFA188

@param	Nil

@return lRet  - .T. -> Validacao OK
				  .F. -> NAO Valido

@author Gustavo G. Rueda
@since 18/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function XFUNReflex( nOperation , aCmpsAlts , cFlag )
	Local	lMsg		:=	.F.
	Local	cMsg		:=	''
	Local	lRet		:=	.T.

//Quando for importacao via MILE, nao trato essas mensagens

	If Type( "lMILE" ) == "U" .Or. ( Type( "lMILE" ) == "L" .And. !lMILE )
		If GetNewPar( 'MV_TAFRFLX' , .T. ) .And.;
				( ( nOperation == MODEL_OPERATION_UPDATE .And. Len( aCmpsAlts ) > 0 ) .Or.;	//Alteracao
			( nOperation == MODEL_OPERATION_INSERT ) .Or.;	//Inclusao
			( nOperation == MODEL_OPERATION_DELETE ) )		//Exclusao

			If cFlag == 'TAFA062'
				//C30_TOTAL,C30_CFOP,C35_CODTRI,C35_CST,C35_BASE,C35_ALIQ,C35_REDBC,C35_MVA,C35_VLNT,C35_VLISEN,C35_VLOUTR,C20_VLDOC,
				//C2F_CODTRI,C2F_CFOP,C2F_CST,C2F_VLOPE,C2F_BASE,C2F_ALIQ,C2F_VALOR,C2F_VLNT,C2F_VLISEN,C2F_VLOUTR
				If nOperation == MODEL_OPERATION_INSERT	//Inclusao
					cMsg	:=	STR0010	//'Ao incluir um novo movimento em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0011	//'neste caso, a base de calculo dos impostos e consequentemente todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0012 + CRLF + CRLF	//'de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0013	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0014	//'movimentação, neste caso, o valor total do documento caso o tributo agregue, todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0015 + CRLF + CRLF	//'de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_DELETE	//Exclusao
					cMsg	:=	STR0016	//'Ao excluir um lançamento de um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0017 + CRLF + CRLF	//'neste caso, todas as obrigações acessórias espelhos deste período de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA053'
				//C1H_UF,C1H_CODMUN,C1H_PPES
				If nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0018	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0019	//'movimentação, neste caso, todos os calculos dos tributos e consequentemente, todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0020 + CRLF + CRLF	//'de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA027'
				//C0R_UF,C0R_VLRPRC,C0R_CODDA,C0R_NUMDA
				If nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0021	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0022	//'movimentação, neste caso, todos os valores apurados e recolhidos através deste documento de arrecadação, e consequentemente, todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0023 + CRLF + CRLF	//'de movimento, como as Apurações dos tributos.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA075'
				//C4R_VLICAP
				If nOperation == MODEL_OPERATION_INSERT	//Inclusao
					cMsg	:=	STR0024	//'Ao incluir um novo movimento em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0025 + CRLF + CRLF	//'neste caso, o crédito apropriado no período através da Apurações do ICMS, inclusive impactando até o recolhimento do saldo devedor.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0026	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0027 + CRLF + CRLF	//'movimentação, neste caso, o crédito apropriado no período através da Apurações do ICMS, impactando até no recolhimento do saldo devedor.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_DELETE	//Exclusao
					cMsg	:=	STR0028	//'Ao excluir um lançamento de um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0029 + CRLF + CRLF	//'neste caso, todas as obrigações acessórias espelhos deste período de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA109'
				//C6Y_QTDEST
				If nOperation == MODEL_OPERATION_INSERT	//Inclusao
					cMsg	:=	STR0030	//'Ao incluir um novo movimento em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0031 + CRLF + CRLF	//'neste caso, o fechamento de estoque (Inventário) do período.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0032	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0033 + CRLF + CRLF	//'movimentação, neste caso, o fechamento de estoque (Inventário) do período.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_DELETE	//Exclusao
					cMsg	:=	STR0034	//'Ao excluir um lançamento de um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0035 + CRLF + CRLF	//'neste caso, o fechamento de estoque (Inventário) do período.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA095' .Or. cFlag == 'TAFA093'
				//TAFA095 - C5S_VLOPR,C5S_CFOP,C5T_CODTRI,C5T_CST,C5T_BASE,C5T_ALIQ,C5T_VALOR,C5T_REDBC,C5T_MVA,C5T_VLNT,C5T_VLISEN
				//TAFA093 - C6I_CODSIT,C6I_DTEMIS,C6I_VLDOC,C6J_CFOP,C6J_VLRITE,C6K_TRIB,C6K_CST,C6K_MVA,C6K_REDBC,C6K_VLRBC,C6K_VLNT,C6K_VLRTRB
				If nOperation == MODEL_OPERATION_INSERT	//Inclusao
					cMsg	:=	STR0036	//'Ao incluir um novo movimento em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0037	//'neste caso, a base de calculo dos impostos e consequentemente todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0038 + CRLF + CRLF	//'de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0039	//'Ao alterar uma informação fiscal já gravada em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta '
					cMsg	+=	STR0040	//'movimentação, neste caso, as datas dos lançamentos, os valores dos itens e seus tributos correspondentes, além de todas as obrigações acessórias espelhos deste período '
					cMsg	+=	STR0041 + CRLF + CRLF	//'de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_DELETE	//Exclusao
					cMsg	:=	STR0042	//'Ao excluir um lançamento de um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0043 + CRLF + CRLF	//'neste caso, todas as obrigações acessórias espelhos deste período de movimento, como as Apurações e os recolhimentos.'
					lMsg	:=	.T.

				EndIf

			ElseIf cFlag == 'TAFA063' .Or. cFlag == 'TAFA188' .Or. cFlag == 'TAFA064'
				If nOperation == MODEL_OPERATION_INSERT	//Inclusao
					cMsg	:=	STR0044	//'Ao incluir uma nova Apuração de um tributo em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0045 + CRLF + CRLF	//'neste caso, os recolhimentos dos tributos apurados e todas as obrigações acessórias espelhos deste período de movimento.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_UPDATE	//Alteracao
					cMsg	:=	STR0046	//'Ao alterar uma Apuração de um tributo em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0047 + CRLF + CRLF	//'neste caso, os recolhimentos dos tributos apurados e todas as obrigações acessórias espelhos deste período de movimento.'
					lMsg	:=	.T.

				ElseIf nOperation == MODEL_OPERATION_DELETE	//Exclusao
					cMsg	:=	STR0048	//'Ao excluir uma Apuração de um tributo em um determinado período podem ocasionar divergências entre os outros lançamentos decorrentes desta movimentação, '
					cMsg	+=	STR0049 + CRLF + CRLF	//'neste caso, os recolhimentos dos tributos apurados e todas as obrigações acessórias espelhos deste período de movimento.'
					lMsg	:=	.T.

				EndIf

			EndIf

			if IsInCallStack( "TSI" )
				lRet := .T.
			elseIf lMsg
				cMsg	+=	STR0050	//'Também será necessário retificar os arquivos magnéticos já declarados nos períodos, pois eles foram gerados com base nos ultimos lançamentos do '
				cMsg	+=	STR0051	//'período, não contemplando esta alteração recente.'
				cMsg	+=	CRLF + CRLF + 'Confirma ?'

				//-----------------------------------------------------------------
				// Se não for execução via server, mostra a mensagem p/ o usuário
				//-----------------------------------------------------------------
				If !IsBlind()
					If !( lRet := ApMsgYesNo( cMsg ) )
						Help( ,,'TAFFORMINVALID' )	//Os lançamentos efetuados neste formulário não foram salvos conforme opção selecionada. Verifique as informações antes de salvar novamente ou cancele a operação através da função 'FECHAR'.
					EndIf
				Else
					//-------------------------------
					// Execução do robo da Automação
					//-------------------------------
					If FindFunction( 'GetParAuto' )
						//-------------------------------
						// Execução do robo da Automação
						//-------------------------------
						aRetAuto := GetParAuto( 'TAFA063TESTCASE' )
						//-------------------------------
						// Simula o click 'sim'
						//-------------------------------
						If type("aRetAuto") == "A" .And. len( aRetAuto ) >= 1 .And. aRetAuto[1] == 1
							lRet := .T.
						Else
							//-------------------------------
							// Simula o click 'não'
							//-------------------------------
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunVldRec
Valida o Codigo da Receita com a UF para qual esta sendo cadastrado o Documento de Arrecadacao

Esta Funcao eh chamada do VALID do campo C0R_CODREC

@param	Nil

@return lRet  - .T. -> Validacao OK
                .F. -> NAO Valido

@author Rodrigo Aguilar
@since 27/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunVldRec()

	Local cVarMem := ReadVar()
	Local cAlias  := SubStr( cVarMem, 4, 3 )
	Local cIDUF   := M->&(cAlias + "_UF")

	Local lRet    := .T.

	C09->(DbSetOrder(3))
	If C09->( MsSeek( xFilial("C09") + cIDUF ) )

		Do Case
		Case C09->C09_UF == "AC"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100072|100099|150010|500011|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "AL"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100080|100099|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "AP" .Or. C09->C09_UF == "BA"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "CE"
			If !( C6R->C6R_CODIGO $ "100013|100030|100048|100056|100080|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "GO"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100099|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "MA"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100080|100099|150010|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "MG"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100080|100099|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "MS"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100072|100099|150010|500011|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "MT"
			If !( C6R->C6R_CODIGO $ "100013|100030|100048|100056|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "PA"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100072|100080|100099|150010|500011|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "PB"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100080|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "PE"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100080|100099|500011|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "PI"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100099|500011|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "PR"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "RN"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100080|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "RO"
			If !( C6R->C6R_CODIGO $ "100013|100030|100048|100056|100080|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "RR"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100080|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "RS"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100072|100080|100099|150010|500011|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "SC"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100064|100072|100080|100099|150010|600016|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "SE"
			If !( C6R->C6R_CODIGO $ "100048|100056|100099|" )
				lRet    := .F.
			EndIf
		Case C09->C09_UF == "TO"
			If !( C6R->C6R_CODIGO $ "100013|100021|100030|100048|100056|100099|" )
				lRet    := .F.
			EndIf
		EndCase
	EndIf

	If !lRet
		Help( ,,"TAFRECUF",,, 1, 0 )
	EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunVldPer
Valida se o Periodo informado no registro esta entre as Datas Inicias e Finais
passadas por parametro

Esta Funcao eh chamada do VALID do campo C0R_CODREC

@param	cCmdPer    -> Nome do campo referente ao Periodo
        cCmpModDe  -> Nome do campo referente a Data Inicial
        cCmpModAte -> Nome do campo referente a Data Final

@return lRet  - .T. -> Validacao OK
                .F. -> NAO Valido

@author Rodrigo Aguilar
@since 12/03/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunVldPer( cCmdPer, cCmpModDe , cCmpModAte )

	Local	lRet		:=	.T.
	Local   cPeriodo    := ""

	If !Empty( FWFldGet( cCmdPer ) )

		cPeriodo := Right( FWFldGet( cCmdPer ), 4 ) + Left( FWFldGet( cCmdPer ), 2 )

		If !Empty( FWFldGet( cCmpModDe ) ) .And. !Empty( FWFldGet( cCmpModAte ) )
			If cPeriodo < StrTran( Left( DtoS ( FWFldGet( cCmpModDe ) ), 6 ), "/", "" ) .Or. ;
					cPeriodo > StrTran( Left( DtoS ( FWFldGet( cCmpModAte ) ), 6 ), "/", "" )
				lRet := .F.
			EndIf
		ElseIf !Empty( FWFldGet( cCmpModDe ) )
			If cPeriodo < StrTran( Left( DtoS ( FWFldGet( cCmpModDe ) ), 6 ), "/", "" )
				lRet := .F.
			EndIf
		ElseIf !Empty( FWFldGet( cCmpModAte ) )
			If cPeriodo > StrTran( Left( DtoS ( FWFldGet( cCmpModAte ) ), 6 ), "/", "" )
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !lRet
		Help( ,,"TAFVLDPER",,, 1, 0 )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunVDcCan
Esta Funcao verifica se a numeracao da Nota Fiscal cancelada esta entre
a numeracao De/Ate do Documento Fiscal

Esta Funcao eh chamada do VALID do campo C2I_NUMDOC

@param	( Nil )

@return lRet  - .T. -> Validacao OK
                .F. -> NAO Valido

@author Rodrigo Aguilar
@since 12/03/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunVDcCan()

	Local lRet   := .T.
	Local cCampo := ReadVar()

	If !Empty( M->C20_NUMDOC ) .And. !Empty( M->C20_NDOCF )
		If Val( &(cCampo) ) < Val( M->C20_NUMDOC ) .Or. Val( &(cCampo) ) > Val( M->C20_NDOCF )
			lRet := .F.
		EndIf
	ElseIf !Empty( M->C20_NUMDOC )
		If Val( &(cCampo) ) < Val( M->C20_NUMDOC )
			lRet := .F.
		EndIf
	ElseIf !Empty( M->C20_NDOCF )
		If Val( &(cCampo) ) > Val( M->C20_NDOCF )
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help( ,,"TAFVLDCAN",,, 1, 0 )
	EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunVldHor
Funcao que valida a hora informada.

@return lRet -   .T. -> Hora válida
                 .F. -> Hora inválida

@author Anderson Costa
@since 26/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunVldHor(cCampo)

	Local cCmpCont  := ""
	Local cHelp     := ""
	Local cHora     := ""
	Local cMinuto   := ""
	Local lRetorno  := .F.
	Local nAchou    := 0
	Local nPosMin   := 0
	Local cX3Pic		:= ""
	Local cNomeCmp	:= ""
	Local cPosAt		:= 0

	Default cCampo := ""

	If !Empty( cCampo )

		If !(Type("M->" + Substr(cCampo,6,11)) == "U")
			cCampo := "M->" +  Substr(cCampo,6,11)
		EndIf

		cCmpCont := &( cCampo )

		cHora 	:= SubStr(cCmpCont,1,2)
		cHelp 	:= AllTrim(SubStr(cCampo, 6))
		nAchou := At(":", cCmpCont) 				// Verifica se a hora foi passada no formato 99:99
		nPosMin := If(nAchou > 0, nAchou + 1, 3)
		cMinuto := SubStr(cCmpCont,nPosMin,2)

		// Se a hora não foi passada no formato '99:99' verifico se o campo tem máscara para esse formato
		If (nAchou = 0)
			cPosAt	:=	AT(">", cCampo) + 1
			cNomeCmp := SubStr(cCampo,cPosAt,Len(cCampo) - 3) //Pega o nome do campo.
			("SX3")->( DbSetOrder( 2 ) )
			If ("SX3")->( MsSeek ( cNomeCmp ) )
				cX3Pic := X3Picture( cNomeCmp ) //Pega a picture do campo
				If AllTrim(cX3Pic) = '@R 99:99'
					nAchou := 3 //Posição do ":"
				EndIf
			EndIf
		EndIf

		If (nAchou > 0) .AND. ( (cHora >= "00" .AND. cHora < "24") .AND. (cMinuto >= "00" .AND. cMinuto < "60") )

			// Verifica se o horario eh positivo
			lRetorno := Val(StrTran(cCmpCont, ":", "")) >= 0

		EndIf
	EndIf

//Seto o retorno como verdadeiro quando o conteudo do campo for vazio, pois existem campos não obrigatórios.
	If Empty(cCmpCont)
		lRetorno := .T.
	EndIf

// Caso nao seja uma hora valida, exibe help do campo "cHelp"
	If !lRetorno
		Help(" ", 1, cHelp)
	EndIf

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunGetVer
Esta Funcao retorna a Versao do registro das tabelas do TAF

Funcao utilizada na confirmacao da tela do campo e integrcao.
Versao das tabelas de eventos do eSocial

@param	( Nil )

@return cVersaoReg  - 	Versao do registro. Consistem em DATA + Hora,
						sendo DDMMAAAHHMMSS

@author Felipe C. Seolin / Dema De Los Rios

@since 30/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunGetVer()

	Local cSeconds := StrTran(AllTrim(Str(Seconds())),".","")
	Local cDia     := Substr(DtoS(dDataBase),7,2)
	Local cMes     := Substr(DtoS(dDataBase),5,2)
	Local cAno     := Substr(DtoS(dDataBase),3,2)

	Local cVersaoReg := cDia + cMes + cAno + StrZero(Val(cSeconds),8,0)

Return( cVersaoReg )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunRmFStr (Função RemoveField da Struct)

Função para não mostrar na tela os campos de controle que são utilizados no e-Social.
Originalmente todos os eventos do e-Social teriam esses campos como não usados, servindo para controle.
Porém o Inic. Padrão dos campos não funcionam quando eles estão como 'não usados'. Dessa forma surgiu a necessidade
de deixar os campos como usados e removê-los da ViewDef de cada fonte. Para concentrar os campos em um único local
foi criada essa função.
Deve ser chamada na viewDef de cada fonte:
xFunRemStr(@Estrutura, cAlias)


@param		oStru: Estrutura da view.
			cAlias: Alias da view.
			lExtemp: Remove os campos de controle para eventos extemporaneos

@return nil

@author Leandro Prado
@since 28/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunRmFStr(oStru, cAlias)

	Default oStru 	:= Nil
	Default cAlias 	:= Nil

	If oStru <> Nil .And. cAlias <> Nil

		//Remove os campos da view.
		oStru:RemoveField(cAlias + '_EVENTO')
		oStru:RemoveField(cAlias + '_ATIVO' )
		oStru:RemoveField(cAlias + '_VERSAO')
		oStru:RemoveField(cAlias + '_VERANT')
		oStru:RemoveField(cAlias + '_PROTPN')
		oStru:RemoveField(cAlias + '_STATUS')

		If FindFunction( "xTafExtmp" ) .And. xTafExtmp() .And. TafColumnPos(cAlias + '_STASEC')
			oStru:RemoveField(cAlias + '_STASEC')
		EndIf

		If TafColumnPos(cAlias + '_TPAMB')
			oStru:RemoveField(cAlias + '_TPAMB')
		EndIf

		If TafColumnPos(cAlias + '_XMLID')
			oStru:RemoveField(cAlias + '_XMLID')
		EndIf

		If TafColumnPos(cAlias + '_ID')
			oStru:RemoveField(cAlias + '_ID')
		EndIf

	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunTrcSN (Função Troca Sim/Não)

Função para trocar número por letra ou letra por número nos combos com opções Sim/Não



@param		cVlrOri: Valor original
			nTpTroca: Tipo de Troca;
						Se igual 1, troca de número por letra;
						Se igual 2, troca de letra por número;

@return cRet - Retorna o valor alterado.

@author Leandro Prado
@since 23/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunTrcSN(cVlrOri as character, nTpTroca as numeric)

	Local cRet 			as character

	Default cVlrOri	 	:= ""
	Default nTpTroca	:= 1

	cRet := ""

	If !Empty(cVlrOri)
		Do Case
			Case nTpTroca == 1
				cRet := IIf(cVlrOri == "1", "S", "N")
			Case nTpTroca == 2
				cRet := IIf(cVlrOri == "S", "1", "2")
			Case nTpTroca == 3
				cRet := IIf(cVlrOri == "0", "N", "S")
			Case nTpTroca == 4
				cRet := IIf(cVlrOri == "N", "0", "1")
			Case nTpTroca == 5
				cRet := IIf(cVlrOri == "S", "1", "")
			Case nTpTroca == 6
				cRet := IIf(cVlrOri == "1", "S", "")
		EndCase
	EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunHisAlt

Funcao para criar a tela de historico de alteracoes do registro.
O registro a ser filtrado eh o mesmo selecionado pelo usuario na Grid

@Param:
cAlias  -  Alias da Tabela Principal ( Tabela onde a Grid eh baseada
                                       para montar as informacoes    )
cRotina - Rotina onde a ViewDef se encontra

@Return:

@author Gustavo G. Rueda
@since 11/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunHisAlt( cAlias as Character, cRotina as Character, aHeaderT as Array, cTitulo as Character,  lCadTrab as Logical, cFuncXml as Character, cLayout as Character )

    Local aCoors   as Array
    Local aFields  as Array
    Local bXml     as Block
    Local cFilter  as Character
    Local oBrowse  as Object
    Local oFWLayer as Object
    Local oPanel   as Object

    Private lMenuDif := .T.

    Default cTitulo  := STR0055 + (cAlias)->&( cAlias + "_ID" )
    Default cFuncXML := ''

    aCoors   := FwGetDialogSize( oMainWnd )
    aFields  := {}
    bXml     := {||TafXmlret( cFuncXML, cLayout, cAlias )}
    cFilter  := cAlias + "_FILIAL + " + cAlias + "_ID"
    oBrowse  := Nil
    oFWLayer := Nil
    oPanel   := Nil

    // Bloqueia ou audita de acordo com a função que está chamando e acesso do usuário
    If TafHistLGPD()

        Define MsDialog oDlgPrinc Title cTitulo From aCoors[1] + 100, aCoors[2] + 100 To aCoors[3] - 100, aCoors[4] - 100 Pixel
        oFWLayer := FWLayer():New()
        oFWLayer:Init( oDlgPrinc, .F., .T. )
        oFWLayer:AddLine( 'UP', 100, .F. )
        oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
        oPanel := oFWLayer:GetColPanel( 'ALL', 'UP' )
        oBrowse:= FWmBrowse():New()
        oBrowse:SetOwner( oPanel )
        oBrowse:SetDescription( cTitulo )
        oBrowse:SetAlias( cAlias )
        oBrowse:AddButton("Gerar XML" ,bXml,,,)

        //Tratamento para o cadastro do Trabalhador
        If lCadTrab

            oBrowse:AddLegend( "EVENTO == 'I'"                                              , "GREEN"                   , "Inclusão de Cadastro do Trabalhador" )       //"Incluísão de Cadastro do Trabalhador"
            oBrowse:AddLegend( "EVENTO == 'I' .AND. !(NOMEVE $('S2200|S2300')) "            , "ORANGE"                  , "Inclusão de Evento de Alteração" )           //"Incluísão de Evento de Alteração"
            oBrowse:AddLegend( "EVENTO == 'A' "                                             , "YELLOW"                  , "Retificação de Informações do Trabalhador " ) //"Retificação de Informações do Trabalhador "
            oBrowse:AddLegend( "EVENTO == 'E' "                                             , "RED"                     , "Exclusão de Evento (Alteração/Retificação)" ) //"Exclusão de Evento (Alteração/Retificação)"
            oBrowse:SetColumns(aHeaderT)

        Else 
                
            cFilter := cAlias + "_FILIAL + " + cAlias + "_ID"
            aFields := xFunGetSX3( cAlias )
            oBrowse:SetFields( aFields )
            oBrowse:SetFilterDefault( cAlias + "_ATIVO == '2' .and. " + cFilter + "=='" + ( cAlias )->&( cFilter ) + "'" )
        EndIf

        IF cLayout $ '1000|1005|1010|1020|1030|1035|1040|1050|1060|1070|1080'

            oBrowse:AddLegend( cAlias + "_EVENTO == 'I' "           , "GREEN"   , "Inclusão de Cadastro do Evento" )                //"Inclusão de Cadastro do Evento"
            oBrowse:AddLegend( cAlias + "_EVENTO == 'A' "           , "YELLOW"  , "Retificação das Informações do Evento" )         //"Retificação das Informações do Evento"
            oBrowse:AddLegend( cAlias + "_EVENTO == 'E' "           , "RED"     , "Exclusão de Evento" )                            //"Exclusão de Evento"

        EndIf 

        oBrowse:SetMenuDef( cRotina )
        oBrowse:SetProfileID( '1' )
        oBrowse:ForceQuitButton()
        oBrowse:DisableDetails()
        oBrowse:Activate()

        Activate MsDialog oDlgPrinc Center

    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TafHistLGPD
Verifica se contem dados senssíveis e também verifica se o usuario tem acesso aos dados, se sim o log
é auditado. se não a tela(Ex: Historico) é bloqueada.
@author  TOTVS
@since   14/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Function TafHistLGPD()
	Local aArea		:= GetArea()
	Local aHistAlt 	:= {}
	Local lRet		:= .T.

	aHistAlt 		:= TAFRotinas()

	If Len(aHistAlt) > 0
		nPosTaf			:= aScan(aHistAlt,{|x| x[1] == FunName()})
		If nPostaf > 0
			If  Len(aHistAlt[nPosTaf]) > 16 .And. aHistAlt[nPosTaf][17]  // verifica se contem dados senssíveis

				If ( lRet	:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)  ) //Verifica se o Usuario tem permissão a dados sensíveis
					IIf (FindFunction('FwPDLogUser'),FwPDLogUser('XFUNHISALT'),.T.) //Grava o LOG /Audita.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} xFunGetSX3

Estrutura da SX3 para o metodo SetField do FWmBrowse

@Param:
cAlias   -  Alias para busca da estrutura SX3
cExclCmp -  Desconsiderar Campos
lVirtual -  Se Inclui campos Virtuais

@Return:
aFields - Estrutura do aFields para metodo SetField()
          [n][01] Titulo da coluna
          [n][02] Code-Block de carga dos dados
          [n][03] Tipo de dados
          [n][04] Mascara
          [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
          [n][06] Tamanho
          [n][07] Decimal
          [n][08] Indica se permite a edicao
          [n][09] Code-Block de validacao da coluna apos a edicao
          [n][10] Indica se exibe imagem
          [n][11] Code-Block de execucao do duplo clique
          [n][12] Variavel a ser utilizada na edicao (ReadVar)
          [n][13] Code-Block de execucao do clique no header
          [n][14] Indica se a coluna esta deletada
          [n][15] Indica se a coluna sera exibida nos detalhes do Browse
          [n][16] Opcoes de carga dos dados (Ex: 1=Sim, 2=Não)

@author Felipe C. Seolin
@since 14/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunGetSX3( cAlias, cExclCmp, lVirtual )

	Local aFields  := {}
	Default cExclCmp := ""
	Default lVirtual := .F.

	DBSelectArea( "SX3" )
	SX3->( DBSetOrder( 1 ) )
	If SX3->( MsSeek( cAlias ) )
		While SX3->( !Eof() ) .and. SX3->X3_ARQUIVO == cAlias
			If X3Usado( SX3->X3_CAMPO )  .And. !(AllTrim(SX3->X3_CAMPO) $ cExclCmp) .And. !('_IDTRAN' $ AllTrim(SX3->X3_CAMPO)) .And. !('_LOGOPE' $ AllTrim(SX3->X3_CAMPO))
				If !lVirtual .And. SX3->X3_CONTEXT == "V"
					SX3->( DBSkip() )
					Loop
				Else
					aAdd( aFields, { AllTrim( X3Titulo() ),;
						SX3->X3_CAMPO,;
						SX3->X3_TIPO,;
						SX3->X3_PICTURE,;
						,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_WHEN,;
						SX3->X3_VALID} )
				EndIf
			EndIf
			SX3->( DBSkip() )
		EndDo
	EndIf

Return( aFields )
//---------------------------------------------------------------------
/*/{Protheus.doc} FVldFunc
Função para validação do CPF informado, função utilizada nos eventos de
alteração cadastral e contratual do funcionário ( S-2200 )
para validar se o funcionário a ser cadastrado existe.

@Return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 22/01/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function FVldFunc( lExistAlt, lBtnOk )

	If lBtnOk
		If !Empty( MV_PAR01 )
			lExistAlt := .T.
		EndIf
	EndIf

Return ( lExistAlt )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunAge

Calcula a idade com referencia na data de nascimento

@Param:
dDtNasc - Data de nascimento
dDtRef  - Data de referencia para comparacao

@Return:
nAge - Idade

@author Felipe C. Seolin
@since 28/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunAge( dDtNasc, dDtRef )

	Local nAge := 0

	Default dDtRef := dDataBase

	nAge := Year( dDataBase ) - Year( dDtNasc )

	If Month( dDataBase ) < Month( dDtNasc )
		nAge --
	ElseIf Day( dDataBase ) < Day( dDtNasc ) .and. Month( dDataBase ) == Month( dDtNasc )
		nAge --
	EndIf

	If nAge < 0
		nAge := 0
	EndIf

Return( nAge )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunDtPer

Retorna o primeiro ou último dia do mês de um período no formato MMAAAA

@Param:
cPer	- Periodo no formato MMAAAA
lLast	- Valor lógico determina se será a primeira ou ultima data do mês no retorno.

@Return:
dData - Data

@author Leandro Prado
@since 04/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunDtPer( cPer, lLast, lInverte, cTbEsoci)

	Local dData := ''
	Local cAno  := ''
	Local cMes  := ''

	Default lLast := .F.
	Default lInverte := .F.
	Default cTbEsoci := ''

	If lInverte
		cMes := Substr(cPer,5,2)
		cAno := Substr(cPer,1,4)
	Else
		cMes := Substr(cPer,1,2)
		cAno := Substr(cPer,3,4)
	EndIf

	If (Alltrim(Upper(cTbEsoci))=="C8R" .AND. Empty(cAno))
		dData := CtoD(dData)
	ElseIf (lLast)
		dData := LastDate(CtoD("01/" + cMes + "/" + cAno))
	Else
		dData := CtoD("01/" + cMes + "/" + cAno)
	EndIf

Return( dData )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCMail
Verifica se a conexao com a Totvs Sped Services pode ser estabelecida - Mail

@author Evandro dos Santos Oliveira
@since 27/01/2014
@version 1.0

@param ${nTipo}	, ${Tipo de servidor - 1 SMTP;2 POP}
@param ${cServer}	, ${Servidor}
@param ${cLogin}	, ${Login}
@param ${cSenha}	, ${Senha}
@param ${cFrom}	, ${Conta de envio}
@param ${lAuth}	, ${Requer autenticacao}
@param ${cAdmin}	, ${Email de notificacao }
@param ${lSSL}		, ${Usa SSL}
@param ${lTLS}		, ${Usa TLS}
@param ${lDanfe}	, ${Envia Danfe por e-mail}

@return ${lRetorno}, ${Retorna se a função foi validada}

@see Função Original - IsMailRead 18.08.2007
/*/
//-------------------------------------------------------------------
Function TAFCMail(nTipo,cServer,cLogin,cSenha,cFrom,lAuth,cAdmin,lSSL,lTLS,lDANFE)

	Local oWS
	Local lOk      := .F.
	Local cIdEnt   := ""
	Local cMsg     := ""
	Local cURL     := ""
	Local lRetorno := .T.

	DEFAULT lAuth  := .F.
	DEFAULT cLogin := ""
	DEFAULT lSSL   := .F.
	DEFAULT lTLS   := .F.
	DEFAULT lDANFE := .F.

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf
	cUrl := AllTrim(cUrl)

	If ValType(lSSL) == "C"
		If lSSL == "T"
			lSSL := .T.
		Else
			lSSL := .F.
		EndIf
	EndIf

	If ValType(lTLS) == "C"
		If lTLS == "T"
			lTLS := .T.
		Else
			lTLS := .F.
		EndIf
	EndIf

	If ValType(lAuth) == "C"
		If lAuth == "T"
			lAuth := .T.
		Else
			lAuth := .F.
		EndIf
	EndIf

	If ValType(lDANFE) == "C"
		If lDANFE == "T"
			lDANFE := .T.
		Else
			lDANFE := .F.
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		If !lAuth .Or. (!Empty(AllTrim(cLogin)) .And. !Empty(AllTrim(cSenha)))
			cIdEnt := AllTrim(TAFRIdEnt())
			If !Empty(AllTrim(cServer))
				If !Empty(cIdEnt)
					oWs:= WsSpedCfgNFe():New()
					oWs:cUSERTOKEN      						:= "TOTVS"
					oWs:cID_ENT         					:= cIdEnt
					oWS:_URL            					:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
					lOk                 					:= oWs:CfgTSSVersao()
					oWs:oWsSMTP                        	:= SPEDCFGNFE_SMTPSERVER():New()
					oWs:oWsSMTP:cMailServer            	:= cServer
					oWS:oWsSMTP:cLoginAccount          	:= cLogin
					oWs:oWsSMTP:cMailPassword          	:= cSenha
					oWs:oWsSMTP:cMailAccount            	:= cFrom
					oWs:oWsSMTP:lAuthenticationRequered	:= lAuth
					oWs:oWsSMTP:cMailAdmin              	:= cAdmin
					If lOk
						If oWs:cCfgTSSVersaoResult >= "1.14p"
							oWs:oWsSMTP:lSSL := lSSL
						EndIf
						If oWs:cCfgTSSVersaoResult >= "1.41"
							oWs:OWSSMTP:lTLS 	:= lTLS
						EndIf
					EndIf
					If oWs:CfgSMTPMail()
						Aviso("SPED",oWS:cCfgSMTPMailResult,{STR0058},3)

						// Configuração do envio do DANFE por e-mail
						oWS					:= wsSPEDCfgNFe():new()
						oWS:_URL			:= allTrim( cURL ) + "/SPEDCFGNFe.apw"
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIDEnt
						oWS:cUSACOLAB		:= ""
						oWS:nNUMRETNF		:= 0
						oWS:nAMBIENTE		:= 0
						oWS:nMODALIDADE	:= 0
						oWS:cVERSAONFE	:= ""
						oWS:cVERSAONSE	:= ""
						oWS:cVERSAODPEC	:= ""
						oWS:cVERSAOCTE	:= ""
						oWS:cPASSWORD		:= ""
						oWS:cNFEDISTRDANFE	:= iif( lDANFE, "1", "0" )
						If !TAFWSRet(oWS,"CFGPARAMSPED" )
							lRetorno	:= .F.
							Aviso( "SPED", STR0078 , {STR0058}, 3 )
						endif
					Else
						lRetorno := .F.
						Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
					EndIf
				EndIf
			Else
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN	:= "TOTVS"
				oWs:cID_ENT    	:= cIdEnt
				oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk            	:= oWs:CfgTSSVersao()
				If oWs:GetSMTPMail()
					DEFAULT oWS:oWSGETSMTPMAILRESULT:cMailAdmin := ""
					cMsg := STR0062+CRLF+CRLF//"O Servidor de SMTP do Totvs Sped não foi configurado"
					cMsg += STR0063+": "+oWS:oWSGETSMTPMAILRESULT:cMAILSERVER+CRLF
					cMsg += STR0064+": "+oWS:oWSGETSMTPMAILRESULT:cLOGINACCOUNT+CRLF
					cMsg += STR0065+": "+oWS:oWSGETSMTPMAILRESULT:cMAILPASSWORD+CRLF
					cMsg += STR0066+": "+oWS:oWSGETSMTPMAILRESULT:cMAILACCOUNT+CRLF
					cMsg += STR0067+": "+IIF(oWS:oWSGETSMTPMAILRESULT:lAUTHENTICATIONREQUERED,".T.",".F.")+CRLF
					cMsg += STR0068+": "+oWS:oWSGETSMTPMAILRESULT:cMailAdmin+CRLF
					If lOk
						If oWs:cCfgTSSVersaoResult >= "1.14p"
							cMsg += STR0069+": "+Iif(oWs:oWSGETSMTPMAILRESULT:lSSL, ".T.", ".F.")+CRLF
						EndIf
						If oWs:cCfgTSSVersaoResult >= "1.41"
							cMsg += STR0070+": "+Iif(oWs:oWSGETSMTPMAILRESULT:lTLS, ".T.", ".F.")+CRLF
						EndIf
					EndIf
					Aviso("SPED",cMsg,{STR0058},3)
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
				EndIf
			EndIf
		EndIf
	Else
		cIdEnt := AllTrim(TAFRIdEnt())
		If !Empty(AllTrim(cServer))
			If !Empty(cIdEnt)
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN      			:= "TOTVS"
				oWs:cID_ENT         		:= cIdEnt
				oWS:_URL            		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk                 		:= oWs:CfgTSSVersao()
				oWs:oWsPOP                := SPEDCFGNFE_POPSERVER():New()
				oWs:oWsPOP:cMailServer     	:= cServer
				oWs:oWsPOP:cLoginAccount  	:= cLogin
				oWs:oWsPOP:cMailPassword  	:= cSenha
				If lOk
					If oWs:cCfgTSSVersaoResult >= "1.14p"
						oWs:oWsPOP:lSSL := lSSL
					EndIf
				EndIf
				If oWs:CfgPOPMail()
					Aviso("SPED",oWS:cCfgPOPMailResult,{STR0058},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
				EndIf
			EndIf
		Else
			oWs:= WsSpedCfgNFe():New()
			oWs:cUSERTOKEN		:= "TOTVS"
			oWs:cID_ENT        	:= cIdEnt
			oWS:_URL           	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk            		:= oWs:CfgTSSVersao()
			If oWs:GetPOPMail()
				cMsg := STR0072+CRLF+CRLF//"O Servidor de POP do Totvs Sped não foi configurado "
				cMsg += STR0073+": "+oWS:oWSGETPOPMAILRESULT:cMAILSERVER+CRLF
				cMsg += STR0074+": "+oWS:oWSGETPOPMAILRESULT:cLOGINACCOUNT+CRLF
				cMsg += STR0075+": "+oWS:oWSGETPOPMAILRESULT:cMAILPASSWORD+CRLF
				If lOk
					If oWs:cCfgTSSVersaoResult >= "1.14p"
						cMsg += STR0079+": "+Iif(oWs:oWSGETPOPMAILRESULT:lSSL, ".T.", ".F.")+CRLF
					EndIf
				EndIf
				Aviso("SPED",cMsg,{STR0058},3)
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
			EndIf
		EndIf
	EndIf
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCTSpd
Verifica se a conexao com a Totvs Sped Services pode ser estabelecida

@author Evandro dos Santos Oliveira
@since 27/01/2014
@version 1.0

@param ${cURL}	, ${URL do Totvs Services SPED}
@param ${nTipo}, ${1=Conexao;2=Certificado}
@param ${lHelp}, ${Exibe Help}
@parm cMsgErr -> Mensagem de Erro

@return ${lRetorno}, ${Retorna se a função foi validada}

@see Função Original - IsReady 18.06.2007
/*/
//-------------------------------------------------------------------
Function TAFCTSpd(cURL, nTipo, lHelp, cMsgErr, lGravaUrl, lTransFil)

	Local nX       		:= 0
	Local cHelp    		:= ""
	Local oWS			:= Nil
	Local lRetorno		:= .F.	
	Local aArea  		:= SM0->(GetArea())
	Local cFilBack		:= cFilAnt
	Local lValidErpOk	:= .F.

	Default nTipo   	:= 1
	Default lHelp   	:= .F.
	Default cMsgErr 	:= ""
	Default lGravaUrl 	:= .F.
	Default lTransFil	:= .F.

	If lTransFil
		lValidErpOk := TAFChgFil(@cMsgErr)
	Else
		lValidErpOk := .T. 
	EndIf

	If lValidErpOk
		/** Atenção - Gravo o Código da Empresa na Filial por conta da regra de négocio do e-Social
			posso ter 1 URL por empresa e não filial */
		If lGravaUrl
			GrvURLTSS(cURL)
		EndIf

		SuperGetMv() //Limpa o cache de parametros - nao retirar

		If Empty(cUrl)
			If FindFunction("TafGetUrlTSS")
				cURL := PadR(TafGetUrlTSS(),250)
			Else
				cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
			EndIf
		EndIf

		cURL := AllTrim(cURL)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o servidor da Totvs esta no ar                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken := "TOTVS"
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		
		If oWs:CFGCONNECT()
			lRetorno := .T.
		Else
			If lHelp

				cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If "WSCERR044" $ cMsgErro
					cMsgErro := "Falha ao tentar se conectar ao TSS."+CRLF+CRLF
					cMsgErro += "Configurações usadas:"+CRLF
					cMsgErro += "Url Totvs Service SOA: "+ AllTrim(cURL) +CRLF+CRLF
					cMsgErro += "Verifique as configurações do servidor e se o mesmo está ativo."
				EndIf

				Aviso("Conexão TSS - Totvs Service SOA",cMsgErro,{STR0058},3)

			Else
				cMsgErr += IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf

			lRetorno := .F.
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o certificado digital ja foi transferido                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo <> 1 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := TAFRIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

			If oWs:CFGReady()
				lRetorno := .T.
			Else
				If nTipo == 3
					cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					
					If lHelp .And. !"003" $ cHelp
						Aviso("SPED",cHelp,{STR0058},3)
						lRetorno := .F.
					EndIf
				Else
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o certificado digital ja foi transferido                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo == 2 .And. lRetorno
			oWs:cUserToken := "TOTVS"
			oWs:cID_ENT    := TAFRIdEnt()
			oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			If oWs:CFGStatusCertificate()
				If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
					For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
						If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()

						Aviso("SPED",STR0076+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{STR0058},3) //"O certificado digital irá vencer em: "

						EndIf
					Next nX
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	cFilAnt := cFilBack

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCTrsf
Verifica se o certificado digital foi transferido com sucesso

@author Evandro dos Santos Oliveira
@since 27/01/2014
@version 1.0

@param ${nTipo}	, ${[1]PEM;[2]PFX}
@param ${cCert}	, ${Certificado digital}
@param ${cKey}		, ${Private Key}
@param ${cPassWord}, ${Password}
@param ${cSlot}	, ${Slot}
@param ${cLabel}	, ${Label}
@param ${cModulo}	, ${Modulo}
@param ${cIdHex}	, ${}


@return ${lRetorno}, ${Retorna se a função foi validada}

@see Função Original - IsCDReady 18.06.2007
/*/
//-------------------------------------------------------------------
Function TAFCTrsf(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex)

	Local oWS
	Local cIdEnt   := ""
	Local lRetorno := .T.
	Local cURL     :=""

	Default cIdHex := ""

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf
	cURL := AllTrim(cURL)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((!Empty(cCert) .And. !Empty(cKey) .And. !Empty(cPassWord) .And. nTipo == 1) .Or. ;
			(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
			(!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
			(!Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 2)) .Or. !TAFCTSpd(,2)

		if !Empty(cLabel) .and. !Empty(cIdHex)
			Aviso("SPED",STR0138,{STR0058},3) //"Para o tipo de certificado HSM, os campos Label e ID Hexadecimal não podem ser preenchidos simultaneamente."
			lRetorno := .F.
		else
			cIdEnt := AllTrim(TAFRIdEnt(,,,,,.T.))
			If nTipo <> 3 .And. !File(cCert)
				Aviso("SPED",STR0077,{STR0058},3) //"Arquivo não encontrado"
				lRetorno := .F.
			EndIf
			If nTipo == 1 .And. !File(cKey) .And. lRetorno
				Aviso("SPED",STR0077,{STR0058},3) //"Arquivo não encontrado"
				lRetorno := .F.
			EndIf
			If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN  	:= "TOTVS"
				oWs:cID_ENT     	:= cIdEnt
				oWs:cCertificate	:= TfLoadTXT(cCert)
				If nTipo == 1
					oWs:cPrivateKey  := TfLoadTXT(cKey)
				EndIf
				oWs:cPASSWORD   	:= RTrim(cPassWord)
				oWS:_URL        	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
					Aviso("SPED",IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult),{STR0058},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
				EndIf
			EndIf
			If !Empty(cIdEnt) .And. lRetorno .And. nTipo == 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN   		:= "TOTVS"
				oWs:cID_ENT      	:= cIdEnt
				oWs:cSlot        	:= cSlot
				oWs:cModule      	:= AllTrim(cModulo)
				oWs:cPASSWORD    	:= AllTrim(cPassWord)
				If !Empty( cIdHex )
					oWs:cIDHEX      	:= AllTrim(cIdHex)
					oWs:cLabel      	:= ""
				Else
					oWs:cIDHEX      	:= ""
					oWs:cLabel     	:= cLabel

				EndIf
				If nTipo == 1
					oWs:cPrivateKey  	:= TfLoadTXT(cKey)
				EndIf
				oWs:cPASSWORD    	:= AllTrim(cPassWord)
				oWS:_URL         	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				If oWs:CfgHSM()
					Aviso("SPED",oWS:cCfgHSMResult,{STR0058},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0058},3)
				EndIf
			EndIf
		endif
	Else
		Aviso("SPED",STR0115,{STR0058},3) //"É Necessário preencher todos os campos que estão habilitados para a correta configuração do certificado."
		lRetorno := .F.
	EndIf
Return(lRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc} TfLoadTXT
Funcao de leitura de arquivo texto para anexar ao layout

@author Evandro dos Santos Oliveira
@since 03/02/2014
@version 1.0

@param ${cFileImp}	, ${Arquivo texto}

@return ${cTexto}, ${Nome do arquivo texto com path}

@see Função Original - FsLoadTxt 24.10.2006
/*/
//-------------------------------------------------------------------
Static Function TfLoadTXT(cFileImp)

	Local cTexto		:= ""
	local cCopia		:= ""
	local cExt			:= ""
	Local nHandle		:= 0
	Local nTamanho	:= 0




	if left(cFileImp, 1) # "\"
		CpyT2S(cFileImp,"\")
	endif

	nHandle := FOpen(cFileImp)
	nTamanho := Fseek(nHandle,0,FS_END)
	FSeek(nHandle,0,FS_SET)
	FRead(nHandle,@cTexto,nTamanho)
	FClose(nHandle)

	SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cCopia,cExt)
	FErase("\"+cCopia+cExt)

Return(cTexto)

//-------------------------------------------------------------------
/*/{Protheus.doc} XFunTAFRND
Funcao de arredondamento de valor conforme o parametro MV_TAFRND

@author Anderson Costa
@since 13/03/2014
@version 1.0

@param  ${nValor}	, ${Vaor a ser arredondado}
@param  ${nDec}	, ${Número de decimais}

@return ${lRet}, ${Retorna o valor arredondado}
/*/
//-------------------------------------------------------------------
Function XFunTAFRND(nValor,nDec)

	Local nMVTAFRND := GetNewPar( "MV_TAFRND" , '1' )
	Local lRet := 0

	Default nDec := 2

//Parametro que trata o tipo de arredondamento desejado, ARREDONDANDO (1) ou TRUNCANDO(2)
	If nMVTAFRND == '1'
		lRet := Round( nValor , nDec )
	Else
		lRet := NoRound( nValor , nDec )
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPerOpen
Função para retornar se o periodo informado existe em aberto para a filial
informada.

@Param
cFilTaf - Filial do TAF
cMes    - Mes de referência para a busca
cAno    - Ano de Referência para a busca

@Return
aRet[1] - Indicador do Periodo que foi encontrado
aRet[2] - Status do Período Encontrado

@author Rodrigo Aguilar
@since 16/05/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFPerOpen( cFilTaf, cMes, cAno )

	Local cPeriodo  := ""
	Local cChaveC8Y := ""

	Local aRet := {}

	Default cMes := ""

	cPeriodo  := Alltrim( cMes ) + Alltrim( cAno )
	cChaveC8Y := ( cFilTaf + cPeriodo )

	DbSelectArea("CUO")
	CUO->( DbSetOrder( 2 ) )

	DbSelectArea("C8Y")
	C8Y->( DbSetOrder( 3 ) )
	If C8Y->( MsSeek( cChaveC8Y ) )

		While C8Y->( !Eof() ) .And. C8Y->( C8Y_FILIAL + C8Y_PERAPU ) == cChaveC8Y

			If C8Y->C8Y_ATIVO == "1"
				If !CUO->( MsSeek( cFilTaf + C8Y->( C8Y_INDAPU + C8Y_PERAPU ) ) )
					Aadd( aRet, { C8Y->C8Y_INDAPU, C8Y->C8Y_STATUS } )
				EndIf
			EndIf
			C8Y->( DbSkip() )
		EndDo
	EndIf

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCFGWS
Rotina para retorno da Empresa/Filial contidos no arquivo
TAFWEBSERVICES.CFG

@author Evandro dos Santos Oliveira
@since 28/04/2014
@version 1.0

@return alRet[1] - Empresa
	    alRet[2] - Filial
/*/
//-------------------------------------------------------------------
Function TAFCFGWS()

	Local alRet    := {.T., "", ""}

	Local cFile   := "TAFWEBSERVICES.CFG"
	Local cBuffer := ""
	Local aEmpFil := {}
	Local nHdl    := 0

// Abre o arquivo de configuração do webservice
	nHdl := FOpen(cFile)
	If nHdl < 0
		nHdl := MSFCreate(cFile)
		If nHdl < 0
			TAFConOut("Nao foi possivel a criacao do arquivo "+cFile+". Execucao de webservices nao permitida.")
			alRet[1] := .F.
			Return alRet
		Else
			//Filtro apenas os NAO DELETADOS para abrir o SIGAMAT
			Set Delete On

			//Abro o SIGAMAT para processamento
			OpenSm0()
			DbSetIndex( "SIGAMAT.IND" )
			SM0->( DbGoTop() )

			//Pego a primeira empresa válida no sigamat
			While SM0->( !Eof() )
				If SM0->M0_CODIGO <> "99"
					aEmpFil :=  { SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME }
					SM0->( DbGoBottom() )
				EndIf
				SM0->( DbSkip() )
			EndDo

			//Volto a considerar os registros deletados na tabela
			Set Delete Off

			FWrite(nHdl, ".T.," + aEmpFil[1] + "," +  aEmpFil[2])
			FClose(nHdl)

			alRet[1] := .T.
			alRet[2] := aEmpFil[1]
			alRet[3] := aEmpFil[2]
		EndIf
	Else
		FRead(nHdl, @cBuffer, 15)
		alRet := StrTokArr (cBuffer, ",")

		If AllTrim(alRet[1]) == ".T."
			alRet[1] := .T.
		ElseIf AllTrim(alRet[1]) == ".F."
			alRet[1] := .F.
		EndIf

		alRet[2] := AllTrim(alRet[2])
		alRet[3] := AllTrim(alRet[3])
	EndIf

Return alRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInt2Hor
Converte Inteiro em Horas

@author Evandro dos Santos Oliveira
@since 13/05/2014
@version 1.0

@param nHora    - Numero de Horas
@param nDigitos - Numero de Digitos

@return cHora 	- Hora convertida
/*/
//-------------------------------------------------------------------
Function TAFInt2Hor(nHora,nDigitos)

	Local nHoras    := 0
	Local nMinutos  := 0
	Local cHora     := ""
	Local lNegativo := .F.

	lNegativo := ( nHora < 0 )

	nHora     := ABS( nHora )

	nHoras    := Int(nHora)
	nMinutos  := (nHora-nHoras)*60

	nDigitos := If( ValType( nDigitos )=="N", nDigitos, Len(cValtoChar(Int(nHora))) ) - If( lNegativo, 1, 0 )

	If nHoras > 99 .And. nHoras < 999
		cHora := If( lNegativo, "-", "" ) + StrZero( nHoras, 3 )+":"+StrZero( nMinutos, 2 )
	Else
		cHora := If( lNegativo, "-", "" ) + StrZero( nHoras, Iif(nDigitos<2,2,nDigitos) )+":"+StrZero( nMinutos, 2 )
	Endif

Return(cHora)
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSubHora
Calcula o Numero de Horas entre dois tempos.

@author Evandro dos Santos Oliveira
@since 13/05/2014
@version 1.0

@param dDataIni - Data Inicial
@param cHoraIni - Numero de Digitos
@param dDataFim - Data Final
@param cHoraFim - Hora Final

@return nExp 	- Diferença entre os horários
/*/
//-------------------------------------------------------------------
Function TAFSubHora(dDataIni,cHoraIni,dDataFim,cHoraFim)

	Local nDias := dDataFim - dDataIni
	Local nHoras:= TAFHor2Int(cHoraFim)-TAFHor2Int(cHoraIni)

Return(nHoras+(nDias*24))

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFHor2Int
Converte Horas em Inteiro.

@author Evandro dos Santos Oliveira
@since 13/05/2014
@version 1.0

@param cHora    - String no Formato "HH:MM"
@param nDigitos - Numero de Digitos

@return nExp 	- Hora convertida
/*/
//-------------------------------------------------------------------
Function TAFHor2Int(cHora,nDigitos)

	Local nHoras
	Local nMinutos
	Local nExtDigit

nExtDigit := If( ValType( nDigitos ) == "N", nDigitos - 2, 0 )

nHoras    := Val(SubStr(cHora,1,2 + nExtDigit ))
nMinutos  := Val(SubStr(cHora,4 + nExtDigit,2))/60

Return(nHoras+nMinutos)


//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFWSRet
Executa um método validando seu retorno.

@param		oWS		Objeto do serviço.
@param		cMetodo	Nome do método a ser invocado.

@return		nil

@author		Evandro dos Santos Oliveira
@since		19/05/2014
@version	1
/*/
//-----------------------------------------------------------------------
Function TAFWSRet( oWS, cMetodo )

	Local bBloco	:= {||}
	Local lRetorno	:= .F.
	Private oWS2

	DEFAULT oWS		:= NIL
	DEFAULT cMetodo	:= ""

	If ( ValType(oWS) <> "U" .And. !Empty(cMetodo) )
		oWS2 := oWS
		If ( Type("oWS2") <> "U" )
			bBloco 	:= &("{|| oWS2:"+cMetodo+"() }")
			lRetorno:= eval(bBloco)
			If ( lRetorno == NIL )
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGeraID
Retorna o Id da função FWUUI

@author Fabio Vessoni santana
@since 02/06/2014
@version 1.0

@param cString - String

@return ID 	- Id gerado pela função FWUUID
/*/
//-------------------------------------------------------------------
Function TAFGeraID( cString )

	Local cID	:=	""

	Default cString	:=	"TAF"

	If FWIsInCallStack( "TafPrepInt" )
		cString := AllTrim( Str( ThreadID() ) ) + FWTimeStamp( 4 ) + StrTran( AllTrim( Str( Seconds() ) ), ".", "" )
	EndIf

	cID := FWuuId( cString )

Return( cID )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafVirtual
Esta função tem como objetivo apenas indicar no mile quais são os campos
virtuais que são utilizados no Mile, considerando o conceito do ECF.

@Author Rodrigo Aguilar
@since 26/06/2014
@version 1.0

@param cCodigo - Codigo enviado na importacao Mile

@return cCodigo - Codigo enviado no arquivo Mile
/*/
//-------------------------------------------------------------------
Function xTafVirtual( cCodigo )
Return ( cCodigo )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMsgDel
Esta função tem como objetivo definir a mensagem de erro que será
 exibida após o SaveModel retornar falso.

Exemplo de utilização:
TAFA260 - Ao excluir registro que já foi transmitido, a rotina exibia
 um aviso de que a exclusão só poderia ser feita utilizando-se o
 evento S-2900. Porém, ao final exibia uma segunda mensagem de
 registro excluído com sucesso.

@Author Anderson Costa
@since 01/10/2014
@version 1.0

@param oModel - Modelo que terá a mensagem de erro redefinida
       lCad		- Indica se tipo do evento é cadastral

/*/
//-------------------------------------------------------------------
Function TAFMsgDel( oModel, lCad )

	Default lCad := .F.

	If lCad
		oModel:SetErrorMessage(, , , , , STR0099, , , ) // "Registro de exclusão já transmitido, portanto não pode ser excluído."
	Else
		oModel:SetErrorMessage(, , , , , STR0081, STR0082, , ) // "Este evento encontra-se transmitido." + "A exclusão deste registro deverá ser feita através do evento S-2900."
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafBldKey

Build Key

Monta a chave a ser utilizada na validacao do campo( xFunVldCmp )

@Param:
lChave -> chave composta
cTxtCont -> conteúdo do arquivo texto importado
cCampoMile -> Campo mile
@Return:
cKey - Chave a ser utilizada na validacao

@Author Felipe C. Seolin
@Since 26/09/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Function xTafBldKey(lChave,cTxtCont,cCampoMile)

	Local cCmp    := ""
	Local cReg    := ""
	Local cCod    := ""
	Local cCod2   := ""
	Local cTam    := ""
	Local cTamCod := ""
	Local cKey    := ""
	Local cKey2   := ""
	Local cUF	  := ""
	Local cOperac := ""
	Local cEstSM0 := ''
	Local cChv	  := ''
	Local aGetCH8 := {}
	Local cDtIni  := Space(8)
	Local cDtFim  := Space(8)

	default lChave    := .F.
	default cTxtCont  := ""
	default cCampoMile:= ""

	cCmp:= IIF(!Empty(cCampoMile),cCampoMile,ReadVar())

	DBSELECTAREA("C09")
	C09->(DBSETORDER(1))

	If AllTrim( SubStr( cCmp , 4 ) ) $ "CFT_CODLAN"

		If FunName() == "TAFA332"
			If "X291" $ Upper( FunDesc() )
				cReg := "X291"
			ElseIf "X292" $ Upper( FunDesc() )
				cReg := "X292"
			ElseIf "X360" $ Upper( FunDesc() )
				cReg := "X360"
			ElseIf "X390" $ Upper( FunDesc() )
				cReg := "X390"
			ElseIf "X400" $ Upper( FunDesc() )
				cReg := "X400"
			ElseIf "X460" $ Upper( FunDesc() )
				cReg := "X460"
			ElseIf "X470" $ Upper( FunDesc() )
				cReg := "X470"
			ElseIf "X480" $ Upper( FunDesc() )
				cReg := "X480"
			ElseIf "X490" $ Upper( FunDesc() )
				cReg := "X490"
			ElseIf "X500" $ Upper( FunDesc() )
				cReg := "X500"
			ElseIf "X510" $ Upper( FunDesc() )
				cReg := "X510"
			EndIf
		Else
			cReg := FwFldGet( "CFT_REGECF" )
		EndIf

		cCod := "CFT_CODLAN"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CH5_CTAREF|CAE_CTAREF|CAG_CTAREF"

		If FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "01"
			cReg := "L100A"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "02"
			cReg := "L100B"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "03"
			cReg := "L100C"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "04"
			cReg := "L300A"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" )== "05"
			cReg := "L300B"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "06"
			cReg := "L300C"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "07"
			cReg := "P100"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "08"
			cReg := "P150"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "09"
			cReg := "U100A"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "10"
			cReg := "U100B"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "11"
			cReg := "U100C"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "12"
			cReg := "U100D"
		ElseIf FwFldGet( allTrim( subStr( cCmp , 4 , 3 ) ) + "_TABECF" ) == "13"
			cReg := "U100E"
		EndIf

		cCod := allTrim( subStr( cCmp , 4 , 3 ) ) + "_CTAREF"
		cTam := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAQ_CODCTA"

		If FwFldGet( "CAQ_REGECF" ) == "1"
			cReg := "L100A"
		ElseIf FwFldGet( "CAQ_REGECF" ) == "2"
			cReg := "L100B"
		ElseIf FwFldGet( "CAQ_REGECF" ) == "3"
			cReg := "L100C"
		EndIf

		cCod := "CAQ_CODCTA"
		cTam := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAT_CODCTA"

		If FwFldGet( "CAT_REGECF" ) == "1"
			cReg := "L300A"
		ElseIf FwFldGet( "CAT_REGECF" ) == "2"
			cReg := "L300B"
		ElseIf FwFldGet( "CAT_REGECF" ) == "3"
			cReg := "L300C"
		EndIf

		cCod := "CAT_CODCTA"
		cTam := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEK_CODCTA"

		If FwFldGet( "CEK_REGECF" ) == "01"
			cReg := "T120"
		ElseIf FwFldGet( "CEK_REGECF" ) == "02"
			cReg := "T150"
		ElseIf FwFldGet( "CEK_REGECF" ) == "03"
			cReg := "T170"
		ElseIf FwFldGet( "CEK_REGECF" ) == "04"
			cReg := "T181"
		EndIf

		cCod := "CEK_CODCTA"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CEO_CODLAN|CHR_CODLAN|CFR_CODLAN|LE9_CODLAN"

		If FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "1"
			cReg := "M300A"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "2"
			cReg := "M300B"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "3"
			cReg := "M300C"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "4"
			cReg := "M350A"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "5"
			cReg := "M350B"
		ElseIf FWFldGet( AllTrim( SubStr( cCmp, 4, 3 ) ) + "_REGECF" ) == "6"
			cReg := "M350C"
		EndIf

		cCod := AllTrim( SubStr( cCmp, 4, 3 ) ) + "_CODLAN"
		cTam := "CH8_CODREG"
		cTamCod := "CH8_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAS_CODCTA" //L210

		cReg := "L210"
		cCod := "CAS_CODCTA"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CAU_CODCTA" //L400

		cReg := "L400"
		cCod := "CAU_CODCTA"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CGX_CODCTA" //Y681

		cReg := "Y681"
		cCod := "CGX_CODCTA"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEI_CODIGO"

		If FwFldGet( "CEI_REGECF" ) == "01"
			cReg := "P130"
		ElseIf FwFldGet( "CEI_REGECF" ) == "02"
			cReg := "P200"
		ElseIf FwFldGet( "CEI_REGECF" ) == "03"
			cReg := "P230"
		ElseIf FwFldGet( "CEI_REGECF" ) == "04"
			cReg := "P300"
		ElseIf FwFldGet( "CEI_REGECF" ) == "05"
			cReg := "P400"
		ElseIf FwFldGet( "CEI_REGECF" ) == "06"
			cReg := "P500"
		EndIf

		cCod := "CEI_CODIGO"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CFI_CODIGO"

		If FwFldGet( "CFI_REGECF" ) == "01"
			cReg := "U180"
		ElseIf FwFldGet( "CFI_REGECF" ) == "02"
			cReg := "U182"
		EndIf

		cCod := "CFI_CODIGO"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "V1S_CODLAN" //V100

		cReg := "V100"
		cCod := "V1S_CODLAN"
		cTam := "CH6_CODREG"
		cTamCod := "CH6_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CEZ_CODCTA"

		If FwFldGet( "CEZ_TABECF" ) == "1"
			cReg := "U100A"
		ElseIf FwFldGet( "CEZ_TABECF" ) == "2"
			cReg := "U100B"
		ElseIf FwFldGet( "CEZ_TABECF" ) == "3"
			cReg := "U100C"
		ElseIf FwFldGet( "CEZ_TABECF" ) == "4"
			cReg := "U100D"
		ElseIf FwFldGet( "CEZ_TABECF" ) == "5"
			cReg := "U100E"
		EndIf

		cCod := "CEZ_CODCTA"
		cTam := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CHA_CTASUP"

		cReg    := FwFldGet( "CHA_CODREG" )
		cCod    := "CHA_CTASUP"
		cTam    := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf AllTrim( SubStr( cCmp , 4 ) ) $ "CHG_CODIGO"

		cReg := FwFldGet( "CHG_TABECF" )

		If cReg == '1'
			cReg:= "U150A"
		Elseif cReg == '2'
			cReg:= "U150B"
		Elseif cReg == '3'
			cReg:= "U150C"
		Elseif cReg == '4'
			cReg:= "U150D"
		Elseif cReg == '5'
			cReg:= "U150E"
		Endif

		cCod := "CHG_CODIGO"
		cTam := "CHA_CODREG"
		cTamCod := "CHA_CODIGO"

	ElseIf (AllTrim( cCmp ) $ "C2T_SUBITE|C2T_IDSUBI|") .or. (AllTrim( cCmp ) $ "M->C2T_SUBITE|M->C2T_IDSUBI|")

		cOperac := '0'
		cCod2   := IIf(! Empty(cTxtCont),cTxtCont,M->C2T_SUBITE )

		If !Empty(Alltrim(cCod2))
			cKey2:= cCod2+cOperac+XFUNUFID()
		Endif

	ElseIf ( AllTrim( cCmp ) $ "C3K_SUBITE|C3K_IDSUBI" ) .or. ( AllTrim( cCmp ) $ "M->C3K_SUBITE|M->C3K_IDSUBI|" )

		cOperac := '1'
		cCod2   := Strtran(IIf(! Empty(cTxtCont),cTxtCont,M->C3K_SUBITE ),".","")

		If !Empty(Alltrim(cCod2))
			cKey2:= cCod2+cOperac+XFUNUFID()
		Endif

	ElseIf (AllTrim( cCmp ) $ "C2D_SUBITE|C2D_IDSUBI") .OR. (AllTrim( cCmp ) $ "M->C2D_SUBITE|M->C2D_IDSUBI|")

		DBSELECTAREA("C09")
		C09->(DBSETORDER(1))
		cEstSM0 := GetAdvFVal( 'SM0', 'M0_ESTCOB', C2D->C2D_FILIAL , 1 )
		If (DBSEEK(xFilial("C09")+cEstSM0))
			cUF:=	C09->C09_ID
		Endif

		If !Empty(cTxtCont)
			cOperac := iif(SubStr( cTxtCont,1,1 ) != '1', '0', '1')
			cCod2   := StrTran(Substr(cTxtCont,2),".","")
		Else
			cOperac := iif( SubStr( Posicione("C0J",3,xFilial("C0J") + FWFLDGET("C2D_CODAJ"),"C0J_CODIGO"), 4,1 ) != '1' , '0', '1')
			cCod2   := M->C2D_SUBITE
		Endif

		If !Empty(Alltrim(cCod2))
			cKey2:= cCod2+cOperac+cUF
		Endif

//Essa conversão foi migrada para a função XFUNSpcMIL devido a complexidade, validações e concatenção de campos
	ElseIf ( AllTrim( cCmp ) $ "C35_IDMINC" ) //.and. Len( cTxtCont ) >= 12 )

	/*If !Empty( cTxtCont )
		cKey2 := AllTrim( cTxtCont ) + AllTrim( xFunUFID() )
	EndIf*/

	cKey2 := ""

ElseIf AllTrim( cCmp ) $ "C2T_IDTMOT|C3K_IDTMOT|C2D_IDTMOT"

	If !Empty( cTxtCont )
		cCod2 := SubStr( cTxtCont, 1 )
	Else
		//cOperac := SubStr( Posicione( "C0J", 3, xFilial( "C0J" ) + FWFLDGET( "C2D_CODAJ" ), "C0J_CODIGO" ), 4, 1 )
		//cCod2 := M->C2D_SUBITE
	EndIf

	If !Empty( AllTrim( cCod2 ) )
		cKey2 := cCod2 + XFunUFID()
	EndIf

EndIf

IF lChave
	cKey:= cKey2
Else
	cKey := PadR( cReg, TamSX3( cTam )[1] ) + Substr(FwFldGet( cCod ),1,TamSX3( cTamCod )[1])
	if "LE9_CODLAN" $ ReadVar()
		aGetCH8 := CH8->(GetArea())
		CH8->(DbSetOrder(2)) //CH8_FILIAL, CH8_CODREG, CH8_CODIGO, CH8_DTINI, CH8_DTFIN
		cChv := xFilial("CH8") + cKey
		if CH8->(DbSeek( cChv ))
			While CH8->(!EOF()) .And. CH8->(CH8_FILIAL+CH8_CODREG+CH8_CODIGO) == cChv
				cDtIni := DtoS(CH8->CH8_DTINI)
				cDtFim := DtoS(CH8->CH8_DTFIN)
				CH8->(DbSkip())
			EndDo
			cKey += cDtIni + cDtFim
		EndIf
		RestArea(aGetCH8)
	endif
Endif

Return( cKey )

//-------------------------------------------------------------------
/*/{Protheus.doc} xMileToEcf

Mile To ECF

Monta a chave a ser utilizada no Mile na função( XFUNCh2ID )

@Param:

@Return:
cKey - Chave utiliza na função XFUNCh2ID para retornar o ID do registro no Mile

@Author Denis R. de Oliveira
@Since 07/10/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Function xMileToEcf( cRegECF, cCampo, cConteud )

	Local cReg := ""
	Local cKey := ""

	If AllTrim( cCampo ) $ "CH5_CTAREF|CAE_CTAREF|CAG_CTAREF"

		If Alltrim(cRegECF) == "01"
			cReg := "L100A"
		ElseIf Alltrim(cRegECF) == "02"
			cReg := "L100B"
		ElseIf Alltrim(cRegECF) == "03"
			cReg := "L100C"
		ElseIf Alltrim(cRegECF) == "04"
			cReg := "L300A"
		ElseIf Alltrim(cRegECF) == "05"
			cReg := "L300B"
		ElseIf Alltrim(cRegECF) == "06"
			cReg := "L300C"
		ElseIf Alltrim(cRegECF) == "07"
			cReg := "P100"
		ElseIf Alltrim(cRegECF) == "08"
			cReg := "P150"
		ElseIf Alltrim(cRegECF) == "09"
			cReg := "U100A"
		ElseIf Alltrim(cRegECF) == "10"
			cReg := "U100B"
		ElseIf Alltrim(cRegECF) == "11"
			cReg := "U100C"
		ElseIf Alltrim(cRegECF) == "12"
			cReg := "U100D"
		ElseIf Alltrim(cRegECF) == "13"
			cReg := "U100E"
		ElseIf Alltrim(cRegECF) == "14"
			cReg := "U150A"
		ElseIf Alltrim(cRegECF) == "15"
			cReg := "U150B"
		ElseIf Alltrim(cRegECF) == "16"
			cReg := "U150C"
		ElseIf Alltrim(cRegECF) == "17"
			cReg := "U150D"
		ElseIf Alltrim(cRegECF) == "18"
			cReg := "U150E"
		EndIf

	ElseIf AllTrim( cCampo ) == "CAQ_CODCTA"

		If Alltrim(cRegECF) == "1"
			cReg := "L100A"
		ElseIf Alltrim(cRegECF) == "2"
			cReg := "L100B"
		ElseIf Alltrim(cRegECF) == "3"
			cReg := "L100C"
		EndIf

	ElseIf AllTrim( cCampo ) == "CAT_CODCTA"

		If Alltrim(cRegECF) == "1"
			cReg := "L300A"
		ElseIf Alltrim(cRegECF) == "2"
			cReg := "L300B"
		ElseIf Alltrim(cRegECF) == "3"
			cReg := "L300C"
		EndIf

	ElseIf AllTrim( cCampo ) == "CEK_CODCTA"

		If Alltrim(cRegECF) == "01"
			cReg := "T120"
		ElseIf Alltrim(cRegECF) == "02"
			cReg := "T150"
		ElseIf Alltrim(cRegECF) == "03"
			cReg := "T170"
		ElseIf Alltrim(cRegECF) == "04"
			cReg := "T181"
		EndIf

	ElseIf AllTrim( cCampo ) $ "CEO_CODLAN|CHR_CODLAN|CFR_CODLAN"

		If Alltrim(cRegECF) == "1"
			cReg := "M300A"
		ElseIf Alltrim(cRegECF) == "2"
			cReg := "M300B"
		ElseIf Alltrim(cRegECF) == "3"
			cReg := "M300C"
		ElseIf Alltrim(cRegECF) == "4"
			cReg := "M350A"
		ElseIf Alltrim(cRegECF) == "5"
			cReg := "M350B"
		ElseIf Alltrim(cRegECF) == "6"
			cReg := "M350C"
		EndIf

	ElseIf AllTrim( cCampo ) == "CAS_CODCTA"

		cReg := "L210"

	ElseIf AllTrim( cCampo ) == "CAU_CODCTA"

		cReg := "L400"

	ElseIf AllTrim( cCampo ) == "CEH_CODCTA"

		cReg := "P100"

	ElseIf AllTrim( cCampo ) == "CGX_CODCTA"

		cReg := "Y681"

	ElseIf AllTrim( cCampo ) == "CEI_CODIGO"

		If Alltrim(cRegECF) == "01"
			cReg := "P130"
		ElseIf Alltrim(cRegECF) == "02"
			cReg := "P200"
		ElseIf Alltrim(cRegECF) == "03"
			cReg := "P230"
		ElseIf Alltrim(cRegECF) == "04"
			cReg := "P300"
		ElseIf Alltrim(cRegECF) == "05"
			cReg := "P400"
		ElseIf Alltrim(cRegECF) == "06"
			cReg := "P500"
		EndIf

	ElseIf AllTrim( cCampo ) == "CFI_CODIGO"

		If Alltrim(cRegECF) == "01"
			cReg := "U180"
		ElseIf Alltrim(cRegECF) == "02"
			cReg := "U182"
		EndIf

	ElseIf AllTrim( cCampo ) == "CEZ_CODCTA"

		If Alltrim(cRegECF) == "1"
			cReg := "U100A"
		ElseIf Alltrim(cRegECF) == "2"
			cReg := "U100B"
		ElseIf Alltrim(cRegECF) == "3"
			cReg := "U100C"
		ElseIf Alltrim(cRegECF) == "4"
			cReg := "U100D"
		ElseIf Alltrim(cRegECF) == "5"
			cReg := "U100E"
		EndIf

	ElseIf AllTrim( cCampo ) == "CEB_CODLAN"

		If Alltrim(cRegECF) == "01"
			cReg := "N500"
		ElseIf Alltrim(cRegECF) == "02"
			cReg := "N600"
		ElseIf Alltrim(cRegECF) == "03"
			cReg := "N610"
		ElseIf Alltrim(cRegECF) == "04"
			cReg := "N620"
		ElseIf Alltrim(cRegECF) == "05"
			cReg := "N630A"
		ElseIf Alltrim(cRegECF) == "06"
			cReg := "N630B"
		ElseIf Alltrim(cRegECF) == "07"
			cReg := "N650"
		ElseIf Alltrim(cRegECF) == "08"
			cReg := "N660"
		ElseIf Alltrim(cRegECF) == "09"
			cReg := "N670"
		EndIf

	ElseIf AllTrim( cCampo ) == "CHE_CODCTA"

		cReg := "P150"

	ElseIf AllTrim( cCampo ) == "CHG_TABECF"

		If Alltrim(cRegECF) == "1"
			cReg := "U150A"
		Elseif Alltrim(cRegECF) == "2"
			cReg := "U150B"
		Elseif Alltrim(cRegECF) == "3"
			cReg := "U150C"
		Elseif Alltrim(cRegECF) == "4"
			cReg := "U150D"
		Elseif Alltrim(cRegECF) == "5"
			cReg := "U150E"
		Endif

	ElseIf AllTrim( cCampo ) == "CFR_CODLAN"

		If Alltrim(cRegECF) == "1"
			cReg := "U150A"
		Elseif Alltrim(cRegECF) == "2"
			cReg := "U150B"
		Elseif Alltrim(cRegECF) == "3"
			cReg := "U150C"
		Elseif Alltrim(cRegECF) == "4"
			cReg := "U150D"
		Elseif Alltrim(cRegECF) == "5"
			cReg := "U150E"
		Endif

	ElseIf AllTrim( cCampo ) == "V1S_CODLAN"

		cReg := "V100"

	EndIf

	If !Empty(cConteud) .And. AllTrim( SubStr( cReg , 1, 4 ) ) $ "L210|L400|N500|N600|N610|N620|N630A|N630B|N650|N660|N670|P130|P200|P230|P300|P400|P500|T120|T150|T170|T181|U180|U182|V100|X291|X292|X390|X400|X460|X470|X480|X490|X500|X510|Y681"

		cKey := PadR( cReg, TamSX3( "CH6_CODREG" )[1] )

	ElseIf !Empty(cConteud) .And. AllTrim( SubStr( cReg , 1, 4 ) ) $ "M300|M350"

		cKey := PadR( cReg, TamSX3( "CH8_CODREG" )[1] )

	ElseIf !Empty(cConteud) .And. AllTrim( SubStr( cReg , 1, 4 ) ) $ "L100|L300|P100|P150|U100|U150"

		cKey := PadR( cReg, TamSX3( "CHA_CODREG" )[1] )

	EndIf

Return( cKey )

//-------------------------------------------------------------------
/*/{Protheus.doc} xValWizCmp
Funcao que valida conteudo digitado nos campos da wizard, conforme
parametros enviados.

@param 	nVal  		- 	Numero da Validação a ser realizada
		aInfo		-   Informações do campo a ser validado
		aObj  		- 	Objeto que esta sendo validado ( conteúdo do campo )
		aPosterior	-	Informação do campo subsequente
		aAnterior	-	Informação do campo anterior
		aCmpsPan 	- 	Objetos do Painel Corrente
		aAllCmps	- 	Objetos de todos os Paineis

@return lRet -	Conteudo validado ou nao.

@author Evandro dos Santos Oliveira
@since 29/10/2014
@version 1.0
@obs Essa validação é executada quando no array de dados é enviado a 12
posição que valida os campos na ação do botão  NEXT da Wizard com auxilio
da função xValWizd.
/*/
//-------------------------------------------------------------------
Function xValWizCmp( nVal, aInfo, aObj, aPosterior, aAnterior, aCmpsPan, aAllCmps )

	Local lRet			:=	.T.
	Local nX			:=	0
	Local cContent	:=	""
	Local aCmpsPanel	:= {}
	Local aAuxCmps	:= {}


	Default nVal		:=	0
	Default aInfo		:=	{}
	Default aObj		:=	{}

	If Len( aObj ) > 0
		If ValType( aObj[1] ) == "D"
			cContent := AllTrim( DToS( aObj[1] ) )
		ElseIf ValType( aObj[1] ) == "N"
			cContent := AllTrim( cValToChar( aObj[1] ) )
		Else
			cContent := AllTrim( aObj[1] )
		EndIF
	EndIf

//Retiro os objetos Null, desta forma ficam no array somente os objetos reais da tela
	aEval(aCmpsPan,{|x| IIf(!Empty(x[2]),aAdd(aCmpsPanel,x),) })

	Do Case

	Case nVal == 1

		If !Empty( cContent )
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + AllTrim( aObj[1] ) )
				MsgInfo( STR0083 ) //"Contabilista não cadastrado."
				lRet := .F.
			EndIf
		EndIf

	Case nVal == 2

		If Empty( cContent )
			MsgInfo( STR0084 ) //"Período de escrituração não informado."
			lRet := .F.
		Else
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + cContent, .T. )
				MsgInfo( STR0085 ) //"Período de escrituração não cadastrado."
				lRet := .F.
			EndIf
		EndIf

	Case nVal == 3

		//"Diretório do arquivo de destino não Existe."
		If !Empty( cContent ) .and. !ExistDir( cContent )
			MsgInfo( STR0122 ) //"Diretório do arquivo de destino não Existe."
			lRet := .F.
		Else
			If Empty( cContent )
				MsgInfo( STR0086 ) //"Diretório do arquivo de destino não informado."
				lRet := .F.
			EndIf
		EndIf

	Case nVal == 4

		If Empty( cContent )
			MsgInfo( STR0087 ) //"Nome do arquivo de destino não informado."
			lRet := .F.
		EndIf

	Case nVal == 5

		If Empty( cContent )
			MsgInfo( STR0094 ) //"Versão não informada."
			lRet := .F.
		Else
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + cContent, .T. )
				MsgInfo( STR0095 ) //"Versão não cadastrada."
				lRet := .F.
			ElseIf aInfo[1] == "CZV" .and. FindFunction("TAFECFVer")
				If !TAFECFVer(cContent)
					MsgInfo( STR0217 ) //"Ambiente desatualizado para a versão selecionada, é necessário executar o UPDDISTR do último pacote do TAF disponível para download no portal do cliente. "
					lRet := .F.
				EndIf
			EndIf
		EndIf

	Case nVal == 6

		/*REGRA_REC_ANTERIOR_OBRIGATORIO
		Verifica, quando o campo 0000.RETIFICADORA é igual a "S" ( ECF Retificadora )
		ou "F" ( ECF original com mudança de forma de tributação ), se 0000.NUM_REC está preenchido.*/
		If SubStr( aAnterior[1], 1, 1 ) $ "S|F" .and. Empty( cContent )
			MsgInfo( STR0096 ) //"Quando o campo 'Escrituração Retificadora?' for igual a 'S' ( ECF Retificadora ) ou 'F' ( ECF original com mudança de forma de tributação ), o campo 'Número do Recibo da ECF Anterior' deve estar preenchido."
			lRet := .F.

		/*REGRA_NRO_REC_ANTERIOR_NAO_SE_APLICA
		Verifica, quando 0000.RETIFICADORA é igual a "N" ( ECF Original ), se 0000.NUM_REC não está preenchido.*/
		ElseIf SubStr( aAnterior[1], 1, 1 ) $ "N" .and. !Empty( cContent )
			MsgInfo( STR0097 ) //"Quando o campo 'Escrituração Retificadora?' for igual a 'N' ( ECF Original ), o campo 'Número do Recibo da ECF Anterior' não deve estar preenchido."
			lRet := .F.
		EndIf

	Case nVal == 7 //Valida Banco
		If !Empty( cContent )
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + AllTrim( aObj[1] ) )
				MsgInfo( STR0119 ) //"Código de Banco inválido"
				lRet := .F.
			EndIf
		EndIf
	Case nVal == 8 //Valida Agência
		If !Empty( aAnterior[1] )
			If cContent == "0"
				MsgInfo( STR0120 ) //"Código de Agência não informado"
				lRet := .F.
			EndIf
		EndIf
	Case nVal == 9 //Valida Conta
		If !Empty( aAnterior[1] )
			If Empty(cContent)
				MsgInfo( STR0121 ) //"Código de Conta não informado"
				lRet := .F.
			EndIf
		EndIf
	Case nVal == 10 //Valida Banco
		If !Empty( cContent )
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + AllTrim( aObj[1] ) )
				MsgInfo( STR0119 ) //"Código do Município inválido"
				lRet := .F.
			EndIf
		EndIf

	Case nVal == 11
		lRet := TAFCTSpd(cContent,1,.T.,"",.T.) //,TAFCfAmb(oAmb:nAt,oServ:nAt)

	/*	If lRet
			xFunVldWiz( "CFG-CERTIFICADO" , aObj, aPosterior, aAnterior, aAllCmps )
	EndIf  */

Case nVal == 12 .Or. nVal == 13

		//Pego somente os Campos, faço isso por que os objetos de Input estão sempre nas posições de numeros pares.
	For nX := 1 To Len(aCmpsPanel)
		If Mod(nX,2) == 0
				aAdd(aAuxCmps,aCmpsPanel[nX])
		EndIf
	Next nX

	If nVal == 12

			// Chamada Antecipada para gravar o CNPJ/CPF antes de executar a TAFCTrsf
		If lRet .And. Len( aAuxCmps) > 8
				lDocValid 	:= .F.

			If GetVersao(.f.) < '12'
					nPosCNPJ 	:= 9
			Else
					nPosCNPJ 	:= 15
			EndIf

			If Empty(aAuxCmps[nPosCNPJ][1])
					lDocValid := .T.
			Else
				If CGC(aAuxCmps[nPosCNPJ][1] ,,.F.) // Verifica se é um documento valido
						lDocValid := .T.
				Else
						MsgInfo( "CNPJ/CPF do transmissor inválido: "+ aAuxCmps[nPosCNPJ][1])
				EndIf
			EndIf
			If lDocValid
					DbSelectArea("C1E")
					DbSetOrder(3)
				If C1E->( DbSeek( xFilial( "C1E" ) + PadR( SM0->M0_CODFIL , TamSX3( 'C1E_FILTAF' )[1] ) + '1' ) )
						RecLock( "C1E", .F. )
						C1E->C1E_CNPJTR := aAuxCmps[nPosCNPJ][1]//"CNPJ" do transmissor
						MsUnlock()
				EndIf
			EndIf
		EndIf

		if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				lRet := TAFCTrsf(aAuxCmps[1][2]:nAt,aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[6][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[7][1],aAuxCmps[8][1])
		else
				lRet := TAFCTrsf(aAuxCmps[1][2]:nAt,aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[6][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[7][1],"")
		endif
	Else
			lRet := TAFCMail(1,aAuxCmps[1][1],aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[6][1],aAuxCmps[7][1],aAuxCmps[8][1],.F.)
	EndIf

	Case nVal == 14
		IF EMPTY( aObj[1] )
			ApMsgStop( 'O Campo EvtAdic não foi preenchido!' )
			lRet := .F.
		EndIf
		
OtherWise

	lRet := .F.

EndCase

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xValWizd
Verifica se há validações nos campos do Painel Atual

@param 	aPanel		- Array com os Paineis da Wizard
		nPan		- Numero do Painel Corrente
		aVarPan	- Conteudos dos Campos
		oWizard    - Objeto criado para Wizard

@return lRet -	Conteudo validado ou nao

@author Evandro dos Santos Oliveira
@since 29/10/2014
@version 1.0

@Alter by Rodrigo Aguilar
Incluído parâmetro oWizard na função para que seja usado nas funções macro
executadas como validação nesta rotina, não APAGAR este parametro

/*/
//-------------------------------------------------------------------
Function xValWizd(aPanel,nPan,aVarPan,oWizard)

	Local nPanel 		:= 0
	Local nX 			:= 0
	Local aFunParGet 	:= {}
	Local bValidGet  	:= {||}
	Local lRet			:= .T.

	nPanel := nPan -1

	For nX := 1 To Len(aPanel[nPanel][3])
		If Len(aPanel[nPanel][3][nX]) >= 12 .and. lRet
			aFunParGet := aPanel[nPanel][3][nX][12]
			//Verifica se utiliza validacao do conteudo do campo na wizard. Executa bloco de codigo conforme funcao e parametros enviados
			If !Empty(aFunParGet) .And. ValType(aFunParGet) == "A"
				aFunparGet[2]	:=	Iif ( ValType(aFunparGet[2])=="N",	Str(aFunparGet[2]),	aFunparGet[2] )
				aAdd(aFunParGet,Alltrim ( Iif ( ValType(cTpContObj)=="N",Str(cTpContObj),cTpContObj) ) )
				bValidGet	:=	& ( "{|| " + aFunParGet[1] + "(" + aFunParGet[2] + ", {'" + aFunParGet[3,1] + "','" + aFunParGet[3,2] + "'}, aVarPan[" + Str( nPanel ) + "," + Str( nX ) + "], aVarPan[" + Str( nPanel ) + "," + Str( nX + 1 ) + "], aVarPan[" + Str( nPanel ) + "," + Str( nX - 1 ) + "],aVarPan[" + Str( nPanel ) + "],aVarPan) }" )
				lRet := Eval(bValidGet)
			Endif
		EndIf
	Next nX
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xIdentXML

Realiza a Identação de um arquivo XML.

@param	 cXml - Arquivo texto contendo o xml a ser identado.

@return cXmlIdent - Xml normalizado

@author Evandro dos Santos Oliveira
@since 21/10/2014
@version 1.0

@obs Essa função foi homologada utilizando o XML retornado pelo SEFAZ
/*/
//-------------------------------------------------------------------
Function xIdentXML(cXml)

	Local cXmlIdent 	:= ""
	Local nX 			:= 0
	Local cNomeTag 		:= ""
	Local cConteud 		:= ""
	Local aPilha  		:= {}
	Local cPosAtu		:= ""
	Local cSitTag 		:= ""
	Local cTagAtrib		:= ""

	//----------------------------------------------------------------------------------------------------
	//|cSitTag - Situação da Tag
	//|
	//|I=Inicio   - Indica que o caracter posicionado (nX) corresponde a uma Tag de Abertura
	//|F=Fim      - Indica que o caracter posicionado (nX) corresponde a uma Tag de Fechamento
	//|N=Normal   - Indica que o caracter posicionado (nX) corresponde ao conteudo da Tag
	//|E=Especial - Indica que o caracter posicionado (nX) corresponde a uma Tag de Comentario <!nononono>

	For nX := 1 To Len(cXml)
		cPosAtu := Substr(cXml,nX,1)

		If (cPosAtu == "<")
			If Substr(cXml,nX+1,1) == "/"
				cSitTag := "F"
			ELseIf Substr(cXml,nX+1,1) == "!"
				cSitTag := "E"
			Else
				cSitTag := "I"
			EndIf

			// Se o Anterior for uma fecha de Taf (inicial) eu quebro a linha
			If Substr(cXml,nX-1,1) == ">"
				cXmlIdent += Space(4 * Len(aPilha)) + CRLF
				If cSitTag == "F"
					cXmlIdent += Space(4 * (Len(aPilha)-1)) //Tamanho da Pilha -1 por que lá em baixo eu vou retirar um item da pilha
				EndIf
			EndIf

		ElseIf (cPosAtu == ">")

			If cSitTag == "F"

				cNomeTag := Right(cNomeTag,Len(cNomeTag)-1)

				If Len(aPilha) > 1
					If aTail(aPilha)[1] == IIf(Len(aTail(aPilha)[1]) > Len(cNomeTag),PADR(cNomeTag,Len(aTail(aPilha)[1])),cNomeTag ) //PADR(cNomeTag,Len(aTail(aPilha)[1]))
						aDel(aPilha,Len(aPilha))
						aSize(aPilha,Len(aPilha)-1)
						cXmlIdent += cConteud + "</"+cNomeTag+">"
					Else
						aAdd(aPilha,{cNomeTag,cTagAtrib})
						cXmlIdent += Space(4 * Len(aPilha))
						cXmlIdent += cConteud + "</"+cNomeTag+">" + CRLF
					EndIf
				EndIf
				cTagAtrib := ""
				cConteud  := ""
			ElseIf cSitTag == "E"
				cXmlIdent += Space(4 * Len(aPilha)) + "<"+cNomeTag+">"
			Else
				If Len(aPilha) > 0
					If aTail(aPilha)[1] <> IIf(Len(aTail(aPilha)[1]) > Len(cNomeTag),PADR(cNomeTag,Len(aTail(aPilha)[1])),cNomeTag ) //Tratamento para verificar se a String da direita é menor que a da esquerda.. ver TEC-482
						cXmlIdent += Space(4 * Len(aPilha))
						aAdd(aPilha,{cNomeTag,cTagAtrib})
					EndIf
				Else
					aAdd(aPilha,{cNomeTag,cTagAtrib})
				EndIf

				If Empty(AllTrim(cTagAtrib))
					cXmlIdent += "<"+cNomeTag+">"
				Else
					cXmlIdent += "<"+cTagAtrib+">"
				EndIf
			EndIf

			cSitTag   := "N"
			cNomeTag  := ""
			cTagAtrib := ""
		ElseIf cSitTag  <> "N"
			//Tenho que quebrar o nome da tag (abertura) quando eu acho um espaço em branco
			//para coincidir com o nome final da tag
			If cSitTag == "I" .And. Empty(AllTrim(cPosAtu))
				cTagAtrib := xQrbEspc(@nX,@cPosAtu,@cXml,cNomeTag)
			Else
				cNomeTag += cPosAtu
			EndIf
		Else
			cConteud += cPosAtu
		EndIf


	Next nX

	//Retira o Ultimo elemento da Pilha
	If Len(aPilha) > 0
		If SubStr(cXmlIdent,Len(cXmlIdent),1) == ">"
			cXmlIdent += cConteud
		EndIf
		cXmlIdent += "</"+aTail(aPilha)[1]+">"
	EndIf

Return (cXmlIdent)

//-------------------------------------------------------------------
/*/{Protheus.doc} xQrbEspc

Normaliza o nome do Tag quando a mesma possui atributos

@param	 nX - Índice do Laço (For)
@param  cPosAtu - Posição do atual da leitura do arquivo (Handle)
@param  cXml - Arquivo XML
@param  NmTag - Nome da Tag

@return cXmlIdent - Xml normalizado

@author Evandro dos Santos Oliveira
@since 21/10/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function xQrbEspc(nX,cPosAtu,cXml,NmTag)

	Local lContinue 	:= .T.
	Local cNomeTag	:= ""

	cNomeTag := NmTag + " "

	While lContinue
		//Incremento o Indice do For e faço um tratamento a parte até encontrar o caracter ">"
		nX++
		cPosAtu := Substr(cXml,nX,1)

		If cPosAtu == ">"
			lContinue := .F.
			nX -- //Retorno uma posição para o For começar a partir dela
		Else
			cNomeTag += cPosAtu
		EndIf
	EndDo

Return cNomeTag

//-------------------------------------------------------------------
/*/{Protheus.doc} xParObrMT

Normaliza o nome do Tag quando a mesma possui atributos

@Param	 cObrig       - Nome da Obrigacao que sera gerada
		 cSemaPhore  - Nome do Semaforo
		 lMultThread - Indica se o processamento sera Mult Thread
		 nQtdThread  - Quantidade de Threads utilizadas no processamento

@Return (Nil )

@author Rodrigo Aguilar
@since 18/11/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xParObrMT( cObrig, cSemaphore, lMultThread, nQtdThread )

	Local cFunction   := ""
	Local nPos        := 0
	Local nIniThread  := 0
	Local nIniTimeOut := 0
	Local nTimeOut    := 0
	Local nI          := 0

	Local aMV_TAFMTOF := {}

	Default cObrig 		:= ""
	Default cSemaphore  := ""

//Garanto que não possua espações em branco na informação enviada
	cObrig := Alltrim( cObrig )

//Verifica as configurações de execução de Thread para a obrigação selecionada
	aMV_TAFMTOF := StrToKArr( GetNewPar( "MV_TAFMTOF", cObrig + "=0" ), ";" )

	If ( nPos := aScan( aMV_TAFMTOF, { |x| cObrig $ x } ) ) > 0

		nIniThread  := At( "=", aMV_TAFMTOF[nPos] ) + 1

		If At( "/", aMV_TAFMTOF[nPos] ) > 0
			nIniTimeOut := At( "/", aMV_TAFMTOF[nPos] ) + 1

			//Quantidade de Threads a serem utilizadas
			nQtdThread := Val( SubStr( aMV_TAFMTOF[nPos], nIniThread, nIniTimeOut - ( nIniThread + 1 ) ) )

			//Tempo de TimeOut
			nTimeOut := Val( SubStr( aMV_TAFMTOF[nPos], nIniTimeOut ) )
		Else
			//Quantidade de Threads a serem utilizadas
			nQtdThread := Val( SubStr( aMV_TAFMTOF[nPos], nIniThread ) )
		EndIf

		//Indica se esta utilizando o conceito de Mult Thread
		If nQtdThread > 1
			lMultThread := .T.
		EndIf

		//Limita a quantidade de Threads para 5
		If nQtdThread > 5
			nQtdThread := 5
		EndIf

		//Define o tempo default de limite de conexao por inatividade para multithread
		If nTimeOut == 0
			nTimeOut := 190000000
		EndIf

	EndIf

//Caso Seja Mult Thread inicio o StartJob
	If lMultThread

		//Define Semaforo
		cSemaphore := cObrig + "_" + AllTrim( Str( ThreadID() ) )

		//Rotina responsavel pela chamada das funcoes de geracoes dos blocos das Obrigações em processamento multithread.
		cFunction := "MThrObrig"

		//Inicio a quantidade de Threads solicitadas para o processamento
		For nI := 1 to nQtdThread
			TAFConOut( "*** Iniciando a Thread -> " + AllTrim( Str( nI ) ) + " ***" )
			StartJob( "ShellThr", GetEnvServer(), .F., cSemaphore, cFunction, cEmpAnt, cFilAnt, StrZero( nI, 2 ), nTimeOut )
			TAFConOut( "*** Thread " + AllTrim( Str( nI ) ) + " Iniciada ***"  )
		Next nI

	EndIf

//Zerando os arrays utilizados durante o processamento
	aSize( aMV_TAFMTOF, 0 )

//Zerando as Variaveis utilizadas
	aMV_TAFMTOF := Nil

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} ShellThr

Estrutura responsavel criar as threads em estado de espera para o
processamento multithread, acionado pelo IPCGo.

@Param cSemaphore -> Nome do semaforo para comunicacao
       cFunction  -> Nome da rotina que o IPCGo ira executar
       cEmp       -> Empresa para processamento da thread
       cFil       -> Filial para processamento da thread
       cNThread   -> Identificao da Thread
       nTimeOut   -> Tempo para encerrar conexao por inatividade

@Return ( Nil )

@Author Felipe C. Seolin
@Since  17/11/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//-------------------------------------------------------------------
Function ShellThr( cSemaphore, cFunction, cEmp, cFil, cNThread, nTimeOut )

	Local uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10, uParm11, uParm12

//Prepara ambiente
	RPCSetType( 3 )
	RPCSetEnv( cEmp, cFil,,,"TAF","TAFXINTEG" )

//Listen - Aguardando comando IPCGo
	While !KillApp()
		If IPCWaitEx( cSemaphore, nTimeOut, @uParm1, @uParm2, @uParm3, @uParm4, @uParm5, @uParm6, @uParm7, @uParm8, @uParm9, @uParm10, @uParm11, uParm12 )
			If ValType( uParm1 ) == "C" .and. uParm1 == "_E_X_I_T_"
				Exit
			EndIf

			//Funcao a ser executada
			&cFunction.( uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10, uParm11, uParm12 )
		Else
			Exit
		EndIf
	EndDo

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MThrObrig

Rotina responsavel pela chamada das funcoes de geracoes dos blocos
das obrigações em processamento multithread.

@Param cObrig		->	Nome da obrigação fiscal
		cFunction	->	Nome da rotina que o IPCGo irá executar
        xPar		->	Variável auxiliar para execução da função

@Return ( Nil )

@Author Felipe C. Seolin
@Since  17/11/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//-------------------------------------------------------------------
Function MThrObrig( cObrig, cFunction, xPar1, xPar2, xPar3, xPar4, xPar5, xPar6, xPar7 )

	If cObrig == "ECF"
		&cFunction.( xPar1, xPar2, xPar3, xPar4, xPar5, xPar6, xPar7 )

	ElseIf cObrig == "SPEDFIS"
		&cFunction.( xPar1, xPar2, xPar3, xPar4, xPar5, xPar6 )

	ElseIf cObrig == "DIEFCE"
		&cFunction.( xPar1, xPar2, xPar3 )

	ElseIf cObrig == "GIM-RN"
		&cFunction.( xPar1, xPar2, xPar3 )
	ElseIf cObrig == "GIA-ST"
		&cFunction.( xPar1, xPar2, xPar3 )

	EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} SelBlcObrg

Rotina de inteligencia da selecao de blocos das Obrigações quando for um reprocessamento.

@Param cCTLAlias  -> Alias da tabela de controle de transacoes
       aWizard    -> Array com as informacoes da Wizard
       cFilSel    -> Filiais selecionadas para o processamento
       aBlocosObr -> Array com as informacoes de processamento dos blocos das Obrigações
	   lAuto      -> Se é automação

@Return ( !lCancel )

@Author Felipe C. Seolin
@Since  28/07/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//-------------------------------------------------------------------
Function SelBlcObrg( cObrig, cCTLAlias, aWizard, cFilSel, aBlocosObr, lAuto )

	Local oCheck  := Nil
	Local oList   := Nil
	Local oOk     := LoadBitmap( GetResources(), "LBOK" )
	Local oNo     := LoadBitmap( GetResources(), "LBNO" )
	Local nI      := 0
	Local nPos    := 0
	Local aList   := {}
	Local aBlocos := BlcProcObr( cObrig, cCTLAlias, aWizard, cFilSel )
	Local lReproc := .F.
	Local lCancel := .F.
	Default lAuto := .f.

//Adiciona os itens a serem exibidos na tela para selecao do usuario
	For nI := 1 to Len( aBlocos )
		If aBlocos[nI,1] .and. !(aBlocos[nI,2] $ ("0|J"))
			aAdd( aList, { lAuto, aBlocos[nI,2] } )
			lReproc := .T.
		EndIf
	Next nI

	If lReproc .and. !lAuto

		Define MsDialog oDlg Title STR0089 STYLE DS_MODALFRAME From 145,0 To 495,638 Of oMainWnd Pixel

		oDlg:lEscClose := .F.

		@ 05,15 To 155,310 LABEL STR0090 Of oDlg Pixel
		@ 20,20 Say STR0092 Of oDlg Pixel
		@ 30,20 Say STR0093 Of oDlg Pixel
		@ 45,20 CheckBox oCheck	PROMPT STR0005	Size 50,10		On Click( aEval( aList, { |x| x[1] := Iif( x[1] == .T., .F., .T. ) } ), oList:Refresh( .F. ) )	Of oDlg Pixel
		@ 60,20 ListBox oList	Fields HEADER "", "Bloco"	Size 283,090	On DblClick( aList := xFunFClTroca( oList:nAt, aList ), oList:Refresh() ) NoScroll	Of oDlg Pixel

		oList:SetArray( aList )
		oList:bLine := { || { Iif( aList[oList:nAt,1], oOk, oNo ), aList[oList:nAt,2] } }

		Define SButton	From 159,255	Type 1	Action oDlg:End()									Enable Of oDlg
		Define SButton	From 159,285	Type 2	Action Iif( lCancel := CancelObr(), oDlg:End(), )	Enable Of oDlg

		Activate MsDialog oDlg Centered

	EndIf

//Marca apenas os itens selecionados pelo usuario para processamento
	If !lCancel
		For nI := 1 to Len( aList )
			nPos := aScan( aBlocosObr, { |x| x[3] == aList[nI,2] } )
			aBlocosObr[nPos,1] := aList[nI,1]
		Next nI
	EndIf

Return( !lCancel )

//---------------------------------------------------------------------
/*/{Protheus.doc} xTafGetObr

Informa todos os blocos das Obrigações e suas respectivas informacoes.

@Param cObrig - Nome da Obrigação
@Param aWizard - Array com informações da wizard

@Return aObrBloco -> 1 - Informa se o bloco deve ser processado
                        2 - Rotina a gerar as informacoes do bloco
                        3 - Nome do bloco

@Author Felipe C. Seolin
@Since 13/06/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//---------------------------------------------------------------------
Function xTafGetObr( cObrig, aWizard )

	Local aObrBloco := {}

	Default aWizard := {}
//Geracao do ECF
	If cObrig == "ECF"

		aAdd( aObrBloco, { .T., "TAFECF0", "0" } )
		aAdd( aObrBloco, { .T., "TAFECFJ", "J" } )
		aAdd( aObrBloco, { .T., "TAFECFK", "K" } )
		aAdd( aObrBloco, { .T., "TAFECFL", "L" } )
		aAdd( aObrBloco, { .T., "TAFECFM", "M" } )
		aAdd( aObrBloco, { .T., "TAFECFN", "N" } )
		aAdd( aObrBloco, { .T., "TAFECFP", "P" } )
		aAdd( aObrBloco, { .T., "TAFECFQ", "Q" } )
		aAdd( aObrBloco, { .T., "TAFECFT", "T" } )
		aAdd( aObrBloco, { .T., "TAFECFU", "U" } )
		aAdd( aObrBloco, { .T., "TAFECFV", "V" } )
		aAdd( aObrBloco, { .T., "TAFECFW", "W" } )
		aAdd( aObrBloco, { .T., "TAFECFX", "X" } )
		aAdd( aObrBloco, { .T., "TAFECFY", "Y" } )

//Geracao do Sped Fiscal
	ElseIf cObrig == "SPEDFIS"

		aAdd( aObrBloco, { .T., "TafxSpd0", "0" } )
		aAdd( aObrBloco, { .T., "TafxSpdC", "C" } )
		aAdd( aObrBloco, { .T., "TafxSpdD", "D" } )
		aAdd( aObrBloco, { .T., "TafxSpdE", "E" } )
		aAdd( aObrBloco, { .T., "TafxSpdG", "G" } )
		aAdd( aObrBloco, { .T., "TafxSpdH", "H" } )
		aAdd( aObrBloco, { .T., "TafxSpdK", "K" } )
		aAdd( aObrBloco, { .T., "Tafxspd1", "1" } )

//Geracao da GIA-SP
	ElseIf cObrig == "GIA-SP"

		aAdd( aObrBloco, { .T., "TAFGS05", "CR05" } )
		aAdd( aObrBloco, { .T., "TAFGS07", "CR07" } )
		aAdd( aObrBloco, { .T., "TAFGS10", "CR10" } )
		aAdd( aObrBloco, { .T., "TAFGS20", "CR20" } )
		aAdd( aObrBloco, { .T., "TAFGS30", "CR30" } )
		aAdd( aObrBloco, { .T., "TAFGS31", "CR31" } )

//Geracao da GIM-RN
	ElseIf cObrig == "GIM-RN"
		aAdd( aObrBloco, { .T., "TAFGIM01", "01" } )
		aAdd( aObrBloco, { .T., "TAFGIM02", "02" } )
		aAdd( aObrBloco, { .T., "TAFGIM03", "03" } )
		aAdd( aObrBloco, { .T., "TAFGIM04", "04" } )
		aAdd( aObrBloco, { .T., "TAFGIM05", "05" } )
		aAdd( aObrBloco, { .T., "TAFGIM06", "06" } )
		aAdd( aObrBloco, { .T., "TAFGIM07", "07" } )
		aAdd( aObrBloco, { .T., "TAFGIM08", "08" } )
		aAdd( aObrBloco, { .T., "TAFGIM09", "09" } )
		aAdd( aObrBloco, { .T., "TAFGIM10", "10" } )
		aAdd( aObrBloco, { .T., "TAFGIM11", "11" } )
		aAdd( aObrBloco, { .T., "TAFGIM99", "99" } )

//Geracao da GIA-ST
	ElseIf cObrig == "GIA-ST"
		aAdd( aObrBloco, { .T., "TAFGSTA1", "Anexo de Devolução" } )
		aAdd( aObrBloco, { .T., "TAFGSTA2", "Anexo de Ressarcimento" } )
		aAdd( aObrBloco, { .T., "TAFGSTA3", "Anexo de Transferência" } )
		aAdd( aObrBloco, { .T., "TAFGSTA4", "Anexo DIFAL/FCP" } )

	EndIf

Return( aObrBloco )

//-------------------------------------------------------------------
/*/{Protheus.doc} xDelObrig

Rotina para excluir as informacoes que serao reprocessadas das
tabelas de controle e de informacoes das obrigações

@Param cObrig  -> Informa qual obrigação esta sendo gerada
		cBloco  -> Bloco a ser gravado
        aWizard -> Array com as informacoes da Wizard
        cFilSel -> Filiais selecionadas para o processamento
        cTabObg -> Nome da tabela referente a geração dos registros
        cTabCtl -> Nome da tabela de controle

@Return ( Nil )

@Author Felipe C. Seolin
@Since  30/07/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//-------------------------------------------------------------------
Function xDelObrig( cObrig, cBloco, aWizard, cFilSel, cTABOBG, cTABCTL )

	Local cDel    := ""
	Local cFil    := TurnFilObr( cFilSel )

	If cObrig == "ECF"
		cObrig := "1"
	ElseIf cObrig == "SPEDFIS"
		cObrig  := "2"
	EndIf

	cDel := "DELETE FROM " + cTABOBG + " "
	cDel += "WHERE FILIAL = '" + cFil + "' "
	cDel += "  AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
	cDel += "  AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "
	cDel += "  AND BLOCO = '" + cBloco + "' "

	TCSQLExec( cDel )

	cDel := "DELETE FROM " + cTabCtl + " "
	cDel += "WHERE EMPRESA = '" + cEmpAnt + "' "
	cDel += "  AND FILIAL = '" + cFil + "' "
	cDel += "  AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
	cDel += "  AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "
	cDel += "  AND OBRIGACAO = '" + cObrig + "' "
	cDel += "  AND BLOCO = '" + cBloco + "' "

	TCSQLExec( cDel )

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} xTafCTLObr

Rotina para manipular a Tabela de Controle de Transacoes.

@Param cOperation -> Operacao  (1-Inicio;2-Final)
        cBloco      -> Bloco a ser gravado
        aWizard     -> Array com as informacoes da Wizard
        cFilSel     -> Filiais selecionadas para o processamento
        cCTLAlias   -> Alias da tabela de controle de transacoes
        cTabCtl     -> Alias da tabela de controle
        cObrig      -> Indica a Qual obrigação se refere

@Return ( Nil )

@Author Felipe C. Seolin
@Since 16/06/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014

/*/
//---------------------------------------------------------------------
Function xTafCTLObr( cOperation, cBloco, aWizard, cFilSel, cCTLAlias, cTABCTL, cObrig )

	Local cUpd    := ""
	Local cFil    := TurnFilObr( cFilSel )

	If cObrig == "ECF"
		cObrig := "1"
	ElseIf cObrig == "SPEDFIS"
		cObrig  := "2"
	EndIf

	If cOperation == "1" //Inicio de processamento do bloco

		If RecLock( cCTLAlias, .T. )
			( cCTLAlias )->EMPRESA   := cEmpAnt
			( cCTLAlias )->FILIAL    := cFil
			( cCTLAlias )->PERINI    := aWizard[1,1]
			( cCTLAlias )->PERFIN    := aWizard[1,2]
			( cCTLAlias )->OBRIGACAO := cObrig
			( cCTLAlias )->BLOCO     := cBloco
			( cCTLAlias )->STATUS    := cOperation
			( cCTLAlias )->( MsUnlock() )
		EndIf

	ElseIf cOperation == "2" //Final de processamento do bloco

		cUpd := "UPDATE " + cTABCTL + " "
		cUpd += "SET STATUS = '" + cOperation + "' "
		cUpd += "WHERE EMPRESA = '" + cEmpAnt + "' "
		cUpd += "  AND FILIAL = '" + cFil + "' "
		cUpd += "  AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
		cUpd += "  AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "
		cUpd += "  AND OBRIGACAO = '" + cObrig + "' "
		cUpd += "  AND BLOCO = '" + cBloco + "' "

		TcSqlExec( cUpd )

	EndIf

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcProcObr

Rotina que verifica se existe processamento para a chave selecionada
pelo usuario e tambem os blocos que foram processados com sucesso.

@Param cObrig     -> Nome da Obrigação
		cCTLAlias -> Alias da tabela de controle de transacoes
        aWizard    -> Array com as informacoes da Wizard
        cFilSel    -> Filiais selecionadas para o processamento

@Return aRet -> 1 - Informa se o bloco foi processado com sucesso( .T. )
                  2 - Nome do bloco

@Author Felipe C. Seolin
@Since  28/07/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014
/*/
//-------------------------------------------------------------------
Function BlcProcObr( cObrig, cCTLAlias, aWizard, cFilSel )

	Local cFil		:=	TurnFilObr( cFilSel )
	Local aRet		:=	{}
	Local lGera	:=	.F.

	If cObrig == "ECF"
		cObrig := "1"
	ElseIf cObrig == "SPEDFIS"
		cObrig  := "2"
	EndIf

	( cCTLAlias )->( DBGoTop() )

	If ( cCTLAlias )->( MsSeek( PadR( cEmpAnt, 10 ) + PadR( cFil, 100 ) + DToS( aWizard[1,1] ) + DToS( aWizard[1,2] ) + cObrig ) )

		While ( cCTLAlias )->( !Eof() ) .and. ( PadR( cEmpAnt, 10 ) + PadR( cFil, 100 ) + DToS( aWizard[1,1] ) + DToS( aWizard[1,2] ) + cObrig ) == ( cCTLAlias )->( EMPRESA + FILIAL + DToS( PERINI ) + DToS( PERFIN ) + OBRIGACAO )
			//Validação realizada de forma que o Bloco K só seja reprocessado após 01/12/2016
			If Upper( ( cCTLAlias )->BLOCO ) <> "K"
				lGera := .T.
			Else
				If aWizard[1,1] >= CToD( "01/12/2016" ) .or. aWizard[1,2] >= CToD( "01/12/2016" )
					lGera := .T.
				Else
					lGera := .F.
				EndIf
			EndIf

			If lGera
				If ( cCTLAlias )->STATUS == "1" //Bloco não foi gerado com sucesso, portanto reprocessará obrigatoriamente
					aAdd( aRet, { .F., ( cCTLAlias )->BLOCO } )
				ElseIf ( cCTLAlias )->STATUS == "2" //Bloco foi gerado com sucesso, ficará a cargo do usuário o reprocessamento
					aAdd( aRet, { .T., ( cCTLAlias )->BLOCO } )
				EndIf
			EndIf
			( cCTLAlias )->( DBSkip() )
		EndDo

	EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} CancelObr

Rotina para selecionar se a operacao sera abortada.

@Param ( Nil )

@Return lRet -> Indica se foi cancelada a operacao

@Author Felipe C. Seolin
@Since  29/07/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Function CancelObr()

	Local lRet := MsgYesNo( STR0091 )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TurnFilObr

Converte a string de filiais selecionadas de forma que fique adequado
para gravacao e consulta nas tabelas de controle das obrigações.

@Param cFilSel -> Filiais selecionadas para o processamento

@Return cFil -> Filiais selecionadas para o processamento apos conversao

@Author Felipe C. Seolin
@Since 01/08/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TurnFilObr( cFilSel )

	Local cFil := cFilSel

	cFil := StrTran( cFil, "'", "" )
	cFil := StrTran( cFil, ",", "|" )

Return( cFil )

//---------------------------------------------------------------------
/*/{Protheus.doc} xFinalThread

Função para realizar o encerramento da Thread após o processamento

@Param cSemaphore - Semaforo
		nQtdThread - Quantidade de Threads

@Return ( Nil )

@Author Felipe C. Seolin
@Since 01/08/2014
@Version 1.0

@Altered by Rodrigo Aguilar In 17/11/2014
/*/
//---------------------------------------------------------------------
Function xFinalThread( cSemaphore, nQtdThread )

	Local nI := 0

	For nI := 1 to nQtdThread
		TAFConOut( "*** Finalizando a Thread  " + AllTrim( Str ( nI ) ) + " ***" )
		IPCGo( cSemaphore, "_E_X_I_T_" )
		Sleep( 1000 )
	Next nI

Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} xFunVldWiz

Função para validação dos campos da wizard.

@Param	cTipoVld	-	Flag da validação a ser realizada
		aObj		-	Conteúdo do campo
		aPosterior	-	Informação do campo subsequente ( utilizado como gatilho )
		aAnterior	-	Informação do campo anterior
		aPainels	-
		aButtons	-
		oWizard	-	Objeto Wizard em execução

@Return lRet		-	Conteúdo validado

@Author Felipe C. Seolin
@Since 02/12/2014
@Version 1.0
@obs Essa função realiza a validação do campo quando o mesmo perde o
foco.
/*/
//-------------------------------------------------------------------
Function xFunVldWiz( cTipoVld, aObj, aPosterior, aAnterior, aPainels , aButtons, oWizard )

	Local cContent	:= Iif( ValType( aObj[1] ) == "D" , AllTrim( DToS( aObj[1] ) ), AllTrim( aObj[1] ) )
	Local nX		:=	0
	Local nAux1		:=	0
	Local nAux2		:=	0
	Local nAux3		:=	0
	Local nOpcoes   := 0
	Local lGetDir	:=	.T.
	Local lRet		:=	.T.
	Local aCmpsPanel:= {}
	Local aAuxCmps	:= {}
	Local cTipoArq 	:= ""


	Default aObj			:=	{}
	Default aPosterior		:=	{}
	Default aAnterior		:=	{}
	Default aPainels		:=	{}
	Default aButtons		:=	{}
	Default oWizard			:=	Nil

	If cTipoVld == "ECF-PERIODO"

		If Empty( cContent )
			aPosterior[1] := ""
		Else
			DBSelectArea( "CHD" )
			CHD->( DBSetOrder( 1 ) )
			If lRet := CHD->( MsSeek( xFilial( "CHD" ) + cContent, .T. ) )
				aPosterior[1] := DToC( CHD->CHD_PERINI ) + " - " + DToC( CHD->CHD_PERFIN )
			EndIf
		EndIf

	ElseIf cTipoVld == "ECF-DIRETORIO"

		If !Empty( cContent ) .and. !ExistDir( cContent )
			lRet := .F.
		EndIf

	ElseIf cTipoVld == "ECF-VERSAO"

		If !Empty( cContent )
			DBSelectArea( "CZV" )
			CZV->( DBSetOrder( 2 ) )
			lRet := CZV->( MsSeek( xFilial( "CZV" ) + cContent, .T. ) )
		EndIf

	ElseIf cTipoVld == "ECF-RECIBO"

	/*REGRA_REC_ANTERIOR_OBRIGATORIO
	Verifica, quando o campo 0000.RETIFICADORA é igual a "S" ( ECF Retificadora )
	ou "F" ( ECF original com mudança de forma de tributação ), se 0000.NUM_REC está preenchido.*/
		If SubStr( aAnterior[1], 1, 1 ) $ "S|F" .and. Empty( cContent )
		lRet := .F.

	/*REGRA_NRO_REC_ANTERIOR_NAO_SE_APLICA
	Verifica, quando 0000.RETIFICADORA é igual a "N" ( ECF Original ), se 0000.NUM_REC não está preenchido.*/
		ElseIf SubStr( aAnterior[1], 1, 1 ) $ "N" .and. !Empty( cContent )
		lRet := .F.

		EndIf

	ElseIf cTipoVld == "TAFA500-DIR"

	nAux1 := aButtons[1,2,1]
	nAux2 := aButtons[1,2,2]
	nAux3 := aButtons[1,2,3]

		If Empty( aObj[2] )
		//Passa aqui na construção do objeto TComboBox
		lGetDir := IIf( SubStr( AllTrim( aObj[1] ), 1, 1 ) == "3", .T., .F. )
		Else
		//Passa aqui na validação do objeto TComboBox
		lGetDir := IIf( aObj[2]:nAt == 2, .T., .F. )
		EndIf

		If !(GetRemoteType() == REMOTE_HTML)
			If lGetDir
			aButtons[1,1]:blClicked	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile( "Diretorio|*.*", OemToAnsi( "Procurar" ), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. ) }
			aButtons[1,1]:bAction	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile( "Diretorio|*.*", OemToAnsi( "Procurar" ), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. ) }
			Else
			aButtons[1,1]:blClicked	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile( "Arquivo txt|*.txt", OemToAnsi( "Procurar" ), 0,, .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE, .T. ) }
			aButtons[1,1]:bAction	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile( "Arquivo txt|*.txt", OemToAnsi( "Procurar" ), 0,, .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE, .T. ) }
			EndIf
		Else
		nOpcoes := GETF_MULTISELECT
		cTipoArq := Iif(lGetDir, "Arquivo xml|*.xml", "Arquivo txt|*.txt")
		aButtons[1,1]:blClicked	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile(cTipoArq, OemToAnsi( "Procurar" ), 0,, .T.,nOpcoes, .T. ) }
		aButtons[1,1]:bAction	:=	{ || aPainels[nAux1,nAux2,nAux3]	:=	cGetFile(cTipoArq, OemToAnsi( "Procurar" ), 0,, .T.,nOpcoes, .T. ) }
		EndIf

	ElseIf cTipoVld == "CENTRAL-PESQUISA"

	nAux1 := oWizard:nPanel - 1

		If aAnterior[1] == "Código"
		nAux2 := 2
		ElseIf aAnterior[1] == "Obrigação"
		nAux2 := 3
		EndIf

		If ( nAux3 := aScan( aPainels[nAux1,9,2]:aArray, { |x| Upper( AllTrim( x[nAux2] ) ) == Upper( AllTrim( cContent ) ) } ) ) > 0
		aPainels[nAux1,9,2]:nAt := nAux3
		aPainels[nAux1,9,2]:Refresh()
		EndIf

	ElseIf cTipoVld == "UF-GNRE"

		If Empty( cContent )
		aPosterior[1] := ""
		Else
		DBSelectArea( "C09" )
		C09->( DBSetOrder(3) )
			If lRet := C09->( MsSeek(xFilial("C09")+cContent,.T.))
			aPosterior[1] := C09->C09_DESCRI
			EndIf
		EndIf

	ElseIf cTipoVld == "CFG-CERTIFICADO"

	//Retiro os objetos Null, desta forma ficam no array somente os objetos reais da tela
	aEval(aPainels[2],{|x| IIf(!Empty(x[2]),aAdd(aCmpsPanel,x),) })

	//Pego somente os Campos, faço isso por que os objetos de Input estão sempre nas posições de numeros pares.
		For nX := 1 To Len(aCmpsPanel)
			If Mod(nX,2) == 0
			aAdd(aAuxCmps,aCmpsPanel[nX])
			EndIf
		Next nX

	//Após o Tratamento o array aAuxCmps estará somente com os campos de Input de acordo com suas ordens na tela
	//sendo assim posso determinar quem é quem dentro do Array

		If Len(aPainels) > 2

			If aAuxCmps[1][2]:nAt == 1 //Combo de certificado Digital #.pem
			aAuxCmps[2][2]:bWhen := {||.T.}
			aAuxCmps[3][2]:bWhen := {||.T.}
			aAuxCmps[4][2]:bWhen := {||.F.}
			aAuxCmps[5][2]:bWhen := {||.F.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.F.}
				if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.F.}
				endif

			ElseIf aAuxCmps[1][2]:nAt == 2 //.pfx ou .p12
			aAuxCmps[2][2]:bWhen := {||.T.}
			aAuxCmps[3][2]:bWhen := {||.F.}
			aAuxCmps[4][2]:bWhen := {||.F.}
			aAuxCmps[5][2]:bWhen := {||.F.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.F.}
				if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.F.}
				endif

			Else
			aAuxCmps[2][2]:bWhen := {||.F.}
			aAuxCmps[3][2]:bWhen := {||.F.}
			aAuxCmps[4][2]:bWhen := {||.T.}
			aAuxCmps[5][2]:bWhen := {||.T.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.T.}
				if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.T.}
				endif

			EndIf

		EndIf
	EndIf

	If !lRet
		MsgInfo( STR0088 )
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldMail

Função para validação do E-Mail.

@Param	cEmail		-	Conteúdo a ser validado

@Return lRet		-	Conteúdo validado

@Author Paulo V.B. Santana
@Since 21/01/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xVldMail( cEmail )

	Local aPosPonto	:= {}
	Local cAntArrob	:= "" //string que Antecede o "@" na informação do e-mail
	Local cPosArrob	:= "" //string posterior o "@" na informação do e-mail
	Local cAntPonto	:= "" //string após o "." na informação do e-mail
	Local cPosPonto	:= "" //string após o "." na informação do e-mail
	Local cAlpha		:= ""
	Local nPosArrob	:= 0 //posição do caracter '@'
	Local nPosPonto	:= 0 //posição do caracter '.'
	Local nI			:= 0
	Local nJ			:= 0
	Local lAlpha		:= .F.
	Local lIniFim 	:= .F. //Se existe caractere "@" no início ou no fim do e-mail, e se existe caractere "." no fim do e-mail.
	Local lRet     	:= .T.

	If ! Empty(cEmail)
		nPosArrob	:= At( "@", cEmail )
		cAntArrob	:= AllTrim( SubStr( cEmail, 1, nPosArrob - 1 ) )
		cPosArrob 	:= AllTrim( SubStr( cEmail, nPosArrob + 1 ) )
		nPosArrb2 := At( "@", cPosArrob )

		nPosPonto	:= At( ".", cPosArrob )
		cAntPonto	:= AllTrim( SubStr( cPosArrob, 1, nPosPonto - 1 ) )
		cPosPonto	:= AllTrim( SubStr( cPosArrob, nPosPonto + 1 ) )

		aPosPonto := Separa( cPosPonto, "." )

		For nI := 1 to Len( aPosPonto )

			For nJ := 1 to Len( aPosPonto[nI] )

				If IsAlpha( SubStr( aPosPonto[nI], nJ, 1 ) )
					cAlpha += SubStr( aPosPonto[nI], nJ, 1 )
				EndIf

			Next nJ

			If nPosArrob == 1 .or. !nPosArrb2 == 0 .or. Substr(cPosPonto,Len(cPosPonto),1) == "."
				lIniFim := .T.
				Exit
			Else
				lIniFim := .F.
			EndIf

			If Len( cAlpha ) >= 2 .and. Len( cAlpha ) <= 4 .and. nPosPonto > 0
				lAlpha := .T.
				Exit
			Else
				cAlpha := ""
			EndIf

		Next nI

		If ( " " ) $ RTrim( cEmail ) .or. Empty( cAntArrob ) .or. Empty( cPosArrob ) .or. lIniFim .or. !lAlpha
			lRet := .F.
		EndIf

	EndIf
Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} xIniPadr

Função para executar a inicialização padrão do campo.

@Param	cCampo	-	Campos que receberá a inicialização padrão

@Return cRet	-	Retorno da função

@Author Paulo V.B. Santana
@Since 03/02/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xIniPadr( )
	Local cRet		:= ""
	Local cCampo	:= ReadVar()
	If AllTrim( SubStr( cCampo , 4 ) ) $ "CHH_DCNTCO"
		cRet:= Iif(!INCLUI .and. !Empty(CHH->CHH_CNTCOR),Posicione("C1O",3,xFilial("C1O")+CHH->CHH_CNTCOR,"ALLTRIM(C1O_CODIGO)+ ' - '+ ALLTRIM(C1O_DESCRI)"),"")
	ElseIf AllTrim( SubStr( cCampo , 4 ) ) $ "CHH_CCNTCO"
		cRet:= Iif(!INCLUI .and. !Empty(CHH->CHH_CNTCOR),Posicione("C1O",3,xFilial("C1O")+CHH->CHH_CNTCOR,"ALLTRIM(C1O_CODIGO)"),"")
	Endif
Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFEcfPer

Retorna ID do periodo da tabela de parâmetros ECF (CHD) de acordo
com a data passada por parâmetro.

@Param	xData - Data correspondente ao período.

@Author Anderson C. Costa
@Since 05/02/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFEcfPer(xData)

	Local cQuery 	:= ''
	Local cData	:= ''

	Local cAliasQry := GetNextAlias()


	cData := IIf(ValType(xData) == "D",DTOS(xData),xData)

	cQuery := " SELECT "
	cQuery += " CHD.CHD_ID "
	cQuery += " FROM "
	cQuery += RetSqlName( 'CHD' ) + " CHD "
	cQuery += " WHERE "
	cQuery += " CHD.CHD_FILIAL='" + xFilial('CHD') + "' AND "
	cQuery += " '" + cData + "' BETWEEN CHD.CHD_PERINI AND CHD.CHD_PERFIN "
	cQuery += " AND CHD.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY "
	cQuery += " CHD.CHD_ID "
	cQuery := ChangeQuery( cQuery )


	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

	cIdper := (cAliasQry)->CHD_ID

	(cAliasQry)->(dbCloseArea())

Return (cIdper)


//-------------------------------------------------------------------
/*/{Protheus.doc} xConvGIA

Converte o valor numa string conforme padrão especifico da GIA

@Param	nValor - Valor à ser Convertido
@Param	nTAM   - Tamanho da string

@Author Paulo Santana
@Since 23/04/2015
@Version 1.0

@Retorn cValRet - Valor Convertido

/*/
//-------------------------------------------------------------------
Function xConvGIA(nValor,nTam)
	Local cValRet:= ""

	cValRet:= TRANSFORM(nValor,"@E 999,999,999,999.99")
	cValRet:= StrTran(cValRet,",","")
	cValRet:= ALLTrIM(StrTran(cValRet,".",""))
	cValRet:= PADL(cValRet,nTam,"0")

Return (cValRet)

// ----------------------------------------
function TAFGetPath( cTipo , cObrigacao )

	local cPath := ""

	do case

	case cTipo == '1'
		cPath	:=	"\Extrator_TAF"

	case cTipo == '2'
		cPath	:=	"\Obrigacoes_TAF\" + cObrigacao

	end case

return cPath
//-------------------------------------------------------------------
/*/{Protheus.doc} xValWizB

Função Criada para que seja possivel que o retorno seja realizado para a
primeira tela da Wizard criada, necessidade nasceu como a Wizard Inicial

@Param	lBackIni - Indica se deve retornar ao inicio da Wizard
		oWizard  - Objeto criado para a Wizard

@Author Rodrigo Aguilar
@Since 27/03/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xValWizB( lBackIni, oWizard )

	if lBackIni
		oWizard:nPanel := 2
	endif

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunIndID

Função que retorna o índice que contem o campo (cAlias)_ID

FUNÇÃO DESCONTINUADA - UTILIZAR TAFGETIDINDEX ( TAFXFUNDIC )

@Param	cAlias - Alias do qual se deseja saber o índice

@Author Anderson Costa
@Since 16/04/2015
@Version 1.0
/*/
//------------------------------------------------------------------
Function xFunIndID( cAlias )

	Local nIndice	:=	0

//FUNÇÃO DESCONTINUADA - UTILIZAR TAFGETIDINDEX ( TAFXFUNDIC )

	If cAlias $	"C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C6W|" +;
			"C7B|CAI|CH1|CH2|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3F|C3G|C3H|C3A|C3I|" +;
			"C5K|C5L|CA2|CA3|CA4|CA5|CA6|CA7|CA8|C3C|C49|CZM|C4A|CA9|C47|" +;
			"C48|CUX|CAA|C4C|CZO|C4M|C5G|C6P|C44|C45|C43|C51|C54|C5B|C5C|C5N|C5O|C81|C5R|" +;
			"C5S|C5T|C5U|CAB|C6G|C6H|C3O|C6I|C6J|C6K|C6L|C7C|C7D|C7E|C7F|C7G|C7H|C7I|C7J|" +;
			"C7K|C7L|C7M|C7N|C7O|C7P|C7Q|C7R|C7S|C7T|C7U|C7V|C7X|C7Z|C70|C71|C72|C73|C74|" +;
			"C75|C76|C77|C78|C79|C4S|C4T|C4U|C4V|C1I|C6Q|C0T|C6V|C1F|CUW|C1K|C6X|C1M|CH5|" +;
			"CHH|C2T|C2U|C2V|C2X|C2Z|C6Z|C2P|C2O|C4G|C4H|C4O|C4P|C56|C57|C3K|C3L|C3M|C3N|" +;
			"C7A|CW6|CZS|CZT|CZU|CZV|CAC|CAP|CFR|CEN|CEA|CHD|CEJ|CEY|CFK|CFT|CAY|CFV|CFY|" +;
			"CG0|CG2|CG3|CG5|CFQ|CGH|CGI|CGJ|CEX|CGK|CGL|CGM|CEM|CGO|CGP|CGQ|CGR|CGT|CGU|" +;
			"CGV|CGW|CGY|CGZ|CH9|CFS|CHC|CHF|CEG|C86|C87|C88|C89|C8A|CMH|C8C|CMI|C8D|C8E|" +;
			"C8F|C8G|C8H|C8I|C8J|C8K|C8L|C8M|C8N|C8O|C8P|C8T|C8U|C8Z|C94|C95|C96|C97|C98|" +;
			"C8S|CMM|CMY|CUA|CUB|CUC|CUE|CUF|CUM|CUN|CUQ|CUR|CUV|CA0|CUY|CUZ|CAH|CAJ|CAK|" +;
			"CAL|CH0|CW4|CAX|CFL|CFM|CFU|CGN|CW9|CH6|CH8|CHA|CHI|CHJ|CHK|CHW|CHY|CW5|T00|" +;
			"T12|T13|T26|T30|T31|T32|T33"
		nIndice := 1
	ElseIf cAlias $ "C46|C5H|C5Q|C6F|C4I|C4J|C1E|C2S|C3J"
		nIndice := 2
	ElseIf cAlias $	"C5Z|C4B|C4E|C50|C5E|C59|C53|C5A|C5M|C6M|C6N|C4R|C1G|C1J|C1L|C2L|C1N|" +;
			"C1O|C1P|C3Q|C4N|C55|C6Y|C3R|C6D|C01|C02|C03|C04|C05|C06|C07|C08|C09|C0A|" +;
			"C0B|C13|C14|C15|C16|C17|C0H|C0J|C0L|C0M|C0N|C0S|C0U|C0X|C0Z|C0Y|C11|C10|" +;
			"C1Q|C1S|C12|C1R|C1T|C0V|C18|C19|C1Y|C1V|C3P|C3S|C0C|C0D|C0E|C0F|C1B|C1C|" +;
			"C1D|C0O|C0I|C1X|C1W|C2M|C3Z|C3V|C3X|C2Q|C2R|C3E|C3D|C41|C42|C4D|C4K|C4Z|" +;
			"C52|C5D|C5P|C5V|C5X|C3T|C3U|C6C|C6R|C6S|C6T|C6U"
		nIndice := 3
	ElseIf cAlias $ "C20|C5I|C4X|C6E|C0Q|C0W|C2N|C4F|C1A|C0K"
		nIndice := 4
	ElseIf cAlias $ "C4Q|C5J|C5Z|C3B|C4B|C4E|C50|C5E|C59|C53|C5A|C5M|C6M|C6N|C4R|C5F|C40|C58|C1H|C2J"
		nIndice := 5
	ElseIf cAlias $ "C0R|C6A|C1U"
		nIndice := 6
	ElseIf cAlias $ "C4L"
		nIndice := 7
	ElseIf cAlias $ "C0G"
		nIndice := 8
	EndIf

//FUNÇÃO DESCONTINUADA - UTILIZAR TAFGETIDINDEX ( TAFXFUNDIC )

Return( nIndice )

//-------------------------------------------------------------------
/*/{Protheus.doc} xValidInsc

Função que valida o Número da Inscrição utilizado nas Tags do eSocial,
de Acordo com o Tipo de Inscrição informado.

@Param	cTpInsc - Tipo de Inscrição
@Param cNumInsc - Número da Inscrição

@Author Paulo Sérgio
@Since 16/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xValidInsc( cTpInsc, cNumInsc )
	Local lRet:= .F.
	Default cTpInsc:= '1'

	If cTpInsc== '1' .Or. cTpInsc== '4'
		dbSelectArea("C92")
		C92->(dbSetOrder(6))
		If C92->( MsSeek(xFilial("C92") + cTpInsc + cNumInsc + "1") )
			If C92->C92_STATUS $ ("2|4")
				lRet:= .T.
			Endif
		Endif
		If lRet .And. cTpInsc== '1' .AND. ( !CGC(Alltrim(cNumInsc),,.T.) .OR. Len(Alltrim(cNumInsc)) == 14 )
			lRet:= .T.
		Endif

	Elseif cTpInsc== '3'
		dbSelectArea("C99")
		C99->(dbSetOrder(7))
		If C99->( MsSeek(xFilial("C99") + cTpInsc + cNumInsc + "1") )
			While C99->C99_TPINES == cTpInsc .And. C99->C99_NRINES == cNumInsc .AND. !C99->(Eof())
				If C99->C99_STATUS $ ("2|4")
					lRet:= .T.
				Endif
			Enddo
		Endif

	Elseif cTpInsc== '2' .AND. !CGC(Alltrim(cNumInsc),,.T.) .OR. Len(Alltrim(cNumInsc)) == 11
		lRet:= .T.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FCadAutCon
Função criada para retirar as opções de Incluir, Alterar e Exluir dos cadastros
das autocontidas, somente a Totvs poderá manutenir esses cadastros através da
Wizard de Configuração( TAFACONT )


@Param	cMenu    - Nome da Rotina que foi chamada pelo Menu
		aRotina  - Arra com as opções do Menu

@Author Rodrigo Aguilar
@Since 15/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function FCadAutCon(cMenu as character, aRotina as array, lMenuDef as logical)

	Local aAutoCont		as array
	Local cAbertas		as character
	Local nPosDel		as numeric

	Default aRotina		:= {}
	Default cMenu		:= ""
	Default lMenuDef 	:= .F.

	aAutoCont	:= TAFRotinas(cMenu, 1, .F., 4,, lMenuDef)
	cAbertas	:= "TAFA010|TAFA020|TAFA163|TAFA192|TAFA237|TAFA034|TAFA475|TAFA215|TAFA378|TAFA043|TAFA300|TAFA270|TAFA628"
	nPosDel		:= 0

	If !( cMenu $ cAbertas ) .and. ( Len( aAutoCont ) > 0 .or. cMenu == "TAFA420" )
		If !(cMenu $ "TAFA420" ) //Para habilitar as opções de cadastro em autocontidas
			nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Incluir" } )
			If nPosDel > 0
				aDel( aRotina , nPosDel )
				aSize( aRotina , Len( aRotina ) - 1 )
			EndIf
		Endif

		If !(cMenu $ "TAFA583" ) // Autocontida que deve permitir somente Alteração
			nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Alterar" } )
			If nPosDel > 0
				aDel( aRotina , nPosDel )
				aSize( aRotina , Len( aRotina ) - 1 )
			EndIf
		EndIf

		nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Excluir" } )
		If nPosDel > 0
			aDel( aRotina , nPosDel )
			aSize( aRotina , Len( aRotina ) - 1 )
		EndIf
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSeekPer

Função para encontrar os regitros de Parâmetro
de Abertura referente ao Período de Apuração.

@Param		cDataIni	-	Data Inicial Saldo
			cDataFim	-	Data Final Saldo
			cAliasCHD	-	Código do Período

@Return	.T.	-	Retorna se encontrou o Parâmetro de Abertura

@Author	Paulo
@Since		13/02/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFSeekPer( cDataIni, cDataFim )

	Local lFound	:= .F.

	DBSelectArea( "CHD" )
	CHD->( DBSetOrder( 1 ) )
	CHD->( DBGoTop() )
	While CHD->( !Eof() )
		If DToS( CHD->CHD_PERINI ) <= cDataIni .and. DToS( CHD->CHD_PERFIN ) >= cDataFim .and. CHD->CHD_FILIAL == xFilial( "CHD" )
			lFound := .T.
			Exit
		Else
			CHD->( DBSkip() )
		EndIf
	EndDo

Return( lFound )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIniPad
Função utilizada para realizar a inicialização padrão do campo de
conta referencial.


@param cIdCTARef - Id da Conta Referencial

@return cRet - Retorna o código da Conta Referencial ou mensagem de Erro
quando não encontrado na integração

@author Paulo
@since 02/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFIniPad(cIdCTARef)
	Local cRet:= ""

	If !INCLUI .And. !Empty(cIdCTARef)
		If "ER" $ (cIdCTARef)
			cRet := cIdCTARef
		Else
			cRet := Posicione("CHA",1,xFilial("CHA")+cIdCTARef,"CHA_CODIGO")
		Endif
	Endif

Return (cRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPath

Ajusta o diretório para linux ou windows

@Param cPath-> Diretório que será ajustado

@Return ( Diretório corrigido )

@Author David Costa
@Since 04/11/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Function TAFAPath( cPath )

	cPath := AllTrim( cPath )
//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPath ) .and. ( SubStr( cPath, Len( cPath ), 1 ) <> "/" )
			cPath += "/"
		EndIf
	Else
		If !Empty( cPath ) .and. ( SubStr( cPath, Len( cPath ), 1 ) <> "\" )
			cPath += "\"
		EndIf
	EndIf

Return ( cPath )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetUF
Retorna a sigla da UF

@Param cC09_ID-> ID da UF

@author David Costa
@since  04/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGetUF( cC09_ID )

	Local cUF	:= ""

	Begin Sequence

		If( !Empty(cC09_ID))
			C09->( DbSetOrder( 3 ) )
			If( C09->(MsSeek( xFilial( "C09" ) + cC09_ID )))
				cUF := C09->C09_UF
			EndIf
		EndIf

	End Sequence

Return (cUF)


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCFOPCon
Verifica se o a CFOP é de consignação

@Param cCFOP-> Código da CFOP

@author David Costa
@since  04/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFCFOPCon( cCFOP )

	Local lConsigna	:= .F.

//CFOPs de Consignação
	If( AllTrim(cCFOP) $ "1111|1113|1917|1918|1919|5111|5112|5113|5114|5115|5917|5918|5919|")
		lConsigna := .T.
	EndIf

Return( lConsigna )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDecimal

Converte o valor numa string conforme a quantidade de casas decimais Definida e
adiciona zeros a esquerda para completar o tamanho do campo

@Param	nValor - Valor à ser Convertido
		nTam - Tamanho do campo
		nDec - Quantidade de Decimais
		cSep - Separdor de decimais (opcional)

@Author David Costa
@Since 09/11/2015
@Version 1.0

@Return cValRet - Valor Convertido

/*/
//-------------------------------------------------------------------
Function TAFDecimal( nValor,nTam,nDec,cSep )

	Local cValRet:= ""

	If nValor == Nil
		nValor := 0
	EndIf

	If Valtype( nValor ) == "C"
		cValRet := nValor
	Else
		cValRet := TRANSFORM(nValor,"@E 999999999999999999999." + Replicate("9",nDec))
		cValRet := iIf(Empty(cSep), StrTran(cValRet,",",""), StrTran(cValRet,",",cSep))
		cValRet := PADL( AllTrim(cValRet),nTam ,"0" )
	EndIf

Return (cValRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTel

@author Marcos Buschmann
@since	13/10/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function GetTel(cTelefone,cArea,cPais)

	Local nX      := 0
	Local nCount  := 0
	Local cAux    := ""
	Local cNumero := ""
	Local lFone   := .T.
	Local lArea   := .F.
	Local lPais   := .F.

	DEFAULT cArea := ""
	DEFAULT cPais := ""

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

Return ({Val(cPais),Val(cArea),Val(cNumero)})
//-------------------------------------------------------------------
/*/{Protheus.doc} xIDFather
Esta função tem como objetivo armanezar o último ID do registro pai
do LayoutTaf para posteriormente ser utilizada na consulta do registro
filho.

@Author Rafael Völtz
@since 13/06/2016
@version 1.0

@param
lChave -> chave composta
cTxtCont -> conteúdo do arquivo texto importado
cCampoMile -> Campo mile
cAlias		-	Alias para o SEEK
nIndice	- 	Indice do SEEK
@Return:
cIDFather	- 	ID do cadastro
/*/
//-------------------------------------------------------------------
Function xIDFather(lChave,cTxtCont,cCampoMile,cAlias , nIndice)

	cIDFather :=	XFUNCh2ID(  xTafBldKey( lChave ,cTxtCont, cCampoMile ), cAlias , nIndice )

Return cIDFather

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatData
Esta função tem como objetivo formatar uma data nos formatos indicados
nos parâmetros.

@Author Rafael Völtz
@since 13/06/2016
@version 1.0

@param
dData -> Data ser convertida
lBarra -> Tipo (Se .T. com Barra, se .F., sem Barra)
nFormato -> Formato (1,2,3)
	Formatos: 1 := ddmmaa
               2 := mmddaa
               3 := aaddmm
               4 := aammdd
               5 := ddmmaaaa
               6 := mmddaaaa
               7 := aaaaddmm
               8 := aaaammdd
@Return:
xData	-  Data Formatada
/*/
//-------------------------------------------------------------------
Function FormatData( dData, lBarra, nFormato )

	Local xData     := dData

	dData   := Iif( dData==Nil,dDataBase,dData )
	lBarra  := Iif( lBarra==Nil,.T.,lBarra )
	nFormato:= Iif( nFormato==Nil,1,nFormato )
	cSepar  := Iif( lBarra,"/","" )

	If !lBarra
		Do Case
		Case nFormato == 1
			xData := StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)+cSepar+SubStr(StrZero(Year(dData),4),3,2)
		Case nFormato == 2
			xData := StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)+cSepar+SubStr(StrZero(Year(dData),4),3,2)
		Case nFormato == 3
			xData := SubStr(StrZero(Year(dData),4),3,2)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)
		Case nFormato == 4
			xData := SubStr(StrZero(Year(dData),4),3,2)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)
		Case nFormato == 5
			xData := StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Year(dData),4)
		Case nFormato == 6
			xData := StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Year(dData),4)
		Case nFormato == 7
			xData := StrZero(Year(dData),4)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)
		OtherWise
			xData := StrZero(Year(dData),4)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)
		EndCase
	End
Return xData

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaMes()
Esta função somar meses a uma data

@Author Rafael Völtz
@since 13/06/2016
@version 1.0

@param
dData -> Data base a ser considerada na soma
nMês  -> Quantidade meses a ser somado

dData -  Nova data
/*/
//-------------------------------------------------------------------
Function TAFSomaMes( dDate , nMonth )

	Local nMonthAux    := Month( dDate )
	Local nDayAux    := Day( dDate )
	Local nYearAux    := Year( dDate )

	Local nYearPlus

	nMonthAux += nMonth
	IF ( nMonthAux > 12 )
		IF ( ( nMonthAux % 12 ) == 0 )
			nYearPlus    := ( ( nMonthAux / 12 ) - 1 )
			nYearAux    += nYearPlus
			nMonthAux    := Month( dDate )
		Else
			nYearPlus    := ( nMonthAux / 12 )
			nYearPlus    := Int( nYearPlus )
			nMonthAux    := ( nMonthAux - ( nYearPlus * 12 ) )
			nYearAux    += nYearPlus
			While ( nMonthAux > 12 )
				nMonthAux    -= 12
				++nYearAux
			End While
		EndIF
	EndIF
	dDate := Ctod( Day2Str( nDayAux ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
	IF Empty( dDate )
		dDate    := Ctod( Day2Str( 1 ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
		nDayAux    := Last_Day( dDate )
		dDate    := Ctod( Day2Str( nDayAux ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
	EndIF

Return( dDate )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSubMes
Esta função tem como objetivo subrair meses de uma data

@Author Rafael Völtz
@since 08/08/2016
@version 1.0

@param
dDate - Data para subtração
nMonth - Quantidade de meses
@Return:
dDate	- Data subtraída
/*/
//-------------------------------------------------------------------
Function TAFSubMes( dDate , nMonth )

	Local nMonthAux := Month( dDate )
	Local nDayAux   := Day( dDate )
	Local nYearAux  := Year( dDate )

	While ( nMonth >= 12 )
		nMonth -= 12
		--nYearAux
	End While

	nMonthAux -= nMonth

	IF ( nMonthAux <= 0 )
		nMonthAux := ( 12 + nMonthAux )
		--nYearAux
	EndIF

	dDate := Ctod( Day2Str( nDayAux ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
	IF Empty( dDate )
		dDate    := Ctod( Day2Str( 1 ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
		nDayAux    := Last_Day( dDate )
		dDate    := Ctod( Day2Str( nDayAux ) + "/" + Month2Str( nMonthAux ) + "/" + Year2Str( nYearAux ) , "DDMMYYYY" )
	EndIF

Return( dDate )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTAFChvPes
Esta função tem como objetivo montar chave de pesquisa para ser utilizada
no indíce conforme regra definida por campo do dicionário.

@Author Rafael Völtz
@since 08/08/2016
@version 1.0

@param
cCampo - Campo a qual será definida regra
@Return:
cRet	- Chave montada para pesquisa
/*/
//-------------------------------------------------------------------
Function xTAFChvPes( cCampo )

	Local cRet
	Local cUF

	cRet	:=	""
	cUF	:=	""

	If cCampo == "CWZ_CODMOT"
		DBSelectArea( "C09" )
		C09->( DBSetOrder( 1 ) )
		If C09->( MsSeek( xFilial( "C09" ) + SM0->M0_ESTCOB ) )
			cUF := C09->C09_ID
		EndIf

		//CWZ_FILIAL + CWZ_CODTRI + CWZ_TPINC + CWZ_CODMOT + CWZ_IDUF
		If FWFldGet( "C35_VLISEN" ) > 0
			cRet := xFilial( "CWZ" ) + AllTrim( FWFldGet( "C35_CODTRI" ) ) + "1" + AllTrim( FWFldGet( "C35_MOTINC" ) ) + AllTrim( cUF )
		ElseIf FWFldGet( "C35_VLNT" ) > 0
			cRet := xFilial( "CWZ" ) + AllTrim( FWFldGet( "C35_CODTRI" ) ) + "2" + AllTrim( FWFldGet( "C35_MOTINC" ) ) + AllTrim( cUF )
		ElseIf FWFldGet( "C35_VLOUTR" ) > 0
			cRet := xFilial( "CWZ" ) + AllTrim( FWFldGet( "C35_CODTRI" ) ) + "3" + AllTrim( FWFldGet( "C35_MOTINC" ) ) + AllTrim( cUF )
		Else
			cRet := xFilial( "CWZ" ) + AllTrim( FWFldGet( "C35_CODTRI" ) ) + "" + AllTrim( FWFldGet( "C35_MOTINC" ) ) + AllTrim( cUF )
		EndIf
	EndIf

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRemCharEsp

Remove caracteres especiais da IE e CNPJ.

@Param		cString	-	String a ser tratada

@Return	cString	-	String sem caracteres especiais

@Author	Rafael Völtz
@Since		15/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFRemCharEsp( cString  )

	Local nAux
	Local aCharEspec

	nAux		:=	1
	aCharEspec	:=	{ ".", "-", "(", ")", "[", "]", " ", "/" }

	While nAux <= Len( aCharEspec )
		cString := StrTran( cString, aCharEspec[nAux], "" )
		nAux ++
	EndDo

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} XVldTNrIns
Funcao generica utilizada para efetuar a validação do numero de inscrição
de acordo com o tipo de inscrição, validando pelos dois campos.

@Param  cTpInsc -  Tipo de Inscrição
		 cNrInsc -  Número de Inscrição
		 cTAFValid - Se a função é chamada pelo TAFValid(Direto no Fonte)

@author Paulo
@since 02/09/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function XVldTNrIns( cTpInsc, cNrInsc, lTAFValid )

	Local lRet			:=	.T.
	Local cCmp    		:= ReadVar()
	Local cCGC     		:= AllTrim(SM0->M0_CGC)
	Local cCGCInsc 		:= Iif(Len(cCgc) == 14, "1", "2")

	Default lTAFValid	:= .F.

	If !Empty(Alltrim(cNrInsc)) .AND. Empty(Alltrim(cTpInsc))

		Help(, , STR0008, , STR0198, 1, 0, , , , , , {STR0199}) // "ATENÇÄO" / "O Tipo de Inscrição não está preenchido." / "Preencha o Número de Inscrição."
		lRet :=	.F.

	ElseIf !Empty(Alltrim(cTpInsc)) .And. !Empty(Alltrim(cNrInsc))

		If cTpInsc == "2" //.or. cTpInsc == "3" //CPF

			// Tratamento para a simplificação do e-Social
			If TafLayESoc("S_01_00_00") .AND. "T1V_NRINAP" $ cCmp
				If cCGCInsc == "2" .AND. Alltrim(cNrInsc) == cCGC
					Help(, , STR0008, , STR0200, 1, 0, , , , , , {STR0201}) // "ATENÇÄO" / "O CPF informado deve ser diferente do empregador." / "Inclua um CPF diferente."
					lRet	:=	.F.
				ElseIf Alltrim(cNrInsc) == AllTrim(M->T1V_CPF)
					Help(, , STR0008, , STR0202, 1, 0, , , , , , {STR0201}) // "ATENÇÄO" / "O CPF informado deve ser diferente do empregado." / "Inclua um CPF diferente."
					lRet	:=	.F.
				EndIf
			EndIf

			If !CGC( cNrInsc,,lTAFValid ) .OR. len( Alltrim(cNrInsc) ) <> 11 .OR. cNrInsc == "99999999999"
				lRet	:=	.F.
			EndIf

		ElseIf cTpInsc == "1"

			// Tratamento para a simplificação do e-Social
			If TafLayESoc("S_01_00_00") .AND. "T1V_NRINAP" $ cCmp
				If cCGCInsc == "1" .AND. Left(Alltrim(cNrInsc), 8) == Left(cCGC, 8)
					Help(, , STR0008, , STR0203, 1, 0, , , , , , {STR0204}) // "ATENÇÄO" / "A raiz do CNPJ informado deve ser diferente do empregador." / "Inclua um CNPJ com a raiz diferente."
					lRet	:=	.F.
				EndIf
			EndIf

			If !CGC( cNrInsc,,lTAFValid ) .OR. len( Alltrim(cNrInsc) ) <> 14 .OR. cNrInsc == "99999999999999"
				lRet	:=	.F.
			EndIf

		EndIf

	EndIf

	If lTAFValid
		If !lRet
			Help( ,, AllTrim( SubStr( cCmp , 4 ) ) ,,, 1 , 0 )
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafLegend
Determina o tipo de legenda para as interfaces do TAF.

@Param  nTpLeg	 -  Tipo de Legenda
		 (1 - Padrão, 2 - Eventos não cadastrais e-Social)
		 cAlias	 - Alias do Browse
		 oBrw 	 - Objeto FwMBrowse()

@Return Nil

@Author Evandro dos Santos Oliveira
@Since 13/11/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafLegend(nTpLeg, cAlias, oBrw)

	Local cLegAlt  := STR0102
	Default nTpLeg := 1

	If cAlias == "C9V"
		cLegAlt := STR0108 //"Registro Retificado"
	EndIf

	If TAFColumnPos( "C9V_IDTRAN" )  .And. nTpLeg == 2 .And. cAlias = 'C9V'	.And. TAFColumnPos( "C9V_DTTRAN" )
		oBrw:AddLegend( "!Empty("+cAlias+"_IDTRAN) .AND. !Empty(" + cAlias+"_DTTRAN ) .And. " + cAlias + "_EVENTO <> 'E'", "PINK"   , IIF(cAlias <> "CM8","Funionário Transferido",STR0110) )  //"Registro Finalizado / Registro Cancelado"
	ElseIf TAFColumnPos( "C9V_IDTRAN" )  .And. nTpLeg == 2 .And. cAlias = 'C9V'
		oBrw:AddLegend( "!Empty("+cAlias+"_IDTRAN) .AND. " + cAlias+"_ATIVO = '2' "		, "PINK"   , IIF(cAlias <> "CM8","Funionário Transferido",STR0110) )  //"Registro Finalizado / Registro Cancelado"
	EndIf

	oBrw:AddLegend( cAlias+"_EVENTO == 'I'  " 	    								, "GREEN" 	, STR0101 ) //"Registro Incluído"

	oBrw:AddLegend( cAlias+"_EVENTO == 'A' "									, "YELLOW"	, cLegAlt ) //"Registro Alterado"

	oBrw:AddLegend( cAlias+"_EVENTO == 'E' .AND. " + cAlias+"_STATUS <> '6'"		, "RED"   	, STR0103 ) //"Registro Excluído"

	IF nTpLeg == 3
		oBrw:AddLegend( cAlias+"_EVENTO == 'R' "									, "WHITE"  	, STR0108 ) //"Registro Retificado"
		oBrw:AddLegend( cAlias+"_EVENTO == 'F' "									, "BLACK"   , IIF(cAlias <> "CM8",STR0109,STR0110) )  //"Registro Finalizado / Registro Cancelado"
		oBrw:AddLegend( cAlias+"_EVENTO == 'E' .AND. " + cAlias+"_STATUS == '6'" 	, "ORANGE"	, STR0104)	//"Aguardando Exclusão da Transmissão"
	ElseIf nTpLeg == 2
		oBrw:AddLegend( cAlias+"_EVENTO == 'E' .AND. " + cAlias+"_STATUS == '6'" 	, "ORANGE"	, STR0104)  //"Aguardando Exclusão da Transmissão"
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunTrCNH(Função Troca CNH)

Função para trocar número por letra ou letra por número no combo do campo das Categorias do CNH



@param		cVlrOriCat: Valor original da categoria da CNH
			nTpTrc: Tipo de Troca;
						Se igual 1, troca de número por letra;
						Se igual 2, troca de letra por número;

@return cRet - Retorna o valor alterado.

@author Daniel O. Schmidt
@since 16/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function xFunTrCNH(cVlrOriCat, nTpTrc)

	Local cRet         := ""

	Default cVlrOriCat := ""
	Default nTpTrc     := 1

	If !Empty( cVlrOriCat )
		Do Case
		Case nTpTrc == 1
			if cVlrOriCat == "1"
				cRet := "A"
			ElseIf cVlrOriCat == "2"
				cRet := "B"
			ElseIf cVlrOriCat == "3"
				cRet := "C"
			ElseIf cVlrOriCat == "4"
				cRet := "D"
			ElseIf cVlrOriCat == "5"
				cRet := "E"
			ElseIf cVlrOriCat == "6"
				cRet := "AB"
			ElseIf cVlrOriCat == "7"
				cRet := "AC"
			ElseIf cVlrOriCat == "8"
				cRet := "AD"
			ElseIf cVlrOriCat == "9"
				cRet := "AE"
			Endif
		Case nTpTrc == 2
			if cVlrOriCat == "A"
				cRet := "1"
			ElseIf cVlrOriCat == "B"
				cRet := "2"
			ElseIf cVlrOriCat == "C"
				cRet := "3"
			ElseIf cVlrOriCat == "D"
				cRet := "4"
			ElseIf cVlrOriCat == "E"
				cRet := "5"
			ElseIf cVlrOriCat == "AB"
				cRet := "6"
			ElseIf cVlrOriCat == "AC"
				cRet := "7"
			ElseIf cVlrOriCat == "AD"
				cRet := "8"
			ElseIf cVlrOriCat == "AE"
				cRet := "9"
			Endif
		EndCase
	EndIf

Return ( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} XVldFone
Funcao generica utilizada para efetuar a validação do número de telefone com DDD.
Verificado se contém apenas números, com o mínimo de dez dígitos.

@Param  cDDD  -  Número do DDD
		 cFone -  Número do Telefone

@return lRet - Retorno da validação efetuada.

@author Denis R. de Oliveira
@since 18/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function XVldFone( cDDD , cFone )

	Local lRet		   := .T.
	Local cFoneCompl := ""
	Local x := 0

	cFoneCompl := Alltrim(cDDD)+ Alltrim(cFone)

	If Len(cFoneCompl) < 10
		lRet := .F.
	Else
		For x := LEN(cFoneCompl) TO 1 STEP -1
			lRet := Iif(SUBSTR(cFoneCompl,x,1) $ "0123456789",lRet,.F.)
		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMsgVldOp
Esta função tem como objetivo definir a mensagem de erro que será
 exibida após o SaveModel retornar falso, de acordo com o status do
 registro que está sendo validado.

@Author Paulo V.B. Santana
@since 01/12/2015
@version 1.0

@param oModel	 - Modelo que terá a mensagem de erro redefinida
        cStatus - Status do Registro

/*/
//-------------------------------------------------------------------
Function TAFMsgVldOp( oModel, cStatus )

	If cStatus == "2"
		oModel:SetErrorMessage(, , , , , xValStrEr("000727"), , , ) //"Registro não pode ser alterado. Aguardando processo da transmissão."
	Elseif cStatus == "6"
		oModel:SetErrorMessage(, , , , , xValStrEr("000728"), , , ) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
	Elseif cStatus == "4"
		oModel:SetErrorMessage(, , , , , xValStrEr("000760"), , , ) //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET"
	Elseif cStatus == "7"
		oModel:SetErrorMessage(, , , , , xValStrEr("000772"), , , ) //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAcessPer
Realiza a validação de permissão de acesso ao registro selecioando no browse.

@Param	cAliasTrb	->	Área de trabalho
@Param	cEvento		->	Evento que o acesso será validado
@Param	cMsg		->	Controle das mensagens a serem exibidas
@Param	nMark		->	Controle dos itens marcados no browse
@Param	cRotina		->	Rotina que o acesso será validado
@Param	cAlias		->	Tabela que o acesso será validado
@Param	lMarkAll	->	Flag que indica se a interface que chamou a função possui
						múltipla seleção de registros.
@Param	cFilAccCFG	->	Filial para checagem de acesso a rotina corrente

@Return	Lógico (.T. ou .F.)

@Author	Denis R. de Oliveira
@Since		19/05/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function FPerAcess(cAliasTrb,cLayout,cMsg,nMark,cRotina,lJob,lMarkAll,cFilAccCFG)

	Local aLayReg		:= {}
	Local alRetRot		:= {}
	Local cMsgInfo		:= ""
	Local lRet			:= .T.
	Local cFilBkp		:= cFilAnt
	Local nPosScan		:= 0

	Default cAliasTrb	:= ""
	Default cLayout		:= ""
	Default cMsg		:= ""
	Default nMark		:= 0
	Default cRotina		:= ""
	Default lJob		:= .F.
	Default lMarkAll	:= .F.
	Default cFilAccCFG	:= cFilAnt

	//-- Encontro a rotina que será validada através do evento do e-social (Monitor E-Social e Gerenciador de Integrações)
	If Empty(cRotina)

		If cLayout $ "S-2200|S-2205|S-2206|S-2300|S-2306"
			cRotina	:= "TAFA421"
		ElseIf "AUTO" $ cLayout
			cRotina	:= "TAFA473"
		Else
			aLayReg	:= TAFRotinas(cLayout,4,.F.,0)
			If Len(aLayReg) > 0
				cRotina	:= aLayReg[1]
			EndIf
		EndIf

	//-- Já possuo a rotina que será validada e busco o evento do e-social (Painel do Trabalhador)
	Else

		If cRotina $ "TAFA420|TAFA421"
			cLayout	:= STR0126 //"do Trabalhador"
		Else
			aLayReg	:= TAFRotinas(cRotina,1,.F.,0)
			If Len(aLayReg) >= 4
				cLayout	:= aLayReg[4]
			EndIf
		EndIf

	EndIF

	alRetRot := TAFRotinas(cRotina,1,.F.,0)

	//-- Trato a mensagem a ser exibida de acordo com o escopo
	If cRotina == "TAFA050"
		cMensagem := cRotina + STR0132 //"O usuário logado no sistema não possui permissão de acesso à rotina de 'Complemento do Cadastro de Estabelecimentos' ( T001 | S-1000 )."
	ElseIf cRotina == "TAFA051"
		cMensagem := cRotina + STR0133 //"O usuário logado no sistema não possui permissão de acesso à rotina de 'Processos Referenciados' ( T001AB | S-1070 )."
	ElseIf Len(alRetRot) >= 5 .And. alRetRot[5] == "2"
		if valtype( cLayout ) == "C"
			cMensagem := cRotina + STR0128 + cLayout // "O usuário logado no sistema não possui permissão de acesso à rotina: " # " - Evento " # cLayout
		elseif valtype( cLayout ) == "U"
			cMensagem := cRotina + STR0128 // "O usuário logado no sistema não possui permissão de acesso à rotina: " # " - Evento " # cLayout
		endif
	Else
		if valtype( cLayout ) == "C"
			cMensagem := cRotina + STR0134 + cLayout // "O usuário logado no sistema não possui permissão de acesso à rotina: " # " - Registro " # cLayout
		elseif valtype( cLayout ) == "U"
			cMensagem := cRotina + STR0128 // "O usuário logado no sistema não possui permissão de acesso à rotina: " # " - Evento " # cLayout
		endif
	EndIf

	//Altera filial para checagem das acesso a rotina corrente
	cFilAnt := cFilAccCFG

	//-- Validação do item marcado no browse
	If !lMarkAll

		//Verifica se já fez consulta de acesso
		nPosScan := aScan(aUsrAccess, {|x|  x[1] == cFilAnt .AND. x[2] == cRotina})

		//-- Verifico se o usuário corrente tem acesso a rotina
		If GetVersao(.f.) < '12' .or. nPosScan > 0 .OR. MPUserHasAccess(cRotina, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )
			lRet := .T.

			//Adiciona Filial e Rotina no array para melhoria de performance de consultas consecutivas
			If nPosScan == 0
				aAdd(aUsrAccess, {cFilAnt, cRotina})
			EndIf

		Else
			lRet := .F.

			If !lJob
				MSGALERT(STR0127 + cMensagem, STR0129) // "Acesso Negado"
			Else
				TAFConOut(STR0127 + cMensagem)
			EndIf

		EndIf

	//-- Validação de todos os itens do browse
	Else

		nMark++ //Controle dos itens marcados

		//Verifica se já fez consulta de acesso
		nPosScan := aScan(aUsrAccess, {|x|  x[1] == cFilAnt .AND. x[2] == cRotina})

		//Verifico se o usuário corrente tem acesso a rotina
		If GetVersao(.f.) < '12' .or. nPosScan > 0 .OR. MPUserHasAccess(cRotina, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )
			lRet := .T.

			//Adiciona Filial e Rotina no array para melhoria de performance de consultas consecutivas
			If nPosScan == 0
				aAdd(aUsrAccess, {cFilAnt, cRotina})
			EndIf

		Else

			If !( FwCutOff(cMsg) == FwCutOff(cMensagem) )
				cMsg+= cMensagem + CRLF	//Guardo as rotinas que o usuário não possui acesso
			EndIF
			lRet := .F.

		EndIf

		//Verifico se foi encontrado algum item sem acesso e todo browse foi percorrido e verificado
		If !Empty(cMsg) .AND. (cAliasTrb)->(LASTREC()) == nMark

			//Monto e exibo a mensagem de alerta
			cMsgInfo := STR0130 + CRLF + CRLF //"O usuário logado no sistema não possui permissão de acesso as seguintes rotinas: "
			If !lJob
				MSGALERT(cMsgInfo + cMsg, STR0131) //"Restrições de Acesso"
			Else
				TAFConOut(cMsgInfo + cMsg)
			EndIf

			//Limpo as variaveis de controle
			nMark		:= 0
			cMsg		:= ""
			lMarkAll	:= .F.

		EndIf

	EndIf

	//Restaura filial anterior
	cFilAnt := cFilBkp

Return lRet

/*/{Protheus.doc} TAFGetValue
Execução de pesquisa em arquivo.
@author Victor Andrade
@since 26/07/2017
@version undefined
@type function
/*/
Function TAFGetValue(cAlias, nIndice, cIndice, cCampo, xDefault)

	Local xRet	:= Nil
	Local aArea := GetArea()

	Default cAlias 	 := Alias()
	Default nIndice	 := IndexOrd()
	Default cIndice  := ""
	Default cCampo	 := ""

	If Alias() <> cAlias
		DbSelectArea(cAlias)
	EndIf

	&(cAlias)->( DbSetOrder(nIndice) )

	If &(cAlias)->( MsSeek( cIndice ) )
		xRet := &( (cAlias) + "->" + cCampo )
	Else
		If ValType(xDefault) <> "U"
			xRet := xDefault
		EndIf
	EndIf

	RestArea(aArea)

Return(xRet)

/*/{Protheus.doc} TAFAtualizado

Verifica se o TAF esta atualizado com relação aos ultimos pacotes de atualização

@author Fabio V Santana
@since 27/07/2017
/*/
Function TAFAtualizado( lMsgAlert ,cRotina  )

	Local cMsg        := ""
	Local lRet        := .T.
	Local lTAFLOAD    := IsInCallStack( "TAFLOAD" )

	Default lMsgAlert := .T.
	Default cRotina   := ""

	If ( ( lTAFLOAD .And. TCCanOpen( RetSqlName( "C9V" ) ) ) .or. !lTAFLOAD ) .And. !( TAFColumnPos( "C9V_CADINI" ) )

		lRet := .F.

		cMsg := I18N( STR0135, { "<b>desatualizado</b>", "layout 2.3 do eSocial" } ) + CRLF + CRLF //"O ambiente do TAF encontra-se #1 com relação as alterações referentes ao #2."
		cMsg += STR0136 + CRLF + CRLF //"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas do que o dicionário de dados."
		cMsg += I18N( STR0137, { "<b>UPDTAF</b>" } ) //"Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados #1."

		If lMsgAlert
			FwAlertWarning( cMsg, "Ambiente Desatualizado!" )
		Else
			TAFConOut( cMsg )
		EndIf

	ElseIf ( ( lTAFLOAD .And. TCCanOpen( RetSqlName( "CMD" ) ) ) .or. !lTAFLOAD ) .And. !( TAFColumnPos( "CMD_CPFSUB" ) )

		lRet := .F.

		cMsg := I18N( STR0135, { "<b>desatualizado</b>", "layout 2.4 do eSocial" } ) + CRLF + CRLF //"O ambiente do TAF encontra-se #1 com relação as alterações referentes ao #2."
		cMsg += STR0136 + CRLF + CRLF //"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas do que o dicionário de dados."
		cMsg += I18N( STR0137, { "<b>UPDTAF</b>" } ) //"Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados #1."

		If lMsgAlert
			FwAlertWarning( cMsg, "Ambiente Desatualizado!" )
		Else
			TAFConOut( cMsg )
		EndIf

	ElseIf cRotina == "TAFA280" .And. !TAFAlsInDic( "T92" )

		lRet := .F.

		cMsg := I18N( STR0135, { "<b>desatualizado</b>", "layout 2.4.0.1 do eSocial" } ) + CRLF + CRLF //"O ambiente do TAF encontra-se #1 com relação as alterações referentes ao #2."
		cMsg += STR0136 + CRLF + CRLF //"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas do que o dicionário de dados."
		cMsg += I18N( STR0137, { "<b>UPDTAF</b>" } ) //"Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados #1."

		If lMsgAlert
			FwAlertWarning( cMsg, "Ambiente Desatualizado!" )
		Else
			TAFConOut( cMsg )
		EndIf

	/// Referencia ao pacote 18-05-25-TAF-DICIONARIOS_DIF_12_1_17
	ElseIf GetVersao(.F.) != "11" .And. (!TAFAlsInDic( "V1M" ) ; // Desligamento - e-Social
		.Or. !TAFAlsInDic( "C9Y" ); // Trabalhador - e-Social
		.Or. ( TamSx3("CH8_CODIGO")[01] <> 7 ) ;// ECF
		.Or. !TAFAlsInDic( "V1O" ) ;// Periodos - Reinf
		.Or. !TafColumnPos("CMD_DTASO") ;// eSocial
		.Or. !TafColumnPos("CMD_PROCCS") ;// eSocial
		.Or. ( GetNewPar( "MV_TAFRVLD","XXX") == "XXX" ))

		lRet := .F.

		cMsg := I18N( STR0135, { "<b>desatualizado</b>", "layout 2.4.02 do eSocial e ao layout 1.03.02 da EFD Reinf"} ) + CRLF + CRLF //"O ambiente do TAF encontra-se #1 com relação as alterações referentes ao #2."
		cMsg += STR0136 + CRLF + CRLF //"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas do que o dicionário de dados."
		cMsg += I18N( STR0137, { "<b>UPDTAF</b>" } ) //"Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados #1."

		If lMsgAlert
			FwAlertWarning( cMsg, "Ambiente Desatualizado!" )
		Else
			TAFConOut( cMsg )
		EndIf

	ElseIf ( ( lTAFLOAD .And. TCCanOpen( RetSqlName( "T0C" ) ) ) .or. !lTAFLOAD ) .And. !( TAFColumnPos( "T0C_CODREC" ) )

		lRet := .F.

		cMsg := I18N( STR0135, { "<b>desatualizado</b>", "Pacote de Atualização Periódica Junho/2018" } ) + CRLF + CRLF //"O ambiente do TAF encontra-se #1 com relação as alterações referentes ao #2."
		cMsg += STR0136 + CRLF + CRLF //"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas do que o dicionário de dados."
		cMsg += I18N( STR0137, { "<b>UPDTAF</b>" } ) //"Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados #1."

		If lMsgAlert
			FwAlertWarning( cMsg, "Ambiente Desatualizado!" )
		Else
			TAFConOut( cMsg )
		EndIf

	ElseIf TafLayESoc("S_01_00_00") .And. !TAFColumnPos("T1V_CODTRE")

		Help( ,, "HELP",, "O parâmetro MV_TAFVLES está com o layout da simplificação do esocial (S_01_00_00) mas não existem os novos campos, necessário aplicar pacote de dicionário e rodar o upddistr", 1, 0 )
		lRet := .F.
	
	ElseIf cRotina == "TAFA413" .And. !TAFColumnPos("T61_ORGSUC")

		Help( ,, "HELP",, "O evento S-1202 somente será enviado no layout da simplificação do esocial (S-1.0), mas não existem os novos campos. É necessário aplicar o pacote de dicionário da expedição continua e executar o upddistr", 1, 0 )
		lRet := .F.

	ElseIf cRotina == "TAFA587" .And. !TAFAlsInDic( "V72" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2231" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

	ElseIf cRotina == "TAFA588" .And. !TAFAlsInDic( "V73" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2400" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

	ElseIf cRotina == "TAFA591" .And. !TAFAlsInDic( "V75" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2410" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

	ElseIf cRotina == "TAFA470" .And. !TafColumnPos("T62_IDBEN")

		Help( ,, "HELP",, I18N( STR0211, { "S-1207" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

		
	ElseIf cRotina == "TAFA276" .And. TafLayESoc("S_01_00_00") .And. !TAFAlsInDic( "V91" )
		
		Help( ,, "HELP",, I18N( STR0211, { "S-2206" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.
	
	ElseIf cRotina == "TAFA278" .And. TafLayESoc("S_01_00_00") .And. !TAFAlsInDic( "V87" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2200" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.
		
	ElseIf cRotina == "TAFA608" .And. !TAFAlsInDic( "V9U" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2500" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

	ElseIf cRotina == "TAFA609" .And. !TAFAlsInDic( "V7C" )

		Help( ,, "HELP",, I18N( STR0211, { "S-2501" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.

	ElseIf cRotina == "TAFA610" .And. !TAFAlsInDic( "V7J" )

		Help( ,, "HELP",, I18N( STR0211, { "S-3500" } ) , 1, 0 ) // "Ambiente desatualizado para o evento #1. Será necessário aplicar pacote de dicionário e rodar o upddistr"
		lRet := .F.
		
	EndIf

Return( lRet )

Function TAFXLogMSG( cMsg )

	//Local cMsgLog	as	character
	//cMsgLog	:=	GetSrvProfString ( 'TAFLOGMESSAGE', '0' )
	If cTAFXLOGMSG == '1'

		cMsg	:=	'TAFLOG(Thd: ' + AllTrim( Str( ThreadID() ) ) + '): ' + DToS( dDataBase ) + ', ' + Time() + ' -> ' + cMsg
	/*
	cSeverity, Informe a severidade da mensagem de log. As opções possiveis são: INFO,WARN,ERROR,FATAL,DEBUG
	cTransactionId, Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior	FWUUIDV1()
	cGroup, Informe o Id do agrupador de mensagem de Log
	cCategory, Informe o Id da categoria da mensagem
	cStep, Informe o Id do passo da mensagem
	cMsgId, Informe o Id do código da mensagem
	cMessage, Informe a mensagem de log. Limitada à 10K
	nMensure, Informe a uma unidade de medida da mensagem
	nElapseTime, Informe o tempo decorrido da transação
	aMessage, Informe a mensagem de log em formato de Array
	*/
		//FWLogMsg('DEBUG',, "BusinessObject", FunName(), 'INTEGRAÇÃO', 'PROCESSAMENTO', cMsg, Nil, Nil, Nil)
		TAFConOut(cMsg)
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} xPerToData
Realiza a conversão de um campo caracter de período no formato (MMAAAA),
para um campo data no formato (DD/MM/AAAA)

@Param	cPeriodo

@Return	dData

@Author	Denis R. de Oliveira
@Since		08/01/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function xPerToData( cPeriodo )

	Local dData

	Default cPeriodo := "011900"

	dData :=	CToD( " / / " )

	If !Empty(cPeriodo) .AND. Len(cPeriodo) == 6 .AND. IsNumeric(cPeriodo)

		dData := STOD( Substr(cPeriodo,3,4) + Substr(cPeriodo,1,2) + "01" ) //Monto a data no formato string (AAAAMMDD) e converto para o tipo Data

	EndIf

Return dData

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXAToHM

Encapsulamento e verificação da existência da função AToHM
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/x/lYObB

@author Felipe Rossi Moreira
@since 06/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXAToHM(aMatriz, nColuna_1, nTrim_1) //, nColuna_2, nTrim_2, nColuna_3, nTrim_3, nColuna_4, nTrim_4,  nColuna_5, nTrim_5, nColuna_6, nTrim_6, nColuna_7, nTrim_7, nColuna_8, nTrim_8

	Local oHash := nil
	Local cRotina := "AToHM"

	If FindFunction(cRotina)
		oHash := &cRotina.(aMatriz, nColuna_1, nTrim_1)
	Else
		oHash := {aClone(aMatriz), nColuna_1, nTrim_1}
	EndIf

Return(oHash)



//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXHMGet

Encapsulamento e verificação da existência da função HMGet
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/x/joObB

@author Felipe Rossi Moreira
@since 06/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXHMGet(oHash, yKey, aVal)

	Local lRet := .F.
	Local cRotina := "HMGet"
	Local aProcura := {}
	Local nCol
	Local nTrim
	Local nPos

	If FindFunction("AToHM") .And. FindFunction(cRotina)
		lRet := &cRotina.(oHash, yKey, @aVal)
	Else
		aProcura := aClone(oHash[1])
		nCol := oHash[2]
		nTrim := oHash[3]

		If nTrim == 1
			nPos := aScan(aProcura, {|aLinha| LTrim(aLinha[nCol]) == LTrim(yKey)})
		ElseIf nTrim == 2
			nPos := aScan(aProcura, {|aLinha| RTrim(aLinha[nCol]) == RTrim(yKey)})
		ElseIf nTrim == 3
			nPos := aScan(aProcura, {|aLinha| AllTrim(aLinha[nCol]) == AllTrim(yKey)})
		Else
			nPos := aScan(aProcura, {|aLinha| aLinha[nCol] == yKey})
		EndIf

		If nPos > 0
			aVal := {aClone(aProcura[nPos])}
			lRet := .T.
		Endif
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafXCommit

Funcao para Ser chamada genericamente antes de executar um commit de um modelo

@param	oModel  - Objeto do Model
		cModel  - Nome do Model
		cAliasX - Alias principal do Model

@return Nil

@author Roberto Souza
@since 04/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafXCommit( oModel, cModel, cAliasX )

	//Tratamento para evitar erro de função duplicada no RPO, após mudança de local da função para o fonte TAFEXTEMP.prw
	If FindFunction("TafGrvExt")
		TafGrvExt( oModel, cModel, cAliasX )
	EndIf

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxExtemp

Funcao para verificar se a funcionalidade de eventos extemporaneos esta habilitada

@Param:	None
@Return: lRet
				.T. Para validacao OK
				.F. Para validacao NAO OK

@author Roberto Souza
@since 04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxExtemp()

	Local lRet	:= .F.

	//Tratamento para evitar erro de função duplicada no RPO, após mudança de local da função para o fonte TAFEXTEMP.prw
	If FindFunction("xTafExtmp")
		If xTafExtmp()
			lRet := .T.
		EndIf
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunNewHis

Funcao para criar a tela de historico de alteracoes do registro.
O registro a ser filtrado eh o mesmo selecionado pelo usuario na Grid
Similar a xFunHisAlt, com as alterações de novas colunas, legendas e itens para atender os eventos extemporaneos.

@Param:
cAlias  -  Alias da Tabela Principal ( Tabela onde a Grid eh baseada
                                       para montar as informacoes    )
cRotina - Rotina onde a ViewDef se encontra
cTitulo - Titulo da Janela
lCadTrab- Informa se trata-se de Eventos do Trabalhador

@Return:

@author Roberto Souza
@since 04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunNewHis( cAlias, cRotina, aHeaderT, cTitulo, lCadTrab, lCadBen, aCampos)

	Local cFilterArea	:= (cAlias)->(DbFilter())
	Default aCampos := {}

	//Tratamento para evitar erro de função duplicada no RPO, após mudança de local da função para o fonte TAFEXTEMP.prw
	If FindFunction("xNewHisAlt")
		xNewHisAlt( cAlias, cRotina, aHeaderT, cTitulo, lCadTrab, Nil , "", "", "", lCadBen, aCampos)
	EndIf

	DbSelectArea(cAlias)

	//Retornamos o filtro original da tabela.
	Set Filter TO &(cFilterArea)

Return( .F. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafTmpWiz
Funcao que grava e/ou recupera parametros complementares que o Wizard não guarda
@author Roberto Souza
@since 10/01/2018
@version 1.0

@aParam	- cFileRef - Nome do arquivo a ser guardado/lido
		- nOpcx :	1-Carrega as Informações
 							2-Grava as Informações
		- aParChck	-	Parametros contendo o nome, tipo e conteudo das variaveis

@return Nil
/*/
//-------------------------------------------------------------------
Function TafTmpWiz( cFileRef, nOpcx, aParChck )

	Local lRet
	Local cBuffer
	Local Nx
	Local nTamVar
	Local nTamTipo

	lRet 		:= .F.
	cBuffer		:= ""
	nTamVar		:= 10
	nTamTipo	:= 1

	If nOpcx == 1 // Carrega
		If File( cFileRef )
			cBuffer := MemoRead( cFileRef )
			nLines 	:= MLCount( cBuffer )

			// Varre todas as linhas do texto
			For Nx := 1 To nLines
				cLin 		:= MemoLine( cBuffer, , Nx )
				cVar 		:= Alltrim( PadR( cLin, nTamVar) )
				cTipo		:= Alltrim( Substr( cLin, nTamVar + 1,nTamTipo) )
				uContent	:= Alltrim( Substr( cLin, nTamVar + nTamTipo +1) )

				If !Empty( cVar ) .And. !Empty( cTipo )
					If cTipo == "C"
						uRet 	:= uContent
					ElseIf cTipo == "L"
						uRet 	:= IIf( AllTrim(uContent)==".T.",.T.,.F.)
					ElseIf cTipo == "N"
						uRet 	:= Val( uContent )
					ElseIf cTipo == "D"
						uRet 	:= Stod( uContent )
					EndIf

					//&( cVar ) := uRet
					nPos := aScan( aParChck, { |x| x[01]==cVar  })

					If nPos > 0
						aParChck[nPos][03] := uRet
					Else
						AADD(aParChck,{cVar,cTipo,uRet})
					EndIf
					lRet := .T.
				EndIf
			Next
		EndIf

	ElseIf nOpcx == 2 // Grava
		For Nx := 1 To Len( aParChck )

			cBuffer	+= PadR( aParChck[Nx][01], nTamVar)
			cBuffer	+= PadR( aParChck[Nx][02], nTamTipo)

			If aParChck[Nx][02] == "C"
				cBuffer 	+= aParChck[Nx][03]
			ElseIf aParChck[Nx][02] == "L"
				cBuffer 	+= IIf( aParChck[Nx][03],".T.",".F.")
			ElseIf aParChck[Nx][02] == "N"
				cBuffer 	+= cValToChar(aParChck[Nx][03])
			ElseIf aParChck[Nx][02] == "D"
				cBuffer 	+= dTos( aParChck[Nx][03] )
			EndIf
			cBuffer	+= CRLF
			lRet := .T.
		Next
		MemoWrite( cFileRef, cBuffer)
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelStru
Rotina que força a exclusão de um diretorio e seu conteudo recursivamemte
@author Roberto Souza
@since 10/01/2018
@version 1.0

@aParam	cMainPath - Diretorio Principal

@return Nil
/*/
//-------------------------------------------------------------------
Function TafDelStru( cMainPath )

	Local aDirDel
	Local Nw
	Local lRet

	lRet 	:= .F.

	If ExistDir( cMainPath )
		aDirDel := Directory( cMainPath +"\*.*","D")


		For Nw := 1 To Len( aDirDel )
			If aDirDel[Nw][05] == "A"
				FErase( cMainPath +'\'+ aDirDel[Nw][01] )
			ElseIf aDirDel[Nw][05] == "D" .And. !( aDirDel[Nw][01] $ ".|.." )
				TafDelStru( cMainPath +'\'+ aDirDel[Nw][01]  )
			EndIf
		Next
		lRet := DirRemove( cMainPath )
	EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldSGBD
Verifica a integridade do banco de dados
@author Roberto Souza
@since 15/01/2018
@version 1.0

@aParam	lMsg	-	Informa se mostra a mensagem

@return lRet - 	.T. = Sem inconsistencia
				.F. = Possui inconsistencia
/*/
//-------------------------------------------------------------------
Function TAFVldSGBD( lMsg )

	Local lRet
	Local cDatabase
	Local cIND
	Local aInd
	Local oArea
	Local oFont

	Default lMsg		:= .T.

	lRet		:= .T.
	cIND 		:= GetNextAlias()
	aInd 		:= {}
	cDatabase 	:= Upper(Alltrim(TCGetDB()))
	oFont		:= TFont():New("Arial",08,14,,.T.,,,,.T.)

	lDemo		:= .F.

	// Para OpenEdge Progress, valida os indices inativos
	If cDatabase == "OPENEDGE"

		BeginSql ALIAS cIND
			SELECT *
				FROM sysprogress.SYSINDEXES
			WHERE active = 0
			ORDER BY idxname , idxseq
		EndSql
		/*
		Column name		Column data type	Column size
		abbreviate		BIT					1
		active			BIT					1
		creator			VARCHAR				32
		colname			VARCHAR				32
		desc			VARCHAR				144
		id				INTEGER				4
		idxcompress		VARCHAR				1
		idxmethod		VARCHAR				2
		idxname			VARCHAR				32
		idxorder		CHARACTER			1
		idxowner		VARCHAR				32
		idxsegid		INTEGER				4
		idxseq			INTEGER				4
		ixcol_user_misc	VARCHAR				20
		rssid			INTEGER				4
		tbl				VARCHAR				32
		tblowner		VARCHAR				32
		*/

		While (cIND)->(!Eof())

			AADD(aInd,{;
				(cIND)->active,;
				(cIND)->id,;
				(cIND)->idxname,;
				(cIND)->idxseq,;
				(cIND)->idxowner,;
				(cIND)->tbl,;
				(cIND)->colname,;
				})

			(cIND)->(DbSkip())
			lRet := .F.
		EndDo

		// Demo
		If Empty( aInd) .And. lDemo

			AADD(aInd,{'0','INDICE 01','SXX001','1','TAF','SXX','SXX_001'})
			AADD(aInd,{'0','INDICE 01','SXX001','2','TAF','SXX','SXX_002'})
			AADD(aInd,{'0','INDICE 01','SXX001','2','TAF','SXX','SXX_002'})

		EndIf

		If Len( aInd ) > 0 .And. lMsg

			// Dialog
			aWindow := {015,085}
			aColumn := {090,010}

			oArea	:= FWLayer():New()
			oDlgScr := tDialog():New(000,000,600,1200,"Indices Inativos - OPENEDGE",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
			oArea:Init(oDlgScr,.F., .F. )

			oArea:AddLine("L01",100,.T.)

			oArea:AddCollumn("LEFT"	,aColumn[01],.F.,"L01") //dados
			oArea:AddCollumn("RIGHT",aColumn[02],.F.,"L01") //botoes

			oArea:AddWindow("LEFT","TEXT","Informações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oText	:= oArea:GetWinPanel("LEFT","TEXT","L01")

			oArea:AddWindow("LEFT","LIST","Detalhes",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oList	:= oArea:GetWinPanel("LEFT","LIST","L01")

			oArea:AddWindow("RIGHT","FUNCTION","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oAreaBut := oArea:GetWinPanel("RIGHT","FUNCTION","L01")


			@ 002,002 SAY "Existem indices inativos no banco de dados, o que pode acarretar em erros nas rotinas do TAF." FONT oFont COLOR CLR_BLUE Pixel Of oText
			@ 012,002 SAY "É recomendável que seja feita a manutenção nos indices para garantir o funcionamento do sistema." FONT oFont COLOR CLR_BLUE Pixel Of oText


			@ 000,000 LISTBOX oLbx FIELDS ;
				HEADER 'active','id','idxname','idxseq','idxowner','tbl','colname' ; //'abbreviate','active','creator','colname','desc','id','idxcompress','idxmethod','idxname','idxorder','idxowner','idxsegid','idxseq','ixcol_user_misc','rssid','tbl','tblowner'  ;
				COLSIZES 2,8,50,5,50,50,50 ;// 1,1,32,32,144,4,1,2,32,1,32,4,4,20,4,32,32 ;
				SIZE 230,095 OF oList PIXEL

			oLbx:SetArray( aInd )
			oLbx:bLine := {|| { 	aInd[oLbx:nAt][01] ,;
				aInd[oLbx:nAt][02] ,;
				aInd[oLbx:nAt][03] ,;
				aInd[oLbx:nAt][04] ,;
				aInd[oLbx:nAt][05] ,;
				aInd[oLbx:nAt][06] ,;
				aInd[oLbx:nAt][07] }}

			oLbx:Align    	:= CONTROL_ALIGN_ALLCLIENT

			oButt1 := tButton():New(000,000,"&Sair"				,oAreaBut,{|| oDlgScr:End()}  		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

			oDlgScr:Activate(,,,.T.,/*valid*/,,/*On Init*/)

		EndIf
	Else
		lRet := .T.
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafInfoMap
Mapeamento de endereços e portas usadas no TAF
@author Roberto Souza
@since 16/01/2018
@version 1.0

@aParam

@return aMar - 	array com as informações
/*/
//-------------------------------------------------------------------
Function TafInfoMap()

	Local aMap

	aMap := {}

	cIp			:= getServerIP()
	cIniFile	:= getAdv97()
	cRootPath	:= GetSrvProfString( "RootPath" , "" )

	cTafIni		:= StrTran( cRootPath+"\bin\appserver\"+cIniFile	, "\\","\")
	cRestIni 	:= StrTran( cRootPath+"\bin\app\"+cIniFile	, "\\","\")
	cAtuIni 	:= StrTran( cRootPath+"\bin\app\"+cIniFile	, "\\","\")
	cDbIni 		:= StrTran( cRootPath+"\TafDbAccess\"+cIniFile	, "\\","\")

	cPortaTAF 	:=	getPvProfString( "TCP" 		, 'PORT' 	, '' , cIniFile )
	cPortaWS 	:=	getPvProfString( "HTTPREST" , 'PORT' 	, '' , If(File(cRestIni),cRestIni	,cTafIni)	, Nil, Nil )
	cPortaAtu 	:=	getPvProfString( "TCP" 		, 'PORT' 	, '' , If(File(cRestIni),cRestIni	,cTafIni)	, Nil, Nil )

	cUrlWS := VldWS()

	// Workaroud do DbAccess
	//1o. Busca na Seção [DBAccess]
	cDBDataBase := GetPvProfString( "DBAccess", "DataBase"	,"ERRO"		,cIniFile )
	cDBServer 	:= GetPvProfString( "DBAccess", "Server"	,"ERRO"		,cIniFile )
	cDBAlias 	:= GetPvProfString( "DBAccess", "Alias"		,"ERRO"		,cIniFile )
	cDBPort 	:= GetPvProfString( "DBAccess", "Port"		,"ERRO"		,cIniFile )

	//2o. Busca na Seção [TopConnect]
	cDBDataBase := GetPvProfString( "TopConnect", "DataBase", cDBDataBase	, cIniFile )
	cDBServer 	:= GetPvProfString( "TopConnect", "Server"	, cDBServer		, cIniFile )
	cDBAlias 	:= GetPvProfString( "TopConnect", "Alias"	, cDBAlias		, cIniFile )
	cDBPort 	:= GetPvProfString( "TopConnect", "Port"	, cDBPort		, cIniFile )

	//3o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "DB"
	cDBDataBase := GetSrvProfString( "DBDataBase"	, cDBDataBase )
	cDBServer 	:= GetSrvProfString( "DBServer"		, cDBServer )
	cDBAlias 	:= GetSrvProfString( "DBAlias"		, cDBAlias )
	cDBPort 	:= GetSrvProfString( "DBPort"		, cDBPort )

	//4o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "Top"
	cDBDataBase := GetSrvProfString( "TopDataBase"	, cDBDataBase )
	cDBServer 	:= GetSrvProfString( "TopServer"	, cDBServer )
	cDBAlias 	:= GetSrvProfString( "TopAlias"		, cDBAlias )
	cDBPort 	:= GetSrvProfString( "TopPort"		, cDBPort )

	AADD( aMap, {"TAF"			,cTafIni	,cIp		,cPortaTAF	, ""						})
	AADD( aMap, {"WebServices"	,cRestIni	,cIp		,cPortaWS	, cUrlWS					})
	AADD( aMap, {"Atualizador"	,cAtuIni	,cIp		,cPortaAtu	, ""						})
	AADD( aMap, {"DbAccess"		,cDbIni		,cDBServer	,cDBPort	, cDBDataBase+"/"+cDBAlias	})

Return( aMap )

//-------------------------------------------------------------------
/*/{Protheus.doc} TaflistBox
Cria uma listbox generica
@author Roberto Souza
@since 16/01/2018
@version 1.0

@aParam

@return aMar - Objeto
/*/
//-------------------------------------------------------------------
Function TaflistBox( oFather , aCoord, aHeader, aColsList, aColSizes, bLine, BlDblClick, aButtons , cTitulo, cText01, cButt1)

	Local Nx 		:= 0
	Local oListBox	:= nil
	Local lAllClient:= .T.
	Local lDock     := oFather <> nil
	Local oArea		:= Nil
	Local oFont		:= Nil

	Default blDblClick 	:= ""
	Default bLine		:= ""
	Default aCoord		:= {}
	Default aColSizes	:= {}
	Default cTitulo		:= "Detalhes"
	Default cText01		:= "Resumo dos endereços e portas utilizadas na configuração do TAF."
	Default cButt1		:= "&Sair"

	// Se não mandar tamanho da tela, ajusta ao objeto pai
	If Empty( aCoord )
		aCoord 		:= {000,000,400,800}
		lAllClient 	:= .T.
	EndIf

	If lDock
		aWindow := {017,083}
		aColumn := {090,010}
		oList	:= oFather
	Else
		oFont		  	:= TFont():New("Arial",08,14,,.T.,,,,.T.)

		aWindow := {020,080}
		aColumn := {088,012}

		oArea := FWLayer():New()
		oFather := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
		oArea:Init(oFather,.F., .F. )

		oArea:AddLine("L01",095,.F.)

		oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados
		oArea:AddCollumn("L01C02",aColumn[02],.F.,"L01") //botoes

		oArea:AddWindow("L01C01","TEXT","Informações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")

		@ 002,002 SAY cText01 FONT oFont COLOR CLR_BLUE Pixel Of oText

		oArea:AddWindow("L01C01","LIST","Detalhes",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

		oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")
	EndIf

	If Empty(bLine)
		nTamCol := Len(aColsList[01])
		bLine 	:= "{|| {"
		For Nx := 1 To nTamCol
			bLine += "aColsList[oListBox:nAt]["+StrZero(Nx,3)+"]"
			If Nx < nTamCol
				bLine += ","
			EndIf
		Next
		bLine += "} }"
	EndIf

	oListBox := TWBrowse():New(0,0,100,100,,aHeader,,oList)
	oListBox:SetArray( aColsList )
	oListBox:bLine := &bLine

	If !Empty( BlDblClick )
		oListBox:BlDblClick := BlDblClick
	EndIf
	If !Empty( aColSizes )
		oListBox:aColSizes := aColSizes
	EndIf

	If lAllClient
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	oListBox:SetFocus()

	If !lDock
		oButt1 := tButton():New(000,000,cButt1				,oAreaBut,{|| oFather:End() }  		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
		oFather:Activate(,,,.T.,/*valid*/,,/*On Init*/)
	EndIf

Return( oListBox )

//--------------------------------------------------------------------
/*/{Protheus.doc} TafQryArr
Funcao para rodar uma Query e retornar como Array.

@author Roberto Souza
@since 16/02/2018
@version 1
@Parametros  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			 ºcQuery : Query SQL a ser executado                           º
             ºcTipo  : A=Array (Default) / V=Variavel (Par.N.Obrigat.)     º
             ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
@Retorno   aRet   - Array com o conteudo da Query
/*/
//--------------------------------------------------------------------
Function TafQryArr( cQuery, cTipo )

	Local aArea 	:= GetArea()
	Local aRet    	:= {}
	Local aRet1   	:= {}
	Local Nx       	:= 0

	Default cTipo := "A"

	TCQUERY (cQuery) NEW ALIAS 'QRY' 

	nRegs   := FCount()
	aRet1   := Array( nRegs )

	QRY->(DbGoTop())

	While QRY->(!Eof())
		For Nx := 1 To nRegs
			aRet1[Nx] := FieldGet(Nx)
		Next
		AADD(aRet, aclone(aRet1))
		QRY->(DbSkip())
	Enddo

	QRY->(DbCloseArea())

	If cTipo == "V" .And. Len(aRet)>0
		aRet := aRet[01][01]
	Elseif cTipo == "V"
		aRet := NIL
	Endif

	RestArea( aArea )

Return( aRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} xFunAltRec
Função responsavel por montar a tela de inserção do valor
do recibo de transmissão

@author fabio.santana
@since 07/05/2018
@version 1
@Parametros
@Retorno
/*/
//--------------------------------------------------------------------
Function xFunAltRec( cAlias )

	Local oWizard
	Local oRadio

	Local nLinha
	Local nColuna
	Local nAltLinha
	Local nLargLin
	Local nAt
	Local nRadio
	Local nRecno

	Local cValNovo
	Local cValAnt
	Local cString
	Local cStrRec
	Local cNomEve
	Local cPage1
	Local cPage2
	Local lRet
	Local lWebApp 	:= Iif(lFindClass, GetRemoteType() == REMOTE_HTML .or. (FWCSSTools():GetInterfaceCSSType() == 5), .F.)

	Local lContinua
	Local lTrab

	Local aSSTFunc	:= {"TAFA264", "TAFA258", "TAFA257"} 
	Local lSSTFunc	:= .F.
	Local nY		:= 0
	Local cCodEv  	:= ""
	Local lExec   	:= .F.

	Default cAlias := ""

	oWizard   := Nil
	oRadio    := Nil

	nLinha    := 0
	nColuna   := 0
	nAltLinha := 0
	nLargLin  := 270
	nAt       := 0
	nRadio    := 1
	nRecno    := 0

	cValAnt   := ""

	cString   := ""
	cStrRec   := ""
	cValNovo  := ""
	cNomEve   := ""
	cPage1    := ""
	cPage2    := ""

	lContinua := .T.
	lTrab     := .F.
	lRet      := .T.

	//-->> Tratamento feito para quando for chamado pelo Histórico do TAFA421.
	If FWIsInCallStack("XFUNNEWHIS") .Or. ( FWIsInCallStack("XNEWHISALT") .And. FWIsInCallStack("TAFA588") )

		If FWIsInCallStack("TAFA591") .Or. FWIsInCallStack("TAFA588") .Or. FWIsInCallStack("TAFA421") .Or. !FWIsInCallStack("FopenPnTrab")

			If Type("cAliasBen") <> "U"
				cAliasTrb := cAliasBen			
			ElseIf FWIsInCallStack("TAFA588")
				cAliasTrb := "V73"
				cCodEv := Substr(V73->V73_NOMEVE,1,1) + "-" + Substr(V73->V73_NOMEVE,2)
			EndIf

			If Type("cAliasTrb") <> "U"
				If Empty(cCodEv)	
					cCodEv := Substr((cAliasTrb)->(NOMEVE),1,1) + "-" + Substr((cAliasTrb)->(NOMEVE),2) 
				EndIf
				
				lExec := .T.

				If cCodEv $ 'S-2200|S-2300'
					
					cAlias := 'C9V'

				ElseIf cCodEv == 'S-2205'

					cAlias := 'T1U'

				ElseIf cCodEv == 'S-2206'

					cAlias := 'T1V'

				ElseIf cCodEv == 'S-2306'

					cAlias := 'T0F'
				
				ElseIf cCodEv == "S-2400" .Or. cCodEv == "S-2405"

					cAlias := "V73"
					nRecno := V73->(Recno())
				
				ElseIf cCodEv == "S-2410"

					cAlias := "V75"

				ElseIf cCodEv == "S-2416"

					cAlias := 'V76'

				ElseIf cCodEv == "S-2418"

					cAlias := 'V77'

				ElseIf cCodEv == "S-2420"

					cAlias := 'V78'

				EndIf

				If !cCodEv $ "S-2400|S-2405"

					nRecno := RECNO

				EndIf
				
				( cAlias )->( DBGoTo( nRecno ) )
				cValAnt 	:= AllTrim(&(cAlias + "->" + cAlias + "_PROTUL"))
				cValNovo	:= Iif(TafLayESoc("S_01_00_00"), Space(23), Space( TamSX3( cAlias + "_PROTUL" )[1] ))
				nRecno 		:= 0
			EndIf

		EndIf

	Else

		cValAnt		:= AllTrim(&(cAlias + "->" + cAlias + "_PROTUL"))

		For nY := 1 To Len(aSSTFunc)
			If !lSSTFunc
				lSSTFunc := FWIsInCallStack(aSSTFunc[nY])
			EndIf
		Next

		cValNovo := Iif(TafLayESoc("S_01_00_00") .OR. lSSTFunc, Space(23), Space( TamSX3( cAlias + "_PROTUL" )[1]))
		
	EndIf

	If !TAFAlsInDic( "V1V" ) // Valida se a tabela existe no dicionário
		cMsg := STR0169 //"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados UPDTAF."
		MsgInfo( cMsg, STR0170 ) // "Ambiente Desatualizado!"
		lRet := .F.
	EndIf

	//Somento um usuario do grupo administrador terá acesso a essa rotina
	If lRet //.And. FWIsAdmin( __cUserID )

		cPage1 := STR0158 + CRLF //"Nesse assistente, será possivel preencher o número do recibo de transmissão do registro posicionado." + CRLF + CRLF
		cPage1 += STR0159 + CRLF //"Os eventos somente serão alterados se estiverem com as seguintes caracteristicas:" + CRLF
		cPage1 += STR0161 + CRLF //" - Campo do ultimo protocolo EM BRANCO." + CRLF
		cPage1 += STR0162 + CRLF //" - O evento deve estar ATIVO." + CRLF

		cPage2 := STR0163 + CRLF // "<h3><b>A T E N Ç Ã O</b></h3>" + CRLF
		cPage2 += STR0164 + CRLF //"Essa alteração deverá ser feita com extremo cuidado, pois impacta diretamente no confronto das<br>" + CRLF
		cPage2 += STR0165 + CRLF //"informações entre o TAF e a base de dados Governo.<br><br>" + CRLF
		cPage2 += STR0166 + CRLF //"O recibo de transmissão correto, pode ser consultado junto ao RET, e é imprescindível<br>" + CRLF
		cPage2 += STR0167 + CRLF //"que esta consulta seja realizada antes de qualquer alteração.<br><br>" + CRLF
		cPage2 += STR0168 + CRLF //"Após uma vez preenchido, este recibo de transmissão não poderá ser substituído.<br>"

		If cAlias $ "C9V|V73|V75"

			If &(cAlias + "->" + cAlias + "_ATIVO") <> '1'
				msgalert(STR0146 + CRLF + CRLF + STR0144,STR0008) //'O registro posicionado encontra-se inativo!'
				lContinua := .F.
			EndIf

			cNomEve := &(cAlias + "->" + cAlias + "_NOMEVE")

		EndIf

		If (cAlias $ 'C9V|V75|V73' .And. !lExec)
			//TRATAMENTO PARA EVITAR ERROS NO EVENTO S-2200;
			If lContinua

				Define WIZARD oWizard;
					TITLE STR0150;
					HEADER 'T A F';
					MESSAGE "TOTVS Automação Fiscal";
					TEXT cPage1;
					NEXT { || .T. };
					FINISH { || .T. };
					NOTESC


				CREATE PANEL oWizard;
					HEADER "TOTVS Automação Fiscal";
					MESSAGE STR0149; //Preencha corretamente as informações solicitadas.
					BACK { || .T. };
					NEXT { ||  xFunVldOpc(nRadio,cNomEve, @cAlias, @nRecno) };
					FINISH {||.T.}

				nLinha		:=	15
				nColuna		:=	10
				nAltLinha	:=	10
				oPnl1		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 2 ],, .F., .F.,,, nLargLin, 135, .T., .F. )

				nLinha := nAltLinha
				TSay():New( nLinha, nColuna, { || STR0157 }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin*7, nAltLinha*7,,,,,,.T. ) //'Selecione o evento que deseja alterar:'

				nLinha		+=	15
				If cNomEve == "S2200"
					oRadio 	:= tRadMenu():New(nLinha,nColuna,{STR0154,STR0155,STR0156},{|u|IIf(PCount() == 0,nRadio,nRadio := u)},oPnl1,,,,,,,,nLargLin,nAltLinha,,,,.T.)
				ElseIf cNomEve == "S2400"
					oRadio 	:= tRadMenu():New(nLinha,nColuna,{STR0215,STR0216},{|u|IIf(PCount() == 0,nRadio,nRadio := u)},oPnl1,,,,,,,,nLargLin,nAltLinha,,,,.T.)
				ElseIf cNomEve == "S2410"
					oRadio 	:= tRadMenu():New(nLinha,nColuna,{"2410 - Benefício - Início ","2416 - Benefício - Alteração","2418 - Reativação de Benefício", "2420 - Benefício - Término",},{|u|IIf(PCount() == 0,nRadio,nRadio := u)},oPnl1,,,,,,,,nLargLin,nAltLinha,,,,.T.)
				Else
					oRadio 	:= tRadMenu():New(nLinha,nColuna,{STR0152,STR0155,STR0153},{|u|IIf(PCount() == 0,nRadio,nRadio := u)},oPnl1,,,,,,,,nLargLin,nAltLinha,,,,.T.)
				EndIf

				CREATE PANEL oWizard;
				HEADER "TOTVS Automação Fiscal";
				MESSAGE STR0149;
				BACK { || .T. };
				NEXT { || .T.};
				FINISH {||xFunRecAlt(cValNovo, cAlias, nRecno)}

				nLinha		:=	IIF(lWebApp,2,15)
				nColuna		:=	10
				nAltLinha	:=	10
				oPnl2		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 3 ],, .F., .F.,,, 290, 140, .F., .F. )

				TSay():New( nLinha, nColuna, { || cPage2 }, oPnl2,,,,,, .T., ,, nLargLin*7, nAltLinha*IIF(lWebApp,10,7),,,,,,.T. )

				nLinha := nAltLinha * 10

				TSay():New( nLinha, nColuna, { || STR0148 }, oPnl2,,,,,, .T., ,, nLargLin, nAltLinha*2,,,,,,.T. )

				nLinha	+=	nAltLinha*2
				TGet():New( nLinha, nColuna, {|u| if( PCount()>0, cValNovo:=u, cValNovo )}, oPnl2, nLargLin-10, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cValNovo,,,, )

				Activate WIZARD oWizard Centered

			EndIf
		Else

			If !(Empty(AllTrim(cValAnt)))
				msgalert(STR0145 + CRLF + STR0144 + CRLF + CRLF + cValAnt + CRLF,STR0008)
				lContinua := .F.
			Else
				if !&(cAlias + "->" + cAlias + "_STATUS") $ '| |0|1|3|4|'

					If &(cAlias + "->" + cAlias + "_STATUS") $ '2'
						msgalert( "Registro já transmitido ao Governo, aguardando retorno.", "Aguardando retorno" )
						lContinua := .F.
					elseIf &(cAlias + "->" + cAlias + "_STATUS") $ '6'
						msgalert( "Exclusão transmitida ao Governo, aguardando retorno.", "Aguardando retorno" )
						lContinua := .F.
					else
						msgalert( "Exclusão transmitida ao Governo com retorno consistente.", "Com retorno consistente" )
						lContinua := .F.
					EndiF
				EndIf
			Endif

			If lContinua

				Define WIZARD oWizard;
					TITLE STR0150; //'Assistente de atualização do Número do Recibo de transmissão'
					HEADER 'T A F';
					MESSAGE "TOTVS Automação Fiscal";
					TEXT cPage1;
					NEXT { || .T. };
					FINISH { || .T. };
					NOTESC

				CREATE PANEL oWizard;
					HEADER "TOTVS Automação Fiscal";
					MESSAGE STR0149;
					BACK { || .T. };
					NEXT { || .T.};
					FINISH {||xFunRecAlt(cValNovo,cAlias)}

				nLinha		:=	IIF(lWebApp,2,15)
				nColuna		:=	10
				nAltLinha	:=	10
				oPnl1		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 2 ],, .F., .F.,,, 290, 140, .F., .F. )

				TSay():New( nLinha, nColuna, { || cPage2 }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin*7, nAltLinha*IIF(lWebApp,10,7),,,,,,.T. )

				nLinha := nAltLinha * 10

				TSay():New( nLinha, nColuna, { || STR0148 }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha*2,,,,,,.T. )

				nLinha	+=	nAltLinha*1.5
				TGet():New( nLinha, nColuna, {|u| if( PCount()>0, cValNovo:=u, cValNovo )}, oPnl1, nLargLin-10, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cValNovo,,,, )

				Activate WIZARD oWizard Centered

			EndIF
		EndIf
	ElseIf !FWIsAdmin( __cUserID )
		msgalert(STR0147,STR0008) //'Para realizar esta ação, o usuário deve pertencer ao grupo de Administradores do sistema.'
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} xFunVldOpc
Valida as informações do campo de protocolo antes de altera-lo
@author fabio.santana
@since 10/05/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Function xFunVldOpc(nRadio, cNomEve, cAlias, nRecno)

	Local lRet 		:= .T.
	Local cChvTrab  := C9V->C9V_ID + '1'
	Local cValAnt	:= ""
	Local cFilBkp   := cFilAnt

	Default nRadio  := 0
	Default cNomEve := ""
	Default cAlias  := ""

	If FWAliasInDic('V75')
		cChvTrab := Iif( cNomEve $ "S2410|S2416|S2418|S2420|", V75->V75_ID + "1", cChvTrab )
		cFilAnt  := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)
	EndIf

	If cNomEve == "S2200"

		If nRadio == 1

			//Verifica se o evento S2200 possui protocolo
			//Altero o alias e o recno de acordo com a seleção
			cAlias := 'C9V'
			nRecno := C9V->( Recno() )

		ElseIf nRadio == 2

			//Verifica se o evento S2205 possui protocolo
			If RetUltAtivo('T1U',cChvTrab,2)
				//Altero o alias e o recno de acordo com a seleção
				cAlias := 'T1U'
				nRecno := T1U->( Recno() )
			Else
				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
			EndIf

		ElseIf nRadio == 3

			//Verifica se o evento S2206 possui protocolo
			If RetUltAtivo('T1V',cChvTrab,2)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := 'T1V'
				nRecno := T1V->( Recno() )
			Else
				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
			EndIf
		EndIf

	ElseIf cNomEve == 'S2300'

		If nRadio == 1

			//Altero o alias e o recno de acordo com a seleção
			cAlias := 'C9V'
			nRecno := C9V->( Recno() )

		ElseIf nRadio == 2

			//Verifica se o evento S2205 possui protocolo
			If RetUltAtivo('T1U',cChvTrab,2)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := 'T1U'
				nRecno := T1U->( Recno() )

			Else
				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
			EndIf

		Elseif nRadio == 3

			//Verifica se o evento S2306 possui protocolo
			If RetUltAtivo('T0F',cChvTrab,2)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := 'T0F'
				nRecno := T0F->( Recno() )
			Else
				msgAlert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
			EndIf
		EndIf
		
	ElseIf cNomEve == "S2410"

		If nRadio == 1

			//Altero o alias e o recno de acordo com a seleção
			cAlias := "V75"
			nRecno := V75->( Recno() )

		ElseIf nRadio == 2

			//Verifica se o evento S2416 possui protocolo
			If RetUltAtv("V76", cChvTrab, 1)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := "V76"
				nRecno := V76->( Recno() )

			Else

				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.

			EndIf

		ElseIf nRadio == 3

			//Verifica se o evento S2418 possui protocolo
			If RetUltAtv("V77", cChvTrab, 1)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := "V77"
				nRecno := V77->( Recno() )

			Else

				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
				
			EndIf

		ElseIf nRadio == 4

			//Verifica se o evento S2420 possui protocolo
			If RetUltAtv("V78", cChvTrab, 1)

				//Altero o alias e o recno de acordo com a seleção
				cAlias := "V78"
				nRecno := V78->( Recno() )

			Else

				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
				
			EndIf

		EndIf

	EndIf

	If cNomEve == 'S2400'
		If nRadio == 1

			//Altero o alias e o recno de acordo com a seleção
			cAlias := 'V73'
			nRecno := V73->( Recno() )

		ElseIf nRadio == 2

			//Verifica se o evento S2405 possui protocolo
			If ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.T.,"'4','0','1',' '")

				//Altero o alias e o recno de acordo com a seleção
				cAlias := 'V73'
				nRecno := V73->( Recno() )

			Else
				msgalert(STR0142 + CRLF + CRLF + STR0144,STR0008)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet

		cValAnt := &(cAlias + "->" + cAlias + "_PROTUL")

		If !(Empty(AllTrim(cValAnt)))
			msgalert(STR0145 + CRLF + STR0144 + CRLF + CRLF + cValAnt + CRLF,STR0008)
			lRet := .F.

		Else

			If !&(cAlias + "->" + cAlias + "_STATUS") $ '| |0|1|3|4|'

				If &(cAlias + "->" + cAlias + "_STATUS") $ '2'
					msgalert( "Registro já transmitido ao Governo, aguardando retorno.", "Aguardando retorno" )
					lRet := .F.
				ElseIf &(cAlias + "->" + cAlias + "_STATUS") $ '6'
					msgalert( "Exclusão transmitida ao Governo, aguardando retorno.", "Aguardando retorno" )
					lRet := .F.
				Else
					msgalert( "Exclusão transmitida ao Governo com retorno consistente.", "Com retorno consistente" )
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	cFilAnt := cFilBkp

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} xFunRecAlt
Valida as informações do campo de protocolo antes de altera-lo
@author fabio.santana
@since 07/05/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Function xFunRecAlt(cValNovo, cAlias, nRecno )

	Local lRet := .T.

	Default cValNovo  := ""
	Default cAlias	  := ""
	Default	nRecno	  := 0

	//Gravar o protocolo na tabela
	If lRet
		xFunGrvRec(cAlias, cValNovo, .F., nRecno)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafGrvRec
Funcao que grava o numero do protocolo
informado manualmente ou via schedule

@author Fabio Santana
@since 08/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunGrvRec(cAlias, cValNovo, lJob, nRecno)

	Local cFilReg
	Local cChave
	Local aArea

	Default cAlias		:= ""
	Default cValNovo  	:= ""
	Default	lJob	    := .F.
	Default nRecno 		:= 0

	cFilReg	 := ""
	cChave	 := ""

	aArea := (cAlias)->(GetArea())

	//Se for passado o RECNO, posiciono no registro, senao, considero que ja esteja posicionado.
	If nRecno > 0
		DbSelectArea(cAlias)
		(cAlias)->(DbGoTo(nRecno))
	EndIf

	DbSelectArea(cAlias)
	RecLock( cAlias , .F.)

	//Gravo o protocolo com o numero passado
	&(cAlias + "->" + cAlias + "_PROTUL") := cValNovo
	&(cAlias + "->" + cAlias + "_STATUS") := '4'

	If ( "7" $ GetSx3Cache( cAlias + "_LOGOPE", "X3_CBOX" )) .Or. ( "CbLogOpe" $ GetSx3Cache( cAlias + "_LOGOPE", "X3_CBOX" ))
		If !lJob
			&(cAlias + "->" + cAlias + "_LOGOPE") := '7' //7-Inclusão Manual do Recibo
		EndIf
	EndIf

	// Tratamento quando for evento excluído que não gera S-3000
	If &(cAlias + "->" + cAlias + "_EVENTO") == "E"
		&(cAlias + "->" + cAlias + "_ATIVO") := '2'
	EndIf

	MsUnlock()

	cFilReg :=  &(cAlias + "->" + cAlias + "_FILIAL")
	cChave  :=  &(cAlias + "->" + cAlias + "_ID")  +  &(cAlias + "->" + cAlias + "_VERSAO")

	If !lJob
		//Grava o log de alteração do protocolo
		xFunLogRec(cFilReg, cAlias, cChave, cValNovo )
	EndIf

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunLogRec
Funçao que grava o log de alteração manual do recibo de transmissão

@Param
cFilialLog   - Filial posicionada
cTabela      - Tabela posicionada
cChave       - Chave de Negócio
cValAtual    - Valor depois da atualização

@author Ronaldo Tapia
@since 08/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFunLogRec(cFilialLog, cTabela, cChave, cValAtual )

	Local cId          	:= TAFGeraID( "TAF" )
	Local dData       	:= ""
	Local cHora       	:= ""
	Local cUserName   	:= ""
	Local cIp         	:= ""

	Default cFilialLog 	:= xFilial( "V1V" )
	Default cTabela     := ""
	Default cChave      := ""
	Default cValAtual  	:= ""

	// Encripta os dados
	dData      := &("rc4crypt( DTOS(dDataBase) ,cValToChar(123456789), .T.)")
	cHora      := &("rc4crypt( Time() ,cValToChar(123456789), .T.)")
	cUserName  := &("rc4crypt( __cUserID ,cValToChar(123456789), .T.)")
	cIp        := &("rc4crypt( getServerIP() , cValToChar(123456789), .T.)")

	// Grava tabela de Log
	If RecLock( "V1V", .T. )
		V1V->V1V_FILIAL         := cFilialLog
		V1V->V1V_ID             := cId
		V1V->V1V_TABELA         := cTabela
		V1V->V1V_CHAVE          := cChave
		V1V->V1V_CHECK1         := dData
		V1V->V1V_CHECK2         := cHora
		V1V->V1V_CHECK3         := cUserName
		V1V->V1V_CHECK4         := cIp
		V1V->V1V_VATUAL         := cValAtual
		V1V->( MsUnlock() )
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TafGetInfo
Funçao que grava o log de alteração manual do recibo de transmissão

@Param
	aParam[01]   - Evento para filtro
	aParam[02]   - Filial para filtro
	aParam[03]   - ID para filtro

Retorno aRet
@author Roberto Souza
@since 07/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafGetInfo( aParam )

	Local aRet
	Local cAliasGet
	Local cAliasSec
	Local lAut
	Local cProtPN

	Default aParam := {"","",""}

	aRet 		:= {}
	lAut		:= .F.

	If aParam[01] == "S-2230"
		cAliasGet	:= GetNextAliea()
		BeginSql ALIAS cAliasGet
			SELECT CM6.R_E_C_N_O_ CM6_RECNO FROM %Table:CM6% CM6

			WHERE CM6.%NotDel%
			AND CM6_FILIAL = %Exp:aParam[02]%
			AND CM6_ID = %Exp:aParam[03]%
			AND CM6_ATIVO = '1'
		EndSql
		DbSelectArea(cAliasGet)
		While (cAliasGet)->(!Eof())
			DbSelectArea("CM6")
			DbGoTo( (cAliasGet)->CM6_RECNO )
			AADD( aRet,{ ;
				CM6->CM6_FILIAL ,;
				CM6->CM6_ID 	,;
				CM6->CM6_VERSAO ,;
				CM6->CM6_FUNC 	,;
				CM6->CM6_DTAFAS ,;
				CM6->CM6_MOTVAF ,;
				CM6->CM6_TPACID ,;
				CM6->CM6_OBSERV ,;
				CM6->CM6_CODCID ,;
				CM6->CM6_DIASAF ,;
				CM6->CM6_IDPROF ,;
				CM6->CM6_CNPJCE ,;
				CM6->CM6_INFOCE ,;
				CM6->CM6_CNPJSD ,;
				CM6->CM6_INFOSD ,;
				CM6->CM6_VERANT ,;
				CM6->CM6_STATUS ,;
				CM6->CM6_PROTUL ,;
				CM6->CM6_PROTPN ,;
				CM6->CM6_EVENTO ,;
				CM6->CM6_ATIVO 	,;
				CM6->CM6_ADTAFA ,;
				CM6->CM6_AMOTAF ,;
				CM6->CM6_EFRETR ,;
				CM6->CM6_DTFAFA ,;
				CM6->CM6_FMOTAF  ;
				} )
			(cAliasGet)->(DbSkip())
			lAut 	:= ( CM6->CM6_STATUS == "4" )
			cProtPN	:= CM6->CM6_PROTPN
		EndDo


		If !lAut .And. !Empty( cProtPN )
			cAliasSec	:= GetNextAlias()
			BeginSql ALIAS cAliasSec
				SELECT CM6.R_E_C_N_O_ CM6_RECNO FROM %Table:CM6% CM6

				WHERE CM6.%NotDel%
				AND CM6_FILIAL = %Exp:aParam[02]%
				AND CM6_ID = %Exp:aParam[03]%
				AND CM6_ATIVO = '2'
				AND CM6_PROTUL = %Exp:cProtPN%
			EndSql
			DbSelectArea(cAliasSec)
			While (cAliasSec)->(!Eof())
				DbSelectArea("CM6")
				DbGoTo( (cAliasSec)->CM6_RECNO )
				AADD( aRet,{ ;
					CM6->CM6_FILIAL ,;
					CM6->CM6_ID 	,;
					CM6->CM6_VERSAO ,;
					CM6->CM6_FUNC 	,;
					CM6->CM6_DTAFAS ,;
					CM6->CM6_MOTVAF ,;
					CM6->CM6_TPACID ,;
					CM6->CM6_OBSERV ,;
					CM6->CM6_CODCID ,;
					CM6->CM6_DIASAF ,;
					CM6->CM6_IDPROF ,;
					CM6->CM6_CNPJCE ,;
					CM6->CM6_INFOCE ,;
					CM6->CM6_CNPJSD ,;
					CM6->CM6_INFOSD ,;
					CM6->CM6_VERANT ,;
					CM6->CM6_STATUS ,;
					CM6->CM6_PROTUL ,;
					CM6->CM6_PROTPN ,;
					CM6->CM6_EVENTO ,;
					CM6->CM6_ATIVO 	,;
					CM6->CM6_ADTAFA ,;
					CM6->CM6_AMOTAF ,;
					CM6->CM6_EFRETR ,;
					CM6->CM6_DTFAFA ,;
					CM6->CM6_FMOTAF  ;
					} )
				(cAliasSec)->(DbSkip())
			EndDo
		EndIf

	EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAltMan
Rotina para gravação do campo padrao XXX_LOGOPE, tanto na saveModel/Grv
1 - Incluído Integração
2 - Incluído Manual
3 - Incluído Integração + Editado Integração
4 - Incluído Integração + Editado Manual
5 - Incluído Manual + Editado Integração
6 - Incluído Manual + Editado Manual
@type function

@author Denis Souza / Wesley Pinheiro
@since 06/07/2018
@version 1.0

@Param nOper - numérico - Operação 3 Inclusão 4 Alteração
@Param cFunc - caracter - Função
@Param oModel - Objeto - Modelo
@Param cModel - caracter - Modelo
@Param cCampo - caracter - Campo
@Param cStatus - caracter - Status
@Param cAltManAnt - caracter - XXX_LOGOPE anterior

@return Nil
/*/
//-------------------------------------------------------------------
Function TafAltMan( nOper , cFunc , oModel , cModel , cCampo , cStatus , cAltManAnt  )

	Local 	aArea
	Default cAltManAnt 	:= ""
	Default cStatus 	:= ""

	aArea := GetArea()

	If TafColumnPos( cCampo )
		if cFunc == 'Save' //SaveModel
			if nOper == 3
				oModel:LoadValue( cModel, cCampo , cStatus )
			endif
			if nOper == 4
				if cAltManAnt $ '1|3|4'
					oModel:LoadValue( cModel, cCampo, '4' )
				Elseif cAltManAnt $ '2|5|6'
					oModel:LoadValue( cModel, cCampo, '6' )
				ElseIf cAltManAnt == '7'
					oModel:LoadValue( cModel, cCampo, '2' )
				ElseIf Empty( cAltManAnt )
					If cModel == "MODEL_C1E"
						oModel:LoadValue( cModel, cCampo, '6' )
					EndIf
				endif
			endif
		elseif cFunc == 'Grv' //Importacao
			if nOper == 3
				oModel:LoadValue( cModel, cCampo , cStatus )
			endif
			if nOper == 4
				if cAltManAnt $ '1|3|4'
					oModel:LoadValue( cModel, cCampo, '3' )
				Elseif cAltManAnt $ '2|5|6'
					oModel:LoadValue( cModel, cCampo, '5' )
				ElseIf cAltManAnt == '7'
					oModel:LoadValue( cModel, cCampo, '1' )
				ElseIf Empty( cAltManAnt )
					If IsInCallStack( "TAF050GRV" )
						oModel:LoadValue( cModel, cCampo, '5' )
					EndIf
				endif
			endif
		EndiF
	else
		aviso := STR0172 + AllTrim(cCampo) + STR0173  //#"O Campo " #" não consta no dicinário de dados. Não será possível utilizar o rotina de tracker."
		if IsBlind()
			MsgInfo(aviso)
		else
			TAFConOut(aviso)
		endif
	EndIf

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIdFunc
Posiciona no ID do funcionário
@author  Diego R. dos Santos
@since   29/06/2018
@version 1
/*/
//-------------------------------------------------------------------

Function TAFGetIdFunc(cCPF, cPerApu, dDtEspec, cFieldLay1, cInfo1, aInfComp, cMatric, cIDCateg,lIdChave,cFieldLay2,cInfo2,cFieldLay3,cInfo3,cFieldLay4,cInfo4,cInconMsg,nSeqErrGrv,lAtributo,lEmpty,cEvento)

	Local cId          := ""
	Local cAlsIdTrb    := GetNextAlias()
	Local cQryIdTrb    := ""
	Local dFrtDt       := CtoD("01/" + SubStr(cPerApu,6,2) + "/" + SubStr(cPerApu,1,4))
	Local aDiff
	Local cBanco       := AllTrim(Upper(TcGetDb()))
	Local cDataAdm     := ""

	Default cFieldLay1 := "cpfBenef"
	Default cInfo1     := "/eSocial/evtPgtos/ideBenef/cpfBenef"
	Default cMatric    := Nil
	Default cIDCateg   := ""
	Default cInfo2     := ""
	Default cInfo3     := ""
	Default cInfo4     := ""
	Default cFieldLay2 := ""
	Default cFieldLay3 := ""
	Default cFieldLay4 := ""
	Default lIdChave   := .T.
	Default lEmpty     := .F.
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default lAtributo  := .F.
	Default cEvento	   := ""

	If getQtdVinculos(cCPF) > 1

		cQryIdTrb := "SELECT C9V.C9V_NOMEVE" + CRLF
		cQryIdTrb += "	,C9V.C9V_FILIAL" + CRLF
		cQryIdTrb += "	,C9V.C9V_ID" + CRLF
		cQryIdTrb += "	,C9V.C9V_VERSAO" + CRLF
		cQryIdTrb += "	,C9V.C9V_ATIVO" + CRLF
		cQryIdTrb += "	,C9V.C9V_STATUS" + CRLF
		cQryIdTrb += "	,C9V.C9V_PROTUL" + CRLF
		cQryIdTrb += "	,CUP.CUP_DTADMI" + CRLF
		cQryIdTrb += "  ,C9V.C9V_DTINIV" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN CMD.CMD_DTDESL" + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2300')" + CRLF
		cQryIdTrb += "			THEN T92.T92_DTERAV" + CRLF
		cQryIdTrb += "		END DTDESL" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN CMD.CMD_ATIVO" + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2300')" + CRLF
		cQryIdTrb += "			THEN T92.T92_ATIVO" + CRLF
		cQryIdTrb += "		END ATIVO" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN CMD.CMD_STATUS" + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2300')" + CRLF
		cQryIdTrb += "			THEN T92.T92_STATUS" + CRLF
		cQryIdTrb += "		END ATIVO" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN CMD.CMD_PROTUL" + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2300')" + CRLF
		cQryIdTrb += "			THEN T92.T92_PROTUL" + CRLF
		cQryIdTrb += "		END PROTUL" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN C9V.C9V_IDTRAN" + CRLF
		cQryIdTrb += "		END IDTRAN" + CRLF
		cQryIdTrb += "	,CASE " + CRLF
		cQryIdTrb += "		WHEN (C9V.C9V_NOMEVE = 'S2200')" + CRLF
		cQryIdTrb += "			THEN C9V.C9V_DTTRAN" + CRLF
		cQryIdTrb += "		END DTTRAN" + CRLF
		cQryIdTrb += " FROM " + RetSQLName("C9V") + " C9V" + CRLF
		cQryIdTrb += " LEFT JOIN " + RetSQLName("CUP") + " CUP ON C9V.C9V_FILIAL = CUP.CUP_FILIAL" + CRLF
		cQryIdTrb += "	AND C9V.C9V_ID = CUP.CUP_ID" + CRLF
		cQryIdTrb += "	AND C9V.C9V_VERSAO = CUP.CUP_VERSAO" + CRLF
		cQryIdTrb += "	AND C9V.C9V_NOMEVE = CUP.CUP_NOMEVE" + CRLF
		cQryIdTrb += "	AND C9V.D_E_L_E_T_ = CUP.D_E_L_E_T_" + CRLF
		cQryIdTrb += " LEFT JOIN " + RetSQLName("CMD") + " CMD ON C9V.C9V_FILIAL = CMD.CMD_FILIAL" + CRLF
		cQryIdTrb += "	AND C9V.C9V_ID = CMD.CMD_FUNC" + CRLF
		cQryIdTrb += "	AND CMD.CMD_ATIVO = '1'" + CRLF
		cQryIdTrb += "	AND CMD.CMD_STATUS = '4'" + CRLF
		cQryIdTrb += "	AND C9V.D_E_L_E_T_ = CMD.D_E_L_E_T_" + CRLF
		cQryIdTrb += " LEFT JOIN " + RetSQLName("T92") + " T92 ON C9V.C9V_FILIAL = T92.T92_FILIAL" + CRLF
		cQryIdTrb += "	AND C9V.C9V_ID = T92.T92_TRABAL" + CRLF
		cQryIdTrb += "	AND T92.T92_ATIVO = '1'" + CRLF
		cQryIdTrb += "	AND T92.T92_STATUS = '4'" + CRLF
		cQryIdTrb += "	AND C9V.D_E_L_E_T_ = T92.D_E_L_E_T_" + CRLF
		cQryIdTrb +=" WHERE C9V.C9V_CPF = '" + cCPF + "'" + CRLF
		cQryIdTrb += "	AND C9V.D_E_L_E_T_ <> '*'" + CRLF
		cQryIdTrb += "	AND C9V.C9V_ATIVO = '1'" + CRLF
		cQryIdTrb += "	AND C9V.C9V_NOMEVE <> 'TAUTO'" + CRLF
		cQryIdTrb += "  AND C9V.C9V_FILIAL = '" + xFilial("C9V") + "'" + CRLF

		If ValType(cMatric) <> "U"
			If Len(cMatric) > 0
				cQryIdTrb += " AND C9V.C9V_MATRIC = '" + cMatric + "'" + CRLF
			Else
				If Len(cMatric) == 0
					cQryIdTrb += " AND C9V.C9V_MATRIC = ''" + CRLF
				EndIf
			EndIf
		EndIf

		If !Empty(cIDCateg)
			cQryIdTrb += "  AND C9V.C9V_CATCI = '" + cIDCateg + "'"
		EndIf

		cQryIdTrb += "	ORDER BY CMD.CMD_DTDESL DESC" + CRLF

		If cBanco $ "ORACLE"
			cQryIdTrb := ChangeQuery(cQryIdTrb)
		EndIf

		TCQuery cQryIdTrb New Alias (cAlsIdTrb)

		(cAlsIdTrb)->(dbGoTop())

		If (cAlsIdTrb)->(!Eof())

			While (cAlsIdTrb)->(!Eof())

				aDiff := {}

				If (cAlsIdTrb)->C9V_NOMEVE == "S2200"
					cDataAdm := (cAlsIdTrb)->CUP_DTADMI
				Else
					cDataAdm := (cAlsIdTrb)->C9V_DTINIV
				EndIf

				If VldPeriodo( cPerApu, SToD(cDataAdm), StoD((cAlsIdTrb)->DTDESL)) .AND. Empty((cAlsIdTrb)->DTTRAN)
					cId := (cAlsIdTrb)->C9V_ID
				EndIf

				// Busco ID do trabalhador para Folha de Pagamento retroativa de funcionário transferido de filial
				If !Empty((cAlsIdTrb)->DTTRAN) .And. StrTran(cPerApu,"-","") <= SubStr((cAlsIdTrb)->DTTRAN, 1, 6) .AND. !(cEvento $ "S2205")
					cId := (cAlsIdTrb)->C9V_ID
					Exit
				EndIf

				If !(Empty((cAlsIdTrb)->DTDESL))
					If !VldDtC9V((cAlsIdTrb)->C9V_FILIAL,cCPF,(cAlsIdTrb)->DTDESL)
						aDiff := DateDiffYMD(Iif(ValType(dDtEspec) == "D", dDtEspec, dFrtDt), StoD((cAlsIdTrb)->DTDESL))

						If Len(aDiff) > 0
							If ( aDiff[2] == 0 .Or. aDiff[2] == 1 ) .And. ( aDiff[1] == 0 ) .And. (aDiff[3] <= 30) .And. STOD((cAlsIdTrb)->DTDESL) < dFrtDt 
								cId := (cAlsIdTrb)->C9V_ID
								Exit
							ElseIf ( aDiff[2] == 0 .Or. (aDiff[2] > 1 .and. aDiff[2] <= 11)) .And. ( aDiff[1] == 0 ) .And. STOD((cAlsIdTrb)->DTDESL) < dFrtDt .and. FwIsInCallStack("TAF407GRV")
								cId := (cAlsIdTrb)->C9V_ID
								Exit
							EndIf
						EndIf
					EndIf
				Endif
				
				(cAlsIdTrb)->(DbSkip())
			EndDo

		EndIf

		(cAlsIdTrb)->(DbCloseArea())
	EndIf

	If Empty(cId)
		cId := FGetIdInt( cFieldLay1, cFieldLay2,cInfo1,cInfo2,lIdChave,aInfComp,@cInconMsg,nSeqErrGrv,cFieldLay3,cInfo3,lEmpty,cFieldLay4,cInfo4,cPerApu,lAtributo,,cEvento )
	EndIf

Return cId

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdVinculos
Retorna a quantidade de vinculos ativos do funcionario.

Esta função foi criada para que a função TAFGetIdFunc seja executada
somente para os funcionários que possuem + de um vinculo dentro da 
filial, caso contrario deve-se utilizar a função FGetIdInt.

@param cCPF - Cpf do funcionario

@author Evandro dos Santos Oliveira	
@since 14/08/2018
@version 1.0

@return nQuantidade - Quantidade de Vinculos
/*/
//-------------------------------------------------------------------
Static Function getQtdVinculos(cCPF)

	Local nQuantidade := 0
	Local cSql := ""

	cSql := " SELECT COUNT(*) QTD "
	cSql += " FROM " + RetSqlName("C9V")
	cSql += " WHERE C9V_FILIAL = '" + xFilial("C9V") + "' "
	cSql += " AND C9V_CPF = '" + cCPF + "'"
	cSql += " AND C9V_ATIVO = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	TCQuery cSql New Alias 'rsId'

	nQuantidade := rsId->QTD

	rsId->(dbCloseArea())

Return nQuantidade

//-------------------------------------------------------------------
/*/{Protheus.doc} VProdRural
Rotina para verificação se a filial é produtor rural através do
campo de CPF preenchido.

@type function

@author Ricardo
@since 14/08/2018
@version 1.0

@return cRet
/*/
//-------------------------------------------------------------------
Function VProdRural(aFilsCalc, lChkUser, cGetIdEnt)

	Local cCpfPR		:= ''
	Local lRet  		:= .F.	
	Local lIsBlind		:= IsBlind()
	Local nY			:= 0
	Local aArea 		:= {}
	Local aSM0      	:= {}
	Local aReturn		:= {}
	Local cListFontes   := "TAFMONTES|TAFAWIZD|TAFAWIZDCPF|TAFR120|TAFR121|TAFR122|TAFR124|TAFEXCESOCIAL|TAFREAVALIATOTALIZADORES"

	Default aFilsCalc	:= {}
	Default lChkUser	:= .T.
	Default cGetIdEnt   := ""
	//-------------------------------------------------------
	//³ Verfica se a Filial logada é Produtor Rural
	//-------------------------------------------------------

	aArea := SM0->(GetArea())

	DBSelectArea("C1E")
	C1E->( DBSetOrder( 7 ) )

	If C1E->( MsSeek( xFilial( "C1E" ) + PadR( cEmpAnt + cFilAnt, TamSx3( "C1E_CODFIL" )[1]) + "1" ) )

		cCpfPR	:= C1E->C1E_NRCPF

		// Varre a C1E, verificando se existe outras Filiais que sejam Produtor Rural e tenha o mesmo CPF.
		If !Empty(cCpfPR)
			C1E->(dbGoTop())
			While !C1E->(Eof())
				
				If C1E->C1E_NRCPF == cCpfPR .AND. C1E->C1E_ATIVO == "1"

					If Len(aSM0) == 0
						aSM0 := FWLoadSM0(.T.,,.T.)
					EndIf

					//Busca no Array se há inconsistencias de acessos da Empresa/Usuario
					nY	:= aScan( aSM0, { |x,y|  Alltrim( x[1]+x[2] ) == Alltrim( C1E->C1E_CODFIL ) } )

					//---------------------------------------------------
					// Desconsidera Grupo de Empresa diferente do logado
					//---------------------------------------------------
					If aSM0[nY][SM0_GRPEMP] != cEmpAnt
						dbSelectArea("C1E")
						C1E->(dbSkip())
						Loop
					EndIf

					//-------------------------------------
					// Desconsidera Empresa nao autorizada
					//-------------------------------------
					If !lIsBlind .And. !aSM0[nY][SM0_EMPOK]
						dbSelectArea("C1E")
						C1E->(dbSkip())
						Loop
					EndIf

					//---------------------------------------------------
					// Desconsidera Filiais que o usuario nao tem acesso
					//---------------------------------------------------
					If lChkUser .And. !lIsBlind .And. !aSM0[nY][SM0_USEROK]
						dbSelectArea("C1E")
						C1E->(dbSkip())
						Loop
					EndIf
				
					//----------------------------------------------------------
					// Posiciona na SM0 para obter os campos M0_INSC e M0_INSCM
					//----------------------------------------------------------
				SM0->(DBGoTo(aSM0[nY][SM0_RECNO]))

					AAdd( aFilsCalc, {.F., aSM0[nY][SM0_CODFIL], aSM0[nY][SM0_NOMRED], aSM0[nY][SM0_CGC], SM0->M0_INSC, SM0->M0_INSCM, SM0->M0_CODIGO} )

					lRet	:= .T.
				EndIf
				dbSelectArea("C1E")
				C1E->(dbSkip())
			End
		EndIf
	EndIf

	RestArea( aArea )

	If FUNNAME() $ cListFontes .OR. cGetIdEnt == "GetIdEntTafspnfe"
		aReturn := { lRet,cCpfPR }
	Else
		aReturn := aFilsCalc
	EndIf
	
Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSSTDtIni
Funcao para retornar a data inicial dos eventos de seguranca e saude no trabalho - SST
@type function

@author Andrews Egas
@since 12/09/2018
@version 1.0

@return dDataIni
/*/
//-------------------------------------------------------------------
Function TafSSTDtIni()

	Local dDataIni

	dDataIni := cToD("08/01/2019") // data inicial da obrigatoriedade dos eventos de SST

Return dDataIni


/*/{Protheus.doc} VldPeriodo
//Retorna verdadeiro se a data inicial do periodo esta entre a Admissão e Desligamento
@author osmar.junior
@since 27/09/2018
@version 1.0
@return ${lRet}, ${lRet}
@param dIniPer, date, Data inicial do período
@param dAdmiss, date, Data de Admissão
@param dDeslig, date, Data de desligamento
@type function
/*/
Static Function VldPeriodo(cPerApu, dAdmiss, dDeslig)

	Local lRet := .F.
	Local dIniPer

	If Len(cPerApu) == 7
		cPerApu := StrTran(cPerApu,"-","")
	EndIf

	If !Empty(dDeslig)
		dIniPer	:= CtoD("01/" + SubStr(cPerApu,5,2) + "/" + SubStr(cPerApu,1,4))
		If(dIniPer >= dAdmiss .And. dIniPer <= dDeslig)
			lRet := .T.
		EndIf
	Else
		dIniPer	:= CtoD("28/" + SubStr(cPerApu,5,2) + "/" + SubStr(cPerApu,1,4))
		If(dIniPer >= dAdmiss)
			lRet := .T.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXHMNew

Encapsulamento e verificação da existência da função HMNew
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/display/tec/HMNew

@author Felipe Morais
@since 17/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXHMNew()

	Local oHash   := Nil
	Local cRotina := "HMNew"

	If FindFunction(cRotina)
		oHash := &cRotina.()
	EndIf

Return(oHash)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXHMList

Encapsulamento e verificação da existência da função HMList
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/display/tec/HMList

@author Felipe Morais
@since 17/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXHMList(oArqTrb, aArqTrb)

	Local cRotina := "HMList"

	If FindFunction(cRotina)
		&cRotina.(oArqTrb, aArqTrb)
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXHMSet

Encapsulamento e verificação da existência da função HMSet
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/display/tec/HMSet

@author Felipe Morais
@since 17/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXHMSet(oHash, yKey, xVal)

	Local cRotina := "HMSet"

	If FindFunction(cRotina)
		&cRotina.(oHash, yKey, xVal)
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXHMAdd

Encapsulamento e verificação da existência da função HMAdd
Criado para tratar erro para Binário não atualizado

http://tdn.totvs.com/display/tec/HMAdd

@author Felipe Morais
@since 17/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXHMAdd( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2, nColuna_3, nTrim_3, nColuna_4, nTrim_4, nColuna_5, nTrim_5, nColuna_6, nTrim_6 )

	Local cRotina	:=	"HMAdd"

	If FindFunction( cRotina )
		If nColuna_6 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2, nColuna_3, nTrim_3, nColuna_4, nTrim_4, nColuna_5, nTrim_5, nColuna_6, nTrim_6 )
		ElseIf nColuna_5 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2, nColuna_3, nTrim_3, nColuna_4, nTrim_4, nColuna_5, nTrim_5 )
		ElseIf nColuna_4 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2, nColuna_3, nTrim_3, nColuna_4, nTrim_4 )
		ElseIf nColuna_3 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2, nColuna_3, nTrim_3 )
		ElseIf nColuna_2 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1, nColuna_2, nTrim_2 )
		ElseIf nColuna_1 <> Nil
			&cRotina.( oHash, aVal, nColuna_1, nTrim_1 )
		EndIf
	EndIf

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} TafGetMtrz

Função utilizada para retornar a filial matriz utilizada pelo REINF na transmissão dos eventos ao RET

@param     cFilialTab - Filial a ser analisada qual é a matriz, com base no CNPJ raiz

@author Wesley Pinheiro
@since 23/11/2018
@version 1.0
*/
//-------------------------------------------------------------------
Function TafGetMtrz( cFilialTab )

	Local nI         := 0
	Local nSM0Recno  := SM0->( Recno( ) )

	Local cFilMatriz := ""
	Local cCNPJFil   := ""

	Local aFiliais   := { }
	Local aAreaC1E   := { }

	DBSelectArea( "C1E" )
	aAreaC1E := C1E->( GetArea( ) )
	C1E->( DbSetOrder(3) ) // C1E_FILIAL + C1E_FILTAF + C1E_ATIVO
	If C1E->( MsSeek( xFilial("C1E") + PadR( cFilialTab, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )

		If C1E->C1E_MATRIZ == .T.
			cFilMatriz := cFilialTab
		Else

			cCNPJFil := AllTrim( Posicione( "SM0", 1, cEmpAnt + cFilialTab, "M0_CGC" ) )
			cCNPJFil := SubStr( cCNPJFil, 1, 8 )

			SM0->( dbGoTop( ) )

			While !SM0->( EOF( ) )
				if cCNPJFil $ SM0->M0_CGC
					Aadd( aFiliais, { AllTrim( SM0->M0_CODFIL ) } )
				EndIf
				SM0->( DbSkip( ) )
			EndDo

			SM0->( DBGoTo( nSM0Recno ) )

			For nI := 1 to len( aFiliais )
				If C1E->( MsSeek( xFilial( "C1E" ) + PadR( aFiliais[nI][1], TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
					If C1E->C1E_MATRIZ == .T.
						cFilMatriz := aFiliais[nI][1]
						exit
					EndIf
				EndIf
			Next nI
		EndIf

	EndIf

	RestArea( aAreaC1E )

Return cFilMatriz

//-------------------------------------------------------------------
/*{Protheus.doc} TafAjustID

Função com objetivo de verificar se ID que está sendo incluso na tabela, está duplicado
caso esteja ele pega o proximo numerador.

@param cId - Id da tabela para ajustar o ID
@param cAlias - Alias da tabela para ajustar o ID

@author Eduardo Sukeda
@since 30/11/2018
@version 1.0
*/
//-------------------------------------------------------------------
Function TafAjustID(cAlias, oModel)

	Local lChangeId := .F.

	Default cAlias := ""

	/*------------------------------
	Busco o próximo ID a ser incluso
	------------------------------*/

	cId := oModel:GetValue( "MODEL_" + cAlias, cAlias + "_ID" )

	While !TAFCheckID(cId,cAlias)

		TAFConOut("Id " + cId + " ja existente na tabela " + cAlias + " . Será realizado uma nova requisicao de numeração. ")

		&(cAlias)->(ConfirmSX8())
		cId := GetSx8Num(cAlias,cAlias+"_ID")

		lChangeId := .T.

	EndDo

	/*------------------------------------------------------------
	Gravo o próximo ID no modelo a ser incluso sem ser o duplicado
	------------------------------------------------------------*/

	oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_ID", cId )

Return(Nil)

/*/{Protheus.doc} xTafDelTab
    Rotina especifica de exclusão para eventos de tabela.
    Esta função teve de ser criada em virtude da ocorrência
    na qual o usuário realizava uma alteração e tentava exclui-la 
    depois antes da transmissão. Caso já existisse um ID + Versão
    transmitido o sistema acusava erro de integridade pois, a chave
    presente no SX9 estão incompletas.
    @type   Function
    @author Diego R Santos
    @since  24-06-2019
    @version 1.0
/*/

Function xTafDelTab(cAlias, nReg, nOpc)

	Local cTitulo	:= 'Exclusão de Evento'
	Local cNmFun	:= Iif(FindFunction("TafSeekRot"), TafSeekRot(cAlias), FunName())

	Local aArea		:= GetArea()

	Local oModel	:= Nil

	Private nRecno	:= nReg
	Private aSX9Rel := {}

	Default cAlias	:= ""
	Default nReg	:= 0
	Default nOpc	:= 1

	oModel:= FWLoadModel(cNmFun)
	oModel:SetOperation( nOpc )
	oModel:Activate()

	If IsBlind()
		FwFormCommit( oModel )
	Else
		FWExecView(cTitulo,cNmFun,nOpc,,{|| .T. },{|| TafDisableSX9( cAlias ) },,,,,,oModel )
		TafEnableSX9( cAlias )
	Endif

	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} xTafSmtERP
Verifica se o ambiente é SmartERP
@author  Wesley Pinheiro
@since   16/08/2019
/*/
//-------------------------------------------------------------------
Function xTafSmtERP( )

	Local nX := 0
	Local lRet := .F.
	Local aIni := GetINISessions( getAdv97( ) )

	For nX := 1 to Len( aIni )
		If GetPvProfString( aIni[nX], "TotvsCloud", "", getAdv97( ) ) == "1"
			lRet := .T.
			Exit
		EndIf
	Next nX

Return lRet

/*/{Protheus.doc} TAFNT1519
Função criada para avaliar se o ambiente do Governo já 
encontra-se com a NT 15-2019 ( Simplificação do E-Social ) em vigor
@type  Function
@author Santos.Diego
@since 24-09-2019
@version 1
@return 
.T. = Caso a NT 15/2019 já esteja ativa no ambiente.
.F. = Caso a NT 15/2019 não esteja ativa no ambiente.
/*/
Function TAFNT1519()

	Local lRet := .F.

//Caso ambiente Produção Restrita
	If GetMv('MV_TAFAMBE') == '2' .And. Dtos(Date()) >= '20191008' //DtoS(Date()) >= '20191008'
		lRet := .T.
	ElseIf GetMv('MV_TAFAMBE') == '1' .And. DtoS(Date()) >= '20191111'
		lRet := .T.
	EndIf

Return lRet
/*/{Protheus.doc} TafXDescont
Função para retorno da mensagem de rotina descontinuada
@type  Function
@author Henrique Pereira
@since 02/12/2019
/*/
Function TafXDescont(cMensagem)
	Default cMensagem := ''

	If !IsBlind()
		If !Empty(cMensagem)
			MSGINFO(STR0177 + cMensagem + STR0178, STR0179) ///"A funcionalidade + cMensagem + foi descontinuada do produto","Recurso Descontinuado"
		Else
			MSGINFO(STR0180,STR0179) //"A funcionalidade acessada foi descontinuada do produto","Recurso Descontinuado"
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtData
Funçao que valida se o usuário atual possui permissão para os campos
sensíveis e pessoais

@param lMsg - Se .t., exibe mensagem padrão (HELP) 
@param cMsgErro - Mensagem de erro que deve mostrar no help, se omitido mostra texto padrão.
@param cMsgSolu - Mensagem de solução que deve mostrar no help, se omitido mostra texto padrão.

Retorno lRet
@author Matheus Prada/Carlos Eduardo
@since 27/11/2019
@version 1.0 
/*/
//-------------------------------------------------------------------
Function ProtData(lMsg, cMsgErro, cMsgSolu)
	Local lRet := VerSenha(192) .and. VerSenha(193)

	default lMsg := .t.
	default cMsgErro := STR0181 //'Esse usuário não tem permissão para acessar dados pessoais e/ou sensíveis!'
	default cMsgSolu := STR0182 //'Solicite a liberação de acesso ao administrador do sistema.'

	if !lRet .and. lMsg
		Help(,,STR0183,, cMsgErro, 1, 0,,,,,,{cMsgSolu}) //#"Dados Pessoais/Sensíveis."
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtC9V
Verifica se existe regristo na C9V com data de admissão maior
que a do desligamento informado.

@param cFilC9v - Filial do trabalhador 
@param cCPFC9V - CPF do trabalhador
@param dDtDeslig - data de desligamento

Retorno lRet
@author TAF E-social
@since 19/01/2020
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function VldDtC9V(cFilC9V,cCPFC9V,dDtDeslig)

	Local cQuery	:= ""
	Local lRet		:= .F.
	Local cAliasC9V	:= GetNextAlias()

	cQuery :=" SELECT C9V_FILIAL, C9V_ID , C9V_CPF, C9V_STATUS, C9V_ATIVO " + CRLF
	cQuery += " FROM " + RetSQLName("C9V") + " C9V" + CRLF
	cQuery += " LEFT JOIN " + RetSQLName("CUP") + " CUP ON C9V.C9V_FILIAL = CUP.CUP_FILIAL" + CRLF
	cQuery += "	AND C9V.C9V_ID = CUP.CUP_ID" + CRLF
	cQuery += "	AND C9V.C9V_VERSAO = CUP.CUP_VERSAO" + CRLF
	cQuery += "	AND C9V.C9V_NOMEVE = CUP.CUP_NOMEVE" + CRLF
	cQuery += "	AND C9V.D_E_L_E_T_ = CUP.D_E_L_E_T_" + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " C9V_FILIAL = '" + cFilC9V + "' " + CRLF
	cQuery += " AND   C9V.C9V_STATUS = '4' " + CRLF
	cQuery += " AND   C9V.C9V_ATIVO  = '1' " + CRLF
	cQuery += " AND   C9V.C9V_CPF    = '" + cCPFC9V +"' " + CRLF
	cQuery += " AND   (CUP.CUP_DTADMI >= '" + dDtDeslig + "' " + CRLF
	cQuery += " OR    C9V.C9V_DTINIV >= '" + dDtDeslig + "' ) " + CRLF
	cQuery += " AND   C9V.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " ORDER BY C9V.C9V_ID DESC "

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAliasC9V)

	If (cAliasC9V)->(!EOF())
		lRet := .T.
	EndIf

	(cAliasC9V)->(DbCloseArea())

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} LegAccMode
Rotina desenvolvida para  considerar a configuração de acessibilidade de legenda númerica
@author Wesley Pinheiro	
@since 24/01/2020
@version 1.0 
/*/
//-------------------------------------------------------------------
Function LegAccMode( cImg )

	Local lIsDaltonic := FWHasAccMode( ACC_DALTONIC ) // Verifica se o modo de acesibilidade '2 - Legenda Númerica' está configurado para o usuário logado
	Local cImgName    := cImg

	If lIsDaltonic

		Do Case

		case cImg == "BR_PRETO"

			cImgName := "BR_PRETO_0"

		case cImg == "BR_VERDE"

			cImgName := "BR_PRETO_1"

		case cImg == "BR_VERMELHO"

			cImgName := "BR_PRETO_2"

		case cImg == "BR_AMARELO"

			cImgName := "BR_PRETO_3"

		case cImg == "BR_LARANJA"

			cImgName := "BR_PRETO_4"

		case cImg == "BR_AZUL"

			cImgName := "BR_PRETO_5"

		EndCase

	EndIf

Return cImgName

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNGETUF
Rotina para buscar o código da UF vindo a sigla ou o código do IBGE
@author Henrique  Pereira
@since 15/04/2020
@version 1.0 
/*/
//-------------------------------------------------------------------
function XFUNGETUF(cChave)

	Local cID		:=	''
	Default cChave	:=	''

	if !empty(cChave)
		cID := XFUNSeekCh( cChave , 'C09' , 1 ) //Verifica se existe a informação em cache
		if empty(cID)
			cID := XFUNSeekCh( cChave , 'C09' , 4 ) //Verifica se existe a informação em cache
		endif
	endif
	
return cID

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunAglt

Funcao de validacao na selecao de filiais, quando selecionado 
as opcoes de aglutinacao na geracao da gia:
1 - Por CNPJ
2 - Por CNPJ+IE

@author Denis Souza
@since 18/08/2020
@version 1.0 
/*/
//-------------------------------------------------------------------
function xFunAglt( aCNPJIE, nIt, aArray )

	Local nIndAux := 0
	Local aStruct := {}
	Local cCnpj   := ""
	Local cIE     := ""
	Local lFoundCnpj := .F.
	Local lFoundIE   := .F.

	Default aArray := {}
	Default nIt := 1

	If len(aArray) > 0
		//aCNPJIE ja validado
		lCNPJ := aCNPJIE[1][1] //aglt cnpj
		lIE   := aCNPJIE[1][2] //aglt IE

		cCnpj := iif( lCNPJ, aArray[nIt][4], "" )
		cIE   := iif( lIE  , aArray[nIt][5], "" )

		//inverte selecao
		aArray[nIt,1] := !aArray[nIt,1]

		//valida selecao
		For nIndAux := 1 to Len(aArray)
			if aArray[nIndAux][1]
				if len(aStruct) == 0
					aadd( aStruct, { aArray[nIndAux][4], aArray[nIndAux][5] } )
				else
					//caso a marcacao seja superior a algum ja selecionado
					//considero o CNPJ e IE do superior para verificacao
					if nIndAux > nIt
						cCnpj := iif( lCNPJ, aArray[nIndAux][4], "" )
						cIE   := iif( lIE  , aArray[nIndAux][5], "" )
					endif

					lFoundCnpj := aScan( aStruct, { |x| x[1] == cCnpj } ) == 0
					lFoundIE   := aScan( aStruct, { |x| x[2] == cIE } ) == 0

					if !Empty(cCnpj) .And. !Empty(cIE) //valida aglutinacao por CNPJ e IE
						if lFoundCnpj .Or. lFoundIE
							aArray[nIt,1] := .F. //desabilito a selecao
							Help(NIL, NIL, STR0184, NIL, STR0185, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0186}) //"Validação"##"A aglutinação por CNPJ+IE foi selecionado."##"Selecione apenas Filiais com o mesmo CNPJ e IE."
							exit
						endif
					elseif !Empty(cCnpj) .And. Empty(cIE) //valida aglutinacao apenas por CNPJ
						if lFoundCnpj
							aArray[nIt,1] := .F.
							Help(NIL, NIL, STR0184, NIL, STR0187, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0188}) //"Validação"##"A aglutinação por CNPJ foi selecionado."##"Selecione apenas Filiais com o mesmo CNPJ."
							exit
						endif
					endif
				endif
			endif
		Next nIndAux
	endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFVldPFRu

Define se o campo A2_CPFRUR pode ser utilizado.

@return   	.F. - Bloqueia o campo.

@author 	Matheus G. Prada
@version	12.1.23 / Superior
@Since		12/04/2019
/*/
//------------------------------------------------------------------------------
Function TAFVldPFRu(cCPFRur,cTpPessoa,cIndRur,cEstado)

	Local	lRet	:=	.F.
	Local	lRural	:=	.F.
	Local	cEstLib :=	SuperGetMV("MV_TAFESLB",.F.,"SP")

	lRural	:=	(cTpPessoa $ "F") .AND. (cIndRur $ "1,2,3") .AND. (cEstado $ cEstLib)

	If lRural .And. ( Empty( cCPFRur ) .Or. ( CGC(cCPFRur) .And. A020CGC(cTpPessoa, cCPFRur) ) )
		lRet := .T.
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} pesqDtDemissao

@origem		Rotina chamada no campo ZAP_RULES do folder 'Base Legal' do Cadastro de Mapeamentos LGPD no AtuSx

A partir de tabelas de origem passadas como parâmetro para a função, pesquisa a data de demissão do funcionário (CMD_DTDESL),
soma 30 anos a essa data, e retorna se o registro poderá ser anonimizado ou não

@param		cTable 	- Alias da tabela que está sendo verificada base legal de tempo de guarda

@return   	lRet 	- Registro pode ou não ser anonimizado

@author 	Fabio Mendonça
@version	12.1.23 / Superior
@Since		02/06/2021
/*/
//------------------------------------------------------------------------------
Function pesqDtDemissao( cTable, cEvent )

	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cCmpCPF  := ""

	Default cTable := ""
	Default cEvent := ""
	
	// EVENTOS DE TRABALHADOR
	If cTable $ "C9V|T1U|T0F|T1V|"

		If Empty(cEvent) .Or. cEvent = "S2200"

			DBSelectArea( "CMD" )
			CMD->( DBSetOrder( 5 ) )

			// PESQUISA DATA DE DEMISSAO DO FUNCIONARIO ATRAVES DO ID DA C9V
			If CMD->( MsSeek( xFilial( cTable ) + ( cTable )->&( cTable + "_ID" ) + "1") )

				lRet := Date() > CMD->CMD_DTDESL + 10950

			EndIf

		ElseIf cEvent = "S2300"

			DBSelectArea( "T92" )
			T92->( DBSetOrder( 3 ) )

			// PESQUISA DATA DE DEMISSAO DO FUNCIONARIO ATRAVES DO ID DA C9V
			If T92->( MsSeek( xFilial( cTable ) + ( cTable )->&( cTable + "_ID" ) + "1") )

				lRet := Date() > T92->T92_DTERAV + 10950

			EndIf

		EndIf

	// EVENTOS TOTALIZADORES
	ElseIf cTable $ "T2M|T2G|V2P|T3A|"

		DBSelectArea( "C9V" )
		C9V->( DBSetOrder( 3 ) )	

		// MONTA CAMPO DE CPF DO TOTALIZADOR SOLICITADO
		If cTable == "T2M"

			cCmpCPF		:=	cTable + "_CPFTRB"

		ElseIf cTable == "T2G"

			cCmpCPF		:=	cTable + "_CPFTRA"

		Else

			cCmpCPF		:=	cTable + "_CPF"

		EndIf	

		// PESQUISA COM BASE NO CPF DO TOTALIZADOR PARA ENCONTRAR O ID DO FUNCIONARIO NA C9V
		If C9V->( MsSeek( xFilial( cTable ) + ( cTable )->&( cCmpCPF ) ) )

			DBSelectArea( "CMD" )
			CMD->( DBSetOrder( 2 ) )

			// PESQUISA DATA DE DEMISSAO DO FUNCIONARIO ATRAVES DO ID DA C9V
			If CMD->( MsSeek( C9V->C9V_FILIAL + C9V->C9V_ID ) )

				lRet := Date() > CMD->CMD_DTDESL + 10950

			EndIf
								
		EndIf	
	EndIf
		
	RestArea( aArea )

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldTokenTSS
Validação da configuração do Token de Autenticação TAF X TSS

@param cMsgRet		- Retorna a mensagem de erro por referência
@param lErroToken 	- Retorna o tipo de erro por referência
@param cFaultCod	- Recebe o código do erro

@author Melkz Siqueira
@since 02/06/2021
@version 1.0		

@return lRet - Retorna se é um erro referente ao Token TAF X TSS
/*/ 
//-------------------------------------------------------------------
Function TAFVldTokenTSS(cMsgRet, lErroToken, cFaultCod,lClearMsg)
	
	Local lRet			:= .T.
	Local aAreaFX7		:= {}

	Default cMsgRet 	:= ""
	Default cFaultCod	:= ""	
	Default lErroToken	:= .F.
	Default lClearMsg	:= .T.

	If AllTrim(cFaultCod) $ "401|403"
		if lClearMsg
			cMsgRet := substr(cMsgRet,at("Mensagem:",cMsgRet),len(cMsgRet))
			if cMsgRet == "Mensagem: Token não informado. "
				if TableInDic("FX7") .and. ChkFile("FX7") .and. ExistFunc("FX7CltKey") .and. !FwIsInCallStack("StaticCall") 
					aAreaFX7 := FX7->(GetArea())
					FX7->(dbSetOrder(1))
					if FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) ))
						cMsgRet := "Mensagem: Token inválido "
					endif
					RestArea(aAreaFX7)
				Endif
			Endif
		Endif

		cMsgRet		:= AllTrim(cMsgRet) + CRLF + CRLF
		cMsgRet 	+= STR0205 + CRLF + CRLF 	// "TOKEN de autenticação obrigatório TAF X TSS. Descrição do Erro:"
		cMsgRet 	+= STR0206 + CRLF + CRLF	// "Esta Filial não tem permissão para acessar o servidor TSS."
		cMsgRet 	+= STR0207 + CRLF + CRLF 	// "Contate o administrador do sistema e verifique as credenciais cadastradas na rotina 'Conf. Geral TSS' (SPEDCONFTSS)"
		cMsgRet 	+= STR0208 + CRLF			// "Links Úteis:"
		cMsgRet 	+= STR0209 + CRLF			// "Configurando TSS com autenticação: https://tdn.totvs.com.br/pages/releaseview.action?pageId=593238229"
		cMsgRet 	+= STR0210 					// "Configurações Gerais do TSS: https://tdn.totvs.com.br/pages/releaseview.action?pageId=590613669"

		lErroToken	:= .T.
		lRet		:= .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFEvtsNT
Retorna a relação de eventos não disponíveis para transmissão 
(obsoletos, inativados, não lançados, etc)

@author Melkz Siqueira
@since 23/06/2021
@version 1.0		

@return cEvtsNT - Retorna uma string contendo os eventos não transmissíveis
/*/ 
//-------------------------------------------------------------------
Function TAFEvtsNT()

	Local cEvtsNT := "|"

Return cEvtsNT

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFChgFil
Faz a troca para a filial Matriz
Usada para fazer as transmissões/consultas pela Matriz
Atenção: Antes de usar essa função guarde a área da SM0 e faça backup da cFilAnt 

@param cMsgErro	- Retorna a mensagem de erro por referência

@author Melkz Siqueira
@since 01/07/2021
@version 1.0		

@return lRet - Retorna se houve a troca para a filial Matriz com êxito
/*/ 
//-------------------------------------------------------------------
Function TAFChgFil(cMsgErro)

	Local aInfoMatriz	:= TAFGFilMatriz()
	Local lJob			:= IsBlind() 
	Local lRet	 		:= .F.
	Local lExibeMsg		:= .T.

	Default cMsgErro	:= ""

	If !Empty(aInfoMatriz)
		If !SM0->(MsSeek(aInfoMatriz[1] + PadR(aInfoMatriz[2], FWSizeFilial())))
			If lJob
				TafConOut("É necessário selecionar 1 Filial como Matriz no Complemento de Empresas.")
			Else
				If lExibeMsg
					Aviso("TOTVS SERVICE SOA","É necessário selecionar 1 Filial como Matriz no Complemento de Empresas.",{"OK"},3)
				Else
					cMsgErro += "É necessário selecionar 1 Filial como Matriz no Complemento de Empresas."
				EndIf 
			EndIf
		Else
			cFilAnt	:= PadR(aInfoMatriz[2], FWSizeFilial())
			lRet 	:= .T.  
		EndIf
	Else
		If lJob
			TafConOut("Não há Filial Marcada como Matriz no Cadastro de Complemento de Empresas ou o CNPJ Base da Filial não é igual ao da Matriz.") 
		Else
			If lExibeMsg
				Aviso("TOTVS SERVICE SOA","Não há Filial Marcada como Matriz no Cadastro de Complemento de Empresas ou o CNPJ Base da Filial não é igual ao da Matriz.",{"OK"},3)
			Else
				cMsgErro += "Não há Filial Marcada como Matriz no Cadastro de Complemento de Empresas ou o CNPJ Base da Filial não é igual ao da Matriz."
			EndIf 
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CbLogOpe

Função que retorna as opções de combobox 
Campos: CBOX

@author Rodrigo Nicolino
@since 26/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function CbLogOpe()

	Local cString := ""

	cString := "1=Incl.Integr;" 			// Incl.Integr
	cString += "2=Incl.Manual;" 			// Incl.Manual
	cString += "3=Incl.Integr+Alt.Integr;" 	// Incl.Integr+Alt.Integr 	
	cString += "4=Incl.Integr+Alt.Manual;" 	// Incl.Integr+Alt.Manual			
	cString += "5=Incl.Manual+Alt.Integr;" 	// Incl.Manual+Alt.Integr
	cString += "6=Incl.Manual+Alt.Manual;" 	// Incl.Manual+Alt.Manual 
	cString += "7=Ajuste Manual Recibo;" 	//Ajuste Manual Recibo

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDecUTF8
Força a decodificação de UTF-8 para CP-1252 (Windows-1252)

@param cText - String a ser decodificada
 
@author Melkz Siqueira
@since 14/09/2021
@version 1.0		

@return cTextDec - Retorna a string passada como parâmetro decodificada
/*/ 
//-------------------------------------------------------------------
Function TAFDecUTF8(cText)

	Local cTryDecode	:= ""
	Local cDecode		:= ""
	Local cTextDec 		:= ""
	Local lDecode		:= .T.

	Default cText 		:= ""
	
	If !Empty(cText)

		cTextDec := AllTrim(cText)

		While lDecode
			
			cDecode 	:= DecodeUTF8(cTextDec)
			cTryDecode	:= cDecode

			If ValType(cDecode) == "U"
			
				cTryDecode := DecodeUTF8(cTextDec, "iso8859-1")
	
			EndIf

			If ValType(cDecode) <> "U" .AND. cDecode <> cTextDec
			
				cTextDec := cDecode
			
			ElseIf ValType(cTryDecode) <> "U" .AND. cTryDecode <> cTextDec
			
				cTextDec := cTryDecode

			Else

				lDecode := .F.

			EndIf

		EndDo

	EndIf

Return cTextDec

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetUltAtv
Posiciona no último registro ativo para o Trabalhador existente na chave

cAlias		-> cAlias da tabela que irá posicionar
cChave		-> Chave utilizada para posicionar
nInd		-> Número do Indice 
cFunction	-> Nome da função que está chamando (usado no extemporâneo)
nRecnoHist	-> Numero do RECNO do dado (usado no extemporâneo)
cCmpDtEvt	-> Nome do Campo de Data da tabela (usado no extemporâneo)

@Return .T. - Se encontrar um evento de alteração ativo para o trabalhador
		.F. - Se não encontrar um evento de alteração ativo para o trabalhador

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//----------------------------------------------------------------------------------------------------------------------------
Function RetUltAtv(cAlias, cChave, nInd, lTrans, cFunction, nRecnoHist, cCmpDtEvt, cCmpChv)

	Local cChvComp     := ""
	Local lReturn      := .F.
	Local nRecno       := 0

	Default cAlias     := ""
	Default cChave     := "" 
	Default nInd       := ""
	Default cCmpDtEvt  := ""
	Default cFunction  := ""
	Default lTrans     := .F. // indica se deve procurar um registro transmitido
	Default nRecnoHist := 0
	Default cCmpChv    := ""

	If (cAlias == "V76" .Or. cAlias == "V77" .Or. cAlias == "V78") .And. !Empty(cFunction)

		dbSelectArea(cAlias)
		(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + CAMPO DE DATA DA TABELA
		(cAlias)->(dbGoTo(nRecnoHist))
		cChave += DTOS((cAlias)->&(cAlias + cCmpDtEvt))
		
	Else

		dbSelectArea(cAlias)
		(cAlias)->(dbSetorder(nInd))
		(cAlias)->(dbGoTop())

	EndIf

	If (cAlias)->(msSeek(xFilial(cAlias) + cChave))

		While (cAlias)->(!Eof()) .And. xFilial(cAlias) == (cAlias)->&(cAlias + "_FILIAL")

			If (cAlias == "V76" .OR. cAlias == "V77" .OR. cAlias == "V78").AND. !empty(cFunction)
				cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO") + DTOS((cAlias)->&(cAlias + cCmpDtEvt))//Chave com data pelo historico
			ElseIf !Empty(cCmpChv)
				cChvComp := (cAlias)->&(cCmpChv)
			Else
				cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO")//Chave Original
			EndIf

			If cChvComp == cChave

				nRecno := (cAlias)->(Recno())

			EndIf

			(cAlias)->(DbSkip())

		EndDo

		If nRecno > 0
			lReturn := .T.
			(cAlias)->(dbGoto(nRecno))
		EndIf

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCacheFil
Cria uma tabela temporária em cache para armazenar as filiais que serão usadas em uma query.
Essa tabela é necessária para não estourar o tamanho da query quando houver muitas filiais.
A tabela é destruída e a área é fechada automaticamente quando a conexão com o banco é encerrada.

@param cAlias - Alias da tabela que será checada
@param aFiliais - Array de Filiais prontas para serem gravas na tabela temporária
@param lForce - Indica se deve forçar a criação de uma nova tabela temporária
@param nTamFil - Tamanho do campo FILIAL que será criado na tabela temporária
@param cCacheID - ID a ser utilizado na identificação da tabela com as filiais em cache

@author Melkz Siqueira
@since 15/10/2021
@version 1.0		

@return cTmpName - Nome da tabela temporária em cache
/*/
//-------------------------------------------------------------------
Function TAFCacheFil(cAlias as character, aFiliais as character, lForce as logical, nTamFil as numeric, cCacheID as character)

	Local aFilSelect	as array
	Local aArea			as array
	Local aInfoSM0		as array
	Local aFields		as array
	Local cID			as character
	Local cInFil 		as character
	Local cTmpAlia		as character
	Local cCNPJRaiz		as character
	Local cTmpName		as character
	Local cTCAlias		as character
	Local cTmpAlias		as character
	Local nI			as numeric
	Local nFilCache		as numeric
	Local oInsert 		as object
	Local oTmpTab		as object

	Default cAlias		:= ""
	Default cCacheID	:= ""
	Default aFiliais	:= {}
	Default lForce		:= .F.
	Default nTamFil		:= 0

	aFilSelect := {}
	aArea      := {}
	aInfoSM0   := {}
	aFields    := {}
	cID        := ""
	cInFil     := ""
	cTmpAlia   := ""
	cCNPJRaiz  := ""
	cTmpName   := ""
	cTCAlias   := ""
	cTmpAlias  := ""
	nI         := 0
	nFilCache  := 0
	oInsert    := Nil
	oTmpTab    := Nil

	cID        := IIf(Empty(cCacheID), __cCacheID, cCacheID)
	nFilCache  := AScan(__aFilCach, {|x| x[1] == cEmpAnt + cFilAnt .And. x[2] == cID})

	If nFilCache > 0

		cTmpName 	:= __aFilCach[nFilCache][3]
		cTmpAlias	:= __aFilCach[nFilCache][4]
		cTCAlias 	:= __aFilCach[nFilCache][5]

		If !TCCanOpen(cTCAlias)

            lForce     := .T.
            __aFilCach := {}
			nFilCache  := 0

        EndIf

	EndIf
	
	If ((!Empty(cAlias) .OR. !Empty(aFiliais)) .AND. (__cFilCach != cEmpAnt + cFilAnt .OR. !ChkFile(cTmpAlias) .Or. !TCCanOpen(cTCAlias)) .And. Empty(cTmpName)) .OR. lForce 
		
		aFilSelect 	:= AClone(aFiliais)
		aArea 		:= GetArea()

		If Empty(aFilSelect)
			
			aInfoSM0   	:= FWLoadSM0()
			cCNPJRaiz	:= SubStr(SM0->M0_CGC, 1, 8)

			aEval(aInfoSM0, {|x| Iif(SubStr(x[18], 1, 8) == cCNPJRaiz .AND. x[1] == cEmpAnt .AND. !xFilial(cAlias, x[2]) $ cInFil, cInFil += xFilial(cAlias, x[2]) + ";", Nil)})

			aFilSelect := StrTokArr2(cInFil, ";")
		
		EndIf

		cTmpAlia	:= GetNextAlias()
		__cFilCach	:= cEmpAnt + cFilAnt

		If nTamFil == 0
			nTamFil	:= Iif(Empty(cAlias), FWSizeFilial(), GetSX3Cache(cAlias + "_FILIAL", "X3_TAMANHO"))
		EndIf

		aAdd(aFilSelect, Space(nTamFil))
		aAdd(aFields, {"FILIAL", "C", nTamFil, 0})
		
		oTmpTab := FWTemporaryTable():New(cTmpAlia)

		oTmpTab:SetFields(aFields)
		oTmpTab:AddIndex("01", {"FILIAL"})
		oTmpTab:Create()

		cTmpName	:= oTmpTab:GetRealName()
		cTmpAlias 	:= oTmpTab:GetAlias()

		If FwLibVersion() >= "20210517"
			cTCAlias := oTmpTab:GetTableNameForTCFunctions()
		EndIf
	
		If __lCanBulk == Nil
			
			If FwLibVersion() >= "20210517"
				__lCanBulk := FwBulk():CanBulk()
			Else
				__lCanBulk := .F.
			EndIf

		EndIf

		If __lCanBulk

			oInsert := FwBulk():New(oTmpTab:GetTableNameForTCFunctions())

			oInsert:SetFields({{"FILIAL"}})

			For nI := 1 To Len(aFilSelect)
				oInsert:AddData({aFilSelect[nI]})
			Next

			oInsert:Flush()
			oInsert:Close()

		Else

			For nI := 1 To Len(aFilSelect)

				cSqlInsert := "INSERT INTO " + cTmpName
				cSqlInsert += " (FILIAL)"
				cSqlInsert += " VALUES ('" + aFilSelect[nI] + "') "

				If TCSQLExec(cSqlInsert) < 0
					MsgInfo(TCSQLError(),"Tabela Temporaria Filiais - " + PROCNAME())
				EndIf

			Next

		EndIf

		If Empty(cCacheID)

			__cCacheID 	:= UUIDRandom()
			cID 		:= __cCacheID

		Else

			cID := cCacheID

		EndIf

		If nFilCache > 0

			__aFilCach[nFilCache][1] := __cFilCach
			__aFilCach[nFilCache][2] := cID
			__aFilCach[nFilCache][3] := cTmpName
			__aFilCach[nFilCache][4] := cTmpAlias
			__aFilCach[nFilCache][5] := cTCAlias

		Else

			AAdd(__aFilCach, {__cFilCach, cID, cTmpName, cTmpAlias, cTCAlias})

		EndIf

		RestArea(aArea)
		FWFreeArray(aInfoSM0)
		FWFreeArray(aFields)
		FWFreeArray(aFilSelect)
		FWFreeObj(oTmpTab)

		(cTmpAlia)->(DBCloseArea())

	EndIf

Return cTmpName 

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFGPEFGTSINSS

Verifica para que está regra seja aplicada somente no GPE
@Return lRet 

@Author José Riquelmo/ Alexandre de Lima S.
@Since 18/02/2022
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function TafGpeFgtsInss()

	Local lRhTAF := SuperGetMV( 'MV_RHTAF' , .F. , .F. ) 
	Local lMid   := SuperGetMV( 'MV_MID' , .F. , .F. )
	Local lRet   := .F.

	If lRhTAF .And. !lMid

		lRet := .T.
	
	EndIf 

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GrvURLTSS
	(Função para fazer a gravação da SX6 com o campo X6_FIL com o código da empresa para atender o débito técnico de gravação direta na SX6)
	(O parâmetro MV_TAFSURL tem uma particularidade que é gravado por código da empresa tanto para gestão de empresas como para sigamat antigo no layout FF)
	@type Static Function
	@author Renan Gomes
	@since 18/04/2022
	@version version
	@return
/*/
//----------------------------------------------------------------------
Static Function GrvURLTSS(cUrl)

	Local cFilBkp		:= cFilAnt
	Local cLayout  		:= FWSM0Layout()
	Local lGestao  	 	:= "E" $ cLayout .Or. "U" $ cLayout
	Local nFil			:= 0
	Local cCodEmp 		:= AllTrim(FWCodEmp())
	Local aFils			:= {}

	Default cUrl := ""

	If FWSX6Util():ExistsParam("MV_TAFSURL")

		if !lGestao 
			cFilAnt := cCodEmp
		Endif

		FWSX6Util():ReplicateParam( "MV_TAFSURL" , {cFilAnt} , .T. , .F. )
		PutMV( 'MV_TAFSURL', cUrl )
		//Volto filial logada
		cFilAnt := cFilBkp

	else

		if lGestao

			aFils := FWLoadSM0()

			//Procuro na lista de filiais qual empresa que tem o parâmetro na base para poder replica-lo
			for nFil := 1 to len(aFils)

				If !Empty(GetNewPar("MV_TAFSURL",'', aFils[nFil][2]))
					cFilAnt := aFils[nFil][2]
					exit
				endif

			next

			//Replico o parâmetro para para a empresa logada de acordo com o parâmetro encontrado em outra filial
			FWSX6Util():ReplicateParam( "MV_TAFSURL" , {cFilBkp} , .T. , .F. )
			
			//Volto filial logada
			cFilAnt := cFilBkp

			SuperGetMv() //Limpa o cache de parametros - nao retirar
			
			If FWSX6Util():ExistsParam("MV_TAFSURL")
				PutMV( 'MV_TAFSURL', cUrl )
			else
				cMsgRet 	:= "Parâmetro MV_TAFSURL não existe na base de dados" + CRLF
				cMsgRet 	+= "Contate o administrador do sistema" + CRLF
				MsgStop(cMsgRet, "Parâmetro MV_TAFSURL inválido")
			Endif

		else 

			/*Quando não for gestão corporativa, os parâmetros na SX6 estavam gravando o campo X6_FIL com o código da empresa via RECLOCK,
			com isso, nenhuma função do frame encontrava esse parâmetro de forma padrão.
			Foi necessário trocar a cFilAnt para o código da empresa para que as funções e métodos do frame funcione corretamente*/
			cFilAnt := cCodEmp

			If FWSX6Util():ExistsParam("MV_TAFSURL")
				//Replico o parâmetro para para a empresa logada de acordo com o parâmetro encontrado em outra filial
				FWSX6Util():ReplicateParam( "MV_TAFSURL" , {cFilBkp} , .T. , .F. )
			
				//Altero o parâmetro que está com o código da empresa ao invés do código da filial
				PutMV( 'MV_TAFSURL', cUrl )
			else
				cMsgRet 	:= "Parâmetro MV_TAFSURL não existe na base de dados" + CRLF
				cMsgRet 	+= "Contate o administrador do sistema" + CRLF
				MsgStop(cMsgRet, "Parâmetro MV_TAFSURL inválido")
			Endif
			
			//Volto filial logada
			cFilAnt := cFilBkp

		Endif	

	Endif
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XFunPosInt
Função genérica sada para pegar o valor de um campo que precisa ser gravado 
via integração porém não faz parte do TafLayout.

@param 	cAlias		-	Alias de pesquisa
		cFieldRet	- 	Campo que deve ser retornardo pela pesquisa
		nInd		- 	Indice que será usado na pesquisa
		cValDef		- 	Valor default de retorno caso chave da pesquisa nao seja encotrada na tabela
		x1			-	Primeiro Parametro do Posicione
		
@return	cRetorno	- 	Conteudo do campo passado por parâmetro, retorno do GetAdvFVal

@author Carlos Eduardo Boy
@since 10/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function XFunPosInt(cAlias, cFieldRet, nInd, xValDef, x1 )

	Local cRet := ''
	Local cTipoVar := ''

	//Verifico se foi passado o retorno default da pesquisa e se o campo de pesquisa existe na dicionario.
	if valtype(xValDef) == 'U'

		cTipoVar := GetSx3Cache( cFieldRet, "X3_TIPO" )

		do case

			case cTipoVar == 'C' 
				xValDef := ''
			case cTipoVar == 'N'
				xValDef := 0
			case cTipoVar == 'D'
				xValDef := dDataBase
			case cTipoVar == 'L'
				xValDef := .T.
		endcase	

	endif

	cRet := GetAdvFVal(cAlias, cFieldRet, xFilial(cAlias) + x1 , nInd, xValDef)

return cRet

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFGetNT1U
@description Retorna o nome mais atual do trabalhador que teve seu nome alterado 
				através do evento S-2205 - Alteração Cadastral
@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param cCPF    	- CPF do trabalhador
@param cPeriodo	- Período da alteração do nome no formato AAAA ou AAAAMM
@param cFil    	- Filial a ser procurado o trabalhador
@return cNome   - Nome do trabalhador
/*/
//----------------------------------------------------------------------
Function TAFGetNT1U(cCPF as character, cPeriodo as character, cFil as character)
    
    Local cLibVer   	as character
    Local cQuery    	as character
    Local cQryT1U   	as character
    Local cQryAlias 	as character
    Local cNome     	as character
	Local cLegacyLib	as character
	Local cQueryPer		as character

    Default cFil    	:= cFilAnt
    Default cCPF    	:= ""
	Default cPeriodo	:= ""

    cLibVer     := ""
    cQuery      := ""
    cQryT1U     := ""
    cQryAlias   := ""
    cNome       := ""
	cQueryPer	:= ""
	cLegacyLib	:= "20020101"

    If !Empty(cCPF)

        cLibVer := "20211116"

		If __cLibVer == Nil

			If FindFunction("TAFisBDLegacy")

				If TAFisBDLegacy()
					__cLibVer := cLegacyLib
				Else
					TAFGetLib()
				EndIf

			Else

				__cLibVer := cLegacyLib

			EndIf 

		EndIf

		TAFGetDB()

		If !Empty(cPeriodo)

			If Len(cPeriodo) == 4
				cQueryPer := " AND T1U.T1U_DTALT <= '" + cPeriodo + "12" + "31" + "' "
			Else
				cQueryPer := " AND T1U.T1U_DTALT <= '" + cPeriodo + "31" + "' "
			EndIf

		EndIf

        If __oQryT1U == Nil .Or. __cLibVer < cLibVer

            cQuery := ""

            If __cLibVer >= cLibVer
                cQuery := " SELECT "
            EndIf

            If __cBanco $ "ORACLE|MYSQL|POSTGRES"

                cQuery += " T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT "

            Else

                cQuery += IIf(__cBanco $ "MSSQL|OPENEDGE", " TOP 1 T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT ",; 
                            " FIRST 1 T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT ")
            
			EndIf

            cQuery += " FROM " + RetSQLName("T1U") + " T1U "
            cQuery += " WHERE T1U.D_E_L_E_T_ = ' ' "
            cQuery += " AND T1U.T1U_ATIVO = '1' "

            If __cLibVer >= cLibVer

                cQuery += " AND T1U.T1U_FILIAL = ? "
                cQuery += " AND T1U.T1U_CPF = ? "
				cQuery += " ? "

            Else

                cQuery += " AND T1U.T1U_FILIAL = '" + xFilial("T1U", cFil) + "' "
                cQuery += " AND T1U.T1U_CPF = '" + cCPF + "' "
				cQuery += cQueryPer

            EndIf

            cQuery += " GROUP BY T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT "
            cQuery += " ORDER BY T1U.T1U_FILIAL, T1U.T1U_DTALT DESC "
            
            If __cBanco $ "POSTGRES|MYSQL"
                cQuery += " LIMIT 1 "
            EndIf

            If __cBanco == "ORACLE"

                If __cLibVer >= cLibVer
                    cQryT1U := " SELECT "
                EndIf

                cQryT1U += " TEMP.T1U_NOME FROM ( "

                If __cLibVer < cLibVer
                    cQryT1U += " SELECT "
                EndIf

                cQryT1U += cQuery
                cQryT1U += " ) TEMP "
                cQryT1U += " WHERE ROWNUM <= 1 "

            Else

                cQryT1U := cQuery

            EndIf

            If __cLibVer >= cLibVer

                cQryT1U		:= ChangeQuery(cQryT1U)
                __oQryT1U 	:= FwExecStatement():New(cQryT1U)

            EndIf

        EndIf
        
        If __cLibVer >= cLibVer

            __oQryT1U:SetString(1, xFilial("T1U", cFil))
            __oQryT1U:SetString(2, cCPF)
			__oQryT1U:SetUnsafe(3, cQueryPer)

            cQryAlias := __oQryT1U:OpenAlias()

        Else

            cQryAlias	:= GetNextAlias()
            cQryT1U		:= "%" + cQryT1U + "%"

            BeginSQL Alias cQryAlias
                SELECT %Exp:cQryT1U%
            EndSQL

        EndIf

        If !(cQryAlias)->(EOF())
            cNome := AllTrim((cQryAlias)->T1U_NOME)
        EndIf

        (cQryAlias)->(DbCloseArea())
		
    EndIf

Return cNome

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFGetNT3A
@description Retorna o nome do trabalhador do evento S-2190
@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param cCPF - CPF do trabalhador
@param cFil - Filial a ser procurado o trabalhador
@return cNome - Nome do trabalhador
/*/
//----------------------------------------------------------------------
Function TAFGetNT3A(cCPF as character, cFil as character)
    
	Local cLegacyLib	as character
    Local cLibVer   	as character
    Local cQuery    	as character
    Local cQryT3A   	as character
    Local cQryAlias 	as character
    Local cNome     	as character

    Default cCPF    	:= ""
    Default cFil    	:= cFilAnt

	cLegacyLib	:= "20020101"
    cLibVer     := ""
    cQuery      := ""
    cQryT3A     := ""
    cQryAlias   := ""
    cNome       := ""

    If !Empty(cCPF)

        cLibVer := "20211116"
        
		If __cLibVer == Nil

			If FindFunction("TAFisBDLegacy")

				If TAFisBDLegacy()
					__cLibVer := cLegacyLib
				Else
					TAFGetLib()
				EndIf

			Else

				__cLibVer := cLegacyLib

			EndIf 

		EndIf

		TAFGetDB()

        If __oQryT3A == Nil .Or. __cLibVer < cLibVer

            cQuery := ""

            If __cLibVer >= cLibVer
                cQuery := " SELECT "
            EndIf

            cQuery += " T3A.T3A_FILIAL, T3A.T3A_ID "
            cQuery += " FROM " + RetSQLName("T3A") + " T3A "
            cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' "
            cQuery += " AND T3A.T3A_ATIVO = '1' "
            
            If __cLibVer >= cLibVer

                cQuery += " AND T3A.T3A_FILIAL = ? "
                cQuery += " AND T3A.T3A_CPF = ? "

            Else

                cQuery += " AND T3A.T3A_FILIAL = '" + xFilial("T3A", cFil) + "' "
                cQuery += " AND T3A.T3A_CPF = '" + cCPF + "' "

            EndIf

            cQuery += " GROUP BY T3A.T3A_FILIAL, T3A.T3A_ID "
            
            cQryT3A := cQuery

            If __cLibVer >= cLibVer

                cQryT3A		:= ChangeQuery(cQryT3A)
                __oQryT3A 	:= FwExecStatement():New(cQryT3A)

            EndIf

        EndIf
        
        If __cLibVer >= cLibVer

            __oQryT3A:SetString(1, xFilial("T3A", cFil))
            __oQryT3A:SetString(2, cCPF)

            cQryAlias := __oQryT3A:OpenAlias()

        Else

            cQryAlias	:= GetNextAlias()
            cQryT3A		:= "%" + cQryT3A + "%"

            BeginSQL Alias cQryAlias
                SELECT %Exp:cQryT3A%
            EndSQL

        EndIf

        If !(cQryAlias)->(EOF())
            cNome := STR0218 // "TRABALHADOR PRELIMINAR"
        EndIf

        (cQryAlias)->(DbCloseArea())

    EndIf

Return cNome

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFGetLib
@description  Carrega a versão da Lib em cache
@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@return __cLibVer - Versão da Lib em cache
/*/
//----------------------------------------------------------------------
Function TAFGetLib()

	If __cLibVer == Nil
		__cLibVer := FwLibVersion()
	EndIf

Return __cLibVer

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFGetDB
@description Carrega o nome do Banco de Dados em cache
@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@return __cBanco - Nome do Banco de Dados em cache
/*/
//----------------------------------------------------------------------
Function TAFGetDB()

    If __cBanco == Nil
        __cBanco := TCGetDB()
    EndIf

Return __cBanco

//----------------------------------------------------------------------
/*/{Protheus.doc} APILogAccess
	Grava Log de Acesso no License Server de API's do TAF 
	
	@type  Function
	@author Fabio Mendonça
	@since 31/03/2023
	@version 1.0
	@param cAPIName, character, Nome da API para Métrica
	@param cComplement, character, Complemento opcional para identificação da Métrica
/*/
//----------------------------------------------------------------------
Function APILogAccess(cAPIName as character, cComplement as character)

	Local cMetricName as character
	Local cIdLog	  as character
	Local cUserId     as character
	Local cModule 	  as character

	Default cComplement := ""

	cIdLog      := "LS006"
	cModule     := "84"
	cMetricName := "TAF" + cAPIName + cComplement
	cUserId     := IIf(Empty(__cUserID), "000000", __cUserID)

	If FindFunction("FWLSPutAsyncInfo")
		FWLSPutAsyncInfo(cIdLog, cUserId, cModule, cMetricName)
	EndIf
	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} XValidRep
	
	@type  Function
	@author 
	@since 
	@version 1.0
	@param 
/*/
//----------------------------------------------------------------------
Function XValidRep(cValTpRep)

	Local cRet as Character

	cRet := ""

	If Len(cValTpRep) == 1 .And. cValTpRep $ ('1|2|3|4|5')
		cRet := cValTpRep
	EndIf	
	
Return (cRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveAltRPT
@type			static function
@description	Armazena os valores da chave do relatório armazenado na V3N antes de 
				serem alterados para que seja possível excluir as informações obsoletas
@author			Melkz Siqueira
@since			31/08/2022
@version		1.0
@param			aAltRPT - Array contendo a chave da V3N antes de ser alterada
/*/
//---------------------------------------------------------------------
Function SaveAltRPT( cIndApu as Character, cPeriodo as Character, cTrabal as Character, cAlias as Character )

	Local aAltRPT as Array
	Local cCPF    as Character
	Local cNome   as Character

	Default cIndApu  := ""
	Default cPeriodo := ""
	Default cTrabal  := ""

	aAltRPT		:= {}
	cCPF		:= ""
	cNome		:= ""


	If cAlias $ "C91" .And. (C91->C91_MV == "1" .Or. Empty(cTrabal))

		cCPF	:= C91->C91_CPF
		cNome 	:= C91->C91_NOME

	ElseIf cAlias $ "T62"

		cCPF := T62->T62_CPF
		cNome 	:= Posicione( "V73", 3, xFilial( "V73" ) + cCPF + "S2400" + "1", "V73_NOMEB" )
		
	ElseIf cAlias $ "C91" .And. C91->C91_ORIEVE == "S2190"

		cCPF 	:= GetADVFVal("T3A", "T3A_CPF", xFilial("T3A") + cTrabal + "1", 3, "", .T.)
		cNome	:= Upper("TRABALHADOR PRELIMINAR") // "TRABALHADOR PRELIMINAR"

	Else

		cCPF 	:= GetADVFVal("C9V", "C9V_CPF", xFilial("C9V") + cTrabal + "1", 2, "", .T.)
		cNome 	:= TAFGetNT1U(cCPF)

		If Empty(cNome)
			cNome := GetADVFVal("C9V", "C9V_NOME", xFilial("C9V") + cTrabal + "1", 2, "", .T.)
		EndIf

	EndIf

	aAltRPT := {cIndApu, cPeriodo, cCPF, cNome}

Return aAltRPT

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoRPTObj
@type			static function
@description	Instancia o objeto oInfoRPT
@author			Melkz Siqueira
@since			16/08/2022
@version		1.0
@param			cIndApu		-	Indicativo de apuração
@param			cPerApu		-	Período de apuração
@param			cCPF		-	CPF do trabalhador
@param			cNome		-	Nome do trabalhador
@param			aAnalitico	-	Array com os dados a serem gravados na V3N
@param			cRecibo		-	Recibo
@param			oInfoRPT	-	Objeto oInfoRPT não instânciado
/*/
//---------------------------------------------------------------------
Function InfoRPTObj( cIndApu as character, cPerApu as character, cCPF as character,; 
					 cNome as character, aAnalitico as array, cRecibo as character, oInfoRPT as object)

	Default aAnalitico := {}
	Default cCPF       := ""
	Default cIndApu    := ""
	Default cNome      := ""
	Default cPerApu    := ""
	Default cRecibo    := ""
	Default oInfoRPT   := Nil
		
	oReport  := IIf(oReport == Nil, TAFSocialReport():New(), oReport)
	oInfoRPT := oReport:oVOReport

	oInfoRPT:SetIndApu(AllTrim(cIndApu))
	oInfoRPT:SetPeriodo(AllTrim(cPerApu))
	oInfoRPT:SetCPF(AllTrim(cCPF))
	oInfoRPT:SetNome(AllTrim(cNome))
	oInfoRPT:SetAnalitico(aAnalitico)
	oInfoRPT:SetRecibo(AllTrim(cRecibo))

Return

/*/{Protheus.doc} CleanCacheFil
	(long_description)
	@type  Function
	@author Alexandre de Lima S.
	@since 18/09/2023
	@version version
	@Limpa variavel de filiais paar refazer cache
	(examples)
	@see (links_or_references)
	/*/
Function CleanCacheFil()
	__aFilCach := {}
Return 

/*/{Protheus.doc} setGlobalHashMapContent
	Seta conteudo em Variaveis Globais de HashMap das Tabelas A ou X, conforme parametrizacao

	@author		Fabio Mendonca
	@since 		16/07/2024
	@version 	1.0
	@param 		cUID			-> UID da Secao de Variaveis Globais HashMap
	@param 		cUKey			-> UKey do conteudo que sera gravado
	@param 		xContent		-> Conteudo a ser gravado
	@param 		cCallerFunction	-> Nome da funcao que realiza a chamada (para fins de registro nos TAFConout)
	@param 		lSaveDirty		-> Indica se deve salvar a informacao sem fazer bloqueio da chave na tabela (modo "Dirty").
	@param 		lArray			-> Indica o conteudo a ser gravado e array. Isso influencia na escolha da tabela para gravacao:
								-> TABELA X armazena dados primarios (Numérico, Caractere, Data e Lógico)
								-> TABELA A armazena lista de valores (Array)
	@return 	Indica se operacao de salvamento na tabela da secao ocorreu com sucesso
	
	@see https://tdn.totvs.com/pages/viewpage.action?pageId=203755846
/*/
Function setGlobalHashMapContent(cUID as Character, cUKey as Character, xContent as Any, cCallerFunction as Character, lSaveDirty as Logical, lArray as Logical) as Logical

	Local lOk			as Logical
	Local cSaveFunction	as Character

	Default	cCallerFunction := ""
	Default lSaveDirty		:= .T.
	Default lArray			:= .T.

	lOk	:= .F.

	cSaveFunction := "VarSet" + IIf(lArray, "A", "X") + IIf(lSaveDirty, "D", "")
	
		If VarSetUID(cUID, .T.) 

			TAFConOut("[" + cCallerFunction + "][cUID:" + cUID + "][cUKey:" + cUKey + "][cSaveFunction:" + cSaveFunction + "] ID da Secao definido com sucesso")

			If VarBeginT(cUID, cUKey)

				TAFConOut("[" + cCallerFunction + "][cUID:" + cUID + "][cUKey:" + cUKey + "][cSaveFunction:" + cSaveFunction + "] Transacao iniciada com sucesso")

				If &(cSaveFunction + "(cUID, cUKey, xContent)")

					TAFConOut("[" + cCallerFunction + "][cUID:" + cUID + "][cUKey:" + cUKey + "][cSaveFunction:" + cSaveFunction + "] Conteúdo gravado com sucesso na tabela A")

				EndIf

				If VarEndT(cUID, cUKey)

					TAFConOut("[" + cCallerFunction + "][cUID:" + cUID + "][cChave:" + cUKey + "][cSaveFunction:" + cSaveFunction + "] Secao e Transacao encerradas com sucesso")
					lOk := .T.

				EndIf

			EndIf

		EndIf
	
Return lOk

/*/{Protheus.doc} getGlobalHashMapContent
	Obtem valor armazenado em Variaveis Globais de HashMap das Tabelas A ou X, conforme parametrizacao
	
	@author 	Fabio Mendonca
	@since 		17/07/2024
	@version 	1.0
	@param 		cUID			-> UID da Secao de Variaveis Globais HashMap
	@param 		cUKey			-> UKey do conteudo que sera obtido
	@param 		cCallerFunction	-> Nome da funcao que realiza a chamada (para fins de registro nos TAFConout)
	@param 		lReadDirty		-> Indica se deve obter a informacao sem fazer bloqueio da chave na tabela (modo "Dirty").
	@param 		lArray			-> Permite identificar baseado no conteudo em qual tabela o dado foi armazenado, conforme abaixo:
								-> TABELA X armazena dados primarios (Numérico, Caractere, Data e Lógico)
								-> TABELA A armazena lista de valores (Array)
	@return  	Conteudo obtido da Variavel Global de HashMap
	
	@see https://tdn.totvs.com/pages/viewpage.action?pageId=203755846
/*/
Function getGlobalHashMapContent(cUID as Character, cUKey as Character, cCallerFunction as Character, lReadDirty as Logical, lArray as Logical) as Any

	Local xContent 		as Any
	Local cReadFunction	as Character

	Default cCallerFunction := ""
	Default lReadDirty		:= .T.
	Default lArray			:= .T.

	xContent 		:= IIf(lArray, {}, "")
	cReadFunction 	:=  "VarGet" + IIf(lArray, "A", "X") + IIf(lReadDirty, "D", "")
	
	If &(cReadFunction + "(cUID, cUKey, @xContent)")
		TAFConOut("[" + cCallerFunction + "][cUID:" + cUID + "][cUKey:" + cUKey + "][cReadFunction:" +  cReadFunction + "] Conteudo recuperado com sucesso")
	EndIf

Return xContent

/*/{Protheus.doc} hasUKeyByUID
	Verifica existencia de UID e UKey

	@author 	Fabio Mendonca
	@since 		17/07/2024
	@version 	1.0
	@param 		cUID	-> UID da Secao de Variaveis Globais HashMap a ser validado
	@param 		cUKey	-> UKey a ser validado, caso se deseje verificar existencia de UKey
	@return 	Indica se ha UID e/ou UKey associado a um HashMap global

	@see https://tdn.totvs.com/pages/viewpage.action?pageId=203755846
/*/
Function hasUKeyByUID(cUID as Character, cUKey as Character) as Logical

	Local lRet			as Logical
	Local aTabAUKeys	as Array
	Local aTabXUKeys	as Array

	Default cUKey	:= ""

	aTabAUKeys		:= {}
	aTabXUKeys		:= {}
	lRet			:= VarIsUID(cUID)

	If lRet .And. !Empty(cUKey) .And. VarGet_A(cUID, @aTabXUKeys, @aTabAUKeys)

		lRet := aScan(aTabAUKeys, {|x| x[1] == cUKey}) .Or. aScan(aTabXUKeys, {|x| x[1] == cUKey})

	EndIf

Return lRet

/*/{Protheus.doc} getFilFromRequestOrCached    
    Obtem lista de filiais com a ressalva de que caso requisicao de filiais tenha vindo vazia, deve buscar cache de listagem de todas as filiais
    autorizadas ao usuario logado conforme filtragem realizada na API de Filiais (WSTAF020)

    @author     Fabio Mendonça
    @since      16/07/2024
    @version    1.0
    @param      aReqBranches 	-> Array com lista de filiais oriundas de requisicao ao WSTAF023
	@param 		cUserId			-> ID do usuário logado
	@param 		cGrpEmp			-> Grupo de Empresas
	@param 		cFilMatriz		-> Filial Matriz
	@param 		cCallerFunction	-> Nome da funcao que realiza a chamada (para fins de registro nos TAFConout)
    @return     Array com filiais a pesquisar, podendo ser de duas fontes:
                1º -> Passadas por parâmetros ao requisitar via WSTAF023
                2º -> Cache de todas as filiais autorizadas ao usuario (o usuario nao requisitar filiais indica que deseja todas as filiais, 
                   	buscando do cache de todas as filiais autorizadas ao usuario)
/*/
Function getFilFromRequestOrCached(aReqBranches as Array, cUserId as Character, cGrpEmp as Character, cFilMatriz as Character,;
								   cCallerFunction as Character) as Array

    Local cUID      	as Character
    Local cUKey     	as Character
	Local cIdFilCache	as Character
    Local aBranches 	as Array

	Default cUserId 		:= ""
	Default cGrpEmp			:= ""
	Default cFilMatriz		:= ""
	Default cCallerFunction	:= ""

	cUID	  	:= ""
	cUKey	  	:= ""
	cIdFilCache	:= cUserId + cGrpEmp + cFilMatriz
    aBranches 	:= {}

	If Findfunction("aWSTAF020GlobalVarIDs")

		cUID	  := aWSTAF020GlobalVarIDs()[1] 				// wstaf020UID
		cUKey	  := aWSTAF020GlobalVarIDs()[2] + cIdFilCache 	// filCodeKey + (cUserId + cGrpEmp + cFilMatriz)

	EndIf


    If Empty(aReqBranches)

        aBranches := getGlobalHashMapContent(cUID, cUKey, cCallerFunction)

    Else

        aBranches := aClone(aReqBranches)

    EndIf   
    
Return aBranches

//--------------------------------------------------------------------
/*/{Protheus.doc} function getIdUserFromRequest
Realiza a busca do id do usuário logado
@author  José Riquelmo/ Melkz Siqueira
@since   10/11/2022
@version 12.1.33
/*/
//--------------------------------------------------------------------
Function getIdUserFromRequest(cAuth as character)

	Local cUserId 	as character
	local oAuth 	as object

	Default cAuth	:= ""
	
	cUserId := '000000'
	oAuth 	:= Nil
	
	cAuth := AllTrim(StrTran(cAuth, "Bearer"))
	
	If FwJWTValid(cAuth, @oAuth)
		
		cUserId := oAuth:PAYLOAD:USERID

	EndIf 

Return cUserId

//-------------------------------------------------------------------
/*/	{Protheus.doc} PctTpInsc

Ajusta a picture conforme o tipo de inscrição informado, sendo:

1 - CNPJ
2 - CPF
4 - CNO

@param  cTipInsc (Tipo de inscrição)
@return cPicture

@author  Rafael de Paula Leme
@since   01/04/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function PctTpInsc(cTipInsc)

	Local cPicture as character

	Default cTipInsc := ""

	If cTipInsc == "1" //CNPJ
		cPicture := "@R! NN.NNN.NNN/NNNN-99"
	ElseIf cTipInsc == "2" //CPF
		cPicture := "@R 999.999.999-99"
	Else //CNO ou Branco
		cPicture := "@!"
	EndIf
	 
	cPicture := cPicture + "%C"

Return cPicture

/*----------------------------------------------------------------------
{Protheus.doc} TafSchdRun
Retorna o Environment que esta rodando o Smart Schedule

@author Jose Felipe
@since 03/07/2025
@return	cEnv 
//----------------------------------------------------------------------*/
Function TafSchdRun()

	Local aEnvs         := {} as Array
	Local cEnv          := "" as character
	Local oSchdInfo  as object
	Local cLibVers := FwLibVersion()
	
	If cLibVers >= "20250224"
		oSchdInfo  := totvs.framework.schedule.information.ScheduleInformation():New()
		aEnvs := oSchdInfo:getEnvironmentsScheduleRunning(2) // Retorna quais Environments tem Smart Schedule rodando
		If Len(aEnvs) > 0
			cEnv := aEnvs[1]
		EndIf
	EndIf

Return cEnv

//-----------------------------------------------------------------------
/*/{Protheus.doc} SimuCpyXml
Função para preparação do ambiente e chamada para processamento da simulação
em XML do evento tributário em segundo plano.

@author Rafael Leme
@since 29/07/2025
@version 1.0
/*/ 
//----------------------------------------------------------------------- 
Function TAFPrepSim(aParams as array)

	Private ALTERA as logical

	Default aParams := {}

	ALTERA := .T.
	
	If !Empty(aParams)

		RpcSetType(3)
		RpcSetEnv(aParams[7], aParams[8],,,"TAF","TAFA433")  

		TAFTaskSim(aParams)
	EndIf

Return
