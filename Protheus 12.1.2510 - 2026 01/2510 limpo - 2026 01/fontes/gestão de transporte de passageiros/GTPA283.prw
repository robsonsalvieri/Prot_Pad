#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA283.CH"

Static __cCodBil    := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA283
Cadastro de Requisições 
@author  Renan Ribeiro Brando   
@since   26/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA283()

Local oBrowse := Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    oBrowse := FWLoadBrw('GTPA283')
    oBrowse:Activate()
    oBrowse:Destroy()
    GTPDestroy(oBrowse)

EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} BrowseDef

@type Static Function
@author jacomo.fernandes
@since 04/03/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GQW")
oBrowse:SetMenuDef('GTPA283')

oBrowse:SetDescription(STR0001) // Cadastro de Requisições
oBrowse:DisableDetails()

oBrowse:AddLegend("GQW_STATUS == '1'"   ,"BLUE"     ,"Baixado"              ,"GQW_STATUS"   )
oBrowse:AddLegend("GQW_STATUS == '2'"   ,"WHITE"    ,"Não Baixado"          ,"GQW_STATUS"   )

oBrowse:AddLegend("GQW_CONFER == '1'"   ,"GREEN"    ,"Conferido"            ,"GQW_CONFER"   )
oBrowse:AddLegend("GQW_CONFER == '2'"   ,"RED"      ,"Não Conferido"        ,"GQW_CONFER"   )

oBrowse:AddLegend("Empty(GQW_CODLOT)"   ,"WHITE"    ,"Sem Lote Vinculado"   ,"GQW_CODLOT"   )
oBrowse:AddLegend("!Empty(GQW_CODLOT)"  ,"GREEN"    ,"Lote Vinculado"       ,"GQW_CODLOT"   )

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu da Rotina
@author  Renan Ribeiro Brando
@since   26/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA283"  OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA283"  OPERATION 3 ACCESS 0//"Incluir"
ADD OPTION aRotina TITLE STR0016 ACTION "VIEWDEF.GTPA283"  OPERATION 4 ACCESS 0//"Alterar"
ADD OPTION aRotina TITLE STR0017 ACTION "VIEWDEF.GTPA283"  OPERATION 5 ACCESS 0//"Excluir"
ADD OPTION aRotina TITLE STR0024 ACTION "VIEWDEF.GTPA283A" OPERATION 4 ACCESS 0//"Conferencia"
ADD OPTION aRotina TITLE STR0050 ACTION "GP283ANX()" OPERATION 4 ACCESS 0//"Anexos de Documentos"
ADD OPTION aRotina TITLE STR0063 ACTION "GTPA283D()" OPERATION 4 ACCESS 0 //'Transferência'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelos de Dados da Rotina
@author  Renan Ribeiro Brando
@since   26/05/2017
@version P12]
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStruGQW  := FWFormStruct(1, "GQW")
Local oStruGIC  := FWFormStruct(1, "GIC")
Local bPreVld   := { |oMdl,nLine,cAction,cField,uNewValue,uOldValue| MdlPreVld(oMdl,nLine,cAction,cField,uNewValue,uOldValue)}
Local bPosVld   := { |oModel| GP283PsVld(oModel)}
Local bVldActiv := { |oModel| MdlVldActiv(oModel) }
Local bCommit   := { |oModel| ModelCommit(oModel) }

SetModelStruct(oStruGQW,oStruGIC)

oModel := MPFormModel():New("GTPA283",/*bPreVld*/, bPosVld /*bPosValidMdl*/, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001) // Cadastro de Requisições

oModel:AddFields("FIELDGQW" ,/*cOwner*/ ,oStruGQW)
oModel:AddGrid("GRIDGIC"    , "FIELDGQW", oStruGIC,/*bLinePre*/,/* bLinePost */ ,bPreVld,/*bPost*/,/*bLoadGIC*/ )

oModel:SetRelation( "GRIDGIC", { { "GIC_FILIAL", "xFilial('GIC')" } , { "GIC_CODREQ", "GQW_CODIGO" } } , GIC->(IndexKey(7)))

oStruGIC:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld()}, .F., .F., .T.)

oModel:GetModel("GRIDGIC"):SetMaxLine(9990)

oModel:GetModel("GRIDGIC"):SetOnlyQuery(.T.)

oModel:GetModel("GRIDGIC"):SetUniqueLine({"GIC_CODIGO"})

If IsInCallStack("GP283ANX")
    oModel:GetModel('GRIDGIC'):SetNoInsertLine(.T.)
    oModel:GetModel('GRIDGIC'):SetNoDeleteLine(.T.)
EndIf

oModel:SetVldActivate(bVldActiv)
oModel:SetCommit(bCommit)

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 04/03/2020
@version 1.0
@param oStruGQW, character, (Descrição do parâmetro)
@param oStruGIC, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGQW,oStruGIC)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue)       }
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)      }
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)                                   }
Local bWhen		:= {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)                                      }

