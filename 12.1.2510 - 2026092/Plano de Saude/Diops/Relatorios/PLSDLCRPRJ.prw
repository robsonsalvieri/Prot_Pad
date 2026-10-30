#Include 'Protheus.ch'
#Include 'PLSDLCRPRJ.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDLCRPRJ
Gera relatório DIOPS de lucros e prejuízos.

@author Rodrigo Morgon

@since 14/03/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function PLSDLCRPRJ()

Local cPerg     	:= "PLSDLCRPRJ"
Local cTitulo   	:= STR0001 //"DIOPS - LUCROS OU PREJUÍZOS"
Local cTrimestre	:= ''
Local cAno			:= ''
Local cLivro		:= ''

/* Perguntes da DIOPS Lucros ou Prejuízos:
- Data Inicial		mv_par01
- Data Final		mv_par02
- Cód. Conf. Livros	mv_par03
*/
//Chama a tela de perguntas quando acionado pelo relatorio 
If !Pergunte(cPerg,.T.) .or. Empty(mv_par01) .OR. Empty(mv_par02) .or. Empty(MV_PAR03) 
	MsgInfo( STR0002, STR0003 ) //"É necessário informar todos os parâmetros!"#"Parâmetros obrigatórios"
	Return
EndIf

cTrimestre	:= IIf(Month(MV_PAR02)==3, '1', IIf(Month(MV_PAR02)==6, '2', IIf(Month(MV_PAR02)==9, '3', '4' ) ) )
cAno		:= StrZero(Year(MV_PAR02),4)
cLivro		:= MV_PAR03

PLSDLCRP(cTrimestre, cAno, .T., cLivro)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDLCRP
Localiza dados do CSV após validação do calendário contábil para as datas enviadas por parâmetro.
Modificado para retornar array de atualização do MVC para envio de dados à Central de Obrigações

@author Rodrigo Morgon

@since 14/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSDLCRP(cTrimestre, cAno, lMsg, cLivro)

Local cQuery	:= ""
Local oMeter
Local oTxt
Local oDlg
Local aSetOfBook	:= {}
Local aCtbMoeda 	:= {}
Local cArqTmp		:= GetNextAlias()
Local aDados		:= {}
Local cCabec		:= ""
Local lEnd			:= .F.
Local dDataIni	:= CtoD('')
Local dDataFim	:= CtoD('')
	
Default cTrimestre	:= ''
Default cAno		:= ''
Default lMsg		:= .F.
Default cLivro		:= ''

dDataFim	:= LastDay( CtoD( IIf(cTrimestre=='1','31/03/'+cAno, IIf(cTrimestre=='2','30/06/'+cAno, IIf(cTrimestre=='3','30/09/'+cAno,'31/12/'+cAno) ) ) ) ) 
dDataIni	:= FirstDay( dDataFim - 85 ) 

aSetOfBook	:= CTBSetOf(cLivro)
lEnd := VdSetOfBook(cLivro,.T.)

If lEnd
	//Valida se as datas estão dentro do calendário contábil.
	cQuery := " SELECT CTG_CALEND, CTG_DTINI, CTG_DTFIM FROM " + PLSSQLNAME("CTG")
	cQuery += " WHERE CTG_FILIAL = '" + xFilial("CTG") +"' AND CTG_DTINI >= '" + DTOS(dDataIni) + "'  AND CTG_DTFIM <= '" + DTOS(dDataFim) + "' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTmp,.T.,.F.)
	
	//Verifica se existem registros no arquivo temporário de busca da query
	If (cArqTmp)->(Eof())
		lEnd := .F.
		If lMsg
			MsgInfo( STR0004, STR0005 )//"Intervalo de datas fora do calendário!"#"Problema no calendário."
		EndIf
	EndIf

	dbSelectArea(cArqTmp)
	Set Filter To
	dbCloseArea()

EndIf

If !lEnd
	aDados := { .F. }
	Return(aDados)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Cada linha da chamada da CtGerPlan tem 5 parametros	
//If lMsg
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"CT7","","",;
				Repl("Z", TamSx3("CT1_CONTA")[1]),"",Repl("Z", TamSx3("CTT_CUSTO")[1]),"",Repl("Z", TamSx3("CTD_ITEM")[1]),;
				"",Repl("Z", TamSx3("CTH_CLVL")[1]),"01","1",aSetOfBook,;
				"","","","",.F.,;
				.F.,3,,.F.,dDataFim,;
				1,.T.,,,,;
				,,,,,;
				,,,,,;
				.T.,.T.,,"",,;
				,,,,,;
				,"01",,)},;
				OemToAnsi(OemToAnsi(STR0006)),;
				OemToAnsi(STR0001)) 
/*
Else
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"CT7","","",;
				Repl("Z", TamSx3("CT1_CONTA")[1]),"",Repl("Z", TamSx3("CTT_CUSTO")[1]),"",Repl("Z", TamSx3("CTD_ITEM")[1]),;
				"",Repl("Z", TamSx3("CTH_CLVL")[1]),"01","1",aSetOfBook,;
				"","","","",.F.,;
				.F.,3,,.F.,dDataFim,;
				1,.T.,,,,;
				,,,,,;
				,,,,,;
				.T.,.T.,,"",,;
				,,,,,;
				,"01",,)
EndIF	
*/
	
If lMsg
	aAdd(aDados, "Descrição;Valores")
Else
	aAdd(aDados, .T.)
EndIf

dbSelectArea( "cArqTmp" )
cArqTmp->(dbGoTop())
While cArqTmp->(!Eof())
	//Se não houver entidade superior e o tipo for sintético, pula do array de retorno
	If Empty(cArqTmp->SUPERIOR) .AND. cArqTmp->TIPOCONTA == "1"
		cArqTmp->(DbSkip())	
		Loop		
	EndIf

	If lMsg
		aadd(aDados, alltrim(cArqTmp->DESCCTA)  + ";" + alltrim(cvaltochar(cArqTmp->SALDOATU)))
	Else
		aadd(aDados, { cArqTmp->CONTA, AllTrim(cArqTmp->DESCCTA) , cArqTmp->MOVIMENTO } )		// cArqTmp->SALDOATU } )
	EndIf
	cArqTmp->(DbSkip())
		
EndDo
	
//Limpa arquivo temporário
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

If lMsg	
	//Gera arquivo CSV
	cCabec := "Lucros ou Prejuízos - Data de " + dtoc(mv_par01) + " até " + dtoc(mv_par02) + "."
	cArqCSV	:= "LucrosPrejuizos_"+ StrTran(dtoc(mv_par01), "/", "") + "_" + StrTran(dtoc(mv_par02), "/", "") +".csv"
	If !Empty(PLSGerCSV(cArqCSV, cCabec, aDados))  
		MsgAlert("Arquivo:"+cArqCSV+" gerado com sucesso.")
	EndIf
Else
	// Envia dados para a Central de Obrigações pelo programa PLSMIGLCR.prw
	Return( aDados )
EndIf
	
Return