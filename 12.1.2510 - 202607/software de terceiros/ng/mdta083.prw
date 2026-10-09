#include 'Mdta083.ch'
#include 'totvs.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta083
Cadastro de taxas metabólicas

@author Eloisa Anibaletto
@since 10/04/2026

/*/
//---------------------------------------------------------------------
Function Mdta083()

	Private oBrowse := Nil

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'TLT' )
		oBrowse:SetMenuDef( 'Mdta083' )
		oBrowse:SetDescription( STR0001 ) // "Taxa Metabólica"
		oBrowse:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Eloisa Anibaletto
@since 10/04/2026

@return aRotina, Array, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta083' , 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.Mdta083' , 0, 3, 0 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.Mdta083' , 0, 4, 0 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.Mdta083' , 0, 5, 0 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'ViewDef.Mdta083' , 0, 8, 0 } ) // "Imprimir"

    If cPaisLoc == 'BRA'
        aAdd( aRotina, { STR0007, 'Processa( { || MdtaCarTax() } )' , 0, 3, 0 } ) // "Gerar Taxas"
    EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Eloisa Anibaletto
@since 10/04/2026

@return oModel, Objeto, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTLT := FWFormStruct( 1 ,'TLT' )

	Local oModel     := MPFormModel():New( 'Mdta083' )

	oModel:AddFields( 'TLTMASTER' , Nil , oStructTLT  )
    oModel:SetPrimaryKey( { 'TLT_FILIAL', 'TLT_CODTAX' } )
	oModel:SetDescription( STR0001 ) // "Taxa Metabólica"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                            
Definição da view

@author Eloisa Anibaletto
@since 10/04/2026

@return oView, Objeto, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( 'Mdta083' )
	
	Local oStructTLT := FWFormStruct( 2 , 'TLT' )
	
	Local oView      := FWFormView():New()

	oView:SetModel( oModel )

    // Adiciona na View controle do tipo formulário
	oView:AddField( 'VIEW_TLT' , oStructTLT , 'TLTMASTER' )

    // Cria box horizontal para receber o elemento da View
	oView:CreateHorizontalBox( 'TELATLT' , 100 )

    // Relaciona o ID da View com o box
	oView:SetOwnerView( 'VIEW_TLT' , 'TELATLT' )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta083X3R
Função utilizada no X3_RELACAO dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@param cCampo, Caractere, Campo passado por parâmetro

@return xValor, Retorna valor conforme operação
/*/
//---------------------------------------------------------------------
Function Mdta083X3R( cCampo )

    Local xValor := ''

    If Inclui

        If cCampo == 'TLT_CARGA'

            xValor := '2'

        ElseIf cCampo == 'TLT_PESVEL'

            xValor := '2'

        EndIf

    EndIf

Return xValor

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta083X3V
Função utilizada no X3_VALID dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@param cCampo, Caractere, Campo passado por parâmetro

@return lRet, Lógico, Retorno da validação do campo
/*/
//---------------------------------------------------------------------
Function Mdta083X3V( cCampo )

    Local lRet := .T.

    If cCampo == 'TLT_CARGA'

        lRet := Pertence( '12' )

    ElseIf cCampo == 'TLT_PESVEL'

        lRet := Pertence( '12' )

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta083X3W
Função utilizada no X3_WHEN dos campos da rotina

@author Eloisa Anibaletto
@since 10/04/2026

@param cCampo, Caractere, Campo passado por parâmetro

@return lRet, Lógico, Retorno da validação do campo
/*/
//---------------------------------------------------------------------
Function Mdta083X3W( cCampo )

    Local lRet      := .T.

    Local oModel    := FWModelActivate()
    Local oModelTLT	:= oModel:GetModel( 'TLTMASTER' )

   If cCampo == 'TLT_DESCAR'

        If oModelTLT:GetValue( 'TLT_CARGA' ) == '2'

            lRet := .F.

        EndIf

    ElseIf cCampo == 'TLT_DESCPV'

        If oModelTLT:GetValue( 'TLT_PESVEL' ) == '2'

            lRet := .F.

        EndIf

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta083Cod
Função para gerar númeração do código da taxa metabólica

@author Eloisa Anibaletto
@since 10/04/2026

@return cCodTax, Caractere, Retorna código disponível
/*/
//---------------------------------------------------------------------
Function Mdta083Cod()

    Local cCodTax := ''

    If Inclui

		cCodTax := GetSxEnum( 'TLT', 'TLT_CODTAX' )

	EndIf

Return cCodTax

//---------------------------------------------------------------------
/*/{Protheus.doc} MdtaCarTax
Função para gerar as taxas metabólicas conforme tabela da NR-15

@author Eloisa Anibaletto
@since 10/04/2026

