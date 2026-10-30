#INCLUDE "tpllx5.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Fun‡ao    ³TPLLX5    ³ Autor ³ 	Templates           ³ Data ³Junho/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de Dados dos arquivos de transacoes (LDE e LDF) para: ³±±
±±³          ³V609:LDE ---> OZ5  //  LDF ---> OZ6                         ³±±
±±³          ³V710:LDE ---> OZ5(padrao na 710)//LDF --->OZ6(padrao na 710)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³Os arqs OZ5 e OZ6 sao do padrao da V710. Como o aplicador do³±±
±±³          ³template nao trata arqs q nao comecem com L (padrao de tpls)³±±
±±³          ³e portanto nao podem  ser criados na aplicacao do tpl na 609³±±
±±³          ³devem ser criados manualmente (apenas na 609).              ³±±
±±³          ³Sempre a carga do conteudo do OZ5 e OZ6 sao feitas a partir ³±±
±±³          ³do LDE e LDF, que servem como arqs de ponte. Nao sao usados ³±±
±±³          ³efetivamente no processamento do SigaREP.                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function TPLLX5(aTplEmp,aTplFiles)
Local nI := 0
Local nj := 0
Local cField
Local lNew

Local cTplEmp
Local cTplFil
Local cAllEmp := ""
Local nPos

For nI := 1 To Len(aTplEmp)
	//  Faz a Checagem dos arquivos

	If !ChkTplFile("LX5",aTplFiles,".DTP") .or. ;
	   !ChkTplFile("LXB",aTplFiles,".DTP")
	   Return .F.
	EndIf

	cTplEmp := Subs(aTplEmp[ni],1,2)
	cTplFil := Subs(aTplEmp[ni],3)

	//Fecha todos os arquivos abertos

	//prepara ambiente da empresa
	RpcSetEnv(cTplEmp,cTplFil)
	
	If !(cTplEmp $ cAllEmp)
		cAllEmp += cTplEmp + "#"
	
		ChkFile("LX5")

		DbSelectArea("LX5TPL")
		DbGoTop()
		While !Eof()
			DbSelectArea("LX5")
			lNew := DbSeek(xFilial("LX5")+LX5TPL->LX5_TABELA+LX5TPL->LX5_CHAVE)
			RecLock("LX5",lNew)
			For nj := 1 To FCount()
				uVar := NIL
				cField := Field(nj)
				If cField == "LX5_FILIAL"
					uVar := cTplFil
				Else
					nPos := LX5TPL->(FieldPos(cField))
					If nPos > 0
						uVar := LX5TPL->(FieldGet(nPos))
					EndIf
				EndIf
				If uVar <> NIL
					FieldPut(nj,uVar)
				EndIf
			Next nj
			MsUnlock()
			DbSelectArea("LX5TPL")
			DbSkip()
		End
	
		ChkFile("LXB")
		
		DbSelectArea("LXB")
		DbSetOrder(1)
		DbGoTop()
	
		DbSelectArea("LXBTPL")
		DbGoTop()
		While !Eof()
			DbSelectArea("LXB")
			lNew := DbSeek(xFilial("LXB")+LXBTPL->LXB_ALIAS+LXBTPL->LXB_TIPO+LXBTPL->LXB_SEQ+LXBTPL->LXB_COLUNA)
			RecLock("LXB",lNew)
			For nj := 1 To FCount()
				uVar := NIL
				cField := Field(nj)
				If cField == "LXB_FILIAL"
					uVar := cTplFil
				Else
					nPos := LXBTPL->(FieldPos(cField))
					If nPos > 0
						uVar := LXBTPL->(FieldGet(nPos))
					EndIf
				EndIf
				
				If uVar <> NIL
					FieldPut(nj,uVar)
				EndIf
			Next nj
			MsUnlock()
			DbSelectArea("LXBTPL")
			DbSkip()
		End

	EndIf
    
	//fecha TODOS os alias abertos
	RpcClearEnv()
Next nI

Conout(STR0001) //"Operacao Finalizada com sucesso!!!!"
Return .T.
