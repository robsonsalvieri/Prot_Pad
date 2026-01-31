#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MAT410RG.CH" //TRATAMENTO PARA RECEBIMENTO DE PAGAMENTO ENTE GOV.


//------------------------------------------------------------------------------
/*/{Protheus.doc} MAT410RG
Facilitador para geração de pedido de recebimento

@sample 	MAT410RG() 
@param		Nil
@return		Nil

@author		SQUAD CRM / FAT
@since		21/11/25  
@version	P12.1.25
/*/
//------------------------------------------------------------------------------
Function MAT410RG()

Local cTDataDe  := OemToAnsi(STR0001) //-- Dt. Emissão De
Local cTDataAte := OemToAnsi(STR0002) //-- Dt. Emissão Até
Local nOpcao    := 0
Local dDataDe	:= CToD('  /  /  ')
Local dDataAte	:= CToD('  /  /  ')
Local oDlgEsp

Private cCliente 	:= CriaVar("F2_CLIENTE",.F.)
Private cLoja    	:= CriaVar("F2_LOJA",.F.)
Private cTes    	:= CriaVar("C6_TES",.F.)

	DEFINE MSDIALOG oDlgEsp FROM 00,00 TO 120,490 PIXEL TITLE OemToAnsi(STR0003) //"Recebimento de Pagamento Gov." 
		
	@ 010,05 SAY RetTitle("F2_CLIENTE") PIXEL 
	@ 010,40 MSGET cCliente F3 'SA1' SIZE 65, 10 OF oDlgEsp PIXEL

	@ 010,120 SAY RetTitle("F2_LOJA") PIXEL 
	@ 010,160 MSGET cLoja SIZE 20, 10 OF oDlgEsp PIXEL ;
			VALID Vazio() .Or. ExistCpo('SA1',cCliente+cLoja,1)

	@ 39,05 SAY cTDataDe PIXEL //-- Dt. Emissão De
	@ 38,45 MSGET dDataDe PICTURE "@D" SIZE 45, 10 OF oDlgEsp PIXEL

	@ 39,120 SAY cTDataAte PIXEL //-- Dt. Emissão Até
	@ 38,165 MSGET dDataAte PICTURE "@D" SIZE 45, 10 OF oDlgEsp PIXEL

	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgEsp ENABLE ;
		ACTION Iif(!Empty(cCliente) .And. !Empty(cLoja) .And. ;
					!Empty(dDataDe) .And. !Empty(dDataAte), ;
					(nOpcao := 1,oDlgEsp:End()),.F.)

	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgEsp ENABLE ACTION (nOpcao := 0,oDlgEsp:End())

	ACTIVATE MSDIALOG oDlgEsp CENTERED

	If nOpcao == 1
		GovNfOri(cCliente,cLoja,dDataDe,dDataAte)
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GovNfOri
Busca as notas do cliente no range de datas informado

@sample 	GovNfOri() 
@param		cCliente	caracter	código do cliente
			cLoja		caracter	loja do cliente
			dDataDe		data		data inicial do range de busca
			dDataAte	data		data final do range de busca
@return		Nil

