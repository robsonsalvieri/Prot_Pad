#Include "TOTVS.CH"
#INCLUDE "TECA020A.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_NAO_RECEBE_VAL		13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static cRetEscala := ""
Static lAreaSuper := .F.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA020A
Programa de Manutencao no Cadastro de Supervisor de Postos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA020A()
Local oBrowse

lAreaSuper := SuperGetMV( 'MV_GSARSUP', , .F. )

If AA1->(ColumnPos("AA1_SUPERV")) > 0  .AND. TableInDic("TXI")


	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('AA1')
	oBrowse:SetDescription(STR0001) //"Supervisores de Postos"
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault("AA1->AA1_SUPERV == '1' ")
	oBrowse:Activate()
Else
	Help(,1,"TECA020A",,STR0002, 1) //"Necessário que o campo AA1_SUPERV e a tabela TXI estejam criados"
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao de definicao do aRotina 
@return	aRotina -  lista de aRotina 
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aMenu := {}
	Local aAt020AMnu := {}
	Local nX := 0
	Local lAt020AMnu := ExistBlock( "AT020AMNU" )

	aAdd( aMenu, { STR0021, 'VIEWDEF.TECA020A', 0, 4, 0, .T. } ) // "Vincular Postos"

	If lAt020AMnu
		aAt020AMnu := ExecBlock( "AT020AMNU", .F., .F. )

		If ValType( aAt020AMnu ) == "A" .And. Len( aAt020AMnu ) > 0
			For nX := 1 To Len( aAt020AMnu )
				AAdd( aMenu, aAt020AMnu[nX] )
			Next
		EndIf
	EndIf

Return aMenu

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados (MVC)  . 
@return	oModel - Objeto Model
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= nil
Local oStruAA1		:= FWFormModelStruct():New()
Local oStruTXI		:= FWFormStruct(1,'TXI')
Local oStrTMPTGY	:= FWFormModelStruct():New()
Local aTables 		:= {}
Local nY			:= 0
Local aFields		:= {}
Local nX            := 0
Local xAux			:= {}

oStruAA1:AddTable("AA1",{"AA1_FILIAL","AA1_CODTEC"}, STR0003) //"Atendentes"
oStrTMPTGY:AddTable("   ",{}, "   ")

AADD(aTables, {oStruAA1, "AA1"})
AADD(aTables, {oStruTXI, "TXI"})
AADD(aTables, {oStrTMPTGY, "TMP"})

For nY := 1 To LEN(aTables)

	aFields := aClone(AT020ADDef(aTables[nY][2], 1))

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_IDENTIFICADOR	],;
						aFields[nX][DEF_TIPO_DO_CAMPO	],;
						aFields[nX][DEF_TAMANHO_DO_CAMPO],;
						aFields[nX][DEF_DECIMAL_DO_CAMPO],;
						aFields[nX][DEF_CODEBLOCK_VALID	],;
						aFields[nX][DEF_CODEBLOCK_WHEN	],;
						aFields[nX][DEF_LISTA_VAL		],;
						aFields[nX][DEF_OBRIGAT			],;
						aFields[nX][DEF_CODEBLOCK_INIT	],;
						aFields[nX][DEF_CAMPO_CHAVE		],;
						aFields[nX][DEF_NAO_RECEBE_VAL		],;
						aFields[nX][DEF_VIRTUAL			])
	Next nX
	aFields := {}
Next nY

If TXI->(ColumnPos("TXI_CODAA0")) > 0
	xAux := FwStruTrigger( 'TXI_CODAA0', 'TXI_DSCAA0','Posicione("AA0",1,xFilial("AA0")+FwFldGet("TXI_CODAA0"),"AA0->AA0_DESCRI")', .F. )
	oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

oModel := MPFormModel():New('TECA020A',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AA1MASTER',/*cOwner*/,oStruAA1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({"AA1_FILIAL", "AA1_CODTEC"})

If lAreaSuper .And. oStruTXI:HasField('TXI_CODTGS')
	oStruTXI:RemoveField( 'TXI_CODAA0' )
	oStruTXI:RemoveField( 'TXI_DSCAA0' )

	oStruTXI:SetProperty("TXI_LOCAL", MODEL_FIELD_OBRIGAT, .F.)

	xAux := FwStruTrigger( 'TXI_LOCAL', 'TXI_CODTGS', 'At020aTrgLc( "TXI_LOCAL" )' )
	oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
	xAux := FwStruTrigger( 'TXI_CODTGS', 'TXI_LOCAL', 'At020aTrgLc( "TXI_CODTGS" )' )
	oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
	xAux := FwStruTrigger( 'TXI_CODTGS', 'TXI_DSCTGS', 'POSICIONE("TGS",1,FWXFILIAL("TGS")+FwFldGet("TXI_CODTGS"),"TGS_DESCRI")' )
	oStruTXI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
Else
	oStruTXI:RemoveField( 'TXI_CODTGS' )
	oStruTXI:RemoveField( 'TXI_DSCTGS' )
EndIf

oStruTXI:SetProperty("TXI_CODTEC", MODEL_FIELD_OBRIGAT, .F.)

oModel:AddGrid("TXIDETAIL","AA1MASTER",oStruTXI,{|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTXI(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) })
// Relacionamento com o GRID Principal
oModel:SetRelation("TXIDETAIL",{{"TXI_FILIAL","xFilial('TXI')"},{"TXI_CODTEC" ,"AA1_CODTEC" }}	,TXI->(IndexKey(2)))
If !IsBlind()
	If lAreaSuper .And. oStruTXI:HasField('TXI_CODTGS')
		oModel:GetModel( 'TXIDETAIL' ):SetUniQueLine({"TXI_CODTGS", "TXI_LOCAL", "TXI_FUNCAO", "TXI_TURNO", "TXI_DTINI", "TXI_DTFIM"})
	Else
		oModel:GetModel( 'TXIDETAIL' ):SetUniQueLine({"TXI_LOCAL", "TXI_FUNCAO", "TXI_TURNO", "TXI_DTINI", "TXI_DTFIM"})
	EndIf
EndIf
oModel:GetModel( 'TXIDETAIL' ):SetOptional(.T.)

oModel:AddGrid("TMPDETAIL","TXIDETAIL",oStrTMPTGY,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At020ALdG2(oGrid,lCopia)})

