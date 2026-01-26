#INCLUDE "TOTVS.CH"
#Include "QIEM100.ch"
#Include "Colors.ch"
#include "font.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEM100   ³ Autor ³ Cleber Souza          ³ data ³ 18/05/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Rotina de Administracao do arquivo TXT de importacao.	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAQIE                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Function QIEM100()

	Local aColsAux  := {}
	Local aCpoTxt   := {}
	Local aHeadAux  := {}
	Local cString   := ""
	Local nHandle   := 0
	Local nOpcA     := 0
	Local nP001		:= 0
	Local nP002		:= 0
	Local nP003		:= 0
	Local nP004		:= 0
	Local nP005		:= 0
	Local nP006		:= 0
	Local nP007		:= 0
	Local nP008		:= 0
	Local nP009		:= 0
	Local nP010		:= 0
	Local nP011		:= 0
	Local nP012		:= 0
	Local nP013		:= 0
	Local nP014		:= 0
	Local nP015		:= 0
	Local nP016		:= 0
	Local nP017		:= 0
	Local nP018		:= 0
	Local nP019		:= 0
	Local nP020		:= 0
	Local oFont1  	:= NIL
	Local oFont2  	:= NIL
	Local oGroup2 	:= NIL
	Local oGroup1 	:= NIL

	Private cArqImp := GetMv("MV_QTXTIMP")
	Private cNomSal := Space(40)
	Private hNo     := LoadBitmap(GetResources(),"LBNO")  //Nao OK
	Private hOk     := LoadBitmap(GetResources(),"LBOK")  //OK
	Private lCheck  := .F.
	Private nPosBrc := 0
	Private nPosCpo := 0
	Private nPosDec := 0
	Private nPosFim := 0
	Private nPosIni := 0
	Private nPosTam := 0
	Private nPosTip := 0
	Private nPosTit := 0
	Private oCheck  := NIL
	Private oGetApr := NIL
	Private oNomSal	:= NIL


