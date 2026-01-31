#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TAFMONTES.CH"

Static lLaySimplif 	:= taflayEsoc("S_01_00_00")
Static lFindClass 	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMonEPer
Cria Browse dos eventos Periódiocos e Não Periódicos

@author evandro.oliveira
@since 29/02/2016
@version 1.0
@param oPanel, objeto, (Objeto no qual o browse será criado)
@param lRefresh, logico, (Indica que o browse deve ser atualizado)
@param aChecks, array, (Contem informações dos status selecionados na tela de parâmetros)
@param nRegSelTrb, Compatibilidade - deixou de ser usando em 04/07/2018
@param nRegSelEvt, Compatibilidade - deixou de ser usando em 04/07/2018
@param lTempTable - Verifica se o build em execução permite a utilização de tabelas
	   temporarias no banco de dados
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${nil}
@obs Na Atualização do browse ele se baseia no evento posicionado no browse
eventos do trabalhador.
/*/
//---------------------------------------------------------------------
Function TafMonEPer(oPanel,lRefresh,aChecks,nRegSelTrb,nRegSelEvt,lTempTable,oTabFilSel)

Local cQry			:= ""
Local cQryStus		:= ""
Local aCmpsBrw		:= {}
Local aColsEvt		:= {}
Local nX			:= 0
Local nY			:= 0
Local lVirgula		:= .F.
Local cStatus		:= ""
Local aFilSts		:= {}
Local aFiltro		:= {}
Local aStru			:= {}
Local aSeek			:= {}
Local nLinBrw		:= 0
Local nMark			:= 0
Local cMsg			:= ""
Local cAliasTrb		:= ""
Local cErroSQL		:= ""
Local aIndex		:= {}

Default oPanel		:= Nil
Default lRefresh	:= .F.
Default aChecks		:= {}
Default lTempTable	:= .F.
Default oTabFilSel	:= Nil

aAdd(aFilSts,{paramStsNaoProcessados,STATUS_NAO_PROCESSADO[1]})
aAdd(aFilSts,{paramStsValidos,STATUS_VALIDO[1]})
aAdd(aFilSts,{paramStsInvalidos,STATUS_INVALIDO[1]})
aAdd(aFilSts,{paramStsSemRetorno,STATUS_SEM_RETORNO_GOV[1]})
aAdd(aFilSts,{paramStsConsistente,STATUS_TRANSMITIDO_OK[1]})
aAdd(aFilSts,{paramStsInconsistente,STATUS_INCONSISTENTE[1]})

For nY := 1 To Len(aChecks)
	If 	aChecks[nY][1]
		IIf (lVirgula,cStatus += ",",lVirgula := .T.)
		cStatus += IIf(aChecks[nY][4] == STATUS_NAO_PROCESSADO[1],"' '","'" + AllTrim(Str(aChecks[nY][4])) + "'")
	EndIf
Next nY

/*+------------------------------------------------------------------------+
	| aCmpsBrw - Array dos campos exibidos no Browse                        |
	| [n][1] - Valor do campo (pode ser uma expressao)                      |
	| [n][2] - Titulo do campo                                              |
	| [n][3] - Tamanho do campo                                             |
	| [n][4] - Tipo de dado do campo                                        |
	| [n][5] - Picture														|
	| [n][6] - Valor do campo para uso no fitro (nao pode ser uma expressao)|
	| [n][7] - Alinhamento													|
	+-----------------------------------------------------------------------+*/
aAdd(aCmpsBrw,{"(cAliasEvt)->XEVENTO"				,STR0111	,06,"C","@!","XEVENTO",0})
aAdd(aCmpsBrw,{"AllTrim((cAliasEvt)->XDESC)"		,"Descrição",220,"C","@!","XDESC",1})