// Relacionamento com o GRID Principal
oModel:GetModel( 'TMPDETAIL' ):SetOnlyQuery(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetDelAllLine(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetNoDeleteLine(.T.)
oModel:SetDescription(STR0004) //"Supervisores"
oModel:GetModel( 'TXIDETAIL' ):SetDescription(STR0005) //"Locais"
oModel:GetModel( 'TMPDETAIL' ):SetDescription(STR0003) //"Atendentes"

Return oModel

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a interface para cadastro em MVC. 
@return	oView - Objeto View
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= NIL
Local oModel   := FWLoadModel('TECA020A')
Local oStruAA1		:= FWFormViewStruct():New()
Local oStruTXI		:= FWFormStruct(2,'TXI', {|cCampo| ( !AllTrim(cCampo) $"TXI_FILIAL+TXI_CODTEC+TXI_NOMTEC") },/*lViewUsado*/)
Local oStrTMPTGY	:= FWFormViewStruct():New()
Local oStruAA12		:= FWFormViewStruct():New()
Local oStruAA13		:= FWFormViewStruct():New()
Local aTables 		:= {}
Local nY			:= 0
Local aFields		:= {}
Local nX            := 0
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStruAA1, "AA1"})
AADD(aTables, {oStruTXI, "TXI"})
AADD(aTables, {oStrTMPTGY, "TMP"})
AADD(aTables, {oStruAA12, "AA12"})
AADD(aTables, {oStruAA13, "AA13"})

For nY := 1 to LEN(aTables)
	aFields := aClone(AT020ADDef(aTables[nY][2], 2))

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
						aFields[nX][DEF_ORDEM],;
						aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_HELP],;
						aFields[nX][DEF_TIPO_CAMPO_VIEW],;
						aFields[nX][DEF_PICTURE],;
						aFields[nX][DEF_PICT_VAR],;
						aFields[nX][DEF_LOOKUP],;
						aFields[nX][DEF_CAN_CHANGE],;
						aFields[nX][DEF_ID_FOLDER],;
						aFields[nX][DEF_ID_GROUP],;
						aFields[nX][DEF_COMBO_VAL],;
						aFields[nX][DEF_TAM_MAX_COMBO],;
						aFields[nX][DEF_INIC_BROWSE],;
						aFields[nX][DEF_VIRTUAL],;
						aFields[nX][DEF_PICTURE_VARIAVEL],;
						aFields[nX][DEF_INSERT_LINE])
	Next nX
	aFields := {}
Next nY

oStruAA1:RemoVeField("AA1_FILIAL")
oStruTXI:RemoveField("TXI_DATABA")
oStruTXI:RemoveField("TXI_CODIGO")

oStruTXI:RemoveField("TXI_UPD")

If lAreaSuper .And. oStruTXI:HasField('TXI_CODTGS')
	oStruTXI:RemoveField( 'TXI_CODAA0' )
	oStruTXI:RemoveField( 'TXI_DSCAA0' )

	oStruTXI:SetProperty('TXI_CODTGS', MVC_VIEW_ORDEM ,'01')
	oStruTXI:SetProperty('TXI_DSCTGS', MVC_VIEW_ORDEM ,'02')
	oStruTXI:SetProperty('TXI_LOCAL' , MVC_VIEW_LOOKUP,'ABSTGS')
Else
	oStruTXI:RemoveField( 'TXI_CODTGS' )
	oStruTXI:RemoveField( 'TXI_DSCTGS' )

	If TXI->(ColumnPos("TXI_CODAA0")) > 0
		oStruTXI:SetProperty('TXI_CODAA0', MVC_VIEW_ORDEM ,'01')
		oStruTXI:SetProperty('TXI_DSCAA0', MVC_VIEW_ORDEM ,'02')
		oStruTXI:SetProperty('TXI_LOCAL' , MVC_VIEW_LOOKUP,'ABSAA0')
	EndIf	
EndIf

If TXI->( FieldPos( "TXI_PERIOD" ) ) > 0 .And. TDW->( FieldPos( "TDW_PERIOD" ) ) > 0
	oStruTXI:SetProperty( 'TXI_TURNO' , MVC_VIEW_LOOKUP, 'SR6TXI' )
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_AA1', oStruAA1,'AA1MASTER')
oView:AddGrid('VIEW_TXI',oStruTXI,'TXIDETAIL')
oView:AddField('VIEW_AA12', oStruAA12,'AA1MASTER')
oView:AddGrid('VIEW_TMP',oStrTMPTGY,'TMPDETAIL')
oView:AddField('VIEW_AA13', oStruAA13,'AA1MASTER')

oView:CreateHorizontalBox('SUPERIOR',20)
oView:CreateHorizontalBox('DETALHE_TXI',25)
oView:CreateHorizontalBox('DETALHE_AA1',13)
oView:CreateHorizontalBox('DETALHE_TMP',35)
oView:CreateHorizontalBox('TOTAL_AA1',7)
oView:SetOwnerView('VIEW_AA1','SUPERIOR')
oView:SetOwnerView('VIEW_TXI','DETALHE_TXI')
oView:SetOwnerView('VIEW_AA12','DETALHE_AA1')
oView:SetOwnerView('VIEW_TMP','DETALHE_TMP')
oView:SetOwnerView('VIEW_AA13','TOTAL_AA1')

