/*============================================================* 
Classe    : EDCSA151
Parametro : -
Retorno   : -
Objetivo  : Imprimir Relatório de Saldos (Drawback Integrado)
By        : Allan Oliveira Monteiro
Data      : 08/03/2012
Revisão   :
Obs       : -
*=============================================================*/

*------------------*
Function EDCSA151()
*------------------*
Local oEDCSA151
Local lRet := .T. 
Local lShowMsg := .T. //Mostra Mensagem de erro
Local oReport 

Begin Sequence

   IF !AVFLAGS("SEQMI")
      lRet := .F.
      MsgInfo("Ambiente não possui atualização de Mercado Interno (Drawback Integrado) para a geração do relatório.","Aviso")  
      Break
   ENDIF
   Pergunte("EDCSA1", .F.)
   oEDCSA151:= EasyTReport():New("EDCSA151",lShowMsg)
   lRet := !oEDCSA151:lError
   
   If lRet
      oReport := oEDCSA151:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCSA151:PrintReport()
   EndIf 

End Sequence

Return lRet


*-------------------------*
Function EDCSAFORM(cCampo,nValor)
*-------------------------*
Local xConteudo
Local oRefObj 
Local aOrd := SaveOrd("ED4")

Begin Sequence

Do Case

   Case cCampo == "VALCOBUS$"
      
      If Select("EEC") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf
   
   	  If EEC->EEC_COBCAM == "1"
         //xConteudo := Transf(EE9->EE9_VL_AC, AVSX3("EE9_VL_AC",6))
         xConteudo := EE9->EE9_VL_AC
      Else
         //xConteudo := Transf(0, AVSX3("EE9_VL_AC",6)) 
         xConteudo := 0
      EndIf
      
   Case cCampo == "VALSEMCOB"
   
      If Select("EEC") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf
   	  
      If EE9->(FieldPos("EE9_VLSCOB")) > 0
         If EEC->EEC_COBCAM == "1"
            //xConteudo := Transf(EE9->EE9_VLSCOB, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VLSCOB
         Else
            //xConteudo := Transf(EE9->EE9_VL_AC+EE9->EE9_VLSCOB, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VL_AC+EE9->EE9_VLSCOB
         EndIf
      Else
   	     If EEC->EEC_COBCAM == "1"
   	        //xConteudo := Transf(0, AVSX3("EE9_VL_AC",6))
   	        xConteudo := 0
         Else
            //xConteudo := Transf(EE9->EE9_VL_AC, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VL_AC
         EndIf
	  EndIf
	  
   Case cCampo == "QTDNCM"
   
      If Select("ED3") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf 

      xConteudo := EasyConvQt(EE9->EE9_COD_I,{{ED3->ED3_UMPROD,EE9->EE9_QT_AC}},ED3->ED3_UMNCM,.F.,@oRefObj)
      
      If Valtype(xConteudo) <> "N"
         xConteudo := 0
      EndIf
      
   Case cCampo == "TIPOAC"
   
      If Select("ED0") == 0 
         xConteudo := ""
         Break
      EndIf  
   
      Do Case
         Case ED0->ED0_TIPOAC == "01"
            xConteudo := "Comum"
         Case ED0->ED0_TIPOAC == "02"
            xConteudo := "Intermediário"
         Case ED0->ED0_TIPOAC == "03"
            xConteudo := "Solidário"
         Case ED0->ED0_TIPOAC == "04"
            xConteudo := "Embarcação"
         Case ED0->ED0_TIPOAC == "05"
            xConteudo := "Fornecimento no Mercado Interno "
         Case ED0->ED0_TIPOAC == "06"
            xConteudo := "Genérico"
         Case ED0->ED0_TIPOAC == "08"
            xConteudo := "Genérico/Embarcação"
         OtherWise
            xConteudo := "Genérico/Fornec. Mercado Interno"
      EndCase
      
   Case cCampo == "DIASREST"
       
      If Select("ED4") == 0 .And. Select("ED0") == 0
         xConteudo := ""
         Break
      EndIf 
      
      ED4->(dbSetOrder(2))
      If ED4->(DbSeek(xFilial("ED4") + ED0->ED0_AC))
         xConteudo := If(!Empty(ED4->ED4_DT_VAL), Str((ED4->ED4_DT_VAL - dDataBase),5),"00")
      Else
         xConteudo := ""
      EndIf
      
      RestOrd(aOrd)   

   Case cCampo == "SALDOQTD"
      xConteudo := ED3->ED3_SALDO + getSaldo()   
   
   Case cCampo == "SALDOQTDNCM"
      xConteudo := EasyConvQt(EE9->EE9_COD_I,{{ED3->ED3_UMPROD,nValor}},ED3->ED3_UMNCM,.F.,@oRefObj)

