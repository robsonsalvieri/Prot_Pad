#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "Parmtype.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "LOJA1178.CH"

/*/{Protheus.doc} LOJA1178
    Painel de Agendamento de Carga Incremental
    @type  Function
    @author caio.okamoto
    @since 26/10/2023
    @version 12
    /*/
Function LOJA1178()

Local oBrowse
Local lCompMIO := LJGetComp("MIO") == "CCC"

If lCompMIO
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('MIO')
    oBrowse:SetDescription(STR0001)
    oBrowse:Activate()
Else
    Help( ,, 'HELP',, STR0019  , 1, 0) //A tabela MIO não pode ser do tipo Exclusivo. Favor rever o Compartilhamento! 
Endif   

Return NIL

/*/{Protheus.doc} MenuDef
    Menu Opções
    @type  Function
    @author caio.okamoto
    @since 26/10/2023
    @version 12
    /*/
Static Function MenuDef()

Local aRotina 	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.LOJA1178' OPERATION MODEL_OPERATION_VIEW    ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.LOJA1178' OPERATION MODEL_OPERATION_INSERT  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.LOJA1178' OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.LOJA1178' OPERATION MODEL_OPERATION_DELETE  ACCESS 0 //"Excluir"

Return aRotina


/*/{Protheus.doc} ViewDef
    Modelo de Visualização
    @type  Function
    @author caio.okamoto
    @since 26/10/2023
    @version 12
    /*/
Static Function ViewDef()

Local oModel   := FWLoadModel( 'LOJA1178' )  
Local oStruMIO := FWFormStruct( 2, 'MIO' )
Local oView    := FWFormView():New()	

oStruMIO:AddGroup( 'GRUPO01', STR0016   , ''    ,   2 )
oStruMIO:AddGroup( 'GRUPO02', STR0017   , ''    ,   2 ) 
oStruMIO:AddGroup( 'GRUPO03', STR0018   , ''    ,   2 )

