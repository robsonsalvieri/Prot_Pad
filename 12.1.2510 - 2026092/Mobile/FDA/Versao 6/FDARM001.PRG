#INCLUDE "FDARM001.ch"

/*********************************************************************************/
/* Funcao: Retorno de Produtos                                          		 */
/* Gravar o Flag de devolucao para os produtos nao vendidos no caminhao          */
/*********************************************************************************/
Function FDARM001()
Local oDlg,oBrw,oCol,oMnu,oItem,oBtn1,oBtn2
Local aItems := {}
Local cDescSB1:="", cTxtBtn:=STR0001 //"Marca "
Local lMarca:=.f. , lD1Ok:=.f.
Local lStatus:=.f.
Local nTot:=0 

//1o Grava D1 
dbSelectArea("HD1")     
dbSetOrder(1) 

DEFINE DIALOG oDlg TITLE STR0002 //"Retorno produtos"
ADD MENUBAR oMnu CAPTION STR0003 OF oDlg   //"Opções"
ADD MENUITEM oItem CAPTION STR0004 ACTION CloseDialog() OF oMnu   //"Sair"
// Carrega array com os produtos 
dbSelectArea("HB6")     
dbSetOrder(1)           
dbGotop()
While HB6->( !EOF() ) 
      If HB6->B6_QTD > 0 
	     dbSelectArea("HB1")     
	     dbSetOrder(1)
	     If HB1->(dbSeek( HB6->B6_COD) ) 
	        cDescSB1 :=  HB1->B1_DESC
	        if HB6->(!IsDirty())
	           lStatus:=if(HB6->B6_STATUS==" ",.f.,.t. )
	           AADD(aItems,{lStatus, ;
		       HB6->B6_DOC, ;
		       HB6->B6_ITEMORI, ;
		       HB6->B6_COD, ;
		       cDescSB1,    ;
		       HB6->B6_ORI, ; 
		       HB6->B6_QTD ,; 
		       HB6->B6_STATUS,; 
   		       HB6->B6_NFENTR,;
		       HB6->(RECNO()) })                      
		       nTot := nTot + HB6->B6_QTD
	        endif
	     endif   
	  Endif   
	  dbSelectArea("HB6")
	  HB6->( dbSkip() ) 
Enddo
@ 20,10 BROWSE oBrw SIZE 140,85 OF oDlg
SET BROWSE oBrw ARRAY aItems
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER ""       WIDTH 10 MARK EDITABLE
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0005  WIDTH 50  //"NF Original"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0006  WIDTH 30  //"It Original"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0007  WIDTH 50  //"Codigo"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5 HEADER STR0008  WIDTH 80  //"Descricao"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6 HEADER STR0009  WIDTH 50  //"Qtd Original"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 7 HEADER STR0010  WIDTH 50  //"Saldo"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8 HEADER STR0011  WIDTH 50  //"Status"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 9 HEADER STR0012  WIDTH 50  //"NF Entrada"

@ 110,10  SAY oSay PROMPT  "Total :" OF oDlg  //"Total:"
@ 110,40  SAY oSay PROMPT  nTot     OF oDlg  

@ 130,05  BUTTON oBtn1 CAPTION cTxtBtn+STR0013 ACTION MarcaTodos(oBrw,aItems,@lMarca,oBtn1,@cTxtBtn)SIZE 57,10 OF oDlg  // // // //"Adiciona Items" //"Todos"
@ 130,70  BUTTON oBtn2 CAPTION STR0014        ACTION GravarRet(1,aItems,oBrw) SIZE 40,10 OF oDlg  // // // //"Faz Devolucao" //"Gravar"
@ 130,115 BUTTON oBtn2 CAPTION STR0015       ACTION GravarRet(2,aItems,oBrw) SIZE 40,10 OF oDlg  // // // //"Estornar Devolucao" //"Estorna"


ACTIVATE DIALOG oDlg
Return nil

/*********************************************************************************/
/* Funcao: MarcaTodos                                                            */
/* Marcar/Desmarcar itens do Browse para Devolucao                               */
/*********************************************************************************/
Function MarcaTodos(oBrw,aItems,lMarca,oBtn1,cTxtBtn)
Local n                              
For n:=1 to Len(aItems) 
    If lMarca
	   aItems[n,1]:=.f. 
	else 
 	   aItems[n,1]:=.t.    
    endif 