/*/
//---------------------------------------------------------------------
Function MdtaCarTax()

                        // Padrão do array conforme os campos que vai popular
                        // TLT_CODTAX, TLT_POSTU, TLT_ACAO, TLT_CARGA, TLT_DESCAR, TLT_PESVEL, TLT_DESCPV, TLT_TAXAME
    Local aTaxaMet  :=  {  { 'Sentado','Em repouso','2','','2','',100 },;
                        { 'Sentado','Trabalho leve com as mãos','2','','2','',126 },;
                        { 'Sentado','Trabalho moderado com as mãos','2','','2','',153 },;
                        { 'Sentado','Trabalho pesado com as mãos','2','','2','',171 },;
                        { 'Sentado','Trabalho leve com um braço','2','','2','',162 },;
                        { 'Sentado','Trabalho moderado com um braço','2','','2','',198 },;
                        { 'Sentado','Trabalho pesado com um braço','2','','2','',234 },;
                        { 'Sentado','Trabalho leve com dois braços','2','','2','',216 },;
                        { 'Sentado','Trabalho moderado com dois braços','2','','2','',252 },;
                        { 'Sentado','Trabalho pesado com dois braços','2','','2','',288 },;
                        { 'Sentado','Trabalho leve com braços e pernas','2','','2','',324 },;
                        { 'Sentado','Trabalho moderado com braços e pernas','2','','2','',441 },;
                        { 'Sentado','Trabalho pesado com braços e pernas','2','','2','',603 },;
                        { 'Em pé, agachado ou ajoelhado','Em repouso','2','','2','',126 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho leve com as mãos','2','','2','',153 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho moderado com as mãos','2','','2','',180 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho pesado com as mãos','2','','2','',198 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho leve com um braço','2','','2','',189 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho moderado com um braço','2','','2','',225 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho pesado com um braço','2','','2','',261 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho leve com dois braços','2','','2','',243 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho moderado com dois braços','2','','2','',279 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho pesado com dois braços','2','','2','',315 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho leve com o corpo','2','','2','',351 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho moderado com o corpo','2','','2','',468 },;
                        { 'Em pé, agachado ou ajoelhado','Trabalho pesado com o corpo','2','','2','',630 },;
                        { 'Em pé, em movimento','Andando no plano','2','','1','2 km/h',198 },;
                        { 'Em pé, em movimento','Andando no plano','2','','1','3 km/h',252 },;
                        { 'Em pé, em movimento','Andando no plano','2','','1','4 km/h',297 },;
                        { 'Em pé, em movimento','Andando no plano','2','','1','5 km/h',360 },;
                        { 'Em pé, em movimento','Andando no plano','1','10 kg','1','4 km/h',333 },;
                        { 'Em pé, em movimento','Andando no plano','1','30 kg','1','4 km/h',450 },;
                        { 'Em pé, em movimento','Correndo no plano','2','','1','9 km/h',787 },;
                        { 'Em pé, em movimento','Correndo no plano','2','','1','12 km/h',873 },;
                        { 'Em pé, em movimento','Correndo no plano','2','','1','15 km/h',990 },;
                        { 'Em pé, em movimento','Subindo rampa','2','','1','com 5° de inclinação, 4 km/h',324 },;
                        { 'Em pé, em movimento','Subindo rampa','2','','1','com 15° de inclinação, 3 km/h',378 },;
                        { 'Em pé, em movimento','Subindo rampa','2','','1','com 25° de inclinação, 3 km/h',540 },;
                        { 'Em pé, em movimento','Subindo rampa','1','20 kg','1','com 15° de inclinação, 4 km/h',486 },;
                        { 'Em pé, em movimento','Subindo rampa','1','20 kg','1','com 25° de inclinação, 4 km/h',738 },;
                        { 'Em pé, em movimento','Descendo rampa (5 km/h) sem carga','2','','1','com 5° de inclinação',243 },;
                        { 'Em pé, em movimento','Descendo rampa (5 km/h) sem carga','2','','1','com 15° de inclinação',252 },;
                        { 'Em pé, em movimento','Descendo rampa (5 km/h) sem carga','2','','1','com 25° de inclinação',324 },;
                        { 'Em pé, em movimento','Subindo escada (80 degraus por minuto - altura do degrau de 0,17 m)','2','','2','',522 },;
                        { 'Em pé, em movimento','Subindo escada (80 degraus por minuto - altura do degrau de 0,17 m)','1','20 kg','2','',648 },;
                        { 'Em pé, em movimento','Descendo escada (80 degraus por minuto - altura do degrau de 0,17 m)','2','','2','',279 },;
                        { 'Em pé, em movimento','Descendo escada (80 degraus por minuto - altura do degrau de 0,17 m)','1','20 kg','2','',400 },;
                        { 'Em pé, em movimento','Trabalho moderado de braços (ex.: varrer, trabalho em almoxarifado)','2','','2','',320 },;
                        { 'Em pé, em movimento','Trabalho moderado de levantar ou empurrar','2','','2','',349 },;
                        { 'Em pé, em movimento','Trabalho de empurrar carrinhos de mão, no mesmo plano, com carga','1','','2','',391 },;
                        { 'Em pé, em movimento','Trabalho de carregar pesos ou com movimentos vigorosos com os braços (ex.: trabalho com foice)','2','','2','',495 },;
                        { 'Em pé, em movimento','Trabalho pesado de levantar, empurrar ou arrastar pesos (ex.: remoção com pá, abertura de valas)','2','','2','',524 } }

    Local nTaxa     := 0
    Local cCod      := ''
    Local cFilTLT   := FwxFilial( 'TLT' )

    dbSelectArea( 'TLT' )
    dbSetOrder( 1 )
    ProcRegua( Len( aTaxaMet ) )
    For nTaxa := 1 to Len( aTaxaMet )

        IncProc( STR0008 )

        cCod := GetSxEnum( 'TLT', 'TLT_CODTAX' )
        ConfirmSX8()

        RecLock( 'TLT', .T. )
            TLT->TLT_FILIAL := cFilTLT
            TLT->TLT_CODTAX := cCod
            TLT->TLT_POSTU  := aTaxaMet[ nTaxa, 1 ]
            TLT->TLT_ACAO   := aTaxaMet[ nTaxa, 2 ]
            TLT->TLT_CARGA  := aTaxaMet[ nTaxa, 3 ]
            TLT->TLT_DESCAR := aTaxaMet[ nTaxa, 4 ]
            TLT->TLT_PESVEL := aTaxaMet[ nTaxa, 5 ]
            TLT->TLT_DESCPV := aTaxaMet[ nTaxa, 6 ]
            TLT->TLT_TAXAME := aTaxaMet[ nTaxa, 7 ]
        TLT->( MsUnlock() )

    Next nTaxa

Return
