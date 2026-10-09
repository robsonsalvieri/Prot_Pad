#include 'Mdta184.ch'
#include 'totvs.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184
Cadastro de limites de exposição

@author Eloisa Anibaletto
@since 08/04/2026

/*/
//---------------------------------------------------------------------
Function Mdta184()

    Local bLegenda := { || Posicione( 'TL4', 1, FwxFilial( 'TL4' ) + TL1->TL1_CODAVA, 'TL4_LIMTOL' ) }

    Local oBrowse  := Nil

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        aRotina := {}

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias( 'TL1' )
        oBrowse:SetMenuDef( 'Mdta184' )
        oBrowse:SetDescription( STR0001 ) // "Limite Exposição"
        oBrowse:AddLegend( { || Eval( bLegenda ) == '1' }, 'GREEN', STR0027 ) // "Dentro do limite de tolerância"
		oBrowse:AddLegend( { || Eval( bLegenda ) == '2' }, 'RED'  , STR0028 ) // "Excedeu o limite de tolerância"
        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Eloisa Anibaletto
@since 08/04/2026

@return aRotina, Array, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta184' , 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.Mdta184' , 0, 3, 0 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.Mdta184' , 0, 4, 0 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.Mdta184' , 0, 5, 0 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'ViewDef.Mdta184' , 0, 8, 0 } ) // "Imprimir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Eloisa Anibaletto
@since 08/04/2026

@return oModel, Objeto, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTL1 := FWFormStruct( 1, 'TL1' )
	Local oStructTL2 := FWFormStruct( 1, 'TL2' )
	Local oStructTL3 := FWFormStruct( 1, 'TL3' )
    Local oStructTL4 := FWFormStruct( 1, 'TL4' )
	Local oModel     := MPFormModel():New( 'Mdta184', Nil, { | oModel | fMdta184Val( oModel ) } )

    // Adiciona um componente de formulário e os componentes das abas inferiores
    oModel:AddFields( 'TL1MASTER', Nil, oStructTL1 )
    oModel:AddGrid( 'TL2DETAIL', 'TL1MASTER', oStructTL2 )
    oModel:AddGrid( 'TL3DETAIL', 'TL1MASTER', oStructTL3 )
    oModel:AddFields( 'TL4DETAIL', 'TL1MASTER', oStructTL4 )

    // Valida repetição nas grids
    oModel:GetModel( 'TL2DETAIL' ):SetUniqueLine( { 'TL2_NUMRIS' } )
	oModel:GetModel( 'TL3DETAIL' ):SetUniqueLine( { 'TL3_CODTAR' } )

    // Relacionamento entre os componentes do modelo
    oModel:SetRelation( 'TL2DETAIL', { { 'TL2_FILIAL', 'FwxFilial( "TL2" )' }, { 'TL2_CODAVA', 'TL1_CODAVA' } }, TL2->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'TL3DETAIL', { { 'TL3_FILIAL', 'FwxFilial( "TL3" )' }, { 'TL3_CODAVA', 'TL1_CODAVA' } }, TL3->( IndexKey( 1 ) ) )
    oModel:SetRelation( 'TL4DETAIL', { { 'TL4_FILIAL', 'FwxFilial( "TL4" )' }, { 'TL4_CODAVA', 'TL1_CODAVA' } }, TL4->( IndexKey( 1 ) ) )

    // Descrições
    oModel:SetDescription( STR0001 ) // Limite Exposição
    oModel:GetModel( 'TL2DETAIL' ):SetDescription( STR0007 ) // Risco
    oModel:GetModel( 'TL3DETAIL' ):SetDescription( STR0008 ) // Tarefas
    oModel:GetModel( 'TL4DETAIL' ):SetDescription( STR0009 ) // Cálculo Limite Exposição

    oModel:SetPrimaryKey( { 'TL1_FILIAL', 'TL1_CODAVA' } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Eloisa Anibaletto
@since 08/04/2026

@return oView, Objeto, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel     := FWLoadModel( 'Mdta184' )
    Local oStructTL1 := FWFormStruct( 2, 'TL1' )
	Local oStructTL2 := FWFormStruct( 2, 'TL2' )
	Local oStructTL3 := FWFormStruct( 2, 'TL3' )
    Local oStructTL4 := FWFormStruct( 2, 'TL4' )

    Local oView      := FWFormView():New()

    oView:SetModel( oModel )

    // Adiciona na View controle do tipo formulário e grid
    oView:AddField( 'VIEW_TL1', oStructTL1, 'TL1MASTER' )
    oView:AddGrid( 'VIEW_TL2', oStructTL2, 'TL2DETAIL' )
    oView:AddGrid( 'VIEW_TL3', oStructTL3, 'TL3DETAIL' )
    oView:AddField( 'VIEW_TL4', oStructTL4, 'TL4DETAIL' )

    // Cria box horizontal para receber os elementos da View
    oView:CreateHorizontalBox( 'SUPERIOR', 40 )
    oView:CreateHorizontalBox( 'INFERIOR', 60 )

    // Cria as abas da parte inferior
    oView:CreateFolder( 'FOLDER','INFERIOR' )
	oView:AddSheet( 'FOLDER', 'ABA01', STR0007 ) // Risco
	oView:AddSheet( 'FOLDER', 'ABA02', STR0008 ) // Tarefas
    oView:AddSheet( 'FOLDER', 'ABA03', STR0009 ) // Cálculo Limite Exposição

    // Cria box horizontal para receber os elementos dentro das abas
    oView:CreateHorizontalBox( 'INFERIOR1', 100,,, 'FOLDER', 'ABA01' )
	oView:CreateHorizontalBox( 'INFERIOR2', 100,,, 'FOLDER', 'ABA02' )
    oView:CreateHorizontalBox( 'INFERIOR3', 100,,, 'FOLDER', 'ABA03' )

    // Relaciona o ID da View com o box
    oView:SetOwnerView( 'VIEW_TL1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_TL2', 'INFERIOR1' )
	oView:SetOwnerView( 'VIEW_TL3', 'INFERIOR2' )
    oView:SetOwnerView( 'VIEW_TL4', 'INFERIOR3' )

    // Adiciona botões ao Ações Relacioandas
    oView:AddUserButton( STR0025, STR0025, { || fCalcLim() }, Nil, Nil, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) // "Calcular Limite Exposição"
	oView:AddUserButton( STR0026, STR0026, { || fTelFunExp()}, Nil, Nil, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) // "Funcionários expostos"

    // Campos removidos da tela
    oStructTL2:RemoveField( 'TL2_CODAVA' )
	oStructTL3:RemoveField( 'TL3_CODAVA' )
    oStructTL4:RemoveField( 'TL4_CODAVA' )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMdta184Val
Pós-validação do modelo de dados.

@author Eloisa Anibaletto
@since 10/04/2026

@param oModel, Objeto, Objeto do modelo de dados

@return lRet, Lógico, Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMdta184Val( oModel )

    Local lRet := .T.

    If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

        // Valida o campo minutos
        lRet := fValMinu( oModel )

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184Grid
Função usada para retornar valores das grids para filtro na consulta 
padrão TN5LT e para tela de funcionários expostos

@author Eloisa Anibaletto
@since 10/04/2026

@param nTipo, Numérico, Conforme local chamado retorna um tipo de 
filtro

@return cFiltro, Caractere, Retorna filtro para consulta padrão TN5LT
/*/
//---------------------------------------------------------------------
Function Mdta184Grid( nTipo )

    Local cAliasTN5 := GetNextAlias()  
    Local cCodTar   := ''
    Local cFiltro   := ''
    Local cRisco    := ''

    Local nRisco    := 0
    Local nTar      := 1

    Local oModel    := FWModelActivate()
    Local oGrid     := oModel:GetModel( 'TL2DETAIL' )

    If oGrid:Length() > 1

	    For nRisco := 1 to oGrid:Length()

            oGrid:GoLine( nRisco )

            If nRisco != 1
                cRisco += "', '"
            EndIf

            cRisco += oGrid:GetValue( 'TL2_NUMRIS' ) 

        Next nRisco

    Else
        cRisco := oGrid:GetValue( 'TL2_NUMRIS' )
    EndIf

    BeginSQL Alias cAliasTN5
		SELECT DISTINCT
            TN5.TN5_CODTAR
		FROM
            %Table:TN5% TN5
        INNER JOIN %table:TN0% TN0 ON
            TN0.TN0_FILIAL = %xFilial:TN0% 
            AND TN0.TN0_NUMRIS IN( %exp:cRisco% )
            AND ( TN0.TN0_CODTAR = TN5.TN5_CODTAR OR TN0.TN0_CODTAR = '*' )
            AND TN0.%notDel%
		WHERE TN5.TN5_FILIAL = %xFilial:TN5%
            AND TN5.%notDel%
	EndSQL

    ( cAliasTN5 )->( DbGoTop() )

    While ( cAliasTN5 )->( !Eof() )

        If nTar > 1
            cCodTar += "', '"
        EndIf

        cCodTar += ( cAliasTN5 )->( TN5_CODTAR )

        nTar ++

        ( cAliasTN5 )->( DbSkip() )

    End

    ( cAliasTN5 )->( DbCloseArea() )

    If nTipo == 1
        cFiltro  := cCodTar
    ElseIf nTipo == 2
        cFiltro  := cRisco
    Else
        cFiltro  := '@# TN5->TN5_CODTAR $ "' + cCodTar + '"@#'
    EndIf

