//Revisão - 04-11-05 - Alcir Alves - consideração apenas de contratos com saldo não zerados
#INCLUDE "EFFVE150.CH"
//Autor.....: Alessandro Alves Ferreira
//Programa..: EFFVE150.PRW
//Data......: 25/03/05
//Descricao.: Relatório de Financiamentos Vinculados a Exportação

#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSGRAPHI.CH"

/*
Função..: EFFVE150
Autor...: Alessandro Alves Ferreira - AAF
Data....: 25/03/05
Objetivo: Relatório de Financiamentos Vinculados a Exportação
Obs.....: O arquivo EFFVE150.RPT contém o relatório em Crystal.
*/
*******************
FUNCTION EFFVE150()
*******************
Local nTot
Private cArquivo
SX3->( dbSetOrder(2) )

Private lPraca := SX3->( dbSeek("EF1_PRACA") )

Private cNomDbfC := "REFFVEC"
Private aCamposC := { {"SEQREL    ","C",08,0},;
                      {"EMPRESA   ","C",15                   ,0                    } }
//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

Private cNomDbfD := "REFFVED"
Private aCamposD := { {"SEQREL    ","C",08,0} }
        AaDD(AcAMPOSd,{"FLAG      ","C",01,0} )
        AaDD(AcAMPOSd,{"FLAGTOT   ","C",01,0} )                                
   IF lEFFTpMod
        AaDD(AcAMPOSd,{"TPMODU    ","C",AVSX3("EF1_TPMODU",3),AVSX3("EF1_TPMODU",4)} )
   ELSE
        AaDD(AcAMPOSd,{"TPMODU    ","C",01,0} )
   ENDIF
        AaDD(AcAMPOSd,{"FILIAL    ","C",AVSX3("EF1_FILIAL",3),AVSX3("EF1_FILIAL",4)} )
        AaDD(AcAMPOSd,{"FILNAME   ","C",15                   ,0                    } )
        AaDD(AcAMPOSd,{"TPFIN     ","C",AVSX3("EF1_TP_FIN",3),AVSX3("EF1_TP_FIN",4)} )
        AaDD(AcAMPOSd,{"DESCFIN   ","C",20                   ,0                    } )
        AaDD(AcAMPOSd,{"BANCO     ","C",AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4)} )
If(lPraca,AaDD(AcAMPOSd,{"PRACA     ","C",AVSX3("EF1_PRACA ",3),AVSX3("EF1_PRACA ",4)}),;
          AaDD(AcAMPOSd,{"PRACA     ","C",1                    ,0                    }) )
        AaDD(AcAMPOSd,{"DESCBAN   ","C",AVSX3("A6_NREDUZ" ,3),AVSX3("A6_NREDUZ" ,4)} )
        AaDD(AcAMPOSd,{"CONTRATO  ","C",AVSX3("EF1_CONTRA",3),AVSX3("EF1_CONTRA",4)} )
   IF lEFFTpMod
        AaDD(AcAMPOSd,{"SEQCNT    ","C",AVSX3("EF1_SEQCNT",3),AVSX3("EF1_SEQCNT",4)} )
   ENDIF
        AaDD(AcAMPOSd,{"CUSTOAA   ","N",AVSX3("EF2_TX_FIX",3),AVSX3("EF2_TX_FIX",4)} )
        AaDD(AcAMPOSd,{"DESCJUR   ","C",AVSX3("EF2_VM_JUR",3),AVSX3("EF2_VM_JUR",4)} )
        AaDD(AcAMPOSd,{"FECHA_CAMB","D",AVSX3("EF1_DT_CON",3),AVSX3("EF1_DT_CON",4)} )
        AaDD(AcAMPOSd,{"PRAZO_CAMB","D",AVSX3("EF1_DT_VIN",3),AVSX3("EF1_DT_VIN",4)} )
        AaDD(AcAMPOSd,{"PRAZO_TOT ","N",10                   ,0                    } )
        AaDD(AcAMPOSd,{"PRAZO_LIQ ","D",AVSX3("EF1_DT_VEN",3),AVSX3("EF1_DT_VEN",4)} )
        AaDD(AcAMPOSd,{"VALOR_US  ","N",AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)} )
        AaDD(AcAMPOSd,{"SALDO_US  ","N",AVSX3("EF1_SLD_PM",3),AVSX3("EF1_SLD_PM",4)} )

