/*--------------------------------------------------------------------------------------------------
GFEBI01B
Programa auxiliar para a geração do arquivo "Freight Expenses Fact" para integração com BI

--------------------------------------------------------------------------------------------------*/
#INCLUDE "PROTHEUS.CH"

#DEFINE VAZIO CHR(95)				// Underline
#DEFINE SEP CHR(09)					// Tabulação
#DEFINE CRLF CHR(13) + CHR(10)		// Nova Linha


/*--------------------------------------------------------------------------------------------------
GFEBI01F
Nome do Arquivo

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
User Function GFEBI01F()

Return "DIS_DTS_Freight_Expenses_Fact.txt"


/*--------------------------------------------------------------------------------------------------
GFEBI01H
Cabeçalho do arquivo Freight Expenses Fact

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
User Function GFEBI01H()
	Local cHeader

	cHeader := "CD_Company"                     + SEP
	cHeader += "CD_Site"                        + SEP
	cHeader += "CD_Business_Unit"               + SEP
	cHeader += "CD_Currency"                    + SEP
	cHeader += "CD_City"                        + SEP
	cHeader += "CD_State"                       + SEP
	cHeader += "CD_Country"                     + SEP
	cHeader += "CD_Geography_Region"            + SEP
	cHeader += "CD_Comercial_Territory"         + SEP
	cHeader += "CD_MicroTerritory"              + SEP //10
	cHeader += "CD_Operation_Nature"            + SEP
	cHeader += "CD_ShipVia"                     + SEP
	cHeader += "CD_Representative"              + SEP
	cHeader += "CD_Vendors"                     + SEP
	cHeader += "CD_Item"                        + SEP
	cHeader += "CD_Commercial_Product"          + SEP
	cHeader += "CD_Carrier"                     + SEP
	cHeader += "CD_Emitter"                     + SEP
	cHeader += "CD_Emitter_Sender"              + SEP
	cHeader += "CD_NF_Type"                     + SEP //20
	cHeader += "CD_Broker"                      + SEP
	cHeader += "CD_Calc_Type"                   + SEP
	cHeader += "CD_Freight_Type"                + SEP
	cHeader += "CD_Vehicle_Type"                + SEP
	cHeader += "CD_Redispatch"                  + SEP
	cHeader += "CD_Sale_Forma_Bill_Series"      + SEP
	cHeader += "CD_Sale_Forma_Bill_Number"      + SEP
	cHeader += "CD_Freight_Document"            + SEP
	cHeader += "CD_Romaneio"                    + SEP
	cHeader += "CD_Freight_Item"                + SEP //30
	cHeader += "DT_Day"                         + SEP
	cHeader += "DT_NF_Create"                   + SEP
	cHeader += "DT_NF_Create_Time"              + SEP
	cHeader += "DT_Material_Out"                + SEP
	cHeader += "DT_Material_Out_Time"           + SEP
	cHeader += "DT_Material_Delivery"           + SEP
	cHeader += "DT_Material_Delivery_Time"      + SEP
	cHeader += "DT_Material_Delivery_Prev"      + SEP
	cHeader += "DT_Material_Delivery_Prev_Time" + SEP
	cHeader += "DT_Material_Out_Prev"           + SEP //40
	cHeader += "DT_Material_Out_Prev_Time"      + SEP
	cHeader += "NM_Freight_Value"               + SEP
	cHeader += "NM_Daily_Value"                 + SEP
	cHeader += "NM_Delivery_Value"              + SEP
	cHeader += "NM_Freight_Weight"              + SEP
	cHeader += "NM_Val_Freight_Value"           + SEP
	cHeader += "NM_Freight_Unit_Value"          + SEP
	cHeader += "NM_Toll_Value"                  + SEP
	cHeader += "NM_GRIS_Value"                  + SEP
	cHeader += "NM_ITR_Value"                   + SEP //50
	cHeader += "NM_Suframa_Value"               + SEP
	cHeader += "NM_Insurance_Value"             + SEP
	cHeader += "NM_Collect_Tax"                 + SEP
	cHeader += "NM_Delivery_Tax"                + SEP
	cHeader += "NM_Dispatch_Tax"                + SEP
	cHeader += "NM_Freight_Document_Tax"        + SEP
	cHeader += "NM_ICMS_Value"                  + SEP
	cHeader += "NM_PIS_Value"                   + SEP
	cHeader += "NM_COFINS_Value"                + SEP
	cHeader += "NM_ISS_Value"                   + SEP //60
	cHeader += "NM_Total_Product_Quantity"      + SEP
	cHeader += "NM_Total_Product_Brute_Weight"  + SEP
	cHeader += "NM_Total_Product_Cubage"        + SEP
	cHeader += "NM_Total_Product_Weight_Cubed"  + SEP
	cHeader += "NM_Total_Product_Value"         + SEP
	cHeader += "NM_Freight_Document_Value"      + SEP
	cHeader += "NM_Discharge_Value"             + SEP
	cHeader += "NM_IRRF_Value"                  + SEP
	cHeader += "NM_SEST_SENAT_Value"            + SEP
	cHeader += "NM_INSS_Partner_Value"          + SEP //70
	cHeader += "NM_Anticipation_Value"          + SEP
	cHeader += "NM_ISS_Partner_Value"           + SEP
	cHeader += "NM_PIS_COFINS_Tot_Prev"         + SEP
	cHeader += "NM_Freight_Normal_Prev"         + SEP
	cHeader += "NM_ICMS_Normal_Prev"            + SEP
	cHeader += "NM_PIS_COFINS_Normal_Prev"      + SEP
	cHeader += "NM_Freight_Redesp_Prev"         + SEP
	cHeader += "NM_ICMS_Redesp_Prev"            + SEP
	cHeader += "NM_PIS_COFINS_Redesp_Prev"      + SEP
	cHeader += "NM_Qtd_Redesp_Prev"             + SEP //80
	cHeader += "NM_ICMS_Daily_Prev"             + SEP
	cHeader += "NM_PIS_COFINS_Daily_Prev"       + SEP
	cHeader += "NM_Qtd_Daily_Prev"              + SEP
	cHeader += "NM_Freight_Reent_Prev"          + SEP
	cHeader += "NM_ICMS_Reent_Prev"             + SEP
	cHeader += "NM_PIS_COFINS_Reent_Prev"       + SEP
	cHeader += "NM_Qtd_Reent_Prev"              + SEP
	cHeader += "NM_Freight_Devol_Prev"          + SEP
	cHeader += "NM_ICMS_Devol_Prev"             + SEP
	cHeader += "NM_PIS_COFINS_Devol_Prev"       + SEP //90
	cHeader += "NM_Qtd_Devol_Prev"              + SEP
	cHeader += "NM_Freight_Auton_Prev"          + SEP
	cHeader += "NM_Freight_Tot_Real"            + SEP
	cHeader += "NM_ICMS_Tot_Real"               + SEP
	cHeader += "NM_PIS_COFINS_Tot_Real"         + SEP
	cHeader += "NM_Freight_Normal_Real"         + SEP
	cHeader += "NM_ICMS_Normal_Real"            + SEP
	cHeader += "NM_PIS_COFINS_Normal_Real"      + SEP
	cHeader += "NM_Freight_Redesp_Real"         + SEP
	cHeader += "NM_ICMS_Redesp_Real"            + SEP //100
	cHeader += "NM_PIS_COFINS_Redesp_Real"      + SEP
	cHeader += "NM_Qtd_Redesp_Real"             + SEP
	cHeader += "NM_Daily_Real"                  + SEP
	cHeader += "NM_ICMS_Daily_Real"             + SEP
	cHeader += "NM_PIS_COFINS_Daily_Real"       + SEP
	cHeader += "NM_Qtd_Daily_Real"              + SEP
	cHeader += "NM_Freight_Reent_Real"          + SEP
	cHeader += "NM_ICMS_Reent_Real"             + SEP
	cHeader += "NM_PIS_COFINS_Reent_Real"       + SEP
	cHeader += "NM_Qtd_Reent_Real"              + SEP //110
	cHeader += "NM_Freight_Devol_Real"          + SEP
	cHeader += "NM_ICMS_Devol_Real"             + SEP
	cHeader += "NM_PIS_COFINS_Devol_Real"       + SEP
	cHeader += "NM_Qtd_Devol_Real"              + SEP
	cHeader += "NM_Freight_Auton_Real"          + SEP
	cHeader += "NM_Taxes_Auton_Real"            + SEP
	cHeader += "NM_INSS_Auton_Real"             + CRLF //117
Return (cHeader)



/*--------------------------------------------------------------------------------------------------
GFEBI01L
Linhas de dados do arquivo Freight Expenses Fact
Generico.


aCachePict : Cache de máscara de campos
	aCachePict[1] => GW8_QTDE
	aCachePict[2] => GW8_PESOR
	aCachePict[3] => GW8_VOLUME
	aCachePict[4] => GW8_PESOC
	aCachePict[5] => GW8_VALOR
	aCachePict[6] => GWI_VLFRET
	aCachePict[7] => GWF_VLPIS
	aCachePict[8] => GWF_VLICMS
	aCachePict[9] => GW2_VLINSS


@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
User Function GFEBI01L()
	Local cLinha
	
	// -- 1 -----
    cLinha := (cAliasBI)->EMPRESA									+ SEP
	cLinha += (cAliasBI)->FILIAL									+ SEP
	cLinha += FormataStr((cAliasBI)->UNINEG, 3)   					+ SEP // CD_Business_Unit
	cLinha += EmBranco(8)                              				+ SEP // CD_Currency
	cLinha += FormataStr((cAliasBI)->CIDADE, 60)                 	+ SEP // CD_City
	cLinha += FormataStr((cAliasBI)->UF, 2)                    		+ SEP // CD_State
	cLinha += FormataStr((cAliasBI)->PAIS, 25) 						+ SEP // CD_Country
	cLinha += FormataStr((cAliasBI)->REGIAO, 40)               		+ SEP // CD_Geography_Region
	cLinha += FormataStr((cAliasBI)->REGIAOCOM, 12)             	+ SEP // CD_Comercial_Territory
	cLinha += EmBranco(12)                             				+ SEP // CD_MicroTerritory
	
	// -- 10 -----
	cLinha += FormataStr((cAliasBI)->NATUOPER, 16)					+ SEP // CD_Operation_Nature 	(GW8_INFO1)
	cLinha += EmBranco(12)                             				+ SEP // CD_ShipVia
	cLinha += "0"                                            		+ SEP // CD_Representative	
	cLinha += FormataStr((cAliasBI)->CANALVENDA, 16)           		+ SEP // CD_Vendors				(GW8_INFO2)
	cLinha += FormataStr((cAliasBI)->ITEM, 16)             			+ SEP // CD_Item
	cLinha += EmBranco(16)                             				+ SEP // CD_Commercial_Product
	cLinha += FormataStr((cAliasBI)->TRANSP, 14)    				+ SEP // CD_Carrier
	cLinha += FormataStr((cAliasBI)->DESTINATA, 14)            		+ SEP // CD_Emitter
	cLinha += FormataStr((cAliasBI)->REMETENTE, 14)          		+ SEP // CD_Emitter
	cLinha += RecNoGV5((cAliasBI)->TIPO_DC)	             			+ SEP // CD_NF_Type
	
	// -- 20 -----
	cLinha += EmBranco(12)                             				+ SEP // CD_Broker
	cLinha += "0"                           						+ SEP // CD_Calc_Type
	cLinha += (cAliasBI)->TIPOFRETE                           		+ SEP // CD_Freight_Type 
	cLinha += RecNoGV3((cAliasBI)->VEICULO)                 		+ SEP // CD_Vehicle_Type
	cLinha += (cAliasBI)->REDESPACHO                           		+ SEP // CD_Redispatch
	cLinha += FormataStr((cAliasBI)->GW1_SERDC, 5)             		+ SEP // CD_Sale_Forma_Bill_Series
	cLinha += FormataStr((cAliasBI)->GW1_NRDC, 16)             		+ SEP // CD_Sale_Forma_Bill_Number
	cLinha += "Documento não disponível"                     		+ SEP // CD_Freight_Document
	cLinha += (cAliasBI)->ROMANEIO                            		+ SEP // CD_Romaneio
	cLinha += FormataStr((cAliasBI)->CLASSFRETE, 4)            		+ SEP // CD_Freight_Item
	
	// -- 30 -----
	cLinha += FormataData((cAliasBI)->GW1_DTIMPL)                   + SEP // DT_Day
	cLinha += FormataData((cAliasBI)->GW1_DTEMIS)                   + SEP // DT_NF_Create
	cLinha += PrintHora((cAliasBI)->GW1_HRIMPL)                		+ SEP // DT_NF_Create_Time
	cLinha += FormataData((cAliasBI)->GW1_DTSAI)                    + SEP // DT_Material_Out
	cLinha += PrintHora((cAliasBI)->GW1_HRSAI)                 		+ SEP // DT_Material_Out_Time
	cLinha += FormataData((cAliasBI)->GWU_DTENT)                    + SEP // DT_Material_Delivery
	cLinha += PrintHora((cAliasBI)->GWU_HRENT)                 		+ SEP // DT_Material_Delivery_Time
	cLinha += FormataData((cAliasBI)->GW1_DTPENT)                   + SEP // DT_Material_Delivery_Prev
	cLinha += PrintHora((cAliasBI)->GW1_HRPENT)                		+ SEP // DT_Material_Delivery_Prev_Time
	cLinha += FormataData((cAliasBI)->GW1_DTPSAI)                   + SEP // DT_Material_Out_Prev
	
	// -- 40 -----
	cLinha += PrintHora((cAliasBI)->GW1_HRPSAI)                		+ SEP // DT_Material_Out_Prev_Time
	cLinha += FormataValor((cAliasBI)->VALORFRETE, aCachePict[6])	+ SEP // NM_Freight_Value
	cLinha += FormataValor((cAliasBI)->VL_DIARIA , aCachePict[6])	+ SEP // NM_Daily_Value
	cLinha += "0,00"										 		+ SEP // NM_Delivery_Value
	cLinha += "0,0000"										 		+ SEP // NM_Freight_Weight
	cLinha += "0,00"										 		+ SEP // NM_Val_Freight_Value
	cLinha += "0,00"										 		+ SEP // NM_Freight_Unit_Value
	cLinha += "0,00"										 		+ SEP // NM_Toll_Value
	cLinha += "0,00"										 		+ SEP // NM_GRIS_Value
	cLinha += "0,00"										 		+ SEP // NM_ITR_Value		
	
	// -- 50 -----
	cLinha += "0,00"										 		+ SEP // NM_Suframa_Value
	cLinha += "0,00"										 		+ SEP // NM_Insurance_Value
	cLinha += "0,00"										 		+ SEP // NM_Collect_Tax
	cLinha += "0,0000"										 		+ SEP // NM_Delivery_Tax
	cLinha += "0,0000"										 		+ SEP // NM_Dispatch_Tax
	cLinha += "0,0000"										 		+ SEP // NM_Freight_Document_Tax
	cLinha += FormataValor((cAliasBI)->VL_ICMS, aCachePict[8]) 		+ SEP // NM_ICMS_Value
	cLinha += "0,00"										 		+ SEP // NM_PIS_Value 
	cLinha += "0,00"										 		+ SEP // NM_COFINS_Value
	cLinha += "0,00"										 		+ SEP // NM_ISS_Value
	
	// -- 60 -----
	cLinha += FormataValor((cAliasBI)->GW8_QTDE  , aCachePict[1]) 	+ SEP // NM_Total_Product_Quantity
	cLinha += FormataValor((cAliasBI)->GW8_PESOR , aCachePict[2])	+ SEP // NM_Total_Product_Brute_Weight
	cLinha += FormataValor((cAliasBI)->GW8_VOLUME, aCachePict[3])	+ SEP // NM_Total_Product_Cubage
	cLinha += FormataValor((cAliasBI)->GW8_PESOC , aCachePict[4])	+ SEP // NM_Total_Product_Weight_Cubed
	cLinha += FormataValor((cAliasBI)->GW8_VALOR , aCachePict[5])	+ SEP // NM_Total_Product_Value
	cLinha += "0,00"										 		+ SEP // NM_Freight_Document_Value
	cLinha += 												 		+ SEP // NM_Discharge_Value
	cLinha +=												 		+ SEP // NM_IRRF_Value
	cLinha +=												 		+ SEP // NM_SEST_SENAT_Value
	cLinha +=												 		+ SEP // NM_INSS_Partner_Value	
	
	// -- 70 ----
	cLinha +=												 		+ SEP // NM_Anticipation_Value
	cLinha +=												 		+ SEP // NM_ISS_Partner_Value
	cLinha += FormataValor((cAliasBI)->Pr_TotPisC, aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Tot_Prev
	cLinha += FormataValor((cAliasBI)->Pr_VlFrtNr, aCachePict[6])   + SEP // NM_Freight_Normal_Prev
	cLinha += FormataValor((cAliasBI)->Pr_ICMSnr , aCachePict[8])   + SEP // NM_ICMS_Normal_Prev
	cLinha += FormataValor((cAliasBI)->Pr_PISNorm, aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Normal_Prev
	cLinha += FormataValor((cAliasBI)->Pr_Redesp , aCachePict[6]) 	+ SEP // NM_Freight_Redesp_Prev
	cLinha += FormataValor((cAliasBI)->Pr_ICMSRed, aCachePict[8])   + SEP // NM_ICMS_Redesp_Prev
	cLinha += FormataValor((cAliasBI)->Pr_PISRed , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Redesp_Prev
	cLinha += FormataValor((cAliasBI)->Pr_TotRed)            		+ SEP // NM_Qtd_Redesp_Prev	
	
	// -- 80 -----
	cLinha += FormataValor((cAliasBI)->Pr_ICMSDia, aCachePict[8]) 	+ SEP // NM_ICMS_Daily_Prev
	cLinha += FormataValor((cAliasBI)->Pr_PISDia , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Daily_Prev
	cLinha += FormataValor((cAliasBI)->Pr_TotDia)        			+ SEP // NM_Qtd_Daily_Prev
	cLinha += FormataValor((cAliasBI)->Pr_VlReen , aCachePict[6]) 	+ SEP // NM_Freight_Reent_Prev
	cLinha += FormataValor((cAliasBI)->Pr_ICMSRee, aCachePict[8]) 	+ SEP // NM_ICMS_Reent_Prev
	cLinha += FormataValor((cAliasBI)->Pr_PISRee , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Reent_Prev
	cLinha += FormataValor((cAliasBI)->Pr_TotReen)       			+ SEP // NM_Qtd_Reent_Prev
	cLinha += FormataValor((cAliasBI)->Pr_VlDevol, aCachePict[6]) 	+ SEP // NM_Freight_Devol_Prev
	cLinha += FormataValor((cAliasBI)->Pr_ICMSDev, aCachePict[8]) 	+ SEP // NM_ICMS_Devol_Prev
	cLinha += FormataValor((cAliasBI)->Pr_PISDev , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Devol_Prev
	
	// -- 90 -----		
	cLinha += FormataValor((cAliasBI)->Pr_TotDev)        			+ SEP // NM_Qtd_Devol_Prev
	cLinha += FormataValor((cAliasBI)->Pr_VlAuton, aCachePict[6]) 	+ SEP // NM_Freight_Auton_Prev
	cLinha += FormataValor((cAliasBI)->Re_TotFrt , aCachePict[6])   + SEP // NM_Freight_Tot_Real
	cLinha += FormataValor((cAliasBI)->Re_TotICMS, aCachePict[8])   + SEP // NM_ICMS_Tot_Real
	cLinha += FormataValor((cAliasBI)->Re_TotPisC, aCachePict[7])   + SEP // NM_PIS_COFINS_Tot_Real
	cLinha += FormataValor((cAliasBI)->Re_FrtNorm, aCachePict[6])   + SEP // NM_Freight_Normal_Real
	cLinha += FormataValor((cAliasBI)->Re_ICMSNr , aCachePict[6])   + SEP // NM_ICMS_Normal_Real
	cLinha += FormataValor((cAliasBI)->Re_PISNor , aCachePict[7])   + SEP // NM_PIS_COFINS_Normal_Real
	cLinha += FormataValor((cAliasBI)->Re_VlRedes, aCachePict[6]) 	+ SEP // NM_Freight_Redesp_Real
	cLinha += FormataValor((cAliasBI)->Re_VlICRed, aCachePict[8]) 	+ SEP // NM_ICMS_Redesp_Real
	
	// -- 100 -----		
	cLinha += FormataValor((cAliasBI)->Re_VlPisRe, aCachePict[7])   + SEP // NM_PIS_COFINS_Redesp_Real
	cLinha += FormataValor((cAliasBI)->Re_TotRede)             		+ SEP // NM_Qtd_Redesp_Real
	cLinha += FormataValor((cAliasBI)->Re_VlDiari, aCachePict[6])   + SEP // NM_Daily_Real
	cLinha += FormataValor((cAliasBI)->Re_ICMSDia, aCachePict[8])   + SEP // NM_ICMS_Daily_Real
	cLinha += FormataValor((cAliasBI)->Re_PISDia , aCachePict[7])   + SEP // NM_PIS_COFINS_Daily_Real
	cLinha += FormataValor((cAliasBI)->Re_TotDia)              		+ SEP // NM_Qtd_Daily_Real
	cLinha += FormataValor((cAliasBI)->Re_VlTotRe, aCachePict[6])   + SEP // NM_Freight_Reent_Real
	cLinha += FormataValor((cAliasBI)->Re_ICMSRe , aCachePict[8])   + SEP // NM_ICMS_Reent_Real
	cLinha += FormataValor((cAliasBI)->Re_PISRee , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Reent_Real
	cLinha += FormataValor((cAliasBI)->Re_TotRee)         	 		+ SEP // NM_Qtd_Reent_Real
	
	// -- 110 -----
	cLinha += FormataValor((cAliasBI)->Re_VlTotDe, aCachePict[6]) 	+ SEP // NM_Freight_Devol_Real
	cLinha += FormataValor((cAliasBI)->Re_ICMSDev, aCachePict[8])	+ SEP // NM_ICMS_Devol_Real
	cLinha += FormataValor((cAliasBI)->Re_PISDev , aCachePict[7]) 	+ SEP // NM_PIS_COFINS_Devol_Real
	cLinha += FormataValor((cAliasBI)->Re_TotDev)         	 		+ SEP // NM_Qtd_Devol_Real
	cLinha += FormataValor((cAliasBI)->Re_VlAuto , aCachePict[6]) 	+ SEP // NM_Freight_Auton_Real
	cLinha += FormataValor((cAliasBI)->Re_TaxAuto, aCachePict[9]) 	+ SEP // NM_Taxes_Auton_Real
	cLinha += FormataValor((cAliasBI)->Re_INSSAut, aCachePict[9]) 	 	  // NM_INSS_Auton_Real
	
	cLinha += CRLF

Return (cLinha)


/*--------------------------------------------------------------------------------------------------
EmBranco
Retorna o conteúdo em branco

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function EmBranco(Tamanho)
	
Return Replicate(VAZIO, Tamanho)


/*--------------------------------------------------------------------------------------------------
FormataStr
Faz o tratamento de literais preenchendo com espaços quando necessário

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function FormataStr(cValor, nTam)
	cValor := AllTrim(cValor)
	
	If Empty(cValor)
		Return (EmBranco(nTam))
	EndIf
	
Return (PadR(cValor, nTam))



/*--------------------------------------------------------------------------------------------------
FormataValor
Faz o tratamento de valoes numéricos

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function FormataValor(nValor, cPic)
	Default cPic := ""
	
	If Empty(cPic)
		Return cValToChar(nValor)
	EndIf
	
	cRet := Transform(nValor, cPic)
	cRet := AllTrim(Replace(cRet, ".", ""))
Return (cRet)


/*--------------------------------------------------------------------------------------------------
FormataData
Retorna a data formatada

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function FormataData(dData)

Return DToC(dData)



/*--------------------------------------------------------------------------------------------------
RecNoGV5
Retorna o RecNo do Tipo do Documento de Carga

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function RecNoGV5(cTipo)
	Local cRecno := "0"

	nPos := aScan(aCacheGV5, {|x| Alltrim(x[2]) == Alltrim(cTipo)})
	If nPos > 0
		cRecno := cValToChar(aCacheGV5[nPos][1])
	EndIf

Return cRecno



/*--------------------------------------------------------------------------------------------------
RecNoGV3
Retorna o RecNo do Tipo de Veículo

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function RecNoGV3(cTipo)
	
	Local cRecno := "0"

	nPos := aScan(aCacheGV3, {|x| Alltrim(x[2]) == Alltrim(cTipo)})
	If nPos > 0
		cRecno := cValToChar(aCacheGV3[nPos][1])
	EndIf

Return cRecno






/*--------------------------------------------------------------------------------------------------
PrintHora
Retorna a hora formatada

@author Israel A. Possoli
@since 30/11/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function PrintHora(cHora)
	If Empty(cHora) .OR. cHora == "0000"
		cHora := "00:00"
	EndIf

	If At(":", cHora) == 0
		If Len(cHora) < 4
			cHora := "0" + cHora
		EndIf

		cHora := Substr(cHora, 1, 2) + ":" + Substr(cHora, 3, 4)
	EndIf

Return ("01/01/1800 " + cHora)