Return cFiltro 

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184X3R
Função utilizada no X3_RELACAO dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@param, cCampo, Caractere, Campo passado para validar

@return xValor, Retorna valor conforme operação
/*/
//---------------------------------------------------------------------
Function Mdta184X3R( cCampo )

    Local xValor := ''

    If Inclui
        Do Case
            Case cCampo == 'TL1_NOMAGE'
                xValor := ''
            Case cCampo == 'TL1_DESEQP'
                xValor := ''
            Case cCampo == 'TL3_NOMTAR'
                xValor := ''
        End Case
    Else
        Do Case
            Case cCampo == 'TL1_NOMAGE'
                xValor := Posicione( 'TMA', 1, FwxFilial( 'TMA' ) + TL1->TL1_AGENTE, 'TMA_NOMAGE' ) 
            Case cCampo == 'TL1_DESEQP'
                xValor := Posicione( 'TM7', 1, FwxFilial( 'TM7' ) + TL1->TL1_EQPTO, 'TM7_NOEQTO' )  
            Case cCampo == 'TL3_NOMTAR'
                xValor := Posicione( 'TN5', 1, FwxFilial( 'TN5' ) + TL3->TL3_CODTAR, 'TN5_NOMTAR' )
        End Case
    EndIf

Return xValor

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184X3V
Função utilizada no X3_VALID dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@param, cCampo, Caractere, Campo passado para validar

@return lRet, Lógico, Retorno da validação do campo
/*/
//---------------------------------------------------------------------
Function Mdta184X3V( cCampo )

    Local oModel    := FWModelActivate()
    Local oModelTL1 := oModel:GetModel( 'TL1MASTER' )
    Local oGridTL2  := oModel:GetModel( 'TL2DETAIL' )
    Local oGridTL3  := oModel:GetModel( 'TL3DETAIL' )
    Local oModelTL4 := oModel:GetModel( 'TL4DETAIL' )

    Local lRet := .T.

    Do Case
        Case cCampo == 'TL1_AGENTE'
            lRet := ExistCPO( 'TMA', oModelTL1:GetValue( 'TL1_AGENTE' ) )
        Case cCampo == 'TL1_DTAVAL'
            fValData( @lRet, oModelTL1:GetValue( 'TL1_DTAVAL' ) )
        Case cCampo == 'TL1_HRAVAL'
            fValHora( @lRet, oModelTL1:GetValue( 'TL1_HRAVAL' ) )
        Case cCampo == 'TL1_EQPTO'
            lRet := ExistCPO( 'TM7', oModelTL1:GetValue( 'TL1_EQPTO' ) )
        Case cCampo == 'TL2_NUMRIS'
            lRet := ExistCPO( 'TN0', oGridTL2:GetValue( 'TL2_NUMRIS' ) )
        Case cCampo == 'TL3_CODTAR'
            fValTar( @lRet, oGridTL3:GetValue( 'TL3_CODTAR' ) )
        Case cCampo == 'TL3_TIPAMB'
            fValTipAmb( @lRet, oGridTL3, oGridTL3:GetValue( 'TL3_TIPAMB' ) )
        Case cCampo == 'TL3_TBN'
            fValTbn( oGridTL3, oModelTL4 )
        Case cCampo == 'TL3_TG'
            fValTg( @lRet, oGridTL3:GetValue( 'TL3_TIPAMB' ), oGridTL3:GetValue( 'TL3_TBN' ), oGridTL3, oModelTL4 )
        Case cCampo == 'TL3_TBS'
            fValTbs( @lRet, oGridTL3:GetValue( 'TL3_TIPAMB' ), oGridTL3:GetValue( 'TL3_TBN' ), oGridTL3:GetValue( 'TL3_TG' ), oGridTL3:GetValue( 'TL3_TBS' ), oGridTL3, oModelTL4 )
    End Case

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184X3W
Função utilizada no X3_WHEN dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@return lRet, Lógico, Retorno da validação do campo
/*/
//---------------------------------------------------------------------
Function Mdta184X3W( cCampo )

    Local oModel  := FWModelActivate()
    Local oGrid   := oModel:GetModel( 'TL3DETAIL' )

    Local cTipAmb := oGrid:GetValue( 'TL3_TIPAMB' )

    Local lRet    := .T.

    If cCampo == 'TL3_TBS'

        If cTipAmb $ '1'

            lRet := .F.

        EndIf

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValTar
Função para validar o campo do código da tarefa

@author Eloisa Anibaletto
@since 10/04/2026

@param, lRet, Lógico, retorno lógico conforme validação
@param, cCodTar, Caractere, código da tarefa

/*/
//---------------------------------------------------------------------
Static Function fValTar( lRet, cCodTar )

    Local cTaxaTar := Posicione( 'TLU', 1, FwxFilial( 'TLU' ) + cCodTar, 'TLU_CODTAX' )

    If Empty( cTaxaTar )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Esta tarefa não possui taxa metabólica vinculada!"
        // "É necessário selecionar uma tarefa que possua taxa metabólica vinculada."
        // "Para vincular acesse a rotina de Tarefas do Funcionário (MDTA090) posicione na tarefa desejada, clique em Outras Ações > Taxa Metabólica x Tarefa."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0031, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0032 + Chr( 13 ) + STR0033 } )

        lRet := .F.

    ElseIf !ExistCPO( 'TN5', M->TL3_CODTAR )

        lRet := .F.

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValTipAmb
Função para validar campo tipo do ambiente