oView:AddUserButton(STR0006, "", { || AT020Mapa()  }) //"Mapa de Locais"
If ExistFunc("TECR027")
	oView:AddUserButton(STR0007, "", { || TECR027() }) //"Relatorio de Supervisores"
EndIf

oView:AddOtherObject("LOAD_ATT",{|oPanel| at20AdExpC(oPanel) })
oView:SetOwnerView("LOAD_ATT","DETALHE_AA1")


oView:AddOtherObject("EXPORT_ATT",{|oPanel| at20AdExpP(oPanel) })
oView:SetOwnerView("EXPORT_ATT","DETALHE_AA1")

oView:EnableTitleView('VIEW_AA1', STR0009) //"Supervisor"
oView:EnableTitleView('VIEW_AA12', STR0003) //"Atendentes"
oView:EnableTitleView('VIEW_TXI', STR0005) //"Locais"

SetKey( VK_F10, { || At020AtGrd(.t.) })
oView:SetCloseOnOk( { || .T. } ) //Retira a opção salvar e criar um novo

If lLowScreen
	oView:SetContinuousForm()
EndIf

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT020ADDef
Retorna o Array dos campos
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT020ADDef(cTable, nOpc)
Local aRet := {}
Local cOrdem := "00"
Local nAux := 0

Do CASE
Case  "AA1" $ cTable
	If cTable == "AA1"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .T. )  //"Filial do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .F. )//"Filial do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| xFilial("AA1")}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FILIAL", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_NOMTEC", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FUNCAO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FUNCAO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FUNCAO", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "RJ_DESC", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "RJ_DESC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DFUNCAO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RJ_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| GetAdvFVal('SRJ',"RJ_DESC", xFilial("SRJ")+AA1->AA1_FUNCAO, 1, "") }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_EMAIL", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_EMAIL", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_EMAIL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_EMAIL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FONE", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FONE", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FONE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FONE")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FONE", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.
	EndIf

	If  nOpc == 1 .or. (cTable == "AA12" .and. nOpc == 2)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DATABA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] :=  {|| !Empty(FwFldGet("AA1_DATABA")) }
		
	EndIf
	If  nOpc == 1 .or. (cTable == "AA13" .and. nOpc == 2)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Total Atendentes"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Total Atendentes"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_TOTAA1"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 0}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@E 999,999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
	EndIf

Case cTable == "TXI"
		cOrdem := "20"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"Atendentes no Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023 //"Atendentes no Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "TXI_TOTAA1"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 0}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@E 99,999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010//"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "TXI_DATABA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .T.

Case cTable ==  "TMP"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0033 //"Cód. Local" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_LOCAL", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "ABS_LOCAL", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0034 //"Desc. Local" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DLOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "ABS_DESCRI", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_CODTEC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_CODTEC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_CODTFF", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_CODTFF", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_CODTFF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_CODTFF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_CODTFF", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_PRODUT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PRODUT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "B1_DESC", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "B1_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DPROD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.


	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DESEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDW_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.


	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_TURNO", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_TURNO", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_SEQTRN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_SEQTRN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "R6_DESC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "R6_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DTURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("R6_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_DTINI", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_DTINI", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TGYDTI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Ctod("")}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_DTINI", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_DTFIM", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_DTFIM", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TGYDTF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Ctod("")}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_DTFIM", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.
EndCase

Return aRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdGr
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdGr(oMdlGrid,lCopy, lLoad)
Local aColsGrid := {}

Default lCopy := .F.
Default lLoad := .F.

Processa({|lEnd| aColsGrid := At020ALdGP(oMdlGrid,lCopy, @lEnd, lLoad) },STR0012,STR0013,.T. )  //"Aguarde..." //"Carregando Atendentes vinculados"

Return aColsGrid

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdG2
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdG2(oMdlGrid,lCopy)
Local aColsGrid := {}
Local oModel := oMdlGrid:GetModel("TECA020A")
Local oMdlTXI := NIL
Local oStrTXI := NIL

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	aColsGrid :=  At020ALdGr(oMdlGrid,lCopy, .t.)
	//configura o campo como visual
	oMdlTXI := oModel:GetModel("TXIDETAIL")
	oStrTXI := oMdlTXI:GetStruct()

	oStrTXI:SetProperty("TXI_DATABA", MODEL_FIELD_WHEN, {|| .F. })

EndIf

Return aColsGrid

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdGP
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdGP(oMdlGrid,lCopy, lEnd, lLoad)

Local aColsGrid := {}
Local aLinha	:= {}
Local cAlias	:= GetNextAlias()
Local cAreaSup	:= ""
Local cExpDtTGY	:= ""
Local cExpPerTDW:= ""
Local cFilters	:= ""
Local cFuncao	:= ""
Local cInnerSR6	:= "LEFT "
Local cInnerSRJ	:= "LEFT "
Local cFilTDX	:= ""
Local cFilTGY	:= ""
Local cFilTDW	:= ""
Local cLocal	:= ""
Local cPeriodo	:= ""
Local cTurno	:= ""
Local cQry		:= ""
Local cQryAux	:= ""
Local dData		:= Ctod("")
Local dDataFim	:= Ctod("")
Local dDataIni	:= Ctod("")
Local lFilPeriod:= SuperGetMV("MV_FILPERI",,.F.)
Local lMultFil	:= SuperGetMV("MV_GSMSFIL",,.F.)
Local lAt020AQry:= ExistBlock( 'AT020AQRY' )
Local nLinha	:= 0
Local nTotAA1	:= 0
Local nTotal	:= 0
Local nTotLoc	:= 0
Local nX		:= 0
Local nY		:= 0
Local nOrder	:= 1
Local oModel	:= oMdlGrid:GetModel("TECA020A")
Local oMdlTXI	:= oModel:GetModel("TXIDETAIL")
Local oMdlAA1	:= oModel:GetModel("AA1MASTER")

