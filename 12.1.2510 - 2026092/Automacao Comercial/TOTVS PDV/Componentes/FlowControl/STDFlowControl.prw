#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRetFlow
Inclui registro para controle de fluxo

@author  Varejo
@version P11.8
@since   15/08/2016
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRetFlow( )

Local cStation 	:= PADR(STFGetStation("CODIGO"),TamSX3("LI_ESTACAO")[1]) // Estacao atual, utilizado na gravacao da SLI de controle de fluxo
Local aRet			:= {}

DbSelectArea("SLI")
SLI->(DbSetOrder( 1 )) //LI_FILIAL+LI_ESTACAO+LI_TIPO
If SLI->(DbSeek( xFilial("SLI") + cStation + "FLW" )) .AND. !Empty(SLI->LI_MSG) .AND. (SLI->LI_MSG <> "OK")
	LjGrvLog( "Controle de Fluxo", "Localizou comando (LI_TIPO = FLW) para Reprocessar na SLI(LI_MSG:)",SLI->LI_MSG)
	aRet := StrTokArr( SLI->LI_MSG, "|" ) //Function|IdAction|Params
EndIf
						
Return aRet
