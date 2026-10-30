#INCLUDE "tfata05.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATA05   บAutor  ณEwerton C. Tomaz    บ Data ณ  22/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCONSULTA GERAL DE PEDIDOS									  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Projeto Ewerton                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TFATA05()
Local _nX
Private cCadastro :=STR0001 //"Pedidos"
Private cQueryCad := ""
Private aFields   := {}  
Private _cCampos  := 'C5_NUM, C5_FIL, A1_NOME, C9_TIP, C9_VLR, C9_MRG'
Private _cEmpresas:= ''//GetMV("MV_TESTRAN")
Private _cPedido  :=STR0002 //"Ver Pedido"
Private _aArqSel  := {'SC5','SA1'}
Private _nMargem := 0
Private _aContadores := {{0,0,0,0,0},;   // 1 Pedidos
						  {0,0,0,0,0},;  // 2 Retiras						
						  {0,0,0,0,0},;  // 3 Entregas						  
						  {0,0,0,0,0},;  // 4 Bloqueados
						  {0,0,0,0,0},;  // 5 Contratos
						  {0,0,0,0,0},;  // 6 Separacao
						  {0,0,0,0,0},;  // 7 Conferidos
						  {0,0,0,0,0}}   // 8 Faturados

If !Pergunte('TFAT05')
   Return
EndIf   
            
@ 050,005 TO 550,780 DIALOG oDlgPedL TITLE STR0001 //"Pedidos"
aCampos := {}
DbSelectArea('SX3')
DbSetOrder(1)
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
	   If !(ALLTRIM(X3_CAMPO) $ _cCampos)
	      DbSkip()
    	  Loop
	   EndIf   
	   AADD(aCampos,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCampos),3,0),Alltrim(X3_CAMPO),Alltrim(X3_TITULO),X3_PICTURE,X3_TAMANHO,X3_DECIMAL})
	   DbSkip()
	End   
Next                                   

AADD(aCampos,{'200','C9_TIP',STR0003,'@!','3','0'}) //'Tipo'
AADD(aCampos,{'201','C9_VLR',STR0004,'999,999.99','10','2'}) //'$ Total'
AADD(aCampos,{'202','C9_MRG',STR0005,'9999.99','8','2'}) //'Margem(%)'
AADD(aCampos,{'203','C9_BLQ',STR0006,'@!','3','0'}) //'Blqs'
AADD(aCampos,{'204','C9_SEP',STR0007,'@!','1','0'}) //'Sep'
AADD(aCampos,{'205','C9_CNF',STR0008,'@!','1','0'}) //'Conf'
AADD(aCampos,{'206','C9_FAT',STR0009,'@!','1','0'}) //'Fat'
AADD(aCampos,{'207','C9_LIB',STR0010,'@!','20','0'}) //'Liberador'
AADD(aCampos,{'208','C9_EST',STR0011,'@!','2','0'}) //'UF'
AADD(aCampos,{'209','C9_EMI',STR0012,'@!','1','0'}) //'Emissao'
AADD(aCampos,{'210','C9_VND',STR0013,'@!','20','0'}) //'Vendedor'
AADD(aCampos,{'211','C9_NOT',STR0014,'@!','06','0'}) //'N.F.'
AADD(aCampos,{'212','C9_CTR',STR0015,'@!','01','0'}) //'Cont.'
AADD(aCampos,{'213','C9_CUS',STR0016,'999,999.99','10','2'}) //'$ CUSTO'
AADD(aCampos,{'214','C9_CFO',STR0017,'@!','04','0'}) //'CFO'
AADD(aCampos,{'215','C9_FIL',STR0018,'@!','02','0'}) //'FIL'
ASort(aCampos,,,{|x,y|x[1]<y[1]})

aCampos2 := {}
For _nX := 1 To Len(aCampos)
    AADD(aCampos2,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5],aCampos[_nX,6]})
