#INCLUDE "GTPA905.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA905
Cadastro de Localidades x Moeda

@sample		GTPA905()

@param 			

@return		
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA905()

Local oBrowse  

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    If GTPxVldDic("H7Z")
        H7Z->(DbSetOrder(1))
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('H7Z') 
        oBrowse:SetDescription(STR0001)    //'Cadastro Localidade X Moeda'

        oBrowse:Activate()
    Else 
        FwAlertHelp(STR0010, STR0011) //"Dicionário desatualizado.Tabela H7Z não localizado." //"Atenção"        
    EndIf 
EndIf

Return()

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Funcao de definição do aRotina

@sample		

@param 			

@return		oModel - Objeto
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function MenuDef() 
Local aRotina := {} 

ADD OPTION aRotina Title STR0002	Action 'PesqBrw'         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.GTPA905' OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina Title STR0004    Action 'VIEWDEF.GTPA905' OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina Title STR0005    Action 'VIEWDEF.GTPA905' OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina Title STR0006    Action 'VIEWDEF.GTPA905' OPERATION 5 ACCESS 0   //"Excluir"

Return aRotina

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o modelo de dados  

@sample		

@param 			

@return		oModel - Objeto
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef() 
Local oModel	  := MPFormModel():New( "GTPA905", /*bPreValidacao*/, { |oModel| PosValid( oModel ) }/*bPosValidacao*/,  /*bCommit*/, /*bCancel*/ ) 
Local oCab	      := FWFormStruct( 1, 'H7Z')
Local oGridTpPg   := FWFormStruct( 1, 'H7U') 
Local oGriLocaliz := FWFormStruct( 1, 'H7V') 
Local aGatilho	  := {}
Local bFldVld	  := {|oMdl,cField,cNewValue,nLinAtu|GTPA905Vld(oMdl,cField,cNewValue,nLinAtu) }

aGatilho := FwStruTrigger("H7Z_MOEDA", "H7Z_DESMOE", "Alltrim(SuperGetMv('MV_MOEDA'+Str(FWFLDGET('H7Z_MOEDA'),1)))")
oCab:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])
oCab:SetProperty('H7Z_MOEDA', MODEL_FIELD_INIT,	{|| 9 })

oGridTpPg:SetProperty( "H7U_TPPAGT"	, MODEL_FIELD_VALID , bFldVld)

aGatilho := FwStruTrigger("H7V_LOCALI", "H7V_LOCDES", "GetAdvFval('GI1','GI1_DESCRI',xFilial('GI1')+FWFLDGET('H7V_LOCALI'),1)")
oGriLocaliz:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

oGriLocaliz:SetProperty( "H7V_LOCALI"	, MODEL_FIELD_VALID , bFldVld)

oModel:AddFields( 'H7ZMASTER', /*cOwner*/, oCab ) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid (antiga getdados)
oModel:AddGrid( 'H7UTPPAGT', 'H7ZMASTER', oGridTpPg  , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'H7VDETAIL', 'H7ZMASTER', oGriLocaliz, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("H7UTPPAGT",{{"H7U_FILIAL","xFilial('H7U')"},{"H7U_CODIGO","H7Z_CODIGO"}},H7U->(IndexKey(1)))								   
oModel:SetRelation("H7VDETAIL",{{"H7V_FILIAL","xFilial('H7V')"},{"H7V_CODIGO","H7Z_CODIGO"}},H7V->(IndexKey(1)))

//Chave Primaria
oModel:SetPrimaryKey({})      

// Liga o controle de nao repeticao de linha
oModel:GetModel("H7UTPPAGT"):SetUniqueLine({"H7U_TPPAGT"})
oModel:GetModel("H7VDETAIL"):SetUniqueLine({"H7V_LOCALI"})

//O preenchimento da grid é opcional (Não é obrigatorio)
oModel:GetModel("H7UTPPAGT"):SetOptional(.F.)
oModel:GetModel("H7VDETAIL"):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )  // 'Localidade x Moeda'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'H7UTPPAGT' ):SetDescription( STR0007 ) // 'Tipo Pagamento' 
oModel:GetModel( 'H7VDETAIL' ):SetDescription( STR0008 ) // 'Localidades de Origem'

