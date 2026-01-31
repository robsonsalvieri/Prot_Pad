#Include "FISR240.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR240

Relatorio de conferencia da ADRC-ST - ARQUIVO DIGITAL DA RECUPERAÇÃO, DO RESSARCIMENTO E DA COMPLEMENTAÇÃO
DO ICMS ST, do Estado do Paraná.
O método de apuração é determinado pelo Decreto nº 3.886 de 21/01/2020 e pela Norma de Procedimento 
Fiscal nº 003/2020, publicado em 28/01/2020.

@return	Nil

@author Ulisses P. Oliveira
@since 08/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISR240()
Local oReport
Local cAnoMes := ""
		
If TRepInUse()

	If Pergunte("FISR240",.T.)
        cAnoMes  := SubStr(mv_par01,3,4) + SubStr(mv_par01,1,2)
        
		oReport := ReportDef(cAnoMes, mv_par02, mv_par03, mv_par04)
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0001)   //---"Rotina disponível apenas em TReport (Relatório Personalizável)."---//
Endif

Return    

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Ulisses P. Oliveira
@since 08/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ReportDef(cAnoMes, cProdDe, cProdAte, nTipo)
Local oReport
Local oSection
Local cQuery   := GetNextAlias()
Local cTitRel  := STR0002   //---"Relatório de Conferência - ADRC-ST"---//
Local oBreak1  := Nil
Local oBreak2  := Nil
Local oBreak3  := Nil
Local oBreak4  := Nil
Local oTot1    := Nil
Local oTot2    := Nil
Local oTot3    := Nil
Local oTot4    := Nil
Local oTot5    := Nil
Local oTot6    := Nil
Local oTot7    := Nil
Local oTot8    := Nil
Local oTot9    := Nil
Local oTot10   := Nil
Local oTot11   := Nil
Local oTot12   := Nil
Local oTot13   := Nil
Local oTot14   := Nil
Local oTot15   := Nil
Local oTot16   := Nil
Local oTot17   := Nil
Local oTot18   := Nil
Local oTot19   := Nil
Local oTot20   := Nil
Local oTot21   := Nil
Local oTot22   := Nil
Local oTot23   := Nil
Local oTot24   := Nil
Local oTot25   := Nil
Local oTot26   := Nil
Local oTot27   := Nil