//Verifica o caminho para gravacao do layout padrao,caso o mesmo nao exista
	If !File(cArqImp)

		//Atribindo valores para as posição a serem utilizadas na montagem do layout.
		nP001:= GetSx3Cache("QEP_FORNEC","X3_TAMANHO")
		nP002:= nP001+GetSx3Cache("QEP_LOJFOR","X3_TAMANHO")
		nP003:= nP002+GetSx3Cache("QEP_PRODUT","X3_TAMANHO")
		nP004:= nP003+GetSx3Cache("QEP_DTENTR","X3_TAMANHO")
		nP005:= nP004+GetSx3Cache("QEP_HRENTR","X3_TAMANHO")
		nP006:= nP005+GetSx3Cache("QEP_LOTE  ","X3_TAMANHO")
		nP007:= nP006+GetSx3Cache("QEP_DOCENT","X3_TAMANHO")
		nP008:= nP007+GetSx3Cache("QEP_TAMLOT","X3_TAMANHO")
		nP009:= nP008+GetSx3Cache("QEP_TAMAMO","X3_TAMANHO")
		nP010:= nP009+GetSx3Cache("QEP_PEDIDO","X3_TAMANHO")
		nP011:= nP010+GetSx3Cache("QEP_NTFISC","X3_TAMANHO")
		nP012:= nP011+GetSx3Cache("QEP_SERINF","X3_TAMANHO")
		nP013:= nP012+GetSx3Cache("QEP_ITEMNF","X3_TAMANHO")
		nP014:= nP013+GetSx3Cache("QEP_DTNFIS","X3_TAMANHO")
		nP015:= nP014+GetSx3Cache("QEP_TIPDOC","X3_TAMANHO")
		nP016:= nP015+GetSx3Cache("QEP_CERFOR","X3_TAMANHO")
		nP017:= nP016+GetSx3Cache("QEP_DIASAT","X3_TAMANHO")
		nP018:= nP017+GetSx3Cache("QEP_SOLIC ","X3_TAMANHO")
		nP019:= nP018+GetSx3Cache("QEP_PRECO ","X3_TAMANHO")
		nP020:= nP019+GetSx3Cache("QEP_EXCLUI","X3_TAMANHO")


		//Montagem das posições para a geração do layout padrao do arquivo de Importacao com base no tamanho dos campos na SX3
		Aadd(aCpoTxt,"0001"+STRZERO((nP001),4)+"QEP_FORNEC")
		Aadd(aCpoTxt,STRZERO(nP001+1,4)+STRZERO(nP002,4)+"QEP_LOJFOR")
		Aadd(aCpoTxt,STRZERO(nP002+1,4)+STRZERO(nP003,4)+"QEP_PRODUT")
		Aadd(aCpoTxt,STRZERO(nP003+1,4)+STRZERO(nP004,4)+"QEP_DTENTR")
		Aadd(aCpoTxt,STRZERO(nP004+1,4)+STRZERO(nP005,4)+"QEP_HRENTR")
		Aadd(aCpoTxt,STRZERO(nP005+1,4)+STRZERO(nP006,4)+"QEP_LOTE  ")
		Aadd(aCpoTxt,STRZERO(nP006+1,4)+STRZERO(nP007,4)+"QEP_DOCENT")
		Aadd(aCpoTxt,STRZERO(nP007+1,4)+STRZERO(nP008,4)+"QEP_TAMLOT")
		Aadd(aCpoTxt,STRZERO(nP008+1,4)+STRZERO(nP009,4)+"QEP_TAMAMO")
		Aadd(aCpoTxt,STRZERO(nP009+1,4)+STRZERO(nP010,4)+"QEP_PEDIDO")
		Aadd(aCpoTxt,STRZERO(nP010+1,4)+STRZERO(nP011,4)+"QEP_NTFISC")
		Aadd(aCpoTxt,STRZERO(nP011+1,4)+STRZERO(nP012,4)+"QEP_SERINF")
		Aadd(aCpoTxt,STRZERO(nP012+1,4)+STRZERO(nP013,4)+"QEP_ITEMNF")
		Aadd(aCpoTxt,STRZERO(nP013+1,4)+STRZERO(nP014,4)+"QEP_DTNFIS")
		Aadd(aCpoTxt,STRZERO(nP014+1,4)+STRZERO(nP015,4)+"QEP_TIPDOC")
		Aadd(aCpoTxt,STRZERO(nP015+1,4)+STRZERO(nP016,4)+"QEP_CERFOR")
		Aadd(aCpoTxt,STRZERO(nP016+1,4)+STRZERO(nP017,4)+"QEP_DIASAT")
		Aadd(aCpoTxt,STRZERO(nP017+1,4)+STRZERO(nP018,4)+"QEP_SOLIC ")
		Aadd(aCpoTxt,STRZERO(nP018+1,4)+STRZERO(nP019,4)+"QEP_PRECO ")
		Aadd(aCpoTxt,STRZERO(nP019+1,4)+STRZERO(nP020,4)+"QEP_EXCLUI")

		nHandle := fCreate(cArqImp)
		Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
		fClose(nHandle)

	EndIf

	QE100Load(@aColsAux,@aHeadAux)

//Sugere salvar como nome padrao
	cNomSal := cArqImp

	DEFINE MSDIALOG oDlg TITLE STR0001 From 020,000 To 560,600 OF oMainWnd Pixel  //"Administração TXT de Importação"
	DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD
	DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11

	@ 015,003 GROUP oGroup1 TO 237,298	LABEL "" OF oDlg PIXEL
	oGroup1:oFont:= oFont1

	@ 240,003 GROUP oGroup2 TO 268,298	LABEL "" OF oDlg PIXEL
	oGroup2:oFont:= oFont1

	oGetApr := MsNewGetDados():New(19,5,235,296,GD_UPDATE,,,"",,,,,,,oDlg,aHeadAux,aColsAux)
	oGetApr:AddAction("OK1",{||QE100ACEOK()})

//Força apenas a visualização dos campos.
	oGetApr:aInfo[nPosTam,5]:='V'
	oGetApr:aInfo[nPosCpo,5]:='V'
	oGetApr:aInfo[nPosTit,5]:='V'
	oGetApr:aInfo[nPosTip,5]:='V'
	oGetApr:aInfo[nPosDec,5]:='V'
	oGetApr:aInfo[nPosBrc,5]:='V'

	@ 250,008 SAY  OemToAnsi(STR0002)    Of oDlg PIXEL FONT oFont2 //"Salvar como : "
	@ 250,050 MSGET oNomSal    VAR cNomSal SIZE 080,8 PIXEL Of oDlg
	@ 250,180 CHECKBOX oCheck  VAR lCheck PROMPT OemToAnsi(STR0003) OF oDlg SIZE 95,11 PIXEL  //"Deseja Substituir arquivo existente."

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(QE100TUDOK(),(nOpcA:=1,oDlg:End()),.F.)},{||nOpcA:=0,oDlg:End()}) CENTERED

	If nOpcA==1
		QE100GRVALL()
	endIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QE100Load ³ Autor ³Cleber L. Souza 		³ Data ³18/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta aHeader e aCols com os campos para escolha           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE100Load(EXPA1,EXPA2)		     						  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 - Array com os Itens (aCols)						  ³±±