Private lExistBCO := EF1->(FieldPos("EF1_BAN_FI")) > 0 .and. EF1->(FieldPos("EF1_PRACA")) > 0 .and.;
                     EF2->(FieldPos("EF2_BAN_FI")) > 0 .and. EF2->(FieldPos("EF2_PRACA")) > 0 .and.;
                     EF3->(FieldPos("EF3_BAN_FI")) > 0 .and. EF3->(FieldPos("EF3_PRACA")) > 0 .and.;
                     EF4->(FieldPos("EF4_BAN_FI")) > 0 .and. EF4->(FieldPos("EF4_PRACA")) > 0
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9") //HVR
	
Private lTemRof := EF3->(FieldPos("EF3_ROF")) > 0 //HVR

Private cArqRpt   := "EFFVE150.RPT"
Private cTitRpt   := IF(lEFFTpMod, STR0020,STR0001) //"Financiamentos Vinculados a Exportação"
Private cMoeDolar := EasyGParam("MV_SIMB2",,"US$")                 
Private oProcess//,oMainWnd

//ASK 13/02/07 15:38 - Incluso no AtuSx do P9R1
//VE150AcDic()
Do While .T.
   dbSelectArea("EF1")
   Private cFiliais:= "'"
   Private aFiliais:=AvgSelectFil(.T.,"EF1")
   
   If aFiliais[1] <> "WND_CLOSE"
      aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})
      
      If !Pergunte("VE150",.T.)
         Exit
      Endif
      
      nTipImp   := mv_par01
    IF lEFFTpMod  
      cTpModu   := Alltrim(STR(mv_par02))
      IF cTpModu = "1"
         cEouI     := "I"
      ELSEIF cTpModu = "2"
         cEouI     :=  "E"
      ELSE 
         cEouI     := ""
      ENDIF     
    ENDIF
      
      If nTipImp == 1
         aArqs := {}
         aAdd(aArqs,{cNomDBFC,aCamposC,"CAB","SEQREL"})
         aAdd(aArqs,{cNomDBFD,aCamposD,"DET","SEQREL"})
         
         aRetCrw := CrwNewFile(aArqs)
         
         cSeqRel :=GetSXENum("SY0","Y0_SEQREL")
         CONFIRMSX8()
         
         CAB->( dbAppend() )
         
         CAB->SEQREL  := cSeqRel
         CAB->EMPRESA := SM0->M0_NOME
         
         Processa({|| nTot := VE150Query("REL") },STR0002)//"Pesquisando Dados..."
        
         If nTot > 0
            lRetC := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
         Else
            //Apaga os arquivos temporarios
            CrwCloseFile(aRetCrw,.T.)
            msgstop(STR0019)    //não há dados para esta consulta
         Endif

      Else
         //THTS - 12/06/2023 - Função TMSGraph e MSGRAPHIC foram descontinuadas pela TOTVS e as opções foram removidas do fonte / ADO: User Story 912046: DTRADE-9146 - Depreciação da classe TMSGraphic
         Aviso(STR0021,STR0022) //"Atenção"####"A geração de Gráfico pelo relatório 'Financiamentos Vinculados a Exportação' foi descontinuada."
      Endif
   Else
      Exit
   Endif

EndDo

Return .T.

