#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VEIXFUNA.CH"
#INCLUDE "FWMVCDEF.CH"
//#define _lConout_ .F.
Static lMilSNF := FindFunction("SerieNfId")
Static oSoConfig
Static oArrHlp := DMS_ArrayHelper():New()
Static oXFA_SQLHelper
Static lMVMIL0185
Static lMultMoeda := FGX_MULTMOEDA()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_VEIMOVSº Autor ³ Luis Delorme             º Data ³ 02/10/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna as movimentacoes realizadas no chassi                  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ [1] - "E" ou "S" - Movimentacao de Entrada ou Saida            º±±
±±º         ³ [2] - Filial da ultima movimentacao                            º±±
±±º         ³ [3] - TRACPA ou NUMTRA (dependendo do retorno [1]              º±±
±±º         ³ [4] - Data da emissao (DTHEMI) ***CARACTERE*** AAMMDDHH:MM:SS  º±±
±±º         ³ [5] - Operacao realizada na movimentacao (OPEMOV)              º±±
±±º         ³ [6] - Data do Movimento  (Formato de DATA)                     º±±
±±º         ³ [7] - Codigo do Cliente/Fornecedor                             º±±
±±º         ³ [8] - Loja do Cliente/Fornecedor                               º±±
±±º         ³ [9] - Tip Fat. (0=Novo, 1=Usado, 2=Venda Fat. Direto )         º±±
±±º         ³[10] - DOCIND CPF/CNPJ do cliente ou fornecedor                 º±±
±±º         ³[11] - DTDIGIT (da NF)                                          º±±
±±º         ³[12] - EMISSAO (da NF)                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_VEIMOVS( _cChassi , _cTipo , _cOper )

Local cQryAlias	:= "SQLVV0AFG" // VV0/VVA
Local cQuery	:= {}
//Local cDataQry	:= ""
Local cAlias := Alias()
Local aQuery := {}
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial(IIf(FWModeAccess("VV1",1)=="E",aFilAtu[3],) , IIf(FWModeAccess("VV1",2)=="E",aFilAtu[4],) , aFilAtu[1], .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local cFilVVA    := ""
Local cFilVVG    := ""
local cSubStrFunc

Default _cTipo   := "SE"
Default _cOper   := ""

If Len(aSM0) > 0
	cFilVVA := "("
	cFilVVG := "("
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilVVA += "'"+xFilial("VVA")+"',"
		cFilVVG += "'"+xFilial("VVG")+"',"
	Next
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
	cFilVVG := left(cFilVVG,len(cFilVVG)-1)+")"
	cFilAnt := cBkpFilAnt
EndIf

if oXFA_SQLHelper == NIL
	oXFA_SQLHelper := DMS_SqlHelper():New()
endif

cSubStrFunc := oXFA_SQLHelper:CompatFunc("SUBSTR")

// Retorna se o Grau de Severidade é diferente de '6=Sem CHASSI' (AMS/Peça)
cQuery := "SELECT VV1.VV1_GRASEV "
cQuery += "FROM " + RetSqlName("VV1") + " VV1 "
cQuery += "WHERE VV1.VV1_FILIAL = '" + xfilial("VV1") + "' AND VV1.VV1_CHASSI = '" + _cChassi + "' AND VV1.D_E_L_E_T_=' ' "
cGRASEV := FM_SQL(cQuery)

cQuery := "SELECT * FROM ( "

If "S" $ _cTipo

	cFunc := oXFA_SQLHelper:Concat({;
		cSubStrFunc + "(VV0_DTHEMI,7,2)",;
		cSubStrFunc + "(VV0_DTHEMI,4,2)",;
		cSubStrFunc + "(VV0_DTHEMI,1,2)",;
		cSubStrFunc + "(VV0_DTHEMI,10,8)";
	})

	cQuery += "SELECT 'S' MOV , VV0.VV0_FILIAL FILIAL , VV0.VV0_NUMTRA TRA, VV0.VV0_OPEMOV OPEMOV, "
	cQuery += "       VV0.VV0_DATMOV DATMOV , VV0.VV0_CODCLI CODCLIFOR , VV0.VV0_LOJA LOJA , VV0.VV0_TIPFAT TIPFAT , SA1.A1_CGC DOCIND "
	cQuery += ", " + cFunc + " DTHEMI, F2_EMISSAO DTDIGIT, F2_EMISSAO EMISSAO "
	cQuery += "FROM "+RetSqlName("VVA")+" VVA INNER JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ' ) "
	cQuery += " LEFT JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = VV0.VV0_CODCLI AND SA1.A1_LOJA = VV0.VV0_LOJA AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSQLName("SF2") + " SF2 ON F2_FILIAL=VV0_FILIAL AND F2_DOC=VV0_NUMNFI AND F2_SERIE=VV0_SERNFI AND SF2.D_E_L_E_T_ = ' '"
	cQuery += "WHERE VVA.VVA_FILIAL IN "+cFilVVA+" AND VVA.VVA_CHASSI='"+_cChassi+"' AND VV0.VV0_SITNFI<>'0' "
	cQuery += " AND "
	cQuery += "( "
	cQuery += "( VV0.VV0_TIPDOC = '2' ) "
	cQuery += " OR "
	cQuery += "( VV0.VV0_TIPDOC <> '2' AND ( VV0.VV0_NUMNFI <> ' ' OR VV0.VV0_NNFFDI <> ' ' "
	If cPaisLoc $ "ARG,MEX"
		cQuery += " OR VV0.VV0_REMITO <> ' ' "
	EndIf
	cQuery += ") ) "
	cQuery += ") "
	cQuery += "AND VVA.D_E_L_E_T_=' ' "
	If _cOper != ""
		cQuery += "AND VV0.VV0_OPEMOV='" + _cOper + "' "
	EndIf
	If cGRASEV <> "6"
		cQuery += "AND VV0.VV0_TIPMOV IN (' ','0') "
	EndIf

	If "E" $ _cTipo
		cQuery += " UNION ALL "
	endif

EndIf
//
If "E" $ _cTipo

	cFunc := oXFA_SQLHelper:Concat({;
		cSubStrFunc + "(VVF_DTHEMI,7,2)",;
		cSubStrFunc + "(VVF_DTHEMI,4,2)",;
		cSubStrFunc + "(VVF_DTHEMI,1,2)",;
		cSubStrFunc + "(VVF_DTHEMI,10,8)";
	})

	cQuery += "SELECT 'E' MOV, VVF.VVF_FILIAL FILIAL , VVF.VVF_TRACPA TRA , VVF.VVF_OPEMOV OPEMOV, "
	cQuery += "       VVF.VVF_DATMOV DATMOV , VVF.VVF_CODFOR CODCLIFOR, VVF.VVF_LOJA LOJA, ' ' TIPFAT , SA2.A2_CGC DOCIND "
	cQuery += ", " + cFunc + " DTHEMI, F1_DTDIGIT DTDIGIT, F1_EMISSAO EMISSAO "
	cQuery += "FROM "+RetSqlName("VVF")+" VVF INNER JOIN "+RetSqlName("VVG")+" VVG ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' ' ) "
	cQuery += " LEFT JOIN " + RetSQLName("SA2") + " SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = VVF.VVF_CODFOR AND SA2.A2_LOJA = VVF.VVF_LOJA AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSQLName("SF1") + " SF1 on F1_FILIAL=VVF_FILIAL and F1_DOC=VVF_NUMNFI and F1_SERIE=VVF_SERNFI and F1_FORNECE=VVF_CODFOR and F1_LOJA=VVF_LOJA and SF1.D_E_L_E_T_ = ' '"
	cQuery += "WHERE VVG.VVG_FILIAL IN "+cFilVVG+" AND VVG.VVG_CHASSI='"+_cChassi+"' AND VVF.VVF_SITNFI<>'0' "
	cQuery += "AND VVF.D_E_L_E_T_=' ' "
	If _cOper != ""
		cQuery += "AND VVF.VVF_OPEMOV='" + _cOper + "' "
	EndIf
	If cGRASEV <> "6"
		cQuery += "AND VVF.VVF_TIPMOV IN (' ','0') "
	EndIf

EndIf

cQuery += " ) TEMP ORDER BY DTHEMI DESC"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
while !((cQryAlias)->(eof()))

	aAdd(aQuery,{ ;
		(cQryAlias)->MOV,;             // 1
		(cQryAlias)->FILIAL,;          // 2
		(cQryAlias)->TRA,;             // 3
		alltrim((cQryAlias)->DTHEMI),; // 4
		(cQryAlias)->OPEMOV,;          // 5
		stod((cQryAlias)->(DATMOV)),;  // 6
		(cQryAlias)->CODCLIFOR,;       // 7
		(cQryAlias)->LOJA,;            // 8
		(cQryAlias)->TIPFAT,;          // 9
		(cQryAlias)->DOCIND,;          // 10
		(cQryAlias)->DTDIGIT,;         // 11
		(cQryAlias)->EMISSAO })        // 12
	DBSkip()
enddo
( cQryAlias )->( dbCloseArea() )


If cAlias <> ""
	DBSelectArea(cAlias)
EndIf

If Len(aQuery) == 0
	Return {}
EndIf

Return aQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FGX_AMOVVEI³ Autor ³  Andre Luis Almeida  ³ Data ³ 12/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza a ULTIMA Movimentacao de Entrada/Saida do Veiculo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_AMOVVEI(_cFilial,_cChassi,_cRotOrigem,_lAtuProAnt, cParFilMov, cParNumMov)

	local aFldUpdate
	Local cBkpVar	 := ""
	Local cAliasAnt  := Alias()
	local aAreaSA1 := SA1->(getArea())
	local lSavInclui := INCLUI
	/*+----------------------------------------------------------------------------+
	  | Marcelo Iuspa em 31/01/2025                                                |
	  | DVARMIL-7073 - CI 014056 Bloqueio de condição de pagamento 999 no VEIXA001 |
	  | Identificado que variavel PRIVATE INCLUI era alterada para falso após      |
	  | chamada da função VA0700093_AtualizaVV1 que tornava os gets readonly       |
	  | na rotina VEIXX000 (chamada pela VEIXA001)                                 |
	  | Implementado save/restore na variavel INCLUI                               |
	  +----------------------------------------------------------------------------+*/

	aFldUpdate := FGX_VV1FLDUPD(_cFilial,_cChassi,_cRotOrigem,_lAtuProAnt, cParFilMov, cParNumMov)

	if len(aFldUpdate) <> 0
		
		//if _lConout_
		//	Conout("  _  __                 _             _ ___ ")
		//	Conout(" |_ /__ \/    /\  |\/| / \ \  / \  / |_  |  ")
		//	Conout(" |  \_| /\ __/--\ |  | \_/  \/   \/  |_ _|_ ")
		//	Conout("                                            ")
		//	//Conout(" aFldUpdate")
		//	//For nAuxPrint := 1 to len(aFldUpdate)
		//	//	conout(" " + aFldUpdate[nAuxPrint,1] + "->[" + cValtoChar(aFldUpdate[nAuxPrint,2]) + "]")
		//	//next nAuxPrint
		//	////varinfo("aFldUpdate - VV1",aFldUpdate)
		//	//Conout("                                            ")
		//endif
		cBkpVar := ReadVar()
		oVV1_AtVeiAMov := FWLoadModel('VEIA070')
		oVV1_AtVeiAMov:SetOperation( MODEL_OPERATION_UPDATE )
		if ! oVV1_AtVeiAMov:Activate()
			return .f.
		endif

		if VA0700093_AtualizaVV1(@oVV1_AtVeiAMov, aFldUpdate)
			FMX_COMMITDATA(@oVV1_AtVeiAMov)
		endif

		oVV1_AtVeiAMov:DeActivate()
		__ReadVar := cBkpVar
		//if _lConout_
		//	Conout("  ")
		//	Conout(" Depois da gravacao do veiculo")
		//	Conout("  ")
		//	Conout(" VV1_CHASSI - " + VV1->VV1_CHASSI )
		//	Conout(" VV1_PROATU - " + VV1->VV1_PROATU )
		//	Conout(" VV1_LJPATU - " + VV1->VV1_LJPATU )
		//	Conout("  ")
		//	Conout(" VV1_SITVEI - " + VV1->VV1_SITVEI  + " - " + iif( VV1->VV1_SITVEI = '0' , 'Estoque' , iif( VV1->VV1_SITVEI = '1' , 'Vendido' , iif( VV1->VV1_SITVEI = '2' , 'Em Transito' , iif( VV1->VV1_SITVEI = '3' , 'Remessa' , iif( VV1->VV1_SITVEI = '4' , 'Consignado' , iif( VV1->VV1_SITVEI = '5' , 'Transferido' , iif( VV1->VV1_SITVEI = '6' , 'Reservado' , iif( VV1->VV1_SITVEI = '7' , 'Progresso' , iif( VV1->VV1_SITVEI = '8' , 'Pedido' , iif( VV1->VV1_SITVEI = '9' , 'Requisitado OS' , '' )))))))))))
		//	Conout(" VV1_ULTMOV - " + VV1->VV1_ULTMOV )
		//	Conout("  ")
		//	Conout(" VV1_FILENT - " + VV1->VV1_FILENT )
		//	Conout(" VV1_TRACPA - " + VV1->VV1_TRACPA )
		//	Conout("  ")
		//	Conout(" VV1_FILSAI - " + VV1->VV1_FILSAI )
		//	Conout(" VV1_NUMTRA - " + VV1->VV1_NUMTRA )
		//	Conout("  ")
		//	Conout(" VV1_BBEQTY - " + VV1->VV1_BBEQTY + " - " + IIf( VV1->VV1_BBEQTY == "1" , "CustomerEquipment" , Iif( VV1->VV1_BBEQTY == "2" , "StockUnit" , iif( VV1->VV1_BBEQTY == "3" , "FixedAsset" , "" ))) )
		//	Conout(" VV1_BBSTTY - " + VV1->VV1_BBSTTY + " - " + IIf( VV1->VV1_BBSTTY == "1" , "New" , iif( VV1->VV1_BBSTTY == "2" , "Used" , iif( VV1->VV1_BBSTTY == "3" , "Demo" , "" ))) )
		//	Conout(" VV1_BBINST - " + VV1->VV1_BBINST + " - " + IIf( VV1->VV1_BBINST == "1" , "Sold", iif( VV1->VV1_BBINST == "2" , "Stock" , iif( VV1->VV1_BBINST == "3" , "Loaner" , iif( VV1->VV1_BBINST == "4" , "OnHold" , iif( VV1->VV1_BBINST == "5" , "Rental" , iif( VV1->VV1_BBINST == "6" , "Demo" , iif( VV1->VV1_BBINST == "7" , "Shop" , iif( VV1->VV1_BBINST == "8" , "Asset" , "" )))))))) )
		//	Conout(" VV1_BBSTST - " + VV1->VV1_BBSTST + " - " + IIf( VV1->VV1_BBSTST == "1" , "Pending" , iif( VV1->VV1_BBSTST == "2" , "InStock" , iif( VV1->VV1_BBSTST == "3" , "Invoiced" , iif( VV1->VV1_BBSTST == "4" , "Rental" , "" )))) )
		//	Conout(" VV1_BBYARD - " + VV1->VV1_BBYARD + " - " + IIf( VV1->VV1_BBYARD == "0" , "Nao" , iif( VV1->VV1_BBYARD == "1" , "Sim" , "" )) )
		//	Conout(" VV1_LOCRID - " + VV1->VV1_LOCRID )
		//	Conout(" VV1_SOLCID - " + VV1->VV1_SOLCID )
		//	Conout("  ")
		//	Conout(" VV1_BBINTG - " + VV1->VV1_BBINTG + " - " + IIf( VV1->VV1_BBINTG == "0" , "Nao" , Iif( VV1->VV1_BBINTG == "1" , "Sim" , "" )))
		//	Conout(" VV1_BBSYNC - " + VV1->VV1_BBSYNC + " - " + IIf( VV1->VV1_BBSYNC == "0" , "Nao Sincronizado" , Iif( VV1->VV1_BBSYNC == "1" , "Sincronizado","" ) ))
		//	Conout(" VV1_BBDEL  - " + VV1->VV1_BBDEL  + " - " + IIf( VV1->VV1_BBDEL == "0" , "Nao" , Iif( VV1->VV1_BBDEL == "1" , "Sim" , "" )))
		//	Conout("  ")
		//
		//	// Saida por Devolucao de Compra 
		//	//if cXUltMov == "S" .and. cXUltOpe == "4" .or. Empty(cXUltMov)
		//	//	if excluirChassiBB
		//	//		Conout(" Excluindo registro no BLACKBIRD -> VA0700053_ExcluirBlackbird")
		//	//		VA0700053_ExcluirBlackbird("VV1",VV1->(Recno()),4,.f.)
		//	//	endif
		//	//endif
		//endif
	endif

	DbSelectArea("VV1")
	DbSetOrder(2)

	// If len(aMovVei) == 0 // comentei pq ta dando error log amovvei n existe aqui?!
	// 	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	// 	If ExistBlock("VM011AMOV")
	// 		If !ExecBlock("VM011AMOV",.f.,.f.)
	// 			Return .f.
	// 		EndIf
	// 	EndIf
	// EndIf
	If ExistBlock("VXFAAMOV")
		If !ExecBlock("VXFAAMOV",.f.,.f.,{ VV1->VV1_FILIAL , VV1->VV1_CHAINT })
			Return .f.
		EndIf
	EndIf
	If !Empty(cAliasAnt)
		DbSelectArea(cAliasAnt)
	EndIf

	restArea(aAreaSA1)

    INCLUI := lSavInclui
Return

/*/{Protheus.doc} FGX_VV1FLDUPD
	Retorna array com campos e valores para serem gravados no VV1

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
Function FGX_VV1FLDUPD(_cFilial,_cChassi,_cRotOrigem,_lAtuProAnt, cParFilMov, cParNumMov)
	local aMovVei := {} 
	local aFldUpdate := {}
	local cSitVei
	local cXUltMov
	local cXUltOpe
	local cProAtu
	local cLjpAtu
	local cEFilMov
	local cENumMov
	local cSFilMov
	local cSNumMov
	local cFilUltMovTEMP
	local cUltMovTEMP
	local cDocpAtu

	default _cFilial  := xFilial("VV1")
	default _cChassi  := VV1->VV1_CHASSI
	default _cRotOrigem := ""
	default _lAtuProAnt := .f.
	default cParFilMov := ""
	default cParNumMov := ""

	DbSelectArea("VV1")
	DbSetOrder(2)

	If ! MsSeek(_cFilial+_cChassi)
		Return {}
	endif

	// Retorna todas as Movimentacoes Validas de Entrada/Saida referente ao Veiculo
	aMovVei := FGX_VEIMOVS( _cChassi , , )

	aStatVeiculo := procAMovVei(aMovVei)
	cSitVei        := aStatVeiculo[01]
	cXUltMov       := aStatVeiculo[02]
	cXUltOpe       := aStatVeiculo[03]
	cProAtu        := aStatVeiculo[04]
	cLjpAtu        := aStatVeiculo[05]
	cEFilMov       := aStatVeiculo[06]
	cENumMov       := aStatVeiculo[07]
	cSFilMov       := aStatVeiculo[08]
	cSNumMov       := aStatVeiculo[09]
	cFilUltMovTEMP := aStatVeiculo[10]
	cUltMovTEMP    := aStatVeiculo[11]
	cDocpAtu       := aStatVeiculo[12]

	aFldUpdate := FGX_Get_VV1_FieldUpdate(;
		cSitVei,;
		cXUltMov,;
		cXUltOpe,;
		cProAtu,;
		cLjpAtu,;
		cEFilMov,;
		cENumMov,;
		cSFilMov,;
		cSNumMov,;
		_cRotOrigem,;
		cFilUltMovTEMP,;
		cUltMovTEMP,;
		cDocpAtu,;
		cParFilMov,;
		cParNumMov )


	if lMVMIL0185 == NIL
		lMVMIL0185 := GetNewPar("MV_MIL0185",.F.)
	endif

	if lMVMIL0185
		if oSoConfig == NIL
			oSoConfig := OFSoConfig():New()
		endif

		cFilialFiltro := oArrHlp:Join(oArrHlp:Map(oSoConfig:GetHabilitadas(), {|oEl| oEl["FILIAL"] }), "/")

		//cFilialFiltro := "010101/010102"
		//MsgInfo("Ambiente de Desenvovimento - FGX_VV1FLDUPD com filial xumbregada.")

		aStatVeiculo := procAMovVei(aMovVei, cFilialFiltro)
		//cSitVei        := aStatVeiculo[01]
		cXUltMov       := aStatVeiculo[02]
		cXUltOpe       := aStatVeiculo[03]
		cProAtu        := aStatVeiculo[04]
		cLjpAtu        := aStatVeiculo[05]
		cEFilMov       := aStatVeiculo[06]
		cENumMov       := aStatVeiculo[07]
		cSFilMov       := aStatVeiculo[08]
		cSNumMov       := aStatVeiculo[09]
		cFilUltMovTEMP := aStatVeiculo[10]
		cUltMovTEMP    := aStatVeiculo[11]
		//cDocpAtu       := aStatVeiculo[12]

		FGX_GetBB_VV1_FieldUpdate(@aFldUpdate, cXUltMov, cXUltOpe, cEFilMov, cENumMov, cSFilMov, cSNumMov, cFilUltMovTEMP, cUltMovTEMP, _cRotOrigem, cParFilMov, cParNumMov)

	endif
Return aFldUpdate

/*/{Protheus.doc} procAMovVei
	Processa as movimentacoes do veiculo e retorna a ultima movimentacao de entrada e saida

	@author Rubens Takahashi
	@since 06/01/2024
	@type function
/*/
Static Function procAMovVei(aMovVei, cFilialFiltro)

	Local ni := 0
	
	//Local nj := 0

	local aRetorno := {}

	Local cEFilMov   := "" // Entrada: Filial
	Local cENumMov   := "" // Entrada: Numero da Transacao de Entrada
	Local cETipMov   := "" // Entrada: Tipo de Faturamento
	Local cSFilMov   := "" // Saida: Filial
	Local cSNumMov   := "" // Saida: Numero do Transacao de Saida
	Local cSTipMov   := "" // Saida: Tipo de Faturamento (TIPFAT)
	Local cXUltMov   := "" // Ultima Movimentacao "E"ntrada/"S"aida
	Local cXUltOpe   := "" // Ultima Operacao Realizada no Veiculo
	Local cSitVei    := ""
	Local cProAtu    := ""
	Local cLjpAtu    := ""
	Local aAuxCodCli := {}
	Local aMovValidos := {}

	local cFilUltMovTEMP := ""
	local cUltMovTEMP := ""


	default cFilialFiltro := ""


	FGX_CheckValidMovVei(@aMovVei, @aMovValidos)


	// Analisa as movimentacoes validas para capturar a ultima movimentacao de entrada e ultima movimentacao de saida
	// alem disso, iremos gravar a ultima movimentacao do equipamento válida 
	lPriMov := .t.
	For ni := 1 to len(aMovVei)

		// processa somente filiais do parametro passado para a funcao 
		// a principio foi feita essa alteração 
		if ! empty(cFilialFiltro) .and. !(aMovVei[ni,2] $ cFilialFiltro)
			loop
		endif
		//

		if lPriMov
			cFilUltMovTEMP := aMovVei[ni,2]
			cUltMovTEMP := aMovVei[ni,3]
			lPriMov := .f.
		endif

		If aMovValidos[ni] // apenas movimentacoes validas

			// ENTRADA /////////////////////////////////////
			If Empty(cEFilMov) .and. left(aMovVei[ni,1],1)=="E" // Left adicionado para evitar erro na CAOA. Estava vindo com espacos...
				cEFilMov := aMovVei[ni,2] 						// Filial de Entrada
				cENumMov := aMovVei[ni,3] 						// Numero da Transacao de Entrada
				cETipMov := aMovVei[ni,9] 						// Tipo do Faturamento
				If Empty(cXUltMov)
					cXUltMov := "E" 							// Ultima Movimentacao Entrada
					cXUltOpe := aMovVei[ni,5]					// Ultima Operacao Realizada no Veiculo
					nPosMovValidos := nI
				EndIf

			// SAIDA ///////////////////////////////////////
			ElseIf Empty(cSFilMov) .and. left(aMovVei[ni,1],1)=="S"   // Left adicionado para evitar erro na CAOA. Estava vindo com espacos...
				cSFilMov := aMovVei[ni,2] 						// Filial de Saida
				cSNumMov := aMovVei[ni,3] 						// Numero do Transacao de Saida
				cSTipMov := aMovVei[ni,9] 						// Tipo do Faturamento
				If Empty(cXUltMov)
					cXUltMov := "S" 							// Ultima Movimentacao Saida
					cXUltOpe := aMovVei[ni,5]					// Ultima Operacao Realizada no Veiculo
					nPosMovValidos := nI
				EndIf
			EndIf

			If !Empty(cEFilMov) .and. !Empty(cSFilMov)
				Exit
			EndIf

		EndIf
	Next


	DbSelectArea("VV1")
	DbSetOrder(2)

	// VV1_SITVEI
	// 0=Estoque
	// 1=Vendido
	// 2=Em Transito
	// 3=Remessa
	// 4=Consignado
	// 5=Transferido
	// 6=Reservado
	// 7=Progresso
	// 8=Pedido
	// 9=Requisitado OS

	// Com base na ultima operacao, atualizamos o SITVEI
	If cXUltMov == "E"
		cSitVei := FGX_retEntradaSitVei(cXUltOpe, aMovVei)

	ElseIf cXUltMov == "S"

		cSitVei := FGX_retSaidaSitVei(cXUltOpe, aMovVei, nPosMovValidos, aMovValidos, .f.)
	
	EndIf

	//// Luis: Problema de Saldo Inicial de Veículos
	//If len(aMovVei) == 0
	//	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	//	DBSelectArea("SB9")
	//	DBSetOrder(1)
	//	DBSeek(xFilial("SB9")+SB1->B1_COD)
	//	While xFilial("SB9") == SB9->B9_FILIAL .and. SB1->B1_COD == SB9->B9_COD
	//		If SB9->B9_QINI > 0
	//			cSitVei := "0"
	////				cEFilMov := VV1->VV1_STATUS
	//		EndIf
	//		DBSkip()
	//	EndDo
	//
	//	cEFilMov := VV1->VV1_FILENT
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 12/04/10                     ³
	//³Atualiza Proprietario atual do Veiculo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cProAtu := VV1->VV1_PROATU
	cLjpAtu := VV1->VV1_LJPATU
	cDocpAtu := VV1->VV1_DOCIND

	For ni := 1 to len(aMovVei)

 		// Entrada
		If aMovVei[ni,1]=="E"
			// Entrada por 0-Normal / 3-Transferencia / 5-Devolucao
			If aMovVei[nI,5] $ "0,3,5"
				aAuxCodCli := FM_SM0CLFR(1, aMovVei[nI,2]) // Pesq. Fornecedor da Filial Corrente
				cProAtu := aAuxCodCli[1]
				cLjpAtu := aAuxCodCli[2]
				cDocpAtu := aAuxCodCli[3]
				Exit
			EndIf

		// Saida
		ElseIf aMovVei[ni,1]=="S" 
			// Saida por 0-Venda
			If aMovVei[nI,5] $ "0"
				cProAtu := aMovVei[nI,7]
				cLjpAtu := aMovVei[nI,8]
				cDocpAtu := aMovVei[nI,10]
				Exit
			EndIf
		EndIf

	Next ni
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a ultima Movimentacao for de saida e a saida for por faturamento direto, gravar FATDIR no VV1_TRACPA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cXUltMov == "S" .and. cSTipMov == "2"
		cEFilMov := cSFilMov
		cENumMov := "FATDIR"
	EndIf
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao houver Movimentacao de Entrada/Saida e o Veiculo for de Pedido, continuar o veiculo em Pedido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VV1->VV1_SITVEI == "8" .and. Empty(cXUltMov) .and. Empty(cENumMov)
		cEFilMov := VV1->VV1_FILENT // Filial de Entrada
		cSitVei  := VV1->VV1_SITVEI // SitVei "8" -> Pedido
	EndIf
	//
	aRetorno := {;
		cSitVei,;
		cXUltMov,;
		cXUltOpe,;
		cProAtu,;
		cLjpAtu,;
		cEFilMov,;
		cENumMov,;
		cSFilMov,;
		cSNumMov,;
		cFilUltMovTEMP,;
		cUltMovTEMP,;
		cDocpAtu }

Return aRetorno

/*/{Protheus.doc} FGX_CheckValidMovVei
	Processa matriz de movimentação e retorna matriz de movimentação válida

	@author Rubens Takahashi
	@since 06/01/2024
	@type function
/*/
Function FGX_CheckValidMovVei(aMovVei, aMovValidos)

	local ni
	Local nContaRem  := 0
	Local lValidMov  := .t.
	Local aChaveValid := {"",""}

	// faz um laço "matando" no vetor aMovValidos as movimentacoes que representam consig ou remessa e seus retornos
	For ni := 1 to len(aMovVei)

		aAdd(aMovValidos,lValidMov)

		// Entrada
		// 7 -> Retorno de Remessa
		// 8 -> Retorno de Consignado
		If aMovVei[ni,5] $ "78" .and. aMovVei[ni,1] == "E"

			If lValidMov

				aMovValidos[ni] = .f.
				lValidMov := .f.

				If aMovVei[ni,5] == "7"  // 7 -> Retorno de Remessa
					aChaveValid := {"3",aMovVei[ni,2]} // "3 -> Saida por Remessa" // Filial do Movimento 
				Else
					aChaveValid := {"5",aMovVei[ni,2]} // "5" -> Saida por Consignacao // Filial do Movimento
				EndIf

			Else

				nContaRem ++

			EndIf
		EndIf

		// Saida 
		// Mesma Filial .AND. Operacao (OPEMOV) .AND. Movimento de Saida
		If aMovVei[ni,2] == aChaveValid[2] .and. aMovVei[ni,5] == aChaveValid[1] .and. aMovVei[ni,1] == "S"
			If nContaRem <= 0
				lValidMov := .t.
			Else
				nContaRem--
			EndIf

		// Operacao da aMovVei .AND. Operacao de
		ElseIf aMovVei[ni,5] == aChaveValid[1] .and. aMovVei[ni,1] == "S"
			nContaRem--
		EndIf

	Next
Return

/*/{Protheus.doc} FGX_retEntradaSitVei
	Retorna a Situacao do Veiculo de acordo com a ultima operacao de entrada

	@author Rubens Takahashi
	@since 06/01/2024
	@type function
/*/
Function FGX_retEntradaSitVei(cXUltOpe, aMovVei)

	//  0=Normal                          
	//  1=Ped.Fabrica                     
	//  3=Transferencia                   
	//  5=Devolucao                       
	//  6=Frete                           
	//  7=Retorno de Remessa              
	//  8=Retorno de Consignacao          

	local cSitVei := " "
	Local aRemVen
	Local nJ
	local cStatAnterior
	local cStatAtual
	Local lRemVen    := .f.


	If cXUltOpe $ "01358"
		cSitVei := "0" // 0=Estoque

	ElseIf cXUltOpe == "7" // precisamos procurar uma venda anterior a remessa // 7=Retorno de Remessa

		//aRemVen := FGX_VEIMOVS( _cChassi )
		aRemVen := aClone(aMovVei)

		cStatAnterior := " "
		cStatAtual := " "

		For nj := 2 to Len(aRemVen)

			cStatAnterior := cStatAtual
			cStatAtual := aRemVen[nj,1]+aRemVen[nj,5]

			// S3 - [S]aida por Remessa
			// S0 - [S]aida  por Venda
			// E7 - [E]ntrada por Retorno de Remessa
			If ! ( cStatAtual $ "S3.S0.E7" )
				Exit
			EndIf

			// cStatAnterior -> Saida por Remessa
			// cStatAtual -> Saida por Venda
			If cStatAnterior == "S3" .and. cStatAtual == "S0"
				lRemVen := .t.
			EndIf
		Next

		If lRemVen
			cSitVei := "1" // 1=Vendido
		Else
			cSitVei := "0" // 0=Estoque
		EndIf

	//  2=Remessa                         
	ElseIf cXUltOpe == "2"
		cSitVei := "3" // 3=Remessa
		
	//  4=Consignacao                     
	ElseIf cXUltOpe == "4"
		cSitVei := "4" // 4=Consignado
	Else
		cSitVei := VV1->VV1_SITVEI
	EndIf

Return cSitVei


/*/{Protheus.doc} FGX_retSaidaSitVei
	Retorna a Situacao do Veiculo de acordo com a ultima operacao de saida

	@author Rubens Takahashi
	@since 06/01/2024
	@type function
/*/
Function FGX_retSaidaSitVei(cXUltOpe, aMovVei, nPosMovValidos, aMovValidos, lRecursivo)

	// 1=Simulacao
	// 2=Transferencia
	// 3=Remessa
	// 4=Devolucao
	// 5=Consignado
	// 6=Ret Remessa
	// 7=Ret Consignado
	// 8=Venda Futura  

	local cSitVei := " "
	Local aRemVen
	Local nJ
	Local ni
	//Local lBlqVei    := .f.
	Local cStatAnterior
	Local cStatAtual

	// 0=Venda
	If cXUltOpe == "0"
		cSitVei := "1" // 1=Vendido

	// 2=Transferencia
	ElseIf cXUltOpe == "2"
		cSitVei := "2" // 2=Em Transito
	
	// 3=Remessa
	ElseIf cXUltOpe == "3"
		
		aRemVen := aClone(aMovVei)

		cStatAnterior := " "
		cStatAtual := " "

		For nj := 2 to Len(aRemVen)

			cStatAnterior := cStatAtual
			cStatAtual := aRemVen[nj,1]+aRemVen[nj,5] // [E]ntrada/[S]aida + OPEMOV

			// S3 - [S]aida por Remessa
			// S0 - [S]aida por Venda
			// E7 - [E]ntrada por Retorno de Remessa
			If ! (cStatAtual $ "S3.S0.E7")
				exit
			EndIf
			
			// S0 - [S]aida  por Venda
			//If cStatAtual == "S0"
			//	lBlqVei := .t.
			//EndIf

		Next

		cSitVei := "3" // 3=Remessa

	// 5=Consignado
	ElseIf cXUltOpe == "5"
		cSitVei := "4" // 4=Consignado

	// 4=Devolucao
	// 6=Ret Remessa
	// 7=Ret Consignado
	ElseIf cXUltOpe $ "467"

		cSitVei := " "

		if ! lRecursivo

			For ni := nPosMovValidos+2 to len(aMovVei)

				// apenas movimentacoes validas
				If aMovValidos[ni] .and. aMovVei[ni,1]=="S"
					cSitVei := FGX_retSaidaSitVei(aMovVei[ni,5], aMovVei, 0 , aMovValidos, .t. )
					return cSitVei
				EndIf

			Next

			// Se a ultima movimentacao é de Saida por Devolucao e nao encontrou um sitvei válido
			// verifica se existe um pedido de compra 
			if cXUltOpe == "4" .and. empty(cSitVei)
				cSQL := "SELECT COUNT(*) " +;
					"FROM " + RetSQLName("VQ0") +;
					" WHERE VQ0_FILIAL = '" + xFilial("VQ0") + "'" +;
						" AND VQ0_CHASSI = '" + VV1->VV1_CHASSI + "'" +;
						" AND VQ0_STATUS <> '3'" +;
						" AND D_E_L_E_T_  = ' '"
				if fm_sql(cSQL) > 0
					cSitVei := "8"
				endif
			endif
		endif

	Else
		cSitVei := VV1->VV1_SITVEI
	EndIf

Return cSitVei

/*/{Protheus.doc} FGX_Get_VV1_FieldUpdate
	Atualiza dados do veiculo dependendo do ultima movimentacao do veiculo

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function FGX_Get_VV1_FieldUpdate(cSitVei, cXUltMov, cXUltOpe, cProAtu, cLjpAtu, cEFilMov, cENumMov, cSFilMov, cSNumMov,_cRotOrigem, cFilUltMovTEMP, cUltMovTEMP, cDocpAtu, cParFilMov, cParNumMov)

	local aFldUpdate := {}
	local aMovVeiAux
	//local excluirChassiBB := .f.

	DbSelectArea("VV1")
	if alltrim(VV1->VV1_FILENT) == alltrim(cEFilMov)
	else
		AADD(aFldUpdate, { "VV1_FILENT" , cEFilMov } )
	endif

	if alltrim(VV1->VV1_TRACPA) == alltrim(cENumMov) // Numero da Transacao de Entrada
	else
		AADD(aFldUpdate, { "VV1_TRACPA" , cENumMov })
	endif

	if alltrim(VV1->VV1_FILSAI) == alltrim(cSFilMov) // Filial de Saida
	else
		AADD(aFldUpdate, { "VV1_FILSAI" , cSFilMov })
	endif

	if alltrim(VV1->VV1_NUMTRA) == alltrim(cSNumMov) // Numero do Transacao de Saida
	else
		AADD(aFldUpdate, { "VV1_NUMTRA" , cSNumMov })
	endif

	if alltrim(VV1->VV1_ULTMOV) == alltrim(cXUltMov) // Ultima Movimentacao "E"ntrada/"S"aida
	else
		AADD(aFldUpdate, { "VV1_ULTMOV" , cXUltMov })
	endif

	if alltrim(VV1->VV1_SITVEI) == alltrim(cSitVei)
	else
		AADD(aFldUpdate, { "VV1_SITVEI" , cSitVei })
	endif

	if VV1->VV1_TRANSM <> "0"
		AADD(aFldUpdate, { "VV1_TRANSM" , "0" })
	endif

	If VV1->VV1_BLQPRO <> "0" .and. cXUltMov == "S" .and. cXUltOpe == "0" // Saida por Venda
		If ( VV1->VV1_PROATU+VV1->VV1_LJPATU ) <> ( cProAtu+cLjpAtu ) // Mudou o Proprietario Atual ou a Loja do Proprietario Atual
			AADD(aFldUpdate, { "VV1_BLQPRO" , "0" }) // 0 = Veiculo NAO BLOQUEADO para Listas de Prospeccao
		EndIf
	EndIf

	if alltrim(VV1->VV1_PROATU) == alltrim(cProAtu)   // Proprietario Atual
	else
		AADD( aFldUpdate , { "VV1_PROATU" , cProAtu })
	endif

	if alltrim(VV1->VV1_LJPATU) == alltrim(cLjpAtu)   // Loja do Proprietario Atual
	else
		AADD( aFldUpdate , { "VV1_LJPATU" , cLjpAtu })
	endif

	if alltrim(VV1->VV1_DOCIND) == alltrim(cDocpAtu)   // CPF/CNPJ do Proprietario Atual
	else
		AADD( aFldUpdate , { "VV1_DOCIND" , cDocpAtu })
	endif

	If cXUltMov == "E" .and. cXUltOpe $ "0" .and. VV1->VV1_ESTVEI == "1" .and. VV1->VV1_DONOVU <> "1"
		AADD( aFldUpdate , { "VV1_DONOVU" , "1" })
	EndIf

	If cXUltMov == "S" .and. cXUltOpe $ "1" .and. VV1->VV1_DONOVU == "2"
		AADD( aFldUpdate , { "VV1_DONOVU" , "3" })
	EndIf

	//If cXUltMov == "S" .and. cXUltOpe == "0" // Saida por Venda
	//	If ( VV1->VV1_PROATU+VV1->VV1_LJPATU ) <> ( cProAtu+cLjpAtu ) // Mudou o Proprietario Atual ou a Loja do Proprietario Atual
	//EndIf

	if VV1->( fieldPos( "VV1_DTPCOM" ) ) > 0
		aMovVeiAux := FGX_VEIMOVS( VV1->VV1_CHASSI, "E", "0" )	// Entradas - Compras
		if len( aMovVeiAux ) > 0
			aSort( aMovVeiAux,,,{|a,b| a[12] < b[12] })	// ordenar por Emissao da NF

			// data de primeira compra e primeira digitacao da compra nunca serão atualizadas
			// se por algum motivo estiverem erradas, devem ser corrigidas manualmente ou 
			// o conteudo do campo deve ser limpo para que seja recalculado
			if VV1->( fieldPos( "VV1_DTPCOM" ) ) > 0 .and. Empty(VV1->VV1_DTPCOM)
				AADD( aFldUpdate , { "VV1_DTPCOM" , StoD( aMovVeiAux[1,12] ) }) // Dt 1a compra
			endif

			if VV1->( fieldPos( "VV1_DTDPCP" ) ) > 0 .and. Empty(VV1->VV1_DTDPCP)
				AADD( aFldUpdate , { "VV1_DTDPCP" , StoD( aMovVeiAux[1,11] ) }) // Dt Dig 1 compr
			endif

			if VV1->( fieldPos( "VV1_DTUCOM" ) ) > 0 .and. VV1->VV1_DTUCOM != StoD( aTail(aMovVeiAux)[12] )
				AADD( aFldUpdate , { "VV1_DTUCOM" , StoD( aTail(aMovVeiAux)[12] ) }) // Dt Ult compra
			endif

			if VV1->( fieldPos( "VV1_DTDUCP" ) ) > 0 .and. VV1->VV1_DTDUCP != StoD( aTail(aMovVeiAux)[11] )
				AADD( aFldUpdate , { "VV1_DTDUCP" , StoD( aTail(aMovVeiAux)[11] ) }) // Dt Ult Dig cmp
			endif
		
		// se não houver movimentações de entrada por compra, limpa os campos de data de compra
		else
			if VV1->( fieldPos( "VV1_DTPCOM" ) ) > 0 .and. !Empty(VV1->VV1_DTPCOM)
				AADD( aFldUpdate , { "VV1_DTPCOM" , CtoD(" ") }) // Dt 1a compra
			endif

			if VV1->( fieldPos( "VV1_DTDPCP" ) ) > 0 .and. !Empty(VV1->VV1_DTDPCP)
				AADD( aFldUpdate , { "VV1_DTDPCP" , CtoD(" ") }) // Dt Dig 1 compr
			endif

			if VV1->( fieldPos( "VV1_DTUCOM" ) ) > 0 .and. !Empty(VV1->VV1_DTUCOM)
				AADD( aFldUpdate , { "VV1_DTUCOM" , CtoD(" ") }) // Dt Ult compra
			endif

			if VV1->( fieldPos( "VV1_DTDUCP" ) ) > 0 .and. !Empty(VV1->VV1_DTDUCP)
				AADD( aFldUpdate , { "VV1_DTDUCP" , CtoD(" ") }) // Dt Ult Dig cmp
			endif
		endif
	endif

	if VV1->( fieldPos( "VV1_FILULV" ) ) > 0
		aMovVeiAux := FGX_VEIMOVS( VV1->VV1_CHASSI, "S", "0" )	// Saídas - Vendas
		if len( aMovVeiAux ) > 0
			aSort( aMovVeiAux,,,{|a,b| a[12] > b[12] })	// ordenar por Emissao da NF Descendente

			// Data da primeira venda não será atualizada.
			// Se estiver errada deve ser ajustada manualmente ou o conteudo do campo deve ser limpo
			// para que seja recalculado
			if VV1->( fieldPos( "VV1_DATVEN" ) ) > 0 .and. Empty(VV1->VV1_DATVEN)
				AADD( aFldUpdate , { "VV1_DATVEN" , StoD( aMovVeiAux[1,12] ) }) // Dt.1a.Venda
			endif

			if VV1->( fieldPos( "VV1_FILULV" ) ) > 0 .and. alltrim( VV1->VV1_FILULV ) != alltrim( aMovVeiAux[1,2] )
				AADD( aFldUpdate , { "VV1_FILULV" , aMovVeiAux[1,2] }) // Fil Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_CLIULV" ) ) > 0 .and. alltrim( VV1->VV1_CLIULV ) != alltrim( aMovVeiAux[1,7] )
				AADD( aFldUpdate , { "VV1_CLIULV" , aMovVeiAux[1,7] }) // Cli Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_CLJULV" ) ) > 0 .and. alltrim( VV1->VV1_CLJULV ) != alltrim( aMovVeiAux[1,8] )
				AADD( aFldUpdate , { "VV1_CLJULV" , aMovVeiAux[1,8] }) // Loj Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_DTUVEN" ) ) > 0 .and. VV1->VV1_DTUVEN != StoD( aMovVeiAux[1,12] )
				AADD( aFldUpdate , { "VV1_DTUVEN" , StoD( aMovVeiAux[1,12] ) }) // Dt.Ult.Venda
			endif

		// se não houver movimentações de saida por venda, limpa os campos de data de venda, filial e cliente
		else

			if VV1->( fieldPos( "VV1_FILULV" ) ) > 0 .AND. !Empty(VV1->VV1_FILULV)
				AADD( aFldUpdate , { "VV1_FILULV" , " " }) // Fil Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_CLJULV" ) ) > 0 .and. !Empty(VV1->VV1_CLJULV)
				AADD( aFldUpdate , { "VV1_CLJULV" , " " }) // Loj Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_CLIULV" ) ) > 0 .and. !Empty(VV1->VV1_CLIULV)
				AADD( aFldUpdate , { "VV1_CLIULV" , " " }) // Cli Ult. Vda
			endif

			if VV1->( fieldPos( "VV1_DATVEN" ) ) > 0 .and. !Empty(VV1->VV1_DATVEN)
				AADD( aFldUpdate , { "VV1_DATVEN" , CtoD(" ") }) // Dt.1a.Venda
			endif

			if VV1->( fieldPos( "VV1_DTUVEN" ) ) > 0 .and. !Empty(VV1->VV1_DTUVEN)
				AADD( aFldUpdate , { "VV1_DTUVEN" , CtoD(" ") }) // Dt.Ult.Venda
			endif

		endif
	endif

	//varInfo("FGX_Get_VV1_FieldUpdate", aFldUpdate)

Return aFldUpdate

/*/{Protheus.doc} FGX_GetBB_VV1_FieldUpdate
	Verifica o tipo de movimento e grava campos relacionados ao blackbird no VV1

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
Function FGX_GetBB_VV1_FieldUpdate(aFldUpdate, cXUltMov, cXUltOpe, cEFilMov, cENumMov, cSFilMov, cSNumMov, cFilUltMovTEMP, cUltMovTEMP, _cRotOrigem, cParFilMov, cParNumMov)

	local lenIniFldUpdate := len(aFldUpdate)

	if cXUltMov == "S"
		FGX_ATUBBSAIDA(@aFldUpdate, cXUltOpe, cSFilMov, cSNumMov)
	elseif cXUltMov == "E"
		FGX_ATUBBENTRADA(@aFldUpdate, cXUltOpe, cEFilMov, _cRotOrigem)
	elseif FGX_PEDVEICULO(VV1->VV1_CHASSI)
		FGX_ATUBBPEDIDO(@aFldUpdate)
	else // limpando os status do equipamento
		FGX_STBBVV1(;
			@aFldUpdate,;
			IIF( ! empty(VV1->VV1_PROATU) , "1" , "" ) ,; // VV1_BBEQTY Se tiver proprietario, considera 1=CustomerEquipment
			,;  // VV1_BBSTTY 
			"",;  // VV1_BBINST
			"",;  // VV1_BBSTST
			"",;  // VV1_BBYARD
			' ' ,;
			cSFilMov)
	endif


	// Saida por Devolucao de Compra
	// Nao encontrou uma movimentacao de entrada
	// Nesses casos, vamos excluir o registro no blackbird pois nao saberemos se o veiculo vai ser excluido do concessionario 
	if (cXUltMov == "S" .and. cXUltOpe == "4") .or. Empty(cXUltMov)

		// Verifica se existe um pedido de compra.
		// Se nao tiver pedido, nos vamos excluir o equipamento no blackbird 
		//if ! FGX_PEDVEICULO(VV1->VV1_CHASSI) .and. _cRotOrigem <> "VX000INC" .and. _cRotOrigem <> "VEIXA001 - VX000EMINF_1"
			//Conout(" __   ___        __        ___       __   __      ___  __          __              ___      ___  __  ")
			//Conout("|__) |__   |\/| /  \ \  / |__  |\ | |  \ /  \    |__  /  \ |  | | |__)  /\   |\/| |__  |\ |  |  /  \ ")
			//Conout("|  \ |___  |  | \__/  \/  |___ | \| |__/ \__/    |___ \__X \__/ | |    /~~\  |  | |___ | \|  |  \__/ ")
			//Conout("                                                                                                     ")
		//	// Conout("FGX_AMOVVEI -> Nao existe Pedido de compra... Vamos excluir o equipamento do BB")
		//	AADD( aFldUpdate , { "VV1_BBDEL" , "1" })
		//endif
	else
		// Verifica se o registro esta deletado, nesses casos vamos sinalizar que o registro nao esta deletado para que o fonte de
		// eventos transmita uma mensagem de CREATE ou UPDATE no balckbird
		if VV1->VV1_BBDEL == "1"
			AADD( aFldUpdate , { "VV1_BBDEL" , "0" })
		endif
	endif

	if lenIniFldUpdate <> len(aFldUpdate)

		//varInfo("FGX_GetBB_VV1_FieldUpdate", aFldUpdate)

		if alltrim(_cRotOrigem) == "VX0020083_CancelaReservaBlackBird"
			AADD( aFldUpdate , { "VV1_AUXFIL" , cParFilMov } ) 
			AADD( aFldUpdate , { "VV1_AUXMOV" , cParNumMov } )
			AADD( aFldUpdate , { "VV1_ROTINA" , _cRotOrigem })
		else
			if ! empty(cUltMovTEMP)
				AADD( aFldUpdate , { "VV1_AUXFIL" , cFilUltMovTEMP } ) 
				AADD( aFldUpdate , { "VV1_AUXMOV" , cUltMovTEMP    } )
			endif

			if ! empty(_cRotOrigem)
				AADD( aFldUpdate , { "VV1_ROTINA" , _cRotOrigem })
			endif
		endif
	endif

Return aFldUpdate

/*/{Protheus.doc} FGX_GetBB_VV1_FieldUpdate
	Grava os campos do black bird relacionados a pedidos

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
static function FGX_ATUBBPEDIDO(aFldUpdate)
	local cSQL :=;
		"SELECT VQ0_FILENT, VQ0_FATDIR " +;
		 " FROM " + RetSQLName("VQ0") +;
		" WHERE VQ0_FILIAL = '" + xFilial("VQ0") + "'" +;
		  " AND VQ0_CHASSI = '" + VV1->VV1_CHASSI + "'" +;
		  " AND VQ0_STATUS <> '3'" +; // 1=Confirmado;2=Faturado;3=Cancelado
		  " AND D_E_L_E_T_  = ' '" +;
		" ORDER BY VQ0_NUMPED"
	
	cAlVQ0 := "TAUXVQ0"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAlVQ0, .F., .T. )

	if ! (cAlVQ0)->(eof())

		// Qualquer mudanca neste pondo requer revisao no VEIA140 (pedido de compra)
		FGX_STBBVV1(;
			@aFldUpdate,;
			IIF((cAlVQ0)->VQ0_FATDIR == "0", "1", "2"),; // VV1_BBEQTY -> Venda direta 1=CustomerEquipment /Outros 2=StockUnit
			,;     // VV1_BBSTTY -> 
			"2",;  // VV1_BBINST -> 2=Stock
			"1",;  // VV1_BBSTST -> 1=Pending
			"0",;  // VV1_BBYARD -> 0=Não
			(cAlVQ0)->VQ0_FILENT ,; // cVV1LOCRID
			"") // cVV1SOLCID)

	endif

	(cAlVQ0)->(dbCloseArea())

return

/*/{Protheus.doc} FGX_PEDVEICULO
	Verifica se tem pedido

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
function FGX_PEDVEICULO(cChassi)
	local cSQL :=;
		"SELECT COUNT(VQ0_FILIAL) " +;
		 " FROM " + RetSQLName("VQ0") +;
		" WHERE VQ0_FILIAL = '" + xFilial("VQ0") + "'" +;
		  " AND VQ0_CHASSI = '" + cChassi + "'" +;
		  " AND VQ0_STATUS <> '3'" +; // 1=Confirmado;2=Faturado;3=Cancelado
		  " AND D_E_L_E_T_  = ' '"
return fm_sql(cSql) > 0

/*/{Protheus.doc} FGX_ATUBBSAIDA
	Grava os campos do black bird relacionados a movimentos de saida

	Campos e suas opções para consulta rápida
	VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
	VV1_BBSTTY - 1=New;2=Used;3=Demo
	VV1_BBINST - 1=Sold;2=Stock;3=Loaner;4=OnHold;5=Rental;6=Demo;7=Shop ;8=Asset
	VV1_BBSTST - 1=Pending;2=InStock;3=Invoiced;4=Rental
	VV1_BBYARD - 0=Não;1=Sim

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
function FGX_ATUBBSAIDA(aFldUpdate, cXUltOpe, cSFilMov, cSNumMov)
	local cStockType := IIF(VV1->VV1_DEMONS == "1", "3", IIF( VV1->VV1_ESTVEI == "0" , "1" , "2")) // '1=New;2=Used;3=Demo'
	local cEquipType := VV1->VV1_BBEQTY
	local cRemDemo := ""
	local cSql     := ""
	//local cAlinha := va070_tabsize()

	Conout(" FGX_ATUBBSAIDA -> " + VV1->VV1_ESTVEI + " - " + cStockType + " - " + VV1->VV1_CHASSI)

	do case
	case cXUltOpe == "0" // 0=Venda
		FGX_STBBVV1(@aFldUpdate,;
			'1',;        // VV1_BBEQTY - 1=CustomerEquipment
			cStockType,; // VV1_BBSTTY - 1=New;2=Used;3=Demo
			'1',;        // VV1_BBINST - 1=Sold
			'3' ,;       // VV1_BBSTST - 3=Invoiced
			'0',;        // VV1_BBYARD - 0=Não;1=Sim
			' ' ,;       // VV1_LOCRID
			cSFilMov )	 // VV1_SOLCID

	case cXUltOpe == "1" // 1=Simulacao

	case cXUltOpe == "2" // 2=Transferencia
		FGX_STBBVV1( @aFldUpdate,;
			,;// VV1_BBEQTY
			,;// VV1_BBSTTY
			,;// VV1_BBINST
			,;// VV1_BBSTST
			'0',;// VV1_BBYARD
			,;// VV1_LOCRID
			) // VV1_SOLCID

	// 13/12/2023 - Nessa primeira implementação, não vamos tratar movimentações de simples remessa pois entendemos que são irrelevantes.
	case cXUltOpe == "3" .and. cEquipType == "2" // 3=Remessa/VV1_BBEQTY == 2 (Stock Unit) - Customer Equipment (VV1_BBEQTY == 1) será desconsiderado na integração
		cSql += " SELECT VVA_DEMONS FROM  " + RetSqlName("VVA")
		cSql += "  WHERE VVA_FILIAL = '"+xFilial('VVA')+"' "
		cSql += "    AND VVA_NUMTRA = '"+cSNumMov+"' "
		cSql += "    AND VVA_CHASSI = '"+VV1->VV1_CHASSI+"' "
		cSql += "    AND D_E_L_E_T_ = ' ' "

		cRemDemo := FM_SQL(cSql)
		FGX_STBBVV1(@aFldUpdate,;
			,; // VV1_BBEQTY - 2=StockUnit
			,;    // VV1_BBSTTY - 
			IIF(cRemDemo == "1", "6", "3"),; // VV1_BBINST - Se Remessa de Demonstração e Stock Unit, 6=Demo, Senão 3=Loaner
			,; // VV1_BBSTST - 1=Pending
			'0',; // VV1_BBYARD - 0=Não
			 ,;   // VV1_LOCRID
			 )    // VV1_SOLCID


	case cXUltOpe == "4" // 4=Devolucao de Compra
		FGX_STBBVV1(@aFldUpdate ,;	// Saída Atendimento
			"2",; // VV1_BBEQTY - 2=StockUnit
			cStockType,; // VV1_BBSTTY - Novo
			"2",; // VV1_BBINST - 2=Stock  
			"1",; // VV1_BBSTST - 1=Pending
			"0",; // VV1_BBYARD - 0=Nao
			,;    // VV1_LOCRID
			)     // VV1_SOLCID

	case cXUltOpe == "5" // 5=Consignado
		FGX_STBBVV1(@aFldUpdate,; // Saída por Consignação
			,; // VV1_BBEQTY - 2=StockUnit
			,;    // VV1_BBSTTY - 
			'3',; // VV1_BBINST - 3=Loaner
			,; // VV1_BBSTST - 1=Pending
			'0',; // VV1_BBYARD - 0=Não
			 ,;   // VV1_LOCRID
			 )    // VV1_SOLCID

	case cXUltOpe == "6" .and. cEquipType == "2"	// 6=Ret/VV1_BBEQTY == 2 (Stock Unit) - Customer Equipment (VV1_BBEQTY == 1) será desconsiderado na integração
		FGX_STBBVV1(@aFldUpdate,; // Saída Retorno Remessa
			'1',; // VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
			' ',; // VV1_BBSTTY - 
			'1',; // VV1_BBINST - 1=Sold
			'3')  // VV1_BBSTST - 3=Invoiced

	case cXUltOpe == "7" // 7=Ret Consignado
		FGX_STBBVV1(@aFldUpdate,; // Saída Retorno Consignação
			'1',; // VV1_BBEQTY - 1=CustomerEquipment
			' ',; // VV1_BBSTTY - 
			'1',; // VV1_BBINST - 1=Sold
			'3')  // VV1_BBSTST - 3=Invoiced

	case cXUltOpe == "8" // 8=Venda Futura

	endcase

return

/*/{Protheus.doc} FGX_ATUBBENTRADA
	Grava os campos do black bird relacionados a movimentos de entrada

	Campos e suas opções para consulta rápida
	VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
	VV1_BBSTTY - 1=New;2=Used;3=Demo
	VV1_BBINST - 1=Sold;2=Stock;3=Loaner;4=OnHold;5=Rental;6=Demo;7=Shop ;8=Asset
	VV1_BBSTST - 1=Pending;2=InStock;3=Invoiced;4=Rental
	VV1_BBYARD - 0=Não;1=Sim

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
function FGX_ATUBBENTRADA(aFldUpdate, cXUltOpe, cEFilMov, _cRotOrigem)
	local cStockType := IIF(VV1->VV1_DEMONS == "1", "3", IIF( VV1->VV1_ESTVEI == "0" , "1" , "2")) // '1=New;2=Used;3=Demo'
	//local cAlinha := va070_tabsize()

	//Conout(" FGX_ATUBBENTRADA -> " + VV1->VV1_ESTVEI + " - " + cStockType + " - " + VV1->VV1_CHASSI + " - " + _cRotOrigem)

	do case
	case cXUltOpe == "0" // 0=Normal

		cVV1BBEQTY := '2'        // VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
		cVV1BBSTTY := cStockType // VV1_BBSTTY - 1=New;2=Used;3=Demo
		cVV1BBINST := '2'        // VV1_BBINST - 1=Sold;2=Stock;3=Loaner;4=OnHold;5=Rental;6=Demo;7=Shop ;8=Asset
		cVV1BBSTST := '2'        // VV1_BBSTST - 1=Pending;2=InStock;3=Invoiced;4=Rental
		cVV1BBYARD := '1'        // VV1_BBYARD - 0=Não;1=Sim
		cVV1LOCRID := cEFilMov   // VV1_LOCRID
		cVV1SOLCID := ' '        // VV1_SOLCID

		if _cRotOrigem <> "INITIAL DATA LOAD"
			// Verifica se o chassi esta em algum atendimento aprovado 
			cSQL := "SELECT COUNT(*) " +;
				" FROM " + RetSQLName("VVA") + " VVA " +;
					" JOIN " + RetSQLName("VV9") + " VV9 " +;
							" ON VV9.VV9_FILIAL = VVA.VVA_FILIAL " +;
						" AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA " +;
						" AND VV9.VV9_STATUS = 'L' " +; // Atendimento Aprovado
						" AND VV9.D_E_L_E_T_ = ' '" +;
				" WHERE VVA.VVA_FILIAL LIKE '" + AllTrim(cEmpAnt) + "%'" +;
					" AND VVA.VVA_CHAINT = '" + VV1->VV1_CHAINT + "'" +;
					" AND VVA.D_E_L_E_T_ = ' ' "
			// No caso em que a chamada vem do cancelamento de reserva de um atendimento, temos que excluir o proprio atendimento da consulta
			if _cRotOrigem $ "VX0020083_CancelaReservaBlackBird;VEIXA018 - VXI001CANCEL"
				cSQL += " AND ( VVA.VVA_FILIAL <> '" + VV9->VV9_FILIAL + "' AND VVA.VVA_NUMTRA <> '" + VV9->VV9_NUMATE + "' )"
			endif
			if fm_sql(cSQL) >= 1
				cVV1BBINST := '1' // VV1_BBINST - 1=Sold

			// Se nao tiver em pedido aprovado, verifica se o chassi esta reservado
			else
			
				// Verifica se o veiculo esta reservado 
				if VV1->VV1_RESERV == "1" .AND. ! Empty(VV1->VV1_DTHVAL) .AND. CtoD(Left(VV1->VV1_DTHVAL,6) + "20" + SubStr(VV1->VV1_DTHVAL,7,2)) >= dDataBase
					cVV1BBINST := '4'  // VV1_BBINST - 4=OnHold
				endif

			endif
		endif
		//

		FGX_STBBVV1( @aFldUpdate,;
			cVV1BBEQTY ,; // VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
			cStockType ,; // VV1_BBSTTY - 1=New;2=Used;3=Demo
			cVV1BBINST ,; // VV1_BBINST - 1=Sold;2=Stock;3=Loaner;4=OnHold;5=Rental;6=Demo;7=Shop ;8=Asset
			cVV1BBSTST ,; // VV1_BBSTST - 1=Pending;2=InStock;3=Invoiced;4=Rental
			cVV1BBYARD ,; // VV1_BBYARD - 0=Não;1=Sim
			cVV1LOCRID ,; // VV1_LOCRID
			cVV1SOLCID  ) // VV1_SOLCID

	case cXUltOpe == "1" // 1=Ped.Fabrica

	// 13/12/2023 - Nessa primeira implementação, não vamos tratar movimentações de simples remessa pois entendemos que são irrelevantes.
	case cXUltOpe == "2" // 2=Remessa
		FGX_STBBVV1( @aFldUpdate,;
			,;            // VV1_BBEQTY
			cStockType ,; // VV1_BBSTTY
			,;            // VV1_BBINST
			,;            // VV1_BBSTST
			,;            // VV1_BBYARD 
			,;            // VV1_LOCRID
			)             // VV1_SOLCID

	case cXUltOpe == "3" // 3=Transferencia

		// TEMPORARIO...
		// No cancelamento da Reserva de atendimento, nao tirando o VV1_BBINST de OnHold...
		// Para contornar temporariamente, quando chegar neste ponto e o status atual for OnHold, vou jogar '2'
		// ate  ter uma solucao definitiva 
		FGX_STBBVV1( @aFldUpdate,;
			,;         // VV1_BBEQTY
			,;         // VV1_BBSTTY
			iif( VV1->VV1_BBINST $ "1,4" , '2' , NIL ),;         // VV1_BBINST
			,;         // VV1_BBSTST
			'1',;      // VV1_BBYARD 
			cEFilMov,; // VV1_LOCRID
			' ')       // VV1_SOLCID

	case cXUltOpe == "4" // 4=Consignacao
		FGX_STBBVV1( @aFldUpdate,; // Entrada por Consignação
			'2',; // VV1_BBEQTY - 1=stock
			' ',; // VV1_BBSTTY - 
			'2',; // VV1_BBINST - 2=Stock
			'1') // VV1_BBSTST - 3=Pending

	case cXUltOpe == "5" // 5=Devolucao
		FGX_STBBVV1( @aFldUpdate,;
			'2',;        // VV1_BBEQTY - 2=StockUnit
			cStockType,; // VV1_BBSTTY - 
			'2',;        // VV1_BBINST - 2=Stock
			'2',;        // VV1_BBSTST - 2=InStock
			'1',;        // VV1_BBYARD - 1=Sim
			cEFilMov ,;  // VV1_LOCRID
			' ' )        // VV1_SOLCID

	case cXUltOpe == "6" // 6=Frete
	
	case cXUltOpe == "7" // 7=Retorno de Remessa
		FGX_STBBVV1( @aFldUpdate,;
			'2',; // VV1_BBEQTY - 2=StockUnit
			,;    // VV1_BBSTTY - 1=New;2=Used;3=Demo
			'2',; // VV1_BBINST - 2=Stock
			'2',; // VV1_BBSTST - 2=InStock
			'1',; // VV1_BBYARD - 1=Sim
			,;    // VV1_LOCRID
			)     // VV1_SOLCID

	case cXUltOpe == "8" // 8=Retorno de Consignacao
		FGX_STBBVV1( @aFldUpdate,; // Entrada por Retorno Consignação
			'2',; // VV1_BBEQTY - 2=StockUnit
			'' ,; // VV1_BBSTTY - 
			'2',; // VV1_BBINST - 2=Stock
			'2')  // VV1_BBSTST - 2=InStock
	
	endcase

return

/*/{Protheus.doc} FGX_STBBVV1
	Grava os campos de status de equipamento do blackbird

	Campos e suas opções para consulta rápida
	VV1_BBEQTY - 1=CustomerEquipment;2=StockUnit;3=FixedAsset
	VV1_BBSTTY - 1=New;2=Used;3=Demo
	VV1_BBINST - 1=Sold;2=Stock;3=Loaner;4=OnHold;5=Rental;6=Demo;7=Shop ;8=Asset
	VV1_BBSTST - 1=Pending;2=InStock;3=Invoiced;4=Rental
	VV1_BBYARD - 0=Não;1=Sim

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
function FGX_STBBVV1(aFldUpdate, cVV1BBEQTY, cVV1BBSTTY, cVV1BBINST, cVV1BBSTST, cVV1BBYARD , cVV1LOCRID, cVV1SOLCID)
	if cVV1BBEQTY <> NIL .and. ! alltrim(VV1->VV1_BBEQTY) == cVV1BBEQTY // Eq.Type
		AADD(aFldUpdate , { "VV1_BBEQTY" , cVV1BBEQTY , nil })
	endif

	if cVV1BBSTTY <> NIL .and. ! alltrim(VV1->VV1_BBSTTY) == cVV1BBSTTY // Stock Type
		AADD(aFldUpdate , { "VV1_BBSTTY" , cVV1BBSTTY , nil })
	endif

	if cVV1BBINST <> NIL .and. ! alltrim(VV1->VV1_BBINST) == cVV1BBINST // Inventory St
		AADD(aFldUpdate , { "VV1_BBINST" , cVV1BBINST , nil })
	endif

	if cVV1BBSTST <> NIL .and. ! alltrim(VV1->VV1_BBSTST) == cVV1BBSTST // Stock Un. St
		AADD(aFldUpdate , { "VV1_BBSTST" , cVV1BBSTST , nil })
	endif

	if cVV1BBYARD <> NIL .and. ! alltrim(VV1->VV1_BBYARD) == cVV1BBYARD // Em posse?
		AADD(aFldUpdate , { "VV1_BBYARD" , cVV1BBYARD , nil })
	endif

	if cVV1LOCRID <> NIL .and. ! VV1->VV1_LOCRID == PadR(cVV1LOCRID, Len(VV1->VV1_LOCRID) , " " ) // Location Ref
		AADD(aFldUpdate , { "VV1_LOCRID" , cVV1LOCRID , nil })
	endif
	
	if cVV1SOLCID <> NIL .and. ! VV1->VV1_SOLCID == PadR(cVV1SOLCID, Len(VV1->VV1_SOLCID) , " ") // Sold by Loc.
		AADD(aFldUpdate , { "VV1_SOLCID" , cVV1SOLCID , nil })
	endif
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FGX_PESQBRW³ Autor ³  Andre Luis Almeida  ³ Data ³ 13/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Avancada do Veiculo no BROWSE                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_PESQBRW(_cTipo,_cOPEMOV,lInverte)
Local nOpca := 0

Default lInverte := .f.
Private nCkPerg1:= 1
Private aComboStat := {"","1-"+STR0001,"0-"+STR0002,"2-"+STR0003} //"1-Valida","0-Cancelada","2-Devolvida"
Private cComboStat := ""
Private dDtIniAte  := dDataBase-(day(dDataBase)-1)
Private dDtFinAte  := dDataBase
Private cNroNFI  := space(len(IIf(_cTipo=="E",SF1->F1_DOC,SF2->F2_DOC)))
Private cSerNFI  := space(len(IIf(_cTipo=="E",SF1->F1_SERIE,SF2->F2_SERIE)))
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private cLevFor  := space(6)
Private cLevCli  := space(6)
Private cLevLj   := "  "
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )		// 1 - Valida
Private overm := LoadBitmap( GetResources() , "BR_VERMELHO" )	// 0 - Cancelada
Private opret := LoadBitmap( GetResources() , "BR_PRETO" ) 		// 2 - Devolvida
Private cLevPedFab := Space(Len(VV1->VV1_PEDFAB))
if  _cTipo == "E"
	DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0004) FROM  01,05 TO 21,85 OF oMainWnd //Pesquisa Chassi/Cliente/Status/Periodo/NF/Serie
Else
	DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0019) FROM  01,05 TO 19,85 OF oMainWnd //Pesquisa Chassi/Cliente/Status/Periodo/NF/Serie
Endif
if ( _cTipo == "E" .and. !lInverte) .or. ( _cTipo == "S" .and. !lInverte)
	@ 000,002 RADIO oRadio1 VAR nCkPerg1 3D SIZE 52,10 PROMPT OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0159) OF oLevPesq PIXEL ON CHANGE (FS_COMBOTIPO(_cTipo,lInverte),FS_PESQBRW(_cTipo,_cOPEMOV,.f.,lInverte))  //Chassi/Fornec. ### Status/Periodo ### NF/Serie ### Pedido
Else
	@ 000,002 RADIO oRadio1 VAR nCkPerg1 3D SIZE 52,10 PROMPT OemToAnsi(STR0018),OemToAnsi(STR0006),OemToAnsi(STR0007) OF oLevPesq PIXEL ON CHANGE (FS_COMBOTIPO(_cTipo,lInverte),FS_PESQBRW(_cTipo,_cOPEMOV,.f.,lInverte))  //Chassi/Cliente ### Status/Periodo ### NF/Serie
Endif
@ 009,055 SAY oChassi VAR STR0015 SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE
@ 009,077 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte)) PICTURE "@!" SIZE 80,08 OF oLevPesq PIXEL
if ( _cTipo == "E" .and. !lInverte) .or. ( _cTipo == "S" .and. !lInverte)
	@ 009,160 SAY oFornec VAR STR0016 SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE
	@ 009,193 MSGET oLevFor VAR cLevFor F3 "SA2" VALID FS_PESQFOR(cLevFor,_cTipo) PICTURE "@!" SIZE 40,08 OF oLevPesq PIXEL
	@ 009,233 MSGET oLevLj VAR cLevLj VALID FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) PICTURE "@!" SIZE 20,08 OF oLevPesq PIXEL
	@ 009,254 BUTTON oOK PROMPT OemToAnsi(STR0011) OF oLevPesq SIZE 10,11 PIXEL ACTION FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) //ok
Else
	@ 009,160 SAY oCliente VAR STR0017 SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE
	@ 009,190 MSGET oLevCli VAR cLevCli F3 "SA1" VALID FS_PESQFOR(cLevCli,_cTipo) PICTURE "@!" SIZE 40,08 OF oLevPesq PIXEL
	@ 009,233 MSGET oLevLj VAR cLevLj VALID FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) PICTURE "@!" SIZE 20,08 OF oLevPesq PIXEL
	@ 009,254 BUTTON oOK PROMPT OemToAnsi(STR0011) OF oLevPesq SIZE 10,11 PIXEL ACTION FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) //ok
Endif
@ 009,055 MSCOMBOBOX oCoboStat VAR cComboStat VALID FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) SIZE 60,08 ITEMS aComboStat OF oLevPesq PIXEL COLOR CLR_BLUE
@ 010,125 SAY oTit1 VAR STR0008+":" SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE   		//Periodo:
@ 010,187 SAY oTit2 VAR STR0009 SIZE 10,08 OF oLevPesq PIXEL COLOR CLR_BLUE    		  		// a
@ 010,070 SAY oTit3 VAR STR0010+":" SIZE 40,08 OF oLevPesq PIXEL COLOR CLR_BLUE 	//Nro NF/Serie
If _cTipo == "E" // Entrada
	@ 009,110 MSGET oNroNFI VAR cNroNFI F3 "SF1VEI" VALID IIf(!Empty(cNroNFI),cSerNFI:=SF1->F1_SERIE,.t.) PICTURE "@!" SIZE 40,08 OF oLevPesq PIXEL
Else // _cTipo == "S" // Saida
	@ 009,110 MSGET oNroNFI VAR cNroNFI F3 "SF2VEI" VALID IIf(!Empty(cNroNFI),cSerNFI:=SF2->F2_SERIE,.t.) PICTURE "@!" SIZE 40,08 OF oLevPesq PIXEL
EndIf
@ 009,156 MSGET oSerNFI VAR cSerNFI PICTURE "@!" SIZE 15,08 OF oLevPesq PIXEL
@ 009,190 BUTTON oOKNF PROMPT OemToAnsi(STR0011) OF oLevPesq SIZE 30,11 PIXEL ACTION FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) //ok
@ 009,146 MSGET oDtIniAte VAR dDtIniAte VALID FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) PICTURE "@D" SIZE 60,08 OF oLevPesq PIXEL
@ 009,210 MSGET oDtFinAte VAR dDtFinAte VALID FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) PICTURE "@D" SIZE 60,08 OF oLevPesq PIXEL
@ 010,090 SAY oTitPedFab VAR STR0160 SIZE 50,08 OF oLevPesq PIXEL COLOR CLR_BLUE // Pedido:
@ 009,125 MSGET oLevPedFab VAR cLevPedFab PICTURE "@!" SIZE 80,08 OF oLevPesq PIXEL
@ 009,240 BUTTON oButPedFab PROMPT OemToAnsi(STR0011) OF oLevPesq SIZE 30,11 PIXEL ACTION FS_PESQBRW(_cTipo,_cOPEMOV,.t.,lInverte) //ok
oTit1:lVisible:=.f.
oTit2:lVisible:=.f.
oTit3:lVisible:=.f.
oOKNF:lVisible:=.f.
oCoboStat:lVisible:=.f.
oDtIniAte:lVisible:=.f.
oDtFinAte:lVisible:=.f.
If nCkPerg1 == 1 // Chassi/Cliente
	oOK:lVisible:=.t.
Endif
oNroNFI:lVisible:=.f.
oSerNFI:lVisible:=.f.
oTitPedFab:lVisible:=.f.
oLevPedFab:lVisible:=.f.
oButPedFab:lVisible:=.f.
DEFINE SBUTTON FROM 009,274 TYPE 2 ACTION (nOpca := 0,oLevPesq:End()) ENABLE OF oLevPesq

If _cTipo == "E" // Entrada
	@ 041,002 LISTBOX oLbLevPesq FIELDS HEADER "",RetTitle("VVF_FILIAL"),RetTitle("VVF_DATMOV"),RetTitle("VVF_NUMNFI"),RetTitle("VVF_VALMOV"),Alltrim(RetTitle("VVF_CODFOR"))+" / "+Alltrim(RetTitle("VV0_CODCLI")) COLSIZES 10,35,35,25,40,150 SIZE 313,105 OF oLevPesq PIXEL ON DBLCLICK (nOpca:=oLbLevPesq:nAt,oLevPesq:End())
Else // _cTipo == "S" // Saida
	@ 029,002 LISTBOX oLbLevPesq FIELDS HEADER "",RetTitle("VV0_FILIAL"),RetTitle("VV0_DATMOV"),RetTitle("VV0_NUMNFI"),RetTitle("VV0_VALMOV"),Alltrim(RetTitle("VV0_CODCLI"))+" / "+Alltrim(RetTitle("VVF_CODFOR")) COLSIZES 10,35,35,25,40,150 SIZE 313,105 OF oLevPesq PIXEL ON DBLCLICK (nOpca:=oLbLevPesq:nAt,oLevPesq:End())
EndIf
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
If _cTipo == "E" // Entrada
	dbSelectArea("VVF")
Else // _cTipo == "S" // Saida
	dbSelectArea("VV0")
EndIf
If nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(1)
	DbSeek(left(aLevPesq[nOpca,3],FWSizeFiliial())+ aLevPesq[nOpca,1])
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQFOR ³ Autor ³  Andre Luis Almeida  ³ Data ³ 13/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o A2_LOJA (Fornecedor) ou o A1_LOJA (Cliente)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQFOR(clevant,_cTipo)
if _cTipo == "E"
	if !Empty(cLevant)
		cLevLj := SA2->A2_LOJA
	Endif
Else
	if !Empty(cLevant)
		cLevLj := SA1->A1_LOJA
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQBRW ³ Autor ³  Andre Luis Almeida  ³ Data ³ 13/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa AVANCADA -> VVF-ENTRADA / VV0-SAIDA //            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//
Static Function FS_PESQBRW(_cTipo,_cOPEMOV,_lMsg,lInverte)
Local cEmpAtu  := ""
Local cNome    := ""
Local lOk      := .t.
Local cQuery   := ""
Local cQAlias  := IIf(_cTipo=="E","SQLVVF","SQLVV0")
Local cFilLibs := ""
Local lVVF_TIPMOV := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lVV0_TIPMOV := ( VVF->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local cAliPedFab := "ALIPEDFAB"
Local cChaPedFab := "" // Chassi do Pedido
Local nFilVV1Sem := 0 // Tamanho da filial sem os espaços
Local nFilVV1Com := 0 // Tamanho da filial com os espaços
Local cFWCodEmp := FWCodEmp() // Código da empresa logada
Default lInverte := .f.

if lInverte
	cTmpStr := cLevFor
	cLevFor := cLevCli
	cLevCli := cTmpStr
endif

if _cTipo == "E"
	If (Empty(cLevChas) .and. Empty(cLevFor)) .and. nCkPerg1 == 1 // Chassi/Fornecedor
		aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
		oLbLevPesq:nAt := 1
		oLbLevPesq:SetArray(aLevPesq)
		oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
		aLevPesq[oLbLevPesq:nAt,03],;
		Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
		aLevPesq[oLbLevPesq:nAt,05],;
		FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
		aLevPesq[oLbLevPesq:nAt,07] }}
		oLbLevPesq:SetFocus()
		oLbLevPesq:Refresh()
		if lInverte
			cTmpStr := cLevFor
			cLevFor := cLevCli
			cLevCli := cTmpStr
		endif
		Return()
	EndIf
Else
	If (Empty(cLevChas) .and. Empty(cLevCli)) .and. nCkPerg1 == 1 // Chassi/Fornecedor
		aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
		oLbLevPesq:nAt := 1
		oLbLevPesq:SetArray(aLevPesq)
		oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
		aLevPesq[oLbLevPesq:nAt,03],;
		Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
		aLevPesq[oLbLevPesq:nAt,05],;
		FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
		aLevPesq[oLbLevPesq:nAt,07] }}
		oLbLevPesq:SetFocus()
		oLbLevPesq:Refresh()
		if lInverte
			cTmpStr := cLevFor
			cLevFor := cLevCli
			cLevCli := cTmpStr
		endif
		Return()
	EndIf
Endif
aLevPesq := {}
If _cTipo == "E" // Entrada
	If nCkPerg1 == 4 // 1=Chassi/Fornecedor, 2=Status/Periodo, 3=NF/Serie, 4=Pedido
		If !Empty(cLevPedFab)
			cQuery := "SELECT VV1_CHASSI"
			cQuery += " FROM " + RetSqlName("VV1") + " VV1"
			cQuery += " WHERE VV1.D_E_L_E_T_ = ' ' AND "

			cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
			If len(cFilLibs) > 1
				nFilVV1Sem := Len(AllTrim(FWxFilial("VV1"))) // Tamanho da filial sem os espaços
				nFilVV1Com := Len(xFilial("VV1"))            // Tamanho da filial com os espaços
				cQuery += "VV1.VV1_FILIAL IN ("
				While len(cFilLibs) > 1
					If cFWCodEmp == left(cFilLibs,2) // Código da empresa logada
						If !("'" + PadR( substr(cFilLibs,3,nFilVV1Sem), nFilVV1Com) + "'," $ cQuery)
							cQuery += "'" + PadR( substr(cFilLibs,3,nFilVV1Sem), nFilVV1Com) + "',"
						EndIf
					EndIf
					cFilLibs := substr(cFilLibs,nFilVV1Com+4)
				EndDo
				cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
			EndIf

			cQuery += " VV1_PEDFAB = '" + cLevPedFab + "'"

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliPedFab, .F., .T. )

			cChaPedFab := "" // Chassi do Pedido
			While (cAliPedFab)->(!Eof())
				cChaPedFab += If(Empty(cChaPedFab), "", ",") + "'" + (cAliPedFab)->VV1_CHASSI + "'"
				(cAliPedFab)->(dbSkip())
			End
			(cAliPedFab)->(dbCloseArea())
		EndIf
	EndIf
	cQuery := "SELECT VVF.VVF_TRACPA , VVF.VVF_SITNFI , VVF.VVF_OPEMOV , VVF.VVF_FILIAL , VVF.VVF_DATMOV , VVF.VVF_NUMNFI , VVF.VVF_SERNFI, VVF." + FGX_MILSNF("VVF", 3, "VVF_SERNFI") + "  , VVF.VVF_VALMOV , VVF.VVF_CODFOR , VVF.VVF_LOJA FROM "+RetSqlName("VVF")+" VVF , "+RetSqlName("VVG")+" VVG WHERE "
	cQuery += "VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND "
	If nCkPerg1 == 1 // Chassi/Fornecedor
		if !Empty(cLevChas)
			cQuery += "VVG.VVG_CHASSI='"+cLevChas+"' AND "
		Endif
		if !Empty(cLevFor)
			cQuery += "VVF.VVF_CODFOR = '"+cLevFor+"' AND VVF.VVF_LOJA = '"+cLevLj+"' AND "
		Endif
	ElseIf nCkPerg1 == 2 // Status/Periodo
		If !Empty(cComboStat)
			cQuery += "VVF.VVF_SITNFI='"+left(cComboStat,1)+"' AND "
		EndIf
		If Empty(dDtFinAte) .or. dDtIniAte > dDtFinAte
			dDtFinAte := dDtIniAte
			oDtFinAte:Refresh()
		EndIf
		cQuery += "VVF.VVF_DATMOV>='"+dtos(dDtIniAte)+"' AND VVF.VVF_DATMOV<='"+dtos(dDtFinAte)+"' AND "
	ElseIf nCkPerg1 == 4 // 1=Chassi/Fornecedor, 2=Status/Periodo, 3=NF/Serie, 4=Pedido
		If !Empty(cChaPedFab) // Chassi do Pedido
			cQuery += "VVG.VVG_CHASSI IN (" + cChaPedFab + ") AND "
		EndIf
	Else//If nCkPerg1 == 3 // NF/Serie
		cQuery += "VVF.VVF_NUMNFI='"+cNroNFI+"' AND VVF.VVF_SERNFI='"+cSerNFI+"' AND "
	EndIf
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VVF.VVF_FILIAL IN ("
		While len(cFilLibs) > 1
			If cFWCodEmp == left(cFilLibs,2) // Código da empresa logada
				cQuery += "'"+substr(cFilLibs,3,Len(xFilial("VVF")))+"',"
			EndIf
			cFilLibs := substr(cFilLibs,Len(xFilial("VVF"))+4)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VVF.VVF_OPEMOV='"+_cOPEMOV+"' AND "
	If lVVF_TIPMOV
		cQuery += "VVF.VVF_TIPMOV IN (' ','0') AND "
	EndIf
	cQuery += "VVF.D_E_L_E_T_=' ' AND VVG.D_E_L_E_T_=' ' ORDER BY VVF.VVF_DATMOV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If ( cQAlias )->( VVF_OPEMOV ) $ "245"
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + ( cQAlias )->( VVF_CODFOR ) + ( cQAlias )->( VVF_LOJA ) )
			cNome := Alltrim(RetTitle("VV0_CODCLI"))+": "+( cQAlias )->( VVF_CODFOR )+"-"+( cQAlias )->( VVF_LOJA )+" "+left(SA1->A1_NOME,20)
		Else
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + ( cQAlias )->( VVF_CODFOR ) + ( cQAlias )->( VVF_LOJA ) )
			cNome := Alltrim(RetTitle("VVF_CODFOR"))+": "+( cQAlias )->( VVF_CODFOR )+"-"+( cQAlias )->( VVF_LOJA )+" "+left(SA2->A2_NOME,20)
		EndIf
		cEmpAtu := FWFilialName(cEmpAnt,( cQAlias )->( VVF_FILIAL ),1)
		aAdd(aLevPesq,{ ( cQAlias )->( VVF_TRACPA ) , ( cQAlias )->( VVF_SITNFI ) , ( cQAlias )->( VVF_FILIAL )+"-"+cEmpAtu , stod(( cQAlias )->( VVF_DATMOV )) , ( cQAlias )->( VVF_NUMNFI )+"-"+( cQAlias )->&( FGX_MILSNF("VVF", 3, "VVF_SERNFI") ) , ( cQAlias )->( VVF_VALMOV ) , cNome })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Else // _cTipo == "S" // Saida
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_SITNFI , VV0.VV0_OPEMOV , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0."+ FGX_MILSNF("VV0", 3, "VV0_SERNFI") +" , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
	cQuery += "VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND "
	If nCkPerg1 == 1 // Chassi/Cliente
		if !Empty(cLevChas)
			cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND "
		Endif
		if !Empty(cLevCli)
			cQuery += "VV0.VV0_CODCLI = '"+cLevCli+"' AND VV0.VV0_LOJA = '"+cLevLj+"' AND "
		Endif
	ElseIf nCkPerg1 == 2 // Status/Periodo
		If !Empty(cComboStat)
			cQuery += "VV0.VV0_SITNFI='"+left(cComboStat,1)+"' AND "
		EndIf
		If Empty(dDtFinAte) .or. dDtIniAte > dDtFinAte
			dDtFinAte := dDtIniAte
			oDtFinAte:Refresh()
		EndIf
		cQuery += "VV0.VV0_DATMOV>='"+dtos(dDtIniAte)+"' AND VV0.VV0_DATMOV<='"+dtos(dDtFinAte)+"' AND "
	Else//If nCkPerg1 == 3 // NF/Serie
		cQuery += "VV0.VV0_NUMNFI='"+cNroNFI+"' AND VV0.VV0_SERNFI='"+cSerNFI+"' AND "
	EndIf
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				//				cQuery += "'"+substr(cFilLibs,3,2)+"',"
				cQuery += "'"+substr(cFilLibs,3,Len(xFilial("VVF")))+"',"
			EndIf
			//			cFilLibs := substr(cFilLibs,6)
			cFilLibs := substr(cFilLibs,Len(xFilial("VVF"))+4)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VV0.VV0_OPEMOV='"+_cOPEMOV+"' AND "
	If lVV0_TIPMOV
		cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
	EndIf
	cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV , VV0.VV0_NUMTRA "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If ( cQAlias )->( VV0_OPEMOV ) $ "345"
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + ( cQAlias )->( VV0_CODCLI ) + ( cQAlias )->( VV0_LOJA ) )
			cNome := Alltrim(RetTitle("VVF_CODFOR"))+": "+( cQAlias )->( VV0_CODCLI )+"-"+( cQAlias )->( VV0_LOJA )+" "+left(SA2->A2_NOME,20)
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + ( cQAlias )->( VV0_CODCLI ) + ( cQAlias )->( VV0_LOJA ) )
			cNome := Alltrim(RetTitle("VV0_CODCLI"))+": "+( cQAlias )->( VV0_CODCLI )+"-"+( cQAlias )->( VV0_LOJA )+" "+left(SA1->A1_NOME,20)
		EndIf
		cEmpAtu := FWFilialName(cEmpAnt,( cQAlias )->( VV0_FILIAL ),1)
		aAdd(aLevPesq,{ ( cQAlias )->( VV0_NUMTRA ) , ( cQAlias )->( VV0_SITNFI ) , ( cQAlias )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlias )->( VV0_DATMOV )) , ( cQAlias )->( VV0_NUMNFI )+"-"+( cQAlias )->&( FGX_MILSNF("VV0", 3, "VV0_SERNFI") ) , ( cQAlias )->( VV0_VALMOV ) , cNome })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
If len(aLevPesq) <= 0
	If _lMsg
		MsgAlert(STR0013,STR0014) //Nenhum registro encontrado! - Atencao
	EndIf
	If nCkPerg1 == 1 // Chassi/Fornecedor
		cLevChas := left(space(50),len(VV1->VV1_CHASSI))
		if _cTipo == "E"
			cLevFor  := space(TamSx3("VVF_CODFOR")[1])
			cLevLj   := space(TamSx3("VVF_LOJA")[1])
		Else
			cLevCli  := space(TamSx3("VV0_CODCLI")[1])
			cLevLj   := space(TamSx3("VV0_LOJA")[1])
		Endif
	Endif
	aLevPesq := {{"","","",ctod(""),"",0,""}}
	lOk := .f.
EndIf
oLbLevPesq:nAt := 1
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
oLbLevPesq:SetFocus()
oLbLevPesq:Refresh()
If !lOk
	oLevChas:SetFocus()
EndIf
if lInverte
	cTmpStr := cLevFor
	cLevFor := cLevCli
	cLevCli := cTmpStr
endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_COMBOTIPO³ Autor ³  Andre Luis Almeida ³ Data ³ 12/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle/Validacao do ComboBox                             ³±±
±±³          ³ ( 1-Chassi/Cliente | 2-Status/Periodo | 3-NF/Serie )       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBOTIPO(_cTipo,lInverte)
if (_cTipo == "E" .and. !lInverte) .or. (_cTipo == "S" .and. lInverte)
	If Type("oLevFor") == "O"
		oLevFor:lVisible:=.f.
	Endif
Else
	If Type("oLevCli") == "O"
		oLevCli:lVisible:=.f.
	Endif
Endif
oLevChas:lVisible:=.f.
oOK:lVisible:=.f.
oTit1:lVisible:=.f.
oTit2:lVisible:=.f.
oTit3:lVisible:=.f.
oChassi:lVisible:=.f.
if (_cTipo == "E" .and. !lInverte) .or. (_cTipo == "S" .and. lInverte)
	If Type("oFornec") == "O"
		oFornec:lVisible:=.f.
	Endif
	If Type("oLevFor") == "O"
		oLevFor:lVisible:=.f.
	Endif
Else
	If Type("oCliente") == "O"
		oCliente:lVisible:=.f.
	Endif
	If Type("oLevCli") == "O"
		oLevCli:lVisible:=.f.
	Endif
Endif
oLevLj:lVisible:=.f.
oOKNF:lVisible:=.f.
oCoboStat:lVisible:=.f.
oDtIniAte:lVisible:=.f.
oDtFinAte:lVisible:=.f.
oNroNFI:lVisible:=.f.
oSerNFI:lVisible:=.f.
oTitPedFab:lVisible:=.f.
oLevPedFab:lVisible:=.f.
oButPedFab:lVisible:=.f.
If nCkPerg1 == 1 // Chassi/Cliente
	oLevChas:lVisible:=.t.
	if (_cTipo == "E" .and. !lInverte) .or. (_cTipo == "S" .and. lInverte)
		If Type("oFornec") == "O"
			oFornec:lVisible:=.t.
		Endif
		If Type("oLevFor") == "O"
			oLevFor:lVisible:=.t.
		Endif
	Else
		If Type("oCliente") == "O"
			oCliente:lVisible:=.t.
		Endif
		If Type("oLevCli") == "O"
			oLevCli:lVisible:=.t.
		Endif
	Endif
	oChassi:lVisible:=.t.
	//	oFornec:lVisible:=.t.
	oLevLj:lVisible:=.t.
	oOK:lVisible:=.t.
ElseIf nCkPerg1 == 2 // Status/Periodo
	oTit1:lVisible:=.t.
	oTit2:lVisible:=.t.
	oCoboStat:lVisible:=.t.
	oDtIniAte:lVisible:=.t.
	oDtFinAte:lVisible:=.t.
ElseIf nCkPerg1 == 4 // 1=Chassi/Fornecedor, 2=Status/Periodo, 3=NF/Serie, 4=Pedido
	oTitPedFab:lVisible:=.t.
	oLevPedFab:lVisible:=.t.
	oButPedFab:lVisible:=.t.
Else//If nCkPerg1 == 3 // NF/Serie
	oTit3:lVisible:=.t.
	oNroNFI:lVisible:=.t.
	oSerNFI:lVisible:=.t.
	oOKNF:lVisible:=.t.
EndIf
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FSX_POSCPO³ Autor ³  Luis Delorme         ³ Data ³ 27/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta get a partir do SX3 ou de parametros fornecidos      ³±±
±±³          ³ a rotina                                                   ³±±
±±³          ³                                                            ³±±
±±³          ³ _cCpo      - Nome do Campo no SX3 (Se _lDic .f. Nome)      ³±±
±±³          ³ _oObj      - Nome do objeto a ser criado                   ³±±
±±³          ³ _nLin      - Linha inicial do texto [ RetTitle() ]         ³±±
±±³          ³ _nCol      - Coluna inicial do texto [ RetTitle() ]        ³±±
±±³          ³ _nSpc      - Espacamento entre o texto e a get             ³±±
±±³          ³ _cCombo    - Combo customizado                             ³±±
±±³          ³ _texto     - Texto customizado [ RetTitle() ]              ³±±
±±³          ³ _F3        - F3    customizado                             ³±±
±±³          ³ _cValid    - Valid customizado                             ³±±
±±³          ³ _oObjGet   - Objeto do Get                                 ³±±
±±³          ³ _lWhen     - When do campo (Se _lDic .f. When customizado) ³±±
±±³          ³ _lDic      - Usar/Não usar o dicionário SX3                ³±±
±±³          ³ _cCor      - Cor do TSay customizado                       ³±±
±±³          ³ _cPict     - Picture customizada                           ³±±
±±³          ³ _cTam      - Tamanho customizado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FSX_POSCPO(_cCpo,_oObj,_nLin,_nCol,_nSpc,_cCombo,_texto,_F3,_cValid,_cODlg,_oObjGet,_lWhen,_lDic,_cCor,_cPict,_cTam,_lVazio)
Local nCntFor
Local cMaior     := ""
Local aVetCombo  := {}
//
Default _cCombo  := ""
Default _texto   := ""
Default _F3      := ""
Default _cValid  := ""
Default _cODlg   := "oDlg"
Default _oObjGet := ""
Default _lWhen   := .t.
Default _lDic    := .t.
Default _cCor    := CLR_BLACK
Default _cPict   := "@!"
Default _cTam    := 20
Default _lVazio  := .f. // Valida Vazio? Somente para função FSX_VALIDCPO()
//
If _lDic
	// Dicionário SX3
	DbSelectArea("SX3")
	DbSetOrder(2)
	If !DBSeek(_cCpo)
		Return
	Endif
	//
	// Calcula a largura da get
	//
	If !Empty(_cCombo)
		aVetCombo := aClone(&(_cCombo))
		For nCntFor := 1 to Len(aVetCombo)
			If Len(cMaior) < Len(aVetCombo[nCntFor])
				cMaior := aVetCombo[nCntFor]
			EndIf
		Next
		// Tratamento para largura do COMBO
		nLarg := CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,cMaior) + 20
	Else
		nLarg := CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) + 10
	EndIf
	// Escreve o titulo do campo na tela na posicao escolhida
	If Empty(_texto)
		&(_oObj) := TSay():New(_nLin,_nCol,{|| RetTitle(_cCpo) },&(_cODlg),,oFnt3,,,,.t.,IIf(X3Obrigat(SX3->X3_CAMPO),CLR_HBLUE,CLR_BLACK),,_nSpc,8)
	Else
		&(_oObj) := TSay():New(_nLin,_nCol,{|| &("'"+_texto+"'") },&(_cODlg),,oFnt3,,,,.t.,IIf(X3Obrigat(SX3->X3_CAMPO),CLR_HBLUE,CLR_BLACK),,_nSpc,8)
	EndIf
	//
	If Empty(_oObjGet)
		If !Empty(_cCombo) // Combo
			@ _nLin,_nCol + _nSpc COMBOBOX oCombo VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) ITEMS &(_cCombo) SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ((IIf(Empty(SX3->X3_WHEN),.t.,&(SX3->X3_WHEN)) .and. SX3->X3_VISUAL != "V") .AND. INCLUI)
		Else // Get
			If !Empty(_F3)
				@ _nLin - 1,_nCol + _nSpc MSGET &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) F3 &("'"+_F3+"'") PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ( FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI )
			ElseIf !Empty(SX3->X3_F3)
				@ _nLin - 1,_nCol + _nSpc MSGET &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) F3 SX3->X3_F3 PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ( FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI )
			Else
				If SX3->X3_VISUAL == "V"
					@ _nLin - 1,_nCol + _nSpc MSGET &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN .F.
				Else
					@ _nLin - 1,_nCol + _nSpc MSGET &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN (FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI)
				EndIf
			EndIf
		EndIf
	Else
		If !Empty(_cCombo) // Combo
			@ _nLin,_nCol + _nSpc COMBOBOX oCombo VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) ITEMS &(_cCombo) SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ((IIf(Empty(SX3->X3_WHEN),.t.,&(SX3->X3_WHEN)) .and. SX3->X3_VISUAL != "V" .and. &( cValToChar(_lWhen) )) .AND. INCLUI)
		Else // Get
			If !Empty(_F3)
				@ _nLin - 1,_nCol + _nSpc MSGET &(_oObjGet) VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) F3 &("'"+_F3+"'") PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ( FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI )
			ElseIf !Empty(SX3->X3_F3)
				@ _nLin - 1,_nCol + _nSpc MSGET &(_oObjGet) VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) F3 SX3->X3_F3 PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN ( FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI )
			Else
				If SX3->X3_VISUAL == "V"
					@ _nLin - 1,_nCol + _nSpc MSGET &(_oObjGet) VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN .F.
				Else
					@ _nLin - 1,_nCol + _nSpc MSGET &(_oObjGet) VAR &("M->"+_cCpo) VALID FSX_VALIDCPO(_cValid,_lVazio) PICTURE SX3->X3_PICTURE SIZE nLarg,8 PIXEL OF &(_cODlg) WHEN (FSX_WHENCPO(&("'"+_cCpo+"'")) .AND. INCLUI)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	// Sem Dicionário SX3
	// Escreve o titulo do campo na tela na posicao escolhida
	&(_oObj) := TSay():New(_nLin, _nCol, {|| &("'" + _texto + "'") }, &(_cODlg),, oFnt3,,,, .t., _cCor,, _nSpc, 8)
	//
	If Empty(_oObjGet)
		If !Empty(_cCombo) // Combo
			@ _nLin, _nCol + _nSpc COMBOBOX oCombo VAR &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") ITEMS &(_cCombo) SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
		Else // Get
			If !Empty(_F3)
				@ _nLin - 1, _nCol + _nSpc MSGET &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") F3 &("'" + _F3 + "'") PICTURE _cPict SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
			Else
				@ _nLin - 1, _nCol + _nSpc MSGET &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") PICTURE _cPict SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
			EndIf
		EndIf
	Else
		If !Empty(_cCombo) // Combo
			@ _nLin, _nCol + _nSpc COMBOBOX oCombo VAR &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") ITEMS &(_cCombo) SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
		Else // Get
			If !Empty(_F3)
				@ _nLin - 1, _nCol + _nSpc MSGET &(_oObjGet) VAR &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") F3 &("'" + _F3 + "'") PICTURE _cPict SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
			Else
				@ _nLin - 1, _nCol + _nSpc MSGET &(_oObjGet) VAR &(_cCpo) VALID Iif(!Empty(_cValid), &(_cValid), "") PICTURE _cPict SIZE _cTam,8 PIXEL OF &(_cODlg) WHEN _lWhen
			EndIf
		EndIf
	EndIf
EndIf

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FSX_VALIDCPO³ Autor ³  Luis Delorme       ³ Data ³ 27/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do campo criado na funcao FSX_POSCPO             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FSX_VALIDCPO(_cValid,_lVazio)
Local lRet :=.t.
Local cCampo := ReadVar()

Default _lVazio := .f.
//
if Empty(&cCampo) .And. !(_lVazio)
	return .t.
endif
//
cCampo := Alltrim(Subs(cCampo,4,Len(SX3->X3_CAMPO)))
DBSelectArea("SX3")
DBSetOrder(2)
DBSeek(cCampo)
If !Empty(SX3->X3_VLDUSER)
	lRet := &(SX3->X3_VLDUSER)
EndIf
If lRet .and. !Empty(SX3->X3_VALID)
	lRet := &(SX3->X3_VALID)
EndIf
If lRet .and. !Empty(_cValid)
	lRet := &(_cValid)
EndIf
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FSX_WHENCPO³ Autor ³  Luis Delorme        ³ Data ³ 27/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Entrada de Veiculos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FSX_WHENCPO(cCampo)
Local lRet :=.t.
//
DBSelectArea("SX3")
DBSetOrder(2)
DBSeek(cCampo)
If !Empty(SX3->X3_WHEN)
	lRet := &(SX3->X3_WHEN)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FGX_Formula³ Autor ³ Manoel               ³ Data ³ 31/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Interpreta formula cadastrada no SM4                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_FORMULA(cFormula,nPos,aStru)
Local nRetVal  := 0
Local cForm    := " "
Local cAliasSv := Alias()
Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| FGX_CheckBug(e) } )
//
Private lRet      := .t.
Private nArrayPos := nPos
//
aErrAva := IIf( Type("aErrAva") == "U" , {} , Aclone( aErrAva ) )
//
IIf(Type("cArqPes")== "U",cArqPes := Alias(),.t.)
//
DbSelectArea("VEG")
DbSetOrder(1)
If DbSeek(xfilial("VEG")+cFormula)
	If "FA_LEVVAL"$VEG_FORMUL
		x := 0
	EndIf
	cForm := AllTrim(VEG_FORMUL)
	DbSelectArea(cArqPes)
	BEGIN SEQUENCE
	nRetVal := &cForm
	END SEQUENCE

	If lRet == .f.
		If nArrayPos # Nil
			If Len(aErrAva)==0 .Or. aScan(aErrAva,{|x| x[1] == aStru[nArrayPos,3].and. x[2] == aStru[nArrayPos,4]}) == 0
				aadd(aErrAva,{aStru[nArrayPos,3],aStru[nArrayPos,4],aStru[nArrayPos,5],aStru[nArrayPos,7]})
			EndIf
			nRetVal := 0
		EndIf
	EndIf

Else

	If nArrayPos # Nil
		If aStru[nArrayPos,6] # "0"  // Sintetico
			If Len(aErrAva)==0 .Or. aScan(aErrAva,{|x| x[1] == aStru[nArrayPos,3].and. x[2] == aStru[nArrayPos,4]}) == 0
				aadd(aErrAva,{aStru[nArrayPos,3],aStru[nArrayPos,4],aStru[nArrayPos,5],aStru[nArrayPos,7]})
			EndIf
		EndIf
	EndIf
	nRetVal := 0

EndIf

ErrorBlock(bBlock)

DbSelectArea(cAliasSv)

Return(nRetVal)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FGX_CheckBu³ Autor ³  Andre Luis Almeida  ³ Data ³ 12/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mensagem de Erro da Checagem da Fórmula                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_CheckBug(e,cCodFormul,cDesFormul)
Local lRet := .t.
Local cFormula    := ""
Local cMensagem   := ""
Default cCodFormul := VEG->VEG_CODIGO
Default cDesFormul := VEG->VEG_DESCRI

If e:gencode > 0
	If !Empty(cCodFormul)
		cFormula := cCodFormul + " - " + cDesFormul + CHR(13) + CHR(10)
	EndIf
	cMensagem := cFormula + e:errorstack

	If !Empty(cCodFormul)
		FMX_HELP("FGX_CheckBug", STR0014 + " " + STR0063, cMensagem)
	Else
		FMX_HELP("FGX_CheckBug", STR0014, e:errorstack)
	EndIf

	lRet := .F.
EndIf
Return(lRet)

/*/{Protheus.doc} FGX_VLRSUGV
	Descricao Retorna o Valor Sugerido ATUAL para Venda do Veiculo

	Uso Veiculos
	Parametro _cChaInt = Chassi Interno (carrega automatic demais parametros)
	_cCodMar = Codigo da Marca
	_cModVei = Modelo do Veiculo
	_cSegMod = Segmento do Modelo
	_cCorVei = Cor do Veiculo
	_lMinCom = Utiliza Minimo Comercial como vlr sugerido de venda
	_cCodCli = Codigo do Cliente
	_cLojCli = Loja do Cliente
	_cFabMod = Ano Fabricacao/Modelo
	nRefMoeda = a moeda que você precisa do valor OU 0 caso precise que o programa te retorne a moeda do valor atual, passar por referencia
	nTaxaMoeda = Taxa da Moeda desejada ( Nil ou 0 a rotina pega a taxa padrão do dia )
	Retorno VALOR DE VENDA

	@author Rubens takalashi
	@type function
	@since 29/04/2024
*/
Function FGX_VLRSUGV( _cChaInt , _cCodMar , _cModVei , _cSegMod , _cCorVei , _lMinCom , _cCodCli , _cLojCli , _cFabMod , nRefMoeda , nTaxaMoeda )
Local ni      := 0
Local nTam    := 0
Local cTipCor := "0"
Local nVlrVda := 0
Local nMinCom := 0
Local _cAlias := "SQLVVP"
Local _cQuery := ""
Local cSalvaA := Alias() // Salva ALIAS
Local cOpcFab := ""
Local nVlrOpc := 0
Local nTotOpc := 0
Local lMM     := FGX_MULTMOEDA()
Local lVVW_SOMAVL := ( VVW->(FieldPos("VVW_SOMAVL")) > 0 )
Local lVV1_MOEDA  := ( VV1->(FieldPos("VV1_MOEDA")) > 0 )
Local lVVP_MOEDA  := ( VVP->(FieldPos("VVP_MOEDA")) > 0 )
Local lCalcVlr    := .f.
Local nVlrCor     := 0
Local nOrigMoeda  := 0
Default _cChaInt := ""
Default _cCodMar := ""
Default _cModVei := ""
Default _cSegMod := ""
Default _cCorVei := ""
Default _lMinCom := .t.
Default _cCodCli := ""
Default _cLojCli := ""
Default _cFabMod := ""
Default nRefMoeda := 0
Default nTaxaMoeda := 0

If !lMM // Se não trabalhar com MultMoeda
	nRefMoeda := 1 // Moeda 1
EndIf

If !Empty(_cChaInt) // Levanta os Dados do Veiculo
	_cQuery := ""
	_cQuery += " SELECT VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , "
	_cQuery += "        VV1.VV1_SUGVDA , VV1.VV1_MNVLVD , VV1.VV1_OPCFAB, VV1.VV1_FABMOD "
	if lMM .and. lVV1_MOEDA
		_cQuery += ", VV1.VV1_MOEDA "
	endif
	_cQuery += "   FROM "+RetSqlName("VV1")+" VV1 "
	_cQuery += "  WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"'"
	_cQuery += "    AND VV1.VV1_CHAINT='"+_cChaInt+"'"
	_cQuery += "    AND VV1.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	If !( _cAlias )->( Eof() )
		_cCodMar  := ( _cAlias )->( VV1_CODMAR )
		_cModVei  := ( _cAlias )->( VV1_MODVEI )
		_cSegMod  := ( _cAlias )->( VV1_SEGMOD )
		_cCorVei  := ( _cAlias )->( VV1_CORVEI )
		cOpcFab   := ( _cAlias )->( VV1_OPCFAB )
		_cFabMod  := ( _cAlias )->( VV1_FABMOD )
		nMinCom   := ( _cAlias )->( VV1_MNVLVD )
		lCalcVlr := .f.
		if lMM .and. lVV1_MOEDA .and. (_cAlias)->(VV1_SUGVDA) > 0
			nOrigMoeda := IIf( ( _cAlias )->( VV1_MOEDA ) > 0 , ( _cAlias )->( VV1_MOEDA ) , 1 ) // Moeda de Origem - Default: 1
			If nRefMoeda == 0
				nRefMoeda := nOrigMoeda // Quando não passa a Moeda, a função retorna a Moeda de Origem
			EndIf
			If nRefMoeda <> nOrigMoeda
				lCalcVlr := .t. // Calcula apenas se a Moeda Desejada for diferente da Moeda de Origem
			EndIf
		EndIf
		//
		nVlrVda := (_cAlias)->(VV1_SUGVDA)
		//
		If lCalcVlr
			nVlrVda := FG_MOEDA(nVlrVda   ,; // Valor Base para Calculo
								nOrigMoeda,; // Moeda Origem
								nRefMoeda ,; // Moeda Destino
								nTaxaMoeda,; // Valor Taxa Moeda
								TamSx3("VV1_SUGVDA")[2] ,; // Decimais (tamanho) do Valor a ser retornado
								dDataBase  ) // dDataBase
		EndIf
	EndIf
	( _cAlias )->( dbCloseArea() )

	If nVlrVda <= 0 .and. GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? - Buscar o Valor de Venda do Pacote
		//TODO: adequar moeda dentro do valor do pacote
		nVlrVda := VA2400151_ValorVendaPacote( _cChaInt , "" , "0" ) // Retorna o Valor de Venda do Pacote
	EndIf

EndIf

If nVlrVda <= 0

	_cQuery := "SELECT VVP.VVP_VALTAB, VVP.VVP_VACRPR, VVP.VVP_VACRMT "
	if lMM .and. lVVP_MOEDA
		_cQuery += ", VVP.VVP_MOEDA "
	endif
	_cQuery += "  FROM "+RetSqlName("VVP")+" VVP "
	_cQuery += " WHERE VVP.VVP_FILIAL =  '" + xFilial("VVP") + "' "
	_cQuery += "   AND VVP.VVP_CODMAR = '" + _cCodMar + "' "
	_cQuery += "   AND VVP.VVP_MODVEI = '" + _cModVei + "' "
	_cQuery += "   AND VVP.VVP_SEGMOD = '" + _cSegMod + "' "
	_cQuery += "   AND VVP.VVP_DATPRC <= '" + dtos(dDataBase) + "' "
	_cQuery += "   AND VVP.D_E_L_E_T_ = ' ' "

	If VVP->(ColumnPos("VVP_FABMOD")) > 0 // .AND. !Empty(_cFabMod) // Controle de valor por ano de fabricacao/modelo ...
		_cQuery += " AND (VVP.VVP_FABMOD = ' ' OR VVP.VVP_FABMOD = '" + _cFabMod + "') "
		_cQuery += " ORDER BY VVP.VVP_FABMOD DESC, VVP.VVP_DATPRC DESC"
	Else
		_cQuery += " ORDER BY VVP.VVP_DATPRC DESC"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	If !( _cAlias )->( Eof() )
		lCalcVlr := .f.
		if lMM .and. lVVP_MOEDA
			nOrigMoeda := IIf( ( _cAlias )->( VVP_MOEDA ) > 0 , ( _cAlias )->( VVP_MOEDA ) , 1 ) // Moeda de Origem - Default: 1
			If nRefMoeda == 0
				nRefMoeda := nOrigMoeda // Quando não passa a Moeda, a função retorna a Moeda de Origem
			EndIf
			If nRefMoeda <> nOrigMoeda
				lCalcVlr := .t. // Calcula apenas se a Moeda Desejada for diferente da Moeda de Origem
			EndIf
		EndIf
// Acrescenta valor adicional pelo tipo da cor
		nVlrCor := 0 // cTipCor == "0" // 0=Solida
		cTipCor := FM_SQL("SELECT VVC_TIPCOR FROM "+RetSQLName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR='"+_cCodMar+"' AND VVC.VVC_CORVEI = '"+_cCorVei+"' AND VVC.D_E_L_E_T_ = ' '")
		if cTipCor == "1" // 1=Metalica
			nVlrCor := ( _cAlias )->( VVP_VACRMT )
		elseif cTipCor == "2" // 2=Perolizada
			nVlrCor := ( _cAlias )->( VVP_VACRPR )
		endif
		//
		nVlrVda := ( _cAlias )->( VVP_VALTAB )+nVlrCor
		//
		If lCalcVlr
			nVlrVda := FG_MOEDA(nVlrVda   ,; // Valor Base para Calculo
								nOrigMoeda,; // Moeda Origem
								nRefMoeda ,; // Moeda Destino
								nTaxaMoeda,; // Valor Taxa Moeda
								TamSx3("VVP_VALTAB")[2] ,; // Decimais (tamanho) do Valor a ser retornado
								dDataBase  ) // dDataBase
		EndIf
	EndIf
	( _cAlias )->( dbCloseArea() )
EndIf

If !Empty(cOpcFab) .and. lVVW_SOMAVL
	For ni := 1 to len(cOpcFab)
		nTam := at("/",cOpcFab)
		If nTam > 1
			nTam--
		ElseIf nTam <= 0
			nTam := len(cOpcFab)
		EndIf
		If nTam > 0
			VVW->(DbSetOrder(1))
			VVW->(DbSeek(xFilial("VVW")+_cCodMar+left(cOpcFab,nTam)))
			If VVW->VVW_SOMAVL == "1" // Soma o Opcional no Valor Sugerido de Venda do Veiculo
				VVM->(DbSetOrder(1))
				VVM->(DbSeek(xFilial("VVM")+_cCodMar+_cModVei+_cSegMod+left(cOpcFab,nTam)))
				nVlrOpc := VVM->VVM_VALCON
				If nVlrOpc <= 0
					nVlrOpc := VVM->VVM_VALOPC
				EndIf
				If nVlrOpc <= 0
					nVlrOpc := VVW->VVW_VALOPC
				EndIf
				nTotOpc += nVlrOpc // Soma o Valor do Opcional
			EndIf
			cOpcFab := substr(cOpcFab,nTam+2)
		Else
			Exit
		EndIf
	Next
	nVlrVda += nTotOpc // Soma total dos Opcionais
EndIf
If _lMinCom .and. left(GetNewPar("MV_MINCVDU","0"),1) $ "1/S" // Utiliza Minimo Comercial como Valor Sugerido de Venda
	If nMinCom == 0
		_cQuery := "SELECT VV2.VV2_MNVLVD "+;
			" FROM "+RetSqlName("VV2")+" VV2 "+;
			" WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"'"+;
			  " AND VV2.VV2_CODMAR='"+_cCodMar+"'"+;
			  " AND VV2.VV2_MODVEI='"+_cModVei+"'"+;
			  " AND VV2.VV2_SEGMOD='"+_cSegMod+"'"+;
			  " AND VV2.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
		If !( _cAlias )->( Eof() )
			nMinCom := ( _cAlias )->( VV2_MNVLVD )
		EndIf
		( _cAlias )->( dbCloseArea() )
		If nMinCom == 0
			nMinCom := GetNewPar("MV_MINCVLV",0) // % de Valor de Venda do Minimo Comercial Geral
		EndIf
	EndIf
	nVlrVda := ( nVlrVda * ( ( 100 - nMinCom ) / 100 ) ) // Valor Minimo Comercial (Vlr de Venda - % Minimo Comercial)
EndIf

// PE - ALTERACAO DO VALOR SUGERIDO DE VENDA DE MAQUINAS E VEICULOS
If ExistBlock("PVLRSUGV")
	nVlrVda := ExecBlock("PVLRSUGV",.f.,.f.,{ nVlrVda , _cChaInt , _cCodMar , _cModVei , _cSegMod , _cCorVei , _cCodCli , _cLojCli })
Endif

nRefMoeda := IIf( nRefMoeda > 0 , nRefMoeda , 1 ) // Default Moeda 1

If !Empty(cSalvaA)
	DbSelectArea(cSalvaA)
EndIf
Return(nVlrVda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_USERVL  ºAutor³ Rubens / Andre Luis º Data ³ 04/05/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrica  ³ Verifica permissao do vendedor de acordo com o campo       º±±
±±º          ³ passado como parametro                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFilUser  = Filial do Usuario                              º±±
±±º          ³ cCodUser  = Codigo do Usuario                              º±±
±±º          ³ cCampo    = Campo da tabela VAI a ser pesquisado           º±±
±±º          ³ cOperador = Operador utilizado para comparar o campo       º±±
±±º          ³             Se for "?" retorna o conteudo do campo         º±±
±±º          ³ xConteudo = Conteudo que deve ser o campo                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_USERVL(cFilUser,cCodUser, cCampo, cOperador, xConteudo)
Local xRet        := .f.
Local cExpressao  := ""
Default cFilUser  := xFilial("VAI")
Default cCodUser  := __cUserID
Default cOperador := "=="
VAI->(dbSetOrder(4))
If VAI->(MsSeek( cFilUser + cCodUser ) )
	If VAI->(FieldPos(cCampo)) > 0
		If cOperador == "?" // Retorna o Conteudo do Campo no VAI
			xRet := &("VAI->" + cCampo )
		Else
			cExpressao := "VAI->" + cCampo + " " + cOperador + " "
			If VALTYPE(xConteudo) == "N"
				cExpressao += AllTrim(Str(xConteudo))
			Else
				cExpressao += '"' + xConteudo + '"'
			EndIf
			If &(cExpressao) // Expressao a ser comparada
				xRet := .t.
			EndIf
		EndIf
	EndIf
Else // Nao existe cadastro no VAI
	If cOperador == "?" // Retorna BRANCO por Tipo de Campo
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(cCampo)) // Existe o campo
			Do Case
				Case SX3->X3_TIPO == "C" // Caracter
					xRet := space(SX3->X3_TAMANHO)
				Case SX3->X3_TIPO == "N" // Numerico
					xRet := 0
				Case SX3->X3_TIPO == "D" // Data
					xRet := ctod("")
			EndCase
		EndIf
		SX3->(DbSetOrder(1))
	EndIf
EndIf
Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_CUSVEI º Autor³ Andre Luis Almeida / Rubens ºData³ 27/05/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna o Custo do Veiculo                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Veiculos                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| _cChaInt = Chassi Interno (carrega automatic demais parametros)º±±
±±º         | _cCodMar = Codigo da Marca                                     º±±
±±º         | _cModVei = Modelo do Veiculo                                   º±±
±±º         | _cSegMod = Segmento do Modelo                                  º±±
±±º         | _cCorVei = Cor do Veiculo                                      º±±
±±º         | _dDatAtu = Data para calculo Indice                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ VALOR DE CUSTO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_CUSVEI( _cChaInt , _cCodMar , _cModVei , _cSegMod , _cCorVei , _dDatAtu )
Local cGruVei := FGX_GrupoVeic(_cChaInt) // Grupo do Veiculo
Local cLocVei := ""
Local cCdProd := ""
Local cTipCor := "0"
Local nVlrCus := 0
Local nB2_CM1 := 0
Local _cAlias := "SQLVV1VVP"
Local _cAlAux := "SQLAUX"
Local _cQuery := ""
Local cSalvaA := Alias() // Salva ALIAS
Local nVlrInd := 0
Local nInd    := 1
Local dDatCpa := dDataBase
Local dDatEnt := cTod("")
Local dDatSai := cTod("")
Local _cChassi := ""
Local lDIACAR := ( VVG->(FieldPos("VVG_DIACAR")) <> 0 )
Default _cChaInt := ""
Default _cCodMar := ""
Default _cModVei := ""
Default _cSegMod := ""
Default _cCorVei := ""
Default _dDatAtu := dDataBase
///////////////////////////////////////////
// CUSTO DA ENTRADA DO VEICULO (SB2/VVG) //
///////////////////////////////////////////
If !Empty(_cChaInt) // Levanta os Dados do Veiculo

	_cQuery := "SELECT VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_FILENT , VV1.VV1_TRACPA , "
	_cQuery += "VV1.VV1_CHASSI , VV1.VV1_LOCPAD , VV1.VV1_ESTVEI FROM "+RetSqlName("VV1")+" VV1 "
	_cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT='"+_cChaInt+"' AND VV1.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )

	If !( _cAlias )->( Eof() )

		cLocVei := ( _cAlias )->( VV1_LOCPAD )

		//////////////////////////////////////////////
		// UTILIZAR CUSTO VEICULO DO SB2 ( B2_CM1 ) //
		//////////////////////////////////////////////
		_cQuery := "SELECT SB1.B1_COD , SB1.B1_LOCPAD FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		_cQuery += "SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE='"+_cChaInt+"' AND SB1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlAux , .F., .T. )
		If !( _cAlAux )->( Eof() )
			cCdProd := ( _cAlAux )->( B1_COD ) // Codigo do Produto
			If Empty(cLocVei)
				If ( _cAlias )->( VV1_ESTVEI ) == '1'
					cLocVei := GETMV("MV_LOCVEIU") // Local Padrao Veiculo Usado
				Else
					cLocVei := GETMV("MV_LOCVEIN") // Local Padrao Veiculo Novo
				EndIf
				If Empty(cLocVei)
					cLocVei := ( _cAlAux )->( B1_LOCPAD ) // Local Padrao do Produto
				EndIf
			Endif
		EndIf
		( _cAlAux )->( DbCloseArea() )
		_cQuery := "SELECT SB2.B2_CM1 FROM "+RetSqlName("SB2")+" SB2 WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND "
		_cQuery += "SB2.B2_COD='"+cCdProd+"' AND SB2.B2_LOCAL='"+cLocVei+"' AND SB2.D_E_L_E_T_=' '"
		nB2_CM1 := FM_SQL(_cQuery) // Valor do Custo no SB2 (B2_CM1)
		nVlrCus := nB2_CM1
		//////////////////////////////////////////////

		If nVlrCus <= 0 .and. GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? - Buscar o Valor de Custo do Pacote
			nVlrCus := nB2_CM1 := VA2400141_CustoTotal( _cChaInt , "" ) // Retorna o Valor de Custo + Frete do Pacote
		EndIf

		_cCodMar := ( _cAlias )->( VV1_CODMAR )
		_cModVei := ( _cAlias )->( VV1_MODVEI )
		_cSegMod := ( _cAlias )->( VV1_SEGMOD )
		_cCorVei := ( _cAlias )->( VV1_CORVEI )
		_cChassi := ( _cAlias )->( VV1_CHASSI )

		If lDIACAR // Existe campo VVG_DIACAR
			_cQuery := "SELECT VVG.VVG_CODIND , VVF.VVF_DATEMI , VVG.VVG_DIACAR , VVH.VVH_DIAPGF , VVH.VVH_DIARET , VVH.R_E_C_N_O_ AS RECVVH FROM "+RetSqlName("VVG")+" VVG "
		Else // utilizar VVH_DIACAR como sendo VVG_DIACAR
			_cQuery := "SELECT VVG.VVG_CODIND , VVF.VVF_DATEMI , VVH.VVH_DIACAR AS VVG_DIACAR , VVH.VVH_DIAPGF , VVH.VVH_DIARET , VVH.R_E_C_N_O_ AS RECVVH FROM "+RetSqlName("VVG")+" VVG "
		EndIf
		_cQuery += "JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.D_E_L_E_T_ = ' ' ) "
		_cQuery += "LEFT JOIN "+RetSqlName("VVH")+" VVH ON ( VVH.VVH_FILIAL='"+xFilial("VVH")+"' AND VVH.VVH_CODIND=VVG.VVG_CODIND AND VVH.D_E_L_E_T_ = ' ' ) "
		_cQuery += "WHERE VVG.VVG_FILIAL='"+( _cAlias )->( VV1_FILENT )+"' AND VVG.VVG_TRACPA='"+( _cAlias )->( VV1_TRACPA )+"' AND VVG.VVG_CHAINT='"+_cChaInt+"' AND VVG.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlAux , .F., .T. )
		If !( _cAlAux )->( Eof() )

			If ( _cAlAux )->( RECVVH ) > 0 // Existe registro no VVH

				dDatCpa := stod(( _cAlAux )->( VVF_DATEMI ))

				dDatEnt := dDatCpa+( _cAlAux )->( VVG_DIACAR )
				dDatSai := _dDatAtu+(( _cAlAux )->( VVH_DIAPGF )-( _cAlAux )->( VVH_DIARET ))

				If ( _cAlAux )->( VVG_DIACAR ) < ( _dDatAtu - dDatCpa )

					VVI->(DbSetOrder(1))
					VVI->(DbSeek(xFilial("VVI")+( _cAlAux )->( VVG_CODIND )+dtos(dDatEnt),.t.))
					If VVI->VVI_INDICE == 0
						VVI->(dbSkip(-1))
					Else
						If VVI->VVI_DATIND != dDatEnt
							VVI->(dbSkip(-1))
							If VVI->VVI_CODIND != ( _cAlAux )->( VVG_CODIND )
								VVI->(dbSkip())
							Endif
						Endif
					Endif

					nInd := VVI->VVI_INDICE
					nVlrInd := ( nVlrCus / nInd )

					VVI->(DbSetOrder(1))
					VVI->(DbSeek(xFilial("VVI")+( _cAlAux )->( VVG_CODIND )+dtos(dDatSai),.t.))
					If VVI->VVI_INDICE == 0
						VVI->(dbSkip(-1))
					Else
						If VVI->VVI_DATIND != dDatSai
							VVI->(dbSkip(-1))
							If VVI->VVI_CODIND != ( _cAlAux )->( VVG_CODIND )
								VVI->(dbSkip())
							Endif
						Endif
					Endif

					nInd := VVI->VVI_INDICE
					nVlrCus := ( nVlrInd * nInd )

					If nVlrCus <= 0 // Se custo calculado for menor ou igual a 0, pegar novamente o Custo do VVG

						nVlrCus := nB2_CM1

					EndIf

				EndIf

			EndIf

		EndIf
		( _cAlAux )->( DbCloseArea() )

	EndIf
	( _cAlias )->( DbCloseArea() )

	////////////////////////////////////////
	// CUSTO DO ARQ DE IMPORTACAO ( VIV ) //
	////////////////////////////////////////
	If nVlrCus <= 0 .and. !Empty(_cChassi)
		_cQuery := "SELECT VIV.VIV_TOTNFI FROM "+RetSqlName("VIV")+" VIV WHERE VIV.VIV_FILIAL='"+xFilial("VIV")+"' AND VIV.VIV_CHASSI='"+_cChassi+"' AND VIV.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
		If !( _cAlias )->( Eof() )
			nVlrCus := ( _cAlias )->( VIV_TOTNFI )
		EndIf
		( _cAlias )->( dbCloseArea() )
	EndIf

Else // Nao possui VV1, utilizar a tabela VVP (Aba PRECOS no Cadastro do Modelo do Veiculo )

	////////////////////////////////////////
	// CUSTO DO MODELO DO VEICULO ( VVP ) //
	////////////////////////////////////////
	If nVlrCus <= 0
		_cQuery := "SELECT VVP.VVP_CUSTAB, VVP.VVP_CUCRPR, VVP.VVP_CUCRMT FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+_cCodMar+"' AND VVP.VVP_MODVEI='"+_cModVei+"' AND VVP.VVP_SEGMOD='"+_cSegMod+"' AND VVP.VVP_DATPRC<='"+dtos(dDataBase)+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC DESC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
		If !( _cAlias )->( Eof() )
			nVlrCus := ( _cAlias )->( VVP_CUSTAB )
			// Acrescenta custo adicional pelo tipo da cor
			cTipCor := FM_SQL("SELECT VVC_TIPCOR FROM "+RetSQLName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR='"+_cCodMar+"' AND VVC.VVC_CORVEI = '"+_cCorVei+"' AND VVC.D_E_L_E_T_ = ' '")
			If cTipCor == "1"
				nVlrCus += ( _cAlias )->( VVP_CUCRMT ) // Acrescenta custo para Cor do Modelo Metalica
			ElseIf cTipCor == "2"
				nVlrCus += ( _cAlias )->( VVP_CUCRPR ) // Acrescenta custo para Cor do Modelo Perolizada
			EndIf
		EndIf
		( _cAlias )->( dbCloseArea() )
	EndIf

EndIf
If !Empty(cSalvaA)
	DbSelectArea(cSalvaA)
EndIf
Return(nVlrCus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_CFXVEI º Autor ³ Andre Luis Almeida       º Data ³ 19/01/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna o Custo FIXO do Veiculo                                º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Veiculos                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| _cChaInt = Chassi Interno (carrega automatic demais parametros)º±±
±±º         | _cCodMar = Codigo da Marca                                     º±±
±±º         | _cModVei = Modelo do Veiculo                                   º±±
±±º         | _cFabMod = Ano Fabricacao/Modelo                               º±±
±±º         | _cOpcFab = Opcional de Fabrica do Veiculo                      º±±
±±º         | _cChassi = Chassi do Veiculo                                   º±±
±±º         | _cEstVei = Estado do Veiculo                                   º±±
±±º         | _cGruMod = Grupo do Modelo                                     º±±
±±º         | _dDatCal = Data para calculo Indice                            º±±
±±º         | _nValTot = Valor Total ( Atendimento / Vlr.Veiculo )           º±±
±±º         | _aVetCus = Vetor recebido por referencia p/ retornar os Custos º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ VALOR DE CUSTO FIXO                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_CFXVEI( _cChaInt , _cCodMar , _cModVei , _cFabMod , _cOpcFab , _cChassi , _cEstVei , _cGruMod  , _dDatCal , _nValTot , _aVetCus, _nMoeda )
Local nValor  := 0
Local cOpcSel := ""
Local ni      := 0
Local nVlrCus := 0
Local _cAlias := "SQLVV1VRAVRD"
Local _cQuery := ""
Local cSalvaA := Alias() // Salva ALIAS
Local nMoedaOrig := 1
Local nDecimais := TamSX3("VRA_VALCUS")[2]
Local lMultMoeda  := FGX_MULTMOEDA()

Default _cChaInt := ""
Default _cCodMar := ""
Default _cModVei := ""
Default _cFabMod := ""
Default _cOpcFab := ""
Default _cChassi := ""
Default _cEstVei := ""
Default _cGruMod := ""
Default _dDatCal := dDataBase
Default _nValTot := 0
Default _aVetCus := NIL
Default _nMoeda  := 1

_nMoeda := Iif(_nMoeda == 0, 1, _nMoeda)

If !Empty(_cChaInt) // Levanta os Dados do Veiculo
	_cQuery := "SELECT VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_FABMOD , VV1.VV1_OPCFAB , VV1.VV1_CHASSI , VV1.VV1_ESTVEI , VV2.VV2_GRUMOD FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 WHERE "
	_cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT='"+_cChaInt+"' AND VV1.D_E_L_E_T_ = ' ' AND "
	_cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	If !( _cAlias )->( Eof() )
		_cCodMar := ( _cAlias )->( VV1_CODMAR )
		_cModVei := ( _cAlias )->( VV1_MODVEI )
		_cFabMod := ( _cAlias )->( VV1_FABMOD )
		_cOpcFab := ( _cAlias )->( VV1_OPCFAB )
		_cChassi := ( _cAlias )->( VV1_CHASSI )
		_cEstVei := ( _cAlias )->( VV1_ESTVEI )
		_cGruMod := ( _cAlias )->( VV2_GRUMOD )
	EndIf
	( _cAlias )->( DbCloseArea() )
EndIf
_cQuery := "SELECT VRA.*, VRD.* FROM "+RetSqlName("VRA")+" VRA INNER JOIN "+RetSqlName("VRD")+" VRD ON "
_cQuery += "(VRD.VRD_FILIAL='"+xFilial("VRD")+"' AND VRD.VRD_CODCUS=VRA.VRA_CODCUS AND VRD.D_E_L_E_T_=' ') "
_cQuery += "WHERE VRA.VRA_FILIAL='"+xFilial("VRA")+"' AND ("
_cQuery += "( VRD.VRD_CODMAR='"+_cCodMar+"' AND VRD.VRD_GRUMOD='"+_cGruMod+"' AND VRD.VRD_MODVEI='"+_cModVei+"' ) OR "
_cQuery += "( VRD.VRD_CODMAR='"+_cCodMar+"' AND VRD.VRD_GRUMOD='"+_cGruMod+"' AND VRD.VRD_MODVEI=' ' ) OR "
_cQuery += "( VRD.VRD_CODMAR='"+_cCodMar+"' AND VRD.VRD_GRUMOD=' ' AND VRD.VRD_MODVEI=' ' ) ) AND "
_cQuery += "( VRD.VRD_FABMOD='"+_cFabMod+"' OR VRD.VRD_FABMOD=' ') AND VRA.VRA_ATIVO='1' AND "
_cQuery += "( VRA.VRA_DATINI<='"+dtos(_dDatCal)+"' AND VRA.VRA_DATFIN>='"+dtos(_dDatCal)+"' ) AND "
_cQuery += "( VRD.VRD_ESTVEI='"+_cEstVei+"' OR VRD.VRD_ESTVEI=' ' ) AND VRA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
While !( _cAlias )->( Eof() )
	If !Empty(_cOpcFab)
		For ni := 1 to 5
			cOpcSel := ""
			If !Empty(Substr(( _cAlias )->( VRD_OPCION ),(ni*3+1)-3,3))
				cOpcSel := Substr(( _cAlias )->( VRD_OPCION ),(ni*3+1)-3,3)
				If !( cOpcSel $ _cOpcFab )
					( _cAlias )->( DbSkip() )//desconsidera o veiculo
					Loop
				EndIf
			EndIf
		Next
	EndIf
	//verificar se o veiculo eh uma excessao do custo se for nao adicionar no array.
	DbSelectArea("VRB")
	DbSetOrder(1)
	If DbSeek( xFilial("VRB") + ( _cAlias )->( VRA_CODCUS ) + _cChassi )
		( _cAlias )->( DbSkip() )
		Loop
	EndIf
	If ( _cAlias )->( VRA_PERCUS ) == 0
		nValor := ( _cAlias )->( VRA_VALCUS )
	Else
		nValor := ( _nValTot * ( ( _cAlias )->( VRA_PERCUS ) / 100 ) )
	EndIf

	if lMultMoeda
		nMoedaOrig := Iif(( _cAlias )->( VRA_MOEDA ) == 0, 1, ( _cAlias )->( VRA_MOEDA ))
		If _nMoeda != nMoedaOrig
			nValor := FG_MOEDA( nValor, nMoedaOrig, _nMoeda ,, nDecimais ) // considera a data do sistema na conversao
		EndIf
	endif

	nVlrCus += nValor

	If _aVetCus <> NIL // Retornar o vetor de CUSTO FIXO
		aAdd(_aVetCus,{.t.,( _cAlias )->( VRA_CODCUS ),nValor,( _cAlias )->( VRA_PERCUS ),( _cAlias )->( VRA_DESCRI ) })
	EndIf

	( _cAlias )->( DbSkip() )
EndDo
( _cAlias )->( dbCloseArea() )

If _aVetCus <> NIL // Retornar o vetor de CUSTO FIXO
	If Len(_aVetCus) <= 0
		aAdd(_aVetCus,{.f.," ",0,0," "})
	Endif
	aSort(_aVetCus,,,{|x,y| x[2]<y[2]})
EndIf

If !Empty(cSalvaA)
	DbSelectArea(cSalvaA)
EndIf
Return(nVlrCus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_DRECVEIº Autor ³ Andre Luis Almeida       º Data ³ 19/01/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna o Valor de Despesa ou Receita do Veiculo               º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Veiculos                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| _cChaInt = Chassi Interno                                      º±±
±±º         | _cTipOpe = Tipo ( 0=Despesa / 1=Receita )                      º±±
±±º         | _aVtDRec = Vetor recebido por referencia p/retornar o VVD      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ VALOR DE RECEITA ou DESPESA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_DRECVEI(_cChaInt,_cTipOpe,_aVtDRec,lDadosUltCpa, nMoeda)
Local nVlrDRec := 0
Local _cAlias  := "SQLVV1VVD"
Local _cQAlAux := "SQLAUXILIAR"
Local _cQuery  := ""
Local _cFilEnt := ""
Local _cTraCpa := ""
Local _cSitVei := "0" // Estoque
Local lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local _aMovAux    := {}
Local _cFilUCp    := "" // Filial da Ultima Entrada por Compra
Local _cTraUCp    := "" // Tracpa da Ultima Entrada por Compra
Local _cFilVVD    := "" // Filiais do VVD
Local lMultMoeda  := FGX_MULTMOEDA()

Default _cChaInt  := ""
Default _cTipOpe  := "0"
Default _aVtDRec  := NIL
Default lDadosUltCpa := .f.
Default nMoeda    := 0

If !Empty(_cChaInt) // Levanta os Dados do Veiculo
	_cQuery := "SELECT VV1.VV1_FILENT , VV1.VV1_TRACPA , VV1.VV1_SITVEI , VV1.VV1_CHASSI "
	_cQuery += "  FROM "+RetSqlName("VV1")+" VV1 "
	_cQuery += " WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT='"+_cChaInt+"' AND VV1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	If !( _cAlias )->( Eof() )
		_cFilEnt := ( _cAlias )->( VV1_FILENT )
		_cFilUCp := ( _cAlias )->( VV1_FILENT )
		_cTraCpa := ( _cAlias )->( VV1_TRACPA )
		_cTraUCp := ( _cAlias )->( VV1_TRACPA )
		_cSitVei := ( _cAlias )->( VV1_SITVEI )
		If lDadosUltCpa .and. lVVD_FILUCP
			_aMovAux := FGX_VEIMOVS( ( _cAlias )->( VV1_CHASSI ) , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
			If len(_aMovAux) > 0
				_cFilUCp := _aMovAux[1,2] // Ultima Filial de Entrada por Compra
				_cTraUCp := _aMovAux[1,3] // Ultimo TraCpa de Entrada por Compra
			EndIf
			//
			_cQuery := "SELECT DISTINCT VVD_FILIAL FROM "+RetSqlName("VVD")+" WHERE D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cQAlAux , .F., .T. )
			While !( _cQAlAux )->( Eof() )
				_cFilVVD += "'"+( _cQAlAux )->( VVD_FILIAL )+"',"
				( _cQAlAux )->( dbSkip() )
			EndDo
			( _cQAlAux )->( dbCloseArea() )
			If !Empty(_cFilVVD)
				_cFilVVD := left(_cFilVVD,len(_cFilVVD)-1)
			Else
				_cFilVVD := "'"+xFilial("VVD")+"'"
			EndIf
			//
		EndIf
	EndIf
	( _cAlias )->( dbCloseArea() )
	If !Empty(_cFilEnt) .and. ( !Empty(_cTraCpa) .or. _cSitVei=="8" )
		_cQuery := "SELECT "

		If lMultMoeda .and. VVD->(FieldPos("VVD_VALOR2")) > 0 .and. nMoeda == 2
			_cQuery += " VVD.VVD_VALOR2 AS VVD_VALOR , "
		Else
			_cQuery += " VVD.VVD_VALOR , "
		EndIf

		_cQuery += " VV5.VV5_DESCRI FROM "+RetSqlName("VVD")+" VVD "
		_cQuery += "LEFT JOIN "+RetSqlName("VV5")+" VV5 ON ( VV5.VV5_FILIAL='"+xFilial("VV5")+"' AND VV5.VV5_TIPOPE=VVD.VVD_TIPOPE AND VV5.VV5_CODIGO=VVD.VVD_CODIGO AND VV5.D_E_L_E_T_=' ' ) "
		If lDadosUltCpa .and. lVVD_FILUCP
			_cQuery += " WHERE VVD.VVD_FILIAL IN (" + _cFilVVD + ")"
			_cQuery += "   AND VVD.VVD_FILUCP  = '" + _cFilUCp + "'"
			_cQuery += "   AND VVD.VVD_TRAUCP  = '" + _cTraUCp + "'"
		Else
			If !lVVD_FILENT
				_cQuery += " WHERE VVD.VVD_FILIAL='"+_cFilEnt+"'" // antes do VVD_FILENT
			Else
				_cQuery += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + _cFilEnt + "' ) " // novos registros
				_cQuery += "       OR (VVD.VVD_FILIAL = '" + _cFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
			Endif
			_cQuery += " AND VVD.VVD_TRACPA='"+_cTraCpa+"' "
		EndIf
		_cQuery += " AND VVD.VVD_CHAINT='"+_cChaInt+"' AND VVD.VVD_TIPOPE='"+_cTipOpe+"' AND VVD.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
		While !( _cAlias )->( Eof() )
			nVlrDRec += ( _cAlias )->( VVD_VALOR )
			If _aVtDRec <> NIL // Retornar o vetor de Despesa/Receita
				aAdd(_aVtDRec,{( _cAlias )->( VV5_DESCRI ),( _cAlias )->( VVD_VALOR )})
			EndIf
			( _cAlias )->( DbSkip() )
		EndDo
		( _cAlias )->( dbCloseArea() )
		If _aVtDRec <> NIL // Retornar o vetor de Despesa/Receita
			If Len(_aVtDRec) <= 0
				aAdd(_aVtDRec,{"",0})
			Endif
			aSort(_aVtDRec,,,{|x,y| x[1]<y[1]})
		EndIf
	EndIf
EndIf
Return(nVlrDRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_BONVEI º Autor ³ Andre Luis Almeida       º Data ³ 20/01/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna o Bonus do Veiculo                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Veiculos                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| _cChaInt = Chassi Interno (carrega automatic demais parametros)º±±
±±º    02   | _cCodMar = Codigo da Marca                                     º±±
±±º    03   | _cModVei = Modelo do Veiculo                                   º±±
±±º    04   | _cFabMod = Ano Fabricacao/Modelo                               º±±
±±º    05   | _cOpcFab = Opcional de Fabrica do Veiculo                      º±±
±±º    06   | _cChassi = Chassi do Veiculo                                   º±±
±±º    07   | _cEstVei = Estado do Veiculo                                   º±±
±±º    08   | _cGruMod = Grupo do Modelo                                     º±±
±±º    09   | _dDatEnt = Data para calculo Indice (Entrada)                  º±±
±±º    10   | _cAtend  = Nro do Atendimento                                  º±±
±±º    11   | _aVetBon = Vetor recebido por referencia p/ retornar os Bonus  º±±
±±º    12   | _cIteTra = Item do Atendimento                                 º±±
±±º    13   | _cComVen = 0 = Bonus de Compra / 1 = Bonus de Venda            º±±
±±º    14   | _dDatRef = Data de referencia para levantamento do Bonus       º±±
±±º    15   | _cFilAte = Filial do Atendimento                               º±±
±±º    16   | _lTodBon = Retorna o Valor de TODOS os bonus ?                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ VALOR DO BONUS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_BONVEI( _cChaInt , _cCodMar , _cModVei , _cFabMod , _cOpcFab , _cChassi , _cEstVei , _cGruMod  , _dDatEnt , _cAtend , _aVetBon , _cIteTra , _cComVen , _dDatRef , _cFilAte , _lTodBon )

Local nVlrVZS     := 0
Local nVlrVZTQ    := 0
Local nCustoVEI   := 0
Local cOpcSel     := ""
Local ni          := 0
Local nVlrBon     := 0
Local nPerBon     := 0
Local _cFilEnt    := xFilial("VVF")
Local _cAlias     := "SQLVV1VZQVZT"
Local _cQuery     := ""
Local cSalvaA     := Alias() // Salva ALIAS
Local nRecVZS     := 0
Local lVZS_FILATE := ( VZS->(FieldPos("VZS_FILATE")) > 0 )
Local lVZS_ITETRA := ( VZS->(FieldPos("VZS_ITETRA")) > 0 )
Local lVZQ_CHASSI := ( VZQ->(FieldPos("VZQ_CHASSI")) > 0 )
Local lVZQ_BONPOR := ( VZQ->(FieldPos("VZQ_BONPOR")) > 0 )
Local cObsVZQ     := ""
Local lRotPedido  := ( GetNewPar("MV_MIL0014","0") == "1" ) // Utiliza Rotina Central de Pedido? (0=Não;1=Sim)
Local lExecSQL    := .f.
Local cUF        := ""
Local aFilAtu    := {}
Local nRecSM0    := SM0->(RecNo())
Local cSlvFilAnt := cFilAnt
Default _cChaInt  := ""
Default _cCodMar  := ""
Default _cModVei  := ""
Default _cFabMod  := ""
Default _cOpcFab  := ""
Default _cChassi  := ""
Default _cEstVei  := ""
Default _cGruMod  := ""
Default _dDatEnt  := dDataBase
Default _cAtend   := ""
Default _cFilAte  := ""
Default _aVetBon  := NIL
Default _cIteTra  := ""
Default _cComVen  := ""
Default _dDatRef  := dDataBase
Default _lTodBon  := .f.
If !Empty(_cChaInt) // Levanta os Dados do Veiculo
	_cQuery := "SELECT VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_FABMOD , VV1.VV1_OPCFAB , VV1.VV1_CHASSI , VV1.VV1_ESTVEI , VV1.VV1_FILENT , VV2.VV2_GRUMOD "
	_cQuery += "FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 WHERE "
	_cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT='"+_cChaInt+"' AND VV1.D_E_L_E_T_ = ' ' AND "
	_cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	If !( _cAlias )->( Eof() )
		_cCodMar := ( _cAlias )->( VV1_CODMAR )
		_cModVei := ( _cAlias )->( VV1_MODVEI )
		_cFabMod := ( _cAlias )->( VV1_FABMOD )
		_cOpcFab := ( _cAlias )->( VV1_OPCFAB )
		_cChassi := ( _cAlias )->( VV1_CHASSI )
		_cEstVei := ( _cAlias )->( VV1_ESTVEI )
		_cGruMod := ( _cAlias )->( VV2_GRUMOD )
		_cFilEnt := ( _cAlias )->( VV1_FILENT )
		If _cComVen == "1" // Bonus de Venda
			aAux := FGX_VEIMOVS( _cChassi , "E",  "0" ) // Retorna a ultima Entrada por Compra do Veiculo
			If len(aAux) > 0
				_dDatEnt := ctod(Subs(aAux[1,4],5,2)+"/"+Subs(aAux[1,4],3,2)+"/"+Subs(aAux[1,4],1,2))
				nCustoVEI := FGX_CUSVEI( _cChaInt , , , , , _dDatRef )
			EndIf
		EndIf
	EndIf
	( _cAlias )->( DbCloseArea() )
EndIf
//
If !lRotPedido
	//
	If lVZQ_BONPOR .and. ! empty( _cFilEnt ) // Bonus por ( 1= Geral(Normal) / 2=Por UF )
		cFilAnt := _cFilEnt
		aFilAtu := FWArrFilAtu()
		If SM0_RECNO > 0 .and. aFilAtu[SM0_RECNO] > 0
			DbSelectArea("SM0")
			DbGoTo(aFilAtu[SM0_RECNO])
		EndIf
		cUF := IIf(!Empty(SM0->M0_ESTCOB),SM0->M0_ESTCOB,SM0->M0_ESTENT) // Pegar UF da Filial de Entrada do Veiculo ( VV1_FILENT )
		DbGoTo(nRecSM0)
		cFilAnt := cSlvFilAnt
	EndIf
	//
	_cQuery := "SELECT VZQ.VZQ_CODBON , VZQ.VZQ_OBRIGA , VZQ.VZQ_TIPBON , VZQ.VZQ_DESCRI , VZT.VZT_OPCION , VZQ.VZQ_VALBON , VZQ.VZQ_PERBON , VZT.VZT_VALBON , VZT.VZT_PERBON , VZQ.VZQ_DATINI , VZQ.VZQ_DATFIN "
	If lVZQ_BONPOR
		_cQuery += ", VZQ.VZQ_BONPOR , VZQ.VZQ_VALBUF , VZQ.VZQ_PERBUF , VZT.VZT_VALBUF , VZT.VZT_PERBUF "
	EndIf
	_cQuery += "FROM "+RetSqlName("VZQ")+" VZQ "
	_cQuery += "INNER JOIN "+RetSqlName("VZT")+" VZT ON (VZT.VZT_FILIAL='"+xFilial("VZT")+"' AND VZT.VZT_CODBON=VZQ.VZQ_CODBON AND VZT.D_E_L_E_T_=' ') "
	_cQuery += "WHERE VZQ.VZQ_FILIAL='"+xFilial("VZQ")+	"' AND "
	_cQuery += "VZT.VZT_CODMAR='"+_cCodMar+"' AND VZT.VZT_GRUMOD='"+_cGruMod+"' AND VZT.VZT_MODVEI='"+_cModVei+"' AND "
	_cQuery += "(VZT.VZT_FABMOD='"+_cFabMod+"' OR VZT.VZT_FABMOD=' ') AND "
	If !Empty(_cComVen) // 0 = Bonus de Compra / 1 = Bonus de Venda
		_cQuery += "VZQ.VZQ_COMVEN IN ('"+_cComVen+"',' ') AND "
	EndIf
	If lVZQ_CHASSI
		If !Empty(_cChassi) // Bonus por Chassi
			_cQuery += "(VZQ.VZQ_CHASSI=' ' OR VZQ.VZQ_CHASSI='"+_cChassi+"') AND "
		Else
			_cQuery += "VZQ.VZQ_CHASSI=' ' AND "
		EndIf
	EndIf
	_cQuery += "( "
	_cQuery += "( VZQ.VZQ_DATVER='0' AND VZQ.VZQ_DATINI<='"+dtos(_dDatRef) +"' AND VZQ.VZQ_DATFIN>='"+dtos(_dDatRef) +"' ) OR " // Filtra Venda
	_cQuery += "( VZQ.VZQ_DATVER='1' AND VZQ.VZQ_DINCPA<='"+dtos(_dDatEnt) +"' AND VZQ.VZQ_DFICPA>='"+dtos(_dDatEnt) +"' ) OR " // Filtra Compra
	_cQuery += "( VZQ.VZQ_DATVER='2' AND VZQ.VZQ_DATINI<='"+dtos(_dDatRef) +"' AND VZQ.VZQ_DATFIN>='"+dtos(_dDatRef) +"' AND VZQ.VZQ_DINCPA<='"+dtos(_dDatEnt) +"' AND VZQ.VZQ_DFICPA>='"+dtos(_dDatEnt) +"' ) " // Filtra Venda e Compra
	_cQuery += ") "
	_cQuery += "AND ( VZT.VZT_ESTVEI='"+_cEstVei+"' OR VZT.VZT_ESTVEI=' ' ) AND VZQ.D_E_L_E_T_=' ' ORDER BY VZQ.VZQ_TIPBON"
	lExecSQL := .t.
ElseIf !Empty(_cChaInt)
	_cQuery := "SELECT VQ1.VQ1_CODBON , VZQ.VZQ_CODBON , '0' AS VZQ_OBRIGA , VZQ.VZQ_TIPBON , VZQ.VZQ_DESCRI , VZQ.VZQ_DATINI , VZQ.VZQ_DATFIN , VQ1.VQ1_VLRLIQ "
	_cQuery += "FROM "+RetSqlName("VQ0")+" VQ0 "
	_cQuery += "JOIN "+RetSqlName("VQ1")+" VQ1 ON (VQ1.VQ1_FILIAL=VQ0.VQ0_FILIAL AND VQ1.VQ1_CODIGO=VQ0.VQ0_CODIGO AND VQ1.VQ1_STATUS<>'4' AND VQ1.D_E_L_E_T_=' ') "
	_cQuery += "LEFT JOIN "+RetSqlName("VZQ")+" VZQ ON (VZQ.VZQ_FILIAL='"+xFilial("VZQ")+"' AND VZQ.VZQ_CODBON=VQ1.VQ1_CODBON AND VZQ.D_E_L_E_T_=' ') "
	_cQuery += "WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT='"+_cChaInt+"' AND VQ0.D_E_L_E_T_=' ' "
	_cQuery += "ORDER BY VZQ.VZQ_TIPBON"
	lExecSQL := .t.
EndIf
If lExecSQL
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlias , .F., .T. )
	While !( _cAlias )->( Eof() )
		If !lRotPedido
			If !Empty(_cOpcFab)
				For ni := 1 to 5
					cOpcSel := ""
					If !Empty(Substr(( _cAlias )->( VZT_OPCION ),(ni*3+1)-3,3))
						cOpcSel := Substr(( _cAlias )->( VZT_OPCION ),(ni*3+1)-3,3)
						If !( cOpcSel $ _cOpcFab )
							( _cAlias )->( DbSkip() )//desconsidera o veiculo
							Loop
						EndIf
					EndIf
				Next
			EndIf
			//verificar se o veiculo eh uma excessao do bonus se for nao adicionar no array.
			DbSelectArea("VZR")
			DbSetOrder(1)
			If DbSeek(xFilial("VZR") + ( _cAlias )->( VZQ_CODBON ) + _cChassi )
				( _cAlias )->( DbSkip() )
				Loop
			EndIf
			//
			nVlrVZS := 0
			If !Empty(_cAtend) .and. !Empty(( _cAlias )->( VZQ_CODBON ))
				_cQuery := "SELECT VZS.R_E_C_N_O_ AS RECVZS FROM "+RetSqlName("VZS")+" VZS WHERE "
				_cQuery += "VZS.VZS_FILIAL='"+xFilial("VZS")+"' AND VZS.VZS_CODBON='"+( _cAlias )->( VZQ_CODBON )+"' AND "
				If lVZS_FILATE .and. !Empty(_cFilAte)
					_cQuery += "VZS.VZS_FILATE='"+_cFilAte+"' AND "
				EndIf
				_cQuery += "VZS.VZS_NUMATE='"+_cAtend+"' AND "
				If lVZS_ITETRA .and. !Empty(_cIteTra)
					_cQuery += "VZS.VZS_ITETRA='"+_cIteTra+"' AND "
				EndIf
				_cQuery += "VZS.D_E_L_E_T_ = ' ' "
				nRecVZS := FM_SQL(_cQuery)
				If nRecVZS > 0 // Existe registro no VZS
					DbSelectArea("VZS")
					DbGoTo(nRecVZS)
					nVlrVZS := VZS->VZS_VALBON
				EndIf
			EndIf
			If nVlrVZS == 0
				If !lVZQ_BONPOR .or. ( _cAlias )->( VZQ_BONPOR ) <> "2" // Nao tem Bonus por UF ou se trata de Bonus Normal
					nPerBon  := 0
					nVlrVZTQ := ( _cAlias )->( VZT_VALBON ) // 1o. Valor VZT
					If nVlrVZTQ == 0
						nPerBon := ( _cAlias )->( VZT_PERBON ) // 2o. % VZT
						If nPerBon == 0
							nVlrVZTQ := ( _cAlias )->( VZQ_VALBON ) // 3o. Valor VZQ
							If nVlrVZTQ == 0
								nPerBon := ( _cAlias )->( VZQ_PERBON ) // 4o. % VZQ
				    		EndIf
						EndIf
					EndIf
				Else // Bonus por UF
					nPerBon  := 0
					nVlrVZTQ := FS_BUSCAUF("1",cUF,( _cAlias )->( VZT_VALBUF )) // 1o. Valor VZT
					If nVlrVZTQ == 0
						nPerBon := FS_BUSCAUF("2",cUF,( _cAlias )->( VZT_PERBUF )) // 2o. % VZT
						If nPerBon == 0
							nVlrVZTQ := FS_BUSCAUF("1",cUF,( _cAlias )->( VZQ_VALBUF )) // 3o. Valor VZQ
							If nVlrVZTQ == 0
								nPerBon := FS_BUSCAUF("2",cUF,( _cAlias )->( VZQ_PERBUF )) // 4o. % VZQ
				    		EndIf
						EndIf
					EndIf
				EndIf
				If nPerBon > 0
					If ExistBlock("PEVBABON")
						nCustoVEI := ExecBlock("PEVBABON",.f.,.f.,{( _cAlias )->( VZQ_CODBON ),nCustoVei,_cChassi})
					Endif
					nVlrVZTQ += nPerBon * nCustoVEI / 100
				EndIf
			EndIf
		Else
			nVlrVZTQ := ( _cAlias )->( VQ1_VLRLIQ )
		EndIf
		//
		If nVlrVZS > 0
			nVlrBon += nVlrVZS
		Else
			If _lTodBon .or. ( _cAlias )->( VZQ_OBRIGA ) == "1" // Todos Bonus ou Somente Bonus obrigatorios
				nVlrBon += 	nVlrVZTQ
			EndIf
		EndIf
		//
		If _aVetBon <> NIL // Retornar o vetor de BONUS
			cObsVZQ := Transform(stod(( _cAlias )->( VZQ_DATINI )),"@D")+" "+STR0009+" "+Transform(stod(( _cAlias )->( VZQ_DATFIN )),"@D") // a
			If !Empty(_cAtend) .and. nVlrVZS > 0
				aAdd(_aVetBon,{IIf(( _cAlias )->( VZQ_OBRIGA )=="1","1","2"),( _cAlias )->( VZQ_CODBON ),nVlrVZTQ,( _cAlias )->( VZQ_TIPBON ),( _cAlias )->( VZQ_DESCRI ),nVlrVZS,cObsVZQ})
			ElseIf nVlrVZTQ > 0
				aAdd(_aVetBon,{( _cAlias )->( VZQ_OBRIGA ),IIf(!lRotPedido,( _cAlias )->( VZQ_CODBON ),( _cAlias )->( VQ1_CODBON )),nVlrVZTQ,IIf(!Empty(( _cAlias )->( VZQ_TIPBON )),( _cAlias )->( VZQ_TIPBON ),"3"),( _cAlias )->( VZQ_DESCRI ),IIf(( _cAlias )->( VZQ_OBRIGA )=='1',nVlrVZTQ,0),cObsVZQ})
			EndIf
		EndIf
		( _cAlias )->( DbSkip() )
	EndDo
	( _cAlias )->( dbCloseArea() )
EndIf
If _aVetBon <> NIL // Retornar o vetor de BONUS
	If Len(_aVetBon) <= 0
		aAdd(_aVetBon,{"0"," ",0," "," ",0,""})
	Endif
	aSort(_aVetBon,,,{|x,y| x[4]<y[4]})
EndIf
If !Empty(cSalvaA)
	DbSelectArea(cSalvaA)
EndIf
Return(nVlrBon)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_BUSCAUF³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ BONUS --> Busca na String o Valor ou Percentual por UF      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BUSCAUF(cTp,cUF,cString)
Local nX   := ( AT(cUF,cString) + 2 )
Local nRet := 0
Local nDiv := 0
If nX > 2
	If cTp == "1" // Valor
		nDiv := 100
	ElseIf cTp == "2" // %
		nDiv := 10000
	EndIf
	nRet := (val(substr(cString,nX,7))/nDiv)
EndIf
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_STAVV0 º Autor³ Andre Luis Almeida          ºData³ 01/06/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna o Status do VV0 (Atendimento/Remessa/Transferencia/...)º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Veiculos                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| cNumTra = Nro da Transacao de Saida (VV0_NUMTRA), caso nao for º±±
±±º         | passado o cNumTra sera utilizado o VV0 que esta posicionado.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_STAVV0(cFilVV0,cNumTra)
Local   cRet    := ""
Default cFilVV0 := ""
Default cNumTra := ""
Default cQuery  := ""
Default cQAlias  := "SQLVV0"

cQuery := "SELECT VV0_VDAFUT, VV0_TIPFAT, VV0_OPEMOV FROM "+RetSqlName("VV0")
cQuery += "  WHERE VV0_FILIAL = '" + cFilVV0 + "'"
cQuery += "  AND VV0_NUMTRA = '" + cNumTra + "'"
cQuery += "  AND D_E_L_E_T_ = ' '"

DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)

// If !Empty(cNumTra)
// 	///////////////////////////////////////////////////////////
// 	// Posiciona no VV0 somente qdo for passado a Transacao  //
// 	///////////////////////////////////////////////////////////
// 	VV0->(DbSetOrder(1))
// 	VV0->(DbSeek(cFilVV0+cNumTra))
// EndIf

if ! (cQAlias)->(Eof())
	(cQAlias)->(DbGoTop())
	If (cQAlias)->VV0_VDAFUT == "1"
		///////////////////////////////////////////////////////
		// Venda Futura                                      //
		///////////////////////////////////////////////////////
		cRet := Alltrim(X3CBOXDESC("VV0_OPEMOV","8"))
	Else
		If (cQAlias)->VV0_TIPFAT == "2"
			///////////////////////////////////////////////////////
			// Faturamento Direto                                //
			///////////////////////////////////////////////////////
			cRet := Alltrim(X3CBOXDESC("VV0_TIPFAT","2"))
		Else
			///////////////////////////////////////////////////////
			// Venda / Simulacao / Remessa / Transferencia / ... //
			///////////////////////////////////////////////////////
			cRet := Alltrim(X3CBOXDESC("VV0_OPEMOV",(cQAlias)->VV0_OPEMOV))
			cRet += " ( "+Alltrim(X3CBOXDESC("VV0_TIPFAT",(cQAlias)->VV0_TIPFAT))+" )"
		EndIf
	EndIf
EndIf
DbCloseArea()
DbSelectArea("VV9")
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_SA1SA2º Autor ³ Andre Luis Almeida / Manoel ºData³ 13/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Posiciona/Cria SA2 partindo do SA1                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| cCodCli = Codigo do Cliente                                    º±±
±±º         | cLojCli = Loja do Cliente                                      º±±
±±º         | lCriaSA2 = Cria SA2 ?                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_SA1SA2(cCodCli,cLojCli,lCriaSA2)
Private aCabForn := {}
Default cCodCli  := ""
Default cLojCli  := ""
Default lCriaSA2 := .f.
If !Empty(cCodCli+cLojCli)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
EndIf
If Empty(SA1->A1_CGC)
	If lCriaSA2
		MsgStop(STR0027+CHR(13)+CHR(10)+CHR(13)+CHR(10)+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,STR0014) // CPF/CNPJ do cliente invalido! / Atencao
	EndIf
	Return(.f.)
EndIf
SA2->(DbSetOrder(3))
If !SA2->(DbSeek(xFilial("SA2")+SA1->A1_CGC))
	SA2->(DbSetOrder(1))
	If !lCriaSA2
		Return .f.
	Else
		// Cria Fornecedor
		aAdd(aCabForn,{"A2_FILIAL"  ,xFilial("SA2")    ,Nil})
		aAdd(aCabForn,{"A2_COD"     ,GetSxENum("SA2","A2_COD") ,Nil})
		aAdd(aCabForn,{"A2_LOJA"    ,SA1->A1_LOJA      ,Nil})
		aAdd(aCabForn,{"A2_NOME"    ,SA1->A1_NOME      ,Nil})
		aAdd(aCabForn,{"A2_TIPO"    ,SA1->A1_PESSOA    ,Nil})
		aAdd(aCabForn,{"A2_CGC"     ,SA1->A1_CGC       ,Nil})
		aAdd(aCabForn,{"A2_NREDUZ"  ,SA1->A1_NREDUZ    ,Nil})
		aAdd(aCabForn,{"A2_END"     ,SA1->A1_END       ,Nil})
		aAdd(aCabForn,{"A2_BAIRRO"  ,SA1->A1_BAIRRO    ,Nil})
		aAdd(aCabForn,{"A2_EST"     ,SA1->A1_EST       ,Nil})
		aAdd(aCabForn,{"A2_MUN"     ,SA1->A1_MUN       ,Nil})
		aAdd(aCabForn,{"A2_CEP"     ,SA1->A1_CEP       ,Nil})
		aAdd(aCabForn,{"A2_DDD"     ,SA1->A1_DDD       ,Nil})
		aAdd(aCabForn,{"A2_TEL"     ,SA1->A1_TEL       ,Nil})
		aAdd(aCabForn,{"A2_FAX"     ,SA1->A1_FAX       ,Nil})
		aAdd(aCabForn,{"A2_EMAIL"   ,SA1->A1_EMAIL     ,Nil})
		aAdd(aCabForn,{"A2_ATIVIDA" ,SA1->A1_ATIVIDA   ,Nil})
		aAdd(aCabForn,{"A2_NATUREZ" ,SA1->A1_NATUREZ   ,Nil})
		aAdd(aCabForn,{"A2_SATIV1"  ,SA1->A1_SATIV1    ,Nil})
		aAdd(aCabForn,{"A2_INSCR"   ,SA1->A1_INSCR     ,Nil})
		aAdd(aCabForn,{"A2_ESTADO"  ,SA1->A1_ESTADO    ,Nil})
		aAdd(aCabForn,{"A2_DDI"     ,SA1->A1_DDI       ,Nil})
		aAdd(aCabForn,{"A2_PAIS"    ,SA1->A1_PAIS      ,Nil})
		aAdd(aCabForn,{"A2_INSCRM"  ,SA1->A1_INSCRM    ,Nil})
		aAdd(aCabForn,{"A2_CONTA"   ,SA1->A1_CONTA     ,Nil})
		aAdd(aCabForn,{"A2_HPAGE"   ,SA1->A1_HPAGE     ,Nil})
		aAdd(aCabForn,{"A2_CLIENTE" ,SA1->A1_COD      ,Nil})
		aAdd(aCabForn,{"A2_LOJCLI"  ,SA1->A1_LOJA      ,Nil})
		If cPaisLoc == "BRA"
			aAdd(aCabForn,{"A2_PFISICA" ,SA1->A1_PFISICA   ,Nil})
			aAdd(aCabForn,{"A2_IBGE"    ,SA1->A1_IBGE      ,Nil})
		EndIf

		if ExistBlock("PVEXFSA1")
			ExecBlock("PVEXFSA1",.f.,.f.)
		Endif

		ConfirmSx8()
		lMsErroAuto := .f.
		lMsHelpAuto := .t.
		MSExecAuto({|x,y| MATA020(x)},aCabForn)
		If lMsErroAuto
			MostraErro()
			Return(.f.)
		EndIf
	EndIf
EndIf
SA2->(DbSetOrder(1))
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FGX_VEISIMº Autor ³ Andre Luis Almeida          ºData³ 19/01/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Simulacao de Veiculo                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro| _cChaInt = Chassi Interno do Veiculo                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_VEISIM(_cChaInt)
Local aObjects    := {} , aInfo := {}
Local aSizeAut    := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nLin        := 0
Local ni          := 0
Local aAux        := {}
Local nDiasEst    := 0
Local aQUltMov    := {}
Local cQAlAux     := "SQLAUX"
Local cQuery      := ""
//
Local lExecNovo   := .f.
Local nVlVeicu    := 0
Local nVlImpos    := 0
Local aRet        := {}
Local aParamBox   := {}
Local cTipOpe     := ""
//
Local cFunJEst    := AllTrim(GetNewPar("MV_FUNJEST",""))
Local nVVG_VCNVEI := 0
Local dVVF_DATEMI := dDataBase
Local nMVICMPAD   := SuperGetMV("MV_ICMPAD",,0)
//
Private cCodCli   := ""
Private cLojCli   := ""
Private cCodTES   := ""
//
Private oEdtS     := LoadBitmap( GetResources() , "SHORTCUTEDIT" ) // edita campos
Private oEdtN     := LoadBitmap( GetResources() , "SEMOBJETO" ) // NAO edita campos
//
Private nLinPSug  := 0
Private nLinDesc  := 0
Private nLinVlrV  := 0
Private nLinVImp  := 0
Private nLinVLiq  := 0
Private nLinCusA  := 0
Private nLinLucB  := 0
Private nLinRecO  := 0
Private nLinDesO  := 0
Private nLinLucO  := 0
Private nLinRecF  := 0
Private nLinDesF  := 0
Private nLinResF  := 0
Private nLinDesA  := 0
Private nLinCusF  := 0
Private nLinResE  := 0
Private cGruVei     := FGX_GrupoVeic(_cChaInt) // Grupo do Veiculo

//
Private aVeicDesc := {} // Descricao do veiculo
Private aSimula   := {}
Private cCadastro := ""
Private aRotina   := {{ " " ," " , 0, 1},;	// Pesquisar
					{ " " ," " , 0, 2},;	// Visualizar
					{ " " ," " , 0, 3},;	// Incluir
					{ " " ," " , 0, 4},;	// Alterar
					{ " " ," " , 0, 5} }	// Excluir
Default _cChaInt  := ""
If !Empty(_cChaInt)

	// Carregar variaveis para nao dar erro no OFIOC060 //
	Inclui    := .f.
	Visualiza := .t.
	Altera    := .f.
	//////////////////////////////////////////////////////

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0, 60 , .T. , .F. } )  	// Topo
	AAdd( aObjects, { 0, 00 , .T. , .T. } )  	// ListBox
	AAdd( aObjects, { 0, 10 , .T. , .F. } )  	// Botoes
	// Fator de reducao de 0.80
	For ni := 1 to Len(aSizeAut)
		aSizeAut[ni] := INT(aSizeAut[ni] * 0.80)
	Next
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos  := MsObjSize (aInfo, aObjects,.F.)
    //
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+_cChaInt)
    //
	FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
	//
	DbSelectArea("VVC")
	DbSetOrder(1)
	DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
	//

	// Posiciona corretamente na SB1 dependendo do parametro MV_MIL0010
	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	SB1->(DbSetOrder(1))
    //
	Pergunte("VXA018",.f.)
	//
	cCodCli := MV_PAR03
	cLojCli := MV_PAR04
	//
	nVlImpos := -1
	nVlVeicu := FGX_VLRSUGV( _cChaInt , , , , , .t. , cCodCli , cLojCli )
	//
	If VV1->VV1_ESTVEI == "1" //Usado
   		cTipOpe := MV_PAR02 // Tipo de Operacao de Usados
   		cCodTES := MV_PAR10 // TES default de Usados
	Else // Novo
   		cTipOpe := MV_PAR01 // Tipo de Operacao de Novos
   		cCodTES := MV_PAR09 // TES default de Novos
	EndIf
	//
	bRefresh := { || .t. } 	// Variavel necessaria ao MAFISREF
	aHeader  := {} 			// Variavel necessaria ao MAFISREF
	aCols    := {} 			// Variavel necessaria ao MAFISREF
	//
	AADD(aParamBox,{1,STR0108,cCodCli,"@!",'MV_PAR05 := MaTesInt(2,MV_PAR04,MV_PAR01,MV_PAR02,"C",MV_PAR03)',"SA1",".T.",35,.f.}) // Cliente
	AADD(aParamBox,{1,STR0109,cLojCli,"@!",'MV_PAR05 := MaTesInt(2,MV_PAR04,MV_PAR01,MV_PAR02,"C",MV_PAR03)',"",".T.",15,.f.}) // Loja
	AADD(aParamBox,{1,STR0110,SB1->B1_COD,"@!",'MV_PAR05 := MaTesInt(2,MV_PAR04,MV_PAR01,MV_PAR02,"C",MV_PAR03)',"SB1",".F.",75,.f.}) // Produto
	AADD(aParamBox,{1,STR0111,cTipOpe,"@!",'MV_PAR05 := MaTesInt(2,MV_PAR04,MV_PAR01,MV_PAR02,"C",MV_PAR03)',"DJ",".T.",20,.f.}) // Tipo de Operacao
	AADD(aParamBox,{1,STR0088,cCodTES,"@!",'vazio().or.FG_SEEK("SF4","MV_PAR05",1,.f.)',"SF4",".T.",25,.f.}) // TES
	If ParamBox(aParamBox,STR0040,@aRet,,,,,,,,.f.) // Simulacao do Veiculo
		If !Empty(aRet[1]) .and. !Empty(aRet[2]) .and. !Empty(aRet[3]) .and. !Empty(aRet[5])
			cCodCli := aRet[1]
			cLojCli := aRet[2]
			cTipOpe := aRet[4]
			cCodTes := aRet[5]
        	//
			nVlVeicu := FGX_VLRSUGV( _cChaInt , , , , , .t. , aRet[1] , aRet[2] )
			//
			MaFisIni(aRet[1],aRet[2],'C','N',,MaFisRelImp("VEIXFUNA",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
			N := 1
			MaFisRef("IT_PRODUTO","VX001",aRet[3])
			MaFisRef("IT_QUANT"  ,"VX001",1)
			MaFisRef("IT_PRCUNI" ,"VX001",nVlVeicu)
		  	MaFisRef("IT_VALMERC","VX001",nVlVeicu)
			MaFisRef("IT_TES"    ,"VX001",aRet[5])
			If VV1->VV1_ESTVEI == "1" //Usado
				aQUltMov := FM_VEIMOVS( VV1->VV1_CHASSI , "E"  )
				For ni := 1 to Len(aQUltMov)
					If aQUltMov[ni,5] $ "0.3"
						VVF->(DbSetOrder(1))
						If VVF->(MsSeek(aQUltMov[ni,2]+aQUltMov[ni,3]))
							SD1->(DbSetOrder(1))
							If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+aRet[3]))
								MaFisRef("IT_NFORI","VX001",SD1->D1_DOC)
								MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
								MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
							EndIf
						EndIf
						Exit
					EndIf
				Next
			EndIf
			nVlVeicu := MaFisRet(,"NF_TOTAL")
			nVlImpos := MaFisRet(,"NF_VALIPI")+MaFisRet(,"NF_VALSOL")+MaFisRet(,"NF_VALICM")
			MaFisEnd()
			//
		EndIf
	EndIf
	//
	aAdd(aVeicDesc,{VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD,VVC->VVC_DESCRI,X3CBOXDESC("VV1_COMVEI",VV1->VV1_COMVEI)}) // 1a.Linha
	//
	aAdd(aVeicDesc,{VV1->VV1_CHASSI,Transform(VV1->VV1_FABMOD,VV1->(x3Picture("VV1_FABMOD"))),Transform(VV1->VV1_PLAVEI,VV1->(x3Picture("VV1_PLAVEI")))}) // 2a.Linha
	//
	aAdd(aVeicDesc,{"","",""}) // 3a.Linha
	//
	aAdd(aVeicDesc,{STR0030+": ",STR0031+": ",STR0032+": "}) // 4a.Linha ( Tipo de Aquisição / Custo Gerencial / Custo Corrigido )
	//
	aQUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "E" , "0" )
	If len(aQUltMov) > 0
		nDiasEst    := (dDataBase-aQUltMov[5])
		dVVF_DATEMI := aQUltMov[5]
		cQuery := "SELECT SB2.B2_CM1 "
		cQuery += "FROM "+RetSqlName("SB1")+" SB1 INNER JOIN "+RetSqlName("SB2")+" SB2 ON ( SB2.B2_FILIAL= '"+ aQUltMov[2] +"' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL = '"+VV1->VV1_LOCPAD+"' ) "
		cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE = '"+VV1->VV1_CHAINT+"' "
		cQuery += "AND SB1.D_E_L_E_T_=' ' AND SB2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		if !((cQAlAux)->(eof()))
			nVVG_VCNVEI :=(cQAlAux)->(B2_CM1)
		endif
   		( cQAlAux )->( dbCloseArea() )
	EndIf
	aVeicDesc[3,1] := STR0038+Transform(nDiasEst,"@E 999999999") // Qtde. de dias em Estoque:
	//
    DbSelectArea("VV1")
	aVeicDesc[4,2] += Transform(nVVG_VCNVEI,"@E 9,999,999.99")
	aVeicDesc[4,3] += Transform(FGX_CUSVEI( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_SEGMOD , VV1->VV1_CORVEI , dDataBase ),"@E 9,999,999.99")

	nLin++
	aAdd(aSimula,{"*",space(1)+STR0033,0,0}) // ANALISE FINANCEIRA

	//////////////////////////
	// Preco Sugerido       //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0035,nVlVeicu,nVlVeicu})		// Preco Sugerido
	nLinPSug := nLin
	//////////////////////////
	// Desconto             //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0036,0,0})	 		// Desconto
	nLinDesc := nLin

	//////////////////////////
	// Preco Venda          //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0037,( aSimula[nLinPSug,3] - aSimula[nLinDesc,3] ),0}) 		// Valor de Venda
	nLinVlrV := nLin

	//////////////////////////
	// Impostos             //
	//////////////////////////
	nLin++
	If nVlImpos >= 0
		aAdd(aSimula,{" ",space(5)+STR0068, nVlImpos , nVlImpos }) // Impostos pelo Fiscal
	Else
		aAdd(aSimula,{" ",space(5)+STR0068, ( aSimula[nLinVlrV,3] * ( nMVICMPAD / 100 ) ) , ( aSimula[nLinVlrV,3] * (nMVICMPAD/100) ) }) // Impostos
	EndIf
	nLinVImp := nLin

	//////////////////////////
	// Venda Liquida        //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0069,( aSimula[nLinVlrV,3] - aSimula[nLinVImp,3] ),0}) // Venda Liquida
	nLinVLiq := nLin

	//////////////////////////
	// Custo Aquisicao      //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0070,nVVG_VCNVEI,nVVG_VCNVEI}) // Custo Aquisicao
	nLinCusA := nLin

	//////////////////////////
	// Lucro Bruto          //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0071,( aSimula[nLinVLiq,3] - aSimula[nLinCusA,3] ),0}) // Lucro Bruto
	nLinLucB := nLin

	//////////////////////////
	// Bonus / Receitas     //
	//////////////////////////
	aAux := {}
	nVlr := 0
	FGX_BONVEI( _cChaInt , , , , , , , , dDataBase , , @aAux , "" , "1" , dDataBase , , .f. )
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0072,0,0}) // Receitas Operacionais
	nLinRecO := nLin
	For ni := 1 to len(aAux)
		If aAux[ni,3] > 0
			nVlr += aAux[ni,3]
			nLin++
			aAdd(aSimula,{" ","       - "+STR0073+": "+aAux[ni,2]+" - "+aAux[ni,5],aAux[ni,3],aAux[ni,3]}) // Bonus
		EndIf
	Next
	aSimula[nLinRecO,3] += nVlr
	aSimula[nLinRecO,4] += nVlr
	aAux := {}
	nVlr := FGX_DRECVEI( _cChaInt , "1" , @aAux , .t. ) // 1 = Receitas ( VVD )
	aSimula[nLinRecO,3] += nVlr
	aSimula[nLinRecO,4] += nVlr
	For ni := 1 to len(aAux)
		If aAux[ni,2] > 0
			nLin++
			aAdd(aSimula,{" ","       - "+STR0074+": "+aAux[ni,1],aAux[ni,2],aAux[ni,2]}) // Receitas
		EndIf
	Next

	//////////////////////////
	// Despesas             //
	//////////////////////////
	aAux := {}
	nVlr := FGX_DRECVEI( _cChaInt , "0" , @aAux , .t. ) // 0 = Despesas ( VVD )
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0075,nVlr,nVlr}) // Despesas Operacionais
	nLinDesO := nLin
	For ni := 1 to len(aAux)
		If aAux[ni,2] > 0
			nLin++
			aAdd(aSimula,{" ","       - "+STR0076+": "+aAux[ni,1],aAux[ni,2],aAux[ni,2]}) // Despesas
		EndIf
	Next

	//////////////////////////
	// Lucro Operacional    //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0077,( ( aSimula[nLinLucB,3] + aSimula[nLinRecO,3] ) - aSimula[nLinDesO,3] ),0}) // Lucro Operacional
	nLinLucO := nLin

	//////////////////////////
	// Receita Financeira   //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0078,0,0}) // Receita Financeira
	nLinRecF := nLin

	//////////////////////////
	// Despesa Financeira   //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0079,0,0}) // Despesa Financeira
	nLinDesF := nLin

	//////////////////////////
	// Resultado Financeiro //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(1)+STR0080,( ( aSimula[nLinLucO,3] + aSimula[nLinRecF,3] ) - aSimula[nLinDesF,3] ),0}) // Resultado Financeiro
	nLinResF := nLin

	nLin++
	aAdd(aSimula,{"*","",0,0})
	nLin++
	aAdd(aSimula,{"*",space(1)+STR0034,0,0}) // ANALISE ECONOMICA

	//////////////////////////
	// Despesa Administrat  //
	//////////////////////////
	If VV1->VV1_ESTVEI == "0" // Novos
		nVlr  := GetNewPar("MV_PDSPNOV",0)
	Else // Usados
		nVlr  := GetNewPar("MV_PDSPUSA",0)
	EndIf
	nVlr := (nVlr*aSimula[nLinVlrV,3])/100
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0081,nVlr,0}) // Despesas Administrativas
	nLinDesA := nLin

	//////////////////////////
	// Custo Financeiro Estq//
	//////////////////////////
	If !Empty(cFunJEst) .and. ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
		nVlr := ExecBlock(cFunJEst,.f.,.f.,{ VV1->VV1_TRACPA , VV1->VV1_CHAINT , dVVF_DATEMI , dDataBase , 'V' })
	Else
		nVlr := FG_JurEst( VV1->VV1_TRACPA , VV1->VV1_CHAINT , dVVF_DATEMI , dDataBase , "V" )
	Endif
	nLin++
	aAdd(aSimula,{" ",space(5)+STR0082,nVlr,nVlr}) // Custo Financeiro do Estoque
	nLinCusF := nLin

	//////////////////////////
	// Resultado Economico  //
	//////////////////////////
	nLin++
	aAdd(aSimula,{" ",space(1)+STR0083,( aSimula[nLinResF,3] - ( aSimula[nLinDesA,3] + aSimula[nLinCusF,3] ) ),0}) // Resultado Economico
	nLinResE := nLin

	/////////////////
	FS_VEISIM(1,0) // atualizar variaveis no vetor
	/////////////////

	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))

	ni := ( (aPos[1,4]-005) / 4 ) // Tamanho da Caixa MSGET

	DEFINE MSDIALOG oSimula FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0040 OF oMainWnd PIXEL // Simulacao do Veiculo

	@ aPos[1,1]+001,aPos[1,2]+001 TO aPos[1,3]-001,aPos[1,4] LABEL "" OF oSimula PIXEL

	@ aPos[1,1]+003,aPos[1,2]+003+(ni*0) MSGET oVeic01 VAR (STR0108+": "+cCodCli+"-"+cLojCli+" "+SA1->A1_NOME) SIZE (ni*3),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+003,aPos[1,2]+003+(ni*3) MSGET oVeic02 VAR (STR0088+": "+cCodTES) SIZE (ni*1)-1,08 OF oSimula PIXEL WHEN .f. // TES

	@ aPos[1,1]+014,aPos[1,2]+003+(ni*0) MSGET oVeic11 VAR aVeicDesc[1,1] SIZE (ni*2),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+014,aPos[1,2]+003+(ni*2) MSGET oVeic12 VAR aVeicDesc[1,2] SIZE (ni*1),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+014,aPos[1,2]+003+(ni*3) MSGET oVeic13 VAR aVeicDesc[1,3] SIZE (ni*1)-1,08 OF oSimula PIXEL WHEN .f.

	@ aPos[1,1]+025,aPos[1,2]+003+(ni*0) MSGET oVeic21 VAR aVeicDesc[2,1] SIZE (ni*2),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+025,aPos[1,2]+003+(ni*2) MSGET oVeic22 VAR aVeicDesc[2,2] SIZE (ni*1),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+025,aPos[1,2]+003+(ni*3) MSGET oVeic23 VAR aVeicDesc[2,3] SIZE (ni*1)-1,08 OF oSimula PIXEL WHEN .f.

	@ aPos[1,1]+036,aPos[1,2]+003+(ni*0) MSGET oVeic31 VAR aVeicDesc[3,1] SIZE (ni*2),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+036,aPos[1,2]+003+(ni*2) MSGET oVeic32 VAR aVeicDesc[3,2] SIZE (ni*2)-1,08 OF oSimula PIXEL WHEN .f.

	@ aPos[1,1]+047,aPos[1,2]+003+(ni*0) MSGET oVeic41 VAR aVeicDesc[4,1] SIZE (ni*2),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+047,aPos[1,2]+003+(ni*2) MSGET oVeic42 VAR aVeicDesc[4,2] SIZE (ni*1),08 OF oSimula PIXEL WHEN .f.
	@ aPos[1,1]+047,aPos[1,2]+003+(ni*3) MSGET oVeic43 VAR aVeicDesc[4,3] SIZE (ni*1)-1,08 OF oSimula PIXEL WHEN .f.

	@ aPos[2,1],aPos[2,2]+001 LISTBOX oLBoxSim FIELDS HEADER " ",STR0041,"%",STR0042,"%",STR0046 COLSIZES aPos[2,4]-222,60,35,60,35,10 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1] OF oSimula PIXEL ON DBLCLICK FS_VEISIM(2,oLBoxSim:nAt) // Valores Default / Valores Desejados / Alterar
	oLBoxSim:SetArray(aSimula)
	oLBoxSim:bLine := { || { aSimula[oLBoxSim:nAt,2] ,;
							IIf(aSimula[oLBoxSim:nAt,1]<>"*",FG_AlinVlrs(Transform(aSimula[oLBoxSim:nAt,3],"@E 999,999,999.99")),"") ,;
							IIf(aSimula[oLBoxSim:nAt,1]<>"*",FG_AlinVlrs(Transform((aSimula[oLBoxSim:nAt,3]/aSimula[IIf(oLBoxSim:nAt==nLinDesc,nLinPSug,nLinVlrV),3])*100,"@E 9999.9999")),"") ,;
							IIf(aSimula[oLBoxSim:nAt,1]<>"*",FG_AlinVlrs(Transform(aSimula[oLBoxSim:nAt,4],"@E 999,999,999.99")),"") ,;
							IIf(aSimula[oLBoxSim:nAt,1]<>"*",FG_AlinVlrs(Transform((aSimula[oLBoxSim:nAt,4]/aSimula[IIf(oLBoxSim:nAt==nLinDesc,nLinPSug,nLinVlrV),4])*100,"@E 9999.9999")),"") ,;
							IIf(( oLBoxSim:nAt == nLinDesc .or. oLBoxSim:nAt == nLinVlrV .or. oLBoxSim:nAt == nLinVImp .or. oLBoxSim:nAt == nLinRecF .or. oLBoxSim:nAt == nLinLucB .or. oLBoxSim:nAt == nLinDesF .or. oLBoxSim:nAt == nLinRecO .or. oLBoxSim:nAt == nLinDesO ),oEdtS,oEdtN) }}

	@ aPos[3,1]+000,aPos[3,2]+002 BUTTON oExecNovo PROMPT STR0112 OF oSimula SIZE 80,10 PIXEL ACTION ( lExecNovo := .t. , oSimula:End() ) // Alterar Cliente/TES default
	@ aPos[3,1]+000,aPos[3,4]-245 BUTTON oCVV1 PROMPT STR0084 OF oSimula SIZE 45,10 PIXEL ACTION ( VX002VV1(VV1->VV1_CHAINT) ) // Cad.Veiculo
	@ aPos[3,1]+000,aPos[3,4]-195 BUTTON oOSrv PROMPT STR0085 OF oSimula SIZE 45,10 PIXEL ACTION ( FG_SALDOS("","","",VV1->VV1_CHAINT) ) // OS do Veiculo
	@ aPos[3,1]+000,aPos[3,4]-145 BUTTON oRast PROMPT STR0086 OF oSimula SIZE 45,10 PIXEL ACTION ( VEIVC140(VV1->VV1_CHASSI, VV1->VV1_CHAINT) ) // Rastreamento
	@ aPos[3,1]+000,aPos[3,4]-095 BUTTON oImpr PROMPT STR0064 OF oSimula SIZE 45,10 PIXEL ACTION ( FS_VEISIM(3,0) ) // Imprimir
	@ aPos[3,1]+000,aPos[3,4]-045 BUTTON oSair PROMPT STR0012 OF oSimula SIZE 45,10 PIXEL ACTION ( oSimula:End() )  // SAIR

	ACTIVATE MSDIALOG oSimula CENTER

EndIf
If lExecNovo
	FGX_VEISIM(_cChaInt) // Executar novamente a SIMULACAO
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEISIM  ³ Autor ³  Andre Luis Almeida  ³ Data ³ 12/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simulação de Veículos (totalizar/Duploclique/Impressao)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEISIM(nTp,nLinha)
Local cDesc1   := ""
Local cDesc2   := ""
Local cDesc3   := ""
Local cAlias   := ""
Local ni       := 0
Local nLin     := 60
Local nValor   := 0
Local nVlrVdaM := 0
Default nLinha := 0
If nTp == 1 // Totalizar variaveis no vetor
	If aSimula[nLinDesc,4] > 0
		aSimula[nLinVlrV,4] := ( aSimula[nLinPSug,4] - aSimula[nLinDesc,4] ) // Valor de Venda
	ElseIf aSimula[nLinVlrV,4] == 0
		aSimula[nLinVlrV,4] := aSimula[nLinPSug,4] // Valor de Venda
	EndIf
	//
	If left(GetNewPar("MV_MINCVDU","0"),1) $ "1/S" // Utiliza Minimo Comercial como Valor Sugerido de Venda
		nVlrVdaM := 0
	Else
		nVlrVdaM := VV1->VV1_MNVLVD // % de Valor de Venda do Minimo Comercial
		If nVlrVdaM == 0
			nVlrVdaM := VV2->VV2_MNVLVD // % de Valor de Venda do Minimo Comercial do Modelo do Veiculo
			If nVlrVdaM == 0
				nVlrVdaM := GetNewPar("MV_MINCVLV",0) // % de Valor de Venda do Minimo Comercial Geral
			EndIf
		EndIf
		nVlrVdaM := ( aSimula[nLinPSug,4] * ( nVlrVdaM / 100 ) ) // Valor Minimo Comercial (Vlr de Venda - % Minimo Comercial)
	EndIf
	aVeicDesc[3,2] := STR0039+Transform(nVlrVdaM,"@E 999,999,999,999.99") // Valor do Minimo Comercial:
	aSimula[nLinVLiq,4] := ( aSimula[nLinVlrV,4] - aSimula[nLinVImp,4] ) // Venda Liquida
	aSimula[nLinLucB,4] := ( aSimula[nLinVLiq,4] - aSimula[nLinCusA,4] ) // Lucro Bruto
	aSimula[nLinLucO,4] := ( ( aSimula[nLinLucB,4] + aSimula[nLinRecO,4] ) - aSimula[nLinDesO,4] ) // Lucro Operacional
	aSimula[nLinResF,4] := ( ( aSimula[nLinLucO,4] + aSimula[nLinRecF,4] ) - aSimula[nLinDesF,4] ) // Resultado Financeiro
	If VV1->VV1_ESTVEI == "0" // Novos
		nVlr  := GetNewPar("MV_PDSPNOV",0)
	Else // Usados
		nVlr  := GetNewPar("MV_PDSPUSA",0)
	EndIf
	nVlr := (nVlr*aSimula[nLinVlrV,4])/100
	aSimula[nLinDesA,4] := nVlr // Despesas Administrativas
	aSimula[nLinResE,4] := ( aSimula[nLinResF,4] - ( aSimula[nLinDesA,4] + aSimula[nLinCusF,4] ) )
ElseIf nTp == 2 // DuploClique no ListBox - Alterar valores desejados
	If nLinha > 0 .and. ( ;
		nLinha == nLinDesc .or. ;
		nLinha == nLinVlrV .or. ;
		nLinha == nLinVImp .or. ;
		nLinha == nLinRecF .or. ;
		nLinha == nLinDesF .or. ;
		nLinha == nLinRecO .or. ;
		nLinha == nLinLucB .or. ;
		nLinha == nLinDesO )
		nValor := aSimula[nLinha,04]
		nPerc  := ( aSimula[nLinha,04] / aSimula[IIf(nLinha==nLinDesc,nLinPSug,nLinVlrV),04] ) * 100
		DEFINE MSDIALOG oDigSim FROM 0,0 TO 65,310 TITLE aSimula[nLinha,02] OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
		@ 007,009 SAY Alltrim(aSimula[nLinha,02]) SIZE 060,009 OF oDigSim  PIXEL
		@ 015,009 MSGET oValor VAR nValor PICTURE "@E 999,999,999.99" VALID (nPerc  := ( nValor / IIf( nLinha<>nLinVlrV,aSimula[IIf(nLinha==nLinDesc,nLinPSug,nLinVlrV),04],nValor) ) * 100) SIZE 60,09 OF oDigSim PIXEL
		DEFINE SBUTTON FROM 015,121 TYPE 1 ACTION (oDigSim:End()) ENABLE OF oDigSim
		@ 007,090 SAY "%" SIZE 060,009 OF oDigSim  PIXEL // % Desejado
		@ 015,073 MSGET oPerc VAR nPerc VALID (nValor := ( aSimula[IIf(nLinha==nLinDesc,nLinPSug,nLinVlrV),04] * ( nPerc / 100))) PICTURE "@E 9999.9999" SIZE 35,09 OF oDigSim PIXEL WHEN ( nLinha <> nLinVlrV )
		ACTIVATE MSDIALOG oDigSim CENTER
		aSimula[nLinha,04] := nValor
		If nLinha == nLinVlrV // Valor Venda
			aSimula[nLinDesc,4] := ( aSimula[nLinPSug,4] - aSimula[nLinVlrV,4] ) // Desconto
		EndIf
		If nLinha == nLinLucB // Calculo por lucro bruto (soma lucro desejado com os custos(imposto e aquisicao) menos preco = ao desconto)
			aSimula[nLinDesc, 4] := aSimula[nLinPSug,4] - (aSimula[nLinVImp, 4] + (nValor + (aSimula[nLinCusA,4])))
		EndIf
		If aSimula[nLinDesc,4] < 0
			aSimula[nLinDesc,4] := 0
		EndIf

		If nLinha == nLinDesc // Desconto
			aSimula[nLinVlrV,4] := ( aSimula[nLinPSug,4] - aSimula[nLinDesc,4] ) // Valor Venda
		EndIf
		If nLinha == nLinVlrV .or. nLinha == nLinDesc // Valor Venda ou Desconto
			aSimula[nLinVImp,4] := ( aSimula[nLinVlrV,4] * ( ( aSimula[nLinVImp,3] / aSimula[nLinVlrV,3] ) ) ) // Imposto
		EndIf
		FS_VEISIM(1,0) // Atualizar linhas do ListBox
		oVeic32:Refresh()
		oLBoxSim:Refresh()
	EndIf
ElseIf nTp == 3 // Impressao
	Private aReturn  := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
	Private cTamanho := "M"            // P/M/G
	Private Limite   := 132           // 80/132/220
	Private aOrdem   := {}             // Ordem do Relatorio
	Private cTitulo  := STR0040
	Private cNomeRel := "FGX_VEISIM"
	Private nLastKey := 0
	Private cabec1   := ""
	Private cabec2   := ""
	Private nCaracter:=15
	Private m_Pag    := 1
	cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cAlias)
	Set Printer to &cNomeRel
	Set Printer On
	Set Device  to Printer
	nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
	@ nLin++,00 psay left(" "+STR0108+": "+cCodCli+"-"+cLojCli+" "+SA1->A1_NOME+space(96),96)+" "+left(STR0088+": "+cCodTES+space(35),35)
	nLin++
	For ni := 1 to len(aVeicDesc)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++,00 psay left(" "+aVeicDesc[ni,1]+space(48),48)+" "+left(aVeicDesc[ni,2]+space(47),47)+" "+left(aVeicDesc[ni,3]+space(35),35)
	Next
	nLin++
	@ nLin++,00 psay repl("_",132)
	nLin++
	@ nLin++,05 psay left(space(60),60)+" "+right(space(25)+STR0041,25)+" "+right(space(25)+STR0042,25)
	For ni := 1 to len(aSimula)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		EndIf
		If aSimula[ni,1] <> "*"
			@ nLin++,05 psay left(aSimula[ni,2]+space(60),60)+" "+;
					Transform(aSimula[ni,3],"@E 999,999,999.99")+" "+;
					Transform((aSimula[ni,3]/aSimula[IIf(ni==nLinDesc,nLinPSug,nLinVlrV),3])*100,"@E 9999.9999")+"% "+;
					Transform(aSimula[ni,4],"@E 999,999,999.99")+" "+;
					Transform((aSimula[ni,4]/aSimula[IIf(ni==nLinDesc,nLinPSug,nLinVlrV),4])*100,"@E 9999.9999")+"% "
		Else
			@ nLin++,05 psay left(aSimula[ni,2]+space(60),60)
		EndIf
	Next
	Ms_Flush()
	Set Printer to
	Set Device  to Screen
	If aReturn[5] == 1
		OurSpool( cNomeRel )
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FGX_MSDOC ³ Autor ³ Thiago			    ³ Data ³17/11/2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Amarracao entidades x documentos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Entidade (Alias)                                    ³±±
±±³          ³ ExpN1 -> Registro (RecNo)                                    ³±±
±±³          ³ ExpN2 -> Opcao (nOpc)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_MSDOC( cAlias , nReg , nOpc )

Local aRecAC9      := {}
Local aPosObj      := {}
Local aPosObjMain  := {}
Local aObjects     := {}
Local aSize        := {}
Local aInfo        := {}
Local aGet		   := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aArea        := GetArea()
Local aButtons     := {}
Local aUsButtons   := {}
Local aChave       := {}
Local aButtPE      := {}

Local cCodEnt      := ""
Local cCodDesc     := ""
Local cNomEnt      := ""
Local cEntidade    := ""
Local cUnico       := ""

Local lMTCONHEC   := ExistBlock('MTCONHEC')
Local lGravou      := .F.
Local lTravas      := .T.
Local lVisual      := .T. //( aRotina[ nOpc, 4 ] == 2 )
Local lAchou       := .F.
Local lRetCon      := .T.
Local lRet		   := .T.
Local lRemotLin	   := GetRemoteType() == 2 //Checa se o Remote e Linux

Local nCntFor      := 0
Local nGetCol      := 0
Local nOpcA	       := 0
Local nScan        := 0

Local oDlg
Local oGetD
Local oGet
Local oGet2
Local oScroll, lRetu
Local aRecACB   := {}
Local	cQuery    := ""
Local	cSeek     := ""
Local	cWhile    := ""
Local aNoFields   := {"AC9_ENTIDA","AC9_CODENT"}									      // Campos que nao serao apresentados no aCols
Local bCond       := {|| .T.}														      	// Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1    := {|| FGX_MSVAC9(@aTravas,@aRecAC9,@aRecACB,lTravas,1,nOpc) }	// Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2    := {|| .F. }
Local lVisPE      := lVisual															      // Retornar .T. para considerar o registro e .F. para desconsiderar
Local nSavn       := 0
If !Type("n") == "U"
	nSavn := n
Else
	n := 1
Endif
if !Type("aHeader") == "U"
	aSavaHeader := aClone(aHeader)
Endif
if !Type("aCols") == "U"
	aSavaCols   := aClone(aCols)
Endif


PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE INCLUI     := .F.
PRIVATE oOle
PRIVATE aExclui      := {}

cCadastro := STR0043

AAdd( aButtons, { "PRODUTO", { || MsDocSize( @oScroll, @oOle, aPosObjMain, aPosObj[2], @aHide ) }, STR0021 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada validar o acesso a rotina quando chamada pelo menu |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTVLDACE")
	lRet := ExecBlock("MTVLDACE",.F.,.F.)
	If ValType(lRetCon) <> "L"
		lRet := .T.
	EndIf
	If !lRet
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para bloquear o botão "Banco Conhecimento para alguns usuários |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lMTCONHEC
	lRetCon := ExecBlock('MTCONHEC', .F., .F.)

	If ValType(lRetCon) <> "L"
		lRetCon := .T.
	EndIf

EndIf

If lRetCon
	AAdd( aButtons, { "NORMAS" , { || MsDocCall() }, STR0043, STR0044 } )  // Banco de Conhecimento / Conhec.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MSDOCBUT" )
	If ValType( aUsButtons := ExecBlock( "MSDOCBUT", .F., .F., { cAlias } ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona a entidade                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEntidade := cAlias

dbSelectArea( cEntidade )
MsGoto( nReg )

aEntidade := MsRelation()
AAdd( aEntidade, { "VV1" , { "VV1_CHAINT" }                                     , { || VV1->VV1_CHASSI } } )				// ChaInt/Chassi - Veiculo
AAdd( aEntidade, { "VVF" , { "VVF_NUMNFI" }                                     , { || VVF->VVF_SERNFI } } )				// NF/Serie - Entrada de Veiculos
AAdd( aEntidade, { "SA1" , { "A1_COD","A1_LOJA"}                                , { || SA1->A1_NOME    } } )				// Codigo/Loja/Nome - Cliente
AAdd( aEntidade, { "VV0" , { "VV0_NUMTRA" }                                     , { || VV0->VV0_FILIAL } } )				// Transacao/Filial - Saida de Veiculos
AAdd( aEntidade, { "VC1" , { "VC1_CODCLI","VC1_LOJA","VC1_TIPAGE","VC1_DATAGE"} , { || strzero(VC1->(RecNo()),10)  } } )	// Cliente/Loja/Tp.Agenda/Dt.Agenda/RecVC1 - CEV Agendas
AAdd( aEntidade, { "VO1" , { "VO1_NUMOSV" }                                     , { || VO1->VO1_FILIAL } } )				// Nro.OS/Filial - Ordem de Servico
AAdd( aEntidade, { "ZY6" , { "ZY6_CODCHA" }                                     , { || ZY6->ZY6_FILIAL } } )				// Chamados/Filial - CI
AAdd( aEntidade, { "ZYD" , { "ZYD_CODIGO" }                                     , { || ZYD->ZYD_CODCHA } } )				// Ocorrencias/Acoes/Chamados - CI
AAdd( aEntidade, { "VQ0" , { "VQ0_FILIAL","VQ0_NUMPED" }                        , { || VQ0->VQ0_NUMPED } } )				// Numero do Pedido do Veículo
AAdd( aEntidade, { "VAZ" , { "VAZ_FILIAL","VAZ_CODIGO","VAZ_REVISA" }           , { || VAZ->VAZ_REVISA } } )				// Avaliação de Usados

nScan := AScan( aEntidade, { |x| x[1] == cEntidade } )

lAchou := .F.

If Empty( nScan )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza a chave unica pelo SX2                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FWAliasInDic(cEntidade)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Macro executa a chave unica                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cUnico := FWX2Unico(cEntidade)
		cCodEnt  := &cUnico
		cCodDesc := Substr( AllTrim( cCodEnt ), TamSX3("A1_FILIAL")[1] + 1 )
		lAchou   := .T.

	EndIf

Else

	aChave   := aEntidade[ nScan, 2 ]
	cCodEnt  := MaBuildKey( cEntidade, aChave )

	cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )

	lAchou := .T.

EndIf

If lAchou

	cCodEnt  := PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )

	dbSelectArea("AC9")
	dbSetOrder(2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara variaveis para FillGetDados                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		cQuery += "SELECT AC9.*,AC9.R_E_C_N_O_ AC9RECNO FROM " + RetSqlName( "AC9" ) + " AC9 "
		cQuery += "WHERE "
		cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
		cQuery += "AC9_FILENT='" + xFilial( cEntidade ) + "' AND "
		cQuery += "AC9_ENTIDA='" + cEntidade            + "' AND "
		cQuery += "AC9_CODENT='" + cCodEnt              + "' AND "
		cQuery += "D_E_L_E_T_ = ' ' ORDER BY " + SqlOrder( AC9->( IndexKey() ) )
	#ENDIF
	cSeek  := xFilial( "AC9" ) + cEntidade + xFilial( cEntidade ) + cCodEnt
	cWhile := "AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT"

	SX2->( dbSetOrder( 1 ) )
	SX2->( DbSeek( cEntidade ) )

	cNomEnt := Capital( X2NOME() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do Array do Cabecalho                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("AA2_CODTEC")
	aadd(aGet,{X3Titulo(),SX3->X3_PICTURE,SX3->X3_F3})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,		³
	//³				  cQuery, bMountFile, lInclui )																	³
	//³nOpcx			- Opcao (inclusao, exclusao, etc). 															³
	//³cAlias		- Alias da tabela referente aos itens															³
	//³nOrder		- Ordem do SINDEX																				³
	//³cSeekKey		- Chave de pesquisa																				³
	//³bSeekWhile	- Loop na tabela cAlias																			³
	//³uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar 	³
	//³				  o registro)																					³
	//³aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader							³
	//³aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader							³
	//³lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario	³
	//³cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera      ³
	//³	           parametros cSeekKey e bSeekWhiele) 																³
	//³bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)						³
	//³lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco					³
	//³aHeaderAux	-																								³
	//³aColsAux		-																								³
	//³bAfterCols	- Bloco executado apos inclusao de cada linha no aCols											³
	//³bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AC9")
	dbSetOrder(2)
	dbGoTop()

	FillGetDados(nOpc,"AC9",2,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

	If ( lTravas )

		aSize := MsAdvSize( )

		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T. } )

		aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObjMain := MsObjSize( aInfo, aObjects )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Resolve os objetos lateralmente                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}

		AAdd( aObjects, { 150, 100, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T., .T. } )

		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. , .T. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Resolve os objetos da parte esquerda                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aInfo   := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3], 0, 4, 0, 0 }

		aObjects := {}
		AAdd( aObjects, { 100,  53, .T., .F., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )

		aPosObj2 := MsObjSize( aInfo, aObjects )

		aHide := {}

		If ( type("aRotina") <> "U" ) // Verifica a existencia da variavel aRotina
			lVisual := ( aRotina[ nOpc, 4 ] == 2 )
		Else
			aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
						{ " " ," " , 0, 2},;	// Visualizar
						{ " " ," " , 0, 3},;	// Incluir
						{ " " ," " , 0, 4},;	// Alterar
						{ " " ," " , 0, 5} }	// Excluir
			If Valtype(nOpc) == "N" .and. nOpc > 0 .and. nOpc <= len(aRotina)
				lVisual := ( aRotina[ nOpc, 4 ] == 2 )
			EndIf
		EndIf

		If !lVisual .And. ExistBlock("MSDOCVIS")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ MSDOCVIS - Ponto de Entrada utilizado para somente visualizar o Conhecimento  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lVisual := IIf(ValType(lVisual:=ExecBlock("MSDOCVIS",.F.,.F.))=='L',lVisual,.F.)
		EndIf

		INCLUI  := .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botao do Wizard de inclusao e associacao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lVisual
			AAdd( aButtons, { "MPWIZARD" , { || MsDocWizard( @oGetD ) }, STR0022, STR0023 } ) // "Inclui conhecimento - Wizard", "Wizard"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PE usado para impedir que usuarios não autorizados e com status diferente
		//  de somente "visualiza" possa Excluir o conhecimento.
		// Se a Função retornar .F. o usuario pode incluir, excluir. Se voltar .T.
		// somente pode incluir.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lVisPE	:= lVisual

		If ExistBlock("MSDOCEXC") .AND. lVisual = .F.
			lVisPE := IIf(ValType(lretu:=ExecBlock("MSDOCEXC",.F.,.F.))=='L',lRetu,lVisual)
		EndIf

		If ExistBlock("MTENCBUT")
			aButtPE := ExecBlock("MTENCBUT",.F.,.F.,{aButtons})
			If ValType(aButtPE) == "A"
				aButtons := aButtPE
			EndIf
		EndIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		@ 0, 0 BITMAP oBmp RESOURCE "PROJETOAP" of oDlg SIZE 100,1000 PIXEL

		@ aPosObj2[1,1],aPosObj2[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj2[1,3],aPosObj2[1,4] OF oDlg CENTERED LOWERED

		nGetCol := 40

		@ 004,005 SAY STR0024 SIZE 040,009 OF oPanel  PIXEL // Entidade
		@ 013,005 GET oGet  VAR cNomEnt  SIZE 090,009 OF oPanel PIXEL WHEN .F.

		@ 027,005 SAY STR0025 SIZE 040,009 OF oPanel PIXEL // Identificacao
		@ 036,005 GET oGet2 VAR cCodDesc SIZE aPosObj2[1,3] - 60,009 OF oPanel PIXEL WHEN .F.


	    if n > Len(aCols)
	       n := 1
	    Endif
		oGetd:=MsGetDados():New(aPosObj2[2,1],aPosObj2[2,2],aPosObj2[2,3],aPosObj2[2,4], nOpc,"MsDocLok","AlwaysTrue",,!lVisPE,NIL,NIL,NIL,1000)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A classe scrollbox esta com o size invertido...                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oScroll := TScrollBox():New( oDlg, aPosObj[2,1], aPosObj[2,2], aPosObj[2,4],aPosObj[2,3])

		oOle    := TOleContainer():New( 0, 0, aPosObj2[2,3],aPosObj2[2,4],oScroll, , "" )
		oOle:Hide()

		oScroll:Cargo := 1

		If !lRemotLin
			@ 17.5, aPosObj2[1,3] - 40  BUTTON oButPrev PROMPT "Preview" SIZE 035,012 FONT oDlg:oFont ACTION ( IIf( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), FGX_PREVIEW() ), .T. ) ) OF oPanel PIXEL      //Preview
			@ 34.5, aPosObj2[1,3] - 40  BUTTON oButOpen PROMPT STR0026   SIZE 035,012 FONT oDlg:oFont ACTION ( IIf( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), FGX_DocOpen() ), .T. ) )  OF oPanel PIXEL     //Abrir
		Else
			@ 34.5, aPosObj2[1,3] - 40  BUTTON oButOpen PROMPT STR0026   SIZE 035,012 FONT oDlg:oFont ACTION ( IIf( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), MsDocOpen( @oOle, @aExclui ) ), .T. ) )  OF oPanel PIXEL     //Abrir
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona ao array dos objetos que devem ser escondidos                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aHide, oPanel )
		AAdd( aHide, oGetD  )
		If !lRemotLin
			AAdd( aHide, oButPrev )
		EndIf
		AAdd( aHide, oButOpen )

		n := 1

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IIf(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},, aButtons )

		If ( nOpcA == 1 ) .And. !lVisual
			Begin Transaction
			lGravou := MsDocGrv( cEntidade, cCodEnt, aRecAC9 )
			If ( lGravou )
				EvalTrigger()
				If ( __lSx8 )
					ConfirmSx8()
				EndIf
				If ExistBlock( "MSDOCOK" )
					ExecBlock("MSDOCOK",.F.,.F.,{cAlias, nReg})
				EndIf
			EndIf
			End Transaction
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os temporarios      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( aExclui )
			MsDocExclui( aExclui, .F. )
		EndIf

	EndIf
	If ( __lSx8 )
		RollBackSx8()
	EndIf
	For nCntFor := 1 To Len(aTravas)
		dbSelectArea(aTravas[nCntFor][1])
		dbGoto(aTravas[nCntFor][2])
		MsUnLock()
	Next nCntFor


Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao inclusao, permite a exibicao de mensagens em tela               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso( STR0014, STR0028 + cAlias, { STR0011 } ) 	 // Atencao / Nao existe chave de relacionamento definida para o alias / Ok

EndIf

RestArea( aArea )

If nSavn > 0
 	n := nSavn
Endif
if !Type("aSavaHeader") == "U"
	aHeader := aClone(aSavaHeader)
Endif
if !Type("aSavaCols") == "U"
	aCols   := aClone(aSavaCols)
Endif

Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FGX_MSVAC9³ Autor ³ Thiago                ³ Data ³17/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ AC9, adicionar recno no array aRecAC9 utilizado na gravacao³±±
±±³          ³ cao da tabela AC9 e verificar se conseguiu travar AC9.     ³±±
±±³          ³ Se retornar .T. considera o registro.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com numero dos registros da tabela AC8         ³±±
±±³          ³ExpA2: Array coim registros travados do AC8                 ³±±
±±³          ³ExpL3: .T. se conseguiu travar AC8                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGX_MSVAC9(aTravas,aRecAC9,aRecACB,lTravas,nOper,nOpc)

Local nTipo := IIf(nOper == 1,2,1)
Local lRet := .T.
Local lMsDocFil := Existblock("MSDOCFIL")
Local nRecNoAC9
DEFAULT nOpc 	:= 2

#IFDEF TOP
	nRecNoAC9 := AC9RECNO
	AC9->( dbGoto( nRecNoAC9 ) )
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Acols para exibicao                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2 .AND. nOpc <> 2
	If ( SoftLock("AC9" ) )
		AAdd(aTravas,{ Alias() , RecNo() })
	Else
		lTravas := .F.
	EndIf
EndIf
AAdd(aRecAC9, AC9->( Recno() ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Array de recnos do banco de conhecimento                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	ACB->( dbSetOrder( 1 ) )
	If ACB->( dbSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ ) )
		AAdd( aRecACB, ACB->( RecNo() ) )
	EndIf
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada pata filtro do usuario. Se retornar .T. considera o   ³
//³ registro do AC9, senao pula o registro.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMsDocFil
	lRet := ExecBlock("MSDOCFIL",.F.,.F.,{AC9->(Recno())})
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGX_ALTVEI³ Autor ³  Andre Luis Almeida  ³ Data ³ 23/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para ALTERAR dados do veiculo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipo = "I" -> Incluir Veiculo                             ³±±
±±³          ³       = "A" -> Alterar Veiculo                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_ALTVEI(cTipo)
Local nOk         := 0
Local lAltVV1     := .f.
Local lAltSA1     := .f.
Private aAltCampos:= {"","","","","","","","","","","",""}
Private aSlvCampos:= {"","","","","","","","","","","",""}
Private aMemos    := {{"VV1_OBSMEM","VV1_OBSERV"}}
Private aCampos   := {}
Private aCampoVV1 := {}
Private cCadastro := (STR0029+" - "+IIf(cTipo=="I",STR0045,IIf(cTipo=="A",STR0046,""))) //Cadastro de Veiculos # Incluir # Alterar
Private aRotina   := VXA010003C_menuDef()
Private lSlvAlt   := .f.
Private aRotAuto  := Nil // Utilizado no "A030Altera"
//
DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserId)
If VAI->(ColumnPos("VAI_OFIVV1")) <= 0 .or. VAI->VAI_OFIVV1 $ " /1" // Habilita: se nao existir o Campo ou ele esta em branco (legado) ou o campo esta com conteudo 1=Sim (novos cadastros)
	lAltVV1 := .t.
EndIf
If VAI->(ColumnPos("VAI_OFISA1")) > 0 .and. VAI->VAI_OFISA1 == "1" // Habilita: somente se existir o Campo e esta com conteudo 1=Sim
	lAltSA1 := .t.
EndIf
//
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !EOF() .And. (X3_ARQUIVO == "VV1")
	If X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !x3_campo $ "VV1_NUMTRA/VV1_TRACPA"
		AADD(aCampoVV1,x3_campo)
		wVar := "M->"+x3_campo
		If x3_campo <> "VV1_CHAINT"
			&wVar:= CriaVar(x3_campo)
		Else
			&wVar:= Space(TamSx3("VV1_CHAINT")[1])
		EndIf
	EndIf
	DbSkip()
EndDo
DbSelectArea("VV1")
If cTipo == "I"
	If MsgYesNo(STR0047,STR0014) // Veiculo nao encontrado! Deseja cadastrar o veiculo? / Atencao
		AxInclui("VV1",0,3,aCampoVV1,,,)
	EndIf
ElseIf cTipo == "A"

	if ExistBlock("PEALTVEI") // Ponto de entrada para que o usuario possa customizar tela de alteração dos dados do veiculo.
		ExecBlock("PEALTVEI",.f.,.f.)
	Else
		aAltCampos[01] := VV1->VV1_PLAVEI
		aAltCampos[02] := VV1->VV1_PROATU
		aAltCampos[03] := VV1->VV1_LJPATU

		FS_VALTVEI("0") // carregar dados do cliente
		
		DEFINE MSDIALOG oFGXAltVei TITLE STR0048 From 00,00 to 17,50 of oMainWnd // Alterar Dados do Veiculo
			//
			@ 006,006 TO 113,192 LABEL "" OF oFGXAltVei PIXEL
			//
			@ 116,164 BUTTON oSair   PROMPT STR0012 OF oFGXAltVei SIZE 28,10 PIXEL ACTION (oFGXAltVei:End()) // SAIR
			//
			@ 011,011 SAY STR0049 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Veiculo:
			@ 010,043 MSGET oModVei VAR (Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV1->VV1_MODVEI)+" - "+Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD,"VV2_DESMOD")) PICTURE "@!" SIZE 145,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.

			@ 022,011 SAY STR0050 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Cor:
			@ 021,043 MSGET oCorVei VAR (Alltrim(VV1->VV1_CORVEI)+" - "+Posicione("VVC",1,xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI,"VVC_DESCRI")) PICTURE "@!" SIZE 145,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			
			@ 033,011 SAY STR0015 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Chassi:
			@ 032,043 MSGET oChaVei VAR VV1->VV1_CHASSI PICTURE "@!" SIZE 145,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			
			@ 044,011 SAY STR0051 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Placa:
			@ 043,043 MSGET oPlaVei VAR aAltCampos[01] PICTURE VV1->(x3Picture("VV1_PLAVEI")) SIZE 40,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK
			//
			@ 055,011 SAY STR0052 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Proprietario:
			@ 054,043 MSGET oCodCli VAR aAltCampos[02] PICTURE "@!" SIZE 33,08 F3 "SA1" VALID FS_VALTVEI("1") OF oFGXAltVei PIXEL COLOR CLR_BLACK
			@ 054,076 MSGET oLojCli VAR aAltCampos[03] PICTURE "@!" SIZE 15,08 VALID FS_VALTVEI("2") OF oFGXAltVei PIXEL COLOR CLR_BLACK
			@ 054,091 MSGET oNomCli VAR aAltCampos[04] PICTURE "@!" SIZE 97,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			
			@ 066,011 SAY STR0053 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Endereco:
			@ 065,043 MSGET oEndCli VAR aAltCampos[05] PICTURE "@!" SIZE 120,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			@ 065,163 MSGET oNroCli VAR aAltCampos[06] PICTURE "@!" SIZE 25,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			@ 076,043 MSGET oBaiCli VAR aAltCampos[07] PICTURE "@!" SIZE 108,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			@ 076,151 MSGET oCEPCli VAR aAltCampos[08] PICTURE SA1->(x3Picture("A1_CEP")) SIZE 35,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			@ 087,043 MSGET oMunCli VAR aAltCampos[09] PICTURE "@!" SIZE 120,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			@ 087,163 MSGET oEstCli VAR aAltCampos[10] PICTURE "@!" SIZE 25,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK WHEN .f.
			//
			@ 099,011 SAY STR0054 SIZE 80,08 OF oFGXAltVei PIXEL COLOR CLR_BLUE // Telefone:
			@ 098,043 MSGET oDDDCli VAR aAltCampos[11] PICTURE "@!" SIZE 30,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK
			@ 098,073 MSGET oTelCli VAR aAltCampos[12] PICTURE SA1->(x3Picture("A1_TEL")) SIZE 50,08 OF oFGXAltVei PIXEL COLOR CLR_BLACK
			//
			@ 116,007 BUTTON oSalvar PROMPT STR0056 OF oFGXAltVei SIZE 60,10 PIXEL ACTION IIf(FS_VALTVEI("3"),(nOk:=1,oFGXAltVei:End()),.t.) // Salvar Alteracoes
			@ 116,072 BUTTON oCadVei PROMPT STR0144 OF oFGXAltVei SIZE 41,10 PIXEL ACTION IIf(FS_VALTVEI("3"),(nOk:=2,oFGXAltVei:End()),.t.) WHEN lAltVV1 // Cad.Veiculo
			@ 116,118 BUTTON oCadCli PROMPT STR0145 OF oFGXAltVei SIZE 41,10 PIXEL ACTION IIf(FS_VALTVEI("3"),(nOk:=3,oFGXAltVei:End()),.t.) WHEN lAltSA1 // Cad.Cliente
			//
		ACTIVATE MSDIALOG oFGXAltVei CENTER
		If lSlvAlt // Salvar Alteracoes

			// Primeiro deve atualizar os dados do cliente para transmitir os dados atualizados ao SO
			FS_ATUSA1(aAltCampos)
		
			FS_ATUVV1(aAltCampos)
		
		EndIf
		If nOk == 2 // Cad.Veiculo
			AxAltera("VV1",VV1->(RecNo()),4,aCampoVV1,,,,)
		ElseIf nOk == 3 // Cad.Cliente
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+aAltCampos[2]+aAltCampos[3])
				aMemos := {}
				A030Altera("SA1",SA1->(RecNo()),4)
			EndIf
		EndIf
	Endif
EndIf
If FindFunction("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf
Return(.t.)

/*/{Protheus.doc} FS_ATUVV1
	Atualiza VV1

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Static Function FS_ATUVV1(aAltCampos)

	local oVV1_AtVeiAMov
	local nRecVV1
	local aFldVV1 := {}
	local lAtuProp := .f.

	local lRetMVCAuto

	nRecVV1 := VV1->(Recno())

	if alltrim(VV1->VV1_PLAVEI) == alltrim(aAltCampos[1])
	else
		AADD( aFldVV1, { "VV1_PLAVEI" , alltrim(aAltCampos[1]) } )
	endif

	if alltrim(VV1->VV1_PROATU) == alltrim(aAltCampos[2])
	else
		lAtuProp := .t.
		AADD( aFldVV1 , { "VV1_PROATU" , alltrim(aAltCampos[2]) } )
	endif

	if alltrim(VV1->VV1_LJPATU) == alltrim(aAltCampos[3])
	else
		lAtuProp := .t.
		AADD( aFldVV1 , { "VV1_LJPATU" , alltrim(aAltCampos[3]) } )
	endif

	if lAtuProp .and. VV1->VV1_BLQPRO <> "0"
		AADD( aFldVV1 , { "VV1_BLQPRO" , "0" } ) // 0 = Veiculo NAO bloqueado para prospeccao
	endif

	if len(aFldVV1) == 0
		return .t.
	endif

	oVV1_AtVeiAMov := FWLoadModel( 'VEIA070' )
	lRetMVCAuto := FwMvcRotAuto(oVV1_AtVeiAMov,"VV1",4,{ {"MODEL_VV1",aFldVV1} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
	endif
	oVV1_AtVeiAMov:DeActivate()

	VV1->(dbgoTo(nRecVV1))

Return

/*/{Protheus.doc} FS_ATUSA1
	Atualiza dados da SA1

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Static Function FS_ATUSA1(aAltCampos)

	local oSA1_CRMA980
	local nRecSA1
	local aFldSA1 := {}
	local lRetMVCAuto := .f.


	SA1->(dbSetOrder(1))
	If ! SA1->(DbSeek(xFilial("SA1")+aAltCampos[2]+aAltCampos[3]))
		return .f.
	endif

	if alltrim(SA1->A1_DDD) == alltrim(aAltCampos[11])
	else
		AADD( aFldSA1 , { "A1_DDD" , aAltCampos[11] , NIL } )
	endif

	if alltrim(SA1->A1_TEL) == alltrim(aAltCampos[12])
	else
		AADD( aFldSA1 , { "A1_TEL" , aAltCampos[12] , NIL } )
	endif

	nRecSA1 := SA1->(Recno())

	if len(aFldSA1) == 0
		return .t.
	endif

	oSA1_CRMA980 := FWLoadModel("CRMA980")
	lRetMVCAuto := FwMvcRotAuto(oSA1_CRMA980,"SA1",4,{ {"SA1MASTER",aFldSA1} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
	endif
	oSA1_CRMA980:DeActivate()

	SA1->(dbgoTo(nRecSA1))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALTVEI³ Autor ³  Andre Luis Almeida  ³ Data ³ 28/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes cliente / Carregar dados do cliente             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTp = "0" -> Carregar dados do Cliente                     ³±±
±±³          ³     = "1" -> Valida Codigo do Cliente                      ³±±
±±³          ³     = "2" -> Valida Codigo e Loja do Cliente               ³±±
±±³          ³     = "3" -> Confirma Alteracoes?                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FGX_ALTVEI() - Tela para ALTERAR dados do veiculo          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALTVEI(cTp)
Local lRet := .f.
Local cMsg := ""
If cTp $ "0/1/2"
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+aAltCampos[2]+Alltrim(aAltCampos[3])))
		lRet := .t.
		aAltCampos[3] := SA1->A1_LOJA
	EndIf
	If lRet // Cliente encontrado
		aAltCampos[04] := SA1->A1_NOME
		aAltCampos[05] := SA1->A1_END
		If SA1->(FieldPos("A1_NUMERO")) > 0
			aAltCampos[06] := SA1->A1_NUMERO
		EndIf
		aAltCampos[07] := SA1->A1_BAIRRO
		aAltCampos[08] := SA1->A1_CEP
		aAltCampos[09] := SA1->A1_MUN
		aAltCampos[10] := SA1->A1_EST
		aAltCampos[11] := SA1->A1_DDD
		aAltCampos[12] := SA1->A1_TEL
	Else // Limpar campos do Cliente
		aAltCampos[04] := space(TamSx3("A1_NOME")[1])
		aAltCampos[05] := space(TamSx3("A1_END")[1])
		If SA1->(FieldPos("A1_NUMERO")) > 0
			aAltCampos[06] := space(TamSx3("A1_NUMERO")[1])
		EndIf
		aAltCampos[07] := space(TamSx3("A1_BAIRRO")[1])
		aAltCampos[08] := space(TamSx3("A1_CEP")[1])
		aAltCampos[09] := space(TamSx3("A1_MUN")[1])
		aAltCampos[10] := space(TamSx3("A1_EST")[1])
		aAltCampos[11] := space(TamSx3("A1_DDD")[1])
		aAltCampos[12] := space(TamSx3("A1_TEL")[1])
	EndIf
	If cTp == "0" // carregar dados do cliente ( inicial )
		aSlvCampos := aClone(aAltCampos)
	Else // cTp == "1" .or. cTp == "2" // validacoes ( codigo e loja do cliente )
		oLojCli:Refresh()
		oNomCli:Refresh()
		oEndCli:Refresh()
		oNroCli:Refresh()
		oBaiCli:Refresh()
		oCEPCli:Refresh()
		oMunCli:Refresh()
		oEstCli:Refresh()
		oDDDCli:Refresh()
		oTelCli:Refresh()
	EndIf
Else // If cTp == "3" // Confirma Alteracoes?
	lRet := .t.
	If aAltCampos[01] <> aSlvCampos[01]
		cMsg += CHR(13)+CHR(10)+" - "+STR0057 // Placa do Veiculo
	EndIf
	If aAltCampos[02] <> aSlvCampos[02]
		cMsg += CHR(13)+CHR(10)+" - "+STR0058 // Codigo do Proprietario
	EndIf
	If aAltCampos[03] <> aSlvCampos[03]
		cMsg += CHR(13)+CHR(10)+" - "+STR0059 // Loja do Proprietario
	EndIf
	If aAltCampos[11] <> aSlvCampos[11]
		cMsg += CHR(13)+CHR(10)+" - "+STR0060 // DDD do Telefone do Proprietario
	EndIf
	If aAltCampos[12] <> aSlvCampos[12]
		cMsg += CHR(13)+CHR(10)+" - "+STR0061 // Telefone do Proprietario
	EndIf
	If !Empty(cMsg)
		If MsgYesNo(STR0062+cMsg,STR0014) // Confirma Alteracoes? / Atencao
			lSlvAlt := .t.
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGX_VLDATE ³ Autor ³ Andre Luis Almeida  ³ Data ³ 28/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna .F. qdo se tratar de um orcamento gerado pelo      ³±±
±±³          ³ Atendimento de Veiculos. Caso contrario, retorna .T.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                   Funcao chamada pelo FATA701                         ³±±
±±³                  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                        ³±±
±±³    O retorno da funcao eh utilizado para o FATA701 validar ou nao a   ³±±
±±³    divergencia dos valores das parcelas em relacao ao valor total     ³±±
±±³    do item (veiculo)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cL1_NUM = Nro do Orcamento do Loja / Venda Direta          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_VLDATE(cL1_NUM)
Local lRet      := .t.
Default cL1_NUM := ""
If !Empty(cL1_NUM)
	If FM_SQL("SELECT VV0.R_E_C_N_O_ AS RECVV0 FROM "+RetSQLName("VV0")+" VV0 WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_PESQLJ='"+cL1_NUM+"' AND VV0.D_E_L_E_T_ = ' '") > 0
		lRet := .f. // A funcao retornara .F. quando se tratar de um orcamento gerado pelo Atendimento de Veiculos. Caso contrario, retornara .T.
	EndIf
Else
	If FM_PILHA("VEIXI002LJ") // Funcao de criacao do Orcamento no Venda Direta
		lRet := .f. // A funcao retornara .F. quando se tratar de um orcamento gerado pelo Atendimento de Veiculos.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³
NTº Autor ³ Andre Luis Almeida       º Data ³ 26/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Visualiza aqruivos de Integracoes                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ _cNomArq  = Nome do Arquivo do Layout                          º±±
±±º         ³ _cTitulo  = Titulo do Layout                                   º±±
±±º         ³ _aIntCab  = Cabecalho ( colunas )                              º±±
±±º         ³ _aIntIte  = Itens ( linhas )                                   º±±
±±º         ³ _lAbrXML  = Abre ( .t. / .f. ) o Excel com o XML gerado        º±±
±±º         ³ _aVRetVIS = Vetor passado como referencia para tratamento      º±±
±±º         ³             posterior à seleção dos Itens na rotina de chamada º±±
±±º         ³             desta função                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ³                                                                º±±
±±º Colunas ³ _aIntCab[n,1] = Titulo Coluna                                  º±±
±±º         ³ _aIntCab[n,2] = Tipo ( C-aracter / N-umero / D-ata / L-ogico ) º±±
±±º         ³ _aIntCab[n,3] = Tamanho Coluna ListBox                         º±±
±±º         ³ _aIntCab[n,4] = Mascara / Picture                              º±±
±±º         ³                                                                º±±
±±º Linhas  ³ _aIntIte[n] = vetor com o conteudo das Colunas ( _aIntCab )    º±±
±±º         ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                          º±±
±±º  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    º±±
±±º                                                                          º±±
±±º  aAdd(_aIntCab,{"Marca"     ,"C",20,"@!"               })                º±±
±±º  aAdd(_aIntCab,{"Modelo"    ,"C",60,"@!"               })                º±±
±±º  aAdd(_aIntCab,{"Placa"     ,"C",35,"@R! AAA-9999"     })                º±±
±±º  aAdd(_aIntCab,{"Valor"     ,"N",55,"@E 999,999,999.99"})                º±±
±±º  aAdd(_aIntCab,{"KM"        ,"N",45,"@E 999,999,999"   })                º±±
±±º  aAdd(_aIntCab,{"Dt.Compra" ,"D",35,"@D"               })                º±±
±±º  aAdd(_aIntCab,{"Licenciado","L",10,""                 })                º±±
±±º                                                                          º±±
±±º  aAdd(_aIntIte,{"VW","MOD1","XYX1234",25600,2350,dDataBase,.t.})         º±±
±±º  aAdd(_aIntIte,{"VW","MOD1","XYX1255",25500,7815,dDataBase,.f.})         º±±
±±º  aAdd(_aIntIte,{"GM","MOD2","XYX1233",23500,2550,dDataBase,.f.})         º±±
±±º  aAdd(_aIntIte,{"GM","MOD2","XYX1244",23500,2690,dDataBase,.t.})         º±±
±±º                                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_VISINT(_cNomArq, _cTitulo, _aIntCab, _aIntIte, _lAbrXML, _aVRetVIS)
Local ni          := 0
Local nj          := 0
Local nTam        := 0
Local lMarca      := .t.
Local aObjects    := {}, aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local _aCabImp    := {}
Private oOkTik    := LoadBitmap(GetResources(), "LBTIK")
Private oNoTik    := LoadBitmap(GetResources(), "LBNO")
Private nOrd      := 0
Private cCreDec   := "<"
Default _cNomArq  := "FGX_VISINT"
Default _cTitulo  := ""
Default _aIntCab  := {}
Default _aIntIte  := {}
Default _lAbrXML  := .f.
Default _aVRetVIS := nil

nRet := 0

If len(_aIntCab) > 0 .and. len(_aIntIte) > 0
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ], aSizeHalf[ 3 ], aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela

	aAdd(aObjects, { 0, 13, .T., .F. }) // Titulo / Botoes
	aAdd(aObjects, { 0,  0, .T., .T. }) // ListBox

	aPos := MsObjSize(aInfo, aObjects)

	For ni := 1 to len(_aIntIte) // Adicionar campo de TIK no vetor (1a.coluna)
		_aIntIte[ni]   := aSize(_aIntIte[ni], Len(_aIntIte[ni]) + 1) // Criar uma posicao a mais no vetor
		_aIntIte[ni]   := aIns(_aIntIte[ni], 1) // inserir 1a. coluna
		_aIntIte[ni,1] := .t.
	Next

	// Alinhamento
	_aCabImp := aClone(_aIntCab)

	For ni := 1 to len(_aCabImp)
		If _aCabImp[ni,2] == "C" // alinhar colunas CARACTER
			nTam := 1

			For nj := 1 to len(_aIntIte)
				If nTam < len(_aIntIte[nj,ni + 1])
					nTam := len(_aIntIte[nj,ni + 1])
				EndIf
			Next

			_aCabImp[ni,1] := left(_aCabImp[ni,1] + space(nTam), nTam)

			For nj := 1 to len(_aIntIte)
				_aIntIte[nj,ni + 1] := left(_aIntIte[nj,ni + 1] + space(nTam), nTam)
			Next
		ElseIf _aCabImp[ni,2] == "D" // alinhar colunas DATA
			nTam := len(Transform(dDatabase, _aCabImp[ni,4]))

			_aCabImp[ni,1] := left(_aCabImp[ni,1] + space(nTam), nTam)
		ElseIf _aCabImp[ni,2] == "N" // alinhar colunas NUMERICO
			nTam := len(Transform(1, _aCabImp[ni,4]))

			_aCabImp[ni,1] := right(space(nTam) + _aCabImp[ni,1], nTam)
		EndIf
	Next

	DEFINE MSDIALOG oFGX_VISINT FROM aSizeHalf[7], 0 TO aSizeHalf[6], aSizeHalf[5];
		TITLE (_cNomArq + " - " + _cTitulo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oFGX_VISINT:lEscClose := .F.

	oLbVISINT := TWBrowse():New(aPos[2,1] + 2, aPos[2,2] + 2, (aPos[2,4] - aPos[2,2] - 4), (aPos[2,3] - aPos[2,1] - 4);
		,,,, oFGX_VISINT,,,,,,,,,,,, .F.,, .T.,, .F.,,,)
	oLbVISINT:nAT := 1
	oLbVISINT:SetArray(_aIntIte)

	oLbVISINT:addColumn(TCColumn():New("", { || IIf(_aIntIte[oLbVISINT:nAt,1], oOkTik, oNoTik) };
		,,,, "LEFT", 05, .T., .F.,,,, .F.,)) // Tik

	For ni := 1 to len(_aIntCab)
		If _aIntCab[ni,2] == "L"
			oLbVISINT:addColumn(TCColumn():New(_aIntCab[ni,1], &("{ || _aIntIte[oLbVISINT:nAt," + Alltrim(str(ni + 1)) + "] }") ;
				,,,, "LEFT"                                 , _aIntCab[ni,3], .F., .F.,,,, .F.,)) // Colunas LOGICAS
		ElseIf _aIntCab[ni,2] == "M"
			oLbVISINT:addColumn(TCColumn():New(_aIntCab[ni,1], { || "Memo" }                                                    ;
				,,,, "LEFT"                                 , _aIntCab[ni,3], .F., .F.,,,, .F.,)) // Colunas MEMO
		Else
			oLbVISINT:addColumn(TCColumn():New(_aIntCab[ni,1], &("{ || Transform(_aIntIte[oLbVISINT:nAt," + Alltrim(str(ni + 1));
				+ "], _aIntCab[" + Alltrim(str(ni)) + ",4]) }"),,,, IIf(_aIntCab[ni,2] <> "N", "LEFT", "RIGHT"), _aIntCab[ni,3], .F., .F.,,,, .F.,)) // DEMAIS Colunas
		EndIf
	Next

	// No duplo clique, verifica se é a primeira coluna do checkbox e apenas marca/desmarca o ckeckbox
	// Caso a coluna seja Memo, abre a tela (Aviso) para visualizar sua informação
	// As demais colunas, verificam se não for tipo Memo e apenas marca/desmarca o ckeckbox
	oLbVISINT:bLDblClick := { || Iif(oLbVISINT:nColPos == 1, _aIntIte[oLbVISINT:nAt,1] := !_aIntIte[oLbVISINT:nAt,1],   ;
		Iif(_aIntCab[oLbVISINT:nColPos - 1, 2] == "M", FGX_VIMEMO(_aIntCab, _aIntIte, oLbVISINT:nColPos, oLbVISINT:nAt),;
		_aIntIte[oLbVISINT:nAt,1] := !_aIntIte[oLbVISINT:nAt,1])) }

	oLbVISINT:bHeaderClick := { |oObj, nCol| IIf(nCol == 1, (lMarca := !lMarca, aEval(_aIntIte, { |x| x[1] := lMarca }),;
		oLbVISINT:Refresh()), FGX_IMPVI("O",,,, _aIntIte, nCol,)) }

	oLbVISINT:Refresh()

	// Montar a tela
	@ aPos[1,1] + 003, 007 SAY oNomTitulo VAR (_cNomArq + " - " + _cTitulo) SIZE 450, 08 OF oFGX_VISINT PIXEL COLOR CLR_BLUE

	@ aPos[1,1] + 001, aPos[1,4] - 170 BUTTON oImprimir PROMPT STR0064 OF oFGX_VISINT SIZE 80, 11;
		PIXEL ACTION FGX_IMPVI("I", _cNomArq, _cTitulo, _aCabImp, _aIntIte,,) // Imprimir

	@ aPos[1,1] + 001, aPos[1,4] - 083 BUTTON oExpExcel PROMPT STR0065 OF oFGX_VISINT SIZE 80, 11;
		PIXEL ACTION FGX_IMPVI("E", _cNomArq, _cTitulo, _aIntCab, _aIntIte,, _lAbrXML) // Exportar XML

	ACTIVATE MSDIALOG oFGX_VISINT ON INIT EnchoiceBar(oFGX_VISINT, {|| nRet := 1, oFGX_VISINT:End() }, {|| nRet := 2, oFGX_VISINT:End() },,)
EndIf
//
If nRet == 1
	If _aVRetVIS <> nil
 		// Vetor utilizado para tratamento posterior à seleção dos Itens na rotina de chamada desta função
		_aVRetVIS := aClone(_aIntIte)
	Endif
Endif
//
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_IMPVI  º Autor ³ Andre Luis Almeida     º Data ³ 26/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ordena/Imprime/GeraExcel - VETOR _aIntIte - funcao FGX_VISINT º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºUso       ³ FGX_VISINT() - Tela para Visualizar aqruivos de Integracoes   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_IMPVI(cTipo, _cNomArq, _cTitulo, _aIntCab, _aIntIte, nColuna, _lAbrXML)
Local aColunas := {}

Local nAl      := 1
Local nTp      := 1
Local ni       := 0
Local nj       := 0

Local oExcel

Local oReport

If cTipo == "O" // Ordenar
	If nOrd <> nColuna
		nOrd := nColuna

		cCreDec := "<"

		Asort(_aIntIte,,, { |x,y| x[nColuna] < y[nColuna] })
	Else
		If cCreDec == ">"
			cCreDec := "<"

			Asort(_aIntIte,,, { |x,y| x[nColuna] < y[nColuna] })
		Else
			cCreDec := ">"

			Asort(_aIntIte,,, { |x,y| x[nColuna] > y[nColuna] })
		EndIf
	EndIf

	If Type("oLbVISINT") <> "U"
		oLbVISINT:Refresh()
	EndIf
ElseIf cTipo == "I" // Imprimir
	oReport := ReportDef(_cNomArq, _cTitulo, _aIntCab, _aIntIte) // Define a estrutura do relatório, por exemplo: seções, campos, totalizadores e etc.
	oReport:SetLandscape() // Define a orientação de página do relatório como paisagem.
	oReport:PrintDialog() // Dispare a impressão do TReport. Exibe a tela de configuração da impressora e os botões de parâmetros.
ElseIf cTipo == "E" // Gerar Excel
	oExcel := FWMSEXCEL():New()

	oExcel:AddworkSheet(_cNomArq)

	oExcel:AddTable (_cNomArq, _cTitulo)

	For ni := 1 to len(_aIntCab)
		nAl := 1 // Alinha: Esquerda
		nTp := 1 // Tipo: Normal
		If _aIntCab[ni,2] == "D"
			nAl := 2 // Alinha: Centralizado
			nTp := 4 // Tipo: Data
		ElseIf _aIntCab[ni,2] == "L"
			nAl := 2 // Alinha: Centralizado
			nTp := 1 // Tipo: Normal
		ElseIf _aIntCab[ni,2] == "N"
			nAl := 3 // Alinha: Direita
			nTp := 2 // Tipo: Numero
		EndIf

		oExcel:AddColumn(_cNomArq, _cTitulo, _aIntCab[ni,1], nAl, nTp)
	Next

	For ni := 1 to len(_aIntIte)
		If _aIntIte[ni,1]
			aColunas := {}

			For nj := 2 to len(_aIntIte[ni])
				If _aIntCab[nj - 1,2] == "C"
					aAdd(aColunas, Transform(_aIntIte[ni,nj], _aIntCab[nj - 1,4]))
				ElseIf _aIntCab[nj - 1,2] == "L"
					aAdd(aColunas, IIf(_aIntIte[ni,nj], ".T.", ".F."))
				Else
					aAdd(aColunas, _aIntIte[ni,nj])
				EndIf
			Next

			If len(aColunas) > 0
				oExcel:AddRow(_cNomArq, _cTitulo, aColunas)
			EndIf
		EndIf
	Next

	oExcel:Activate()

	cArq := &("cGetFile('*.xml', '*.xml', 1, 'SERVIDOR', .F., " + str(nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)) + ", .T., .T.)")

	If !Empty(cArq)
		oExcel:GetXMLFile(cArq + _cNomArq + ".xml")

		MsgAlert(STR0066 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cArq + _cNomArq + ".xml", _cTitulo) // Arquivo gerado com sucesso!

		If _lAbrXML
			If !ApOleClient("MsExcel")
				MsgStop(STR0067, STR0014) // Microsoft Excel não instalado! / Atencao
				Return
			EndIf

			oExcelVer:= MsExcel():New()

			oExcelVer:WorkBooks:Open(cArq + _cNomArq + ".xml")

			oExcelVer:SetVisible(.T.)
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ FGX_SELVEIº Autor ³ Andre Luis Almeida       º Data ³ 18/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Selecao dos Veiculos do VVF (Entrada) ou VV0 (Saida)           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ _cAli = Nome do Alias "VVF" ou "VV0"                           º±±
±±º         ³ _cTit = Titulo da tela                                         º±±
±±º         ³ _cFil = Filial do VVF ou VV0                                   º±±
±±º         ³ _cNro = Numero VVF_TRACPA ou VV0_NUMTRA                        º±±
±±º         ³ _aPar = Parambox que sera inserido no cabecalho da tela        º±±
±±º         ³ _cFVldTES = Funcao para validacao do TES                       º±±
±±º         ³ _lFuncVld = Valida Veiculo Bloqueado? (default: .t.)           º±±
±±º         ³ _aChassiPerm = Chassi's permitidos (vetor em branco: Todos)    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ aRet = { Vetor de retorno do Parambox , Vetor dos Veiculos }   º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FGX_SELVEI( _cAli , _cTit , _cFil , _cNro , _aPar , _cFVldTES , _lFuncVld , _aChassiPerm )
Local aRetorno  := {} // Retorno da Funcao
Local aRet      := array(len(_aPar)) // Retorno do Parambox
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor   := 0
Local nOpcao    := 0
Local cQuery    := ""
Local cSQLAlias := "SQL"+_cAli
Local oOk       := LoadBitmap( GetResources(), "LBTIK" )
Local oNo       := LoadBitmap( GetResources(), "LBNO" )
Local lMarcar   := .t.
Local aObrig    := {}
Local aButtons  := {}
Local lVXSELVEI := existBlock("VXSELVEI")
Local lRet      := .T.
Private aIteVei   := {} // Itens ( Veiculos )
Private lContabil := ( VVA->(FieldPos("VVA_CENCUS")) > 0 .and. VVA->(FieldPos("VVA_CONTA")) > 0 .and. VVA->(FieldPos("VVA_ITEMCT")) > 0 .and. VVA->(FieldPos("VVA_CLVL")) > 0 ) // Campos para a contabilizacao das SAIDAS de Veiculos
Private lCadCtbVV1:= ( VV1->(FieldPos("VV1_CC")) > 0 .and. VV1->(FieldPos("VV1_CONTA")) > 0 .and. VV1->(FieldPos("VV1_ITEMCC")) > 0 .and. VV1->(FieldPos("VV1_CLVL")) > 0 ) // Campos para a contabilizacao Cadastro de Veiculo
Private lMosOper := .f.

Default _lFuncVld := .t.
Default _aChassiPerm := {} // Chassi's permitidos (vetor em branco tras todos os Chassi's da Movimentação selecionada VVF/VV0)

If cPaisLoc == "BRA"
	AADD( aButtons , {"", {|| FS_VIMPDET(_cAli) }, STR0137/*"Impostos"*/} )
EndIf

If FM_PILHA("VEIXA002") .or. FM_PILHA("VEIXA006") .or. FM_PILHA("VEIXA007") .or. FM_PILHA("VEIXA016") .or. FM_PILHA("VEIXA017") .or. FM_PILHA("VEIXA012")
	lMosOper := .t.
EndIf

// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
If cPaisLoc $ "ARG,MEX"
	AAdd( aObjects, {  0 ,  0 , .T. , .F. } ) // Parambox
Else
	AAdd( aObjects, {  0 ,  0 , .T. , .T. } ) // Parambox
EndIf
AAdd( aObjects, {  0 ,  0 , .T. , .T. } ) // ListBox Veiculos
AAdd( aObjects, { 10 , 10 , .T. , .F. } ) // Observacao
aPos := MsObjSize( aInfo, aObjects )
//
For nCntFor := 1 to Len(_aPar)
	aRet[nCntFor] := _aPar[nCntFor,3] // Inicializador padrao dos campos
	&("MV_PAR"+strzero(nCntFor,2)) := _aPar[nCntFor,3]
	If _aPar[nCntFor,len(_aPar[nCntFor])]
		aAdd(aObrig,"MV_PAR"+strzero(nCntFor,2)) // Variaveis obrigatorios
	EndIf
Next
If _cAli == "VVF" // Levanta Veiculos (VVG) da Entrada
	cQuery := "SELECT VVG.R_E_C_N_O_ AS REC , SF4.F4_TESDV , VV1.VV1_CHASSI , VV1.VV1_CHAINT, VV1.VV1_CODMAR , VV2.VV2_DESMOD "
	If lCadCtbVV1
		cQuery += ",VV1.VV1_CC  AS CENCUS,VV1.VV1_CONTA AS CONTA,VV1.VV1_ITEMCC AS ITEMCC,VV1.VV1_CLVL AS CLVL "
	ElseIf lContabil
		cQuery += ",VVG.VVG_CENCUS AS CENCUS,VVG.VVG_CONTA AS CONTA,VVG.VVG_ITEMCT AS ITEMCC,VVG.VVG_CLVL AS CLVL "
	EndIf
	cQuery += ",VVG.VVG_TOTFRE AS FRETE, VVG.VVG_TOTSEG AS DESPESA, VVG.VVG_TOTSEG AS SEGURO "
	cQuery += "FROM "+RetSQLName("VVG")+" VVG "
	cQuery += "JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVG.VVG_CHAINT AND VV1.VV1_ULTMOV='E' AND VV1.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+RetSQLName("VV2")+" VV2 ON VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' "
	cQuery += "LEFT JOIN "+RetSQLName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=VVG.VVG_CODTES AND SF4.D_E_L_E_T_=' ' "
	cQuery += "WHERE VVG.VVG_FILIAL='"+_cFil+"' AND VVG.VVG_TRACPA='"+_cNro+ "' AND VVG.D_E_L_E_T_=' '"
ElseIf _cAli == "VV0" // Levanta Veiculos (VVA) da Saida
	cQuery := "SELECT VVA.R_E_C_N_O_ AS REC , SF4.F4_TESDV , VV1.VV1_CHASSI , VV1.VV1_CHAINT, VV1.VV1_CODMAR , VV2.VV2_DESMOD "
	If lCadCtbVV1
		cQuery += ",VV1.VV1_CC  AS CENCUS,VV1.VV1_CONTA AS CONTA,VV1.VV1_ITEMCC AS ITEMCC,VV1.VV1_CLVL AS CLVL "
	ElseIf lContabil
		cQuery += ",VVA.VVA_CENCUS AS CENCUS,VVA.VVA_CONTA AS CONTA,VVA.VVA_ITEMCT AS ITEMCC,VVA.VVA_CLVL AS CLVL "
	EndIf
	cQuery += ",VVA.VVA_FRETE AS FRETE, VVA.VVA_DESVEI AS DESPESA, VVA.VVA_SEGVIA AS SEGURO "
	cQuery += "FROM "+RetSQLName("VVA")+" VVA "
	cQuery += "JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVA.VVA_CHAINT AND VV1.VV1_ULTMOV='S' AND VV1.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+RetSQLName("VV2")+" VV2 ON VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' "
	cQuery += "LEFT JOIN "+RetSQLName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=VVA.VVA_CODTES AND SF4.D_E_L_E_T_=' ' "
	cQuery += "WHERE VVA.VVA_FILIAL='"+_cFil+"' AND VVA.VVA_NUMTRA='"+_cNro+ "' AND VVA.D_E_L_E_T_=' '"
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !( cSQLAlias )->( Eof() )
	If len(_aChassiPerm) == 0 .or. aScan(_aChassiPerm,( cSQLAlias )->( VV1_CHASSI )) > 0
		if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das SAIDAS de Veiculos
			If !lMosOper
				//14 posições
				aadd(aIteVei,{ .t. , ( cSQLAlias )->( REC ) , ( cSQLAlias )->( F4_TESDV ) , ( cSQLAlias )->( VV1_CHASSI ) , ( cSQLAlias )->( VV1_CODMAR ) , ( cSQLAlias )->( VV2_DESMOD ), ( cSQLAlias )->( VV1_CHAINT ),( cSQLAlias )->(CENCUS),( cSQLAlias )->(CONTA),( cSQLAlias )->(ITEMCC),( cSQLAlias )->(CLVL),( cSQLAlias )->(FRETE),( cSQLAlias )->(DESPESA),( cSQLAlias )->(SEGURO)} )
			Else
				//16 posições
				aadd(aIteVei,{ .t. , ( cSQLAlias )->( REC ) , ( cSQLAlias )->( F4_TESDV ) , ( cSQLAlias )->( VV1_CHASSI ) , ( cSQLAlias )->( VV1_CODMAR ) , ( cSQLAlias )->( VV2_DESMOD ), ( cSQLAlias )->( VV1_CHAINT ),( cSQLAlias )->(CENCUS),( cSQLAlias )->(CONTA),( cSQLAlias )->(ITEMCC),( cSQLAlias )->(CLVL), Space(GetSX3Cache("FM_TIPO", "X3_TAMANHO")),,( cSQLAlias )->(FRETE),( cSQLAlias )->(DESPESA),( cSQLAlias )->(SEGURO) } )
			EndIf
		Else
			If !lMosOper
				//10 posições
				aadd(aIteVei,{ .t. , ( cSQLAlias )->( REC ) , ( cSQLAlias )->( F4_TESDV ) , ( cSQLAlias )->( VV1_CHASSI ) , ( cSQLAlias )->( VV1_CODMAR ) , ( cSQLAlias )->( VV2_DESMOD ), ( cSQLAlias )->( VV1_CHAINT ),,( cSQLAlias )->(FRETE),( cSQLAlias )->(DESPESA),( cSQLAlias )->(SEGURO)} )
			Else
				//11 posições
				aadd(aIteVei,{ .t. , ( cSQLAlias )->( REC ) , ( cSQLAlias )->( F4_TESDV ) , ( cSQLAlias )->( VV1_CHASSI ) , ( cSQLAlias )->( VV1_CODMAR ) , ( cSQLAlias )->( VV2_DESMOD ), ( cSQLAlias )->( VV1_CHAINT ),Space(2),,( cSQLAlias )->(FRETE),( cSQLAlias )->(DESPESA),( cSQLAlias )->(SEGURO) } )
			EndIf
		Endif
	EndIf
	( cSQLAlias )->( dbSkip() )
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea(_cAli)
If len(aIteVei) > 0 .and. ( !cPaisLoc $ "ARG,MEX" .or. ParamBox(_aPar,"",@aRet,,,,1,1,,,.f.) )
	DEFINE MSDIALOG oDlgSELVEI TITLE _cTit FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL
		oDlgSELVEI:lEscClose := .F.
		If !cPaisLoc $ "ARG,MEX"
			oTPanelPar := TPanel():New(aPos[1,1],aPos[1,2],"",oDlgSELVEI,NIL,.T.,.F.,NIL,NIL,aPos[1,4]-aPos[1,2],aPos[1,3]-aPos[1,1],.T.,.F.)
			ParamBox(_aPar,"",@aRet,,,,1,1,oTPanelPar,,.f.)
		EndIf
		if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das SAIDAS de Veiculos
			If	!lMosOper
				//11 posições
				@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbIteVei FIELDS HEADER "",STR0087,STR0089,STR0088,STR0113,STR0114,STR0115,STR0116, STR0146 , STR0147, STR0148 COLSIZES 10,80,120,40,60,60,60,60,40,40,40 SIZE aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1] OF oDlgSELVEI PIXEL ON DBLCLICK FS_SELVEI(1,@aIteVei,oLbIteVei:nAt,oLbIteVei:nColPos,_cFVldTES,,_cAli,.f.,len(_aPar))
			Else
				//12 posições
				@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbIteVei FIELDS HEADER "",STR0087,STR0089,STR0118,STR0088,STR0113,STR0114,STR0115,STR0116, STR0146 , STR0147, STR0148 COLSIZES 10,80,120,50,40,60,60,60,60,40,40,40 SIZE aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1] OF oDlgSELVEI PIXEL ON DBLCLICK FS_SELVEI(1,@aIteVei,oLbIteVei:nAt,oLbIteVei:nColPos,_cFVldTES,,_cAli,.f.,len(_aPar))
			EndIf
		Else
			If	!lMosOper
				//7 posições
				@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbIteVei FIELDS HEADER "",STR0087,STR0089,STR0088,STR0146 , STR0147, STR0148 COLSIZES 10,80,120,40,40,40,40 SIZE aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1] OF oDlgSELVEI PIXEL ON DBLCLICK FS_SELVEI(1,@aIteVei,oLbIteVei:nAt,oLbIteVei:nColPos,_cFVldTES,,_cAli,.f.,len(_aPar))
			Else
				//8 posições
				@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbIteVei FIELDS HEADER "",STR0087,STR0089,STR0118,STR0088,STR0146 , STR0147, STR0148 COLSIZES 10,80,120,50,40,40,40,40 SIZE aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1] OF oDlgSELVEI PIXEL ON DBLCLICK FS_SELVEI(1,@aIteVei,oLbIteVei:nAt,oLbIteVei:nColPos,_cFVldTES,,_cAli,.f.,len(_aPar))
			EndIf
		Endif
		oLbIteVei:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar:=!lMarcar , aEval( aIteVei , {|x| x[1] := lMarcar } ) , oLbIteVei:Refresh() ) ,Nil) , }

		if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das SAIDAS de Veiculos
			oLbIteVei:SetArray(aIteVei)
			If	!lMosOper
				oLbIteVei:bLine := { || { IIf(aIteVei[oLbIteVei:nAt,1],oOk,oNo) , aIteVei[oLbIteVei:nAt,4] , aIteVei[oLbIteVei:nAt,5]+" "+aIteVei[oLbIteVei:nAt,6] , aIteVei[oLbIteVei:nAt,3],aIteVei[oLbIteVei:nAt,8],aIteVei[oLbIteVei:nAt,9],aIteVei[oLbIteVei:nAt,10],aIteVei[oLbIteVei:nAt,11],Transform(aIteVei[oLbIteVei:nAt,12], PesqPict('VVA', 'VVA_FRETE')),Transform(aIteVei[oLbIteVei:nAt,13], PesqPict('VVA', 'VVA_DESVEI')),Transform(aIteVei[oLbIteVei:nAt,14], PesqPict('VVA', 'VVA_SEGVIA')) }}
			Else
				oLbIteVei:bLine := { || { IIf(aIteVei[oLbIteVei:nAt,1],oOk,oNo) , aIteVei[oLbIteVei:nAt,4] , aIteVei[oLbIteVei:nAt,5]+" "+aIteVei[oLbIteVei:nAt,6] , aIteVei[oLbIteVei:nAt,12], aIteVei[oLbIteVei:nAt,3] ,aIteVei[oLbIteVei:nAt,8],aIteVei[oLbIteVei:nAt,9],aIteVei[oLbIteVei:nAt,10],aIteVei[oLbIteVei:nAt,11],Transform(aIteVei[oLbIteVei:nAt,14], PesqPict('VVA', 'VVA_FRETE')),Transform(aIteVei[oLbIteVei:nAt,15], PesqPict('VVA', 'VVA_DESVEI')),Transform(aIteVei[oLbIteVei:nAt,16], PesqPict('VVA', 'VVA_SEGVIA')) }}
			EndIf
		Else
			oLbIteVei:SetArray(aIteVei)
			If	!lMosOper
				oLbIteVei:bLine := { || { IIf(aIteVei[oLbIteVei:nAt,1],oOk,oNo) , aIteVei[oLbIteVei:nAt,4] , aIteVei[oLbIteVei:nAt,5]+" "+aIteVei[oLbIteVei:nAt,6] , aIteVei[oLbIteVei:nAt,3],Transform(aIteVei[oLbIteVei:nAt,08], PesqPict('VVA', 'VVA_FRETE')),Transform(aIteVei[oLbIteVei:nAt,09], PesqPict('VVA', 'VVA_DESVEI')),Transform(aIteVei[oLbIteVei:nAt,10], PesqPict('VVA', 'VVA_SEGVIA')) }}
			Else
				oLbIteVei:bLine := { || { IIf(aIteVei[oLbIteVei:nAt,1],oOk,oNo) , aIteVei[oLbIteVei:nAt,4] , aIteVei[oLbIteVei:nAt,5]+" "+aIteVei[oLbIteVei:nAt,6] , aIteVei[oLbIteVei:nAt,8], aIteVei[oLbIteVei:nAt,3],Transform(aIteVei[oLbIteVei:nAt,09], PesqPict('VVA', 'VVA_FRETE')),Transform(aIteVei[oLbIteVei:nAt,10], PesqPict('VVA', 'VVA_DESVEI')),Transform(aIteVei[oLbIteVei:nAt,11], PesqPict('VVA', 'VVA_SEGVIA')) }}
			EndIf
		Endif
		@ aPos[3,1],aPos[3,2] SAY STR0093 SIZE 360,8 OF oDlgSELVEI PIXEL COLOR CLR_RED // Clique duas vezes sobre a coluna TES para alterar o TES da linha desejada.
	ACTIVATE MSDIALOG oDlgSELVEI CENTER ON INIT (EnchoiceBar(oDlgSELVEI,{|| IIf(FS_SELVEI(2, @aIteVei, 0, 0, "", aObrig, "", _lFuncVld, len(_aPar)),( nOpcao:=1 , oDlgSELVEI:End() ),.t.) },{ || oDlgSELVEI:End()}, , aButtons))
	If nOpcao == 1 // OK Tela
		aRetorno := {aClone(aRet),aClone(aIteVei)}

		if lVXSELVEI
			lRet := execBlock("VXSELVEI", .F., .F., { aClone(aRet), aClone(aIteVei) } )
			if valType(lRet) == "L" .and. ! lRet
				aRetorno := {}
			endif
		endif
	EndIf
Else
	MsgStop(STR0090,STR0014) // Nenhum veiculo encontrado! / Atencao
EndIf
Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VIMPDET º Autor ³ Vinicius Gati          º Data ³ 22/02/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mostra detalhes de impostos de veiculos tranferidos           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VIMPDET( _cAlias )
	Local nIdx := 1
	Local aObjects  := {} , aPos := {} , aInfo := {}
	Local aSelected := {}
	Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local oLbImp
	Local oDlg
	Local oMainWindow
	Local nPOSCODTES := 3 // posicoes coletadas da funcao acima
	Local nPOSCHASSI := 4 // posicoes coletadas da funcao acima
	Local nPOSCODMAR := 5 // posicoes coletadas da funcao acima
	Local nPOSDESMOD := 6 // posicoes coletadas da funcao acima
	Local oArHlp     := DMS_ArrayHelper():New()
	Local aArea      := GetArea()
	Local nPOSCHAINT := 7 //Necessário para posicionar na tabela VVG pois o Chaint é Chave.

	// Fator de reducao 80%
	For nIdx := 1 to Len(aSizeHalf)
		aSizeHalf[nIdx] := INT(aSizeHalf[nIdx] * 0.8)
	Next
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, {  0 ,  0 , .T. , .T. } ) // Parambox
	AAdd( aObjects, {  0 ,  0 , .T. , .T. } ) // ListBox Veiculos
	AAdd( aObjects, { 10 , 10 , .T. , .F. } ) // Observacao
	aPos := MsObjSize( aInfo, aObjects )

	// filtrando somente os selecionados no browse que tenha tes digitado
	for nIdx := 1 to LEN( oLbIteVei:aArray ) // array de veiculos , primeira posição é o tik
		aDadosVei := oLbIteVei:aArray[nIdx]

		if aDadosVei[1] .AND. ! Empty(aDadosVei[nPOSCODTES])

			// Busca informações de impostos
			if _cAlias == 'VV0'
				dbSelectArea("VVA")
				dbSetOrder(1)
				MsSeek(VV0->VV0_FILIAL + VV0->VV0_NUMTRA + aDadosVei[nPOSCHASSI])
				oFiscal := FS_FISVEI('C',VV0->VV0_CODCLI, VV0->VV0_LOJA, aDadosVei[nPOSCODTES], aDadosVei[nPOSCHASSI], aDadosVei[nPOSCHAINT])
			else
				dbSelectArea("VVG")
				dbSetOrder(1)
				MsSeek(VVF->VVF_FILIAL + VVF->VVF_TRACPA + aDadosVei[nPOSCHAINT])
				oFiscal := FS_FISVEI('F',VVF->VVF_CODFOR, VVF->VVF_LOJA, aDadosVei[nPOSCODTES], aDadosVei[nPOSCHASSI], aDadosVei[nPOSCHAINT])
			end
			// pega as informações e coloca nos dados do listbox
			nTotal := oFiscal:GetValue('VALOR' , 0) + oFiscal:GetValue('PIS', 0) +;
				oFiscal:GetValue('COFINS', 0) + oFiscal:GetValue('ICMS', 0) + oFiscal:GetValue('ICMST', 0)

			AADD(aSelected, { ;
				aDadosVei[nPOSCHASSI]        ,; // 01 chassi
				aDadosVei[nPOSCODMAR]        ,; // 02 marca
				aDadosVei[nPOSDESMOD]        ,; // 03 des modelo
				oFiscal:GetValue('VALOR' , 0),; // 04 valor veiculo
				oFiscal:GetValue('PIS'   , 0),; // 05 pis
				oFiscal:GetValue('COFINS', 0),; // 06 cofins
				oFiscal:GetValue('ICMS'  , 0),; // 07 icms
				oFiscal:GetValue('ICMST' , 0) ; // 08 icms st
			})
		end
	next

	RestArea(aArea)

	// Linha totalizadora
	AADD(aSelected, {;
		STR0138 /*"Total"*/     ,; // 01 chassi
		""                      ,; // 02 marca
		""                      ,; // 03 des modelo
		oArHlp:Sum(4, aSelected),; // 04 soma dos valores veiculo
		oArHlp:Sum(5, aSelected),; // 05 soma dos pis
		oArHlp:Sum(6, aSelected),; // 06 soma dos cofins
		oArHlp:Sum(7, aSelected),; // 07 soma dos icms
		oArHlp:Sum(8, aSelected) ; // 08 soma dos icms st
	})

	if LEN(aSelected) == 0
		Alert(STR0136, STR0014) /* "Nenhum veículo selecionado com TES preenchida detectado." | "Atenção" */
		return .F.
	end

	DEFINE MSDIALOG oDlg TITLE STR0132 /*"Detalhamento Fiscal"*/ FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWindow PIXEL

	@ aPos[1,1]+010,aPos[1,2]+000 LISTBOX oLbImp FIELDS ;
		HEADER   STR0087/*"Chassi"*/, STR0133/*"Cod. Marca"*/, STR0134 /*"Modelo"*/, STR0135 /*"Valor Veiculo"*/, "Pis", "Cofins", "ICMS", "ICMS ST",  "" ;
		COLSIZES 80, 50, 80, 50, 50, 50, 50, 50, 100 ;
		SIZE aPos[2,4]-aPos[1,2],aPos[2,3]-aPos[1,1] ;
	OF oDlg PIXEL
	oLbImp:SetArray(aSelected)
	oLbImp:bLine := { || ;
		{ ;
			oLbImp:aArray[oLbImp:nAt, 01],;
			oLbImp:aArray[oLbImp:nAt, 02],;
			oLbImp:aArray[oLbImp:nAt, 03],;
			FG_AlinVlrs(Transform(oLbImp:aArray[oLbImp:nAt, 04], PesqPict('SF2', 'F2_VALBRUT'))),;
			FG_AlinVlrs(Transform(oLbImp:aArray[oLbImp:nAt, 05], PesqPict('SF1', 'F1_VALPIS' ))),;
			FG_AlinVlrs(Transform(oLbImp:aArray[oLbImp:nAt, 06], PesqPict('SF1', 'F1_VALCOFI'))),;
			FG_AlinVlrs(Transform(oLbImp:aArray[oLbImp:nAt, 07], PesqPict('SD2', 'D2_VALICM' ))),;
			FG_AlinVlrs(Transform(oLbImp:aArray[oLbImp:nAt, 08], PesqPict('SD2', 'D2_VALICM' ))),;
			"" ;
		};
	}

	ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| oDlg:End() },{ || oDlg:End()}, , /*aButtons*/))
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_FISVEI  º Autor ³ Vinicius Gati         º Data ³ 22/02/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula e retorna dados de fiscal para o veiculo e tes        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FISVEI(cTipo, cCod, cLoja, cTES, cChassi, cChaInt)
	
	Local cGruVei    := FGX_GrupoVeic(cChaInt)
	Local nValCus    := 0
	Local aArea      := GetArea()
	Local cFilBck    := cFilAnt
	Local aAreaB1    := SB1->(GetArea())
	Local aAreaA1    := SA1->(GetArea())
	Local aAreaA2    := SA2->(GetArea())
	Local aAreaVV1   := VV1->(GetArea())

	MaFisClear()

	if cTipo == 'C' // Cliente
		dbSelectArea('SA1')
		dbSetOrder(1)
		MsSeek(xFilial('SA1') + cCod + cLoja)
		MaFisIni(cCod, cLoja, cTipo /*C ou F*/, 'N' /*Tipo NF*/, SA1->A1_TIPO, MaFisRelImp("VEIXFUNA",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
	elseif cTipo == 'F' //Fornecedor
		dbSelectArea('SA2')
		dbSetOrder(1)
		MsSeek(xFilial('SA2') + cCod + cLoja)
		MaFisIni(cCod, cLoja, cTipo /*C ou F*/, 'N' /*Tipo NF*/, SA2->A2_TIPO, MaFisRelImp("VEIXFUNA",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
	else
		Alert(STR0131, STR0014) // "Tipo inválido para calcular fiscal" | "Atenção"
	end

	// Posiciona corretamente na SB1 dependendo do parametro MV_MIL0010
	If FGX_VV1SB1("CHASSI", cChassi , /* cMVMIL0010 */ , cGruVei )

		//Busca valor do veiculo conforme veixx001
		if Empty(GetNewPar("MV_CUSTRFV",""))

			// se foi saida troco cfilant pois existe o risco de naõ existir no B2 da filial que receberá o veiculo
			if cTipo == 'C'
				cFilAnt := VV1->VV1_FILSAI
			end

			cQryAlias := GetNextAlias()
			cQuery := "SELECT B2_CM1 FROM "+RetSqlName("SB2")
			cQuery += " WHERE B2_FILIAL ='"+xFilial("SB2")+"'"
			cQuery += " AND B2_COD ='"+SB1->B1_COD+"'"
			cQuery += " AND D_E_L_E_T_=' ' ORDER BY B2_QATU DESC "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )

			(cQryAlias)->(dbGoTop())
			if !(cQryAlias)->(eof())
				nValCus := (cQryAlias)->(B2_CM1)
			endif
			(cQryAlias)->(dbCloseArea())
		else
			cForPad := GETMV("MV_CUSTRFV")
			nValCus := FG_FORMULA(cForPad)
		endif

		MaFisAdd(SB1->B1_COD,; // 1-Codigo do Produto ( Obrigatorio )
		  cTES,; // 02 - Codigo do TES ( Opcional )
			  1,; // 03 - Quantidade ( Obrigatorio )
			nValCus,; // 04 - Preco Unitario ( Obrigatorio )
			  0,; // 05 - Valor do Desconto ( Opcional )
			 "",; // 06 - Numero da NF Original ( Devolucao/Benef )
			 "",; // 07 - Serie da NF Original ( Devolucao/Benef )
			  0,; // 08 - RecNo da NF Original no arq SD1/SD2
			  0,; // 09 - Valor do Frete do Item ( Opcional )
			  0,; // 10 - Valor da Despesa do item ( Opcional )
			  0,; // 11 - Valor do Seguro do item ( Opcional )
			  0,; // 12 - Valor do Frete Autonomo ( Opcional )
			nValCus,; // 13 - Valor da Mercadoria ( Obrigatorio )
			0  ,; // 14 - Valor da Embalagem ( Opiconal )
			   ,; // 15
			   ,; // 16
			 "",; // 17
			  0,; // 18 - Despesas nao tributadas - Portugal
			  0,; // 19 - Tara - Portugal
			 "",; // 20 - CFO
			 {},; // 21 - Array para o calculo do IVA Ajustado (opcional)
			 "",; // 22 - Codigo Retencao - Equador
			  0,; // 23 - Valor Abatimento ISS
			 "",; // 24 - Lote Produto
			 "",; // 25 - Sub-Lote Produto
			   ,;
			   ,;
			 "" ; // 28-Classificação fiscal
		)

		nPIS    := MAFISRET(1,'IT_VALPIS')
		nCOFINS := MAFISRET(1,'IT_VALCOF')
		nICMS   := MAFISRET(1,'IT_VALICM')
		nICMSST := MAFISRET(1,'IT_VALSOL')

		MaFisEnd()
	else
		nPIS    := 0
		nCOFINS := 0
		nICMS   := 0
		nICMSST := 0
	end

	RestArea(aArea)
	RestArea(aAreaB1)
	RestArea(aAreaA1)
	RestArea(aAreaA2)
	RestArea(aAreaVV1)
	cFilAnt := cFilBck

Return DMS_DataContainer():New({ ;
	{'VALOR' , nValCus },;
	{'PIS'   , nPIS    },;
	{'COFINS', nCOFINS },;
	{'ICMS'  , nICMS   },;
	{'ICMST' , nICMSST } ;
})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_SELVEI  º Autor ³ Andre Luis Almeida     º Data ³ 19/06/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Selec veiculo / Alteracao TES / OK tela - funcao FGX_SELVEI   º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºUso       ³ FGX_SELVEI() - Tela para selecao de Veiculos / altera TES     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELVEI(nTp,aIteVei,nLinha,nColuna,cFVldTES,aObrig,_cAli,_lFuncVld,nQtdMV)
Local lRet        := .t.
Local lSelec      := .f.
Local nCntFor     := 0
Local aParamBox   := {}
Local aRPBox      := {}
Local lAltTES     := GetNewPar("MV_MIL0099","N") == "S"
Local cWhenTES    := IIF(lAltTES, ".T.", ".F.")
Local oVeiculos   := DMS_Veiculo():New()
Local aSlvMV      := {}

Private cAli      := _cAli
Private nLha      := 0

Default cFVldTES  := ""
Default aObrig    := {}
Default _cAli     := ""
Default _lFuncVld := .t.
Default nQtdMV    := 0

For nCntFor := 1 to nQtdMV
	aAdd(aSlvMV,&("MV_PAR"+strzero(nCntFor,2))) // Salva MV_PAR... devido a Parambox
Next

If nTp == 1 // Seleciona Veiculo   ou   Altera TES
	If nColuna <> 4 .and. nColuna <> 5 .and. nColuna <> 6 .and. nColuna <> 7 .and. nColuna <> 8  // Seleciona Veiculo
		aIteVei[nLinha,1] := !aIteVei[nLinha,1]
		oLbIteVei:Refresh()
	Else // Alteracao TES
		If lMosOper
			nLha := nLinha
			if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das ENTRADAS/SAIDAS de Veiculos
				aAdd(aParamBox,{1,STR0118,aIteVei[nLinha,12],"@!","FS_PCHTES(aIteVei,nLha,cAli)","DJ" ,"", GetSX3Cache("FM_TIPO", "X3_TAMANHO"),.F.})
			Else
				aAdd(aParamBox,{1,STR0118,aIteVei[nLinha,08],"@!","FS_PCHTES(aIteVei,nLha,cAli)","DJ" ,"",2,.F.})
			EndIf
			AADD(aParamBox,{1,STR0088,aIteVei[nLinha,3],"@!",'(FG_SEEK("SF4","MV_PAR02",1,.f.).and.'+IIf(!Empty(cFVldTES),(cFVldTES+'(MV_PAR02, aItevei, nLha, aIteVei[nLha, 4])'),".T.") + ") .OR. Empty(MV_PAR02)","SF4",cWhenTES,40,.t.}) // TES
		Else
			nLha := nLinha
			AADD(aParamBox,{1,STR0088,aIteVei[nLinha,3],"@!",'FG_SEEK("SF4","MV_PAR01",1,.f.).and.'+IIf(!Empty(cFVldTES),(cFVldTES+'(MV_PAR01, aIteVei, nLha, aIteVei[nLha, 4])'),".T."),"SF4",cWhenTES,40,.t.}) // TES
		EndIf
		if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das ENTRADAS/SAIDAS de Veiculos
			AADD(aParamBox,{1,STR0113,aIteVei[nLinha,8],"@!","","CTT","",40,.f.}) // Centro de Custo
			AADD(aParamBox,{1,STR0114,aIteVei[nLinha,9],"@!","","CT1","",40,.f.}) // Conta
			AADD(aParamBox,{1,STR0117,aIteVei[nLinha,10],"@!","","CTD","",40,.f.}) // Item da Conta
			AADD(aParamBox,{1,STR0116,aIteVei[nLinha,11],"@!","","CTH","",40,.f.}) // Classe Valor
		Endif

		if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das SAIDAS de Veiculos
			If !lMosOper
				//14 posições
				AADD(aParamBox,{1,STR0146 ,aIteVei[nLinha,12],PesqPict('VVA', 'VVA_FRETE'),"","","",80,.f.}) // Frete
				AADD(aParamBox,{1,STR0147,aIteVei[nLinha,13],PesqPict('VVA', 'VVA_DESVEI'),"","","",80,.f.}) // Despesas
				AADD(aParamBox,{1,STR0148,aIteVei[nLinha,14],PesqPict('VVA', 'VVA_SEGVIA'),"","","",80,.f.}) // Seguro
			Else
				//16 posições
				AADD(aParamBox,{1,STR0146 ,aIteVei[nLinha,14],PesqPict('VVA', 'VVA_FRETE'),"","","",80,.f.}) // Frete
				AADD(aParamBox,{1,STR0147,aIteVei[nLinha,15],PesqPict('VVA', 'VVA_DESVEI'),"","","",80,.f.}) // Despesas
				AADD(aParamBox,{1,STR0148,aIteVei[nLinha,16],PesqPict('VVA', 'VVA_SEGVIA'),"","","",80,.f.}) // Seguro
			EndIf
		Else
			If !lMosOper
				//10 posições
				AADD(aParamBox,{1,STR0146 ,aIteVei[nLinha,8],PesqPict('VVA', 'VVA_FRETE'),"","","",80,.f.}) // Frete
				AADD(aParamBox,{1,STR0147,aIteVei[nLinha,9],PesqPict('VVA', 'VVA_DESVEI'),"","","",80,.f.}) // Despesas
				AADD(aParamBox,{1,STR0148,aIteVei[nLinha,10],PesqPict('VVA', 'VVA_SEGVIA'),"","","",80,.f.}) // Seguro
			Else
				//11 posições
				AADD(aParamBox,{1,STR0146 ,aIteVei[nLinha,9],PesqPict('VVA', 'VVA_FRETE'),"","","",80,.f.}) // Frete
				AADD(aParamBox,{1,STR0147,aIteVei[nLinha,10],PesqPict('VVA', 'VVA_DESVEI'),"","","",80,.f.}) // Despesas
				AADD(aParamBox,{1,STR0148 ,aIteVei[nLinha,11],PesqPict('VVA', 'VVA_SEGVIA'),"","","",80,.f.}) // Seguro
			EndIf
		Endif
		If ParamBox(aParamBox,STR0088,@aRPBox,,,,,,,,.f.) // TES
			If lMosOper
				aIteVei[nLinha,3] := aRPBox[02] // TES
				if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das ENTRADAS/SAIDAS de Veiculos
					aIteVei[nLinha,8] := aRPBox[03] // Centro de Custo
					aIteVei[nLinha,9] := aRPBox[04] // Conta
					aIteVei[nLinha,10] := aRPBox[05] // Item da Conta
					aIteVei[nLinha,11] := aRPBox[06] // Classe Valor
					aIteVei[nLinha,12] := aRPBox[01] // Operacao
					aIteVei[nLinha,14] := aRPBox[07] // Frete
					aIteVei[nLinha,15] := aRPBox[08] // Despesas
					aIteVei[nLinha,16] := aRPBox[09] // Seguro
				Else
					aIteVei[nLinha,08] := aRPBox[01] // Operacao
					aIteVei[nLinha,09] := aRPBox[03] // Frete
					aIteVei[nLinha,10] := aRPBox[04] // Despesas
					aIteVei[nLinha,11] := aRPBox[05] // Seguro
			 	Endif
			 Else
				aIteVei[nLinha,3] := aRPBox[01] // TES
				if lContabil .or. lCadCtbVV1 // Campos para a contabilizacao das ENTRADAS/SAIDAS de Veiculos
					aIteVei[nLinha,8] := aRPBox[02] // Centro de Custo
					aIteVei[nLinha,9] := aRPBox[03] // Conta
					aIteVei[nLinha,10] := aRPBox[04] // Item da Conta
					aIteVei[nLinha,11] := aRPBox[05] // Classe Valor
					aIteVei[nLinha,12] := aRPBox[06] // Frete
					aIteVei[nLinha,13] := aRPBox[07] // Despesas
					aIteVei[nLinha,14] := aRPBox[08] // Seguro
				else
					aIteVei[nLinha,8] := aRPBox[02] // Frete
					aIteVei[nLinha,9] := aRPBox[03] // Despesas
					aIteVei[nLinha,10] := aRPBox[04] // Seguro
			 	Endif
			 EndIf
		EndIf
	EndIf
ElseIf nTp == 2 // OK tela
	// Verificar campos obrigatorios
	For nCntFor := 1 to Len(aObrig)
		If Empty(&(aObrig[nCntFor]))
			lRet := .f.
			MsgStop(STR0091,STR0014) // Campos obrigatorios nao estao preenchidos! / Atencao
			Exit
		EndIf
	Next
	If lRet
		// verificar veiculos selecionados
		For nCntFor := 1 to Len(aIteVei)
			If aIteVei[nCntFor,1]
				lSelec := .t.
				If _lFuncVld
					// Chassi Bloqueado
					If oVeiculos:Bloqueado(aIteVei[nCntFor,7], aIteVei[nCntFor,4])
						lRet := .f. // A mensagem já é exibida dentro da função Bloqueado()
					EndIf
				EndIf
			EndIf
		Next
		If lSelec
			If lRet
				If ExistBlock("PESELVEI") // Ponto de Entrada no TUDOOK da tela de Selecao de Veiculos
					lRet := ExecBlock("PESELVEI",.f.,.f.,{ aClone(aIteVei) }) // Ponto de Entrada no TUDOOK da tela de Selecao de Veiculos
				EndIf
			EndIf
		Else
			MsgStop(STR0092,STR0014) // Nenhum veiculo selecionado! / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
For nCntFor := 1 to nQtdMV
	&("MV_PAR"+strzero(nCntFor,2)) := aSlvMV[nCntFor] // Volta MV_PAR... devido a Parambox
Next
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_PREVIEW º Autor ³ Thiago			       º Data ³ 26/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre preview no banco de conhecimento.				   	     º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_PREVIEW()
if ACB->(FieldPos("ACB_NIVEL")) > 0
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	DBSelectArea("ACB")
	DBSetOrder(2)
	DBSeek(xFilial("ACB")+Alltrim(aCols[n,FG_POSVAR("AC9_OBJETO","aHeader")]))
	if !Alltrim(ACB->ACB_NIVEL) $ VAI->VAI_NIVAC9
		MsgAlert(STR0094,STR0014)
		Return(.f.)
	Endif
Endif
MsFlPreview( oOle, @aExclui )
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_XlsOpen º Autor ³ Thiago			       º Data ³ 26/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre planilha no banco de conhecimento.				   	     º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_XlsOpen()
if ACB->(FieldPos("ACB_NIVEL")) > 0
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	DBSelectArea("ACB")
	DBSetOrder(2)
	DBSeek(xFilial("ACB")+Alltrim(aCols[n,FG_POSVAR("AC9_OBJETO","aHeader")]))
	if !Alltrim(ACB->ACB_NIVEL) $ VAI->VAI_NIVAC9
		MsgAlert(STR0094,STR0014)
		Return(.f.)
	Endif
Endif
PcoXlsOpen( @oOle, @aExclui )
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_DocOpen º Autor ³ Thiago			       º Data ³ 26/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre documento no banco de conhecimento.				   	     º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_DocOpen()
if ACB->(FieldPos("ACB_NIVEL")) > 0
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	DBSelectArea("ACB")
	DBSetOrder(2)
	DBSeek(xFilial("ACB")+Alltrim(aCols[n,FG_POSVAR("AC9_OBJETO","aHeader")]))
	if !Alltrim(ACB->ACB_NIVEL) $ VAI->VAI_NIVAC9
		MsgAlert(STR0094,STR0014)
		Return(.f.)
	Endif
Endif
MsDocOpen( @oOle, @aExclui )
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_ALTGRU º Autor ³ Vinicius Gati          º Data ³ 04/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Utilizada no mata010 para alterar o grupo da peca             º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_ALTGRU( cB1COD , cB1CODITE , cGrpAnt , cB1GRUPO , cOrigem )
Local lRet     := .T.
Local nRecVR2  := 0
Local nErrcode := Nil
Local cAux     := ""
Local aTexto1  := {""}
Local aTexto2  := {""}
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local nTpExec  := GetNewPar("MV_MIL0077",1)            //            Tipo de Execucao na alteracao do GRUPO do Produto               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tipo de Execucao:                                                                                                                 //
//   1 - Executa agora em modo Exclusivo (default)                                                                                   //
//   2 - Executa depois via SCHEDULE                                                                                                 //
//   3 - Executa agora e refaz depois via SCHEDULE (opcao nao deve ser utilizada pq pode ocorrer inconsistencia nos relacionamentos) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
Default cOrigem := "1" // 1=Cad.Produto / 2=Aplicação / 3=Grupo/SubGrupo
//
DbSelectArea("SB1")
If X3Obrigat("B1_GRUPO") .and. Empty(cB1GRUPO) // Quando GRUPO novo estiver em branco Retornar .f.
	Help(" ",1,"OBRIGAT2",,RetTitle("B1_GRUPO"),4,1)
	Return .f.
EndIf
//
If ExistBlock("PEALTGR1") // Temporario PEALTGR1
	lAux := ExecBlock("PEALTGR1",.f.,.f.) // checagem de ponto de entrada onde o cliente pode invalidar a validacao de exclusividade ao alterar grupo caso deseje
	If lAux
		nTpExec := 3 // Agora e refazer depois via SCHEDULE
	EndIf
EndIf
//
If cOrigem == "1" .and. nTpExec == 2 // MATA010 ( Cad.Produto ) e Executar depois via SCHEDULE
	DbSelectArea("SB1")
	DbSetOrder(1)
	If MsSeek(xFilial("SB1")+cB1COD)
		aTexto1:= {RetTitle("B1_GRUPO")}
		aTexto2:= {STR0128}
		ShowHelpDlg(STR0014,aTexto1,5,aTexto2,5)
		RecLock("SB1",.f.)
		SB1->B1_GRUPO := cGrpAnt // Voltar Grupo, alteração do GRUPO sera executada depois via SCHEDULE
		MsUnLock()
	EndIf
EndIf
//
cAux := FM_SQL("SELECT VR2_GRUNOV FROM "+RetSqlName('VR2')+" WHERE VR2_FILIAL='"+xFilial('VR2')+"' AND VR2_STATUS='0' AND VR2_CODSB1='"+cB1COD+"' AND D_E_L_E_T_=' ' ORDER BY VR2_CODIGO DESC")
If !Empty(cAux)
	cGrpAnt := cAux // Utilizar o ultimo Grupo Novo para modificalo
EndIf
//
If cGrpAnt <> cB1GRUPO
	DbSelectArea("VR2")
	RecLock("VR2",.t.)
		VR2->VR2_FILIAL := xFilial("VR2")
		VR2->VR2_CODIGO := GetSXENum("VR2","VR2_CODIGO")
		VR2->VR2_CODSB1 := cB1COD
		VR2->VR2_STATUS := "0" // 0=Pendente / 1=OK
		VR2->VR2_CODITE := cB1CODITE
		VR2->VR2_GRUANT := cGrpAnt
		VR2->VR2_GRUNOV := cB1GRUPO
		VR2->VR2_DATSOL := dDataBase
		VR2->VR2_HORSOL := val(substr(time(),1,2)+substr(time(),4,2))
		VR2->VR2_CODUSR := __cUserID
		VR2->VR2_ORIGEM := cOrigem // 1=Cad.Produto / 2=Aplicação / 3=Grupo/SubGrupo
		VR2->VR2_FILANT := cFilAnt
		VR2->VR2_DATALT := ctod("")
		VR2->VR2_HORALT := 0
	MsUnLock()
	ConfirmSX8()
	nRecVR2 := VR2->(RecNo())
	//
	oPecDAO := DMS_Peca():New()
	oLogger := Mil_Logger():New('SB1_MUDANCA_B1_GRUPO.log')
	//
	If nTpExec == 1 .or. nTpExec == 3 // Executar AGORA
		nErrCode := oPecDAO:UpdateGroup( cB1COD , cB1CODITE , cGrpAnt , cB1GRUPO , nRecVR2 )
		DbSelectArea("SB1")
		DbSetOrder(1)
		MsSeek(xFilial("SB1")+cB1COD)
		If nErrCode == 0 // Executou OK
			if nTpExec == 3 // Refazer depois via SCHEDULE
				DbSelectArea("VR2")
				DbGoTo(nRecVR2)
				RecLock("VR2",.f.)
					VR2->VR2_STATUS := "0" // 0=Pendente / 1=OK
					VR2->VR2_DATALT := ctod("")
					VR2->VR2_HORALT := 0
				MsUnLock()
			EndIf
			// So escreve no log se conseguiu processar tudo com sucesso
			cLogMessage := STR0096+UsrFullName(RetCodUsr())+" B1_CODITE: "+cB1CODITE+" B1_GRUPO:  "+cGrpAnt+STR0095+" B1_GRUPO: "+cB1GRUPO
			oLogger:Log({'TIMESTAMP', cLogMessage})
		Else
			If nTpExec == 1 // Somente Exclusivo
				aTexto1:= {STR0142} // Houve uma alteração de grupo do produto, o mesmo requer acesso exclusivo ao sistema em modo SIGAADV.
				aTexto2:= {STR0143} // Por favor desconecte todos os usuários antes de tentar novamente.
				ShowHelpDlg(STR0014,aTexto1,5,aTexto2,5)
				lRet := .F.
				If cOrigem == "1" // MATA010 ( Cad.Produto )
					RecLock("SB1",.f.)
					SB1->B1_GRUPO := cGrpAnt // Voltar Grupo, alteração do GRUPO tem que ser executada de forma exclusiva
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_CALEND º Autor ³ Andre Luis Almeida     º Data ³ 03/07/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calendario - selecao de datas                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ dDtIni = Dt Inicial utilizada para validar a selecao do dia   º±±
±±º          ³ dDtFin = Dt Final utilizada para validar a selecao do dia     º±±
±±º          ³ aDtSel = { Vetor com as datas pre-selecionadas no Calendario }º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aDtSel = { Vetor com as datas selecionadas no Calendario }    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_CALEND(dDtIni,dDtFin,aDtSel)
Local dDtRef   := dDataBase
Local dDtDM    := dDataBase
Local dDtFM    := dDataBase
Local aCalend  := {}
Default dDtIni := dDataBase
Default dDtFin := dDataBase + 99999
Default aDtSel := {}
FS_CLICK("0",0,0,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin)
DEFINE DIALOG oCalend TITLE STR0098 FROM 0,0 TO 146,232 PIXEL // Calendario
oCalend:lEscClose := .F.
@ 001,001 BUTTON oDA PROMPT "<<" OF oCalend SIZE 15,10 PIXEL ACTION FS_CLICK("DANO",0,0,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin)
@ 001,016 BUTTON oDM PROMPT "<" OF oCalend SIZE 15,10 PIXEL ACTION FS_CLICK("DMES",0,0,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin)
@ 001,031 BUTTON oBMesAno PROMPT strzero(month(dDtRef),2)+" / "+strzero(year(dDtRef),4) OF oCalend SIZE 55,10 PIXEL WHEN .f.
@ 001,086 BUTTON oAM PROMPT ">" OF oCalend SIZE 15,10 PIXEL ACTION FS_CLICK("AMES",0,0,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin)
@ 001,101 BUTTON oAA PROMPT ">>" OF oCalend SIZE 15,10 PIXEL ACTION FS_CLICK("AANO",0,0,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin)
oLbCalend := TWBrowse():New(12,01,124,75,,,,oCalend,,,,,{ || FS_CLICK("DIA",oLbCalend:nAt,oLbCalend:nColPos,@aCalend,@aDtSel,@dDtRef,@dDtDM,@dDtFM,dDtIni,dDtFin) },,,,,,,.F.,,.T.,,.F.,,.F.,.F.)
oLbCalend:addColumn( TCColumn():New( STR0099 , { || aCalend[oLbCalend:nAt,1] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Dom
oLbCalend:addColumn( TCColumn():New( STR0100 , { || aCalend[oLbCalend:nAt,2] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Seg
oLbCalend:addColumn( TCColumn():New( STR0101 , { || aCalend[oLbCalend:nAt,3] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Ter
oLbCalend:addColumn( TCColumn():New( STR0102 , { || aCalend[oLbCalend:nAt,4] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Qua
oLbCalend:addColumn( TCColumn():New( STR0103 , { || aCalend[oLbCalend:nAt,5] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Qui
oLbCalend:addColumn( TCColumn():New( STR0104 , { || aCalend[oLbCalend:nAt,6] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Sex
oLbCalend:addColumn( TCColumn():New( STR0105 , { || aCalend[oLbCalend:nAt,7] },,,,"CENTER",16,.F.,.F.,,,,.F.,) ) // Sab
oLbCalend:nAT := 1
oLbCalend:SetArray(aCalend)
ACTIVATE DIALOG oCalend CENTERED
Return(aDtSel)
/////////////////////////////////////////////////////////////////
// Tik (selecao) dos dias e alteracao de mes/ano // FGX_CALEND //
/////////////////////////////////////////////////////////////////
Static Function FS_CLICK(cTp,nLin,nCol,aCalend,aDtSel,dDtRef,dDtDM,dDtFM,dDtIni,dDtFin)
Local ni   := 0
Local nj   := 0
Local dDia := dDataBase
If cTp == "DIA"
	If !Empty(aCalend[nLin,nCol])
		If "(" $ aCalend[nLin,nCol]
			aCalend[nLin,nCol] := substr(aCalend[nLin,nCol],3,2)
			dDia := stod(left(dtos(dDtRef),6)+aCalend[nLin,nCol])
			aDel(aDtSel,aScan(aDtSel,dDia))
			aSize(aDtSel,Len(aDtSel)-1)
		Else
			dDia := stod(left(dtos(dDtRef),6)+aCalend[nLin,nCol])
			If dDia < dDtIni .or. dDia > dDtFin
				MsgInfo(STR0106+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0107+" "+Transform(dDtIni,"@D")+" "+STR0009+" "+Transform(dDtFin,"@D"))
			    Return()
			EndIf
			aAdd(aDtSel,dDia)
			aCalend[nLin,nCol] := "( "+aCalend[nLin,nCol]+" )"
		EndIf
	EndIf
Else
	Do Case
		Case cTp == "DANO" // Diminuir Ano
			dDtRef := ctod("01/"+strzero(month(dDtRef),2)+"/"+substr(strzero(year(dDtRef)-1,4),3,2))
		Case cTp == "DMES" // Diminuir Mes
			dDtRef := ctod("01/"+IIf(month(dDtRef)>1,strzero(month(dDtRef)-1,2)+"/"+substr(strzero(year(dDtRef),4),3,2),"12/"+substr(strzero(year(dDtRef)-1,4),3,2)))
		Case cTp == "AMES" // Aumentar Mes
			dDtRef := ctod("01/"+IIf(month(dDtRef)<12,strzero(month(dDtRef)+1,2)+"/"+substr(strzero(year(dDtRef),4),3,2),"01/"+substr(strzero(year(dDtRef)+1,4),3,2)))
		Case cTp == "AANO" // Aumentar Ano
			dDtRef := ctod("01/"+strzero(month(dDtRef),2)+"/"+substr(strzero(year(dDtRef)+1,4),3,2))
	EndCase
	dDtDM := (dDtRef-day(dDtRef)+1)
	dDtFM := ctod("01/"+IIf(month(dDtRef)<12,strzero(month(dDtRef)+1,2)+"/"+substr(strzero(year(dDtRef),4),3,2),"01/"+substr(strzero(year(dDtRef)+1,4),3,2)))-1
	aCalend  := {}
	For ni := 1 to 6
		aAdd(aCalend,{"","","","","","",""})
		If dDtDM <= dDtFM
			nCol := dow(dDtDM)
			For nj := nCol to 7
				If aScan(aDtSel,dDtDM) > 0
					aCalend[ni,nj] := "( "+strzero(day(dDtDM),2)+" )"
				Else
					aCalend[ni,nj] := strzero(day(dDtDM),2)
				EndIf
				dDtDM++
				If dDtDM > dDtFM
					Exit
				EndIf
			Next
		EndIf
	Next
	If cTp <> "0"
		oBMesAno:cCaption := strzero(month(dDtRef),2)+" / "+strzero(year(dDtRef),4)
		oBMesAno:Refresh()
	EndIf
EndIf
If cTp <> "0"
	oLbCalend:SetArray(aCalend)
	oLbCalend:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FGX_AVALCREDº Autor ³ Andre Luis Almeida     º Data ³ 26/08/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao central p/chamada das funcoes de Avaliacao de Credito  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ _cCodCli = Codigo do Cliente que sera verificado o credito    º±±
±±º          ³ _cLojCli = Loja do Cliente que sera verificado o credito      º±±
±±º          ³ _nVlrAva = Valor a ser avaliado para o cliente                º±±
±±º          ³ _lExecFG = Executa FG_AVALCRED ?                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet ( .t. Cliente com Limite OK )                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_AVALCRED(_cCodCli,_cLojCli,_nVlrAva,_lExecFG, _lApi, cNumOsv, nMoeda)
Local lRet       := .t. // Retorno .t. -> Cliente com Limite OK
Local cCreCli    := GetMv("MV_CREDCLI")
Local aValdet    := {}
Local cQuery     := ""  // SQL
Local cFILSE1Where := ""  // SQL
Local lSA1Exclus := ! empty(xFilial("SA1"))
Local cCondNAO   := GetNewPar("MV_MIL0158","") // Condicoes de Pagamento a descosiderar no levantamento dos titulos do Limite de Credito do Cliente. Separar por /
Local nRecVSW    := 0
Local nLimCred   := 0   // Somar no Limite de Credito do Cliente
Local cWherMoeda := ""  // Somente Argentina
Local nTmpSum    := 0   // Somente Argentina
Default _nVlrAva := 0   // Valor a ser avaliado para o cliente
Default _lExecFG := .t. // Executa FG_AVALCRED ?
Default _lApi    := .f.
Default cNumOsv  := ""
Default nMoeda   := 1
//
If lMultMoeda
	cWherMoeda := " E1_MOEDA = 1 AND "
Endif

If lSA1Exclus // SA1 Exclusivo
	cFILSE1Where := "SE1.E1_FILIAL LIKE '" + alltrim(xFilial("SA1")) + "%' AND "
else
	cFILSE1Where := FS_E1FIL()
Endif

If GetNewPar("MV_MIL0045","1") == "0" // Considera Titulos de Veiculos na Avaliacao de Credito do Cliente ?    0-NAO / 1-SIM
	cQuery := "SELECT SUM(SE1.E1_SALDO) VLR FROM "+RetSQLName("SE1")+" SE1 WHERE "
	cQuery += cFILSE1Where
	cQuery += "SE1.E1_CLIENTE='"+_cCodCli+"' AND "
	If cCreCli == "L"
		cQuery += "SE1.E1_LOJA='"+_cLojCli+"' AND "
	EndIf
	cQuery += "SE1.E1_PREFORI='"+GetNewPar("MV_PREFVEI","VEI")+"' AND "
	If lMultMoeda
		cQuery += cWherMoeda
	Endif
	cQuery += "SE1.E1_SALDO > 0 AND "
	cQuery += "SE1.D_E_L_E_T_=' '"
	nLimCred := FM_SQL(cQuery) // Somar valores dos titulos de veiculos no Credito do Cliente
	If lMultMoeda
		If nMoeda <> 1
			nLimCred := FG_MOEDA( nLimCred , 1 , nMoeda )
		Endif
		cQuery := StrTran(cQuery, cWherMoeda, " E1_MOEDA = 2 AND ")
		nTmpSum := FM_SQL(cQuery) // Somar valores dos titulos de veiculos no Credito do Cliente
		If nMoeda <> 2
			nLimCred += FG_MOEDA( nTmpSum , 1 , nMoeda )
		Else
			nLimCred += nTmpSum
		Endif
	Endif
EndIf
//
If !Empty(cCondNAO) // Desconsiderar no Levantamento do Limite de Credito as Condicoes de Pagamento contidas no parametro MV_MIL0158
	If lMultMoeda
		cWherMoeda := " E1_MOEDA = 1 AND "
	Endif
	If len(cCondNAO) > 1 .and. right(cCondNAO,1) == "/"
		cCondNAO := left(cCondNAO,len(cCondNAO)-1)
	EndIf
	cQuery := "SELECT SUM(SE1.E1_SALDO) VLR "
	cQuery += "  FROM "+RetSQLName("SE1")+" SE1 "
	cQuery += "  JOIN "+RetSQLName("SF2")+" SF2 ON "
	cQuery += " SF2.F2_FILIAL=SE1.E1_FILORIG AND "
	cQuery += " SF2.F2_PREFIXO=SE1.E1_PREFIXO AND "
	cQuery += " SF2.F2_DUPL=SE1.E1_NUM AND "
	cQuery += " SF2.F2_CLIENTE=SE1.E1_CLIENTE AND "
	cQuery += " SF2.F2_LOJA=SE1.E1_LOJA AND "
	cQuery += " SF2.F2_PREFORI=SE1.E1_PREFORI AND "
	cQuery += " SF2.F2_COND IN " + FormatIN(cCondNAO,"/") + " AND "
	cQuery += " SF2.D_E_L_E_T_=' ' "
	cQuery += " WHERE "
	cQuery += cFILSE1Where
	cQuery += "SE1.E1_CLIENTE='"+_cCodCli+"' AND "
	If cCreCli == "L"
		cQuery += "SE1.E1_LOJA='"+_cLojCli+"' AND "
	EndIf
	If lMultMoeda
		cQuery += cWherMoeda
	Endif
	cQuery += "SE1.E1_SALDO > 0 AND "
	cQuery += "SE1.D_E_L_E_T_=' '"
	nLimCred += FM_SQL(cQuery) // Somar valores dos titulos de Condicoes de Pagamentos especificas no Credito do Cliente
	If lMultMoeda
		If nMoeda <> 1
			nLimCred := FG_MOEDA( nLimCred , 1 , nMoeda )
		Endif
		cQuery := StrTran(cQuery, cWherMoeda, " E1_MOEDA = 2 AND ")
		nTmpSum := FM_SQL(cQuery) // Somar valores dos titulos de veiculos no Credito do Cliente
		If nMoeda <> 2
			nLimCred += FG_MOEDA( nTmpSum , 1 , nMoeda )
		Else
			nLimCred += nTmpSum
		Endif
	Endif
EndIf
//
If _lExecFG // Executa FG_AVALCRED ?
	_nVlrAva += FG_AVALCRED(_cCodCli,_cLojCli,,,,cNumOsv,nMoeda)
EndIf
//
lRet := MaAvalCred( _cCodCli , _cLojCli , _nVlrAva , If(lMultMoeda, nMoeda, 1) , .T. ,  ,  ,  , nLimCred , @aValdet ) // Chamada da funcao padrao de Limite de Credito ( TOTVS )
//
If !lRet .and. len(aValdet) > 0
	If FM_PILHA("OFIOM020") .or. FM_PILHA("OFIOM030") .or. FM_PILHA("OFIOM140") .or. FM_PILHA("OFIXX100") // OS Requisicoes/Liberacao/Fechamento
		If aValdet[1,1] == "01" // Restricoes
			If !aValdet[1,2,1] .and. aValdet[1,2,2] // Problema somente com Datas Vencidas nos Titulos
				nRecVSW := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VSW")+" WHERE VSW_FILIAL='"+xFilial("VSW")+"' AND VSW_NUMORC='OS"+VO1->VO1_NUMOSV+"' AND VSW_LIBVOO='OS_TOTAL' AND D_E_L_E_T_=' '")
				If nRecVSW <= 0 // Nao existe VSW
					if ! _lApi
						If !FM_PILHA("OFIXX100")
							If MsgYesNo(STR0125,STR0014) // Cliente com Limite de Credito, mas com Titulos vencidos. Deseja solicitar liberacao total da OS? / Atencao
								SA1->(DbSetOrder(1))
								SA1->(MsSeek(xFilial("SA1")+_cCodCli+_cLojCli))
								DBSelectArea("VSW")
								RecLock("VSW",.t.)
								VSW->VSW_FILIAL := xFilial("VSW")
								VSW->VSW_CODCLI := SA1->A1_COD
								VSW->VSW_LOJA   := SA1->A1_LOJA
								VSW->VSW_VALCRE := 0
								VSW->VSW_ORIGEM := FunName()
								VSW->VSW_RISANT := SA1->A1_RISCO
								VSW->VSW_LCANT  := SA1->A1_LC
								VSW->VSW_VLCANT := SA1->A1_VENCLC
								VSW->VSW_USUARI := FM_SQL("SELECT VAI_NOMUSU FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+__cUserID+"' AND D_E_L_E_T_=' '")
								VSW->VSW_DATHOR := Left(Dtoc(dDataBase),6)+Right(STR(Year(dDataBase)),2)+"-"+Left(Time(),5)
								VSW->VSW_NUMORC := "OS"+VO1->VO1_NUMOSV
								VSW->VSW_TIPTEM := ""
								VSW->VSW_LIBVOO := "OS_TOTAL"
								MsUnLock()
							EndIf
						EndIf
					EndIf
                Else // Existe VSW
					DbSelectArea("VSW")
					DbGoTo(nRecVSW)
					If Empty(VSW->VSW_DTHLIB) .and. ! _lApi// Nao esta liberado
						MsgInfo(STR0126,STR0014) // Aguardando liberacao de OS Total. / Atencao
					Else // Ja esta liberado "OS Total"
						lRet := .t. // Liberado!
					EndIf
				EndIf
			ElseIf aValdet[1,2,1] // Problema com valores
				nRecVSW := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VSW")+" WHERE VSW_FILIAL='"+xFilial("VSW")+"' AND VSW_NUMORC='OS"+VO1->VO1_NUMOSV+"' AND VSW_LIBVOO='OS_TOTAL' AND VSW_DTHLIB=' ' AND D_E_L_E_T_=' '")
				If nRecVSW > 0 // Existe VSW nao liberado
					DbSelectArea("VSW")
					DbGoTo(nRecVSW)
					RecLock("VSW",.f.,.t.)
						DbDelete() // Excluir registro OS_TOTAL do VSW, será criado o registro padrao por Valores
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
//
Return lRet


static function FS_E1FIL()
	local cRetSE1SelFil := ""
	Local aSE1Filial
	Local nx

	if oXFA_SQLHelper == NIL
		oXFA_SQLHelper := DMS_SqlHelper():New()
	endif
	aSE1Filial := oXFA_SQLHelper:GetSelectArray("SELECT DISTINCT E1_FILIAL FROM " + RetSqlName( "SE1" ) + " WHERE D_E_L_E_T_ = ' '")

	For nx := 1 to Len(aSE1Filial)
		if nx > 1
			cRetSE1SelFil += ","
		Endif
		cRetSE1SelFil += "'" + Alltrim(aSE1Filial[nx]) + "'"
	Next

	if empty(cRetSE1SelFil)
		cRetSE1SelFil := " SE1.E1_FILIAL = ' ' AND "
	else
		cRetSE1SelFil := " SE1.E1_FILIAL IN (" + cRetSE1SelFil + ") AND "
	endif
return cRetSE1SelFil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_GDVALID º Autor ³ Andre Luis Almeida º Data ³ 12/11/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo na GetDados                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ _cCpo = Nome do Campo a validar                            º±±
±±º          ³ _xVlr = Valor do campo                                     º±±
±±º          ³ _cObj = Nome do Objeto                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºReturn    ³ lRet = Retorno ( .t. / .f. )                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_GDVALID(_cCpo,_xVlr,_cObj)
Local lRet := .t.
Local cSlv := &("M->"+_cCpo)						// Salvar o conteudo do campo
Local oObj := &(_cObj)								// Objeto (GetDados)
Local nPos := FG_POSVAR(_cCpo,_cObj+":aHeader")		// Posicao do campo na aCols (coluna)
/////////////////////////
// Altera Conteudo     //
/////////////////////////
&("M->"+_cCpo):= oObj:aCols[oObj:nAt,nPos] := _xVlr
/////////////////////////
// Executa VALID       //
/////////////////////////
If lRet .and. !Empty(oObj:aHeader[nPos,06])
	lRet := &(Alltrim(oObj:aHeader[nPos,06])) // executa VALID do campo
EndIf
/////////////////////////
// Executa VALIDUSER   //
/////////////////////////
If lRet .and. len(oObj:aHeader[nPos]) >= 15 .and. !Empty(oObj:aHeader[nPos,15]) // VALIDUSER
	lRet := &(Alltrim(oObj:aHeader[nPos,15])) // executa VALIDUSER do campo
EndIf
/////////////////////////
// ERRO Volta Conteudo //
/////////////////////////
If !lRet
	&("M->"+_cCpo):= oObj:aCols[oObj:nAt,nPos] := cSlv
EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_MILSER º Autor ³ Vinicius Gati                                             º Data ³ 21/01/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Sera usada para evitar criacao de 2 versoes de fontes para 2                                     º±±
±±º versoes do protheus diferentes.                                                                             º±±
±±º      nOpcao   -> 1 - Gravacao                                                                               º±±
±±º		 		  -> 2 - retorna "serie real" (DAV)                                                             º±±
±±º		 		  -> 3 - Retorna o nome do campo serie a ser utilizado em Querys                                º±±
±±º		 		  -> 4 - Retorna a Chave de Pesquisa ID ou Serie Real para utilizar em                          º±±
±±º	                    validacoes dbseeks ANTES da gravacao                                                    º±±
±±º		 		  -> 5 - Retorna o CriaVar do campo _SDOC em caso onde o campo _SERIE                           º±±
±±º	                    foi alterado tamanho para 14 para gravar o novo formato                                 º±±
±±º		 		  -> 6 - Retorna o TamSX3 do campo  _SDOC em caso onde o campo _SERIE                           º±±
±±º	                    foi alterado tamanho para 14 para gravar o novo formato                                 º±±
±±º		 		  -> 7 - Retorna o RetTitle do campo _SDOC em caso onde o campo _SERIE                          º±±
±±º	                    foi alterado tamanho para 14 para gravar o novo formato                                 º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_MILSNF(cAlias,nOpcao,cCpoOrig,dEmissao,cEspecie,cSerieGrv,cNewIdPai)
	if lMilSNF
		cReturn := SerieNfId(cAlias,nOpcao,cCpoOrig,dEmissao,cEspecie,cSerieGrv,cNewIdPai)
		if Empty(cReturn) .AND. nOpcao == 3
			Return cCpoOrig
		else
			return cReturn
		end
	else
		Do Case
			Case nOpcao == 1
				&(cAlias+"->"+AllTrim(cCpoOrig)) := cSerieGrv // grava direto como é feito hoje em dia
				return cSerieGrv
			Case nOpcao == 2
				return &(cAlias+"->"+AllTrim(cCpoOrig))
			Case nOpcao == 3
				return cCpoOrig
			Case nOpcao == 4
				return FGX_MILSNF(cAlias, 2 ,cCpoOrig,dEmissao,cEspecie,cSerieGrv,cNewIdPai)
			Case nOpcao == 5
				return CriaVar( ALLTRIM(cCpoOrig) )
			Case nOpcao == 6
				return TamSx3( ALLTRIM(cCpoOrig) )[1]
			Case nOpcao == 7
				return RetTitle( ALLTRIM(cCpoOrig) )
		EndCase
	Endif
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_UFSNF º Autor ³ Vinicius Gati                                              º Data ³ 23/01/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ mostra a serie nova em formato "user friendly" ou amigavel ao usuario                            º±±
±±º	                                                                                                            º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_UFSNF(cSerie)
	if VALTYPE(cSerie) != "C"
		return "   "
	end
Return Transform(cSerie, "!!!")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_PCHTES ºAutor  ³Renato Vinicius     º Data ³  22/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que efetua a pesquisa/alteracao do TES caso informe  º±±
±±º          ³o Tipo de Operacao. (TES Inteligente)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_PCHTES(aIteVei,nLha,cAli)

Local cCliFor := ""
Local cLoja   := ""
Local	nEntSai
Local cTip    := ""
Local nPOSCHASSI := 4
Local cGruVei    := FGX_GrupoVeic() // Grupo do Veiculo

dbSelectArea('VV1')
dbSetOrder(2)
dbSeek(xFilial('VV1') + aIteVei[nLha, nPOSCHASSI] )
cGruVei    := FGX_GrupoVeic(VV1->VV1_CHAINT)

FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

If cAli == "VV0"
	nEntSai := 1
	cTip    := "F"
	DBSelectArea("SA1")
	DBSetOrder(1)
	DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	DBSelectArea("SA2")
	DBSetOrder(3)
	DbSeek(xFilial("SA2")+SA1->A1_CGC)
	DBSetOrder(1)
	cCliFor := SA2->A2_COD
	cLoja   := SA2->A2_LOJA
ElseIf cAli == "VVF"
	nEntSai := 2
	cTip    := "C"
	DBSelectArea("SA2")
	DBSetOrder(1)
	DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	DBSelectArea("SA1")
	DBSetOrder(3)
	DbSeek(xFilial("SA1")+SA2->A2_CGC)
	DBSetOrder(1)
	cCliFor := SA1->A1_COD
	cLoja   := SA1->A1_LOJA
EndIf

MV_PAR02 := If(!Empty(MV_PAR01),MaTesInt(nEntSai,MV_PAR01,cCliFor,cLoja,cTip,SB1->B1_COD),aIteVei[nLha,3])


Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_SUSSA1  º Autor ³ Andre Luis Almeida º Data ³ 24/08/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Conversao do SUS ( Prospect ) em SA1 ( Cliente )           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ _cCodSUS = Codigo Prospect                                 º±±
±±º          ³ _cLojSUS = Loja Prospect                                   º±±
±±º          ³ _lAuto   = Rotina Automatica ?                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_SUSSA1(_cCodSUS,_cLojSUS,_lAuto,_lPosSUS,lRecursivo)
Local lRet       := .t.
Local lPE        := ExistBlock("PESUSSA1")
Local lSUSok := .f.
Default _lPosSUS := .f.
Default _cCodSUS := SUS->US_COD
Default _cLojSUS := SUS->US_LOJA
Default _lAuto   := .f.
Default lRecursivo := .f.

// Chamada pela rotinas do BackOffice...
If lRecursivo == .f. .and. FunName() == "TMKA260"
	lRet := FGX_SUSSA1(,,,,.t.)
	DbSelectArea("SUS")
	Return lRet
EndIf
//

If _lPosSUS .and. !Empty(_cCodSUS+_cLojSUS)
	DbSelectArea("SUS")
	DbSetOrder(1)
	If DbSeek(xFilial("SUS")+_cCodSUS+_cLojSUS) .and. !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
		lSUSok := .t.
	EndIf
EndIf
If !lSUSok
	If FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_SUSSA1", "==" ,"1")
		DbSelectArea("SUS")
		DbSetOrder(1)
		If !Empty(_cCodSUS+_cLojSUS) .and. DbSeek(xFilial("SUS")+_cCodSUS+_cLojSUS)
			If Empty(SUS->US_CODCLI+SUS->US_LOJACLI)

				//Ponto de Entrada tem a finalidade de validar a conversao do Prospect em cliente - Tipo ( 1 = Validação / 2 = Apos conversão )
				If !lPE .or. ExecBlock("PESUSSA1",.f.,.f.,{ "1" , _lAuto , _cCodSUS , _cLojSUS , SUS->US_CODCLI , SUS->US_LOJACLI })
					//
					lRet := Tk273GrvPTC(_cCodSUS,_cLojSUS,_lAuto) // Converter SUS em SA1
					//
					If lRet .and. !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
						If !_lAuto
							MsgInfo(STR0120+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0119+" "+_cCodSUS+"-"+_cLojSUS+CHR(13)+CHR(10)+STR0017+" "+SUS->US_CODCLI+"-"+SUS->US_LOJACLI,STR0014) // Prospect convertido com sucesso! / Prospect / Cliente / Atencao
						EndIf
						if lPE
							//Ponto de Entrada tem a finalidade de validar a conversao do Prospect em cliente - Tipo ( 1 = Validação / 2 = Apos conversão )
							ExecBlock("PESUSSA1",.f.,.f.,{ "2" , _lAuto , _cCodSUS , _cLojSUS , SUS->US_CODCLI , SUS->US_LOJACLI })
						Endif
							//
					EndIf
				Endif
			Else // Possui Cliente relacionado ao Prospect
				lRet := .f.
				If !_lAuto
					MsgStop(STR0121+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0119+" "+_cCodSUS+"-"+_cLojSUS+CHR(13)+CHR(10)+STR0017+" "+SUS->US_CODCLI+"-"+SUS->US_LOJACLI,STR0014) // Impossivel continuar! Prospect já esta relacionado a um Cliente. / Prospect / Cliente / Atencao
				EndIf
			EndIf
		Else
			lRet := .f.
			If !_lAuto
				MsgStop(STR0122,STR0014) // Impossivel continuar! Prospect não encontrado. / Atencao
			EndIf
		EndIf
	Else
		lRet := .f.
		If !_lAuto
			MsgStop(STR0123,STR0014) // Usuario sem permissao para converter o Prospect em Cliente. / Atencao
		EndIf
	EndIf
Endif

DbSelectArea("SUS")
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_LBBROW  º Autor ³ Andre Luis Almeida º Data ³ 06/10/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ListBox montada com SX3 como se fosse MBrowse              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ _cTitulo   = Titulo da Janela                              º±±
±±º          ³ _cAlias    = Alias                                         º±±
±±º          ³ _aOpcoes   = Opcoes para Acoes Relacionadas da Tela        º±±
±±º          ³ _cAndQuery = Query do Filtro                               º±±
±±º          ³ _cOrdemSQL = Ordem do SQL                                  º±±
±±º          ³ _cDtFiltro = Nome do Campo de Data que sera feito o filtro º±±
±±º          ³ _cFuncVld  = Nome da Função de Validação                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_LBBROW(_cTitulo, _cAlias, _aOpcoes, _cAndQuery, _cOrdemSQL, _cDtFiltro, _cFuncVld)
Local aObjects     := {} , aInfo := {}
Local aSizeHalf    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni           := 0
Local nDias        := 0
Local aBotoes      := {}
Local nPosicao     := 2
Local nEspacos     := 0
Local nAjustaCol   := 07 // Ajusta as colunas
Local cCamposNao   := "" // Não mostra os campos

Private aSX3Browse := {}
Private aLBBrowse  := {}
Private dDtIniBrow := dDataBase
Private dDtFinBrow := dDataBase
Private cNFIBrow   := Space(GetSX3Cache("VV0_NUMNFI","X3_TAMANHO"))
Private cSerieBrow := Space(GetSX3Cache("VV0_SERNFI","X3_TAMANHO"))
Private cCodCFBrow := Space(GetSX3Cache("VV0_CODCLI","X3_TAMANHO"))
Private cLojaBrow  := Space(GetSX3Cache("VV0_LOJA","X3_TAMANHO"))
Private cChaBrow   := Space(GetSX3Cache("VV1_CHASSI","X3_TAMANHO"))
Private cChaRBrow  := Space(GetSX3Cache("VV1_CHARED","X3_TAMANHO"))

If cPaisLoc $ "ARG,MEX"
	Private cRemitBrow := Space(GetSX3Cache("VV0_REMITO","X3_TAMANHO"))
	Private cSerReBrow := Space(GetSX3Cache("VV0_SERREM","X3_TAMANHO"))
	// Não mostra os campos
	If _cAlias == "VVF"
		cCamposNao := "VVF_VBAIPI,VVF_ALIIPI,VVF_VALIPI,VVF_VBAICM,VVF_ALIICM,VVF_TOTICM,VVF_ICMRET,VVF_BASCOF,VVF_ALICOF,VVF_VALCOF,VVF_BASPIS,VVF_ALIPIS,VVF_VALPIS"
	EndIf
EndIf

Default _cTitulo   := "MIL"
Default _cAlias    := ""
Default _aOpcoes   := {}
Default _cAndQuery := ""
Default _cOrdemSQL := ""
Default _cDtFiltro := ""
Default _cFuncVld  := ""

If !Empty(_cAlias)
	If !Empty(_cDtFiltro)
		nDias := GetNewPar("MV_MIL0073",1095) // Qtde de Dias a retroagir na DataBase. Será utilizada como Dt.Inicial do filtro na função que substitui o Browse (FGX_LBBROW)
		dDtIniBrow := ( dDataBase - nDias )
	EndIf
	For ni := 1 to len(_aOpcoes)
		aAdd(aBotoes,{"E5",&("{|| FS_LBBROW(_cAlias, 3," + Alltrim(str(ni)) + ", _cAndQuery, _cOrdemSQL, _aOpcoes, .t., _cDtFiltro, _cFuncVld) }"), _aOpcoes[ni,1] } )
	Next

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(_cAlias)
	While !Eof().and.( SX3->X3_ARQUIVO == _cAlias )
		If ( ( X3USO(SX3->X3_USADO) .and. SX3->X3_BROWSE == "S" ) .or. ( "_FILIAL" $ SX3->X3_CAMPO ) ) .and. !AllTrim(SX3->X3_CAMPO) $ cCamposNao // Não mostra os campos
			aAdd(aSX3Browse,{Alltrim(SX3->X3_CAMPO),RetTitle(SX3->X3_CAMPO),SX3->X3_PICTURE,SX3->X3_CONTEXT,SX3->X3_INIBRW,SX3->X3_TAMANHO,"LEFT"})
			If SX3->X3_TIPO == "N"
				If Empty(aSX3Browse[len(aSX3Browse),3]) // SEM PICTURE
					aSX3Browse[len(aSX3Browse),3] := "@E "+repl("9",SX3->X3_TAMANHO)
				EndIf
				If Empty(aSX3Browse[len(aSX3Browse),5]) // SEM INICIALIZADOR DO BROWSE
					aSX3Browse[len(aSX3Browse),5] := "0"
				EndIf
				aSX3Browse[len(aSX3Browse),7] := "RIGHT"
			ElseIf SX3->X3_TIPO == "D"
				aSX3Browse[len(aSX3Browse),3] := "@D"
				If Empty(aSX3Browse[len(aSX3Browse),5]) // SEM INICIALIZADOR DO BROWSE
					aSX3Browse[len(aSX3Browse),5] := "cTod('')"
				EndIf
			Else//If SX3->X3_TIPO == "C"
				aSX3Browse[len(aSX3Browse),3] := "@!"
				If Empty(aSX3Browse[len(aSX3Browse),5]) // SEM INICIALIZADOR DO BROWSE
					aSX3Browse[len(aSX3Browse),5] := ""
				EndIf
			EndIf
			aSX3Browse[len(aSX3Browse),6] := (aSX3Browse[len(aSX3Browse),6]*4)

			// Inserir Chassi Reduzido após Chassi Interno
			If Alltrim(SX3->X3_CAMPO) == "VV0_CHAINT"
			  cRecVV0 := RECNO()
				aAdd(aSX3Browse, {"VV1_CHARED", RetTitle("VV1_CHARED"), GetSX3Cache("VV1_CHARED","X3_PICTURE"),;
					GetSX3Cache("VV1_CHARED","X3_CONTEXT"), GetSX3Cache("VV1_CHARED","X3_INIBRW"), GetSX3Cache("VV1_CHARED","X3_TAMANHO"), "LEFT"})
				DBGOTO(cRecVV0)
			EndIf
		EndIf
		SX3->(DbSkip())
	Enddo
	aAdd(aSX3Browse,{"RECNO","RECNO("+_cAlias+")","@E 9999999999","V","strzero("+_cAlias+"->( RECNO() ),10)",40,"LEFT"})
	//
	FS_LBBROW(_cAlias,1,0,_cAndQuery,_cOrdemSQL,_aOpcoes,.f.,_cDtFiltro) // Levantar Registros
	//
	If len(aLBBrowse) <= 0
		MsgStop(STR0013+" ( "+_cAlias+" )",STR0014) // Nenhum registro encontrado! / Atencao
	Else
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		If !Empty(_cDtFiltro)
			aAdd( aObjects, { 0 , 12 , .T. , .F. } ) // Filtro por Periodo

			If _cAlias == "VV0"
				aAdd( aObjects, { 0 , 12 , .T. , .F. } ) // 2ª Linha - Filtro por Chassi e Chassi Reduzido

				nPosicao := 3
			Else
				nEspacos := 12
			EndIf
		Else
			aAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // Sem Filtro por Periodo
		EndIf
		aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox ( Browse )
		aPosP := MsObjSize( aInfo, aObjects )
		//
		DEFINE MSDIALOG oFGX_LBBROW FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (_cTitulo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
		oFGX_LBBROW:lEscClose := .F.
		If !Empty(_cDtFiltro)
			@ aPosP[1,1]+001 , aPosP[1,2]+005 SAY (Alltrim(RetTitle(Alltrim(_cDtFiltro)))+": ") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Data Movto
			@ aPosP[1,1]+000 , aPosP[1,2]+035 + nAjustaCol MSGET oDtIniBrow VAR dDtIniBrow PICTURE "@D" SIZE 45,09 OF oFGX_LBBROW PIXEL HASBUTTON
			@ aPosP[1,1]+001 , aPosP[1,2]+083 + nAjustaCol SAY STR0009 OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // a
			@ aPosP[1,1]+000 , aPosP[1,2]+092 + nAjustaCol MSGET oDtFinBrow VAR dDtFinBrow PICTURE "@D" SIZE 45,09 OF oFGX_LBBROW PIXEL HASBUTTON

			@ aPosP[1,1]+001 , aPosP[1,2]+149 + nAjustaCol SAY (Alltrim(RetTitle("VV0_NUMNFI")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Nro. Fiscal
			@ aPosP[1,1]+000 , aPosP[1,2]+180 + nAjustaCol MSGET oNFIBrow VAR cNFIBrow PICTURE GetSX3Cache("VV0_NUMNFI","X3_PICTURE") F3 IIf(cPaisLoc == "ARG", Iif(_cAlias == "VV0", "VV0NFA", "VVFNFA"), Iif(_cAlias == "VV0", "SF2", "SF1")) SIZE 55,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow)
			@ aPosP[1,1]+001 , aPosP[1,2]+238 + nAjustaCol SAY (Alltrim(RetTitle("VV0_SERNFI")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Série
			@ aPosP[1,1]+000 , aPosP[1,2]+270 + nAjustaCol MSGET oSerieBrow VAR cSerieBrow PICTURE GetSX3Cache("VV0_SERNFI","X3_PICTURE") SIZE 22,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow) .And. !Empty(cNFIBrow)

			If cPaisLoc $ "ARG,MEX"
				nAjustaCol += 036 // Ajusta as colunas
				@ aPosP[1,1]+001 , aPosP[1,2]+262+005 + nAjustaCol SAY (Alltrim(RetTitle("VV0_REMITO")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Nro. Remito
				@ aPosP[1,1]+000 , aPosP[1,2]+262+033 + nAjustaCol MSGET oRemitBrow VAR cRemitBrow PICTURE GetSX3Cache("VV0_REMITO","X3_PICTURE") F3 Iif(_cAlias == "VV0", "VV0REM", "VVFREM") SIZE 55,09 OF oFGX_LBBROW PIXEL HASBUTTON // WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow)
				@ aPosP[1,1]+001 , aPosP[1,2]+262+093 + nAjustaCol SAY (Alltrim(RetTitle("VV0_SERREM")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Serie Remito
				@ aPosP[1,1]+000 , aPosP[1,2]+262+126 + nAjustaCol MSGET oSerReBrow VAR cSerReBrow PICTURE GetSX3Cache("VV0_SERREM","X3_PICTURE") SIZE 22,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow) .And. !Empty(cRemitBrow)
				nAjustaCol += 123 // Ajusta as colunas
			EndIf

			@ aPosP[1,1]+001 , aPosP[1,2]+298 + nAjustaCol SAY (Alltrim(Iif(_cAlias == "VV0", RetTitle("VV0_CODCLI"), RetTitle("VVF_CODFOR"))) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Cliente / Fornecedor
			@ aPosP[1,1]+000 , aPosP[1,2]+318 + nAjustaCol + nEspacos MSGET oCodCFBrow VAR cCodCFBrow PICTURE GetSX3Cache("VV0_CODCLI","X3_PICTURE") F3 Iif(_cAlias == "VV0", "SA1", "SA2") SIZE 45,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow)

			@ aPosP[1,1]+001 , aPosP[1,2]+375 + nAjustaCol + nEspacos SAY (Alltrim(RetTitle("VV0_LOJA")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Loja
			@ aPosP[1,1]+000 , aPosP[1,2]+406 + nAjustaCol + nEspacos MSGET oLojaBrow VAR cLojaBrow PICTURE GetSX3Cache("VV0_LOJA","X3_PICTURE") SIZE 22,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow) .And. !Empty(cCodCFBrow)

			If _cAlias == "VV0"
				nAjustaCol := 0 // Na segunda linha não precisa ajustar as colunas

				@ aPosP[2,1]+001 , aPosP[2,2]+005 + nAjustaCol SAY (Alltrim(RetTitle("VV1_CHASSI")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Chassi
				@ aPosP[2,1]+000 , aPosP[2,2]+025 + nAjustaCol MSGET oChaBrow VAR cChaBrow PICTURE GetSX3Cache("VV1_CHASSI","X3_PICTURE") F3 "VV1" SIZE 85,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow)

				@ aPosP[2,1]+001 , aPosP[2,2]+119 + nAjustaCol SAY (Alltrim(RetTitle("VV1_CHARED")) + ":") OF oFGX_LBBROW PIXEL COLOR CLR_BLUE // Chassi Reduz
				@ aPosP[2,1]+000 , aPosP[2,2]+156 + nAjustaCol MSGET oChaRBrow VAR cChaRBrow PICTURE GetSX3Cache("VV1_CHARED","X3_PICTURE") SIZE 23,09 OF oFGX_LBBROW PIXEL HASBUTTON WHEN !Empty(dDtIniBrow) .And. !Empty(dDtFinBrow)

				@ aPosP[2,1]+000 , aPosP[2,2]+207 + nAjustaCol BUTTON oBtOK PROMPT STR0011 OF oFGX_LBBROW SIZE 20,11 PIXEL ACTION FS_LBBROW(_cAlias,1,0,_cAndQuery,_cOrdemSQL,_aOpcoes,.t.,_cDtFiltro) // OK
			Else
				@ aPosP[1,1]+000 , aPosP[1,2]+435 + nAjustaCol + nEspacos BUTTON oBtOK PROMPT STR0011 OF oFGX_LBBROW SIZE 20,11 PIXEL ACTION FS_LBBROW(_cAlias,1,0,_cAndQuery,_cOrdemSQL,_aOpcoes,.t.,_cDtFiltro) // OK
			EndIf
		EndIf
		oLBBrowse := TWBrowse():New(aPosP[nPosicao,1]-001,aPosP[nPosicao,2],(aPosP[nPosicao,4]-2),(aPosP[nPosicao,3]-aPosP[nPosicao,1]+3),,,,oFGX_LBBROW,,,,,{ || .T. },,,,,,,.F.,,.T.,,.F.,,,)
		For ni := 1 to len(aSX3Browse)
			oLBBrowse:addColumn( TCColumn():New( aSX3Browse[ni,2] , &("{ || Transform(aLBBrowse[oLBBrowse:nAt,"+Alltrim(str(ni))+"],"+'"'+aSX3Browse[ni,3]+'"'+") }") , , , , aSX3Browse[ni,7] , aSX3Browse[ni,6] , .F. , .F. , , , , .F. , ) )
		Next
		oLBBrowse:nAT := 1
		oLBBrowse:SetArray(aLBBrowse)
		oLBBrowse:bHeaderClick := {|oObj,nCol| FS_LBBROW(_cAlias,2,nCol,_cAndQuery,_cOrdemSQL,_aOpcoes,.t.,_cDtFiltro) , }
		ACTIVATE MSDIALOG oFGX_LBBROW ON INIT EnchoiceBar(oFGX_LBBROW,{ || IIf(FS_LBBROW(_cAlias, 3, 0, _cAndQuery, _cOrdemSQL, _aOpcoes, .t., _cDtFiltro, _cFuncVld),oFGX_LBBROW:End(),.T.) }, { || oFGX_LBBROW:End() },,aBotoes)
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FS_LBBROW   º Autor ³ Andre Luis Almeida º Data ³ 07/10/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao auxiliar do FGX_LBBROW                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º _nTp     ³ 1 = Levantamento de Registros da Tabela (_cAlias)          º±±
±±º          ³ 2 = Ordena Vetor pelo click no Titulo da coluna do ListBox º±±
±±º          ³ 3 = Execucao dos Botoes                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LBBROW(_cAlias, _nTp, _nAux, _cAndQuery, _cOrdemSQL, _aOpcoes, _lRefresh, _cDtFiltro, _cFuncVld)
Local lRet         := .t.
Local cQryAlias    := "SQLBROWSE"
Local cQuery       := ""
Local nRecNo       := 0
Local ni           := 0
Local nQtdCampos   := len(aSX3Browse)
Local oSqlHelp   := DMS_SqlHelper():New()
local cAuxFilVV1 := AllTrim(xFilial("VV1"))

Default _nAux      := 0
Default _cAndQuery := ""
Default _cOrdemSQL := ""
Default _lRefresh  := .f.
Default _cDtFiltro := ""
Default _cFuncVld  := ""

If _nTp == 1 // Levantamento de Registros da Tabela (_cAlias)
	aLBBrowse := {}
	If _cAlias == "VV0" .And. !Empty(_cDtFiltro)
		cQuery := "SELECT VV0.R_E_C_N_O_ RECSQL, VV1.VV1_CHAINT, VV1.VV1_CHARED, VVA.VVA_CHASSI"
		cQuery += " FROM " + RetSqlName("VV0") + " VV0, " + RetSqlName("VVA") + " VVA, " + RetSqlName("VV1") + " VV1"
		cQuery += " WHERE VV0.VV0_FILIAL = VVA.VVA_FILIAL AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA"
		cQuery += " AND VVA.VVA_CHAINT = VV1.VV1_CHAINT"

		if len(cAuxFilVV1) <> 0
			cQuery += " AND "+ oSqlHelp:CompatFunc('SUBSTR') +"(VV1.VV1_FILIAL,1," + cValtoChar(len(cAuxFilVV1)) + ") = "+ oSqlHelp:CompatFunc('SUBSTR') +"(VVA.VVA_FILIAL,1," + cValtoChar(len(cAuxFilVV1)) + ")"
		endif

		cQuery += " AND VV0.D_E_L_E_T_ = ' ' AND VVA.D_E_L_E_T_ = ' ' AND VV1.D_E_L_E_T_ = ' '"
	Else
		cQuery := "SELECT R_E_C_N_O_ RECSQL FROM "+RetSqlName(_cAlias)+" WHERE D_E_L_E_T_=' '"
	EndIf

	If !Empty(_cAndQuery)
		cQuery += " AND "+_cAndQuery
	EndIf

	If !Empty(_cDtFiltro)
		// Período de Datas
		cQuery += " AND "+_cDtFiltro+" >= '"+dtos(dDtIniBrow)+"' AND "+_cDtFiltro+" <= '"+dtos(dDtFinBrow)+"'"

		// Nota Fiscal e Série
		If !Empty(cNFIBrow)
			cQuery += " AND " + _cAlias + "_NUMNFI" + " = '" + cNFIBrow + "'"

			If !Empty(cSerieBrow)
				cQuery += " AND " + _cAlias + "_SERNFI" + " = '"  + cSerieBrow + "'"
			EndIf
		EndIf

		// Cliente e Loja
		If !Empty(cCodCFBrow)
			cQuery += " AND " + Iif(_cAlias == "VV0", "VV0_CODCLI", "VVF_CODFOR") + " = '" + cCodCFBrow + "'"

			If !Empty(cLojaBrow)
				cQuery += " AND " + _cAlias + "_LOJA" + " = '"  + cLojaBrow + "'"
			EndIf
		EndIf

		// Chassi
		If !Empty(cChaBrow)
			cQuery += " AND VV1_CHASSI = '" + cChaBrow + "'"
		EndIf

		// Chassi Reduzido
		If !Empty(cChaRBrow)
			cQuery += " AND VV1_CHARED = '" + cChaRBrow + "'"
		EndIf

		// Remito e Série Remito
		If cPaisLoc $ "ARG,MEX"
			If !Empty(cRemitBrow)
				cQuery += " AND " + _cAlias + "_REMITO" + " = '" + cRemitBrow + "'"

				If !Empty(cSerReBrow)
					cQuery += " AND " + _cAlias + "_SERREM" + " = '"  + cSerReBrow + "'"
				EndIf
			EndIf
		EndIf
	EndIf
	If !Empty(_cOrdemSQL)
		cQuery += " ORDER BY "+_cOrdemSQL
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	While !((cQryAlias)->(Eof()))
		DbSelectArea( _cAlias )
		DbGoTo( ( cQryAlias )->( RECSQL ) ) // Posiciona no Registro do Arquivo
		aAdd(aLBBrowse,array( nQtdCampos ))
		For ni := 1 to nQtdCampos
			If _cAlias == "VV0" .And. aSX3Browse[ni,1] $ "VV0_CHAINT/VV1_CHARED/VV0_CHASSI/VV0_TPFATR"
				If aSX3Browse[ni,1] == "VV0_TPFATR"
					aLBBrowse[len(aLBBrowse),ni] := X3CBOXDESC("VV0_TPFATR",(_cAlias)->(VV0_TPFATR))
				ElseIf aSX3Browse[ni,1] == "VV0_CHASSI"
					aLBBrowse[len(aLBBrowse),ni] := Alltrim((cQryAlias)->(VVA_CHASSI))
				Else
					If aSX3Browse[ni,1] == "VV0_CHAINT"
						aLBBrowse[len(aLBBrowse),ni] := Alltrim((cQryAlias)->(VV1_CHAINT))
					Else
						aLBBrowse[len(aLBBrowse),ni] := Alltrim((cQryAlias)->(VV1_CHARED))
					EndIf
				Endif
			ElseIf _cAlias == "VVF" .And. aSX3Browse[ni,1] $ "VVF_TPFATR"
				If aSX3Browse[ni,1] == "VVF_TPFATR"
					aLBBrowse[len(aLBBrowse),ni] := X3CBOXDESC("VVF_TPFATR",(_cAlias)->(VVF_TPFATR))
				EndIf
			ElseIf aSX3Browse[ni,4] <> "V" // Campo REAL
				aLBBrowse[len(aLBBrowse),ni] := &(_cAlias+"->"+aSX3Browse[ni,1])
			Else
				aLBBrowse[len(aLBBrowse),ni] := &(aSX3Browse[ni,5])
			EndIf
		Next
		(cQryAlias)->( DbSkip() )
	EndDo
	( cQryAlias )->( dbCloseArea() )
	If len(aLBBrowse) <= 0
		aAdd(aLBBrowse,array( nQtdCampos ))
		aLBBrowse[1,nQtdCampos] := strzero(0,10)
	EndIf
	DbSelectArea( _cAlias )
	If _lRefresh
		oLBBrowse:nAT := 1
		oLBBrowse:SetArray(aLBBrowse)
		oLBBrowse:Refresh()
	EndIf
ElseIf _nTp == 2 // Ordena Vetor pelo click na coluna do ListBox
	Asort(aLBBrowse,,,{|x,y| x[_nAux] < y[_nAux] })
	If _lRefresh
		oLBBrowse:Refresh()
	EndIf
ElseIf _nTp == 3 // Execucao dos Botoes
	lRet := .f.
	DbSelectArea(_cAlias)
	nRecNo := val(aLBBrowse[oLBBrowse:nAt,len(aLBBrowse[oLBBrowse:nAt])])
	If nRecNo > 0
		DbGoTo(nRecNo)
		lRet := .t.

		// Função de Validação Padrão
		If !Empty(_cFuncVld)
			lRet := &(_cFuncVld + "(aSX3Browse, aLBBrowse," + Str(oLBBrowse:nAt) + ")")
		EndIf

		If lRet
			If _nAux == 0
				If len(_aOpcoes) == 1
					_nAux := 1
				Else
					nLinha := 7
					DEFINE MSDIALOG oDlgOpcoes TITLE STR0127 From 00 , 00 TO ( len(_aOpcoes) * 34 ) + 20 , 162 PIXEL // Opcoes
					For ni := 1 to len(_aOpcoes)
						tButton():New(nLinha,007,_aOpcoes[ni,1],oDlgOpcoes, &("{ || (_nAux:="+Alltrim(str(ni))+",oDlgOpcoes:End())  }") , 70 , 12 ,,,,.T.,,,,{ || .t. })	// Botoes
						nLinha += 17
					Next
					ACTIVATE MSDIALOG oDlgOpcoes CENTER
				EndIf
			EndIf
			If _nAux > 0
				If &(_aOpcoes[_nAux,2]) // Executa Opcao
					FS_LBBROW(_cAlias,1,0,_cAndQuery,_cOrdemSQL,_aOpcoes,.t.,_cDtFiltro) // Levantar Registros
					lRet := .t.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FGX_STATF2  º Autor ³ Manoel/Rubens      º Data ³ 11/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Verifica se a NF pode ser ou foi excluida quando cliente   º±±
±±º          ³ possui Totvs Colaboração                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_STATF2(cOpcao,cSerie,cNumero,cCliFor,cLJClFo,cTipo, lAgendado)

Local cQuery := ""
Local cQueryJob := ""
Local cQryAlias := "SQLSF2DEL"
Local cRet := ""

Default lAgendado := .f.

If cTipo == "S" // saida
	cQuery := "SELECT SF2.F2_STATUS"
	cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
	cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery +=   " AND SF2.F2_DOC='"+cNumero+"'"
	cQuery +=   " AND SF2.F2_SERIE = '"+cSerie+"'"
	cQuery +=   " AND SF2.F2_CLIENTE='"+cCliFor+"'"
	cQuery +=   " AND SF2.F2_LOJA = '"+cLJClFo+"'"
	cQuery +=   " AND SF2.D_E_L_E_T_=' ' "
EndIf

If cOpcao == "D" // verifica se NF foi Deletada
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	If (cQryAlias)->(eof())
		cRet := "T"
	EndIf
	(cQryAlias)->(DbCloseArea())
EndIf

If cOpcao == "J"
	cQueryJob := cQuery
	cQueryJob += " AND SF2.F2_STATUS <> '   ' " // Ja foi gerado JOB para cancelamento...
	cQueryJob += " AND SF2.F2_STATUS <> '015' " // Diferente de Foi autorizado a solicitacao de cancelamento da NFe
	cQueryJob += " AND SF2.F2_STATUS <> '030' " // Diferente de Inutilizacao de numeracao autorizada
	cQueryJob += " AND SF2.F2_STATUS <> '036' " // Diferente de Cancelamento autorizado fora do prazo
	cQueryJob += " AND SF2.F2_STATUS <> '026' " // Diferente de Cancelamento Não Autorizado
	If !Empty(FM_SQL(cQueryJob))
		lAgendado := .t.
		cOpcao := "V"
	EndIf
EndIf

If cOpcao == "V"
	Processa( { || cRet := FGX_CONSF2( cQuery ) } , "Consulta NF-e" , "" , .f. )
Endif

Return (cRet == "T")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FGX_CONSF2  º Autor ³ Manoel/Rubens      º Data ³ 11/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Verifica STATUS da Nota Fiscal ou se ja foi excluida pelo  º±±
±±º          ³ JOB do Totvs Colaboração                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGX_CONSF2(cQuery)
Local cQryAlias := "TNFE"
Local cRet := ""
Local nCont := 1
Local nMaxCont := 40
ProcRegua(1)
conout("FGX_CONSF2 - INICIO DA VERIFICACAO DO F2_STATUS:  "+Dtoc(dDataBase)+" - "+Time())
While cRet == ""
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	conout("FGX_CONSF2 - VERIFICANDO DO F2_STATUS:  " + (cQryAlias)->F2_STATUS + " - " +Dtoc(dDataBase) + " - " + Time() + " " + Str(nCont,2))
	If (cQryAlias)->(Eof())
		cRet := "T"
	Else
		IncProc(STR0139 + ": " + (cQryAlias)->F2_STATUS + " " + STR0140 + ": " + Str(nCont,2)) // Status da Nota Fiscal # Tentativa
		If (cQryAlias)->F2_STATUS == "026"
			MsgInfo(STR0124,STR0014) // "Cancelamento não autorizado." // Atencao
			cRet := "F"
		Else
			Sleep( 10000 )
			nCont ++
			If nCont > nMaxCont .and. (cQryAlias)->F2_STATUS == "025"
				MsgInfo(STR0141,STR0014) // "Cancelamento agendado. Verifique o status no monitor da NF-e Sefaz." # Atencao
				cRet := "F"
			EndIf
		EndIf
	EndIf
	(cQryAlias)->(DbCloseArea())
End
conout("FGX_CONSF2 - RETORNO DA FUNCAO - [" + cRet + "] VERIFICANDO DO F2_STATUS:  "+Dtoc(dDataBase)+" - "+Time())
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FGX_SC5BLQ  º Autor ³ Andre Luis Almeida º Data ³ 06/10/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Verifica se o SC5 ( PEDIDO ) esta bloqueado                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_SC5BLQ(cNumPed,lMsg)
Local lRet   := .t.
Default lMsg := .t.
SC5->(DbSetOrder(1))
If SC5->(MsSeek(xFilial("SC5")+cNumPed))
	If SC5->C5_BLQ == "1"
		lRet := .f.
		If lMsg
			MsgStop(STR0129,STR0014) // Pedido está bloqueado por Regra! O processo será abortado! Favor verificar! / Atencao
		EndIf
	ElseIf SC5->C5_BLQ == "2"
		lRet := .f.
		If lMsg
			MsgStop(STR0130,STR0014) // Pedido está bloqueado por Verba! O processo será abortado! Favor verificar! / Atencao
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FGX_SC5BLQ  º Autor ³ Fernando V. Cavani º Data ³ 07/02/18 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Validação de Tipo de Atendimento ao Tipo de Tempo          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGX_VOITPATEN(cTipAte,cTipTem,lMsg)
Local lConsidera := .f.

Default cTipAte := ""
Default cTipTem := ""
Default lMsg 	:= .t.

If VOI->(FieldPos("VOI_CONVCP")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ))
	If VOI->VOI_CONVCP == "1"
		lConsidera := .t.
	EndIf
EndIf

If !lConsidera
	Return(.t.)
EndIf

// Peças ou Serviços
cQuery := "SELECT VCP.R_E_C_N_O_ "
cQuery += "FROM " + RetSqlName("VCP") + " VCP "
cQuery += "WHERE VCP.VCP_FILIAL = '" + xFilial("VCP") + "' "
cQuery +=   "AND VCP.VCP_TPATEN = '" + cTipAte +"' "
cQuery +=   "AND VCP.VCP_TIPTEM = '" + cTipTem +"' "
cQuery +=   "AND VCP.D_E_L_E_T_ = ' ' "

nRecVCP := FM_SQL(cQuery)

If nRecVCP == 0
	If lMsg
		Help(1,"  ","TPTEMATE")
	EndIf

	Return(.f.)
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FGX_VIMEMO º Autor ³ Fernando Vitor Cavani  º Data ³ 09/04/18 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualização dos dados de colunas Memo que existam no grid    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGX_VIMEMO(aCabDados, aIteDados, nColPos, nLinPos)
	Aviso(aCabDados[nColPos - 1, 1], aIteDados[nLinPos, nColPos], { "Ok" }, 3)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ ReportDef ³ Autor ³ Fernando Vitor Cavani  ³ Data ³ 09/04/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Definicoes do oReport (linhas/colunas/totalizadores)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(_cNomArq, _cTitulo, _aIntCab, _aIntIte)
Local nk := 0

Local oSection

// oReport
oReport := TReport():New(_cNomArq, _cTitulo,, {|oReport| FGX_REPORT(oReport, _aIntCab, _aIntIte)})

// Cabeçalho
oSection := TRSection():New(oReport, _cNomArq)

For nk := 1 to Len(_aIntCab)
	If _aIntCab[nk,2] <> "M" // Não imprime campos tipo Memo (sem suporte)
		TRCell():New(oSection, _aIntCab[nk,1] + Str(nk), "", _aIntCab[nk,1], _aIntCab[nk,4], _aIntCab[nk,3],, /*{|| dados }*/,,, Iif(_aIntCab[nk,2] <> "N", "LEFT", "RIGHT"), .t.)
	EndIf
Next
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ FGX_REPORT ³ Autor ³ Fernando Vitor Cavani  ³ Data ³ 09/04/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao While/For com chamadas de PrintLine (TREPORT)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGX_REPORT(oReport, _aIntCab, _aIntIte)
Local ni := 0
Local nj := 0

Local oSection := oReport:Section(1)

oSection:Init()

For ni := 1 to len(_aIntIte)
	If _aIntIte[ni,1]
		For nj := 2 to len(_aIntIte[ni])
			If _aIntCab[nj - 1,2] == "C"
				oSection:Cell(_aIntCab[nj - 1,1] + Str(nj - 1)):SetValue(Transform(_aIntIte[ni,nj], _aIntCab[nj - 1,4]))
			ElseIf _aIntCab[nj - 1,2] == "L"
				oSection:Cell(_aIntCab[nj - 1,1] + Str(nj - 1)):SetValue(Iif(_aIntIte[ni,nj], ".T.", ".F."))
			ElseIf _aIntCab[nj - 1,2] $ "N/D"
				oSection:Cell(_aIntCab[nj - 1,1] + Str(nj- 1)):SetValue(_aIntIte[ni,nj])
			EndIf // Não imprime campos tipo Memo (sem suporte)
		Next

		oSection:PrintLine() // Imprimir Seção 1
	EndIf
Next

oSection:Finish()
Return


/*/{Protheus.doc} FGX_VV2SB1
Posiciona na SB1 referente ao produto informado no modelo do veículo (VV2_PRODUT)
@author Rubens
@since 12/12/2018
@version 1.0
@return lRetorno, Indica se foi possivel posicionar na SB1
@param cParCodMar, characters, Código da Marca (Conteúdo padrão VV1_CODMAR)
@param cParModVei, characters, Código do Modelo do Veículo (Conteúdo padrão VV1_MODVEI)
@param cParSegMod, characters, Código do Segmento do Modelo (Conteúdo padrão VV1_SEGMOD)
@type function
/*/
FUNCTION FGX_VV2SB1(cParCodMar, cParModVei, cParSegMod)

	Local lRetorno := .f.

	Default cParCodMar := VV1->VV1_CODMAR
	Default cParModVei := VV1->VV1_MODVEI
	Default cParSegMod := VV1->VV1_SEGMOD

	VV2->(DBSetOrder(1))
	lRetorno := VV2->(MsSeek(xFilial("VV2") + cParCodMar + cParModVei + cParSegMod))

	If lRetorno
		If Empty(VV2->VV2_PRODUT)
			lRetorno := .f.
		Else
			SB1->(dbSetOrder(1))
			lRetorno := SB1->(MsSeek(xFilial("SB1")+VV2->VV2_PRODUT))
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} FGX_VV2
Posiciona na VV2
@author Rubens
@since 12/12/2018
@version 1.0
@return lRetorno, Indica se foi possivel posicionar na VV2
@param cParCodMar, characters, Código da Marca (Conteúdo padrão VV1_CODMAR)
@param cParModVei, characters, Código do Modelo do Veículo (Conteúdo padrão VV1_MODVEI)
@param cParSegMod, characters, Código do Segmento do Modelo (Conteúdo padrão VV1_SEGMOD)
@type function
/*/
FUNCTION FGX_VV2(cParCodMar, cParModVei, cParSegMod)

	Local lRetorno := .f.

	Default cParCodMar := VV1->VV1_CODMAR
	Default cParModVei := VV1->VV1_MODVEI
	Default cParSegMod := VV1->VV1_SEGMOD

	VV2->(DBSetOrder(1))
	lRetorno := VV2->(MsSeek(xFilial("VV2") + cParCodMar + cParModVei + cParSegMod ))

Return lRetorno

/*/{Protheus.doc} FGX_VV1SB1
Posiciona o arquivo SB1 relacionado ao Veiculo passado como parametro

@author Rubens
@since 12/12/2018
@version 1.0
@return lRetorno, Indica se foi possivel posicionar na SB1
@param cCpoChave, characters, [CHAINT] posiciona VV1 por VV1_CHAINT / [CHASSI/ posiciona VV1 por VV1_CHASSI
@param cChave, characters, Chave de pesquisa na VV1
@param cMVMIL0010, characters, Conteudo do parametro MV_MIL0010 (Não obrigatorio)
@param cAuxGruVei, characters, Grupo para pesquisa na VV1 (Não obrigatorio)
@type function
/*/
FUNCTION FGX_VV1SB1(cCpoChave, cChave, cMVMIL0010 , cAuxGruVei )

	Local lRetorno := .f.
	Local lPesqVV1 := .t.

	Default cMVMIL0010 := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
	Default cAuxGruVei := ""

	Do Case
	Case cCpoChave == "CHAINT"
		If VV1->VV1_CHAINT == cChave
			lPesqVV1 := .f.
			lRetorno := .t.
		Else
			VV1->(DBSetOrder(1))
		EndIf
	Case cCpoChave == "CHASSI"
		If VV1->VV1_CHASSI == cChave
			lPesqVV1 := .f.
			lRetorno := .t.
		Else
			VV1->(DBSetOrder(2))
		EndIf
	EndCase

	If lPesqVV1
		lRetorno := VV1->( DBSeek( xFilial("VV1")+ cChave ))
	EndIf

	If lRetorno
		If cMVMIL0010 == "1" // SB1 Agrupado por MODELO
			lRetorno := FGX_VV2SB1(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
		Else
			lRetorno := FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
			If lRetorno
				If Empty(cAuxGruVei)
					cAuxGruVei := FGX_GrupoVeic(VV1->VV1_CHAINT)
				EndIf
				SB1->(dbSetOrder(7))
				lRetorno := SB1->(dbSeek(xFilial("SB1") + cAuxGruVei + VV1->VV1_CHAINT ))
			EndIf
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} FGX_SetVlJson
	Adiciona o conteudo de uma TAG Json.
	Se estiver vazio joga NIL

	@type function
	@author Rubens Takahashi
	@since 10/01/2022
/*/
Function FGX_SetVlJson(cAuxValue, lUTF8)
	DEFAULT lUTF8 := .f.

	do case
	case empty( cAuxValue )
		return nil
	case lUTF8
		return alltrim(encodeUtf8(cAuxValue))
	endcase
Return alltrim(cAuxValue)

/*/{Protheus.doc} FGX_GetFromSoJson
	Adiciona o conteudo de uma TAG Json.
	Se estiver vazio joga NIL

	@type function
	@author Rubens Takahashi
	@since 10/01/2022
/*/
Function FGX_GetFromSoJson(cValue)
	if cValue == nil
		return cValue
	endif
	cValue := DecodeUTF8(cValue)
return alltrim(cValue)

/*/{Protheus.doc} FGX_Timestamp
	Retorna timestamp no padrao definido por vinicius e rubens de gravacao de timestamp
	para bases protheus.
	A decisão foi tomada levando em consideração tamanho da base relacionado com o campo string
	do protheus além do fuso horário.

	@type function
	@author Vinicius Gati
	@since 22/08/2019
/*/
Function FGX_Timestamp(cTimeStamp)
	default cTimeStamp := fwtimestamp(6)
return LEFT(strtran(strtran(strtran(cTimeStamp, '-', ''), 'T', ''), ':', ''), 14)

/*/{Protheus.doc} FGX_ToTimestamp
	Pega o formato de timestamp que vamos gravar com 14 c e converte para o formato padrão
	do fwtimestamp de 20 caracteres

	@type function
	@author Vinicius Gati
	@since 22/08/2019
/*/
Function FGX_ToTimestamp(cData)
	local nX := 1
	local cRet := ''
	For nX := 1 to Len(cData)
		If nX == 5 .or. nX == 7
			cRet += '-'
		elseif nX == 9
			cRet += 'T'
		elseif nX == 11 .or. nX == 13
			cRet += ':'
		endif
		cRet += substr(cData, nX, 1)
	Next
	cRet += 'Z'
return cRet

/*/{Protheus.doc} FGX_ToTimestamp
	Pega o formato de timestamp que vamos gravar com 14 c e converte para o formato padrão
	do fwtimestamp de 20 caracteres

	@type function
	@author Vinicius Gati
	@since 22/08/2019
/*/
Function FGX_ConvFoneToProtheus(cTel)
	local oRet := JsonObject():New()
	oRet["TEL"] := ""
	oRet["DDD"] := ""
	if valtype(cTel) == "U"
		return oRet
	endif
	cTel := STRTRAN(cTel, "(", "")
	cTel := STRTRAN(cTel, ")", "")
	cTel := STRTRAN(cTel, " ", "")
	if LEN( ALLTRIM(cTel) ) == 8 .OR. LEN( ALLTRIM(cTel) ) == 9
		oRet["TEL"] := cTel
	elseIf LEN( ALLTRIM(cTel) ) == 10
		oRet["TEL"] := RIGHT( cTel, 8)
		oRet["DDD"] := LEFT( cTel , 2 )
	elseIf ! Empty( cTel )
		oRet["TEL"] := RIGHT( cTel, LEN(cTel)-2 )
		oRet["DDD"] := LEFT( cTel , 2 )
	endIf
return oRet

/*/{Protheus.doc} FGX_CtoArr
	(long_description)
	@type  Function
	@author Vinicius Gati
	@since 01/07/2021
	@version 1.0
	@param cToConv, Charactere, vai pegar string e quebrar por espaco e transformar em array
	@return return, Array, o array com os valores
	@example FGX_CtoArr("banana maca alface batata") => {"banana", "maca", "alface", "batata"}
/*/
Function FGX_CtoArr(cToConv)
Return STRTOKARR(cToConv, " ")

/*/{Protheus.doc} FGX_ConcJsonAttrs
	Função para ajudar a concatenar valores de um json com tranquilidade de ser null safe

	@type  Function
	@author Vinicius Gati
	@since 01/07/2021
	@version 1.0
	@param aAttrs, array, atributos para concatenar
	@param jJson, JsonObject, the object with data
	@return return, charactere, the charactere with the concatenated data
/*/
Function FGX_ConcJsonAttrs(aAttrs, jJson)
	local cConcat := ""
	local nX := 1
	local cAttr
	For nX:= 1 to Len(aAttrs)
		cAttr := aAttrs[nX]
		if empty(cAttr)
			loop
		endif

		if jJson:hasProperty(cAttr)
			uVal := jJson[cAttr]
			if valtype(uVal) == "U"
				loop
			else
				if ! empty(uVal)
					cConcat += " "
				endif
				cConcat += cValToChar(uVal)
			endif
		endif
	Next
Return cConcat

/*/{Protheus.doc} FGX_UltKil
	(long_description)
	@type  Function
	@author Alecsandre Ferreira
	@since 01/07/2022
	@version 1.0
	@param cChaInt, cChassi, cCpo
	@return Array, Última Kilometragem[1], Última Hora Trilha[2]
/*/
Function FGX_UltKil(cChaInt, cChassi, cCpo)
	Local nKmUltTri := 0
	Local cQuery := ""
	Default cChaInt := ""

	If Empty(cChaInt) .AND. Empty(cChassi)
		Return nKmUltTri
	Endif

	cQuery := " SELECT "
	cQuery +=      Iif(cCpo == "K", "VO0_KILOME", "VO0_HORTRI") + " KM_ULTTRI "
	cQuery += " FROM "
	cQuery +=      RetSqlName("VV1") + " VV1 JOIN " + RetSqlName("VO0") + " VO0 "
	cQuery += " 	ON "
	cQuery +=      " VO0.VO0_FILIAL = '" + xFilial("VO0") + "'"
	cQuery +=      " AND VO0.VO0_CHAINT = VV1.VV1_CHAINT "
	cQuery +=      " AND VO0.D_E_L_E_T_ = '' "
	cQuery += " WHERE "
	cQuery += " 	VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
	If !Empty(cChaint)
		cQuery += " 	AND VV1.VV1_CHAINT = '" + cChaint + "' "
	Else
		cQuery += " 	AND VV1.VV1_CHASSI = '" + cChassi + "' "
	Endif
	cQuery += "  AND VV1.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY "
	cQuery += " 	VO0_DATA DESC, "
	cQuery += " 	VO0_HORA DESC "

	nKmUltTri := FM_SQL(cQuery)
Return nKmUltTri

/*/{Protheus.doc} FGX_VV1VC3
	Verifica a existência de Frota(VC3) relacionada ao Veiculo(VV1) e retorna o Recno do VC3
	@type Function
	@author Alecsandre Ferreira
	@since 04/07/2022
	@version 1.0
	@param cChaInt, cChassi
	@return nRecnoVC3
/*/
Function FGX_VV1VC3(cChaInt, cChassi)
	Local cQuery := ""
	Local nRecnoVC3
	Local lChaInt

	DBSelectArea("VC3")
	lChaInt := FieldPos("VC3_CHAINT") > 0

	cQuery := " SELECT "
	cQuery += " 	R_E_C_N_O_ Recno "
	cQuery += " FROM "
	cQuery += " 	" + RetSqlName("VC3") + " VC3 "
	cQuery += " WHERE "
	cQuery += " 	VC3.VC3_FILIAL = '" + xFilial("VC3") + "' "
	cQuery += " 	AND " + Iif(lChaInt,;
		"(VC3.VC3_CHASSI = '" + cChassi + "' OR VC3.VC3_CHAINT = '" + cChaInt + "')",;
		"VC3.VC3_CHASSI = '" + cChassi + "' ")
	cQuery += " 	AND VC3.D_E_L_E_T_ = '' "

	nRecnoVC3 := FM_SQL(cQuery)
Return nRecnoVC3

/*/{Protheus.doc} FGX_GRVSA1()

	@type Function
	@author Renato Vinicius
	@since 19/08/2022
	@version 1.0
	@param aCpoSA1
	@return
/*/
Function FGX_GRVSA1( lInclusao , aCpoSA1 )

	Local ni  := 0
	Local nOp := 0
	Local oModSA1
	Local lMVCAuto := .f.

	Default aCpoSA1 := {}

	If GetNewPar("MV_MIL0186",.f.) == .t. .and. Len(aCpoSA1) > 0

		Private aRotina := {}

		conout(STR0153)	// "Gravação atraves de MVC"

		if lInclusao
			nOp := 3
		Else // Alteração
			nOp := 4
		EndIf

		oModSA1 := FWLoadModel("CRMA980")
		lMVCAuto := FwMvcRotAuto(oModSA1,"SA1",nOp,{ {"SA1MASTER",aCpoSA1} },/*lSeek*/ .f. ,.f.)
		if ! lMVCAuto
			MostraErro()
		endif
		oModSA1:DeActivate()

	Else

		conout(STR0154)	// "Gravação atraves de RECNO"

		SA1->(RecLock( "SA1", lInclusao ))

		For ni := 1 to Len(aCpoSA1)
			conout('CAMPO ' + aCpoSA1[ ni,1 ] + ' := ' + aCpoSA1[ ni,2 ] )
			&("SA1->" + aCpoSA1[ ni,1 ] + ':= "' + aCpoSA1[ ni,2 ] + '"')
		Next

		SA1->(MsUnLock())

	EndIf

Return

/*/{Protheus.doc} FGX_DTHEMI
	Função para retornar a Data/Hora GMT que será gravado nos campos _DTHEMI
	Exemplo de formato: 20/06/23/14:05:36

	@author Andre Luis Almeida
	@since 23/06/2023
	@return return, charactere, "Dia / Mes / Ano (2 posicoes) / Hora:Minuto:Segundo GMT"
	/*/
Function FGX_DTHEMI()
Local cRet := ""
Local cGMT := fwtimestamp(6)
cRet += substr(cGMT, 9,2)+"/" // Dia /
cRet += substr(cGMT, 6,2)+"/" // Mes /
cRet += substr(cGMT, 3,2)+"/" // Ano (2 posições) /
cRet += substr(cGMT,12,8)     // Hora:Minuto:Segundo GMT
Return cRet

/*/{Protheus.doc} FGX_RETCON
	Função para retorna a condicao de pagto ref. a veiculo/oficina

	@author Renato Santos
	@since 10/11/2023
	@return return, charactere
	/*/
Function FGX_RETCON()

	Local cReturn:='   '

	Local lE4_MSBLQL := SE4->(FieldPos("E4_MSBLQL")) > 0

	cSQL := "SELECT E4_CODIGO "
	cSQL += " FROM " + RetSQLName("SE4") + " SE4 "
	cSQL += " WHERE SE4.E4_FILIAL = '" + xFilial("SE4") + "'"
	cSQL += "  AND SE4.E4_TIPO = 'A' "
	cSQL += Iif(lE4_MSBLQL, "  AND SE4.E4_MSBLQL <> '1'", "")
	cSQL += "  AND SE4.D_E_L_E_T_ = ' '"

	cReturn := FM_SQL(cSQL)

	If Empty(cReturn)
		HELP(" ",1,"NCONDVEI")
	EndIf

Return cReturn

/*/{Protheus.doc} FGX_JsonToText
Retorna String JSON com tags ordenadas
@type function
@version 1.0
@author cristiamRossi
@since 12/29/2023
@param oJson, object, objeto JSON
@param nTTL, numeric, time to live (evitar loop em recursão)
@return character, string json com tags ordenadas
/*/
function FGX_JsonToText( oJson, nTTL )
local   cRet := "{"
local   nI
local   aNames
local   cKey
local   keyVal
local   keyType
default nTTL := 10

	if --nTTL < 0
		cRet += "}"
		return cRet
	endif

	aNames := oJson:GetNames()
	aSort( aNames,,,{|a,b| upper(a) < upper(b)} )

	for nI := 1 to len( aNames )
		if nI > 1
			cRet += ","
		endif

		cKey := aNames[nI]
		cRet += '"' + cKey + '":'

		oJson:GetJsonValue(cKey, @keyVal, @keyType)
		do case
			case keyType == "A"
				cRet += FGX_ArrayToText( keyVal, nTTL )
			case keyType $ "C;M"
				cRet += '"' + strTran( alltrim( keyVal ), CRLF, "\r\n") + '"'
			case keyType == "D"
				cRet += '"' + FWTimeStamp(6, keyVal, "00:00:00") + '"'
			case keyType == "L"
				cRet += iif( keyVal, "true", "false" )
			case keyType == "N"
				cRet += cValToChar( keyVal )
			case keyType == "J"
				cRet += FGX_JsonToText( keyVal, nTTL )
			otherwise
				cRet += 'null'
		end case
	next

	cRet += "}"
return cRet


/*/{Protheus.doc} FGX_ArrayToText
Retorna Array em string (rotina auxiliar de FGX_JsonToText)
função padrão da TOTVS não converte elementos complexos e a Data fica em formato dd/mm/yy
@type function
@version 1.0
@author cristiamRossi
@since 12/29/2023
@param aDados, object, objeto ARRAY
@param nTTL, numeric, time to live (evitar loop em recursão)
@return character, string com elementos
/*/
function FGX_ArrayToText( aDados, nTTL )
local   cRet   := "["
local   nI
local   keyType
private keyVal
default nTTL   := 10

	if --nTTL < 0
		cRet += "]"
		return cRet
	endif

	for nI := 1 to len( aDados )
		if nI > 1
			cRet += ","
		endif

		keyVal  := aDados[nI]
		keyType := valType( keyVal )

		do case
			case keyType == "A"
				cRet += FGX_ArrayToText( keyVal, nTTL )
			case keyType $ "C;M"
				cRet += '"' + alltrim( keyVal ) + '"'
			case keyType == "D"
				cRet += '"' + FWTimeStamp(6, keyVal, "00:00:00") + '"'
			case keyType == "L"
				cRet += iif( keyVal, "true", "false" )
			case keyType == "N"
				cRet += cValToChar( keyVal )
			case keyType == "J"
				cRet += FGX_JsonToText( keyVal, nTTL )
			otherwise
				cRet += 'null'
		end case
	next

	cRet += "]"
return cRet


/*/{Protheus.doc} FGX_JSONform
Formata uma string JSON modo Pretty
@type function
@version 1.0
@author Cristiam
@since 18/04/2021
@param cJSON, character, String JSON
@param lQuiet, logical, não exibir mensagens popup
@param cErro, character, passada por referência para obter uma descrição de erro
@param lOrdena, logical, se ordena o JSON por TAG
@return character, String JSON pretty format
/*/
function FGX_JSONform( cJSON, lQuiet, cErro, lOrdena )
local   cMsg
local   cNewMsg := ""
local   nAspas  := 0
local   nRecuo  := 0
local   nI
local   oJSON   := JsonObject():New()
default cJSON   := ""
default lQuiet  := .F.
default cErro   := ""
default lOrdena := .T.

// Validação JSON de entrada

    cMsg := alltrim( cJSON )

    if empty( cMsg )
        cErro := "JSONform: string vazia"
        if ! lQuiet
            msgStop( cErro, "JSONform")
        endif
        return ""
    endif

    if ! Empty( cErro := oJSON:fromJson(cMsg) )
        cErro := "JSONform: JSON corrompido"+CRLF+cErro
        if ! lQuiet
            msgStop( cErro, "JSONform")
        endif
        return ""
    endif

	if lOrdena
		cMsg := FGX_JsonToText( oJSON )
	endif

//    oJSON:DeActivate()
    oJSON := nil

// troca os tokens abaixo para formatá-los depois
    cMsg := strTran( cMsg, "},", chr(176) )
    cMsg := strTran( cMsg, "],", chr(177) )
    cMsg := strTran( cMsg, "),", chr(178) )
    cMsg := strTran( cMsg, '\"', chr(179) )

// adicionando ENTERS
    cMsg := strTran( cMsg, "{", "{"+CRLF )
    cMsg := strTran( cMsg, "[", "["+CRLF )
    cMsg := strTran( cMsg, "(", "("+CRLF )
    cMsg := strTran( cMsg, "}", CRLF+"}"+CRLF )
    cMsg := strTran( cMsg, "]", CRLF+"]"+CRLF )
    cMsg := strTran( cMsg, ")", CRLF+")"+CRLF )

// adicionando ENTERS nos tokens trocados
    cMsg := strTran( cMsg, chr(176), CRLF+"},"+CRLF )
    cMsg := strTran( cMsg, chr(177), CRLF+"],"+CRLF )
    cMsg := strTran( cMsg, chr(178), CRLF+"),"+CRLF )

// localiza vírgulas que não estejam entre ""
    for nI := 1 to len( cMsg )
        cToken := substr(cMsg,nI,1)

        if cToken == '"'
            nAspas++
        endif

        if cToken == "," .and. nAspas % 2 == 0
            cToken += CRLF
        endif

        cNewMsg += cToken
    next

    cNewMsg := strTran(cNewMsg, chr(179), '\"')

// gerando array por linhas para adicionar os recuos
    aLinhas := strTokArr( cNewMsg, CRLF )
    cNewMsg := ""

    for nI := 1 to len( aLinhas )
        if right( alltrim(aLinhas[nI]), 1 ) $ ")]}" .or. left( alltrim(aLinhas[nI]), 1 ) $ ")]}"
            nRecuo -= 3
        endif

        cNewMsg += space(nRecuo) + alltrim( aLinhas[nI] ) + CRLF

        if right( alltrim(aLinhas[nI]), 1 ) $ "{[("
            nRecuo += 3
        endif
    next

return cNewMsg


/*/{Protheus.doc} FGX_MULTMOEDA
	Função para retornar se trabalha com Multimoedas

	@author Andre Luis Almeida
	@since 17/04/2024
	@return lMultMoeda, logico
	/*/
Function FGX_MULTMOEDA()
Local lMultMoeda := .f. // Default BRASIL - Não trabalha com Multimoeda
If cPaisLoc $ "ARG/MEX/PAR" // Argentina , México e Paraguay
   lMultMoeda := .t.
EndIf
Return lMultMoeda

/*/{Protheus.doc} FMX_RmvAcent
Função para retornar se trabalha com Multimoedas
@author Andre Luis Almeida
@since 17/04/2024
@type function
@return character, string sem os caracteres especiais
/*/
Function FMX_RmvAcent(cString)
Local nx        := 0
Local ny        := 0
Local cSubStr   := ""
Local cRetorno  := ""

Local cStrEsp   := "Á??ÀáàäãóöööööÇÇÉÉééº"
Local cStrEqu   := "AAAAaaaa000000CCEEeer-"
Local cPode     := "ASDFGHJKLÇQWERTYUIOPZXCVBNM<>:?^}^{}`]\|/;.,]~[[´]]''1234567890-=_+!@#$%&*()"+'"' + Chr(13) + Chr(10)

For nx :=1 to Len(cString)
    cSubStr := SubStr(cString,nx,1)
    ny := At(cSubStr,cStrEsp)
    If ny > 0
        cSubStr := SubStr(cStrEqu,ny,1)
    Endif
    // Alem de substituir os especiais somente add os que podem.
    If Upper(cSubStr) $ cPode
        cRetorno += cSubStr
    Else
        cRetorno += " "
    Endif
Next nx

Return cRetorno

/*/{Protheus.doc} FGX_ValidRequiredFieds
	Função genérica que valida se os campos obrigatórios do registro estão preenchidos
	@type  Function
	@author Lucas Oliveira
	@since 20/03/2025
	@version version
	@param 
		nRecno, numeric, recno do registro a ser verificado
		cTable, character, table do registro
		lShowMessage, logical, apresenta help do erro
	@return 
		lRet, logical, registro está valido
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FGX_ValidRequiredFieds(nRecno, cTable, lShowMessage)

	Local lRet 		:= nRecno > 0
	Local aArea 	:= GetArea()
	Local nField 	:= 0
	Local aStructFields := FWSX3Util():GetListFieldsStruct(cTable , .F., .F.) // cAlias , lVirtual, lRequired
	Default lShowMessage:= .T.

	DBSelectArea(cTable)
	If nRecno > 0
		DBGoTo(nRecno)
		For nField := 1 To Len(aStructFields)
			If X3Obrigat(aStructFields[nField][1]) .and. Empty(&(cTable +"->" + aStructFields[nField][1]))
				lRet := .F.
				If lShowMessage .and. !FWIsInCallStack("VX000INC") // Não mostrar mensagem novamente quando VX000INC, pois o FGX_AMOVVEI já exibe
					FMX_HELP("FMX_VALID", STR0156 + aStructFields[nField][1], STR0157) //"Campo obrigatório não preenchido - Realize o preenchimento dos campos obrigatórios antes de continuar."
				Endif
				Exit
			Endif
		Next
	Endif

	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} FGX_SM0SA1
Função para retornar Cliente e Loja da Filial informada
@type function
@version 1.0
@author João Carlos da Silva
@since 23/07/2024
@param cCodFil, character, Código da Filial
@param cTipoRet, character, Tipo do Retorno: A=Array, C=Caracter
@return array, Cliente e Loja
/*/
Function FGX_SM0SA1(cCodFil,cTipoRet)
Local nTamCod := Len(SA1->A1_COD)
Local nTamLoj := Len(SA1->A1_LOJA)
Local cChave  := "092" // Cliente por Filial Mercado Internacional
Local aRet    := {}

Default cTipoRet := "A" // A=Array, C=Caracter

VX5->(dbSetOrder(1)) // VX5_FILIAL+VX5_CHAVE+VX5_CODIGO
VX5->(dbSeek(xFilial("VX5") + cChave + cCodFil)) // Posiciona no VX5
If VX5->(!Eof())
	AAdd(aRet,Subs(VX5->VX5_DESCRI,1        ,nTamCod))
	AAdd(aRet,Subs(VX5->VX5_DESCRI,nTamCod+1,nTamLoj))
Else
	AAdd(aRet,PadR("",nTamCod))
	AAdd(aRet,PadR("",nTamLoj))
EndIf

Return(If(cTipoRet=="A",aRet,aRet[1]+aRet[2]))

/*/{Protheus.doc} FGX_SA1SM0
Função para retornar Código da Filial do Cliente e Loja informados
@type function
@version 1.0
@author João Carlos da Silva
@since 23/07/2024
@param cCodCli, character, Código do Cliente
@param cLojCli, character, Loja do Cliente
@return character, Código da Filial
/*/
Function FGX_SA1SM0(cCodCli,cLojCli)
Local nTamFil := Len(cFilAnt)
Local cChave  := "092" // Cliente por Filial Mercado Internacional
Local cRet    := PadR("",nTamFil)

VX5->(dbSetOrder(1)) // VX5_FILIAL+VX5_CHAVE+VX5_CODIGO
VX5->(dbSeek(xFilial("VX5") + cChave)) // Posiciona no VX5
While VX5->(!Eof() .and. VX5_FILIAL + VX5_CHAVE == xFilial("VX5") + cChave)
	If AllTrim(VX5->VX5_DESCRI) == cCodCli+cLojCli
		cRet := Subs(VX5->VX5_CODIGO,1,nTamFil)
		Exit
	EndIf
	VX5->(dbSkip())
End

Return(cRet)

/*/{Protheus.doc} FGX_VLDSX3
Função para trazer o VALID+VLDUSER de um campo especifico utilizando valor de variavel em tela
Exemplos de chamadas:
   FGX_VLDSX3('VVF_NUMNFI','MV_PAR01')
   FGX_VLDSX3('VVF_SERNFI','MV_PAR02')

@type function
@version 1.0
@author André Luis Almeida
@since 20/03/2025
@param cCampo, character, nome do campo do SX3 que será utilizado o VALID/VLDUSER
@param cVarTela, character, variavel que vem o valor
@return cRet, character, VALID+VLDUSER a ser executado
/*/
Function FGX_VLDSX3(cCampo,cVarTela)
Local cAux := ""
Local cRet := ""
cRet := "FGX_SETVAL('M->"+cCampo+"','"+cVarTela+"')"
cAux := Alltrim(GetSX3Cache(cCampo,"X3_VALID"))
cRet += IIf(!Empty(cAux)," .AND. "+cAux,"")
cAux := Alltrim(GetSX3Cache(cCampo,"X3_VLDUSER"))
cRet += IIf(!Empty(cAux)," .AND. "+cAux,"")
cRet += " .AND. FGX_SETVAL('"+cVarTela+"','M->"+cCampo+"')"
Return cRet

/*/{Protheus.doc} FGX_SETVAL
Função para setar valor entre 2 variaveis e retornar sempre .t. para passar dentro de VALID
Exemplos:
   FGX_SETVAL('M->VVF_NUMNFI','MV_PAR01')
   FGX_SETVAL('MV_PAR01','M->VVF_NUMNFI')

@type function
@version 1.0
@author André Luis Almeida
@since 20/03/2025
@param cVarA, character, variavel que vai receber o valor
@param cVarB, character, variavel que vai passar o valor
@return .t.
/*/
Function FGX_SETVAL(cVarA,cVarB)
&(cVarA) := &(cVarB)
__ReadVar := cVarA
Return .t.

/*/{Protheus.doc} FGX_CPOCOMBO
Função para retornar o nome do campo (SX3) referente ao COMBOBOX dependendo do Idioma selecionado na entrada do sistema

@type function
@version 1.0
@author André Luis Almeida
@since 24/04/2025
@return string - nome do campo referente ao combobox
/*/
Function FGX_CPOCOMBO()
Local cIdiom    := FwRetIdiom()
Local cCboIdiom := "X3_CBOX" // Combo no Idioma
cCboIdiom := IIf(cIdiom=='es',"X3_CBOXSPA",cCboIdiom) // Combo do SX3 por Idioma --> Espanhol
cCboIdiom := IIf(cIdiom=='en',"X3_CBOXENG",cCboIdiom) // Combo do SX3 por Idioma --> Ingles
Return cCboIdiom
/*/{Protheus.doc} FGX_FuncDMS

	Função para indicar se a chama é feita a partir de uma rotina do DMS

	@author Renato Vinicius
	@since 14/05/2025
/*/

Function FGX_FuncDMS(cFunName)
	
	Local lModDMS := nModulo == 11 .or. nModulo == 14 .or. nModulo == 41 // Módulos DMS

	Default cFunName := FunName()

	If lModDMS .and. cFunName $ "OFIXA011/OFIXA018/OFIXA100/OFIOM430/VEIXA011/VEIXA012/VEIXA013/VEIXA015/VEIXA016/"
		Return .t.
	EndIf

Return .f.

/*/{Protheus.doc} FGX_CPOSX5
Função para retornar o nome do campo (SX5) dependendo do Idioma selecionado na entrada do sistema

@type function
@version 1.0
@author André Luis Almeida
@since 02/06/2025
@return string - nome do campo SX5 referente ao Idioma selecionado
/*/
Function FGX_CPOSX5()
Local cIdiom  := FwRetIdiom()
Local cCampo  := "X5_DESCRI" // Portugues (PADRÃO)
If cIdiom $ "es/en"
	cCampo := IIf(cIdiom=="es","X5_DESCSPA","X5_DESCENG") // Espanhol / Ingles
EndIf
Return cCampo

/*/{Protheus.doc} FGX_DESSX5
Função para retornar a Descrição (SX5) dependendo do Idioma selecionado na entrada do sistema
Será utilizada para substituir a função Posicione do "SX5" no SX3

@type function
@version 1.0
@author André Luis Almeida
@since 02/06/2025
@param cSeekSX5, character, variavel que vai dar Seek no SX5 ( xFilial("SX5") + cTabela SX5 + cChave SX5 )
@return string - descricao do SX5 referente ao Idioma selecionado
/*/
Function FGX_DESSX5(cSeekSX5)
Return POSICIONE("SX5",1,cSeekSX5,FGX_CPOSX5())

/*/{Protheus.doc} FGX_GrupoVeic
	Função geral que retorna o Grupo (B1_GRUPO) para cadastro do veículo
	como produto
	@type  Function
	@author Lucas Oliveira
	@since 29/08/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FGX_GrupoVeic(cChaInt)

	Local aArea		:= GetArea()
	Local cGrupoVeic:= ""
	Default cChaInt	:= ""

	If !Empty(cChaInt) .and. ExistBlock("VXGRUVEI")
		cGrupoVeic := ExecBlock("VXGRUVEI",.F.,.F.,{cChaInt})
	Endif

	If Empty(cGrupoVeic)
		cGrupoVeic := Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])
	Endif

	RestArea(aArea)

Return cGrupoVeic

/*/{Protheus.doc} FGX_CallDMS
 
    @author Leonardo M Solera
    @since 14/05/2025
/*/
 
Function FGX_CallDMS()
   
    Local lDMS := nModulo == 11 .or. nModulo == 14 .or. nModulo == 41
 
    If lDMS .and. FWIsInCallStack( "OFIA460")
        Return .t.
    EndIf
 
Return .f.

/*/{Protheus.doc} FGX_GtUIDFJWT
	Retorna o user id de um jwt de autenticacao, usado por apis John Deere para identificar o usuario

	@type method
	@author Vinicius Gati
	@since 26/06/2025
/*/
Function FGX_GtUIDFJWT(cJWT)
	Local aPartes := StrTokArr(cJWT, ".")
	Local cPayload

	If Len(aPartes) >= 2
		cPayload := Decode64(aPartes[2])

		jData := JsonObject():new()
		jData:FromJson(cPayload)

		if ! empty(jData["userID"]) .and. ValType(jData["userID"]) == "C"
			// Retorna o userID do JWT
			Return jData["userID"]
		endif
	EndIf
return "GtUIDFJWT-Error"

/*/{Protheus.doc} FGX_MOEDAFAT
	Mercado Internacional - seleciona a Moeda que se deseja realizar a Fatura

	@type method
	@author André Luis Almeida
	@since 23/07/2025
/*/
Function FGX_MOEDAFAT(nMoedaOri)
Local nMoedFat   := nMoedaOri
Local nCntFor    := 0
Local nQtdMoedas := MoedFin() // Retorna a Quantidade de Moedas utilizadas
Local aMoedas    := {}
Local aParamBox  := {}
Local aRet       := {}
Local cAux       := ""
For nCntFor := 1 to nQtdMoedas
	cAux := GETMV("MV_MOEDA"+Alltrim(str(nCntFor)))
	If !Empty(cAux)
		aAdd(aMoedas,Alltrim(str(nCntFor))+"="+STR0161+" "+Alltrim(str(nCntFor))+" ( "+cAux+" )") // Moeda
	EndIf
Next
aAdd(aParamBox,{2,STR0158,IIf(nMoedaOri==0,"1",Alltrim(str(nMoedaOri))),aMoedas,120,"",.t.}) // Moeda para Faturar
While .t.
	If ParamBox(aParamBox,STR0158,@aRet,,,,,,,,.f.) // Moeda para Faturar
		nMoedFat := val(aRet[1])
		Exit
	EndIf
EndDo
Return nMoedFat
