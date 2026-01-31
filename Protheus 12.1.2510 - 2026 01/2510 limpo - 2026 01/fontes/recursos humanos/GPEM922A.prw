#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM922A.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEM922A
@type			function
@description	Cadastro MVC para apresentar os registros da tabela RJE
@author			lidio.oliveira
@since			02/05/2024
/*/
//---------------------------------------------------------------------
Function GPEM922A()

    Local lContinua := ChkFile("RJE") 
    Local cFiltraRh := ""
    Local oBrowse

    If !lContinua
        //"Atenção"
        //"Tabela RJE não existe no ambiente."
        //"Execute as atualizações da expedição contínua do RH (Pacote e UPDDISTR) para acessar esta rotina."
        Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
        Return
	EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription( OemToAnsi(STR0004) ) //"Registros na tabela de fila no monitor middleware"
    oBrowse:SetAlias( "RJE" )

    //Inicializa o filtro
	oBrowse:SetFilterDefault( cFiltraRh )
    fRJELeg(@oBrowse)

	oBrowse:ExecuteFilter(.T.)    

    oBrowse:Activate()

Return 


//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			lidio.oliveira
@since			02/05/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
    
    Local aRotina :=  {}

    ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 //"Pesquisar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0006) ACTION 'VIEWDEF.GPEM922A'	OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0007) ACTION 'fAjuRec()'	        OPERATION 4 ACCESS 0 //"Ajustar Recibo"

Return( aRotina )


//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			lidio.oliveira
@since			02/05/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel    := MPFormModel():New( "GPEM922A" )
    Local oStruRJE  := FWFormStruct( 1, 'RJE')
   
    oModel:AddFields( "GPEM922A_RJE", /*cOwner*/, oStruRJE )
    oModel:SetVldActivate( { |oModel| .T. } )

    //Definição de chave primária do modelo
	oModel:SetPrimaryKey({'RJE_TPINSC','RJE_INSCR','RJE_EVENTO','RJE_KEY','RJE_INI','DTOS(RJE_DTG)'})

Return( oModel )


//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			lidio.oliveira
@since			08/04/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel	:=	FWLoadModel( "GPEM922A" )
    Local oView		:=	FWFormView():New()
    Local oStruRJE	:=	FWFormStruct( 2, "RJE" )

	oView:SetModel(oModel)
    oView:AddField( "VIEW_RJE", oStruRJE, "GPEM922A_RJE" )
	oView:CreateHorizontalBox( 'FIELDSRJE' , 100 )
    oView:SetOwnerView( "VIEW_RJE", "FIELDSRJE" )

Return( oView )


//---------------------------------------------------------------------
/*/{Protheus.doc} fRJELeg
Legenda do browse
@author  Recursos Humanos
@since   02/05/2024
/*/
//---------------------------------------------------------------------
Function fRJELeg(oBrowse)

    oBrowse:AddLegend( "RJE->RJE_STATUS=='1' .AND. EMPTY(RJE->RJE_EXC)"		, 'GREEN'	, OemToAnsi(STR0010), , .T. )        //"Evento pendente de envio"
    oBrowse:AddLegend( "RJE->RJE_STATUS=='2' .AND. EMPTY(RJE->RJE_EXC)"		, 'YELLOW'	, OemToAnsi(STR0011), , .T. )       //"Evento aguardando retorno"
    oBrowse:AddLegend( "RJE->RJE_STATUS=='3' .AND. EMPTY(RJE->RJE_EXC)"		, 'ORANGE'	, OemToAnsi(STR0012), , .T. )                //"Evento rejeitado"
    oBrowse:AddLegend( "RJE->RJE_STATUS=='4' .AND. EMPTY(RJE->RJE_EXC)"		, 'BLUE'	, OemToAnsi(STR0013), , .T. )  //"Evento transmitido com sucesso"
    oBrowse:AddLegend( "!EMPTY(RJE->RJE_EXC)"		, 'BLACK'	, OemToAnsi(STR0014), , .T. )  //"Evento excluído"

Return( .T. )



