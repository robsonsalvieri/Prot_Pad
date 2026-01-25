#INCLUDE "TOTVS.CH"
#INCLUDE "WMSA590.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA575
Recalcula nível do endereço
@author Squad WMS
@since 13/06/2018
@version 1.0

@return return, Nil
/*/
//--------------------------------------------------------------
Function WMSA590()
Local oProcess := MsNewProcess():New( { || Ajustar(oProcess) },STR0001 + "...", STR0002, .F. ) // Processamento // Finalizando 
	If MsgYesNo(STR0003,STR0004) // Este programa irá recalcular a segunda unidade de medida! Confirma processamento? // Recalculo da segunda unidade de medida
		If Pergunte("WMSA590")
			oProcess:Activate()
		EndIf
	EndIf
Return

Static Function Ajustar(oProcess)
Local oProduto  := WMSDTCProdutoDadosGenericos():New()
	oProduto:RemFatConv(MV_PAR01,MV_PAR02,oProcess)
return Nil