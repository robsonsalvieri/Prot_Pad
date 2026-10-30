// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 003    ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "PROTHEUS.CH"
#include "OFICSC02.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFICSC02   | Autor |Carla Catiane F R      | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Informacoes do WHI Scania.                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integraÁ„o com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFICSC02(lNoMBrowse, nOpcAux)

Default lNoMBrowse := .f.
Default nOpcAux    := 2

Private cCadastro := ""
Private aRotina := MenuDef()

Private cVV1Mostra := "VV1_CHASSI/VV1_CHAINT/VV1_MODVEI/VV1_DESMOD/VV1_FABMOD/VV1_DATVEN/VV1_DTUVEN/VV1_PROATU/VV1_LJPATU/VV1_NOMPRO/VV1_DATETG"

DbSelectArea("VV1")
If lNoMBrowse
	If ( nOpcAux <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpcAux,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()))
	Endif
Else
	mBrowse( 6, 1,22,75,"VV1",,,,,,,,,,,,,,)
EndIf
//

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCSCCO2   | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCSCCO2(cAlias, nReg)
	local oCfg  := Nil
	local oJson := Nil
	local cURL  := ""

	If !OFISC01001_ConfigValidaWHI(@oJson)
		FMX_HELP("OFCSCCO2",;
		STR0003 ,; //A configuraÁ„o do WHI n„o foi concluÌda, impedindo o processamento do XML.
		STR0004 )  // Acesse ConfiguraÁıes Gerais (OFIA551), na aba WHI, e conclua a configuraÁ„o necess·ria para habilitar o processamento do XML.
		Return .F.
	Endif

	VV1->(DbGoto(nReg))
	cURL := oJson["WHI_URL"]
	cURL += alltrim( VV1->VV1_CHASSI )

	If !Empty(cURL)
		ShellExecute( "Open", cURL, "", "C:\", 1 )
	Endif

	fwFreeObj(oCfg)
	fwFreeObj(oJson)

Return nil


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

	Local aRotina:= {{ STR0001 , "PesqBrw"   , 0 , 1},; // Pesquisar
	{ STR0002 , "OFCSCCO2"  , 0 , 2}} // Cons. Chassi

Return aRotina
