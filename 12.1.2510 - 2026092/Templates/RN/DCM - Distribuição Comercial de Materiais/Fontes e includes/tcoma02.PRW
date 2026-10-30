#INCLUDE "tcoma02.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA02   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  21/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MarkBrowse com filtro de produtos para analise de estoque  บฑฑ
ฑฑบ          ณ no compras                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TCOMA02()
Local _nX
Local _aArea := GetArea()
cDelFunc     := ".T." 
cPerg        := Padr("COMA2B",Len(SX1->X1_GRUPO))

CHKTEMPLATE("DCM")  

If !Pergunte(cPerg,.T.)
	//mv_par01 = "Fornecedor         ?"
	//mv_par02 = "Produto De         ?"
	//mv_par03 = "Produto Ate        ?"
	//mv_par04 = "Situacao           ?" ("Todos";"Com Pedidos";"Sem Pedidos")
	//mv_par05 = "Movimentos De      ?"
	//mv_par06 = "Movimentos Ate     ?"
	//mv_par07 = "Aumoxarifado       ?"
	//mv_par08 = "Considera Filiais  ?" ("Sim";"Nao")
	//mv_par09 = "Vendas 3 Meses Ant.?" ("Sim";"Nao")
	//mv_par10 = "Grupos de Precos   ?"
	//mv_par11 = "Desconsidera Sit.? ?"
	//mv_par12 = "Grupos de Mkps     ?"
	Return(.T.)
Endif

Private cCadastro  :=STR0001+Alltrim(SM0->M0_CODFIL)+" / "+Alltrim(SM0->M0_FILIAL) //"Analise de Estoques para Compras - "
Private cQueryCad  := ""
Private aFields    := {}
Private _cArqTrab  := ""
Private _cIndex    := ""
//Private _cCampos   := 'B2_COD, B1_DESC, B1_FABRIC, B1_UM, B1_SEGUM, B1_QE, B2_QATU, B1_EMIN, B2_RESERVA, (B2_QPEDVEN-B2_RESERVA) AS B2_QPEDVEN, B1_UPRC, B1_UCOM, B2_CM1, LH7_VALREF, B1_SITPROD, B1_ALTER, B1_CODITE, B1_CODBAR, B1_KLINDES, B1_KGRUDES, B1_KGRPDES, B1_KSUBDES '
Private _cCampos   := "B2_COD, B1_DESC, B1_FABRIC, B1_UM, B1_SEGUM, B1_CONV, B1_QE, "+;
					  " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B2_QATU ELSE ROUND(B2_QATU/B1_CONV,0) END) AS B2_QATU, "+;
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B1_EMIN ELSE ROUND(B1_EMIN/B1_CONV,0) END) AS B1_EMIN, "+;
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B2_RESERVA ELSE ROUND(B2_RESERVA/B1_CONV,0) END) AS B2_RESERVA, "+;
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN (B2_QPEDVEN-B2_RESERVA) ELSE ROUND((B2_QPEDVEN-B2_RESERVA)/B1_CONV,0) END) AS B2_QPEDVEN, "+;
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B1_UPRC ELSE ROUND(B1_UPRC*B1_CONV,4) END) AS B1_UPRC, "+;
                      " B1_UCOM, "+;                                                                       
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B2_CM1  ELSE ROUND(B2_CM1*B1_CONV,4) END) AS B2_CM1, "+;
                      " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN LH7_PRC  ELSE ROUND(LH7_PRC*B1_CONV,4) END) AS LH7_PRC, "+;
                      " B1_SITPROD, B1_ALTER, B1_CODITE, B1_CODBAR "
Private _aArqSel   := {'SB2','SB1','LH7','SB0'}
Private _cArqSel2  := ''
Private _aFilEst   := {}
Private _aGruposA  := {}
Private _aGruposB  := {}

If !Empty(MV_PAR10)
   AaDd(_aGruposA,{SubStr(MV_PAR10,1,2),'',''})
   AaDd(_aGruposA,{SubStr(MV_PAR10,4,2),'',''})   
   If !Empty(MV_PAR12)   
	   AaDd(_aGruposB,{SubStr(MV_PAR12,1,2),'',''})
	   AaDd(_aGruposB,{SubStr(MV_PAR12,4,2),'',''})   
   Endif
   For _nX := 1 To 2
       If !Empty(Posicione('SU0',1,xFilial('SU0')+_aGruposA[_nX,1],'U0_TABMIN'))
          _cCampos += ", (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN B0_PRV"+Alltrim(Str(SU0->U0_TABMIN))
          _cCampos += "   ELSE ROUND((B0_PRV"+Alltrim(Str(SU0->U0_TABMIN))+"*B1_CONV)*(1-(LH7_DU2"+_aGruposA[_nX,1]+"/100)),4) END) AS B0_PRV"+Alltrim(Str(SU0->U0_TABMIN))
          _aGruposA[_nX,2] := 'Prc.'+Alltrim(SubStr(SU0->U0_NOME,1,10)) 
          _aGruposA[_nX,3] := 'B0_PRV'+Alltrim(Str(SU0->U0_TABMIN))
          If !Empty(MV_PAR12)   
	          _cCampos += ", LH7_MKP"+_aGruposB[_nX,1]+" "
    	      _aGruposB[_nX,2] := 'Mkp.'+Alltrim(SubStr(SU0->U0_NOME,1,10)) 
        	  _aGruposB[_nX,3] := 'LH7_MKP'+_aGruposB[_nX,1]
          Endif
       Endif
   Next
