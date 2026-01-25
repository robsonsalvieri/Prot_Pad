#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
      aDocCarga[n] = "GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC"
*/

/*/{Protheus.doc} GFEC040A
(long_description)
       
@author alexandre.cuchi
@since 12/12/2013
@version 1.0

@param adocCarga, array

@example

/*/


Function GFEC040A(aDocCarga)
      Local        nPos
      Local nCount
      Private aDocCargaV    := {}
      Private aTotal          := {}
      
      
      dbSelectArea("GW1")
      dbSelectArea("GW8")
      
      Default aDocCarga       := { GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC }
      
      aDocCargaV    := aDocCarga
      
      If Type("aDocCargaV") == "A" .And. Len(aDocCargaV) > 0
            
            For nCount := 1 To Len(aDocCargaV)
                  
                  SomaGW8(aDocCargaV[nCount])
                  
            Next nCount
            
      Else
            SomaGW8(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
      EndIf
      
      If Len(aTotal) == 0
            Return .F.
      EndIf
      
      FWExecView("Totais por Classificação de Frete",'GFEC040A', , ,{||.T.}) 
Return

Static Function SomaGW8(cChaveGW1)
      Local aAreaGW1 := GW1->( GetArea() )
      Local aAreaGW8 := GW8->( GetArea() )
      
      GW1->( dbSetOrder(1) )
      GW8->( dbSetOrder(1) )
      
      If !GW1->( dbSeek(cChaveGW1) )
            Return
      End If
      
      If GW8->( dbSeek(cChaveGW1) )
      
            While !GW8->(Eof())     .And. GW1->GW1_FILIAL == GW8->GW8_FILIAL .And. GW1->GW1_CDTPDC == GW8->GW8_CDTPDC;
                                 .And. GW1->GW1_EMISDC == GW8->GW8_EMISDC .And. GW1->GW1_SERDC == GW8->GW8_SERDC;
                                 .And. GW1->GW1_NRDC == GW8->GW8_NRDC
                  
                  nPos := aScan(aTotal, {|x| x[1] == GW8->GW8_CDCLFR })
      
               If nPos > 0
                        aTotal[nPos, 3] += GW8->GW8_QTDE
                        aTotal[nPos, 4] += GW8->GW8_VALOR
                        aTotal[nPos, 5] += GW8->GW8_VOLUME
                        aTotal[nPos, 6] += GW8->GW8_PESOR
                        aTotal[nPos, 7] += GW8->GW8_PESOC
                        aTotal[nPos, 8] += GW8->GW8_QTDALT
                  Else
                        aAdd(aTotal,      {GW8->GW8_CDCLFR                                              ,;
                                               POSICIONE("GUB",1,XFILIAL("GUB")+GW8->GW8_CDCLFR,"GUB_DSCLFR"),;
                                              GW8->GW8_QTDE                                                 ,; 
                                               GW8->GW8_VALOR                                                ,; 
                                               GW8->GW8_VOLUME                                               ,; 
                                               GW8->GW8_PESOR                                                ,;
                                              GW8->GW8_PESOC                                                ,; 
                                               GW8->GW8_QTDALT})
                             
                  EndIf
                  
                  GW8->( dbSkip() )
                  
            EndDo
            
      EndIf
            
      RestArea(aAreaGW1)
      RestArea(aAreaGW8)
      
Return

Static Function MenuDef()
      Local aRotina := {}
Return aRotina

Static Function ModelDef()
      Local oModel
      Local oStructTMP := FWFormModelStruct():New()
      Local oStructGW8 := GetStructGW8(1)
      
      oStructTMP:AddField("Classe de Frete"  ,'',"GW1_TPFRET"  ,'C',TamSX3('GW1_TPFRET')[1],,,,,,{|| '1'})
      
      oModel := MPFormModel():New("GFEC040A",/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
      
      oModel:AddFields("GFEC040A",Nil,oStructTMP,,,{|| })
      oModel:AddGrid("GFEC40ATPF","GFEC040A",oStructGW8,,,,,{|oModel| GFEC040AL(oModel)})
      
      oModel:SetDescription("Totais por Classificação de Frete")
      
      oModel:GetModel("GFEC040A"):SetDescription("Totais por Classificação de Frete")
      oModel:GetModel("GFEC40ATPF"):SetDescription("Totais por Classificação de Frete")
      
      oModel:SetPrimaryKey({"GW1_TPFRET"})
Return oModel

Function GFEC040AL(oModel)
      Local aRet := {}
      Local nX          
      
      aSort(aTotal,,,{|x,y| x[1] < y[1] })
      
      For nX:= 1 To Len(aTotal)
            aAdd(aRet, { nX, aTotal[nX] } )
      Next nX
                             
Return aRet

Static Function ViewDef()
      Local oView
      Local oStructTMP := FwFormViewStruct():New()
      Local oStructGW8 := GetStructGW8(2)
      Local oModel := FwLoadModel("GFEC040A")
      
      oStructTMP:AddField("GW1_TPFRET","1","Classe de Frete","GW1_TPFRET",,"N")
      
      oStructGW8:RemoveField("GW1_TPFRET")
      
      oView := FwFormView():New()
      oView:SetModel(oModel)

    oView:AddGrid("GFEC40ATPF" , oStructGW8)
    
    oView:CreateFolder("IDFOLDER") 
    oView:AddSheet("IDFOLDER","IDSHEET01","Totais dos Itens por Classificação")
    
    oView:CreateHorizontalBox("MASTER",100,,,"IDFOLDER","IDSHEET01")
    
    oView:SetOwnerView("GFEC40ATPF","MASTER")
Return oView



Static Function GetStructGW8(nType)
      Local oStruct
      Local aCampos := {}
      Local nCount
      
      Default nType = 1
      
      If nType == 1
            oStruct := FWFormModelStruct():New()
      Else
            oStruct := FWFormViewStruct():New()
      EndIf
      
      aCampos := {;
                  {'GW8_CDCLFR' ,'Clas Frete'   ,'C',PESQPICT('GW8' , 'GW8_CDCLFR')},;
                  {'GW8_DSCLFR' ,'Desc Clas'    ,'C',PESQPICT('GW8' , 'GW8_DSCLFR')},;
                  {'GW8_QTDE'   ,'Quantidade'   ,'N',PESQPICT('GW8' , 'GW8_QTDE'  )},;
                  {'GW8_VALOR'  ,'Valor'        ,'N','@R 999,999,999.99'}          ,;
                  {'GW8_VOLUME' ,'Volume(m3)'   ,'N','@R 999,999,999.99999'}       ,;
                  {'GW8_PESOR'  ,'Peso Real'    ,'N','@R 999,999,999.99999'}       ,;
            	    {'GW8_PESOC'  ,'Peso Cubado'  ,'N','@R 999,999,999.99999'}       ,;
                  {'GW8_QTDALT' ,'Qtd/Peso Alt' ,'N','@R 999,999,999.99999'}} 
/* NumCampo       1                            2                 3               
      /*{'GW1_TPFRET'   ,'Tp Frete'                  ,'C',TamSX3('GW1_TPFRET')[1]},;*/
      //
      For nCount := 1 To Len(aCampos)
            If nType == 1
                  // Model
                  oStruct:AddField(aCampos[nCount][2], '', aCampos[nCount][1], aCampos[nCount][3], TamSX3(aCampos[nCount][1])[1],TamSX3(aCampos[nCount][1])[2],,,,)
            Else
                  // View
                  oStruct:AddField(aCampos[nCount][1],StrZero(nCount,2), aCampos[nCount][2], '', ,aCampos[nCount][3],PESQPICT(substr(aCampos[nCount][1],1,3), aCampos[nCount][1]),,,.t. )
            EndIf       
      Next nCount
      
Return oStruct