@author Eloisa Anibaletto
@since 08/05/2026

@param, lRet, Lógico, retorno passado por parametro

/*/
//---------------------------------------------------------------------
Static Function fValTipAmb( lRet, oGrid, cTipAmb )

    If Empty( cTipAmb )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Campo Tipo Ambiente (TL3_TIPAMB) não pode ser vazio!"
        // "Favor selecionar um dos valores disponíveis no campo Tipo Ambiente (TL3_TIPAMB)."
        //----------------------------------------------
        Help( Nil, Nil, STR0010, Nil, STR0036, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0037 } )

        lRet := .F.

    EndIf

    // Caso tenha alterado o campo zera os campos dependetes
    If oGrid:IsFieldUpdated( 'TL3_TIPAMB' )

        oGrid:LoadValue( 'TL3_TG', 0 )
        oGrid:LoadValue( 'TL3_TBN', 0 )
        oGrid:LoadValue( 'TL3_TBS', 0 )
        oGrid:LoadValue( 'TL3_IBUTG', 0 )

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValMinu
Função para calcular os minutos e validar se o campo 
Minutos (TL3_MINUTO) esta dentro dos 60 minutos necessários para 
o cálculo

@author Eloisa Anibaletto
@since 10/04/2026

@param, oModel, Objeto, Objeto do modelo de dados 

@return lRet, Lógico, Retorno falso caso valor dos minutos não for 
60 minutos
/*/
//---------------------------------------------------------------------
Static Function fValMinu( oModel )

    Local lRet    := .T.

    Local nMinTar := 0
    Local nTarefa := 0

    Local oGrid   := oModel:GetModel( 'TL3DETAIL' )     

    If oGrid:Length() > 0

        For nTarefa := 1 to oGrid:Length()

            oGrid:GoLine( nTarefa )

            nMinTar += oGrid:GetValue( 'TL3_MINUTO' )

        Next nTarefa

        If nMinTar != 60

            If nMinTar > 60

                //----------------------------------------------
                // Mensagens:
                // "Atenção"
                // "O valor ou a soma do campo Minuto (TL3_MINUTO) trabalhado(s) na(s) tarefa(s) selecionada(s) é superior a 60!"
                // "Conforme a NR-15 para os cálculos do limite de exposição, o(s) minuto(s) deve(m) ter um total de 60 minutos. "
                // "Portanto ajuste o(s) campo(s) Minuto (TL3_MINUTO) para que possua um total de 60 minutos na(s) tarefa(s) selecionda(s)."
                //----------------------------------------------

                Help( Nil, Nil, STR0010, Nil, STR0020 + STR0021, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0023 + Chr( 13 ) + STR0024 } )

                lRet := .F.

            ElseIf nMinTar < 60

                //----------------------------------------------
                // Mensagens:
                // "Atenção"
                // "O valor ou a soma do campo Minuto (TL3_MINUTO) trabalhado(s) na(s) tarefa(s) selecionada(s) é inferior a 60!"
                // "Conforme a NR-15 para os cálculos do limite de exposição, o(s) minuto(s) deve(m) ter um total de 60 minutos. "
                // "Portanto ajuste o(s) campo(s) Minuto (TL3_MINUTO) para que possua um total de 60 minutos na(s) tarefa(s) selecionda(s)."
                //----------------------------------------------

                Help( Nil, Nil, STR0010, Nil, STR0020 + STR0022, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0023 + Chr( 13 ) + STR0024 } )

                lRet := .F.

            EndIf

        EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValData
Valida o campo de data

@author Eloisa Anibaletto
@since 20/04/2026

@param, lRet, Lógico, retorno lógico conforme validação
@param, dData, Data, data informada ao chamar função

/*/
//-------------------------------------------------------------------
Static Function fValData( lRet, dData )

    If !Empty( dData ) .And. dData > dDataBase

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Data inválida!"
        // "A data não pode ser maior que a data atual."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0011, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0012 } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValHora
Valida o campo de hora

@author Eloisa Anibaletto
@since 20/04/2026

@param, lRet, retorno lógico conforme vaidação
@param, dData, data informada ao chamar função

/*/
//-------------------------------------------------------------------
Static Function fValHora( lRet, cHora )

    Local nPont   := At( ':', cHora )
    Local nHora   := Val( SubStr( cHora, 1, ( nPont - 1 ) ) )
    Local nMinuto := Val( SubStr( cHora, ( nPont + 1 ) ) )

    If '-' $ cHora

        //---------------------------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Hora inválida!"
        // "Sinal incorreto."
        //---------------------------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0013, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0014 } )

        lRet := .F.

    ElseIf ( nHora > 24 .Or. nMinuto > 59 ) .Or. Len( AllTrim( cHora ) ) < 5

        //---------------------------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Hora inválida!"
        // "Informe uma hora válida."
        //---------------------------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0013, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0015 } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValTbn
