#include "ofir250.ch"
#include "protheus.ch"

/*/{Protheus.doc} ofir250
Este relatório possibilita a visualização das vendas e do resultado obtido. Pode-se imprimir desde um resumo, até um relatório detalhado, podendo enxergar, se necessário, o resultado de cada venda efetuada dentro do período desejado.
@type function
@author André Cruz
@since 10/10/2023
@version 1.0
/*/

function ofir250()
private cPerg := "OFIR250" as character

	Pergunte(cPerg, .f.)

	oReport := ReportDef()
	oReport:PrintDialog()

return nil

static function ReportDef()
local oReport := TReport():New("OFIR250", STR0001, cPerg,{|oReport| ReportPrint(oReport)}, STR0002) as object // "Relatório de Vendas e Resultado" ### "Esse relatório possibilita a visualização das vendas e do resultado obtido."
local oSecCabec := nil as object
local oSecLinha := nil as object

oSecCabec := TRSection():New(oReport, STR0017) // "Origem"
TRCell():New(oSecCabec, "AGRUP", "", "",        ,                          20,, {|| cDescGrupo}                                 ,,,       ,.t.) // imprime a descrição do grupo

oSecLinha := TRSection():New(oReport, STR0018) // "Totais"

TRCell():New(oSecLinha, "DESCR", "", STR0003, "",                          50,, {|| cDesc}                                      ,,,       ,.t.) // "Descrição"
TRCell():New(oSecLinha, "VALOR", "", STR0004, "@E 999,999,999,999,999.99", 15,, {|| nValor}                                     ,,,"RIGHT",.t.) // "Valor"
TRCell():New(oSecLinha, "CUSTO", "", STR0005, "@E 999,999,999,999,999.99", 15,, {|| nCusto}                                     ,,,"RIGHT",.t.) // "Custo"
TRCell():New(oSecLinha, "IMPOS", "", STR0006, "@E 999,999,999,999,999.99", 15,, {|| nImposto}                                   ,,,"RIGHT",.t.) // "Impostos"
TRCell():New(oSecLinha, "LUCRO", "", STR0007, "@E 999,999,999,999,999.99", 15,, {|| nValor - nImposto - nCusto}                 ,,,"RIGHT",.t.) // "Lucro Bruto"
TRCell():New(oSecLinha, "PERLU", "", STR0008, "@E 999,999.99"            , 15,, {|| (nValor - nImposto - nCusto) / nValor * 100},,,"RIGHT",.t.) // "% Lucro Bruto"

TRFunction():New(oSecLinha:Cell("VALOR"), NIL, "SUM")   
TRFunction():New(oSecLinha:Cell("CUSTO"), NIL, "SUM")   
TRFunction():New(oSecLinha:Cell("IMPOS"), NIL, "SUM")   
TRFunction():New(oSecLinha:Cell("LUCRO"), NIL, "SUM")

oSecLinha:SetTotalInLine(.f.)
oReport:SetTotalInLine(.f.)

return oReport

static function ReportPrint(oReport)
local oSecCabec := oReport:Section(1) as object
local oSecLinha := oReport:Section(2) as object
local aData := {} as array
local i := 0 as numeric
local nLen := 0 as numeric

private cPrfOriVei := Alltrim(GetMV("MV_PREFVEI",,"VEI"))
private cPrfOriBal := Alltrim(GetMV("MV_PREFBAL",,"BAL"))
private cPrfOriOfi := Alltrim(GetMV("MV_PREFOFI",,"OFI"))

private cGrupo := "" as character
private cDescGrupo := "" as character
private cDesc := "" as character
private nValor := 0 as numeric
private nCusto := 0 as numeric
private nImposto := 0 as numeric

FWMsgRun(, {|oSay| aData := GetData(oSay) }, STR0009, STR0010) // "Processando" ### "Carregando dados para o relatório..."

nLen := Len(aData)
oReport:SetMeter(nLen)
for i := 1 to nLen

	if cGrupo <> aData[i][1]
		if aData[i][1] == cPrfOriVei
			cDescGrupo := STR0011 // "VEICULOS"
		elseif aData[i][1] == cPrfOriBal
			cDescGrupo := STR0012 // "VENDA BALCAO"
		elseif aData[i][1] == cPrfOriOfi + "-PCS"
			cDescGrupo := STR0013 // "OFICINA - PECAS"
		elseif aData[i][1] == cPrfOriOfi + "-SRV"
			cDescGrupo := STR0014 // "OFICINA - SERVICOS"
		endif
		if !Empty(cGrupo)
			oSecLinha:Finish()
		endif
		cGrupo := aData[i][1]
		oSecCabec:Init()
		oSecCabec:PrintLine()
		oSecCabec:Finish()
		oSecLinha:Init()
	endif

	cDesc := aData[i][2] + "-" + aData[i][3]
	nValor := aData[i][4]   
	nCusto := aData[i][5]
	nImposto := aData[i][6]
	oSecLinha:PrintLine()

	oReport:IncMeter()
	
