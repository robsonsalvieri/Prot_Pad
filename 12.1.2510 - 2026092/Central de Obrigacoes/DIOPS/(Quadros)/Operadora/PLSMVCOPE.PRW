#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCOPE

Manutencao de Operadoras

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCOPE(lAuto)
	Local oBrowse	:= Nil
	Private CENUF	:= ""
	Private B8MN	:= ""
	Private B8MM	:= ""
	Private B8MS	:= ""
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8M')
	oBrowse:SetDescription("Operadoras") //Operadoras
	oBrowse:AddLegend( "B8M_CODOPE > ' '", "GREEN",	"Valido   - possui Número de Registro ANS" )
	oBrowse:AddLegend( "B8M_CODOPE = ' '", "RED",	"Invalido - Não possui Número de Registro ANS" )
	oBrowse:SetMenuDef( 'PLSMVCOPE' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Operadoras", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf


Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCOPE'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCOPE'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCOPE'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCOPE'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir"				, 'PLSRDOPER(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir

	// Permite importar Cadastro de Operadoras PLS (BA0) para a Central de Obrigações (B8M)
	If GetNewPar("MV_PLSATIV",.F.)	// PLS Ativo no sistema
		aAdd( aRotina, { "Import.PLS"		, 'PlLoadOper()'		, 0 , 3 , 0 , NIL } ) //Imprimir
	EndIf

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8M

@return oModel	objeto model criado

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8M 	:= FWFormStruct( 1, 'B8M', , )
	Local oStruB8W 	:= FWFormStruct( 1, 'B8W', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "Operadoras", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8MMASTER', , oStruB8M )
	oModel:AddGrid( 'B8WDETAIL', 'B8MMASTER', oStruB8W )
	oModel:SetRelation( 'B8WDETAIL', {;
		{'B8W_FILIAL','xFilial("B8W")'},;
		{'B8W_CODOPE','B8M_CODOPE'};
		}, B8W->(IndexKey(1)) )

	oModel:GetModel( 'B8MMASTER' ):SetDescription( "Operadoras" )
	oModel:GetModel( 'B8WDETAIL' ):SetDescription( "Municipios" )
	oModel:GetModel( 'B8WDETAIL' ):SetOptional(.T.)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8M

@return oView	objeto view criado

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCOPE' )
	Local oStruB8M := FWFormStruct( 2, 'B8M' )
	Local oStruB8W := FWFormStruct( 2, 'B8W' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8M' , oStruB8M , 'B8MMASTER' )
	oView:AddGrid( 'VIEW_B8W' , oStruB8W, 'B8WDETAIL' )
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )
	oView:SetOwnerView( 'VIEW_B8M', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B8W', 'INFERIOR' )
	oView:EnableTitleView( 'VIEW_B8M', 'Operadoras' )
	oView:EnableTitleView( 'VIEW_B8W', 'Municipios' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getB3MF3

Funcao que retorna a matriz de dados para os F3 do cadastro de operadora

@return oView	objeto view criado

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function getB3MF3(cTab)
	Local aTab			:= {}
	Local lGerArq       := FunName()=="PXMLDIOPSC" .And. !Empty(B8M->B8M_SEGMEN) .And. Alltrim(B8M->B8M_MODALI)=="AUTOG"
	Default cTab		:= 'S'

	Do Case

		Case cTab == 'N'//Natureza Jurídica da Operadora

			aAdd(aTab,{"ASSOC","Associação"})
			aAdd(aTab,{"DEPEX","Dependencia de empresa sediada no exterior"})
			aAdd(aTab,{"EMIND","Empresa individual"})
			aAdd(aTab,{"EMPUB","Empresa pública"})
			aAdd(aTab,{"FUNDA","Fundação"})
			aAdd(aTab,{"OUTRC","Outras com fins"})
			aAdd(aTab,{"OUTRS","Outras sem fins"})
			aAdd(aTab,{"SOCIA","Sociedade Anônima"})
			aAdd(aTab,{"SCIVL","Sociedade Civil com fins lucrativos"})
			aAdd(aTab,{"SCIVS","Sociedade Civil sem fins lucrativos"})
			aAdd(aTab,{"SCOOP","Sociedade Cooperativa"})
			aAdd(aTab,{"SCOTA","Sociedade por Cotas de Responsabilidade Ltda"})

		Case cTab == 'M'//Modalidade da Operadora

			aAdd(aTab,{"ADMIN","Administradora",			"administradora"})

			If lGerArq
				If Alltrim(B8M->B8M_SEGMEN)=="AUTRH"
					aAdd(aTab,{"AUTOG","Autogestão","autoGRH"})

				ElseIf Alltrim(B8M->B8M_SEGMEN)=="AUTMN"
					aAdd(aTab,{"AUTOG","Autogestão","autoGComMantenedor"})

				ElseIf Alltrim(B8M->B8M_SEGMEN)=="AUTSM"
					aAdd(aTab,{"AUTOG","Autogestão","autoGSemMantenedor"})
				EndIf

			Else
				aAdd(aTab,{"AUTOG","Autogestão",			"autoGComMantenedor"})
			EndIf

			aAdd(aTab,{"COOPM","Cooperativa médica",		"coopMedica"})
			aAdd(aTab,{"COOPO","Cooperativa odontológica",		"coopOdontologica"})
			aAdd(aTab,{"FILAN","Filantropia",			"filantropia"})
			aAdd(aTab,{"MEGRP","Medicina de grupo",			"medicinaGrupo"})
			aAdd(aTab,{"ODGRP","Odontologia de grupo",		"odontologiaGrupo"})
			//autoGSemMantenedor autoGRH

		Case cTab == 'S'//Segmentação da Operadora

			aAdd(aTab,{"SEM","(Sem enunciado)"})
			aAdd(aTab,{"ADMPL","Administradora de Planos"})
			aAdd(aTab,{"ADMSV","Administradora de Serviços"})
			aAdd(aTab,{"AUTMN","Autogestão com Mantenedor"})
			aAdd(aTab,{"AUTRH","Autogestão por RH"})
			aAdd(aTab,{"AUTSM","Autogestão sem Mantenedor"})
			aAdd(aTab,{"NPATR","Não Patrocinada"})
			aAdd(aTab,{"PATRM","Patrocinada Multipatrocinada"})
			aAdd(aTab,{"PATRS","Patrocinada Singular"})
			aAdd(aTab,{"SOM","Segmento Misto - SM"})
			aAdd(aTab,{"SOP","Segmento próprio - SP"})
			aAdd(aTab,{"SOT","Segmento terciário - ST (Odontologia de Grupo)"})
			aAdd(aTab,{"SPP","Segmento Primário Principal"})
			aAdd(aTab,{"SPS","Segmento primário subsidiário - SPS"})
			aAdd(aTab,{"SPSUS","Segmento primário principal / SUS - SPP/SUS"})
			aAdd(aTab,{"SSP","Segmento secundário principal - SSP"})
			aAdd(aTab,{"SSS","Segmento secundário subsidiário - SSS"})
			aAdd(aTab,{"ST","Segmento terciário","ST (Medicina de Grupo)"})

	EndCase

Return aTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F3B8M

Funcao cria o F3 para os campos Natureza, Modalidade e Segmentacao

@author timoteo.bega
@since 18/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function F3B8M(cTp,lAuto)
	Local cTitulo	:= ""
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
	Local lPlsMvcOpe:= FWISINCALLSTACK("PLSCENTOBR")
	Default cTp	:= 'S'
	Default lAuto   := .F.

	If cTp == 'N'//Natureza
		cTitulo := "Natureza Jurídica"
	ElseIf cTp == 'M'//Modalide
		cTitulo := "Modalidade"
	Else// cTp == 'S'//Segmentacao
		cTitulo := "Segmentação"
	EndIf

	//coloca virgula no comeco (caso tenha inicializador padrao)
	cDado := AllTrim(cDado)
	If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
		cDado += ","
	EndIf

	aGrupos := getB3MF3(cTp)

	For nInd := 1 To Len(aGrupos)
		aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],Iif(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
	Next

	If !lAuto
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 To 25,88 OF GetWndDefault()
		@ 020,012 SAY oSay PROMPT "Selecione uma "+cTitulo SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione uma atividade

		oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
		oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
		oGrupo:AddColumn(TcColumn():New('Codigo'	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
		oGrupo:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))	//Descricao"
		oGrupo:SetArray(aLista)
		oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=35 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )
	EndIf

	lRet := !empty(cDado)

	If nOpca == 1 .Or. lAuto
		cDado := ""
		For nInd := 1 To Len(aLista)
			If aLista[nInd,3]
				cDado := aLista[nInd,1]
			EndIf
		Next
	EndIf

	If Subs(cDado,4,1) == ","
		cDado := Subs(cDado,1,3)
	EndIf

	IF lAuto .And. Alltrim(cTitulo) == "Modalidade"   //na automação não é possível preencher o cdado, por isso eu ja retorno lret = .t.
		lRet:=.T.
	EndIf

	If !lAuto .And. (Inclui .Or. Altera) .And. !Empty(cDado)

		If cTp == 'N'//Natureza
			B8MN := Alltrim(cDado)
			M->B8M_NATJUR := Alltrim(cDado)
			M->B8M_DNATJU := B8MDescri(cTp)
			iif(lPlsMvcOpe,FWFldPUT("B8M_NATJUR",Alltrim(cDado)),"")
			iif(lPlsMvcOpe,FWFldPUT("B8M_DNATJU",B8MDescri(cTp)),"")
		ElseIf cTp == 'M'//Modalide
			B8MM := Alltrim(cDado)
			M->B8M_MODALI := Alltrim(cDado)
			M->B8M_DMODAL := B8MDescri(cTp)
			iif(lPlsMvcOpe,FWFldPUT("B8M_MODALI",Alltrim(cDado)),"")
			iif(lPlsMvcOpe,FWFldPUT("B8M_DMODAL",B8MDescri(cTp)),"")
		Else// cTp == 'S'//Segmentacao
			B8MS := Alltrim(cDado)
			M->B8M_SEGMEN := Alltrim(cDado)
			M->B8M_DSEGME := B8MDescri(cTp)
			iif(lPlsMvcOpe,FWFldPUT("B8M_SEGMEN",Alltrim(cDado)),"")
			iif(lPlsMvcOpe,FWFldPUT("B8M_DSEGME",B8MDescri(cTp)),"")
		EndIf

		lRet := .T.

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8MDescri

Funcao retorna a descricao de acordo com a natureza, modalidade ou segmentacao selecionada

@author timoteo.bega
@since 18/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8MDescri(cTp,nMov,lAuto)
	Local aDescri := {}
	Local cDescri	:= ""
	Local cCod		:= ""
	Local nPos		:= 0
	Default cTp		:= "S"
	Default nMov	:= 0
	Default lAuto   := .T.

	aDescri := getB3MF3(cTp)

	If nMov == 0 .and. ( Inclui .Or. Altera )

		If cTp == 'N'
			cCod := M->B8M_NATJUR
		ElseIf cTp == 'M'
			cCod := M->B8M_MODALI
		Else
			cCod := M->B8M_SEGMEN
		EndIf

	Else

		If cTp == 'N'
			cCod := B8M->B8M_NATJUR
		ElseIf cTp == 'M'
			cCod := B8M->B8M_MODALI
		Else
			cCod := IIF(lAuto,"ADMPL",B8M->B8M_SEGMEN)
		EndIf

	EndIf

	nPos :=	aScan(aDescri,{ |x| x[1] == AllTrim(cCod)})
	If nPos > 0
		cDescri := AllTrim(aDescri[nPos,2])
	EndIf

Return cDescri

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8MOPE

Função criada para validar se um determinado numero de registro ja foi cadastrado

@author timoteo.bega
@since 11/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function B8MOPE(lAuto)
	Local lRet    := .T.
	Default lAuto := .F.

	If !ExistChav("B8M",IIF (lAuto,"417505",M->B8M_CODOPE),1)
		lRet := .F.
		If !lAuto
			Help( ,, 'HELP',,"Número de registro de operadora já cadastrado! [" + M->B8M_CODOPE + "]", 1, 0)
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8MTagXML

Funcao retorna a string principal do xml cadastral de acordo com a modalidade

@author timoteo.bega
@since 18/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8MTagXML(cTab,cCod)
	Local cNomeTag	:= ""
	Local aTag		:= ""
	Default cTab	:= "S"
	Default cCod	:= ""

	aTag := getB3MF3(cTab)

	nPos :=	aScan(aTag,{ |x| x[1] == AllTrim(cCod)})

	If nPos > 0 .And. Len(aTag[nPos]) >= 3
		cNomeTag := AllTrim(aTag[nPos,3])
	EndIf

Return cNomeTag


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegOpe

Retorna array de regras para validar o quadro Operadora de Planos de Saúde

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegOpe()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	aRegras := { getTabOpe(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabOpe

Retorna tabela do quadro Operadora de Planos de Saúde

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabOpe()
return "B8M"


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLLOADOPER

Carrega Operadoras do sistema PLS para a Central de Obrigações

@author Roger C
@since 13/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PlLoadOper(lAuto)
	Local cSQL	:= ""
	Local aTab	:= {}
	Local aArea	:= GetArea()
	Local lRet  := .F.
	Default lAuto := .F.

	cSQL := " SELECT BA0_SUSEP, BA0_CGC, BA0_NOMINT, BA0_NATJUR, BA0_SEGMEN, BA0_MODALI, R_E_C_N_O_ AS Recno "
	cSQL += " FROM " + RetSqlName("BA0") + " BA0 "
	cSQL += " WHERE BA0_FILIAL = '"+xFilial("BA0")+"' "
	cSQL += " AND BA0_SUSEP > '      ' "
	cSQL += " AND BA0.D_E_L_E_T_ = ' '  "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBOPE",.F.,.T.)
	TcSetField("TRBOPE", "Recno",  "N", 16, 2 )

	B8M->(dbSetOrder(1))
	While !TRBOPE->(Eof())

		BA0->(DbGoto(TRBOPE->Recno))
		If !B8M->(msSeek(xFilial('B8M')+TRBOPE->BA0_SUSEP,.F.))
			If !lAuto
				RecLock('B8M',.T.)
				B8M->B8M_FILIAL	:= xFilial('B8M')
				B8M->B8M_CODOPE	:= TRBOPE->BA0_SUSEP
				B8M->B8M_CNPJOP	:= TRBOPE->BA0_CGC
				B8M->B8M_RAZSOC	:= TRBOPE->BA0_NOMINT
				B8M->B8M_NOMFAN	:= TRBOPE->BA0_NOMINT
				B8M->B8M_NATJUR	:= BA0->BA0_NATJUR		// SX5 - B8
				B8M->B8M_SEGMEN	:= BA0->BA0_SEGMEN		// SX5 - BD
				B8M->B8M_MODALI	:= BA0->BA0_MODALI		// SX5 - BA
				B8M->(msUnlock())
			Else
				lRet:= .T.
			EndIf
		EndIf

		TRBOPE->(DbSkip())

	Enddo

	TRBOPE->(DbCloseArea())
	RestArea(aArea)

Return lRet

