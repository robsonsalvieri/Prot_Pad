#Include 'Protheus.ch'
#Include 'teca202.ch'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TECA202
Cadastro de Área de Supervisão
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples) -> ->
@see (links_or_references)
/*/
Function TECA202()
Local oBrw := FWmBrowse():New()
Local lAreaSup := SuperGetMV( 'MV_GSARSUP', , .F. )

oBrw:SetDescription(STR0001) // STR0001 - "Área de Supervisão"
oBrw:SetAlias("TGS")

If lAreaSup .And. TGS->( FieldPos( 'TGS_DESCRI' ) )  > 0
	oBrw:SetOnlyFields( { 'TGS_COD', 'TGS_DESCRI' } )
Else
	oBrw:SetOnlyFields( { 'TGS_COD', 'TGS_REGIAO', 'TGS_DESREG', 'TGS_DPTO', 'TGS_DESDPT', 'TGS_SUPERV', 'TGS_NOMSUP' } )
EndIf

oBrw:SetMenuDef("TECA202")
oBrw:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Funcao de Menu do Cadastro de Área de Supervisão
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0003 Action "AxPesqui"        OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.TECA202" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina Title STR0005 Action "VIEWDEF.TECA202" OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina Title STR0006 Action "VIEWDEF.TECA202" OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina Title STR0007 Action "VIEWDEF.TECA202" OPERATION 5 ACCESS 0	//"Excluir"
ADD OPTION aRotina Title STR0009 Action "TECR027()"		  OPERATION 8 ACCESS 0	//"Relatório de Supervisores"

Return aRotina

/*/{Protheus.doc} ModelDef
Funcao do Modelo do Cadastro de Área de Supervisão
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oStruTGS	:= FWFormStruct(1,"TGS")
Local oStruTXI	:= FWFormStruct(1,'TXI')
Local oModel	:= MPFormModel():New("TECA202")
Local lAreaSup	:= SuperGetMV( 'MV_GSARSUP', , .F. )
Local aUniqueLin:= {}

