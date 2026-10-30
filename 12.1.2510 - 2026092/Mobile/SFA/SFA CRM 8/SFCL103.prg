#INCLUDE "SFCL103.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VrfCliente()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida dados do CLiente 					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli - Codigo do Cliente, cLojaCLi - Loja do CLiente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VrfCliente(nOpCli, aCliCtrl, aCliObj)

Local cMsg 		:= "", lCGCRet
Local cCodCli := "", cLojacli := "", cTipo := "", cRazao := "", cFantasia	:= ""
Local cEndereco	:= "", cBairro := "", cCep := "", cCidade := "", cUF := "", cTel := ""
Local cCGC := "", cIE := "", cEmail := ""
Local lRet := .T.

Local nPosCOD	 := ScanArray(aCliCtrl,"HA1_COD",,,1)
Local nPosLOJA	 := ScanArray(aCliCtrl,"HA1_LOJA",,,1)
Local nPosTIPO	 := ScanArray(aCliCtrl,"HA1_TIPO",,,1)
Local nPosNOME	 := ScanArray(aCliCtrl,"HA1_NOME",,,1)
Local nPosNREDUZ := ScanArray(aCliCtrl,"HA1_NREDUZ",,,1)
Local nPosEND	 := ScanArray(aCliCtrl,"HA1_END",,,1)
Local nPosBAIRRO := ScanArray(aCliCtrl,"HA1_BAIRRO",,,1)
Local nPosCEP	 := ScanArray(aCliCtrl,"HA1_CEP",,,1)
Local nPosMUN	 := ScanArray(aCliCtrl,"HA1_MUN",,,1)
Local nPosEST	 := ScanArray(aCliCtrl,"HA1_EST",,,1)
Local nPosTEL	 := ScanArray(aCliCtrl,"HA1_TEL",,,1)
Local nPosCGC	 := ScanArray(aCliCtrl,"HA1_CGC",,,1)
Local nPosINSCR	 := ScanArray(aCliCtrl,"HA1_INSCR",,,1)
Local nPosEMAIL	 := ScanArray(aCliCtrl,"HA1_EMAIL",,,1)

Local lValidIE 	:= SFGetMv("MV_SFVLDIE",,"F") == "T"
Local cValCNPJ 	:= SFGetMv("MV_VALCNPJ","1")
Local cValCPF  	:= SFGetMv("MV_VALCPF","1")

Local nRec 		:= 0

cCodCli 	:= Alltrim(aCliCtrl[nPosCOD,2])
cLojacli	:= AllTrim(aCliCtrl[nPosLOJA,2])
cTipo		:= AllTrim(aCliCtrl[nPosTIPO,2])
cRazao		:= AllTrim(aCliCtrl[nPosNOME,2])
cRazao		:= Upper(cRazao)
cFantasia	:= AllTrim(aCliCtrl[nPosNREDUZ,2])
cFantasia	:= Upper(cFantasia)
cEndereco	:= AllTrim(aCliCtrl[nPosEND,2])
cEndereco	:= Upper(cEndereco)
cBairro		:= AllTrim(aCliCtrl[nPosBAIRRO,2])
cBairro		:= Upper(cBairro)
cCep		:= AllTrim(aCliCtrl[nPosCEP,2])
cCidade		:= AllTrim(aCliCtrl[nPosMUN,2])
cCidade		:= Upper(cCidade)
cUF			:= AllTrim(aCliCtrl[nPosEST,2])
cUF			:= Upper(cUF)
cTel		:= AllTrim(aCliCtrl[nPosTEL,2])
cCGC		:= AllTrim(aCliCtrl[nPosCGC,2])
cIE  		:= AllTrim(aCliCtrl[nPosINSCR,2])
cEmail		:= AllTrim(aCliCtrl[nPosEMAIL,2])

if Empty(cCodcli)
	MsgStop(STR0001,STR0002) //"Escreva o Código do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cLojacli)
	MsgStop(STR0003,STR0002) //"Escreva a Loja do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cTipo)
	MsgStop(STR0004,STR0002) //"Escolha o Tipo do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cRazao)
	MsgStop(STR0005,STR0002) //"Escreva a Razão Social do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cFantasia)
	MsgStop(STR0006,STR0002) //"Escreva o Nome Fantasia do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cEndereco)
	MsgStop(STR0007,STR0002) //"Escreva o Endereço do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cBairro)
	MsgStop(STR0008,STR0002) //"Escreva o Bairro do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCep)
	MsgStop(STR0009,STR0002) //"Escreva o Cep do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCidade)
	MsgStop(STR0010,STR0002) //"Escreva a Cidade do Endereço do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cUF)
	MsgStop(STR0011,STR0002) //"Escreva o UF do Endereço do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cTel)
	MsgStop(STR0012,STR0002) //"Escreva o Telefone do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCGC)
	MsgStop(STR0013,STR0002) //"Escreva o CGC do Cliente!"###"Verifica Cliente"
	Return .F.
ElseIf Empty(cIE) .And. lValidIE
	MsgStop(STR0025,STR0002)//"Escreva a IE do Cliente!"###"Verifica Cliente"
	Return .F.
Endif

