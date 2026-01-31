#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} STWPayGiftV
Decisoes para vale presente

@param   cValPre - Vale presente	
@param   oMdlDtl	- Model detalhes
@author  Varejo
@version P11.8
@since   	19/03/2013
@return  	cValor - Valor do vale presente
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWPayGiftV(cValPre, oMdlDtl)

Local cMsg 	:= "" 	//Mensagem de inconsistencia de vale presente
Local cValor	:= 0	//Valor do vale presente

Default cValPre := ""
Default oMdlDtl := Nil

ParamType 0 Var 	cValPre 	As Character	Default 	""
ParamType 1 Var  oMdlDtl        As Object	Default Nil

If !Empty(cValPre) .AND. STBVldVp(oMdlDtl, cValPre)
	/*
		Valida algumas validacoes do vale presente que o usuario informou
	*/
	If Empty(cMsg := STBValidVP(cValPre))
	
		/*
			Consulta o valor do vale presente
		*/
		cValor := STBValorVP(cValPre)
					
	Else
		STFMessage("STWPayGiftV","STOP",cMsg)
		STFShowMessage("STWPayGiftV")	
	EndIf

EndIf

Return cValor

