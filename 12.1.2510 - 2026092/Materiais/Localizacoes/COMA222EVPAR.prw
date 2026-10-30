#include 'Protheus.ch'
#include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA222EVPAR
Eventos de regras de negócio específicas para a localização Paraguai

@author cleber.denisp
@since 07/11/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Class COMA222EVPAR From FWModelEvent

	Method New() CONSTRUCTOR
	Method AfterTTS()
	Method RegPagos()

EndClass

//-----------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@type Method
@return Nil
@author cleber.denisp
@since 07/11/2025
@version P12.1.2410
/*/
//-----------------------------------------------------------------
Method New() CLASS COMA222EVPAR

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} AfterTTS(oModel, cModelId)
Método responsável por executar as regras de negócio após a 
transação do modelo de dados.

@type Method
@param 		oModel	,objeto		,Modelo de dados
@param 		cID   	,caracter	,Identificador do modelo
@return 	Nil
@author cleber.denisp
@since 07/11/2025
@version P12.1.2410
*/
//-----------------------------------------------------------------
Method AfterTTS(oModel,cID) Class COMA222EVPAR
    Local nOpc := oModel:GetOperation()

    If nOpc == MODEL_OPERATION_INSERT	
        self:RegPagos()
    EndIf
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} RegPagos
Método responsável por mostrar a tela para registrar o pagamento da
fatura quando for autofactura e condição de pagamento a vista.

@type Method
@return Nil
@author cleber.denisp
@since 07/11/2025
@version P12.1.2410
*/
//-----------------------------------------------------------------
Method RegPagos() Class COMA222EVPAR
	Local lAutoFact As Logical
	Local lContado  As Logical

	lAutoFact := SF1->F1_AUTOFAC == "1"
	lContado  := POSICIONE("SE4",1,XFILIAL("SE4") + SF1->F1_COND,"E4_BXTITAV") == "1"

	If lAutoFact .and. lContado
		M486PAGOS(SF1->F1_ESPECIE, SF1->F1_DOC, SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_COND,SF1->F1_VALBRUT,4,.T.)
	EndIf
Return Nil