oReport := TReport():New("FISR240",cTitRel,"FISR240",{|oReport| ReportPrint(oReport, oSection, cQuery, cAnoMes, cProdDe, cProdAte, nTipo)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:SetLandScape(.T.)

If nTipo == 1
    oSection := TRSection():New(oReport,cTitRel,{cQuery,"F1Z","SB1"})
ElseIf nTipo == 2
    oSection := TRSection():New(oReport,cTitRel,{cQuery,"F1M","SA1","SA2","SB1"})
EndIf

oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

If nTipo == 1
    TRCell():New(oSection,"F1L_ANOMES"	,cQuery,STR0003,"@R 99/9999"                ,TamSx3("F1L_ANOMES")[1],,) //---"Mês/Ano---//"
    TRCell():New(oSection,"F1L_PRODUT"	,cQuery,STR0004,PesqPict("F1L","F1L_PRODUT"),TamSx3("F1L_PRODUT")[1],,) //---"Produto---//"
    TRCell():New(oSection,"F1L_VMUSUP"	,cQuery,STR0025,PesqPict("F1L","F1L_VMUSUP"),TamSx3("F1L_VMUSUP")[1],,) //---"Vlr Med ICMS Sup"---//
    TRCell():New(oSection,"F1L_VMUBST"	,cQuery,STR0026,PesqPict("F1L","F1L_VMUBST"),TamSx3("F1L_VMUBST")[1],,) //---"Vlr Med BC ST"---//
    TRCell():New(oSection,"F1Z_INDSAI"	,cQuery,STR0027,PesqPict("F1Z","F1Z_INDSAI"),TamSx3("F1Z_INDSAI")[1],,) //---"Ind. Saída"---//
    TRCell():New(oSection,"F1Z_QTDSAI"	,cQuery,STR0028,PesqPict("F1Z","F1Z_QTDSAI"),TamSx3("F1Z_QTDSAI")[1],,) //---"Qtd. Saída"---//
    TRCell():New(oSection,"F1Z_VTOSAI"	,cQuery,STR0029,PesqPict("F1Z","F1Z_VTOSAI"),TamSx3("F1Z_VTOSAI")[1],,) //---"Vlr ICMS Efet."---//
    TRCell():New(oSection,"F1Z_VCONFE"	,cQuery,STR0030,PesqPict("F1Z","F1Z_VCONFE"),TamSx3("F1Z_VCONFE")[1],,) //---"Vlr Confronto"---//
    TRCell():New(oSection,"F1Z_ALIEFE"	,cQuery,STR0031,PesqPict("F1Z","F1Z_ALIEFE"),TamSx3("F1Z_ALIEFE")[1],,) //---"Aliq. Efetiva"---//
    TRCell():New(oSection,"F1Z_ALIFEC"	,cQuery,STR0032,PesqPict("F1Z","F1Z_ALIFEC"),TamSx3("F1Z_ALIFEC")[1],,) //---"Aliq. FECOP"---//
    TRCell():New(oSection,"F1Z_VLRESS"	,cQuery,STR0033,PesqPict("F1Z","F1Z_VLRESS"),TamSx3("F1Z_VLRESS")[1],,) //---"Vlr Ressarcimento"---//
    TRCell():New(oSection,"F1Z_VLCOMP"	,cQuery,STR0034,PesqPict("F1Z","F1Z_VLCOMP"),TamSx3("F1Z_VLCOMP")[1],,) //---"Vlr Complemento"---//
    TRCell():New(oSection,"F1Z_VLFRES"	,cQuery,STR0035,PesqPict("F1Z","F1Z_VLFRES"),TamSx3("F1Z_VLFRES")[1],,) //---"Vlr Ress. FECOP"---//
    TRCell():New(oSection,"F1Z_VLFCOM"	,cQuery,STR0036,PesqPict("F1Z","F1Z_VLFCOM"),TamSx3("F1Z_VLFCOM")[1],,) //---"Vlr Comp. FECOP"---//

    oBreak1 := TRBreak():New(oSection,oSection:Cell('F1L_PRODUT'),'Totais do Produto',.F.,'Produto',.F.)
    oTot1   := TRFunction():New(oSection:Cell("F1Z_VLRESS"),"TOT1","SUM",oBreak1,,,,.F.,.F.,.F.,oSection)
    oTot2   := TRFunction():New(oSection:Cell("F1Z_VLCOMP"),"TOT2","SUM",oBreak1,,,,.F.,.F.,.F.,oSection)
    oTot3   := TRFunction():New(oSection:Cell("F1Z_VLFRES"),"TOT3","SUM",oBreak1,,,,.F.,.F.,.F.,oSection)
    oTot4   := TRFunction():New(oSection:Cell("F1Z_VLFCOM"),"TOT4","SUM",oBreak1,,,,.F.,.F.,.F.,oSection)

ElseIf nTipo == 2
    TRCell():New(oSection,"F1M_ANOMES"	,cQuery,STR0003,"@R 99/9999"                   ,TamSx3("F1M_ANOMES")[1],,) //---"Mês/Ano"---//
    TRCell():New(oSection,"F1M_PRODUT"	,cQuery,STR0004,PesqPict("F1M","F1M_PRODUT")   ,TamSx3("F1M_PRODUT")[1],,) //---"Produto"---//
    TRCell():New(oSection,"F1M_DTMOV"	,cQuery,STR0005,PesqPict("F1M","F1M_DTMOV")    ,TamSx3("F1M_DTMOV")[1] ,,) //---"Data Movto"---//
    TRCell():New(oSection,"TIPOMOV"	    ,cQuery,STR0006,                               ,                       ,,) //---"Tipo Movto"---//
    TRCell():New(oSection,"F1M_NFISCA"	,cQuery,STR0007,PesqPict("F1M","F1M_NFISCA")   ,TamSx3("F1M_NFISCA")[1],,) //---"Documento"---//
    TRCell():New(oSection,"F1M_SERIE"	,cQuery,STR0008,PesqPict("F1M","F1M_SERIE")    ,TamSx3("F1M_SERIE")[1] ,,) //---"Série"---//
    TRCell():New(oSection,"F1M_ITEM "	,cQuery,STR0009,PesqPict("F1M","F1M_ITEM")     ,TamSx3("F1M_ITEM")[1]  ,,) //---"Item"---//
    TRCell():New(oSection,"F1M_PARTIC"	,cQuery,STR0010,PesqPict("F1M","F1M_PARTIC")   ,TamSx3("F1M_PARTIC")[1],,) //---"Participante"---//
    TRCell():New(oSection,"F1M_LOJA"	,cQuery,STR0011,PesqPict("F1M","F1M_LOJA")     ,TamSx3("F1M_LOJA")[1]  ,,) //---"Loja"---//
    TRCell():New(oSection,"F1M_QTDCON"	,cQuery,STR0012,PesqPict("F1M","F1M_QTDCON")   ,TamSx3("F1M_QTDCON")[1],,) //---"Qtde"---//
    TRCell():New(oSection,"F1M_VLRCON"	,cQuery,STR0013,PesqPict("F1M","F1M_VLRCON")   ,TamSx3("F1M_VLRCON")[1],,) //---"Vlr Contabil"---//
    TRCell():New(oSection,"F1M_VLRICM"	,cQuery,STR0014,PesqPict("F1M","F1M_VLRICM")   ,TamSx3("F1M_VLRICM")[1],,) //---"Vlr ICMS"---//
    TRCell():New(oSection,"F1M_BASIST"	,cQuery,STR0015,PesqPict("F1M","F1M_BASIST")   ,TamSx3("F1M_BASIST")[1],,) //---"Base ICMS ST"---//
    TRCell():New(oSection,"F1M_VLRIST"	,cQuery,STR0016,PesqPict("F1M","F1M_VLRIST")   ,TamSx3("F1M_VLRIST")[1],,) //---"Vlr ICMS ST"---//
    TRCell():New(oSection,"F1M_INDSAI"	,cQuery,STR0017,PesqPict("F1M","F1M_INDSAI")   ,TamSx3("F1M_INDSAI")[1],,) //---"Ind. Saída"---//
    TRCell():New(oSection,"F1M_VLREFE"	,cQuery,STR0018,PesqPict("F1M","F1M_VLREFE")   ,TamSx3("F1M_VLREFE")[1],,) //---"Vlr ICMS Efetivo"---//
    TRCell():New(oSection,"F1M_CODRES"	,cQuery,STR0019,PesqPict("F1M","F1M_CODRES")   ,TamSx3("F1M_CODRES")[1],,) //---"Resp Ret ST Entr"---//
    TRCell():New(oSection,"F1M_VLRSUP"	,cQuery,STR0020,PesqPict("F1M","F1M_VLRSUP")   ,TamSx3("F1M_VLRSUP")[1],,) //---"Vlr ICMS Suport."---//

    oBreak1 := TRBreak():New(oSection,oSection:Cell('F1M_PRODUT'),'Totais do Produto - Entradas'                                                                      ,.F.,'Produto',.F.)
    oTot1   := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT1","ONPRINT" ,oBreak1,"",,{||oSection:GetFunction("TOT4"):GetValue() - oSection:GetFunction("TOT5"):GetValue()},.F.,.F.,.F.,oSection,{|| ((cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0') .Or. ((cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1')})
    oTot2   := TRFunction():New(oSection:Cell("F1M_BASIST"),"TOT2","ONPRINT" ,oBreak1,"",,{||oSection:GetFunction("TOT6"):GetValue() - oSection:GetFunction("TOT7"):GetValue()},.F.,.F.,.F.,oSection,{|| ((cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0') .Or. ((cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1')})
    oTot3   := TRFunction():New(oSection:Cell("F1M_VLRSUP"),"TOT3","ONPRINT" ,oBreak1,"",,{||oSection:GetFunction("TOT8"):GetValue() - oSection:GetFunction("TOT9"):GetValue()},.F.,.F.,.F.,oSection,{|| ((cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0') .Or. ((cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1')})
    oTot4   := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT4","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0'                                                                    })
    oTot5   := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT5","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1'                                                                    })
    oTot6   := TRFunction():New(oSection:Cell("F1M_BASIST"),"TOT6","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0'                                                                    })
    oTot7   := TRFunction():New(oSection:Cell("F1M_BASIST"),"TOT7","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1'                                                                    })
    oTot8   := TRFunction():New(oSection:Cell("F1M_VLRSUP"),"TOT8","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0'                                                                    })
    oTot9   := TRFunction():New(oSection:Cell("F1M_VLRSUP"),"TOT9","SUM"     ,oBreak1,"",,                                                                                     ,.F.,.F.,.F.,oSection,{||  (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1'                                                                    })

    oBreak2 := TRBreak():New(oSection,oSection:Cell('F1M_PRODUT'),'Totais do Produto - Saída Tipo 12 – Saídas internas destinadas a consumidor final'                 ,.F.,'Produto',.F.)
    oTot10  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT10","ONPRINT",oBreak2,"",,{||oSection:GetFunction("TOT12"):GetValue()-oSection:GetFunction("TOT13"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '12'}                                                                                                    )
    oTot11  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT11","ONPRINT",oBreak2,"",,{||oSection:GetFunction("TOT14"):GetValue()-oSection:GetFunction("TOT15"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '12'}                                                                                                    )
    oTot12  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT12","SUM"    ,oBreak2,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '12'}                                  )
    oTot13  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT13","SUM"    ,oBreak2,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '12'}                                  )
    oTot14  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT14","SUM"    ,oBreak2,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '12'}                                  )
    oTot15  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT15","SUM"    ,oBreak2,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '12'}                                  )

    oBreak3 := TRBreak():New(oSection,oSection:Cell('F1M_PRODUT'),'Totais do Produto - Saída Tipo 13 – Saídas interestaduais'                                         ,.F.,'Produto',.F.)
    oTot16  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT16","ONPRINT",oBreak3,"",,{||oSection:GetFunction("TOT18"):GetValue()-oSection:GetFunction("TOT19"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '13'}                                                                                                    )
    oTot17  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT17","ONPRINT",oBreak3,"",,{||oSection:GetFunction("TOT20"):GetValue()-oSection:GetFunction("TOT21"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '13'}                                                                                                    )
    oTot18  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT18","SUM"    ,oBreak3,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '13'}                                  )
    oTot19  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT19","SUM"    ,oBreak3,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '13'}                                  )
    oTot20  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT20","SUM"    ,oBreak3,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '13'}                                  )
    oTot21  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT21","SUM"    ,oBreak3,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '13'}                                  )

    oBreak4 := TRBreak():New(oSection,oSection:Cell('F1M_PRODUT'),'Totais do Produto - Saída Tipo 15 – Saídas internas destinadas a contribuintes do Simples Nacional',.F.,'Produto',.F.)
    oTot22  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT22","ONPRINT",oBreak4,"",,{||oSection:GetFunction("TOT24"):GetValue()-oSection:GetFunction("TOT25"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '15'}                                                                                                    )
    oTot23  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT23","ONPRINT",oBreak4,"",,{||oSection:GetFunction("TOT26"):GetValue()-oSection:GetFunction("TOT27"):GetValue()},.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_INDSAI == '15'}                                                                                                    )
    oTot24  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT24","SUM"    ,oBreak4,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '15'}                                  )
    oTot25  := TRFunction():New(oSection:Cell("F1M_QTDCON"),"TOT25","SUM"    ,oBreak4,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '15'}                                  )
    oTot26  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT26","SUM"    ,oBreak4,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0' .And. (cQuery)->F1M_INDSAI == '15'}                                  )
    oTot27  := TRFunction():New(oSection:Cell("F1M_VLREFE"),"TOT27","SUM"    ,oBreak4,"",,                                                                                     ,.F.,.F.,.F.,oSection,{|| (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1' .And. (cQuery)->F1M_INDSAI == '15'}                                  )

    oSection:GetFunction("TOT4"):Disable() 
    oSection:GetFunction("TOT5"):Disable() 
    oSection:GetFunction("TOT6"):Disable() 
    oSection:GetFunction("TOT7"):Disable() 
    oSection:GetFunction("TOT8"):Disable() 
    oSection:GetFunction("TOT9"):Disable() 
    oSection:GetFunction("TOT12"):Disable() 
    oSection:GetFunction("TOT13"):Disable() 
    oSection:GetFunction("TOT14"):Disable() 
    oSection:GetFunction("TOT15"):Disable() 
    oSection:GetFunction("TOT18"):Disable() 
    oSection:GetFunction("TOT19"):Disable() 
    oSection:GetFunction("TOT20"):Disable() 
    oSection:GetFunction("TOT21"):Disable() 
    oSection:GetFunction("TOT24"):Disable() 
    oSection:GetFunction("TOT25"):Disable() 
    oSection:GetFunction("TOT26"):Disable() 
    oSection:GetFunction("TOT27"):Disable() 

EndIf

Return(oReport)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Ulisses P. Oliveira
@since 08/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport, oSection, cQuery, cAnoMes, cProdDe, cProdAte, nTipo)

Local cSelect	 := ""
Local cFrom      := ""
Local cWhere     := ""
Local cOrder     := ""
Local cMesAno    := "" 

If nTipo == 1
    cSelect := "F1L_FILIAL, F1L_ANOMES, F1L_PRODUT, F1L.F1L_VMUSUP, F1L.F1L_VMUBST, "
    cSelect += "F1Z_INDSAI, F1Z_QTDSAI, F1Z_VTOSAI, F1Z_VCONFE, F1Z_ALIEFE, F1Z_ALIFEC, F1Z_VLRESS, F1Z_VLCOMP, F1Z_VLFRES, F1Z_VLFCOM "
    cFrom   := RetSqlName("F1Z") + " F1Z LEFT OUTER JOIN "+ RetSqlName("F1L") + " F1L ON (F1L.F1L_FILIAL = F1Z.F1Z_FILIAL AND F1L.F1L_ANOMES = F1Z.F1Z_ANOMES AND F1L.F1L_PRODUT = F1Z.F1Z_PRODUT AND F1L.D_E_L_E_T_ = ' ') "
    cWhere  := "F1Z.F1Z_FILIAL = '" + xFilial("F1Z") + "' AND "
    cWhere  += "F1Z.F1Z_ANOMES = '" + cAnoMes        + "' AND "
    cWhere  += "F1Z.F1Z_PRODUT BETWEEN '" + cProdDe  + "' AND '" + cProdAte + "' AND "
    cWhere  += "F1Z.D_E_L_E_T_ = ' ' "
    cOrder  := "F1Z.F1Z_PRODUT, F1Z_INDSAI"

ElseIf nTipo == 2
    cSelect := "F1M.F1M_ANOMES, F1M.F1M_PRODUT, F1M.F1M_DTMOV, F1M.F1M_TPMOV, F1M.F1M_INDOP, F1M.F1M_NFISCA, F1M.F1M_SERIE, F1M.F1M_ITEM, F1M.F1M_PARTIC, F1M.F1M_LOJA, "
    cSelect += "F1M.F1M_QTDCON, F1M.F1M_VLRCON, F1M.F1M_VLRICM, F1M.F1M_BASIST, F1M.F1M_VLRIST, F1M.F1M_INDSAI, F1M.F1M_VLREFE, F1M.F1M_CODRES, F1M.F1M_VLRSUP "
    cFrom   := RetSqlName("F1M") + " F1M "
    cWhere  := "F1M.F1M_FILIAL = '" + xFilial("F1M") + "' AND "
    cWhere  += "F1M.F1M_ANOMES = '" + cAnoMes        + "' AND "
    cWhere  += "F1M.F1M_PRODUT BETWEEN '" + cProdDe  + "' AND '" + cProdAte + "' AND "
    cWhere  += "F1M.D_E_L_E_T_ = ' ' "
    cOrder  := "F1M.F1M_ANOMES, F1M.F1M_PRODUT, F1M.F1M_ORDEM "
EndIf

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%' + cOrder  + '%'

oSection:BeginQuery()

BeginSql Alias cQuery
    SELECT %Exp:cSelect%
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
    Order by %Exp:cOrder%
EndSQL

oSection:EndQuery()

oReport:SetMeter((cQuery)->(RecCount()))

//---Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.---//
If nTipo == 1
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F1L_PRODUT)})
ElseIf nTipo == 2
    TRPosition():New(oSection,"SA1",1,{||xFilial("SA1")+(cQuery)->(F1M_PARTIC+F1M_LOJA)})
    TRPosition():New(oSection,"SA2",1,{||xFilial("SA2")+(cQuery)->(F1M_PARTIC+F1M_LOJA)})
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F1M_PRODUT)})
EndIf

oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cQuery)->(Eof())

    If nTipo == 1
        cMesAno := SubStr((cQuery)->F1L_ANOMES,5,2) + "/" + SubStr((cQuery)->F1L_ANOMES,1,4)

        oSection:Cell("F1L_ANOMES"):SetValue(cMesAno)
    Else
        cMesAno := SubStr((cQuery)->F1M_ANOMES,5,2) + "/" + SubStr((cQuery)->F1M_ANOMES,1,4)
        
        If (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0'
            cTipoMov := STR0021 //---"Entrada"---//
        ElseIf (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0'
            cTipoMov := STR0022 //---"Saída"---//
        ElseIf (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1'    
            cTipoMov := STR0023 //---"Dev. Saída"---//
        ElseIf (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1'
            cTipoMov := STR0024 //---"Dev. Entrada"---//
        EndIf

        oSection:Cell("F1M_ANOMES"):SetValue(cMesAno)
        oSection:Cell("TIPOMOV"):SetValue(cTipoMov)
    EndIf
	oReport:Section(1):PrintLine()
				
	(cQuery)->(dbSkip())
	oReport:IncMeter()
EndDo
(cQuery)->(dbCloseArea())

oReport:Section(1):Finish()

Return