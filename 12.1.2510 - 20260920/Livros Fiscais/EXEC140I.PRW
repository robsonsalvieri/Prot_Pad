#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#DEFINE Linha Chr(13) + Chr(10)
   
User Function EXEC140I()
   
Local nOpc := 3
   
    Local aCabec      := {}
    Local aItens      := {}
    Local aLinha      := {}
    Local lMsErroAuto := .F.
    Local cDoc   := ""
    Local cSerie := ""
    Local cFornec := "" //código de cliente
    Local cTes := "" // código da tes
    Local cEspecie := "" //espécie do documento
    Local nQtdNotas := 0 //controle do numero de notas do array
   // Local nQuantItens := 0 //numero de itens
    Local nContador := 0 //contador inicial 
    Local lCont := .T.
    Local nItem := 0
    Local cLoja := ""
    Local cProduto := ""
   
    PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "COM" TABLES "SF1","SD1","SA1","SA2","SB1","SB2","SF4" USER "admin" PASSWORD "1234"

     MsgInfo("Olá, este programa irá incluir documentos na pre nota. " + Linha + ;
        "Será necessário digitar alguns dados manualmente.", "EXEC140I")
        While lCont //controle se após inclusão será efetuado novamente

            /* Digitar códigos válidos e existentes na SA1/SF4*/
            cDoc := FWINPUTBOX("Digite o numero do documento:")
            cSerie := FWINPUTBOX("Digite a serie do documento:")
            cFornec := FWINPUTBOX("Digite o código do fornecedor:")
            cLoja := FWINPUTBOX("Digite a loja do fornecedor:")
            cEspecie := FWINPUTBOX("Digite a espécie do documento:")
            cProduto := FWINPUTBOX("Digite codigo do produto")
            //cTrib := FWINPUTBOX("Digite qual tributo será calculado? 1-ICM/IPI, 2-ISS, 3-ICM/IPI/PIS/COF:")
            cTes := FWINPUTBOX("Digite a TES:")
            dDataBase := STOD(FWINPUTBOX("Data de emissão: formato AAAAMMDD "))
            nQtdNotas := Val(FWINPUTBOX("Digite quantas notas serão geradas com os dados acima"))
            //nQuantItens := Val(FWINPUTBOX("Digite quantas de intens na nota fiscal serão geradas com os dados acima"))

    For nContador := 1 to nQtdNotas
        
        cDoc   := Soma1(cDoc)
   
        aAdd(aCabec,{'F1_TIPO','N',NIL})
        aAdd(aCabec,{'F1_FORMUL','N',NIL})
        aAdd(aCabec,{'F1_DOC',cDoc,NIL})
        aAdd(aCabec,{"F1_SERIE",cSerie,NIL})
        aAdd(aCabec,{"F1_EMISSAO",dDataBase,NIL})
        aAdd(aCabec,{'F1_FORNECE',cFornec,NIL})
        aAdd(aCabec,{'F1_LOJA',cLoja,NIL})
        aAdd(aCabec,{"F1_ESPECIE",cEspecie,NIL})
        aAdd(aCabec,{"F1_COND",'001',NIL})
        aAdd(aCabec,{"F1_STATUS",'',NIL})


        For nItem := 1 to 4
            aLinha := {}     
            aAdd(aItens,{'D1_ITEM',StrZero(nItem, 2),NIL}) 
            aAdd(aItens,{'D1_COD',cProduto,NIL})
            aAdd(aItens,{"D1_QUANT",1,Nil})
            aAdd(aItens,{"D1_VUNIT",1000,Nil})
            aAdd(aItens,{"D1_TOTAL",1000,Nil})
            aAdd(aItens,{"D1_TES",cTes,NIL})
        
            aAdd(aLinha,aItens)

        Next
        
        MSExecAuto({|x,y,z,a,b| MATA140(aCabec,aLinha,nOpc,a,b)}, aCabec, aLinha, nOpc,,)
        
        If lMsErroAuto
            mostraerro()
        Else
            Alert("Execauto MATA140 de inclusão executado com sucesso!")
        EndIf
            aCabec := nil  //zerando os arrays para não ocorrer chave duplicada
            aLinha := nil 
            aItens := nil
    Next 
            lCont := MsgYesNo("Deseja efetuar uma nova inclusão?",) //caso positivo retorna para as perguntas iniciais
        End 
  
    RESET ENVIRONMENT
    
Return

static function Soma1(cDoc)

cret := "0"
nDoc := 0

nDoc := Val(cDoc)
nDoc++
cRet := cValtoChar(nDoc)

return cRet


/*quebrar o execauto para selecionar fornecedores, 
produtos e TES para calculos especificos:

utilizar a função randomize:

TES de saida com ICMS e IPI XIFIS26:

"501","502","504","506","507";
,"508","509","511","516","517","518","520";
,"524","526","527","528","530","532","533";
,"534","535","538","539","541","555","560"

*/

/*static function retornaTESICM()

Local aTES := {"001","002","504","506","507";
,"508","509","511","516","517","518","520";
,"524","526","527","528","530","532","533";
,"534","535","538","539","541","555","560" }

Local nIndice := 0
Local cRet := "" 

nIndice := Randomize(1, Len(aTES))
cRet := aTES[nIndice]

return cRet */

