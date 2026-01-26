#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFMONTES.CH"

Static lLaySimplif 	:= taflayEsoc("S_01_00_00")
Static lFindClass	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools
Static cEvtsTrab  	:= Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMonDet
Browse com o detalhamento dos registros e-Social de acordo com a selecão
do Browse da rotina superior
@author evandro.oliveira
@since 25/02/2016
@version 1.0
@param oBrow, objeto, (Browse que está sendo executado a função)
@param xStatus, variável, (Status para filtro na query, quando passado isoladamente
deve ser do tipo numerico, quando conter 2 ou mais status deve ser passado sendo tipo caracter
separado por virgula, exemplo: "1,2,4")
@param cNomeSts, character, (Descrição do status)
@param xEvento, variável, (Eventos para filtro da query, quando passado isoladamente
dever ser do tipo caracter, quando conter 2 ou mais eventos deve ser do tipo Array
com 1 evento em cada posição)
@param lEvtsRot, lógico,(determina se o parâmetro xEvento já vem com as informações do
TafRotinas quando o mesmo for do tipo Array)
@param lMultTp, lógico,(Informa se os eventos selecionados são de + de 1 tipo ex: tabelas,periodios etc..)
@param xRecLin, numerico/caracter, (obsoleto)
@param lDetal, logico, ( Define se o browse de detalhamento (painel da direita) foi selecionado )
@param oProcess, object, (Objeto MsNewProcess)
@param lCancel, logico, ( Informa que o usuário efetuou o cancelamento do processamento)
@return ${Nil}
/*/
//---------------------------------------------------------------------
Function TafMonDet( oBrow, xStatus, cNomeSts, xEvento, lEvtsRot, lMultTp, xRecLin, aIDsSel, lDetal, cIDBrowse,lTempTable,oProcess,lCancel,oTabFilSel,dDtIni,dDtFim )

	Local oSize        := FWDefSize():New(.F. )
	Local cQuery       := ""
	Local cStatus      := ""
	Local cArqTrbDet   := ""
	Local cMsg         := ""
	Local nX           := 0
	Local nE           := 0
	Local nTotRegs     := 0
	Local nPenAnt      := 0
	Local nPenDep      := 0
	Local nAjust       := 0
	Local nPos         := 0
	Local nRetTSS      := 1
	Local aCampos      := {}
	Local aStruct      := {}
	Local aTAFXERP     := {}
	Local aHeaderT     := {}
	Local aIndex       := {}
	Local aSeek        := {}
	Local aFiltro      := {}
	Local lMaisD1      := .F.
	Local lConxTSS     := .F.
	Local aFiliais     := {}
	Local cErroSQL     := ""
	Local lJob         := isBlind()
	Local lNewProcess  := .F.
	Local cEvent       := ""
	Local cRegra       := ""
	Local cDataLim     := ""
	Local lTafOwner    := .F.
	Local cBanco       := ""

	Private oMBrowse   := Nil
	Private cAliasDet  := ""
	Private aRetorno   := {}

	Default lEvtsRot   := .F.
	Default lMultTp    := .F.
	Default lDetal     := .F.
	Default lTempTable := .F.
	Default lCancel    := .F.
	Default oProcess   := Nil
	Default oTabFilSel := Nil
	Default dDtIni     := paramDataInicial
	Default dDtFim     := paramDataFim
	Default aIDsSel    := {}

	cBanco := AllTrim(TCGetDB())

	If ValType(oProcess) == "O"
		lNewProcess := .T. //Informa que a barra de processamento é um MsNewProcess
	EndIf

	//Verifico se o usuário corrente tem acesso a rotina
	If FPerAcess( , AllTrim( xEvento ) )

		aEvents := TAFRotinas(,,.T.,2)

		If cEvtsTrab == Nil

			cEvtsTrab := ""

			For nE := 1 To Len(aEvents)

				If !Empty(aEvents[nE][11]) .And. !("CPF" $ aEvents[nE][11]) .And. !Empty(aEvents[nE][4]) .And. aEvents[nE][4] != "S-3000"
					cEvtsTrab += aEvents[nE][04] + "|"
				EndIf

			Next nE

		EndIf

		If !lJob .And. lNewProcess
			oProcess:SetRegua1(4)
		EndIf

		dBSelectArea( "T0X" )
		T0X->(dBSetOrder( 3 ) )

		dBSelectArea("V2H")
		V2H->(dBSetOrder(2))

		dBSelectArea("V2J")
		V2H->(dBSetOrder(1))

		dBSelectArea("C9V")
		C9V->(dBSetOrder(2))

		If ValType(xEvento) == "A"

			If Len(xEvento) > 0
				cEvent := xEvento[1][4]
			EndIf

		Else

			cEvent	:= xEvento

		EndIf

		If !Empty( xEvento ) .or. !Empty( aIDsSel )

			If !Empty( xEvento )
				aEvents := FTrataEvt( xEvento, lEvtsRot, @lMultTp, @lMaisD1 )
			Else
				//Deixei o aEvents + acima por preciso utiliza-lo em outro contexto
				/*+------------------------------------------------------+
				| Quando houver seleção no browse do trabalhador, assumo |
				| que existem múltiplos eventos de diversos tipos        |
				+--------------------------------------------------------+*/
				If paramVisao == 2 .and. !lDetal
					lMaisD1 := .T.
					lMultTp := .T.
				EndIf
				
			EndIf

			lConxTSS := TAFWVerUrl( , @cMsg )

			If !lConxTSS
				cMsg := STR0107 //"Não foi possível conectar-se a um servidor TSS, a interface de detalhamento será criada, porém os registros com status de transmissão não terão suas descrições exibidas."
				cMsg += CRLF + CRLF + STR0108 //"Clique em Ok para continuar."

				nRetTSS := Aviso( STR0109, cMsg, { STR0077, STR0110 }, 3 ) //##"Divergência de Parâmetros" ##"Cancelar"
			EndIf

			If nRetTSS == 1 .and. ( !Empty( xEvento ) .or. !Empty( aIDsSel ) ) .and. xStatus <> Nil .and. Len( aEvents[1] ) > 0
				/*+---------------------------------------------------+
				| Criar estrutura dos campos                          |
				| [x][1] - Descrição                                  |
				| [x][2] - Nome do Campo                              |
				| [x][3] - Tamanho do Campo                           |
				| [x][4] - Tipo do Campo                              |
				| [x][5] - Picture do Campo                           |
				| [x][6] - Alinhamento                                |
				| [x][7] - Atributo do campo no Objeto ( WebService ) |
				| [x][8] - Define se o campo deve aparecer no Browse  |
				| [x][9] - Tamanho da coluna Browse					  |
				+-----------------------------------------------------+*/

				aAdd( aCampos, { STR0111		, "EVENTO"		, Len( aEvents[1][4] )										, "C"	, "@!"	, 1	, "",.T.} ) //"Evento"
				aAdd( aCampos, { STR0112		, "XSTATUS"		, 01														, "C"	, ""	, 1	, "",.T. } ) //"Status"
				aAdd( aCampos, { "Descr. Status", "DESCSTATUS"	, 15														, "C"	, ""	, 1	, "",.T. } ) //"Descr. Status"
				aAdd( aCampos, { "Filial"		, "FILIAL"		, GetSX3Cache( aEvents[1][3] + "_FILIAL", "X3_TAMANHO" )	, "C"	, ""	, 1	, "",.T. } ) //"Filial"
				aAdd( aCampos, { STR0113		, "ID"			, 36														, "C"	, "@!"	, 1	, "",.T. } ) //"ID do Registro"
	//			aAdd( aCampos, { "Versao"		, "VERSAO"		, 44														, "C"	, "@!"	, 1	, "",.T. } ) //"Versão"

				If (aEvents[1][12] == EVENTOS_INICIAIS[2] .and. cIDBrowse == "Tabelas") .or. alltrim(xEvento) == "S-1005"
					aAdd( aCampos, { STR0169, "CODIGO", 30, "C", "@!", 1, "",.T.,10} ) //"Código"
				EndIf

				aAdd( aCampos, { STR0114, "DESCR", 220, "C", "@!", 1, "",.T.,50 } ) //"Descrição"

				If Alltrim(cEvent) == "S-2230"
					aAdd( aCampos, { STR0262	, "XMLENV"	, 25										, "C"	, "@!"	, 1	, "",.T.} ) //"XML Recebido"
				EndIf

				If aEvents[1][12] == EVENTOS_INICIAIS[2] .and. cIDBrowse == "Tabelas"
					aAdd( aCampos, { STR0115	, "INIVALD"	, 6	, "C"	, GetSX3Cache( aEvents[1][3] + "_DTINI", "X3_PICTURE" )		, 0	, "",.T. } ) //"Início Validade"
						
					aAdd( aCampos, { STR0116	, "FINVALID"	, 6	, "C"	, GetSX3Cache( aEvents[1][3] + "_DTFIN", "X3_PICTURE" )		, 0	, "",.T. } ) //"Fim Validade"
				ElseIf aEvents[1][12] == EVENTOS_MENSAIS[2] .or. lMultTp
					aAdd( aCampos, { STR0117	, "INDAPU"		, 1	, "C"	, GetSX3Cache( aEvents[1][3] + "_INDAPU", "X3_PICTURE" )	, 0	, "",.T. } ) //"Ind. Apuração"
					aAdd( aCampos, { STR0118	, "PERAPU"		, 6	, "C"	, GetSX3Cache( aEvents[1][3] + "_PERAPU", "X3_PICTURE" )	, 0	, "",.T. } ) //"Per. Apuração"
				EndIf

				aAdd( aCampos, { STR0218	, "MENSG"	, 255	, "C", "", 1	, "CDETSTATUS"	,.T. } ) //"Situação do Evento"
				aAdd( aCampos, { STR0219	, "RETGOV"	, 200	, "C", "", 1	, "CDSCRECEITA"	,.T. } ) //"Descrição da Receita"
				aAdd( aCampos, { STR0187	, "DATALI"	, 10	, "C", "", 1	, ""			,.T. } ) //"Data"
	/*
				aTAFXERP := xTAFGetStru( "TAFXERP" )[1]
				If ( nPos := aScan( aTAFXERP, { |x| AllTrim( x[1] ) == "TAFKEY" } ) ) > 0
					aAdd( aCampos, { STR0201, aTAFXERP[nPos,1], aTAFXERP[nPos,3], aTAFXERP[nPos,2], "", 1, "",.T.} ) //"Chave de Integração"
				EndIf
	*/
				aAdd( aCampos, { STR0188	, "REGRA"		, 255															, "C"	, ""	, 1	, ""			,.T.} ) //"Regra"
				aAdd( aCampos, { STR0208	, "RECIBO"		, GetSX3Cache( aEvents[1][3] + "_PROTUL", "X3_TAMANHO" ), "C"	, "@!"	, 1		, "CRECIBO"			,.T.} ) //"Recibo"
				aAdd( aCampos, { STR0122	, "VERSAO"		, GetSX3Cache( aEvents[1][3] + "_VERSAO", "X3_TAMANHO" ), "C"	, "@!"	, 1		, ""				,.F.} ) //"Versão"
				aAdd( aCampos, { STR0123	, "RECNO"		, 6																, "N"	, ""	, 1	, ""			,.F.} ) //"RecNo"
				aAdd( aCampos, { ''			, "HISTPROC"	, 10															, "M"	, ""	, 1	, "CHISTPROC"	,.F.} ) //"Historico Processo TSS"
				aAdd( aCampos, { ''			, "XMLERRO"		, 10															, "M"	, ""	, 1	, "CXMLERRORET"	,.F.} ) //"Inconsistências"
				aAdd( aCampos, { ''			, "CODRECEITA"	, 3																, "C"	, ""	, 1	, "CCODRECEITA"	,.F.} ) //"Codigo de Receita"
				aAdd( aCampos, { ''			, "STATUSTSS"	, 1																, "C"	, ""	, 1	, "CSTATUS"		,.F.} ) //"Status TSS"
				aAdd( aCampos, { ''			, "EXTEMP"		, 1																, "C"	, ""	, 1	, ""			,.F.} ) //"Evento Extemporâneo"
				aAdd( aCampos, { ''			, "CIDTRAB"		, GetSX3Cache("C9V_ID", "X3_TAMANHO" )	    					, "C"	, ""	, 1	, ""			,.F.} ) //"Id do Trabalhador"
				aAdd( aCampos, { ''			, "CPFMV"		, GetSX3Cache("C91_CPF", "X3_TAMANHO" )	    					, "C"	, ""	, 1	, ""			,.F.} ) //"CPF eventos S-1200 - S-1210"

				If TAFAlsInDic("V2J")
					aAdd( aCampos, {"Situação do Totalizador?", "TOTALIZD" , 50 , "C" , "" , 1	, "" ,.T.} ) //Gerou totalizador
				EndIf

				If (Alltrim(cEvent) == "S-1200" .OR. Alltrim(cEvent) == "S-1210")
					aAdd( aCampos, { "ERP Origem"		, "TAFOWNER"		, GetSX3Cache( aEvents[1][3] + "_OWNER", "X3_TAMANHO" )	, "C"	, ""	, 1	, "",.T. } ) //"OWNER"
					lTafOwner := .T.
				EndIf

				For nX := 1 to Len( aCampos )

					aAdd( aStruct, { aCampos[nX][2], aCampos[nX][4], aCampos[nX][3], 0 } )

					if !( aCampos [ nX, 2 ] $ 'XSTATUS|HISTPROC|XMLERRO|CODRECEITA|STATUSTSS|EXTEMP|RECNO|' )
						aAdd( aFiltro, { aCampos[nX][2], aCampos[nX][1], aCampos[nX][4], aCampos[nX][3], 0, aCampos[nX][5] } )
					endif

				Next nX


				aAdd( aSeek, { "Evento+Id", { { "", "C", Len( aEvents[1][4] ), 0, "EVENTO", "@!", }, { "", "C", GetSX3Cache( aEvents[1][3] + "_ID", "X3_TAMANHO" ), 0, "ID", "@!", } } } )


				If ValType( xStatus ) == "C"
					cStatus := xStatus
				ElseIf ValType( xStatus ) == "N"
					cStatus := Iif( xStatus == STATUS_NAO_PROCESSADO[1], "' '", AllTrim( Str( xStatus ) ) )
				EndIf

				cAliasDet := GetNextAlias()

				cQuery := BuildTemp( cStatus, aEvents, aIDsSel, cIDBrowse, aCampos, @nTotRegs, lConxTSS, @nPenAnt, @nPenDep, lMaisD1,,@lCancel,@oProcess,@oTabFilSel, xRecLin,lTafOwner)

				aFiliais := FWLoadSM0()

				/*+--------------------------+
				| Cria colunas para o Browse |
				+----------------------------+*/
				For nX := 1 to Len( aCampos )

					If aCampos[nX][8]

						aAdd( aHeaderT, FWBrwColumn():New() )

						If aCampos[nX][2] == "DESCR"
							aTail(aHeaderT):SetData( &( "{ || TafMDetDescr(lMaisD1,xEvento,aFiliais,cBanco) }" ) )
						ElseIf aCampos[nX][2] == "XMLENV"
							aTail(aHeaderT):SetData( &( "{ || AfastaEnv((cAliasDet)->" + aCampos[nX][2] + ") }" ) )
						Else
							aTail(aHeaderT):SetData( &( "{ || (cAliasDet)->" + aCampos[nX][2] + " }" ) )
						EndIf

						aTail(aHeaderT):SetTitle( aCampos[nX][1] )
						aTail(aHeaderT):SetSize( aCampos[nX][3] )
						aTail(aHeaderT):SetType( aCampos[nX][4] )
						aTail(aHeaderT):SetDecimal( 0 )
						aTail(aHeaderT):SetPicture( aCampos[nX][5] )
						aTail(aHeaderT):SetAlign( aCampos[nX][6] )

						If aCampos[nX][2] == "TOTALIZD"
							aTail(aHeaderT):SetDoubleClick({||FWMsgRun(,{||mostraTotErro()},'Totalizadores','Vericando Inconsistências... ')})
						EndIf 

					EndIf

				Next nX

				/*+----------------------------------------+
				| Cria interface utilizando o objeto Layer |
				+------------------------------------------+*/
				Define MSDialog oDlg1 Title STR0078 From oSize:aWindSize[1], oSize:aWindSize[2] to oSize:aWindSize[3], oSize:aWindSize[4] Pixel //"Monitor eSocial - Detalhamento"

				oLayer := FWLayer():New()
				oLayer:Init( oDlg1, .F. )

				oLayer:AddLine( "LINE01", 013 )
				oLayer:AddLine( "LINE02", 072 )
				oLayer:AddLine( "LINE03", 015 )

				oCabec := oLayer:GetLinePanel( "LINE01" )
				oEventos := oLayer:GetLinePanel( "LINE02" )
				oRodape := oLayer:GetLinePanel( "LINE03" )

				If lMaisD1

					If cIDBrowse == "Tabelas"
						cDescr := STR0127 //"Eventos de Tabelas ( DIVERSOS )"
					Else
						cDescr := STR0128 //"Eventos ( DIVERSOS )"
					EndIf

				Else
				
					cDescr := aEvents[1][4] + " - " + AllTrim( Posicione( "C8E", 2, xFilial( "C8E" ) + aEvents[1][4], "C8E_DESCRI" ) ) + " " + cNomeSts

				EndIf

				aIndex := {}

				aAdd( aIndex, "EVENTO+ID+VERSAO" )
				aAdd( aIndex, "XSTATUS")

				If nPos > 0
					aAdd( aIndex, aTAFXERP[nPos,1] )
				EndIf

				oMBrowse := FWMBrowse():New()

				oMBrowse:SetDataQuery(.T.)
				oMBrowse:SetQuery(cQuery)
				oMBrowse:SetQueryIndex(aIndex)

				oMBrowse:SetAlias( cAliasDet )
				oMBrowse:SetColumns( aHeaderT )
				oMBrowse:SetDescription( cDescr )

				oMBrowse:DisableDetails()
				oMBrowse:SetUseFilter( .T. )
				oMBrowse:SetProfileId("uFil")
				oMBrowse:SetDBFFilter()
				oMBrowse:SetFieldFilter( aFiltro )
		//		oMBrowse:SetSeek( .T., aSeek )

				//-----------------------------------------------------------------------------------------------------------------------------
				// Define os campos chave de um browse de query ou array para conseguir reposicionar posteriormente em atualizações que forcem
				// a reconstrução do browse (Refresh). Não será realizado controle de inserção em duplicidade de registros no browse.
				//-----------------------------------------------------------------------------------------------------------------------------
				oMBrowse:SetUniqueKey({"ID"})

				(cAliasDet)->(dbGotop())
				If !( (cAliasDet)->( Eof() ) .And. (cAliasDet)->( Bof() ) )
					TafRegra( ( cAliasDet )->ID + ( cAliasDet )->VERSAO, ( cAliasDet )->ALIAS, AllTrim( ( cAliasDet )->LAYOUT ), @cRegra, @cDataLim )
					( cAliasDet )->DATALI := cDataLim
					( cAliasDet )->REGRA := cRegra
				EndIf

				oMBrowse:SetDoubleClick( { ||  FWMsgRun( , { || FTableTSSErr(),FeSocCallV((cAliasDet)->EVENTO,(cAliasDet)->RECNO, Iif( AllTrim((cAliasDet)->XSTATUS) == "2|4|6|7",1,4),, ( cAliasDet )->FILIAL ) }, STR0129, STR0130 ), oMBrowse:ExecuteFilter(.T.) } ) //##"Manutenção dos Itens" ##"Carregando Cadastro do Evento"

				oMBrowse:AddButton(STR0220,{||mostraXMLErro(lMaisD1,xEvento,@oTabFilSel) })	//"Inconsistências no Governo"
				setFilterOpc(oMBrowse)
				oMBrowse:Activate(oEventos)

				nTotRegs := geTotalRegs(oMBrowse)
				nPenAnt := geTotalRegs(oMBrowse,'pendAnt')

				oPanCab := Nil
				FPanStus( @oPanCab, oCabec, 1, @nTotRegs, nPenAnt, nPenDep, nAjust,,,,,, lConxTSS, aIDsSel, cIDBrowse,@lCancel,@oProcess,lTempTable,cArqTrbDet, @oTabFilSel,dDtIni,dDtFim,lTafOwner )

				oPanRod := Nil
				FPanStus( @oPanRod, oRodape, 2, @nTotRegs, nPenAnt, @nPenDep, @nAjust, lMaisD1, cStatus, aEvents, lMultTp, aCampos, lConxTSS, aIDsSel, cIDBrowse,@lCancel,@oProcess,lTempTable,cArqTrbDet,@oTabFilSel,dDtIni,dDtFim,lTafOwner )

				Activate MSDialog oDlg1 Centered

				If FindFunction("FTableTSSErr")

					TafDelTempTable(cArqREtTss:GetRealName(),@cErroSQL)
					If !Empty(cErroSQL)
						MsgInfo(cErroSQL,"Exclusão de Tabela Temporaria")
					EndIF

				EndIf

			EndIf

		EndIf

	EndIf

