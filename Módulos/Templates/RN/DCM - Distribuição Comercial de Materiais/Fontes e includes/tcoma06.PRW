#INCLUDE "TCOMA06.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA06   บAutor  ณVendas Clientes     บ Data ณ  24/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula o consumo mensal das lojas.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            
Template Function TCOMA06()

CHKTEMPLATE("DCM")  

MsAguarde({|| Executa()} ,STR0001,STR0002,.T.) //"Aguarde"###"Calculando Consumo Medio."

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecuta   บAutor  ณVendas Clientes     บ Data ณ  24/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a tabela LFW                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Executa
Local _DataIni	:= Ctod("01/"+Str(Month(dDataBase))+"/"+Str(Year(dDataBase)))
Local _Dia			:= 31
Local _DataFim	:= Ctod(Str(_Dia)+"/"+Str(Month(dDataBase))+"/"+Str(Year(dDataBase)))
Local cMesAtu		:= Alltrim(StrZero(Month(dDataBase),2))
Local cAnoAtu		:= Alltrim(Str(Year(dDataBase),4))
Local cD2_CF		:= " AND SUBSTRING(D2_CF,2,3) IN "
Local cMV_CFRELS	:= SuperGetMv('MV_CFRELS',.F.,"'12','102','108','904'")	//Conteudo do parameteo MV_CFRELS
Local _nConsu		:= 0
Local cFilAnt		:= ""
Local cProdAnt	:= ""

While Day(_datafim)<=0
	_Dia -= 1
	_DataFim := Ctod(Str(_Dia)+"/"+Str(Month(dDataBase))+"/"+Str(Year(dDataBase)))
	Loop
EndDo

_DataIni := Dtos(_DataIni)
_DataFim := Dtos(_DataFim)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta o filtro dos registros       
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("SD2")
// Monta Query
_cQuery := "SELECT D2_FILIAL, D2_COD, D2_QUANT FROM "+RETSQLNAME('SD2')+" SD2 "
_cQuery += " WHERE SD2.D2_EMISSAO>='"+_DataIni+"' AND SD2.D2_EMISSAO<='"+_DataFim+"' "
_cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
_cQuery += " AND D2_TIPO = 'N' "
_cQuery += cD2_CF +" (" +cMV_CFRELS+ ")" +" "
_cQuery += " ORDER BY D2_FILIAL,D2_COD"

// Verifica se o Arquivo esta em uso, caso esteja fecha antes de montar a nova Query

If Select("CON") > 0
	DbSelectArea("CON")
	DbCloseArea()
Endif

TCQUERY _cQuery NEW ALIAS "CON"
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia o calculo do consumo mensal por produto
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("CON")
DbGotop()
While CON->(! Eof())
	cFilAnt	:= CON->D2_FILIAL
	cProdAnt	:= CON->D2_COD
	_nConsu	:= 0
	While CON->(! Eof()) .AND. CON->D2_FILIAL == cFilAnt .AND. CON->D2_COD == cProdAnt
		_nConsu += CON->D2_QUANT
		DbSelectArea("CON")
		DbSkip()
	EndDo
	DbSelectArea("LFW")
	DbSetOrder(1)
	If !DbSeek(xFilial("LFW")+cProdAnt+cAnoAtu+cMesAtu)
		RecLock("LFW",.T.)
		LFW->LFW_LOJA    := cFilAnt
		LFW->LFW_PRODUT  := cProdAnt
		LFW->LFW_QUANT   := _nConsu
		LFW->LFW_ANO     := cAnoAtu
		LFW->LFW_MES     := cMesAtu
		LFW->(MsUnLock())
	Else
		RecLock("LFW",.F.)
		LFW->LFW_QUANT   := _nConsu
		LFW->(MsUnLock())
	Endif
	DbSelectArea("CON")
EndDo
Return Nil