next

if !Empty(cGrupo)
	oSecLinha:Finish()
endif

return nil

static function GetData(oSay)
local aData := {} as array
local nPos := 0 as integer
local nMoedaDoc := 1 as numeric
local cAlias := GetNextAlias() as character
local cCase := "" as character
local aX3Box := {} as array
local i := 0 as numeric, nLen := 0 as numeric

oSay:SetText(STR0015) // "Carregando dados de vendas de veículos. Aguarde..."

GetSX3Cache("VOI_SITTPO", "X3_CAMPO")
cCBox := X3CBox()

if !Empty(cCBox)
	aX3Box := StrTokArr(cCBox,';')
	nLen := Len(aX3Box)
	cCase := "%case VOI.VOI_SITTPO"
	for i := 1 to nLen
		aX3Box[i] := StrTokArr(aX3Box[i],'=')
		cCase += " when '" + aX3Box[i][1] + "' then '" + aX3Box[i][2] + "' "
	next
	cCase += "end%"
endif

BeginSql alias cAlias

	column F2_EMISSAO as Date

// VENDA TOTAL  (D2_TOTAL)
// CUSTO  (D2_CUSTO1)
// IMPOSTOS      (D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6)
// LUCRO BRUTO   (TOTAL-IMPOSTOS-CUSTO)
// % LUCRO BRUTO (LUCRO BRUTO/TOTAL)*100

//
// Para veículos F2_PREFORI = 'VEI'
// Para veículo quebra por VV1_MODVEI ou F2_CLIENTE+F2_LOJA
// Modelo -> D2_COD->B1_COD|B1_CODITE->VV1_CHAINT
// 

	select SF2.F2_PREFORI
	     , VV1.VV1_CODMAR + '-' + VV1.VV1_MODVEI as AGRUPADOR
		 , trim(VE1.VE1_DESMAR) + '-' + trim(VV2.VV2_DESMOD) as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , sum(D2_TOTAL) as TOTAL
		 , sum(D2_CUSTO1) as CUSTO
		 , sum(D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6) as IMPOSTO
      from %table:SF2% SF2
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
      join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
      join %table:SB1% SB1
        on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
      join %table:VV1% VV1
        on VV1.VV1_FILIAL = %xfilial:VV1%
	   and VV1.VV1_CHAINT = SB1.B1_CODITE
       and VV1.%notDel%
	  join %table:VE1% VE1
	    on VE1.VE1_FILIAL = %xfilial:VE1%
	   and VE1.VE1_CODMAR = VV1_CODMAR
	   and VE1.%notDel%
      join %table:VV2% VV2
	    on VV2.VV2_FILIAL = %xfilial:VV2%
	   and VV2.VV2_CODMAR = VE1.VE1_CODMAR
	   and VV2.VV2_MODVEI = VV1.VV1_MODVEI
	   and VV2.%notDel%
     where SF2.F2_FILIAL  = %xfilial:SF2%
       and SF2.F2_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SF2.F2_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriVei% // 'VEI'
	   and SF2.%notDel%
  group by SF2.F2_PREFORI
	     , VV1.VV1_CODMAR + '-' + VV1.VV1_MODVEI
		 , trim(VE1.VE1_DESMAR) + '-' + trim(VV2.VV2_DESMOD)
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

     union all

