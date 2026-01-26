#INCLUDE "PROTHEUS.CH"
#INCLUDE "GEMR080.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR080   ºAutor  ³ Daniel Tadashi Batori  º Data ³  02/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Informes IR                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMR080()
Local oReport

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AjustaSX1()

oReport := ReportDef()
oReport:PrintDialog()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ Daniel Batori         ³ Data ³ 10/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do layout do Relatorio									    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport  
Local oSec1
Local oSec2
Local oSec21
Local n := SM0->(FCOUNT())
Local aCampos[n]
Local aType[n]
Local aWidths[n]
Local nNome, nEndCob, nCepCob, nBairCob, nCidCob, nEstCob, nCGC, nInsc
Local cFilSA1 := xFilial("SA1")         
Local nTamITPARC:=TamSX3("E1_ITPARC")[1]+2

oReport := TReport():New("GEMR080",STR0001,"GMR080",; //"Informes - Imposto e Renda"
{|oReport| ReportPrint(oReport)},STR0002) //"Relatorio dos Informes - Imposto e Renda."

Pergunte("GMR080", .F.)
oReport:SetPortrait()

DbSelectArea("SM0")
aFields(aCampos,aType,aWidths)

nNome    := Ascan(aCampos,{|x| x=='M0_NOMECOM'})
nEndCob  := Ascan(aCampos,{|x| x=='M0_ENDCOB'})
nCepCob  := Ascan(aCampos,{|x| x=='M0_CEPCOB'})
nBairCob := Ascan(aCampos,{|x| x=='M0_BAIRCOB'})
nCidCob  := Ascan(aCampos,{|x| x=='M0_CIDCOB'})
nEstCob  := Ascan(aCampos,{|x| x=='M0_ESTCOB'})
nCGC     := Ascan(aCampos,{|x| x=='M0_CGC'})
nInsc    := Ascan(aCampos,{|x| x=='M0_INSC'})

oSec1 := TRSection():New(oReport,STR0003,{"SM0"},{},.F.,.F.) //"Dados da Empresa"
TRCell():New(oSec1,"M0_NOMECOM","",STR0006,,aWidths[nNome],.F.,{|| SM0->M0_NOMECOM } ) //"EMPRESA"
TRCell():New(oSec1,"M0_ENDCOB","",STR0007,,aWidths[nEndCob],.F.,{|| SM0->M0_ENDCOB } ) //"ENDEREÇO"
TRCell():New(oSec1,"M0_CEPCOB","",STR0008,,aWidths[nCepCob],.F.,{|| SM0->M0_CEPCOB } ) //"CEP"
TRCell():New(oSec1,"M0_BAIRCOB","",STR0009,,aWidths[nBairCob],.F.,{|| SM0->M0_BAIRCOB } ) //"BAIRRO"
TRCell():New(oSec1,"M0_CIDCOB","",STR0010,,aWidths[nCidCob],.F.,{|| SM0->M0_CIDCOB } ) //"CIDADE"
TRCell():New(oSec1,"M0_ESTCOB","",STR0011,,aWidths[nEstCob],.F.,{|| SM0->M0_ESTCOB } ) //"ESTADO"
TRCell():New(oSec1,"M0_CGC","",STR0012,,aWidths[nCGC],.F.,{|| SM0->M0_CGC } ) //"CNPJ"
TRCell():New(oSec1,"M0_INSC","",STR0013,,aWidths[nInsc],.F.,{|| SM0->M0_INSC } ) //"INSCRIÇÃO ESTADUAL"

oSec2 := TRSection():New(oReport,STR0004,{"TRB","SA1"},,.F.,.F.) //"Clientes"
TRCell():New(oSec2,"A1_NOME","SA1",,,,.F.,{|| SA1->A1_NOME } )
TRPosition():New(oSec2,"SA1",1, {|| cFilSA1 + TRB->(A1_COD+A1_LOJA) })
oSec2:OnPrintLine({|| oReport:EndPage(), .T. })

