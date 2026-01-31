#INCLUDE "SFCL103.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VrfCliente()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida dados do CLiente 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli - Codigo do Cliente, cLojaCLi - Loja do CLiente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VrfCliente(cCodCli,cLojaCli,cTipo,cRazao,cFantasia,cEndereco,cBairro,cCep,cCidade,cUF,cTel,cCGC,cIE,cEmail)
Local cMsg := "", lCGCRet

cCodCli 	:= Alltrim(cCodCli)
cLojacli	:= AllTrim(cLojaCli)
cTipo		:= AllTrim(cTipo)
cRazao		:= AllTrim(cRazao)
cRazao		:= Upper(cRazao)
cFantasia	:= AllTrim(cFantasia)
cFantasia	:= Upper(cFantasia)
cEndereco	:= AllTrim(cEndereco)
cEndereco	:= Upper(cEndereco)
cBairro		:= AllTrim(cBairro)
cBairro		:= Upper(cBairro)
cCep		:= AllTrim(cCep)
cCidade		:= AllTrim(cCidade)
cCidade		:= Upper(cCidade)
cUF			:= AllTrim(cUF)
cUF			:= Upper(cUF)
cTel		:= AllTrim(cTel)
cCGC		:= AllTrim(cCGC)
cIE  		:= AllTrim(cIE)
cEmail		:= AllTrim(cEmail)

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
Elseif !Empty(cCGC)
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
Endif	

Return .T.

Function ExcCliente(cCodCli, cLojaCli,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)
Local cResp	:= ""
cResp:= if(MsgYesOrNo(STR0017,STR0018),STR0019,STR0020) //"Você deseja Excluir o Cliente Selecionado?"###"Cancelar"###"Sim"###"Não"
If cResp=STR0019 //"Sim"
	dbSelectArea("HC5")
	dbSetOrder(2)
	dbSeek( cCodCli+cLojaCli,.f. )
	While !Eof() .and. HC5->C5_CLI == cCodCli .and. HC5->C5_LOJA == cLojaCli
		If HC5->C5_STATUS = "N"
			MsgAlert(STR0021,STR0022) //"Não será possível excluir, existem pedidos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo   

	dbSelectArea("HU5")
	dbSetOrder(2)
	dbSeek( cCodCli+cLojaCli,.f. )
	While !Eof() .And. HU5->U5_CLIENTE == cCodCli .And. HU5->U5_LOJA == cLojaCli
		If HU5->U5_STATUS = "N"
			MsgAlert(STR0023,STR0022) //"Não será possível excluir, existem novos contatos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo   

	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(cCodCli + cLojaCli)
	If HA1->(Found()) 
		dbDelete()
		dbSkip()
		MsgAlert(STR0024,STR0022) //"Cliente Excluído com Sucesso!"###"Aviso"
	Endif
	CloseDialog()	

	//Atualiza o Browse do Cliente
	dbSelectArea("HA1")
	dbSetOrder(nCampo)
	dbGoTop()
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
If dbSeek(cTabela)
	While !Eof() .And. HX5->X5_TABELA == cTabela
		AADD(aUf, AllTrim(HX5->X5_CHAVE) + "-"	+ AllTrim(HX5->X5_DESCRI))
		If HX5->X5_CHAVE = cUf
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
Function AtualUf(aUf, cUf, nUf)
cUf := SubStr(aUf[nUf],1,2)
Return Nil