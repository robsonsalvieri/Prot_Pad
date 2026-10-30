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

	//Necessidade verificada em 04/2026.
	TAFRestIni()

	If TAFAtualizado()
		TAFInit()
	Else
		Final()
	EndIf

Return()

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