oSec21 := TRSection():New(oSec2,STR0005,{"TRB"},,.F.,.F.) //"Créditos"
TRCell():New(oSec21,"E5_DATA","SE5",,,11,.F.,{|| TRB->E5_DATA } )
TRCell():New(oSec21,"LK3_DESCRI","LK3",STR0014,,,.F.,{|| TRB->LK3_DESCRI } ) //"OBRA"
TRCell():New(oSec21,"LIQ_DESC","LIQ",STR0015,,60,.F.,{|| TRB->LIQ_DESC } ) //"UNIDADE"
TRCell():New(oSec21,"LJO_TPDESC","LJO",,,,.F.,{|| TRB->LJO_TPDESC } )
TRCell():New(oSec21,"E1_ITPARC","SE1",,,nTamITPARC,.F.,{|| TRB->E1_ITPARC } )
TRCell():New(oSec21,"E5_VALOR","SE5",,,,.F.,{|| TRB->E5_VALOR } )
TRFunction():New(oSec21:Cell("E5_VALOR"),STR0018,"SUM",,,,,.T.,.F.) //"TOTAL"
oSec21:SetTotalInLine(.F.)
oSec21:SetTotalText(STR0018) //"TOTAL"
oSec21:SetParentFilter ( {|cParam| TRB->(A1_COD+A1_LOJA) == cParam},{|| TRB->(A1_COD+A1_LOJA) })

Return oReport                                                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Daniel Batori          ³ Data ³15/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
Local oSec1 := oReport:Section(1)
Local oSec2 := oReport:Section(2)
Local cArq  := ""

Processa({||CRIATRB(@cArq)},STR0016) //"Processando..."

dbSelectArea("TRB")
TRB->(DbGotop())  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtros do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilter := "SM0->M0_CODIGO == cEMPANT .AND. "
cFilter += "SM0->M0_CODFIL == cFILANT "

oSec1:SetFilter( cFilter )

oReport:OnPageBreak({||	oSec1:Print(), oReport:SkipLine() })
oSec2:Print()

dbSelectArea("TRB")
dbCloseArea()
FErase(cArq+GetDBExtension())
FErase(cArq+OrdBagExt())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRIATRB   ºAutor  ³Daniel Tadashi Batori  º Data ³  14/02/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o arquivo temporario que contem os registros a serem      º±±
±±º          ³impressos                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cArq : nome do arquivo de trabalho a ser criado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMR080                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRIATRB(cArq)
Local aEstru  :={}
Local cArqInd
Local cChave  := ""
Local cFilSA1 := xFilial("SA1")
Local cFilLIU := xFilial("LIU")
Local cFilSE5 := xFilial("SE5")
Local cFilLK3 := xFilial("LK3")
Local cFilSE1 := xFilial("SE1")
Local cFilLIX := xFilial("LIX")
Local cFilLIQ := xFilial("LIQ")
Local cFilLJO := xFilial("LJO")
Local nValor  := 0
Local dData