Valida o campo TBN (TL3_TBN)

@author Eloisa Anibaletto
@since 11/05/2026

@param, oGrid, Objeto, objeto da aba TL3
@param, oModelTL4, Objeto, objeto da aba TL4
/*/
//-------------------------------------------------------------------
Static Function fValTbn( oGrid, oModelTL4 )

    // Valida primeiro caso alterar o TBN limpa valores da TL3 para forçar a refazer o cálculo
    If oGrid:IsFieldUpdated( 'TL3_TBN' ) .And. !Empty( oGrid:GetValue( 'TL3_IBUTG' ) )

        oGrid:LoadValue( 'TL3_TG', 0 )
        oGrid:LoadValue( 'TL3_IBUTG', 0 )

        If !Empty( oGrid:GetValue( 'TL3_TBS' ) )

            oGrid:LoadValue( 'TL3_TBS', 0 )

        EndIf

    EndIf

    // Após valida também caso alterar o TBN se já possui limite calculado e limpa valores TL4
    // para forçar a refazer o cálculo
    If oGrid:IsFieldUpdated( 'TL3_TBN' ) .And. !Empty( oModelTL4:GetValue( 'TL4_LIMTOL' ) )

        oModelTL4:LoadValue( 'TL4_IBUTGM', 0 )
        oModelTL4:LoadValue( 'TL4_MEDTAX', 0 )
        oModelTL4:LoadValue( 'TL4_LIMTOL', 0 )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValTg
Valida o campo TG (TL3_TG)

@author Eloisa Anibaletto
@since 20/04/2026

@param, lRet, Lógico, retorno lógico conforme validação
@param, cTipAmb, Caracter, valor do campo Tipo Ambiente (TL3_TIPAMB)
@param, cTbn, Caracter, valor do campo TBN (TL3_TBN)
@param, oGrid, Objeto, objeto da aba TL3
@param, oModelTL4, Objeto, objeto da aba TL4
/*/
//-------------------------------------------------------------------
Static Function fValTg( lRet, cTipAmb, cTbn, oGrid, oModelTL4 )

    If Empty( cTbn )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Campo TBN (TL3_TBN) não preenchido!"
        // "Favor preencher primeiro o campo TBN (TL3_TBN)."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0016, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0017 } )

        lRet := .F.

    ElseIf cTipAmb == '1'

        fCalIbutg( 1, cTbn, M->TL3_TG )

        lRet := .T.

    EndIf

    // Valida caso alterar o TG limpa valores da TL4 para forçar a refazer o cálculo
    If oGrid:IsFieldUpdated( 'TL3_TG' ) .And. !Empty( oModelTL4:GetValue( 'TL4_LIMTOL' ) )

        oModelTL4:LoadValue( 'TL4_IBUTGM', 0 )
        oModelTL4:LoadValue( 'TL4_MEDTAX', 0 )
        oModelTL4:LoadValue( 'TL4_LIMTOL', 0 )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValTbs
Valida o campo TBS (TL3_TBS)

@author Eloisa Anibaletto
@since 20/04/2026

