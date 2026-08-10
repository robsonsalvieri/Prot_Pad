#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TAFLOAD.CH"

Static cEnter := Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLoad
Função chamada na inicialização do ambiente do TAF

@Author Rodrigo Aguilar
@Since 23/03/2015
@Version 1.1
/*/
//-------------------------------------------------------------------
Function TAFLoad()

	Local lFindClass	:=	FindFunction( "TAFFindClass" ) .and. TAFFindClass( "FWCSSTools" )
	Local lSmart		:=	Iif( lFindClass, FWCSSTools():GetInterfaceCSSType() == 5 .or. GetRemoteType() == REMOTE_HTML, .F. )
	Local lMPP			:=	.F.
	Local lREST			:=	.F.
	Local lHTTP			:=	.F.
	Local lConfig		:=	.F.

	If FindFunction("TAFRestIni")
		TAFRestIni()
	EndIf

	If FindFunction( "TAFAtualizado" ) .and. TAFAtualizado()

		TAFInit()

		If !FWIsInCallStack( "FTAFAUTCON" ) .and. GetBuild() >= "7.00.170117A-20190628" .and. !lSmart
			if FindFunction( "AmIOnRestEnv" )
				lMPP	:= AmIOnRestEnv()
			else
				lMPP	:= .f.
			Endif
			lREST	:= !Empty( GetNewPar( "MV_BACKEND", "" ) )
			lHTTP	:= !Empty( GetNewPar( "MV_GCTPURL", "" ) )
			lConfig	:= TAFVldRP( .F. )

			If !lMPP .and. ( !lREST .or. !lHTTP .or. !lConfig )
				TAFFUTPAR()
			EndIf
		EndIf
	Else
		Final()
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FCarrAutoC

Função principal para chamar a função que realiza a carga nas tabela
auto-contidas.

@Param		cError		-	Variável que armazena o erro que ocorreu
oProcess	-	Objeto de controle do processamento
aEmpresas	-	Array com as empresas / filiais

@Author	Rodrigo Aguilar
@Since		23/03/2015
@Version	1.1
/*/
//-------------------------------------------------------------------
Static Function FCarrAutoC( cError, oProcess, aEmpresas, lAutomato )

	Local nI		:=	0
	Local aEmpFil	:=	{}
	Local lRet		:=	.F.

	Default lAutomato	:=	.F.

	For nI := 1 to Len( aEmpresas )
		If aEmpresas[nI,1]
			aAdd( aEmpFil, { aEmpresas[nI,2], aEmpresas[nI,3], aEmpresas[nI,4] } )
		EndIf
	Next nI

	lRet := FTafAutCon( aEmpFil, @oProcess, @cError, lAutomato, lAutomato )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FConectTAF
Função criada para realizar a conexão com a tabela TAFST1

@Param	cMVTafTali - Alias de Conexão
cMVTafTDB  - Banco da Conexão
nMVTafPort - Porta da Conexão

@author Rodrigo Aguilar
@since 27/03/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FConectTAF( cMVTafTali, cMVTafTDB, nMVTafPort, lEncConn, nHdlLink, lTcLink, aOrigem )
	Local lConect   := .F.
	Local aTopInfo  := FWGetTopInfo()
	Local cDBFile := ""

	Default lEncConn := .T.
	Default nHdlLink := 0
	Default lTcLink  := .F.
	Default aOrigem  := {}

	// Para ambiente onde o TAF esta como um modulo e a instancia do SGBD eh a mesma do ERP
	If !lTcLink .And. ( allTrim( upper( cMVTafTali ) ) == alltrim( upper( aTopInfo[ 5 ] ) ) .and. allTrim( upper( cMVTafTDB ) ) == alltrim( upper( aTopInfo[4] ) ) .and. ( nMVTafPort == 0 .or. nMVTafPort == aTopInfo[ 3 ] ) )
		lConect   := .T.
		nHdlLink  := -9999999	//Tratamento especifico para nao dar TCUNLICK quanto entrar neste IF
	Else
		cDBFile   := cMVTafTDB + "/" + cMVTafTali

		//-------------------------------------------------------------------------
		// Tratamento para obter a porta, devido ambiente com DBAccess distribuido
		//-------------------------------------------------------------------------
		If nMvTAFPort == 0
			nMvTAFPort := aTopInfo[03]
		EndIf

		//Verifica se foi possível realizar a conexão com o banco do ERP para a tabela TAFST1
		nHdlLink := TcLink( cDBFile, aTopInfo[01], nMVTafPort )
		if nHdlLink >= 0
			lConect := .T.

			//encerra a conexão
			if lEncConn
				TCUnlink( nHdlLink )
			else
				TCSETCONN( nHdlLink )
			endif

		else
			//Se enviado processo novamente a função para fazer o TcLink no caso de falha
			if len( aOrigem ) > 0
				FConectTAF( aOrigem[2], aOrigem[3], aOrigem[6], .T., 0, .T. )
			endif
		endif
	EndIf

Return ( lConect )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuSx6Taf
Função criada para atualizar o dicionário de dados

@Param	lUsaIntTaf - Indica se usuário utiliza integração banco a banco
cMVTafTali - Alias de Conexão com a TAFST1
cMVTafTDB  - Banco da tabela TAFST1
nMVTafPort - Porta do Top para conexão com a TAFST1
lOpenWiz   - Informa se a Wizard de configuração deve ser executada

