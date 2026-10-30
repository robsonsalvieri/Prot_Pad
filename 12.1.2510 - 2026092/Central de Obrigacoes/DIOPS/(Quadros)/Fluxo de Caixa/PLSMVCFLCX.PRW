#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCFLCX

Manutencao de Fluxo de Caixa

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCFLCX(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	Private B8HF3	:= ""

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8H')
	oBrowse:SetDescription("DIOPS - Fluxo de Caixa")
	oBrowse:AddLegend( "B8H_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8H_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8H_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B8H_FILIAL=B3D->B3D_FILIAL .And. B8H_CODOPE=B3D->B3D_CODOPE .And. B8H_CODOBR=B3D->B3D_CDOBRI .And. B8H_ANOCMP=B3D->B3D_ANO .And. B8H_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCFLCX' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Fluxo de Caixa", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8H", B8H->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCFLCX'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCFLCX'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCFLCX'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDFLCX(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("4")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabFlx())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCFLCX'   	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8H

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8H 	:= FWFormStruct( 1, 'B8H', , )
	Local oModel		:= Nil
	Local bPreValida	:= {|oModel| .T. }	// PLSVALBAL(oModel) }
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8HMASTER', 'B8H_CODOPE', 'B8H_CODOBR', 'B8H_CDCOMP', 'B8H_ANOCMP', 'B8H_REFERE', 'B8H_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - Fluxo de Caixa", bPreValida/*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8HMASTER', , oStruB8H )
	oModel:GetModel( 'B8HMASTER' ):SetDescription( "DIOPS - Fluxo de Caixa" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8H

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCFLCX' )
	Local oStruB8H := FWFormStruct( 2, 'B8H' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8H' , oStruB8H , 'B8HMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8H', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8H', 'DIOPS - Fluxo de Caixa' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegrasBal

Retorna array de regras para validar o fluxo de caixa

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegFlx()

	local aRegrasAll := {}
	local aRegrasBl := {}
	local aRegras := {}

	aAdd( aRegrasAll, {"FC01","    ","FluxCaixaA()", "Código do Item do Fluxo de Caixa Incorreto.", "Verifique a Tabela de Domínio da ANS para Códigos de Fluxo de Caixa.", ""} )
	aAdd( aRegrasBl, {"FC02","    ","FluxCaixaB()", "Valor apurado diferente do valor encontrado no Balancete.", "Verifique o valor da conta contábil 121 informado no balancete.", ""} )
	aAdd( aRegrasAll,{"FC03","    ","FluxCaixaC()", "Código do Fluxo de Caixa é Redutor, o valor deverá ser menor ou igual a zero.", "Verificar se o Código do Fluxo de Caixa é Redutor, esses codigos tem o sinal (-) e precede o valor.", ""} )
	aRegras := { getTabFlx(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabFlx

Retorna tabela do quadro

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabFlx()
return "B8H"

Function B8HDescri(cCod,cTipo)
	Local aDescri := GetTabFLCX()
	Local cDescri	:= ''
	Local nPos		:= 0
	Default cCod	:= ''
	Default cTipo	:= ''

	If Empty(cCod)
		cCod := IIf( INCLUI, M->B8H_CODIGO, B8H->B8H_CODIGO )
	EndIf

	nPos :=	aScan(aDescri,{ |x| x[1] == cCod})
	If nPos > 0
		cDescri := aDescri[nPos,2]
	EndIf

Return cDescri

Function GetTabFLCX()
	Local cDescri	:= ""
	Local aDescri	:= {}
	Local nPos		:= 0

	// ATIVIDADES OPERACIONAIS
	aAdd(aDescri,{"101","Recebimentos de Plano Saúde (+)"})
	aAdd(aDescri,{"102","Resgate de Aplicações Financeiras (+)"})
	aAdd(aDescri,{"103","Recebimentos de Juros de Aplicações Financeiras (+)"})
	aAdd(aDescri,{"104","Outros Recebimentos Operacionais (+)"})
	aAdd(aDescri,{"105","Pagamentos a Fornecedores/Prestadores de Serviço de Saúde (-)"})
	aAdd(aDescri,{"106","Pagamentos de Comissões (-)"})
	aAdd(aDescri,{"107","Pagamentos de Pessoal (-)"})
	aAdd(aDescri,{"108","Pagamentos de Pró-Labore (-)"})
	aAdd(aDescri,{"109","Pagamentos de Serviços Terceiros (-)"})
	aAdd(aDescri,{"110","Pagamentos de Tributos (-)"})
	aAdd(aDescri,{"111","Pagamentos de Processos Judiciais (-) (Cíveis/Trabalhistas/Tributárias)"})
	aAdd(aDescri,{"112","Pagamentos de Aluguel (-)"})
	aAdd(aDescri,{"113","Pagamentos de Promoção/Publicidade (-)"})
	aAdd(aDescri,{"114","Aplicações Financeiras (-)"})
	aAdd(aDescri,{"115","Outros Pagamentos Operacionais (-)"})

	// ATIVIDADES DE INVESTIMENTO
	aAdd(aDescri,{"201","Recebimentos de Venda de Ativo Imobilizado - Hospitalar (+)"})
	aAdd(aDescri,{"202","Recebimentos de Venda de Ativo Imobilizado - Outros (+)"})
	aAdd(aDescri,{"203","Recebimentos de Venda de Investimentos (+)"})
	aAdd(aDescri,{"204","Recebimentos de Dividendos (+)"})
	aAdd(aDescri,{"205","Outros Recebimentos das Atividades de Investimento (+)"})
	aAdd(aDescri,{"206","Pagamentos de Aquisição de Ativo Imobilizado - Hospitalar (-)"})
	aAdd(aDescri,{"207","Pagamentos de Aquisição de Ativo Imobilizado - Outros (-)"})
	aAdd(aDescri,{"208","Pagamentos Relativos ao Ativo Intangível (-)"})
	aAdd(aDescri,{"209","Pagamentos de Aquisição de Participação em Outras Empresas (-)"})
	aAdd(aDescri,{"210","Outros Pagamentos das Atividade de Investimento (-)"})

	// ATIVIDADES DE FINANCIAMENTO
	aAdd(aDescri,{"301","Integralização Capital em Dinheiro (+)"})
	aAdd(aDescri,{"302","Recebimento Empréstimos/Financiamentos (+)"})
	aAdd(aDescri,{"303","Títulos Descontados (+)"})
	aAdd(aDescri,{"304","Outros Recebimentos das Atividades de Financiamento (+)"})
	aAdd(aDescri,{"305","Pagamentos de Juros - Empréstimos/Financiamentos/Leasing (-)"})
	aAdd(aDescri,{"306","Pagamentos de Amortização - Empréstimos/Financiamentos/Leasing (-)"})
	aAdd(aDescri,{"307","Pagamento de Participação nos Resultados (-)"})
	aAdd(aDescri,{"308","Outros Pagamentos das Atividades de Financiamento (-)"})

Return aDescri

Function F3B8H(lAuto)
	Local cTitulo	:= "Descrição da Atividade"
	Local nInd		:= 0
	Local nPos		:= 0
	Local nQtd		:= 0
	Local bChk		:= {|| nQtd := PlsCntLst(aLista) }
	Local aLista	:= {}
	Local aGrupos	:= {}
	Local nOpca		:= 0
	Local bOK		:= { || nOpca := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local oDlg		:= Nil
	Local oGrupo	:= Nil
	Local lRet		:= .F.
	Default lAuto   := .F.

	//coloca virgula no comeco (caso tenha inicializador padrao)
	cDado := AllTrim(cDado)
	If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
		cDado += ","
	EndIf

	aGrupos := GetTabFLCX()

	For nInd := 1 To Len(aGrupos)
		aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],Iif(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
	Next
	If !lAuto
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 To 25,88 OF GetWndDefault()
		@ 020,012 SAY oSay PROMPT "Selecione uma atividade" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione uma atividade

		oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
		oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
		oGrupo:AddColumn(TcColumn():New('Codigo'	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
		oGrupo:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))	//Descricao"
		oGrupo:SetArray(aLista)
		oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=35 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )

	EndIf

	If lAuto
		cDado += "101"
	EndIf

	lRet := !empty(cDado)

	If lAuto .Or. nOpca == 1
		cDado := ""
		For nInd := 1 To Len(aLista)
			If aLista[nInd,3]
				cDado += aLista[nInd,1]+","
			EndIf
		Next
	EndIf

	If Subs(cDado,4,1) == ","
		cDado := Subs(cDado,1,3)
	EndIf

	If !lAuto .And. Inclui .And. !Empty(cDado)
		M->B8H_CODIGO := Alltrim(cDado)
		M->B8H_DESCRI := B8HDescri()
		B8HF3 := Alltrim(cDado)
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetComFLCX

Retorna opções para o BOX do campo

@author José Paulo
@since 13/06/2019
/*/
//--------------------------------------------------------------------------------------------------

Function GetComFLCX()
	Local cDescri	:= ""

	cDescri:="101=Recebimentos de Plano Saúde (+);102=Resgate de Aplicações Financeiras (+);103=Recebimentos de Juros de Aplicações Financeiras (+);104=Outros Recebimentos Operacionais (+);"
	cDescri+="105=Pagamentos a Fornecedores/Prestadores de Serviço de Saúde (-);106=Pagamentos de Comissões (-);107=Pagamentos de Pessoal (-);108=Pagamentos de Pró-Labore (-);109=Pagamentos de Serviços Terceiros (-);"
	cDescri+="110=Pagamentos de Tributos (-);111=Pagamentos de Processos Judiciais (-) (Cíveis/Trabalhistas/Tributárias);112=Pagamentos de Aluguel (-);113=Pagamentos de Promoção/Publicidade (-);"
	cDescri+="114=Aplicações Financeiras (-);115=Outros Pagamentos Operacionais (-);201=Recebimentos de Venda de Ativo Imobilizado - Hospitalar (+);202=Recebimentos de Venda de Ativo Imobilizado - Outros (+);"
	cDescri+="203=Recebimentos de Venda de Investimentos (+);204=Recebimentos de Dividendos (+);205=Outros Recebimentos das Atividades de Investimento (+);206=Pagamentos de Aquisição de Ativo Imobilizado - Hospitalar (-);"
	cDescri+="207=Pagamentos de Aquisição de Ativo Imobilizado - Outros (-);208=Pagamentos Relativos ao Ativo Intangível (-);209=Pagamentos de Aquisição de Participação em Outras Empresas (-);"
	cDescri+="210=Outros Pagamentos das Atividade de Investimento (-);301=Integralização Capital em Dinheiro (+);302=Recebimento Empréstimos/Financiamentos (+);303=Títulos Descontados (+);"
	cDescri+="304=Outros Recebimentos das Atividades de Financiamento (+);305=Pagamentos de Juros - Empréstimos/Financiamentos/Leasing (-);306=Pagamentos de Amortização - Empréstimos/Financiamentos/Leasing (-);"
	cDescri+="307=Pagamento de Participação nos Resultados (-);308=Outros Pagamentos das Atividades de Financiamento (-);"

Return cDescri
