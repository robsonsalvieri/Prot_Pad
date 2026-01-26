#INCLUDE "SFPD102.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2Load()           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega List de Produto para a consulta avancada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aProduto, nProduto - Array e Posicao de Produtos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2Load(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, lProdAnt)
Local nI		:=	0
Local nCargMax	:=	0
Local cPesqFabr	:=	""

If !Empty(cProduto) .And. lProdAnt  
	HB1->(dbSetOrder(1))
	If HB1->(dbSeek(RetFilial("HB1")+cProduto))
		nTop := HB1->(Recno())
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

aSize(aProduto,0)
//nCargMax:=GetListRows(oBrwProd)
If lNotTouch
	nCargMax := HB1->(RecCount())
Else	
	nCargMax:=GridRows(oBrwProd)
EndIf
If nOrder == 3
	If cPesqFabr == "S"
		If Select("HA5")>0
			HA5->(dbSetOrder(1))
			If nTop == 0 
				HA5->(dbSeek(RetFilial("HA5")))
				//HB1->(dbGoTop())
				If !HA5->(Eof())
					nTop := HA5->(Recno())
				EndIf
			Else
				HA5->(dbGoTo(nTop))
			EndIf
		 	HB1->(dbSetOrder(1))
		 	//HA2->(dbSetOrder(1))
			For nI:=1 to nCargMax
				If nI > nCargMax
					break
				Endif
				If !HA5->(Eof()) 
		      		//If HA2->(dbSeek(RetFilial("HA2")+HA5->HA5_FORNEC+HA5->HA5_LOJA)) .And. HB1->(dbSeek(RetFilial("HB1")+HA5->HA5_PRODUT))   
			        	//AADD(aProduto,{ALLTRIM(HA2->HA2_COD),ALLTRIM(HA2->HA2_NOME),ALLTRIM(HA2->HA2_LOJA),AllTrim(HB1->HB1_COD),AllTrim(HB1->HB1_DESC)})	  
					//EndIf
					If HB1->(dbSeek(RetFilial("HB1")+HA5->HA5_PRODUT))
						AADD(aProduto,{AllTrim(HA5->HA5_CODPRF),AllTrim(HA5->HA5_PRODUT),AllTrim(HB1->HB1_DESC)})	  
					EndIf
				Else
					break
				Endif
				HA5->(dbSkip())     
			Next
		EndIf
	EndIf
Else
	HB1->(dbSetOrder(nOrder))
	If nTop == 0 
		HB1->(dbSeek(RetFilial("HB1")))
		//HB1->(dbGoTop())
		If !HB1->(Eof())
			nTop := HB1->(Recno())
		EndIf
	Else
		HB1->(dbGoTo(nTop))
	EndIf
	For nI:=1 to nCargMax
	   if nI > nCargMax
	   	  break
	   Endif
	   if !HB1->(Eof()) 
		  if nOrder == 1
		  	AADD(aProduto,{AllTrim(HB1->HB1_COD),AllTrim(HB1->HB1_DESC)})
		  Elseif nOrder == 2  
		  	AADD(aProduto,{AllTrim(HB1->HB1_DESC),AllTrim(HB1->HB1_COD)})
		  Endif
	   else
		  break
	   endif
	   HB1->(dbSkip())     
	Next
EndIf	
SetArray(oBrwProd,aProduto)
Return //PD2Set(@cProduto,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2Down()           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tratamento da navegacao do List de Produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aProduto - Array de Produtos								        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2Down(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local cPesqFabr	:=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

If nOrder == 3
	If cPesqFabr == "S"	
		If Select("HA5")>0
			HA5->(dbGoTo(nTop))
			HA5->(dbSkip(GridRows(oBrwProd)))
			If !HA5->(Eof()) 
			   nTop := HA5->(Recno())
			Else
			   Return nil
			Endif
		EndIf
	EndIf
Else
	HB1->(dbGoTo(nTop))
	//HB1->(dbSkip(GetListRows(oBrwProd)))
	HB1->(dbSkip(GridRows(oBrwProd)))
	if !HB1->(Eof()) 
	   nTop := HB1->(Recno())
	else
	   return nil
	endif     
