#Include 'Protheus.ch'   
#INCLUDE "STFScreenColor.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFScreenColor
Função para alterar a cor da Janela do POS
@author  Varejo
@version P11.8
@since   19/06/2013
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFScreenColor()

Local oDlg 		:= NIL  	//Janela
Local oColorT   := NIL      //Color da Janela     
Local oButton1	:= NIL		//botao 1
Local oButton2 	:= NIL		//Botão 2      
Local nColor	:= 0		//Codigo da Cor

DEFINE MSDIALOG oDlg FROM 0,0 TO 430,600 PIXEL TITLE STR0001 //"Cores"

	oColorT	:= tColorTriangle():New(1, 1, oDlg, 300, 200)
	oColorT:SetColorIni( 2 )
	nColor 	:= oColorT:RetColor()
	
	oButton1:=tButton():New(200,1,STR0002,oDlg,{||nColor := STFScrRec(@oColorT,oDlg)},100,20,,,,.T.)     //"Gravar Cor"
	oButton2:=tButton():New(200,200,STR0003,oDlg,{||oDlg:End()},101,20,,,,.T.)    //"Fechar"
	oButton3:=tButton():New(200,100,STR0004,oDlg,{||nColor := STFSetDefault(@oColorT,oDlg)},100,20,,,,.T.)     //"Padrão"
	

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFScrRec
Carrega e Grava a Cor
@param oColor  Objeto Paleta
@param oDlg	   Janela
@author  Varejo
@version P11.8
@since   26/04/2013
@return  oColorT:RetColor() Codigo da Cor
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STFScrRec(oColorT, oDlg)
Local nAzul 		:= 0 	//Codigo da Cor Azul
Local nRestoAzul 	:= 0	//Resto do Codigo da Cor Azul
Local nVerde 		:= 0    //Codigo da Cor Verde
Local nVermelho 	:= 0	//Codigo da Cor Vermelho
Local cRet			:= ""	//Retorno da função

DEFAULT oColorT := NIL
DEFAULT oDlg	:= NIL

nColor := oColorT:RetColor()

nAzul		:= Int(nColor/65536)
nRestoAzul 	:= Mod(nColor,65536)
nVerde		:= Int(nRestoAzul/256)
nVermelho	:= Int(Mod(nRestoAzul,256))

cRet := decToHex(nVermelho,2) + decToHex(nVerde,2) + decToHex(nAzul,2)

PutMv("MV_LJCOLOR" , cRet)

If !Empty(cRet)
	MsgAlert (STR0005) //"Cor gravada com sucesso"   
EndIf


Return oColorT:RetColor()



//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetDefault
Carrega a Cor Default
@param oColor  Objeto Paleta
@param oDlg	   Janela
@author  Varejo
@version P11.8
@since   19/09/2014
@return  oColorT:RetColor() Codigo da Cor
@obs
@sample
/*/

//-------------------------------------------------------------------
Static Function STFSetDefault(oColorT, oDlg)
Local nAzul 		:= 0 	//Codigo da Cor Azul
Local nRestoAzul 	:= 0	//Resto do Codigo da Cor Azul
Local nVerde 		:= 0    //Codigo da Cor Verde
Local nVermelho 	:= 0	//Codigo da Cor Vermelho
Local cRet			:= ""	//Retorno da função
Local cDefCor		:= 		"07334C"


DEFAULT oColorT := NIL
DEFAULT oDlg	:= NIL

nColor := oColorT:RetColor()

nAzul		:= Int(nColor/65536)
nRestoAzul 	:= Mod(nColor,65536)
nVerde		:= Int(nRestoAzul/256)
nVermelho	:= Int(Mod(nRestoAzul,256))

cRet := decToHex(nVermelho,2) + decToHex(nVerde,2) + decToHex(nAzul,2)

PutMv("MV_LJCOLOR" , cDefCor)

If !Empty(cRet)
	MsgAlert (STR0005) //"Cor gravada com sucesso"
EndIf


Return oColorT:RetColor()