/*
Função..: VE150Query()
Autor...: Alessandro Alves Ferreira - AAF
Data....: 25/03/05
Objetivo: Executa a Query e grava os dados para o relatório.
*/
Function VE150Query(cTipRel)
Local cDel     := If( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local cQuery
Local nTotalReg
Local cChave   := ""
Local aTotal   := {}
Local nInd          
Local cTpBanco := TcGetDB() // GCC - 05/12/2013 - Retorna o tipo de banco utilizado pelo sistema

If cTipRel == "REL"
   //         Filial           Tp. Financiam.                             Banco                           Contrato        Custo A.A.
   cCampos := "EF1.EF1_FILIAL, "+IF(lEFFTpMod, "EF1.EF1_TPMODU, ","")+"EF1.EF1_TP_FIN, "+IF(lCadFin, " EF7.EF7_DESCRI"," SX5B.X5_DESCRI")+" AS DESCFIN,"+" EF1.EF1_BAN_FI,  EF1.EF1_CONTRA, "+IF(lEFFTpMod, "EF1.EF1_SEQCNT, ","")+"EF2.EF2_TX_FIX + EF2.EF2_TX_VAR AS CUSTOAA, "
   //         Descr. do Juros Fechamento      Prazo Camb.     Prazo Liquid.   Moeda          Valor na Moeda  Valor a Vinc. R$
   cCampos += "SX5A.X5_DESCRI DESCJUR, EF1.EF1_DT_CON, EF1.EF1_DT_VIN, EF1.EF1_DT_VEN, EF1.EF1_MOEDA, EF1.EF1_VL_MOE, EF1.EF1_SLD_PM "
   cCampos += ", EF1.EF1_CAMTRA"
   
   If lPraca
      cCampos += ", EF1.EF1_PRACA "
   Endif
   
   //
   cFrom   := RetSqlName("EF1")+" EF1 , "+RetSqlName("EF2")+" EF2, "+RetSqlName("SX5")+" SX5A, "
   cFrom   += IF(lCadFin, RetSqlName("EF7")+" EF7 , ", RetSqlName("SX5")+" SX5B ") //+RetSqlName("SA6")+" SA6 "
   
   cWhere  := " EF1.EF1_FILIAL IN("+cFiliais+") AND EF1."+cDel+" AND EF2."+cDel+IF(lCadFin," AND EF7."+cDel,"")+" AND SX5A."+cDel
   cWhere  += " AND EF1.EF1_FILIAL = EF2.EF2_FILIAL AND EF2.EF2_BAN_FI = EF1.EF1_BAN_FI "+If(lPraca,"AND EF2.EF2_PRACA = EF1.EF1_PRACA","")+" AND EF2.EF2_CONTRA = EF1.EF1_CONTRA "
   cWhere  += IF(lEFFTpMod,IF(cTpModu<>"3"," AND EF1.EF1_TPMODU = '"+cEouI+"'" ,""),"")
   cWhere  += " AND SX5A.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5A.X5_TABELA ='"+AvKey("CV","X5_TABELA")+"'" 
   cWhere  += " AND SX5A.X5_CHAVE = EF2.EF2_TIPJUR "+IF(lCadFin, "AND EF7.EF7_FILIAL = '"+xFilial("EF7")+"'"," AND SX5B.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5B.X5_TABELA ='"+AvKey("CG","X5_TABELA")+"'") 
   cWhere  += " AND "+IF(lCadFin,"EF7.EF7_FINANC","SX5B.X5_CHAVE")+" = EF1.EF1_TP_FIN " // AND SA6.A6_FILIAL = '"+xFilial("SA6")+"' AND SA6.A6_COD = EF1.EF1_BAN_FI AND SA6.A6_AGENCIA = EF1.EF1_AGENFI AND SA6.A6_NUMCON = EF1.EF1_NCONFI "     
   cWhere  += " AND (EF1.EF1_SLD_PM+EF1.EF1_SLD_JM+EF1.EF1_SL2_PM+EF1.EF1_SL2_JM)>0"   //Alcir Alves - consideração apenas de contratos com saldo não zerados EF1.EF1_SLD_PM+
   IF lEFFTpMod
      cOrder  := " EF1_TPMODU, EF1_FILIAL, EF1_TP_FIN, EF1_BAN_FI, EF1_CONTRA, EF1_SEQCNT "
   ELSE
      cOrder  := " EF1_FILIAL, EF1_TP_FIN, EF1_BAN_FI, EF1_CONTRA "
   ENDIF      

   cQuery  := " SELECT DISTINCT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere
   
   cQuery2 := ChangeQuery( cQuery+" ORDER BY "+cOrder )
   
   If Select("TRB") > 0
      TRB->( dbCloseArea() )
   Endif
   
   TcQuery cQuery2 ALIAS "TRB" NEW
   TcSetField("TRB","EF1_DT_CON","D")
   TcSetField("TRB","EF1_DT_VIN","D")
   TcSetField("TRB","EF1_DT_VEN","D")
   
   If Select("TOTALREG") > 0
      TOTALREG->( dbCloseArea() )
   Endif
   
   // GCC - 05/12/2013 - Tratamento na query para quando o banco utilizado for Informx, para retornar o total de registros
   If cTpBanco == "INFORMIX"  
      cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") AS TEMP")
   Else
      cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP") 
   EndIf
      
   TcQuery cQuery ALIAS "TOTALREG" NEW
  
   nTotalReg:= TOTALREG->TOTAL
   
   TOTALREG->( dbCloseArea() )
   
   lFlag:= .T.
   ProcRegua(nTotalReg)
   
   Do While !TRB->( EoF() )     
      SA6->(DbSetOrder(1))      
      IncProc("Buscando " +TRB->EF1_CONTRA)
      DET->( dbAppend() )
      
      DET->SEQREL     := cSeqRel
      DET->FLAGTOT    := "N"
      DET->FILIAL     := TRB->EF1_FILIAL
      IF lEFFTpMod
         DET->TPMODU     := TRB->EF1_TPMODU
      ELSE
         DET->TPMODU     := "E"
      ENDIF
      DET->FILNAME    := AvgFilName({TRB->EF1_FILIAL})[1]
      DET->TPFIN      := TRB->EF1_TP_FIN   
      //SX5->(DBSEEK(xFilial("SX5")+"CG"+TRB->EF1_TP_FIN) )
      DET->DESCFIN    := TRB->DESCFIN //IF(lEFFTpMod, TRB->DESCFIN, SX5->X5_DESCRI)  // PLB 07/07/06
      DET->BANCO      := TRB->EF1_BAN_FI
      DET->DESCBAN    := Posicione("SA6",1,XFILIAL("SA6")+TRB->EF1_BAN_FI,"A6_NREDUZ")
      DET->CONTRATO   := TRB->EF1_CONTRA
      IF lEFFTpMod   
         DET->SEQCNT     := TRB->EF1_SEQCNT
      ENDIF
      DET->CUSTOAA    := TRB->CUSTOAA
      DET->DESCJUR    := TRB->DESCJUR
      
      If lPraca
         DET->PRACA   := TRB->EF1_PRACA
      Endif
      
      nParidade := If(TRB->EF1_MOEDA <> "R$ ",BuscaTaxa(TRB->EF1_MOEDA,dDataBase,,.F.,.T.),1) / If(BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.) > 0,BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.),1)
      lFlag:= !lFlag
      
      If IF(lEFFTpMod, TRB->EF1_TPMODU,"")+TRB->EF1_FILIAL+TRB->EF1_BAN_FI+If(lPraca,TRB->EF1_PRACA,"")+TRB->EF1_CONTRA+IF(lEFFTpMod,TRB->EF1_SEQCNT,"") <> cChave
         DET->FECHA_CAMB := TRB->EF1_DT_CON
         DET->PRAZO_CAMB := TRB->EF1_DT_VIN
         DET->PRAZO_TOT  := TRB->EF1_DT_VEN - TRB->EF1_DT_CON
         DET->PRAZO_LIQ  := TRB->EF1_DT_VEN
         IF lEFFTpMod  .And.  TRB->EF1_TPMODU="I"
            IF TRB->EF1_CAMTRA="1"
               EF3->(DbSetOrder(1))
               IF EF3->(DbSeek(xFilial("EF3")+TRB->EF1_TPMODU+TRB->EF1_CONTRA+TRB->EF1_BAN_FI+TRB->EF1_PRACA+TRB->EF1_SEQCNT+"70"))
                  Do While !EF3->(EOF()) .And. EF3->EF3_FILIAL = TRB->EF1_FILIAL .And. EF3->EF3_TPMODU = TRB->EF1_TPMODU .And. EF3->EF3_CONTRA = TRB->EF1_CONTRA .And. EF3->EF3_SEQCNT = TRB->EF1_SEQCNT .And. Left(EF3->EF3_CODEVE,2)="70" .And. EF3->EF3_TX_MOE <> 0
                     DET->SALDO_US   += EF3->EF3_VL_MOE * nParidade
                     EF3->(DbSkip())
                  Enddo
                  DET->VALOR_US   += TRB->EF1_VL_MOE * nParidade
               ELSE
                  DET->VALOR_US   := TRB->EF1_VL_MOE * nParidade
                  DET->SALDO_US   := 0
               ENDIF
            ELSE
               DET->VALOR_US   := TRB->EF1_VL_MOE * nParidade
               DET->SALDO_US   := TRB->EF1_SLD_PM * nParidade
            ENDIF
         ELSE
            DET->VALOR_US  := TRB->EF1_VL_MOE * nParidade
            DET->SALDO_US  := TRB->EF1_SLD_PM * nParidade
         ENDIF
      Else
         lFlag:= !lFlag
         DET->VALOR_US   := TRB->EF1_VL_MOE * nParidade
         DET->SALDO_US   := TRB->EF1_SLD_PM * nParidade
      Endif
      
      IF lEFFTpMod
         nPos= aScan(aTotal,{|X| X[1] == TRB->EF1_TPMODU .And. X[2] == TRB->DESCFIN})
      ELSE
         nPos= aScan(aTotal,{|X| X[1] == DET->DESCFIN})
      ENDIF
      If nPos > 0
         IF lEFFTpMod
            IF aTotal[nPos][1]<>"I"
               aTotal[nPos][3] += DET->VALOR_US
               aTotal[nPos][4] += DET->SALDO_US
            ELSE
               aTotal[nPos][5] += DET->VALOR_US
               aTotal[nPos][6] += DET->SALDO_US
            ENDIF
         ELSE
               aTotal[nPos][2] += DET->VALOR_US
               aTotal[nPos][3] += DET->SALDO_US
         ENDIF
      Else
         IF lEFFTpMod
            aAdd(aTotal,{TRB->EF1_TPMODU, DET->DESCFIN, DET->VALOR_US, DET->SALDO_US, DET->VALOR_US, DET->SALDO_US})
         ELSE
            aAdd(aTotal,{DET->DESCFIN, DET->VALOR_US, DET->SALDO_US, DET->VALOR_US, DET->SALDO_US})
         ENDIF
      Endif
      
      DET->FLAG := if(lFlag,"1","0")
      
      cChave := IF(lEFFTpMod, TRB->EF1_TPMODU,"")+TRB->EF1_FILIAL+TRB->EF1_BAN_FI+If(lPraca,TRB->EF1_PRACA,"")+TRB->EF1_CONTRA+IF(lEFFTpMod,TRB->EF1_SEQCNT,"")
      TRB->( dbSkip() )
   EndDo
   
   For nInd := 1 To Len(aTotal)
      DET->( dbAppend() )
      
      DET->SEQREL   := cSeqRel
      DET->FLAGTOT  := "S"
      DET->DESCFIN  := IF(lEFFTpMod, aTotal[nInd][2],  aTotal[nInd][1])
      IF lEFFTpMod
         DET->TPMODU   := aTotal[nInd][1]
      Else
         DET->TPMODU   := "E"
      ENDIF
      If lEFFTpMod
         If aTotal[nInd, 1]<>"I"
            DET->VALOR_US  := aTotal[nInd][3]
            DET->SALDO_US  := aTotal[nInd][4]
         ELSE
            DET->VALOR_US := aTotal[nInd][5]
            DET->SALDO_US := aTotal[nInd][6]
         ENDIF
      Else
         DET->VALOR_US  := aTotal[nInd][2]
         DET->SALDO_US  := aTotal[nInd][3]
      EndIf
   Next
   
   TRB->( dbCloseArea() )
