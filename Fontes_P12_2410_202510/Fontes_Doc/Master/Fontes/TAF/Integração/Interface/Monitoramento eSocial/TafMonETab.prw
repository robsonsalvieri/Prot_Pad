#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TAFMONTES.CH"

Static lLaySimplif 	:= taflayEsoc("S_01_00_00")
Static lFindClass 	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMonETab
Browse dos Eventos de Tabelas e-Social

@author evandro.oliveira
@since 26/02/2016
@version 1.0
@param oPanel, objeto, (Objeto que o Browse será criado.)
@param lRefresh, logico, (Indica que o browse deve ser atualizado)
@param aChecks, array, (Contem informações dos status selecionados na tela de parâmetros)
@param oMBrwTabs, objeto, (Browse dos regsitros de tabela)
@param lTempTable - Verifica se o build em execução permite a utilização de tabelas 
	   temporarias no banco de dados. Variável mantida apenas por compatibilidade.
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${Nil}
/*/
//---------------------------------------------------------------------
Function TafMonETab(oPanel, lRefresh, aChecks, oMBrwTabs,lTempTable,oTabFilSel)

Local aStru			:= {}
Local aHeadTab		:= {}
Local aFiltro		:= {}
Local nZ			:= 0
Local cStsAux		:= ""
Local lVirgula		:= .F.
Local nTotal		:= 0
Local aSeek			:= {}
Local nLinBrw		:= 0
Local nMark			:= 0
Local cMsg			:= ""
Local cAliasTrb		:= ""
Local cErroSQL		:= ""

Default oPanel		:= Nil
Default lRefresh	:= .F.  
Default aChecks		:= {}
Default oMBrwTabs	:= Nil
Default lTempTable	:= .F. // Mantido por compatibilidade.
Default oTabFilSel	:= Nil

If !lRefresh

	FTableCodTabs()

	/*+-------------------------------------------+
	  | Cria estrutura para o arquivo de trabalho | 
	  +--------------------------------------------+*/	
	aAdd(aStru,{ "MARK"   	, "C",  002, 0})
	aAdd(aStru,{ "XEVENTO"  , "C",  060, 0})

	aAdd(aStru,{"REGINVLD"	, "N",  010, 0})
	aAdd(aStru,{"REGSRET"	, "N",  010, 0})
	aAdd(aStru,{"REGVALID"	, "N",  010, 0})
	aAdd(aStru,{"REGNPROC"	, "N",  010, 0})
	aAdd(aStru,{"REGINCOS"	, "N",  010, 0})
	aAdd(aStru,{"REGCONST"	, "N",  010, 0})
	
	aAdd(aStru,{ "TOTAL" 	, "N",  010, 0})
	
	/*+-------------------------------+
	  | Cria colunas para o Browse    | 
	  +-------------------------------+*/	
    aAdd(aHeadTab,FWBrwColumn():New())
    aHeadTab[Len(aHeadTab)]:SetData( {||AllTrim((cAliasTab)->XEVENTO) } )
    aHeadTab[Len(aHeadTab)]:SetTitle(STR0111) //Evento 
    aHeadTab[Len(aHeadTab)]:SetSize(50) 
    aHeadTab[Len(aHeadTab)]:SetDecimal(0)
    aHeadTab[Len(aHeadTab)]:SetPicture("@!") 
    aHeadTab[Len(aHeadTab)]:SetAlign(1)
    aAdd(aFiltro,{"XEVENTO"  ,STR0111,"C",60,0,"@!"}) //Evento
     
	For nZ := 1 To Len(aChecks)
		If aChecks[nZ][1]
		   	aAdd(aHeadTab,FWBrwColumn():New())
		   	aHeadTab[Len(aHeadTab)]:SetData( &("{||"+ aChecks[nZ][2]+ "}") )
		   	aHeadTab[Len(aHeadTab)]:SetTitle(aChecks[nZ][3]) 
		   	aHeadTab[Len(aHeadTab)]:SetSize(10) 
		   	aHeadTab[Len(aHeadTab)]:SetDecimal(0) 
	    	aHeadTab[Len(aHeadTab)]:SetType("N")
		  	aHeadTab[Len(aHeadTab)]:SetAlign(0)
		  	aHeadTab[Len(aHeadTab)]:SetDoubleClick( &("{|oColl|IIf((cAliasTab)->&(aChecks[" + AllTrim(Str(nZ)) + "][2]) > 0,FWMsgRun(,{|oColl|TafMonDet(oColl,aChecks[" + AllTrim(Str(nZ)) + "][4] ,(aChecks[" + AllTrim(Str(nZ)) + "][3]),Substr((cAliasTab)->XEVENTO,1,6),,,,,,'Tabelas',,,,@oTabFilSel),TafMonETab(,.T.,aChecks,oMBrwTabs,,@oTabFilSel)},'" + STR0084 +"','" +STR0157 +"'),.F.)}"))  //'Detalhamento'#'Consultando Registros no TSS'
		
			IIf (lVirgula,cStsAux += ",",lVirgula := .T.)
			cStsAux += "'" + IIf(aChecks[nZ][4] == STATUS_NAO_PROCESSADO[1], "  ",AllTrim(Str(aChecks[nZ][4])) ) + "'"
			aAdd(aFiltro,{aChecks[nZ][2]  ,aChecks[nZ][3],"N",10,0,""})

		EndIf
	Next nZ        

	aAdd(aHeadTab,FWBrwColumn():New())
   	aHeadTab[Len(aHeadTab)]:SetData( {||(cAliasTab)->TOTAL } )
   	aHeadTab[Len(aHeadTab)]:SetTitle(STR0158) //'Total de Registros'
   	aHeadTab[Len(aHeadTab)]:SetSize(10) 
   	aHeadTab[Len(aHeadTab)]:SetDecimal(0)
   	aHeadTab[Len(aHeadTab)]:SetType("N")
   	aHeadTab[Len(aHeadTab)]:SetAlign(0)
   	aHeadTab[Len(aHeadTab)]:SetDoubleClick( {|oColl|FWMsgRun(,{|oColl|TafMonDet(oColl,cStsAux,STR0159,Substr((cAliasTab)->XEVENTO,1,6),,,,,,'Tabelas')},STR0084,STR0157) } ) //''TODOS'#Detalhamento'#'Consultando Registros no TSS'
	aAdd(aFiltro,{"TOTAL"  ,STR0158,"N",10,0,"@!"}) //Total de Registros
	
	oTmpTabls := FWTemporaryTable():New(cAliasTab)
	oTmpTabls:SetFields(aStru)
	oTmpTabls:AddIndex("I1",{"XEVENTO"}) 
	oTmpTabls:Create()

	FFillBrow(aChecks,@oTabFilSel)

	/*+-------------------------+
	  | Cria e ativa o Browse   | 
	  +-------------------------+*/	
	oPGerTb := TPanel():New(00,00,"",oPanel,,.F.,.F.,,,10,oPanel:NCLIENTHEIGHT * 0.50,.F.,.F.) 
	oPGerTb:Align = CONTROL_ALIGN_ALLCLIENT
	If lFindClass .And. !(GetRemoteType() == REMOTE_HTML) .and. !(FWCSSTools():GetInterfaceCSSType() == 5)
		oPGerTb:setCSS(QLABEL_AZUL_A)
	EndIf

	aAdd( aSeek, {STR0111,{{ "", "C", 6, 0, "XEVENTO","@!", }}}) //Eventos
	
	oMBrwTabs := FWMarkBrowse():New()
	oMBrwTabs:SetAlias(cAliasTab)
	oMBrwTabs:oBrowse:SetFieldFilter(aFiltro)
	oMBrwTabs:SetColumns(aHeadTab)
	oMBrwTabs:SetFieldMark("MARK")
	oMBrwTabs:SetValid( {|| FPerAcess(cAliasTrb,Substr((cAliasTab)->XEVENTO,1,6),@cMsg,@nMark)} ) //Valida a permissão de acesso
	oMBrwTabs:SetDescription(STR0160 +" / " + STR0168) //'Eventos de Tabelas'
	oMBrwTabs:DisableDetails()
	oMBrwTabs:SetUseFilter( .T. )
	oMBrwTabs:oBrowse:SetDBFFilter()
	oMBrwTabs:SetSeek(.T.,aSeek)
	oMBrwTabs:SetAllMark({||FMarkAll(oMBrwTabs)})
	oMBrwTabs:SetTemporary(.T.)
	oMBrwTabs:Activate(oPGerTb)
	cAliasTrb := oMBrwTabs:Alias()
	//Força o posicionamento do primeiro registro
	oMBrwTabs:GoTo(1)
	
