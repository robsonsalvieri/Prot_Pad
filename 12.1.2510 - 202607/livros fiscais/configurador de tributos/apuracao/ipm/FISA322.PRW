#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA322.CH"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA322()
Esta rotina tem objetivo de realizar Cadastro de Regra de IPM
@author Denis Souza
@since 06/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Function FISA322()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CKD")
oBrowse:SetDescription(STR0001) //"Cadastro de Regra de IPM"
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao responsável por gerar o menu.
@author Denis Souza
@since 06/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA322" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do Cadastro de Regra de IPM
@author Denis Souza	
@since 06/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel     := Nil
Local oCabecalho := FWFormStruct(1, "CKD" )
Local oIPM       := FWFormStruct(1, "CKE" )
Local oRateio    := FWFormStruct(1, "CKF" )

oModel := MPFormModel():New('FISA322', ,{|oModel|VldFisa322(oModel)})

oModel:AddFields("MODEL_CKD",,oCabecalho)

oModel:SetPrimaryKey( {"CKD_FILIAL","CKD_ID","CKD_CODREG"} )
                                                                                                                                                                                                               
oModel:AddGrid("MODEL_CKE","MODEL_CKD",oIPM)
oModel:GetModel("MODEL_CKE"):SetUniqueLine({"CKE_UF","CKE_CODIPM","CKE_REGCAL"})
oModel:GetModel( "MODEL_CKE" ):SetOptional( .T. )
oModel:SetRelation("MODEL_CKE", {{"CKE_FILIAL", "xFilial('CKE')"},{"CKE_ID","CKD_ID"}},CKE->(IndexKey(1))) //CKE_FILIAL+CKE_ID+CKE_UF+CKE_CODIPM+CKE_REGCAL

oModel:AddGrid("MODEL_CKF","MODEL_CKE",oRateio)
oModel:GetModel("MODEL_CKF"):SetUniqueLine({"CKF_CODMUN"})
oModel:GetModel( "MODEL_CKF" ):SetOptional( .T. )
oModel:SetRelation("MODEL_CKF", {{"CKF_FILIAL", "xFilial('CKF')"},{"CKF_IDIPM","CKD_ID"},{"CKF_UF","CKE_UF"},{"CKF_CODIPM","CKE_CODIPM"}},CKF->(IndexKey(1))) //CKF_FILIAL+CKF_IDIPM+CKF_UF+CKF_CODIPM+CKF_REGCAL+CKF_CODMUN

oModel:SetDescription(STR0003) //"Cadastro de Regra IPM"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.
@author Denis Souza
@since 06/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel     := FWLoadModel("FISA322")
Local oView      := Nil
Local oCabecalho := Nil
Local oCkeIPM    := Nil
Local oCkfRateio := Nil
Local cCmpFolder := ''

oView := FWFormView():New()
oView:SetModel(oModel)

