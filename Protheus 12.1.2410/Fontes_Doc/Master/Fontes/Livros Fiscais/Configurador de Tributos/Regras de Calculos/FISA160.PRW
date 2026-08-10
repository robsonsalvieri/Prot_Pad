#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160.ch" 
#Include "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA160 SOURCE FISA160

Static lCIN       := AliasIndic("CIN") .And. FindFunction("xFisFormul") .and. ;
        F2B->(FieldPos("F2B_ALTERA")) > 0 .and. ;
        F2B->(FieldPos("F2B_DTALT")) > 0 .and. ;
        F2B->(FieldPos("F2B_HRALT")) > 0

Static lRdBAux    := F2B->(FieldPos("F2B_RDBASE")) > 0

Static lF2BRND    := F2B->(FieldPos("F2B_RND")) > 0

Static lF2Altera  := F2B->(FieldPos("F2B_ALTERA")) > 0

Static lOriTrb    := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0

Static lNewValMin := F2B->(FieldPos("F2B_ACMIN")) > 0 .And. F2B->(FieldPos("F2B_ACMAX")) > 0 .and. Len(FWSX3Util():GetFieldStruct("F2B_TPREGR")) > 0 .and. ;
            Len(FWSX3Util():GetFieldStruct("F2B_TBCONF")) > 0 .and. ;
            Len(FWSX3Util():GetFieldStruct("F2B_CONREG")) > 0


//Verifica se possui funcionalidades de formula
STATIC lF2BStatus := lCIN .and. F2B->(FieldPos("F2B_STATUS")) > 0
STATIC aRegTrib as array // array com as regras tributárias a serem verificadas
STATIC jChekedOper as json
STATIC cOpt := ""
Static cCampos := getF2B()

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160()

Esta rotina tem objetivo de realizar o cadastro das regras de cálculo dos tributos, 
considerando os perfis de produto, operação, origem/destino e participante,
bem como as regras de composição da base de cálculo, alíquota e regras financeiras.

Esta rotina estará disponível somente na versão 12.

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA160()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic('F2B')
    dbSelectArea("F2B")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2B")    
    oBrowse:SetDescription(STR0001) // Cadastro de regras de cálculo
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FISA160' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FISA160' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.FISA160' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA160' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FISA160' OPERATION 9 ACCESS 0 //'Copiar'

//Somente adicionará  botão se o campo com informação de alterações existir no ambiente
If F2B->(FieldPos("F2B_ALTERA")) > 0
    ADD OPTION aRotina TITLE STR0014 ACTION 'FSA160Hist'      OPERATION 4 ACCESS 0 //"Histórico de Alterações"
EndIF

if lF2BStatus
    ADD OPTION aRotina TITLE "Aprovação de regras" ACTION 'FSA160Apro'      OPERATION 4 ACCESS 0 //"Aprovação em cadeia"
endif

ADD OPTION aRotina TITLE "Carga Regras de Cálculo CBS/IBS" ACTION 'FISA160N("'+cFilant+'")'      OPERATION 4 ACCESS 0 //"Carga Regras de Cálculo CBS/IBS"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da rotina de cadastro de regras de cálculo

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel     := Nil
Local oCabecalho := Nil
Local oFORMULCAL := Nil
Local oFORMULISE := Nil
Local oFORMULOUT := Nil

//Cria a estrutura de dados utilizada no modelo
oCabecalho := FWFormStruct(1, "F2B" )
//Estrutura correspondete a formula
If lCIN
    oFORMULCAL     := FWFormStruct(1,"CIN")
    oFORMULISE     := FWFormStruct(1,"CIN")
    oFORMULOUT     := FWFormStruct(1,"CIN")
Endif

//Instanciando o modelo
If lCIN
    oModel	:=	MPFormModel():New('FISA160',{|oModel|AtualizForm(oModel)},{|oModel|VALIDACAO(oModel) },{|oModel|FSA160Grava(oModel)})
Else
    oModel	:=	MPFormModel():New('FISA160',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })
Endif

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160",,oCabecalho)

//Verifico se tabela CIN existe
If lCIN
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULCAL","FISA160",oFORMULCAL)
    oModel:AddFields("FORMULCAL_ISENTO","FISA160",oFORMULISE)    
    oModel:AddFields("FORMULCAL_OUTROS","FISA160",oFORMULOUT)    
EndIF

//Não permite alterar a sigla da regra
oCabecalho:SetProperty('F2B_REGRA' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })


//Validação para não permitir informar um código da regra que já exista no sistema (legado)
oCabecalho:SetProperty('F2B_REGRA' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})

