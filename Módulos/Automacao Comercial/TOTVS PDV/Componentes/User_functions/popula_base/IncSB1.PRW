#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

User Function IncSB1()
Local c_Emp := "99"
Local c_Fil := "01"
Local nNumIni := 000001
Local nNumFim := 010000
Local nInd := 0

PREPARE ENVIRONMENT EMPRESA c_Emp Filial c_Fil modulo 'FAT'

dbSelectArea("SB1")

for nInd:=nNumIni to nNumFim
	RecLock("SB1",.T.)
	SB1->B1_FILIAL := xFilial("SB1")
	SB1->B1_COD := StrZero(nInd,6)
	SB1->B1_DESC := "PRODUTO " + StrZero(nInd,6)
	SB1->B1_TIPO := "PA"
	SB1->B1_UM := "UN"
	SB1->B1_LOCPAD := "01"
	SB1->B1_TIPCONV := "M"
	SB1->B1_MCUSTD := "1"
	SB1->B1_APROPRI := "D"
	SB1->B1_TIPODEC := "N"
	SB1->B1_RASTRO := "N"
	SB1->B1_UREV := dDataBase
	SB1->B1_DATREF := dDataBase
	SB1->B1_MRP := "S"
	SB1->B1_CONINI := dDataBase
	SB1->B1_CODBAR := SB1->B1_COD
	SB1->B1_LOCALIZ := "N"
	SB1->B1_CONTRAT := "N"
	SB1->B1_IMPORT := "N"
	SB1->B1_ANUENTE := "2"
	SB1->B1_TIPOCQ := "M"
	SB1->B1_SOLICIT := "N"
	SB1->B1_DESPIMP := "N"
	SB1->B1_AGREGCU := "2"
	SB1->B1_INSS := "N"
	SB1->B1_FLAGSUG := "1"
	SB1->B1_CLASSVE := "1"
	SB1->B1_MIDIA := "2"
	SB1->B1_QTDSER := 1
	SB1->B1_ATIVO := "S"
	SB1->B1_CPOTENC := "2"
	SB1->B1_USAFEFO := "1"
	SB1->B1_ESCRIPI := "3"
	SB1->B1_PRODSBP := "P"
	SB1->B1_MSBLQL := "2"
	SB1->B1_PIS := "2"
	SB1->B1_RETOPER := "2"
	SB1->B1_CSLL := "2"
	SB1->B1_FETHAB := "N"
	SB1->B1_COFINS := "2"
	SB1->B1_RICM65 := "2"
	SB1->( MsUnLock() )
	
	RecLock("SB0",.T.)
	SB0->B0_FILIAL 	:= xFilial("SB0")
	SB0->B0_COD 	:= SB1->B1_COD
	SB0->B0_PRV1 	:= 10.00
	SB0->( MsUnLock() )
	
	conout("************ Inclusao do Registro " + SB1->B1_COD)
next nInd

Return 