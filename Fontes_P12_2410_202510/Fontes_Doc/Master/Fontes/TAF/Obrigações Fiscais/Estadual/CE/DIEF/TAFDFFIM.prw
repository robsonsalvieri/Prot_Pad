#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFFIM             
Gera o registro FIM da DIEF-CE 
Registro tipo FIM - Final das informações do contribuinte

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFFIM( aWizard, cRegime )

Local cNomeReg	:= "FIM"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local lSM0			:= .F.
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro FIM, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence
	
	DbSelectArea("SM0") 
	SM0->( DbSetOrder( 1 ) )
	lSM0 := SM0->(MsSeek( cEmpAnt+cFilAnt ))
	
	AddLinDIEF( )
	
	cStrReg	:= cNomeReg
	cStrReg	+= PadR(Iif(lSM0 .And. !Empty(SM0->M0_INSC), SM0->M0_INSC, Space(1)), 9)					//Inscrição Estadual
	cStrReg	+= StrZero( val(GetGlbValue( "cTotLin" )), 10)												//Total de linhas do Arquivo
	
	WrtStrTxt( nHandle, cStrReg )
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )

End Sequence

ErrorBlock(oLastError)

Return

