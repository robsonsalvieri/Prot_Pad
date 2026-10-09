#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "plsr407.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR407   บAutor  ณ TOTVS              บ Data ณ  18/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emite Relat๓rio de Provisใo de Perdas Sobre Cr้ditos.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Plano de Saude                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function PLSR407() 

Local oReport
Local cPerg   := "PLR407"

Pergunte(cPerg,.F.)

If EMPTY(mv_par11)
	mv_par11 := dDataBase
EndIf

oReport := ReportDef()
oReport:PrintDialog() //Tela com botใo de parametros
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณReportDef บAutor  ณ TOTVS              บ Data ณ  18/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Plano de Saude                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportDef()

Local oReport
Local oSection1,oSection2
Local oCell
Local oTotaliz
Local cTitulo1	:= STR0001//"Relat๓rio de Provisใo de Perdas Sobre Cr้ditos"
Local cTitulo2	:= STR0002//"Este programa ira emitir o relat๓rio de provisใo de perdas sobre cr้ditos."
Local dDtVenct	:= CToD("")

oReport := TReport():New("PLSR407",cTitulo1,"PLR407", {|oReport| R407IMP(oReport)},cTitulo2)
oReport:SetLandscape() 							 				// Imprimir relat๓rio em formato paisagem
oReport:SetCustomText( {|| Cabec407( oReport )} ) 

oSection1 := TRSection():New(oReport,STR0003, {"SE1"},{STR0004})//"Titulos"  "Cliente + Loja + Prefixo + No. Titulo + Parcela + Tipo"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina
oSection1:SetHeaderSection(.F.) 	//Indica se cabecalho da secao sera impresso (padrao)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oCell := TRCell():New(oSection1,"cCliLoja",,STR0005	,,30,,{||cCliLoja:=STR0006	+TrbR407->(E1_CLIENTE)+"-"+TrbR407->(E1_LOJA)}) //"Cliente"  "Cliente: "
oCell := TRCell():New(oSection1,"cNomeCli",,STR0007		,,30,,{||cNomeCli:=STR0008		+TrbR407->(A1_NOME)})//"Nome"   "Nome: "
oCell := TRCell():New(oSection1,"cCPFCNPJ",,STR0009	,,30,,{||cCPFCNPJ:=STR0010	+IIF(TrbR407->(A1_PESSOA)=="F",Transform(TrbR407->(A1_CGC),StrTran(PicCpfCnpj("","F"),"%C","")),Transform(TrbR407->(A1_CGC),StrTran(PicCpfCnpj("","J"),"%C","")))}) //"CPF/CNPJ"     "CPF/CNPJ: "
oCell := TRCell():New(oSection1,"cMunicip",,STR0011		,,30,,{||cMunicip:=STR0012	+TrbR407->(A1_MUN)})  //"Mun"   "Cidade: "
oCell := TRCell():New(oSection1,"cSiglaUF",,STR0013		,,30,,{||cSiglaUF:=STR0014	+TrbR407->(A1_EST)}) //"Est"    "Estado: "


oSection2 := TRSection():New(oSection1,STR0015,{"TrbR407"})//"Tํtulos de Cliente"
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Contrato                                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oCell := TRCell():New(oSection2,"BA3_CODINT","TrbR407",,,10) 		//"BA3_CODINT"
oCell := TRCell():New(oSection2,"BA3_CODEMP","TrbR407",,,10) 		//"BA3_CODEMP"
oCell := TRCell():New(oSection2,"BA3_MATRIC","TrbR407",,,10) 		//"BA3_MATRIC"
oCell := TRCell():New(oSection2,"BA3_CONEMP","TrbR407",,,15) 		//"BA3_CONEMP"
oCell := TRCell():New(oSection2,"BA3_SUBCON","TrbR407",,,15) 		//"BA3_SUBCON"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Titulos                                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oCell := TRCell():New(oSection2,"E1_NUM","TrbR407",,,15) 	  		//"Documento"
oCell := TRCell():New(oSection2,"cPrefix","TrbR407",STR0016,,07,,{||cPrefix := TrbR407->(E1_PREFIXO)}) //"Pref."
oCell := TRCell():New(oSection2,"cParcel","TrbR407",STR0017,,07,,{||cParcel := TrbR407->(E1_PARCELA)}) //"Parc."

oCell := TRCell():New(oSection2,"dDtEmissao","TrbR407",STR0018,,13,,{||dDtEmissao := IIf(mv_par10==1,TrbR407->(E1_EMISSAO)," ")}) 	   			//"Dt Emissใo"
If mv_par13 == 1
	oCell := TRCell():New(oSection2,"dDtVenct","TrbR407",STR0019,,13,,{||dDtVenct := IIf(mv_par10==1,TrbR407->(E1_VENCREA)," ")}) 	//"Dt Vencimento Real"
