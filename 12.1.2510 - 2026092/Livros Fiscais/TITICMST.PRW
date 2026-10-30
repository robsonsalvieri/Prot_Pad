User Function TITICMST
    Local cOrigem := PARAMIXB[1]
    Local cTipoImp := PARAMIXB[2]
    Local lDifal := PARAMIXB[3]
    Local dData := CTOD("")
  
    //EXEMPLO 1 (cOrigem)
    If AllTrim(cOrigem)='MATA460A' //PEDIDO DE VENDAS
        MsgAlert("Entrou")
        dData := CTOD(FWINPUTBOX("Digite a Data de vencimento: formato DD/MM/AAAA"))
        SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
        SE2->E2_VENCTO := DataValida(dData,.T.)
        SE2->E2_VENCREA := DataValida(dData,.T.)
        SE2->E2_NATUREZ := 'IND001'
    EndIf

    //EXEMPLO 2 (cTipoImp)
   /* If AllTrim(cTipoImp)='1' // ICMS ST
        SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
        SE2->E2_VENCTO := DataValida(dData,.T.)
        SE2->E2_VENCREA := DataValida(dData,.T.)
        SE2->E2_NATUREZ := 'IND001'
    EndIf
  
    //EXEMPLO 3 (lDifal)
    If lDifal // DIFAL
        SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
        SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
        SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
        SE2->E2_NATUREZ := 'EXEMPLO3'
    EndIf*/
  
Return {SE2->E2_NUM,SE2->E2_VENCTO}