Else

	nLinBrw := oMBrwTabs:oBrowse:nAt

	If !TafDelTempTable(oTmpTabls:GetRealName(),@cErroSQL)
		MsgInfo (cErroSQL,"Exclusão Tabela Temporária") 
	EndIf 

	FFillBrow(aChecks,@oTabFilSel)
	oMBrwTabs:GoTo(nLinBrw)
	oMBrwTabs:Refresh(.T.)

EndIf
	 
Return NIL 

//---------------------------------------------------------------------
/*/{Protheus.doc} FFillBrow
Realiza consulta para aBrowse Eventos Iniciais (Tabelas)
e alimenta o arquivo de trabalho.

@author evandro.oliveira
@since 16/02/2016
@version 1.0
@param aChecks, array, (Contem informações dos status selecionados na tela de parâmetros)
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${Nil}
/*/
//---------------------------------------------------------------------
Static Function FFillBrow( aChecks ,oTabFilSel)

Local cQry			:= ""
Local cTAFKEY		:= ""
Local nX			:= 0
Local nY			:= 0
Local nI			:= 0
Local nTotal		:= 0
Local aTAFKEY		:= {}
Local aAux			:= {}
Local lTAFKEY		:= .F.
Local cAliasLay		:= ""
Local cLayout		:= ""
Local cDescEvt		:= ""
Local cTipoEvt		:= ""
Local cCmpData		:= ""
Local cRelacTrb		:= ""
Local cQryTabs		:= ""
Local cQryRet		:= ""
Local cBanco		:= AllTrim(TCGetDB())
Local nStatus		:= 0
Local cCmpAux		:= ""
Local cIndApu		:= ""