If ValType(oStruGQW) == "O"
    If GQW->( ColumnPos( 'GQW_CODH7A' ) ) > 0
        oStruGQW:AddField(  STR0053,;			    // 	[01]  C   Titulo do campo //"Descrição"
                            STR0053,;				// 	[02]  C   ToolTip do campo //"Descrição"
                            "GQW_DSCH7A",;				// 	[03]  C   Id do Field
                            "C",;						// 	[04]  C   Tipo do campo
                            TAMSX3("H7A_DESCRI")[1],;		// 	[05]  N   Tamanho do campo
                            0,;							// 	[06]  N   Decimal do campo
                            Nil,;						// 	[07]  B   Code-block de validação do campo
                            Nil,;						// 	[08]  B   Code-block de validação When do campo
                            Nil,;						//	[09]  A   Lista de valores permitido do campo
                            .F.,;						//	[10]  L   Indica se o campo tem preenchimento obrigatório
                            {|| Iif(!Inclui,Posicione( "H7A", 1, xFilial('H7A') + GQW->(GQW_CODH7A), 'H7A_DESCRI'),"") },;//	[11]  B   Code-block de inicializacao do campo
                            .F.,;						//	[12]  L   Indica se trata-se de um campo chave
                            .F.,;						//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.)						// 	[14]  L   Indica se o campo é virtual
    Endif

    oStruGQW:AddTrigger("GQW_CODCLI", "GQW_CODCLI" ,{ ||.T.}, bTrig )
    oStruGQW:AddTrigger("GQW_CODLOJ", "GQW_CODLOJ" ,{ ||.T.}, bTrig )
    oStruGQW:AddTrigger("GQW_CODAGE", "GQW_CODAGE" ,{ ||.T.}, bTrig )

    oStruGQW:SetProperty('GQW_TOTAL'    , MODEL_FIELD_VALID , {|| .T.})
	oStruGQW:SetProperty('GQW_CODAGE'   , MODEL_FIELD_VALID , bFldVld )
    If GQW->( ColumnPos( 'GQW_CODH7A' ) ) > 0 
        oStruGQW:SetProperty('GQW_CODH7A'   , MODEL_FIELD_VALID , bFldVld )
        oStruGQW:SetProperty('GQW_CODCLI'   , MODEL_FIELD_VALID , bFldVld )
        oStruGQW:SetProperty('GQW_CODLOJ'   , MODEL_FIELD_VALID , bFldVld )
        oStruGQW:AddTrigger("GQW_CODH7A", "GQW_DSCH7A" ,{ ||.T.}, bTrig )
    Endif
    oStruGQW:SetProperty("GQW_CODCLI"   , MODEL_FIELD_WHEN  , bWhen )
	oStruGQW:SetProperty("GQW_CODLOJ"   , MODEL_FIELD_WHEN  , bWhen )
	oStruGQW:SetProperty("GQW_CODAGE"   , MODEL_FIELD_WHEN  , bWhen )

    If IsInCallStack("GP283ANX")
        oStruGQW:SetProperty("*"        , MODEL_FIELD_WHEN  , {|| .F.} )
    EndIf

    If !GtpIsInPoui()
        oStruGQW:SetProperty('GQW_CODCLI'    , MODEL_FIELD_VALID , {|| .T.})
        oStruGQW:SetProperty('GQW_CODLOJ'    , MODEL_FIELD_VALID , {|| .T.})
    EndIf
Endif

If ValType(oStruGIC) == "O"
    oStruGIC:AddTrigger("GIC_CODIGO", "GIC_CODIGO" ,{||.T.}, bTrig )
    oStruGIC:AddTrigger("GIC_REQTOT", "GIC_REQTOT" ,{||.T.}, bTrig )

    oStruGIC:SetProperty("*", MODEL_FIELD_INIT      , {||"" })
    oStruGIC:SetProperty('*', MODEL_FIELD_VALID     , {||.T.})
    oStruGIC:SetProperty("*", MODEL_FIELD_OBRIGAT   , .F.)

    oStruGIC:SetProperty("GIC_NLOCDE", MODEL_FIELD_INIT , bInit )
    oStruGIC:SetProperty("GIC_NLOCOR", MODEL_FIELD_INIT , bInit )
    If IsInCallStack("GP283ANX")
        oStruGIC:SetProperty("*"        , MODEL_FIELD_WHEN  , {|| .F.} )
    EndIf

    oStruGIC:SetProperty('GIC_CODIGO', MODEL_FIELD_VALID, bFldVld )

Endif

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View da Rotina
@author  Renan Ribeiro Brando
@since   26/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := FWFormView():New()
Local oModel    := FwLoadModel('GTPA283')
Local oStruGQW  := FWFormStruct(2, "GQW")
Local oStruGIC  := FWFormStruct(2, 'GIC' , { |x| AllTrim(x)+"|" $ "GIC_CODIGO|GIC_BILHET|GIC_LOCORI|GIC_NLOCOR|GIC_LOCDES|GIC_NLOCDE|"+;
                                                                  "GIC_TAX|GIC_TAR|GIC_PED|GIC_REQDSC|GIC_REQTOT|GIC_VALTOT|GIC_SGFACU|GIC_CODREQ|"+;
                                                                  "GIC_STATUS|GIC_TIPO|GIC_DTVEND|GIC_NUMBPE|GIC_LINHA|GIC_NOMEPA|" } )
Local bFldAction    := {|oView| oView:Refresh() }
Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

SetViewStruct(oStruGQW,oStruGIC)

oView:SetModel(oModel)

oView:AddField("VIEW_GQW", oStruGQW, "FIELDGQW")
oView:AddGrid("VIEW_GIC" , oStruGIC, 'GRIDGIC') 

oStruGIC:AddField("ANEXO","01",STR0051,STR0051,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"

oView:SetViewProperty("VIEW_GIC", "GRIDDOUBLECLICK", bDblClick)

oView:CreateHorizontalBox( "BOX_GQW", 40)
oView:CreateHorizontalBox( "BOX_GIC", 60)

oView:SetOwnerView("VIEW_GQW", "BOX_GQW")
oView:SetOwnerView("VIEW_GIC", "BOX_GIC")

If !IsInCallStack("GP283ANX")
    oView:addUserButton(STR0004, "", {|oView| FwMsgRun(,{|| GA283LoadTks(oView) ,oView:Refresh()}, STR0025, STR0026 )} ,,,{3 ,4} )  // "Carregar bilhetes", "Carregando Bilhetes", "Aguarde" 
    oView:addUserButton(STR0018, "", {|oView| FwMsgRun(,{|| GA285Recal(oView)   ,oView:Refresh()},        , STR0027 )} ,,,{3 ,4} )  // "Reaplicar Descontos", "Recalculando"
EndIf
oView:AddUserButton(STR0049, "", {|oView| AtacDocGQW(oView)}) // "Documentos Anexos Cabec"

oView:SetViewAction("DELETELINE"   , bFldAction )
oView:SetViewAction("UNDELETELINE" , bFldAction )

oView:SetFieldAction("GQW_CODCLI"   , bFldAction )
oView:SetFieldAction("GQW_CODLOJ"   , bFldAction )
oView:SetFieldAction("GQW_CODAGE"   , bFldAction )
oView:SetFieldAction("GIC_CODIGO"   , bFldAction )
oView:SetFieldAction("GIC_REQTOT"   , bFldAction )

Return oView
//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 04/03/2020
@version 1.0
@param oStruGQW, character, (Descrição do parâmetro)
@param oStruGIC, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGQW,oStruGIC)

If ValType(oStruGQW) == 'O'

    If GQW->(FieldPos("GQW_CODH7A")) > 0     
        oStruGQW:SetProperty("GQW_CODIGO",MVC_VIEW_ORDEM,"01")
        oStruGQW:SetProperty("GQW_CODORI",MVC_VIEW_ORDEM,"02")
        oStruGQW:SetProperty("GQW_REQDES",MVC_VIEW_ORDEM,"03")
        oStruGQW:SetProperty("GQW_CODH7A",MVC_VIEW_ORDEM,"04")
        oStruGQW:AddField(	"GQW_DSCH7A",;	// [01]  C   Nome do Campo
                            "05",;			// [02]  C   Ordem
                            STR0053,;	// [03]  C   Titulo do campo //"Descrição"
                            STR0053,;	// [04]  C   Descricao do campo //"Descrição"
                            {STR0053},;	// [05]  A   Array com Help //"Descrição"
                            "GET",;			// [06]  C   Tipo do campo
                            "@!",;			// [07]  C   Picture
                            NIL,;			// [08]  B   Bloco de Picture Var
                            "",;			// [09]  C   Consulta F3
                            .F.,;			// [10]  L   Indica se o campo é alteravel
                            NIL,;			// [11]  C   Pasta do campo
                            "",;			// [12]  C   Agrupamento do campo
                            NIL,;			// [13]  A   Lista de valores permitido do campo (Combo)
                            NIL,;			// [14]  N   Tamanho maximo da maior opção do combo
                            NIL,;			// [15]  C   Inicializador de Browse
                            .T.,;			// [16]  L   Indica se o campo é virtual
                            NIL,;			// [17]  C   Picture Variavel
                            .F.)			// [18]  L   Indica pulo de linha após o campo
        oStruGQW:SetProperty("GQW_CODCLI",MVC_VIEW_ORDEM,"06")
        oStruGQW:SetProperty("GQW_CODLOJ",MVC_VIEW_ORDEM,"07")
        oStruGQW:SetProperty("GQW_NOMCLI",MVC_VIEW_ORDEM,"08")
        oStruGQW:SetProperty("GQW_CODAGE",MVC_VIEW_ORDEM,"09")
        oStruGQW:SetProperty("GQW_NOMAGE",MVC_VIEW_ORDEM,"10")
        oStruGQW:SetProperty("GQW_DATEMI",MVC_VIEW_ORDEM,"11")
        oStruGQW:SetProperty("GQW_TOTAL",MVC_VIEW_ORDEM,"12")
        oStruGQW:SetProperty("GQW_TOTDES",MVC_VIEW_ORDEM,"13")
        oStruGQW:SetProperty("GQW_STATUS",MVC_VIEW_ORDEM,"14")
        oStruGQW:SetProperty("GQW_CONFER",MVC_VIEW_ORDEM,"15")
        oStruGQW:SetProperty("GQW_CODLOT",MVC_VIEW_ORDEM,"16")
        oStruGQW:SetProperty("GQW_CONFCH",MVC_VIEW_ORDEM,"17")
        oStruGQW:SetProperty("GQW_MOTREJ",MVC_VIEW_ORDEM,"18")
        oStruGQW:SetProperty("GQW_USUCON",MVC_VIEW_ORDEM,"18")
        oStruGQW:SetProperty("GQW_NUMFCH",MVC_VIEW_ORDEM,"19")

    Endif

	oStruGQW:SetProperty('GQW_CODIGO', MVC_VIEW_CANCHANGE   , .F. )
	oStruGQW:SetProperty('GQW_TOTDES', MVC_VIEW_CANCHANGE   , .F. )
	oStruGQW:SetProperty("GQW_CONFER", MVC_VIEW_CANCHANGE   , .F. )
    If GQW->(FieldPos("GQW_CONFCH")) >  0
        oStruGQW:RemoveField("GQW_CONFCH")
    EndIf
    If GQW->(FieldPos("GQW_MOTREJ")) >  0
        oStruGQW:RemoveField("GQW_MOTREJ")
    EndIf
    If GQW->(FieldPos("GQW_USUCON")) >  0
        oStruGQW:RemoveField("GQW_USUCON")
    EndIf
    If GQW->(FieldPos("GQW_NUMFCH")) >  0
        oStruGQW:RemoveField("GQW_NUMFCH")
    EndIf

Endif

If ValType(oStruGIC) == "O"
    oStruGIC:SetProperty("*"         , MVC_VIEW_CANCHANGE   , .F.)
    oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_CANCHANGE   , .T.)
    oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_ORDEM       , "0")
    oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_LOOKUP      ,"GICREQ")

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GA283LoadTks(oView)
Facilitador que abre pergunte der ranges de bilhetes e os adiciona ao GRID
@author  Renan Ribeiro Brando
@since   14/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA283LoadTks(oView)
Local oModel	:= oView:GetModel()
Local oModelGIC := oModel:GetModel("GRIDGIC")
Local lRet      := .T.
Local cAgencia  := oModel:GetModel('FIELDGQW'):GetValue('GQW_CODAGE')
Local aBilhetes := {}
Local nX        := 0