@param, lRet, Lógico, retorno lógico conforme validação
@param, cTipAmb, Caracter, valor do campo Tipo Ambiente (TL3_TIPAMB)
@param, cTbn, Caracter, valor do campo TBN (TL3_TBN)
@param, cTg, Caracter, valor do campo TG (TL3_TG)
@param, cTbs, Caracter, valor do campo TBS (TL3_TBS)
@param, oGrid, Objeto, Modelo da aba TL3
@param, oModelTL4, Objeto, objeto da aba TL4
/*/
//-------------------------------------------------------------------
Static Function fValTbs( lRet, cTipAmb, cTbn, cTg, cTbs, oGrid, oModelTL4 )

    If Empty( cTbn )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Campo TBN (TL3_TBN) não preenchido!"
        // "Favor preencher primeiro o campo TBN (TL3_TBN)."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0016, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0017 } )

        lRet := .F.

    ElseIf Empty( cTg )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Campo TG (TL3_TG) não preenchido!"
        // "Favor preencher primeiro o campo TG (TL3_TG)."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0018, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0019 } )

        lRet := .F.

    ElseIf cTipAmb == '2' .And. Empty( cTbs )

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Campo TBS (TL3_TBS) não preenchido!"
        // "Favor preencher primeiro o campo TBS (TL3_TBS)."
        //----------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0034, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0035 } )

        lRet := .F.

    Else

        fCalIbutg( 2, cTbn, cTg, M->TL3_TBS )

        lRet := .T.

    EndIf

    // Valida caso alterar o TBS limpa valores da TL4 para forçar a refazer o cálculo
    If oGrid:IsFieldUpdated( 'TL3_TBS' ) .And. !Empty( oModelTL4:GetValue( 'TL4_LIMTOL' ) )

        oModelTL4:LoadValue( 'TL4_IBUTGM', 0 )
        oModelTL4:LoadValue( 'TL4_MEDTAX', 0 )
        oModelTL4:LoadValue( 'TL4_LIMTOL', 0 )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCalIbutg
Cálculo do IBUTG individual por tarefa

@author Eloisa Anibaletto
@since 20/04/2026

@param, nTipAmb, Númerico, Tipo do Ambiente conforme informado no 
parametro
@param, cTbn, Caracter, valor do campo TBN (TL3_TBN)
@param, cTg, Caracter, valor do campo TG (TL3_TG)
@param, cTbs, Caracter, valor do campo TBS (TL3_TBS)
/*/
//-------------------------------------------------------------------
Static Function fCalIbutg( nTipAmb, cTbn, cTg, cTbs )

    Local nIbutg := ''

    Local oModel := FWModelActivate()
    Local oGrid  := oModel:GetModel( 'TL3DETAIL' )

    // Se for ambiente interno
    If nTipAmb == 1

        nIbutg := ( 0.7 * cTbn ) + ( 0.3 * cTg )

        oGrid:LoadValue( 'TL3_IBUTG', nIbutg )

    // Se for ambiente externo
    ElseIf nTipAmb == 2

        nIbutg := ( 0.7 * cTbn ) + ( 0.2 * cTg ) + ( 0.1 * cTbs )

        oGrid:LoadValue( 'TL3_IBUTG', nIbutg )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCalcLim
Cálculo final do IBUTG Médico e Taxa Metabólica Médica para 
determinar o limite de exposição