±±³          ³ EXPA2 - Array com as Colunas (aHeader)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QE100Load(aCols,aHeader)

	Local bHeadMed
	Local cAlias
	Local cQuery
	Local cIndex
	Local nHandle
	Local nTamArq := 0
	Local nTamLin := 0
	Local nBytes  := 0
	Local xBuffer
	Local nY      := 0
	Local nX
	Local aStrut

//Monta aHeader 
	Aadd(aHeader,{"OK"   ,"OK1"   ,"@BMP",03,0,""  			  ,""               ,"C","","","",""})
	Aadd(aHeader,{STR0004,"CAMPO" ,"@!"  ,15,0,""			      ,"€€€€€€€€€€€€€€ ","C","","","",""}) //"Campo"
	Aadd(aHeader,{STR0005,"TITULO","@!"  ,25,0,""                ,"€€€€€€€€€€€€€€ ","C","","","",""}) //"Titulo"
	Aadd(aHeader,{STR0006,"INIC"  ,"@!"  ,04,0,"QE100VALPOS('I')",""               ,"C","","","",""}) //"Inicio"
	Aadd(aHeader,{STR0007,"FIM"   ,"@!"  ,04,0,"QE100VALPOS('F')",""               ,"C","","","",""}) //"Fim"
	Aadd(aHeader,{STR0008,"TAM"   ,"@999",03,0,""			      ,"€€€€€€€€€€€€€€ ","N","","","",""}) //"Tamanho"
	Aadd(aHeader,{STR0009,"TIPO"  ,"@!"  ,01,0,""				  ,"€€€€€€€€€€€€€€ ","C","","","",""}) //"Tipo"
	Aadd(aHeader,{STR0010,"DEC"   ,"@9"  ,01,0,""				  ,"€€€€€€€€€€€€€€ ","N","","","",""}) //"Decimal"
	Aadd(aHeader,{""     ,"BRC"   ,"@!"  ,01,0,""				  ,"€€€€€€€€€€€€€€ ","C","","","",""})

	aStrut := FWFormStruct(3,"QEP",,.F.)[3]
	For nX := 1 to Len(aStrut)
		aadd(aCols,Array(Len(aHeader)+1))
		aCols[Len(aCols),1] := hNo
		aCols[Len(aCols),2] := aStrut[nX,1]
		aCols[Len(aCols),3] := QAGetX3Tit(aStrut[nX,1])
		aCols[Len(aCols),4] := "9999"
		aCols[Len(aCols),5] := "9999"
		aCols[Len(aCols),6] := GetSx3Cache(aStrut[nX,1],"X3_TAMANHO")
		aCols[Len(aCols),7] := GetSx3Cache(aStrut[nX,1],"X3_TIPO")
		aCols[Len(aCols),8] := GetSx3Cache(aStrut[nX,1],"X3_DECIMAL")
		aCols[Len(aCols),Len(aHeader)+1] := .F.
	Next nX

//Pesquisa posicao das Colunas na aCols
	nPosCpo := Ascan(aHeader,{|x|Alltrim(x[2])=="CAMPO"})
	nPosIni := Ascan(aHeader,{|x|Alltrim(x[2])=="INIC"})
	nPosFim := Ascan(aHeader,{|x|Alltrim(x[2])=="FIM"})
	nPosTam := Ascan(aHeader,{|x|Alltrim(x[2])=="TAM"})
	nPosTit := Ascan(aHeader,{|x|Alltrim(x[2])=="TITULO"})
	nPosTip := Ascan(aHeader,{|x|Alltrim(x[2])=="TIPO"})
	nPosDec := Ascan(aHeader,{|x|Alltrim(x[2])=="DEC"})
	nPosBrc := Ascan(aHeader,{|x|Alltrim(x[2])=="BRC"})

//Pesquisa campos do TXT
	nHandle := fOpen(cArqImp,2+64)

//Posiciona no arquivo
	nTamArq := fSeek(nHandle,0,2)
	nTamLin := 20
	fSeek(nHandle,0,0)

	While nBytes < nTamArq
		xBuffer := Space(nTamLin)
		fRead(nHandle,@xBuffer,nTamLin)

		nPosCp := Ascan(aCols,{|x|Alltrim(x[2])==AllTrim(SubStr(xBuffer,9,10))})
		If nPosCp>0
			aCols[nPosCp,1] := hOK
			aCols[nPosCp,nPosIni] := SubStr(xBuffer,1,4)
			aCols[nPosCp,nPosFim] := SubStr(xBuffer,5,4)
		EndIF

		nBytes+=nTamLin
	EndDo

