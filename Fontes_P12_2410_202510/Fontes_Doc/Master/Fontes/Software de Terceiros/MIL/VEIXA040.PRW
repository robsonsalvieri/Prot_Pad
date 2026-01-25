#include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIXA040.CH"

/*/{Protheus.doc} VEIXA040
	Agrega/Desagrega - Chamada da nova Rotina de Multieventos ( VEIA300 )

	@author Andre Luis Almeida
	@since 20/03/2023
/*/
Function VEIXA040()
Local cQuery    := ""
Local cSQLAlias := "SQLVDV"
Local aVDV      := {}
Local oModelVFJ
Local cNamVVA   := RetSQLName("VVA")
Local cNamVVG   := RetSQLName("VVG")

If cPaisLoc == "BRA" .and. GetNewPar("MV_MIL0194","0") == "0" // TEMPORARIO - Utiliza Agrega/Desagrega ANTIGO - VEIXX040
	//
	cCadastro := STR0001 // Agrega/Desagrega no Equipamento
	aRotina := VXA040001C_menuDef()








	DbSelectArea("VV1")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"VV1",,,,,,,,,,,,,," VV1_SITVEI='0' AND VV1_GRASEV<>'6' AND VV1_FILENT='"+xFilial("VVF")+"' ")
	DbSelectArea("VV1")
	Return()
	//
EndIf
/////////////////////////////////////////////////
// Ajustar VFJ - Agrega/Desagrega Multieventos //
/////////////////////////////////////////////////
If VDV->(ColumnPos("VDV_CODEXE")) > 0 .and. FWAliasInDic("VFJ") // Existe campo de Execução do Agrega/Desagrega Multieventos
	oModelVFJ := FWLoadModel( 'VEIA317' ) // MVC para inserir o cabeçalho VFJ
	cQuery := "SELECT R_E_C_N_O_ AS RECVDV"
	cQuery += "  FROM "+RetSQLName("VDV")
	cQuery += " WHERE VDV_FILIAL = '"+xFilial("VDV")+"'"
	cQuery += "   AND VDV_FILVV0 = '"+xFilial("VV0")+"'"
	cQuery += "   AND VDV_FILVVF = '"+xFilial("VVF")+"'"
	cQuery += "   AND VDV_FILEXE = ' '"
	cQuery += "   AND VDV_CODEXE = ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		VDV->(DbGoTo( (cSQLAlias)->( RECVDV ) ))
		aVDV := {}
		oModelVFJ:SetOperation( MODEL_OPERATION_INSERT )
		If oModelVFJ:Activate()
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_STATUS" , IIf(VDV->VDV_STATUS=="1","1","2") ) // 0=Digitado / 1=Efetivado / 2=Cancelado / 3=Efetivação Pendente ( problema para Efetivar )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_PROCES" , VDV->VDV_AGRDES ) // 1=Agrega / 2=Desagrega
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_TIPPRO" , VDV->VDV_TIPDOC ) // 1=Notas Fiscais / 2=Movimentações Internas
			If VDV->VDV_TIPDOC == "1" // 1=Notas Fiscais
				oModelVFJ:SetValue( "VFJMASTER" , "VFJ_TIPITE" , IIf(Empty(VDV->VDV_SNUMNP).and.Empty(VDV->VDV_ENUMNP),"1","2") ) // 1=AMS / 2=Peças
			Else // VDV->VDV_TIPDOC == "2" // Movimentações Internas
				cQuery := "SELECT SUM(QTD) FROM ( "
				cQuery += "   SELECT COUNT(VVA.VVA_NUMTRA) AS QTD "
				cQuery += "     FROM "+cNamVVA+" VVA "
				cQuery += "    WHERE VVA.VVA_FILIAL = '"+VDV->VDV_FILVV0+"'"
				cQuery += "      AND VVA.VVA_NUMTRA = '"+VDV->VDV_NUMTRA+"'"
				cQuery += "      AND VVA.D_E_L_E_T_ = ' '"
				cQuery += " UNION "
				cQuery += "   SELECT COUNT(VVG.VVG_TRACPA) AS QTD "
				cQuery += "     FROM "+cNamVVG+" VVG "
				cQuery += "    WHERE VVG.VVG_FILIAL = '"+VDV->VDV_FILVVF+"'"
				cQuery += "      AND VVG.VVG_TRACPA = '"+VDV->VDV_TRACPA+"'"
				cQuery += "      AND VVG.D_E_L_E_T_ = ' '"
				cQuery += ") TMP"
				oModelVFJ:SetValue( "VFJMASTER" , "VFJ_TIPITE" , IIf(FM_SQL(cQuery)>2,"1","2") ) // 1=AMS / 2=Peças
			EndIf
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_VV1001" , VDV->VDV_CHAINT )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_DATINC" , VDV->VDV_DATMOV )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_HORINC" , strzero(VDV->VDV_HORMOV,4) )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_USRINC" , VDV->VDV_CODUSR )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_DATEFE" , VDV->VDV_DATMOV )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_HOREFE" , strzero(VDV->VDV_HORMOV,4) )
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_USREFE" , VDV->VDV_CODUSR )
			If oModelVFJ:VldData()
				oModelVFJ:CommitData()
			EndIf
			aAdd(aVDV,{ "VDV_FILEXE" , oModelVFJ:GetValue( "VFJMASTER" , "VFJ_FILIAL" ) }) // Filial da Execução do Processo
			aAdd(aVDV,{ "VDV_CODEXE" , oModelVFJ:GetValue( "VFJMASTER" , "VFJ_CODIGO" ) }) // Codigo de Execução do Processo
			oModelVFJ:DeActivate()
		EndIf
		If len(aVDV) > 0
			VA3180011_MVC_CAD_VDV( (cSQLAlias)->( RECVDV ) , aVDV )
		EndIf
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VDV")
	FreeObj(oModelVFJ)
	//
	VEIA300() // Agrega/Desagrega Multieventos - VEIA300
	//
Else
	//
	MsgAlert(STR0009,STR0008) // Para utilizar a rotina Agrega/Desagrega Multieventos é necessário ajustar a base de dados conforme documentação do pacote. / Atenção
	//
EndIf
Return()


/*/{Protheus.doc} menuDef
Declaração da função MenuDef 
@type function
@version 1.0
@author cristiamRossi
@since 2/16/2024
@return array, aRotina - menudef
/*/
static function menuDef()
return VXA040001C_menuDef()


/*/{Protheus.doc} VXA040001C_menuDef
Rotina que retorna array aRotina com o MenuDef
@type function
@version 1.0
@author cristiamRossi
@since 2/16/2024
@return array, aRotina - menudef
/*/
function VXA040001C_menuDef()
local aRotina := {	{STR0003, "VEIVC140(VV1->VV1_CHASSI, VV1->VV1_CHAINT)", 0, 2},; // Visualizar
					{STR0004, "VEIXX040(1)", 0, 4}, ; // Agregar
					{STR0005, "VEIXX040(2)", 0, 4}, ; // Desagregar
					{STR0006, "VX040CANC()", 0, 5}, ; // Cancelar
					{STR0007, "VEIC020(VV1->VV1_CHASSI)", 0, 4}} // Histórico Agrega/Desagrega
	
	If ( ExistBlock("VX040BT") )
		aRotina := ExecBlock("VX040BT",.f.,.f.,{aRotina})
	EndIf

return aRotina