End Case

End Sequence


Return xConteudo


/*
Funcao                  : getSaldo
Retorno                 : Retorna o total de qtde de processos sem data de averbação da DUE
Objetivos               : Calcular o total de qtde do ato de processos sem data de averação da DUE
Autor       			   : Maurício Frison
Data/Hora   			   : novembro/2022
*/
Static Function getSaldo()
Local cQuery := ''
Local cAliasTemp 
Local oQryYs
Local nTotal := 0
//Pega a soma dos atos que não tenha data de averbação na EE9(itens do embarque exportação)
cQuery += 'SELECT SUM(EE9_QT_AC) EE9_QT_AC FROM ' + RetSqlName("EE9") + ' EE9 '
cQuery += ' LEFT JOIN ' + RetSqlName("ED3") + ' ED3 ON EE9.EE9_ATOCON = ED3.ED3_AC AND EE9.EE9_POSIPI = ED3.ED3_NCM AND EE9.EE9_SEQED3 = ED3.ED3_SEQSIS'
cQuery += ' LEFT JOIN ' + RetSqlName("EEC") + ' EEC ON EE9.EE9_PREEMB = EEC.EEC_PREEMB'
cQuery += ' WHERE EEC.EEC_DUEAVR = ? AND EEC.EEC_FILIAL = ? AND EEC.D_E_L_E_T_= ? AND '
cQuery += '       EE9.D_E_L_E_T_= ? AND EE9.EE9_FILIAL = ? AND '
cQuery += '       ED3.D_E_L_E_T_= ? AND ED3.ED3_FILIAL = ?  AND ED3.ED3_AC = ? AND ED3.ED3_SEQSIS = ?'
oQryYs := FWPreparedStatement():New(cQuery)

oQryYs:SetString(1,' ')
oQryYs:SetString(2,xFilial('EEC'))
oQryYs:SetString(3,' ')
oQryYs:SetString(4,' ')
oQryYs:SetString(5,xFilial('EE9'))
oQryYs:SetString(6,' ')
oQryYs:SetString(7,xFilial('ED3'))
oQryYs:SetString(8,ED3->ED3_AC)
oQryYs:SetString(9,ED3->ED3_SEQSIS)

cQuery := oQryYs:GetFixQuery()
cAliasTemp := MPSysOpenQuery(cQuery)
nTotal := (cAliasTemp)->EE9_QT_AC 
(cAliasTemp)->(DbCloseArea())

//Pega a soma dos atos que não tenha data de averbação na ED9(R.E./Due Externa)
cQuery := 'SELECT SUM(ED9_QT_AC) ED9_QT_AC FROM ' + RetSqlName("ED9") + ' ED9  LEFT JOIN ' + RetSqlName("ED3") + ' ED3 ON ED9.ED9_AC = ED3.ED3_AC AND ED9.ED9_NCM = ED3.ED3_NCM AND ED9.ED9_SEQSIS = ED3.ED3_SEQSIS '
cQuery += ' WHERE ED9.ED9_DTAVRB = ? AND ED9.ED9_AC = ? AND ED9.ED9_SEQSIS = ? AND ED9.D_E_L_E_T_ = ? AND ED9.ED9_FILIAL = ? AND '                  
cQuery += '                                                                        ED3.D_E_L_E_T_ = ? AND ED3.ED3_FILIAL = ?'
oQryYs := FWPreparedStatement():New(cQuery)
oQryYs:SetString(1,' ')
oQryYs:SetString(2,ED3->ED3_AC)
oQryYs:SetString(3,ED3->ED3_SEQSIS)
oQryYs:SetString(4,' ')
oQryYs:SetString(5,xFilial('ED9'))
oQryYs:SetString(6,' ')
oQryYs:SetString(7,xFilial('ED3'))
cQuery := oQryYs:GetFixQuery()
cAliasTemp := MPSysOpenQuery(cQuery)
nTotal += (cAliasTemp)->ED9_QT_AC 

(cAliasTemp)->(DbCloseArea())
oQryYs:Destroy()
return nTotal