@author		SQUAD CRM / FAT
@since		21/11/25  
@version	P12.1.25
/*/
//------------------------------------------------------------------------------
Static Function GovNfOri(cCliente,cLoja,dDataDe,dDataAte)

Local aArea	  	:= GetArea()
Local aNfOri	:= {}
Local cAliasQry1:= ""
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local cCadastro	:= ""
Local cQuery	:= ""
Local cTCliente   := ""
Local cVar		:= ""
Local nOAT      := 0
Local nOpca     := 0
Local oDlg		:= Nil
Local oQual		:= Nil
Local cNome 	:= ""
Local oQryNfsGov := Nil
Local nTamVlBrut:= FWSX3Util():GetFieldStruct( 'F2_VALBRUT' )[3]
Local nTamVlMerc:= FWSX3Util():GetFieldStruct( 'F2_VALMERC' )[3]
Local nDecVlBrut:= FWSX3Util():GetFieldStruct( 'F2_VALBRUT' )[4]
Local nDecVlMerc:= FWSX3Util():GetFieldStruct( 'F2_VALMERC' )[4]
Local cFilSA1	:= FwxFilial("SA1")
Local cFilSF2	:= FwxFilial("SF2")

Default cCliente:= ""
Default cLoja	:= ""
Default dDataDe := ""
Default dDataAte:= ""

cAliasQry1	:= GetNextAlias()

cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_EMISSAO,SF2.F2_VALBRUT, SF2.F2_VALMERC,SA1.A1_NOME"
cQuery += " FROM "+ RetSqlName("SF2") +" SF2"
cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1" 
cQuery += " ON SA1.A1_FILIAL = ?"
cQuery += " AND SA1.A1_COD = SF2.F2_CLIENTE"
cQuery += " AND SA1.A1_LOJA = SF2.F2_LOJA"
cQuery += " AND SA1.D_E_L_E_T_ = ?" 
cQuery += " WHERE SF2.F2_FILIAL = ?" 
cQuery += " AND SF2.F2_TIPO = ?" 
cQuery += " AND SF2.F2_GOVOPER = ?" 
cQuery += " AND SF2.F2_CLIENTE = ?" 
cQuery += " AND SF2.F2_LOJA = ?"
cQuery += " AND SF2.F2_EMISSAO >= ?"
cQuery += " AND SF2.F2_EMISSAO <= ?"
cQuery += " AND SF2.D_E_L_E_T_ = ?"
cQuery += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA"

cQuery	:= ChangeQuery(cQuery)

oQryNfsGov := FwExecStatement():New(cQuery)

oQryNfsGov:SetString( 1, cFilSA1)
oQryNfsGov:SetString( 2, ' ')
oQryNfsGov:SetString( 3, cFilSF2)
oQryNfsGov:SetString( 4, 'N')
oQryNfsGov:SetString( 5, '1')
oQryNfsGov:SetString( 6, cCliente)
oQryNfsGov:SetString( 7, cLoja)
oQryNfsGov:SetString( 8, DtoS(dDataDe))
oQryNfsGov:SetString( 9, DtoS(dDataAte))
oQryNfsGov:SetString( 10, ' ')

cAliasQry1 := oQryNfsGov:OpenAlias() //oQryNfsGov:getFixQuery()

//Adiciona as notas no array aNfOri para a tela de seleção das notas de origem
While !(cAliasQry1)->(Eof())
	AADD(aNfOri,{;
			(cAliasQry1)->F2_DOC,;
			(cAliasQry1)->F2_SERIE,;
			SToD((cAliasQry1)->F2_EMISSAO),;
			Str((cAliasQry1)->F2_VALBRUT,nTamVlBrut,nDecVlBrut),;
			Str((cAliasQry1)->F2_VALMERC,nTamVlMerc,nDecVlMerc);
		})
	If Empty(cNome)
		cNome := (cAliasQry1)->A1_NOME
	EndIf
	(cAliasQry1)->(dbSkip())
EndDo

If !Empty(aNfOri)

	aSize[1] /= 1.5
	aSize[2] /= 1.5
	aSize[3] /= 1.5
	aSize[4] /= 1.3
	aSize[5] /= 1.5
	aSize[6] /= 1.3
	aSize[7] /= 1.5

	AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
	AAdd( aObjects, { 100, 060,.T.,.T.,.T.} )
	AAdd( aObjects, { 100, 020,.T.,.F.} )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	cCadastro:= STR0004 	//Notas Fiscais de Fornecimento - Documento de Saída
	
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],000 To aSize[6],aSize[5] OF oMainWnd PIXEL

	@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED

	cTCliente := AllTrim(RetTitle("C5_CLIENTE"))+"/"+AllTrim(RetTitle("C5_LOJCLI"))+": "+cCliente+"/"+cLoja+"  -  "+RetTitle("A1_NOME")+": "+cNome
	@ 002,005 SAY cTCliente SIZE aPosObj[1,3],008 OF oPanel PIXEL

	@ 008,250 SAY STR0005 PIXEL 
	@ 001,330 MSGET cTes F3 'SF4' SIZE 40, 10 OF oPanel PIXEL ;
			VALID cTes > "500" .And. ExistCpo('SF4',cTes,1) .And. VldTESRGov(cTes)

	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oQual VAR cVar Fields HEADER STR0006,STR0007,STR0008,STR0009,STR0010 SIZE aPosObj[2,3],aPosObj[2,4] ON DBLCLICK (nOpca := 1,oDlg:End()) PIXEL	//"Nota"##"Série"##"Emissão"##"Valor Bruto"##"Valor Mercadoria"

	oQual:SetArray(aNfOri)
	oQual:bLine := { || {aNfOri[oQual:nAT][1],aNfOri[oQual:nAT][2],aNfOri[oQual:nAT][3],aNfOri[oQual:nAT][4],aNfOri[oQual:nAT][5]}}

	DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030  TYPE 1 ACTION (nOpca := 1,oDlg:End()) 	ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION oDlg:End() 					ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT, .t.) CENTERED

	If nOpca == 1
		CriaPedPag(cCliente,cLoja,aNfOri[nOAT][1],aNfOri[nOAT][2],cTes)
	EndIf
Else
	Help( , , STR0011, , STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013}) //"Sem Nota"##"Não localizamos documentos aptos ao registro de Pagamento de Ente Governamental."##"Verifique os dados utilizamos na busca."
EndIf

RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CriaPedPag
Cria o pedido de venda para Recebimento baseado na nota de Fornecimento selecionada

@sample 	CriaPedPag() 
@param		cCliente	caracter	código do cliente
			cLoja		caracter	loja do cliente
			cNfOri		caracter	numeração da nota de origem
			cSerOri		caracter	serie da nota de origem
			cTes		caracter	TES a ser utilizada no pedido gerado
@return		.T.			lógico		<sem função>

@author		SQUAD CRM / FAT
@since		21/11/25  
@version	P12.1.25
/*/
//------------------------------------------------------------------------------
Static Function CriaPedPag(cCliente,cLoja,cNfOri,cSerOri,cTes)

