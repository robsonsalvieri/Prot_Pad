#INCLUDE "WMSC015.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Static oBrwSB2, oBrwD14, oBrwSB8, oBrwSDD, oBrwDC3, oBrwSBE, oBrwDCH, oBrwSC9, oBrwSDC, oBrwDCF, oBrwSC2, oBrwSD4, oBrwDH1

Function WMSC015()
Local aCoors := FWGetDialogSize (oMainWnd )
Local oLayerPrin, oLayerDet, oLayerSeq
Local oPnlSB2, oPnlDet, oPnlDown1, oPnlDown2, oPnlDown3, oPnlTree, oPnlD14
Local oRelSB8, oRelSDD, oRelDC3, oRelSBE, oRelDCH, oRelSC9, oRelSDC, oRelDCF, oRelSC2, oRelSD4, oRelDH1
Local cPict   := PesqPict('SB2','B2_QATU')
Local lCpoDC8 :=WmsX312120("DC8","DC8_NRUNIT")

Private lastProd  := ""
Private lastLocal := ""
Private oTree, oFolder

Private aColsSX3 := {}
Private aColsSB2 := {}
Private aColsSB8 := {}
Private aColsSDD := {}
Private aColsDC3 := {}
Private aColsSBE := {}
Private aColsDCH := {}
Private aColsSC9 := {}
Private aColsSDC := {}
Private aColsDCF := {}
Private aColsSC2 := {}
Private aColsSD4 := {}

Private aBoxDC3  := RetSx3Box(Posicione('SX3',2,'DC3_EMBDES','X3CBox()'),,,1)
Private aBoxDCF  := RetSx3Box(Posicione('SX3',2,'DCF_STSERV','X3CBox()'),,,1)
Private aBoxSB1  := RetSx3Box(Posicione('SX3',2,'B1_TIPCONV','X3CBox()'),,,1)
Private aBoxDC32 := RetSx3Box(Posicione('SX3',2,'DC3_TIPREP','X3CBox()'),,,1)

Private oDispo, oAtual, oReser,  oEmpen, oEnder
Private oBCred, oBest,  oSEmp,   oCEmp
Private oQtTNP, oQtNPT, oEmpNF , oEmpSA
Private oBloq,  oProd,  oPedido