Else
	oCell := TRCell():New(oSection2,"dDtVenct","TrbR407",STR0019,,13,,{||dDtVenct := IIf(mv_par10==1,TrbR407->(E1_VENCTO)," ")}) 	//"Dt Vencimento Real"   "Dt. Vencto"
EndIf
oCell := TRCell():New(oSection2,"dDtBaixa","TrbR407",STR0020,,13,,{||dDtBaixa := IIf(mv_par10==1,TrbR407->(E1_BAIXA)," ")}) 					//"Dt Baixa"
oCell := TRCell():New(oSection2,"nDiasAtr","TrbR407",STR0021,,07,,{||nDiasAtr := PR407Atr(TrbR407->E1_STATUS,TrbR407->E1_SALDO,dDtVenct)}) //"Atraso"

oCell := TRCell():New(oSection2,"E1_VALOR","TrbR407",,,14)	   		//"Valor do Titulo"
oCell := TRCell():New(oSection2,"E1_DESCONT","TrbR407",,,14)	  	//"Desconto"
oCell := TRCell():New(oSection2,"E1_VALLIQ","TrbR407",,,14)		//"Valor Pago"
oCell := TRCell():New(oSection2,"E1_SALDO","TrbR407",,,14)			//"Saldo do Titulo"

oCell := TRCell():New(oSection2,"cStatus","TrbR407",STR0022,,15,,{||cStatus := IIF(mv_par10<>1," ",IIF(TrbR407->(E1_STATUS)=="B" .OR. TrbR407->(E1_SALDO)==0,"Baixado","Em Aberto"))}) //"Status"

oTotaliz := TRFunction():new(oSection2:Cell("E1_VALOR")	,,"SUM",,STR0023	,"@E 999,999,999.99") 	//"Total Titulos"
oTotaliz := TRFunction():new(oSection2:Cell("E1_DESCONT")	,,"SUM",,STR0024	,"@E 999,999,999.99") 	//"Tot. Desconto"
oTotaliz := TRFunction():new(oSection2:Cell("E1_VALLIQ")	,,"SUM",,STR0025	,"@E 999,999,999.99") 	//"Tot. de Baixa"
oTotaliz := TRFunction():new(oSection2:Cell("E1_SALDO")	,,"SUM",,STR0026	,"@E 999,999,999.99")	//"Tot. do Saldo"


Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPR407Atr  บAutor  ณ TOTVS              บ Data ณ  18/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna os dias de atrasos dos tํtulos                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Plano de Saude                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PR407Atr(cStatus,nSaldo,dDtVenct)
Local nDias := 0 

IF !(cStatus == "B" .AND. nSaldo == 0)

	mv_par11 := IIF(EMPTY(mv_par11),dDataBase,mv_par11)
	
	If mv_par10 == 1 	// Analitico
		nDias := mv_par11-dDtVenct
	Else
		nDias := " " 	// Para sintetico nao sera possivel calcular os atrasos
	EndIf

EndIf

Return (nDias)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณR407IMP   บAutor  ณ TOTVS              บ Data ณ  18/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Relat๓rio de Provisใo de Perdas Sobre Cr้ditos.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function R407IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cPFPJAMB 	:= ""
Local cOrder	:= ""
Local cDtVencto	:= ""
Local cQrySE1_1	:= ""
Local cQrySE1_2	:= ""
Local cQryCampo	:= ""
Local cQryGroup	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Complemento da query para os campos necessarios                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par10 == 1 // Analitico
	cQryCampo	:= "% " 
	cQryCampo	+= "SE1.E1_CODINT ,SE1.E1_CODEMP ,SE1.E1_MATRIC ,SE1.E1_CONEMP ,"
	cQryCampo	+= "SE1.E1_VERCON ,SE1.E1_SUBCON ,SE1.E1_VERSUB ,"
	cQryCampo	+= "SE1.E1_CLIENTE ,SE1.E1_LOJA ,BBT.BBT_NIVEL ,SE1.E1_STATUS ,"
	cQryCampo	+= "SE1.E1_EMISSAO ,SE1.E1_VENCTO ,SE1.E1_VENCREA ,SE1.E1_BAIXA ,"
	cQryCampo	+= "SE1.E1_VALOR ,SE1.E1_VALLIQ ,SE1.E1_DESCONT ,SE1.E1_SALDO ,"
	cQryCampo	+= "SE1.E1_PREFIXO ,SE1.E1_NUM ,SE1.E1_PARCELA ,SE1.E1_TIPO ,"
	cQryCampo	+= "SA1.A1_NOME ,SA1.A1_PESSOA ,SA1.A1_CGC ,SA1.A1_MUN ,SA1.A1_EST ,"
	cQryCampo	+= "BA3.BA3_CODINT ,BA3.BA3_CODEMP ,BA3.BA3_MATRIC ,"
	cQryCampo	+= "BA3.BA3_CONEMP ,BA3.BA3_VERCON ,BA3.BA3_SUBCON ,BA3.BA3_VERSUB" 
	cQryCampo 	+= " %"