Default lEnd  := .F.
Default lLoad := .F.

If !lLoad
	oMdlGrid:InitLine()
EndIf

If !oMdlTXI:IsDeleted() .AND. oMdlTXI:GetLine() > 0 .AND. !oMdlTXI:IsEmpty()
	dData 	:= oMdlAA1:GetValue("AA1_DATABA") //Dia da busca
	dDataIni:= oMdlTXI:GetValue("TXI_DTINI") //Data ini da supervisão
	dDataFim :=  oMdlTXI:GetValue("TXI_DTFIM") //Data fim da supervisão

	//Valida se a data da busca está no range da supervisão:
	If (dData >= dDataIni .AND. dData <= dDataFim) .OR. ;
		(dData >= dDataIni .And. Empty(dDataFim)) .OR. ;
		(dData <= dDataFim .And. Empty(dDataIni)) 

		nTotLoc := oMdlTXI:GetValue("TXI_TOTAA1")
		cLocal 	:= oMdlTXI:GetValue("TXI_LOCAL")
		cLocal 	:= StrTran(cLocal, "'", "''")
		cFuncao	:= oMdlTXI:GetValue("TXI_FUNCAO")
		cTurno	:= oMdlTXI:GetValue("TXI_TURNO")

		If lAreaSuper
			cAreaSup:= oMdlTXI:GetValue("TXI_CODTGS")
		EndIf

		If Empty(dDataIni)
			dDataIni := dData
		EndIf

		If Empty(dDataFim)
			dDataFim := dData
		EndIf

		If lMultFil
			cFilTDX := FWJoinFilial("TDX" , "TFF" , "TDX", "TFF", .T.) + " "
			cFilTGY := FWJoinFilial("TGY" , "TFF" , "TGY", "TFF", .T.) + " "
			cFilTDW := FWJoinFilial("TDW" , "TFF" , "TDW", "TFF", .T.) + " "
			cFilters:= FWJoinFilial("TFF" , "TFF" , "TFF", "TFF", .T.) + " "
		Else
			cFilTDX := " TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
			cFilTGY := " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
			cFilTDW := " TDW.TDW_FILIAL = '" + xFilial("TDW") + "' "
			cFilters:= " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
		EndIf

		cExpDtTGY := " AND TGY.TGY_ULTALO != ' ' AND ( '" + DToS(dData)+ "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM ) "
		
		If TXI->( FieldPos( "TXI_PERIOD" ) ) > 0 .And. TDW->( FieldPos( "TDW_PERIOD" ) ) > 0 .And. lFilPeriod
			cPeriodo :=  oMdlTXI:GetValue("TXI_PERIOD")
			If !Empty(cPeriodo)
				cExpPerTDW := " AND TDW.TDW_PERIOD = '" + cPeriodo +"' "
			EndIf
		EndIf
		
		If !Empty(cLocal)
			cFilters+= "AND TFF.TFF_LOCAL = '"+cLocal+"' "
		EndIf

		If !Empty(cAreaSup)
			cFilters+=  "AND ABS.ABS_CODSUP ='"+cAreaSup+"' "
		EndIF
		
		If !Empty(cFuncao)
			cInnerSRJ := "INNER "
			cFilters+= "AND TFF.TFF_FUNCAO='"+cFuncao+"' "
		EndIf

		If !Empty(cTurno)
			cInnerSR6:= "INNER "
			cFilters+= "AND TFF.TFF_TURNO='"+cTurno+"' "
		EndIf

		If !Empty(cLocal) .or. !Empty(cAreaSup) .or. !Empty(cFuncao) .or. !Empty(cTurno)

			cQry := " SELECT "
			cQry += " 		TGY.TGY_FILIAL AS TMP_FILIAL, "
			cQry += " 		TFF.TFF_LOCAL AS TMP_LOCAL, "
			cQry += " 		ABS.ABS_DESCRI AS TMP_DLOCAL, "
			cQry += " 		AA1.AA1_CODTEC AS TMP_CODTEC, "
			cQry += " 		AA1.AA1_NOMTEC AS TMP_NOMTEC, "
			cQry += " 		TGY.TGY_CODTFF AS TMP_CODTFF, "
			cQry += " 		TGY.TGY_DTINI AS TMP_TGYDTI, "
			cQry += " 		TGY.TGY_DTFIM AS TMP_TGYDTF, "
			cQry += " 		TGY.TGY_TIPALO AS TMP_TIPALO, "
			cQry += " 		TFF.TFF_ESCALA AS TMP_ESCALA, "
			cQry += " 		TDW.TDW_DESC AS TMP_DESEC, "
			cQry += " 		TFF.TFF_TURNO AS TMP_TURNO, "
			cQry += " 		TGY.TGY_SEQ AS TMP_SEQTRN, "
			cQry += " 		SR6.R6_DESC AS TMP_DTURNO, "
			cQry += " 		TFF.TFF_PRODUT AS TMP_PRODUT, "
			cQry += " 		SB1.B1_DESC AS TMP_DPROD "
			cQry += " FROM ? TFF "
			cQry += " INNER JOIN ? TDX ON (  ? AND "
			cQry += " 						TDX.TDX_CODTDW = TFF.TFF_ESCALA AND "
			cQry += " 						TDX.D_E_L_E_T_ = ' ' ) "
			cQry += " INNER JOIN ? TGY ON ( ? AND 
			cQry += " 						TGY.TGY_ESCALA = TFF.TFF_ESCALA AND "
			cQry += " 						TGY.TGY_CODTDX = TDX.TDX_COD AND  "
			cQry += " 						TGY.TGY_CODTFF = TFF.TFF_COD  AND "
			cQry += " 						TGY.D_E_L_E_T_ = ' ' ) "
			cQry += " INNER JOIN ? AA1 ON (  AA1.AA1_FILIAL = ? AND  
			cQry += " 						AA1.AA1_CODTEC = TGY.TGY_ATEND AND "
			cQry += " 						AA1.D_E_L_E_T_ = ' ' ) "
			cQry += " INNER JOIN ? SB1 ON (  SB1.B1_FILIAL = ? AND 
			cQry += " 						SB1.B1_COD = TFF.TFF_PRODUT AND "
			cQry += " 						SB1.D_E_L_E_T_ = ' ') "
			cQry += " INNER JOIN ? TDW ON ( ? AND
			cQry += " 						TDW.TDW_COD = TFF.TFF_ESCALA AND "
			cQry += " 						TDW.D_E_L_E_T_ = ' ' "
			cQry += " 						? ) "
			cQry += " INNER JOIN ? ABS ON (	 ABS.ABS_FILIAL = ? AND 
			cQry += " 						ABS.ABS_LOCAL = TFF.TFF_LOCAL AND "
			cQry += " 						ABS.D_E_L_E_T_ = ' ' ) "
			cQry += " ? JOIN ? SR6 ON ( SR6.R6_FILIAL = ? AND 
			cQry += " 						SR6.R6_TURNO = TFF.TFF_TURNO AND "
			cQry += " 						SR6.D_E_L_E_T_ = ' ') "
			cQry += " ? JOIN ? SRJ ON ( SRJ.RJ_FILIAL = ? AND 
			cQry += " 						SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO AND "
			cQry += " 						SRJ.D_E_L_E_T_ = ' ') "
			cQry += " WHERE "
			cQry += " 		? "
			cQry += " 		AND TFF.D_E_L_E_T_ = ' ' "
			cQry += " 		? "

			oStatement := FWPreparedStatement():New( cQry )
			oStatement:SetNumeric( nOrder++, RetSQLName( "TFF" ) )
			oStatement:SetNumeric( nOrder++, RetSQLName( "TDX" ) )
			oStatement:SetNumeric( nOrder++, cFilTDX )
			oStatement:SetNumeric( nOrder++, RetSQLName( "TGY" ) )
			oStatement:SetNumeric( nOrder++, cFilTGY )
			oStatement:SetNumeric( nOrder++, RetSQLName( "AA1" ) )
			oStatement:SetString( nOrder++, FwXFilial( "AA1" ) )
			oStatement:SetNumeric( nOrder++, RetSQLName( "SB1" ) )
			oStatement:SetString( nOrder++, FwXFilial( "SB1" ) )
			oStatement:SetNumeric( nOrder++, RetSQLName( "TDW" ) )
			oStatement:SetNumeric( nOrder++, cFilTDW )
			oStatement:SetNumeric( nOrder++, cExpPerTDW )
			oStatement:SetNumeric( nOrder++, RetSQLName( "ABS" ) )
			oStatement:SetString( nOrder++, FwXFilial( "ABS" ) )
			oStatement:SetNumeric( nOrder++, cInnerSR6 )
			oStatement:SetNumeric( nOrder++, RetSQLName( "SR6" ) )
			oStatement:SetString( nOrder++, FwXFilial( "SR6" ) )
			oStatement:SetNumeric( nOrder++, cInnerSRJ )
			oStatement:SetNumeric( nOrder++, RetSQLName( "SRJ" ) )
			oStatement:SetString( nOrder++, FwXFilial( "SRJ" ) )
			oStatement:SetNumeric( nOrder++, cFilters )
			oStatement:SetNumeric( nOrder++, cExpDtTGY )

			cQry := ChangeQuery( oStatement:GetFixQuery() )

			If lAt020AQry
				cQryAux := ExecBlock( 'AT020AQRY', .F. , .F. , { cQry } )
				If !Empty( cQryAux )
					cQry := cQryAux
				EndIf
			EndIf

			MPSysOpenQuery( cQry, cAlias )

			TCSetField(cAlias,"TMP_TGYDTI","D")
			TCSetField(cAlias,"TMP_TGYDTF","D")

			ProcRegua((cAlias)->(RecCount()))
			If !lLoad
				oMdlGrid:SetNoInsertLine(.F.)
				oMdlGrid:SetNoUpDateLine(.F.)
			EndIf
			While (cAlias)->(!Eof())	
				IncProc()
				nX++	
				
				If !lLoad
					If !oMdlGrid:IsEmpty()
						nLinha := oMdlGrid:AddLine()
						oMdlGrid:GoLine(nLinha)
					EndIf
					
					For nY := 1 To Len(oMdlGrid:aHeader)
						oMdlGrid:Loadvalue(oMdlGrid:aHeader[nY][2], (cAlias)->&(oMdlGrid:aHeader[nY][2]))
					Next nY
				Else
					aLinha := Array(Len(oMdlGrid:aHeader)+1)
					For nY := 1 To Len(oMdlGrid:aHeader)	
						aLinha[nY] := (cAlias)->&(oMdlGrid:aHeader[nY][2])
					Next nY
					aLinha[Len(oMdlGrid:aHeader)+1] := .F.
					Aadd(aColsGrid,{ 0, aClone(aLinha)})
				EndIf
				(cAlias)->(DbSkip())
			EndDo
			If !lLoad
				oMdlGrid:SetNoInsertLine(.T.)
				oMdlGrid:SetNoUpDateLine(.T.)		
				If oMdlGrid:GetLine() > 0 
					oMdlGrid:GoLine(1)
				EndIf
			EndIf
			(cAlias)->(DbCloseArea())
		EndIf
	EndIf