Default aChecks		:= {}
Default oTabFilSel	:= Nil

If !Empty( paramTAFKEY )
	aTAFKEY	:=	StrToKArr( paramTAFKEY, "," )

	For nX := 1 to Len( aTAFKEY )
		cTAFKEY += "'" + AllTrim( aTAFKEY[nX] ) + "'" + ","
	Next nX

	cTAFKEY := SubStr( cTAFKEY, 1, Len( cTAFKEY ) - 1 )

	lTAFKEY	:= !Empty( cTAFKEY )
EndIf

For nI := 1 To Len(aEventosParm)

	nEventos := Len(aEventosParm[nI][1]) 
	
	//Verifico se o Tipo de Evento foi Marcado e se o mesmo faz parte do escopo da query, tenho que pegar os mensais e os eventuais por
	//causa dos eventos que não tem relação com o trabalhador.	
	If nEventos > 0 .And. aEventosParm[nI][2] .And. aEventosParm[nI][3] $ EVENTOS_INICIAIS[2] + EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2] 
		For nX := 1 To nEventos 
		
			cAliasLay := aEventosParm[nI][1][nX][1] //Alias do Evento
			cLayout   := aEventosParm[nI][1][nX][2] //Layout
			cDescEvt  := aEventosParm[nI][1][nX][3] //Descrição do evento
			cTipoEvt  := aEventosParm[nI][1][nX][8] //Tipo do Evento
			cCmpData  := aEventosParm[nI][1][nX][7] //Campo que determina o periodo ou data do evento
			cRelacTrb := aEventosParm[nI][1][nX][11] //Define se o evento tem relação com o Trabalhador

			If  aEventosParm[nI][3] $ EVENTOS_INICIAIS[2]  // Já está considerando também cRelacTrb == "S" 

				cQryTabs := "SELECT COUNT(*) QUANT "
				cQryRet  := "SELECT " + cAliasLay + "_FILIAL FILIAL "

				cQryRet  += ", " + cAliasLay + "_ID ID "
				cQryRet  += ", " + cAliasLay + "_VERSAO VERSAO "
				cQryRet  += ", '" + cLayout  + "' EVENTO "
				cQryRet  += getCodTabs(cLayout,cAliasLay) + " CODIGO "
				cQryRet  += getDescrTabs(cLayout,cBanco)  + " DESCRICAO "

				cQry := "      , " + cAliasLay + "_STATUS XSTATUS "
				cQry += "FROM " + RetSqlName( cAliasLay ) + " " + cAliasLay + " "
		
				If lTAFKEY
					cQry += "INNER JOIN TAFXERP TAFXERP "
					cQry += "  ON TAFXERP.TAFALIAS = '" + cAliasLay +  "' "
					cQry += " AND TAFXERP.TAFRECNO = " + ( cAliasLay ) + ".R_E_C_N_O_ "
					cQry += " AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
					cQry += " AND TAFXERP.D_E_L_E_T_ = '' "
				EndIf
		
				If TafColumnPos( cAliasLay + "_STASEC" )
					cQry += " WHERE " + "(" + cAliasLay + "." + cAliasLay + "_ATIVO = '1' OR " + cAliasLay + "." + cAliasLay + "_STASEC = 'E' )" 
				Else
					cQry += " WHERE " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "
				EndIf

				//Os Eventos de tabela não usam o S-3000 por isso eu considero os Excluidos
				If cTipoEvt != EVENTOS_INICIAIS[2]
					cQry += " AND " + cAliasLay + "_STATUS <> 'E'
				EndIf
				cQry += " AND " + cAliasLay + ".D_E_L_E_T_ <> '*' "
				
				//para C1E devo olhar para o campo _FILTAF ao invés de _FILIAL
				If cAliasLay == "C1E"
					cQry += " AND " + cAliasLay + "." + cAliasLay + "_FILTAF IN ( "
				Else
					cQry += " AND " + cAliasLay + "." + cAliasLay + "_FILIAL IN ( "
				Endif
				cQry += TafMonPFil(cAliasLay,@oTabFilSel)
				cQry += ") "
		
				If AllTrim( cLayout ) $ "S-1070"
					cQry += "  AND " + cAliasLay + "." + cAliasLay + "_ESOCIA = '1' "
				EndIf
				
				If cTipoEvt == EVENTOS_MENSAIS[2] .Or. cAliasLay = "CMJ" 
					
					If lLaySimplif
						
						cIndApu := Space(GetSx3Cache(cAliasLay + "_INDAPU", "X3_TAMANHO"))
					
					EndIf

					cQry += " AND ( "

					If !lLaySimplif

						cQry += " (" + cAliasLay + "_INDAPU = '1' "

					Else

						cQry += " ((" + cAliasLay + "_INDAPU = '1' "
						cQry += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

					EndIf

					cQry += " AND " + cAliasLay + "." + cCmpData + " >= '" + AnoMes(paramDataInicial) + "'" 
					cQry += " AND " + cAliasLay + "." + cCmpData + " <= '" + AnoMes(paramDataFim) + "')"

					If !lLaySimplif

						cQry += " OR (" + cAliasLay + "_INDAPU = '2' "

					Else

						cQry += " OR ((" + cAliasLay + "_INDAPU = '2' "
						cQry +=  " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

					EndIf

					cQry += " AND " + cAliasLay + "." + cCmpData +  " BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')" 
					cQry += " OR (" + cAliasLay + "_INDAPU = '" + cIndApu + "' " 
					cQry += " AND " + cAliasLay + "." + cCmpData + " = ' ' AND '" + cAliasLay + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
					cQry += ")"				
				ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ" 
					cQry += " AND " + cAliasLay + "." + cCmpData + " >= '" + DtoS(paramDataInicial) + "'" 
					cQry += " AND " + cAliasLay + "." + cCmpData + " <= '" + DtoS(paramDataFim) + "'"			
				EndIf
				//Só pego o registro da Matriz
				If cAliasLay == "C1E"
					cQry += " AND C1E_MATRIZ = 'T' "
				EndIf
		
				cQryTabs += cQry
				cQryTabs += "GROUP BY " + cAliasLay + "." + cAliasLay + "_STATUS "
				cQryTabs := ChangeQuery( cQryTabs )
				TCQuery cQryTabs New Alias "AliasTot"

				cQryRet += cQry
				
				//Comentado ChangeQuery, pois em alguns bancos não aceita "READ ONLY"
				//cQryRet := ChangeQuery(cQryRet)

				insertTabCod(cQryRet) 
		
				nTotal	:=	0
				aAux	:=	{}
		
				While AliasTot->( !Eof() )
					nStatus := Iif( Empty( AllTrim( AliasTot->XSTATUS ) ), STATUS_NAO_PROCESSADO[1], Val( AliasTot->XSTATUS ) ) //Troco os status em branco por 99
		
					If ( nPos := aScan( aChecks,{ |x| x[4] == nStatus } ) ) > 0
						cCmpAux := aChecks[nPos][2]
		
						aAdd( aAux, { cCmpAux, ALIASTOT->QUANT } )
		
						If aChecks[nPos][1]
							nTotal += AliasTot->QUANT
						EndIf
					EndIf
		
					AliasTot->( DBSkip() )
				EndDo
		
				AliasTot->( DBCloseArea() )
		
				If lTAFKEY
				 	If nTotal > 0
				 		RecLock( ( cAliasTab ), .T. )
				 		( cAliasTab )->MARK		:=	"  "
				 		( cAliasTab )->XEVENTO	:=	cLayout + " - " + cDescEvt 
		
				 		For nY := 1 to Len( aAux )
				 			( cAliasTab )->&( aAux[nY,1] ) := aAux[nY,2]
				 		Next nY
		
				 		( cAliasTab )->TOTAL := nTotal
				 		( cAliasTab )->( MsUnlock() )
				 	EndIf
				Else
					RecLock( ( cAliasTab ), .T. )
					( cAliasTab )->MARK		:=	"  "
					( cAliasTab )->XEVENTO	:=	cLayout + " - " + cDescEvt 
		
					For nY := 1 to Len( aAux )
						( cAliasTab )->&( aAux[nY,1] ) := aAux[nY,2]
					Next nY
		
					( cAliasTab )->TOTAL := nTotal
					( cAliasTab )->( MsUnlock() )
				EndIf
			EndIf
		Next nX
		(cAliasTab)->(dBGoTop())
	EndIf
