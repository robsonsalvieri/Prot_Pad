#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "NFEATORINT.CH"

PUBLISH MODEL REST NAME SPEDATORINT source SPEDATORINT

#Define _CRLF (CHR(13)+CHR(10))

Static cAliasTmp    := ""
Static cTpAtor      := ""
Static __evAtor     := .F.
Static __aPrepared  := {}

/*/{Protheus.doc}SPEDATORINT
Chamada da rotina de Ator Interessado
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Function SPEDATORINT(oObjTela, cTipoAtor, cIdEnt, cVersaoTSS ,cDadosTSS)

Local oDlgMain           := nil                     as object
Local oColumns           := nil                     as object
Local oBrowseNotas       := nil                     as object
Local nContFlds          := 0                       as mumeric
Local aColumns           := {}                      as array
Local aFields            := {}                      as array
Local aStructCampo       := {}                      as array
Local aSize              := {}                      as array
Local cTitle             := ""                      as character
Local aSeek              := {}                      as array
Local aIndex             := {}                      as array

Private cTitulo             := STR0001				as character //"Ator Interessado NF-"
Private cQueryDocumentos    := ""                   as character
Private cAliasDocumentos    := ""                   as character
Private lThemeDark          := .F.                  as logical
Private cEventoSelecionado  := ""                   as character
Private cEventoTransmissao  := "110150"             as character
Private cEventoMonitor      := "110000"             as character
Private aBrowserMonitor     := {}                   as array

Default cTipoAtor        := ""
Default cDadosTSS        := ""

cTpAtor     := cTipoAtor
cDadosTSS   := STR0001 + " - " + cDadosTSS //"Ator Interessado NF-e - "

cAliasTmp   := GetNextAlias()

If !AtorPergunta()
    Return (.F.)
EndIf

(cAliasDocumentos)->(DbGoTop())
If (cAliasDocumentos)->(!Eof()) .AND. (cAliasDocumentos)->(!Bof())
	(cAliasDocumentos)->(DbCloseArea())
Else
	(cAliasDocumentos)->(DbCloseArea())
	FWAlertInfo(STR0002,cTitulo) // "Não existem registros relacionados ao filtro selecionado."  "ECONF"
    Return(.F.)
EndIf

AtorThemaSistema()
aSize  := MsAdvSize()
cTitle := cTitulo + " - " + cIdEnt + " - " + cVersaoTSS

Aadd( aSeek, { STR0003, {{"","C", GetSX3Cache( "F3_NFISCAL","X3_TAMANHO") , 0 ,STR0003,,}}} ) //"Documento"
Aadd( aSeek, { STR0004, {{"","C", GetSX3Cache( "F3_CHVNFE" ,"X3_TAMANHO") , 0 ,STR0004,,}}} ) //"Chave da NF-e"
Aadd( aIndex, "F3_NFISCAL" )
Aadd( aIndex, "F3_CHVNFE" )

DEFINE MSDIALOG oDlgMain TITLE cTitle FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	oBrowseNotas := FWFormBrowse():New()
	oBrowseNotas:SetDataQuery()
	oBrowseNotas:SetOwner(oDlgMain)
	oBrowseNotas:SetAlias(cAliasDocumentos)
	oBrowseNotas:SetDescription(cTitle)
	oBrowseNotas:SetQuery(cQueryDocumentos)
	oBrowseNotas:SetQueryIndex(aIndex)
	oBrowseNotas:SetSeek(,aSeek)
	oBrowseNotas:SetMenuDef('')
	oBrowseNotas:DisableDetails()

	aColumns := {}
	aFields := {}

	aAdd(aFields,{"F3_NFISCAL"  ,STR0003 }) // "Documento"
	aAdd(aFields,{"F3_SERIE"    ,STR0005 }) // "Serie"
	aAdd(aFields,{"F3_CLIEFOR"  ,STR0006 }) // "Cliente/Fornecedor"
	aAdd(aFields,{"F3_LOJA"     ,STR0007 }) // "Loja"
	aAdd(aFields,{"F3_CHVNFE"   ,STR0004 }) // "Chave da Nfe"
	aAdd(aFields,{"F3_EMISSAO"  ,STR0009 }) // "Data de Emissão"

	For nContFlds := 1 To Len(aFields)

		aStructCampo := FWSX3Util():GetFieldStruct(aFields[nContFlds,1])
		oColumns :=  FWBrwColumn():New()
		If Alltrim(aStructCampo[2]) == "D"
			oColumns:SetData(&("{|| DtoC(StoD("+aFields[nContFlds,1]+"))}"))
		Else
			oColumns:SetData(&("{|| "+aFields[nContFlds,1]+" }"))
		EndIf
		oColumns:SetTitle( aFields[nContFlds,2])
		oColumns:SetSize(aStructCampo[3])
		oColumns:SetType(aStructCampo[2])
		oColumns:SetID(aFields[nContFlds])
		oColumns:SetPicture(Alltrim(GetSX3Cache(aFields[nContFlds,1],"X3_PICTURE")))

		aAdd(aColumns,oColumns)
	Next

	oBrowseNotas:AddButton(STR0010,{||oDlgMain:End()},,,,.F.) // Sair
	If !lUsaColab
		oBrowseNotas:AddButton(STR0011,{|| SpedNFeCfg()},,,,.F.) // "Wiz.Config."
	EndIf
    oBrowseNotas:AddButton(STR0012 ,{|| SpedCCePar()            },,,,.F.) // "Parametros"
	oBrowseNotas:AddButton(STR0013 ,{|| AtorTransmissao()       },,,,.F.) // "Transmissao"
	oBrowseNotas:AddButton(STR0014 ,{|| AtorVisualizaDocumento()},,,,.F.) // "Visualiza Doc."
	oBrowseNotas:SetColumns(aColumns)
	oBrowseNotas:Activate()

	ACTIVATE MSDIALOG oDlgMain

Return Nil

/*/{Protheus.doc}ModelDef
definição de modelo
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Static Function ModelDef()

Local aTrigger      := {}

oNFs       := FWFormModelStruct():New()
oGrdTransp := FWFormModelStruct():New()
oModel     := MPFormModel():New('SPEDATORINT')

/*
Criação da parte de cima NF
*/
oNFs:AddTable('MASTERNF',{},'MASTERNF')
oNFs:AddField(  STR0015         		            ,;  // [01] Titulo do campo
                STR0015 		                    ,;  // [02] ToolTip do campo
                "CAB_TRANSP"	                    ,;  // [03] Id do Field
                "C"				                    ,;	// [04] Tipo do campo
                tamSX3("A4_COD")[1]		            ,;	// [05] Tamanho do campo
                0       				            ,;	// [06] Decimal do campo
                {|| .T.}                            ,;	// [07] Code-block de validação do campo
                {|| .T. }		                    ,;	// [08] Code-block de validação When do campo
                {}                                  ,;	// [09] Lista de valores permitido do campo
                .F.)                                    // [10] Obrigatorio

oModel:AddFields('MASTERNF',,oNFs)
oModel:GetModel('MASTERNF'):SetOnlyQuery(.T.) //Desabilita a Gravação automatica do Model

