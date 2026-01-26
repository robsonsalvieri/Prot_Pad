#INCLUDE "PLSMGER.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSA260.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "hat-actions.ch"
#INCLUDE 'FWMBROWSE.CH'

/*/{Protheus.doc} PLS260COFZ
Substitui a função PLS260COFP
Valida no XB a consulta B43 . Trata o num. contrato
@author DEV TOTVS.
@since 05/08/2019
@version P12
/*/
Function PLS260COFZ(lHelp,oModel,cCodFor,nTipo)

Local lRet    	:= .T.
Local cEmp    	:= ""
Local cCodPlano := ""
Local cVerPlano := ""
Local cConEmp   := ""
Local cNumCom   := ""
Local cVerCon   := ""
Local cSubCon   := ""
Local cVerSub   := ""

Default lHelp 	:= .T.
Default cCodFor := If(oModel:cID == "PLSA260FD3PLANO",oModel:GetModel('MasterBA3'):GetValue('BA3_FORPAG'),oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG'))
Default nTipo   := 1


If oModel:cID == "PLSA260FD3PLANO"
	cEmp  	  := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') + oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cVerPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_VERSAO')
	cConEmp   := BA3->BA3_CONEMP
	cNumCom   := BA3->BA3_NUMCON
	cVerCon   := BA3->BA3_VERCON
	cSubCon   := BA3->BA3_SUBCON
	cVerSub   := BA3->BA3_VERSUB
Else
	cEmp  	  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') + oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cNumCom   := ""//oModel:GetModel('BA3DETAIL'):GetValue('BA3_NUMCON')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
Endif

BG9->(DBSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+cEmp))

If BG9->BG9_TIPO == "2"
	lRet := PLSA260FPG(cCodPlano,cVerPlano,SubStr(cEmp,1,4),SubStr(cEmp,5,4),cConEmp,cCodFor,lHelp,nTipo,cVerCon,cSubCon,cVerSub,cCodPlano,cVerPlano)
Else
	lRet := PLSA260FPG(cCodPlano,cVerPlano,SubStr(cEmp,1,4),SubStr(cEmp,5,4),AllTrim(cNumCom),cCodFor,lHelp,nTipo,cVerCon,cSubCon,cVerSub,cCodPlano,cVerPlano)
Endif

DBSelectArea("BJ1")
Return(lRet)

/*/{Protheus.doc} PLSABA3MVC
Substitui a função PLSA260BA3
Valida a data analisando a versao do plano no contrato
@author DEV TOTVS
@since 06/08/2019
@version P12
/*/
Function PLSABA3MVC(oModel,nModel)

Local lRet		:= .T.
Local cChave    := ""
Local cCodPlano := ""
Local cVerPlano := ""
Local cConEmp   := ""
Local cVerCon   := ""
Local cSubCon   := ""
Local cVerSub   := ""
Local lAtuVar   := .T.

Local dDataBas  := date()

Default oModel  := FwModelActive()
DeFault nModel	:= 1 // 1 Vem dos modelos BA3DETAIL e os demais BA1MASTER


If nModel = 1 .and. oModel:cID <> "PLSA260FD3PLANO"
	cChave    := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') + oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	
	If !Empty(oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO'))
		cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Else
		oModel:LoadValue( 'BA3DETAIL','BA3_VERSAO',BI3->BI3_VERSAO )
		cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	EndIf
	 
	dDataBas  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_DATBAS')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
	dDataBas  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_DATBAS')
	lAtuVar := .T.
ElseIf nModel = 1 .and. oModel:cID == "PLSA260FD3PLANO"
	cChave    := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') + oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cVerPlano := BA3->BA3_VERSAO
	dDataBas  := BA3->BA3_DATBAS
	cConEmp   := BA3->BA3_CONEMP
	cVerCon   := BA3->BA3_VERCON
	cSubCon   := BA3->BA3_SUBCON
	cVerSub   := BA3->BA3_VERSUB
	dDataBas  := BA3->BA3_DATBAS
	lAtuVar := .T.

Else
	cChave 	  := BA1->(BA1_CODINT+BA1_CODEMP) //Campos estaticos eu acesso direto a tabela
	cCodPlano := oModel:GetModel('BA1MASTER'):GetValue('BA1_CODPLA')
	cVerPlano := If(!Empty(oModel:GetModel('BA1MASTER'):GetValue('BA1_VERSAO')),oModel:GetModel('BA1MASTER'):GetValue('BA1_VERSAO'),"001")
	cConEmp   := BA1->BA1_CONEMP
	cVerCon   := BA1->BA1_VERCON
	cSubCon   := BA1->BA1_SUBCON
	cVerSub   := BA1->BA1_VERSUB
	lAtuVar   := .F.

Endif


BG9->(DBSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+cChave))

lRet    := PLS260PLAMvc(cCodPlano,dDataBas,SubStr(cChave,1,4),SubStr(cChave,5,4),cConEmp,cVerCon,cSubCon,cVerSub, lAtuVar, , cVerPlano,Empty(cSubCon)  ) [1]

Return(lRet)

/*/{Protheus.doc} PLSA260GCMvc
Substitui a função PLSA260GCF
BA3_CODPLA - Validacao de campo
@author DEV TOTVS
@since 06/08/2019
@version P12
/*/
Function PLSA260GCMvc(oModel,lDireto)

Local cCodPlano := ""
Local cChaveBI3 := ""
Local cTipOUS   := ""
Local cCodEmp   := ""
Local cVerPlano := ""
Local cForPag   := ""
Local cForCTX   := ""
Local cCodInt   := ""
Local cConEmp   := ""
Local cSubCon   := ""
Local cVerCon   := ""
Local cVerSub   := ""

Default lDireto := .F.

If oModel:cID == "PLSA260FD3PLANO"

	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cChaveBI3 := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') +cCodPlano+oModel:GetModel('MasterBA3'):GetValue('BA3_VERSAO')
	cCodEmp   := oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cVerPlano := BA3->BA3_VERSAO
	cForPag   := oModel:GetModel('MasterBA3'):GetValue('BA3_FORPAG')
	cForCTX   := oModel:GetModel('MasterBA3'):GetValue('BA3_FORCTX')
	cCodInt   := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT')
	cTipOUS   := BA3->BA3_TIPOUS
	cConEmp   := BA3->BA3_CONEMP
	cSubCon   := BA3->BA3_SUBCON
	cVerCon   := BA3->BA3_VERCON
	cVerSub   := BA3->BA3_VERSUB
Else
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	cChaveBI3 := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') +cCodPlano+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cTipOUS   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_TIPOUS')
	cCodEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cForPag   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG')
	cForCTX   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORCTX')
	cCodInt   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
Endif


BI3->( dbSetorder(01) )
If BI3->( MsSeek(xFilial("BI3")+cChaveBI3) ) .and. BI3->BI3_STATUS == '2'
	If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
		Help("",1,"PLSSITANS")
	Else
		Help("",1,"PLSA260003")
	Endif
	Return(.F.)
Endif


