#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#include "PLSA660.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} PLSA660D
Cadastro de Descontos na mensalidade
@Version P12
@Author DXM
@Since 12/06/2024
/*/
//---------------------------------------------------------------------------
Function PLSA660D()

    Local oBrowse

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('BQ0')
    oBrowse:SetMenuDef( 'PLSA660D' )
    oBrowse:SetDescription(STR0050) // 'Descontos x Parcelas'
    oBrowse:Activate()
    
Return(.T.)

//---------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cadastro de Desconto na mensalidade
@Version P12
@Author DXM
@Since 12/06/2024
/*/
//---------------------------------------------------------------------------

Static Function MenuDef()

Return FWMVCMenu("PLSA660D")

//---------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cadasatro de Descontos na mensalidade
@Version P12
@Author DXM
@Since 12/06/2024
/*/
//---------------------------------------------------------------------------
Static Function ViewDef()

    Local oModel   	    := nil
    Local oStru         := nil
    Local oStruBQ0 	    := nil
    Local aCampos       := {}
    Local nCampos       := 0
    Local nI            := 0
    Local oView
    Local cCabec        := ""

    cAlias := getCurrentAlias()

    oModel := FWLoadModel('PLSA660D')
    oStru := FWFormStruct( 2, cAlias)
    oStruBQ0 := FWFormStruct( 2, 'BQ0' )
    
    aCampos := FWSX3UTIL():GetAllFields(cAlias)

    Do Case 
        Case cAlias == "BG9"
            cCabec := 'Grupo/Empresa'
        Case cAlias == "BT5"
            cCabec := 'Contrato'
        Case cAlias == "BQC"
            cCabec := 'Sub-Contrato'
        Case cAlias == "BA3"
            cCabec := 'Família'
    EndCase                           

    oView := FWFormView():New()

    oView:SetModel( oModel )

    nCampos := Len(aCampos)
    For nI := 1 To nCampos
        Do Case 
            Case cAlias == "BG9"
                IF !(aCampos[nI] $ "BG9_CODINT|BG9_CODIGO")
                    oStru:RemoveField(aCampos[nI])
                EndIf
            Case cAlias == "BT5"
                IF !(aCampos[nI] $ "BT5_CODINT|BT5_CODIGO|BT5_NUMCON|BT5_VERSAO")
                    oStru:RemoveField(aCampos[nI])
                EndIf
            Case cAlias == "BQC"
                IF !(aCampos[nI] $ "BQC_CODINT|BQC_CODEMP|BQC_NUMCON|BQC_VERCON|BQC_SUBCON|BQC_VERSUB")
                    oStru:RemoveField(aCampos[nI])
                EndIf
            Case cAlias == "BA3"
                IF !(aCampos[nI] $ "BA3_CODINT|BA3_CODEMP|BA3_CONEMP|BA3_VERCON|BA3_SUBCON|BA3_VERSUB|BA3_MATRIC")
                    oStru:RemoveField(aCampos[nI])
                EndIf
        EndCase

    Next nI

    oView:AddField( 'VIEW_'+cAlias,	oStru, cAlias+'MASTER' )
    oView:AddGrid(  'VIEW_BQ0', oStruBQ0, 'BQ0DETAIL' )

    oStru:SetNoFolder() // Retirando as pastas de uma estrutura

    oView:CreateHorizontalBox( 'CABEC', 30 )
    oView:CreateHorizontalBox( 'GRID', 70 )

    oView:SetOwnerView( 'VIEW_'+cAlias, 'CABEC')
    oView:SetOwnerView( 'VIEW_BQ0', 'GRID')

    oView:EnableTitleView('VIEW_'+cAlias,cCabec)
    oView:EnableTitleView('VIEW_BQ0','Descontos')

Return oView

//---------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cadasatro de Descontos na mensalidade
@Version P12
@Author DXM
@Since 12/06/2024
/*/
//---------------------------------------------------------------------------
Static Function ModelDef()
                                         
    Local cAlias := getCurrentAlias()
    Local oStru 	:= FWFormStruct( 1, cAlias)
    Local oStruBQ0 	:= FWFormStruct( 1, 'BQ0' )
    Local oModel
    Local cCabec    := ""

    Do Case 
        Case cAlias == "BG9"
            cCabec := 'Grupo/Empresa'
        Case cAlias == "BT5"
            cCabec := 'Contrato'
        Case cAlias == "BQC"
            cCabec := 'Sub-Contrato'
        Case cAlias == "BA3"
            BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
            BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
            cCabec := 'Família'
    EndCase

    oModel := MPFormModel():New('PLSA660D_M')

    //Monta a estrutura
    oModel:AddFields(cAlias+'MASTER',Nil, oStru)
    oModel:AddGrid('BQ0DETAIL', cAlias+'MASTER', oStruBQ0)

    oModel:GetModel("BQ0DETAIL"):setOptional(.T.)

    Do Case 
        
        Case cAlias == "BG9"
            //Relacionamentos
            oModel:SetRelation('BQ0DETAIL', { 	{ 'BQ0_FILIAL', 'xFilial("BG9")'    },;
                                                { 'BQ0_CODINT', 'BG9_CODINT'        },;
                                                { 'BQ0_CODEMP', 'BG9_CODIGO'        } ;
                                            },  BQ0->(IndexKey(2)) )
        Case cAlias == "BT5"
            //Relacionamentos
            oModel:SetRelation('BQ0DETAIL', { 	{ 'BQ0_FILIAL', 'xFilial("BT5")'    },;
                                                { 'BQ0_CODINT', 'BT5_CODINT'        },;
                                                { 'BQ0_CODEMP', 'BT5_CODIGO'        },;
                                                { 'BQ0_NUMCON', 'BT5_NUMCON'        },;
                                                { 'BQ0_VERCON', 'BT5_VERSAO'        } ;
                                            },  BQ0->(IndexKey(3)) )
        Case cAlias == "BQC"
            //Relacionamentos
            oModel:SetRelation('BQ0DETAIL', { 	{ 'BQ0_FILIAL', 'xFilial("BQC")'    },;
                                                { 'BQ0_CODINT', 'BQC_CODINT'        },;
                                                { 'BQ0_CODEMP', 'BQC_CODEMP'        },;
                                                { 'BQ0_NUMCON', 'BQC_NUMCON'        },;
                                                { 'BQ0_VERCON', 'BQC_VERCON'        },;
                                                { 'BQ0_SUBCON', 'BQC_SUBCON'        },;
                                                { 'BQ0_VERSUB', 'BQC_VERSUB'        } ;
                                            },  BQ0->(IndexKey(1)) )
        Case cAlias == "BA3"
            //Relacionamentos
            oModel:SetRelation('BQ0DETAIL', { 	{ 'BQ0_FILIAL', 'xFilial("BA3")'    },;
                                                { 'BQ0_CODINT', 'BA3_CODINT'        },;
                                                { 'BQ0_CODEMP', 'BA3_CODEMP'        },;
                                                { 'BQ0_NUMCON', 'BA3_CONEMP'        },;
                                                { 'BQ0_VERCON', 'BA3_VERCON'        },;
                                                { 'BQ0_SUBCON', 'BA3_SUBCON'        },;
                                                { 'BQ0_VERSUB', 'BA3_VERSUB'        },;
                                                { 'BQ0_MATRIC', 'BA3_MATRIC'        } ;
                                            },  BQ0->(IndexKey(4)) )
    EndCase

    //Descricoes
    oModel:SetDescription('Cadastro de descontos por parcela')
    
    oModel:GetModel(cAlias+'MASTER'):SetDescription(cCabec)
    oModel:GetModel('BQ0DETAIL'):SetDescription('Descontos')

    oModel:GetModel("BQ0DETAIL"):SetLoadFilter(, " UPPER(BQ0_NIVEL) = '"+cAlias+"' " )

    //Chave Primaria 										
    oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} getCurrentAlias
Obtém o alias de contexto conforme a rotina chamadora para montagem do ModelDef e ViewDef.
@type static function
@version 12.1.2610
@author vinicius.queiros
@since 29/05/2026
@return character, Alias de contexto identificado (BA3, BQC, BT5, BG9) ou vazio quando não identificado
/*/
static function getCurrentAlias()

    local cCurrentAlias := "" as character

    do case
        case isInCallStack("PLSA260") .or. isInCallStack("PLSA260MVC")
            cCurrentAlias := "BA3"
        
        case isInCallStack("PLS660FilS")
            cCurrentAlias := "BQC"
        
        case isInCallStack("PLS660FilC")
            cCurrentAlias := "BT5"
        
        case isInCallStack("Pls660DES")
            cCurrentAlias := "BG9"
    endcase

return cCurrentAlias