If lCIN
    //Habilitar o campo apenas se o F2B_RBASES estiver preenchido
    oCabecalho:SetProperty('F2B_MAXMIN' , MODEL_FIELD_WHEN, {|| !Empty(oModel:GetValue('FISA160',"F2B_RBASES")) } )

    If lRdBAux
        oCabecalho:SetProperty('F2B_RDBASE' , MODEL_FIELD_WHEN, {|| !Empty(oModel:GetValue('FISA160',"F2B_RBASES")) } )
    EndIf
  
    //Tributado
    oFORMULCAL:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULCAL:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") <> "ZZ" .And. FSA160HCon(oModel, "FORMULCAL", "CIN_TRIB")})
    oFORMULCAL:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") })
    oFORMULCAL:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") == "ZZ" })
    oFORMULCAL:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") $ "05/Z1" } )

    If lOriTrb
        oFORMULCAL:SetProperty('CIN_ORITRB' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") $ "05/Z1" } )
        oFORMULCAL:SetProperty('CIN_FILTRO' , MODEL_FIELD_VALID ,{||  xForGVld(oModel,"CIN_FILTRO","FORMULCAL")} )
    EndIf

    //Isento
    oFORMULISE:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULISE:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") <> "ZZ" .And. FSA160HCon(oModel, "FORMULCAL_ISENTO", "CIN_TRIB")})    
    oFORMULISE:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") })
    oFORMULISE:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") == "ZZ" })
    oFORMULISE:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") $ "05/Z1" } )

    If lOriTrb
        oFORMULISE:SetProperty('CIN_ORITRB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") $ "05/Z1" } )
        oFORMULISE:SetProperty('CIN_FILTRO' , MODEL_FIELD_VALID ,{||  xForGVld(oModel,"CIN_FILTRO","FORMULCAL_ISENTO")} )
    EndIf

    //Outros
    oFORMULOUT:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULOUT:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") <> "ZZ" .And. FSA160HCon(oModel, "FORMULCAL_OUTROS", "CIN_TRIB")})    
    oFORMULOUT:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") })
    oFORMULOUT:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") == "ZZ" })
    oFORMULOUT:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") $ "05/Z1" } )    
    
    If lOriTrb
        oFORMULOUT:SetProperty('CIN_ORITRB' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") $ "05/Z1" } )
        oFORMULOUT:SetProperty('CIN_FILTRO' , MODEL_FIELD_VALID ,{||  xForGVld(oModel,"CIN_FILTRO","FORMULCAL_OUTROS")} )
    EndIf

    oCabecalho:SetProperty('F2B_RBASE' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RBASE"))})
    oCabecalho:SetProperty('F2B_RBASES' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RBASES"))})
    oCabecalho:SetProperty('F2B_RALIQ' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RALIQ"))})
    oCabecalho:SetProperty('F2B_TRBMAJ' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_TRBMAJ"))})
    oCabecalho:SetProperty('F2B_DEDDEP' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_DEDDEP"))})
    oCabecalho:SetProperty('F2B_DEDPRO' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_DEDPRO"))})
    oCabecalho:SetProperty('F2B_MAXMIN' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_MAXMIN"))})
    oCabecalho:SetProperty('F2B_CODESC' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_CODESC"))})

    If lNewValMin

        oCabecalho:SetProperty('F2B_TBCONF'  , MODEL_FIELD_WHEN, {|| AllTrim(oModel:GetValue('FISA160',"F2B_TPREGR")) == "02"  })
        oCabecalho:SetProperty('F2B_CONREG'  , MODEL_FIELD_WHEN, {|| AllTrim(oModel:GetValue('FISA160',"F2B_TPREGR")) $ "01|03" .OR. (AllTrim(oModel:GetValue('FISA160',"F2B_TPREGR")) == "02" .And. !Empty(oModel:GetValue('FISA160',"F2B_TBCONF"))) })
        oCabecalho:SetProperty('F2B_ACMAX'   , MODEL_FIELD_WHEN, {|| !Empty(AllTrim(oModel:GetValue('FISA160',"F2B_VLRMAX"))) .Or. !Empty(AllTrim(oModel:GetValue('FISA160',"F2B_OPRMAX")) )})
        oCabecalho:SetProperty('F2B_ACMIN'   , MODEL_FIELD_WHEN, {|| !Empty(AllTrim(oModel:GetValue('FISA160',"F2B_VLRMIN"))) .Or. !Empty(AllTrim(oModel:GetValue('FISA160',"F2B_OPRMIN")) )})
        oCabecalho:SetProperty('F2B_TPREGR'  , MODEL_FIELD_INIT, {||" "} )
        oCabecalho:SetProperty('F2B_CONREG'  , MODEL_FIELD_INIT, {||" "} )


    EndIf

    //Não permite alterar os campos de Valor minimo e Maximo a sigla da regra
    oCabecalho:SetProperty('F2B_VLRMIN' , MODEL_FIELD_WHEN, {||  AllTrim(oModel:GetValue('FISA160',"F2B_OPRMIN")) == 'O:VAL_MANUAL' })
    oCabecalho:SetProperty('F2B_VLRMAX' , MODEL_FIELD_WHEN, {||  AllTrim(oModel:GetValue('FISA160',"F2B_OPRMAX")) == 'O:VAL_MANUAL' })
    


    If lF2BStatus
        oCabecalho:SetProperty('F2B_STATUS', MODEL_FIELD_WHEN , { || F2BEditStatus(oModel)})
    EndIf
   
    //Cria relacionamento entre a tabela F2B e CIN.
    oModel:SetRelation( 'FORMULCAL', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'8 '"}}, CIN->( IndexKey(3)))
    oModel:SetRelation( 'FORMULCAL_ISENTO', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'11'"}}, CIN->( IndexKey(3)))
    oModel:SetRelation( 'FORMULCAL_OUTROS', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'12'"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F2B_FILIAL","F2B_ID","F2B_REGRA","DTOS(F2B_VIGINI)","DTOS(F2B_VIGFIM)"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel      := FWLoadModel( "FISA160" )
//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho  := nil
Local oVirtLim    := nil
Local oRealLim    := nil
Local oView       := Nil
Local cVersao     := GetVersao(.F.)
Local cCmpCIN     := Iif(lOriTrb,"CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB/CIN_ORITRB","CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB")
Local cVirtLimite := ""
Local cRealLimite := ""
//Somente adiciona na view da fórmula o campo CIN_FORMUL
Local oFormula    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil )
Local oFormulaI   := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil )
Local oFormulaO   := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil )
Local oRegra      := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ cCmpCIN}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL
Local oRegraI     := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ cCmpCIN}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL
Local oRegraO     := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ cCmpCIN}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
If lNewValMin
    cVirtLimite := "F2B_TPREGR/F2B_TBCONF/F2B_CONREG/"
    cRealLimite := "F2B_OPRMIN/F2B_VLRMIN/F2B_OPRMAX/F2B_VLRMAX/F2B_ACMAX/F2B_ACMIN"

    oVirtLim    := FWFormStruct(2, "F2B", {|x| AllTrim( x ) $ cVirtLimite })
    oRealLim    := FWFormStruct(2, "F2B", {|x| AllTrim( x ) $ cRealLimite })

    oView:AddField( 'VIEW_LIMITE' , oVirtLim, 'FISA160') 
    oView:AddField( 'VIEW_LIMITE_CAMPO' , oRealLim, 'FISA160')//campo para dividir a aba das regras de limite    
Endif

oCabecalho := FWFormStruct(2, "F2B", {|x| !(AllTrim( x ) $ cVirtLimite+cRealLimite) })
oView:AddField( 'VIEW_ABA' , oCabecalho , 'FISA160' )

//Retiro o ID da view
oCabecalho:RemoveField('F2B_ID')

//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_ABA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Cria os grupos
oCabecalho:AddGroup( 'GRUPO_DEF'          , STR0005 , '' , 2 )    //"Definição da Regra"
oCabecalho:AddGroup( 'GRUPO_REGRAS'       , "Regras de Cálculo" , '' , 2 )    //"Definição das Regras"
If !lNewValMin
    oCabecalho:AddGroup( 'GRUPO_REGRAS_LIMITE', "Regras de Limitações do Tributo" , '' , 2 )    //"Definição dos Perfis"
Endif
oCabecalho:AddGroup( 'GRUPO_ESCRITURACAO' , "Regras de Escrituração" , '' , 2 )    //"Definição dos Perfis"
oCabecalho:AddGroup( 'GRUPO_REGRAS_COMPL' , "Regras Complementares" , '' , 2 )    //"Definição das Regras"
oCabecalho:AddGroup( 'GRUPO_PERFIS'       , STR0007 , '' , 2 )    //"Definição dos Perfis"

//Campos que fazem parte do grupo do tributo
oCabecalho:SetProperty( 'F2B_REGRA'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_DESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_VIGINI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_VIGFIM'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_TRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_DTRIB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )

If lCIN .and. lF2BStatus
    oCabecalho:SetProperty( 'F2B_STATUS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
EndIf

//Campos que fazem parte do grupo de regras do tributo
oCabecalho:SetProperty( 'F2B_RBASE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DBASE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_RALIQ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DALIQ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_RFIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DFIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )


If lCIN
    //Adiciona os campos no grupo
    oCabecalho:SetProperty( 'F2B_RBASES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DBASES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_TRBMAJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETMAJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DEDDEP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETDEP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_RGGUIA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DRGUIA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DEDPRO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETPRO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_MAXMIN' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )

    If lRdBAux
        oCabecalho:SetProperty( 'F2B_RDBASE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    EndIf

    if lNewValMin       

        oVirtLim:SetProperty( 'F2B_CONREG' , MVC_VIEW_INSERTLINE, .T. )
        oRealLim:SetProperty( 'F2B_ACMIN' , MVC_VIEW_INSERTLINE, .T. )

        oRealLim:SetProperty( 'F2B_OPRMIN', MVC_VIEW_LOOKUP, "" )
        oRealLim:SetProperty( 'F2B_OPRMAX', MVC_VIEW_LOOKUP, "" )        

    Else
        // Campos que fazem parte da regra de limitação do tributo
        oCabecalho:SetProperty( 'F2B_OPRMIN', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
        oCabecalho:SetProperty( 'F2B_VLRMIN', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
        oCabecalho:SetProperty( 'F2B_OPRMAX', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
        oCabecalho:SetProperty( 'F2B_VLRMAX', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
    Endif
   
EndIF

oCabecalho:SetProperty("F2B_RBASE" , MVC_VIEW_ORDEM  , "01")
oCabecalho:SetProperty("F2B_DBASE" , MVC_VIEW_ORDEM  , "02")
oCabecalho:SetProperty("F2B_RALIQ" , MVC_VIEW_ORDEM  , "03")
oCabecalho:SetProperty("F2B_DALIQ" , MVC_VIEW_ORDEM  , "04")

If lCIN
    oCabecalho:SetProperty("F2B_TRBMAJ" , MVC_VIEW_ORDEM , "05")
    oCabecalho:SetProperty("F2B_DETMAJ" , MVC_VIEW_ORDEM , "06")
    oCabecalho:SetProperty("F2B_DEDDEP" , MVC_VIEW_ORDEM , "07")
    oCabecalho:SetProperty("F2B_DETDEP" , MVC_VIEW_ORDEM , "08")
    oCabecalho:SetProperty("F2B_DEDPRO" , MVC_VIEW_ORDEM , "09")
    oCabecalho:SetProperty("F2B_DETPRO" , MVC_VIEW_ORDEM , "10")
    oCabecalho:SetProperty("F2B_RGGUIA" , MVC_VIEW_ORDEM , "11")
    oCabecalho:SetProperty("F2B_DRGUIA" , MVC_VIEW_ORDEM , "12")
    oCabecalho:SetProperty("F2B_RBASES" , MVC_VIEW_ORDEM , "13")
    oCabecalho:SetProperty("F2B_DBASES" , MVC_VIEW_ORDEM , "14")
    oCabecalho:SetProperty("F2B_MAXMIN" , MVC_VIEW_ORDEM , "15")

    If lRdBAux
        oCabecalho:SetProperty("F2B_RDBASE" , MVC_VIEW_ORDEM , "16")
    EndIf

EndIF

oCabecalho:SetProperty("F2B_RFIN" , MVC_VIEW_ORDEM   , "16")
oCabecalho:SetProperty("F2B_DFIN" , MVC_VIEW_ORDEM   , "17")
oCabecalho:SetProperty("F2B_RAPUR" , MVC_VIEW_ORDEM  , "18")
oCabecalho:SetProperty("F2B_DAPUR" , MVC_VIEW_ORDEM  , "19")

// tratamento para disponibilizar os campos referente a regra de custo do modulo de estoque/custos
If HasCustEst()
    ESTViewDef(@oCabecalho, {"20","21"}, 'GRUPO_REGRAS') // declaração no fonte FISA160xEST.prw
EndIf

If lF2BRND
    oCabecalho:SetProperty("F2B_RND" , MVC_VIEW_ORDEM    , "45")
EndIF

oCabecalho:SetProperty("F2B_PEROD" , MVC_VIEW_ORDEM  , "23")
oCabecalho:SetProperty("F2B_DOD" , MVC_VIEW_ORDEM    , "24")
oCabecalho:SetProperty("F2B_PERFPA" , MVC_VIEW_ORDEM , "25")
oCabecalho:SetProperty("F2B_DPA" , MVC_VIEW_ORDEM    , "26")
oCabecalho:SetProperty("F2B_PERFOP" , MVC_VIEW_ORDEM , "27")
oCabecalho:SetProperty("F2B_DOP" , MVC_VIEW_ORDEM    , "28")
oCabecalho:SetProperty("F2B_PERFPR" , MVC_VIEW_ORDEM , "29")
oCabecalho:SetProperty("F2B_DPR" , MVC_VIEW_ORDEM    , "30")

//Verifica se o campo de controle de arredondamento existe antes de adicionar no grupa das regras complementares
If lF2BRND
    oCabecalho:SetProperty( 'F2B_RND' , MVC_VIEW_GROUP_NUMBER,  'GRUPO_REGRAS' )    
EndIf

//Campos que fazem parte do grupo de perfis
oCabecalho:SetProperty( 'F2B_PEROD'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DOD'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFPA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DPA'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFOP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DOP'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFPR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DPR'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )

//Atribui os campos para grupo de escrituração
If lCIN
    
    oCabecalho:SetProperty( 'F2B_RAPUR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    oCabecalho:SetProperty( 'F2B_DAPUR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    
    oCabecalho:SetProperty( 'F2B_CODESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    oCabecalho:SetProperty( 'F2B_DESESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )

    IF !lNewValMin
        oCabecalho:SetProperty("F2B_OPRMIN" , MVC_VIEW_ORDEM , "40")
        oCabecalho:SetProperty("F2B_VLRMIN" , MVC_VIEW_ORDEM , "41")
        oCabecalho:SetProperty("F2B_OPRMAX" , MVC_VIEW_ORDEM , "42")
        oCabecalho:SetProperty("F2B_VLRMAX" , MVC_VIEW_ORDEM , "43")
    Else
        oVirtLim:SetProperty('F2B_TPREGR' , MVC_VIEW_ORDEM,  "1")
        oVirtLim:SetProperty('F2B_TBCONF' , MVC_VIEW_ORDEM,  "2")
        oVirtLim:SetProperty('F2B_CONREG' , MVC_VIEW_ORDEM,  "3")
        oRealLim:SetProperty("F2B_OPRMIN" , MVC_VIEW_ORDEM , "4")
        oRealLim:SetProperty("F2B_VLRMIN" , MVC_VIEW_ORDEM , "5")
        oRealLim:SetProperty("F2B_ACMIN"  , MVC_VIEW_ORDEM , "6")
        oRealLim:SetProperty("F2B_OPRMAX" , MVC_VIEW_ORDEM , "7")
        oRealLim:SetProperty("F2B_VLRMAX" , MVC_VIEW_ORDEM , "8")
        oRealLim:SetProperty("F2B_ACMAX"  , MVC_VIEW_ORDEM , "9")
    EndIf

EndIf

//Picture do campo código
oCabecalho:SetProperty('F2B_TRIB' , MVC_VIEW_PICT, "@!")

//Retira da view os campos de ID
oCabecalho:RemoveField('F2B_FKKID')

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

// //Se a tabela CIN existir então dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da fórmula
If lCIN
    oCabecalho:SetProperty("F2B_MAXMIN", MVC_VIEW_TITULO, "Valor maior ou menor entre bases")

    If lRdBAux
        oCabecalho:SetProperty("F2B_RDBASE", MVC_VIEW_TITULO, "% total da base auxiliar ao comparar com a base principal")
    EndIf

    oCabecalho:SetProperty("F2B_RBASES", MVC_VIEW_TITULO, "Base de Cálculo Auxiliar")
    oCabecalho:SetProperty("F2B_TRBMAJ", MVC_VIEW_TITULO, "Tributo para Majoração")
    oCabecalho:SetProperty("F2B_DEDDEP", MVC_VIEW_TITULO, "Dedução por Dependentes")
    oCabecalho:SetProperty("F2B_DEDPRO", MVC_VIEW_TITULO, "Tabela Progressiva")
    oCabecalho:SetProperty("F2B_RAPUR", MVC_VIEW_TITULO, "Regra de Apuração")
    oCabecalho:SetProperty("F2B_RFIN", MVC_VIEW_TITULO, "Regra Financeira")
    oCabecalho:SetProperty("F2B_RND", MVC_VIEW_TITULO, "Configuração de Arredondamento")

    oCabecalho:SetProperty("F2B_DETPRO", MVC_VIEW_TITULO, "Descrição")
    oCabecalho:SetProperty("F2B_DETDEP", MVC_VIEW_TITULO, "Descrição")
    oCabecalho:SetProperty("F2B_DETMAJ", MVC_VIEW_TITULO, "Descrição")

    oCabecalho:SetProperty("F2B_CODESC", MVC_VIEW_TITULO, "Escrituração")

    oCabecalho:SetProperty("F2B_PEROD", MVC_VIEW_TITULO, "Origem/Destino")
    oCabecalho:SetProperty("F2B_PERFPA", MVC_VIEW_TITULO, "Participante")
    oCabecalho:SetProperty("F2B_PERFOP", MVC_VIEW_TITULO, "Operação")
    oCabecalho:SetProperty("F2B_PERFPR", MVC_VIEW_TITULO, "Produto")

    If lNewValMin
        oVirtLim:SetProperty( 'F2B_TPREGR', MVC_VIEW_TITULO, 'Tipo de Regra')
        oVirtLim:SetProperty( 'F2B_TBCONF', MVC_VIEW_TITULO, 'Tributo para Consulta')
        oVirtLim:SetProperty( 'F2B_CONREG', MVC_VIEW_TITULO, 'Regra para Limitação')
        oRealLim:SetProperty( 'F2B_OPRMIN', MVC_VIEW_TITULO, 'Operador Limite Mínimo' )
        oRealLim:SetProperty( 'F2B_VLRMIN', MVC_VIEW_TITULO, 'Valor Mínimo Manual' )
        oRealLim:SetProperty( 'F2B_OPRMAX', MVC_VIEW_TITULO, 'Operador Limite Máximo' )
        oRealLim:SetProperty( 'F2B_VLRMAX', MVC_VIEW_TITULO, 'Valor Máximo Manual' )
        oRealLim:SetProperty( 'F2B_ACMAX' , MVC_VIEW_TITULO, 'Ação ao Exceder Limite Máximo' )
        oRealLim:SetProperty( 'F2B_ACMIN' , MVC_VIEW_TITULO, 'Ação ao Exceder Limite Mínimo' )

        oRealLim:SetProperty("F2B_OPRMIN"  , MVC_VIEW_CANCHANGE, .F.)
        oRealLim:SetProperty("F2B_OPRMAX"  , MVC_VIEW_CANCHANGE, .F.)

    Else

        oCabecalho:SetProperty( 'F2B_OPRMIN', MVC_VIEW_TITULO, 'Oper. Min. de limitação do Tributo' )
        oCabecalho:SetProperty( 'F2B_VLRMIN', MVC_VIEW_TITULO, 'Valor Min. Manual' )
        oCabecalho:SetProperty( 'F2B_OPRMAX', MVC_VIEW_TITULO, 'Oper. Max. de limitação do Tributo' )
        oCabecalho:SetProperty( 'F2B_VLRMAX', MVC_VIEW_TITULO, 'Valor Max. Manual' )
        
    EndIf


    // //Cria as views do operando e da fórmula    
     oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULCAL')
     oView:AddField( 'VIEW_FORMULA_ISENTO' , oFormulaI, 'FORMULCAL_ISENTO')
     oView:AddField( 'VIEW_FORMULA_OUTROS' , oFormulaO, 'FORMULCAL_OUTROS')

    // //Cria as view do campo regra
     oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULCAL')
     oView:AddField( 'VIEW_REGRA_ISENTO' , oRegraI, 'FORMULCAL_ISENTO')
     oView:AddField( 'VIEW_REGRA_OUTROS' , oRegraO, 'FORMULCAL_OUTROS')

    // //Ajuste dos títulos dos campos de filtros de fórmula
    oRegra:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegra:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegra:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegra:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB", MVC_VIEW_TITULO, "Referencia do Tributo")
    EndIf

    oRegraI:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegraI:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegraI:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegraI:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    If lOriTrb
        oRegraI:SetProperty("CIN_ORITRB", MVC_VIEW_TITULO, "Referencia do Tributo")
    EndIf

    oRegraO:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegraO:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegraO:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegraO:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    If lOriTrb
        oRegraO:SetProperty("CIN_ORITRB", MVC_VIEW_TITULO, "Referencia do Tributo")
    EndIf

    // //Ordem dos campos da CIN para realizarem filtros nas fórmulas
    oRegra:SetProperty("CIN_FILTRO" ,   MVC_VIEW_ORDEM, "01")
    oRegra:SetProperty("CIN_TRIB"   ,   MVC_VIEW_ORDEM, "02")
    oRegra:SetProperty("CIN_CONSUL" ,   MVC_VIEW_ORDEM, "03")
    oRegra:SetProperty("CIN_VAL"    ,   MVC_VIEW_ORDEM, "04")   

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB" ,   MVC_VIEW_ORDEM, "05")   
    EndIf

    oRegraI:SetProperty("CIN_FILTRO" ,  MVC_VIEW_ORDEM, "01")
    oRegraI:SetProperty("CIN_TRIB"   ,  MVC_VIEW_ORDEM, "02")
    oRegraI:SetProperty("CIN_CONSUL" ,  MVC_VIEW_ORDEM, "03")
    oRegraI:SetProperty("CIN_VAL"    ,  MVC_VIEW_ORDEM, "04")    

    If lOriTrb
        oRegraI:SetProperty("CIN_ORITRB" ,  MVC_VIEW_ORDEM, "05")   
    EndIf

    oRegraO:SetProperty("CIN_FILTRO" ,  MVC_VIEW_ORDEM, "01")
    oRegraO:SetProperty("CIN_TRIB"   ,  MVC_VIEW_ORDEM, "02")
    oRegraO:SetProperty("CIN_CONSUL" ,  MVC_VIEW_ORDEM, "03")
    oRegraO:SetProperty("CIN_VAL"    ,  MVC_VIEW_ORDEM, "04")    

    If lOriTrb
        oRegraO:SetProperty("CIN_ORITRB" ,  MVC_VIEW_ORDEM, "05")
    EndIf    

    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)
    oFormulaI:SetProperty("CIN_FORMUL" , MVC_VIEW_CANCHANGE, .F.)
    oFormulaO:SetProperty("CIN_FORMUL" , MVC_VIEW_CANCHANGE, .F.)

     //Divide a tela em duas pastas
     oView:CreateFolder( 'PASTAS' )
     oView:AddSheet( 'PASTAS', 'ABA01', "Definição da regra de cálculo do tributo"       )
     oView:AddSheet( 'PASTAS', 'ABA02', "Detalhamento da Fórmula de Cálculo" )
    If lNewValMin
        oView:AddSheet( 'PASTAS', 'ABA03', "Regra de Limitação de Tributo" )
    EndIf
    
    //Aba da esquerda cheia
     oView:CreateHorizontalBox( 'ESQUERDA', 100,,, 'PASTAS', 'ABA01' ) //Aqui ficarão todos os componentes de tela que já estavam na onda 1
     oView:CreateHorizontalBox( 'DIREITA', 100,,, 'PASTAS', 'ABA02' ) //Aqui ficarão todos os componentes de tela que já estavam na onda 1
    If lNewValMin
        oView:CreateHorizontalBox( 'ABALIMITE', 30,,, 'PASTAS', 'ABA03' )
        oView:SetOwnerView( 'VIEW_LIMITE'  , 'ABALIMITE')     

        oView:CreateHorizontalBox( 'BOX_INTERMEDIARIOL'      ,80,,.T. , 'PASTAS', 'ABA03') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
        oView:AddOtherObject("BOTOES_LIMITE", {|oPanelBtn| xBtnVlM(oPanelBtn, "FISA160","VIEW_LIMITE", "30", "F2B_TPREGR", "FISA160", "F2B_REGRA", "VIEW_LIMITE")})
        oView:SetOwnerView( 'BOTOES_LIMITE'        , 'BOX_INTERMEDIARIOL') 

        oView:CreateHorizontalBox( 'BOX_INFERIORL'           , 200,,.T., 'PASTAS', 'ABA03') //Campos de limite
        oView:SetOwnerView( 'VIEW_LIMITE_CAMPO', 'BOX_INFERIORL') 

        //Atribuo um título para a segunda aba.
        oView:EnableTitleView('VIEW_LIMITE'  , "Definição da Regra de Limitação do Tributo")
    EndIf
    
     oView:CreateFolder( 'SUBPASTAS','DIREITA' )
     oView:AddSheet( 'SUBPASTAS', 'TRIBUTADO', "Tributado")
     oView:AddSheet( 'SUBPASTAS', 'ISENTO', "Isento" )
     oView:AddSheet( 'SUBPASTAS', 'OUTROS', "Outros" )

    //--------------------------------
    //Botões da fórmula aba tributado
    //--------------------------------
    //Aba da direita dividida em duas partes horizontais
    oView:CreateHorizontalBox( 'TITULO'              , 30,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'BOX_SUPERIOR'        , 200,,.T., 'SUBPASTAS', 'TRIBUTADO') 
    oView:CreateVerticalBox( 'BOX_SUPERIOR_ESQUERDO' , 600,'BOX_SUPERIOR',.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'BOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'BOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficará o campo memo de fórmula
     
    //Painel com os botões
    // //Adiciono componente da fórmula, que está definido por meio da função xFisFormul().    
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULCAL","VIEW_FORMULA", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL", {|oPanel| xFisLabel(oPanel)}) 

    //--------------------------------
    //Botões da fórmula aba Isento
    //--------------------------------
    oView:CreateHorizontalBox( 'ITITULO'              , 30,,.T., 'SUBPASTAS', 'ISENTO') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'IBOX_SUPERIOR'        , 200,,.T., 'SUBPASTAS', 'ISENTO') 
    oView:CreateVerticalBox( 'IBOX_SUPERIOR_ESQUERDO' , 600,'IBOX_SUPERIOR',.T., 'SUBPASTAS', 'ISENTO') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'IBOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'ISENTO') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'IBOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'ISENTO') //Aqui ficará o campo memo de fórmula

    oView:AddOtherObject("BOTOES_ISENTO", {|oPanel| xFisFormul(oPanel, "FORMULCAL_ISENTO","VIEW_FORMULA_ISENTO", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA_ISENTO")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL_ISENTO", {|oPanel| xFisLabel(oPanel)}) 

    //--------------------------------
    //Botões da fórmula aba Outros
    //--------------------------------
    oView:CreateHorizontalBox( 'OTITULO'              , 30,,.T., 'SUBPASTAS', 'OUTROS') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'OBOX_SUPERIOR'        , 200,,.T., 'SUBPASTAS', 'OUTROS') 
    oView:CreateVerticalBox( 'OBOX_SUPERIOR_ESQUERDO' , 600,'OBOX_SUPERIOR',.T., 'SUBPASTAS', 'OUTROS') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'OBOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'OUTROS') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'OBOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'OUTROS') //Aqui ficará o campo memo de fórmula

    oView:AddOtherObject("BOTOES_OUTROS", {|oPanel| xFisFormul(oPanel, "FORMULCAL_OUTROS","VIEW_FORMULA_OUTROS", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA_OUTROS")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL_OUTROS", {|oPanel| xFisLabel(oPanel)}) 

    //Atribuição de Owner
    //Aba da esquerda
    oView:SetOwnerView( 'VIEW_ABA', 'ESQUERDA')   
    
    // //Título
    oView:SetOwnerView( 'LABEL'        , 'TITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA'    , 'BOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES'        , 'BOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA'  , 'BOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL'  , "Composição da Fórmula (Tributado)")     

    //----------
    //Aba Isento
    //----------

    // //Título
    oView:SetOwnerView( 'LABEL_ISENTO'        , 'ITITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA_ISENTO'    , 'IBOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES_ISENTO'        , 'IBOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA_ISENTO'  , 'IBOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA_ISENTO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL_ISENTO'  , "Composição da Fórmula (Isento)")         

    //----------
    //Aba Outros
    //----------

    // //Título
    oView:SetOwnerView( 'LABEL_OUTROS'        , 'OTITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA_OUTROS'    , 'OBOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES_OUTROS'        , 'OBOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA_OUTROS'  , 'OBOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA_OUTROS", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL_OUTROS'  , "Composição da Fórmula (Outros)") 
    
    If lNewValMin        
        oView:SetFieldAction('F2B_TPREGR' , {|oView| xVldTpregr(oView, oModel) })
        oView:SetFieldAction('F2B_TBCONF' , {|oView| xVldTbConf(oView, oModel) })
        oView:SetFieldAction('F2B_CONREG' , {|oView,cIDView| FSA160SFoc(oView, cIDView,"F2B_TPREGR") })
    EndIf

    oView:SetAfterViewActivate({ |oView| FSA160DFil(oView, oModel)})
    oView:SetFieldAction("F2B_STATUS", { |oView| FSA160DFil(oView, oModel)})
    oView:SetFieldAction("CIN_TRIB", { |oView, cIDView| FSA160SFoc(oView, cIDView,"CIN_FILTRO")})
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Erick G Dias
@since 09/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local dDtIni        := oModel:GetValue ('FISA160',"F2B_VIGINI" )
Local dDtFim        := oModel:GetValue ('FISA160',"F2B_VIGFIM" )
Local cRegra        := oModel:GetValue ('FISA160',"F2B_REGRA" ) 
Local nOperation 	:= oModel:GetOperation()
Local cErrForml     := ""

//Verifica se já existe regra com mesmo código e mesma vigência já gravados
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    IF VigIniFIm(cRegra, dDtIni, dDtFim, nOperation == MODEL_OPERATION_UPDATE, oModel:GetValue ('FISA160',"F2B_ID" ))
        lRet:= .F.
        Help( ,, 'Help',, STR0008 , 1, 0 ) //'Regra já cadastrada para a vigência informada'
    EndIF

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL", @cErrForml, .F., "8", "F2B_REGRA", "FISA160"  )       
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

    //Validação nos campos obrigatorios
    If lRet .And. lCIN
        lRet:= FuncObrig(oModel)
    EndIf
    
    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL_ISENTO", @cErrForml, .F., "11", "F2B_REGRA", "FISA160", .T., xFisTpForm("6")+cRegra  )     
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula(Isento): -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL_OUTROS", @cErrForml, .F., "12", "F2B_REGRA", "FISA160", .T., xFisTpForm("6")+cRegra  )
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula(Outros): -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

    // controla a aprovação da regra
    if lF2BStatus .and. oModel:GetValue('FISA160', 'F2B_STATUS') == "2"
        startApproval()
        if VerifCampoAlt(oModel, "FISA160", "F2B_STATUS")
            if isBlind()
                approvalProcessing(oModel)
            else
                Processa({||approvalProcessing(oModel)},,,.F.)
            endif
        else
            approvalProcessing(oModel, .F.)
            if len(getTestTax(aRegTrib)) > 0
                lRet := .F.
                Help(NIL, NIL, "Verificar fórmula", NIL, "Regras de cálculo em produção não podem receber operandos que contenha em sua composição outras regras em fase de teste.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Retirar da fórmula todos os operandos que têm regras em fase de teste em sua composição."})
            endif
        endif
        finishApprovals()
    endif

EndiF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Função que verifica se data inicial e data final já existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vigência
@param     dDtFim      - Date - Data final de vigência
@param     lEdit       - Booleano - indica se é uma operação de edição

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vigência vazio 

@author Erick G Dias
@since 09/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdF2B)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando filial e regra
cSelect := "F2B.F2B_REGRA"
cFrom   += RetSQLName("F2B") + " F2B "
cWhere  += "F2B.F2B_FILIAL = " + ValToSQL(xFilial("F2B")) + " AND "
cWhere  += "F2B.F2B_REGRA = " + ValToSQL(cRegra) + " AND "
IF lCIN
    cWhere  += "(F2B.F2B_ALTERA =  ' ' OR F2B.F2B_ALTERA =  '2' ) AND "
Endif   

cWhere  += "( "

//Verifica se está compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= F2B.F2B_VIGINI  AND F2B.F2B_VIGFIM = ' ' ) OR"
//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= F2B.F2B_VIGINI  AND " + ValToSQL(dDtIni) + " <= F2B.F2B_VIGFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( F2B.F2B_VIGFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F2B.F2B_VIGINI  AND " + ValToSQL(dDtFim) + " <= F2B.F2B_VIGFIM ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F2B.F2B_VIGINI  AND F2B.F2B_VIGFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
    //Como temos consulta padrão da F2B, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a F2B originalmente clicada no browse para edição
    DbSelectArea("F2B")
    F2B->(DbSetOrder(3))
    If F2B->(MsSeek( xFilial("F2B") + cIdF2B ))
        cWhere  += " F2B.R_E_C_N_O_ <> " + ValtoSql(F2B->(recno())) + " AND "    
    EndIF
    F2B->(DbSetOrder(1))
EndIF

cWhere  += "F2B.D_E_L_E_T_ = ' '"		
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

IF !(cAliasQry)->(Eof())
    //já existe regra cadastrada para esta vigência
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Função que valida se o código da regra já não está cadastrado ou
já não é utilizado pelo MATXFIS nos tributos legados.

@author joao.pellegrini
@since 19/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('FISA160', "F2B_REGRA")
Local lRet          := .T.
Local cTrMtxfis3  := "ICM|CPM|IPI|ICR|CMP|DIF|ICC|ISS|IRR|INS|PIS|COF|CSL|PS2|CF2|PS3|CF3|CPB|ZFI|ZFP|ZFC|FCP|FCM|FST|INP|PTG"

// Não permito cadastrar se utilizar um código já utilizado pelo MATXFIS nos tributos legados.
If (Len(Alltrim(cCodigo)) == 3 .AND. AllTrim(cCodigo) $ cTrMtxfis3 )
    lRet := .F.
EndIf

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, "Código não pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, "Código não pode conter espaço.", 1, 0 ) 
    Return .F.
EndIf

If lCIN
    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO", .F.)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS", .F.)

    //Se o código estiver preenchido, então atualizarei o padrão da regra de isento e outros
    If !Empty(cCodigo)
        xForBtnAct(xFisTpForm("6")+cCodigo, "FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO")
        xForBtnAct(xFisTpForm("6")+cCodigo, "FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS")  
    EndIF    
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160Grava
Função responsável por realizar a gravação da regra de base de alíquota
Aqui faremos o tratamento do histórico de alterações

@author Rafael.Soliveira
@since 04/02/2020
@version P12.1.20

/*/
//-------------------------------------------------------------------
Function FSA160Grava(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cFormula     	:= ""
Local cFormulaI    	:= ""
Local cFormulaO    	:= ""
Local cIdRegra      := "" //oModel:GetValue ('FISA160','F2B_ID')
Local cCodigo       := oModel:GetValue ('FISA160',"F2B_REGRA")   // Código Regra
Local cDescri       := oModel:GetValue ('FISA160',"F2B_DESC")    // Descrição   
Local cTrib         := oModel:GetValue ('FISA160',"F2B_TRIB")    // Tributo     
Local dDataIni      := oModel:GetValue ('FISA160',"F2B_VIGINI")  //	Data Início 
Local dDataFin      := oModel:GetValue ('FISA160',"F2B_VIGFIM")  //	Data Final  
Local cBase         := oModel:GetValue ('FISA160',"F2B_RBASE")   // Base Cálculo
Local cAliq         := oModel:GetValue ('FISA160',"F2B_RALIQ")   // Alíquota    
Local cOrigDest     := oModel:GetValue ('FISA160',"F2B_PEROD")   // Perf.Ori/Des
Local cPart         := oModel:GetValue ('FISA160',"F2B_PERFPA")  //	Perf. Part. 
Local cOper         := oModel:GetValue ('FISA160',"F2B_PERFOP")  //	Perf. Oper. 
Local cProd         := oModel:GetValue ('FISA160',"F2B_PERFPR")  //	Perf. Prod. 
Local cFin          := oModel:GetValue ('FISA160',"F2B_RFIN")    // Financeira  
Local cApur         := oModel:GetValue ('FISA160',"F2B_RAPUR")   // Regra Apur. 
Local cAltera       := ""
Local cArred        := oModel:GetValue ('FISA160',"F2B_RND")     // Config Arred  
Local cBaseSec      := oModel:GetValue ('FISA160',"F2B_RBASES")  // Código da base secundária
Local cTribMaj      := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Código do tributo que fará majoração
Local cDedDep       := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Código código da regra de dependentes
Local cDedPro       := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Código código da regra de dedução da tabela progressiva
Local cCodesc       := oModel:GetValue ('FISA160',"F2B_CODESC")  // Código da escrituração   
Local cMaxMin       := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Tratamento para valor maior ou menor entre bases
Local nRdBasAux     := 0  // % da base auxiliar a se levar em consideração no momento da comparação
Local nVlrMin       := oModel:GetValue ('FISA160',"F2B_VLRMIN")  // Valor maximo do Tributo
Local nVlrMax       := oModel:GetValue ('FISA160',"F2B_VLRMAX")  // Valor minimo do Tributo
Local cLimMin       := oModel:GetValue ('FISA160',"F2B_OPRMIN")  // Operador Limite Minimo
Local cLimMax       := oModel:GetValue ('FISA160',"F2B_OPRMAX")  // Operador Limite Maximo
Local cCodRGuia     := oModel:GetValue ('FISA160',"F2B_RGGUIA")  // Regra para geração da guia de recolhimento
Local cOldIdReg     := ""
Local aCampos       := oModel:GetModel("FISA160"):GetStruct():GetFields()
Local nX            := 0
Local cFormulaD     := "0"

Local lUpBase       := .T.
Local lUpAliq       := .T.
Local lUpMaj        := .T.
Local lGrvCIN       := oModel:GetModel("FORMULCAL"):IsFieldUpdated("CIN_FORMUL") .Or. oModel:GetModel("FORMULCAL_ISENTO"):IsFieldUpdated("CIN_FORMUL") .Or. oModel:GetModel("FORMULCAL_OUTROS"):IsFieldUpdated("CIN_FORMUL")

Local lVersiona     := .T.
Local nOp           := 1

Local lChvMD5       := F2B->(FieldPos('F2B_CHVMD5') > 0)
Local cChvMD5       := ""
Local cF2BStatus    := ""

Local oF2BModel := FWFormStruct(1, "F2B", {|x| !AllTrim( x ) $ cCampos })
Local aF2BCamp := oF2BModel:GetFields()

If lRdBAux
    nRdBasAux     := oModel:GetValue ('FISA160',"F2B_RDBASE")  // % da base auxiliar a se levar em consideração no momento da comparação
EndIf

If !lGrvCIN
    // Caso somente o campo de Descrição seja alterado, não serão gerados novos registros das tabela F2B e CIN
    If nOperation == MODEL_OPERATION_UPDATE .And. oModel:GetModel("FISA160"):IsFieldUpdated("F2B_DESC")
        For nX := 1 To Len(aCampos)
            If aCampos[nX,3] <> "F2B_DESC" .And. oModel:GetModel("FISA160"):IsFieldUpdated(aCampos[nX,3])
                lGrvCIN := .T.
                Exit
            EndIf
        Next nX
    Else
        lGrvCIN := .T.
    EndIf
EndIf

If lGrvCIN
    Begin Transaction

        If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE

            //Na edição preciso alterar o flag como alterado para manter o histórico de alterações
            If nOperation == MODEL_OPERATION_UPDATE

                lUpBase       := oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RBASE") .Or. oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RBASES")
                lUpAliq       := oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RALIQ")
                lUpMaj        :=  oModel:GetModel("FISA160"):IsFieldUpdated("F2B_TRBMAJ")

                //verifica se versiona olhando para a F2B. Se versionar faz o fluxo normal
                cOldIdReg := F2B->F2B_ID
                lVersiona := findTaxF2D(cOldIdReg, 'F2D_IDCAD')

                if lVersiona
                    //Chama função para alterar registro atual
                    cOldIdReg := GravaF2B(2)   

                    //Chama função para editar a regra CIN
                    If lUpBase
                        GravaCIN("2", "6",, cOldIdReg) //Atualiza registro referente à base de cálculo
                    EndIf

                    If lUpAliq .OR. lUpMaj
                        GravaCIN("2", "7",, cOldIdReg) //Atualiza registro referente à aliquota
                    EndIf

                    GravaCIN("2", "8",, cOldIdReg) //Atualiza registro referente ao valor
                    GravaCIN("2","11",, cOldIdReg)
                    GravaCIN("2","12",, cOldIdReg)
                    GravaCIN("2","13",, cOldIdReg)
                    //se não versiona não faz o fluxo acima. Criar uma variável para controlar a operação a ser aplicada na GRAVAF2B abaixo
                else
                    nOp := 2
                endIf

            EndIF
			
            If ( lChvMD5 )
                cChvMD5 := GetChvMd5()
            EndIf

            If lF2BStatus
                cF2BStatus := oModel:GetValue ('FISA160',"F2B_STATUS")
            EndIf

            //Agora chamo função para inserir novo registro, seja na operação de inclusão ou edição.
            cIdRegra    := GravaF2B(nOp, cCodigo, cDescri, cTrib, dDataIni, dDataFin, cBase, cAliq, cOrigDest, cPart, cOper, cProd,;
                                    cFin, cApur, cArred, cBaseSec, cTribMaj, cDedDep, cDedPro, cCodesc, cMaxMin, cCodRGuia, nVlrMax, nVlrMin, cLimMin, cLimMax, lVersiona, cChvMD5, nRdBasAux;
                                    ,oModel, cF2BStatus, aF2BCamp)

            //Chama função para gravar nova linha na CIN
            cFormula    := oModel:GetValue ('FORMULCAL',"CIN_FORMUL")
            cFormulaI   := oModel:GetValue ('FORMULCAL_ISENTO',"CIN_FORMUL")
            cFormulaO   := oModel:GetValue ('FORMULCAL_OUTROS',"CIN_FORMUL")

            If RetPercDif(cCodesc) > 0
                cFormulaD   := xFisTpForm("9") + "PERC_DIFERIMENTO"
            EndIf

            If !lUpBase
                cBase := ""
            EndIf

            If !lUpAliq .and. !lUpMaj
                cAliq := ""
            EndIf

            cAltera     := "0"
            //Grava CIN da base

            //Realiza tratamento e gravação da CIN
            PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep, cDedPro, cFormulaI, cFormulaO, cMaxMin, cOldIdReg, cFormulaD, lVersiona, nOp)

        ElseIf nOperation == MODEL_OPERATION_DELETE

            //Chama função para excluir a regra CIN antes de excluir a F2B
            GravaCIN("3","6",, F2B->F2B_ID)
            GravaCIN("3","7",, F2B->F2B_ID)
            GravaCIN("3","8",, F2B->F2B_ID)
            GravaCIN("3","11",, F2B->F2B_ID)
            GravaCIN("3","12",, F2B->F2B_ID)
            GravaCIN("3","13",, F2B->F2B_ID)

            //Faz exclusão do registro
            RecLock("F2B",.F.)
            F2B->(dbDelete())
            MsUnLock()
            //Faz exclusão dos registros de versionamento da regra
            delTRVers(cCodigo)
        EndIF
    End Transaction
Else
    FwFormCommit( oModel )
EndIf

    oF2BModel:Destroy()
    oF2BModel := Nil 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF2B
Função que faz gravação e edição da tabela F2B

@author Rafael S Oliveira
@since 05/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function GravaF2B(nOp, cCodigo, cDescri, cTrib, dDataIni, dDataFin, cBase, cAliq, cOrigDest, cPart,;
                         cOper, cProd, cFin, cApur, cArred, cBaseSec, cTribMaj, cDedDep, cDedPro, cCodesc, cMaxMin, cCodRGuia,nVlrMax, nVlrMin, cLimMin, cLimMax, lVersiona, cChvMD5 , nRdBasAux;
                         , oModel, cF2BStatus, aF2BCamp)
Local cId       := ""
Default lVersiona:= .T.

If nOp == 1 //Incluiu
    RecLock("F2B",.T.)
    F2B->F2B_FILIAL	 := xFilial("F2B")
    F2B->F2B_ID		 := FWUUID("F2B")
    F2B->F2B_ALTERA	 := "2"       // Indica que não foi alterado
EndIf

If nOp == 2  //Alteração
    RecLock("F2B",.F.)
    if lVersiona // altero apenas os campos de versionamento
        F2B->F2B_ALTERA := "1"//Indica que sofreu alterações
        F2B->F2B_DTALT  := Date()
        F2B->F2B_HRALT  := Time()
    endIf
EndIf

if nOp == 1 .OR. (nOp == 2 .and. !lVersiona)
    F2B->F2B_REGRA   := cCodigo   // Código Regra
    F2B->F2B_DESC    := cDescri   // Descrição
    F2B->F2B_TRIB    := cTrib     // Tributo
    F2B->F2B_VIGINI  := dDataIni  // Data Início
    F2B->F2B_VIGFIM  := dDataFin  // Data Final
    F2B->F2B_RBASE   := cBase     // Base Cálculo
    F2B->F2B_RALIQ   := cAliq     // Alíquota
    F2B->F2B_PEROD   := cOrigDest // Perf.Ori/Des
    F2B->F2B_PERFPA  := cPart     // Perf. Part.
    F2B->F2B_PERFOP  := cOper     // Perf. Oper.
    F2B->F2B_PERFPR  := cProd     // Perf. Prod.
    F2B->F2B_RFIN    := cFin      // Financeira
    F2B->F2B_RAPUR   := cApur     // Regra Apur.
    F2B->F2B_RND     := cArred    // Config Arred
    F2B->F2B_RBASES  := cBaseSec  // Regra de Base secundária
    F2B->F2B_TRBMAJ  := cTribMaj  // Tributo que fará majoração
    F2B->F2B_DEDDEP  := cDedDep  // Tributo que fará majoração
    F2B->F2B_DEDPRO  := cDedPro  // Tributo que que terá dedução da tabela progressiva
    F2B->F2B_CODESC  := cCodesc  //Código do cadastro de escrituração
    F2B->F2B_MAXMIN  := cMaxMin   // Tratamento para valor maior ou menor entre bases

    If lRdBAux
        F2B->F2B_RDBASE  := nRdBasAux // % da base auxiliar a se levar em consideração no momento da comparação
    EndIf

    F2B->F2B_RGGUIA  := cCodRGuia // Regra para geração da guia de recolhimento
    F2B->F2B_VLRMAX  := nVlrMax // Valor maximo do Tributo
    F2B->F2B_VLRMIN  := nVlrMin // Valor minimo do tributo
    F2B->F2B_OPRMIN  := cLimMin // tipo limite valor minimo
    F2B->F2B_OPRMAX  := cLimMax // tipo limite valor minimo
	
    If ( !Empty(cChvMD5) )
        F2B->F2B_CHVMD5 := cChvMD5
    EndIf

    If lNewValMin
        F2B_ACMAX := oModel:GetValue ('FISA160',"F2B_ACMAX")
        F2B_ACMIN := oModel:GetValue ('FISA160',"F2B_ACMIN")
    Endif

    // Tratamento para gravar os campos da tabela F2B referente a regra de custo do modulo SIGAEST
    If HasCustEst()
        ESTGravF2B(oModel) // declaração no fonte FISA160xEST.prw
    EndIf

    If !Empty(cF2BStatus)
        F2B->F2B_STATUS := cF2BStatus
    EndIf

    F2BCustom(aF2BCamp, oModel) // Realiza o ponteiro nos campos personalizados da F2B

    aSize(aF2BCamp, 0)
    aF2BCamp := Nil

Endif
MsUnLock()

Return cId := F2B->F2B_ID

//-------------------------------------------------------------------V
/*/{Protheus.doc} F2BCustom

Função que realiza o ponteiro nos campos personalizados da F2B.

@author luiz.foliveira
@since 11/08/2025
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function F2BCustom(aF2BCamp, oModel)

    Local nPos := 0
    Local nX   := 1
    
    For nX := 1 to Len(aF2BCamp)
        If (nPos := FieldPos(aF2BCamp[nX,3])) > 0 
            F2B->(FieldPut(nPos, oModel:GetValue('FISA160', aF2BCamp[nX,3])))
        EndIf
    Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getF2B
Função que retorna os campos padrões da tabela F2B.

@return - cCampos - Campos padrões da F2B.

@author luiz.foliveira
@since 11/08/2025
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Static Function getF2B()

    cCampos := "F2B_FILIAL|F2B_ID|F2B_REGRA|F2B_DESC|F2B_TRIB|F2B_DTRIB|"
    cCampos += "F2B_VIGINI|F2B_VIGFIM|F2B_RBASE|F2B_DBASE|F2B_RALIQ|F2B_DALIQ|"
    cCampos += "F2B_PEROD|F2B_DOD|F2B_PERFPA|F2B_DPA|F2B_PERFOP|F2B_DOP|"
    cCampos += "F2B_PERFPR|F2B_DPR|F2B_RFIN|F2B_DFIN|F2B_RAPUR|F2B_DAPUR|"
    cCampos += "F2B_RND|F2B_RBASES|F2B_DBASES|F2B_ALTERA|F2B_DTALT|F2B_HRALT|"
    cCampos += "F2B_TRBMAJ|F2B_DETMAJ|F2B_DEDDEP|F2B_DETDEP|F2B_DEDPRO|F2B_DETPRO|"
    cCampos += "F2B_CODESC|F2B_DESESC|F2B_MAXMIN|F2B_RGGUIA|F2B_DRGUIA|F2B_VLRMIN|"
    cCampos += "F2B_VLRMAX|F2B_OPRMIN|F2B_OPRMAX|F2B_RDBASE|F2B_ACMIN|F2B_ACMAX|"
    cCampos += "F2B_RCUSTO|F2B_DCUSTO|F2B_STATUS|F2B_TPREGR|F2B_TBCONF|F2B_CONREG|F2B_ORIGEM|F2B_CHVMD5"

Return cCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160Form
Função que atualiza a fórmula da regra de base de cálculo.
Ao alterar algum operando do modo básico da regra, a fórmula 
será atualizada.

@return - .T.

@author Rafael S Oliveira 
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160Form(cCampo,cFormula,cFormulI,cFormulO)

Local oModel        := FWModelActive()
Local cValBase 		:= oModel:GetValue ('FISA160',"F2B_RBASE")
Local cCodRegra		:= oModel:GetValue ('FISA160',"F2B_REGRA")
Local cValBaseS 	:= ""
Local cTrbMaj   	:= ""
Local cDedDep   	:= ""
Local cDedPro   	:= ""
Local cValAliq 		:= oModel:GetValue ('FISA160',"F2B_RALIQ")
Local cPrefixo      := ""
Local oCabecalho	:= oModel:GetModel("FISA160")
Local cEscrit       := ""

Default cCampo      := ""
Default cFormula    := ""
Default cFormulI    := ""
Default cFormulO    := ""

IF !Empty(cFormula)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL", .F., "VIEW_FORMULA", .F.)

    //Abrir parentes 
    xForBtnAct(cFormula, "FORMULCAL", .F., "VIEW_FORMULA")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.


Endif

IF !Empty(cFormulI)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO", .F.)

    //Abrir parentes 
    xForBtnAct(cFormulI, "FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.

Endif

IF !Empty(cFormulO)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS", .F.)

    //Abrir parentes 
    xForBtnAct(cFormulO, "FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.

Endif

If !Empty(cFormula) .Or. !Empty(cFormulI) .Or. !Empty(cFormulO)
    Return .T.
EndIf

If lCIN
    cValBaseS 	:= oModel:GetValue ('FISA160',"F2B_RBASES")
    cTrbMaj     := oModel:GetValue ('FISA160',"F2B_TRBMAJ")
    cDedDep     := oModel:GetValue ('FISA160',"F2B_DEDDEP")
    cDedPro     := oModel:GetValue ('FISA160',"F2B_DEDPRO")
    cMaxMin     := oModel:GetValue ('FISA160','F2B_MAXMIN')
    cEscrit     := oModel:GetValue ('FISA160','F2B_CODESC')
EndIF

//Aqui preciso validar se o código da regra de base e de alíquota existem no cadastro
If !Empty(cCampo)
    
    If cCampo == "F2B_RBASE" .And. !Empty(cValBase)
         //Verifcica cadastro de base
        
        //As bases não podem ser iguais
        If !Empty(cValBaseS) .And. cValBase == cValBaseS
            Return .F.
        EndIf

        DbSelectArea("F27")
        F27->(DbSetOrder(1))
        If !F27->(MsSeek( xFilial("F27") + cValBase + "2"))
            Return .F.
        EndIF        
    ElseIf cCampo == "F2B_RBASES"
        If !Empty(cValBaseS)
            //Verifcica cadastro de base
            //As bases não podem ser iguais
            If !Empty(cValBase) .And. cValBaseS == cValBase
                Return .F.
            EndIf

            DbSelectArea("F27")
            F27->(DbSetOrder(1))
            If !F27->(MsSeek( xFilial("F27") + cValBaseS + "2"))
                Return .F.
            EndIF
        Else
            //Limpa o conteúdo do campo F2B_MAXMIN
            oCabecalho:LoadValue('F2B_MAXMIN', Criavar("F2B_MAXMIN") )
        EndIf

    ElseIf cCampo == "F2B_TRBMAJ" .And. !Empty(cTrbMaj)
        //Verifcica cadastro de base
        //As bases não podem ser iguais
        If !Empty(cCodRegra) .And. cCodRegra == cTrbMaj
            Return .F.
        EndIf       
        
        //seek F2B
        DbSelectArea("F2B")
        F2B->(DbSetOrder(7))
        If !F2B->(MsSeek( xFilial("F2B") + cTrbMaj + "2"))
            Return .F.
        EndIF       
        
    //Validação dependentes
    ElseIf cCampo == "F2B_DEDDEP" .And. !Empty(cDedDep)
        
        DbSelectArea("CIV")
        CIV->(DbSetOrder(4))
        If !CIV->(MsSeek( xFilial("CIV") +cDedDep+"2"))
            Return .F.
        EndIF        

    //Validação tabela progressiva        
    ElseIf cCampo == "F2B_DEDPRO" .And. !Empty(cDedPro)
        
        DbSelectArea("CIQ")
        CIQ->(DbSetOrder(1))
        If !CIQ->(MsSeek( xFilial("CIQ") +cDedPro))
            Return .F.
        EndIF        

    ElseIf cCampo == "F2B_RALIQ" .And. !Empty(cValAliq)
        //Verifcica cadastro de alíquota
        DbSelectArea("F28")
        F28->(DbSetOrder(1))
        If !F28->(MsSeek( xFilial("F28") + cValAliq + "2"))
            Return .F.
        EndIF

     ElseIf cCampo == "F2B_CODESC" .And. !Empty(cEscrit)
        //Verifcica cadastro de Regra Escrituração
        DbSelectArea("CJ2")
        CJ2->(DbSetOrder(1))
        If !CJ2->(MsSeek( xFilial("CJ2") + cEscrit + "2"))
            Return .F.
        EndIF           
    EndIF

EndIf

//Primeiro limpa a fórmula
xForClear("FORMULCAL", .F., "VIEW_FORMULA", .F.)

//Indica que o botão de edição de fórmula ficará habilitado
lclicked := .T.

//Se operador estiver vazio então a fórmula não será montada!
If !Empty(cValBase) .and. !Empty(cValAliq)
    
    //Regra de Diferimento
    If !Empty(cEscrit) .And. RetPercDif(cEscrit) > 0
        xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA") 
    EndIf

    //Abrir parentes
    xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA")

    //Adiciona o operador de origem/início na fórmula
    
    cPrefixo:= xFisTpForm("1") //Base de cálculo
    IF !Empty(cMaxMin) .And. !Empty(cValBases)
        //Se as duas bases estiverem preenchidas, então utilizarei o MAIOR()
        If cMaxMin == "1"
            xForBtnAct( xFisTpForm("10") + "( " + cPrefixo+cValBase + " , " + cPrefixo+cValBases + " )", "FORMULCAL", .F., "VIEW_FORMULA")
        Else
            xForBtnAct( xFisTpForm("14") + "( " + cPrefixo+cValBase + " , " + cPrefixo+cValBases + " )", "FORMULCAL", .F., "VIEW_FORMULA")
        EndIf
    Else        
        //Se somente houver a base de cálculo preenche sem MAIOR
        xForBtnAct(cPrefixo+cValBase, "FORMULCAL", .F., "VIEW_FORMULA")        
    EndIF

    //Adiciona o operador de multiplicação
    xForBtnAct("*", "FORMULCAL", .F., "VIEW_FORMULA")

    If Empty(cTrbMaj)
        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("2") //Alíquota
        xForBtnAct(cPrefixo+cValAliq, "FORMULCAL", .F., "VIEW_FORMULA")
    Else
        xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA")
        
        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("2") //Alíquota
        xForBtnAct(cPrefixo+cValAliq, "FORMULCAL", .F., "VIEW_FORMULA")

        //Adiciona o operador de multiplicação
        xForBtnAct("+", "FORMULCAL", .F., "VIEW_FORMULA")

        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("7") //Alíquota
        xForBtnAct(cPrefixo+cTrbMaj, "FORMULCAL", .F., "VIEW_FORMULA")
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULCAL", .F., "VIEW_FORMULA")

    EndIf
    
    //Fecha o parentes
    xForBtnAct(")", "FORMULCAL", .F., "VIEW_FORMULA")

    //Regra de Diferimento
    If !Empty(cEscrit) .And. RetPercDif(cEscrit) > 0
        xForBtnAct(" * "+xFisTpForm("9") + "PERC_DIFERIMENTO )", "FORMULCAL", .F., "VIEW_FORMULA")
    EndIf

    //Regra de Tabela Progressiva
    If !Empty(cDedPro)
        xForBtnAct(" - ", "FORMULCAL", .F., "VIEW_FORMULA")
        xForBtnAct(xFisTpForm("9") + "DED_TAB_PROGRESSIVA", "FORMULCAL", .F., "VIEW_FORMULA")
    EndIF
EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160HBtn
Esta função indica se o botão que habilita a edição da fórmula deverá estar
ou não habilitado.

Por padrão em um novo cadastro o botão estará habilitado.

@return bool - Retorna verdadeiro quando não informado base e aliquota

@author Rafael S Oliveira
@since 05/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160HBtn(cModelo)

If cModelo == "FORMULCAL"
    Return lclicked
EndIf

If cModelo == "FORMULCAL_ISENTO"
    Return lclickedI
EndIf

If cModelo == "FORMULCAL_OUTROS"
    Return lclickedO
EndIf

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160HFor
Função que indica se o campo de fórmula deverá ou não estar habilitado,
e ter o seu conteúdo alterado.

@return - bool - Retorna verdadeiro se foi informado base e aliquota

@author Rafael S Oliveira
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160HFor(cModelo)

If cModelo == "FORMULCAL"
    Return !lclicked
EndIf

If cModelo == "FORMULCAL_ISENTO"
    Return !lclickedI
EndIf

If cModelo == "FORMULCAL_OUTROS"
    Return !lclickedO
EndIf

Return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160AFor
Função executada quando usuário Limpar a formula
Esta ação limpara tambem campos de base e aliuqota na aba direita

@author Rafael S Oliveira
@since 06/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160AFor(cChamada)
Local oModel    := FWModelActive()
Local oFormul   := oModel:GetModel("FISA160")
Local oView 	:= 	FWViewActive()
Default cChamada:= ""

If Empty(cChamada)
    //Aqui retornarei todos os campos para estado inicial
    oFormul:SetValue('F2B_RBASE', Criavar("F2B_RBASE"))       
    oFormul:SetValue('F2B_RALIQ', Criavar("F2B_RALIQ"))
    If lCIN
        oFormul:SetValue('F2B_RBASES', Criavar("F2B_RBASES"))
        oFormul:SetValue('F2B_MAXMIN', Criavar("F2B_MAXMIN"))
    EndIF
EndIf

//Atualizo a view
oview:Refresh( 'VIEW_ABA')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'BOTOES')

oview:Refresh( 'VIEW_FORMULA_ISENTO')
oview:Refresh( 'VIEW_REGRA_ISENTO')
oview:Refresh( 'BOTOES_ISENTO')

oview:Refresh( 'VIEW_FORMULA_OUTROS')
oview:Refresh( 'VIEW_REGRA_OUTROS')
oview:Refresh( 'BOTOES_OUTROS')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160F2B
Função executada quando usuário entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160F2B()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""
Local cBase     := ""
Local cAliq     := ""
Local cBaseSec  := ""
Local cTribMaj  := ""
Local cDedDep   := ""
Local cDedPro   := ""
Local cMaxMin   := ""
Local cFormulaD := "0"
Local cCodesc   := ""
//Realiza pesquisa pela relação da F2B com CIN
cAlias := PesqCIN("F2B")

DbSelectArea(cAlias)

//Caso não encontre diferenças finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA160
oModel    := FWLoadModel('FISA160')

DbSelectArea("F2B")
F2B->(DbSetOrder(3)) // F2B_FILIAL+F2B_ID

While (!(cAlias)->(Eof()))
    F2B->(DbSetOrder(3)) // F2B_FILIAL+F2B_ID
    If F2B->(MsSeek(xFilial("F2B") + (cAlias)->F2B_ID))

        cAltera   := Iif(F2B->F2B_ALTERA $ ' |2',"0","1")
        cFormulaD := "0"
        
        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA160',"F2B_REGRA")   // Código Regra
        cDescri   := oModel:GetValue ('FISA160',"F2B_DESC")    // Descrição   
        cIdRegra  := oModel:GetValue ('FISA160','F2B_ID')
        cBase     := oModel:GetValue ('FISA160','F2B_RBASE')
        cAliq     := oModel:GetValue ('FISA160','F2B_RALIQ')

        //Função que atualiza a fórmula da regra de cálculo.
        Fsa160Form()

        cFormula    := oModel:GetValue ('FORMULCAL',"CIN_FORMUL")       

        //Grava CIN da base        
        cBaseSec      := oModel:GetValue ('FISA160',"F2B_RBASES")  // Código da base secundária
        cTribMaj      := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Código do tributo que fará majoração
        cDedDep       := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Regra de depdentes
        cDedPro       := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Regra de dedução tabela progressiva
        cMaxMin       := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Tratamento para valor maior ou menor entre bases
        cCodesc       := oModel:GetValue ('FISA160',"F2B_CODESC")  // Código da escrituração   

        If RetPercDif(cCodesc) > 0
            cFormulaD := xFisTpForm("9") + "PERC_DIFERIMENTO"
        EndIf
        
        //Realiza tratamento e gravação da CIN
        PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep, cDedPro, xFisTpForm("6")+cCodigo , xFisTpForm("6")+cCodigo, cMaxMin, , cFormulaD)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F2B->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160Prefix
Função que retorna o prefixo da regra do tributo

@return string com o prefixo da fórmula considerando as regra de base e de
alíqutoa selecionadas

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
/*Function Fsa160Prefix()
Local oModel     := FWModelActive()

//TODO regra de prefixo da fórmula, será muito difícil prever todas variações, pode ter somente pautam somente alíquota, ou os dois.

// //Verifico se a base secundária está preenchida ou não para montar a fórmula da base de cálculo
// If Empty(oModel:GetValue ('FISA160',"F2B_RBASES"))
//     //(B:BASE*A:ALIQ)
//     Return "(" + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASE")) + "*" + xFisTpForm("2") + Alltrim(oModel:GetValue ('FISA160',"F2B_RALIQ")) + ")"
// Else
//     //(MAIOR( B:BASE1 , B:BASE2 ) * A:ALIQ)
//     return "(" + xFisTpForm("10") + "(" + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASE")) + "," + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASES")) + ")*" + xFisTpForm("2") +  Alltrim(oModel:GetValue ('FISA160',"F2B_RALIQ")) + ")"
// EndIF

Return ""
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160ETrb
Função que verifica se os campos de base e alíquota estão prenchidos.

@return - .T. se os campos está preenchidos.

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160ETrb()

Local oModel        := FWModelActive()
Return !Empty(oModel:GetValue ('FISA160',"F2B_RBASE")) .And. !Empty(oModel:GetValue ('FISA160',"F2B_RALIQ"))


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160Hist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160Hist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de alteração, pois o UPDDISTR não altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posições dos arrays
1 - Título
2 - Codeblock para carregra a ~informação
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite alteração
*/
AADD(aColunas,{ STR0018, &("{ || IIf(F2B->F2B_ALTERA == '1','" + STR0019 + "','" + STR0020 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0016, &("{ || F2B->F2B_DTALT }"), "D", "", 1, 1, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0017, &("{ || Alltrim(F2B->F2B_HRALT) }"), "C", "", 1, 1, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "F2B"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="F2B_FILIAL == '" + xFilial("F2B") + "'"
cFiltro	+= " .AND. F2B_REGRA == '" + F2B->F2B_REGRA +  "'"

//Utilizo segundo índice para facilitar a visualização
F2B->(DbSetOrder(6))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("F2B", cFiltro, STR0015 , aColunas) //"Histórico de Alterações da Regra de Cálculo de Tributo"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
F2B->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFormval

Função auxiliar que monta a fórmula do valor do tributo, subtituindo
os dois primeiros operadores por base e alíquota, mantendo o resto da
fórmula

@param cFormTemp  - Fórmula temporária sem os operadores com sufixo _BAS e _ALQ
@param cTributo   - Tributo a qual este operando pertence

@return -cRet Fórmula substituída

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetFormval(cFormTemp, cTributo, cTribMaj, cBaseSec, cDedDep, lTribDif)

Local nX		:= 0
Local aFormTemp	:= {}
Local cRet		:= "(" + xFisTpForm("6") + cTributo + " * " + xFisTpForm("7") + cTributo + ")"
Local lMaj      := .F.
Local lMaior    := .F.
Local nXIni     := 0
Local lCustomOper   := .F.

Default lTribDif:= .F.

//Para facilitar o cálculo irei substituir o primeiro e segundo operandos pelos respectivos códigos de base e aliquota
aFormTemp	:= StrTokArr(alltrim(cFormTemp)," ")

//Caso tenha diferimento é preciso colocar um parenteses, pois será fechado ao longo da fórmula
If lTribDif
    cRet := "(" + cRet
EndIf

If !Empty(cBaseSec)
    //Possui base com operador MAIOR 
    lMaior  := .T.
EndIF

If !Empty(cTribMaj)
    //Possui soma na alíquota para majoração        
    lMaj    := .T.
EndIf

// Se a formula for customizada com um operando responsavel pelo valor, descarto o padrao de Base x Aliquota ...
If Len(aFormTemp) == 1 .and. IsOperVal( aFormTemp )
    cRet := ""
    lCustomOper := .T.
EndIf

If lMaj .AND. lMaior .And. lTribDif
    nXIni   := 15
ElseIf lMaj .AND. lMaior .And. !lTribDif
    nXIni   := 14    
ElseIf (lMaj .Or. lMaior) .And. lTribDif
    nXIni   := 11
ElseIf lMaj .Or. lMaior
    nXIni   := 10
ElseIf lTribDif 
    nXIni   := 7
ElseIf lCustomOper // Se For uma formula customizada, começo a montar a formula NPI a partir da 1 posição ...
    nXIni   := 1
Else
    nXIni   := 6
EndIF

//Somente majorada, montar a fórmula : (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 9 posição
//Somente MAIOR, montar a fórmula : (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 9 posição
//Se houver MAIOR e majorada, montar a fórmula: (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 13 posição

For nX := nXIni  to len(aFormTemp)		
	cRet +=  " "
    cRet += Alltrim(aFormTemp[nX])	
Next nX

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperVal

Função que verifica se a fórmula é customizada com um operando que contem o valor total da formula

@param aFormTemp - Array com a fórmula

@return - .T. se for um operando com valor da formula, .F. caso contrário

@author Douglas Dourado
@since 26/03/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function IsOperVal( aFormTemp )
Local cOperGen := "O:VALOR_INTEGRACAO" // Caso tenha mais operandos que vão retornar o valor total da formula, adicionar nessa variavel "O:VALOR_INTEGRACAO|O:OPER_FUTURO|etc" ...
Return ASCAN( aFormTemp ,{|x| cOperGen $ x }) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} PreGrvCIN

Função que trata a gravação das fórmulas da tabela CIN, tanto na gravação 
da regra quando nas cargas automáticas.

@author Erick Dias
@since 10/07/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep,; 
                          cDedPro, cFormulaI, cFormulaO, cMaxMin, cOldIdReg, cFormulaD, lVersiona, nOp)
Local cTribVal    := ""
Local cFrmTotDif  := ""
Local lDiferido   := .F.


Default cBase     := ""
Default cAliq     := ""
Default cOldIdReg := ""
Default cFormulaD := ""
Default lVersiona := .T.
Default nOp       := 1

nOp := cValToChar(nOp)

//Quando possui escrituração na regra mas não possui diferimento o cFormulaD vem com string 0, por isso é diferente de branco e de 0
lDiferido   := !Empty(cFormulaD)  .And. cFormulaD <> "0"

// Caso a formula não tenha sido alterada, indica que os registros de Base, Aliquota e Valor não sofreram qualquer alteração.
If !Empty(cBase)
    //Grava CIN da base
    If !Empty(cBaseSec) .And. !Empty(cMaxMin)
        //Maior
        If cMaxMin == "1"
            GravaCIN(nOp,"6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("10") + "( " + xFisTpForm("1")  + cBase + " , " + xFisTpForm("1") + cBaseSec + " )" , cAltera,,,lVersiona)
        //Menor
        Else
            GravaCIN(nOp,"6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("14") + "( " + xFisTpForm("1")  + cBase + " , " + xFisTpForm("1") + cBaseSec + " )" , cAltera,,,lVersiona)
        EndIf
    Else
        GravaCIN(nOp,"6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("1") +cBase , cAltera,,,lVersiona)
    EndIF
ElseIf !Empty(cOldIdReg) .and. lVersiona
    GravaCIN("2", "6",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cAliq)
    //Grava CIN da alíquota
    IF Empty(cTribMaj)
        GravaCIN(nOp,"7", cCodigo, cIdRegra, "(Alíquota) | " + cDescri, xFisTpForm("2")+cAliq , cAltera,,,lVersiona)
    Else
        GravaCIN(nOp,"7", cCodigo, cIdRegra, "(Alíquota) | " + cDescri, "( "  + xFisTpForm("2")+cAliq + " + " + xFisTpForm("7") + cTribMaj + ")", cAltera,,,lVersiona)
    EndIF
ElseIf !Empty(cOldIdReg) .and. lVersiona
    GravaCIN("2", "7",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cFormula)
    //Grava CIN do valor
    GravaCIN(nOp,"8", cCodigo, cIdRegra, "(Valor) | "    + cDescri, GetFormval(cFormula, cCodigo, cTribMaj, cBaseSec, cDedDep, lDiferido),cAltera,cFormula,,lVersiona)
ElseIf !Empty(cOldIdReg)
    GravaCIN("2", "8",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cFormulaI)
    //Grava CIN do valor de Isento
    GravaCIN(nOp,"11", cCodigo, cIdRegra, "(Isento) | "    + cDescri, cFormulaI ,cAltera,,,lVersiona)
EndIf

If !Empty(cFormulaO)
    //Grava CIN do valor de Outros
    GravaCIN(nOp,"12", cCodigo, cIdRegra, "(Outros) | "    + cDescri, cFormulaO ,cAltera,,,lVersiona)
EndIf

//Grava CIN do valor Diferido
//Verifico se o tributo contem diferimento maior que zero.
If lDiferido
    cTribVal    := "(" + GetFormval(cFormula, cCodigo, cTribMaj, cBaseSec, cDedDep, lDiferido) + ")"
    cFrmTotDif  := "(" + cTribVal +" / "+ cFormulaD+ ")" + " - " + cTribVal
    GravaCIN(nOp,"13", cCodigo, cIdRegra, "(Diferido) | "    + cDescri, cFrmTotDif, cAltera,,,lVersiona)
Else
    GravaCIN(nOp,"13", cCodigo, cIdRegra, "(Diferido) | "    + cDescri, "0", cAltera,,,lVersiona)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FuncObrig
Função para validar de campos obrigatórios

@author Renato Rezende
@since 14/09/2020
@version P12.1.31
/*/
//-------------------------------------------------------------------
Static Function FuncObrig(oModel)
Local lRet      := .T.
Local cValBaseS := oModel:GetValue ('FISA160',"F2B_RBASES")
Local cMaxMin   := oModel:GetValue ('FISA160','F2B_MAXMIN')

//Campo do maior ou menor preenchido e o campo da base secundária não preenchido
If !Empty(cMaxMin) .And. Empty(cValBaseS)
    lRet:= .F.
    Help( ,, 'Help',, "Campo obrigatório não preenchido: Base de Cálculo Auxiliar (F2B_RBASES)", 1, 0 )

//Campo da base secundária preenchido e o campo de maior ou menor não preenchido
ElseIf !Empty(cValBaseS) .And. Empty(cMaxMin)
    lRet:= .F.
    Help( ,, 'Help',, "Campo obrigatório não preenchido: Valor maior ou menor entre bases (F2B_MAXMIN)", 1, 0 )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160POS
Função auxiliar para tratar o inicializador padrão da descrição do 
do Produto, pois o campo X3_RELACAO é limitado e não cabia 
toda a instrução necessária.

Devido POSICIONE ser na propria tabela sera nescessario retornar a area original

@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------

Function FSA160POS()
Local aArea      := GetArea()
Local cDescr    := ""

If !INCLUI     
    cDescr  := POSICIONE("F2B",7,xFilial("F2B")+F2B->F2B_TRBMAJ+"2","F2B_DESC")
EndIF

//Retorna para registro de Origem da F2B
Restarea(aArea)

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizForm
Função responsavel por atualizar a formula quando realizada copia a regra de calculo


@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------
Static Function AtualizForm(oModel)
Local cBase      := ""
Local cBases     := ""
Local cAliq      := ""
Local cTribmj    := ""
Local cDep       := ""
Local cDeppro    := ""
Local cMaxmin    := ""
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT
    cBase    := oModel:GetValue ('FISA160',"F2B_RBASE")   // Base Cálculo
    cBases   := oModel:GetValue ('FISA160',"F2B_RBASES")  // Base Cálculo secundaria
    cAliq    := oModel:GetValue ('FISA160',"F2B_RALIQ")   // Alíquota    
    cTribmj  := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Trib Majorado
    cDep     := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Dependencia
    cDeppro  := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Dependencia
    cMaxmin  := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Min e Max

    IF !Empty(Alltrim(cBase))
        Fsa160Form("F2B_RBASE")
    Endif
    IF !Empty(Alltrim(cBases))
        Fsa160Form("F2B_RBASES")
    Endif
    IF !Empty(Alltrim(cAliq))
        Fsa160Form("F2B_RALIQ")
    Endif
    IF !Empty(Alltrim(cTribmj))
        Fsa160Form("F2B_TRBMAJ")
    Endif
    IF !Empty(Alltrim(cDep))
        Fsa160Form("F2B_DEDDEP")
    Endif
    IF !Empty(Alltrim(cDeppro))
        Fsa160Form("F2B_DEDPRO")
    Endif
    IF !Empty(Alltrim(cMaxmin))
        Fsa160Form("F2B_MAXMIN")
    Endif 
Endif
    
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPercDif
Função responsavel por retornar o % de diferimento da escrituração

@author Renato Rezende
@since 29/03/2021
@version 12.1.22
/*/
//-------------------------------------------------------------------
Static Function RetPercDif(cEscrit)
Local nRet := 0

//Verifcica cadastro de Regra Escrituração
If !Empty(cEscrit)

    DbSelectArea("CJ2")
    CJ2->(DbSetOrder(1))
    If CJ2->(MsSeek( xFilial("CJ2") + cEscrit + "2"))
        nRet := CJ2->CJ2_PERDIF
    EndIf

EndIf

Return nRet


/*/{Protheus.doc} FSA160OPR
    Fun~c"ao de filtro da consulta padrão CINOPR
    @type  Function
    @author Erich Buttner
    @since 28/04/2021
    @version version
    @param param, param_type, param_descr
    @return Codigo
    @example
    (examples)
    @see (links_or_references)
    /*/

Function FSA160OPR ()
Local oModel := nil
Local cTipo  := ""

IF lNewValMin
    oModel := FWModelActive()
    cTipo  := Alltrim(oModel:GetValue( 'FISA160' , 'F2B_TPREGR' ))

    If cTipo == "03"
        // Se o tipo de regra for 03, apresenta apenas a opção manual        
        cRet := "O:VAL_MANUAL"
    Elseif cTipo == "01"
        // Se o tipo de regra for diferente de 03, apresenta as opções padrão
        cRet := "O:VAL_MERCADORIA|O:VAL_ICMS|O:FRETE|O:DESCONTO|O:SEGURO|O:DESPESAS"
    EndIf
    
Else

    cRet := "CIN_CODIGO == 'O:VAL_MERCADORIA' .OR. CIN_CODIGO == 'O:VAL_ICMS' "
    cRet += " .OR. CIN_CODIGO == 'O:FRETE' .OR. CIN_CODIGO == 'O:DESCONTO' "
    cRet += " .OR. CIN_CODIGO == 'O:SEGURO' .OR. CIN_CODIGO == 'O:DESPESAS' "
    cRet += " .OR. CIN_CODIGO == 'O:VAL_MANUAL'  "

Endif



Return cRet


/*/{Protheus.doc} delTRVers
    Efetua o delete dos registros versionados da F2B e CIN após o registro principal
    da F2B e CIN serem deletados.
    @type  Function
    @author anedino.santos
    @since 05/02/2024
    @version 12.1.2310
    @param cCodReg, character, Codigo da Regra Tributária que foi deletado.
    @return Nil, Nil, sem retorno
    /*/
Function delTRVers(cCodReg)
    Local aArea as array
    Local cidF2B as character
    // Guarda a área de trabalho atual
    aArea := GetArea()
    // Seleciono a área F2B
    dbSelectArea('F2B')
    F2B->(dbSetOrder(7))//F2B_FILIAL, F2B_REGRA, F2B_ALTERA, R_E_C_N_O_, D_E_L_E_T_
    F2B->(dbGoTop())
    // Seleciono a área CIN
    dbSelectArea('CIN')
    CIN->(dbSetOrder(3))//CIN_FILIAL, CIN_IREGRA, CIN_TREGRA, R_E_C_N_O_, D_E_L_E_T_
    CIN->(dbGoTop())
    // Efetuo o delete dos registros versionados conforme o código da regra
    // verifico se há ao menos um registro de versionamento.
    if F2B->(MsSeek(xFilial('F2B') + cCodReg + '1'))
        // percorro a F2B procurando registros para serem deletados
        while !F2B->(EOF()) .and. ;
        (F2B->F2B_FILIAL + F2B->F2B_REGRA + F2B->F2B_ALTERA == xFilial('F2B') + cCodReg + '1')
            cidF2B := F2B->F2B_ID
            RecLock("F2B", .F.)
            F2B->(dbDelete())
            F2B->(MsUnLock())
            // Para um registro na F2B há vários na CIN.
            // Percorro todos os registros da CIN com o ID do tributo da F2B.
            if CIN->(MsSeek(xFilial('CIN') + cidF2B))
                while !CIN->(EOF()) .and.;
                (CIN->CIN_FILIAL + CIN->CIN_IREGRA == xFilial('CIN') + cidF2B)
                    RecLock("CIN", .F.)
                    CIN->(dbDelete())
                    CIN->(MsUnLock())
                    CIN->(dbSkip())
                endDo
            endIf
            F2B->(dbSkip())
        endDo
    endIf
    // Fecho as áreas de trabalho e recupero a área inicial
	F2B->(dbCloseArea())
    CIN->(dbCloseArea())
	RestArea(aArea)
Return


/*/{Protheus.doc} findTaxF2D
    Verifica se ha registro na tabela F2D conforme consulta de Id do campo indicado
    @type  Function
    @author anedino.santos
    @since 22/01/2024
    @version 12.1.2310
    @param cId, character, id a ser procurado
    @param cCampo, character, o campo da tabela F2D ao qual procuraremos o Id
    @return lFound, logical, flag que confirma se registro foi encontrado
    @example
    findTaxF2D( 'b28d6b19-9b85-7cf1-b9c3-48104a0eada2' , 'F2D_IDCAD' ) -> .T./.F.
    @example
    findTaxF2D( cId , 'F2D_IDBASE' ) -> .T./.F.

    A chamada da funcao pode receber o ID do tributo como literal ou atraves de 
    uma variavel.
    Em ambos os exemplos de chamada acima a funcao ira retornar TRUE ou FALSE
    a depender se encontrou ou nao o registro na F2D.
/*/
Function findTaxF2D(cId, cCampo)
    Local lFound as logical
    Local cQuery as character
    Local oStatement as object

    BEGINCONTENT var cQuery
        SELECT F2D_ID
        FROM ?
        WHERE F2D_FILIAL = ?
        AND %Exp:cCampo% = ?
        AND D_E_L_E_T_ = ?
    ENDCONTENT

    oStatement := FWExecStatement():New(cQuery)
    oStatement:SetUnsafe(1, RetSqlName( 'F2D' ))
    oStatement:setString(2, xFilial( 'F2D' ))
    oStatement:setString(3, cId)
    oStatement:setString(4, ' ')

    lFound := !Empty(oStatement:ExecScalar("F2D_ID"))
    oStatement:Destroy()
Return lFound

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChvMd5
Função para atualização do campo MD5.

@author Juliano Fernandes
@since 16/04/2024
@version P12.1.2310
/*/
//-------------------------------------------------------------------
static function GetChvMd5()

    local oModel := FWModelActive()
    local cChave := ''
    local cPrefixo := 'CONFITRIB-' 
    local cChvMd5 := ''
    local lIsClassification := FWIsInCallStack('IntegraRegras')

    if ( lIsClassification )
        cPrefixo := 'CLASSTRIB-'
    endif

    cChave := oModel:GetValue('FISA160', 'F2B_TRIB')
    cChave += oModel:GetValue('FISA160', 'F2B_RBASE')
    cChave += oModel:GetValue('FISA160', 'F2B_RALIQ')
    cChave += oModel:GetValue('FISA160', 'F2B_PEROD')
    cChave += oModel:GetValue('FISA160', 'F2B_PERFPA')
    cChave += oModel:GetValue('FISA160', 'F2B_PERFOP')
    cChave += oModel:GetValue('FISA160', 'F2B_PERFPR')
    cChave += oModel:GetValue('FISA160', 'F2B_RFIN')
    cChave += oModel:GetValue('FISA160', 'F2B_RAPUR')
    cChave += oModel:GetValue('FISA160', 'F2B_RND')
    cChave += oModel:GetValue('FISA160', 'F2B_RBASES')
    cChave += oModel:GetValue('FISA160', 'F2B_TRBMAJ')
    cChave += oModel:GetValue('FISA160', 'F2B_DEDDEP')
    cChave += oModel:GetValue('FISA160', 'F2B_DEDPRO')
    cChave += oModel:GetValue('FISA160', 'F2B_CODESC')
    cChave += oModel:GetValue('FISA160', 'F2B_MAXMIN')
    cChave += oModel:GetValue('FISA160', 'F2B_RGGUIA')
    cChave += CValToChar(oModel:GetValue('FISA160', 'F2B_VLRMAX'))
    cChave += CValToChar(oModel:GetValue('FISA160', 'F2B_VLRMIN'))
    cChave += oModel:GetValue('FISA160', 'F2B_OPRMIN')
    cChave += oModel:GetValue('FISA160', 'F2B_OPRMAX')

    cChvMd5 := cPrefixo + Md5(cChave)

return cChvMd5

//-------------------------------------------------------------------
/*/{Protheus.doc} xBtnVlM
Função que cria os botões das fórmulas para as seção Regras de Limitações do Tributo que será responsável por adicionar o valor minumo ou máximo.

@author julia.mota
@since 26/03/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function xBtnVlM(oPanelBtn, cModelo, cViewForm, cTpRegra, cCodCab, cCodModCab, cCodRegra, cViewRegra)

Local cCssAdd	:= getCss("ADICIONAR_001.PNG")
Local cCssLim	:= getCss("excluir.PNG")

//Posições do eixo Y das linhas
Local nYFisrtRow       := 1

//Posições do exixo X das linhas
Local nXFirstCol       := 2
Local nXSecondCol      := 110
Local nXThirdCol       := 220


//Dimensões do tamanho dos botões
Local nWidthCss        := 100 //Largura do botão com CSS
Local nHeightCss       := 16 //Altura do botão com CSS
Local nWidthChk        := 100 //Largura do botão Chk

Default cTpRegra:= ""
Default cCodCab := ""
Default cCodModCab := ""
Default cCodRegra := CriaVar("F2B_TPREGR")
Default cViewRegra:= ""

//Cria frame para colcoar os componentes
oLayer := FWLayer():New()
oLayer:Init(oPanelBtn, .F.)
oLayer:AddLine('LIN1', 100, .F.) 
oPanel1  := oLayer:getLinePanel('LIN1')

//            TButton():New( [ nRow ], [ nCol ], [ cCaption ], [ oWnd ], [ bAction ], [ nWidth ], [ nHeight ], [ uParam8 ], [ oFont ], [ uParam10 ], [ lPixel ], [ uParam12 ], [ uParam13 ], [ uParam14 ], [ bWhen ], [ uParam16 ], [ uParam17 ] )
oBtnEAdd   := TButton():New((nYFisrtRow - 1) , nXFirstCol   ,"  Adicionar Limite Mínimo" ,oPanel1,{|| AddVlMin()} ,nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{|| HabBtnEdit()}/*{||xCanEdit() .and. HabBtnEdit(cModelo)  } */  ,,.F.)
oBtnChk    := TButton():New(nYFisrtRow       , nXSecondCol  ,"  Adicionar Limite Máximo"  ,oPanel1,{|| AddVlMax() },nWidthChk ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{|| HabBtnEdit()}/*{||xCanEdit() .and. HabBtnvalid(cModelo)  }  */  ,,.F.)
oBtnLimp    := TButton():New(nYFisrtRow       , nXThirdCol   ,"  Limpar"  ,oPanel1,{|| btnLimp() },nWidthChk ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{|| HabBtnLimp()}/*{||xCanEdit() .and. HabBtnvalid(cModelo)  }  */  ,,.F.)

//Aplica o CSS nos botões
oBtnEAdd:SetCss(cCssAdd)
oBtnChk:SetCss(cCssAdd)
oBtnLimp:SetCss(cCssLim)


Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} getCss
Função que monta o CSS

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Static Function getCss(cImg)

Local cEstilo	:= ""

cEstilo := "QPushButton {"  

If !Empty(cImg)
	//Usando a propriedade background-image, inserimos a imagem que será utilizada, a imagem pode ser pega pelo repositório (RPO)
	cEstilo += " background-image: url(rpo:" + cImg + ");background-position: left center;background-repeat: no-repeat; margin: 2px;" 
EndIF

cEstilo += " border-style: outset;"
cEstilo += " border-width: 1px;"
cEstilo += " border: 1px solid #03396C;"
cEstilo += " border-radius: 6px;"
cEstilo += " border-color: #03396C;"
cEstilo += " font: bold 12px Arial;"
cEstilo += " padding: 6px;"
cEstilo += " background-color: #f4f7f9;"
cEstilo += "}"

//Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botão ele muda
cEstilo += "QPushButton:pressed {"
cEstilo += " background-color: #e68a2c;"
cEstilo += " border-style: inset;"
cEstilo += "}" 

Return cEstilo

/*/{Protheus.doc} AddVlMin()
    Função responsável por adicionar o valor mínimo no botão da regra de limitação
    @type  Static Function
    @author julia.mota
    @author Rafael Oliveira
    @since 11/04/2025
    @version 12.1.2410
/*/
Static Function AddVlMin()

Local oModel      := FWModelActive()
Local oFormul   := oModel:GetModel('FISA160')
Local cTpRegra  := Alltrim(oModel:GetValue('FISA160', 'F2B_TPREGR'))
Local cCodRegra := Alltrim(oModel:GetValue('FISA160', 'F2B_CONREG'))

If !Empty(cTpRegra) .and. !Empty(cCodRegra)
    oFormul:LoadValue('F2B_OPRMIN', Alltrim(cCodRegra))

    IF cCodRegra <> "O:VAL_MANUAL"        
        oFormul:LoadValue('F2B_VLRMIN', 0)
    Endif

    xLimiteRefresh()
EndIf

Return

/*/{Protheus.doc} AddVlMax
    Função responsável por adicionar o valor mínimo no botão da regra de limitação
    @type  Static Function
    @author julia.mota
    @since 11/04/2025
    @version 12.1.2410
/*/
Static Function AddVlMax()

Local oModel      := FWModelActive()
Local oFormul   := oModel:GetModel('FISA160')
Local cTpRegra  := Alltrim(oModel:GetValue('FISA160', 'F2B_TPREGR'))
Local cCodRegra := Alltrim(oModel:GetValue('FISA160', 'F2B_CONREG'))

If !Empty(cTpRegra) .and. !Empty(cCodRegra)
    oFormul:LoadValue('F2B_OPRMAX', Alltrim(cCodRegra))

    IF cCodRegra <> "O:VAL_MANUAL"
        oFormul:LoadValue('F2B_VLRMAX', 0)
    Endif
    
    xLimiteRefresh()
EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X160TPREG
Função para Retornar conteudo para combo do campo F2B_TPREGR.

@author julia.mota
@since 24/03/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function X160TPREG()
Return '01=Operandos;02=Tributos Genéricos;03=Valor Manual'


//-------------------------------------------------------------------
/*/{Protheus.doc} FisLimCIN
Função auxiliar que retorna os tipo da regra de limitação
conforme selecionado no combo.
A princípio esta função será utilizada na consulta padrão da CINLIM

@author Rafael Oliveira
@since 10/05/2025
@version P12.1.2410

/*/
//-------------------------------------------------------------------
Function FisLimCIN()
Local oModel := FWModelActive()
Local cTipo  := Alltrim(oModel:GetValue( 'FISA160' , 'F2B_TPREGR' ))
Local cRet   := ""

If cTipo == "01" //Operandos
    cRet  := "0 "
ElseIf cTipo == "02" //Regras de Tributos
    cRet  := "6 /8 /11/12/13"
ElseIf cTipo == "03" //Valor Manual
    cRet  := "0 "
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTRBLimt
Função auxiliar que retorna o tributo selecionado pelo usuário
para poder filtrar a consulta das regras

@author Rafael Oliveira
@since 10/05/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Function FisTRBLimt()
Local oModel := FWModelActive()
Return Alltrim(oModel:GetValue ( 'FISA160' ,"F2B_TBCONF"))

/*/{Protheus.doc} FSA160Limt
    Função auxiliar que retorna os operandos que devem ser listados na consulta padrão CINLIM
    
    @type  Function
    @author Rafael Oliveira
    @since 12/05/2025
    @version P12.1.2410
    @return cRet, character, retorna os operandos que devem ser listados na consulta padrão CINLIM
    
    /*/
Function FSA160Limt()
Local cFilter := 'CIN_ALTERA == "0" .AND. CIN_TREGRA $ FisLimCIN() .And. Iif(!Empty(FisTRBLimt()), Alltrim(CIN_REGRA) == FisTRBLimt(), .T.) .and. Iif(Alltrim(CIN_TREGRA) == "0", Alltrim(CIN_CODIGO) $ FSA160OPR(), .T.)'
Return cFilter

/*/{Protheus.doc} xVldTpregr
    Validação do campo F2B_TPREGR
    @type  Static Function
    @author Rafael Oliveira
    @since 12/05/2025
    @version 12.1.2410
    @param oModel, object, modelo do campo
    @return retorna .T. ou .F. para validar o campo    
/*/
Static Function xVldTpregr(oView,oModel)    

    oModel:LoadValue('FISA160', 'F2B_TBCONF', criavar('F2B_TBCONF'))
    oModel:LoadValue('FISA160', 'F2B_CONREG', criavar('F2B_CONREG'))

    If Alltrim(oModel:GetValue('FISA160', 'F2B_TPREGR')) == "03"
        oModel:LoadValue('FISA160', 'F2B_CONREG', "O:VAL_MANUAL")
    Endif

    xLimiteRefresh()
    
Return .T.

/*/{Protheus.doc} xVldTbConf
    Validação do campo F2B_TBCONF
    @type  Static Function
    @author Rafael Oliveira
    @since 12/05/2025
    @version 12.1.2410
    @param oModel, object, modelo do campo
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function xVldTbConf(oView, oModel)    

    //Se alterado tributo limpa campo de consulta
    oModel:LoadValue('FISA160', 'F2B_CONREG', criavar('F2B_CONREG'))

    xLimiteRefresh()

Return Vazio() .OR. ExistCpo("F2B",FwFldGet("F2B_TBCONF"),1)


/*/{Protheus.doc} xLimiteRefresh
    Função responsável por atualizar as views de Limite e Limite de Campo
    @type  Static Function
    @author rafael.soliveira
    @since 12/05/2025
    @version 12.1.2410
/*/
Static Function xLimiteRefresh()
    Local oView := FWViewActive()

    If valType(oview) == "O"        
        oView:Refresh('VIEW_LIMITE')
        oView:Refresh('VIEW_LIMITE_CAMPO')
    Endif

Return

/*/{Protheus.doc} HabBtnEdit
    Função que habilita o botão de edição da regra de cálculo
    @type  Static Function
    @author Rafael Oliveira
    @since 13/05/2025
    @version 12.1.2410    
    @return lRet, logical, retorna .T. ou .F. para habilitar o botão    
/*/
Static Function HabBtnEdit(param_name)
    Local oModel := FWModelActive()
    Local cTpRegra  := Alltrim(oModel:GetValue('FISA160', 'F2B_TPREGR'))
    Local cCodRegra := Alltrim(oModel:GetValue('FISA160', 'F2B_CONREG'))
    Local lRet := .F.

    If !Empty(cTpRegra) .and. !Empty(cCodRegra)
        lRet := .T.    
    Endif
Return lRet

Static Function HabBtnLimp()
    Local oModel := FWModelActive()
    Local cOperMin  := Alltrim(oModel:GetValue('FISA160', 'F2B_OPRMIN'))
    Local cOperMax := Alltrim(oModel:GetValue('FISA160', 'F2B_OPRMAX'))
    Local lRet := .F.

    If !Empty(cOperMin) .Or. !Empty(cOperMax)
        lRet := .T.        
    Endif
Return lRet

/*/{Protheus.doc} btnLimp
    Função que limpa os campos de valor mínimo e máximo
    @type  Static Function
    @author Rafael Oliveira
    @since 13/05/2025
    @version 12.1.2410    
    @return lRet, logical, retorna .T. ou .F. para habilitar o botão
/*/
Static Function btnLimp()
    Local oModel := FWModelActive()
    Local cOperMin  := Alltrim(oModel:GetValue('FISA160', 'F2B_OPRMIN'))
    Local cOperMax := Alltrim(oModel:GetValue('FISA160', 'F2B_OPRMAX'))

    If !Empty(cOperMin) .Or. !Empty(cOperMax)
        oModel:SetValue('FISA160', 'F2B_OPRMIN', " ")
        oModel:SetValue('FISA160', 'F2B_OPRMAX', " ")
        oModel:SetValue('FISA160', 'F2B_VLRMIN', 0)
        oModel:SetValue('FISA160', 'F2B_VLRMAX', 0)        
        xLimiteRefresh()
    Endif
Return .T.




/*/{Protheus.doc} F2BEditStatus
Função para determinar se o campo F2B_STATUS deve estar habilitado ou desabilitado.

## Descrição
Esta função verifica o status do campo `F2B_STATUS` e determina se ele deve estar habilitado ou desabilitado com base na operação atual (inclusão ou edição) e no valor inicial do campo.

## Regras de Negócio
- Status '1' (Em teste): Campo habilitado.
- Status '2' (Em produção): Campo desabilitado.

### Inclusão
- Quando é uma inclusão, o campo deve estar habilitado.

### Edição
- Na edição, caso o valor inicial do campo seja '2' (Em produção), o campo deve estar desabilitado.
- Na edição, caso o valor inicial do campo seja '1' (Em teste), o campo deve estar habilitado.

@param oModel - Objeto - Modelo ativo.
@return lRet - Booleano - Retorna .T. se o campo deve estar habilitado, .F. caso contrário.

@since
@version 12.1.2410
@Author Rafael Oliveira
/*/
//-------------------------------------------------------------------
Static Function F2BEditStatus(oModel)
    Local lRet       := .F.
    Local nOperation := oModel:GetOperation()
    Local cStatus    := oModel:GetValue('FISA160', 'F2B_STATUS')

    If nOperation == MODEL_OPERATION_INSERT
        lRet := .T.
    ElseIf nOperation == MODEL_OPERATION_UPDATE
        lRet := ValidateStatus(cStatus, oModel)
    EndIf

Return lRet

/*/{Protheus.doc} ValidateStatus
    Função para validar o campo F2B_STATUS.

    @type  Static Function
    @author Rafael Oliveira
    @since 10/02/2025
    @version 12.1.2410
    @param cStatus - String - Valor do campo F2B_STATUS.
    @param oModel - Objeto - Modelo ativo.
    @return lRet - Booleano - Retorna .T. se o campo foi alterado, .F. caso contrário.
    @example
    ValidateStatus('2', oModel) -> .T./.F.    
/*/
Static Function ValidateStatus(cStatus, oModel)
    Local lRet := .T.

    If cStatus == '2' .and. !VerifCampoAlt(oModel, "FISA160", "F2B_STATUS")
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} VerifCampoAlt
    Verifica se o campo foi alterado.

    @type  Static Function
    @author user
    @since 10/02/2025
    @version 12.1.2410
    @param oModel - Objeto - Modelo ativo.
    @param cModelo - String - Nome do modelo.
    @param cCampo - String - Nome do campo.
    @return lRet - Booleano - Retorna .T. se o campo foi alterado, .F. caso contrário.
    @example
    VerifCampoAlt(oModel, "FISA160", "F2B_STATUS") -> .T./.F.
/*/
Static Function VerifCampoAlt(oModel, cModelo, cCampo)
Return oModel:GetModel(cModelo):IsFieldUpdated(cCampo)

/*/{Protheus.doc} AtuF2BStatus
    Função para atualizar o campo F2B_STATUS.

    @type  Function
    @author Rafael Oliveira
    @since 04/02/2025
    @version 12.1.2410
/*/
Function AtuF2BStatus()

Local cQuery := ""

    cQuery := "UPDATE " +  RetSqlName('F2B') + " SET F2B_STATUS = '2' WHERE F2B_FILIAL = '" + xFilial('F2B') + "' AND F2B_STATUS = ' ' AND D_E_L_E_T_ = ' '"
    TcSqlExec(cQuery)

Return


/*/{Protheus.doc} startApproval

    Inicializa as variáveis estáticas utilizadas no processo de aprovação de
    regras tributárias em cadeia.

    @type  Static Function
    @author anedino.santos
    @since 07/04/2025
    @version 12.1.2410
    @return nil, nil, sem retorno
/*/
Static Function startApproval()
    aRegTrib := {}
    jChekedOper := JsonObject():New()
Return


/*/{Protheus.doc} approvalProcessing

    Gerencia a aprovação das regras em cadeia possibilitando ou não das regras
    serem aprovadas através do parâmetro `lApprov`.

    Essa função pode ser disparada de duas formas: pelo valid do modelo ou pela
    função `apprPreview`.

    ### Pelo valid do modelo
    Quando o campo Status for alterado para "2=Aprovada" será feita a verificação
    se dentro da fórmula da regra há outras regras tributárias envolvidas que
    estando em fase de testes devem também ser aprovadas para que não haja 
    inconformidades nos dados das regras tributárias.

    Uma vez que uma regra é aprovada, todas as regras que compõem a cadeia de
    fórmulas que estão direta e indiretamente ligadas e essa fórmula devem ser
    ou estar aprovadas também.

    ### Pela função apprPreview
    Essa rotina pode ser chamada sem que o processo de aprovação seja concluído
    ao definir `lApprov` como falso. Essa possibilidade é usada pela função `apprPreview`
    que faz o processo apenas para demonstrar quais regras devem ser aprovadas
    em cadeia

    @type  Static Function
    @author anedino.santos
    @since 01/04/2025
    @version 12.1.2410
    @param oModel, object, objeto do modelo da FISA160
    @param lApprov, logical, define se será feito o processo de aprovação
    @return lRet, logical, retorna se tudo ocorreu bem
/*/
Static Function approvalProcessing(oModel, lApprov)
    Local lRet as logical
    Local cFormula    := oModel:GetValue('FORMULCAL',"CIN_FORMUL") as character
    Local cFormulaIn  := oModel:GetValue('FORMULCAL_ISENTO',"CIN_FORMUL") as character
    Local cFormulaOu  := oModel:GetValue('FORMULCAL_OUTROS',"CIN_FORMUL") as character
    Local aAreaCIN    := CIN->(getArea())
    Local cRegra      := AllTrim(oModel:GetValue("FISA160", "F2B_REGRA"))

    default lApprov := .T.

    chainedRules(cFormula, cRegra)
    chainedRules(cFormulaIn, cRegra)
    chainedRules(cFormulaOu, cRegra)

    if lApprov
        if .not. makeApproval()
            oModel:SetValue('FISA160', "F2B_STATUS", "1")
        endif
    endif

    CIN->(RestArea(aAreaCIN))
Return lRet


/*/{Protheus.doc} chainedRules

    Recupera as regras tributárias existentes em uma fórmula. O parâmetro cRegra
    é usado como exceção na verificação da fórmula onde a regra informada nesse
    parâmetro é ignorada.

    @type  Static Function
    @author anedino.santos
    @since 02/04/2025
    @version 12.1.2410
    @param cFormula, character, formula que será verificada
    @param cRegra, character, código da regra que será ignorada
/*/
Static Function chainedRules(cFormula, cRegra)
    Local aCompOper as array
    Local nI as numeric
    // recupero os operandos compostos da fórmula
    aCompOper := listOper(cFormula, 2)

    for nI := 1 to len(aCompOper)
        if !jChekedOper:hasProperty(aCompOper[nI])
            extractRules(aCompOper[nI], cRegra)
        endif
    next nI
Return


/*/{Protheus.doc} extractRules

    Processa o operando composto extraíndo a regra tributária do mesmo se houver,
    além de processar sua fórmula de forma recursiva chamando a função chainedRules.

    @type  Static Function
    @author anedino.santos
    @since 02/04/2025
    @version 12.1.2410
    @param cOper, character, operando composto a ser processado
    @param cException, character, regra tributária a ser desconsiderada
    @return nil, nil, sem retorno
/*/
Static Function extractRules(cOper, cException)
    local cRegTrib := isRegTrib(cOper) as character
    local cFormulPlus := "" as character
    local cAlias := "" as character

    // Quando encontro uma regra tributária devo verificar todas as formulas dela
    // tributada - isenta - outros
    // para então definir se dentro destas fórmulas há outras regras que devem ser
    // aprovadas junto.
    if !Empty(cRegTrib) .and. cException <> cRegTrib .and. aScan(aRegTrib, cRegTrib) == 0
        // guardamos o tributo no array estático
        aAdd(aRegTrib, cRegTrib)
        // recuperamos todas as fórmulas do tributo
        cAlias := FSA160getForm(cRegTrib)
        // percorremos todas as formulas e concatenamos elas para enviarmos de uma
        // vez só como se fosse uma única fórmula
        while (cAlias)->(!EOF())
            cFormulPlus+= " " + AllTrim((cAlias)->CIN_FORMUL)
            (cAlias)->(DbSkip())
        endDo
        (cAlias)->(dbCloseArea())
        // enviamos as fórmulas concatenadas para serem processadas recursivamente
        chainedRules(cFormulPlus, cException)

    // caso não seja um operando de regra tributária trato o operando composto de
    // forma mais simples.
    elseif CIN->(MsSeek(xFilial("CIN") + cOper))
        cRegTrib := CIN->CIN_REGRA
        chainedRules(CIN->CIN_FORMUL, cException)
    endif
    // guardo o operando como chave e seu valor será a regra (fórmula)
    jChekedOper[cOper] := cRegTrib
Return


/*/{Protheus.doc} FSA160getForm

    Recupera todas as formulas do tributo na CIN

    @type  Function
    @author anedino.santos
    @since 09/04/2025
    @version 12.1.2510
    @param cRegTrib, character, regra tributária a qual buscaremos suas fórmulas na CIN
    @return cAlias, character, alias do retorno da query
/*/
Function FSA160getForm(cRegTrib)
    local cAlias := "" as character
    local oExec := nil as object

    oExec := FWExecStatement():New(qryFormula())
    oExec:setUnsafe(1, RetSqlName("CIN"))
    oExec:setString(2, xFilial("CIN"))
    oExec:setString(3, cRegTrib)
    oExec:setString(4, " ")

    cAlias := oExec:openAlias()

    oExec:destroy()
    FwFreeObj(oExec)
    oExec := Nil
Return cAlias


/*/{Protheus.doc} qryFormula

    Define e retorna a query de busca das fórmulas.
    Para esta query é preciso utilizar de funções específicas de cada banco de
    dados homologado. Por este motivo ela foi extraída em uma função própria.
    Também pelo fato de ser possível testá-la.

    @type  Static Function
    @author anedino.santos
    @since 09/04/2025
    @version 12.1.2510
    @param cDB, character, define qual o banco de dados será consultado
    @return cQuery, character, query string formatada para bind
/*/
static function qryFormula(cDB)
    local cQuery := ""

    default cDB := TCGetDB()

    cQuery := "SELECT "
    IF "ORACLE" $ cDB
        cQuery += "UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CIN_FORMUL, 4000, 1)) CIN_FORMUL"
    ELSEIF "POSTGRES" $ cDB
        cQuery += "encode(CIN_FORMUL, 'escape') CIN_FORMUL"
    ELSE
        cQuery += "COALESCE(CAST(CAST(CIN_FORMUL AS VARBINARY(8000)) AS VARCHAR(8000)),' ') CIN_FORMUL"
    ENDIF
    cQuery += " FROM ? "
    cQuery += "WHERE "
    cQuery += "CIN_FILIAL = ? "
    cQuery += "AND CIN_REGRA = ? "
    cQuery += "AND D_E_L_E_T_ = ? "

return cQuery


/*/{Protheus.doc} makeApproval

    Separa os tributos que estão em teste e demonstra ao usuário para definir
    se continua com a rotina de aprovação

    @type  Static Function
    @author anedino.santos
    @since 03/04/2025
    @version 12.1.2410
/*/
Static Function makeApproval()
    local aTestTax := {} as array
    local lApprov := .T. as logical

    aTestTax := getTestTax(aRegTrib)

    if len(aTestTax) > 0
        if !isBlind()
            // execução com interface demonstra a pergunta
            // para casos em que for sem interface, serão aprovadas todas as regras automaticamente
            lApprov := MsgYesNo(setMsgApro(aTestTax), "Atenção!")
        endif
        if lApprov
            approvRule(aTestTax)
        endif
    endif
Return lApprov


/*/{Protheus.doc} setMsgApro

    Define a mensagem de aprovação conforme lista de tributos a serem aprovados

    @type  Static Function
    @author anedino.santos
    @since 17/04/2025
    @version 12.1.2510
    @param aReg, array, lista de regras em teste que serão apresentadas no texto
    @return cText, return_type, return_description
/*/
Static Function setMsgApro(aReg)
    local cText := "" as character
    local nI := 0 as numeric

    cText := "Há outras regras que compõem a fórmula da regra atual de forma "
    cText += "direta ou indireta que devem ser aprovadas junto com ela: "

    for nI := 1 to len(aReg)
        cText += aReg[nI] + ", "
    next nI
    cText := StrTran(cText, ",", ".", len(aReg))
    cText += CRLF + CRLF + "Deseja fazer a aprovação de todas as regras em conjunto?"
Return cText


/*/{Protheus.doc} finishApprovals

    Finaliza o processamento de aprovação de regra limpando as variáveis estáticas

    @type  Static Function
    @author anedino.santos
    @since 07/04/2025
    @version 12.1.2410
    @return nil , nil, sem retorno
/*/
Static Function finishApprovals()

    if ValType(aRegTrib) == "A"
        aSize(aRegTrib, 0)
        aRegTrib := nil
    endif

    if ValType(jChekedOper) == "J"
        FwFreeVar(jChekedOper)
        jChekedOper := nil
    endif
Return


/*/{Protheus.doc} approvRule

    Aprova as regras em fase de teste conforme lista enviada.

    @type  Function
    @author anedino.santos
    @since 03/04/2025
    @version 12.1.2410
    @param aTaxRules, array, lista de regras a serem aprovadas
    @return nil, nil, sem retorno
/*/
Function approvRule(aTaxRules)
    Local oExec as object
    Local cQuery := "" as character

    cQuery := "UPDATE " +  RetSqlName('F2B') + " SET F2B_STATUS = '2' "
    cQuery += "WHERE F2B_FILIAL = ? AND "
    cQuery += "F2B_STATUS = ? AND "
    cQuery += "F2B_REGRA IN (?) AND "
    cQuery += "D_E_L_E_T_ = ? "

    // usado apenas para evitar potencial SQL Injection em aTaxRules
    oExec := FwExecStatement():New(cQuery)
    oExec:setString(1, xFilial('F2B'))
    oExec:setString(2, "1")
    oExec:setIn(3, aTaxRules)
    oExec:setString(4, " ")

    Begin Transaction
        execQryApr(oExec:GetFixQuery())
    End Transaction

    oExec:destroy()
    FwFreeObj(oExec)
    oExec := Nil
Return


/*/{Protheus.doc} execQryApr

    Executa o camando SQL UPDATE para aprovar as regras em fase de teste.

    @type  Function
    @author anedino.santos
    @since 22/04/2025
    @version 12.1.2510
    @param cStatement, character, comando sql update
/*/
Function execQryApr(cStatement)
    // O comando UPDATE não retorna alias em openAlias()
    // Para evitar erros utilizei o comando abaixo
    if TcSqlExec(cStatement) <> 0
        DisarmTransaction()
    endif
Return


/*/{Protheus.doc} FSA160Apro

    Efetua o processo de aprovação alterando o campo STATUS da regra posicionada
    para "2" e startando a aprovação em cadeia através do valid do modelo.

    @type  Function
    @author anedino.santos
    @since 17/04/2025
    @version 12.1.2510
/*/
function FSA160Apro()
    local oModel := Nil

    if F2B->F2B_STATUS == "1"
        oModel := FWLoadModel("FISA160")
        oModel:setOperation(MODEL_OPERATION_UPDATE)
        oModel:activate()
        oModel:setValue("FISA160", "F2B_STATUS", "2")
        if oModel:vldData()
            oModel:commitData()
        endif
        oModel:deActivate()
        oModel:destroy()
        FwFreeObj(oModel)
    elseIf !isBlind()
        Alert("A regra selecionada já está aprovada.")
    endif

return


/*/{Protheus.doc} getTestTax

    A partir de uma lista de regras tributárias, retorna todas as regras que
    estão em fase de teste.
    Para uso dessa função é preciso ter a área de trabalho F2B aberta além da
    lista das regras enviadas na lista não serem deletadas.

    @type  Function
    @author anedino.santos
    @since 17/04/2025
    @version 12.1.2510
    @param aReg, array, lista de regras a serem avaliadas se estão em teste
    @return aRet, array, lista de tributos em teste
/*/
function getTestTax(aReg)
    local nI as numeric
    local aF2BArea := F2B->(GetArea()) as array
    local aRet := {} as array

    dbSelectArea("F2B")
    dbSetOrder(7)

    for nI := 1 to len(aReg)
        if F2B->(MsSeek(xFilial("F2B") + aReg[nI])) .and. alltrim(F2B->F2B_STATUS) == "1"
            aAdd(aRet, aReg[nI])
        endif
    next nI

    F2B->(RestArea(aF2BArea))
return aRet


/*/{Protheus.doc} apprPreview

    Retorna quais regras tributárias serão aprovadas em cadeia conforme a regra
    tributária enviada em `cRegra`.

    @type  Function
    @author anedino.santos
    @since 17/04/2025
    @version 12.1.2510
    @param cRegra, character, código da regra tributária inicial
    @return aRet, array, lista de regras que serão aprovadas em cadeia
/*/
Function apprPreview(cRegra)
    local oModel := Nil as object
    local aRet := {} as array

    DbSelectArea("F2B")
    F2B->(DbSetOrder(1))

    If F2B->(MsSeek( xFilial("F2B") + cRegra ))
        oModel := FWLoadModel("FISA160")
        oModel:setOperation(MODEL_OPERATION_VIEW)
        oModel:activate()
        startApproval()
        approvalProcessing(oModel, .F.)
        aRet := getTestTax(aRegTrib)
        finishApprovals()
        oModel:deActivate()
        oModel:Destroy()
    endif

    F2B->(DbCloseArea())

Return aRet


/*/{Protheus.doc} FSA160DFil
    Lista de opções dinâmicas para o campo CIN_FILTRO

    @type  Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
    @param oView, object, objeto da view ativa
    @param oModel, object, objeto do modelo ativo 
/*/
Function FSA160DFil(oView, oModel)
    local aOpt as array
    local cOptions as character

    if ValType(oView) =='O'
        oModel    := FWModelActive()
        if lF2BStatus .and. oModel:IsActive()
            cOptions := XFISTREGRA()
            aOpt := StrToKArr(cOptions, ';')
            if oModel:GetModel("FISA160"):getValue("F2B_STATUS") == "2"
                aDel(aOpt, len(aOpt))
                aSize(aOpt, len(aOpt)-1)
            endif
            oView:SetFieldProperty("VIEW_REGRA", "CIN_FILTRO", "COMBOVALUES",{aOpt})
            oview:Refresh()
        endif
    endif
Return


/*/{Protheus.doc} FSA160Filt
    Função utilizada para definir o filtro da consulta padrão do campo CIN_TRIB.

    @type  Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
/*/
function FSA160Filt()
    Local cFiltro := 'F2B_ALTERA <> "1"'

    if cOpt == "05" .and. lF2BStatus
        cFiltro += ' .AND. F2B_STATUS = "2"'
    elseif cOpt == "Z1" .and. lF2BStatus
        cFiltro += ' .AND. F2B_STATUS = "1"'
    endif
return cFiltro


/*/{Protheus.doc} FSA160HCon
    Função utilizada na verificação do modo WHEN do campo CIN_CONSUL.

    @type  Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
    @param oModel, object, objeto do modelo ativo
    @param cSubModel, character, nome do sub-modelo do tipo fields
    @param cCmp, character, campo do sub-modelo
/*/
function FSA160HCon(oModel, cSubModel, cCmp)
    local lRet := .T.
    // defino o valor da variável static
    cOpt := oModel:getValue(cSubModel, "CIN_FILTRO")

    if cOpt $ "05/Z1" .and. Empty(oModel:getValue(cSubModel, cCmp))
        lRet := .F.
    endif

return lRet


/*/{Protheus.doc} FSA160SFoc
    Coloca o focus no campo CIN_FILTRO.

    @type Static Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
    @param oView, object, objeto da view em uso
    @param cIDView, character, nome da subview
/*/
static function FSA160SFoc(oView, cIDView,cField)
    oView:getViewObj(cIDView)[3]:getFWEditCtrl(cField):oCtrl:SetFocus()
return


/*/{Protheus.doc} X160F2BINIT
    Função responsavel por inicializar campos da tabela F2B
    @param cCampo, character, campo a ser inicializado
    @return cRet, character, retorna o valor inicial do campo
    @type Function
    @author Rafael Oliveira
    @since 22/05/2025
    @version 12.1.2410

/*/
Function X160F2BINIT(cCampo)
return ''