//Fecha o arquivo de configuracao
	fClose(nHandle)

//Organiza array na tela em ordem de campo para verificação do usuário.
	ASORT(aCols,,,{|x,y| x[4]+x[5] < y[4]+y[5] })
	Aeval(aCols,{|x,y|aCols[y,nPosIni]:=IIF(aCols[y,nPosIni]=="9999",Space(4),aCols[y,nPosIni])})
	Aeval(aCols,{|x,y|aCols[y,nPosFim]:=IIF(aCols[y,nPosFim]=="9999",Space(4),aCols[y,nPosFim])})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QE100ACEOK ³ Autor ³Cleber L. Souza 		³ Data ³18/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os BMPs de marcado e desmarcado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE100ACEOK					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE100ACEOK()

	If oGetApr:aCols[oGetApr:nAT,1] == hOk
		oGetApr:aCols[oGetApr:nAT,1] := hNo
	Else
		oGetApr:aCols[oGetApr:nAT,1] := hOk
	EndIf

	oGetApr:Refresh()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QE100TUDOK ³ Autor ³Cleber L. Souza 		³ Data ³18/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os BMPs de marcado e desmarcado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE100TUDOK					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 - Retorno da Validação das Infos digitadas.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE100TUDOK()

	Local lRet  := .T.
	Local aCols := oGetApr:aCols
	Local nY    := 0

	For nY:=1 to Len(aCols)

		If aCols[nY,1] == hOK .and. (  Empty(aCols[nY,nPosIni]) .or. Empty(aCols[nY,nPosFim]) )
			Help("  ",1,"QIEM10001") //"Existem campos selecionados sem Posição Inicial ou Final"
			lRet := .F.
			Exit
		Endif

		If aCols[nY,1] == hNO .and. ( !Empty(aCols[nY,nPosIni]) .or. !Empty(aCols[nY,nPosFim]) )
			Help("  ",1,"QIEM10002") //"Existem campos com posição Inicial/Final preenchidos que não foram selecionados."
			lRet := .F.
			Exit
		EndIf

	Next nY

	If lRet
		If Empty(cNomSal)
			Help("  ",1,"QIEM10003") //"É obrigatório a digitação do nome do arquivo TXT."
			lRet := .F.
		EndIF
	EndIf

	If lRet
		If File(cNomSal) .and. !lCheck
			Help("  ",1,"QIEM10004") //"O arquivo informado já existe, para substitui-lo, favor informar na tela de administração do TXT."
			lRet := .F.
		EndIF
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QE100GRVALL³ Autor ³Cleber L. Souza 		³ Data ³18/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os BMPs de marcado e desmarcado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE100GRVALL					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE100GRVALL()

	Local aCpoTxt := {}
	Local nY      := 0
	Local aCols   := oGetApr:aCols

	If File(cNomSal) .and. lCheck
		If !FileDelete( cNomSal )
			Help("  ",1,"QIEM10005") //Nao foi possivel criar novo arquivo TXT pois o antigo não foi pode ser deletado.
			Return(NIL)
		EndIf
	EndIf

	For nY:=1 to Len(aCols)
		If aCols[nY,1]==hOK
			Aadd(aCpoTxt,StrZero(Val(aCols[nY,nPosIni]),4)+StrZero(Val(aCols[nY,nPosFim]),4)+PadR(Alltrim(aCols[nY,nPosCpo]),10))
		EndIF
	Next nY

	nHandle := fCreate(cNomSal)
	Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
	fClose(nHandle)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QE100VALPOS³ Autor ³Cleber L. Souza 		³ Data ³18/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os campos de posição Inicial e Final dos campos.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE100VALPOS					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 - Indica se e campo Inicio (I) ou Final (F)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 - Retorno logico com a validação do campo.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM100													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE100VALPOS(cCpo)

	Local lRet := .T.
	Local nAT  := oGetApr:nAT

	If cCpo=="I"
		oGetApr:aCols[nAT,nPosFim] := StrZero(Val(&(ReadVar())) + oGetApr:aCols[nAT,nPosTam] - 1,4)
		oGetApr:Refresh()
	Else
		If &(ReadVar()) < oGetApr:aCols[nAT,nPosIni]
			lRet := .F.
		EndIF
	EndIF

Return(lRet)