cCmpFolder := "CKD_CODREG|CKD_DESCR|CKD_VIGINI|CKD_VIGFIM|"
oCabecalho:= FwFormStruct( 2, 'CKD', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

cCmpFolder := "CKE_UF|CKE_CODIPM|CKE_DSCIPM|CKE_CONSMU|CKE_REGCAL|CKE_CONVLS|"
oCkeIPM	    := FwFormStruct( 2, 'CKE', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

cCmpFolder  := "CKF_CODMUN|CKF_DESCMU|CKF_RATEIO|"
oCkfRateio  := FwFormStruct( 2, 'CKF', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

oView:AddField( 'VIEW_CAB'   , oCabecalho, 'MODEL_CKD' )
oView:AddGrid(  'VIEW_IPM'   , oCkeIPM   , 'MODEL_CKE' )
oView:AddGrid(  'VIEW_RATEIO', oCkfRateio, 'MODEL_CKF' )

//Habilitando opções de filtros
oView:SetViewProperty( 'VIEW_IPM', "GRIDFILTER", {.T.} )
oView:SetViewProperty( 'VIEW_IPM', "GRIDSEEK"  , {.T.} )

oView:SetViewProperty( 'VIEW_RATEIO', "GRIDFILTER", {.T.} )
oView:SetViewProperty( 'VIEW_RATEIO', "GRIDSEEK"  , {.T.} )

//Cria três box
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

//Cria o Folder Principal
oView:CreateFolder( 'Folder_CKD', 'INFERIOR' )

//Cria as Abas Principais
oView:AddSheet( 'Folder_CKD', 'ABA_IPM'   , STR0004 ) //"IPM"
oView:AddSheet( 'Folder_CKD', 'ABA_RATEIO', STR0005 ) //"Rateio"

//Cria box da aba de Principais
oView:CreateHorizontalBox( 'PAINEL_IPM'   , 100,,, 'Folder_CKD', 'ABA_IPM'    )
oView:CreateHorizontalBox( 'PAINEL_RATEIO', 100,,, 'Folder_CKD', 'ABA_RATEIO' )

//Faz vínculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'   , 'SUPERIOR'      )
oView:SetOwnerView( 'VIEW_IPM'   , 'PAINEL_IPM'    )
oView:SetOwnerView( 'VIEW_RATEIO', 'PAINEL_RATEIO' )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CAB'   , STR0006 ) //"Cadastro Código e Vigência"
oView:EnableTitleView('VIEW_IPM'   , STR0007 ) //"Amarração UFs x Código IPM"
oView:EnableTitleView('VIEW_RATEIO', STR0008 ) //"Rateio do Código IPM x Municípios"

// Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CAB", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFisa322
Função que realiza as validações do modelo
@param	oModel - Objeto  -  Objeto do modelo FISA322
@Return lRet   - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Denis Souza	
@since 06/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VldFisa322(oModel)

Local lRet       := .T.
lOCAL cID        := oModel:GetValue('MODEL_CKD',"CKD_ID"     )
Local dDtIni     := oModel:GetValue('MODEL_CKD',"CKD_VIGINI" )
Local dDtFim     := oModel:GetValue('MODEL_CKD',"CKD_VIGFIM" )
Local nOperation := oModel:GetOperation()
Local lInclui    := nOperation == MODEL_OPERATION_INSERT
Local lAltera    := nOperation == MODEL_OPERATION_UPDATE

IF lInclui .OR. lAltera

    IF VldVigen(cID, dDtIni, dDtFim, lAltera )
        lRet:= .F.
        Help(,,'Help',,STR0009,1,0) //"Intervalo de vigência já informada em outro cadastro."
    EndIF

	if lRet
        lRet := VldRateio(oModel)
        //"Atenção"##"A soma do rateio dos municípios para o Código IPM "##" não é de 100%."##"Preencha corretamente o campo % Rateio"
        Help(,,STR0010,,(STR0011+Alltrim(oModel:GetValue('MODEL_CKE',"CKE_CODIPM"))+STR0012),1,0,,,,,,{STR0013})
	endif
    If lRet
        lRet := VldOpMun(oModel)
        //"Atenção"##"A chave "UF + Código IPM" foi informada com rateio."##"Existem outras regras de cálculo vinculadas à mesma chave,##"
        // todas também devem ser configuradas como rateio."##" Verifique a chave "UF + Código IPM "##" e ajustar o campo Operação Município."
        Help(,,STR0010,,(STR0014+" "+STR0015+STR0016),1,0,,,,,,{STR0017+STR0018})
    EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVigen
Função que verifica se data inicial e data final já existem no cadastro
@param     cId     - String - Id do cadastro pai
@param     dDtIni  - Date - Data inicial de vigência
@param     dDtFim  - Date - Data final de vigência
@param     lAltera - Booleano - indica se é uma operação de edição
@return    lRet    - Booleano - Indica se encontrou o cadastro
@author Denis Souza
@since 06/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VldVigen(cId, dDtIni, dDtFim, lAltera)

Local lRet       := .F.
Local cQry	     := ""
Local cAliasQry	 := ""
Local oPrepare   := Nil
Local aBind      := {}
Local nX         := 0

Default cId      := ""
Default dDtIni   := ""
Default dDtFim   := ""
Default lAltera  := ""

cQry := "SELECT CKD.CKD_CODREG FROM " + RetSQLName("CKD") + " CKD WHERE CKD.CKD_FILIAL = ? AND "
aAdd(aBind, xFilial("CKD") )

cQry += "( "

//Verifica se está compreendido em cadastro somente com data inicial preenchida
cQry += "( ? >= CKD.CKD_VIGINI AND CKD.CKD_VIGFIM = ? ) OR "
aAdd(aBind, DtoS(dDtIni) )
aAdd(aBind, space(1) )

//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
cQry += "( ? >= CKD.CKD_VIGINI AND ? <= CKD.CKD_VIGFIM ) "
aAdd(aBind, DtoS(dDtIni) )
aAdd(aBind, DtoS(dDtIni) )

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
    cQry += " OR ( CKD.CKD_VIGFIM = ? ) "
    aAdd(aBind, space(1) )

ElseIf !Empty(dDtFim)
    //Caso a data final seja informada então verificaremos se está compreendida em algum cadastro com data inicial e final preenchidos.
    cQry += " OR ( ? >= CKD.CKD_VIGINI AND ? <= CKD.CKD_VIGFIM ) "
    aAdd(aBind, DtoS(dDtFim) )
    aAdd(aBind, DtoS(dDtFim) )

    cQry += " OR ( ? >= CKD.CKD_VIGINI AND CKD.CKD_VIGFIM = ? ) "
    aAdd(aBind, DtoS(dDtFim) )
    aAdd(aBind, space(1) )
EndIF

cQry += " ) AND "

If lAltera
    //Se for edição desconsidera a linha editada, para não entrar em conflito com ela mesma
    DbSelectArea("CKD")
    CKD->(DbSetOrder(1))
    If CKD->(MsSeek( xFilial("CKD") + cId ))
        cQry += " CKD.R_E_C_N_O_ <> ? AND "
        aAdd(aBind, CKD->(recno()) )
    EndIF
EndIF

cQry += "CKD.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

cQry := ChangeQuery(cQry)
oPrepare := FwExecStatement():New(cQry)

For nX := 1 To Len(aBind)
	If ValType(aBind[nX]) == 'C'
		oPrepare:setString(nX, aBind[nX])
	elseif ValType(aBind[nX]) == 'N'
		oPrepare:SetNumeric(nX, aBind[nX])
	EndIf
Next nX

cAliasQry := GetNextAlias()

oPrepare:OpenAlias(cAliasQry) //oPrepare:getfixquery()

IF !(cAliasQry)->(Eof())
    lRet := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

aSize(aBind,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldRateio
- Validacao total rateio por Código IPM.
- Validacao de rateio se existir lancamento na CKF.
- Mesmo se nao existir lancamento na CKF (linhas válidas), 
para CKE_CONSMU = 5 (Rateio), o rateio entre municipios se torna obrigatorio.

@param  cId  - String - Id do cadastro pai
@return lRet - Booleano - Indica se encontrou o cadastro
@author Denis Souza
@since 06/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VldRateio(oModel)

Local oMdlCKE  := Nil
Local oMdlCKF  := Nil
Local lRet     := .T.
Local nCKE     := 0
Local nAteCKE  := 0
Local nCKF     := 0
Local nAteCKF  := 0
Local nSum     := 0
Local lLnValid := .F.
Local aDados   := {}
Local nX       := 0
Local nPos     := 0
Local cRegCal  := ""

Default oModel := Nil

oMdlCKE := oModel:GetModel( 'MODEL_CKE' )
nAteCKE := oMdlCKE:Length()

For nCKE := 1 To nAteCKE
    oMdlCKE:GoLine(nCKE)
    If !oMdlCKE:IsDeleted() .And. !oMdlCKE:IsEmpty()
        lLnValid := .F.
        nSum     := 0
        oMdlCKF  := oModel:GetModel( 'MODEL_CKF' )
        nAteCKF  := oMdlCKF:Length()
        For nCKF := 1 To nAteCKF
            oMdlCKF:GoLine(nCKF)
            If !oMdlCKF:IsDeleted() .And. !oMdlCKF:IsEmpty()
                lLnValid := .T.
                nSum += oMdlCKF:GetValue("CKF_RATEIO") 
            endif
        Next nCKF
        if oMdlCKE:GetValue("CKE_CONSMU") == "5"
            nPos := Ascan(aDados,{|x|AllTrim(x[1]) == Alltrim((xFilial("CKE") + oMdlCKE:GetValue("CKE_UF") + oMdlCKE:GetValue("CKE_CODIPM")))})
            If nPos > 0 .and. !(cRegCal == oMdlCKE:GetValue("CKE_REGCAL")) .and. aDados[nPos][3] < 100
                aDados[nPos][3] += nSum                 
            ElseIf nPos == 0 //Só grava se não achar
                aAdd(aDados,{AllTrim((xFilial("CKE") + oMdlCKE:GetValue("CKE_UF") + oMdlCKE:GetValue("CKE_CODIPM"))), oMdlCKE:GetValue("CKE_CONSMU"), nSum})
                cRegCal := oMdlCKE:GetValue("CKE_REGCAL")  
            EndIf
        Endif      
    EndIf
Next nCKE

if Len(aDados)> 0
    For nX := 1 To Len(aDados)
        If aDados[nX][3] != 100
            lRet := .F.
            exit
        EndIf
    Next nX
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa322Mun
Validação de campo CKF_CODMUN, a funcao é necessaria pois o M->CKF_UF ou FwFldGet("CKF_UF") não é alimentado na Tela,
somente após a gravação, é que armazena o conteúdo do pai (CKE_UF) devido o relation do mvc.
@param  nil - nil
@return Booleano - Indica se encontrou o cadastro
@author Denis Souza
@since 06/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Function Fisa322Mun()
Return ExistCpo("CC2",FwFldGet("CKE_UF") + M->CKF_CODMUN)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa322CC2
Funcao utilizada no gatilho campo CKF_CODMUN
@param  cUf     - String
@param  cMunic  - String
@return cDescMuni - String
@author Denis Souza
@since 06/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Function Fisa322CC2(cUf, cMunic)

Local cDescMuni := ""

Default cUf    := ""
Default cMunic := ""

DbSelectArea('CC2')
CC2->(dbSetOrder(1))
If CC2->(MsSeek( xFilial("CC2") + cUf + cMunic ))
    cDescMuni := Alltrim(CC2->CC2_MUN)
EndIf

Return cDescMuni

//-------------------------------------------------------------------
/*/{Protheus.doc} VldOpRat
- Validacao se há Operação Muncipios diferente quando possui rateio, para mesma UF e DIPAM com regras diferentes.

@return lRet - Booleano - Indica se encontrou o cadastro
@author Carlos Pister
@since 22/08/2025
version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function VldOpMun(oModel)

Local oMdlCKE  := Nil
Local lRet     := .T.
Local nCKE     := 0
Local nAteCKE  := 0
Local aDados   := {}
Local nPos     := 0

Default oModel := Nil

oMdlCKE := oModel:GetModel( 'MODEL_CKE' )
nAteCKE := oMdlCKE:Length()

For nCKE := 1 To nAteCKE
    oMdlCKE:GoLine(nCKE)
    If !oMdlCKE:IsDeleted() .And. !oMdlCKE:IsEmpty()

        nPos := Ascan(aDados,{|x|AllTrim(x[1]) == Alltrim((xFilial("CKE") + oMdlCKE:GetValue("CKE_UF") + oMdlCKE:GetValue("CKE_CODIPM")))})
        If nPos > 0
            if (oMdlCKE:GetValue("CKE_CONSMU") == "5" .and. !(aDados[nPos][2] == "5")) .or. (aDados[nPos][2] == "5" .and. !(oMdlCKE:GetValue("CKE_CONSMU") == "5"))
                lRet := .F.
                exit
            endif            
        Else
            aAdd(aDados,{AllTrim((xFilial("CKE") + oMdlCKE:GetValue("CKE_UF") + oMdlCKE:GetValue("CKE_CODIPM"))),;
                          oMdlCKE:GetValue("CKE_CONSMU")} )                                             
        EndIf
                
    EndIf
Next nCKE

Return lRet