@author Rodrigo Aguilar
@since 27/03/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FAtuSx6Taf( lUsaIntTaf, cMVTafTali, cMVTafTDB, nMVTafPort, aEmpresas )
	Local nX := 0

	For nX := 1 To Len(aEmpresas)
		If aEmpresas[nX,1]
			// Define o ambiente
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv( aEmpresas[nX,2] , aEmpresas[nX,3] , , , 'TAF',"TAFLOAD")

			PutMv('MV_TAFINT', IIF( lUsaIntTaf, '.T.', '.F.' ))

			If lUsaIntTaf
				PutMv('MV_TAFTALI', cMVTafTali)

				PutMv('MV_TAFTDB', cMVTafTDB)

				PutMv('MV_TAFPORT', Alltrim( Str( nMVTafPort ) ) )
			Endif
		EndIf
	Next nX

Return ( nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuTabSD
Realiza a alteração das tabelas sem dicionário de dados de acordo com a
estrutura definida na função xTAFGetStru()

@Param	cTable - Tabela a ser alterada 
cError - Variável para controle do erro

@author Rodrigo Aguilar
@since 27/03/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FAtuTabSD( cTable, cError )

	Local cIndice := ''

	Local cOrd    := '00'

	Local nX, nY  	 := 0

	Local lRet        := .F.
	Local lBuildIndex := .F.

	Local aCampos  := {}
	Local aIndices := {}
	Local cErrDes	 := ""
	Local cErrStk  := ""
	Local cArqErro := ""
	Local oLError  := ErrorBlock({|e| cErrDes := e:Description, cErrStk := e:ErrorStack})

	BEGIN SEQUENCE

		//Tratamento pois essas tabelas tem o complemento da empresa no nome
		//e não em sua estrutura na função xTAFGetStru
		If ( "TAFSPED" $ cTable .or. "TAFECF" $ cTable ) .and. At( "_", cTable ) > 0
			aStruct := xTAFGetStru( SubStr( cTable, 1, At( "_", cTable ) - 1 ) )
		Else
			aStruct := xTAFGetStru( cTable )
		EndIf

		//Neste momento estou alimentando o array aIndices com os indices da tabela que
		//devem ser criados, ja no formato correto
		if ( !Empty( aStruct ) )

			//Busca a Estrutura de Campos Nova
			aCampos := aStruct[1]

			//Varre o Array de Indices
			for nX := 1 to len( aStruct[2] )

				cIndice   := ''

				for nY := 1 To Len( aStruct[2][nX] )
					cIndice += aStruct[2][nX][nY] + '+'
				next

				//Retira o ultimo '+'
				cIndice := SubStr( cIndice, 1,  Len( cIndice ) -1 )

				//Alimenta o Array com os indices necessários para criação
				aAdd( aIndices, cIndice )

			next nX

			//Tratamento pois essas tabelas tem o complemento da empresa no nome
			If cTable == "TAFSPED" .or. cTable == "TAFECF"
				cTable := cTable + "_" + cEmpAnt
			EndIf

			//Atualiza a tabela no Top
			TcRefresh( cTable )

			//Verifica se a tabela já existe no BD
			if !MSFile( RetArq( __CRDD, cTable, .T. ), ,__CRDD )

				If Len(aCampos) > 0
					TAFConOut( "Criando Tabela " + cTable )

					//Prepara o banco para criação da tabela
					TcCommit( 5, .T. )

					TcInternal( 30 , "AUTORECNO" )
					TcInternal( 25 , "CLOB" )

					TAFConOut( __CRDD )
					//Realiza a criação da tabela
					DBCreate( cTable, aCampos, __CRDD )

					//Finaliza o banco após criação da tabela
					TcCommit( 5, .F. )

					TcInternal( 30 , "OFF" )
					TcInternal( 25 , "OFF" )

					TAFConOut( "Tabela " + cTable + " criada com Sucesso!" )
				Else
					TAFConOut( "Tabela " + cTable + " não criada, erro na estrutura" )
					cError := "Tabela " + cTable + " não criada, erro na estrutura"
				EndIf

				//Tabela Já existe no BD
			else

				//Abre tabela em modo exclusivo para buscar a sua estrutura atual
				Use &( cTable ) Alias &( cTable ) EXCLUSIVE NEW Via __CRDD

				if !NetErr()
					aArqStru := dbStruct()

					//Encerra a conexão para que seja possivel realizar a alteração de estrutura
					(cTable)->( dbCloseArea() )

					//Indica que deve realizar a criação de indices
					lBuildIndex := .T.

					TAFConOut("Realizando alteracao na Tabela " + cTable + " !")

					TcInternal( 25, "CLOB" )

					//Realiza a alteração na tabela
					If !TcAlter( cTable, aArqStru, aCampos )
						cError := 'Alter table in ' + cTable + ' is not possible!'
						TAFConOut( cError )
					EndIf

					TcInternal( 25, "OFF" )

					TAFConOut("Finalizada a alteracao !")
				else

					cError := ' Nao foi possível abrir ' + cTable + ' em modo Exclusivo '
				endif
			EndIf

			//Verifica se não ocorreu erro no processamento acima
			if empty( cError )

				//Verifica se os indices ja existem na tabela
				if "ORACLE" $ Upper(TcGetDB())
					cOrd := "0"

				else
					cOrd := "00"

				endif

				For nX := 1 To Len( aIndices )

					cOrd     := Soma1( cOrd )
					cOrdName := RetArq( __CRDD, cTable + cOrd, .F. )

					If ( !MsFile( cTable, cOrdName, __CRDD ) )
						lBuildIndex := .T.
						Exit
					EndIf

				Next nX

				//Criacao de indices conforme definicao
				If lBuildIndex

					//Abre a tabela
					Use &( cTable ) Alias &( cTable ) EXCLUSIVE NEW Via __CRDD

					if !NetErr()

						(cTable)->( dbClearIndex() )

						If __CRDD == "TOPCONN"

							//Deleta os indices da tabela para posterior criação com os novos
							//indices

							if "ORACLE" $ Upper(TcGetDB())
								cOrd := "0"

							else
								cOrd := "00"

							endif

							For nX := 1 To Len( aIndices )

								cOrd     := Soma1( cOrd )
								cOrdName := cTable + cOrd

								If ( TcCanOpen( cTable, cOrdName ) )

									If "MYSQL" $ Upper(TcGetDB())
										cQuery := 'DROP INDEX ' + cOrdName + ' ON ' + cTable

									Else
										If Upper(TcGetDB()) $ "INFORMIX|ORACLE"
											cQuery := 'DROP INDEX ' + cOrdName
										Else
											cQuery := 'DROP INDEX ' + cTable + '.' + cOrdName
										EndIf

									EndIf

									If TcSqlExec( cQuery ) <> 0

										cQuery := 'DROP INDEX ' + cOrdName
										TcSqlExec('DROP INDEX ' + cOrdName)

									EndIf

								EndIf

							Next nX

							TAFConOut("Iniciando a criacao dos Indices !")
							TAFConOut("Criando Indices da Tabela "+cTable+" !")

							//Atualiza a tabela no Top com as novas informações para que o TcCanOpen abaixo
							//se baseie na nova estrutura da tabela
							TcRefresh( cTable )

							//Realiza a criação dos indices na tabela
							if "ORACLE" $ Upper(TcGetDB())
								cOrd := "0"

							else
								cOrd := "00"

							endif

							For nX := 1 To Len(aIndices)

								cOrd := Soma1(cOrd)
								cOrdName := cTable+cOrd

								If ( !TcCanOpen(cTable,cOrdName) )

									TAFConOut("Criando Indice "+aIndices[nX]+" !")
									INDEX ON &(aIndices[nX]) TO &(cOrdName)
									TAFConOut("Indice Criado !")

								EndIf

							Next nX

							TAFConOut("Finalizada a criacao dos Indices !")

						EndIf
						(cTable)->( DbCloseArea() )
						lRet := .T.
					else
						cError := ' Nao foi possível abrir ' + cTable + ' em modo Exclusivo '

					endif
				EndIf
			endif

		else
			cError := ' Não foi encontrada a estrutura da tabela ' + cTable + ' para compatibilização de dicionário '
		endif
		RECOVER

		cArqErro := "WIZATU" + DTOS(dDataBase) + StrTran(Time(), ":", "" ) + ".log"

		MemoWrite(cArqErro,cErrDes + cEnter + cErrStk)
		cError := cErrDes +  '. Verifique o log do erro na pasta system no arquivo ' + cArqErro
		lRet := .F.

	END SEQUENCE

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FOpnTabTAf
Função responsável para a abertura das tabelas do TAF que não possuem
dicionário de dados

@Param	cTable - Nome Fisico da tabela
cAlias - Alias onde deve ser aberta a tabela

@author Rodrigo Aguilar
@since 27/03/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FOpnTabTAf( cTable, cAlias )

	Local cOrd     := ''
	Local cOrdName := ''
	Local aCampos  := {}

	Local lRet := .F.


	Local nX, nY := 0

	Local aIndices := {}

	//Tratamento pois essas tabelas tem o complemento da empresa no nome
	//e não em sua estrutura na função xTAFGetStru
	If ( "TAFSPED" $ cTable .or. "TAFECF" $ cTable ) .and. At( "_", cTable ) > 0
		aStruct := xTAFGetStru( SubStr( cTable, 1, At( "_", cTable ) - 1 ) )
	Else
		aStruct := xTAFGetStru( cTable )
	EndIf

	//Carrega os indices para utilização dos DbSetOrder()
	If ( !Empty( aStruct ) )

		aCampos := aStruct[1]

		For nX := 1 to len( aStruct[2] )

			cIndice   := ''
			For nY := 1 To Len( aStruct[2][nX] )
				cIndice += aStruct[2][nX][nY] + '+'
			next
			cIndice := SubStr( cIndice, 1,  Len( cIndice ) -1 )

			aAdd(aIndices,cIndice)

		Next nX

	EndIf

	//Abertura de tabelas
	Use &(cTable) Alias &(cAlias) SHARED NEW Via __CRDD

	//Verifica se não ocorreram problemas no processamento
	If !NetErr()

		//Abertura de indices
		cOrd := "0"

		//Abertura dos indices
		for nX := 1 To Len( aIndices )

			cOrd     := Soma1( cOrd )
			cOrdName := cTable+cOrd
			lRet     := .T.

			//Verifico se é possível abrir o indice da tabela no formato TAFST1X
			if !( MsFile( cTable , cOrdName, __CRDD) )

				cOrd     := strZero( val(cOrd), 2 )
				cOrdName := cTable + cOrd

				if !( MsFile( cTable , cOrdName, __CRDD) )
					lRet := .F.
					Exit
				endif
			endif

			//Somente se foi possivel localizar o indice realizo sua utilização
			if lRet
				(cAlias)->( DbSetIndex(cOrdName))
				(cAlias)->( DbSetNickName(OrdName(nX),cOrdName) )
			endif

		next nX
		(cAlias)->(DbSetOrder(1))

	endif

	Iif ( NetErr(), TAFConOut("Problemas na estrutura da tabela ou a tabela nao existe: " + cTable), Nil)
Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuTAFVer
Atualização da versão do TAF 

@Param	cRpoRelease - Versão a ser gravada 
cError - Variável para controle do erro
aEmpresas - Empresas selecionadas para atualização da versão 

@author Anderson Costa
@since 26/08/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FAtuTAFVer(cRpoRelease, cError, aEmpresas)

	Local lRet := .F.

	StartJob( 'FSetParam', GetEnvServer(), .T., cRpoRelease, aEmpresas)

	lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSetParam
Realiza a alteração no parâmetro.

Essa função utiliza RpcSetEnv, portanto deve ser executada 
dentro de uma thread.

@Param	cRpoRelease - Versão a ser gravada 
cError - Variável para controle do erro
aEmpresas - Empresas selecionadas para atualização da versão 

@author Anderson Costa
@since 26/08/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FSetParam(cRpoRelease, aEmpresas)

	Local nX := 0

	For nX := 1 To Len(aEmpresas)
		If aEmpresas[nX,1]
			// Define o ambiente
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv( aEmpresas[nX,2] , aEmpresas[nX,3] , , , 'TAF',"TAFLOAD" )

			PutMv('MV_TAFVER', Alltrim( cRpoRelease ) )

			TafConOut("Atualizou TAFVER - Empresa: " + aEmpresas[nX,2])
		EndIf
	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuParInt
Atualização da versão do TAF 

@Param	cRpoRelease - Versão a ser gravada 
cError - Variável para controle do erro
aEmpresas - Empresas selecionadas para atualização da versão 

@author Anderson Costa
@since 26/08/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function FAtuParInt(lUsaIntTaf, cMVTafTali, cMVTafTDB, nMVTafPort, aEmpresas)

	Local lRet := .F.

	StartJob( 'FAtuSx6Taf', GetEnvServer(), .T., lUsaIntTaf, cMVTafTali, cMVTafTDB, nMVTafPort, aEmpresas)

	lRet := .T.

Return lRet

/*
Esta função estava sendo chamada pelo TAFINIT, para evitar possiveis error.logs
estamos mantendo ela vazia. Na virada do release a mesma deve ser apagada por conta
dos débitos técnicos.
*/
Function TafFilEvt()
Return Nil


/*
{Protheus.doc} TAFRestIni
Rotina criada para escrever a seção [OnStart] no Server Rest
@type  Function
@author Diego Santos
@since 13/02/2019
@version 1.0
*/
Function TAFRestIni()

	Local cAmbiente := "TAF_WS"
	Local oRPC		:= TRpc():New( AllTrim(cAmbiente) )
	Local nRestPort := Val(AllTrim(GetPvProfString( "TAFRESTPORT", "PORT", "0", GetAdv97() )))
	Local cServer	:= AllTrim(GetProfString( "TCP", "Server", "", .T. ))

	If nRestPort != 0 .And. !Empty(cServer)
		//Realizo a conexão via RPC
		If ( oRPC:Connect( cServer, nRestPort ) )
			oRPC:CallProc("TafOnStart", .F.)
			oRPC:Disconnect()
		Else
			TAFConOut("Não foi possível realizar a conexão ao servidor REST do TAF.")
		EndIf
	EndIf

Return

/*Esta função é chamada pelo TAFINIT, para evitar error.log a mesma está
sendo mantida vazia, na virada do release a mesma deve ser excluida por 
conta dos débitos técnicos.
*/
Function UpdProfile()
Return Nil


/*/{Protheus.doc} TAFFUTPAR
Rotina que valida e grava os parâmetros relacionados ao TAF do futuro.
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Function TAFFUTPAR()

	Local nTamSay		:= 380
	Local aButtons		:= {}
	Local lRet			:= .F.
	Local lContinua		:= .F.
	Local lAdmin		:= FWIsAdmin( __cUserID )
	Local oModal		:= Nil
	Local oContainer	:= Nil
	Local cInfoMPP		:= "Você será direcionado para a documentação sobre a configuração da Porta Multiprotocolo. Após a configuração, será necessário reiniciar o servidor."

	oProfile := FWProfile():New()
	oProfile:SetUser( RetCodUsr() )
	oProfile:SetProgram( "TAFFUTPAR" )
	oProfile:SetTask( "TAFFUTPAR" )
	oProfile:Load()

	cRetProf := oProfile:GetStringProfile()

	If Empty( cRetProf ) .or. DateDiffDay( Date(), SToD( cRetProf ) ) >= 7
		lContinua := .T.
	EndIf

	If FWIsInCallStack("TAFA552A") .OR. FWIsInCallStack("TAFA552B") .OR. FWIsInCallStack("TAFA552C")
		lContinua := .T.
	EndIf

	If lContinua

		oFontSub := TFont():New('Arial',,-14,.T.)

		oFontText := TFont():New('Arial',,-14,.T.)

		oFontTitle := TFont():New('Arial',,-18,.T.)
		oFontTitle:Bold := .T.

		oFontButtons := TFont():New('Arial',,-16,.T.)
		oFontButtons:Underline := .T.
		oFontButtons:Bold := .T.

		oModal  := FWDialogModal():New()
		oModal:SetEscClose(.T.)

		oModal:setSize(300, 600)
		oModal:createDialog()

		If !lAdmin
			AAdd(aButtons, {'',"Não ver esta mensagem nos próximos 7 dias", { || SetProfile( oProfile, .T. ), oModal:Deactivate() },"Não ver esta mensagem nos próximos 7 dias",0,.T.,.F.} )
		EndIf

		If (SuperGetMv("MV_TAFPO",, .F.) == .F.) .AND. lAdmin
			AAdd(aButtons,{'',STR0080, { || MsgInfo( cInfoMPP, STR0079 ), ShellExecute( "Open", "https://tdn.totvs.com/x/jIUoI", "", "C:\", 1 ), oModal:Deactivate() },STR0080,0,.T.,.F.} ) // #Atenção #Configurar Porta Multiprotocolo
			AAdd(aButtons,{'',STR0081, { || lRet := ConfPar() },STR0081,0,.T.,.F.} ) //#"Configurar Parâmetros"
		Else
			nTamSay := 510
		EndIf

		oModal:AddButtons(aButtons)

		oModal:addCloseButton(nil, "Fechar")

		oFont := TFont():New('Courier new',,-18,.T.)

		lHtml := .T.
		oScr1 := TScrollBox():New(oModal:getPanelMain(),01,01,250, 597,.T.,.T.,.T.)

		cTextHtml := GetHtml()

		// Cria objetos para teste do Scroll
		oFont := TFont():New('Courier new',,-22,.T.)

		oSay := TSay():New(01,01,{|| cTextHtml },oScr1,,oFontSub,,,,.T.,,,570,nTamSay,,,,,,lHtml)

		oBtn1 := THButton():New( 255, 005, "O que é PO UI?",							oContainer, { || ShellExecute( "Open", "https://po-ui.io/", "", "C:\", 1 ) }, 060, 020, oFontButtons, "O que é PO UI?" )
		oBtn2 := THButton():New( 255, 100, "Como configurar a Porta Multiprotocolo?",	oContainer, { || ShellExecute( "Open", "https://tdn.totvs.com/x/jIUoI", "", "C:\", 1 ) }, 160, 020, oFontButtons, "Como configurar a Porta Multiprotocolo?" )
		oBtn3 := THButton():New( 255, 290, "Como configurar o servidor REST?",			oContainer, { || ShellExecute( "Open", "https://tdn.totvs.com/x/gkkSCw", "", "C:\", 1 ) }, 140, 020, oFontButtons, "Como configurar o servidor REST?" )
		oBtn4 := THButton():New( 255, 455, "Como configurar o servidor HTTP?",			oContainer, { || ShellExecute( "Open", "https://tdn.totvs.com/x/sYpc", "", "C:\", 1 ) }, 140, 020, oFontButtons, "Como configurar o servidor HTTP?" )

		oBtn1:SetCss("QPushButton{ color: #21a4c4; }")
		oBtn2:SetCss("QPushButton{ color: #21a4c4; }")
		oBtn3:SetCss("QPushButton{ color: #21a4c4; }")
		oBtn4:SetCss("QPushButton{ color: #21a4c4; }")

		oModal:Activate()

	EndIf

Return lRet

/*/{Protheus.doc} ConfPar
Grava os parâmetros relacionados ao TAF do futuro.
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Static Function ConfPar()

	Local aParambox 	:= {}
	Local aRet			:= {}
	Local aUrls			:= {}
	Local lRet			:= .F.

	aUrls := GetURLs()

	AAdd(aParamBox,{1, "Endereço do serviço HTTP",Padr(aUrls[1], 255),"@!","","","",120,.T.})	// 1
	AAdd(aParamBox,{1, "Endereço do serviço REST",Padr(aUrls[2], 255),"@!","","","",120,.T.}) // 2
	AAdd(aParamBox,{2, "Utiliza módulos além do TAF", Iif(SuperGetMv( "MV_TAFPO",, .F. ), "1 - True", "2 - False"), { "1 - True", "2 - False" }, 40,".T.", .T.}) // 3
	AAdd(aParamBox,{9, "Observação: Caso os dados acima não estejam corretos, altere de acordo com a necessidade.",120,30,.T.})

	If ParamBox(aParamBox,"URLs do serviços",@aRet,,,,,,,,.T.)
		Processa( {|| lRet := ValidUrls(MV_PAR01, MV_PAR02, MV_PAR03) }, "Aguarde...", "Validando endereços dos serviços...",.F.)
	EndIf

Return lRet

/*/{Protheus.doc} TAFFUTPAR
Busca as URLS do REST e HTTP na estrutura criada pelo instalador.
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Static Function GetURLs()

	Local cRestURL		:=	""
	Local cRestPort		:=	""
	Local cHTTPPort		:=	""
	Local cHTTPPath		:=	""
	Local cValidPath	:=	""
	Local cRootPath		:=	GetSrvProfString( "ROOTPATH", "" )
	Local cBinPathApp	:=	"\bin\app\appserver.ini"
	Local cBarra		:=	Iif( IsSrvUnix(), "/", "\" )
	Local aRet			:=	{ "", "" }

	cHTTPPort := AllTrim( GetPvProfString( "HTTP", "PORT", "", GetAdv97() ) )

//Se encontrar o HTTP, verifica se o http-root está criado
	If !Empty( cHTTPPort )
		cHTTPPath := AllTrim( GetPvProfString( "HTTP", "PATH", "", GetAdv97() ) )

		If !Empty( cHTTPPath )
			If Right( AllTrim( cRootPath ), 1 ) == cBarra
				cValidPath := cRootPath + "http-root"
			Else
				cValidPath := cRootPath + cBarra + "http-root"
			EndIf
		EndIf
	EndIf

//REST
//Busca primeiro no appserver principal
	cRestPort := AllTrim( GetPvProfString( "HTTPREST", "PORT", "", GetAdv97() ) )

	If !Empty( cRestPort )
		cRestURL := AllTrim( GetPvProfString( "HTTPURI", "URL", "", GetAdv97() ) )
	EndIf

//Se não econtrar, busca no appserver da pasta APP
	If Empty( cRestPort )
		//REST
		If ( AllTrim( GetPvProfString( "HTTPV11", "ENABLE", "", cRootPath + cBinPathApp, Nil, Nil ) ) == "1" ) .and. !Empty( AllTrim( GetPvProfString( "HTTPREST", "PORT", "", cRootPath + cBinPathApp, Nil, Nil ) ) )
			cRestPort := AllTrim( GetPvProfString( "HTTPREST", "PORT", "", cRootPath + cBinPathApp, Nil, Nil ) )
			cRestURL := AllTrim( GetPvProfString( "HTTPURI", "URL", "", cRootPath + cBinPathApp, Nil, Nil ) )
		EndIf
	EndIf

	If !Empty( cHTTPPort )
		aRet[1] := "http://" + GetServerIP() + ":" + cHTTPPort
	EndIf

	If !Empty( cRestPort )
		aRet[2] := "http://" + GetServerIP() + ":" + cRestPort + cRestURL
	EndIf

Return( aRet )


/*/{Protheus.doc} TAFFUTPAR
Valida as URLS do REST e HTTP.
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Static Function ValidUrls(cUrlHttp, cRestURL, cMv)

	Local lRet		:= .F.
	Local lMV			:= Iif( SubStr(cMv, 1, 1) == '1', .T., .F.)

	If lMV .AND. FWSX6Util():ExistsParam( "MV_TAFPO" )

		lRet := GrvParams( cUrlHttp, cRestURL, lMV )

	ElseIf ValidRest(cRestURL)

		If TafVldRP(.T.)

			lRet := GrvParams( cUrlHttp, cRestURL, lMV )

		Else

			MsgAlert("Parâmetros não gravados. Verifique suas informações.")

		EndIf

	ElseIf !ValidRest(cRestURL)

		MsgAlert("Não foi possível acessar a URL do serviço REST, os parâmetros não serão gravados. Verifique suas informações.")

	EndIf

	If lRet
		MsgInfo(STR0082) //#"Parâmetros atualizados com sucesso."
	EndIf

Return lRet

/*/{Protheus.doc} GrvParams
Realiza a gravação dos parâmetros
1 - MV_BACKEND
2 - MV_GCTPURL
3 - MV_TAFPO
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Static Function GrvParams( cUrlHttp, cRestURL, lMV )
	Local cParams	:= ''
	Local lRet		:= .T.

	If FWSX6Util():ExistsParam( "MV_BACKEND" )
		PutMVPar( "MV_BACKEND", AllTrim(cRestURL) )
	Else
		cParams := 'MV_BACKEND'
	EndIf

	If FWSX6Util():ExistsParam( "MV_GCTPURL" )
		PutMVPar( "MV_GCTPURL", AllTrim(cUrlHttp) )
	Else
		cParams += IIF(Len(cParams) > 0 , CRLF,'') + 'MV_GCTPURL'
	EndIf

	If FWSX6Util():ExistsParam( "MV_TAFPO" )
		PutMVPar( "MV_TAFPO", lMV )
	Else

		cParams += IIF(Len(cParams) > 0 , CRLF,'') + 'MV_TAFPO'
	EndIf

	If !Empty(cParams)
		lRet := .F.
		Aviso( 	STR0079; //#'Atenção'
		,I18N(STR0083, {'https://tdn.totvs.com/x/TIp-Hw '} ) + CRLF + CRLF +;//#"A TOTVS recomenda a utilização da Porta Multiprotocolo (MPP)...
		STR0084 +; //#"Caso não queria configurar a Porta Multiprotocolo (MPP)..."
		I18N(STR0085, {'https://tdn.totvs.com/x/K8ZTK '} ) + CRLF + cParams; //#" (mais detalhes de como criar em: #1"
		,{"&OK"},3,,,,.T. )
	EndIf

Return lRet

/*/{Protheus.doc} TAFVLDREST
Valida a URL do REST
Obs: Funcão Criada para chamada Externa evitando o uso
de StaticCall

@author Evandro Oliveira
@since 02/10/2024
@version 1.0
@param 
@return 
/*/
Function TAFVLDREST( cRestURL )
Return ValidRest( cRestURL )

/*/{Protheus.doc} TAFFUTPAR
Valida a URL do REST.
@author Robson Santos
@since 28/11/2019
@version 1.0
@param 
@return 
/*/
Static Function ValidRest( cRestURL )

	Local oRest	:=	FWRest():New( AllTrim( cRestURL ) )
	Local lRet	:=	.F.

	oRest:SetPath( "/index/TAFVALIDRESTONLINE" )

	If oRest:Get()
		lRet := .T.
	EndIf

Return( lRet )

/*/{Protheus.doc} TAFFUTPAR
Valida se o path do HTTP contém 'http-root'
@author Robson Santos
@since 06/12/2019
@version 1.0
@param 
@return 
/*/
Function TafVldRP( lMsg )

	Local cHTTPPort		:=	""
	Local cHTTPPath		:=	""
	Local cValidPath	:=	""
	Local cRootPath		:=	GetSrvProfString( "ROOTPATH", "" )
	Local cBarra			:=	Iif( IsSrvUnix(), "/", "\" )
	Local lRet				:=	.F.

	Default lMsg			:=	.T.

	If SuperGetMv( "MV_TAFPO",, .F. ) == .T.
		lRet := .T.
	Else
		If AllTrim( GetPvProfString( "HTTP", "ENABLE", "", GetAdv97() ) ) == "1" .and. !Empty( AllTrim( GetPvProfString( "HTTP", "PORT", "", GetAdv97() ) ) )
			cHTTPPort := AllTrim( GetPvProfString( "HTTP", "PORT", "", GetAdv97() ) )

			//Se encontrar o HTTP, verifica se o http-root está criado
			If !Empty( cHTTPPort )
				cHTTPPath := AllTrim( GetPvProfString( "HTTP", "PATH", "", GetAdv97() ) )

				If !Empty( cHTTPPath )
					If Right( AllTrim( cRootPath ), 1 ) == cBarra
						cValidPath := cRootPath + "http-root"
					Else
						cValidPath := cRootPath + cBarra + "http-root"
					EndIf

					If cHTTPPath == cValidPath
						lRet := .T.
					Else
						If lMsg
							MsgAlert( "O 'PATH' do serviço HTTP deve ser um diretório com o nome 'http-root'. Verifique a documentação em: https://tdn.totvs.com/x/-RSLHg" )
						EndIf
					EndIf
				Else
					If lMsg
						MsgAlert( "O 'PATH' do serviço HTTP não está configurado. Verifique a documentação em: https://tdn.totvs.com/x/apk4E" )
					EndIf
				EndIf
			EndIf
		Else
			If lMsg
				MsgAlert( "O serviço HTTP não está configurado. Verifique a documentação em: https://tdn.totvs.com/x/apk4E" )
			EndIf
		EndIf
	EndIf

Return( lRet )

Static Function GetHtml()

	Local cHtml := ""

	cHtml += '<h1 style="color: #21a4c4; padding-top: 10px;">Bem vindo ao TAF do Futuro!</h1>'
	cHtml += '<p style="color: #4a5c60; ">Pensando em melhorar a experiência de uso de nossos clientes, nós estamos realizando um trabalho de evolução do produto TAF, deixando-o com visões gerenciais de conferência tanto do eSocial quanto da EFD-Reinf.</p>'

	cHtml += '<h3 style="color: #21a4c4; padding-top: 20px;">O que essa versão contempla para o eSocial?</h3>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>1.</b> Novo Monitor de Transmissão de eventos;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>2.</b> Novo Painel de Contribuição Previdênciária para ajudar na conferência dos valores retornados pelo Governo;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>3.</b> Novo Painel de FGTS para ajudar na conferência dos valores retornados pelo Governo.</p>'

	cHtml += '<h3 style="color: #21a4c4; padding-top: 20px;">Quais as próximas entregas do eSocial?</h3>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>1.</b> Incremento dos valores de terceiros, RAT e patronal no Painel de Contribuição Previdênciária para que seja possível conferir o valor de cálculo de sua folha com a DCTF WEB;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>2.</b> Painel do Trabalhador ( Irá exibir todo o ciclo de vida do funcionário dentro do eSocial, desde sua admissão até a foto atual );</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>3.</b> Painel de Auditoria de eventos entregues dentro ou fora do prazo.</p>'

	cHtml += '<h3 style="color: #21a4c4; padding-top: 20px;">O que essa versão contempla para a EFD-Reinf?</h3>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20;"><b>1.</b> Painel EFD-Reinf, que concentra todas as informações dos eventos e permite que a emissão de relatórios para conferência, apuração, transmissão e acompanhamento dos eventos seja realizada de forma simples, rápida e intuitiva;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>2.</b> Eventos disponíveis: R-1000, R-1070, R-2010, R-2020, R-2030, R-2040, R-2050, R-2055, R-2060, R-2098, R-2099, R-3010 e R-9000;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>3.</b> Relatório que permite a conferência dos dados retornados pelo Governo;</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>4.</b> Exportação dos dados dos relatórios em Excel.</p>'

	cHtml += '<p style="color: #4a5c60; padding-top: 10px;"><b>As rotinas já existentes no produto serão substituídas pelas citadas acima tanto do eSocial quanto para a EFD-Reinf e a partir de Dezembro de 2021 as rotinas antigas não serão mais suportadas pela TOTVS.</b></p>'

	If (SuperGetMv("MV_TAFPO",, .F.) == .T.)

		cHtml += '<h2 style="color: #21a4c4; padding-top: 20px;">Clientes da linha Protheus:</h2>
		cHtml += '<p style="color: #4a5c60; margin-left: 20px;">Para utilizar essa nova funcionalidade, existem alguns pré-requisitos que seu ambiente precisa atender, conforme abaixo:</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>1.</b> Utilizar binário 64 bits;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>2.</b> Possuir o último pacote acumulado do eSocial ( TAF e GPE );</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>3.</b> Possuir a Porta Multiprotocolo habilitada;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>4.</b> Caso não utilize a Porta Multiprotocolo:</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 40px;"><b>4.1.</b> Possuir um servidor HTTP configurado;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 40px;"><b>4.2.</b> Possuir um servidor REST configurado;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 40px;"><b>4.3.</b> Preencher o parâmetro <b>MV_GCTPURL</b> com a URL do serviço <b>HTTP</b>;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 40px;"><b>4.4.</b> Preencher o parâmetro <b>MV_BACKEND</b> com a URL do serviço <b>REST</b>;</p>'
		cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>5.</b> Possuir no menu do TAF a opção TAFA552A para o contexto de eSocial, e TAFA552B para o contexto de REINF.</p>'

	EndIf

	cHtml += '<h3 style="color: #21a4c4; padding-top: 20px;">As melhorias disponíveis nessa versão encontram-se nos seguintes caminhos do menu:</h3>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>eSocial:</b> Miscelanea - eSocial - eSocial do Futuro</p>'
	cHtml += '<p style="color: #4a5c60; margin-left: 20px;"><b>EFD-Reinf:</b> Atualizações - Eventos Reinf - Painel Reinf</p>'

Return cHtml

//---------------------------------------------------------------------
/*/{Protheus.doc} SetProfile
@type			function
@description	Atualiza o arquivo de profile da GRFGTS.
@author			Felipe C. Seolin
@since			29/01/2019
@param			oProfile	-	Objeto referente ao arquivo de profile
@param			lCheck		-	Indica se a opção para não exibir nos próximos 7 dias foi marcada
/*/
//---------------------------------------------------------------------
Static Function SetProfile( oProfile, lCheck )

	Local cSetting	:=	""

	If lCheck
		cSetting := DToS( Date() )
	EndIf

	oProfile:SetStringProfile( cSetting )
	oProfile:Save()

Return()

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntAtiva
@type			function
@description	Cria campo de controle (S_T_A_M_P_) nas tabelas de integração entre SIGAFIS e TAF.
@author			Carlos Eduardo
@since			14/05/2020
/*/
//------------------------------------------------------------------------------------------------
Function IntAtiva(cMsg)
	Local lRet := .t.
//Local nHwnd := 0
	Local aTables := getTblTSI()
	Local aFiles := {} //{ arquivo , alias }
	Local i := 0
/*
	A função TCCONFIG tem que ser macro executada, pois estava causando erro de Invalid function type. Please check RPO file
	Detalhes em https://tdn.totvs.com/x/B4eUD
*/
	Local cFn := "TCCONFIG"

	If FindFunction( cFn )

		//For executado para evitar quebras no momento da criação do stamp devido a tabela não ter sido acessada.
		for i := 1 to len( aTables )
			DbSelectArea( aTables[i] )
			DbCloseArea()
		next

		//Carrego o array com os dados para abertura das tabelas.
		aEval( aTables, { |x| aadd(aFiles,{RetSqlName(x),x}) } )

		//Foi comentado o tclink devido problemas no oracle, onde o mesmo retorna -2 (no connection),
		//devido estar em servidor diferente de localhost e estar no linux.
		//nHwnd := TCLink()
		//if nHwnd >= 0 //Conectado com sucesso
		if ( &cFn.('SETAUTOSTAMP = ON') == 'OK' ) .and. ( &cFn.('SETUSEROWSTAMP = ON') == 'OK' )

			//Verifico se todas as tabelas puderam ser abertas em modo excluivo.
			for i := 1 to len(aFiles)
				TCRefresh( aFiles[i][1] )
				DbUseArea( .t., 'TOPCONN', aFiles[i][1], aFiles[i][2], .f. , .f. )
				DbCloseArea()
				if aScan( TCStruct( aFiles[i][1] ), { | x | x[1] == 'S_T_A_M_P_' } ) = 0
					lRet := .f.
					exit
				endif
			next

			if lRet
				cMsg := 'Campos para integração entre SIGAFIS e TAF criados COM SUCESSO!'
			else
				cMsg := 'Não foi possível abrir as tabelas para atualização! Tente novamente acessando o sistema em modo exclusivo.'+CRLF+;
					'Para mais detalhes acesse: https://tdn.totvs.com/x/J9ruDQ'
			endif
		endif
		//TCUnlink(nHwnd,.t.)
		//endif

		lRet := ( &cFn.('SETAUTOSTAMP = OFF') == 'OK' ) .and. ( &cFn.('SETUSEROWSTAMP = OFF') == 'OK' )

	Else
		lRet := .f.
		cMsg := 'Não foi possível abrir as tabelas para atualização! Tente novamente acessando o sistema em modo exclusivo.'+CRLF+;
			'Para mais detalhes acesse: https://tdn.totvs.com/x/J9ruDQ - Tópico "Erro na criação do campo S_T_A_M_P_ " '
	EndIf

return lRet