EndIf
nTotal := nX
nTotAA1 := oMdlAA1:GetValue("AA1_TOTAA1")
oMdlAA1:LoadValue("AA1_TOTAA1", nTotAA1 + nTotal )

If oMdlTXI:GetLine() > 0 .AND. !oMdlTXI:IsEmpty() .AND.  !Empty(cLocal)
	oMdlTXI:LoadValue("TXI_DATABA", dData)
	oMdlTXI:LoadValue("TXI_TOTAA1", nTotal)
EndIf

Return aColsGrid 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at20AdExpP
Função de Adição do Botão Exportar CSV
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at20AdExpP(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0014 , oPanel, { || At020AExDP()  },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Exportar Dados" //"Exportar CSV"

Return ( Nil )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at20AdExpC
Função de Adição do Botão Carregar Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at20AdExpC(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}
Local oView := FwViewActive()

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - ((aTamanho[1]+IIF(!lLowScreen, 5, 0))*2) , STR0026 , oPanel, { || At020AtGrd(.t.) },43,12,,,.F.,.T.,.F.,,.F.,{ || oView:GetOperation()<>MODEL_OPERATION_VIEW},,.F. )	//"Buscar (F10)"

Return ( Nil )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AtGrd
Função de Atualização do Grid de Atendentes ao Alterar da Data
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020AtGrd(lLoadAll)
Local oView := FwViewActive()
LOcal oModel := FwModelActive()
Local oModlTMP := oModel:GetModel("TMPDETAIL")
Local oModlTXI := oModel:GetModel("TXIDETAIL")
Local aSaveLines := FWSaveRows()
Local dData := FwFldGet("AA1_DATABA")
Local nX := 0
Local lUpd := .F.
Local nLineBckp := 0

