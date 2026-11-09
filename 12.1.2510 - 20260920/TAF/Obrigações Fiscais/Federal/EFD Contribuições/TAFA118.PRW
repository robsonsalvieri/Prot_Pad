#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA118
EFD Contribuições - Descontinuada em Dez/2021
/*/
//-------------------------------------------------------------------
Function TAFA118()
	MsgInfo("Prezado cliente, esta rotina foi descontinuada. O EFD Contribuições deve ser entregue através do módulo Fiscal de seu ERP principal.")
Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Construção dos painéis para geração do arquivo.

@Return	aRet	-	Parametrização necessária para a rotina xFunWizard

@Author	Fabio V. Santana
@Since		22/02/2013
@Version	1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()	

Local	aTxtApre	:= {}
Local	aRet		:= {}

aAdd (aTxtApre, "EFD Contribuições")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Atenção! Rotina descontinuada.")
aAdd (aTxtApre, "Rotina Obsoleta - O EFD Contribuições deve ser entregue através do módulo Fiscal de seu ERP principal.")

aAdd( aRet, aTxtApre )
aAdd( aRet, {} )
aAdd( aRet, "SPDPISCOF"+FWGETCODFILIAL)
aAdd( aRet, "" )
aAdd( aRet, Nil )
aAdd( aRet, Nil )
aAdd( aRet, { || TAFA118() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo

Return( aRet )
