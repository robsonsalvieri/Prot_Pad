#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GpTABCRG   ºAutor³ Mauricio Takakura  º Data ³  15/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Enviar informacoes de Tabelas Auxiliares ao cliente        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.  ³16/02/10³??????/2010³Tratamento da localizacao Peru.           ³±±
±±³Mauricio T. ³27/03/10³006700/    ³Erro gerado na declaracao de DEFAULT      ³±±
±±³            ³        ³       2010³nos itens do Mexico.            		   ³±±
±±³Erika K.    ³18/05/10³10732/     ³Ajuste de string da tabela S025 (Peru).   ³±±
±±³            ³        ³       2010³                                          ³±±
±±³Christiane V³03/11/10³25090/     ³Ajuste Tab. S024 Portugal, cód. Oficiais  ³±±
±±³	           ³		³       2010³                                          ³±±
±±³Alex        ³04/12/10³           ³Inclusao dos gastos com outras empresas.  ³±±
±±³            ³        ³           ³Localizacao Equador                       ³±±
±±³Tiago Malta ³30/11/10³027152/2010³-Alteracao da funcao Gp310TABPTG, ajustado³±±
±±³            ³        ³           ³a Tab.S021 Portugal e incluido tabela S033³±±
±±³Ademar Jr.  ³07/10/10³024301/2010³-Implementado o tratamento pra HomologNet.³±±
±±³Alessandro  ³03/01/11³26914/2010 ³Implementado tratamento para residentes no³±±
±±³            ³        ³           ³exterior.                                 ³±±
±±³Ademar Jr.  ³21/03/11³029310/2010³-Ajuste Tabela S011 de Portugal, conforme ³±±
±±³            ³        ³           ³ novo modelo.                             ³±±
±±³Ademar Jr.  ³22/03/11³00????/2011³-Compatibilizacao do fonte da Fase 4 com a³±±
±±³            ³        ³           ³ Fase Normal do RH.                       ³±±
±±³Tiago Malta ³27/04/11³009779/2011³Ajuste na Tab. Auxiliar S020 - Venezuela. ³±±
±±³/Ademar Jr. ³        ³           ³                                          ³±±
±±³ 		   ³		³			³                                          ³±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC / Chamado  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.  ³21/07/11³00000017542/2011³-Localizacao Colombia-Criado a carga da Ta-³±±
±±³            ³        ³Chamado TDITZ9  ³ bela Auxiliar S030.                       ³±±
±±³L.Trombini  ³17/08/11³00000019483/2011³-Localizacao Argentina - Retirada pesquisa ³±±
±±³            ³        ³Chamado TDNFFT  ³ da tabela Auxiliar S016, pois estava      ³±±
±±³            ³        ³				 ³ realizando a pesquisa na propria tabela.  ³±±
±±³Luis Ricardo³04/10/11³00000015522/2011³Ajuste na carga das tabelas do Brasil para ³±±
±±³Cinalli     ³		³				 ³preencher a Filial da Tabela em Branco.    ³±±
±±³Ademar Jr.  ³05/10/11³00000017679/2011³-COL-Implementado na carga da Tabela S030  ³±±
±±³            ³        ³Chamado TDHI34  ³    os itens 005S, 006S e 007S.            ³±±
±±³Ademar Jr.  ³14/11/11³00000028373/2011³-AUS-Implementado carga das Tabelas S006 e ³±±
±±³            ³        ³Chamado TDYEKN  ³     S013.                                 ³±±
±±³Laura Medina³19/12/13³                ³Se crearon tablas Alfanuméricas  en la	 ³±±
±±³            ³        ³                ³funcion Gp310TABMEX						 ³±±
±±³Laura Medina|04/03/14|TIGYIB          |Actualizacion conceptos S031  Mexico       ³±±
±±³            ³        ³                ³- MEX-Actualizacion de la tabla S027- Tipo ³±±
±±³            ³        ³TIJIB8          ³      Regimen SAT.                         ³±±
±±³Alf. Medrano³07/09/16³                ³Merge V 12.1.13                            ³±±
±±³            ³        ³                ³se actualiza Gp310TABCOL COLOMBIA          ³±±
±±³LuisEnriquez³22/06/17³    MMI-5054    ³Merge main .En función Gp310TABMEX se rea- ³±±
±±³            ³        ³                ³lizaron ade cuaciones en estructura y lle- ³±±
±±³            ³        ³                ³nado de tablas auxiliares S027 a S037.(MEX)³±±
±±³Jonathan glz³16/08/17³DMINA-221       ³Replica 12.1.17 Se agrega creación de tabla³±±
±±³            ³        ³ReplicaDMINA-219³S031 con actualizacion de conceptos 024D a ³±±
±±³            ³        ³                ³100D. (MEX)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GpTABCRG()

	If cPaisLoc == "PTG"
		Gp310TABPTG()
	ElseIf cPaisLoc == "ANG"
		Gp310TABANG()
	ElseIf cPaisLoc == "VEN"
		Gp310TABVEN()
	ElseIf cPaisLoc == "EQU"
		Processa( {|lEnd| Gp310TabEQU(), "Cargamento de Tablas... Aguarde!" })
	ElseIf cPaisLoc == "BRA"
		Processa( {|lEnd| Gp310TABBRA(), "Carregamento de Tabelas... Aguarde!" })
	ElseIf cPaisLoc == "AUS"
		Processa( {|lEnd| Gp310TabAUS(), "Load Tables ... Wait!" })
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABPTGºAutor³ Kelly Soares       º Data ³  30/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PORTUGAL                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rogerio     ³14/08/08³151449³Alteracao da GP310PTG p/preencher tabelas ³±±
±±³Melonio     ³        ³151451³padroes de Portugal-Relatorios Anuais.    ³±±
±±³            ³        ³151453³Quadro de Pessoal/Balanco Anual/Mod.10 IRS³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp310TABPTG()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq :=	""
Local nI		:=	0

DbSelectArea("RCB")
DbSetOrder(3)
lAchou := dbSeek(cFilRCB+'DESCRICAO '+'S011')
If lAchou .And. RCB_TAMAN <= 50
	RecLock("RCB",.F.)
	RCB->RCB_TAMAN := 90
	MsUnLock("RCB")
EndIf

