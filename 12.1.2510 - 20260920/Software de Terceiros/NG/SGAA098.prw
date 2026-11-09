#INCLUDE "Totvs.ch"
#INCLUDE "FWMVCDEF.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098
Rotina vinculativa do Código do Sinir com Empresa Protheus

@type   Function

@author Eduardo Mussi
@since  06/08/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAA098()
    
    Local oBrowse

    Private cRetPriF3  := ''
    Private cRetSegF3  := ''
	Private cSINFun    := 'SGAA098F3()'
	Private cSINRet1   := 'SGAA098F3R(1)'
    Private cSINRet2   := 'SGAA098F3R(2)'
    Private cMdtGenFun := 'SGAA098F3()'
	Private cMdtGenRet := 'SGAA098F3R(1)'

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias( 'TH8' )
    oBrowse:SetMenuDef( 'SGAA098' )
    oBrowse:SetDescription( 'Código Sinir x Empresa Protheus' )
    oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria o menu da rotina

@type   Function

@author Eduardo Mussi
@since  06/08/2025

@return Array, Array com as opções da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'SGAA098' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria o Modelo

@type   Function

@author Eduardo Mussi
@since  06/08/2025

@return Objeto, objeto do modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    
    Local oModel
    Local oStructTH8 := FWFormStruct( 1, 'TH8' )

    oModel := MPFormModel():New( 'SGAA098', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
    oModel:AddFields( 'SGAA098_TH8', Nil, oStructTH8, /*bPre*/, /*bPost*/, /*bLoad*/)
    oModel:SetPrimaryKey( { 'TH8_FILIAL', 'TH8_CODIGO'})
    //oModel:SetDescription("")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria a view

@type   Function

@author Eduardo Mussi
@since  06/08/2025

@return Objeto, objeto da view
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel := FWLoadModel( 'SGAA098' )
    Local oView  := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField( 'SGAA098_TH8', FWFormStruct( 2, 'TH8' ), /*cLinkID*/)
    oView:CreateHorizontalBox( 'MASTER_HOR', 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
    oView:SetOwnerView( 'SGAA098_TH8', 'MASTER_HOR')

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA098F3
Função responsável por criar um F3 com duas tabelas baseado no valor
informado no campo TH8_TIPO

@author Eduardo Mussi
@since  10/09/2025

@return Lógico, valida se o conteúdo informado existe na tabela em questão
/*/
//---------------------------------------------------------------------
Function SGAA098F3()
    
    Local lRet
    Local oModel  := FWModelActive()

    If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'

        lRet := ConPad1( ,,, 'EMPTH8',,, .F. )

		If lRet
			
            cRetPriF3 := SM0->M0_CODIGO                                                                                                                                                                                                                                            
            cRetSegF3 := SM0->M0_CODFIL                                                                                                                                                                                                                                            

		EndIf

	ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '2'

        If ( lRet := ConPad1( ,,, 'TDL',,, .F. ) )
            
            cRetPriF3 := TDL->TDL_CODTRA

		EndIf
	
    ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '3'
    
        If ( lRet := ConPad1( ,,, 'SA4',,, .F. ) )
            
            cRetPriF3 := SA4->A4_COD

		EndIf
    
	Else
		
        lRet := ConPad1( ,,, 'SA2',,, .F. )

		If lRet
			
            cRetPriF3 := SA2->A2_COD
            cRetSegF3 := SA2->A2_LOJA

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098F3R
Função responsável por retornar os conteúdos da consulta padrão feita
na função SGAA098F3.

@type   Function

@author Eduardo Mussi
@since  10/09/2025
@param  nReturn, Numérico, 1 - primeiro retorno / 2 - segundo retorno

@return Caracter, Retorna conteúdo selecionado no F3.
/*/
//-------------------------------------------------------------------
Function SGAA098F3R( nReturn )

    Local cReturn

    If nReturn == 1

        cReturn := cRetPriF3
    
    Else

        cReturn := cRetSegF3

    EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098F3F
Realiza filtro na consulta padrão

@type   Function

@author Eduardo Mussi
@since  24/10/2025

@return Caracter, Filtro SQL a ser executado quando acionado F3 - TH8TAT
/*/
//-------------------------------------------------------------------
Function SGAA098F3F()
	
	Local cFilter := ''

	If ReadVar() == 'M->TAT_UNSGER'
        
        cFilter :=  "@TH8_TIPO = '1'"

    ElseIf ReadVar() == 'M->TAT_UNSTRA'
        
        cFilter :=  "@TH8_TIPO = '2'"
        
    ElseIf ReadVar() == 'M->TAT_UNARMT'
        
        cFilter := "@TH8_TIPO = '3'"

    ElseIf ReadVar() == 'M->TAT_UNSDES' .Or. ReadVar() == 'M->TB5_CODSIN'

        cFilter := "@TH8_TIPO = '4'"
        
	EndIf

Return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098VLD
Função responsável pela validação de cada campo ( X3_VALID ).

@type   Function

@author Eduardo Mussi
@since  10/09/2025
@Param  cField, Caracter, Campo a ser validado.

@return Lógico, Define se o conteúdo informado no campo está correto.
/*/
//-------------------------------------------------------------------
Function SGAA098VLD( cField )

    Local lReturn := .F.
    Local oModel  := FWModelActive()

    If cField == 'TH8_TIPO'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '1/2/3/4'
        
    ElseIf cField == 'TH8_CODEMP' .Or. cField == 'TH8_FILEMP'
        
        If !Empty( oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ) )

            If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1' .And. fValSM0( oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ) )
                
                lReturn := .T.

            EndIf

        Else
        
            If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1' .And. fValSM0( oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + cRetSegF3 )
                
                lReturn := .T.

            EndIf

        EndIf
    
    ElseIf cField == 'TH8_FORTRA'
        
            
        If NGIFDBSEEK( 'SA4', oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 1 )
    
            lReturn := .T.

        EndIf

    ElseIf cField == 'TH8_FORDES' .Or. cField == 'TH8_LOJA'

        If !Empty( oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ) )
            
            If NGIFDBSEEK( 'SA2', oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 1 )
                
                lReturn := .T.

            EndIf

        Else
            
            If NGIFDBSEEK( 'SA2', oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + cRetSegF3, 1 )

                lReturn := .T.

            EndIf

        EndIf

    ElseIf cField == 'TH8_CODSIN'
        
        lReturn := .T.

    EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098WHE
