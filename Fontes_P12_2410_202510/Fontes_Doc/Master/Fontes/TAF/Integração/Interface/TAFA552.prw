#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TAFA552.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552A
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF ( eSocial )
@author			Flavio Lopes Rasta
@since			07/08/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552A()

	If IsMatrizC1E( 2 ) .and. ProtData()
		//Verifica se o ambiente está com todas as configurações para uso da função FWCallApp
		If lCfgPainelTAF( "A" )
			If TAFAlsInDic( "V3J" ) .and. TAFAlsInDic( "V45" )
				FWMsgRun( , { || EraseData() }, STR0001, STR0002 ) //##"Aguarde" ##"Aplicando limpeza das tabelas de requisições"
			EndIf

			CallAppTAF()
		EndIf
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de código que receberá as chamadas JavaScript.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

	Local aContent     as array
	Local aRotinas     as array
	Local cAlias       as character
	Local cChave       as character
	Local cContext     as character
	Local cEvento      as character
	Local cFonte       as character
	Local cIsTAFFull   as character
	Local cJsonCodUser as character
	Local cJsonCompany as character
	Local cJsonContext as character
	Local cJsonTAFFeat as character
	Local cJsonTAFFull as character
	Local cOperation   as character
	Local cTipo        as character
	Local cFilBkp	   as character
	Local nI           as numeric
	Local nIndex       as numeric
	Local nOk          as numeric
	Local lErrFil      as logical
	Local lChangeFil   as logical
	Local lSmartView   as logical
	Local cTafTsi	   as character
	Local cJsonTafTsi  as character
	Local cTafSv   	   as character
	Local cJsonTafSv   as character
	Local cLibVersion  as character
	Local cRuleID      as character
	Local cObject      as character
	Local cPeriod      as character
	Local cTafMit	   as character
	Local cJsonTafMit  as character
	Local nChave       as numeric
	Local cTitulo      as character
	Local lAutomato    as logical
    Local cCode		   as character
    Local cUser		   as character
    Local cModule	   as character
    Local cRoutine 	   as character	
	Private aSX9Rel    as array

	Default cContent   := " "

	aContent     := {}
	aRotinas     := {}
	cAlias       := ""
	cChave       := ""
	cContext     := ""
	cEvento      := ""
	cFonte       := ""
	cIsTAFFull   := "true"
	cJsonCodUser := ""
	cJsonCompany := ""
	cJsonContext := ""
	cJsonTAFFeat := ""
	cJsonTAFFull := ""
	cOperation   := ""
	cTipo        := ""
	cFilBkp		 :=	""
	nI           := 0
	nIndex       := 0
	nOk          := 1
	lErrFil      := .F.
	lChangeFil   := .F.
	aSX9Rel 	 := {}
	cTafTsi		 := "noTsi"
	cJsonTafTsi	 := ""
	cTafSv 	     := "noSv"
	cJsonTafSv   := ""
	cLibVersion  := FWLibVersion()
	lSmartView   := GetRpoRelease() >= '12.1.2310' .and. cLibVersion >= "20231009" .and. totvs.framework.smartview.util.isConfig()
	cRuleID      := ""
	cObject      := ""
	cPeriod      := ""
	cTafMit		 := ""
	cJsonTafMit  := ""
	nChave 		 := 0
	cTitulo      := ""
	lAutomato    := .F.
	cCode		 := "LS006"  
	cUser		 := RetCodUsr()
	cModule	     := "84"     
	cRoutine 	 := "TAFMITREL" 	

	If FWIsInCallStack( "TAFA552A" )
		cContext := "esocial"
	ElseIf FWIsInCallStack( "TAFA552B" )
		cContext := "reinf"
		If TemRegSFT()
			cTafTsi := "tsi"
		EndIf
		//A rotina relatorio financeiro, devera aparecer no painel, havera uma protecao para o seu uso dentro do painel

		if lSmartView
			cTafSv := "smartview"
		endif
		If AliasInDic("T1A") .or. cContent == "Automato_TAFA552_04"
			cTafMit := "mit"
		EndIf
	ElseIf FWIsInCallStack( "TAFA552C" )
		cContext := "gpe"
		cIsTAFFull := "false"
	ElseIf FWIsInCallStack( "TAFA552D" )
		cContext := "labor-process"
		cIsTAFFull := "false"
	ElseIf FWIsInCallStack("TAFA552E")
		cContext := "evolucao"

		If lSmartView
			cTafSv := "smartview"
		EndIf
	ElseIf FWIsInCallStack("TAFA552F")
		cContext := "lalurlacs"
	EndIf

	Do Case

		Case cType == "preLoad"

			cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code" : "' + FWCodFil() + '" }'
			cJsonContext := '{ "context" : "' + cContext + '" }'
			cJsonTAFFull := '{ "tafFull" : "' + cIsTAFFull + '" }'
			cJsonCodUser := '{ "codUser" : "' + RetCodUsr() + '" }'
			cJsonTafTsi  := '{ "tafTsi" : "' + cTafTsi + '" }'
			cJsonTafMit  := '{ "tafMit" : "' + cTafMit + '" }'
			//A rotina relatorio financeiro, devera aparecer no painel, havera uma protecao para o seu uso dentro do painel
			cJsonTafSv   := '{ "tafSv" : "' + cTafSv + '" }'
			cJsonTAFFeat := GetTAFFeatures(lSmartView)

			oWebChannel:AdvPLToJS( "setCompany", cJsonCompany )
			oWebChannel:AdvPLToJS( "setContext", cJsonContext )
			oWebChannel:AdvPLToJS( "setTafTsi", cJsonTafTsi )
			oWebChannel:AdvPLToJS( "setTafSv" , cJsonTafSv )
			oWebChannel:AdvPLToJS( "setTafMit" , cJsonTafMit )
			oWebChannel:AdvPLToJS( "setlIsTafFull", cJsonTAFFull )
			oWebChannel:AdvPLToJS( "setCodUser", cJsonCodUser )
			oWebChannel:AdvPLToJS( "setFeatures", cJsonTAFFeat )

		Case cType == "saveFileZip"

			//Chama função para realizar a cópia dos arquivos para estação
			TafSaveZip(oWebChannel, cContent)

		Case cType == "callTafSmartView"

			//Chama função para realizar a renderizacaod do smartview
			TafSmartView(oWebChannel, cContent)

		Case cType == "TafSVApur"

			//Chama função para realizar a renderizacao do smartview
			TafSVApur(oWebChannel, cContent)

		Case cType == "TafSVCalc"

			//Chama função para realizar a renderizacao do smartview
			TafSVCalc(oWebChannel, cContent)

		Case cType == "TafSVSimulator"

			//Chama função para realizar a renderizacao do smartview
			TafSVSimulator(oWebChannel, cContent)
		
		Case cType == "TafSVMit"

			//Chama função para realizar a renderizacao do smartview
			TafSVMit(oWebChannel, cContent)			
			//Registra o Uso da Rotina no License Server
			FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine)

		Case cType == "execView"

			aContent := StrTokArr( cContent, "|" )

			For nI := 1 to Len( aContent )
				If nI == 1
					cOperation := aContent[nI]
				ElseIf nI == 2
					cEvento  := aContent[nI]
					aRotinas := TAFRotinas( cEvento, 4, .F., 2 )
					cFonte   := aRotinas[1]
					cAlias   := aRotinas[3]
				ElseIf nI == 3
					If cFilAnt <> aContent[nI]
						lErrFil := VldTabTAF(cAlias, 1) != "C" .And. !(FWFilExist( cEmpAnt, aContent[nI] ))
						If !(lErrFil)
							cFilBkp    := cFilAnt
							cFilAnt    := aContent[nI]
							lChangeFil := .T.
						EndIf
					EndIf

					cChave += aContent[nI]
				Else
					If nI <> 4
						cChave += aContent[nI]
					EndIf
				EndIf
			Next nI

			If !lErrFil

				If Len(aRotinas) <> 0

					If cEvento $ 'S-2410|S-2416|S-2418|S-2420'
						nIndex := 2
					Else
						nIndex  := TAFGetIdIndex( cAlias )
					EndIf

					If cOperation == "insert"

						If cEvento $ 'S-2500'
							DBSelectArea( cAlias )
							( cAlias )->( DBSetOrder( nIndex ) )
							TAF608Inc( cAlias, (cAlias)->(Recno()))
						Else
							nOk := FWExecView( STR0020, cFonte, MODEL_OPERATION_INSERT )
						EndIf

					ElseIf cOperation == "update"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							If cEvento = "S-2190" .And. !lLaySimplif
								nOk := TAFVAltEsocial(cAlias, cFonte)
							Else
								nOk := FWExecView( STR0021, cFonte, MODEL_OPERATION_UPDATE )
							EndIf
						EndIf

					ElseIf cOperation == "delete"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							If (Empty(&(( cAlias )->(cAlias + "_PROTUL"))) .And. &(( cAlias )->(cAlias + "_STATUS")) <> "4" .And. !cEvento $ 'S-3000|S-3500' ) .Or. cEvento $ "S-1000|S-1005|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070|S-1080|S-1298|S-1299"
								nOk := FWExecView( STR0022, cFonte, MODEL_OPERATION_DELETE, ,{|| .T. },{|| TafDisableSX9( cAlias ) })
								TafEnableSX9( cAlias )
							Else
								nOk := xTafVExc(cAlias, (cAlias)->(Recno()), 1)
							EndIf
						EndIf

					ElseIf cOperation == "view"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							nOk := FWExecView( STR0023, cFonte, MODEL_OPERATION_VIEW )
						EndIf

					EndIf

				EndIf

				If lChangeFil .And. cFilAnt <> cFilBkp
					cFilAnt := cFilBkp
				EndIf
			EndIf

			If nOk == 0 .Or. nOk == Nil
				oWebChannel:advplToJs( "setFinishExecView", "true" )
			Else
				oWebChannel:advplToJs( "setFinishExecView", "false" )
			EndIf

		Case cType == "execViewMit"

			aContent := StrTokArr( cContent, "|" )

			For nI := 1 to Len( aContent )
				If nI == 1
					cOperation := aContent[nI]
						If cOperation == 'view'
							nOperation := MODEL_OPERATION_VIEW
							cTitulo    := STR0023
						ElseIf cOperation == 'insert'
							nOperation := MODEL_OPERATION_INSERT
							cTitulo    := STR0020
						ElseIf cOperation == 'update'
							nOperation := MODEL_OPERATION_UPDATE
							cTitulo    := STR0021
						ElseIf cOperation == 'delete'
							nOperation := MODEL_OPERATION_DELETE
							cTitulo    := STR0022
						EndIf
				ElseIf nI == 2
					nChave := Val(aContent[nI])
					If aContent[nI] == "Automato"
						lAutomato := .T.
					EndIf
				EndIf
			Next nI

			DbSelectArea("T1A")
			If !(cOperation == 'insert')
				T1A->( DBGoto(nChave) )
			EndIf
			If !lAutomato
				FWExecView( cTitulo, 'TAFA632', nOperation )
			EndIf

			oWebChannel:advplToJs( "setFinishExecView", "true" )

	EndCase

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTAFFeatures
@type			function
@description	Função responsável por verificar todas as features que necessitam de atualização de
@description	binário, lib, etc e retorna um json informando se a feature encontra-se disponível ou não.
@author			Diego Santos
@since			14/07/2020
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function GetTAFFeatures(lSmartView)

	Local cBuildSmart	as character
	Local cBuildAppSrv	as character
	Local cLibVersion	as character
	Local cRet			as character
	Local nX			as numeric
	Local aFeatures		as array

	default lSmartView := .F.

	cBuildSmart		:=	GetBuild( .T. )
	cBuildAppSrv	:=	GetBuild( .F. )
	cLibVersion		:=	FWLibVersion()
	cRet			:=	""
	nX				:=	0
	aFeatures		:=	{}

	//Feature downloadXLS
	If cBuildSmart >= "7.00.191205P-20200504" .and. cBuildAppSrv >= "7.00.191205P-20200629" .and. cLibVersion >= "20200615" .and. FindFunction( "FWDLEXLIST" )
		aAdd( aFeatures, { "downloadXLS", .T., Encode64( "Disponível." ) } )
	Else
		aAdd( aFeatures, { "downloadXLS", .F., Encode64( "Funcionalidade disponível a partir do binário AppServer: 7.00.191205P-20200629, SmartClient: 7.00.191205P-20200504, Lib superior à 15/06/2020 e pacote acumulado do TAF igual ou superior à 09/2020." ) } )
	EndIf

	If ExistStamp(,,"SFT") .and. TafColumnPos("C20_STAMP")
		aAdd( aFeatures, { "tsiStamp", .T., Encode64( STR0030 ) } ) //"Disponível."
	Else
		aAdd( aFeatures, { "tsiStamp", .F., Encode64( STR0031 ) } ) //"Foi identificado que o TSI ainda não está configurado em seu ambiente. Certifique-se de que seu ambiente está atualizado e se os campos STAMPs foram criados após a execução da rotina da wizard de configuração TAF."
	EndIf

	if lSmartView
		aAdd( aFeatures, { "smartView", .T., Encode64( STR0030 ) } ) //"Disponível."
	endif

	//Exemplo de json esperado
	//'{
	//	"feature1" : { "access" : true, "message" : "Teste1" },
	//	"feature2" : { "access" : false, "message" : "Teste2" },
	//	"feature3" : { "access" : false, "message" : "Teste3" }
	//}'

	cRet += "{ "

	For nX := 1 to Len( aFeatures )
		cRet += '"' + aFeatures[nX,1] + '" : { "access" : ' + Iif( aFeatures[nX,2], "true", "false" ) + ', "message" : "' + aFeatures[nX,3] + '" }'

		If Len( aFeatures ) > 1 .and. nX <> Len( aFeatures )
			cRet += ", "
		EndIf
	Next nX

	cRet += " }"

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} EraseData
@type			function
@description	Exclui os dados voláteis dos relatórios.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function EraseData()

	Local cQuery	as character
	Local cDate		as character

	cQuery	:=	""
	cDate	:=	DToS( dDataBase )

	cQuery := "DELETE FROM " + RetSqlName( "V45" ) + " "
	cQuery += "WHERE V45_ID IN ( SELECT V3J_ID FROM " + RetSqlName( "V3J" ) + " WHERE V3J_DTREQ < '" + cDate + "' )

	TCSQLExec( cQuery )

	cQuery := "DELETE FROM " + RetSqlName( "V3J" ) + " "
	cQuery += "WHERE V3J_DTREQ < '" + cDate + "' "

	TCSQLExec( cQuery )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552B
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF ( Reinf ).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552B()

	If IsMatrizC1E( 1 ) .and. ProtData()
		//Verifica se o ambiente está com todas as configurações para uso da função FWCallApp
		If lCfgPainelTAF( "B" )
			CallAppTAF()
		EndIf
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552C
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF ( GPE ).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552C()