Next
aCampos := {}
aCampos := aCampos2
Cria_TC9()
DbSelectArea('TC9')
@ 006,005 TO 140,385 BROWSE "TC9"  FIELDS aCampos Object _oBrwPed
@ 195,347 BUTTON STR0019           SIZE 40,15 ACTION FTA05B2() //"_Ver Pedido"
@ 215,347 BUTTON STR0020           SIZE 40,15 ACTION Close(oDlgPedL) //"_Sair"
                        
Processa({|| Monta_TC9() } ,STR0021) //"Selecionando Informacoes dos Pedidos..."

@ 141,060 SAY "QTDE"
@ 141,115 SAY STR0022 //"VOLUMES"
@ 141,170 SAY STR0023 //"PESO	"
@ 141,230 SAY STR0024 //"$ TOTAL"
@ 141,295 SAY STR0025 //"$ MARGEM"

@ 151,005 SAY STR0026 //"     PEDIDOS: "
@ 171,005 SAY STR0027 //"     RETIRAS: "
@ 181,005 SAY STR0028 //"    ENTREGAS: "
@ 191,005 SAY STR0029 //"  BLOQUEADOS: "
@ 201,005 SAY STR0030 //"   FATURADOS: "
@ 211,005 SAY STR0031 //"EM SEPARACAO: "
@ 221,005 SAY STR0032 //"  CONFERIDOS: "
@ 231,005 SAY STR0033 //"   CONTRATOS: "

@ 151,060 GET _aContadores[1,1] Picture '999999' SIZE 40,9 When .f.
@ 171,060 GET _aContadores[2,1] Picture '999999' SIZE 40,9 When .f.
@ 181,060 GET _aContadores[3,1] Picture '999999' SIZE 40,9 When .f.
@ 191,060 GET _aContadores[4,1] Picture '999999' SIZE 40,9 When .f.
@ 201,060 GET _aContadores[8,1] Picture '999999' SIZE 40,9 When .f.
@ 211,060 GET _aContadores[6,1] Picture '999999' SIZE 40,9 When .f.
@ 221,060 GET _aContadores[7,1] Picture '999999' SIZE 40,9 When .f.
@ 231,060 GET _aContadores[5,1] Picture '999999' SIZE 40,9 When .f.

@ 151,115 GET _aContadores[1,2] Picture '999999' SIZE 40,9 When .f.
@ 171,115 GET _aContadores[2,2] Picture '999999' SIZE 40,9 When .f.
@ 181,115 GET _aContadores[3,2] Picture '999999' SIZE 40,9 When .f.
@ 191,115 GET _aContadores[4,2] Picture '999999' SIZE 40,9 When .f.
@ 201,115 GET _aContadores[8,2] Picture '999999' SIZE 40,9 When .f.
@ 211,115 GET _aContadores[6,2] Picture '999999' SIZE 40,9 When .f.
@ 221,115 GET _aContadores[7,2] Picture '999999' SIZE 40,9 When .f.
@ 231,115 GET _aContadores[5,2] Picture '999999' SIZE 40,9 When .f.

