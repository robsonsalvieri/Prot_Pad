#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM940.CH"

Static lFirst
Static lVldOk

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM940
Integração com Swile
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Function GPEM940()

Local aParams			:= {}
Local oNewPag   		:= Nil
Local oStepWiz  		:= Nil

//Parametrização
Local cSWURL			:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local cSWUser			:= SuperGetMv( 'MV_APISWI2', Nil, "" )
Local cSWPsw			:= SuperGetMv( 'MV_APISWI3', Nil, "" )

Private aLogErr       	:= {}
Private aLogFiltro     	:= {}
Private aLogIncon     	:= {}
Private aLogImp       	:= {}
Private aLogProc       	:= {}
Private aTitle         	:= { OemToAnsi(STR0004), OemToAnsi(STR0005), OemToAnsi(STR0045), OemToAnsi(STR0046), OemToAnsi(STR0064)}//"Processamento"##"Filtros realizados: "##"Erro na integração com Swile"##"Registros Integrados"##"Registros inconsistentes"
Private cAliasTmp		:= GetNextAlias()
Private cTabSR0			:= RetSqlName("SR0")
Private cTabSRA			:= RetSqlName("SRA")
Private cTimeIni		:= ""
Private lInExec			:= .F.
Private lIntegrou		:= .F.
Private nQtdSel 		:= 0
Private nRemoteType		:= GetRemoteType()
Private nTotInteg 		:= 0
Private nTotProc 		:= 0
Private oArqTmp			:= Nil
Private oProfile		:= FwProfile():New()

//Tela Opções
Private cFilCNPJ 		:= Space( FwGetTamFilial )
Private dDtCred 		:= cToD("")
Private dDtVcto 		:= cToD("")
Private cPerPed 		:= AnoMes(dDataBase)
Private lIntFil 		:= .F.
Private lIntGrp 		:= .F.
Private lIntFunc 		:= .F.
Private lIntPed 		:= .F.
Private oChkFil			:= Nil
Private oChkGrp			:= Nil
Private oChkFunc		:= Nil
Private oChkPed			:= Nil
Private oGetDtCred		:= Nil
Private oGetDtVcto		:= Nil
Private oGetPerPed		:= Nil
Private oGetFilCNPJ		:= Nil

//Tela Filtro
Private aArrayFil		:= {}
Private cFltGrp			:= ""
Private cFltFunc		:= ""
Private cFltPed			:= ""
Private oButFil			:= Nil
Private oButGrp			:= Nil
Private oButFunc		:= Nil
Private oButPed			:= Nil

//Tela Processamento
Private oButtonProc		:= Nil
Private oSayProc		:= Nil
Private oSaySep			:= Nil

If Empty(cSWURL) .Or. Empty(cSWUser) .Or. Empty(cSWPsw)
	//"Atenção"###"Os parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APISWI1 MV_APISWI2 e/ou MV_APISWI3 no módulo Configurador"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

oProfile:SetUser( RetCodUsr() )
oProfile:SetProgram( "GPEM940" )
oProfile:SetTask( "GPEM940PARAM" )

aParams := oProfile:Load()
If !Empty(aParams)
	cFilCNPJ	:= aParams[1]
	dDtCred		:= aParams[2]
	dDtVcto		:= aParams[3]
	cPerPed		:= If(Len(aParams)>3,aParams[4],cPerPed)
EndIf

fCriaTmp()//Criação de tabela temporária para a MarkBrowse de seleção de filiais

oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep( "1" )
oNewPag:SetStepDescription( STR0006 )//"Observações"
oNewPag:SetConstruction( { |Panel1| fPag1(Panel1) } )
oNewPag:SetNextAction( { || !PrcExec() .And. fVldAut() } )
oNewPag:SetCancelAction( { || .T.} )