If cTipOUS == "1" .and. !Empty(cForPag)//PF
	aRet := PLFORPAGPF(cCodPlano,cVerPlano, cForPag, cForCTX, lDireto, cCodInt)
	//forço através do LoadValue para não que seja feita validação de Dicionario
	If oModel:cID == "PLSA260FD3PLANO"

		oModel:LoadValue( 'MasterBA3','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'MasterBA3','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'MasterBA3','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'MasterBA3','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_RATSAI', AllTrim(aRet[5]) )

	Else
		oModel:LoadValue( 'BA3DETAIL','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_MODPAG', AllTrim(aRet[4]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_RATSAI', AllTrim(aRet[5]) )
	Endif					
	
	
ElseIf cTipOUS == "2" .and. !Empty(cForPag) //PJ
	//Forma de Cobranca Grp Empresa	
	aRet := PLFORPAGPJ(cCodPlano,cVerPlano, cForPag, cForCTX, lDireto, cCodEmp, cConEmp, cVerCon, cSubCon, cVerSub, cCodInt)
	//forço através do LoadValue para não que seja feita validação de Dicionario
	If oModel:cID == "PLSA260FD3PLANO"

		oModel:LoadValue( 'MasterBA3','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'MasterBA3','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'MasterBA3','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'MasterBA3','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_RATSAI', AllTrim(aRet[5]) )
	Else	

		oModel:LoadValue( 'BA3DETAIL','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_MODPAG', AllTrim(aRet[4]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_RATSAI', AllTrim(aRet[5]) )	
	Endif	
				
Endif

Return(.T.)




/*/{Protheus.doc} PLS260CAMPOS
Tratamento para ajustar os campos a serem utilizados nas telas.
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260CAMPOS(cCampo, cAlias,cFolder)

Local lRet		:= .F.
Local cSXCampo 	:= "X3_FOLDER"

If cAlias == "BA3" .and. cFolder == 'Cobranca'

	If GetSx3Cache(cCampo,"X3_FOLDER") == '6' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.	
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'Comercial'
	If GetSx3Cache(cCampo,cSXCampo) == '5' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF


ElseIf cAlias == "BA3" .and. cFolder == 'Plano'
	If GetSx3Cache(cCampo,cSXCampo) == '2' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC" )
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'ANS'
	If GetSx3Cache(cCampo,cSXCampo) == '3' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'OUTROS'
	If GetSx3Cache(cCampo,cSXCampo) == ' ' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		If cCampo <> 'BA3_GRPFAM'
			lRet := .T.
		Endif
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'Cadastro'
	If GetSx3Cache(cCampo,cSXCampo) == '1' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'LOG'
	If GetSx3Cache(cCampo,cSXCampo) == '7' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA1" .and. cFolder == 'Pessoais'
	if GetSx3Cache(cCampo,cSXCampo) == '1' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Plano'
	if GetSx3Cache(cCampo,cSXCampo) == '3' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" ;
	  		.or. cCampo == "BA1_DATINC")
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Cobranca'	
	if GetSx3Cache(cCampo,cSXCampo) == '4' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'ANS'
	if GetSx3Cache(cCampo,cSXCampo) == '5' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'OUTROS'
	if GetSx3Cache(cCampo,cSXCampo) == '6' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Parcelamento'
	if GetSx3Cache(cCampo,cSXCampo) == '7' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif


ElseIf cAlias == "BA1" .and. cFolder == 'Demais'
	if GetSx3Cache(cCampo,cSXCampo) == ' ' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Transferencia'
	if GetSx3Cache(cCampo,cSXCampo) == '1' .And. (  cCampo == "BA1_NOMUSR" .or. cCampo == "BA1_DATTRA"  .or.  cCampo == "BA1_TRADES" .or. cCampo == "BA1_TRAORI")																			  								 
		lRet := .T.
	endif
EndIF

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Menu do grupo familiar em MVC
@author DEV TOTVS
@since 02/08/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSA260MENU(nOpMenu, lAutomato, nOperation)

	local cTitle := ""

	default nOpMenu := 0
	default lAutomato := .f.
	default nOperation := MODEL_OPERATION_UPDATE

	cTitle := iif(nOperation == MODEL_OPERATION_VIEW, "Visualização", "Edição")

	BA3->(dbSetOrder(1))
	BA3->(msSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

	do case
		case nOpMenu == 1 // Forma de Cobrança da Familia
			FWExecView(cTitle, 'PLSA260BJK', nOperation,, { || .T.} )

		case nOpMenu == 2 // Dados da Cobrança da Familia
			FWExecView(cTitle, 'PLSA260FD1COB', nOperation,, { || .T.} )

		case nOpMenu == 3 // Dados Comerciais da Familia
			FWExecView(cTitle, 'PLSA260FD2COME', nOperation,, { || .T.} )

		case nOpMenu == 4 // Logs
			FWExecView(cTitle, 'PLSA260FD7LOGS', nOperation,, { || .T. } )

		case nOpMenu == 5 // Dados do Plano da Familia
			FWExecView(cTitle, 'PLSA260FD3PLANO', nOperation,, { || .T. } )

		case nOpMenu == 6 // Dados da ANS
			FWExecView(cTitle, 'PLSA260FD4ANS', nOperation,, { || .T. } )

		case nOpMenu == 7 // Outros Dados
			FWExecView(cTitle, 'PLSA260FD5OUTROS', nOperation,, { || .T. } )

		case nOpMenu == 8 // Demais Dados Cadastrais
			FWExecView(cTitle, 'PLSA260FD6DEMAIS', nOperation,, { || .T. } )

		case nOpMenu == 9 // Dados Pessoais	
			FWExecView(cTitle, 'PLSA260FD8BA1', nOperation,, { || .T. } )

		case nOpMenu == 10 // Relativos ao Plano
			FWExecView(cTitle, 'PLSA260FD9BA1', nOperation,, { || .T. } )

		case nOpMenu == 11 // Dados da Cobrança	
			FWExecView(cTitle, 'PLSA260FDABA1', nOperation,, { || .T. } )

		case nOpMenu == 12 // Dados da ANS
			FWExecView(cTitle, 'PLSA260FDBBA1', nOperation,, { || .T. } )

		case nOpMenu == 13 // Outros Dados
			FWExecView(cTitle, 'PLSA260FDCBA1', nOperation,, { || .T. } )

		case nOpMenu == 14 // Regras de Parcelamento
			FWExecView(cTitle, 'PLSA260FDDBA1', nOperation,, { || .T. } )

		case nOpMenu == 15 // Outras Informações
			FWExecView(cTitle, 'PLSA260FDEBA1', nOperation,, { || .T. } )

		case nOpMenu == 16 // Taxa de Adesão
			FWExecView(cTitle, 'PLSA260BJL', nOperation,, { || .T. } )

		case nOpMenu == 17 // Gratuidade
			FWExecView(cTitle, 'PLSA260BH5', nOperation,, { || .T. } )

		case nOpMenu == 18 // Opcional do Beneficiario
			FWExecView(cTitle, 'PLSA260BF4', nOperation,, { || .T. } )

		case nOpMenu == 19 // Gratuidade do Beneficiario
			FWExecView(cTitle, 'PLSA260BH6', nOperation,, { || .T. } )

		case nOpMenu == 20	// Grupo de Cobertura - Cobertura
			FWExecView(cTitle, 'PLSA260BFC', nOperation,, { || .T. } )

		case nOpMenu == 21 // Grupo de Cobertura - Procedimentos
			FWExecView(cTitle, 'PLSA260BFD', nOperation,, { || .T. } )

		case nOpMenu == 22 // Grupo de Cobertura - Grupo de Quantidade
			FWExecView(cTitle, 'PLSA260BW7', nOperation,, { || .T. } )

		case nOpMenu == 23 // Grupo de Cobertura - Classe de Carência
			FWExecView(cTitle, 'PLSA260BFJ', nOperation,, { || .T. } )

		case nOpMenu == 24 // Cobertura - Grupos Determinados
			FWExecView(cTitle, 'PLSA260BFE', nOperation,, { || .T. } )

		case nOpMenu == 25 // Cobertura - Procedimentos
			FWExecView(cTitle, 'PLSA260BFG', nOperation,, { || .T. } )

		case nOpMenu == 26 // Cobertura - Grupo de Quantidade
			FWExecView(cTitle, 'PLSA260BW9', nOperation,, { || .T. } )

		case nOpMenu == 27// Cobertura - Classe de Carência
			FWExecView(cTitle, 'PLSA260BFO', nOperation,, { || .T. } )

		case nOpMenu == 28// Documentos Obrigatórios
			FWExecView(cTitle, 'PLSA260BCP', nOperation,, { || .T. } )

		case nOpMenu == 29 // Faixa Etaria Especifica do Beneficiario
			FWExecView(cTitle, 'PLSA260BDQ', nOperation,, { || .T. } )

		case nOpMenu == 30 // Histórico Financeiro
			FWExecView('Visualização','PLSA260SE1', MODEL_OPERATION_VIEW,, { || .T. } )

		case nOpMenu == 31 // Histórico Cobrança Carteirinha
			FWExecView('Visualização','PLSA260BED', MODEL_OPERATION_VIEW,, { || .T. } )

		case nOpMenu == 32 // Histórico Bloqueio da Família
			FWExecView('Visualização','PLSA260BC3', MODEL_OPERATION_VIEW,, { || .T. } )

		case nOpMenu == 33 // Doenças pré-existentes
			FWExecView(cTitle, 'PLSA260BF3', nOperation,, { || .T. } )

		case nOpMenu == 34 // Situações Adversas
			FWExecView(cTitle, 'PLSA260BHH', nOperation,, { || .T. } )

		case nOpMenu == 35 // Historico Bloqueio do usuário
			FWExecView(cTitle, 'PLSA260BCA', nOperation,, { || .T. } )

		case nOpMenu == 36 // Historico Parcelamento
			FWExecView('Visualização','PLSA260B78', MODEL_OPERATION_VIEW,, { || .T. } )

		case nOpMenu == 37 // Grupo de Rol de Procedimentos
			FWExecView(cTitle, 'PLSA260B1W', nOperation,, { || .T. } )

		case nOpMenu == 38 // Opcional da familia
			FWExecView(cTitle, 'PLS260BF1MVC', nOperation,, { || .T. } )

		case nOpMenu == 39 // Histórico de bloqueio dos Opcionais da familia
			FWExecView('Visualização','PLSA260BGT', MODEL_OPERATION_VIEW, nil, {|| .T.})
		
		case nOpMenu == 40 // Histórico de bloqueio dos Opcionais do beneficiário
			FWExecView('Visualização','PLSA260BGU', MODEL_OPERATION_VIEW, nil, {|| .T.})

		case nOpMenu == 41 // Histórico de Transferência do Beneficiário
			FwMsgRun(,{||PL169HIST()},,'Carregando')

		case nOpMenu == 42 // Cancelamento de Reajuste
			FWExecView(cTitle, 'PLSA260BYW', nOperation,, { || .T. } )
	endcase

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260PLAMvc
Reescrita da função PLSA260PLA
Valida a data analisando a versao do plano..
@author DEV TOTVS
@since 02/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260PLAMvc(cCodPla,dData,cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,lAtuVar,cCodOpc,cVerPla,lJuridico)

Local lRet   	:= .F.
Local lBloq	 	:= .F.
Local cChave 	:= cCodInt+cCodPla
Local lBT6Found
Local lSitAns	:= .T.

Default lJuridico := .F.
Default lAtuVar := .T.
Default cCodOpc	:= ""
Default cVerPla := "001"


//Verificar so o plano esta disponivel para a empresa/contrato...
If BG9->BG9_TIPO == "2"

	If !Empty(cCodOpc)
		DbSelectArea("BHS")
		BHS->(DbSetOrder(1))//BHS_FILIAL + BHS_CODINT + BHS_CODIGO + BHS_NUMCON + BHS_VERCON + BHS_SUBCON + BHS_VERSUB + BHS_CODPRO + BHS_VERPRO + BHS_CODPLA + BHS_VERPLA
		If BHS->(MsSeek(xFilial("BHS")+cCodInt+cCodEmp+cNumCon+cVercon+cSubCon+cVerSub+cCodPla+cVerPla+cCodOpc))
			Return({.T.,BHS->BHS_VERPLA})
		Else
			Return({.T.,M->BF1_VERSAO})
		EndIf
	EndIf

	BT6->(DBSetOrder(1))

    lBT6Found := BT6->(MsSeek(xFilial("BT6")+cCodInt+cCodEmp+cNumCon+cVercon+cSubCon+cVerSub+cCodPla+cVerPla))

	If ! lBT6Found
	   Help("",1,"Codigo de Plano inexistente na base.")
	   Return({lRet,""})
	Else
		//Verificar se a data base e maior que a data do servidor...		
		BI3->(DbSetOrder(1))
		If BI3->(MsSeek(xFilial("BI3")+cChave))			
			//Posiciona na primeira versao...			
			BIL->(DbSetOrder(1))
			If BIL->(MsSeek(xFilial("BIL")+cChave))
				While ! BIL->(Eof()) .And. BIL->(BIL_FILIAL+BIL_CODIGO) == xFilial("BIL")+cChave
					If dtos(dData) >= dtos(BIL->BIL_DATINI) .And. dtos(dData) <= dtos(BIL->BIL_DATFIN)
						// Testa agora se a versao do produto disponivel esta ativa...
						If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
							If BI3->BI3_STATUS <> '2' .and.  !BI3->BI3_SITANS $ "2,3"
								lRet := .T.
								Exit
							Else
								If inclui
									If !lJuridico
										lBloq := .T.
									Else
										lRet := .T.
										Exit
									EndIf
								Else
									If !lJuridico
										If PLS260IsTMvc()
											lBloq := .T.
										Else
											lRet := .T.
											Exit
										Endif
									Else
										lRet := .T.
										Exit
									EndIf
								Endif
							Endif
						Endif
					ElseIf Empty(BIL->BIL_DATFIN)
						If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO)) //BI3->(MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA3_CODPLA+BIL->BIL_VERSAO))
							If Dtos(dData) >= dtos(BIL->BIL_DATINI)
								If BI3->BI3_STATUS <> '2'.and.!BI3->BI3_SITANS $ "2,3"
									lRet := .T.
									Exit
								Else
									If inclui
										If !lJuridico
											lBloq := .T.
										Else
											lRet := .T.
											Exit
										EndIf
									Else
										If !lJuridico
											If PLS260IsTMvc()
												lBloq := .T.
											Else
												lRet := .T.
												Exit
											Endif
										Else
											lRet := .T.
											Exit
										EndIf
									Endif
								Endif
							Else
								// Se a versao selecionada nao estiver na faixa de datas e nao estiver bloqueada
								// Deve apresentar o help sobre a faixa de datas, entao desligo o flag de mensagem
								// de versao bloqueada, caso ela esteja ligada.
								If BI3->BI3_STATUS <> '2' .and. lBloq
									lBloq := .F.
								Endif
							Endif
						Endif
					Endif
					BIL->(DbSkip())
				Enddo
			Endif

			If ! lRet
				If !lBloq
					Help("",1,"PLS26003")
				Else
					If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
						If (!INCLUI .and. Readvar()=='M->BA3_CODPLA' .and. M->BA3_CODPLA == BA3->BA3_CODPLA) .or.;
						   (!INCLUI .and. Readvar()=='M->BA1_CODPLA' .and. IIf(Empty(BA1->BA1_CODPLA), M->BA3_CODPLA == BA3->BA3_CODPLA, M->BA1_CODPLA == BA1->BA1_CODPLA) )
							lSitAns	:= .F.
							lRet	:= .T.
						EndIf
						If !PLS260IsTMvc() .and. lSitAns
							Help("",1,"PLSSITANS")
						EndIf
					Else
						Help("",1,"PLSA260002")
					Endif
				Endif
				Return({lRet,""})
			Else
				BI3->(DbSetOrder(1))
				BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
				If lAtuVar
					M->BA3_SEGPLA := BT6->BT6_CODSEG
					M->BA3_MODPAG := BT6->BT6_MODPAG
					M->BA3_APLEI  := BT6->BT6_APOSRG
					M->BA3_ABRANG := BT6->BT6_ABRANG
				Endif
			Endif
	    Endif
	Endif

	lRet := .T.

Else

	If !Empty(cCodOpc)

		DbSelectArea("BT3")
		BT3->(DbSetOrder(1))//BT3_FILIAL + BT3_CODIGO + BT3_VERSAO + BT3_CODPLA + BT3_VERPLA
		If BT3->(MsSeek(xFilial("BTS")+cCodInt+cCodPla+cVerPla+cCodOpc))
			Return({.T.,BT3->BT3_VERPLA})
		Else
			Return({.T.,M->BF1_VERSAO})
		EndIf

	EndIf
	//Verificar se a data base e maior que a data do servidor...

	BI3->(DbSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+cChave))
		//Posiciona na primeira versao...		
		BIL->(DbSetOrder(1))
		If BIL->(MsSeek(xFilial("BIL")+cChave))
			While ! BIL->(Eof()) .And. BIL->(BIL_FILIAL+BIL_CODIGO) == xFilial("BIL")+cChave
				If     dtos(dData) >= dtos(BIL->BIL_DATINI) .And. dtos(dData) <= dtos(BIL->BIL_DATFIN)
					// Testa agora se a versao do produto disponivel esta ativa...
					If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
						If BI3->BI3_STATUS <> '2'.and. !BI3->BI3_SITANS $ "2,3"
							lRet := .T.
							Exit
						Else
							If inclui
								lBloq := .T.
							Else
								If !PLS260IsTMvc()
									lBloq := .T.
								Else
									lRet := .T.
									Exit
								Endif
							Endif
						Endif
					Endif
				ElseIf Empty(BIL->BIL_DATFIN)
					// Testa agora se a versao do produto disponivel esta ativa...
					If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))//BI3->(MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA3_CODPLA+BIL->BIL_VERSAO))
						If Dtos(dData) >= dtos(BIL->BIL_DATINI)
							If BI3->BI3_STATUS <> '2' .and. !BI3->BI3_SITANS $ "2,3"
								lRet := .T.
								Exit
							Else
								If inclui
									lBloq := .T.
								Else
									If !PLS260IsTMvc()
										lBloq := .T.
									Else
										lRet := .T.
										Exit
									Endif
								Endif
							Endif
						Else
							// Se a versao selecionada nao estiver na faixa de datas e nao estiver bloqueada
							// Deve apresentar o help sobre a faixa de datas, entao desligo o flag de mensagem
							// de versao bloqueada, caso ela esteja ligada.
							If BI3->BI3_STATUS <> '2' .and. lBloq
								lBloq := .F.
							Endif
						Endif
					Endif
				Endif
				BIL->(DbSkip())
			Enddo
		Endif

		If ! lRet
			If !lBloq
				Help("",1,"PLS26003")
			Else
				If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
					If (!INCLUI .and. Readvar()=='M->BA3_CODPLA' .and. M->BA3_CODPLA == BA3->BA3_CODPLA) .or.;
   					   (!INCLUI .and. Readvar()=='M->BA1_CODPLA' .and. IIf(Empty(BA1->BA1_CODPLA), M->BA3_CODPLA == BA3->BA3_CODPLA, M->BA1_CODPLA == BA1->BA1_CODPLA) )
						lSitAns	:= .F.
						lRet	:= .T.
					EndIf
					If lSitAns
						Help("",1,"PLSSITANS")
					EndIf
				Else
					Help("",1,"PLSA260002")
				Endif
			Endif
			Return({lRet,""})
		Else
			BI3->(DbSetOrder(1))
			BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
			If lAtuVar
				M->BA3_SEGPLA := BI3->BI3_CODSEG
				M->BA3_MODPAG := BI3->BI3_MODPAG
				M->BA3_APLEI  := BI3->BI3_APOSRG
				M->BA3_ABRANG := BI3->BI3_ABRANG
			Endif
		Endif
	Else
		Help("",1,"RECNO")
		Return({lRet,""})
	Endif
Endif

If lAtuVar
	If BG9->BG9_TIPO == "2"
		M->BA3_TIPCON := BT5->BT5_TIPCON
	Else
		M->BA3_TIPCON := GetNewPar("MV_PLSTIPC","1")
	Endif
Endif

Return({lRet,BIL->BIL_VERSAO})

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260IsTit
Reescrita da função PLS260IsTit
Valida a data analisando a versao do plano..
@author DEV TOTVS
@since 02/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260IsTMvc()

Local lRetIsTit := .F.

If ReadVar() =='M->BA3_CODPLA' .Or. Type("M->BA1_TIPUSU") == "U"
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
ElseIf ReadVar() == 'M->BF4_CODPRO'
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
Else
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
EndIf

Return lRetIsTit

//----------------------------------------------------------------
/*/{Protheus.doc} PLSVLDVIGMvc
--Substitui a função PLSVLDVIG
Validacao da vigencia
@author  DEV TOTVS
@version P12
@since   09/09/19
/*/
//----------------------------------------------------------------
Function PLSVLDVIGMvc(cAlias, oModel)

    Local lRet    := .T.
    Local nQTD    := ""
    Local nLinha  := ""
    Local dVigIni := ""
    Local dVigFim := ""
    Local nI      := 0
    Local cModel  := ""
    Local cCmpIni := ""
    Local cCmpFim := ""
    Local cCmpTip := ""


    If cALias == "BVC"
        cModel  := "BVCDETAIL"
        cCmpIni := "BVC_VIGINI"
        cCmpFim := "BVC_VIGFIM"
        cCmpTip := "BVC_TIPO"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := oModel:GetValue(cModel,cCmpTip)    
    ElseIf cAlias == "BVF"
        cModel  := "BVFDETAIL"
        cCmpIni := "BVF_VIGINI"
        cCmpFim := "BVF_VIGFIN"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""
    ElseIf cAlias == "BVJ"
        cModel  := "BVJDETAIL"
        cCmpIni := "BVJ_VIGDE"
        cCmpFim := "BVJ_VIGATE"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""
    ElseIf cAlias == "BVM"
        cModel  := "BVMDETAIL"
        cCmpIni := "BVM_VIGDE"
        cCmpFim := "BVM_VIGATE"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""
	ElseIf cAlias == "BYW"
	    cModel  := "BYWDETAIL"
        cCmpIni := "BYW_DATINI"
        cCmpFim := "BYW_DATFIN"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""

    EndIf
        
    //Verifico se a vigência final é maior que a inicial.
    If !Empty(dVigFim) .and. dVigIni > dVigFim
        Help( ,, "Atenção",, "Vigência Final maior que a Inicial", 1, 0 )
        lRet := .F.
        Return(lRet)
    EndIf

    //Verifico se já existe uma vigência em aberto
    If nQtd > 1
        For nI := 1 To nQtd
            If nI <> nLinha
                oModel:GetModel(cModel):GoLine(nI)
                If !Empty(cTipo)
                    If cTipo == oModel:GetValue(cModel,cCmpTip)//Tipos diferentes podem ter vigencias iguais.
                        If !Empty(dVigFim) .and. (dVigIni >= oModel:GetValue(cModel,cCmpIni) .and. dVigIni <= oModel:GetValue(cModel,cCmpFim))//Verifico se estão no mesmo intervalo                
                            lRet := .F.
                            Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada!", 1, 0 )
                            Return(lRet)
                        EndIf
                    EndIf
                else
                    If !Empty(dVigFim) .AND. (dVigIni >= oModel:GetValue(cModel,cCmpIni)  .and. dVigIni <= oModel:GetValue(cModel,cCmpFim))//Verifico se estão no mesmo intervalo                
                        lRet := .F.
                        Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada!", 1, 0 )
                        Return(lRet)
                    EndIf
                    
                EndIf

            EndIf        
        Next nI

    else
    lRet := .T.
    EndIf

    //Retorno o Grid para a posição original
    If nQtd > 1
        oModel:GetModel(cModel):GoLine(nLinha)
    EndIf

Return (lRet)


/*/{Protheus.doc} PLSPermMVC
-*-*-*-Substitui a função PLSPerm*-*-*-
Verifica se o usuario possui permissao para usar o plano
que esta no contrato
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------

Function PLSPermMVC(cTipUsu,cGrauPa,cEstCiv,cSexo,oBrwUsr,cCodInt,cCodPro,cVersao,dDatInc,dDatNas,;
		cCodEmp,cNumcon,cVerCon,cSubCon,cVerSub,lJuridico)

Local I
LOCAL aQtd      := {}
LOCAL nPos      := {0,0,0}
LOCAL _aQtdUsr  := {,,,}
LOCAL bClose    := {|| TrbBT1->(dbCloseArea())}
Local aArea     := GetArea()
LOCAL lRet      := .F.
Local Inclui    := .T.

Default cTipUsu := ""
Default cGrauPa := ""
Default cEstCiv := ""
Default cSexo   := ""
Default cCodInt := ""
Default cCodPro := ""
Default cVersao := ""
Default dDatInc := CtoD("")
Default dDatNas := CtoD("")
Default cCodEmp := ""
Default cNumcon := ""
Default cVerCon := ""
Default cSubCon := ""
Default cVerSub := ""
Default lJuridico := !Empty(cSubCon)


//Coloco na quantidade de usuarios este que estou tentando inserir
aadd(aQtd,{cTipUsu,cGrauPa,cEstCiv,cSexo,dDatNas})

BT0->(DBSetOrder(1))
BT1->(DBSetOrder(1))
BQC->(DBSetOrder(1))
BT6->(DBSetOrder(1))

//Verifico se o titular está ciente e de acordo com a RN 309. Se não estiver permito apenas a
//inclusão de conjuge e filhos no contrato. Os graus de parentesco estarão definidos no MV_RN309GP
If Inclui .and.  BQC->( msSeek(xFilial("BQC")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))
	If BT5->( MsSeek(xFilial("BT5")+cCodInt+cCodEmp+cNumCon+cVerCon) )
		DbSelectArea("BQC")
		If AllTrim(BT5->BT5_TIPCON) $ "2,3" .AND. IIF(BQC->( FieldPos("BQC_CIE309") ) > 0 , AllTrim(BQC->BQC_CIE309) $ '2,3',.F.)
			If !(cGrauPa $ GetNewPar("MV_RN309GP","01,02,03,04,05,06"))
				Help("",1,"PLS260R309")
				RestArea(aArea)
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf


// Verifico no SubContrato para pessoa Juridica se o tipo de usuario pode usar o plano
If BT0->(MsSeek(xFilial("BT0")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub+cCodPro+cVersao))
	//Verifica se esta dentro dos padroes de permissao  no Subcontrato Usuários Permitido...
	cSQL := "SELECT BT0_TIPUSR TIPUSR, BT0_GRAUPA GRAUPA, BT0_ESTCIV ESTCIV, BT0_SEXO SEXO, "
	cSQL +=    "BT0_NMIUSR NMIUSR, BT0_NMAUSR NMAUSR, BT0_IDAMIN IDAMIN, BT0_UNIMIN UNIMIN, BT0_IDAMAX IDAMAX, BT0_UNIMAX UNIMAX "
	cSQL +=   "FROM "+RetSQLName("BT0")+" WHERE "
	cSQL +=    "BT0_FILIAL = '"+xFilial("BT1")+"' AND "
	cSQL +=    "BT0_CODIGO = '"+cCodInt+cCodEmp+"' AND "
	cSQL +=    "BT0_NUMCON = '"+cNumCon+"' AND "
	cSQL +=    "BT0_VERCON = '"+cVerCon+"' AND "
	cSQL +=    "BT0_SUBCON = '"+cSubCon+"' AND "
	cSQL +=    "BT0_VERSUB = '"+cVerSub+"' AND "
	cSQL +=    "BT0_CODPRO = '"+cCodPro+"' AND "
	cSQL +=    "BT0_VERSAO = '"+cVersao+"' AND "
	cSQL +=    "BT0_ATIVO  = '1' AND " // somente regras ativas
	cSQL +=    "D_E_L_E_T_ = ' ' "
	cSQL +=  "ORDER BY BT0_TIPUSR DESC, BT0_GRAUPA DESC, BT0_ESTCIV DESC, BT0_SEXO DESC"
	PLSQuery(cSQL,"TrbBT1")
Else

	//Verifico se o produto e permitido para todos os usuario
	BI3->(DBSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPro+cVersao))
		If BI3->BI3_ALLUSR == "1"
			If !lJuridico .and. !PLS260IsTMvc() .and. BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
				If !INCLUI .and. cCodPro == IIf(Empty(BA1->BA1_CODPLA), BA3->BA3_CODPLA, BA1->BA1_CODPLA)
					lSitAns	:= .F.
					lRet	:= .T.
				EndIf
				If !lRet
					Help("",1,"PLSSITANS")
				EndIf
				Return(lRet)
			Else
				//se ele eh permitido para todos usuarios retorna .t.
				RestArea(aArea)
				Return(.T.)
			Endif
		Endif
	Endif

	// Se não estiver para todos os Usuarios verifico  na BT1 (Produtos Usuários Permitidos  )
	// quais os tipo de usuario tem permissão para usar Pessoa Fisica

		
	cSQL := "SELECT BT1_TIPUSR TIPUSR, BT1_GRAUPA GRAUPA, BT1_ESTCIV ESTCIV, BT1_SEXO SEXO, "
	cSQL +=    "BT1_NMIUSR NMIUSR, BT1_NMAUSR NMAUSR, BT1_IDAMIN IDAMIN, BT1_UNIMIN UNIMIN, BT1_IDAMAX IDAMAX, BT1_UNIMAX UNIMAX "
	cSQL +=   "FROM "+RetSQLName("BT1")+" WHERE "
	cSQL +=    "BT1_FILIAL = '"+xFilial("BT1")+"' AND "
	cSQL +=    "BT1_CODIGO = '"+cCodInt+cCodPro+"' AND "
	cSQL +=    "BT1_VERSAO = '"+cVersao+"' AND "
	cSQL +=    "BT1_ATIVO  = '1' AND " // somente regras ativas
	cSQL +=    "D_E_L_E_T_ = ' ' "
	cSQL +=  "ORDER BY BT1_TIPUSR DESC, BT1_GRAUPA DESC, BT1_ESTCIV DESC, BT1_SEXO DESC"
	PLSQuery(cSQL,"TrbBT1")

Endif
While !TrbBT1->(Eof())
	_aQtdUsr := {,,,}
	For I := 1 to 4
		_aQtdUsr[I] := PL260QUsrMVC(I,aQtd,TrbBT1->TIPUSR,TrbBT1->GRAUPA,TrbBT1->ESTCIV,TrbBT1->SEXO)
	Next

	//Verifico se esta preenchido o Grau e o Tipo do Usuario, Estado Civil e Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV .And.;
				(TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==cTipUsu})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==cGrauPa})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==cEstCiv})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau e o Tipo do Usuario, Estado Civil...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. cEstCiv == TrbBT1->ESTCIV

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se esta preenchido o Grau e o Tipo do Usuario e Sexo...              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif
	//Verifico se esta preenchido o Grau e o Estado Civil e Sexo..	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cGrauPa == TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Estado Civil e Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

   //Verifico se esta preenchido o Grau e o Tipo do Usuario...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa== TrbBT1->GRAUPA

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif	
	
	//Verifico se esta preenchido o Estado Civil e Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau e o Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cGrauPa== TrbBT1->GRAUPA .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau Estado Civil...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cGrauPa== TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Estado Civil..	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cEstCiv   == TrbBT1->ESTCIV

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif
	
	//Verifico se esta preenchido o Tipo do Usuario...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")
			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
				Eval(bClose)
				RestArea(aArea)
				lRet:= .T.
			Endif
		Endif
	Endif

	lFlag := .F.

	//Verifico se esta preenchido o Estado Civil..	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cEstCiv   == TrbBT1->ESTCIV
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	lFlag := .F.

	//Verifico se esta preenchido o Grau...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cGrauPa== TrbBT1->GRAUPA
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	TRBBT1->(DbSkip())
Enddo
Eval(bClose)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAPPRDPMVC
-*-*-*-Substitui a função PLSAPPRDPq*-*-*-
Pesquisa os Opcionais na base de dados como um opcional
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------

