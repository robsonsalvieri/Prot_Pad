// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIIJD01.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIJD01 ³ Autor ³  Thiago					  ³ Data ³ 22/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importação DEF.						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIJD01()
Local aParamBox  := {}
Local aRet       := {}
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE
Local cAliasVD8  := "SQLVD8"

aAdd(aParamBox,{1,RetTitle("VD9_CODDEF"),Space(TamSX3("VD9_CODDEF")[1]),"@!","","VD7","",0,.T.})
aAdd(aParamBox,{6,STR0020,Space(200),"","","",80,	.T.,"(*.csv) |*.csv",,nOpcGetFil}) // "Arquivo:"

If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.t.))
	Return .f.
EndIf

If !MsgYesNo(STR0001,STR0002) //Esta rotina irá importar dados externos para a criação automatizada do cadastro dos itens do DEF! Deseja continuar?
	Return .f.
EndIf

If File(aRet[2])

	if (nHandle:= FT_FUse( aRet[2] )) == -1
		Return
	EndIf

	Begin Transaction

	FT_FGotop()
	lRet := .f.
	While ! FT_FEof()

		cStr := FT_FReadLN()
		If !Empty(cStr)

			aImport := strtokarr2(cStr,";",.t.)
			if len(aImport) < 8
				FMX_HELP("OFINJD01",STR0018,STR0019) // "Erro na formatação do arquivo de importação.","Verificar a documentação no TDN."
				//FT_FUse()
				EXIT
			endif

			// Gravacao da tabela VD9
			dbSelectArea("VD9")
			RecLock("VD9",.t.)
			VD9->VD9_FILIAL := FWxFilial("VD9")
			VD9->VD9_CODCON := GetSXENum("VD9","VD9_CODCON")
			VD9->VD9_CODDEF := aRet[1]
			VD9->VD9_CONCTA := AllTrim(StrTran(aImport[01],'"',""))
			VD9->VD9_DESCRI := AllTrim(StrTran(aImport[02],'"',""))
			VD9->VD9_CPODEF := AllTrim(StrTran(aImport[03],'"',""))
			VD9->VD9_CCUSTS := AllTrim(StrTran(aImport[04],'"',""))
			VD9->VD9_CCUSTA := AllTrim(StrTran(aImport[05],'"',""))
			VD9->VD9_CCUSTB := AllTrim(StrTran(aImport[06],'"',""))
			VD9->VD9_CCUSTC := AllTrim(StrTran(aImport[07],'"',""))
			VD9->VD9_ITECT1 := AllTrim(StrTran(aImport[08],'"',""))
			VD9->VD9_ITECT2 := AllTrim(StrTran(aImport[09],'"',""))
			VD9->VD9_CLVL1  := AllTrim(StrTran(aImport[10],'"',""))
			VD9->VD9_CLVL2  := AllTrim(StrTran(aImport[11],'"',""))
			VD9->VD9_TIPO   := "3"
			VD9->VD9_ATIVO  := "1"
			ConfirmSX8()
			MsUnlock()

			//Gravação da tabela VDE
			dbSelectArea("VDE")
			dbSetOrder(1)
			lAchou := dbSeek(xFilial("VDE")+aRet[1]+VD9->VD9_CODCON)
			RecLock("VDE",!lAchou)
			if ! lAchou
				VD9->VD9_FILIAL := FWxFilial("VD9")
			endif
			VDE->VDE_CODDEF := VD9->VD9_CODDEF
			VDE->VDE_CODCON := VD9->VD9_CODCON
			VDE->VDE_CCTERP := AllTrim(StrTran(aImport[12],'"',""))
			VDE->VDE_OPER   := AllTrim(StrTran(aImport[13],'"',""))
			VDE->VDE_TIPSAL := AllTrim(StrTran(aImport[14],'"',""))
			VDE->VDE_CCUSTO := AllTrim(StrTran(aImport[15],'"',""))
			VDE->VDE_ITEMCT := AllTrim(StrTran(aImport[16],'"',""))
			VDE->VDE_CLVL   := AllTrim(StrTran(aImport[17],'"',""))
			VDE->VDE_PERCEN := Val(aImport[18])
		EndIf

		FT_FSkip()
	End
	FT_FUse()

	// Gravacao da tabela VDA
	cQuery := "SELECT DISTINCT VD9.VD9_CODDEF,VD9.VD9_CODCON,VD8.VD8_CODDEF,VD8.VD8_CODEMP,VD8.VD8_CODFIL,VD8.VD8_ATIVO "
	cQuery += "FROM "
	cQuery += RetSqlName( "VD8"  ) + " VD8 "
	cQuery += "JOIN "+RetSqlName("VD9")+" VD9 ON ( VD9.VD9_FILIAL='"+xFilial("VD9")+"' AND VD9.VD9_CODDEF=VD8.VD8_CODDEF AND VD9.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE "
	cQuery += "VD8.VD8_FILIAL='"+ xFilial("VD8")+ "' AND VD8.VD8_CODDEF = '"+aRet[1]+"' AND "
	cQuery += "VD8.VD8_ATIVO = '1' AND "
	cQuery += "VD8.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD8, .T., .T. )

	Do While !( cAliasVD8 )->( Eof() )
		dbSelectArea("VDA")
		dbSetOrder(1)
		if !dbSeek(xFilial("VDA")+( cAliasVD8 )->VD9_CODDEF+( cAliasVD8 )->VD9_CODCON+( cAliasVD8 )->VD8_CODEMP+( cAliasVD8 )->VD8_CODFIL)
			RecLock("VDA",.t.)
			VDA->VDA_FILIAL := FWxFilial("VDA")
			VDA->VDA_CODDEF := ( cAliasVD8 )->VD9_CODDEF
			VDA->VDA_CODCON := ( cAliasVD8 )->VD9_CODCON
			VDA->VDA_CODEMP := ( cAliasVD8 )->VD8_CODEMP
			VDA->VDA_CODFIL := ( cAliasVD8 )->VD8_CODFIL
			VDA->VDA_ATIVO  := ( cAliasVD8 )->VD8_ATIVO
			MsUnlock()
		Endif
		dbSelectArea(cAliasVD8)
		( cAliasVD8 )->(dbSkip())

	Enddo
	( cAliasVD8 )->( dbCloseArea() )

	End Transaction