Endif

For _nX := 1 To Len(_aArqSel)
	_cArqSel2 += RetSqlName(_aArqSel[_nX])+ ' ' + _aArqSel[_nX] + ' '+IIf(_nX<>Len(_aArqSel),', ',' ')
Next

If MV_PAR08 == 1
    cQueryCad := "SELECT DISTINCT B2_FILIAL AS FILIAL FROM "+RetSqlName("SB2")+" WHERE B2_FILIAL <> '"+xFilial("SB2")+"' "
   	TCQUERY cQueryCad NEW ALIAS "CAD"
   	DbSelectArea('CAD')
   	While !Eof()
   		AaDd(_aFilEst,CAD->FILIAL)
   	   DbSkip()
   	EndDo
	DbCloseArea()
Endif

DbSelectArea("SB2")

aCampos := {}
AADD(aCampos,{'Codigo',     'B2_COD',    'C', TamSX3("B2_COD")[01],    0,                     PesqPict("SB2","B2_COD")})
AADD(aCampos,{'Descricao',  'B1_DESC',   'C', TamSX3("B1_DESC")[01],   0,                     PesqPict("SB1","B1_DESC")})
AADD(aCampos,{'Marca',      'B1_FABRIC', 'C', TamSX3("B1_FABRIC")[01], 0,                     PesqPict("SB1","B1_FABRIC")}) 
AADD(aCampos,{'Unidade',    'B1_UM',     'C', TamSX3("B1_UM")[01],     0,                     PesqPict("SB1","B1_UM")})
AADD(aCampos,{'Seg.UM ',    'B1_SEGUM',  'C', TamSX3("B1_SEGUM")[01],  0,                     PesqPict("SB1","B1_SEGUM")})
AADD(aCampos,{'Fat.Seg.',   'B1_CONV',   'N', TamSX3("B1_CONV")[01],   TamSX3("B1_CONV")[02], PesqPict("SB1","B1_CONV")})
AADD(aCampos,{'Emb.Fornec', 'B1_QE',     'N', TamSX3("B1_QE")[01],     TamSX3("B1_QE")[02],   PesqPict("SB1","B1_QE")})
AADD(aCampos,{'Atual',      'B2_QATU',   'N', TamSX3("B2_QATU")[01],   TamSX3("B2_QATU")[02], PesqPict("SB2","B2_QATU")})
If MV_PAR08 == 1 .And. Len(_aFilEst) > 0
   For _nX := 1 To Len(_aFilEst)
   		// SubStr(StrTran(_aFilEst[_nX], " "),1,10) -> nome da filial sem os espacoes com limite de 10 caracteres (limite de nome de campo)
		AADD(aCampos,{SubStr(StrTran(_aFilEst[_nX], " "),1,10), Upper(SubStr(StrTran(_aFilEst[_nX], " "),1,10)), 'N', TamSX3("B2_QATU")[01], TamSX3("B2_QATU")[02], PesqPict("SB2","B2_QATU")})   
   Next
   AADD(aCampos,{'Filial_TOT', 'FILIAL_TOT', 'N', TamSX3("B2_QATU")[01],    TamSX3("B2_QATU")[02],    PesqPict("SB2","B2_QATU")})   