Define se o campo será aberto para edição ( X3_WHEN ).

@type   Function

@author Eduardo Mussi
@since  10/09/2025
@Param  cField, Caracter, Campo a ser verificado.

@return Lógico, Define se o campo será aberto para edição.
/*/
//-------------------------------------------------------------------
Function SGAA098WHE( cField )
    
    Local lReturn := .F.
    Local oModel  := FWModelActive()
    
    If cField == 'TH8_TIPO'

        lReturn := oModel:GetOperation() == 3

    ElseIf cField == 'TH8_CODEMP'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'

    ElseIf cField == 'TH8_FILEMP'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
    
    ElseIf cField == 'TH8_FORDES'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '4'

    ElseIf cField == 'TH8_LOJA'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '4'
    
    ElseIf cField == 'TH8_FORTRA'
        
        lReturn := oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'

    ElseIf cField == 'TH8_CODSIN'
        
        lReturn := .T.
        
    EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098REL
Busca informação a ser apresentada no campo ( X3_RELACAO ).

@type   Function

@author Eduardo Mussi
@since  10/09/2025
@param  cField, Caracter, Campo a ser carregado informações

@return Indefinido, Retorna valor a ser carregado no campo passado pelo cField
/*/
//-------------------------------------------------------------------
Function SGAA098REL( cField )

    Local oModel  := FWModelActive()
    Local xReturn
    
    If cField == 'TH8_CODIGO'
        
        xReturn := Soma1Old( GetSXENUM( 'TH8', 'TH8_CODIGO' )  )

    ElseIf cField == 'TH8_NOME'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_NOMECOM' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_NOME' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_NOME' )
            
        EndIf
        
    ElseIf cField == 'TH8_TEL'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_TEL' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_TEL' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_TEL' )
            
        EndIf

    ElseIf cField == 'TH8_EST'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_EST' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_EST' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_EST' )
            
        EndIf

    ElseIf cField == 'TH8_CID'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_CIDENT' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_MUN' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_MUN' )
            
        EndIf

    ElseIf cField == 'TH8_BAI'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_BAIRENT' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_BAIRRO' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_BAIRRO' )
            
        EndIf

    ElseIf cField == 'TH8_END'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_ENDENT' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_END' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_END' )
            
        EndIf

    ElseIf cField == 'TH8_CGC'
        
        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'
            
            xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_CGC' )

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'
            
            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_CGC' )

        Else
            
            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_CGC' )
            
        EndIf

    EndIf

Return xReturn