Else
	cQryCampo	:= "% " 
	cQryCampo	+= "' ' E1_CODINT,' ' E1_CODEMP,' ' E1_MATRIC,' ' E1_CONEMP,"
	cQryCampo	+= "' ' E1_VERCON,' ' E1_SUBCON,' ' E1_VERSUB,"
	cQryCampo	+= "SE1.E1_CLIENTE E1_CLIENTE,SE1.E1_LOJA E1_LOJA,' ' BBT_NIVEL,' ' E1_STATUS,"
	cQryCampo	+= "' ' E1_EMISSAO,' ' E1_VENCTO,' ' E1_VENCREA,' ' E1_BAIXA,"
	cQryCampo	+= "SUM(SE1.E1_VALOR) E1_VALOR,SUM(SE1.E1_VALLIQ) E1_VALLIQ,SUM(SE1.E1_DESCONT) E1_DESCONT,SUM(SE1.E1_SALDO) E1_SALDO,"
	cQryCampo	+= "' ' E1_PREFIXO,' ' E1_NUM,' ' E1_PARCELA,' ' E1_TIPO,"
	cQryCampo	+= "SA1.A1_NOME A1_NOME,SA1.A1_PESSOA A1_PESSOA,SA1.A1_CGC A1_CGC,SA1.A1_MUN A1_MUN,SA1.A1_EST A1_EST,"
	cQryCampo	+= "BA3.BA3_CODINT BA3_CODINT,BA3.BA3_CODEMP BA3_CODEMP,BA3.BA3_MATRIC BA3_MATRIC,"
	cQryCampo	+= "BA3.BA3_CONEMP BA3_CONEMP,BA3.BA3_VERCON BA3_VERCON,BA3.BA3_SUBCON BA3_SUBCON,BA3.BA3_VERSUB BA3_VERSUB"
	cQryCampo 	+= " %"
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Complemento da query para o vencimento a partir da data de referencia   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mv_par11 	:= IIF(EMPTY(mv_par11),dDataBase,mv_par11)
cDtVencto	:= "% " 
If mv_par13 == 1  // Vencimento Real ou Vencimento
	cDtVencto	+= "SE11.E1_VENCREA <= " + DToS(mv_par11 - IIF(EMPTY(mv_par12),0,Val(mv_par12)))
Else
	cDtVencto	+= "SE11.E1_VENCTO <= "  + DToS(mv_par11 - IIF(EMPTY(mv_par12),0,val(mv_par12)))
EndIf
cDtVencto 	+= " %"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Transforma parametros Range em expressao SQL                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr(oReport:uParam)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Complemento da query para definir a busca de todos os contratos do      ณ
//ณ cliente ou apenas o contrato do titulo inadimplente em questใo          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par14 == 1 	// Apenas o contrato do titulo inadimplente em questใo 
	cQrySE1_1 := "% SE1.E1_CLIENTE||SE1.E1_LOJA||SE1.E1_CODINT||SE1.E1_CODEMP||SE1.E1_MATRIC||SE1.E1_CONEMP||SE1.E1_VERCON||SE1.E1_SUBCON||SE1.E1_VERSUB %"
	cQrySE1_2 := "% SE11.E1_CLIENTE||SE11.E1_LOJA||SE11.E1_CODINT||SE11.E1_CODEMP||SE11.E1_MATRIC||SE11.E1_CONEMP||SE11.E1_VERCON||SE11.E1_SUBCON||SE11.E1_VERSUB %"
Else				// Todos os contratos do cliente
	cQrySE1_1 := "% SE1.E1_CLIENTE||SE1.E1_LOJA %"
	cQrySE1_2 := "% SE11.E1_CLIENTE||SE11.E1_LOJA %"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Complemento da query para regra Pessoa Fํsica ou Juridica ou Ambos      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPFPJAMB := "% "