Endif
AADD(aCampos,{'Transito',      'QTDE_TRANS', 'N', TamSX3("B2_QATU")[01],    TamSX3("B2_QATU")[02],    PesqPict("SB2","B2_QATU")})   
AADD(aCampos,{'Minimo',        'B1_EMIN',    'N', TamSX3("B1_EMIN")[01],    TamSX3("B1_EMIN")[02],    PesqPict("SB1","B1_EMIN")})
AADD(aCampos,{'Reserva',       'B2_RESERVA', 'N', TamSX3("B2_RESERVA")[01], TamSX3("B2_RESERVA")[02], PesqPict("SB2","B2_RESERVA")})
AADD(aCampos,{'Pendentes',     'B2_QPEDVEN', 'N', TamSX3("B2_QPEDVEN")[01], TamSX3("B2_QPEDVEN")[02], PesqPict("SB2","B2_QPEDVEN")})
AADD(aCampos,{'Contrato',      'LH5_QTDSAL', 'N', TamSX3("LH5_QTDSAL")[01], TamSX3("LH5_QTDSAL")[02], PesqPict("LH5","LH5_QTDSAL")})
AADD(aCampos,{'Compras',       'C7_QUANT',   'N', TamSX3("C7_QUANT")[01],   TamSX3("C7_QUANT")[02],   PesqPict("SC7","C7_QUANT")})
AADD(aCampos,{'Dt.Ult.Com',    'B1_UCOM',    'D',  8,                       0,                        PesqPict("SB1","B1_UCOM")})
//AADD(aCampos,{ 'Qtd.Ult.Co', 'D1_QUANT',   'N', TamSX3("D1_QUANT")[01],   TamSX3("D1_QUANT")[02],   PesqPict("SD1","D1_QUANT")}) //campo retirado por incompatibilidade de sintaxe na query que traz os dados.
AADD(aCampos,{'Prc.Ult.Co',    'B1_UPRC',    'N', TamSX3("B1_UPRC")[01],    TamSX3("B1_UPRC")[02],    PesqPict("SB1","B1_UPRC")})
AADD(aCampos,{'Custo Med.',    'B2_CM1',     'N', TamSX3("B2_CM1")[01],     TamSX3("B2_CM1")[02],     PesqPict("SB2","B2_CM1")})
AADD(aCampos,{'Custo Rep',     'LH7_PRC',    'N', TamSX3("LH7_PRC")[01],    TamSX3("LH7_PRC")[02],    PesqPict("LH7","LH7_PRC")})
AADD(aCampos,{'Vendas Atu',    'D2_QUANT',   'N', TamSX3("D2_QUANT")[01],   TamSX3("D2_QUANT")[02],   PesqPict("SD2","D2_QUANT")})
If MV_PAR09 == 1
   AADD(aCampos,{'Vendas A1', 'LFW_QUANT1', 'N',  TamSX3("LFW_QUANT1")[01], TamSX3("LFW_QUANT1")[02], PesqPict("LFW","LFW_QUANT")})
   AADD(aCampos,{'Vendas A2', 'LFW_QUANT2', 'N',  TamSX3("LFW_QUANT2")[01], TamSX3("LFW_QUANT2")[02], PesqPict("LFW","LFW_QUANT")})
   AADD(aCampos,{'Vendas A3', 'LFW_QUANT3', 'N',  TamSX3("LFW_QUANT3")[01], TamSX3("LFW_QUANT3")[02], PesqPict("LFW","LFW_QUANT")})
Endif
AADD(aCampos,{'Media',       'LFW_QUANT',   'N',  TamSX3("LFW_QUANT")[01],  TamSX3("LFW_QUANT")[02],  PesqPict("LFW","LFW_QUANT")})
AADD(aCampos,{'Situacao',    'B1_SITPROD',  'C',  TamSX3("B1_SITPROD")[01], 0,                        PesqPict("SB1","B1_SITPROD")})
AADD(aCampos,{'Cod.Barras',  'B1_CODBAR',   'C',  TamSX3("B1_CODBAR")[01],  0,                        PesqPict("SB1","B1_CODBAR")})
AADD(aCampos,{'Cod.Produto', 'B1_ALTER',    'C',  TamSX3("B1_ALTER")[01],   0,                        PesqPict("SB1","B1_ALTER")})
AADD(aCampos,{'Referencia',  'B1_CODITE',   'C',  TamSX3("B1_CODITE")[01],  0,                        PesqPict("SB1","B1_CODITE")})
For  _nX := 1 To 2
	If !Empty(MV_PAR10) .AND. !Empty(_aGruposA[_nX,2])
		AADD(aCampos,{ _aGruposA[_nX,2], _aGruposA[_nX,3], 'N', 12, 4, "@ER 99,999,999.9999" } )	
	Endif
Next
For _nX := 1 To 2
	If !Empty(MV_PAR12) .AND. !Empty(_aGruposB[_nX,2])
		AADD(aCampos,{ _aGruposB[_nX,2], _aGruposB[_nX,3], 'N', 12, 4, "@ER 999.9999" } )	
	Endif
Next

aCamposMB := {}

For _nX   := 1 To Len(aCampos)
	AaDd(aCamposMB,{aCampos[_nX,1],aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5],aCampos[_nX,6]})
Next

Cria_TMP()
DbSelectArea('TMP')

Private aRotina := MenuDef()

Private aCores := { { '(B1_EMIN > (B2_QATU-B2_RESERVA))', 'BR_VERMELHO' },;
                    { '(B1_EMIN = (B2_QATU-B2_RESERVA))', 'BR_AMARELO'  },;
                    { '(B1_EMIN < (B2_QATU-B2_RESERVA))', 'BR_VERDE'    }}

Processa({|| Monta_TMP() } ,STR0007) //"Selecionando Informacoes dos Produtos..."

mBrowse( 6,1,22,75,"TMP",aCamposMB,,,,,aCores)

