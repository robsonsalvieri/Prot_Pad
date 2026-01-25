#INCLUDE "WMSC010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Static oBrwSB2, oBrwSB8, oBrwSBF, oBrwDC3, oBrwSBE, oBrwDCH, oBrwSC9, oBrwSDD, oBrwSDC, oBrwSDA, oBrwDCF, oBrwSC2, oBrwSD4

Function WMSC010()
Local aCoors := FWGetDialogSize (oMainWnd )
Local oLayerPrin, oLayerDet, oLayerSeq
Local oPnlSB2, oPnlDC3, oPnlSBE, oPnlDet, oPnlDown1, oPnlDown2, oPnlDown3
Local oRelSB8, oRelSBF, oRelDC3, oRelSBE, oRelDCH, oRelSC9, oRelSDD, oRelSDC, oRelSDA, oRelDCF, oRelSC2, oRelSD4
Local oFolder

Local cPict  := PesqPict('SB2','B2_QATU')

Private aColsSX3 := {}
Private aColsSB2 := {}
Private aColsSBF := {}
Private aColsDC3 := {}
Private aColsSBE := {}
Private aColsDCH := {}
Private aColsSC9 := {}
Private aColsSDD := {}
Private aColsSDC := {}
Private aColsSDA := {}
Private aColsDCF := {}
Private aColsSC2 := {}
Private aColsSD4 := {}
Private aFolders := {}

Private aBoxSBE  := RetSx3Box(Posicione('SX3',2,'BE_STATUS' ,'X3CBox()'),,,1)
Private aBoxDC3  := RetSx3Box(Posicione('SX3',2,'DC3_EMBDES','X3CBox()'),,,1)
Private aBoxDCF  := RetSx3Box(Posicione('SX3',2,'DCF_STSERV','X3CBox()'),,,1)
Private aBoxSB1  := RetSx3Box(Posicione('SX3',2,'B1_TIPCONV','X3CBox()'),,,1)
Private aBoxDC32 := RetSx3Box(Posicione('SX3',2,'DC3_TIPREP','X3CBox()'),,,1)

Private oDispo, oAtual, oReser, oEmpen, oEnder
Private oBCred, oBest, oSEmp, oCEmp
Private oBloq, oProd, oPedido

