#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX100 

Monitor de Integrações

@author Felipe Mendes
@since 02/02/12
@version 1.0
/*/
//-------------------------------------------------------------------             
Function GFEX100()

Local aCampos, nCont  
Local s_ERPGFE  := SuperGetMV("MV_ERPGFE",,"2")
Private cAliX100, oBrowse
Private s_GFEX100 := Pergunte("GFEX100",.T.)


aCampos := {{"Situação"  	,"GW_SITINT"  ,"C", 01, 0, "@!"},;
			{"Filial"		,"GW_FILIAL"  ,"C", FWSizeFilial(), 0, "@!"},;
			{"Tabela"		,"GW_DESTAB"  ,"C", 20, 0, "@!"},;
			{"Emissor"		,"GW_CDEMIS"  ,"C", 10, 0, "@!"},;
			{"Nome Emissor"	,"GW_NMEMIS"  ,"C", 25, 0, "@!"},;
			{"Série"		,"GW_SER"	  ,"C", 05, 0, "@!"},;
			{"Nr.Doc."		,"GW_NRDOC"	  ,"C", 16, 0, "@!"},;
			{"Apto" 		,"GW_APTO"    ,"C", 01, 0, "@!"},;
			{"Dt.Emissão"	,"GW_DTEMIS"  ,"D", 08, 0, ""},;
			{"Dt.Criação"	,"GW_DTCRIA"  ,"D", 08, 0, ""},;
			{"Dt.Impressão"	,"GW_DTIMPRE" ,"D", 08, 0, ""},;
			{"Dt.Vencto"	,"GW_DTVENC"  ,"D", 08, 0, ""},;
			{"Financeiro"	,"GW_FIN"	  ,"C", 01, 0, ""},;
			{"Dt.Fin"		,"GW_DTFIN"	  ,"D", 08, 0, ""},;
			{"Fiscal"		,"GW_FIS"	  ,"C", 01, 0, ""},;
			{"Dt.Fisc"		,"GW_DTFIS"   ,"D", 08, 0, ""},;
			{"Materiais"	,"GW_REC"	  ,"C", 01, 0, ""},;
			{"Dt.Mat"		,"GW_DTREC"	  ,"D", 08, 0, ""},;
			{"Folha Pagto"	,"GW_RH"	  ,"C", 01, 0, ""},;
			{"Dt.FP"		,"GW_DTRH"		,"D", 08, 0, ""}}
			
If GFXTB12117("GWC")
	aAdd(aCampos,{"Custo de Frete"	,"GW_CUS"	,"C", 01, 0, ""})
	aAdd(aCampos,{"Dt.Cus"			,"GW_DTCUS"	,"D", 08, 0, ""})
EndIf

If !s_GFEX100   
	Return .F.
EndIf

While MV_PAR01 == 1 .AND. MV_PAR02 == 1 .AND. MV_PAR03 == 1 .AND. MV_PAR04 == 1
   
	If MV_PAR01 == 1 .AND. MV_PAR02 == 1 .AND. MV_PAR03 == 1 .AND. MV_PAR04 == 1
	    Help( ,, 'HELP',, "É necessário escolher uma opção", 1, 0) 
	    Return .F.
	EndIf
	If !s_GFEX100 
		Return .F.
    EndIf    
    
EndDo 
 
//Cria a tabela usada no monitor
GFEX100CriaTab()
//Abestece a tabela com dados
GFEX100Dados()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAliX100)
oBrowse:SetMenuDef('GFEX100')
oBrowse:DisableFilter()
oBrowse:SetDescription("Monitor de Integração")

For nCont := 1 to Len( aCampos )
	
	If aCampos[nCont][2] == "GW_NMEMIS"
    	
    	oBrowse:AddColumn( {aCampos[nCont][1],&("{|| POSICIONE('GU3',1,xFilial('GU3')+(cAliX100)->" + aCampos[nCont-1][2] + ",'GU3_NMEMIT')}"),aCampos[nCont][3],aCampos[nCont][6],1,aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} } )
    	
    ElseIf aCampos[nCont][2] == "GW_SITINT"
		
   		oBrowse:AddLegend("GW_SITINT=='1'", "BLUE" ,"Integrado"     ,"GW_SITINT")
		oBrowse:AddLegend("GW_SITINT=='2'", "RED"  ,"Não Integrado" ,"GW_SITINT")
		
    ElseIf aCampos[nCont][2] == "GW_APTO"
    	
		oBrowse:AddLegend("GW_APTO=='1'", "BLUE" ,"Sim" ,"GW_APTO")
		oBrowse:AddLegend("GW_APTO=='2'", "RED"  ,"Não" ,"GW_APTO")
		
    ElseIf aCampos[nCont][2] == "GW_FIN"
  		
		oBrowse:AddLegend("GW_FIN=='1'", "WHITE"  ,"Não Enviado" ,"GW_FIN")
		oBrowse:AddLegend("GW_FIN=='2'", "YELLOW" ,"Pendente"    ,"GW_FIN")
		oBrowse:AddLegend("GW_FIN=='3'", "RED"    ,"Rejeitado"   ,"GW_FIN")
		oBrowse:AddLegend("GW_FIN=='4'", "BLUE"   ,"Atualizado"  ,"GW_FIN")
		oBrowse:AddLegend("GW_FIN=='5'", "ORANGE" ,"Pend.Canc."  ,"GW_FIN")
     	oBrowse:AddLegend("GW_FIN=='6'", "BLACK"  ,"Não Integra" ,"GW_FIN")
		
	ElseIf aCampos[nCont][2] == "GW_FIS"
		
		oBrowse:AddLegend("GW_FIS=='1'", "WHITE"  ,"Não Enviado" ,"GW_FIS")
		oBrowse:AddLegend("GW_FIS=='2'", "YELLOW" ,"Pendente"    ,"GW_FIS")
		oBrowse:AddLegend("GW_FIS=='3'", "RED"    ,"Rejeitado"   ,"GW_FIS")
		oBrowse:AddLegend("GW_FIS=='4'", "BLUE"   ,"Atualizado"  ,"GW_FIS")
		oBrowse:AddLegend("GW_FIS=='5'", "ORANGE" ,"Pend.Canc."  ,"GW_FIS")
		oBrowse:AddLegend("GW_FIS=='6'", "BLACK"  ,"Não Integra" ,"GW_FIS")
		
	ElseIf aCampos[nCont][2] == "GW_REC"
	 	
		oBrowse:AddLegend("GW_REC=='1'", "WHITE"  ,"Não Enviado" ,"GW_REC")
		oBrowse:AddLegend("GW_REC=='2'", "YELLOW" ,"Pendente"    ,"GW_REC")
		oBrowse:AddLegend("GW_REC=='3'", "RED"    ,"Rejeitado"   ,"GW_REC")
		oBrowse:AddLegend("GW_REC=='4'", "BLUE"   ,"Atualizado"  ,"GW_REC")
		oBrowse:AddLegend("GW_REC=='5'", "ORANGE" ,"Pend.Canc."  ,"GW_REC")
		oBrowse:AddLegend("GW_REC=='6'", "BLACK"  ,"Não Integra" ,"GW_REC")
  		
	ElseIf aCampos[nCont][2] == "GW_CUS"
	 	
		oBrowse:AddLegend("GW_CUS=='1'", "WHITE"  ,"Não Enviado" ,"GW_CUS")
		oBrowse:AddLegend("GW_CUS=='2'", "BLUE"   ,"Atualizado"  ,"GW_CUS")
		oBrowse:AddLegend("GW_CUS=='3'", "RED"    ,"Rejeitado"   ,"GW_CUS")
		oBrowse:AddLegend("GW_CUS=='4'", "YELLOW" ,"Pendente"    ,"GW_CUS")
		oBrowse:AddLegend("GW_CUS=='0' .Or. GW_CUS==' '", "BLACK"  ,"Não Integra" ,"GW_CUS")

	ElseIf aCampos[nCont][2] $ "GW_RH/GW_DTRH/GW_MSGRH" .And. s_ERPGFE == "1"
	    
	  	If aCampos[nCont][2] == "GW_RH"
			oBrowse:AddLegend("GW_RH=='1'", "WHITE"  ,"Não Enviado" ,"GW_RH")
			oBrowse:AddLegend("GW_RH=='2'", "YELLOW" ,"Pendente"    ,"GW_RH")
			oBrowse:AddLegend("GW_RH=='3'", "RED"    ,"Rejeitado"   ,"GW_RH")
			oBrowse:AddLegend("GW_RH=='4'", "BLUE"   ,"Atualizado"  ,"GW_RH")
			oBrowse:AddLegend("GW_RH=='5'", "ORANGE" ,"Pend.Canc."  ,"GW_RH")
			oBrowse:AddLegend("GW_RH=='6'", "BLACK"  ,"Não Integra" ,"GW_RH")
		Else
			oBrowse:AddColumn( {aCampos[nCont][1],&("{|| (cAliX100)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],1,aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} } )
    	EndIf
	   		
    ElseIf !(aCampos[nCont][2] $ "GW_RH/GW_DTRH/GW_MSGRH")
    	oBrowse:AddColumn( {aCampos[nCont][1],&("{|| (cAliX100)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],1,aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} } )
    EndIf
    
Next nCont  

//Titulo das colunas de status
oBrowse:ACOLUMNS[01]:CTITLE := "Sit."
oBrowse:ACOLUMNS[08]:CTITLE := "Apto"
oBrowse:ACOLUMNS[13]:CTITLE := "Financeiro"
oBrowse:ACOLUMNS[15]:CTITLE := "Fiscal"
oBrowse:ACOLUMNS[17]:CTITLE := "Materiais"
If GFXTB12117("GWC")
	oBrowse:ACOLUMNS[19]:CTITLE := "Custo Frete"
	If s_ERPGFE == "1"
		oBrowse:ACOLUMNS[21]:CTITLE := "Folha Pagto"
	EndIf
Else
	If s_ERPGFE == "1"
		oBrowse:ACOLUMNS[19]:CTITLE := "Folha Pagto"
	EndIf
EndIf

oBrowse:Activate()
                                                                                    
GFEDelTab(cAliX100)
	
Return .T.
//-------------------------------------------------------------------------------------------------------    

Static Function MenuDef()
	Local aRotina := {}
	Local s_ERPGFE  := SuperGetMV("MV_ERPGFE",,"2")

	ADD OPTION aRotina TITLE "Visualizar"					ACTION 'GFEX100CON()'	OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE "Parâmetros"					ACTION "GFEX100PAR()"	OPERATION 3  ACCESS 0 //"Parâmetros"
	ADD OPTION aRotina TITLE "Enviar Financeiro"			ACTION "GFEX100INT(1)"	OPERATION 3  ACCESS 0 
	ADD OPTION aRotina TITLE "Enviar Fiscal"				ACTION "GFEX100INT(2)"	OPERATION 3  ACCESS 0 
	ADD OPTION aRotina TITLE "Enviar Materias"			ACTION "GFEX100INT(3)"	OPERATION 3  ACCESS 0 
	If s_ERPGFE == "1"
		ADD OPTION aRotina TITLE "Enviar Folha Pagto"		ACTION "GFEX100INT(4)"	OPERATION 3  ACCESS 0 
	Endif
	If GFXTB12117("GWC")
		ADD OPTION aRotina TITLE "Enviar Custo Frete"			ACTION "GFEX100INT(5)"	OPERATION 3  ACCESS 0
	EndIf
	ADD OPTION aRotina TITLE "Situação Financeiro"		ACTION "GFEX100Edt('GW_FIN')"  OPERATION 9  ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Situação Fiscal"			ACTION "GFEX100Edt('GW_FIS')"  OPERATION 9  ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Situação Materias"		ACTION "GFEX100Edt('GW_REC')"  OPERATION 9  ACCESS 0 DISABLE MENU
	If s_ERPGFE == "1"
		ADD OPTION aRotina TITLE "Situação Folha Pagto"	ACTION "GFEX100Edt('GW_RH')"   OPERATION 9  ACCESS 0 DISABLE MENU
	Endif
	If GFXTB12117("GWC")
		ADD OPTION aRotina TITLE "Situação Custo Frete"	ACTION "GFEX100Edt('GW_CUS')"  OPERATION 9  ACCESS 0 DISABLE MENU
	EndIf 

Return aRotina                                                                                     

//---------------------------------------------------------------------------------------------------
/*GFEX100CON
Chamada das consultas
Uso restrito 

@sample
GFEX100CON()

@author Felipe M.
@since 02/02/12
@version 1.0
/*///------------------------------------------------------------------------------------------------  

