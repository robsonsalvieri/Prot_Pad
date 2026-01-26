Function Impost()
Local oBrwImp,oFldImp,oCol,oDlg 
Local acabImp:={},aFdaNfItem:={}
Local oGetT,nTotalNF:=18540.56

DEFINE DIALOG oDlg TITLE "Inclusão de NF"
ADD FOLDER oFldImp CAPTION "Impostos" OF oDlg
@ 18,2 BROWSE oBrwImp    SIZE 155,50 OF oFldImp
SET BROWSE oBrwImp ARRAY aFdaNfItem
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 1  HEADER "Produto"  WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 2  HEADER "Grp.Trib" WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 3  HEADER "PrcVen"   WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 4  HEADER "QtdVen"   WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 5  HEADER "Descto"   WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 6  HEADER "ValMerc"  WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 7  HEADER "Frete"    WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 8  HEADER "Despesa"  WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 9  HEADER "Seguro"   WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 10 HEADER "Tes"      WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 11 HEADER "Base Icm"     WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 12 HEADER "Aliq Icm"     WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 13 HEADER "Vl imp Icm"   WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 14 HEADER "Base IPI"    WIDTH 50
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 15 HEADER "Aliq IPI"    WIDTH 50 
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 16 HEADER "Vlimp IPI"   WIDTH 50 

aadd( aCabImp,{ "Base do ICMS" , 0 } )
aadd( aCabImp,{ "Valor do ICMS", 0 } )
aadd( aCabImp,{ "Base Calculo ICMS Subs.", 0 } )
aadd( aCabImp,{ "Valor do ICMS SUBST", 0 } )
aadd( aCabImp,{ "Valor do Frete", 0 } )
aadd( aCabImp,{ "Valor do Seguro", 0 } )
aadd( aCabImp,{ "Outras Desp.Acessorias", 0 } )
aadd( aCabImp,{ "Valor Total do IPI", 0 }  )

@ 70,2 BROWSE oBrwCab    SIZE 155,55 OF oFldImp
SET BROWSE oBrwCab ARRAY aCabImp
ADD COLUMN oCol TO oBrwCab ARRAY ELEMENT 1  HEADER "Descricao" WIDTH 80
ADD COLUMN oCol TO oBrwCab ARRAY ELEMENT 2  HEADER "Valor    " WIDTH 70 

@ 130,2  SAY "Total da Nota :" OF oFldImp
@ 130,65 GET oGetT VAR nTotalNF Picture "@E 9,999,999.99" READONLY SIZE 40,12 of oFldImp

ACTIVATE DIALOG oDlg 

Return Nil