#INCLUDE "TBICONN.CH"

#DEFINE Linha Chr(13) + Chr(10)
 
USER Function MA920AUT()
 
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local cDoc   := "77829"
Local cCliente := "" //código de cliente
Local cTes := "" // código da tes
Local cEspecie := "" //espécie do documento
Local nQtdNotas := 0 //controle do numero de notas do array
Local nContador := 0 //contador inicial 
Local lCont := .T.
Local cTrib := ""
Local nItem := 0

 
PRIVATE lMsErroAuto := .F.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "FIS" TABLES "SF2","SD2","SA1","SA2","SB1","SB2","SF4","SED","SE1"

        MsgInfo("Olá, este programa irá incluir notas fiscais manuais de saida. " + Linha + ;
        "Será necessário digitar alguns dados manualmente.", "MA920AUT")
        While lCont //controle se após inclusão será efetuado novamente

            /* Digitar códigos válidos e existentes na SA1/SF4*/
            cCliente := FWINPUTBOX("Digite o código do cliente:")
            cEspecie := FWINPUTBOX("Digite a espécie:")
            cTrib := FWINPUTBOX("Digite qual tributo será calculado? 1-ICM/IPI, 2-ISS, 3-ICM/IPI/PIS/COF:")
            //cTes := FWINPUTBOX("Digite a TES:")
            dDataBase := STOD(FWINPUTBOX("Data de emissão: formato AAAAMMDD "))
            nQtdNotas := Val(FWINPUTBOX("Digite quantas notas serão geradas com os dados acima"))


            for nContador := 1 to nQtdNotas

                if cTrib == "1"
                   cTes := retornaTESICM()
                end If

                cDoc   := Soma1(cDoc)
                //Montagem da capa do documento fiscal    
                aCabec := {}
                aadd(aCabec,{"F2_TIPO"   ,"N"})
                aadd(aCabec,{"F2_FORMUL" ,"S"})
                aadd(aCabec,{"F2_DOC"    ,cDoc})   
                aadd(aCabec,{"F2_SERIE"  ,"001"})  
                aadd(aCabec,{"F2_EMISSAO",dDataBase})  
                aadd(aCabec,{"F2_CLIENTE",cCliente})   
                aadd(aCabec,{"F2_LOJA"   ,"01"})   
                aadd(aCabec,{"F2_ESPECIE",cEspecie})   
                aadd(aCabec,{"F2_COND","001"}) 
                aadd(aCabec,{"F2_DESCONT",0})  
                aadd(aCabec,{"F2_FRETE",0})
                aadd(aCabec,{"F2_SEGURO",0})   
                aadd(aCabec,{"F2_DESPESA",0})

                     

                For nItem := 1 to 1
                    aLinha := {}      
                    aAdd(aLinha, {"D2_ITEM"  ,StrZero(nItem, 2), Nil})   
                    aadd(aLinha,{"D2_COD"  ,"ATIVO",Nil}) 
                    aadd(aLinha,{"D2_QUANT",1,Nil})
                    aadd(aLinha,{"D2_PRCVEN",1000,Nil}) 
                    aadd(aLinha,{"D2_TOTAL",1000,Nil})
                    aadd(aLinha,{"D2_TES",cTes,Nil})      
                    
                    aadd(aItens,aLinha)

                Next

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
                //| Teste de Inclusao                                            | 
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
                
                MSExecAuto ({|x,y| MATA920(aCabec,aItens)}, aCabec, aItens, 3) 
    
                If !lMsErroAuto    
                    ConOut("Incluido com sucesso! "+cDoc)      
                Else       
                    ConOut("Erro na inclusao!")
                    MostraErro() //exibir erros na tela
                EndIf  
                aCabec := nil  //zerando os arrays para não ocorrer chave duplicada
                aLinha := nil 
                aItens := nil
            Next 
            lCont := MsgYesNo("Deseja efetuar uma nova inclusão?",) //caso positivo retorna para as perguntas iniciais
        End 

ConOut("Fim  : "+Time())
 
RESET ENVIRONMENT
 
Return .T.



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

static function retornaTESICM()

Local aTES := {"501","502","504","506","507";
,"508","509","511","516","517","518","520";
,"524","526","527","528","530","532","533";
,"534","535","538","539","541","555","560" }

Local nIndice := 0
Local cRet := "" 

nIndice := Randomize(1, Len(aTES))
cRet := aTES[nIndice]

return cRet 
