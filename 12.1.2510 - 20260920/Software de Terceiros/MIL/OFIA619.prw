#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "ofia619.ch"

/*/{Protheus.doc} OFIA619
Rotina para permitir a geração manual de XML para integração com a WHI, utilizando o MarkBrowse para sinalizar os registros que já foram processados.
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Function OFIA619()

    Private oMark   := Nil As Object
	Private aRegSel := {} As Array

    oMark := FwMBrowse():New()
    oMark:SetDescription(STR0001) // "Geração de XML Integração WHI"
    oMark:SetAlias("VDW")
    oMark:AddMarkColumns({|| OA619003M_ColBMark()}, {|| OA619004M_MarkRegistro()})
    oMark:AddLegend("Empty(VDW->VDW_DATENV)",  "BR_VERDE",    STR0002) // "Registro não enviado"
    oMark:AddLegend("!Empty(VDW->VDW_DATENV)", "BR_VERMELHO", STR0003) // "Registro enviado"
    oMark:lChgAll := .T. // não apresentar a tela para informar a filial
    oMark:DisableDetails()
    oMark:ForceQuitButton(.T.)
    oMark:Activate()

Return()

/*/{Protheus.doc} MenuDef
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Static Function MenuDef()

    Local aRotina := {} As Array
     
    //Criação das opções
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.OFIA619"    OPERATION 1 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION "OA619001M_Legendas" OPERATION 6 ACCESS 0 // "Legenda"
    ADD OPTION aRotina TITLE STR0006 ACTION "OA619002M_GeraXmls" OPERATION 6 ACCESS 0 // "Gerar XML"
    ADD OPTION aRotina TITLE STR0013 ACTION "OA619005C_ConsultaChassi" OPERATION 6 ACCESS 0 // "Consulta chassi"

Return(aRotina)

/*/{Protheus.doc} ModelDef
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Static Function ModelDef()

    Local oStruct := Nil As Object
    Local oModel  := Nil As Object

    oStruct := FWFormStruct(1, "VDW")
    oModel := MPFormModel():new('OFIA619',,,,)
    oModel:AddFields("VDWMASTER",, oStruct,,,)
    oModel:SetPrimaryKey({xFilial("VDW"), "VDW_NUMOSV"})

Return(oModel)

/*/{Protheus.doc} ViewDef
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Static Function ViewDef()
    
    Local oStruct := Nil As Object
    Local oModel  := Nil As Object
    Local oView   := Nil As Object

    oStruct := FWFormStruct(2, "VDW")
    oModel := fwLoadModel("OFIA619")
    oView := fwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VDWMASTER", oStruct, "VDWMASTER")
    oView:CreateHorizontalBox("BOXVDW", 100)
    oView:SetOwnerView("VDWMASTER", "BOXVDW")

Return(oView)

/*/{Protheus.doc} OA619001M_Legendas
Rotina que apresenta as legendas para o MarkBrowse, indicando quais registros foram ou não processados para geração do XML.
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Function OA619001M_Legendas()

	Local oLegenda := Nil As Object

	oLegenda := FWLegend():New()
	oLegenda:Add("", "BR_VERDE",    STR0002) // Registro não enviado
	oLegenda:Add("", "BR_VERMELHO", STR0003) // Registro enviado
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:Deactivate()
	FreeObj(oLegenda)

Return()

/*/{Protheus.doc} OA619002M_GeraXmls
Rotina que realiza a geração dos arquivos XML para os registros selecionados no MarkBrowse, utilizando a função OFSC02, e atualizando a data de envio no cadastro para sinalizar que o registro já foi processado.
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Function OA619002M_GeraXmls() As Null

    Local aArea := FwGetArea() As Array
    Local aXml  := {} As Array
    Local nI    := 0 As Numeric

    If Len(aRegSel) == 0
        FWAlertError(STR0007, STR0008) // "Nenhum registro selecionado!" / "Erro"
    Else
        For nI := 1 To Len(aRegSel)
            If VDW->(DbSeek(xFilial("VDW") + aRegSel[ni, 1]))
                aAdd(aXml, VDW->VDW_NUMOSV) // Adiciona o número da OS para o array de XML
            EndIf
        Next

        FWMsgRun(, {|| OFSC02(.T., .T., aXml)}, STR0009, STR0010)
        
        FWAlertSuccess(STR0011, STR0012) // "Arquivo XML gerado!" / "Sucesso"
    EndIf

    FwRestArea(aArea) //Restaura a área original
 	
Return()

/*/{Protheus.doc} OA619003M_ColBMark
Rotina que define a coluna de marcação no MarkBrowse.
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Static Function OA619003M_ColBMark() As Null

	Local lRet := "LBNO"
	
	If aScan(aRegSel, {|x| x[1] == VDW->VDW_NUMOSV}) > 0
		lRet := "LBOK"
	EndIf

Return(lRet)

/*/{Protheus.doc} OA619004M_MarkRegistro
Rotina que marca ou desmarca um registro no MarkBrowse, adicionando ou removendo o número da OS do array de registros selecionados.
@type function
@version 1.0
@author Leandro Nunes
@since 14/04/2026
@return Nulo
/*/
Static Function OA619004M_MarkRegistro() As Null
	
	If aScan(aRegSel, {|x| x[1] == VDW->VDW_NUMOSV}) == 0
		aAdd(aRegSel, { VDW->VDW_NUMOSV })
	Else
		aDel(aRegSel, aScan(aRegSel, {|x| x[1] == VDW->VDW_NUMOSV}))
		aSize(aRegSel, Len(aRegSel) - 1)
	EndIf

Return(Nil)


/*/{Protheus.doc} OA619005C_ConsultaChassi
Consulta Chassi na URL WHI Scania
@type function
@version 1.0
@author Cristiam Rossi
@since 28/04/2026
/*/
Function OA619005C_ConsultaChassi()
local aPerg := {}

    aAdd( aPerg, { 1, RetTitle("VV1_CHASSI") , space(25), "@!", "FG_POSVEI('MV_PAR01')", "VV1", "" , 90, .T. } )

    if paramBox( aPerg, STR0013 )
        dbSelectArea( "VV1" )
        dbSetOrder(2)
        if VV1->( dbSeek( xFilial("VV1") + MV_PAR01 ) )
            OFCSCCO2( alias(), recno() )
        endif
    endif

    dbSelectArea( "VDW" )
return nil