Function PLSAPPRDPMVC(aBrowPro,aVetPad,oBrowPro,cNumCon,cCodInt,cCodEmp,cCodPla,cVersao,cSubCon,lValid,cCampo,oModel)
Local aArea    := GetArea()
Local cSQL
//Local dDt
//Local aOpcoes  	:= {}
Local cRetBI3  	:= BI3->(RetSQLName("BI3"))
Local cRetBHS  	:= BHS->(RetSQLName("BHS"))
Local cRetBT3  	:= BT3->(RetSQLName("BT3"))
Local cRetBE5  	:= BG9->(RetSQLName("BE5"))
Local lRet 	   	:= .F.



DEFAULT lValid 	:= .F.
DEFAULT cCampo 	:= READVAR()
DEFAULT cSubCon := ""
DEFAULT cVersao := ""
DEFAULT oModel  := FwModelActive()

//Posiciona no grupo/empresa....
If BG9->(BG9_CODINT+BG9_CODIGO) <> cCodInt+cCodEmp
	BG9->(DbSetOrder(1))
	BG9->(MsSeek(xFilial("BG9")+cCodInt+cCodEmp))
Endif

//Verifica se o usuario tem um plano especifico
If BG9->BG9_TIPO == "1" .And. !Empty(BA1->BA1_CODPLA)
    cCodPla := BA1->BA1_CODPLA
    cVersao := BA1->BA1_VERSAO