//---------------------------------------------------------------------
/*/{Protheus.doc}  SGAA098
Responsável por realizar gatilho dos campos da rotina

@type   Function

@author Eduardo Mussi
@since  11/09/2025

@param cDomain , Caracter, campo que está gatilhando
@param cCDomain, Caracter, campo a receber o valor do gatilho

@return Indefinido, Valor do Gatilho do campo em questão.
/*/
//---------------------------------------------------------------------
Function SGAA098GAT( cDomain, cCDomain )

    Local aArea   := FwGetArea()
    Local oModel  := FWModelActive()
    Local xReturn

    If cDomain == 'TH8_TIPO' .And.;
        ( cCDomain == 'TH8_CODEMP' .Or. cCDomain == 'TH8_FILEMP' .Or. cCDomain == 'TH8_FORTRA' .Or. cCDomain == 'TH8_FORDES' .Or. cCDomain == 'TH8_LOJA' .Or.;
            cCDomain == 'TH8_NOME' .Or. cCDomain == 'TH8_TEL' .Or. cCDomain == 'TH8_EST' .Or. cCDomain == 'TH8_CID' .Or.;
                cCDomain == 'TH8_BAI' .Or. cCDomain == 'TH8_END' .Or. cCDomain == 'TH8_CGC' )

        // Tratamento para limpar os campos quando o usuário trocar o tipo de cadastro
        xReturn := Space( FwTamSX3( cCDomain )[ 1 ] )

    Else

        If oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) == '1'

            Do Case
            
                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_NOME'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_NOMECOM' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_TEL'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_TEL' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_EST'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_EST' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_CID'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_CIDENT' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_BAI'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_BAIRENT' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_END'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_ENDENT' )

                Case cDomain == 'TH8_FILEMP' .And. cCDomain == 'TH8_CGC'
                    
                    xReturn := Posicione( 'SM0', 1, oModel:GetValue( 'SGAA098_TH8', 'TH8_CODEMP' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FILEMP' ), 'M0_CGC' )

            EndCase

        ElseIf oModel:GetValue( 'SGAA098_TH8', 'TH8_TIPO' ) $ '2/3'

            Do Case

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_NOME'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_NOME' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_TEL'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_TEL' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_EST'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_EST' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_CID'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_MUN' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_BAI'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_BAIRRO' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_END'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_END' )

                Case cDomain == 'TH8_FORTRA' .And. cCDomain == 'TH8_CGC'
                    
                    xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORTRA' ), 'A4_CGC' )

            EndCase
        
        Else

            Do Case

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_NOME'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_NOME' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_TEL'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_TEL' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_EST'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_EST' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_CID'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_MUN' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_BAI'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_BAIRRO' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_END'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_END' )

                Case cDomain == 'TH8_LOJA' .And. cCDomain == 'TH8_CGC'
                    
                    xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_FORDES' ) + oModel:GetValue( 'SGAA098_TH8', 'TH8_LOJA' ), 'A2_CGC' )

            EndCase

        EndIf

    EndIf

    FwRestArea( aArea )
    
Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fValSM0
Valida os dados da SM0 informado no campo TH8_CODEMP e TH8_FILEMP

@type   Function

@author Eduardo Mussi
@since  11/09/2025
@param  cChave, Caracter, Chave de busca na SM0

@return Lógico, Define se o valor informado na chave existe
/*/
//-------------------------------------------------------------------
Static Function fValSM0( cChave )

    Local aArea   := FwGetArea()
    Local lReturn := .F.

    dbSelectArea( 'SM0' )
    dbSetOrder( 1 )
    If dbSeek( cChave )
    
        lReturn := .T.

    EndIf

    FwRestArea( aArea )

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA098INB
Função responsável por carregar os conteúdos no browse

@type   Function

@author Eduardo Mussi
@since  18/09/2025
@param  cField, Caracter, Campo a ser carregado o conteúdo

@return Indefinido, Conteúdo a ser carregado no campo
/*/
//-------------------------------------------------------------------
Function SGAA098INB( cField )

    Local aArea := FwGetArea()
    Local xReturn

    If TH8->TH8_TIPO == '1'

        If cField == 'TH8_NOME'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_NOMECOM' )
            
        ElseIf cField == 'TH8_TEL'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_TEL' )
            
        ElseIf cField == 'TH8_EST'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_ESTENT' )
            
        ElseIf cField == 'TH8_CID'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_CIDCOB' )
            
        ElseIf cField == 'TH8_BAI'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_BAIRENT' )
            
        ElseIf cField == 'TH8_END'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_ENDCOB' )
            
        ElseIf cField == 'TH8_CGC'

            xReturn := Posicione( 'SM0', 1, TH8->TH8_CODEMP + TH8->TH8_FILEMP, 'M0_CGC' )
            
        EndIf
    
    ElseIf TH8->TH8_TIPO $ '2/3'

        If cField == 'TH8_NOME'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_NOME' )
            
        ElseIf cField == 'TH8_TEL'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_TEL' )
            
        ElseIf cField == 'TH8_EST'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_EST' )
            
        ElseIf cField == 'TH8_CID'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_MUN' )
            
        ElseIf cField == 'TH8_BAI'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_BAIRRO' )
            
        ElseIf cField == 'TH8_END'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_END' )
            
        ElseIf cField == 'TH8_CGC'

            xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + TH8->TH8_FORTRA, 'A4_CGC' )

        EndIf

    Else
       
        If cField == 'TH8_NOME'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_NOME' )

        ElseIf cField == 'TH8_TEL'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_TEL' )

        ElseIf cField == 'TH8_EST'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_EST' )

        ElseIf cField == 'TH8_CID'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_MUN' )

        ElseIf cField == 'TH8_BAI'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_BAIRRO' )

        ElseIf cField == 'TH8_END'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_END' )

        ElseIf cField == 'TH8_CGC'

            xReturn := Posicione( 'SA2', 1, FwxFilial( 'SA2' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'A2_CGC' )
        
        EndIf

    EndIf

    FwRestArea( aArea )

Return xReturn