/*
Criando modelo do grid de transportadores
*/
oGrdTransp:AddTable('GRDTRANSP',{},'GRDTRANSP')
oGrdTransp:AddField(STR0015 		                  ,; // [01] Titulo do campo
                    STR0015        			          ,; // [02] ToolTip do campo
                    "DET_TRANSP"	                  ,; // [03] Id do Field
                    "C"				                  ,; // [04] Tipo do campo
                    tamSX3("A4_COD")[1]		          ,; // [05] Tamanho do campo
                    0       				          ,; // [06] Decimal do campo
                    {|a,b,c,d| VldCodTransp(a,b,c,d)} ,; // [07] Code-block de validação do campo
                    {|| .T. }		                  ,; // [08] Code-block de validação When do campo
                    {}                                ,; // [09] Lista de valores permitido do campo
                    .F.)                                 // [10] Obrigatorio

oGrdTransp:AddField(STR0016		                      ,; // [01] Titulo do campo
                    STR0016     	                  ,; // [02] ToolTip do campo
                    "DET_CGC"   	                  ,; // [03] Id do Field
                    "C"				                  ,; // [04] Tipo do campo
                    tamSX3("A4_CGC")[1]		          ,; // [05] Tamanho do campo
                    0       				          ,; // [06] Decimal do campo
                    {|a,b,c,d| VldCGC(a,b,c,d)}       ,; // [07] Code-block de validação do campo
                    {|| .T. }		                  ,; // [08] Code-block de validação When do campo
                    {}                                ,; // [09] Lista de valores permitido do campo
                    .T.)                                 // [10] Obrigatorio

oGrdTransp:AddField(STR0017                           ,; // [01] Titulo do campo
                    STR0017                           ,; // [02] ToolTip do campo
                    "DET_NOME"   	                  ,; // [03] Id do Field
                    "C"				                  ,; // [04] Tipo do campo
                    tamSX3("A4_NOME")[1]	          ,; // [05] Tamanho do campo
                    0       				          ,; // [06] Decimal do campo
                    {|| .T. }	                      ,; // [07] Code-block de validação do campo
                    {|| .F. }		                  ,; // [08] Code-block de validação When do campo
                    {}                                ,; // [09] Lista de valores permitido do campo
                    .F.)                                 // [10] Obrigatorio

oGrdTransp:AddField(STR0018 							,;  // [01] Titulo do campo
                    STR0018 							,;  // [02] ToolTip do campo
                    "DET_ACESSO"   	                    ,;  // [03] Id do Field
                    "L"				                    ,;	// [04] Tipo do campo
                    1                   	            ,;	// [05] Tamanho do campo
                    0       				            ,;	// [06] Decimal do campo
                    {|| .T. }	                        ,;	// [07] Code-block de validação do campo
                    {|| .T. }		                    ,;	// [08] Code-block de validação When do campo
                    {}                                  ,;	// [09] Lista de valores permitido do campo
                    .F.)                                	// [10] Obrigatorio

aTrigger := FwStruTrigger('DET_TRANSP','DET_CGC','SA4->A4_CGC',.T.,'SA4',1,'xFilial("SA4")+M->DET_TRANSP')
oGrdTransp:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3],aTrigger[4] )

aTrigger := FwStruTrigger('DET_TRANSP','DET_NOME','SA4->A4_NOME',.T.,'SA4',1,'xFilial("SA4")+M->DET_TRANSP')
oGrdTransp:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3],aTrigger[4] )

oModel:AddGrid('GRDTRANSP', 'MASTERNF', oGrdTransp)
oModel:GetModel('GRDTRANSP'):SetOnlyQuery(.T.) //Desabilita a Gravação automatica do Model
oModel:GetModel('GRDTRANSP'):SetDelAllLine(.T.) //Permite a deleção de todas as linhas do Grid

oModel:SetDescription(STR0019) //"Evento Ator Interessado"
oModel:SetPrimarykey({})

Return oModel

/*/{Protheus.doc}ViewDef
definição da view
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Static Function ViewDef()

oModel     := FWLoadModel( 'SPEDATORINT' ) 
oView      := FWFormView():New()
oNFs	   := FWFormViewStruct():New()
oGrdTransp := FWFormViewStruct():New()

oNFs:AddField(  "CAB_TRANSP"	                ,;  // [01] Id do Field
                "01"			                ,;	// [02] Ordem
                STR0015                 		,;  // [03] Titulo do campo  //"Transportador"
                STR0015                 		,;  // [04] ToolTip do campo //"Transportador"
                {STR0082}    					,;  // [05] Help			 //"Codigo da Transportadora"
                "C"		                        ,;	// [06] Tipo do campo
                PesqPict( "SA4", "A4_COD" )     ,;	// [07] Picture
                                            	,;	// [08] PicVar
                'SA4')                              // [09] F3

oGrdTransp:AddField("DET_TRANSP"	                ,;  // [01] Id do Field
                    "01"			                ,;	// [02] Ordem
                    STR0015			                ,;  // [03] Titulo do campo  //"Transportador"
                    STR0015         		        ,;  // [04] ToolTip do campo //"Transportador"
                    {STR0082}    					,;  // [05] Help			 //"Codigo da Transportadora"
                    "C"		                        ,;	// [06] Tipo do campo
                    PesqPict( "SA4", "A4_COD" )     ,;	// [07] Picture
                                                	,;	// [08] PicVar
                    'SA4')                              // [09] F3

oGrdTransp:AddField("DET_CGC"	                    ,;  // [01] Id do Field
                    "02"			                ,;	// [02] Ordem
                    STR0016		                    ,;  // [03] Titulo do campo	 //"CNPJ/CPF"
                    STR0016     	 	            ,;  // [04] ToolTip do campo //"CNPJ/CPF"
                    {STR0083}						,;  // [05] Help             //"CNPJ ou CPF do transportador"
                    "C"		                        ,;	// [06] Tipo do campo
                    PesqPict( "SA4", "A4_CGC" )     ,;	// [07] Picture
                                                	,;	// [08] PicVar
                    '')                                 // [09] F3

oGrdTransp:AddField("DET_NOME"	                    ,;  // [01] Id do Field
                    "03"			                ,;	// [02] Ordem
                    STR0017                         ,;  // [03] Titulo do campo	 //"Nome"
                    STR0017                         ,;  // [04] ToolTip do campo //"Nome"
                    {STR0084}				        ,;  // [05] Help			 //"Nome do transportador"
                    "C"		                        ,;	// [06] Tipo do campo
                    PesqPict( "SA4", "A4_NOME" )    ,;	// [07] Picture
                                                	,;	// [08] PicVa
                    '')                                 // [09] F3

oGrdTransp:AddField("DET_ACESSO"	                ,;  // [01] Id do Field
                    "04"			                ,;	// [02] Ordem
                    STR0018 						,;  // [03] Titulo do campo	 //"Permite ao Transportador Conceder Acesso?"
                    STR0018 						,;  // [04] ToolTip do campo //"Permite ao Transportador Conceder Acesso?"
                    {STR0085}   			        ,;  // [05] Help			 //"Permite ao Transportador Conceder Acesso do XML da NF-e"
                    "L"		                        ,;	// [06] Tipo do campo
                                                    ,;	// [07] Picture
                                                	,;	// [08] PicVar
                    '')                                 // [09] F3

oView:SetModel(oModel)
oView:AddField('FORM_NF'	,oNFs	    ,'MASTERNF'  ) //FAKE
oView:AddGrid('GRID_TRANSP'	,oGrdTransp	,'GRDTRANSP' )  

oView:CreateHorizontalBox('BOXCABEC'	,000) //fake
oView:CreateHorizontalBox('BOXTRANSP'	,100) //transportadores

oView:SetOwnerView('FORM_NF'    ,'BOXCABEC') //TODO: Colocar aqui o objeto de seleção de notas
oView:SetOwnerView('GRID_TRANSP','BOXTRANSP')

oView:EnableTitleView('GRID_TRANSP'	, STR0020) //"Informe o(s) transportador(es):"

Return oView

/*/{Protheus.doc} VldCodTransp
Valida os dados informados no transportador e gatilha os demais campos
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Function VldCodTransp(oModel,cField,cDado,nLinha)