If paramVisao == 1
	If paramStsNaoProcessados
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSBRANCO"	,STR0052	,009,"N","","STSBRANCO"	,0}) //"Não Processados"
	EndIf
	If paramStsValidos
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSZERO"	,STR0054	,009,"N","","STSZERO"	,0}) //"Válidos"
	EndIf
	If paramStsInvalidos
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSUM"		,STR0056	,009,"N","","STSUM"		,0}) //"Invalidos"
	EndIf
	If paramStsSemRetorno
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSDOIS"	,STR0061	,009,"N","","STSDOIS"	,0}) //"Sem Retorno"
	EndIf
	If paramStsInconsistente
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSTRES"	,STR0065	,009,"N","","STSTRES"	,0}) //"Inconsistente"
	EndIf
	If paramStsConsistente
		aAdd(aCmpsBrw,{"(cAliasEvt)->STSQUATRO"	,STR0063	,009,"N","","STSQUATRO"	,0}) //"Consistente"
	EndIf

	aAdd(aCmpsBrw,{"(cAliasEvt)->STSTOTAL"			,"Total"		,009,"N","","STSTOTAL",0})
	
EndIf

If (!lRefresh)

	cQuery := FFillBrow(cStatus,@oTabFilSel)
	/*+-------------------------------+
	  | Cria colunas para o Browse    |
	  +-------------------------------+*/
	For nX := 1 To Len(aCmpsBrw)

		aAdd(aColsEvt,FWBrwColumn():New())
		aColsEvt[nX]:SetTitle(aCmpsBrw[nX][2])
		aColsEvt[nX]:SetData(&("{||" + aCmpsBrw[nX][1] + "}"))
		aColsEvt[nX]:SetPicture(aCmpsBrw[nX][5])
		aColsEvt[nX]:SetSize(aCmpsBrw[nX][3])
		aColsEvt[nX]:SetDecimal( 0 )
		aColsEvt[nX]:SetAlign(aCmpsBrw[nX][7])

		aColsEvt[nX]:SetDoubleClick({||FWMsgRun(,{||FTableTSSErr(),TafMonDet(;
											,cStatus;
											,'';
											,(cAliasEvt)->XEVENTO;
											,.F.;
											,;
											,;
											,;
											,;
											,"EvtsPer";
											,;
											,;
											,;
											,@oTabFilSel )},STR0152,STR0153)})//"Eventos"#'Carregando evento(s)'

		aAdd(aFiltro,{aCmpsBrw[nX][6],aCmpsBrw[nX][2],aCmpsBrw[nX][4],aCmpsBrw[nX][3],0,aCmpsBrw[nX][5]})

	Next nX

	aAdd( aSeek, {STR0154,{{ "", "C", 6, 0, "XEVENTO","@!" }}}) //"Codigo do Evento"

	aIndex := {}
	aAdd(aIndex, "XEVENTO" )
	aAdd(aIndex, "MARK" )

	/*+-------------------------------+
	  | Cria objeto FWMarkBrowse      |
	  +-------------------------------+*/

	oPanEvt  := TPanel():New(00,00,"",oPanel,,.F.,.F.,,,10,20,.F.,.F.)
	oPanEvt:Align := CONTROL_ALIGN_ALLCLIENT
	If lFindClass .And. !(GetRemoteType() == REMOTE_HTML) .And. !(FWCSSTools():GetInterfaceCSSType() == 5)
		oPanEvt:setCSS(QLABEL_AZUL_A)
	EndIf

	oMarkEvt := FWMarkBrowse():New()

	oMarkEvt:SetDataQuery(.T.)
	oMarkEvt:SetQuery(cQuery)
	oMarkEvt:SetFieldMark("MARK")
	oMarkEvt:oBrowse:SetQueryIndex(aIndex)

	oMarkEvt:SetAlias(cAliasEvt)
	oMarkEvt:SetColumns(aColsEvt)
	If paramVisao == 1
		oMarkEvt:SetChange({|| FWMsgRun(oPanelTrb,{||TafMonETrb(,.T.,,,,,@oTabFilSel)}) })
	EndIf
	
	
	oMarkEvt:SetValid( {|| FPerAcess(cAliasTrb,SubsTr((cAliasEvt)->XEVENTO,1,6),@cMsg,@nMark)} )  //Valida a permissão de acesso
	oMarkEvt:SetDescription(STR0155)
	oMarkEvt:DisableDetails()
	oMarkEvt:oBrowse:SetUseFilter(.T.)
	oMarkEvt:oBrowse:SetDBFFilter()
	oMarkEvt:oBrowse:SetFieldFilter(aFiltro)
	oMarkEvt:SetSeek(.T.,aSeek)
	oMarkEvt:bMark  := {||FCountMark()}
	oMarkEvt:bAllMark := {||.F.}
	cAliasTrb := oMarkEvt:Alias()
	setFilterOpc(oMarkEvt)
	
	oMarkEvt:AddButton("Marcar Todos",{||FMarkAll(.T.)})
	oMarkEvt:AddButton("Desmarcar Todos",{||FMarkAll(.F.)})
	
	If TafColumnPos( "C91_CPF" )
		oMarkEvt:AddButton("Múltiplos Vínculos",{||FWMsgRun( ,{|| TafMonMV( cStatus, paramDataInicial, paramDataFim, paramFiliais, @oTabFilSel ) },"Aguarde...","Verificando eventos periódicos.") } )
	EndIf
	
	oMarkEvt:Activate(oPanEvt)