Return()

Static Function geTotalRegs(oMBrowse,cToken)

	Local cTabTemp	:= oMBrowse:oData:oTempDB:GetRealName()
	Local cQry		:= ""
	Local nTotRegs	:= 0

	Default cToken	:= 'total'

	If cToken == 'total'
		cQry := " SELECT COUNT(*) NREGS FROM " + cTabTemp
	Else
		cQry := " SELECT COUNT(*) NREGS FROM " + cTabTemp + " WHERE XSTATUS NOT IN ('4','7') "
	EndIf


	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),'ArqCount', .F., .T. )

	nTotRegs := ArqCount->NREGS

	ArqCount->(dbCloseArea())


Return nTotRegs

//---------------------------------------------------------------------
/*/{Protheus.doc} setFilterOpc
Define os Filtros padrões do Browse

@author evandro.oliveira
@since 27/03/2018
@version 1.0
@param oBrw - Objeto FWMBrowse
@return Nil
/*/
//---------------------------------------------------------------------
Static Function setFilterOpc(oBrowse)

	oBrowse:AddFilter(STR0025,"XSTATUS == ' '") 					//Não processado
	oBrowse:AddFilter(STR0026,"XSTATUS == '0'") 					//Aguardando Transmissão
	oBrowse:AddFilter(STR0027,"XSTATUS == '1'") 					//Inválidos
	oBrowse:AddFilter(STR0028,"XSTATUS == '2'") 					//Sem Retorno do Governo
	oBrowse:AddFilter(STR0029,"XSTATUS == '3'") 					//Inconsitente
	oBrowse:AddFilter("Transmitido com Sucesso","XSTATUS == '4'") 	//Tramitido com Sucesso

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} mostraXMLErro
Exibe retorno do XML quando é retornado uma inconsistência.
@param lMaisD1 -> Identifica se existe eventos com codigos diferentes no detalhamento
necessário para saber se o campo EVENTO foi criado no browse.
@param xEvento -> Layout do Evento (quando não há eventos com codigos diferentes)

@author evandro.oliveira
@since 21/08/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function mostraXMLErro(lMaisD1,xEvento,oTabFilSel)

	Local cEvento	:= ""
	Local cFuncao	:= ""
	Local aEvento	:= {}
	Local cFilBkp	:= ""
	Local cIdEntTSS := ""
	Local aParamFil	:= Array(6)
	Local aRetTSS 	:= {}
	Local cMsg		:= ""
	Local cErrRet   := ""
	Local lFoundErro := .T. 
	Local nTamChv	:= 0
	Local cTipoErro := ""

	Default oTabFilSel := Nil
	
	//Ajusta para Filial do Registro
	cFilBkp	:= cFilAnt
	cFilAnt := (cAliasDet)->FILIAL


	cIdUnic := AllTrim(STRTRAN((cAliasDet)->EVENTO,"-","")) + AllTrim((cAliasDet)->ID) + AllTrim((cAliasDet)->VERSAO)
	cEvento := (cAliasDet)->EVENTO
	nTamChv := GetSx3Cache("V2J_CHVTAF","X3_TAMANHO")

	If TAFAlsInDic("V2H")

		V2H->(dBSetOrder(2))

		Do Case 

		Case (cAliasDet)->XSTATUS == '3' .Or. (cAliasDet)->XSTATUS == '4'

			If V2H->(MsSeek((cAliasDet)->FILIAL+Substr(cIdUnic,1,nTamChv)))

				If (cAliasDet)->XSTATUS == '3' .Or. (V2H->V2H_CODREC = '202' .And. (cAliasDet)->XSTATUS == '4')    

					While V2H->(!Eof()) .And. Substr(cIdUnic,1,nTamChv) == AllTrim(V2H->V2H_IDCHVE)

						cTipoErro := IIf(V2H->V2H_TPERRO == '1',"Erro","Advertência")

						cErrRet += "Sequência: " 				+ V2H->V2H_SEQERR
						cErrRet += " - Tipo: "					+ cTipoErro
						cErrRet += " - Codigo da Ocorrência: " 	+ V2H->V2H_CODERR 
						cErrRet += " - Descrição : " 			+ V2H->V2H_DCERRO
						
						If TafColumnPos("V2H_LOCERR")
							cErrRet += " - Localização : " 		+ V2H->V2H_LOCERR
						EndIf
						
						cErrRet += CRLF + CRLF

						V2H->(dbSkip())
					EndDo

					If V2H->(MsSeek((cAliasDet)->FILIAL+Substr(cIdUnic,1,nTamChv)))
						If !Empty(V2H->V2H_CODERR)
							ShowLog(STR0247,"Código da Resposta: " + V2H->V2H_CODREC + " - " + V2H->V2H_DSCREC,cErrRet) //"Inconsistências retornadas do RET"
						Else
							If !Empty(V2H->V2H_DCRESP) .And. TafColumnPos("V2H_DCRESP")
								ShowLog(STR0247,"Código da Resposta: " + V2H->V2H_CODREC + " - " + V2H->V2H_DCRESP, "") //"Inconsistências retornadas do RET"
							Else
								MsgInfo("O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados UPDDISTR disponível no portal do cliente do TAF.", "Ambiente Desatualizado!")
							EndIf
						EndIf
					EndIf

				Else
					MsgAlert(STR0242,"Aviso") //"Não há Inconsistências para este registro ."
				EndIf 

			ElseIf TafSeekT0X(cIdUnic)

				If T0X->T0X_TPERRO = 'S' .And. (cAliasDet)->XSTATUS == '3'
					Aviso(STR0245, T0X->T0X_DCERRO, {STR0246}, 3 ) //"Erro de Schema"#"Fechar"
				Else

					lFoundErro := .F. 
				EndIf
			Else

				lFoundErro := .F. 
			EndIf 
		
		Case (cAliasDet)->XSTATUS == '2'

			aParamFil[1] := .T.
			aParamFil[2] := (cAliasDet)->FILIAL
			aParamFil[3] := AllTrim(SM0->M0_FILIAL)
			aParamFil[4] := AllTrim(SM0->M0_CGC)
			aParamFil[5] := AllTrim(SM0->M0_INSC)
			aParamFil[6] := ""

			aEvento := TAFRotinas(cEvento,4,.F.,2)
			aRetTSS := TAFProc5Tss(.F.,{aEvento},'2',,cValToChar((cAliasDet)->RECNO),.F.,,{aParamFil},,,,.F.,@cIdEntTSS,,.T.,@oTabFilSel)

			If Len(aRetTSS) > 0 .And. Len(aRetTSS[1]) > 0
				If !Empty(aRetTSS[1][1]:CHISTPROC)
					If parseJsonTSS(aRetTSS[1][1]:CHISTPROC,@cMsg)
						Aviso(STR0243,cMsg, {STR0246}, 3 ) //"Status do processo retorno TSS"#"Fechar"
					Else
						MsgInfo(" Aguardando processamento no TSS. Aguarde mais alguns minutos. ",STR0243)
					EndIf
				Else
					MsgInfo("Aguardando Processamento no TSS. Status : " + aRetTSS[1][1]:CDETSTATUS,"Consulta de Status")
				EndIf

				FreeObj(aRetTSS[1][1])
				aSize(aRetTSS,0)
			Else
				MsgInfo("Aguardando Processamento no TSS.","Consulta de Status")
			EndIf

		OtherWise
	
			MsgAlert(STR0242,"Aviso") //"Não há Inconsistências para este registro ."
		EndCase

		If !lFoundErro
			MsgInfo("Não foi possível obter a mensagem de inconsitência. Realize a retransmissão do evento. ","Consulta de Status")
		EndIf 

	Else 
		/*************************** Reavaliar este trecho, após a expedição do pacote de dicionario o mesmo pode ser retirado */
		If (cAliasDet)->STATUSTSS == '5'

			ShowLog(STR0247, ( cAliasDet )->RETGOV, xIdentXML( AllTrim(( cAliasDet )->XMLERRO) )) //"Inconsistências retornadas do RET"

		ElseIf (cAliasDet)->XSTATUS == '3' .OR. (cAliasDet)->XSTATUS == '1'

			If TafSeekT0X(cIdUnic)
				If T0X->T0X_TPERRO = 'S' .And. (cAliasDet)->XSTATUS == '3'
					Aviso(STR0245, T0X->T0X_DCERRO, {STR0246}, 3 ) //"Erro de Schema"#"Fechar"
				Else
					If T0X->T0X_TPERRO = 'P' .And. (cAliasDet)->XSTATUS == '1'
						Aviso(STR0244, STR0165 + T0X->T0X_PREDEC, {STR0246}, 3 ) //"Erro de Predecessão"#"Fechar"
					Else
						MsgAlert(STR0242) //"Não há Inconsistências para este registro ."
					EndIf
				EndIf
			ElseIf (cAliasDet)->XSTATUS == '1'

				aEvento := TAFRotinas(cEvento,4,.F.,2)
				cFuncao	:= aEvento[2]
				&cFuncao.(aEvento[3],(cAliasDet)->RECNO)
			ELseIf !Empty((cAliasDet)->MENSG) .And. (cAliasDet)->XSTATUS == '3'

				ShowLog(STR0247, ( cAliasDet )->RETGOV, xIdentXML( AllTrim(( cAliasDet )->XMLERRO) ))
			Else

				MsgInfo("Não foi possivel obter a mensagem de inconsitência. ","Consulta de Status")
			EndIf

		ElseIf (cAliasDet)->XSTATUS == '2' //.And. !Empty((cAliasDet)->HISTPROC)

			aParamFil[1] := .T.
			aParamFil[2] := (cAliasDet)->FILIAL
			aParamFil[3] := AllTrim(SM0->M0_FILIAL)
			aParamFil[4] := AllTrim(SM0->M0_CGC)
			aParamFil[5] := AllTrim(SM0->M0_INSC)
			aParamFil[6] := ""

			aEvento := TAFRotinas(cEvento,4,.F.,2)
			aRetTSS := TAFProc5Tss(.F.,{aEvento},'2',,cValToChar((cAliasDet)->RECNO),.F.,,{aParamFil},,,,.F.,@cIdEntTSS,,.T.,@oTabFilSel)

			If Len(aRetTSS) > 0 .And. Len(aRetTSS[1]) > 0
				If !Empty(aRetTSS[1][1]:CHISTPROC)
					If parseJsonTSS(aRetTSS[1][1]:CHISTPROC,@cMsg)
						Aviso(STR0243,cMsg, {STR0246}, 3 ) //"Status do processo retorno TSS"#"Fechar"
					Else
						MsgInfo(" Aguardando processamento no TSS. Aguarde mais alguns minutos. ",STR0243)
					EndIf
				Else
					MsgInfo("Aguardando Processamento no TSS. Status : " + aRetTSS[1][1]:CDETSTATUS,"Consulta de Status")
				EndIf

				FreeObj(aRetTSS[1][1])
				aSize(aRetTSS,0)
			Else
				MsgInfo("Aguardando Processamento no TSS.","Consulta de Status")
			EndIf

		Else
			MsgAlert(STR0242,"Aviso") //"Não há Inconsistências para este registro ."
		EndIf
	EndIf 

	//Retorna filial original
	cFilAnt := cFilBkp


Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} parseJsonTSS