EndIf

//Limpa resultado...
If !lValid
   aBrowPro := {}
EndIf

If BG9->BG9_TIPO == "1"

	//Faz uma pesquisa pelos produtos vinculados ao produto do contrato	
	cSQL := "SELECT DISTINCT BT3_FILIAL, BT3_CODIGO, BT3_CODPLA "
	cSQL += "  FROM "+cRetBT3
	cSQL += " WHERE BT3_FILIAL = '"+xFilial("BT3")+"'"
	cSQL += "   AND "+cRetBT3+".D_E_L_E_T_ = '' "
	cSQL += "   AND BT3_CODIGO = '"+cCodInt+cCodPla+"'"

	cSQL += "   AND BT3_VERSAO = '"+cVersao+"'"
	cSQL += "   AND BT3_CODPLA IN (SELECT BI3_CODIGO "
	cSQL +=                       "  FROM "+cRetBI3+","+cRetBE5
    cSQL +=                       " WHERE BI3_FILIAL = '"+xFilial("BI3")+"'"
    cSQL +=                       "   AND BE5_FILIAL = '"+xFilial("BE5")+"'"
    cSQL +=                       "   AND "+cRetBI3+".D_E_L_E_T_ = ''"
    cSQL +=                       "   AND "+cRetBE5+".D_E_L_E_T_ = ''"
    cSQL +=                       "   AND BE5_CODGRU = BI3_GRUPO "
    cSQL +=                       "   AND (BE5_PEROPC = '1' OR BE5_PERAGR = '1')"
    cSQL +=                       "   AND BI3_STATUS <> '2' ) "
    cSQL += " ORDER BY BT3_FILIAL, BT3_CODIGO, BT3_CODPLA "

    cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbPes",.T.,.T.)

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		If !lValid
		   If aScan(aBrowPro,{ |x| x[1] == TrbPes->BT3_CODIGO }) == 0
		     	TrbPes->(aadd(aBrowPro,{BT3_CODPLA,;
		    	Posicione("BI3",1,xFilial("BI3")+cCodInt+BT3_CODPLA,"BI3_DESCRI")}))
		   Endif
		Else
           If cCampo $ "BF1_CODPRO" .And. oModel:GetModel('BF1DETAIL'):GetValue('BF1_CODPRO') == TrbPes->BT3_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BF4_CODPRO" .And. oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO") == TrbPes->BT3_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BK0_CODFOR" .And. oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODFOR") == TrbPes->BT3_CODPLA
		      lRet := .T.			  
		   EndIf
		EndIf
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
Else
	//Faz uma pesquisa agora para os produtos opcionais do Grupo/Empresa
	cSQL := "SELECT BI3_DESCRI, BHS_CODINT, BHS_CODIGO, BHS_NUMCON, BHS_CODPLA, BE5_PEROPC, BE5_CODGRU, "
	cSql += "       BI3_GRUPO,  BI3_CODINT, BI3_CODIGO  "
	cSQL += "  FROM "+cRetBHS+","+cRetBE5+","+cRetBI3
	cSQL += " WHERE BHS_FILIAL = '"+xFilial("BHS")+"'"
	cSQL += "   AND "+cRetBHS+".D_E_L_E_T_ = ' '"
	cSQL += "   AND BHS_CODINT = '"+cCodInt+"'"
	cSQL += "   AND BHS_CODIGO = '"+cCodEmp+"'"
	cSQL += "   AND BHS_NUMCON = '"+cNumCon+"'"
	cSQL += "   AND BHS_SUBCON = '"+cSubCon+"'"
	cSQL += "   AND BHS_CODPRO = '"+cCodPla+"'"
	cSQL += "   AND BE5_CODGRU = BI3_GRUPO "
	cSQL += "   AND BI3_CODINT = '"+cCodInt+"'"
	cSQL += "   AND BE5_PEROPC = '1' "
	cSQL += "   AND BI3_CODIGO = BHS_CODPLA "
   	

	cSQL += " ORDER BY BHS_FILIAL, BHS_CODINT, BHS_CODPRO"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbPes",.F.,.T.)

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		If !lValid
		   If aScan(aBrowPro,{ |x| x[1] == TrbPes->BHS_CODPLA }) == 0
		      TrbPes->(aadd(aBrowPro,{BHS_CODPLA,;
			  TrbPes->BI3_DESCRI}))
		   Endif
		Else
		   If cCampo $ "BF1_CODPRO" .And. oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO") == TrbPes->BHS_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BF4_CODPRO" .And. oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO") == TrbPes->BHS_CODPLA
		      lRet := .T.
		   EndIf
		Endif
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
Endif

If !lValid
   //Testa resultado da pesquisa...
    If Len(aBrowPro) == 0
      aBrowPro := aClone(aVetPad)
   Endif

	//Atualiza browse...   
   oBrowPro:SetArray(aBrowPro)
   oBrowPro:Refresh()
   oBrowPro:SetFocus()

EndIf

//Fim da Rotina...
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLChkOpcMvc
*--Substitui a função PL260ChkOpc
Funcao que verifica a data base no BF4 BIL_DATINI
@author Totver
@since 03/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLChkOpcMvc(nTipo, oModel)
Local lRet		:= .T.
Local dDatNov	:= ReadVar()


If nTipo = 1 // opcional na familia //Verificar depois, quando implementar na familia
	IF BIL->(DbSeek(xFilial("BIL")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO)) 
		If BIL->BIL_DATINI >= &dDatNov
			MsgAlert(OemtoAnsi(STR0247))//"A data base deve ser maior ou igual a data inicial da versão do produto"
			lRet := .F.
		Endif
	Endif