Function GFEX100CON()

dbSelectArea((cAliX100)->GW_TAB)
dbSetOrder(1)       
dbSeek(AllTrim((cAliX100)->GW_CHAVE)) 

//Verifica qual programa deve chamar atraves da tabela    
If (cAliX100)->GW_TAB == "GWJ"
    
    FWExecView("Frete Embarcador",'GFEC055', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 

ElseIf (cAliX100)->GW_TAB == "GW3"  

    FWExecView("Frete Embarcador",'GFEC065', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 

ElseIf (cAliX100)->GW_TAB == "GW6"
    
	FWExecView("Frete Embarcador",'GFEC070', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 

ElseIf (cAliX100)->GW_TAB == "GW2"
	
    FWExecView("Frete Embarcador",'GFEC100', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 

EndIf

Return       
//---------------------------------------------------------------------------------------------------
/*GFEX100CriaTab
Cria a estrutura da tabela
Uso restrito 

@sample
GFEX100CriaTab()

@author Felipe M.
@since 02/02/12
@version 1.0
/*///------------------------------------------------------------------------------------------------  
Static Function GFEX100CriaTab()
Local aCampos

aCampos := {{"GW_SITINT" ,"C",01,0},;
			{"GW_FILIAL"  ,"C",FWSizeFilial(),0},;
			{"GW_TAB"		,"C",03,0},;
			{"GW_DESTAB"	,"C",20,0},;
			{"GW_CDEMIS"	,"C",14,0},;
			{"GW_NMEMIS"	,"C",50,0},;
			{"GW_SER"		,"C",05,0},;
			{"GW_NRDOC"	,"C",16,0},;
			{"GW_APTO"  	,"C",01,0},;
			{"GW_DTEMIS"	,"D",08,0},;
			{"GW_DTCRIA"	,"D",08,0},;
			{"GW_DTIMPRE"	,"D",08,0},;
			{"GW_DTVENC"	,"D",08,0},;
			{"GW_FIN"		,"C",01,0},;
			{"GW_DTFIN"	,"D",08,0},;
			{"GW_FIS"		,"C",01,0},;
			{"GW_DTFIS" 	,"D",08,0},;
			{"GW_REC"		,"C",01,0},;
			{"GW_DTREC"	,"D",08,0},;
			{"GW_RH"		,"C",01,0},;
			{"GW_DTRH"  	,"D",08,0},;
			{"GW_CHAVE"   ,"C",99,0}}
If GFXTB12117("GWC")			
	aAdd(aCampos,{"GW_CUS"		,"C",01,0})
	aAdd(aCampos,{"GW_DTCUS"	,"D",08,0})
EndIf      

cAliX100 := GFECriaTab({aCampos,{"GW_FILIAL+GW_TAB+GW_CDEMIS+GW_NMEMIS+GW_SER+GW_NRDOC+DTOS(GW_DTEMIS)"}})

Return
//---------------------------------------------------------------------------------------------------
/*GFEX100Dados
Alimenta a tabela
Uso restrito 

@sample
GFEX100Dados()

@author Felipe M.
@since 02/02/12
@version 1.0
/*///------------------------------------------------------------------------------------------------  
Static Function GFEX100Dados()
Local cQuery := ''
Local lParSit4 := .F.
Local lParSit5 := .F.

dbSelectArea(cAliX100)
ZAP      

//Irá criar uma Query de acordo com as opções selecionadas pelo usuario
			
If MV_PAR01 != 1 
	//PRE-FATURAS DE FRETE
    
	cQuery += "SELECT "                                                                
	cQuery += "(CASE GWJ.GWJ_SITFIN WHEN '4' THEN '1' ELSE '2' END) AS  GW_SITINT, "
	cQuery += "GWJ.GWJ_FILIAL AS GW_FILIAL, "
	cQuery += "'GWJ'          AS GW_TAB,    "
	cQuery += "'PRE-FATURAS'  AS GW_DESTAB, "
	cQuery += "GWJ.GWJ_CDTRP  AS GW_CDEMIS, "
	cQuery += "''             AS GW_NMEMIS, "
	cQuery += "''             AS GW_SER,    "
	cQuery += "GWJ.GWJ_NRPF   AS GW_NRDOC,  "
	cQuery += "(CASE GWJ.GWJ_SIT WHEN '3' THEN '1' ELSE '2' END) AS  GW_APTO, "
	cQuery += "''             AS GW_DTEMIS, "
	cQuery += "GWJ.GWJ_DTIMPL AS GW_DTCRIA, "
	cQuery += "''             AS GW_DTIMPRE,"
	cQuery += "GWJ.GWJ_DTVCTO AS GW_DTVENC, "
	cQuery += "GWJ.GWJ_SITFIN AS GW_FIN,    "
	cQuery += "GWJ.GWJ_DTFIN  AS GW_DTFIN,  "
	cQuery += "'6'            AS GW_FIS,    " //6 - Não Integra 
	cQuery += "''             AS GW_DTFIS,  "
	cQuery += "'6'            AS GW_REC,    " //6 - Não Integra 
	cQuery += "''             AS GW_DTREC,  "
	cQuery += "'6'            AS GW_RH,     " //6 - Não Integra 
	cQuery += "''             AS GW_DTRH,   " 
	If GFXTB12117("GWC")
		cQuery += "'0'            AS GW_CUS,    " //0 - Não Integra 
		cQuery += "''             AS GW_DTCUS,  "
	EndIf 
	cQuery += "GWJ.GWJ_FILIAL || GWJ.GWJ_NRPF AS GW_CHAVE " 
	cQuery += " FROM " + RetSQLName( 'GWJ' ) + " GWJ WHERE GWJ.D_E_L_E_T_ = ' ' AND ( GWJ.GWJ_FILIAL >= '" + MV_PAR05 + "' AND GWJ.GWJ_FILIAL <= '" + MV_PAR06 +"' ) "
   
    If MV_PAR01 == 2 //filtra pela data de Implantação
    	cQuery += " AND ( ( GWJ.GWJ_DTIMPL >= '" + DtoS(MV_PAR07) + "' AND GWJ.GWJ_DTIMPL <= '" + DtoS(MV_PAR08) + "') OR GWJ.GWJ_DTIMPL = '' ) "
    ElseIf MV_PAR01 == 3//filtra pela data de Vencimento
    	cQuery += " AND ( ( GWJ.GWJ_DTVCTO >= '" + DtoS(MV_PAR07) + "' AND GWJ.GWJ_DTVCTO <= '" + DtoS(MV_PAR08) + "') OR GWJ.GWJ_DTVCTO = '' ) "
    EndIf
    
     //Verifica se o registro está integrado, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR09 == 1 
    	cQuery += " AND ( GWJ.GWJ_SITFIN = '4' ) "
    ElseIf MV_PAR09 == 2
     	cQuery += " AND ( GWJ.GWJ_SITFIN <> '4' ) "   
    EndIf  
    
    //Verifica se o registro está apto para a integração, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR10 == 1
    	cQuery += " AND ( GWJ.GWJ_SIT = '3' ) "
    ElseIf MV_PAR10 == 2
    	cQuery += " AND ( GWJ.GWJ_SIT <> '3' ) "
    EndIf 
    
    //verifica se há mais uma query a ser anexada
	If MV_PAR02 != 1 .OR. MV_PAR03 != 1 .OR. MV_PAR04 != 1  
		cQuery += " UNION ALL "
	EndIf      
	
EndIf

If MV_PAR02 != 1
	//DOCUMENTOS DE FRETE  

	cQuery += "SELECT "
	cQuery += "(CASE WHEN (GW3.GW3_SITFIS = '4' OR GW3.GW3_SITFIS = '6') AND (GW3.GW3_SITREC = '4' OR GW3.GW3_SITREC = '6') THEN '1' ELSE '2' END) AS  GW_SITINT, "
	cQuery += "GW3.GW3_FILIAL AS GW_FILIAL,  "
	cQuery += "'GW3'          AS GW_TAB,     "
	cQuery += "'DOC FRETE'    AS GW_DESTAB,  "
	cQuery += "GW3.GW3_EMISDF AS GW_CDEMIS,  "
	cQuery += "''             AS GW_NMEMIS,  "
	cQuery += "GW3.GW3_SERDF  AS GW_SER,     "
	cQuery += "GW3.GW3_NRDF   AS GW_NRDOC,       "
	cQuery += "(CASE  WHEN GW3.GW3_SIT IN('3','4') THEN '1' ELSE '2' END) AS  GW_APTO,"
	cQuery += "GW3.GW3_DTEMIS AS GW_DTEMIS,  "
	cQuery += "GW3.GW3_DTENT  AS GW_DTCRIA,  "
	cQuery += "''             AS GW_DTIMPRE, "
	cQuery += "''             AS GW_DTVENC,  "
	cQuery += "'6'            AS GW_FIN,     "  //6 - Não Integra 
	cQuery += "''             AS GW_DTFIN,   "
	cQuery += "GW3.GW3_SITFIS AS GW_FIS,     "
	cQuery += "GW3.GW3_DTFIS  AS GW_DTFIS,   "
	cQuery += "GW3.GW3_SITREC AS GW_REC,     "
	cQuery += "GW3.GW3_DTREC  AS GW_DTREC,   "
	cQuery += "'6'            AS GW_RH,      "//6 - Não Integra 
	cQuery += "''             AS GW_DTRH,    "
	If GFXTB12117("GWC")
		cQuery += "GW3.GW3_SITCUS AS GW_CUS,     "  
		cQuery += "GW3.GW3_DTCUS  AS GW_DTCUS,   " 
	EndIf
	cQuery += "GW3.GW3_FILIAL||GW3.GW3_CDESP||GW3.GW3_EMISDF||GW3.GW3_SERDF||GW3.GW3_NRDF||GW3.GW3_DTEMIS   AS GW_CHAVE "
	cQuery += " FROM " + RetSQLName( 'GW3' )+ " GW3 "

	IIF(SuperGetMV("MV_DSOFDT",.T.,"") == '2' .AND. SuperGetMV("MV_ERPGFE",.T.,"") == '1' .AND. MV_PAR10 == 1 ,lParSit4 := .T.,)
	
	IIF(SuperGetMV("MV_DSOFDT",.T.,"") == '2' .AND. SuperGetMV("MV_ERPGFE",.T.,"") == '1' .AND. MV_PAR10 == 2 ,lParSit5 := .T.,)

	//Validação da integração com o financeiro
	If lParSit4
		cQuery += "  INNER JOIN " + RetSQLName("GW6") + " GW6 ON "
		cQuery += "  	GW6.GW6_FILIAL = GW3.GW3_FILFAT"
		cQuery += " AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
		cQuery += " AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
		cQuery += " AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT"
		cQuery += " AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA "
	EndIf
	
	If lParSit5
	   cQuery += "  LEFT JOIN " + RetSQLName("GW6") + " GW6 ON "
	   cQuery += "  	GW6.GW6_FILIAL = GW3.GW3_FILFAT"
	   cQuery += " AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
	   cQuery += " AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
	   cQuery += " AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT"
	   cQuery += " AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA "
	EndIf 
	    
	cQuery += "WHERE GW3.D_E_L_E_T_ = ' ' AND ( GW3.GW3_FILIAL >= '" + MV_PAR05 + "' AND GW3.GW3_FILIAL <= '" + MV_PAR06 + "' ) "

	//Validação após where (4-Atualizada)
	If lParSit4
		cQuery += " AND GW6.GW6_SITFIN = '4' "
	EndIf
	
	//filtra pela data de entrada ou emissão
    If MV_PAR02 == 2
    	cQuery += " AND ( (GW3.GW3_DTEMIS >= '" + DtoS(MV_PAR07) + "' AND GW3.GW3_DTEMIS <= '" + DtoS(MV_PAR08) + "') OR GW3.GW3_DTEMIS = '' ) "
    ElseIf MV_PAR02 == 3
    	cQuery += " AND ( (GW3.GW3_DTENT >= '" + DtoS(MV_PAR07) + "' AND GW3.GW3_DTENT <= '" + DtoS(MV_PAR08) + "') OR GW3.GW3_DTENT = '' ) "
    EndIf
    
    //Verifica se o registro está integrado, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR09 == 1
    	cQuery += " AND ( ( GW3.GW3_SITFIS = '4' OR GW3.GW3_SITFIS = '6') "
    	cQuery += "       AND (GW3.GW3_SITREC = '4' OR GW3.GW3_SITREC = '6') "
    	If GFXTB12117("GWC") 
    		cQuery += "       AND (GW3.GW3_SITCUS = '0' OR GW3.GW3_SITCUS = '2') "
    	EndIf
    	cQuery += " ) "
    ElseIf MV_PAR09 == 2
     	cQuery += " AND (( GW3.GW3_SITFIS <> '4' AND GW3.GW3_SITFIS <> '6') "
     	cQuery += "       OR (GW3.GW3_SITREC <> '4' AND GW3.GW3_SITREC <> '6') "
     	If GFXTB12117("GWC")
     		cQuery += "      OR (GW3.GW3_SITCUS <> '0' AND GW3.GW3_SITCUS <> '2') "
     	EndIf
     	cQuery += "      ) "  
    EndIf    
    
    //Verifica se o registro está apto para a integração, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR10 == 1
    	cQuery += " AND ( GW3.GW3_SIT IN('3','4') ) "
    ElseIf MV_PAR10 == 2
    	//Validação após where (4-Atualizada)
    	cQuery += " AND ( GW3.GW3_SIT NOT IN('3','4')    
    	
      If lParSit5
		     cQuery += " OR GW3.GW3_NRFAT = '' "
		     cQuery += " OR GW6.GW6_SITFIN <> '4' ) "
	   	Else
	       cQuery += " )" 
    	EndIf
    EndIf 
     //verifica se há mais uma query a ser anexada
	If MV_PAR03 != 1 .OR. MV_PAR04 != 1  
		cQuery += " UNION ALL "
	EndIf      
	
EndIf

If MV_PAR03 != 1
	//FATURA DE FRETE  
	
	cQuery += "SELECT "
	cQuery += "(CASE  WHEN GW6.GW6_SITFIN = '4' THEN '1' ELSE '2' END) AS  GW_SITINT, "
	cQuery += "GW6.GW6_FILIAL	AS GW_FILIAL,  "
	cQuery += "'GW6'   			AS GW_TAB,     "
	cQuery += "'FATURAS FRETE'	AS GW_DESTAB,  "
	cQuery += "GW6.GW6_EMIFAT	AS GW_CDEMIS,  "
	cQuery += "''               AS GW_NMEMIS,  "
	cQuery += "GW6.GW6_SERFAT	AS GW_SER,     "
	cQuery += "GW6.GW6_NRFAT    AS GW_NRDOC,   "
	cQuery += "(CASE  WHEN GW6.GW6_SITAPR IN('3','4') THEN '1' ELSE '2' END) AS  GW_APTO, "
	cQuery += "GW6.GW6_DTEMIS	AS GW_DTEMIS,  "
	cQuery += "GW6.GW6_DTCRIA	AS GW_DTCRIA,  "
	cQuery += "''               AS GW_DTIMPRE, "
	cQuery += "GW6.GW6_DTVENC	AS GW_DTVENC,  "
	cQuery += "GW6.GW6_SITFIN	AS GW_FIN,     "
	cQuery += "GW6.GW6_DTFIN    AS GW_DTFIN,   "
	cQuery += "'6'				AS GW_FIS,     "//6 - Não Integra 
	cQuery += "''               AS GW_DTFIS,   "
	cQuery += "'6'				AS GW_REC,     "//6 - Não Integra 
	cQuery += "''               AS GW_DTREC,   "
	cQuery += "'6'				AS GW_RH,      "//6 - Não Integra 
	cQuery += "''  		     	AS GW_DTRH,    "
	If GFXTB12117("GWC")
		cQuery += "'0'              AS GW_CUS,     " //0 - Não Integra 
		cQuery += "''               AS GW_DTCUS,   "
	EndIf 
	cQuery += "GW6.GW6_FILIAL||GW6.GW6_EMIFAT||GW6.GW6_SERFAT||GW6.GW6_NRFAT||GW6.GW6_DTEMIS AS GW_CHAVE "
	cQuery += " FROM " + RetSQLName( 'GW6' ) + " GW6 WHERE GW6.D_E_L_E_T_ = ' '  AND ( GW6.GW6_FILIAL >= '" + MV_PAR05 + "' AND GW6.GW6_FILIAL <= '" + MV_PAR06 + "' ) "
    
    //filtra pelas datas de Emissão, criação ou vencimento  
 	If MV_PAR03 == 2
    	cQuery += " AND ( (GW6.GW6_DTEMIS >= '" + DtoS(MV_PAR07) + "' AND GW6.GW6_DTEMIS <= '" + DtoS(MV_PAR08) + "') OR GW6.GW6_DTEMIS = '' ) "
    ElseIf MV_PAR03 == 3
    	cQuery += " AND ( (GW6.GW6_DTCRIA >= '" + DtoS(MV_PAR07) + "' AND GW6.GW6_DTCRIA <= '" + DtoS(MV_PAR08) + "') OR GW6.GW6_DTCRIA = '' ) "
    ElseIf MV_PAR03 == 4
    	cQuery += " AND ( (GW6.GW6_DTVENC >= '" + DtoS(MV_PAR07) + "' AND GW6.GW6_DTVENC <= '" + DtoS(MV_PAR08) + "') OR GW6.GW6_DTVENC = '' ) "
    EndIf
    
     //Verifica se o registro está integrado, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR09 == 1
    	cQuery += " AND ( GW6.GW6_SITFIN = '4' ) "
    ElseIf MV_PAR09 == 2
     	cQuery += " AND ( GW6.GW6_SITFIN <> '4' ) "
    EndIf  
    
    //Verifica se o registro está apto para a integração, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR10 == 1
    	cQuery += " AND ( GW6.GW6_SITAPR IN('3','4') ) "
    ElseIf MV_PAR10 == 2
    	cQuery += " AND ( GW6.GW6_SITAPR NOT IN('3','4') ) "
    EndIf 

     //verifica se há mais uma query a ser anexada
	If MV_PAR04 != 1  
		cQuery += " UNION ALL "
	EndIf      
	
EndIf

If MV_PAR04 != 1  

	//CONTRATOS COM AUTONOMOS
	cQuery += "SELECT "
	cQuery += "(CASE  WHEN GW2.GW2_SITFIN = '4' AND GW2.GW2_SITREC IN('4','6') AND GW2.GW2_SITRH = '4' THEN '1' ELSE '2' END) AS  GW_SITINT, "
	cQuery += "GW2.GW2_FILIAL	AS GW_FILIAL,   "
	cQuery += "'GW2'            AS GW_TAB,      "
	cQuery += "'CONTRATO'		AS GW_DESTAB,   "
	cQuery += "GW2.GW2_CDPROP	AS GW_CDEMIS,   "
	cQuery += "''               AS GW_NMEMIS,   "
	cQuery += "''               AS GW_SER,      "
	cQuery += "GW2.GW2_NRCONT	AS GW_NRDOC,    "
	cQuery += "(CASE  WHEN GW2.GW2_SITCON IN('3','4') THEN '1' ELSE '2' END) AS  GW_APTO,"
	cQuery += "''               AS GW_DTEMIS,   "
	cQuery += "GW2.GW2_DTCRIA	AS GW_DTCRIA,   "
	cQuery += "GW2.GW2_DTIMPR	AS GW_DTIMPRE,  "
	cQuery += "GW2.GW2_DTVENC	AS GW_DTVENC,   "
	cQuery += "GW2.GW2_SITFIN	AS GW_FIN,      "
	cQuery += "GW2.GW2_DTFIN    AS GW_DTFIN,    "
	cQuery += "'6'				AS GW_FIS,      "//6 - Não Integra 
	cQuery += "''               AS GW_DTFIS,    "
	cQuery += "GW2.GW2_SITREC	AS GW_REC,      "
	cQuery += "GW2.GW2_DTREC 	AS GW_DTREC,    "
	cQuery += "GW2.GW2_SITRH    AS GW_RH,       "
	cQuery += "GW2.GW2_DTRH		AS GW_DTRH,     "
	If GFXTB12117("GWC")
		cQuery += "'0'              AS GW_CUS,      " //0 - Não Integra 
		cQuery += "''               AS GW_DTCUS,    "
	Endif 
	cQuery += "GW2.GW2_FILIAL||GW2.GW2_NRCONT AS GW_CHAVE "	
	cQuery += " FROM " + RetSQLName( 'GW2' )+ " GW2 WHERE GW2.D_E_L_E_T_ = ' '  AND ( GW2.GW2_FILIAL >= '" + MV_PAR05 + "' AND GW2.GW2_FILIAL <= '" + MV_PAR06 + "' ) " 
	
	//Filtra pelas datas de criação, impressão ou vencimento	   
	If MV_PAR04 == 2
    	cQuery += " AND ( (GW2.GW2_DTCRIA >= '" + DtoS(MV_PAR07) + "' AND GW2.GW2_DTCRIA <= '" + DtoS(MV_PAR08) + "') OR GW2.GW2_DTCRIA = '' ) "
    ElseIf MV_PAR04 == 3
    	cQuery += " AND ( (GW2.GW2_DTIMPR >= '" + DtoS(MV_PAR07) + "' AND GW2.GW2_DTIMPR <= '" + DtoS(MV_PAR08) + "') OR GW2.GW2_DTIMPR = '' ) "
    ElseIf MV_PAR04 == 4
    	cQuery += " AND ( (GW2.GW2_DTVENC >= '" + DtoS(MV_PAR07) + "' AND GW2.GW2_DTVENC <= '" + DtoS(MV_PAR08) + "') OR GW2.GW2_DTVENC = '' ) "
    EndIf	   
    
     //Verifica se o registro está integrado, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR09 == 1
    	cQuery += " AND ( GW2.GW2_SITFIN = '4' AND GW2.GW2_SITREC = '4' AND GW2.GW2_SITRH = '4' ) "
    ElseIf MV_PAR09 == 2
     	cQuery += " AND ( GW2.GW2_SITFIN <> '4' OR GW2.GW2_SITREC NOT IN('4','6') OR GW2.GW2_SITRH = '4' ) "  
    EndIf  
    
    //Verifica se o registro está apto para a integração, caso seja a opção '3', não executa esse filtro pois deve trazer ambos
    If MV_PAR10 == 1
    	cQuery += " AND ( GW2.GW2_SITCON IN('3','4') ) "
    ElseIf MV_PAR10 == 2
    	cQuery += " AND ( GW2.GW2_SITCON NOT IN('3','4') ) "
    EndIf 
    
EndIf

cQuery += " ORDER BY GW_FILIAL,GW_TAB,GW_CDEMIS,GW_NMEMIS,GW_SER,GW_NRDOC,GW_DTEMIS "
  

	cTmp := GetNextAlias()     
	cQuery := ChangeQuery(cQuery) 
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )  

	dbSelectArea(cTmp)
	dbgotop()
	While !( (cTmp)->( Eof() ) )          
	
		Reclock((cAliX100),.T.)
			(cAliX100)->GW_SITINT  :=   (cTmp)->GW_SITINT  
			(cAliX100)->GW_FILIAL  :=   (cTmp)->GW_FILIAL
			(cAliX100)->GW_TAB     :=   (cTmp)->GW_TAB
			(cAliX100)->GW_DESTAB  :=   (cTmp)->GW_DESTAB  
			(cAliX100)->GW_CDEMIS  :=   (cTmp)->GW_CDEMIS   
			(cAliX100)->GW_NMEMIS  :=   (cTmp)->GW_NMEMIS   
			(cAliX100)->GW_SER	 :=   (cTmp)->GW_SER	  
			(cAliX100)->GW_NRDOC   :=   (cTmp)->GW_NRDOC   
			(cAliX100)->GW_APTO    :=   (cTmp)->GW_APTO     
			(cAliX100)->GW_DTEMIS  :=   If(Empty((cTmp)->GW_DTEMIS) ,StoD("        ")  ,StoD((cTmp)->GW_DTEMIS) )
			(cAliX100)->GW_DTCRIA  :=   If(Empty((cTmp)->GW_DTCRIA) ,StoD("        ")  ,StoD((cTmp)->GW_DTCRIA) ) //StoD((cTmp)->GW_DTCRIA)  
			(cAliX100)->GW_DTIMPRE :=   If(Empty((cTmp)->GW_DTIMPRE),StoD("        ")  ,StoD((cTmp)->GW_DTIMPRE) )//StoD((cTmp)->GW_DTIMPR)  
			(cAliX100)->GW_DTVENC  :=   If(Empty((cTmp)->GW_DTVENC) ,StoD("        ")  ,StoD((cTmp)->GW_DTVENC) ) //StoD((cTmp)->GW_DTVENC)  
			(cAliX100)->GW_FIN	 :=   (cTmp)->GW_FIN	 
			(cAliX100)->GW_DTFIN   :=   If(Empty((cTmp)->GW_DTFIN)  ,StoD("        ")  ,StoD((cTmp)->GW_DTFIN) )  //StoD((cTmp)->GW_DTFIN)    
			(cAliX100)->GW_FIS     :=   (cTmp)->GW_FIS      
			(cAliX100)->GW_DTFIS   :=   If(Empty((cTmp)->GW_DTFIS)  ,StoD("        ")  ,StoD((cTmp)->GW_DTFIS) )  //StoD((cTmp)->GW_DTFIS)    
			(cAliX100)->GW_REC     :=   (cTmp)->GW_REC      
			(cAliX100)->GW_DTREC   :=   If(Empty((cTmp)->GW_DTREC)  ,StoD("        ")  ,StoD((cTmp)->GW_DTREC) )  //StoD((cTmp)->GW_DTREC)   
			(cAliX100)->GW_RH		 :=   (cTmp)->GW_RH	    
			(cAliX100)->GW_DTRH    :=   If(Empty((cTmp)->GW_DTRH)   ,StoD("        ")  ,StoD((cTmp)->GW_DTRH) )   //StoD((cTmp)->GW_DTRH)  
			(cAliX100)->GW_CHAVE   :=   cValToChar((cTmp)->GW_CHAVE)
			If GFXTB12117("GWC")
				(cAliX100)->GW_CUS		:=   (cTmp)->GW_CUS	    
				(cAliX100)->GW_DTCUS   :=   If(Empty((cTmp)->GW_DTCUS)   ,StoD("        ")  ,StoD((cTmp)->GW_DTCUS) )   //StoD((cTmp)->GW_DTRH)
			EndIf  
		MsUnlock()    
		
		(cTmp)->(dbSkip())
	EndDo            

	(cTmp)->(dbCloseArea())

//EndIf  
 
Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA057PAR

função que executa a tela de parametros do brownse

@author Felipe Mendes
@since 02/02/2012
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEX100PAR()  

If !Pergunte("GFEX100",.T.)
	Return .F.
Else      
	While MV_PAR01 == 1 .AND. MV_PAR02 == 1 .AND. MV_PAR03 == 1 .AND. MV_PAR04 == 1
	   
		If MV_PAR01 == 1 .AND. MV_PAR02 == 1 .AND. MV_PAR03 == 1 .AND. MV_PAR04 == 1
		    Help( ,, 'HELP',, "É necessário escolher uma opção", 1, 0) 
		    Return .F.
		EndIf
		If !s_GFEX100  
			Return .F.
	    EndIf    
	    
	EndDo 
 
	GFEX100Dados()
Endif

(cAliX100)->(dbgotop())

Return           

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX100INT

Função de integração, utilizada para chamar a rotina de integração de cada tabela

@author Felipe Mendes
@since 02/02/2012
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEX100INT(nOp)
Local cChave := ""
Local oModelIn
Local aRet := {}
Local cFilAtu := cFilAnt

//Se o registro estiver apto
If (cAliX100)->GW_APTO == "1"    
	
	cFilAnt := (cAliX100)->GW_FILIAL
	
	dbSelectArea((cAliX100)->GW_TAB)    
	dbSetOrder(1)
	
	If (cAliX100)->GW_TAB == "GW6"
		cChave := SubStr( (cAliX100)->GW_CHAVE,1,TamSx3("GW6_FILIAL")[1]+TamSx3("GW6_EMIFAT")[1]+TamSx3("GW6_SERFAT")[1]+TamSx3("GW6_NRFAT")[1] )
		
	ElseIf (cAliX100)->GW_TAB == "GWJ"
		cChave := SubStr( (cAliX100)->GW_CHAVE,1,TamSx3("GWJ_FILIAL")[1]+TamSx3("GWJ_NRPF")[1] )
		
	ElseIf (cAliX100)->GW_TAB == "GW2"
		cChave := SubStr( (cAliX100)->GW_CHAVE,1,TamSx3("GW2_FILIAL")[1]+TamSx3("GW2_NRCONT")[1] )
		
	ElseIf (cAliX100)->GW_TAB == "GW3"
		cChave := SubStr( (cAliX100)->GW_CHAVE,1,TamSx3("GW3_FILIAL")[1]+TamSx3("GW3_CDESP")[1]+TamSx3("GW3_EMISDF")[1]+TamSx3("GW3_SERDF")[1]+TamSx3("GW3_NRDF")[1]+TamSx3("GW3_DTEMIS")[1] )
		
	EndIf
			
	If dbSeek( cChave ) //(cAliX100)->GW_CHAVE
	
		If nOp == 1 //FINANCEIRO    
			
			If (cAliX100)->GW_TAB == "GWJ" //PRE-FATURAS DE FRETE
				oModelIn := FWLoadModel("GFEA055")
				GFEA055X(.F.,oModelIn)
				oModelIn:DeActivate()
				oModelIn:Destroy()
			ElseIf (cAliX100)->GW_TAB == "GW6"//FATURA DE FRETE  
				GFEA070X()
		    ElseIf (cAliX100)->GW_TAB == "GW2"	//CONTRATOS COM AUTONOMOS	
			    GFEA100X("1")
		    Else
				Help( ,, 'HELP',, "Este registro não integra com a opção desejada.", 1, 0) 
			EndIf
	
		ElseIf nOp == 2 //FISCAL
	
		    If (cAliX100)->GW_TAB == "GW3" 	//DOCUMENTOS DE FRETE   
		      GFEA065XF()
		      (cAliX100)->GW_FIS := "4"
		      (cAliX100)->GW_SITINT := "1"  
	        Else
				Help( ,, 'HELP',, "Este registro não integra com a opção desejada.", 1, 0) 
			EndIf
	
		ElseIf nOp == 3 //RECEBIMENTO
	
		    If (cAliX100)->GW_TAB == "GW3" 	//DOCUMENTOS DE FRETE 
		       GFEA065XC()
		       (cAliX100)->GW_REC := "4"
		       (cAliX100)->GW_SITINT := "1"   
		    ElseIf (cAliX100)->GW_TAB == "GW2"	//CONTRATOS COM AUTONOMOS	 
		        GFEA100X("3")
		 	Else
				Help( ,, 'HELP',, "Este registro não integra com a opção desejada.", 1, 0) 
			EndIf		
	
		ElseIf nOp == 4 //FOLHA DE PAG
	
		    If (cAliX100)->GW_TAB == "GW2"	//CONTRATOS COM AUTONOMOS
				GFEA100X("2")
		    Else
				Help( ,, 'HELP',, "Este registro não integra com a opção desejada.", 1, 0) 
			EndIf	

		ElseIf nOp == 5 //CUSTO DE FRETE
	
			If (cAliX100)->GW_TAB == "GW3" 	//DOCUMENTOS DE FRETE 
				aRet := GFEA065CTP("IL")
				If !aRet[1]
					Help( ,, 'HELP',, aRet[2], 1, 0)
				Else
					//para que não seja necessario refazer a Query na base, é gravada na tabela em tela a nova opção e motivo
					dbSelectArea(cAliX100)
					RecLock(cAliX100,.F.)
						(cAliX100)->GW_CUS := aRet[3]     		 
						(cAliX100)->GW_DTCUS := aRet[4]
					MsUnlock(cAliX100)
				EndIf						
			Else
				Help( ,, 'HELP',, "Este registro não integra com a opção desejada.", 1, 0) 
			EndIf	
		EndIf 
		
	EndIf
	
	cFilAnt := cFilAtu 
Else
	Help( ,, 'HELP',, "Este registro não está apto a ser integrado.", 1, 0) 
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX100Edit()

Função de integração

@author Felipe Mendes
@since 02/02/2012
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEX100Edt(cCampo)

Local oComboBo1
Local cComboBo1 := "1" , aCombo := {}
Local oGet1
Local oGroup1
Local oGroup2
Local oMultiGe1
Local cMultiGe1 
Local oMultiGe2
Local cMultiGe2 
Local oSay1,oSay2,oSay3,oSay4
local oDlg
local cTitle, lRet := .T.
 
If (cCampo != "GW_CUS" .And. (cAliX100)->&(cCampo) != "6") .Or. (cCampo == "GW_CUS" .And. (cAliX100)->&(cCampo) != "0" .And. AllTrim((cAliX100)->&(cCampo)) != "")
	cSitAtual := RetStatus((cAliX100)->&(cCampo), cCampo)
Else
	lRet := .F.
EndIf      


If lRet  
  
	If cCampo == "GW_FIN"
		cTitle:= "Financeiro"
	ElseIf cCampo == "GW_FIS"
		cTitle:= "Fiscal"
	ElseIf cCampo == "GW_REC"
		cTitle:= "Recebimento"
	ElseIf cCampo == "GW_RH"
		cTitle:= "Folha de Pagamento"
	ElseIf cCampo == "GW_CUS"
		cTitle:= "Custo de Frete"
	EndIf
	 
	cMultiGe2 := "Tabela : " + POSICIONE('SX2',1,(cAliX100)->GW_TAB ,'X2_NOME') + CHR(13)+CHR(10) +;
	             "Emissor: " + Alltrim((cAliX100)->GW_CDEMIS) + " - " + (cAliX100)->GW_NMEMIS + CHR(13)+CHR(10) +;
	             "Serie / Numero Doc: " + (cAliX100)->GW_SER + " / " + (cAliX100)->GW_NRDOC + CHR(13)+CHR(10) +;
	             If(!Empty((cAliX100)->GW_DTEMIS),"Data de Emissão: " + DTOC((cAliX100)->GW_DTEMIS) + CHR(13)+CHR(10),"")  
	               
    If cSitAtual == "Não Enviado"
		aCombo := {"2=Atualizado"}
	ElseIf cSitAtual == "Atualizado" 
		aCombo := {"1=Não Enviado"}
	Else
		aCombo := {"1=Não Enviado","2=Atualizado"}
	EndIf  	  
	           
	DEFINE MSDIALOG oDlg TITLE "Modificar Situação" FROM 000, 000  TO 550, 450 PIXEL
    
    @ 057, 009 GROUP oGroup1 TO 116, 213 PROMPT cTitle OF oDlg PIXEL
    @ 121, 009 GROUP oGroup2 TO 249, 213 PROMPT "Modificar Situação" OF oDlg PIXEL
    @ 141, 016 MSGET oGet1 VAR cSitAtual SIZE 076, 010 OF oDlg READONLY PIXEL
    @ 132, 016 SAY oSay1 PROMPT "Situação Atual :" SIZE 053, 008 OF oDlg PIXEL
    @ 132, 129 SAY oSay2 PROMPT "Modificar para :" SIZE 052, 010 OF oDlg PIXEL
    @ 141, 129 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS aCombo SIZE 076, 010 OF oDlg PIXEL
    @ 155, 016 SAY oSay3 PROMPT "Justificativa :" SIZE 051, 008 OF oDlg PIXEL
    @ 067, 016 SAY oSay4 PROMPT "Registro :" SIZE 037, 010 OF oDlg PIXEL
    @ 164, 016 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 190, 069 HSCROLL PIXEL
    @ 076, 016 GET oMultiGe2 VAR cMultiGe2 OF oDlg MULTILINE SIZE 192, 033 HSCROLL PIXEL
    	
    ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||IF(GFEX100OK((cAliX100)->GW_TAB,(cAliX100)->GW_CHAVE,cCampo,cComboBo1,cMultiGe1,cSitAtual),oDlg:End(),Nil)},{||oDlg:End()},,)) CENTERED