@author Eloisa Anibaletto
@since 20/04/2026
/*/
//-------------------------------------------------------------------
Static Function fCalcLim()

    Local nCalcTaxa  := 0
    Local nPosLim    := 0
    Local nTarefas   := 0
    Local nTaxa      := 0
    Local nTotTaxa   := 0
    Local nIbutg     := 0
    Local nTotIbutg  := 0
    Local nCalcIbutg := 0

    Local oModel     := FWModelActivate()
    Local oGridTL3   := oModel:GetModel( 'TL3DETAIL' )
    Local oGridTL4   := oModel:GetModel( 'TL4DETAIL' )

    Local aTabLim    := { { 100, 33.7 }, { 102, 33.6 }, { 104, 33.5 }, { 106, 33.4 }, { 108, 33.3 }, ;
                        { 110, 33.2 }, { 112, 33.1 }, { 115, 33.0 }, { 117, 32.9 }, { 119, 32.8 }, ;
                        { 122, 32.7 }, { 124, 32.6 }, { 127, 32.5 }, { 129, 32.4 }, { 132, 32.3 }, ;
                        { 135, 32.2 }, { 137, 32.1 }, { 140, 32.0 }, { 143, 31.9 }, { 146, 31.8 }, ;
                        { 149, 31.7 }, { 152, 31.6 }, { 155, 31.5 }, { 158, 31.4 }, { 161, 31.3 }, ;
                        { 165, 31.2 }, { 168, 31.1 }, { 171, 31.0 }, { 175, 30.9 }, { 178, 30.8 }, ;
                        { 182, 30.7 }, { 186, 30.6 }, { 189, 30.5 }, { 193, 30.4 }, { 197, 30.3 }, ;
                        { 201, 30.2 }, { 205, 30.1 }, { 209, 30.0 }, { 214, 29.9 }, { 218, 29.8 }, ;
                        { 222, 29.7 }, { 227, 29.6 }, { 231, 29.5 }, { 236, 29.4 }, { 241, 29.3 }, ;
                        { 246, 29.2 }, { 251, 29.1 }, { 256, 29.0 }, { 261, 28.9 }, { 266, 28.8 }, ;
                        { 272, 28.7 }, { 277, 28.6 }, { 283, 28.5 }, { 289, 28.4 }, { 294, 28.3 }, ;
                        { 300, 28.2 }, { 306, 28.1 }, { 313, 28.0 }, { 319, 27.9 }, { 325, 27.8 }, ;
                        { 332, 27.7 }, { 339, 27.6 }, { 346, 27.5 }, { 353, 27.4 }, { 360, 27.3 }, ;
                        { 367, 27.2 }, { 374, 27.1 }, { 382, 27.0 }, { 390, 26.9 }, { 398, 26.8 }, ;
                        { 406, 26.7 }, { 414, 26.6 }, { 422, 26.5 }, { 431, 26.4 }, { 440, 26.3 }, ;
                        { 448, 26.2 }, { 458, 26.1 }, { 467, 26.0 }, { 476, 25.9 }, { 486, 25.8 }, ;
                        { 496, 25.7 }, { 506, 25.6 }, { 516, 25.5 }, { 526, 25.4 }, { 537, 25.3 }, ;
                        { 548, 25.2 }, { 559, 25.1 }, { 570, 25.0 }, { 582, 24.9 }, { 594, 24.8 }, ;
                        { 606, 24.7 } }

    If oGridTL3:Length() > 1

        For nTarefas := 1 to oGridTL3:Length()

            oGridTL3:GoLine( nTarefas )

            nIbutg := oGridTL3:GetValue( 'TL3_IBUTG' ) * oGridTL3:GetValue( 'TL3_MINUTO' )
            nTotIbutg += nIbutg

            nTaxa := oGridTL3:GetValue( 'TL3_TAXAME' ) * oGridTL3:GetValue( 'TL3_MINUTO' )
            nTotTaxa += nTaxa

        Next nTarefas 

        nCalcIbutg := NoRound( nTotIbutg / 60, 1 )
        nCalcTaxa := NoRound( nTotTaxa / 60, 1 )

        oGridTL4:LoadValue( 'TL4_IBUTGM', nCalcIbutg )
        oGridTL4:LoadValue( 'TL4_MEDTAX', nCalcTaxa  )

        nPosLim := aScan( aTabLim, { |x| x[ 1 ] >= nCalcTaxa } )

        If nCalcIbutg > aTabLim[ nPosLim ][ 2 ]  
            oGridTL4:LoadValue( 'TL4_LIMTOL', '2' ) // "Excedeu o limite de tolerância"
        Else
            oGridTL4:LoadValue( 'TL4_LIMTOL', '1' ) // "Dentro do limite de tolerância"
        EndIf

    Else

        // Caso for apenas uma atividade não faz calculo de média, apenas compara com os valores inseridos
        nCalcIbutg := oGridTL3:GetValue( 'TL3_IBUTG' )
        nCalcTaxa := oGridTL3:GetValue( 'TL3_TAXAME' )

        oGridTL4:LoadValue( 'TL4_IBUTGM', nCalcIbutg )
        oGridTL4:LoadValue( 'TL4_MEDTAX', nCalcTaxa )

        nPosLim := aScan( aTabLim, { |x| x[ 1 ] >= nCalcTaxa } )

        If nCalcIbutg > aTabLim[ nPosLim ][ 2 ]  
            oGridTL4:LoadValue( 'TL4_LIMTOL', '2' ) // "Excedeu o limite de tolerância"
        Else
            oGridTL4:LoadValue( 'TL4_LIMTOL', '1' ) // "Dentro do limite de tolerância"
        EndIf

    EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} fTelFunExp
Cria tela com os funcionários expostos ao ambiente avaliado

@author Eloisa Anibaletto
@since 20/04/2026
/*/
//-------------------------------------------------------------------
Static Function fTelFunExp()

    Local aCampos    := {}

	Local cTarefas	 := Mdta184Grid( 1 )
    Local cRiscos	 := Mdta184Grid( 2 )
    Local cAliasSRA  := GetNextAlias()
    Local cTamData   := Space( 8 )

    Local oDlg       := Nil
    Local oPanel     := Nil

    Private aFunc    := {}
    Private oBrowFun := Nil

    BeginSQL Alias cAliasSRA
		SELECT DISTINCT
            SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA,
			SRA.RA_CC, SRA.RA_CODFUNC, SRA.RA_DEPTO,TN6.TN6_CODTAR, 
            TN0.TN0_CC, TN0.TN0_CODFUN, TN0.TN0_DEPTO
		FROM %Table:SRA% SRA
		INNER JOIN %Table:TN6% TN6 ON
		    TN6.TN6_FILIAL = %xFilial:TN6% 
			AND TN6.TN6_MAT = SRA.RA_MAT 
			AND TN6.TN6_CODTAR IN ( %exp:cTarefas% )
            AND TN6.TN6_DTTERM = %exp:cTamData%
			AND TN6.%notDel%
        INNER JOIN %Table:TN0% TN0 ON
		    TN0.TN0_FILIAL = %xFilial:TN0% 
			AND TN0.TN0_NUMRIS IN ( %exp:cRiscos% ) 
			AND TN0.%notDel%
		WHERE
			SRA.RA_FILIAL = %xFilial:SRA%
		    AND ( SRA.RA_CC = TN0.TN0_CC OR TN0.TN0_CC = '*' )
			AND ( SRA.RA_CODFUNC = TN0.TN0_CODFUN OR TN0.TN0_CODFUN = '*' )
			AND ( SRA.RA_DEPTO = TN0.TN0_DEPTO OR TN0.TN0_DEPTO = '*' )
			AND SRA.RA_SITFOLH != 'D' AND SRA.RA_DEMISSA = %exp:cTamData%
			AND SRA.%notDel%
	EndSQL

    ( cAliasSRA )->( DbGoTop() )

    While ( cAliasSRA )->( !Eof() )

        aAdd( aFunc, { ( cAliasSRA )->RA_MAT, ( cAliasSRA )->RA_NOME , ( cAliasSRA )->RA_CC, ( cAliasSRA )->RA_CODFUNC, ( cAliasSRA )->RA_DEPTO } )

        ( cAliasSRA )->( DbSkip() )

    End

    If Len( aFunc ) > 0

        aAdd( aCampos, fFieldCol( '{|| aFunc[oBrowFun:At(), 1 ] }' , .F., 'Matrícula'       , 12, '@!' ) )
        aAdd( aCampos, fFieldCol( '{|| aFunc[oBrowFun:At(), 2 ] }' , .F., 'Nome'            , 40, '@!' ) )
        aAdd( aCampos, fFieldCol( '{|| aFunc[oBrowFun:At(), 3 ] }' , .F., 'Centro de Custo' , 15, '@!' ) )
        aAdd( aCampos, fFieldCol( '{|| aFunc[oBrowFun:At(), 4 ] }' , .F., 'Função'          , 15, '@!' ) )
        aAdd( aCampos, fFieldCol( '{|| aFunc[oBrowFun:At(), 5 ] }' , .F., 'Departamento'    , 15, '@!' ) )

        oDlg := FWDialogModal():New()
        oDlg:SetTitle( STR0029 )  // Funcionários Expostos
        oDlg:SetSize( 300, 600 )
        oDlg:SetBackground( .T. )
        oDlg:SetEscClose( .T. )
        oDlg:EnableFormBar( .T. )
        oDlg:CreateDialog()
        oDlg:AddButton( 'Fechar', { || lOk:= .F., oDlg:Deactivate() }, 'Fechar', , .T., .T., .T., ) // "Fechar"

        oPanel := oDlg:GetPanelMain()

        oBrowFun:= FWFormBrowse():New()
        oBrowFun:SetDataArray()
        oBrowFun:SetOwner( oPanel )
        oBrowFun:SetDescription( STR0029 ) // Funcionários Expostos
        oBrowFun:SetArray( aFunc )
        oBrowFun:SetColumns( aCampos )
        oBrowFun:DisableReport()
        oBrowFun:DisableLocate()
        oBrowFun:DisableFilter()
        oBrowFun:Refresh( .T. )
        oBrowFun:Activate()

        oDlg:Activate()

    Else
        Help( Nil, Nil, STR0010, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0030 } )
    EndIf

    ( cAliasSRA )->( DbCloseArea() )

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} fFieldCol
Cria obejeto das colunas