Default lLoadAll := .F.

If oModel:GetOperation() <> MODEL_OPERATION_VIEW
	oModel:LoadValue("AA1MASTER","AA1_TOTAA1", 0)
	If !oModlTXI:IsEmpty()
		nLineBckp := oModlTXI:GetLine()
		For nX := 1 to oModlTXI:Length()
				oModlTXI:GoLine(nX)
				If lLoadAll .OR.  oModlTXI:GetValue("TXI_DATABA") <> dData
					oModlTMP:ClearData(.F., .F.)
					At020ALdGr(oModlTMP,.f.)
					lUpd := .T.
				EndIf
		Next nX
		oModlTXI:GoLine(nLineBckp)
		If lUpd
			oView:Refresh("VIEW_TMP")
			oView:Refresh("VIEW_AA13")
			oView:Refresh("VIEW_TXI")
		EndIf
	EndIf
	FWRestRows( aSaveLines )
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXI
@description 	PreLinTXI validação para a grid de Locais ao excluir/deletar um local

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		07/02/2020
@version	P12
@author	 fabiana.silva
/*/
//------------------------------------------------------------------------------
Static Function PreLinTXI(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)

Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModel		:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local nTotLoc		:= 0
Local nTotAA1		:= 0
Local oView := FwViewActive()


If oModel <> Nil .And. oModel:GetId() == 'TECA020A'
	If "DELETE" $ cAcao
		nTotLoc := oMdlG:GetValue("TXI_TOTAA1")
		If cAcao == 'DELETE'
			nTotLoc *= -1
		Else // cAcao == 'UNDELETE'
			nTotLoc *= 1
		EndIf
		nTotAA1 := oModel:GetModel("AA1MASTER"):GetValue("AA1_TOTAA1")
		oModel:LoadValue("AA1MASTER","AA1_TOTAA1", nTotAA1 + nTotLoc)	

		oView:Refresh("VIEW_AA13")

	EndIf	
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT020Mapa
@description  Função para abertura de mapa dos postos.
@author Augusto Albuquerque
@since  05/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT020Mapa()
Local aLocal	:= {}
Local aError	:= {}
Local aFilPesq	:= {}
Local cMsg		:= ""
Local cHtml		:= ""
Local cFile		:= ""
Local cQry		:= ""
Local cAliasABS	:= GetNextAlias()
Local nSleep	:= 1000
Local nLineBckp	:= 0
Local nX		:= 0
Local oModel	:= FwModelActive()
Local oMdlTXI	:= oModel:GetModel("TXIDETAIL")
Local oQry		:= Nil

nLineBckp := oMdlTXI:GetLine()
For nX := 1 To oMdlTXI:Length()
	oMdlTXI:GoLine(nX)
	If !oMdlTXI:IsDeleted() .And. !Empty(oMdlTXI:GetValue("TXI_LOCAL"))
		aAdd(aFilPesq,oMdlTXI:GetValue("TXI_LOCAL"))
	EndIf
Next nX
oMdlTXI:GoLine(nLineBckp)

cQry := "SELECT ABS.ABS_LATITU, ABS.ABS_LONGIT, ABS.ABS_DESCRI, ABS.ABS_LOCAL, ABS.ABS_END, ABS.ABS_MUNIC, ABS.ABS_ESTADO "
cQry += "FROM ? ABS "
cQry += "WHERE ABS.ABS_FILIAL = ? "
cQry += "AND ABS.D_E_L_E_T_ = ' ' "
cQry += "AND ABS.ABS_LOCAL IN (?) "

oQry := FwPreparedStatement():New( cQry )
oQry:setNumeric(1, RetSqlName( "ABS" ) )
oQry:setString(2, xFilial("ABS") )
oQry:SetIN(3, aFilPesq)

cQry := oQry:GetFixQuery()
cQry := ChangeQuery(cQry)
cAliasABS := MPSysOpenQuery(cQry)

While !( cAliasABS )->( EOF() )
	If Empty( ( cAliasABS )->ABS_LATITU ) .OR. Empty( ( cAliasABS )->ABS_LONGIT )
		If Empty( ( cAliasABS )->ABS_END ) .OR. Empty( ( cAliasABS )->ABS_MUNIC ) .OR. Empty( ( cAliasABS )->ABS_ESTADO )
			AADD( aError, { ( cAliasABS )->ABS_LOCAL,;
							( cAliasABS )->ABS_DESCRI} )
		Else
			aLatLon := TECGtCoord( ( cAliasABS )->ABS_END, ( cAliasABS )->ABS_MUNIC, ( cAliasABS )->ABS_ESTADO )
			If Len( aLatLon ) > 0 .AND. !Empty( aLatLon[1] ) .AND.  !Empty( aLatLon[2] )
				DbSelectArea("ABS")
				ABS->(DbSetOrder(1))
				If ABS->(DbSeek(xFilial("ABS")+ ( cAliasABS )->ABS_LOCAL ))
					RecLock("ABS", .F.)
						ABS->ABS_LATITU := aLatLon[1]
						ABS->ABS_LONGIT := aLatLon[2]
					MsUnlock()
				EndIf
				AADD( aLocal, { aLatLon[1],;
								aLatLon[2],;
								STR0015,;
								"red"})
			EndIf
		EndIf
	Else
		AADD( aLocal, { ( cAliasABS )->ABS_LATITU,;
						( cAliasABS )->ABS_LONGIT,;
						STR0015,; //"Local de atendimento"
						"red"} )
	EndIf
	( cAliasABS )->( DbSkip() )
EndDo
( cAliasABS )->( DbCloseArea() )
oQry:Destroy()
FwFreeObj( oQry )

If Len(aError) > 0
	cMsg := STR0016+CRLF+CRLF+CRLF //"Foram encontrados alguns cadastros que não possuem latitude e/ou longitude"
	For nX := 1 To Len(aError)
		cMsg += Alltrim(Str(nX)) + " " + STR0018 + " " + aError[nX][1] + " " + STR0017 + " " + aError[nX][2] + CRLF //"Local: " //"Numero do Local: "
	Next nX
	cMsg += CRLF+CRLF+STR0019  //"Verifique nos cadastros citados acima, se os campos de Latitude e Longitude foram informados."
	If !IsBlind()
		AtShowLog(cMsg,STR0020,.T.,.T., ,.F.) // STR0020 //"Latitude / Longitude"
	EndIf
EndIf

If Len(aLocal) > 0
	cHtml := TECHTMLMap( , aLocal, "16", 1 )
	cFile := GetTempPath() + "locationcheckin.html"
	TECGenMap( cHtml, cFile, nSleep, .T. )
EndIf
	MsgAlert(STR0025, "") // "Processo concluido!"
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AExDP
@description  Função para processamento de exportacao dos dados
@author fabiana.silva
@since  12/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At020AExDP()
Local oModel := FwModelActive()
Local oModlTMP := oModel:GetModel("TMPDETAIL")

If !oModlTMP:IsEmpty()
	TecGrd2CSV("VIEW_TMP","TMPDETAIL","VIEW_TMP",/*aNoCpos*/,/*aIncCpo*/,/*aLegenda*/,"TECA020A", /*cFldVld*/)