Local aArea 		:= GetArea()
Local aAreaSCJ		:= SCJ->(GetArea())
Local aDadosCfo		:= {}
Local aColsC6		:= {}
Local nCntFor		:= 0
Local nCntCps		:= 0
Local nMaxFor		:= 0
Local nAcols		:= 0
Local nUsado		:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nL 			:= 0
Local nStack		:= GetSX8Len()  
Local bCampo		:= {|x| FieldName(x) }
Local cItSC6		:= "00"
Local aCamposQry	:= {}
Local aCmpsAux1		:= {}
Local aCmpsAux2		:= {}
Local nQtdCpos		:= 0
Local aCposSC6 		:= {}
Local cFilSD2		:= FwxFilial("SD2")
Local cFilSE4		:= FwXFilial("SE4")
Local cFilSA1 		:= FWxFilial("SA1")
Local cFilSF4 		:= FwXFilial("SF4")
Local cFilSB1		:= FwXFilial("SB1")
Local aHeadC6		:= {}

Private aSize		:= MsAdvSize()
Private aObjects 	:= {} 
Private aInfo    	:= {} 
Private aPosObj  	:= {} 
PRIVATE aHeader   	:= {}
PRIVATE aCols     	:= {{.F.}}
PRIVATE aHeadGrade	:= {}
PRIVATE aColsGrade	:= {}
PRIVATE aMemoSC6 	:= { { 'C6_CODINF', 'C6_INFAD' } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os DEFAULT´s do sistema                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cCliente:= ""
Default cLoja	:= ""
Default cNfOri	:= ""
Default cSerOri	:= ""
Default cTes	:= ""

//Campos do select
aAdd(aCamposQry,"F2_CLIENTE")
aAdd(aCamposQry,"F2_LOJA")
aAdd(aCamposQry,"F2_CLIENTE")
aAdd(aCamposQry,"F2_LOJA")
aAdd(aCamposQry,"F2_TIPOCLI")
aAdd(aCamposQry,"F2_COND")
aAdd(aCamposQry,"F2_VALMERC")
aAdd(aCamposQry,"F2_FRETE")
aAdd(aCamposQry,"F2_SEGURO")
aAdd(aCamposQry,"F2_DESPESA")
aAdd(aCamposQry,"F2_FRETAUT")
aAdd(aCamposQry,"F2_MOEDA")
aAdd(aCamposQry,"F2_TXMOEDA")
aAdd(aCamposQry,"F2_DESCONT")
aAdd(aCamposQry,"F2_TPFRETE")

aAdd(aCamposQry,"D2_ITEM")
aAdd(aCamposQry,"D2_COD")
aAdd(aCamposQry,"D2_UM")
aAdd(aCamposQry,"D2_SEGUM")
aAdd(aCamposQry,"D2_QUANT")
aAdd(aCamposQry,"D2_PRCVEN")
aAdd(aCamposQry,"D2_TOTAL")
aAdd(aCamposQry,"D2_LOCAL")
aAdd(aCamposQry,"D2_DESCON")  
aAdd(aCamposQry,"D2_PEDIDO")
aAdd(aCamposQry,"D2_PRUNIT")
aAdd(aCamposQry,"D2_CLASFIS")
aAdd(aCamposQry,"D2_CONTA")
aAdd(aCamposQry,"D2_ITEMCC")
aAdd(aCamposQry,"D2_CCUSTO")
aAdd(aCamposQry,"D2_DOC")
aAdd(aCamposQry,"D2_SERIE")

nQtdCampos := Len(aCamposQry)

If !Empty(cNfOri) .And. !Empty(cSerOri)

	cAliasQry2	:= GetNextAlias()

	cQryItens := "SELECT "
	For nX := 1 to nQtdCampos
		cQryItens += aCamposQry[nX]
		If nX < nQtdCampos
			cQryItens += ","
		EndIf
	Next nX
	cQryItens += " FROM "+ RetSqlName("SD2") +" SD2"
	cQryItens += " INNER JOIN "+ RetSqlName("SF2") +" SF2 
 	cQryItens += " ON SF2.F2_FILIAL = SD2.D2_FILIAL"
   	cQryItens += " AND SF2.F2_DOC = SD2.D2_DOC"
   	cQryItens += " AND SF2.F2_SERIE = SD2.D2_SERIE"
   	cQryItens += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE"
   	cQryItens += " AND SF2.F2_LOJA = SD2.D2_LOJA"
   	cQryItens += " AND SF2.D_E_L_E_T_ = ?"
	cQryItens += " WHERE SD2.D2_FILIAL = ?"
  	cQryItens += " AND SD2.D2_DOC = ?"
  	cQryItens += " AND SD2.D2_SERIE = ?"
  	cQryItens += " AND SD2.D2_CLIENTE = ?"
  	cQryItens += " AND SD2.D2_LOJA = ?"
  	cQryItens += " AND SD2.D_E_L_E_T_ = ?"
	cQryItens += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SD2.D2_ITEM"
	
	cQryItens	:= ChangeQuery(cQryItens)
	
	oQryNfsGov := FwExecStatement():New(cQryItens)

	oQryNfsGov:SetString( 1, ' ')
	oQryNfsGov:SetString( 2, cFilSD2)
	oQryNfsGov:SetString( 3, cNfOri)
	oQryNfsGov:SetString( 4, cSerOri)
	oQryNfsGov:SetString( 5, cCliente)
	oQryNfsGov:SetString( 6, cLoja)
	oQryNfsGov:SetString( 7, ' ')
						
	cAliasQry2 := oQryNfsGov:OpenAlias() //oQryNfsGov:getFixQuery()

EndIf

If !(cAliasQry2)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader do SC6                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeadC6 := {}
	aCmpsAux1 := FWSX3Util():GetListFieldsStruct("SC6",.T.)
	nQtdCpos := Len(aCmpsAux1)
	//Ordenar pelo campo X3_ORDEM
	For nY := 1 To nQtdCpos
		aAdd(aCmpsAux2,{aCmpsAux1[nY],GetSX3Cache(aCmpsAux1[nY][1],"X3_ORDEM")})
	Next nY
	aSort(aCmpsAux2,,,{|x,y| x[2] < y[2] })
	For nZ := 1 To nQtdCpos
		aAdd(aCposSC6,aCmpsAux2[nZ][1])
	Next nZ
	For nL := 1 To nQtdCpos
		If (  ((X3USO(GetSX3Cache(aCposSC6[nL][1],"X3_USADO")) .And. ;
				!( Trim(aCposSC6[nL][1]) == "C6_NUM" ) .And.;
				Trim(aCposSC6[nL][1]) != "C6_QTDEMP"  .And.;
				Trim(aCposSC6[nL][1]) != "C6_QTDENT") .And.;
				cNivel >= GetSX3Cache(aCposSC6[nL][1],"X3_NIVEL")).Or.;
				Trim(aCposSC6[nL][1])=="C6_OP" .Or. ;
				Trim(aCposSC6[nL][1])=="C6_OPC" )	
				aAdd(aHeadC6,{ Trim(FWX3Titulo(aCposSC6[nL][1])),;
							FWSX3Util():GetFieldStruct(aCposSC6[nL][1])[1],;
							GetSX3Cache(aCposSC6[nL][1],"X3_PICTURE"),;
							aCposSC6[nL][3],;
							aCposSC6[nL][4],;
							GetSX3Cache(aCposSC6[nL][1],"X3_VALID"),;
							GetSX3Cache(aCposSC6[nL][1],"X3_USADO"),;
							aCposSC6[nL][2],;
							GetSX3Cache(aCposSC6[nL][1],"X3_ARQUIVO"),;
							GetSX3Cache(aCposSC6[nL][1],"X3_CONTEXT") } )
		EndIf
	Next nL
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria as variaveis do Pedido de Venda                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	nMaxFor := FCount()
	For nCntCps := 1 To nMaxFor
		M->&(EVAL(bCampo,nCntCps)) := CriaVar(FieldName(nCntCps),.T.)
	Next nCntCps
	M->C5_TIPO		:= "N"
	M->C5_CLIENTE	:= (cAliasQry2)->F2_CLIENTE
	M->C5_LOJACLI	:= (cAliasQry2)->F2_LOJA
	M->C5_CLIENT	:= (cAliasQry2)->F2_CLIENTE
	M->C5_LOJAENT	:= (cAliasQry2)->F2_LOJA
	M->C5_TIPOCLI	:= (cAliasQry2)->F2_TIPOCLI
	M->C5_CONDPAG	:= (cAliasQry2)->F2_COND
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(cFilSE4+M->C5_CONDPAG)) .And. SE4->E4_TIPO == "9"
		M->C5_PARC1	:= (cAliasQry2)->F2_VALMERC //Por se tratar de Pagamento Gov. todo valor é regsitrado em uma úunica parcela
		M->C5_DATA1	:= dDataBase
	EndIf
	M->C5_FRETE   := (cAliasQry2)->F2_FRETE
	M->C5_SEGURO  := (cAliasQry2)->F2_SEGURO
	M->C5_DESPESA := (cAliasQry2)->F2_DESPESA
	M->C5_FRETAUT := (cAliasQry2)->F2_FRETAUT

	M->C5_MOEDA   := (cAliasQry2)->F2_MOEDA
	M->C5_TXMOEDA := (cAliasQry2)->F2_TXMOEDA 
	M->C5_TIPLIB  := "2" //Por se tratar de Pagamento Gov. é sempre 2
	M->C5_DESCONT := (cAliasQry2)->F2_DESCONT
	M->C5_TPFRETE := (cAliasQry2)->F2_TPFRETE
	//C5_VEND - Não trata vendedores pois é apenas registro do pagamento do ente gov.
	M->C5_GOVOPER := "2"
	
	While !(cAliasQry2)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche o Acols do Pedido de Venda                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aHeadC6)
		aadd(aColsC6,Array(nUsado+1))
		nAcols := Len(aColsC6)
		aColsC6[nAcols,nUsado+1] := .F.
		For nCntFor := 1 To nUsado
			Do Case
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_ITEM" )
					cItSC6 := Soma1(cItSC6)
					aColsC6[nAcols,nCntFor] := cItSC6
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_PRODUTO" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_COD
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_UM" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_UM
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_SEGUM" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_SEGUM
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_QTDVEN" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_QUANT
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_PRCVEN" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_PRCVEN
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_VALOR" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_TOTAL
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_TES" )
					aColsC6[nAcols,nCntFor] := cTES
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_CF" )

					aDadosCfo := {}

					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))

					DbSelectArea("SF4")
					SF4->(DbSetOrder(1))

					If SA1->(DbSeek(cFilSA1+cCliente+cLoja)) .And.;
						SF4->(DbSeek(cFilSF4+cTES))
						
						Aadd(aDadosCfo,{"OPERNF"  ,"S"}) 
						Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
						Aadd(aDadosCfo,{"UFDEST"  ,SA1->A1_EST})
						Aadd(aDadosCfo,{"INSCR"   ,SA1->A1_INSCR})
						Aadd(aDadosCfo,{"CONTR"   ,SA1->A1_CONTRIB})
						Aadd(aDadosCfo,{"FRETE"   ,M->C5_TPFRETE})

						aColsC6[nAcols,nCntFor] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
					EndIf

				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_LOCAL" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_LOCAL
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_VALDESC" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_DESCON
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_ENTREG" )
					aColsC6[nAcols,nCntFor] := dDataBase
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_PEDCLI" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_PEDIDO
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_DESCRI" )
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					If SB1->(DbSeek(cFilSB1+(cAliasQry2)->D2_COD))
						aColsC6[nAcols,nCntFor] := SB1->B1_DESC
					EndIf
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_PRUNIT" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_PRUNIT
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_CLASFIS" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_CLASFIS
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_CONTA" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_CONTA
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_CLVL" )
					aColsC6[nAcols,nCntFor] := SB1->B1_CLVL
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_ITEMCTA" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_ITEMCC
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_CC" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_CCUSTO
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_NFORI" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_DOC
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_SERIORI" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_SERIE
				Case ( AllTrim(aHeadC6[nCntFor,2]) == "C6_ITEMORI" )
					aColsC6[nAcols,nCntFor] := (cAliasQry2)->D2_ITEM
				OtherWise
					aColsC6[nAcols,nCntFor] := CriaVar(aHeadC6[nCntFor,2],.T.)			
			EndCase
		Next nCntFor
		(cAliasQry2)->(dbSkip())
	EndDo
																
	If !Empty(aColsC6)

		aCols   := aColsC6
		aHeader := aHeadC6

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis Utilizadas pela Funcao a410Inclui          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRIVATE ALTERA := .F.
		PRIVATE INCLUI := .T.
					
		cCadastro := STR0014 //"Pedido de Venda: Recebimento Gov."
		Pergunte("MTA410",.F.)
		a410Inclui(Alias(),Recno(),4,.T.,nStack,)
	EndIf
