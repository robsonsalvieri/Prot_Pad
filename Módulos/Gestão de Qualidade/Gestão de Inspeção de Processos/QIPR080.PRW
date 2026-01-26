#INCLUDE "QIPR080.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR080   ºAutor  ³Leandro Sabino      º Data ³  20/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Instrumento X Lotes			                              º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QIPR080()
Local oReport := NIL

	// Variaveis utilizadas para parametros         
	// mv_par01             // Da Data de Medição
	// mv_par02             // At‚ Data de Medição
	// mv_par03             // Do Instrumento
	// mv_par04             // At‚ Instrumento
	Pergunte("QPR080",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 20/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo  	    := STR0003	//"Instrumento x Lote"
Local cDesc1 		:= STR0001	//"SerÆo relacionados os Instrumentos utilizados em cada Lote."
Local oSection1 

DEFINE REPORT oReport NAME "QIPR080" TITLE cTitulo PARAMETER "QPR080" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "TRB" TITLE TitSX3("QPR_PRODUT")[1]
DEFINE CELL NAME "PRODUT" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_PRODUT")[1]) SIZE (TamSx3("QPR_PRODUT")[1])
DEFINE CELL NAME "REVI"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_REVI")[1])   SIZE (TamSx3("QPR_REVI")[1])
DEFINE CELL NAME "OP"     OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_OP")[1])     SIZE (TamSx3("QPR_OP")[1])
DEFINE CELL NAME "DTENTR" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_DTENTR")[1]) SIZE (TamSx3("QPR_DTENTR")[1])
DEFINE CELL NAME "LOTE"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_LOTE")[1])   SIZE (TamSx3("QPR_LOTE")[1])
DEFINE CELL NAME "DTMEDI" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_DTMEDI")[1]) SIZE (TamSx3("QPR_DTMEDI")[1])

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Instrumento X Lotes         							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oSection1  := oReport:Section(1)
Local cQPT_INSTR := TitSX3("QPT_INSTR")[1] 
Local cInstr     := ""
Local cChave     := ""
Local aArea	   := GetArea()


// Cria Arquivo de Trabalho

MakeSqlExpr(oReport:uParam)

oSection1:BeginQuery()
		
 	BeginSQL Alias "TRB"  
 
	COLUMN DTENTR AS DATE
	COLUMN DTMEDI AS DATE

 	SELECT 	QPR.QPR_DTENTR DTENTR, QPT.QPT_INSTR INSTR, QPR.QPR_PRODUT PRODUT,
	 	    QPR.QPR_REVI REVI    , QPR.QPR_OP OP      , QPT.QPT_CODMED CODMED, 
	 	    QPR.QPR_DTMEDI DTMEDI, QPR.QPR_LOTE LOTE 
 	FROM  %table:QPT% QPT, %table:QPR% QPR 
	WHERE 
	 QPT.QPT_FILIAL  = %xFilial:QPT%  And QPR.QPR_FILIAL  = %xFilial:QPR%  And 
	 QPR.QPR_DTMEDI Between %Exp:Dtos(mv_par01)% And %Exp:Dtos(mv_par02)% And 
	 QPT.QPT_INSTR  Between %Exp:mv_par03% And %Exp:mv_par04% And 
	 QPT.QPT_CODMED = QPR.QPR_CHAVE And 
	 QPT.%notDel% And QPR.%notDel%
	 
	GROUP BY QPR.QPR_DTENTR,QPT.QPT_INSTR,QPR.QPR_PRODUT,QPR.QPR_REVI,QPR.QPR_OP,QPT.QPT_CODMED,QPR.QPR_DTMEDI,QPR.QPR_LOTE			

	ORDER BY QPR_DTENTR, QPT_INSTR, QPR_PRODUT

   EndSql
   
oSection1:EndQuery()

dbSelectArea("TRB")
dbGoTop()

While !oReport:Cancel() .And. TRB->(!Eof())
	If cChave <> TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)
		If cInstr != TRB->INSTR
			If !Empty(cInstr)
				oSection1:Finish()
			EndIf
			oSection1:Init()
			oReport:SkipLine(1) 
			oReport:ThinLine()
			oReport:PrintText(cQPT_INSTR+": "+TRB->INSTR,oReport:Row(),025) //"Instrumento" 
			oReport:SkipLine(1)	
			oReport:ThinLine()
			cInstr := TRB->INSTR	
	    Endif
		oSection1:PrintLine()
		cChave := TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)	
	Endif
	TRB->(dbSkip())
EndDo

oSection1:Finish()
TRB->(DbCloseArea())

RestArea(aArea)

Return