Else
	Help( ,, 'HELP',, "Este registro não faz integração com a opção selecionada.", 1, 0) 	
EndIf

Return

//-------------------------------------
//Retorna a descrição da situação
//------------------------------------
Static Function RetStatus(cSit, cCampo) 

	If cCampo == "GW_CUS"
		If cSit == "1"
			Return "Não Enviado"
		ElseIf cSit == "2"
			Return "Atualizado"
		ElseIf cSit == "3"
			Return "Rejeitado"
		ElseIf cSit == "4"
			Return "Pendente"
		EndIf 
	Else
		If cSit == "1"
			Return "Não Enviado"
		ElseIf cSit == "2"
			Return "Pendente"
		ElseIf cSit == "3"
			Return "Rejeitado"
		ElseIf cSit == "4"
			Return "Atualizado" 
		ElseIf cSit == "5"
			Return "Pendente Cancelamento"
		EndIf
	EndIf

Return   
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX100OK()

Salva o novo status e a justificativa

@author Felipe Mendes
@since 02/02/2012
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEX100OK(cTab,cChave,cCampo,cOpcao,cMotivo,cSitAnt)     

Local cCampoSit := cTab+"_SIT"+SUBSTRING(cCampo,4,3)
Local cCampoMot := cTab+"_MOT"+SUBSTRING(cCampo,4,3)
Local cCampoDat := cTab+"_DT"+SUBSTRING(cCampo,4,3)
Local cCampoDt  := "GW_DT"+SUBSTRING(cCampo,4,3)
Local cMSG
Local dDtVazia  := CtoD("  /  /    ")

