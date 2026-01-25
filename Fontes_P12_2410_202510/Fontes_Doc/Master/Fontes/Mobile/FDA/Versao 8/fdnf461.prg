Function ShowImpost(aCabNot,aIteNot,oDlg,aFdaNfCab,aFdaNfItem,oBrw,oCol)
Local cCodCliFor,cLoja, cTipoNf:="S", cEspecie   := "NF " 
Local aFdNfCab:={}, aFdNfItem:={} 

cCodCliFor := aCabNot[4,1]
cLoja      := aCabNot[5,1]

FdaFisIni(cCodCliFor,cLoja,cTipoNF,cEspecie,aFdNfCab,aFdNfItem)

//AQUI
// Faz os calculos dos itens 
For nCont:=1 to len(aIteNot)
    FdaFisAdd(cProduto,cTes, nQtdVen, nPrcVen, nDesconto, nSeguro, nFrete, nDespesa, nValMerc, aFdaNfCab, aFdaNfItem)
Next 

// Mostra os impostos no Folder
NFFldTaxas(oDlg,aFdaNfCab,aFdaNfItem,oBrw,oCol)

//Montagem do Folder impostos para consulta 
Function NFFldImpost(oDlg,aFdaNfCab,aFdaNfItem,oBrw,oCol)

@ 35,5 BROWSE oBrw SIZE 145,90 OF oDlg
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
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 11 HEADER "Base"     WIDTH 50
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 12 HEADER "Aliq"     WIDTH 50 
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 13 HEADER "Vl imp"   WIDTH 50 

Return nil