Local lRet      := .T.
Local cMsgErro  := ""

If !Empty(cDado)
    SA4->(DBSetOrder(1)) //"A4_FILIAL+A4_COD"
    If !SA4->(MsSeek(xFilial("SA4")+cDado))
        cMsgErro := STR0021 + cDado + STR0022 //"Código '" # "' não encontrado na tabela de transportadores"
        oModel:GetModel():SetErrorMessage(,, "GRDTRANSP", "DET_TRANSP", "vldCodTransp", cMsgErro,STR0023) //"Informar um código valido!"
        lRet := .F.
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} VldCGC
Valida digitação do campo CGC de transportadores
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Static Function VldCGC(oModel,cField,cDado,nLinha)
Local lRet  := .T.

If !Empty(cDado)
    lRet := CGC(cDado) .And. VldLine(oModel,cField,cDado,nLinha)
EndIf

Return lRet

/*/{Protheus.doc} VldLine
Valida a linha do gride de CNPJ de transportadores
@author Felipe Sales Martinez
@since  22/02/2021
@version  P12
/*/
Static Function VldLine(oModel,cField,cDado,nLinha)

Local lRet          := .T.
Local oDetTransp    := oModel:GetModel():GetModel("GRDTRANSP")
Local nLength       := oDetTransp:Length()
Local nI            := 1
Local aSaveLines    := {}
Local cMsg          := ""
Local cSolu         := nil

If nLength > 1
    aSaveLines := FWSaveRows()
    cDado 	   := AllTrim(cDado)
    For nI := 1 To nLength
        If nLinha <> nI
            oDetTransp:GoLine(nI)
            If AllTrim(oDetTransp:GetValue("DET_CGC")) == cDado
                cMsg := STR0024 //"O CNPJ/CPF já foi informado anterioremente"
                If oDetTransp:IsDeleted()
                    cMsg  += STR0025 + Alltrim(str(nI)) + "'" //" porem se encontra deletado na linha: '"
                    cSolu := STR0026 //"Por favor habilitar o registros novamente."
                EndIf
                oModel:GetModel():SetErrorMessage(,,"GRDTRANSP", "DET_CGC", "VldLine", cMsg,cSolu)
                lRet := .F.
                Exit
            EndIf
        EndIf
    Next
    FWRestRows( aSaveLines )
EndIf

Return lRet

/*/{Protheus.doc} AtorTransmissao
    Função responsável de Transmissao de Eventos Monitoramento / Cancelamento / Tramissao
    @author Leonardo Miranda
    @since 18/11/2024
    @version 12.1.2410
/*/
Function AtorTransmissao()

Local cTitle        := ""             as character
Local cEvento       := ""			  as character
Local aButtons      := {}             as array
Local cCodCliente   := ""             as character
Local cLoja         := ""             as character
Local cNomeCliente  := ""             as character
Local cCnpjClinete  := ""             as character
Local cTipoCli      := ""             as character
Local cNumDoc       := ""             as character
Local cDocSerie     := ""             as character
Local dDocEmissao   := date()         as date
Local cChaveDoc     := ""             as character
Local cTipoCliDesc  := ""             as character
Local aTipoEvento   := {}             as Array
Local cMaskCnpj     := ""             as character

Private oModel              := nil                              as object
Private oView               := nil                              as object
Private oNFs	            := nil                              as object
Private oGrdTransp          := nil                              as object
Private oBrowse             := nil                              as object
Private oOkMonitor          := nil                              as object
Private oNoMonitor          := nil                              as object
Private oBrwMonitor     	:= nil                              as object
Private oFont               := TFont():New(,,-12,.T.,.F.,,,,,)  as object
Private oMdlTela	        := nil                              as object
Private oTopBar				:= nil                              as object
Private oSize               := nil as object
Private oGrpDadosNota       := nil as object
Private oGrpNotas           := nil as object
Private oGrpBrowser         := nil as object
Private oSayCodCli          := nil as object
Private oSayNomeCli         := nil as object
Private oSayPessoa          := nil as object
Private oSayNF              := nil as object
Private oSayChave           := nil as object
Private oWorkAreaMain       := nil as object
Private oWorkAreaContainer  := nil as object
Private oPanelDadosNota     := nil as object
Private oPanelDadosMonitor  := nil as object
Private oTSayTransacao      := nil as object
Private oComboEvento        := nil as object

cTitle      := cTitulo + STR0027 + cIdEnt + STR0028 + cVersaoTSS //" - Entidade " # " - Versão "
aTipoEvento := {"",STR0029 , STR0030} //"110000-Monitor" # "110150-Transmitir Evento"
                                  
cCodCliente  := (cAliasDocumentos)->F3_CLIEFOR
cLoja        := (cAliasDocumentos)->F3_LOJA
cNomeCliente := (cAliasDocumentos)->A1_NOME
cCnpjClinete := (cAliasDocumentos)->A1_CGC
cTipoCli     := (cAliasDocumentos)->A1_PESSOA
cNumDoc      := (cAliasDocumentos)->F3_NFISCAL
cDocSerie    := (cAliasDocumentos)->F3_SERIE
dDocEmissao  := Stod((cAliasDocumentos)->F3_EMISSAO)
cChaveDoc    := (cAliasDocumentos)->F3_CHVNFE
cMaskCnpj 	 := "@R 999.999.999-99"

If cTipoCli == 'F'
	cTipoCliDesc := STR0031 //"Pessoa Fisica"
ElseIf cTipoCli == 'J'
	cTipoCliDesc:= STR0032  //"Pessoa Juridica"
	cMaskCnpj := "@R! NN.NNN.NNN/NNNN-99"
EndIf

oSize := FwDefSize():New(.T.,.F.,,)
oSize:AddObject( "MAIN",100,100,.T.,.T. ) // Totalmente dimensionavel
oSize:lProp 	:= .T. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:Process() // Dispara os calculos

oWorkAreaMain := FWDialogModal():New()
oWorkAreaMain:SetEscClose(.T.)
oWorkAreaMain:SetTitle(cTitle)
oWorkAreaMain:setPos(oSize:aWindSize[1] / 2,oSize:aWindSize[2] / 2 )
oWorkAreaMain:setSize(oSize:aWindSize[3] / 2,oSize:aWindSize[4] / 2)
oWorkAreaMain:CreateDialog()

oWorkAreaContainer := FWUIWorkArea():new(oWorkAreaMain:GetPanelMain())
oWorkAreaContainer:CreateHorizontalBox("MAIN", 100 , .F.)
oWorkAreaContainer:SetBoxCols("MAIN" , {"WIDDOC", "WIDMONITOR"} )
oWorkAreaContainer:Activate()

oPanelDadosNota    := oWorkAreaContainer:GetPanel("WIDDOC")
oPanelDadosMonitor := oWorkAreaContainer:GetPanel("WIDMONITOR")

oSayCodCli  := TSay():New(01, 01, {|| StrTran(STR0021,"'")+" "+cCodCliente+" - "+STR0007+" "+cLoja }, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont) // "Código" # "Loja"
oSayNomeCli := TSay():New(02, 01, {|| STR0008+" "+Alltrim(cNomeCliente)}, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont) //"Razão Social"
oSayPessoa  := TSay():New(03, 01, {|| cTipoCliDesc + " - " +Transform(Alltrim(cCnpjClinete),cMaskCnpj)}, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont)
oSayNF      := TSay():New(03, 18, {|| STR0003+" "+cNumDoc+ " - "+cDocSerie+" - "+ DToc(dDocEmissao)}, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont) //"Documento"
oSayChave   := TSay():New(04, 01, {|| STR0004+" "+ cChaveDoc}, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont) //"Chave"