ElseIf !Empty(oMarkEvt) 

	nLinBrw := oMarkEvt:oBrowse:nAt

	If IsInCallStack("atualizaInformacoes")
		For nY := 1 To Len(aChecks)
			If 	aChecks[nY][1]
				IIf (lVirgula,cStatus += ",",lVirgula := .T.)
				cStatus += IIf(aChecks[nY][4] == STATUS_NAO_PROCESSADO[1],"' '","'" + AllTrim(Str(aChecks[nY][4])) + "'")
			EndIf
		Next nY

		FechaAlias()
		FCountStatus(,@oTabFilSel)
	EndIf
	
	cQuery := FFillBrow(cStatus,@oTabFilSel)
	oMarkEvt:SetQuery(cQuery)
	oMarkEvt:Refresh(.T.)

EndIf
 
Return(oMarkEvt)

//---------------------------------------------------------------------
/*/{Protheus.doc} setFilterOpc
Define os Filtros padrões do Browse

@author evandro.oliveira
@since 27/03/2018
@version 1.0
@param oMarkBrw - Objeto FWMarkBrowse
@return Nil 
/*/
//---------------------------------------------------------------------
Static Function setFilterOpc(oMarkBrw)

	oMarkBrw:AddFilter(STR0257,'PENDENTE > 0') //'Com Pendências'
	oMarkBrw:AddFilter(STR0258,'PENDENTE == 0') //'Sem Pendências'

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FFillBrow
Realiza consulta para aBrowse Eventos Mensais e Periodicos
e alimenta o arquivo de trabalho.

