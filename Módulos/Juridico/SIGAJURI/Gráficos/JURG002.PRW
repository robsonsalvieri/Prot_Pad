#INCLUDE "JURG002.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "MSGRAPHI.CH"

// Vetores dos totais mensais
#DEFINE MESES_MESANO  1
#DEFINE MESES_MESANOD 2
#DEFINE MESES_TOTAL   3
#DEFINE MESES_DTINI   4
#DEFINE MESES_DTFIM   5


//------------------------------------------------------------------------
/*/{Protheus.doc} JURG002
Grafico de processos em aberto mês a mês

@author Ernani Forastieri
@since 05/11/2013
@version P11
/*/
//------------------------------------------------------------------------
Function JURG002( oOwner )
Local aButton := {}
Local aSay    := {}
Local lOk     := .F.

// Mensagens de Tela Inicial
aAdd( aSay, STR0004 ) //Esta rotina irá gerar um grafico mês a mês, referente
aAdd( aSay, STR0005 ) //as quantidades de processos que estavam em aberto

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

dbSelectArea( 'NSZ' )

FormBatch(  STR0006,  aSay,  aButton ) //Gráfico de processos em aberto

If lOk .And. Pergunte( 'JURG002', .T. ) 
	//<- Validação do código do assunto juridico ->
	If VCodAssJur(MV_PAR05)
		
		If !lOk .OR. !ApMsgYesNo( STR0007) //Confirma geração do gráfico ?
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
/*/ { Protheus.doc } Processa
Processamento dos dados

@author Ernani Forastieri
@since 05/11/2013
@version P11
/*/
//------------------------------------------------------------------------
Static Function Processa( oOwner )
Local aArea       := GetArea()
Local aMeses      := {}
Local cAlias      := ''
Local cCampo      := ''
Local cLit        := ''
Local cQuery      := ''
Local dAux 		  := CtoD( '' )
Local dDataRet    := CtoD( '' )
Local lEntIncl    := .T.
Local nMeses      := 0
Local nTipoGraf   := 0
Local nX          := 0
Local aParams     := {}

nMeses      := MV_PAR01
dDataRet    := CtoD( '15/' + StrZero( MV_PAR02, 2 ) + '/' + StrZero( MV_PAR03, 4 ) )
lEntIncl    := ( MV_PAR04 == 1 )
cAssunto    := MV_PAR05
nTipoGraf   := MV_PAR06

//
// Prepara vetor dos meses
//
dAux :=  dDataRet
For nX := nMeses To 1 Step -1
	aAdd( aMeses,  { ;
	SubStr( DToS( dAux ), 1, 6 ), ;
	SubStr(MesExtenso(Month(dAux)),1,3)+'/'+ SubString(StrZero(Year(dAux),4),3,2), ;
	0, ;
	FirstDay( dAux ),  ;
	LastDay( dAux ) } )
	dAux := MonthSub( dAux, 1 )
Next

// Obtem os dados abertura
If lEntIncl
	cCampo := 'NSZ_DTENTR'
	cLit   := STR0009 //Data de Entrada
Else
	cCampo := 'NSZ_DTINCL'
	cLit   := STR0010 //Data de Inclusão
EndIf

    
cAlias := GetNextAlias()
For nX := 1 To Len( aMeses )
	cQuery := ""
	cQuery += "SELECT COUNT(*) TOTAL, '" + aMeses[nX][MESES_MESANO] + "' MESANO FROM " + RetSQLName( 'NSZ'  )+ " "
	cQuery += "WHERE NSZ_FILIAL = ? "
	cQuery +=    "AND " + cCampo + " <= ? "
	cQuery +=    "AND NSZ_TIPOAS = ? "
	cQuery +=    "AND ( NSZ_DTENCE = '        ' OR NSZ_DTENCE > ? ) "
	cQuery +=    "AND D_E_L_E_T_ = ' ' "

	aAdd( aParams, xFilial("NSZ") )
	aAdd( aParams, DToS( aMeses[nX][MESES_DTFIM] )  )
	aAdd( aParams, cAssunto)
	aAdd( aParams, DToS( aMeses[nX][MESES_DTFIM] ) )
	
	cQuery := ChangeQuery( cQuery )
	
	DbUseArea( .T., 'TOPCONN', TCGenQry2(NIL, NIL, cQuery, aParams), cAlias, .T., .F. )

	aMeses[nX][MESES_TOTAL] := (cAlias)->TOTAL
		
	(cAlias)->( dbCloseArea() )
	aSize(aParams, 0)
Next

aSort( aMeses, , , { |aX,aY| aX[MESES_MESANO] < aY[MESES_MESANO] } )


dbSelectArea( 'NSZ' )

Grafico( oOwner, aMeses, nTipoGraf, cLit, cAssunto )

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
Static Function Grafico( oOwner, aMeses, nTipoGraf, cLit, cAssunto )
Local aCoors    := {}
Local nX        := 0
Local oGrafico  := Nil
Local oDlgRel   := Nil
local cTitle    := ""  
Local aXAxis    := {}
Local aYAxisAbe := {}

If oOwner == NIL
	oOwner := oMainWnd
EndIf

aCoors := FWGetDialogSize( oOwner )

Define Dialog oDlgRel Title STR0011 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Of oOwner Pixel

	oPanel:= TPanel():New( , ,,oDlgRel,,,,,, 0,  50)
	oPanel:Align := CONTROL_ALIGN_TOP
    
	oPanel2:= TPanel():New( , ,,oDlgRel,,,,,, 0,  0)
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	oGrafico := FWChartFactory():New()
	oGrafico:SetOwner(oPanel2)

	
	For nX := 1 To Len( aMeses )
		aAdd(aXAxis, aMeses[nX][2])
		aAdd(aYAxisAbe, aMeses[nX][3])
	Next nX

	oGrafico:SetXAxis(aXAxis)
	oGrafico:addSerie(STR0016, aYAxisAbe) //"Em aberto"
	
	oGrafico:SetLegend(CONTROL_ALIGN_BOTTOM) //Seta a legenda para ficar no rodapé da página
    
	cTitle :=  STR0012 + AllTrim(JURGETDADOS( "NYB",1,xFILIAL('NYB') + cAssunto, "NYB_DESC")) + ' - ' + STR0013 + aMeses[1][MESES_MESANOD] + STR0014 + aTail( aMeses)[MESES_MESANOD] + STR0015 + cLit

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

	If !EMPTY(cTmpCod) .AND. !( JurGetDados('NYB', 1, xFilial('NYB') + cTmpCod, 'NYB_COD') == NIl ) .AND. JurGetDados('NYB', 1, xFilial('NYB') + cTmpCod, 'NYB_COD') <> " "
		lRet := .T.
	EndIf
	
Return lRet