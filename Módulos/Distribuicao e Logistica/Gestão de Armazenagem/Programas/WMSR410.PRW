#INCLUDE "PROTHEUS.CH"   


//-----------------------------------------------------------
/*/{Protheus.doc} WmsR401
Chama RdMake Impressao de Etiquetas de Embalagem 
Feito isso pois o AtuSx estava fechado e a funcao está como 
Function no AtuSx

@author  Leandro Paulino
@since   05/17/11
/*/
//-----------------------------------------------------------
Function WmsR410()
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		If ExistBlock("WMSR410A")
			ExecBlock("WMSR410A",.F.,.F.)
		Else
			WMSR410A(,.F.)
		Endif
	Else
		WMSR410A(,.F.)
	EndIf	
Return Nil	