Else
	// opcional no Usuario
		IF BIL->(DbSeek(xFilial("BIL")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO)) .and. !Empty(oModel:GetModel('BF4DETAIL'):GetValue('BF4_CODPRO'))
			If BIL->BIL_DATINI >= &dDatNov
				MsgAlert(OemtoAnsi(STR0247))//"A data base deve ser maior ou igual a data inicial da versão do produto"
				lRet := .F.
			Endif
		Endif
		
		IF lRet
			//Verificar se já existe outros produtos no grid	
			If oModel:GetModel('BF4DETAIL'):Length(.T.) > 1
				
				If BF4->BF4_DATBAS <> oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS')
					
					If oModel:GetModel('BF4DETAIL'):GetValue('BF4_TIPBLO') == "0" .AND. !EMPTY(BF4->BF4_DATBLO) 
					
						MsgAlert(OemtoAnsi(STR0265))//"A alteração da data base será permitida após o debloqueio do opcional."
						oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS'):= BF4->BF4_DATBAS 
						lRet := .F.
					
					ElseIf oModel:GetModel('BF4DETAIL'):GetValue('BF4_TIPBLO') == "1" .And. oBrwOUsu:aCols[oBrwOUsu:Linha(),oBrwOUsu:PlRetPos("BF4_TIPBLO")] =="1"
					
						MsgAlert(OemtoAnsi(STR0266)) //"Opcional já Desbloqueado. Realize o Bloqueio para alterar a data base!"						
						oModel:GetModel('BF4DETAIL'):LoadValue('BF4_DATBAS',BF4->BF4_DATBAS)						
						lRet := .F.
					Endif
				EndIf
			EndIf 
		ENDIF 
	
		If oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS') > oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBLO') .AND.;
		 	!EMPTY(oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBLO')) .AND. lRet
			msgAlert(STR0262,STR0242) //STR0262,"A ve ser menor ou igual a data de bloqueio.##"Atenção"
			lRet := .F.
		EndIf

EndIf


If nTipo = 1
	    dDataBas :=  oModel:GetModel('BF1DETAIL'):GetValue('BF1_DATBAS')    
   Else
	    dDataBas :=  oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS')
Endif 

If (BA1->BA1_DATINC > dDataBas) 
   MsgAlert(STR0281,STR0071) //STR0281,"A data base deve ser maior ou igual a data de Inclusão do Beneficiário.##"Atenção"
   lRet := .F.
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBYXValid
Criação do array para validação de tipo de usuario, grau de parentesco, estado civil e sexo
Essa função é chamada da PLSPermMVC 
@author Totver
@since 04/09/19
@version P12
/*/

Static Function PL260QUsrMVC(nTipo,aVet,cTIPUSR,cGRAUPA,cESTCIV,cSEXO)
//nTipo
//  1 - Tipo Usuario
//  2 - Grau Parentesco
//  3 - Estado Civil
//  4 - Sexo
LOCAL _I := 0
LOCAL nTemp   := 0
Local cTemp   := ""
LOCAL aQtdUsr := {}
For _I := 1 to Len(aVet)
	If 	aVet[_I,1] == cTipUSR .and.;
		(aVet[_I,2] == cGrauPa .Or. Empty(cGrauPa)) .and.;
		(aVet[_I,3] == cEstCiv .or. Empty(cEstCiv)) .and.;
		(aVet[_I,4] == cSexo .or. cSexo == "3" .or. Empty(cSexo))
		if !Empty(aVet[_I,1])
			cTemp := aVet[_I,nTipo]
			nTemp := aScan(aQtdUsr,{|x|x[1]==cTemp})
			if nTemp > 0
				aQtdUsr[nTemp,2] := aQtdUsr[nTemp,2] + 1
			Else
				aadd(aQtdUsr,{aVet[_I,nTipo],1})
			Endif
		Endif
	EndIf
Next
Return(aQtdUsr)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlM260NAlMVC
Substitui a função ³PLSM260NAl 
Nao permite alteracao do codigo da cobranca caso ja tenha propriedades
@author  DEV TOTVS
@version P12
@since   19/08/19
/*/
//-------------------------------------------------------------------
Function PlM260NAlMVC(oModel, cAlias)

	Local lEdita := .T.
	Local cCodFor
	Local nOpc 		 := oModel:GetOperation()
	Local aAreaBJK   := BJK->(GetArea())
	Local aSaveLines := FWSaveRows()

	//Se tem dados na BBU e BFY, eu não permito editar a BJK
		if cAlias == "BJK" .AND. nOpc == MODEL_OPERATION_UPDATE
			BJK->(DbSetOrder(1))
			BJK->(MsSeek(xFilial('BJK')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			cCodFor := BJK->BJK_CODFOR
		Elseif cAlias = "BJL" .AND. nOpc == MODEL_OPERATION_UPDATE
			cCodFor := M->BJL_CODFOR
		Elseif cAlias = "BK0" .AND. nOpc == MODEL_OPERATION_UPDATE		
			cCodFor := M->BK0_CODFOR 
		Elseif cAlias = "BYX" .AND. nOpc == MODEL_OPERATION_UPDATE				
			cCodFor := BYX->BYX_CODFOR
		Endif

		If cAlias == "BJK" 
			oBJK := oModel:GetModel( 'BJKDETAIL' )
			oBjk:GoLine(oBjk:getline())
		 	If !Empty(oBJK:GetValue('BJK_CODFOR')) .AND. oBJK:GetValue('BJK_CODFOR') == cCodFor	
				lEdita := .F.
			Endif	
			RestArea(aAreaBJK)
		ElseIf cAlias == "BF4" .AND. !Empty(oModel:GetValue("BYXDETAIL", 'BYX_CODFOR')) .AND. oModel:GetValue( "BYXDETAIL",  'BYX_CODFOR') == cCodFor	
			lEdita := .F.
		EndIf

		
	
	FWRestRows( aSaveLines )
Return (lEdita)

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldCbMVC
Substitui a função PlsVldCb 
Funcao para verificar se forma de cobranca pode ser digitada
@author  DEV TOTVS
@version P12
@since   20/08/19
/*/
//-------------------------------------------------------------------
Function PlsVldCbMVC(cTipo, cUso, cCpoDescri, uCampos,oModel,cCodFor)

	Local lRet    := .T.
	Local cDesUsu := ""
	
	Default cCodFor := ""

	If cCpoDescri == "BYX_DESFOR"
		cCodFor := oModel:GetValue("BYXDETAIL","BYX_CODFOR")
	ElseIf cCpoDescri == "BJL_DESFOR"
		cCodFor := oModel:GetValue("BJLDETAIL","BJL_CODFOR")
	ElseIf cCpoDescri == "BK0_CODFOR"
		cCodFor := oModel:GetValue("BK0DETAIL","BK0_CODFOR")	
	Else
		cCodFor := oModel:GetValue("BJKDETAIL","BJK_CODFOR")
	EndIf

	If ! BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
		lRet := .F.
		Help("",1,"REGNOIS")
	Else
		If BJ1->BJ1_TIPO <> cTipo
			ApMsgAlert(	'Codigo da Cobranca invalido. Somente podera ser informado' +; //"Codigo da Cobranca invalido. Somente podera ser informado "
						AllTrim(QA_CBOX("BJ1_TIPO",cTipo)) + ".")
			lRet := .F.
		Endif
		If ! cUso $ BJ1->BJ1_USO
			If cUso = "1"
				cDesUsu := 'no Produto'
			ElseIf cUso = "2"
				cDesUsu := 'no Grupo/Empresa'
			ElseIf cUso = "3"
				cDesUsu := 'na Familia'
			ElseIf cUso = "4"
				cDesUsu := 'no Usuario'
			Endif
			ApMsgAlert(	'Codigo da Cobranca invalido. Nao pode ser informado' +;
						cDesUsu)
			lRet := .F.
		Endif
	Endif

	If lRet .And. cCpoDescri # Nil
		&("M->" + cCpoDescri) := BJ1->BJ1_DESCRI
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBusMatric
Inicializador padrão do codigo da mtricula
@author  DEV TOTVS
@version P12
@since   10/01/2020
/*/
//-------------------------------------------------------------------

Function PlsBusMatric()

cMatric:= BA1->BA1_MATRIC


 Return cMatric



//-------------------------------------------------------------------
/*/{Protheus.doc} 
Função de Pré Validação do Model
Retorna a chave do plano na BA3
@author Totver
@since 09/08/2019
@version P12
/*/
//-------------------------------------------------------------------

Function RetFilPla(oModel)
Local cRet := ""	
	If oModel:cID == "PLSA260FD3PLANO"
		cRet := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT')+oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')//+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Else
		cRet := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT')+oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')//+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Endif
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCampMVC

Devido aos campos que estao como não usado para atender ao cadastro 
antigo temos que criar esse campos no Model e na View 
@author Team PLS
@param nOp 		= 1 pra Model/2 pra View
	   oStruBA1	= Estrutura a ser adicionada os campos
	   cCampo   = Campo a ser criado na estrutua
	   cOrdem   = Ordem a ser criada o campo (Especifico pra View)
@return Retorna a estrura com os campos adicionados
@since 25/10/2019
@version P12
/*/
//-------------------------------------------------------------------

Function CriaCampMVC(nOp,oStruTab,cCampo,cOrdem)

Local aDadosCpo

Default nOp    := 0
Default cCampo := ""
Default cOrdem := ""

If nOp == 1 .AND. !Empty(cCampo) // Cria os campos para a Model
	aDadosCpo := TxSX3Campo(cCampo)
	oStruTab:AddField(			;
					aDadosCpo[1]			, ;	// [01] Titulo do campo	
					aDadosCpo[2]			, ;	// [02] ToolTip do campo
					cCampo					, ;	// [03] Id do Field
					aDadosCpo[6]			, ;	// [04] Tipo do campo
					aDadosCpo[3]			, ;	// [05] Tamanho do campo
					aDadosCpo[4]			, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .F. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						,;	// [10] Indica se o campo tem preenchimento obrigatÃ¯Â¿Â½rio
					FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache(cCampo, "X3_RELACAO") ))	// [11] Inicializador Padrão do campo
								
											
ElseIf nOp == 2 .AND. !Empty(cCampo) .AND. !Empty(cOrdem) // Cria os campos para View
	aDadosCpo := TxSX3Campo(cCampo)
	oStruTab:AddField(cCampo	,;	// [01]  C   Nome do Campo
				cOrdem			,;	// [02]  C   Ordem
				aDadosCpo[1]	,;	// [03]  C   Titulo do campo
				aDadosCpo[1]	,;	// [04]  C   Descricao do campo
				NIL				,;	// [05]  A   Array com Help
				aDadosCpo[6]	,;	// [06]  C   Tipo do campo
				aDadosCpo[5]	,;	// [07]  C   Picture
				NIL				,;	// [08]  B   Bloco de Picture Var
				NIL				,;	// [09]  C   Consulta F3
				.F.				,;	// [10]  L   Indica se o campo é alteravel
				NIL				,;	// [11]  C   Pasta do campo
				NIL				,;	// [12]  C   Agrupamento do campo
				Iif(!Empty(aDadosCpo[7]),StrTokArr(Alltrim(aDadosCpo[7]),';'),NIL)			,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL				,;	// [15]  C   Inicializador de Browse
				.F.				,;	// [16]  L   Indica se o campo é virtual
				NIL				,;	// [17]  C   Picture Variavel
				NIL				)	// [18]  L   Indica pulo de linha após o campo

EndIf

Return oStruTab

/*/{Protheus.doc} PLAddFldStruct
Função responsavel por adicionar campos (ou somente não usado) na estrutura da
tabela para ser utilizado no MVC

@type function
@version Protheus 12.1.2310  
@author vinicius.queiros
@since 27/07/2023
@param nType, numeric, define o tipo do struct: 1 (model) e 2 (view)
@param oStruct, object, objeto struct (FWFormStruct) para adicionar os campos
@param aFields, array, campos a serem adicionados
@param lUnused, logical, define se será adicionado somente campos não usados
@return oStruct, retorna o objecto struct com os campos adicionados
/*/
function PLAddFldStruct(nType, oStruct, aFields, lAddUnused)

	local nX := 0
	local cField := ""

	default lAddUnused := .t.

	do case
		case nType == 1 // Model
			for nX := 1 to len(aFields)
				cField := aFields[nX]

				if aScan(oStruct:aFields, {|x| x[3] == cField}) == 0
					if (lAddUnused .and. !X3Uso(GetSx3Cache(cField, "X3_USADO"))) .or. !lAddUnused

						oStruct:addField(getSx3Cache(cField, "X3_TITULO"),;	// [01] Titulo do campo	
										 FWSX3Util():getDescription(cField),; // [02] ToolTip do campo
										 cField,;	// [03] Id do Field
										 getSx3Cache(cField, "X3_TIPO"),; // [04] Tipo do campo
										 getSx3Cache(cField, "X3_TAMANHO"),; // [05] Tamanho do campo
										 getSx3Cache(cField, "X3_DECIMAL"),; // [06] Decimal do campo
										 FWBuildFeature(STRUCT_FEATURE_INIPAD, getSx3Cache(cField, "X3_VALID")),; // [07] Code-block de validação do campo
										 FWBuildFeature(STRUCT_FEATURE_INIPAD, getSx3Cache(cField, "X3_WHEN")),; // [08] Code-block de validação When do campo
										 iif(empty(getSx3Cache(cField, "X3_CBOX")), {}, strToArray(alltrim(getSx3Cache(cField, "X3_CBOX")), ";")),; // [09] Lista de valores permitido do campo
										 x3Obrigat(cField),; // [10] Indica se o campo tem preenchimento obrigatório
										 FWBuildFeature(STRUCT_FEATURE_INIPAD, getSx3Cache(cField, "X3_RELACAO"))) // [11] Inicializador Padrão do campo
					endif
				endif
			next nX	

		case nType == 2 // View
			for nX := 1 to len(aFields)
				cField := aFields[nX]

				if aScan(oStruct:aFields, {|x| x[1] == cField}) == 0
					if (lAddUnused .and. !X3Uso(GetSx3Cache(cField, "X3_USADO"))) .or. !lAddUnused

						oStruct:AddField(cField,; // [01] Nome do Campo
										 getSx3Cache(cField, "X3_ORDEM"),;	// [02] Ordem
										 getSx3Cache(cField, "X3_TITULO"),; // [03] Titulo do campo
										 FWSX3Util():getDescription(cField),; // [04] Descricao do campo
										 nil,; // [05] Array com Help
										 getSx3Cache(cField, "X3_TIPO"),; // Tipo do campo
										 getSx3Cache(cField, "X3_PICTURE"),; // [07] Picture
										 nil,; // [08] Bloco de Picture Var
										 getSx3Cache(cField, "X3_F3"),; // [09] Consulta F3
										 getSx3Cache("BA1_CODPLA", "X3_VISUAL") == "A",; // [10] Indica se o campo é alteravel
										 getSx3Cache("BA1_CODPLA", "X3_FOLDER"),; // [11] Pasta do campo
										 nil,; // [12] Agrupamento do campo
										 iif(empty(getSx3Cache(cField, "X3_CBOX")), {}, strToArray(alltrim(getSx3Cache(cField, "X3_CBOX")), ";")),; // [13] Lista de valores permitido do campo (Combo)
										 nil,; // [14] Tamanho maximo da maior opção do combo
										 nil,; // [15] Inicializador de Browse
										 getSx3Cache("BA1_CODPLA", "X3_CONTEXT") == "V",; // [16] Indica se o campo é virtual
										 nil,; // [17] Picture Variavel
										 nil) // [18] Indica pulo de linha após o campo
					endif
				endif
			next nX
	endcase

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSACHKMENU

Funçõao que determina na chamdado do menu se vai utilizar o modelo de titular ou dependnete
para os itens de cpnsulta, alteração e exclusão.
@author Team PLS
@param nOperation 			= 2 Consultar
							= 3 Incluir
							= 4 Alterar
							= 5 Excluir
						   
@return nil
@since 30/10/2019
@version P12
/*/
//-------------------------------------------------------------------


Function PLSACHKMENU(nOperation,lAutomato)
Local aAreaBa1 := BA1->(Getarea())
Default lAutomato	:= .F.

Default nOperation = 3

If(!lAutomato,BA1->(DbGoTo(oBrowse:nat)),)

If BA1->BA1_TIPUSU == "T"			
	PLSA260VLMVC(nOperation,lAutomato)	
Else

	If(!lAutomato,FWExecView('','PL260DEPMVC' , nOperation,, { || .T. } ),)
Endif	

RestArea(aAreaBa1)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PosFinBenef()
Chamada para exibir a posiçã0 financeira do beneficiario.
@author Totver
@since 12/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PosFinBenef()

If BA3->((DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))))

	PLPOSFIN(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),.T.,.T.)

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDelBenMVC
Realiza a exclusão dos beneficiário/familia

@type function
@version prothues 12.1.2310 
@author Gabriela.cattin
@since 31/05/2023
/*/
Function PLDelBenMVC()

	local cCodIntBenef := BA1->BA1_CODINT
	local cCodEmpBenef := BA1->BA1_CODEMP
	local cMatricBenef := BA1->BA1_MATRIC
	local cTipRegBenef := BA1->BA1_TIPREG
	local cDigitoBenef := BA1->BA1_DIGITO
	local lIsHolder := BA1->BA1_TIPUSU == getNewPar("MV_PLCDTIT", "T")
	local lDelete := .f.
	local lSucess := .f.
	local oModelBenef := nil
	local cErrorMessage := ""

	If lIsHolder
		lDelete := MsgYesNo(OemtoAnsi("Deseja realmente excluir o Titular e a Familia?")) 
	Else
		lDelete := MsgYesNo(OemtoAnsi("Deseja realmente excluir o Beneficiário?")) 
	Endif	

	If lDelete
		if PLSA260Exc(cCodIntBenef, cCodEmpBenef, cMatricBenef, .t., iif(lIsHolder, .f., .t.))

			begin transaction
				// Para o títular exclui os dependentes e as tabelas relacionadas do títular e da família
				If lIsHolder
					lSucess := delAllDepenFamily(cCodIntBenef, cCodEmpBenef, cMatricBenef, @cErrorMessage) 

					If lSucess
						lSucess := delBenefReg(cCodIntBenef+cCodEmpBenef+cMatricBenef+cTipRegBenef+cDigitoBenef)

						If lSucess
							lSucess := delFamilyReg(cCodIntBenef, cCodEmpBenef, cMatricBenef)
						endif

						oModelBenef := FWLoadModel("PLSA260MVC")
						oModelBenef:setOperation(MODEL_OPERATION_DELETE)
						oModelBenef:activate()

						lSucess := oModelBenef:vldData()
						if lSucess
							oModelBenef:commitData()
						else
							cErrorMessage := oModelBenef:getErrorMessage()[6]
						endif

						oModelBenef:deActivate()
					endif
				else
					lSucess := delBenefReg(cCodIntBenef+cCodEmpBenef+cMatricBenef+cTipRegBenef+cDigitoBenef)

					oModelBenef := FWLoadModel("PL260DEPMVC")
					oModelBenef:setOperation(MODEL_OPERATION_DELETE)
					oModelBenef:activate()

					lSucess := oModelBenef:vldData()
					if lSucess
						oModelBenef:commitData()
					else
						cErrorMessage := oModelBenef:getErrorMessage()[6]
					endif

					oModelBenef:deActivate()
				endif

				if !lSucess
					disarmTransaction()
				endif

			end transaction

			if lSucess
				FwAlertSuccess(iif(lIsHolder, "Títular e família excluída com sucesso!", "Beneficiário excluído com sucesso!"), "Exclusão de Beneficiário")
			else
				FWAlertError(iif(lIsHolder, "Erro ao excluir títular/Família,", "Erro ao excluir beneficiário,")+" verifique a integridade dos dados:<br><br>"+cErrorMessage, "Exclusão de Beneficiário")
			endif
		endif
	endif

Return

/*/{Protheus.doc} delAllDepenFamily
Exclui os dependentes da família