If !Empty(cAgencia)

    aBilhetes := GTPA283B(cAgencia)

    For nX := 1 To Len(aBilhetes)

        If (!oModelGIC:SeekLine({{"GIC_CODIGO", aBilhetes[nX]}}))
                    
            If (!Empty(oModelGIC:GetValue("GIC_CODIGO")) .Or. oModelGIC:IsDeleted())
                oModelGIC:AddLine(.T.)
            Endif

            oModelGIC:SetValue("GIC_CODIGO", aBilhetes[nX])   

        Endif

    Next
     
    oModelGIC:GoLine(1) 

Else
    FwAlertHelp(STR0040, STR0041, STR0005) // "Agência não informada","Informe uma agência antes de selecionar os bilhetes","Atenção")    
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelCommit(oModel)
Bloco de commit da rotina
@author  Renan Ribeiro Brando
@since   07/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet      := .T. 
Local oModelGIC := FWLoadModel("GTPA115")
Local oGridGIC  := oModel:GetModel('GRIDGIC')
Local cReq      := oModel:GetModel("FIELDGQW"):GetValue("GQW_CODIGO")
Local nI        := 1

GIC->(DBSetOrder(1)) // GIC_FILIAL + GIC_CODIGO
// Altera o modelo GIC para update afim de atrelar o código da requisição
oModelGIC:SetOperation(MODEL_OPERATION_UPDATE)