oGrpDadosNota := TGroup():New(02,02,75,(oPanelDadosNota:NWIDTH / 2) - 3,,oWorkAreaContainer:GetPanel("WIDDOC"),,,.T.)
If !lThemeDark
	oGrpDadosNota:SetCss("TGroup{background-color: white;}")
EndIf

oTSayTransacao := TSay():New(07, 01, {||STR0033}, oWorkAreaContainer:GetPanel("WIDDOC"),,oFont) //"Selecionar Evento: "
oComboEvento   := TComboBox():New(100,07,{|u|If(PCount()>0,cEvento:=u,cEvento)},;
aTipoEvento,120,20,oWorkAreaContainer:GetPanel("WIDDOC"),,{||(AtorSetTrocaEvento(cEvento),AtorTrocarEvento())},,,,.T.,,,,,,,,,'cEvento',,)

oGrpNotas:= TGroup():New(80,02,(oPanelDadosNota:NHEIGHT / 2) - 3,(oPanelDadosNota:NWIDTH / 2) - 3,,oWorkAreaContainer:GetPanel("WIDDOC"),,,.T.)
If !lThemeDark
	oGrpNotas:SetCss("TGroup{background-color: white;}")
EndIf

oGrpBrowser := TGroup():New(02,02,(oPanelDadosMonitor:NHEIGHT / 2) - 3,(oPanelDadosMonitor:NWIDTH / 2) - 3,,oWorkAreaContainer:GetPanel("WIDMONITOR"),,,.T.)
If !lThemeDark
	oGrpBrowser:SetCss("TGroup{background-color: white;}")
EndIf

AtorTrocarEvento()
Aadd(aButtons,{,STR0010 ,{|| oWorkAreaMain:DeActivate()                },STR0034 ,1,.T.,.T.}) // "Sair"     # "Sair da Rotina"
Aadd(aButtons,{,STR0035 ,{|| AtorRefreshMonitor()                      },STR0038 ,1,.T.,.T.}) // "Refresh"  # "Atualiza Browser Monitor"
Aadd(aButtons,{,STR0036 ,{|| AtorMostraMenssagem(cTitulo+STR0087,"","")},STR0086 ,1,.T.,.T.}) // "Mensagem" # " - Visualiza Evento" # Ator Interessado - Visualiza Evento
Aadd(aButtons,{,STR0037 ,{|| Transmitir()                              },STR0040 ,1,.T.,.T.}) // Transmitir # "Transmitir Eventos"

oWorkAreaMain:AddButtons(aButtons)
oWorkAreaMain:Activate()

FreeObj(oModel)
FreeObj(oView)
FreeObj(oNFs)
FreeObj(oGrdTransp)
FreeObj(oBrowse)
FreeObj(oOkMonitor)
FreeObj(oNoMonitor)
FreeObj(oBrwMonitor)
FreeObj(oFont)
FreeObj(oMdlTela)
FreeObj(oTopBar)
FreeObj(oSize)
FreeObj(oGrpDadosNota)
FreeObj(oGrpNotas)
FreeObj(oGrpBrowser)
FreeObj(oSayCodCli)
FreeObj(oSayNomeCli)
FreeObj(oSayPessoa)
FreeObj(oSayNF)
FreeObj(oSayChave)
FreeObj(oWorkAreaMain)
FreeObj(oWorkAreaContainer)
FreeObj(oPanelDadosNota)
FreeObj(oPanelDadosMonitor)
FreeObj(oTSayTransacao)
FreeObj(oComboEvento)
cEventoSelecionado := ""

Return

/*/{Protheus.doc} Transmitir
Função responsavel por transmitir os eventos
@author Renan Franco
@since  22/02/2021
@version  P12
/*/

Static Function Transmitir()

Local nI       		:= 1
Local cCodMun  		:= SubStr(SM0->M0_CODMUN,1,2)
Local oGridModel	:= FWModelActive()
Local aNfe     		:= {}
Local aTransp  		:= {}
Local nCount		:= 0
Local cURL   		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cError    	:= ""
Local lVisible  	:= If(Type("oTopBar:lVisible") == "L",oTopBar:lVisible,.F.)

If oModel != Nil .And. lVisible
	oGridModel  := oGridModel:GetModel():GetModel("GRDTRANSP") //array de transportadores

	Aadd(aNfe, {(cAliasDocumentos)->F3_CHVNFE, cTpAtor, cCodMun, (cAliasDocumentos)->F3_SERIE+(cAliasDocumentos)->F3_NFISCAL} )

	For nI := 1 To oGridModel:Length() //Transportador
		oGridModel:GoLine(nI)
		If !oGridModel:IsDeleted() .And. !Empty(oGridModel:GetValue("DET_CGC")) 
			Aadd(aTransp, { oGridModel:GetValue("DET_CGC"), If(oGridModel:GetValue("DET_ACESSO"),"1","0") })
		ElseIf !oGridModel:IsDeleted() .And. Empty(Alltrim(oGridModel:GetValue("DET_CGC")) )
			nCount ++
		EndIf
	Next

	If Len(aTransp) > 0 .And. Len(aNfe) > 0 .And. nCount == 0
			
		cIdEnt := RetIdEnti()

		If !Empty(cIdEnt) .and. StrTran(GetVersaoTSS(),".","") < "2.07"

			oWS					:= WsSpedCfgNfe():New()
			oWS:cUSERTOKEN 	  	:= "TOTVS"
			oWS:cID_ENT    		:= cIdEnt
			oWS:nAMBIENTECCE	:= 0
			oWS:cVERCCELAYOUT	:="1.00"
			oWS:cVERCCELAYEVEN	:= "1.00"
			oWS:cVERCCEEVEN		:= "1.00"
			oWS:cVERCCE			:= "1.00"
			oWS:cHORAVERAOCCE	:= "2-Nao"
			oWS:cHORARIOCCE		:= "2-Brasilia"
			oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"

			aCfgCCe := GetCfgCCe(@cError, cIdEnt)
			lOk		:= Empty(cError)

			If lOk
				lOk := AtorModal(aNfe,aTransp)
			EndIf
		EndIf
	Else
		Help(NIL, NIL, STR0041, NIL, If(nCount == 0 ,STR0042,STR0096) , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0043}) //"Eventos NF-e" # "Nenhuma NF-e ou transportador selecionado" # "Selecione ao menos uma NF-e e um transportador para realizar a transmissão do evento."
	EndIf
Else
	Help(NIL, NIL, STR0041, NIL, STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0043}) //"Eventos NF-e" # "Nenhuma NF-e ou transportador selecionado" # "Selecione ao menos uma NF-e e um transportador para realizar a transmissão do evento."
EndIf

If Len(aNfe) > 0
	AtorUpdateMonitor(cEventoSelecionado,(cAliasDocumentos)->F3_CHVNFE)
	FreeObj(oBrwMonitor)
	AtorMontaBrowserMonitor()	
EndIf

Return .T.

/*/{Protheus.doc} AtorModal
Tela de confirmação, processamento e resultado da transmissão do evento
@author Renan Franco
@since  22/02/2021
@version  P12
/*/
Function AtorModal(aNfe, aTransp)

