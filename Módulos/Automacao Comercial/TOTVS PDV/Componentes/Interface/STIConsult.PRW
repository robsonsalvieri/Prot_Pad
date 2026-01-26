#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STICONSULT.CH"

Static oSayName			:= Nil
Static oSayValue		:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIConsult
Interface Consulta de Produto

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIConsult()

STIExchangePanel( { || STIPanConsult() } )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanConsult
Contexto Consulta de Produto

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  oPanConsult			Painel Consulta de Produto  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanConsult()

Local oPanConsult		:= Nil 					// Painel Cancelamento de Venda
Local oPanBtnSale  		:= Nil					// Painel de Botões da Venda
Local oPanGetConsult	:= Nil					// Painel de Get de Consulta
Local oPanelMVC			:= STIGetPanel()		// Painel Principal

/*/
	Título - "Consulta de Produto"
/*/
Local nSay1HorPerc		:= 0.015				// Percentual de Posição Horizontal do Say "Consulta de Produto"
/*/
	Say - "Código do Produto"
/*/
Local nSay2HorPerc		:= 0.03					// Percentual de Posição Horizontal do Say "Código do Produto"
Local nSay2VerPerc		:= 0.08			   		// Percentual de Posição Vertical do Say "Código do Produto"
/*/
	Get Codigo do Produto
/*/
Local oCodProd			:= Nil					// TGet Codigo do Produto
Local cGetProd			:= Space(40)			// Variável do Get
Local nGetVerPerc		:= 0.1					// Percentual da Posição Vertical do Get
Local nGetHorPerc		:= 0.03					// Percentual da Posição Horizontal do Get
Local nGetHeiPerc		:= 0.05					// Percentual de Altura do Get
/*/
	Say - "Nome do Produto"
/*/
Local nSay3VerPerc		:= 0.2					// Percentual de Posição Vertical do Say "Nome do Produto"
Local nSay3HorPerc		:= 0.03					// Percentual de Posição Horizontal do Say "Nome do Produto"
/*/
	Say - "Valor"
/*/
Local nSay4VerPerc		:= 0.2					// Percentual de Posição Vertical do Say "Valor"
Local nSay4HorPerc		:= 0.7					// Percentual de Posição Horizontal do Say "Valor"
/*/
	Say - Set do Nome do Produto
/*/
Local oSay5				:= Nil					// Say de Set do Nome do Produto
Local nSay5VerPerc		:= 0.22					// Percentual de Posição Vertical do Say Set do Nome do Produto
Local nSay5HorPerc		:= 0.03					// Percentual de Posição Horizontal do Say Set do Nome do Produto
/*/
	Say - Set do Valor
/*/ 
Local oSay6				:= Nil					// Say de Set do Valor
Local nSay6VerPerc		:= 0.22					// Percentual de Posição Vertical do Say Set do Valor
Local nSay6HorPerc		:= 0.7					// Percentual de Posição Horizontal do Say Set do Valor
/*/
	Botão "Consultar Produto"
/*/
Local oButton			:= Nil					// Botao "Consultar Produto"
Local nBtnWidPerc		:= 0.25			   		// Percentual de Largura do Botão "Consultar Produto"
Local nBtnHeiPerc		:= 0.08			   		// Percentual de Altura do Botão "Consultar Produto"
Local nBtnVerPerc		:= 0.3			   		// Percentual da Posição Vertical do Botão "Consultar Produto"
Local nBtnHorPerc		:= 0.65			   		// Percentual da Posição Horizontal do Botão "Consultar Produto"

/*/
	Panel Consulta de Produto
/*/			
oPanConsult := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)
/*/
	Panel Botoes da Venda
/*/
oPanBtnSale := STIPanBtnSale( oPanConsult )
/*/
	Panel Get do Produto
/*/
oPanGetConsult := TPanel():New(oPanBtnSale:nHeight/2,00,"",oPanConsult,,,,,,oPanConsult:nWidth/2,(oPanConsult:nHeight - oPanBtnSale:nHeight/2)/2)