EndIf
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.F.)
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2Up()             ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tratamento da navegacao do List de Produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aProduto - Array de Produtos								        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2Up(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local cPesqFabr	:=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

If nOrder == 3
	If cPesqFabr == "S"
        If Select("HA5")>0
			HA5->(dbGoTo(nTop))
			HA5->(dbSkip(-GridRows(oBrwProd)))
			If !HA5->(Bof()) 
			   nTop := HA5->(Recno())
			Else
				HA5->(dbSeek(RetFilial("HA5")))
				nTop := HA5->(Recno())
			EndIf
		EndIf
	EndIf
Else
	HB1->(dbGoTo(nTop))
	HB1->(dbSkip(-GridRows(oBrwProd)))
	If !HB1->(Bof()) 
	   nTop := HB1->(Recno())
	Else
		HB1->(dbSeek(RetFilial("HB1")))
		//HB1->(dbGoTop())
	    nTop := HB1->(Recno())
	EndIf
EndIf
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.F.)
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2SetDet()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Preenche o folder de detalhes do produto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codgio do Produto, cDesc - Descr. do Produto	  ³±±
±±³          ³ aPrecos  - Array de Precos				         				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2SetDet(cProduto,aProduto,oBrwProd,nOrder,aDetalhe, oBrwDet)
Local nLinha:=GridRow(oBrwProd)
Local cPesqFabr	:=	""
Local cPlvLest  :=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_PLVLEST   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF") + "MV_PLVLEST")
if !eof()
	cPlvLest := AllTrim(HCF->HCF_VALOR)
else
	cPlvLest :=	"T"  
endif

If nOrder == 3
	If cPesqFabr == "S"
        If Select("HA5")>0
			HA5->(dbSetOrder(1))
			//HA5->(dbSeek(RetFilial("HA5") + aProduto[nLinha,1] +aProduto[nLinha,2]))		
			cProduto := aProduto[nLinha,2]//HA5->HA5_PRODUT
			HB1->(dbSetOrder(1))
			HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,2]))
		EndIf
	EndIf
Else
	HB1->(dbSetOrder(nOrder))
	HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,1]))
	cProduto := HB1->HB1_COD
EndIf	

HB2->(dbSetOrder(1))
HB2->(dbSeek(RetFilial("HB2") + cProduto))

aSize(aDetalhe,0)
AADD(aDetalhe,{ STR0001, HB1->HB1_GRUPO } ) //"Grupo: "
AADD(aDetalhe,{ STR0002, HB1->HB1_COD } ) //"Código: "
AADD(aDetalhe,{ STR0003, HB1->HB1_DESC } ) //"Descrição: "
AADD(aDetalhe,{ STR0004, HB1->HB1_UM } ) //"Unidade: "
AADD(aDetalhe,{ STR0005, HB1->HB1_QE } ) //"Qtd.Emb.: "
AADD(aDetalhe,{ STR0006, HB1->HB1_PE } ) //"Entr.: "
AADD(aDetalhe,{ STR0007, HB1->HB1_PICM } ) //"ICMS: "
AADD(aDetalhe,{ STR0008, HB1->HB1_IPI } ) //"IPI: "
If cPlvLest == "T"
	AADD(aDetalhe,{ STR0009, Str(HB2->HB2_QTD,5,2) + " em " + DtoC(HB2->HB2_DATA) } ) //"Estoque: "
ElseIf (HB2->HB2_QTD) > 0
	AADD(aDetalhe,{ STR0009,STR0017})  
ElseIf (HB2->HB2_QTD) <= 0
	AADD(aDetalhe,{ STR0009,STR0018})
EndIf

If ExistBlock("SFAPD002")
	aDetalhe := ExecBlock("SFAPD002", .F., .F., {aDetalhe})
EndIf