@type static function
@version Protheus 12.1.2310 
@author vinicius.queiros
@param cCodInt, character, Código da operadora
@param cCodEmp, character, Código da empresa
@param cMatric, character, Mátricula da família
@since 19/05/2023
/*/
Static Function delAllDepenFamily(cCodIntBenef, cCodEmpBenef, cMatricBenef, cErrorMessage)

	local cAliasTemp := ""
	local cHolderType := getNewPar("MV_PLCDTIT", "T")
	local aAreaBA1 := BA1->(getArea("BA1"))
	local lSucess := .t.
	local oModelBA1Dep := nil

	default cErrorMessage := ""

	cAliasTemp := getNextAlias()
	beginSql alias cAliasTemp	
		SELECT R_E_C_N_O_ RECNO FROM %table:BA1% BA1
		WHERE BA1.BA1_FILIAL = %xFilial:BA1%
		  AND BA1.BA1_CODINT = %exp:cCodIntBenef%
		  AND BA1.BA1_CODEMP = %exp:cCodEmpBenef%
		  AND BA1.BA1_MATRIC = %exp:cMatricBenef%
		  AND BA1.BA1_TIPUSU <> %exp:cHolderType%
		  AND BA1.%notDel%
	endSql
	
	while !(cAliasTemp)->(eof())
		BA1->(dbGoTo((cAliasTemp)->RECNO))

		lSucess := delBenefReg(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))

		If lSucess		
			oModelBA1Dep := FWLoadModel("PL260DEPMVC")
			oModelBA1Dep:setOperation(MODEL_OPERATION_DELETE)
			oModelBA1Dep:activate()

			lSucess := oModelBA1Dep:vldData()
			if lSucess
				oModelBA1Dep:commitData()
			else
				cErrorMessage := oModelBA1Dep:getErrorMessage()[6]
			endif

			oModelBA1Dep:deActivate()

			freeObj(oModelBA1Dep)
			oModelBA1Dep := nil	
		EndIf

		if lSucess
			(cAliasTemp)->(dbSkip())
		else
			exit
		endif

	enddo

	(cAliasTemp)->(dbCloseArea())

	restArea(aAreaBA1)

return lSucess

/*/{Protheus.doc} delBenefReg
Exclui os cadastros relacionados ao beneficiáiro: Tabela BYY, BCP, BFA etc

@type static function
@version Protheus 12.1.2310 
@author vinicius.queiros
@param cSubscribeId, character, Matricula do beneficiário, sendo BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
@since 11/05/2023
/*/
Static Function delBenefReg(cSubscribeId) 

	local aAreaBA1 := {}
	local oModelBF3 := nil
	local oModelBCP := nil
	local oModelBF4 := nil
	local oModelBCA := nil
	local oModelBH6 := nil
	local oModelBFE := nil
	local oModelBFG := nil
	local oModelBW9 := nil
	local oModelBFO := nil
	local oModelBHH := nil
	local oModelBDK := nil
	local oModelBGU := nil
	local lSucess := .t.

	BA1->(dbSetOrder(2))
	if BA1->(msSeek(xFilial("BA1")+cSubscribeId))
		// Doenças pre-existentes (Tabelas: BF3, BYY)
		BF3->(dbSetOrder(1))
		if BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			aAreaBA1 := BA1->(getArea())
			
			oModelBF3 := FWLoadModel("PLSA260BF3")
			oModelBF3:setOperation(MODEL_OPERATION_DELETE)
			oModelBF3:activate()

			lSucess := oModelBF3:vldData()
			if lSucess
				oModelBF3:commitData()
			endif

			freeObj(oModelBF3)
			restArea(aAreaBA1)
		endif
		// Documentos obrigatórios (Tabelas: BCP)
		if lSucess
			BCP->(dbSetOrder(1))
			if BCP->(msSeek(xFilial("BCP")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBCP := FWLoadModel("PLSA260BCP")
				oModelBCP:setOperation(MODEL_OPERATION_DELETE)
				oModelBCP:activate()

				lSucess := oModelBCP:vldData()
				if lSucess
					oModelBCP:commitData()
				endif

				freeObj(oModelBCP)	
				restArea(aAreaBA1)
			endif
		endif
		// Opcionais do beneficiário (Tabelas: BF4, BYX, BZX, BYI)
		if lSucess
			BF4->(dbSetOrder(1))
			if BF4->(msSeek(xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBF4 := FWLoadModel("PLSA260BF4")
				oModelBF4:setOperation(MODEL_OPERATION_DELETE)
				oModelBF4:activate()

				lSucess := oModelBF4:vldData()
				if lSucess
					oModelBF4:commitData()
				endif

				freeObj(oModelBF4)	
				restArea(aAreaBA1)
			endif
		endif
		// Grupo de cobertura do opcional (Tabelas: BV0)
		BV0->(dbSetOrder(1))
		if BV0->(msSeek(xFilial("BV0")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV0->(eof()) .and. BV0->(BV0_CODINT+BV0_CODEMP+BV0_MATRIC+BV0_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV0->(reclock("BV0", .f.))
					BV0->(dbDelete())
				BV0->(msUnlock())

				BV0->(dbSkip() )
			endDo
		endif
		// Classes de carencia do opcional (Tabelas: BV1)
		BV1->(dbSetOrder(1))
		if BV1->(msSeek(xFilial("BV1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV1->(eof()) .and. BV1->(BV1_CODINT+BV1_CODEMP+BV1_MATRIC+BV1_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV1->(reclock("BV1", .f.))
					BV1->(dbDelete())
				BV1->(msUnlock())

				BV1->(dbSkip())
			endDo
		endif
		// Co-Participacao do opcional (Tabelas: BV2)
		BV2->(dbSetOrder(1))
		if BV2->(msSeek(xFilial("BV2")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV2->(eof()) .and. BV2->(BV2_CODINT+BV2_CODEMP+BV2_MATRIC+BV2_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV2->(reclock("BV2", .f.))
					BV2->(dbDelete())
				BV2->(msUnlock())

				BV2->(dbSkip())
			endDo
		endif
		// Procedimentos (Tabelas: BV3)
		BV3->(dbSetOrder(1))
		if BV3->(msSeek(xFilial("BV3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV3->(eof()) .and. BV3->(BV3_CODINT+BV3_CODEMP+BV3_MATRIC+BV3_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV3->(reclock("BV3", .f.) )
					BV3->(dbDelete())
				BV3->(msUnlock())

				BV3->(dbSkip())
			endDo
		endif
		// CID x Precedimento (Tabelas: BV4)
		BV4->(dbSetOrder(1))
		if BV4->(msSeek(xFilial("BV4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV4->(eof()) .and. BV4->(BV4_CODINT+BV4_CODEMP+BV4_MATRIC+BV4_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV4->(reclock("BV4", .f.))
					BV4->(dbDelete())
				BV4->(msUnlock())

				BV4->(dbSkip())
			endDo
		endif
		// Opc x Proced x Co-Participação (Tabelas: BV5)
		BV5->(dbSetOrder(1))
		if BV5->(msSeek(xFilial("BV5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV5->(eof()) .and. BV5->(BV5_CODINT+BV5_CODEMP+BV5_MATRIC+BV5_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV5->(reclock("BV5", .f.))
					BV5->(dbDelete())
				BV5->(msUnlock())

				BV5->(dbSkip())
			endDo
		endif
		// Especialidade x Procedimento (Tabelas: BV6)
		BV6->(dbSetOrder(1))
		if BV6->(msSeek(xFilial("BV6")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV6->(eof()) .and. BV6->(BV6_CODINT+BV6_CODEMP+BV6_MATRIC+BV6_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV6->(reclock("BV6", .f.))
					BV6->(dbDelete())
				BV6->(msUnlock())

				BV6->(dbSkip())
			endDo
		endif
		// Especialidade x Procedimento x Co-participacao (Tabelas: BV7)
		BV7->(dbSetOrder(1))
		if BV7->(msSeek(xFilial("BV7")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV7->(eof()) .and. BV7->(BV7_CODINT+BV7_CODEMP+BV7_MATRIC+BV7_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV7->(reclock("BV7", .f.))
					BV7->(dbDelete())
				BV7->(msUnlock())

				BV7->(dbSkip())
			endDo
		endif
		// Co-Participacao x Procedimento (Tabelas: BV8)
		BV8->(dbSetOrder(1))
		if BV8->(msSeek(xFilial("BV8")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV8->(eof()) .and. BV8->(BV8_CODINT+BV8_CODEMP+BV8_MATRIC+BV8_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV8->(reclock("BV8", .f.))
					BV8->(dbDelete())
				BV8->(msUnlock())

				BV8->(dbSkip())
			endDo
		endif
		// Grupo de quantidade do opcional (Tabelas: BV9)
		BV9->(dbSetOrder(1))
		if BV9->(msSeek(xFilial("BV9")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BV9->(eof()) .and. BV9->(BV9_CODINT+BV9_CODEMP+BV9_MATRIC+BV9_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BV9->(reclock("BV9", .f.))
					BV9->(dbDelete())
				BV9->(msUnlock())

				BV9->(dbSkip())
			endDo
		endif
		// Co-Participacao x Grupo de quantidade x Opcional (Tabelas: BVA)
		BVA->(dbSetOrder(01) )
		if BVA->( msSeek(xFilial("BVA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			While !BVA->(eof()) .and. BVA->(BVA_CODINT+BVA_CODEMP+BVA_MATRIC+BVA_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BVA->(reclock("BVA", .f.))
					BVA->(dbDelete())
				BVA->(msUnlock())

				BVA->(dbSkip())
			endDo
		endif
		// Historico do opcional do usuario (Tabelas: BGU)
		if lSucess
			BGU->(dbSetOrder(2))
			if BGU->(msSeek(xFilial("BGU")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBGU := FWLoadModel("PLSA260BGU")
				oModelBGU:setOperation(MODEL_OPERATION_DELETE)
				oModelBGU:activate()

				lSucess := oModelBGU:vldData()
				if lSucess
					oModelBGU:commitData()
				endif

				freeObj(oModelBGU)	
				restArea(aAreaBA1)
			endif
		endif	
		// Histórico do bloqueio do beneficiário (Tabelas: BCA)
		if lSucess
			BCA->(dbSetOrder(1))
			if BCA->(msSeek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBCA := FWLoadModel("PLSA260BCA")
				oModelBCA:setOperation(MODEL_OPERATION_DELETE)
				oModelBCA:activate()

				lSucess := oModelBCA:vldData()
				if lSucess
					oModelBCA:commitData()
				endif

				freeObj(oModelBCA)
				restArea(aAreaBA1)
			endif
		endif
		// Gratuidade (Tabelas: BH6)
		if lSucess
			BH6->(dbSetorder(1))
			if BH6->( msSeek(xFilial("BH6")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBH6 := FWLoadModel("PLSA260BH6")
				oModelBH6:setOperation(MODEL_OPERATION_DELETE)
				oModelBH6:activate()

				lSucess := oModelBH6:vldData()
				if lSucess
					oModelBH6:commitData()
				endif

				freeObj(oModelBH6)	
				restArea(aAreaBA1)
			endif
		endif
		// Cobertura - Grupos Determinados (Tabelas: BFE, BVI, BVJ)
		if lSucess
			BFE->(dbSetOrder(1))
			if BFE->(msSeek(xFilial("BFE")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBFE := FWLoadModel("PLSA260BFE")
				oModelBFE:setOperation(MODEL_OPERATION_DELETE)
				oModelBFE:activate()

				lSucess := oModelBFE:vldData()
				if lSucess
					oModelBFE:commitData()
				endif

				freeObj(oModelBFE)	
				restArea(aAreaBA1)
			endif
		endif
		// Cobertura - Procedimentos (Tabelas: BFG, BVM)
		if lSucess
			BFG->(dbSetOrder(1))
			if BFG->(msSeek(xFilial("BFG")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBFG := FWLoadModel("PLSA260BFG")
				oModelBFG:setOperation(MODEL_OPERATION_DELETE)
				oModelBFG:activate()

				lSucess := oModelBFG:vldData()
				if lSucess
					oModelBFG:commitData()
				endif

				freeObj(oModelBFG)	
				restArea(aAreaBA1)
			endif
		endif
		// Cobertura - Grupo de quantidade (Tabelas: BW9, BWA)
		if lSucess
			BW9->(dbSetOrder(1))
			if BW9->(msSeek(xFilial("BW9")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBW9 := FWLoadModel("PLSA260BW9")
				oModelBW9:setOperation(MODEL_OPERATION_DELETE)
				oModelBW9:activate()

				lSucess := oModelBW9:vldData()
				if lSucess
					oModelBW9:commitData()
				endif

				freeObj(oModelBW9)	
				restArea(aAreaBA1)
			endif
		endif
		// Classe de carência (Tabelas: BFO)
		if lSucess
			BFO->(dbSetOrder(1))
			if BFO->(msSeek(xFilial("BFO")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBFO := FWLoadModel("PLSA260BFO")
				oModelBFO:setOperation(MODEL_OPERATION_DELETE)
				oModelBFO:activate()

				lSucess := oModelBFO:vldData()
				if lSucess
					oModelBFO:commitData()
				endif

				freeObj(oModelBFO)	
				restArea(aAreaBA1)
			endif
		endif
		// Situaçãoes adversas (Tabelas: BHH)
		if lSucess
			BHH->(dbsetOrder(1))
			if BHH->(msSeek(xFilial("BHH")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBHH := FWLoadModel("PLSA260BHH")
				oModelBHH:setOperation(MODEL_OPERATION_DELETE)
				oModelBHH:activate()

				lSucess := oModelBHH:vldData()
				if lSucess
					oModelBHH:commitData()
				endif

				freeObj(oModelBHH)	
				restArea(aAreaBA1)
			endif
		endif
		// Faixa especifica do beneficiário (Tabelas: BDK, BDQ, BYB)
		if lSucess
			BDK->(dbSetOrder(1))
			if BDK->(msSeek(xFilial("BDK")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				aAreaBA1 := BA1->(getArea())

				oModelBDK := FWLoadModel("PLSA260BDQ") // Nome do modelo é BDQ, mas a tabela master é BDK
				oModelBDK:setOperation(MODEL_OPERATION_DELETE)
				oModelBDK:activate()

				lSucess := oModelBDK:vldData()
				if lSucess
					oModelBDK:commitData()
				endif

				freeObj(oModelBDK)	
				restArea(aAreaBA1)
			endif
		endif
		// Grupo de rol de procedimentos (Tabelas: B1W)
		B1W->(dbSetOrder(1))
		if B1W->(msSeek(xFilial("B1W")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !B1W->(eof()) .and. B1W->(B1W_CODINT+B1W_CODEMP+B1W_MATRIC+B1W_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				B1W->(reclock("B1W", .f.))
					B1W->(dbDelete())
				B1W->(msUnlock())

				B1W->(dbSkip())
			endDo
		endif
		// Cancelamento Reajuste (Tabelas: BYW)
		BYW->(dbSetOrder(1))
		if BYW->(msSeek(xFilial("BYW")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			while !BYW->(eof()) .and. BYW->(BYW_CODINT+BYW_CODEMP+BYW_MATRIC+BYW_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BYW->(reclock("BYW", .f.))
					BYW->(dbDelete())
				BYW->(msUnlock())

				BYW->(dbSkip())
			endDo
		endif
		// Histório de emissão de carterinhas (Tabelas: BED)
		BED->(dbSetOrder(9))
		if BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) )
			while !BED->(eof()) .and. BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				BED->(reclock("BED", .f.))
					BED->(dbDelete())
				BED->(msUnlock())

				BED->(dbSkip())
			endDo
		endif
		// Entrevista Qualificada (Tabelas: BXA, BXC, BXB, BXD)
		BXA->(dbSetOrder(1))
		if BXA->(msSeek(xFilial("BXA")+BA1->(BA1_NUMENT+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))
			BXA->(recLock("BXA", .f.))
				BXA->(dbDelete())
			BXA->(msUnlock())
		endif

		BXC->(dbSetOrder(3))
		if BXC->(msSeek(xFilial("BXC")+BA1->(BA1_NUMENT+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))
			while !BXC->(eof()) .and. BXC->BXC_NUMERO == BA1->BA1_NUMENT .and. BXC->BXC_USUARI == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

				BXB->(dbSetOrder(1))
				if BXB->(msSeek(xFilial("BXB")+BA1->BA1_NUMENT+BXC->BXC_TIPREG))
					while !BXB->(eof()) .and. BXB->BXB_NUMERO == BA1->BA1_NUMENT .and. BXB->BXB_TIPREG == BXC->BXC_TIPREG
						BXB->(recLock("BXB", .f.))
							BXB->(dbDelete())
						BXB->(msUnlock())

						BXB->(dbSkip())
					endDo
				endif

				BXD->(dbSetorder(1))
				if BXD->(msSeek(xFilial("BXD")+BA1->BA1_NUMENT+BXC->BXC_TIPREG))
					while !BXD->(eof()) .and. BXD->BXD_NUMERO == BA1->BA1_NUMENT .and. BXD->BXD_TIPREG == BXC->BXC_TIPREG
						BXD->(recLock("BXD", .f.))
							BXD->(dbDelete())
						BXD->(msUnlock())

						BXD->(dbSkip())
					endDo
				endif

				BXC->(recLock("BXC", .f.))
					BXC->(dbDelete())
				BXC->(msUnlock())

				BXC->(dbSkip())
			endDo
		endif

	endif

return lSucess

/*/{Protheus.doc} delFamilyReg
Exclui os cadastros relacionados a família: Tabela BF1, BJK, BC3 etc

