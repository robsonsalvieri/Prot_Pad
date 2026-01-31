#INCLUDE "PROTHEUS.CH"

Static aVlrVP := {}
Static aCodVP := {}

//-------------------------------------------------------------------
/*{Protheus.doc} STBGetMinMaxVP
Retorna o valor minimo e maximo do vale presente 

@param  cCodProduto  codigo do produto
@author  Varejo
@version P1180
@since   14/01/2015
@return  aRes valor minino e maximo vale presente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetMinMaxVP(cCodProduto)

Local aRes := {}
Local lRet := .F.

Default cCodProduto := 0

lRet := STBRemoteExecute("STDGetMinMaxVP" ,{cCodProduto}, NIL,.F., @aRes)

Return aRes

//-------------------------------------------------------------------
/*{Protheus.doc} STBSetVlrVP
Adiciona à um array os valores dos vales presentes vendidos venda variavel

@param  cCodVP  codigo vale presente
@param  nValor  valor do vale presente
@author  Varejo
@version P1180
@since   14/01/2015
@return  aRes valores vales presentes
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSetVlrVP(cCodVP,nValor)

Default cCodVP := ""
Default nValor := 0

If !Empty(cCodVP)
	AAdd(aVlrVP, {cCodVP, nValor})
Else
	aVlrVP := {}
EndIf
	
Return aVlrVP

//-------------------------------------------------------------------
/*{Protheus.doc} STBGetVlrVP
Recupera array com os valores dos vales presentes vendidos

@param  
@author  Varejo
@version P1180
@since   14/01/2015
@return  aVlrVP  valores dos vales presentes
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetVlrVP()
Return aVlrVP

//-------------------------------------------------------------------
/*{Protheus.doc} STBIsGiftCard
Verifica se o produto é vale presente.

@param  
@author  Varejo
@version P1180
@since   24/02/2015
@return  lRet	.T. -> Produto Vale presente / .F. -> Produto não é vale presente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBIsGiftCard(cCodProd)
Return FindFunction("STDGGiftCard") .And. STDGGiftCard(cCodProd) == "1" //1-Sim /2->Nao	

//-------------------------------------------------------------------
/*{Protheus.doc} STBGetCodVP
Recupera codigo do vale presente registrado

@param  
@author  Varejo
@version P1180
@since   24/03/2015
@return  aCodVP  codigo do vale presente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCodVP() 
Return aCodVP

//-------------------------------------------------------------------
/*{Protheus.doc} STBSetCodVP
Seta codigo do vale presente registrado

@param  cCodigo codigo do vale presente
@author  Varejo
@version P1180
@since   24/03/2015
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSetCodVP(cCodigo)

Default cCodigo := ""

If !Empty(cCodigo)
	aAdd(aCodVP , cCodigo)
Else
	aCodVP := {}
EndIf	

Return 

//-------------------------------------------------------------------
/*{Protheus.doc} STBExistVP
Verifica se existe vale presente na venda

@param  
@author  Varejo
@version P1180
@since   10/06/2015
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBExistVP()

Local lRet := .F.

If STDExistVP()
	lRet := .T.	
EndIf

Return lRet