SetArray(oBrwDet,aDetalhe)
nLastProd := HB1->(Recno())

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2SetPrc()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Preenche o folder com informacoes de precos do produto.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codgio do Produto, cDesc - Descr. do Produto	  ³±±
±±³          ³ aPrecos  - Array de Precos								           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2SetPrc(cProduto,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc)
Local nLinha:=GridRow(oBrwProd)

If nOrder == 3 
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,2]))
	cProduto := HB1->HB1_COD
Else
	HB1->(dbSetOrder(nOrder))
	HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,1]))
	cProduto := HB1->HB1_COD
EndIf	
aSize(aPrecos,0)

HPR->(dbSetOrder(1))
If HPR->(dbSeek(RetFilial("HPR") + cProduto))
	While (!HPR->(Eof()) .and. HPR->HPR_PROD == cProduto)
		AADD(aPrecos,{ HPR->HPR_TAB, HPR->HPR_UNI } )
		HPR->(dbSkip())
	End
Else
	AADD(aPrecos,{"Não","Encontrado"} )
EndIf

SetArray(oBrwPrc,aPrecos)
nLastProd := HB1->(Recno())

Return nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2Order()          ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega List de Produtos na ordem desejada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codigo do Produtos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2Order(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local oCol
GridReset(oBrwProd)
nTop:=0     
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.T.)
if nOrder == 1
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0010 WIDTH 50 //"Código"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0011 WIDTH 125 //"Descrição"
   //	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0015 WIDTH 125 //"Fornecedor"
ElseIf nOrder == 2
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0011 WIDTH 125 //"Descrição"
   	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0010 WIDTH 50 //"Código"
   //	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0015 WIDTH 125 //"Fornecedor"
ElseIf nOrder == 3
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0015 WIDTH 50  //"Cód. Fabr."
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0016 WIDTH 50  //"Còd. Prod."
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0011 WIDTH 125 //"Descrição"
Endif	

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2Find()           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Busca do Produto								                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codigo do Produto						      		  ³±±
±±³          ³ aControls - Array de Controles							        ³±±
±±³          ³ lCodigo - Busca por Codigo (T ou F) 						     ³±±
±±³          ³ aPrecos - Array de Precos								           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2Find(cProduto,nTop,cPesq,aProduto,oBrwProd, nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, aPrdPrefix)
Local cPrefixo := ""
Local cPesqFabr	:=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

cPesq:=Upper(AllTrim(cPesq))

If !Empty(aPrdPrefix[1,1]) .And. nOrder = 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf
If nOrder == 3
	If cPesqFabr == "S"
        If Select("HA5")>0
			HA5->(dbSetOrder(1))
			If HA5->(dbSeek(RetFilial("HA5") + cPesq))
				nTop:=HA5->(Recno())
				PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.F.)
			Else	   
			   MsgStop(STR0012,STR0013) //"Produto não localizado!"###"Código do Produto"
			EndIf
		EndIf
	EndIf
Else
	HB1->(dbSetOrder(nOrder))
	if HB1->(dbSeek(RetFilial("HB1") + cPesq))
	   nTop:=HB1->(Recno())
		PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.F.)
	else
	    if nOrder == 1
	    	MsgStop(STR0012,STR0013) //"Produto não localizado!"###"Código do Produto"
		else
	    	MsgStop(STR0012,STR0014) //"Produto não localizado!"###"Descrição do Produto"
		Endif
	endif
EndIf
Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD2End()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Codigo do Produto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codigo do Produtos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD2End(lRet,cProduto,aProduto,oBrwProd,nOrder)
Local nLinha:=GridRow(oBrwProd)

If Len(aProduto) > 0
	If nOrder == 3
		HB1->(dbSetOrder(1))
		HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,2]))
		cProduto := HB1->HB1_COD
	Else
		HB1->(dbSetOrder(nOrder))
		HB1->(dbSeek(RetFilial("HB1") + aProduto[nLinha,1]))
		cProduto := HB1->HB1_COD
	EndIf
EndIf		
lRet := if ( Len(cProduto) > 0 , .T., .F.)
CloseDialog()
Return nil