@author evandro.oliveira
@since 16/02/2016
@version 1.0
@param cStatus, caracter, (Range de Status para o filtro da consulta)
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${xValor}, ${Valor do Status}
/*/
//---------------------------------------------------------------------
Static Function FFillBrow(cStatus,oTabFilSel)

Local cQry			:= ""
Local cQryStus		:= ""
Local cAuxInic		:= ""
Local cTAFKEY		:= ""
Local cQryData		:= ""
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nI			:= 0
Local aTAFKEY		:= {}
Local lVirgula		:= .F.
Local lVazioTrb		:= .F.
Local lTAFKEY		:= .F.
Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_05_00")
Local cDescEvt		:= ""
Local cCmpTrab		:= ""
Local cTipoEvt		:= ""
Local cCmpData		:= ""
Local cRelacTrb		:= ""
Local cAliasLay		:= ""
Local cC9VFilPar	:= ""
Local cLayFilpar	:= ""
Local cBancoDB		:= tcGetDb()
Local cIniEsoc		:= SuperGetMv('MV_TAFINIE',.F.," ")
Local cIndApu		:= ""

Default cStatus		:= ""
Default oTabFilSel	:= Nil

If !Empty( paramTAFKEY )
	aTAFKEY	:=	StrToKArr( paramTAFKEY, "," )

	For nX := 1 to Len( aTAFKEY )
		cTAFKEY += "'" + AllTrim( aTAFKEY[nX] ) + "'" + ","
	Next nX

	cTAFKEY := SubStr( cTAFKEY, 1, Len( cTAFKEY ) - 1 )

	lTAFKEY	:= !Empty( cTAFKEY )
EndIf


If paramVisao == 2

	For nI := 1 To Len(aEventosParm)

		nEventos := Len(aEventosParm[nI][1])

		If nEventos > 0 .And. aEventosParm[nI][2] .And. aEventosParm[nI][3] $ EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2]

			For nX := 1 To nEventos

				cAliasLay := aEventosParm[nI][1][nX][1] //Alias do Evento
				cLayout   := aEventosParm[nI][1][nX][2] //Layout
				cDescEvt  := aEventosParm[nI][1][nX][3] //Descrição do evento
				cCmpTrab  := aEventosParm[nI][1][nX][6] //Campo Id do Trabalhador
				cTipoEvt  := aEventosParm[nI][1][nX][8] //Tipo do Evento
				cCmpData  := aEventosParm[nI][1][nX][7] //Campo que determina o periodo ou data do evento
				cRelacTrb := aEventosParm[nI][1][nX][11] //Define se o evento tem relação com o Trabalhador
				cQryData  := ""

				If  cRelacTrb != "S"

					If cTipoEvt == EVENTOS_MENSAIS[2] .Or. cAliasLay $ "CMJ"
						
						If lLaySimplif
							
							cIndApu := Space(GetSx3Cache(cAliasLay + "_INDAPU", "X3_TAMANHO"))
						
						EndIf

						cQryData := " AND ( "

						If !lLaySimplif

							cQryData += " (" + cAliasLay + "_INDAPU = '1' "

						Else

							cQryData += " ((" + cAliasLay + "_INDAPU = '1' "
							cQryData += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cQryData += " AND " + cCmpData + " >= '" + AnoMes(paramDataInicial) + "'"
						cQryData += " AND " + cCmpData + " <= '" + AnoMes(paramDataFim) + "')"

						If !lLaySimplif

							cQryData += " OR (" + cAliasLay + "_INDAPU = '2' "

						Else

							cQryData += " OR ((" + cAliasLay + "_INDAPU = '2' "
							cQryData += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cQryData += " AND " + cCmpData +  " BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')"
						cQryData += ")"
					ElseIf cTipoEvt == "E" .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"
						cQryData := " AND " + cCmpData + " >= '" + DtoS(paramDataInicial) + "'"
						cQryData += " AND " + cCmpData + " <= '" + DtoS(paramDataFim) + "'"
					EndIf
					cQryData += GetOwner(cAliasLay,aParamES[16])

					If !Empty(cQry)
						cQry += " UNION ALL "
					EndIf

					If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
						cQry += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK"
					Else
						cQry += " SELECT DISTINCT '  ' MARK"
					EndIf
					cQry += ", '" 				    + PADR(cLayout  ,006,"") 	+ "' XEVENTO "
					cQry += ", '" 					+ PADR(cDescEvt ,220,"") 	+ "' XDESC "
					cQry += ", '" 					+ PADR(cAliasLay,003,"") 	+ "' XALIAS "
					cQry += ", '" 					+ PADR(cCmpTrab ,010,"")	+ "' XCMPTRAB "
					cQry += ", '" 					+ PADR(cCmpData ,010,"") 	+ "' XCMPDATA "
					cQry += ", '" 					+ PADR(cTipoEvt ,001,"")	+ "' XTIPOEVT "
					cQry += SelOwner(cAliasLay)
					cQry += " FROM " + RetSqlname("C9V")+ " C9V "
					If cAliasLay != "C9V"
						cQry += " INNER JOIN  " + RetSqlname(cAliasLay) + " " + cAliasLay
						cQry += " ON C9V.C9V_ID = " + cCmpTrab + " AND C9V.C9V_FILIAL = " + cAliasLay + "_FILIAL "
					EndIf

					If cLayout = "S-2200"

			        	cQry += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
						cQry += " AND C9V_ID = CUP_ID "
						cQry += " AND C9V_VERSAO = CUP_VERSAO "
						cQry += " AND CUP.D_E_L_E_T_ <> '*' "
						cQry += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,,,cTipoEvt)

			        EndIf

					cQry += " WHERE "
					cQry += " C9V.C9V_FILIAL = '" + (cAliasTrb)->C9V_FILIAL +  "'"
					cQry += " AND C9V.C9V_ID = '" + (cAliasTrb)->C9V_ID  + "'"
					cQry += " AND C9V.C9V_ATIVO = '1' "
					cQry += " AND C9V.C9V_EVENTO <> 'E' "
					cQry += " AND C9V.D_E_L_E_T_ <> '*' "
					If cAliasLay $  "C91|C9V"
						cQry += " AND " + cAliasLay + "_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
					EndIf

					// Realiza trava para eventos S-1200 e S-1210 para apenas visualização de autônomos.
					If lLockAuton .And. cAliasLay $  "C91|T3P"
						cQry += " AND " + cAliasLay + "_TRABEV= 'TAUTO' "
					EndIf

					If cLayout = "S-2300"
						cQry +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
					EndIf

					If cAliasLay ==  "CM6"
						cQry += " AND ("
						cQry += TafMonPAfast(cVerSchema)
						cQry += " AND CM6_FILIAL = '" + (cAliasTrb)->C9V_FILIAL 		+ "'"
						cQry += " AND " + cCmpTrab    + " = '" + (cAliasTrb)->C9V_ID 	+ "')"
					EndIf

					cQry += cQryData
					cQry += " AND " + cAliasLay + "_STATUS IN (" + cStatus + ") "

			        If TafColumnPos( cAliasLay + "_STASEC" )
			        	cQry += " AND (" + cAliasLay + "_ATIVO = '1' OR " +cAliasLay + "_STASEC = 'E' )"
			        Else
			        	cQry += " AND " + cAliasLay + "_ATIVO = '1' "
			        EndIf


					cQry += " AND " + cAliasLay +  "_EVENTO <> 'E'"
					cQry += " AND " + cAliasLay + "." +  "D_E_L_E_T_ <> '*'"
					cQry += GetOwner(cAliasLay,aParamES[16])
				EndIf

			Next nX
		EndIf
	Next nI

	
		cQry := " SELECT MARK,XEVENTO,XDESC,XALIAS,XCMPTRAB,XCMPDATA,XTIPOEVT FROM ( " + cQry + " ) TAF "
	

	//cQry := ChangeQuery(cQry)

	//MemoWrite("C:\memowrite\tafmoneper_visao2.txt", cQry )

Else

	For nI := 1 To Len(aEventosParm)

		nEventos := Len(aEventosParm[nI][1])

		If nEventos > 0 .And. aEventosParm[nI][2] .And. aEventosParm[nI][3] $ EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2]
			For nX := 1 To nEventos

				cAliasLay := aEventosParm[nI][1][nX][1] //Alias do Evento
				cLayout   := aEventosParm[nI][1][nX][2] //Layout
				cDescEvt  := aEventosParm[nI][1][nX][3] //Descrição do evento
				cCmpTrab  := aEventosParm[nI][1][nX][6] //Id do Trabalhador
				cTipoEvt  := aEventosParm[nI][1][nX][8] //Tipo do Evento
				cCmpData  := aEventosParm[nI][1][nX][7] //Campo que determina o periodo ou data do evento
				cRelacTrb := aEventosParm[nI][1][nX][11] //Define se o evento tem relação com o Trabalhador

				If  cRelacTrb != "S"

					cLayFilpar := TafMonPFil(cAliasLay,@oTabFilSel)

					If !Empty(cQry)
						cQry += " UNION ALL "
					EndIf

					If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
						cQry += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK"
					Else
						cQry += " SELECT DISTINCT '  ' MARK"
					EndIf

					cQry += ", '" 				    + PADR(cLayout  ,006,"") 	+ "' XEVENTO "
					cQry += ", '" 					+ PADR(cDescEvt ,220,"") 	+ "' XDESC "
					cQry += ", '" 					+ PADR(cAliasLay,003,"") 	+ "' XALIAS "
					cQry += ", '" 					+ PADR(cCmpTrab ,010,"")	+ "' XCMPTRAB "
					cQry += ", '" 					+ PADR(cCmpData ,010,"") 	+ "' XCMPDATA "
					cQry += ", '" 					+ PADR(cTipoEvt ,001,"")	+ "' XTIPOEVT "
					cQry += ", TOTEVT.BRANCO STSBRANCO "
					cQry += ", TOTEVT.ZERO STSZERO "
					cQry += ", TOTEVT.UM STSUM "
					cQry += ", TOTEVT.DOIS STSDOIS "
					cQry += ", TOTEVT.TRES STSTRES "
					cQry += ", TOTEVT.QUATRO STSQUATRO "
					cQry += ", TOTEVT.SEIS STSSEIS "
					cQry += ", TOTEVT.SETE STSSETE "
					cQry += ", TOTEVT.TOTAL STSTOTAL "
					cQry += ", TOTEVT.BRANCO + TOTEVT.ZERO + TOTEVT.UM + TOTEVT.DOIS + TOTEVT.TRES  PENDENTE " 

					cQry += " FROM " + RetSqlName(cAliasLay) + " " + cAliasLay
					cQry += " INNER JOIN " + cArqCountEvt:GetRealName() + " TOTEVT ON TOTEVT.EVENTO = '" + cLayout + "'"

					If lTAFKEY
						cQry += " INNER JOIN TAFXERP TAFXERP "
						cQry += "    ON TAFXERP.TAFALIAS = '" + cAliasLay + "' "
						cQry += "   AND TAFXERP.TAFRECNO = " + cAliasLay + ".R_E_C_N_O_ "
						cQry += "   AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
						cQry += "   AND TAFXERP.D_E_L_E_T_ = '' "
					EndIf

					cQry += " WHERE "
				  	cQry +=  cAliasLay + "_FILIAL IN ("
				  	cQry += cLayFilpar
				  	cQry += ")

			        If TafColumnPos( cAliasLay + "_STASEC" )
			        	cQry += " AND (" + cAliasLay + "_ATIVO = '1' OR " +cAliasLay + "_STASEC = 'E' )"
			        Else
			        	cQry += " AND " + cAliasLay + "_ATIVO = '1' "
			        EndIf

					cQry += " AND " + cAliasLay + "_EVENTO <> 'E' "
					cQry += " AND " + cAliasLay + "_STATUS IN (" + cStatus + ") "

					If cAliasLay $ "C9V|C91"
						cQry += " AND " + cAliasLay + "_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
					EndIf

					// Realiza trava para eventos S-1200 e S-1210 para apenas visualização de autônomos.
					If lLockAuton .And. cAliasLay $  "C91|T3P"
						cQry += " AND " + cAliasLay + "_TRABEV= 'TAUTO' "
					EndIf


					cQry += " AND " + cAliasLay + ".D_E_L_E_T_ <> '*' "

				EndIf

			Next nX
		EndIf
	Next nI

	
		cQry := " SELECT MARK,XEVENTO,XDESC,XALIAS,XCMPTRAB,XCMPDATA,XTIPOEVT,STSBRANCO,STSZERO,STSUM,STSDOIS,STSTRES,STSQUATRO,STSSEIS,STSSETE,STSTOTAL,PENDENTE FROM ( " + cQry + " ) TAF "
	

	//cQry := ChangeQuery(cQry)

	//MemoWrite("C:\memowrite\tafmoneper_visao1.txt", cQry )

EndIf


Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} TafRetStus
Retorna Descrição do Status de acordo com os itens
do array aStatus

@author evandro.oliveira
@since 16/02/2016
@version 1.0
@param cCampo, character, (Campo Status da tabela avaliada)
@param nItem, numeric, (Sub-Item do array aStatus )
@return ${xValor}, ${Valor do Status}
/*/
//---------------------------------------------------------------------
Function TafRetStus(cCampo, nItem)

