#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFEMP             
Gera o registro EMP da DIEF-CE 

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  17/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFEMP( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "EMP"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local lSM0			:= .F.
Local lC1E			:= .F.
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro EMP, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence
	
	DbSelectArea("SM0") 
	SM0->( DbSetOrder( 1 ) )
	lSM0 := SM0->(MsSeek( cEmpAnt+cFilAnt ))
	
	DbSelectArea("C1E") 
	C1E->( DbSetOrder( 3 ) )
	lC1E := C1E->(MsSeek( xFilial( "C1E" ) + cFilAnt ))
	
	cStrReg	:= cNomeReg
	cStrReg	+= PadR(Iif(lSM0 .And. !Empty(SM0->M0_INSC), SM0->M0_INSC, Space(1)), 9)					//Inscrição Estadual
	cStrReg	+= PadR(Iif(lC1E .And. !Empty(C1E->C1E_NOME), C1E->C1E_NOME, Space(1)), 60)				//Razão Social
	cStrReg	+= GetCRT( cRegime )																				//Regime de recolhimento
	cStrReg	+= Iif(!Empty(aWizard[1][5]), dToS(aWizard[1][5]), Space(8))								//Data Inicio Periodo
	cStrReg	+= Iif(!Empty(aWizard[1][6]), dToS(aWizard[1][6]), Space(8))								//Data Final Periodo
	cStrReg	+= GetTpDIEF(AllTrim(aWizard[1][4]))															//Tipo DIEF
	cStrReg	+= GetFinDIEF(AllTrim(aWizard[1][7]))															//Finalidade DIEF
	cStrReg	+= GetMotDIEF(AllTrim(aWizard[1][8]))															//Motivo
	cStrReg	+= Iif(aWizard[1][13], 'S', 'N')																//Contribuinte de IPI
	cStrReg	+= Iif(aWizard[1][14], 'S', 'N')																//Substituto nas operações de saída
	cStrReg	+= Iif(lC1E, GetContFDI( aWizard ), 'N' )														//Contribuinte do PROVIN-FDI
	cStrReg	+= strZero(Iif(!Empty(aWizard[1][11]),val(aWizard[1][11]), 0), 5)							//Percentual FDI
	cStrReg	+= Iif(!Empty(dToS(aWizard[1][12])), dToS(aWizard[1][12]), Replicate("0",8))				//Vencimento FDI
	cStrReg	+= PadR(Iif(!Empty(aWizard[1][9]), AllTrim(aWizard[1][9]), Space(1)), 20)					//Cod. Transmissor Responsavel 
	cStrReg	+= PadR(Iif(lC1E .And. !Empty(C1E->C1E_EMAIL), C1E->C1E_EMAIL,Space(1)), 50)				//Email
	cStrReg	+= PadR(Iif(!Empty(aWizard[1][3]), AllTrim(aWizard[1][3]), Space(1)), 3)					//Versão do Layout
	
	AddLinDIEF( )
	
	WrtStrTxt( nHandle, cStrReg )
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )
	
	DbCloseArea("C1E")

	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()
	
Recover
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCRT             
Retorna o CRT da Filial Conforme definições da DIEFE-CE

@author David Costa
@since  20/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCRT( cRegime )

If(Empty(cRegime))
	cRegime	:= "00"
Else
	cRegime	:= StrZero(val(cRegime), 2)
EndIf

Return (cRegime)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpDIEF             
Retorna o Tipo da DIEFE Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetTpDIEF( cTpDIEF )

If(!Empty(cTpDIEF))
	Do Case
		Case cTpDIEF == "1 - DIEF"
			cTpDIEF	:= "1"
		Case cTpDIEF == "3 - Inventário"
			cTpDIEF	:= "3"
		Case cTpDIEF == "4 - Centros Comerciais"
			cTpDIEF	:= "4"
		OtherWise 
			cTpDIEF	:= "0"
	EndCase
Else
	cTpDIEF	:= "0"
EndIf

Return (cTpDIEF)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFinDIEF             
Retorna a Finalidade Tipo da DIEFE Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetFinDIEF( cFinDIEF )

If(!Empty(cFinDIEF))
	Do Case
		Case cFinDIEF == "01 - Normal (inclusão)"
			cFinDIEF	:= "01"
		Case cFinDIEF == "02 - Retificação"
			cFinDIEF	:= "02"
		OtherWise 
			cFinDIEF	:= "00"
	EndCase
Else
	cFinDIEF	:= "00"
EndIf

Return (cFinDIEF)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMotDIEF             
Retorna o Motivo da DIEFE Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetMotDIEF( cMotDIEF )

If(!Empty(cMotDIEF))
	Do Case
		Case cMotDIEF == "01 - Mensal"
			cMotDIEF	:= "01"
		Case cMotDIEF == "03 - Baixa cadastral"
			cMotDIEF	:= "03"
		Case cMotDIEF == "04 - Alteração de regime de recolhimento"
			cMotDIEF	:= "04"
		Case cMotDIEF == "05 - Alteração de endereço"
			cMotDIEF	:= "05"
		Case cMotDIEF == "06 - Alteração de sistemática de tributação"
			cMotDIEF	:= "06"
		Case cMotDIEF == "07 - Fiscalização"
			cMotDIEF	:= "07"
		Case cMotDIEF == "09 - Estoque final do Exercício"
			cMotDIEF	:= "09"
		Case cMotDIEF == "10 - Estoque na Baixa Cadastral"
			cMotDIEF	:= "10"
		OtherWise 
			cMotDIEF	:= "00"
	EndCase
Else
	cMotDIEF	:= "00"
EndIf

Return (cMotDIEF)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetContFDI             
Retorna se a Filail é Contribuinte do FDI Conforme definições da DIEFE-CE

@author David Costa
@since  22/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetContFDI( aWizard )

Local cContFDI	:= ''

If (!Empty(dToS(aWizard[1][12])) .And. !Empty(aWizard[1][11]))
	cContFDI := 'S'
Else
	cContFDI := 'N'
EndIf

Return(cContFDI)