Realiza o parser da mensagem de numero de tentativas do TSS

@param cJson - String com o Json
@param cDetalhe - Descrição formatada da mensagem Json

@return - Indica que a mensagem foi formatada


@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function parseJsonTSS(cJson,cDetalhe)

	Local lRet := .F.
	Local ojson := Nil

	If FwJsonDeserialize(cJson, @ojson)

		cTentativas	:= ojson:log:tentativas

		cDetalhe := "Histórico do processo TSS:" + Chr(10) + Chr(13) + ""
		cDetalhe += Alltrim(Decode64(ojson:log:detalhe)) +  Chr(10) + Chr(13)
		cDetalhe += "Numero de Tentativas : " + AllTrim(cTentativas)
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe o log com inconsistências encontradas durante o processamento.

@Param		cTitulo	-	Título da interface
			cHeader	-	Cabeçalho da inconsistência
			cBody	-	Mensagem de inconsistência

@Author		Felipe C. Seolin
@Since		17/01/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ShowLog( cTitulo, cHeader, cBody )

	Local oModal	as object

	oModal	:=	Nil

	oModal := FWDialogModal():New()
	oModal:SetTitle( cTitulo )
	oModal:SetFreeArea( 290, 250 )
	oModal:SetEscClose( .T. )
	oModal:SetBackground( .T. )
	oModal:CreateDialog()

	TMultiGet():New( 030, 020, { || cHeader + Chr( 13 ) + Chr( 10 ) + Chr( 13 ) + Chr( 10 ) + cBody }, oModal:GetPanelMain(), 250, 190,,,,,, .T.,,,,,, .T.,,,,, .T. )

	oModal:Activate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FTrataEvt