@author Eloisa Anibaletto
@since 20/04/2026

@param  cData , Caracter, Valor do campo
@param  lEdit, Lógico, Define se é campo alterável
@param  cTitle, Caracter, Define título do campo
@param  nSize, Caracter, Define tamanho do campo
@param  cPict, Caracter, Define a picture do campo

@return oColuna, objeto, objeto da coluna
/*/
//--------------------------------------------------------------------------
Static Function fFieldCol( cData, lEdit, cTitle, nSize, cPict )
	
	Private oColuna

	oColuna := FWBrwColumn():New()
	oColuna:SetData( &( cData ) )
	oColuna:SetEdit( lEdit )
	oColuna:SetTitle( cTitle )
	oColuna:SetType( "C" )
	oColuna:SetSize( nSize )
	oColuna:SetPicture( cPict )
	oColuna:SetAlign( CONTROL_ALIGN_LEFT )

Return oColuna

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta184Cod
Função para gerar númeração do código do limite de exposição

@author Eloisa Anibaletto
@since 29/04/2026

@return cCodLim, Caractere, Retorna código disponível
/*/
//---------------------------------------------------------------------
Function Mdta184Cod()

    Local cCodLim := ''

    If Inclui

		cCodLim := GetSxEnum( 'TL1', 'TL1_CODAVA' )

	EndIf

Return cCodLim

