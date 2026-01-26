#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA164.ch" 

Static lF22Tipo := F22->(Fieldpos("F22_TIPOPF")) > 0
Static lAutomato := IsBlind()

Static oJSCLIFOR 
Static cFilAtu := " "

PUBLISH MODEL REST NAME FISA164
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA164()

Cadastro de perfil tributário de participantes.
Esta rotina fará cadastro de perfis de participantes, que serão utilizadas no
motor de cálculo tributário fiscal.


@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA164()

Local   oBrowse := Nil
Private cTpPart := ""

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F20") .AND. AliasIndic("F22")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0001) // Cadastro de Perfil Tributário de Produto
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '02'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA164' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA164' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA164' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA164' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA164' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador - Clientes'      ACTION 'FSA171WIZ("1","02","CLI")' OPERATION 4 ACCESS 0 //'Facilitador'
    ADD OPTION aRotina TITLE 'Facilitador - Fornecedores'  ACTION 'FSA171WIZ("1","02","FOR")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela de perfil F20
Local oCabecalho := FWFormStruct(1, "F20" )

//Estrutura do produto considerando a tabela F24
Local oParticipante := FWFormStruct(1, "F22" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA164')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA164",,oCabecalho)

//Adicionando o grid de participante
oModel:AddGrid( 'FISA164PARTICIPANTE', 'FISA164', oParticipante,,,,{|oParticipante| ValidDel(oParticipante)})
//oModel:GetModel( 'FISA164PARTICIPANTE' ):SetUseOldGrid()

//Inicializa o campo F20_TIPO com ´conteúdo "04" que significa tipo de perfil de produto
oCabecalho:SetProperty('F20_TIPO' , MODEL_FIELD_INIT ,{||"02"} )

IF lF22Tipo
    oParticipante:SetProperty('F22_TIPOPF' , MODEL_FIELD_INIT ,{||"02"} )
Endif

//Retira obrigatoriedade dos campos F24_CODIGO e F25_CODIGO
oParticipante:SetProperty('F22_CODIGO' , MODEL_FIELD_OBRIGAT,  .F. )

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA164', '02') )})
oParticipante:SetProperty('F22_LOJA',   MODEL_FIELD_VALID, {||Vazio() .Or. VldCliFor(oModel:GetValue ('FISA164PARTICIPANTE',"F22_TPPART"),oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA"))})

// Gatilho do campo Loja do cliente/fornecedor
oParticipante:AddTrigger('F22_CLIFOR','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_CLIFOR" )})
oParticipante:AddTrigger('F22_CLIFOR','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_CLIFOR" )})
oParticipante:AddTrigger('F22_TPPART','F22_CLIFOR',{|| .T. },{||A164TRG(oModel,"F22_TPPART" )})
oParticipante:AddTrigger('F22_TPPART','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_TPPART" )})
oParticipante:AddTrigger('F22_TPPART','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_TPPART" )})
oParticipante:AddTrigger('F22_CLIFOR','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC" )})
oParticipante:AddTrigger('F22_LOJA','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC" )})

//Relacionamento entre as tabelas F20 Perfil com F22 Participantes
oModel:SetRelation( 'FISA164PARTICIPANTE', { { 'F22_FILIAL', 'xFilial("F22")' }, { 'F22_CODIGO', 'F20_CODIGO' }, {'02','F20_TIPO'} }, F22->( IndexKey( 1 ) ) )

//Define para não repetir o código de produto
oModel:GetModel( 'FISA164PARTICIPANTE' ):SetUniqueLine( { 'F22_TPPART','F22_CLIFOR','F22_LOJA'} )

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA164PARTICIPANTE'):SetMaxLine(9999999)

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tributário de Participantes


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA164" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20")
Local oParticipante	:= FWFormStruct(2, "F22")


Local oView := Nil
Local cVersao 	:= GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA164'         )
oView:AddGrid(  'VIEW_PARTICIPANTE'   , oParticipante    , 'FISA164PARTICIPANTE'  )

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_PARTICIPANTE', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_PARTICIPANTE', "GRIDSEEK", {.T.})


//Retira os campos da View
oCabecalho:RemoveField( 'F20_TIPO' )
oParticipante:RemoveField( 'F22_CODIGO' )

IF lF22Tipo
    oParticipante:RemoveField('F22_TIPOPF')
Endif

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_PARTICIPANTE'     , 'INFERIOR'    )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO' , STR0001 )
oView:EnableTitleView('VIEW_PARTICIPANTE' , STR0003 ) 

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

oParticipante:SetProperty("F22_CLIFOR",MVC_VIEW_LOOKUP,{ || A164ChgF3("F22_TPPART",oModel) })
oParticipante:SetProperty("F22_CLIFOR",MVC_VIEW_INIBROW,{ || A164TRG(oModel,"F22_RAZSOC") })

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ") 
    oView:AddUserButton( 'Facilitador - Clientes'    ,'', {|oView| FSA171WIZ("2","02","CLI")} )
    oView:AddUserButton( 'Facilitador - Fornecedores','', {|oView| FSA171WIZ("2","02","FOR")} )
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function A164ChgF3(cCmpF3,oModel)

Local cTpPart	:= oModel:GetValue ('FISA164PARTICIPANTE',cCmpF3)
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.

If cTpPart == '1'
    cRet    := "SA2"
ElseIf cTpPart == '2'
    cRet    := "SA1"   
EndIF

Retur cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function A164TRG(oModel,cCmpTrigger)

Local cTpPart	:= oModel:GetValue ('FISA164PARTICIPANTE',"F22_TPPART")
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.

If cTpPart == '1'
    If cCmpTrigger == "F22_CLIFOR"

        cRet    := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"),"A2_LOJA")

    ElseIf cCmpTrigger == "F22_RAZSOC"  

        If AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"))+AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet    := STR0005 //"TODOS OS FORNECEDORES"
        Else
            cRet    := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA"),"A2_NOME")
        EndIf 
    ElseIf cCmpTrigger == "F22_TPPART"
    
        cRet := " "
    
    EndIf 

ElseIf cTpPart == '2'

    If cCmpTrigger == "F22_CLIFOR"

        cRet    := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"),"A1_LOJA")

    ElseIf cCmpTrigger == "F22_RAZSOC"  

        If AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"))+AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet    := STR0004//"TODOS OS CLIENTES"
        Else
            cRet    := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA"),"A1_NOME")
        EndIf

    ElseIf cCmpTrigger == "F22_TPPART"
    
        cRet := " "
    
    EndIf 

EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCliFor(cTipo,cCliFor)

Local lRet := .F.

//Verifico o Tipo do Participante para Setar a consulta de Campo.
If AllTrim(cCliFor) == PADR("TODOS", TamSx3("F22_CLIFOR")[1]) + Replicate("Z",TamSx3("F22_LOJA")[1])
    lRet    := .T.
ElseIf cTipo == '1'
    DbSelectArea("SA2")
    DbSetOrder(1)
    If SA2->(DbSeek(xFilial("SA2")+cCliFor))
        lRet    := .T.
    EndIf 
ElseIf cTipo == '2' 
    DbSelectArea("SA1")
    DbSetOrder(1)
    If SA1->(DbSeek(xFilial("SA1")+cCliFor))
        lRet    := .T.
    EndIf 
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A164RAZSOC
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function A164RAZSOC(cTpPart,cCliFor,cLoja)
Local cRet := ""
Local lJson:= .T.
Local nTamSx3:= len(cLoja)
Local cCodigo := ""

If !Empty(cCliFor)

    IF Upper(AllTrim(cCliFor) + AllTrim(cLoja)) == "TODOS" + Replicate("Z", nTamSx3) 
        If cTpPart == "1"
            cRet := STR0005 //"TODOS OS FORNECEDORES"
        Else
            cRet := STR0004 //"TODOS OS CLIENTES"
        Endif
    Endif

    lJson    := VALTYPE( oJSCLIFOR ) == "J"

    if !lJson .or. cFilAtu <> cFilAnt

        lJson := CliForJs()
        cFilAtu := cFilAnt

    EndIf


//Verifico o Tipo do Participante para Setar a consulta de Campo.

    If lJson .AND. Empty(cRet)

        If cTpPart == "1"      
           cRFilial := RTrim(oJSCLIFOR:GetNames()[1])
           cCodigo  := alltrim(cClifor) + cLoja + "F"
        else
           cRFilial := RTrim(oJSCLIFOR:GetNames()[1])
           cCodigo  := alltrim(cClifor) + cLoja + "C"
        Endif 

        If oJSCLIFOR:hasproperty(cRFilial)
            cRet  := oJSCLIFOR[cRFilial][cCodigo]
        EndIf
                 
    EndIf

    If Empty(cRet)
        If cTpPart == "1"      
            cRet  := POSICIONE("SA2",1,xFilial("SA2")+cCliFor+cLoja,"A2_NOME")
        Else
            cRet  := POSICIONE("SA1",1,xFilial("SA1")+cCliFor+cLoja,"A1_NOME")
        Endif
    EndIf
    
Endif
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA164GF22

Função para gravação/exclusão da F22 chamada de "fora" da rotina
de cadastro

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA164GF22(cCodPerfil, cOper, cTpPart, cCliFor, cLoja)

Local oModel := NIL
Local oPartic := NIL
Local lRet := .F.

oModel := FWLoadModel("FISA164")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "02"))

    oModel:Activate()

    oPartic := oModel:GetModel("FISA164PARTICIPANTE")

    If cOper == "INCLUI"

        oPartic:AddLine()
        oPartic:LoadValue("F22_TPPART" , cTpPart)
        oPartic:SetValue("F22_CLIFOR" , cCliFor)
        oPartic:SetValue("F22_LOJA"   , cLoja)
        IF lF22Tipo
            oPartic:SetValue("F22_TIPOPF"   , '02')
        Endif

    ElseIf cOper == "EXCLUI"

        If oPartic:SeekLine( { {"F22_TPPART", cTpPart }, {"F22_CLIFOR", cCliFor}, {"F22_LOJA", cLoja } } )
            oPartic:DeleteLine()
        EndIf

    EndIf

    If oModel:VldData()
        lRet := oModel:CommitData()        
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet


/*/{Protheus.doc} AtuTpPF02
    (Atualiza novo campo F22_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF02()

IF lF22Tipo
    cQuery := "UPDATE " +  RetSqlName('F22') + " SET F22_TIPOPF = '02' WHERE F22_FILIAL = " + ValToSql(xFilial('F22')) + " AND F22_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif


Return

/*/{Protheus.doc} VldTodos
    Valida a inclusão do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oParticipante)

Local lRet      := .T.
Local lForTd    := .F.
Local lCliTd    := .F.
Local lForAv    := .F.
Local lCliAv    := .F.
Local cTpPart   := ""
Local nY
Local cPart

oModelPad   := FwModelActive()

For nY := 1 to oParticipante:Length()

    oParticipante:GoLine(nY)

    iF !oParticipante:IsDeleted()

        cTpPart := AllTrim(oParticipante:GetValue ("F22_TPPART"))
        cPart   := AllTrim(oParticipante:GetValue ("F22_CLIFOR"))

        lForTd := iif(lForTd==.F.,iif(cTpPart=="1" .and. AllTrim(cPart)=="TODOS",.t.,.f.),.T.)
        lCliTd := iif(lCliTd==.F.,iif(cTpPart=="2" .and. AllTrim(cPart)=="TODOS",.t.,.f.),.T.)

        lForAv := iif(lForAv==.F.,iif(cTpPart=="1" .and. !("TODOS" $ cPart),.t.,.f.),.T.)
        lCliAv := iif(lCliAv==.F.,iif(cTpPart=="2" .and. !("TODOS" $ cPart),.t.,.f.),.T.)

        If (lForTd .and. lForAv) .and. (lCliTd .and. lCliAv)
            exit
        ENDIF

    EndIf

Next nY

nY := 0

If (lForTd .and. lForAv) .or. (lCliTd .and. lCliAv)

    If lAutomato .or. MsgYesNo(STR0006 + chr(13)+chr(10) +;    //"Existem participantes configurados como 'TODOS' no Grid."
                STR0007 + chr(13)+chr(10) +;    //"Os participantes diferente de TODOS serão excluídos"
                STR0008, STR0001)               //"Deseja continuar?" "Perfil Tributário de Participante"

        For nY := 1 to oParticipante:Length()

        oParticipante:GoLine(nY)

            cTpPart := AllTrim(oParticipante:GetValue ("F22_TPPART"))
            cPart   := AllTrim(oParticipante:GetValue ("F22_CLIFOR"))

            iF !oParticipante:IsDeleted()

                if(!("TODOS" $ cPart) .and. (lCliTd .and. lCliAv) .and. cTpPart == "2")
                    oParticipante:DeleteLine()
                EndIf

                if(!("TODOS" $ cPart) .and. (lForTd .and. lForAv) .and. cTpPart == "1")
                    oParticipante:DeleteLine()
                EndIf
            EndIf

        Next nY
    else
        lRet := .F.
        oModelPad:SetErrorMessage(,,,,,STR0009,STR0010)
    EndIf
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CliForJs

Cria um JSON com todos clientes e fornecedores para melhorar a performance ao visualizar, 
alterar e excluir no perfil de participantes

@author Julia Mota
@since 05/09/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function CliForJs()
Local cAlias	:= GetNextAlias()
Local cQuery	:= " "
Local cChave := " "
Local oPSAtiv 
Local cFilBkp := " "
Local lRet    := .F.

    cQuery := " SELECT SA1.A1_FILIAL FILIAL,SA1.A1_COD CODIGO,SA1.A1_LOJA LOJA,SA1.A1_NOME NOME, 'C' TIPO
    cQuery += " FROM ? SA1"
    cQuery += " WHERE A1_FILIAL = ? AND SA1.D_E_L_E_T_ = ' '"
    cQuery += " UNION ALL
    cQuery += " SELECT SA2.A2_FILIAL FILIAL,SA2.A2_COD CODIGO, SA2.A2_LOJA LOJA,SA2.A2_NOME NOME, 'F' TIPO
    cQuery += " FROM ? SA2"
    cQuery += " WHERE A2_FILIAL = ? AND SA2.D_E_L_E_T_ = ' ' ORDER BY 1 ASC"

    oPSAtiv := FwExecStatement():New(cQuery)

    oPSAtiv:SetUnsafe(1, RetSQLName("SA1"))
    oPSAtiv:setString(2, xFilial("SA1"))
    oPSAtiv:SetUnsafe(3, RetSQLName("SA2"))
    oPSAtiv:setString(4, xFilial("SA2"))

    cAlias	:= oPSAtiv:OpenAlias(GetNextAlias())

	DbSelectArea (cAlias)
	
    oJSDetalhe:=JsonObject():new()

 	While (cAlias)->(!Eof()) 
        cFilBkp := (cAlias)->FILIAL
        cChave  := (cAlias)->CODIGO+(cAlias)->LOJA+(cAlias)->TIPO
        
        oJSDetalhe[cChave]:=(cAlias)->NOME

		(cAlias)->(DbSkip())
	EndDo

    IF VALTYPE( oJSCLIFOR ) == "J"    
        FREEOBJ(oJSCLIFOR)
    Endif 

    oJSCLIFOR    := JsonObject():New()

    If Len(oJSDetalhe:GetNames( )) > 0
        oJSCLIFOR[RTrim(cFilBkp)] := oJSDetalhe
        lRet := .T.
    EndIf

	(cAlias)->(dbCloseArea()) //Fecha tabela temporaria
     FREEOBJ(oJSDetalhe)

Return lRet