Next
// Atualiza Browse 
SetArray(oBrw,aItems)
iif( !lMarca , lMarca:=.t., lMarca:=.f. ) 
// Atualiza Texto do Botao 
iif( lMarca , cTxtBtn:=STR0016 , cBtn:=STR0001 ) //"Desmarca "###"Marca "
HideControl(oBtn1)
SetText( oBtn1 , cTxtBtn )
ShowControl(oBtn1)

Return nil

/*********************************************************************************/
/* Funcao: GravarRet()                                                           */
/* Gravar retorno das Mercadorias												 */
/*********************************************************************************/
Function GravarRet(nOpc,aItems,oBrw) 
Local cEspecie := ""
Local cTipoDoc := ""
Local cFornCli := ""
Local cLojaCli := ""
Local cFormul  := ""
Local cSerie   := ""
Local n1:=0,  lD1OK:= .f.   , lNrOk:=.f.
Local nQtdItem :=0
Local nNrItens :=Len(aItems)                            
Local cProxNum:="000001"

if nNrItens=0 
   MsgAlert( STR0017 ,STR0018 )   //"Nao existem itens para estornar!"###"Atencao"
   Return 
Endif
//Inicializa conforme Parametros do FDA 
cEspecie := GetMV("MV_FDAESP" , "NFE" )
cTipoDoc := GetMV("MV_FDATDOC", "D" )
cFornCli := GetMV("MV_FDACLIP", "000001" )
cLojaCli := GetMV("MV_FDALOJP", "01" )           
cFormul  := GetMV("MV_FDAFORM", "S" )    
cSerie   := GetMV("MV_FDASERI", "RUA" )           

if nOpc==1 
    //Buca Proxima Nota
    NextNumF1(@cProxNum,cSerie)                 
	if !MsgYesOrNo(STR0019 + cProxNum,STR0020 ) //"Confirma este Nr. de nota :"###"Nota"
       NFProxF1(@cProxNum)
	endif
	if !MsgYesOrNo(STR0021 + cProxNum  ) //"Confirma realmente a devolucao desta nota : "
       lNrOk:=.f.   
	   Return       
	Else 
	   lNrOk:=.T.   
	endif
	dbSelectArea("HB6") 
	HB6->( dbGotop() )

	For n1:=1 to nNrItens
	        HB6->( dbGoto(aItems[n1,10]) ) // Usa o Recno do registro para fazer atualizacao 
	        if aItems[n1,8]== "P" .And. aItems[n1,9]<>""
	           Alert( aItems[n1,4] + STR0022 )         //" - Este produto ja foi enviado para devolucao!"
	        Else
	           //Grava a Nota para Devolver

	           if aItems[n1,1]==.T. 

	        	  GravaD1(@ld1Ok,cEspecie,cTipoDoc,cFornCli,cLojaCli,cSerie,cProxNum,@nQtdItem,n1 )   
	           endif
	        endif
	        If ld1Ok

	           if nOpc==1 .and. aItems[n1,1] 
	              HB6->B6_STATUS := "P"  // Marca "P" para devolucao                          
	              aItems[n1,8]   := "P"    
                  HB6->B6_NFENTR := cProxNum
                  HB6->B6_SERNFE := cSerie    
                  HB6->B6_DATNFE := Date() 
	              aItems[n1,9]    := cProxNum
                  HB6->( dbCommit() )
	           endif                                                                                                
	        endif
	Next
	//Grava a Nota para Devolver
    If lD1Ok 
	   GravaF1(cEspecie,cTipoDoc,cFornCli,cLojaCli,cFormul,cProxNum,cSerie,@nQtdItem)
	   MsgAlert( STR0023 ,STR0024 )  //"Registros marcados para retornar !"###"Retorno"
	endif
   else         
       //Desfaz a nota de entrada 
       FDARM002(oBrw,aItems)
       MsgAlert(  STR0025,STR0026 )  //"Registros estornados !"###"Estornar"
endif    

// Atualiza Browse 
SetArray(oBrw,aItems)

Return nil 