DbSelectArea("TMP")
DbCloseArea()
If File(_cArqTrab+OrdBagExt())
	FErase(_cArqTrab+OrdBagExt())
Endif
If File(_cIndex+ordbagext())
	FErase(_cIndex+ordbagext())
Endif

Return(nil)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TCOMA02                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {{STR0002, "T_PesqSB2()",            0, 2, 0, .F.},;	//"Pesquisa"
                  {STR0003, "T_TTMKC01(TMP->B2_COD)", 0, 2, 0, .F.},;	//"Posicao"
                  {STR0004, "T_TCOMA02Imp()",         0, 2, 0, .T.},;	//"Imprimir"
                  {STR0005, "T_TCOMA02Exc()",         0, 2, 0, .T.},;	//"Gera Excel"
                  {STR0006, "T_VeLegB2()",            0, 2, 0, .T.}}	//"Legenda"
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TMP  บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cria_TMP()
Local _nX
aFields := {}
For _nX := 1 To Len(aCampos)
	AADD(aFields,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5]})
Next
_cArqTrab:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,_cArqTrab,"TMP")
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TMP บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TMP()
Local _nX, _nX2, _nXLS
For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+_cArqSel2+" WHERE "
	Else
		cQueryCad := "SELECT DISTINCT "
		cQueryCad += _cCampos+ ","
		cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "		
		cQueryCad += " (SELECT ISNULL(SUM(LH5_QTDSAL),0) FROM "+RetSqlName('LH5')
		cQueryCad += " WHERE "+RetSqlName('LH5')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " LH5_PRODUT = SB2.B2_COD) ELSE "
		cQueryCad += " ROUND(((SELECT ISNULL(SUM(LH5_QTDSAL),0) FROM "+RetSqlName('LH5')
		cQueryCad += " WHERE "+RetSqlName('LH5')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " LH5_PRODUT = SB2.B2_COD)/B1_CONV),0) END) "
		cQueryCad += " AS LH5_QTDSAL, "        
		
		/* O comando TOP nao funciona em todos os bancos. Por conta disso, a coluna D1_QUANT sera removida da consulta
		
		
		cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "				
		cQueryCad += " (SELECT TOP 1 ISNULL(D1_QUANT,0) FROM "+RetSqlName('SD1')
		cQueryCad += " WHERE "+RetSqlName('SD1')+".D_E_L_E_T_ <> '*' "
		cQueryCad += " AND D1_COD = SB2.B2_COD ORDER BY D1_EMISSAO DESC) ELSE "
		cQueryCad += " ROUND(((SELECT TOP 1 ISNULL(D1_QUANT,0) FROM "+RetSqlName('SD1')
		cQueryCad += " WHERE "+RetSqlName('SD1')+".D_E_L_E_T_ <> '*' "
		cQueryCad += " AND D1_COD = SB2.B2_COD ORDER BY D1_EMISSAO DESC)/B1_CONV),0,1) END) "
		cQueryCad += " AS D1_QUANT, "
		*/
		
		
		
		cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "
		cQueryCad += " (SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM "+RetSqlName('SC7')
		cQueryCad += " WHERE "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " C7_QUANT > C7_QUJE AND C7_RESIDUO = ' ' AND "
		If !Empty(GetMv("MV_F_TRANS"))		
			cQueryCad += " C7_FORNECE NOT IN ("+GetMv("MV_F_TRANS")+") AND "				
		Endif
		cQueryCad += " C7_ENCER <> 'E' and SB2.B2_COD = C7_PRODUTO) ELSE "
		cQueryCad += " ROUND(((SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM "+RetSqlName('SC7')
		cQueryCad += " WHERE "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " C7_QUANT > C7_QUJE AND C7_RESIDUO = ' ' AND "
		If !Empty(GetMv("MV_F_TRANS"))		
			cQueryCad += " C7_FORNECE NOT IN ("+GetMv("MV_F_TRANS")+") AND "				
		Endif
		cQueryCad += " C7_ENCER <> 'E' and SB2.B2_COD = C7_PRODUTO)/B1_CONV),0) END) "
		cQueryCad += " AS C7_QUANT, "
		If !Empty(GetMv("MV_F_TRANS"))
			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "		
			cQueryCad += " (SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM "+RetSqlName('SC7')
			cQueryCad += " WHERE "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND C7_PRODUTO = SB2.B2_COD AND "
			cQueryCad += " C7_QUANT > C7_QUJE AND C7_RESIDUO = ' ' AND C7_ENCER <> 'E' AND "
			cQueryCad += " C7_FORNECE IN ("+GetMv("MV_F_TRANS")+")) ELSE " 
//			cQueryCad += " C7_FILIAL = '"+xFilial("SC7")+"') ELSE " 			
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM "+RetSqlName('SC7')
			cQueryCad += " WHERE "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND C7_PRODUTO = SB2.B2_COD AND "
			cQueryCad += " C7_QUANT > C7_QUJE AND C7_RESIDUO = ' ' AND C7_ENCER <> 'E' AND "
			cQueryCad += " C7_FORNECE IN ("+GetMv("MV_F_TRANS")+"))/B1_CONV),0) END) AS QTDE_TRANS, "			
