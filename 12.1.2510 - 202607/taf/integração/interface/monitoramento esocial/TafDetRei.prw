#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "TAFMONTES.CH"

#DEFINE  CRLF 			Chr(13) + Chr(10)

/*/{Protheus.doc} TafDetRei
Tela para selecão dos tipos evento e parametros.

@author Leonardo Kichitaro
@since 12/03/2018
@version 1.0
@return ${Nil}
/*/
Function TafDetRei( nTipoMon, cIdEnt, cPeriodo)

Local oChk01		as object
Local oChk02		as object
Local oChk03		as object
Local oSDtIni		as object
Local oGDataIni		as object
Local oSDtFim		as object
Local oGDataFIm		as object
Local nTop			as numeric
Local nLeft			as numeric
Local nBottom		as numeric
Local nRight		as numeric
Local nLin			as numeric
Local nCol			as numeric
Local nTamCol		as numeric
Local nTipoEven		as numeric
Local oSize			as object
Local aItsSelc		as array
Local aRetEvts		as array
Local nX			as numeric
Local cMsgBtt		as char
Local cRadio1		as char
Local cRadio2		as char
Local nRadio		as numeric
Local lDetal		as logical
Local lOk			as logical
Local lVirgula		as logical
Local lChk01		as logical
Local lChk02		as logical
Local lChk03		as logical
Local lExit			as logical
Local cStatus		as char
Local cRecNos		as char
Local lEnd			as logical
Local aEvtsSel		as array
Local aIdsSel		as array
Local cMsgRet		as char
Local lMultEvt		as logical
Local cMsgErr		as char
Local cMsgTit		as char
Local cEvento		as char
Local cEveDsc		as char
Local aInfoTrab		as array
Local dPerFim		as Date

Private aParamRei	as array

oChk01		:= Nil
oChk02		:= Nil
oChk03		:= Nil
oSDtIni 	:= Nil
oGDataIni	:= Nil
oSDtFim		:= Nil
oGDataFIm	:= Nil
nTop		:= 0
nLeft		:= 0
nBottom		:= 0
nRight		:= 0
nLin		:= 005
nCol		:= 0
nTamCol		:= 0
nTipoEven	:= 0
oSize		:= FwDefSize():New(.F.)
aItsSelc	:= {}
aParamRei	:= Array(1)
nX			:= 0
cMsgBtt		:= ""
cRadio1		:= ""
cRadio2		:= ""
nRadio		:= 1
lDetal		:= .F.
lOk			:= .F.
lVirgula	:= .F.
lChk01		:= .T.
lChk02		:= .F.
lChk03		:= .F.
lOKFx7		:= .t.
cStatus		:= ""
cRecNos		:= ""
lEnd		:= .T.
aEvtsSel	:= {}
aIdsSel		:= {}
aRetEvts	:= {}
cMsgRet		:= ""
lMultEvt	:= .F.
lExit		:= .F.
cMsgBtt		:= ""
cMsgErr		:= ""
cMsgTit		:= ""
cMsgPar		:= ""
cEvento		:= ""
cEveDsc		:= ""
aInfoTrab	:= {}
dPerFim		:= Date()

nTop    := 0		//oSize:aWindSize[1] - (oSize:aWindSize[1] * 0.73)
nLeft   := 1.5		//oSize:aWindSize[2] - (oSize:aWindSize[2] * 0.70)
nBottom := 197.34	//oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.67)
nRight  := 405.6	//oSize:aWindSize[4] - (oSize:aWindSize[4] * 0.70)

Define MsDialog oDlgT Title "Parâmetros Detalhamento" From nTop,nLeft To nBottom,nRight  Pixel 