Else
   //         Tp. Financiam.                              Moeda          Valor
   cCampos := "EF1.EF1_TP_FIN, "+IF(lCadFin, " EF7.EF7_DESCRI"," SX5.X5_DESCRI")+" AS DESCFIN,"+" EF1.EF1_MOEDA, EF1.EF1_VL_MOE "
   
   cFrom   := RetSqlName("EF1")+" EF1 , "+IF(lCadFin, RetSqlName("EF7")+" EF7 ", RetSqlName("SX5")+" SX5 ")
   
   cWhere  := " EF1.EF1_FILIAL IN("+cFiliais+") "+IF(lCadFin," AND EF7."+cDel+" "," AND SX5."+cDel)+" AND EF1."+cDel
   IF lCadFin
      cWhere  += " AND EF7.EF7_FILIAL = '"+xFilial("EF7")+"'"
      cWhere  += " AND EF7.EF7_FINANC = EF1.EF1_TP_FIN "
   ELSE
      cWhere  += " AND SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = 'CG' "
      cWhere  += " AND SX5.X5_CHAVE  = EF1.EF1_TP_FIN "
   ENDIF
   
   IF lEFFTpMod
      cOrder  := " EF1_TPMODU,  EF1_TP_FIN, EF1_MOEDA "
   ELSE
      cOrder  := " EF1_TP_FIN, EF1_MOEDA "
   ENDIF
      
   cQuery  := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere
   
   cQuery  := ChangeQuery( cQuery+" ORDER BY "+cOrder )
   
   If Select("TRB") > 0
      TRB->( dbCloseArea() )
   Endif
   
   TcQuery cQuery ALIAS "TRB" NEW
Endif

Return nTotalReg