DbSetOrder(1)
If !dbSeek(cFilRCB+'S011')

	cNomeArq := 'S011'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','01','CODIGO'   ,'CODIGO'      ,'C', 2,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','02','DESCRICAO','DESCRICAO'   ,'C',90,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','03','DIASCONTR','VIG.CONTRATO','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','04','MINDCONTR','MINIMO  DIAS','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','05','MAXDCONTR','MAXIMO DIAS' ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','06','QTDRENOV' ,'RENOVACOES'  ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','07','PRAZOMIN' ,'PRAZO MINIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','08','PRAZOMAX' ,'PRAZO MAXIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','09','TIPO_QDP' ,'QDR. PESSOAL','C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))' ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','10','TIPO_BSO' ,'BAL. SOCIAL' ,'C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'       ,'','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Else
	DbSelectArea("RCB")
	DbSetOrder(3)
	If dbSeek(cFilRCB+'TIPO_QDP')
		If Alltrim(RCB->RCB_CODIGO)=='S011' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
	If dbSeek(cFilRCB+'TIPO_BSO')
		If Alltrim(RCB->RCB_CODIGO)=='S011' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)	//-RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN
lAchou := dbSeek(cFilRCC+'S011')
If lAchou .And. SubStr(RCC_CONTEU,1,2)=="01"
	While !Eof() .And. RCC_FILIAL+RCC_CODIGO==cFilRCC+'S011'
		RecLock("RCC",.F.)
		dbDelete()
		MsUnLock("RCC")
		dbSkip()
	EndDo
	lAchou := .F.