oPanel := TPanel():New(00,00,"",oDlgT,,.F.,.F.,,,10,20,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS(QLABEL_AZUL_D)

cMsgTit := "Selecione o painel dos eventos para detalhamento:"

oSayTit := TSay():New(005,oPanel:NCLIENTWIDTH  * 0.02,{||cMsgTit},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.45,030,,,,,,.F.)

oChk01 := TCheckBox():New(020,020,"Tabelas",&("{|u|IIf (PCount()==0,lChk01,lChk01 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
oChk01:bChange := { || TafMonChk(1,@lChk01,@lChk02,@lChk03,oChk01,oChk02,oChk03,oDlgT)}

oChk02 := TCheckBox():New(020,060,"Periódicos",&("{|u|IIf (PCount()==0,lChk02,lChk02 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
oChk02:bChange := { || TafMonChk(2,@lChk01,@lChk02,@lChk03,oChk01,oChk02,oChk03,oDlgT)}

oChk03 := TCheckBox():New(020,100,"Não Periódicos",&("{|u|IIf (PCount()==0,lChk03,lChk03 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
oChk03:bChange := { || TafMonChk(3,@lChk01,@lChk02,@lChk03,oChk01,oChk02,oChk03,oDlgT)}

Activate MsDialog oDlgT ON INIT (EnchoiceBar(oDlgT,{||lOk :=.T.,oDlgT:End()},{||oDlgT:End()},,,,,.F.,.F.,.F.,.T.,.F.))

If lOk
	If lChk01
		cEvento		:= (cAliasTab)->CODEVEN
		cEveDsc		:= (cAliasTab)->XEVENTO
		nTipoEven	:= 1
	ElseIf lChk02
		cEvento		:= (cAliasEvp)->CODEVEN
		cEveDsc		:= (cAliasEvp)->XEVENTO
		nTipoEven	:= 2
	ElseIf lChk03
		cEvento		:= (cAliasEvn)->CODEVEN
		cEveDsc		:= (cAliasEvn)->XEVENTO
		nTipoEven	:= 3
	EndIf

	While .T.
		FWMsgRun(,{||lExit := TafReiEven(nTipoMon, cEvento, cEveDsc, nTipoEven, cPeriodo, dPerFim, cIdEnt)},"Carregando registros","Carregando registros para "+iif(nTipoMon, "Transmissão", "Monitoramento"))
		If !lExit
			Exit
		EndIf
	EndDo
EndIf

aParamRei[1] := cPeriodo

FSalvProf()
TafMonAtu(cPeriodo)

Return

/*/{Protheus.doc} TafReiEven
Tela para selecão dos eventos.

@author Leonardo Kichitaro
@since 12/03/2018
@version 1.0
@return ${Nil}
/*/
Static Function TafReiEven(nTipoMon, cEvento, cEveDsc, nTipoEven, cPerIni, dPerFim, cIdEnt)

Local oDlg1			as object
Local oSize			as object
Local oTmpTb		as object
Local cQuery		as character
Local cStatus		as character
Local cMsg			as character
Local nX			as numeric
Local nTotRegs		as numeric
Local nPenAnt		as numeric
Local nPenDep		as numeric
Local nAjust		as numeric
Local nPos			as numeric
Local nRetTSS		as numeric
Local aCampos		as array
Local aStruct		as array
Local aTAFXERP		as array
Local aHeaderT		as array
Local aIndex		as array
Local aSeek			as array
Local aFiltro		as array
Local lMaisD1		as logical
Local lConxTSS		as logical
Local lLoopTel		as logical
Local aFiliais 		as array

Local xStatus		as char

Private oMBrowse	as object
Private cAliasDet	as character
Private aRetorno	as array
Private aEvents		as array
Private lCloseTel	as logical

oSize		:=	FWDefSize():New( .F. )
cQuery		:=	""
cStatus		:=	""
cMsg		:=	""
xStatus		:= "'0','1','2','3','6','7'"
nX			:=	0
nTotRegs	:=	0
nPenAnt		:=	0
nPenDep		:=	0
nAjust		:=	0
nPos		:=	0
nRetTSS		:=	1
aCampos		:=	{}
aStruct		:=	{}
aTAFXERP	:=	{}
aHeaderT	:=	{}
aIndex		:=	{}
aSeek		:=	{}
aFiltro		:=	{}
aEvents		:=	{}
lMaisD1		:=	.F.
lConxTSS	:=	.F.
lLoopTel	:=	.F.

oMBrowse	:=	Nil
cAliasDet	:=	""
aRetorno	:=	{}

If TAFAlsInDic( "T0X" )
	DBSelectArea( "T0X" )
	T0X->( DBSetOrder( 3 ) )
EndIf

aEvents := TAFRotinas( cEvento ,4,.F.,5)

lConxTSS := TAFWVerUrl( , @cMsg )

If !lConxTSS
	cMsg := "Não foi possível conectar-se a um servidor TSS, a interface de detalhamento será criada, porém os registros com status de transmissão não terão suas descrições exibidas."
	cMsg += CRLF + CRLF + "Clique em Ok para continuar."

	nRetTSS := Aviso( "Divergência de Parâmetros", cMsg, { "Ok", "Cancelar" }, 3 )
EndIf

If nRetTSS == 1 .and. Len( aEvents ) > 0
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

	aAdd( aCampos, { "Status"				, "XSTATUS"		, 15														, "N"	, ""	, 1	, "",.T.,15 } )
	aAdd( aCampos, { "Filial"				, "FILIAL"		, GetSX3Cache( aEvents[3] + "_FILIAL", "X3_TAMANHO" )	, "C"	, ""	, 1	, "",.T.,04 } )
	aAdd( aCampos, { "ID do Registro"		, "ID"			, GetSX3Cache( aEvents[3] + "_ID", "X3_TAMANHO" )		, "C"	, ""	, 1	, "",.T.,05 } )

	aAdd( aCampos, { "Código"				, "CODIGO"		, 30, "C", "@!", 1, "",.T.,10} )
	aAdd( aCampos, { "Descrição"			, "DESCR"		, 100, "C", "@!", 1, "",.T.,50 } )

	If nTipoEven == 1
		aAdd( aCampos, { "Início Validade"	, "INIVALD"		, 7	, "C"	, GetSX3Cache( aEvents[3] + "_DTINI", "X3_PICTURE" )		, 0	, "",.T.,4 } )
		aAdd( aCampos, { "Fim Validade"		, "FINVALID"	, 7	, "C"	, GetSX3Cache( aEvents[3] + "_DTFIN", "X3_PICTURE" )		, 0	, "",.T.,4 } )
	Else
		aAdd( aCampos, { "Per. Apuração"	, "PERAPU"		, 6	, "C"	, GetSX3Cache( aEvents[3] + "_PERAPU", "X3_PICTURE" )	, 0	, "",.T.,4 } )
	EndIf

	aAdd( aCampos, { "Situação do Evento"	, "MENSG"		, 255	, "C", "", 1	, "CDETSTATUS"	,.T.,30 } )
//	aAdd( aCampos, { "Descrição da Receita"	, "RETGOV"		, 200	, "C", "", 1	, "CDSCRECEITA"	,.T.,30 } )
	aAdd( aCampos, { "Recibo"				, "RECIBO"		, GetSX3Cache( aEvents[3] + "_PROTUL", "X3_TAMANHO" )	, "C"	, "@!"	, 1	, "CRECIBO"		,.T.,52 } ) //"Recibo"
	aAdd( aCampos, { "Data"					, "DATALI"		, 10	, "C", "", 1	, ""			,.T.,07 } )
	
	aTAFXERP := xTAFGetStru( "TAFXERP" )[1]
	If ( nPos := aScan( aTAFXERP, { |x| AllTrim( x[1] ) == "TAFKEY" } ) ) > 0
		aAdd( aCampos, { "Chave de Integração", aTAFXERP[nPos,1], aTAFXERP[nPos,3], aTAFXERP[nPos,2], "", 1, "",.T.,30 } )
	EndIf

	aAdd( aCampos, { "Regra"	, "REGRA"		, 255														, "C"	, ""	, 1	, ""			,.T.,25 } ) //"Regra"
	aAdd( aCampos, { "Versão"	, "VERSAO"		, GetSX3Cache( aEvents[3] + "_VERSAO", "X3_TAMANHO" )	, "C"	, "@!"	, 1	, ""			,.T.,0 } ) //"Versão"
	aAdd( aCampos, { "RecNo"	, "RECNO"		, 6															, "N"	, ""	, 1	, ""			,.F.,6 } ) //"RecNo"
//	aAdd( aCampos, { ''			, "HISTPROC"	, 10														, "M"	, ""	, 1	, "CHISTPROC"	,.F.,0 } ) //"Historico Processo TSS"
	aAdd( aCampos, { ''			, "XMLRET"		, 10														, "M"	, ""	, 1	, "CXMLEVENTO"	,.F.,0 } ) //"XML Retorno do governo"
	aAdd( aCampos, { ''			, "XMLERRO"		, 10														, "M"	, ""	, 1	, "CXMLRETEVEN"	,.F.,0 } ) //"Inconsistências"
//	aAdd( aCampos, { ''			, "CODRECEITA"	, 3															, "C"	, ""	, 1	, "CCODRECEITA"	,.F.,0 } ) //"Codigo de Receita"
	aAdd( aCampos, { ''			, "STATUSTSS"	, 1															, "C"	, ""	, 1	, "CSTATUS"		,.F.,0 } ) //"Status TSS"
	aAdd( aCampos, { ''			, "EXTEMP"		, 1															, "C"	, ""	, 1	, ""			,.F.,0 } ) //"Evento Extemporâneo"

	If nTipoMon == 1
		aAdd(aStruct,{ "MARK"   	, "C",  002, 0})
	EndIf

	For nX := 1 to Len( aCampos )
		aAdd( aStruct, { aCampos[nX][2], aCampos[nX][4], aCampos[nX][3], 0 } )
		aAdd( aFiltro, { aCampos[nX][2], aCampos[nX][1], aCampos[nX][4], aCampos[nX][3], 0, aCampos[nX][5] } )
	Next nX

	aAdd( aSeek, { "Versão", { { "", "C", Len( aEvents[4] ), 0, "VERSAO", "@!", } } } )
	aAdd( aSeek, { "Id", { { "", "C", Len( aEvents[4] ), 0, "ID", "@!", } } } )
	aAdd( aSeek, { "Chave de Integração", { { "", aTAFXERP[nPos,2], aTAFXERP[nPos,3], aTAFXERP[nPos,4], aTAFXERP[nPos,1], "@!", } } } )

	If ValType( xStatus ) == "C"
		cStatus := xStatus
	ElseIf ValType( xStatus ) == "N"
		cStatus := Iif( xStatus == STATUS_NAO_PROCESSADO[1], "' '", AllTrim( Str( xStatus ) ) )
	EndIf

	cAliasDet := GetNextAlias()

	oTmpTb := FWTemporaryTable():New(cAliasDet, aStruct)

	aAdd( aIndex, {"VERSAO"} )
	aAdd( aIndex, {"ID", "VERSAO"} )
	aAdd( aIndex, {aTAFXERP[nPos,1]} )

	For nX := 1 to Len( aIndex )
		oTmpTb:AddIndex(AllTrim(Str(nX)), aIndex[nX])
	Next nX

	oTmpTb:Create()

	BuildTemp( cStatus, aEvents, , , aCampos, @nTotRegs, lConxTSS, @nPenAnt, @nPenDep, cPerIni, dPerFim, nTipoMon, , , cIdEnt)

	(cAliasDet)->(DbGoTop())

	aFiliais := FWLoadSM0()

	/*+--------------------------+
	| Cria colunas para o Browse |
	+----------------------------+*/
	For nX := 1 to Len( aCampos )
		If aCampos[nX][8]
			aAdd( aHeaderT, FWBrwColumn():New() )

			If aCampos[nX][2] == "XSTATUS"
				aHeaderT[nX]:SetData( &( "{ || nPos := aScan( aStatus, { |x| x[1] == ( cAliasDet )->" + aCampos[nX][2] + " } ), Iif( nPos > 0, AllTrim( Str( aStatus[nPos][1] ) ) + '-' + aStatus[nPos][2], '' ) } " ) )
			ElseIf aCampos[nX][2] == "DESCR"
				aHeaderT[nX]:SetData( &( "{ || TafMDetDescr(.F.,cEvento,aFiliais) }" ) )
			Else
				aHeaderT[nX]:SetData( &( "{ || (cAliasDet)->" + aCampos[nX][2] + " }" ) )
			EndIf

			aHeaderT[nX]:SetTitle( aCampos[nX][1] )
			aHeaderT[nX]:SetSize( aCampos[nX][9] )
			aHeaderT[nX]:SetType( aCampos[nX][4] )
			aHeaderT[nX]:SetDecimal( 0 )
			aHeaderT[nX]:SetPicture( aCampos[nX][5] )
			aHeaderT[nX]:SetAlign( aCampos[nX][6] )
		EndIf
	Next nX

	/*+----------------------------------------+
	| Cria interface utilizando o objeto Layer |
	+------------------------------------------+*/
	Define MSDialog oDlg1 Title "Detalhamento - Reinf" From oSize:aWindSize[1], oSize:aWindSize[2] to oSize:aWindSize[3], oSize:aWindSize[4] Pixel //"Monitor eSocial - Detalhamento"

	oLayer := FWLayer():New()
	oLayer:Init( oDlg1, .F. )

	oLayer:AddLine( "LINE01", 090 )
	oLayer:AddLine( "LINE02", 010 )
	//oLayer:AddLine( "LINE04", 005 )

//	oCabec := oLayer:GetLinePanel( "LINE01" )
	oEventos := oLayer:GetLinePanel( "LINE01" )
	oRodape := oLayer:GetLinePanel( "LINE02" )
	//oSair := oLayer:GetLinePanel( "LINE04" )

	oPanRod := Nil
	FPanStus( @oPanRod, oRodape, 2, nTotRegs )


	cDescr := cEveDsc

	If nTipoMon == 1
		oMBrowse := FWMarkBrowse():New()
		oMBrowse:SetAlias(cAliasDet)
		oMBrowse:oBrowse:SetFieldFilter(aFiltro)
		oMBrowse:SetColumns(aHeaderT)
		oMBrowse:SetFieldMark("MARK")
		//oMBrwTabs:SetValid( {|| FPerAcess(cAliasTrb,Substr((cAliasTab)->XEVENTO,1,6),@cMsg,@nMark)} ) //Valida a permissão de acesso
		oMBrowse:SetDescription(cDescr)
		oMBrowse:DisableDetails()
		oMBrowse:SetUseFilter( .T. )
		oMBrowse:oBrowse:SetDBFFilter()
		oMBrowse:SetSeek(.T.,aSeek)
		oMBrowse:SetAllMark({||FMarkAll(oMBrowse)})
		oMBrowse:AddButton("Transmitir",{||iif(FVerChks(aEvents,@lLoopTel,cIdEnt,cPerIni),oDlg1:End(),oDlg1:Refresh()) })
		oMBrowse:AddButton("Visualizar",{ || FWMsgRun( , { || FeSocCallV(cEvento, ( cAliasDet )->RECNO, 1 , Nil, Nil, 5) }, "Manutenção dos Itens", "Carregando Cadastro do Evento" ) })
		
		oMBrowse:Activate(oEventos)
		cAliasDet := oMBrowse:Alias()
		//Força o posicionamento do primeiro registro
		oMBrowse:GoTo(1)
		oMBrowse:Refresh()
	Else
		oMBrowse := FWMBrowse():New()
		oMBrowse:SetAlias( cAliasDet )
		oMBrowse:SetColumns( aHeaderT )
		oMBrowse:SetDescription( cDescr )

		oMBrowse:DisableDetails()
		oMBrowse:SetUseFilter( .T. )
		oMBrowse:SetDBFFilter()
		oMBrowse:SetFieldFilter( aFiltro )
		oMBrowse:SetSeek( .T., aSeek )

		//oMBrowse:SetDoubleClick( { || FWMsgRun( , { || FeSocCallV(cEvento, ( cAliasDet )->RECNO, Iif( ( cAliasDet )->XSTATUS == STATUS_INCONSISTENTE[1] .or. ( cAliasDet )->XSTATUS == STATUS_INVALIDO[1], 4, 1 ), Nil, Nil, 5) }, "Manutenção dos Itens", "Carregando Cadastro do Evento" ) } ) //##"Manutenção dos Itens" ##"Carregando Cadastro do Evento"
		oMBrowse:SetDoubleClick( { || FWMsgRun( , { || FeSocCallV(cEvento, ( cAliasDet )->RECNO, 1 , Nil, Nil, 5) }, "Manutenção dos Itens", "Carregando Cadastro do Evento" ) } ) //##"Manutenção dos Itens" ##"Carregando Cadastro do Evento"
		oMBrowse:AddButton("Inconsistências",{||mostraXMLErro(cEvento) })	//"Inconsistências no Governo"
		oMBrowse:AddButton("Refresh",{||oMBrowse:Refresh() })	//"Inconsistências no Governo"		

		oMBrowse:Activate( oEventos )
		oMBrowse:GoTo(1)
		oMBrowse:Refresh()
	EndIf

	Activate MSDialog oDlg1 Centered

	( cAliasDet )->( DBCloseArea() )
	oTmpTb:Delete()
EndIf

Return lLoopTel

//---------------------------------------------------------------------
/*/{Protheus.doc} FVerChks
Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção
@Return	Nil
@Author	Evandro dos Santos 
@Since		10/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FVerChks(aEvents, lLoopTel, cIdEnt,cPerIni)

Local aRegSel		as array
Local aRetEvts		as array
Local nLinBrw		as numeric
Local nRecTmp		as numeric
Local cMsgRet		as char
Local lRetorno		as logical
Local lConexTSS		as logical

Default cPerIni		:= ""

aRegSel		:=	{}
aRetEvts	:=	{}
cMsgRet 	:=	""
lRetorno	:=	.F.
lConexTSS	:=	.F.
nLinBrw 	:=	oMBrowse:oBrowse:nAt
nRecTmp 	:=	(cAliasDet)->(Recno())

dbSelectArea(cAliasDet)
(cAliasDet)->(dbGoTop())
While (cAliasDet)->(!Eof())
	If !Empty((cAliasDet)->MARK)
		aAdd(aRegSel,(cAliasDet)->RECNO)
	EndIf
	(cAliasDet)->(dbSkip())
EndDo
oMBrowse:GoTo(nLinBrw)
(cAliasDet)->(dbGoTo(nRecTmp))

If Len(aRegSel) > 0

	If FindFunction("TafSet2099") .And. aEvents[04]=="R-2099"
		cPeriodo := StrTran(cPerIni,"-","")
		FWMsgRun(,{|| TafSet2099( cPeriodo ) },"Geração de XMLs","Gerando os Xmls Selecionados")
	EndIf
	
	FWMsgRun(,{||aRetEvts := TAFProc9Tss(.F., aEvents, Nil, Nil, Nil, Nil, Nil, @cMsgRet, Nil, Nil, Nil, Nil, Nil, aRegSel, @lConexTSS)},"Geração de XMLs","Gerando os Xmls Selecionados")
	TAFMErrT0X(aRetEvts)

	Aviso("Transmissão REINF",cMsgRet,{"Ok"},2)

	lRetorno := lConexTSS
Else
	Aviso("Transmissão REINF","Nenhum registro selecionado para transmissão",{"Ok"},2)

	lRetorno := .F.	
EndIf

lLoopTel := lRetorno

Return lRetorno

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

Local cAlias	as char
Local cMark	as char
Local nRecno	as numeric

Private lMarkAll as logical

Default oMBrwTabs	:=	Nil

cAlias		:=	oMBrwTabs:Alias()
cMark		:=	oMBrwTabs:Mark()
nRecno		:=	( cAlias )->( Recno() )

lMarkAll	:= .T.

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
@param cIDBrowse, char, (Identificador do Browse que está "chamando" a função"
@return ${Nil}
/*/
Static Function FPanStus(oPanel, oOwner, nTitulo, nTotRegs, nPenAnt, nPenDep, nAjust, lMaisD1, cStatus, aEvents, lMultTp, aCampos, lConxTSS, aIDsSel,cIDBrowse)

Local nLin    	  as numeric
Local cMsgHelp	  as character
Local oBtSair 	  as object
Local oBJob3   	  as object
Local cMsgAmb  	  as character
Local cAmbEsocial as character
Local cNmAmb	  as character

Default nTotRegs	:= 0
Default nPenAnt		:= 0

nLin     	:= 010
cMsgHelp 	:= ""
cMsgAmb	 	:= ""
cAmbEsocial := GetNewPar( "MV_TAFAMBR", "2" )
cNmAmb		:= ""
oBtSair  	:= Nil
oBJob3   	:= Nil

//Verifica qual tipo de ambiente foi configurado 
//pela wizard de configuração do esocial
If cAmbEsocial == "1"
	cNmAmb := "Produção"
ElseIf cAmbEsocial == "2"
	cNmAmb := "Pré-produção - dados reais"
Else
	cNmAmb := "Pré-produção - dados fictícios"
EndIf

oPanel:= TPanel():New(00,00,"",oOwner,,.F.,.F.,,,0,0,.T.,.F.) 
oPanel:Align = CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS(QLABEL_AZUL_A)

cMsgAmb := "<font size='2' color='RED'>"
cMsgAmb +=  "Ambiente do Reinf configurado para transmissão de Evento" + "<b>" + cNmAmb +"</b>" //Ambiente do Reinf configurado para transmissão de Eventos
cMsgAmb += "</font>"
oSayAmb := TSay():New(002,005,{||cMsgAmb},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

nLin+= (oPanel:NCLIENTHEIGHT * 0.112)
oSayTR := TSay():New(nLin,005,{||'<font size="3">' + "Total de Registros:" + '<b>' + AllTrim(Str(nTotRegs)) + '</b>'},oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Total de Registros:	


//oSayPenC := TSay():New(nLin,oPanel:NCLIENTWIDTH * 0.20,{||'<font size="3">' + "Pendentes:" +' <b>' + AllTrim(Str(nPenAnt)) + '</b>' },oPanel,,,,,,.T.,,,100,030,,,,,,.T.) //Pendentes:

nLin += (oPanel:NCLIENTHEIGHT * 0.11)

cMsgHelp := FONT_HELP_1
cMsgHelp += "Só serão trnasmitidos os registros selecionados. "  //São considerados pendentes os registros cujo o status é igual a#INVÁLIDO#INCONSISTENTE
//oSHelp	:= TSay():New(nLin,005,{||cMsgHelp},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.49,030,,,,,,.T.) 	
  	
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

@Author		Felipe C. Seolin
@Since		14/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function BuildTemp( cStatus, aEvents, aIDsTrb, cIDBrowse, aCampos, nTotRegs, lConxTSS, nPenAnt, nPenDep, cPerIni, dPerFim, nTipoMon, lUpdate, cIdEnt )

Local cQuery	 as character
Local cAuxDesc	 as character
Local cBanco	 as character
Local cTAFKEY	 as character
Local cAuxFil	 as character
Local cAuxTrab	 as character
Local cAliasLay  as character
Local cLayout    as character
Local cDescEvt   as character
Local cNomeFunc  as character
Local cTagEvt    as character
Local cIdTrab    as character
Local cCmpData   as character
Local cTipoEvt   as character
Local cCmpDescr  as character
Local cRelacTrb  as character
Local cIniEsoc	 as character
Local cVerSchema as character
Local cPerFin 	 as character
Local nX		 as numeric
Local nY		 as numeric
Local nZ		 as numeric
Local nRange	 as numeric
Local nVolume	 as numeric
Local nI		 as numeric
Local aTAFKEY	 as array
Local lTAFKEY	 as logical
Local lVirgula	 as logical
Local lEvtMarcado as logical

Default aIDsTrb	:=	{}
Default lUpdate	:=	.F.
Default cIDBrowse := ""

cQuery		:=	""
cAuxDesc	:=	""
cBanco		:=	AllTrim( TCGetDB() )
cTAFKEY		:=	""
cAuxFil		:=	""
cAuxTrab	:=	""
cAliasLay   :=  ""
cLayout     :=  ""
cDescEvt    :=  ""
cNomeFunc   :=  ""
cTagEvt     :=  ""
cIdTrab     :=  ""
cCmpData    :=  ""
cTipoEvt    :=  ""
cCmpDescr   :=  ""
cRelacTrb   :=  ""
cPerFin		:= SubStr(Dtoc(dPerFim),4,2)+SubStr(Dtoc(dPerFim),7,4)
cIniEsoc	:= SuperGetMv('MV_TAFINIE',.F.," ")
cVerSchema	:= SuperGetMv('MV_TAFVLRE',.F.,"1_03_00")
nX			:=	0
nY			:=	0
nZ			:=	0
nI 			:=  0
nRange		:=	5
nVolume		:=	1
aTAFKEY		:=	{}
lTAFKEY		:=	.F.
lVirgula	:=	.F.

//Zerar contadores a cada vez que executar a construção do temporário
nTotRegs := 0
nPenDep := 0

lEvtMarcado	:= .T.

If lEvtMarcado
	cAliasLay := aEvents[3] //Alias do Evento
	cLayout   := aEvents[4] //Layout

	cQuery += "SELECT DISTINCT '" + cLayout + "' EVENTO "
	cQuery += " ," + cAliasLay + "." + cAliasLay + "_FILIAL FILIAL "
	cQuery += " ," + cAliasLay + "." + cAliasLay + "_STATUS XSTATUS "
	cQuery += " ,TAFKEY TAFKEY "
	cQuery += " ," + cAliasLay + "." + cAliasLay + "_ID ID "

	If AllTrim( cLayout ) $ "R-1000"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NRINSC CODIGO "
	ElseIf AllTrim( cLayout ) $ "R-1070"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NUMPRO CODIGO "
	ElseIf AllTrim( cLayout ) $ "R-2020"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_IDESTA CODIGO "
	ElseIf AllTrim( cLayout ) $ "R-2010|R-2030|R-2060|R-2040|R-2050"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_TPINSC CODIGO "
	ElseIf AllTrim( cLayout ) $ "R-9000"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NRRECI CODIGO "
	Else
		cQuery += " ,' ' CODIGO "
	EndIf
/*
	If cTipoEvt == EVENTOS_INICIAIS[2]
		cAuxDesc := getDescrTabs(cLayout) 
	ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2]
		cAuxDesc := getDescrPeriodicos(cLayout)
	ElseIf cTipoEvt == EVENTOS_MENSAIS[2]
		cAuxDesc := getDescrNaoPeriodicos(cLayout)
	Else
		cAuxDesc := "' '"
	EndIf
*/

	If AllTrim( cLayout ) $ "R-1000"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NOMCTT DESCR "
	ElseIf AllTrim( cLayout ) $ "R-1070"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_DSUFVA DESCR "
	ElseIf AllTrim( cLayout ) $ "R-2020"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_DESTAB DESCR "
	ElseIf AllTrim( cLayout ) $ "R-2010|R-2030|R-2060|R-2040|R-2050"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NRINSC DESCR "
	ElseIf AllTrim( cLayout ) $ "R-9000"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_NRRECI DESCR "
	Else
		cQuery += " ,' ' DESCR "
	EndIf

	If AllTrim( cLayout ) $ "R-1000|R-1070"
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_DTINI INIVALD "
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_DTFIN FINVALID "
	Else
		cQuery += " ,' ' INIVALD " 
		cQuery += " ,' ' FINVALID "
	EndIf

	If AllTrim( cLayout ) $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2070|R-2098|R-2099"
		If AllTrim( cLayout ) == "R-2020"
			cQuery += " ," + cAliasLay + "." + cAliasLay + "_INDAPU INDAPU "
		Else
			cQuery += " , ' ' INDAPU "
		EndIF
		cQuery += " ," + cAliasLay + "." + cAliasLay + "_PERAPU PERAPU "
	Else
		cQuery += " , ' ' INDAPU "
		cQuery += " ,' ' PERAPU "
	EndIf
	
	cQuery += " ,' ' MENSG "
	cQuery += " ,' ' XMLERRO "
	cQuery += " ,' ' DATALI "
	cQuery += " ,' ' REGRA "
	cQuery += " ," + cAliasLay + "." + cAliasLay + "_PROTUL RECIBO "
	cQuery += " ," + cAliasLay + "." + cAliasLay + "_VERSAO VERSAO "
	cQuery += " ," + cAliasLay + ".R_E_C_N_O_ RECNO "
	cQuery += " ,'" + cNomeFunc + "' FUNCAO "
	cQuery += " ,'" + cAliasLay + "' ALIAS "
	cQuery += " ,'" + cLayout + "' LAYOUT "
	cQuery += " ,'" + cTagEvt + "' CREGNODE "
	cQuery += " ,'" + cAliasLay + "' TABELA "

	If TafColumnPos( cAliasLay + "_STASEC" )
		cQuery += " ," + cAliasLay + "_STASEC EXTEMP "
	Else
		cQuery += " , ' ' EXTEMP "
	EndIf

	cQuery += "FROM " + RetSqlName( cAliasLay ) + " " + cAliasLay + " "
	
	//Tratamento específico para ORACLE que não aceita LEFT JOIN com uma tabela onde o
	//on utiliza uma SubQuery
	If cBanco == "ORACLE" .Or. cBanco == "OPENEDGE" 
		
		cQuery += "LEFT JOIN "
		cQuery += " ( "
		cQuery += "    SELECT C.TAFKEY, C.TAFALIAS, C.TAFRECNO FROM TAFXERP C WHERE C.D_E_L_E_T_ <> '*' 
		cQuery += "    AND C.R_E_C_N_O_ = "
		cQuery += "        ( "
		cQuery += "			 SELECT MAX( B.R_E_C_N_O_ ) RECNO "
		cQuery += "          FROM TAFXERP B "
		cQuery += "			 WHERE B.TAFALIAS = C.TAFALIAS "
		cQuery += "          AND B.TAFRECNO = C.TAFRECNO "
		cQuery += "          AND B.D_E_L_E_T_ = '' "						
		cQuery += "        ) "
		cQuery += "  ) TAFXERP
		cQuery += " ON TAFXERP.TAFALIAS = '" + cAliasLay +  "' "
		cQuery += " AND TAFXERP.TAFRECNO = " + cAliasLay + ".R_E_C_N_O_ "

	Else
		If cBanco == "DB2"

			cQuery += "LEFT JOIN ( "
			cQuery += "SELECT * "
			cQuery += "  FROM TAFXERP SUBTAFX "
			cQuery += " WHERE SUBTAFX.D_E_L_E_T_ = '' "
			cQuery += "ORDER BY SUBTAFX.R_E_C_N_O_ DESC "
			cQuery += " FETCH FIRST 1 ROWS ONLY ) TAFXERP "
			cQuery += "  ON TAFXERP.TAFALIAS = '" + cAliasLay +  "' "
			cQuery += " AND TAFXERP.TAFRECNO = " + cAliasLay + ".R_E_C_N_O_ "

		Else

			cQuery += "LEFT JOIN TAFXERP TAFXERP "
			cQuery += "  ON TAFXERP.TAFALIAS = '" + cAliasLay +  "' "
			cQuery += " AND TAFXERP.TAFRECNO = " + cAliasLay + ".R_E_C_N_O_ "
			cQuery += " AND TAFXERP.TAFKEY = ( "
		
			If !( cBanco $ ( "INFORMIX|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
				cQuery += "SELECT TOP 1 B.TAFKEY TAFKEY "
			Else
				cQuery += "SELECT B.TAFKEY TAFKEY "
			EndIf

			cQuery += "FROM TAFXERP B "
			cQuery += "WHERE B.TAFALIAS = TAFXERP.TAFALIAS "
			cQuery += "  AND B.TAFRECNO = TAFXERP.TAFRECNO "
			cQuery += "  AND B.D_E_L_E_T_ = '' "
	
			cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "

			If cBanco == "DB2"
				cQuery += "ORDER BY B.R_E_C_N_O_ DESC "
				cQuery += "FETCH FIRST 1 ROWS ONLY "
			ElseIf cBanco $ "POSTGRES|MYSQL"
				cQuery += "ORDER BY B.R_E_C_N_O_ DESC LIMIT 1 "
			ElseIf cBanco <> "INFORMIX"
				cQuery += "ORDER BY B.R_E_C_N_O_ DESC "
			EndIf

			cQuery += " ) "
		EndIf
	Endif

	If nTipoMon == 1
		cQuery += "WHERE " + cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + "' AND " + cAliasLay + "." + cAliasLay + "_STATUS IN (' ','0','1','3','7') "
	Else
		cQuery += "WHERE " + cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + "' AND " + cAliasLay + "." + cAliasLay + "_STATUS IN ('2','4','3','6','7') "
	EndIf
	cQuery += "  AND " + cAliasLay + ".D_E_L_E_T_ <> '*' " 

	cQuery += "  AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "

	If AllTrim( cLayout ) $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2070|R-2098|R-2099"
		cQuery += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU = '" + STRTRAN(cPerIni,"/","") + "'"
//		cQuery += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU <= '" + cPerFin + "'"
	ElseIf AllTrim( cLayout ) == "R-1000"
		cQuery += " AND " + cAliasLay + "." + cAliasLay + "_NRINSC = '" + SM0->M0_CGC +"' "
	EndIf
EndIf
  
If !Empty( cQuery )
	cQuery := ChangeQuery( cQuery )
	FillTemp( cQuery, aCampos, @nTotRegs, @nPenAnt, @nPenDep, lConxTSS, cStatus, aIDsTrb, lUpdate, nTipoMon, cIdEnt )
EndIf   

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FillTemp

Preenchimento do arquivo temporário.

@Param		cQuery		-	Estrutura da consulta
			aCampos		-	Campos para tabela temporária
			nTotRegs	-	Contador do total de registros ( referência )
			nPenAnt		-	Contador de registros pendentes ( referência )
			nPenDep		-	Contador de registros pendentes após ajuste ( referência )
			lConxTSS	-	Indicador do conexão com TSS
			cStatus		-	Status de filtro dos registros
			aIDsSel		-	IDs do(s) trabalhador(es) selecionados
			lMaisD1		-	Indicador de seleção de mais de 1 evento

@Author		Felipe C. Seolin
@Since		14/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FillTemp( cQuery, aCampos, nTotRegs, nPenAnt, nPenDep, lConxTSS, cStatus, aIDsSel, lUpdate, nTipoMon, cIdEnt )

Local cAuxEvt		as character
Local cIdUnic		as character
Local cAliasAux		as character
Local cRegra		as character
Local cDataLim		as character
Local cChave		as character
Local nX			as numeric
Local nY			as numeric
Local nZ			as numeric
Local nAuxSts		as numeric
Local nTamID		as numeric
Local nTamVer		as numeric
Local nTamEvt		as numeric
Local nPendentes	as numeric
Local aReg4Trans	as array
Local aReg10Rec		as array
Local aAreaCUP		as array
Local aAreaCUU		as array
Local aAreaT3A		as array
Local lEnd			as logical

cAuxEvt		:=	""
cIdUnic		:=	""
cAliasAux	:=	GetNextAlias()
cRegra		:=	""
cDataLim	:=	""
cChave		:=	""
nX			:=	0
nY			:=	0
nZ			:=	0
nAuxSts		:=	0
nTamID		:=	0
nTamVer		:=	0
nTamEvt		:=	0
nPendentes	:=	0
aReg4Trans	:=	{}
aReg10Rec	:=	{}
aAreaCUP	:=	CUP->( GetArea() )
aAreaCUU	:=	CUU->( GetArea() )
aAreaT3A	:=	T3A->( GetArea() )
lEnd		:=	.F.

If !Empty( cQuery )
//	MemoWrite("D:\memowrite\tafmondet.txt", cQuery )
	TCQuery cQuery New Alias ( cAliasAux )

	If !lUpdate
		nTamId := GetSX3Cache( "C1E_ID", "X3_TAMANHO" )
		nTamVer := GetSX3Cache( "C1E_VERSAO", "X3_TAMANHO" )
		nTamEvt := GetSX3Cache( "C8E_CODIGO", "X3_TAMANHO" )
	EndIf
	
	While ( cAliasAux )->( !Eof() )
		RecLock( cAliasDet, .T. )

		For nX := 1 to Len( aCampos )
			If Empty( aCampos[nX][7] ) .Or. aCampos[nX][7] == "CRECIBO"
				If lUpdate
					( cAliasDet )->&( aCampos[nX][2] ) := Iif( aCampos[nX][1] == "Status", Iif( Empty( ( cAliasAux )->&( aCampos[nX][2] ) ), STATUS_NAO_PROCESSADO[1], Val( ( cAliasAux )->&( aCampos[nX][2] ) ) ), ( cAliasAux )->&( aCampos[nX][2] ) ) //"Status"
				Else
					If aCampos[nX][2] == "XSTATUS"
						( cAliasDet )->&( aCampos[nX][2] ) := Iif( Empty( ( cAliasAux )->&( aCampos[nX][2] ) ), STATUS_NAO_PROCESSADO[1], Val( ( cAliasAux )->&( aCampos[nX][2] ) ) )
					ElseIf aCampos[nX][2] == "DESCR"
						( cAliasDet )->&( aCampos[nX][2] ) := Iif( ValType( ( cAliasAux )->&( aCampos[nX][2] ) ) == "N", AllTrim( Str( ( cAliasAux )->&( aCampos[nX][2] ) ) ), ( cAliasAux )->&( aCampos[nX][2] ) )
					Else
						( cAliasDet )->&( aCampos[nX][2] ) := ( cAliasAux )->&( aCampos[nX][2] )
					EndIf
				EndIf
			EndIf
		Next nX

		nTotRegs ++

		nAuxSts := ( cAliasDet )->XSTATUS

		//Como eu não tenho uma tabela para gravar as inconsistências tenho que ficar verificando 
		//os registros que já retornaram erro para poder conseguir pegar a descrição do erro no TSS
		//e assim conseguir mostrar no detalhamento.
		iF nTipoMon == 1
			If nAuxSts == STATUS_SEM_RETORNO_GOV[1] .Or. nAuxSts == STATUS_INCONSISTENTE[1] 
				If lConxTSS
					If Empty( aReg4Trans ) .Or. ( nPos := aScan( aReg4Trans, { |x| x[4] == Alltrim(( cAliasAux )->LAYOUT) } ) ) == 0
						aAdd( aReg4Trans, TAFRotinas( Alltrim(( cAliasAux )->LAYOUT), 4, .F., 5 ) )
					EndIf
				Else
					( cAliasDet )->MENSG := "Servidor TSS desconectado." //"Servidor TSS desconectado."#
				EndIf
			ElseIf nAuxSts == STATUS_TRANSMITIDO_OK[1]
				( cAliasDet )->MENSG  := STATUS_TRANSMITIDO_OK[3]
			ElseIf nAuxSts == STATUS_INVALIDO[1]

				cIdUnic := STRTRAN((cAliasAux)->EVENTO,"-","") + AllTrim((cAliasAux)->ID) + AllTrim((cAliasAux)->VERSAO)

				If TAFAlsInDic( "T0X" ) .and. T0X->( MsSeek( xFilial( "T0X" ) +cIdUnic) )
					( cAliasDet )->MENSG := "ERRO DE PREDECESSÃO - O(s) seguinte(s) evento(s) ainda não foram enviado(s): " + T0X->T0X_PREDEC
				Else
					( cAliasDet )->MENSG := STATUS_INVALIDO[3]
				EndIf

			ElseIf nAuxSts == STATUS_VALIDO[1]
				( cAliasDet )->MENSG := STATUS_VALIDO[3]
			ElseIf nAuxSts == STATUS_NAO_PROCESSADO[1]
				( cAliasDet )->MENSG := STATUS_NAO_PROCESSADO[3]
			EndIf
		Else
			If nAuxSts == STATUS_SEM_RETORNO_GOV[1] .Or. nAuxSts == STATUS_INCONSISTENTE[1] 
				If lConxTSS
//					If Empty( aReg4Trans ) .Or. ( nPos := aScan( aReg4Trans, { |x| x[4] == ( cAliasAux )->LAYOUT } ) ) == 0
						aAdd( aReg4Trans, TAFRotinas( Alltrim(( cAliasAux )->LAYOUT), 4, .F., 5 ) )
						aAdd( aReg10Rec, ( cAliasDet )->RECNO)
//					EndIf
				Else
					( cAliasDet )->MENSG := "Servidor TSS desconectado." //"Servidor TSS desconectado."#
				EndIf
			ElseIf nAuxSts == STATUS_TRANSMITIDO_OK[1]
				( cAliasDet )->MENSG  := STATUS_TRANSMITIDO_OK[3]
			ElseIf nAuxSts == STATUS_INVALIDO[1]

				cIdUnic := STRTRAN((cAliasAux)->EVENTO,"-","") + AllTrim((cAliasAux)->ID) + AllTrim((cAliasAux)->VERSAO)

				If TAFAlsInDic( "T0X" ) .and. T0X->( MsSeek( xFilial( "T0X" ) +cIdUnic) )
					( cAliasDet )->MENSG := "ERRO DE PREDECESSÃO - O(s) seguinte(s) evento(s) ainda não foram enviado(s): " + T0X->T0X_PREDEC
				Else
					( cAliasDet )->MENSG := STATUS_INVALIDO[3]
				EndIf

			ElseIf nAuxSts == STATUS_VALIDO[1]
				( cAliasDet )->MENSG := STATUS_VALIDO[3]
			ElseIf nAuxSts == STATUS_NAO_PROCESSADO[1]
				( cAliasDet )->MENSG := STATUS_NAO_PROCESSADO[3]
			EndIf
		EndIf

		//Considero somente os inválidos e os inconsistentes como pendentes
		If nAuxSts == STATUS_INVALIDO[1] .or. nAuxSts == STATUS_INCONSISTENTE[1]
			nPendentes ++
		EndIf

		//Retorna as regras específicas de transmissão de cada um dos eventos do eSocial
		//TafRegra( ( cAliasAux )->ID + ( cAliasAux )->VERSAO, ( cAliasAux )->ALIAS, ( cAliasAux )->LAYOUT, @cRegra, @cDataLim )

		( cAliasDet )->DATALI := cDataLim
		( cAliasDet )->REGRA := cRegra

		//Zero a variável que será reutilizada
		cRegra := ""

		( cAliasDet )->( MSUnlock() )

		( cAliasAux )->( DBSkip() )
	EndDo

	( cAliasAux )->( DBCloseArea() )

	RestArea( aAreaCUP )
	RestArea( aAreaCUU )
	RestArea( aAreaT3A )

	nPenDep += nPendentes

	If !lUpdate
		nPenAnt += nPendentes
	EndIf

	lEnd := .F.

//	( cAliasDet )->( DBGoTop() )

	If Len( aReg4Trans ) > 0 .And. nTipoMon == 2
		/*+-------------------------------------------------+
		  | Realiza consulta dos registros no WS e atualiza |
		  | status e protocolo no arquivo de trabalho       |
		  +-------------------------------------------------+*/
		//Tenho que mudar o Status para que seja consultado somente o que está transmitido e pendente de transmissão.  
		cStatus := "'" + AllTrim(Str(STATUS_SEM_RETORNO_GOV[1])) 
		cStatus += "','" + AllTrim(Str(STATUS_INCONSISTENTE[1])) 
		cStatus += "','" + AllTrim(Str(STATUS_EXCLUSAO_PENDENTE[1])) + "'"
		FGrvRetTSS( aReg4Trans, cStatus, aCampos, aReg10Rec, cIdEnt )
	//	( cAliasDet )->( DBGoTop() )
	EndIf
EndIf

Return()

/*/{Protheus.doc} FGrvRetTSS
Grava o Retono do TSS
@author evandro.oliveira
@since 17/03/2016
@version 1.0
@param aReg4Trans, array, (Array dos itens para a consulta no TSS)
@param , ${param_type}, (Informa que existe eventos de tipos diferentes)
@param cStatus, character, (Status para filtro)
@param aCampos, array, (Campos do Browse)
@return ${Nil}, ${return_description}
/*/
Static Function FGrvRetTSS(aReg4Trans, cStatus, aCampos, aReg10Rec, cIdEnt)

Local cChave		as character
Local nTamId		as numeric
Local nTamVer		as numeric
Local nTamExt		as numeric
Local nX,nZ,nY		as numeric
Local cAuxEvt		as character
Local cDetalhe		as character
Local cTentativas	as character
Local lEnd			as logical
Local lHistProc		as logical
Local aAreaDet		as array

Private aRetLnTSS		as array
Private oJsonHistProc	as object

cChave   	:= ""
nTamId   	:= 0
nTamVer  	:= 0
nTamExt  	:= 0
nX		 	:= 0
nZ		 	:= 0
nY 		 	:= 0	
cAuxEvt  	:= ""
cTentativas	:= ""
cDetalhe	:= ""
aAreaDet	:= (cAliasDet)->( GetArea() )
lEnd     	:= .F.
lHistProc	:= .F.

nTamId	 := GetSx3Cache("C1E_ID"	,"X3_TAMANHO")
nTamVer  := GetSx3Cache("C1E_VERSAO","X3_TAMANHO")
nTamEvt  := GetSx3Cache("C8E_CODIGO","X3_TAMANHO")

aRetorno := TAFProc10Tss(.F., aEvents, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, aReg10Rec, cIdEnt)

(cAliasDet)->( DBSetOrder( 2 ) )

For nX := 1 To Len(aRetorno)
	For nZ := 1 To Len(aRetorno[nX])
		cChave := Substr(aRetorno[nX][nZ]:cId,nTamEvt,nTamId+nTamVer)

		aRetLnTSS := aRetorno[nX][nZ]

		cAuxEvt := Substr(aRetorno[nX][nZ]:cId,1,5)
		If (cAliasDet)->(MsSeek(cChave))
			If RecLock((cAliasDet),.F.)
				For nY := 1 To Len(aCampos)
					If !Empty(aCampos[nY][7])
						(cAliasDet)->&(aCampos[nY][2]) := &("aRetorno["+ AllTrim(Str(nX)) + "][" + AllTrim(Str(nZ)) + "]:"+aCampos[nY][7]) + iif(aCampos[nY][2] == "MENSG" .And. lHistProc .And. aRetorno[nX][nZ]:CSTATUS $ "124"," - " + cDetalhe,"")
					ElseIf aCampos[nY][2] == "XSTATUS"
						If !Empty(aRetorno[nX][nZ]:CSTATUS)
							( cAliasDet )->&( aCampos[nY][2] ) := Val(TAFStsXTSS(aRetorno[nX][nZ]:CSTATUS))
						EndIf
					EndIf
				Next nY
				(cAliasDet)->(MsUnlock())
			EndIf
		EndIf
	Next nZ
Next nX

RestArea( aAreaDet )

Return Nil

/*/{Protheus.doc} TafMonChk
Controle do CheckBox selecionado.

@author Leonardo Kichitaro
@since 12/03/2018
@version 1.0
@return ${Nil}
/*/
Static Function TafMonChk(nTipoChk,lChk01,lChk02,lChk03,oChk01,oChk02,oChk03,oDlg)

If nTipoChk == 1
	lChk01	:= .T.
	lChk02	:= .F.
	lChk03	:= .F.
ElseIf nTipoChk == 2
	lChk01	:= .F.
	lChk02	:= .T.
	lChk03	:= .F.
ElseIf nTipoChk == 3
	lChk01	:= .F.
	lChk02	:= .F.
	lChk03	:= .T.
EndIf

oChk01:Refresh()
oChk02:Refresh()
oChk03:Refresh()
oDlg:Refresh()

Return

/*/{Protheus.doc} mostraXMLErro
Exibe retorno do XML quando é retornado uma inconsistência.
@param lMaisD1 -> Identifica se existe eventos com codigos diferentes no detalhamento
necessário para saber se o campo EVENTO foi criado no browse.
@param xEvento -> Layout do Evento (quando não há eventos com codigos diferentes)

@author evandro.oliveira
@since 21/08/2017
@version 1.0
/*/
Static Function mostraXMLErro(xEvento)

	Local cEvento	:= ""
	Local cFuncao	:= ""
	Local aEvento	:= {}
	
	If (cAliasDet)->STATUSTSS == '5'

		ShowLog("Inconsistências retornadas do RET" , ( cAliasDet )->MENSG, xIdentXML( ( cAliasDet )->XMLERRO ) ) //"Inconsistências retornadas do RET"

	ElseIf (cAliasDet)->XSTATUS == 3 .OR. (cAliasDet)->XSTATUS == 1

		If ValType(xEvento) == "A"   
			cEvento := xEvento[1][4]
		Else
			cEvento := xEvento
		EndIf

		cIdUnic := STRTRAN(cEvento,"-","") + AllTrim((cAliasDet)->ID) + AllTrim((cAliasDet)->VERSAO)

		If TafSeekT0X(cIdUnic)
			If T0X->T0X_TPERRO = 'S' .And. (cAliasDet)->XSTATUS == 3
				Aviso("Erro de Schema", T0X->T0X_DCERRO, {"Fechar"}, 3 ) //"Erro de Schema"#"Fechar"
			Else
				If T0X->T0X_TPERRO = 'P' .And. (cAliasDet)->XSTATUS == 1
					Aviso("Erro de Predecessão", "Erro de Predecessão" + T0X->T0X_PREDEC, {"Fechar"}, 3 ) //"Erro de Predecessão"#"Fechar"
				Else
					MsgAlert("Não há Inconsistências para este registro .") //"Não há Inconsistências para este registro ."
				EndIf
			EndIf
		ElseIf (cAliasDet)->XSTATUS == 1
			aEvento := TAFRotinas(cEvento,4,.F.,2)
			cFuncao	:= aEvento[2]
			&cFuncao.(aEvento[3],(cAliasDet)->RECNO)
		EndIf
//	ElseIf (cAliasDet)->XSTATUS == 2 .And. !Empty((cAliasDet)->HISTPROC)
//		Aviso("Status do processo retorno TSS", (cAliasDet)->HISTPROC, {"Fechar"}, 3 ) //"Status do processo retorno TSS"#"Fechar"
	Else
		MsgAlert("Não há Inconsistências para este registro .") //"Não há Inconsistências para este registro ."
	EndIf
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TafMonAtu

Função que faz o refresh do WidGets

@sample 	TafMonAtu

@param		Nenhum

@return   	Nenhum

@author	Anderson Silva
@since		10/08/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Function TafMonAtu( cPeriodo )  

Local nX		:= 0
Local aObjTela	:= TafMonStat()

FWMsgRun(,{||TafReiAtu(Nil, cAliasTab, 1, .F., cPeriodo )},"Atualizando Monitor","Atualizando totalizadores do monitor")
FWMsgRun(,{||TafReiAtu(Nil, cAliasEvp, 2, .F., cPeriodo )},"Atualizando Monitor","Atualizando totalizadores do monitor")
FWMsgRun(,{||TafReiAtu(Nil, cAliasEvn, 3, .F., cPeriodo )},"Atualizando Monitor","Atualizando totalizadores do monitor")

CursorWait()	
For nX := 1 To Len(aObjTela)
	If !Empty( aObjTela[nX] )
		aObjTela[nX]:GoTop()
		aObjTela[nX]:Refresh()
	EndIf	
Next nX

CursorArrow()

Return Nil

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

//--------------------------------------------------------------------
/*/{Protheus.doc} FSalvProf
Grava os Parâmentros em um arquivo de profile
@author Leonardo Kichitaro
@since 19/04/2018
@version 1.0
@return ${boolean}, ${A função MemoWrite Retorna True ou False}
/*/
//--------------------------------------------------------------------
Static Function FSalvProf ()
Local  nX			as numeric
Local  cWrite		as char
Local  cBarra		as char
Local  lRet			as logical	    
Local  cUserName	as char
Local  cNomeProf 	as char

nX			:= 0
cWrite		:= ""
cBarra		:= If ( IsSrvUnix () , "/" , "\" )
lRet		:= .F.	    
cUserName	:= __cUserID
cNomeProf 	:= ""
	
// --> Gera a string em formato JSON
cWrite := FwJsonSerialize(aParamRei)
	
cNomeProf	:=	FunName() +"_" +cUserName
	
Return (MemoWrite ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" , cWrite ))


//--------------------------------------------------------------------
/*/{Protheus.doc} msgTSSAuth
Função para apresentar DIALOG com link da documentação
@author Renan Santos
@since 10/05/2021
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
Static Function msgTSSAuth()
	Local cMsg  		:= ""
	Local oModal 		:= Nil
	Local oContainer 	:= Nil

	Default lQTDesc		:= .F.
	Default dDataFim	:= CtoD("01/12/2021")

	oFontSub 				:= TFont():New('Arial',,-16,.T.)
	oFontText 				:= TFont():New('Arial',,-16,.T.)
	oFontTitle 				:= TFont():New('Arial',,-18,.T.)
	oFontTitle:Bold 		:= .T.
	oFontButtons 			:= TFont():New('Arial',,-16,.T.)
	oFontButtons:Underline 	:= .T.
	oFontButtons:Bold 		:= .T.
	oModal					:= FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:SetTitle('TOKEN de autenticação obrigatório TAF X TSS') // "TOKEN de autenticação obrigatório TAF X TSS"

	oModal:SetSize(190,400)
	oModal:CreateDialog()

	oModal:addCloseButton(Nil, "Fechar")

	oFont := TFont():New("Courier new",, -18, .T.)

	cMsg := '<div align="justify">'
	cMsg += '	<br>' + 'Esta Filial não tem permissão para acessar o servidor TSS.' + '</br>' 						// "Esta Filial não tem permissão para acessar o servidor TSS."	
	cMsg += '	<p>' + 'Contate o administrador do sistema e verifique as credenciais cadastradas na rotina <b> "Conf. Geral TSS" (SPEDCONFTSS) </b></p>'	// "Contate o administrador do sistema e verifique as credenciais cadastradas na rotina" // "'Conf. Geral TSS' (SPEDCONFTSS)"
	cMsg += '	<p>' + 'Clique nos links abaixo para saber o passo a passo, de como configurar o TSS com Autenticação e também conhecer mais detalhes.' + '</p>' 						// "Clique nos links abaixo para saber o passo a passo, de como configurar o TSS com Autenticação e também conhecer mais detalhes."
	cMsg += '</div>'

	oFont := TFont():New("Courier new",, -22, .T.)

	oSay := TSay():New(30,15,{|| cMsg },,,oFontSub,,,,.T.,,,350,130,,,,,,.T.)

	oBtn1 := THButton():New(140, 010, 'Configurando TSS com autenticação', oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com.br/pages/releaseview.action?pageId=593238229", "", "C:\", 1)}, 200, 20, oFontButtons, 'Configurando TSS com autenticação') 	// "Configurando TSS com autenticação"
	oBtn2 := THButton():New(140, 200, 'Configurações Gerais do TSS', oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com.br/pages/releaseview.action?pageId=590613669", "", "C:\", 1)}, 165, 20, oFontButtons, 'Configurações Gerais do TSS')	// "Configurações Gerais do TSS"
		
	oBtn1:SetCss("QPushButton{ color: #21a4c4; }")
	oBtn2:SetCss("QPushButton{ color: #21a4c4; }")

	oModal:Activate()
		
Return 
