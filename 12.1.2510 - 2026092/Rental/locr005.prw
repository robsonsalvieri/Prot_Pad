#INCLUDE "locr005.ch" 
#INCLUDE "PROTHEUS.CH"   

/*/{PROTHEUS.DOC} LOCR005.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DISPONIBILIDADE DE FROTA - CAIXA DE PROCESSO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
    
FUNCTION LOCR005()
LOCAL CDESC1         	:= STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
LOCAL CDESC2         	:= STR0002 //"DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC3         	:= STR0003 //"DISPONIBILIDADE DE FROTA - CAIXA DE PROCESSO"
LOCAL TITULO       		:= STR0003 //"DISPONIBILIDADE DE FROTA - CAIXA DE PROCESSO"
LOCAL NLIN         		:= 80
LOCAL CPERG        		:= "LOCR005"
LOCAL CABEC2       		:= ""
LOCAL AORD 				:= {}       
LOCAL IMPRIME  

PRIVATE CABEC1       	:= ""
PRIVATE LEND         	:= .F.
PRIVATE LABORTPRINT  	:= .F.
PRIVATE LIMITE          := 120
PRIVATE TAMANHO         := "G"
PRIVATE NOMEPROG        := "LOCDISFRV1_3" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO           := 18
PRIVATE ARETURN         := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY        := 0
PRIVATE CBTXT      		:= SPACE(10)
PRIVATE CBCONT     		:= 00
PRIVATE CONTFL     		:= 01
PRIVATE M_PAG      		:= 01
PRIVATE WNREL      		:= "LOCDISFRV13" // COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING 		:= ""

	IMPRIME := .T. 

	PERGUNTE(CPERG,.T.)

	WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.T.,AORD,.T.,TAMANHO,,.T.)

	IF NLASTKEY == 27
		RETURN
	ENDIF

	SETDEFAULT(ARETURN,CSTRING)

	NTIPO := IF(ARETURN[4]==1,15,18)

	RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

RETURN                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³DESCRI‡…O ³ PROCESSAMENTO E EXECUCAO DO RELATORIO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ ESPECIFICO GPO                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
	CABEC1 := PADR(STR0009, TamSx3("T9_CODBEM")[1] + 1) //"FROTA"
	CABEC1 += PADR(STR0010, TamSx3("T9_NOME")[1] + 1) //"DESCRICAO"
	CABEC1 += PADR(STR0011, 20)  //"STATUS"
	CABEC1 += PADR(STR0012, 31) //"CLIENTE/OBRA"
	CABEC1 += PADR(STR0013, 24) //"MUNICIPIO/UF"
	CABEC1 += PADR(STR0014, TamSx3("FPF_DATA")[1] + 1) //"DATA"
	CABEC1 += PADR(STR0015, TamSx3("FPF_HORAI")[1] + 3) //"INICIO"
	CABEC1 += PADR(STR0016, TamSx3("FPF_HORAF")[1] + 3) //"FINAL"

	FPF->(dbSetOrder(1))
	FPF->(dbSeek(xFilial("FPF")))
	While FPF->(!Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF")
				
		If FPF->FPF_FROTA < MV_PAR01 .or. FPF->FPF_FROTA > MV_PAR02
			FPF->(dbSkip())
			Loop
		EndIf

		If FPF->FPF_DATA < MV_PAR03 .or. FPF->FPF_DATA > MV_PAR04
			FPF->(dbSkip())
			Loop
		EndIf

		If FPF->FPF_AS < MV_PAR06 .or. FPF->FPF_AS > MV_PAR07
			FPF->(dbSkip())
			Loop
		EndIf

		If FPF->FPF_OBRA < MV_PAR12 .or. FPF->FPF_OBRA > MV_PAR13
			FPF->(dbSkip())
			Loop
		EndIf

		If MV_PAR05 <> "*" .and. !empty(MV_PAR05)
			If FPF->FPF_STATUS <> MV_PAR05
				FPF->(dbSkip())
				Loop
			EndIf
		EndIf

		// --> IMPRESSAO DO CABECALHO DO RELATORIO... 
		If nLin > 55  // SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			nLin := 8
		ENDIF

		ST9->(dbSetOrder(1))     
		ST9->(dbSeek(xFilial("ST9")+FPF->FPF_FROTA))

		FP1->(dbSetOrder(1))
		FP1->(dbSeek(xFilial("FP1")+FPF->(FPF_PROJET+FPF_OBRA)))

		If FP1->FP1_CLIORI < MV_PAR08 .or. FP1->FP1_CLIORI > MV_PAR09
			FPF->(dbSkip())
			Loop
		EndIf

		If FP1->FP1_LOJORI < MV_PAR10 .or. FP1->FP1_LOJORI > MV_PAR11
			FPF->(dbSkip())
			Loop
		EndIf


		@ nLin, 000     	 PSAY ST9->T9_CODBEM
		@ nLin, PCOL()+1	 PSAY ST9->T9_NOME
		@ nLin, PCOL()+1	 PSAY alltrim(UPPER( LOCR00502(FPF->FPF_STATUS)))+space(20-len(alltrim(UPPER( LOCR00502(FPF->FPF_STATUS))))-1)
		@ nLin, PCOL()+1	 PSAY alltrim(substr(FP1->FP1_NOMORI,1,30))
		@ nLin, 109	 		 PSAY alltrim(substr(FP1->FP1_MUNORI,1,20))+ '/'+ FP1->FP1_ESTORI
		@ NLIN, 133	 		 PSAY FPF->FPF_DATA
		@ NLIN, PCOL()+1	 PSAY FPF->FPF_HORAI
		@ NLIN, PCOL()+1	 PSAY FPF->FPF_HORAF

		nLin++   

		FPF->(dbSkip())
	EndDo

	Set Device TO Screen

	If aReturn[5]==1
		dbCommitAll()
		Set Printer to
		OURSPOOL(WNREL)
	EndIf

	MS_FLUSH()

RETURN


//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCR00502
Pesquisa do STATUS no Pergunte LOCR005
@author Jose Eulalio
@since 21/11/2022
/*/
//------------------------------------------------------------------------------
Function LOCR00501(l1Elem,lTipoRet)
Local cTitulo	:=""
Local cCombo	:= ""
Local MvPar
Local MvParDef	:=""
Local nTam		:= 0

