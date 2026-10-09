#INCLUDE "JURG001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "MSGRAPHI.CH"

// Vetores dos totais mensais
#DEFINE MESES_MESANO  1
#DEFINE MESES_MESANOD 2
#DEFINE MESES_TOTAL   3


//------------------------------------------------------------------------
/*/{Protheus.doc} JURG001
Grafico de processos abertos e encerrados mês a mês

@author Ernani Forastieri
@since 05/11/2013
@version P11
/*/
//------------------------------------------------------------------------
Function JURG001( oOwner )
Local aButton := {}
Local aSay    := {}
Local lOk     := .F.

// Mensagens de Tela Inicial
aAdd( aSay, STR0004 ) //Esta rotina irá gerar um grafico mês a mês,
aAdd( aSay, STR0005 ) //referente aos processos abertos e encerrados.

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

dbSelectArea( 'NSZ' )

FormBatch( STR0006,  aSay,  aButton ) //Gráfico de processos abertos e encerrados mês a mês

If lOk .And. Pergunte( 'JURG001', .T. ) 

	//<- Validação do código do assunto juridico ->
	If VCodAssJur(MV_PAR05)

		If !lOk .OR. !ApMsgYesNo( STR0007 ) //Confirma geração do gráfico ?
			Return NIL
		EndIf
		
		MsgRun( STR0008, '', { || Processa( oOwner ) } ) //Gerando gráfico, aguarde...
	Else
		//JurMsgErro("Atenção!"+CRLF+CRLF+"Verificar o código do assunto jurídico na tela de paramêtros."+CRLF +"Valor inválido.")
		JurMsgErro( STR0001 + CRLF+CRLF + STR0002 + CRLF + STR0003 )
	EndIf
EndIf

Return NIL


//------------------------------------------------------------------------
/*/{Protheus.doc} Processa
Processamento dos dados

@author Ernani Forastieri
@since 05/11/2013
@version P11
/*/
//------------------------------------------------------------------------
Static Function Processa( oOwner )
Local aArea       := GetArea()
Local aMesesAbe   := {}
Local aMesesEnc   := {}
Local aParams     := {}
Local cAlias      := ''
Local cCampo      := ''
Local cLit        := ''
Local cQuery      := ''
Local dAux 		  := CtoD( '' )
Local dDataRet    := CtoD( '' )
Local dFimPeriodo := CtoD( '' )
Local dIniPeriodo := CtoD( '' )
Local lEntIncl    := .T.
Local nMeses      := 0
Local nPos        := 0
Local nTipoGraf   := 0
Local nX          := 0

nMeses      := MV_PAR01
dDataRet    := CtoD( '15/' + StrZero( MV_PAR02, 2 ) + '/' + StrZero( MV_PAR03, 4 ) )
dIniPeriodo := FirstDay( MonthSub( dDataRet, nMeses ) )
dFimPeriodo := LastDay( dDataRet )
lEntIncl    := ( MV_PAR04 == 1 )
cAssunto    := MV_PAR05
nTipoGraf   := MV_PAR06

//
// Prepara vetor dos meses
//
dAux :=  dDataRet
For nX := nMeses To 1 Step -1
	aAdd( aMesesAbe,  { SubStr( DToS( dAux ), 1, 6 ), SubStr(MesExtenso(Month(dAux)),1,3)+'/'+ SubString(StrZero(Year(dAux),4),3,2), 0 } )
	dAux := MonthSub( dAux, 1 )
Next
aMesesEnc := aClone( aMesesAbe)


//
// Obtem os dados abertura
//
If lEntIncl
	cCampo := 'NSZ_DTENTR'
	cLit   := STR0009 //Data de Entrada
Else
	cCampo := 'NSZ_DTINCL'
	cLit   := STR0010 //Data de Inclusão
EndIf


cQuery := " SELECT MESANO, COUNT( * ) TOTAL FROM ("
cQuery += " SELECT SUBSTRING( " + cCampo + ", 1, 6) MESANO"
cQuery += " FROM " + RetSQLName( 'NSZ'  )
cQuery += " WHERE NSZ_FILIAL = ?"
cQuery +=   " AND " + cCampo + " BETWEEN ? AND ?"
cQuery +=   " AND NSZ_TIPOAS = ?"
cQuery +=   " AND D_E_L_E_T_ = ' ' ) AAAAMM"
cQuery +=   " GROUP BY MESANO "


aAdd( aParams, xFilial("NSZ") )
aAdd( aParams, DToS( dIniPeriodo ) )
aAdd( aParams, DToS( dFimPeriodo ) )
aAdd( aParams, cAssunto)

cQuery := ChangeQuery( cQuery )


cAlias := GetNextAlias()

DbUseArea( .T., 'TOPCONN', TCGenQry2(NIL, NIL, cQuery, aParams), cAlias, .T., .F. )

While !(cAlias)->( EOF() )

	If ( nPos := aScan( aMesesAbe, { |aX| aX[MESES_MESANO] == (cAlias)->MESANO } ) ) > 0
		aMesesAbe[nPos][MESES_TOTAL] := (cAlias)->TOTAL
	EndIf

	(cAlias)->( dbSkip() )
End


(cAlias)->( dbCloseArea() )
aSize(aParams, 0)

aSort( aMesesAbe, , , { |aX,aY| aX[MESES_MESANO] < aY[MESES_MESANO] } )