Local oContainer, oSay, oCheckBox, oModal := FWDialogModal():New(), oRet := FWDialogModal():New()
Local aButtons	:= {}
Local cRetorno	:= ""
Local cTexto	:= ""	
Local lOk		:= .F.
Local cNota     := ""

Default aNfe	 := {}
Default aTransp	 := {}
Default bConfirm := {|| oModal:Deactivate(), Processa({|lEnd| cRetorno := SpedAtorTRF(aNfe,aTransp,@cNota), lOk := .T.})} 
   	
If !__evAtor
	
	cTexto := '<p style="font-size:12px">'+;
			STR0044 + If(Len(aTransp) > 1, STR0045, STR0046); //"Confirma a inclusão " # "dos Transportadores " # "do Transportador "
			     	+ If(Len(aNfe   ) > 1, STR0047, STR0048) + '</p>' //"nas notas selecionadas?" # "na nota selecionada?"
		
	Aadd(aButtons, {nil, STR0049, bConfirm, STR0050, 1, .T., .T.,}) //"Sim" # "Botão para confirmar transmissão"

	oModal:SetEscClose(.T.)
	oModal:cFontTitleName := "Verdana"
	oModal:SetTitle(STR0019) //"Evento Ator Interessado"
	oModal:SetSize(100,220) // Altura x Largura
	oModal:CreateDialog()
	oModal:AddButtons(aButtons)
	oModal:AddCloseButton(nil, "Fechar")

	oContainer := TPanelCSS():New( ,,, oModal:getPanelMain())
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oSay := TSay():New(5,5,{||cTexto},oContainer,,/*oFont*/,,,,.T.,,,209,25,,,,,,.T.)
	oCheckBox := TCheckBox():New(40,5,STR0052,{||.T.},oContainer,150,11,,,,,,,,.T.,,,) //"Não exibir essa mensagem novamente"
	oCheckBox:bSetGet := { | U | If( PCOUNT() == 0, __evAtor, __evAtor := U ) }

	oModal:Activate()

Else
	Processa({|lEnd| cRetorno := SpedAtorTRF(aNfe,aTransp,@cNota)})
	lOk := .T.
EndIf

If lOk
	oRet:SetEscClose(.T.)
	oRet:cFontTitleName := "Verdana"
	oRet:SetTitle(STR0019) //"Evento Ator Interessado"
	oRet:SetSize(100,220) // Altura x Larguras
	oRet:CreateDialog()
	oRet:AddCloseButton(nil, STR0051) //"Fechar"

	oContainer := TPanelCSS():New( ,,, oRet:getPanelMain())
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
		
	oSay := TSay():New(5,5,{||cRetorno},oContainer,,,,,,.T.,,,209,30,,,,,,.T.)
	oScroll := tMultiget():new(31.5,05,{| u | If( pCount() > 0, cNota := u, cNota )},oContainer,213,21.5,,,,,,.T.,,,,,,.T.,,,,.T.,.F.,,,)
	oScroll:SetCss("tmultiget {border-style:hidden; font-family:Arial; font-size:11px} ")

	oScroll:lWordWrap := .T.
	oRet:Activate()
		
EndIf

FwFreeObj(oModal)
FwFreeObj(oRet)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedAtorTRF
Função que transmite o evento Ator Interessado na Nf-e

@author Renan Franco
@since 19/02/2020
@version P12

@param	aNfe		[n][1] - chNFe
					[n][2] - tpAutor
					[n][3] - cOrgaoAutor
                    [n][4] - Id da Nfe

		aTransp		[n][1] - CNPJ ou CPF
					[n][2] - tpAutorizacao

@return	cRetorno
/*/
//-------------------------------------------------------------------
Function SpedAtorTRF(aNfe,aTransp,cNotas)

Local aRetorno	:= {}
Local cHoraIni  := Time()
Local cIdEnt    := ""
Local cRetorno  := ""
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local dDataIni	:= Date()
Local lRetorno	:= .F.
Local nEnvio	:= 0
Local nI,nX

If CTIsReady()

	cIdEnt	:= RetIdEnti()
	aXml	:= SpedAtorXml(aNfe,aTransp)

	For nI := 1 to Len(aXml)

		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= aXML[nI]
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWs:RemessaEvento()
		If Type("oWS:oWsRemessaEventoResult:cString") <> "U"                
			aRetorno := oWS:oWsRemessaEventoResult:cString
			For nX := 1 to Len(aNfe)
				nPos := aScan(aRetorno,{|X| Substr(X,9,44) == aNfe[nX][1]})
				If nPos > 0
					nEnvio++
					cNotas += 'NFe ' + aNfe[nX][4]+_CRLF
				EndIf
			Next
		    lRetorno := .T.
		EndIf
	Next nI

	If lRetorno .And. nEnvio > 0
		cRetorno := '<p style="font-size:12px; font-family:arial;text-align:center">'+STR0088+'</p>' //Evento transmitido com sucesso.
		cRetorno += '<p style="font-size:12px; font-family:arial;margin:5px;">';
        +If(nEnvio >1, 	STR0053, STR0054)+ cValToChar(nEnvio)+ If(nEnvio >1, STR0055, STR0056); // "Foram transmitidos " # "Foi transmitido " # " eventos " # " evento "
        +'em ' +IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+'</p>'
	Else
		cRetorno := '<p style="font-size:12px; font-family:arial;text-align:center">'+STR0089+'</p>' //"Houve erro durante a transmissão para o Totvs Services SPED."
		cRetorno += IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	EndIf

Else
	Aviso("SPED",STR0090,{STR0091},3)
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedAtorXml
Função para montagem do XML do evento Ator Interessado na Nf-e

@author renan.franco
@since 19/02/2020
@version P12
/*/
//-------------------------------------------------------------------
function SpedAtorXml(aNfe,aTransp)

Local aXML  := {}
Local cXML := ""
Local nI, nJ
Local nTotal := 0

For nI := 1 to Len(aNfe)
	For nJ := 1 to Len(aTransp)

		nTotal++

		cXml += '		<detEvento>'
		cXml += '			<tpEvento>110150</tpEvento>'
		cXml += '			<chNFe>'+aNfe[nI,1]+'</chNFe>'
		cXml += '			<tpAutor>'+aNfe[nI,2]+'</tpAutor>'
		cXml += '			<cOrgaoAutor>'+aNfe[nI,3]+'</cOrgaoAutor>'
		cXml += '			<autXML>'
		cXml += If(Len(AllTrim(aTransp[nJ,1]))== 14,;
								'<CNPJ>'+Alltrim(aTransp[nJ,1])+'</CNPJ>',;
								'<CPF>'+Alltrim(aTransp[nJ,1])+'</CPF>') // <!---Somente uma opção CNPJ ou CPF-->'
		cXml += '			</autXML>'
		cXml += '			<tpAutorizacao>'+aTransp[1,2]+'</tpAutorizacao>'
		cXml += '		</detEvento>'

		If ( nTotal == 20 .or. (nI == Len(aNfe) .and. nJ == Len(aTransp)) )
			nTotal := 0
			aAdd(aXml, '<envEvento><eventos>'+cXML+'</eventos></envEvento>')
			cXML := ""
		EndIf

	Next nJ
Next nI

Return aXML