//Verifica se o ambiente está com todas as configurações para uso da função FWCallApp
	If lCfgPainelTAF( "C" )
		CallAppTAF()
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552D
@type			function
@description	Programa de inicialização do Portal PO UI do TAF ( GPE - Processos Trabalhistas ).
@author			Felipe C. Seolin
@since			28/12/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552D()

//Verifica se o ambiente está com todas as configurações para uso da função FWCallApp
	If lCfgPainelTAF( "D" )
		CallAppTAF()
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} IsMatrizC1E
@type			function
@description	Verifica se a Filial logada é a Filial Matriz para executar as apurações.
@param			nAmbiente	-	1 para Reinf e 2 para eSocial
@return			lRet		-	Retorna se a Filial logada está cadastrada como Matriz
@author			Karen Honda
@since			10/02/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function IsMatrizC1E( nAmbiente as numeric ) as logical

	Local cCNPJFil   as character
	Local nOpcAviso  as numeric
	Local lMatriz    as logical
	Local lReinfAtu  as logical
	Local lTransFil  as logical
	Local lNoVldEst  as logical
	Local lOkC8E     as logical
	Local lRet       as logical
	Local lWsLoadFil as logical
	Local cCodFil    as character

	Default nAmbiente	:=	1

	cCNPJFil	:=	""
	lMatriz		:=	.F.
	lReinfAtu	:=	.F.
	lRet		:=	.F.
	lWsLoadFil	:=  IsInCallStack("wsLoadFil")

	DBSelectArea( "C1E" )
	C1E->( DBSetOrder( 3 ) )
	cCodFil := IIF(lWsLoadFil .AND. nAmbiente == 1 , AllTrim(cFilAnt), AllTrim( SM0->M0_CODFIL))

	If C1E->( DBSeek( xFilial( "C1E" ) + PadR( cCodFil, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lMatriz := .T.
		EndIf

		cCNPJFil := AllTrim( Posicione( "SM0", 1, cEmpAnt + C1E->C1E_FILTAF, "M0_CGC" ) )
	EndIf

	If !lWsLoadFil
		If nAmbiente == 1 //Ambiente Reinf
			If lMatriz
				lReinfAtu := TAFColumnPos( "V0W_CNOEST" ) .and. !X3Obrigat( "V0B_PGTOS" )
			EndIf

			If lMatriz .and. Len( cCNPJFil ) >= 11 .and. lReinfAtu
				lRet := .T.
			Else
				lRet := .F.

				If !lMatriz
					Aviso( STR0005, STR0006, { STR0007 }, 2 ) //##"Rotina indisponível" ##"Esta funcionalidade está disponível apenas para a filial marcada como matriz no complemento cadastral." ##"Sair"
				ElseIf Len( cCNPJFil ) < 11
					Aviso( STR0005, STR0008, { STR0007 }, 2 ) //##"Rotina indisponível" ##"O código de inscrição ( CNPJ ) da matriz não está preenchido no cadastro de empresas." ##"Sair"
				ElseIf !lReinfAtu
					nOpcAviso := Aviso( STR0009, STR0010 + CRLF + CRLF +; //##"Ambiente desatualizado!" ##"O ambiente do TAF encontra-se desatualizado com relação as alterações referentes ao layout 1.04.00 da EFD Reinf."
					STR0011 + CRLF + CRLF +; //"As rotinas disponíveis no repositório de dados ( RPO ) estão mais atualizadas do que o dicionário de dados."
					STR0012 + CRLF + CRLF +; //"Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último arquivo diferencial disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF."
					STR0013 + CRLF +; //"**IMPORTANTE**"
					STR0014, { STR0007, STR0015 }, 3 ) //##"No caso do arquivo diferencial referente ao layout 1.4 da EFD Reinf já ter sido executado, siga as instruções do FAQ." ##"Sair" ##"FAQ"

					If nOpcAviso == 2 //FAQ
						ShellExecute( "Open", "http://tdn.totvs.com/x/y4DlGg", "", "", 1 )
					EndIf
				EndIf
			EndIf
		Else //Ambiente eSocial
			lTransFil := SuperGetMv( "MV_TAFTFIL", .F., .F. ) //Permite que seja realizado a transmissão pela Filial
			lNoVldEst := SuperGetMv( "MV_TAFVLUF", .F., .F. ) //Permite que seja realizado a integração de códigos de municípios incompatíveis com a UF
			lOkC8E := .T.

			DBSelectArea( "C8E" )
			C8E->( DBSetOrder( 2 ) )
			C8E->( DBGoTop() )
			If C8E->( Eof() )
				lOkC8E := .F.
			EndIf

			If ( lMatriz .or. lTransFil ) .and. TAFAlsInDic( "T0X" ) .and. TAFColumnPos( "T0X_USER" ) .and. lOkC8E .and. !lNoVldEst
				lRet := .T.
			Else
				lRet := .F.

				If !lMatriz .and. !lTransFil
					Aviso( STR0005, STR0006, { STR0007 }, 2 ) //##"Rotina indisponível" ##"Esta funcionalidade está disponível apenas para a filial marcada como matriz no complemento cadastral." ##"Sair"
				ElseIf !lOkC8E
					Aviso( STR0005, STR0017, { STR0007 }, 2 ) //##"Rotina indisponível" ##"Autocontidas desatualizadas. É necessário executar a Wizard de Configuração do TAF e a atualização das tabelas autocontidas para o correto funcionamento da aplicação." ##"Sair"
				ElseIf lNoVldEst
					Aviso( STR0005, STR0018, { STR0007 }, 2 ) //##"Rotina indisponível" ##"Não é permitido realizar a transmissão de eventos com o parâmetro MV_TAFVLUF habilitado. Este parâmetro desabilita a validação do código de município e pode gerar inconsistências nos envios de eventos relativos ao trabalhador, o mesmo deve ser utilizado somente para a carga de arquivos XMLs na rotina de migração." ##"Sair"
				Else
					Aviso( STR0005, STR0019, { STR0007 }, 2 ) //##"Rotina indisponível" ##"Dicionário de dados desatualizado, é necessário que as atualizações de dicionário do layout 2.04.01 estejam aplicadas para o correto funcionamento da aplicação." ##"Sair"
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRet )


//---------------------------------------------------------------------
/*/{Protheus.doc} lCfgPainelTAF
@type			function
@description	Verifica se o ambiente está com todos as config para uso da função FWCallApp e apresenta msg caso não estiver configurado
@param			cRotina   	-	"A" - TAFA552A, "B" - TAFA552B, "C" - TAFA552C, "E" - TAFA552E - Utilizar para futuras validações
@return			lRet		-	Retorna se ambiente está corretamente configurado
@author			Renan Gomes
@since			07/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function lCfgPainelTAF(cRotina,cBuild)

	Local lMPP		as logical
	Local lREST		as logical
	Local lHTTP		as logical
	Local lConfig	as logical
	Local lRet	    as logical
	Local lAutomato as logical

	lMPP	  := .F.
	lREST	  := .F.
	lHTTP	  := .F.
	lConfig	  := .F.
	lRet      := .F.
	lAutomato := IsBlind()

	Default cRotina := ""
	Default cBuild  := GetBuild()

	If cBuild >= "7.00.170117A-20190628" .and. FWLibVersion() >= "20200325"
		lMPP	:= Iif( FindFunction( "AmIOnRestEnv" ), AmIOnRestEnv(), .F. )
		lREST	:= !Empty( GetNewPar( "MV_BACKEND", "" ) )
		lHTTP	:= !Empty( GetNewPar( "MV_GCTPURL", "" ) )
		lConfig	:= TAFVldRP( .F. )

		If lMPP .or. ( lREST .and. lHTTP .and. lConfig )
			lRet := .T.
		Else
			If FWIsAdmin( __cUserID ) .and. !lAutomato .and. !IsInCallStack('ExtFisxTaf') //Se usuário for ADM ou tiver no grupo de adm e não tiver o ExtFisxTaf na pilha de chamada, mostro tela de configurações
				If TAFFUTPAR()
					lRet := .T.
				EndIf
			Else
				MsgAlert( STR0003 ) //"As configurações para o funcionamento dos Paineis em POUI não foram realizadas. Contate o administrador do sistema."
			EndIf
		EndIf
	Else
		MsgAlert( STR0004 ) //"Para utilizar as funcionalidades dos Paineis em POUI você deve atualizar o seu sistema para uma build 64 bits."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSaveZip
@type			function
@description	Chama cGetFile para selecionar onde irão ser copiados os arquivos zip
@param			oWebChannel    - Clase WebChannel
@param			cContent       - Json em formato de string com os arquivos que deverão ser copiados

@return			lRet		-	Retorna se conseguiu copiar
@author			Renan Gomes
@since			22/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TafSaveZip(oWebChannel, cContent)
	Local cCaminho  := ""
	Local lRet 		:= .F.
	Local lWebApp	:= GetRemoteType() == 5
	Local lJob		:= isBlind()

	//Se for WEBAPP, mando o diretório como "\" e as funções de cópia salvam no users\downloads
	If lJob .or. lWebApp
		cCaminho := "\"
	else
		cCaminho := cGetFile( "",STR0024, 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY + GETF_NETWORKDRIVE, .F. )
	Endif

	if(!Empty(cCaminho))
		oJson := JsonObject():New()
		lRet := ValType(oJson:FromJson(cContent)) <> "C"
		if !lRet
			oWebChannel:AdvplToJs("retSaveFileZip", STR0025)
		else
			lRet := TafCpyZip(oJson,cCaminho)
			if lRet
				if lWebApp
					oWebChannel:advplToJs( "retSaveFileZip", STR0026)
				else
					oWebChannel:advplToJs( "retSaveFileZip", STR0027 +cCaminho)
				Endif
			Else
				oWebChannel:advplToJs( "retSaveFileZip", STR0028 )
			Endif
		Endif
	else
		oWebChannel:advplToJs( "retSaveFileZip", STR0029 )
	Endif
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSmartView
@type		 static function
@description Chama callTReports para selecionar as opções presentes no objeto de negocio 
			 (visao, tabela dinâmica ou relatorio)

@param	oWebChannel - Clase WebChannel
@param	cContent - nome do objeto de negocio em tlpp
		
@retur	lRet -	Retorna se foi possivel executar o smartview
@autho	Denis Souza
@since	04/10/2023
@versi	1.0
/*/
//---------------------------------------------------------------------
Static function TafSmartView(oWebChannel, cContent)

	local lRet   := .F. as logical
	local cError := ""  as character
	local cMsg	 := ""  as character

	default oWebChannel := nil
	default cContent 	:= ''

	lConfig := totvs.framework.smartview.util.isConfig()

//1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
//2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
//3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
//4º parâmetro = Informações de impressão
//5º parâmetro = Parâmetros do relatório
//6º parâmetro = Indica se executa em job
//7º parâmetro = Indica se exibe os parâmetros para preenchimento
//8º parâmetro = Indica se exibe o wizard de configuração do Smart View
//9º parâmetro = Erro da execução
	if lConfig
		lRet := totvs.framework.treports.callTReports(cContent,/*2*/,/*3*/,/*4*/,/*5*/,.F.,/*7*/,.T.,@cError)
	endif

	cMsg := iif(!lConfig,"Falha ao acessar a configuração do SmartView","Smartview possui configuração")
	cMsg += iif(!Empty(cError),", foi encontrado a seguinte falha: " + cError + ". " ,". " )
	cMsg += iif(lRet,"Êxito na geração.", "Falha na geração.")

	oWebChannel:AdvplToJs("retTafSmartView", EncodeUTF8(cMsg) )

return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafCpyZip
@type			function
@description	Copia arquivos do protheus_data para máquina local do usuário
@param			oJson    - JSON com os caminhos zipados
@param			cCaminho - Caminho local onde deverá ser salvado os arquivos 
@return			lRet		-	Retorna se conseguiu copiar
@author			Renan Gomes
@since			22/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TafCpyZip(oJson,cCaminho)
	Local nFile 	:= 0
	Local lRetCopy  := .t.

	//Copio arquivos para máquina locaL e deleto arquivo
	for nFile := 1 to len(oJson['aFiles'])
		//Se der algum erro para de copiar os arquivos,mas deleto arquivo da protheus_Data
		If lRetCopy
			lRetCopy := CpyS2T(oJson['aFiles'][nFile],cCaminho,.F.,.F.) //Adicionado o parametro .F. para copiar arquivo da forma certa
		Endif
		FErase(oJson['aFiles'][nFile])
	next

Return lRetCopy

//---------------------------------------------------------------------
/*/{Protheus.doc} CallAppTAF
@type			function
@description	Programa de inicialização do Portal PO UI do TAF de acordo
@description	com Release, por conta da garantia estendida da Release 12.1.27.
@author			Felipe C. Seolin
@since			09/02/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function CallAppTAF()

	If GetRPORelease() <= "12.1.027"
		FWCallApp( "TAFA612" )
	Else
		FWCallApp( "TAFA552" )
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552E
@type			function
@description	Programa de inicialização do Portal PO UI do TAF (Evolução)
@author			Melkz Siqueira
@since			15/02/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552E()

	// Parâmetro MV_TAFDEV criado para uso interno do time TAF Evolução, para que seja possível acessar o painel antes do seu lançamento
	If SuperGetMv("MV_TAFDEV",, .F.) // .or. GetRPORelease() == "12.1.2410"
		If ProtData()
			If lCfgPainelTAF("E")
				CallAppTAF()
			EndIf
		EndIf

		Return
	EndIf

	FWAlertInfo(STR0032 + CRLF + CRLF + STR0033, STR0034) // #Prezado cliente, // "Estamos construindo uma nova experiência para as Apurações no TAF através do Painel de Apurações, este item está em construção e estará disponível em breve!" // "Atenção!"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552F
@type			function
@description	Programa de inicialização do Lalur e Lacs.
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552F()

	If IsMatrizC1E( 1 ) .and. ProtData()
		If lCfgPainelTAF("F")
			CallAppTAF()
		EndIf
	EndIf

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} TemRegSE2

Verifica a existência de registros na tabela SE2 para habilitar o menu FIN x TAF
no painel reinf

@Author Rafael de Paula Leme	
@Since 16/02/2024
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TemRegSE2()

	Local lRet as Logical

	lRet := .F.

	If AliasInDic("SE2")
		If TCCanOpen(RetSqlname('SE2'))
			SE2->(DBGoTop())
			If SE2->(!Eof())
				lRet :=	.T.
			Else
				lRet :=	.F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSVApur
@type		 static function
@description Chama callSmartView() para selecionar as opções presentes no objeto de negocio 
			 (visao, tabela dinâmica ou relatorio)
			 Função utilizada internamente no painel de apuração, posicionado na regra e período selecionados

@param	oWebChannel - Clase WebChannel
@param	cContent - nome do objeto de negocio em tlpp
		
@author		Juliana Mellão
@since		18/07/2024
@version	1.0
/*/
//---------------------------------------------------------------------
Function TafSVApur(oWebChannel, cContent)

	Local cMsg	    := "" as character
	Local oSmartView      as Object
	Local aContent  := {} as array
	Local cObject 	:= "" as character
	Local cRuleID 	:= "" as character
	Local cPeriod	:= "" as character
	Local cPerg     := "TAFTR00012" as character
	Local nI        := 0  as numeric

	Default oWebChannel := nil
	Default cContent 	:= ''

	aContent := StrTokArr( cContent, "|" )

	For nI := 1 to Len( aContent )
		If nI == 1
			cObject  := aContent[1]
		ElseIf nI == 2
			cRuleID  := aContent[2]
		Else
			cPeriod  := aContent[3]
		EndIf
	Next

	lConfig := totvs.framework.smartview.util.isConfig()

	If lConfig .and. Len(aContent) <> 0
		If FWSX1Util():ExistPergunte(cPerg)
			oSmartView := totvs.framework.smartview.callSmartView():new(cObject)
			oSmartView:setParam("MV_PAR01", cRuleID, "Hidden")
			oSmartView:setParam("MV_PAR02", cPeriod, "Hidden")
			// Força a definição dos parâmetros
			oSmartView:setForceParams(.T.)
			oSmartView:executeSmartView()

			cMsg := oSmartView:getError()

			oSmartView:destroy()
			FwFreeObj(oSmartView)
		Else
			cMsg := STR0035 + cPerg
			TAFConOut(cMsg)
		EndIf

		If cMsg != ""
			TAFConOut(cMsg)
		EndIf
	Else
		cMsg:= STR0036
	Endif

	oWebChannel:AdvplToJs("retTafSmartView", cMsg)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSVCalc
@type		 static function
@description Chama callSmartView para selecionar as opções presentes no objeto de negocio 
			 (visao, tabela dinâmica ou relatorio)
			 Função utilizada no Painel de Apuração (Menu SmartView)

@param	oWebChannel - Clase WebChannel
@param	cContent - nome do objeto de negocio em tlpp
		
@author	Juliana Mellão
@since	22/07/2024
@version	1.0
/*/
//---------------------------------------------------------------------
Static Function TafSVCalc(oWebChannel, cContent)

	Local oSmartView     as Object
	Local cMsg    := ""  as character
	Local cPerg   := "TAFTR00011"  as character

	Default oWebChannel := nil
	Default cContent 	:= ""

	lConfig := totvs.framework.smartview.util.isConfig()

	If lConfig
		If FWSX1Util():ExistPergunte(cPerg)
			oSmartView := totvs.framework.smartview.callSmartView():new(cContent)
			oSmartView:executeSmartView()

			cMsg := oSmartView:getError()

			oSmartView:destroy()
			FwFreeObj(oSmartView)
		Else
			cMsg := STR0035 + cPerg
			TAFConOut(cMsg)
		EndIf

		If cMsg != ""
			TAFConOut(cMsg)
		EndIf
	Else
		cMsg:= STR0036
	EndIf

	oWebChannel:AdvplToJs("retTafSmartView", cMsg )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} TafSVSimulator
@type		 static function
@description Chama callSmartView para selecionar as opções presentes no objeto de negocio 
			 (visao, tabela dinâmica ou relatorio)
			 Função utilizada no Painel de Apuração (Menu SmartView)

@param	oWebChannel - Clase WebChannel
@param	cContent - nome do objeto de negocio em tlpp
		
@author José Riquelmo
@since	19/08/2024
@version	1.0
/*/
//---------------------------------------------------------------------
Static Function TafSVSimulator(oWebChannel, cContent)

	Local oSmartView	:= Nil 			as object
	Local cMsg			:= ""  			as character
	Local cPerg			:= "TAFTR00014"	as character

	Default oWebChannel := nil
	Default cContent 	:= ""

	If totvs.framework.smartview.util.isConfig()
		If FWSX1Util():ExistPergunte(cPerg)
			oSmartView := totvs.framework.smartview.callSmartView():new(cContent)

			oSmartView:executeSmartView()

			cMsg := oSmartView:getError()

			oSmartView:destroy()
			FwFreeObj(oSmartView)
		Else
			cMsg := STR0035 + cPerg

			TAFConOut(cMsg)
		EndIf

		If cMsg != ""
			TAFConOut(cMsg)
		EndIf
	Else
		cMsg := STR0036
	EndIf

	oWebChannel:AdvplToJs("retTafSmartView", cMsg)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} TafSVMit
@type		 static function
@description Chama callSmartView() para selecionar as opções presentes no objeto de negocio 
			 (visao, tabela dinâmica ou relatorio)
			 Função utilizada internamente no painel de apuração, posicionado na regra e período selecionados

@param	oWebChannel - Clase WebChannel
@param	cContent - nome do objeto de negocio em tlpp
		
@author		Wesley Matos
@since		11/03/2025
@version	1.0
/*/
//---------------------------------------------------------------------
Function TafSVMit(oWebChannel, cContent)

	Local cMsg	     := ""  as character
	Local oSmartView := nil as Object
	Local aContent   := {}  as array
	Local cObject 	 := ""  as character
	Local cPeriod	 := ""  as character
	Local cPerg      := ""  as character
	Local nI         := 0   as numeric
	Local lConfig    := .F. as logical

	Default oWebChannel := nil
	Default cContent 	:= ''

	aContent := StrTokArr( cContent, "|" )
	cPerg 	 := "TAFTR00015"

	For nI := 1 to Len( aContent )
		If nI == 1
			cObject  := aContent[1]
		ElseIf nI == 2
			cPeriod  := aContent[2]
		EndIf
	Next nI

	lConfig := totvs.framework.smartview.util.isConfig()

	If cPeriod == 'advpr' //Chamada pelo caso de teste
		lConfig := .F.
	EndIf

	If lConfig .and. Len(aContent) <> 0
		If FWSX1Util():ExistPergunte(cPerg)
			oSmartView := totvs.framework.smartview.callSmartView():new(cObject)
			oSmartView:setParam("MV_PAR01", cPeriod, "Disabled")
			//Força a definição dos parâmetros
			oSmartView:setForceParams(.T.)
			oSmartView:executeSmartView()

			cMsg := oSmartView:getError()

			oSmartView:destroy()
			FwFreeObj(oSmartView)
		Else
			cMsg := STR0035 + cPerg
			TAFConOut(cMsg)
		EndIf

		If cMsg != ""
			TAFConOut(cMsg)
		EndIf
	Else
		cMsg:= STR0036
	Endif

	oWebChannel:AdvplToJs("retTafSmartView", cMsg)

Return
