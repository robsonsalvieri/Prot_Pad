#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE _TAB CHR(09)
#DEFINE _TXT_BEGIN 1
#DEFINE _TXT_END 2
 
Static oTmpTabDf := Nil
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEBI01
Geração de arquivo para BI (Freight Expenses Fact)
Generico.
    
@sample
GFEBI01()     

@author Felipe M.
@since 19/12/11
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEBI01()
	Local aParam := {,}, aFiles := {}
	Private cTxt, cArqLog, cTxtArq, cInfoLine
	//Carrega os dados do de/para de filiais;
	Private aArrFil := LoadFil()
	Private cAliasBI
	Private aCachePict := {}
	Private aCacheGV3 := LoadGV3()
	Private aCacheGV5 := LoadGV5()

	If !IsBlind()
		If !Pergunte("GFEBI01", .T.)
			Return
		EndIf  
	EndIf

	AAdd(aCachePict, PesqPict("GW8", "GW8_QTDE"  ))
	AAdd(aCachePict, PesqPict("GW8", "GW8_PESOR" ))
	AAdd(aCachePict, PesqPict("GW8", "GW8_VOLUME"))
	AAdd(aCachePict, PesqPict("GW8", "GW8_PESOC" ))
	AAdd(aCachePict, PesqPict("GW8", "GW8_VALOR" ))
	AAdd(aCachePict, PesqPict("GWI", "GWI_VLFRET"))
	AAdd(aCachePict, PesqPict("GWF", "GWF_VLPIS" ))
	AAdd(aCachePict, PesqPict("GWF", "GWF_VLICMS"))
	AAdd(aCachePict, PesqPict("GW2", "GW2_VLINSS"))

	//Analisa qual parametros foi escolhido para filtrar o periodo
	If MV_PAR01 = 1

		GFEConout("INFO",GetNewPar("MV_GFEBI01",""))

		aParam := GFEBIXML(GetNewPar("MV_GFEBI01",""))

		If aParam == NIL
			Help( ,, 'HELP',, "O arquivo de parâmetros informado não foi encontrado.", 1, 0,)
			Return
		EndIf

		cArqLog := aParam[3]
	Else
		If MV_PAR02 == 1
			aParam[1] := MV_PAR03
			aParam[2] := MV_PAR04
		Else
			aParam[1] := date() - MV_PAR05
			aParam[2] := date() + MV_PAR06
		EndIf

		cArqLog := Alltrim(MV_PAR07)
	EndIf

	cArqLog += "/" + U_GFEBI01F()

	cAliasBI := GFEProcDF( {{"", Replicate("z", 12)}, aParam}) //Recebe o nome da tabela temporaria

	nExistArq :=  ADIR(cArqLog, aFiles)

	If nExistArq != 0
		FERASE ( cArqLog )
	EndIf

	/*
	cHead := "CD_Company"                     + _TAB
	cHead += "CD_Site"                        + _TAB
	cHead += "CD_Business_Unit"               + _TAB
	cHead += "CD_Currency"                    + _TAB
	cHead += "CD_City"                        + _TAB
	cHead += "CD_State"                       + _TAB
	cHead += "CD_Country"                     + _TAB
	cHead += "CD_Geography_Region"            + _TAB
	cHead += "CD_Comercial_Territory"         + _TAB
	cHead += "CD_MicroTerritory"              + _TAB //10
	cHead += "CD_Operation_Nature"            + _TAB
	cHead += "CD_ShipVia"                     + _TAB
	cHead += "CD_Representative"              + _TAB
	cHead += "CD_Vendors"                     + _TAB
	cHead += "CD_Item"                        + _TAB
	cHead += "CD_Commercial_Product"          + _TAB
	cHead += "CD_Carrier"                     + _TAB
	cHead += "CD_Emitter"                     + _TAB
	cHead += "CD_Emitter_Sender"              + _TAB
	cHead += "CD_NF_Type"                     + _TAB //20
	cHead += "CD_Broker"                      + _TAB
	cHead += "CD_Calc_Type"                   + _TAB
	cHead += "CD_Freight_Type"                + _TAB
	cHead += "CD_Vehicle_Type"                + _TAB
	cHead += "CD_Redispatch"                  + _TAB
	cHead += "CD_Sale_Forma_Bill_Series"      + _TAB
	cHead += "CD_Sale_Forma_Bill_Number"      + _TAB
	cHead += "CD_Freight_Document"            + _TAB
	cHead += "CD_Romaneio"                    + _TAB
	cHead += "CD_Freight_Item"                + _TAB //30
	cHead += "DT_Day"                         + _TAB
	cHead += "DT_NF_Create"                   + _TAB
	cHead += "DT_NF_Create_Time"              + _TAB
	cHead += "DT_Material_Out"                + _TAB
	cHead += "DT_Material_Out_Time"           + _TAB
	cHead += "DT_Material_Delivery"           + _TAB
	cHead += "DT_Material_Delivery_Time"      + _TAB
	cHead += "DT_Material_Delivery_Prev"      + _TAB
	cHead += "DT_Material_Delivery_Prev_Time" + _TAB
	cHead += "DT_Material_Out_Prev"           + _TAB //40
	cHead += "DT_Material_Out_Prev_Time"      + _TAB
	cHead += "NM_Freight_Value"               + _TAB
	cHead += "NM_Daily_Value"                 + _TAB
	cHead += "NM_Delivery_Value"              + _TAB
	cHead += "NM_Freight_Weight"              + _TAB
	cHead += "NM_Val_Freight_Value"           + _TAB
	cHead += "NM_Freight_Unit_Value"          + _TAB
	cHead += "NM_Toll_Value"                  + _TAB
	cHead += "NM_GRIS_Value"                  + _TAB
	cHead += "NM_ITR_Value"                   + _TAB //50
	cHead += "NM_Suframa_Value"               + _TAB
	cHead += "NM_Insurance_Value"             + _TAB
	cHead += "NM_Collect_Tax"                 + _TAB
	cHead += "NM_Delivery_Tax"                + _TAB
	cHead += "NM_Dispatch_Tax"                + _TAB
	cHead += "NM_Freight_Document_Tax"        + _TAB
	cHead += "NM_ICMS_Value"                  + _TAB
	cHead += "NM_PIS_Value"                   + _TAB
	cHead += "NM_COFINS_Value"                + _TAB
	cHead += "NM_ISS_Value"                   + _TAB //60
	cHead += "NM_Total_Product_Quantity"      + _TAB
	cHead += "NM_Total_Product_Brute_Weight"  + _TAB
	cHead += "NM_Total_Product_Cubage"        + _TAB
	cHead += "NM_Total_Product_Weight_Cubed"  + _TAB
	cHead += "NM_Total_Product_Value"         + _TAB
	cHead += "NM_Freight_Document_Value"      + _TAB
	cHead += "NM_Discharge_Value"             + _TAB
	cHead += "NM_IRRF_Value"                  + _TAB
	cHead += "NM_SEST_SENAT_Value"            + _TAB
	cHead += "NM_INSS_Partner_Value"          + _TAB //70
	cHead += "NM_Anticipation_Value"          + _TAB
	cHead += "NM_ISS_Partner_Value"           + _TAB
	cHead += "NM_PIS_COFINS_Tot_Prev"         + _TAB
	cHead += "NM_Freight_Normal_Prev"         + _TAB
	cHead += "NM_ICMS_Normal_Prev"            + _TAB
	cHead += "NM_PIS_COFINS_Normal_Prev"      + _TAB
	cHead += "NM_Freight_Redesp_Prev"         + _TAB
	cHead += "NM_ICMS_Redesp_Prev"            + _TAB
	cHead += "NM_PIS_COFINS_Redesp_Prev"      + _TAB
	cHead += "NM_Qtd_Redesp_Prev"             + _TAB //80
	cHead += "NM_ICMS_Daily_Prev"             + _TAB
	cHead += "NM_PIS_COFINS_Daily_Prev"       + _TAB
	cHead += "NM_Qtd_Daily_Prev"              + _TAB
	cHead += "NM_Freight_Reent_Prev"          + _TAB
	cHead += "NM_ICMS_Reent_Prev"             + _TAB
	cHead += "NM_PIS_COFINS_Reent_Prev"       + _TAB
	cHead += "NM_Qtd_Reent_Prev"              + _TAB
	cHead += "NM_Freight_Devol_Prev"          + _TAB
	cHead += "NM_ICMS_Devol_Prev"             + _TAB
	cHead += "NM_PIS_COFINS_Devol_Prev"       + _TAB //90
	cHead += "NM_Qtd_Devol_Prev"              + _TAB
	cHead += "NM_Freight_Auton_Prev"          + _TAB
	cHead += "NM_Freight_Tot_Real"            + _TAB
	cHead += "NM_ICMS_Tot_Real"               + _TAB
	cHead += "NM_PIS_COFINS_Tot_Real"         + _TAB
	cHead += "NM_Freight_Normal_Real"         + _TAB
	cHead += "NM_ICMS_Normal_Real"            + _TAB
	cHead += "NM_PIS_COFINS_Normal_Real"      + _TAB
	cHead += "NM_Freight_Redesp_Real"         + _TAB
	cHead += "NM_ICMS_Redesp_Real"            + _TAB //100
	cHead += "NM_PIS_COFINS_Redesp_Real"      + _TAB
	cHead += "NM_Qtd_Redesp_Real"             + _TAB
	cHead += "NM_Daily_Real"                  + _TAB
	cHead += "NM_ICMS_Daily_Real"             + _TAB
	cHead += "NM_PIS_COFINS_Daily_Real"       + _TAB
	cHead += "NM_Qtd_Daily_Real"              + _TAB
	cHead += "NM_Freight_Reent_Real"          + _TAB
	cHead += "NM_ICMS_Reent_Real"             + _TAB
	cHead += "NM_PIS_COFINS_Reent_Real"       + _TAB
	cHead += "NM_Qtd_Reent_Real"              + _TAB //110
	cHead += "NM_Freight_Devol_Real"          + _TAB
	cHead += "NM_ICMS_Devol_Real"             + _TAB
	cHead += "NM_PIS_COFINS_Devol_Real"       + _TAB
	cHead += "NM_Qtd_Devol_Real"              + _TAB
	cHead += "NM_Freight_Auton_Real"          + _TAB
	cHead += "NM_Taxes_Auton_Real"            + _TAB
	cHead += "NM_INSS_Auton_Real"             + CRLF //117
	*/
	
	cHead := U_GFEBI01H()

	AddToTxtBI(cHead, _TXT_BEGIN)

	dbSelectArea(cAliasBI)
	(cAliasBI)->( dbGotop() )
	Do While (cAliasBI)->(!Eof())
		/*
		
		// -- 1 -----
		cLinha := Iif( Empty(RetEmpFil((cAlias)->FILIAL, (cAlias)->GW1_FILIAL)), (cAlias)->FILIAL, RetEmpFil((cAlias)->FILIAL, (cAlias)->GW1_FILIAL)[1] ) + _TAB // CD_Company
		cLinha += Iif( Empty(RetEmpFil((cAlias)->FILIAL, (cAlias)->GW1_FILIAL)), (cAlias)->GW1_FILIAL, RetEmpFil((cAlias)->FILIAL, (cAlias)->GW1_FILIAL)[2] ) + _TAB // CD_Site
		cLinha += (cAlias)->GW8_UNINEG                           + _TAB // CD_Business_Unit
		cLinha += Replicate("_", 8)                              + _TAB // CD_Currency
		cLinha += (cAlias)->GW_NMCIDD                            + _TAB // CD_City
		cLinha += (cAlias)->GWU_UFD                              + _TAB // CD_State
		cLinha += POSICIONE("SYA",1, XFILIAL("SYA") + (cAlias)->GW_PAIS,"YA_DESCR") + _TAB // CD_Country
		cLinha += (cAlias)->GW_DSREDS                            + _TAB // CD_Geography_Region
		cLinha += (cAlias)->GW1_REGCOM                           + _TAB // CD_Comercial_Territory
		cLinha += Replicate("_", 12)                             + _TAB // CD_MicroTerritory
		// -- 10 -----
		cLinha += (cAlias)->GW8_INFO1                            + _TAB // CD_Operation_Nature
		cLinha += Replicate("_", 12)                             + _TAB // CD_ShipVia
		cLinha += "0"                                            + _TAB // CD_Representative
		cLinha += (cAlias)->GW8_INFO2                            + _TAB // CD_Vendors
		cLinha += (cAlias)->GW8_ITEM                             + _TAB // CD_Item
		cLinha += Replicate("_", 16)                             + _TAB // CD_Commercial_Product
		cLinha += (cAlias)->GW1_TRANSP                           + _TAB // CD_Carrier
		cLinha += (cAlias)->GW1_CDDEST                           + _TAB // CD_Emitter
		cLinha += (cAlias)->GW1_CDREM                            + _TAB // CD_Emitter_Sender
		cLinha += RecnoGV5((cAlias)->GW1_CDTPDC)	             + _TAB // CD_NF_Type
		// -- 20 -----
		cLinha += Replicate("_", 12)                             + _TAB // CD_Broker
		cLinha += (cAlias)->GWF_TPCALC                           + _TAB // CD_Calc_Type
		cLinha += (cAlias)->GW1_TPFRET                           + _TAB // CD_Freight_Type 
		cLinha += RecNoGV3((cAlias)->GWN_CDTPVC)                 + _TAB // CD_Vehicle_Type
		cLinha += (cAlias)->GW_REDESP                            + _TAB // CD_Redispatch
		cLinha += (cAlias)->GW1_SERDC                            + _TAB // CD_Sale_Forma_Bill_Series
		cLinha += (cAlias)->GW1_NRDC                             + _TAB // CD_Sale_Forma_Bill_Number
		cLinha += "Documento não disponível"                     + _TAB // CD_Freight_Document
		cLinha += (cAlias)->GW1_NRROM                            + _TAB // CD_Romaneio
		cLinha += (cAlias)->GW_CDCLFR                            + _TAB // CD_Freight_Item
		// -- 30 -----
		cLinha += DToC((cAlias)->GW1_DTIMPL)                     + _TAB // DT_Day
		cLinha += DToC((cAlias)->GW1_DTEMIS)                     + _TAB // DT_NF_Create
		cLinha += PrintHora((cAlias)->GW1_HRIMPL)                + _TAB // DT_NF_Create_Time
		cLinha += DToC((cAlias)->GW1_DTSAI)                      + _TAB // DT_Material_Out
		cLinha += PrintHora((cAlias)->GW1_HRSAI)                 + _TAB // DT_Material_Out_Time
		cLinha += DToC((cAlias)->GWU_DTENT)                      + _TAB // DT_Material_Delivery
		cLinha += PrintHora((cAlias)->GWU_HRENT)                 + _TAB // DT_Material_Delivery_Time
		cLinha += DToC((cAlias)->GW1_DTPENT)                     + _TAB // DT_Material_Delivery_Prev
		cLinha += PrintHora((cAlias)->GW1_HRPENT)                + _TAB // DT_Material_Delivery_Prev_Time
		cLinha += DToC((cAlias)->GW1_DTPSAI)                     + _TAB // DT_Material_Out_Prev
		// -- 40 -----
		cLinha += PrintHora((cAlias)->GW1_HRPSAI)                + _TAB // DT_Material_Out_Prev_Time
		cLinha += FormataValor((cAlias)->GW_VLFRET , aPict[6])   + _TAB // NM_Freight_Value
		cLinha += FormataValor((cAlias)->GW_VLDIAR , aPict[6])   + _TAB // NM_Daily_Value
		cLinha += "0,00"										 + _TAB // NM_Delivery_Value
		cLinha += "0,0000"										 + _TAB // NM_Freight_Weight
		cLinha += "0,00"										 + _TAB // NM_Val_Freight_Value
		cLinha += "0,00"										 + _TAB // NM_Freight_Unit_Value
		cLinha += "0,00"										 + _TAB // NM_Toll_Value
		cLinha += "0,00"										 + _TAB // NM_GRIS_Value
		cLinha += "0,00"										 + _TAB // NM_ITR_Value		
		// -- 50 -----
		cLinha += "0,00"										 + _TAB // NM_Suframa_Value
		cLinha += "0,00"										 + _TAB // NM_Insurance_Value
		cLinha += "0,00"										 + _TAB // NM_Collect_Tax
		cLinha += "0,0000"										 + _TAB // NM_Delivery_Tax
		cLinha += "0,0000"										 + _TAB // NM_Dispatch_Tax
		cLinha += "0,0000"										 + _TAB // NM_Freight_Document_Tax
		cLinha += FormataValor((cAlias)->GW_VLICMS , aPict[8])   + _TAB // NM_ICMS_Value
		cLinha += "0,00"										 + _TAB // NM_PIS_Value 
		cLinha += "0,00"										 + _TAB // NM_COFINS_Value
		cLinha += "0,00"										 + _TAB // NM_ISS_Value
		// -- 60 -----
		cLinha += FormataValor((cAlias)->GW8_QTDE  , aPict[1])   + _TAB // NM_Total_Product_Quantity
		cLinha += FormataValor((cAlias)->GW8_PESOR , aPict[2])   + _TAB // NM_Total_Product_Brute_Weight
		cLinha += FormataValor((cAlias)->GW8_VOLUME, aPict[3])   + _TAB // NM_Total_Product_Cubage
		cLinha += FormataValor((cAlias)->GW8_PESOC , aPict[4])   + _TAB // NM_Total_Product_Weight_Cubed
		cLinha += FormataValor((cAlias)->GW8_VALOR , aPict[5])   + _TAB // NM_Total_Product_Value
		cLinha += "0,00"										 + _TAB // NM_Freight_Document_Value
		cLinha += 												 + _TAB // NM_Discharge_Value
		cLinha +=												 + _TAB // NM_IRRF_Value
		cLinha +=												 + _TAB // NM_SEST_SENAT_Value
		cLinha +=												 + _TAB // NM_INSS_Partner_Value		
		// -- 70 ----
		cLinha +=												 + _TAB // NM_Anticipation_Value
		cLinha +=												 + _TAB // NM_ISS_Partner_Value
		cLinha += FormataValor((cAlias)->Pr_TotPisC, aPict[7]) 	 + _TAB // NM_PIS_COFINS_Tot_Prev
		cLinha += FormataValor((cAlias)->Pr_VlFrtNr, aPict[6])   + _TAB // NM_Freight_Normal_Prev
		cLinha += FormataValor((cAlias)->Pr_ICMSnr , aPict[8])   + _TAB // NM_ICMS_Normal_Prev
		cLinha += FormataValor((cAlias)->Pr_PISNorm, aPict[7]) 	 + _TAB // NM_PIS_COFINS_Normal_Prev
		cLinha += FormataValor((cAlias)->Pr_Redesp , aPict[6]) 	 + _TAB // NM_Freight_Redesp_Prev
		cLinha += FormataValor((cAlias)->Pr_ICMSRed, aPict[8])   + _TAB // NM_ICMS_Redesp_Prev
		cLinha += FormataValor((cAlias)->Pr_PISRed , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Redesp_Prev
		cLinha += AllTrim(Str((cAlias)->Pr_TotRed))              + _TAB // NM_Qtd_Redesp_Prev		
		// -- 80 -----
		cLinha += FormataValor((cAlias)->Pr_ICMSDia, aPict[8]) 	 + _TAB // NM_ICMS_Daily_Prev
		cLinha += FormataValor((cAlias)->Pr_PISDia , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Daily_Prev
		cLinha += AllTrim(Str((cAlias)->Pr_TotDia))        		 + _TAB // NM_Qtd_Daily_Prev
		cLinha += FormataValor((cAlias)->Pr_VlReen , aPict[6]) 	 + _TAB // NM_Freight_Reent_Prev
		cLinha += FormataValor((cAlias)->Pr_ICMSRee, aPict[8]) 	 + _TAB // NM_ICMS_Reent_Prev
		cLinha += FormataValor((cAlias)->Pr_PISRee , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Reent_Prev
		cLinha += AllTrim(Str((cAlias)->Pr_TotReen))       		 + _TAB // NM_Qtd_Reent_Prev
		cLinha += FormataValor((cAlias)->Pr_VlDevol, aPict[6]) 	 + _TAB // NM_Freight_Devol_Prev
		cLinha += FormataValor((cAlias)->Pr_ICMSDev, aPict[8]) 	 + _TAB // NM_ICMS_Devol_Prev
		cLinha += FormataValor((cAlias)->Pr_PISDev , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Devol_Prev
		// -- 90 -----		
		cLinha += AllTrim(Str((cAlias)->Pr_TotDev))        		 + _TAB // NM_Qtd_Devol_Prev
		cLinha += FormataValor((cAlias)->Pr_VlAuton, aPict[6]) 	 + _TAB // NM_Freight_Auton_Prev
		cLinha += FormataValor((cAlias)->Re_TotFrt , aPict[6])   + _TAB // NM_Freight_Tot_Real
		cLinha += FormataValor((cAlias)->Re_TotICMS, aPict[8])   + _TAB // NM_ICMS_Tot_Real
		cLinha += FormataValor((cAlias)->Re_TotPisC, aPict[7])   + _TAB // NM_PIS_COFINS_Tot_Real
		cLinha += FormataValor((cAlias)->Re_FrtNorm, aPict[6])   + _TAB // NM_Freight_Normal_Real
		cLinha += FormataValor((cAlias)->Re_ICMSNr , aPict[6])   + _TAB // NM_ICMS_Normal_Real
		cLinha += FormataValor((cAlias)->Re_PISNor , aPict[7])   + _TAB // NM_PIS_COFINS_Normal_Real
		cLinha += FormataValor((cAlias)->Re_VlRedes, aPict[6]) 	 + _TAB // NM_Freight_Redesp_Real
		cLinha += FormataValor((cAlias)->Re_VlICRed, aPict[8]) 	 + _TAB // NM_ICMS_Redesp_Real
		// -- 100 -----		
		cLinha += FormataValor((cAlias)->Re_VlPisRe, aPict[7])   + _TAB // NM_PIS_COFINS_Redesp_Real
		cLinha += AllTrim(Str((cAlias)->Re_TotRede))             + _TAB // NM_Qtd_Redesp_Real
		cLinha += FormataValor((cAlias)->Re_VlDiari, aPict[6])   + _TAB // NM_Daily_Real
		cLinha += FormataValor((cAlias)->Re_ICMSDia, aPict[8])   + _TAB // NM_ICMS_Daily_Real
		cLinha += FormataValor((cAlias)->Re_PISDia , aPict[7])   + _TAB // NM_PIS_COFINS_Daily_Real
		cLinha += AllTrim(Str((cAlias)->Re_TotDia))              + _TAB // NM_Qtd_Daily_Real
		cLinha += FormataValor((cAlias)->Re_VlTotRe, aPict[6])   + _TAB // NM_Freight_Reent_Real
		cLinha += FormataValor((cAlias)->Re_ICMSRe , aPict[8])   + _TAB // NM_ICMS_Reent_Real
		cLinha += FormataValor((cAlias)->Re_PISRee , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Reent_Real
		cLinha += AllTrim(Str((cAlias)->Re_TotRee))         	 + _TAB // NM_Qtd_Reent_Real
		// -- 110 -----
		cLinha += FormataValor((cAlias)->Re_VlTotDe, aPict[6]) 	 + _TAB // NM_Freight_Devol_Real
		cLinha += FormataValor((cAlias)->Re_ICMSDev, aPict[8]) 	 + _TAB // NM_ICMS_Devol_Real
		cLinha += FormataValor((cAlias)->Re_PISDev , aPict[7]) 	 + _TAB // NM_PIS_COFINS_Devol_Real
		cLinha += AllTrim(Str((cAlias)->Re_TotDev))         	 + _TAB // NM_Qtd_Devol_Real
		cLinha += FormataValor((cAlias)->Re_VlAuto , aPict[6]) 	 + _TAB // NM_Freight_Auton_Real
		cLinha += FormataValor((cAlias)->Re_TaxAuto, aPict[9]) 	 + _TAB // NM_Taxes_Auton_Real
		cLinha += FormataValor((cAlias)->Re_INSSAut, aPict[9]) 	 + CRLF // NM_INSS_Auton_Real
		
		*/
		
		cLinha := U_GFEBI01L();

		AddToTxtBI(cLinha)
		(cAliasBI)->( dbSkip() )
	EndDo

	SaveLogBI()

	If !IsInCallStack("GFER080")
		GFEDelTab(cAliasBI)
	EndIf