EndIf
If !lAchou
	aTabela	:=	{}
	cNomeArq := 'S011'
																//           1         2         3         4         5         6         7         8         9
																//12123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123412341234123412341234
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','10CONTRATO DE TRABALHO SEM TERMO                                                               0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','11CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO SEM TERMO                    0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','12CONTRATO DE TRABALHO EM COMISSAO DE SERVICO SEM TERMO                                        0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','13CONTRATO DE TRABALHO INTERMITENTE SEM TERMO                                                  0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','14CONTRATO DE TRABALHO POR TEMPO INDETERMINADO PARA CEDENCIA TEMPORARIA                        0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','20CONTRATO DE TRABALHO COM TERMO CERTO                                                         0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','21CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO COM TERMO CERTO              0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','22CONTRATO DE TRABALHO EM COMISSAO DE SERVICO COM TERMO CERTO                                  0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','23CONTRATO DE TRABALHO TEMPORARIO COM TERMO CERTO                                              0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','30CONTRATO DE TRABALHO COM TERMO INCERTO                                                       0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','31CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO COM TERMO INCERTO            0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','32CONTRATO DE TRABALHO EM COMISSAO DE SERVICO COM TERMO INCERTO                                0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','33CONTRATO DE TRABALHO TEMPORARIO COM TERMO INCERTO                                            0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','80OUTRA SITUACAO                                                                               0   0   0   0   0   0'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S013')
	cNomeArq := 'S013'
	aTabela	:=	{}
	aAdd( aTabela, { cFilRCB,cNomeArq,'NIVEIS QUALIFICACAO','01','CODIGO'   ,'CODIGO'   ,'C', 1,0,'@!','NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'NIVEIS QUALIFICACAO','02','DESCRICAO','DESCRICAO','C',50,0,'@!','NAOVAZIO()','','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S013')
	aTabela	:=	{}
	cNomeArq := 'S013'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','1PRATICANTES / APRENDIZES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','2PROFISSIONAIS NAO QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','3PROFISSIONAIS SEMI-QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','4PROFISSIONAIS ALTAMENTE QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','5QUADROS INTERMEDIO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','6QUADROS MEDIOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','7QUADROS SUPERIORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','8DIRIGENTES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S021')
	aTabela := {}
	cNomeArq := 'S021'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','01','CODIGO'		,'CODIGO'		,'C',2	,0,'@!','NAOVAZIO()'	,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','02','DESCRICAO'	,'DESCRICAO'	,'C',100,0,'@!','NAOVAZIO()'	,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','03','DIUTURNI'	,'DIUTURNIDADE'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','04','SUBALIMEN'	,'SUB.ALIMENT.'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','05','SUBFERIAS'	,'SUB.FER.PROP'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','06','SUBNATAL'	,'SUB.NAT.PROP'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','07','INDEMNIZ'	,'INDEMNIZACAO'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','08','AVISOPREV'	,'AVISO PREVIO'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S021')
	aTabela	:=	{}
	cNomeArq := 'S021'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01CADUCIDADE POR TERMO DO CONTRATO A TERMO CERTO - ARTIGO 388                                         SSSS01N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02CADUCIDADE POR TERMO DO CONTRATO A TERMO INCERTO - ARTIGO 389                                       SSSS01N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03CADUCIDADE DO CONTRATO POR MORTE DO EMPREGADOR E EXTINCAO OU ENCERRAMENTO DA EMPRESA - ARTIGO 390   SSSS02N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04CADUCIDADE DO CONTRATO POR INSOLVENCIA E RECUPERACAO DA EMPRESA - ARTIGO 391                        SSSS04N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05CADUCIDADE COM A REFORMA DO TRABALHADOR POR VELHICE - ARTIGO 392                                    SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06INICIATIVA DO EMPREGADOR COM JUSTA CAUSA SUBJECTIVA DE DESPEDIMENTO - ARTIGO 396                    SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07INICIATIVA DO EMPREGADOR COM JUSTA CAUSA OBJECTIVA DE DESPEDIMENTO ( COLETIVO ) - ARTIGO 397        SSSS01S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08DESPEDIMENTO POR EXTINCAO DO POSTO DE TRABALHO - ARTIGO 402                                         SSSS06S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09DESPEDIMENTO POR INADAPTACAO DO TRABALHADOR - ARTIGO 405                                            SSSS07S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10INICIATIVA DO TRABALHADOR COM JUSTA CAUSA DE RESOLUCAO - ARTIGO 441                                 SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11POR DENUNCIA - ARTIGO 447                                                                           SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','12MUTUO ACORDO                                                                                        SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','13REFORMA POR INVALIDEZ                                                                               SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','14REFORMA ANTECIPADA                                                                                  SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','15PRE-REFORMA                                                                                         SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','16FALECIMENTO                                                                                         SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','17ANTECIPACAO DA CESSACAO A TERMO CERTO                                                               SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','18ANTECIPACAO DA CESSACAO A TERMO INCERTO                                                             SSSS  S'})


	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)

		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S023')
	aTabela	:=	{}
	cNomeArq := 'S023'
	aAdd( aTabela, {cFilRCB,cNomeArq,'REMUNERACAO DO QUADRO DE PESSOAL','01','CODIGO'   ,'CODIGO'   ,'C',2,0,'@!','NAOVAZIO()','','001'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'REMUNERACAO DO QUADRO DE PESSOAL','02','DESCRICAO','DESCRICAO','C',40,0,'@!','NAOVAZIO()','','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S023')
	aTabela	:=	{}
	cNomeArq := 'S023'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','01','01SALARIO BASE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','02','02TRABALHO SUPLEMENTAR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','03','03PREMIOS E SUBSIDIOS REGULARES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','04','04PRESTACOES IRREGULARES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S024')
	aTabela	:=	{}
	cNomeArq := 'S024'

	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','01','CODIGO'   ,'CODIGO'     ,'C',2,0,'@!','NAOVAZIO()','','002'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','02','DESCRICAO','DESCRICAO'  ,'C',30,0,'@!','NAOVAZIO()','','002'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','03','TPNACION' ,'TIPO NACION','C',2,0,'@!','NAOVAZIO()','S25','002'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If dbSeek(cFilRCC+'S024')
	If Substr(RCC->RCC_CONTEU, 1, 2) == '01'
	    While RCC->(!Eof()) .And. RCC_CODIGO == 'S024'
			RecLock("RCC",.F.,.T.)
			dbDelete( )
	    	MsUnlock()
	    	RCC->(DBSKIP())
		End
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S024')
	aTabela	:=	{}
	cNomeArq := 'S024'

	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','ADAndorra                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','AEEmiratos Árabes Unidos        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','AFAfeganistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','AGAntígua e Barbuda             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','AIAnguila                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','ALAlbânia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','AMArménia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','ANAntilhas Holandesas           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','AOANGOLA                        02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','AQAntárctica                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','ARArgentina                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','ASSamoa Americana               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','ATÁUSTRIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','AUAustrália                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','AWAruba                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','AXIlhas Aland                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','AZAzerbaijão                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','BABósnia-Herzegovina            04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','019','BBBarbados                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','020','BDBangladesh                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','021','BEBÉLGICA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','022','BFBurkina Faso                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','023','BGBULGÁRIA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','024','BHBarém                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','025','BIBurundi                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','026','BJBenim                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','027','BLSão Bartolomeu                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','028','BMBermudas                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','029','BNBrunei Darussalam             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','030','BOBolívia (Est.Plurinac.)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','031','BRBRASIL                        03'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','032','BSBahamas	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','033','BTButão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','034','BVIlha Bouvet                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','035','BWBotswana                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','036','BYBielorrússia                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','037','BZBelize                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','038','CACanadá                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','039','CCIlhas Cocos (Keeling)         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','040','CDCongo (Rep.Democrática)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','041','CFCentro-Africana (República)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','042','CGCongo                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','043','CHSuiça                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','044','CICosta do Marfim               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','045','CKIlhas Cook                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','046','CLChile                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','047','CMCamarões                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','048','CNChina                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','049','COColômbia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','050','CRCosta Rica                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','051','CUCuba                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','052','CVCABO VERDE                    02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','053','CXIlha Christmas                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','054','CYCHIPRE                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','055','CZREPUBLICA CHECA               01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','056','DEALEMANHA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','057','DJJibuti                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','058','DKDINAMARCA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','059','DMDomínica                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','060','DORepública Dominicana          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','061','DZArgélia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','062','ECEquador                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','063','EEESTONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','064','EGEgipto                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','065','EHSara Ocidental                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','066','EREritreia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','067','ESESPANHA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','068','ETEtiópia	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','069','FIFINLANDIA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','070','FJIlhas Fiji                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','071','FKIlhas Falkland (Malvinas)     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','072','FMMicronésia (Estados Federados)04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','073','FOIlhas Faroé                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','074','FRFRANCA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','075','GAGabão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','076','GBREINO UNIDO                   01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','077','GDGranada	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','078','GEGeórgia	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','079','GFGuiana Francesa               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','080','GGGuernsey                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','081','GHGana                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','082','GIGibraltar                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','083','GLGronelândia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','084','GMGâmbia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','085','GNGuiné                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','086','GPGuadalupe                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','087','GQGuiné Equatorial              04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','088','GRGRECIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','089','GSGeórgia do Sul                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','090','GTGuatemala                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','091','GUGuam                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','092','GWGUINE-BISSAU                  02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','093','GYGuiana                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','094','HKHong Kong                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','095','HMIlha Heard/Ilhas Mcdonald     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','096','HNHonduras                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','097','HRCroácia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','098','HTHaiti                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','099','HUHUNGRIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','100','IDIndonésia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','101','IEIRLANDA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','102','ILIsrael                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','103','IMIlha de Man                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','104','INÍndia                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','105','IOTer. Britânico Oc. Índico     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','106','IQIraque                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','107','IRIrão (República Islâmica)     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','108','ISIslândia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','109','ITITALIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','110','JEJersey                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','111','JMJamaica                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','112','JOJordânia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','113','JPJAPAO                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','114','KEQuénia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','115','KGQuirguizistão                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','116','KHCamboja	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','117','KIKiribati                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','118','KMComores                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','119','KNSão Cristóvão e Nevis         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','120','KPCoreia (Rep.Popular Democr.)  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','121','KRCoreia (República da)         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','122','KWKuwait                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','123','KYIlhas Caimão                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','124','KZCazaquistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','125','LALaos (Rep.Popular Democr.)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','126','LBLíbano                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','127','LCSanta Lúcia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','128','LILiechtenstein                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','129','LKSri Lanka                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','130','LRLibéria                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','131','LSLesoto                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','132','LTLITUANIA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','133','LULUXEMBURGO                    01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','134','LVLETONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','135','LYLíbia (Jamahiriya Árabe)      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','136','MAMarrocos                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','137','MCMónaco                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','138','MDMoldova (República de)        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','139','MEMontenegro                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','140','MFSão Martinho                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','141','MGMadagáscar                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','142','MHIlhas Marshall                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','143','MKMacedónia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','144','MLMali                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','145','MMMyanmar                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','146','MNMongólia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','147','MOMacau                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','148','MPIlhas Marianas do Norte       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','149','MQMartinica                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','150','MRMauritânia                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','151','MSMonserrate                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','152','MTMalta                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','153','MUMaurícias                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','154','MVMaldivas                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','155','MWMalawi                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','156','MXMéxico                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','157','MYMalásia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','158','MZMOCAMBIQUE                    02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','159','NANamíbia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','160','NCNova Caledónia                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','161','NENiger                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','162','NFIlha Norfolk                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','163','NGNigéria                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','164','NINicarágua                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','165','NLPaíses Baixos                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','166','NONoruega                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','167','NPNepal                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','168','NRNauru                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','169','NUNiue                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','170','NZNova Zelândia                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','171','OMOmã                           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','172','PAPanamá                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','173','PEPeru                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','174','PFPolinésia Francesa            04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','175','PGPapuásia-Nova Guiné           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','176','PHFilipinas                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','177','PKPaquistão                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','178','PLPOLONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','179','PMSão Pedro e Miquelon          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','180','PNPitcairn                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','181','PRPorto Rico                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','182','PSTerritório Palestiniano Ocup. 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','183','PTPORTUGAL                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','184','PWPalau                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','185','PYParaguai                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','186','QACatar                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','187','REReunião                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','188','ROROMENIA                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','189','RSSérvia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','190','RURUSSIA                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','191','RWRuanda                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','192','SAArábia Saudita                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','193','SBIlhas Salomão                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','194','SCSeychelles                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','195','SDSudão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','196','SESUECIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','197','SGSingapura                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','198','SHSanta Helena                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','199','SIESLOVENIA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','200','SJSvalbard e Ilha Jan Mayen     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','201','SKESLOVÁQUIA                    01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','202','SLSerra Leoa                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','203','SMSão Marino                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','204','SNSenegal                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','205','SOSomália                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','206','SRSuriname                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','207','STSAO TOME E PRINCIPE           02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','208','SVEl Salvador                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','209','SYSíria (República Árabe da)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','210','SZSuazilândia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','211','TCIlhas Turcas e Caicos         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','212','TDChade                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','213','TFTerritório Franceses do Sul   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','214','TGTogo                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','215','THTailândia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','216','TJTajiquistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','217','TKTokelau                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','218','TLTimor Leste                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','219','TMTurquemenistão                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','220','TNTunísia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','221','TOTonga                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','222','TRTurquia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','223','TTTrindade e Tobago             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','224','TVTuvalu                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','225','TWTaiwan (Província da China)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','226','TZTanzânia (República Unida)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','227','UAUcrânia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','228','UGUganda                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','229','UMIlhas Menores Distantes EUA   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','230','USESTADOS UNIDOS AMERICA(EUA)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','231','UYUruguai                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','232','UZUsbequistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','233','VASanta Sé (Cid.Est.Vaticano)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','234','VCSão Vicente e Granadinas      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','235','VEVenezuela                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','236','VGIlhas Virgens (Britânicas)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','237','VIIlhas Virgens (EUA)           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','238','VNVietname                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','239','VUVanuatu                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','240','WFWallis e Futuna (Ilhas)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','241','WSSamoa                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','242','YEIémen                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','243','YTMayotte                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','244','ZAÁfrica do Sul                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','245','ZMZâmbia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','246','ZWZimbabwe                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','247','APApátrida                      04'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S025')
	aTabela	:=	{}
	cNomeArq := 'S025'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO NACIONALIDADE','01','TPNAC '     ,'TP NACIONAL.'  ,'C',2,0,'@!','NAOVAZIO()'    ,'','001'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO NACIONALIDADE','02','DESNAC'     ,'DESC.NACION.'  ,'C',30,0,'@!','NAOVAZIO()'    ,'','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S025')
	aTabela	:=	{}
	cNomeArq := 'S025'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01PAISES DA UNIAO EUROPEIA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02PAISES AFRICANOS DE LINGUA OFICIAL'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03BRASIL'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04OUTROS PAISES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S026')
	aTabela	:=	{}
	cNomeArq := 'S026'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO RENDIMENTO IRS','001','CODIGO'   ,'CODIGO'   ,'C',003,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO RENDIMENTO IRS','002','DESCRICAO','DESCRICAO','C',100,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S026')
	aTabela	:=	{}
	cNomeArq := 'S026'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','A  TRABALHO DEPENDENTE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','B  RENDIMENTOS EMPRESARIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','E  OUTROS RENDIMENTOS DE CAPITAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','EE SALDOS CREDORES C/C (ARTIGO 12)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','F  PREDIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','G  INCREMENTOS PATRIMONIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','H  PENSOES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S027')
	aTabela	:=	{}
	cNomeArq := 'S027'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'CLASSIFICACAO IRS','01','CODIGO'   ,'CODIGO'   ,'C',002,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'CLASSIFICACAO IRS','02','DESCRICAO','DESCRICAO','C',120,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S027')
	aTabela	:=	{}
	cNomeArq := 'S027'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','1 RENDIMENTO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','2 RETENCOES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','3 DESCONTOS OBRIGATORIOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','4 QUOTIZACOES SINDICAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','5 REMUNERACOES NAO SUJEITAS A IRS'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S028')
	aTabela	:=	{}
	cNomeArq := 'S028'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'FORMACAO ESCOLAR','01','CODIGO ','CODIGO'  	,'C',  3,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'FORMACAO ESCOLAR','02','DESCRICAO','DESCRICAO','C',60,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S028')
	aTabela	:=	{}
	cNomeArq := 'S028'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','111Nao sabe ler nem escrever'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','112Sabe ler e escrever sem possuir o 1o. Ciclo do Ensino Basico'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2111o. Ciclo do Ensino Basico (Ensino Primario 4a. classe)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2121o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2212o. Ciclo do Ensino Basico (Ensino Preparatorio, Telescola ou antigo 2o. ano do Liceu)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2222o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2313o. Ciclo do Ensino Basico (antigo 5o. ano do Liceu, ou 9o. ano unificado)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','232Ensino Tecnico: Curso Geral Comercial'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2333o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','234Cursos das Escolas Profissionais - Nivel II'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','311Ensino Secundario (12o. ano) ou equivalente com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','312Ensino Secundario Tecnico Complementar'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','313Ensino Secundario Tecnico-Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','314Cursos das Escolas Profissionais - Nivel III'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','414Formacao de professores/formadores e ciencias da educacao'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','421Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','422Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','431Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','432Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','434Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','438Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','442Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','444Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','446Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','452Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','454Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','458Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','462Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','464Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','472Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','476Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','481Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','484Servicos de transporte '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','485Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','486Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','499Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','514Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','521Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','522Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','531Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','532Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','534Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','538Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','542Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','544Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','546Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','552Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','554Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','558Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','562Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','564Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','572Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','576Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','581Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','584Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','585Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','586Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','599Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','614Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','621Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','622Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','631Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','632Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','634Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','638Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','642Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','644Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','646Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','652Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','654Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','658Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','662Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','664Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','672Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','676Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','681Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','684Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','685Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','686Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','699Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','714Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','721Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','722Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','731Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','732Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','734Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','738Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','742Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','744Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','746Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','752Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','754Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','758Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','762Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','764Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','772Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','776Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','781Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','784Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','785Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','786Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','799Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','814Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','821Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','822Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','831Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','832Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','834Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','838Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','842Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','844Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','846Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','852Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','854Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','858Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','862Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','864Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','872Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','876Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','881Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','884Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','885Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','886Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','899Desconhecido ou nao especificado '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With StrZero(nI,3) // aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S029')
	aTabela	:=	{}
	cNomeArq := 'S029'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'PROFISSOES','01','CODIGO'   ,'CODIGO'   ,'C', 3,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'PROFISSOES','02','DESCRICAO','DESCRICAO','C',60,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S033')
	aTabela	:=	{}
	cNomeArq := 'S033'

	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','01','CODINDE'  ,'CODIGO INDEMNIZACAO'      ,'C',2 ,0,'@!'           ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','02','DESCRICAO','DESCRICAO'                ,'C',60,0,'@!'           ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','03','DIASRETRI','DIAS RETRIBUICAO(DIAS)'   ,'N',6 ,2,'@E 999.99'    ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','04','ANTIGSUP' ,'ANTIGUIDADE SUPERIOR(MES)','N',4 ,0,'9999'         ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','05','ANTIGSUPA','ANTIGUIDADE SUPERIOR(ANO)','N',4 ,0,'9999'         ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','06','MINIMOPAG','MINIMO A PAGAR'           ,'N',9 ,2,'@E 999,999.99','','','' } )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S033')
	aTabela	:=	{}
	cNomeArq := 'S033'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01CADUCIDADE DE CONTRATO A TERMO CERTO                          0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02POR MORTE DO EMPREGADOR                                       0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03EXTINCAO DA PESSOA COLECTIVA                                  0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04ENCERRAMENTO DA EMPRESA                                       0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05DESPEDIMENTO COLECTIVO                                        0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06EXTINCAO DE POSTO DE TRABALHO                                 0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07DESPEDIMENTO POR INADAPTACAO                                  0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08RESOLUCAO PELO TRABALHADOR                                    0.00   0   0     0.00'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With StrZero(nI,3) // aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABANGºAutor³ Tiago Malta        º Data ³  29/07/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Angola                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp310TABANG()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq :=	"S001"
