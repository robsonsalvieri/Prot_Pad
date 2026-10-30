#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'

/*/{Protheus.doc} MATA010EVPE
Eventos especificos para tratar chamadas a pontos de entrada já suportados pelo MVC.

Essa classe existe para manter o legado dos pontos de entrada do MATA010 quando não era MVC.
Os pontos de entrada são chamados nos mesmos momentos que é chamado no MATA010 sem MVC.

O ideal é que os clientes passem a usar o ponto de entrada do MVC e aos poucos não exista 
mais a necessidade de manter a compatibilidade com o legado. Quando isso acontecer, basta
remover a instalação dessa classe no modelo MATA020.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA010EVPE FROM FWModelEvent
	
	DATA nOpc
	DATA cIDSB1
	
	DATA l010TOk
	DATA l010Inc
	DATA l010Alt
	DATA l010E
	DATA l010TOKExc
	DATA l010Exc
	DATA l010LinAlterna
	Data lM010B5CP	

	
	METHOD New() CONSTRUCTOR
	METHOD FieldPosVld()
	METHOD InTTS() 
	METHOD BeforeTTS()
	METHOD GridLinePosVld()
	METHOD Activate( oModel, lCopy )
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cIDSB1) CLASS MATA010EVPE
Default cIDSB1 := "SB1MASTER"
	
	::cIDSB1 			:= cIDSB1	
	::l010TOk   		:= Existblock("A010TOK")
	::l010Inc   		:= ExistBlock("MT010INC")
	::l010Alt   		:= ExistBlock("MT010ALT")
	::l010E     		:= ExistBlock("MTA010E")
	::l010TOKExc 		:= ExistBlock("MTA010OK")
	::l010Exc   		:= ExistBlock("MT010EXC")
	::l010LinAlterna 	:= ExistBlock("MT010LIN")
	::lM010B5CP		:= ExistBlock("M010B5CP")	

Return

METHOD FieldPosVld(oSubModel, cID) CLASS MATA010EVPE
Local lRet := .T.
	
	If cID == ::cIDSB1
		::nOpc := oSubModel:getOperation()
		
		If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
			If ::l010TOk
				lRet:= Execblock("A010TOK",.F.,.F.)
				If ValType(lRet) # "L"
					lRet :=.T.
				EndIf
			EndIf
		ElseIf ::nOpc == MODEL_OPERATION_DELETE
			If ::l010TOKExc
				lRet := ExecBlock("MTA010OK",.f.,.f.)
				If ValType(lRet) <> "L"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lRet

METHOD InTTS(oModel) CLASS MATA010EVPE
	
	If ::l010Inc .And. ::nOpc == MODEL_OPERATION_INSERT
		ExecBlock("MT010INC",.F.,.F.)
	EndIf
	
	If ::l010Alt .And. ::nOpc == MODEL_OPERATION_UPDATE
		ExecBlock("MT010ALT",.f.,.f.)
	EndIf
	
	If ::l010E .And. ::nOpc == MODEL_OPERATION_DELETE
		ExecBlock("MTA010E",.f.,.f.)
	EndIf
	
Return

METHOD BeforeTTS(oModel) CLASS MATA010EVPE
	
	If ::l010Exc .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		ExecBlock("MT010EXC",.F.,.F.)
	EndIf
	
Return

METHOD GridLinePosVld(oGridModel, cID) CLASS MATA010EVPE
Local lRet := .T.
	
	If cID == "SGIDETAIL"
		If ::l010LinAlterna
			lRet := ExecBlock("MT010LIN",.F.,.F.)
			If ValType(lRet) <> "L"
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet

METHOD Activate( oModel, lCopy ) CLASS MATA010EVPE
Local lRet 	:= .T.
Local xModel	:= Nil
Local nOpcx	:= oModel:GetOperation()

Default lCopy	:= .F.

// SB5 - PE que permite limpar o conteúdo dos campos de complemento de produto
If Self:lM010B5CP .And. lCopy .And. nOpcx == MODEL_OPERATION_INSERT
	xModel := oModel:GetModel( 'SB5DETAIL' )
	lRet :=	ExecBlock( 'M010B5CP',.F.,.F., { xModel, nOpcx, lCopy } )
	lRet := IIf( ValType( lRet ) <> "L", .T., lRet ) 
EndIf

Return lRet