//			cQueryCad += " C7_FILIAL = '"+xFilial("SC7")+"')/B1_CONV),0,1) END) AS QTDE_TRANS, "
		Else
			cQueryCad += " 0 AS QTDE_TRANS, "
		Endif
		_cMes1 := Str(Val(Str(Year(dDatabase),4)+StrZero(Month(dDatabase),2))-1,6)
		If Val(SubStr(_cMes1,5,2)) == 0 
			_cMes1 := Str(Val(Str(Year(dDatabase)-1,4)+'12'),6)			
		Endif
		_cMes2 := Str(Val(_cMes1)-1,6) 
		If Val(SubStr(_cMes2,5,2)) == 0 
			_cMes2 := Str(Val(Str(Val(SubStr(_cMes2,1,4))-1,4)+'12'),6)			
		Endif
		_cMes3 := Str(Val(_cMes2)-1,6)
		If Val(SubStr(_cMes3,5,2)) == 0 
			_cMes3 := Str(Val(Str(Val(SubStr(_cMes3,1,4))-1,4)+'12'),6)			
		Endif                                                                           
		cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "						
		cQueryCad += " (SELECT ROUND(ISNULL(SUM(LFW_QUANT)/3,0),0) FROM "+RetSqlName('LFW')
		cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
		cQueryCad += " LFW_ANO+LFW_MES >= '"+_cMes3+"') ELSE "
		cQueryCad += " ROUND(((SELECT ROUND(ISNULL(SUM(LFW_QUANT)/3,0),0) FROM "+RetSqlName('LFW')
		cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
		cQueryCad += " LFW_ANO+LFW_MES >= '"+_cMes3+"')/B1_CONV),0) END) "
		cQueryCad += " 	AS LFW_QUANT, "
                                                        
		If MV_PAR09 == 1                                                                        

			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "											
			cQueryCad += " (SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes1+"') ELSE "
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes1+"')/B1_CONV),0) END) "
			cQueryCad += " AS LFW_QUANT1, "
			
			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "											
			cQueryCad += " (SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes2+"') ELSE "
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes2+"')/B1_CONV),0) END) "
			cQueryCad += " AS LFW_QUANT2, "
			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "
			cQueryCad += " (SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes3+"') ELSE "
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(LFW_QUANT),0) FROM "+RetSqlName('LFW')
			cQueryCad += " WHERE "+RetSqlName('LFW')+".D_E_L_E_T_ <> '*' AND "
			cQueryCad += " LFW_PRODUT = SB2.B2_COD AND "
			cQueryCad += " LFW_ANO+LFW_MES = '"+_cMes3+"')/B1_CONV),0) END) "
			cQueryCad += " AS LFW_QUANT3, "
		Endif
		If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "		
			cQueryCad += " (SELECT ISNULL(SUM(D2_QUANT),0) FROM "+RetSqlName('SD2')
			cQueryCad += " WHERE "+RetSqlName('SD2')+".D_E_L_E_T_ <> '*' "
			cQueryCad += " AND D2_COD = SB2.B2_COD "
//			cQueryCad += " AND D2_FILIAL = SB2.B2_FILIAL "
			cQueryCad += " AND D2_EMISSAO >= '"+DTOS(MV_PAR05)+"' "
			cQueryCad += " AND D2_EMISSAO <= '"+DTOS(MV_PAR06)+"' "
			cQueryCad += " AND D2_TIPO = 'N' "
			cQueryCad += " AND SUBSTRING(D2_CF,2,3) IN ("+GetMv("MV_CFRELS")+")) ELSE "
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(D2_QUANT),0) FROM "+RetSqlName('SD2')
			cQueryCad += " WHERE "+RetSqlName('SD2')+".D_E_L_E_T_ <> '*' "
			cQueryCad += " AND D2_COD = SB2.B2_COD "