@type static function
@version Protheus 12.1.2310 
@author vinicius.queiros
@param cCodInt, character, Código da operadora
@param cCodEmp, character, Código da empresa
@param cMatric, character, Mátricula da família
@since 11/05/2023
/*/
Static Function delFamilyReg(cCodInt, cCodEmp, cMatric)

	local aAreaBA3 := {}
	local oModelBF1 := nil
	local oModelBJK := nil
	local oModelBJL := nil
	local oModelBH5 := nil
	local oModelBFC := nil
	local oModelBFD := nil
	local oModelBW7 := nil
	local oModelBFJ := nil
	local oModelBC3 := nil
	local oModelBYG := nil
	local oModelBGT := nil
	local lSucess := .t.

	BA3->(dbSetOrder(1))
	if BA3->(msSeek(xFilial("BA3")+cCodInt+cCodEmp+cMatric))
		// Opcional da Família (BF1, BK0, BBY, BG0)
		BF1->(dbSetOrder(1))
		if BF1->(msSeek(xFilial("BF1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
			aAreaBA3 := BA3->(getArea())
			
			oModelBF1 := FWLoadModel("PLS260BF1MVC")
			oModelBF1:setOperation(MODEL_OPERATION_DELETE)
			oModelBF1:activate()

			lSucess	:= oModelBF1:vldData()
			if lSucess
				oModelBF1:commitData()
			endif

			freeObj(oModelBF1)
			restArea(aAreaBA3)
		endif
		// Forma de Cobrança da Família (BJK, BBU, BFY)
		if lSucess
			BJK->(dbSetOrder(1))
			if BJK->(msSeek(xFilial("BJK")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBJK := FWLoadModel("PLSA260BJK")
				oModelBJK:setOperation(MODEL_OPERATION_DELETE)
				oModelBJK:activate()

				lSucess	:= oModelBJK:vldData()
				if lSucess
					oModelBJK:commitData()
				endif

				freeObj(oModelBJK)
				restArea(aAreaBA3)
			endif
		endif
		// Taxa de Adesão da Família (BJL, BRX, BFZ)
		if lSucess
			BJL->(dbSetOrder(1))
			if BJL->(msSeek(xFilial("BJL")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBJL := FWLoadModel("PLSA260BJL")
				oModelBJL:setOperation(MODEL_OPERATION_DELETE)
				oModelBJL:activate()

				lSucess	:= oModelBJL:vldData()
				if lSucess
					oModelBJL:commitData()
				endif

				freeObj(oModelBJL)
				restArea(aAreaBA3)
			endif
		endif
		// Gratuidade da Família (BH5)
		if lSucess
			BH5->(dbSetOrder(1))
			if BH5->(msSeek(xFilial("BH5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBH5 := FWLoadModel("PLSA260BH5")
				oModelBH5:setOperation(MODEL_OPERATION_DELETE)
				oModelBH5:activate()

				lSucess	:= oModelBH5:vldData()
				if lSucess
					oModelBH5:commitData()
				endif

				freeObj(oModelBH5)
				restArea(aAreaBA3)
			endif
		endif
		// Cobertura - Grupos de Cobertura (BFC, BVC)
		if lSucess
			BFC->(dbSetOrder(1))
			if BFC->(msSeek(xFilial("BFC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBFC := FWLoadModel("PLSA260BFC")
				oModelBFC:setOperation(MODEL_OPERATION_DELETE)
				oModelBFC:activate()

				lSucess	:= oModelBFC:vldData()
				if lSucess
					oModelBFC:commitData()
				endif

				freeObj(oModelBFC)
				restArea(aAreaBA3)
			endif
		endif
		// Cobertura - Procedimentos (BFD, BVF)
		if lSucess
			BFD->(dbSetOrder(1))
			if BFD->(msSeek(xFilial("BFD")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBFD := FWLoadModel("PLSA260BFD")
				oModelBFD:setOperation(MODEL_OPERATION_DELETE)
				oModelBFD:activate()

				lSucess	:= oModelBFD:vldData()
				if lSucess
					oModelBFD:commitData()
				endif

				freeObj(oModelBFD)
				restArea(aAreaBA3)
			endif
		endif
		// Cobertura - Grupo de Quantidade (BW7)
		if lSucess
			BW7->(dbSetOrder(1))
			if BW7->(msSeek(xFilial("BW7")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBW7 := FWLoadModel("PLSA260BW7")
				oModelBW7:setOperation(MODEL_OPERATION_DELETE)
				oModelBW7:activate()

				lSucess	:= oModelBW7:vldData()
				if lSucess
					oModelBW7:commitData()
				endif

				freeObj(oModelBW7)
				restArea(aAreaBA3)
			endif
		endif
		// Cobertura - Classe de Carência (BFJ)
		if lSucess
			BFJ->(dbSetOrder(1))
			if BFJ->(msSeek(xFilial("BFJ")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBFJ := FWLoadModel("PLSA260BFJ")
				oModelBFJ:setOperation(MODEL_OPERATION_DELETE)
				oModelBFJ:activate()

				lSucess	:= oModelBFJ:vldData()
				if lSucess
					oModelBFJ:commitData()
				endif

				freeObj(oModelBFJ)
				restArea(aAreaBA3)
			endif
		endif
		// Histórico do Bloqueio da Família
		If lSucess
			BC3->( dbSetorder(1) )
			If BC3->(MsSeek(xFilial("BC3")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())

				oModelBC3 := FWLoadModel("PLSA260BC3")
				oModelBC3:setOperation(MODEL_OPERATION_DELETE)
				oModelBC3:activate()

				lSucess := oModelBC3:vldData()
				if lSucess
					oModelBC3:commitData()
				Endif

				freeObj(oModelBC3)
				restArea(aAreaBA3)
			EndIf
		Endif
		// Histórico de Reajuste da Taxa de Adesão da Família
		if lSucess
			BYG->(dbSetOrder(1))
			if BYG->(msSeek(xFilial("BYG")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBYG := FWLoadModel("PLSA260BYG")
				oModelBYG:setOperation(MODEL_OPERATION_DELETE)
				oModelBYG:activate()

				lSucess	:= oModelBYG:vldData()
				if lSucess
					oModelBYG:commitData()
				endif

				freeObj(oModelBYG)
				restArea(aAreaBA3)
			endif
		endif
		// Histórico de Bloqueio dos Opcionais da Família
		if lSucess
			BGT->(dbSetOrder(1))
			if BGT->(msSeek(xFilial("BGT")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				aAreaBA3 := BA3->(getArea())
				
				oModelBGT := FWLoadModel("PLSA260BGT")
				oModelBGT:setOperation(MODEL_OPERATION_DELETE)
				oModelBGT:activate()

				lSucess	:= oModelBGT:vldData()
				if lSucess
					oModelBGT:commitData()
				endif

				freeObj(oModelBGT)
				restArea(aAreaBA3)
			endif
		endif
	endif

return lSucess

/*/{Protheus.doc} PFldGetBA1
Retorna o valor do campo informado, sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 31/07/2023
@param xFields, variant, Campos para busca do valor
@param oModel, object, modelo de dados já instanciado
@return xFieldValue, Retornar o valor dos campos informados concatenados
/*/
function PFldGetBA1(xFields, oModel)	

	local xFieldValue := nil
	local nCont as numeric
	local lIsModel := .f. as logical
	
	default oModel := fwModelActive()

	lIsModel := valType(oModel) <> "U" .and. oModel:isActive()

	if valType(xFields) == "A"
		xFieldValue := ""

		for nCont := 1 to len(xFields)
			if lIsModel
				if valType(oModel:getModel("BA1MASTER")) <> "U" .and. oModel:getModel("BA1MASTER"):getStruct():hasField(xFields[nCont])
					xFieldValue += oModel:getValue("BA1MASTER", xFields[nCont])
				else
					xFieldValue += &(substr(xFields[nCont], 1, 3)+"->"+xFields[nCont])
				endif
			else
				xFieldValue += iif(valType(&("M->"+xFields[nCont])) == "U", "", &("M->"+xFields[nCont]))
			endif
		next nCont
	else
		if lIsModel
			if valType(oModel:getModel("BA1MASTER")) <> "U" .and. oModel:getModel("BA1MASTER"):getStruct():hasField(xFields)
				xFieldValue := oModel:getValue("BA1MASTER", xFields)
			else
				xFieldValue := &(substr(xFields, 1, 3)+"->"+xFields)
			endif		
		else
			xFieldValue := &("M->"+xFields)
		endif
	endif

return xFieldValue

/*/{Protheus.doc} PFldGetBA3
Retorna o valor do campo informado, sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 31/07/2023
@param xFields, variant, Campos para busca do valor
@param oModel, object, modelo de dados já instanciado
@return xFieldValue, Retornar o valor dos campos informados concatenados
/*/
function PFldGetBA3(xFields, oModel)	

	local xFieldValue := nil
	local nCont as numeric
	local lIsModel := .f. as logical
	
	default oModel := fwModelActive()

	lIsModel := valType(oModel) <> "U" .and. oModel:isActive()

	if valType(xFields) == "A"
		xFieldValue := ""

		for nCont := 1 to len(xFields)
			if lIsModel
				if valType(oModel:getModel("BA3MASTER")) <> "U" .and. oModel:getModel("BA3MASTER"):getStruct():hasField(xFields[nCont])
					xFieldValue += oModel:getValue("BA3MASTER", xFields[nCont])
				else
					xFieldValue += &(substr(xFields[nCont], 1, 3)+"->"+xFields[nCont])
				endif
			else
				xFieldValue += iif(valType(&("M->"+xFields[nCont])) == "U", "", &("M->"+xFields[nCont]))
			endif
		next nCont
	else
		if lIsModel
			if valType(oModel:getModel("BA3MASTER")) <> "U" .and. oModel:getModel("BA3MASTER"):getStruct():hasField(xFields)
				xFieldValue := oModel:getValue("BA3MASTER", xFields)
			elseif valType(oModel:getModel("BA3DETAIL")) <> "U" .and. oModel:getModel("BA3DETAIL"):getStruct():hasField(xFields)
				xFieldValue := oModel:getValue("BA3DETAIL", xFields)
			else
				xFieldValue := &(substr(xFields, 1, 3)+"->"+xFields)
			endif		
		else
			xFieldValue := &("M->"+xFields)
		endif
	endif

return xFieldValue

/*/{Protheus.doc} PlGfPlaAct
Verifica se o plano informado está com o status ativo no cadastro

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 31/07/2023
@param cPlanAlias, character, tabela para buscar os campos no model ou na memoria
@return lCheck, retorna se o plano está ativo ou bloqueado
@obs semelhante a função PLSA260GCF()
/*/
function PlGfPlaAct(cPlanAlias)

	local aAreaBI3 := BI3->(getArea()) as array
	local lCheck := .f. as logical
	local cPlanKey := "" as character

	do case
		case cPlanAlias == "BA1"
			cPlanKey := PFldGetBA1({"BA1_CODINT", "BA1_CODPLA", "BA1_VERSAO"})
	endcase
	
	BI3->(dbSetOrder(1))
	if BI3->(msSeek(xFilial("BI3")+cPlanKey)) .and. BI3->BI3_STATUS == "2"
		if BI3->BI3_SITANS $ "2,3"
			help("", 1, "PLSSITANS")
		else
			help("", 1, "PLSA260003")
		endif
		lCheck := .f.
	else
		lCheck := .t.
	endif
	
	restArea(aAreaBI3)

return lCheck

/*/{Protheus.doc} PlGfChkPlan
Valida a data analisando a versao do plano no contrato

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 01/08/2023
@param cPlanAlias, character, tabela para buscar os campos no model ou na memoria
@return lCheck, retorna se o plano está valido
@obs semelhante a função PLSA260BA3()
/*/
function PlGfChkPlan(cPlanAlias)

	local lCheck := .f.
	local oModel := fwModelActive()
	local oPlanData := JsonObject():new()

	do case
		case cPlanAlias == "BA1"
			oPlanData["cCodPla"] := iif(empty(PFldGetBA1("BA1_CODPLA", oModel)), PFldGetBA3("BA3_CODPLA", oModel), PFldGetBA1("BA1_CODPLA", oModel))
			oPlanData["dData"] := iif(empty(PFldGetBA1("BA1_DATINC", oModel)), PFldGetBA3("BA3_DATBAS", oModel), PFldGetBA1("BA1_DATINC", oModel))
			oPlanData["cCodInt"] := PFldGetBA3("BA3_CODINT", oModel)
			oPlanData["cCodEmp"] := PFldGetBA3("BA3_CODEMP", oModel)
			oPlanData["cNumCon"] := PFldGetBA3("BA3_CONEMP", oModel)
			oPlanData["cVerCon"] := PFldGetBA3("BA3_VERCON", oModel)
			oPlanData["cSubCon"] := PFldGetBA3("BA3_SUBCON", oModel)
			oPlanData["cVerSub"] := PFldGetBA3("BA3_VERSUB", oModel)
			oPlanData["lAtuVar"] := .f.
			oPlanData["cCodOpc"] := nil
			oPlanData["cVerPla"] := iif(empty(PFldGetBA1("BA1_VERSAO", oModel)), PFldGetBA3("BA3_VERSAO", oModel), PFldGetBA3("BA1_VERSAO", oModel))
	endcase

	BG9->(dbSetOrder(1))
	BG9->(msSeek(xFilial("BG9")+oPlanData["cCodInt"]+oPlanData["cCodEmp"]))

	if type("nOpcx") <> "N" .and. valType(oModel) <> "U" .and. oModel:isActive()
		nOpcx := oModel:getOperation() // Variavel private
	endif

	if type("lJuridico") <> "L" .and. valType(oModel) <> "U" .and. oModel:isActive()
		lJuridico := !empty(PFldGetBA3("BA1_CONEMP", oModel)) // Variavel private
	endif

	lCheck := PLSA260PLA(oPlanData["cCodPla"], oPlanData["dData"], oPlanData["cCodInt"], oPlanData["cCodEmp"], oPlanData["cNumCon"],;
						 oPlanData["cVerCon"], oPlanData["cSubCon"], oPlanData["cVerSub"], oPlanData["lAtuVar"], oPlanData["cCodOpc"],;
						 oPlanData["cVerPla"])[1]

return lCheck

/*/{Protheus.doc} PlGfVldSA3
Verifica se o vendedor pertence a equipe na data da inclusao

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 01/08/2023
@param cSeller, character, código do vendedor
@param cTeamCode, character, código da equipe
@param dDateInc, date, date de inclusão para vefificação
@return lValid, retorna se o vendedor está válido para equipe e data informada
@obs semelhante a função PL903SA3()
/*/
function PlGfVldSA3(cSeller, cTeamCode, dDateInc)

	local lValid := .f. as logical
	local cQuery := "" as character
	local nCountReg := 0 as numeric

	if existCpo("SA3", cSeller, 1)
		if empty(cTeamCode) .or. empty(dDateInc)
			lValid := .t.
		else
			cQuery := "SELECT COUNT(BXM.R_E_C_N_O_) COUNTREG FROM "+retSQLName("BXL")+" BXL"
			cQuery += " INNER JOIN "+retSQLName("BXM")+" BXM "
			cQuery += "  ON BXM.BXM_FILIAL = '"+xFilial("BXM")+"' "
			cQuery += " AND BXM.BXM_SEQBXL = BXL.BXL_SEQ "
			cQuery += " AND BXM.BXM_CODVEN = '"+cSeller+"'"
			cQuery += " AND BXM.D_E_L_E_T_ = ' ' "

			cQuery += " WHERE BXL.BXL_FILIAL = '"+xFilial("BXL")+"' "
			cQuery += "   AND BXL.BXL_CODEQU = '"+cTeamCode+"'"
			cQuery += "   AND '"+dtos(dDateInc)+"' >= BXL.BXL_VLDINI "
			cQuery += "   AND (BXL.BXL_VLDFIM = ' ' OR '"+dtos(dDateInc)+"' <= BXL.BXL_VLDFIM)"
			cQuery += "   AND BXL.D_E_L_E_T_ = ' ' "

			nCountReg := MPSysExecScalar(cQuery, "COUNTREG")

			if nCountReg > 0
				lValid := .t.
			else
				lValid := .f.
				help("", 1, "PL903SA3")
			endif
		endif
	endif

return lValid

/*/{Protheus.doc} PlValidGra
Valida os campos de Mês e Ano da Gratuidade do Familia ou do Benenficiário,
sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author Giovanna Charlo
@since 27/10/2023
@param xFields, variant, Campos para busca do valor
@return lCheck, retorna se os campos Ano e Mês estao de acordo com a regra
/*/
function PlValidGra(xFields)	

	Local nCont := 0
	Local lIsModel := .f. 
	Local lCheck := .t. 
	Local cCampo := ""
	Local cMesBase := SubStr(dtos(dDataBase),5, 2)
	Local cAnoBase := cValToChar(Year(dDataBase))
	Local oModel := fwModelActive()
	Local cAnoIni := ""
	Local cAnoFim := ""
	Local cMesIni := ""
	Local cMesFim := ""
	Local cModel := ""

	lIsModel := valType(oModel) <> "U" .and. oModel:isActive()

	For nCont := 1 to len(xFields)

		cCampo := substr(xFields[nCont], 5) 

		If lIsModel
				if valType(oModel:getModel("BH5DETAIL")) <> "U" .and. oModel:getModel("BH5DETAIL"):getStruct():hasField(xFields[nCont])
					cModel := "BH5DETAIL"
				elseif valType(oModel:getModel("BH6DETAIL")) <> "U" .and. oModel:getModel("BH6DETAIL"):getStruct():hasField(xFields[nCont])
					cModel := "BH6DETAIL"
				Endif

	 			Do Case 
					Case cCampo = "ANOINI"
						cAnoIni := oModel:getValue(cModel, xFields[nCont])
					Case cCampo = "ANOFIM"
						cAnoFim := oModel:getValue(cModel, xFields[nCont])
					Case cCampo = "MESINI"
						cMesIni :=  oModel:getValue(cModel, xFields[nCont])
					Case cCampo = "MESFIM"
						cMesFim := oModel:getValue(cModel, xFields[nCont])
				EndCase
		Else
			Do Case 
				Case cCampo = "ANOINI"
					cAnoIni := &("M->"+ xFields[nCont])
				Case cCampo = "ANOFIM"
					cAnoFim := &("M->"+ xFields[nCont])
				Case cCampo = "MESINI"
					cMesIni :=  &("M->"+ xFields[nCont])
				Case cCampo = "MESFIM"
					cMesFim := &("M->"+ xFields[nCont])
			EndCase
		endif
	Next nCont

	If !Empty(cAnoIni) .And. !Empty(cAnoFim) .And. !Empty(cMesIni) .And. !Empty(cMesFim)

		If cMesIni > "12" .Or. cMesFim > "12"
			//Mês Inicial e Final não podem ser mariores do que 12 meses!
			Help(NIL, NIL, OemtoAnsi(STR0317), NIL, OemtoAnsi(STR0311), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemtoAnsi(STR0312)})
			lCheck := .F.
		Elseif cAnoIni < cAnoBase
			///"Ano inicial não pode ser inferior ao ano da data de lançamento."
			Help(NIL, NIL,  OemtoAnsi(STR0317), NIL, OemtoAnsi(STR0230), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemtoAnsi(STR0313)})
			lCheck := .F.
		Elseif cAnoBase == cAnoIni .And. cMesBase > cMesIni
			//"Mês e ano inicial não podem ser inferior ao mês e ano da data de lançamento."
			Help(NIL, NIL, OemtoAnsi(STR0317), NIL,OemtoAnsi(STR0231), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemtoAnsi(STR0314)})
			lCheck := .F.
	
		Elseif cAnoIni == cAnoFim .And. cMesIni > cMesFim
			//"O intervalo entre as datas é invalido! O mês e ano final não podem ser inferior ao mês e ano inicial."
			Help(NIL, NIL,  OemtoAnsi(STR0317), NIL,OemtoAnsi(STR0232), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemtoAnsi(STR0315)})
			lCheck := .F.
		Elseif cAnoFim < cAnoIni
			//"Ano final não pode ser inferior ao ano inicial."
			Help(NIL, NIL, OemtoAnsi(STR0317), NIL,OemtoAnsi(STR0233), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemtoAnsi(STR0316)})
			lCheck := .F.
		Endif
	Endif
return lCheck