// 
// devoluções das notas F2_PREFORI = 'VEI'
// 
//

	select SF2.F2_PREFORI
	     , VV1.VV1_CODMAR + '-' + VV1.VV1_MODVEI as AGRUPADOR
		 , trim(VE1.VE1_DESMAR) + '-' + trim(VV2.VV2_DESMOD) as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , (-1) * sum(D1_TOTAL) as TOTAL
		 , (-1) * sum(D1_CUSTO) as CUSTO
		 , (-1) * sum(D1_VALIMP1+D1_VALIMP2+D1_VALIMP3+D1_VALIMP4+D1_VALIMP5+D1_VALIMP6) as IMPOSTO
      from %table:SD1% SD1
	  join %table:SF2% SF2
        on SF2.F2_FILIAL  = %xfilial:SF2%
       and SF2.F2_DOC     = SD1.D1_NFORI
	   and SF2.F2_SERIE   = SD1.D1_SERIORI
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriVei% // 'VEI'
	   and SF2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
      join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	 
	   and SD2.D2_ITEM    = SD1.D1_ITEMORI
	   and SD2.%notDel%
      join %table:SB1% SB1
        on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
      join %table:VV1% VV1
        on VV1.VV1_FILIAL = %xfilial:VV1%
	   and VV1.VV1_CHAINT = SB1.B1_CODITE
       and VV1.%notDel%
	  join %table:VE1% VE1
	    on VE1.VE1_FILIAL = %xfilial:VE1%
	   and VE1.VE1_CODMAR = VV1_CODMAR
	   and VE1.%notDel%
      join %table:VV2% VV2
	    on VV2.VV2_FILIAL = %xfilial:VV2%
	   and VV2.VV2_CODMAR = VE1.VE1_CODMAR
	   and VV2.VV2_MODVEI = VV1.VV1_MODVEI
	   and VV2.%notDel%
     where SD1.D1_FILIAL  = %xfilial:SD1%
       and SD1.D1_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SD1.D1_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SD1.D1_ESPECIE = 'RFD'
	   and SD1.D1_TIPO    = 'D'
	   and 1              = %exp:MV_PAR05% // Deduz devolucao? [{1=Sim; 2=Não}
	   and SD1.%notDel%
  group by SF2.F2_PREFORI
	     , VV1.VV1_CODMAR + '-' + VV1.VV1_MODVEI
		 , trim(VE1.VE1_DESMAR) + '-' + trim(VV2.VV2_DESMOD)
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

	 union all

//
// Para Balcão: F2_PREFORI = 'BAL'
// Quebra por B1_GRUPO ou F2_CLIENTE+F2_LOJA
// 
//

	select SF2.F2_PREFORI
	     , SB1.B1_GRUPO as AGRUPADOR
		 , SBM.BM_DESC as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , sum(D2_TOTAL) as TOTAL
		 , sum(D2_CUSTO1) as CUSTO
		 , sum(D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6) as IMPOSTO
	  from %table:SF2% SF2
	  join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
	  join %table:SB1% SB1
	    on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
	  join %table:SBM% SBM
	    on SBM.BM_FILIAL  = %xfilial:SBM%
	   and SBM.BM_GRUPO   = SB1.B1_GRUPO
	   and SBM.%notDel%
	 where SF2.F2_FILIAL  = %xfilial:SF2%
	   and SF2.F2_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SF2.F2_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriBal% // 'BAL'
	   and SF2.%notDel%
  group by SF2.F2_PREFORI
	     , SB1.B1_GRUPO
		 , SBM.BM_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

     union all

//
// devoluções das notas F2_PREFORI = 'BAL'
// 
//

 	select SF2.F2_PREFORI
	     , SB1.B1_GRUPO as AGRUPADOR
		 , SBM.BM_DESC as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , (-1) * sum(D1_TOTAL) as TOTAL
		 , (-1) * sum(D1_CUSTO) as CUSTO
		 , (-1) * sum(D1_VALIMP1+D1_VALIMP2+D1_VALIMP3+D1_VALIMP4+D1_VALIMP5+D1_VALIMP6) as IMPOSTO
	  from %table:SD1% SD1
	  join %table:SF2% SF2
        on SF2.F2_FILIAL  = %xfilial:SF2%
       and SF2.F2_DOC     = SD1.D1_NFORI
	   and SF2.F2_SERIE   = SD1.D1_SERIORI
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriBal% // 'BAL'
	   and SF2.%notDel%
	  join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
	  join %table:SB1% SB1
	    on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
	  join %table:SBM% SBM
	    on SBM.BM_FILIAL  = %xfilial:SBM%
	   and SBM.BM_GRUPO   = SB1.B1_GRUPO
	   and SBM.%notDel%
	 where SD1.D1_FILIAL  = %xfilial:SD1%
       and SD1.D1_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SD1.D1_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SD1.D1_ESPECIE = 'NCC'
	   and SD1.D1_TIPO    = 'D'
	   and 1              = %exp:MV_PAR05% // Deduz devolucao? [{1=Sim; 2=Não}
	   and SD1.%notDel%
  group by SF2.F2_PREFORI
	     , SB1.B1_GRUPO
		 , SBM.BM_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

     union all