//			cQueryCad += " AND D2_FILIAL = SB2.B2_FILIAL "
			cQueryCad += " AND D2_EMISSAO >= '"+DTOS(MV_PAR05)+"' "
			cQueryCad += " AND D2_EMISSAO <= '"+DTOS(MV_PAR06)+"' "
			cQueryCad += " AND D2_TIPO = 'N' "
			cQueryCad += " AND SUBSTRING(D2_CF,2,3) IN ("+GetMv("MV_CFRELS")+"))/B1_CONV),0) END) "
			cQueryCad += " AS D2_QUANT "
		Else
			cQueryCad += " 0 AS D2_QUANT "
		Endif
		If MV_PAR08 == 1 .And. Len(_aFilEst) > 0
			cQueryCad += " , "			
			For _nX := 1 To Len(_aFilEst)
				cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "		
				cQueryCad += " (SELECT ISNULL(SUM(B2_QATU-B2_RESERVA),0) FROM "+RetSqlName('SB2')
				cQueryCad += " WHERE "+RetSqlName('SB2')+".D_E_L_E_T_ <> '*' AND B2_FILIAL = '"+_aFilEst[_nX]+"' "
				cQueryCad += " AND B2_COD = SB2.B2_COD AND B2_LOCAL = SB2.B2_LOCAL) ELSE "
				cQueryCad += " ROUND(((SELECT ISNULL(SUM(B2_QATU-B2_RESERVA),0) FROM "+RetSqlName('SB2')
				cQueryCad += " WHERE "+RetSqlName('SB2')+".D_E_L_E_T_ <> '*' AND B2_FILIAL = '"+_aFilEst[_nX]+"' "
				cQueryCad += " AND B2_COD = SB2.B2_COD AND B2_LOCAL = SB2.B2_LOCAL)/B1_CONV),0) END) "
				cQueryCad += " AS "+  SubStr(StrTran(_aFilEst[_nX], " "),1,10) +" , " // SubStr(StrTran(_aFilEst[_nX], " "),1,10) -> nome da filial sem os espacoes com limite de 10 caracteres (limite de nome de campo)
			Next
			cQueryCad += " (CASE WHEN B1_SEGUM = '  ' AND B1_CONV = 0 THEN "		
			cQueryCad += " (SELECT ISNULL(SUM(B2_QATU-B2_RESERVA),0) FROM "+RetSqlName('SB2')
			cQueryCad += " WHERE "+RetSqlName('SB2')+".D_E_L_E_T_ <> '*' AND B2_COD = SB2.B2_COD AND B2_LOCAL = SB2.B2_LOCAL) ELSE "
			cQueryCad += " ROUND(((SELECT ISNULL(SUM(B2_QATU-B2_RESERVA),0) FROM "+RetSqlName('SB2')
			cQueryCad += " WHERE "+RetSqlName('SB2')+".D_E_L_E_T_ <> '*' AND B2_COD = SB2.B2_COD AND B2_LOCAL = SB2.B2_LOCAL)/B1_CONV),0) END) "
			cQueryCad += " AS FILIAL_TOT "
		Endif
		cQueryCad += " FROM "+_cArqSel2+" WHERE "
	Endif
	
	For _nX2 := 1 To Len(_aArqSel)
		cQueryCad += _aArqSel[_nX2]+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += IIF(SubStr(_aArqSel[_nX2],1,1)=='S',SubStr(_aArqSel[_nX2],2,2),_aArqSel[_nX2])+"_FILIAL = '"+xFilial(_aArqSel[_nX2])+"'"+IIf(_nX2<>Len(_aArqSel)," AND ",' ')
	Next _nX2
	cQueryCad += " AND B1_COD = B2_COD "
	cQueryCad += " AND B1_COD = LH7_COD "	
	cQueryCad += " AND B1_COD = B0_COD "		
	If !Empty(MV_PAR01)
		cQueryCad += " AND B1_PROC = '"+MV_PAR01+"' "
	Endif
	If !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
		cQueryCad += " AND B1_COD >= '"+MV_PAR02+"' "
		cQueryCad += " AND B1_COD <= '"+MV_PAR03+"' "
	Endif
	If !Empty(MV_PAR07)
		cQueryCad += " AND B2_LOCAL = '"+MV_PAR07+"' "
	Endif
	If MV_PAR04 > 1
		cQueryCad += " AND (SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM "+RetSqlName('SC7')+"  "
		cQueryCad += " WHERE "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += " C7_QUANT > C7_QUJE AND C7_RESIDUO = ' ' AND "
		cQueryCad += " C7_ENCER <> 'E' and SB2.B2_COD = C7_PRODUTO) "+If(MV_PAR04 = 2,">","=")+" 0 "
	Endif
	If !Empty(MV_PAR11)
		_aListaSit := &("{'"+Strtran(MV_PAR11,";","','")+"'}")
		cQueryCad += " AND B1_SITPROD NOT IN ("	
		For _nXLS := 1 To Len(_aListaSit)
			cQueryCad += "'"+Alltrim(_aListaSit[_nXLS])+"'"+IIF(_nXLS < Len(_aListaSit),",",")")
		Next
	Endif
	If _nX = 2
		cQueryCad += " ORDER BY B1_DESC "
	Endif 
	
	cQueryCad := ChangeQuery(cQueryCad)
	
	TCQUERY cQueryCad NEW ALIAS "CAD" 
	
	If _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	Endif
Next

TCSetField("CAD","B1_UCOM","D")
                               
Dbselectarea("CAD")

ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock("TMP",.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] = 'C'
			_cX := 'TMP->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			_cX := 'TMP->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
		Endif
		_cX := &_cX
	Next
	MsUnLock()
	CAD->(dBSkip())