Next nI

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll
Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção
@Return	Nil
@Author	Evandro dos Santos 
@Since		10/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMarkAll(oMBrwTabs)

Local cAlias		:= oMBrwTabs:Alias()
Local cMark			:= oMBrwTabs:Mark()
Local nRecno		:= ( cAlias )->( Recno() )

Private lMarkAll	:= .T.

Default oMBrwTabs	:= Nil

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif(( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf
	( cAlias )->( DBSkip() )
EndDo
( cAlias )->( DBGoTo( nRecno ) )

oMBrwTabs:Refresh()

Return()

Static Function FTableCodTabs()

	Local aStru := {} 

	If Select(cAlsCodTab) == 0

		aAdd(aStru,{ "FILIAL"  		, "C",  FWSizeFilial(), 0})
		aAdd(aStru,{ "ID"  			, "C",  036, 0}) 
		aAdd(aStru,{ "VERSAO"  		, "C",  014, 0})
		aAdd(aStru,{ "EVENTO"  		, "C",  006, 0})
		aAdd(aStru,{ "CODIGO"    	, "C",  050, 0})
		aAdd(aStru,{ "DESCRICAO"    , "C",  220, 0})
		aAdd(aStru,{ "XSTATUS"    	, "C",  001, 0})

		cArqCodTabs := FWTemporaryTable():New(cAlsCodTab)
		cArqCodTabs:SetFields(aStru)
		cArqCodTabs:AddIndex("I1",{"FILIAL","EVENTO","ID","VERSAO"}) 
		cArqCodTabs:Create()

	EndIf 

Return 

Static Function insertTabCod(cQry)

	Local cSqlInsert := ""

	cSqlInsert := "INSERT INTO " + cArqCodTabs:GetRealName() 
	cSqlInsert += "(FILIAL,ID,VERSAO,EVENTO,CODIGO,DESCRICAO,XSTATUS)" 
	cSqlInsert += " " 
	cSqlInsert += cQry

	If TCSQLExec (cSqlInsert) < 0
		MsgInfo (TCSQLError(),"Erro no Insert do Browse de Tabelas ")
	EndIf	

Return Nil

/*/{Protheus.doc} getDescrTabs
Retorna a descrição para os eventos de tabela

@type function
@author Evandro dos Santos O. Teixeira
@since 04/02/2018
@version 1.0
@param cLayout - Codigo do Layout
@return cDescricao - Descrição do evento
/*/
Static Function getDescrTabs(cLayout, cBanco)

	Local cDescricao := "" 

	Default cLayout := ""

	Do Case
		Case  cLayout == "S-1000"
			cDescricao := "C1E_NOME " 
		Case cLayout == "S-1005"
			cDescricao := "C92_NRINSC "
		Case cLayout == "S-1010"
			cDescricao := "C8R_DESRUB "
		Case cLayout == "S-1020"
			cDescricao := "C99_DESCRI "
		Case cLayout == "S-1030"
			cDescricao := "C8V_DESCRI "
		Case cLayout == "S-1035"
			cDescricao := "T5K_DESCRI " 
		Case cLayout == "S-1040"
			cDescricao := "C8X_DESCRI "
		Case cLayout == "S-1050"
			cDescricao := "C90_DESCRI "
		/*
		Case cLayout == "S-1060"
			If cBanco == "ORACLE"
				cDescricao := " utl_raw.cast_to_varchar2(dbms_lob.substr(T04_DESCRI)) "
			Else
				cDescricao := " CAST(T04_DESCRI AS VARCHAR) " //Nao colocado o tamaho do TamSX3, campo memo //vER pq sai desconfigurado no POSTGRES
			endif  */
		Case cLayout == "S-1070"
			cDescricao := " CASE WHEN C1G_TPPROC = '1' THEN 'PROCESSO JUDICIAL' "
			cDescricao += " 	 WHEN C1G_TPPROC = '2' THEN 'PROCESSO ADMINISTRATIVO' "
			cDescricao += " 	 WHEN C1G_TPPROC = '3' THEN 'NÚMERO DE BENEFÍCIO (NB) do INSS' "
			cDescricao += " 	 WHEN C1G_TPPROC = '4' THEN 'PROCESSO FAP' 
			cDescricao += " 	 ELSE ' ' END "
		Case cLayout == "S-1080"
			cDescricao := " C8W_DTINI "
		OtherWise
			cDescricao := "' '"
	EndCase

	cDescricao := ',' + cDescricao

Return (cDescricao)

Static Function getCodTabs(cLayout,cAliasLay)

	Local cCodigo := ""

	If AllTrim( cLayout ) $ "S-1020|S-1030|S-1035|S-1040|S-1050|S-1060"
		cCodigo += " ," + cAliasLay + "." + cAliasLay + "_CODIGO  "
	ElseIf AllTrim( cLayout ) $ "S-1000"
		cCodigo += " ," + cAliasLay + "." + cAliasLay + "_FILTAF  "
	ElseIf AllTrim( cLayout ) $ "S-1005"
		cCodigo += " ," + cAliasLay + "." + cAliasLay + "_NRINSC  "
	ElseIf AllTrim( cLayout ) $ "S-1010"
		cCodigo += " ," + cAliasLay + "." + cAliasLay + "_CODRUB  "
	ElseIf AllTrim( cLayout ) $ "S-1070"
		cCodigo += " ," + cAliasLay + "." + cAliasLay + "_NUMPRO  "
	ElseIf AllTrim( cLayout ) $ "S-1080"
		cCodigo +=  " ," + cAliasLay + "_CNPJOP  "
	Else
		cCodigo += " ,' ' "
	EndIf

Return cCodigo

