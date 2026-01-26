#include "eADVPL.ch"
Function TODOS()
Local cCodCliFor:="",cLoja:="", cTipoNf:="S", cEspecie   := "NF " 
Local aFdaNfCab:={}, aFdaNfItem:={}
Local aIteNot:={} 
Local cProduto:="21.21103",cTes:="501"
Local nQtdVen:=0,nPrcVen:=0, nDesconto:=0, nSeguro:=0, nFrete:=0, nDespesa:=0, nValMerc:=0
Local oMnu, oCol, oItem, oBrw, oDlg
Local nCont:=0, nOpt:=15
Local oLbx
Local oSayFile,oMeterFiles,nMeterFiles:=0

public MV_ESTADO
public MV_ICMPAD
Public MV_NORTE
Public MV_ESTICM                    
Public aCabView:={}     
Public nVez:=0

DEFINE DIALOG oDlg TITLE "Impostos" //"Impostos"
ADD MENUBAR oMnu CAPTION "Opções" OF oDlg  //"Opções"
ADD MENUITEM oItem CAPTION "Calcular" ACTION Avancar(oSayFile,oMeterFiles,nMeterFiles,oBrw,aFdaNfItem,aFdaNfCab,oLbx) OF oMnu  //"Calcular"
ADD MENUITEM oItem CAPTION "Sair"     ACTION CloseDialog() OF oMnu  //"Sair"

@ 20,2  LISTBOX oLbx VAR nOpt ITEM aCabView SIZE 145,35 OF oDlg

@ 125,20  SAY oSayFile PROMPT "" OF oDlg
@ 140,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlg
@ 145,06 SAY oSay PROMPT  "Microsiga Intelligence" OF oDlg      

//Abrindo os arquivos
OpenEmp("MatxFis") 
openFiles(oSayFile,oMeterFiles,nMeterFiles)
HideControl(oSayFile)
HideControl(oMeterFiles)

@ 65,2 BROWSE oBrw    SIZE 145,50 ON CLICK Alert("OnClick") OF oDlg

SET BROWSE oBrw ARRAY aFdaNfItem
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1  HEADER "Produto"  WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2  HEADER "Grp.Trib" WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3  HEADER "PrcVen"   WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4  HEADER "QtdVen"   WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5  HEADER "Descto"   WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6  HEADER "ValMerc"  WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 7  HEADER "Frete"    WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8  HEADER "Despesa"  WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 9  HEADER "Seguro"   WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 10 HEADER "Tes"      WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 11 HEADER "Base Icm"     WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 12 HEADER "Aliq Icm"     WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 13 HEADER "Vl imp Icm"   WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 14 HEADER "Base IPI"    WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 15 HEADER "Aliq IPI"    WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 16 HEADER "Vlimp IPI"   WIDTH 50 

ACTIVATE DIALOG oDlg

HideControl(oSayFile)
HideControl(oMeterFiles)

Return nil

Function Avancar(oSayFile,oMeterFiles,nMeterFiles,oBrw,aFdaNfItem,aFdaNfCab,oLbx,oPosit)
Local cCodCliFor,cLoja, cTipoNf:="S", cEspecie 
Local aIteNot:={} 
Local cProduto:="21.21103",cTes:="501"
Local nQtdVen:=60,nPrcVen:=6.90, nDesconto:=6.00, nSeguro:=0, nFrete:=0, nDespesa:=0, nValMerc:=414
Local nCont:=0

ASize(aCabView,0)

MsgStatus("Calculando..." )

cEspecie   := "NF " 
cCodCliFor := "000002"
cLoja      := "01"    

FdaFisIni(cCodCliFor,cLoja,cTipoNF,cEspecie,aFdaNfCab,aFdaNfItem)

//For nCont:=1 to 2 // Sera os itens da nota....    

    //1a Vez                                                
    nQtdVen:=60
    nPrcVen:=6.90
    nDesconto:=6.00
    nSeguro:=0
    nFrete:=0
    nDespesa:=0
    nValMerc:=414
    
    FdaFisAdd(cProduto,cTes, nQtdVen, nPrcVen, nDesconto, nSeguro, nFrete, nDespesa, nValMerc, aFdaNfCab, aFdaNfItem)
    
    nQtdVen:=200
	nPrcVen:=15
	nDesconto:=7.00
	nSeguro:=0
	nFrete:=0
	nDespesa:=0
	nValMerc:=3000

    //2a Vez  para o mesmo Produto 
   
    FdaFisAdd(cProduto,cTes, nQtdVen, nPrcVen, nDesconto, nSeguro, nFrete, nDespesa, nValMerc, aFdaNfCab, aFdaNfItem)

    SetArray( oBrw, aFdaNfItem )
    ShowControl(oLbx)           
    
    //Converte o array somente para Visualizar
    aCabView:=aClone(aFdaNfCab) 
    aCabView[2]:=if( aCabView[2], ".T." , ".F." ) 
    aCabView[9]:=if( aCabView[9], ".T." , ".F." ) 
    for n1:=10 to 15

           if n1==12          
              aCabView[n1]:= "NF_BASEICM | " + Str(aCabView[n1],5,3 ) 
           elseif n1==13        
              aCabView[n1]:= "NF_VALICM  | " + Str(aCabView[n1],5,3 )
           elseif n1==14        
              aCabView[n1]:= "NF_BASEIPI | " + Str(aCabView[n1],5,3 )
           elseif n1==15 
             aCabView[n1] := "NF_VALIPI  | " + Str(aCabView[n1],5,3 )             
           else 
			    aCabView[n1]:= Str(aCabView[n1],5,3 )             
           endif  
    next                        
                                        
    SetArray( oLbx, aCabView )
    
//Next                                                           

ClearStatus() 

Return                                                                                            

