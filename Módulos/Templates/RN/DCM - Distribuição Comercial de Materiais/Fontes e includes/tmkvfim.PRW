#INCLUDE "tmkvfim.ch"
#INCLUDE "rwmake.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณTMKVFIM    บAutor  ณEwerton C Tomaz     บ Data ณ  11/29/00    บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.    ณ P.E. acionado apos a grava็ใo do C5 e C6 para gravar C9 e    บฑฑ
ฑฑบ         ณ Empenhos                                                     บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP5                                                          บฑฑ
ฑฑฬอออออออออุออออออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista ณ Data/Bops/Ver  ณManutencao Efetuada                          บฑฑ
ฑฑฬอออออออออุอออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบConrado Qณ04/04/07 ณ10    ณBOPS 122711: Alterada a utiliza็ใo da chamadaบฑฑ
ฑฑบ         ณ         ณ      ณSubStr(cUsuario,7,15) por cUserName          บฑฑ
ฑฑศอออออออออฯอออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TMKVFIM(cNumSUA,cNumSC5)
Private _aArea
Private _nItem,_lOk,_cNumSc5,_cNumSUA,_nCustoGer,_nCustoTot,_nValTot,_nDivisao,_nPesoL,_nValCon
Private _nPesoB,_aGrupos,_nPosItem, _nPosProd,_nQtdVen,_nDispo,_nQtdLib,_nMix,_nPosDel
Private _cRegras, _cCondBloq

_aArea := T_SRArea('S',nil)

_nItem    := 1
_lOk      := .T.
_cNumSC5  := cNumSC5 
If _cNumSC5 <> SUA->UA_NUMSC5
   _cNumSC5  := SUA->UA_NUMSC5
EndIf   

_cNumSUA  := cNumSUA
If _cNumSUA <> SUA->UA_NUM
   _cNumSUA  := SUA->UA_NUM
EndIf  

_nCustoGer:= 0
_nCustoTot:= 0
_nValTot  := 0
_nValCon  := 0
_nDivisao := 0
_nPesoL   := 0
_nPesoB   := 0
_aGrupos  := {}
_nQtdVen  := 0
_nDispo   := 0
_nQtdLib  := 0
_nMix     := 0

DbSelectArea("SA1")
DbSetOrder(1)

DbSelectArea("SUA")
DbSetOrder(1)

DbSelectArea("SUB")
DbSetorder(1)

DbSelectArea("SB0")
DbSetOrder(1)

DbSelectarea("SB1")
DbSetOrder(1)

DbSelectArea('SB2')
DbSetOrder(1)

DbSelectarea("SF4")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)

DbSelEctArea("SC5")
DbSetOrder(1) 

DbSelectArea("SYP")
DbSetOrder(1)

DbSelectArea("LH7")
DbSetOrder(1)

DbSelectArea("LH9")
DbSetOrder(1)