/*/
	Objetos
/*/
oSay1		:= TSay():New(000,oPanGetConsult:nWidth/2 * nSay1HorPerc,{||STR0001},oPanGetConsult,,,,,,.T.,,,,)  //"Venda > Consulta de Produto"

oSay2		:= TSay():New(oPanGetConsult:nHeight/2 * nSay2VerPerc,oPanGetConsult:nWidth/2 * nSay2HorPerc,{||STR0002},oPanGetConsult,,,,,,.T.,,,,) //"Código do Produto"
                                                        
oCodProd	:= TGet():New(	oPanGetConsult:nHeight/2 * nGetVerPerc,oPanGetConsult:nWidth/2 * nGetHorPerc,{|u| If(PCount()>0,cGetProd:=u,cGetProd)}, ;
							oPanGetConsult,oPanGetConsult:nWidth/2 - (2*nGetHorPerc*oPanGetConsult:nWidth/2) ,oPanGetConsultrod:nHeight/2 * nGetHeiPerc,,,,,,,,.T.,,,,,,,,,,"cGetProd")   	                                
							
oSay3  		:= TSay():New(oPanGetConsult:nHeight/2 * nSay3VerPerc,oPanGetConsult:nWidth/2 * nSay3HorPerc,{||STR0003},oPanGetConsult,,,,,,.T.,,,,)							 //"Nome do Produto"

oSay4  		:= TSay():New(oPanGetConsult:nHeight/2 * nSay4VerPerc,oPanGetConsult:nWidth/2 * nSay4HorPerc,{||STR0004},oPanGetConsult,,,,,,.T.,,,,) //"Valor"							

oSay5  		:= TSay():New(oPanGetConsult:nHeight/2 * nSay5VerPerc,oPanGetConsult:nWidth/2 * nSay5HorPerc,{||Space(40)},oPanGetConsult,,,,,,.T.,,,,)							
oSayName 	:= oSay5

oSay6  		:= TSay():New(oPanGetConsult:nHeight/2 * nSay6VerPerc,oPanGetConsult:nWidth/2 * nSay6HorPerc,{||Space(20)},oPanGetConsult,,,,,,.T.,,,,)							
oSayValue	:= oSay6

oButton		:= TButton():New(	oPanGetConsult:nHeight/2 * nBtnVerPerc,oPanGetConsult:nWidth/2 * nBtnHorPerc,STR0005,oPanGetConsult,{ || STIProdConsult(cGetProd,oSay5,oSay6) }, ;   //"Consultar Produto"
								oPanGetConsult:nWidth/2 * nBtnWidPerc,oPanGetConsult:nHeight/2 * nBtnHeiPerc,,,,.T.) 

oCodProd:SetFocus()
								
Return oPanConsult


//-------------------------------------------------------------------
/*/{Protheus.doc} STIProdConsult
Realiza a Consulta pelo código informado

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIProdConsult(cGetProd)
                          
Local nValue		:= 0			// Valor do Produto
Local aInfoItem		:= {}			// Armazena informações do produto

Default cGetProd	:= ""
Default oSayName	:= Nil
Default oSayValue	:= Nil

If !(Empty(cGetProd)) .AND. (oSayName <> Nil) .AND. (oSayValue <> Nil)

	aInfoItem	:= STWFindItem( AllTrim(cGetProd) )
	
	If Len(aInfoItem) > 0
		
		/*/
			Descrição
		/*/
		oSayName:SetText(aInfoItem[8])
		
		/*/
			Valor
		/*/
		nValue := STBSearchPrice(aInfoItem[2])   		
		oSayValue:SetText( "R$" + " " + cValToChar(nValue) )
	
	Else
	
		STFMessage("STIConsult","STOP",STR0006) //"Item nao Encontrado"
		STFShowMessage("STIConsult")
		
	EndIf
	
EndIf

Return