Local nI		:=	0

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+cNomeArq)
	aTabela	:=	{}
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01BENGO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02BENGUELA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03BIE                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04CABINGA                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05CUANDO-CUBANGO                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06KWANZA-NORTE                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07KWANZA-SUL                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08CUNENE                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09HUAMBO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10HUILA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11LUANDA                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','12LUNDA-NORTE                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','13LUNDA-SUL                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','14MALANJE                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','15MOXICO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','16NAMIBE                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','17UIGE                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','18ZAIRE                         '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABVENºAutor³ Paulo Leme         º Data ³  04/12/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venezuela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABVEN()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq := ""
Local nI	   := 0

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S014')

	cNomeArq := 'S014'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','01','CODIGO'   ,'CODIGO'      ,'C', 2,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','02','DESCRICAO','DESCRICAO'   ,'C',50,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','03','DIASCONTR','VIG.CONTRATO','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','04','MINDCONTR','MINIMO  DIAS','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','05','MAXDCONTR','MAXIMO DIAS' ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','06','QTDRENOV' ,'RENOVACOES'  ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','07','PRAZOMIN' ,'PRAZO MINIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','08','PRAZOMAX' ,'PRAZO MAXIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','09','TIPO_QDP' ,'QDR. PESSOAL','C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))' ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','10','TIPO_BSO' ,'BAL. SOCIAL' ,'C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'       ,'','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Else
	DbSelectArea("RCB")
	DbSetOrder(3)
	If dbSeek(cFilRCB+'TIPO_QDP')
		If Alltrim(RCB->RCB_CODIGO)=='S014' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
	If dbSeek(cFilRCB+'TIPO_BSO')
		If Alltrim(RCB->RCB_CODIGO)=='S014' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S014')
	aTabela	:=	{}
	cNomeArq := 'S014'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01POR TIEMPO INDETERMINADO', '0','0','0','0','0','0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02POR TIEMPO DETERMINADO',   '0','0','0','0','0','0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03PARA UNA OBRA DETERMINADA','0','0','0','0','0','0'})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04SEM CONTRATO                                         0   0   0   0   0   0'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')
	aTabela	:=	{}
	cNomeArq := 'S020'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01Remuneração Salario'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02Remuneração Utilidades'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03Remuneração Bonificações'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04Remuneração Gratificação'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05Remuneração Antiguidade'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06Remuneração Outros'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07Imposto Retido'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08Deduções'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TabEQUºAutor³ Erika Kanamori     º Data ³  27/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Equador                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TabEQU()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Cargamento de Tablas ..."

