#INCLUDE "TOTVS.ch"
#INCLUDE "AGDSV010.ch"

/*/{Protheus.doc} AGDSV001
    (Informe Rendimentos Cooperado) - Acionado por AGDA160
    @type  Function
    @author carlos.augusto
    @since 19/08/2026
    @version 1.0
    @see (DAGRODIST-4908)
    /*/
Function AGDSV001(cFilFilt, cCodCoop, cLojCoop, cAnoRef, cCodContab)

	local oSmartView := NIL

	oSmartView := totvs.framework.smartview.callSmartView():new("agrobusiness.sv.sigaagd.quotaincomestatement.rep", "report") 
	    
    if !Empty(cCodCoop) .And. !Empty(cLojCoop)
        oSmartView:setParam("filialDe", cFilFilt)
        oSmartView:setParam("filialAte", cFilFilt)
		oSmartView:setParam("codigoCooperadoDe", cCodCoop)
        oSmartView:setParam("codigoCooperadoAte", cCodCoop)
		oSmartView:setParam("lojaCooperadoDe", cLojCoop)
        oSmartView:setParam("lojaCooperadoAte", cLojCoop)
        oSmartView:setParam("matriculaDe", " ")
        oSmartView:setParam("matriculaAte", " ")
        oSmartView:setParam("anoCalendario", cAnoRef)
        oSmartView:setParam("codigoContabilista", cCodContab)
		oSmartView:setForceParams(.T.)
		oSmartView:setShowWizard(.F.)
	EndIf

    If !oSmartView:executeSmartView(.T.)
        Help( " ", 1, OemToAnsi("Smart View!"), Nil, OemToAnsi(STR0001), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0002) } ) //#"Não foi possível abrir o Smart View. #"Verifique se o servidor REST está no ar ou contate o administrador do sistema."
    EndIf  

    oSmartView:destroy()

return
