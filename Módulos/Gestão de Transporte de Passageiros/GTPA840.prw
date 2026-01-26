#INCLUDE "GTPA840.ch"
#include 'TOTVS.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GTPA840  ³ Autor ³João P. Pires    ³ Data ³23.10.2024  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contabilizacao OFF LINE (GIC)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GTPA840()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaGTP - Transporte de Passageiros                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GTPA840()

Local aButtons       := {}
Local nOpca          := 0
Local bProcesso      := {|oSelf|nOpca:=1}
Local cDescription	:= STR0002 //"Este programa tem como finalidade gerar a Contabilizacao OFF LINE dos movimentos de Bilhetes (GIC) ... "
Local oTProces
Private cCadastro    := STR0001 //"Contabilizacao OFF LINE de Bilhetes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³
//³ mv_par03 - Data Inicial   ?                                  ³
//³ mv_par04 - Data Final     ?                                  ³
//³ mv_par05 - Agencia Inicial ?       
//³ mv_par06 - Agencia Final ?       
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("GTA840",.F.)

ProcLogIni(aButtons,"GTPA840")

oTProces := tNewProcess():New( "GTPA840" , cCadastro, bProcesso , cDescription, "GTA840")
oTProces:SaveLog(OemToAnsi(STR0003)) //"Finalizado com sucesso."


If nOpca == 1	

		If !(GIC->(FieldPos("GIC_LA")) > 0)
			
			Alert(STR0004) //"Banco de dados desatualizado!"

		Else
			Begin Transaction				
				FWMsgRun(, {|oSelf| GTPA840Proc(oSelf)},STR0005,STR0006) //"Aguarde" "Contabilizando..."
			End Transaction
		Endif
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    GTPA840Proc ³ Autor ³ João Pires ³ Data ³23.10.2024³          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa Contabilizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GTPA850                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function GTPA840Proc(oSelf)

Local cQuery      := ''
Local cAliasNew   := ''
Local cArqTRB     := ''
Local lCriaHead   := .T.
Local aRecGICEmi  := {}
Local nCntFor     := 1
Local aArea       := GetArea()
Local lDigita     := .F.
Local lAglutina   := .F.
Local dData       := dDataBase
Local lCtbOk	  := .F.
Local aDadosDev	  := {}
Local nRecno	  := 0

Private nHdlPrv            				// Endereco do arquivo de contra prova dos lanctos cont.
Private lCriaHeader := .T. 				// Para criar o header do arquivo Contra Prova
Private cLoteGTP	:= "8888"           // Numero do lote para lancamentos do GTP
Private nTotal := 0        				// Total dos lancamentos contabeis
Private cArquivo           				// Nome do arquivo contra prova

cArqTRB := CriaTrab(Nil,.F.)
ProcLogIni({},"GTPA840")
ProcLogAtu("INICIO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona numero do Lote para Lancamentos do GTP             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasNew := GetNextAlias()
cQuery := " SELECT GIC_DTVEND, GIC_STATUS,GIC_CHVBPE, GIC.R_E_C_N_O_ AS NRECNO FROM "+RetSqlName('GIC') + " GIC WHERE "
cQuery += " GIC_STAPRO = '1' AND GIC_DTVEND BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
cQuery += " AND GIC_FILIAL = '"+xFilial('GIC')+"' "
cQuery += " AND GIC_LA <> 'S' AND GIC.D_E_L_E_T_ = ' ' "
If !Empty(MV_PAR06)
	cQuery += " AND GIC_AGENCI >= '"+ALLTRIM(MV_PAR05)+"' AND GIC_AGENCI <= '"+ALLTRIM(MV_PAR06)+"' "
Endif
cQuery += " ORDER BY GIC_DTVEND,GIC_STATUS DESC"
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
TCSetField(cAliasNew,"GIC_DTVEND","D",8,0)

DBSelectArea('GIC')

While (cAliasNew)->(!Eof())
	dData  		:= (cAliasNew)->GIC_DTVEND
	lCriaHead  	:= .T.
	nTotal      := 0

	While (cAliasNew)->(!Eof()) .And. dData == (cAliasNew)->GIC_DTVEND
		IF lCriaHead
			nHdlPrv := HeadProva(cLoteGTP,"GTPA840",cUserName,@cArquivo)			
			lCriaHead := .F.
		ENDIF

		IF (cAliasNew)->GIC_STATUS == 'C'
			aDadosDev	:= {}
			RetDadosDev("",(cAliasNew)->GIC_CHVBPE, @aDadosDev) //Traz o bilhete de origem para pegar o recno
			nRecno := IIF(Len(aDadosDev) > 0, aDadosDev[7],0)
		ELSE
			nRecno := (cAliasNew)->NRECNO
		ENDIF

		GIC->(dbGoTo(nRecno))
		IF (cAliasNew)->GIC_STATUS $ 'V#T#I#E' 
			nTotal += DetProva(nHdlPrv,'G02',"GTPA840",cLoteGTP)
		ELSEIF (cAliasNew)->GIC_STATUS == 'C'
			nTotal += DetProva(nHdlPrv,'G01',"GTPA840",cLoteGTP)
		ENDIF

		AADD(aRecGICEmi, { (cAliasNew)->NRECNO, (cAliasNew)->GIC_DTVEND } )

		(cAliasNew)->(DBSkip())
	Enddo

	If nTotal > 0
		RodaProva(nHdlPrv,nTotal)
		lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
		lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
		//-- Envia para Lan‡amento Cont bil
		lCtbOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteGTP,lDigita,lAglutina,,dData)
		
		If lCtbOk
			For nCntFor := 1 To Len(aRecGICEmi)
				GIC->(dbGoTo(aRecGICEmi[nCntFor,1]))
				RecLock('GIC',.F.)				
				GIC->GIC_LA		:= 'S'
				MsUnLock()
			Next
		Endif

	Endif

	(cAliasNew)->(DBSkip())
Enddo
ProcLogAtu("FIM")

RestArea(aArea)

Return Nil
