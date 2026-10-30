#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STIPANBUTTONS.CH"                       

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanBtnSale
Painel de Botoes de Contexto

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanBtnSale( oPanel )

Local oPanBtnSale  		:= Nil
Local nBtnHeight		:= 0
Local nBtnWidth	   		:= 0
Local nSpace	   		:= 0
Local nPercSpace		:= 0.015
Local nPanHeightPerc	:= 0.15

If oPanel <> Nil
	
	/*/
		Panel Botoes da Venda
	/*/	    
	oPanBtnSale := 	TPanel():New(00,00,"",oPanel,,,,,,oPanel:nWidth/2,oPanel:nHeight/2 * nPanHeightPerc)    
	
	/*/
		Espaco unico definido a partir do percentual referente à largura
	/*/	
	nSpace			:= ((oPanBtnSale:nWidth/2) * nPercSpace)
   	
	nBtnHeight		:= ( oPanBtnSale:nHeight/2 - (3 * nSpace) ) / 2
	
	nBtnWidth		:= ( (oPanBtnSale:nWidth/2) - ( 4 * nSpace )  ) / 3
				
	/*/
		Registro de Item
	/*/
	@ nSpace , nSpace BUTTON STR0001 SIZE nBtnWidth , nBtnHeight PIXEL ACTION STIExchangePanel( { || STIPanItemRegister() } ) OF oPanBtnSale	 //"Registro de Item"
	   	
	/*/
		Cliente / CPF
	/*/
   	@ nSpace , nSpace + nBtnWidth + nSpace BUTTON STR0002 SIZE nBtnWidth , nBtnHeight PIXEL ACTION MSGALERT(STR0002) OF oPanBtnSale //"Cliente / CPF"
	   	
	/*/
		Cancelar Item
	/*/
   	@ nSpace , nSpace + nBtnWidth + nSpace + nBtnWidth + nSpace BUTTON STR0003 SIZE nBtnWidth , nBtnHeight PIXEL ACTION STICancelItem() OF oPanBtnSale //"Cancelar Item"

	/*/
		Orçamento
	/*/
   	@ nSpace + nBtnHeight + nSpace , nSpace BUTTON STR0004 SIZE nBtnWidth , nBtnHeight PIXEL ACTION STIImportSale() OF oPanBtnSale //"Orçamento"
   	
   	/*/
		Desconto na Venda
	/*/
   	@ nSpace + nBtnHeight + nSpace , nSpace + nBtnWidth + nSpace BUTTON STR0005 SIZE nBtnWidth , nBtnHeight PIXEL ACTION STIDiscountTotal() OF oPanBtnSale //"Desconto na Venda"
   	
   	/*/
		Consultar Produto
	/*/
   	@ nSpace + nBtnHeight + nSpace , nSpace + nBtnWidth + nSpace + nBtnWidth + nSpace BUTTON STR0006 SIZE nBtnWidth , nBtnHeight PIXEL ACTION STIConsult() OF oPanBtnSale //"Consultar Produto"
	   	
EndIf

Return(oPanBtnSale)