Return

/*--------------------------------------------------------
Função que processa a regua de progressão
--------------------------------------------------------*/
Function GFEProcDF(aParam)

	Local cAliasRet

	Processa( {|| cAliasRet := GFEBIDISPF(aParam) }, "Aguarde...", "Exportando Despesas de Frete...",.F.)

Return cAliasRet

/*--------------------------------------------------------/
Função que cria a Tamp-table da despesa de frete
--------------------------------------------------------*/
Function GFEBITtDF()

	Local aTT
	Local cTTBIDisp

	// Criacao da tabela temporaria p/ imprimir o relat
	aTT := {{"EMPRESA"   , "C", Len(FWCodFil())        , 0},;
			{"FILIAL"	 , "C", TamSX3("GW1_FILIAL")[1], 0},;
			{"CANALVENDA", "C", TamSX3("GW8_INFO2" )[1], 0},;
			{"GW_CDCIDD" , "C", TamSX3("GU7_NRCID" )[1], 0},;
			{"CIDADE"    , "C", TamSX3("GU7_NMCID" )[1], 0},;
			{"UF"   	 , "C", TamSX3("GU7_CDUF"  )[1], 0},;
			{"PAIS"   	 , "C", TamSX3("YA_DESCR")[1]  , 0},;
			{"REGIAOCOM" , "C", TamSX3("GW1_REGCOM")[1], 0},;
			{"REGIAO" 	 , "C", 40					   , 0},;
			{"NATUOPER"  , "C", TamSX3("GW8_INFO1" )[1], 0},;
			{"GW1_REPRES", "C", TamSX3("GW1_REPRES")[1], 0},;
			{"GW8_INFO5" , "C", TamSX3("GW8_INFO5" )[1], 0},;
			{"ITEM"  	 , "C", TamSX3("GW8_ITEM"  )[1], 0},;
			{"SEQUENCIA" , "C", TamSX3("GW8_SEQ"   )[1], 0},;
			{"GW1_EMISDC", "C", TamSX3("GW1_EMISDC")[1], 0},;
			{"TRANSP"	 , "C", TamSX3("GWU_CDTRP" )[1], 0},;
			{"GW_NMEMI"  , "C", TamSX3("GU3_NMEMIT")[1], 0},;
			{"DESTINATA" , "C", TamSX3("GW1_CDDEST")[1], 0},;
			{"GW1_NMDEST", "C", TamSX3("GW1_NMDEST")[1], 0},;
			{"REMETENTE" , "C", TamSX3("GW1_CDREM" )[1], 0},;                       //20
			{"GW1_NMREM" , "C", TamSX3("GW1_NMREM" )[1], 0},;
			{"TIPO_DC"	 , "C", TamSX3("GW1_CDTPDC")[1], 0},;
			{"GV5_DSTPDC", "C", TamSX3("GV5_DSTPDC")[1], 0},;
			{"TIPOFRETE" , "C", 1                      , 0},;
			{"VEICULO"   , "C", TamSX3("GWN_CDTPVC")[1], 0},;
			{"GV3_DSTPVC", "C", TamSX3("GV3_DSTPVC")[1], 0},;
			{"REDESPACHO", "C", 1					   , 0},;
			{"GW1_SERDC" , "C", TamSX3("GW1_SERDC" )[1], 0},;
			{"GW1_NRDC"  , "C", TamSX3("GW1_NRDC"  )[1], 0},;
			{"ROMANEIO"  , "C", TamSX3("GW1_NRROM" )[1], 0},;                       //30
			{"CLASSFRETE", "C", TamSX3("GW8_CDCLFR")[1], 0},;
			{"GUB_DSCLFR", "C", TamSX3("GUB_DSCLFR")[1], 0},;
			{"GW1_DTIMPL", "D", TamSX3("GW1_DTIMPL")[1], 0},;
			{"GW1_DTEMIS", "D", TamSX3("GW1_DTEMIS")[1], 0},;
			{"GW1_HRIMPL", "C", TamSX3("GW1_HRIMPL")[1], 0},;
			{"GW1_DTSAI" , "D", TamSX3("GW1_DTSAI" )[1], 0},;
			{"GW1_HRSAI" , "C", TamSX3("GW1_HRSAI" )[1], 0},;
			{"GWU_DTENT" , "D", TamSX3("GWU_DTENT" )[1], 0},;
			{"GWU_HRENT" , "C", TamSX3("GWU_HRENT" )[1], 0},;
			{"GW1_DTPENT", "D", TamSX3("GW1_DTPENT")[1], 0},;                       //40
			{"GW1_HRPENT", "C", TamSX3("GW1_HRPENT")[1], 0},;
			{"GW1_DTPSAI", "D", TamSX3("GW1_DTPSAI")[1], 0},;
			{"GW1_HRPSAI", "C", TamSX3("GW1_HRPSAI")[1], 0},;
			{"VALORFRETE", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"VL_DIARIA" , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"VL_ICMS"   , "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"GW8_QTDE"  , "N", TamSX3("GW8_QTDE"  )[1], TamSX3("GW8_QTDE"  )[2]},;
			{"GW8_PESOR" , "N", TamSX3("GW8_PESOR" )[1], TamSX3("GW8_PESOR" )[2]},;
			{"GW8_VOLUME", "N", TamSX3("GW8_VOLUME")[1], TamSX3("GW8_VOLUME")[2]},;
			{"GW8_PESOC" , "N", TamSX3("GW8_PESOC" )[1], TamSX3("GW8_PESOC" )[2]},; //50
			{"GW8_VALOR" , "N", TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]},;
			{"GWN_CDTPOP", "C", TamSX3("GWN_CDTPOP")[1], 0},;
			{"GV4_DSTPOP", "C", TamSX3("GV4_DSTPOP")[1], 0},;
			{"GV5_SENTID", "C", TamSX3("GV5_SENTID")[1], 0},;
			{"GW1_USO"   , "C", TamSX3("GW1_USO"   )[1], 0},;
			{"Pr_TotPisC", "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_VlFrtNr", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_ICMSnr" , "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Pr_PISNorm", "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},; //60
			{"Pr_Redesp" , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_ICMSRed", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Pr_PISRed" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_TotRed" , "N", TamSX3("GWU_SEQ"   )[1], 0},;
			{"Pr_ICMSDia", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Pr_PISDia" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_TotDia" , "N", 4                      , 0},;
			{"Pr_VlReen" , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_ICMSRee", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Pr_PISRee" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},; //70
			{"Pr_TotReen", "N", 4                      , 0},;
			{"Pr_VlDevol", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_ICMSDev", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Pr_PISDev" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Pr_TotDev" , "N", 4                      , 0},;
			{"Pr_VlAuton", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotFrt" , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotICMS", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_TotPisC", "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_FrtNorm", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},; //80
			{"Re_ICMSNr" , "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_PISNor" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_VlRedes", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_VlICRed", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_VlPisRe", "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotRede", "N", 4                      , 0},;
			{"Re_VlDiari", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_ICMSDia", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_PISDia" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotDia" , "N", 4                      , 0},;                       //90
			{"Re_VlTotRe", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_ICMSRe" , "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_PISRee" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotRee" , "N", 4                      , 0},;
			{"Re_VlTotDe", "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_ICMSDev", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
			{"Re_PISDev" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TotDev" , "N", 4                      , 0},;
			{"Re_VlAuto" , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;
			{"Re_TaxAuto", "N", TamSX3("GW2_VLINSS")[1], TamSX3("GW2_VLINSS")[2]},; //100
			{"Re_INSSAut", "N", TamSX3("GW2_VLINSS")[1], TamSX3("GW2_VLINSS")[2]},;
			{"UNINEG"    , "C", TamSX3("GW8_UNINEG")[1], 0},;
			{"LACRE"     , "C", TamSX3("GWN_LACRE" )[1], 0}}

	cTTBIDisp := GFECriaTab({aTT, {"FILIAL+TIPO_DC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+TRANSP+ITEM+SEQUENCIA"}},@oTmpTabDf)
Return cTTBIDisp

/*--------------------------------------------------------------------------------------------------
Função responsavel por buscar os registro e retornar o nome da tabela temporaria com os registros
Generico.

@sample
GFEBIDISPF(aParam)

@author Felipe M.
@since 19/12/11
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFEBIDISPF(aParam,aParamGW1)
	Local cMV_CriRat  := SuperGetMv("MV_CRIRAT", .F., "1")
	Local cFilAux     := {}
	Local cSQLCriRat  := ""
	Local cSQLWhere   := ""
	
	Private cAliGWM := GetNextAlias()
	
	If !IsInCallStack("GFER080")
		cAliasDf := GFEBITtDF()
	EndIf
	
	If !IsInCallStack("GFEWSGETDATA")
		If Empty(aParam[1][1])
			cFilAux := GFEGETFIL(cEmpAnt)
			aParam[1][1] := cFilAux[1][1]
		EndIf
	EndIf
	
	cSQLCriRat := "%"
	If cMV_CriRat == "2"
		cSQLCriRat += " MAX(GWM_VLFRE1) AS VL_FRETE, "
		cSQLCriRat += " (MAX(GWM_VLPIS1) + MAX(GWM_VLCOF1)) AS VL_PISCOF, "
		cSQLCriRat += " MAX(GWM_VLICM1) AS VL_ICMS, "
		cSQLCriRat += " MAX(GWM_VLINA1) AS VL_INAU, "
		cSQLCriRat += " MAX(GWM_VLINE1) AS VL_INEM, "
		cSQLCriRat += " MAX(GWM_VLIRR1) AS VL_IRRF, "
		cSQLCriRat += " MAX(GWM_VLSES1) AS VL_SEST, "
	ElseIf cMV_CriRat == "3"
		cSQLCriRat += " MAX(GWM_VLFRE3) AS VL_FRETE, "
		cSQLCriRat += " (MAX(GWM_VLPIS3) + MAX(GWM_VLCOF3)) AS VL_PISCOF, "
		cSQLCriRat += " MAX(GWM_VLICM3) AS VL_ICMS, "
		cSQLCriRat += " MAX(GWM_VLINA3) AS VL_INAU, "
		cSQLCriRat += " MAX(GWM_VLINE3) AS VL_INEM, "
		cSQLCriRat += " MAX(GWM_VLIRR3) AS VL_IRRF, "
		cSQLCriRat += " MAX(GWM_VLSES3) AS VL_SEST, "
	ElseIf cMV_CriRat == "4"
		cSQLCriRat += " MAX(GWM_VLFRE2) AS VL_FRETE, "
		cSQLCriRat += " (MAX(GWM_VLPIS2) + MAX(GWM_VLCOF2)) AS VL_PISCOF, "
		cSQLCriRat += " MAX(GWM_VLICM2) AS VL_ICMS, "
		cSQLCriRat += " MAX(GWM_VLINA2) AS VL_INAU, "
		cSQLCriRat += " MAX(GWM_VLINE2) AS VL_INEM, "
		cSQLCriRat += " MAX(GWM_VLIRR2) AS VL_IRRF, "
		cSQLCriRat += " MAX(GWM_VLSES2) AS VL_SEST, "
	Else
		// Critério padrão: Peso
		cSQLCriRat += " MAX(GWM_VLFRET) AS VL_FRETE, "
		cSQLCriRat += " (MAX(GWM_VLPIS) + MAX(GWM_VLCOFI)) AS VL_PISCOF, "
		cSQLCriRat += " MAX(GWM_VLICMS) AS VL_ICMS, "
		cSQLCriRat += " MAX(GWM_VLINAU) AS VL_INAU, "
		cSQLCriRat += " MAX(GWM_VLINEM) AS VL_INEM, "
		cSQLCriRat += " MAX(GWM_VLIRRF) AS VL_IRRF, "
		cSQLCriRat += " MAX(GWM_VLSEST) AS VL_SEST, "	
	EndIf
	cSQLCriRat += "%"
	
	cSQLWhere := "%"
		If Len(aParam) > 1
			cSQLWhere += " GW1.GW1_FILIAL >= '" + Alltrim(aParam[1][1]) + "' AND GW1.GW1_FILIAL <= '" + Alltrim(aParam[1][2]) + "'"
			cSQLWhere += " AND GW1.GW1_DTEMIS >= '" + DtoS(aParam[2][1]) + "' AND GW1.GW1_DTEMIS <= '" + DToS(aParam[2][2]) + "' "
		ElseIf !Empty(aParamGW1)
			cSQLWhere += " GW1.GW1_FILIAL = '" + Alltrim(aParamGW1[1][1]) + "'"
			cSQLWhere += " AND GW1.GW1_CDTPDC = '" + Alltrim(aParamGW1[1][2]) + "'"
			cSQLWhere += " AND GW1.GW1_EMISDC = '" + Alltrim(aParamGW1[1][3]) + "'"
			cSQLWhere += " AND GW1.GW1_SERDC = '"  + Alltrim(aParamGW1[1][4]) + "'"
			cSQLWhere += " AND GW1.GW1_NRDC = '"   + Alltrim(aParamGW1[1][5]) + "'"
		EndIf
	cSQLWhere += "%"
		
	BeginSql Alias cAliGWM
		SELECT DISTINCT '' AS FILIAL,
				GWM_FILIAL,
				GWM_CDTPDC,
				GWM_EMISDC,
				GWM_SERDC,
				GWM_NRDC,
				GWM_ITEM,
				GWM_NRDOC,
				GWM_TPDOC,
				GWM_CDTRP,
				MAX(GW1_REGCOM) AS REGIAOCOM,
				MAX(GW1_REPRES) AS GW1_REPRES,
				MAX(GW1_CDREM) AS REMETENTE,
				MAX(GW1_CDDEST) AS DESTINATA,
				MAX(GW1_ENTNRC) AS GW1_ENTNRC,
				MAX(GW1_CDTPDC) AS TIPO_DC,
				MAX(GW1_TPFRET) AS TIPOFRETE,
				MAX(GW1_SERDC) AS GW1_SERDC,
				MAX(GW1_NRDC) AS GW1_NRDC,
				MAX(GW1_NRROM) AS ROMANEIO,
				MAX(GW1_DTIMPL) AS GW1_DTIMPL,
				MAX(GW1_DTEMIS) AS GW1_DTEMIS,
				MAX(GW1_HRIMPL) AS GW1_HRIMPL,
				MAX(GW1_DTSAI) AS GW1_DTSAI,
				MAX(GW1_HRSAI) AS GW1_HRSAI,
				MAX(GW1_DTPENT) AS GW1_DTPENT,
				MAX(GW1_HRPENT) AS GW1_HRPENT,
				MAX(GWN_CDCLFR) AS GWN_CDCLFR,
				MAX(GWN_LACRE) AS GWN_LACRE,
				MAX(GW1_DTPSAI) AS GW1_DTPSAI,
				MAX(GW1_USO) AS GW1_USO,
				MAX(GW1_EMISDC) AS GW1_EMISDC,
				MAX(GW8_QTDE) AS GW8_QTDE,
				MAX(GW8_PESOR) AS GW8_PESOR,
				MAX(GW8_VOLUME) AS GW8_VOLUME,
				MAX(GW8_PESOC) AS GW8_PESOC,
				MAX(GW8_UNINEG) AS UNINEG,
				MAX(GW8_INFO1) AS NATUOPER,
				MAX(GW8_INFO2) AS CANALVENDA,
				MAX(GW8_ITEM) AS ITEM,
				GW8_SEQ AS SEQUENCIA,
				MAX(GW8_VALOR) AS GW8_VALOR,
				MAX(GW1_HRPSAI) AS GW1_HRPSAI,
				MAX(GWN_CDTPOP) AS GWN_CDTPOP,
				MAX(GWN_CDTPVC) AS VEICULO,
				MAX(GWM.GWM_CDTRP) AS GWN_CDTRP,
				CASE MAX(GWM.GWM_TPDOC)
					WHEN '1' THEN MAX(GWF.GWF_TPCALC) || ';' || MAX(GWF.GWF_FINCAL)
					WHEN '2' THEN MAX(GW3.GW3_TPDF) || ';0' 
				ELSE '0;0' END AS TPCALC,
				MAX(GW8_INFO2) AS CANALVENDA,
				0 AS TOT_PISCOF,
				%Exp:cSQLCriRat%
				MAX(GU9_NMREG) AS GU9_NMREG,
				MAX(GWU_DTENT) AS GWU_DTENT,
				MAX(GWU_HRENT) AS GWU_HRENT
		FROM %Table:GWM% GWM
		LEFT JOIN %Table:GW1% GW1
		ON GW1.GW1_FILIAL = GWM.GWM_FILIAL
		AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC
		AND GW1.GW1_EMISDC = GWM.GWM_EMISDC
		AND GW1.GW1_SERDC = GWM.GWM_SERDC
		AND GW1.GW1_NRDC = GWM.GWM_NRDC
		AND GW1.%NotDel%
		LEFT JOIN %Table:GW8% GW8
		ON GW8.GW8_FILIAL = GWM.GWM_FILIAL
		AND GW8.GW8_CDTPDC = GWM.GWM_CDTPDC
		AND GW8.GW8_EMISDC = GWM.GWM_EMISDC
		AND GW8.GW8_SERDC = GWM.GWM_SERDC
		AND GW8.GW8_NRDC = GWM.GWM_NRDC
		AND GW8.GW8_ITEM = GWM.GWM_ITEM
		AND GW8.GW8_SEQ = GWM.GWM_SEQGW8
		AND GW8.%NotDel%
		LEFT JOIN %Table:GWN% GWN
		ON GWN.GWN_FILIAL = GW1.GW1_FILIAL
		AND GWN.GWN_NRROM = GW1.GW1_NRROM
		AND GWN.%NotDel%
		LEFT JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = GWM.GWM_FILIAL
		AND GWF.GWF_NRCALC = GWM.GWM_NRDOC
		AND GWF.%NotDel%
		LEFT JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GWM.GWM_FILIAL
		AND GW3.GW3_CDESP = GWM.GWM_CDESP
		AND GW3.GW3_EMISDF = GWM.GWM_CDTRP
		AND GW3.GW3_SERDF = GWM.GWM_SERDOC
		AND GW3.GW3_NRDF = GWM.GWM_NRDOC
		AND GW3.GW3_DTEMIS = GWM.GWM_DTEMIS
		AND GW3.%NotDel%
		LEFT JOIN %Table:GWG% GWG
		ON GWG.GWG_FILIAL = GWF.GWF_FILIAL
		AND GWG.GWG_NRCALC = GWF.GWF_NRCALC
		AND GWG.%NotDel%
		LEFT JOIN %Table:GV8% GV8
		ON GV8.GV8_FILIAL = %xFilial:GV8%
		AND GV8.GV8_CDEMIT = GWG.GWG_CDEMIT
		AND GV8.GV8_NRTAB = GWG.GWG_NRTAB
		AND GV8.GV8_NRNEG = GWG.GWG_NRNEG
		AND GV8.GV8_NRROTA = GWG.GWG_NRROTA
		AND GV8.%NotDel%
		LEFT JOIN %Table:GU9% GU9
		ON GU9.GU9_FILIAL = %xFilial:GU9%
		AND GU9.GU9_NRREG = GV8.GV8_NRREDS
		AND GU9.%NotDel%
		LEFT JOIN %Table:GWU% GWU
		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
		AND GWU.GWU_SERDC = GW1.GW1_SERDC
		AND GWU.GWU_NRDC = GW1.GW1_NRDC
		AND GWU.GWU_PAGAR = '1'
		AND GWU.%NotDel%
		WHERE %Exp:cSQLWhere%
		AND GWM.%NotDel%
		GROUP BY GWM_FILIAL,
					GWM_CDTPDC,
					GWM_EMISDC,
					GWM_SERDC,
					GWM_NRDC,
					GWM_CDTRP,
					GWM_ITEM,
					GW8_SEQ,
					GWM_TPDOC,
					GWM_NRDOC
	EndSql
	
	ProcRegua(RecCount())
	Do While (cAliGWM)->(!Eof())
		If IsInCallStack("GFEWSGETDATA")
			GravaTTRES()
		Else
			GravaTT()
		EndIf
		(cAliGWM)->( dbSkip() )
	EndDo
	GFEDelTab(cAliGWM)
Return cAliasDf

Static Function GravaTT()
	Local aRetEmpFil := {}
	Local cTmpTabDf  := "%"+oTmpTabDf:GetRealName()+"%"
	Local cSerDc     := IIf(Empty((cAliGWM)->GWM_SERDC), "_____", (cAliGWM)->GWM_SERDC)
	Local cAliasQry  := Nil
	Local cAliasGU3  := Nil
	Local cAliasGU7  := Nil
	Local cAliasGV3  := Nil
	Local cAliasGV4  := Nil
	Local cAliasGUB  := Nil
	Local cRepres    := ""
	Local cTipFrete  := ""
	Local cNrDc      := ""
	Local cRomaneio  := ""
	Local cLacre     := ""
	Local dDtImpl    := ""
	Local dDtEmis    := ""
	Local cHorImpl   := ""
	Local dDtSaida   := ""
	Local cHorSaida  := ""
	Local dDtPEntr   := ""
	Local cHorPEntr  := ""
	Local dDtPSaida  := ""
	Local cHorPSaida := ""
	Local cUso       := ""
	Local cCdTpOp    := ""
	Local cRedesp    := ""
	Local cNmEmiDest := ""
	Local cNmEmiRem  := ""
	Local cNmEmiTrp  := ""
	Local cCdCidd    := ""
	Local cUF        := ""
	Local cCidade    := ""
	Local cPais      := ""
	Local cEmpTDf    := ""
	Local cFilTDf    := ""
	Local cDsTpVc    := ""
	Local cDsTpOp    := ""
	Local cDsClFr    := ""
	Local cSentido   := ""
	Local cDsTpDc    := ""
	Local dDtEntTr   := SToD("")
	Local cHorEntTr  := ""
	Local nPos       := 0


	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT TDF.R_E_C_N_O_ RECNOTDF
		FROM %Exp:cTmpTabDf% TDF
		WHERE TDF.FILIAL = %Exp:(cAliGWM)->GWM_FILIAL%
		AND TDF.TIPO_DC = %Exp:(cAliGWM)->GWM_CDTPDC%
		AND TDF.GW1_EMISDC = %Exp:(cAliGWM)->GWM_EMISDC%
		AND TDF.GW1_SERDC = %Exp:cSerDc%
		AND TDF.GW1_NRDC = %Exp:(cAliGWM)->GWM_NRDC%
		AND TDF.TRANSP = %Exp:(cAliGWM)->GWM_CDTRP%
		AND TDF.ITEM = %Exp:(cAliGWM)->GWM_ITEM%
		AND TDF.SEQUENCIA = %Exp:(cAliGWM)->SEQUENCIA%
		AND TDF.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		(cAliasDf)->(dbGoto((cAliasQry)->RECNOTDF))
		// Alteração
		RecLock(cAliasDf, .F.)
			PreencheValores()
		(cAliasDf)->(MsUnlock())
	Else
		// Inicializa as variáveis
		cRepres    := IIf(Empty((cAliGWM)->GW1_REPRES), "0", (cAliGWM)->GW1_REPRES) 
		cTipFrete  := IIf(Empty((cAliGWM)->TIPOFRETE), "0", (cAliGWM)->TIPOFRETE)
		cNrDc      := TrataCampo((cAliGWM)->GW1_NRDC, 16)
		cRomaneio  := IIf(Empty((cAliGWM)->ROMANEIO), "0", (cAliGWM)->ROMANEIO)
		cLacre     := IIf(Empty((cAliGWM)->GWN_LACRE), "0", (cAliGWM)->GWN_LACRE)
		dDtImpl    := IIf(!Empty((cAliGWM)->GW1_DTIMPL),STOD((cAliGWM)->GW1_DTIMPL),CtoD("01/01/1800") )
		dDtEmis    := IIf(!Empty((cAliGWM)->GW1_DTEMIS),STOD((cAliGWM)->GW1_DTEMIS),CtoD("01/01/1800") )
		cHorImpl   := TrataCampo((cAliGWM)->GW1_HRIMPL, 5)
		dDtSaida   := IIf(!Empty((cAliGWM)->GW1_DTSAI),STOD((cAliGWM)->GW1_DTSAI),CtoD("01/01/1800") )
		cHorSaida  := TrataCampo((cAliGWM)->GW1_HRSAI, 5)
		dDtPEntr   := IIf(!Empty((cAliGWM)->GW1_DTPENT),STOD((cAliGWM)->GW1_DTPENT),CtoD("01/01/1800") ) //20
		cHorPEntr  := TrataCampo((cAliGWM)->GW1_HRPENT, 5)
		dDtPSaida  := IIf(!Empty((cAliGWM)->GW1_DTPSAI),STOD((cAliGWM)->GW1_DTPSAI),CtoD("01/01/1800") )
		cHorPSaida := TrataCampo((cAliGWM)->GW1_HRPSAI, 5)
		cUso       := TrataCampo(GFEFldInfo("GW1_USO", (cAliGWM)->GW1_USO, 2), 15) 
		cCdTpOp    := TrataCampo((cAliGWM)->GWN_CDTPOP, 10) //40
		cRedesp    := TrataCampo(If((cAliGWM)->TIPOFRETE $ "2/4/6", "1", "0"), 1)		
		
		// Busca empresa e filial
		If IsInCallStack("GFEBI01")
			aRetEmpFil := RetEmpFil(cEmpAnt, (cAliGWM)->GWM_FILIAL)	
			cEmpTDf := aRetEmpFil[1]
			cFilTDf := aRetEmpFil[2]
		Else
			cEmpTDf := cEmpAnt
			cFilTDf := (cAliGWM)->GWM_FILIAL
		EndIf

		// Busca nome emitente destinatário
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_NMEMIT,
					GU3.GU3_NRCID,
					GU7.GU7_CDUF,
					GU7.GU7_NMCID,
					GU7.GU7_CDPAIS,
					SYA.YA_DESCR
			FROM %Table:GU3% GU3
			INNER JOIN %Table:GU7% GU7
			ON GU7.GU7_FILIAL = %xFilial:GU7%
			AND GU7.GU7_NRCID = GU3.GU3_NRCID
			AND GU7.%NotDel%
			INNER JOIN %Table:SYA% SYA
			ON SYA.YA_FILIAL = %xFilial:SYA%
			AND SYA.YA_CODGI = GU7.GU7_CDPAIS
			AND SYA.%NotDel%
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:(cAliGWM)->DESTINATA%
			AND GU3.%NotDel%
		EndSql
		If (cAliasGU3)->(!Eof())
			cNmEmiDest := TrataCampo((cAliasGU3)->GU3_NMEMIT, 50)
			cCdCidd    := (cAliasGU3)->GU3_NRCID
			cUF        := (cAliasGU3)->GU7_CDUF
			cCidade    := (cAliasGU3)->GU7_NMCID
			cPais      := (cAliasGU3)->YA_DESCR
		EndIf
		(cAliasGU3)->(dbCloseArea())

		// Busca dados cidade
		If !Empty((cAliGWM)->GW1_ENTNRC)
			cCdCidd := (cAliGWM)->GW1_ENTNRC
			
			cAliasGU7 := GetNextAlias()
			BeginSql Alias cAliasGU7
				SELECT GU7.GU7_CDUF,
						GU7.GU7_NMCID,
						GU7.GU7_CDPAIS,
						SYA.YA_DESCR
				FROM %Table:GU7% GU7
				INNER JOIN %Table:SYA% SYA
				ON SYA.YA_FILIAL = %xFilial:SYA%
				AND SYA.YA_CODGI = GU7.GU7_CDPAIS
				AND SYA.%NotDel%
				WHERE GU7.GU7_FILIAL = %xFilial:GU7%
				AND GU7.GU7_NRCID = %Exp:(cAliGWM)->GW1_ENTNRC%
				AND GU7.%NotDel%
			EndSql
			If (cAliasGU7)->(!Eof())
				cUF     := (cAliasGU7)->GU7_CDUF
				cCidade := (cAliasGU7)->GU7_NMCID
				cPais   := (cAliasGU7)->YA_DESCR
			EndIf
			(cAliasGU7)->(dbCloseArea())
		EndIf

		// Busca nome emitente remetente
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_NMEMIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:(cAliGWM)->REMETENTE%
			AND GU3.%NotDel%
		EndSql
		If (cAliasGU3)->(!Eof())
			cNmEmiRem := TrataCampo((cAliasGU3)->GU3_NMEMIT, 50)
		EndIf
		(cAliasGU3)->(dbCloseArea())

		// Busca nome do transportador
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_NMEMIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:(cAliGWM)->GWN_CDTRP%
			AND GU3.%NotDel%
		EndSql
		If (cAliasGU3)->(!Eof())
			cNmEmiTrp := TrataCampo((cAliasGU3)->GU3_NMEMIT, 50)
		EndIf
		(cAliasGU3)->(dbCloseArea())

		// Busca descrição do tipo de veículo
		cAliasGV3 := GetNextAlias()
		BeginSql Alias cAliasGV3
			SELECT GV3.GV3_DSTPVC
			FROM %Table:GV3% GV3
			WHERE GV3.GV3_FILIAL = %xFilial:GV3%
			AND GV3.GV3_CDTPVC = %Exp:(cAliGWM)->VEICULO%
			AND GV3.%NotDel%
		EndSql
		If (cAliasGV3)->(!Eof())
			cDsTpVc := TrataCampo((cAliasGV3)->GV3_DSTPVC, 10) 
		EndIf
		(cAliasGV3)->(dbCloseArea())

		// Busca descrição do tipo de operador
		cAliasGV4 := GetNextAlias()
		BeginSql Alias cAliasGV4
			SELECT GV4.GV4_DSTPOP
			FROM %Table:GV4% GV4
			WHERE GV4.GV4_FILIAL = %xFilial:GV4%
			AND GV4.GV4_CDTPOP = %Exp:(cAliGWM)->GWN_CDTPOP%
			AND GV4.%NotDel%
		EndSql
		If (cAliasGV4)->(!Eof())
			cDsTpOp  := TrataCampo((cAliasGV4)->GV4_DSTPOP, 50)
		EndIf
		(cAliasGV4)->(dbCloseArea())

		// Busca descrição da classificação
		cAliasGUB := GetNextAlias()
		BeginSql Alias cAliasGUB
			SELECT GUB.GUB_DSCLFR
			FROM %Table:GUB% GUB
			WHERE GUB.GUB_FILIAL = %xFilial:GUB%
			AND GUB.GUB_CDCLFR = %Exp:(cAliGWM)->GWN_CDCLFR%
			AND GUB.%NotDel%
		EndSql
		If (cAliasGUB)->(!Eof())
			cDsClFr := TrataCampo((cAliasGUB)->GUB_DSCLFR, 50)
		EndIf
		(cAliasGUB)->(dbCloseArea())

		// Busca sentido e descrição do tipo de documento
		nPos := aScan(aCacheGV5, {|x| Alltrim(x[2]) == Alltrim((cAliGWM)->TIPO_DC)})
		If nPos > 0
			cSentido := TrataCampo(aCacheGV5[nPos][4], 15)
			cDsTpDc  := TrataCampo(aCacheGV5[nPos][3], 50)
		EndIf
		// Data entrega
		If !Empty((cAliGWM)->GWU_DTENT)
			dDtEntTr  := SToD((cAliGWM)->GWU_DTENT)
			cHorEntTr := (cAliGWM)->GWU_HRENT
		EndIf

		// Grava dados
		RecLock(cAliasDf, .T.)
			(cAliasDf)->EMPRESA	      := cEmpTDf
			(cAliasDf)->FILIAL	      := cFilTDf
			(cAliasDf)->REGIAOCOM     := (cAliGWM)->REGIAOCOM
			(cAliasDf)->GW1_REPRES    := cRepres
			(cAliasDf)->TRANSP    	  := (cAliGWM)->GWM_CDTRP
			(cAliasDf)->DESTINATA  	  := (cAliGWM)->DESTINATA
			(cAliasDf)->GW1_NMDEST    := cNmEmiDest
			(cAliasDf)->REMETENTE     := (cAliGWM)->REMETENTE
			(cAliasDf)->GW1_NMREM     := cNmEmiRem
			(cAliasDf)->TIPO_DC    	  := (cAliGWM)->TIPO_DC
			(cAliasDf)->TIPOFRETE     := cTipFrete
			(cAliasDf)->GW1_SERDC     := cSerDc
			(cAliasDf)->GW1_NRDC      := cNrDc
			(cAliasDf)->ROMANEIO      := cRomaneio
			(cAliasDf)->LACRE         := cLacre
			(cAliasDf)->GW1_DTIMPL    := dDtImpl
			(cAliasDf)->GW1_DTEMIS    := dDtEmis
			(cAliasDf)->GW1_HRIMPL    := cHorImpl
			(cAliasDf)->GW1_DTSAI     := dDtSaida
			(cAliasDf)->GW1_HRSAI     := cHorSaida
			(cAliasDf)->GW1_DTPENT    := dDtPEntr
			(cAliasDf)->GW1_HRPENT    := cHorPEntr
			(cAliasDf)->GW1_DTPSAI    := dDtPSaida
			(cAliasDf)->GW1_HRPSAI    := cHorPSaida
			(cAliasDf)->GW1_USO       := cUso
			(cAliasDf)->GW1_EMISDC    := (cAliGWM)->GWM_EMISDC
			(cAliasDf)->SEQUENCIA     := (cAliGWM)->SEQUENCIA
			(cAliasDf)->GW8_QTDE      := (cAliGWM)->GW8_QTDE
			(cAliasDf)->GW8_PESOR     := (cAliGWM)->GW8_PESOR
			(cAliasDf)->GW8_VOLUME    := (cAliGWM)->GW8_VOLUME
			(cAliasDf)->GW8_PESOC     := (cAliGWM)->GW8_PESOC //30
			(cAliasDf)->UNINEG    	  := (cAliGWM)->UNINEG
			(cAliasDf)->NATUOPER      := (cAliGWM)->NATUOPER
			(cAliasDf)->CANALVENDA 	  := (cAliGWM)->CANALVENDA
			(cAliasDf)->ITEM      	  := (cAliGWM)->ITEM
			(cAliasDf)->GW8_VALOR     := (cAliGWM)->GW8_VALOR
			(cAliasDf)->GWN_CDTPOP    := cCdTpOp
			(cAliasDf)->VEICULO       := (cAliGWM)->VEICULO
			(cAliasDf)->GV3_DSTPVC    := cDsTpVc
			(cAliasDf)->GV4_DSTPOP    := cDsTpOp
			(cAliasDf)->GV5_SENTID    := cSentido
			(cAliasDf)->GV5_DSTPDC    := cDsTpDc
			(cAliasDf)->GUB_DSCLFR    := cDsClFr
			(cAliasDf)->REGIAO        := (cAliGWM)->GU9_NMREG
			(cAliasDf)->GWU_DTENT     := dDtEntTr
			(cAliasDf)->GWU_HRENT     := cHorEntTr
			(cAliasDf)->GW_CDCIDD     := cCdCidd
			(cAliasDf)->UF       	  := cUF
			(cAliasDf)->CIDADE    	  := cCidade
			(cAliasDf)->PAIS		  := cPais
			(cAliasDf)->GW_NMEMI      := cNmEmiTrp
			(cAliasDf)->REDESPACHO    := cRedesp
			(cAliasDf)->CLASSFRETE    := (cAliGWM)->GWN_CDCLFR
			
			//Valores provisão.
			(cAliasDf)->VALORFRETE    := 0  
			(cAliasDf)->VL_DIARIA     := 0 
			(cAliasDf)->VL_ICMS       := 0 
			(cAliasDf)->Pr_TotPisC    := 0 
			(cAliasDf)->Pr_VlFrtNr    := 0 
			(cAliasDf)->Pr_ICMSnr     := 0 //60 
			(cAliasDf)->Pr_PISNorm    := 0 
			(cAliasDf)->Pr_Redesp     := 0 
			(cAliasDf)->Pr_ICMSRed    := 0 
			(cAliasDf)->Pr_PISRed     := 0 
			(cAliasDf)->Pr_TotRed     := 0 
			(cAliasDf)->Pr_ICMSDia    := 0 
			(cAliasDf)->Pr_PISDia     := 0 
			(cAliasDf)->Pr_TotDia     := 0 
			(cAliasDf)->Pr_VlReen     := 0 
			(cAliasDf)->Pr_ICMSRee    := 0 //70
			(cAliasDf)->Pr_PISRee     := 0 
			(cAliasDf)->Pr_TotReen    := 0 
			(cAliasDf)->Pr_VlDevol    := 0 
			(cAliasDf)->Pr_ICMSDev    := 0 
			(cAliasDf)->Pr_PISDev     := 0 
			(cAliasDf)->Pr_TotDev     := 0 
			(cAliasDf)->Pr_VlAuton    := 0 
			
			//Valores realização.
			(cAliasDf)->Re_TotFrt     := 0 
			(cAliasDf)->Re_TotICMS    := 0 
			(cAliasDf)->Re_TotPisC    := 0 //80
			(cAliasDf)->Re_FrtNorm    := 0 
			(cAliasDf)->Re_ICMSNr     := 0 
			(cAliasDf)->Re_PISNor     := 0 
			(cAliasDf)->Re_VlRedes    := 0 
			(cAliasDf)->Re_VlICRed    := 0 
			(cAliasDf)->Re_VlPisRe    := 0 
			(cAliasDf)->Re_TotRede    := 0 
			(cAliasDf)->Re_VlDiari    := 0 
			(cAliasDf)->Re_ICMSDia    := 0 
			(cAliasDf)->Re_PISDia     := 0 //90
			(cAliasDf)->Re_TotDia     := 0 
			(cAliasDf)->Re_VlTotRe    := 0 
			(cAliasDf)->Re_ICMSRe     := 0 
			(cAliasDf)->Re_PISRee     := 0 
			(cAliasDf)->Re_TotRee     := 0 
			(cAliasDf)->Re_VlTotDe    := 0 
			(cAliasDf)->Re_ICMSDev    := 0 
			(cAliasDf)->Re_PISDev     := 0 
			(cAliasDf)->Re_TotDev     := 0 
			(cAliasDf)->Re_VlAuto     := 0 //100
			(cAliasDf)->Re_TaxAuto    := 0 
			(cAliasDf)->Re_INSSAut    := 0
			
			PreencheValores()
		(cAliasDf)->( MsUnlock() )
	EndIf
	(cAliasQry)->(dbCloseArea())
Return

Static Function PreencheValores()

	//GWM_TPDOC => 1=Calculo Frete;2=CTRC/NFS;3=Contrato Autonomo;4=Estimativa Frete
	
	/* Previsto - CALCULO DE FRETE */
	If (cAliGWM)->GWM_TPDOC == "1"
		// GWF_TPCALC => 1=Normal;2=Compl Valor;3=Compl Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico;8=Estimativa
		
		//Total de PIS/COFINS
		(cAliasDf)->Pr_TotPisC += (cAliGWM)->VL_PISCOF 
		
		If SubStr((cAliGWM)->TPCALC, 3, 1) == "3"
			(cAliasDf)->Pr_VlAuton    += (cAliGWM)->VL_FRETE 
		EndIf
		
		// Normal
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "1" .Or. SubStr((cAliGWM)->TPCALC, 1, 1) == "2" .Or. SubStr((cAliGWM)->TPCALC, 1, 1) == "3"
			(cAliasDf)->Pr_VlFrtNr += (cAliGWM)->VL_FRETE
			(cAliasDf)->Pr_ICMSnr  += (cAliGWM)->VL_ICMS
			(cAliasDf)->Pr_PISNorm += (cAliGWM)->VL_PISCOF
		EndIf
		
		//Reentrega
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "4"
			(cAliasDf)->Pr_VlReen  += (cAliGWM)->VL_FRETE
			(cAliasDf)->Pr_ICMSRee += (cAliGWM)->VL_ICMS
			(cAliasDf)->Pr_PISRee  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Pr_TotReen += 1
		EndIf
		
		//Devolução
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "5"
			(cAliasDf)->Pr_VlDevol += (cAliGWM)->VL_FRETE
			(cAliasDf)->Pr_ICMSDev += (cAliGWM)->VL_ICMS
			(cAliasDf)->Pr_PISDev  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Pr_TotDev  += 1
		EndIf
		
		// Redespacho
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "6"
			(cAliasDf)->Pr_Redesp  += (cAliGWM)->VL_FRETE
			(cAliasDf)->Pr_ICMSRed += (cAliGWM)->VL_ICMS
			(cAliasDf)->Pr_PISRed  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Pr_TotRed  += 1
		EndIf
		
		//Serviço
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "7"
			(cAliasDf)->VL_DIARIA  += (cAliGWM)->VL_FRETE
			(cAliasDf)->Pr_ICMSDia += (cAliGWM)->VL_ICMS
			(cAliasDf)->Pr_PISDia  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Pr_TotDia  += 1
		EndIf
		
		(cAliasDf)->VALORFRETE := (cAliasDf)->Pr_VlFrtNr + (cAliasDf)->Pr_Redesp + (cAliasDf)->Pr_VlReen + (cAliasDf)->Pr_VlDevol + (cAliasDf)->VL_DIARIA
		(cAliasDf)->VL_ICMS    := (cAliasDf)->Pr_ICMSnr + (cAliasDf)->Pr_ICMSRed + (cAliasDf)->Pr_ICMSRee + (cAliasDf)->Pr_ICMSDev + (cAliasDf)->Pr_ICMSDia
	EndIf

	/* Realizado - DOCUMENTO DE FRETE */
	If (cAliGWM)->GWM_TPDOC == "2"
		// Normal
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "1" .Or. SubStr((cAliGWM)->TPCALC, 1, 1) == "2" .Or. SubStr((cAliGWM)->TPCALC, 1, 1) == "3"
			(cAliasDf)->Re_FrtNorm += (cAliGWM)->VL_FRETE
			(cAliasDf)->Re_ICMSNr  += (cAliGWM)->VL_ICMS
			(cAliasDf)->Re_PISNor  += (cAliGWM)->VL_PISCOF
		EndIf
		
		//Reentrega
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "4"	
			(cAliasDf)->Re_VlTotRe += (cAliGWM)->VL_FRETE
			(cAliasDf)->Re_ICMSRe  += (cAliGWM)->VL_ICMS
			(cAliasDf)->Re_PISRee  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Re_TotRee  += 1	
		EndIf
		
		//Devolução
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "5"	
			(cAliasDf)->Re_VlTotDe += (cAliGWM)->VL_FRETE
			(cAliasDf)->Re_ICMSDev += (cAliGWM)->VL_ICMS
			(cAliasDf)->Re_PISDev  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Re_TotDev  += 1
		EndIf
		
		//Redespacho
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "6"	
			(cAliasDf)->Re_VlRedes += (cAliGWM)->VL_FRETE
			(cAliasDf)->Re_VlICRed += (cAliGWM)->VL_ICMS
			(cAliasDf)->Re_VlPisRe += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Re_TotRede += 1
		EndIf
		
		//Serviço
		If SubStr((cAliGWM)->TPCALC, 1, 1) == "7"	
			(cAliasDf)->Re_VlDiari += (cAliGWM)->VL_FRETE
			(cAliasDf)->Re_ICMSDia += (cAliGWM)->VL_ICMS
			(cAliasDf)->Re_PISDia  += (cAliGWM)->VL_PISCOF
			(cAliasDf)->Re_TotDia  += 1
		EndIf
		
		//Totais
		(cAliasDf)->Re_TotFrt  := (cAliasDf)->Re_FrtNorm  + (cAliasDf)->Re_VlRedes + (cAliasDf)->Re_VlTotRe + (cAliasDf)->Re_VlTotDe + (cAliasDf)->Re_VlDiari 
		(cAliasDf)->Re_TotICMS := (cAliasDf)->Re_ICMSNr + (cAliasDf)->Re_VlICRed + (cAliasDf)->Re_ICMSRe + (cAliasDf)->Re_ICMSDev + (cAliasDf)->Re_ICMSDia
		(cAliasDf)->Re_TotPisC := (cAliasDf)->Re_PISNor + (cAliasDf)->Re_VlPisRe + (cAliasDf)->Re_PISRee + (cAliasDf)->Re_PISDev + (cAliasDf)->Re_PISDia
	EndIf
	
	/* Realizado - CONTRATO AUTONOMO */
	If (cAliGWM)->GWM_TPDOC == "3" 
		//Autonomo
		(cAliasDf)->Re_VlAuto  += (cAliGWM)->VL_FRETE
		(cAliasDf)->Re_TaxAuto += (cAliGWM)->VL_INEM + (cAliGWM)->VL_IRRF + (cAliGWM)->VL_SEST
		(cAliasDf)->Re_INSSAut += (cAliGWM)->VL_INAU
	EndIf
Return
		
//Tratamento dos valores
Static Function TrataCampo(cValor, nTam, xType)
	Local xRet := ""

	Default xType := "C"
	
	If Empty(cValor)
		xRet :=  Replicate("_", nTam)
	EndIf
	
	If xType == "N"
		xRet := cValToChar(cValor)
	Else
		xRet := cValor
	EndIf
Return xRet

//-------------------------------------------------------
//Função Sentido do Documento
//-------------------------------------------------------
Function LoadGV5()	
	Local aReg       := {}
	Local aComboBox  := StrTokArr(Posicione("SX3",2,"GV5_SENTID","X3_CBOX"),';')
	Local nPos       := 0
	Local cDscSentid := ""
	
	dbSetOrder(1)
	Do While GV5->(!Eof())
		nPos := aScan(aComboBox, GV5->GV5_SENTID)
		If nPos > 0
			cDscSentid := aComboBox[nPos]
		EndIf
	
		Aadd(aReg, {GV5->( Recno() ), GV5->GV5_CDTPDC, GV5->GV5_DSTPDC, GV5->GV5_SENTID, cDscSentid})
		
		GV5->(dbSkip())
	EndDo
Return aReg

//-------------------------------------------------------
//Função Tipo de Veículo
//-------------------------------------------------------

Function LoadGV3()
	Local aReg := {}
	
	dbSetOrder(1)
	Do While GV3->(!Eof())
		Aadd(aReg, {GV3->( Recno() ), GV3->GV3_CDTPVC, GV3->GV3_DSTPVC})
		
		GV3->(dbSkip())
	EndDo
Return aReg

//-------------------------------------------------------
//Função FormataValor
//-------------------------------------------------------

Static Function FormataValor(nValor, cPic)
	Local cRet := Transform(nValor, cPic)

	cRet = AllTrim(Replace(cRet, ".", ""))
Return cRet


//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------

Static Function SchedDef()
	Local aParam := {}
	Local aOrd   := {}

	aParam := {;
			   "P"			,;  // Tipo: R para relatorio P para processo
			   "GFEBI01"	,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
			   "GW1"      ,;  // Alias
			   aOrd       ,;  // Array de ordens
			  }
Return aParam

/**/

Static Function GravaTTRES()
	Local cTmpTabDf  := "%"+oTmpTabDf:GetRealName()+"%"
	Local cAliasQry  := Nil
	Local cSerDC     := IIf(Empty((cAliGWM)->GWM_SERDC), "_____", (cAliGWM)->GWM_SERDC)
	Local cTipFrete  := ""
	Local cNrDc      := ""

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT TDF.R_E_C_N_O_ RECNOTDF
		FROM %Exp:cTmpTabDf% TDF
		WHERE TDF.FILIAL = %Exp:(cAliGWM)->GWM_FILIAL%
		AND TDF.TIPO_DC = %Exp:(cAliGWM)->GWM_CDTPDC%
		AND TDF.GW1_EMISDC = %Exp:(cAliGWM)->GWM_EMISDC%
		AND TDF.GW1_SERDC = %Exp:cSerDC%
		AND TDF.GW1_NRDC = %Exp:(cAliGWM)->GWM_NRDC%
		AND TDF.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		(cAliasDf)->(dbGoto((cAliasQry)->RECNOTDF))
		// Alteração
		RecLock(cAliasDf, .F.)
			PreencheValores()
		(cAliasDf)->( MsUnlock() )
	Else //Cria um novo registro para ser gravado.
		// Inicializa variaveis
		cTipFrete := IIf(Empty((cAliGWM)->TIPOFRETE), "0", (cAliGWM)->TIPOFRETE)
		cNrDc     := TrataCampo((cAliGWM)->GW1_NRDC, 16)

		RecLock(cAliasDf, .T.)
			(cAliasDf)->EMPRESA	   := cEmpAnt
			(cAliasDf)->FILIAL	   := (cAliGWM)->GWM_FILIAL
			(cAliasDf)->TIPO_DC    := (cAliGWM)->TIPO_DC
			(cAliasDf)->TIPOFRETE  := cTipFrete
			(cAliasDf)->GW1_SERDC  := cSerDC //TrataCampo((cAliGWM)->GW1_SERDC, 5) 
			(cAliasDf)->GW1_NRDC   := cNrDc
			(cAliasDf)->GW1_EMISDC := (cAliGWM)->GWM_EMISDC

			//Valores provisão.
			(cAliasDf)->VALORFRETE := 0  
			(cAliasDf)->VL_DIARIA  := 0 
			(cAliasDf)->VL_ICMS    := 0 
			(cAliasDf)->Pr_TotPisC := 0 
			(cAliasDf)->Pr_VlFrtNr := 0 
			(cAliasDf)->Pr_ICMSnr  := 0 //60 
			(cAliasDf)->Pr_PISNorm := 0 
			(cAliasDf)->Pr_Redesp  := 0 
			(cAliasDf)->Pr_ICMSRed := 0 
			(cAliasDf)->Pr_PISRed  := 0 
			(cAliasDf)->Pr_TotRed  := 0 
			(cAliasDf)->Pr_ICMSDia := 0 
			(cAliasDf)->Pr_PISDia  := 0 
			(cAliasDf)->Pr_TotDia  := 0 
			(cAliasDf)->Pr_VlReen  := 0 
			(cAliasDf)->Pr_ICMSRee := 0 //70
			(cAliasDf)->Pr_PISRee  := 0 
			(cAliasDf)->Pr_TotReen := 0 
			(cAliasDf)->Pr_VlDevol := 0 
			(cAliasDf)->Pr_ICMSDev := 0 
			(cAliasDf)->Pr_PISDev  := 0 
			(cAliasDf)->Pr_TotDev  := 0 
			(cAliasDf)->Pr_VlAuton := 0 
			
			//Valores realização.
			(cAliasDf)->Re_TotFrt  := 0 
			(cAliasDf)->Re_TotICMS := 0 
			(cAliasDf)->Re_TotPisC := 0 //80
			(cAliasDf)->Re_FrtNorm := 0 
			(cAliasDf)->Re_ICMSNr  := 0 
			(cAliasDf)->Re_PISNor  := 0 
			(cAliasDf)->Re_VlRedes := 0 
			(cAliasDf)->Re_VlICRed := 0 
			(cAliasDf)->Re_VlPisRe := 0 
			(cAliasDf)->Re_TotRede := 0 
			(cAliasDf)->Re_VlDiari := 0 
			(cAliasDf)->Re_ICMSDia := 0 
			(cAliasDf)->Re_PISDia  := 0 //90
			(cAliasDf)->Re_TotDia  := 0 
			(cAliasDf)->Re_VlTotRe := 0 
			(cAliasDf)->Re_ICMSRe  := 0 
			(cAliasDf)->Re_PISRee  := 0 
			(cAliasDf)->Re_TotRee  := 0 
			(cAliasDf)->Re_VlTotDe := 0 
			(cAliasDf)->Re_ICMSDev := 0 
			(cAliasDf)->Re_PISDev  := 0 
			(cAliasDf)->Re_TotDev  := 0 
			(cAliasDf)->Re_VlAuto  := 0 //100
			(cAliasDf)->Re_TaxAuto := 0 
			(cAliasDf)->Re_INSSAut := 0
			
			PreencheValores()
		(cAliasDf)->( MsUnlock() )		
	EndIf
Return

/*Carrega o De/Para de empresa e filial de acordo com os parâmetros MV_EMPBI e MV_FILBI*/
Function LoadFil()

	Local aAllFil := FWLoadSM0()
	Local nCont, cEmpBI, cFilBI
	Local aArrFil := {}
	
	For nCont := 1 to Len(aAllFil)
		cEmpBI := LoadEmpBI(aAllFil[nCont][2])
		cFilBI := LoadFilBI(aAllFil[nCont][2])
		If !Empty(cEmpBI) .And. !Empty(cFilBI)
			Aadd(aArrFil, {Alltrim(aAllFil[nCont][1]), Alltrim(aAllFil[nCont][2]), Alltrim(cEmpBI), Alltrim(cFilBI)})
		EndIf
	Next nCont
	
	If Empty(aArrFil)
		cEmpBI := Alltrim(SuperGetMv("MV_EMPBI",,""))
		cFilBI := Alltrim(SuperGetMv("MV_FILBI",,""))
		If !Empty(cEmpBI) .And. !Empty(cFilBI)
			Aadd(aArrFil, {Alltrim(aAllFil[1][1]), Alltrim(aAllFil[1][2]), Alltrim(cEmpBI), Alltrim(cFilBI)})
		EndIf
	EndIf
	
	If Empty(aArrFil)
		For nCont := 1 to Len(aAllFil)
			Aadd(aArrFil, {Alltrim(aAllFil[nCont][1]), Alltrim(aAllFil[nCont][2]), Alltrim(aAllFil[nCont][1]), Alltrim(aAllFil[nCont][2])})
		Next nCont
	EndIf
Return aArrFil

Function LoadEmpBI(cEmpBI)
Return Alltrim(SuperGetMv("MV_EMPBI",,"",cEmpBI))

Function LoadFilBI(cFilBI)
Return Alltrim(SuperGetMv("MV_FILBI",,"",cFilBI))

/*Retorna a empresa e filial correspondente do DTS.*/
Function RetEmpFil(cEmpGFE, cFilGFE)

	Local aEmpFil := {cEmpGFE, cFilGFE}
	Local nPos
	
	nPos := aScan(aArrFil, { |x| x[1] == Alltrim(cEmpGFE) .AND. x[2] == Alltrim(cFilGFE)}) 

	If nPos > 0
		aEmpFil[1] := aArrFil[nPos][3]
		aEmpFil[2] := aArrFil[nPos][4]
	Else
		aEmpFil[1] := Alltrim(SuperGetMv("MV_EMPBI",,""))
		aEmpFil[2] := Alltrim(SuperGetMv("MV_FILBI",,""))
	EndIf

Return aEmpFil

/*----------------------------------------------------------------------------
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
----------------------------------------------------------------------------*/
Function AddToTxtBI(cTexto, nPosicao)

Local nLimit := 1000000

Default nPosicao := _TXT_END

If nPosicao == _TXT_BEGIN // inicio do log (1)
	cTxtArq := cTexto // + cTxtArq
Else	// final do log (2)
	cTxtArq += cTexto
EndIf

if len(cTxtArq) > nLimit
	SaveLogBI()
EndIf

Return NIL

/*----------------------------------------------------------------------------
{Protheus.doc} SaveLog
Salva o log em um arquivo texto
Uso: SaveLog

@sample SaveLog()

@author Luciano de Araujo
@since 25/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function SaveLogBI()

Local nHandle := 0

cInfoLine := If(!Empty(cInfoLine),cInfoLine+CRLF,"") //Retira o último ponto e vírgula e adiciona uma quebra de linha
if !File(cArqLog)  // Arquivo não existe
	// Cria o arquivo de log
	nHandle := FCreate(cArqLog,FC_NORMAL)
	FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
Else	// Arquivo existe
	nHandle := FOpen(cArqLog,FO_READWRITE)
	FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
EndIf

FWrite(nHandle,cInfoLine+cTxtArq,len(cInfoLine+cTxtArq)) // Grava o conteudo da variavel no arquivo de log
cInfoLine := "" //Apaga seu conteúdo pois é necessário imprimí-la apenas uma vez

FClose(nHandle) // Fecha o arquivo de log

cTxtArq := "" // "Zera" a variavel

Return NIL

/*----------------------------------------------------------------------------
{Protheus.doc} XML
Retorna um Array com os parametros do XML
Uso: Restrito

@sample GFEBIXML(Caminho do XML)

@author Luciano de Araujo
@since 25/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEBIXML(cXMLDir)
	Local cError   := ""
	Local cWarning := ""
	Local aParam := Array(3), aFiles := {}
	Local cArquivo
	Local cExtensao

	GFEConout("INFO", "cXMLDir: " + cXMLDir)

	If !File(cXMLDir)
		Help( ,, 'HELP',, "Arquivo '" + cXMLDir + "' não encontrado." , 1, 0,)
	EndIf

	// Faz a copia do arquivo client para o servidor
	SplitPath (cXMLDir, , , cArquivo, cExtensao )

	GFEConout("INFO", "cArquivo.: " + cArquivo)
	GFEConout("INFO", "cExtensao: " + cExtensao)

	CpyT2S(cXMLDir, "\", .F. )

	oXML := XmlParserFile(AllTrim(cArquivo + cExtensao), '_', @cError, @cWarning)

	If !Empty(cError) .Or. !Empty(cWarning)
		GFEConout("ERROR", "cError..: " + cError)
		GFEConout("WARNING", "cWarning: " + cWarning)
		Help( ,, 'HELP',, cError + CHR(13)+CHR(10) + cWarning , 1, 0,)
		Return
	EndIf

	//TipoPeriodo
	If oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[1]:TEXT == "0"
		aParam[1] := CtoD(oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[2]:TEXT) //DataInicio
		aParam[2] := CtoD(oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[3]:TEXT)//DataTermino
	Else
		aParam[1] := date() - ABS(VAL(oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[4]:TEXT)) //IntervaloInicio
		aParam[2] := date() + ABS(VAL(oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[5]:TEXT))//IntervaloTermino
	EndIf

	//DirExp
	aParam[3] := oXML:_PARAMSBUILDER:_VALUES:_CONTROLVALUE[13]:TEXT

	GFEConout("INFO", "aParam[1]: " + cValToChar(aParam[1]))
	GFEConout("INFO", "aParam[2]: " + cValToChar(aParam[2]))
	GFEConout("INFO", "aParam[3]: " + aParam[3])

	If File("\" + cArquivo + cExtensao)
		GFEConout("INFO", "Eliminando arquivo do Server")
		FErase("\" + cArquivo + cExtensao)
	EndIf
Return aParam

Function geraStruct(cTabela)

	Local aStruct := {}
	Local nX
	Local aStructSX	:= FWFormStruct(3,cTabela)[1] //Todos os Campos
	Local oStructX3	:= GFESeekSX():New()
	
	For nX := 1 to Len(aStructSX)
		
		oStructX3:SeekX3(aStructSX[nX,3],.F.,.F.,.T.)
		
		aadd(aStruct, {AllTrim(aStructSX[nX,3]), aStructSX[nX,4], oStructX3:getX3Tamanho(), oStructX3:getX3Decimal()})
	Next nX
	oStructX3:Destroy()

Return aStruct

//-------------------------------------------------------
//Função SeekLast
//-------------------------------------------------------

Function SeekLast(cTabela,nOrder,cFiltro)
	dbSelectArea(cTabela)
	dbSetOrder(nOrder)
	DbSetFilter( {|| &cFiltro }, cFiltro )
	DBGoBottom()
Return