aTam := TamSX3("A1_COD")
Aadd(aEstru, { "A1_COD"     , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("A1_LOJA")
Aadd(aEstru, { "A1_LOJA"    , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("A1_NOME")
Aadd(aEstru, { "A1_NOME"    , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LIT_PREFIX")
Aadd(aEstru, { "LIT_PREFIX" , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LIT_DOC")
Aadd(aEstru, { "LIT_DOC"    , "C" , aTam[1] , aTam[2] } )
Aadd(aEstru, { "E5_DATA"    , "D" , 8       , 0        } )
aTam := TamSX3("LK3_CODEMP")
Aadd(aEstru, { "LK3_CODEMP" , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LK3_DESCRI")
Aadd(aEstru, { "LK3_DESCRI" , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LIQ_COD")
Aadd(aEstru, { "LIQ_COD"    , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LIQ_DESC")
Aadd(aEstru, { "LIQ_DESC"   , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LJO_NCONTR")
Aadd(aEstru, { "LJO_NCONTR" , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LJO_ITEM")
Aadd(aEstru, { "LJO_ITEM"   , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("LJO_TPDESC")
Aadd(aEstru, { "LJO_TPDESC" , "C" , aTam[1] , aTam[2] } )
aTam := TamSX3("E5_VALOR")
Aadd(aEstru, { "E5_VALOR"   , "N" , aTam[1] , aTam[2] } )
aTam := TamSX3("E1_ITPARC")
Aadd(aEstru, { "E1_ITPARC"  , "C" , aTam[1] , aTam[2] } )

cChave := "A1_COD+A1_LOJA+DTOS(E5_DATA)"

cArq := Criatrab(aEstru,.T.)
dbUseArea( .T.,, cArq, "TRB", .T., .F. )

cArqInd	:= CriaTrab(Nil, .F.)
IndRegua("TRB", cArqInd, cChave,,,STR0017)  //"Selecionando Registros..."

SA1->(DbSetOrder(1)) //filial+A1_COD+A1_LOJA
SE5->(DbSetOrder(7)) //FILIAL+PREFIXO+TITULO
LK3->(DbSetOrder(1)) //FILIAL+LK3_CODEMP+LK3_DESC
LIQ->(DbSetOrder(1)) //FILIAL+LIQ_COD
SE1->(DbSetOrder(1)) //FILIAL+PREFIXO+NUM+PARCELA+TIPO
LIX->(DbSetOrder(1)) //FILIAL+PREFIXO+NUM+PARCELA+TIPO
LJO->(DbSetOrder(1)) //FILIAL+LJO_NCONTR+LJO_ITEM
LIU->(DbSetOrder(3)) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
LIT->(DbSetOrder(2)) //FILIAL+CONTRATO
LIT->(DbGoTop())

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeADVPLExpr("GMR080")

ProcRegua(LIT->(RecCount()))
IncProc()

While !LIT->(EOF())

	IncProc()
	
	If SA1->(DbSeek(cFilSA1+LIT->(LIT_CLIENT+LIT_LOJA)))
		If !(SA1->&Mv_Par01)
			LIT->(DbSkip())
			Loop
		EndIf

		If SE1->(DbSeek(cFilSE1+LIT->(LIT_PREFIX+LIT_DOC)))
			
			While !SE1->(EOF()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)==cFilSE1+LIT->(LIT_PREFIX+LIT_DOC)
				
				//deve ser mostrado apenas titulos que tenham sido pagos parcialmente ou total
				If SE1->E1_SALDO == SE1->E1_VALOR
					SE1->(DbSkip())
					Loop
				EndIf
				
				If SE5->(DbSeek(cFilSE5+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)))

					//Totaliza as baixas do titulo e mostra a data maior das baixas				
					nValor := 0
					dData  := SE5->E5_DATA
					While !SE5->(EOF()) .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA)==cFilSE5+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)

						//Verifica se o titulo eh de receber
						If SE5->E5_RECPAG != "R"
							If SE5->E5_TIPODOC == "ES"
								nValor -= SE5->E5_VALOR
							EndIf
							SE5->(DbSkip())
							Loop
						EndIf
	
						If !(SE5->E5_TIPODOC $ "VL/BA/V2/CP")
							SE5->(DbSkip())
							Loop
						EndIf

						// Consiste se o motivo gera ou nao movimento bancario.
						If !MovBcoBx( SE5->E5_MOTBX, .F. )
							SE5->(DbSkip())
							Loop
						Endif
	
						//Verifica se o titulo pago/recebido esta dentro do periodo de apuracao
						If SE5->E5_DATA<mv_par02 .or. SE5->E5_DATA>mv_par03
							SE5->(DbSkip())
							Loop
						EndIf

						nValor += SE5->E5_VALOR
						dData  := Max(SE5->E5_DATA,dData)

						SE5->(DbSkip())
					EndDo
				EndIf
				
				If nValor == 0
					SE1->(DbSkip())
					Loop
				EndIf
					
			    LIU->(DbSeek(cFilLIU+LIT->LIT_NCONTR))
				LIQ->(DbSeek(cFilLIQ+LIU->LIU_CODEMP))
				LK3->(DbSeek(cFilLK3+LIQ->LIQ_CODEMP))
				LIX->(DbSeek(cFilLIX+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				LJO->(DbSeek(cFilLJO+LIT->LIT_NCONTR+LIX->LIX_ITCND))
	
				RecLock( "TRB" , .T. )
				TRB->A1_COD     := SA1->A1_COD
				TRB->A1_LOJA    := SA1->A1_LOJA
				TRB->A1_NOME    := SA1->A1_NOME
				TRB->LIT_PREFIX := LIT->LIT_PREFIX
				TRB->LIT_DOC    := LIT->LIT_DOC
				TRB->E5_DATA    := dData
				TRB->LK3_CODEMP := LK3->LK3_CODEMP
				TRB->LK3_DESCRI := LK3->LK3_DESCRI
				TRB->LIQ_COD    := LIQ->LIQ_COD
				TRB->LIQ_DESC   := LIQ->LIQ_DESC
				TRB->LJO_NCONTR := LJO->LJO_NCONTR
				TRB->LJO_ITEM   := LJO->LJO_ITEM
				TRB->LJO_TPDESC := LJO->LJO_TPDESC
				TRB->E5_VALOR   := nValor
				TRB->E1_ITPARC  := SE1->E1_ITPARC
				MsUnlock()
	
				SE1->(DbSkip())
			EndDo
		EndIf
	EndIf
	LIT->(DbSkip())
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AjustaSX1 ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 14.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza a tabela SX1 do relatorio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 14.02.07 ³Daniel         ³ Criacao                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Local aRegs		:= {}

aRegs		:= {}

aHelpPor := { "Informe intervalo de clientes que ",;
               "deseja considerar para impressao ",;
               "do relatorio." }
//aHelpSpa := { "Informe intervalo de proyectos"  ,;
//               "que desea considerar para impresion ",;
//               "del informe." }
//aHelpEng := { "Enter project range to be considered ",;
//              "to print report." }
PutSX1Help("P.GMR08001.",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := { "Informe a data inicial para o    ",;
               "período a ser impresso.          "}
//aHelpSpa := { "Informe intervalo de producto  "  ,;
//               "que desea considerar para impresion ",;
//               "del informe." }
//aHelpEng := { "Enter product range to be considered ",;
//              "to print report." }
PutSX1Help("P.GMR08002.",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := { "Informe a data final para o      ",;
               "período a ser impresso.          "}
//aHelpSpa := { "Informe intervalo de producto  "  ,;
//               "que desea considerar para impresion ",;
//               "del informe." }
//aHelpEng := { "Enter product range to be considered ",;
//              "to print report." }
PutSX1Help("P.GMR08003.",aHelpPor,aHelpEng,aHelpSpa)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³           Grupo   Ordem   Pergunta Portugues   Pergunta Espanhol    Pergunta Ingles  Variavel Tipo Tamanho Decimal Presel  GSC   Valid   Var01      Def01 DefSPA1  DefEng1  Cnt01       Var02  Def02 DefSpa2 DefEng2 Cnt02 Var03 Def03  DefSpa3  DefEng3  Cnt03 Var04 Def04 DefSpa4 DefEng4 Cnt04  Var05  Def05  DefSpa5 DefEng5 Cnt05  XF3   GrgSxg  cPyme aHelpPor aHelpEng aHelpSpa cHelp   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ValidPerg()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AjustaSX1 ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 14.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza a tabela SX1 do relatorio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 14.02.07 ³Daniel         ³ Criacao                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg( ) 
Local cAlias := Alias()

	DbSelectArea("SX1")
	DbSetOrder(1)
	PutSx1(	"GMR080", "01", "Cliente ?", "", "", ;
				"mv_ch1", "C", 99, 0, 0, "R", "", "SA1", "", "", ;
				"mv_par01", "", "", "", "A1_COD", "", "", "", "", ;
				"", "", "", "", "", "", "", "",{},{},{})

	PutSx1(	"GMR080", "02", "Data De ?", "", "", ;
				"mv_ch2", "D", 8, 0, 0, "G", "naovazio()", "", "", "", ;
				"mv_par02", "", "", "", "", "", "", "", "", ;
				"", "", "", "", "", "", "", "",{},{},{})

	PutSx1(	"GMR080", "03", "Data Ate ?", "", "", ;
				"mv_ch3", "D", 8, 0, 0, "G", "naovazio()", "", "", "", ;
				"mv_par03", "", "", "", "", "", "", "", "", ;
				"", "", "", "", "", "", "", "",{},{},{})

	DbSelectArea(cAlias)

Return .T.
