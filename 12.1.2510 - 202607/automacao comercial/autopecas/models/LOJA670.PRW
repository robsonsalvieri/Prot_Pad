#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA670.ch"

/*/{Protheus.doc} LOJA670
    Cadastro de Motorizacao
    @type    function
    @author  eduardo.FLima
    @since   25/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA670()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MEA')
    oBrowse:SetDescription(STR0001) //"Motorizacao"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Motorizacao
    @type    function
    @author  eduardo.FLima
    @since   25/05/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Motorizacao
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0005    Action "VIEWDEF.LOJA670"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0002    Action "VIEWDEF.LOJA670"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003    Action "VIEWDEF.LOJA670"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004    Action "VIEWDEF.LOJA670"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006    Action "VIEWDEF.LOJA670"  Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Motorizacao
    @type    function
    @author  eduardo.FLima
    @since   25/05/2026
    @version P12
    @return  Objeto de Model para o cadastro de Motorizacao
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MEA')
    Local oModel  := MPFormModel():New('LOJA670', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Motorizacao"
    oModel:AddFields('MEAMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MEA_FILIAL', 'MEA_CODMOT'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Motorizacao
    @type    function
    @author  eduardo.FLima
    @since   25/05/2026
    @version P12
    @return  Objeto de View para o cadastro de Motorizacao
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MEA')
    Local oModel  := FWLoadModel('LOJA670')

    oView:SetDescription(STR0001) //"Motorizacao"
    oView:SetModel(oModel)
    oView:AddField('MEA', oStruct, 'MEAMASTER')
    oView:EnableTitleView('MEA', STR0001) //"Motorizacao"

Return oView

/*/{Protheus.doc} VldCilCm3
    Validacao cruzada entre Cilindrada em Litros (MEA_CILLIT) e Cilindrada em cm3 (MEA_CILCM3).
    Motores >= 1.0L: margem de 15% (fator 850 a 1150).
    Motores < 1.0L (Motos/Ciclomotores): margem ampliada (fator 600 a 1600).
    Exibe Help amigavel informando a faixa aceita quando o valor e incoerente.
    @type    function
    @author  eduardo.FLima
    @since   26/05/2026
    @version P12
    @return  Logical, .T. se valor coerente ou campos vazios, .F. se fora da faixa
/*/
Function VldCilCm3()
    Local nLitros   := 0 as Numeric
    Local nCilCm3   := M->MEA_CILCM3 as Numeric
    Local nLimInf   := 0 as Numeric
    Local nLimSup   := 0 as Numeric
    Local lRet      := .T. as Logical
    Local cMsg      := "" as Character
    Local cCRLF     := Chr(13) + Chr(10) as Character

    // Valida apenas quando ambos os campos estao preenchidos
    If !Empty(M->MEA_CILLIT) .And. nCilCm3 <> 0

        nLitros := Val(M->MEA_CILLIT)

        // Calcula limites baseado na faixa de cilindrada
        If nLitros < 1
            // Motocicletas e Ciclomotores (< 1.0L): margem ampliada
            nLimInf := nLitros * 600
            nLimSup := nLitros * 1600
        Else
            // Motores leves e pesados (>= 1.0L): margem de 15%
            nLimInf := nLitros * 850
            nLimSup := nLitros * 1150
        EndIf

        // Valida se o valor esta dentro da faixa aceitavel
        lRet := (nCilCm3 >= nLimInf .And. nCilCm3 <= nLimSup)

        If !lRet
            cMsg := STR0007 + cValToChar(nCilCm3) + STR0008 + AllTrim(M->MEA_CILLIT) + STR0009 + cCRLF + cCRLF //"O valor digitado (" ### " cm3) nao e coerente com a cilindrada de " ### " Litros selecionada."
            cMsg += STR0010 + cValToChar(nLimInf) + STR0011 + cValToChar(nLimSup) + STR0012 + cCRLF + cCRLF //"Faixa aceita: de " ### " a " ### " cm3."
            cMsg += STR0013 //"Corrija o valor ou altere o campo Cilindrada em Litros."
            Help(" ", 1, "VLDCILCM3", , cMsg, 1, 0)
        EndIf

    EndIf

Return lRet