Private aSit:={}

	l1Elem := If (l1Elem = Nil , .F. , .T.) //se permite apenas 1 elemento

	Default lTipoRet := .T.

	cAlias := Alias() 					 // Salva Alias Anterior

	MvPar := "MV_PAR05"
	MvRet := "MV_PAR05"

	cCombo := AllTrim(GetSX3Cache("FPF_STATUS", "X3_CBOX")) // FPF_STATUS 	1=Prevista;2=Confirmada;3=Baixada;4=Encerrada;5=Cancelada;6=Medida

	aSit := StrToKarr(cCombo,";")

	aSit[5] := "5=Disponivel"

	MvParDef:="123456"
	cTitulo :="Status"  //"Situacao"

	nTam 	:= Len(aSit)

	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem,1,nTam,.T.)  // Chama funcao f_Opcoes
			&MvRet := mvpar                                                                          // Devolve Resultado
		EndIf	
	EndIf
	dbSelectArea(cAlias) 	
							 // Retorna Alias
Return( IF( lTipoRet , .T. , MvParDef ) )


//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCR00502
Retorna descrição do combo box do campo FPF_STATUS
@author Jose Eulalio
@since 21/11/2022
/*/
//------------------------------------------------------------------------------
Function LOCR00502(cStatFPF)
Local cRetorno 	:= "Disponivel"
Local nX		:= 0
Local aSit		:= {}

	cCombo := AllTrim(GetSX3Cache("FPF_STATUS", "X3_CBOX")) // FPF_STATUS 	1=Prevista;2=Confirmada;3=Baixada;4=Encerrada;5=Cancelada;6=Medida

	aSit := StrToKarr(cCombo,";")

	For nX := 1 To len(aSit)
		If cStatFPF $ aSit[nX]
			If At("5",aSit[nX]) > 0
				cRetorno := "Disponivel"
			Else
				cRetorno := SubStr(aSit[nX],At("=",aSit[nX])+1)
			EndIf
			Exit
		EndIf
	Next nX

Return cRetorno