ProcRegua(15)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S003  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S003')

	aTabela	:=	{}
	cNomeArq := 'S003'
	//													121234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Arabia                        Arabe                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Argentina                     Argentina                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Brasil                        Brasilera                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Canadá                        Canadiense                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Chile                         Chilena                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Colombia                      Colombiana                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Costa Rica                    Costaricense                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Cuba                          Cubana                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Ecuador                       Ecuatoriana                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Espana                        Espanola                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Mexico                        Mexicana                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','012Paraguay                      Paraguaya                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','013Peru                          Peruana                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','014Estados Unidos                Estadounidense                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','015Venezuela                     Venezolana                    '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S019									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S019')

	aTabela	:=	{}
	cNomeArq := 'S019'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','106 GASTOS DE VIVIENDA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','107 GASTOS DE EDUCACION'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','108 GASTOS DE SALUD'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','109 GASTOS DE VESTIMENTA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','110 GASTOS DE ALIMENTACION'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','106OGASTOS DE VIVIENDA OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','107OGASTOS DE EDUCACION OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','108OGASTOS DE SALUD OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','109OGASTOS DE VESTIMENTA OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','110OGASTOS DE ALIMENTACION OTROS EMPLEADORES'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S020									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')

	aTabela	:=	{}
	cNomeArq := 'S020'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01COSTA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02ORIENTE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03SIERRA'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABBRAºAutor³ Ademar Fernandes   º Data ³  07/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasil                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABBRA()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Carregamento de Tabelas ..."