//
// Para Oficina - Peças: F2_PREFORI = 'OFI'
// Quebrar por VOI_SITTPO + B1_GRUPO ou F2_CLIENTE+F2_LOJA
//

	select SF2.F2_PREFORI + '-PCS'
	     , VOI.VOI_SITTPO + '-' + SB1.B1_GRUPO as AGRUPADOR
		 , %exp:cCase% + SBM.BM_DESC as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , sum(D2_TOTAL) as TOTAL
		 , sum(D2_CUSTO1) as CUSTO
		 , sum(D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6) as IMPOSTO
	  from %table:SF2% SF2
	  join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
	  join %table:VEC% VEC
	    on VEC.VEC_FILIAL  = %xfilial:VEC%
	   and VEC.VEC_NUMNFI = SD2.D2_DOC
	   and VEC.VEC_SERNFI = SD2.D2_SERIE
	   and VEC.VEC_ITENFI = SD2.D2_ITEM
	   and VEC.%notDel%
	  join %table:VOI% VOI
	    on VOI.VOI_FILIAL  = %xfilial:VOI%
	   and VOI.VOI_TIPTEM = VEC.VEC_TIPTEM
	   and VOI.%notDel%
	  join %table:SB1% SB1
	    on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
	  join %table:SBM% SBM
	    on SBM.BM_FILIAL  = %xfilial:SBM%
	   and SBM.BM_GRUPO   = SB1.B1_GRUPO
	   and SBM.BM_TIPGRU  not in('4', '7')
	   and SBM.%notDel%
	 where SF2.F2_FILIAL  = %xfilial:SF2%
	   and SF2.F2_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SF2.F2_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriOfi% // 'OFI'
	   and SF2.%notDel%
  group by SF2.F2_PREFORI
	     , VOI.VOI_SITTPO + '-' + SB1.B1_GRUPO
		 , %exp:cCase% + SBM.BM_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

     union all

/* 
 * devoluções das notas F2_PREFORI = 'OFI' - Peças
 * 
 */

	select SF2.F2_PREFORI + '-PCS'
	     , VOI.VOI_SITTPO + '-' + SB1.B1_GRUPO as AGRUPADOR
		 , %exp:cCase% + SBM.BM_DESC as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , (-1) * sum(D1_TOTAL) as TOTAL
		 , (-1) * sum(D1_CUSTO) as CUSTO
		 , (-1) * sum(D1_VALIMP1+D1_VALIMP2+D1_VALIMP3+D1_VALIMP4+D1_VALIMP5+D1_VALIMP6) as IMPOSTO
	  from %table:SD1% SD1
	  join %table:SF2% SF2
        on SF2.F2_FILIAL  = %xfilial:SF2%
       and SF2.F2_DOC     = SD1.D1_NFORI
	   and SF2.F2_SERIE   = SD1.D1_SERIORI
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriOfi% // 'OFI'
	   and SF2.%notDel%
	  join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
	  join %table:VEC% VEC
	    on VEC.VEC_FILIAL  = %xfilial:VEC%
	   and VEC.VEC_NUMNFI = SD2.D2_DOC
	   and VEC.VEC_SERNFI = SD2.D2_SERIE
	   and VEC.VEC_ITENFI = SD2.D2_ITEM
	   and VEC.%notDel%
	  join %table:VOI% VOI
	    on VOI.VOI_FILIAL  = %xfilial:VOI%
	   and VOI.VOI_TIPTEM = VEC.VEC_TIPTEM
	   and VOI.%notDel%
	  join %table:SB1% SB1
	    on SB1.B1_FILIAL  = %xfilial:SB1%
	   and SB1.B1_COD     = SD2.D2_COD
	   and SB1.%notDel%
	  join %table:SBM% SBM
	    on SBM.BM_FILIAL  = %xfilial:SBM%
	   and SBM.BM_GRUPO   = SB1.B1_GRUPO
	   and SBM.BM_TIPGRU  not in('4', '7')
	   and SBM.%notDel%
	 where SD1.D1_FILIAL  = %xfilial:SD1%
       and SD1.D1_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SD1.D1_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SD1.D1_ESPECIE = 'NCC'
	   and SD1.D1_TIPO    = 'D'
	   and 1              = %exp:MV_PAR05% // Deduz devolucao? [{1=Sim; 2=Não}
	   and SD1.%notDel%
  group by SF2.F2_PREFORI
	     , VOI.VOI_SITTPO + '-' + SB1.B1_GRUPO
		 , %exp:cCase% + SBM.BM_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

     union all