//---------------------------------------------------------------------
/*/{Protheus.doc} fAjuRec
Função para possibilitar o ajuste do recibo
@author lidio.oliveira
@since 02/05/2024
@version 1.0
@return Nil
/*/
//---------------------------------------------------------------------
Function fAjuRec()

    Local oDlg			:= NIL
    Local oBtOk		    := NIL
    Local oBtFechar     := Nil
    Local oGroup		:= NIL
    Local cRecibo       := Space(TamSX3("RJE_RECIB")[1])
    Local lContinua     := .T.

    If !(RJE->RJE_STATUS $ "1*3" .And. Empty(RJE->RJE_EXC))
        //"Atenção!"
        //"O Ajuste de recibo só pode ser executado para registros pendentes de envio ou rejeitados."
        //"Verifique o registro e tente novamente."
        Help( " ", 1, OemToAnsi(STR0018),, OemToAnsi(STR0016), 2 , 0 , , , , , , { OemToAnsi(STR0017) } )
        lContinua := .F.
    EndIf

    If lContinua
        DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
        DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11

        DEFINE MSDIALOG oDlg FROM  094,001 TO 400,600 TITLE OemToAnsi( STR0018 ) PIXEL Style 128 //"Atenção!"

        @ 010,015	GROUP oGroup TO 120,285 LABEL OemToAnsi( STR0019)  OF oDlg PIXEL //"Ajuste de Recibo"
        oGroup:oFont:=oFont

        @ 030 , 030 SAY OemToAnsi(STR0020)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"Essa alteração deve ser realizada com extremo cuidado, pois impacta diretamente no confronto "
        @ 040 , 030 SAY OemToAnsi(STR0021)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"das informações entre o Middleware e a base de dados do Governo."
        @ 050 , 030 SAY OemToAnsi(STR0022)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"O recibo de transmissão correto pode ser consultado junto ao RET e é imprescindível que esta"
        @ 060 , 030 SAY OemToAnsi(STR0023)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"consulta seja realizada antes de qualquer alteração."
        @ 070 , 030 SAY OemToAnsi(STR0024)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"Uma vez preenchido, este recibo de transmissão não poderá ser substituído. "
        @ 080 , 030 SAY OemToAnsi(STR0025)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"Caso queira prosseguir, preencha o número do recibo e clique em 'Ok'."

        @ 100 , 030 SAY OemToAnsi(STR0026)  SIZE 150,17 OF oDlg PIXEL FONT oFont //"Informe o número do recibo: "
        @ 100 , 150 MSGET cRecibo 		    SIZE 126,07 OF oDlg PIXEL FONT oFont1 WHEN .T. PICTURE "@!"

        @ 130, 210 BUTTON oBtFechar PROMPT OemToAnsi(STR0027) SIZE 037, 012 OF oDlg PIXEL   //"Fechar"
        @ 130, 250 BUTTON oBtOk PROMPT OemToAnsi(STR0028) SIZE 037, 012 OF oDlg PIXEL       //"Ok"

        oBtFechar:bLClicked := {|| oDlg:End() }
        oBtOk:bLClicked := {|| Iif( fGrvRec(cRecibo), oDlg:End(), Nil) }
        oDlg:lEscClose     	:= .F.

        ACTIVATE DIALOG oDlg CENTERED
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrvRec
Grava o número do Recibo
@author lidio.oliveira
@since 02/05/2024
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Static Function fGrvRec(cRecibo)

    Local lRet := .T.

    Default cRecibo := ""

    If Empty(cRecibo)
        //"Recibo Não Preenchido!"
        //"O número do recibo de transmissão não foi preenchido."
        //"Preencha o campo destinado ao número recibo e tente novamente."
        Help( " ", 1, OemToAnsi(STR0018),, OemToAnsi(STR0030), 2 , 0 , , , , , , { OemToAnsi(STR0031) } )
        lRet := .F.
    EndIf

    If lRet
        Begin Transaction
            Reclock( "RJE", .F.)
                RJE->RJE_RECIB  := Alltrim(cRecibo)
                RJE->RJE_STATUS := "4"
                MsgInfo(STR0029) //"Recibo atualizado e status atualizado para 4 - Transmitido com sucesso."
            MsUnlock()
        End Transaction
    EndIf

Return lRet