Local cFilRCC_Us:= 	Replicate( " ", Len( cFilRCC ) )	 	// A Filial das Tabelas do Brasil devem ter origem compartilhada

ProcRegua(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S019  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S019')

	aTabela	:=	{}
	cNomeArq := 'S019'
	//													                      1         2         3         4         5         6         7         8         9         0         1         2
	//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','SJ2DESPEDIDA SEM JUSTA CAUSA, PELO EMPREGADOR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','JC2DESPEDIDA POR JUSTA CAUSA, PELO EMPREGADOR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','RA2RESCISAO ANTECIPADA, PELO EMPREGADOR, DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','FE2RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADOR INDIVIDUAL SEM CONTINUACAO DA ATIVIDADE DA EMPRESA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','FE1RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADOR INDIVIDUAL POR OPCAO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','RA1RESCISAO ANTECIPADA, PELO EMPREGADO, DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','SJ1RESCISAO CONTRATUAL A PEDIDO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','FT1RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','PD0EXTINCAO NORMAL DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','RI2RESCISAO INDIRETA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','CR0RESCISAO POR CULPA RECIPROCA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','FM0RESCISAO POR FORCA MAIOR'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S020  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')

	aTabela	:=	{}
	cNomeArq := 'S020'
	//													                      1         2         3         4         5         6         7         8         9         0         1         2
	//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','001SALARIO FIXO                                                                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','002GARANTIA                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','003PRODUCAO                                                                                            NSNS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','004HORAS EXTRAS                                                                                        NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','005HORAS TRABALHADAS NO MES                                                                            NSNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','006PERCENTAGEM                                                                                         SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','007COMISSAO                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','008PREMIOS                                                                                             SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','009MULTA ARTIGO 477 PARAGRAFO 8 CLT - ATRASO PAGAMENTO RESCISAO                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','010VIAGENS                                                                                             SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','011GORJETAS                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','012HORAS ADICIONAL NOTURNO                                                                             NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','013INSALUBRIDADE                                                                                       NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','014PERICULOSIDADE                                                                                      NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','015SOBREAVISO                                                                                          NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','016','016PRONTIDAO                                                                                           NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','017','017GRATIFICACAO                                                                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','018','018ADICIONAL TEMPO SERVICO                                                                             NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','019','019ADICIONAL POR TRANSFERENCIA DE LOCALIDADE DE TRABALHO                                               NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','020','020SALARIO FAMILIA NO QUE EXCEDER O VALOR LEGAL OBRIGATORIO                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','021','021ABONO OU GRATIFICACAO DE FERIAS, DESDE QUE EXCEDENTE A 20 DIAS DO SALARIO, CONCEDIDO EM VIRTUDE D...SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','022','022DIARIAS PARA VIAGEM, PELO SEU VALOR GLOBAL, QUANDO EXCEDEREM A 50% DA REMUNERACAO DO EMPREGADO, D...SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','023','023AJUDA DE CUSTO - ARTIGO 470 CLT                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','024','024ETAPAS, NO CASO DOS MARITIMOS                                                                       SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','025','025LICENCA PREMIO INDENIZADA                                                                           SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','026','026QUEBRA DE CAIXA                                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','027','027PARTICIPACAO DO EMPREGADO NOS LUCRO OU RESUTADOS DA EMPRESA, PAGA NOS TERMOS DA LEGISLACAO          SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','028','028INDENIZACAO RECEBIDA A TITULO DE INCENTIVO A DEMISSAO                                               SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','029','029BOLSA APRENDIZAGEM                                                                                  SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','030','030ABONOS DESVINCULADOS DO SALARIO                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','031','031GANHOS EVENTUAIS DESVINCULADOS DO SALARIO                                                           SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','032','032REEMBOLSO CRECHE PAGO EM CONFORMIDADE A LEGISLACAO TRABALHISTA                                      SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','033','033REEMBOLSO BABA PAGO EM CONFORMIDADE A LEGISLACAO TRABALHISTA E PREVIDENCIARIA                       SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','034','034GRATIFICACAO SEMESTRAL                                                                              SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','035','035NUMERO DE DIAS TRABALHADOS NO MES                                                                   NSNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','036','036MULTA DO ART. 476-A, PARAGRAFO 5,DA CLT                                                             SNNN'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S021  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S021')

	aTabela	:=	{}
	cNomeArq := 'S021'
																				  //             1         2         3         4         5
																				  // 12312345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','100RENDAS DE PROPRIEDADE IMOBILIARIA                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','110RENDAS DO TRASPORTE INTERNACIONAL                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','120LUCROS E DIVIDENTOS DISTRIBUIDOS                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','130JUROS                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','140ROYALTIES                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','150GANHOS DE CAPITAL                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','160RENDAS DO TRABALHO SEM VINCULO EMPREGATICIO       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','170RENDA DO TRABALHO COM VINCULO EMPREGATICIO        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','180REMUNERACAO DE ADMINISTRADORES                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','190RENDAS DE ARTISTAS E DE ESPORTISTAS               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','200PENSOES                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','210PAGAMENTOS GOVERNAMENTAIS                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','220RENDAS DE PROFESSORES E PESQUISADORES             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','230RENDAS DE ESTUDANTES E APRENDIZES                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','300OUTRAS RENDAS                                     '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S022  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S022')

	aTabela	:=	{}
	cNomeArq := 'S022'
																				  //             1         2         3         4         5         6         7         8
																				  // 12312345678901234567890123456789012345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','10RETENCAO DO IRRF - ALIQUOTA PADRAO                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','11RETENCAO DO IRRF - ALIQUOTA DA TABELA PROGRESSIVA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','12RETENCAO DO IRRF - ALIQUOTA DIFERENCIADA (PAISES TRIBUTACAO FAVORECIDA)          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','13RETENCAO DO IRRF - ALIQUOTA LIMITADA CONFORME CLAUSULA EM CONVENIO               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','30RETENCAO DO IRRF - OUTRAS HIPOTESES                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','40NAO-RETENCAO DO IRRF - ISENCAO ESTABELECIDA EM CONVENIO                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','41NAO-RETENCAO DO IRRF - ISENCAO PREVISTA EM LEI INTERNA                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','42NAO-RETENCAO DO IRRF - ALIQUOTA ZERO PREVISTA EM LEI INTERNA                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','43NAO-RETENCAO DO IRRF - PAGAMENTO ANTECIPADO DO IMPOSTO                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','44NAO-RETENCAO DO IRRF - MEDIDA JUDICIAL                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','50NAO-RETENCAO DO IRRF - OUTRAS HIPOTESES                                          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S023  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S023')

	aTabela	:=	{}
	cNomeArq := 'S023'
																				  //             1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
																				  // 1231234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','500A FONTE PAGADORA é MATRIZ DA BENEFICIARIA NO EXTERIOR.                                                                                                                                                                                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','510A FONTE PAGADORA é FILIAL, SUCURSAL OU AGENCIA DE BENEFICIARIA NO EXTERIOR.                                                                                                                                                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','520A FONTE PAGADORA é CONTROLADA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS PARAGRAFOS 1º E 2º DO ART. 243 DA LEI Nº 6404, DE 15 DE DEZEMBRO DE 1976.                                                                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','530A FONTE PAGADORA é CONTROLADORA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS PARAGRAFOR 1º E 2º DO ART. 243 DA LEI Nº 6404, DE 15 DE DEZEMBRO DE 1976.                                                                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','540A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR ESTAO SOB CONTROLE SOCIETARIO OU ADMINISTRATIVO COMUM OU QUANDO PELO MENOS 10% DO CAPITAL DE CADA UMA , PERTENCER A UMA MESMA PESSOA FISICA OU JURIDICA.                                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','550A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR TÊM PARTICIPACAO SOCIETARIA NO CAPITAL DE UMA TERCEIRA PESSOA JURIDICA, CUJA SOMA AS CARACTERIZE COMO CONTROLADORAS OU COLIGADAS NA FORMA DOS §§ 1º E 2º DO ART. 243 DA LEI Nº 6.404, DE 15 DE DEZ DE 1976'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','560A FONTE PAGADORA OU A BENEFICIARIA NO EXTERIOR MANTENHA CONTRATO DE EXCLUSIVIDADE COMO AGENTE, DISTRIBUIDOR OU CONCESSIONARIO NAS OPERACOES COM BENS,  SERVICOS E DIREITOS.                                                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','570A FONTE PAGADORA E A BENEFICIARIA MANTÉM ACORDO DE ATUACAO CONJUNTA.                                                                                                                                                                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','900NAO HA RELACAO ENTRE A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR.                                                                                                                                                                                     '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S024  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S024')

	aTabela	:=	{}
	cNomeArq := 'S024'
																				  //             1         2         3         4         5
																				  // 12312345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','105BRASIL                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','013AFEGANISTAO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','756AFRICA DO SUL                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','017ALBANIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','023ALEMANHA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','037ANDORRA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','040ANGOLA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','041ANGUILLA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','043ANTIGUA BARBUDA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','047ANTILHAS HOLANDESAS                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','053ARABIA SAUDITA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','059ARGELIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','063ARGENTINA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','064ARMENIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','065ARUBA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','016','073ARZEBAIJAO, REPUBLICA DO                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','017','069AUSTRALIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','018','072AUSTRIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','019','077BAHAMAS, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','020','080BAHREIN, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','021','081BANGLADESH                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','022','083BARBADOS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','023','085BELARUS, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','024','087BELGICA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','025','088BELIZE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','026','229BENIN                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','027','090BERMUDAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','028','097BOLIVIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','029','098BOSNIA-HERZEGOVINA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','030','101BOTSUANA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','031','108BRUNEI                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','032','111BULGARIA, REPUBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','033','031BURKINA FASO                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','034','115BURUNDI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','035','119BUTAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','036','127CABO VERDE, REPUBLICA DE                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','037','145CAMAROES                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','038','141CAMBOJA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','039','149CANADA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','040','151CANARIAS, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','041','153CASAQUISTAO, REPUBLICA DO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','042','154CATAR                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','043','137CAYMAN, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','044','788CHADE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','045','158CHILE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','046','160CHINA, REPUBLICA POPULAR                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','047','163CHIPRE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','048','511CHRISTMAS, ILHAS (NAVIDAD)                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','049','741CINGAPURA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','050','165COCOS-KEELING, ILHAS                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','051','169COLOMBIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','052','173COMORES, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','053','177CONGO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','054','888CONGO, REPÚBLICA DEMOCRÁTICA DO                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','055','183COOK, ILHAS                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','056','190COREIA, REPUBLICA                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','057','187COREIA, REPUBLICA POPULAR DEMOCRATICA             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','058','193COSTA DO MARFIM                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','059','196COSTA RICA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','060','198COVEITE                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','061','195CROACIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','062','199CUBA                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','063','998DELEGAÇÃO ESPECIAL DA PALESTINA                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','064','232DINAMARCA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','065','783DJIBUTI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','066','235DOMINICA, ILHA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','067','372DUBAI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','068','237DUBAI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','069','240EGITO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','070','687EL SALVADOR                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','071','244EMIRADOS ÁRABES UNIDOS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','072','243ERITREIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','073','239EQUADOR                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','074','247ESLOVACA, REPÚBLICA                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','075','246ESLOVÊNIA, REPÚBLICA DA                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','076','245ESPANHA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','077','249ESTADOS UNIDOS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','078','251ESTÔNIA, REPÚBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','079','253ETIÓPIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','080','255FALKLAND (ILHAS MALVINAS)                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','081','259FEROE, ILHAS                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','082','263FEZZAN                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','083','870FIDJI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','084','267FILIPINAS                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','085','271FINLANDIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','086','161FORMOSA(TAIWAN)                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','087','275FRANCA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','088','281GABAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','089','285GAMBIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','090','289GANA                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','091','291GEORGIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','092','293GIBRALTAR                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','093','297GRANADA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','094','301GRECIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','095','305GROENLANDIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','096','309GUADALUPE                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','097','313GUAM                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','098','317GUATEMALA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','099','337GUIANA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','100','325GUIANA FRANCESA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','101','329GUINE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','102','334GUINE-BISSAU                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','103','331GUINE-EQUATORIAL                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','104','341HAITI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','105','345HONDURAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','106','351HONG KONG                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','107','355HUNGRIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','108','357IEMEM                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','109','361INDIA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','110','365INDONESIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','111','367INGLATERRA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','112','372IRA, REPUBLICA ISLAMICA DO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','113','369IRAQUE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','114','375IRLANDA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','115','379ISLANDIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','116','383ISRAEL                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','117','386ITALIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','118','388IUGOSLAVIA, REPUBLICA FEDERATIVA DA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','119','391JAMAICA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','120','399JAPAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','121','150JERSEY, ILHA DO CANAL										 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','122','396JOHNSTON, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','123','403JORDANIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','124','411KIRIBATI                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','125','420LAOS, REPUBLICA POPULAR DEMOCRATICA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','126','423LEBUAN, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','127','426LESOTO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','128','427LETONIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','129','431LIBANO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','130','434LIBERIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','131','438LIBIA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','132','440LIECHTENSTEIN                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','133','442LITUÂNIA, REPÚBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','134','445LUXEMBURGO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','135','447MACAU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','136','449MACEDÔNIA, ANT.REP.IUGOSLAVA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','137','450MADAGASCAR                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','138','452MADEIRA, ILHA DA                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','139','455MALÁSIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','140','458MALAVI                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','141','461MALDIVAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','142','464MALI                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','143','467MALTA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','144','359MAN, ILHA DE                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','145','472MARIANAS DO NORTE                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','146','474MARROCOS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','147','476MARSHALL, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','148','477MARTINICA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','149','485MAURÍCIO                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','150','488MAURITÂNIA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','151','493MÉXICO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','152','093MIANMAR (BIRMÂNIA)                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','153','499MICRONÉSIA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','154','490MIDWAY, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','155','505MOÇAMBIQUE                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','156','494MOLDOVA, REPÚBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','157','495MÔNACO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','158','497MONGÓLIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','159','498MONTENEGRO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','160','501MONTSERRAT, ILHAS                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','161','507NAMÍBIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','162','508NAURU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','163','517NEPAL                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','164','521NICARÁGUA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','165','525NIGER                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','166','528NIGÉRIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','167','531NIUE, ILHA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','168','535NORFOLK, ILHA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','169','538NORUEGA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','170','542NOVA CALEDONIA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','171','548NOVA ZELANDIA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','172','556OMÃ                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','173','563PACIFICO, ILHAS DO (ADMINIST. DOS EUA)            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','174','566PACIFICO, ILHAS DO (POSSESSAO DOS EUA)            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','175','573PAISES BAIXOS (HOLANDA)                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','176','575PALAU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','177','580PANAMA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','178','545PAPUA NOVA GUINE                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','179','576PAQUISTAO                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','180','586PARAGUAI                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','181','589PERU                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','182','593PITCAIRN, ILHA DE                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','183','599POLINESIA FRANCESA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','184','603POLONIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','185','611PORTO RICO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','186','607PORTUGAL                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','187','623QUENIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','188','625QUIRGUIZ, REPUBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','189','628REINO UNIDO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','190','640REPUBLICA CENTRO-AFRICANA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','191','647REPUBLICA DOMINICANA                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','192','660REUNIAO, ILHA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','193','670ROMENIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','194','675RUANDA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','195','676RUSSIA, FEDERACAO DA                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','196','685SAARA OCIDENTAL                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','197','677SALOMAO, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','198','690SAMOA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','199','691SAMOA AMERICANA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','200','697SAN MARINO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','201','710SANTA HELENA                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','202','715SANTA LÚCIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','203','678SAINT KITTS E NEVIS                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','204','695SÃO CRISTÓVÃO E NEVES, ILHAS                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','205','700SÃO PEDRO E MIQUELON                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','206','720SÃO TOMÉ E PRÍNCIPE, ILHAS                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','207','705SÃO VICENTE E GRANADINAS                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','208','728SENEGAL                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','209','735SERRA LEOA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','210','737SERVIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','211','731SEYCHELLES                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','212','744SÍRIA, REPÚBLICA ÁRABE DA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','213','748SOMÁLIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','214','750SRI LANKA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','215','754SUAZILÂNDIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','216','759SUDÃO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','217','764SUÉCIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','218','767SUÍÇA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','219','770SURINAME                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','220','776TAILÂNDIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','221','772TADJIQUISTÃO, REPÚBLICA DO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','222','780TANZÂNIA, REPÚBLICA UNIDA DA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','223','791TCHECA, REPÚBLICA                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','224','782TERRITÓRIO BRITÂNICO NO OCEANO ÍNDICO             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','225','795TIMOR LESTE                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','226','800TOGO                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','227','810TONGA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','228','805TOQUELAU, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','229','815TRINIDAD E TOBAGO                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','230','820TUNÍSIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','231','823TURCAS E CAICOS, ILHAS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','232','824TURCOMENISTÃO, REPÚBLICA DO                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','233','827TURQUIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','234','828TUVALU                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','235','831UCRÂNIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','236','833UGANDA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','237','845URUGUAI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','238','847UZBEQUISTÃO, REPÚBLICA DO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','239','551VANUATU                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','240','848VATICANO, ESTADO DA CIDADE DO                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','241','873WAKE, ILHA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','242','850VENEZUELA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','243','858VIETNÃ                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','244','863VIRGENS, ILHAS (BRITÂNICAS)                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','245','866VIRGENS, ILHAS(EUA)                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','246','875WALLIS E FUTUNA, ILHAS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','247','888ZAIRE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','248','890ZÂMBIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','249','665ZIMBABUE                                          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TabAUSºAutor³ Equipe RH Inovacao º Data ³  14/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Australia                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TabAUS()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Load Tables ... Wait!"

ProcRegua(5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S006  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S002')

	aTabela	:=	{}
	cNomeArq := 'S002'
	//													   1231234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001SPAYG Withholding'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002SSuperannuation'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003SHELP'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004SSSFS'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S006  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S006')

	aTabela	:=	{}
	cNomeArq := 'S006'
	//													   1231234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Cars using the statutory formula'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Cars using the operating cost method'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Loans granted'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Debt waiver'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Expense payments'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Housing - units of accomodation provided'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Employees receiving living-away-from-home allowance'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Airline transport'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Board'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Property'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Income tax exempt body - entertainment'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','012Other benefits'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','013Car parking'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','014Meal entertainment'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S013  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S013')

	aTabela	:=	{}
	cNomeArq := 'S013'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Salaries and Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Allowances'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Bonuses/Commisions'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Termination Payments'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Superannuation'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Fringe Benefits'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Aprentice and Trainee Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Other Taxable Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Accounts Payable/Services'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Deduction'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Payable Tax'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return