If !Empty(cCGC)
	If Len(cCGC) <= 11  // Tamanho do CPF
		lCGCRet := ValidCPF(cCGC)
		cMsg := STR0014 //"CPF"
	Else
		lCGCRet := ValidCGC(cCGC)
		cMsg := STR0015 //"CGC"
	EndIf
	If !lCGCRet
		MsgStop(cMsg + STR0016,STR0002) //" Inválido!"###"Verifica Cliente"
		Return .F.
	EndIf
	
	If nOpCli = 1 .Or. (nOpCli = 2 .And. Alltrim(cCGC) != Alltrim(HA1->HA1_CGC))
		//Verifica se CNPJ informado ja existe na base para validar na inclusao
		If nOpCli = 2
			nRec := HA1->(Recno())
		EndIf
		HA1->(dbSetOrder(03))
		If HA1->(DBSeek(RetFilial("HA1")+cCGC))
			If Len(cCGC) <= 11		// Tamanho do CPF
				If cValCPF == "1"	// Pergunta
					If !MsgYesOrNo("O CPF informado já foi utilizado no cliente "+HA1->HA1_COD+"/"+HA1->HA1_LOJA+;
					   " - "+HA1->HA1_NOME+CHR(10)+"Deseja prosseguir?","Atenção")
						lRet := .F.
					EndIf
				Else				// Bloqueia
					MsgAlert("O CPF informado já foi utilizado no cliente "+HA1->HA1_COD+"/"+HA1->HA1_LOJA+;
					" - "+HA1->HA1_NOME,"Atenção")
					lRet := .F.
				EndIf
			Else					// CNPJ
				If cValCNPJ == "1"	// Pergunta
					If !MsgYesOrNo("O CNPJ informado já foi utilizado no cliente "+HA1->HA1_COD+"/"+HA1->HA1_LOJA+;
					   " - "+HA1->HA1_NOME+CHR(10)+"Deseja prosseguir?","Atenção")
						lRet := .F.
					EndIf
				Else				// Bloqueia
					MsgAlert("O CNPJ informado já foi utilizado no cliente "+HA1->HA1_COD+"/"+HA1->HA1_LOJA+;
					" - "+HA1->HA1_NOME,"Atenção")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Endif

If !lRet
	If nRec > 0
		HA1->(dbGoTo(nRec))
	EndIf
	Return .F.
EndIf

If !Empty(cIE)
	If !IE(cIE,cUF)
		MsgStop(STR0026,STR0002) //"Inscrição Estadual Inválida!"###"Verifica Cliente"
		Return .F.
	EndIf
EndIf

// Ponto de Entrada para Complemento de Validacao dos Dados da Tela de Cadastro de Clientes
// O Ponto deve retornar .T. ou .F. (Caso seja .F., nao sera permitida a confirmacao dos dados na Tela de Clientes
// 1o Param: nOpCli (1-Inclusao, 2-Alteracao, 3-Detalhes)
// 2o Param: aCliCtrl (Array contendo os campos, objetos e campos padrao, onde poderemos agregar especificos
// 3o Param: OClieObj (Array com todos os Objetos relacionados aos campos do aCliCtrl)

If ExistBlock("SFACL002")
	lRet := ExecBlock("SFACL002", .F., .F., {@nOpCli, @aCliCtrl, @aCliObj })
	If !lRet
		Return .F.
	EndIF
EndIf


Return .T.

Function ExcCliente(cCodCli, cLojaCli,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)
Local cResp	:= ""
cResp:= if(MsgYesOrNo(STR0017,STR0018),STR0019,STR0020) //"Você deseja Excluir o Cliente Selecionado?"###"Cancelar"###"Sim"###"Não"
If cResp=STR0019 //"Sim"
	dbSelectArea("HC5")
	dbSetOrder(2)
	dbSeek(RetFilial("HC5") +  cCodCli+cLojaCli,.f. )
	While !Eof() .and. HC5->HC5_CLI == cCodCli .and. HC5->HC5_LOJA == cLojaCli
		If HC5->HC5_STATUS = "N"
			MsgAlert(STR0021,STR0022) //"Não será possível excluir, existem pedidos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo
	
	dbSelectArea("HU5")
	dbSetOrder(2)
	dbSeek( RetFilial("HU5") + cCodCli+cLojaCli,.f. )
	While !Eof() .And. HU5->HU5_CLIENT == cCodCli .And. HU5->HU5_LOJA == cLojaCli
		If HU5->HU5_STATUS = "N"
			MsgAlert(STR0023,STR0022) //"Não será possível excluir, existem novos contatos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo
	
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1") + cCodCli + cLojaCli)
	If HA1->(Found())
		dbDelete()
		dbSkip()
		MsgAlert(STR0024,STR0022) //"Cliente Excluído com Sucesso!"###"Aviso"
	Endif
	CloseDialog()
	
	//Atualiza o Browse do Cliente
	dbSelectArea("HA1")
	dbSetOrder(nCampo)
	dbSeek(RetFilial("HA1"))
	//dbGoTop()
	nTop := HA1->(Recno())
	ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)
Endif

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ LoadUF()        	   ³Autor: Fabio Garbin  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega as UFs do Brasil       	 			     		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LoadUF(aUF, nUf, cUf)
Local cAlias  := Alias()
Local cTabela := "UF"

dbSelectArea("HX5")
dbSetOrder(1)
If dbSeek(RetFilial("HX5") + cTabela)
	While !Eof() .And. HX5->HX5_TABELA == cTabela
		AADD(aUf, AllTrim(HX5->HX5_CHAVE) + "-"	+ AllTrim(HX5->HX5_DESCRI))
		If HX5->HX5_CHAVE = cUf
			nUf := Len(aUf)
		EndIf
		dbSkip()
	Enddo
EndIf
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtualUf()           ³Autor: Fabio Garbin  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona a UF											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AtualUf(aUf, nUf, aCliCtrl, nPosaCli)

aCliCtrl[nPosaCli,2] := SubStr(aUf[nUf],1,2)

Return Nil