EndDo
Dbselectarea("CAD")
DbCloseArea()
Dbselectarea("TMP")
DbGoTop()

_cIndex := Criatrab(Nil,.F.)
_cChave := 'B1_DESC'
Indregua("TMP",_cIndex,_cChave,,,STR0008) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())
Dbselectarea("TMP")
SysRefresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA02ExcบAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TCOMA02Exc()
Local _nX
tamanho  :="M"
li       := 65
limite   := 80
titulo   := STR0026+Alltrim(SM0->M0_CODFIL)+" / "+Alltrim(SM0->M0_FILIAL) //"ANALISE DE ESTOQUE - "
cDesc1   := STR0027 //"Emissao do filtro da analise de estoque - Excel"
cDesc2   := ""
cDesc3   := ""
m_pag    := 1
aReturn  := { STR0028, 1,STR0029, 1, 2, 1,"",1 } //"Especial"###"Administracao"
wnrel    := nomeprog:="TCOMA02_EXCEL"
nLastKey := 0
cString  := "SB2"
cabec1   := "" 
For _nX := 1 To Len(aCampos)
	cabec1   += aCampos[_nX,1]+IIF(_nX<Len(aCampos),';','')
Next
wnrel    := SetPrint(cString,wnrel,nil,@Titulo,cDesc1,cDesc2,cDesc3,.t.,,.t.,tamanho)
If nLastKey == 27
	Return
Endif
RptStatus({|| RptExcel() })
If nLastKey == 27
	Return
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRptExcel  บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function RptExcel()
Local _nX
SetDefault(aReturn,cString)
setprc(0,0)
setregua(RecCount())
DbSelectArea('TMP')
DbGoTop()
li := 0
@ li,000 PSAY cabec1
++li
do while !Eof()
	incregua()
	_cLinhaExc := ''
	For _nX := 1 To Len(aCampos)        
		If 'Mkp' = SubStr(aCampos[_nX,1],1,3)
			_cLinhaExc += IIF(aCampos[_nX,3]=='N'.And.aCampos[_nX,5]==0,"TransForm(TMP->"+aCampos[_nX,2]+",'@ER'+Replicate('9',"+Alltrim(Str(aCampos[_nX,4]))+"))+'%'",;
						  IIF(aCampos[_nX,3]=='N'.And.aCampos[_nX,5]>0 ,"TransForm(ROUND(TMP->"+aCampos[_nX,2]+",2),'@ER'+Replicate('9',"+Alltrim(Str((aCampos[_nX,4]-aCampos[_nX,5]-1)))+")+'.'+Replicate('9',"+Alltrim(Str(aCampos[_nX,5]))+"))+'%'","TMP->"+aCampos[_nX,2]))+IIF(_nX<Len(aCampos),"+';'+","")
		Else
			_cLinhaExc += IIF(aCampos[_nX,3]=='C',"TMP->"+aCampos[_nX,2],;
						  IIF(aCampos[_nX,3]=='N'.And.aCampos[_nX,5]==0,"TransForm(TMP->"+aCampos[_nX,2]+",'@ER'+Replicate('9',"+Alltrim(Str(aCampos[_nX,4]))+"))",;
						  IIF(aCampos[_nX,3]=='N'.And.aCampos[_nX,5]>0 ,"TransForm(ROUND(TMP->"+aCampos[_nX,2]+",2),'@ER'+Replicate('9',"+Alltrim(Str((aCampos[_nX,4]-aCampos[_nX,5]-1)))+")+'.'+Replicate('9',"+Alltrim(Str(aCampos[_nX,5]))+"))",;
						  IIF(aCampos[_nX,3]=='D',"DTOC(TMP->"+aCampos[_nX,2]+")","TMP->"+aCampos[_nX,2]))))+IIF(_nX<Len(aCampos),"+';'+","")
		Endif					  
	Next
	@ li,000 PSAY &_cLinhaExc
	++li
	DbSkip()
enddo
DbGoTop()
If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA02ImpบAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TCOMA02Imp()

CHKTEMPLATE("DCM")  

tamanho  :="M"
li       := 65
limite   := 80
titulo   := STR0026+Alltrim(SM0->M0_CODFIL)+" / "+Alltrim(SM0->M0_FILIAL) //"ANALISE DE ESTOQUE - "
cDesc1   := STR0030 //"Emissao do filtro da analise de estoque"
cDesc2   := ""
cDesc3   := ""
m_pag    := 1
aReturn  := { STR0028, 1,STR0029, 1, 2, 1,"",1 } //"Especial"###"Administracao"
wnrel    := nomeprog:="TCOMA02"
nLastKey := 0
cString  := "SB2" 
cabec1   := STR0031 //"Codigo          Descricao                                UM Marca             Atual Minimo Reserv Penden Compra    Ctr Vendas  Media"
cabec2   := ""                   
wnrel    := SetPrint(cString,wnrel,nil,@Titulo,cDesc1,cDesc2,cDesc3,.t.,,.t.,tamanho)
If nLastKey == 27
	Return