/*/{Protheus.doc} AtorPergunta
	Função para pergunta(s) do evento Ator Interessado na Nf-e
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/
Function AtorPergunta()

Local aPerg         As Array
Local lRetorno      As Logical
Local cQuery        As Character
Local cGrupo	    As Character
Local cFil 	    	As Character
Local aInsert       As Array
Local nLenPrepStat  As Numeric
Local cMD5          As Character
Local nPosPrepared  As Numeric
Local nX            As Numeric
Local cCmdNull		As Character 

aPerg     := {}
lRetorno  := .F.
cGrupo	  := FWGrpCompany()
cFil 	  := FWCodFil()
cCmdNull  := "COALESCE("

Aadd(aPerg,{2,STR0057 ,PadR("",Len("2-Entrada"))						  ,{"1-Saída","2-Entrada"} ,80	  ,		 		     ,.T.   ,           }) //"Tipo de NFe"###"1-Saída"###"2-Entrada"
Aadd(aPerg,{1,STR0006 ,Space(TamSX3('A1_COD')[01])						  ,""					   ,".T." ,"AtorAltConsul()" ,".T."	,50		,.T.}) //"Cliente/Fornecedor"
Aadd(aPerg,{1,STR0007 ,Space(TamSX3('A1_LOJA')[01])						  ,""					   ,".T." ,""			     ,".T."	,30		,.F.}) //loja
Aadd(aPerg,{1,STR0058 ,PadR("",Len(If(lSdoc,SF2->F2_SDOC,SF2->F2_SERIE))) ,""					   ,".T." ,""			     ,".T."	,30		,.F.}) //"Serie da Nota Fiscal"
Aadd(aPerg,{1,STR0059 ,Space(tamsx3("F2_DOC")[1])						  ,""					   ,".T." ,""			     ,".T."	,30		,.F.}) //"nota inicial"
Aadd(aPerg,{1,STR0060 ,Space(tamsx3("F2_DOC")[1])						  ,""					   ,".T." ,""			     ,".T."	,30		,.F.}) //"nota final"	
Aadd(aPerg,{1,STR0061 ,Date()											  ,""					   ,".T." ,""			     ,".T."	,80		,.F.}) //"Dt de emissão inicial"
Aadd(aPerg,{1,STR0062 ,Date()											  ,""					   ,".T." ,""			     ,".T."	,80		,.F.}) //"Dt de emissão final"

lRetorno := ParamBox(aPerg,"Ator int.",, {|| AtorFiltro() },,,,,,"SPEDNFE"+STR0063+cGrupo+cFil,.T.,.F.) //"AtorInt"

If lRetorno
    cQuery := " SELECT  F3_NFISCAL  		F3_NFISCAL	,"
    cQuery += "         F3_SERIE    		F3_SERIE	,"
    cQuery += "         F3_CLIEFOR  		F3_CLIEFOR	,"
    cQuery += "         F3_LOJA     		F3_LOJA		,"
    cQuery += "         F3_CHVNFE   		F3_CHVNFE	,"
    cQuery += "         F3_EMISSAO  		F3_EMISSAO	,"
    cQuery += " "+cCmdNull+"A1_NOME,'') 	A1_NOME 	,"
    cQuery += " "+cCmdNull+"A1_CGC,'')      A1_CGC		,"
    cQuery += " "+cCmdNull+"A1_PESSOA,'')   A1_PESSOA	, "
    cQuery += " "+cCmdNull+"A2_NOME,'') 	A2_NOME 	,"
    cQuery += " "+cCmdNull+"A2_CGC,'')      A3_CGC		,"
    cQuery += " "+cCmdNull+"A2_TIPO,'')   	A2_TIPO		,"
	cQuery += " "+cCmdNull+"F1_CHVNFE,'')	F1_CHVNFE	,"
	cQuery += " "+cCmdNull+"F2_CHVNFE,'')	F2_CHVNFE	 "
    cQuery += " FROM ? SF3" 
 	cQuery += " LEFT JOIN " 
    cQuery += "      ? SA1 ON   SF3.F3_CLIEFOR	= SA1.A1_COD     "
    cQuery += "             AND SF3.F3_LOJA     = SA1.A1_LOJA    "
    cQuery += "             AND ? 				= SA1.A1_FILIAL  "
    cQuery += "             AND SF3.D_E_L_E_T_	= SA1.D_E_L_E_T_ "
 	cQuery += " LEFT JOIN "
    cQuery += "      ? SA2 ON   SF3.F3_CLIEFOR	= SA2.A2_COD     "
    cQuery += "             AND SF3.F3_LOJA     = SA2.A2_LOJA    "
    cQuery += "             AND ? 				= SA2.A2_FILIAL  "
    cQuery += "             AND SF3.D_E_L_E_T_	= SA2.D_E_L_E_T_ "
 	cQuery += " LEFT JOIN "
    cQuery += "      ? SF2 ON   SF3.F3_NFISCAL	= SF2.F2_DOC     "
    cQuery += "             AND SF3.F3_SERIE    = SF2.F2_SERIE   "
	cQuery += "      		AND SF3.F3_CLIEFOR	= SF2.F2_CLIENTE "
    cQuery += "             AND SF3.F3_LOJA     = SF2.F2_LOJA    "
    cQuery += "             AND SF3.F3_CHVNFE   = SF2.F2_CHVNFE   "
    cQuery += "             AND ? 				= SF2.F2_FILIAL  "
    cQuery += "             AND SF3.D_E_L_E_T_	= SF2.D_E_L_E_T_ "
 	cQuery += " LEFT JOIN "
    cQuery += "      ? SF1 ON   SF3.F3_NFISCAL	= SF1.F1_DOC     "
    cQuery += "             AND SF3.F3_SERIE    = SF1.F1_SERIE   "
	cQuery += "      		AND SF3.F3_CLIEFOR	= SF1.F1_FORNECE "
    cQuery += "             AND SF3.F3_LOJA     = SF1.F1_LOJA    "
    cQuery += "             AND SF3.F3_CHVNFE   = SF1.F1_CHVNFE   "
    cQuery += "             AND ? 				= SF1.F1_FILIAL  "
    cQuery += "             AND SF3.D_E_L_E_T_	= SF1.D_E_L_E_T_ "
    cQuery += " WHERE   SF3.F3_FILIAL   =  ? "
    cQuery += "     AND SF3.D_E_L_E_T_  =  ? "
	cQuery += "     AND SF3.F3_CHVNFE   <> ? "
  	cQuery += "     AND SF3.F3_CODRSEF  =  ? "
    cQuery += "     AND SF3.F3_CLIEFOR  =  ? "
    cQuery += "     AND SF3.F3_LOJA     =  ? "
    cQuery += "     AND SF3.F3_SERIE    =  ? "
    cQuery += "     AND SF3.F3_NFISCAL  BETWEEN ? AND ? "
    cQuery += "     AND SF3.F3_EMISSAO  >= ? "
    cQuery += "     AND SF3.F3_EMISSAO  <= ? "
	cQuery += "		AND "+cCmdNull+"SF2.F2_SERIE,'')	=  ? "
	cQuery += "		AND "+cCmdNull+"SF1.F1_SERIE,'')	=  ? "

    aInsert := {}
    Aadd(aInsert, RetSqlName("SF3") ) //01
    Aadd(aInsert, RetSqlName("SA1") ) //02
    Aadd(aInsert, FWxFilial("SA1")  ) //03 	
    Aadd(aInsert, RetSqlName("SA2") ) //04
    Aadd(aInsert, FWxFilial("SA2")  ) //05
    Aadd(aInsert, RetSqlName("SF2") ) //06
    Aadd(aInsert, FWxFilial("SF2")  ) //07
    Aadd(aInsert, RetSqlName("SF1") ) //08 
    Aadd(aInsert, FWxFilial("SF1")  ) //09
    Aadd(aInsert, xFilial("SF3")    ) //10
    Aadd(aInsert, ' '               ) //11
	Aadd(aInsert, ' '               ) //12
  	Aadd(aInsert, '100'             ) //13
    Aadd(aInsert, MV_PAR02          ) //14
    Aadd(aInsert, MV_PAR03          ) //15
    Aadd(aInsert, MV_PAR04          ) //16
    Aadd(aInsert, MV_PAR05          ) //17
    Aadd(aInsert, MV_PAR06          ) //18
    Aadd(aInsert, Dtos(MV_PAR07)    ) //10
    Aadd(aInsert, Dtos(MV_PAR08)    ) //20
	Aadd(aInsert, If(Left(MV_PAR01,1) == "1",MV_PAR04," "))
	Aadd(aInsert, If(Left(MV_PAR01,1) == "2",MV_PAR04," "))

    nLenPrepStat := Len(aInsert)
    cMD5         := MD5(cQuery) 
    If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
        cQuery := ChangeQuery(cQuery)
        Aadd(__aPrepared,{FwExecStatement():New(cQuery),cMD5 })
        nPosPrepared := Len(__aPrepared)			
    EndIf 

    For nX := 1 To nLenPrepStat
		If nx == 1 .Or. nx == 2 .Or. nx == 4 .Or. nx == 6 .Or. nx == 8
			__aPrepared[nPosPrepared][1]:SetUnsafe(nX, aInsert[nX])
		Else
    	    __aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
		EndIf
    Next 
    cQueryDocumentos := __aPrepared[nPosPrepared][1]:GetFixQuery()
    cAliasDocumentos := __aPrepared[nPosPrepared][1]:OpenAlias()
    
    __aPrepared[nPosPrepared][1]:Destroy()
	FreeObj(__aPrepared[nPosPrepared][1])
EndIf

Return(lRetorno)

/*/{Protheus.doc} AtorFiltro
	Função para filtro do evento Ator Interessado na Nf-e
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/
Function AtorFiltro()