/*
 * Para Oficina - Serviços: F2_PREFORI = 'OFI'
 * Quebrar por VOI_SITTPO+B1_COD ou F2_CLIENTE+F2_LOJA
 */
	select SF2.F2_PREFORI + '-SRV'
	     , VOI.VOI_SITTPO+'-'+VOK.VOK_TIPSER as AGRUPADOR
		 , %exp:cCase% + VOK.VOK_DESSER as AGRUP_DESC
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA as COD_CLI
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO
		 , sum(D2_TOTAL) as TOTAL
		 , sum(D2_CUSTO1) as CUSTO
		 , sum(D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6) as IMPOSTO
	  from %table:SF2% SF2
	  join %table:SD2% SD2
	    on SD2.D2_FILIAL  = %xfilial:SD2% 
	   and SD2.D2_DOC	  = SF2.F2_DOC	  
	   and SD2.D2_SERIE	  = SF2.F2_SERIE    
	   and SD2.D2_CLIENTE = SF2.F2_CLIENTE 
	   and SD2.D2_LOJA	  = SF2.F2_LOJA	   
	   and SD2.%notDel%
	  join %table:SA1% SA1
	    on SA1.A1_FILIAL  = %xfilial:SA1%
	   and SA1.A1_COD     = SF2.F2_CLIENTE
	   and SA1.A1_LOJA    = SF2.F2_LOJA
	   and SA1.%notDel%
	  join %table:VSC% VSC
	    on VSC.VSC_FILIAL = %xfilial:VSC%
	   and VSC.VSC_NUMNFI = SD2.D2_DOC
	   and VSC.VSC_SERNFI = SD2.D2_SERIE
	   and VSC.VSC_ITENFI = SD2.D2_ITEM
	   and VSC.%notDel%
	  join %table:VOI% VOI
	    on VOI.VOI_FILIAL  = %xfilial:VOI%
	   and VOI.VOI_TIPTEM = VSC.VSC_TIPTEM
	   and VOI.%notDel%
	  join %table:VOK% VOK
	    on VOK.VOK_FILIAL = %xfilial:VOK%
	   and VOK.VOK_TIPSER =  VSC.VSC_TIPSER
	   and VOK.%notDel%
	 where SF2.F2_FILIAL  = %xfilial:SF2%
	   and SF2.F2_EMISSAO >= %exp:DToS(MV_PAR01)%
	   and SF2.F2_EMISSAO <= %exp:DToS(MV_PAR02)%
	   and SF2.F2_ESPECIE = 'NF'
	   and SF2.F2_PREFORI = %exp:cPrfOriOfi% // 'OFI'
	   and SF2.%notDel%
  group by SF2.F2_PREFORI
	     , VOI.VOI_SITTPO+'-'+VOK.VOK_TIPSER
		 , %exp:cCase% + VOK.VOK_DESSER
		 , SF2.F2_CLIENTE + '-' + SF2.F2_LOJA
		 , SA1.A1_NOME
		 , SF2.F2_MOEDA
		 , SF2.F2_EMISSAO

EndSql

oSay:SetText(STR0016) // "Totalizando dados..."

while !(cAlias)->(Eof())
	nMoedaDoc := Iif(Empty((cAlias)->F2_MOEDA), 1, (cAlias)->F2_MOEDA)
	if (nPos := aScan(aData, {|aMat| aMat[1] == AllTrim((cAlias)->F2_PREFORI) .and. aMat[2] == Iif(MV_PAR04 == 1, (cAlias)->AGRUPADOR, COD_CLI) }) ) == 0
		AAdd(aData, { AllTrim((cAlias)->F2_PREFORI);
		            , Iif(MV_PAR04 == 1, (cAlias)->AGRUPADOR, COD_CLI);
					, Iif(MV_PAR04 == 1, (cAlias)->AGRUP_DESC, A1_NOME);
					, FG_Moeda((cAlias)->TOTAL, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO);
					, FG_Moeda((cAlias)->CUSTO, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO);
					, FG_Moeda((cAlias)->IMPOSTO, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO) } )
	else
		aData[nPos][4] += FG_Moeda((cAlias)->TOTAL, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO)
		aData[nPos][5] += FG_Moeda((cAlias)->CUSTO, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO)
		aData[nPos][6] += FG_Moeda((cAlias)->IMPOSTO, nMoedaDoc, MV_PAR03,,,(cAlias)->F2_EMISSAO)
	endif
	(cAlias)->(DbSkip())
end

(cAlias)->(DbCloseArea())

ASort(aData,,,{|a, b| a[1] + a[2] > b[1] + b[2]})

return AClone(aData)