Endif
RptStatus({|| RptDetail() })
If nLastKey == 27
	Return
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRptDetail บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function RptDetail()

//Codigo          Descricao                                UM Marca             Atual Minimo Reserv Penden Compra    Ctr Vendas  Media
//123456789012345 1234567890123456789012345678901234567890 12 1234567890123456 999999 999999 999999 999999 999999 999999 999999 999999
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//          1         2         3         4         5         6         7         8         9         0         1         2
SetDefault(aReturn,cString)
setprc(0,0)
setregua(RecCount())
DbSelectArea('TMP')
DbGoTop()
do while !Eof()
	incregua()
	if li>=60
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	endif
	
	@ li,000 PSAY TMP->B2_COD
	@ li,016 PSAY TMP->B1_DESC
	@ li,057 PSAY TMP->B1_UM
	@ li,060 PSAY SubStr(TMP->B1_FABRIC,1,16)
	If (TMP->B2_QATU-TMP->B2_RESERVA)<=TMP->B1_EMIN .And. TMP->B1_EMIN > 0
	   @ li,076 PSAY '>'
	Endif
	@ li,077 PSAY TMP->B2_QATU    PICTURE "@ER 999999"
	@ li,084 PSAY TMP->B1_EMIN    PICTURE "@ER 999999"
	@ li,091 PSAY TMP->B2_RESERVA PICTURE "@ER 999999"
	@ li,098 PSAY TMP->B2_QPEDVEN PICTURE "@ER 999999"
	@ li,105 PSAY TMP->C7_QUANT   PICTURE "@ER 999999"
	@ li,112 PSAY TMP->LH5_QTDSAL PICTURE "@ER 999999"
	@ li,119 PSAY TMP->D2_QUANT   PICTURE "@ER 999999"
	@ li,126 PSAY TMP->LFW_QUANT  PICTURE "@ER 999999"
	++li
	@ li,000 PSAY Replicate('-',132)
	++li
		
	DbSkip()
enddo
DbGoTop()
If aReturn[5] == 1
	Set Printer To
	//Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesqSB2   บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function PesqSB2()

CHKTEMPLATE("DCM")  

_cPesqCod := Space(TamSX3("B1_COD")[01])
_cPesqDes := Space(TamSX3("B1_DESC")[01])
@ 220,005 TO 320,350 DIALOG oDlgPesC TITLE STR0032 //'Pesquisa Produtos'
@ 003,002 SAY STR0033 //'Codigo'
@ 002,035 GET _cPesqCod   SIZE 135,15 PICTURE "@!" VALID PesquiPro("C",_cPesqCod)
@ 018,002 SAY STR0034 //'Descricao'
@ 017,035 GET _cPesqDes   SIZE 135,15 PICTURE "@!" VALID PesquiPro("D",_cPesqDes)
@ 030,090 BUTTON "_Ok" SIZE 80,15 ACTION Close(oDlgPesC)
ACTIVATE DIALOG oDlgPesC CENTERED
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquiPro บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION PesquiPro(_cTpPesq,_cPesq)
If !Empty(_cPesq)
	If _cTpPesq == "D"	// Pesquisa por descri็ใo
		DbSelectArea('TMP')
		If DbSeek(Rtrim(_cPesq))
			Close(oDlgPesC)
			SysRefresh()
		Else
			MsgBox(STR0035) //"Descricao Nao Encontrada!"
			_cPesqDes := Space(TamSX3("B1_DESC")[01])
			DbSelectArea('TMP')
			DbGoTop()
		Endif
	Else
		DbSelectArea('SB1')
		DbSetOrder(1)
		If DbSeek(xFilial('SB1')+_cPesq)
			DbSelectArea('TMP')
			If DbSeek(Rtrim(SB1->B1_DESC))
				Close(oDlgPesC)
				SysRefresh()
			Else
				MsgBox(STR0036) //"Codigo Nao Encontrado no Filtro!"
				DbSelectArea('TMP')
				DbGoTop()
			Endif
		Else
			MsgBox(STR0037) //"Codigo Nao Encontrado!"
			DbSelectArea('TMP')
			DbGoTop()
		Endif
	Endif
Endif
Return(.T.)
                                               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVeLegB2   บAutor  ณMicrosiga           บ Data ณ  08/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function VeLegB2()
CHKTEMPLATE("DCM")  
aCorDesc := {{'BR_VERDE',    STR0038},; //'Em condicoes normais'
             {'BR_VERMELHO', STR0039},; //'Estoque Abaixo do Minimo'
             {'BR_AMARELO',  STR0040}}  //'Estoque Igual ao Minimo'
BrwLegenda(STR0040, STR0041, aCorDesc)  //"Legenda"###"Status"
Return( .T. )