oStruMIO:SetProperty( 'MIO_SEQ'     ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_DESCRI'  ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_GRPCAR'  ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_DGRPC'   ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_ATIVO'   ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_RECORR'  ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )
oStruMIO:SetProperty( 'MIO_PERIOD'  ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO01' )

oStruMIO:SetProperty( 'MIO_SEG' ,   MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_TER' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_QUA' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_QUI' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_SEX' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_SAB' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )
oStruMIO:SetProperty( 'MIO_DOM' ,	MVC_VIEW_GROUP_NUMBER   ,  'GRUPO02' )

oStruMIO:SetProperty( 'MIO_HRINI'   ,  MVC_VIEW_GROUP_NUMBER    ,  'GRUPO03' )
oStruMIO:SetProperty( 'MIO_HRFIM'   ,  MVC_VIEW_GROUP_NUMBER    ,  'GRUPO03' )

oStruMIO:SetProperty( 'MIO_HRFIM'   ,   MVC_VIEW_ORDEM  ,  '17' )
oStruMIO:SetProperty( 'MIO_ATIVO'   ,   MVC_VIEW_ORDEM  ,  '06' )

oView:SetModel( oModel )
oView:AddField( 'VIEW_MIO', oStruMIO, 'MIOMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MIO', 'TELA' )

Return oView       


/*/{Protheus.doc} ModelDef
    Modelo de Dados
    @type  Function
    @author caio.okamoto
    @since 26/10/2023
    @version 12
    /*/
Static Function ModelDef()  

Local oStruMIO 	:= FWFormStruct( 1, 'MIO')
Local oModel	:= MPFormModel ():New('LOJA1178_M',,{ |oModel| LA1178POST( oModel )},/*{  |oModel| LA730CON(oModel)}*/)	// Modelo de Dados

oModel:AddFields( 'MIOMASTER',   , oStruMIO)
oModel:SetPrimaryKey( { "MIO_FILIAL","MIO_SEQ" } )
oModel:SetDescription( STR0002)					
oModel:GetModel( 'MIOMASTER' ):SetDescription( STR0002)

Return oModel


/*/{Protheus.doc} VldGrpCar
    Rotina chamada pelo valid do campo MIO_GRPCAR para verificar que o grupo de tabelas selecionado já faz parte de outro agendamento
    @type  Function
    @author caio.okamoto
    @since 26/10/2023
    @version 12
    @return lRet, lógico, caso já exista agendamento retorno .F.
    /*/
Function VldGrpCar()

Local aAreaMIO 	    := GetArea("MIO")
Local aAreaMBU 	    := GetArea("MBU")
Local lRet          := .T. 

dbSelectArea("MIO")
MIO->(dbSetOrder(2))	//MIO_FILIAL+MIO_GRPCAR

dbSelectArea("MBU")
MBU->(dbSetOrder(1))	//MBU_FILIAL+MBU_CODIGO

If MIO->(dbSeek( xFilial("MIO") + M->MIO_GRPCAR ))
    Help( ,, 'HELP',, STR0007 + MIO->MIO_GRPCAR + STR0008 + MIO->MIO_SEQ  +"-"+ MIO->MIO_DESCRI  , 1, 0) //O Grupo de Tabela  está sendo utilizado no Agendamento 
    lRet := .F. 
ElseIF !MBU->(dbSeek( xFilial("MBU") + M->MIO_GRPCAR ))
    Help( ,, 'HELP',, STR0009  , 1, 0) //Grupo de Tabela inválido ou inexistente!
    lRet := .F.
Endif  

RestArea( aAreaMIO)
RestArea( aAreaMBU)

Return lRet


/*/{Protheus.doc} LA1178POST
    Rotina para validação no momento da confirmação da inclusão
    @type  Function
    @author user
    @since 26/10/2023
    @version version
    @param oModel, object, model da tela
    @return lRet, lógico, se passar na validação retorna .T.
    /*/
Static Function LA1178POST(oModel)

Local nOperation	:= oModel:GetOperation()  
Local nRecorr       := oModel:GetValue( 'MIOMASTER', 'MIO_RECORR')
Local cPeriodo      := oModel:GetValue( 'MIOMASTER', 'MIO_PERIOD')
Local lRet   	    := .T.

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
    If Empty(nRecorr) 
        Help( ,, 'HELP',, STR0010  , 1, 0) //O Campo Recorrência deve ser maior que 0!
        lRet := .F. 
    Elseif  cPeriodo =='1' .AND. nRecorr > 24                                                                                                                                                                                                                                                                                                                                                                                                                                          
        Help( ,, 'HELP',, STR0011  , 1, 0) //Para o Período em hora(s) o campo Recorrência deve ser menor que 24! 
        lRet := .F. 
    Elseif cPeriodo =='2' .AND. nRecorr > 60                                                                                                                                                                                                                                                                                                                                                                                                                                  
        Help( ,, 'HELP',, STR0012  , 1, 0) //Para o período em Minuto(s), o campo Recorrência deve ser menor que 60 minutos! 
        lRet := .F. 
    Endif   
Endif 

Return lRet 


/*/{Protheus.doc} LJGetComp
    Verifica o compartilhamento da tabela
    @type  Function
    @author user
    @since 06/11/2023
    @version version
    @param cAlias, caractere, alias da tabela
    @return cRet, caractére, retorna os modos de compatilhamento
    /*/
Function LJGetComp(cAlias)
Local cRet      := ""    
Local aComp     := {} 
Local lQuery    := .F.

Default cAlias := ""

if !Empty(cAlias)
	lQuery := .T.
	aComp := FwSX2Util():GetSX2Data(cAlias, {"X2_MODOEMP", "X2_MODOUN", "X2_MODO"}, lQuery)
    cRet := aComp[1][2] + aComp[2][2] + aComp[3][2]
Endif 

Return cRet  