oNewPag := oStepWiz:AddStep( "2" )
oNewPag:SetStepDescription( STR0007 )//"Opções"
oNewPag:SetConstruction( { |Panel2| fPag2(Panel2) } )
oNewPag:SetNextAction( { || fVldOpc() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "3" )
oNewPag:SetStepDescription( STR0008 )//"Filtro"
oNewPag:SetConstruction( { |Panel3| fPag3(Panel3) } )
oNewPag:SetNextAction( { || fVldOpc() .And. fVldFil() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "4" )
oNewPag:SetStepDescription( STR0009 )//"Processamento"
oNewPag:SetConstruction( { |Panel4| fPag4(Panel4) } )
oNewPag:SetPrevAction( { || PrcConcl() } )
oNewPag:SetNextAction( { || !PrcInt() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag:SetPrevWhen( { || !PrcExec() } )
oNewPag:SetCancelWhen( { || !PrcExec() } )

oStepWiz:Activate()

oProfile:DeActivate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaTmp
Criação da tabela temporária da SM0
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fCriaTmp()

Local aLstIndices	:= {}
Local aSM0 			:= FWLoadSM0(.T., Nil, .T.)
Local aStru			:= {}
Local nCont			:= 0

aAdd( aStru, { "OK"		, "C", 2			  , 0 } )
aAdd( aStru, { "FILIAL"	, "C", FwGetTamFilial , 0 } )
aAdd( aStru, { "NOME"  	, "C", 100			  , 0 } )
aAdd( aStru, { "CNPJ"  	, "C", 14 			  , 0 } )
aAdd( aLstIndices, { "FILIAL" } )

oArqTmp := RhCriaTrab(cAliasTmp, aStru, aLstIndices)

For nCont := 1 To Len(aSM0)
	If aSM0[nCont, 1] == cEmpAnt
		If (cAliasTmp)->( RecLock(cAliasTmp, .T.) )
			(cAliasTmp)->FILIAL	:= aSM0[nCont, 2]
			(cAliasTmp)->NOME  	:= aSM0[nCont, 7]
			(cAliasTmp)->CNPJ 	:= aSM0[nCont, 18]
			(cAliasTmp)->(MsUnlock())
		EndIf
	EndIf
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag1
Painel com os descritivos do assistente
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag1(oPanel)

Local oButtonProc	:= Nil

TSay():New( 25, 20, { || fText("BEMVINDO") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )
TSay():New( 45, 20, { || fText("ASSIST") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 120, 25, OemToAnsi(STR0010), oPanel, { || ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=707370134", "", "", 1 ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F. )//"Clique para abrir a documentação no TDN"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag2
Painel com as opções para integração
@author  Allyson L Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag2(oPanel)

Local lTabSel	    := .F.
Local nLin			:= 30

oGrpOpc 	:= TGroup():Create( oPanel, 10, 5, 100, 300, STR0007, Nil, Nil, .T. )//"Opções"

oChkFil := TcheckBox():New( nLin, 10, STR0011, { || lIntFil }, oGrpOpc, 300, 10, Nil, { || lIntFil := !lIntFil }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Filiais"
nLin += 10
oChkGrp := TcheckBox():New( nLin, 10, STR0012, { || lIntGrp }, oGrpOpc, 300, 10, Nil, { || lIntGrp := !lIntGrp }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .F. } )//"Grupos de benefícios"
nLin += 10
oChkFunc := TcheckBox():New( nLin, 10, STR0013, { || lIntFunc }, oGrpOpc, 300, 10, Nil, { || lIntFunc := !lIntFunc }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Funcionários"
nLin += 10
oChkPed := TcheckBox():New( nLin, 10, STR0014, { || lIntPed }, oGrpOpc, 300, 10, Nil, { || lIntPed := !lIntPed }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Pedidos"

nLin += 20
oChkInv := TcheckBox():New( nLin, 10, STR0015, { || lTabSel }, oGrpOpc, 300, 10, Nil, { || fInverte(@lTabSel) }, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, Nil )//"Inverte seleção"

nLin += 30
oGrpParam 	:= TGroup():Create( oPanel, nLin, 5, 205, 300, STR0078, Nil, Nil, .T. )//"Parametrização para integração de pedidos"
nLin += 20
oSayFilCNPJ	:= TSay():New( nLin, 10, { || STR0079 }, oGrpParam, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Filial para geração da nota fiscal: "
oGetFilCNPJ	:= TGet():New( nLin, 115, { |u| Iif( PCount() == 0, cFilCNPJ, cFilCNPJ := u ) }, oGrpParam, 180, 10, "@!", { || Vazio() .Or. ExistCpo("SM0", cEmpAnt + cFilCNPJ) } , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'cFilCNPJ' )
oGetFilCNPJ:cF3	:= "XM0"
nLin += 20
oSayDtCred 	:= TSay():New( nLin, 10, { || STR0080 }, oGrpParam, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Data de crédito: "
oGetDtCred 	:= TGet():New( nLin, 115, { |u| Iif( PCount() == 0, dDtCred, dDtCred := u ) }, oGrpParam, 180, 10, "@D", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'dDtCred' )
nLin += 20
oSayDtVcto	:= TSay():New( nLin, 10, { || STR0081 }, oGrpParam, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Data de vencimento: "
oGetDtVcto 	:= TGet():New( nLin, 115, { |u| Iif( PCount() == 0, dDtVcto, dDtVcto := u ) }, oGrpParam, 180, 10, "@D", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'dDtVcto' )
nLin += 20
oSayPerPed	:= TSay():New( nLin, 10, { || STR0095 }, oGrpParam, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Competência dos pedidos: "
oGetPerPed 	:= TGet():New( nLin, 115, { |u| Iif( PCount() == 0, cPerPed, cPerPed := u ) }, oGrpParam, 180, 10, "@!", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'cPerPed' )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag3
Painel com os filtros
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag3(oPanel)

Local nLin			:= 45
Local oSayExec		:= Nil

oSayExec := TSay():New( 10, 10, { || STR0016 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Filtros"

oButFil  := TButton():New( nLin, 25, OemToAnsi(STR0017), oPanel, { || fSelFil() }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Filiais"
nLin += 20
oButGrp  := TButton():New( nLin, 25, OemToAnsi(STR0018), oPanel, { || GpFltBldExp( "SRA", Nil, @cFltGrp, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Grupos de benefícios"
nLin += 20
oButFunc := TButton():New( nLin, 25, OemToAnsi(STR0019), oPanel, { || GpFltBldExp( "SRA", Nil, @cFltFunc, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Funcionários"
nLin += 20
oButPed := TButton():New( nLin, 25, OemToAnsi(STR0020), oPanel, { || GpFltBldExp( "SR0", Nil, @cFltPed, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Pedidos"

oButGrp:lActive 	:= lIntGrp
oButFunc:lActive 	:= lIntFunc .or. lIntPed
oButPed:lActive 	:= lIntPed

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag4
Painel com o processamento da integração
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag4(oPanel)

TSay():New( 45, 20, { || fText("PROC") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 100, 25, OemToAnsi(STR0021), oPanel, { || fBarra(oPanel, oButtonProc ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Clique para efetuar a integração"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fText
Formatação do textos dos descritivos do assistente
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fText(cInfo)

Local cRet 		:= ""

If cInfo == "BEMVINDO"
	cRet := '<span style="font-size:18px; color:#0c9abe;"><b>'+STR0022+'</b></span>'//"Bem-vindo..."
	cRet += '<br/>'
ElseIf cInfo == "ASSIST"
	cRet += '<span style="font-size:16px; color:#888;">'+STR0023+'</span>'//"Este é um processo para a integração de registros para Swile"
ElseIf cInfo == "PROC"
	cRet += '<span style="font-size:16px; color:#888;">'+STR0024//"Ao clicar no botão abaixo, será iniciado o processo de"
	cRet += '<br/>'
	cRet += STR0025//"integração com Swile."
	cRet += '</span>'
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fCSS(cIDCSS)

Local cCSS := ""

Do Case
	Case cIDCSS == "TEXTTITLE"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "BTPROC"
		cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;"
		cCSS += "padding: 2px 5px;"
		cCSS += "text-align: center; "
		cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS += "QPushButton:hover { "
		cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
		cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;"
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
EndCase

Return(cCSS)

//-------------------------------------------------------------------
/*/{Protheus.doc} fInverte
Função para inverter a seleção dos itens a serem integrados
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fInverte(lRet)

lIntFil 	:= !lIntFil
lIntGrp 	:= !lIntGrp
lIntFunc 	:= !lIntFunc
lIntPed 	:= !lIntPed

oChkFil:Refresh()
oChkGrp:Refresh()
oChkFunc:Refresh()
oChkPed:Refresh()

Return !lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOpc
Valida a seleção de opções
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fVldOpc()

Local aParams 	:= {}
Local lRet 		:= .T.

fContSel()

If Empty(nQtdSel)
	lRet := .F.
	MsgInfo(STR0026, STR0001)//"Certifique-se ao menos de selecionar uma opção para integração"##"Atenção"
EndIf

If lIntPed .And. ( Empty(cFilCNPJ) .Or. Empty(dDtCred) .Or. Empty(dDtVcto) )
	lRet := .F.
	MsgInfo(STR0082, STR0001)//"Certifique-se de preencher a filial para geração da nota fiscal, a data de crédito do pedido e a data de vencimento do boleto."##"Atenção"
EndIf

If ValType(oButFil) != "U"
	oButFil:lActive 	:= .T.
	oButGrp:lActive 	:= lIntGrp
	oButFunc:lActive 	:= lIntFunc .or. lIntPed
	oButPed:lActive 	:= lIntPed
EndIf

If lRet
	aParams := { cFilCNPJ, dDtCred, dDtVcto, cPerPed }
	oProfile:SetProfile( aParams )
	oProfile:Save()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fContSel
Verifica quantas opções foram selecionadas
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fContSel()

nQtdSel := 0

If lIntFil
	nQtdSel++
EndIf
If lIntGrp
	nQtdSel++
EndIf
If lIntFunc
	nQtdSel++
EndIf
If lIntPed
	nQtdSel++
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcConcl
Retorna se o processamento já foi concluído
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcConcl()

If oArqTmp == Nil
	fCriaTmp()
	oButtonProc:Enable()
	oSayProc:setText("")
	oSaySep:setText("")	
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcExec
Retorna se o processamento está em execução de acordo com o semáforo
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcInt
Retorna se o processamento foi realizado
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcInt()

Local lRet	:= .F.

If !lIntegrou
	lRet := !MsgNoYes(STR0027, STR0001)//"Deseja fechar a rotina sem efetuar a importação?"##"Atenção"
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fSelFil
Retorna as filiais que serão processadas
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fSelFil()

Local aButtons 		:= {}
Local aColumns 		:= {}
Local bOK2			:= { || ( oDlgGrid:End(), nOpcB := 1 ) }
Local bFecha 		:= { || oDlgGrid:End() }
Local lMArcar 		:= .F.
Local nOpcB 		:= 0
Local oFont 		:= Nil

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->FILIAL }") )
aColumns[Len(aColumns)]:SetTitle( STR0028 )//"Filial"
aColumns[Len(aColumns)]:SetSize( FwGetTamFilial )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->NOME }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0029 )//"Nome"
aColumns[Len(aColumns)]:SetSize( Len(SM0->M0_NOME) )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->CNPJ }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0030 )//"CNPJ"
aColumns[Len(aColumns)]:SetSize( 14 )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!R NN.NNN.NNN/NNNN-99" )

//Tela
oSize := FwDefSize():New(.F.)
oSize:AddObject( "CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4) , .F., .F. )
oSize:aMargins 	:= { 0, 0, 0, 0 }
oSize:lProp 	:= .F. 
oSize:Process()

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(STR0031) From 0, 0 TO 380, 930 OF oMainWnd PIXEL//"Filiais"

oTela2	:= FWFormContainer():New( oDlgGrid )
cIdGrid	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension( "CABECALHO","LININI" )+1, oSize:GetDimension( "CABECALHO", "COLINI" )+4 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090, oSize:GetDimension("CABECALHO","COLEND") * 0.431 OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension( "CABECALHO","LININI" )+9, oSize:GetDimension( "CABECALHO", "COLINI" )+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()
oMark:SetAlias( cAliasTmp )
oMark:SetTemporary( .T. )
oMark:SetColumns( aColumns )

//Indica o container onde sera criado o browse
oMark:SetOwner( oPanel4 )
oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTmp ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')

oMark:SetMenuDef("GPEM034")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha, NIL, aButtons)

If nOpcB == 1
	aArrayFil		:= {}
	(cAliasTmp)->(dbGoTop())
	While (cAliasTmp)->( !EoF() )
		If !Empty( (cAliasTmp)->OK )
			aAdd(aArrayFil, { (cAliasTmp)->FILIAL, (cAliasTmp)->NOME })
		EndIf
		(cAliasTmp)->( dbSkip() )
	EndDo
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Marca/desmarca todos os itens
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca, lMarcar, cAliasTmp)

Local aAreaMark  := (cAliasTmp)->( GetArea() )

dbSelectArea(cAliasTmp)
(cAliasTmp)->( dbGoTop() )

While (cAliasTmp)->( !Eof() )
	If RecLock( (cAliasTmp), .F. )
		(cAliasTmp)->OK := Iif( lMarcar, cMarca, '  ' )
		MsUnLock()
	EndIf
	(cAliasTmp)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFil
Valida a seleção de filiais
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFil()

Local lRet := .T.

If Empty(aArrayFil)
	lRet := .F.
	MsgInfo(STR0032, STR0001)//"Certifique-se de selecionar a(s) filial(is) para processamento no botão de Filtro de Filiais"##"Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fBarra
Monta a barra de progresso na parte de baixo do painel 3 do wizard
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fBarra(oPanel, oButtonProc)

Local nMeter	:= 0
Local nMeter2	:= 0
Local oMeter	:= Nil
Local oMeter2	:= Nil
Local oSayProc2	:= Nil
Local oSayProc3	:= Nil

lInExec := .T.

aAdd( aLogProc, STR0033 + dToC( Date() ) )//"Data de início: "
aAdd( aLogProc, STR0034 + Time() )//"Hora de início: "

// Desabilita os botões
oButtonProc:Disable()

oSaySep := TSay():New( 115, 02, { || Replicate("_", 150) }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )
oSaySep:setCSS( fCSS("LINESEPARADOR") )

oSayProc := TSay():New( 130, 80, { || STR0035 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Efetuando Processamento -> "
oSayProc:setCSS( fCSS("TEXTTITLE") )

oSayProc2 := TSay():New( 145, 115, { || STR0036 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Opções importadas: "
oSayProc2:setCSS( fCSS("TEXTTITLE") )
oMeter2 := TMeter():New( 155, 25, { |u| Iif( Pcount() > 0, nMeter2 := u, nMeter2) }, 100, oPanel, 250, 16,, .T.)
oMeter2:setCSS("METER")
oMeter2:SetTotal(0)
oMeter2:Set(0)

oSayProc3 := TSay():New( 175, 115, { || STR0037 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300,20 )//"Registros importados: "
oSayProc3:setCSS( fCSS("TEXTTITLE") )
oMeter := TMeter():New( 185, 25, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 250, 16, Nil, .T. )
oMeter:setCSS("METER")
oMeter:SetTotal(0)
oMeter:Set(0)

// Chama as funções de processamento
fProc(oSayProc, oMeter, oMeter2, oSayProc2, oSayProc3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fProc
Encapsula as funções de processamento
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fProc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local cFilSelec	:= ""
Local cToken	:= ""
Local lTokOk	:= .F.
Local nContFil	:= 0

cTimeIni := Time()
oMeter2:SetTotal( nQtdSel )

fLogoutSwi()
lTokOk := fTokenSwi( @cToken )

If !lTokOk
	aAdd(aLogErr, STR0047)//"Houve falha ao tentar obter o token de acesso. Solicite ao administrador uma revisão dos parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3"
Else
	For nContFil := 1 To Len(aArrayFil)
		cFilSelec += aArrayFil[nContFil, 1] + "|"
	Next nContFil
	FiltraLog( aLogFiltro, STR0038 + cFilSelec)//"Filiais selecionadas: "

	If lIntFil//Filial
		fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
	EndIf
	If lIntFunc//Funcionarios
		fIntFun(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0013 + ": " + cFltFunc)//"Funcionários"
	EndIf
	If lIntPed//Pedidos
		fIntPed(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0014 + ": " + cFltPed)//"Pedidos"
	EndIf
EndIf

aAdd( aLogProc, STR0039 + dToC( Date() ) )//"Data de término: "
aAdd( aLogProc, STR0040 + Time() )//"Hora de término: "
aAdd( aLogProc, STR0041 + ElapTime( cTimeIni, Time() ) )//"Tempo de processamento: "
aAdd( aLogProc, "")
aAdd( aLogProc, STR0042 + cValToChar(nTotInteg) )//"Total de registros integrados: "
fMakeLog( { aLogProc, aLogFiltro, aLogErr, aLogImp, aLogIncon }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0043), "G", "L", Nil, .F.) //"Log de Ocorrências"

MsgAlert(STR0044, STR0001)//"Processamento Finalizado"##"Atenção"
lInExec 	:= .F.
lIntegrou  	:= .T.

If ValType(oMeter2) <> "U"
	oSay:setText(Space(20)+STR0044)//"Processamento Finalizado."
	oMeter:Free()
	oMeter2:Free()
	oSayProc2:setText("")
	oSayProc3:setText("")
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->( dbCloseArea() )
EndIf

If oArqTmp != Nil
	oArqTmp:Delete()
	Freeobj(oArqTmp)
EndIf

///Reinicialização das variáveis de integração
aArrayFil 	:= {}
aLogErr		:= {}
aLogFiltro	:= {}
aLogImp 	:= {}
aLogIncon 	:= {}
aLogProc 	:= {}
aTitle    	:= { OemToAnsi(STR0004), OemToAnsi(STR0005), OemToAnsi(STR0045), OemToAnsi(STR0046), OemToAnsi(STR0064)}//"Processamento"##"Filtros realizados: "##"Erro na integração com Swile"##"Registros Integrados"##"Registros inconsistentes"
cFltGrp 	:= cFltFunc := cFltPed 	:= ""
lIntFil 	:= lIntGrp 	:= lIntFunc := lIntPed := .F.
nTotInteg	:= nTotProc	:= 0
oButFil:lActive 	:= .F.
oButGrp:lActive 	:= .F.
oButFunc:lActive 	:= .F.
oButPed:lActive 	:= .F.

Return

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} fLogoutSwi()
Função que efetua o logout no Swile
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Function fLogoutSwi()

Local aHeader	:= {}
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local oClient 	:= Nil

oClient := FwRest():New(cSWURL+"/logout")
oClient:SetPath("")
oClient:Post(aHeader)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fTokenSwi()
Função que gera o token de acesso no Swile
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Function fTokenSwi( cToken )

Local aHeader		:= {}
Local cBody			:= ""
Local cSWURL		:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local cSWUser		:= SuperGetMv( 'MV_APISWI2', Nil, "" )
Local cSWPsw		:= SuperGetMv( 'MV_APISWI3', Nil, "" )
Local lRet 			:= .F.
Local oClient 		:= Nil
Local oJson 		:= JsonObject():New()

DEFAULT cToken      := ""

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Content-Type: application/x-authc-username-password+json" )

cBody := "{"
cBody += '"userId": "' + cSWUser + '",'
cBody += '"password": "' + cSWPsw + '"'
cBody += "}"

oClient:SetPostParams(cBody)
oClient:SetPath("/authenticate")

If oClient:Post(aHeader)
	oJson:fromJson( oClient:GetResult() )
	cToken 	:= oJson["token"]
	lRet 	:= .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFil
Realiza a integração da tabela SM0 de filiais
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aInfoFil		:= {}
Local aRegErr		:= {}
Local aRegInt		:= {}
Local cAliasQRY 	:= "IMPSM0"
Local cErrInt		:= ""
Local cFilQry		:= ""
Local cNomeTmp 		:= oArqTmp:GetRealName()
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0049 + STR0050 )//"Iniciando Processamento..."##"Importação filiais"
oSayProc2:SetText( STR0051 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT FILIAL "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	+= "ORDER BY 1"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	cErrInt := ""
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0052 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

	If fInfo( @aInfoFil, (cAliasQRY)->FILIAL, cEmpAnt )
		oJson := JsonObject():New()
		oJson['name'] 			:= AllTrim( aInfoFil[03] )//M0_NOMECOM
		oJson['document'] 		:= AllTrim( aInfoFil[08] )//M0_CGC
		oJson['street'] 		:= AllTrim( SubStr( aInfoFil[04], 1, At(",", aInfoFil[04])-1) )//M0_ENDENT
		oJson['number'] 		:= AllTrim( SubStr( aInfoFil[04], At(",",aInfoFil[04])+1) )//M0_ENDENT
		oJson['complement'] 	:= AllTrim( aInfoFil[14] )//M0_COMPENT
		oJson['neighborhood'] 	:= AllTrim( aInfoFil[13] )//M0_BAIRENT
		oJson['city'] 			:= AllTrim( aInfoFil[05] )//M0_CIDENT
		oJson['state'] 			:= AllTrim( aInfoFil[06] )//M0_ESTENT
		oJson['country'] 		:= Iif( cPaisLoc == "BRA", "Brasil", "")
		oJson['zipCode'] 		:= AllTrim( SubStr(aInfoFil[07], 1, 5) + "-" + SubStr(aInfoFil[07], 6) )//M0_CEPENT
		
		If fEnvFil(oJson, cToken, @cErrInt)
			aAdd(aRegInt, oJson['document'] + " - " + oJson['name'])
		Else
			aAdd(aRegErr, oJson['document'] + " - " + oJson['name'])
			aAdd(aRegErr, cErrInt )
		EndIf
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

If !Empty(aRegInt)
	aAdd(aLogImp, STR0053)//"Registros integrados de filiais: "
	For nRegs := 1 To Len(aRegInt)
		aAdd(aLogImp, aRegInt[nRegs])
	Next nRegs
	nTotInteg += Len(aRegInt)
EndIf

If !Empty(aRegErr)
	aAdd(aLogErr, STR0054)//"Erro na integração das filiais: "
	aAdd(aLogErr, STR0048)//"Obs.: erro completo retornado:"
	For nErrInt := 1 To Len(aRegErr)
		FiltraLog( aLogErr, aRegErr[nErrInt])
	Next nErrInt	
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEnvFil()
Função que efetua a integração para Swile das filiais
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fEnvFil( oJson, cToken, cErrInt )

Local aHeader	:= {}
Local cBody		:= ""
Local cPath		:= ""
Local cStatus	:= "2"
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local lAchou	:= .F.
Local lRet 		:= .F.
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Token " + cToken )
aAdd( aHeader, "Content-Type: application/json; charset=UTF-8" )

oClient:SetPath("/private/corporate/branch/find")

cBody := '{'
cBody += 	'"document": "' + oJson['document'] + '"'
cBody += '}'
oClient:SetPostParams(cBody)

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	lAchou := ValType( oResult["branchIdentify"] ) == "C"
EndIf

cPath := Iif( lAchou, "/private/corporate/branch/update", "/private/corporate/branch/add" )
oClient:SetPath(cPath)

cBody := '{'
cBody += 	'"name": "' + oJson['name'] + '",'
cBody += 	'"document": "' + oJson['document'] + '",'
cBody += 	'"address": {'
cBody += 		'"street": "' + oJson['street'] + '",'
cBody += 		'"number": ' + oJson['number'] + ','
cBody += 		'"complement": "' + oJson['complement'] + '",'
cBody += 		'"neighborhood": "' + oJson['neighborhood'] + '",'
cBody += 		'"city": "' + oJson['city'] + '",'
cBody += 		'"state": "' + oJson['state'] + '",'
cBody += 		'"country": "' + oJson['country'] + '",'
cBody += 		'"zipCode": "' + oJson['zipCode'] + '"'
cBody += 		'}'
cBody += '}'
oClient:SetPostParams( EncodeUTF8(cBody) )	

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	If oResult["statusCode"] == 1
		cStatus := "1"
		lRet 	:= .T.
	EndIf
EndIf

cErrInt := DecodeUTF8( oClient:GetResult() )

fGravaRUC( "1", cStatus, cBody, cErrInt )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFun
Realiza a integração da tabela SRA de funcionários
@author  Allyson Luiz Mesashi
@since   14/10/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFun(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaSRA 		:= SRA->( GetArea() )
Local aCpfsProc		:= {}
Local aRegErr		:= {}
Local aRegInt		:= {}
Local cAliasQRY 	:= "IMPSRA"
Local cCNPJ			:= ""
Local cErrInt		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0049 + STR0055 )//"Iniciando Processamento..."##"Importação funcionários"
oSayProc2:SetText( STR0051 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SRA.RA_CIC, SRA.RA_SITFOLH, SRA.RA_ADMISSA, SRA.R_E_C_N_O_ AS SRARECNO "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1,2 ASC, 3 DESC"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0056)//"Erro na integração de funcionários: "
	aAdd(aLogErr, STR0057)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		cErrInt := ""
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0052 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SRA->( dbGoTo( (cAliasQRY)->SRARECNO ) )
		
		If aScan( aCpfsProc, { |x| x == SRA->RA_CIC } ) > 0
			If aScan( aLogIncon, { |x| x == STR0061 } ) == 0//"Inconsistências na integração de funcionários:"
				aAdd(aLogIncon, STR0061)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0059 + SRA->RA_FILIAL+SRA->RA_MAT + STR0066)//"Filial + Mat: "##" desprezado porque CPF já foi enviado anteriormente."
			(cAliasQRY)->( dbSkip() )
			Loop		
		EndIf

		If fVldSRA( @cCNPJ, cToken )
			aAdd( aCpfsProc, SRA->RA_CIC )
			oJson := JsonObject():New()	
			oJson['name'] 							:= Iif( !Empty(SRA->RA_NOMECMP), AllTrim( SRA->RA_NOMECMP ), SRA->RA_NOME )
			oJson['document'] 						:= AllTrim( SRA->RA_CIC )
			oJson['externalId'] 					:= AllTrim( cEmpAnt + SRA->RA_FILIAL + SRA->RA_MAT )
			oJson['phoneNumber'] 					:= "("+AllTrim( SRA->RA_DDDCELU )+")" + AllTrim( SRA->RA_NUMCELU )
			oJson['email'] 							:= AllTrim( SRA->RA_EMAIL )
			oJson['workGroupName'] 					:= cCNPJ//na fase 1, fixo com o CNPJ da filial
			oJson['corporateBranchDocument'] 		:= cCNPJ
			oJson['gender'] 						:= Iif( SRA->RA_SEXO == "M", "MALE", Iif( SRA->RA_SEXO == "F", "FEMALE", "UNDEFINED" ) )
			oJson['birthDate'] 						:= dToC( SRA->RA_NASC )
			oJson['status'] 						:= IIf( !Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA >= Date(), "INACTIVE", "ACTIVE" )

			If fEnvFun(oJson, cToken, @cErrInt)
				aAdd(aRegInt, oJson['externalId'] + " - " + oJson['name'])
			Else
				aAdd(aRegErr, oJson['externalId'] + " - " + oJson['name'])
				aAdd(aRegErr, cErrInt )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo
EndIf

If !Empty(aRegInt)
	aAdd(aLogImp, STR0058)//"Registros integrados de filiais: "
	For nRegs := 1 To Len(aRegInt)
		aAdd(aLogImp, aRegInt[nRegs])
	Next nRegs
	nTotInteg += Len(aRegInt)
EndIf

If !Empty(aRegErr)
	aAdd(aLogErr, STR0056)//"Erro na integração de funcionários: "
	aAdd(aLogErr, STR0048)//"Obs.: erro completo retornado:"
	For nErrInt := 1 To Len(aRegErr)
		FiltraLog( aLogErr, aRegErr[nErrInt])
	Next nErrInt	
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSRA()
Função que verifica se o funcionário é válido para integração
@author  Allyson Luiz Mesashi
@since   14/10/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSRA( cCNPJ, cToken )

Local aInfoFil 	:= {}
Local lRet		:= .T.

If fInfo( @aInfoFil, SRA->RA_FILIAL, cEmpAnt )
	cCNPJ := aInfoFil[08]
EndIf

If Empty(SRA->RA_CIC)
	If aScan( aLogIncon, { |x| x == STR0061 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0061)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0059 + SRA->RA_FILIAL+SRA->RA_MAT + STR0062)//"Filial + Mat: "##" sem CPF cadastrado."
	lRet := .F.
EndIf

If Empty(SRA->RA_EMAIL)
	If aScan( aLogIncon, { |x| x == STR0061 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0061)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0059 + SRA->RA_FILIAL+SRA->RA_MAT + STR0063)//"Filial + Mat: "##" sem e-mail cadastrado."
	lRet := .F.
EndIf

If Empty(SRA->RA_DDDCELU) .Or. Empty(SRA->RA_NUMCELU) 
	If aScan( aLogIncon, { |x| x == STR0061 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0061)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0059 + SRA->RA_FILIAL+SRA->RA_MAT + STR0065)//"Filial + Mat: "##" sem celular cadastrado."
	lRet := .F.
EndIf

//Validação para a FASE 1, existência do grupo PROTHEUS no CNPJ do funcionário
If !fVldGrupo( cCNPJ, cToken )
	If aScan( aLogIncon, { |x| x == STR0061 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0061)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0059 + SRA->RA_FILIAL+SRA->RA_MAT + STR0067 + cCNPJ)//"Filial + Mat: "##" desprezado porque não foi cadastrado manualmente um grupo no portal da Swile cujo nome seja o CNPJ da filial do empregado: "
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fEnvFun
Função que efetua a integração para Swile dos funcionarios
@author  Allyson Luiz Mesashi
@since   14/10/2022
/*/
//-------------------------------------------------------------------
Static Function fEnvFun( oJson, cToken, cErrInt )

Local aHeader	:= {}
Local cBody		:= ""
Local cPath		:= ""
Local cStatus	:= "2"
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local lAchou	:= .F.
Local lRet 		:= .F.
Local nIdFunc	:= 0
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Token " + cToken )
aAdd( aHeader, "Content-Type: application/json; charset=UTF-8" )

oClient:SetPath("/private/employee/list")

cBody := '{'
cBody += 	'"filter": "' + oJson['document'] + '"'
cBody += '}'
oClient:SetPostParams(cBody)

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	lAchou := ValType( oResult["totalSize"] ) == "N" .And. oResult["totalSize"] > 0
	If lAchou
		nIdFunc := oResult["employeeList"][1]["idEmployee"]
	EndIf
EndIf

cPath := Iif( lAchou, "/private/employee/update", "/private/employee/add" )
oClient:SetPath(cPath)

cBody := '{'
If !lAchou
	cBody += 	'"employeeList": ['
	cBody += 		'{'
Else
	cBody += 			'"idEmployee": ' + cValToChar(nIdFunc) + ','
EndIf
cBody += 				'"name": "' + oJson['name'] + '",'
cBody += 				'"document": "' + oJson['document'] + '",'
cBody += 				'"externalId": "' + oJson['externalId'] + '",'
cBody += 				'"phoneNumber": "' + oJson['phoneNumber'] + '",'
cBody += 				'"email": "' + oJson['email'] + '",'
If !lAchou
	cBody += 			'"workGroupName": "' + oJson['workGroupName'] + '",'
	cBody += 			'"corporateBranchDocument": "' + oJson['corporateBranchDocument'] + '",'
EndIf
cBody += 				'"gender": "' + oJson['gender'] + '",'
cBody += 				'"birthDate": "' + oJson['birthDate'] + '",'
cBody += 				'"status": "' + oJson['status'] + '"'
If !lAchou
	cBody += 		'}'
	cBody += 	']'
EndIf
cBody += '}'
oClient:SetPostParams( EncodeUTF8(cBody) )

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	If oResult["statusCode"] == 1
		cStatus := "1"
		lRet 	:= .T.
	EndIf
EndIf

cErrInt := DecodeUTF8( oClient:GetResult() )

fGravaRUC( "3", cStatus, cBody, cErrInt )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaRUC()
Função que efetua a gravação do lote na tabela RUC
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Static Function fGravaRUC( cTipo, cStatus, cBody, cRetorn )

If RUC->( RecLock("RUC", .T.) )
	RUC->RUC_TIPO  		:= cTipo
	RUC->RUC_DATINT		:= Date()
	RUC->RUC_HORINT		:= Time()
	RUC->RUC_STATUS		:= cStatus
	RUC->RUC_LOTE  		:= cBody
	RUC->RUC_RETORN 	:= cRetorn
	RUC->RUC_USER  		:= RetCodUsr()
	RUC->( MsUnLock() )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldGrupo
Função que efetua a validação de existência do grupo PROTHEUS no portal da Swile para o CNPJ do funcionário
Obs.: validação para a FASE 1, em que não há integração de grupo do Protheus para a Swile
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Static Function fVldGrupo( cCNPJ, cToken )

Local aHeader	:= {}
Local cBody		:= ""
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local lAchou	:= .F.
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Token " + cToken )
aAdd( aHeader, "Content-Type: application/json" )

oClient:SetPath("/private/workgroup/list")

cBody := '{'
cBody += 	'"filter": "' + cCNPJ + '"'
cBody += '}'
oClient:SetPostParams(cBody)

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	lAchou := ValType( oResult["totalSize"] ) == "N" .And. oResult["totalSize"] > 0
EndIf

Return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntPed
Realiza a integração da tabela SR0 de benefícios
@author  Allyson Luiz Mesashi
@since   24/10/2022
/*/
//-------------------------------------------------------------------
Static Function fIntPed(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaSR0 		:= SR0->( GetArea() )
Local aAuxPed		:= {}
Local aInfoFil		:= {}
Local aRegErr		:= {}
Local aRegInt		:= {}
Local cAliasQRY 	:= "IMPSR0"
Local cCodPedido	:= ""
Local cCodSwile		:= ""
Local cErrInt		:= ""
Local cFilQry		:= ""
Local cNFCNPJ		:= ""
Local cNomeFun		:= ""
Local cQuery		:= ""
Local nBenSwile		:= 0
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nFilMat		:= 0
Local nFuncs		:= 0
Local nIdFunc		:= 0
Local nInc			:= 0
Local nItens		:= 0
Local nPosCPF		:= 0
Local nPosFilMat	:= 0
Local nPosSwile		:= 0
Local nRegs			:= 0
Local nTotalPed		:= 0
Local nPedAux       := 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0049 + STR0068 )//"Iniciando Processamento..."##"Importação pedidos"
oSayProc2:SetText( STR0051 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery  += " INNER JOIN " + cTabSR0 + " SR0 ON " + FWJoinFilial( "SRA", "SR0" ) + " AND "
			cQuery	+=	" SR0.R0_MAT = SRA.RA_MAT AND SR0.D_E_L_E_T_ = ' ' "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
If !Empty(cFltPed)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltPed)) + " ) AND "
EndIf
If !Empty(cPerPed)
	cQuery 	+= "SR0.R0_PERIOD = '" + cPerPed + "' AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SR0.R0_FILIAL, SR0.R0_MAT, SR0.R_E_C_N_O_ AS SR0RECNO "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery  += " INNER JOIN " + cTabSR0 + " SR0 ON " + FWJoinFilial( "SRA", "SR0" ) + " AND "
			cQuery	+=	" SR0.R0_MAT = SRA.RA_MAT AND SR0.D_E_L_E_T_ = ' ' "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
If !Empty(cFltPed)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltPed)) + " ) AND "
EndIf
If !Empty(cPerPed)
	cQuery 	+= "SR0.R0_PERIOD = '" + cPerPed + "' AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' '"
cQuery 	+= "ORDER BY 1,2"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0069)//"Erro na integração de pedidos: "
	aAdd(aLogErr, STR0057)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		cErrInt := ""
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0052 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SR0->( dbGoTo( (cAliasQRY)->SR0RECNO ) )
		
		If fVldSR0( cToken, @cCodSwile, @cNomeFun, @nIdFunc )
			nPedAux++
			If ( nPosCPF := aScan( aAuxPed, { |x| x[1] == nIdFunc } ) ) == 0
				aAdd( aAuxPed, { nIdFunc, { { SR0->R0_FILIAL+SR0->R0_MAT } }, cNomeFun, { { cCodSwile, SR0->R0_VALCAL } } } )
			Else
				If ( nPosSwile := aScan( aAuxPed[nPosCPF, 4], { |x| x[1] == cCodSwile } ) ) == 0
					aAdd( aAuxPed[nPosCPF, 4], { cCodSwile, SR0->R0_VALCAL } )
				Else
					aAuxPed[nPosCPF, 4, nPosSwile, 2] += SR0->R0_VALCAL
				EndIf
				If ( nPosFilMat := aScan( aAuxPed[nPosCPF, 2], { |x| x[1] == SR0->R0_FILIAL+SR0->R0_MAT } ) ) == 0
					aAdd( aAuxPed[nPosCPF, 2], { SR0->R0_FILIAL+SR0->R0_MAT } )
				EndIf
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo
EndIf

If !Empty( aAuxPed )
	If fInfo( @aInfoFil, cFilCNPJ, cEmpAnt )
		cNFCNPJ := AllTrim( aInfoFil[08] )//M0_CGC
	EndIf

	For nFuncs := 1 To Len(aAuxPed)
		For nItens := 1 To Len(aAuxPed[nFuncs, 4])
			nTotalPed += aAuxPed[nFuncs, 4, nItens, 2]
		Next nItens
	Next nFuncs

	If fEnvPed(cToken, @cErrInt, aAuxPed, cNFCNPJ, dDtCred, dDtVcto, nTotalPed, @cCodPedido)
		aAdd(aRegInt, "")
		aAdd(aRegInt, STR0090 + cCodPedido)//"Código do pedido retornado pela Swile: "
		aAdd(aRegInt, STR0086 + Iif( cPaisLoc == "BRA", "R$ ", "" ) + Transform(nTotalPed, "@E 999,999.99" ) )//"Total geral do pedido incluído:"
		aAdd(aRegInt, STR0087)//"Funcionários incluídos no pedido:"
		For nFuncs := 1 To Len(aAuxPed)
			aAdd(aRegInt, " - " + STR0088)//"Matrícula(s) do funcionário - Nome:"
			For nFilMat := 1 To Len(aAuxPed[nFuncs, 2])
				aAdd(aRegInt, "   - " + aAuxPed[nFuncs, 2, nFilMat, 1] + " - " + aAuxPed[nFuncs, 3] )
			Next nFilMat
			aAdd(aRegInt, "     " + STR0089)//"Benefício(s) do funcionário: (código Swile - Valor)"
			For nBenSwile := 1 To Len(aAuxPed[nFuncs, 4])
				aAdd(aRegInt, "       - " + aAuxPed[nFuncs, 4, nBenSwile, 1] + " - " +  Iif( cPaisLoc == "BRA", "R$ ", "" ) + Transform(aAuxPed[nFuncs, 4, nBenSwile, 2] , "@E 999,999.99" ) )
			Next nBenSwile
		Next nFuncs
	Else
		aAdd(aRegErr, "")
		aAdd(aRegErr, cErrInt )
	EndIf
EndIf

If !Empty(aRegInt)
	aAdd(aLogImp, STR0070)//"Registros integrados de pedidos: "
	For nRegs := 1 To Len(aRegInt)
		aAdd(aLogImp, aRegInt[nRegs])
	Next nRegs
	nTotInteg += nPedAux
EndIf

If !Empty(aRegErr)
	aAdd(aLogErr, STR0069)//"Erro na integração de pedidos: "
	aAdd(aLogErr, STR0048)//"Obs.: erro completo retornado:"
	For nErrInt := 1 To Len(aRegErr)
		FiltraLog( aLogErr, aRegErr[nErrInt])
	Next nErrInt	
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaSR0 )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSR0()
Função que verifica se o benefício é válido para integração
@author  Allyson Luiz Mesashi
@since   24/10/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSR0( cToken, cCodSwile, cNomeFun, nIdFunc )

Local aArea		:= GetArea()
Local aAreaRFP	:= RFP->( GetArea() )
Local aAreaSRA	:= SRA->( GetArea() )
Local lRet		:= .T.

RFP->( dbSetOrder(1) )//RFP_FILIAL+RFP_TPVALE+RFP_CODIGO+RFP_TPBEN
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

If SRA->( dbSeek( SR0->R0_FILIAL + SR0->R0_MAT ) )
	cNomeFun := Iif( !Empty(SRA->RA_NOMECMP), AllTrim( SRA->RA_NOMECMP ), SRA->RA_NOME )
	If Empty( SRA->RA_CIC )
		If aScan( aLogIncon, { |x| x == STR0071 } ) == 0//"Inconsistências na integração de pedidos:"
			aAdd(aLogIncon, STR0071)//"Inconsistências na integração de pedidos:"
		EndIf
		If aScan( aLogIncon, { |x| x == STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0062 } ) == 0//"Filial + Mat: "##" sem CPF cadastrado."
			aAdd(aLogIncon, STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0062)//"Filial + Mat: "##" sem CPF cadastrado."
		EndIf
		lRet := .F.
	EndIf
Else
	If aScan( aLogIncon, { |x| x == STR0071 } ) == 0//"Inconsistências na integração de pedidos:"
		aAdd(aLogIncon, STR0071)//"Inconsistências na integração de pedidos:"
	EndIf
	If aScan( aLogIncon, { |x| x == STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0072 } ) == 0//"Filial + Mat: "##" não encontrada no cadastro da tabela SRA."
		aAdd(aLogIncon, STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0072)//"Filial + Mat: "##" não encontrada no cadastro da tabela SRA."
	EndIf
	lRet := .F.
EndIf

If lRet .And. Empty( nIdFunc := fVldId( cToken ) )
	If aScan( aLogIncon, { |x| x == STR0071 } ) == 0//"Inconsistências na integração de pedidos:"
		aAdd(aLogIncon, STR0071)//"Inconsistências na integração de pedidos:"
	EndIf
	If aScan( aLogIncon, { |x| x == STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0073 } ) == 0//"Filial + Mat: "##" com CPF não encontrado no Portal da Swile."
		aAdd(aLogIncon, STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0073)//"Filial + Mat: "##" com CPF não encontrado no Portal da Swile."
	EndIf
	lRet := .F.
EndIf

If RFP->( dbSeek( xFilial( "RFP", SR0->R0_FILIAL ) + SR0->R0_TPVALE + SR0->R0_CODIGO ) )
	If Empty( ( cCodSwile := Lower( AllTrim( RFP->RFP_CODSWI ) ) ) )
		If aScan( aLogIncon, { |x| x == STR0071 } ) == 0//"Inconsistências na integração de pedidos:"
			aAdd(aLogIncon, STR0071)//"Inconsistências na integração de pedidos:"
		EndIf
		aAdd(aLogIncon, STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0074 + SR0->R0_TPVALE + "-" + Iif( SR0->R0_TPVALE == "0", STR0083, Iif( SR0->R0_TPVALE == "1", STR0084, STR0085 ) ) + STR0075 + SR0->R0_CODIGO + STR0076)//"Filial + Mat: "##" com benefício do tipo: "##"VT"##"VR"##"VA"##" do código: " ## " sem preenchimento do campo RFP_CODSWI."
		lRet := .F.
	EndIf
Else
	If aScan( aLogIncon, { |x| x == STR0071 } ) == 0//"Inconsistências na integração de pedidos:"
		aAdd(aLogIncon, STR0071)//"Inconsistências na integração de pedidos:"
	EndIf
	aAdd(aLogIncon, STR0059 + SR0->R0_FILIAL+SR0->R0_MAT + STR0074 + SR0->R0_TPVALE + "-" + Iif( SR0->R0_TPVALE == "0", STR0083, Iif( SR0->R0_TPVALE == "1", STR0084, STR0085 ) ) + STR0075 + SR0->R0_CODIGO + STR0077)//"Filial + Mat: "##" com benefício do tipo: "##"VT"##"VR"##"VA"##" do código: " ## " não encontrado no cadastro da tabela RFP."
	lRet := .F.
EndIf

RestArea( aAreaRFP )
RestArea( aAreaSRA )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldId
Função que efetua a validação de existência do funcionário no portal da Swile
@author  Allyson Luiz Mesashi
@since   24/10/2022
/*/
//-------------------------------------------------------------------
Static Function fVldId( cToken )

Local aHeader	:= {}
Local cBody		:= ""
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local lAchou	:= .F.
Local nIdFunc	:= 0
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Token " + cToken )
aAdd( aHeader, "Content-Type: application/json" )

oClient:SetPath("/private/employee/list")

cBody := '{'
cBody += 	'"filter": "' + SRA->RA_CIC + '"'
cBody += '}'
oClient:SetPostParams(cBody)

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	lAchou := ValType( oResult["totalSize"] ) == "N" .And. oResult["totalSize"] > 0
	If lAchou
		nIdFunc := oResult["employeeList"][1]["idEmployee"]
	EndIf
EndIf

Return nIdFunc

//-------------------------------------------------------------------
/*/{Protheus.doc} fEnvPed
Função que efetua a integração para Swile dos pedidos
@author  Allyson Luiz Mesashi
@since   24/10/2022
/*/
//-------------------------------------------------------------------
Static Function fEnvPed( cToken, cErrInt, aItens, cNFCNPJ, dDtCred, dDtVcto, nTotalPed, cCodPedido )

Local aHeader	:= {}
Local cBody		:= ""
Local cStatus	:= "2"
Local cSWURL	:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Local lRet 		:= .F.
Local lCentury	:= __SetCentury("on")
Local nFunc		:= 0
Local nItens	:= 0
Local nVezes	:= 0
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Token " + cToken )
aAdd( aHeader, "Content-Type: application/json" )

oClient:SetPath("/private/order/create")

cBody := '{'
cBody += 	'"feeValue": 0,'
cBody += 	'"orderGroupList": '
cBody += 		'['
cBody += 			'{'
cBody += 				'"payerDocument": "' + cNFCNPJ + '",'
cBody += 				'"orderList": '
cBody += 					'['
cBody += 						'{'
cBody += 							'"creationOrderType": "BY_EXTERNAL_API",'
cBody += 							'"dtCredit": "' + dToC(dDtCred) + ' 10:00",'
cBody += 							'"dtDueDate": "' + dToC(dDtVcto) + '",'
cBody += 							'"valueCredit": ' + cValToChar(nTotalPed) + ','
cBody += 							'"employeeList": '
cBody += 								'['
For nFunc := 1 To Len(aItens)
	cBody += 								'{'
	cBody += 									'"idEmployee": ' + cValToChar( aItens[ nFunc, 1 ] ) + ','
	cBody += 									'"flexibleAmount": 0,'
	cBody += 									'"itemList": '
	cBody += 										'['
	For nItens := 1 To Len(aItens[ nFunc, 4 ])
		cBody += 										'{'
		cBody += 											'"code": "' + aItens[ nFunc, 4, nItens, 1 ] + '",'
		cBody += 											'"amount": ' + cValToChar( aItens[ nFunc, 4, nItens, 2 ] )
		If nItens == Len(aItens[ nFunc, 4 ])
			cBody += 									'}'
		Else
			cBody += 									'},'
		EndIf
	Next nItens
	cBody += 										']'
	If nFunc == Len(aItens)
		cBody += 							'}'
	Else
		cBody += 							'},'
	EndIf	
Next nFunc
cBody += 								']'
cBody += 						'}'
cBody += 					']'
cBody += 			'}'
cBody += 		']'
cBody += '}'
oClient:SetPostParams(cBody)	

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	If oResult["statusCode"] == 1
		cCodPedido 	:= oResult["orderCode"]
		cStatus 	:= Iif( ValType( oResult["idJob"] ) == "U", "1", "2" )
		If ValType( oResult["idJob"] ) == "N"
			oClient := FwRest():New(cSWURL)
			oClient:SetPath("/private/job/" + cValToChar( oResult["idJob"] ) + "/output" )
			While !lRet .And. nVezes < 100
				Sleep( 5000 )//5 segundos
				nVezes++
				If oClient:Get(aHeader)
					oResult:fromJson( oClient:GetResult() )
					If oResult["statusCode"] == 1 .And. oResult["job"]["status"] $ "PROCESSED/PROCESSED_WITH_ERRORS"
						cStatus	:= Iif( oResult["job"]["status"] == "PROCESSED", "1", "2" )
						lRet 	:= .T.
					EndIf
				EndIf
			EndDo
		EndIf
	EndIf
EndIf

cErrInt := DecodeUTF8( oClient:GetResult() )

fGravaRUC( "4", cStatus, cBody, cErrInt )

If !lCentury
	__SetCentury("off")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAut
Função que valida a autenticação no endpoint da Swile
@author  Allyson Luiz Mesashi
@since   19/04/2023
/*/
//-------------------------------------------------------------------
Static Function fVldAut()

DEFAULT lFirst  := .T.
DEFAULT lVldOk  := .T.

If lFirst
    lFirst := .F.
    fLogoutSwi()
    If !fTokenSwi()
        lVldOk := .F.    
    EndIf
EndIf

If !lVldOk
    Help( Nil, Nil, OemToAnsi(STR0001), Nil, OemToAnsi(STR0092), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0093) } ) //"Atenção"##"Não foi possível efetuar a autenticação na Swile"##"Solicite ao administrador uma revisão dos parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3"
EndIf

Return lVldOk