Begin Transaction
    // Varre o GRID preenchendo o array com o código dos bilhetes ativos 
    FOR nI := 1 To oGridGIC:Length()
        IF GIC->(DBSeek(xFilial("GIC") + oGridGIC:GetValue("GIC_CODIGO", nI) ))

            oModelGIC:Activate()

            // Preenche o código da requisição no bilhete
            // Na inserção ou alteração da requisição o código deve ser atualziado no bilhete  
            IF !oGridGIC:IsDeleted(nI) .AND. oModel:GetOperation() <> 5
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODREQ", cReq)
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_REQDSC",oGridGIC:GetValue("GIC_REQDSC",nI))
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_REQTOT",oGridGIC:GetValue("GIC_REQTOT",nI))
            // Na deleção o código deve ser apagado
            ELSE
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODREQ",  ""  )
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_REQDSC",  0   )
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_REQTOT",  0   )
            ENDIF

            // Commit do FIELD
            IF !(oModelGIC:VldData() .and. oModelGIC:CommitData())
                lRet := .F.
                If !IsInCallStack('GTPA285')
                    JurShowErro( oModelGIC:GetErrormessage() )	
                Endif
                DisarmTransaction()
                Break
            ENDIF    

            // Desativa o modelo
            oModelGIC:DeActivate()

        Endif

    NEXT nI

End Transaction

// Destrói instância de oModelGIC
oModelGIC:Destroy()