Return(oModel)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a interface para cadastro  

@sample		

@param 			

@return		oModel - Objeto
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function ViewDef()      

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado 
Local oModel	:= FWLoadModel( 'GTPA905' ) 
Local oView		:= FWFormView():New() 
// Cria a estrutura a ser usada na View
Local oCab	      := FWFormStruct( 2, 'H7Z' )
Local oGridTpPg   := FWFormStruct( 2, 'H7U' ,{|cCampo| Alltrim(cCampo) $ "H7U_TPPAGT" }) 
Local oGriLocaliz := FWFormStruct( 2, 'H7V' ,{|cCampo| Alltrim(cCampo) $ "H7V_LOCALI|H7V_LOCDES" }) 

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel ) 

oView:AddField('VIEW_H7UCAB', oCab       , 'H7ZMASTER' )                     
oView:AddGrid('VIEW_H7UTPPG', oGridTpPg  , 'H7UTPPAGT' ) 
oView:AddGrid('VIEW_H7VLOCA', oGriLocaliz, 'H7VDETAIL' ) 

oView:CreateHorizontalBox('SUPERIOR',20)	
oView:CreateHorizontalBox('BOX_PAGTO',30)	
oView:CreateHorizontalBox('BOX_LOCALIDADES',50)

oView:SetOwnerView( 'VIEW_H7UCAB'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_H7UTPPG'  , 'BOX_PAGTO' )
oView:SetOwnerView( 'VIEW_H7VLOCA'  , 'BOX_LOCALIDADES' )

oView:EnableTitleView('VIEW_H7UCAB' , STR0009 )  // 'Detalhes'
oView:EnableTitleView('VIEW_H7UTPPG', STR0007 )  // 'Tipo de pagamento'
oView:EnableTitleView('VIEW_H7VLOCA', STR0008 )  // 'Localidade de origem'

oView:SetDescription( STR0001 ) // 'Localidade x Moeda')
         
Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosValid( oModel )
Funcao de ação de verificação de dados preenchidos

@sample		

@param 			

@return		booleano
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function PosValid( oModel )
    Local lRet        := .T.
    Local oGridPg     := oModel:GetModel("H7UTPPAGT")
    Local oGridLc     := oModel:GetModel("H7VDETAIL")
    Local nOperation  := oModel:GetOperation()
    Local nX          := 0
    Local nY          := 0
    Local lLocalidade := .T.
    Local aSavLines   := FwSaveRows()
    Local lSemTpPg    := .F.
    Local nDeletado   := 0
    Local cCadMoeda   := ""
    Local cCodigoAtu  := ""
    Local cTpPagto    := ""
    Local cLocalidade := ""
    Local cCodigo     := ""

    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
        aSavLines   := FwSaveRows()
        For nX := 1 To oGridPg:Length()
            oGridPg:GoLine(nX)
            If !oGridPg:IsDeleted()
                If Alltrim(oGridPg:GetValue('H7U_TPPAGT')) == '**'
                    lSemTpPg := .T.
                EndIf 
            EndIf 
        Next nX 

        If lSemTpPg
            For nY:= 1 To oGridLc:Length()
                oGridLc:GoLine(nY)
                If oGridLc:IsDeleted() 
                    nDeletado ++
                Else 
                    If Empty(oGridLc:GetValue("H7V_LOCALI"))
                        lLocalidade := .F.
                    Else 
                        If ExistLocalid(FWFldGet("H7Z_CODIGO"), '**', oGridLc:GetValue("H7V_LOCALI"), @cCodigo )
                            lRet := .F. // Informa ao usuário inconsistencia
                            cCadMoeda := cValToChar(GetAdvFval("H7Z","H7Z_MOEDA",xFilial("H7Z")+cCodigo,1))
                            Help(NIL, NIL, "GTPA905_4", NIL , I18N(STR0016,{'**',oGridLc:GetValue("H7V_LOCALI"),cCadMoeda}) , 1, 0, NIL, NIL, NIL , NIL , NIL ,{STR0017}) //"Tipo [ #1 ] localidade [ #2 ], já cadastrado na moeda [ #3 ]" // "Informe uma nova localização."
                            Exit                          
                        EndIf     
                    EndIf 
                EndIf 
            Next nY 
            If nDeletado == oGridLc:Length()
                lLocalidade := .F.
            EndIf 
        EndIf 

        If !(lLocalidade)
            lRet:= .F.
            Help(NIL, NIL, "GTPA905", NIL , STR0012, 1, 0, NIL, NIL, NIL , NIL , NIL ,{STR0013})  //"Para tipo de pagamento: 'SEM TIPO PAGTO' é obrigatório informar uma localização." // "Informe uma localização."
        EndIf 

        If lRet 
            For nX := 1 To oGridPg:Length()
                oGridPg:GoLine(nX)
                If !oGridPg:IsDeleted()

                    cCodigoAtu := FWFldGet("H7Z_CODIGO")
                    cTpPagto   := FWFldGet("H7U_TPPAGT")

                    If ExistTipoPg(cCodigoAtu, cTpPagto,@cCodigo)
                        For nY:= 1 To oGridLc:Length()
                            oGridLc:GoLine(nY)
                            If !oGridLc:IsDeleted() 
                                cLocalidade := FWFldGet("H7V_LOCALI")
                                If Empty(cLocalidade)
                                    lRet := .F.
                                    cCadMoeda := cValToChar(GetAdvFval("H7Z","H7Z_MOEDA",xFilial("H7Z")+cCodigo,1))
                                    Help(NIL, NIL, "GTPA905_3", NIL , I18N(STR0014,{cTpPagto,cCadMoeda}) , 1, 0, NIL, NIL, NIL , NIL , NIL ,{STR0015}) //"Tipo [ #1 ] já cadastrado na moeda [ #2 ]" // "Informe uma nova localização e/ou tipo de pagamento."
                                    Exit
                                Else 
                                    lRet := ExistLocalid(cCodigoAtu, cTpPagto, cLocalidade,@cCodigo)
                                    If lRet
                                        lRet := .F.
                                        cCadMoeda := cValToChar(GetAdvFval("H7Z","H7Z_MOEDA",xFilial("H7Z")+cCodigo,1))
                                        Help(NIL, NIL, "GTPA905_2", NIL , I18N(STR0016,{cTpPagto,cLocalidade,cCadMoeda}) , 1, 0, NIL, NIL, NIL , NIL , NIL ,{STR0017}) //"Tipo [ #1 ] localidade [ #2 ], já cadastrado na moeda [ #3 ]" // "Informe uma nova localização."
                                        Exit
                                    Else 
                                        // Caso não exista a localização, permite a inclusão.
                                        lRet := .T.                                        
                                    EndIf
                                EndIf  
                            EndIf 
                        Next nY 
                    EndIf 

                EndIf 
            Next nX 
        EndIF 
        FWRestRows( aSavLines )
    EndIf 

Return lRet 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA905TP()
Funcao de composição do combobox do campo H7U_TPPAGT

@sample		

@param 			

@return		Caracter - lista de opções
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA905TP()
    Local cLista := '**=SEM TIPO PAGTO;' + G421TpPag()
Return cLista 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP905MOEDA( cCodigoBil )
Funcao de retorno da moeda corrente

@sample		

@param 			

@return		númerico
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTP905MOEDA( cCodigoBil )
    Local nMoeda      := CriaVar( 'F2_MOEDA' )
    Local aAreaAtu    := GetArea()
    Local aAreaGIC    := GIC->(GetArea())
    Local lTables     := FWAliasInDic( 'H7U' ) .And. FWAliasInDic( 'H7V' ) .And. FWAliasInDic( 'H7Z' )
    Local cLocalidade := ''
    Local cAliasQry   := ''
    Local cTpPagto    := ''
    Local lLocalidade := .F. 
    Local lTipo       := .F.
    Local nVlrTipo    := 0
    Local nVlrLocal   := 0
    Local cExpressao  := ''

    /*
        Regra:
        1.) Pesquisa por localidade
        2.) Pesquisa por tipo de pagamento
    */

    If lTables .And. !Empty(cCodigoBil)
        GIC->(DbSetOrder(1))    // GIC_FILIAL, GIC_CODIGO, R_E_C_N_O_, D_E_L_E_T_
        If GIC->(DbSeek(xFilial("GIC")+cCodigoBil))

            cLocalidade := GIC->GIC_LOCORI
            cTpPagto    := GetAdvFVal("GZP","GZP_TPAGTO",xFilial("GZP")+GIC->(GIC_CODIGO+GIC_BILHET),1)

            cExpressao := I18N("% AND H7U_TPPAGT IN ('**','#1')%" ,{cTpPagto}) 

            cAliasQry := GetNextAlias()

            BeginSql Alias cAliasQry 

                SELECT H7Z_CODIGO,H7U_TPPAGT,H7Z_MOEDA,ISNULL(H7V_LOCALI,'') H7V_LOCALI
                FROM %table:H7Z% H7Z
                INNER JOIN %table:H7U% H7U ON H7U_FILIAL = %xFilial:H7U% AND H7U_CODIGO = H7Z_CODIGO %exp:cExpressao% AND H7U.%NotDel%
                LEFT JOIN %table:H7V% H7V ON H7V_FILIAL = %xFilial:H7V% AND H7V_CODIGO = H7Z_CODIGO AND H7V.%NotDel%
                WHERE 
                    H7Z_FILIAL = %xFilial:H7Z%
                AND H7Z.%NotDel%

            EndSql 

            While (cAliasQry)->(!Eof())

                If Empty((cAliasQry)->H7V_LOCALI)
                    lTipo  := .T. 
                    nVlrTipo := (cAliasQry)->H7Z_MOEDA
                EndIf 
                If (cAliasQry)->H7V_LOCALI == cLocalidade
                    lLocalidade := .T. 
                    nVlrLocal := (cAliasQry)->H7Z_MOEDA
                    Exit 
                EndIf 
                (cAliasQry)->(DbSkip())
            EndDo 

            If lLocalidade
                nMoeda := nVlrLocal 
            ElseIf lTipo 
                nMoeda := nVlrTipo
            EndIf                 

            (cAliasQry)->(DbCloseArea())

        EndIf 
    EndIf 

    RestArea( aAreaGIC )
    RestArea( aAreaAtu )

Return nMoeda 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP905PERT()
Funcao de validação dos tipos de pagamento H7U_TPPAGT

@sample		

@param 			

@return		booleano
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA905PERT()
    Local lRetorno := .T.
    Local cLista   := GTPA905TP()
    Local cTpPagto := &( ReadVar() )
    Local aOpcoes  := StrToKarr(cLista,";")

    lRetorno := Ascan(aOpcoes,{|z| Left(Alltrim(z),2) == Alltrim(cTpPagto)}) > 0

Return lRetorno 


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA905Vld(oMdl,cField,cNewValue,nLinAtu,cCadMoeda)
Validação preenchimento de campos do modal

@sample		

@param 			

@return		booleano
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function GTPA905Vld(oMdl,cField,cNewValue,nLinAtu,cCadMoeda)
    Local lRet       := .T.
    Local oModel     := oMdl:GetModel()
    Local cMdlId     := oMdl:GetId()
    Local nOperation := oModel:GetOperation()
    Local cTitulo    := "GTPA905Vld"
    Local cMsgErro   := ""
    Local cMsgSol    := ""
    Local aSavLines  := NIL
    Local nCount     := 0
    Local lSemTpPg   := .F.
    Local nDeletado  := 0

    Default cCadMoeda  := ''

    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .And. cField $ 'H7U_TPPAGT'

        aSavLines:= FwSaveRows()

        If cField == 'H7U_TPPAGT'

            If oMdl:Length() > 1 

                For nCount:=1 To oMdl:Length() 
                    oMdl:GoLine(nCount)

                    If oMdl:IsDeleted()
                        nDeletado ++
                    EndIf 

                    If Alltrim(oMdl:GetValue('H7U_TPPAGT')) == '**' 
                        lSemTpPg := .T.
                    EndIf 

                Next nCount 

                If (oMdl:Length() - nDeletado) > 1 .And. lSemTpPg
                    lRet        := .F.
                    cMsgErro	:= STR0018  // "O tipo de pagamento ['SEM TIPO PAGTO'], não é permitido com mais de um tipo de pagamento na mesma moeda. "
                    cMsgSol		:= STR0019  // "Exclua os demais tipos de pagamento na Grid."
                EndIf 
                
            EndIf 

        EndIf 

        If !lRet
            oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,cTitulo,cMsgErro,cMsgSol,cNewValue,cValToChar(nLinAtu))
        Endif

        FWRestRows( aSavLines ) 

    EndIf 

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistTipoPg(cCodigoAtu, cTpPagto)
Funcao de verificação de existencia do tipo do pagamento em outras moedas já cadastradas

