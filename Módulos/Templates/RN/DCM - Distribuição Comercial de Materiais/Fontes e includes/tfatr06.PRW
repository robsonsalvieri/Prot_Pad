#INCLUDE "TFATR06.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Rdmake   ณ TFATR06                                ณ Data ณ 27/06/2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Autor    ณ Vendas Clientes                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Resumo de Faturamento			                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TPL DCM                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TFATR06
Private cString      := "SD2"
Private lEnd         := .F.
Private limite       := 132
Private tamanho		 := "M"
Private M_Pag        := 1
Private nomeprog     := "TFATR06"
Private nTipo        := 18
Private aReturn		 := { STR0001, 1, STR0002, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cArqDbf		 := ""
Private wnrel        := "TFATR06"
Private cDesc1       := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := STR0004 //"de acordo com os parametros informados pelo usuario."
Private cDesc3       := STR0005 //"Resumo de Faturamento"
Private aOrd         := {}
Private titulo       := STR0005 //"Resumo de Faturamento"
Private nLin         := 80
Private CabecExc     := STR0006 //"Origem;Serie;Fornecedor;Linha;Vendedor;Grupo;Total"
Private Cabec1       := STR0007 //"Origem Serie Fornecedor           Linha                          Vendedor                       Grupo                        Total"
//                       123    123   12345678901234567890 123456789012345678901234567890 123456789012345678901234567890 12 123456789012345  999,999,999.99  
//                       0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345679012345679012345678901
//                                 1         2         3         4         5         6         7         8         9         0        1        2         3
Private Cabec2       := ""
Private nOrdem         := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(Padr("TFAT06",Len(SX1->X1_GRUPO)) ,.F.)
DbSelectArea("SD2")
DbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,"TFAT06",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
EndIf
 
nTipo := If(aReturn[4]==1,15,18)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunReport บAutor  ณVendas Clientes     บ Data ณ  14/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do relatorio                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TPL DCM                                    	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem   := aReturn[8]
Local cCondFat := ""
Local _cDepto  := ""
Local _cDescVe := ""

Cria_Tfa()

Processa({||Monta_TFA()})

DbSelectArea("TFA")
SetRegua(RecCount())
DbGotop()

_nTotal := 0
If MV_PAR11 == 1
	nLin := 0
	@nLin,000 PSAY CabecExc
	++nLin
EndIf

While TFA->(!Eof())
	IncRegua()
		
	If nLin > 55 .AND. MV_PAR11 == 2
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin      := 8
	EndIf
    
	_cNomePosto := TFA->U7_POSTO+' '+Posicione('SU0',1,xFilial('SU0')+TFA->U7_POSTO,'U0_NOME')
                                    
	If MV_PAR11 == 2
		@nLin,000 PSAY TFA->D2_ORIGLAN
		@nLin,007 PSAY TFA->D2_SERIE
		@nLin,013 PSAY SubStr(TFA->A2_NREDUZ,1,20)
		@nLin,034 PSAY SubStr(TFA->X5_DESCRI,1,30)
		@nLin,065 PSAY SubStr(TFA->A3_NOME,1,30)
		@nLin,096 PSAY SubStr(Alltrim(_cNomePosto),1,18)
		@nLin,116 PSAY TFA->D2_TOTAL PICTURE "@ER 999,999,999.99"
	Else
		@nLin,000 PSAY TFA->D2_ORIGLAN+';'+TFA->D2_SERIE+';'+TFA->A2_NREDUZ+';'+TFA->X5_DESCRI+';'+TFA->A3_NOME+';'+_cNomePosto+';'+TransForm(TFA->D2_TOTAL,"@ER 999,999,999.99")
	EndIf
	
	_nTotal += TFA->D2_TOTAL
	
	nLin++
	
	DbSkip()
	
End
          
If MV_PAR11 == 2
	nLin+=3
	@nLin,108 PSAY 'TOTAL:'
	@nLin,116 PSAY _nTotal PICTURE "@ER 999,999,999.99"
EndIf

DbSelectArea("TFA")

DbCloseArea()

Set Device to Screen

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	Set Printer to
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_Tfa  บAutor  ณVendas Clientes     บ Data ณ  14/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a tabela temporaria TFA                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TPL DCM                                    	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_Tfa()
Local aFields := {}	//Array para a montagem dos campos
Local cArqDBF := ""	//Arquivo dbf a ser criado

AAdd(aFields,{"D2_ORIGLAN","C",03,0})
AAdd(aFields,{"D2_SERIE"  ,"C",03,0})
AAdd(aFields,{"A2_NREDUZ" ,"C",20,0})
AAdd(aFields,{"X5_DESCRI" ,"C",30,0})
AAdd(aFields,{"A3_NOME"   ,"C",30,0})
AAdd(aFields,{"U7_POSTO"  ,"C",02,0})
AAdd(aFields,{"D2_TOTAL"  ,"N",12,2})

cArqDBF := CriaTrab(NIL,.F.)

DbCreate(cArqDbf,aFields)
DbUseArea(.T.,,cArqDbf,"TFA")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_Tfa บAutor  ณVendas Clientes     บ Data ณ  14/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara os dados para alimentar a tabela TFA (tabela        บฑฑ
ฑฑบ          ณtemporaria que sera' utilizada para visualizar os dados     บฑฑ
ฑฑบ          ณdo relatorio)                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TPL DCM                                    	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_Tfa()
Local _cQuery    := ""	//Query a ser montada
Local _nCount    := 0	//Numero de registros processados pela query
Local _nX	     := 0	//Controle de loop
Local cD2_CF	 := " SUBSTRING(D2_CF,2,3) IN "
Local cMV_CFRELS := SuperGetMv('MV_CFRELS',.F.,"'12','102','108','904'")	//Conteudo do parameteo MV_CFRELS

For _nX := 1 To 2
	If _nX = 1
		_cQuery := "SELECT COUNT(DISTINCT D2_ORIGLAN + D2_SERIE + A2_NREDUZ + X5_DESCRI + A3_NOME + "
		_cQuery +=        "ISNULL(U7_POSTO, CASE WHEN A3_FAT_RH <> ' ' THEN A3_FAT_RH "
		_cQuery +=                         "ELSE '00' "
		_cQuery +=                          "END)) AS TOTAL "
	Else
		_cQuery := "SELECT DISTINCT D2_ORIGLAN, D2_SERIE, A2_NREDUZ, X5_DESCRI, A3_NOME, "
		_cQuery +=        "ISNULL(U7_POSTO, CASE WHEN A3_FAT_RH <> ' ' THEN A3_FAT_RH ELSE '00' END) AS U7_POSTO, "
		_cQuery +=        "ISNULL(SUM(D2_TOTAL-D2_DESCON),0) AS D2_TOTAL "
	EndIf
	_cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
	_cQuery +=       "INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_ <> '*' "
	_cQuery +=                                           "AND D2_DOC = F2_DOC "
	_cQuery +=                                           "AND D2_SERIE = F2_SERIE "
	_cQuery +=                                           "AND D2_FILIAL = F2_FILIAL "
	_cQuery +=       "INNER JOIN "+RetSqlName("SA3")+" SA3 ON SA3.D_E_L_E_T_ <> '*' "
	_cQuery +=       "INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ <> '*' "
	_cQuery +=       "INNER JOIN "+RetSqlName("SX5")+" SX5 ON SX5.D_E_L_E_T_ <> '*' "
	_cQuery +=       "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ <> '*' "
	_cQuery +=       "LEFT  JOIN "+RetSqlName("SU7")+" SU7 ON SU7.D_E_L_E_T_ <> '*' "
	_cQuery +=                                           "AND F2_VEND1 = U7_CODVEN "
	_cQuery += "WHERE SD2.D_E_L_E_T_ <> '*' "
	If !Empty(MV_PAR06)
		_cQuery += "AND SD2.D2_FILIAL = '"+MV_PAR06+"' "
		_cQuery += "AND SF2.F2_FILIAL = '"+MV_PAR06+"' "
		_cQuery += "AND SA3.A3_FILIAL = '"+xFilial("SA3")+"' "
		_cQuery += "AND SU7.U7_FILIAL = '"+xFilial("SU7")+"' "
	EndIf
	_cQuery += "AND F2_VEND1 = A3_COD "
	_cQuery += "AND D2_COD = B1_COD "
	_cQuery += "AND D2_EMISSAO >= '"+DTOS(MV_PAR03)+"' "
	_cQuery += "AND D2_EMISSAO <= '"+DTOS(MV_PAR04)+"' "
	_cQuery += "AND D2_COD >= '"+MV_PAR08+"' "
	_cQuery += "AND D2_COD <= '"+MV_PAR09+"' "
	If !Empty(MV_PAR01)
		_cQuery += "AND F2_VEND1 = '"+MV_PAR01+"' "
	EndIf
	If !Empty(MV_PAR02)
		_cQuery += "AND F2_CLIENTE = '"+MV_PAR02+"' "
	EndIf
	If !Empty(MV_PAR05)
		_cQuery += "AND U7_POSTO  = '"+MV_PAR05+"' "
	EndIf
	If !Empty(MV_PAR07)
		_cQuery += "AND B1_FABRIC LIKE '"+MV_PAR07+"%' "
	EndIf
	If !Empty(MV_PAR10)
		_cQuery += "AND X5_DESCRI LIKE '"+MV_PAR10+"%' "
	EndIf
	_cQuery += "AND D2_TIPO = 'N' "
	_cQuery += "AND " + cD2_CF + "(" + cMV_CFRELS + ")" + " "
	
	If _nX = 2
		_cQuery += "GROUP BY D2_ORIGLAN,D2_SERIE,A2_NREDUZ,X5_DESCRI,A3_NOME,ISNULL(U7_POSTO,CASE WHEN A3_FAT_RH <> ' ' THEN A3_FAT_RH ELSE '00' END) "
		_cQuery += "ORDER BY D2_ORIGLAN,D2_SERIE,A2_NREDUZ,X5_DESCRI,A3_NOME,ISNULL(U7_POSTO,CASE WHEN A3_FAT_RH <> ' ' THEN A3_FAT_RH ELSE '00' END) "
	EndIf
	
	
	_cQuery := ChangeQuery(_cQuery)
	
	TCQUERY _cQuery NEW ALIAS "QUERY"
	
	If _nX = 1
		_nCount := QUERY->TOTAL
		DbCloseArea()
	EndIf
	
Next

DbSelectArea("QUERY")
ProcRegua(_nCount)
DbGotop()

While !Eof()
	IncProc()
	If !Empty(MV_PAR05)
		If QUERY->U7_POSTO <> MV_PAR05
			DbSkip()
			Loop
		EndIf
	EndIf

	RecLock("TFA",.T.)
	TFA->D2_ORIGLAN := QUERY->D2_ORIGLAN
	TFA->D2_SERIE   := QUERY->D2_SERIE
	TFA->A2_NREDUZ  := QUERY->A2_NREDUZ
	TFA->X5_DESCRI  := QUERY->X5_DESCRI
	TFA->A3_NOME    := QUERY->A3_NOME
	TFA->U7_POSTO   := QUERY->U7_POSTO
	TFA->D2_TOTAL   := QUERY->D2_TOTAL
	MsUnLock()

	DbSelectArea("QUERY")
	DbSkip()
EndDo

DbSelectArea("QUERY")
DbCloseArea()
Return