// Faz o commit do modelo todo 
IF (lRet)
    FWFormCommit(oModel)
ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MdlPreVld(oModelGIC, nLine, cOperation, cField, uValue)
description
@author  Renan Ribeiro Brando   
@since   13/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MdlPreVld(oMdl, nLine, cAction, cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local oModelGQW := oModel:GetModel('FIELDGQW')
Local nOpc		:= oMdl:GetOperation()

Local cMdlId    := oMdl:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""

IF ( cAction == "CANSETVALUE" .And. cField == 'GIC_CODIGO')
    If Empty(oModelGQW:GetValue('GQW_CODCLI')) .or. Empty(oModelGQW:GetValue('GQW_CODLOJ'))
        lRet        := .F.
        cMsgErro    := STR0020 // 'Código do cliente ou loja não informado'
        cMsgSol     := STR0021 // 'Informe o código do Cliente e Loja no cabeçalho da rotina'

    ElseIf Empty(oModelGQW:GetValue('GQW_CODAGE'))
        lRet        := .F.
        cMsgErro    := STR0042 // 'Código da agencia não informado'
        cMsgSol     := STR0043 // 'Informe o código da agencia no cabeçalho da rotina'
    Endif

ElseIf cAction == "DELETE" .or. cAction == "UNDELETE"
    If (nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE);
        .and. !Empty(oMdl:GetValue('GIC_NUMFCH')) .AND. !Empty(oMdl:GetValue('GIC_CODREQ'))

        lRet        := .F.
        cMsgErro    := STR0028 // 'Não é possivel excluir o bilhete da requisição, pois o mesmo se encontra vinculado à uma ficha de remessa'
		cMsgErro    += STR0060 + oMdl:GetValue('GIC_CODREQ')  // ' Requisição: '
        cMsgErro    += STR0061 + oMdl:GetValue('GIC_BILHET')  // ' Bilhete: '
        cMsgErro    += STR0062 + oMdl:GetValue('GIC_NUMBPE')  // ' N° BPE: '
        cMsgSol     := STR0044 // 'Desvicule o bilhete da ficha antes de realizar essa operação'
    Else
        If !FwIsInCallStack('GTPA283D')
            oMdl:GetData()[nLine][3] := If(cAction == "DELETE",.T.,.F.)
            GTPReCalc(oMdl) 
        EndIf 
    Endif                          
ENDIF

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"MdlPreVld",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPReCalc
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GTPReCalc(oModelGIC)
Local oModel    := oModelGIC:GetModel()
Local nValTot   := 0
Local nDesTot   := 0
Local n1        := 0

For n1 := 1 to oModelGIC:Length()
    If !oModelGIC:IsDeleted(n1)
        nValTot += oModelGIC:GetValue('GIC_REQTOT',n1)
        nDesTot += oModelGIC:GetValue('GIC_REQDSC',n1)
    Endif
Next

oModel:GetModel('FIELDGQW'):LoadValue('GQW_TOTAL'    ,nValTot)
oModel:GetModel('FIELDGQW'):LoadValue('GQW_TOTDES'   ,nDesTot)

Return

/*/{Protheus.doc} MdlVldActiv
Função responsavel para validação de ativação do modelo
@type function
@author jacomo.fernandes
@since 13/08/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return lRet, Caso retorne falso, não será possivel alterar o modelo
/*/
Static Function MdlVldActiv(oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local cMdlId    := oModel:GetId()
Local cField    := ""
Local cMsgErro  := ""
Local cMsgSol   := ""

If nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_DELETE
	If !(FwIsInCallStack('GTPA284') .or. FwIsInCallStack('GTPA285')  .or. FwIsInCallStack('GTPA502'))

		If !Empty(GQW->GQW_CODLOT)
			lRet        := .F.
            cField      := "GQW_CODLOT"
            cMsgErro    := STR0029 // "Requisições vinculadas em lotes não podem ser alteradas ou excluidas"

		ElseIf lRet .and. GQW->GQW_STATUS = "1"
			lRet        := .F.
            cField      := "GQW_STATUS"
            cMsgErro    := STR0030 // "Requisições já baixadas não podem ser alteradas ou excluidas"

		Elseif nOpc == MODEL_OPERATION_DELETE .and. !ChkBilFch()
			lRet        := .F.
            cField      := "GQW_STATUS"
            cMsgErro    := STR0031 //"Requisições que possuem bilhetes vinculados à ficha de remessa não podem ser excluidas"

        Elseif nOpc == MODEL_OPERATION_DELETE .and. GQW->GQW_CONFER == '1'
            lRet        := .F.
            cField      := "GQW_STATUS"
            cMsgErro    := STR0048
        Endif

	Endif
Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"MdlVldActiv",cMsgErro,cMsgSol,,)
Endif

Return lRet 

/*/{Protheus.doc} ChkBilFch
Função responsavel para verificar se existem bilhetes vinculados à ficha de remessa nessa requisição
@type function
@author jacomo.fernandes
@since 13/08/2018
@version 1.0
/*/
Static Function ChkBilFch()
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()

	BeginSql Alias cAliasTmp 
		Select 
			Count(GIC_NUMFCH) as TOTFCH
		From
			%Table:GIC% GIC
		Where
			GIC.GIC_FILIAL = %xFilial:GIC%
			And GIC.GIC_AGENCI = %Exp:GQW->GQW_CODAGE%
			And GIC.GIC_CODREQ = %Exp:GQW->GQW_CODIGO%
			And GIC.GIC_NUMFCH <> ''
			And GIC.%NotDel%
	
	EndSql
	
	lRet := (cAliasTmp)->TOTFCH == 0
	
	(cAliasTmp)->(DbCloseArea())
	
Return lRet


/*/{Protheus.doc} FieldValid
(long_description)
@type function
@author jacomo.fernandes
@since 13/08/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return lRet, ${return_description}
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""
Local lNewCpos	:= AvExisteTab('H7S')
Local lEmiGIC	:= GTPGetRules("HABEMIGIC",,,.T.)

Local aAreaGIC  := nil

If FwIsInCallStack('GTPA283D')
    Return lRet
EndIf 

Do Case
    Case Empty(uNewValue)
        lRet := .T.

    Case cField == 'GQW_CODAGE'
        If !GtpExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro    := STR0032 // "Agência informada não existe"

        ElseIf !oModel:GetModel('GRIDGIC'):IsEmpty()
            IF !(!IsBlind() .and. FwAlertYesNo(STR0033)) // "Existem bilhetes selecionados, deseja remove-los?"
                lRet    := .F.
                cMsgErro:= STR0045 // "Processo Abortado pelo usuário"
            Endif

        Endif

    Case cField == "GIC_CODIGO"
        aAreaGIC := GIC->(GetArea())
                
        GIC->(DbSetOrder(1))    //GIC_FILIAL+GIC_CODIGO

        If !GIC->(DbSeek( xFilial("GIC") + uNewValue ) )
            lRet    := .F.
            cMsgErro:= STR0034 //"Código do bilhete não encontrado"
            cMsgSol := STR0015 //"Selecione outro bilhete."

        ElseIf !Empty(GIC->GIC_CODREQ)
            lRet    := .F.
            cMsgErro:= STR0014 //"Já existe uma requisição para o bilhete!"
            cMsgSol := STR0015 //"Selecione outro bilhete."

        ElseIf GIC->GIC_STATUS <> 'V'
            lRet    := .F.
            cMsgErro:= STR0035 //"Status do bilhete não permite que o mesmo seja selecionado"
            cMsgSol := STR0015 //"Selecione outro bilhete."

        ElseIf GIC->GIC_AGENCI <> oModel:GetValue('FIELDGQW','GQW_CODAGE')
            lRet    := .F.
            cMsgErro:= STR0036 //"Bilhete selecionado não pertence a agência informada na requisição"
            cMsgSol := STR0015 //"Selecione outro bilhete."
        
        ElseIf lNewCpos .AND. !Gp283ChkParCli(oModel:GetValue('FIELDGQW','GQW_CODCLI'),;
                               oModel:GetValue('FIELDGQW','GQW_CODLOJ'),;
                               GIC->GIC_LINHA)
            lRet := .F.
            cMsgErro    := STR0056 + ALLTRIM(GIC->GIC_LINHA)// "Cliente possui restrição de bilhetes na linha "
            cMsgSol     := STR0057 // "Verifique o cadastro de parâmetros de cliente"
        
        ElseIf !lEmiGIC .AND. !IsInCallStack("GA283LoadTks") .AND. GIC->GIC_DTVEND < Daysub(Date(),30)
            lRet := .F.
            cMsgErro    := STR0058 // "Não é permitido inclusão de bilhetes emitidos a mais de 30 dias"
            cMsgSol     := STR0059 // "Verifique o parâmetro HABEMIGIC"
        Endif

        RestArea(aAreaGIC)
        GtpDestroy(aAreaGIC)

    Case cField $ "GQW_CODCLI|GQW_CODLOJ"   
        If GQW->(FieldPos("GQW_CODH7A")) > 0 .And. !Empty(oModel:GetValue('FIELDGQW','GQW_CODH7A'))
            If Gp283QryCl(  oModel:GetValue('FIELDGQW','GQW_CODH7A'),;
                            oModel:GetValue('FIELDGQW','GQW_CODCLI'),;
                            oModel:GetValue('FIELDGQW','GQW_CODLOJ'))
                lRet    := .F.
                cMsgErro:= STR0054 //"Cliente selecionado não faz parte da aglutinação de requisições."
                cMsgSol := STR0055 //"Selecione um cliente que esteja vinculado na aglutinação de requisições."
            Endif
        Endif
        If lRet .And. !ExistCpo("GQV",oModel:GetValue('FIELDGQW',"GQW_CODCLI")+AllTrim(oModel:GetValue('FIELDGQW',"GQW_CODLOJ")))
            lRet    := .F.
        Endif
    Case cField $ "GQW_CODH7A"
        If !Empty(uNewValue)
            If !ExistCpo('H7A',uNewValue)
                lRet := .F.
            Endif
        Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type function
@author jacomo.fernandes
@since 13/08/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel    := oMdl:GetModel()
If GtpIsInPoui()
    Do Case
        Case cField == "GQW_CODCLI"
            oMdl:SetValue("GQW_CODLOJ",'')

        Case cField == "GQW_CODLOJ"
            oMdl:SetValue("GQW_NOMCLI",Posicione("SA1", 1, xFilial("SA1") +oMdl:GetValue("GQW_CODCLI")+ uVal, "A1_NOME"))

        Case cField == "GQW_CODAGE"
            oMdl:SetValue("GQW_NOMAGE",Posicione("GI6", 1, xFilial("GI6") + uVal, "GI6_DESCRIC"))

            oModel:GetModel('GRIDGIC'):ClearData()

        Case cField == "GIC_CODIGO" .And. !Empty(uVal)
            GA283TrigBil(oMdl)
            GTPReCalc(oMdl)

        Case cField == "GIC_REQTOT"
            GTPReCalc(oMdl)
        Case cField == "GQW_CODH7A"
           uVal := Posicione("H7A", 1, xFilial("H7A") + uVal, "H7A_DESCRIC")

    EndCase
EndIf

Return uVal

//-------------------------------------------------------------------
/*/{Protheus.doc} GA283TrigBil()
Gatilho que preenche os dados do bilhete
@author  Renan Ribeiro Brando
@since   05/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA283TrigBil(oGridGIC)
Local aArea     := GetArea()
Local aGICStruct:= GIC->(DbStruct())
Local oStruGIC  := oGridGIC:GetStruct()
Local n1        := 0
Local cFldsGIC  :=  "GIC_CODIGO|GIC_BILHET|GIC_LOCORI|GIC_NLOCOR|GIC_LOCDES|GIC_NLOCDE|"+;
                    "GIC_TAX|GIC_TAR|GIC_PED|GIC_REQDSC|GIC_REQTOT|GIC_VALTOT|GIC_SGFACU|GIC_CODREQ|"+;
                    "GIC_STATUS|GIC_TIPO|GIC_DTVEND|GIC_NUMBPE|GIC_LINHA|GIC_NOMEPA|" 

    GIC->(DbSeek(xFilial('GIC')+oGridGIC:GetValue("GIC_CODIGO")))

    For n1 := 1 to Len(aGicStruct) 
        If oStruGIC:HasField(aGicStruct[n1][1]) .And. aGicStruct[n1][1] $ cFldsGIC
            oGridGIC:LoadValue(aGicStruct[n1][1],GIC->(&(aGicStruct[n1][1])))
        Endif
    Next
    oGridGIC:SetValue("GIC_NLOCDE", Posicione('GI1' ,1 ,xFilial("GI1") + oGridGIC:GetValue("GIC_LOCDES"), "GI1_DESCRI"))
    oGridGIC:SetValue("GIC_NLOCOR", Posicione('GI1', 1, xFilial("GI1") + oGridGIC:GetValue("GIC_LOCORI"), "GI1_DESCRI"))

    GA285Desc(oGridGIC)

    GtpDestroy(aGICStruct)

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Função responsavel pelo When dos Campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param uVal, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local lInsert   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lTrig     := FwIsInCallStack('FIELDTRIGGER')
If GtpIsInPoui()
    Do Case
        Case lTrig
            lRet := .T.
        Case cField == "GQW_CODCLI" .or. cField == "GQW_CODLOJ"
            lRet := oMdl:GetValue('GQW_CONFER') == "2"
        Case cField == "GQW_CODAGE"
            lRet := lInsert
    EndCase
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Função responsavel pela inicialização dos campos
@type Static Function
@author 
@since 08/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := uVal
Local lInsert   := oMdl:GetOperation() == MODEL_OPERATION_INSERT
If GtpIsInPoui()
    Do Case 
        Case cField == "GIC_NLOCOR"
            If !lInsert
                uRet := Posicione('GI1', 1, xFilial('GI1') + GIC->GIC_LOCORI, 'GI1_DESCRI')
            Else
                uRet := ""
            Endif
        Case cField == "GIC_NLOCDE"
            If !lInsert
                uRet := Posicione('GI1', 1, xFilial('GI1') + GIC->GIC_LOCDES, 'GI1_DESCRI')
            Else
                uRet := ""
            Endif
    EndCase
EndIf
Return uRet
//------------------------------------------------------------------------------
/* /{Protheus.doc} G283FilSxb
Função responsvel pela busca dos bilhetes conforme o cadastro de requisição
@type Function
@author jacomo.fernandes
@since 03/03/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Function G283FilSxb()
Local lRet          := .F.
Local aRetorno      := {}
Local cQuery        := ""
Local oLookUp       := Nil

Local oModel        := Nil 
Local cAgencia      := ''
Local lEmiGIC	    := Nil

If FwIsInCallStack('GTPA283D')
    lRet := FilReqOriginal()
    Return lRet 
EndIF 

oModel   := FwModelActive()
cAgencia := oModel:GetModel( 'FIELDGQW' ):GetValue( 'GQW_CODAGE' )
lEmiGIC  := GTPGetRules("HABEMIGIC",,,.T.)

cQuery += "SELECT "
cQuery += "GIC.GIC_CODIGO, "
cQuery += "GIC.GIC_BILHET, "
cQuery += "GIC.GIC_LINHA, "
cQuery += "GIC.GIC_LOCORI, "
cQuery += "GI1ORI.GI1_DESCRI GIC_NLOCOR, "
cQuery += "GIC.GIC_LOCDES, "
cQuery += "GI1DES.GI1_DESCRI GIC_NLOCDE, "
cQuery += "GIC.GIC_DTVEND, "
cQuery += "GIC.GIC_TIPO, "
cQuery += "GIC.GIC_STATUS, "
cQuery += "GIC.GIC_ORIGEM, "
cQuery += "GIC.GIC_NUMBPE, "
cQuery += "GIC.GIC_LINHA, "
cQuery += "GIC.GIC_SGFACU, "
cQuery += "GIC.GIC_TAR, "
cQuery += "GIC.GIC_TAX, "
cQuery += "GIC.GIC_PED, "
cQuery += "GIC.GIC_SGFACU, "
cQuery += "GIC.GIC_VALTOT, "
cQuery += "GIC.GIC_CCF "
cQuery += "FROM "+RetSqlName("GIC")+" GIC "
cQuery += "Left JOIN "+RetSqlName("GI1")+" GI1ORI ON "
cQuery += "GI1ORI.GI1_FILIAL = '"+xFilial("GI1")+"' "
cQuery += "AND GI1ORI.GI1_COD = GIC.GIC_LOCORI "
cQuery += "AND GI1ORI.D_E_L_E_T_  = ' ' "
cQuery += "Left JOIN "+RetSqlName("GI1")+" GI1DES ON "
cQuery += "GI1DES.GI1_FILIAL = '"+xFilial("GI1")+"' "
cQuery += "AND GI1DES.GI1_COD = GIC.GIC_LOCDES "
cQuery += "AND GI1DES.D_E_L_E_T_  = ' ' "
cQuery += "WHERE "
cQuery += "GIC.GIC_FILIAL = '"+xFilial("GIC")+"' "
cQuery += "AND GIC.D_E_L_E_T_ = ' ' "
cQuery += "AND GIC.GIC_CODREQ = '"+Space(TamSx3('GIC_CODREQ')[1])+"' "
cQuery += "AND GIC.GIC_AGENCI =  '"+cAgencia+"' "
cQuery += "AND GIC.GIC_STATUS = 'V' "
IF !lEmiGIC
    cQuery += "AND GIC.GIC_DTVEND >= '"+DTOS(Daysub(Date(),30))+"' "
ENDIF
cQuery += "ORDER BY GIC.GIC_CODIGO "

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GIC_CODIGO"})

oLookUp:AddButton("Visualizar","Visualizar",{|| SXBVisual(oLookUp)}) 

oLookUp:AddIndice("Código"          , "GIC_CODIGO")
oLookUp:AddIndice("Cód. Origem"     , "GIC_LOCORI")
oLookUp:AddIndice("Cód. Destino"    , "GIC_LOCDES")
oLookUp:AddIndice("Dsc. Destino"    , "GIC_NLOCOR")
oLookUp:AddIndice("Dsc. Destino"    , "GIC_NLOCDE")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	__cCodBil := aRetorno[1]
EndIf   

FreeObj(oLookUp)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} G283RetFil
Função responsavel pelo retorno da consulta especifica
@type Function
@author jacomo.fernandes
@since 03/03/2020
@version 1.0
@return cRet, return_description
/*/
//------------------------------------------------------------------------------
Function G283RetFil()
Local cRet := __cCodBil
Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SXBVisual
Função responsavel pela visualização do registro posicionado na consulta especifica
@type Function
@author jacomo.fernandes
@since 03/03/2020
@version 1.0
@return cRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function SXBVisual(oLookUp)
local cCodBil   := (oLookUp:cAlias)->GIC_CODIGO
Local aAreaGIC  := GIC->(GetArea())

GIC->(DbSetOrder(1))
If GIC->(DbSeek(xFilial('GIC')+cCodBil))
    FWExecView("Visualizar","VIEWDEF.GTPA115",MODEL_OPERATION_VIEW,,{|| .T.})
Else
    FwAlertHelp(STR0046, STR0047, STR0005) // "Não foi possivel encontrar o bilhete selecionado","Verifique os dados selecionados","Atenção!!"
Endif

RestArea(aAreaGIC)
GTPDestroy(aAreaGIC)

return 

/*/{Protheus.doc} AttachDocs(oView)
Função para tratamento do MsDocument para anexar os documentos aos itens.
@type  Static Function
@author Eduardo Silva
@since 13/03/2024
/*/
Static Function AttachDocs(oView)
Local nOpc   := 4
Local nRecno := oView:GetModel():GetModel('GRIDGIC'):GetDataId()
Local oMdl   := oView:GetModel()
If oMdl:GetOperation() == MODEL_OPERATION_VIEW .Or. IsInCallStack("GP421EVWNX") .Or. IsInCallStack("GTPA421E")
    nOpc := 2
EndIf
If nOpc == 2 .Or. IsInCallStack("GP283ANX")
    MsDocument('GIC' , GIC->(nRecno),nOpc)
EndIf
oView:GetModel():GetModel('GRIDGIC'):LoadValue("ANEXO", SetIniFld())
oView:Refresh()
Return 

/*/{Protheus.doc} SetIniFld()
Função para tratamento da legenda do item (campo anexo).
@type  Static Function
@author Eduardo Silva
@since 13/03/2024
/*/
Static Function SetIniFld()
Local cValor    := ''
AC9->( dbSetOrder(2) )
If AC9->(dbSeek(xFilial('AC9') + 'GIC' + xFilial('GIC') + xFilial('GIC') + GIC->GIC_CODIGO) )
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
EndIf
Return cValor

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Função de tratamento par ao duplo clique do anexo.
@type  Static Function
@author Eduardo Silva
@since 12/03/2024
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()
Local oMdl  := oView:GetModel()
If cField == 'ANEXO'
    If oMdl:GetOperation() == MODEL_OPERATION_VIEW .Or. IsInCallStack("GP283ANX")
        AttachDocs(oView)
    Else
        MsgInfo(STR0052)   // "Para utilização do campo de anexo, somente na tela anterior em Outras Ações/Anexos de Documentos"
    EndIf
EndIf
Return .T.

/*/{Protheus.doc} AtacDocGQW(oView)
Função para tratamento do MSDocument para anexar os documentos ao cabeçalho.
@type  Static Function
@author Eduardo Silva
@since 12/03/2024
/*/
Static Function AtacDocGQW(oView)
Local nOpc   := 4
Local oMdl   := oView:GetModel()
If oMdl:GetOperation() == MODEL_OPERATION_VIEW .Or. IsInCallStack("GP421EVWNX") .Or. IsInCallStack("GTPA421E")
    nOpc := 2
EndIf
If nOpc == 2 .Or. IsInCallStack("GP283ANX")
    MsDocument('GQW', GQW->(Recno()),nOpc)
Else
    MsgInfo(STR0052)    // "Para utilização do campo de anexo, somente na tela anterior em Outras Ações/Anexos de Documentos"
EndIf
oView:Refresh()
Return 

/*/{Protheus.doc} GP283ANX()
Função que abrirá a tela da requisição para anexar os documentos.
@type  Static Function
@author Eduardo Silva
@since 12/03/2024
/*/
Function GP283ANX()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
FWExecView(STR0050,"VIEWDEF.GTPA283",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons)   // "Anexos de Documentos"
Return

/*/{Protheus.doc} GP283Filt()
Função de filtro para 
@type  Function
@author Kaique Schiller
@since 01/04/2024
/*/
Function GP283Filt()
Local lRet := .T.

If !Empty(FwFldGet("GQW_CODH7A"))
    lRet := FwFldGet("GQW_CODH7A")==Posicione('H7B',2,xFilial('H7B')+FwFldGet("GQW_CODH7A")+GQV->GQV_CODIGO+GQV->GQV_CODLOJ,'H7B_CODH7A')
Endif

Return lRet

/*/{Protheus.doc} Gp283QryCl()
Query para validar se existe o vinculo com o cliente na aglutinação de requisição
@type  Function
@author Kaique Schiller
@since 01/04/2024
/*/
Function Gp283QryCl(cCodAgl,cCodCli,cCodLoj)
Local cAliasTmp	:= GetNextAlias()
Local cWhere :=  ""
Local lRet  := .T.

If !Empty(cCodLoj)
    cWhere += " AND H7B.H7B_CODLOJ = '"+cCodLoj+"' "
Endif

cWhere := "%"+cWhere+"%"

BeginSql Alias cAliasTmp 
    SELECT 1 REG
    FROM
        %Table:H7B% H7B
    WHERE
        H7B.H7B_FILIAL = %xFilial:H7B%
        AND H7B.H7B_CODH7A = %Exp:cCodAgl%
        AND H7B.H7B_CODCLI = %Exp:cCodCli%
        AND H7B.%NotDel%
        %Exp:cWhere%
EndSql

lRet := (cAliasTmp)->REG == 0

(cAliasTmp)->(DbCloseArea())
	
Return lRet

/*/{Protheus.doc} GP283PsVld()
Posvalide do modelo
@type  Function
@author Kaique Schiller
@since 01/04/2024
/*/
Static Function GP283PsVld(oModel)
Local lRet := .T.

If GQW->( ColumnPos( 'GQW_CODH7A' ) ) > 0 .And. !Empty(oModel:GetValue("FIELDGQW","GQW_CODH7A"))
    If Gp283QryCl(  oModel:GetValue("FIELDGQW","GQW_CODH7A"),;
                    oModel:GetValue("FIELDGQW","GQW_CODCLI"),;
                    oModel:GetValue("FIELDGQW","GQW_CODLOJ"))
        lRet := .F.
        Help(NIL, NIL, 'GP283PsVld', NIL,STR0054, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0055}) //"Cliente selecionado não faz parte da aglutinação de requisições."##"Selecione um cliente que esteja vinculado na aglutinação de requisições."
    Endif