//
// Obtem os dados encerramentos
//
cQuery := " SELECT MESANO, COUNT( * ) TOTAL FROM ("
cQuery += " SELECT SUBSTRING(NSZ_DTENCE,1,6) MESANO FROM " + RetSQLName( 'NSZ'  )+ " "
cQuery += " WHERE NSZ_FILIAL = ?"
cQuery +=   " AND NSZ_TIPOAS = ?"
cQuery +=   " AND NSZ_SITUAC = ?"
cQuery +=   " AND NSZ_DTENCE BETWEEN ? AND ?"
cQuery +=   " AND D_E_L_E_T_ = ' ' ) AAAAMM"
cQuery +=   " GROUP BY MESANO "

aAdd( aParams, xFilial( 'NSZ' ))
aAdd( aParams, cAssunto)
aAdd( aParams, "2")
aAdd( aParams, DToS( dIniPeriodo ))
aAdd( aParams, DToS( dFimPeriodo ))

cQuery := ChangeQuery( cQuery )

DbUseArea( .T., 'TOPCONN', TCGenQry2(NIL, NIL, cQuery, aParams), cAlias, .T., .F. )

While !(cAlias)->( EOF() )

	If ( nPos := aScan( aMesesEnc, { |aX| aX[MESES_MESANO] == (cAlias)->MESANO } ) ) > 0
		aMesesEnc[nPos][MESES_TOTAL] := (cAlias)->TOTAL
	EndIf

	(cAlias)->( dbSkip() )
End

(cAlias)->( dbCloseArea() )

aSort( aMesesEnc, , , { |aX,aY| aX[MESES_MESANO] < aY[MESES_MESANO] } )
aSize(aParams, 0)

dbSelectArea( 'NSZ' )

Grafico( oOwner, aMesesAbe, aMesesEnc, nTipoGraf, cLit, cAssunto )

RestArea( aArea )

Return NIL


//------------------------------------------------------------------------
/*/ { Protheus.doc } Grafico
Geracao do Grafico

@author Ernani Forastieri
@since 05/11/2013
@version P11
/*/
//------------------------------------------------------------------------
Static Function Grafico( oOwner, aMesesAbe, aMesesEnc, nTipoGraf, cLit, cAssunto )
Local aCoors    := {}
Local nX        := 0
Local oGrafico  := Nil
Local oDlgRel   := Nil
local cTitle    := ""  
Local aXAxis    := {}
Local aYAxisAbe := {}
Local aYAxisEnc := {}

If oOwner == NIL
	oOwner := oMainWnd
EndIf

aCoors := FWGetDialogSize( oOwner )

Define Dialog oDlgRel Title STR0006 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Of oOwner Pixel

	oPanel:= TPanel():New( , ,,oDlgRel,,,,,, 0,  50)
	oPanel:Align := CONTROL_ALIGN_TOP
    
	oPanel2:= TPanel():New( , ,,oDlgRel,,,,,, 0,  0)
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	oGrafico := FWChartFactory():New()
	oGrafico:SetOwner(oPanel2)
     
	For nX := 1 To Len( aMesesAbe )
		aAdd(aXAxis, aMesesAbe[nX][MESES_MESANOD])
		aAdd(aYAxisAbe, aMesesAbe[nX][MESES_TOTAL])
		aAdd(aYAxisEnc, aMesesEnc[nX][MESES_TOTAL])
	Next nX

	oGrafico:SetXAxis(aXAxis)
	oGrafico:addSerie(STR0015, aYAxisAbe) //"Abertos"
	oGrafico:addSerie(STR0016, aYAxisEnc) //"Encerrados"
	
	oGrafico:SetLegend(CONTROL_ALIGN_BOTTOM) //Seta a legenda para ficar no rodapé da página
     
	cTitle :=  STR0011 + AllTrim(JURGETDADOS( "NYB",1,xFILIAL('NYB') + cAssunto, "NYB_DESC")) +' - '+ STR0012 + aMesesAbe[1][MESES_MESANOD] + STR0013 + aTail( aMesesAbe)[MESES_MESANOD] + STR0014 + cLit
	oGrafico:SetTitle( cTitle ,CONTROL_ALIGN_CENTER )
	
	//Desativa menu que permite troca do tipo de gráfico pelo usuário
	oGrafico:EnableMenu(.F.)
             
	//Define o tipo do gráfico
	If nTipoGraf == 1
		oGrafico:SetChartDefault(COLUMNCHART)
	Else
		oGrafico:SetChartDefault(NEWLINECHART)
	EndIf
   
	oGrafico:Activate()

Activate Dialog oDlgRel Centered

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} JurEntre
Função Generica para validar esta entre 2 limites

@author TOTVS Protheus
@since  12/11/2013
@version 1.0
/*/
//--------------------------------------------------------------------
User Function JurEntre( xInicial, xFinal, cCampo )
Local lRet := .T.

If ValType( cCampo ) = "U"
	cCampo := &( ReadVar() )
EndIf

If ( cCampo < xInicial ) .OR. ( cCampo > xFinal )
	Help( "", 1, "Help",, I18N( STR0017, { AllTrim( AllToChar( xInicial ) ) , AllTrim( AllToChar( xFinal ) ) , } ) , 1, 1 )
	lRet := .F.
EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} VCodAssJur
Validação do código do assunto jurídico 

@Param cTmpCod -> Código do assunto a ser verificado

@author Rafael Rezende Costa
@since  17/12/2014

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VCodAssJur(cTmpCod)
Local lRet := .F.

	If !EMPTY(cTmpCod) .AND. JurGetDados('NYB', 1, xFilial('NYB') + cTmpCod, 'NYB_COD') <> " "
		lRet := .T.
	EndIf
	
Return lRet