Private oDlgPrinc
Private aSaldos := Array(5)
Private aPedido := Array(4)
Private aProduc := Array(3)

	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSC015()
	EndIf

	// Trata a altura da janela de acordo com a resolução
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel

	// Cria conteiner para os browses

	oLayerPrin:= FWLayer():New()
	oLayerPrin:Init( oDlgPrinc, .F., .T.)

	Chkfile( 'SBE',,'SBECON')
	Chkfile( 'DC3',,'DC3CON')
	Chkfile( 'SB8',,'SB8CON')

	// Define painel Master
	oLayerPrin:AddLine( 'UP', 40, .F.)
	oPnlSB2 := oLayerPrin:GetLinePanel ('UP')

	// Campos adicionais
	aColsSB2:= {;
	   {buscarSX3('B2_LOCAL',,aColsSX3)  	   ,{|| SB2->B2_LOCAL}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B2_COD',,aColsSX3)  	      ,{|| SB2->B2_COD  }   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B1_DESC',,aColsSX3)  	   ,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_DESC')} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_DESC',,,,1},;
		{buscarSX3('B1_UM',,aColsSX3)  		   ,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_UM')}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_UM',,,,1},;
		{buscarSX3('B1_SEGUM',,aColsSX3)  	   ,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_SEGUM')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_SEGUM',,,,1},;
		{buscarSX3('B2_QATU',STR0003,aColsSX3),{|| (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP - SB2->B2_QACLASS)},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B1_TIPCONV',,aColsSX3)	   ,{|| IF ((nSeek := Ascan(aBoxSB1, { |x| x[ 2 ] == Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_TIPCONV')})) > 0,AllTrim( aBoxSB1[ nSeek, 3 ] ),'')},'C',,1,,,.F.,,,,'B1_TIPCONV',,,,1},;
		{buscarSX3('B1_CONV',,aColsSX3)		   ,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_CONV')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_CONV',,,,1},;
		{buscarSX3('B9_DATA',STR0008,aColsSX3),{|| dDataBase},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B1_RASTRO',,aColsSX3)	   ,{|| If(Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_RASTRO')=='L',STR0009 /*Lote*/,If(Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_RASTRO')=='S',STR0035 /*Sub-Lote*/,STR0046))},'C',,1,,,.F.,,,,'B1_RASTRO',,,,1},;
		{buscarSX3('B1_LOCALIZ',,aColsSX3)	   ,{|| If( (RetFldProd(Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_COD'),"B1_LOCALIZ")=='S'),STR0045,STR0046)},'C',,1,,,.F.,,,,'B1_LOCALIZ',,,,1},;
		{buscarSX3('B5_CODZON',,aColsSX3)     ,{|| Posicione('SB5',1,xFilial('SB5')+SB2->B2_COD,'B5_CODZON')} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B5_CODZON',,,,1},;
		{buscarSX3('B9_DATA',STR0010,aColsSX3),{|| GetUltFech()},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B9_DATA',STR0011,aColsSX3),{|| GetUltFech()+ 1},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B9_DATA',STR0012,aColsSX3),{|| dDataBase},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
		}

	oBrwSB2 := FWMBrowse():New()
	oBrwSB2:SetOwner(oPnlSB2)
	oBrwSB2:SetAlias('SB2')
	oBrwSB2:SetFields(aColsSB2)
	oBrwSB2:SetOnlyFields({''})
	oBrwSB2:SetMenuDef('')
	oBrwSB2:SetProfileID('1')
	oBrwSB2:DisableDetails()
	oBrwSB2:SetFixedBrowse(.T.)
	oBrwSB2:SetAmbiente(.F.)
	oBrwSB2:SetWalkThru(.F.)
	oBrwSB2:SetChange({|| SetAtualiz()})
	oBrwSB2:AddButton(STR0024, "WMSC010KAD()",, 2, 0) // Kardex
	oBrwSB2:SetDescription(STR0002) // Saldo por Produto
	oBrwSB2:ForceQuitButton()

	// Define painel Detail
	oLayerPrin:AddLine( 'DOWN', 60, .F.)
	oPnlDet := oLayerPrin:GetLinePanel ('DOWN')

	// Saldo,Lote,Endereço,Seq. Abastecimento,Zona Alternativa,Pedido Liberado,Lote Bloqueado,Empenho,Endereçar,Serviço,OP,Empenho OP
	aFolders := {STR0027,STR0009,STR0028,STR0029,STR0030,STR0022,STR0031,STR0023,STR0007,STR0032,STR0018,STR0034}

	// Define Browse Superior
	oFolder := TFolder():New( 0, 0, aFolders,aFolders, oPnlDet,,,, .T.,,oPnlDet:NCLIENTWIDTH/2,oPnlDet:NCLIENTHEIGHT/2)
	oFolder:bChange := {|nFolder| AtuBrw(nFolder) }
	
	oLayerDet := FWLayer():New()
	oLayerDet:Init(oFolder:aDialogs[1], .F., .T.)

	oLayerDet:AddLine('DOWN1', 100, .F.)
	oLayerDet:AddCollumn('ALL1', 33.33, .T., 'DOWN1')
	oLayerDet:AddWindow('ALL1',"WIN1",STR0002,100,.F.,.T.,,'DOWN1',{ || }) // Saldo por Produto
	oPnlDown1 := oLayerDet:GetWinPanel('ALL1',"WIN1",'DOWN1')

	// Saldos por produto
	TSay():New( 21,10,{|| STR0003},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Disponível
	oDispo := TGet():New( 19,60,{|| aSaldos[1]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nDispo",,,,.T.)
	TSay():New( 36,10,{|| STR0004},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Atual
	oAtual := TGet():New( 34,60,{|| aSaldos[2]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nAtual",,,,.T.)
	TSay():New( 51,10,{|| STR0005},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Reservado
	oReser := TGet():New( 49,60,{|| aSaldos[3]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nReser",,,,.T.)
	TSay():New( 66,10,{|| STR0006},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Empenhado
	oEmpen := TGet():New( 64,60,{|| aSaldos[4]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEmpen",,,,.T.)
	TSay():New( 81,10,{|| STR0007},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // À Endereçar
	oEnder := TGet():New( 79,60,{|| aSaldos[5]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEnder",,,,.T.)

	oLayerDet:AddCollumn('ALL2', 33.33, .T., 'DOWN1')
	oLayerDet:AddWindow('ALL2',"WIN2",STR0022,100,.F.,.T.,,'DOWN1',{ || }) // Pedido Liberado
	oPnlDown2 := oLayerDet:GetWinPanel('ALL2',"WIN2",'DOWN1')

	// Saldos por Pedido
	TSay():New( 21,10,{|| STR0013},oPnlDown2,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Bloqueado Crédito
	oBCred := TGet():New( 19,60,{|| aPedido[1]}, oPnlDown2, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nBCred",,,,.T.)
	TSay():New( 36,10,{|| STR0014},oPnlDown2,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Bloqueado Estoque
	oBEst := TGet():New( 34,60,{|| aPedido[2]} , oPnlDown2, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nBEst",,,,.T.)
	TSay():New( 51,10,{|| STR0015},oPnlDown2,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Sem Empenho
	oSEmp := TGet():New( 49,60,{|| aPedido[3]} , oPnlDown2, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nSEmp",,,,.T.)
	TSay():New( 66,10,{|| STR0016},oPnlDown2,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Com Empenho
	oCEmp := TGet():New( 64,60,{|| aProduc[3]} , oPnlDown2, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nCEmp",,,,.T.)

	oLayerDet:AddCollumn('ALL3', 33.33, .T., 'DOWN1')
	oLayerDet:AddWindow('ALL3',"WIN3",STR0023,100,.F.,.T.,,'DOWN1',{ || }) // Empenho
	oPnlDown3 := oLayerDet:GetWinPanel('ALL3',"WIN3",'DOWN1')

	TSay():New( 21,10,{|| STR0017},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Bloqueado
	oBloq := TGet():New( 19,60,{|| aProduc[1]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nBloq',,,,.T.)

	TSay():New( 36,10,{|| STR0018},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Ordem de Produção
	oProd := TGet():New( 34,60,{|| aProduc[2]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nProd',,,,.T.)

	TSay():New( 51,10,{|| STR0019},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Pedido de Venda
	oPedido := TGet():New( 49,60,{|| aProduc[3]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nPedido',,,,.T.)

	// Define Browse Lote
	// Campos adicionais
	aColsSB8:= {;
		{buscarSX3('B8_DATA',,aColsSX3)   ,{|| SB8->B8_DATA}   ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_LOTECTL',,aColsSX3),{|| SB8->B8_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_NUMLOTE',,aColsSX3),{|| SB8->B8_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_DTVALID',,aColsSX3),{|| SB8->B8_DTVALID},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_DFABRIC',,aColsSX3),{|| SB8->B8_DFABRIC},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_SALDO',,aColsSX3)  ,{|| SB8->B8_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_QTDORI',,aColsSX3) ,{|| SB8->B8_QTDORI} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_EMPENHO',,aColsSX3),{|| SB8->B8_EMPENHO},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_SALDO2',,aColsSX3) ,{|| SB8->B8_SALDO2} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_EMPENH2',,aColsSX3),{|| SB8->B8_EMPENH2},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_QACLASS',,aColsSX3),{|| SB8->B8_QACLASS},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_LOTEFOR',,aColsSX3),{|| SB8->B8_LOTEFOR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_DOC',,aColsSX3)    ,{|| SB8->B8_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_SERIE',,aColsSX3)  ,{|| SB8->B8_SERIE}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
		}

	oBrwSB8 := FWMBrowse():New()
	oBrwSB8:SetOwner(oFolder:aDialogs[2])
	oBrwSB8:SetAlias('SB8')
	oBrwSB8:SetFields(aColsSB8)
	oBrwSB8:SetOnlyFields({''})
	oBrwSB8:SetMenuDef('')
	oBrwSB8:SetProfileID('2')
	oBrwSB8:DisableDetails()
	oBrwSB8:SetFixedBrowse(.T.)
	oBrwSB8:SetDescription(STR0039) // Saldo por Lote

	oRelSB8 := FWBrwRelation():New()
	oRelSB8:AddRelation(oBrwSB2,oBrwSB8,{{'B8_FILIAL',"xFilial('SB8')"},{'B8_LOCAL','B2_LOCAL'},{'B8_PRODUTO','B2_COD'},{'B8_SALDO','0','<>'}})

	// Saldo por Endereço
	aColsSBF:= {;
		{buscarSX3('BF_LOCALIZ',,aColsSX3)       ,{|| SBF->BF_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_LOTECTL',,aColsSX3)       ,{|| SBF->BF_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_NUMLOTE',,aColsSX3)       ,{|| SBF->BF_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B8_DTVALID',,aColsSX3)       ,{|| Posicione('SB8CON',3,xFilial('SB8')+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_LOTECTL+SBF->BF_NUMLOTE,'B8_DTVALID')},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,'B8_DTVALID',,,,1},;
		{buscarSX3('BF_NUMSERI',,aColsSX3)       ,{|| SBF->BF_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_QUANT',,aColsSX3)         ,{|| SBF->BF_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_EMPENHO',,aColsSX3)       ,{|| SBF->BF_EMPENHO},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_PRIOR',,aColsSX3)         ,{|| SBF->BF_PRIOR}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BF_ESTFIS',,aColsSX3)        ,{|| SBF->BF_ESTFIS} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC8_DESEST',,aColsSX3)       ,{|| Posicione('DC8',1,xFilial('DC8')+SBF->BF_ESTFIS,'DC8_DESEST')}												 ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC8_DESEST',,,,1},;
		{buscarSX3('BE_STATUS',,aColsSX3)        ,{|| IF ((nSeek := Ascan(aBoxSBE, { |x| x[ 2 ] == Posicione('SBECON',1,xFilial('SBE')+SBF->BF_LOCAL+SBF->BF_LOCALIZ,'BE_STATUS') })) > 0,AllTrim( aBoxSBE[ nSeek, 3 ] ),'')},'C',,1,,,.F.,,,,'BE_STATUS',,,,1},;
		{buscarSX3('BE_CODZON',,aColsSX3)        ,{|| Posicione('SBECON',1,xFilial('SBE')+SBF->BF_LOCAL+SBF->BF_LOCALIZ,'BE_CODZON')}							 ,'C',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,'BE_CODZON',,,,1},;
		{buscarSX3('DC2_CAMADA','Norma',aColsSX3),{|| GetNorma(Posicione('DC3CON',2,xFilial('DC3')+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_ESTFIS,'DC3_CODNOR'))}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,'DC2_CAMADA',,,,1};
		}

	oBrwSBF := FWMBrowse():New()
	oBrwSBF:SetAlias('SBF')
	oBrwSBF:SetOwner(oFolder:aDialogs[3])
	oBrwSBF:SetFields(aColsSBF)
	oBrwSBF:SetOnlyFields({''})
	oBrwSBF:SetMenuDef('')
	oBrwSBF:SetProfileID('3')
	oBrwSBF:DisableDetails()
	oBrwSBF:SetFixedBrowse(.T.)
	oBrwSBF:SetDescription(STR0040) // Saldo por Endereço

	oRelSBF := FWBrwRelation():New()
	oRelSBF:AddRelation(oBrwSB2,oBrwSBF,{{'BF_FILIAL',"xFilial('SBF')"},{'BF_LOCAL','B2_LOCAL'},{'BF_PRODUTO','B2_COD'},{'BF_QUANT','0','<>'}})


	oLayerSeq := FWLayer():New()
	oLayerSeq:Init(oFolder:aDialogs[4], .F., .T.)

	oLayerSeq:AddColumn( 'UPABAST', 50, .F.)
	oPnlDC3 := oLayerSeq:GetColPanel ('UPABAST')

	aColsDC3:= {;
		{buscarSX3('DC3_ORDEM',,aColsSX3)        ,{|| DC3->DC3_ORDEM},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC3_TPESTR',,aColsSX3)       ,{|| DC3->DC3_TPESTR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC8_DESEST',,aColsSX3)       ,{|| Posicione('DC8',1,xFilial('DC8')+DC3->DC3_TPESTR,'DC8_DESEST')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC8_DESEST',,,,1},;
		{buscarSX3('DC3_CODNOR',,aColsSX3)       ,{|| DC3->DC3_CODNOR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC2_DESNOR',,aColsSX3)       ,{|| Posicione('DC2',1,xFilial('DC2')+DC3->DC3_CODNOR,'DC2_DESNOR')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC2_DESNOR',,,,1},;
		{buscarSX3('DC3_PERREP',,aColsSX3)       ,{|| DC3->DC3_PERREP},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC3_QTDUNI',,aColsSX3)       ,{|| DC3->DC3_QTDUNI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC3_PERAPM',,aColsSX3)       ,{|| DC3->DC3_PERAPM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC3_EMBDES',,aColsSX3)	      ,{|| IF ((nSeek := Ascan(aBoxDC3, { |x| x[ 2 ] == DC3->DC3_EMBDES})) > 0,AllTrim( aBoxDC3[ nSeek, 3 ] ),'')}  ,'C',,1,,,.F.,,,,,,,,1},;
		{buscarSX3('DC3_NUNITI',,aColsSX3)       ,{|| DC3->DC3_NUNITI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 },;
		{buscarSX3('DC3_TIPREP',,aColsSX3)       ,{|| IF ((nSeek := Ascan(aBoxDC32, { |x| x[ 2 ] == DC3->DC3_TIPREP})) > 0,AllTrim( aBoxDC32[ nSeek, 3 ] ),'')},'C',,1,,,.F.,,,,,,,,1},;
		{buscarSX3('DC2_CAMADA',STR0038,aColsSX3),{|| GetNorma(DC3->DC3_CODNOR)},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 };
				}

	oBrwDC3 := FWMBrowse():New()
	oBrwDC3:SetAlias('DC3')
	oBrwDC3:SetOwner(oPnlDC3)
	oBrwDC3:SetFields(aColsDC3)
	oBrwDC3:SetOnlyFields({''})
	oBrwDC3:SetMenuDef('')
	oBrwDC3:SetProfileID('4')
	oBrwDC3:DisableDetails()
	oBrwDC3:SetFixedBrowse(.T.)
	oBrwDC3:SetDescription(STR0029) // Seq. Abastecimento

	oRelDC3 := FWBrwRelation():New()
	oRelDC3:AddRelation(oBrwSB2,oBrwDC3,{{'DC3_FILIAL',"xFilial('DC3')"},{'DC3_CODPRO','B2_COD'},{'DC3_LOCAL','B2_LOCAL'}})


	oLayerSeq:AddColumn( 'DOWNENDPICK', 50, .F.)
	oPnlSBE := oLayerSeq:GetColPanel ('DOWNENDPICK')

	// Picking Fixo
	aColsSBE:= {;
		{buscarSX3('BE_LOCALIZ',,aColsSX3),{|| SBE->BE_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('BE_CODZON',,aColsSX3) ,{|| SBE->BE_CODZON},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC4_DESZON',,aColsSX3),{|| Posicione('DC4',1,xFilial('DC4')+SBE->BE_CODZON,'DC4_DESZON')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC4_DESZON',,,,1},;
		{buscarSX3('BE_ESTFIS',,aColsSX3) ,{|| SBE->BE_ESTFIS},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC8_DESEST',,aColsSX3),{|| Posicione('DC8',1,xFilial('DC8')+SBE->BE_ESTFIS,'DC8_DESEST')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC8_DESEST',,,,1};
				}

	oBrwSBE := FWMBrowse():New()
	oBrwSBE:SetAlias('SBE')
	oBrwSBE:SetOwner(oPnlSBE)
	oBrwSBE:SetFields(aColsSBE)
	oBrwSBE:SetOnlyFields({''})
	oBrwSBE:SetMenuDef('')
	oBrwSBE:SetProfileID('5')
	oBrwSBE:DisableDetails()
	oBrwSBE:SetFixedBrowse(.T.)
	oBrwSBE:SetDescription(STR0042) // Picking Fixo

	oRelSBE := FWBrwRelation():New()
	oRelSBE:AddRelation(oBrwSB2,oBrwSBE,{{'BE_FILIAL',"xFilial('SBE')"},{'BE_LOCAL','B2_LOCAL'},{'BE_CODPRO','B2_COD'}})

	// Zona Alternativa
	aColsDCH:= {;
		{buscarSX3('DCH_ORDEM',,aColsSX3) ,{|| DCH->DCH_ORDEM},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCH_CODZON',,aColsSX3),{|| DCH->DCH_CODZON},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC4_DESZON',,aColsSX3),{|| Posicione('DC4',1,xFilial('DC4')+DCH->DCH_CODZON,'DC4_DESZON')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC4_DESZON',,,,1};
				}

	oBrwDCH := FWMBrowse():New()
	oBrwDCH:SetAlias('DCH')
	oBrwDCH:SetOwner(oFolder:aDialogs[5])
	oBrwDCH:SetFields(aColsDCH)
	oBrwDCH:SetOnlyFields({''})
	oBrwDCH:SetMenuDef('')
	oBrwDCH:SetProfileID('4')
	oBrwDCH:DisableDetails()
	oBrwDCH:SetFixedBrowse(.T.)
	oBrwDCH:SetDescription(STR0030) // Zona Alternativa

	oRelDCH := FWBrwRelation():New()
	oRelDCH:AddRelation(oBrwSB2,oBrwDCH,{{'DCH_FILIAL',"xFilial('DCH')"},{'DCH_CODPRO','B2_COD'}})

	// Pedido Liberado
	aColsSC9:= {;
		{buscarSX3('C9_PEDIDO',,aColsSX3) ,{|| SC9->C9_PEDIDO} ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_ITEM',,aColsSX3)   ,{|| SC9->C9_ITEM}   ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_SEQUEN',,aColsSX3) ,{|| SC9->C9_SEQUEN} ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_CLIENTE',,aColsSX3),{|| SC9->C9_CLIENTE},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_LOJA',,aColsSX3)   ,{|| SC9->C9_LOJA}   ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_LOTECTL',,aColsSX3),{|| SC9->C9_LOTECTL},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_NUMLOTE',,aColsSX3),{|| SC9->C9_NUMLOTE},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_NUMSERI',,aColsSX3),{|| SC9->C9_NUMSERI},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_DATALIB',,aColsSX3),{|| SC9->C9_DATALIB},"D",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C6_ENTREG',,aColsSX3) ,{|| Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO,"C6_ENTREG")},"D",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'C6_ENTREG',,,,1},;
		{buscarSX3('C9_QTDLIB',,aColsSX3) ,{|| SC9->C9_QTDLIB} ,"N",aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_BLCRED',,aColsSX3) ,{|| SC9->C9_BLCRED} ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_BLEST',,aColsSX3)  ,{|| SC9->C9_BLEST}  ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_BLWMS',,aColsSX3)  ,{|| SC9->C9_BLWMS}  ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_CARGA',,aColsSX3)  ,{|| SC9->C9_CARGA}  ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_SERVIC',,aColsSX3) ,{|| SC9->C9_SERVIC} ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_IDDCF',,aColsSX3)  ,{|| SC9->C9_IDDCF}  ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C9_ORDSEP',,aColsSX3) ,{|| SC9->C9_ORDSEP} ,"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSC9 := FWMBrowse():New()
	oBrwSC9:SetAlias('SC9')
	oBrwSC9:SetOwner(oFolder:aDialogs[6])
	oBrwSC9:SetFields(aColsSC9)
	oBrwSC9:SetOnlyFields({''})
	oBrwSC9:SetMenuDef('')
	oBrwSC9:SetProfileID('5')
	oBrwSC9:DisableDetails()
	oBrwSC9:SetFixedBrowse(.T.)
	oBrwSC9:SetDescription(STR0022) // Pedido Liberado

	oRelSC9 := FWBrwRelation():New()
	oRelSC9:AddRelation(oBrwSB2,oBrwSC9,{{'C9_FILIAL',"xFilial('SC9')"},{'C9_LOCAL','B2_LOCAL'},{'C9_PRODUTO','B2_COD'},{'C9_NFISCAL','SPACE(LEN(SC9->C9_NFISCAL))'}})


	// Lote Bloqueado
	aColsSDD:= {;
		{buscarSX3('DD_DOC',,aColsSX3)    ,{|| SDD->DD_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_LOTECTL',,aColsSX3),{|| SDD->DD_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_NUMLOTE',,aColsSX3),{|| SDD->DD_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_DTVALID',,aColsSX3),{|| SDD->DD_DTVALID},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_LOCALIZ',,aColsSX3),{|| SDD->DD_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_NUMSERI',,aColsSX3),{|| SDD->DD_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_QUANT',,aColsSX3)  ,{|| SDD->DD_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_SALDO',,aColsSX3)  ,{|| SDD->DD_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_QTDORIG',,aColsSX3),{|| SDD->DD_QTDORIG},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DD_MOTIVO',,aColsSX3),{|| Posicione('SX5',1,xFilial('SX5')+'E1'+SDD->DD_MOTIVO,'X5DESCRI()')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DD_MOTIVO',,,,1},;
		{buscarSX3('DD_OBSERVA',,aColsSX3),{|| SDD->DD_OBSERVA},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSDD := FWMBrowse():New()
	oBrwSDD:SetAlias('SDD')
	oBrwSDD:SetOwner(oFolder:aDialogs[7])
	oBrwSDD:SetFields(aColsSDD)
	oBrwSDD:SetOnlyFields({''})
	oBrwSDD:SetMenuDef('')
	oBrwSDD:SetProfileID('6')
	oBrwSDD:DisableDetails()
	oBrwSDD:SetFixedBrowse(.T.)
	oBrwSDD:SetDescription(STR0043) // Lote com Bloqueio

	oRelSDD := FWBrwRelation():New()
	oRelSDD:AddRelation(oBrwSB2,oBrwSDD,{{'DD_FILIAL',"xFilial('SDD')"},{'DD_LOCAL','B2_LOCAL'},{'DD_PRODUTO','B2_COD'},{'DD_SALDO','0','>'}})

	// Empenho
	aColsSDC:= {;
		{buscarSX3('DC_ORIGEM',,aColsSX3) ,{|| SDC->DC_ORIGEM} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_PEDIDO',,aColsSX3) ,{|| SDC->DC_PEDIDO} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_ITEM',,aColsSX3)   ,{|| SDC->DC_ITEM}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_SEQ',,aColsSX3)    ,{|| SDC->DC_SEQ}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_OP',,aColsSX3)     ,{|| SDC->DC_OP}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_TRT',,aColsSX3)    ,{|| SDC->DC_TRT}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_LOTECTL',,aColsSX3),{|| SDC->DC_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_NUMLOTE',,aColsSX3),{|| SDC->DC_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_LOCALIZ',,aColsSX3),{|| SDC->DC_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_NUMSERI',,aColsSX3),{|| SDC->DC_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_QUANT',,aColsSX3)  ,{|| SDC->DC_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_QTSEGUM',,aColsSX3),{|| SDC->DC_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DC_IDDCF',,aColsSX3)  ,{|| SDC->DC_IDDCF}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSDC := FWMBrowse():New()
	oBrwSDC:SetAlias('SDC')
	oBrwSDC:SetOwner(oFolder:aDialogs[8])
	oBrwSDC:SetFields(aColsSDC)
	oBrwSDC:SetOnlyFields({''})
	oBrwSDC:SetMenuDef('')
	oBrwSDC:DisableDetails()
	oBrwSDC:SetFixedBrowse(.T.)
	oBrwSDC:SetProfileID('7')
	oBrwSDC:SetDescription(STR0023) // Empenho

	oRelSDC := FWBrwRelation():New()
	oRelSDC:AddRelation(oBrwSB2,oBrwSDC,{{'DC_FILIAL',"xFilial('SDC')"},{'DC_LOCAL','B2_LOCAL'},{'DC_PRODUTO','B2_COD'}})


	// Endereçar
	aColsSDA:= {;
		{buscarSX3('DA_DATA',,aColsSX3)   ,{|| SDA->DA_DATA}           ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_LOTECTL',,aColsSX3),{|| SDA->DA_LOTECTL}        ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_NUMLOTE',,aColsSX3),{|| SDA->DA_NUMLOTE}        ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_SALDO',,aColsSX3)  ,{|| SDA->DA_SALDO}          ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_SALDO',,aColsSX3)  ,{|| 0}                      ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_QTDORI',,aColsSX3) ,{|| SDA->DA_QTDORI}         ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_QTSEGUM',,aColsSX3),{|| SDA->DA_QTSEGUM}        ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_QTDORI2',,aColsSX3),{|| SDA->DA_QTDORI2}        ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_TIPONF',,aColsSX3) ,{|| SDA->DA_TIPONF}         ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_ORIGEM',,aColsSX3) ,{|| SDA->DA_ORIGEM}         ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_DOC',,aColsSX3)    ,{|| SDA->DA_DOC}            ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_SERIE',,aColsSX3)  ,{|| SDA->DA_SERIE}          ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_CLIFOR',,aColsSX3) ,{|| SDA->DA_CLIFOR}         ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DA_LOJA',,aColsSX3)   ,{|| SDA->DA_LOJA}           ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSDA := FWMBrowse():New()
	oBrwSDA:SetAlias('SDA')
	oBrwSDA:SetOwner(oFolder:aDialogs[9])
	oBrwSDA:SetFields(aColsSDA)
	oBrwSDA:SetOnlyFields({''})
	oBrwSDA:SetMenuDef('')
	oBrwSDA:SetProfileID('8')
	oBrwSDA:DisableDetails()
	oBrwSDA:SetFixedBrowse(.T.)
	oBrwSDA:SetDescription(STR0044) // Saldo a Endereçar

	oRelSDA := FWBrwRelation():New()
	oRelSDA:AddRelation(oBrwSB2,oBrwSDA,{{'DA_FILIAL',"xFilial('SDA')"},{'DA_LOCAL','B2_LOCAL'},{'DA_PRODUTO','B2_COD'},{'DA_SALDO','0','<>'}/*,{'DA_DATA','DTOS(dDataBase)','<='}*/})

	aColsDCF:= {;
		{buscarSX3('DCF_SERVIC',,aColsSX3),{|| DCF->DCF_SERVIC},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_DATA',,aColsSX3)  ,{|| DCF->DCF_DATA}  ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_CARGA',,aColsSX3) ,{|| DCF->DCF_CARGA} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_DOCTO',,aColsSX3) ,{|| DCF->DCF_DOCTO} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_SERIE',,aColsSX3) ,{|| DCF->DCF_SERIE} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_CLIFOR',,aColsSX3),{|| DCF->DCF_CLIFOR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_LOJA',,aColsSX3)  ,{|| DCF->DCF_LOJA}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_LOTECT',,aColsSX3),{|| DCF->DCF_LOTECT},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_NUMLOT',,aColsSX3),{|| DCF->DCF_NUMLOT},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_QUANT',,aColsSX3) ,{|| DCF->DCF_QUANT} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_QTDORI',,aColsSX3),{|| DCF->DCF_QTDORI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_QTSEUM',,aColsSX3),{|| DCF->DCF_QTSEUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_ORIGEM',,aColsSX3),{|| DCF->DCF_ORIGEM},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_DOCORI',,aColsSX3),{|| DCF->DCF_DOCORI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_STSERV',,aColsSX3),{|| IF ((nSeek := Ascan(aBoxDCF, { |x| x[ 2 ] == DCF->DCF_STSERV })) > 0,AllTrim( aBoxDCF[ nSeek, 3 ] ),"")},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('DCF_ID',,aColsSX3)    ,{|| DCF->DCF_ID}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
		}

	oBrwDCF := FWMBrowse():New()
	oBrwDCF:SetAlias('DCF')
	oBrwDCF:SetOwner(oFolder:aDialogs[10])
	oBrwDCF:SetFields(aColsDCF)
	oBrwDCF:SetOnlyFields({''})
	oBrwDCF:AddLegend("DCF_STSERV=='1'"  ,'GREEN' ,AllTrim( aBoxDCF[ 1, 3 ] )) // Serviço não Executado
	oBrwDCF:AddLegend("DCF_STSERV=='2'"  ,'YELLOW',AllTrim( aBoxDCF[ 2, 3 ] )) // Serviço Interrompido
	oBrwDCF:AddLegend("DCF_STSERV=='3'"  ,'RED'   ,AllTrim( aBoxDCF[ 3, 3 ] )) // Serviço Executado
	oBrwDCF:AddLegend("DCF_STSERV=='4'"  ,'BLUE'  ,AllTrim( aBoxDCF[ 4, 3 ] )) // Serviço Em Conferencia
	oBrwDCF:SetMenuDef('')
	oBrwDCF:SetProfileID('9')
	oBrwDCF:DisableDetails()
	oBrwDCF:SetFixedBrowse(.T.)
	oBrwDCF:SetDescription(STR0032) // Serviço

	oRelDCF := FWBrwRelation():New()
	oRelDCF:AddRelation(oBrwSB2,oBrwDCF,{{'DCF_FILIAL',"xFilial('DCF')"},{'DCF_LOCAL','B2_LOCAL'},{'DCF_CODPRO','B2_COD'},{'DCF_STSERV','"3"','<>'}})

	// Ordem Produção
	aColsSC2:= {;
		{buscarSX3('C2_EMISSAO',,aColsSX3)     ,{|| SC2->C2_EMISSAO}                        ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_NUM',STR0041,aColsSX3)  ,{|| SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_DATPRI',,aColsSX3)      ,{|| SC2->C2_DATPRI}                         ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_DATPRF',,aColsSX3)      ,{|| SC2->C2_DATPRF}                         ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_QUANT',,aColsSX3)       ,{|| SC2->C2_QUANT}		                     ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_QUANT',STR0027,aColsSX3),{|| SC2->C2_QUANT-SC2->C2_QUJE}		       ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_QTSEGUM',,aColsSX3)     ,{|| SC2->C2_QTSEGUM}                        ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_STATUS',,aColsSX3)      ,{|| SC2->C2_STATUS}                         ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSC2 := FWMBrowse():New()
	oBrwSC2:SetAlias('SC2')
	oBrwSC2:SetOwner(oFolder:aDialogs[11])
	oBrwSC2:SetFields(aColsSC2)
	oBrwSC2:SetOnlyFields({''})
	oBrwSC2:SetMenuDef('')
	oBrwSC2:SetProfileID('12')
	oBrwSC2:DisableDetails()
	oBrwSC2:SetFixedBrowse(.T.)
	oBrwSC2:SetDescription(STR0018) // Ordem de produção

	oRelSC2 := FWBrwRelation():New()
	oRelSC2:AddRelation(oBrwSB2,oBrwSC2,{{'C2_FILIAL',"xFilial('SC2')"},{'C2_LOCAL','B2_LOCAL'},{'C2_PRODUTO','B2_COD'},{'C2_QUANT-C2_QUJE','0','>'}})

	// Empenho OP
	aColsSD4:= {;
		{buscarSX3('D4_DATA',,aColsSX3)   ,{|| SD4->D4_DATA}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_OP',,aColsSX3)     ,{|| SD4->D4_OP}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_TRT',,aColsSX3)    ,{|| SD4->D4_TRT}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_SEQ',,aColsSX3)    ,{|| SD4->D4_SEQ}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_LOTECTL',,aColsSX3),{|| SD4->D4_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_NUMLOTE',,aColsSX3),{|| SD4->D4_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_QTDEORI',,aColsSX3),{|| SD4->D4_QTDEORI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_QUANT',,aColsSX3)  ,{|| SD4->D4_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_QTSEGUM',,aColsSX3),{|| SD4->D4_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('D4_OPORIG',,aColsSX3) ,{|| SD4->D4_OPORIG} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSD4 := FWMBrowse():New()
	oBrwSD4:SetAlias('SD4')
	oBrwSD4:SetOwner(oFolder:aDialogs[12])
	oBrwSD4:SetFields(aColsSD4)
	oBrwSD4:SetOnlyFields({''})
	oBrwSD4:SetMenuDef('')
	oBrwSD4:SetProfileID('11')
	oBrwSD4:DisableDetails()
	oBrwSD4:SetFixedBrowse(.T.)
	oBrwSD4:SetDescription(STR0034) // Empenho Ordem Produção

	oRelSD4 := FWBrwRelation():New()
	oRelSD4:AddRelation(oBrwSB2,oBrwSD4,{{'D4_FILIAL',"xFilial('SD4')"},{'D4_LOCAL','B2_LOCAL'},{'D4_COD','B2_COD'}})


	// Ativa Browses
	oBrwSB2:Activate()
	oBrwSB8:Activate()
	oBrwSBF:Activate()
	oBrwDC3:Activate()
	oBrwSBE:Activate()
	oBrwDCH:Activate()
	oBrwSC9:Activate()
	oBrwSDD:Activate()
	oBrwSDC:Activate()
	oBrwSDA:Activate()
	oBrwDCF:Activate()
	oBrwSC2:Activate()
	oBrwSD4:Activate()

	// Ativa Relacionamentos
	oRelSB8:Activate()
	oRelSBF:Activate()
	oRelDC3:Activate()
	oRelSBE:Activate()
	oRelDCH:Activate()
	oRelSC9:Activate()
	oRelSDD:Activate()
	oRelSDC:Activate()
	oRelSDA:Activate()
	oRelDCF:Activate()
	oRelSC2:Activate()
	oRelSD4:Activate()


	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center

	SBECON->( dbCloseArea() )
	DC3CON->( dbCloseArea() )
	SB8CON->( dbCloseArea() )
Return(Nil)

//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Busca Data Ultimo Fechamento
/*/
//-----------------------------------------------------------
Static Function GetUltFech()
Local aAreaSB2 := SB2 -> (GetArea())
Local cAliSB9  := GetNextAlias()
Local dUltFech

	cQuery := "SELECT MAX(B9_DATA) AS B9_DATA FROM "+RETSQLNAME('SB9')+" WHERE B9_FILIAL='"+xFilial("SB9")+"' AND B9_LOCAL = '"+ SB2->B2_LOCAL + "' AND D_E_L_E_T_ = ' ' AND B9_COD = '" + SB2->B2_COD + "' AND B9_DATA < '"+DTOS(dDatabase)+"'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSB9,.F.,.T.)
	TCSETFIELD(cAliSB9,'B9_DATA','D')
	dUltFech := (cAliSB9)->B9_DATA
	(cAliSB9)->( DBCloseArea())

	RestArea(aAreaSB2)
Return dUltFech

//-----------------------------------------------------------
/*/{Protheus.doc} GetNorma
Busca Norma (Lastro x Camada)

@param 	cCODNOR 		(Obrigatório) Código da Norma

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Busca Norma

/*/
//-----------------------------------------------------------
Static Function GetNorma(cCODNOR)
Local aAreaSBF := SBF -> (GetArea())
Local aAreaDC3 := DC3 -> (GetArea())
Local nNorma

	DBSelectArea('DC2')
	DBSetOrder(1) // DC2_FILIAL+DC2_CODNOR
	DBSeek(xFilial('DC2')+cCODNOR)
	nNorma := DC2_LASTRO*DC2_CAMADA

	RestArea(aAreaSBF)
	RestArea(aAreaDC3)
Return nNorma

//-----------------------------------------------------------
/*/{Protheus.doc} SetAtualiz
Atualiza dados

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Atualiza dados

/*/
//-----------------------------------------------------------
Static Function SetAtualiz()
// Atualiza
Local aAreaSB2 := SB2 -> (GetArea())

	aSaldos := SetSaldos()
	aPedido := SetPedido()
	aProduc := SetProduc()

	// Atualiza Saldos do Produto
	oDispo:CtrlRefresh()
	oAtual:CtrlRefresh()
	oReser:CtrlRefresh()
	oEmpen:CtrlRefresh()
	oEnder:CtrlRefresh()

	// Atualiza Saldos Pedidos
	oBCred:CtrlRefresh()
	oBEst:CtrlRefresh()
	oSEmp:CtrlRefresh()
	oCEmp:CtrlRefresh()

	// Atualiza Saldos Produção
	oBloq:CtrlRefresh()
	oProd:CtrlRefresh()
	oPedido:CtrlRefresh()

	RestArea(aAreaSB2)
Return .T.
//-----------------------------------------------------------
/*/{Protheus.doc} SetSaldos
Calcula saldos

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Calcula saldos

/*/
//-----------------------------------------------------------
Static Function SetSaldos()
Local aRet := {}
	// Carrega dados
    aRet := {SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP - SB2->B2_QACLASS, SB2->B2_QATU, SB2->B2_RESERVA, SB2->B2_QEMP, SB2->B2_QACLASS}
Return aRet

//-----------------------------------------------------------
/*/{Protheus.doc} SetPedido
Calcula saldos (bloqueado crédito, bloqueado estoque e liberado)

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Calcula saldos

/*/
//-----------------------------------------------------------
Static Function SetPedido()
Local nCredi   := nEstoq := nLiber := 0
Local aRet 	 := {}
Local cAliSC9  := GetNextAlias()

	// Calculo bloqueado crédito, bloqueado estoque e liberado
	cQuery := " SELECT C9_BLCRED, C9_QTDLIB, C9_BLEST, C9_BLWMS FROM "+RETSQLNAME("SC9")
	cQuery += " WHERE C9_FILIAL='"+xFilial("SC9")+"' AND C9_LOCAL='"+SB2->B2_LOCAL+"' AND "+RETSQLNAME("SC9")+".D_E_L_E_T_ = ' ' AND C9_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery += " AND C9_NFISCAL=''"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSC9,.F.,.T.)
	While !Eof()
		Do Case
		Case !Empty((cAliSC9)->C9_BLCRED)
			nCredi += (cAliSC9)->C9_QTDLIB
		Case !Empty((cAliSC9)->C9_BLEST)
			nEstoq += (cAliSC9)->C9_QTDLIB
		Case Empty((cAliSC9)->C9_BLCRED) .AND. Empty((cAliSC9)->C9_BLEST) .AND. (cAliSC9)->C9_BLWMS = '01'
			nLiber += (cAliSC9)->C9_QTDLIB
		EndCase
		DBSkip()
	Enddo
	(cAliSC9)->( dbCloseArea() )
    aRet := {nCredi,nEstoq,nLiber}
Return aRet
//-----------------------------------------------------------
/*/{Protheus.doc} SetProduc
Calcula saldos (Empenhado e bloqueado)

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Calcula saldos

/*/
//-----------------------------------------------------------
Static Function SetProduc()
Local cAliSDC := GetNextAlias()
Local cAliSD4 := GetNextAlias()
Local aRet 	:= {}
Local nBloqu  := nProdu := nEmpPe := 0

	// Calculo empenhado e bloqueado
	cQuery := " SELECT DC_QUANT, DC_ORIGEM FROM "+RETSQLNAME("SDC")
	cQuery += " WHERE DC_FILIAL='"+xFilial("SDC")+"' AND DC_LOCAL='"+SB2->B2_LOCAL+"' AND "+RETSQLNAME("SDC")+".D_E_L_E_T_ = ' ' AND DC_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSDC,.F.,.T.)
	While !Eof()
		Do Case
		Case (cAliSDC)->DC_ORIGEM == 'SC6'
			nEmpPe += (cAliSDC)->DC_QUANT
		Case (cAliSDC)->DC_ORIGEM == 'SDD'
			nBloqu += (cAliSDC)->DC_QUANT
		EndCase
		DBSkip()
	Enddo
	(cAliSDC)->( dbCloseArea() )

	// Calculo produção
	cQuery := " SELECT D4_QUANT FROM "+RETSQLNAME("SD4")
	cQuery += " WHERE D4_FILIAL='"+xFilial("SD4")+"' AND D4_LOCAL='"+SB2->B2_LOCAL+"' AND "+RETSQLNAME("SD4")+".D_E_L_E_T_ = ' ' AND D4_COD = '"+SB2->B2_COD+"'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSD4,.F.,.T.)
	While !Eof()
		nProdu += (cAliSD4)->D4_QUANT
		DBSkip()
	Enddo
	(cAliSD4)->( dbCloseArea() )
	aRet := {nBloqu, nProdu, nEmpPe }
Return aRet
//-----------------------------------------------------------
/*/{Protheus.doc} WMSC010KAD
Kardex

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Kardex

/*/
//-----------------------------------------------------------
Function WMSC010KAD()
Local aAreaSB2 := SB2 -> (GetArea())
Local aAreaSB1 := SB1 -> (GetArea())
	Processa({|| ProcRegua(0), IncProc(STR0025 + '...'), WMSC011(), IncProc(STR0026 + '...')} , STR0024, STR0036 + '...', .F.) // Aguarde, Encerrando, Kardex, Buscando informações
	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
Return .T.
//-----------------------------------------------------------
/*/{Protheus.doc} AtuBrw
//Atualização do browser na troca de folder
@author felipe.m
@since 28/12/2017
@version 1.0
/*/
//-----------------------------------------------------------
Static Function AtuBrw(nFolder)
	Do Case
		Case nFolder == 2
			oBrwSB8:Refresh()
		Case nFolder == 3
			oBrwSBF:Refresh()
		Case nFolder == 4
			oBrwDC3:Refresh()
			oBrwSBE:Refresh()
		Case nFolder == 5
			oBrwDCH:Refresh()
		Case nFolder == 6
			oBrwSC9:Refresh()
		Case nFolder == 7
			oBrwSDD:Refresh()
		Case nFolder == 8
			oBrwSDC:Refresh()
		Case nFolder == 9
			oBrwSDA:Refresh()
		Case nFolder == 10
			oBrwDCF:Refresh()
		Case nFolder == 11
			oBrwSC2:Refresh()
		Case nFolder == 12
			oBrwSD4:Refresh()
	EndCase
Return .T.