Endif


MsgInfo(STR0003)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OIJD01EXP ³ Autor ³ Thiago					  ³ Data ³ 22/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao DEF.						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OIJD01EXP()
Local aParamBox := {}
Local aRet      := {}
Local aIntCab   := {}
Local aIntIte   := {}
Local cAliasVD9 := "SQLVD9"
Local cNomRel   := "OFIIJD01"
Local cTitulo   := STR0004

aAdd(aParamBox,{1,RetTitle("VD9_CODDEF"),Space(TamSX3("VD9_CODDEF")[1]),"@!","","VD7","",0,.T.})

If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.t.))
	Return .f.
EndIf

aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CODDEF"))), "C" , TamSX3("VD9_CODDEF")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CODCON"))), "C" , TamSX3("VD9_CODCON")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CONCTA"))), "C" , TamSX3("VD9_CONCTA")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_DESCRI"))), "C" , TamSX3("VD9_DESCRI")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CPODEF"))), "C" , TamSX3("VD9_CPODEF")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CCUSTS"))), "C" , TamSX3("VD9_CCUSTS")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CCUSTA"))), "C" , TamSX3("VD9_CCUSTA")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CCUSTB"))), "C" , TamSX3("VD9_CCUSTB")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CCUSTC"))), "C" , TamSX3("VD9_CCUSTC")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_ITECT1"))), "C" , TamSX3("VD9_ITECT1")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_ITECT2"))), "C" , TamSX3("VD9_ITECT2")[1] ,"@!"})
if VD9->(FieldPos("VD9_CLVL1")) > 0
	aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CLVL1" ))), "C" , TamSX3("VD9_CLVL1")[1]  ,"@!"})
	aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_CLVL2" ))), "C" , TamSX3("VD9_CLVL2")[1]  ,"@!"})
endif
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_TIPO"  ))), "C" , TamSX3("VD9_TIPO")[1]   ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VD9_ATIVO" ))), "C" , TamSX3("VD9_ATIVO")[1]  ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_CCTERP"))), "C" , TamSX3("VDE_CCTERP")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("CT1_DESC01"))), "C" , TamSX3("CT1_DESC01")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_OPER"  ))), "C" , TamSX3("VDE_OPER")[1]   ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_TIPSAL"))), "C" , TamSX3("VDE_TIPSAL")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_CCUSTO"))), "C" , TamSX3("VDE_CCUSTO")[1] ,"@!"})
aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_ITEMCT"))), "C" , TamSX3("VDE_ITEMCT")[1] ,"@!"})
if VDE->(FieldPos("VDE_CLVL")) > 0
	aAdd(aIntCab,{ Upper(AllTrim(RetTitle("VDE_CLVL"))), "C" , TamSX3("VDE_CLVL")[1] ,"@!"})
endif

