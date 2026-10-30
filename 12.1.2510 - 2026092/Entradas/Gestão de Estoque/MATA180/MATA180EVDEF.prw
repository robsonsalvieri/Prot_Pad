#Include "PROTHEUS.CH"
#include "Mata180.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} MATA180EVDEF
Eventos padrão do Complemento de Produto, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA180EVDEF FROM FWModelEvent
	
	DATA nOpc	
	DATA cIDSB5	
	DATA lHistFiscal	
	DATA bCampoSB5	
	DATA aCmps
	
	METHOD New() CONSTRUCTOR
	METHOD FieldPosVld()
	METHOD InTTS()
	METHOD ModelPosVld(oModel, cModelId)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cID) CLASS MATA180EVDEF
Default cID := "SB5MASTER"

	::cIDSB5 := cID
	
	::lHistFiscal := HistFiscal()
		
	::bCampoSB5 := { |x| SB5->(Field(x)) }
	
	::aCmps := {}
	
Return

METHOD FieldPosVld(oModel, cID) CLASS MATA180EVDEF
Local lRet := .T.
Local cCodigo

	If cID == ::cIDSB5
		::nOpc := oModel:GetOperation()		
		
		If ::nOpc == MODEL_OPERATION_DELETE
			cCodigo := oModel:GetValue(::cIDSB5, "B5_COD")

			If IntDl(cCodigo)
				lRet := WmsVlDelB5(cCodigo)
			EndIf
		EndIf	
	
	EndIf
			
Return lRet

METHOD InTTS(oModel, cID) CLASS MATA180EVDEF

	If ::nOpc == MODEL_OPERATION_DELETE .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If ::lHistFiscal .And. Len(::aCmps) > 0
			GrvHistFis("SB5", "SS5", ::aCmps)			
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} ModelPosVld
Método de pós validação do modelo de dados
@author douglas.heydt
@since 23/01/2020
@version 1.0

@param oModel	- Modelo de dados que será validado
@param cModelId	- ID do modelo de dados que está sendo validado.

@return lReturn	- Indica se o modelo foi validado com sucesso.
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS MATA180EVDEF

	Local lReturn   := .T.
	Local nOpc      := oModel:GetOperation()
	Local oModelSB5 := oModel:GetModel(::cIDSB5)
	Local cProduto  := ""
	Local aAreaSG1  := SG1->(GetArea())
	Local nRecnoSB5 := 0
	
	cProduto := oModel:GetValue(::cIDSB5, "B5_COD")

	::nOpc := oModel:GetOperation()
    
	If cModelId == "MATA180" .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)

		If M->B5_PROTOTI
			
			SG1->(dbSetOrder(1))
			If SG1->(DbSeek(xFilial("SG1") + cProduto))
				lReturn := .F.
				Help( ,  , "A180PROTOT", ,  STR0032,; //"O produto não pode ser definido como protótipo pois faz parte de uma estrutura."
					 1, 0, , , , , , {""}) 
			EndIf
			
			SG1->(dbSetOrder(2))
			If lReturn .And. SG1->(DbSeek(xFilial("SG1") + cProduto))
				lReturn := .F.
				Help( ,  , "A180PROTOT", ,  STR0032,; //"O produto não pode ser definido como protótipo pois faz parte de uma estrutura."
					 1, 0, , , , , , {""}) 
			EndIf

		EndIf
	EndIf

	If ::nOpc == MODEL_OPERATION_DELETE	.Or. ::nOpc == MODEL_OPERATION_UPDATE		
		If ::lHistFiscal
			nRecnoSB5 := SB5->(RECNO())
			SB5->(dbSeek(xFilial("SB5")+cProduto))
			::aCmps := RetCmps("SB5",::bCampoSB5)

			If ::nOpc == MODEL_OPERATION_UPDATE
				oModelSB5:SetValue("B5_IDHIST",IdHistFis())
			EndIf

			SB5->(dbGoTo(nRecnoSB5))
		EndIf			
	EndIf

	RestArea(aAreaSG1)
Return lReturn
