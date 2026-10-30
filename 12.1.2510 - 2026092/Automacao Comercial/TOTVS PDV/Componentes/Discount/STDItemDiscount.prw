#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDTime
Busca configuração de momento de desconto por usuário, se antes ou despois de registrar o item

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  cTime 			Retorna configuração de momento de efetuar desconto no Item via usuário
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDTime()

Local cTime		:= "A"		// Retorna configuração de momento de efetuar desconto no Item via usuário
Local aDados	:= {"15", space(20)} // Pega Estatus 15 do ECF para saber se permite desconto apos registrar o item
Local aRet		:= {}

/*/
	"A" - 	Antes (Padrao)
	"D" - 	Depois
/*/


/*/
	Se utiliza impressora fiscal, utiliza
	Verifica se o ECF permite desconto apos registrar o item
/*/
If STFUseFiscalPrinter()

	aRet := STFFireEvent( 	ProcName(0)			,; // Nome do processo
								"STPrinterStatus" 	,; // Nome do evento
								@aDados 				)

	// 0-Arredonda 	1-Trunca
	If !Empty(aRet) .AND. aRet[1] == 1
		cTime := "A" //Antes
	Else
		cTime := "D"	//Depois
	EndIf

EndIf

Return cTime




//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDUseDiscountFrom
Efetua Desconto no Item

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  cConfig 			Retorna configuração de desconto no item quanto a aplicar descontos via usuário, via regra ou ambos
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDUseDiscountFrom()

Local cConfig		:= ""		// Retorna configuração de desconto no item quanto a aplicar descontos via usuário, via regra ou ambos

/*/
	Fazer Facilitador para configuração se usa desconto via usuário, via regra ou ambos
	"U" - Usuário
	"R" - Regra de Desconto
	"A" - Ambos
/*/
cConfig := STFGetCfg("cCtrlDesc")

// Tratamento para corrigir informação do parâmetro caso venha preenchido com ""
// Necessário para não alterar boletim técnico
If Len(cConfig) > 1
	cConfig := SubStr(cConfig,2,1)
EndIf

Return cConfig


//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDReasonDiscount
Busca configuração se Registra Motivo de Desconto quando uma Regra de Desconto é aplicada

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet 			Retorna configuração se Registra Motivo quando uma Regra de Desconto é aplicada
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDReasonDiscount()

Local lRet		:= .F.		// Retorna configuração se Registra Motivo quando uma Regra de Desconto é aplicada

lRet := .T.

Return lRet