Endif

Return lRet


/*/{Protheus.doc} Gp283ChkParCli()
Validar se existe restrição de linhas do cliente
@type  Function
@author João Pires
@since 08/08/2024
/*/
Static Function Gp283ChkParCli(cCodCli,cCodLoj,cCodLin)
    Local aArea	:= GetArea()   
    Local lRet  := .T.

    DBSelectArea('H7S')
    H7S->(DBSetOrder(2)) //H7S_FILIAL+H7S_CLIENT+H7S_LOJA

    IF H7S->(DBSeek(xFilial('H7S') + cCodCli + cCodLoj))
        lRet  := .F.

        While H7S->(!Eof()) .AND. H7S->(H7S_FILIAL+H7S_CLIENT+H7S_LOJA) == xFilial('H7S') + cCodCli + cCodLoj
            
            IF H7S->H7S_CODLIN == cCodLin
                lRet  := .T.
                Exit
            ENDIF

            H7S->(DBSkip())
        Enddo

    ENDIF

    H7S->(DbCloseArea())

    RestArea(aArea)

Return lRet

/*/{Protheus.doc} GP283TRANSF()
Chamada da função de transferência GTPA283
@type  Function
@author José Carlos
@since 03/12/2025
/*/
Function GP283TRANSF()
    FWExecView(STR0063,"VIEWDEF.GTPA283",MODEL_OPERATION_INSERT,,{|| .T.}) //'Transferência'  	