//validação de integridade
If ValidStatus(cSitAnt,cOpcao,cMotivo)

		cMSG := "Situação alterada manualmente de " + cSitAnt + " para " + If(cOpcao=="2","Atualizado","Não Enviado") + CHR(13)+CHR(10) +;
											" por: " + cUserName + CHR(13)+CHR(10) +;
											" em: " + DTOC(dDataBase) + " / " + TIME()  + CHR(13)+CHR(10) +;
											" Motivo: " + cMotivo
	
	dbSelectArea(cTab)
	dbSetOrder(1)
	If dbSeek(RTRIM(cChave) ) 
       	
		//grava na tabela a nova opção e motivo
		dbSelectArea(cTab)
		RecLock(cTab,.F.) 
			&(cTab+"->"+cCampoSit) := If(cCampo=="GW_CUS",cOpcao,If(cOpcao=="2","4","1"))
			&(cTab+"->"+cCampoMot) := cMSG
			&(cTab+"->"+cCampoDat) := If (cOpcao == "2",dDataBase,dDtVazia)
		MsUnlock(cTab)   
		
		//para que não seja necessario refazer a Query na base, é gravada na tabela em tela a nova opção e motivo
		dbSelectArea(cAliX100)
		RecLock(cAliX100,.F.)
			&("(cAliX100)->"+cCampo) := If(cCampo=="GW_CUS",cOpcao,If(cOpcao=="2","4","1"))
			&("(cAliX100)->"+cCampoDt) := If (cOpcao == "2",dDataBase,dDtVazia)
		MsUnlock(cAliX100)
	EndIf
	
	lRet := .T. 
	
Else
	lRet := .F.
EndIf	       

Return lRet    
  
//--------------------------
//Validação de integridade
//-------------------------- 
Static Function ValidStatus(cSitAnt,cOpcao,cMotivo) 

//Não deixa grava uma situação que já esteja gravada
If cSitAnt == If(cOpcao=="2","Atualizado","Não Enviado") 
	Help( ,, 'HELP',, "A opção selecionada já está gravada.", 1, 0) 	
	Return .F.   
EndIf  

//Precisa ser informado um motivo para mudança de status
If Empty(cMotivo) 
	Help( ,, 'HELP',, "Deve ser informado um motivo.", 1, 0) 	
	Return .F.
EndIf  

Return .T.