Adequa array de eventos para a rotina
@author evandro.oliveira
@since 07/03/2016
@version 1.0
@param xEvento, variável, (Eventos não normalizados)
@param lEvtsRot, lógico,(determina se o parâmetro xEvento já vem com as informações do TafRotinas quando o mesmo for do tipo Array)
@param lMultTp, lógico,(Informa se os eventos selecionados são de + de 1 tipo ex: tabelas,periodios etc..)
@param lMaisD1, lógico,(Indica que será exibido mais de 1 evento)
@return ${aEventos}, ${Eventos normalizados}
/*/
//---------------------------------------------------------------------
Static Function FTrataEvt(xEvento, lEvtsRot, lMultTp, lMaisD1)

	Local aEvents	:= {}
	Local nX		:= 0
	Local cAuxTp	:= ""

	If ValType(xEvento) == "C"

		aAdd(aEvents,TAFRotinas( xEvento ,4,.F.,2))

	Else

		If lEvtsRot
		
			aEvents := xEvento

		Else

			For nX := 1 To Len(xEvento)

				aAdd(aEvents,TAFRotinas( xEvento[nX] ,4,.F.,2))

				If aTail(aEvents)[12] <> cAuxTp .And. nX <> 1
					lMultTp := .T.
				ElseIf nX > 1
					cAuxTp := aTail(aEvents)[12]
				EndIf

			Next nX

		EndIf

		lMaisD1 := IIf(Len(aEvents) > 1,.T.,.F.)

	EndIf

Return (aEvents)

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanStus
Cria painel de cabeçalho e rodapé do Browse.
Estes paineis contem os totalizadores.
@author evandro.oliveira
@since 25/02/2016
@version 1.0
@param oPanel, objeto, (Variavel referente ao objeto Panel)
@param oOwner, objeto, (Objeto que sera criado o Panel)
@param nTitulo, numérico, (Titulo do Painel)
@param nTotRegs, numérico, (Total de registros exibidos no Browse)
@param nPenAnt, numérico, (Total de registros pendentes do Browse)
@param nPenDep, numérico, (Total de registros pendentes após ajustes)
@param nAjust, numérico, (Total de registros ajustados)
@param lConxTSS, logico , (Informa se ha conexao com servidor TSS)
@param aIDsSel, array, (Ids do Trabalhador)
@param cIDBrowse, char, (Identificador do Browse que está "chamando" a função")
@param lCancel, char, (Variavel que controla o cancelamento da barra de processo)
@param lTempTable, logico , (Indica se o arquivo de trabalho foi criado no banco)
@param cArqTrbDet, character, arquivo de trabalho do monitor de detalhamento
@param FPanStus, logico, Determina se o campo TAFOWNER deve ser criado.
@return ${Nil}
/*/
//---------------------------------------------------------------------
Static Function FPanStus(oPanel, oOwner, nTitulo, nTotRegs, nPenAnt, nPenDep, nAjust, lMaisD1, cStatus, aEvents, lMultTp, aCampos, lConxTSS, aIDsSel,cIDBrowse,lCancel,oProcess,lTempTable,cArqTrbDet,oTabFilSel,dDtIni,dDtFim,lTafOwner)

	Local nLin			:= 010
	Local cMsgHelp		:= ""
	Local oBtSair		:= Nil
	Local oBtot			:= Nil 
	Local cMsgAmb		:= ""
	Local cAmbEsocial	:= GetNewPar( "MV_TAFAMBE", "3" )
	Local cNmAmb		:= ""
	Local nPosB1		:= 0
	Local nPosB2		:= 0
	Local nPosB3		:= 0

	Default lTafOwner   := .F. 

	//Verifica qual tipo de ambiente foi configurado
	//pela wizard de configuração do esocial
	If cAmbEsocial == "1"
		cNmAmb := STR0171 //Produção
	ElseIf cAmbEsocial == "2"
		cNmAmb := STR0172 //Pré-produção - dados reais
	Else
		cNmAmb := STR0173 //Pré-produção - dados fictícios
	EndIf

	oPanel:= TPanel():New(00,00,"",oOwner,,.F.,.F.,,,0,0,.T.,.F.)
	oPanel:Align = CONTROL_ALIGN_ALLCLIENT
	If lFindClass .And. !(GetRemoteType() == REMOTE_HTML) .And. !(FWCSSTools():GetInterfaceCSSType() == 5)
		oPanel:setCSS(QLABEL_AZUL_A)
	EndIf

	cMsgAmb := "<font size='2' color='RED'>"
	cMsgAmb +=  STR0170 + "<b>" + cNmAmb +"</b>" //Ambiente do eSocial configurado para transmissão de Eventos
	cMsgAmb += "</font>"
	oSayAmb := TSay():New(002,005,{||cMsgAmb},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

	oSaySI := TSay():New(nLin,005,{||IIf(nTitulo == 1,STR0131,STR0132)},oPanel,,,,,,.T.,,,100,030,,,,,,.F.) //"Status Inicial:"#"Status pós-ajustes:"

	If nTitulo==2

		oSayPenR := TSay():New(nLin,oPanel:NCLIENTWIDTH * 0.20,{||STR0134 + '<font size="3"><b>' + AllTrim(Str(nPenDep)) + '</b>' },oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Pendentes:
		oSayAju  := TSay():New(nLin,oPanel:NCLIENTWIDTH * 0.35,{||STR0135 + '<font size="3"><b>' + AllTrim(Str(nAjust)) + '</b>' },oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Ajustados:

		nLin+= (oPanel:NCLIENTHEIGHT * 0.15)
		oSayTR := TSay():New(oPanel:NCLIENTHEIGHT -(oPanel:NCLIENTHEIGHT * 0.7),005,{||'<font size="3">' + STR0133 + '<b>' + AllTrim(Str(nTotRegs)) + '</b>'},oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Total de Registros:

		If TAFAlsInDic("V2J") .And. (cIDBrowse $ "Eventos|EvtsPer|Trabalhador")
			nPosB1 := oPanel:NCLIENTWIDTH * 0.40
			nPosB2 := oPanel:NCLIENTWIDTH * 0.33
			nPosB3 := oPanel:NCLIENTWIDTH * 0.26
		Else
			nPosB1 := oPanel:NCLIENTWIDTH * 0.37
			nPosB2 := oPanel:NCLIENTWIDTH * 0.30	
		EndIf 

		If cIDBrowse $ "Tabelas" .And. TAFAlsInDic("V2J") 
			oBtot := TButton():New(oPanel:NCLIENTHEIGHT -(oPanel:NCLIENTHEIGHT * 0.70),nPosB3,"Re-avaliar Totalizadores",oPanel,{||consultaTotalizador(aIDsSel,@oTabFilSel,dDtIni,dDtFim,cIDBrowse)}, 850,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Consultar Totalizadores"
			oBtot:SetCSS(BTNLINK)
		EndIf 

		oBttRvd  := TButton():New(oPanel:NCLIENTHEIGHT -(oPanel:NCLIENTHEIGHT * 0.70),nPosB1, STR0136,; //"Re-avaliar Pendencias"
		oPanel,{||FWMsgRun(,{|oMsgRun|FAtuPan(lMaisD1,cStatus,aEvents,lMultTp,aCampos,@nTotRegs,nPenAnt,@nPenDep,@nAjust,lConxTSS,aIDsSel,cIDBrowse,@lCancel,@oProcess,lTempTable,cArqTrbDet,@oTabFilSel,,lTafOwner,oMsgRun)},STR0137,STR0138)}, 65,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Validação"#"Re-Avalidando os registros"
		oBttRvd:SetCSS(BTNLINK) //CSSBOTAO

		If TAFAlsInDic("V2J") .And. (cIDBrowse $ "Eventos|EvtsPer|Trabalhador") 
			oBtot := TButton():New(oPanel:NCLIENTHEIGHT -(oPanel:NCLIENTHEIGHT * 0.70),nPosB3,"Re-avaliar Totalizadores",oPanel,{||consultaTotalizador(aIDsSel,@oTabFilSel,dDtIni,dDtFim,cIDBrowse)}, 75,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Consultar Totalizadores"
			oBtot:SetCSS(BTNLINK)
		EndIf 
			
		oBtSair := TButton():New(oPanel:NCLIENTHEIGHT -(oPanel:NCLIENTHEIGHT * 0.70),oPanel:NCLIENTWIDTH * 0.47, STR0106,oPanel,{||oDlg1:End()}, 30,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"
		oBtSair:SetCSS(CSSBOTAO)

	Else

		nLin+= (oPanel:NCLIENTHEIGHT * 0.112)
		oSayTR := TSay():New(nLin,005,{||'<font size="3">' + STR0133 + '<b>' + AllTrim(Str(nTotRegs)) + '</b>'},oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Total de Registros:


		oSayPenC := TSay():New(nLin,oPanel:NCLIENTWIDTH * 0.20,{||'<font size="3">' + STR0134 +' <b>' + AllTrim(Str(nPenAnt)) + '</b>' },oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Pendentes:

		nLin += (oPanel:NCLIENTHEIGHT * 0.11)

		cMsgHelp := FONT_HELP_1
		cMsgHelp += STR0140 + ' <b>' + STR0141 + '</b> ' + STR0145 + ' <b>' + STR0142 + '</b>. '  //São considerados pendentes os registros cujo o status é igual a#INVÁLIDO#INCONSISTENTE
		cMsgHelp += STR0143 //'Clicando 2 vezes em cima de um registro será aberto uma janela para edição do mesmo caso o status seja igual '
		cMsgHelp += STR0144 //'a um dos dois citados anteriormente, caso contrario a janela será aberta em modo de visualização.'
		oSHelp	:= TSay():New(nLin,005,{||cMsgHelp},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuPan
Atualiza as informações do browse
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param lMaisD1, ${param_type}, (Indica que existe mais de 1 evento no browse)
@param cStatus, character, (Status de acordo com a parametrização inicial)
@param aEvents, array, (Array com as informações do evento)
@param lMultTp, ${param_type}, (Indica que existe eventos de diferentes
tipos ex: Periodicos,Não Periodicos etc..)
@param aCampos, array, (Campos do browse)
@param nTotRegs, numérico, (Numero total de registros no browse)
@param nPenAnt, numérico, (Numero de registros pendentes Inicialmente)
@param nPenDep, numérico, (Numero de registros pendentes após a re-avalição
dos itens)
@param nAjust, numérico, (Numero de registros ajustados)
@param lConxTSS, logico , (Informa se ha conexao com servidor TSS)
@param aIDsSel, array, (Ids do Trabalhador)
@param lCancel, logico, (variavel de controle do cancelamento da barra de processo)
@param cArqTrbDet, character, arquivo de trabalho do monitor de detalhamento
@param lTafOwner -Indica que o campo TAFOWNER deve ser criado na query

@return ${Nil}
/*/
//---------------------------------------------------------------------
Static Function FAtuPan( lMaisD1, cStatus, aEvents, lMultTp, aCampos, nTotRegs, nPenAnt, nPenDep, nAjust, lConxTSS, aIDsSel, cIDBrowse,lCancel,oProcess,lTempTable,cArqTrbDet,oTabFilSel, lReavPen,lTafOwner,oMsgRun)

	Local cErroSQL    := ""
	Local cRecNos     := ""

	Default lReavPen  := .F.
	Default lTafOwner := .F.

	lEnd := .F.

	If FindFunction("FTableTSSErr")

		TafDelTempTable(cArqREtTss:GetRealName(),@cErroSQL)

		If !Empty(cErroSQL)
			MsgInfo(cErroSQL,"Exclusão de Tabela Temporaria")
		EndIF

	EndIf

	TAFProc5Tss(.F.,aEvents,"'2','3'",aIdsSel,,lEnd,,paramFiliais,paramDataInicial,paramDataFim,,,,,,@oTabFilSel,, lReavPen,oMsgRun)

	cQuery :=BuildTemp( cStatus, aEvents, aIDsSel, cIDBrowse, aCampos, @nTotRegs, lConxTSS, nPenAnt, @nPenDep, lMaisD1, .T.,@lCancel,@oProcess,@oTabFilSel, cRecNos,lTafOwner)
	oMBrowse:lTemporary := .T.
	oMBrowse:SetQuery(cQuery) 
	oMBrowse:Refresh(.T.)
	
	oMBrowse:GoTop()

	nTotRegs := geTotalRegs(oMBrowse)
	nPenDep := geTotalRegs(oMBrowse,'pendAnt')
	nAjust := nPenAnt - nPenDep

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} TafVldNProc

Função chamada para validar registros não processados considerando a
filial do registro

@Author	Felipe Rossi Moreira
@Since	21/03/2018

@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TafVldNProc()

	Local nF			as numeric
	Local cOrigFilAnt	as char
	Local aFiliais		as array
	Local aAreaDet		as array

	aAreaDet    := (cAliasDet)->( GetArea() )
	cOrigFilAnt := cFilAnt
	aFiliais    := {}

	//Verifica as filiais na lista
	(cAliasDet)->( dbGoTop() )
	While (cAliasDet)->( !Eof() )

		If !Empty((cAliasDet)->FILIAL) .And. (aScan(aFiliais, (cAliasDet)->FILIAL) <= 0)
			aAdd(aFiliais, (cAliasDet)->FILIAL)
		EndIf

		(cAliasDet)->( dbSkip() )

	EndDo

	//Executa a fiial para cada filial
	For nF := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nF]
		TAFAINTEG(,3,,,,,"3")
	Next nF

	cFilAnt := cOrigFilAnt
	(cAliasDet)->( RestArea(aAreaDet) )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} BuildTemp

Construção da consulta a banco de dados para preenchimento do arquivo temporário.

@Param		cStatus		-	Status de filtro dos registros
			aEvents		-	Eventos selecionados
			aIDsTrb		-	IDs do(s) trabalhador(es) selecionados
			cIDBrowse	-	Identificador do Browse executor
			aCampos		-	Campos para tabela temporária
			nTotRegs	-	Contador do total de registros ( referência )
			lConxTSS	-	Indicador do conexão com TSS
			nPenAnt		-	Contador de registros pendentes ( referência )
			nPenDep		-	Contador de registros pendentes após ajuste ( referência )
			lMaisD1		-	Indicador de seleção de mais de 1 evento
			lUpdate		-	Indicador de execução de Atualização do Painel
			lCancel		- 	Variavel de controle do botão de cancelamento da barra de processo
			oProcess	-   Objeto MSNewProcess
						lTafOwner   -   Indica que o campo TAFOWNER deve ser incluido na query

@Author		Felipe C. Seolin
@Since		14/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function BuildTemp( cStatus, aEvents, aIDsTrb, cIDBrowse, aCampos, nTotRegs, lConxTSS, nPenAnt, nPenDep, lMaisD1, lUpdate ,lCancel,oProcess, oTabFilSel, cRecNos,lTafOwner )

	Local cQuery		:= ""
	Local cAuxDesc		:= ""
	Local cBanco		:= AllTrim(TCGetDB())
	Local cTAFKEY		:= ""
	Local cAuxFil		:= ""
	Local cAuxTrab		:= ""
	Local cAliasLay		:= ""
	Local cLayout		:= ""
	Local cDescEvt		:= ""
	Local cNomeFunc		:= ""
	Local cTagEvt		:= ""
	Local cIdTrab		:= ""
	Local cCmpData		:= ""
	Local cTipoEvt		:= ""
	Local cCmpDescr		:= ""
	Local cRelacTrb		:= ""
	Local cConcat		:= ""
	Local cIniEsoc		:= SuperGetMv('MV_TAFINIE',.F.," ")
	Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_04_01")
	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 0
	Local nRange		:= 5
	Local nVolume		:= 1
	Local nI			:= 0
	Local aTAFKEY		:= {}
	Local lTAFKEY		:= .F.
	Local lVirgula		:= .F.
	Local lEvtMarcado	:= .F.
	Local cIndApu		:= ""

	Default aIDsTrb		:= {}
	Default lUpdate		:= .F.
	Default cIDBrowse	:= ""
	Default lCancel		:= .F.
	Default oTabFilSel	:= Nil
	Default cRecNos		:= ""
	Default lTafOwner   := .F.

	//Zerar contadores a cada vez que executar a construção do temporário
	nTotRegs := 0
	nPenDep := 0

	If !Empty( paramTAFKEY )

		aTAFKEY	:=	StrToKArr( paramTAFKEY, "," )

		For nX := 1 to Len( aTAFKEY )
			cTAFKEY += "'" + AllTrim( aTAFKEY[nX] ) + "'" + ","
		Next nX

		cTAFKEY := SubStr( cTAFKEY, 1, Len( cTAFKEY ) - 1 )

		lTAFKEY	:= !Empty( cTAFKEY )

	EndIf

	//Verifica se o Evento foi Selecionado //Realizar Refatoração desta função
	For nX := 1 To Len(aEventosParm)

		If aEventosParm[nX][2]

			For nI := 1 To Len(aEventosParm[nX][1])

				nPos := aScan(aEvents,{|x|x[4] == aEventosParm[nX][1][nI][2] })
				If nPos > 0
					aEventosParm[nX][1][nI][12] := .T.
				Else
					aEventosParm[nX][1][nI][12] := .F.
				EndIf

			Next nI

		EndIf

	Next nX

	If cBanco $ "POSTGRES|ORACLE|DB2|INFORMIX|OPENEDGE"
		cConcat := " || " 
	Else
		cConcat := " + " 
	EndIf 

	For nI := 1 To Len(aEventosParm)

		If lCancel //Cancelamento da barra de processo
			nI := Len(aEventosParm)+1
		EndIf

		nEventos := Len(aEventosParm[nI][1])

		//Verifico se o Tipo de Evento foi Marcado e se o mesmo faz parte do escopo da query, tenho que pegar os mensais e os eventuais por
		//causa dos eventos que não tem relação com o trabalhador.
		If nEventos > 0 .And. aEventosParm[nI][2] .And. aEventosParm[nI][3] $ EVENTOS_INICIAIS[2] + EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2]

			For nX := 1 To nEventos

				lEvtMarcado	:= aEventosParm[nI][1][nX][12]

				If lEvtMarcado

					cAliasLay := aEventosParm[nI][1][nX][1] //Alias do Evento
					cLayout   := aEventosParm[nI][1][nX][2] //Layout
					cDescEvt  := aEventosParm[nI][1][nX][3] //Descrição do evento
					cNomeFunc := aEventosParm[nI][1][nX][4] //Função de geração do XML
					cTagEvt   := aEventosParm[nI][1][nX][5] //Tag de Identificação do Evento
					cIdTrab   := aEventosParm[nI][1][nX][6] //Nome do campo relativo ao Id do Trabalhador
					cCmpData  := aEventosParm[nI][1][nX][7] //Campo que determina o periodo ou data do evento
					cTipoEvt  := aEventosParm[nI][1][nX][8] //Tipo do Evento
					cCmpDescr := aEventosParm[nI][1][nX][10] //Campo de descrição do evento no monitor do e-Social. Deve ser um campo que identifique o registro ex: Nome do trabalhador, Desc. Rubrica etc.
					cRelacTrb := aEventosParm[nI][1][nX][11] //Define se o evento tem relação com o Trabalhador

					//Verifico se o tipo de evento é correspondente ao browse se não for eu pulo.
					If cIDBrowse $ "Eventos|EvtsPer|Trabalhador" .And. (cTipoEvt == EVENTOS_INICIAIS[2] .Or. cRelacTrb == "S")
						Loop
					EndIf

					If cIDBrowse == "Tabelas" .And. (cTipoEvt != EVENTOS_INICIAIS[2]  .And. (cTipoEvt $ EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2] .And. Empty(cRelacTrb)))
						Loop
					EndIf

					If !Empty( AllTrim( cQuery ) )
						If nVolume > nRange
							cQuery := ChangeQuery( cQuery )
							nVolume := 1
							cQuery := ""
						Else
							cQuery += " UNION ALL "
							nVolume++
						EndIf
					EndIf

					//Se for banco informix faz um select para agrupar os "Unions"
					If Upper(cBanco) == "INFORMIX" .AND. Empty(cQuery)
						cQuery += "SELECT * " //faço um select * por que os campos já estão filtrados na subquery do FROM, desta maneira diminuimos a chances de erro.		
						cQuery += "FROM ( "
					EndIf

					cQuery += "SELECT DISTINCT '" + cLayout + "' EVENTO "						
					cQuery += " ," + cAliasLay + "." + cAliasLay + "_FILIAL FILIAL "			

					If lTafOwner

						If TafColumnPos(cAliasLay + "_OWNER")
							cQuery += " ," + cAliasLay + "." + cAliasLay + "_OWNER TAFOWNER "	
						Else
							cQuery += " , ' ' TAFOWNER "	
						EndIf	

					Endif

					cQuery += " , " + cAliasLay + "." + cAliasLay + "_STATUS XSTATUS "
					cQuery += " ,CASE WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = ' ' THEN 'Não Processado' "
					cQuery += "  WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = '0' THEN 'Válido - Pronto para Transmissão' "
					cQuery += "  WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = '1' THEN 'Inválido' "
					cQuery += "  WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = '2' THEN 'Aguardando Retorno do Governo' "
					cQuery += "  WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = '3' THEN 'Inconsistente' "
					cQuery += "  WHEN " +  cAliasLay + "." + cAliasLay + "_STATUS = '4' THEN 'Aceito pelo RET' "
					cQuery += "  END 	DESCSTATUS "

	//				cQuery += " ,TAFKEY TAFKEY "
					cQuery += " , CAST(" + cAliasLay + "." + cAliasLay + "_ID AS CHAR(36) ) ID "

					If Select(cAlsCodTab) > 0 .AND. aEventosParm[nI][3] == EVENTOS_INICIAIS[2]

						cQuery += " , ISNULL(DESCR_TAB.CODIGO,' ') CODIGO "
						cQuery += " , ISNULL(DESCR_TAB.DESCRICAO,' ') DESCR "

					Else

						If cTipoEvt == EVENTOS_EVENTUAIS[2]
							cAuxDesc := getDescrPeriodicos(cLayout)
						ElseIf cTipoEvt == EVENTOS_MENSAIS[2]
							cAuxDesc := getDescrNaoPeriodicos(cLayout)
						Else
							cAuxDesc := "' '"
						EndIf

						cQuery += " ,' ' CODIGO "

						If  Empty( cAuxDesc )
							cQuery += " , CAST(' ' AS CHAR(100)) DESCR "
						Else
							If cBanco == "ORACLE"
								cQuery += " , ISNULL( SUBSTR(" + cAuxDesc + ",1,100), CAST('  ' AS CHAR(100)) ) DESCR "
							Else
								cQuery += " , ISNULL(" + cAuxDesc + ", CAST(' ' AS CHAR(100)) ) DESCR "
							EndIf
						EndIf

					EndIf

					If cTipoEvt == EVENTOS_INICIAIS[2]
						cQuery += " ," + cAliasLay + "." + cAliasLay + "_DTINI INIVALD "
						cQuery += " ," + cAliasLay + "." + cAliasLay + "_DTFIN FINVALID "
					Else
						cQuery += " ,' ' INIVALD "
						cQuery += " ,' ' FINVALID "
					EndIf

					If cTipoEvt <> EVENTOS_MENSAIS[2]
						cQuery += " , ' ' INDAPU "
						cQuery += " ,' ' PERAPU "
					Else
						cQuery += " ," + cAliasLay + "." + cAliasLay + "_INDAPU INDAPU "
						cQuery += " ," + cAliasLay + "." + cAliasLay + "_PERAPU PERAPU "
					EndIf

					cQuery += " , ISNULL(RETTSS.V2H_DETAIL,' ')  MENSG "					//
					cQuery += " ,'"+space(10)+"' XMLERRO "
					cQuery += " ,'"+space(10)+"' DATALI "
					cQuery += " ,'"+space(255)+"' REGRA "
					cQuery += " , ISNULL(RETTSS.V2H_DSCREC,' ') RETGOV "
					cQuery += " ,'"+space(10)+"' HISTPROC "
					cQuery += " , ISNULL(RETTSS.V2H_CODREC,' ') CODRECEITA "
					cQuery += " ,'"+space(1)+"' STATUSTSS "

					cQuery += " ," + cAliasLay + "." + cAliasLay + "_PROTUL RECIBO "
					cQuery += " ," + cAliasLay + "." + cAliasLay + "_VERSAO VERSAO "
					cQuery += " ," + cAliasLay + ".R_E_C_N_O_ RECNO "
					cQuery += " ,'" + cNomeFunc + "' FUNCAO "
					cQuery += " ,'" + cAliasLay + "' ALIAS "
					cQuery += " ,'" + cLayout + "' LAYOUT "
			//		cQuery += " ,'" + cTagEvt + "' CREGNODE "
					cQuery += " ,'" + cAliasLay + "' TABELA "

					If TafColumnPos( cAliasLay + "_STASEC" )
						cQuery += " ," + cAliasLay + "_STASEC EXTEMP "
					Else
						cQuery += " , ' ' EXTEMP "
					EndIf

					If TafColumnPos( cAliasLay + "_XMLREC" )
						cQuery += " ," + cAliasLay + "_XMLREC XMLENV "
					Else
						cQuery += " , CAST(' ' AS CHAR(4)) XMLENV "
					EndIf

					If cLayout $ "S-1200|S-1210|S-1295|S-1299|S-2299|S-2399|S-2501|"

						If TafColumnPos(cAliasLay+"_GRVTOT")

							cQuery += " , CAST( CASE WHEN " + cAliasLay + "_GRVTOT = 'T' THEN 'Gravado' "
							cQuery += " WHEN " + cAliasLay + "_GRVTOT = 'F' THEN 'Não Gravado' "
							cQuery += " END AS CHAR(50) ) TOTALIZD "
						Else
							cQuery += ", '" + PADR(' ',50) + "' TOTALIZD "
						EndIf 

					Else
						cQuery += ", CAST( '" + PADR('Não há totalizadores para este evento.',50) + "' AS CHAR(50) ) TOTALIZD "
					EndIf 

					If cLayout $ cEvtsTrab 
						cQuery += " ," + cAliasLay + "." + cIdTrab + " CIDTRAB "
					Else 
						cQuery += " , ' ' CIDTRAB " 
					EndIf  

					If cLayout == "S-1200" .Or. cLayout == "S-1210"
						cQuery += " ," + cAliasLay + "." + cAliasLay + "_CPF " + " CPFMV "
					Else 
						cQuery += " , ' ' CPFMV " 
					EndIf  

					cQuery += "FROM " + RetSqlName( cAliasLay ) + " " + cAliasLay + " "

					If cLayout == "S-2200"

						cQuery += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
						cQuery += " AND C9V_ID = CUP_ID "
						cQuery += " AND C9V_VERSAO = CUP_VERSAO "
						cQuery += " AND CUP.D_E_L_E_T_ <> '*' "
						cQuery += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,,,cTipoEvt)

					EndIf

					If  TAFAlsInDic("V2H") 

						cQuery += " LEFT JOIN " + RetSqlName("V2H") + " RETTSS ON "
						cQuery += " RETTSS.V2H_FILIAL = " + cAliasLay + "." + cAliasLay + "_FILIAL "
						cQuery += " AND RETTSS.V2H_IDCHVE = '" + StrTran(cLayout,"-","") + "'" + cConcat + cAliasLay + "." + cAliasLay + "_FILIAL  " + cConcat + cAliasLay + "." + cAliasLay + "_VERSAO "

					Else 
						//Retirar posteriormente, mantido somente para não gerar error em clientes sem atualização
						If FindFunction("FTableTSSErr")
							cQuery += " LEFT JOIN " + cArqREtTss:GetRealName() + " RETTSS ON "
							cQuery += " RETTSS.FILIAL = " + cAliasLay + "." + cAliasLay + "_FILIAL "
							cQuery += " AND RETTSS.ID = " + cAliasLay + "." + cAliasLay + "_ID "
							cQuery += " AND RETTSS.EVENTO = '" + cLayout + "'"
						EndIf
					EndIf 

					If Select(cAlsCodTab) > 0 .AND. aEventosParm[nI][3] == EVENTOS_INICIAIS[2]
						cQuery += " LEFT JOIN " + cArqCodTabs:GetRealName()  + " DESCR_TAB ON "
						cQuery += " DESCR_TAB.FILIAL = " + cAliasLay + "." + cAliasLay + "_FILIAL "
						cQuery += " AND DESCR_TAB.EVENTO = '" + cLayout  + "' "
						cQuery += " AND DESCR_TAB.ID = " + cAliasLay + "." + cAliasLay + "_ID "
		//				cQuery += " AND DESCR_TAB.VERSAO = " + cAliasLay + "." + cAliasLay + "_VERSAO "

					EndIf

					//Filtro do TAFKEY retirado, olhar historico do fonte caso seja necessário implementa-lo novamente

					If "'" $ cStatus
						cQuery += "WHERE " + cAliasLay + "." + cAliasLay + "_STATUS IN (" + cStatus + ") "
					Else
						cQuery += "WHERE " + cAliasLay + "." + cAliasLay + "_STATUS IN ('" + cStatus + "') "
					EndIf

					If cAliasLay == "C9V" .or. cAliasLay == "C91"
						cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = '" + StrTran( cLayout, "-", "" ) + "' "
					EndIf
					
					If TafColumnPos( cAliasLay + "_OWNER" ) .AND. (cAliasLay == "C91" .OR. cAliasLay == "T3P")
						cQuery += GetOwner(cAliasLay,aParamES[16])
					EndIf

					If !Empty(AllTrim(cRecNos))
						cQuery += "  AND " + cAliaslay + ".R_E_C_N_O_ IN (" + cRecNos + ")"
					EndIf

					cQuery += "  AND " + cAliasLay + ".D_E_L_E_T_ <> '*' "

					If cAliasLay == "CM6"
						cQuery += "  AND ( CM6_ATIVO = '1' OR CM6_STASEC = 'E' OR ( CM6_ATIVO = '2' AND CM6_STATUS NOT IN ('4','7') AND CM6_PROTUL = ' ' ) )"
					ElseIf TafColumnPos( cAliasLay + "_STASEC" )
						cQuery += "  AND (" + cAliasLay + "." + cAliasLay + "_ATIVO = '1'  OR " + cAliasLay + "." +cAliasLay + "_STASEC = 'E' )"
					Else
						cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "
					EndIf

					//Os Eventos de tabela não usam o S-3000 por isso eu considero o Status E
					If cTipoEvt != EVENTOS_INICIAIS[2]
						cQuery += " AND " + cAliasLay + "_STATUS <> 'E'
					EndIf

					If cTipoEvt == EVENTOS_MENSAIS[2] .Or. cAliasLay $ "CMJ"
						
						If lLaySimplif
							
							cIndApu := Space(GetSx3Cache(cAliasLay + "_INDAPU", "X3_TAMANHO"))
						
						EndIf

						cQuery += " AND ( "
						
						If !lLaySimplif

							cQuery += " (" + cAliasLay + "_INDAPU = '1' "

						Else

							cQuery += " ((" + cAliasLay + "_INDAPU = '1' "
							cQuery += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cQuery += " AND " + cAliasLay + "." + cCmpData + " >= '" + AnoMes(paramDataInicial) + "'"
						cQuery += " AND " + cAliasLay + "." + cCmpData + " <= '" + AnoMes(paramDataFim) + "')"

						If !lLaySimplif

							cQuery += " OR (" + cAliasLay + "_INDAPU = '2' "

						Else

							cQuery += " OR ((" + cAliasLay + "_INDAPU = '2' "
							cQuery += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cQuery += " AND " + cAliasLay + "." + cCmpData +  " BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')"
						cQuery += " OR (" + cAliasLay + "_INDAPU = '" + cIndApu + "' "
						cQuery += " AND " + cAliasLay + "." + cCmpData + " = ' ' AND '" + cAliasLay + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
						cQuery += ")"

					ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"

						cQuery += " AND "
						
						If cAliasLay == "V3C"
							cQuery += "(( "	
						EndIf

						cQuery += cAliasLay + "." + cCmpData + " >= '" + DtoS(paramDataInicial) + "'"
						cQuery += " AND " + cAliasLay + "." + cCmpData + " <= '" + DtoS(paramDataFim) + "'"

						If cAliasLay == "V3C"
							cQuery += ") OR " + cCmpData + " = '' )"		
						EndIf

					EndIf

					//Só pego S-1000 da matriz
					If cAliasLay == "C1E"
						cQuery += " AND C1E_MATRIZ = 'T' "
					EndIf

					If cLayout == "S-2300"
						cQuery += TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
					EndIf

					If cAliaslay ==  "CM6"
						cQuery+= " AND (( "
						cQuery+= TafMonPAfast(cVerSchema)
						cQuery+= " ) "
					EndIf

					/*+--------------------------------------------------------------------------------------+
					| Quando a variável aIDsTrb está preenchida, foi realizada uma ou mais seleções        |
					| no Browse do Trabalhador, neste caso precisa filtrar por Id + Filial do Trabalhador. |
					+--------------------------------------------------------------------------------------+*/
					If Len( aIDsTrb ) > 0 .And. cTipoEvt != EVENTOS_INICIAIS[2] .And. Empty(cRelacTrb)

						For nY := 1 to Len( aIDsTrb )

							If nY == 1
								cQuery += "  AND ( "
							Else
								cQuery += " OR "
							EndIf

							cQuery += " ( " + cAliasLay + "." + cAliasLay + "_FILIAL = '" + aIDsTrb[nY][1] + "' "
							cQuery += " AND " + cAliasLay + "." + cIdTrab + " IN ("

							lVirgula := .F.

							For nZ := 1 to Len( aIDsTrb[nY][2] )
								Iif( lVirgula, cAuxTrab += ",", )
								cAuxTrab += "'" + aIDsTrb[nY][2][nZ] + "'"
								lVirgula := .T.
							Next nZ

							cQuery += cAuxTrab
							cQuery += " ) ) "
							cAuxTrab := ""

						Next nY

						cQuery += " ) "

					Else

						If paramVisao == 1 .Or. (cTipoEvt == EVENTOS_INICIAIS[2]) .Or. cRelacTrb == "S"

							/*+--------------------------------------------------------------------------+
							| Quando o aIDsTrb está vazio, foi chamada de um duplo-clique ou do browse |
							| de tabelas. Neste caso, pego as filiais selecionadas na tela de filtro.  |
							+--------------------------------------------------------------------------+*/

							If cAliasLay == "C1E"
								cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_FILTAF IN ( "
							Else
								cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_FILIAL IN ( "
							Endif

							cAuxFil := TafMonPFil(cAliasLay,@oTabFilSel,paramFiliais)

							cQuery += cAuxFil
							cQuery += " ) "
							cAuxFil := ""

						Else

							/*+-----------------------------------------------------------------+
							| Na Visão por Trabalhador, pego as informações de Filial e Id do |
							| Trabalhador do registro posicionado no Browse do Trabalhador.   |
							+-----------------------------------------------------------------+*/
							cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_FILIAL = '" + ( cAliasTrb )->C9V_FILIAL + "' "
							cQuery += "  AND " + cAliasLay + "." + cIdTrab + " = '" + ( cAliasTrb )->C9V_ID + "' "

						EndIf

					EndIf

					If cAliaslay ==  "CM6"
						cQuery += ")"
					EndIf

					//Só considera Evento do eSocial
					If AllTrim( cLayout ) $ "S-1070"

						cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_ESOCIA = '1' "
						//INCLUSÃO DE TRECHO NA QUERY DEVIDO A NOTA TÉCNICA Nº 15/2019
						//OS REGISTROS DA C1G COM STATUS= 4 FICAVAM APARECENDO COMO TRANSMITIDOS
						cQuery += "	 AND (("+ cAliasLay + "." + cAliasLay + "_STATUS = '4' AND "+; 
											cAliasLay + "." + cAliasLay + "_PROTUL <> ' ' ) OR "+;
											cAliasLay + "." + cAliasLay + "_STATUS <> '4') "

					EndIf

				EndIf

			Next nX

		EndIf

	Next nI

	If !Empty( cQuery )

		If Upper(cBanco) == "INFORMIX" 
			cQuery += " )  "
		EndIf
		//cQuery := ChangeQuery( cQuery )
	//	 MemoWrite("C:\memowrite\tafmondet_c.txt", cQuery )

	EndIf

Return(cQuery)

//--------------------------------------------------------------------
/*/{Protheus.doc} TafRegra
Valida as regras de transmissão para os eventos do esocial
Esta função é usada para as validações especificas de cada evento

Ex: 1200 - Deve ser transmitido até o dia 07 do mê seguinte ao mês de referência,
porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados)
antecipar para  o dia útil anterior

@Param

@Author	Fabio V Santana
@Since	16/04/2015

@Obs

@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafRegra( cChave , cAlias , cLayout , cRegra , cDataLim )

	Local dData	:= CTOD("  /  /    ")
	Local cAno	:= ""

	cAlias  := alltrim( cAlias )

	If cAlias != 'C1E'

		If TafAlsInDIC( cAlias )

			DbSelectArea( cAlias )
			( cAlias )->( DbSetOrder( 1 ) )

			If MsSeek(xFilial(cAlias) + cChave) .And. &( cAlias + "->" + cAlias + "_STATUS" ) <> '4'

				Do Case

					Case cLayout $ "S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1270|S-1280|S-1299|S-2205|S-2206|S-2220|S-2240|S-2298"

						Do Case
							//Retorno o ultimo dia do mes + 7
							Case cLayout $ "S-2205|S-2206"
								If !Empty(&( cAlias + "->" + cAlias + "_DTALT" ))
									dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTALT" )),1,6), .T. , .T.) + 7
								EndIf
							Case cLayout $ "S-2220"
								If !Empty(&( cAlias + "->" + cAlias + "_DTASO" ))
									dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTASO" )),1,6), .T. , .T.) + 7
								EndIF
							Case cLayout $ "S-2240"
								If !Empty(&( cAlias + "->" + cAlias + "_DTINI" ))
									dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTINI" )),1,6), .T. , .T.) + 7
								EndIf
							Case cLayout $ "S-2298"
								If !Empty(&( cAlias + "->" + cAlias + "_DTEFEI" ))
									dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTEFEI" )),1,6), .T. , .T.) + 7
								EndIf
							OtherWise
								If !Empty(&( cAlias + "->" + cAlias + "_PERAPU" ))
									dData := xFunDtPer( &( cAlias + "->" + cAlias + "_PERAPU" ), .T. , .T.) + 7
								EndIf
						EndCase

						//Para a correta transmissão, o 7º dia deverá ser uma data valida
						//Porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados) antecipar para o dia útil anterior
						If !Empty(dData)
							dData := DataValida(dData,.F.)
							cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
							cRegra := STR0175
						Else
							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''
						EndIf

					Case cLayout $ "S-2190"

						If !Empty(&( cAlias + "->" + cAlias + "_DTADMI" ))
							dData := &( cAlias + "->" + cAlias + "_DTADMI" ) -1
							cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
							cRegra := STR0176
						Else
							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''
						EndIf

					Case cLayout $ "S-2200"

						CUP->(DbSetOrder(1))
						DbSelectArea('CUP')
						If MsSeek(xFilial("CUP") + cChave)

							T3A->(DbSetOrder(2))
							DbSelectArea('T3A')
							//Posiciona no evento S-2190 - Cadastro preliminar
							If MsSeek(xFilial("T3A") + C9V->C9V_CPF + DTOS(CUP->CUP_DTADMI) + "1")

								//Registro não transmitido
								If T3A->T3A_STATUS <> '4'
									//CLT
									If !Empty(CUP->CUP_TPADMI)
										//Caso não tenha transmitido o evento preliminar (S-2190), a data de envio é um dia antes da admissão.
										If CUP->CUP_TPADMI == "1"
											If !Empty(CUP->CUP_DTADMI)
												If C9V->C9V_CADINI <> '1'
													dData := CUP->CUP_DTADMI -1
													cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
													cRegra := STR0179	//Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior ao início da prestação.
												EndIf
											Else
												//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
												cRegra := STR0189
												cDataLim := ''
											EndIf
										ElseIf CUP->CUP_TPADMI $ "2|3|4|"
											If !Empty(CUP->CUP_DTINVI)
												If C9V->C9V_CADINI <> '1'
													dData := CUP->CUP_DTINVI -1
													cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
													cRegra := STR0251 //"Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior ao início do vinculo."
												EndIf
											Else
												//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
												cRegra := STR0189
												cDataLim := ''
											EndIf
										Else
											If !Empty(CUP->CUP_DTTRAN)
												If C9V->C9V_CADINI <> '1'
													dData := CUP->CUP_DTTRAN -1
													cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
													cRegra := STR0252 // "Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior a data de transferencia."
												EndIf
											Else
												//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
												cRegra := STR0189
												cDataLim := ''
											EndIf
										EndIf
									//Estatutário
									Else
										If !Empty(CUP->CUP_DTNOME)
											If C9V->C9V_CADINI <> '1'
												dData := CUP->CUP_DTNOME -1
												cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
												cRegra := STR0253 //"Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior a Data da Nomeação do Servidor"
											EndIf
										Else
											//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
											cRegra := STR0189
											cDataLim := ''
										EndIf
									EndIf
								Else
									//Caso o evento preliminar tenha sido transmitido
									//Se houver entrada ou se o registro se tratar de órgão público, deve ser transmitido até o dia 07 do mês seguinte ao mês de referência,
									//Porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados) antecipar para o dia útil anterior.
									If !Empty(CUP->CUP_DTADMI)
										If C9V->C9V_CADINI <> '1'
											dData := xFunDtPer( Substr(DTOS(CUP->CUP_DTADMI),1,6), .T. , .T.) + 7
											dData := DataValida(dData,.F.)
											cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
											cRegra := STR0180
										EndIf
									Else
										//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
										cRegra := STR0189
										cDataLim := ''
									EndIF
								EndIf
							Else
								//CLT
								If !Empty(CUP->CUP_TPADMI)
									//Caso não tenha transmitido o evento preliminar (S-2190), a data de envio é um dia antes da admissão.
									If CUP->CUP_TPADMI == "1"
										If !Empty(CUP->CUP_DTADMI)
											If C9V->C9V_CADINI <> '1'
												dData := CUP->CUP_DTADMI -1
												cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
												cRegra := STR0179
											EndIf
										Else
											//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
											cRegra := STR0189
											cDataLim := ''
										EndIf
									ElseIf CUP->CUP_TPADMI $ "2|3|4|"

										If !Empty(CUP->CUP_DTINVI)

											If C9V->C9V_CADINI <> '1'
												dData := CUP->CUP_DTINVI
												cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
												cRegra := STR0251 //"Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior ao início do vinculo."
											EndIf

										Else

											//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
											cRegra := STR0189
											cDataLim := ''

										EndIf

									Else
										If !Empty(CUP->CUP_DTTRAN)

											If C9V->C9V_CADINI <> '1'

												dData := CUP->CUP_DTTRAN
												cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
												cRegra := STR0252 //"Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior a data de transferencia."
											
											EndIf

										Else

											//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
											cRegra := STR0189
											cDataLim := ''

										EndIf

									EndIf

								//Estatutário
								Else

									If !Empty(CUP->CUP_DTNOME)

										If C9V->C9V_CADINI <> '1'
											dData := CUP->CUP_DTNOME
											cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
											cRegra := STR0253 //"Se não houve entrega do S-2190 referente a este CPF, o registro deve ser enviado até o final do dia imediatamente anterior a Data da Nomeação do Servidor"
										EndIf

									Else

										//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
										cRegra := STR0189
										cDataLim := ''

									EndIf

								EndIf

							EndIf

						EndIf

					Case cLayout $ "S-2230"

						//Retorno o ultimo dia do mes + 7
						If &( cAlias + "->" + cAlias + "_EVENTO" ) == 'I' .And. !Empty(&( cAlias + "->" + cAlias + "_DTAFAS" ))
							dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTAFAS" )),1,6), .T. , .T.) + 7
						ElseIf &( cAlias + "->" + cAlias + "_EVENTO" ) == 'A' .And. !Empty(&( cAlias + "->" + cAlias + "_ADTAFA" ))
							dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_ADTAFA" )),1,6), .T. , .T.) + 7
						ElseIf &( cAlias + "->" + cAlias + "_EVENTO" ) == 'F' .And. !Empty(&( cAlias + "->" + cAlias + "_DTFAFA" ))
							dData := xFunDtPer( Substr(DTOS(&( cAlias + "->" + cAlias + "_DTFAFA" )),1,6), .T. , .T.) + 7
						EndIf

						//Para a correta transmissão, o 7º dia deverá ser uma data valida
						//Porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados) antecipar para o dia útil anterior
						If !Empty(dData)
							dData := DataValida(dData,.F.)
							cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
							cRegra := STR0175
						Else
							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''
						EndIf

					Case cLayout $ "S-2250"

						//Data atual + 10
						If !Empty(&( cAlias + "->" + cAlias + "_DTAVIS" ))

							dData := &( cAlias + "->" + cAlias + "_DTAVIS" ) + 10
							cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
							cRegra := STR0177

						Else

							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''

						EndIf

					Case cLayout $ "S-2299"

						If !Empty(&( cAlias + "->" + cAlias + "_DTDESL" ))

							cDataLim := &( cAlias + "->" + cAlias + "_DTDESL" ) +10
							cDataLim := Substr(DtoS(cDataLim),7,2) + "/" + Substr(DtoS(cDataLim),5,2) + "/" + Substr(DtoS(cDataLim),1,4)

							If date() > &( cAlias + "->" + cAlias + "_DTDESL" ) + 10
								cRegra := STR0268//"A data de envio do evento deve ser inferior a data de desligamento acrescida de 10 dias corridos."
							EndIf

						Else

							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''

						EndIf

					Case cLayout $ "S-2300"

							If !Empty(C9V->C9V_DTINIV)

								If C9V->C9V_CADINI <> '1'

									//Retorno o ultimo dia do mes + 7
									dData := xFunDtPer( Substr(DTOS(C9V->C9V_DTINIV),1,6), .T. , .T.) + 7

									//Para a correta transmissão, o 7º dia deverá ser uma data valida
									//Porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados) antecipar para o dia útil anterior
									dData := DataValida(dData,.F.)
									cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
									cRegra := STR0175

								EndIf

							Else

								//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
								cRegra := STR0189
								cDataLim := ''

							EndIf

					Case cLayout $ "S-2306"

						If !Empty(&( cAlias + "->" + cAlias + "_DTALT" ))

							//O registro deve ser transmitido até o 7º dia da sua ocorrência.
							dData := &( cAlias + "->" + cAlias + "_DTALT" ) + 7

							//O registro deve ser transmitido até o 7º dia da sua ocorrência.
							cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
							cRegra   := STR0178

						Else

							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra   := STR0189
							cDataLim := ''

						EndIf

					Case cLayout $ "S-2399"

						//Retorno o ultimo dia do mes + 7
						T92->(DbSetOrder(1))
						DbSelectArea('T92')
						If MsSeek(xFilial("T92") + cChave)

							//O registro deve ser transmitido até o 7º dia da sua ocorrência.
							If !Empty(T92->T92_DTERAV)

								dData := LastDay(T92->T92_DTERAV) + 7
								dData := DataValida(dData,.F.)
								cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
								cRegra := STR0178

							Else

								//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
								cRegra := STR0189
								cDataLim := ''

							EndIf

						EndIf

					Case cLayout $ "S-1300"

						If !Empty(&( cAlias + "->" + cAlias + "_PERAPU" ))

							If &( cAlias + "->" + cAlias + "_INDAPU" ) == '1'

								//Retorno o ultimo dia do mes + 7
								dData := xFunDtPer( &( cAlias + "->" + cAlias + "_PERAPU" ), .T. , .T.) + 7

								//Para a correta transmissão, o 7º dia deverá ser uma data valida
								//Porém se o dia 07 não houver expediente bancário (sábado, domingo e feriados) antecipar para o dia útil anterior
								dData := DataValida(dData,.F.)
								cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
								cRegra := STR0181

							Else

								//Os registros anuais devem ser transmitidos somente nos dias 7 de fevereiro de cada ano ou 7 de outubro para empregadores rurais.
								cAno 	  := SubStr(&( cAlias + "->" + cAlias + "_PERAPU" ),1,4)
								If date() > CtoD("07/02/" + cAno   )
									dData 	  := CtoD("07/02/" + cAno   )
								Else
									dData 	  := CtoD("07/10/" + cAno   )
								EndIf

								cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
								cRegra   := STR0182

							EndIF

						Else

							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''

						EndIf

					Case cLayout $ "S-2210"

						If !Empty(&( cAlias + "->" + cAlias + "_DTACID" ))

							If &( cAlias + "->" + cAlias + "_INDOBI" ) == '1'

								//Eventos de acidentes de trabalho onde haja óbito, devem ser transmitidos no mesmo dia da ocorrência.
								dData 	  := &( cAlias + "->" + cAlias + "_DTACID" )
								cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
								cRegra   := STR0183
								
							Else

								//Eventos de acidentes de trabalho onde não haja óbito, devem ser transmitidos no próximo dia util após a ocorrência
								dData := &( cAlias + "->" + cAlias + "_DTACID" ) +1
								dData := DataValida(dData,.T.)
								cDataLim := Substr(DtoS(dData),7,2) + "/" + Substr(DtoS(dData),5,2) + "/" + Substr(DtoS(dData),1,4)
								cRegra := STR0184

							EndIf

						Else

							//'Data não preenchida no cadastro, não será possível calcular a data limite para transmissão.'
							cRegra := STR0189
							cDataLim := ''

						EndIf

				EndCase

			EndIf

		Endif

		//Se não entrou em nenhuma regra, considero que foi atendida corretamente
		If Empty(cRegra)
			cRegra := STR0185 //Regra de transmissão atendida corretamente
		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} verificaEvento
Verifica a origem do Browse para a montagem da Query do detalhamento
de acordo com o tipo de evento.

@type function
@author Evandro dos Santos O. Teixeira
@since 08/07/2016
@version 1.0
@param cIDBrowse				- Identificador do Browse
@param cNomeEvento				- Nome do Evento (S-1000,S-1020 etc..)
@param cTipoEvento				- Tipo do evento (inicial, mensal etc..)
@param cSemRelacaoTrabalhador	- Indica se o evento tem relacão com o Trabalhador
@return lEventoValido			- Determina se o evento deve entrar na Query
/*/
//---------------------------------------------------------------------
Static Function verificaEvento(cIDBrowse,cNomeEvento,cTipoEvento,cSemRelacaoTrabalhador)

	Local lEventoValido := .F.

	If cIDBrowse == "Tabelas"

		If cTipoEvento == EVENTOS_INICIAIS[2] .Or. cSemRelacaoTrabalhador == "S"

			If cNomeEvento != "TAUTO"
				lEventoValido := .T.
			EndIf

		EndIf

	Else

		If cTipoEvento $ EVENTOS_MENSAIS[2]+"|"+EVENTOS_EVENTUAIS[2] .And. Empty(cSemRelacaoTrabalhador)
			lEventoValido := .T.
		EndIf

	EndIf

Return (lEventoValido)

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMDetDescr
Retorna a descrição dos eventos que necessitam de posiciomento
para a obtenção do valor.

@type function
@author Evandradmin	o dos Santos O. Teixeira
@since 04/02/2018
@version 1.0

@param lMaisD1 - Indica se a seleção de varios eventos
@param xEvento - Variavel com o nome do evento caso lMaisD1 igual a .F.
@param aFiliais - Array da função FWLoadSM0
@param cBanco - Banco de dados em Uso

@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Function TafMDetDescr(lMaisD1,xEvento,aFiliais,cBanco)

	Local cDescricao := " "
	Local cEvento    := ""
	Local nPos       := 0

	Default cBanco := AllTrim(TCGetDB())

	If lMaisD1
		cEvento := (cAliasDet)->EVENTO
	Else
		If ValType(xEvento) == "A"
			cEvento := xEvento[1][4]
		Else
			cEvento := xEvento
		EndIf
	Endif

	cEvento := AllTrim(cEvento)

	If cEvento == "S-1005"

		nPos := aScan(aFiliais,{|aFil|AllTrim(aFil[18]) == AllTrim((cAliasDet)->CODIGO) })
		If nPos > 0
			cDescricao := aFiliais[nPos][17]
		Else
			cDescricao := AllTrim((cAliasDet)->CODIGO)
		EndIf
	Else

		If cEvtsTrab == Nil
			cEvtsTrab := ""
		endif

		If cEvento $ cEvtsTrab .And. FindFunction("monGetTrbName") 	

			If (cEvento == "S-1200" .Or. cEvento == "S-1210") .And. FindFunction("TafMVNomeFun") 
				cDescricao := TafMVNomeFun((cAliasDet)->CPFMV,cBanco)
			Else
				C9V->(dBSetOrder(2))
				If C9V->(MsSeek((cAliasDet)->FILIAL+(cAliasDet)->CIDTRAB+"1"))
					cDescricao := monGetTrbName(cBanco,(cAliasDet)->FILIAL,C9V->C9V_CPF)
				EndIf 
			EndIf 

			If Empty(cDescricao)
				cDescricao := AllTrim((cAliasDet)->DESCR)
			Endif 
		Else
			cDescricao := AllTrim((cAliasDet)->DESCR)
		EndIf 

		If (cAliasDet)->EXTEMP == "E"
			cDescricao := STR0233 + " - " + cDescricao //EXTEMPORÂNEO
		EndIf

	EndIf

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescrPeriodicos
Retorna a descrição para os eventos Periódicos

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cLayout - Codigo do Layout
@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Static Function getDescrPeriodicos(cLayout)

	Local cDescricao := ""

	Default cLayout := ""

	Do Case
		Case cLayout == "S-2200"
			cDescricao := "C9V.C9V_NOME "
		Case cLayout == "S-2205"
			cDescricao := "T1U.T1U_NOME "
		Case cLayout == "S-2206"
			cDescricao := "T1V.T1V_NOME "
		Case cLayout == "S-2210"
			cDescricao := getDescrTrab('CM0.CM0_FILIAL', 'CM0.CM0_TRABAL')
		Case cLayout == "S-2220"
			cDescricao := getDescrTrab('C8B.C8B_FILIAL', 'C8B.C8B_FUNC')
		Case cLayout == "S-2230"
			cDescricao := getDescrTrab('CM6.CM6_FILIAL', 'CM6.CM6_FUNC')
		Case cLayout == "S-2240"
			cDescricao := getDescrTrab('CM9.CM9_FILIAL', 'CM9.CM9_FUNC')
		Case cLayout == "S-2241"
			cDescricao := getDescrTrab('T3B.T3B_FILIAL', 'T3B.T3B_IDTRAB')
		Case cLayout == "S-2250"
			cDescricao := getDescrTrab('CM8.CM8_FILIAL', 'CM8.CM8_TRABAL')
		Case cLayout == "S-2260"
			cDescricao := getDescrTrab('T87.T87_FILIAL', 'T87.T87_TRABAL')
		Case cLayout == "S-2298"
			cDescricao := getDescrTrab('CMF.CMF_FILIAL', 'CMF.CMF_FUNC')
		Case cLayout == "S-2299"
			cDescricao := getDescrTrab('CMD.CMD_FILIAL', 'CMD.CMD_FUNC')
		Case cLayout == "S-2300"
			cDescricao := "C9V.C9V_NOME "
		Case cLayout == "S-2306"
			cDescricao := "T0F.T0F_NOME  "
		Case cLayout == "S-2399"
			cDescricao := getDescrTrab('T92.T92_FILIAL', 'T92.T92_TRABAL')
		Case cLayout == "S-2400"
			cDescricao := "T5T.T5T_NOME "
		Case cLayout == "S-3000"
			cDescricao := " (SELECT C8E_DESCRI FROM " + RetSqlName("C8E") + " WHERE C8E_FILIAL = '"+xFilial("C8E")+"' AND C8E_ID = CMJ.CMJ_TPEVEN AND D_E_L_E_T_ <> '*') "
		OtherWise
			cDescricao := "' '"
	EndCase

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescrTrab
Retorna a descrição para os eventos que tem relação com o trabalhador

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cIdTrab - Campo que contem o Id do Trabalhador
@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Static Function getDescrTrab(cFilTrab, cIdTrab)

	Local cDescricao := ""

	If paramVisao == 1
		cDescricao := "(SELECT DISTINCT C9V_NOME FROM "  + RetSqlName("C9V")  + " C9V "
		cDescricao += " WHERE C9V.C9V_FILIAL = "+cFilTrab+" "
		cDescricao += " AND C9V.C9V_ID = " + cIdTrab + " AND C9V.C9V_ATIVO = '1' AND C9V.D_E_L_E_T_ <> '*') "
	Else
		cDescricao := "'" + AllTrim((cAliasTrb)->C9V_NOME) + "'"
	EndIf

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescrNaoPeriodicos
Retorna a descrição para os eventos Não Periodicos

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cLayout - Codigo do Layout
@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Static Function getDescrNaoPeriodicos(cLayout)

	Local cDescricao := ""

	Default cLayout := ""

	Do Case
		Case cLayout == "S-1200" .Or. cLayout == "S-1202"
			cDescricao := getDescrTrab('C91.C91_FILIAL', 'C91.C91_TRABAL')
		Case cLayout == "S-1207"
			cDescricao := "T62.T62_CPF"
		Case cLayout == "S-1210"
			cDescricao := getDescrTrab('T3P.T3P_FILIAL', 'T3P.T3P_BENEFI')
		Case cLayout == "S-1250"
			cDescricao := " CASE WHEN CMR.CMR_INDAPU = '1' THEN 'PERIODO DE APURAÇÃO MENSAL'  END "
		Case cLayout == "S-1260"
			cDescricao := getDescEstab("T1M.T1M_FILIAL", "T1M.T1M_IDESTA")
		Case cLayout == "S-1270"
			cDescricao := " CASE WHEN T2A.T2A_INDAPU = '1' THEN 'PERIODO DE APURAÇÃO MENSAL'  END "
		Case cLayout == "S-1280"
			cDescricao := getDescApuracao("T3V.T3V_INDAPU")
		Case cLayout == "S-1295"
			cDescricao := getDescApuracao("T72.T72_INDAPU")
		Case cLayout == "S-1298"
			cDescricao := getDescApuracao("T1S.T1S_INDAPU")
		Case cLayout == "S-1299"
			cDescricao := getDescApuracao("CUO.CUO_INDAPU")
		Case cLayout == "S-1300"
			cDescricao := getDescApuracao("T3Z.T3Z_INDAPU")
		OtherWise
			cDescricao := "' '"
	EndCase

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescEstab
Retorna a descrição para os eventos que tem relação com o estabelecimento

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cIdEstab - Campo Relativo ao Inscrição do estabeleciomento
@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Static Function getDescEstab(cFilEstab, cIdEstab)

	Local cDescricao := ""

	cDescricao := "(SELECT C92_NRINSC FROM "  + RetSqlName("C92")  + " C92  "
	cDescricao += " WHERE C92.C92_FILIAL = "+cFilEstab+" AND C92.C92_ID = " + cIdEstab + " AND C92.C92_ATIVO = '1' AND C92.D_E_L_E_T_ <> '*') "

Return cDescricao

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescApuracao
Retorna a Descrição do Indice de Apuração

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cIndApu - Numero de Inscrição do estabeleciomento
@return cDescricao - Descrição do evento
/*/
//---------------------------------------------------------------------
Static Function getDescApuracao(cIndApu)

	Local cDescricao := ""

	cDescricao := " CASE WHEN " + cIndApu + " = '1' THEN 'PERIODO DE APURAÇÃO MENSAL' ELSE 'PERIDO DE APURAÇÃO ANUAL'  END "

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} AfastaEnv
Retorna a descrição do tipo do afastamento enviado

@type function
@author Denis R. de Oliveira
@since 15/05/2018
@version 1.0

@return cDscAfast - Descrição do Evento de Afastamento
/*/
//-------------------------------------------------------------------
Function AfastaEnv(cTpAfast)

	Local cDscAfast	:= ""

	Default cTpAfast	:= ""

	If AllTrim(cTpAfast) == "INIC"
		cDscAfast := "Início de Afastamento"
	ElseIf AllTrim(cTpAfast) == "TERM"
		cDscAfast := "Término de Afastamento"
	ElseIf AllTrim(cTpAfast) == "COMP"
		cDscAfast := "Completo (Início e Término)"
	EndIf

Return cDscAfast

//-------------------------------------------------------------------
/*/{Protheus.doc} consultaTotalizador
Faz a Re-avaliação do eventos que geram totalizador.

@type function
@author Evandro dos Santos Oliveira	
@since 17/09/2018
@version 1.0

@param aIDsSel - Ids Selecionador no browse do trabalhador
@param oTabFilSel -Tabela temporaria com as filiais selecionadas 

@return cDscAfast - Descrição do Evento de Afastamento
/*/
//-------------------------------------------------------------------
Function consultaTotalizador( aIDsSel as Array, oTabFilSel as Object, dDtIni as Date, dDtFim as Date, cIDBrowse as Character )

	Local aData   as Array
	Local aEvents as Array
	Local cMsgAmb as Character
	Local l1200   as Logical
	Local l1210   as Logical
	Local l1295   as Logical
	Local l1299   as Logical
	Local l2299   as Logical
	Local l2399   as Logical
	Local l2501   as Logical
	Local lEnd    as Logical
	Local lForce  as Logical
	Local lOk     as Logical
	Local o1200   as Object
	Local o1210   as Object
	Local o1295   as Object
	Local o1299   as Object
	Local o2299   as Object
	Local o2399   as Object
	Local o2501   as Object
	Local oForce  as Object
	Local oSayMsg as Object

	Default cIDBrowse := ""

	aData   := GetApoInfo("TAFA423.PRW")
	aEvents := {}
	cMsgAmb := ""
	l1200   := .F.
	l1210   := .F.
	l1295   := .F.
	l1299   := .F.
	l2299   := .F.
	l2399   := .F.
	l2501   := .F.
	lEnd    := .F.
	lForce  := .F.
	lOk     := .F.
	o1200   := Nil
	o1210   := Nil
	o1295   := Nil
	o1299   := Nil
	o2299   := Nil
	o2399   := Nil
	o2501   := Nil
	oForce  := Nil
	oSayMsg := Nil

	cCadastro := "Geração Totalizadores"

	cMsgAmb := "<font size='3' color='BLUE'>"
	cMsgAmb += "Selecione os Eventos para a geração dos Totalizadores Faltantes." 
	cMsgAmb += "</font>"

	Define MsDialog oDlg Title "Seleção de Status" From 0,0 To 180,600  Pixel

	oSayMsg := TSay():New( 045, 020, { ||cMsgAmb },oDlg,,,,,,.T.,,,280,030,,,,,,.T. )

	o1200 := TCheckBox():New(060, 020, "S-1200", {||l1200}, oDlg, 200, 050,, { || l1200 := !l1200},,,,,,.T.,,, ) 
	o1210 := TCheckBox():New(060, 060, "S-1210", {||l1210}, oDlg, 200, 050,, { || l1210 := !l1210},,,,,,.T.,,, ) 
	o1295 := TCheckBox():New(060, 100, "S-1295", {||l1295}, oDlg, 200, 050,, { || l1295 := !l1295},,,,,,.T.,,, )
	o1299 := TCheckBox():New(060, 140, "S-1299", {||l1299}, oDlg, 200, 050,, { || l1299 := !l1299},,,,,,.T.,,, )
	o2299 := TCheckBox():New(060, 180, "S-2299", {||l2299}, oDlg, 200, 050,, { || l2299 := !l2299},,,,,,.T.,,, )
	o2399 := TCheckBox():New(060, 220, "S-2399", {||l2399}, oDlg, 200, 050,, { || l2399 := !l2399},,,,,,.T.,,, )
	o2501 := TCheckBox():New(060, 260, "S-2501", {||l2501}, oDlg, 200, 050,, { || l2501 := !l2501},,,,,,.T.,,, )

	If aData[4] >= SToD( "20190329" )
		oForce := TCheckBox():New( 075, 020, "Deseja forçar a re-avaliação de todos os eventos selecionados ?", { || lForce }, oDlg, 200, 050,, {|| lForce := !lForce },,,,,,.T.,,, )
	EndIf

	If !paramEtvPeriodicos //Retirado o S-1295, visto que é considerado um evento de tabela.

		o1200:Disable()
		o1210:Disable()

	EndIf 

	If !paramEtvNaoPeriodicos

		o2299:Disable()
		o2399:Disable()
		o2501:Disable()

	EndIf 

	If !cIDBrowse == "Tabelas" 

		o1295:Disable()
		o1299:Disable()

	EndIf 

	If !FwIsInCallStack("TAFREAVALIATOTALIZADORES")

		If cIDBrowse == "Tabelas"

			o1200:Disable()
			o1210:Disable()
			o2299:Disable()
			o2399:Disable()
			o2501:Disable()

		EndIf 

	EndIf

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,{||lOk :=.T.,oDlg:End()},{||oDlg:End()},,,,,.F.,.F.,.F.,.T.,.F.))

	If lOk 

		If l1200
			aAdd(aEvents,TAFRotinas('S-1200' ,4,.F.,2))
		EndIf 

		If l1210
			aAdd(aEvents,TAFRotinas('S-1210' ,4,.F.,2))
		EndIf 

		If l1295
			aAdd(aEvents,TAFRotinas('S-1295' ,4,.F.,2))
		EndIf

		If l1299
			aAdd(aEvents,TAFRotinas('S-1299' ,4,.F.,2))
		EndIf 

		If l2299
			aAdd(aEvents,TAFRotinas('S-2299' ,4,.F.,2))
		EndIf 

		If l2399
			aAdd(aEvents,TAFRotinas('S-2399' ,4,.F.,2))
		EndIf 

		If l2501
			aAdd(aEvents,TAFRotinas('S-2501' ,4,.F.,2))
		EndIf 

		If Len(aEvents) == 0

			MsgInfo("Nenhum evento selecionado, o processo não será realizado.")

		Else

			If lForce
				TafGrvTot( paramFiliais, dDtIni, dDtFim, aEvents )
			EndIf

			FWMsgRun(,{|oMsgRun| TAFProc5Tss(.F., aEvents, '4', aIdsSel,, lEnd,, paramFiliais, dDtIni, dDtFim,,,,,, @oTabFilSel,,, oMsgRun)},;
					 "Consulta de Totalizadores", "Realizando Consulta no Servidor TSS ..." )
			MsgInfo("Processo Finalizado")

		EndIf 

	EndIf 

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIdsFunc

Cria String SQL normalizada para uso na clausula IN do SQL com
base no array com Ids dos trabalhadores selecionados no monitor.

@param aItens 	 - Array com as Filiais + Ids dos trabalhadores
@param cAliasEvt - Alias do evento que gerou o totalizador. 
exemplo: C91.
@param cCmpTrab  - Campo que se relaciona com o ID do trabalhador. 
exemplo: C91_TRABAL.

@type function
@author Evandro dos Santos Oliveira
@since 06/09/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAFIdsFunc(aItens,cAliasEvt,cCmpTrab)

	Local cSqlIn   := ""
	Local nFils    := 0
	Local nId      := 0
	Local lVirgula := .F.

	Default aItens := {}

	For nFils := 1 To Len(aItens)

		If nFils > 1
			cSqlIn += " OR "	
		EndIf 

		cSqlIn += " (" + cAliasEvt + "_FILIAL = '" + aItens[nFils][1] + "'" 
		cSqlIn += " AND "
		cSqlIn += cCmpTrab  + " IN ("

		For nId := 1 To Len(aItens[nFils][2])

			Iif( lVirgula, cSqlIn += ",", )
			cSqlIn += "'" + aItens[nFils][2][nId] + "'"
			lVirgula := .T.

		Next nId

		cSqlIn += ")) "

	Next nFils

	aSize(aItens,0)

Return cSqlIn 

//-------------------------------------------------------------------
/*/{Protheus.doc} execTotErase

Exibe mensagem com o erro retornado no totalizador.

@param cAliasTot - Alias do Evento Totalizador
@param cAliasEvt - Alias do Evento que gerou o Totalizador
@param cCmpCPF 	 - Campo que contem o CPF do trabalador (na tabela do totalizador)
exemplo: T2M_CPFTRB
@param cIdsTrab  - Ids dos funcionarios quando existe seleção no browse do monitor
@param dDtIni	 - Data Inicial (filtro do monitor)
@param dDtFim	 - Data Final (filtro do monitor)

@type function
@author Evandro dos Santos Oliveira
@since 04/07/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function execTotErase(cAliasTot,cAliasEvt,cCmpCPF,cIdsTrab,dDtIni,dDtFim,cCdEvento)

	Local cSql   := ""
	Local cNumEv := GetIDEvent(cCdEvento)

	cSql := " UPDATE " + RetSqlName(cAliasTot)
	cSql += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cSql += " WHERE R_E_C_N_O_ IN "
	cSql += " ( "
	cSql += " 	SELECT " + cAliasTot + ".R_E_C_N_O_ " 
	cSql += " 	FROM " + RetSqlName(cAliasTot) + " " + cAliasTot 

	If !Empty(cCmpCPF)
	
		cSql += " INNER JOIN " + RetSqlName("C9V") + " C9V "
		cSql += " ON "  + cAliasTot + "." + cAliasTot + "_FILIAL = C9V.C9V_FILIAL " 
		cSql += " AND " + cAliasTot + "." + cCmpCPF + " = C9V.C9V_CPF " 
		cSql += " AND C9V.C9V_ATIVO = '1' "
		cSql += " INNER JOIN " + RetSqlName(cAliasEvt) + " " + cAliasEvt
		cSql += " ON "  + cAliasEvt + "." + cAliasEvt + "_FILIAL = C9V.C9V_FILIAL "
		If cAliasEvt == "CMD" 
			cSql += " AND " + cAliasEvt + "." + cAliasEvt + "_FUNC = C9V.C9V_ID "
		Else
			cSql += " AND " + cAliasEvt + "." + cAliasEvt + "_TRABAL = C9V.C9V_ID " 
		EndIF

	EndIf 

	cSql += " WHERE " + cAliasTot + ".D_E_L_E_T_ = ' ' "

	If !Empty(cCmpCPF)
		cSql += " AND C9V.D_E_L_E_T_ = ' ' " 
		cSql += " AND " + cAliasEvt + ".D_E_L_E_T_ = ' ' "
	EndIf 
	
	If Empty(cIdsTrab)
		cSql += " AND " + getSQLInFilias(cAliasEvt)
	Else

		cSql += " AND " 
		cSql += " ( "
		cSql += cIdsTrab
		cSql += " ) "
	EndIf

	If cAliasTot $ "T2M|T2G|T2V|T0G"
	
		cSql  += " AND " +  cAliasTot + "." + cAliasTot + "_PERAPU BETWEEN '" + SubStr(DToS(dDtIni),1,6) + "' AND '" + SubStr(DToS(dDtFim),1,6) + "' "
		
		If cAliasTot == 'T2M' .AND. TAFColumnPos("T2M_IDEVEN")
			cSql  += " AND (" + cAliasTot + "." + cAliasTot + "_IDEVEN = ' ' OR " + cAliasTot + "." + cAliasTot + "_IDEVEN = '" + cNumEv + "' )"	
		EndIf 
	Else
		cSql  += " AND " + cAliasTot + "_PERAPU BETWEEN '" + SubStr(DToS(dDtIni),5,2) + SubStr(DToS(dDtIni),1,4) + "' "
		cSql  += " AND '" +  SubStr(DToS(dDtIni),5,2) + SubStr(DToS(dDtIni),1,4)+ "' "
	EndIf 

	cSql += ")"

	If TCSQLExec (cSql) < 0
		MsgInfo(TCSQLError(),"Limpeza de Totalizadores")
	EndIf

Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} getSQLInFilias

Retorna as filiais selecionas formatadas para o uso na clausula IN 
do SQL

@param cAliasTab - Alias da tabela

@type function
@author Evandro dos Santos Oliveira
@since 09/10/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getSQLInFilias(cAliasTab)

	Local aFiliais 		:= {}
	Local cFiliais		:= ""
	Local nX 			:= 0
	Local cSql			:= ""

	Default cAliasTab 	:= ""

	If Len(paramFiliais) == 1

		cSql :=  cAliasTab + "." + cAliasTab + "_FILIAL = '" + paramFiliais[1][2] + "' " 

	ElseIf Len(paramFiliais) > 1

		For nX := 1 To Len(paramFiliais)

			AAdd(aFiliais, paramFiliais[nX][2])
		
		Next nX 

		cFiliais	:= TAFCacheFil(cAliasTab, aFiliais, .T.)
		cSql 		:= cAliasTab + "." + cAliasTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "  

	EndIf 

Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} mostraTotErro
Exibe mensagem com o erro retornado no totalizador.

@type function
@author Evandro dos Santos Oliveira
@since 18/10/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function mostraTotErro()

	Local cEvtRetXml as Character
	Local cIdUnic    as Character

	cEvtRetXml := "S-1200|S-1210|S-1295|S-1299|S-2299|S-2399|S-2501|"
	cIdUnic    := ""

	If (cAliasDet)->EVENTO $ cEvtRetXml

		cIdUnic := STRTRAN((cAliasDet)->EVENTO,"-","") + AllTrim((cAliasDet)->ID) + AllTrim((cAliasDet)->VERSAO)

		If AllTrim((cAliasDet)->TOTALIZD) == "Gravado"

			MsgInfo("Totalizador retornado com Sucesso.","Totalizadores")

		Else

			If V2J->(MsSeek((cAliasDet)->FILIAL+PADR(AllTrim(cIdUnic),GetSx3Cache("V2J_CHVTAF","X3_TAMANHO"))))

				If !Empty(V2J->V2J_DSCERR)
					Aviso("Erro Totalizador",V2J->V2J_DSCERR, {STR0246}, 3 ) //"Erro Totalizado"#"Fechar"
				Else
					MsgStop("Ocorreram erros na gravação do totalizador.")
				EndIf 

			Else

				MsgInfo("Não há erros na gravação do totalizador. Realize a operação de Re-consulta Totalizadores para o retorno do mesmo.","Totalizadores")

			EndIf 

		EndIf

	Else

		MsgInfo("Somente os eventos S-1200,S-1210,S-1295,S-1299,S-2299, S-2399 e S-2501 retornam totalizadores.","Totalizadores")

	EndIf

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrvTot
Força os registros a Re-avaliar os totalizadores determinando período e evento.

@type function
@author Eduardo Sukeda
@since 29/03/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TafGrvTot( aFiliais as Array, dDtIni as Date, dDtFim as Date, aEvents as Array )

	Local cQuery   as Character
	Local cUpdate  as Character
	Local cWhere   as Character
	Local lForce   as Logical
	Local nDtForce as Numeric
	Local nI       as Numeric
	Local nX       as Numeric

	Default aEvents		:= {}

	cQuery   := ""
	cUpdate  := ""
	cWhere   := ""
	lForce   := .T.
	nDtForce := 0
	nI       := 0
	nX       := 0

	If MsgYesNo("Este procedimento realizará a substituição de todos os totalizadores do período e filial(ais) selecionada(s), deseja prosseguir ?","Eventos de Totalizadores")

		nDtForce := dDtFim - dDtIni

		If nDtForce > 31 .And. !MsgYesNo("Foi informado um período maior do que 1 mês para processamento, isto poderá ocasionar um tempo maior para finalização da execução. Caso clique em não a re-avaliação irá ser feita somente com os registros que não estão com os totalizadores gravados, deseja prosseguir ?","Eventos de Totalizadores")
			lForce := .F.
		EndIf

		If lForce

			For nI := 1 To Len(aFiliais)

				For nX := 1 To Len(aEvents)

				cUpdate := "UPDATE "+ RetSqlName( aEvents[nX][3] ) + " SET " + aEvents[nX][3] + "_GRVTOT = 'F' "
				cWhere	:= "WHERE " + aEvents[nX][3] + "_FILIAL = '" + aFiliais[nI][2] + "' "

				If aEvents[nX][3] $ "C91|T3P|T72|CUO|V7C|" //S-1200, S-1210, S-1295, S-1299 E S-2501
				
					cWhere  += "AND " + aEvents[nX][3] + "_PERAPU BETWEEN '" + SubStr(DToS(dDtIni),1,6) + "' AND '" + SubStr(DToS(dDtFim),1,6) + "' "
				
				ElseIf aEvents[nX][3] $ "CMD" //S-2299

					cWhere  += "AND " + aEvents[nX][3] + "_DTDESL BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' "
				
				ElseIf aEvents[nX][3] $ "T92" //S-2399

					cWhere  += "AND " + aEvents[nX][3] + "_DTERAV BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' "

				EndIf

				cWhere	+= "AND " + aEvents[nX][3] + "_STATUS = '4' "
				cWhere	+= "AND " + aEvents[nX][3] + "_ATIVO = '1' "
				cWhere	+= "AND D_E_L_E_T_ = ' ' "

				cQuery := cUpdate + cWhere

				TCSqlExec( cQuery )

				Next nX

			Next nI

		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIDEvent
@type			function
@description	Busca o ID do Evento Original a partir do Recibo.
@authorOriginal	Felipe C. Seolin
@AutorCopiador	Alexandre de Lima S.
@since			05/08/2019
@version		1.0
@param			cRecibo	-	Recibo do evento original
@return			cEvento	-	Evento original
/*/
//---------------------------------------------------------------------
Static Function GetIDEvent( cEvtOri )

	Local cEvento	:=	""

	Default cEvtOri	:=  ""

	/*-----
	S-1200
	------*/
	If cEvtOri == "S-1200"
		cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-1200", "C8E_ID" )
	EndIf

	/*-----
	S-2299
	------*/
	If cEvtOri == "S-2299"
		cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2299", "C8E_ID" )
	EndIf

	/*-----
	S-2399
	---
	---*/
	If cEvtOri == "S-2399"
		cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2399", "C8E_ID" )
	EndIf

	/*-----
	S-2501
	---
	---*/
	If cEvtOri == "S-2501"
		cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2501", "C8E_ID" )
	EndIf

Return( cEvento )