Return Nil 

/*/{Protheus.doc} FilReqOriginal()
LooKup Consulta Requisições 
@type  Function
@author José Carlos
@since 03/12/2025
/*/
Static Function FilReqOriginal()
Local lRet          := .F.
Local aRetorno      := {}
Local cQuery        := ""
Local oLookUp       := Nil

Local oModel        := FwModelActive()
Local oMdlHead      := oModel:GetModel('HEADER')
Local cDataIni		:= Dtos(oMdlHead:GetValue('DATAINI'))
Local cDataFim		:= Dtos(oMdlHead:GetValue('DATAFIM'))
Local cAgencDe 		:= oMdlHead:GetValue('AGENCIAINI')
Local cAgencAte		:= oMdlHead:GetValue('AGENCIAFIM')
Local cCliIni		:= oMdlHead:GetValue('CLIENTEINI')
Local cCliFim		:= oMdlHead:GetValue('CLIENTEFIM')

cQuery += "SELECT "
cQuery += "GQW_CODORI,"
cQuery += "GQW_CODIGO,"
cQuery += "GQW_REQDES "
cQuery += "FROM "+RetSqlName("GQW")+" GQW "
cQuery += "WHERE "
cQuery += "GQW_FILIAL = '"+xFilial("GQW")+"' "
cQuery += "AND GQW_CODORI <> ' ' "
cQuery += "AND GQW_DATEMI BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
If !Empty(cCliFim)
    cQuery += "AND GQW_CODCLI BETWEEN '"+cCliIni+"' AND '"+cCliFim+"' "
EndIF 
If !Empty(cAgencAte)
    cQuery += "AND GQW_CODAGE BETWEEN '"+cAgencDe+"' AND '"+cAgencAte+"' "
EndIf     

cQuery += "AND GQW.GQW_STATUS = '2' AND GQW.GQW_CONFER = '2' AND GQW.GQW_CODLOT = ' '"
cQuery += "AND GQW.D_E_L_E_T_ = ' ' "

cQuery += "ORDER BY GQW_CODIGO "

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GQW_CODORI"})

oLookUp:AddIndice("Req.Original" , "GQW_CODORI")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	__cCodBil := aRetorno[1]
EndIf   

FreeObj(oLookUp)

Return lRet