Private oDlgPrinc
Private aSaldos := Array(7)
Private aPedido := Array(4)
Private aProduc := Array(5)
	If !SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSC010()
	EndIf

	If !Pergunte("WMSC015",.T.)
		Return(Nil)
	EndIf
	// Trata a altura da janela de acordo com a resolução
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Consulta Saldo do Produto"
	// Cria conteiner para os browses
	oLayerPrin:= FWLayer():New()
	oLayerPrin:Init( oDlgPrinc, .F., .T.)
	// Define painel Master
	oLayerPrin:AddLine( 'UP', 43, .F.)
	oPnlSB2 := oLayerPrin:GetLinePanel ('UP')
	// Campos adicionais
	aColsSB2:= {;
		{buscarSX3('B2_LOCAL',,aColsSX3),{|| SB2->B2_LOCAL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B2_COD',,aColsSX3),{|| SB2->B2_COD  },'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('B1_DESC',,aColsSX3),{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_DESC')} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_DESC',,,,1},;
		{buscarSX3('B1_UM',,aColsSX3),{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_UM')}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_UM',,,,1},;
		{buscarSX3('B1_SEGUM',,aColsSX3),{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_SEGUM')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_SEGUM',,,,1},;
		{buscarSX3('B2_QATU',STR0003,aColsSX3),{|| SaldoSB2()},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Disponível
		{buscarSX3('B1_TIPCONV',,aColsSX3),{|| IF ((nSeek := Ascan(aBoxSB1, { |x| x[ 2 ] == Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_TIPCONV')})) > 0,AllTrim( aBoxSB1[ nSeek, 3 ] ),'')},'C',,1,,,.F.,,,,,,,,1},;
		{buscarSX3('B1_CONV',,aColsSX3),{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_CONV')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B1_CONV',,,,1},;
		{buscarSX3('B9_DATA',STR0008,aColsSX3),{|| dDataBase},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Data Limite
		{buscarSX3('B1_RASTRO',,aColsSX3),{|| If(Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_RASTRO')=='L',STR0009 /*Lote*/,If(Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'B1_RASTRO')=='S',STR0035 /*Sub-Lote*/,STR0046))},'C',,1,,,.F.,,,,'B1_RASTRO',,,,1},; // Lote // Sub-Lote // Não
		{buscarSX3('B5_CODZON',,aColsSX3),{|| Posicione('SB5',1,xFilial('SB5')+SB2->B2_COD,'B5_CODZON')} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'B5_CODZON',,,,1},;
		{buscarSX3('B9_DATA',STR0010,aColsSX3),{|| GetUltFech()},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Data Ultimo Fechamento
		{buscarSX3('B9_DATA',STR0011,aColsSX3),{|| GetUltFech()+ 1},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Data Inicial
		{buscarSX3('B9_DATA',STR0012,aColsSX3),{|| dDataBase},'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Data Final
	}

	oBrwSB2 := FWMBrowse():New()
	oBrwSB2:SetOwner(oPnlSB2)
	oBrwSB2:SetAlias('SB2')
	oBrwSB2:SetFields(aColsSB2)
	oBrwSB2:SetOnlyFields({''})
	oBrwSB2:SetMenuDef('')
	oBrwSB2:SetProfileID('SB2')
	oBrwSB2:DisableDetails()
	oBrwSB2:SetFixedBrowse(.T.)
	oBrwSB2:SetAmbiente(.F.)
	oBrwSB2:SetWalkThru(.F.)
	oBrwSB2:SetFilterDefault("@ "+RetFilSB2())
	oBrwSB2:SetChange({|| SetAtualiz()})
	oBrwSB2:AddButton(STR0024,{ || KardexSld() },, 2, 0) // Kardex
	oBrwSB2:SetDescription(STR0002) // Saldo por Produto
	oBrwSB2:ForceQuitButton()

	// Define painel Detail
	oLayerPrin:AddLine( 'DOWN', 57, .F.)
	oPnlDet := oLayerPrin:GetLinePanel ('DOWN')

	// Saldo,Lote,WMS, Seq. Abastecimento,Picking Fixo, Zona Alternativa,Pedido Liberado,Lote Bloqueado,Empenho,Endereçar,Serviço,OP,Empenho OP
	aFolders := {STR0027,STR0009,STR0028,STR0029,STR0042,STR0030,STR0022,STR0043,STR0006,STR0032,STR0047,STR0048,STR0049}
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
	oDispo := TGet():New( 19,65,{|| aSaldos[1]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nDispo",,,,.T.)
	TSay():New( 36,10,{|| STR0004},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Atual
	oAtual := TGet():New( 34,65,{|| aSaldos[2]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nAtual",,,,.T.)
	TSay():New( 51,10,{|| STR0005},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Reservado
	oReser := TGet():New( 49,65,{|| aSaldos[3]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nReser",,,,.T.)
	TSay():New( 66,10,{|| STR0006},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Empenhado
	oEmpen := TGet():New( 64,65,{|| aSaldos[4]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEmpen",,,,.T.)
	TSay():New( 81,10,{|| STR0053},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // À Endereçar STR0007
	oEnder := TGet():New( 79,65,{|| aSaldos[5]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEnder",,,,.T.)
	TSay():New( 96,10,{|| STR0054},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Terc. em Nosso Poder
	oQtTNP := TGet():New( 94,65,{|| aSaldos[6]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nQtTNP",,,,.T.)
	TSay():New( 111,10,{|| STR0055},oPnlDown1,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)// Nosso em Poder Terc.
	oQtNPT := TGet():New( 109,65,{|| aSaldos[7]} , oPnlDown1, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nQNPT",,,,.T.)

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
	oCEmp := TGet():New( 64,60,{|| aPedido[4]} , oPnlDown2, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nCEmp",,,,.T.)

	oLayerDet:AddCollumn('ALL3', 33.33, .T., 'DOWN1')
	oLayerDet:AddWindow('ALL3',"WIN3",STR0023,100,.F.,.T.,,'DOWN1',{ || }) // Empenho
	oPnlDown3 := oLayerDet:GetWinPanel('ALL3',"WIN3",'DOWN1')

	TSay():New( 21,10,{|| STR0017},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Bloqueado
	oBloq := TGet():New( 19,60,{|| aProduc[1]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nBloq',,,,.T.)

	TSay():New( 36,10,{|| STR0018},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Ordem de Produção
	oProd := TGet():New( 34,60,{|| aProduc[2]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nProd',,,,.T.)

	TSay():New( 51,10,{|| STR0019},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Pedido de Venda
	oPedido := TGet():New( 49,60,{|| aProduc[3]}, oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nPedido',,,,.T.)

	TSay():New( 66,10,{|| STR0051},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Empenhada N.F.s
	oEmpNF := TGet():New( 64,60,{|| aProduc[4]} , oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEmpNF",,,,.T.)

	TSay():New( 81,10,{|| STR0052},oPnlDown3,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Empenho S.A.
	oEmpSA := TGet():New( 79,60,{|| aProduc[5]} , oPnlDown3, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,"nEmpSA",,,,.T.)

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
	oBrwSB8:SetProfileID('SB8')
	oBrwSB8:DisableDetails()
	oBrwSB8:AddButton(STR0024,{ || KardexLot() },, 2, 0) // Kardex
	oBrwSB8:SetFixedBrowse(.T.)
	oBrwSB8:SetDescription(STR0039) // Saldo por Lote

	oRelSB8 := FWBrwRelation():New()
	oRelSB8:AddRelation(oBrwSB2,oBrwSB8,{{'B8_FILIAL',"xFilial('SB8')"},{'B8_LOCAL','B2_LOCAL'},{'B8_PRODUTO','B2_COD'},{'B8_SALDO','0','<>'}})

	oLayerSeq := FWLayer():New()
	oLayerSeq:Init(oFolder:aDialogs[3], .F., .T.)
	oLayerSeq:AddColumn( 'UPABAST', 75, .F.)
	oPnlD14 := oLayerSeq:GetColPanel ('UPABAST')

	oBrwD14 := FWMBrowse():New()
	oBrwD14:SetAlias("D14")
	oBrwD14:SetOwner(oPnlD14)
	oBrwD14:SetMenuDef('')
	oBrwD14:SetProfileID('D14')
	oBrwD14:DisableDetails()
	oBrwD14:AddButton(STR0024, { || KardexEnd() },, 2, 0) // Kardex
	oBrwD14:SetFixedBrowse(.T.)
	oBrwD14:SetDescription(STR0028) // Endereço"

	aAdd(aColsDC3,{buscarSX3('DC3_ORDEM',,aColsSX3)        ,{|| DC3->DC3_ORDEM},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC3_TPESTR',,aColsSX3)       ,{|| DC3->DC3_TPESTR},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC8_DESEST',,aColsSX3)       ,{|| Posicione('DC8',1,xFilial('DC8')+DC3->DC3_TPESTR,'DC8_DESEST')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC8_DESEST',,,.T.,1})
	If lCpoDC8
		aAdd(aColsDC3,{buscarSX3('DC8_NRUNIT',STR0056,aColsSX3),{|| Posicione('DC8',1,xFilial('DC8')+DC3->DC3_TPESTR,'DC8_NRUNIT')},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,'DC8_NRUNIT',,,,1 })
	EndIf
	aAdd(aColsDC3,{buscarSX3('DC3_NUNITI',,aColsSX3)       ,{|| DC3->DC3_NUNITI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC2_DESNOR',,aColsSX3)       ,{|| Posicione('DC2',1,xFilial('DC2')+DC3->DC3_CODNOR,'DC2_DESNOR')},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,'DC2_DESNOR',,,,1})
	aAdd(aColsDC3,{buscarSX3('DC3_PERREP',,aColsSX3)       ,{|| DC3->DC3_PERREP},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC3_QTDUNI',,aColsSX3)       ,{|| DC3->DC3_QTDUNI},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC3_PERAPM',,aColsSX3)       ,{|| DC3->DC3_PERAPM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })
	aAdd(aColsDC3,{buscarSX3('DC3_EMBDES',,aColsSX3)       ,{|| IF ((nSeek := Ascan(aBoxDC3, { |x| x[ 2 ] == DC3->DC3_EMBDES})) > 0,AllTrim( aBoxDC3[ nSeek, 3 ] ),'')}  ,'C',,1,,,.F.,,,,,,,,1})
	aAdd(aColsDC3,{buscarSX3('DC3_TIPREP',,aColsSX3)       ,{|| IF ((nSeek := Ascan(aBoxDC32, { |x| x[ 2 ] == DC3->DC3_TIPREP})) > 0,AllTrim( aBoxDC32[ nSeek, 3 ] ),'')},'C',,1,,,.F.,,,,,,,,1})
	aAdd(aColsDC3,{buscarSX3('DC2_CAMADA',STR0038,aColsSX3),{|| GetNorma(DC3->DC3_CODNOR)},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1 })

	oLayerSeq:AddColumn('DOWNENDPICK', 25, .F.)
	oLayerSeq:AddWindow('DOWNENDPICK','DOWNENWIN', 'Estrutura',100,.F.,.T.)
	oPnlTree := oLayerSeq:getWinPanel ('DOWNENDPICK','DOWNENWIN')

	// Estrutura armazenagem
	oTree := DbTree():New(0,0,0,0,oPnlTree,{||C015CARGO()},/*bRClick*/,.T.,/*lDisable*/,/*oFont*/,/*cHeaders*/)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	oTree:SetScroll(1,.T.)
	oTree:SetScroll(2,.T.)

	oBrwDC3 := FWMBrowse():New()
	oBrwDC3:SetAlias('DC3')
	oBrwDC3:SetOwner(oFolder:aDialogs[4])
	oBrwDC3:SetFields(aColsDC3)
	oBrwDC3:SetOnlyFields({''})
	oBrwDC3:SetMenuDef('')
	oBrwDC3:SetProfileID('DC3')
	oBrwDC3:DisableDetails()
	oBrwDC3:SetFixedBrowse(.T.)
	oBrwDC3:SetDescription(STR0029) // Seq. Abastecimento

	oRelDC3 := FWBrwRelation():New()
	oRelDC3:AddRelation(oBrwSB2,oBrwDC3,{{'DC3_FILIAL',"xFilial('DC3')"},{'DC3_CODPRO','B2_COD'},{'DC3_LOCAL','B2_LOCAL'}})

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
	oBrwSBE:SetOwner(oFolder:aDialogs[5])
	oBrwSBE:SetFields(aColsSBE)
	oBrwSBE:SetOnlyFields({''})
	oBrwSBE:SetMenuDef('')
	oBrwSBE:SetProfileID('SBE')
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
	oBrwDCH:SetOwner(oFolder:aDialogs[6])
	oBrwDCH:SetFields(aColsDCH)
	oBrwDCH:SetOnlyFields({''})
	oBrwDCH:SetMenuDef('')
	oBrwDCH:SetProfileID('DCH')
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
	oBrwSC9:SetOwner(oFolder:aDialogs[7])
	oBrwSC9:SetFields(aColsSC9)
	oBrwSC9:SetOnlyFields({''})
	oBrwSC9:SetMenuDef('')
	oBrwSC9:SetProfileID('SC9')
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
	oBrwSDD:SetOwner(oFolder:aDialogs[8])
	oBrwSDD:SetFields(aColsSDD)
	oBrwSDD:SetOnlyFields({''})
	oBrwSDD:SetMenuDef('')
	oBrwSDD:SetProfileID('SDD')
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
	oBrwSDC:SetOwner(oFolder:aDialogs[9])
	oBrwSDC:SetFields(aColsSDC)
	oBrwSDC:SetOnlyFields({''})
	oBrwSDC:SetMenuDef('')
	oBrwSDC:DisableDetails()
	oBrwSDC:SetFixedBrowse(.T.)
	oBrwSDC:SetProfileID('SDC')
	oBrwSDC:SetDescription(STR0023) // Empenho

	oRelSDC := FWBrwRelation():New()
	oRelSDC:AddRelation(oBrwSB2,oBrwSDC,{{'DC_FILIAL',"xFilial('SDC')"},{'DC_LOCAL','B2_LOCAL'},{'DC_PRODUTO','B2_COD'}})

	// Servico
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
	oBrwDCF:SetProfileID('DCF')
	oBrwDCF:DisableDetails()
	oBrwDCF:SetFixedBrowse(.T.)
	oBrwDCF:SetDescription(STR0032) // Serviço

	oRelDCF := FWBrwRelation():New()
	oRelDCF:AddRelation(oBrwSB2,oBrwDCF,{{'DCF_FILIAL',"xFilial('DCF')"},{'DCF_LOCAL','B2_LOCAL'},{'DCF_CODPRO','B2_COD'},{'DCF_STSERV','"3"','<>'},{'DCF_STSERV','"0"','<>'}})

	// Ordem Produção
	aColsSC2:= {;
		{buscarSX3('C2_EMISSAO',,aColsSX3)     ,{|| SC2->C2_EMISSAO}                        ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_NUM',STR0041,aColsSX3)  ,{|| SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;// Ordem
		{buscarSX3('C2_DATPRI',,aColsSX3)      ,{|| SC2->C2_DATPRI}                         ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_DATPRF',,aColsSX3)      ,{|| SC2->C2_DATPRF}                         ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_QUANT',,aColsSX3)       ,{|| SC2->C2_QUANT}		                     ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_QUANT',STR0027,aColsSX3),{|| SC2->C2_QUANT-(SC2->C2_QUJE + SC2->C2_PERDA)}		       ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Saldo
		{buscarSX3('C2_QTSEGUM',,aColsSX3)     ,{|| SC2->C2_QTSEGUM}                        ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
		{buscarSX3('C2_STATUS',,aColsSX3)      ,{|| SC2->C2_STATUS}                         ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}

	oBrwSC2 := FWMBrowse():New()
	oBrwSC2:SetAlias('SC2')
	oBrwSC2:SetOwner(oFolder:aDialogs[11])
	oBrwSC2:SetFields(aColsSC2)
	oBrwSC2:SetOnlyFields({''})
	oBrwSC2:SetMenuDef('')
	oBrwSC2:SetProfileID('SC2')
	oBrwSC2:DisableDetails()
	oBrwSC2:SetFixedBrowse(.T.)
	oBrwSC2:SetDescription(STR0018) // Ordem de produção

	oRelSC2 := FWBrwRelation():New()
	oRelSC2:AddRelation(oBrwSB2,oBrwSC2,{{'C2_FILIAL',"xFilial('SC2')"},{'C2_LOCAL','B2_LOCAL'},{'C2_PRODUTO','B2_COD'},{'C2_QUANT-(C2_QUJE+C2_PERDA)','0','>'}})
	
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
	oBrwSD4:SetProfileID('SD4')
	oBrwSD4:DisableDetails()
	oBrwSD4:SetFixedBrowse(.T.)
	oBrwSD4:SetDescription(STR0034) // Empenho Ordem Produção

	oRelSD4 := FWBrwRelation():New()
	oRelSD4:AddRelation(oBrwSB2,oBrwSD4,{{'D4_FILIAL',"xFilial('SD4')"},{'D4_LOCAL','B2_LOCAL'},{'D4_COD','B2_COD'}})

	//Movimentos Internos
	oBrwDH1 := FWMBrowse():New()
	oBrwDH1:SetAlias('DH1')
	oBrwDH1:SetOwner(oFolder:aDialogs[13])
	oBrwDH1:SetMenuDef('')
	oBrwDH1:SetProfileID('DH1')
	oBrwDH1:DisableDetails()
	oBrwDH1:SetFixedBrowse(.T.)
	oBrwDH1:SetFilterDefault( "DH1->DH1_STATUS == '1' .AND. DH1->DH1_TM > '500'" )
	oBrwDH1:SetDescription(STR0050) // Movimentos Internos Com Reserva

	oRelDH1 := FWBrwRelation():New()
	oRelDH1:AddRelation(oBrwSB2,oBrwDH1,{{'DH1_FILIAL',"xFilial('DH1')"},{'DH1_LOCAL','B2_LOCAL'},{'DH1_PRODUT','B2_COD'}})

	// Ativa Browses
	oBrwSB8:Activate()
	oBrwSDD:Activate()
	oBrwD14:Activate()
	oBrwDC3:Activate()
	oBrwSBE:Activate()
	oBrwDCH:Activate()
	oBrwSC9:Activate()
	oBrwSDC:Activate()
	oBrwDCF:Activate()
	oBrwSC2:Activate()
	oBrwSD4:Activate()
	oBrwSB2:Activate()
	oBrwDH1:Activate()


	// Ativa Relacionamentos
	oRelSB8:Activate()
	oRelSDD:Activate()
	oRelDC3:Activate()
	oRelSBE:Activate()
	oRelDCH:Activate()
	oRelSC9:Activate()
	oRelSDC:Activate()
	oRelDCF:Activate()
	oRelSC2:Activate()
	oRelSD4:Activate()
	oRelDH1:Activate()

	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
Return(Nil)

Static Function RetFilSB2()
Local aAreaAnt   := GetArea()
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cFiltro := ""
	dbSelectArea("SBZ")
	cFiltro :=     " B2_LOCAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cFiltro += " AND B2_COD    BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cFiltro += " AND B2_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	If cDadosProd == 'SBZ'
		cFiltro += " AND (EXISTS (SELECT 1"
		cFiltro +=                " FROM "+RetSqlName("SBZ")+" SBZ"
		cFiltro +=               " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
		cFiltro +=                 " AND SBZ.BZ_COD     = B2_COD"
		cFiltro +=                 " AND SBZ.BZ_LOCALIZ IN (' ','S')"
		cFiltro +=                 " AND SBZ.BZ_CTRWMS  IN (' ','1')"
		cFiltro +=                 " AND SBZ.D_E_L_E_T_ = ' ')"
		cFiltro +=      " OR ( NOT EXISTS (SELECT 1"
		cFiltro +=                         " FROM "+RetSqlName("SBZ")+" SBZ"
		cFiltro +=                        " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
		cFiltro +=                          " AND SBZ.BZ_COD     = B2_COD"
		cFiltro +=                          " AND SBZ.BZ_LOCALIZ IN (' ','S')"
		cFiltro +=                          " AND SBZ.BZ_CTRWMS  IN (' ','1')"
		cFiltro +=                          " AND SBZ.D_E_L_E_T_ = ' ')"
	EndIf
	cFiltro +=           " AND EXISTS (SELECT 1"
	cFiltro +=                         " FROM "+RetSqlName("SB5")+" SB5"
	cFiltro +=                        " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cFiltro +=                           " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cFiltro +=                          " AND SB1.B1_COD = SB5.B5_COD"
	cFiltro +=                          " AND SB1.B1_LOCALIZ = 'S'"
	cFiltro +=                          " AND SB1.D_E_L_E_T_ = ' '"
	cFiltro +=                        " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
	cFiltro +=                          " AND SB5.B5_COD = B2_COD"
	cFiltro +=                          " AND SB5.B5_CTRWMS = '1'"
	cFiltro +=                          " AND SB5.D_E_L_E_T_ = ' ')"
	If cDadosProd == 'SBZ'
		cFiltro +="))"
	EndIf	
	RestArea(aAreaAnt)
Return cFiltro
//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Busca Data Ultimo Fechamento

/*/
//-----------------------------------------------------------
Static Function GetUltFech()
Local aAreaSB2    := SB2 -> (GetArea())
Local cAliasSB9  := GetNextAlias()
Local dUltFech
	BeginSql Alias cAliasSB9
		SELECT MAX(SB9.B9_DATA)B9_DATA
		FROM %Table:SB9% SB9
		WHERE SB9.B9_FILIAL = %xFilial:SB9%
		AND SB9.B9_LOCAL = %Exp:SB2->B2_LOCAL%
		AND SB9.B9_COD = %Exp:SB2->B2_COD%
		AND SB9.B9_DATA < %Exp:DTOS(dDatabase)%
		AND SB9.%NotDel%
	EndSql
	TcSetField(cAliasSB9,'B9_DATA','D')
	dUltFech := (cAliasSB9)->B9_DATA
	(cAliasSB9)->( DBCloseArea())
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
@obs Busca Norma

/*/
//-----------------------------------------------------------
Static Function GetNorma(cCodNor)
Local aAreaDC2    := DC2 -> (GetArea())
Local aDC2_LASTRO := TamSx3("DC2_LASTRO")
Local aDC2_CAMADA := TamSx3("DC2_CAMADA")
Local cAliasDC2   := GetNextAlias()
Local nNorma      := 0

	BeginSql Alias cAliasDC2
		SELECT DC2.DC2_LASTRO,
				DC2.DC2_CAMADA
		FROM %Table:DC2% DC2
		WHERE DC2.DC2_FILIAL = %xFilial:DC2%
		AND DC2.DC2_CODNOR = %Exp:cCodNor%
		AND DC2.%NotDel%
	EndSql
	TcSetField(cAliasDC2,'DC2_LASTRO','N',aDC2_LASTRO[1],aDC2_LASTRO[2])
	TcSetField(cAliasDC2,'DC2_CAMADA','N',aDC2_CAMADA[1],aDC2_CAMADA[2])
	If (cAliasDC2)->(!Eof())
		nNorma := (cAliasDC2)->DC2_LASTRO * (cAliasDC2)->DC2_CAMADA
	EndIf
	RestArea(aAreaDC2)
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
	aSaldos := SetSaldos()
	aPedido := SetPedido()
	aProduc := SetProduc()

	// Atualiza Saldos do Produto
	oDispo:CtrlRefresh()
	oAtual:CtrlRefresh()
	oReser:CtrlRefresh()
	oEmpen:CtrlRefresh()
	oEnder:CtrlRefresh()
	oQtTNP:CtrlRefresh()
	oQtNPT:CtrlRefresh()

	// Atualiza Saldos Pedidos
	oBCred:CtrlRefresh()
	oBEst:CtrlRefresh()
	oSEmp:CtrlRefresh()
	oCEmp:CtrlRefresh()

	// Atualiza Saldos Produção
	oBloq:CtrlRefresh()
	oProd:CtrlRefresh()
	oPedido:CtrlRefresh()
	oEmpNF:CtrlRefresh()
	oEmpSA:CtrlRefresh()

	If lastLocal <> SB2->B2_LOCAL .Or. lastProd <> SB2->B2_COD
		lastLocal := SB2->B2_LOCAL
		lastProd  := SB2->B2_COD
		// Ajusta tree
		WMSA335TRE(oTree, SB2->B2_COD)
		oTree:PTRefresh()
		oTree:TreeSeek(SB2->B2_COD)
		C015CARGO()
	EndIf
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
	aRet := {SaldoSB2(), SB2->B2_QATU, SB2->B2_RESERVA, SB2->(B2_QEMP+B2_QEMPSA+B2_QEMPN), SB2->B2_QACLASS, SB2->B2_QTNP, SB2->B2_QNPT}
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
Local aRet 	     := {}
Local aAreaAnt   := GetArea()
Local cAliasSC9  := GetNextAlias()
Local nCredi     := 0
Local nEstoq     := 0
Local nBloq      := 0
Local nLiber     := 0

	// Calculo bloqueado crédito, bloqueado estoque e liberado
	BeginSql Alias cAliasSC9
		SELECT SC9.C9_BLCRED,
				SC9.C9_QTDLIB,
				SC9.C9_BLEST,
				SC9.C9_BLWMS
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_LOCAL = %Exp:SB2->B2_LOCAL%
		AND SC9.C9_PRODUTO = %Exp:SB2->B2_COD%
		AND SC9.C9_NFISCAL = %Exp:Space(TamSx3('C9_NFISCAL')[1])%
		AND SC9.C9_REMITO = %Exp:Space(TamSx3('C9_REMITO')[1])%
		AND SC9.%NotDel%
	EndSql
	Do While (cAliasSC9)->(!Eof())
		Do Case
			Case !Empty((cAliasSC9)->C9_BLCRED)
				nCredi += (cAliasSC9)->C9_QTDLIB
			Case !Empty((cAliasSC9)->C9_BLEST)
				nEstoq += (cAliasSC9)->C9_QTDLIB
			Case (cAliasSC9)->C9_BLWMS = '01'
				nBloq += (cAliasSC9)->C9_QTDLIB
			OtherWise
				nLiber += (cAliasSC9)->C9_QTDLIB
		EndCase
		(cAliasSC9)->(dbSkip())
	Enddo
	(cAliasSC9)->(dbCloseArea())
	aRet := {nCredi,nEstoq,nBloq,nLiber}
	RestArea(aAreaAnt)
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
Local aRet 	     := {}
Local aAreaAnt   := GetArea()
Local cAliasSDC  := Nil
Local cAliasSD4  := Nil
Local cOrigem    := ""
Local nBloqu     := 0 
Local nProdu     := 0
Local nEmpPe     := 0
	// Calculo empenhado e bloqueado
	cAliasSDC := GetNextAlias()
	cOrigem := 'SC6'
	BeginSql Alias cAliasSDC
		SELECT SUM(SDC.DC_QUANT) DC_QUANT
		FROM %Table:SDC% SDC
		WHERE SDC.DC_FILIAL = %xFilial:SDC%
		AND SDC.DC_LOCAL = %Exp:SB2->B2_LOCAL%
		AND SDC.DC_PRODUTO = %Exp:SB2->B2_COD%
		AND SDC.DC_ORIGEM = %Exp:cOrigem%
		AND SDC.%NotDel%
	EndSql
	If (cAliasSDC)->(!Eof())
		nEmpPe := (cAliasSDC)->DC_QUANT
	EndIf
	(cAliasSDC)->(dbCloseArea())
	cAliasSDC := GetNextAlias()
	cOrigem := 'SDD'
	BeginSql Alias cAliasSDC
		SELECT SUM(SDC.DC_QUANT) DC_QUANT
		FROM %Table:SDC% SDC
		WHERE SDC.DC_FILIAL = %xFilial:SDC%
		AND SDC.DC_LOCAL = %Exp:SB2->B2_LOCAL%
		AND SDC.DC_PRODUTO = %Exp:SB2->B2_COD%
		AND SDC.DC_ORIGEM = %Exp:cOrigem%
		AND SDC.%NotDel%
	EndSql
	If (cAliasSDC)->(!Eof())
		nBloqu := (cAliasSDC)->DC_QUANT
	EndIf
	(cAliasSDC)->(dbCloseArea())
	// Calculo produção
	cAliasSD4 := GetNextAlias()
	BeginSql Alias cAliasSD4
		SELECT SUM(SD4.D4_QUANT) D4_QUANT
		FROM %Table:SD4% SD4
		WHERE D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_LOCAL = %Exp:SB2->B2_LOCAL%
		AND SD4.D4_COD = %Exp:SB2->B2_COD%
		AND SD4.%NotDel%
	EndSql
	If (cAliasSD4)->(!Eof())
		nProdu += (cAliasSD4)->D4_QUANT
	EndIf
	(cAliasSD4)->(dbCloseArea())
	aRet := {nBloqu, nProdu, nEmpPe , SB2->B2_QEMPN , SB2->B2_QEMPSA}
	RestArea(aAreaAnt)
Return aRet

Static Function KardexSld()
	Processa({|| ProcRegua(0), IncProc(STR0025 + '...'), WMSC015A(SB2->B2_LOCAL,SB2->B2_COD), IncProc(STR0026 + '...')} , STR0024, STR0036 + '...', .F.) // Aguarde, Encerrando, Kardex, Buscando informações
Return .T.

Static Function KardexLot()
	Processa({|| ProcRegua(0), IncProc(STR0025 + '...'), WMSC015B(SB2->B2_LOCAL,SB2->B2_COD), IncProc(STR0026 + '...')} , STR0024, STR0036 + '...', .F.) // Aguarde, Encerrando, Kardex, Buscando informações
Return .T.

Static Function KardexEnd()
	Processa({|| ProcRegua(0), IncProc(STR0025 + '...'), WMSC015C(SB2->B2_LOCAL,D14->D14_PRODUT,SB2->B2_COD), IncProc(STR0026 + '...')} , STR0024, STR0036 + '...', .F.) // Aguarde, Encerrando, Kardex, Buscando informações
Return .T.

Function C015CARGO()
Local cFilter
Local oProdComp := WMSDTCProdutoComponente():New()
	oProdComp:SetProduto(oTree:GetCargo())
	cFilter := "D14_FILIAL = '" + xFilial('D14') + "' .And. D14_LOCAL = '" + SB2->B2_LOCAL + "' .And. D14_PRDORI = '" + SB2->B2_COD + IIf(oProdComp:IsDad(),"'","' .And. D14_PRODUT = '"+ oTree:GetCargo() + "'")
	D14->(dbClearFilter())
	oBrwD14:SetFilterDefault(cFilter)
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
			oBrwD14:Refresh()
		Case nFolder == 4
			oBrwDC3:Refresh()
		Case nFolder == 5
			oBrwSBE:Refresh()
		Case nFolder == 6
			oBrwDCH:Refresh()
		Case nFolder == 7
			oBrwSC9:Refresh()
		Case nFolder == 8
			oBrwSDD:Refresh()
		Case nFolder == 9
			oBrwSDC:Refresh()
		Case nFolder == 10
			oBrwDCF:Refresh()
		Case nFolder == 11
			oBrwSC2:Refresh()
		Case nFolder == 12
			oBrwSD4:Refresh()
		Case nFolder == 13
			oBrwDH1:Refresh()
	EndCase
Return .T.
