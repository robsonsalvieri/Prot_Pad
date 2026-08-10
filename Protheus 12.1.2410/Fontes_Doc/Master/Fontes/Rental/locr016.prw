#INCLUDE "locr016.ch" 
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "VKEY.CH"
#Include 'FwMVCDef.ch'

#include 'parmtype.ch'
#Include 'FWMVCDEF.ch' 
#Include 'MsOle.CH'

#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{PROTHEUS.DOC} LOCR016.PRW
ITUP BUSINESS - TOTVS RENTAL
GERA CONTRATO DE LOCAÇÃO ATRAVÉS DA INTEGRAÇÃO WORD
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCR016()
Local AITENS := {"PDF" , "DOT"} 
Local CCOMBO , CGETSB1 
Local LOK    := .F.
Local cSO
Local nSo
Local lPassa := .F.

PRIVATE CPATH     := SUPERGETMV("MV_LOCX273",.F.,"\DOT\") 
PRIVATE C_NOMEARQ := SUPERGETMV("MV_LOCX272",.F.,STR0001)  //"MODELO_CONTRATO.DOT"
PRIVATE CARQUIVO  := CPATH + C_NOMEARQ 

PRIVATE LTEM_DOT  := .F.   

	// Frank em 21/09/2023
	// Validar o sistema operacional
	nSo := GetRemoteType(@cSo)
	IF EXISTBLOCK("LOCR016P")
		lPassa := EXECBLOCK("LOCR016P",.T.,.T.,{})
	ENDIF

	If nSo <> 1 .or. AT("WIN",cSo) == 0 .or. lPassa
		Help(Nil,	Nil,alltrim(upper(Procname())),; 
					Nil,STR0046,1,0,Nil,Nil,Nil,Nil,Nil,; //"Sistema operacional inválido"
					{STR0047}) //"Necessário o Word homologado pela Totvs para o funcionamento."
		Return
	Endif

	If FP0->FP0_STATUS $ "8,7,C,B,6"
		MSGALERT(STR0048, STR0002) //"Status inválido para a emissão do contrato."###IMPRESSÃO DE CONTRATO
		Return
	EndIF

	IF FILE(CARQUIVO) 
		LTEM_DOT := .T. 
	ELSE 
		CGETSB1  := FP0->FP0_PROJET 
	ENDIF 

	DEFINE MSDIALOG ODLG TITLE STR0002 FROM 000,000 TO 250,370 PIXEL  //"IMPRESSÃO DE CONTRATO"
		@ 015,010 SAY    OSAY01   PROMPT STR0003 SIZE 170,010 OF ODLG PIXEL  //"ESTE PROGRAMA FARÁ A IMPRESSÃO DO CONTRATO POSICIONADO !"
	IF LTEM_DOT
		@ 042,010 SAY    OSAY03   PROMPT STR0004     SIZE 040,010 OF ODLG PIXEL  //"TIPO IMPRESSÃO :"
		@ 040,055 MSCOMBOBOX OCOMBOBO1 VAR CCOMBO  ITEMS AITENS SIZE 038,010 OF ODLG PIXEL 

		@ 072,010 SAY    OSAY05   PROMPT STR0005     SIZE 040,010 OF ODLG PIXEL //"LOCAL P/ SALVAR:"
		@ 070,055 MSGET  OGETSB1       VAR CGETSB1 WHEN .F.     SIZE 115,010 OF ODLG PIXEL
		//@ 070,170 BUTTON OBTNFILE PROMPT "..."                  SIZE 010,010 ACTION (CGETSB1:=CGETFILE(".DOT",OEMTOANSI(STR0006),1,"C:\",.F.,NOR(GETF_LOCALHARD,GETF_NETWORKDRIVE ),.F.))       OF ODLG PIXEL  //"SELECIONE O LOCAL PARA SALVAR O ARQUIVO"
	ELSE 
		@ 042,010 SAY    OSAY05   PROMPT STR0007          SIZE 040,010 OF ODLG PIXEL  //"CONTRATO : "
		@ 040,055 MSGET  OGETSB1       VAR CGETSB1 WHEN .F.     SIZE 115,010 OF ODLG PIXEL 
	ENDIF 
		@ 100,025 BUTTON OBTNOK   PROMPT STR0008     SIZE 050,010 ACTION (IIF(!EMPTY(CGETSB1) , LJMSGRUN(STR0009 , , {||LOK := LOCR01601(CGETSB1,CCOMBO)}) , LOK:=.F.) , IIF(LOK , ODLG:END() , NIL)) OF ODLG PIXEL  //"IMPRIME CONTRATO"###"AGUARDE, IMPRIMINDO..."
		@ 100,115 BUTTON OBTNOK   PROMPT STR0010             SIZE 050,010 ACTION (LOK:=.F.,ODLG:END()) OF ODLG PIXEL  //"CANCELAR"
	ACTIVATE MSDIALOG ODLG CENTERED 

RETURN

// ======================================================================= \\
FUNCTION LOCR01601(CCAMINHO,CCOMBO)
// ======================================================================= \\

//CAL NZAGQUANT := 0 
LOCAL NZAAQUANT := 0 

	CCONTA			:= CCAMINHO
	CWORD    		:= OLE_CREATELINK()
	AZA0AREA 		:= GETAREA("FP0")

	DBSELECTAREA("FP6") 			// ITENS
	DBSETORDER(1)

	DBSELECTAREA("SE4") 			// CONDIÇÕES DE PAGAMENTOS
	DBSETORDER(1)
	SE4->(MSSEEK(XFILIAL("SA1")+FPA->FPA_CONPAG))

	DBSELECTAREA("SA1") 			// TABELA CLIENTES
	DBSETORDER(1)
	SA1->(MSSEEK(XFILIAL("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))

	DBSELECTAREA("FP1") 			// TABELA CLIENTES PROJETOS
	DBSETORDER(1)
	FP1->(MSSEEK(XFILIAL("FP1")+FP0->FP0_PROJET))

	DBSELECTAREA("FPA") 			// TABELA ITENS DO CONTRATO
	DBSETORDER(1) 
	FPA->(MSSEEK(XFILIAL("FPA")+FP0->FP0_PROJET)) 

	DBSELECTAREA("SB1") 			// PRODUTOS
	DBSETORDER(1) 
	SB1->(MSSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT)) 

	IF ! LTEM_DOT
		LOCR01602() 
		RETURN 
	ENDIF 

	IF (CWORD >= "0")
		OLE_CLOSELINK(CWORD) 		// FECHA O LINK COM O WORD
		CWORD := OLE_CREATELINK()
		OLE_NEWFILE(CWORD,CARQUIVO)
		
		// --> FUNCAO QUE FAZ O WORD APARECER NA AREA DE TRANSFERENCIA DO WINDOWS, 
		//     SENDO QUE PARA HABILITAR/DESABILITAR E SO COLOCAR .T. OU .F.
		OLE_SETPROPERTY(CWORD , OLEWDVISIBLE   , .T.)
		OLE_SETPROPERTY(CWORD , OLEWDPRINTBACK , .F.)
		
		// --> DADOS CADASTRAIS.
		OLE_SETDOCUMENTVAR(CWORD, "CPROJET" , ALLTRIM(FP0->FP0_PROJET))											// NUMERO DO CONTRATO
		OLE_SETDOCUMENTVAR(CWORD, "CDIA"	, DAY(DDATABASE)) 													// DATA DE EMISSÃO DA IMPRESSÃO DO CONTRATO - DIA
		OLE_SETDOCUMENTVAR(CWORD, "CMES"	, MONTH(DDATABASE)) 												// DATA DE EMISSÃO DA IMPRESSÃO DO CONTRATO - MES
		OLE_SETDOCUMENTVAR(CWORD, "CANO"	, YEAR(DDATABASE)) 													// DATA DE EMISSÃO DA IMPRESSÃO DO CONTRATO - ANO
		OLE_SETDOCUMENTVAR(CWORD, "CNOMERE" , ALLTRIM(SA1->A1_NREDUZ))											// LOCATÁRIA
		OLE_SETDOCUMENTVAR(CWORD, "CCGC"	, ALLTRIM(SA1->A1_CGC))												// CNPJ
		OLE_SETDOCUMENTVAR(CWORD, "CFATURA" , SA1->(ALLTRIM(A1_END)+" "+ALLTRIM(A1_BAIRRO)+" "+ALLTRIM(A1_MUN)+" "+ALLTRIM(A1_EST)+" "+ALLTRIM(A1_CEP)))//FATURAMENTO
		OLE_SETDOCUMENTVAR(CWORD, "CCOBRAN" , SA1->(ALLTRIM(A1_ENDCOB)+" "+ALLTRIM(A1_BAIRRO)+" "+ALLTRIM(A1_MUN)+" "+ALLTRIM(A1_EST)+" "+ALLTRIM(A1_CEP)))					//COBRANÇA
		OLE_SETDOCUMENTVAR(CWORD, "CENTREG" , FP1->(ALLTRIM(FP1_ENDORI)+" "+ALLTRIM(FP1_BAIORI)+" "+ALLTRIM(FP1_MUNORI)+" "+ALLTRIM(FP1_ESTORI)+" "+ALLTRIM(FP1_CEPORI)))	//ENTREGA
		OLE_SETDOCUMENTVAR(CWORD, "CCONDIC" , SE4->E4_DESCRI )													// CONDIÇÃO DE COBRANÇA  (RECUPERAR A DESCRIÇÃO DA CONDIÇÃO DE PAGAMENTO)
		OLE_SETDOCUMENTVAR(CWORD, "CTITPAG" , FPA->FPA_TIPPAG )													// (RECUPERAR A DESCRIÇÃO DO X3_CBOX CORRESPONDENTE)
		IF     ! EMPTY(FPA->FPA_MINMES) 	// CASO O CAMPO FPA_MINMES ESTEJA DIFERENTE DE ZERO SERÁ APRESENTANDO O FPA_MINMES+HRS/MÊS
			OLE_SETDOCUMENTVAR(CWORD, "CTITPAG" , STR(FPA->FPA_MINMES) + STR0011) //"HRS/MÊS"
		ELSEIF ! EMPTY(FPA->FPA_MINMES) 	// O CAMPO FPA_MINMES ESTEJA IGUAL A ZERO SERÁ APRESENTANDO O FPA_MINDIA+HRS/SEMANA.
			OLE_SETDOCUMENTVAR(CWORD, "CTITPAG" , STR(FPA->FPA_MINDIA) + STR0012) //"HRS/SEMANA"
		ENDIF
		
		// --> PRIMEIRA PLANILHA. 
		IF ! EMPTY(FPA->FPA_AS)
			// QUANTIDADE - ESPECIFICAÇÃO			 - PERÍODO (DIAS) - VALOR UNIT. PERÍODO - VALOR TOTAL 
			// 999		  - DESCRIÇÃO DO ITEM LOCADO - 999	 		  - R$					- R$ - 
			OLE_SETDOCUMENTVAR(CWORD, "CDESCRI" , FPA->FPA_DESGRU+FPA->FPA_CARAC) 	// ESPECIFICAÇÃO
			OLE_SETDOCUMENTVAR(CWORD, "CPERIOD" , FPA->FPA_DTFIM-FPA->FPA_DTINI) 	// PERIODO EM DIAS
			OLE_SETDOCUMENTVAR(CWORD, "NQTDZAA" , FPA->FPA_QUANT)
			OLE_SETDOCUMENTVAR(CWORD, "NVALHOR" , FPA->FPA_VRHOR)
			OLE_SETDOCUMENTVAR(CWORD, "NVTOTAL" , FPA->FPA_QUANT*FPA->FPA_VRHOR)
			
			// --> SEGUNDA PLANILHA
			// QUANTIDADE	-ITENS ADICIONAIS	 -VALOR UNIT.	-VALOR TOTAL
			// 999			-DESCRIÇÃO DO ITEM	 -R$-   	 	-R$-
			IF FP6->(MSSEEK(XFILIAL("FP6")+FPA->(FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU)))
				OLE_SETDOCUMENTVAR(CWORD, "CDESCIT" ,FP6->FP6_DESCRI)
				IF FP6->FP6_RESPON == "L"
					SELZAA(FP6->FP6_PROJET)
					NZAAQUANT := 0
					WHILE ZAATMP->(! EOF())
						NZAAQUANT += ZAATMP->FP6_QUANT
						NVALZAACOB += IIF( ZAATMP->FP6_VALCOB > 0, ZAATMP->FP6_VALCOB, 0)
						ZAATMP->(DBSKIP())
					ENDDO
					OLE_SETDOCUMENTVAR(CWORD, "NQTDZAA" , NZAAQUANT)
					OLE_SETDOCUMENTVAR(CWORD, "NVALCOB" , NVALZAACOB/NZAAQUANT)
					OLE_SETDOCUMENTVAR(CWORD, "NVALTOT" , NVALZAACOB)
				ELSE
					OLE_SETDOCUMENTVAR(CWORD, "NQTDZAA" , FP6->FP6_QUANT)
					OLE_SETDOCUMENTVAR(CWORD, "NVALCOB" , IIF(FP6->FP6_VALCOB>0,FP6->FP6_VALCOB,STR0013) ) //"INCLUSO"
					OLE_SETDOCUMENTVAR(CWORD, "NVALTOT" , IIF(FP6->FP6_VALCOB>0,FP6->FP6_QUANT*FP6->FP6_VALCOB,STR0013) ) //"INCLUSO"
				ENDIF
			ENDIF
		ENDIF
		
		// --> ATUALIZA OS CAMPOS DO WORD COM O CONTEUDO DO SETDOCUMENTVAR.
		OLE_UPDATEFIELDS(CWORD)
		
		// --> IMPRIME O DOCUMENTO.
	//	OLE_PRINTFILE(CWORD , "ALL" , , , )
		
		// --> SALVA O ARQUIVO EM FORMATO DOC OU PDF. 
		IF     CCOMBO == "1"
			// --> SALVA O DOCUMENTO
			OLE_SAVEASFILE(CWORD,ALLTRIM(CCONTA)+".DOC") 
			OLE_OPENFILE( CWORD, ALLTRIM(CCONTA)+".DOC") 
			OLE_SAVEASFILE(CWORD,ALLTRIM(CCONTA)+".PDF") 
		ELSEIF CCOMBO == "2"
			EXECINCLIENT(OLESAVEASFILE, {CWORD , ALLTRIM(CCONTA) , "" , "" , "0" , "17"} ) 
		//	OLE_SAVEASFILE(CWORD,ALLTRIM(CCONTA)+".DOC") 
		ENDIF
		
		// --> ENCERRA A CONEXÃO COM O WORD.
		OLE_CLOSELINK(CWORD)
	ENDIF

	RESTAREA(AZA0AREA)

RETURN 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ SELZAA    º AUTOR ³ IT UP BUSINESS     º DATA ³ 02/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ GERA CONTRATO DE LOCAÇÃO ATRAVÉS DA INTEGRAÇÃO WORD        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO - TECNOGERA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION SELZAA(CPROJETO)
Local XCQUERY

	IF SELECT("ZAATMP") > 0
		ZAATMP->(DBCLOSEAREA())
	ENDIF

	/*
	+CPROJETO+
	+XFILIAL()+
	*/

	XCQUERY := " SELECT	* "
	XCQUERY += " FROM "+RETSQLNAME("FP6")+" "
	XCQUERY += " WHERE  FP6_PROJET = ? "
	XCQUERY +=   " AND  FP6_FILIAL = ? "
	XCQUERY := ChangeQuery(XCQUERY)
	aBindParam := {CPROJETO,XFILIAL()}
	MPSysOpenQuery(XCQUERY,"ZAATMP",,,aBindParam)
	//TCQUERY XCQUERY NEW ALIAS "ZAATMP"

RETURN

// ======================================================================= \\
FUNCTION LOCR01602()
// ======================================================================= \\

Local lAdjustToLegacy	:= .f.
Local lDisableSetup		:= .t.

Local nLin 		:= 10
Local oPrinter

Local cLocadora	 := ""
Local cLocataria := ""
Local cClausula1 := ""
Local cClausula2 := ""
Local nPreco	 := 0

	oPrinter := FWMSPrinter():New('Proposta'+FP0->FP0_PROJET+'.PDF', IMP_PDF, lAdjustToLegacy,  , lDisableSetup, , , , , , .f. , .f. ) 

	oFont1	:= TFONTEX():NEW(oPrinter,"Arial",09,09,.F.,.T.,.F.)
	oFont1N	:= TFONTEX():NEW(oPrinter,"Arial",09,09,.T.,.T.,.F.)
	oFont2  := TFONTEX():NEW(oPrinter,"Arial",10,10,.F.,.T.,.F.)
	oFont2N := TFONTEX():NEW(oPrinter,"Arial",10,10,.T.,.T.,.F.)
	oFont3  := TFONTEX():NEW(oPrinter,"Arial",12,12,.F.,.T.,.F.)
	oFont4  := TFONTEX():NEW(oPrinter,"Arial",12,12,.F.,.T.,.F.)

	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9)
	oPrinter:StartPage()

	cLocadora  := "Cedeu: " + Alltrim(SM0->M0_NOMECOM) + ", com sede em "
	cLocadora  += AllTrim(SM0->M0_ENDENT) + ", " + AllTrim(SM0->M0_BAIRENT) + ", " + AllTrim(SM0->M0_CIDENT) + "/" + AllTrim(SM0->M0_ESTENT) 
	cLocadora  += ", inscrita no CNPJ sob o n° "+Alltrim(Transform(SM0->M0_CGC, "@!R NN.NNN.NNN/NNNN-99"))
	cLocadora  += ", neste ato representada por " + AllTrim(FP0->FP0_NOMVEN) +", doravante denominada LOCADORA,"

	SA1->(DbSetOrder(1))
	If (SA1->(DbSeek(xFilial("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA)))
		cLocataria := "Alocou: " + Alltrim(SA1->A1_NOME) + ", com sede em "
		cLocataria += AllTrim(SA1->A1_END) + ", " + AllTrim(SA1->A1_BAIRRO) + ", " + AllTrim(SA1->A1_MUN) + "/" + AllTrim(SA1->A1_EST) 
		cLocataria += ", inscrita no CNPJ sob o n° "+Alltrim(Transform(FP0->FP0_CLICGC, "@!R NN.NNN.NNN/NNNN-99"))
		cLocataria += ", neste ato representada por " + AllTrim(FP0->FP0_NOMECO) +", doravante denominada LOCATÁRIA,"
	EndIf

	FPA->(DbSetOrder(1))
	If (FPA->(DbSeek(FP0->FP0_FILIAL + FP0->FP0_PROJET + "001001  ")))
		nPreco := ((FPA->FPA_VLBRUT/FPA->FPA_LOCDIA) * DateWorkDay(FPA->FPA_DTINI,FPA->FPA_DTENRE,.T.,.T.,.T.))
		If (SB1->(DbSeek(xFilial("SB1") + FPA->FPA_PRODUT)))
			cClausula1 := "A LOCADORA cede à LOCATÁRIA, a título de locação, a máquina " + AllTrim(SB1->B1_DESC)+ ", de sua "
			cClausula1 += "propriedade, em perfeito estado de funcionamento, conservação e operabilidade, completa com todos os "
			cClausula1 += "seus acessórios, conforme memorial anexo a este instrumento, que faz parte integrante dele para todos os fins."
	
			cClausula2 := "O presente contrato terá início em " + Dtoc(FPA->FPA_DTINI) + " com término em " + Dtoc(FPA->FPA_DTENRE) + ", "
			cClausula2 += "podendo ser prorrogado mediante termo aditivo firmado entre as partes."
		EndIf
	EndIf

	nLin := 40
	oPrinter:SayAlign( nLin, 20, "CONTRATO DE LOCAÇÃO DE MÁQUINA", oFont2N:OFONT, 520, 010, , 2,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, cLocadora, oFont1:OFONT, 520, 300, , 3,  ) 
	nLin += 40
	oPrinter:SayAlign( nLin, 20, cLocataria, oFont1:OFONT, 520, 300, , 3,  ) 
	nLin += 40
	oPrinter:SayAlign( nLin, 20, "As partes, acima qualificadas, têm entre si justo e acordado o presente Contrato de Locação de Máquina, que se regerá pelas seguintes cláusulas e condições: ", oFont1:OFONT, 520, 300, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "Cláusula 1ª - Objeto", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, cClausula1, oFont1:OFONT, 520, 300, , 3,  ) 
	nLin += 40
	oPrinter:SayAlign( nLin, 20, "Cláusula 2ª - Prazo", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, cClausula2, oFont1:OFONT, 520, 010 , , 3,  ) 
	nLin += 20

	oPrinter:SayAlign( nLin, 20, "Cláusula 3ª - Preço", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "Pelo presente contrato, a LOCATÁRIA pagará à LOCADORA o valor total de R$ " +AllTrim(Transform(nPreco, "@E 999,999.99" ))+ " (reais)", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20

	oPrinter:SayAlign( nLin, 20, "Cláusula 4ª - Obrigações da Locadora", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "A LOCADORA se obriga a:", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Disponibilizar à LOCATÁRIA a máquina em perfeito estado de funcionamento, conservação e operabilidade, completa com todos os seus acessórios, nos prazos solicitados pela LOCATÁRIA;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Prestar à LOCATÁRIA todo o suporte técnico necessário à operação da máquina;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Substituir a máquina por outra de similares características, em caso de inoperabilidade da máquina locada, no prazo de 10 dias;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Permitir à LOCATÁRIA a vistoria da máquina antes de sua retirada.", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20

	oPrinter:SayAlign( nLin, 20, "Cláusula 5ª - Obrigações da Locatária", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "A LOCATÁRIA se obriga a:", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Utilizar a máquina de acordo com as instruções do fabricante e da LOCADORA;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Responsabilizar-se pela guarda, conservação e manutenção da máquina durante o período de locação;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Comunicar à LOCADORA, por escrito, qualquer dano ou avaria à máquina no prazo de 5 dias após a sua ocorrência;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Permitir à LOCADORA o acesso à máquina para fins de vistoria e reparos;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Devolver a máquina à LOCADORA ao término do contrato nas mesmas condições em que a recebeu, salvo o desgaste natural;", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 10
	oPrinter:SayAlign( nLin, 20, "Pagar o preço da locação e demais encargos contratuais nos prazos estabelecidos.", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20

	oPrinter:SayAlign( nLin, 20, "Cláusula 6ª - Rescisão", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "O presente contrato poderá ser rescindido por qualquer das partes, mediante comunicação por escrito com antecedência mínima de 30 dias.", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20

	oPrinter:SayAlign( nLin, 20, "Cláusula 6ª - Foro", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "Para dirimir quaisquer dúvidas ou litígios oriundos deste contrato, as partes elegem o Foro da Comarca de São Paulo, Estado de SP.", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20
	oPrinter:SayAlign( nLin, 20, "**E, por estarem justos e contratados, assinam este instrumento em duas vias de igual teor e forma,", oFont1:OFONT, 520, 010, , 0,  ) 
	nLin += 20


	oPrinter:SetViewPDF(.t.)
	oPrinter:Preview()

Return