If lAreaSup .And. oStruTGS:HasField('TGS_DESCRI') .And. oStruTXI:HasField('TXI_CODTGS')
	oStruTGS:RemoveField( 'TGS_REGIAO' )
	oStruTGS:RemoveField( 'TGS_DESREG' )
	oStruTGS:RemoveField( 'TGS_DPTO' )
	oStruTGS:RemoveField( 'TGS_DESDPT' )
	oStruTGS:RemoveField( 'TGS_SUPERV' )
	oStruTGS:RemoveField( 'TGS_NOMSUP' )

	If TXI->(ColumnPos("TXI_CODAA0")) > 0
		xAux := FwStruTrigger( 'TXI_CODAA0', 'TXI_DSCAA0','Posicione("AA0",1,xFilial("AA0")+FwFldGet("TXI_CODAA0"),"AA0->AA0_DESCRI")', .F. )
		oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	xAux := FwStruTrigger( 'TXI_CODTEC', 'TXI_NOMTEC','POSICIONE("AA1",1,XFILIAL("AA1")+M->TXI_CODTEC,"AA1_NOMTEC")', .F. )
	oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	oStruTXI:RemoveField( 'TXI_CODAA0' )
	oStruTXI:RemoveField( 'TXI_DSCAA0' )

	oStruTXI:SetProperty( "TXI_LOCAL", MODEL_FIELD_OBRIGAT, .F. )

	oModel:AddFields( "MODEL_TGS", /*cOwner*/, oStruTGS )
	oModel:AddGrid( "TXIDETAIL", "MODEL_TGS", oStruTXI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( "TXIDETAIL", { {"TXI_FILIAL","xFilial('TXI')"}, {"TXI_CODTGS" ,"TGS_COD" } }, TXI->(IndexKey(3)) )
	oModel:GetModel("MODEL_TGS"):SetPrimaryKey( {"TGS_COD"} )

	If !IsBlind()
		aUniqueLin := {"TXI_CODTEC", "TXI_CODTGS", "TXI_LOCAL", "TXI_FUNCAO", "TXI_TURNO", "TXI_DTINI", "TXI_DTFIM"}
		If TXI->(ColumnPos("TXI_PERIOD")) > 0
			AADD(aUniqueLin, "TXI_PERIOD")
		EndIf
		oModel:GetModel( 'TXIDETAIL' ):SetUniQueLine(aUniqueLin)
	EndIf
Else
	oStruTGS:RemoveField( 'TGS_DESCRI' )

	oModel:AddFields( "MODEL_TGS", /*cOwner*/, oStruTGS )
	oModel:GetModel("MODEL_TGS"):SetPrimaryKey( {"TGS_COD"} )
EndIf

Return oModel

/*/{Protheus.doc} ViewDef
View do Cadastro de Área de Supervisão
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel   := FWLoadModel("TECA202")
Local oStruTGS := FWFormStruct(2,"TGS")
Local oStruTXI := FWFormStruct(2,"TXI")
Local oView    := FWFormView():New()
Local lAreaSup := SuperGetMV( 'MV_GSARSUP', , .F. )

oStruTXI:RemoveField( "TXI_DATABA" )
oStruTXI:RemoveField( "TXI_CODIGO" )
oStruTXI:RemoveField( "TXI_UPD" )

oView:SetModel(oModel)

If lAreaSup .And. oStruTGS:HasField('TGS_DESCRI') .And. oStruTXI:HasField('TXI_CODTGS')
	oStruTGS:RemoveField( 'TGS_REGIAO' )
	oStruTGS:RemoveField( 'TGS_DESREG' )
	oStruTGS:RemoveField( 'TGS_DPTO' )
	oStruTGS:RemoveField( 'TGS_DESDPT' )
	oStruTGS:RemoveField( 'TGS_SUPERV' )
	oStruTGS:RemoveField( 'TGS_NOMSUP' )

	oStruTXI:RemoveField( 'TXI_CODAA0' )
	oStruTXI:RemoveField( 'TXI_DSCAA0' )
	oStruTXI:RemoveField( 'TXI_CODTGS' )
	oStruTXI:RemoveField( 'TXI_DSCTGS' )

	oStruTXI:SetProperty('TXI_CODTEC', MVC_VIEW_ORDEM ,'01')
	oStruTXI:SetProperty('TXI_NOMTEC', MVC_VIEW_ORDEM ,'02')
	oStruTXI:SetProperty('TXI_LOCAL' , MVC_VIEW_LOOKUP,'ABSTGS')

	oView:AddField("VIEW_TGS", oStruTGS, "MODEL_TGS")
	oView:AddGrid("VIEW_TXI", oStruTXI, "TXIDETAIL" )

	oView:CreateHorizontalBox("FIELDSTGS", 30 )
	oView:CreateHorizontalBox("FIELDSTXI", 70 )

	oView:SetOwnerView("VIEW_TGS", "FIELDSTGS")
	oView:SetOwnerView("VIEW_TXI", "FIELDSTXI")

	oView:EnableTitleView( "VIEW_TXI", STR0008 ) // STR0008 - "Locais"
Else
	oStruTGS:RemoveField( 'TGS_DESCRI' )

	oView:AddField( "VIEW_TGS", oStruTGS, "MODEL_TGS" )


	oView:CreateHorizontalBox("FIELDSTGS", 100 )

	oView:SetOwnerView( "VIEW_TGS", "FIELDSTGS" )
EndIf

oView:EnableTitleView( "VIEW_TGS", STR0001 ) // STR0001 - "Área de Supervisão"

Return oView

/*/{Protheus.doc} AT202GetSup
Funcao que retorna o codigo do superviso de acordo
com amarracao no cadastro de departamentos.
@param	cDpto,caractere,Código do departamento que foi realizada atualização no cadastro de departamentos
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${cRet}, ${Codigo do Supervisor}
/*/
Function AT202GetSup(cDpto)
Local cRet 		:= "" 							// Retorno da função - Supervisor
Local aSQBAlias	:= SQB->(GetArea())
Local aAA1Alias	:= AA1->(GetArea())

Default cDpto 	:= ""							// Departamento default - vazio

// -------------------------------
// Abertura dos Alias e indices
DbSelectArea("SQB")	// Alias SQB - Departamentos
SQB->(DbSetOrder(1)) // QB_FILIAL + QB_DEPTO

DbSelectArea("AA1")	// Alias AA1 - Supervisor
AA1->(DbSetOrder(7)) // AA1_FILIAL + AA1_CDFUNC + AA1_FUNFIL

// ----------------------------------------
// Verifica se encontro o departamento
If SQB->(DbSeek(xFilial("SQB")+cDpto))
// ----------------------------------------------------------------------------------------------------
// Verifica se extiste Filial Resp. e Matr.Resp. preenchido, se sim, procura na AA1 o supervisor.
	If !Empty(SQB->QB_FILRESP+SQB->QB_MATRESP) .AND. AA1->(DbSeek(xFilial("AA1")+SQB->QB_MATRESP+SQB->QB_FILRESP))
		cRet := AA1->AA1_CODTEC
	EndIf
EndIf

// Retorna area - SQB
SQB->(RestArea(aSQBAlias))
AA1->(RestArea(aAA1Alias))
Return cRet

/*/{Protheus.doc} AT202GetSup
Funcao criada para atender RH. Chamada dentro da rotina
de gravacao do fonte CSAA100. Atualiza os registros da
TGS de acordo com nova amarracao do departamento

@param cDepto,caractere,Código do departamento que foi realizada atualização no cadastro de departamentos
@param	cFilSuperv,caractere,Filial do supervisor atribuído ao departamento
@param	cMatSuperv	,caractere,Matricula do supervisor atribuído ao departamento
@return nil	Nenhum retorno.
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
/*/
Function At202AtSup (cDepto, cFilSuperv , cMatSuperv)
Local 	cChaveWhl		:= ""
Local 	aTGSArea 		:= TGS->(Getarea())
Local 	aAA1Area 		:= AA1->(Getarea())
Local 	nTamDpto		:= TamSX3("TGS_DPTO")[1]
Local 	nTamFilSp		:= TamSX3("AA1_FUNFIL")[1]
Local 	nTamCdFun		:= TamSX3("AA1_CDFUNC")[1]
Local	cSuperv		:= "" 

Default cDepto		:= ""
Default cFilSuperv	:= ""
Default cMatSuperv	:= ""

DbSelectArea("AA1")	// Alias AA1 - Supervisor
AA1->(DbSetOrder(7)) // AA1_FILIAL + AA1_CDFUNC + AA1_FUNFIL

DbSelectArea("TGS")	//	Alias TGS - Supervisão
TGS->(DbSetOrder(4)) // TGS_FILIAL + TGS_DPTO

// So' realiza as alteracoes caso todas as informacoes seja passada, e caso encontre o Filial+Func na AA1
If !Empty(cDepto) .AND. !Empty(cFilSuperv) .AND. !Empty(cMatSuperv) .AND. ;
	AA1->( DbSeek(xFilial("AA1")+PadR(cMatSuperv,nTamCdFun)+PadR(cFilSuperv,nTamFilSp)) )

	cSuperv := AA1->AA1_CODTEC
	If TGS->(DbSeek(xFilial("TGS")+PadR(cDepto,nTamDpto)))
		cChaveWhl := TGS->TGS_FILIAL+TGS->TGS_DPTO
		While TGS->(!EOF()) .AND. (TGS->TGS_FILIAL+TGS->TGS_DPTO)==cChaveWhl
			If	TGS->(RecLock("TGS",.F.))
				TGS->TGS_SUPERV := cSuperv
				TGS->(MsUnLock())
			EndIf
			TGS->(DbSkip())
		EndDo
	EndIf

EndIf

// Restaura areas
AA1->(RestArea(aAA1Area))
TGS->(RestArea(aTGSArea))
Return NIL

/*/{Protheus.doc} At202VrfRg
Funcao para verificar se existe regiao para a filial corrente
se existir nao deve permitir a inclusao
@param	cCodReg,caractere,Código da Região.
@author Cleverson Ernesto da Silva
@since 31/05/2015
@version 1.0
@return ${lRet}, ${Variavel boleana, se permite .T. ou não .F. a inclusao}
/*/
Function At202VrfRg(cCodReg)
Local lExist 		:= .F.
Local aTGSArea	:= TGS->(GetArea())

If !Empty(cCodReg)
	// ---------------------------------------------------------------------
	// Verifica se já existe regiaado cadastrada para a filial corrente. Se existir exibe a mensagem
	TGS->(DbSetOrder(3)) // TGS_FILIAL + TGS_REGIAO
	If ( lExist := (TGS->(DbSeek(xFilial("TGS")+cCodReg))) )
		Help(,,'Help',,STR0002,1,0)	// STR0002 - "Região já cadastrada em uma área de supervisão" 
	EndIf
EndIf

TGS->(RestArea(aTGSArea))
Return !lExist