cQuery := "SELECT VD9.VD9_CODDEF,VD9.VD9_CODCON,VD9.VD9_CONCTA,VD9.VD9_DESCRI,VD9.VD9_CPODEF,VD9.VD9_CCUSTS,VD9.VD9_CCUSTA,VD9.VD9_CCUSTB,VD9.VD9_CCUSTC,VD9.VD9_TIPO,VD9.VD9_ATIVO,VDE.VDE_CCTERP,CT1.CT1_DESC01,VD9_ITECT1,VD9_ITECT2,"
if VD9->(FieldPos("VD9_CLVL1")) > 0
	cQuery += " VD9_CLVL1,VD9_CLVL2,"
endif
cQuery += "VDE.VDE_OPER,VDE.VDE_TIPSAL,VDE.VDE_CCUSTO, VDE.VDE_ITEMCT "
if VDE->(FieldPos("VDE_CLVL")) > 0
	cQuery += " , VDE_CLVL "
endif
cQuery += "FROM "
cQuery += RetSqlName( "VD9"  ) + " VD9 "
cQuery += " JOIN "+RetSqlName("VDE")+" VDE ON (VDE.VDE_FILIAL='"+xFilial("VDE")+"' "
cQuery += "AND VDE.VDE_CODDEF = VD9.VD9_CODDEF AND VDE.VDE_CODCON = VD9.VD9_CODCON AND VDE.D_E_L_E_T_=' ') "
cQuery += " LEFT JOIN "+RetSqlName("CT1")+" CT1 ON (CT1.CT1_FILIAL='"+xFilial("CT1")+"' AND CT1.CT1_CONTA = VDE.VDE_CCTERP AND CT1.D_E_L_E_T_=' ') "
cQuery += "WHERE "
cQuery += "VD9.VD9_FILIAL='"+ xFilial("VD9")+ "' AND VD9.VD9_CODDEF = '"+aRet[1]+"' AND "
cQuery += "VD9.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD9, .T., .T. )

Do While !( cAliasVD9 )->( Eof() )

	if VD9->(FieldPos("VD9_CLVL1")) > 0
		aAdd(aIntIte,{;
			( cAliasVD9 )->VD9_CODDEF,;
			( cAliasVD9 )->VD9_CODCON,;
			( cAliasVD9 )->VD9_CONCTA,;
			( cAliasVD9 )->VD9_DESCRI,;
			( cAliasVD9 )->VD9_CPODEF,;
			( cAliasVD9 )->VD9_CCUSTS,;
			( cAliasVD9 )->VD9_CCUSTA,;
			( cAliasVD9 )->VD9_CCUSTB,;
			( cAliasVD9 )->VD9_CCUSTC,;
			( cAliasVD9 )->VD9_ITECT1,;
			( cAliasVD9 )->VD9_ITECT2,;
			( cAliasVD9 )->VD9_CLVL1,;
			( cAliasVD9 )->VD9_CLVL2,;
			( cAliasVD9 )->VD9_TIPO,;
			( cAliasVD9 )->VD9_ATIVO,;
			( cAliasVD9 )->VDE_CCTERP,;
			( cAliasVD9 )->CT1_DESC01,;
			( cAliasVD9 )->VDE_OPER,;
			( cAliasVD9 )->VDE_TIPSAL,;
			( cAliasVD9 )->VDE_CCUSTO,;
			( cAliasVD9 )->VDE_ITEMCT,;
			( cAliasVD9 )->VDE_CLVL;
		})
	else
		aAdd(aIntIte,{;
			( cAliasVD9 )->VD9_CODDEF ,;
			( cAliasVD9 )->VD9_CODCON ,;
			( cAliasVD9 )->VD9_CONCTA ,;
			( cAliasVD9 )->VD9_DESCRI ,;
			( cAliasVD9 )->VD9_CPODEF ,;
			( cAliasVD9 )->VD9_CCUSTS ,;
			( cAliasVD9 )->VD9_CCUSTA ,;
			( cAliasVD9 )->VD9_CCUSTB ,;
			( cAliasVD9 )->VD9_CCUSTC ,;
			( cAliasVD9 )->VD9_ITECT1 ,;
			( cAliasVD9 )->VD9_ITECT2 ,;
			( cAliasVD9 )->VD9_TIPO   ,;
			( cAliasVD9 )->VD9_ATIVO  ,;
			( cAliasVD9 )->VDE_CCTERP ,;
			( cAliasVD9 )->CT1_DESC01 ,;
			( cAliasVD9 )->VDE_OPER   ,;
			( cAliasVD9 )->VDE_TIPSAL ,;
			( cAliasVD9 )->VDE_CCUSTO,;
			( cAliasVD9 )->VDE_ITEMCT;
		})
	endif

	dbSelectArea(cAliasVD9)
	( cAliasVD9 )->(dbSkip())

Enddo
( cAliasVD9 )->( dbCloseArea() )

FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. )

Return