Local lRet		As Logical
Local cMsgAtor	As Character

lRet	 := .T.
cMsgAtor := ""

If MV_PAR05 <> "" .AND. MV_PAR06 <> ""
	If MV_PAR06 < MV_PAR05
		cMsgAtor += STR0064+_CRLF //"Nota fiscal final menor que a inicial"
	EndIf
EndIf

If MV_PAR08 < MV_PAR07
	cMsgAtor += STR0065+_CRLF //"Data de emissão final menor que a inicial"
EndIf

If !Empty(cMsgAtor)
	lRet := .F.
	Help(,,STR0092,,STR0066,1,0,,,,,, {cMsgAtor}) //"Atenção" # "Revise as Informações a seguir:"
EndIf

Return(lRet)

/*/{Protheus.doc} AtorVisualizaDocumento
    (long_description)
    @author Leonardo Miranda
    @since 18/11/2024
    @version 12.1.2410
    /*/
Function AtorVisualizaDocumento()

Local aArea 	:= GetArea()		 As Array 
Local aRotRec	:= aClone(aRotina)	 As Array

If !Empty(Alltrim((cAliasDocumentos)->F2_CHVNFE))
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+(cAliasDocumentos)->F3_NFISCAL+;
								(cAliasDocumentos)->F3_SERIE  +;
								(cAliasDocumentos)->F3_CLIEFOR+;
								(cAliasDocumentos)->F3_LOJA))
	Mc090Visual("SF2",SF2->(Recno()),1)
Else
	SF1->(DbSetOrder(8))
	SF1->(DbSeeK(xFilial("SF1")+(cAliasDocumentos)->F1_CHVNFE))
	aRotina := {{""                          ,""           ,0,2,0 ,NIL},;
				{OemToAnsi(SubStr(STR0095,2)),"A103NFiscal",0,2,0 ,NIL}}
	A103NFiscal("SF1",SF1->(RecNo()),2)
	aRotina := aClone(aRotRec)
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} AtorThemaSistema
	Recebe o Thema selecionado para ajuste de cores do SCSS das Telas
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
	/*/
Function AtorThemaSistema()

Local lRelease2410 	:= (GetRpoRelease() >= "12.1.2310" .Or. GetRpoRelease() >= "12.1.2410") as logical
Local oTheme        := nil as object

If lRelease2410
	oTheme := totvs.framework.css.ProtheusTheme():New()
	If Alltrim(oTheme:CTHEME) == "DARK"
		lThemeDark := .T.
	EndIf
EndIf

FreeObj(oTheme)

Return

/*/{Protheus.doc} AtorSetTrocaEvento
	Seta o evento Selecionado ao acionar o controle de evento
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/
Function AtorSetTrocaEvento(cValue as character)

If Empty(cValue)
	cEventoSelecionado := ""
Else
	cEventoSelecionado := Substr(Alltrim(cValue),1,6)
EndIf

Return

/*/{Protheus.doc} AtorTrocarEvento
	Função responsalvel por Mudar o comportamento ao trocar o tipo de evento
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/
Function AtorTrocarEvento()

If Empty(cEventoSelecionado) .OR. cEventoSelecionado == cEventoMonitor
	AtorActionCampos()
	AtorRefreshMonitor()
EndIf

If cEventoSelecionado == cEventoTransmissao
	AtorActionCampos()
	AtorRefreshMonitor()
EndIf

Return

/*/{Protheus.doc} AtorActionCampos
	(long_description)
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
	/*/
Function AtorActionCampos()

If cEventoSelecionado == cEventoTransmissao

	If oTopBar == Nil
		oTopBar := TPanel():New( 119 , 05 ,,oGrpNotas,,,,,, 370,115)
	Else
		oTopBar:Show()
	EndIf

	If oMdlTela == Nil
    	oMdlTela := FWLoadModel("SPEDATORINT")
    	oMdlTela:SetOperation( MODEL_OPERATION_INSERT )
    	oMdlTela:Activate()  
	EndIf
 
	If oView == Nil
        oView := FWLoadView("SPEDATORINT")
        oView:SetModel(oMdlTela)
        oView:SetOwner(oTopBar)
        oView:SetOperation( MODEL_OPERATION_INSERT )
        oView:Activate()
	EndIf

	AtorUpdateMonitor(cEventoSelecionado,(cAliasDocumentos)->F3_CHVNFE)

	FreeObj(oBrwMonitor)
	AtorMontaBrowserMonitor()

ElseIf Empty(cEventoSelecionado) .Or. cEventoSelecionado == cEventoMonitor

	If oTopBar != NIL
		oTopBar:Hide()
	EndIf
EndIf

Return

/*/{Protheus.doc} AtorUpdateMonitor
	Atualiza os dados no Monitor de Eventos
	@author Leoanrdo Mirnada
	@since 18/10/2024
	@version 12.1.2410
/*/
Function AtorUpdateMonitor(cEvento as character, cChaveDoc as character)

Local aEventosRetorno   := {} as array

aSize(aBrowserMonitor,0)
If Empty(cEvento) .OR. cEventoSelecionado == cEventoMonitor
	cEvento := cEventoTransmissao
	aEventosRetorno := AtorCallRetornaEvento(cChaveDoc,cEvento)
	AtorSetArrayMonitor(aEventosRetorno,cEvento)
Else
	aEventosRetorno := AtorCallRetornaEvento(cChaveDoc,cEvento)
	AtorSetArrayMonitor(aEventosRetorno,cEvento)
EndIf

If Empty(aBrowserMonitor)
	aBrowserMonitor := { {.F.,'','','','','','','','','','',0}}
EndIf

Return

/*/{Protheus.doc} AtorMontaBrowserMonitor
	Monta o Browser do Monitor de Eventos
	@author Leonardo Miranda
	@since 18/10/2024
	@version 12.1.2410