EndIf

MsUnLockAll()
RestArea(aAreaSCJ)
RestArea(aArea)

Return(.T.)

Static Function VldTESRGov(cTes)

Local lRet := .T.

Default cTes := ""

DbSelectArea("SF4")
SF4->(DbSetOrder(1))
SF4->(DbSeek(FwXFilial("SF4")+cTES)) 
If SF4->F4_ESTOQUE == 'S' .Or. SF4->F4_DUPLIC == 'S'
	Help( , , STR0015, , STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0017}) //"TES Inválida"##"Este pedido será utilizado para registrar o Recebimento de Pagamento referente a uma nota de Fornecimento para Ente Governamental"##"A TES não deve movimentar estoque ou gerar financeiro."
	lRet := .F.
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} MT410OpGov
Função de controle de edição do C5_GOVOPER

@sample 	MT410OpGov(cPedTipo,cCliente,cLoja)
@param		cPedTipo	caracter	tipo do pedido (C5_TIPO)
			cCliente	caracter	código do cliente
			cLoja		caracter	loja do cliente
@return		cRet		caracter	conteúdo do C5_GOVOPER

@author		SQUAD CRM / FAT
@since		14/11/25  
@version	P12.1.25
/*/
//------------------------------------------------------------------------------ 
Function MT410OpGov(cPedTipo,cCliente,cLoja)

Local aArea			:= GetArea()
Local aAreaAI0		:= AI0->(GetArea())
Local nPosGovOpe	:= 0
Local cRet			:= ""
Local lReadOnly		:= .F.

Default cPedTipo 	:= ""
Default cCliente 	:= ""
Default cLoja	 	:= ""

If cPaisLoc == "BRA" .And. AI0->(ColumNPos("AI0_ENTGOV")) > 0 .And. SC5->(ColumNPos("C5_GOVOPER")) > 0 .And. Type('oGetPV')=="O"
	nPosGovOpe := Ascan(oGetPV:aEntryCtrls,{|x| Upper(Trim(x:cReadVar)) == "M->C5_GOVOPER"})
	If nPosGovOpe > 0
		If !Empty(cPedTipo) .And. cPedTipo $ "NCB" .And. !Empty(cCliente) .And. !Empty(cLoja)
			DbSelectArea("AI0")
			AI0->(DbSetOrder(1))
			If AI0->(DbSeek(xFilial("AI0")+cCliente+cLoja)) .And. AI0->AI0_ENTGOV $ '1|2|3|4'
				oGetPV:aEntryCtrls[nPosGovOpe]:lReadOnly := .F.
				If Empty(M->C5_GOVOPER)
					cRet := "1"
				EndIf
			Else
				lReadOnly := .T.
			EndIf
		Else
			lReadOnly := .T.
		EndIf

		If lReadOnly
			oGetPV:aEntryCtrls[nPosGovOpe]:lReadOnly := .T.
			cRet := " "
		EndIf
	EndIf
EndIf



RestArea(aAreaAI0)
RestArea(aArea)

Return cRet