If mv_par01 == 1		// Fisica
	cPFPJAMB += "     BA3.BA3_CONEMP =  '"+ Space(TamSx3("BA3_CONEMP")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_VERCON =  '"+ Space(TamSx3("BA3_VERCON")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_SUBCON =  '"+ Space(TamSx3("BA3_SUBCON")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_VERSUB =  '"+ Space(TamSx3("BA3_VERSUB")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_MATRIC <> '"+ Space(TamSx3("BA3_MATRIC")[1]) +"'"
	cPFPJAMB += " AND BBT.BBT_NIVEL >= '4' "	
ElseIf mv_par01 == 2	// Juridica
	cPFPJAMB += "     BA3.BA3_CONEMP <> '"+ Space(TamSx3("BA3_CONEMP")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_VERCON <> '"+ Space(TamSx3("BA3_VERCON")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_SUBCON <> '"+ Space(TamSx3("BA3_SUBCON")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_VERSUB <> '"+ Space(TamSx3("BA3_VERSUB")[1]) +"'"
	cPFPJAMB += " AND BA3.BA3_MATRIC <> '"+ Space(TamSx3("BA3_MATRIC")[1]) +"'"
	
	cPFPJAMB += "	AND ("
	cPFPJAMB += "	(SE1.E1_CONEMP =  '"   + Space(TamSx3("E1_CONEMP")[1]) +"' "
	cPFPJAMB += " 	AND SE1.E1_SUBCON =  '"+ Space(TamSx3("E1_SUBCON")[1]) +"' "
	cPFPJAMB += "  	AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "
	cPFPJAMB += "  	AND BBT.BBT_NIVEL <= '1') "
	cPFPJAMB += "  	OR "
	cPFPJAMB += "  	(SE1.E1_CONEMP >= '"   + mv_par06  +"' "
	cPFPJAMB += "  	AND SE1.E1_CONEMP <= '"+ mv_par07  +"' "
	cPFPJAMB += " 	AND SE1.E1_SUBCON =  '"+ Space(TamSx3("E1_SUBCON")[1]) +"' "
	cPFPJAMB += "  	AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "
	cPFPJAMB += "  	AND BBT.BBT_NIVEL <= '2') "
	cPFPJAMB += "  	OR "
	cPFPJAMB += "  	(SE1.E1_CONEMP >= '"   + mv_par06  +"' "
	cPFPJAMB += "  	AND SE1.E1_CONEMP <= '"+ mv_par07  +"' "
	cPFPJAMB += " 	AND SE1.E1_SUBCON >= '"+ mv_par08  +"' "
	cPFPJAMB += " 	AND SE1.E1_SUBCON <= '"+ mv_par09  +"' "
	cPFPJAMB += "  	AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "
	cPFPJAMB += "  	AND BBT.BBT_NIVEL <= '3') "
	cPFPJAMB += "  	OR "
	cPFPJAMB += " 	(SE1.E1_CONEMP = '"    + Space(TamSx3("E1_CONEMP")[1]) +"' "
	cPFPJAMB += " 	AND SE1.E1_VERCON  = '"+ Space(TamSx3("E1_VERCON")[1]) +"' "
	cPFPJAMB += "	AND SE1.E1_SUBCON  = '"+ Space(TamSx3("E1_SUBCON")[1]) +"' "
	cPFPJAMB += "	AND SE1.E1_VERSUB  = '"+ Space(TamSx3("E1_VERSUB")[1]) +"' "
	cPFPJAMB += "	AND SE1.E1_MATRIC <> '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "
	cPFPJAMB += "	AND BBT.BBT_NIVEL >= '4') "
	cPFPJAMB += "	) "
Else
	cPFPJAMB += "	SE1.D_E_L_E_T_= ' ' " // Gen้rico para preencher a variแvel
EndIf
cPFPJAMB += " %"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Complemento da query para definir a ordem                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par10 == 1 	// Analitico
	cQryGroup 	:= cQryCampo
	cOrder		:= "% SE1.E1_CODINT,SE1.E1_CODEMP,SE1.E1_MATRIC,SE1.E1_CONEMP,SE1.E1_VERCON,SE1.E1_SUBCON,SE1.E1_VERSUB,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VENCREA %"
Else				// Sintetico
	cQryGroup 	:= "% SE1.E1_CLIENTE,SE1.E1_LOJA,SA1.A1_NOME,SA1.A1_PESSOA,SA1.A1_CGC,SA1.A1_MUN,SA1.A1_EST,BA3.BA3_CODINT,BA3.BA3_CODEMP,BA3.BA3_MATRIC,BA3.BA3_CONEMP,BA3.BA3_VERCON,BA3.BA3_SUBCON,BA3.BA3_VERSUB %"
	cOrder		:= "% SE1.E1_CLIENTE,SE1.E1_LOJA %"
EndIf

oSection1:BeginQuery()
BeginSql alias "TrbR407"

SELECT %Exp:cQryCampo%
	FROM %table:SE1% SE1 
	JOIN %table:BBT% BBT ON BBT.BBT_FILIAL = %xFilial:BBT% AND BBT.%NotDel%  
 						AND BBT.BBT_CODOPE = SE1.E1_CODINT
 						AND BBT.BBT_CODEMP = SE1.E1_CODEMP
 						AND BBT.BBT_CONEMP = SE1.E1_CONEMP
        				AND BBT.BBT_VERCON = SE1.E1_VERCON
                   	  	AND BBT.BBT_SUBCON = SE1.E1_SUBCON
                   	  	AND BBT.BBT_VERSUB = SE1.E1_VERSUB
                     	AND BBT.BBT_MATRIC = SE1.E1_MATRIC
                     	AND BBT.BBT_PREFIX = SE1.E1_PREFIXO
                     	AND BBT.BBT_NUMTIT = SE1.E1_NUM
                     	AND BBT.BBT_PARCEL = SE1.E1_PARCELA
                     	AND BBT.BBT_TIPTIT = SE1.E1_TIPO
	JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel%  
 						AND SA1.A1_COD     = SE1.E1_CLIENTE
 						AND SA1.A1_LOJA    = SE1.E1_LOJA
	JOIN %table:BA3% BA3 ON BA3.BA3_FILIAL = %xFilial:BA3% AND BA3.%NotDel%  
 						AND BA3.BA3_CODINT    = BBT.BBT_CODOPE
 						AND BA3.BA3_CODEMP    = BBT.BBT_CODEMP
 						AND BA3.BA3_MATRIC    = BBT.BBT_MATRIC
	WHERE SE1.E1_FILIAL = %xFilial:SE1% AND SE1.%NotDel%  
	   AND (BA3.BA3_CODINT >= %Exp:mv_par02%)
	   AND (BA3.BA3_CODINT <= %Exp:mv_par03%)
	   AND (BA3.BA3_CODEMP >= %Exp:mv_par04%)
	   AND (BA3.BA3_CODEMP <= %Exp:mv_par05%)
	   AND %Exp:cPFPJAMB%  		// Regra de pessoa Fisica ou Juridica
       
	   AND %Exp:cQrySE1_1%
	   IN (
	   		SELECT %Exp:cQrySE1_2%
			FROM %table:SE1% SE11 
			WHERE SE11.E1_STATUS = 'A' AND SE11.E1_SALDO > 0 AND SE11.D_E_L_E_T_ = ' '
			AND %Exp:cDtVencto%
		)
   GROUP BY %Exp:cQryGroup%	   
   ORDER BY %Exp:cOrder%
EndSql

oSection1:EndQuery()

oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G|("TrbR407")->E1_CLIENTE+("TrbR407")->E1_LOJA == G }, {||("TrbR407")->E1_CLIENTE+("TrbR407")->E1_LOJA} ) 

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(TrbR407->(LastRec()))

	 
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cabec407 บAutor  ณ TOTVS              บ Data ณ  18/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCustomiza o cabecalho do relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Plano de Saude                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Cabec407( oReport )
Local aArea		:= GetArea()
Local aCabec	:= {}
Local cChar		:= chr(160)  // caracter dummy para alinhamento do cabe็alho
 
iif(SM0->(Eof()),SM0->( MsSeek( cEmpAnt + cFilAnt , .T. )),nil)

aCabec := {	"__LOGOEMP__" , cChar + "            " ;
	      + "            " + cChar + RptFolha + TRANSFORM(oReport:Page(),'9999');
          , cChar + "            " ;
          + "            " + cChar ;
          , "SIGA /" + 'PLSR407' + " /v." + cVersao ; 
          + "            " + cChar + UPPER( oReport:CTITLE + IIF(mv_par10 == 1,STR0027,STR0028) ) ; // " - Analํtico"  " - Sint้tico"
          + "            " + cChar;
          , RptHora + " " + time() ;
          + "            " + cChar + RptEmiss + " " + Dtoc(dDataBase),;
          + (STR0029 +Trim(SM0->M0_NOME) + "/" + STR0053 + Trim(SM0->M0_FILIAL));//"Empresa:"  "Filial:"
          , cChar + "            "}

RestArea( aArea )
              
Return aCabec