DbSelectArea('SU0')
DbSetOrder(1)
If !DbSeek(xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
	T_SRArea('R',_aArea)
	MsgStop(STR0001) //'Grupo de Atendimento nao Encontrado!'
	Return(.F.)
Endif

_nPosDel := Len(aHeader)+ 1

If Alltrim(M->UA_OPER) == "1"
	
	_nPosItem := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='UB_ITEM'})
	_nPosProd := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='UB_PRODUTO'})
	_cRegras  := ''
	
	SUB->(DbSeek(xFilial('SUB')+_cNumSUA))
	
	While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .AND. SUB->UB_NUM == _cNumSUA
		
		SB1->(Dbseek(xfilial("SB1")+SUB->UB_PRODUTO))
		
		LH7->(Dbseek(xfilial("LH7")+SUB->UB_PRODUTO))
		
		_nValTot   += SUB->UB_VLRITEM
		_nCustoUni := LH7->LH7_PRCL
		_nCustoTot := SUB->UB_QUANT * _nCustoUni
		_nCustoGer += _nCustoTot
		
		If AsCan(_aGrupos,SB1->B1_GRUPO) = 0
			AaDd(_aGrupos,SB1->B1_GRUPO)
		EndIf
		
		_nValConOk := T_BuscaValCon(M->UA_CLIENTE,SUB->UB_PRODUTO)
		If _nValConOk
			If !((!Empty(LH4->LH4_NUMORC) .And. LH4->LH4_NUMORC = _cNumSUA) .Or. Empty(LH4->LH4_NUMORC))
				_nValConOk := .F.
			EndIf
		EndIf
		
		If !_nValConOk
			_lOk := VerBloqPre(_lOk)
		Else
			_nValCon += SUB->UB_VRUNIT
		Endif
		
		LH9->(DbSeek(xFilial('LH9')+'I'))
		While LH9->(!Eof()) .AND. LH9->LH9_FILIAL == xFilial('LH9') .AND. SubStr(LH9->LH9_CODIGO,1,1)=='I'
			If &(LH9->LH9_REGRA)	                    
		       _cRegras += LH9->LH9_CODIGO+';'
		    EndIf               
			LH9->(DbSkip())
		End  
		
		DbSelectArea("SUB")
		DbSkip()
	End  
	
	LH9->(DbSeek(xFilial('LH9')+'C'))
	While LH9->(!Eof()) .AND. LH9->LH9_FILIAL == xFilial('LH9') .AND. SubStr(LH9->LH9_CODIGO,1,1)=='C'
		If &(LH9->LH9_REGRA)	                    
	       _cRegras += LH9->LH9_CODIGO+';'
	    Endif               
		LH9->(DbSkip())
	End  
	
	SA1->(DbSeek(xFilial('SA1')+SUA->UA_CLIENTE+SUA->UA_LOJA))
	
	_cCondBloq := ""
	
	cBlo := maAvalCred(SUA->UA_CLIENTE,SUA->UA_LOJA,_nValTot,1,.T.,@_cCondBloq)
	
	If cBlo .And. (SA1->A1_RISCO = 'E' .Or. _nValTot > (SA1->A1_LC-(SA1->A1_SALDUP+SA1->A1_SALPEDL)))
		cBlo       := .F.
		_cCondBloq := "99"
	EndIf

    SUB->(DbSeek(xFilial("SUB")+_cNumSUA))
	While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .AND. SUB->UB_NUM == _cNumSUA
		
		SB0->(DbSeek(xFilial("SB0")+SUB->UB_PRODUTO))
		
		SB1->(Dbseek(xfilial("SB1")+SUB->UB_PRODUTO))
		_cGrupo := SB1->B1_GRUPO
		
		SF4->(Dbseek(xfilial("SF4")+SUB->UB_TES))
		
		SC6->(DbSeek(xfilial("SC6")+SUA->UA_NUMSC5+SUB->UB_ITEM+SUB->UB_PRODUTO))
		
		_nQtdVen := SC6->C6_QTDVEN
		_nQtdLib := SC6->C6_QTDVEN
		_nDispo  := 0
		
		If SB2->(DbSeek(xFilial('SB2')+SC6->C6_PRODUTO+SC6->C6_LOCAL))
			_nMix := 0
			If T_BuscaSalCon(M->UA_CLIENTE,SC6->C6_PRODUTO) = 0
				_nMix := T_BuscaSalCon('',SC6->C6_PRODUTO)
			EndIf
			_nDispo   := SB2->(SaldoMov()) - _nMix
			RecLock("SB2",.F.)
			If (_nDispo >= SC6->C6_QTDVEN) 
				SB2->B2_QPEDVEN += SC6->C6_QTDVEN
			Else
				_nQtdLib := U_VerSegUm(SUB->UB_SEGUM,SC6->C6_PRODUTO,_nDispo,SUB->UB_UNSVEN)
				If _nQtdLib > 0			
					SB2->B2_RESERVA += _nQtdLib
				Else
					_nQtdLib := SC6->C6_QTDVEN
					SB2->B2_QPEDVEN += SC6->C6_QTDVEN
				EndIf
			EndIf
			SB2->(MsUnLock())
		EndIf
		
		RecLock("SUB",.F.)
		SUB->UB_QTDANT := SUB->UB_QUANT
		MsUnLock()
		
		DbSelectArea('SC6')
		
		RecLock("SC6",.F.)
		SC6->C6_OP 		:= "02"
		SC6->C6_TPOP	:= "F"
		SC6->C6_DESCRI  := SB1->B1_DESC
		SC6->C6_COMISSA	:= SUB->UB_COMISSA
		SC6->C6_PERCOM	:= SUB->UB_PERCOM
		SC6->C6_ITEMCLI := SUB->UB_ITEMCLI
		SC6->C6_SEGUM 	:= SUB->UB_SEGUM
		SC6->C6_UNSVEN	:= SUB->UB_UNSVEN
		SC6->C6_QTDANT	:= SUB->UB_QTDANT
		SC6->C6_QTDLIB	:= _nQtdLib
		If SU0->U0_PEDAUT == 'S'
			SC6->C6_IMPRE := 'R01'
		EndIf
		MsUnlock()
		
		_nPesoL    += (SB1->B1_PESO * SUB->UB_QUANT)
		_nPesoB    += (SB1->B1_PESBRU * SUB->UB_QUANT)
		
		DbSelectArea("SC9")
		RecLock("SC9",.T.)
		SC9->C9_FILIAL 	:= xFilial("SC9")
		SC9->C9_PEDIDO 	:= SUA->UA_NUMSC5
		SC9->C9_ITEM	:= SC6->C6_ITEM
		SC9->C9_CLIENTE := SC6->C6_CLI
		SC9->C9_LOJA	:= SC6->C6_LOJA
		SC9->C9_PRODUTO := SC6->C6_PRODUTO
		SC9->C9_LOCAL   := SC6->C6_LOCAL
		SC9->C9_QTDLIB	:= _nQtdLib
		SC9->C9_DATALIB := dDataBase
		SC9->C9_SEQUEN	:= "01"
		SC9->C9_PRCVEN 	:= SC6->C6_PRCVEN
		SC9->C9_DATALIB	:= dDatabase
		SC9->C9_GRUPO   := _cGrupo
		SC9->C9_VEND    := SUA->UA_VEND
		SC9->C9_BLCRED  := If(cBlo,"  ",_cCondBloq)
		SC9->C9_BLINF   := _cRegras		
		SC9->C9_ENDPAD  := SC6->C6_LOCALIZ
	    SC9->C9_TPCARGA := '3'					
		
		If _lOk .And. Empty(_cRegras)
			SC9->C9_BLPRE := Upper(Rtrim(cUserName))+" "+DTOC(dDatabase)+" "+Time()
		EndIf

		DbSelectArea("SC9")
		If SC6->C6_QTDVEN > _nDispo
			SC9->C9_BLEST  := '02'
			_nQtdLib := U_VerSegUm(SC6->C6_SEGUM,SC6->C6_PRODUTO,_nDispo,SC6->C6_UNSVEN)
			If _nQtdLib > 0
				SC9->C9_BLEST  := '  '
				SC9->C9_QTDLIB := _nQtdLib
				_nQtdVen  -= _nQtdLib
			Else
				_nQtdVen  := 0
			Endif
		Else
			_nQtdVen  := 0
		Endif
		If SU0->U0_PEDAUT == 'S' .And. Empty(SC9->C9_BLEST) 
			SC9->C9_BLCONF := 'OK'
		EndIf
		MsUnlock()
		
		U_fa450Grava(1,.F.,.F.,.F.)
		
		If !Empty(SC9->C9_BLCRED)
			RecLock('SA1',.F.)
			SA1->A1_SALPEDB += (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
			MsUnlock()
		ElseIf Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
			RecLock('SA1',.F.)
			SA1->A1_SALPEDL += (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
			MsUnlock()
		EndIf
		
		If _nQtdVen > 0
			RecLock("SC9",.T.)
			SC9->C9_FILIAL 	:= xFilial("SC9")
			SC9->C9_PEDIDO 	:= SUA->UA_NUMSC5
			SC9->C9_ITEM	:= SC6->C6_ITEM
			SC9->C9_CLIENTE := SC6->C6_CLI
			SC9->C9_LOJA	:= SC6->C6_LOJA
			SC9->C9_PRODUTO := SC6->C6_PRODUTO
			SC9->C9_LOCAL   := SC6->C6_LOCAL
			SC9->C9_QTDLIB	:= _nQtdVen
			SC9->C9_SEQUEN	:= "02"
			SC9->C9_PRCVEN 	:= SC6->C6_PRCVEN
			SC9->C9_DATALIB	:= dDatabase
			SC9->C9_GRUPO 	:= Posicione('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO,'B1_GRUPO')
			SC9->C9_BLEST   := "02"
			SC9->C9_VEND    := SUA->UA_VEND
			SC9->C9_BLCRED  := If(cBlo,"  ",_cCondBloq)
			SC9->C9_BLINF   := _cRegras	  
			SC9->C9_ENDPAD  := SC6->C6_LOCALIZ					
		    SC9->C9_TPCARGA := '3'			
			
			If _lOk .And. Empty(_cRegras)
				SC9->C9_BLPRE := Upper(Rtrim(cUserName))+" "+DTOC(dDatabase)+" "+Time()
			EndIf
			MsUnlock()
			
			U_fa450Grava(1,.F.,.F.,.T.)
			
			If !Empty(SC9->C9_BLCRED)
				RecLock('SA1',.F.)
				SA1->A1_SALPEDB += (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
				MsUnlock()
			ElseIf Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
				RecLock('SA1',.F.)
				SA1->A1_SALPEDL += (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
				MsUnlock()
			Endif
			
		EndIf
		
		DbSelectArea("SUB")
		DbSkip()		
	End  
	
	RecLock("SUA",.F.)
	SUA->UA_CODREQ := M->UA_CODREQ
	SUA->UA_NOMEREQ:= M->UA_NOMEREQ
	SUA->UA_REQCLI := M->UA_REQCLI
	MsUnlock()
	
	DbSelEctArea("SC5")
	DbSetOrder(1) 
	If SC5->(DbSeek(xfilial("SC5")+_cNumSc5))
	   RecLock("SC5",.F.)
	   SC5->C5_TIPLIB     := If(SUA->UA_FATINT="S","2","1")
	   SC5->C5_LIBEROK    := "S"
	   SC5->C5_TRANSP	  := SUA->UA_TRANSP
	   SC5->C5_CODREQ     := SUA->UA_CODREQ
	   SC5->C5_REQCLI     := SUA->UA_REQCLI
	   SC5->C5_NOMEREQ    := SUA->UA_NOMEREQ
	   SC5->C5_ENDENT     := SUA->UA_ENDENT 
	   SC5->C5_BAIRROE    := SUA->UA_BAIRROE
	   SC5->C5_MUNE       := SUA->UA_MUNE 
	   SC5->C5_ESTE       := SUA->UA_ESTE 
	   SC5->C5_CEPE       := SUA->UA_CEPE 
	   SC5->C5_MENNOTA    := SUA->UA_OBSDCM
	   SC5->C5_FATINT     := SUA->UA_FATINT
	   SC5->C5_AGLUTIN    := SUA->UA_AGLUTIN
	   SC5->C5_CONDPAG    := If(!Empty(SUA->UA_CONDPG),SUA->UA_CONDPG,SA1->A1_COND)
	   SC5->C5_TPFRETE    := SUA->UA_TPFRETE
	   SC5->C5_PESOL      := _nPesoL
	   SC5->C5_PBRUTO     := _nPesoB
	   SC5->C5_TPCARGA    := "3"
	   MsUnlock()
	Endif
	
Endif

T_SRArea('R',_aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณVerSegUm   บAutor  ณEwerton C Tomaz     บ Data ณ  11/29/00    บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.    ณ 															   บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP5                                                          บฑฑ
ฑฑฬอออออออออุออออออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista ณ Data/Bops/Ver  ณManutencao Efetuada                          บฑฑ
ฑฑศอออออออออฯอออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VerSegUm(_cCodSeg,_cCodPro,_nQtdLib,_nQtdSeg)
_nQtdRet := _nQtdLib
If !Empty(_cCodSeg)
	_nQtdEmb := IIF(_cCodSeg=SB1->B1_UM,1,;
	IIF(_cCodSeg=SB1->B1_SEGUM,SB1->B1_CONV,;
	IIF(_cCodSeg=SB1->B1_UM3,SB1->B1_UM3FAT,;
	IIF(_cCodSeg=SB1->B1_UM4,SB1->B1_UM4FAT,1))))
	_nQtdEmb2 := Int(_nQtdLib/_nQtdEmb)
	_nQtdRet := IIF((_nQtdEmb*_nQtdSeg)<=_nQtdLib,_nQtdEmb*_nQtdSeg,_nQtdEmb2*_nQtdEmb)
Endif
Return(_nQtdRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณVerBloqPre บAutor  ณEwerton C Tomaz     บ Data ณ  11/29/00    บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.    ณ 															   บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP5                                                          บฑฑ
ฑฑฬอออออออออุออออออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista ณ Data/Bops/Ver  ณManutencao Efetuada                          บฑฑ
ฑฑศอออออออออฯอออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VerBloqPre(lOk)
Local _cPrePro   := 'LH7->LH7_PRO'+Alltrim(SU0->U0_CODIGO)
Local _cPreProDI := 'LH7->LH7_DATI'+Alltrim(SU0->U0_CODIGO)
Local _cPreProDF := 'LH7->LH7_DATF'+Alltrim(SU0->U0_CODIGO)
_cPrePro   := &_cPrePro
_cPreProDI := &_cPreProDI
_cPreProDF := &_cPreProDF
If lOk .And. (SUB->UB_VRUNIT < SUB->UB_VLRMIN .OR. SUB->UB_VRUNIT > SUB->UB_VLRMAX)
	If !(!Empty(_cPrePro) .And. _cPrePro = SUB->UB_VRUNIT .And.;
	   dDatabase >= _cPreProDI .And. dDatabase <= _cPreProDF)
		Return(.F.)
	Endif
Endif
Return(.T.)