/*/
Function AtorMontaBrowserMonitor()

oOKMonitor := LoadBitmap(GetResources(),STR0067) //"br_verde"
oNOMOnitor := LoadBitmap(GetResources(),STR0068) //"br_vermelho"

aSort(aBrowserMonitor,,,{|x,y| x[3] < y[3] })

oBrwMonitor := TCBrowse():New( 05 , 05, oPanelDadosMonitor:NWIDTH / 2 - 10, oPanelDadosMonitor:NHEIGHT / 2 - 10 ,, {'',STR0069,STR0070,STR0071,STR0072,STR0073,STR0074,STR0075,STR0076,STR0077,STR0078},; //'Evento',"Sequência","Documento","Série","Protocolo","ID","Cod.Evento","Evento","Cod.Ret","Mensagem"
		{20,40,30,40,25,50,170,45,50,25,170},oWorkAreaContainer:GetPanel("WIDMONITOR"),,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oBrwMonitor:SetArray(aBrowserMonitor)
oBrwMonitor:bLine := {||{ If( aBrowserMonitor[oBrwMonitor:nAt,01],oOKMonitor,oNOMonitor),;
	                              aBrowserMonitor[oBrwMonitor:nAt,02],;
		                          aBrowserMonitor[oBrwMonitor:nAt,03],;
	                              aBrowserMonitor[oBrwMonitor:nAt,04],;
		                          aBrowserMonitor[oBrwMonitor:nAt,05],;
		                          aBrowserMonitor[oBrwMonitor:nAt,06],;
			                      aBrowserMonitor[oBrwMonitor:nAt,07],;
			                      aBrowserMonitor[oBrwMonitor:nAt,08],;
			                      aBrowserMonitor[oBrwMonitor:nAt,09],;
			                      aBrowserMonitor[oBrwMonitor:nAt,10],;
			                      aBrowserMonitor[oBrwMonitor:nAt,11]}}

oBrwMonitor:DrawSelect()
oBrwMonitor:Refresh()

Return

/*/{Protheus.doc} AtorCallRetornaEvento
	Chama o endpoint para retornar os eventos da NFe
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410	
/*/
Function AtorCallRetornaEvento(cChave as character, cEvento as character)
Local cError := ""                                                      as character
Local cMsg   := ""                                                      as character
Local aValue := TSSMonEven(@cError,,cIdEnt,cChave,cChave,cEvento,@cMsg) as array

Return aValue

/*/{Protheus.doc} AtorRefreshMonitor
	Refresh Monitor
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/
Function AtorRefreshMonitor()

AtorUpdateMonitor(cEventoSelecionado,(cAliasDocumentos)->F3_CHVNFE)
FreeObj(oBrwMonitor)
AtorMontaBrowserMonitor()

Return

/*/{Protheus.doc} AtorSetArrayMonitor
	Popula o array do Browser do Monitor 
	@author Leonardo Miranda
	@since 18/11/2024
	@version 12.1.2410
/*/

Function AtorSetArrayMonitor(aValue as array, cEvento as character)

Local nCount     := 0  as numeric
Local nTamID     := 0  as numeric
Local cSeq       := "" as character
Local cDocumento := "" as character
Local cSerie     := "" as character

For nCount := 1 To Len(aValue)

	nTamID      := Len(aValue[nCount,3])
	cSeq        := SubStr(Alltrim(aValue[nCount,3]),nTamID-2,2)
	cDocumento  := SubStr(Alltrim(aValue[nCount,3]),34,9)
	cSerie      := SubStr(Alltrim(aValue[nCount,3]),31,3)
	Aadd(aBrowserMonitor,{iIf(aValue[nCount,1] == 6,.T.,.f.) ,;
		 STR0079  											 ,; //"Transmissão"
		 cSeq                                                ,;
		 cDocumento                                          ,;
		 cSerie                                              ,;
		 aValue[nCount,2]                                    ,;
		 aValue[nCount,3]                                    ,;
		 "110150"									       	 ,;
    	 aValue[nCount,6]                                 	 ,;
		 aValue[nCount,7]                                 	 ,;
		 aValue[nCount,8]})
Next

Return

/*/{Protheus.doc} AtorMostraMenssagem 
	Mostra Dados do evento no Monitor de eventos
	@author Leonardo Miranda
	@since 19/11/2024
	@version 12.1.2410
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
/*/
Function AtorMostraMenssagem(cTitulo as character, cSubTitulo as character, cMenssagem as character)

Local oModal 	 := nil as object
Local oContainer := nil as object
Local oTMultLine := nil as Object
Local nLinha := 0 as numeric

nLinha := oBrwMonitor:nAt

cMenssagem := STR0069 +" - "+Alltrim(aBrowserMonitor[nLinha,2])+_CRLF     //"Evento:"
cMenssagem += STR0070 +":  "+Alltrim(aBrowserMonitor[nLinha,3])+_CRLF     //"Sequência:"
cMenssagem += STR0071 +":  "+Alltrim(aBrowserMonitor[nLinha,4])+_CRLF     //"Documento:"
cMenssagem += STR0072 +":  "+Alltrim(aBrowserMonitor[nLinha,5])+_CRLF     //"Série:"
cMenssagem += STR0073 +":  "+Alltrim(aBrowserMonitor[nLinha,6])+_CRLF     //"Protocolo:"
cMenssagem += STR0074 +":  "+Alltrim(aBrowserMonitor[nLinha,7])+_CRLF     //"ID:"
cMenssagem += STR0093 +":  "+Alltrim(aBrowserMonitor[nLinha,8])+_CRLF     //"Status:"
cMenssagem += STR0094 +":  "+Alltrim(aBrowserMonitor[nLinha,9])+_CRLF     //"Descrição:"
cMenssagem += STR0075 +":  "+cValtoChar(aBrowserMonitor[nLinha,10])+_CRLF //"Cod.Evento:"
cMenssagem += STR0078 +":  "+Alltrim(aBrowserMonitor[nLinha,11])+_CRLF    //"Mensagem:"

oModal := FWDialogModal():New()
oModal:SetEscClose(.T.)
oModal:SetTitle(cTitulo)
oModal:setSubTitle(cSubTitulo)

oModal:setSize(250,250)

oModal:CreateDialog()
oModal:addCloseButton(nil,"Fechar")

oContainer := TPanel():New(,,,oModal:GetPanelMain())
If !lThemeDark
	oContainer:SetCss("TPanel{background-color : white;}")
EndIf
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

oTMultLine := TMultiget():New(01,01,{| u | If( pCount() > 0, cMenssagem := u, cMenssagem)},oContainer,245,180,,,,,,.T.)
oTMultLine:lReadOnly := .T.
oModal:Activate()

Return

/*/{Protheus.doc} AtorAltConsul 
	Função que altera a consulta F3 
	@author Leonardo Miranda
	@since 19/11/2024
	@version 12.1.2410
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
/*/

Function AtorAltConsul()

If Substr(MV_PAR01,1,1) == "1"
	If ConPad1(,,,"SA1")
		MV_PAR02 := aCpoRet[1]
		MV_PAR03 := aCpoRet[2]
	EndIf
Else
	If ConPad1(,,,"SA2")
		MV_PAR02 := aCpoRet[1]
		MV_PAR03 := aCpoRet[2]
	EndIf
EndIf

Return