@ 151,170 GET _aContadores[1,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 171,170 GET _aContadores[2,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 181,170 GET _aContadores[3,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 191,170 GET _aContadores[4,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 201,170 GET _aContadores[8,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 211,170 GET _aContadores[6,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 221,170 GET _aContadores[7,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.
@ 231,170 GET _aContadores[5,3] Picture '@ER 99,999.99' SIZE 45,9 When .f.

@ 151,230 GET _aContadores[1,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 171,230 GET _aContadores[2,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 181,230 GET _aContadores[3,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 191,230 GET _aContadores[4,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 201,230 GET _aContadores[8,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 211,230 GET _aContadores[6,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 221,230 GET _aContadores[7,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.
@ 231,230 GET _aContadores[5,4] Picture '@ER 99,999,999.99' SIZE 50,9 When .f.

@ 151,295 GET Iif(_aContadores[1,5]>0,Round(100-((_aContadores[1,5] / _aContadores[1,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 171,295 GET Iif(_aContadores[2,1]>0,Round(100-((_aContadores[2,5] / _aContadores[2,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 181,295 GET Iif(_aContadores[3,1]>0,Round(100-((_aContadores[3,5] / _aContadores[3,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 191,295 GET Iif(_aContadores[4,1]>0,Round(100-((_aContadores[4,5] / _aContadores[4,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 201,295 GET Iif(_aContadores[8,1]>0,Round(100-((_aContadores[5,5] / _aContadores[5,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 211,295 GET Iif(_aContadores[6,1]>0,Round(100-((_aContadores[6,5] / _aContadores[6,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 221,295 GET Iif(_aContadores[7,1]>0,Round(100-((_aContadores[7,5] / _aContadores[7,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.
@ 231,295 GET Iif(_aContadores[5,1]>0,Round(100-((_aContadores[8,5] / _aContadores[8,4])*100),2),0) Picture '@ER 999.99' SIZE 40,9 When .f.

ACTIVATE DIALOG oDlgPedL CENTERED

DbSelectArea("TC9")
DbCloseArea()
                                         
Return                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC9  บAutor  ณMicrosiga           บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION Cria_TC9()
Local _nX
DbSelectArea('SX3')
DbSetOrder(1)
aFields := {}
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
	   If !(ALLTRIM(X3_CAMPO) $ _cCampos)
    	  DbSkip()
	      Loop
	   Endif   
	   AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	   DbSkip()
	End   
Next  
AADD(aFields,{"C9_TIP"     ,"C",03,0})
AADD(aFields,{"C9_VLR"     ,"N",10,2})
AADD(aFields,{"C9_MRG"     ,"N",08,2})
AADD(aFields,{"C9_BLQ"     ,"C",03,0})
AADD(aFields,{"C9_SEP"     ,"C",01,0})
AADD(aFields,{"C9_CNF"     ,"C",01,0})
AADD(aFields,{"C9_FAT"     ,"C",01,0})
AADD(aFields,{"C9_LIB"     ,"C",20,0})
AADD(aFields,{"C9_EST"     ,"C",02,0})
AADD(aFields,{"C9_EMI"     ,"D",08,0})
AADD(aFields,{"C9_VND"     ,"C",10,0})
AADD(aFields,{"C9_NOT"     ,"C",06,0})
AADD(aFields,{"C9_CTR"     ,"C",01,0})
AADD(aFields,{"C9_CUS"     ,"N",10,2})
AADD(aFields,{"C9_CFO"     ,"C",04,0})
AADD(aFields,{"C9_FIL"     ,"C",02,0})

cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TC9")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC9 บAutor  ณMicrosiga           บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TC9()
Local _nX
_nCount := 0
cQueryCad := ""
For _nX := 1 To 2
    If _nX = 1
       cQueryCad := "SELECT COUNT(*) AS TOTAL FROM "+RetSqlName('SC5')+" C5  WHERE "
   	Else 
		cQueryCad := "SELECT C5.C5_NUM AS C5_NUM, C5.C5_FILIAL AS C5_FIL, " 
		cQueryCad += "A1.A1_NOME AS A1_NOME, "
		cQueryCad += "CASE "
		cQueryCad += "WHEN ISNULL((SELECT COUNT(*) FROM "+RetSqlName('SA4')+"  WHERE A4_COD = C5.C5_TRANSP AND A4_NOME LIKE '%RETIRA%' AND D_E_L_E_T_ <> '*'),0) > 0 THEN 'RET' "
		cQueryCad += "ELSE '  ' "
		cQueryCad += "END AS C9_TIP, " 
		cQueryCad += "(SELECT SUM(C6_VALOR) FROM "+RetSqlName('SC6')+" C6  WHERE "
		cQueryCad += " C6_NUM = C5.C5_NUM AND C6.C6_CLI = C5.C5_CLIENTE AND C6.C6_LOJA = C5.C5_LOJACLI AND C6.D_E_L_E_T_ <> '*') AS C9_VLR, "
		cQueryCad += "(SELECT 100-((SUM(LH7_PRC * C6_QTDVEN) / SUM(C6_VALOR))*100) FROM "+RetSqlName('SC6')+" C6 , "+RetSqlName('LH7')+" LH7  "
		cQueryCad += "	WHERE C6_NUM = C5.C5_NUM AND C6.C6_CLI = C5.C5_CLIENTE AND C6.C6_LOJA = C5.C5_LOJACLI AND "
		cQueryCad += "	C6.D_E_L_E_T_ <> '*' AND LH7.D_E_L_E_T_ <> '*' AND LH7_COD = C6_PRODUTO) AS C9_MRG "
		cQueryCad += "FROM "+RetSqlName('SC5')+" C5  "
		cQueryCad += "INNER JOIN "+RetSqlName('SA1')+" A1  "
		cQueryCad += "ON C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA "
		cQueryCad += "WHERE "               
		cQueryCad += "A1.D_E_L_E_T_ <> '*' AND "
	Endif
	cQueryCad += "C5.D_E_L_E_T_ <> '*' "
	If !Empty(MV_PAR07)
		cQueryCad += "AND C5.C5_FILIAL >= '"+MV_PAR07+"' "
	Endif
	If !Empty(MV_PAR08)
		cQueryCad += " AND C5.C5_FILIAL <= '"+MV_PAR08+"' "
	Endif
    If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		cQueryCad += "AND C5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	Endif         
	If !Empty(MV_PAR03)
   	   cQueryCad += "AND C5.C5_CLIENTE = '"+MV_PAR03+"' " 
   	Endif                                             
	If !Empty(MV_PAR04)
   	   cQueryCad += " AND C5.C5_VEND1 = '"+MV_PAR04+"' "
   	Endif                 
    If _nX = 2   	                                      
       cQueryCad += " ORDER BY C5.C5_NUM"
    Endif   
    
    cQueryCad := ChangeQuery(cQueryCad)
	
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
	   _nCount := CAD->TOTAL
	   DbCloseArea()
	Endif
Next	

Dbselectarea("SUA")                  
DbSetOrder(8)

Dbselectarea("SU7")                  
DbSetOrder(1)

Dbselectarea("CAD")                  
DbGoTop()
ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	
	_nCusto := 0.00
	_cImpre := Posicione("SC6",1,CAD->C5_FIL+CAD->C5_NUM,"C6_IMPRE")
    _lEstoq := _lCred := _lFatur := _lPreco := _lConf := .t.       
    _lCfo := .f.
    _cLiberador := ""
    _cContrato  := ""    
    _cCFO := ""
    
    DbSelectArea('SC9')
    DbSetOrder(1)
    If dbSeek(CAD->C5_FIL+CAD->C5_NUM)
	    // Liberador do Pedido
	    _cLiberador := SC9->C9_BLPRE

    	While SC9->(!Eof()) .AND. SC9->C9_FILIAL == CAD->C5_FIL .AND. SC9->C9_PEDIDO == CAD->C5_NUM
            
    	    If !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST # '10'
    	    	_lEstoq := .f.
    	    Endif
    	    
     	    If !Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED # '10'
    	       _lCred := .f.
    	    Endif
    	    
    	    If Empty(SC9->C9_BLPRE)
    	       _lPreco := .f.
    	    Endif     
    	    
            If !Empty(SC9->C9_BLCONF)
               _lConf := .f.
            Endif

            If !Empty(SC9->C9_NFISCAL)
               _lFatur := .f.
            Endif   
            
            _cNada := Posicione("SC6",2,CAD->C5_FIL+SC9->C9_PRODUTO+CAD->C5_NUM,"C6_NUM")
            
            _nCusto += (Posicione("LH7",1,xFilial("LH7")+SC9->C9_PRODUTO,"LH7_PRC") * SC9->C9_QTDLIB)            
            
		    _cCFO := RTRIM(SC6->C6_CF)
		    
            If RIGHT(RTRIM(SC6->C6_CF),3) $ "102,114,119,108,922"
               _lCfo := .t.                         
			ElseIf SC6->C6_CLI $ _cEmpresas 
				If .Not. RIGHT(RTRIM(SC6->C6_CF),3) $ "102,114,119,108,922"
   			       _lCfo := .t.                         
   				Endif
            Endif
            
            SC9->(dbSkip(1))
		End
    Else
	    _lEstoq := _lCred := _lFatur := _lPreco := _lConf := .t.
    Endif
	
    // Parametro de Filtro de Situacao

	If MV_PAR05 == 2 .And. CAD->C9_TIP # 'RET' // Retira
		Cad->(dbSkip(1));Loop
	ElseIf MV_PAR05 == 3 .And. CAD->C9_TIP == 'RET' // Entrega
		Cad->(dbSkip(1));Loop
	ElseIf MV_PAR05 == 4 .And. _lFatur               // Faturados
		Cad->(dbSkip(1));Loop
	ElseIf MV_PAR05 == 5 .And. _lEstoq .And. _lCred .And. _lPreco // Bloqueados
		Cad->(dbSkip(1));Loop
	Endif	                                   
	              
	If SUA->(DbSeek(CAD->C5_FIL+CAD->C5_NUM))
		If !Empty(Posicione('SA1',1,xFilial('SA1')+SUA->UA_CLIENTE,'A1_GRUPOAT'))
			If !Empty(MV_PAR06)
				If MV_PAR06 <> SA1->A1_GRUPOAT
					CAD->(DbSkip())
					Loop
				Endif
			Endif
		Else
			If SU7->(DbSeek(xFilial('SU7')+SUA->UA_OPERADO))	
				If !Empty(MV_PAR06)
					If SU7->U7_POSTO <> MV_PAR06
						CAD->(DbSkip())
						Loop
					Endif
				Endif
			Endif
		Endif
	Endif
    // Se o pedido ja foi faturado e a emissao nao e a mesma da ultima data nao traz.
	
	If  !_lFatur 
		_dEmissao := Posicione("SD2",8,CAD->C5_FIL+CAD->C5_NUM,"D2_EMISSAO")
		If DTOS(_dEmissao) <> DTOS(MV_PAR02) 
		   Cad->(dbSkip(1));Loop
		Endif
	Endif
	
// Se a nota fiscal nao possuir cfo aceitavel pula registro

	If !_lCfo 
	   Cad->(dbSkip(1));Loop
	Endif

	RecLock("TC9",.T.)
    For _nX := 1 To Len(aFields)
        If Alltrim(aFields[_nX,1])$'C5_NUM C5_FIL A1_NOME C9_TIP C9_VLR C9_MRG'
           If aFields[_nX,2] = 'C'
              _cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
           Else
              _cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]                                                                
           Endif   
           _cX := &_cX           
        Endif                                                                                 
    Next            
    
    _cContrato  := Iif(T_BuscaValCon(SC6->C6_CLI, ""),"S"," ")             
    
	TC9->C9_BLQ := IIf(_lEstoq,' ','E') + Iif(_lCred,' ','C') + Iif(_lPreco,' ','P')
	TC9->C9_SEP := Iif(!Empty(_cImpre),'S',' ')
	TC9->C9_CNF := Iif(_lConf,' ','C')
	TC9->C9_FAT := Iif(_lFatur,' ','F') 
	TC9->C9_EMI := Posicione("SC5",1,xfilial("SC5")+CAD->C5_NUM,"SC5->C5_EMISSAO")
	TC9->C9_VND := Left(Posicione("SA3",1,xfilial("SA3")+SC5->C5_VEND1,"SA3->A3_NOME"),20)
	TC9->C9_NOT := SC5->C5_NOTA     
	TC9->C9_CUS := _nCusto   
	TC9->C9_LIB := _cLiberador
	TC9->C9_CFO := _cCFO
	TC9->C9_EST := Iif(!Empty(SC5->C5_ESTE),SC5->C5_ESTE,Posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE,"SA1->A1_ESTE"))
	TC9->C9_CTR := _cContrato
	TC9->C9_FIL := CAD->C5_FIL
	MsUnLock()	

    // Pedidos
    _aContadores[1,1] := _aContadores[1,1] + 1
    _aContadores[1,2] += SC5->C5_VOLUME1
    _aContadores[1,3] += SC5->C5_PBRUTO
    _aContadores[1,4] += TC9->C9_VLR
    _aContadores[1,5] += TC9->C9_CUS
    
    If TC9->C9_TIP == 'RET'
    	// Retira
	    _aContadores[2,1] := _aContadores[2,1] + 1
    	_aContadores[2,2] += SC5->C5_VOLUME1
	    _aContadores[2,3] += SC5->C5_PBRUTO
    	_aContadores[2,4] += TC9->C9_VLR
    	_aContadores[2,5] += TC9->C9_CUS    
    Endif
    
    If TC9->C9_TIP # 'RET'
    	// Entregas
	    _aContadores[3,1] := _aContadores[3,1] + 1
    	_aContadores[3,2] += SC5->C5_VOLUME1
	    _aContadores[3,3] += SC5->C5_PBRUTO
    	_aContadores[3,4] += TC9->C9_VLR
    	_aContadores[3,5] += TC9->C9_CUS    
    Endif

    If !Empty(TC9->C9_BLQ)
    	// Bloqueados
	    _aContadores[4,1] := _aContadores[4,1] + 1
    	_aContadores[4,2] += SC5->C5_VOLUME1
	    _aContadores[4,3] += SC5->C5_PBRUTO
    	_aContadores[4,4] += TC9->C9_VLR
    	_aContadores[4,5] += TC9->C9_CUS    
    Endif                                   

    If _cContrato == "S"
    	// Contratos
	    _aContadores[5,1] := _aContadores[5,1] + 1
    	_aContadores[5,2] += SC5->C5_VOLUME1
	    _aContadores[5,3] += SC5->C5_PBRUTO
    	_aContadores[5,4] += TC9->C9_VLR
    	_aContadores[5,5] += TC9->C9_CUS    
    Endif                                   

    If !Empty(TC9->C9_SEP) .And. Empty(TC9->C9_CNF)
    	// Separacao
	    _aContadores[6,1] := _aContadores[6,1] + 1
    	_aContadores[6,2] += SC5->C5_VOLUME1
	    _aContadores[6,3] += SC5->C5_PBRUTO
    	_aContadores[6,4] += TC9->C9_VLR    
    	_aContadores[6,5] += TC9->C9_CUS    
    Endif                                   

    If !Empty(TC9->C9_CNF)  .And. Empty(TC9->C9_FAT)
    	// Conferidos
	    _aContadores[7,1] := _aContadores[7,1] + 1
    	_aContadores[7,2] += SC5->C5_VOLUME1
	    _aContadores[7,3] += SC5->C5_PBRUTO
    	_aContadores[7,4] += TC9->C9_VLR
    	_aContadores[7,5] += TC9->C9_CUS    
    Endif                                   

    If !Empty(TC9->C9_FAT)
    	// Faturados
	    _aContadores[8,1] := _aContadores[8,1] + 1
    	_aContadores[8,2] += SC5->C5_VOLUME1
	    _aContadores[8,3] += SC5->C5_PBRUTO
    	_aContadores[8,4] += TC9->C9_VLR
    	_aContadores[8,5] += TC9->C9_CUS    
    Endif                                   

	CAD->(dBSkip())
EndDo
Dbselectarea("CAD")                  
DbCloseArea()
Dbselectarea("TC9")                  
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:="C5_NUM"
Indregua("TC9",_cIndex,_cChave,,,STR0047) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTA05B2   บAutor  ณMicrosiga           บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FTA05B2()

SC5->(DBSETORDER(1))
If !SC5->(DbSeek(xFilial("SC5")+TC9->C5_NUM,.f.))
   msgbox(STR0048) //"Registro nao localizado na tabela [Cabecalho de pedidos de venda]"
   Return
EndIf      

_cVend   :=SC5->C5_VEND1 
_dEmissao:=SC5->C5_EMISSAO
If !Empty(Posicione("SUA",8,SC5->C5_FILIAL+SC5->C5_NUM,"UA_NUM"))
   T_TTMK4V(SUA->UA_FILIAL+SUA->UA_NUM,"SUA",.F.)
Else
   T_TTMK4V(SC5->C5_FILIAL+SC5->C5_NUM,"SC5",.F.)
EndIf  
Return