@sample		

@param 			

@return		booleano
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ExistTipoPg(cCodigoAtu, cTpPagto, cCodigo)
    Local lRet      := .F.
    Local cAliasQry := GetNextAlias()
    Local aAreaAtu  := GetArea()
    
    Default cCodigo := ''

    BeginSql Alias cAliasQry 

        SELECT H7U_CODIGO
        FROM %table:H7U% H7U
        WHERE 
            H7U_FILIAL = %xFilial:H7U%
        AND H7U_CODIGO <> %exp:cCodigoAtu%
        AND H7U_TPPAGT = %exp:cTpPagto%
        AND H7U.%NotDel%

    EndSql 

    If (cAliasQry)->(!Eof())
        cCodigo :=  (cAliasQry)->H7U_CODIGO
        lRet := .T.
    EndIf 

    (cAliasQry)->(DbCloseArea())

    RestArea(aAreaAtu)
Return lRet 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistLocalid(cCodigoAtu, cTpPagto, cLocalidade, cCodigo )
Funcao de verificação de existencia de localidades em outras moedas já cadastradas

@sample		

@param 			

@return		booleano
@author		José Carlos
@since		04/10/2024
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ExistLocalid(cCodigoAtu, cTpPagto, cLocalidade, cCodigo )
    Local lRet      := .F.
    Local cAliasQry := ''
    
    Default cCodigo  := ''

    If cTpPagto == '**'
        H7V->(DbSetOrder(2))    // H7V_FILIAL, H7V_LOCALI, R_E_C_N_O_, D_E_L_E_T_
        If H7V->(DbSeek(xFilial("H7V")+cLocalidade))
            While H7V->(!Eof()) .And. H7V->H7V_FILIAL == xFilial("H7V") .And. H7V->H7V_LOCALI == cLocalidade
                If H7V->H7V_CODIGO <> cCodigoAtu     
                    lRet := .T.
                    cCodigo := H7V->H7V_CODIGO
                    Exit
                EndIf 
                H7V->(DbSkip())
            EndDo 
        EndIf 
    Else     
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry 

            SELECT H7U_CODIGO
            FROM %table:H7U% H7U
            INNER JOIN %table:H7V% H7V ON H7V_FILIAL = %xFilial:H7U% AND H7V_CODIGO = H7U_CODIGO AND H7V.%NotDel% 
            WHERE 
                H7U_FILIAL = %xFilial:H7U%
            AND H7U_CODIGO <> %exp:cCodigoAtu%
            AND H7U_TPPAGT = %exp:cTpPagto%
            AND H7V_LOCALI = %exp:cLocalidade%
            AND H7U.%NotDel%

        EndSql 

        If (cAliasQry)->(!Eof())
            cCodigo := (cAliasQry)->H7U_CODIGO
            lRet := .T.
        EndIf 

        (cAliasQry)->(DbCloseArea())
    EndIf 

Return lRet 
