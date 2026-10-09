#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ003.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ003A

Rotina de validações para geração de registros - Histórico de preços

@type 		function
@sample 	GTPIRJ003A( aDados, aFldDePara, aDeParaXXF, cUrl, cPath, cRotina, cParam, cFilRJ)
@param 	 	aDados, Array - indica dados para analise e processamento
@param      aFldDepara, Array - campos depara de origem do XML de integração
@param      aDeParaXXF, Array - campos depara de origem do XML de configuração
@param      cUrl, caracter - URL de origem da api utlizado identificação da origem em casos de falha
@param      cPath, caracter - PATH de origem da api utlizado identificação da origem em casos de falha
@param      cRotina, caracter - identificação da rotina utlizado identificação da origem em casos de falha
@param      cParam, caracter - parametro de origem da api utlizado identificação da origem em casos de falha
@param      cFilRJ, caracter - filial de origem da api utlizado identificação da origem em casos de falha
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	jose.darocha
@since 		19/06/2024
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ003A( aDados, aFldDePara, aDeParaXXF, cUrl, cPath, cRotina, cParam, cFilRJ)

	Local aIntIDs     := {}
	Local cIntID	  := ""
	Local cExtID	  := ""
	Local cExtLinha	  := ""
	Local cCodLinha	  := ""
	Local cExtLocOri  := ""
	Local cExtLocDes  := ""
	Local cFilReg	  := cFilRJ
	Local nY          := 0
	Local nOpc		  := 0
	Local lOk		  := .F.
 	Local lVerFilial  := .F.
	Local aError	  := {}
	Local nRecGI2     := 0
	Local lContinua   := .T.
    Local cErro       := ""
    Local lRet        := .T.
    Local cFilbkp     := cFilAnt

	Private cCodLocOri  := ""
	Private cCodLocDes  := ""    

    If cFilReg <> cFilAnt 
        cFilAnt := cFilReg
    EndIf 

	GI4->(DbSetOrder(5))	// GI4_FILIAL+GI4_LINHA+GI4_LOCORI+GI4_LOCDES+GI4_HIST    

    If !Empty(cExtLinha := IRJ03BGetValue(aDados['idLinha'], 'idLinha', 'C',,aFldDePara)) 	//!Empty(cExtLinha := cValToChar(aDados[nX]['idLinha'])) 	//!Empty(cExtLinha := oRJIntegra:GetJsonValue(nX, 'idLinha', 'C')) 

        cCodLinha := GTPxRetId("TotalBus", "GI2", "GI2_COD", cExtLinha, @cIntID, 3, @lOk, @cErro, {"GI2_FILIAL", "GI2_COD", {"GI2_HIST", "2"}}, 4, lVerFilial, @cFilReg)

        // validando se a linha existe no cadastro de seções
        nRecGI2 := 0
        GI2->(DbSetOrder(1))
        If !Empty(cCodLinha) .And. ((!Empty(cfilreg) .AND. GI2->(DbSeek(xFilial('GI2', cFilReg) + cCodLinha))) .OR. (Empty(cfilreg) .AND. GI2->(DbSeek(xFilial('GI2') + cCodLinha)))) 
            nOpc := MODEL_OPERATION_UPDATE
            nRecGI2 := GI2->(Recno())
        Else

            lContinua := .F.
            cErro := I18N( STR0003 , {GTPXErro(NIL,'Linha: ['+cCodLinha+']'),cExtID,cIntId}) + CRLF +'idLinha: ' + cExtLinha	// "Linha não encontrada. Favor realizar o cadastro prévio da Linha para prosseguir com a integração das Tarifas."
            If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
                GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) //"Trechos da Linha"
                aAdd(aError, cErro)
            Endif

        EndIf

        If lContinua
            
            cExtID     := IRJ03BGetValue(aDados['idPreco'], 'idPreco'  , 'C',,aFldDePara)
            cExtLocOri := IRJ03BGetValue(aDados['idOrigem'], 'idOrigem' , 'C',,aFldDePara)
            cExtLocDes := IRJ03BGetValue(aDados['idDestino'], 'idDestino', 'C',,aFldDePara)
            aAdd(aIntIDs, {cExtLocOri, "cCodLocOri", "GI1", "GI1_COD", 3, {"GI1_FILIAL", "GI1_COD"}, 1})
            aAdd(aIntIDs, {cExtLocDes, "cCodLocDes", "GI1", "GI1_COD", 3, {"GI1_FILIAL", "GI1_COD"}, 1})

            For nY := 1 To Len(aIntIDs)
                If !Empty(aIntIDs[nY, 1])
                    &(aIntIDs[nY, 2]) := GTPxRetId("TotalBus", aIntIDs[nY, 3], aIntIDs[nY, 4], aIntIDs[nY, 1], aIntIDs[nY, 2], aIntIDs[nY, 5], @lOk ,@cErro, aIntIDs[nY, 6], aIntIDs[nY, 7])
                    If !lOk

                        lContinua := .F.
                        If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
                            GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) //"Trechos da Linha"
                            aAdd(aError, cErro)
                            Exit
                        EndIf

                    EndIf
                EndIf
            Next nY

            If lContinua
                // verificando se existe tarifa para as localidades de origem e destino
                If (!Empty(cfilreg) .AND. !(GI4->(DbSeek(xFilial('GI4', cFilReg) + cCodLinha + cCodLocOri + cCodLocDes + "2")))) .Or. (Empty(cfilreg) .AND. !(GI4->(DbSeek(xFilial('GI4') + cCodLinha + cCodLocOri + cCodLocDes + "2"))))
                    
                    cErro := I18N(STR0004, {GTPXErro(Nil,'Linha/Local Origem/Local Destino: [' + cCodLinha + '][' + cCodLocOri +  '][' + cCodLocDes+']'),cExtID,cIntId})	// "Não foi possivel encontrar a localidade do trecho de Origem: #1 e/ou de Destino: #2"
                    If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
                        GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) //"Trechos da Linha"                    
                        aAdd(aError, cErro)
                    Endif

                Else
                    /* Função manutenção de registro Trechos e tarifas  */
                    GTPIRJ003B(nOpc,aFldDePara,aDeParaXXF,aDados,nRecGI2,cUrl,cPath,cParam)
                EndIf
            EndIf 
        EndIf
    EndIf

    cFilAnt := cFilBkp

Return lRet 