Else
	MsgStop(STR0027) //"Não há dados para exportar"
EndIf

Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dExec
Executa um comando genérico recebido via string

@author		Matheus Gonçalves
@since		09/12/2020
@param 		cCommand - Comando via string a ser executado
@Versão 	1.0
/*/
//------------------------------------------------------------------------------
Function At020aExec( cCommand)
Local oModel    := FwLoadModel("TECA020A")
Local oModlTMP	:= oModel:GetModel("TMPDETAIL")
Local xRet 

If IsBlind()
	oModel:Activate()
	oModlTMP:Activate()
EndIF

xRet := (&(cCommand))

Return xRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020Fil
@description Filtro da consulta padrao de Locais de Atendimento vinculados com base operacional
@param  Nenhum
@return Lógico
@author Kaique Schiller
@since 24/04/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020aFil()
Local cFiltro := "@#"

If !Empty(FwFldGet("TXI_CODAA0"))
	cFiltro += '(ABS->ABS_FILIAL == "' + xFilial("ABS")  +'" .And. ABS->ABS_BASEOP == "' + FwFldGet("TXI_CODAA0")+ '" )'
Else
	cFiltro += '(ABS->ABS_FILIAL == "' + xFilial("ABS")  +'" )'
EndIf

Return cFiltro+"@#"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020aSup
@description Filtro da consulta padrao de Locais de Atendimento vinculados com Área de Supervisão
@param  Nenhum
@return Lógico
@author Anderson F. Gomes
@since 29/08/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020aSup()
Local cFiltro := "@#"

If !Empty(FwFldGet("TXI_CODTGS"))
	cFiltro += '(ABS->ABS_FILIAL == "' + xFilial("ABS")  +'" .And. ABS->ABS_CODSUP == "' + FwFldGet("TXI_CODTGS")+ '" )'
Else
	cFiltro += '(ABS->ABS_FILIAL == "' + xFilial("ABS")  +'" )'
EndIf

Return cFiltro+"@#"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020aTrgLc
@description Gatilho para o campo TXI_CODTGS para verifical se o Local é Área de Supervisão do Atendente
@param  cCampo - Campo que executou o gatilho
@return Lógico
@author Anderson F. Gomes
@since 29/08/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020aTrgLc( cCampo )
Local cRet As Character
Local cQuery As Character
Local cAlias As Character
Local oExec As Object
Local oModel := FwModelActive()

cRet := ""
cQuery := "SELECT ABS_LOCAL,ABS_CODSUP FROM ? WHERE ABS_FILIAL = ? AND ABS_LOCAL = ? AND ABS_CODSUP = ? AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery( cQuery )
oExec := FwExecStatement():New( cQuery )

oExec:SetUnsafe( 1, RetSqlName( "ABS" ) )
oExec:SetString( 2, FwXFilial( "ABS" ) )
oExec:SetString( 3, FwFldGet("TXI_LOCAL") )
oExec:SetString( 4, FwFldGet("TXI_CODTGS") )

cAlias := oExec:OpenAlias()

If cCampo == "TXI_CODTGS"
	If !Empty( FwFldGet("TXI_CODTGS") )
		cRet := Space( FWSX3Util():GetFieldStruct( "TXI_LOCAL" )[3] )

		If !Empty( FwFldGet("TXI_LOCAL") )
			If (cAlias)->( !Eof() )
				cRet := (cAlias)->ABS_LOCAL
			EndIf
		EndIf
	Else
		cRet := FwFldGet("TXI_LOCAL")
	EndIf
	If Empty( cRet )
		oModel:LoadValue( "TXIDETAIL","TXI_DESLOC", Space( FWSX3Util():GetFieldStruct( "TXI_DESLOC" )[3] ) )
	EndIf
ElseIf cCampo == "TXI_LOCAL"
	If !Empty( FwFldGet("TXI_LOCAL") )
		cRet := Space( FWSX3Util():GetFieldStruct( "TXI_CODTGS" )[3] )

		If !Empty( FwFldGet("TXI_CODTGS") )
			If (cAlias)->( !Eof() )
				cRet := (cAlias)->ABS_CODSUP
			EndIf
		EndIf
	Else
		cRet := FwFldGet("TXI_CODTGS")
	EndIf
EndIf

(cAlias)->( DbCloseArea() )
oExec:Destroy()
oExec := Nil

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AEsc
@description F3 para o campo TXI_TURNO
@param  Nenhum
@return Logical
@author Anderson F. Gomes
@since 21/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020AEsc()
Local oModel := FwModelActive()
Local oMdlTXI := oModel:GetModel('TXIDETAIL')
Local oBrowse := Nil
Local oDlgTela := Nil
Local lRet := .F.
Local cPeriodo := oMdlTXI:GetValue( 'TXI_PERIOD' )
Local cAls := GetNextAlias()
Local cQry := ""
Local aIndex := {}
Local aSeek := { { STR0028, { { STR0029, "C", GetSx3Cache( "R6_TURNO", "X3_TAMANHO" ), 0, "", , } } } }	// STR0028 - "Turnos" \ STR0029 - "Turno"
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita := 0

cQry := " SELECT SR6.R6_TURNO, SR6.R6_DESC " + CRLF
cQry += " FROM " + RetSqlName( "SR6" ) + " SR6 " + CRLF
cQry += " INNER JOIN " + RetSqlName( "TDX" ) + " TDX ON TDX.TDX_FILIAL = '" + FwxFilial( "TDX" ) + "' AND TDX.TDX_TURNO = SR6.R6_TURNO AND TDX.D_E_L_E_T_ = ' ' " + CRLF
cQry += " INNER JOIN " + RetSqlName( "TDW" ) + " TDW ON TDW.TDW_FILIAL = TDX.TDX_FILIAL AND TDW.TDW_COD = TDX.TDX_CODTDW AND TDW.D_E_L_E_T_ = ' ' " + CRLF
cQry += " WHERE SR6.D_E_L_E_T_ = ' ' AND TDW.TDW_STATUS <> '2' " + CRLF
If !Empty( cPeriodo )
	cQry += " AND TDW.TDW_PERIOD = '" + cPeriodo + "' " + CRLF
EndIf

AAdd( aIndex, "R6_TURNO" )

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
If !isBlind()
	DEFINE MSDIALOG oDlgTela TITLE OemTOAnsi( STR0028 ) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	// STR0028 - "Turnos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner( oDlgTela )
	oBrowse:SetDataQuery()
	oBrowse:SetAlias( cAls )
	oBrowse:SetQueryIndex( aIndex )
	oBrowse:SetQuery( cQry )
	oBrowse:SetSeek( , aSeek )
	oBrowse:SetDescription( OemTOAnsi( STR0028 ) ) // STR0028 - "Turnos"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetDoubleClick({ || cRetEscala := (oBrowse:Alias())->R6_TURNO, lRet := .T. ,oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi( STR0030 ), {|| cRetEscala := (oBrowse:Alias())->R6_TURNO, lRet := .T., oDlgTela:End() } ,, 2 ) // STR0030 - "Confirmar"
	oBrowse:AddButton( OemTOAnsi( STR0031 ), {|| cRetEscala := "", oDlgTela:End() } ,, 2 ) // STR0031 - "Cancelar"
	oBrowse:SetUseFilter( .T. )

	ADD COLUMN oColumn DATA {|| R6_TURNO}  TITLE OemTOAnsi( STR0032 ) SIZE GetSx3Cache( "R6_TURNO", "X3_TAMANHO" ) OF oBrowse // STR0032 - "Cód. Turno"
	ADD COLUMN oColumn DATA {|| R6_DESC}  TITLE OemTOAnsi( STR0029 ) SIZE GetSx3Cache( "R6_DESC", "X3_TAMANHO" ) OF oBrowse // STR0029 - "Turno"
	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

Return( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AEscR
@description Retorno da Consulta Específica At020AEsc
@param  Nenhum
@return Character
@author Anderson F. Gomes
@since 21/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020AEscR()
Return cRetEscala