/*********************************************************************************/
/* Funcao: gravaD1 Retorno de Mercadorias                                        */
/* Gravar  Nota de entrada para Devolver Mercadorias                             */
/*********************************************************************************/
Function GravaD1(ld1Ok,cEspecie,cTipoDoc,cFornCli,cLojaCli,cSerie,cProxNum,nQtdItem,n)
Local cTesDev   := GetMV("MV_FDATDEV", "009" )    
Local nQtde:=0
Local nTotal:=0       

If HD1->( ! dbSeek ( cProxNum + StrZero(n,2) ) )
   HD1->( dbAppend() )
   HD1->D1_DOC    := cProxNum
   HD1->D1_SERIE  := cSerie
   HD1->D1_ITEM   := StrZero(n,2)
   HD1->D1_COD    := HB6->B6_COD
   nQtde          := HB6->B6_QTD    
   nTotal         := HB6->B6_PRCVEN * HB6->B6_QTD       
   HD1->D1_QUANT  := nQtde
   HD1->D1_ITEMORI:= HB6->B6_ITEMORI
   HD1->D1_LOTECTL:= HB6->B6_LOTECTL
   HD1->D1_DTVALID:= HB6->B6_DTVALID
   HD1->D1_VUNIT  := HB6->B6_PRCVEN
   HD1->D1_TOTAL  := nTotal
   HD1->D1_TES    := cTesDev 
   HD1->D1_TIPODOC:= "D"
   HD1->D1_NFORI  := HB6->B6_DOC
   HD1->D1_SERIORI:= HB6->B6_SERIE
   nQtdItem       := nQtdItem + 1
   nQtde          := 0
   nTotal         := 0
   HD1->( dbCommit())
   // Confirma Gravacao Do D1 para gravar o F1 
   // So grava o F1 se confirmar o D1 
   ld1Ok:=.T. 
else
   ld1Ok:=.f. 
endif

Return 

/*********************************************************************************/
/* Funcao: gravaF1 Retorno de Mercadorias                                        */
/* Gravar  Nota de entrada para Devolver Mercadorias                             */
/*********************************************************************************/
Function GravaF1(cEspecie,cTipoDoc,cFornCli,cLojaCli,cFormul,cProxNum,cSerie,nQtdItem)

//1o Grava F1 
dbSelectArea("HF1") 
dbSetOrder(1)

If HF1->( ! dbSeek ( cProxNum + cSerie ) )
   
   HF1->( dbAppend() )       
   HF1->F1_TIPO    := cTipoDoc
   HF1->F1_FORMUL  := cFormul
   HF1->F1_DOC     := cProxNum
   HF1->F1_SERIE   := cSerie
   HF1->F1_EMISSAO := DATE()
   HF1->F1_FORNECE := cFornCli
   HF1->F1_LOJA    := cLojaCli
   HF1->F1_ESPECIE := cEspecie
   HF1->F1_COND    := ""
   HF1->F1_TIPODOC := cTipoDoc
   HF1->F1_QTDITE  := nQtdItem     // Nr de Itens para Importar
   HF1->F1_STATUS  := "N"
   HF1->( dbCommit())

   nQtdItem:=0
   
endif

Return 
//
// Procura Proximo Numero na base HF1
//
Function NextNumF1(cProxNum,cSerie)
Local nSeq:=1    
dbSelectarea("HF1")
HF1->( dbSetOrder(1))    
HF1->( dbGobottom() )
nSeq  := Val(HF1->F1_DOC)+1
cProxNum:=StrZero(nSeq,6)   
Return 

// Obtem novo numero da nota fiscal
//
Function NFProxF1(cProxNum,lNrOk)
Local oDlgNf,oGet,oBtnFechar

DEFINE DIALOG oDlgNf TITLE STR0027 //"Próxima NF"
@ 25,15 TO 100,150 OF oDlgNF
@ 31,38  SAY oSay PROMPT  STR0028 BOLD OF oDlgNF //"Número :"
@ 31,85  GET oGet VAR cProxNum OF oDlgNF
#IFDEF __PALM__
  @ 115,50 BUTTON oBtnFechar CAPTION BTN_BITMAP_OK SYMBOL ACTION CloseDialog() SIZE 65,17 OF oDlgNf
#ELSE 
  @ 115,50 BUTTON oBtnFechar CAPTION STR0029 ACTION  CloseDialog()  SIZE 65,17 OF oDlgNf //"OK"
#ENDIF
SetFocus(oGet)
ACTIVATE DIALOG oDlgNf              

Return 