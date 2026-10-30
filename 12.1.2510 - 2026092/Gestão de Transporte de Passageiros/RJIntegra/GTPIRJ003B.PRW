#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ003.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ003B

Processamento via startjob - Trecho das linhas - histórico de preços

@type 		function
@sample 	GTPIRJ003B(nOpc,aFldDePara,aDeParaXXF,aDados,nRecGI2,cUrl,cPath,cParam)
@param 	    nOpc        - Opção de menu [3-inclusão][4-alteração]
            aFldDePara  - Campos de para
            aDeParaXXF  - Registros existentes
            aDados      - Dados jSon
            nRecGI2     - Número do registro da tabela GI2, caso exista
            cUrl        - URL de processamento
            cPath       - Caminho da URL de processamento
            cParam      - Parametro da URL
@return		Nulo
@author 	jose.darocha
@since 		10/06/2024
@version 	1.0
**/

Function GTPIRJ003B(nOpc,aFldDePara,aDeParaXXF,aDados,nRecGI2,cUrl,cPath,cParam)

	Local oModel	  := FwLoadModel("GTPI003")
	Local oMdlGI4	  := Nil
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
 	Local lOnlyInsert := .F.
	Local lOverWrite  := .F.
    Local nY          := 0
    Local nPos        := 0
	Local cIntAux     := ""
	Local cErro		  := ""    
	Local lOk		  := .F.
	Local aError	  := {}
    Local lContinua   := .T.
    Local cRotina	  := "GTPIRJ003"
	Local cExtID	  := ""  
	Local cIntID	  := ""      

    If nRecGI2 > 0
        GI2->(DbGoTo(nRecGI2))
    EndIf

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "GI4", "GI4_ITEM", cExtID, GTPxMakeId(cIntId, 'GI4')) },.T.)

    oModel:SetOperation(nOpc)
    oModel:Activate()
    oMdlGI4 := oModel:GetModel("GI4MASTER")

    For nY := 1 To Len(aFldDePara)
        // recuperando a TAG e o respectivo campo da tabela
        cTagName    := aFldDePara[nY][1]
        cCampo      := aFldDePara[nY][2]
        cTipoCpo    := aFldDePara[nY][3]
        lOnlyInsert := aFldDePara[nY][6]
        lOverWrite  := aFldDePara[nY][7]

        // recuperando através da TAG o valor a ser inserido no campo
        If !Empty(cTagName) .And. !Empty((xValor := IRJ03BGetValue(aDados[cTagName], cTagName, cTipoCpo,,aFldDePara)))

            // verificando a necessidade de realizar o DePara XXF
            If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
                xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
            EndIf

            If cTagName $ "statusTarifa"
                xValor := Iif( xValor = "A", "2", "1")
            EndIf

            If (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
                lContinua := oMdlGI4:SetValue(cCampo, xValor)
            EndIf

            If !lContinua
                cErro := I18N(STR0005 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
                If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
                    GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) //"Trechos da Linha"
                    aAdd(aError, cErro)
                    EXIT
                Endif
            EndIf

        EndIf
    Next nY

    If lContinua .And. oModel:lModify
        lContinua := oModel:VldData() .And. oModel:CommitData()
        If !lContinua
            cErro := I18N( STR0011, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados da Trechos da Linha #2 (#1)."
            If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
                GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) //"Trechos da Linha"
                aAdd(aError, cErro)
            Endif
        EndIf
    Endif
    oModel:DeActivate()

	GTPDestroy(oModel)
	GTPDestroy(oMdlGI4)

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IRJ03BGetValue

Função de retorno de conteúdo de Array 

@type 		function
@sample 	IRJ03BGetValue( uRetValue, cTagName, cTipo, lPrencCamp, aFldDePara) 
@param      
@return		conteúdo do campo
@author 	jose.darocha
@since 		10/06/2024
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function IRJ03BGetValue( uRetValue, cTagName, cTipo, lPrencCamp, aFldDePara) 

	Local 	nPosFld  := aScan( aFldDePara, {|x| AllTrim(x[1]) == cTagName})
	Local	uValue
	Local 	cPicture := ""
	
	Default lPrencCamp	:= .T.

	uValue := GTPCastType(uRetValue, cTipo)
	If lPrencCamp .AND. nPosFld > 0
		cPicture := X3Picture(aFldDePara[nPosFld][2])
	EndIf

	If lPrencCamp .AND. nPosFld > 0 .AND. aFldDePara[nPosFld][3] == "C" 
		uValue := SubStr(uValue, 1, aFldDePara[nPosFld][4])
	EndIf

Return uValue