Local nStatus	:= 0
Local nPos		:= 0

Default cCampo	:= ""
Default nItem	:= 0

//Se o Campo for vazio troco por 99 (Status dos registros não validados)
nStatus := IIf (Empty(AllTrim(cCampo)),STATUS_NAO_PROCESSADO[1],Val(cCampo) )

nPos := aScan(aStatus,{|x|x[1] == nStatus })
If nPos > 0
	xValor := aStatus[nPos][nItem]
EndIf

Return xValor
//---------------------------------------------------------------------
/*/{Protheus.doc} FCountMark
Calcula os itens selecionados no Browse

@author evandro.oliveira
@since 07/04/2016
@version 1.0
@return ${Nil}
/*/
//---------------------------------------------------------------------
Static Function FCountMark()

Local nRegSelTrb := 0

If !Empty((cAliasEvt)->MARK)

	nRegSelTrb := TafMCountBrw(oMarkTrb)

	If nRegSelTrb > 0
		MsgAlert("Retirar a Seleção do Browse Trabalhador para realizar a marcação do Browse Eventos")
		//Retiro a Marcação do Item por que o mesmo já recebeu a marca do sistema.
		If RecLock(cAliasEvt,.F.)
			(cAliasEvt)->MARK := "  "
			(cAliasEvt)->(MsUnlock())
		EndIf
	EndIf
EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll
Inverte a indicação de seleção de todos registros do Browse.

@param	lMarca - Define se deve ter a Marcar ou Desmarcar todos

@Return	Nil
@Author	Evandro dos Santos
@Since		10/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMarkAll(lMarca)

	Local cAlias	:= oMarkEvt:Alias()
	Local cMark		:= ""
	Local cTableEvt	:= ""
	Local cQuery	:= ""
	Local nRecno	:= (cAlias)->(Recno())
	Local nLenRegs	:= 0
	Local oDataMark	:= oMarkEvt:Data()
	Local lHasLines	:= .T.
	Local nPosBrw	:= oMarkEvt:At()

	//oMarkEvt:AllMark()

	oMarkEvt:SetInvert(lMarca)
	oMarkEvt:Refresh()

	If lMarca
		cMark := getMark()
	Else
		cMark := '  '
	EndIf

	cQuery := " UPDATE "
	cQuery += oDataMark:oTempDB:GetRealName()
	cQuery += " SET MARK = '" + cMark + "'"


	If TCSQLExec (cQuery) < 0
		MsgInfo (TCSQLError(),"Update Mark Eventos.")
	EndIf

	(cAlias)->(dbGoTo(nRecno))

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} FechaAlias
Fecha os Alias Utilizados na Função FCriaMonit
@author brunno.costa
@since 19/08/2018
@version 1.0
@return ${Nil}
/*/
//--------------------------------------------------------------------

Static Function FechaAlias()

	If Select(cAliasEvt) > 0
		(cAliasEvt)->(DbCloseArea())
	EndIf

	If Select(cAliasTotEvt) > 0
		(cAliasTotEvt)->(DbCloseArea())
	EndIf

Return
