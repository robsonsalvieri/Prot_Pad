#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TAFMONTES.CH"

Static lLaySimplif 	:= taflayEsoc("S_01_00_00")
Static lFindClass 	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMonETrb
Cria Browse dos eventos relacionados ao trabalhador

@author evandro.oliveira
@since 26/02/2016
@version 1.0
@param oPanel, objeto, (Objeto que o browse será criado.)
@param lRefresh, ${param_type}, (Indica que o Browse deve ser atualizado)
@param aChecks, array, (array com os status normalizados)
@param nRegSelTrb, Compatibilidade - deixou de ser usando em 04/07/2018
@param nRegSelEvt, Compatibilidade - deixou de ser usando em 04/07/2018
@param lTempTable - Verifica se o build em execução permite a utilização de tabelas
	   temporarias no banco de dados.
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${Nil}
@obs Na Atualização do browse ele se baseia no evento posicionado no browse
dos eventos periódicos e não periódicos
/*/
//---------------------------------------------------------------------
Function TafMonETrb(oPanel, lRefresh, aChecks, nRegSelTrb, nRegSelEvt,lTempTable,oTabFilSel)

Local cQry			:= ""
Local aStruTrb		:= {}
Local aCampos		:= {}
Local aColsTrb		:= {}
Local nX			:= 0
Local aCmpTrab		:= {}
Local aFiltro		:= {}
Local aSeek			:= {}
Local aStru			:= {}
Local nLinBrw		:= 0
Local nMark			:= 0
Local cMsgPend		:= ""
Local cMsgSPend		:= ""
Local cMsg			:= ""
Local cAlsTrb		:= ""
Local cErroSQL		:= ""
Local cBancoDB		:= tcGetDb()
Local aIndex		:= {}
Local lOrdena		:= .F.

Default oPanel		:= Nil
Default lRefresh	:= .F.
Default aChecks		:= {}
Default lTempTable	:= .F.
Default oTabFilSel	:= Nil

aCmpTrab	:= {"C9V_FILIAL","C9V_NOME","C9V_MATRIC","C9V_CPF","C9V_ID","C9V_NOMEVE","C9V_CADINI"}

aAdd(aStru,{ "MARK"   		, "C"									, 02										, 0})
aAdd(aStru,{ "RECNO"   	 	, "N"									, 08										, 0})
aAdd(aStru,{ "C9V_FILIAL"  	, GetSx3Cache("C9V_FILIAL" 	,"X3_TIPO")	,GetSx3Cache("C9V_FILIAL"	,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "PENDENTE"  	, "N"									, 12										, 0})
aAdd(aStru,{ "C9V_MATRIC"	, GetSx3Cache("C9V_MATRIC"	,"X3_TIPO")	,GetSx3Cache("C9V_MATRIC"	,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_CPF"  	, GetSx3Cache("C9V_CPF"	 	,"X3_TIPO")	,GetSx3Cache("C9V_CPF"		,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_NOME"  	, GetSx3Cache("C9V_NOME"	,"X3_TIPO")	,GetSx3Cache("C9V_NOME"		,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_ID"  		, GetSx3Cache("C9V_ID" 		,"X3_TIPO")	,GetSx3Cache("C9V_ID"		,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_VERSAO"  	, GetSx3Cache("C9V_VERSAO" 	,"X3_TIPO")	,GetSx3Cache("C9V_VERSAO"	,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_NOMEVE"  	, GetSx3Cache("C9V_ID" 		,"X3_TIPO")	,GetSx3Cache("C9V_NOMEVE"	,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "C9V_CADINI"  	, GetSx3Cache("C9V_CADINI" 	,"X3_TIPO")	,GetSx3Cache("C9V_CADINI"	,"X3_TAMANHO")	, 0})
aAdd(aStru,{ "TAFOWNER"		, GetSx3Cache("C91_OWNER" 	,"X3_TIPO")	,GetSx3Cache("C91_OWNER"	,"X3_TAMANHO")	, 0})

If (!lRefresh)

	cQuery := FFillBrow(aClone(aStru),@oTabFilSel)
	/*+-------------------------------+
	  | Cria colunas para o Browse    | 
	  +--------------------------------+*/
	cMsgPend := IIf(paramVisao == 2,STR0150,STR0148)//"1-Com pendências"#"1-Com pendência"
	cMsgSPend := IIf(paramVisao == 2,STR0151,STR0149)//"2-Sem pendências"#"2-Sem pendência"
	
	aAdd(aColsTrb,FWBrwColumn():New())
	aColsTrb[1]:SetTitle('Status')
	aColsTrb[1]:SetData({||IIf( (cAliasTrb)->PENDENTE == 1 ,cMsgPend,cMsgSPend)})	

	aColsTrb[1]:SetSize(15)
	aColsTrb[1]:SetDecimal( 0 )
	aColsTrb[1]:SetPicture("")	
		
	aAdd(aFiltro	,{"PENDENTE",STR0112,'N',1,0,""}) //'Status'

	For nX := 1 To Len(aCmpTrab)

		aAdd(aColsTrb,FWBrwColumn():New())
		aColsTrb[Len(aColsTrb)]:SetTitle(getTitleBrw(aCmpTrab[nX]))
		//Tratamento para trazer o ultimo nome do trabalhador (olhando  S-2205)
		If aCmpTrab[nX] == "C9V_NOME"
			aColsTrb[Len(aColsTrb)]:SetHeaderClick(&("{||ordenaBrw(aStru,oTabFilSel,@lOrdena,'C9V_NOME')}"))
		EndIf 
		
		If FindFunction('monGetTrbName')
			If aCmpTrab[nX] == "C9V_NOME"
				aColsTrb[Len(aColsTrb)]:SetData(&("{||getNomeTrab('" + cBancoDB + "' )}"))
			Else
				aColsTrb[Len(aColsTrb)]:SetData(&("{||" + getValueBrw(aCmpTrab[nX]) + "}"))
			EndIf 
		Else
			aColsTrb[Len(aColsTrb)]:SetData(&("{||" + getValueBrw(aCmpTrab[nX]) + "}"))
		EndIf 

		aColsTrb[Len(aColsTrb)]:SetSize(GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO"))
		aColsTrb[Len(aColsTrb)]:SetDecimal( 0 )
		aColsTrb[Len(aColsTrb)]:SetPicture(GetSx3Cache(aCmpTrab[nX],"X3_PICTURE"))

		If aCmpTrab[nX] == "C9V_NOMEVE" .Or. aCmpTrab[nX] == "C9V_CADINI"
			aColsTrb[Len(aColsTrb)]:SetAlign(0)
		EndIf

		aAdd(aFiltro	,{aCmpTrab[nX];
						,RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO"));
						,GetSx3Cache(aCmpTrab[nX],"X3_TIPO");
						,GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO");
						,0;
						,"@!"})

		aAdd(aSeek	,{RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO"));
					,{{'';
					,GetSx3Cache(aCmpTrab[nX],"X3_TIPO");
					,GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO");
					,0;
					,aCmpTrab[nX];
					,"@!"}}})


	Next nX

	aAdd(aColsTrb,FWBrwColumn():New())
	aColsTrb[Len(aColsTrb)]:SetTitle('ERP Origem')
	aColsTrb[Len(aColsTrb)]:SetData({|| (cAliasTrb)->TAFOWNER})	

	aColsTrb[Len(aColsTrb)]:SetSize(40)
	aColsTrb[Len(aColsTrb)]:SetDecimal( 0 )
	aColsTrb[Len(aColsTrb)]:SetPicture("@!")

	aAdd(aFiltro	,{'TAFOWNER';
						,'ERP Origem';
						,'C';
						,40;
						,0;
						,"@!"})

	aAdd(aSeek	,{'ERP Origem';
					,{{'';
					,'C';
					,40;
					,0;
					,'TAFOWNER';
					,"@!"}}})

	oPanTrb  := TPanel():New(00,00,"",oPanel,,.F.,.F.,,,10,20,.F.,.F.)
	oPanTrb:Align := CONTROL_ALIGN_ALLCLIENT
	If lFindClass .And. !(GetRemoteType() == REMOTE_HTML) .and. !(FWCSSTools():GetInterfaceCSSType() == 5)
		oPanTrb:setCSS(QLABEL_AZUL_A)
	EndIf

	aIndex := {}
	For nX := 1 To Len( aCmpTrab )
		aAdd(aIndex, aCmpTrab[nX] )
	Next nX

	aAdd(aIndex, "MARK" )
	aAdd(aIndex, "TAFOWNER" )

	oMarkTrb := FWMarkBrowse():New()
	oMarkTrb:SetDataQuery(.T.)
	oMarkTrb:SetQuery(cQuery)
	oMarkTrb:oBrowse:SetQueryIndex(aIndex)

	oMarkTrb:SetAlias(cAliasTrb)
	oMarkTrb:SetColumns(aColsTrb)
	If (paramEtvPeriodicos .Or. paramEtvNaoPeriodicos) .And. paramVisao == 2
		oMarkTrb:SetChange({||FWMsgRun(oPanelEvt,{||TafMonEPer(,.T.,aChecks,,,,@oTabFilSel)}) })
	EndIf
	oMarkTrb:SetFieldMark("MARK")
	oMarkTrb:SetDescription(STR0260) //"Trabalhor Com e Sem Vinculo (S-2200/S-2300)"
	oMarkTrb:DisableDetails()
	oMarkTrb:oBrowse:SetUseFilter(.T.)
	oMarkTrb:oBrowse:SetDBFFilter()
	oMarkTrb:oBrowse:SetFieldFilter(aFiltro)
	oMarkTrb:oBrowse:SetSeek(.T.,aSeek)
	oMarkTrb:bMark  := {||FCountMark()}
	oMarkTrb:SetValid( {|| FPerAcess(cAlsTrb,"S-"+Substr((cAliasTrb)->C9V_NOMEVE,2,4),@cMsg,@nMark)} ) //Valida a permissão de acesso

	oMarkTrb:bAllMark := {||FMarkAll()}
	setFilterOpc(oMarkTrb)
	oMarkTrb:AddButton(STR0261,{||FWMsgRun( ,{|| FopenPnTrab( (cAliasTrb)->RECNO, (cAliasTrb)->C9V_FILIAL, aChecks, "S-"+Substr((cAliasTrb)->C9V_NOMEVE,2,4),@oTabFilSel) },STR0079,STR0156) })	//"Exibir Painel do Trabalhador"#'Trabalhador'#'Abrindo Painel do Trabalhador'
	oMarkTrb:Activate(oPanTrb)
	cAlsTrb := oMarkTrb:Alias()


ElseIf !Empty(oMarkTrb)

	cQuery := FFillBrow(aClone(aStru),@oTabFilSel)
	oMarkTrb:SetQuery(cQuery)
	oMarkTrb:Refresh(.T.)
	oMarkTrb:Gotop(.T.)

EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ordenaBrw
Realiza a ordenação do browse de acordo com o parametro cCampoOrd

@author evandro.oliveira
@since 06/08/2020
@version 1.0
@param aStru - Estrutura dos campos
@param oTabFilSel - Arquivo temporario com as filiais selecionadas
@param lOrdena - Variavel de controle da ordenação (ASC - DESC )
@param cCampoOrd - Campo utilizado para ordenação
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ordenaBrw(aStru,oTabFilSel,lOrdena,cCampoOrd)

	Local cQuery := ""

	Default lOrdena := .T.
	Default cCampoOrd := ""

	cQuery := FFillBrow(aClone(aStru),oTabFilSel,@lOrdena,cCampoOrd)
	oMarkTrb:SetQuery(cQuery)
	oMarkTrb:Refresh(.T.)

Return nIl 

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

	oMarkBrw:AddFilter(STR0255,'C9V_CADINI == "1"') //'Cadastro Inicial'
	oMarkBrw:AddFilter("Admissão",'C9V_CADINI == "2"') //'Admissão'
	oMarkBrw:AddFilter(STR0257,'PENDENTE == 1') //'Com Pendências'
	oMarkBrw:AddFilter(STR0258,'PENDENTE == 2') //'Sem Pendências'

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getValueBrw
Retorna o Valor que Será exibido no Browse

@author evandro.oliveira
@since 27/03/2018
@version 1.0
@param cField - Nome do Campo
@return Nil
/*/
//---------------------------------------------------------------------
Static Function getValueBrw(cField)

	Local cValue := ''

	If cField == "C9V_CADINI"
		cValue := "IIf ((cAliasTrb)->C9V_CADINI == '1','1-" + STR0254 + "',IIf ((cAliasTrb)->C9V_CADINI == '2','2-" + STR0256 + "',''))" //'1-Sim'#'2-Não'
	Else
		cValue := "(cAliasTrb)->"+cField
	EndIf

Return cValue

//---------------------------------------------------------------------
/*/{Protheus.doc} getTitleBrw
Retorna o Titulo que Será exibido no Browse

@author evandro.oliveira
@since 27/03/2018
@version 1.0
@param cField - Nome do Campo
@return Nil
/*/
//---------------------------------------------------------------------
Static Function getTitleBrw(cField)

	Local cTitle := ""

	If cField == "C9V_CADINI"
		cTitle := STR0255 //"Cadastro Inicial"
	Else
		cTitle := RTrim(GetSx3Cache(cField,"X3_TITULO"))
	EndIf

Return cTitle

//---------------------------------------------------------------------
/*/{Protheus.doc} FFillBrow
Realiza consulta para aBrowse do Trabalhador
e alimenta o arquivo de trabalho.

@author evandro.oliveira
@since 16/02/2016
@version 1.0
@param aCmpsGrv, array, (Campos do arquivo de trabalho)
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${Nil}
/*/
//---------------------------------------------------------------------
Static Function FFillBrow(aCmpsGrv,oTabFilSel,lOrdena,cCampoOrd)

Local cQryStus		:= ""
Local cAuxQry		:= ""
Local cAuxSts		:= ""
Local cQry			:= ""
Local cTAFKEY		:= ""
Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_05_00")
Local cC9VFilpar	:= ""
Local cIniEsoc		:= SuperGetMv('MV_TAFINIE',.F.," ")
Local nX			:= 0
Local nI			:= 0
Local nY			:= 0
Local nInd			:= 0
Local nTamQry		:= 0
Local aFilSts		:= {}
Local aTAFKEY		:= {}
Local lVirgula		:= .F.
Local lTAFKEY		:= .F.

Default aCmpsGrv	:= {}
Default oTabFilSel	:= Nil
Default lOrdena		:= .F.
Default cCampoOrd	:= ""


aAdd(aFilSts,{paramStsNaoProcessados,STATUS_NAO_PROCESSADO[1]})
aAdd(aFilSts,{paramStsValidos,STATUS_VALIDO[1]})
aAdd(aFilSts,{paramStsInvalidos,STATUS_INVALIDO[1]})
aAdd(aFilSts,{paramStsSemRetorno,STATUS_SEM_RETORNO_GOV[1]})
aAdd(aFilSts,{paramStsConsistente,STATUS_TRANSMITIDO_OK[1]})
aAdd(aFilSts,{paramStsInconsistente,STATUS_INCONSISTENTE[1]})

//Retiro o campo MARK
aCmpsGrv := aDel(aCmpsGrv,1)
aCmpsGrv := aSize(aCmpsGrv,Len(aCmpsGrv)-1)

For nX := 1 To Len(aFilSts)
	If aFilSts[nX][1]
		IIf (lVirgula,cAuxSts += ",",)
			cAuxSts += IIf(aFilSts[nX][2] == STATUS_NAO_PROCESSADO[1], "' '" , + "'" + AllTrim(Str(aFilSts[nX][2])) + "'")
		lVirgula := .T.
	EndIf
Next nX
lVirgula := .F.

If !Empty( paramTAFKEY )
	aTAFKEY	:=	StrToKArr( paramTAFKEY, "," )

	For nX := 1 to Len( aTAFKEY )
		cTAFKEY += "'" + AllTrim( aTAFKEY[nX] ) + "'" + ","
	Next nX

	cTAFKEY := SubStr( cTAFKEY, 1, Len( cTAFKEY ) - 1 )

	lTAFKEY	:= !Empty( cTAFKEY )
EndIf

cC9VFilpar := TafMonPFil("C9V",@oTabFilSel)

FGetQuery(@cQry,cC9VFilpar,cAuxSts,lTAFKEY,cTAFKEY,cIniEsoc,cVerSchema,@oTabFilSel,@lOrdena,cCampoOrd)


Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetQuery
Retorna Sring com a Query a ser utilizada pelo browse

@author evandro.oliveira
@since 07/07/2017
@version 1.0
@param cQryRet 		- String para retorno da Query (referencia - obrigatória)
@param cLayFilpar	- String com o Filtro de filiais (dinamico de acordo com o evento)
@param cC9VFilpar   - String com o Filtro de filiais para o trabalhador
@param cAuxSts		- String com os status selecionados na tela de filtro
@param lTAFKEY		- Determina se ocorreu filtro por TAFKEY
@param cTAFKEY		- String com TafKeys
@param cIniEsoc 	- Data de Inicio do e-Social
@param cVerSchema	- Versão do Schema e-Social
@param oTabFilSel   - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return Nil
/*/
//---------------------------------------------------------------------
Static Function FGetQuery(cQryRet,cC9VFilpar,cAuxSts,lTAFKEY,cTAFKEY,cIniEsoc,cVerSchema,oTabFilSel,lOrdena,cCampoOrd)

	Local nI			:= 0
	Local nX			:= 0
	Local nEventos		:= 0
	Local cLayFilpar	:= ""
	Local cAliasLay		:= ""
	Local cLayout		:= ""
	Local cCmpTrab		:= ""
	Local cTipoEvt		:= ""
	Local cCmpData		:= ""
	Local cRelacTrb		:= ""
	Local cQry 			:= ""
	Local cBancoDB		:= tcGetDb()
	Local aEventoPos	:= {}
	Local cIndApu		:= ""

	Default cQry		:= ""
	Default cC9VFilpar	:= ""
	Default cAuxSts		:= ""
	Default cTAFKEY		:= ""
	Default cIniEsoc	:= ""
	Default cVerSchema	:= ""
	Default cCampoOrd	:= ""
	Default lTAFKEY 	:= .T.
	Default lOrdena		:= .F.

	If paramVisao == 1 //Por Evento

		/*+-------------------------------------------------------------------------------------+
		| Quando a visão é por evento pego as informações diretamente do TAFRotinas 		    |
		| para melhorar a performance realizando a consulta somente no evento posicionado.      |
		+---------------------------------------------------------------------------------------+*/
		If !Empty((cAliasEvt)->XEVENTO)
			aEventoPos := TAFRotinas(AllTrim((cAliasEvt)->XEVENTO),4,.F.,2)
		Else
			// Se não encontrar nenhum evento, monta o arquivo de trabalho vazio com base no evento S-2200
			aEventoPos := TAFRotinas("S-2200",4,.F.,2)
		EndIf

		cAliasLay := aEventoPos[03] //Alias do Evento
		cLayout   := aEventoPos[04] //Layout
		cCmpTrab  := aEventoPos[11] //Campo relacionado ao Trabalhador
		cTipoEvt  := aEventoPos[12] //Tipo do Evento
		cCmpData  := aEventoPos[06] //Campo que determina o periodo ou data do evento
		cRelacTrb := aEventoPos[15] //Define se o evento tem relação com o Trabalhador

		cLayFilpar := TafMonPFil(cAliasLay,@oTabFilSel)

		If cRelacTrb != "S"

			If !Empty(cQry)
				cQry += " UNION ALL "
			EndIf

			If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
				cQry += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK "
			Else
				cQry += " SELECT DISTINCT  '  ' MARK"
			EndIf

			cQry += " ,C9V.R_E_C_N_O_ RECNO "
			cQry += " ,C9V_NOMEVE "
			cQry += " ,C9V_FILIAL "
			cQry += " ,C9V_NOME "
			cQry += " ,C9V_MATRIC "
			cQry += " ,C9V_CPF "
			cQry += " ,C9V_ID "
			cQry += " ,C9V_VERSAO "
			cQry += " ,C9V_CADINI "
			cQry += " ," + cAliasLay + "_STATUS "
			cQry += SelOwner(cAliasLay)
			cQry += " FROM " + RetSqlName("C9V") + " C9V "

			If cLayout == "S-2200"
				cQry += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
				cQry += " AND C9V_ID = CUP_ID "
				cQry += " AND C9V_VERSAO = CUP_VERSAO "
				cQry += " AND CUP.D_E_L_E_T_ = ' ' "
				cQry += TafMonPVinc(cIniEsoc,cVerSchema,cLayout)

			EndIf

			//Join com o Evento relacionado ao trabalhador
			If cAliasLay <> 'C9V'
				cQry += " INNER JOIN " + RetSqlName(cAliasLay) + " " + cAliasLay + " ON " + cAliasLay + "_FILIAL = C9V_FILIAL AND " + cCmpTrab+ " = C9V_ID  "

				If  cTipoEvt == EVENTOS_MENSAIS[2]

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
					
					cQry += " AND " + cAliasLay + "_PERAPU >= '" + AnoMes(paramDataInicial) + "'"
					cQry += " AND " + cAliasLay + "_PERAPU <= '" + AnoMes(paramDataFim) + "')"

					If !lLaySimplif

						cQry += " OR (" + cAliasLay + "_INDAPU = '2' "

					Else

						cQry += " OR ((" + cAliasLay + "_INDAPU = '2' "
						cQry += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

					EndIf

					cQry += " AND " + cAliasLay +  "_PERAPU BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')"
					cQry += ")"
				
				ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"

					cQry += " AND " 
					If cAliasLay == "V3C"
						cQry += "(("		
					EndIf
					cQry += cCmpData + " >= '" + DtoS(paramDataInicial) + "'"
					cQry += " AND " + cCmpData + " <= '" + DtoS(paramDataFim) + "'"

					If cAliasLay == "V3C"
						cQry += ") OR " + cCmpData + " = '' )"		
					EndIf
					
					cQry += GetOwner(cAliasLay,aParamES[16])

				EndIf

				If cAliasLay ==  "CM6"
					cQry += " AND (" + TafMonPAfast(cVerSchema)
					cQry += " AND CM6_FILIAL = C9V.C9V_FILIAL "
					cQry += " AND CM6_FUNC = C9V.C9V_ID	)"
				EndIf

				If TafColumnPos( cAliasLay + "_STASEC" )
					cQry += " AND (" + cAliasLay + "_ATIVO = '1' OR " +cAliasLay + "_STASEC = 'E' )"
				Else
					cQry += " AND " + cAliasLay + "_ATIVO = '1' "
				EndIf

				cQry += " AND " + cAliasLay + "_EVENTO <> 'E' "
				If cAliasLay == "C91"
					cQry += " AND C91_NOMEVE = '" + StrTran(cLayout,"-","") + "' "
				EndIf

				// Realiza trava para eventos S-1200 e S-1210 para apenas visualização de autônomos.
				If lLockAuton .And. cAliasLay $  "C91|T3P"
					cQry += " AND " + cAliasLay + "_TRABEV= 'TAUTO' "
				EndIf

				cQry += " AND "+ cAliasLay+ "_FILIAL IN ("
				cQry += cLayFilpar
				cQry += ") "

				cQry += " AND " + cAliasLay + ".D_E_L_E_T_ = ' ' "
				cQry += " AND " + cAliasLay + "_STATUS IN (" + cAuxSts + ") "
			EndIf

			//Verifica se foi inserido TAFKEy no Filtro
			If lTAFKEY
				cQry += "INNER JOIN TAFXERP TAFXERP "
				cQry += "   ON TAFXERP.TAFALIAS = '" + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + "' "
				cQry += "  AND TAFXERP.TAFRECNO = " + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + ".R_E_C_N_O_ "
				cQry += "  AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
				cQry += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
			EndIf

			cQry += " WHERE "
			cQry += " C9V.C9V_ATIVO = '1' "
			cQry += " AND C9V.C9V_EVENTO <> 'E' "
			cQry += " AND C9V.D_E_L_E_T_ = ' ' "

			If cLayout = "S-2300"
				cQry +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
			EndIf

			If cLayout == "S-2300" .Or. cLayout == "S-2200"
				cQry += " AND C9V.C9V_STATUS IN (" + cAuxSts + ") "
			EndIf

			If cAliasLay == "C9V"
				cQry += " AND C9V_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
			EndIf

			cQry += "   AND C9V.C9V_FILIAL IN ("
			cQry += cC9VFilpar
			cQry += ") " 

			// Condição para a query sempre vir vazia quando o browser superior estiver vazio
			If Empty( (cAliasEvt)->XEVENTO )
				cQry += " AND C9V_ID = '' "
			EndIf
			cQry += GetOwner(cAliasLay,aParamES[16])

		EndIf

	Else //Por Trabalhador
	

		If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
			cQry += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK "
		Else
			cQry += " SELECT DISTINCT  '  ' MARK"
		EndIf

		cQry += " ,C9V.R_E_C_N_O_ RECNO "
		cQry += " ,C9V_NOMEVE "
		cQry += " ,C9V_FILIAL "
		cQry += " ,C9V_NOME "
		cQry += " ,C9V_MATRIC "
		cQry += " ,C9V_CPF "
		cQry += " ,C9V_ID "
		cQry += " ,C9V_VERSAO "
		cQry += " ,C9V_CADINI "
		cQry += " ," + iif(!Empty(cAliasLay),cAliasLay,"C9V") + "_STATUS "
		cQry += SelOwner(cAliasLay)

		cQry += " FROM " + RetSqlName("C9V") + " C9V "

		cQry += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
		cQry += " AND C9V_ID = CUP_ID "
		cQry += " AND C9V_VERSAO = CUP_VERSAO "
		cQry += " AND CUP.D_E_L_E_T_ = ' ' "
		cQry += TafMonPVinc(cIniEsoc,cVerSchema,cLayout)

		//Verifica se foi inserido TAFKEy no Filtro
		If lTAFKEY
			cQry += "INNER JOIN TAFXERP TAFXERP "
			cQry += "   ON TAFXERP.TAFALIAS = '" + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + "' "
			cQry += "  AND TAFXERP.TAFRECNO = " + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + ".R_E_C_N_O_ "
			cQry += "  AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
			cQry += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
		EndIf

		cQry += " WHERE C9V.C9V_ATIVO = '1' "
		cQry += " AND C9V.C9V_EVENTO <> 'E' "
		cQry += " AND C9V.C9V_NOMEVE <> 'TAUTO' " 
		cQry += " AND C9V.D_E_L_E_T_ <> '*' "
		cQry += " AND C9V.C9V_STATUS IN (" + cAuxSts + ") "

		cQry += " AND C9V_NOMEVE = 'S2200'"

		cQry += "   AND C9V.C9V_FILIAL IN ("
		cQry += cC9VFilpar
		cQry += ") "

		cQry += " UNION ALL"

		If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
			cQry += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK "
		Else
			cQry += " SELECT DISTINCT  '  ' MARK"
		EndIf

		cQry += " ,C9V.R_E_C_N_O_ RECNO "
		cQry += " ,C9V_NOMEVE "
		cQry += " ,C9V_FILIAL "
		cQry += " ,C9V_NOME "
		cQry += " ,C9V_MATRIC "
		cQry += " ,C9V_CPF "
		cQry += " ,C9V_ID "
		cQry += " ,C9V_VERSAO "
		cQry += " ,C9V_CADINI "
		cQry += " ," + iif(!Empty(cAliasLay),cAliasLay,"C9V") + "_STATUS "
		cQry += SelOwner(cAliasLay)

		cQry += " FROM " + RetSqlName("C9V") + " C9V "

		//Verifica se foi inserido TAFKEy no Filtro
		If lTAFKEY
			cQry += "INNER JOIN TAFXERP TAFXERP "
			cQry += "   ON TAFXERP.TAFALIAS = '" + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + "' "
			cQry += "  AND TAFXERP.TAFRECNO = " + IIF(!Empty(cAliasLay),cAliasLay,"C9V") + ".R_E_C_N_O_ "
			cQry += "  AND TAFXERP.TAFKEY IN ( " + cTAFKEY + " ) "
			cQry += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
		EndIf

		cQry += " WHERE C9V.C9V_ATIVO = '1' "
		cQry += " AND C9V.C9V_EVENTO <> 'E' "
		cQry += " AND C9V.C9V_NOMEVE <> 'TAUTO' " 
		cQry += " AND C9V.D_E_L_E_T_ = ' ' "
		cQry += " AND C9V.C9V_STATUS IN (" + cAuxSts + ") "

		cQry += " AND C9V_NOMEVE = 'S2300'"
		cQry +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
		cQry += "   AND C9V.C9V_FILIAL IN ("
		cQry += cC9VFilpar
		cQry += ") "
	
	EndIf
		
		cQryRet := " SELECT MARK,RECNO,C9V_NOMEVE,CASE WHEN " + iif(!Empty(cAliasLay),cAliasLay,"C9V") + "_STATUS = '4' THEN 2 ELSE 1 END PENDENTE,C9V_FILIAL,C9V_NOME,C9V_MATRIC,C9V_CPF,C9V_ID,C9V_VERSAO,C9V_CADINI, TAFOWNER "
		cQryRet += " FROM ( " + cQry + " ) TAF "
		If !Empty(cCampoOrd)
			If lOrdena
				cQryRet += " ORDER BY " + cCampoOrd + " DESC "
			Else
				cQryRet += " ORDER BY " + cCampoOrd + " ASC "
			EndIf 
			lOrdena := !lOrdena
		EndIf 
	
Return Nil

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

Local cMsg := ""

Local nRegSelEvt	:= 0
Local nRegSelTrb	:= 0

If !Empty((cAliasTrb)->MARK)

	nRegSelTrb := TafMCountBrw(oMarkTrb)

	If nRegSelTrb <= 25

		nRegSelEvt := TafMCountBrw(oMarkEvt)

		If nRegSelEvt > 0
			MsgAlert(STR0259) //"Retirar a Seleção do Browse Eventos para realizar a marcação do Browse Trabalhador"
			//Retiro a Marcação do Item por que o mesmo já recebeu a marca do sistema.
			If RecLock(cAliasTrb,.F.)
				(cAliasTrb)->MARK := "  "
				(cAliasTrb)->(MsUnlock())
			EndIf
		EndIf
	Else
		cMsg := "A Marcação de Trabalhadores está limitado a 25 registros. "
		cMsg += "Para marcação de todos os trabalhadores utilize a visão por "
		cMsg += "eventos localizada na tela de filtros, para acessa-la utilize o botão "
		cMsg += "parâmetros de filtro localizado no canto superior direito desta interface."
		cMsg += CRLF + CRLF
		cMsg += "Esta restrição é imposta para otimização do monitor de detalhamento. "
		Aviso("Seleção de Eventos" , cMsg , {"OK"} , 3 )
	EndIf

EndIf

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll

Inverte a indicação de seleção de todos registros do Browse.
@param		oBrowse - Objeto contendo campo de seleção
@Return	Nil
@Author	Evandro dos Santos
@Since		10/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMarkAll( )

	Local cMsg := ""

	If paramVisao == 1

		cMsg := "Para Selecionar todos os Trabalhadores utilize Browse de Eventos."
		cMsg += CRLF + CRLF
		cMsg += "Ao Selecionar 1 ou mais eventos serão considerados todos os trabalhadores relativos aos mesmos."

	else

		cMsg := "Para realizar a marcação de todos os Eventos e Funcionários utilize a visão "
		cMsg += "por eventos localizada na tela de filtros, para acessa-la utilize o botão "
		cMsg += "parâmetros de filtro localizado no canto superior direito desta interface."
		cMsg += CRLF + CRLF
		cMsg += "Esta restrição é imposta para otimização do monitor de detalhamento. "

	EndIf

	Aviso("Seleção de Eventos" , cMsg , {"OK"} , 3 )

Return()



//---------------------------------------------------------------------
/*/{Protheus.doc} FopenPnTrab

Função genérica para abertura do painel de trabalhador
@param		nRecnoPn    - Recno de abertura do cadastro
@param 		cFilPn      - Filial para abertura do painel
@param 		aChecks 	-
@param 		cEvePn 		- Evento
@param		oTabFilSel	- Recebido como referencia, guarda as filiais selecionadas por tabelas de evento

@Return	Nil
@Author	Evandro dos Santos
@Since		10/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FopenPnTrab( nRecnoPn, cFilPn, aChecks, cEvePn, oTabFilSel )

	Default nRecnoPn	:= 0
	Default cFilPn	:= ""
	Default aChecks	:= {}
	Default cEvePn	:= ""

	//Verifico se o usuário corrente tem acesso a rotina
	If FPerAcess(,Alltrim(cEvePn))

		If !('AUTO' $ cEvePn)
			FeSocCallV('TAFAPNFUNC',nRecnoPn,4,,cFilPn )

			If Len( aChecks ) > 0
				TafMonEPer(,.T.,aChecks,,,,@oTabFilSel)
				TafMonETrb(,.T.,aChecks)
			EndIf
		Else
			MsgAlert( STR0190 ) //"Para trabalhador cuja categoria não está sujeita ao evento de admissão ou ao evento de início de 'Trabalhador Sem Vínculo' não é possível abrir o painel do trabalhador pois não podem existir eventos vinculados a ele."
		Endif

	EndIf

Return Nil

Static Function FGrvPendente(cStatus,cIniEsoc,cVerSchema)

	Local nI			:= 0
	Local nX			:= 0
	Local nEventos		:= 0
	Local nStusPend		:= 2 //1 - Com Pendecia/ 2 - Sem Pendencia
	Local cAliasLay		:= ""
	Local cTipoEvt		:= ""
	Local cLayout		:= ""
	Local cCmpData		:= ""
	Local cCmpTrab		:= ""
	Local cRelacTrb		:= ""
	Local cIndApu		:= ""

	Default cStatus		:= ""
	Default cIniEsoc	:= ""


	(cAliasTrb)->(dbGoTop())

	While (cAliasTrb)->(!Eof())

		For nI := 1 To Len(aEventosParm)

			nEventos := Len(aEventosParm[nI][1])

			If nEventos > 0 .And. aEventosParm[nI][2] .And. aEventosParm[nI][3] $ EVENTOS_MENSAIS[2] + EVENTOS_EVENTUAIS[2]
				For nX := 1 To nEventos

					cAliasLay := aEventosParm[nI][1][nX][1]  //Alias do Evento
					cLayout   := aEventosParm[nI][1][nX][2]  //Layout
					cCmpTrab  := aEventosParm[nI][1][nX][6]  //Campo relacionado ao Trabalhador
					cTipoEvt  := aEventosParm[nI][1][nX][8]  //Tipo do Evento
					cCmpData  := aEventosParm[nI][1][nX][7]  //Campo que determina o periodo ou data do evento
					cRelacTrb := aEventosParm[nI][1][nX][11] //Define se o evento tem relação com o Trabalhador

					If cRelacTrb != "S"

						cQry := " SELECT COUNT(*) QTDPEND "
						cQry += " FROM " + RetSqlName(cAliasLay)

						If paramVisao == 1

							If AllTrim((cAliasTrb)->C9V_NOMEVE) == "S2200"

								cQry += " INNER JOIN " + RetSqlName("CUP") + " CUP ON '" + (cAliasTrb)->C9V_FILIAL + "' = CUP_FILIAL "
								cQry += " AND '" + (cAliasTrb)->C9V_ID + "' = CUP_ID "
								cQry += " AND '" + (cAliasTrb)->C9V_VERSAO + "' = CUP_VERSAO "
								cQry += " AND CUP.D_E_L_E_T_ = ' ' "
								cQry += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,,,cTipoEvt)
							EndIf

						EndIf

						cQry += " WHERE "
						cQry += " ( " + cAliasLay + "_STATUS IN (" + cStatus + ") "
						cQry += " AND " + cAliasLay + "_STATUS <> '" + AllTrim(Str(STATUS_TRANSMITIDO_OK[1])) + "'"
						cQry += " AND " + cAliasLay + "_STATUS <> '" + AllTrim(Str(STATUS_EXCLUSAO_OK[1])) + "')"

						If cTipoEvt == EVENTOS_MENSAIS[2] .Or. cAliasLay $ "CMJ"
							
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

							cQry += " AND " + cCmpData + " >= '" + AnoMes(paramDataInicial) + "'"
							cQry += " AND " + cCmpData + " <= '" + AnoMes(paramDataFim) + "')"

							If !lLaySimplif

								cQry += " OR (" + cAliasLay + "_INDAPU = '2' "

							Else

								cQry += " OR ((" + cAliasLay + "_INDAPU = '2' "
								cQry += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

							EndIf

							cQry += " AND " + cCmpData +  " BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')"
							cQry += ")"
						ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"
							cQry += " AND " + cCmpData + " >= '" + DtoS(paramDataInicial) + "'"
							cQry += " AND " + cCmpData + " <= '" + DtoS(paramDataFim) + "'"
						EndIf

						If cAliasLay ==  "CM6"
							cQry += " AND ( "
							cQry += TafMonPAfast(cVerSchema)
							cQry += " ) "
						EndIf

						If cAliasLay $ "C9V|C91|"
							cQry += " AND " + cAliasLay + "_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
						EndIf

						// Realiza trava para eventos S-1200 e S-1210 para apenas visualização de autônomos.
						If lLockAuton .And. cAliasLay $  "C91|T3P"
							cQry += " AND " + cAliasLay + "_TRABEV= 'TAUTO' "
						EndIf

						If cLayout = "S-2300"
							cQry +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
						EndIf

						cQry += " AND " + cCmpTrab + " =  '" + (cAliasTrb)->C9V_ID + "'"
						cQry += " AND " +  RetSqlName(cAliasLay) + ".D_E_L_E_T_ = ' ' "
						cQry += " AND "+ cAliasLay+ "_FILIAL = '" + (cAliasTrb)->C9V_FILIAL  + "'"

						TCQuery cQry New Alias "AliasPend"

						//MemoWrite("D:\memowrite\" + cLayout + "_pend_trab_" + (cAliasTrb)->C9V_ID + ".txt", cQry )

					EndIf
				Next nX
			EndIf
			nStusPend := 2
		Next nI

		(cAliasTrb)->(dbSkip())
	EndDo

	(cAliasTrb)->(dbGoTop())

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SelOwner

Função genérica para abertura do painel de trabalhador
@param		cTable    	- Tabela em uso
@param		cParam    	- par?metro escolhido pelo usu?rio

@Return		cRet		- formato utilizado no where
@Author		Totvs
@Since		30/12/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function GetOwner(cTable,cParam)
Local cRet		:= ' '
Local cPar		:= AllTrim(cParam)
Local cCampo	:= cTable + '_OWNER'

	If TafColumnPos(cCampo)
		If cPar == 'OUTROS'
			cRet += " AND " 
			cRet += + "( " + cCampo + " <> 'RM' "
			cRet += " AND " + cCampo + " <> 'PROTHEUS' "
			cRet += " AND " + cCampo + " <> 'GPE' "
			cRet += " AND " + cCampo + " <> 'DATASUL' ) "
		ElseIf cPar == 'TODOS'
			cRet += " AND " + cCampo + " LIKE '%%' "
		ElseIf cPar == 'PROTHEUS'
			cRet += " AND " + cCampo + " LIKE '%GPE%' "
		Else
			cRet += " AND " + cCampo + " LIKE '%" + cPar + "%' "
		EndIf
	
	EndIf
Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SelOwner

Função genérica para abertura do painel de trabalhador
@param		cTable    	- Tabela em uso

@Return		cRet		- formato utilizado no select
@Author		Totvs
@Since		30/12/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function SelOwner(cTable)
Local cRet		:= ' '
Local cCampo	:= cTable + '_OWNER'
Local cBancoDB	:= AllTrim(TCGetDB())

If TafColumnPos(cCampo)
	cRet := ", " + cCampo + " TAFOWNER"
Else
	If cBancoDB == "ORACLE" 
		cRet += ", CAST('" + Space(40) + "' AS CHAR(40)) TAFOWNER "
	ElseIf cBancoDB == "POSTGRES"
		cRet += ", CAST('" + Space(40) + "' AS VARCHAR) TAFOWNER "
	Else
		cRet := ", '" + Space(40) + "' TAFOWNER "
	EndIf
EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} getNomeTrab

Faz a chamada da funcao monGetTrbName responsavel por verificar se 
o funcionario teve alteração de nome

@param		cBanco    	- Nome do Banco de dados em uso 

@Return		cNome		- Nome Atual do Funcionario
@Author		Totvs
@Since		12/08/2020
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function getNomeTrab(cBanco)

	Local cNome := ""

	cNome := monGetTrbName(cBanco,(cAliasTrb)->C9V_FILIAL,(cAliasTrb)->C9V_CPF)

	If Empty(cNome)
		cNome := AllTrim((cAliasTrb)->C9V_NOME)
	EndIf 

Return cNome 
